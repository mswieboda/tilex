{% if flag?(:darwin) && flag?(:standalone) %}
  # Tell the linker we need AppKit
  @[Link(framework: "AppKit")]
  lib LibObjC
    # The core of Objective-C: sending a message to an object
    # We use Void* for the objects (id) and selectors (SEL)
    fun msg_send = objc_msgSend(id : Void*, sel : Void*, ...) : Void*
    fun get_class = objc_getClass(name : UInt8*) : Void*
    fun get_sel = sel_registerName(name : UInt8*) : Void*
  end
{% end %}

module Tilex
  Width = 800
  Height = 600

  class App
    @image : UIng::Image?
    @image_width : Float64 = 0
    @image_height : Float64 = 0
    @area  : UIng::Area?

    {% if flag?(:darwin) && flag?(:standalone) %}
      def force_activate_macos
        # 1. Get the NSApplication class
        ns_app_class = LibObjC.get_class("NSApplication")

        # 2. Get the sharedApplication instance (NSApp)
        shared_app_sel = LibObjC.get_sel("sharedApplication")
        ns_app = LibObjC.msg_send(ns_app_class, shared_app_sel)

        # 3. Set activation policy to .regular (0)
        # This makes the app show up in the Dock and take focus
        set_policy_sel = LibObjC.get_sel("setActivationPolicy:")
        LibObjC.msg_send(ns_app, set_policy_sel, 0_i64)

        # 4. Activate the app, ignoring other apps
        activate_sel = LibObjC.get_sel("activateIgnoringOtherApps:")
        LibObjC.msg_send(ns_app, activate_sel, true)

        puts "macOS focus forced for tilex."
      end
    {% end %}

    def run
      {% if flag?(:darwin) && flag?(:standalone) %}
        force_activate_macos()
      {% end %}

      UIng.init

      create_menu_bar

      setup_window

      create_ui

      Window.show

      UIng.main
      UIng.uninit
    end

    def create_menu_bar
      file_menu = UIng::Menu.new("File")
      file_menu.append_item("Open").on_clicked do |w|
        if path = Window.open_file
          load_image(path)

          # Tell the area to repaint now that we have a new image
          puts ">>> @area.try(&.queue_redraw_all)"
          @area.try(&.queue_redraw_all)
        end
      end

      file_menu.append_item("Quit").on_clicked do
        UIng.quit
        # Keep your standalone exit hack for the debug builds
        {% if flag?(:darwin) && flag?(:standalone) %}
          exit(0)
        {% end %}
      end
    end

    def load_image(path)
      puts ">>> Loading image: #{path}"
      canvas = StumpyPNG.read(path)
      @image_width = canvas.width.to_f
      @image_height = canvas.height.to_f

      # 1. Create the UIng image object
      image = UIng::Image.new(canvas.width, canvas.height)

      # 2. Prepare a flat buffer for RGBA bytes
      # Total size = width * height * 4 (one byte each for R, G, B, A)
      buffer_size = canvas.width * canvas.height * 4
      buffer = Bytes.new(buffer_size)

      # 3. Fill the buffer
      i = 0

      # Note: Standard row-major order (y then x)
      (0...canvas.height).each do |y|
        (0...canvas.width).each do |x|
          # Force RGBA conversion to be sure
          r, g, b, a = canvas[x, y].to_rgba

          # REMOVE the >> 8 here
          buffer[i] = r.to_u8
          buffer[i + 1] = g.to_u8
          buffer[i + 2] = b.to_u8
          buffer[i + 3] = a.to_u8

          # Log just a few pixels to avoid flooding the terminal
          if (x == 0 && y == 0) || (x == canvas.width // 2 && y == canvas.height // 2)
            puts "Pixel at #{x},#{y} - Stumpy(16bit): R:#{r} G:#{g} B:#{b} A:#{a}"
            puts "Pixel at #{x},#{y} - Buffer(8bit):  R:#{buffer[i]} G:#{buffer[i + 1]} B:#{buffer[i + 2]} A: #{buffer[i + 3]}"
          end

          i += 4
        end
      end

      # 4. Append the buffer to the image
      # The second argument is the 'stride' (bytes per row), which is width * 4
      image.append(buffer, @image_width.to_i, @image_height.to_i, canvas.width * 4)

      @image = image
    end

    def setup_window
      Window.set_position(Width // 2, Height // 2)
      Window.on_closing do
        puts "Closing window..."
        UIng.quit

        # On macOS, if we are in .regular policy mode,
        # we sometimes need to nudge the process to finish.
        {% if flag?(:darwin) && flag?(:standalone) %}
          exit(0)
        {% end %}

        true
      end
    end

    def create_ui
      vbox = UIng::Box.new(:vertical, padded: true)

      # area
      handler = UIng::Area::Handler.new

      handler.draw do |area, params|
        puts ">>> handler draw area: #{params.area_width}x#{params.area_height}"
        # Only draw if we actually have an image loaded
        if img = @image
          puts ">>> handler draw image"
          # Draw the full image at coordinates (0, 0)
          w = @image_width.to_f
          h = @image_height.to_f
          params.context.draw_image(img, 0.0, 0.0, w, h)
        end
      end

      @area = UIng::Area.new(handler)
      vbox.append(@area.not_nil!, stretchy: true)

      Window.set_child(vbox)
    end
  end

  Window = UIng::Window.new("Hello World", Width, Height, menubar: true, margined: true)
end
