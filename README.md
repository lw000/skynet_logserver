# skynet_logserver
日志服务器：
说明：
该程序结构使用单节点部署，服务内部包含子服务（匹配服务，房间服务，REDIS服务，DB服务），匹配服务，房间服务，模拟日志数据，发送redis服务，redis服务负责存储到redis，redis服务定时从redis中获取数据，写入到db服务，db服务负责数据的入库mysql

启动脚本 main.lua
match_server.lua 匹配服务
room_server.lua 房间服务
redis_server.lua REDIS服务
db_server.lua DB服务
