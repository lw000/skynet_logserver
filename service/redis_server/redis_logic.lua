local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("skycommon.helper")
require("common.export")
require("core.define")

local rediskey_match_server = "match_server"
local rediskey_room_server = "room_server"

local logic = {

}

-- 更新配服务器数据
function logic.onUpdateMatchServerInfo(redisConn, content)
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新配服务器数据 " .. jsonstr)
    local ok = redisConn:hset(rediskey_match_server, content.server_id, jsonstr)
    -- skynet.error("redis:", ok)
    return ok
end

-- 更新房间服务器数据
function logic.onUpdateRoomServerInfo(redisConn, content)
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新房间服务器数据 " .. jsonstr)
    local ok = redisConn:hset(rediskey_room_server, content.room_id, jsonstr)
    -- skynet.error("redis:", ok)
    return ok
end

-- 同步匹配服务器信息
function logic.syncMatchServerInfoToDB(redisConn, content)
    local exists = redisConn:exists(rediskey_match_server)
    if not exists then
        local errmsg = "redis key [" .. rediskey_match_server .. "] not found"
        skynet.error(errmsg)
        return 1, errmsg
    end

    local results = redisConn:hvals(rediskey_match_server)
    for k, v in pairs(results) do
        skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, v)
    end

    return 0
end

-- 同步房间服务器数据
function logic.syncRoomServerInfoToDB(redisConn, content)
    local exists = redisConn:exists(rediskey_room_server)
    if not exists then
        local errmsg = "redis key [" .. rediskey_room_server .. "] not found"
        skynet.error(errmsg)
        return 1, errmsg
    end

    local results = redisConn:hvals(rediskey_room_server)
    for k, v in pairs(results) do
        skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_UPDATE_ROOM_SERVER_INFOS, v)
    end

    return 0
end

return logic