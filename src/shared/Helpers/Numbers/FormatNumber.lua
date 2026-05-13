local Abbreviate = require(script.Parent.Abbreviate)
local MinNumber = Abbreviate:stringToNumber("-1k")
local MaxNumber = Abbreviate:stringToNumber("1k")

return function(Value)
    Value = math.round(Value * 1000) / 1000
    
    local R
    if Value >= MaxNumber or Value <= MinNumber then
        R = Abbreviate:numberToString(Value)
    else
        R = Abbreviate:commify(Value)
    end
    return R
end