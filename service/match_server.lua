package.path = package.path .. ";./service/?.lua;"
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
    server_type = SERVICE_TYPE.MATCH, -- 服务ID
    server_name = "匹配服务器",
    match_queue_length = 0, -- 匹配队列等待人数
    match_success_count = 0, -- 成功匹配的次数
    match_time = 0, -- 匹配时长
    running = false, -- 服务器状态
}

-- 服务启动·接口
function command.START(conf)
    assert(conf ~= nil)
    command.running = true

    -- 上报服务器状态
    skynet.fork(command._uploadServerInfo)

    local errmsg = "匹配服务器·启动"
    return 0, errmsg
end

-- 服务停止·接口
function command.STOP()
    command.running = false

    local errmsg = "匹配服务器·停止"
    return 0, errmsg
end

-- 报告服务器信息
function command._uploadServerInfo()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 按秒·汇报
        if math.fmod(now.sec, 1) == 0 then
            -- skynet.error("系统时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))

            skynet.error("上报·匹配服务器状态")
            
            local redis_server_id = skynet.localname(".redis_server")
            skynet.send(redis_server_id, "lua", "writeMessage", 0x0004, 0x0001,
            {
                server_type = command.server_type, -- 服务类型
                server_name = command.server_name,
                match_queue_length = command.match_queue_length, -- 匹配队列等待人数
                match_success_count = command.match_success_count, -- 成功匹配的次数
                match_time = command.match_time, -- 匹配时长
            })
        end

        -- 按分钟·汇报
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
    skynet.register(".match_server")
end

skynet.start(dispatch)
