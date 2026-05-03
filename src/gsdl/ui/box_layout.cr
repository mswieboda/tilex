require "./container"

module GSDL
  abstract class BoxLayout < Container
    property spacing : Int32 = 0

    @dirty_layout = true

    def initialize
      @spacing = 0
      @width = FillContent
      @height = FillContent
    end

    def initialize(@width = FillContent, @height = FitContent, @spacing = 0)
    end

    protected def dirty_layout!
      @dirty_layout = true
    end

    # Overriding add_child to mark the layout as "dirty"
    def add_child(child : UIElement)
      @dirty_layout = true
      super(child)
    end

    # Overriding remove_child to mark the layout as "dirty"
    def remove_child(child : UIElement)
      @dirty_layout = true
      super(child)
    end

    def draw(draw : Draw)
      layout! if @dirty_layout

      super(draw)
    end

    abstract def layout!
  end
end
