-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local NotificationController
local RebirthService

-- TemplateController
local RebirthController = Knit.CreateController({
	Name = "RebirthController",
})

--|| Local Functions ||--

function RebirthController:Rebirth()
	RebirthService:Rebirth(Players.LocalPlayer):andThen(function(result)
		NotificationController:Notify({
			tag = "Rebirth",
			text = result.text,
			type = result.type,
		})
		return result
	end)
end

function RebirthController:CanRebirth()
	repeat
		task.wait()
	until RebirthService

	return RebirthService:CanRebirth():andThen(function(result)
		return result
	end)
end

--|| Functions ||--

function RebirthController:KnitStart()
	local DataCacheController = Knit.GetController("DataCacheController")
	self.Template = DataCacheController:GetFile("Template")

	NotificationController = Knit.GetController("NotificationController")

	RebirthService = Knit.GetService("RebirthService")

	print("[REBIRTH CONTROLLER] Controller started successfully.")
end

return RebirthController
