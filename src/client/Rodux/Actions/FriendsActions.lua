--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local FriendsActions = {
	setFriends = Rodux.makeActionCreator("setFriends", function(value)
		return { value = value }
	end),

	setInvitedFriends = Rodux.makeActionCreator("setInvitedFriends", function(value)
		return { value = value }
	end),

	setStars = Rodux.makeActionCreator("setStars", function(value)
		return { value = value }
	end),

	setOnlineFriends = Rodux.makeActionCreator("setOnlineFriends", function(value)
		return { value = value }
	end),
}

return FriendsActions
