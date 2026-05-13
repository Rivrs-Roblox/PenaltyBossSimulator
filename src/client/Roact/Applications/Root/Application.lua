--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Constants
local Applications = StarterPlayer.StarterPlayerScripts.Client.Roact.Applications
local Contexts = StarterPlayer.StarterPlayerScripts.Client.Roact.Contexts

-- Modules
local Roact = require(ReplicatedStorage.Packages.roact)
local AllowedApplicationsContext = require(Contexts.AllowedApplicationsContext)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local ContextStack = require(Contexts.ContextStack)

local function Root(props, hooks)
	return Roact.createElement(ContextStack, {
		providers = {
			AllowedApplicationsContext.Provider,
		},
	}, Roact.createFragment(props[Roact.Children]))
end
Root = RoactHooks.new(Roact)(Root)

local Frames = {
	Hud = Roact.createElement(require(Applications.HUD.Application)),
	Store = Roact.createElement(require(Applications.Store.Application)),
	Travel = Roact.createElement(require(Applications.Travel.Application)),
	Rebirth = Roact.createElement(require(Applications.Rebirth.Application)),
	Trails = Roact.createElement(require(Applications.Trails.Application)),
	Friends = Roact.createElement(require(Applications.Friends.Application)),
	Coaches = Roact.createElement(require(Applications.Coaches.Application)),
	Inventory = Roact.createElement(require(Applications.Inventory.Application)),
	ExitGift = Roact.createElement(require(Applications.ExitGift.Application)),
	--AllRewards = Roact.createElement(require(Applications.AllRewards.Application)),
	Settings = Roact.createElement(require(Applications.Settings.Application)),
	Rewards = Roact.createElement(require(Applications.Rewards.Application)),
	DailyRewards = Roact.createElement(require(Applications.DailyRewards.Application)),
	Spins = Roact.createElement(require(Applications.Spins.Application)),
	Trade = Roact.createFragment({
	TradeList = Roact.createElement(require(Applications.Trade.List.Application)),
	TradeRequest = Roact.createElement(require(Applications.Trade.Request.Application)),
	TradePanel = Roact.createElement(require(Applications.Trade.Trading.Application)),
}),
	-- Season = Roact.createElement(require(Applications.Season.Application)),
	GoldPets = Roact.createElement(require(Applications.GoldPets.Application)),
	RainbowPets = Roact.createElement(require(Applications.RainbowPets.Application)),
	Update = Roact.createElement(require(Applications.Update.Application)),
	StarterPack = Roact.createElement(require(Applications.StarterPack.Application)),
	-- ExclusivePack = Roact.createElement(require(Applications.ExclusivePack.Application)),
	UpdateLog = Roact.createElement(require(Applications.UpdateLog.Application)),
	Fight = Roact.createElement(require(Applications.Fight.Application)),
	StopAutoWin = Roact.createElement(require(Applications.StopAutoWin.Application)),
	OfflineFarm = Roact.createElement(require(Applications.OfflineFarm.Application)),
	OfflineNotification = Roact.createElement(require(Applications.OfflineNotification.Application)),
	Characters = Roact.createElement(require(Applications.Characters.Application)),
	Rejoin = Roact.createElement(require(Applications.Rejoin.Application)),
}

-- Component
local function StoryFrame()
	return Roact.createElement(Root, {}, Frames)
end

local function GameFrame()
	return Roact.createElement(Root, {}, {
		GameScreenGui = Roact.createElement("ScreenGui", {
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			ResetOnSpawn = false,
			--VirtualCursorMode = Enum.VirtualCursorMode.Enabled
		}, Frames),
	})
end

return {
	Story = StoryFrame,
	Game = GameFrame,
}
