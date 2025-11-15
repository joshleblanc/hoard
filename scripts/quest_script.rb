module Hoard
  module Scripts
    class QuestScript < Hoard::Script
      attr_accessor :id, :parent_id, :name, :description, :image_url, :asset, :item,
                    :default_active, :prerequisite, :required_completions, :index,
                    :score, :track_by_default, :daily, :on_complete, :on_progress

      attr_accessor :parent, :children, :prerequisite_quest

      event :on_complete 
      event :on_progress

      def initialize(id:, parent_id: nil, name:, description:, image_url: nil, asset: nil, item: nil, default_active: true, prerequisite: nil, required_completions: 1, index: 0, score: 0, track_by_default: false, daily: false)
        @id = id
        @parent_id = parent_id
        @name = name
        @description = description
        @image_url = image_url
        @asset = asset
        @item = item
        @default_active = default_active
        @prerequisite = prerequisite
        @required_completions = required_completions
        @index = index
        @score = score
        @track_by_default = track_by_default
        @daily = daily
        @children = []
      end

      def db
        # Assumes the entity this script is on has a user, which has document stores
        user&.document_stores_script&.get_db("quest-system")
      end

      def quests
        user&.user_quests_script
      end

      def progress
        if children.any?
          children.sum(&:progress) / children.size.to_f
        else
          record = db&.find_one({ _id: id }) || {}
          num_completions = record[:num_completions] || 0
          num_completions / required_completions.to_f
        end
      end

      def is_active?
        return false if prerequisite_quest && !prerequisite_quest.is_complete?
        return false if parent && !parent.is_active?

        record = db&.find_one({ _id: id })
        default_active || (record && record[:active])
      end

      def is_complete?
        progress == 1
      end

      def is_root?
        parent_id.nil?
      end

      def has_children?
        children.any?
      end

      def is_end?
        return false if children.empty?
        children.all? { |child| !child.has_children? }
      end

      def has_rewards?
        rewards.any?
      end

      def rewards
        quests&.get_quest_rewards(id) || []
      end

      def activate(recursive: false)
        return if is_active?
        db&.update_one({ _id: id }, { "$set" => { activated_at: Time.now.utc, active: true, is_end: is_end? } }, { upsert: true })
        children.each { |q| q.activate(recursive: true) } if recursive
      end

      def complete
        raise "Cannot call complete on a quest with children" if has_children?
        return if is_complete?
        return unless is_active?

        # TODO: Send XP event
        on_progress&.call(self)
        quests&.on_quest_progress&.emit(self)

        db&.update_one({ _id: id }, { "$inc" => { num_completions: 1 }, "$setOnInsert" => { is_end: is_end? } }, { upsert: true })

        send_complete_events if is_complete?
      end

      def send_complete_events
        db&.update_one({ _id: id }, { "$set" => { completed_at: Time.now.utc, is_end: is_end?, has_rewards: has_rewards?, claimed_rewards: false } }, { upsert: true })

        # TODO: Notifications
        puts "Quest Complete: #{name}"

        quests&.on_quest_complete&.emit(self)
        on_complete&.call(self)

        # TODO: Send XP event

        quests&.add_score(score) if score > 0

        parent&.send_complete_events if parent&.is_complete?
      end

      def completed_at
        return nil unless is_complete?
        db&.find_one({ _id: id })&.[](:completed_at)
      end

      def toggle_tracking
        record = db&.find_one({ _id: id }) || { tracking: false }
        db&.update_one({ _id: id }, { "$set" => { tracking: !record[:tracking] } }, { upsert: true })
      end

      def to_h
        record = db&.find_one({ _id: id }) || {}
        {
          id: id,
          parent_id: parent_id,
          name: name,
          description: description,
          done: is_complete?,
          active: is_active?,
          num_completions: record[:num_completions] || 0,
          index: index,
          has_children: has_children?,
          is_end: is_end?,
          required_completions: required_completions,
          image_url: image_url, # FIXME: needs to handle asset and item types
          score: score,
          completed_at: completed_at,
          tracking: record[:tracking],
          rewards: rewards.map(&:to_h)
        }
      end
    end
  end
end
