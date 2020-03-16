package.path = package.path .. ";./service/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
require("skynet.manager")
require("common.export")
require("config.config")
local database = require("database.database")

--[[
    db数据库服务
]]

local command = {
    server_id = SERVICE_CONFIG.DB_SERVICE_ID, -- 服务ID
    running = false, -- 服务器状态
    dbconn = nil, -- 数据库连接信息
    conf = {}, -- 数据库配置
}

-- 服务启动·接口
--[[
    返回值：code, err
    code=0成功，非零失败
    err 错误消息
]]
function command.START(conf)
    assert(conf ~= nil)
    dump(conf, "conf")
    command.conf = conf
    command.dbconn = database.mysql_open(command.conf)
    assert(command.dbconn ~= nil)
    if command.dbconn == nil then
        return -1, "DB服务器·启动失败"
    end

    command.running = true

    skynet.fork(function()
        local sql = [[select * from user]]
        local result, err = database.mysql_query(command.dbconn, sql)
        if err ~= nil then
            skynet.error(err)
            return
        end
        dump(result, "result")
    end)

    local msg = "DB服务器·启动成功"
    return 0, msg
end

-- 服务停止·接口
function command.STOP()
    command.running = false

    local msg = "DB服务器·停止成功"
    return 0, msg
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
            else
                skynet.error(string.format("unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".db_server")
end

skynet.start(dispatch)
