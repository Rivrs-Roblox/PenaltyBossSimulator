--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- NotificationController
local NotificationController = Rodux.createReducer({
    Notifications = {},
}, {
    setNotification = function(state, action)
        local newState = table.clone(state)
        newState.Notifications[action.key] = action.value
        return newState
    end,
})

return NotificationController