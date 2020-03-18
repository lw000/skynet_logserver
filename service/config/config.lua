require("common.export")

local config = {
    -- 调试控制台端口
    debug_port = 8000,
    -- db配置
    db = {
        host_ = "127.0.0.1",
        host = "192.168.0.102",
        port = 3306,
        database = "test",
        user = "root",
        password_ = "LEvi123!",
        password = "lwstar",
    },
    --redis配置
    redis = {
        host = "127.0.0.1",
        port = 6379,
        db = 0,
    }
}

dump(config, "config")

return config