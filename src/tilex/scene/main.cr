module Tilex
  class Scene::Main < GSDL::Scene
    @canvas : GSDL::RootCanvas
    @handler : GSDL::EventHandler

    def initialize
      transition_in = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::In,
        duration: 0.75_f32,
        started: true
      )
      transition_out = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::Out,
        duration: 0.5_f32
      )

      super(:main, transition_in: transition_in, transition_out: transition_out)

      # canvas
      @canvas = GSDL::RootCanvas.new(App.width, App.height)
      @handler = Scene::EventHandler.new(@canvas)
      App.instance.register_event_handler(@handler)

      # canvas -> status bar
      status_bar = @canvas.add_child(GSDL::StatusBar.new(spacing: 32))
      status_bar.margin = GSDL::UISpacing.new(horizontal: 16, vertical: 8)
      status_bar.padding = GSDL::UISpacing.new(horizontal: 64, vertical: 32)

      # canvas -> status bar -> text
      font = GSDL::Font.default(32_f32)
      text = status_bar.add_child(GSDL::UIText.new(font, "Pos: 0,0"))
      status_bar.add_child(GSDL::UIText.new(font, "Layer: Background"))
      status_bar.add_child(GSDL::UIText.new(font, "Zoom: 100%"))

      # canvas box test
      box = @canvas.add_child(GSDL::Canvas.new)
      box.background_color = GSDL::Color::Magenta
      box.padding = GSDL::UISpacing.new(all: 32)
      box.margin = GSDL::UISpacing.new(all: 16)
      box_inner = box.add_child(GSDL::Canvas.new)
      box_inner.margin = GSDL::UISpacing.new(all: 16)
      box_inner.background_color = GSDL::Color::LimeGreen
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
