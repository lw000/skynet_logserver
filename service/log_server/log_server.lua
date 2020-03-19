package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/log_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local datacenter = require("skynet.datacenter")
local logmgr = require("log_manager")
require("skynet.manager")
require("core.define")

local command = {
    servertype = SERVICE.TYPE.LOG,  -- 服务类型
    servername = SERVICE.NAME.LOG,  -- 服务名
    server_name = "",               -- 服务名称
    running = false,	            -- 服务器状态
}

function command.START()
    math.randomseed(os.time())
    
    command.running = true

    logmgr.start(command.servername)
    
    -- dump(datacenter.get("debug"), "debug")
    -- dump(datacenter.get("release"), "release")
    -- dump(datacenter.get("config"), "config")
    return 0
end

function command.STOP()
    command.running = false
    logmgr.stop()
    return 0
end

-- LOG服务·消息处理接口
function command.MESSAGE(mid, sid, content)
    -- skynet.error(string.format(command.servername .. ":> mid=%d sid=%d", mid, sid))

    if mid ~= LOG_CMD.MDM_LOG then
        local errmsg = "unknown " .. command.servername .. " message command"
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
                skynet.error(string.format(command.servername .. " unknown command %s", tostring(cmd)))
            end     
        end
    )
    skynet.register(command.servername)
end

skynet.start(dispatch)
