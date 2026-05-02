require "./scene/main"

module Tilex
  class App < GSDL::Game
    def initialize
      super(
        title: "tilex",
        width: 1280,
        height: 768,
        resizable: true,
        high_pixel_density: true,
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
