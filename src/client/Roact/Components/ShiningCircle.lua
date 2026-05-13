--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

function ShiningCircle(props, hooks)
    local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
			rotate = 0,
		}
	end)

    -- api.start({
	-- 	from = { rotate = 0 },
	-- 	to = { rotate = 180 },
	-- 	loop = { delay = 0, reset = false },
	-- 	config = { duration = 5 },
	-- })

    return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.fromScale(alpha --[[* 0.38]], alpha) --* 0.9)
		end),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://16287180760",
			Size = UDim2.fromScale(1.75, 1.75),
			BackgroundTransparency = 1,
			Rotation = styles.rotate:map(function(rotate)
				return rotate
			end),
		}),
    })
end

ShiningCircle = RoactHooks.new(Roact)(ShiningCircle)

return ShiningCircle