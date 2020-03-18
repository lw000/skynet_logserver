# skynet_logserver
日志服务器：
说明：
1. 该程序结构使用单节点部署，内部包含（匹配服务，房间服务，日志服务，REDIS服务，DB服务）子服务。
2. 匹配服务，房间服务，模拟日志数据，发送到log服务，log服务根据业务类型，转发到redis服务或者db服务。
3. redis服务负责数据存储到redis。
4. db服务负责数据存储到到mysql。

main.lua            单节点服务启动入口

代码结构
##### .
##### ├── common
##### │   ├── core.lua
##### │   ├── dump.lua
##### │   ├── export.lua
##### │   ├── function.lua
##### │   ├── trackback.lua
##### │   └── utils.lua
##### ├── config
##### │   └── config.lua
##### ├── core
##### │   └── define.lua
##### ├── db_server                     -- 数据库服务
##### │   ├── database
##### │   │   └── database.lua
##### │   ├── db_logic.lua
##### │   ├── db_manager.lua
##### │   └── db_server.lua
##### ├── log_server                    -- 日志服务
##### │   ├── log_logic.lua
##### │   ├── log_manager.lua
##### │   └── log_server.lua
##### ├── main_db.lua
##### ├── main_log.lua
##### ├── main.lua                      -- 主程序
##### ├── main_match.lua
##### ├── main_redis.lua
##### ├── main_room.lua
##### ├── match_server                  -- 匹配服务
##### │   ├── match_logic.lua
##### │   └── match_server.lua
##### ├── network
##### │   ├── packet.lua
##### │   └── ws.lua
##### ├── redis_server                  -- REDIS服务
##### │   ├── redis_logic.lua
##### │   ├── redis_manager.lua
##### │   └── redis_server.lua
##### ├── room_server                   -- 房间服务
##### │   ├── room_logic.lua
##### │   └── room_server.lua
##### └── skycommon
#####     └── helper.lua