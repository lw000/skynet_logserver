local pb = require("protobuf")
local skynet = require("skynet")

local pbfiles = {
    "protos/service.pb"
}

proto_map = proto_map or {}

function proto_map.registerFiles(...)
    local args = {...}
    for i = 1, #args do
        pb.register_file(args[i])
        skynet.error("注册protobuf协议 " .. i .. " [" .. args[i] .. "]")
    end
end

function proto_map.encode_ReqRegService(t)
    return pb.encode("Tws.ReqRegService", t)
end

function proto_map.decode_ReqRegService(data)
    return pb.decode("Tws.ReqRegService", data)
end

function proto_map.encode_AckRegService(t)
    return pb.encode("Tws.AckRegService", t)
end

function proto_map.decode_AckRegService(data)
    return pb.decode("Tws.AckRegService", data)
end

local function init()
    for i, c in pairs(pbfiles) do
        proto_map.registerFiles(c)
    end
end

init()
