module GSDL
  FillParent = -2
  FitContent = -1

  abstract class UIElement
    # Basic Transform
    getter x : Int32 = 0
    getter y : Int32 = 0

    getter width : Int32 = FitContent
    getter height : Int32 = FitContent

    # The Box Model
    property margin : UISpacing = UISpacing.new(all: 0)
    property padding : UISpacing = UISpacing.new(all: 0)

    # The "Shares" this element takes in a BoxLayout
    # 0 = Fixed/Fit, 1+ = Flex Fill
    getter flex : UInt8 = 0_u8

    # TODO: implement border
    # property border : UISpacing = UISpacing.new(all: 0)

    # Aesthetics
    property background_color : Color?
    property foreground_color : Color = Color::White

    # Layout Logic (For things like Bottom Bar alignment)
    getter anchor : Anchor = Anchor::TopLeft
    property z_index : Int32 = 0

    # Tree Structure
    property? visible : Bool = true
    property parent : UIElement?

    @dirty_position : Bool = true
    @global_position_cache : {Int32, Int32} = {0, 0}

    def draw(draw : Draw)
      draw_background(draw)
    end

    def draw_background(draw : Draw)
      if (color = @background_color) && !color.transparent?
        draw.rect_fill(
          rect: FRect.new(
            x: inner_x,
            y: inner_y,
            w: inner_width,
            h: inner_height,
          ),
          color: color,
          z_index: z_index,
        )
      end
    end

    def x=(x : Int32)
      return if @x == x
      @x = x
      dirty_position!
    end

    def y=(y : Int32)
      return if @y == y
      @y = y
      dirty_position!
    end

    def width=(width : Int32)
      return if @width == width
      @width = width
      dirty_position!
    end

    def height=(height : Int32)
      return if @height == height
      @height = height
      dirty_position!
    end

    def anchor=(anchor : Anchor)
      return if @anchor == anchor
      @anchor = anchor

      # When the anchor changes, we re-calculate our local x/y
      if p = @parent
        # This sets our internal @x and @y based on the new anchor
        apply_anchor!(p.width, p.height)
      end

      dirty_position!
    end

    def flex=(flex : UInt8)
      return if @flex == flex
      @flex = flex
      if p = @parent
        dirty_layout! if p.is_a?(Container)
      end
    end

    protected def dirty_position!
      @dirty_position = true
    end

    protected def dirty_position? : Bool
      @dirty_position || (@parent && @parent.not_nil!.dirty_position?) || false
    end

    def width_fixed? : Bool
      # It's fixed if it's a specific number OR if it's the RootCanvas
      return true if @width > 0 || self.is_a?(RootCanvas)

      # If I am a fill parent, I am only fixed if my parent is fixed
      if @width == FillParent && (p = @parent)
        return p.width_fixed?
      end

      false
    end

    def height_fixed? : Bool
      # It's fixed if it's a specific number OR if it's the RootCanvas
      return true if @height > 0 || self.is_a?(RootCanvas)

      # If I am a fill parent, I am only fixed if my parent is fixed
      if @height == FillParent && (p = @parent)
        return p.height_fixed?
      end

      false
    end

    def apply_anchor!(pw : Int32, ph : Int32)
      # Only apply if we aren't being managed by a BoxLayout (flex > 0)
      return if flex > 0

      off_x, off_y = calculate_anchor_offset(pw, ph)

      # Update local x/y. These will be added to the parent's content_x/y
      # in the global_position call.
      @x = off_x
      @y = off_y
    end

    # Logic to calculate the "Actual" draw position based on parent/anchors
    # cached, recalculated when dirty_position? from other variable changes
    def global_position : {Int32, Int32}
      # If we or our parent have a dirty_position?, we must recalculate
      if dirty_position?
        @global_position_cache = calculate_global_position
        @dirty_position = false
      end

      @global_position_cache
    end

    # def calculate_global_position : {Int32, Int32}
    #   # 1. Start with the local relative offset
    #   base_x = self.x
    #   base_y = self.y

    #   # 2. If there's no parent, we are at the root (window level)
    #   if (p = @parent).nil?
    #     return {base_x, base_y}
    #   end

    #   # 3. Get the parent's global position first (recursion)
    #   px, py = p.global_position

    #   # Note: parent width/height used for anchors should be "inner" size
    #   inner_pw = p.width # - p.padding.horizontal
    #   inner_ph = p.height # - p.padding.vertical

    #   # 4. Calculate the anchor point relative to the parent's dimensions
    #   anchor_offset_x, anchor_offset_y = calculate_anchor_offset(inner_pw, inner_ph)

    #   # 5. Result = Parent Content Start + Anchor + Local x
    #   {px + p.content_x + anchor_offset_x + base_x, py + p.content_y + anchor_offset_y + base_y}
    # end

    def calculate_global_position : {Int32, Int32}
      # 1. Start with the local relative offset (set by layout! or user)
      base_x = self.x
      base_y = self.y

      # 2. Root check
      if (p = @parent).nil?
        return {base_x, base_y}
      end

      # 3. Result = Parent's Global Content Start + Local x/y
      # p.content_x/y already include p.global_x/y and p.margin and p.padding
      {p.content_x + base_x, p.content_y + base_y}
    end

    def global_x : Int32
      global_position[0]
    end

    def global_y : Int32
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
      inner_position[0]
    end

    # The 'Inner' coordinate: Start of the Padding/Background.
    # Logic: Global Position + Margin.
    def inner_y : Int32
      inner_position[1]
    end

    # The 'Visible' dimension: The box that gets a background color.
    # Logic: Internal width + padding on both sides.
    def inner_width : Int32
      width + @padding.horizontal
    end

    # The 'Visible' dimension: The box that gets a background color.
    # Logic: Internal width + padding on both sides.
    def inner_height : Int32
      height + @padding.vertical
    end

    def content_x : Int32
      inner_x + @padding.left
    end

    def content_y : Int32
      inner_y + @padding.top
    end

    def layout!
      # Base implementation does nothing
    end


    def content_width : Int32
      width
    end

    def content_height : Int32
      height
    end

    def footprint_x : Int32
      global_x
    end

    def footprint_y : Int32
      global_y
    end

    # The total horizontal space taken up in the parent
    def footprint_width : Int32
      inner_width + @margin.horizontal
    end

    # The total horizontal space taken up in the parent
    def footprint_height : Int32
      inner_height + @margin.vertical
    end

    private def calculate_anchor_offset(parent_width : Int32, parent_height : Int32) : {Int32, Int32}
      # The "Footprint" is the total space this element occupies in its parent.
      # Using the 'inner' dimensions (Padding+Content) + the Margins.
      footprint_width = self.inner_width + @margin.horizontal
      footprint_height = self.inner_height + @margin.vertical

      x_offset = case @anchor
      when .top_left?, .center_left?, .bottom_left?
        0
      when .top_center?, .center?, .bottom_center?
        # Centers the entire footprint within the parent width
        (parent_width - footprint_width) // 2
      when .top_right?, .center_right?, .bottom_right?
        # Snaps the right edge of the margin to the parent's right edge
        parent_width - footprint_width
      else
        0
      end

      y_offset = case @anchor
      when .top_left?, .top_center?, .top_right?
        0
      when .center_left?, .center?, .center_right?
        (parent_height - footprint_height) // 2
      when .bottom_left?, .bottom_center?, .bottom_right?
        parent_height - footprint_height
      else
        0
      end

      {x_offset, y_offset}
    end
  end
end
