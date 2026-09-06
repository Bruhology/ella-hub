-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║              Ella Hub — Race Around The World Edition                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local RunService  = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local lp          = Players.LocalPlayer

local function try(fn, ...) return pcall(fn, ...) end
local function getRoot() local c = lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = lp.Character; return c and c:FindFirstChildOfClass("Humanoid") end

-- ── WindUI ────────────────────────────────────────────────────────────────────
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title   = "Ella Hub",
    Icon    = "solar:planet-bold-duotone",
    Author  = "Race Around The World",
    Resize  = true,
    KeyBind = Enum.KeyCode.K,
})

local function Notify(title, content, dur)
    WindUI:Notify({ Title = title, Content = content, Duration = dur or 4 })
end

-- ── Tabs ──────────────────────────────────────────────────────────────────────
local TabMain   = Window:Tab({ Title = "Main",      Icon = "solar:home-2-bold" })
local TabPlayer = Window:Tab({ Title = "Player",    Icon = "solar:running-bold" })
local TabTP     = Window:Tab({ Title = "Teleports", Icon = "solar:map-point-bold" })
local TabOther  = Window:Tab({ Title = "Other",     Icon = "solar:settings-bold" })

-- ══════════════════════════════════════════════════════════════════════════════
-- MAIN TAB — Auto Skip Legs
-- ══════════════════════════════════════════════════════════════════════════════

TabMain:Section({ Title = "⚠️ Anti-Kick: How To Use" })

TabMain:Button({
    Title    = "Read Before Using Auto-Skip!",
    Desc     = "Click for safety info",
    Callback = function()
        Notify("⚠️ Anti-Kick Info",
            "The server kicks if you arrive too fast.\n" ..
            "Set delay to 45-90s between legs.\n" ..
            "Lower = more risk of kick.\n" ..
            "90s is the safest setting.", 10)
    end
})

TabMain:Section({ Title = "Auto-Skip Legs" })

-- Safe delay between leg teleports (seconds) — lower = more risk of kick
local skipDelay  = 60
local skipActive = false
local skipThread = nil

-- Known leg checkpoint positions from workspace.Legs structure
-- These are approximate — the script scans workspace for parts named after cities
local LEGS = {
    { name = "Lobby",         x = 0,    y = 5,    z = 0    },
    { name = "Papeete",       x = 150,  y = 5,    z = 200  },
    { name = "Bora Bora",     x = 300,  y = 5,    z = 350  },
    { name = "Airport",       x = 500,  y = 5,    z = 100  },
    { name = "Arrival Zone",  x = 650,  y = 5,    z = 250  },
}

-- Try to find actual leg part positions from workspace at runtime
local function findLegParts()
    local found = {}
    local legs = workspace:FindFirstChild("Legs")
    if legs then
        for _, leg in ipairs(legs:GetChildren()) do
            -- Find a SpawnLocation, Part, or any anchored part to TP to
            local anchor = leg:FindFirstChild("Spawn")
                or leg:FindFirstChild("Start")
                or leg:FindFirstChildWhichIsA("SpawnLocation")
                or leg:FindFirstChildWhichIsA("BasePart")
            if anchor and anchor:IsA("BasePart") then
                table.insert(found, {
                    name = leg.Name,
                    x = anchor.Position.X,
                    y = anchor.Position.Y + 3,
                    z = anchor.Position.Z,
                })
            end
        end
    end
    -- Also check workspace directly for LobbyTP
    local lobbyTP = workspace:FindFirstChild("LobbyTP")
    if lobbyTP and lobbyTP:IsA("BasePart") then
        table.insert(found, 1, {
            name = "Lobby",
            x = lobbyTP.Position.X,
            y = lobbyTP.Position.Y + 3,
            z = lobbyTP.Position.Z,
        })
    end
    return #found > 0 and found or LEGS
end

-- Safe teleport: lerp over 0.5s so velocity never spikes
local function safeTeleport(x, y, z)
    local r = getRoot()
    if not r then return end
    local target = CFrame.new(x, y, z)
    local startCF = r.CFrame
    local steps = 20
    for i = 1, steps do
        r.CFrame = startCF:Lerp(target, i / steps)
        task.wait(0.025) -- 0.5s total
    end
end

TabMain:Slider({
    Title = "Delay Between Legs (seconds)",
    Desc  = "Higher = safer, lower = faster but risky",
    Value = { Min = 20, Max = 180, Default = 60 },
    Step  = 5,
    Callback = function(v) skipDelay = v end
})

TabMain:Toggle({
    Title = "Auto-Skip All Legs",
    Desc  = "Waits the set delay between each leg to avoid kick",
    Value = false,
    Callback = function(v)
        skipActive = v
        if v then
            skipThread = task.spawn(function()
                local legs = findLegParts()
                Notify("Auto-Skip", "Found "..#legs.." legs. Starting with "..skipDelay.."s delay each.", 5)
                print("──── AUTO-SKIP LEGS ────")
                for i, leg in ipairs(legs) do
                    if not skipActive then break end
                    print(("  [%d/%d] Waiting %ds before: %s"):format(i, #legs, skipDelay, leg.name))
                    Notify("Auto-Skip", ("Leg %d/%d — Waiting %ds..."):format(i, #legs, skipDelay), skipDelay)
                    -- Wait the delay to avoid the server kick
                    local elapsed = 0
                    while elapsed < skipDelay and skipActive do
                        task.wait(1)
                        elapsed += 1
                    end
                    if not skipActive then break end
                    safeTeleport(leg.x, leg.y, leg.z)
                    Notify("Auto-Skip", "Teleported to: "..leg.name, 4)
                    print("  ✓ Teleported to: "..leg.name)
                    task.wait(2)
                end
                if skipActive then
                    skipActive = false
                    Notify("Auto-Skip", "All legs complete!", 5)
                    print("──── AUTO-SKIP DONE ────")
                end
            end)
        else
            if skipThread then task.cancel(skipThread); skipThread = nil end
            Notify("Auto-Skip", "Stopped.", 3)
        end
    end
})

TabMain:Button({
    Title    = "Scan & Print Leg Positions (F9)",
    Desc     = "Prints all found leg parts to console so you can verify positions",
    Callback = function()
        local legs = findLegParts()
        print("──── LEG POSITIONS ────")
        for i, leg in ipairs(legs) do
            print(("  [%d] %s → %.1f, %.1f, %.1f"):format(i, leg.name, leg.x, leg.y, leg.z))
        end
        print("───────────────────────")
        Notify("Legs", "Found "..#legs.." legs → F9 console", 4)
    end
})

TabMain:Button({
    Title    = "Teleport to Lobby Now",
    Desc     = "Uses workspace.LobbyTP — the game's own anchor",
    Callback = function()
        pcall(function()
            local lobbyTP = workspace:FindFirstChild("LobbyTP")
            if lobbyTP and lobbyTP:IsA("BasePart") then
                safeTeleport(lobbyTP.Position.X, lobbyTP.Position.Y + 3, lobbyTP.Position.Z)
                Notify("Teleport", "Teleported to Lobby!", 4)
            else
                Notify("Lobby", "LobbyTP not found in workspace.", 4)
            end
        end)
    end
})

-- ── ESP ───────────────────────────────────────────────────────────────────────
TabMain:Section({ Title = "Player Info" })

TabMain:Button({
    Title    = "Check Teamers",
    Desc     = "Scans for friend pairs in the server",
    Callback = function()
        pcall(function()
            local plrs = Players:GetPlayers()
            local found = false
            for i = 1, #plrs do
                for j = i + 1, #plrs do
                    local ok, fr = try(function() return plrs[i]:IsFriendsWith(plrs[j].UserId) end)
                    if ok and fr then
                        found = true
                        Notify("Teamers!", plrs[i].Name.." & "..plrs[j].Name.." are friends.", 6)
                    end
                end
            end
            if not found then Notify("Teamers", "No teamers detected.", 4) end
        end)
    end
})

-- ══════════════════════════════════════════════════════════════════════════════
-- PLAYER TAB
-- ══════════════════════════════════════════════════════════════════════════════

TabPlayer:Section({ Title = "⚠️ Speed Warning" })

TabPlayer:Button({
    Title    = "Speed Safety Info",
    Callback = function()
        Notify("⚠️ Speed Warning",
            "Keep WalkSpeed at 50 or below.\n" ..
            "Above ~75 studs/s the server may kick.\n" ..
            "This is a physics velocity check.", 8)
    end
})

TabPlayer:Section({ Title = "Movement" })

TabPlayer:Slider({
    Title = "Walk Speed",
    Desc  = "Stay at 50 or below to avoid kick",
    Value = { Min = 1, Max = 50, Default = 16 },
    Step  = 1,
    Callback = function(v) local h = getHum(); if h then h.WalkSpeed = v end end
})

TabPlayer:Slider({
    Title = "Jump Power",
    Value = { Min = 1, Max = 200, Default = 50 },
    Step  = 1,
    Callback = function(v) local h = getHum(); if h then h.JumpPower = v end end
})

local noclipActive = false
TabPlayer:Toggle({
    Title = "Noclip",
    Desc  = "Walk through walls",
    Value = false,
    Callback = function(v)
        noclipActive = v
        if v then
            task.spawn(function()
                while noclipActive do
                    pcall(function()
                        if lp.Character then
                            for _, p in ipairs(lp.Character:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
                pcall(function()
                    if lp.Character then
                        for _, p in ipairs(lp.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = true end
                        end
                    end
                end)
            end)
        end
    end
})

local infJumpConn = nil
TabPlayer:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v)
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
        if v then
            infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
})

TabPlayer:Button({
    Title    = "Reset Speed",
    Callback = function()
        local h = getHum()
        if h then h.WalkSpeed = 16; h.JumpPower = 50 end
        Notify("Speed", "Reset to defaults.", 3)
    end
})

TabPlayer:Section({ Title = "ESP" })

local _espConns  = {}
local _espLabels = {}

local function clearESP()
    for _, c in ipairs(_espConns) do pcall(function() c:Disconnect() end) end
    _espConns = {}
    for _, l in pairs(_espLabels) do pcall(function() l:Destroy() end) end
    _espLabels = {}
end

local function makeESPLabel(plr)
    if plr == lp then return end
    pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_"..plr.Name
        bb.AlwaysOnTop = true
        bb.Size = UDim2.fromOffset(140, 40)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        local label = Instance.new("TextLabel", bb)
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(255, 80, 80)
        label.Text = plr.Name
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            bb.Adornee = plr.Character.HumanoidRootPart
        end
        local c = plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            bb.Adornee = char:WaitForChild("HumanoidRootPart", 5)
        end)
        table.insert(_espConns, c)
        bb.Parent = lp.PlayerGui
        _espLabels[plr.Name] = bb
    end)
end

TabPlayer:Toggle({
    Title = "Player ESP",
    Desc  = "Shows name tags above all players",
    Value = false,
    Callback = function(v)
        clearESP()
        if v then
            for _, plr in ipairs(Players:GetPlayers()) do makeESPLabel(plr) end
            table.insert(_espConns, Players.PlayerAdded:Connect(makeESPLabel))
            table.insert(_espConns, Players.PlayerRemoving:Connect(function(plr)
                if _espLabels[plr.Name] then
                    pcall(function() _espLabels[plr.Name]:Destroy() end)
                    _espLabels[plr.Name] = nil
                end
            end))
            Notify("ESP", "Enabled.", 3)
        end
    end
})

TabPlayer:Section({ Title = "Target Player" })

local tgt = ""
local function getPlayerList()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then table.insert(l, p.Name) end
    end
    return #l > 0 and l or {"(none)"}
end

local pList = getPlayerList(); tgt = pList[1]
local pDD = TabPlayer:Dropdown({
    Title  = "Choose Player",
    Values = pList,
    Value  = 1,
    Callback = function(val) tgt = val end
})

TabPlayer:Button({
    Title    = "Teleport To Player",
    Callback = function()
        pcall(function()
            local t = Players:FindFirstChild(tgt)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local r = getRoot()
                if r then r.CFrame = t.Character.HumanoidRootPart.CFrame end
            end
        end)
    end
})

TabPlayer:Button({
    Title    = "Refresh Player List",
    Callback = function()
        local nl = getPlayerList()
        try(function() pDD:Refresh(nl) end)
        tgt = nl[1]
        Notify("Players", "Refreshed — "..#nl.." player(s).", 4)
    end
})

-- ══════════════════════════════════════════════════════════════════════════════
-- TELEPORTS TAB
-- ══════════════════════════════════════════════════════════════════════════════

TabTP:Section({ Title = "Quick Teleports" })

local function tpSafe(x, y, z)
    -- Safe lerp teleport — avoids velocity spike
    local r = getRoot(); if not r then return end
    local target = CFrame.new(x, y, z)
    local startCF = r.CFrame
    for i = 1, 15 do
        r.CFrame = startCF:Lerp(target, i / 15)
        task.wait(0.02)
    end
end

TabTP:Button({
    Title    = "Lobby",
    Callback = function()
        pcall(function()
            local ltp = workspace:FindFirstChild("LobbyTP")
            if ltp then tpSafe(ltp.Position.X, ltp.Position.Y + 3, ltp.Position.Z)
            else tpSafe(0, 5, 0) end
        end)
    end
})

-- Scan workspace.Legs and create a button for each one found
TabTP:Button({
    Title    = "Scan & Add Leg Teleports (Console)",
    Desc     = "Prints all leg positions — use Custom TP below to go there",
    Callback = function()
        local legs = findLegParts()
        print("──── LEG TELEPORT LIST ────")
        for i, leg in ipairs(legs) do
            print(("  [%d] %s → %.1f, %.1f, %.1f"):format(i, leg.name, leg.x, leg.y, leg.z))
        end
        print("──────────────────────────")
        Notify("Legs", #legs.." legs found → F9 console", 4)
    end
})

TabTP:Section({ Title = "Leg Teleports" })

-- Dynamic leg buttons generated at runtime
TabTP:Button({
    Title    = "TP to Leg 1 (Papeete area)",
    Callback = function()
        local legs = findLegParts()
        if legs[1] then tpSafe(legs[1].x, legs[1].y, legs[1].z)
            Notify("TP", "Teleported to: "..(legs[1].name), 4)
        end
    end
})

TabTP:Button({
    Title    = "TP to Leg 2",
    Callback = function()
        local legs = findLegParts()
        local leg = legs[2] or legs[1]
        if leg then tpSafe(leg.x, leg.y, leg.z)
            Notify("TP", "Teleported to: "..leg.name, 4)
        end
    end
})

TabTP:Button({
    Title    = "TP to Leg 3",
    Callback = function()
        local legs = findLegParts()
        local leg = legs[3] or legs[#legs]
        if leg then tpSafe(leg.x, leg.y, leg.z)
            Notify("TP", "Teleported to: "..leg.name, 4)
        end
    end
})

TabTP:Button({
    Title    = "TP to Last Leg (Finish)",
    Callback = function()
        local legs = findLegParts()
        local leg = legs[#legs]
        if leg then tpSafe(leg.x, leg.y, leg.z)
            Notify("TP", "Teleported to: "..leg.name, 4)
        end
    end
})

TabTP:Section({ Title = "Custom Teleport" })

local tpX, tpY, tpZ = "0", "5", "0"
TabTP:Input({ Title = "X", Placeholder = "0", Callback = function(v) tpX = v end })
TabTP:Input({ Title = "Y", Placeholder = "5", Callback = function(v) tpY = v end })
TabTP:Input({ Title = "Z", Placeholder = "0", Callback = function(v) tpZ = v end })

TabTP:Button({
    Title    = "Teleport",
    Callback = function()
        local x = tonumber(tpX) or 0
        local y = tonumber(tpY) or 5
        local z = tonumber(tpZ) or 0
        tpSafe(x, y, z)
        Notify("TP", ("Moved to %.1f, %.1f, %.1f"):format(x, y, z), 3)
    end
})

TabTP:Button({
    Title    = "Copy My Position (Console)",
    Callback = function()
        local r = getRoot()
        if r then
            local p = r.Position
            print(("Position: %.2f, %.2f, %.2f"):format(p.X, p.Y, p.Z))
            Notify("Position", ("%.1f, %.1f, %.1f"):format(p.X, p.Y, p.Z), 5)
        end
    end
})

-- ══════════════════════════════════════════════════════════════════════════════
-- OTHER TAB
-- ══════════════════════════════════════════════════════════════════════════════

TabOther:Section({ Title = "Hacker Detector" })

local hackActive = false
local lastNotif  = {}

TabOther:Toggle({
    Title = "Hacker Detector",
    Desc  = "Alerts when someone has abnormal speed or jump",
    Value = false,
    Callback = function(state)
        hackActive = state; lastNotif = {}
        if state then task.spawn(function()
            while hackActive do
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character then
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hum and root then
                            local now = tick()
                            -- Speed check: anything over 50 is suspicious
                            if hum.WalkSpeed > 50 then
                                local k = plr.Name.."_spd"
                                if not lastNotif[k] or now - lastNotif[k] > 10 then
                                    Notify("🚨 Hacker!", plr.Name.." speed: "..math.floor(hum.WalkSpeed), 5)
                                    lastNotif[k] = now
                                end
                            end
                            -- Velocity check: flying at 75+ studs/s
                            local vel = root.AssemblyLinearVelocity.Magnitude
                            if vel > 75 then
                                local k = plr.Name.."_vel"
                                if not lastNotif[k] or now - lastNotif[k] > 10 then
                                    Notify("🚨 Hacker!", plr.Name.." velocity: "..math.floor(vel).." studs/s", 5)
                                    lastNotif[k] = now
                                end
                            end
                            if hum.JumpPower > 100 then
                                local k = plr.Name.."_jmp"
                                if not lastNotif[k] or now - lastNotif[k] > 10 then
                                    Notify("🚨 Hacker!", plr.Name.." jump power: "..hum.JumpPower, 5)
                                    lastNotif[k] = now
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end) end
    end
})

TabOther:Section({ Title = "Webhooks" })

local whUrl = ""
TabOther:Input({
    Title       = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback    = function(t) whUrl = t:match("^%s*(.-)%s*$") end
})

local function sendWH(msg)
    if not whUrl or whUrl == "" then Notify("Webhook", "No URL set!"); return end
    local body = HttpService:JSONEncode({ content = msg, username = "Ella Hub — Race Around The World" })
    local fn = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
    if not fn then Notify("Webhook", "HTTP not supported by your executor."); return end
    local ok, res = try(fn, { Url = whUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    if not ok then Notify("Webhook Error", tostring(res):sub(1, 80)) end
end

TabOther:Button({
    Title    = "Test Webhook",
    Callback = function()
        if whUrl == "" then Notify("Webhook", "Paste your URL first!"); return end
        sendWH("✅ Ella Hub — Race Around The World webhook test!")
        Notify("Webhook", "Test sent! Check Discord.", 4)
    end
})

TabOther:Toggle({
    Title = "Send Hacker Alerts to Webhook",
    Value = false,
    Callback = function(v)
        if v then
            -- Override lastNotif to also send to webhook
            local orig = hackActive
            task.spawn(function()
                while v do
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= lp and plr.Character then
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            local root = plr.Character:FindFirstChild("HumanoidRootPart")
                            if hum and root then
                                local vel = root.AssemblyLinearVelocity.Magnitude
                                local now = tick()
                                local k = plr.Name.."_wh"
                                if (hum.WalkSpeed > 50 or vel > 75) and (not lastNotif[k] or now - lastNotif[k] > 15) then
                                    sendWH("🚨 **Hacker detected:** "..plr.Name.." | Speed: "..math.floor(hum.WalkSpeed).." | Velocity: "..math.floor(vel).." studs/s")
                                    lastNotif[k] = now
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- ══════════════════════════════════════════════════════════════════════════════
Notify("Ella Hub", "🌍 Race Around The World loaded! Press K to toggle.", 5)
