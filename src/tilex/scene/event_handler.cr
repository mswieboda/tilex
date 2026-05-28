module Tilex
  class Scene::EventHandler < GSDL::EventHandler
    @canvas : GSDL::RootCanvas
    @viewport : GSDL::Viewport

    def initialize(@canvas : GSDL::RootCanvas, @viewport : GSDL::Viewport)
    end

    def handle(event : GSDL::Event, window : SDL3::Window) : Bool
      if event.type == GSDL::Events::WindowResized
        size = window.size
        @canvas.resize(size[0], size[1])
        return false
      end

      # Route events through the RootCanvas first, but always return false to let GSDL update GSDL::Mouse state correctly
      @canvas.handle_event(event)

      false # Event passed through to update engine-internal mouse and input state
    end
  end
end
