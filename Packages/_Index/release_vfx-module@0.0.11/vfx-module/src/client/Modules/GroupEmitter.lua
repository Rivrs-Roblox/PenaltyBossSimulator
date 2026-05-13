local SingleEmitter = require(script.Parent.SingleEmitter)
local GroupEmitter = {}
GroupEmitter.__index = GroupEmitter

function GroupEmitter.new(vfxFolder, part)
	local self = setmetatable({}, GroupEmitter)
	self.emitters = {}
	self.part = part

	local function processFolder(folder)
		for _, item in ipairs(folder:GetChildren()) do
			if item:IsA("ParticleEmitter") or item:IsA("Beam") then
				table.insert(self.emitters, SingleEmitter.new(item, part))
			elseif item:IsA("Folder") then
				processFolder(item)
			end
		end
	end

	processFolder(vfxFolder)
	return self
end

function GroupEmitter:emit(counts: { number } | number?)
	for i, emitter in ipairs(self.emitters) do
		if type(counts) == "table" then
			emitter:emit(counts[i] or 50)
		else
			emitter:emit(counts or 50)
		end
	end
end

function GroupEmitter:play()
	for _, emitter in ipairs(self.emitters) do
		emitter:play()
	end
end

function GroupEmitter:stop()
	for _, emitter in ipairs(self.emitters) do
		emitter:stop()
	end
end

function GroupEmitter:destroy()
	for _, emitter in ipairs(self.emitters) do
		emitter:destroy()
	end
	self.emitters = {}
end

return GroupEmitter
