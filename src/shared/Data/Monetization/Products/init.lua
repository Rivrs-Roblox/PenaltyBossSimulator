--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

local products = {}

for _, productsFile in pairs(script:GetDescendants()) do
    local product = require(productsFile)

    for key, value in pairs(product) do
        products[key] = value
    end
end

return products