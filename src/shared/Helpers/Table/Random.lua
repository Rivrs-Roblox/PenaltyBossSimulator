return function(weights)
    local totalWeight = 0
    for _, weight in ipairs(weights) do
        totalWeight = totalWeight + weight.Chance
    end

    local randomValue = math.random() * totalWeight
    for i, weight in ipairs(weights) do
        randomValue = randomValue - weight.Chance
        if randomValue <= 0 then
            return i
        end
    end
end