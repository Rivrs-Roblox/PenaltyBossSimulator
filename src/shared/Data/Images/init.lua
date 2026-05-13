--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local images = {}

for _, imageFile in pairs(script:GetDescendants()) do
    local imagesFile = require(imageFile)
    for key, value in pairs(imagesFile) do
        images[key] = value
    end
end

return images