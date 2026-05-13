--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local passes = {}

for _, passesFile in pairs(script:GetDescendants()) do
    local pass = require(passesFile)

    for key, value in pairs(pass) do
        passes[key] = value
    end
end

return passes