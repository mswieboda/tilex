module Tilex
  class Scene::Main < GSDL::Scene
    @canvas : GSDL::RootCanvas
    @handler : GSDL::EventHandler
    @status_bar : GSDL::StatusBar

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

      puts ">>> App.width: #{App.width} App.window_width: #{App.window_width}"

      # canvas
      @canvas = GSDL::RootCanvas.new(App.width, App.height)
      @handler = Scene::EventHandler.new(@canvas)
      App.instance.register_event_handler(@handler)

      # canvas -> status bar
      @status_bar = GSDL::StatusBar.new(@canvas.width)
      @status_bar.padding = GSDL::UISpacing.new(horizontal: 16, vertical: 8)
      @canvas.add_child(@status_bar)

      # canvas -> status bar -> hbox
      layout = @status_bar.add_child(GSDL::HBox.new(spacing: 8))

      # canvas -> status bar -> hbox -> text
      font = GSDL::Font.default(64_f32)
      layout.add_child(GSDL::UIText.new(font, "Pos: 0,0"))
      layout.add_child(GSDL::UIText.new(font, "Layer: Background"))
      layout.add_child(GSDL::UIText.new(font, "Zoom: 100%"))
    end

    def update(dt : Float32)
      if GSDL::Keys.just_pressed?(GSDL::Keys::Escape)
        transition_out.start
      end
    end

    def draw_screen_overlay(draw : GSDL::Draw)
      super(draw)
      # @text.draw(draw)
      @canvas.draw(draw)
    end

    def destroy
      puts ">>> Scene::Main#destroy"
      App.instance.unregister_event_handler(@handler)
    end
  end
end
