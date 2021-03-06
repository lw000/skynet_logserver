package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/room_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local skyhelper = require("skycommon.helper")
local logic = require("room_logic")
require("skynet.manager")
require("common.export")
require("core.define")

--[[
    实时将自己在线信息实时写入redis；
    在线信息：当前房间人数
]]

-- 玩家下注信息
-- [{"userId":10000,"bet":1000},{"userId":10001,"bet":1000},{"userId":10002,"bet":1000},{"userId":10003,"bet":1000}]

-- 玩家结算信息
-- [{"userId":10000,"score":1000},{"userId":10001,"score":1000},{"userId":10002,"score":1000},{"userId":10003,"score":1000}]

-- 玩家牌面值信息
-- [{"userId":10000,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":10001,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":10002,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]},{"userId":10003,"cards":["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]}]

local command = {
    servertype = SERVICE_CONF.ROOM.TYPE,     -- 服务类型
    servername = SERVICE_CONF.ROOM.NAME,  	-- 服务名
    room_id = 0,                        -- 房间服务ID
    room_name = "",                     -- 房间服务名
    running = false,                     -- 服务器状态
    online_count = 0,                   -- 房间在线人数
}

-- 服务启动·接口
function command.START(conf)
    assert(conf ~= nil)
    -- dump(conf, "conf")

    command.room_id = conf.room_id
    command.room_name = conf.room_name
    command.running = true

    math.randomseed(os.time())

    -- 房间服务·主业务
    skynet.fork(
		function(...)
			local ok = xpcall(
				command._run,
				__G__TRACKBACK__
			)
			if ok then
				skynet.error("_run exit")
			end
		end
	)

    -- 上报服务器状态
    skynet.timeout(100, command._uploadServerInfo)

    -- 写牌局日志到日志服务器
    -- 写玩家分数日志到日志服务器
    skynet.timeout(1000, command._writeLog)

    return 0
end

-- 服务停止·接口
function command.STOP()
    command.running = false
    
    return 0
end

-- 房间服务·主业务
function command._run ()
    while command.running do
        skynet.sleep(100)
        command.online_count = math.random(100, 150)
    end
end

-- 写玩家牌局日志,玩家分数日志到日志服务器
function command._writeLog ()
    if command.running then
        skynet.timeout(1000, command._writeLog)
    end

    -- 1. 写牌局日志到日志服务器
    local gamelog = {}
    gamelog.gameLogId = os.time() -- 牌局ID
    gamelog.betScore = {} -- 玩家下注分数
    gamelog.resultScore = {} -- 玩家结算分数
    gamelog.cardInfo = {} -- 玩家牌面值信息
    
    -- 玩家下注分数
    table.insert(gamelog.betScore, {userId= 10000, bet=80})
    table.insert(gamelog.betScore, {userId= 10001, bet=10})
    table.insert(gamelog.betScore, {userId= 10002, bet=20})
    table.insert(gamelog.betScore, {userId= 10003, bet=30})
    
    -- 玩家结算分数
    table.insert(gamelog.resultScore, {userId= 10000, score=60, status=1})
    table.insert(gamelog.resultScore, {userId= 10001, score=10, status=-1})
    table.insert(gamelog.resultScore, {userId= 10002, score=20, status=-1})
    table.insert(gamelog.resultScore, {userId= 10003, score=30, status=-1})

    -- 玩家牌面值信息
    table.insert(gamelog.cardInfo, {userId= 10000, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
    table.insert(gamelog.cardInfo, {userId= 10001, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
    table.insert(gamelog.cardInfo, {userId= 10002, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
    table.insert(gamelog.cardInfo, {userId= 10003, cards={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}})
    -- skynet.error("写牌局日志到日志服务器")
    logic.writeGameLog(gamelog)
    
    -- 2. 写玩家分数日志到日志服务器
    local gameScoreChangeLog = {}
    table.insert(gameScoreChangeLog, {userId = 10000, score = 10, changeScore = 60, beforScore = 10000})
    table.insert(gameScoreChangeLog, {userId = 10001, score = 10, changeScore = -10, beforScore = 10000})
    table.insert(gameScoreChangeLog, {userId = 10002, score = 10, changeScore = -20, beforScore = 10000})
    table.insert(gameScoreChangeLog, {userId = 10003, score = 10, changeScore = -30, beforScore = 10000})
    -- skynet.error("写玩家分数日志到日志服务器")
    logic.writeGameScoreChangeLog(gameScoreChangeLog)
end

-- 上报服务器信息
function command._uploadServerInfo ()
    if command.running then
        skynet.timeout(100, command._uploadServerInfo)
    end

    -- skynet.error("更新房间服务器数据（在线用户数）")
    local roomInfo = {
        room_id = command.room_id, -- 房间ID
        room_name = command.room_name, -- 房间名字
        room_online_count = command.online_count, -- 房间在线人数
    }
    logic.updateRoomInfo(roomInfo)
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
