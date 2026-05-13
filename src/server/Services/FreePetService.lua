--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataCacheService = nil
local DataService = nil
--local QuestsService = nil
local PetsService = nil

-- FreePetService
local FreePetService = Knit.CreateService({
	Name = "FreePetService",
	Client = {
		ClaimablePetsChanged = Knit.CreateSignal(),
	},

	Template = {},

	Claimable_Pets = {},
	Check_Tasks = {},
})

--|| Client Functions ||--
function FreePetService.Client:Claim(player: Player)
	return self.Server:Claim(player)
end

--|| Functions ||--
function FreePetService:Claim(player)
	local data = DataService:GetData(player)
	if not data then
		return warn("[FREE PET SERVICE] Player has no data: " .. player.Name)
	end

	if self.Claimable_Pets[player] == 0 then
		return { text = self.Template.Messages.Notifications.No_Pet_Claimable, type = "ERROR" }
	end
	local added = PetsService:AddPet(player, self.Template.FreePet.Name)
	if added then
		self:ChangeClaimable(player, -1)

		return { text = self.Template.Messages.Notifications.Pet_Claimed(self.Template.FreePet.Name), type = "SUCCESS" }
	end

	return { text = self.Template.Messages.Notifications.Max_Pet_Stored(data.Inventory.Storage.Stored), type = "ERROR" }
end

function FreePetService:CheckCompleted(player: Player)
	self.Check_Tasks[player] = task.spawn(function()
		local data = DataService:GetData(player)
		while task.wait(0.5) do
			-- local ClicksGood = QuestsService:GetClicks(player).temp >= self.Template.FreePet.Tasks.Clicks
			--local WinsGood = QuestsService:GetWins(player).temp >= self.Template.FreePet.Tasks.Wins
			--local PlayTimeGood = QuestsService:GetPlayTime(player).temp >= self.Template.FreePet.Tasks.Play
			local FollowGood = data.Codes.Verified

			--if ClicksGood and WinsGood and PlayTimeGood and FollowGood then
			--QuestsService:ResetClicks(player)
			--QuestsService:ResetWins(player)
			--QuestsService:ResetPlayTime(player)

			--self:ChangeClaimable(player, 1)
			-- end
		end
	end)
end

function FreePetService:ChangeClaimable(player, value)
	self.Claimable_Pets[player] += value
	self.Client.ClaimablePetsChanged:Fire(player, self.Claimable_Pets[player])
end

--|| Knit Lifecycle ||--
function FreePetService:KnitInit()
	DataCacheService = Knit.GetService("DataCacheService")
	DataService = Knit.GetService("DataService")
	--QuestsService = Knit.GetService("QuestsService")
	PetsService = Knit.GetService("PetsService")

	self.Template = DataCacheService:GetFile("Template")

	Players.PlayerAdded:Connect(function(player)
		self.Claimable_Pets[player] = 0
		self:CheckCompleted(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if self.Check_Tasks[player] then
			task.cancel(self.Check_Tasks[player])
			self.Check_Tasks[player] = nil
		end

		self.Claimable_Pets[player] = nil
	end)

	print("[FREE PET SERVICE] Service loaded successfully.")
end

return FreePetService
