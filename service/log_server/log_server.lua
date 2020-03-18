package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/log_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local loghelper = require("log_helper")
require("skynet.manager")
require("config.config")

local command = {
    server_type = SERVICE.TYPE.LOG, -- 服务类型
    server_name = "",               -- 服务名称
    running = false,	            -- 服务器状态
    methods = nil,                  -- 业务处理接口映射表
}

function command.START()
    math.randomseed(os.time())
    
    command.running = true
    command.registerMethods()

    local errmsg = SERVICE.NAME.LOG .. "->start"
    return 0, errmsg
end

function command.STOP()
    command.running = false
    command.methods = nil

    local errmsg = SERVICE.NAME.LOG .. "->stop"
    return 0, errmsg
end

function command.registerMethods()
    if command.methods == nil then
		command.methods = {}
    end

    command.methods[LOG_CMD.SUB_UPDATE_MATCH_SERVER_INFOS]  = {func = loghelper.saveMatchServerInfo, desc="更新匹配服务器数据"}
    command.methods[LOG_CMD.SUB_UPDATE_ROOM_SERVER_INFOS]   = {func = loghelper.saveRoomServerInfo, desc="更新房间服务器数据"}
    command.methods[LOG_CMD.SUB_GAME_LOG]                   = {func = loghelper.writeGameLog, desc="写游戏记录"}
    command.methods[LOG_CMD.SUB_GAME_SCORE_CHANGE_LOG]      = {func = loghelper.writeScoreChangeLog, desc="写玩家金币变化记录"}
    dump(command.methods, SERVICE.NAME.LOG .. ".command.methods")
end

-- LOG消息處理接口
function command.MESSAGE(mid, sid, content)
    skynet.error(string.format(SERVICE.NAME.LOG .. ":> mid=%d sid=%d", mid, sid))

	if mid ~= LOG_CMD.MDM_LOG then
		skynet.error("unknown " .. SERVICE.NAME.LOG .. " message command")
		return -1
	end
    
    -- 查询业务处理函数
    local method = command.methods[sid]
    assert(method ~= nil)
    if method then
        local ret, err = method.func(content)
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
    skynet.register(SERVICE.NAME.LOG)
end

skynet.start(dispatch)
