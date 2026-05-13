--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- TrailReducer
local TutorialReducer = Rodux.createReducer({
    Step3Visible = false,
}, {
    setStep3Visible = function(state, action)
        local newState = table.clone(state)
        newState.Step3Visible = action.value
        return newState
    end,
})

return TutorialReducer