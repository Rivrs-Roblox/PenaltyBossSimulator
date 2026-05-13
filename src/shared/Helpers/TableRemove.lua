return function(t: {}, key)
    local element = t[key]
    t[key] = nil
    return element
end