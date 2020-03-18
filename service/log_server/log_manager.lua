local skynet = require("skynet")
local logic = require("log_logic")
require("common.export")

local manager = {
    methods = nil,   -- 业务处理接口映射表
    servername = nil,   -- 服务名字
}

function manager.start(servername)
    assert(servername ~= nil) 
    manager.servername = servername

    -- 注册业务处理接口
    if manager.methods == nil then
		manager.methods = {}
    end
    manager.methods[LOG_CMD.SUB_UPDATE_MATCH_SERVER_INFOS]  = {func = logic.saveMatchServerInfo, desc="更新匹配服务器数据"}
    manager.methods[LOG_CMD.SUB_UPDATE_ROOM_SERVER_INFOS]   = {func = logic.saveRoomServerInfo, desc="更新房间服务器数据"}
    manager.methods[LOG_CMD.SUB_GAME_LOG]                   = {func = logic.writeGameLog, desc="写游戏记录"}
    manager.methods[LOG_CMD.SUB_GAME_SCORE_CHANGE_LOG]      = {func = logic.writeScoreChangeLog, desc="写玩家金币变化记录"}
    manager.methods[LOG_CMD.SUB_USER_INFO]                  = {func = logic.queryUserInfo, desc="查询用户信息"}
    
    -- dump(manager.methods, manager.servername .. ".command.methods")
end

function manager.stop()
    manager.methods = nil
end

function manager.dispatch(mid, sid, content)
    assert(mid ~= nil and mid >= 0)
    assert(mid ~= nil and sid >= 0)

    -- 查询业务处理函数
    local method = manager.methods[sid]   
    assert(method ~= nil)
    if not method then
        local errmsg = "unknown " .. manager.servername .. " sid command" 
        skynet.error(errmsg)
        return nil, errmsg 
    end

    return method.func(content)
end

return manager