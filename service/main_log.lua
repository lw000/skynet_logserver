package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
require("common.export")

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

        skynet.exit()
    end
)
