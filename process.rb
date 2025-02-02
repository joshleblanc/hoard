module Hoard
  class Process
    attr_gtk

    FPS = 60
    ROOTS = []
    @@uniq_id = 0

    attr :uniq_id, :base_time_mul, :ignore_time_multipliers
    attr :utmod, :ftime, :init_once_done, :ucd, :cd, :delayer,
         :tw, :udelayer, :tmod, :parent, :uftime, :children

    attr_reader :name

    class << self
      def can_run?(p)
        p.can_run?
      end

      def find(what, root = ROOTS)
        root.find do |r|
          p "#{r.class.name} is a #{what.name}"
          if r.is_a?(what)
            return r
          end

          find(what, r.children)
        end
      end

      def send_to_scripts(p, method_name, *args, &blk)
        return unless can_run?(p)

        p.send_to_scripts(method_name, *args, &blk) if p.respond_to?(:send_to_scripts)

        p.children.each do |child|
          send_to_scripts(child, method_name, *args, &blk)
        end
      end

      def pre_update(p, utmod)
        return unless can_run?(p)

        p.args = $args
        p.utmod = utmod
        p.ftime += p.tmod
        p.uftime += p.utmod

        p.delayer.update(p.tmod)

        p.udelayer.update(p.utmod) if can_run?(p)
        p.cd.update(p.tmod) if can_run?(p)
        p.ucd.update(p.utmod) if can_run?(p)
        p.tw.update(p.tmod) if can_run?(p)

        if can_run?(p)
          unless p.init_once_done
            p.init
            p.init_once_done = true
          end

          p.pre_update
        end

        if can_run?(p)
          p.children.each do |c|
            pre_update(c, utmod)
          end
        end
      end

      def main_update(p)
        return unless can_run?(p)

        p.args = $args
        p.update

        if can_run?(p)
          p.children.each do |c|
            main_update(c)
          end
        end
      end

      def post_update(p)
        return unless can_run?(p)

        p.args = $args
        p.post_update

        unless p.destroyed?
          p.children.each do |c|
            post_update(c)
          end
        end
      end

      def broadcast_to_scripts(method_name, *args, &blk)
        ROOTS.each do |root|
          send_to_scripts(root, method_name, *args, &blk)
        end
      end

      def update_all(utmod)
        ROOTS.each do |root|
          send_to_scripts(root, :args=, $args)
        end

        ROOTS.each do |root|
          pre_update(root, utmod)
        end

        ROOTS.each do |root|
          main_update(root)
        end

        ROOTS.each do |root|
          post_update(root)
        end
      end

      def shutdown
        ROOTS.each do |root|
          root.args = $args
          root.shutdown

          root.children.each(&:shutdown)
        end
      end

      def client=(new_val)
        @client = new_val
      end

      def server=(new_val)
        @server = new_val
      end

      def client?
        @client
      end

      def server?
        @server
      end
    end

    def initialize(parent = nil)
      @uniq_id = @@uniq_id
      @@uniq_id += 1

      @children = []
      @manually_paused = false
      @destroyed = false
      @ftime = 0
      @uftime = 0
      @utmod = 1
      @ignore_time_multipliers = false
      @base_time_mul = 1.0
      @name = ""
      @init_once_done = false

      @cd = Cooldown.new(FPS)
      @tw = Tweenie.new(FPS)
      @delayer = Delayer.new(FPS)

      @ucd = Cooldown.new(FPS)
      @udelayer = Delayer.new(FPS)

      if parent
        parent.add_child(self)
      else
        ROOTS << self
      end
    end

    def server?
      Process.server?
    end

    def client?
      Process.client?
    end

    def local?
      client? && user
    end

    def user
      return self if self.is_a?(User)

      if parent.is_a?(User)
        parent
      else
        parent&.user
      end
    end

    def apply_args(args)
      self.args = args
      @children.each do |child|
        child.apply_args(args)
      end
    end

    def can_run?
      !paused? && !destroyed?
    end

    def ignore_time_multipliers?
      @ignore_time_multipliers
    end

    def to_s
      "#{uniq_id} #{display_name}##{paused? ? "[PAUSED]" : ""}"
    end

    def display_name
      return name if name
      self.class.name
    end

    def rnd(min, max, sign = false)
      if sign
        (min + rand * (max - min)) * (rand(2) * 2 - 1)
      else
        min + rand * (max - min)
      end
    end

    def rnd_seconds_f(min, max, sign = false)
      sec_to_frames(rnd(min, min, sign))
    end

    def ms_to_frames(v)
      sec_to_frames(v * 1000)
    end

    def frames_to_ms(v)
      1000 * frames_to_sec(v)
    end

    def any_parent_paused?
      if parent
        parent.paused?
      else
        false
      end
    end

    def toggle_pause!
      if @manually_paused
        resume!
      else
        pause!
      end
    end

    def sec_to_frames(v)
      v * FPS
    end

    def frames_to_sec(v)
      FPS / v
    end

    def ftime
      Kernel.global_tick_count
    end

    def tmod
      utmod * computed_time_multiplier
    end

    def utmod
      1
    end

    def uftmodf
      Kernel.global_tick_count
    end

    def computed_time_multiplier
      if ignore_time_multipliers?
        1
      else
        [0, base_time_mul * parent_computed_time_multiplier].max
      end
    end

    def parent_computed_time_multiplier
      if parent
        parent.computed_time_multiplier
      else
        1
      end
    end

    def stime
      ftime * FPS
    end

    def paused?
      @manually_paused || any_parent_paused?
    end

    def pause!
      @manually_paused = true
    end

    def resume!
      @manually_paused = false
    end

    def destroyed?
      @destroyed
    end

    def destroy!
      @destroyed = true
      if parent
        parent.remove_and_destroy_child(self)
      elsif ROOTS.include?(self)
        ROOTS.delete(self)
      end
    end

    def add_child(p)
      if p.parent == nil
        ROOTS.delete p
      else
        p.parent.children.delete p
      end

      p.parent = self
      @children << p
    end

    def root?
      parent == nil
    end

    def move_child_to_root(p)
      if p.parent != self
        raise "Not a child of this process"
      end

      p.parent = nil
      @children.delete p
      ROOTS << p
    end

    def remove_and_destroy_child(p)
      if p.parent != self
        raise "Not a child of this process"
      end

      p.parent = nil

      @children.delete(p)
      ROOTS << p
      p.destroy!
    end

    def destroy_all_children!
      loop do
        break if @children.empty?
        @children.first.destroy!
      end
    end

    def pre_update; end
    def update; end
    def post_update; end
    def final_update; end
    def init; end
    def shutdown; end
  end
end
