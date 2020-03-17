package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

skynet.start(
    function()
        -- REDIS服务器
        local redis_server_id = skynet.uniqueservice(true, "redis_server")
        local ret, err = skynet.call(redis_server_id, "lua", "start", {
            host = "127.0.0.1",
            port = 6379,
            db = 0,
        })
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        skynet.exit()
    end
)
