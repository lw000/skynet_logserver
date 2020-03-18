local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("sky_common.helper")
require("common.export")
require("config.config")

local logic = {}

function logic.updateServerInfo(content)
    assert(content ~= nil)
    skynet.error("更新匹配服务器数据（匹配队列等待人数，已经成功匹配的次数，匹配时长）")
    skyhelper.sendLocal(SERVICE.NAME.LOG, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, content)
end

return logic