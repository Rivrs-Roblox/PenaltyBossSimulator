--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

local RewardsActions = {
    setRewards = Rodux.makeActionCreator("setRewards", function(rewards)
		return {
			rewards = rewards
		}
	end),

    updateReward = Rodux.makeActionCreator("updateReward", function(index, reward)
        return {
			index = index,
            reward = reward
        }
    end),

	addTime = Rodux.makeActionCreator("addTime", function(value)
		return { value = value }
	end)
}

return RewardsActions