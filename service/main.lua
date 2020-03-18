package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

skynet.start(
    function()
        -- 0. DEBUG服务
        skynet.newservice("debug_console", "8000")
        
        -- 1. DB服务器
        local db_server_id = skynet.newservice("db_server")
        local ret, err = skynet.call(db_server_id, "lua", "start", {
            host = "127.0.0.1",
            host_ = "192.168.0.102",
            port = 3306,
            database = "test",
            user = "root",
            password = "LEvi123!",
            password_ = "lwstar",
        })
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        -- 2. REDIS服务器
        local redis_server_id = skynet.newservice("redis_server")
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

        -- 3. 匹配服务器
        local matching_server_id = skynet.newservice("match_server")
        local ret, err = skynet.call(matching_server_id, "lua", "start", {
            server_id = 1,
            server_name = string.format("%s[%d]", "匹配服务器", 1),
        })
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        -- 4. 房间服务器
        local room_server_id = skynet.newservice("room_server")
        local ret, err = skynet.call(room_server_id, "lua", "start", {
            room_id = 10000,
            room_name = string.format("%s[%d]", "房间服务器", 10000),
        })
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        -- 5. 主服务
        local log_server_id = skynet.newservice("log_server")
        local ret, err = skynet.call(log_server_id, "lua", "start")
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        skynet.exit()
    end
)
