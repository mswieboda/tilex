require "./box_layout"

module GSDL
  class HBox < BoxLayout
    def layout!
      return if @children.empty?

      # PASS 1: Measurement
      # Ensure all children measure themselves so their footprints are accurate.
      @children.each(&.layout!)

      # PASS 2: Proportions
      # Now that fixed children know their size, we can calculate the flex-shares
      calculate_flex_sizes(self.width, is_horizontal: true)

      # PASS 3: Sequencing
      current_x = 0
      @children.each do |child|
        child.x = current_x
        child.y = 0
        current_x += child.footprint_width + @spacing
      end

      @dirty_layout = false
    end
  end
end
