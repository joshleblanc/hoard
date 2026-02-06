class ShowcaseEntity < Hoard::Entity
  script Hoard::Scripts::QuestScript.new
  widget ShowcaseWidget.new
  widget Hoard::Widgets::QuestTrackerWidget.new
  widget Hoard::Widgets::QuestLogWidget.new
  widget Hoard::Widgets::NotificationWidget.new
  widget Hoard::Widgets::InventoryWidget.new
  widget Hoard::Widgets::ShopWidget.new
  widget Hoard::Widgets::ConfirmationWidget.new

  def initialize(**opts)
    super(**opts)
    self.visible = false  # No sprite to render -- purely a widget host
    define_sample_quests
    define_sample_inventory
    define_sample_shop
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

    # =====================================================================
    # Root: Exploration
    # =====================================================================
    qm.define(id: :exploration, name: "Exploration", index: 0)

    # -- Exploration > Sunken Treasure (leaf) --
    qm.define(
      id: :find_treasure, name: "Find Sunken Treasure", parent: :exploration,
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

    # -- Exploration > Hidden Items (branch) --
    qm.define(id: :hidden_items, name: "Hidden Items", parent: :exploration, index: 1)

    # -- Exploration > Hidden Items > Feathers (branch) --
    qm.define(id: :feathers, name: "Feathers", parent: :hidden_items, index: 0)

    qm.define(id: :feather_1, name: "Feather 1", parent: :feathers, score: 2, index: 0,
              description: "A white feather near the fountain.",
              steps: [{ id: :find, name: "Find the feather" }])
    qm.define(id: :feather_2, name: "Feather 2", parent: :feathers, score: 2, index: 1,
              description: "A blue feather on the rooftops.",
              steps: [{ id: :find, name: "Find the feather" }])
    qm.define(id: :feather_3, name: "Feather 3", parent: :feathers, score: 2, index: 2,
              description: "A golden feather in the cave.",
              steps: [{ id: :find, name: "Find the feather" }])

    # -- Exploration > Hidden Items > Ancient Coins (branch) --
    qm.define(id: :coins, name: "Ancient Coins", parent: :hidden_items, index: 1)

    qm.define(id: :coin_1, name: "Coin in the Well",   parent: :coins, score: 3, index: 0,
              steps: [{ id: :find, name: "Retrieve the coin" }])
    qm.define(id: :coin_2, name: "Coin in the Ruins",  parent: :coins, score: 3, index: 1,
              steps: [{ id: :find, name: "Retrieve the coin" }])

    # -- Exploration > Map the Caves (leaf) --
    qm.define(
      id: :map_caves, name: "Map the Caves", parent: :exploration,
      description: "Explore all cave entrances in the Northern Range.",
      score: 15, index: 2,
      steps: [
        { id: :cave_a, name: "Find Cave A" },
        { id: :cave_b, name: "Find Cave B" },
        { id: :cave_c, name: "Find Cave C" },
      ]
    )

    # -- Exploration > Reach the Summit (leaf) --
    qm.define(
      id: :climb_peak, name: "Reach the Summit", parent: :exploration,
      description: "Climb to the highest point on the map.", score: 20, index: 3,
      steps: [{ id: :summit, name: "Reach the summit" }],
      rewards: [{ name: "Mountaineer Badge", quantity: 1 }]
    )

    # =====================================================================
    # Root: Combat
    # =====================================================================
    qm.define(id: :combat, name: "Combat", index: 1)

    qm.define(
      id: :slay_slimes, name: "Slay 10 Slimes", parent: :combat,
      description: "The slime population is out of control. Thin them out.",
      score: 5, index: 0, tracking: true,
      steps: [{ id: :kill, name: "Kill slimes", required: 10 }]
    )

    qm.define(
      id: :defeat_boss, name: "Defeat the Golem", parent: :combat,
      description: "A stone golem guards the ancient ruins. Defeat it.",
      score: 25, index: 1, active: false,
      steps: [{ id: :fight, name: "Defeat the Stone Golem" }],
      rewards: [
        { name: "Golem Heart", quantity: 1 },
        { name: "Gold", quantity: 500 },
      ]
    )

    # =====================================================================
    # Root: Crafting
    # =====================================================================
    qm.define(id: :crafting, name: "Crafting", index: 2)

    qm.define(
      id: :craft_sword, name: "Forge a Sword", parent: :crafting,
      description: "Gather materials and forge your first sword.",
      score: 10, index: 0,
      steps: [
        { id: :ore,   name: "Mine iron ore", required: 5 },
        { id: :wood,  name: "Gather wood", required: 3 },
        { id: :forge, name: "Use the forge" },
      ],
      rewards: [{ name: "Iron Sword", quantity: 1 }]
    )

    qm.define(
      id: :craft_armor, name: "Forge Armor", parent: :crafting,
      description: "Craft a set of iron armor.",
      score: 15, index: 1,
      steps: [
        { id: :ore,    name: "Mine iron ore", required: 10 },
        { id: :leather, name: "Gather leather", required: 5 },
        { id: :forge,  name: "Use the forge" },
      ],
      rewards: [{ name: "Iron Armor", quantity: 1 }]
    )

    # Pre-progress some quests
    qm.progress(:find_treasure, :dive)
    qm.progress(:slay_slimes, :kill, 3)
    qm.progress(:craft_sword, :ore, 2)
    qm.progress(:feather_1, :find)  # complete one feather
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

  def define_sample_shop
    catalog = [
      { name: "Health Potion",   description: "Restores 50 HP",          buy_price: 25  },
      { name: "Mana Potion",     description: "Restores 30 MP",          buy_price: 30  },
      { name: "Iron Sword",      description: "A sturdy blade",          buy_price: 150 },
      { name: "Steel Shield",    description: "Strong protection",       buy_price: 200 },
      { name: "Leather Armor",   description: "Light but flexible",      buy_price: 120 },
      { name: "Fire Scroll",     description: "Casts Fireball",          buy_price: 75  },
      { name: "Antidote",        description: "Cures poison",            buy_price: 15  },
      { name: "Tent",            description: "Rest anywhere",           buy_price: 50  },
      { name: "Lockpick",        description: "Opens locked chests",     buy_price: 40  },
      { name: "Diamond Ring",    description: "Very shiny and expensive",buy_price: 999 },
    ]

    sell_inventory = [
      { name: "Health Potion",  description: "Restores 50 HP",        sell_price: 10, quantity: 5  },
      { name: "Iron Ore",       description: "Raw crafting material", sell_price: 5,  quantity: 12 },
      { name: "Lumber",         description: "Processed wood planks", sell_price: 3,  quantity: 8  },
      { name: "Slime Gel",      description: "Dropped by slimes",     sell_price: 8,  quantity: 3  },
      { name: "Map Fragment",   description: "Part of a treasure map",sell_price: 0,  quantity: 2  },
    ]

    shop_widget.catalog   = catalog
    shop_widget.inventory = sell_inventory
    shop_widget.gold      = 500
    shop_widget.shop_name = "General Store"
  end
end
