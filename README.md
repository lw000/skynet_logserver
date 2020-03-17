# skynet_logserver
日志服务器：
说明：
1. 该程序结构使用单节点部署，内部包含（匹配服务，房间服务，日志服务，REDIS服务，DB服务）子服务。
2. 匹配服务，房间服务，模拟日志数据，发送到log服务，log服务根据业务类型，转发到redis服务或者db服务。
3. redis服务负责数据存储到redis。
4. db服务负责数据存储到到mysql。

代码结构
.
├── common                      公共函数
│   ├── core.lua
│   ├── dump.lua
│   ├── export.lua
│   ├── function.lua
│   ├── trackback.lua
│   └── utils.lua
├── config                      服务配置
│   └── config.lua
├── database
│   └── database.lua            数据库接口
├── db_server                   DB服务
│   ├── db_helper.lua
│   └── db_server.lua
├── log_server                  日志服务
│   ├── log_helper.lua
│   └── log_server.lua
├── main.lua                    启动入口
├── match_server                匹配服务
│   └── match_server.lua
├── network                     
│   ├── packet.lua
│   └── ws.lua
├── redis_server                REDIS服务
│   ├── redis_helper.lua
│   └── redis_server.lua
└── room_server                 房间服务
    └── room_server.lua