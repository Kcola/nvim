P = function(...)
    print(vim.inspect(...))
    return ...
end

JSON_PARSE = function(filename)
    return vim.fn.json_decode(vim.fn.readfile(filename))
end

NOOP = function()
    return {}
end

function string:split(sep)
    local fields = {}

    local _sep = sep or " "
    local pattern = string.format("([^%s]+)", _sep)
    string.gsub(self, pattern, function(c)
        fields[#fields + 1] = c
    end)

    return fields
end
