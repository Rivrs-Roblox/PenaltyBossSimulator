--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local items = {}

for _, itemFile in pairs(script:GetDescendants()) do
    local itemsFile = require(itemFile)
    for key, value in pairs(itemsFile) do
        items[key] = value
    end
end

return items