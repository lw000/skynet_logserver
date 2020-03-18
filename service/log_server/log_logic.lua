local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("skycommon.helper")
require("common.export")
require("config.config")

local logic = {

}

-- 同步匹配服务器信息
function logic.saveMatchServerInfo(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE.NAME.REDIS, "message", REDIS_CMD.MDM_REDIS, REDIS_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, content)
end

-- 同步房间在线用户
function logic.saveRoomServerInfo(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE.NAME.REDIS, "message", REDIS_CMD.MDM_REDIS, REDIS_CMD.SUB_UPDATE_ROOM_SERVER_INFOS, content)
end

-- 写玩家游戏记录
function logic.writeGameLog(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_GAME_LOG, content)
end

-- 写玩家金币变化记录
function logic.writeScoreChangeLog(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_GAME_SCORE_CHANGE_LOG, content)
end

-- 查询用户信息
function logic.queryUserInfo(content)
    assert(content ~= nil)
    return skyhelper.callLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_USER_INFO, content)
end

return logic