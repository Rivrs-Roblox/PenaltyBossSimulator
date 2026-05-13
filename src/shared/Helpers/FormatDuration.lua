return function(sec: number)
    local hours = math.floor(sec / 3600)
    local minutes = math.floor((sec % 3600) / 60)
    local remainingSeconds = sec % 60
    
    return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
end