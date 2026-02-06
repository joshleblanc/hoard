class ShowcaseEntity < Hoard::Entity
  script Hoard::Scripts::QuestScript.new
  widget ShowcaseWidget.new
  widget Hoard::Widgets::QuestTrackerWidget.new
  widget Hoard::Widgets::QuestLogWidget.new
  widget Hoard::Widgets::NotificationWidget.new
  widget Hoard::Widgets::InventoryWidget.new

  def initialize(**opts)
    super(**opts)
    self.visible = false  # No sprite to render -- purely a widget host
    define_sample_quests
    define_sample_inventory
  end

  # No level loaded, skip world position and collision logic
  def update_world_pos; end

  def pre_update
    send_to_scripts(:args=, args)
    send_to_widgets(:args=, args)
    send_to_scripts(:pre_update)
    send_to_widgets(:pre_update)
  end

  private

  def define_sample_quests
    qm = quest_script.manager

    qm.define_category(:exploration, name: "Exploration")
    qm.define_category(:combat,     name: "Combat")
    qm.define_category(:crafting,   name: "Crafting")

    # --- Exploration quests ---
    qm.define(
      id: :find_treasure, name: "Find Sunken Treasure", category: :exploration,
      description: "Rumour has it there's treasure beneath the Lurten Docks.",
      score: 10, index: 0, tracking: true,
      steps: [
        { id: :dive,       name: "Dive into the water" },
        { id: :find_chest, name: "Find the chest" },
        { id: :surface,    name: "Return to surface" },
      ],
      rewards: [
        { name: "Gold", quantity: 100 },
        { name: "Diving Helmet", quantity: 1 },
      ]
    )

    qm.define(
      id: :map_caves, name: "Map the Caves", category: :exploration,
      description: "Explore all cave entrances in the Northern Range.",
      score: 15, index: 1,
      steps: [
        { id: :cave_a, name: "Find Cave A" },
        { id: :cave_b, name: "Find Cave B" },
        { id: :cave_c, name: "Find Cave C" },
      ]
    )

    qm.define(
      id: :climb_peak, name: "Reach the Summit", category: :exploration,
      description: "Climb to the highest point on the map.", score: 20, index: 2,
      steps: [{ id: :summit, name: "Reach the summit" }],
      rewards: [{ name: "Mountaineer Badge", quantity: 1 }]
    )

    # --- Combat quests ---
    qm.define(
      id: :slay_slimes, name: "Slay 10 Slimes", category: :combat,
      description: "The slime population is out of control. Thin them out.",
      score: 5, index: 0, tracking: true,
      steps: [{ id: :kill, name: "Kill slimes", required: 10 }]
    )

    qm.define(
      id: :defeat_boss, name: "Defeat the Golem", category: :combat,
      description: "A stone golem guards the ancient ruins. Defeat it.",
      score: 25, index: 1, active: false,
      steps: [{ id: :fight, name: "Defeat the Stone Golem" }],
      rewards: [
        { name: "Golem Heart", quantity: 1 },
        { name: "Gold", quantity: 500 },
      ]
    )

    # --- Crafting quests ---
    qm.define(
      id: :craft_sword, name: "Forge a Sword", category: :crafting,
      description: "Gather materials and forge your first sword.",
      score: 10, index: 0,
      steps: [
        { id: :ore,   name: "Mine iron ore", required: 5 },
        { id: :wood,  name: "Gather wood", required: 3 },
        { id: :forge, name: "Use the forge" },
      ],
      rewards: [{ name: "Iron Sword", quantity: 1 }]
    )

    # Pre-progress some quests so the demo isn't empty
    qm.progress(:find_treasure, :dive)
    qm.progress(:slay_slimes, :kill, 3)
    qm.progress(:craft_sword, :ore, 2)
  end

  def define_sample_inventory
    items = [
      { name: "Health Potion",  description: "Restores 50 HP",        quantity: 5   },
      { name: "Iron Sword",     description: "A sturdy blade",        quantity: 1   },
      { name: "Wooden Shield",  description: "Basic protection",      quantity: 1   },
      { name: "Iron Ore",       description: "Raw crafting material", quantity: 12  },
      { name: "Lumber",         description: "Processed wood planks", quantity: 8   },
      { name: "Gold Coin",      description: "Currency",              quantity: 347 },
      { name: "Slime Gel",      description: "Dropped by slimes",     quantity: 3   },
      { name: "Map Fragment",   description: "Part of a treasure map",quantity: 2   },
    ]

    inventory_widget.slots = items
    inventory_widget.size = 20
  end
end
