require("common.export")

local config = {
    -- 调试控制台端口
    debugPort = 8000,
    -- db配置
    db = {
        host = "127.0.0.1",
        host_ = "192.168.0.102",
        port = 3306,
        database = "test",
        user = "root",
        password = "LEvi123!",
        password_ = "lwstar",
    },
    --redis配置
    redis = {
        host = "127.0.0.1",
        port = 6379,
        db = 0,
    }
}

-- dump(config, "config")

return config