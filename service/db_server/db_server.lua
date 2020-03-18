package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/db_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local database = require("database.database")
local dbhelper = require("db_helper")
require("skynet.manager")
require("common.export")
require("config.config")

--[[
    db数据库服务
]]

local command = {
    server_type = SERVICE.TYPE.DB,  -- 服务ID
    running = false,                -- 服务器状态
    dbconn = nil,                   -- db连接
    conf = nil,                     -- 数据库配置
    methods = nil                   -- 业务处理接口映射表
}

-- 服务启动·接口
--[[
    返回值：code, err
    code=0成功，非零失败
    err 错误消息
]]

function command.START(conf)
    assert(conf ~= nil)
    -- dump(conf, "conf")
    command.conf = conf
    command.dbconn = database.open(command.conf)
    assert(command.dbconn ~= nil)
    if command.dbconn == nil then
        return 1, SERVICE.NAME.DB .. "->fail"
    end

    math.randomseed(os.time())

    command.running = true

    command.registerMethods()

    local errmsg = SERVICE.NAME.DB .. "->start"
    return 0, errmsg
end

-- 服务停止·接口
function command.STOP()
    command.running = false
    command.methods = nil
    database.close(command.dbconn)
    command.dbconn = nil

    local errmsg = SERVICE.NAME.DB .. "->stop"
    return 0, errmsg
end

-- 注册业务处理接口
function command.registerMethods()
    if command.methods == nil then
		command.methods = {}
    end
    command.methods[DB_CMD.SUB_UPDATE_MATCH_SERVER_INFOS] = {func = dbhelper.syncMatchServerInfo, desc="同步匹配服务器数据"}
    command.methods[DB_CMD.SUB_UPDATE_ROOM_SERVER_INFOS] = {func = dbhelper.syncRoomServerOnlineCount, desc="更新房间在线用户数"}
    command.methods[DB_CMD.SUB_GAME_LOG] = {func = dbhelper.writeGameLog, desc="写游戏记录"}
    command.methods[DB_CMD.SUB_GAME_SCORE_CHANGE_LOG] = {func = dbhelper.writeScoreChangeLog, desc="写玩家金币变化"}
    dump(command.methods, SERVICE.NAME.DB .. ".command.methods")
end

-- DB消息處理接口
function command.MESSAGE(mid, sid, content)
    skynet.error(string.format(SERVICE.NAME.DB .. ":> mid=%d sid=%d", mid, sid))

    if mid ~= DB_CMD.MDM_DB then
        skynet.error("unknown " .. SERVICE.NAME.DB .. " message command")
    end

    -- 查询业务处理函数
    local method = command.methods[sid]   
    assert(method ~= nil)
    if method then
        local ret, err = method.func(command.dbconn, content)
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
                skynet.error(string.format("db_server unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(SERVICE.NAME.DB)
end

skynet.start(dispatch)
