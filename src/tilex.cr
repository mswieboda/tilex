require "uing"

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

  # In your tilex.cr initialization:
  force_activate_macos()
  # Then start Uing...
{% end %}

module Tilex
  def self.run
    UIng.init

    window = UIng::Window.new("Hello World", 300, 200)
    window.on_closing do
      puts "Closing window..."
      UIng.quit

      # On macOS, if we are in .regular policy mode,
      # we sometimes need to nudge the process to finish.
      {% if flag?(:darwin) && flag?(:standalone) %}
        exit(0)
      {% end %}

      true
    end

    button = UIng::Button.new("Click me")
    button.on_clicked do
      window.msg_box("Info", "Button clicked!")
    end

    window.set_child(button)
    window.show

    puts "Calling UIng.main..."
    UIng.main
    puts "Cleaning up..."
    UIng.uninit

    puts "Exiting..."
    # {% unless flag?(:release) %}
    exit(0) # Force the process to terminate
    # {% end %}
  end
end

Tilex.run
