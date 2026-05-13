local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

local DamageIndicator = {}
DamageIndicator.__index = DamageIndicator

local SIZE = UDim2.fromOffset(40, 40)

-- Pool lokal (reusable)
local _pool = {}
local _active = {}

-- Membuat atau mengambil instance dari pool
local function getFromPool(gui)
	if #_pool > 0 then
		local label = table.remove(_pool)
		label.Parent = gui
		label.Visible = true
		return label
	end

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Ubuntu
	label.FontFace.Style = Enum.FontStyle.Italic
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0
	-- label.TextScaled = true
	label.TextSize = 24
	label.Size = SIZE
	label.ZIndex = 10
	label.Visible = true
	label.Parent = gui
	return label
end

-- Mengembalikan label ke pool
local function returnToPool(label)
	label.Visible = false
	label.Parent = nil
	label.TextTransparency = 0
	label.Size = SIZE
	table.insert(_pool, label)
end

function DamageIndicator.new()
	local self = setmetatable({}, DamageIndicator)
	return self
end

function DamageIndicator:Create(text: string, position: Vector2, gui: ScreenGui, color: Color3)
	local label = getFromPool(gui)

	label.Text = text

	label.TextColor3 = color or Color3.fromRGB(255, 160, 0)
	label.Position = UDim2.fromOffset(position.X, position.Y)
	label.TextTransparency = 0

	-- Efek kecil saat muncul
	label.Size = UDim2.fromOffset(0, 0)
	label:TweenSize(SIZE, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)

	task.spawn(function()
		task.wait(0.2)

		-- Tween ke atas dan memudar
		local upTween = TweenService:Create(label, tweenInfo, {
			Position = UDim2.fromOffset(position.X, position.Y - 50),
			TextTransparency = 1,
		})
		upTween:Play()
		upTween.Completed:Wait()

		-- Setelah animasi selesai, kembalikan ke pool
		returnToPool(label)
	end)
end

return DamageIndicator
