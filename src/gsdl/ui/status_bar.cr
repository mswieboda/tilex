require "./container"

module GSDL
  class StatusBar < HBox
    def initialize(
      width : Int32 = FillParent,
      height : Int32 = FitContent,
      spacing : Int32 = 0,
      @anchor = Anchor::BottomCenter,
      @background_color = Color::DarkerGray,
    )
      super(width: width, height: height, spacing: spacing)
    end
  end
end
