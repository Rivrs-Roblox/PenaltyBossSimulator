-- AllRewards/Frames/SpinWheels/Wheel.lua
-- Visual SpinWheels untuk AllRewards, logic spin/buy mengikuti Applications/Spins.
-- Reward item dibangun dari Template.Spins agar ikon dan chance tidak hardcode.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatDuration = require(Helpers.FormatDuration)

local SpinButton = require(script.Parent.SpinButton)
local WheelReward = require(script.Parent.WheelReward)

local DataCacheController = Knit.GetController("DataCacheController")
local SpinController = Knit.GetController("SpinController")
local MonetizationController = Knit.GetController("MonetizationController")

local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local FREE_SPIN_INTERVAL = 60 * 15

local COLORS = {
	Free = {
		accent = Color3.fromHex("35ff42"),
		accentHex = "35ff42",
		spinGradient = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("42c747")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("118311")),
		},
		spinStroke = Color3.fromHex("60ff88"),
		spinCenterStroke = Color3.fromHex("1f446b"),
		spinCenterGradient = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("46ddff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("1e61ff")),
		},
		buyGradient = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("3f91fc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("234fad")),
		},
		buyStroke = Color3.fromHex("2ad1ff"),
	},

	Premium = {
		accent = Color3.fromHex("ffa200"),
		accentHex = "ffa200",
		spinGradient = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffcf43")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("c86c05")),
		},
		spinStroke = Color3.fromHex("ffdb65"),
		spinCenterGradient = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffde25")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff6f0f")),
		},
		spinCenterStroke = Color3.fromHex("6b3116"),
		buyGradient = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("ff6754")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("a91f1f")),
		},
		buyStroke = Color3.fromHex("ff8c75"),
	},
}

local PRODUCTS = {
	Free = {
		first = { itemName = "x10 Free Spins", value = "+10" },
		second = { itemName = "x30 Free Spins", value = "+30" },
	},

	Premium = {
		first = { itemName = "x1 Premium Spins", value = "+1" },
		second = { itemName = "x10 Premium Spins", value = "+10" },
	},
}

local REWARD_ICON_MAP = {
	Money1 = "Money1",
	Money2 = "Money2",
	Wins = "Wins",
	Win = "Wins",
	Rebirth = "Rebirth",
	Rebirths = "Rebirths",
	Premium_Spin = "Spin_Wheel",
	Free_Spin = "Spin_Wheel",
	Fruit = "Fruits",
	Boost = "Boosts",
}

local function getPrice(itemName)
	local ok, price = pcall(function()
		return MonetizationController:GetPrice(itemName)
	end)

	local robuxIcon = Template and Template.Messages and Template.Messages.Robux_Icon or "R$"

	if ok and price ~= nil then
		return `{robuxIcon} {price}`
	end

	return `{robuxIcon} ...`
end

local function getSpinAmount(spinsReducer, wheelType)
	local spins = spinsReducer and spinsReducer.Spins
	if typeof(spins) ~= "table" then
		return 0
	end

	return spins[wheelType] or 0
end

local function getLastFreeSpin(spinsReducer, fallback)
	local spins = spinsReducer and spinsReducer.Spins
	if typeof(spins) ~= "table" then
		return fallback
	end

	return spins.Last_Free_Spin or fallback
end

local function formatName(name)
	name = tostring(name or "Reward")

	local economy = Template and Template.Economy or {}
	local money1 = economy.Money1 or "Money1"
	local money2 = economy.Money2 or "Money2"

	return name:gsub("MONEY_1", money1):gsub("MONEY_2", money2):gsub("_", " ")
end

local function getRewardImage(reward)
	if typeof(reward) ~= "table" then
		return UI.Gift or ""
	end

	if reward.Reward == "Boost" and reward.Boost then
		return UI[reward.Boost] or UI.Boosts or UI.Gift or ""
	end

	if reward.Reward == "Fruit" and reward.Fruit then
		return UI[reward.Fruit] or UI.Fruits or UI.Gift or ""
	end

	local imageKey = REWARD_ICON_MAP[reward.Reward] or reward.Reward
	return UI[imageKey] or UI[reward.Reward] or UI.Gift or ""
end

local function getRewardLabel(reward)
	if typeof(reward) ~= "table" then
		return "REWARD"
	end

	if reward.Reward == "Boost" and reward.Boost then
		return formatName(reward.Boost)
	end

	if reward.Reward == "Fruit" and reward.Fruit then
		return formatName(reward.Fruit)
	end

	return formatName(reward.Reward)
end

local function getRewardAmount(reward)
	if typeof(reward) ~= "table" then
		return ""
	end

	if reward.Reward == "Boost" or reward.Reward == "Fruit" then
		return `x{reward.Amount or 0}`
	end

	return `+{reward.Amount or 0}`
end

local function buildRewards(wheelType)
	local templateSpins = Template and Template.Spins or {}
	local rewards = templateSpins[wheelType] or {}
	local children = {}
	local totalRewards = #rewards

	if totalRewards <= 0 then
		return children
	end

	local radius = totalRewards >= 8 and 0.335 or 0.32
	local rewardSize = totalRewards >= 8 and UDim2.fromScale(0.2, 0.2) or UDim2.fromScale(0.24, 0.24)

	for index, reward in ipairs(rewards) do
		-- Index 1 dimulai di atas, lalu berputar searah jarum jam mengikuti rumus SpinService.
		local angle = -90 + ((index - 1) / totalRewards) * 360
		local radians = math.rad(angle)
		local x = 0.5 + math.cos(radians) * radius
		local y = 0.5 + math.sin(radians) * radius

		children[`Reward_{index}`] = Roact.createElement(WheelReward, {
			position = UDim2.fromScale(x, y),
			rotation = angle + 90,
			size = rewardSize,
			data = {
				percent = `{reward.Chance or 0}%`,
				name = string.upper(getRewardLabel(reward)),
				amount = getRewardAmount(reward),
				image = getRewardImage(reward),
			},
		})
	end

	return children
end

return function(params)
	params = params or {}

	local hooks = params.hooks
	local wheelType = params.type or "Free"
	local style = COLORS[wheelType] or COLORS.Free
	local products = PRODUCTS[wheelType] or PRODUCTS.Free

	local SpinsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.SpinsReducer
	end) or {}

	-- Dipertahankan seperti Applications/Spins agar reducer terkait tetap ter-subscribe ketika quest berubah.
	RoduxHooks.useSelector(hooks, function(state)
		return state.QuestsReducer
	end)

	local now, setNow = hooks.useState(os.time())

	hooks.useEffect(function()
		if wheelType ~= "Free" then
			return function() end
		end

		local running = true
		task.spawn(function()
			while running do
				setNow(os.time())
				task.wait(1)
			end
		end)

		return function()
			running = false
		end
	end, { wheelType })

	local spinAmount = getSpinAmount(SpinsReducer, wheelType)
	local lastFreeSpin = getLastFreeSpin(SpinsReducer, now)
	local nextFreeSpinRemaining = math.clamp(FREE_SPIN_INTERVAL - (now - lastFreeSpin), 0, FREE_SPIN_INTERVAL)
	local plural = spinAmount > 1 and "s" or ""

	local wheelImage = UI[`{wheelType}_Wheel`] or ""
	local middleImage = UI[`{wheelType}_Wheel_Middle`] or ""
	local triangleImage = UI.Wheel_Triangle or ""

	return Roact.createElement("Frame", {
		Name = `{wheelType}Wheel`,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.8,
		LayoutOrder = params.layoutOrder or params.order or 1,
		Size = UDim2.fromScale(0.48, 1),
		ZIndex = 4,
	}, {
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 15) }),
		UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("6f6f6f"), Thickness = 2 }),
		List = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		TitleText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.2, 0.022),
			RichText = true,
			Size = UDim2.fromScale(0.9, 0.1),
			Text = `<font color="#{style.accentHex}">{string.upper(wheelType)}</font> WHEEL`,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 5,
		}, {
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("191919"), Thickness = 2 }),
		}),

		WheelHolder = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.72, 0.72),
			ZIndex = 5,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),

			Wheel = Roact.createElement("ImageLabel", {
				Name = "Wheel",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = wheelImage,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1.05, 1.05),
				ZIndex = 5,
			}, buildRewards(wheelType)),

			Land = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Image = triangleImage,
				Position = UDim2.fromScale(0.5, -0.02),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.15, 0.15),
				ZIndex = 15,
			}, {
				AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
			}),

			--Spin2 = Roact.createElement("ImageButton", {
			--	AnchorPoint = Vector2.new(0.5, 0.5),
			--	BackgroundTransparency = 1,
			--	BorderSizePixel = 0,
			--	Image = middleImage,
			--	Position = UDim2.fromScale(0.5, 0.5),
			--ScaleType = Enum.ScaleType.Fit,
			--	Size = UDim2.fromScale(0.2, 0.2),
			--ZIndex = 25,
			--	[Roact.Event.MouseButton1Click] = function()
			--		SpinController:Spin(wheelType)
			--	end,
			--}, {
			--	Ratio = Roact.createElement("UIAspectRatioConstraint"),
			--}),

			Spin = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 25,
				Size = UDim2.fromScale(0.18, 0.18),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				[Roact.Event.MouseButton1Click] = function()
					SpinController:Spin(wheelType)
				end,
			}, {
				ButtonText = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ffffff"),
					Text = "SPIN!",
					FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = 100,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.48, 0.5),
					TextSize = 32,
					TextScaled = true,
					ZIndex = 26,
					Size = UDim2.fromScale(0.8, 0.4),
				}, {
					UIStroke = Roact.createElement("UIStroke", {
						Color = style.spinCenterStroke,
						Thickness = 2,
					}),
				}),
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new(style.spinCenterGradient),
					Rotation = 90,
				}),
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				UIStroke = Roact.createElement("UIStroke", {
					Color = style.spinCenterStroke,
					Thickness = 2,
				}),
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
		}),

		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Position = UDim2.fromScale(0.5, 0.92),
			Size = UDim2.fromScale(0.9, 0.08),
			ZIndex = 20,
		}, {
			List = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),

			BuyOne = SpinButton({
				layoutOrder = 1,
				text = products.first.value,
				price = getPrice(products.first.itemName),
				gradient = style.buyGradient,
				strokeColor = style.buyStroke,
				onClick = function()
					SpinController:Buy(products.first.itemName)
				end,
			}),

			Spin = SpinButton({
				layoutOrder = 2,
				text = `x{spinAmount} Spin{plural}`,
				gradient = style.spinGradient,
				strokeColor = style.spinStroke,
				showNotification = spinAmount>0,
				onClick = function()
					SpinController:Spin(wheelType)
				end,
			}),
			BuyTen = SpinButton({
				layoutOrder = 3,
				text = products.second.value,
				price = getPrice(products.second.itemName),
				gradient = style.buyGradient,
				strokeColor = style.buyStroke,
				onClick = function()
					SpinController:Buy(products.second.itemName)
				end,
			}),
		}),

		NextText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			LayoutOrder = 4,
			Position = UDim2.fromScale(0.5, 1.02),
			Size = UDim2.fromScale(0.8, 0.05),
			Text = `+1 Spin in {FormatDuration(nextFreeSpinRemaining)}`,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			Visible = wheelType == "Free",
			ZIndex = 5,
		}, {
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("191919"), Thickness = 2 }),
		}),
	})
end
