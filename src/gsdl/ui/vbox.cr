require "./box_layout"

module GSDL
  class VBox < BoxLayout
    def layout!
      return if @children.empty?

      # PASS 1: Measurement
      # Ensure all children measure themselves so their footprints are accurate.
      @children.each(&.layout!)

      # PASS 2: Proportions
      # Now that fixed children know their size, we can calculate the flex-shares
      calculate_flex_sizes(self.height, is_horizontal: false)

      # PASS 3: Sequencing
      current_y = 0
      @children.each do |child|
        child.x = 0
        child.y = current_y
        current_y += child.footprint_height + @spacing
      end

      @dirty_layout = false
    end
  end
end
