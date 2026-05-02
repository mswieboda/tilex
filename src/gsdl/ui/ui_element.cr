module GSDL
  abstract class UIElement
    # Basic Transform
    getter x : Int32 = 0
    getter y : Int32 = 0
    setter width : Int32 = -1
    setter height : Int32 = -1

    # The Box Model
    property margin : UISpacing = UISpacing.new(all: 0)
    property padding : UISpacing = UISpacing.new(all: 0)
    property border_width : Int32 = 0

    # Aesthetics
    property background_color : Color?
    property foreground_color : Color = Color::White

    # Layout Logic (For things like Bottom Bar alignment)
    property anchor : Anchor = Anchor::TopLeft
    property z_index : Int32 = 0

    # Tree Structure
    property? visible : Bool = true
    property children = [] of UIElement
    property parent : UIElement?

    @position_dirty : Bool = true
    @global_position_cache : {Int32, Int32} = {0, 0}

    abstract def draw(draw : Draw)

    def x=(x : Int32)
      return if @x == x
      @x = x
      dirty!
    end

    def y=(y : Int32)
      return if @y == y
      @y = y
      dirty!
    end

    def anchor=(anchor : Anchor)
      return if @anchor == anchor
      @anchor = anchor
      dirty!
    end

    protected def dirty!
      return if @position_dirty

      @position_dirty = true

      # Notify children that their global positions are now invalid
      @children.each(&.dirty!)
    end

    protected def position_dirty? : Bool
      @position_dirty || (@parent && @parent.not_nil!.position_dirty?) || false
    end

    def width : Int32
      return @width if @width != -1
      return 0 if @children.empty?

      # Find the furthest right edge among children
      @children.max_of { |c| c.x + c.width }
    end

    def height : Int32
      return @height if @height != -1
      return 0 if @children.empty?

      # Find the furthest bottom edge among children
      h = @children.max_of { |c| c.y + c.height }
    end
    
    def add_child(child : UIElement)
      # 1. Prevent adding the same child twice
      return child if @children.includes?(child)

      # 2. If the child already has a different parent, remove it from there first
      if old_parent = child.parent
        old_parent.remove_child(child)
      end

      # 3. Set the bidirectional relationship
      child.parent = self

      @children << child

      child
    end

    def remove_child(child : UIElement)
      if @children.delete(child)
        child.parent = nil
      end

      child
    end

    # Useful helper to clear a container (like a toolbar)
    def clear_children
      @children.each { |c| c.parent = nil }
      @children.clear
    end

    # Logic to calculate the "Actual" draw position based on parent/anchors
    # TODO: might eventually want to "dirty-flag" and cache this value
    # if parent/children usages get heavy and deeply nested
    def global_position : {Int32, Int32}
      # If we or our parent are dirty, we must recalculate
      if @position_dirty || (@parent && @parent.not_nil!.position_dirty?)
        @global_position_cache = calculate_global_position
        @position_dirty = false
      end

      @global_position_cache
    end

    def calculate_global_position
      # 1. Start with the local relative offset
      base_x = self.x + @margin.left
      base_y = self.y + @margin.top

      # 2. If there's no parent, we are at the root (window level)
      if (p = @parent).nil?
        return {base_x, base_y}
      end

      # 3. Get the parent's global position first (recursion)
      px, py = p.global_position
      pw, ph = p.width, p.height

      # Add parent's padding to the starting point
      px += p.padding.left
      py += p.padding.top

      # Note: parent width/height used for anchors should be "inner" size
      inner_pw = pw - p.padding.left - p.padding.right
      inner_ph = ph - p.padding.top - p.padding.bottom

      # 4. Calculate the anchor point relative to the parent's dimensions
      anchor_offset_x, anchor_offset_y = calculate_anchor_offset(inner_pw, inner_ph)

      # 5. Result is Parent_Pos + Anchor_Point + Local_Offset
      {px + anchor_offset_x + base_x, py + anchor_offset_y + base_y}
    end

    def global_x
      global_position[0]
    end

    def global_y
      global_position[1]
    end

    # Returns the {x, y} of the visible Background/Padding Box
    def inner_position : {Int32, Int32}
      gx, gy = global_position
      {gx + @margin.left, gy + @margin.top}
    end

    # The 'Inner' coordinate: Start of the Padding/Background.
    # Logic: Global Position + Margin.
    def inner_x : Int32
      global_x + @margin.left
    end

    # The 'Inner' coordinate: Start of the Padding/Background.
    # Logic: Global Position + Margin.
    def inner_y : Int32
      global_y + @margin.top
    end

    # The 'Visible' dimension: The box that gets a background color.
    # Logic: Internal width + padding on both sides.
    def inner_width
      width + @padding.horizontal
    end

    # The 'Visible' dimension: The box that gets a background color.
    # Logic: Internal width + padding on both sides.
    def inner_height
      height + @padding.vertical
    end

    private def calculate_anchor_offset(parent_width : Int32, parent_height : Int32) : {Int32, Int32}
      # The full width/height including the padding box and the margins
      full_width = self.inner_width + @margin.horizontal
      full_height = self.inner_height + @margin.vertical

      x_offset = case @anchor
      when .top_left?, .center_left?, .bottom_left?
        0
      when .top_center?, .center?, .bottom_center?
        (parent_width - full_width) // 2
      when .top_right?, .center_right?, .bottom_right?
        parent_width - full_width
      else
        0
      end

      y_offset = case @anchor
      when .top_left?, .top_center?, .top_right?
        0
      when .center_left?, .center?, .center_right?
        (parent_height - full_height) // 2
      when .bottom_left?, .bottom_center?, .bottom_right?
        parent_height - full_height
      else
        0
      end

      {x_offset, y_offset}
    end
  end
end
