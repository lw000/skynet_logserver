package.path = package.path .. ";./service/?.lua;"
local skynet = require("skynet")
local service = require("skynet.service")
local ws = require("network.ws")
require("skynet.manager")
require("common.export")
require("proto_map")

local SVR_TYPE = {
    ServerType = 6
}

local command = {
    scheme = "",
    host = 0,
    running = false,
    client = ws:new()
}

local msgs_switch = {
    [0x0000] = {
        [0x0000] = {
            name = "心跳消息",
            fn = function(conn, pk)
                skynet.error("心跳消息", os.date("%Y-%m-%d %H:%M:%S", os.time()))
            end
        }
    },
    [0x0001] = {
        name = "MDM_CORE",
        [0x0001] = {
            name = "SUB_CORE_REGISTER",
            fn = function(conn, pk)
                local data = proto_map.decode_AckRegistService(pk:data())
                if data.result == 0 then
                    skynet.error(
                        "服务注册成功",
                        "result=" .. data.result .. ", serverId=" .. data.serverId .. ", errmsg=" .. data.errmsg
                    )
                end
            end
        }
    }
}

function command.START(scheme, host)
    command.scheme = scheme
    command.host = host
    command.client:handleMessage(command.onMessage)
    command.client:handleError(command.onError)
    local ok, err = command.client:connect(scheme, host)
    if err then
        return 1, "网络服务启动失败"
    end
    command.registerService(SVR_TYPE.ServerType)
    command.running = true
    command.alive()
    return 0, "网络服务启动成功"
end

function command.registerService(serverType)
    local content =
        proto_map.encode_ReqRegService(
        {
            serverId = command.client:serverId(),
            svrType = serverType
        }
    )
    local on_cb_regservice = function(conn, pk)
        local data = proto_map.decode_AckRegService(pk:data())
        dump(data, "AckRegistService")
        if data.result == 0 then
            print("code=" .. data.result, "serverId=" .. data.serverId, "errmsg=" .. data.errmsg)
        end
    end
    command.client:registerService(0x0001, 0x0001, content, on_cb_regservice)
end

function command.alive()
    skynet.fork(
        function()
            while command.running do
                local checking = command.client:open()
                if not checking then
                    skynet.error("断线重连")
                    command.client:connect(command.scheme, command.host)
                    command.registerService(SVR_TYPE.ServerType)
                end
                skynet.sleep(100 * 3)
            end
        end
    )
end

function command.onMessage(conn, pk)
    local msgmap = msgs_switch[pk:mid()][pk:sid()]
    if msgmap then
        if msgmap.fn ~= nil then
            skynet.fork(msgmap.fn, self, pk)
        -- msgmap.fn(self, pk)
        end
    else
        print("<: pk", "mid=" .. pk:mid() .. ", sid=" .. pk:sid() .. "命令未实现")
    end
end

function command.onError(err)
    skynet.error(err)
end

skynet.init(
    function()
        skynet.error("ws_client init ......")
    end
)

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            if cmd == "START" then
                local f = command[cmd]
                assert(f)
                skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format("unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".ws_client")
end

skynet.start(dispatch)
