module Tilex
  RESIZE_WATCHER = ->(userdata : Void*, event_ptr : LibSDL3::Event*) : Bool {
    event = event_ptr.value
    if event.type == LibSDL3::SDL_EVENT_WINDOW_RESIZED
      new_w = event.window.data1
      new_h = event.window.data2

      app = Tilex::App.instance
      scene = app.scene
      if scene.is_a?(Tilex::Scene::Main)
        canvas = scene.canvas
        canvas.resize(new_w, new_h)
        canvas.layout!

        app.clear_screen
        app.draw
      end
    end
    true
  }
end
