--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- ColorableButton
return function(params: table)
    setmetatable(params, { __index = {
        text = "" :: string,
        image = UI.Button,
        position = UDim2.fromScale(0.5, 0.5) :: UDim2,
        size = UDim2.fromScale(1, 1) :: UDim2,
        color = Color3.fromRGB(255, 255, 255) :: Color3,
        action = function() end,
        disabled = false :: boolean,
        visible = true,
        stroke = 0,
        hooks = nil,
        closeOnClick = true,
        order = 0,
    }})

    local styles, api = RoactSpring.useSpring(params.hooks, function()
        return {
            sizeAlpha = 1,
        }
    end)

    return Roact.createElement("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = params.image,
        Position = params.position,
        Size = Size(styles, { X = params.size.X.Scale, Y = params.size.Y.Scale }),
        ImageColor3 = params.color,
        BackgroundTransparency = 1,
        Visible = params.visible,
        ZIndex = 2,
        LayoutOrder = params.order,

        [Roact.Event.MouseButton1Click] = function()
            if params.disabled == false then
                Sound:PlaySound("UI_Click")
                --SoundController:CreateSound(Players.LocalPlayer.Character, "UI_Click")
                params.action()
                if params.closeOnClick then UIController:HideFrame() end
            end
        end,

        [Roact.Event.MouseEnter] = function()
            api.start({ sizeAlpha = 1.1 })
        end,

        [Roact.Event.MouseLeave] = function()
            api.start({ sizeAlpha = 1 })
        end,

        [Roact.Event.MouseButton1Down] = function()
            api.start({ sizeAlpha = 0.8 })
        end,

        [Roact.Event.MouseButton1Up] = function()
            api.start({ sizeAlpha = 1 })
        end

    }, {
        Corner = Corner({ radius = 0.2 }),
        Stroke = Stroke({ thick = params.stroke }),
        BottomText = Text({ text = params.text, position = UDim2.fromScale(0.5, 0.5), size = UDim2.fromScale(0.75, 0.6), color = Color3.fromRGB(255, 255, 255), backgroundTransparency = 1, stroke = 1.5, index = 3 })
    })
end