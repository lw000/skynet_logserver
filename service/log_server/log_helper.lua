local skynet = require("skynet")
local cjson = require("cjson")
require("common.export")
require("config.config")

local loghelper = {

}

-- 同步匹配服务器信息
function loghelper.saveMatchServerInfo(redisConn, content)
    local redis_server_id = skynet.localname(".redis_server")
    assert(redis_server_id > 0)
    skynet.send(redis_server_id, "lua", "message", REDIS_CMD.MDM_REDIS, REDIS_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, content)
end

-- 同步房间在线用户
function loghelper.saveRoomServerOnlineCount(redisConn, content)
    local redis_server_id = skynet.localname(".redis_server")
    assert(redis_server_id > 0)
    skynet.send(redis_server_id, "lua", "message", REDIS_CMD.MDM_REDIS, REDIS_CMD.SUB_UPDATE_ROOM_ONLINE_COUNT, content)
end

-- 写玩家游戏记录
function loghelper.writeGameLog(redisConn, content)
    local db_server_id = skynet.localname(".db_server")
    assert(db_server_id > 0)
    skynet.send(db_server_id, "lua", "message", DB_CMD.MDM_DB, DB_CMD.SUB_GAME_LOG, content)
end

-- 写玩家金币变化记录
function loghelper.writeScoreChangeLog(redisConn, content)
    local db_server_id = skynet.localname(".db_server")
    assert(db_server_id > 0)
    skynet.send(db_server_id, "lua", "message", DB_CMD.MDM_DB, DB_CMD.SUB_GAME_SCORE_CHANGE_LOG, content)
end

return loghelper