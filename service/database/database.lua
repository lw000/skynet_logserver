local skynet = require("skynet")
local mysql = require("skynet.db.mysql")

local database = {}

local function on_connect(db)
    db:query("set charset utf8mb4")
end

-- 打开数据库连接
function database.mysql_open(conf)
    local db =
        mysql.connect(
        {
            host = conf["host"],
            port = conf["port"],
            database = conf["database"],
            user = conf["user"],
            password = conf["password"],
            max_packet_size = 1024 * 1024,
            on_connect = on_connect
        }
    )

    if not db then
        skynet.error("failed to connect gamedata")
        return nil
    end

    skynet.error("success to connect to mysql server")

    return db
end

-- 关闭数据库连接
function database.mysql_close(dbconn)
    if dbconn then
        dbconn:disconnect()
    end
end

function database.mysql_query(dbconn, sql)
    local results = dbconn:query(sql)
    if results.err then
        skynet.error("error: sql execute, " .. results.err)
        return nil, results.err
    end
    return results
end

function database.mysql_execute(dbconn, sql, ...)
    local stmt = dbconn:prepare(sql)
    if stmt.err then
        skynet.error("error: sql prepare, " .. stmt.err)
        return nil, stmt.err
    end
    local results = dbconn:execute(stmt, ...)
    dbconn:stmt_close(stmt)
    if results.err then
        skynet.error("error: sql execute, " .. results.err)
        return nil, results.err
    end
    return results
end


return database