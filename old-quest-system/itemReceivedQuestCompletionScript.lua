local ItemReceivedQuestCompletionScript = {}

-- Script properties are defined here
ItemReceivedQuestCompletionScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "itemToReceive", type = "template" },
	{ name = "onComplete", type = "event" },
}

--This function is called on the server when this entity is created
function ItemReceivedQuestCompletionScript:Init()
	local user = self:GetEntity()
	if not user:IsA(User) then 
		user = user:GetUser()
	end
	
	self.user = user
	
	user.inventoryScript.properties.onInventoryUpdated:Listen(self, "HandleInventoryUpdated")
end

function ItemReceivedQuestCompletionScript:HandleInventoryUpdated()
	local inventory = self.user.inventoryScript.inventory
	for _, item in ipairs(inventory) do
		if item.template == self.properties.itemToReceive then 
			self.properties.onComplete:Send()
		end
	end
end

return ItemReceivedQuestCompletionScript