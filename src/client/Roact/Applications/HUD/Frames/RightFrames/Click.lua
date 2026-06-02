--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local Image = require(Components.Image)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

local TrainingController = Knit.GetController("TrainingController")

-- Signals
local TrainingSignals = require(ReplicatedStorage.Shared.Signals.TrainingSignals)

-- Click
function Click(_, hooks)
	-- State untuk mengontrol visibilitas
	local isVisible, setVisible = hooks.useState(false)
	local isMobile = UserInputService.TouchEnabled
	local clickIcon = if isMobile then UI.Taps_Click else UI.Blue_Click
	local clickText = if isMobile then "Tap!" else "Click!"

	-- Animasi menggunakan RoactSpring untuk efek membesar & mengecil
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			size = UDim2.fromScale(1.2, 1.2), -- Ukuran default
			config = { tension = 1000, friction = 30, speed = 100 }, -- Percepat animasi
		}
	end)

	-- Gunakan useEffect untuk mendengarkan event
	hooks.useEffect(function()
		-- Event listener untuk menampilkan frame
		local function onTrainingStarted()
			if TrainingController.IsTraining then
				setVisible(true)
			end
			
		end

		-- Event listener untuk menyembunyikan frame
		local function onTrainingStopped()
			setVisible(false)
		end

		-- Sambungkan event
		local startConnection = TrainingSignals.TrainingStarted:Connect(onTrainingStarted)
		local stopConnection = TrainingSignals.TrainingStopped:Connect(onTrainingStopped)

		-- Cleanup ketika komponen dihapus
		return function()
			startConnection:Disconnect()
			stopConnection:Disconnect()
		end
	end, {}) -- Dependency kosong berarti hanya dieksekusi sekali

	-- Fungsi untuk menjalankan animasi klik
	local function onClick()
		api.start({ size = UDim2.fromScale(1.5, 1.5) }) -- Membesar cepat
		task.wait(0.05) -- Percepat durasi animasi
		api.start({ size = UDim2.fromScale(1.2, 1.2) }) -- Kembali ke ukuran normal
	end

	-- Listener untuk menangani input di PC (Mouse), Mobile (Touch), dan Console (Gamepad)
	hooks.useEffect(function()
		local function handleInput(input, gameProcessedEvent)
			if gameProcessedEvent then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				onClick() -- Klik Mouse
			elseif input.UserInputType == Enum.UserInputType.Touch then
				onClick() -- Sentuhan Mobile
			elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
				onClick()
			end
		end

		local inputConnection = UserInputService.InputBegan:Connect(handleInput)

		return function()
			inputConnection:Disconnect()
			ContextActionService:UnbindAction("ClickAction")
		end
	end, {})

	-- Komponen utama
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.2, 0.8),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		LayoutOrder = 4,
		Visible = isVisible, -- State visibilitas dikontrol oleh event
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.5,
		}),

		Icon = Image({
			image = clickIcon,
			position = UDim2.fromScale(0.5, 0.25),
			size = styles.size, -- Gunakan animasi untuk ukuran
			backgroundTransparency = 1,
			children = {
				UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
				}),
			},
		}),

		Title = Text({
			text = clickText,
			position = UDim2.fromScale(0.5, 1),
			size = UDim2.fromScale(0.35, 0.35),
			stroke = 1.5,
			color = Color3.fromRGB(255, 255, 255),
		}),
	})
end

Click = RoactHooks.new(Roact)(Click)
return Click
