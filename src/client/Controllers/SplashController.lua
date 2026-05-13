--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Games Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local Tween = require(ReplicatedStorage.Shared.Helpers.Tween)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TroveSplash = Trove.new()

-- Constants
local VALID_INPUTS = {
	Enum.UserInputType.Touch,
	Enum.UserInputType.MouseButton1,
	Enum.KeyCode.ButtonR2,
}

local SplashColor = Color3.fromRGB(255, 255, 255)


-- SplashController
local SplashController = Knit.CreateController({
	Name = "SplashController",

	CanSplash = true,
})

--|| Functions ||--
function SplashController:Splash(pos)
	for _ = 1, math.random(3, 5) do
		task.spawn(function()
			local popup = Instance.new("Frame", Players.LocalPlayer.PlayerGui.GameScreenGui)
			local size = math.random(5, 8)

			popup.Size = UDim2.fromOffset(size, size)
			popup.BackgroundColor3 = SplashColor

			local parentFrame = UDim2.fromOffset(pos.X, pos.Y)
			local parentFramePos = parentFrame.Y

			popup.Position = UDim2.fromOffset(parentFrame.X.Offset, parentFramePos.Offset + 50)

			local corner = Instance.new("UICorner", popup)
			corner.CornerRadius = UDim.new(1, 0)

			Tween(popup, {
				["Position"] = popup.Position - UDim2.fromOffset(math.random(-50, 50), math.random(-50, 50)),
			}, 0.5)
			task.wait(0.2)
			Tween(popup, { ["BackgroundTransparency"] = 1 }, 0.4).Completed:Once(function()
				popup:Destroy()
			end)
		end)
	end
end


function SplashController:SplashWithColor(pos, color)
	for _ = 1, math.random(12, 24) do
		task.spawn(function()
			local popup = Instance.new("Frame", Players.LocalPlayer.PlayerGui.GameScreenGui)
			local size = math.random(6, 12)

			popup.Size = UDim2.fromOffset(size, size)
			popup.BackgroundColor3 = color

			local parentFrame = UDim2.fromOffset(pos.X, pos.Y)
			local parentFramePos = parentFrame.Y

			popup.Position = UDim2.fromOffset(parentFrame.X.Offset, parentFramePos.Offset + 50)

			local corner = Instance.new("UICorner", popup)
			corner.CornerRadius = UDim.new(1, 0)

			Tween(popup, {
				["Position"] = popup.Position - UDim2.fromOffset(math.random(-50, 50), math.random(-50, 50)),
			}, 0.5)
			task.wait(0.2)
			Tween(popup, { ["BackgroundTransparency"] = 1 }, 0.4).Completed:Once(function()
				popup:Destroy()
			end)
		end)
	end
end

function SplashController:SplashMoneyObtained(pos, color) 
	for _ = 1, math.random(6, 17) do
		task.spawn(function()
			local popup = Instance.new("Frame", Players.LocalPlayer.PlayerGui.GameScreenGui)
			local size = math.random(4, 10)

			popup.Size = UDim2.fromOffset(size, size)
			popup.BackgroundColor3 = color
			popup.ZIndex = 1
			popup.BackgroundTransparency = 0.2

			popup.Position = pos

			local corner = Instance.new("UICorner", popup)
			corner.CornerRadius = UDim.new(1, 0)

			Tween(popup, {
				["Position"] = popup.Position - UDim2.fromScale(math.random(-50, 50)*0.08/50, math.random(-100, 100)*0.08/50),
			}, 0.5)
			Tween(popup, { ["BackgroundTransparency"] = 0.5 }, 0.4)
			task.wait(0.5)
			Tween(popup, {["BackgroundColor3"] = Color3.fromRGB(6, 34, 115), ["BackgroundTransparency"] = 1, ["Position"] = popup.Position + UDim2.fromScale(0, 0.03)}, 0.4).Completed:Once(function()
				popup:Destroy()
			end)
		end)
	end
end

function SplashController:SplashClicks()
	TroveSplash:Clean()
	TroveSplash:Add(UserInputService.InputBegan:Connect(function(Input: InputObject)
		if not self.CanSplash then
			return
		end
		if
			(table.find(VALID_INPUTS, Input.UserInputType) or table.find(VALID_INPUTS, Input.KeyCode))
			and Players.LocalPlayer.PlayerGui:FindFirstChild("GameScreenGui") ~= nil
		then
			self:Splash(Input.Position)
		end
	end))
end

function SplashController:ChangeColor(color: Color3)
	SplashColor = color
end

--|| Knit Lifecycle ||--
function SplashController:KnitInit()
	print("[SPLASH CONTROLLER] Controller loaded successfully.")
end

return SplashController
