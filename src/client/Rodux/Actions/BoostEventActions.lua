--[=[
 	Owner: CategoryTheory
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

local BoostEventActions = {
	setBoostEventCountdown = Rodux.makeActionCreator("setBoostEventCountdown", function(boostEventCountdown)
		return {
			BoostEventCountdown = boostEventCountdown,
		}
	end),

	setCurrentBoostEvent = Rodux.makeActionCreator("setCurrentBoostEvent", function(currentBoostEvent)
		return {
			CurrentBoostEvent = currentBoostEvent,
		}
	end),
}

return BoostEventActions
