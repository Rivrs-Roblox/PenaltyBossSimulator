local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local PetAssets = Assets:WaitForChild("Pets")

return function(Data: { [any]: any })
	local PetName = Data.Name
	local PetModel = PetAssets:FindFirstChild(PetName, true)
	if PetModel == nil then
		warn("Can't find pet model:", PetName)
		return
	end
	for i, v in PetModel:GetDescendants() do
		pcall(function()
			v.CanCollide = false
			v.CanQuery = false
		end)
	end
	return PetModel
end