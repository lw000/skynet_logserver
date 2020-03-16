require("common.export")

SERVICE_CONFIG = {
    LOGON_SERVICE_ID = 1,  -- 登录服务
    MATCH_SERVICE_ID = 2,  -- 匹配服务
    ROOM_SERVICE_ID = 3, -- 房间服务
    REDIS_SERVICE_ID = 4, -- REDIS缓存服务
    DB_SERVICE_ID = 5, -- 数据服务
    LOGGER_SERVICE_ID = 6, -- 日志服务
}

SERVICE_CMD = {
    [0x0001] = {
        name = "登录服务主命令",
        [0x0001] = {
            name = "更新服务器状态"
        }
    },
    [0x0002] = {
        name = "匹配服务主命令",
        [0x0001] = {
            name = "更新匹配服务器状态"
        }
    },
    [0x0003] = {
        name = "房间服务主命令",
        [0x0001] = {
            name = "更新房间在线人数状态"
        }
    } 
}

-- dump(SERVICE_CONFIG, "SERVICE_CONFIG")

-- dump(SERVICE_CMD, "SERVICE_CMD")