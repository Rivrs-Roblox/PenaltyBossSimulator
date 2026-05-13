local RagdollModule = {}
RagdollModule.__index = RagdollModule

local RAGDOLL_JOINTS = {
	{ "UpperTorso", "LowerTorso", "Waist" },
	{ "UpperTorso", "RightUpperArm", "RightShoulder" },
	{ "UpperTorso", "LeftUpperArm", "LeftShoulder" },
	{ "LowerTorso", "RightUpperLeg", "RightHip" },
	{ "LowerTorso", "LeftUpperLeg", "LeftHip" },
	{ "RightUpperArm", "RightLowerArm", "RightElbow" },
	{ "LeftUpperArm", "LeftLowerArm", "LeftElbow" },
	{ "RightUpperLeg", "RightLowerLeg", "RightKnee" },
	{ "LeftUpperLeg", "LeftLowerLeg", "LeftKnee" },
}

local jointProperties = {}

function RagdollModule.new(character)
	local self = setmetatable({}, RagdollModule)
	self.character = character
	self.constraints = {}
	return self
end

function RagdollModule:disableMovement()
	local humanoid = self.character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
end

function RagdollModule:enableMovement()
	local humanoid = self.character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

function RagdollModule:setupRagdollPhysics()
	for _, jointInfo in ipairs(RAGDOLL_JOINTS) do
		local part0 = self.character:FindFirstChild(jointInfo[1])
		local part1 = self.character:FindFirstChild(jointInfo[2])

		if part0 and part1 then
			-- Store original joint CFrame for restoration
			local motor = part1:FindFirstChild(jointInfo[3])
			if motor and motor:IsA("Motor6D") then
				jointProperties[motor] = {
					C0 = motor.C0,
					C1 = motor.C1,
					Parent = motor.Parent,
					Enabled = motor.Enabled,
				}
				motor.Enabled = false
			end

			-- Create BallSocketConstraint
			local ballSocket = Instance.new("BallSocketConstraint")
			ballSocket.Name = jointInfo[3] .. "_Ragdoll"
			table.insert(self.constraints, ballSocket)

			-- Create Attachment points
			local attachment0 = Instance.new("Attachment")
			local attachment1 = Instance.new("Attachment")

			attachment0.Name = jointInfo[3] .. "_Att0"
			attachment1.Name = jointInfo[3] .. "_Att1"

			-- Match the original joint's CFrame
			if motor then
				attachment0.CFrame = motor.C0
				attachment1.CFrame = motor.C1
			end

			attachment0.Parent = part0
			attachment1.Parent = part1

			-- Configure BallSocketConstraint
			ballSocket.Attachment0 = attachment0
			ballSocket.Attachment1 = attachment1
			ballSocket.LimitsEnabled = true
			ballSocket.TwistLimitsEnabled = true
			ballSocket.UpperAngle = 90
			ballSocket.TwistUpperAngle = 90
			ballSocket.TwistLowerAngle = -90

			ballSocket.Parent = part0

			-- Make parts collidable
			part0.CanCollide = true
			part1.CanCollide = true
		end
	end
end

function RagdollModule:removeRagdollPhysics()
	-- Remove all constraints and attachments
	for _, constraint in ipairs(self.constraints) do
		if constraint and constraint.Parent then
			local att0 = constraint.Attachment0
			local att1 = constraint.Attachment1

			if att0 then
				att0:Destroy()
			end
			if att1 then
				att1:Destroy()
			end
			constraint:Destroy()
		end
	end
	self.constraints = {}

	-- Re-enable original Motor6D joints
	for _, jointInfo in ipairs(RAGDOLL_JOINTS) do
		local part1 = self.character:FindFirstChild(jointInfo[2])
		if part1 then
			local motor = part1:FindFirstChild(jointInfo[3])
			if motor and motor:IsA("Motor6D") then
				-- Restore original properties
				local props = jointProperties[motor]
				if props then
					motor.C0 = props.C0
					motor.C1 = props.C1
					motor.Parent = props.Parent
					motor.Enabled = true
				end
			end
		end
	end

	table.clear(jointProperties)
end

function RagdollModule:enableRagdoll()
	self:disableMovement()
	self:setupRagdollPhysics()
end

function RagdollModule:disableRagdoll()
	self:removeRagdollPhysics()
	self:enableMovement()
end

return RagdollModule
