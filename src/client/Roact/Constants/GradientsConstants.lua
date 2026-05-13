return table.freeze({
    Rainbow = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)),
    }),
    Golden = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 200, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
    }),
})