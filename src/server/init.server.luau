local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

require(ReplicatedStorage.Packages.Sound)
require(ReplicatedStorage.Packages.VFX)

-- Services
for _, file in pairs(script.Services:GetChildren()) do
	local startTime = os.clock()
	require(file)
	local elapsed = os.clock() - startTime
	print(string.format("[Services Loader] %-40s loaded in %.3fs", file.Name, elapsed))
end

Knit.Start()
	:andThen(function()
		print("[SERVER] Server started successfully")
	end)
	:catch(warn)
	:await()
