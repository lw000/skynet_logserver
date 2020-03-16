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
    [0x0002] = {
        dest = "匹配服务·主命令",
        [0x0001] = {
            dest = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"
        }
    },
    [0x0003] = {
        dest = "房间服务·主命令",
        [0x0001] = {
            dest = "更新房间服务器在线人数"
        }
    },
    [0x0004] = {
        dest = "REDIS缓存服务·主命令",
        [0x0001] = {
            dest = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"
        },
        [0x0002] = {
            dest = "更新房间服务器在线人数"
        }
    },
    [0x0005] = {
        dest = "数据服务·主命令",
        [0x0001] = {
            dest = "更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长"
        },
        [0x0002] = {
            dest = "更新房间服务器在线人数"
        }
    },
}

-- dump(SERVICE_CONFIG, "SERVICE_CONFIG")

-- dump(SERVICE_CMD, "SERVICE_CMD")