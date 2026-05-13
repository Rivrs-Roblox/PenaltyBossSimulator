local SingleEmitter = {}
SingleEmitter.__index = SingleEmitter

function SingleEmitter.new(instance, part)
	local self = setmetatable({}, SingleEmitter)
	self.instance = instance:Clone()
	self.part = part
	self.isEnabled = false
	self.attachments = {}

	if self.instance:IsA("ParticleEmitter") then
		local attachmentCFrame = self.instance:GetAttribute("Attachment")
		if attachmentCFrame then
			local attachment = Instance.new("Attachment")
			attachment.CFrame = attachmentCFrame
			self.attachments[1] = attachment
		end
	elseif self.instance:IsA("Beam") then
		local attachment0CFrame = self.instance:GetAttribute("Attachment0")
		local attachment1CFrame = self.instance:GetAttribute("Attachment1")

		if attachment0CFrame and attachment1CFrame then
			local attachment0 = Instance.new("Attachment")
			local attachment1 = Instance.new("Attachment")
			attachment0.CFrame = attachment0CFrame
			attachment1.CFrame = attachment1CFrame
			self.attachments[1] = attachment0
			self.attachments[2] = attachment1
		end
	end

	return self
end

function SingleEmitter:emit(count: number?)
	if self.instance:IsA("ParticleEmitter") then
		self.instance:Emit(count or 50)
	end
end

function SingleEmitter:play()
	if not self.isEnabled then
		if self.instance:IsA("ParticleEmitter") then
			if #self.attachments == 1 then
				self.attachments[1].Parent = self.part
				self.instance.Parent = self.attachments[1]
			else
				self.instance.Parent = self.part
			end
		elseif self.instance:IsA("Beam") then
			if #self.attachments == 2 then
				self.attachments[1].Parent = self.part
				self.attachments[2].Parent = self.part
				self.instance.Attachment0 = self.attachments[1]
				self.instance.Attachment1 = self.attachments[2]
				self.instance.Parent = self.part
			end
		end
		
		self.instance.Enabled = true
		self.isEnabled = true
	end
end

function SingleEmitter:stop()
	if self.isEnabled then
		self.instance.Enabled = false
		self.isEnabled = false
	end
end

function SingleEmitter:destroy()
	self:stop()
	for _, attachment in ipairs(self.attachments) do
		attachment:Destroy()
	end
	self.instance:Destroy()
end

return SingleEmitter
