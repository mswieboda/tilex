require "./ui_element"

module GSDL
  class Canvas < UIElement
    def initialize(@width : Int32, @height : Int32, @x = 0, @y = 0)
      @anchor = Anchor::TopLeft # Root is always fixed to the window origin
    end

    # The Root is the end of the line, it returns its own x,y (0,0)
    def global_position : {Int32, Int32}
      {@x, @y}
    end

    def draw(draw)
      children.each(&.draw(draw))
    end
    
    # Critical: Update this when the user resizes the window
    def resize(width : Int32, height : Int32)
      @width = width
      @height = height
    end
  end
end
