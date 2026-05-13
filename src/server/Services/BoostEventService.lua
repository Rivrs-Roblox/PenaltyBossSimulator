local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataCacheService

local EVENTINTERVAL = 60 * 30 -- 30 minutes
local countdown = EVENTINTERVAL

local trainingAreas

local BoostEventService = Knit.CreateService({
	Name = "BoostEventService",
	Client = {
		BoostStarted = Knit.CreateSignal(),
		BoostEnded = Knit.CreateSignal(),
		UpdateCountdown = Knit.CreateSignal(),
	},

	Template = {},
	CurrentBoost = nil,
	BoostCountdown = 0,
})

function BoostEventService:SetTrainingBoostVisual(isActive)
	for _, trainingArea in ipairs(trainingAreas) do
		local trainingModel = trainingArea.Parent

		local boostEffect = trainingModel:FindFirstChild("Boost")

		if boostEffect then
			for _, descendant in ipairs(boostEffect:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = isActive
				elseif descendant:IsA("MeshPart") then
					descendant.Transparency = isActive and 0.5 or 1
				end
			end
		end
	end
end

function BoostEventService:StartBoost(boostData)
	self.CurrentBoost = boostData
	self.Client.BoostStarted:FireAll(boostData)

	if boostData.type == "Money2" then
		self:SetTrainingBoostVisual(true)
	end

	self.BoostCountdown = boostData.duration
	self.Client.UpdateCountdown:FireAll(self.BoostCountdown)

	task.spawn(function()
		while self.BoostCountdown > 0 and self.CurrentBoost == boostData do
			task.wait(1)
			self.BoostCountdown -= 1
			self.Client.UpdateCountdown:FireAll(self.BoostCountdown)
		end

		if self.CurrentBoost == boostData then
			self.CurrentBoost = nil
			self.Client.BoostEnded:FireAll()
			if boostData.type == "Money2" then
				self:SetTrainingBoostVisual(false)
			end
		end
	end)
end

function BoostEventService:KnitStart()
	DataCacheService = Knit.GetService("DataCacheService")

	self.Template = DataCacheService:GetFile("Template")

	-- trainingAreas = CollectionService:GetTagged("TrainingArea")

	-- -- player added resume current boost
	-- Players.PlayerAdded:Connect(function(player)
	-- 	if self.CurrentBoost then
	-- 		self.Client.BoostStarted:Fire(player, self.CurrentBoost)
	-- 		self.Client.UpdateCountdown:Fire(player, self.BoostCountdown)
	-- 	end
	-- end)

	-- task.spawn(function()
	-- 	while true do
	-- 		if not self.CurrentBoost then
	-- 			if countdown <= 0 then
	-- 				local boost = self.Template.BoostEvent[math.random(1, #self.Template.BoostEvent)]
	-- 				-- local boost = self.Template.BoostEvent[1]
	-- 				self:StartBoost(boost)
	-- 				countdown = EVENTINTERVAL
	-- 			else
	-- 				countdown -= 1
	-- 				self.Client.UpdateCountdown:FireAll(countdown)
	-- 			end
	-- 		end
	-- 		task.wait(1)
	-- 	end
	-- end)
end

return BoostEventService
