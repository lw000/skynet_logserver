local skynet = require("skynet")
local cjson = require("cjson")
require("common.export")

local redishelper = {

}

-- 同步匹配服务器信息
function redishelper.syncMatchServerInfo(redisConn, content)
    local server_id = content.server_id -- 服务ID
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新匹配服务器状态", jsonstr)
    local ok = redisConn:hset("match_server", server_id, jsonstr)
    -- skynet.error("redis:", ok)
end

-- 同步房间在线用户
function redishelper.syncRoomServerOnlineCount(redisConn, content)
    local room_id = content.room_id 
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新房间服务器在线人数", jsonstr)
    local ok = redisConn:hset("room_server", room_id, jsonstr)
    -- skynet.error("redis:", ok)
end

-- 写玩家游戏记录
function redishelper.writeGameLog(redisConn, content)
    local db_server_id = skynet.localname(".db_server")
    assert(db_server_id > 0)
    skynet.send(db_server_id, "lua", "message", 0x0005, 0x0003, content)
end

-- 写玩家金币变化记录
function redishelper.writeScoreChangeLog(redisConn, content)
    local db_server_id = skynet.localname(".db_server")
    assert(db_server_id > 0)
    skynet.send(db_server_id, "lua", "message", 0x0005, 0x0004, content)
end

return redishelper