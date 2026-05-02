module Tilex
  class Scene::Main < GSDL::Scene
    # @text : GSDL::Text
    @canvas : GSDL::Canvas
    @status_bar : GSDL::StatusBar

    def initialize
      # transition_in = GSDL::FadeTransition.new(
      #   direction: GSDL::TransitionDirection::In,
      #   duration: 0.75_f32,
      #   started: true
      # )
      # transition_out = GSDL::FadeTransition.new(
      #   direction: GSDL::TransitionDirection::Out,
      #   duration: 0.5_f32
      # )

      # super(:main, transition_in: transition_in, transition_out: transition_out)
      super(:main)

      puts ">>> App.width: #{App.width} App.window_width: #{App.window_width}"

      @canvas = GSDL::Canvas.new(App.width, App.height)

      @status_bar = GSDL::StatusBar.new(@canvas.width)
      @status_bar.padding = GSDL::UISpacing.new(horizontal: 16, vertical: 8)

      layout = @status_bar.add_child(GSDL::HBox.new(spacing: 8))

      font = GSDL::Font.default(64_f32)
      layout.add_child(GSDL::UIText.new(font, "Pos: 0,0"))
      layout.add_child(GSDL::UIText.new(font, "Layer: Background"))
      layout.add_child(GSDL::UIText.new(font, "Zoom: 100%"))
      # @text = GSDL::UIText.new(
      #   font: GSDL::Font.default(24.0_f32),
      #   text: "tilex!",
      #   color: GSDL::Color.new(g: 255)
      # )
      # @status_bar.add_child(@text)


      @canvas.add_child(@status_bar)
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
  end
end
