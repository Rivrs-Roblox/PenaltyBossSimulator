--[=[
    Description: Custom Proximity Prompt UI Controller using ReplicatedStorage.Prompt template
    Integrated with Knit Framework
]=]
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local ProximityPromptController = Knit.CreateController({
	Name = "ProximityPromptController",
})
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Template from ReplicatedStorage
local promptTemplate = ReplicatedStorage:WaitForChild("FightPrompt")
-- Cache for active billboard GUIs mapping: ProximityPrompt -> Table of GUI elements and connections
local activePrompts = {}
-- Gamepad keycode map to clean button names
local GAMEPAD_BUTTON_MAP = {
	[Enum.KeyCode.ButtonA] = "A",
	[Enum.KeyCode.ButtonB] = "B",
	[Enum.KeyCode.ButtonX] = "X",
	[Enum.KeyCode.ButtonY] = "Y",
	[Enum.KeyCode.ButtonL1] = "LB",
	[Enum.KeyCode.ButtonR1] = "RB",
	[Enum.KeyCode.ButtonL2] = "LT",
	[Enum.KeyCode.ButtonR2] = "RT",
}
-- Helper function to recursively get all elements with their original transparencies
local function getOriginalTransparencies(gui)
	local trans = {}
	local function scan(inst)
		if inst:IsA("Frame") or inst:IsA("CanvasGroup") then
			trans[inst] = { ["BackgroundTransparency"] = inst.BackgroundTransparency }
		elseif inst:IsA("TextLabel") or inst:IsA("TextBox") then
			trans[inst] = { ["TextTransparency"] = inst.TextTransparency }
			local stroke = inst:FindFirstChildOfClass("UIStroke")
			if stroke then
				trans[stroke] = { ["Transparency"] = stroke.Transparency }
			end
		elseif inst:IsA("ImageLabel") then
			trans[inst] = { ["ImageTransparency"] = inst.ImageTransparency }
		elseif inst:IsA("UIStroke") then
			trans[inst] = { ["Transparency"] = inst.Transparency }
		end
		for _, child in ipairs(inst:GetChildren()) do
			scan(child)
		end
	end
	scan(gui)
	return trans
end
-- Helper function to tween transparencies
local function fadeGui(transparencies, targetTransparency, duration)
	for element, props in pairs(transparencies) do
		if element and element.Parent then
			local properties = {}
			for prop, originalVal in pairs(props) do
				if targetTransparency == 1 then
					-- Fade out to fully invisible
					properties[prop] = 1
				else
					-- Fade in to original transparency value
					properties[prop] = originalVal
				end
			end
			TweenService
				:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
				:Play()
		end
	end
end
-- Helper function to check if prompt is for a Fight podium
local function isFightPrompt(prompt)
	if not prompt or not prompt.Parent then
		return false
	end
	if prompt.Name == "FightPrompt" then
		return true
	end
	if CollectionService:HasTag(prompt.Parent, "EnemyPodium") then
		return true
	end
	if prompt.ActionText == "Fight" then
		return true
	end
	return false
end

function ProximityPromptController:CreateCustomPrompt(prompt, inputType)
	if not isFightPrompt(prompt) then
		return
	end
	-- Avoid duplicate displays
	if activePrompts[prompt] then
		self:DestroyCustomPrompt(prompt)
	end
	-- Get interactive key string based on input type
	local keyString = "E"
	local isGamepad = inputType == Enum.ProximityPromptInputType.Gamepad
	local isTouch = inputType == Enum.ProximityPromptInputType.Touch
	if isGamepad then
		keyString = GAMEPAD_BUTTON_MAP[prompt.GamepadKeyCode] or prompt.GamepadKeyCode.Name
	elseif isTouch then
		keyString = "TAP"
	else
		local str = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		if str and str ~= "" then
			keyString = string.upper(str)
		else
			keyString = prompt.KeyboardKeyCode.Name
		end
	end
	-- Clone pre-designed BillboardGui from ReplicatedStorage
	local billboardGui = promptTemplate:Clone()
	billboardGui.Name = "CustomProximityPromptGui"
	billboardGui.AlwaysOnTop = true
	billboardGui.ResetOnSpawn = false

	-- Determine attachment point or model part
	local parentPart = prompt.Parent
	if parentPart:IsA("Model") then
		parentPart = parentPart.PrimaryPart or parentPart:FindFirstChildWhichIsA("BasePart", true)
	end

	if not parentPart or not parentPart:IsA("BasePart") then
		billboardGui:Destroy()
		return
	end

	billboardGui.Adornee = parentPart
	billboardGui.Parent = playerGui
	-- Find UI elements inside cloned template
	local mainFrame = billboardGui:FindFirstChild("Frame")
	if not mainFrame then
		warn("[ProximityPrompt] Template Prompt has no child Frame!")
		billboardGui:Destroy()
		return
	end
	local contents = mainFrame:FindFirstChild("Contents")
	local buttonFrame = contents and contents:FindFirstChild("Frame")
	-- local buttonImage = buttonFrame and buttonFrame:FindFirstChild("ButtonImage")
	local buttonText = buttonFrame and buttonFrame:FindFirstChild("ButtonText")

	local textFrame = contents and contents:FindFirstChild("TextFrame")
	local actionTextLabel = textFrame and textFrame:FindFirstChild("ActionText")

	local fillFrame = mainFrame:FindFirstChild("Fill")
	local objectTextLabel = mainFrame:FindFirstChild("ObjectText")
	-- Apply texts
	if actionTextLabel then
		actionTextLabel.Text = prompt.ActionText
	end

	if objectTextLabel then
		objectTextLabel.Text = prompt.ObjectText
	end
	-- Setup Keyboard/Gamepad/Touch buttons in UI
	if buttonText then
		buttonText.Text = keyString
		buttonText.Visible = true
	end
	-- if buttonImage then
	-- 	buttonImage.Visible = false
	-- end
	-- Handle hold fill frame size (initial width = 0)
	if fillFrame then
		fillFrame.Visible = prompt.HoldDuration > 0
		fillFrame.Size = UDim2.fromScale(0, 1)
	end
	-- Record original transparencies for fade-in/out
	local originalTrans = getOriginalTransparencies(billboardGui)
	-- Start initial invisible state for elements to fade them in
	for element, props in pairs(originalTrans) do
		for prop, _ in pairs(props) do
			element[prop] = 1
		end
	end
	-- Original sizes for animation scaling
	local originalGuiSize = billboardGui.Size
	local originalButtonSize = buttonFrame and buttonFrame.Size
	-- Set small size for pop-in pop animation
	billboardGui.Size = UDim2.new(
		originalGuiSize.X.Scale * 0.85,
		originalGuiSize.X.Offset * 0.85,
		originalGuiSize.Y.Scale * 0.85,
		originalGuiSize.Y.Offset * 0.85
	)
	-- 1. Pop & Fade In Animation
	TweenService:Create(billboardGui, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalGuiSize,
	}):Play()
	fadeGui(originalTrans, 0, 0.2)
	-- Handle Hold Progress and Squeezing animations
	local holdStartConn, holdEndConn, triggerConn
	local activeTweens = {}
	if prompt.HoldDuration > 0 then
		holdStartConn = prompt.PromptButtonHoldBegan:Connect(function()
			-- Squish key cap tactile feedback
			if buttonFrame and originalButtonSize then
				local squishTween = TweenService:Create(
					buttonFrame,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(
							originalButtonSize.X.Scale * 0.85,
							originalButtonSize.X.Offset * 0.85,
							originalButtonSize.Y.Scale * 0.85,
							originalButtonSize.Y.Offset * 0.85
						),
					}
				)
				squishTween:Play()
				table.insert(activeTweens, squishTween)
			end
			-- Charge progress Fill size from 0 to 1 as requested!
			if fillFrame then
				local progressTween =
					TweenService:Create(fillFrame, TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear), {
						Size = UDim2.fromScale(1, 1),
					})
				progressTween:Play()
				table.insert(activeTweens, progressTween)
			end
		end)
		holdEndConn = prompt.PromptButtonHoldEnded:Connect(function()
			-- Cancel ongoing hold tweens
			for _, tween in ipairs(activeTweens) do
				tween:Cancel()
			end
			activeTweens = {}
			-- Fast release back to normal
			if buttonFrame and originalButtonSize then
				TweenService
					:Create(buttonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = originalButtonSize,
					})
					:Play()
			end
			if fillFrame then
				TweenService:Create(fillFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(0, 1),
				}):Play()
			end
		end)
	else
		-- Click prompt keycap micro-press
		holdStartConn = prompt.Triggered:Connect(function()
			if buttonFrame and originalButtonSize then
				TweenService
					:Create(buttonFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(
							originalButtonSize.X.Scale * 0.85,
							originalButtonSize.X.Offset * 0.85,
							originalButtonSize.Y.Scale * 0.85,
							originalButtonSize.Y.Offset * 0.85
						),
					})
					:Play()
				task.delay(0.08, function()
					if buttonFrame and buttonFrame.Parent then
						TweenService
							:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Size = originalButtonSize,
							})
							:Play()
					end
				end)
			end
		end)
	end
	-- Handle TextButton clicks/touches to simulate holds
	local btnDownConn, btnUpConn, btnLeaveConn
	local textButton = billboardGui:FindFirstChildWhichIsA("TextButton")
	if textButton then
		local isHolding = false

		local function startHold()
			if not isHolding then
				isHolding = true
				prompt:InputHoldBegin()
			end
		end

		local function endHold()
			if isHolding then
				isHolding = false
				prompt:InputHoldEnd()
			end
		end

		btnDownConn = textButton.MouseButton1Down:Connect(startHold)
		btnUpConn = textButton.MouseButton1Up:Connect(endHold)
		btnLeaveConn = textButton.MouseLeave:Connect(endHold)
	end

	-- Cache tracking details
	activePrompts[prompt] = {
		Gui = billboardGui,
		Transparencies = originalTrans,
		OriginalGuiSize = originalGuiSize,
		ActiveTweens = activeTweens,
		Connections = {
			HoldStart = holdStartConn,
			HoldEnd = holdEndConn,
			Trigger = triggerConn,
			BtnDown = btnDownConn,
			BtnUp = btnUpConn,
			BtnLeave = btnLeaveConn,
		},
	}
end
function ProximityPromptController:DestroyCustomPrompt(prompt)
	local promptCache = activePrompts[prompt]
	if not promptCache then
		return
	end
	activePrompts[prompt] = nil
	
	-- Cancel any ongoing hold or interaction tweens explicitly
	if promptCache.ActiveTweens then
		for _, tween in ipairs(promptCache.ActiveTweens) do
			if tween then
				tween:Cancel()
			end
		end
		promptCache.ActiveTweens = nil
	end

	-- Disconnect events
	for _, connection in pairs(promptCache.Connections) do
		if connection then
			connection:Disconnect()
		end
	end
	-- Fade Out & Shrink UI
	local billboardGui = promptCache.Gui
	if billboardGui and billboardGui.Parent then
		local originalGuiSize = promptCache.OriginalGuiSize
		TweenService:Create(billboardGui, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(
				originalGuiSize.X.Scale * 0.85,
				originalGuiSize.X.Offset * 0.85,
				originalGuiSize.Y.Scale * 0.85,
				originalGuiSize.Y.Offset * 0.85
			),
		}):Play()
		fadeGui(promptCache.Transparencies, 1, 0.15)
		task.delay(0.15, function()
			billboardGui:Destroy()
		end)
	end
end
-- #region Knit Lifecycle
function ProximityPromptController:KnitInit()
	print("ProximityPromptController Initialized")
end
function ProximityPromptController:KnitStart()
	-- Listen for Prompt Events
	ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
		self:CreateCustomPrompt(prompt, inputType)
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		self:DestroyCustomPrompt(prompt)
	end)
	print("[PROXIMITY PROMPT CONTROLLER] Template Prompt Controller successfully started.")
end
-- #endregion Knit Lifecycle
return ProximityPromptController
