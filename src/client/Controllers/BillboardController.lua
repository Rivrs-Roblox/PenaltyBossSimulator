--[=[
    Owner: JustStop__
	Version: v0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Constants
local BILLBOARD_TAG = "ActiveBillboard"
local ROTATE_INTERVAL = 3 -- seconds between image changes
local POSTER_IMAGES = {
	"rbxassetid://120070795379706",
	"rbxassetid://79026603230312",
	"rbxassetid://113277432114850",
}

-- BillboardController
local BillboardController = Knit.CreateController({
	Name = "BillboardController",
})

--|| Knit Lifecycle ||--
function BillboardController:KnitStart()
	-- Cache: model → ImageLabel reference, built once per model on tag.
	-- The hot loop only touches this table — zero FindFirstChild per tick.
	local posterCache: { [Model]: ImageLabel } = {}

	local function register(model: Model)
		local poster = model:FindFirstChild("Poster")
		local surfaceGui = poster and poster:FindFirstChild("SurfaceGui")
		local image = surfaceGui and surfaceGui:FindFirstChild("PosterImage")
		if image then
			posterCache[model] = image :: ImageLabel
		end
	end

	local function unregister(model: Model)
		posterCache[model] = nil
	end

	-- Cache all models already tagged on startup
	for _, model in CollectionService:GetTagged(BILLBOARD_TAG) do
		register(model)
	end

	-- Keep cache in sync as models get tagged / untagged / streamed out
	CollectionService:GetInstanceAddedSignal(BILLBOARD_TAG):Connect(register)
	CollectionService:GetInstanceRemovedSignal(BILLBOARD_TAG):Connect(unregister)

	-- Rotation loop: only iterates direct ImageLabel references — no lookup overhead
	local currentIndex = 1
	task.spawn(function()
		while true do
			local image = POSTER_IMAGES[currentIndex]
			for _, label in posterCache do
				label.Image = image
			end
			currentIndex = (currentIndex % #POSTER_IMAGES) + 1
			task.wait(ROTATE_INTERVAL)
		end
	end)

	print("[BILLBOARD CONTROLLER] Controller loaded successfully.")
end

return BillboardController
