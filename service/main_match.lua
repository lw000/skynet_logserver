package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

skynet.start(
    function()    
        -- 匹配服务器
        local match_server_id = skynet.newservice("match_server")
        local ret, err = skynet.call(match_server_id, "lua", "start", {
            server_id = 1,
            server_name = string.format("%s[%d]", "匹配服务器", 1),
        })
        if err ~= nil then
            skynet.error(ret, err)
            return
        end

        skynet.exit()
    end
)
