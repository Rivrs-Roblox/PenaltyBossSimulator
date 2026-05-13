-- AllRewards/Application.lua
-- Entry utama, disusun seperti Inventory: Application.lua -> Frames -> sub frame.
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local Frames = script.Parent.Frames
local Panel = require(Frames.Panel.Panel)
local TimeRewards = require(Frames.TimeRewards.TimeRewards)
local DailyRewards = require(Frames.DailyRewards.DailyRewards)
local SpinWheels = require(Frames.SpinWheels.SpinWheels)

local UIController = Knit.GetController("UIController")

local function AllRewards(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

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
			Visible = UIReducer.CurrentUI == FramesConstants.AllRewards,
			ZIndex = 2,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = 1.6 }),
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("1e314b")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("0a0e27")),
				}),
				Rotation = 90,
			}),
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("ffffff"), Thickness = 5 }, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("3369e6")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("1e388d")),
					}),
					Rotation = 90,
				}),
			}),

			Close = Roact.createElement("ImageButton", {
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
				UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
				Ratio = Roact.createElement("UIAspectRatioConstraint"),
				Icon = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://120045489184571",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.5, 0.5),
					ZIndex = 11,
				}),
				UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("8f0000"), Thickness = 3 }),
			}),
			TimeRewards = TimeRewards(hooks),
			DailyRewards = DailyRewards(hooks),
			SpinWheels = SpinWheels(hooks),
		}),
	})
end

AllRewards = RoactHooks.new(Roact)(AllRewards)
return AllRewards
