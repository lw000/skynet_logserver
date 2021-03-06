local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("skycommon.helper")
require("common.export")
require("core.define")

local logic = {}

-- 更新房间服务器信息
function logic.updateRoomInfo(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE_CONF.LOG.NAME, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_UPDATE_ROOM_SERVER_INFOS, content)
end

-- 写游戏牌局记录
function logic.writeGameLog(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE_CONF.LOG.NAME, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_GAME_LOG, content)
end

-- 写金币变化记录
function logic.writeGameScoreChangeLog(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE_CONF.LOG.NAME, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_GAME_SCORE_CHANGE_LOG, content)
end

return logic