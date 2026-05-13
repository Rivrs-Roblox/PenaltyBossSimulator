local Tween = require(script.Parent.Tween)
local Camera = workspace.CurrentCamera

return function (FieldOfView : number, Time : number)
    return Tween(Camera, { FieldOfView = FieldOfView }, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
end