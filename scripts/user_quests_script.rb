module Hoard
  module Scripts
    class UserQuestsScript < Hoard::Script
      attr_accessor :on_quest_complete, :on_quest_activate, :on_quest_progress
      attr_reader :quests, :quest_rewards

      event :on_quest_complete
      event :on_quest_activate
      event :on_quest_progress
      
      def initialize()
        @quests = []
        @quest_rewards = {}
      end

      def local_init
        gather_quests
        gather_rewards
        build_quest_tree
        reset_dailies_if_needed
      end

      def db
        user&.document_stores_script&.get_db("quest_system")
      end

      def metadata_db
        user&.document_stores_script&.get_db("quest_system_metadata")
      end

      def gather_quests
        # This assumes quests are attached to entities that are children of the User's entity,
        # or some other central entity. For now, we'll search all entities.
        @quests = []
        ObjectSpace.each_object(Hoard::Entity) do |entity|
          entity.find_scripts(Hoard::Scripts::QuestScript).each do |quest_script|
            @quests << quest_script
          end
        end
      end

      def gather_rewards
        @quest_rewards = {}
        ObjectSpace.each_object(Hoard::Entity) do |entity|
          entity.find_scripts(Hoard::Scripts::QuestRewardScript).each do |reward_script|
            @quest_rewards[reward_script.quest_id] ||= []
            @quest_rewards[reward_script.quest_id] << reward_script
          end
        end
      end

      def build_quest_tree
        quests_by_id = @quests.to_h { |q| [q.id, q] }
        @quests.each do |quest|
          if quest.parent_id
            parent_quest = quests_by_id[quest.parent_id]
            if parent_quest
              parent_quest.children << quest
              quest.parent = parent_quest
            end
          end
          if quest.prerequisite
            quest.prerequisite_quest = quests_by_id[quest.prerequisite]
          end
        end
      end

      def reset_dailies_if_needed
        curr_day = (Time.now.utc.to_i / 86400)
        metadata = metadata_db&.find_one({}) || {}
        last_daily = metadata[:last_daily]

        if !last_daily || curr_day > last_daily
          metadata_db&.update_one({}, { "$set" => { last_daily: curr_day } }, { upsert: true })
          reset_dailies
        end
      end

      def reset_dailies
        @quests.each do |quest|
          quest.db&.delete_one({ _id: quest.id }) if quest.daily
        end
      end

      def get_quest_rewards(id)
        @quest_rewards[id] || []
      end

      def get_unclaimed_rewards
        quest_docs = db&.find({ has_rewards: true, claimed_rewards: false }) || []
        quests = map_records_to_quests(quest_docs)
        quests.map do |q|
          {
            id: q.id,
            rewards: q.rewards.map(&:to_h)
          }
        end
      end

      def score
        metadata = metadata_db&.find_one({}) || {}
        metadata[:score] || 0
      end

      def add_score(amount)
        metadata_db&.update_one({}, { "$inc" => { score: amount } }, { upsert: true })
        # TODO: Add to leaderboard
      end

      def toggle_quest_tracking(id)
        find_quest(id)&.toggle_tracking
      end

      def map_records_to_quests(records)
        records.map { |record| find_quest(record[:_id]) }.compact
      end

      def get_tracked_quests
        data = db&.find({ tracking: true }) || []
        map_records_to_quests(data)
      end

      def is_quest_complete?(id)
        find_quest(id)&.is_complete?
      end

      def recently_completed
        quests = db&.find({ is_end: true }, { sort: { completed_at: -1 }, limit: 3 }) || []
        map_records_to_quests(quests).map(&:to_h)
      end

      def complete_quest(id)
        # In Hoard, scripts run on the server, so no need for SendToServer
        quest = find_quest(id)
        return unless quest
        return if quest.is_complete?
        return unless quest.is_active?
        quest.complete
      end

      def find_quest(id)
        @quests.find { |q| q.id == id }
      end

      def get_widget_data
        @quests.map(&:to_h)
      end
    end
  end
end
