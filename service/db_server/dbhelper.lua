local skynet = require("skynet")
local database = require("database.database")

local dbhelper = {

}

function dbhelper.queryUserInfo(dbconn)
    local sql = [[select * from user]]
    local result, err = database.query(dbconn, sql)
    if err ~= nil then
        skynet.error(err)
        return nil, err
    end
    return result, nil
end

return dbhelper