package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/room_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
require("skynet.manager")
require("common.export")
require("config.config")

--[[
    实时将自己在线信息实时写入redis；
    在线信息：当前房间人数
]]


-- 玩家下注信息
-- [{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000},{"userId":1000,"bet":1000}]

-- 玩家结算信息
-- [{"userId":1000,"score":1000},{"userId":1000,"score":1000},{"userId":1000,"score":1000},{"userId":1000,"score":1000},{"userId":1000,"score":1000},{"userId":1000,"score":1000}]

-- 玩家牌面值信息
-- [{"userId":1000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":1000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":1000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":1000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":1000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":1000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]}]

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
    
    local errmsg = "roomserver start"
    return 0, errmsg
end

-- 服务停止·接口
function command.STOP()
    command.running = false

    local errmsg = "roomserver stop"
    return 0, errmsg
end

-- 上报服务器信息
function command._uploadServerInfo ()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 每秒更新房间在线用户信息到日志服务
        if math.fmod(now.sec, 1) == 0 then
            -- skynet.error("系统时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))
            
            command.room_online_count = math.random(100, 150)
            
            local logServerId = skynet.localname(".log_server")
            skynet.send(logServerId, "lua", "message", 0x0006, 0x0002,
            {
                room_id = command.room_id, -- 房间ID
                room_name = command.room_name, -- 房间名字
                room_online_count = command.room_online_count, -- 房间在线人数
            })
        end

        -- 每10秒写牌局日志到日志服务器
        -- 每10秒玩家分数日志到日志服务器
        if math.fmod(now.sec, 10) == 0 then
            local logServerId = skynet.localname(".log_server")

            -- 1. 写牌局日志到日志服务器
            local gamelog = {}
            gamelog.gameLogId = os.time() -- 牌局ID
            gamelog.betScore = {} -- 玩家下注分数
            gamelog.resultScore = {} -- 玩家结算分数
            gamelog.cardInfo = {} -- 玩家牌面值信息
            table.insert(gamelog.betScore, {userId= 10000, bet=80})
            table.insert(gamelog.betScore, {userId= 10001, bet=10})
            table.insert(gamelog.betScore, {userId= 10002, bet=20})
            table.insert(gamelog.betScore, {userId= 10003, bet=30})
            
            table.insert(gamelog.resultScore, {userId= 10000, score=60, status=1})
            table.insert(gamelog.resultScore, {userId= 10001, score=10, status=-1})
            table.insert(gamelog.resultScore, {userId= 10002, score=20, status=-1})
            table.insert(gamelog.resultScore, {userId= 10003, score=30, status=-1})

            table.insert(gamelog.cardInfo, {userId= 10000, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
            table.insert(gamelog.cardInfo, {userId= 10001, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
            table.insert(gamelog.cardInfo, {userId= 10002, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
            table.insert(gamelog.cardInfo, {userId= 10003, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
            skynet.send(logServerId, "lua", "message", 0x0006, 0x0003, gamelog)

            -- 2. 写玩家分数日志到日志服务器
            local gameScoreChangeLog = {}
            table.insert(gameScoreChangeLog, {userId = 10000, score = 10, changeScore = 60, beforScore = 10000})
            table.insert(gameScoreChangeLog, {userId = 10001, score = 10, changeScore = -10, beforScore = 10000})
            table.insert(gameScoreChangeLog, {userId = 10002, score = 10, changeScore = -20, beforScore = 10000})
            table.insert(gameScoreChangeLog, {userId = 10003, score = 10, changeScore = -30, beforScore = 10000})
            skynet.send(logServerId, "lua", "message", 0x0006, 0x0004, gameScoreChangeLog)
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