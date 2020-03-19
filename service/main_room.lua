package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

skynet.start(
    function()
        -- 4. 房间服务器
        local room_server_id = skynet.newservice("room_server")
        local ret, err = skynet.call(room_server_id, "lua", "start", {
            room_id = 10000,
            room_name = string.format("%s[%d]", "房间服务器", 10000),
        })
        if err ~= nil then
            skynet.error(ret, err)
            return
        end
        
        skynet.exit()
    end
)
