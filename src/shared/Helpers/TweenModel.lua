local Tween = require(script.Parent.Tween)

return function(Model: Model, NewCFrame: CFrame, ...)
	local Instance = Instance.new("CFrameValue", Model)
	Instance.Value = Model:GetPivot()

	local T = Tween(Instance, { Value = NewCFrame }, ...)

	Instance.Changed:Connect(function(Value) Model:PivotTo(Value) end)
	T.Completed:Once(function() Instance:Destroy() end)
	
	return T
end