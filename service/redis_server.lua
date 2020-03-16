package.path = package.path .. ";./service/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
local redis = require("skynet.db.redis")
local cjson = require("cjson")
require("skynet.manager")
require("common.export")
require("config.config")

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
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
	server_id = SERVICE_CONFIG.REDIS_SERVICE_ID, -- 服务ID
	running = false,
	redisdb = nil,
}

function command.START(conf)
    assert(conf ~= nil)
	command.redisdb = redis.connect(conf)
	assert(command.redisdb ~= nil)
    if command.redisdb == nil then
        return -1, "REDIS服务器·启动失败"
	end
	
	command.running = true

	-- skynet.fork(test_redis)

	local errmsg = "REDIS服务器·启动成功"
    return 0, errmsg
end

function command.STOP()
	command.running = false
	command.redisdb:disconnect()

	local errmsg = "REDIS服务器·停止成功"
    return 0, errmsg
end

function command.WRITEMESSAGE(mainId, subId, data)
	dump(data, "redis-data")
	if mainId == 0x0001 then	
	elseif mainId == 0x0002 then
		if subId == 0x0001 then	-- 更新匹配服务器状态
			local server_id = data.server_id -- 服务ID
			local jsondata = cjson.encode(data)
			dump(jsondata, "匹配服务器状态")
			skynet.error(command.redisdb:hset("match_service", server_id, jsondata))
		end
	elseif mainId == 0x0003 then
		if subId == 0x0001 then -- 更新房间在线人数
			local room_id = data.room_id -- 房间ID
			local jsondata = cjson.encode(data)
			dump(jsondata, "房间在线人数")
			skynet.error(command.redisdb:hset("room_service", room_id, jsondata))
		end
	elseif mainId == 0x0005 then
	elseif mainId == 0x0006 then
	else
		skynet.error("unknow command")
	end
	return 0
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
			elseif cmd == "WRITEMESSAGE" then
                local f = command[cmd]
                assert(f)
				skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format("unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".redis_server")
end

skynet.start(dispatch)
