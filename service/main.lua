package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

skynet.start(
    function()
        skynet.newservice("debug_console", "8000")
        
        -- 1. DB服务器
        local db_server_id = skynet.newservice("db_server")
        local ret, err = skynet.call(db_server_id, "lua", "start", {
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
        local matching_server_id = skynet.newservice("matching_server")
        local ret, err = skynet.call(matching_server_id, "lua", "start", {})
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        -- 4. 房间服务器
        for roomId = 10000, 10000 do
            local room_server_id = skynet.newservice("room_server")
            local ret, err = skynet.call(room_server_id, "lua", "start", {
                room_id = roomId,
                room_name = string.format("%s[%d]", "炸金花房间", roomId),
            })
            if ret ~= 0 then
                skynet.error(ret, err)
                return
            end
            skynet.error(ret, err)
        end

        -- 5. 主服务
        local ws_server_id = skynet.newservice("ws_server")
        local ret, err = skynet.call(ws_server_id, "lua", "start", 8080)
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        -- for i = 0, 0 do
        --     skynet.sleep(10)
        --     local client_id = skynet.newservice("ws_client")
        --     skynet.send(client_id, "lua", "start", "ws", "127.0.0.1:8080")
        -- end

        skynet.exit()
    end
)
