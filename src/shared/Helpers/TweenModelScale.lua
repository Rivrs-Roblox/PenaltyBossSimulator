local Tween = require(script.Parent.Tween)

return function(Model: Model, NewScale: number, ...: any)
	local Instance = Instance.new("NumberValue", Model)
    Instance.Value = Model:GetScale()
	local T = Tween(Instance, { Value = NewScale }, ...)
	T.Completed:Once(function()
		Instance:Destroy()
	end)
	Instance.Changed:Connect(function(Value: number)
		Model:ScaleTo(Value)
	end)
	return T
end