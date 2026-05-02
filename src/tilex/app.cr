require "./scene/main"

module Tilex
  class App < GSDL::Game
    def initialize
      super(
        title: "tilex",
        width: 800,
        height: 600,
        resizable: true,
        high_pixel_density: true,
        # TODO: use metal or vulkan if supported else, opengl, else nil
        renderer_type: :metal,
      )
    end

    def init
      push(Scene::Main.new)
    end

    def load_default_font
      "fonts/Electrolize-Regular.ttf"
    end
  end
end
