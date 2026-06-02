-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Preloader = require(Packages.Preloader)

local TrailsService

-- Controllers
local NotificationController
local UIController
local FightController

local Helpers = ReplicatedStorage.Shared.Helpers
local SetupArea = require(Helpers.SetupArea)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local blockBuyTrail = false

local player = Players.LocalPlayer

-- TemplateController
local TrailsController = Knit.CreateController({
	Name = "TrailsController",

	CurrentSpeed = StarterPlayer.CharacterWalkSpeed,
})

--|| Local Functions ||--

function TrailsController:SyncMoveSpeed(character)
	character = character or player.Character
	if not character then
		return
	end

	if FightController.IsFighting then
		local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end
		return
	end

	local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.WalkSpeed = self.CurrentSpeed
	end
end

function TrailsController:Equip(id: number)
	TrailsService:Equip(id):andThen(function(result)
		if result.type then
			NotificationController:Notify({
				tag = "Trail",
				text = result.text,
				type = result.type,
			})
		end
	end)
end

function TrailsController:Buy(id: number)
	if blockBuyTrail then
		NotificationController:Notify({
			tag = "Trail",
			text = "Please wait while your purchase is being processed",
			type = "ERROR",
		})
		return
	end

	blockBuyTrail = true

	TrailsService:Buy(id):andThen(function(result)
		if result.type then
			NotificationController:Notify({
				tag = "Trail",
				text = result.text,
				type = result.type,
			})
			blockBuyTrail = false
		end
	end)
end

--|| Functions ||--
function TrailsController:KnitInit()
	TrailsService = Knit.GetService("TrailsService")

	Preloader.EndPreloaderSignal:Connect(function()
		if player.Character then
			TrailsService:GetCurrentSpeed():andThen(function(speed)
				if speed then
					self.CurrentSpeed = speed
					self:SyncMoveSpeed(player.Character)
				end
			end)
		end
	end)
end

function TrailsController:KnitStart()
	local DataCacheController = Knit.GetController("DataCacheController")
	self.Template = DataCacheController:GetFile("Template")

	FightController = Knit.GetController("FightController")
	NotificationController = Knit.GetController("NotificationController")

	UIController = Knit.GetController("UIController")

	TrailsService.MoveSpeedUpdated:Connect(function(moveSpeed)
		self.CurrentSpeed = moveSpeed
		self:SyncMoveSpeed()
	end)

	player.CharacterAdded:Connect(function(character)
		self:SyncMoveSpeed(character)
	end)

	SetupArea("TrailsArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.Trails })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})

	-- Optionnel : Écouter les changements d'état des VFX
end

return TrailsController
