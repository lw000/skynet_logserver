package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/db_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local database = require("database.database")
local dbhelper = require("db_helper")
local cjson = require("cjson")
require("skynet.manager")
require("common.export")
require("config.config")

--[[
    db数据库服务
]]

local command = {
    server_type = SERVICE_TYPE.DB,  -- 服务ID
    running = false,                -- 服务器状态
    dbconn = nil,                   -- db连接
    conf = {},                      -- 数据库配置
    methods = {}                    -- 业务处理接口映射表
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
    command.methods = {}
    command.conf = conf
    command.dbconn = database.open(command.conf)
    assert(command.dbconn ~= nil)
    if command.dbconn == nil then
        return -1, "dbserver start fail"
    end

    math.randomseed(os.time())

    command.running = true

    command.registerMethods()

    -- skynet.fork(function()
    --     local result, err = dbhelper.queryUserInfo(command.dbconn)
    --     if err ~= nil then
    --         skynet.error(err)
    --         return
    --     end
    --     dump(result, "result")
    -- end)

    local errmsg = "dbserver start"
    return 0, errmsg
end

-- 服务停止·接口
function command.STOP()
    command.methods = {}
    command.running = false

    database.close(command.dbconn)
    command.dbconn = nil

    local errmsg = "dbserver stop"
    return 0, errmsg
end

-- 注册业务处理接口
function command.registerMethods()
    command.methods[0x0001] = {func = dbhelper.syncMatchServerInfo, desc="同步匹配服务器数据"}
    command.methods[0x0002] = {func = dbhelper.syncRoomServerOnlineCount, desc="更新房间在线用户数"}
    command.methods[0x0003] = {func = dbhelper.writeGameLog, desc="写游戏记录"}
    command.methods[0x0004] = {func = dbhelper.writeScoreChangeLog, desc="写玩家金币变化"}
    -- dump(command.methods, "db_server.command.methods")
end

-- 写数据到DB
function command.MESSAGE(mid, sid, content)
    skynet.error(string.format("db_server mid=%d, sid=%d", mid, sid))

    if mid ~= 0x0005 then
        skynet.error("unknow db_server message command")
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
    skynet.register(".db_server")
end

skynet.start(dispatch)
