# skynet_logserver

# 日志服务器：

## 概要
    1. 该程序单节点部署，内部包含（匹配服务，房间服务，日志服务，REDIS服务，DB服务）子服务。
    2. 匹配服务，房间服务，模拟日志数据发送到log服务，log服务根据业务类型，转发到redis服务或者db服务。
    3. redis服务负责数据存储到redis, redis服务定时把（匹配服务，房间服务）数据同步到DB服务。
    4. db服务负责数据存储到到mysql。

## 部署
    1. centos x64位系统
    2. 安装redis
    3. 安装mysql
    4. 导入数据库脚本sql/test.sql
    5. config/config.lua 修改配置数据库和redis的相关配置

##  启动
    cd skynet_logserver
    bin/skynet conf/config

## 代码基本说明
    1. main.lua 单节点服务启动入口
    2. common 文件夹公共函数库
    3. config 配置文件夹
    4. core下配置服务类型，服务名字，已经服务间指令
    5. db_server文件夹下存放数据服务代码
    6. log_server文件夹下存放日志服务代码
    7. match_server文件夹下存放匹配服务代码
    8. redis_server文件夹下存放缓存服务代码
    9. room_server文件夹下存放房间服务代码
    10. skycommon文件夹下存放发送消息代码

## 代码结构

#### .
#### ├── common
#### │   ├── core.lua
#### │   ├── dump.lua
#### │   ├── export.lua
#### │   ├── function.lua
#### │   ├── trackback.lua
#### │   └── utils.lua
#### ├── config
#### │   └── config.lua
#### ├── core
#### │   └── define.lua
#### ├── db_server                     -- 数据库服务
#### │   ├── database
#### │   │   └── database.lua
#### │   ├── db_logic.lua
#### │   ├── db_manager.lua
#### │   └── db_server.lua
#### ├── log_server                    -- 日志服务
#### │   ├── log_logic.lua
#### │   ├── log_manager.lua
#### │   └── log_server.lua
#### ├── main_db.lua
#### ├── main_log.lua
#### ├── main.lua                      -- 主程序
#### ├── main_match.lua
#### ├── main_redis.lua
#### ├── main_room.lua
#### ├── match_server                  -- 匹配服务
#### │   ├── match_logic.lua
#### │   └── match_server.lua
#### ├── redis_server                  -- REDIS服务
#### │   ├── redis_logic.lua
#### │   ├── redis_manager.lua
#### │   └── redis_server.lua
#### ├── room_server                   -- 房间服务
#### │   ├── room_logic.lua
#### │   └── room_server.lua
#### └── skycommon
####     └── helper.lua