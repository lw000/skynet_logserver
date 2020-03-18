local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("skycommon.helper")
require("common.export")
require("core.define")

local logic = {}

function logic.updateServerInfo(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE.NAME.LOG, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, content)
end

function logic.queryUserInfo(content)
    assert(content ~= nil)
    return skyhelper.callLocal(SERVICE.NAME.LOG, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_USER_INFO, content)
end

return logic