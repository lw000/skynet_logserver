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

	-- 定时同步数据到dbserver
	skynet.fork(command._savetodbserver)

	local errmsg = "REDIS服务器·启动成功"
    return 0, errmsg
end

function command.STOP()
	command.running = false
	command.redisdb:disconnect()

	local errmsg = "REDIS服务器·停止成功"
    return 0, errmsg
end

-- 写数据到REDIS
function command.WRITEMESSAGE(mainId, subId, data)
	if mainId == 0x0004 then	
		if subId == 0x0001 then	-- 更新匹配服务器，匹配队列等待人数，已经成功匹配的次数，匹配时长
			local server_id = data.server_id -- 服务ID
			local jsondata = cjson.encode(data)
			skynet.error("更新匹配服务器状态", jsondata)
			local ok = command.redisdb:hset("match_service", server_id, jsondata)
			skynet.error("redis:", ok)
		elseif subId == 0x0002 then
			local room_id = data.room_id -- 更新房间服务器在线人数
			local jsondata = cjson.encode(data)
			skynet.error("更新房间服务器在线人数", jsondata)
			local ok = command.redisdb:hset("room_service", room_id, jsondata)
			skynet.error("redis:", ok)
		end
	else
		skynet.error("unknow command")
	end
	return 0
end

-- 定时同步数据到数据库
function command._savetodbserver()
    while command.running do
        skynet.sleep(100)

        local now = os.date("*t")
        -- dump(now, "系统时间")

        -- 按秒·汇报
        if math.fmod(now.sec, 30) == 0 then
            -- skynet.error("系统时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))

            skynet.error("存储数据到dbserver")
			
			local db_server_id = skynet.localname(".db_server")
			assert(db_server_id > 0)

			local exists = command.redisdb:exists("match_service")
			if exists then
				local r = command.redisdb:hvals("match_service")
				for k,v in pairs(r) do
					print(k,v)
				end
				skynet.send(db_server_id, "lua", "writeMessage", 0x0005, 0x0001, [[{"a"=1}]])
			end

			local exists = command.redisdb:exists("room_service")
			if exists then
				local r = command.redisdb:hvals("room_service")
				for k,v in pairs(r) do
					print(k,v)
				end
				skynet.send(db_server_id, "lua", "writeMessage", 0x0005, 0x0002, [[{"a"=1}]])
			end
            
        end

        -- 按分钟·汇报
        if now.sec == 0 and math.fmod(now.min, 1) == 0 then

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
			elseif cmd == "WRITEMESSAGE" then
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
