package.path = package.path .. ";./service/?.lua;"
local skynet = require("skynet")
local websocket = require("http.websocket")
local packet = require("network.packet")
require("proto_map")

local handle = {
    debug = 0
}

local msgs_switch = {
    [0x0000] = {
        name = "MDM_HEARTBEAT",
        [0x0000] = {
            name = "SUB_HEARTBEAT",
            dest = "心跳",
            req = nil,
            ack = nil,
            fn = function(sock_id, mid, sid, clientId, req)
                skynet.error("心跳", os.date("%Y-%m-%d %H:%M:%S", os.time()))
            end
        }
    },
    [0x0001] = {
        name = "MDM_CORE",
        [0x0001] = {
            name = "SUB_CORE_REGISTER",
            dest = "注册服务",
            req = proto_map.encode_ReqRegistService,
            ack = proto_map.encode_AckRegistService,
            fn = function(sock_id, mid, sid, clientId, req)
                dump(req, "ReqRegistService")

                local content =
                    proto_map.encode_AckRegService(
                    {
                        result = 0,
                        serverId = 10000,
                        errmsg = "客户端注册成功"
                    }
                )
                handle.send(sock_id, mid, sid, clientId, content)
            end
        }
    }
}

function handle.connect(sock_id)
    -- print("ws connect from: " .. tostring(sock_id))
end

function handle.handshake(sock_id, header, url)
    local addr = websocket.addrinfo(sock_id)
    print("ws handshake from", "addr=" .. addr, "url=" .. url)
    -- print("----header-----")
    -- for k, v in pairs(header) do
    --     print(k, v)
    -- end
    -- print("--------------")
end

function handle.message(sock_id, msg)
    local pk = packet:new()
    pk:unpack(msg)

    if handle.debug == 1 then
        skynet.error(
            "<: agent",
            "sock_id=" .. sock_id,
            "mid=" .. pk:mid(),
            "sid=" .. pk:sid(),
            "checkCode=" .. pk:checkCode(),
            "clientId=" .. pk:clientId(),
            "dataLen=" .. string.len(pk:data())
        )
    end

    local msgmap = msgs_switch[pk:mid()][pk:sid()]
    dump(msgmap, "msgmap")
    if msgmap then
        if msgmap.fn then
            local req = nil
            if msgmap.req and pk:data() then
                req = msgmap.req(pk:data())
            end
            local mid = pk:mid()
            local sid = pk:sid()
            local clientId = pk:clientId()
            skynet.fork(msgmap.fn, sock_id, mid, sid, clientId, req)
        end
    else
        skynet.error("<: pk", "mid=" .. pk:mid() .. ", sid=" .. pk:sid() .. "命令未实现")
    end
end

function handle.ping(sock_id)
    skynet.error("ws ping from: " .. tostring(sock_id) .. "\n")
end

function handle.pong(sock_id)
    skynet.error("ws pong from: " .. tostring(sock_id))
end

function handle.close(sock_id, code, reason)
    skynet.error("ws close from: " .. tostring(sock_id), code, reason)
end

function handle.error(sock_id)
    skynet.error("ws error from: " .. tostring(sock_id))
end

function handle.send(wsid, mid, sid, clientid, content)
    local pk = packet:new()
    pk:pack(mid, sid, clientid, content)
    if pk:data() == nil then
        skynet.error("packet create error")
        return 0, "packet create error"
    end
    websocket.write(wsid, pk:data(), "binary", 0x02)
    return 1, nil
end

skynet.init(
    function()
        skynet.error("ws_agent init ......")
    end
)

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, sock_id, protocol, addr)
            skynet.error(
                "accept",
                "session=" .. session,
                "address=" .. skynet.address(address),
                "sock_id=" .. sock_id,
                "protocol=" .. protocol,
                "addr=" .. addr
            )
            local ok, err = websocket.accept(sock_id, handle, protocol, addr)
            if not ok then
                skynet.error(err)
            end
        end
    )
end

skynet.start(dispatch)
