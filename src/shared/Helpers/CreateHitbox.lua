return function(Model: Model, Offset: Vector3?): Part
	if not Offset then
		Offset = Vector3.zero
	end
	local Hitbox = Instance.new("Part")
	Hitbox.Size = (Model:IsA("Model") and Model:GetExtentsSize() + Offset) or Model.Size + Offset
	Hitbox.Anchored = true
	Hitbox.CanCollide = false
	Hitbox.Transparency = 1
	Hitbox.CFrame = (Model:IsA("Model") and (Model:GetPivot() + Vector3.new(0, Offset.Y / 2, 0)))
		or Model.CFrame + Vector3.new(0, Offset.Y / 2, 0)
	Hitbox.Parent = Model
	Hitbox.Name = "Hitbox"
	return Hitbox
end