package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

local function test (name)
    local v = 0
    while (v < 100) do
        skynet.error(name, v)
        v = v + 1
        if v % 10 == 0 then
            skynet.yield()
        end
    end
end

skynet.start(
    function()
        -- 0. DEBUG服务
        skynet.newservice("debug_console", "8000")
         
        -- log服务
        local log_server_id = skynet.uniqueservice(true, "log_server")
        local ret, err = skynet.call(log_server_id, "lua", "start")
        if ret ~= 0 then
            skynet.error(ret, err)
            return
        end
        skynet.error(ret, err)

        -- repeat
        --     skynet.error("repeat until - 1")
        --     break
        --     skynet.error("repeat until - 2")
        -- until 0

        skynet.fork(test, "test1")
        skynet.fork(test, "test2")

        -- skynet.exit()
    end
)
