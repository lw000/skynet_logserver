package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/log_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local loghelper = require("log_helper")
require("skynet.manager")
require("config.config")

local command = {
    server_id = SERVICE_TYPE.LOG, -- 服务ID
    methods = {}, -- 业务处理接口映射表
    running = false,	-- 服务器状态
}

function command.START()
    command.running = true
    command.registerMethods()

    local errmsg = "logserver start"
    return 0, errmsg
end

function command.STOP()
    command.running = false
    command.methods = {}

    local errmsg = "logserver stop"
    return 0, errmsg
end

function command.registerMethods()
    command.methods[0x0001] = {func = loghelper.saveMatchServerInfo, desc="同步匹配服务器数据"}
    command.methods[0x0002] = {func = loghelper.saveRoomServerOnlineCount, desc="更新房间在线用户数"}
    command.methods[0x0003] = {func = loghelper.writeGameLog, desc="写游戏记录"}
    command.methods[0x0004] = {func = loghelper.writeScoreChangeLog, desc="写玩家金币变化"}
    -- dump(command.methods, "redis_server.command.methods")
end


-- 写数据到REDIS
function command.MESSAGE(mid, sid, content)
	skynet.error(string.format("log_server mid=%d, sid=%d", mid, sid))

	if mid ~= 0x0006 then
		skynet.error("unknow log_server message command")
		return -1
	end

    -- 查询业务处理函数
    local method = command.methods[sid]
    assert(method ~= nil)
    if method then
        local ret, err = method.func(command.redisConn, content)
        if err ~= nil then
            skynet.error(err)
            return 1
        end
    end
	return 0
end

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            if cmd == "START" then
                local f = command[cmd]
                assert(f)
                skynet.ret(skynet.pack(f(...)))
            elseif cmd == "STOP" then
                local f = command[cmd]
                assert(f)
                skynet.ret(skynet.pack(f(...)))
            elseif cmd == "MESSAGE" then
                local f = command[cmd]
                assert(f)
				skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format("unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".log_server")
end

skynet.start(dispatch)
