-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Controllers
local NotificationController = nil

-- Remote Events
local powerNotificationEvent = ReplicatedStorage.RemoteEvents:WaitForChild("PowerNotificationEvent")

-- PowerNotificationController
local PowerNotificationController = Knit.CreateController({
	Name = "PowerNotificationController",
})

local function notifyPlayer(message)
    NotificationController:Notify({ text = message, type = "ERROR" })
end

--|| Knit Lifecycle ||--
function PowerNotificationController:KnitInit()
	NotificationController = Knit.GetController("NotificationController")

    powerNotificationEvent.OnClientEvent:Connect(notifyPlayer)

	print("[POWER NOTIFICATION CONTROLLER] Controller loaded successfully!")
end

return PowerNotificationController
