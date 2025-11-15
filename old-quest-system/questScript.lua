local QuestScript = {}

-- Script properties are defined here
QuestScript.Properties = {
	-- Example property
	{ name = "id", type = "string" },
	{ name = "parentId", type = "string" },
	{ name = "name", type = "text" },
	{ name = "description", type = "text" },
	{ name = "imageType", type = "string", options = { "asset", "url", "item", }, default = "url" },
	{ name = "imageUrl", type = "string", visibleIf=function(p) return p.imageType == "url" end },
	{ name = "asset", type = "asset", visibleIf=function(p) return p.imageType == "asset" end },
	{ name = "item", type = "template", visibleIf=function(p) return p.imageType == "item" end },
	{ name = "defaultActive", type = "boolean", default = true },
	{ name = "prerequisite", type = "string" },
	{ name = "requiredCompletions", type = "number", default = 1 },
	{ name = "index", type = "number" },
	{ name = "score", type = "number", default = 0 },
	{ name = "trackByDefault", type = "boolean", default = false },
	{ name = "daily", type = "boolean", default = false },
	{ name = "onComplete", type = "event" },
	{ name = "onProgress", type = "event" },
}

function QuestScript:Init()	
	if self.properties.trackByDefault then 
		self:GetDb():UpdateOne({ _id = self.properties.id }, {
			_setOnInsert = {
				tracking = self.properties.trackByDefault
			}
		}, {
			upsert = true
		})
	end
end

function QuestScript:IsDaily()
	if not self:Parent() then return false end
	
	return self.properties.daily or self:Parent():IsDaily()
end

function QuestScript:ResetQuest()
	self:GetDb():DeleteOne({ _id = self.properties.id })
end

function QuestScript:GetDb()
	if not self.db then 
		self.db = self:GetEntity().documentStoresScript:GetDb("quest-system")
	end
	
	return self.db
end

function QuestScript:GetQuests()
	return self:GetEntity().userQuestsScript
end

function QuestScript:GetChildren()
	if not self.children then 
		local questScripts = self:GetEntity():FindAllScripts("questScript")
		self.children = {}

		for _, script in ipairs(questScripts) do 
			if script.properties.parentId == self.properties.id then 
				table.insert(self.children, script)
			end
			if script.properties.id == self.properties.parentId then 
				self.parent = script
			end
			
			if script.properties.id == self.properties.prerequisite then 
				self.prerequisite = script
			end
		end
	end
	
	return self.children
end

function QuestScript:Progress()
	if #self:GetChildren() > 0 then 
		local progress = 0
		for _, child in ipairs(self:GetChildren()) do 
			progress = progress + child:Progress()
		end
		return progress / #self:GetChildren()
	else 
		local record = self:GetDb():FindOne({ _id = self.properties.id }) or {}
		local numCompleted = record.numCompletions or 0

		return numCompleted / self.properties.requiredCompletions
	end
end

function QuestScript:ChildQuests()
	return self:GetChildren()
end

function QuestScript:HasChildren()
	return #self:GetChildren() > 0
end

function QuestScript:ActiveId()
	return FormatString("quest-{1}-active", self.properties.id)
end

function QuestScript:ActivateForUser(user)
	if user ~= self:GetEntity() then return end 
	
	self:Activate()
end

function QuestScript:ToggleTracking()
	local data = self:GetDb():FindOne({ _id = self.properties.id }) or { tracking = false }
	
	self:GetDb():UpdateOne({ _id = self.properties.id }, {
		_set = {
			tracking = not data.tracking
		}	
	}, {
		upsert = true
	})
	
	data = self:GetDb():FindOne({ _id = self.properties.id })
end

function QuestScript:Activate(recursive)
	--print("Activating quest", self:ActiveId())
	if self:IsActive() then return end 
	
	self:GetDb():UpdateOne({ 
		_id = self.properties.id, 
	}, {
		_set = {
			activatedAt = GetWorld():GetUTCTime(),
			active = true,
			isEnd = self:IsEnd()
		}
	}, {
		upsert = true
	})
	
	if recursive then 
		for _, q in ipairs(self:ChildQuests()) do
			q:Activate(recursive)
		end
	end
end

function QuestScript:IsActive()
	--if self:HasParent() and self:Parent():IsActive() then 
	--	return true
	--end
	
	if self.prerequisite and not self.prerequisite:IsComplete() then 
		return false
	end
	
	if self.parent and not self.parent:IsActive() then 
		return false
	end
	
	local record = self:GetDb():FindOne({ _id = self.properties.id })
	
	return self.properties.defaultActive or (record and record.active)
end

function QuestScript:Parent()
	return self.parent
end

function QuestScript:HasParent()
	return not self:IsRoot()
end

function QuestScript:IsRoot()
	return #self.properties.parentId == 0
end

function QuestScript:CompleteId()
	return FormatString("quest-{1}-complete", self.properties.id)
end

function QuestScript:Complete()
	assert(#self:GetChildren() <= 0, "Cannot call complete on a quest with children. Called on " .. self.properties.id)
	
	-- if it's already done, no need to complete it
	if self:IsComplete() then return end 
	if not self:IsActive() then return end 
	
	self:GetEntity():SendXPEvent("quest-system-progress", { id = self.properties.id })
	self.properties.onProgress:Send(self)
	self:GetQuests().properties.onQuestProgress:Send(self)
	
	self:GetDb():UpdateOne({ _id = self.properties.id }, {
		_inc = {
			numCompletions = 1,
		},
		_setOnInsert = {
			isEnd = self:IsEnd()
		}
	}, {
		upsert = true
	})

	if self:IsComplete() then 
		self:SendCompleteEvents()
	end
end

function QuestScript:SendCompleteEvents()
	self:GetDb():UpdateOne({ _id = self.properties.id }, {
		_set = {
			completedAt = GetWorld():GetUTCTime(),
			isEnd = self:IsEnd(),
			hasRewards = self:HasRewards(),
			claimedRewards = false
		}
	}, {
		upsert = true
	})
	
	local notif
	if self:GetEntity().cMenuNotificationsScript then 
		notif = self:GetEntity().cMenuNotificationsScript
	elseif self:GetEntity():GetPlayer() and self:GetEntity():GetPlayer().cMenuNotificationsScript then 
		notif = self:GetEntity():GetPlayer().cMenuNotificationsScript
	end
	
	if notif then 
		notif:AddNotification({
			title = "Quest Complete",
			subtitle = self.properties.name,
			accent = "#dbab1e",
			imageUrl = "https://live.content.crayta.com/ui_image/e5bdf7ac-fd04-4e30-9ede-d585dba3701b_ui_image"
		})
		
	else 
		self:GetEntity():SendToScripts("Shout", FormatString("Quest Complete: {1}", self.properties.name))
	end
	
	self:GetQuests().properties.onQuestComplete:Send(self)
	self.properties.onComplete:Send()
	
	if self:IsEnd() then 
		self:GetEntity():SendXPEvent("quest-system-complete-quest", { id = self.properties.id })
	else
		self:GetEntity():SendXPEvent("quest-system-complete-step", { id = self.properties.id })
	end
	
	
	if self.properties.score > 0 then 
		self:GetQuests():AddScore(self.properties.score)
	end
	
	if self:HasParent() and self:Parent():IsComplete() then 
		self:Parent():SendCompleteEvents()
	end
end

function QuestScript:CompletedAt()
	if self:IsComplete() then 
		--print("Trying to access data for", self.properties.id)
		return self:GetDb():FindOne({ _id = self.properties.id }).completedAt
	else 
		return nil
	end
end

function QuestScript:IsComplete()
	return self:Progress() == 1
end

function QuestScript:IsEnd()
	if #self:GetChildren() == 0 then 
		return false 
	end
	
	for _, child in ipairs(self:GetChildren()) do 
		if child:HasChildren() then 
			return false
		end
	end
	
	return true
end

function QuestScript:GetImageUrl()
	if self.properties.imageType == "url" then 
		return self.properties.imageUrl
	elseif self.properties.imageType == "asset" then 
		local asset = self.properties.asset 
		if asset then 
			return asset:GetIcon()
		else
			return ""
		end
	elseif self.properties.imageType == "item" then 
		local item = self.properties.item
		if item then 
		
			local iconUrl = item:FindScriptProperty("iconUrl")
			if iconUrl then 
				return iconUrl
			end
			
			local iconAsset = item:FindScriptProperty("iconAsset")
			if iconAsset then 
				return iconAsset:GetIcon()
			end
			
			return ""
		else 
			return ""
		end
	end
end

function QuestScript:HasRewards()
	return #self:GetRewards() > 0
end

function QuestScript:GetRewards()
	local rewards = {}
	for _, reward in ipairs(self:GetQuests():GetQuestRewards(self.properties.id)) do 
		table.insert(rewards, reward:ToTable())
	end
	return rewards
end

function QuestScript:ToTable() 
	local record = self:GetDb():FindOne({ _id = self.properties.id }) or {}
	
	return {
		id = self.properties.id,
		parentId = self.properties.parentId,
		name = self.properties.name,
		description = self.properties.description,
		done = self:IsComplete(),
		active = self:IsActive(),
		numCompletions = record.numCompletions or 0,
		index = self.properties.index,
		hasChildren = self:HasChildren(),
		isEnd = self:IsEnd(),
		requiredCompletions = self.properties.requiredCompletions,
		imageUrl = self:GetImageUrl(),
		score = self.properties.score,
		completedAt = self:CompletedAt(),
		tracking = record.tracking,
		rewards = self:GetRewards()
	}
end

return QuestScript