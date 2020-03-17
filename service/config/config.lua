require("common.export")

-- 服务器ID分配
SERVICE_TYPE = {
    LOGON = 1,  -- 登录服务
    MATCH = 2,  -- 匹配服务
    ROOM = 3,   -- 房间服务
    REDIS = 4,  -- REDIS缓存服务
    DB = 5,     -- 数据服务
    LOG = 6,    -- 日志服务
}

-- 服务名字
SERVER_NAME = {
    LOG = ".log_server",
    DB = ".db_server",
    REDIS = ".redis_server",
    MATCH = ".match_server",
    ROOM = ".room_server",
}

-- 服务内部协议指令

-- DB服务命令
DB_CMD = {
    MDM_DB = 0x0005,                            -- DB服务·主命令
    SUB_UPDATE_MATCH_SERVER_INFOS = 0x0001,     -- 更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长
    SUB_UPDATE_ROOM_ONLINE_COUNT = 0x0002,      -- 更新房间服务器在线人数
    SUB_GAME_LOG = 0x0003,                      -- 玩家牌局日志
    SUB_GAME_SCORE_CHANGE_LOG = 0x0004,         -- 玩家分数日志
}

-- REDIS服务命令
REDIS_CMD = {
    MDM_REDIS = 0x0004,                         -- REDIS服务·主命令
    SUB_UPDATE_MATCH_SERVER_INFOS = 0x0001,     -- 更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长
    SUB_UPDATE_ROOM_ONLINE_COUNT = 0x0002,      -- 更新房间服务器在线人数
}

-- 日志服务命令
LOG_CMD = {
    MDM_LOG = 0x0006,                           --日志服务·主命令
    SUB_UPDATE_MATCH_SERVER_INFOS = 0x0001,     -- 更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长
    SUB_UPDATE_ROOM_ONLINE_COUNT = 0x0002,      -- 更新房间服务器在线人数
    SUB_GAME_LOG = 0x0003,                      -- 玩家牌局日志
    SUB_GAME_SCORE_CHANGE_LOG = 0x0004,         -- 玩家分数日志
}

-- dump(SERVICE_TYPE, "SERVICE_TYPE")
-- dump(DB_CMD, "DB_CMD")
-- dump(REDIS_CMD, "REDIS_CMD")
-- dump(LOG_CMD, "LOG_CMD")
dump(SERVER_NAME, "SERVER_NAME")