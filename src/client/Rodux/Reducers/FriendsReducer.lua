--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- FriendsReducer
local FriendsReducer = Rodux.createReducer({
	Friends = {},
	InvitedFriends = {},
	Stars = 0,
	OnlineFriends = {},
}, {
	setFriends = function(state, action)
		local newState = table.clone(state)
		newState.Friends = action.value
		return newState
	end,

	setInvitedFriends = function(state, action)
		local newState = table.clone(state)
		newState.InvitedFriends = action.value
		return newState
	end,

	setStars = function(state, action)
		local newState = table.clone(state)
		newState.Stars = action.value
		return newState
	end,

	setOnlineFriends = function(state, action)
		local newState = table.clone(state)
		newState.OnlineFriends = action.value
		return newState
	end,
})

return FriendsReducer
