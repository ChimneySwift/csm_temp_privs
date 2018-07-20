local modstorage = minetest.get_mod_storage()

local serverinfo = minetest.get_server_info()
local serverstr = (serverinfo.ip or "0.0.0.0")..":"..(serverinfo.port or 30000)

local queue = minetest.deserialize(modstorage:get_string("queue_"..serverstr)) or {}

local unit_to_secs = {
    s = 1,
    m = 60,
    h = 3600,
    D = 86400,
    W = 604800,
    M = 2592000,
    Y = 31104000,
}

local function parse_time(t) --> secs
    local secs = 0
    for num, unit in t:gmatch("(%d+)([smhDWMY]?)") do
        secs = secs + (tonumber(num) * (unit_to_secs[unit] or 1))
    end
    return secs
end

local function queue_reversal(name, privstr, after, grant) -- To grant when time is up or revoke? (grant=true to grant, grant=false to revoke)
    local trig_time = os.time() + parse_time(after)

    table.insert(queue, {time=trig_time, privs=privstr, name=name, grant=grant})
    modstorage:set_string("queue_"..serverstr, minetest.serialize(queue))
end

minetest.register_chatcommand("tgrant", {
    description = "Temporarily grant privs.",
    params = "<name> <privs> <time>",
    func = function(param)
        local name, privs, time = param:match("(%S+)%s+(%S+)%s+(.+)")

        if not (name and privs and time) then
            return false, "Invalid parameters"
        end

        queue_reversal(name, privs, time, false)
        minetest.run_server_chatcommand("grant", name.." "..privs)
    end,
})

minetest.register_chatcommand("trevoke", {
    description = "Temporarily revoke privs.",
    params = "<name> <privs> <time>",
    func = function(param)
        local name, privs, time = param:match("(%S+)%s+(%S+)%s+(.+)")

        if not (name and privs and time) then
            return false, "Invalid parameters"
        end

        queue_reversal(name, privs, time, true)
        minetest.run_server_chatcommand("revoke", name.." "..privs)
    end,
})

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime

    if timer >= 1 then
        timer = 0

        local curr_time = os.time()

        for i, action in pairs(queue) do
            if action.time <= curr_time then
                minetest.run_server_chatcommand((action.grant and "grant" or "revoke"), action.name.." "..action.privs)
                table.remove(queue, i)
                modstorage:set_string("queue_"..serverstr, minetest.serialize(queue))
            end
        end
    end
end)