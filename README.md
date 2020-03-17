# skynet_logserver
日志服务器：
说明：
1. 该程序结构使用单节点部署，内部包含（匹配服务，房间服务，日志服务，REDIS服务，DB服务）子服务。
2. 匹配服务，房间服务，模拟日志数据，发送到log服务，log服务根据业务类型，转发到redis服务或者db服务。
3. redis服务负责数据存储到redis。
4. db服务负责数据存储到到mysql。

main.lua            启动入口
match_server.lua    匹配·服务
room_server.lua     房间·服务
redis_server.lua    REDIS·服务
db_server.lua       DB·服务
log_server.lua      日志·服务

代码结构
# .
# ├── common
# │   ├── core.lua
# │   ├── dump.lua
# │   ├── export.lua
# │   ├── function.lua
# │   ├── trackback.lua
# │   └── utils.lua
# ├── config
# │   └── config.lua
# ├── db_server             DB·服务
# │   ├── database
# │   │   └── database.lua
# │   ├── db_helper.lua
# │   └── db_server.lua
# ├── log_server            日志·服务
# │   ├── log_helper.lua
# │   └── log_server.lua
# ├── main.lua              启动入口
# ├── match_server          匹配·服务
# │   └── match_server.lua
# ├── network
# │   ├── packet.lua
# │   └── ws.lua
# ├── redis_server          REDIS·服务
# │   ├── redis_helper.lua
# │   └── redis_server.lua
# └── room_server           房间·服务
#     └── room_server.lua