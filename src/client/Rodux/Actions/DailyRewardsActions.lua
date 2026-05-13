--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local DailyRewardsActions = {
    setLastRedeemedTimestamp = Rodux.makeActionCreator("setLastRedeemedTimestamp", function(value)
        return { value = value }
    end),

    setLastRedeemedId = Rodux.makeActionCreator("setLastRedeemedId", function(value)
        return { value = value }
    end),

    setDailyRewards = Rodux.makeActionCreator("setDailyRewards", function(value)
        return { value = value }
    end)
}

return DailyRewardsActions