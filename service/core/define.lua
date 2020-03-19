require("common.export")

-------------------------------------------------------------------------------------
-- 服务配置
SERVICE_CONF = {
    LOGON = { TYPE= 1, NAME= ".logon_server", DESC= "登录服务" },
    MATCH = { TYPE= 2, NAME= ".match_server", DESC= "匹配服务" },
    ROOM =  { TYPE= 3, NAME= ".room_server",  DESC= "房间服务" },
    REDIS = { TYPE= 4, NAME= ".redis_server", DESC= "缓存服务器" },
    DB =    { TYPE= 5, NAME= ".db_server",    DESC= "数据服务器" },
    LOG =   { TYPE= 6, NAME= ".log_server",   DESC= "日志服务器" },
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
