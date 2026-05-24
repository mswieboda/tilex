module Tilex
  class Scene::Main < GSDL::Scene
    getter canvas : GSDL::RootCanvas
    @handler : GSDL::EventHandler

    def initialize
      super(:main)

      # canvas
      @canvas = GSDL::RootCanvas.new(App.width, App.height)
      @handler = Scene::EventHandler.new(@canvas)
      App.instance.register_event_handler(@handler)

      vbox = @canvas.add_child(GSDL::VBox.new)

      # vbox canvas box test
      hbox = vbox.add_child(GSDL::HBox.new)
      hbox.flex = 1
      hbox.background_color = GSDL::Color::Magenta

      # left panels
      panel_left = hbox.add_child(GSDL::Canvas.new)
      panel_left.background_color = GSDL::Color::Blue

      # main center panel
      panel_main = hbox.add_child(GSDL::Canvas.new)
      panel_main.flex = 4
      panel_main.background_color = GSDL::Color::LimeGreen

      # right panel
      panel_right = hbox.add_child(GSDL::Canvas.new)
      panel_right.flex = 0
      panel_right.width = 33
      panel_right.background_color = GSDL::Color::Purple

      # Add oversized, overflowing text to right panel for visual clipping verification
      panel_left.add_child(GSDL::UIText.new(text: "Oversized Overflowing Clipping Text Element", font_size: 32))

      # vbox -> status bar
      status_bar = vbox.add_child(GSDL::StatusBar.new(spacing: 32, anchor: GSDL::Anchor::BottomLeft))
      status_bar.flex = 0
      status_bar.margin = GSDL::UISpacing.new(horizontal: 16, vertical: 8)
      status_bar.padding = GSDL::UISpacing.new(all: 8)
      status_bar.background_color = GSDL::Color::Red

      # status bar -> text
      status_bar.add_child(GSDL::UIText.new(text: "Pos: 0,0", font_size: 32))
      status_bar.add_child(GSDL::UIText.new(text: "Layer: Background", font_size: 32))
      status_bar.add_child(GSDL::UIText.new(text: "Zoom: 100%", font_size: 32))
    end

    def update(dt : Float32)
      if GSDL::Keys.just_pressed?(GSDL::Keys::Escape)
        transition_out.start
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
