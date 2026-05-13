--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)

-- Constants
local X_MIN, Y_MIN = 0.25, 0.25
local X_MAX, Y_MAX = 0.75, 0.75

local SplashController = nil
local UIController = nil
local DataCacheController = nil
local DataService = nil

-- PopupController
local PopupController = Knit.CreateController({
	Name = "PopupController",
})

local Positions = {
	Wins = {
		Position = UDim2.fromScale(0.592, 0.055),
		Size = UDim2.fromScale(0.036, 0.14),
	},
	Fruits = {
		Position = UDim2.fromScale(0.06, 0.415),
		Size = UDim2.fromScale(0.036, 0.14),
	},
	Money2 = {
		Position = UDim2.fromScale(0.464, 0.05),
		Size = UDim2.fromScale(0.039, 0.13),
	},
}

--|| Functions ||--
function PopupController:TweenFrameIn(params: table)
	local TweenLook = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0)
	local In = TweenService:Create(params.Frame, TweenLook, { Size = params.Size })

	In:Play()
end

function PopupController:TweenMoneyFrameIn(params: table)
	params.Frame.Rotation = -90
	local initPos = params.Frame.Position
	params.Frame.ZIndex = 2
	params.Frame.Position = initPos + UDim2.fromScale(0.08, -0.08)
	local icon = params.Frame:FindFirstChild("Image")
	icon.ImageColor3 = Color3.fromRGB(50, 50, 50)

	local TweenLook = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local In = TweenService:Create(params.Frame, TweenLook, { Size = params.Size })

	local TweenInfoRotation = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local Rot = TweenService:Create(params.Frame, TweenInfoRotation, { Rotation = 0 })

	local TweenInfoPosition = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0)
	local Pos = TweenService:Create(params.Frame, TweenInfoPosition, { Position = initPos })

	local TweenInfoImageColor = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0)
	local ImageColor = TweenService:Create(icon, TweenInfoImageColor, { ImageColor3 = Color3.fromRGB(255, 255, 255) })

	ImageColor:Play()
	Pos:Play()
	Pos.Completed:Connect(function()
		ImageColor:Destroy()
		self:SpawnImpactCircle(initPos)
		SplashController:SplashMoneyObtained(initPos, Color3.fromRGB(212, 65, 78))
		Pos:Destroy() -- Changer la couleur en fonction du jeu
	end)
	Rot:Play()
	In:Play()
	In.Completed:Connect(function()
		In:Destroy()
	end)
end

function PopupController:TweenToPosAndSize(params: table)
	params.Text:Destroy()

	local TweenLook = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
	local Move = TweenService:Create(params.Frame, TweenLook, { Position = params.Position, Size = params.Size })

	Move:Play()
	Move.Completed:Connect(function()
		if params.Currency then
			UIController:TweenTopDisplaySize(params.Currency)
		end

		Move:Destroy()
	end)
	return Move
end

function PopupController:TweenMoneyToPosAndSize(params: table)
	params.Text:Destroy()

	local TweenLook = TweenInfo.new(0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, 0, false, 0)
	local Move = TweenService:Create(params.Frame, TweenLook, { Position = params.Position, Size = params.Size })

	Move:Play()
	Move.Completed:Connect(function()
		UIController:TweenTopDisplaySize("Money2")
		Move:Destroy()
	end)
	return Move
end

function PopupController:SpawnOnScreen(params: table): Frame
	setmetatable(params, {
		__index = {
			image = "" :: string,
			text = "" :: string,
		},
	})

	local RNG = Random.new()
	local Coords = UDim2.fromScale(RNG:NextNumber(X_MIN, X_MAX), RNG:NextNumber(Y_MIN, Y_MAX))

	local Frame = Instance.new("Frame", Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui"))
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.Size = UDim2.fromScale(0, 0)
	Frame.Position = Coords
	Frame.BackgroundTransparency = 1

	local Image = Instance.new("ImageLabel", Frame)
	Image.AnchorPoint = Vector2.new(0.5, 0.5)
	Image.Position = UDim2.fromScale(0.5, 0.5)
	Image.Size = UDim2.fromScale(0.8, 0.8)
	Image.Image = params.image
	Image.BackgroundTransparency = 1
	Image.ScaleType = Enum.ScaleType.Fit

	local Text = Instance.new("TextLabel", Frame)
	Text.AnchorPoint = Vector2.new(0.5, 0.5)
	Text.Position = UDim2.fromScale(0.5, 1)
	Text.Size = UDim2.fromScale(0.8, 0.325)
	Text.Text = params.text
	Text.TextScaled = true
	Text.TextColor3 = Color3.fromRGB(255, 255, 255)
	Text.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	Text.BackgroundTransparency = 1

	local Ratio = Instance.new("UIAspectRatioConstraint", Image)
	Ratio.AspectRatio = 1

	local Stroke = Instance.new("UIStroke", Text)
	Stroke.Thickness = 1.5

	self:TweenFrameIn({
		Frame = Frame,
		Size = UDim2.fromScale(RNG:NextNumber(0.0575, 0.095), RNG:NextNumber(0.10, 0.15)),
	})

	return {
		Frame = Frame,
		Text = Text,
	}
end

function PopupController:SpawnMoneyOnScreen(params: table): Frame
	setmetatable(params, {
		__index = {
			image = "" :: string,
			text = "" :: string,
		},
	})

	local RNG = Random.new()
	local Coords = UDim2.fromScale(RNG:NextNumber(X_MIN, X_MAX), RNG:NextNumber(Y_MIN, Y_MAX))

	local Frame = Instance.new("Frame", Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui"))
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.Size = UDim2.fromScale(0, 0)
	Frame.Position = Coords
	Frame.BackgroundTransparency = 1

	local Image = Instance.new("ImageLabel", Frame)
	Image.Name = "Image"
	Image.AnchorPoint = Vector2.new(0.5, 0.5)
	Image.Position = UDim2.fromScale(0.5, 0.5)
	Image.Size = UDim2.fromScale(0.8, 0.8)
	Image.Image = params.image
	Image.BackgroundTransparency = 1
	Image.ScaleType = Enum.ScaleType.Fit

	local Text = Instance.new("TextLabel", Frame)
	Text.AnchorPoint = Vector2.new(0.5, 0.5)
	Text.Position = UDim2.fromScale(0.5, 1)
	Text.Size = UDim2.fromScale(0.8, 0.325)
	Text.Text = params.text
	Text.TextScaled = true
	Text.TextColor3 = Color3.fromRGB(255, 255, 255)
	Text.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	Text.BackgroundTransparency = 1

	local Ratio = Instance.new("UIAspectRatioConstraint", Image)
	Ratio.AspectRatio = 1

	local Stroke = Instance.new("UIStroke", Text)
	Stroke.Thickness = 1.5

	self:TweenMoneyFrameIn({
		Frame = Frame,
		Size = UDim2.fromScale(RNG:NextNumber(0.06, 0.075), RNG:NextNumber(0.08, 0.12)),
	})

	return {
		Frame = Frame,
		Text = Text,
	}
end

function PopupController:SpawnImpactCircle(pos)
	local ImpactCircle = Instance.new("ImageLabel", Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui"))
	ImpactCircle.Image = "rbxassetid://18605797355"
	ImpactCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	ImpactCircle.Position = pos
	ImpactCircle.Size = UDim2.fromScale(0.06, 0.06)
	ImpactCircle.ImageColor3 = Color3.fromRGB(212, 65, 78)
	ImpactCircle.ImageTransparency = 0.5
	ImpactCircle.BackgroundTransparency = 1

	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", ImpactCircle)
	UIAspectRatioConstraint.AspectRatio = 1

	local TweenSizeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local TweenIn =
		TweenService:Create(ImpactCircle, TweenSizeInfo, { Size = UDim2.fromScale(0.18, 0.18), ImageTransparency = 1 })

	TweenIn:Play()
	TweenIn.Completed:Connect(function()
		ImpactCircle:Destroy()
		TweenIn:Destroy()
	end)
end

--|| Knit Lifecycle ||--
function PopupController:KnitInit()
	SplashController = Knit.GetController("SplashController")
	UIController = Knit.GetController("UIController")
	DataCacheController = Knit.GetController("DataCacheController")
	DataService = Knit.GetService("DataService")

	self.UI = DataCacheController:GetFile("Images")

	DataService.Money2Updated:Connect(function(value)
		local valueText

		if value > 0 then
			valueText = `+{FormatNumber(value)}`
		elseif value < 0 then
			valueText = FormatNumber(value)
		else
			return
		end

		local r = PopupController:SpawnOnScreen({
			image = self.UI["Money2"],
			text = valueText,
		})
		task.wait(1)
		PopupController:TweenToPosAndSize({
			Frame = r.Frame,
			Text = r.Text,
			Position = Positions.Money2.Position,
			Size = Positions.Money2.Size,
			Currency = "Money2",
		}).Completed
			:Connect(function()
				r.Frame:Destroy()
			end)
	end)

	DataService.WinsUpdated:Connect(function(value)
		local valueText

		if value > 0 then
			valueText = `+{FormatNumber(value)}`
		else
			valueText = FormatNumber(value)
		end

		local r = PopupController:SpawnOnScreen({
			image = self.UI["Wins"],
			text = valueText,
		})
		task.wait(1)
		PopupController:TweenToPosAndSize({
			Frame = r.Frame,
			Text = r.Text,
			Position = Positions.Wins.Position,
			Size = Positions.Wins.Size,
			Currency = "Wins",
		}).Completed
			:Connect(function()
				r.Frame:Destroy()
			end)
	end)

	-- WinsService.FruitsWon:Connect(function(fruits)
	-- 	for _, Fruit in fruits do
	-- 		local res = PopupController:SpawnMoneyOnScreen({ image = self.UI[Fruit.Name], text = "+1" })
	-- 		task.delay(1, function()
	-- 			PopupController:TweenToPosAndSize({
	-- 				Frame = res.Frame,
	-- 				Text = res.Text,
	-- 				Position = Positions.Fruits.Position,
	-- 				Size = Positions.Fruits.Size,
	-- 			}).Completed
	-- 				:Connect(function()
	-- 					res.Frame:Destroy()
	-- 				end)
	-- 		end)
	-- 	end
	-- end)

	-- BossFightService.FruitsWon:Connect(function(fruit)
	-- 	local res = PopupController:SpawnMoneyOnScreen({ image = self.UI[fruit.Name], text = `+{fruit.Amount}` })
	-- 	task.delay(1, function()
	-- 		PopupController:TweenToPosAndSize({
	-- 			Frame = res.Frame,
	-- 			Text = res.Text,
	-- 			Position = Positions.Fruits.Position,
	-- 			Size = Positions.Fruits.Size,
	-- 		}).Completed
	-- 			:Connect(function()
	-- 				res.Frame:Destroy()
	-- 			end)
	-- 	end)
	-- end)

	print("[POPUP CONTROLLER] Controller loaded successfully.")
end

return PopupController
