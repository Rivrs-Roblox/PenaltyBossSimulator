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
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Helpers
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)
local GetTableLength = require(ReplicatedStorage.Shared.Helpers.GetTableLength)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local RainbowMachineController = Knit.GetController("RainbowMachineController")
local UIController = Knit.GetController("UIController")

-- Frames
local Frames = script.Parent.Frames
local Scroll = require(Frames.Scroll)
local Pet = require(Frames.Pet)

-- UI
local UI = DataCacheController:GetFile("Images")
local Colors = DataCacheController:GetFile("Colors")
local PetsData = DataCacheController:GetFile("Pets")

local TITLE_ICON = "rbxassetid://103901141281428"
local CLOSE_ICON = "rbxassetid://120045489184571"

local function Title()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.04, 0.08),
		Size = UDim2.fromScale(0.55, 0.09),
		ZIndex = 5,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Icon = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = TITLE_ICON,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.2, 1.2),
			ZIndex = 6,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		TitleText = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Size = UDim2.fromScale(0.8, 1),
			Text = "Rainbow Pets",
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 6,
		}),
	})
end

local function CloseButton()
	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.94, 0.08),
		Size = UDim2.fromScale(0.09, 0.09),
		ZIndex = 10,

		[Roact.Event.MouseButton1Click] = function()
			UIController:HideFrame()
		end,
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
			}),
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("8f0000"),
			Thickness = 3,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = CLOSE_ICON,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.5, 0.5),
			ZIndex = 11,
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint"),
	})
end

local function SearchBar(textBoxRef)
	return Roact.createElement("Frame", {
		LayoutOrder = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("3b65a3"),
		Position = UDim2.fromScale(0.265, 0.5),
		Size = UDim2.fromScale(0.52, 1),
		ZIndex = 10,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("6f88e1"),
			Thickness = 2,
		}),
		TextBox = Roact.createElement("TextBox", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			PlaceholderColor3 = Color3.fromHex("ffffff"),
			PlaceholderText = "Search pets...",
			Position = UDim2.fromScale(0.12, 0.5),
			Size = UDim2.fromScale(0.66, 0.5),
			Text = "",
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextTransparency = 0.5,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 11,

			[Roact.Ref] = textBoxRef,
		}),
		SearchIcon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = 0.5,
			Image = "rbxassetid://108045196460145",
			Position = UDim2.fromScale(0.06, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.6, 0.6),
			ZIndex = 12,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = TITLE_ICON,
			Position = UDim2.fromScale(0.93, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8),
			ZIndex = 12,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),
		
	})
end

local function CraftButton()
	return Roact.createElement("ImageButton", {
		LayoutOrder = 3,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.18, 1),
		ZIndex = 10,

		[Roact.Event.MouseButton1Click] = function()
			RainbowMachineController:Craft()
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("04da01"),
			Thickness = 2,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("00d921")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("0e820e")),
			}),
			Rotation = 90,
		}),
		ButtonText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.55),
			Text = "Craft",
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 11,
		}),
	})
end

local function BottomBar(params)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.93),
		Size = UDim2.fromScale(0.9, 0.1),
		ZIndex = 8,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		SearchBar = SearchBar(params.textBoxRef),

		AmountText = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Size = UDim2.fromScale(0.2, 0.6),
			Text = params.amountText,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 10,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 1.5,
			}),
		}),

		Craft = CraftButton(),
	})
end

-- RainbowPets
function RainbowPets(_, hooks)
	local PetsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PetsReducer
	end)
	local RainbowPetsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RainbowPetsReducer
	end)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local TextBoxRef = hooks.useValue(Roact.createRef())
	local SearchText, SetSearchText = hooks.useState("")

	hooks.useEffect(function()
		local textBox = TextBoxRef.value:getValue()
		if textBox == nil then
			return nil
		end

		local connection = textBox:GetPropertyChangedSignal("Text"):Connect(function()
			SetSearchText(string.lower(textBox.Text))
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local index = 0
	local MyPets = {}

	for id, pet in pairs(PetsReducer.Pets) do
		if MyPets[id] == nil then
			if not string.find(pet.Name, "Gold ") then
				continue
			end
			if SearchText == "" or string.find(string.lower(pet.Name), string.lower(SearchText)) then
				local Icon = UI[pet.Name]
				if Icon == nil then
					Icon = UI[pet.Name:gsub("Gold ", ""):gsub("Rainbow ", "")]
				end

				local powerData = PetsData[pet.Name].Power
				if powerData == nil and PetsData[pet.Name].Type == "Scaling" then
					powerData = PetsReducer.ScaledPetsPower[pet.Name]
				end

				MyPets[id] = Pet({
					equipped = RainbowPetsReducer.SelectedRainbowPets[id] ~= nil,
					icon = Icon,
					name = pet.Name,
					id = id,
					power = `x{FormatNumber(powerData)}`,
					bg_color = Colors[pet.Rarity],
					rarity = pet.Rarity,
					order = -powerData,
				})

				index += 1
			end
		end
	end

	local selectedCount = GetTableLength(RainbowPetsReducer.SelectedRainbowPets)
	local amountText = `{selectedCount}/3 ({math.floor(selectedCount / 3 * 100)}%)`

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		Popup = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			Visible = UIReducer.CurrentUI == FramesConstants.RainbowPets,
			ZIndex = 2,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.6,
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("1e314b")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("0a0e27")),
				}),
				Rotation = 90,
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 5,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("3369e6")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("1e388d")),
					}),
					Rotation = 90,
				}),
			}),

			Title = Title(),
			Close = CloseButton(),
			PlayerScroll = Scroll({ children = MyPets }),
			Bottom = BottomBar({
				textBoxRef = TextBoxRef.value,
				amountText = amountText,
			}),

			EmptyText = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.2),
				Text = "You have nothing to show here yet ):",
				TextColor3 = Color3.fromHex("ffffff"),
				TextScaled = true,
				TextTransparency = 0.8,
				TextWrapped = true,
				Visible = index <= 0,
				ZIndex = 20,
			}),
		}),
	})
end

RainbowPets = RoactHooks.new(Roact)(RainbowPets)
return RainbowPets
