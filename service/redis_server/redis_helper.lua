local skynet = require("skynet")
local cjson = require("cjson")
require("common.export")
require("config.config")

local redishelper = {

}

redishelper.match_server_key = "match_server"
redishelper.room_server_key = "room_server"

-- 保存配服务器信息
function redishelper.saveMatchServerInfo(redisConn, content)
    local server_id = content.server_id -- 服务ID
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新匹配服务器状态", jsonstr)
    local ok = redisConn:hset("match_server", server_id, jsonstr)
    -- skynet.error("redis:", ok)
end

-- 保存房间在线用户
function redishelper.saveRoomServerOnlineCount(redisConn, content)
    local room_id = content.room_id 
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新房间服务器在线人数", jsonstr)
    local ok = redisConn:hset("room_server", room_id, jsonstr)
    -- skynet.error("redis:", ok)
end

-- 同步匹配服务器信息
function redishelper.syncMatchServerInfo(redisConn, content)
    local exists = redisConn:exists(redishelper.match_server_key)
    if exists then
        local db_server_id = skynet.localname(".db_server")
        assert(db_server_id > 0)
        if db_server_id > 0 then
            local results = redisConn:hvals(redishelper.match_server_key)
            for k, v in pairs(results) do
                skynet.send(db_server_id, "lua", "message", DB_CMD.MDM_DB, DB_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, v)
            end
        end
    else
        skynet.error("redis key " .. redishelper.match_server_key .. " not found")
    end
end

-- 同步房间在线用户
function redishelper.syncRoomServerOnlineCount(redisConn, content)
    -- 2. 同步房间服务器数据
    local exists = redisConn:exists(redishelper.room_server_key)
    if exists then
        local db_server_id = skynet.localname(".db_server")
        assert(db_server_id > 0)
        local results = redisConn:hvals(redishelper.room_server_key)
        for k, v in pairs(results) do
            skynet.send(db_server_id, "lua", "message", DB_CMD.MDM_DB, DB_CMD.SUB_UPDATE_ROOM_ONLINE_COUNT, v)
        end
    else
        skynet.error("redis key " .. redishelper.room_server_key .. " not found")
    end
end

return redishelper