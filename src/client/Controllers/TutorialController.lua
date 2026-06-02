--[=[
	Owner: Vooldy
	Version: v.0.0.
	Contact owner if any question, concern or feedback
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Modules
local player = Players.LocalPlayer
local UIHighlighter = require(script.Parent.Parent.Modules.UIHighlighter)

-- Controllers
local NotificationController
local FightController

-- Services
local DataService
local CoachesService
local CharactersService
local PetsService
local FightService

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Cache
local TutorialGUI
local TutorialFrame
local TutorialText
local CountText
local SkipButton

-- Variables
local currentTutorialStep = 0
local CurrentTutorialTarget
local tutorialArrowCount = 0
local tutorialArrows = {} --[id::string = {Part::Instance,CurrentOffset::number}]
local trove = Trove.new()
local blockTutorial = false
local isAdvancing = false

local _winsCache = 0
local _allBossBeaten = false

-- Consts
local ARROW_SPAWN_RATE = 0.25 -- in sec
local ARROW_SPEED = 15
local ARROW_TWEEN_TIME = 0.40
local ARROW_LIFETIME = 2.5
local CHECK_REFRESH_TIME = 1 -- in sec, refresh time before a condition check
local IN_FRAME_POS = UDim2.new(0.5, 0, 0.16, 0)
local OUT_FRAME_POS = UDim2.new(0.5, 0, -0.3, 0)

local TUTORIAL_STEPS = {
	[1] = {
		Text = "Click to kick the ball!",
		ArrowTarget = nil,
		Target = 0,
		Condition = function()
			return not FightController.IsFighting
		end,
	},
	[2] = {
		Text = "Gain 120 Power by training!",
		ArrowTarget = function()
			local PowerArea =
				workspace.Area01:WaitForChild("TrainingTargets"):WaitForChild("Target01"):FindFirstChild("Pivot", true)
			return PowerArea
		end,
		Target = 120,
		Condition = function()
			return not FightController.IsFighting
		end,
	},
	[3] = {
		Text = "Buy coach to increase your power gain!",
		ArrowTarget = function()
			local Podium =
				workspace.Area01:WaitForChild("Podiums"):WaitForChild("Coaches"):FindFirstChild("Pivot", true)
			return Podium
		end,
		Target = 0,
	},
	[4] = {
		Text = "Gain 150 Power so you can beat stronger goalie!",
		ArrowTarget = function()
			local PowerArea =
				workspace.Area01:WaitForChild("TrainingTargets"):WaitForChild("Target01"):FindFirstChild("Pivot", true)
			return PowerArea
		end,
		Target = 150,
	},
	[5] = {
		Text = "Gain 50 Wins by defeating the goalies!",
		ArrowTarget = function()
			local PenaltyZone = workspace.Area01
				:FindFirstChild("PenaltyZone")
				:WaitForChild("Enemies")
				:WaitForChild("MiniBoss 1")
				:WaitForChild("Pivot", 10)
			return PenaltyZone
		end,
		Target = 50,
	},
	[6] = {
		Text = "Buy a player to increase your Wins gain!",
		ArrowTarget = function()
			local Podium =
				workspace.Area01:WaitForChild("Podiums"):WaitForChild("Players"):FindFirstChild("Pivot", true)
			return Podium
		end,
		Target = 0,
	},
	[7] = {
		Text = "Hatch your first pet!",
		ArrowTarget = function()
			local Podium = workspace.Eggs:WaitForChild("Area01"):WaitForChild("DefaultEgg").PrimaryPart
			return Podium
		end,
		Target = 0,
	},
	[8] = {
		Text = "Unlock new zone!",
		ArrowTarget = function()
			local Podium = workspace.Area01:WaitForChild("Gate"):WaitForChild("Model"):WaitForChild("Gate")
			return Podium
		end,
		Target = 0,
		Condition = function()
			return _winsCache >= 1_000 and _allBossBeaten
		end,
	},
}

--| Tutorial Controller |--
local TutorialController = Knit.CreateController({
	Name = "TutorialController",
})

function TutorialController:UpdateUIHighlight()
	UIHighlighter.StopAll()

	local playerGui = player:WaitForChild("PlayerGui")
	local gameScreenGui = playerGui:WaitForChild("GameScreenGui")
	local hud = gameScreenGui:WaitForChild("HUD")
	local characterUI = gameScreenGui:WaitForChild("Characters")
	local coachUI = gameScreenGui:WaitForChild("Coaches")

	local charactersButton = hud:WaitForChild("LeftFrame"):WaitForChild("Main"):WaitForChild("Characters")
	local coachesButton = hud:WaitForChild("LeftFrame"):WaitForChild("Main"):WaitForChild("Coaches")

	local scrollCharacter = characterUI:WaitForChild("Content"):WaitForChild("Container"):WaitForChild("ScrollingFrame")
	local scrollCoach = coachUI:WaitForChild("Content"):WaitForChild("Container"):WaitForChild("ScrollingFrame")

	local characterTargetCard = scrollCharacter:FindFirstChild("2")
	local coachTargetCard = scrollCoach:FindFirstChild("4")

	if currentTutorialStep == 3 then
		task.spawn(function()
			while currentTutorialStep == 3 do
				if TutorialGUI then
					TutorialGUI.Enabled = false
				end

				local currentUI = Store:getState().UIReducer.CurrentUI

				if currentUI == nil or currentUI == "" then
					UIHighlighter.Stop(charactersButton)
					UIHighlighter.Stop(coachTargetCard)
					UIHighlighter.Highlight(coachesButton)
				elseif currentUI == "Coach" then
					UIHighlighter.Stop(coachesButton)
					UIHighlighter.Stop(charactersButton)
					UIHighlighter.Highlight(coachTargetCard)
				end

				task.wait(0.1) -- Jeda loop agar tidak terjadi script exhaustion
			end

			UIHighlighter.Stop(coachesButton)
			UIHighlighter.Stop(charactersButton)
			UIHighlighter.Stop(coachTargetCard)
			if TutorialGUI then
				TutorialGUI.Enabled = true
			end
		end)
	elseif currentTutorialStep == 6 then
		task.spawn(function()
			while currentTutorialStep == 6 do
				if TutorialGUI then
					TutorialGUI.Enabled = false
				end

				local currentUI = Store:getState().UIReducer.CurrentUI

				if currentUI == nil or currentUI == "" then
					UIHighlighter.Stop(coachesButton)
					UIHighlighter.Stop(characterTargetCard)
					UIHighlighter.Highlight(charactersButton)
				elseif currentUI == "Characters" then
					local targetCard = characterTargetCard or scrollCharacter:FindFirstChild("2")
					if scrollCharacter and targetCard then
						local relativeY = targetCard.AbsolutePosition.Y
							- scrollCharacter.AbsolutePosition.Y
							+ scrollCharacter.CanvasPosition.Y
						scrollCharacter.CanvasPosition = Vector2.new(0, math.max(0, relativeY - 20))
					end

					UIHighlighter.Stop(coachesButton)
					UIHighlighter.Stop(charactersButton)
					UIHighlighter.Highlight(targetCard)
				end

				task.wait(0.1) -- Jeda loop agar tidak terjadi script exhaustion
			end

			UIHighlighter.Stop(charactersButton)
			UIHighlighter.Stop(coachesButton)
			UIHighlighter.Stop(characterTargetCard)
			if TutorialGUI then
				TutorialGUI.Enabled = true
			end
		end)
	end
end

--| Function |--

-- Skip the current task, the boolean flag disable the success feedback
function TutorialController:_SkipTutorial()
	self:TutorialNextStep(true)
end

-- Create a tutorial frame then cache all useful components
function TutorialController:CreateTutorialFrame(visible: true)
	local PlayerGui = player:WaitForChild("PlayerGui")
	TutorialGUI = Instance.new("ScreenGui")
	TutorialGUI.Parent = PlayerGui
	TutorialGUI.Name = "feedbackGui"
	TutorialGUI.DisplayOrder = 1
	TutorialGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
	TutorialGUI.IgnoreGuiInset = true
	TutorialGUI.ResetOnSpawn = false
	trove:Add(TutorialGUI)

	if FightController and FightController.IsFighting then
		TutorialGUI.Enabled = false
	end

	local GUIFolder = ReplicatedStorage.Assets.GUIs
	TutorialFrame = GUIFolder:FindFirstChild("TutorialFrame")
	if visible then
		TutorialFrame.Position = IN_FRAME_POS
	else
		TutorialFrame.Position = OUT_FRAME_POS
	end
	TutorialFrame.Parent = TutorialGUI

	TutorialText = TutorialFrame:FindFirstChild("TutorialText")
	TutorialText.Text = TUTORIAL_STEPS[currentTutorialStep].Text

	CountText = TutorialFrame:FindFirstChild("CountText")

	if TUTORIAL_STEPS[currentTutorialStep].Target > 0 then
		if currentTutorialStep == 2 or currentTutorialStep == 4 then
			DataService:GetData(player):andThen(function(data)
				local formatedValue = FormatNumber(data.Money2)
				CountText.Text = formatedValue .. "/" .. TUTORIAL_STEPS[currentTutorialStep].Target
			end)
		elseif currentTutorialStep == 5 then
			DataService:GetData(player):andThen(function(data)
				local formatedValue = FormatNumber(data.Wins)
				CountText.Text = formatedValue .. "/" .. TUTORIAL_STEPS[currentTutorialStep].Target
			end)
		else
			CountText.Text = "0/" .. TUTORIAL_STEPS[currentTutorialStep].Target
		end
	else
		CountText.Visible = false
	end

	local ButtonFrame = TutorialFrame:FindFirstChild("ButtonFrame")
	SkipButton = ButtonFrame:FindFirstChild("TextButton")
	SkipButton.Activated:Connect(function()
		self:_SkipTutorial()
	end)
end

-- Continuously spawn tutorial arrows and store them in a library
function TutorialController:CreateTutorialArrows()
	while task.wait(ARROW_SPAWN_RATE) do
		if currentTutorialStep > #TUTORIAL_STEPS then
			break
		end

		if not blockTutorial and CurrentTutorialTarget then
			local MeshFolder = ReplicatedStorage.Assets.Mesh
			local ArrowPart = MeshFolder:FindFirstChild("Arrow"):Clone()
			trove:Add(ArrowPart)

			local arrowId = tostring(tutorialArrowCount)
			tutorialArrowCount += 1

			local humanoidRootPart = player.Character.HumanoidRootPart
			ArrowPart.Parent = humanoidRootPart
			ArrowPart.CFrame = CFrame.new(humanoidRootPart.CFrame.Position)
			-- tween in
			local tween = self:TweenPart(ArrowPart, Vector3.new(0, 0, 0), Vector3.new(4, 0.1, 4))
			trove:Add(tween)
			tween:Play()
			-- store the arrow
			tutorialArrows[arrowId] = {}
			tutorialArrows[arrowId].Part = ArrowPart -- string dictionnary to avoid list increment issue
			tutorialArrows[arrowId].CurrentOffset = 0
			task.delay(ARROW_LIFETIME - ARROW_TWEEN_TIME, function() -- tween out
				local tween = self:TweenPart(ArrowPart, Vector3.new(4, 0.1, 4), Vector3.new(0, 0, 0))
				trove:Add(tween)
				tween:Play()
			end)
			-- self-destruct
			task.delay(ARROW_LIFETIME, function()
				tutorialArrows[arrowId] = nil
				ArrowPart:Destroy()
			end)
		end
	end
end

-- return a tween from StartSize to EndSize
function TutorialController:TweenPart(part: Instance, startSize: Vector3, endSize: Vector3)
	part.Size = startSize
	local tweenGoal = { Size = endSize }
	local tweenInfo = TweenInfo.new(ARROW_TWEEN_TIME, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(part, tweenInfo, tweenGoal)
	return tween
end

-- Clear all existing arrows
function TutorialController:ClearArrows()
	for index, arrowTable in tutorialArrows do
		if arrowTable.Part then
			arrowTable.Part:Destroy()
		end
	end
	table.clear(tutorialArrows)
	tutorialArrowCount = 0
end

-- Update arrow Pos Cframe at renderStep.
function TutorialController:UpdateArrowsPos()
	trove:Add(RunService.RenderStepped:Connect(function(deltaTime)
		if player.Character ~= nil and CurrentTutorialTarget ~= nil then
			local humanoidRootPart = player.Character.HumanoidRootPart -- will later be stepped outside heartbeat

			local playerToTargetDistance = (CurrentTutorialTarget.Position - humanoidRootPart.Position).Magnitude

			if playerToTargetDistance < 15 or FightController.IsFighting then
				blockTutorial = true
			else
				blockTutorial = false
			end

			for index, arrowTable in tutorialArrows do
				arrowTable.CurrentOffset += ARROW_SPEED * deltaTime -- add local offset
				if humanoidRootPart and CurrentTutorialTarget then
					local startCFrame =
						CFrame.new(humanoidRootPart.CFrame.Position, CurrentTutorialTarget.CFrame.Position)
					local LookVector = startCFrame.LookVector
					arrowTable.Part.CFrame = CFrame.new(
						startCFrame.Position + LookVector * arrowTable.CurrentOffset,
						CurrentTutorialTarget.CFrame.Position
					)
					-- Distance check to remove arrow if reached target
					local arrowDistance = (arrowTable.Part.CFrame.Position - humanoidRootPart.CFrame.Position).Magnitude
					local targetDistance = (CurrentTutorialTarget.CFrame.Position - humanoidRootPart.CFrame.Position).Magnitude
					if arrowDistance > targetDistance then
						tutorialArrows[index] = nil
						arrowTable.Part:Destroy()
					end
				elseif humanoidRootPart then -- if no actual target
					arrowTable.Part.CFrame = CFrame.new(Vector3.new(0, 0, 0))
				end
			end
		end
	end))
end

-- Set a new tutorial target for the arrows
function TutorialController:UpdateTutorialTarget()
	if TUTORIAL_STEPS[currentTutorialStep].ArrowTarget == nil then
		CurrentTutorialTarget = nil
		self:ClearArrows()
		return
	end
	local success, warnMessage = pcall(function()
		CurrentTutorialTarget = TUTORIAL_STEPS[currentTutorialStep].ArrowTarget()
	end)
	if not success then
		warn("Tutorial target not found : " .. warnMessage)
		CurrentTutorialTarget = nil
	end

	if CurrentTutorialTarget == nil then
		self:ClearArrows()
	end
end

-- return a tween from start pos to end pos
function TutorialController:TweenFrame(frame: Frame, startPos: UDim2, endPos: UDim2)
	frame.Position = startPos
	local tweenGoal = { Position = endPos }
	local tweenInfo = TweenInfo.new(ARROW_TWEEN_TIME, Enum.EasingStyle.Sine)
	local tween = TweenService:Create(frame, tweenInfo, tweenGoal)
	return tween
end

-- Start a loop to check the next tutorial condition, then tween the frame in if met
function TutorialController:KeepCheckingCondition()
	local success, warnMessage = pcall(function()
		while TUTORIAL_STEPS[currentTutorialStep].Condition() == false do
			task.wait(CHECK_REFRESH_TIME)
		end
	end)
	if not success then
		print("Error while performing tutorial condition check : " .. warnMessage)
	end
	self:TweenFrameIn()
end

-- Tween the frame out, change the text, then check the tutorial condition. Tween back the frame if no condition.
function TutorialController:TweenFrameOut()
	local tween = self:TweenFrame(TutorialFrame, IN_FRAME_POS, OUT_FRAME_POS)
	trove:Add(tween)
	tween:Play()
	tween.Completed:Connect(function()
		TutorialText.Text = TUTORIAL_STEPS[currentTutorialStep].Text

		if TUTORIAL_STEPS[currentTutorialStep].Target == 0 then
			CountText.Visible = false
		else
			if currentTutorialStep == 2 or currentTutorialStep == 4 then
				DataService:GetData(player):andThen(function(data)
					local formatedValue = FormatNumber(data.Money2)
					CountText.Text = formatedValue .. "/" .. TUTORIAL_STEPS[currentTutorialStep].Target
				end)
			elseif currentTutorialStep == 5 then
				DataService:GetData(player):andThen(function(data)
					local formatedValue = FormatNumber(data.Wins)
					CountText.Text = formatedValue .. "/" .. TUTORIAL_STEPS[currentTutorialStep].Target
				end)
			else
				CountText.Text = "0/" .. TUTORIAL_STEPS[currentTutorialStep].Target
			end

			CountText.Visible = true
		end

		if
			TUTORIAL_STEPS[currentTutorialStep].Condition
			and TUTORIAL_STEPS[currentTutorialStep].Condition() == false
		then -- If condition not
			CurrentTutorialTarget = nil
			self:ClearArrows()
			task.defer(function()
				self:KeepCheckingCondition()
			end)
		else -- Else continue
			self:TweenFrameIn()
		end
	end)
end

-- Tween the frame back in visible range.
function TutorialController:TweenFrameIn()
	local tween = self:TweenFrame(TutorialFrame, OUT_FRAME_POS, IN_FRAME_POS)
	self:UpdateTutorialTarget()
	tween:Play()
	isAdvancing = false
end

-- Skip to the next tutorial step, and end it if last step. Feedback Success prompt can be disable by input.
function TutorialController:TutorialNextStep(skipped: boolean)
	if isAdvancing then
		return
	end
	isAdvancing = true

	currentTutorialStep += 1
	DataService:TutorialProgressed(currentTutorialStep)
	if currentTutorialStep == #TUTORIAL_STEPS + 1 then -- If tutorial ended
		if not skipped then
			NotificationController:Notify({
				text = "You finished the tutorial!",
				type = "SUCCESS",
				tag = "Tutorial",
			})
		end
		self:EndTutorial()
		return
	end
	if not skipped then
		NotificationController:Notify({ text = "You completed a tutorial step!", type = "SUCCESS", tag = "Tutorial" })
	end

	if self:CheckAutoSkip() then
		isAdvancing = false
		self:TutorialNextStep(true)
		return
	end

	self:UpdateUIHighlight()
	self:TweenFrameOut()
end

-- Check if we should automatically skip the current step because we already have the item
function TutorialController:CheckAutoSkip()
	if currentTutorialStep == 3 then
		local success, data = DataService:GetData():await()
		if success and data and data.Coaches and table.find(data.Coaches.Unlocked, 4) then
			return true
		end
	elseif currentTutorialStep == 2 or currentTutorialStep == 4 then
		local success, data = DataService:GetData():await()
		if success and data and data.Money2 and data.Money2 >= TUTORIAL_STEPS[currentTutorialStep].Target then
			return true
		end
	elseif currentTutorialStep == 5 then
		local success, data = DataService:GetData():await()
		if success and data and data.Wins and data.Wins >= TUTORIAL_STEPS[currentTutorialStep].Target then
			return true
		end
	elseif currentTutorialStep == 6 then
		local success, data = DataService:GetData():await()
		if success and data and data.Characters and table.find(data.Characters.Unlocked, 2) then
			return true
		end
	elseif currentTutorialStep == 8 then
		local success, data = DataService:GetData():await()
		if success and data and data.Areas and table.find(data.Areas.Unlocked, "Zone2") then
			return true
		end
	end

	return false
end

-- End the tutorial by setting the last step and cleaning everything
function TutorialController:EndTutorial()
	DataService:TutorialFinished(true)
	UIHighlighter.StopAll()
	trove:Destroy()
	self:ClearArrows()
end

--| Knit Startup |--
function TutorialController:KnitInit()
	DataService = Knit.GetService("DataService")
	CoachesService = Knit.GetService("CoachesService")
	CharactersService = Knit.GetService("CharactersService")
	PetsService = Knit.GetService("PetsService")
	FightService = Knit.GetService("FightService")
end

function TutorialController:KnitStart()
	NotificationController = Knit.GetController("NotificationController")
	FightController = Knit.GetController("FightController")

	DataService:GetData(player):andThen(function(data)
		if not data.TutorialComplete then
			currentTutorialStep = data.TutorialStep

			if self:CheckAutoSkip() then
				currentTutorialStep += 1
			end

			if currentTutorialStep == #TUTORIAL_STEPS + 1 then -- If tutorial ended
				self:EndTutorial()
				return
			end

			self:UpdateUIHighlight()
			local success, warnMessage = pcall(function()
				-- Creating, caching and updating arrows
				task.defer(function()
					self:CreateTutorialArrows()
				end)
				self:UpdateArrowsPos()
				if -- IF REQUIRE A CONDITION
					TUTORIAL_STEPS[currentTutorialStep].Condition
					and TUTORIAL_STEPS[currentTutorialStep].Condition() == false
				then
					self:CreateTutorialFrame(false)
					CurrentTutorialTarget = nil
					self:ClearArrows()
					task.defer(function()
						self:KeepCheckingCondition()
					end)
				else -- ELSE NO CONDITION
					self:CreateTutorialFrame(true)
					self:UpdateTutorialTarget()
				end
			end)
			if not success then
				warn("Error while tutorial loading : " .. warnMessage)
			end

			FightController.OnKickSignal:Connect(function()
				if currentTutorialStep == 1 then
					self:TutorialNextStep(false)
				end
			end)

			FightService.FightStarted:Connect(function()
				if TutorialGUI then
					TutorialGUI.Enabled = false
				end
			end)

			FightService.FightEnded:Connect(function()
				if TutorialGUI and currentTutorialStep <= #TUTORIAL_STEPS then
					if currentTutorialStep ~= 3 and currentTutorialStep ~= 6 then
						TutorialGUI.Enabled = true
					end
				end
			end)

			CoachesService.CoachBought:Connect(function(coachId)
				if currentTutorialStep == 3 then
					self:TutorialNextStep(false)
				end
			end)

			-- Check boss progress for Area01 efficiently
			local function checkBosses(bossProgress)
				if bossProgress and bossProgress["Area01"] and bossProgress["Area01"] >= 5 then
					_allBossBeaten = true
				else
					_allBossBeaten = false
				end
			end

			checkBosses(data.BossProgress)

			DataService.BossProgressUpdated:Connect(function(updatedProgress)
				checkBosses(updatedProgress)
			end)

			_winsCache = data.Wins
			DataService.WinsUpdated:Connect(function(wins)
				_winsCache += wins
				if currentTutorialStep == 5 and not isAdvancing then
					local formatedValue = FormatNumber(_winsCache)
					CountText.Text = formatedValue .. "/" .. TUTORIAL_STEPS[currentTutorialStep].Target

					if _winsCache >= TUTORIAL_STEPS[currentTutorialStep].Target then
						self:TutorialNextStep(false)
					end
				end
			end)

			-- Connect Tutorial Signals
			DataService.PowerUpdated:Connect(function(power)
				if (currentTutorialStep == 2 or currentTutorialStep == 4) and not isAdvancing then
					local formatedValue = FormatNumber(power)
					CountText.Text = formatedValue .. "/" .. TUTORIAL_STEPS[currentTutorialStep].Target

					if power >= TUTORIAL_STEPS[currentTutorialStep].Target then
						self:TutorialNextStep(false)
					end
				end
			end)

			CharactersService.CharactersUpdated:Connect(function()
				if currentTutorialStep == 6 then
					self:TutorialNextStep(false)
				end
			end)

			PetsService.PetsUpdated:Connect(function()
				if currentTutorialStep == 7 then
					self:TutorialNextStep(false)
				end
			end)

			DataService.AreasUpdated:Connect(function()
				if currentTutorialStep == 8 then
					self:TutorialNextStep(false)
				end
			end)
		end
	end)
end

return TutorialController
