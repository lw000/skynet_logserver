package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/match_server/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
local logic = require("match_logic")

require("skynet.manager")
require("common.export")
require("core.define")

--[[
    每秒将服务器状态实时写入到redis；
    服务器状态信息：匹配队列等待人数，已经成功匹配的次数；匹配时长
]]

local command = {
    servertype = SERVICE.TYPE.MATCH,    -- 服务类型
    servername = SERVICE.NAME.MATCH,  	-- 服务名
    match_server_id = -1,               -- 匹配服务器ID
    match_server_name = "",             -- 匹配服务器名称
    match_queue_length = 0,             -- 匹配队列等待人数
    match_success_count = 0,            -- 成功匹配的次数
    running_time = 0,                   -- 匹配时长
    start_time = 0,                     -- 启动时间
    running = false,                    -- 服务器状态
}

-- 服务启动·接口
function command.START(conf)
    assert(conf ~= nil)

    math.randomseed(os.time())

    command.match_server_id = conf.server_id
    command.match_server_name = conf.server_name
    assert(command.server_id ~= nil or command.server_id ~= -1)
    assert(command.server_name ~= nil or command.server_name ~= "")

    command.match_queue_length = 0             -- 匹配队列等待人数
    command.match_success_count = 0            -- 成功匹配的次数
    command.running_time = skynet.time()       -- 匹配时长
    command.start_time = skynet.time()         -- 启动时间
    command.running = true                     -- 服务器状态

    -- 匹配服务器·主业务
    skynet.fork(command._run)

    -- 上报服务器状态
    skynet.fork(command._uploadServerInfo)

    return 0
end

-- 服务停止·接口
function command.STOP()
    command.running = false
    
    return 0
end

-- 匹配服务器·主业务
function command._run()
    while command.running do
        local now = os.date("*t")
        if math.fmod(now.sec, 1) == 0 then               
            -- 匹配队列等待人数
            command.match_queue_length = math.random(100, 150)
            -- 匹配成功次数
            command.match_success_count = command.match_success_count + 1
            -- 运行时长
            command.running_time = skynet.time()
        end
        skynet.sleep(100)
    end
end

-- 报告服务器信息
function command._uploadServerInfo()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 按秒·上报
        if math.fmod(now.sec, 1) == 0 then
            -- skynet.error("系统时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))
            skynet.error("更新匹配服务器数据（匹配队列等待人数，已经成功匹配的次数，匹配时长）")
            local serverInfo = {
                server_id = command.match_server_id,                    -- 服务ID
                server_name = command.match_server_name,                -- 服务名字
                match_queue_length = command.match_queue_length,        -- 匹配队列等待人数
                match_success_count = command.match_success_count,      -- 成功匹配的次数
                match_time = command.running_time - command.start_time, -- 匹配时长
            }
            logic.updateServerInfo(serverInfo)
        end

        -- 获取用户信息
        if math.fmod(now.sec, 5) == 0 then
            -- skynet.error("查询用户信息")
            -- local result, err = logic.queryUserInfo({userId=10000})
            -- if err == nil then
            --     dump(result, "用户信息")
            -- else
            --     skynet.error(err)
            -- end
        end

        -- 按分钟·上报
        if now.sec == 0 and math.fmod(now.min, 1) == 0 then

        end
    end
end

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            local f = command[cmd]
            assert(f)
            if f then
                skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format(command.servername .. " unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(command.servername)
end

skynet.start(dispatch)
