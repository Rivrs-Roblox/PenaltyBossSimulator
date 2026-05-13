--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatDuration = require(Helpers.FormatDuration)
local FindValue = require(Helpers.Table.FindValue)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local List = require(Components.List)
local Grid = require(Components.Grid)
local AspectRatio = require(Components.AspectRatio)
local Text = require(Components.Text)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

-- ActiveEffects
function ActiveEffects(_, hooks)
	local FruitsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.FruitsReducer
	end)
	local MonetizationReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.MonetizationReducer
	end)
	local ChestsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.ChestsReducer
	end)
	local BoostsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.BoostsReducer
	end)
	local _ = RoduxHooks.useSelector(hooks, function(state)
		return state.QuestsReducer
	end)

	local function GetFriends()
		local Friends = {}
		for _, Player in Players:GetPlayers() do
			if Player ~= Players.LocalPlayer then
				if Player:IsFriendsWith(Players.LocalPlayer.UserId) then
					table.insert(Friends, Player)
				end
			end
		end
		return Friends
	end

	local Friends = {}
	Friends = GetFriends()

	local activeEffects = {}
	local lastID = 0

	for id, fruit in pairs(FruitsReducer.ActiveFruits) do
		lastID = id
		activeEffects[fruit.Name] = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LayoutOrder = tonumber(id),
			Image = UI[fruit.Name],
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
			Title = Text({
				text = FormatDuration(fruit.End - os.time()),
				color = Color3.fromRGB(255, 255, 255),
				position = UDim2.fromScale(0.5, 0.9),
				size = UDim2.fromScale(0.985, 0.37),
				backgroundTransparency = 1,
				stroke = 1.5,
			}),
		})
	end

	for id, boost in pairs(BoostsReducer.ActiveBoosts) do
		lastID = id
		activeEffects[id] = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LayoutOrder = tonumber(id),
			Image = UI[boost.Name],
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
			Title = Text({
				text = FormatDuration(boost.End - os.time()),
				color = Color3.fromRGB(255, 255, 255),
				position = UDim2.fromScale(0.5, 0.9),
				size = UDim2.fromScale(0.985, 0.37),
				backgroundTransparency = 1,
				stroke = 1.5,
			}),
		})
	end

	if ChestsReducer.Verified == true then
		activeEffects["Verified"] = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LayoutOrder = tonumber(lastID + 1),
			Image = UI.Codes,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
			Title = Text({
				text = "+100%",
				color = Color3.fromRGB(255, 255, 255),
				position = UDim2.fromScale(0.5, 0.9),
				size = UDim2.fromScale(0.985, 0.37),
				backgroundTransparency = 1,
				stroke = 1.5,
			}),
		})
	end

	if Players.LocalPlayer.MembershipType == Enum.MembershipType.Premium then
		activeEffects["Roblox Premium"] = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LayoutOrder = tonumber(lastID + 2),
			Image = UI.Roblox,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
			Title = Text({
				text = "+10%",
				color = Color3.fromRGB(255, 255, 255),
				position = UDim2.fromScale(0.5, 0.9),
				size = UDim2.fromScale(0.985, 0.37),
				backgroundTransparency = 1,
				stroke = 1.5,
			}),
		})
	end

	if FindValue(MonetizationReducer.Gamepasses, "VIP") then
		activeEffects["VIP"] = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LayoutOrder = tonumber(lastID + 3),
			Image = UI.VIP_Icon,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
			Title = Text({
				text = "+100%",
				color = Color3.fromRGB(255, 255, 255),
				position = UDim2.fromScale(0.5, 0.9),
				size = UDim2.fromScale(0.985, 0.37),
				backgroundTransparency = 1,
				stroke = 1.5,
			}),
		})
	end

	activeEffects["Friends"] = Roact.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = tonumber(lastID + 4),
		Image = UI.Invite,
		ScaleType = Enum.ScaleType.Fit,
		Visible = #Friends > 0,
	}, {
		AspectRatio = AspectRatio({ ratio = 1 }),
		Title = Text({
			text = `+{#Friends * 10}%`,
			color = Color3.fromRGB(255, 255, 255),
			position = UDim2.fromScale(0.5, 0.9),
			size = UDim2.fromScale(0.985, 0.37),
			backgroundTransparency = 1,
			stroke = 1.5,
		}),
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.105, 0.89),
		Size = UDim2.fromScale(0.2, 0.2),
		ZIndex = 1,
	}, {
		List = List({
			padding = UDim.new(0.02, 0),
			fillDirection = Enum.FillDirection.Vertical,
			horizontalAlignment = Enum.HorizontalAlignment.Left,
			verticalAlignment = Enum.VerticalAlignment.Bottom,
		}),

		Container = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1.009, 0.882),
			BackgroundTransparency = 1,
		}, {
			AspectRatio = AspectRatio({ ratio = 2.2 }),
			Grid = Grid({
				cellPadding = UDim2.fromScale(0.01, 0.05),
				cellSize = UDim2.fromScale(0.15, 0.3),
				verticalAlignment = Enum.VerticalAlignment.Bottom,
			}),

			Roact.createFragment(activeEffects),
		}),
	})
end

ActiveEffects = RoactHooks.new(Roact)(ActiveEffects)
return ActiveEffects
