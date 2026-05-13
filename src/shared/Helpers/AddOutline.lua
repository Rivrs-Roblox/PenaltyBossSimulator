return function(Inst: Instance)
	local Highlight = Instance.new("Highlight", Inst)
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded

    Highlight.FillColor = Color3.fromRGB(0, 0, 0)
	Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)

	Highlight.OutlineTransparency = 0.75
    Highlight.FillTransparency = 1
end