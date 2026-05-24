module GSDL
  class UIText < UIElement
    getter text_entity : GSDL::Text

    def initialize(
      font : Symbol = :default,
      text : String = "",
      font_size : Num = 16_f32,
      @x : Int32 = 0,
      @y : Int32 = 0,
      color = ColorScheme.get(:ui_text),
      align : HorizontalAlign = HorizontalAlign::Left,
      @anchor : Anchor = Anchor::TopLeft,
      wrap_width : Int32? = nil,
      @z_index : Int32 = 0,
      opacity : UInt8 = 255_u8,
      weight : FontWeight = FontWeight::Normal,
      style : FontStyle = FontStyle::Regular,
    )
      @text_entity = GSDL::Text.new(
        font: font,
        font_size: font_size,
        text: text,
        h_align: align,
        color: color,
        width: wrap_width,
        z_index: z_index,
        weight: weight,
        style: style,
        draw_relative_to_camera: false
      )
      @text_entity.opacity = opacity

      @width = wrap_width || FitContent
      @height = FitContent
    end

    def text : String
      @text_entity.text
    end

    def font : Symbol
      @text_entity.font
    end

    def font_size : Num
      @text_entity.font_size
    end

    def color : Color
      @text_entity.color
    end

    def color=(color : Color)
      @text_entity.color = color
    end

    def z_index : Int32
      @text_entity.z_index
    end

    def z_index=(z : Int32)
      @text_entity.z_index = z
    end

    def opacity : UInt8
      @text_entity.opacity
    end

    def opacity=(op : UInt8)
      @text_entity.opacity = op
    end

    def weight : FontWeight
      @text_entity.weight
    end

    def weight=(w : FontWeight)
      @text_entity.weight = w
    end

    def style : FontStyle
      @text_entity.style
    end

    def style=(s : FontStyle)
      @text_entity.style = s
    end

    def text=(text : String)
      return if @text_entity.text == text
      @text_entity.text = text
      notify_size_changed
    end

    def font=(font : Symbol)
      return if @text_entity.font == font
      @text_entity.font = font
      notify_size_changed
    end

    def font_size=(size : Num)
      return if font_size == size
      recreate_text_entity(font_size: size)
      notify_size_changed
    end

    def align : HorizontalAlign
      @text_entity.h_align
    end

    def align=(align : HorizontalAlign)
      return if @text_entity.h_align == align
      @text_entity.h_align = align
      notify_size_changed
    end

    def wrap_width : Int32?
      w = @width
      w > 0 ? w : nil
    end

    def wrap_width=(val : Int32?)
      @width = val || FitContent
      @text_entity.width = val
      notify_size_changed
    end

    def width : Int32
      w = @width
      if w == FitContent
        @text_entity.width.to_i
      elsif w == FillParent
        if p = @parent
          p.width_fixed? ? (p.width - @margin.horizontal - @padding.horizontal) : 0
        else
          0
        end
      else
        w
      end
    end

    def height : Int32
      h = @height
      if h == FitContent
        @text_entity.height.to_i
      elsif h == FillParent
        if p = @parent
          p.height_fixed? ? (p.height - @margin.vertical - @padding.vertical) : 0
        else
          0
        end
      else
        h
      end
    end

    def draw(draw : Draw)
      return unless visible?

      # Draw background first if background_color is set
      draw_background(draw)

      # Position the text entity exactly where we are drawing
      # content_x and content_y already account for parent and padding/margins
      @text_entity.x = content_x
      @text_entity.y = content_y
      @text_entity.z_index = z_index

      # Render the text entity
      @text_entity.draw(draw)
    end

    private def notify_size_changed
      dirty_position!
      if p = @parent
        p.dirty_layout! if p.is_a?(Container)
      end
    end

    private def recreate_text_entity(
      font : Symbol = @text_entity.font,
      font_size : Num = @text_entity.font_size,
      text : String = @text_entity.text,
      align : HorizontalAlign = @text_entity.h_align,
      color : Color = @text_entity.color,
      wrap_width : Int32? = self.wrap_width,
      z_index : Int32 = @text_entity.z_index,
      opacity : UInt8 = @text_entity.opacity,
      weight : FontWeight = @text_entity.weight,
      style : FontStyle = @text_entity.style
    )
      @text_entity = GSDL::Text.new(
        font: font,
        font_size: font_size,
        text: text,
        h_align: align,
        color: color,
        width: wrap_width,
        z_index: z_index,
        weight: weight,
        style: style,
        draw_relative_to_camera: false
      )
      @text_entity.opacity = opacity
    end
  end
end
