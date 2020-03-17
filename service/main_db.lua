package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

skynet.start(
    function()
        -- 1. DB服务器
        local db_server_id = skynet.uniqueservice(true, "db_server")
        local ret, err = skynet.call(db_server_id, "lua", "start", {
            host_ = "127.0.0.1",
            host = "192.168.0.102",
            port = 3306,
            database = "test",
            user = "root",
            password_ = "LEvi123!",
            password = "lwstar",
        })
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        skynet.exit()
    end
)
