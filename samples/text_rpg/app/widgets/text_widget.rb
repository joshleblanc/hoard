class TextWidget < Hoard::Widget
  attr_accessor :text, :title

  def initialize(title: nil, **opts)
    super()
    @text = ""
    @title = title
    @visible = true
    @instructions = nil
  end

  def render
    return unless @visible

    panel :text_panel, x: 920, y: 220, w: 300, h: 450, title: @title do
      lines = @text.to_s.split("\n")
      lines.each_with_index do |line, i|
        label :"line_#{i}", text: line, color_key: :text_primary, size_key: :size_sm
      end

      if @instructions
        label :sep, text: "---", color_key: :text_disabled, size_key: :size_xs
        @instructions.each_with_index do |inst, i|
          label :"inst_#{i}", text: inst, color_key: :text_disabled, size_key: :size_xs
        end
      end
    end
  end

  def visible?
    @visible
  end

  def visible=(val)
    @visible = val
  end
end
