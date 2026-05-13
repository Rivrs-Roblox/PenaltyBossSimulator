-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Constants
local SeasonConstants = require(StarterPlayerScripts.Client.Roact.Constants.SeasonConstants)

-- Store
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)

function Top(_, hooks)
    local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Position=UDim2.fromScale(0.71,0),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffffff'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.4,0.16),
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            VerticalAlignment=0,
            SortOrder=2,
            HorizontalAlignment=0,
            Padding=UDim.new(0.08,0),
            FillDirection=0,
        }),
        Rewards = Roact.createElement("ImageButton", {
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.734,-0.039),
            BorderColor3=Color3.fromHex('000000'),
            Size=UDim2.fromScale(0.25,1),
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ff3826'),
            [Roact.Event.MouseButton1Click] = function()
                Sound:PlaySound("UI_Open")
                Store:dispatch(UIActions.setCurrentSeasonPassUI(SeasonConstants.Rewards))
            end,

            [Roact.Event.MouseEnter] = function()
                api.start({ sizeAlpha = 1.1, config = { duration = 0.2 } })
            end,

            [Roact.Event.MouseLeave] = function()
                api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
            end,

            [Roact.Event.MouseButton1Down] = function()
                api.start({ sizeAlpha = 0.8, config = { duration = 0.2 } })
            end,

            [Roact.Event.MouseButton1Up] = function()
                api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
            end,
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.2,0),
            }),
            Label = Roact.createElement("TextLabel", {
                TextWrapped=true,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="REWARDS",
                Size=UDim2.fromScale(1.2,0.32),
                TextSize=14,
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,1),
                TextScaled=true,
                ZIndex=2,
                BorderSizePixel=0,
                BackgroundColor3=Color3.fromHex('ffffff'),
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Thickness=2,
                }),
            }),
            Stroke = Roact.createElement("UIStroke", {
                Thickness=3,
            }),
            Icon = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://128197558541858",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.5),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.9,0.9),
            }),
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('950000'))}),
                Rotation=90,
            }),
        }),
        Quests = Roact.createElement("ImageButton", {
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.734,-0.039),
            BorderColor3=Color3.fromHex('000000'),
            Size=UDim2.fromScale(0.25,1),
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ff3826'),
            [Roact.Event.MouseButton1Click] = function()
                Sound:PlaySound("UI_Open")
                Store:dispatch(UIActions.setCurrentSeasonPassUI(SeasonConstants.Quests))
            end,

            [Roact.Event.MouseEnter] = function()
                api.start({ sizeAlpha = 1.1, config = { duration = 0.2 } })
            end,

            [Roact.Event.MouseLeave] = function()
                api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
            end,

            [Roact.Event.MouseButton1Down] = function()
                api.start({ sizeAlpha = 0.8, config = { duration = 0.2 } })
            end,

            [Roact.Event.MouseButton1Up] = function()
                api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
            end,
        }, {
            Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.2,0),
        }),
        Label = Roact.createElement("TextLabel", {
            TextWrapped=true,
            TextColor3=Color3.fromHex('ffffff'),
            BorderColor3=Color3.fromHex('000000'),
            Text="QUESTS",
            Size=UDim2.fromScale(1.2,0.32),
            TextSize=14,
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,1),
            TextScaled=true,
            ZIndex=2,
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ffffff'),
        }, {
            Stroke = Roact.createElement("UIStroke", {
                Thickness=2,
            }),
        }),
        Stroke = Roact.createElement("UIStroke", {
            Thickness=3,
        }),
        Icon = Roact.createElement("ImageLabel", {
            ScaleType=3,
            BorderColor3=Color3.fromHex('000000'),
            AnchorPoint=Vector2.new(0.5,0.5),
            Image="rbxassetid://105197352660451",
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffffff'),
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.9,0.9),
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('950000'))}),
            Rotation=90,
        }),
    }),
    Premium = Roact.createElement("ImageButton", {
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.734,-0.039),
        BorderColor3=Color3.fromHex('000000'),
        Size=UDim2.fromScale(0.25,1),
        BorderSizePixel=0,
        BackgroundColor3=Color3.fromHex('ff3826'),
        [Roact.Event.MouseButton1Click] = function()
            Sound:PlaySound("UI_Open")
            Store:dispatch(UIActions.setCurrentSeasonPassUI(SeasonConstants.PremiumRewards))
        end,

        [Roact.Event.MouseEnter] = function()
            api.start({ sizeAlpha = 1.1, config = { duration = 0.2 } })
        end,

        [Roact.Event.MouseLeave] = function()
            api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
        end,

        [Roact.Event.MouseButton1Down] = function()
            api.start({ sizeAlpha = 0.8, config = { duration = 0.2 } })
        end,

        [Roact.Event.MouseButton1Up] = function()
            api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
        end,
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.2,0),
        }),
        Label = Roact.createElement("TextLabel", {
            TextWrapped=true,
            TextColor3=Color3.fromHex('ffffff'),
            BorderColor3=Color3.fromHex('000000'),
            Text="PREMIUM",
            Size=UDim2.fromScale(1.2,0.32),
            TextSize=14,
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,1),
            TextScaled=true,
            ZIndex=2,
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ffffff'),
        }, {
            Stroke = Roact.createElement("UIStroke", {
                Thickness=2,
            }),
        }),
        Stroke = Roact.createElement("UIStroke", {
            Thickness=3,
        }),
        Icon = Roact.createElement("ImageLabel", {
            ScaleType=3,
            BorderColor3=Color3.fromHex('000000'),
            AnchorPoint=Vector2.new(0.5,0.5),
            Image="rbxassetid://81846085332138",
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffffff'),
            BorderSizePixel=0,
            Size=UDim2.fromScale(1.1,1.2),
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('950000'))}),
            Rotation=90,
        }),
    }),
    })
end

Top = RoactHooks.new(Roact)(Top)
return Top