--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local BoostService = nil

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- BoostController
local BoostController = Knit.CreateController({
    Name = "BoostController"
})

--|| Functions ||--

-- Continuously checks for player's active boosts and remove if ended
function BoostController:Check()
    task.spawn(function()

        while task.wait(1) do
            local ActiveBoosts = Store:getState()["BoostsReducer"].ActiveBoosts
            for id, boost in pairs(ActiveBoosts) do

                if boost.End < os.time() then
                    BoostService:End(id)
                end

            end
        end

    end)
end

--|| Knit Lifecycle ||--
function BoostController:KnitInit()
    BoostService = Knit.GetService("BoostService")

    self:Check()

    print("[BOOST CONTROLLER] Controller loaded sucessfully.")
end

return BoostController