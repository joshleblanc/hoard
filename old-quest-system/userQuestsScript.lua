local UserQuestsScript = {}

-- Script properties are defined here
UserQuestsScript.Properties = {
	-- this is fired from the questScript
	{ name = "onQuestComplete", type = "event" },
	{ name = "onQuestActivate", type = "event" },
	{ name = "onQuestProgress", type = "event" },
}

function UserQuestsScript:LocalInit()
	self.quests = self:GetEntity():FindAllScripts("questScript")
	
	self.db = self:GetEntity().documentStoresScript:GetDb("quest-system")
	self.questRewards = self:GatherRewards()
end

function UserQuestsScript:Init()
	self.quests = self:GetEntity():FindAllScripts("questScript")
	
	self.db = self:GetEntity().documentStoresScript:GetDb("quest-system")
	self.questRewards = self:GatherRewards()
	
	local currDay = math.floor(GetWorld():GetUTCTime() / 86400)
	local metadata = self:GetMetadata():FindOne({})
	
	if not metaData or currDay > metadata.lastDaily then 
		self:GetMetadata():UpdateOne({}, {
			_set = {
				lastDaily = currDay
			}
		}, {
			upsert = true
		})
		
		self:ResetDailies()
	end
end

function UserQuestsScript:ResetDailies()
	for _, quest in ipairs(self.quests) do 
		if quest:IsDaily() then 
			quest:ResetQuest()
		end
	end
end

function UserQuestsScript:GetMetadata()
	if not self.metadata then 
		self.metadata = self:GetEntity().documentStoresScript:GetDb("quest-system-metadata")
	end
	
	return self.metadata
end

function UserQuestsScript:GatherRewards()
	local rewards = {}
	for _, reward in ipairs(self:GetEntity():FindAllScripts("questRewardScript")) do 
		local id = reward.properties.questId
		rewards[id] = rewards[id] or {}
		table.insert(rewards[id], reward)
	end
	return rewards
end

function UserQuestsScript:GetQuestRewards(id)
	return self.questRewards[id] or {}
end

function UserQuestsScript:GetUnclaimedRewards()
	local questDocs = self.db:Find({ 
		hasRewards = true,
		claimedRewards = false
	})
	
	local quests = self:MapRecordsToQuests(questDocs)
	local data = {}
	
	for _, q in ipairs(quests) do 
		table.insert(data, {
			id = q.properties.id, 
			rewards = q:GetRewards()
		})
	end
	
	return data
end

function UserQuestsScript:Score()
	local metadata = self:GetMetadata():FindOne({}) or {}
	return metadata.score or 0
end

function UserQuestsScript:ToggleQuestTracking(id)
	self:FindQuest(id):ToggleTracking()
end

function UserQuestsScript:MapRecordsToQuests(records)
	local quests = {}
	
	for _, record in ipairs(records) do 
		table.insert(quests, self:FindQuest(record._id))
	end
	
	return quests
end

function UserQuestsScript:GetTrackedQuests()
	local data = self.db:Find({ tracking = true })
	
	return self:MapRecordsToQuests(data)
end

function UserQuestsScript:AddScore(amt)
	self:GetMetadata():UpdateOne({
		_inc = {
			score = amt
		}
	}, { upsert = true })
	
	self:GetEntity():AddToLeaderboardValue("quest-system-score", amt)
end

function UserQuestsScript:IsQuestComplete(id)
	return self:FindQuest(id):IsComplete()
end

function UserQuestsScript:IsQuestCompleteForDialog(responseData, id)
	responseData.result = self:IsQuestComplete(id)
end

function UserQuestsScript:RecentlyCompleted()
	local quests = self.db:Find({ isEnd = true }, {
		limit = 3,
		sort = {
			completedAt = 1
		}
	})
	
	local retVal = {}
	for _, questScript in ipairs(self.quests) do 
		for _, quest in pairs(quests) do 
			if quest._id == questScript.properties.id then 
				table.insert(retVal, questScript:ToTable())
			end
		end
	end
	
	return retVal
end

function UserQuestsScript:CompleteQuest(id)
	if not IsServer() then 
		self:SendToServer("CompleteQuest", id) 
		return
	end
	
	local quest = self:FindQuest(id)
	
	if not quest then return end 
	if quest:IsComplete() then return end 
	if not quest:IsActive() then return end
	
	--print("Completing quest")
	quest:Complete()
end

function UserQuestsScript:FindQuest(id)
	for _, quest in ipairs(self.quests) do 
		if quest.properties.id == id then 
			return quest
		end
	end
end

function UserQuestsScript:BuildStructure(quests, structure)
	for _, quest in ipairs(quests) do 
		local s = {}
		structure[quest.properties.id] = s
		self:BuildStructure(quest:ChildQuests(), s)
	end
end

function UserQuestsScript:GetStructure()
	local structure = {}
	for _, quest in ipairs(self.quests) do 
		if quest:IsRoot() then 
			local struct = {}
			structure[quest.properties.id] = struct
			self:BuildStructure(quest:ChildQuests(), struct)
		end
	end
	
	--self:GetEntity().cUtilsScript:PrintTable(structure)
	
	return structure
end

function UserQuestsScript:GetWidgetData()
	local quests = {}
	
	for _, quest in ipairs(self.quests) do 
		table.insert(quests, quest:ToTable())
	end
	
	return quests
end

return UserQuestsScript