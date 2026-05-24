module Tilex
  class Scene::EventHandler < GSDL::EventHandler
    @canvas : GSDL::RootCanvas

    def initialize(@canvas : GSDL::RootCanvas)
    end

    def handle(event : GSDL::Event, window : SDL3::Window) : Bool
      if event.type == GSDL::Events::WindowResized
        size = window.size
        @canvas.resize(size[0], size[1])
      end

      false # Event passed through
    end
  end
end
