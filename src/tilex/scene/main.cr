module Tilex
  class Scene::Main < GSDL::Scene
    getter canvas : GSDL::RootCanvas
    @handler : Scene::EventHandler
    @viewport : GSDL::Viewport

    # Track status elements
    @status_pos : GSDL::UIText
    @status_zoom : GSDL::UIText

    # Track interactive buttons
    @btn_zoom_in : GSDL::UIButton
    @btn_zoom_out : GSDL::UIButton
    @btn_zoom_reset : GSDL::UIButton
    @btn_pan_reset : GSDL::UIButton
    @btn_clip_toggle : GSDL::UIButton
    @movable_box : GSDL::Canvas

    # Colors
    BgDark = GSDL::Color.parse("#121214")      # Obsidian
    PanelDark = GSDL::Color.parse("#18181c")   # Dark Gray
    SidebarDark = GSDL::Color.parse("#1e1e24") # Medium Slate
    AccentIndigo = GSDL::Color.parse("#4f46e5") # Indigo
    AccentViolet = GSDL::Color.parse("#7c3aed") # Violet
    ButtonDefault = GSDL::Color.parse("#2e2e38") # Charcoal
    TextLight = GSDL::Color.parse("#f4f4f5")     # Off-white

    def initialize
      super(:main)

      # Canvas
      @canvas = GSDL::RootCanvas.new(App.width, App.height)

      # VBox - Main Vertical Layout
      vbox = @canvas.add_child(GSDL::VBox.new)

      # HBox - Sidebar | Viewport | Controls
      hbox = vbox.add_child(GSDL::HBox.new)
      hbox.flex = 1
      hbox.background_color = BgDark

      # --- LEFT SIDEBAR (Controls & Theme) ---
      panel_left = hbox.add_child(GSDL::Canvas.new)
      panel_left.width = 280
      panel_left.flex = 0_u8
      panel_left.background_color = SidebarDark
      panel_left.padding = GSDL::UISpacing.new(all: 16)
      panel_left.z_index = 10
      panel_left.swallows_events = true

      left_vbox = panel_left.add_child(GSDL::VBox.new(spacing: 8))
      left_vbox.flex = 1_u8

      # --- CENTER VIEWPORT (The zoomable/panning area) ---
      @viewport = GSDL::Viewport.new
      @viewport.flex = 4
      @viewport.background_color = BgDark
      @viewport.z_index = 50
      @viewport.clips_children = true
      hbox.add_child(@viewport)

      # Instantiating the input event handler
      @handler = Scene::EventHandler.new(@canvas, @viewport)
      App.instance.register_event_handler(@handler)

      # Let's add gorgeous test objects inside the Viewport to display zooming/clipping
      # Card 1 (Center-Left)
      card1 = @viewport.add_child(GSDL::Canvas.new(
        width: 300, height: 200, x: 50, y: 50
      ))
      card1.background_color = AccentIndigo
      card1.padding = GSDL::UISpacing.new(all: 16)
      # card1.swallows_events = true
      card1.add_child(GSDL::UIText.new(text: "Interactive Panel A\nx: 50, y: 50", font_size: 18, color: TextLight))

      # Card 2 (Center-Right)
      card2 = @viewport.add_child(GSDL::Canvas.new(
        width: 300, height: 200, x: 450, y: 150
      ))
      card2.background_color = AccentViolet
      card2.padding = GSDL::UISpacing.new(all: 16)
      # card2.swallows_events = true
      card2.add_child(GSDL::UIText.new(text: "Interactive Panel B\nx: 450, y: 150", font_size: 18, color: TextLight))

      # Card 3 (Way Out of Bounds to verify panning and clipping)
      card3 = @viewport.add_child(GSDL::Canvas.new(
        width: 400, height: 150, x: 900, y: 400
      ))
      card3.background_color = GSDL::Color.parse("#0ea5e9") # Sky blue
      card3.padding = GSDL::UISpacing.new(all: 16)
      card3.swallows_events = true
      card3.add_child(GSDL::UIText.new(text: "Far-right Element\nx: 900, y: 400", font_size: 18, color: TextLight))

      # --- SIDEBAR INTERACTIVE FORM ELEMENTS ---
      title_theme = left_vbox.add_child(GSDL::UIText.new(
        text: "THEME & CONTROLS",
        font_size: 18,
        color: AccentIndigo
      ))
      title_theme.flex = 0_u8
      title_theme.margin = GSDL::UISpacing.new(0, 0, 8, 0)

      # Checkbox to toggle card visibility in the viewport
      cb_cards_visible = left_vbox.add_child(GSDL::UICheckbox.new(
        text: "Show Viewport Cards",
        checked: true,
        hover_text_color: AccentIndigo
      ))
      cb_cards_visible.flex = 0_u8
      cb_cards_visible.margin = GSDL::UISpacing.new(0, 0, 16, 0)
      cb_cards_visible.on_toggle = ->(checked : Bool) {
        card1.visible = checked
        card2.visible = checked
        card3.visible = checked
      }

      # Radio button group to change the background color of panel_left
      lbl_theme = left_vbox.add_child(GSDL::UIText.new(
        text: "Left Sidebar Theme:",
        font_size: 14,
        color: TextLight
      ))
      lbl_theme.flex = 0_u8
      lbl_theme.margin = GSDL::UISpacing.new(0, 0, 8, 0)

      radio_dark = left_vbox.add_child(GSDL::UIRadioButton.new(
        text: "Default Dark Theme",
        group: :left_theme,
        checked: true,
        hover_text_color: AccentIndigo
      ))
      radio_dark.flex = 0_u8
      radio_dark.margin = GSDL::UISpacing.new(0, 0, 6, 0)
      radio_dark.on_select = -> {
        panel_left.background_color = SidebarDark
      }

      radio_indigo = left_vbox.add_child(GSDL::UIRadioButton.new(
        text: "Deep Indigo Theme",
        group: :left_theme,
        checked: false,
        hover_text_color: AccentIndigo
      ))
      radio_indigo.flex = 0_u8
      radio_indigo.margin = GSDL::UISpacing.new(0, 0, 6, 0)
      radio_indigo.on_select = -> {
        panel_left.background_color = GSDL::Color.parse("#1e1b4b")
      }

      radio_violet = left_vbox.add_child(GSDL::UIRadioButton.new(
        text: "Midnight Violet Theme",
        group: :left_theme,
        checked: false,
        hover_text_color: AccentIndigo
      ))
      radio_violet.flex = 0_u8
      radio_violet.on_select = -> {
        panel_left.background_color = GSDL::Color.parse("#120b24")
      }


      # --- RIGHT SIDEBAR (Control Buttons) ---
      panel_right = hbox.add_child(GSDL::Canvas.new)
      panel_right.width = 200
      panel_right.flex = 0_u8
      panel_right.background_color = SidebarDark
      panel_right.padding = GSDL::UISpacing.new(all: 16)
      panel_right.z_index = 10
      panel_right.swallows_events = true

      panel_right.add_child(GSDL::UIText.new(
        text: "VIEWPORT CONTROLS",
        font_size: 18,
        color: AccentViolet,
        x: 0, y: 10
      ))

      # Custom styled buttons using Canvas + hover state detection in update()
      button_height = 40
      button_width = 168

      @btn_zoom_in = panel_right.add_child(GSDL::UIButton.new(
        text: "Zoom In (+)",
        width: button_width,
        height: button_height,
        x: 0,
        y: 50,
        font_size: 16,
        default_background_color: ButtonDefault,
        hover_background_color: AccentIndigo,
        default_text_color: TextLight,
        hover_text_color: TextLight
      ) do
        @viewport.zoom_to(@viewport.zoom * 1.25_f32)
      end)

      @btn_zoom_out = panel_right.add_child(GSDL::UIButton.new(
        text: "Zoom Out (-)",
        width: button_width,
        height: button_height,
        x: 0,
        y: 100,
        font_size: 16,
        default_background_color: ButtonDefault,
        hover_background_color: AccentIndigo,
        default_text_color: TextLight,
        hover_text_color: TextLight
      ) do
        @viewport.zoom_to(@viewport.zoom / 1.25_f32)
      end)

      @btn_zoom_reset = panel_right.add_child(GSDL::UIButton.new(
        text: "Reset Zoom (1x)",
        width: button_width,
        height: button_height,
        x: 0,
        y: 150,
        font_size: 16,
        default_background_color: ButtonDefault,
        hover_background_color: AccentIndigo,
        default_text_color: TextLight,
        hover_text_color: TextLight
      ) do
        @viewport.zoom_to(1.0_f32)
      end)

      @btn_pan_reset = panel_right.add_child(GSDL::UIButton.new(
        text: "Reset Pan",
        width: button_width,
        height: button_height,
        x: 0,
        y: 200,
        font_size: 16,
        default_background_color: ButtonDefault,
        hover_background_color: AccentIndigo,
        default_text_color: TextLight,
        hover_text_color: TextLight
      ) do
        @viewport.pan_x = 0_f32
        @viewport.pan_y = 0_f32
      end)

      @btn_clip_toggle = panel_right.add_child(GSDL::UIButton.new(
        text: "Clip: ON",
        width: button_width,
        height: button_height,
        x: 0,
        y: 250,
        font_size: 16,
        default_background_color: ButtonDefault,
        hover_background_color: AccentIndigo,
        default_text_color: TextLight,
        hover_text_color: TextLight
      ))

      @btn_clip_toggle.on_click = -> {
        @viewport.clips_children = !@viewport.clips_children?
        @btn_clip_toggle.text = "Clip: #{@viewport.clips_children? ? "ON" : "OFF"}"
      }

      # Test Movable Box
      @movable_box = panel_right.add_child(GSDL::Canvas.new(
        width: 60, height: 60, x: 10, y: 320
      ))
      @movable_box.background_color = GSDL::Color.parse("#f43f5e") # Pink
      @movable_box.z_index = 100
      @movable_box.swallows_events = true

      # --- STATUS BAR ---
      status_bar = vbox.add_child(GSDL::StatusBar.new(spacing: 8))
      status_bar.flex = 0
      status_bar.margin = GSDL::UISpacing.new(horizontal: 16, vertical: 8)
      status_bar.padding = GSDL::UISpacing.new(all: 8)
      status_bar.background_color = PanelDark
      status_bar.z_index = 20

      font_size = 24
      @status_pos = GSDL::UIText.new(text: "Pan: 0, 0", font_size: font_size, v_align: GSDL::VerticalAlign::Center)
      @status_layer = GSDL::UIText.new(text: "Tilex Active Viewport", font_size: font_size, h_align: GSDL::HorizontalAlign::Center, v_align: GSDL::VerticalAlign::Center)
      @status_zoom = GSDL::UIText.new(text: "Zoom: 100%", font_size: font_size, h_align: GSDL::HorizontalAlign::Right, v_align: GSDL::VerticalAlign::Bottom)

      status_bar.add_child(@status_pos)
      status_bar.add_child(@status_layer)
      status_bar.add_child(@status_zoom)
    end

    def update(dt : Float32)
      @canvas.update(dt)

      if GSDL::Keys.just_pressed?(GSDL::Keys::Escape)
        transition_out.start
      end

      # 1. WASD keyboard panning (camera moves relative to zoom level)
      pan_speed = 400_f32 * dt / @viewport.zoom
      if GSDL::Keys.pressed?(GSDL::Keys::W)
        @viewport.pan_y -= pan_speed
      end
      if GSDL::Keys.pressed?(GSDL::Keys::S)
        @viewport.pan_y += pan_speed
      end
      if GSDL::Keys.pressed?(GSDL::Keys::A)
        @viewport.pan_x -= pan_speed
      end
      if GSDL::Keys.pressed?(GSDL::Keys::D)
        @viewport.pan_x += pan_speed
      end

      # 2. Arrow keys move the pink test box
      box_speed = 300_f32 * dt
      if GSDL::Keys.pressed?(GSDL::Keys::Up)
        @movable_box.y -= box_speed.to_i
      end
      if GSDL::Keys.pressed?(GSDL::Keys::Down)
        @movable_box.y += box_speed.to_i
      end
      if GSDL::Keys.pressed?(GSDL::Keys::Left)
        @movable_box.x -= box_speed.to_i
      end
      if GSDL::Keys.pressed?(GSDL::Keys::Right)
        @movable_box.x += box_speed.to_i
      end

      # Only allow mouse interactions on the viewport if we aren't hovering over an event-swallowing UI element
      ui_element = @canvas.find_element_at(GSDL::Mouse.x, GSDL::Mouse.y)
      has_active_ui = ui_element && ui_element.swallows_events?

      # 2. Right-click dragging to pan
      if !has_active_ui && GSDL::Mouse.dragging?(GSDL::Mouse::ButtonRight)
        @viewport.pan_x -= GSDL::Mouse.dx / @viewport.zoom
        @viewport.pan_y -= GSDL::Mouse.dy / @viewport.zoom
      end

      # 3. Mouse Wheel zoom (handled globally using Mouse.wheel_y)
      if !has_active_ui && GSDL::Mouse.in?(@viewport.content_x, @viewport.content_y, @viewport.width, @viewport.height)
        wy = GSDL::Mouse.wheel_y
        if wy != 0
          zoom_factor = wy > 0 ? 1.1_f32 : 1.0_f32 / 1.1_f32
          @viewport.zoom_to(@viewport.zoom * zoom_factor, GSDL::Mouse.x, GSDL::Mouse.y)
        end
      end

      # 4. Update Status bar text dynamically
      @status_pos.text = "Pan: #{@viewport.pan_x.round.to_i}, #{@viewport.pan_y.round.to_i}"
      @status_zoom.text = "Zoom: #{(@viewport.zoom * 100).round.to_i}%"
    end

    def draw_screen_overlay(draw : GSDL::Draw)
      @canvas.draw(draw)
    end

    def destroy
      App.instance.unregister_event_handler(@handler)
    end
  end
end
