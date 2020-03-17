package.path = package.path .. ";./service/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
local database = require("database.database")
local cjson = require("cjson")
require("skynet.manager")
require("common.export")
require("config.config")

--[[
    db数据库服务
]]

local command = {
    server_type = SERVICE_TYPE.DB, -- 服务ID
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
    -- dump(conf, "conf")

    command.conf = conf
    command.dbconn = database.open(command.conf)
    assert(command.dbconn ~= nil)
    if command.dbconn == nil then
        return -1, "DB服务器·启动失败"
    end

    command.running = true

    -- skynet.fork(function()
    --     local sql = [[select * from user]]
    --     local result, err = database.query(command.dbconn, sql)
    --     if err ~= nil then
    --         skynet.error(err)
    --         return
    --     end
    --     dump(result, "result")
    -- end)

    local errmsg = "DB服务器·启动"
    return 0, errmsg
end

-- 服务停止·接口
function command.STOP()
    command.running = false
    database.close(command.dbconn)

    local errmsg = "DB服务器·停止"
    return 0, errmsg
end

-- 写数据到DB
function command.WRITEMESSAGE(mainId, subId, content)
	if mainId == 0x0005 then
        if subId == 0x0001 then	-- 更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长
			local data = cjson.decode(content)
            dump(data, "数据库·匹配服务器状态")

            local sql = [[INSERT INTO matchServerInfo (serverId, serverName, matchQueueLength, matchSuccessCount, matchDuration, updateTime)
                VALUES (?,?,?,?,?,?) 
                ON DUPLICATE KEY UPDATE matchQueueLength= ?, matchSuccessCount= ?, matchDuration= ?, updateTime= ?;]]
            local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
            local result, err = database.execute(command.dbconn, sql,
                data.server_id,
                data.server_name,
                data.match_queue_length,
                data.match_success_count,
                data.match_time,
                now,
                data.match_queue_length,
                data.match_success_count,
                data.match_time,
                now)
            if err ~= nil then
                skynet.error(err)
                return
            end

            -- 写入数据库
        elseif subId == 0x0002 then	-- 更新房间服务器在线人数
            local data = cjson.decode(content)
            dump(data, "数据库·更新房间服务器在线人数")
            
            -- 写入数据库
            local sql = [[INSERT INTO roomServerInfo (roomId, roomName, roomOnlineCount, updateTime)
                VALUES (?,?,?,?) 
                ON DUPLICATE KEY UPDATE roomOnlineCount= ?, updateTime= ?;]]
            local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
            local result, err = database.execute(command.dbconn, sql,
                data.room_id,
                data.room_name,
                data.room_online_count,
                now,
                data.room_online_count,
                now)
            if err ~= nil then
                skynet.error(err)
                return
            end
        elseif subId == 0x0003 then -- 玩家牌局日志
            dump(content, "数据库·玩家牌局日志")
            local gameLogId = content.gameLogId
            local betScore = cjson.encode(content.betScore)
            local resultScore = cjson.encode(content.resultScore)
            local cardInfo = cjson.encode(content.cardInfo)
        
            -- 写入数据库
            local sql = [[INSERT INTO gameLog (gameLogId,betScore,resultScore,cardInfo,updateTime) VALUES (?,?,?,?,?);]]
            local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
            local result, err = database.execute(command.dbconn, sql, gameLogId, betScore, resultScore, cardInfo, now)
            if err ~= nil then
                skynet.error(err)
                return
            end
        elseif subId == 0x0004 then -- 玩家分数日志
            dump(content, "数据库·玩家分数日志")
            
            -- 写入数据库
            local sql = [[INSERT INTO gameScoreChangeLog (userId,score,changeScore,beforeScore,updateTime) VALUES (?,?,?,?,?);]]
            local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
            for _, v in pairs(content) do
                local userId = v.userId
                local score = v.score
                local changeScore = v.changeScore
                local beforScore = v.beforScore
                local result, err = database.execute(command.dbconn, sql, userId, score, changeScore, beforScore, now)
                if err ~= nil then
                    skynet.error(err)
                    return
                end
            end
		end
	else
		skynet.error("unknow message command")
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
            elseif cmd == "WRITEMESSAGE" then
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
