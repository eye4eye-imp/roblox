
local input_service = game:GetService("LogService")
local c_meta = getrawmetatable(game) or debug.getmetatable(game)
if c_meta and setreadonly then
    setreadonly(c_meta, false)
    local old_namecall = c_meta.__namecall
    c_meta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "HttpGet" or method == "httpGet" then
            local url = args[1]
            local success, response = pcall(function()
                return request({Url = url, Method = "GET"}).Body
            end)
            if success and response then
                return response
            end
        end
        return old_namecall(self, ...)
    end)

    setreadonly(c_meta, true)
end
if typeof(game.HttpGet) == "function" then
    local old_http = game.HttpGet
    game.HttpGet = function(self, url, ...)
        local success, response = pcall(function()
            return request({Url = url, Method = "GET"}).Body
        end)
        if success and response then return response end
        return old_http(self, url, ...)
    end
end
