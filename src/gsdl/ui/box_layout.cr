require "./container"

module GSDL
  abstract class BoxLayout < Container
    property spacing : Int32 = 0

    getter? layout_dirty : Bool = true

    def initialize(@spacing = 0)
      @width = -1
      @height = -1
    end

    # Overriding add_child to mark the layout as "dirty"
    def add_child(child : UIElement)
      @layout_dirty = true
      super
    end

    def draw(draw : Draw)
      layout! if @layout_dirty

      children.each(&.draw(draw))
    end

    abstract def layout!
  end
end
