Plugins = {}


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- Helper function to get the ESX Identity object
function getIdentity(source)
    local identifier = GetIdentifiers(source)[Config.primaryIdentifier]
    if Config.primaryIdentifier == "steam" then
        identifier = ("steam:%s"):format(identifier)
    end
    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    if result[1] ~= nil then
        local identity = result[1]

        return {
            identifier = identity['identifier'],
            firstname = identity['firstname'],
            lastname = identity['lastname'],
            dateofbirth = identity['dateofbirth'],
            sex = identity['sex'],
            height = identity['height']
        }
    else
        return nil
    end
end

-- Toggles API sender.
RegisterServerEvent("cadToggleApi")
AddEventHandler("cadToggleApi", function()
    apiSendEnabled = not apiSendEnabled
end)

--[[
    Sonoran CAD API Handler - Core Wrapper
]]

function performApiRequest(postData, type, cb)
    -- apply required headers
    local payload = {}
    payload["id"] = communityID
    payload["key"] = apiKey
    payload["type"] = type
    payload["data"] = {postData}
    PerformHttpRequest(apiURL, function(statusCode, res, headers) 
        if statusCode == 200 and res ~= nil then
            debugPrint("result: "..tostring(res))
            cb(res)
        else
            print(("CAD API ERROR: %s %s"):format(statusCode, res))
        end
    end, "POST", json.encode(payload), {["Content-Type"]="application/json"})
end



-- Utility Functions

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function GetIdentifiers(player)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(player)) do
        local split = stringsplit(id, ":")
        ids[split[1]] = split[2]
    end
    return ids
end