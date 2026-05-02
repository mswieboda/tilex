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

      vbox = @canvas.add_child(GSDL::VBox.new(width: GSDL::FillParent, height: GSDL::FillParent))

      # vbox canvas box test
      box = vbox.add_child(GSDL::Canvas.new(width: GSDL::FillParent, height: GSDL::FillParent))
      box.background_color = GSDL::Color::Magenta
      box.padding = GSDL::UISpacing.new(all: 32)
      box.margin = GSDL::UISpacing.new(all: 16)
      box_inner = box.add_child(GSDL::Canvas.new)
      box_inner.margin = GSDL::UISpacing.new(all: 16)
      box_inner.background_color = GSDL::Color::LimeGreen

      # vbox -> status bar
      status_bar = @canvas.add_child(GSDL::StatusBar.new(spacing: 32))
      status_bar.margin = GSDL::UISpacing.new(horizontal: 16, vertical: 8)
      status_bar.padding = GSDL::UISpacing.new(horizontal: 64, vertical: 32)

      # status bar -> text
      font = GSDL::Font.default(32_f32)
      text = status_bar.add_child(GSDL::UIText.new(font, "Pos: 0,0"))
      status_bar.add_child(GSDL::UIText.new(font, "Layer: Background"))
      status_bar.add_child(GSDL::UIText.new(font, "Zoom: 100%"))

      # log_e(@canvas, "@canvas")
      # log_e(vbox, "vbox")
      # log_e(box, "box")
      # log_e(box_inner, "box_inner")

      # TODO: for some reason needs this log to render correctly
      # log_e(status_bar, "status_bar")

      # log_e(text, "text")
    end

    def log_e(e : GSDL::UIElement, name : String)
      puts ">>> #{name}"
      puts ">>> \tm trbl: #{{e.margin.top, e.margin.right, e.margin.bottom, e.margin.left}}"
      puts ">>> \tp trbl: #{{e.padding.top, e.padding.right, e.padding.bottom, e.padding.left}}"
      puts ">>> relative:\t pos: #{{e.x, e.y}}\tsize: #{e.width}x#{e.height}"
      puts ">>> inner:\t pos: #{{e.inner_x, e.inner_y}}\tsize: #{e.inner_width}x#{e.inner_height}"
      puts ">>> content:\t pos: #{{e.content_x, e.content_y}}\tsize: #{e.content_width}x#{e.content_height}"
      puts ">>> footprint:\t pos: #{{e.footprint_x, e.footprint_y}}\tsize: #{e.footprint_width}x#{e.footprint_height}"
      puts
      puts
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
