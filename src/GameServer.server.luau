local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Rules = require(script.Parent:WaitForChild('RoundRules'))
local Config = { RoundSeconds = 300, HeadStart = 15, Intermission = 20, MaxPlayers = 10 }
local state = ReplicatedStorage:WaitForChild('MansionState')
local map = workspace:WaitForChild('Mansion')
local spawnFolder = workspace:WaitForChild('SurvivorSpawns')
local lobbySpawn = workspace:WaitForChild('LobbySpawn')
local killerSpawn = workspace:WaitForChild('KillerSpawn')
local entranceSpawn = workspace:WaitForChild('EntranceSpawn')
map:WaitForChild('Ceiling').Transparency = 0
local random = Random.new()
local round = nil
local touchConnections = {}
local loading = {}
local function now() return workspace:GetServerTimeNow() end
local function setRole(player, role) player:SetAttribute('MansionRole', role) end
local function setPhase(phase, endsAt, message)
    state:SetAttribute('Phase', phase)
    state:SetAttribute('EndsAt', endsAt or 0)
    state:SetAttribute('Message', message or '')
end
local function humanoid(player)
    return player.Character and player.Character:FindFirstChildOfClass('Humanoid')
end
local function root(player)
    return player.Character and player.Character:FindFirstChild('HumanoidRootPart')
end
local function teleport(player, destination)
    if player.Character and root(player) then
        root(player).AssemblyLinearVelocity = Vector3.zero
        root(player).AssemblyAngularVelocity = Vector3.zero
        player.Character:PivotTo(destination.CFrame + Vector3.new(0, 4, 0))
    end
end
local function updateAlive()
    state:SetAttribute('Alive', round and Rules.count(round) or 0)
end
local function retire(player)
    setRole(player, 'Spectator')
    teleport(player, lobbySpawn)
    local playerRoot = root(player)
    if playerRoot then playerRoot.Anchored = true end
    updateAlive()
end
local function safeReload(player)
    if loading[player] or player.Parent ~= Players then return end
    loading[player] = true
    task.spawn(function()
        local ok, err = pcall(function() player:LoadCharacterAsync() end)
        loading[player] = nil
        if not ok then warn('Could not reload ' .. player.Name .. ': ' .. tostring(err)) end
    end)
end

local function dressKiller(player)
    local character = player.Character
    if not character then return end
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA('Accessory') or item:IsA('Shirt') or item:IsA('Pants')
            or item:IsA('ShirtGraphic') or item:IsA('BodyColors') then
            item:Destroy()
        elseif item:IsA('BasePart') and item.Name ~= 'HumanoidRootPart' then
            item.Color = Color3.fromRGB(28, 36, 44)
            item.Material = Enum.Material.SmoothPlastic
        end
    end
    local head = character:FindFirstChild('Head')
    if not head then return end
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA('Decal') then child:Destroy() end
    end
    local function facePart(name, size, offset, color)
        local part = Instance.new('Part')
        part.Name, part.Size, part.Color = name, size, color
        part.CanCollide, part.CanTouch, part.CanQuery, part.Massless = false, false, false, true
        part.CFrame = head.CFrame * CFrame.new(offset)
        part.Parent = character
        local weld = Instance.new('WeldConstraint')
        weld.Part0, weld.Part1, weld.Parent = head, part, part
    end
    local width, height, depth = head.Size.X, head.Size.Y, head.Size.Z
    facePart('WhiteMask', Vector3.new(width * 0.8, height * 0.94, 0.16),
        Vector3.new(0, 0, -depth / 2 - 0.06), Color3.fromRGB(223, 221, 207))
    for _, x in ipairs({-0.2, 0.2}) do
        facePart('MaskEye', Vector3.new(width * 0.16, height * 0.12, 0.06),
            Vector3.new(width * x, height * 0.1, -depth / 2 - 0.16), Color3.fromRGB(10, 10, 12))
    end
    facePart('MaskMouth', Vector3.new(width * 0.22, height * 0.04, 0.06),
        Vector3.new(0, -height * 0.24, -depth / 2 - 0.16), Color3.fromRGB(55, 53, 50))
end

local function catchTouch(killer, other)
    local activeRound = round
    if not activeRound or activeRound.result then return end
    local character = other:FindFirstAncestorOfClass('Model')
    local victim = character and Players:GetPlayerFromCharacter(character)
    -- Accessories alone don't count as touching someone's body.
    if not victim or other.Parent ~= victim.Character or victim == killer then return end
    local killerRoot, victimRoot = root(killer), root(victim)
    local killerHumanoid, victimHumanoid = humanoid(killer), humanoid(victim)
    if not killerRoot or not victimRoot or not killerHumanoid or not victimHumanoid then return end
    if killerHumanoid.Health <= 0 or victimHumanoid.Health <= 0 then return end
    local displacement = victimRoot.Position - killerRoot.Position
    if displacement.Magnitude > 7 then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {map}
    if workspace:Raycast(killerRoot.Position, displacement, params) then return end
    if Rules.capture(activeRound, killer.UserId, victim.UserId, now()) then
        retire(victim)
    end
end

local function onCharacter(player, character)
    local h = character:WaitForChild('Humanoid', 10)
    local r = character:WaitForChild('HumanoidRootPart', 10)
    if not h or not r or player.Character ~= character then return end
    h.WalkSpeed = 16
    h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    -- An unexpected replacement character never re-enters an active round.
    if round and round.characters[player.UserId] ~= character and round.members[player.UserId] then
        Rules.remove(round, player.UserId, now())
        setRole(player, 'Spectator')
        updateAlive()
    end
    teleport(player, lobbySpawn)
    if player:GetAttribute('MansionRole') == 'Spectator' then r.Anchored = true end
    if not round and RunService:IsStudio() and #Players:GetPlayers() == 1 then
        local spawn = spawnFolder:FindFirstChild('01')
        if spawn then teleport(player, spawn) end
    end
    h.Died:Connect(function()
        if round and round.characters[player.UserId] == character then
            Rules.remove(round, player.UserId, now())
            setRole(player, 'Spectator')
            updateAlive()
        end
    end)
end

local function addPlayer(player)
    setRole(player, 'Waiting')
    player.CharacterAdded:Connect(function(character) onCharacter(player, character) end)
    if player.Character then task.spawn(onCharacter, player, player.Character) end
end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player)
    loading[player] = nil
    if round then
        Rules.remove(round, player.UserId, now())
        updateAlive()
    end
end)
for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end

local function readyPlayers()
    local ready = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local h = humanoid(player)
        if not loading[player] and h and h.Health > 0 and root(player)
            and player:HasAppearanceLoaded() then
            table.insert(ready, player)
        end
    end
    return ready
end
local function disconnectTouches()
    for _, connection in ipairs(touchConnections) do connection:Disconnect() end
    table.clear(touchConnections)
end

state:SetAttribute('Alive', 0)
state:SetAttribute('KillerName', '')
state:SetAttribute('Result', '')
while true do
    -- Also cover returning to a single Studio client after another client leaves.
    local waitingPlayers = Players:GetPlayers()
    if RunService:IsStudio() and #waitingPlayers == 1 and root(waitingPlayers[1]) then
        teleport(waitingPlayers[1], spawnFolder:WaitForChild('01'))
    end
    setPhase('Waiting', 0, RunService:IsStudio()
        and 'Explore the mansion. Start a test with 2+ players for a round.'
        or 'Waiting for at least 2 players...')
    repeat task.wait(1) until #readyPlayers() >= 2
    local intermissionEnds = now() + Config.Intermission
    setPhase('Intermission', intermissionEnds, 'A new hunt begins soon.')
    repeat task.wait(0.25) until now() >= intermissionEnds or #readyPlayers() < 2
    local roster = readyPlayers()
    if #roster < 2 then continue end
    -- Shuffle so overflow spectators get a fair chance next round.
    for i = #roster, 2, -1 do
        local j = random:NextInteger(1, i)
        roster[i], roster[j] = roster[j], roster[i]
    end
    while #roster > Config.MaxPlayers do table.remove(roster) end
    local killer = roster[1]
    local ids = {}
    for _, player in ipairs(roster) do table.insert(ids, player.UserId) end
    local activeRound = Rules.new(ids, killer.UserId, now(), Config.RoundSeconds, Config.HeadStart)
    activeRound.characters = {}
    for _, player in ipairs(roster) do activeRound.characters[player.UserId] = player.Character end
    round = activeRound
    state:SetAttribute('Result', '')
    state:SetAttribute('KillerName', killer.DisplayName)
    local spawns = spawnFolder:GetChildren()
    table.sort(spawns, function(a, b) return a.Name < b.Name end)
    for i, player in ipairs(roster) do
        local r, h = root(player), humanoid(player)
        r.Anchored = false
        h.WalkSpeed = 16
        h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA('ForceField') then child:Destroy() end
        end
        setRole(player, i == 1 and 'Killer' or 'Survivor')
        teleport(player, i == 1 and killerSpawn or spawns[((i - 2) % #spawns) + 1])
    end
    dressKiller(killer)
    root(killer).Anchored = true
    for _, part in ipairs(killer.Character:GetChildren()) do
        if part:IsA('BasePart') and part.CanTouch then
            table.insert(touchConnections, part.Touched:Connect(function(other) catchTouch(killer, other) end))
        end
    end
    updateAlive()
    setPhase('HeadStart', activeRound.chaseAt, 'Survivors: find a hiding place!')
    local released = false
    while not Rules.tick(activeRound, now()) do
        if not released and now() >= activeRound.chaseAt then
            released = true
            if root(killer) then
                teleport(killer, entranceSpawn)
                root(killer).Anchored = false
            end
            setPhase('Running', activeRound.endsAt, 'Survive until the timer reaches zero.')
        end
        task.wait(0.1)
    end
    disconnectTouches()
    state:SetAttribute('Result', activeRound.result)
    local message = activeRound.result == 'Survivors' and 'SURVIVOR TEAM WINS — someone survived five minutes!'
        or activeRound.result == 'Killer' and 'MICHAEL MYERS WINS — all survivors were caught!'
        or 'ROUND CANCELLED — the killer left or reset.'
    setPhase('Results', now() + 8, message)
    for _, player in ipairs(roster) do if root(player) then root(player).Anchored = true end end
    task.wait(8)
    round = nil
    for _, player in ipairs(Players:GetPlayers()) do
        setRole(player, 'Waiting')
        if root(player) then root(player).Anchored = false end
        safeReload(player)
    end
    updateAlive()
    state:SetAttribute('KillerName', '')
    state:SetAttribute('Result', '')
end
