package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local dns = require("skynet.dns")
local datacenter = require("skynet.datacenter")
local conf = require("config.config")
require("common.export")

-- local resolve_list = {
-- 	"github.com",
-- 	"stackoverflow.com",
--     "lua.com",
--     "www.baidu.com",
-- }

skynet.start(
    function()
        -- datacenter.set("debug", 1)
        -- datacenter.set("release", 0)
        -- datacenter.set("config", {
        --     debug = 1,
        --     release = 0,
        -- })

        -- for _ , name in ipairs(resolve_list) do
        --     local ip, ips = dns.resolve(name)
        --     for k,v in ipairs(ips) do
        --         print(name,v)
        --     end
        --     skynet.sleep(500)	-- sleep 5 sec
        -- end

        -- 0. DEBUG服务
        skynet.newservice("debug_console", conf.debug_port)
        
         -- 1. LOG服务
         local log_server = skynet.newservice("log_server")
         local ret, err = skynet.call(log_server, "lua", "start")
         if err ~= nil then
             skynet.error(ret, err)
             return
         end
         skynet.error("log_server", ret)

        -- 2. DB服务器
        local db_server = skynet.newservice("db_server")
        local ret, err = skynet.call(db_server, "lua", "start", conf.db)
        if err ~= nil then
            skynet.error(ret, err)
            return
        end
        skynet.error("db_server", ret)

        -- 3. REDIS服务器
        local redis_server = skynet.newservice("redis_server")
        local ret, err = skynet.call(redis_server, "lua", "start", conf.redis)
        if err ~= nil then
            skynet.error(ret, err)
            return
        end
        skynet.error("redis_server", ret)

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
        skynet.error("match_server", ret)

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
        skynet.error("room_server", ret)

        skynet.exit()
    end
)
