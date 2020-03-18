local skynet = require("skynet")
local cjson = require("cjson")
local database = require("database.database")
require("common.export")

local dbhelper = {

}

function dbhelper.checkparcm(dbconn, content)
    assert(dbconn ~= nil)
    assert(content ~= nil)
    if dbconn == nil then
        return -1
    end
    if content == nil then
        return -1
    end
    return 0
end

-- 获取用户信息
function dbhelper.queryUserInfo(dbconn, content)
    local sql = [[select * from user]]
    local result, err = database.query(dbconn, sql)
    if err ~= nil then
        skynet.error(err)
        return nil, err
    end
    return result, nil
end

-- 同步匹配服务器信息
function dbhelper.syncMatchServerInfo(dbconn, content)
    assert(dbconn ~= nil)
    assert(content ~= nil)
    if dbconn == nil then
        return 1, "db connect is nil"
    end

    if content == nil then
        return 2, "content is nil"
    end

    local data = cjson.decode(content)
    dump(data, "数据库·匹配服务器状态")

    local sql = [[INSERT INTO matchServerInfo (serverId, serverName, matchQueueLength, matchSuccessCount, matchDuration, updateTime)
        VALUES (?,?,?,?,?,?) 
        ON DUPLICATE KEY UPDATE matchQueueLength=?, matchSuccessCount=?, matchDuration=?, updateTime=?;]]
    local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
    local result, err = database.execute(dbconn, sql,
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
        return 3, err
    end

    return 0, nil
end

-- 同步房间在线用户
function dbhelper.syncRoomServerOnlineCount(dbconn, content)
    assert(dbconn ~= nil)
    assert(content ~= nil)
    if dbconn == nil then
        return 1, "db connect is nil"
    end

    if content == nil then
        return 2, "content is nil"
    end

    local data = cjson.decode(content)
    dump(data, "数据库·更新房间服务器在线人数")

    -- 写入数据库
    local sql = [[INSERT INTO roomServerInfo (roomId, roomName, roomOnlineCount, updateTime)
        VALUES (?,?,?,?) 
        ON DUPLICATE KEY UPDATE roomOnlineCount= ?, updateTime= ?;]]
    local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
    local result, err = database.execute(dbconn, sql,
        data.room_id,
        data.room_name,
        data.room_online_count,
        now,
        data.room_online_count,
        now)
    if err ~= nil then
        skynet.error(err)
        return 3, err
    end

    return 0, nil
end

-- 写玩家游戏记录
function dbhelper.writeGameLog(dbconn, content)
    assert(dbconn ~= nil)
    assert(content ~= nil)
    if dbconn == nil then
        return 1, "db connect is nil"
    end

    if content == nil then
        return 2, "content is nil"
    end

    dump(content, "数据库·玩家牌局日志")
    local gameLogId = content.gameLogId
    local betScore = cjson.encode(content.betScore)
    local resultScore = cjson.encode(content.resultScore)
    local cardInfo = cjson.encode(content.cardInfo)

    -- 写入数据库
    local sql = [[INSERT INTO gameLog (gameLogId,betScore,resultScore,cardInfo,updateTime) VALUES (?,?,?,?,?);]]
    local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
    local result, err = database.execute(dbconn, sql, gameLogId, betScore, resultScore, cardInfo, now)
    if err ~= nil then
        skynet.error(err)
        return 3, err
    end
    return 0, nil
end

-- 写玩家金币变化记录
function dbhelper.writeScoreChangeLog(dbconn, content)
    assert(dbconn ~= nil)
    assert(content ~= nil)
    if dbconn == nil then
        return 1, "db connect is nil"
    end

    if content == nil then
        return 2, "content is nil"
    end

    dump(content, "数据库·玩家分数变化日志")
            
    -- 写入数据库
    local sql = [[INSERT INTO gameScoreChangeLog (userId,score,changeScore,beforeScore,updateTime) VALUES (?,?,?,?,?);]]
    local now = os.date("%Y-%m-%d %H:%M:%S", os.time())
    for _, v in pairs(content) do
        local userId = v.userId
        local score = v.score
        local changeScore = v.changeScore
        local beforScore = v.beforScore
        local result, err = database.execute(dbconn, sql, userId, score, changeScore, beforScore, now)
        if err ~= nil then
            skynet.error(err)
            return 3, err
        end
    end

    return 0, nil
end


return dbhelper