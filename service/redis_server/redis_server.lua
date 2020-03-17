package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/redis_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local redis = require("skynet.db.redis")
local redishelper = require("redis_helper")

require("skynet.manager")
require("common.export")
require("config.config")

local conf = {
	host = "127.0.0.1" ,
	port = 6379,
	db = 0
}

local function watching()
	local w = redis.watch(conf)
	w:subscribe "foo"
	w:psubscribe "hello.*"
	while true do
		print("Watch", w:message())
	end
end

local function test_redis()
	local db = redis.connect(conf)

	db:del "C"
	db:set("A", "hello")
	db:set("B", "world")
	db:sadd("C", "one")

	print(db:get("A"))
	print(db:get("B"))

	db:del "D"
	for i=1,10 do
		db:hset("D",i,i)
	end
	local r = db:hvals "D"
	for k,v in pairs(r) do
		print(k,v)
	end

	db:multi()
	db:get "A"
	db:get "B"
	local t = db:exec()
	for k,v in ipairs(t) do
		print("Exec", v)
	end

	print(db:exists "A")
	print(db:get "A")
	print(db:set("A","hello world"))
	print(db:get("A"))
	print(db:sismember("C","one"))
	print(db:sismember("C","two"))

	print("===========publish============")

	for i=1,10 do
		db:publish("foo", i)
	end
	for i=11,20 do
		db:publish("hello.foo", i)
	end

	db:disconnect()
--	skynet.exit()
end

local command = {
	server_type = SERVICE_TYPE.REDIS, 	-- 服务ID
	running = false,					-- 服务器状态
	redisConn = nil,					-- redis连接
	syncinterval = 30, 					-- 同步DB时间间隔，秒·单位
	conf = {}, 							-- redis配置
	methods = {} 						-- 业务处理接口映射表
}

function command.START(conf)
	assert(conf ~= nil)
	command.conf = conf
	command.methods = {}
	command.redisConn = redis.connect(command.conf)
	assert(command.redisConn ~= nil)
    if command.redisConn == nil then
        return -1, "redisserver start fail"
	end
	
	math.randomseed(os.time())
	
	command.running = true

	command.registerMethods()

	-- 定时同步数据到dbserver
	skynet.fork(command._syncdbserver)

	local errmsg = "redisserver start"
    return 0, errmsg
end

function command.STOP()
	command.running = false
	command.methods = {}
	command.redisConn:disconnect()
	command.redisdb = nil

	local errmsg = "redisserver stop"
    return 0, errmsg
end

function command.registerMethods()
    command.methods[0x0001] = {func = redishelper.saveMatchServerInfo, desc="同步匹配服务器数据"}
    command.methods[0x0002] = {func = redishelper.saveRoomServerOnlineCount, desc="更新房间在线用户数"}
    -- dump(command.methods, "redis_server.command.methods")
end

-- 写数据到REDIS
function command.MESSAGE(mid, sid, content)
	skynet.error(string.format("redis_server mid=%d, sid=%d", mid, sid))

	if mid ~= REDIS_CMD.MDM_REDIS then
		skynet.error("unknow redis_server message command")
		return -1
	end

    -- 查询业务处理函数
    local method = command.methods[sid]
    assert(method ~= nil)
    if method then
        local ret, err = method.func(command.redisConn, content)
        if err ~= nil then
            skynet.error(err)
            return 1
        end
    end
	return 0
end

-- 定时同步数据到数据库
function command._syncdbserver()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 按秒·同步数据到DB
		if math.fmod(now.sec, command.syncinterval) == 0 then
			
			-- 1. 同步匹配服务器数据
			-- redishelper.syncMatchServerInfo(command.redisConn)
			skynet.fork(redishelper.syncMatchServerInfo, command.redisConn)

			-- 2. 同步房间服务器数据
			-- redishelper.syncRoomServerOnlineCount(command.redisConn)
			skynet.fork(redishelper.syncRoomServerOnlineCount, command.redisConn)
        end
    end
end

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            if cmd == "START" then
                local f = command[cmd]
                assert(f)
                skynet.ret(skynet.pack(f(...)))
            elseif cmd == "STOP" then
                local f = command[cmd]
                assert(f)
				skynet.ret(skynet.pack(f(...)))
			elseif cmd == "MESSAGE" then
                local f = command[cmd]
                assert(f)
				skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format("redis_server unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".redis_server")
end

skynet.start(dispatch)
