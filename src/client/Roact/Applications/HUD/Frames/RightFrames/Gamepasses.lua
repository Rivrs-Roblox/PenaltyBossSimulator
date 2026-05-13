--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local ImageButton = require(Components.ImageButton)
local AspectRatio = require(Components.AspectRatio)

-- UI
local MonetizationService = Knit.GetService("MonetizationService")
local DataCacheController = Knit.GetController("DataCacheController")
local NotificationController = Knit.GetController("NotificationController")
local UI = DataCacheController:GetFile("Images")

-- Gamepasses
function Gamepasses(_, hooks)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(-0.15, 1.15),
		Size = UDim2.fromScale(1.1, 0.257),
		ZIndex = 1,
		LayoutOrder = 5,
	}, {

		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),

		VIP = ImageButton({
			image = UI.VIP,
			size = UDim2.fromScale(1, 1),
			backgroundTransparency = 1,
			order = 1,
			hooks = hooks,
			children = {
				AspectRatio = AspectRatio({ ratio = 1 }),
			},
			action = function()
				MonetizationService:PromptPurchase("VIP", "GamePasses"):andThen(function(result)
					if result ~= nil and result.type == "ERROR" then
						NotificationController:Notify(result)
					end
				end)
			end,
		}),

		x2DiscoBalls = ImageButton({
			image = UI.x2_Money2,
			size = UDim2.fromScale(1, 1),
			backgroundTransparency = 1,
			order = 2,
			hooks = hooks,
			children = {
				AspectRatio = AspectRatio({ ratio = 1 }),
			},
			action = function()
				MonetizationService:PromptPurchase("x2 Power", "GamePasses"):andThen(function(result)
					if result ~= nil and result.type == "ERROR" then
						NotificationController:Notify(result)
					end
				end)
			end,
		}),

		x2Wins = ImageButton({
			image = UI.x2_Wins,
			size = UDim2.fromScale(1, 1),
			backgroundTransparency = 1,
			order = 3,
			hooks = hooks,
			children = {
				AspectRatio = AspectRatio({ ratio = 1 }),
			},
			action = function()
				MonetizationService:PromptPurchase("x2 Wins", "GamePasses"):andThen(function(result)
					if result ~= nil and result.type == "ERROR" then
						NotificationController:Notify(result)
					end
				end)
			end,
		}),

		x2Rebirth = ImageButton({
			image = UI.x2_Rebirth,
			size = UDim2.fromScale(1, 1),
			backgroundTransparency = 1,
			order = 4,
			hooks = hooks,
			children = {
				AspectRatio = AspectRatio({ ratio = 1 }),
			},
			action = function()
				MonetizationService:PromptPurchase("x2 Rebirths", "GamePasses"):andThen(function(result)
					if result ~= nil and result.type == "ERROR" then
						NotificationController:Notify(result)
					end
				end)
			end,
		}),
	})
end

Gamepasses = RoactHooks.new(Roact)(Gamepasses)
return Gamepasses
