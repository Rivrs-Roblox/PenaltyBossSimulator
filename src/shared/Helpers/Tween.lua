local TweenService = game:GetService("TweenService")

return function(inst : Instance, properties : { [any] : any }, ... : any)
    local tween = TweenService:Create(inst, TweenInfo.new(...), properties)
    tween:Play();
    return tween
end