-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)

-- Services
local DataService = nil
local MonetizationService = nil
local FruitsService = nil
local BoostService = nil
local PetsService = nil
local CoachesService = nil
local CodesService = nil

-- Controllers
local DataCacheController

local trainingAreas

-- UpdatePowerPerSecondController
local UpdatePowerPerSecondController = Knit.CreateController({
	Name = "UpdatePowerPerSecondController",
})

--|| Functions ||--

function UpdatePowerPerSecondController:UpdatePowerPerSecond()
	DataService:GetMultiplier("Money2"):andThen(function(multiplier)
		for _, trainingArea in pairs(trainingAreas) do
			local area = trainingArea:GetAttribute("Area")
			local index = trainingArea:GetAttribute("Index")
			local plusText = trainingArea.Parent.Requirement.BillboardGui:FindFirstChild("PlusText")

			local baseValue = self.Template.TrainingAreas[area][index].PowerPerSecond
			local value = math.round(baseValue * multiplier)

			plusText.Text = "+" .. FormatNumber(value) .. "/s"
		end
	end)
end

--|| Knit Lifecycle ||--
function UpdatePowerPerSecondController:KnitInit()
	DataService = Knit.GetService("DataService")
	MonetizationService = Knit.GetService("MonetizationService")
	FruitsService = Knit.GetService("FruitService")
	BoostService = Knit.GetService("BoostService")
	PetsService = Knit.GetService("PetsService")
	CoachesService = Knit.GetService("CoachesService")
	CodesService = Knit.GetService("CodesService")

	DataCacheController = Knit.GetController("DataCacheController")
	self.Template = DataCacheController:GetFile("Template")

	trainingAreas = CollectionService:GetTagged("TrainingArea")
	self:UpdatePowerPerSecond()

	CollectionService:GetInstanceAddedSignal("TrainingArea"):Connect(function(trainingArea)
		table.insert(trainingAreas, trainingArea)
		self:UpdatePowerPerSecond()
	end)

	CollectionService:GetInstanceRemovedSignal("TrainingArea"):Connect(function(trainingArea)
		table.remove(trainingAreas, table.find(trainingAreas, trainingArea))
		self:UpdatePowerPerSecond()
	end)

	DataService.RebirthsUpdated:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	PetsService.PetsUpdated:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	FruitsService.FruitsUpdated:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	BoostService.BoostsUpdated:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	MonetizationService.GamepassesUpdate:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	CoachesService.CoachesUpdated:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	CodesService.PlayerVerified:Connect(function()
		self:UpdatePowerPerSecond()
	end)

	Players.PlayerAdded:Connect(function()
		task.delay(0.2, function()
			self:UpdatePowerPerSecond()
		end)
	end)

	Players.PlayerRemoving:Connect(function()
		task.delay(0.2, function()
			self:UpdatePowerPerSecond()
		end)
	end)

	-- BoostEventService.BoostStarted:Connect(function(boostData)
	-- 	if boostData.type == "Money2" then
	-- 		self:UpdatePowerPerSecond()
	-- 	end
	-- end)

	-- BoostEventService.BoostEnded:Connect(function()
	-- 	self:UpdatePowerPerSecond()
	-- end)

	print("[UPDATE POWER PER SECOND CONTROLLER] Controller loaded successfully!")
end

return UpdatePowerPerSecondController
