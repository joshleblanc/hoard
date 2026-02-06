class ShowcaseEntity < Hoard::Entity
  widget ShowcaseWidget.new

  def initialize(**opts)
    super(**opts)
    self.visible = false  # No sprite to render -- purely a widget host
  end

  # No level loaded, skip world position and collision logic
  def update_world_pos; end

  def pre_update
    send_to_scripts(:args=, args)
    send_to_widgets(:args=, args)
    send_to_scripts(:pre_update)
    send_to_widgets(:pre_update)
  end
end
