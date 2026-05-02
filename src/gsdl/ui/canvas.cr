require "./container"

module GSDL
  class Canvas < Container
    def initialize(
      @width : Int32 = FillParent,
      @height : Int32 = FillParent,
      @x : Int32 = 0,
      @y : Int32 = 0,
      @anchor : Anchor = Anchor::Center,
      @background_color : Color = Color::Transparent,
    )
    end
  end

  class RootCanvas < Canvas
    def initialize(@width : Int32, @height : Int32)
      super(
        width: width,
        height: height,
        x: 0,
        y: 0,
        anchor: Anchor::TopLeft
      )
    end

    # The Root is the end of the line, it returns its own x,y (0,0)
    def global_position : {Int32, Int32}
      @dirty = false # Clear the flag so the ripple stops
      {@x, @y}
    end


    # Critical: Update this when the user resizes the window
    def resize(width : Int32, height : Int32)
      self.width = width
      self.height = height
    end
  end
end
