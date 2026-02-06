class StatsWidget < Hoard::Widget
  attr_accessor :stats

  def initialize(**opts)
    super()
    @stats = {}
    @visible = true
  end

  def render
    return unless @visible

    panel :stats_panel, x: 420, y: 520, w: 220, h: 200, title: "STATS" do
      label :hp,  text: "HP: #{@stats[:hp] || 0}/#{@stats[:max_hp] || 0}",     color_key: :error
      label :atk, text: "ATK: #{@stats[:attack] || 0}",                         color_key: :text_primary
      label :def, text: "DEF: #{@stats[:defense] || 0}",                         color_key: :text_primary
      label :lvl, text: "LVL: #{@stats[:level] || 1}",                           color_key: :warning
      label :xp,  text: "XP: #{@stats[:xp] || 0}/#{@stats[:xp_to_next] || 100}", color_key: :accent

      if @stats[:hp] && @stats[:max_hp]
        progress_bar :hp_bar,
          value: @stats[:hp],
          max: @stats[:max_hp],
          color_key: :error,
          show_percentage: false
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
