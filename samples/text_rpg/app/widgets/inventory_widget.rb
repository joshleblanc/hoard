class InventoryWidget < Hoard::Widget
  attr_accessor :items, :gold, :on_use, :on_drop, :selected_index, :visible

  def initialize(**opts)
    super()
    @items = []
    @gold = 0
    @on_use = nil
    @on_drop = nil
    @selected_index = 0
    @visible = false
  end

  def render
    return unless @visible

    panel :inventory, x: 450, y: 150, w: 400, h: 520, title: "INVENTORY" do
      label :gold_display, text: "Gold: #{@gold}", color_key: :warning, size_key: :size_sm

      if @items.empty?
        label :empty, text: "Empty", color_key: :text_disabled, size_key: :size_lg
      else
        @items.each_with_index do |item, i|
          selected = i == @selected_index
          name = item.name
          name += " x#{item.quantity}" if item.quantity && item.quantity > 1

          label :"item_#{i}",
            text: "[#{i + 1}] #{name}",
            color_key: selected ? :accent : :text_secondary,
            size_key: :size_sm
        end
      end

      label :controls,
        text: "[U]se  [D]rop  [ESC]Close  [+/-]Select",
        color_key: :text_disabled,
        size_key: :size_xs
    end
  end

  def handle_input(key)
    return unless @visible

    case key
    when :up
      @selected_index = [@selected_index - 1, 0].max
    when :down
      @selected_index = [@selected_index + 1, [@items.length - 1, 0].max].min
    when :use
      item = @items[@selected_index]
      @on_use&.call(item)
    when :drop
      item = @items[@selected_index]
      @on_drop&.call(item)
    end
  end
end
