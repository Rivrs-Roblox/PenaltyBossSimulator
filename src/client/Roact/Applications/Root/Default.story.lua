--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Constants
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions

-- Modules
local Roact = require(ReplicatedStorage.Packages.roact)
local Application = require(script.Parent.Application)

local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Code
return function(target)
	local handle = Roact.mount(
		Roact.createElement(RoduxHooks.Provider, {
			store = Store
		}, {
			Roact.createElement(Application.Story)
		}),
		target,
		"Root"
	)
	return function ()
		Roact.unmount(handle)
	end
end