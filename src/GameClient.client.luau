local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
local state = ReplicatedStorage:WaitForChild('MansionState')
local gui = Instance.new('ScreenGui')
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = 'MansionHUD', false, false
gui.Parent = player:WaitForChild('PlayerGui')
local function label(parent, name, text, position, size, fontSize, color)
    local object = Instance.new('TextLabel')
    object.Name, object.Text, object.Position, object.Size = name, text, position, size
    object.BackgroundTransparency = 1
    object.TextColor3 = color or Color3.fromRGB(235, 229, 213)
    object.Font, object.TextSize, object.TextWrapped = Enum.Font.GothamMedium, fontSize, true
    object.Parent = parent
    return object
end
local panel = Instance.new('Frame')
panel.Name, panel.AnchorPoint, panel.Position = 'RoundPanel', Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 8)
panel.Size = UDim2.new(0.9, 0, 0, 134)
panel.BackgroundColor3, panel.BackgroundTransparency = Color3.fromRGB(16, 20, 24), 0.1
panel.BorderSizePixel, panel.Parent = 0, gui
local limit = Instance.new('UISizeConstraint')
limit.MaxSize, limit.Parent = Vector2.new(650, 134), panel
local corner = Instance.new('UICorner')
corner.CornerRadius, corner.Parent = UDim.new(0, 10), panel
label(panel, 'Title', 'MIDNIGHT MANOR', UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 20), 17)
local clockLabel = label(panel, 'Clock', '--:--', UDim2.new(0.35, 0, 0, 31), UDim2.new(0.3, 0, 0, 36), 30)
local roleLabel = label(panel, 'Role', '', UDim2.new(0, 10, 0, 35), UDim2.new(0.35, -10, 0, 30), 13)
local aliveLabel = label(panel, 'Alive', '', UDim2.new(0.65, 0, 0, 35), UDim2.new(0.35, -10, 0, 30), 13)
local messageLabel = label(panel, 'Message', '', UDim2.new(0, 12, 0, 75), UDim2.new(1, -24, 0, 48), 14)
local spectate = Instance.new('Frame')
spectate.Name, spectate.AnchorPoint = 'Spectate', Vector2.new(0.5, 1)
spectate.Position, spectate.Size = UDim2.new(0.5, 0, 1, -20), UDim2.new(0.86, 0, 0, 56)
spectate.BackgroundColor3, spectate.BorderSizePixel, spectate.Parent = Color3.fromRGB(16, 20, 24), 0, gui
local specLimit = Instance.new('UISizeConstraint')
specLimit.MaxSize, specLimit.Parent = Vector2.new(440, 56), spectate
local specCorner = corner:Clone()
specCorner.Parent = spectate
local targetLabel = label(spectate, 'Target', '', UDim2.new(0, 60, 0, 0), UDim2.new(1, -120, 1, 0), 14)
local selectedId = nil
local currentTargets = {}
local function button(text, x, anchor)
    local b = Instance.new('TextButton')
    b.Text, b.TextSize, b.Font = text, 24, Enum.Font.GothamBold
    b.Size, b.Position, b.AnchorPoint = UDim2.fromOffset(50, 44), UDim2.new(x, 0, 0.5, 0), Vector2.new(anchor, 0.5)
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(63, 37, 39), Color3.new(1, 1, 1)
    b.BorderSizePixel, b.Parent = 0, spectate
    return b
end
local previousButton, nextButton = button('<', 0, 0), button('>', 1, 1)
local function cycle(direction)
    if #currentTargets == 0 then selectedId = nil return end
    local index = 1
    for i, target in ipairs(currentTargets) do if target.UserId == selectedId then index = i break end end
    selectedId = currentTargets[((index - 1 + direction) % #currentTargets) + 1].UserId
end
previousButton.Activated:Connect(function() cycle(-1) end)
nextButton.Activated:Connect(function() cycle(1) end)
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
    local time = workspace:GetServerTimeNow()
    if time - lastUpdate < 0.1 then return end
    lastUpdate = time
    local phase = state:GetAttribute('Phase') or 'Waiting'
    local role = player:GetAttribute('MansionRole') or 'Waiting'
    local running = phase == 'Running' or phase == 'HeadStart'
    local remaining = math.max(0, math.ceil((state:GetAttribute('EndsAt') or 0) - time))
    clockLabel.Text = phase == 'Waiting' and '--:--' or string.format('%d:%02d', math.floor(remaining / 60), remaining % 60)
    roleLabel.Text = role == 'Killer' and 'MICHAEL MYERS' or string.upper(role)
    roleLabel.TextColor3 = role == 'Killer' and Color3.fromRGB(235, 104, 100) or Color3.fromRGB(198, 215, 191)
    aliveLabel.Text = running and tostring(state:GetAttribute('Alive') or 0) .. ' SURVIVORS' or string.upper(phase)
    messageLabel.Text = state:GetAttribute('Message') or ''
    if phase == 'HeadStart' and role == 'Killer' then
        messageLabel.Text = 'You are Michael Myers. You will be released when this countdown ends.'
    elseif phase == 'Running' and role == 'Killer' then
        messageLabel.Text = 'Touch every survivor before time runs out.'
    elseif running and role == 'Spectator' then
        messageLabel.Text = 'You were eliminated. Your team can still win!'
    end
    spectate.Visible = running and (role == 'Spectator' or role == 'Waiting')
    currentTargets = {}
    for _, target in ipairs(Players:GetPlayers()) do
        local h = target.Character and target.Character:FindFirstChildOfClass('Humanoid')
        if target:GetAttribute('MansionRole') == 'Survivor' and h and h.Health > 0 then
            table.insert(currentTargets, target)
        end
    end
    table.sort(currentTargets, function(a, b) return a.UserId < b.UserId end)
    local selected = nil
    for _, target in ipairs(currentTargets) do if target.UserId == selectedId then selected = target end end
    if not selected then selected = currentTargets[1] end
    selectedId = selected and selected.UserId or nil
    local subject = nil
    if spectate.Visible and selected then
        subject = selected.Character:FindFirstChildOfClass('Humanoid')
        targetLabel.Text = 'WATCHING ' .. selected.DisplayName
    else
        subject = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
        targetLabel.Text = 'Waiting for survivors...'
    end
    previousButton.Visible, nextButton.Visible = #currentTargets > 1, #currentTargets > 1
    local camera = workspace.CurrentCamera
    if subject and camera then
        camera.CameraType = Enum.CameraType.Custom
        if camera.CameraSubject ~= subject then camera.CameraSubject = subject end
    end
end)
