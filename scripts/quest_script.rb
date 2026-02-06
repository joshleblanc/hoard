# Hoard::Scripts::QuestScript - Attaches a QuestManager to an entity
#
# Usage on an entity class:
#   class Player < Hoard::Entity
#     script Hoard::Scripts::QuestScript.new
#     widget Hoard::Widgets::QuestTrackerWidget.new
#     widget Hoard::Widgets::QuestLogWidget.new
#   end
#
# From other scripts:
#   entity.quest_script.manager.progress(:slay_slimes, :kill)

module Hoard
  module Scripts
    class QuestScript < Script
      attr_reader :manager

      def initialize
        super
        @manager = Quests::QuestManager.new
      end

      def init
        @manager.on_complete do |quest|
          entity.send_to_widgets(:on_quest_complete, quest)
          entity.send_to_scripts(:on_quest_complete, quest)
        end

        @manager.on_progress do |quest, step|
          entity.send_to_widgets(:on_quest_progress, quest, step)
        end
      end

      # Convenience: define a quest
      def define(**opts)
        @manager.define(**opts)
      end

      # Convenience: progress a step
      def progress(quest_id, step_id, count = 1)
        @manager.progress(quest_id, step_id, count)
      end

      # Convenience: complete a quest
      def complete!(quest_id)
        @manager.complete!(quest_id)
      end
    end
  end
end
