require "./ui_element"

module GSDL
  abstract class Container < UIElement
    property children = [] of UIElement

    def add_child(child : UIElement)
      # 1. Prevent adding the same child twice
      return child if @children.includes?(child)

      # 2. If the child already has a different parent, remove it from there first
      if old_parent = child.parent
        if old_parent.is_a?(Container)
          old_parent.remove_child(child)
        end
      end

      # 3. Set the bidirectional relationship
      child.parent = self

      @children << child

      dirty_position!

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

      dirty_position!
    end

    def draw(draw : Draw)
      draw_background(draw)
      @children.each(&.draw(draw))
    end

    protected def dirty_position!
      return if @dirty_position

      @dirty_position = true

      # Notify children that their global positions are now invalid
      @children.each(&.dirty_position!)
    end

    def width : Int32
      case @width
      when FillParent
        if p = @parent
          # Only fill if the parent has a concrete size to fill.
          # If the parent is also dynamic (-1 or -2), we must return 0
          # or a base size to break the recursion.
          return p.width_fixed? ? (p.width - @margin.horizontal - @padding.horizontal) : 0
        end

        0
      when FitContent
        return 0 if @children.empty?

        @children.max_of { |c| (c.x + c.footprint_width).as(Int32) }
      else
        @width
      end
    end

    def height : Int32
      case @height
      when FillParent
        if p = @parent
          # Only fill if the parent has a concrete size to fill.
          # If the parent is also dynamic (-1 or -2), we must return 0
          # or a base size to break the recursion.
          return p.height_fixed? ? (p.height - @margin.vertical - @padding.vertical) : 0
        end

        0
      when FitContent
        return 0 if @children.empty?

        @children.max_of { |c| (c.y + c.footprint_height).as(Int32) }
      else
        @height
      end
    end
  end
end
