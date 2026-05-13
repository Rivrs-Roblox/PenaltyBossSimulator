--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local QuestsActions = {
    -- Free Pet
    addClicks = Rodux.makeActionCreator("addClicks", function(value)
        return { value = value }
    end),

    setClicks = Rodux.makeActionCreator("setClicks", function(value)
        return { value = value }
    end),

    addBattlesWon = Rodux.makeActionCreator("addBattlesWon", function(value)
        return { value = value }
    end),

    setBattlesWon = Rodux.makeActionCreator("setBattlesWon", function(value)
        return { value = value }
    end),

    addPlayTime = Rodux.makeActionCreator("addPlayTime", function(value)
        return { value = value }
    end),

    setPlayTime = Rodux.makeActionCreator("setPlayTime", function(value)
        return { value = value }
    end),

    addClaimablePets = Rodux.makeActionCreator("addClaimablePets", function(value)
        return { value = value }
    end),

    setClaimablePets = Rodux.makeActionCreator("setClaimablePets", function(value)
        return { value = value }
    end),
}

return QuestsActions