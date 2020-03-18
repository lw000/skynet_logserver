require("common.export")

-------------------------------------------------------------------------------------
SERVICE = {
    -- 服务器类型
    TYPE = {
        LOGON   = 1,    -- 登录服务
        MATCH   = 2,    -- 匹配服务
        ROOM    = 3,    -- 房间服务
        REDIS   = 4,    -- REDIS缓存服务
        DB      = 5,    -- DB服务
        LOG     = 6,    -- 日志服务
    },
    -- 服务名字
    NAME = {
        LOGON   = ".logon_server",      -- 登录服务
        MATCH   = ".match_server",      -- 匹配服务
        ROOM    = ".room_server",       -- 房间服务
        REDIS   = ".redis_server",      -- REDIS缓存服务
        DB      = ".db_server",         -- DB服务
        LOG     = ".log_server",        -- 日志服务
    }
}

-- 服务内部协议指令
-------------------------------------------------------------------------------------
-- DB服务·命令
DB_CMD = {
    MDM_DB = 0x0005,                            -- DB服务·主命令
    SUB_UPDATE_MATCH_SERVER_INFOS = 0x0001,     -- 更新匹配服务器（匹配队列等待人数，已经成功匹配的次数，匹配时长）
    SUB_UPDATE_ROOM_SERVER_INFOS = 0x0002,      -- 更新房间服务器（在线人数）
    SUB_GAME_LOG = 0x0003,                      -- 玩家牌局日志
    SUB_GAME_SCORE_CHANGE_LOG = 0x0004,         -- 玩家分数日志
    SUB_USER_INFO = 0x0005,                     -- 获取用户信息
}

-- REDIS服务·命令
REDIS_CMD = {
    MDM_REDIS = 0x0004,                         -- REDIS服务·主命令
    SUB_UPDATE_MATCH_SERVER_INFOS = 0x0001,     -- 更新匹配服务器（匹配队列等待人数，已经成功匹配的次数，匹配时长）
    SUB_UPDATE_ROOM_SERVER_INFOS = 0x0002,      -- 更新房间服务器（在线人数）
}

-- 日志服务·命令
LOG_CMD = {
    MDM_LOG = 0x0006,                           --日志服务·主命令
    SUB_UPDATE_MATCH_SERVER_INFOS = 0x0001,     -- 更新匹配服务器（匹配队列等待人数，已经成功匹配的次数，匹配时长）
    SUB_UPDATE_ROOM_SERVER_INFOS = 0x0002,      -- 更新房间服务器（在线人数）
    SUB_GAME_LOG = 0x0003,                      -- 玩家牌局日志
    SUB_GAME_SCORE_CHANGE_LOG = 0x0004,         -- 玩家分数日志
    SUB_USER_INFO = 0x0005,                     -- 获取用户信息
}

-- dump(SERVICE, "SERVICE")
-- dump(DB_CMD, "DB_CMD")
-- dump(LOG_CMD, "LOG_CMD")
-- dump(REDIS_CMD, "REDIS_CMD")
