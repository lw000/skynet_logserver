local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("sky_common.helper")
require("common.export")
require("config.config")

local loghelper = {

}

-- 同步匹配服务器信息
function loghelper.saveMatchServerInfo(content)
   skyhelper.sendLocal(SERVICE.NAME.REDIS, "message", REDIS_CMD.MDM_REDIS, REDIS_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, content)
end

-- 同步房间在线用户
function loghelper.saveRoomServerInfo(content)
    skyhelper.sendLocal(SERVICE.NAME.REDIS, "message", REDIS_CMD.MDM_REDIS, REDIS_CMD.SUB_UPDATE_ROOM_SERVER_INFOS, content)
end

-- 写玩家游戏记录
function loghelper.writeGameLog(content)
    skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_GAME_LOG, content)
end

-- 写玩家金币变化记录
function loghelper.writeScoreChangeLog(content)
    skyhelper.sendLocal(SERVICE.NAME.DB, "message", DB_CMD.MDM_DB, DB_CMD.SUB_GAME_SCORE_CHANGE_LOG, content)
end

return loghelper