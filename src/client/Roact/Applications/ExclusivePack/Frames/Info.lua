--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local InfoItemCard = require(Components.Shop.InfoItemCard)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local Template = DataCacheController:GetFile("Template")

return function(hooks)
	local infoItems = {}
	for index, item in ipairs(Template.Shop.ExclusiveChest.Pets) do
		infoItems["infoItem" .. index] = InfoItemCard({
			LayoutOrder = index,
			hooks = hooks,
			hover = item.Text,
			order = item.Order,
		}, item)
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.865),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0.29),
	}, {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			VerticalAlignment = 0,
			HorizontalAlignment = 0,
			SortOrder = 2,
			CellSize = UDim2.fromScale(0.125, 1),
			FillDirectionMaxCells = 1,
			CellPadding = UDim2.fromScale(0.05, 0),
			FillDirection = 1,
		}),
		InfoItems = Roact.createFragment(infoItems),
	})
end
