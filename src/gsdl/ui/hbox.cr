require "./box_layout"

module GSDL
  class HBox < BoxLayout
    def layout!
      current_x = 0

      children.each do |child|
        child.x = current_x
        child.y = 0
        current_x += child.inner_width + child.margin.horizontal + @spacing
      end

      @layout_dirty = false
    end
  end
end
