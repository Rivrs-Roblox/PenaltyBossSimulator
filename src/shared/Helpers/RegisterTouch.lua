local Players = game:GetService("Players")

return function(BasePart: BasePart)
	local Touched = Instance.new("BindableEvent")

	BasePart.Touched:Connect(function(Hit: BasePart)
		local Player = Players:GetPlayerFromCharacter(Hit.Parent)
		if Player ~= Players.LocalPlayer then
			return
		end

		for _, element in Hit.Parent:GetDescendants() do
			if Hit.Name == element.Name then
				Touched:Fire(true)
				break
			end
		end
	end)

	BasePart.TouchEnded:Connect(function(Hit: BasePart)
		local Player = Players:GetPlayerFromCharacter(Hit.Parent)
		if Player ~= Players.LocalPlayer then
			return
		end

		for _, element in Hit.Parent:GetDescendants() do
			if Hit.Name == element.Name then
				Touched:Fire(false)
				break
			end
		end
	end)
    
	return Touched.Event
end