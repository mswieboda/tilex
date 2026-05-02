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
        Window.open_file
      end
      file_menu.append_item("Quit").on_clicked do
        UIng.quit
        # Keep your standalone exit hack for the debug builds
        {% if flag?(:darwin) && flag?(:standalone) %}
          exit(0)
        {% end %}
      end
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

      # button
      button = UIng::Button.new("Click me")
      button.on_clicked do
        Window.msg_box("Info", "Button clicked!")
      end

      # Window.set_child(button)
      vbox.append(button)

      # area
      handler = UIng::Area::Handler.new
      # handler.on_mouse_event do |event|
      #   if event.button == 1 # Left Click
      #     tile_x = (event.x / 32).to_i
      #     tile_y = (event.y / 32).to_i
      #     puts "Placing tile at: #{tile_x}, #{tile_y}"
      #     # Update your map model here!
      #   end
      # end

      area = UIng::Area.new(handler)

      vbox.append(area, true) # The 'true' here tells the box to expand and fill space

      Window.set_child(vbox)
    end
  end

  Window = UIng::Window.new("Hello World", Width, Height, menubar: true, margined: true)
end
