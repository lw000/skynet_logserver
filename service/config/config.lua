require("common.export")

SERVICE_TYPE = {
    LOGON = 1,  -- 登录服务
    MATCH = 2,  -- 匹配服务
    ROOM = 3,   -- 房间服务
    REDIS = 4,  -- REDIS缓存服务
    DB = 5,     -- 数据服务
    LOG = 6,    -- 日志服务
}

 -- 服务内部协议
SERVICE_CMD = {
    [0x0004] = {
        name = "MDM_REDIS",
        desc = "REDIS服务·主命令",
        [0x0001] = {name = "SUB_UPLOAD_MATCH_SERVER_INFOS", desc = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"},
        [0x0002] = {name = "SUB_UPDATE_ROOM_ONLINE_COUNT", desc = "更新房间服务器在线人数"},
        [0x0003] = {name = "SUB_UPDATE_GAMELOG", desc = "玩家牌局日志"},
        [0x0004] = {name = "SUB_UPDATE_GAMESCORE", desc = "玩家分数日志"},
    },
    [0x0005] = {
        name = "MDM_DB",
        desc = "数据服务·主命令",
        [0x0001] = {name = "SUB_UPLOAD_MATCH_SERVER_INFOS", desc = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"},
        [0x0002] = {name = "SUB_UPDATE_ROOM_ONLINE_COUNT", desc = "更新房间服务器在线人数"},
        [0x0003] = {name = "SUB_UPDATE_GAMELOG", desc = "玩家牌局日志"},
        [0x0004] = {name = "SUB_UPDATE_GAMESCORE", desc = "玩家分数日志"},
    },
}

-- dump(SERVICE_TYPE, "SERVICE_TYPE")

-- dump(SERVICE_CMD, "SERVICE_CMD")