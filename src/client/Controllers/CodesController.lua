--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Controllers
local NotificationController = nil
local UIController = nil

-- Services
local CodesService = nil

-- CodesController
local CodesController = Knit.CreateController({
    Name = "CodesController",
})

--|| Functions ||--
function CodesController:Redeem(code: string)
    local promise, res = CodesService:Redeem(code):await()
    if promise == false then return warn("[CODES CONTROLLER] An internal error occured while redeeming code.") end

    NotificationController:Notify(res)
    if res.type == "SUCCESS" then
        UIController:HideFrame()
    end
end

function CodesController:Verify(code: string)
    local promise, res = CodesService:Verify(code):await()
    if promise == false then return warn("[CODES CONTROLLER] An internal error occured while verifying player.") end

    NotificationController:Notify(res)
    if res.type == "SUCCESS" then
        -- UIController:HideFrame()
    end
end

--|| Knit Lifecycle ||--
function CodesController:KnitInit()
    NotificationController = Knit.GetController("NotificationController")
    UIController = Knit.GetController("UIController")

    CodesService = Knit.GetService("CodesService")
    
    print("[CODES CONTROLLER] Controller loaded successfully.")
end

return CodesController