package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/log_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local logmgr = require("log_manager")
require("skynet.manager")
require("config.config")

local command = {
    server_type = SERVICE.TYPE.LOG, -- 服务类型
    server_name = "",               -- 服务名称
    running = false,	            -- 服务器状态
}

function command.START()
    math.randomseed(os.time())
    
    command.running = true

    logmgr.start(SERVICE.NAME.LOG)

    local errmsg = SERVICE.NAME.LOG .. "->start"
    return 0, errmsg
end

function command.STOP()
    command.running = false
    logmgr.stop()

    local errmsg = SERVICE.NAME.LOG .. "->stop"
    return 0, errmsg
end

-- LOG消息處理接口
function command.MESSAGE(mid, sid, content)
    skynet.error(string.format(SERVICE.NAME.LOG .. ":> mid=%d sid=%d", mid, sid))

    if mid ~= LOG_CMD.MDM_LOG then
        local errmsg = "unknown " .. SERVICE.NAME.LOG .. " message command"
		skynet.error(errmsg)
		return 1, errmsg
    end
    
    return logmgr.dispatch(mid, sid, content)
end

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            local f = command[cmd]
            assert(f)
            if f then
                skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format(SERVICE.NAME.LOG .. " unknown command %s", tostring(cmd)))
            end     
        end
    )
    skynet.register(SERVICE.NAME.LOG)
end

skynet.start(dispatch)
