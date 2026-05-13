return function(Instance: Instance, Player: Player)
	local function setOwner(part: BasePart)
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part:SetAttribute("Owner", Player.UserId)
		end
	end

	if Instance:IsA("Model") then
		for _, part in Instance:GetDescendants() do
			setOwner(part)
		end
	else
		setOwner(Instance)
	end
end