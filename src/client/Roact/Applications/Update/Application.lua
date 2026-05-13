--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Update
function Update(_, hooks)
    local UpdateReducer = RoduxHooks.useSelector(hooks, function(state) return state.UpdateReducer end)

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = UpdateReducer.Updating
    }, {
        UpdateText = Text({ text = "Update incoming, you will be teleported to a new place!", color = Color3.fromRGB(255, 255, 255), backgroundTransparency = 1, position = UDim2.fromScale(0.5, 0.4), size = UDim2.fromScale(0.7, 0.17), stroke = 2 }),
        Timer = Text({ text = `{UpdateReducer.Timer}`, color = Color3.fromRGB(255, 255, 255), backgroundTransparency = 1, position = UDim2.fromScale(0.5, 0.55), size = UDim2.fromScale(0.8, 0.1), stroke = 2 }),
    })
end

Update = RoactHooks.new(Roact)(Update)
return Update