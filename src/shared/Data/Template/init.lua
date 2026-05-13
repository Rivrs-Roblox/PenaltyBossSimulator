--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local templates = {}

for _, templateFile in pairs(script:GetChildren()) do
    local template = require(templateFile)
    local tmp = {}

    for key, value in pairs(template) do
        tmp[key] = value
    end

    templates[string.gsub(templateFile.Name, ".lua", "")] = tmp
end

return templates