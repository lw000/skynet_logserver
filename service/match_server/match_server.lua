package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/match_server/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
require("skynet.manager")
require("common.export")
require("config.config")

--[[
    每秒将服务器状态实时写入到redis；
    服务器状态信息：匹配队列等待人数，已经成功匹配的次数；匹配时长
]]

local command = {
    server_type = SERVICE_TYPE.MATCH,   -- 服务类型
    server_id = -1,                     -- 服务ID
    server_name = "",                   -- 服务名称
    match_queue_length = 0,             -- 匹配队列等待人数
    match_success_count = 0,            -- 成功匹配的次数
    match_time = 0,                     -- 匹配时长
    running = false,                    -- 服务器状态
}

-- 服务启动·接口
function command.START(conf)
    assert(conf ~= nil)
    command.server_id = conf.server_id
    command.server_name = conf.server_name
    assert(command.server_id ~= nil or command.server_id ~= -1)
    assert(command.server_name ~= nil or command.server_name ~= "")

    command.running = true
    
    math.randomseed(os.time())

    -- 上报服务器状态
    skynet.fork(command._uploadServerInfo)

    local errmsg = "matchserver start"
    return 0, errmsg
end

-- 服务停止·接口
function command.STOP()
    command.running = false

    local errmsg = "matchserver stop"
    return 0, errmsg
end

-- 报告服务器信息
function command._uploadServerInfo()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 按秒·上报
        if math.fmod(now.sec, 1) == 0 then
            -- skynet.error("系统时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))
            
            skynet.error("匹配服务器·匹配队列等待人数，已经成功匹配的次数；匹配时长")

            command.match_queue_length = math.random(100, 150)
            command.match_success_count = math.random(100, 150)

            local logServerId = skynet.localname(SERVER_NAME.LOG)
            assert(logServerId ~= nil)
            if logServerId == nil then
                return
            end
            skynet.send(logServerId, "lua", "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_UPDATE_MATCH_SERVER_INFOS,
            {
                server_id = command.server_id, -- 服务ID
                server_name = command.server_name, -- 服务名字
                match_queue_length = command.match_queue_length, -- 匹配队列等待人数
                match_success_count = command.match_success_count, -- 成功匹配的次数
                match_time = command.match_time, -- 匹配时长
            })
        end

        -- 按分钟·上报
        if now.sec == 0 and math.fmod(now.min, 1) == 0 then

        end
    end
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
                skynet.error(string.format("matching_server unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(SERVER_NAME.MATCH)
end

skynet.start(dispatch)
