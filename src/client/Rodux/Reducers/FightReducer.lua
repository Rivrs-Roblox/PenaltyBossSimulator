--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- FightReducer
local FightReducer = Rodux.createReducer({
	Fighting = false,
	AverageClicks = 0,
	BarSize = 0,

	BossName = "",
	BossPower = 0,
	ClientPower = 0,
}, {
	setFighting = function(state, action)
		local newState = table.clone(state)
		newState.Fighting = action.value
		return newState
	end,

	setAverage = function(state, action)
		local newState = table.clone(state)
		newState.AverageClicks = action.value
		return newState
	end,

	setBarSize = function(state, action)
		local newState = table.clone(state)
		newState.BarSize = action.value
		return newState
	end,

	setBossName = function(state, action)
		local newState = table.clone(state)
		newState.BossName = action.value
		return newState
	end,

	setBossPower = function(state, action)
		local newState = table.clone(state)
		newState.BossPower = action.value
		return newState
	end,

	setClientPower = function(state, action)
		local newState = table.clone(state)
		newState.ClientPower = action.value
		return newState
	end,
})

return FightReducer
