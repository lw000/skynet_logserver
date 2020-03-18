local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("sky_common.helper")
require("common.export")
require("config.config")

local redishelper = {

}

redishelper.match_server_key = "match_server"
redishelper.room_server_key = "room_server"

-- 保存配服务器信息
function redishelper.saveMatchServerInfo(redisConn, content)
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新匹配服务器状态", jsonstr)
    local ok = redisConn:hset("match_server", content.server_id, jsonstr)
    -- skynet.error("redis:", ok)
end

-- 保存房间在线用户
function redishelper.saveRoomServerInfo(redisConn, content)
    local jsonstr = cjson.encode(content)
    skynet.error("REDIS·更新房间服务器在线人数", jsonstr)
    local ok = redisConn:hset("room_server", content.room_id, jsonstr)
    -- skynet.error("redis:", ok)
end

--[[
    函數：同步匹配服务器信息
    返回值：
        成功: 0
        失敗: 1, errmsg
]]
function redishelper.syncMatchServerInfo(redisConn, content)
    local exists = redisConn:exists(redishelper.match_server_key)
    if not exists then
        local errmsg = "redis key [" .. redishelper.match_server_key .. "] not found"
        skynet.error(errmsg)
        return 1, errmsg
    end

    local results = redisConn:hvals(redishelper.match_server_key)
    for k, v in pairs(results) do
        skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, v)
    end

    return 0
end

--[[
    函數：同步房间在线用户數
    返回值：
        成功: 0
        失敗: 1, errmsg
]]
function redishelper.syncRoomServerInfo(redisConn, content)
    -- 2. 同步房间服务器数据
    local exists = redisConn:exists(redishelper.room_server_key)
    if not exists then
        local errmsg = "redis key [" .. redishelper.room_server_key .. "] not found"
        skynet.error(errmsg)
        return 1, errmsg
    end

    local results = redisConn:hvals(redishelper.room_server_key)
    for k, v in pairs(results) do
        skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_UPDATE_ROOM_SERVER_INFOS, v)
    end

    return 0
end

return redishelper