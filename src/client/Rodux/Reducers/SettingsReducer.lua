--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- SettingsReducer
local SettingsReducer = Rodux.createReducer({
	UI_Volume = 100,
	Music_Volume = 100,
	MISC_Volume = 100,
	Pets_Visible = true,
	Trade = true,
}, {
	setUIVolume = function(state, action)
		local newState = table.clone(state)
		newState.UI_Volume = action.value
		return newState
	end,

	setMusicVolume = function(state, action)
		local newState = table.clone(state)
		newState.Music_Volume = action.value
		return newState
	end,

	setMiscVolume = function(state, action)
		local newState = table.clone(state)
		newState.MISC_Volume = action.value
		return newState
	end,

	setPetsVisible = function(state, action)
		local newState = table.clone(state)
		newState.Pets_Visible = action.value
		return newState
	end,

	setTrade = function(state, action)
		local newState = table.clone(state)
		newState.Trade = action.value
		return newState
	end,
})

return SettingsReducer
