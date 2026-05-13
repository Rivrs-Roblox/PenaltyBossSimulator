--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local SettingsActions = {
	setUIVolume = Rodux.makeActionCreator("setUIVolume", function(value)
		return { value = value }
	end),

	setMusicVolume = Rodux.makeActionCreator("setMusicVolume", function(value)
		return { value = value }
	end),

	setMiscVolume = Rodux.makeActionCreator("setMiscVolume", function(value)
		return { value = value }
	end),

	setPetsVisible = Rodux.makeActionCreator("setPetsVisible", function(value)
		return { value = value }
	end),

	setTrade = Rodux.makeActionCreator("setTrade", function(value)
		return { value = value }
	end),
}

return SettingsActions
