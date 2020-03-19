package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/redis_server/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local redis = require("skynet.db.redis")
local logic = require("redis_logic")
local redismgr = require("redis_manager")
require("skynet.manager")
require("common.export")
require("core.define")

local command = {
	servertype = SERVICE.TYPE.REDIS, 	-- 服务类型
	servername = SERVICE.NAME.REDIS,  	-- 服务名
	running = false,					-- 服务器状态
	redisConn = nil,					-- redis连接
	syncInterval = 30, 					-- 同步DB时间（单位·秒）
	conf = nil, 						-- redis配置
}

function command.START(conf)
	assert(conf ~= nil)
	command.conf = conf
	command.redisConn = redis.connect(command.conf)
	assert(command.redisConn ~= nil)
    if command.redisConn == nil then
        return 1, command.servername .. " fail"
	end
	
	math.randomseed(os.time())
	
	command.running = true

	redismgr.start(command.servername)

	-- 定时同步数据到dbserver
	skynet.fork(
		function(...)
			local ok = xpcall(
				command._syncToDbserver,
				__G__TRACKBACK__
			)
			if ok then
				skynet.error("_syncToDbserver exit")
			end
		end
	)
    return 0
end

function command.STOP()
	command.running = false
	
	redismgr.stop()

	command.redisConn:disconnect()
	command.redisdb = nil

    return 0
end

-- REDIS服务·消息处理接口
function command.MESSAGE(mid, sid, content)
	-- skynet.error(string.format(command.servername .. ":> mid=%d sid=%d", mid, sid))

	if mid ~= REDIS_CMD.MDM_REDIS then
		local errmsg = "unknown " .. command.servername .. " message command"
		skynet.error(errmsg)
		return -1, errmsg
	end

	return redismgr.dispatch(command.redisConn, mid, sid, content)
end

-- 定时同步数据到数据库
function command._syncToDbserver()
    while command.running do
		skynet.sleep(100)
			
		local now = os.date("*t")
        -- dump(now, "系统时间")

		-- 每30秒同步一次配服务器和房间服务器数据
		if math.fmod(now.sec, command.syncInterval) == 0 then
			-- 1. 同步匹配服务器数据
			skynet.fork(logic.syncMatchServerInfoToDB, command.redisConn)

			-- 2. 同步房间服务器数据
			skynet.fork(logic.syncRoomServerInfoToDB, command.redisConn)
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
