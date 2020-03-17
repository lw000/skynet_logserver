local skynet = require("skynet")
local cjson = require("cjson")
require("common.export")

local loghelper = {

}

-- 同步匹配服务器信息
function loghelper.syncMatchServerInfo(redisConn, content)
    local redis_server_id = skynet.localname(".redis_server")
    assert(redis_server_id > 0)
    skynet.send(redis_server_id, "lua", "message", 0x0004, 0x0001, content)
end

-- 同步房间在线用户
function loghelper.syncRoomServerOnlineCount(redisConn, content)
    local redis_server_id = skynet.localname(".redis_server")
    assert(redis_server_id > 0)
    skynet.send(redis_server_id, "lua", "message", 0x0004, 0x0002, content)
end

-- 写玩家游戏记录
function loghelper.writeGameLog(redisConn, content)
    local db_server_id = skynet.localname(".db_server")
    assert(db_server_id > 0)
    skynet.send(db_server_id, "lua", "message", 0x0005, 0x0003, content)
end

-- 写玩家金币变化记录
function loghelper.writeScoreChangeLog(redisConn, content)
    local db_server_id = skynet.localname(".db_server")
    assert(db_server_id > 0)
    skynet.send(db_server_id, "lua", "message", 0x0005, 0x0004, content)
end

return loghelper