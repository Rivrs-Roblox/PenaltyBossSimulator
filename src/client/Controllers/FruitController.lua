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
local FruitService = nil

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- FruitController
local FruitController = Knit.CreateController({
    Name = "FruitController"
})

--|| Functions ||--

-- Continuously checks for player's active fruits and remove if ended
function FruitController:Check()
    task.spawn(function()

        while task.wait(1) do
            local ActiveFruits = Store:getState()["FruitsReducer"].ActiveFruits
            for id, fruit in pairs(ActiveFruits) do

                if fruit.End < os.time() then
                    FruitService:End(id)
                end

            end
        end

    end)
end

--|| Knit Lifecycle ||--
function FruitController:KnitInit()
    FruitService = Knit.GetService("FruitService")

    self:Check()

    print("[FRUIT CONTROLLER] Controller loaded sucessfully.")
end

return FruitController