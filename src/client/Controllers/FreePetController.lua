--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local QuestsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.QuestsActions)

-- Controllers
local DataCacheController = nil
local NotificationControlller = nil
local StoreController = nil

-- Services
local FreePetService = nil
local RejoinService = nil

-- FreePetController
local FreePetController = Knit.CreateController({
    Name = "FreePetController",
    Template = {}
})

--|| Functions ||--
function FreePetController:Claim()
    local promise, res = FreePetService:Claim():await()
    if not promise then return warn("[FREE PET CONTROLLER] An internal error occured while claiming free pets.") end

    NotificationControlller:Notify(res)
end

function FreePetController:Buy(number: number)
    StoreController:BuyItem({ name = `x{number} Free Pet` })
end

function FreePetController:ClaimRejoin()
    print("Claiming rejoin")
    local promise, res = RejoinService:Claim():await()
    if not promise then return warn("[FREE PET CONTROLLER] An internal error occured while claiming rejoin pets.") end

    NotificationControlller:Notify(res)
end


--|| Knit Lifecycle ||--
function FreePetController:KnitInit()
    DataCacheController = Knit.GetController("DataCacheController")
    NotificationControlller = Knit.GetController("NotificationController")
    StoreController = Knit.GetController("StoreController")
    RejoinService = Knit.GetService("RejoinService")

    FreePetService = Knit.GetService("FreePetService")

    self.Template = DataCacheController:GetFile("Template")

    print("[FREE PET CONTROLLER] Controller loaded successfully.")
end

return FreePetController