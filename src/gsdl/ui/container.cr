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

      dirty!

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

      dirty!
    end

    def draw(draw : Draw)
      draw_background(draw)
      @children.each(&.draw(draw))
    end

    protected def dirty!
      return if @dirty

      @dirty = true

      # Notify children that their global positions are now invalid
      @children.each(&.dirty!)
    end

    def width : Int32
      w = @width

      if w == FillParent
        # fill parent
        if p = @parent
          # Fill is the parent's AVAILABLE content space minus MY margins
          # p.width is already the "Content" area of the parent.
          return p.width - @margin.horizontal - @padding.horizontal
        else
          # continue with fit content as backup
          w = FitContent
        end
      end

      if w == FitContent
        return 0 if @children.empty?
        return @children.max_of { |c| c.x + c.footprint_width }
      end

      @width
    end

    def height : Int32
      h = @height

      if h <= FillParent
        # fill parent
        if p = @parent
          return p.height - @margin.vertical - @padding.vertical
        else
          # continue with fit content as backup
          h = FitContent
        end
      end

      if h == FitContent
        return 0 if @children.empty?
        return @children.max_of { |c| c.y + c.footprint_height }
      end

      @height
    end
  end
end
