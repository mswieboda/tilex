require "./box_layout"

module GSDL
  class VBox < BoxLayout
    def layout!
      current_y = 0

      children.each do |child|
        child.y = current_y
        child.x = 0
        current_y += child.inner_height + child.margin.vertical + @spacing
      end

      @dirty_layout = false
    end
  end
end
