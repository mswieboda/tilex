require "./ui_element"

module GSDL
  class StatusBar < UIElement
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
            x: inner_x, # - self.padding.left,
            y: inner_y, # - self.padding.top,
            w: inner_width, # + padding.right,
            h: inner_height, # + padding.bottom
          ),
          color: color,
          z_index: z_index
        )
      end

      children.each(&.draw(draw))
    end
  end
end
