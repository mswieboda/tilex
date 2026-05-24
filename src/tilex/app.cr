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
      self.target_fps = 60

      push(Scene::Main.new)

      # Register the resize event watcher to bypass the OS modal resize loop
      SDL3.add_event_watch(RESIZE_WATCHER, nil)
    end

    def load_default_font
      "fonts/Electrolize-Regular.ttf"
    end

    def destroy
      SDL3.remove_event_watch(RESIZE_WATCHER, nil)
      super
    end
  end
end
