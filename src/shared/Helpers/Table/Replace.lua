local function Replace(data, template : { [any] : any })
    for k, v in template do
        data[k] = v
    end
end

return Replace