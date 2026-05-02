require "./container"

module GSDL
  class Canvas < Container
    def initialize(
      @width : Int32,
      @height : Int32,
      @x : Int32 = 0,
      @y : Int32 = 0,
      @anchor : Anchor = Anchor::Center,
      @background_color : Color = Color::Transparent,
    )
    end

    def draw(draw : Draw)
      # Draw the canvas background
      if color = @background_color
        draw.rect_fill(
          rect: FRect.new(
            x: inner_x,
            y: inner_y,
            w: inner_width,
            h: inner_height,
          ),
          color: color,
          z_index: z_index
        )
      end

      super # Draw children (game objects, UI, etc.)
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
      {@x, @y}
    end


    # Critical: Update this when the user resizes the window
    def resize(width : Int32, height : Int32)
      old = {self.width, self.height}

      self.width = width
      self.height = height

      # NOTE: not a full cascade, just to immediate children for now
      # current usage RootCanvas -> StatusBar
      if old != {self.width, self.height}
        @children.each do |child|
          if child.responds_to?(:parent_width=)
            child.parent_width = self.width
          end

          if child.responds_to?(:parent_height=)
            child.parent_width = self.height
          end
        end
      end
    end
  end
end
