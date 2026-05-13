--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = nil

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local SetInterval = require(Helpers.SetInterval)
local RegisterTouch = require(Helpers.RegisterTouch)

-- Controllers
local UIController = nil

-- TagsController
local TagsController = Knit.CreateController({
    Name = "TagsController",
    Index = 0,
})

--|| Functions ||--
function TagsController:Hide()
    local hidden = CollectionService:GetTagged("Hide")
    for _, hide in hidden do hide.Transparency = 1 end
end

function TagsController:Egg()
    task.delay(2, function()
        local Eggs = CollectionService:GetTagged("Egg")
        SetInterval(function()
            for _, Egg in Eggs do
                -- Egg.CFrame = Egg.CFrame * CFrame.Angles(0, math.rad(1), 0)
                -- Make egg move up and down with a sin wave
                local Divisor = 100
                local Time = 2
                Egg.CFrame = Egg.CFrame * CFrame.new(0, math.sin(os.clock() * Time) / Divisor, 0)
            end
        end, 1 / 60)
    end)
end

function TagsController:Detection()
    local Detections = CollectionService:GetTagged("Detection")

	for _, Detection in Detections do
		if string.find(Detection.Name, "Frame") then
			local Frame = string.split(Detection.Name, " ")[1]
			RegisterTouch(Detection):Connect(function(State: boolean)
				if State and not UIController:IsCurrentFrame(Frame) then
					UIController:ShowFrame({ frame = Frame })
				elseif not State and UIController:IsCurrentFrame(Frame) then
					UIController:HideFrame()
				end
			end)
		end
	end
end

function TagsController:Look()
    RunService:BindToRenderStep("Looks", Enum.RenderPriority.Last.Value, function()
        local Looks = CollectionService:GetTagged("Look")

        for _, Look in Looks do
            if Players.LocalPlayer:DistanceFromCharacter(Look.CFrame.Position) < 100 then
                Look.CFrame = CFrame.lookAt(Look.CFrame.Position, Players.LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(-270), 0)
            end
        end
    end)
end

function TagsController:NoPhysics()
    local noCollisions = CollectionService:GetTagged("NoPhysics")

    for _, obj in ipairs(noCollisions) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanQuery = false
            obj.CanTouch = false
        end
    end
end

--|| Knit Lifecycle ||--
function TagsController:KnitInit()
    UIController = Knit.GetController("UIController")
    TeleportService = Knit.GetService("TeleportService")

    TeleportService.AreaUpdated:Connect(function(area)
        
        if area == "Battle" then
			return
		end

        task.delay(0.5, function()
            self:Hide()
            self:Egg()
            self:Detection()
            self:Look()
            self:NoPhysics()
        end)
    end)

    print("[TAGS CONTROLLER] Controller loaded successfully.")
end

return TagsController