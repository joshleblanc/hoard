module Hoard
    module Scripts
        class DialogueScript < Hoard::Script
            attr_accessor :dialogue_active, :current_node, :dialogue_text

            def initialize
                @dialogue_active = false
                @current_node = nil
                @dialogue_text = []
                @dialogue_index = 0
                @npc_name = nil
                @choices = []
                @callback = nil
            end

            def start_dialogue(npc_name, dialogue_tree, &blk)
                @dialogue_active = true
                @npc_name = npc_name
                @current_dialogue = dialogue_tree
                @dialogue_index = 0
                @callback = blk
                advance_dialogue
            end

            def advance_dialogue(choice = nil)
                return end_dialogue if @current_dialogue.nil?

                if choice
                    @current_dialogue = @current_dialogue[:choices]&.[](choice)
                else
                    @current_dialogue = @current_dialogue[:next]
                end

                if @current_dialogue.nil?
                    end_dialogue
                    return
                end

                if @current_dialogue.is_a?(Symbol)
                    @current_dialogue = DIALOGUES[@current_dialogue]
                end

                if @current_dialogue.is_a?(Hash)
                    @dialogue_text = @current_dialogue[:text].split("\n") rescue [@current_dialogue[:text].to_s]
                    @choices = @current_dialogue[:choices] || []
                    entity.add_message("#{@npc_name}: #{@dialogue_text.first}")
                else
                    end_dialogue
                end
            end

            def select_choice(index)
                return unless @dialogue_active && @choices[index]

                choice = @choices[index]
                entity.add_message("You: #{choice[:response]}")
                advance_dialogue(choice[:next])
            end

            def end_dialogue
                @dialogue_active = false
                @current_dialogue = nil
                @choices = []
                @callback&.call
            end

            def is_active?
                @dialogue_active
            end

            def post_update
            end
        end
    end
end

DIALOGUES = {
    village_elder: {
        text: "Welcome, brave adventurer! Our village has been plagued by monsters.\nWill you help us?",
        choices: [
            { response: "I'll help!", next: :quest_accept, response: "I'm on my way!" },
            { response: "Not now.", next: nil }
        ]
    },
    quest_accept: {
        text: "Thank you! The monsters lair lies to the east.\nClear them out and return for your reward.",
        next: nil
    },
    quest_complete: {
        text: "You've done it! The village is safe.\nHere, take this treasure as your reward.",
        next: nil
    },
    shopkeeper: {
        text: "Welcome to my shop!\nLooking to buy or sell?",
        choices: [
            { response: "Buy", next: :buy_items },
            { response: "Sell", next: :sell_items },
            { response: "Bye", next: nil }
        ]
    },
    buy_items: {
        text: "Take your time browsing.\nPress I to open your inventory.",
        next: nil
    },
    sell_items: {
        text: "What do you have for me?",
        next: nil
    }
}
