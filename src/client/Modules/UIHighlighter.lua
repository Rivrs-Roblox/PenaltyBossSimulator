local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIHighlighter = {}
UIHighlighter.__index = UIHighlighter

local activeHighlights = {}

--[[
	Highlights a GuiObject by creating an outline frame inside it that pulsates.
]]
function UIHighlighter.Highlight(guiObject: GuiObject)
	if not guiObject or typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiObject") then
		warn("UIHighlighter: Invalid GuiObject passed.")
		return
	end

	-- If it's already highlighted, do nothing
	if activeHighlights[guiObject] then
		return
	end

	local highlightTemplate = ReplicatedStorage:FindFirstChild("Highlight")
	if not highlightTemplate then
		warn("UIHighlighter: ReplicatedStorage.Highlight not found!")
		return
	end

	-- Create an overlay frame from ReplicatedStorage
	local outlineFrame = highlightTemplate:Clone()
	outlineFrame.Name = "UIHighlighterOverlay"
	outlineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	outlineFrame.Position = UDim2.fromScale(0.5, 0.5)
	outlineFrame.Rotation = 180
	outlineFrame.Size = UDim2.fromScale(1, 1)
	outlineFrame.Parent = guiObject

	local tweenInfo = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1, -- Loop indefinitely
		true -- Reverse (pulsate)
	)

	local goalSize = UDim2.fromScale(1.2, 1.2)
	local tween = TweenService:Create(outlineFrame, tweenInfo, { Size = goalSize })

	activeHighlights[guiObject] = {
		tween = tween,
		outlineFrame = outlineFrame,
	}

	tween:Play()
end

--[[
	Highlights a position on screen by creating an outline frame inside it that pulsates.
]]
function UIHighlighter.HighlightHere(id: string, size: UDim2, position: UDim2, parent: Instance)
	-- If it's already highlighted, do nothing
	if activeHighlights[id] then
		return
	end

	local highlightTemplate = ReplicatedStorage:FindFirstChild("Highlight")
	if not highlightTemplate then
		warn("UIHighlighter: ReplicatedStorage.Highlight not found!")
		return
	end

	-- Create an overlay frame from ReplicatedStorage
	local outlineFrame = highlightTemplate:Clone()
	outlineFrame.Name = "UIHighlighterOverlay"
	outlineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	outlineFrame.Position = position
	outlineFrame.Size = size
	outlineFrame.Parent = parent

	local tweenInfo = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1, -- Loop indefinitely
		true -- Reverse (pulsate)
	)

	local goalSize = UDim2.fromScale(size.X.Scale * 1.2, size.Y.Scale * 1.2)
	local tween = TweenService:Create(outlineFrame, tweenInfo, { Size = goalSize })

	activeHighlights[id] = {
		tween = tween,
		outlineFrame = outlineFrame,
	}

	tween:Play()
end

--[[
	Stops highlighting the given GuiObject and cleans up.
]]
function UIHighlighter.Stop(guiObject: GuiObject)
	local highlightData = activeHighlights[guiObject]
	if highlightData then
		highlightData.tween:Cancel()
		highlightData.outlineFrame:Destroy()
		activeHighlights[guiObject] = nil
	end
end

--[[
	Stops all active highlights.
]]
function UIHighlighter.StopAll()
	for guiObject, _ in pairs(activeHighlights) do
		UIHighlighter.Stop(guiObject)
	end
end
return UIHighlighter
