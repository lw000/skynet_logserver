local skynet = require("skynet")
local cjson = require("cjson")
local skyhelper = require("skycommon.helper")
require("common.export")
require("core.define")

local logic = {}

-- 更新服务器信息
function logic.updateServerInfo(content)
    assert(content ~= nil)
    skyhelper.sendLocal(SERVICE.NAME.LOG, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_UPDATE_MATCH_SERVER_INFOS, content)
end

-- 查询用户信息
function logic.queryUserInfo(userId)
    assert(userId ~= nil)
    assert(type(userId) == "number")
    assert(userId > 0)
    return skyhelper.callLocal(SERVICE.NAME.LOG, "message", LOG_CMD.MDM_LOG, LOG_CMD.SUB_USER_INFO, userId)
end

return logic