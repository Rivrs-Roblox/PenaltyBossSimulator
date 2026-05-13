--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local MonetizationService = nil

-- Controllers
local NotificationController = nil
local DataCacheController = nil
local MonetizationController = nil

-- StoreController
local StoreController = Knit.CreateController({
    Name = "StoreController",

    Template = {} :: nil
})

--|| Functions ||--
function StoreController:BuyItem(params: table)
    setmetatable(params, { __index = { name = "" :: string }})

    if params.name == "" then return end

    local res = MonetizationController:GetID(params.name)

    if res ~= nil then
        local p, r = MonetizationService:PromptPurchase(res.ID, res.Type):await()
        if p == false then return warn("[STORE CONTROLLER] An internal error occured while prompting for purchase.") end

        if r ~= nil then NotificationController:Notify(r) end
    end
end

--|| Knit Lifecycle ||--
function StoreController:KnitInit()
    MonetizationService = Knit.GetService("MonetizationService")

    NotificationController = Knit.GetController("NotificationController")
    DataCacheController = Knit.GetController("DataCacheController")
    MonetizationController = Knit.GetController("MonetizationController")

    self.Template = DataCacheController:GetFile("Template")

    MonetizationService.PurchaseFinished:Connect(function(success)
        if success then
            NotificationController:Notify({ text = self.Template.Messages.Notifications.Purchase_Success, type = "SUCCESS" })
        else
            NotificationController:Notify({ text = self.Template.Messages.Notifications.Purchase_Error, type = "ERROR" })
        end
    end)

    print("[STORE CONTROLLER] Controller loaded successfully.")
end

return StoreController