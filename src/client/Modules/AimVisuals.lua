local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Trove = require(ReplicatedStorage.Packages.Trove)

local AimVisuals = {}
AimVisuals.__index = AimVisuals

function AimVisuals.new()
	local self = setmetatable({}, AimVisuals)
	self._trove = Trove.new()
	self._penaltyArrowModel = nil
	self._aimTarget = nil -- EndPoint part
	self._startPoint = nil -- StartPoint part
	self._goalPos = Vector3.new(0, 0, 0)
	self._rightDir = Vector3.new(1, 0, 0)
	self._character = nil
	return self
end

function AimVisuals:Show(goalPos: Vector3, character: Model)
	self:Cleanup()

	self._goalPos = goalPos
	self._character = character

	-- Calculate RightVector for target movement along goal line
	local charPos = character and character.PrimaryPart and character.PrimaryPart.Position or Vector3.new(0, 0, 0)
	local forwardDir = (goalPos - charPos).Unit
	local rightDir = forwardDir:Cross(Vector3.new(0, 1, 0)).Unit
	self._rightDir = rightDir

	-- Clone PenaltyArrow template
	local MeshFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Mesh")
	local PenaltyArrowTemplate = MeshFolder:FindFirstChild("PenaltyArrow")
	if not PenaltyArrowTemplate then
		warn("AimVisuals: PenaltyArrow template not found in Assets/Mesh!")
		return
	end

	local arrowModel = PenaltyArrowTemplate:Clone()
	arrowModel.Name = "AimPenaltyArrow"
	
	-- Anchor points and make them non-collidable
	local startPoint = arrowModel:FindFirstChild("StartPoint")
	local endPoint = arrowModel:FindFirstChild("EndPoint")
	
	if startPoint then
		startPoint.Anchored = true
		startPoint.CanCollide = false
		self._startPoint = startPoint
	end
	if endPoint then
		endPoint.Anchored = true
		endPoint.CanCollide = false
		self._aimTarget = endPoint
	end

	arrowModel.Parent = workspace
	self._penaltyArrowModel = self._trove:Add(arrowModel)

	-- Set initial positions
	local feetPos = charPos - Vector3.new(0, 1.0, 0)
	if self._startPoint then
		self._startPoint.Position = feetPos
	end
	if self._aimTarget then
		self._aimTarget.Position = goalPos
	end
end

function AimVisuals:Update(pointerPosition: number, dt: number)
	local activeChar = self._character or Players.LocalPlayer.Character
	if activeChar and activeChar.PrimaryPart then
		-- Update StartPoint to always follow the player's feet dynamically
		local feetPos = activeChar.PrimaryPart.Position - Vector3.new(0, 1.0, 0)
		if self._startPoint then
			self._startPoint.Position = feetPos
		end
	end

	-- Update EndPoint Position along the goal line
	if self._aimTarget then
		local targetPos = self._goalPos + self._rightDir * (pointerPosition - 0.5) * 50
		self._aimTarget.Position = targetPos
	end
end

function AimVisuals:Lock()
	-- Flash target part green to indicate aim lock
	if self._aimTarget then
		self._aimTarget.Color = Color3.fromRGB(0, 255, 0)
		
		-- Turn the BillboardGui's Target image label green
		local billboard = self._aimTarget:FindFirstChildOfClass("BillboardGui")
		local billboardTarget = billboard and billboard:FindFirstChild("Target")
		if billboardTarget and billboardTarget:IsA("ImageLabel") then
			billboardTarget.ImageColor3 = Color3.fromRGB(0, 255, 0)
		end
	end

	-- Flash the Beam green too
	if self._penaltyArrowModel then
		local beam = self._penaltyArrowModel:FindFirstChildOfClass("Beam")
		if beam then
			beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
		end
	end
end

function AimVisuals:Cleanup()
	self._trove:Clean()
	self._penaltyArrowModel = nil
	self._aimTarget = nil
	self._startPoint = nil
end

return AimVisuals
