local QuestRewardScript = {}

-- Script properties are defined here
QuestRewardScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "questId", type = "string" },
	{ name = "template", type = "template" },
	{ name = "quantity", type = "number", default = 1 },
}

--This function is called on the server when this entity is created
function QuestRewardScript:Init()
end

function QuestRewardScript:GetName(template)
	if not template then
		return ""
	end

	return template:FindScriptProperty("friendlyName") or template:GetName()
end

function QuestRewardScript:GetText(template, key)
	if not template then
		return ""
	end
	
	local val = template:FindScriptProperty(key)
	
	return val or ""
end

function QuestRewardScript:GetIcon(template)
	if not template then
		return ""
	end
		
	local iconProperty = template:FindScriptProperty("iconUrl")
	
	if iconProperty and #iconProperty > 0 then 
		return iconProperty
	end
	
	local iconAsset = template:FindScriptProperty("iconAsset")
		
	if iconAsset then
		return iconAsset:GetIcon()
	else 
		return ""
	end
end

function QuestRewardScript:ToTable()
	local template = self.properties.template 
	
	return {
		questId = self.properties.questId,
		templateName = template:GetName(),
		name = self:GetName(template), 
		count = self.properties.quantity,
		description = self:GetText(template, "description"),
		icon = self:GetIcon(template),
	}
end

return QuestRewardScript