local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KnitClient = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

require(ReplicatedStorage.Packages.Sound)
require(ReplicatedStorage.Packages.VFX)

local Preloader = require(ReplicatedStorage.Packages.Preloader)

Preloader:Configure({
	showLoadingScreen = true,
	loadControllers = true,
	loadImages = true, -- If at false imagesPath should be nil.
	loadUI = false, --Leave this at False
	initialDelay = 0.5,
	finalDelay = 0.5,
	skipEnabled = false,
	batchSize = 30,
	keepLoadingScreen = false, --if at true it won't remove the loading screen even when loading is finish
	paths = {
		controllersPath = StarterPlayer.StarterPlayerScripts.Client.Controllers,
		imagesPath = ReplicatedStorage.Shared.Data.Images,
		componentsPath = nil, --Always keep at nil
	},
})

Preloader.ControllersLoadedSignal:Connect(function()
	KnitClient.Start()
		:andThen(function()
			print("Knit Client Successfully Started")
		end)
		:catch(warn)
		:await()

	local Root = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Applications.Root.Application)
	local Sync = require(StarterPlayer.StarterPlayerScripts.Client.Modules.Synchronization)
	Sync()

	Roact.mount(
		Roact.createElement(RoduxHooks.Provider, {
			store = Store,
		}, {
			GameScreenGui = Roact.createElement(Root.Game),
		}),
		Players.LocalPlayer.PlayerGui,
		"UI"
	)
end)

Preloader.EndPreloaderSignal:Connect(function(bool)

	-- Handle teleportation or any other post-loading logic here
	--[[local TeleportationService = KnitClient.GetService("TeleportationService")
	TeleportationService:HandlePlayerSpawn()]]
end)

Preloader:PreloadContent()
