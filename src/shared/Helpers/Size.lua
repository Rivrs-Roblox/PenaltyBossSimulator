return function(styles, params: table)
    if params == nil or params == {} or params.X == nil or params.Y == nil then
        return styles.sizeAlpha:map(function(alpha) return UDim2.fromScale(alpha*1.1, alpha*1.1) end)
    end

    return styles.sizeAlpha:map(function(alpha) return UDim2.fromScale(alpha*params.X, alpha*params.Y) end)
end