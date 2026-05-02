require "./container"

module GSDL
  abstract class BoxLayout < Container
    property spacing : Int32 = 0

    def initialize
      @spacing = 0
      @width = FillContent
      @height = FillContent
    end

    def initialize(@width = FillContent, @height = FitContent, @spacing = 0)
    end

    def draw(draw : Draw)
      layout! if dirty?

      super(draw)
    end

    abstract def layout!
  end
end
