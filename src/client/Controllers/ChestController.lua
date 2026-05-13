--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Sound = require(ReplicatedStorage.Packages.Sound)
local Zone = require(ReplicatedStorage.Shared.ZonePlus)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local CreateHitbox = require(Helpers.CreateHitbox)
local ToHMS = require(Helpers.FormatDuration)

-- Controllers
local DataCacheController = nil
local NotificationController = nil

-- Services
local ChestService = nil

-- ChestController
local ChestController = Knit.CreateController({
	Name = "ChestController",

	Template = {},
	FirstRun = true,
	Debounce = false,
})

--|| Functions ||--
function ChestController:Update()
	local Chests = CollectionService:GetTagged("Chest")

	for _, Chest in Chests do
		if self.FirstRun then
			local zonePart = Chest
			local zone = Zone.new(zonePart)
			zone:setDetection("Centre")
			-- MASUK ZONE
			zone.playerEntered:Connect(function(player)
				if self.Debounce == false then
					if (player ~= Players.LocalPlayer) then
						return
					end
					self.Debounce = true

					local p, r = ChestService:Claim(Chest.Parent.Name):await()
					if p == false then
						return warn("[CHEST CONTROLLER] An internal error occured while claiming chest.")
					end

					NotificationController:Notify({
						tag = "Chest",
						text = r.text,
						type = r.type,
					})
					if r.type == "SUCCESS" then
						Sound:PlaySound("UI_Chest_Open")
						--SoundController:CreateSound(Players.LocalPlayer.Character, "Chest_Open")
					end

					task.delay(2, function()
						self.Debounce = false
					end)
				end
			end)
		end

		local LastClaimed = Store:getState()["ChestsReducer"].Chests[Chest.Name]
		if not LastClaimed then
			warn("[CHEST CONTROLLER] Player has no data for chest: " .. Chest.Name)
			continue
		end

		-- local UI = Chest:WaitForChild("ChestGui")
		-- local Count = UI:WaitForChild("Count_Down")
		-- local IntTime = Store:getState()["ChestsReducer"].Chests[Chest.Name] - os.time()
		-- local Sign = math.sign(IntTime)

		-- if Sign ~= -1 then
		-- 	local Time = ToHMS(IntTime)
		-- 	Count:WaitForChild("Amount").Text = Time
		-- else
		-- 	Count:WaitForChild("Amount").Text = "Ready!"
		-- end
	end

	self.FirstRun = false
end

function ChestController:Claim()
	local p, r = ChestService:Claim("Group Chest"):await()
	if p == false then
		return warn("[CHEST CONTROLLER] An internal error occured while claiming chest.")
	end

	NotificationController:Notify({
		tag = "Chest",
		text = r.text,
		type = r.type,
	})
	if r.type == "SUCCESS" then
		Sound:PlaySound("UI_Chest_Open")
		--SoundController:CreateSound(Players.LocalPlayer.Character, "Chest_Open")
	end
end

--|| Knit Lifecycle ||--
function ChestController:KnitInit()
	DataCacheController = Knit.GetController("DataCacheController")
	NotificationController = Knit.GetController("NotificationController")

	ChestService = Knit.GetService("ChestService")

	self.Template = DataCacheController:GetFile("Template")

	task.delay(3, function()
		self:Update()
	end)

	print("[CHEST CONTROLLER] Controller loaded successfully.")
end

return ChestController
