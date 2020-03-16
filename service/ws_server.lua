package.path = package.path .. ";./service/?.lua;"

local skynet = require("skynet")
local socket = require("skynet.socket")
local service = require("skynet.service")
require("skynet.manager")
require("config.config")

local command = {
    server_id = SERVICE_CONFIG.LOGGER_SERVICE_ID, -- 服务ID
    sfd = -1;
    agents = {}
}

function command.START(port)
    local protocol = "ws"
    command.sfd = socket.listen("0.0.0.0", port)
    assert(command.sfd ~= -1)

    skynet.error(string.format("websocket listen port: " .. port .. " protocol:%s", protocol))

    socket.start(
        command.sfd,
        function(id, addr)
            print(string.format("accept client socket_id: %s addr:%s", id, addr))

            local agent_id = skynet.newservice("ws_agent")
            command.agents[agent_id] = agent_id
            skynet.send(agent_id, "lua", id, protocol, addr)
        end
    )
    local errmsg = "websocket server start"
    return 0, errmsg
end

function command.STOP()
    socket.close(command.sfd)
    local errmsg = "websocket server stop"
    return 0, errmsg
end

skynet.start(
    function()
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
                else
                    skynet.error(string.format("unknown command %s", tostring(cmd)))
                end
            end
        )
        skynet.register(".ws_server")
    end
)
