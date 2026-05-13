local BACKGROUND_IMAGE = "rbxassetid://116136315301524"
local LOGO_IMAGE = "rbxassetid://80173223874509"

-- Creating Loading Screen
local LoadingUI = Instance.new("ScreenGui")
LoadingUI.DisplayOrder = 5
LoadingUI.IgnoreGuiInset = true
LoadingUI.ResetOnSpawn = false
LoadingUI.Name = "LoadingUI"

-- ImageLabelBackground: full-screen root (name kept for Preloader compatibility)
local ImageLabelBackground = Instance.new("Frame")
ImageLabelBackground.Name = "ImageLabelBackground"
ImageLabelBackground.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabelBackground.Position = UDim2.fromScale(0.5, 0.5)
ImageLabelBackground.Size = UDim2.fromScale(1, 1)
ImageLabelBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabelBackground.BorderSizePixel = 0
ImageLabelBackground.Parent = LoadingUI

local RootGradient = Instance.new("UIGradient")
RootGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 7, 44)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})
RootGradient.Rotation = 60
RootGradient.Parent = ImageLabelBackground

-- Background
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "Background"
BackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
BackgroundImage.Position = UDim2.fromScale(0.5, 0.5)
BackgroundImage.Size = UDim2.fromScale(1, 1)
BackgroundImage.Image = BACKGROUND_IMAGE
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.ScaleType = Enum.ScaleType.Stretch
BackgroundImage.Parent = ImageLabelBackground
BackgroundImage.ImageTransparency = 0.85

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.AnchorPoint = Vector2.new(0.5, 0.5)
Logo.Position = UDim2.fromScale(0.5, 0.35)
Logo.Size = UDim2.fromScale(0.3, 0.3)
Logo.Image = LOGO_IMAGE
Logo.BackgroundTransparency = 1
Logo.ScaleType = Enum.ScaleType.Fit
Logo.BorderSizePixel = 0
Logo.Parent = ImageLabelBackground

local LogoRatio = Instance.new("UIAspectRatioConstraint")
LogoRatio.AspectRatio = 1.4
LogoRatio.Parent = Logo

-- Skip button
local Skip = Instance.new("ImageButton")
Skip.Name = "Skip"
Skip.AnchorPoint = Vector2.new(0.5, 0.5)
Skip.Position = UDim2.fromScale(0.5, 0.72)
Skip.Size = UDim2.fromScale(0.1, 0.055)
Skip.BackgroundColor3 = Color3.fromHex("495d99")
Skip.BorderSizePixel = 0
Skip.Parent = ImageLabelBackground
Skip.Visible = false -- Temp remove

local SkipCorner = Instance.new("UICorner")
SkipCorner.CornerRadius = UDim.new(0, 6)
SkipCorner.Parent = Skip

local SkipStroke = Instance.new("UIStroke")
SkipStroke.Color = Color3.fromHex("818bc7")
SkipStroke.Thickness = 2
SkipStroke.Parent = Skip

local SkipRatio = Instance.new("UIAspectRatioConstraint")
SkipRatio.AspectRatio = 2.2
SkipRatio.Parent = Skip

local SkipText = Instance.new("TextLabel")
SkipText.Text = "Skip"
SkipText.AnchorPoint = Vector2.new(0.5, 0.5)
SkipText.Position = UDim2.fromScale(0.5, 0.5)
SkipText.Size = UDim2.fromScale(0.85, 0.5)
SkipText.BackgroundTransparency = 1
SkipText.TextColor3 = Color3.fromHex("ffffff")
SkipText.TextScaled = true
SkipText.Font = Enum.Font.FredokaOne
SkipText.ZIndex = 2
SkipText.BorderSizePixel = 0
SkipText.Parent = Skip

-- BottomLeftImage: container for progress bar area (name kept for Preloader compatibility)
local BottomLeftImage = Instance.new("Frame")
BottomLeftImage.Name = "BottomLeftImage"
BottomLeftImage.AnchorPoint = Vector2.new(0.5, 0.5)
BottomLeftImage.Position = UDim2.fromScale(0.5, 0.6)
BottomLeftImage.Size = UDim2.fromScale(0.45, 0.45)
BottomLeftImage.BackgroundTransparency = 1
BottomLeftImage.BorderSizePixel = 0
BottomLeftImage.Parent = ImageLabelBackground

local Ratio = Instance.new("UIAspectRatioConstraint")
Ratio.AspectRatio = 5.45
Ratio.Parent = BottomLeftImage

local BarFrame = Instance.new("ImageLabel")
BarFrame.Name = "BarFrame"
BarFrame.Image = "rbxassetid://122354048064794"
BarFrame.AnchorPoint = Vector2.new(0.5, 0.5)
BarFrame.Position = UDim2.fromScale(0.5, 0.5)
BarFrame.Size = UDim2.fromScale(1, 1)
BarFrame.BackgroundTransparency = 1
BarFrame.Parent = BottomLeftImage
BarFrame.ZIndex = 2

-- local BackFrame = Instance.new("ImageLabel")
-- BackFrame.Name = "BackFrame"
-- BackFrame.Image = "rbxassetid://125295604981328"
-- BackFrame.AnchorPoint = Vector2.new(0, 0.5)
-- BackFrame.Position = UDim2.fromScale(0.189, 0.518)
-- BackFrame.Size = UDim2.fromScale(0.6, 0.633)
-- BackFrame.BackgroundTransparency = 1
-- BackFrame.Parent = BottomLeftImage

-- Background: progress bar bg (name kept for Preloader compatibility)
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.AnchorPoint = Vector2.new(0, 0.5)
Background.Position = UDim2.fromScale(0.189, 0.518)
Background.Size = UDim2.fromScale(0.785, 0.633)
Background.BackgroundTransparency = 1
Background.Parent = BottomLeftImage

-- Fill bar (name kept for Preloader compatibility)
local Fill = Instance.new("ImageLabel")
Fill.Name = "Fill"
Fill.Image = "rbxassetid://125295604981328"
Fill.AnchorPoint = Vector2.new(0, 0.5)
Fill.Position = UDim2.new(0, 0, 0.5, 0)
Fill.Size = UDim2.new(0, 0, 1, 0)
Fill.BackgroundTransparency = 1
Fill.Parent = Background

-- local FillCorner = Instance.new("UICorner")
-- FillCorner.CornerRadius = UDim.new(0.25, 0)
-- FillCorner.Parent = Fill

-- local FillGradient = Instance.new("UIGradient")
-- FillGradient.Color = ColorSequence.new({
-- 	ColorSequenceKeypoint.new(0, Color3.fromHex("ffa200")),
-- 	ColorSequenceKeypoint.new(1, Color3.fromHex("bf3609")),
-- })
-- FillGradient.Rotation = 90
-- FillGradient.Parent = Fill

-- Knob indicator
-- local Knob = Instance.new("ImageLabel")
-- Knob.Name = "Knob"
-- Knob.AnchorPoint = Vector2.new(0.5, 0.5)
-- Knob.Position = UDim2.fromScale(0, 0.5)
-- Knob.Size = UDim2.new(0, 0, 1.4, 0)
-- Knob.Image = "rbxassetid://85019492895590"
-- Knob.BackgroundTransparency = 1
-- Knob.BorderSizePixel = 0
-- Knob.ZIndex = 2
-- Knob.Parent = Background

-- local KnobRatio = Instance.new("UIAspectRatioConstraint")
-- KnobRatio.Parent = Knob

-- TextLabel: progress text (name kept for Preloader compatibility)
local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "TextLabel"
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.Position = UDim2.fromScale(0.5, 0.72)
TextLabel.Size = UDim2.fromScale(0.5, 0.05)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromHex("ffffff")
TextLabel.Text = "Loading..."
TextLabel.TextScaled = true
TextLabel.ZIndex = 2
TextLabel.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold)
TextLabel.BorderSizePixel = 0
TextLabel.Parent = ImageLabelBackground

-- wait for the loading screen
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui", 10)
LoadingUI.Parent = playerGUI

-- Function to clean up when loading is done
local function cleanupLoading()
	if LoadingUI and LoadingUI.Parent then
		LoadingUI:Destroy()
	end
end

task.wait(0.1)

-- Remove the default loading screen
game.ReplicatedFirst:RemoveDefaultLoadingScreen()

return {
	GUI = LoadingUI,
	Cleanup = cleanupLoading,
}
