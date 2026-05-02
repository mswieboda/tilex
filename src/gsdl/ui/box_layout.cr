require "./container"

module GSDL
  abstract class BoxLayout < Container
    property spacing : Int32 = 0

    def initialize
      @spacing = 0
      @width = FitContent
      @height = FitContent
    end

    def initialize(@spacing = 0, @width = FitContent, @height = FitContent)
    end

    def draw(draw : Draw)
      layout! if dirty?

      super(draw)
    end

    abstract def layout!
  end
end
