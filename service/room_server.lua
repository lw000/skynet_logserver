package.path = package.path .. ";./service/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
require("skynet.manager")
require("common.export")
require("config.config")

--[[
    实时将自己在线信息实时写入redis；
    在线信息：当前房间人数
]]

local command = {
    server_type = SERVICE_TYPE.ROOM, -- 服务ID
    room_id = 0, -- 房间ID
    room_name = "", -- 房间名字
    room_online_count = 0, -- 当前房间在线人数
    running = false -- 服务器状态
}

-- 服务启动·接口
function command.START(conf)
    assert(conf ~= nil)
    dump(conf, "conf")
    command.room_id = conf.room_id
    command.room_name = conf.room_name
    command.running = true

    math.randomseed(os.time())

    -- 上报服务器状态
    skynet.fork(command._uploadServerInfo)
    
    return 0, "房间服务器·启动"
end

-- 服务停止·接口
function command.STOP()
    command.running = false

    local errmsg = "房间服务器·停止"
    return 0, errmsg
end

-- 上报服务器信息
function command._uploadServerInfo ()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 按秒·汇报
        if math.fmod(now.sec, 1) == 0 then
            -- skynet.error("系统时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))
            -- skynet.error("上报·房间服务器在线人数")
            
            command.room_online_count = math.random(100, 150)
            
            local redis_server_id = skynet.localname(".redis_server")
            skynet.send(redis_server_id, "lua", "writeMessage", 0x0004, 0x0002,
            {
                room_id = command.room_id, -- 房间ID
                room_name = command.room_name, -- 房间名字
                room_online_count = command.room_online_count, -- 房间在线人数
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
                skynet.error(string.format("room_server unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".room_server")
end

skynet.start(dispatch)
