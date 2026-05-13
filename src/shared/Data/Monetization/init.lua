--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local monetization = {}

for _, categoryFile in pairs(script:GetChildren()) do
	print(categoryFile)
    local category = require(categoryFile)
    monetization[string.gsub(categoryFile.Name, ".lua", "")] = category
end

return monetization