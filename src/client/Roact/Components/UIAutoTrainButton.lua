--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local NormalOutline = require(script.Parent.NormalOutline)
local TutorialOutline = require(script.Parent.TutorialOutline)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

-- Components
local Image = require(script.Parent.Image)
local Text = require(script.Parent.Text)

function UIAutoTrainButton(params: table, hooks)
    setmetatable(params, {
        __index = {
            background = "",
            icon = "",
            text = "",
            pos = UDim2.fromScale(0.5, 0.5),
            size = UDim2.fromScale(1, 1),
            order = 1,
            onClick = function() end,
            visible = true,
            hover = true,
            aspectRatio = 1,
            animate = false,
            OutlineVisible = false,
            TutorialOutlineVisible = false
        },
    })

    local isDebounced, setIsDebounced = hooks.useState(false)
    local springApiState, setSpringApiState = hooks.useState(nil)
    
    -- Initialize spring
    local styles, api = RoactSpring.useSpring(hooks, function()
        return {
            sizeAlpha = 1,
            rotation = 0,
            rotation2 = 0,
            transparency = 0,
        }
    end)

    -- Store the api reference when it's created
    hooks.useEffect(function()
        if not springApiState then
            setSpringApiState(api)
        end

        return function()
            if springApiState then
                springApiState.stop()
            end
        end
    end, {})

    -- Consolidated animation function
    local function animate(props)
        if springApiState then
            springApiState.start(props)
        end
    end

    local function handleClick()
        if isDebounced then return end
        
        setIsDebounced(true)
        animate({
            transparency = 0.5,
            config = { tension = 300, friction = 20 }
        })
        
        params.onClick()
        
        task.delay(0.7, function()
            setIsDebounced(false)
            animate({
                transparency = 0,
                config = { tension = 300, friction = 20 }
            })
        end)
    end

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = params.pos,
        Size = params.size,
        LayoutOrder = params.order,
        Visible = params.visible,
    }, {
        Button = Roact.createElement("ImageButton", {
            Image = params.background,
            BackgroundTransparency = 1,
            ImageTransparency = styles.transparency,
            Position = params.pos,
            Size = Size(styles, { X = 1, Y = 1 }),
            LayoutOrder = params.order,
            Visible = params.visible,
            [Roact.Event.MouseButton1Click] = handleClick,

            [Roact.Event.MouseEnter] = function()
                if not isDebounced then
                    animate({
                        sizeAlpha = 1.05,
                        rotation2 = 35,
                        config = { mass = 1, tension = 1000, friction = 50 }
                    })
                end
            end,

            [Roact.Event.MouseLeave] = function()
                animate({
                    sizeAlpha = 1,
                    rotation2 = 0,
                    config = { mass = 1, tension = 1000, friction = 50 }
                })
            end,

            [Roact.Event.MouseButton1Down] = function()
                if not isDebounced then
                    animate({ sizeAlpha = 0.95 })
                end
            end,

            [Roact.Event.MouseButton1Up] = function()
                animate({ sizeAlpha = 1 })
            end,
        }, {
            UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = params.aspectRatio or 1,
            }),

            Icon = Image({
                image = params.icon,
                position = UDim2.fromScale(0.5, 0.5),
                size = UDim2.fromScale(0.75, 0.75),
                backgroundTransparency = 1,
                rotation = if params.animate == true then styles.rotation else styles.rotation2,
                children = {
                    UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1,
                    }),
                },
            }),

            Text = Text({
                text = params.text,
                position = UDim2.fromScale(0.5, 0.925),
                size = UDim2.fromScale(0.985, 0.278),
                color = Color3.fromRGB(250, 250, 250),
                stroke = 1.5,
                index = 5,
            }),

            NormalOutline = NormalOutline({
                visible = params.OutlineVisible,
                color = Color3.fromRGB(101, 215, 56),
                strokeThickness = 3,
                pulseSpeed = 1.3,
                pulseSize = 1.03,
                hooks = hooks,
            }),

            TutorialOutline = TutorialOutline({
                visible = params.TutorialOutlineVisible,
                color = Color3.fromRGB(255, 148, 55),
                strokeThickness = 3,
                pulseSpeed = 1.3,
                pulseSize = 1.3,
                hooks = hooks,
            }),
        }),
    })
end

UIAutoTrainButton = RoactHooks.new(Roact)(UIAutoTrainButton)
return UIAutoTrainButton