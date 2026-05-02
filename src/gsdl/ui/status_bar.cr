require "./container"

module GSDL
  class StatusBar < Container
    def initialize(
      parent_width : Int32,
      @height : Int32 = -1,
      @anchor = Anchor::BottomLeft,
      @background_color = Color::DarkerGray,
    )
      @width = parent_width
    end

    def draw(draw : Draw)
      # Draw the background box
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

      children.each(&.draw(draw))
    end

    def parent_width=(parent_width : Int32)
      @width = parent_width
    end
  end
end
