--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local SeasonActions = {
    setSeason = Rodux.makeActionCreator("setSeason", function(value)
        return { value = value }
    end),

    setLevel = Rodux.makeActionCreator("setLevel", function(value)
        return { value = value }
    end),

    setExp = Rodux.makeActionCreator("setExp", function(value)
        return { value = value }
    end),

    setFreeRewards = Rodux.makeActionCreator("setFreeRewards", function(value)
        return { value = value }
    end),

    setPremiumRewards = Rodux.makeActionCreator("setPremiumRewards", function(value)
        return { value = value }
    end),

    setClaimedRewards = Rodux.makeActionCreator("setClaimedRewards", function(value)
        return { value = value }
    end),

    setClaimedPremiumRewards = Rodux.makeActionCreator("setClaimedPremiumRewards", function(value)
        return { value = value }
    end),

    setSeasonQuests = Rodux.makeActionCreator("setSeasonQuests", function(value1, value2)
        return { value1 = value1, value2 = value2 }
    end),

    setRemainingDayTime = Rodux.makeActionCreator("setRemainingDayTime", function(value)
        return { value = value }
    end),

    setRemainingWeekTime = Rodux.makeActionCreator("setRemainingWeekTime", function(value)
        return { value = value }
    end),

    setPremium = Rodux.makeActionCreator("setPremium", function(value)
        return { value = value }
    end),
}

return SeasonActions