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
      # Containers usually draw their own background, then children
      @children.each(&.draw(draw))
    end

    protected def dirty!
      return if @position_dirty

      @position_dirty = true

      # Notify children that their global positions are now invalid
      @children.each(&.dirty!)
    end

    def width : Int32
      return @width - @padding.horizontal if @width != -1
      return 0 if @children.empty?

      # Find the furthest right edge among children
      @children.max_of { |c| c.x + c.width } - @padding.horizontal
    end

    def height : Int32
      return @height - @padding.vertical if @height != -1
      return 0 if @children.empty?

      # Find the furthest bottom edge among children
      @children.max_of { |c| c.y + c.height } - @padding.vertical
    end
  end
end
