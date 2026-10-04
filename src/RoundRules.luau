-- Pure game rules. No Roblox services: the same code runs in CLI tests and Studio.
local Rules = {}

function Rules.new(ids, killerId, now, duration, headStart)
    assert(#ids >= 2 and #ids <= 10, 'Rounds need 2 to 10 players')
    local members, alive = {}, {}
    for _, id in ipairs(ids) do
        assert(not members[id], 'Duplicate player')
        members[id] = true
        if id ~= killerId then alive[id] = true end
    end
    assert(members[killerId], 'Killer must be in the roster')
    assert(duration > 0 and headStart >= 0, 'Invalid round timing')
    return {
        members = members, alive = alive, killerId = killerId,
        chaseAt = now + headStart, endsAt = now + headStart + duration,
        result = nil,
    }
end

function Rules.count(state)
    local count = 0
    for _ in pairs(state.alive) do count += 1 end
    return count
end

function Rules.tick(state, now)
    if state.result then return state.result end
    -- The deadline wins ties. No late event can steal a survivor victory.
    if now >= state.endsAt then
        state.result = 'Survivors'
    elseif Rules.count(state) == 0 then
        state.result = 'Killer'
    end
    return state.result
end

function Rules.capture(state, attackerId, victimId, now)
    if Rules.tick(state, now) or now < state.chaseAt then return false end
    if attackerId ~= state.killerId or not state.alive[victimId] then return false end
    state.alive[victimId] = nil
    Rules.tick(state, now)
    return true
end

function Rules.remove(state, id, now)
    if Rules.tick(state, now) then return end
    if id == state.killerId then
        state.result = 'Cancelled'
    else
        state.alive[id] = nil
        Rules.tick(state, now)
    end
end

return Rules
