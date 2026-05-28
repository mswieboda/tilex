module Tilex
  class Scene::Main < GSDL::Scene
    getter canvas : GSDL::RootCanvas
    @handler : Scene::EventHandler
    @viewport : GSDL::Viewport

    # Track status elements
    @status_pos : GSDL::UIText
    @status_zoom : GSDL::UIText

    # Track interactive buttons
    @btn_zoom_in : GSDL::Canvas
    @btn_zoom_out : GSDL::Canvas
    @btn_zoom_reset : GSDL::Canvas
    @btn_pan_reset : GSDL::Canvas
    @btn_clip_toggle : GSDL::Canvas

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

      # --- LEFT SIDEBAR (Help & Info) ---
      panel_left = hbox.add_child(GSDL::Canvas.new)
      panel_left.flex = 1_u8
      panel_left.background_color = SidebarDark
      panel_left.padding = GSDL::UISpacing.new(all: 16)
      panel_left.z_index = 10

      panel_left.add_child(GSDL::UIText.new(
        text: "NAVIGATION HELP",
        font_size: 20,
        color: AccentIndigo,
        x: 0, y: 10,
        width: GSDL::FillParent
      ))

      help_text = "• Right-Click + Drag\n  to pan around\n\n• Mouse Scroll Wheel\n  to zoom on cursor\n\n• WASD or Arrow Keys\n  to slide camera\n\n• Click side buttons\n  for direct actions\n\n• Press ESC to quit"
      panel_left.add_child(GSDL::UIText.new(
        text: help_text,
        font_size: 16,
        color: TextLight,
        x: 0, y: 50,
        width: GSDL::FillParent
      ))

      # --- CENTER VIEWPORT (The zoomable/panning area) ---
      @viewport = GSDL::Viewport.new
      @viewport.flex = 4
      @viewport.background_color = BgDark
      @viewport.z_index = 50
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
      card1.add_child(GSDL::UIText.new(text: "Interactive Panel A\nx: 50, y: 50", font_size: 18, color: TextLight))

      # Card 2 (Center-Right)
      card2 = @viewport.add_child(GSDL::Canvas.new(
        width: 300, height: 200, x: 450, y: 150
      ))
      card2.background_color = AccentViolet
      card2.padding = GSDL::UISpacing.new(all: 16)
      card2.add_child(GSDL::UIText.new(text: "Interactive Panel B\nx: 450, y: 150", font_size: 18, color: TextLight))

      # Card 3 (Way Out of Bounds to verify panning and clipping)
      card3 = @viewport.add_child(GSDL::Canvas.new(
        width: 400, height: 150, x: 900, y: 400
      ))
      card3.background_color = GSDL::Color.parse("#0ea5e9") # Sky blue
      card3.padding = GSDL::UISpacing.new(all: 16)
      card3.add_child(GSDL::UIText.new(text: "Far-right Element\nx: 900, y: 400", font_size: 18, color: TextLight))

      # --- RIGHT SIDEBAR (Control Buttons) ---
      panel_right = hbox.add_child(GSDL::Canvas.new)
      panel_right.width = 200
      panel_right.flex = 0_u8
      panel_right.background_color = SidebarDark
      panel_right.padding = GSDL::UISpacing.new(all: 16)
      panel_right.z_index = 10

      panel_right.add_child(GSDL::UIText.new(
        text: "VIEWPORT CONTROLS",
        font_size: 18,
        color: AccentViolet,
        x: 0, y: 10
      ))

      # Custom styled buttons using Canvas + hover state detection in update()
      button_height = 40
      button_width = 168

      @btn_zoom_in = panel_right.add_child(GSDL::Canvas.new(width: button_width, height: button_height, x: 0, y: 50))
      @btn_zoom_in.background_color = ButtonDefault
      @btn_zoom_in.padding = GSDL::UISpacing.new(all: 8)
      @btn_zoom_in.add_child(GSDL::UIText.new(text: "Zoom In (+)", font_size: 16, color: TextLight))

      @btn_zoom_out = panel_right.add_child(GSDL::Canvas.new(width: button_width, height: button_height, x: 0, y: 100))
      @btn_zoom_out.background_color = ButtonDefault
      @btn_zoom_out.padding = GSDL::UISpacing.new(all: 8)
      @btn_zoom_out.add_child(GSDL::UIText.new(text: "Zoom Out (-)", font_size: 16, color: TextLight))

      @btn_zoom_reset = panel_right.add_child(GSDL::Canvas.new(width: button_width, height: button_height, x: 0, y: 150))
      @btn_zoom_reset.background_color = ButtonDefault
      @btn_zoom_reset.padding = GSDL::UISpacing.new(all: 8)
      @btn_zoom_reset.add_child(GSDL::UIText.new(text: "Reset Zoom (1x)", font_size: 16, color: TextLight))

      @btn_pan_reset = panel_right.add_child(GSDL::Canvas.new(width: button_width, height: button_height, x: 0, y: 200))
      @btn_pan_reset.background_color = ButtonDefault
      @btn_pan_reset.padding = GSDL::UISpacing.new(all: 8)
      @btn_pan_reset.add_child(GSDL::UIText.new(text: "Reset Pan", font_size: 16, color: TextLight))

      @btn_clip_toggle = panel_right.add_child(GSDL::Canvas.new(width: button_width, height: button_height, x: 0, y: 250))
      @btn_clip_toggle.background_color = ButtonDefault
      @btn_clip_toggle.padding = GSDL::UISpacing.new(all: 8)
      @btn_clip_toggle.add_child(GSDL::UIText.new(text: "Clip: OFF", font_size: 16, color: TextLight))

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
      if GSDL::Keys.just_pressed?(GSDL::Keys::Escape)
        transition_out.start
      end

      # 1. WASD/Arrow keys keyboard panning (camera moves relative to zoom level)
      pan_speed = 400_f32 * dt / @viewport.zoom
      if GSDL::Keys.pressed?(GSDL::Keys::W) || GSDL::Keys.pressed?(GSDL::Keys::Up)
        @viewport.pan_y -= pan_speed
      end
      if GSDL::Keys.pressed?(GSDL::Keys::S) || GSDL::Keys.pressed?(GSDL::Keys::Down)
        @viewport.pan_y += pan_speed
      end
      if GSDL::Keys.pressed?(GSDL::Keys::A) || GSDL::Keys.pressed?(GSDL::Keys::Left)
        @viewport.pan_x -= pan_speed
      end
      if GSDL::Keys.pressed?(GSDL::Keys::D) || GSDL::Keys.pressed?(GSDL::Keys::Right)
        @viewport.pan_x += pan_speed
      end

      # 2. Right-click dragging to pan
      if GSDL::Mouse.dragging?(GSDL::Mouse::ButtonRight)
        @viewport.pan_x -= GSDL::Mouse.dx / @viewport.zoom
        @viewport.pan_y -= GSDL::Mouse.dy / @viewport.zoom
      end

      # 3. Mouse Wheel zoom (handled globally using Mouse.wheel_y)
      if GSDL::Mouse.in?(@viewport.content_x, @viewport.content_y, @viewport.width, @viewport.height)
        wy = GSDL::Mouse.wheel_y
        if wy != 0
          zoom_factor = wy > 0 ? 1.1_f32 : 1.0_f32 / 1.1_f32
          @viewport.zoom_to(@viewport.zoom * zoom_factor, GSDL::Mouse.x, GSDL::Mouse.y)
        end
      end

      # 4. Button Interactions & Micro-animations (hover transitions)
      update_button(@btn_zoom_in) do
        @viewport.zoom_to(@viewport.zoom * 1.25_f32)
      end

      update_button(@btn_zoom_out) do
        @viewport.zoom_to(@viewport.zoom / 1.25_f32)
      end

      update_button(@btn_zoom_reset) do
        @viewport.zoom_to(1.0_f32)
      end

      update_button(@btn_pan_reset) do
        @viewport.pan_x = 0_f32
        @viewport.pan_y = 0_f32
      end

      update_button(@btn_clip_toggle) do
        @viewport.clips_children = !@viewport.clips_children?
        text_element = @btn_clip_toggle.children.first.as?(GSDL::UIText)
        if text_element
          text_element.text = "Clip: #{@viewport.clips_children? ? "ON" : "OFF"}"
        end
      end

      # 5. Update Status bar text dynamically
      @status_pos.text = "Pan: #{@viewport.pan_x.round.to_i}, #{@viewport.pan_y.round.to_i}"
      @status_zoom.text = "Zoom: #{(@viewport.zoom * 100).round.to_i}%"
    end

    private def update_button(btn : GSDL::Canvas, &on_click_block)
      if GSDL::Mouse.in?(btn.content_x, btn.content_y, btn.content_width, btn.content_height)
        btn.background_color = AccentIndigo
        if GSDL::Mouse.just_pressed?(GSDL::Mouse::ButtonLeft)
          yield
        end
      else
        btn.background_color = ButtonDefault
      end
    end

    def draw_screen_overlay(draw : GSDL::Draw)
      @canvas.draw(draw)
    end

    def destroy
      App.instance.unregister_event_handler(@handler)
    end
  end
end
