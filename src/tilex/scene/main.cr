module Tilex
  class Scene::Main < GSDL::Scene
    @canvas : GSDL::RootCanvas
    @handler : GSDL::EventHandler

    def initialize
      super(:main)

      # canvas
      @canvas = GSDL::RootCanvas.new(App.width, App.height)
      @handler = Scene::EventHandler.new(@canvas)
      App.instance.register_event_handler(@handler)

      vbox = @canvas.add_child(GSDL::VBox.new)

      # vbox canvas box test
      box = vbox.add_child(GSDL::Canvas.new)
      box.flex = 1_u8
      box.background_color = GSDL::Color::Magenta
      box.padding = GSDL::UISpacing.new(all: 32)
      box.margin = GSDL::UISpacing.new(all: 16)
      box_inner = box.add_child(GSDL::Canvas.new)
      box_inner.margin = GSDL::UISpacing.new(all: 16)
      box_inner.background_color = GSDL::Color::LimeGreen

      # vbox -> status bar
      status_bar = vbox.add_child(GSDL::StatusBar.new(spacing: 32, anchor: GSDL::Anchor::BottomLeft))
      status_bar.flex = 0_u8
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
