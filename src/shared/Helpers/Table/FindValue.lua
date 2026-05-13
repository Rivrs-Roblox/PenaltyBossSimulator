return function(table: table, value: any)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end

    return nil
end