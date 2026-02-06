module Hoard
  module Ui
    class Context
      attr_accessor :theme, :components, :render_target
      attr_reader :focused_component

      # render_target: nil => args.outputs.primitives
      #                :ui => args.outputs[:ui].primitives (hoard default)
      def initialize(theme: nil, render_target: nil)
        @theme = theme || Theme.new
        @render_target = render_target
        @components = []
        @focused_component = nil
        @focus_index = -1
      end

      def add(component)
        @components << component
        component
      end

      def remove(component)
        @components.delete(component)
        blur_component(component) if @focused_component == component
      end

      def find(id)
        @components.find { |c| c.id == id }
      end

      def tick(args)
        handle_focus_navigation(args)
        handle_click_focus(args)

        @components.each do |c|
          next unless c.visible
          c.tick(args)
        end
      end

      def prefab
        prims = []
        @components.each do |c|
          next unless c.visible
          prims.concat(c.prefab)
        end
        prims
      end

      def render(args)
        tick(args)
        prims = prefab
        if @render_target
          args.outputs[@render_target].primitives << prims
        else
          args.outputs.primitives << prims
        end
      end

      def focus(component)
        return if component == @focused_component
        blur_component(@focused_component) if @focused_component
        @focused_component = component
        @focus_index = @components.index(component) || -1
        component.focus! if component
      end

      def blur(component = nil)
        target = component || @focused_component
        return unless target
        blur_component(target)
        @focused_component = nil if target == @focused_component
      end

      private

      def blur_component(component)
        component.blur! if component && component.respond_to?(:blur!)
      end

      def focusable_components
        @components.select { |c| c.visible && c.enabled }
      end

      def handle_focus_navigation(args)
        kb = args.inputs.keyboard
        return unless kb.key_down.tab

        focusable = focusable_components
        return if focusable.empty?

        if kb.shift
          @focus_index -= 1
          @focus_index = focusable.length - 1 if @focus_index < 0
        else
          @focus_index += 1
          @focus_index = 0 if @focus_index >= focusable.length
        end

        focus(focusable[@focus_index])
      end

      def handle_click_focus(args)
        return unless args.inputs.mouse.click

        # Search in reverse so children (added after parents) are found first.
        clicked = @components.reverse.find do |c|
          next false if c.is_a?(Panel)  # Panels are containers, not focusable targets
          c.visible && c.enabled && args.inputs.mouse.inside_rect?(c.rect)
        end

        if clicked
          focus(clicked)
        else
          blur
        end
      end
    end
  end
end
