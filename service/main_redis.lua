package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local conf = require("config.config")
require("common.export")

skynet.start(
    function()
        -- REDIS服务器
        local redis_server_id = skynet.uniqueservice(true, "redis_server")
        local ret, err = skynet.call(redis_server_id, "lua", "start", conf.redis)
        if err ~= nil then
            skynet.error(ret, err)
            return
        end
        skynet.exit()
    end
)
