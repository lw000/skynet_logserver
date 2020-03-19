package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local datacenter = require("skynet.datacenter")
local conf = require("config.config")
require("common.export")

skynet.start(
    function()
        -- 0. DEBUG服务
        skynet.newservice("debug_console", conf.debugPort)
        
         -- 1. LOG服务
        local log_server = skynet.newservice("log_server")
        local ret, err = skynet.call(log_server, "lua", "start")
        if err ~= nil then
            skynet.error(ret, err)
            return
        end

        -- 2. DB服务器
        local db_server = skynet.newservice("db_server")
        local ret, err = skynet.call(db_server, "lua", "start", conf.db)
        if err ~= nil then
            skynet.error(ret, err)
            return
        end

        -- 3. REDIS服务器
        local redis_server = skynet.newservice("redis_server")
        local ret, err = skynet.call(redis_server, "lua", "start", conf.redis)
        if err ~= nil then
            skynet.error(ret, err)
            return
        end

        -- 4. 匹配服务器
        local matching_server = skynet.newservice("match_server")
        local ret, err = skynet.call(matching_server, "lua", "start", {
            server_id = 1,
            server_name = string.format("%s[%d]", "匹配服务器", 1),
        })
        if err ~= nil then
            skynet.error(ret, err)
            return
        end
        -- 5. 房间服务器
        local room_server = skynet.newservice("room_server")
        local ret, err = skynet.call(room_server, "lua", "start", {
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
