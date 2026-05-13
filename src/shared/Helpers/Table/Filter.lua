return function (t : { [any] : any }, predicate : (x : any) -> boolean )
    local filtered = {}
    for _, value in t do
        if predicate(value) then
            table.insert(filtered, value)
        end
    end
    return filtered
end