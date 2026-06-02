--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- UIReducer
local UIReducer = Rodux.createReducer({
	CurrentUI = "",
	StoreTargetSection = nil,
	CurrentSeasonPassUI = "Rewards",
	CurrentChristmasUI = "Daily",
}, {
	setCurrentUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentUI = action.value
		return newState
	end,

	setStoreTargetSection = function(state, action)
		local newState = table.clone(state)
		newState.StoreTargetSection = action.value
		return newState
	end,

	resetStoreTargetSection = function(state, action)
		local newState = table.clone(state)
		newState.StoreTargetSection = nil
		return newState
	end,

	resetCurrentUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentUI = nil
		return newState
	end,

	setCurrentSeasonPassUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentSeasonPassUI = action.value
		return newState
	end,

	resetCurrentSeasonPassUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentSeasonPassUI = "Quests"
		return newState
	end,

	setCurrentChristmasUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentChristmasUI = action.value
		return newState
	end,

	resetCurrentChristmasUI = function(state, action)
		local newState = table.clone(state)
		newState.CurrentChristmasUI = "Daily"
		return newState
	end,
})

return UIReducer
