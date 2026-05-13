local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zone = require(ReplicatedStorage.Shared.ZonePlus)

return function(tagName: string, callbacks: { onEnter: ((Player) -> ())?, onExit: ((Player) -> ())? })
	local function setupArea(area)
		if area:GetAttribute("IsZoneSetup") then
			return
		end
		area:SetAttribute("IsZoneSetup", true)

		local zone = Zone.new(area)

		if callbacks.onEnter then
			zone.playerEntered:Connect(callbacks.onEnter)
		end

		if callbacks.onExit then
			zone.playerExited:Connect(callbacks.onExit)
		end
	end

	for _, area in CollectionService:GetTagged(tagName) do
		setupArea(area)
	end

	CollectionService:GetInstanceAddedSignal(tagName):Connect(setupArea)
end
