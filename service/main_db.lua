package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local conf = require("config.config")
require("common.export")

skynet.start(
    function()
        -- 1. DB服务器
        local db_server_id = skynet.uniqueservice(true, "db_server")
        local ret, err = skynet.call(db_server_id, "lua", "start", conf.db)
        if err ~= nil then
            skynet.error(ret, err)
            return
        end

        skynet.exit()
    end
)
