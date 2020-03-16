require("common.export")

SERVICE_CONFIG = {
    LOGON_SERVICE_ID = 1,  -- 登录服务
    MATCH_SERVICE_ID = 2,  -- 匹配服务
    ROOM_SERVICE_ID = 3, -- 房间服务
    REDIS_SERVICE_ID = 4, -- REDIS缓存服务
    DB_SERVICE_ID = 5, -- 数据服务
    LOGGER_SERVICE_ID = 6, -- 日志服务
}

 -- 服务内部协议
SERVICE_CMD = {
    [0x0004] = {
        name = "MDM_REDIS",
        desc = "REDIS缓存服务·主命令",
        [0x0001] = {name = "SUB_UPLOAD_MATCH_SERVER_INFOS", desc = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"},
        [0x0002] = {name = "SUB_UPDATE_ROOM_ONLINE_COUNT", desc = "更新房间服务器在线人数"}
    },
    [0x0005] = {
        desc = "数据服务·主命令",
        [0x0001] = {name = "SUB_UPLOAD_MATCH_SERVER_INFOS", desc = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"},
        [0x0002] = {name = "SUB_UPDATE_ROOM_ONLINE_COUNT", desc = "更新房间服务器在线人数"}
    },
}

-- dump(SERVICE_CONFIG, "SERVICE_CONFIG")

-- dump(SERVICE_CMD, "SERVICE_CMD")