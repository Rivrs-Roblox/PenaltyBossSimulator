local Lighting = game:GetService("Lighting")
local Tween = require(script.Parent.Tween)
local Blur = Lighting:FindFirstChild("BLUR_FOR_UI") or Instance.new("BlurEffect", Lighting)

if Blur.Name ~= "BLUR_FOR_UI" then
	Blur.Name = "BLUR_FOR_UI"
	Blur.Size = 0
end

return function(Size: number, Time: number)
	return Tween(Blur, { Size = Size }, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
end