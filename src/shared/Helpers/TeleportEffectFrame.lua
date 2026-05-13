local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

return function(_Params)
	local TweenGUI = Players.LocalPlayer.PlayerGui:WaitForChild("Transition")
	local Image = TweenGUI:WaitForChild("Image")
	local BlackScreen = TweenGUI:WaitForChild("BlackScreen")
	local GoalSize = nil
	local StartSize = nil
	local IsBlackScreen = nil

	if _Params == "Open" then
		StartSize = UDim2.fromScale(1, 1)
		GoalSize = UDim2.fromScale(30, 30)
		IsBlackScreen = false
	elseif _Params == "Close" then
		StartSize = UDim2.fromScale(30, 30)
		GoalSize = UDim2.fromScale(1, 1)
		IsBlackScreen = true
	else
		return
	end

	if Image then
		Image.Size = StartSize
		Image.Visible = true
		BlackScreen.Visible = false

		local TweenFrame =
			TweenService:Create(Image, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = GoalSize,
			})

		TweenFrame:Play()

		TweenFrame.Completed:Wait()

		Image.Visible = false

		if IsBlackScreen then
			BlackScreen.Visible = true
		end
	end
end
