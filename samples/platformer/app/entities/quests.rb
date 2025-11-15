class Quests < Hoard::Entity
  script Hoard::Scripts::QuestScript.new(
    id: "collect_coins",
    name: "Coin Collector",
    description: "Collect all the coins in the level.",
  )

  script Hoard::Scripts::QuestScript.new(
    id: "coin1",
    parent_id: "collect_coins",
    name: "Collect the first coin",
    description: "Find and collect the first coin.",
  )

  script Hoard::Scripts::QuestScript.new(
    id: "coin2",
    parent_id: "collect_coins",
    name: "Collect the second coin",
    description: "Find and collect the second coin.",
  )

  script Hoard::Scripts::QuestScript.new(
    id: "coin3",
    parent_id: "collect_coins",
    name: "Collect the third coin",
    description: "Find and collect the third coin.",
  )
end
