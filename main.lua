-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                    Ella Hub — TRD Script  v2.0                         ║
-- ║                    UI: WindUI (official dist)                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ══════════════════════════════════════════════════════════════════════════════
-- SERVICES  (cached once at top — no repeated GetService calls)
-- ══════════════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local RS               = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")

local lp = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════
-- UTILITIES  (shared helpers used throughout)
-- ══════════════════════════════════════════════════════════════════════════════

-- Safe wrapper: returns success + result, swallows errors silently
local function try(fn, ...)
    return pcall(fn, ...)
end

-- Get the local player's character root safely
local function getRoot()
    local char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Get the local player's humanoid safely
local function getHumanoid()
    local char = lp.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Move a finish-line part to the player's position (used across all three maps)
local function winObby()
    local f = workspace.Assets and workspace.Assets:FindFirstChild("Finish", true)
    local root = getRoot()
    if f and root then
        f.CanCollide  = false
        f.Transparency = 1
        f.Position    = root.Position
    end
end

-- Auto-solve a MathMania GUI (shared across Camp/Movie/Expedition)
local function solveMath()
    local gui = lp.PlayerGui:FindFirstChild("MathMania")
    if not gui then return end
    for i = 1, 10 do
        local q = gui:FindFirstChild(tostring(i))
        if not q then continue end
        local raw   = q:FindFirstChild("MainText")
        local box   = q:FindFirstChild("Box")
        local enter = q:FindFirstChild("Enter")
        if not (raw and box) then continue end
        local clean = raw.Text:gsub("[=?%s]", "")
        local ok, result = pcall(function() return loadstring("return " .. clean)() end)
        if ok and result then
            box.Text = tostring(result)
            task.wait()
            if enter and getconnections then
                for _, ev in ipairs({"MouseButton1Click","MouseButton1Down","Activated"}) do
                    for _, c in ipairs(getconnections(enter[ev])) do
                        if c.Function then pcall(c.Fire, c) end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end

-- Kill all players with a sword tool (used in Camp/Movie/Expedition)
local function killAllWithSword()
    local char = lp.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not (tool and tool:FindFirstChild("Handle")) then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            try(function() tool:Activate() end)
            for _, part in ipairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    try(firetouchinterest, tool.Handle, part, 0)
                    try(firetouchinterest, tool.Handle, part, 1)
                end
            end
        end
    end
end

-- Resolve display name from Season.Players value
local function resolveDisplayName(key)
    local ok, val = try(function()
        return RS.Season.Players[key].Value
    end)
    return ok and val or key
end

-- ══════════════════════════════════════════════════════════════════════════════
-- EXECUTOR DETECTION
-- ══════════════════════════════════════════════════════════════════════════════
local function getExecutorName()
    if syn then return "Synapse X" end
    if KRNL_LOADED then return "KRNL" end
    if fluxus then return "Fluxus" end
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then return tostring(name) end
    end
    return "Unknown"
end

-- ══════════════════════════════════════════════════════════════════════════════
-- BLACKLIST  (checked before anything else loads)
-- ══════════════════════════════════════════════════════════════════════════════
local function checkBlacklist()
    local ok, response = try(function()
        return game:HttpGet("https://raw.githubusercontent.com/Bruhology/ella-hub/main/blacklist.txt")
    end)
    if not ok or not response then
        lp:Kick("Failed to verify authorization. Please rejoin.")
        return
    end
    local userId   = tostring(lp.UserId)
    local userName = lp.Name
    for line in response:gmatch("[^\r\n]+") do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed == userId or trimmed == userName then
            lp:Kick("You are blacklisted from using this script.")
            return
        end
    end
end
checkBlacklist()

-- ══════════════════════════════════════════════════════════════════════════════
-- XENO REDIRECT
-- ══════════════════════════════════════════════════════════════════════════════
local execName = getExecutorName():lower()
if execName:find("xeno") then
    -- Load legacy version for Xeno users after showing notification
    -- WindUI not yet initialised here so we delay slightly
    task.spawn(function()
        task.wait(0.5)
        WindUI:Notify({
            Title   = "Xeno Detected",
            Content = "You are using Xeno — executing Legacy mode!",
            Duration = 6,
        })
        task.wait(2)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Bruhology/ella-hub/main/haha.lua"))()
    end)
    -- Still init the window so the notification renders, then stop
    task.wait(3)
    return
end

-- ══════════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title            = "Ella Hub",
    Icon             = "solar:home-2-bold",
    Author           = "by Ella",
    Folder           = "EllaHub",
    Theme            = "Dark",
    NewElements      = true,
    Transparent      = true,
    Acrylic          = true,
    Resizable        = true,
    SideBarWidth     = 200,
    HideSearchBar    = false,
    ScrollBarEnabled = false,
    ToggleKey        = Enum.KeyCode.RightShift,
})
Window:Tag({ Title = "TRD Script", Color = "Text" })

-- ══════════════════════════════════════════════════════════════════════════════
-- WEBHOOK / TRACKING SYSTEM
-- Unified HTTP request helper + rich-embed tracker using the same webhook
-- ══════════════════════════════════════════════════════════════════════════════
local TRACK_URL = "https://discord.com/api/webhooks/1499989357992480921/vTAmLDsCFhostWASgBrWI82CRKJgP0dqHBTt84LEZsdLi7GcIczU3MUsbkKPYaj66Syl"

-- Resolve the best available HTTP function for the current executor
local function getHttpFn()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
end

-- Core send — posts a fully-formed Discord embed body dict
local function sendWebhook(url, body)
    local httpFn = getHttpFn()
    if not httpFn then return false, "No HTTP function available" end
    local ok, err = try(httpFn, {
        Url     = url,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = HttpService:JSONEncode(body),
    })
    return ok, err
end

-- Public webhook for user-configured webhooks (Other tab)
local _whUrl = ""
local function sendUserWH(msg)
    if _whUrl == "" then
        WindUI:Notify({Title="Webhook", Content="No URL set! Paste your webhook URL first.", Duration=4})
        return
    end
    local ok, err = sendWebhook(_whUrl, {
        content    = msg,
        username   = "Ella Hub",
        avatar_url = "https://i.imgur.com/Cqde1fS.png",
    })
    if not ok then
        WindUI:Notify({Title="Webhook Error", Content=tostring(err):sub(1,80), Duration=5})
    end
end

-- Rich embed tracker  (same webhook, nicer format)
local function trackUser(status, color)
    color = color or 0xFFB6C1
    local desc = table.concat({
        "**Username:** " .. lp.Name,
        "**Display:** "  .. (lp.DisplayName or lp.Name),
        "**Executor:** " .. getExecutorName(),
        "**Place ID:** " .. tostring(game.PlaceId),
        "**Status:** "   .. status,
    }, "\n")
    task.spawn(function()
        sendWebhook(TRACK_URL, {
            username   = "Ella Hub Tracker",
            avatar_url = "https://i.imgur.com/Cqde1fS.png",
            embeds = {{
                title       = "User " .. status,
                color       = color,
                description = desc,
                footer      = { text = "Ella Hub v2.0 — User Tracker" },
                timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }},
        })
    end)
end

-- Send tracker after a short delay so the game has loaded
task.spawn(function()
    task.wait(3)
    trackUser("Joined", 0x00FF88)
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- TABS
-- ══════════════════════════════════════════════════════════════════════════════
Window:Divider()
local TabCamp     = Window:Tab({ Title="Camp",       Icon="solar:shield-bold" })
local TabMovie    = Window:Tab({ Title="Movie",      Icon="solar:camera-bold" })
local TabExped    = Window:Tab({ Title="Expedition", Icon="solar:map-bold" })
Window:Divider()
local TabMain     = Window:Tab({ Title="Main",       Icon="solar:home-2-bold" })
local TabChars    = Window:Tab({ Title="Characters", Icon="solar:user-bold" })
local TabPlyr     = Window:Tab({ Title="Player",     Icon="solar:running-2-bold" })
Window:Divider()
local TabStats    = Window:Tab({ Title="Stats",      Icon="solar:chart-square-bold" })
local TabTp       = Window:Tab({ Title="Teleports",  Icon="solar:map-point-bold" })
local TabUniv     = Window:Tab({ Title="Universal",  Icon="solar:global-bold" })
local TabClient   = Window:Tab({ Title="Client",     Icon="solar:cpu-bolt-bold" })
Window:Divider()
local TabOther    = Window:Tab({ Title="Other",      Icon="solar:settings-bold" })
local TabAutoplay = Window:Tab({ Title="Autoplay",   Icon="solar:play-bold" })
local TabDiscord  = Window:Tab({ Title="Discord",    Icon="solar:chat-round-bold" })
local TabShop     = Window:Tab({ Title="Shop",       Icon="solar:shop-bold" })
local TabCredits  = Window:Tab({ Title="Credits",    Icon="solar:star-bold" })
Window:Divider()
local TabRecorder = Window:Tab({ Title="Recorder",   Icon="solar:videocamera-record-bold" })
local TabCombat   = Window:Tab({ Title="Combat",     Icon = "solar:gameboy-bold"
local TabVisuals  = Window:Tab({ Title="Visuals",    Icon="solar:eye-bold" })
Window:Divider()

TabCamp:Select()

-- ══════════════════════════════════════════════════════════════════════════════
-- DISCORD
-- ══════════════════════════════════════════════════════════════════════════════
TabDiscord:Button({ Title="Join Discord", Desc="Click to copy the invite link", Callback=function()
    setclipboard("https://discord.gg/JEHHxynrME")
    WindUI:Notify({ Title="Discord", Content="Invite copied! discord.gg/JEHHxynrME", Duration=4 })
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- CAMP
-- ══════════════════════════════════════════════════════════════════════════════

TabCamp:Section({ Title="Obby" })
local G_obby = TabCamp:Group()
G_obby:Button({ Title="Win Obby", Justify="Center", Icon="solar:flag-bold", IconAlign="Left", Size="Small", Callback=function()
    winObby()
end})
G_obby:Space({ Columns=0.5 })
G_obby:Button({ Title="Godmode", Justify="Center", Icon="solar:shield-bold", IconAlign="Left", Size="Small", Callback=function()
    -- Remove all hazard touch interests
    for _, v in pairs(workspace.Assets:GetDescendants()) do
        if v.Name == "Mud" or v.Name == "Water" or v.Name == "Lava" then
            local t = v:FindFirstChild("TouchInterest")
            if t then t:Destroy() end
        end
    end
end})
local _campObby = false
TabCamp:Toggle({ Title="Auto-Win Obby", Desc="Finish line loops to your position", Value=false, Callback=function(v)
    _campObby = v
    if v then task.spawn(function()
        while _campObby do winObby(); task.wait(0.5) end
    end) end
end})

TabCamp:Section({ Title="Food" })
TabCamp:Button({ Title="Eat / Finish Pancake", Desc="Rapidly clicks your food item to finish eating", Callback=function()
    local name = lp.Name
    for _, v in pairs(workspace.Assets:GetDescendants()) do
        if v.Name == name then
            local cd = v:FindFirstChildOfClass("ClickDetector")
            if cd then for _ = 1, 80 do try(fireclickdetector, cd) end end
        end
    end
end})

TabCamp:Section({ Title="Spleef" })
local Gspl = TabCamp:Group()
Gspl:Button({ Title="Godmode", Justify="Center", Icon="solar:shield-bold", IconAlign="Left", Size="Small", Callback=function()
    local s = workspace.Assets:FindFirstChild("Spleef")
    if s then
        local p = s:FindFirstChild("Part")
        if p then local t = p:FindFirstChild("TouchInterest"); if t then t:Destroy() end end
    end
end})
Gspl:Space({ Columns=0.5 })
Gspl:Button({ Title="Clear Parts", Justify="Center", Icon="solar:trash-bin-bold", IconAlign="Left", Size="Small", Callback=function()
    local root = getRoot()
    if not root then return end
    for _, v in pairs(workspace.Assets:GetDescendants()) do
        if v.Name == "SpleefPart" then try(firetouchinterest, root, v, 0) end
    end
end})

TabCamp:Section({ Title="Coins & Gems" })
local _coinsActive = false
TabCamp:Toggle({ Title="Auto Collect Coins & Gems", Desc="Moves all coins and gems to your character", Value=false, Callback=function(v)
    _coinsActive = v
    if v then task.spawn(function()
        while _coinsActive do
            local root = getRoot()
            if root then
                try(function()
                    for _, obj in pairs(workspace.Assets:GetDescendants()) do
                        if obj.Name == "Coin" or obj.Name == "Gem" then
                            obj.CanCollide = false
                            obj.Position   = root.Position
                        end
                    end
                end)
            end
            task.wait(0.5)
        end
    end) end
end})

TabCamp:Section({ Title="Math Mania" })
local _mathCamp = false
TabCamp:Toggle({ Title="Auto-Win Math Mania", Desc="Auto-solves and submits all math questions", Value=false, Callback=function(v)
    _mathCamp = v
    if v then task.spawn(function()
        while _mathCamp do solveMath(); task.wait(1) end
    end) end
end})

TabCamp:Section({ Title="Block Push" })
TabCamp:Button({ Title="Win Block Push", Desc="Pushes your box onto the gold target", Callback=function()
    local root = getRoot()
    if not root then return end
    local box, gold
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") then
            if v.Name == "SingularBox" and (v.Position - root.Position).Magnitude <= 100 then box = v end
            if v.Name == "Gold" then gold = v end
        end
        if box and gold then break end
    end
    if box and gold then
        box.Position = gold.Position + Vector3.new(0, 3, 0)
        root.CFrame  = CFrame.new(box.Position + Vector3.new(0, 3, 0))
    end
end})

TabCamp:Section({ Title="Sword Fight" })
local _sfLoop = nil
TabCamp:Toggle({ Title="Kill All In Sword Fight", Desc="Fires sword touch on all players every frame", Value=false, Callback=function(v)
    if _sfLoop then _sfLoop:Disconnect(); _sfLoop = nil end
    if v then
        _sfLoop = RunService.RenderStepped:Connect(killAllWithSword)
    end
end})

TabCamp:Section({ Title="Auto-Win All" })
local _awActive = false
local _awKill   = nil
TabCamp:Toggle({ Title="Auto-Win All Challenges", Desc="Enables all loops at once", Value=false, Callback=function(state)
    _awActive = state

    -- Disconnect kill loop first regardless
    if _awKill then _awKill:Disconnect(); _awKill = nil end

    if state then
        -- Obby loop
        task.spawn(function() while _awActive do winObby(); task.wait(0.5) end end)
        -- Coin/gem loop
        task.spawn(function() while _awActive do
            local torso = lp.Character and lp.Character:FindFirstChild("Torso")
            if torso then
                try(function()
                    for _, obj in pairs(workspace.Assets:GetDescendants()) do
                        if obj.Name == "Coin" or obj.Name == "Gem" then
                            obj.CanCollide = false; obj.Position = torso.Position
                        end
                    end
                end)
            end
            task.wait(0.3)
        end end)
        -- Food loop
        task.spawn(function() while _awActive do
            local name = lp.Name
            try(function()
                for _, obj in pairs(workspace.Assets:GetDescendants()) do
                    if obj.Name == name then
                        local cd = obj:FindFirstChildOfClass("ClickDetector")
                        if cd then for _ = 1, 10 do fireclickdetector(cd) end end
                    end
                end
            end)
            task.wait(0.5)
        end end)
        -- Hazard cleanup loop
        task.spawn(function() while _awActive do
            try(function()
                for _, v in pairs(workspace.Assets:GetDescendants()) do
                    if v.Name=="Mud" or v.Name=="Water" or v.Name=="Lava" then
                        local t = v:FindFirstChild("TouchInterest"); if t then t:Destroy() end
                    end
                end
            end)
            task.wait(1)
        end end)
        -- Kill loop
        _awKill = RunService.RenderStepped:Connect(killAllWithSword)
    end

    WindUI:Notify({Title="Auto-Win All", Content=state and "ENABLED!" or "Disabled.", Duration=3})
end})

TabCamp:Section({ Title="Dodgeball & Paintball" })
local _keepBall = false
local _ballConn = nil
TabCamp:Toggle({ Title="Keep Dodgeball After Round", Desc="Re-equips the dodgeball if it gets taken away", Value=false, Callback=function(v)
    _keepBall = v
    if _ballConn then _ballConn:Disconnect(); _ballConn = nil end
    if v then
        _ballConn = lp.Backpack.ChildRemoved:Connect(function(child)
            if child.Name ~= "Dodgeball" or not _keepBall then return end
            task.wait(0.5)
            if _keepBall and not lp.Backpack:FindFirstChild("Dodgeball") then
                local found = workspace:FindFirstChild("Dodgeball", true)
                if found then found:Clone().Parent = lp.Backpack end
            end
        end)
    end
end})

local _autoBounce = false
TabCamp:Toggle({ Title="Auto Throw Dodgeball", Desc="Automatically fires the dodgeball remote", Value=false, Callback=function(v)
    _autoBounce = v
    if v then task.spawn(function()
        while _autoBounce do
            local root = getRoot()
            if root then try(function()
                local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name == "Dodgeball" then
                    local bounce = tool:FindFirstChild("Bounce")
                    if bounce then bounce:FireServer(root.Position) end
                end
            end) end
            task.wait(0.3)
        end
    end) end
end})

local _autoPaint = false
TabCamp:Toggle({ Title="Auto Fire Paintball", Desc="Automatically fires paintball at all players", Value=false, Callback=function(v)
    _autoPaint = v
    if v then task.spawn(function()
        while _autoPaint do
            try(function()
                local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name == "PaintballGun" then
                    local fire = tool:FindFirstChild("Fire")
                    if fire then
                        for _, plr in pairs(Players:GetPlayers()) do
                            if plr ~= lp and plr.Character then
                                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    fire:FireServer(CFrame.new(root.Position))
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
    end) end
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- MOVIE
-- ══════════════════════════════════════════════════════════════════════════════

TabMovie:Section({ Title="Obby" })
local Gmovobby = TabMovie:Group()
Gmovobby:Button({ Title="Win Obby", Justify="Center", Icon="solar:flag-bold", IconAlign="Left", Size="Small", Callback=winObby})
local _movObby = false
TabMovie:Toggle({ Title="Auto-Win Obby", Desc="Finish line loops to your position", Value=false, Callback=function(v)
    _movObby = v
    if v then task.spawn(function() while _movObby do winObby(); task.wait(0.5) end end) end
end})

TabMovie:Section({ Title="Pirate" })
TabMovie:Button({ Title="Collect Keys & Open Chests", Desc="Collects all pirate keys and opens matching chests", Callback=function()
    local pa = workspace.Assets:FindFirstChild("Pirate"); if not pa then return end
    local function getKey()
        for _, v in ipairs(lp.Backpack:GetChildren()) do if v:IsA("Tool") then return v end end
        for _, v in ipairs(lp.Character:GetChildren()) do if v:IsA("Tool") then return v end end
    end
    while true do
        local kf
        for _, v in ipairs(pa:GetDescendants()) do if v.Name == "MainKey" then kf = v; break end end
        if not kf then break end
        lp.Character.HumanoidRootPart.CFrame = kf.CFrame; task.wait(0.25)
        local kt, elapsed = nil, 0
        while elapsed < 5 and not kt do kt = getKey(); if not kt then task.wait(0.1); elapsed += 0.1 end end
        if not kt then break end
        kt.Parent = lp.Character; task.wait(0.05)
        local cf = pa:FindFirstChild("Chests")
        if cf then
            local cm = cf:FindFirstChild(kt.Name)
            if cm then local ch = cm:FindFirstChild("Chest"); if ch then lp.Character.HumanoidRootPart.CFrame = ch.CFrame; task.wait(0.15) end end
        end
    end
end})

TabMovie:Section({ Title="Beach Fight" })
local _beachLoop = nil
TabMovie:Toggle({ Title="Kill Everyone In Beach Fight", Desc="Fires sword touch on all players every frame", Value=false, Callback=function(v)
    if _beachLoop then _beachLoop:Disconnect(); _beachLoop = nil end
    if v then _beachLoop = RunService.RenderStepped:Connect(killAllWithSword) end
end})

TabMovie:Section({ Title="Monster" })
TabMovie:Button({ Title="Monster Godmode", Desc="Destroys the monster NPC to prevent damage", Callback=function()
    local m = workspace.Assets:FindFirstChild("Monster")
    if m then local n = m:FindFirstChild("MonsterNPC"); if n then n:Destroy() end end
end})

TabMovie:Section({ Title="Alien" })
TabMovie:Button({ Title="Collect Egg", Desc="Moves your egg to your character position", Callback=function()
    local root = getRoot(); if not root then return end
    local alien = workspace.Assets:WaitForChild("Alien")
    if not alien then return end
    local charVal = RS.Season.Players:FindFirstChild(lp.Name)
    local cv = charVal and charVal.Value; if not cv then return end
    for _, v in pairs(alien:GetDescendants()) do
        if v.ClassName == "TextLabel" and v.Text == cv then
            local mdl = v.Parent.Parent.Parent
            try(function() mdl.CFrame = root.CFrame; mdl.CanCollide = false end)
        end
    end
end})

TabMovie:Section({ Title="Pre-Historic" })
local _ancientConn
TabMovie:Toggle({ Title="Auto Collect Ancient Artifacts", Desc="Teleports artifact coins to you as they spawn", Value=false, Callback=function(state)
    if state then
        try(function()
            local ph = workspace.Assets:WaitForChild("Pre-Historic")
            local cf = ph and ph:WaitForChild("Coins")
            if cf then
                _ancientConn = cf.ChildAdded:Connect(function(coin)
                    local root = getRoot()
                    if root then
                        coin.Position   = root.Position
                        coin.Transparency = 0
                        coin.CanCollide  = false
                    end
                end)
            end
        end)
    else
        if _ancientConn then _ancientConn:Disconnect(); _ancientConn = nil end
    end
end})

TabMovie:Section({ Title="Math Mania" })
local _mathMov = false
TabMovie:Toggle({ Title="Auto-Win Math Mania", Desc="Auto-solves and submits all math questions", Value=false, Callback=function(v)
    _mathMov = v
    if v then task.spawn(function() while _mathMov do solveMath(); task.wait(1) end end) end
end})

TabMovie:Section({ Title="Rock & Roll" })
local _guitarConn = nil
TabMovie:Toggle({ Title="Auto Collect Guitars", Desc="Heartbeat collects all coins/gems in Rock & Roll", Value=false, Callback=function(v)
    if _guitarConn then _guitarConn:Disconnect(); _guitarConn = nil end
    if v then
        _guitarConn = RunService.Heartbeat:Connect(function()
            local root = getRoot(); if not root then return end
            local assets = workspace:FindFirstChild("Assets"); if not assets then return end
            try(function()
                for _, obj in pairs(assets:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Gem") then
                        obj.CFrame = root.CFrame * CFrame.new(0, 5, 0)
                    end
                end
            end)
        end)
    end
end})

TabMovie:Section({ Title="Prison" })
TabMovie:Button({ Title="Instantly Eat Poison Bowl", Desc="Fires clickdetector on every bowl in the prison", Callback=function()
    local count = 0
    try(function()
        for _, v in pairs(workspace.Assets:GetDescendants()) do
            if v.Name == "bowl" then
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd then for _ = 1, 10 do fireclickdetector(cd) end; count += 1 end
            end
        end
    end)
    WindUI:Notify({Title="Prison", Content="Fired " .. count .. " bowl(s)!", Duration=3})
end})

local _raygunProt = false
TabMovie:Toggle({ Title="Raygun Protection", Desc="Destroys all bullets so they cannot hit you", Value=false, Callback=function(v)
    _raygunProt = v
    if v then task.spawn(function()
        while _raygunProt do
            try(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "bullet" or obj.Name == "Bullet" then
                        local ti = obj:FindFirstChild("TouchInterest"); if ti then ti:Destroy() end
                        try(function() obj:Destroy() end)
                    end
                end
            end)
            task.wait(0.05)
        end
    end) end
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- EXPEDITION
-- ══════════════════════════════════════════════════════════════════════════════

TabExped:Section({ Title="Obby" })
local Gexpobby = TabExped:Group()
Gexpobby:Button({ Title="Win Obby", Justify="Center", Icon="solar:flag-bold", IconAlign="Left", Size="Small", Callback=winObby})
local _expObby = false
TabExped:Toggle({ Title="Auto-Win Obby", Desc="Finish line loops to your position", Value=false, Callback=function(v)
    _expObby = v
    if v then task.spawn(function() while _expObby do winObby(); task.wait(0.5) end end) end
end})

TabExped:Section({ Title="Collectibles" })
local _clovers = false
TabExped:Toggle({ Title="Auto-Collect Clovers", Desc="Moves all gems and coins to your character", Value=false, Callback=function(v)
    _clovers = v
    if v then task.spawn(function()
        while _clovers do
            local torso = lp.Character and lp.Character:FindFirstChild("Torso")
            if torso then
                try(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "Gem" or obj.Name == "Coin" then
                            obj.Transparency = 1; obj.Position = torso.Position
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end) end
end})

local _rings = false
TabExped:Toggle({ Title="Auto-Collect Rings", Desc="Moves all ring hitboxes to your character", Value=false, Callback=function(v)
    _rings = v
    if v then task.spawn(function()
        while _rings do
            local torso = lp.Character and lp.Character:FindFirstChild("Torso")
            if torso then
                try(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "RingHitbox" then
                            obj.Transparency = 1; obj.Position = torso.Position
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end) end
end})

TabExped:Section({ Title="Math Mania" })
local _mathExp = false
TabExped:Toggle({ Title="Auto-Win Math Mania", Desc="Auto-solves and submits all math questions", Value=false, Callback=function(v)
    _mathExp = v
    if v then task.spawn(function() while _mathExp do solveMath(); task.wait(1) end end) end
end})

TabExped:Section({ Title="Greece" })
local _greeceLoop = nil
TabExped:Toggle({ Title="Kill Everyone in Greece", Desc="Fires sword touch on all players every frame", Value=false, Callback=function(v)
    if _greeceLoop then _greeceLoop:Disconnect(); _greeceLoop = nil end
    if v then _greeceLoop = RunService.RenderStepped:Connect(killAllWithSword) end
end})

TabExped:Section({ Title="Amazon" })
TabExped:Button({ Title="Break Amazon (Spleef)", Desc="Fires touchinterest on all Amazon spleef parts", Callback=function()
    local root = getRoot(); if not root then return end
    for _, v in pairs(workspace.Assets:GetDescendants()) do
        if v.Name == "SpleefPart" then try(firetouchinterest, root, v, 0) end
    end
end})

TabExped:Section({ Title="France (Cheese Push)" })
local function findCheese(name) return workspace:FindFirstChild(name, true) end
local function findFinish()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "FinishingFade" then
            local h = v:FindFirstChild("Hitbox"); if h then return h end
        end
    end
end
local Gcheese = TabExped:Group()
Gcheese:Button({ Title="Push Cheese 1", Justify="Center", Icon="solar:map-point-bold", IconAlign="Left", Size="Small", Callback=function()
    local cheese, finish = findCheese("Cheese1"), findFinish()
    if cheese and finish then cheese.CFrame = finish.CFrame; WindUI:Notify({Title="France", Content="Cheese1 pushed!", Duration=3})
    else WindUI:Notify({Title="France", Content="Not found.", Duration=3}) end
end})
Gcheese:Space({ Columns=0.5 })
Gcheese:Button({ Title="Push Cheese 2", Justify="Center", Icon="solar:map-point-bold", IconAlign="Left", Size="Small", Callback=function()
    local cheese, finish = findCheese("Cheese2"), findFinish()
    if cheese and finish then cheese.CFrame = finish.CFrame; WindUI:Notify({Title="France", Content="Cheese2 pushed!", Duration=3})
    else WindUI:Notify({Title="France", Content="Not found.", Duration=3}) end
end})
local _cheesePush = false
TabExped:Toggle({ Title="Auto Push Cheese", Desc="Continuously pushes both cheeses to the finish", Value=false, Callback=function(v)
    _cheesePush = v
    if v then task.spawn(function()
        while _cheesePush do
            local finish = findFinish()
            if finish then
                for _, name in ipairs({"Cheese1","Cheese2"}) do
                    local cheese = findCheese(name)
                    if cheese then try(function() cheese.CFrame = finish.CFrame end) end
                end
            end
            task.wait(0.1)
        end
    end) end
end})

TabExped:Section({ Title="Italy" })
local _keepMeatball = false
local _meatballConn = nil
TabExped:Toggle({ Title="Keep Meatball After Round", Desc="Re-equips the meatball if it gets taken away", Value=false, Callback=function(v)
    _keepMeatball = v
    if _meatballConn then _meatballConn:Disconnect(); _meatballConn = nil end
    if v then
        _meatballConn = lp.Backpack.ChildRemoved:Connect(function(child)
            if child.Name ~= "Meatball" or not _keepMeatball then return end
            task.wait(0.5)
            if _keepMeatball and not lp.Backpack:FindFirstChild("Meatball") then
                local found = workspace:FindFirstChild("Meatball", true)
                if found then found:Clone().Parent = lp.Backpack end
            end
        end)
    end
end})

local _autoMeatball = false
TabExped:Toggle({ Title="Auto Collect Meatballs", Desc="Teleports all meatballs to you automatically", Value=false, Callback=function(v)
    _autoMeatball = v
    if v then task.spawn(function()
        while _autoMeatball do
            local root = getRoot()
            if root then try(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "Meatball" and obj:IsA("BasePart") then
                        try(firetouchinterest, root, obj, 0)
                        try(firetouchinterest, root, obj, 1)
                        obj.Position = root.Position
                    end
                end
            end) end
            task.wait(0.1)
        end
    end) end
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- MAIN
-- ══════════════════════════════════════════════════════════════════════════════

TabMain:Section({ Title="Safety Statue" })
local Gstatue = TabMain:Group()
Gstatue:Button({ Title="Get Statue/Bag", Justify="Center", Icon="solar:diploma-bold", IconAlign="Left", Size="Small", Callback=function()
    try(function()
        local torso = lp.Character and lp.Character:FindFirstChild("Torso"); if not torso then return end
        for _, v in pairs(workspace.Idols:GetDescendants()) do
            if v.Name == "Bag" or v.Name == "SafetyStatue" then
                local hit = v:FindFirstChild("hit"); if not hit then continue end
                hit.CanCollide  = false
                hit.Transparency = 1
                task.wait()
                hit.Position = torso.Position
                task.wait()
            end
        end
    end)
end})
Gstatue:Space({ Columns=0.5 })
Gstatue:Button({ Title="Who Has It", Justify="Center", Icon="solar:eye-bold", IconAlign="Left", Size="Small", Callback=function()
    try(function()
        local idol = RS.Season.Twists.Idol
        local holder = idol.Value
        local msg
        if holder == "" then
            msg = "Nobody has the statue."
        else
            local ok, name = try(function() return RS.Season.Players[holder].Value end)
            msg = (ok and name or holder) .. " has the statue."
        end
        WindUI:Notify({Title="Statue Status", Content=msg, Duration=5})
    end)
end})

TabMain:Toggle({ Title="Safety Bag ESP", Desc="Shows white highlight and label on all safety bags", Value=false, Callback=function(v)
    if v then try(function()
        for _, bag in ipairs(workspace.Idols:GetDescendants()) do
            if bag.Name == "Bag" and bag:IsA("Model") then
                local part = bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart"); if not part then continue end
                if not bag:FindFirstChild("BagHL") then
                    local hl = Instance.new("Highlight"); hl.Name = "BagHL"
                    hl.FillColor = Color3.fromRGB(255,255,255); hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.OutlineTransparency = 0
                    hl.Parent = bag
                end
                if not bag:FindFirstChild("BagESP") then
                    local bb = Instance.new("BillboardGui"); bb.Name = "BagESP"
                    bb.Size = UDim2.fromOffset(160,28); bb.StudsOffset = Vector3.new(0,3,0)
                    bb.AlwaysOnTop = true; bb.Adornee = part; bb.Parent = workspace
                    local lbl = Instance.new("TextLabel", bb); lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1; lbl.Text = "BAG"
                    lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.new(0,0,0); lbl.TextSize = 14; lbl.Font = Enum.Font.GothamBold
                end
            end
        end
    end)
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "BagHL" or obj.Name == "BagESP" then try(function() obj:Destroy() end) end
        end
    end
end})

TabMain:Toggle({ Title="Safety Statue ESP", Desc="Shows white highlight and label on all safety statues", Value=false, Callback=function(v)
    if v then try(function()
        for _, s in ipairs(workspace.Idols:GetDescendants()) do
            if s.Name == "SafetyStatue" and s:IsA("Model") then
                local part = s.PrimaryPart or s:FindFirstChildWhichIsA("BasePart"); if not part then continue end
                if not s:FindFirstChild("StatueHL") then
                    local hl = Instance.new("Highlight"); hl.Name = "StatueHL"
                    hl.FillColor = Color3.fromRGB(255,255,255); hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.OutlineTransparency = 0
                    hl.Parent = s
                end
                if not s:FindFirstChild("StatueESP") then
                    local bb = Instance.new("BillboardGui"); bb.Name = "StatueESP"
                    bb.Size = UDim2.fromOffset(160,28); bb.StudsOffset = Vector3.new(0,4,0)
                    bb.AlwaysOnTop = true; bb.Adornee = part; bb.Parent = workspace
                    local lbl = Instance.new("TextLabel", bb); lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1; lbl.Text = "STATUE"
                    lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.new(0,0,0); lbl.TextSize = 14; lbl.Font = Enum.Font.GothamBold
                end
            end
        end
    end)
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "StatueHL" or obj.Name == "StatueESP" then try(function() obj:Destroy() end) end
        end
    end
end})

TabMain:Section({ Title="Votes" })
local _vC, _pC, _eC, _exC, _juryC

TabMain:Toggle({ Title="Notify Votes", Desc="Shows a notification each time a vote is cast", Value=false, Callback=function(v)
    if _vC then _vC:Disconnect(); _vC = nil end
    if v then _vC = RS.Season.Voting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then WindUI:Notify({Title="Vote Cast", Content=voter.." voted for "..target, Duration=5}) end
    end) end
end})

TabMain:Toggle({ Title="Print Votes to Console", Desc="Prints each vote to the F9 developer console", Value=false, Callback=function(v)
    if _pC then _pC:Disconnect(); _pC = nil end
    if v then _pC = RS.Season.Voting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then print("[Ella Hub] Vote: " .. voter .. " → " .. target) end
    end) end
end})

TabMain:Toggle({ Title="Expose Votes in Chat", Desc="Sends each vote publicly in the game chat", Value=false, Callback=function(v)
    if _eC then _eC:Disconnect(); _eC = nil end
    if v then _eC = RS.Season.Voting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then
            try(function() game.TextChatService.TextChannels.RBXGeneral:SendAsync(voter.." voted for "..target) end)
        end
    end) end
end})

TabMain:Toggle({ Title="Notify & Expose Exile Votes", Desc="Notifies and exposes exile votes in chat", Value=false, Callback=function(v)
    if _exC then _exC:Disconnect(); _exC = nil end
    if v then _exC = RS.Season.Twists.ExileVoting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then
            local msg = voter .. " voted to exile " .. target
            WindUI:Notify({Title="Exile Vote", Content=msg, Duration=5})
            try(function() game.TextChatService.TextChannels.RBXGeneral:SendAsync(msg) end)
        end
    end) end
end})

TabMain:Toggle({ Title="Notify Jury Votes", Desc="Shows a notification each time a jury vote is cast", Value=false, Callback=function(v)
    if _juryC then _juryC:Disconnect(); _juryC = nil end
    if v then try(function()
        _juryC = RS.Season.Players.JuryVotes.ChildAdded:Connect(function(vote)
            local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
            local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
            if ok1 and ok2 then WindUI:Notify({Title="Jury Vote", Content=voter.." jury-voted for "..target, Duration=5}) end
        end)
    end) end
end})

-- ── Vote Log GUI ──────────────────────────────────────────────────────────────
local _vlOpen    = false
local _vlGui     = nil
local _vlConns   = {}
local _vlEntries = {}

local function closeVL()
    _vlOpen = false
    for _, c in ipairs(_vlConns) do try(function() c.conn:Disconnect() end) end
    _vlConns = {}
    if _vlGui then try(function() _vlGui:Destroy() end); _vlGui = nil end
end

local function makeVL()
    closeVL(); _vlOpen = true
    local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local W, H   = mobile and 280 or 340, mobile and 210 or 270
    local TH, FS = 30, mobile and 11 or 12

    -- Use best GUI parent
    local parent = lp:FindFirstChild("PlayerGui")
    try(function() if gethui then parent = gethui() end end)
    if not parent then try(function() parent = game:GetService("CoreGui") end) end

    local sg = Instance.new("ScreenGui")
    sg.Name = "VoteLogGui"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    try(function() sg.IgnoreGuiInset = true end)
    sg.Parent = parent; _vlGui = sg

    local fr = Instance.new("Frame"); fr.Name = "VL"
    fr.Size = UDim2.fromOffset(W, H); fr.Position = UDim2.fromOffset(24, 130)
    fr.BackgroundColor3 = Color3.fromRGB(10,10,14); fr.BorderSizePixel = 0
    fr.ClipsDescendants = true; fr.Parent = sg
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)

    local tb = Instance.new("Frame"); tb.Name = "TB"
    tb.Size = UDim2.new(1,0,0,TH); tb.BackgroundColor3 = Color3.fromRGB(16,16,22)
    tb.BorderSizePixel = 0; tb.Parent = fr
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    -- Cover bottom-radius of title bar
    local tbc = Instance.new("Frame")
    tbc.Size = UDim2.new(1,0,0,8); tbc.Position = UDim2.new(0,0,1,-8)
    tbc.BackgroundColor3 = Color3.fromRGB(16,16,22); tbc.BorderSizePixel = 0; tbc.Parent = tb

    local ico = Instance.new("TextLabel"); ico.Size = UDim2.fromOffset(TH,TH)
    ico.BackgroundTransparency = 1; ico.Text = "🗑"; ico.TextSize = 13
    ico.Font = Enum.Font.Gotham; ico.TextColor3 = Color3.fromRGB(160,160,160); ico.Parent = tb

    local ttl = Instance.new("TextLabel"); ttl.Size = UDim2.new(0,80,1,0)
    ttl.Position = UDim2.fromOffset(TH+2, 0); ttl.BackgroundTransparency = 1
    ttl.Text = "Vote Log"; ttl.TextSize = 12; ttl.Font = Enum.Font.GothamBold
    ttl.TextColor3 = Color3.fromRGB(210,210,210); ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = tb

    local function mkBtn(txt, xoff, fs)
        local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(TH,TH)
        b.Position = UDim2.new(1,xoff,0,0); b.BackgroundTransparency = 1
        b.Text = txt; b.TextSize = fs or 14; b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.fromRGB(190,190,190); b.Parent = tb; return b
    end
    local closeB = mkBtn("×", -TH, 16)
    local minB   = mkBtn("–", -(TH*2), 15)
    local asB    = mkBtn("↓", -(TH*3), 13)

    local filters = {
        {label="Votes", key="v", active=true, col=Color3.fromRGB(100,180,255)},
        {label="Jury",  key="j", active=true, col=Color3.fromRGB(255,200,80)},
        {label="Exile", key="e", active=true, col=Color3.fromRGB(255,120,120)},
    }
    local pillX = TH + 60
    for _, f in ipairs(filters) do
        local pill = Instance.new("TextButton"); pill.Size = UDim2.fromOffset(36,16)
        pill.Position = UDim2.fromOffset(pillX, 7)
        pill.BackgroundColor3 = f.active and f.col or Color3.fromRGB(40,40,50)
        pill.BackgroundTransparency = 0.3; pill.Text = f.label
        pill.TextSize = 9; pill.Font = Enum.Font.GothamBold
        pill.TextColor3 = Color3.fromRGB(220,220,220); pill.Parent = tb
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        pillX += 38
        local fRef = f
        pill.MouseButton1Click:Connect(function()
            fRef.active = not fRef.active
            pill.BackgroundColor3 = fRef.active and fRef.col or Color3.fromRGB(40,40,50)
        end)
    end

    local sc = Instance.new("ScrollingFrame"); sc.Name = "SC"
    sc.Size = UDim2.new(1,-4,1,-(TH+3)); sc.Position = UDim2.new(0,2,0,TH+1)
    sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 3; sc.ScrollBarImageColor3 = Color3.fromRGB(70,70,100)
    sc.ScrollingDirection = Enum.ScrollingDirection.Y
    sc.CanvasSize = UDim2.fromOffset(0,0); sc.ElasticBehavior = Enum.ElasticBehavior.Never
    sc.Parent = fr

    local lay = Instance.new("UIListLayout"); lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0,1); lay.Parent = sc

    local autoScroll = true
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y + 4)
        if autoScroll then sc.CanvasPosition = Vector2.new(0, math.huge) end
    end)
    sc.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseWheel or i.UserInputType == Enum.UserInputType.Touch then
            autoScroll = false; asB.Text = "↑"; asB.TextColor3 = Color3.fromRGB(160,160,160)
        end
    end)

    local emp = Instance.new("TextLabel"); emp.Name = "Empty"
    emp.Size = UDim2.new(1,-6,0,22); emp.BackgroundTransparency = 1
    emp.Text = "Waiting for votes..."; emp.TextSize = FS; emp.Font = Enum.Font.Gotham
    emp.TextColor3 = Color3.fromRGB(80,80,100); emp.TextXAlignment = Enum.TextXAlignment.Left
    emp.LayoutOrder = 0; emp.Parent = sc

    local entN = 0
    local function addEntry(txt, col, filterKey)
        if not _vlOpen then return end
        local filt
        for _, f in ipairs(filters) do if f.key == filterKey then filt = f; break end end
        if filt and not filt.active then return end
        emp.Visible = false; entN += 1
        table.insert(_vlEntries, {text=txt, color=col, order=entN})
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-6,0,FS+5)
        lbl.BackgroundTransparency = 1; lbl.Text = txt; lbl.TextColor3 = col
        lbl.TextSize = FS; lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.LayoutOrder = entN; lbl.Parent = sc
        -- Trim oldest entries to prevent memory growth
        if #_vlEntries > 150 then
            for _, c in ipairs(sc:GetChildren()) do
                if c:IsA("TextLabel") and c.Name ~= "Empty" then c:Destroy(); break end
            end
            table.remove(_vlEntries, 1)
        end
        if autoScroll then sc.CanvasPosition = Vector2.new(0, math.huge) end
    end

    if #_vlEntries > 0 then emp.Visible = false end
    for _, e in ipairs(_vlEntries) do
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-6,0,FS+5)
        lbl.BackgroundTransparency = 1; lbl.Text = e.text; lbl.TextColor3 = e.color
        lbl.TextSize = FS; lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.LayoutOrder = e.order; lbl.Parent = sc
    end
    entN = #_vlEntries

    local function hookVote(getter, label, col, filterKey)
        local c = {conn=nil}
        local function tryHook()
            local ok, src = try(getter)
            if not ok or not src then return false end
            c.conn = src.ChildAdded:Connect(function(vote)
                if not _vlOpen then return end
                local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
                local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
                if ok1 and ok2 then
                    addEntry(os.date("%H:%M") .. " " .. label .. voter .. " → " .. target, col, filterKey)
                end
            end)
            table.insert(_vlConns, c); return true
        end
        if not tryHook() then
            task.spawn(function() while _vlOpen and not c.conn do task.wait(1); tryHook() end end)
        end
    end
    hookVote(function() return RS.Season.Voting.Votes end,           "",          Color3.fromRGB(140,200,255), "v")
    hookVote(function() return RS.Season.Players.JuryVotes end,      "[JURY] ",   Color3.fromRGB(255,200,80),  "j")
    hookVote(function() return RS.Season.Twists.ExileVoting.Votes end,"[EXILE] ", Color3.fromRGB(255,120,120), "e")

    asB.MouseButton1Click:Connect(function()
        autoScroll = not autoScroll
        asB.Text = autoScroll and "↓" or "↑"
        asB.TextColor3 = autoScroll and Color3.fromRGB(90,210,90) or Color3.fromRGB(160,160,160)
        if autoScroll then sc.CanvasPosition = Vector2.new(0, math.huge) end
    end)
    local minimised = false
    minB.MouseButton1Click:Connect(function()
        minimised = not minimised
        fr.Size = UDim2.fromOffset(W, minimised and TH or H)
        sc.Visible = not minimised
        minB.Text = minimised and "+" or "–"
    end)
    closeB.MouseButton1Click:Connect(closeVL)

    -- Dragging
    local drag, dStart, fStart = false, Vector2.zero, Vector2.zero
    tb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = Vector2.new(i.Position.X, i.Position.Y)
            local ap = fr.AbsolutePosition; fStart = Vector2.new(ap.X, ap.Y)
        end
    end)
    local c1 = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    local c2 = UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d  = Vector2.new(i.Position.X, i.Position.Y) - dStart
            local vp = workspace.CurrentCamera.ViewportSize
            fr.Position = UDim2.fromOffset(
                math.clamp(fStart.X + d.X, 0, vp.X - W),
                math.clamp(fStart.Y + d.Y, 0, vp.Y - TH)
            )
        end
    end)
    sg.Destroying:Connect(function() c1:Disconnect(); c2:Disconnect() end)
end

TabMain:Button({ Title="Vote Log GUI", Desc="Opens a movable dark GUI logging all votes live", Callback=function()
    if _vlOpen then closeVL(); WindUI:Notify({Title="Vote Log", Content="Closed.", Duration=2})
    else makeVL(); WindUI:Notify({Title="Vote Log", Content="Opened! Waiting for votes...", Duration=3}) end
end})

TabMain:Section({ Title="Round Info" })
local TWIST_MSGS = {
    Undecided  = "Not decided yet.",
    normal     = "Normal round.",
    purge      = "🔥 PURGE round!",
    double     = "⚡ Double elimination!",
    singleswap = "🔀 Sike — swap teams.",
    exile      = "🏝️ Exile vote.",
    votereveal = "👁️ Vote reveal.",
    merge      = "💥 MERGE!",
}
local Gdetect = TabMain:Group()
Gdetect:Button({ Title="Round Type", Justify="Center", Icon="solar:bolt-circle-bold", IconAlign="Left", Size="Small", Callback=function()
    try(function()
        local t = RS.Season.Twists:FindFirstChild("CurrentTwist"); if not t then return end
        WindUI:Notify({Title="Round Type", Content=TWIST_MSGS[t.Value] or t.Value, Duration=5})
    end)
end})
Gdetect:Space({ Columns=0.5 })
Gdetect:Button({ Title="Teamers", Justify="Center", Icon="solar:users-group-two-rounded-bold", IconAlign="Left", Size="Small", Callback=function()
    try(function()
        local pf = RS:FindFirstChild("Season") and RS.Season:FindFirstChild("Players"); if not pf then return end
        local function ign(p) local d = pf:FindFirstChild(p.Name); return d and d.Value ~= "" and d.Value or p.Name end
        local found = false
        local plrs = Players:GetPlayers()
        for i = 1, #plrs do
            for j = i + 1, #plrs do
                local ok, fr2 = try(function() return plrs[i]:IsFriendsWith(plrs[j].UserId) end)
                if ok and fr2 then
                    found = true
                    WindUI:Notify({Title="Teamers!", Content=ign(plrs[i]).." & "..ign(plrs[j]).." are friends.", Duration=5})
                end
            end
        end
        if not found then WindUI:Notify({Title="Teamers", Content="No teamers detected.", Duration=5}) end
    end)
end})

local _rdActive = false
TabMain:Toggle({ Title="Round Detector", Desc="Notifies on twists BEFORE the round starts + merges", Value=false, Callback=function(v)
    _rdActive = v
    if v then
        task.spawn(function()
            local conns = {}
            local ok, twist = try(function() return RS.Season.Twists.CurrentTwist end)
            if ok and twist then
                local cur = twist.Value
                if cur and cur ~= "" and cur ~= "Undecided" then
                    WindUI:Notify({Title="Current Twist", Content=TWIST_MSGS[cur] or cur, Duration=6})
                end
                table.insert(conns, twist.Changed:Connect(function(val)
                    if not _rdActive then return end
                    local msg = TWIST_MSGS[val]
                    if msg then WindUI:Notify({Title="⚠️ Twist Incoming!", Content=msg, Duration=8}) end
                end))
            end
            while _rdActive do task.wait(1) end
            for _, c in ipairs(conns) do try(function() c:Disconnect() end) end
        end)
        WindUI:Notify({Title="Round Detector", Content="Watching for twists and merges.", Duration=3})
    end
end})

TabMain:Section({ Title="Utilities" })
TabMain:Button({ Title="Remove Intro Cutscene", Desc="Destroys the intro camera cutscene", Callback=function()
    try(function()
        local ev = RS:FindFirstChild("Events")
        local cam = ev and ev:FindFirstChild("Camera"); if cam then cam:Destroy() end
        local hum = getHumanoid()
        if hum then
            workspace.CurrentCamera.CameraType    = Enum.CameraType.Custom
            workspace.CurrentCamera.CameraSubject = hum
        end
    end)
end})
TabMain:Button({ Title="Fling / Reanimate", Desc="Executes the reanimate script", Callback=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/robloxcheatck/reanimatescript/main/script.lua"))()
end})
TabMain:Button({ Title="Open Console", Desc="Opens the developer console", Callback=function()
    StarterGui:SetCore("DevConsoleVisible", true)
end})

local _blkConn
TabMain:Toggle({ Title="Auto-Block Long Usernames", Desc="Truncates very long display names to prevent lag", Value=false, Callback=function(v)
    if _blkConn then _blkConn:Disconnect(); _blkConn = nil end
    if v then _blkConn = RunService.RenderStepped:Connect(function()
        for _, plr in pairs(Players:GetPlayers()) do
            try(function()
                local head = plr.Character and plr.Character:FindFirstChild("Head"); if not head then return end
                local ng   = head:FindFirstChild("NameGUI") or head:FindFirstChild("playerName"); if not ng then return end
                local lbl  = ng:FindFirstChild("Sector") and ng.Sector:FindFirstChild("name")
                if lbl and lbl:IsA("TextLabel") and #lbl.Text > 700 then lbl.Text = lbl.Text:sub(1,1) .. "..." end
            end)
        end
    end) end
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- CHARACTERS
-- ══════════════════════════════════════════════════════════════════════════════

TabChars:Section({ Title="Free" })
local Ggender = TabChars:Group()
Ggender:Button({ Title="Set Male",   Justify="Center", Icon="solar:user-bold", IconAlign="Left", Size="Small", Callback=function() RS.Events.Buy:FireServer("Gender","Male")   end})
Ggender:Space({ Columns=0.5 })
Ggender:Button({ Title="Set Female", Justify="Center", Icon="solar:user-bold", IconAlign="Left", Size="Small", Callback=function() RS.Events.Buy:FireServer("Gender","Female") end})

TabChars:Section({ Title="Buy Character" })
local _charSym  = ""
local _charName = ""
local _symMap   = {["None"]="", ["Verified"]="", ["Premium"]="", ["Robux"]=""}
TabChars:Dropdown({ Title="Symbol", Desc="Choose a symbol to append to the character name", Values={"None","Verified","Premium","Robux"}, Value=1, Callback=function(opt) _charSym = _symMap[opt] or "" end})
TabChars:Input({ Title="Character Name", Desc="Type the exact character name to purchase", Placeholder="Enter name...", Callback=function(t) _charName = t end})
TabChars:Button({ Title="Buy Character (60 coins)", Desc="Fires the buy remote with your entered name", Callback=function()
    if _charName == "" then WindUI:Notify({Title="Buy", Content="Enter a character name first.", Duration=3}); return end
    RS.Events.Buy:FireServer("Character", _charName .. (_charSym ~= "" and " " .. _charSym or ""))
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- PLAYER
-- ══════════════════════════════════════════════════════════════════════════════

TabPlyr:Section({ Title="Movement" })
TabPlyr:Space({ Columns=2 })
TabPlyr:Slider({ Title="Walk Speed", IsTooltip=true, Step=1, Value={Min=1,Max=350,Default=16},
    Icons={From="solar:ghost-bold",To="solar:running-2-bold"},
    Callback=function(v) local h = getHumanoid(); if h then h.WalkSpeed = v end end})
TabPlyr:Space({ Columns=1 })
TabPlyr:Slider({ Title="Jump Power", IsTooltip=true, Step=1, Value={Min=1,Max=350,Default=50},
    Icons={From="solar:arrow-up-bold",To="solar:rocket-bold"},
    Callback=function(v) local h = getHumanoid(); if h then h.JumpPower = v end end})

TabPlyr:Section({ Title="Map" })
TabPlyr:Button({ Title="Remove Glass Barriers", Desc="Destroys all glass barrier parts in the map", Callback=function()
    for _, v in pairs(workspace:GetDescendants()) do if v.Name == "Glass" then try(function() v:Destroy() end) end end
end})
TabPlyr:Toggle({ Title="Walk on Lake", Desc="Enables lake collision", Value=false, Callback=function(v)
    try(function() workspace.Map["Roblox Drama: Camp"].Map.Lake.Water.CanCollide = v end)
end})
TabPlyr:Button({ Title="Lake God-Mode", Desc="Destroys the lake sand touch interest", Callback=function()
    try(function() workspace.Map["Roblox Drama: Camp"].Sand.TouchInterest:Destroy() end)
end})

TabPlyr:Section({ Title="Target Player" })
local _tgt = ""
local _pHL  = nil

local function buildPList()
    local l = {}
    local ok, sp = try(function() return RS:WaitForChild("Season",5):WaitForChild("Players",5) end)
    if not ok or not sp then return l end
    for _, v in ipairs(sp:GetChildren()) do
        if v:IsA("ValueBase") and v.Name ~= lp.Name and v.Value ~= "" then table.insert(l, v.Value) end
    end
    return l
end
local function refreshPDD(dd)
    local nl = buildPList(); if #nl == 0 then nl = {"(none)"} end
    dd:Refresh(nl); _tgt = nl[1]
end

local _pl = buildPList()
local PDD = TabPlyr:Dropdown({ Title="Choose Player", Desc="Select a player to target",
    Values=#_pl > 0 and _pl or {"(none)"}, Value=1,
    Callback=function(opt) _tgt = opt end})
if #_pl > 0 then _tgt = _pl[1] end

-- Auto-refresh on join/leave
Players.PlayerAdded:Connect(function()   task.wait(1);   refreshPDD(PDD) end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); refreshPDD(PDD) end)

local Gplyr = TabPlyr:Group()
Gplyr:Button({ Title="Teleport To", Justify="Center", Icon="solar:map-point-bold", IconAlign="Left", Size="Small", Callback=function()
    try(function()
        local sp = RS:FindFirstChild("Season") and RS.Season:FindFirstChild("Players"); if not sp then return end
        for _, v in ipairs(sp:GetChildren()) do
            if v.Value == _tgt then
                local t = Players:FindFirstChild(v.Name)
                if t and t.Character then
                    local tRoot = t.Character:FindFirstChild("HumanoidRootPart")
                    local myRoot = getRoot()
                    if tRoot and myRoot then myRoot.CFrame = tRoot.CFrame end
                end
                break
            end
        end
    end)
end})
Gplyr:Space({ Columns=0.5 })
Gplyr:Button({ Title="Refresh List", Justify="Center", Icon="solar:refresh-bold", IconAlign="Left", Size="Small", Callback=function()
    refreshPDD(PDD)
    WindUI:Notify({Title="Player List", Content="Refreshed " .. #buildPList() .. " players.", Duration=2})
end})

TabPlyr:Toggle({ Title="Highlight Player", Desc="Adds a yellow highlight to the selected player", Value=false, Callback=function(v)
    try(function()
        local sp = RS:FindFirstChild("Season") and RS.Season:FindFirstChild("Players"); if not sp then return end
        for _, e in ipairs(sp:GetChildren()) do
            if e.Value == _tgt then
                local t = Players:FindFirstChild(e.Name); if not t or not t.Character then return end
                if _pHL then _pHL:Destroy(); _pHL = nil end
                if v then
                    _pHL = Instance.new("Highlight")
                    _pHL.FillColor         = Color3.fromRGB(255,221,0)
                    _pHL.OutlineColor      = Color3.fromRGB(255,221,0)
                    _pHL.FillTransparency  = 0.5
                    _pHL.OutlineTransparency = 0
                    _pHL.Parent = t.Character
                end
                break
            end
        end
    end)
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- STATS
-- ══════════════════════════════════════════════════════════════════════════════

TabStats:Section({ Title="Player Stats" })
local _sTgt = ""
local _plyL = {}
for _, p in ipairs(Players:GetPlayers()) do table.insert(_plyL, p.Name) end
_sTgt = _plyL[1] or ""

local SDD = TabStats:Dropdown({ Title="Choose Player", Desc="Select a player to view their stats",
    Values=#_plyL > 0 and _plyL or {"(none)"}, Value=1,
    Callback=function(v) _sTgt = v end})

TabStats:Button({ Title="Refresh List", Desc="Updates the list with current players", Callback=function()
    local nl = {}; for _, p in ipairs(Players:GetPlayers()) do table.insert(nl, p.Name) end
    SDD:Refresh(nl); if #nl > 0 then _sTgt = nl[1] end
end})

local function getDS(key)
    local plr = Players:FindFirstChild(_sTgt)
    if not plr then WindUI:Notify({Title="Stats", Content="Player not found.", Duration=4}); return nil end
    local ds  = plr:FindFirstChild("DataStore")
    if not ds  then WindUI:Notify({Title="Stats", Content="No DataStore.", Duration=4}); return nil end
    local val = ds:FindFirstChild(key)
    if not val then WindUI:Notify({Title="Stats", Content=key.." not found.", Duration=4}); return nil end
    return val
end

local function statBtn(label, key, title, desc, fmt)
    TabStats:Button({Title=label, Desc=desc, Callback=function()
        local v = getDS(key); if v then WindUI:Notify({Title=title, Content=fmt(v), Duration=5}) end
    end})
end
statBtn("Camp Wins",       "CampWins",       "Camp Wins",       "Shows camp win count",       function(v) return _sTgt.." has "..v.Value.." camp wins." end)
statBtn("Movie Wins",      "MoviesWins",     "Movie Wins",      "Shows movie win count",      function(v) return _sTgt.." has "..v.Value.." movie wins." end)
statBtn("Expedition Wins", "ExpeditionWins", "Expedition Wins", "Shows expedition win count", function(v) return _sTgt.." has "..v.Value.." expedition wins." end)
statBtn("Coins",           "Coins",          "Coins",           "Shows coin balance",         function(v) return _sTgt.." has "..v.Value.." coins." end)
statBtn("Comeback Wins",   "ComebackWins",   "Comeback Wins",   "Shows comeback win count",   function(v) return _sTgt.." has "..v.Value.." comeback wins." end)
statBtn("Games Played",    "GamesPlayed",    "Games Played",    "Shows total games played",   function(v) return _sTgt.." played "..v.Value.." games." end)
statBtn("Idols Found",     "IdolsFound",     "Idols Found",     "Shows idols found",          function(v) return _sTgt.." found "..v.Value.." idols." end)

TabStats:Button({ Title="Skins", Desc="Lists all skins owned by selected player", Callback=function()
    local plr = Players:FindFirstChild(_sTgt); if not plr then return end
    local sk  = plr:FindFirstChild("DataStore") and plr.DataStore:FindFirstChild("Skins")
    if not sk then WindUI:Notify({Title="Skins", Content=_sTgt.." has no skins.", Duration=4}); return end
    local names = {}; for _, s in ipairs(sk:GetChildren()) do table.insert(names, s.Name) end
    WindUI:Notify({Title="Skins", Content=#names==0 and _sTgt.." has no skins." or table.concat(names,", "), Duration=6})
end})
TabStats:Button({ Title="Marshmallows", Desc="Lists all marshmallows owned by selected player", Callback=function()
    local plr = Players:FindFirstChild(_sTgt); if not plr then return end
    local ms  = plr:FindFirstChild("DataStore") and plr.DataStore:FindFirstChild("Marshmallows")
    if not ms then WindUI:Notify({Title="Marshmallows", Content=_sTgt.." has none.", Duration=4}); return end
    local names = {}; for _, m in ipairs(ms:GetChildren()) do table.insert(names, m.Name) end
    WindUI:Notify({Title="Marshmallows", Content=#names==0 and _sTgt.." has none." or table.concat(names,", "), Duration=6})
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- TELEPORTS
-- ══════════════════════════════════════════════════════════════════════════════

local function tpBtn(tab, name, x, y, z, desc)
    tab:Button({Title=name, Desc=desc or "Teleport to "..name, Callback=function()
        local root = getRoot()
        if root then root.CFrame = CFrame.new(x, y, z) end
    end})
end

TabTp:Section({ Title="Camp" })
tpBtn(TabTp,"Spectator Island", 33,-16,31,    "Teleport to the spectator island")
tpBtn(TabTp,"Main Island",      150,-17,-417, "Teleport to the main island")
tpBtn(TabTp,"Exile Island",    -116,-14,-166, "Teleport to the exile island")
tpBtn(TabTp,"Voting Area",     -23,95,-514,   "Teleport to the voting area")
tpBtn(TabTp,"Boat",             47,-20,-297,  "Teleport to the boat")
tpBtn(TabTp,"Bathroom",         302,-15,-325, "Teleport to the bathroom area")

TabTp:Section({ Title="Movie" })
tpBtn(TabTp,"Starter Island",  -672,-67,-617, "Teleport to the starter island")
tpBtn(TabTp,"Voting Area",      83,60,-187,   "Teleport to the movie voting area")
tpBtn(TabTp,"Cabin 1",         -1,56,-34,     "Teleport to cabin 1")
tpBtn(TabTp,"Cabin 2",         -8,53,144,     "Teleport to cabin 2")
tpBtn(TabTp,"Dining Room",     -1,53,168,     "Teleport to the dining room")
tpBtn(TabTp,"Kitchen",        -210,49,30,     "Teleport to the kitchen")
tpBtn(TabTp,"Inside Boat",    -47,80,-28,     "Teleport inside the boat")

TabTp:Section({ Title="Expedition" })
tpBtn(TabTp,"Ship Voting Area",  -154,101,-31, "Teleport to the expedition ship voting area")
tpBtn(TabTp,"First Class (VIP)",  154,98,-33,  "Teleport to first class / VIP area")
tpBtn(TabTp,"2nd Class",           50,98,-34,  "Teleport to 2nd class area")
tpBtn(TabTp,"Ship Bathroom",        5,98,-23,  "Teleport to the ship bathroom")
tpBtn(TabTp,"Dining Class",       -45,98,-34,  "Teleport to the dining class area")
tpBtn(TabTp,"Basement",           -47,80,-28,  "Teleport to the basement")

-- ══════════════════════════════════════════════════════════════════════════════
-- UNIVERSAL
-- ══════════════════════════════════════════════════════════════════════════════

TabUniv:Section({ Title="Tools" })
TabUniv:Button({ Title="VC Unban",           Desc="Rejoins voice chat to bypass a voice ban",     Callback=function() try(function() game:GetService("VoiceChatService"):joinVoice() end) end})
TabUniv:Button({ Title="Apply Shaders",      Desc="Applies custom lighting and sky shaders",       Callback=function()
    try(function()
        local l = game:GetService("Lighting")
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        l.Technology     = Enum.Technology.ShadowMap
        l.ShadowSoftness = 0.15; l.ClockTime = 9; l.Brightness = 5
        l.Ambient        = Color3.fromRGB(70,70,70)
        l.ColorShift_Top = Color3.fromRGB(255,138,35)
        l.OutdoorAmbient = Color3.fromRGB(135,135,135)
        l.GlobalShadows  = true; l.ExposureCompensation = 0
        local t = workspace.Terrain
        t.WaterReflectance = 0.08; t.WaterTransparency = 0.85
        t.WaterDefaultColor = Color3.fromRGB(12,84,92)
        local sky = Instance.new("Sky", l)
        sky.SkyboxBk="rbxassetid://271042516"; sky.SkyboxDn="rbxassetid://271077243"
        sky.SkyboxFt="rbxassetid://271042556"; sky.SkyboxLf="rbxassetid://271042310"
        sky.SkyboxRt="rbxassetid://271042467"; sky.SkyboxUp="rbxassetid://271077958"
    end)
end})
TabUniv:Button({ Title="Infinite Yield",     Desc="Loads Infinite Yield FE admin commands",        Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
TabUniv:Button({ Title="Fly GUI",            Desc="Loads a fly script with GUI controls",           Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end})
TabUniv:Button({ Title="Wall Hop",           Desc="Loads a wall hop movement script",               Callback=function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Roblox-WallHop-Script-38387"))() end})
TabUniv:Button({ Title="Sound Panel",        Desc="Loads a sound control panel",                    Callback=function() loadstring(game:HttpGet("https://pastebin.com/raw/w3uzjgEq"))() end})
TabUniv:Button({ Title="Energize Animations",Desc="Opens the FE animation GUI",                     Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Bruhology/ella-hub/main/Energize.lua"))() end})
TabUniv:Button({ Title="Bring Back Old Chat",Desc="Restores the old Roblox chat UI",                Callback=function()
    loadstring(game:HttpGet("https://pastebin.com/raw/9AQrDua1"))()
    WindUI:Notify({Title="Chat", Content="Old chat loaded!", Duration=3})
end})

TabUniv:Section({ Title="Misc" })
local _collisionActive = false
TabUniv:Toggle({ Title="Collision", Desc="Adds invisible collision to all other players' characters", Value=false, Callback=function(v)
    _collisionActive = v
    if v then task.spawn(function()
        while _collisionActive do
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= lp then
                    local char = workspace:FindFirstChild(plr.Name)
                    if char and not char:FindFirstChild("CHECKER") then
                        try(function()
                            Instance.new("BoolValue", char).Name = "CHECKER"
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") or part:IsA("MeshPart") then
                                    local col = Instance.new("Part", part)
                                    col.Size = part.Size; col.Position = part.Position; col.Transparency = 1
                                    local weld = Instance.new("Weld", part)
                                    weld.Part0 = part; weld.Part1 = col
                                end
                            end
                        end)
                    end
                end
            end
            task.wait(3)
        end
    end) end
end})

TabUniv:Section({ Title="Fonts" })
local function loadFonts()
    try(function()
        local function dlFont(filename, id)
            if not isfile(filename) then writefile(filename, game:HttpGet("https://drive.google.com/uc?export=download&id="..id)) end
        end
        dlFont("starborn.ttf",    "1k9H8G60p7iaJL4hHcyWEXgWJbONqam8_")
        dlFont("vhsgothic.ttf",   "1XRWSIsNj9-v-vnrOCdYiUJIvz6ETAzfE")
        dlFont("minecrafter.ttf", "1_LSZQUGrKHzJctxK7Jp8rVRRVWIvdif4")
        dlFont("horror.ttf",      "1dH4Y_ZuoTeMouMQoGZSc1OVLT7-73zmq")
        local function makeJson(name, file)
            writefile(name..".json", HttpService:JSONEncode({name=name,faces={{style="normal",assetId=getcustomasset(file),name="Regular",weight=400}}}))
        end
        makeJson("Starborn",    "starborn.ttf")
        makeJson("VHS",         "vhsgothic.ttf")
        makeJson("Minecrafter", "minecrafter.ttf")
        makeJson("Horror",      "horror.ttf")
    end)
end
local function applyFont(jsonFile, fontName)
    try(function()
        local f = Font.new(getcustomasset(jsonFile))
        local function apply(obj)
            try(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then obj.FontFace = f end
            end)
        end
        for _, v in pairs(lp.PlayerGui:GetDescendants()) do apply(v) end
        lp.PlayerGui.DescendantAdded:Connect(apply)
        WindUI:Notify({Title="Fonts", Content=fontName.." applied!", Duration=3})
    end)
end
TabUniv:Button({ Title="Load Fonts",    Desc="Download all fonts before applying",  Callback=function()
    WindUI:Notify({Title="Fonts", Content="Downloading fonts...", Duration=4})
    task.spawn(function() loadFonts(); WindUI:Notify({Title="Fonts", Content="Done! Now pick a font.", Duration=4}) end)
end})
TabUniv:Button({ Title="Starborn",    Desc="Apply Starborn font",    Callback=function() applyFont("Starborn.json","Starborn") end})
TabUniv:Button({ Title="VHS",         Desc="Apply VHS gothic font",  Callback=function() applyFont("VHS.json","VHS") end})
TabUniv:Button({ Title="Minecrafter", Desc="Apply Minecrafter font", Callback=function() applyFont("Minecrafter.json","Minecrafter") end})
TabUniv:Button({ Title="Horror",      Desc="Apply Horror font",      Callback=function() applyFont("Horror.json","Horror") end})

-- ══════════════════════════════════════════════════════════════════════════════
-- OTHER — Auto Farm, Farm Screen, Webhooks, etc.
-- ══════════════════════════════════════════════════════════════════════════════

TabOther:Section({ Title="Auto Farm" })

local _farmActive  = false
local _farmConns   = {}
local _farmRunning = false

local function stopFarm()
    _farmActive  = false
    _farmRunning = false
    for _, c in ipairs(_farmConns) do try(function() c:Disconnect() end) end
    _farmConns = {}
end

local function runFarmCycle(label)
    if not _farmActive or _farmRunning then return end
    _farmRunning = true
    WindUI:Notify({Title="Auto Farm", Content=label.." — Reanimating!", Duration=3})
    task.spawn(function()
        try(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/robloxcheatck/reanimatescript/main/script.lua",true))() end)
        task.wait(25)
        try(function() Stop() end)
        task.wait(0.5)
        local hum = getHumanoid()
        if hum then hum.Health = 0 end
        -- Wait for respawn then reset running flag
        lp.CharacterAdded:Wait()
        task.wait(1.5)
        _farmRunning = false
    end)
end

local function watchStat(plr, statName)
    local ds   = plr:FindFirstChild("DataStore") or plr:WaitForChild("DataStore", 10)
    local stat = ds and (ds:FindFirstChild(statName) or ds:WaitForChild(statName, 10))
    if not stat then return end
    local lastVal = stat.Value
    table.insert(_farmConns, stat.Changed:Connect(function(newVal)
        if not _farmActive then return end
        if newVal <= lastVal then lastVal = newVal; return end
        lastVal = newVal
        task.spawn(function()
            runFarmCycle((plr == lp and "Your " or plr.Name .. "'s ") .. statName)
        end)
    end))
end

local function hookPlayer(plr)
    task.spawn(function()
        watchStat(plr, "CampWins")
        watchStat(plr, "MoviesWins")
        watchStat(plr, "ExpeditionWins")
    end)
end

TabOther:Toggle({ Title="Auto Farm Coin", Desc="Reanimates when any player wins + auto-win obby", Value=false, Callback=function(state)
    if state then
        _farmActive = true; _farmRunning = false; _farmConns = {}
        task.spawn(function()
            hookPlayer(lp)
            for _, plr in ipairs(Players:GetPlayers()) do if plr ~= lp then hookPlayer(plr) end end
            table.insert(_farmConns, Players.PlayerAdded:Connect(function(plr) if _farmActive then hookPlayer(plr) end end))
            task.spawn(function() while _farmActive do winObby(); task.wait(0.5) end end)
            WindUI:Notify({Title="Auto Farm", Content="Watching " .. #Players:GetPlayers() .. " players.", Duration=4})
        end)
    else stopFarm(); WindUI:Notify({Title="Auto Farm", Content="Stopped.", Duration=3}) end
end})

-- ── Farm Screen ───────────────────────────────────────────────────────────────
TabOther:Section({ Title="Farm Screen" })

local _fsActive    = false
local _fsGui       = nil
local _fsHidden    = {}
local _fsFloatConn = nil
local _fsFloatLoop = false
local _fsStatsLoop = false

local function fsFloat(char)
    char = char or lp.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.Anchored = true
        try(function() hrp.AssemblyLinearVelocity  = Vector3.zero end)
        try(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
    end
    if hum then hum.PlatformStand = true; hum.AutoRotate = false end
end

local function fsUnfloat()
    try(function()
        local char = lp.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.Anchored = false end
        if hum then hum.PlatformStand = false; hum.AutoRotate = true end
    end)
end

local function fsGetStat(ds, key)
    local v = ds:FindFirstChild(key); return v and tostring(v.Value) or "?"
end

local function fsBuildStats()
    local ds = lp:FindFirstChild("DataStore"); if not ds then return "Waiting for DataStore..." end
    return table.concat({
        "👤  " .. lp.DisplayName .. " (" .. lp.Name .. ")",
        "",
        "🏕️  Camp Wins:         " .. fsGetStat(ds,"CampWins"),
        "🎬  Movie Wins:        " .. fsGetStat(ds,"MoviesWins"),
        "🗺️  Expedition Wins:   " .. fsGetStat(ds,"ExpeditionWins"),
        "🪙  Coins:             " .. fsGetStat(ds,"Coins"),
        "🎮  Games Played:      " .. fsGetStat(ds,"GamesPlayed"),
        "🏆  Comeback Wins:     " .. fsGetStat(ds,"ComebackWins"),
        "🗿  Idols Found:       " .. fsGetStat(ds,"IdolsFound"),
    }, "\n")
end

TabOther:Toggle({ Title="Farm Screen", Desc="White screen + hidden models + floating + live stats", Value=false, Callback=function(v)
    _fsActive = v

    if v then
        -- 1. Hide all models
        _fsHidden = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= lp.Character and obj.Parent then
                try(function()
                    table.insert(_fsHidden, {model=obj, parent=obj.Parent})
                    obj.Parent = nil
                end)
            end
        end

        -- 2. Float loop (re-anchors every 0.1s, cannot be undone by game)
        _fsFloatLoop = true
        fsFloat()
        task.spawn(function() while _fsFloatLoop do try(fsFloat); task.wait(0.1) end end)
        _fsFloatConn = lp.CharacterAdded:Connect(function(char) task.wait(0.3); fsFloat(char) end)

        -- 3. Build white screen GUI parented to CoreGui/gethui
        local sg = Instance.new("ScreenGui")
        sg.Name = "FarmScreenGui"; sg.ResetOnSpawn = false
        sg.DisplayOrder = 999999; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        try(function() sg.IgnoreGuiInset = true end)
        local guiParent = lp.PlayerGui
        try(function() if gethui then guiParent = gethui() else guiParent = game:GetService("CoreGui") end end)
        sg.Parent = guiParent; _fsGui = sg

        -- White background
        local bg = Instance.new("Frame", sg)
        bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(255,255,255)
        bg.BorderSizePixel = 0; bg.ZIndex = 1

        -- Shadow under card
        local shadow = Instance.new("Frame", sg)
        shadow.Size = UDim2.fromOffset(390,330); shadow.Position = UDim2.new(0.5,-195,0.5,-162)
        shadow.BackgroundColor3 = Color3.fromRGB(0,0,0); shadow.BackgroundTransparency = 0.7
        shadow.BorderSizePixel = 0; shadow.ZIndex = 1
        Instance.new("UICorner", shadow).CornerRadius = UDim.new(0,16)

        -- Card
        local card = Instance.new("Frame", sg)
        card.Size = UDim2.fromOffset(380,320); card.Position = UDim2.new(0.5,-190,0.5,-160)
        card.BackgroundColor3 = Color3.fromRGB(15,15,15); card.BorderSizePixel = 0; card.ZIndex = 2
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)

        -- Title bar
        local titleBar = Instance.new("Frame", card)
        titleBar.Size = UDim2.new(1,0,0,42); titleBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
        titleBar.BorderSizePixel = 0; titleBar.ZIndex = 3
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,14)
        local tbFix = Instance.new("Frame", titleBar)
        tbFix.Size = UDim2.new(1,0,0,14); tbFix.Position = UDim2.new(0,0,1,-14)
        tbFix.BackgroundColor3 = Color3.fromRGB(25,25,25); tbFix.BorderSizePixel = 0; tbFix.ZIndex = 3

        local titleLbl = Instance.new("TextLabel", titleBar)
        titleLbl.Size = UDim2.new(1,-16,1,0); titleLbl.Position = UDim2.new(0,14,0,0)
        titleLbl.BackgroundTransparency = 1; titleLbl.Text = "🌿  Ella Hub — Live Farm Stats"
        titleLbl.TextColor3 = Color3.fromRGB(255,255,255); titleLbl.TextSize = 14
        titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 4

        -- Divider
        local div = Instance.new("Frame", card)
        div.Size = UDim2.new(1,-28,0,1); div.Position = UDim2.new(0,14,0,44)
        div.BackgroundColor3 = Color3.fromRGB(50,50,50); div.BorderSizePixel = 0; div.ZIndex = 3

        -- Stats label
        local statsLbl = Instance.new("TextLabel", card)
        statsLbl.Size = UDim2.new(1,-28,1,-58); statsLbl.Position = UDim2.new(0,14,0,52)
        statsLbl.BackgroundTransparency = 1; statsLbl.Text = "Loading..."
        statsLbl.TextColor3 = Color3.fromRGB(210,210,210); statsLbl.TextSize = 13
        statsLbl.Font = Enum.Font.Gotham; statsLbl.TextXAlignment = Enum.TextXAlignment.Left
        statsLbl.TextYAlignment = Enum.TextYAlignment.Top; statsLbl.ZIndex = 3

        -- Status bar
        local statusBar = Instance.new("Frame", card)
        statusBar.Size = UDim2.new(1,0,0,28); statusBar.Position = UDim2.new(0,0,1,-28)
        statusBar.BackgroundColor3 = Color3.fromRGB(25,25,25); statusBar.BorderSizePixel = 0; statusBar.ZIndex = 3
        Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0,14)
        local sbFix = Instance.new("Frame", statusBar)
        sbFix.Size = UDim2.new(1,0,0,14); sbFix.BackgroundColor3 = Color3.fromRGB(25,25,25)
        sbFix.BorderSizePixel = 0; sbFix.ZIndex = 3

        local statusLbl = Instance.new("TextLabel", statusBar)
        statusLbl.Size = UDim2.new(1,-16,1,0); statusLbl.Position = UDim2.new(0,14,0,0)
        statusLbl.BackgroundTransparency = 1; statusLbl.Text = "⬤  Farm Active"
        statusLbl.TextColor3 = Color3.fromRGB(100,255,150); statusLbl.TextSize = 11
        statusLbl.Font = Enum.Font.Gotham; statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.ZIndex = 4

        -- 4. Stats + stale detection loop
        _fsStatsLoop = true
        task.spawn(function()
            local lastSnap       = nil
            local lastChangeTick = tick()
            local warned         = false

            while _fsActive and _fsStatsLoop do
                try(function()
                    statsLbl.Text = fsBuildStats()
                    local ds = lp:FindFirstChild("DataStore")
                    if ds then
                        local snap = fsGetStat(ds,"CampWins")..fsGetStat(ds,"MoviesWins")..fsGetStat(ds,"ExpeditionWins")
                        if snap ~= lastSnap then
                            lastSnap       = snap
                            lastChangeTick = tick()
                            warned         = false
                            statsLbl.TextColor3  = Color3.fromRGB(210,210,210)
                            statusLbl.Text       = "⬤  Farm Active"
                            statusLbl.TextColor3 = Color3.fromRGB(100,255,150)
                        elseif tick() - lastChangeTick >= 180 and not warned then
                            warned               = true
                            statsLbl.TextColor3  = Color3.fromRGB(255,100,100)
                            statusLbl.Text       = "⚠️  No changes in 3 min — farm may have stopped!"
                            statusLbl.TextColor3 = Color3.fromRGB(255,100,100)
                            WindUI:Notify({Title="Farm Warning", Content="No stat changes in 3 minutes — farm may have stopped!", Duration=8})
                            lastChangeTick = tick() -- reset to avoid spam
                        end
                    end
                end)
                task.wait(2)
            end
        end)

        WindUI:Notify({Title="Farm Screen", Content="ON — models hidden, floating, stats live.", Duration=4})

    else
        -- Turn OFF
        _fsStatsLoop = false
        _fsFloatLoop = false
        if _fsFloatConn then _fsFloatConn:Disconnect(); _fsFloatConn = nil end
        fsUnfloat()
        if _fsGui then try(function() _fsGui:Destroy() end); _fsGui = nil end
        for _, data in pairs(_fsHidden) do try(function() data.model.Parent = data.parent end) end
        _fsHidden = {}
        WindUI:Notify({Title="Farm Screen", Content="OFF — everything restored.", Duration=3})
    end
end})

-- ── Auto Restart Day ──────────────────────────────────────────────────────────
TabOther:Section({ Title="Auto Restart Day" })
local _arActive = false
local _arFired  = false

local function doReanimate(label)
    if _arFired then return end; _arFired = true
    WindUI:Notify({Title="Auto Restart Day", Content=label.." — reanimating!", Duration=3})
    try(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/robloxcheatck/reanimatescript/main/script.lua",true))() end)
    task.wait(25); try(function() Stop() end); task.wait(0.5)
    local hum = getHumanoid(); if hum then hum.Health = 0 end
    lp.CharacterAdded:Wait(); task.wait(2); _arFired = false
end

TabOther:Toggle({ Title="Auto Restart Day", Desc="Reanimates when the round ends — fires once per round", Value=false, Callback=function(state)
    _arActive = state; _arFired = false
    if state then
        WindUI:Notify({Title="Auto Restart Day", Content="Active — watching for round end...", Duration=3})
        task.spawn(function()
            local season      = RS:WaitForChild("Season", 10); if not season then return end
            local roundActive = season:WaitForChild("RoundActive", 10); if not roundActive then return end
            local conn = roundActive.Changed:Connect(function(val)
                if not val and _arActive then doReanimate("Round ended") end
            end)
            while _arActive do task.wait(1) end
            conn:Disconnect()
        end)
    else WindUI:Notify({Title="Auto Restart Day", Content="Stopped.", Duration=3}) end
end})

-- ── Webhooks ──────────────────────────────────────────────────────────────────
TabOther:Section({ Title="Webhooks" })
TabOther:Input({ Title="Webhook URL", Desc="Paste your Discord webhook URL here", Placeholder="https://discord.com/api/webhooks/...", Callback=function(t)
    _whUrl = t:match("^%s*(.-)%s*$") -- trim whitespace
end})

TabOther:Button({ Title="Test Webhook", Desc="Sends a test message to verify your webhook URL works", Callback=function()
    if _whUrl == "" then WindUI:Notify({Title="Webhook", Content="Paste your webhook URL first!", Duration=4}); return end
    sendUserWH("✅ Ella Hub webhook test — working!")
    WindUI:Notify({Title="Webhook", Content="Test sent! Check your Discord channel.", Duration=4})
end})

local _whVC, _whEC, _whExileChat, _whJury, _whStatue, _whRound

TabOther:Toggle({ Title="Send Jury Votes to Webhook", Value=false, Callback=function(v)
    if _whJury then _whJury:Disconnect(); _whJury = nil end
    if v then try(function()
        _whJury = RS.Season.Players.JuryVotes.ChildAdded:Connect(function(vote)
            local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
            local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
            if ok1 and ok2 then sendUserWH("⚖️ **"..voter.."** jury-voted for **"..target.."**") end
        end)
    end) end
end})
TabOther:Toggle({ Title="Send Votes to Webhook", Value=false, Callback=function(v)
    if _whVC then _whVC:Disconnect(); _whVC = nil end
    if v then _whVC = RS.Season.Voting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then sendUserWH("🗳️ **"..voter.."** voted for **"..target.."**") end
    end) end
end})
TabOther:Toggle({ Title="Send Exile Votes to Webhook", Value=false, Callback=function(v)
    if _whEC then _whEC:Disconnect(); _whEC = nil end
    if v then _whEC = RS.Season.Twists.ExileVoting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then sendUserWH("⚠️ **"..voter.."** voted to exile **"..target.."**") end
    end) end
end})
TabOther:Toggle({ Title="Expose Exile Votes in Chat", Value=false, Callback=function(v)
    if _whExileChat then _whExileChat:Disconnect(); _whExileChat = nil end
    if v then _whExileChat = RS.Season.Twists.ExileVoting.Votes.ChildAdded:Connect(function(vote)
        local ok1, voter  = try(function() return RS.Season.Players[vote.Value].Value end)
        local ok2, target = try(function() return RS.Season.Players[vote.Name].Value end)
        if ok1 and ok2 then try(function() game.TextChatService.TextChannels.RBXGeneral:SendAsync(voter.." voted to exile "..target) end) end
    end) end
end})
TabOther:Toggle({ Title="Send Statue Holder to Webhook", Value=false, Callback=function(v)
    if _whStatue then _whStatue:Disconnect(); _whStatue = nil end
    if v then try(function()
        _whStatue = RS.Season.Twists.Idol.Changed:Connect(function(val)
            if val == "" then sendUserWH("🗿 Safety Statue: nobody has it now.")
            else local ok, name = try(function() return RS.Season.Players[val].Value end); sendUserWH("🗿 Safety Statue: **"..(ok and name or val).."** now has it!") end
        end)
    end) end
end})
TabOther:Toggle({ Title="Send Round Info to Webhook", Value=false, Callback=function(v)
    if _whRound then _whRound:Disconnect(); _whRound = nil end
    if v then try(function()
        _whRound = RS.Season.Twists.CurrentTwist.Changed:Connect(function(val)
            local msg = TWIST_MSGS[val] or ("Round twist: " .. tostring(val))
            sendUserWH("🎮 **Round twist detected:** " .. msg)
        end)
    end) end
end})

TabOther:Section({ Title="Hacker Detector" })
local _hackActive = false
local _lastNotif  = {}
TabOther:Toggle({ Title="Hacker Detector", Desc="Flags abnormal speed or jump", Value=false, Callback=function(state)
    _hackActive = state
    if state then task.spawn(function()
        while _hackActive do
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local now = tick()
                        if hum.WalkSpeed > 40 then
                            local k = plr.Name.."_spd"
                            if not _lastNotif[k] or now - _lastNotif[k] > 10 then
                                WindUI:Notify({Title="Hacker!", Content=plr.Name.." speeding ("..hum.WalkSpeed..")", Duration=4})
                                _lastNotif[k] = now
                            end
                        end
                        if hum.JumpPower > 100 then
                            local k = plr.Name.."_jmp"
                            if not _lastNotif[k] or now - _lastNotif[k] > 10 then
                                WindUI:Notify({Title="Hacker!", Content=plr.Name.." high jump ("..hum.JumpPower..")", Duration=4})
                                _lastNotif[k] = now
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end) end
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- SHOP
-- ══════════════════════════════════════════════════════════════════════════════

local function getShopItems()
    local result = {}
    try(function()
        local shop       = RS.Products.Shop.DailyShop
        local categories = {"Skins","Marshmallows","ElimColors","Eliminations"}
        for _, cat in ipairs(categories) do
            local folder = shop:FindFirstChild(cat); if not folder then continue end
            for _, item in pairs(folder:GetChildren()) do
                if not item.Name:find("price") and not item.Name:find("Gender") then
                    local price = item:FindFirstChild("price")
                    table.insert(result, {category=cat, name=item.Name, price=price and price.Value or "?"})
                end
            end
        end
    end)
    return result
end

TabShop:Section({ Title="Daily Shop" })
TabShop:Button({ Title="Print Shop to Console", Desc="Prints all daily shop items to F9 console", Callback=function()
    local items = getShopItems()
    print("=== Ella Hub — Daily Shop ===")
    for _, item in ipairs(items) do print("[" .. item.category .. "] " .. item.name .. " — " .. tostring(item.price) .. " coins") end
    print("=============================")
    WindUI:Notify({Title="Shop", Content="Printed to console! Press F9 to view.", Duration=3})
end})
TabShop:Button({ Title="Send Shop to Webhook", Desc="Posts all daily shop items to your Discord webhook", Callback=function()
    if _whUrl == "" then WindUI:Notify({Title="Webhook", Content="No URL set! Go to Other > Webhooks first.", Duration=4}); return end
    local items = getShopItems()
    if #items == 0 then WindUI:Notify({Title="Shop", Content="No items found in shop.", Duration=3}); return end
    local msg = "🛒 **Ella Hub — Daily Shop**\n"
    for _, item in ipairs(items) do msg ..= "**[" .. item.category .. "]** " .. item.name .. " — " .. tostring(item.price) .. " coins\n" end
    sendUserWH(msg)
    WindUI:Notify({Title="Shop", Content="Shop sent to webhook!", Duration=3})
end})

TabShop:Section({ Title="Shop Watcher" })
local _shopWatchConn = nil
local _shopWHConn    = nil
TabShop:Toggle({ Title="Notify When Shop Updates", Desc="Notifies you when a new item appears in the shop", Value=false, Callback=function(v)
    if _shopWatchConn then _shopWatchConn:Disconnect(); _shopWatchConn = nil end
    if v then try(function()
        _shopWatchConn = RS.Products.Shop.DailyShop.DescendantAdded:Connect(function(obj)
            if not obj.Name:find("price") and not obj.Name:find("Gender") then
                local price = obj:FindFirstChild("price")
                WindUI:Notify({Title="Shop Updated!", Content=obj.Name..(price and " — "..price.Value.." coins" or ""), Duration=6})
            end
        end)
        WindUI:Notify({Title="Shop Watcher", Content="Watching for shop updates...", Duration=3})
    end) end
end})
TabShop:Toggle({ Title="Auto Send Shop Updates to Webhook", Desc="Posts to webhook when new items appear in shop", Value=false, Callback=function(v)
    if _shopWHConn then _shopWHConn:Disconnect(); _shopWHConn = nil end
    if v then
        if _whUrl == "" then WindUI:Notify({Title="Webhook", Content="No URL set!", Duration=4}); return end
        try(function()
            _shopWHConn = RS.Products.Shop.DailyShop.DescendantAdded:Connect(function(obj)
                if not obj.Name:find("price") and not obj.Name:find("Gender") then
                    local price = obj:FindFirstChild("price")
                    sendUserWH("🛒 **Shop Updated!** " .. obj.Name .. (price and " — " .. price.Value .. " coins" or ""))
                end
            end)
        end)
        WindUI:Notify({Title="Shop Watcher", Content="Auto webhook active!", Duration=3})
    end
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- CLIENT TAB
-- ══════════════════════════════════════════════════════════════════════════════

TabClient:Section({ Title="Cosmetics" })
local _rainbowActive = false
local _rainbowConn   = nil
TabClient:Toggle({ Title="Rainbow Name", Desc="Makes your character name cycle through rainbow colors", Value=false, Callback=function(v)
    _rainbowActive = v
    if _rainbowConn then _rainbowConn:Disconnect(); _rainbowConn = nil end
    if v then
        _rainbowConn = RunService.RenderStepped:Connect(function()
            local char = lp.Character; if not char then return end
            local hue  = tick() * 0.5 % 1
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    obj.TextColor3 = Color3.fromHSV(hue, 1, 1)
                end
            end
        end)
    end
end})

TabClient:Section({ Title="Skin Changer" })
TabClient:Button({ Title="Skin Changer", Desc="Opens the skin changer GUI", Callback=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bruhology/ella-hub/main/Skinchanger.lua"))()
end})

TabClient:Section({ Title="Size Changer" })
TabClient:Button({ Title="Size Changer", Desc="Changes your size", Callback=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bruhology/ella-hub/main/Size.lua"))()
end})

TabClient:Section({ Title="Admin Panel" })
TabClient:Button({ Title="Gets Admin Panel", Desc="Forces open the settings/admin GUI", Callback=function()
    local ok, gui = try(function()
        return RS:WaitForChild("Products",5):WaitForChild("GUIs",5):WaitForChild("Settings",5):Clone()
    end)
    if not ok or not gui then WindUI:Notify({Title="Admin Panel", Content="Could not find the Settings GUI.", Duration=5}); return end
    gui.Parent  = lp:WaitForChild("PlayerGui")
    gui.Enabled = true
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("ImageLabel") then v.Visible = true end
        if v:IsA("TextButton") or v:IsA("ImageButton") then v.Visible = true; v.Active = true end
    end
    WindUI:Notify({Title="Admin Panel", Content="Forced open! (May not work)", Duration=5})
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- CREDITS
-- ══════════════════════════════════════════════════════════════════════════════

TabCredits:Section({ Title="Credits" })
TabCredits:Button({ Title="Skin Changer — Kobi",      Desc="Skin changer GUI made by Kobi",          Callback=function() WindUI:Notify({Title="Credits", Content="Skin Changer made by Kobi!",         Duration=4}) end})
TabCredits:Button({ Title="Autoplay — Callie & Kobi", Desc="TAS autoplay system made by Callie & Kobi", Callback=function() WindUI:Notify({Title="Credits", Content="Autoplay made by Callie and Kobi!", Duration=4}) end})

-- ══════════════════════════════════════════════════════════════════════════════
-- AUTOPLAY  (TAS system — unchanged logic, cleaned up variable names)
-- ══════════════════════════════════════════════════════════════════════════════

local TAS_HttpService        = HttpService  -- reuse cached service
local TAS_Workspace          = workspace
local TAS_LocalPlayer        = lp
local TAS_ViewingTAS         = false
local TAS_PlaybackConn       = nil
local TAS_FinishTouchConn    = nil
local TAS_AppliedShiftLock   = false
local TAS_DisableShiftCam    = false
local TAS_PathfindToStart    = true
local TAS_ActivePathfindId   = 0
local TAS_LastMapName        = nil
local TAS_LastMapDetectTime  = 0
local TAS_SelCaveChaos       = "Cave Chaos"
local TAS_SelUnstableSavannah = "Unstable Savannah"

local TAS_Routes = {
    ["Bootcamp Team 1"]     = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Bootcamp%20Team%201.json"},
    ["Bootcamp Team 2"]     = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Bootcamp%20Team%202.json"},
    ["Bootcamp Team 3"]     = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Bootcamp%20Team%203.json"},
    ["Cave Chaos Clip"]     = {type="url",source="https://raw.githubusercontent.com/callienew/tas-skid-skid-skid/refs/heads/main/Cave%20Chaos%20Clip.json"},
    ["Cave Chaos"]          = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Cave%20Chaos%20Clip.json"},
    ["Colosseum Climb"]     = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Colosseum.json"},
    ["Construct Course"]    = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Construct%20Course.json"},
    ["Hill Hike"]           = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Hill%20HIke.json"},
    ["Lava Dash"]           = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Lava%20Dash.json"},
    ["Obstacle Course"]     = {type="url",source="https://raw.githubusercontent.com/callienew/tas-skid-skid-skid/refs/heads/main/Obstacle%20Course.json"},
    ["Pond Pier"]           = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Pond%20Pier.json"},
    ["Rickety Rails"]       = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Rickety%20Rails.json"},
    ["Rock Wall Team 1"]    = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Rock%20Wall%20Team%201.json"},
    ["Rock Wall Team 2"]    = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Rock%20Wall%20Team%202.json"},
    ["Rock Wall Team 3"]    = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Rock%20Wall%20Team%203.json"},
    ["Spinner"]             = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Spinner.json"},
    ["Sweeper"]             = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Sweeper.json"},
    ["Tightrope"]           = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Tightrope%20Obby.json"},
    ["Unstable Savannah Clip"] = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Unstable%20Savannah%20Clip.json"},
    ["Unstable Savannah"]   = {type="url",source="https://raw.githubusercontent.com/krohbe/skidknickys/main/Unstable%20Savannah.json"},
}

local function TAS_Fetch(url)
    local ok, content = try(function() return game:HttpGet(url, true) end); if not ok then return nil end
    local pOk, data   = try(function() return TAS_HttpService:JSONDecode(content) end)
    return (pOk and type(data) == "table") and data or nil
end
local function TAS_LoadSource(s)
    if type(s) == "table" and s.type == "url" then return TAS_Fetch(s.source) end
end
local function TAS_ApplyShiftLock(enabled)
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter == enabled then return end
    TAS_AppliedShiftLock = enabled; keypress(0xA0); task.wait(); keyrelease(0xA0)
end
local function TAS_Stop()
    if TAS_PlaybackConn    then TAS_PlaybackConn:Disconnect();    TAS_PlaybackConn    = nil end
    if TAS_FinishTouchConn then TAS_FinishTouchConn:Disconnect(); TAS_FinishTouchConn = nil end
    TAS_ViewingTAS = false
    local root = getRoot(); if root then root.Anchored = false end
    if not TAS_DisableShiftCam then task.spawn(TAS_ApplyShiftLock, false) end
end
local function TAS_FramePos(frame) return Vector3.new(frame.CCFrame[1], frame.CCFrame[2], frame.CCFrame[3]) end
local function TAS_PathTime(path, fromPos)
    if path.Status ~= Enum.PathStatus.Success then return math.huge end
    local wps = path:GetWaypoints(); if #wps == 0 then return math.huge end
    local len, last = 0, fromPos
    for _, wp in ipairs(wps) do len += (wp.Position - last).Magnitude; last = wp.Position end
    return len / 16
end
local function TAS_BestSyncFrame(data, curPos)
    if #data == 0 then return 1 end
    local max = math.min(120, #data); local bestI = 1; local bestSaved = -math.huge; local closestI = 1; local closestD = math.huge
    for i = 1, max do
        local f = data[i]; local pos = TAS_FramePos(f); local dist = (pos - curPos).Magnitude
        local estSaved = f.time - dist / 16
        if dist < closestD then closestD = dist; closestI = i end
        if estSaved > bestSaved and f.time >= dist / 16 then bestSaved = estSaved; bestI = i end
    end
    if bestSaved == -math.huge then return closestI end
    local lo, hi = math.max(1, bestI-10), math.min(max, bestI+10)
    for i = lo, hi do
        local pos  = TAS_FramePos(data[i])
        local path = PathfindingService:CreatePath({AgentRadius=0.5,AgentHeight=2,AgentCanJump=true})
        local ok   = try(function() path:ComputeAsync(curPos, pos) end)
        local pt   = (ok and path.Status == Enum.PathStatus.Success) and TAS_PathTime(path, curPos) or (pos-curPos).Magnitude/16
        local s    = data[i].time - pt
        if s > bestSaved and data[i].time >= pt then bestSaved = s; bestI = i end
    end
    return bestI
end
local function TAS_Play(data, startIdx)
    startIdx = startIdx or 1; if TAS_ViewingTAS or #data == 0 then return end
    TAS_ViewingTAS = true
    local syncFrame = data[startIdx]; local t0 = tick() - syncFrame.time; local fi = startIdx
    local char = TAS_LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then TAS_ViewingTAS = false; return end
    local root = char.HumanoidRootPart; root.Anchored = false
    local assets     = TAS_Workspace:FindFirstChild("Assets")
    local finishPart = assets and assets:FindFirstChild("Finish", true)
    if finishPart then
        TAS_FinishTouchConn = finishPart.Touched:Connect(function(hit)
            if hit and hit.Parent == char then TAS_Stop() end
        end)
    end
    TAS_PlaybackConn = RunService.Heartbeat:Connect(function()
        if not root or not root.Parent then TAS_Stop(); return end
        if not TAS_ViewingTAS then return end
        local elapsed = tick() - t0; local target = nil
        while fi <= #data and data[fi].time <= elapsed do target = data[fi]; fi += 1 end
        if target then
            local cf  = target.CCFrame; local cam = target.CCameraCFrame
            root.CFrame = CFrame.new(cf[1],cf[2],cf[3],cf[4],cf[5],cf[6],cf[7],cf[8],cf[9],cf[10],cf[11],cf[12])
            root.Velocity = Vector3.new(target.VVelocity[1], target.VVelocity[2], target.VVelocity[3])
            if not TAS_DisableShiftCam then
                TAS_Workspace.CurrentCamera.CFrame = CFrame.new(cam[1],cam[2],cam[3],cam[4],cam[5],cam[6],cam[7],cam[8],cam[9],cam[10],cam[11],cam[12])
            end
            if not TAS_DisableShiftCam and target.ShiftLock ~= nil then task.spawn(TAS_ApplyShiftLock, target.ShiftLock) end
        end
        if fi > #data then TAS_Stop() end
    end)
end
local function TAS_Norm(name)
    if type(name) == "table" then name = name[1] or "" end
    return tostring(name):gsub("[^%w]",""):lower()
end
local function TAS_TeamSpawnPos(folder)
    if not folder then return nil end
    local s = folder:FindFirstChildOfClass("SpawnLocation"); if s then return s.Position end
    for _, c in ipairs(folder:GetDescendants()) do if c:IsA("BasePart") then return c.Position end end
end
local function TAS_ScoreMap(normMap, normFile)
    if normFile == normMap then return 100 end
    if normFile:find(normMap,1,true) or normMap:find(normFile,1,true) then return 50 end
    local score = 0
    for i = 3, math.min(#normMap, 8) do
        local chunk = normMap:sub(1,i); if normFile:find(chunk,1,true) then score = math.max(score,i) end
    end
    return score
end
local function TAS_GetFile()
    local assets = TAS_Workspace:FindFirstChild("Assets"); if not assets then return nil end
    local allRoutes = {}; for name, info in pairs(TAS_Routes) do table.insert(allRoutes,{name=name,info=info}) end
    local bestFolder, bestScore, bestCand = nil, 0, nil
    for _, child in ipairs(assets:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            local normMap = TAS_Norm(child.Name); local folderBest = 0; local folderCand = nil
            for _, route in ipairs(allRoutes) do
                local normFile = TAS_Norm(route.name); local sc = TAS_ScoreMap(normMap, normFile)
                if sc > folderBest then folderBest = sc; folderCand = {path=route.info,name=route.name,norm=normFile,team=normFile:match("team(%d)")} end
            end
            if folderBest > bestScore then bestScore = folderBest; bestFolder = child; bestCand = folderCand end
        end
    end
    if not bestFolder or bestScore < 5 then return nil end
    local mapName = bestFolder.Name
    if TAS_LastMapName ~= mapName then TAS_LastMapName = mapName; TAS_LastMapDetectTime = tick(); return nil end
    if tick() - TAS_LastMapDetectTime < 1 then return nil end
    local preferredTeam, teamFolders = nil, {}
    for _, child in ipairs(bestFolder:GetChildren()) do
        local n = child.Name:match("^Team(%d+)$"); if n then table.insert(teamFolders,{folder=child,num=tonumber(n)}) end
    end
    if #teamFolders > 1 then
        local hrp = getRoot()
        if hrp then
            local closestTeam, closestDist = nil, math.huge
            for _, info in ipairs(teamFolders) do
                local pos = TAS_TeamSpawnPos(info.folder)
                if pos then local d = (pos-hrp.Position).Magnitude; if d < closestDist then closestDist=d; closestTeam=info.num end end
            end
            preferredTeam = closestTeam
        end
    end
    local mapPrefix = bestCand.norm:gsub("team%d+",""); local candidates = {}
    for _, route in ipairs(allRoutes) do
        local nf = TAS_Norm(route.name); local cp = nf:gsub("team%d+","")
        if cp == mapPrefix or nf:sub(1,#mapPrefix) == mapPrefix then
            table.insert(candidates,{path=route.info,name=route.name,norm=nf,team=nf:match("team(%d)")})
        end
    end
    if preferredTeam then for _, c in ipairs(candidates) do if c.team and tonumber(c.team)==preferredTeam then return c.path end end end
    for _, c in ipairs(candidates) do if c.norm:find("team1") then return c.path end end
    local mln = mapName:lower()
    if mln:find("cave") and mln:find("chaos") then for _, r in ipairs(allRoutes) do if r.name:lower()==TAS_SelCaveChaos:lower() then return r.info end end end
    if mln:find("unstable") and mln:find("savannah") then for _, r in ipairs(allRoutes) do if r.name:lower()==TAS_SelUnstableSavannah:lower() then return r.info end end end
    return bestCand.path
end
local function TAS_InChallenge()
    local cp = TAS_Workspace:FindFirstChild("ChallengePlayers"); if not cp then return false end
    return cp:FindFirstChild(TAS_LocalPlayer.Name) ~= nil
end
local function TAS_PathfindAndPlay(data)
    if #data == 0 then return end
    local char = TAS_LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then TAS_Play(data,1); return end
    local curPos   = char.HumanoidRootPart.Position
    local syncIdx  = TAS_PathfindToStart and TAS_BestSyncFrame(data, curPos) or 1
    local syncPos  = TAS_FramePos(data[syncIdx])
    if (syncPos - curPos).Magnitude < 5 then TAS_Play(data, syncIdx); return end
    local path = PathfindingService:CreatePath({AgentRadius=1.5,AgentHeight=4,AgentCanJump=true})
    local ok   = try(function() path:ComputeAsync(curPos, syncPos) end)
    if not ok or path.Status ~= Enum.PathStatus.Success then char.HumanoidRootPart.CFrame = CFrame.new(syncPos); TAS_Play(data,syncIdx); return end
    TAS_ActivePathfindId += 1; local thisId = TAS_ActivePathfindId
    local root = char.HumanoidRootPart; local hum = char.Humanoid; if not hum then root.CFrame = CFrame.new(syncPos); TAS_Play(data,syncIdx); return end
    root.Anchored = false; try(function() hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.Running) end)
    task.spawn(function()
        for _, wp in ipairs(path:GetWaypoints()) do
            if TAS_ActivePathfindId ~= thisId then return end
            if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true; root.Velocity = Vector3.new(root.Velocity.X,math.max(root.Velocity.Y,40),root.Velocity.Z); task.wait(0.15) end
            hum:MoveTo(wp.Position)
            local reached, conn = false, nil
            conn = hum.MoveToFinished:Connect(function(ok) reached = ok end)
            local t0 = tick()
            while not reached and tick()-t0 < 6 do
                if TAS_ActivePathfindId ~= thisId then conn:Disconnect(); return end
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                task.wait(0.05)
            end
            conn:Disconnect()
            if not reached then root.CFrame = CFrame.new(syncPos); break end
        end
        if TAS_ActivePathfindId ~= thisId then return end
        if (syncPos - root.Position).Magnitude > 10 then root.CFrame = CFrame.new(syncPos) end
        TAS_Play(data, syncIdx)
    end)
end
local function TAS_AutoPlay()
    if not TAS_InChallenge() then return end
    local file = TAS_GetFile()
    if not file then
        for _ = 1, 10 do task.wait(0.2); if not TAS_InChallenge() then return end; file = TAS_GetFile(); if file then break end end
    end
    if not file then return end
    local data = TAS_LoadSource(file); if not data then return end
    TAS_ActivePathfindId += 1; TAS_Stop()
    local hum = TAS_LocalPlayer.Character and TAS_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed == 0 then
        while true do
            if not TAS_InChallenge() then return end
            hum = TAS_LocalPlayer.Character and TAS_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed >= 16 then break end
            task.wait(0.05)
        end
    end
    TAS_PathfindAndPlay(data)
end

-- ── Autoplay UI ───────────────────────────────────────────────────────────────
TabAutoplay:Section({ Title="TAS Autoplay" })
local _tasEnabled = false
TabAutoplay:Toggle({ Title="Autoplay", Desc="Automatically plays the TAS when a challenge starts", Value=false, Callback=function(v)
    _tasEnabled = v
    if v then task.spawn(function()
        while _tasEnabled do
            if TAS_InChallenge() then
                local hum = TAS_LocalPlayer.Character and TAS_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed == 0 then TAS_AutoPlay() end
            end
            task.wait(0.5)
        end
    end) end
end})
TabAutoplay:Toggle({ Title="Disable Shiftlock / Camera", Desc="Keeps your camera free during TAS playback", Value=false, Callback=function(v) TAS_DisableShiftCam = v end})
TabAutoplay:Button({ Title="Play This Round",  Desc="Manually triggers autoplay for the current map", Callback=function() TAS_AutoPlay() end})
TabAutoplay:Button({ Title="Stop Playback",    Desc="Stops the current TAS playback",                  Callback=function()
    TAS_Stop(); WindUI:Notify({Title="Autoplay", Content="Playback stopped.", Duration=3})
end})

TabAutoplay:Section({ Title="Map Options" })
TabAutoplay:Dropdown({ Title="Cave Chaos Route",       Values={"Cave Chaos","Cave Chaos Clip"},          Value=1, Callback=function(opt) TAS_SelCaveChaos = opt end})
TabAutoplay:Dropdown({ Title="Unstable Savannah Route",Values={"Unstable Savannah","Unstable Savannah Clip"}, Value=1, Callback=function(opt) TAS_SelUnstableSavannah = opt end})

-- ══════════════════════════════════════════════════════════════════════════════
-- RECORDER  (adapted from Kobi's TRD Recorder)
-- Records movement relative to a capture origin so replays work anywhere.
-- Features: Record, Pause/Resume, Stop, Delete, Replay (interpolated), Save.
-- ══════════════════════════════════════════════════════════════════════════════

TabRecorder:Section({ Title="Controls" })

-- State
local REC_frames      = {}     -- captured frames
local REC_isRec       = false  -- currently recording
local REC_isPaused    = false  -- recording paused
local REC_conn        = nil    -- RenderStepped connection
local REC_playConn    = nil    -- replay RenderStepped connection
local REC_startTick   = 0
local REC_pauseOffset = 0
local REC_pauseStart  = 0
local REC_origin      = CFrame.identity  -- world origin at record start
local REC_fileName    = ""     -- save file name from input

-- Status display (WindUI button used as a read-only label via Desc)
local REC_statusBtn = TabRecorder:Button({ Title="Status: Idle", Desc="Current recorder state", Callback=function() end})

local function recSetStatus(text)
    -- Update the button title to show status (WindUI reflects Title changes)
    try(function() REC_statusBtn.Title = text end)
    -- Fallback: notify for important state changes
end

-- ── RECORD ────────────────────────────────────────────────────────────────────
TabRecorder:Button({ Title="⏺  Record", Desc="Start recording your movement", Callback=function()
    if REC_isRec then
        WindUI:Notify({Title="Recorder", Content="Already recording!", Duration=2}); return
    end
    local root = getRoot(); local hum = getHumanoid()
    if not root or not hum then
        WindUI:Notify({Title="Recorder", Content="No character found.", Duration=3}); return
    end
    REC_frames      = {}
    REC_isRec       = true
    REC_isPaused    = false
    REC_pauseOffset = 0
    REC_startTick   = tick()
    REC_origin      = root.CFrame  -- capture world origin; frames stored relative to this
    local cam       = workspace.CurrentCamera

    if REC_conn then REC_conn:Disconnect() end
    REC_conn = RunService.RenderStepped:Connect(function()
        if REC_isPaused then return end
        local r = getRoot(); local h = getHumanoid(); if not r or not h then return end
        -- Store root CFrame and camera CFrame relative to the capture origin
        table.insert(REC_frames, {
            cf    = REC_origin:Inverse() * r.CFrame,
            vel   = REC_origin:Inverse():VectorToWorldSpace(r.Velocity),
            state = h:GetState(),
            camCf = REC_origin:Inverse() * cam.CFrame,
            t     = (tick() - REC_startTick) - REC_pauseOffset,
        })
    end)
    WindUI:Notify({Title="Recorder", Content="Recording started!", Duration=3})
end})

-- ── PAUSE / RESUME ────────────────────────────────────────────────────────────
TabRecorder:Button({ Title="⏸  Pause / Resume", Desc="Pause or resume the current recording", Callback=function()
    if not REC_isRec then
        WindUI:Notify({Title="Recorder", Content="Not recording.", Duration=2}); return
    end
    REC_isPaused = not REC_isPaused
    if REC_isPaused then
        REC_pauseStart = tick()
        WindUI:Notify({Title="Recorder", Content="Paused — " .. #REC_frames .. " frames so far.", Duration=3})
    else
        REC_pauseOffset += tick() - REC_pauseStart
        WindUI:Notify({Title="Recorder", Content="Resumed recording.", Duration=2})
    end
end})

-- ── STOP ──────────────────────────────────────────────────────────────────────
TabRecorder:Button({ Title="⏹  Stop", Desc="Stop recording and keep the captured data", Callback=function()
    if not REC_isRec then
        WindUI:Notify({Title="Recorder", Content="Nothing to stop.", Duration=2}); return
    end
    REC_isRec   = false
    REC_isPaused = false
    if REC_conn then REC_conn:Disconnect(); REC_conn = nil end
    WindUI:Notify({Title="Recorder", Content="Stopped. " .. #REC_frames .. " frames captured.", Duration=4})
end})

-- ── DELETE ────────────────────────────────────────────────────────────────────
TabRecorder:Button({ Title="🗑  Delete", Desc="Clear all recorded data", Callback=function()
    if REC_isRec then
        REC_isRec = false
        if REC_conn then REC_conn:Disconnect(); REC_conn = nil end
    end
    if REC_playConn then REC_playConn:Disconnect(); REC_playConn = nil end
    REC_frames      = {}
    REC_isPaused    = false
    REC_pauseOffset = 0
    WindUI:Notify({Title="Recorder", Content="Recording cleared.", Duration=3})
end})

-- ── REPLAY ────────────────────────────────────────────────────────────────────
TabRecorder:Section({ Title="Playback" })
TabRecorder:Button({ Title="▶  Replay", Desc="Replay the recording from your current position", Callback=function()
    if #REC_frames < 2 then
        WindUI:Notify({Title="Recorder", Content="Not enough data to replay.", Duration=3}); return
    end
    if REC_isRec then
        WindUI:Notify({Title="Recorder", Content="Stop recording first.", Duration=2}); return
    end
    if REC_playConn then REC_playConn:Disconnect(); REC_playConn = nil end

    local root = getRoot(); local hum = getHumanoid()
    if not root or not hum then
        WindUI:Notify({Title="Recorder", Content="No character found.", Duration=3}); return
    end

    -- Replay origin = wherever the player stands right now
    -- This means the path plays back relative to current position
    local replayOrigin = root.CFrame
    local cam          = workspace.CurrentCamera
    local prevCamType  = cam.CameraType
    cam.CameraType     = Enum.CameraType.Scriptable

    local replayStart = tick()
    local duration    = REC_frames[#REC_frames].t

    WindUI:Notify({Title="Recorder", Content="Replaying " .. #REC_frames .. " frames...", Duration=3})

    REC_playConn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - replayStart

        if elapsed >= duration then
            REC_playConn:Disconnect(); REC_playConn = nil
            local r = getRoot(); if r then r.Velocity = Vector3.zero end
            cam.CameraType = prevCamType
            WindUI:Notify({Title="Recorder", Content="Replay finished.", Duration=3})
            return
        end

        -- Binary search for the correct frame pair (O(log n) instead of linear)
        local lo, hi, idx = 1, #REC_frames, 1
        while lo <= hi do
            local mid = math.floor((lo + hi) / 2)
            if REC_frames[mid].t <= elapsed then idx = mid; lo = mid + 1
            else hi = mid - 1 end
        end

        local fA = REC_frames[idx]
        local fB = REC_frames[idx + 1] or fA
        local alpha = 0
        if fB ~= fA then alpha = (elapsed - fA.t) / math.max(fB.t - fA.t, 0.0001) end

        -- Interpolate relative CFrames then transform into world space
        local relRoot = fA.cf:Lerp(fB.cf, alpha)
        local relCam  = fA.camCf:Lerp(fB.camCf, alpha)

        local r = getRoot(); if not r then return end
        r.CFrame   = replayOrigin * relRoot
        cam.CFrame = replayOrigin * relCam
        r.Velocity = replayOrigin:VectorToWorldSpace(fA.vel)

        local h = getHumanoid()
        if h and h:GetState() ~= fA.state then try(function() h:ChangeState(fA.state) end) end
    end)
end})

TabRecorder:Button({ Title="⏹  Stop Replay", Desc="Stops the current replay playback", Callback=function()
    if REC_playConn then
        REC_playConn:Disconnect(); REC_playConn = nil
        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        local r = getRoot(); if r then r.Velocity = Vector3.zero end
        WindUI:Notify({Title="Recorder", Content="Replay stopped.", Duration=3})
    else
        WindUI:Notify({Title="Recorder", Content="No replay running.", Duration=2})
    end
end})

-- ── SAVE ──────────────────────────────────────────────────────────────────────
TabRecorder:Section({ Title="Save" })
TabRecorder:Input({ Title="File Name", Desc="Name for the saved .lua file (no extension needed)", Placeholder="e.g. MyRoute", Callback=function(t)
    REC_fileName = t:match("^%s*(.-)%s*$")
end})

TabRecorder:Button({ Title="💾  Save to File", Desc="Saves the recording as a runnable .lua file", Callback=function()
    if #REC_frames == 0 then
        WindUI:Notify({Title="Recorder", Content="Nothing to save.", Duration=3}); return
    end
    if not writefile then
        WindUI:Notify({Title="Recorder", Content="writefile not available on this executor.", Duration=4}); return
    end

    local rawName = REC_fileName ~= "" and REC_fileName:gsub("%s+","_") or ("EllaRec_" .. os.time())
    local fileName = rawName .. ".lua"

    -- Build a self-contained replay script
    -- At runtime the saved file captures replay origin from the player's current position
    local lines = {
        "-- Ella Hub — Saved Recording (" .. #REC_frames .. " frames)",
        "-- Run this script to replay the movement from your current position",
        "local p=game.Players.LocalPlayer",
        "local r=p.Character.HumanoidRootPart",
        "local h=p.Character.Humanoid",
        "local c=workspace.CurrentCamera",
        "local ori=r.CFrame",  -- capture replay origin at runtime
        "local ct=c.CameraType",
        "c.CameraType=Enum.CameraType.Scriptable",
        "local d={",
    }

    for _, v in ipairs(REC_frames) do
        table.insert(lines, string.format(
            "{CFrame.new(%s),Vector3.new(%s),Enum.HumanoidStateType.%s,CFrame.new(%s),%.6f},",
            tostring(v.cf), tostring(v.vel), v.state.Name, tostring(v.camCf), v.t
        ))
    end

    table.insert(lines, "}")
    table.insert(lines, "local s=tick()")
    table.insert(lines, "local run=game:GetService('RunService')")
    table.insert(lines, "local conn")
    table.insert(lines, "conn=run.RenderStepped:Connect(function()")
    table.insert(lines, "  local e=tick()-s")
    table.insert(lines, "  if e>=d[#d][5] then conn:Disconnect();r.Velocity=Vector3.zero;c.CameraType=ct;return end")
    table.insert(lines, "  local lo,hi,idx=1,#d,1")
    table.insert(lines, "  while lo<=hi do local m=math.floor((lo+hi)/2) if d[m][5]<=e then idx=m;lo=m+1 else hi=m-1 end end")
    table.insert(lines, "  local a=d[idx];local b=d[idx+1] or a")
    table.insert(lines, "  local al=b~=a and (e-a[5])/math.max(b[5]-a[5],0.0001) or 0")
    table.insert(lines, "  r.CFrame=ori*(a[1]:Lerp(b[1],al))")
    table.insert(lines, "  c.CFrame=ori*(a[4]:Lerp(b[4],al))")
    table.insert(lines, "  r.Velocity=ori:VectorToWorldSpace(a[2])")
    table.insert(lines, "  if h:GetState()~=a[3] then pcall(function() h:ChangeState(a[3]) end) end")
    table.insert(lines, "end)")

    try(function()
        writefile(fileName, table.concat(lines, "\n"))
        WindUI:Notify({Title="Recorder", Content="Saved: " .. fileName, Duration=4})
    end)
end})

TabRecorder:Section({ Title="Info" })
TabRecorder:Button({ Title="Frame Count", Desc="Shows how many frames are currently captured", Callback=function()
    WindUI:Notify({
        Title   = "Recorder",
        Content = #REC_frames .. " frames captured" .. (REC_isRec and " (recording)" or " (stopped)"),
        Duration = 4,
    })
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- COMBAT TAB
-- Aimbot, ESP, Hitbox Expander, Kill Aura, Damage Amp, Sword Bot
-- ══════════════════════════════════════════════════════════════════════════════

-- ── Shared combat config ──────────────────────────────────────────────────────
local COMBAT = {
    aimbotEnabled     = false,
    highlightEnabled  = false,
    hitboxEnabled     = false,
    smoothness        = 50,
    maxDistance       = 500,
    fov               = 150,
    aimPart           = "Head",
    requireVisibility = true,
    hitboxSize        = 0.5,
}

local _cam           = workspace.CurrentCamera
local _screenCenter  = Vector2.zero
local _playerConns   = {}
local _playerHLs     = {}
local _playerHBParts = {}

-- FOV circle (Drawing API)
local _fovCircle
try(function()
    _fovCircle           = Drawing.new("Circle")
    _fovCircle.Thickness = 2
    _fovCircle.Color     = Color3.new(1,1,1)
    _fovCircle.Transparency = 0.9
    _fovCircle.Filled    = false
    _fovCircle.Radius    = COMBAT.fov
    _fovCircle.Visible   = false
end)

local function _removeHL(plr)
    if _playerHLs[plr] then _playerHLs[plr]:Destroy(); _playerHLs[plr] = nil end
end
local function _applyHL(plr)
    if not COMBAT.highlightEnabled or plr == lp then return end
    _removeHL(plr)
    local char = plr.Character; if not char then return end
    local h = Instance.new("Highlight")
    h.FillColor         = Color3.fromRGB(255,50,50)
    h.OutlineColor      = Color3.fromRGB(255,255,255)
    h.FillTransparency  = 0.6
    h.OutlineTransparency = 0
    h.DepthMode         = Enum.HighlightDepthMode.Occluded
    h.Parent            = char
    _playerHLs[plr]     = h
end
local function _removeHB(plr)
    if _playerHBParts[plr] then
        for _, p in ipairs(_playerHBParts[plr]) do try(function() p:Destroy() end) end
        _playerHBParts[plr] = nil
    end
end
local function _applyHB(plr)
    if not COMBAT.hitboxEnabled or plr == lp then return end
    _removeHB(plr)
    local char = plr.Character; if not char then return end
    _playerHBParts[plr] = {}
    for _, pname in ipairs({"Head","UpperTorso","LowerTorso","HumanoidRootPart"}) do
        local orig = char:FindFirstChild(pname)
        if orig and orig:IsA("BasePart") then
            local exp = Instance.new("Part")
            exp.Size        = orig.Size + Vector3.new(COMBAT.hitboxSize, COMBAT.hitboxSize, COMBAT.hitboxSize)
            exp.CanCollide  = false; exp.CanTouch = false; exp.CanQuery = true
            exp.Transparency = 1; exp.Anchored = false; exp.Parent = char
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = exp; weld.Part1 = orig; weld.Parent = exp
            table.insert(_playerHBParts[plr], exp)
        end
    end
end

local function _onPlayerAdded(plr)
    _playerConns[plr] = {}
    _playerConns[plr].ca = plr.CharacterAdded:Connect(function()
        task.wait(0.1); _applyHL(plr); _applyHB(plr)
    end)
    if plr.Character then _applyHL(plr); _applyHB(plr) end
end
local function _onPlayerRemoving(plr)
    _removeHL(plr); _removeHB(plr)
    if _playerConns[plr] then
        for _, c in pairs(_playerConns[plr]) do c:Disconnect() end
        _playerConns[plr] = nil
    end
end

Players.PlayerAdded:Connect(_onPlayerAdded)
Players.PlayerRemoving:Connect(_onPlayerRemoving)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= lp then _onPlayerAdded(plr) end
end

local function _getAimbotTarget()
    local closest, minDist = nil, COMBAT.fov
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {lp.Character}
    local center = _screenCenter
    for plr in pairs(_playerConns) do
        if plr == lp then continue end
        local char   = plr.Character
        local target = char and char:FindFirstChild(COMBAT.aimPart)
        local hum    = char and char:FindFirstChildOfClass("Humanoid")
        if target and hum and hum.Health > 0 then
            local dist = (char.PrimaryPart.Position - lp.Character.PrimaryPart.Position).Magnitude
            if dist <= COMBAT.maxDistance then
                local sp, onScreen = _cam:WorldToViewportPoint(target.Position)
                if onScreen then
                    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if sd < minDist then
                        local visible = true
                        if COMBAT.requireVisibility then
                            local res = workspace:Raycast(_cam.CFrame.Position, (target.Position - _cam.CFrame.Position).Unit * dist, params)
                            visible = not res or res.Instance:IsDescendantOf(char)
                        end
                        if visible then minDist = sd; closest = target end
                    end
                end
            end
        end
    end
    return closest
end

local _lastAimTime = tick()
RunService.Heartbeat:Connect(function()
    _screenCenter = Vector2.new(_cam.ViewportSize.X / 2, _cam.ViewportSize.Y / 2)
    local now = tick()
    local dt  = now - _lastAimTime; _lastAimTime = now
    try(function()
        if _fovCircle then
            _fovCircle.Visible = COMBAT.aimbotEnabled
            if COMBAT.aimbotEnabled then
                _fovCircle.Position = _screenCenter
                _fovCircle.Radius   = COMBAT.fov
            end
        end
    end)
    if COMBAT.aimbotEnabled and lp.Character and lp.Character:FindFirstChild("Head") then
        local t = _getAimbotTarget()
        if t then
            local smooth = 1 - math.exp(-COMBAT.smoothness * dt)
            _cam.CFrame  = _cam.CFrame:Lerp(CFrame.new(_cam.CFrame.Position, t.Position), smooth)
        end
    end
end)

TabCombat:Section({ Title="Aimbot" })
TabCombat:Toggle({ Title="Aimbot", Desc="Smooth camera lock onto nearest visible player", Value=false, Callback=function(v) COMBAT.aimbotEnabled = v end})
TabCombat:Toggle({ Title="Require Visibility", Desc="Only lock onto players not behind walls", Value=true, Callback=function(v) COMBAT.requireVisibility = v end})
TabCombat:Slider({ Title="Smoothness", IsTooltip=true, Step=1, Value={Min=1,Max=100,Default=50}, Icons={From="solar:ghost-bold",To="solar:bolt-bold"}, Callback=function(v) COMBAT.smoothness = v end})
TabCombat:Slider({ Title="Max Distance", IsTooltip=true, Step=10, Value={Min=50,Max=1000,Default=500}, Icons={From="solar:ghost-bold",To="solar:map-point-bold"}, Callback=function(v) COMBAT.maxDistance = v end})
TabCombat:Slider({ Title="FOV Radius", IsTooltip=true, Step=5, Value={Min=10,Max=500,Default=150}, Icons={From="solar:ghost-bold",To="solar:eye-bold"}, Callback=function(v) COMBAT.fov = v end})

TabCombat:Section({ Title="ESP" })
TabCombat:Toggle({ Title="Player Highlights", Desc="Red highlight on all enemy players", Value=false, Callback=function(v)
    COMBAT.highlightEnabled = v
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then if v then _applyHL(plr) else _removeHL(plr) end end
    end
end})
TabCombat:Toggle({ Title="Hitbox Expander", Desc="Expands player hitboxes for easier hits", Value=false, Callback=function(v)
    COMBAT.hitboxEnabled = v
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then if v then _applyHB(plr) else _removeHB(plr) end end
    end
end})
TabCombat:Slider({ Title="Hitbox Size", IsTooltip=true, Step=0.5, Value={Min=0,Max=10,Default=0.5}, Icons={From="solar:ghost-bold",To="solar:maximize-bold"}, Callback=function(v) COMBAT.hitboxSize = v end})

TabCombat:Section({ Title="Kill Aura" })
local _kaEnabled = false
local _kaRange   = 15
local _kaConn    = nil
TabCombat:Toggle({ Title="Kill Aura", Desc="Auto-hits all players within range every frame", Value=false, Callback=function(v)
    _kaEnabled = v
    if _kaConn then _kaConn:Disconnect(); _kaConn = nil end
    if v then
        _kaConn = RunService.RenderStepped:Connect(function()
            local char = lp.Character; local tool = char and char:FindFirstChildOfClass("Tool")
            if not (tool and tool:FindFirstChild("Handle")) then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and lp:DistanceFromCharacter(root.Position) <= _kaRange then
                        try(function() tool:Activate() end)
                        for _, part in ipairs(plr.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                try(firetouchinterest, tool.Handle, part, 0)
                                try(firetouchinterest, tool.Handle, part, 1)
                            end
                        end
                    end
                end
            end
        end)
    end
end})
TabCombat:Slider({ Title="Kill Aura Range", IsTooltip=true, Step=1, Value={Min=1,Max=500,Default=15}, Icons={From="solar:ghost-bold",To="solar:bomb-bold"}, Callback=function(v) _kaRange = v end})

TabCombat:Section({ Title="Damage Amplifier" })
local _daEnabled = false
local _daAmount  = 7
local _daConn    = nil
TabCombat:Toggle({ Title="Damage Amplifier", Desc="Fires extra touch hits when near enemies", Value=false, Callback=function(v)
    _daEnabled = v
    if _daConn then _daConn:Disconnect(); _daConn = nil end
    if v then
        _daConn = RunService.RenderStepped:Connect(function()
            local char = lp.Character; local tool = char and char:FindFirstChildOfClass("Tool")
            if not (tool and tool:FindFirstChild("Handle")) then return end
            local myRoot = char:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local dist = (myRoot.Position - root.Position).Magnitude
                        if dist <= math.random(5, 12) then
                            for _ = 1, _daAmount do
                                try(firetouchinterest, root, tool.Handle, 0)
                                try(firetouchinterest, root, tool.Handle, 1)
                            end
                        end
                    end
                end
            end
        end)
    end
end})
TabCombat:Slider({ Title="Damage Amp Hits", IsTooltip=true, Step=1, Value={Min=1,Max=20,Default=7}, Icons={From="solar:ghost-bold",To="solar:fire-bold"}, Callback=function(v) _daAmount = v end})

TabCombat:Section({ Title="Sword Bot" })
local _sbEnabled  = false
local _sbTarget   = nil
local _sbConn     = nil
local _sbGyro     = nil
local _sbLastMove = 0
local _sbLastAct  = 0
local _sbNum      = 50

TabCombat:Toggle({ Title="Sword Bot", Desc="Auto-aims and attacks nearest player with sword", Value=false, Callback=function(v)
    _sbEnabled = v
    if not v then
        if _sbConn  then _sbConn:Disconnect();  _sbConn  = nil end
        if _sbGyro  then try(function() _sbGyro:Destroy() end); _sbGyro = nil end
        local hum = getHumanoid(); if hum then hum.AutoRotate = true end
        return
    end
    -- Target refresh loop
    task.spawn(function()
        while _sbEnabled do
            local best, bestDist = nil, math.huge
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= lp.Character then
                    local h = obj:FindFirstChildOfClass("Humanoid")
                    local r = obj:FindFirstChild("HumanoidRootPart")
                    local myR = getRoot()
                    if h and r and h.Health > 0 and myR then
                        local d = (myR.Position - r.Position).Magnitude
                        if d < bestDist then bestDist = d; best = obj end
                    end
                end
            end
            _sbTarget = best
            _sbNum = math.random(20, 90)
            task.wait(0.5)
        end
    end)
    -- Main combat loop
    _sbGyro = Instance.new("BodyGyro")
    _sbGyro.MaxTorque = Vector3.new(4e7, 4e7, 4e7)
    _sbGyro.P = 10000; _sbGyro.D = 1
    _sbGyro.Parent = game:GetService("ReplicatedStorage")
    _sbConn = RunService.RenderStepped:Connect(function()
        if not _sbEnabled then
            if _sbGyro then try(function() _sbGyro:Destroy() end); _sbGyro = nil end
            local hum = getHumanoid(); if hum then hum.AutoRotate = true end
            _sbConn:Disconnect(); _sbConn = nil; return
        end
        local char = lp.Character; if not char then return end
        local myRoot = char:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
        local hum    = char:FindFirstChildOfClass("Humanoid");  if not hum    then return end
        local t      = _sbTarget; if not t then _sbGyro.Parent = game:GetService("ReplicatedStorage"); hum.AutoRotate = true; return end
        local tHum   = t:FindFirstChildOfClass("Humanoid")
        local tRoot  = t:FindFirstChild("HumanoidRootPart")
        if not tHum or not tRoot or tHum.Health <= 0 then _sbGyro.Parent = game:GetService("ReplicatedStorage"); hum.AutoRotate = true; return end
        _sbGyro.Parent = myRoot; hum.AutoRotate = false
        -- Equip tool if needed
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            local bp = lp:FindFirstChild("Backpack")
            if bp then for _, t2 in ipairs(bp:GetChildren()) do if t2:IsA("Tool") then hum:EquipTool(t2); break end end end
        end
        tool = char:FindFirstChildOfClass("Tool")
        -- Aim gyro
        local dir = (tRoot.Position - myRoot.Position) * Vector3.new(1,0,1)
        _sbGyro.CFrame = CFrame.new(myRoot.Position, myRoot.Position + dir)
        -- Move toward target
        local dist = (tRoot.Position - myRoot.Position).Magnitude
        local now  = tick()
        if dist > 19 then
            hum:MoveTo(tRoot.Position)
        else
            if now - _sbLastMove > math.random() * (_sbNum^2 / 10) / 380 then
                _sbLastMove = now
                local sa = 1 * (_sbNum * math.random() * 2)
                hum:MoveTo(tRoot.Position + Vector3.new(math.random(-sa,sa), 0, math.random(-sa,sa)))
                if tRoot.Position.Y - 0.5 > myRoot.Position.Y then hum.Jump = true end
            end
        end
        -- Activate
        if tool and now - _sbLastAct > math.random(1,3) / 10 then
            _sbLastAct = now
            try(function() tool:Activate() end)
            local rem = tool:FindFirstChildOfClass("RemoteEvent")
            if rem then try(function() rem:FireServer() end) end
            if tool:FindFirstChild("Handle") then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character then
                        for _, part in ipairs(plr.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                try(firetouchinterest, tool.Handle, part, 0)
                                try(firetouchinterest, tool.Handle, part, 1)
                            end
                        end
                    end
                end
            end
        end
    end)
end})

TabCombat:Section({ Title="Movement" })
TabCombat:Slider({ Title="Lag High Jump Height", IsTooltip=true, Step=1, Value={Min=10,Max=200,Default=69}, Icons={From="solar:arrow-up-bold",To="solar:rocket-bold"}, Callback=function(v)
    _G._lhj_height = v
end})
TabCombat:Button({ Title="Lag High Jump", Desc="Launches you into the air (also bound to Left Alt)", Callback=function()
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid"); if not hrp or not hum then return end
    local h = _G._lhj_height or 69
    hum:ChangeState(Enum.HumanoidStateType.Jumping); task.wait(0.01)
    local s = os.clock(); while os.clock() - s < 0.15 do end
    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, h, hrp.AssemblyLinearVelocity.Z)
end})
TabCombat:Button({ Title="Floor Bounce", Desc="Jumps then lag high jumps mid-air", Callback=function()
    local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.spawn(function()
        repeat task.wait() until hum.FloorMaterial == Enum.Material.Air
        repeat task.wait() until hum.FloorMaterial ~= Enum.Material.Air
        local hrp = getRoot(); if not hrp then return end
        local h = _G._lhj_height or 69
        local s = os.clock(); while os.clock() - s < 0.15 do end
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, h, hrp.AssemblyLinearVelocity.Z)
    end)
end})

-- Alt key binding for Lag High Jump
RunService.Heartbeat:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local hum = getHumanoid()
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
            local hrp = getRoot(); if not hrp then return end
            local h = _G._lhj_height or 69
            local s = os.clock(); while os.clock() - s < 0.15 do end
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, h, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- VISUALS TAB
-- Custom Name, Static Color, Rainbow, VIP Tag, Show Usernames,
-- Rainbow Marshmallow, Fake #1, Custom Stats (client-side)
-- ══════════════════════════════════════════════════════════════════════════════

-- Shared visual globals
local VIS_CustomName    = ""
local VIS_UseCustomName = false
local VIS_RainbowMode   = false
local VIS_RainbowSpeed  = 0.5
local VIS_StaticColor   = Color3.fromRGB(255,182,193)
local VIS_UseStatic     = false

TabVisuals:Section({ Title="Name & Color" })
TabVisuals:Input({ Title="Custom Name", Desc="Replaces your character name tag text", Placeholder="Enter name...", Callback=function(t)
    VIS_CustomName    = t
    VIS_UseCustomName = (t ~= "")
end})
TabVisuals:Slider({ Title="Rainbow Speed", IsTooltip=true, Step=0.1, Value={Min=0,Max=5,Default=0.5},
    Icons={From="solar:ghost-bold",To="solar:play-bold"},
    Callback=function(v) VIS_RainbowSpeed = v end})
TabVisuals:Toggle({ Title="Rainbow Effect", Desc="Cycles your name tag through rainbow colors", Value=false, Callback=function(v)
    VIS_RainbowMode = v; if v then VIS_UseStatic = false end
end})

-- Color picker via dropdown (WindUI doesn't have a native color picker in all versions)
TabVisuals:Button({ Title="Static Color (use input below)", Desc="Set a hex color e.g. 255,182,193", Callback=function() end})
TabVisuals:Input({ Title="R,G,B Color", Placeholder="e.g. 255,100,200", Callback=function(t)
    local r,g,b = t:match("(%d+),(%d+),(%d+)")
    if r then VIS_StaticColor = Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)); VIS_UseStatic = true end
end})

TabVisuals:Section({ Title="Name Tag Effects" })
TabVisuals:Toggle({ Title="VIP Name Tag", Desc="Shows your VIP tag and makes name gold", Value=false, Callback=function(v)
    try(function()
        local char = lp.Character; if not char then return end
        local head = char:FindFirstChild("Head"); if not head then return end
        local pn   = head:FindFirstChild("playerName"); if not pn then return end
        local vip  = pn:FindFirstChild("VIP")
        if vip then
            vip.Visible = v
            for _, obj in ipairs(vip:GetDescendants()) do if obj:IsA("GuiObject") then obj.Visible = v end end
        end
        for _, obj in ipairs(pn:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if v then
                    if not _G._vipOrigColors then _G._vipOrigColors = {} end
                    if not _G._vipOrigColors[obj] then _G._vipOrigColors[obj] = obj.TextColor3 end
                    obj.TextColor3 = Color3.fromRGB(255,165,0)
                else
                    if _G._vipOrigColors and _G._vipOrigColors[obj] then
                        obj.TextColor3 = _G._vipOrigColors[obj]; _G._vipOrigColors[obj] = nil
                    end
                end
            end
        end
    end)
end})

TabVisuals:Toggle({ Title="Show All Usernames", Desc="Shows floating name tags above every player colored by team", Value=false, Callback=function(v)
    local function getTeamColor(plr)
        local ok, col = try(function()
            local pd = RS:FindFirstChild("Season") and RS.Season:FindFirstChild("Players") and RS.Season.Players:FindFirstChild(plr.Name)
            local tn = pd and pd:FindFirstChild("Team") and pd.Team.Value
            local team = tn and game:GetService("Teams"):FindFirstChild(tn)
            return team and team.TeamColor.Color or Color3.fromRGB(169,169,169)
        end)
        return ok and col or Color3.fromRGB(169,169,169)
    end
    local function applyTag(plr)
        local char = plr.Character; if not char then return end
        local head = char:FindFirstChild("Head"); if not head then return end
        local old  = head:FindFirstChild("EllaUsernameTag"); if old then old:Destroy() end
        local bb   = Instance.new("BillboardGui"); bb.Name = "EllaUsernameTag"
        bb.Adornee = head; bb.Size = UDim2.fromOffset(120,20)
        bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true; bb.Parent = head
        local lbl  = Instance.new("TextLabel", bb); lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1; lbl.Text = plr.Name; lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamMedium; lbl.TextColor3 = getTeamColor(plr)
        lbl.TextStrokeTransparency = 0.5
    end
    if v then
        _G._usernameTagConns = {}
        for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
        table.insert(_G._usernameTagConns, Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function() task.wait(0.1); applyTag(plr) end)
        end))
    else
        if _G._usernameTagConns then for _, c in ipairs(_G._usernameTagConns) do c:Disconnect() end; _G._usernameTagConns = {} end
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character; if not char then continue end
            local head = char:FindFirstChild("Head"); if not head then continue end
            local tag  = head:FindFirstChild("EllaUsernameTag"); if tag then tag:Destroy() end
        end
    end
end})

TabVisuals:Section({ Title="Marshmallow" })
local _rainbowMarshmallow = false
local _rainbowMarshConn   = nil
TabVisuals:Toggle({ Title="Rainbow Marshmallow", Desc="Cycles the marshmallow image color through rainbow", Value=false, Callback=function(v)
    _rainbowMarshmallow = v
    if _rainbowMarshConn then _rainbowMarshConn:Disconnect(); _rainbowMarshConn = nil end
    if v then
        _rainbowMarshConn = RunService.RenderStepped:Connect(function()
            try(function()
                local char = lp.Character; if not char then return end
                local head = char:FindFirstChild("Head"); if not head then return end
                local gui  = head:FindFirstChild("MarshmallowGUI"); if not gui then return end
                local sec  = gui:FindFirstChild("Sector"); if not sec then return end
                local img  = sec:FindFirstChildOfClass("ImageLabel"); if not img then return end
                img.ImageColor3 = Color3.fromHSV(tick() * VIS_RainbowSpeed % 1, 0.6, 1)
            end)
        end)
    else
        try(function()
            local char = lp.Character; if not char then return end
            local img  = char:FindFirstChild("Head") and char.Head:FindFirstChild("MarshmallowGUI")
                        and char.Head.MarshmallowGUI:FindFirstChild("Sector")
                        and char.Head.MarshmallowGUI.Sector:FindFirstChildOfClass("ImageLabel")
            if img then img.ImageColor3 = Color3.fromRGB(255,255,255) end
        end)
    end
end})

TabVisuals:Section({ Title="Leaderboard" })
TabVisuals:Button({ Title="Fake #1 All Leaderboards", Desc="Puts your name in first place on all win boards", Callback=function()
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=48&height=48&format=png"
    local boards = {}
    try(function()
        table.insert(boards, workspace.Elements.MoviesWinLeaderboard)
        table.insert(boards, workspace.Elements.CampWinLeaderboard)
        table.insert(boards, workspace.Elements.ExpeditionWinLeaderboard)
    end)
    for _, board in pairs(boards) do
        try(function()
            local sf = board.SurfaceGui.ScrollingFrame
            for _, frame in pairs(sf:GetChildren()) do
                if frame:IsA("Frame") then
                    local pl = frame:FindFirstChild("Image") and frame.Image:FindFirstChild("Place")
                    if pl and pl.Text == "1" then
                        frame.PName.Text  = lp.Name
                        frame.Image.Image = avatarUrl
                    end
                end
            end
        end)
    end
    WindUI:Notify({Title="Visuals", Content="Faked #1 on all leaderboards!", Duration=3})
end})

TabVisuals:Section({ Title="Client Stats" })
TabVisuals:Input({ Title="Custom Coins",          Placeholder="Numbers only...", Callback=function(t) try(function() lp.DataStore.Coins.Value = tonumber(t) or lp.DataStore.Coins.Value end) end})
TabVisuals:Input({ Title="Custom Camp Wins",      Placeholder="Numbers only...", Callback=function(t) try(function() lp.DataStore.CampWins.Value = tonumber(t) or lp.DataStore.CampWins.Value end) end})
TabVisuals:Input({ Title="Custom Movie Wins",     Placeholder="Numbers only...", Callback=function(t) try(function() lp.DataStore.MoviesWins.Value = tonumber(t) or lp.DataStore.MoviesWins.Value end) end})
TabVisuals:Input({ Title="Custom Expedition Wins",Placeholder="Numbers only...", Callback=function(t) try(function() lp.DataStore.ExpeditionWins.Value = tonumber(t) or lp.DataStore.ExpeditionWins.Value end) end})

-- Main RenderStepped loop for custom name + color effects
RunService.RenderStepped:Connect(function()
    local char = lp.Character; if not char then return end
    local hue  = tick() * VIS_RainbowSpeed % 1
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            try(function()
                if VIS_UseCustomName and VIS_CustomName ~= "" then obj.Text = VIS_CustomName end
                if VIS_RainbowMode then
                    obj.TextColor3 = Color3.fromHSV(hue, 0.6, 1)
                elseif VIS_UseStatic then
                    obj.TextColor3 = VIS_StaticColor
                end
                obj.TextStrokeTransparency = 0.5
                obj.BackgroundTransparency = 1
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- CHALLENGE EXTRAS — Placement Tracker, Finish ESP, Protection toggles,
-- Infect All, Disable Fires/Lasers added to existing tabs
-- ══════════════════════════════════════════════════════════════════════════════

-- ── Finish ESP helper (shared) ────────────────────────────────────────────────
local function makeFinishESP(labelText, color)
    local objects = {}
    local conns   = {}
    local function create(part)
        if objects[part] then return end
        local bb = Instance.new("BillboardGui"); bb.AlwaysOnTop = true
        bb.Size = UDim2.fromOffset(260,70); bb.StudsOffset = Vector3.new(0,4,0)
        bb.Adornee = part; bb.Parent = part
        local lbl = Instance.new("TextLabel", bb); lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1,0,0.5,0); lbl.TextColor3 = color or Color3.fromRGB(255,255,255)
        lbl.TextStrokeTransparency = 0; lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold; lbl.Text = labelText
        local distLbl = Instance.new("TextLabel", bb); distLbl.BackgroundTransparency = 1
        distLbl.Size = UDim2.new(1,0,0.5,0); distLbl.Position = UDim2.new(0,0,0.5,0)
        distLbl.TextColor3 = Color3.fromRGB(255,255,255); distLbl.TextStrokeTransparency = 0
        distLbl.TextScaled = true; distLbl.Font = Enum.Font.Gotham; distLbl.Text = ""
        objects[part] = {bb=bb, dist=distLbl}
    end
    local function destroy()
        for part, esp in pairs(objects) do try(function() esp.bb:Destroy() end) end
        objects = {}
        for _, c in ipairs(conns) do c:Disconnect() end
        conns = {}
    end
    local function enable(name)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower() == name:lower() then create(obj) end
        end
        table.insert(conns, workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("BasePart") and obj.Name:lower() == name:lower() then create(obj) end
        end))
        table.insert(conns, workspace.DescendantRemoving:Connect(function(obj)
            if objects[obj] then try(function() objects[obj].bb:Destroy() end); objects[obj] = nil end
        end))
        table.insert(conns, RunService.RenderStepped:Connect(function()
            local root = getRoot(); if not root then return end
            for part, esp in pairs(objects) do
                local dist = (part.Position - root.Position).Magnitude
                esp.bb.Enabled  = dist <= 500
                esp.dist.Text   = string.format("%.1f studs", dist)
            end
        end))
    end
    return enable, destroy
end

-- ── Camp extras ───────────────────────────────────────────────────────────────
TabCamp:Section({ Title="Finish ESP" })
local _campFinishESPEnable, _campFinishESPDestroy = makeFinishESP("🏁 FINISH", Color3.fromRGB(100,255,100))
TabCamp:Toggle({ Title="Cliff Diving / Finish ESP", Desc="Shows finish parts with distance label", Value=false, Callback=function(v)
    if v then _campFinishESPEnable("Finish") else _campFinishESPDestroy() end
end})

TabCamp:Section({ Title="Challenge Extras" })
TabCamp:Button({ Title="Disable Spinner/Sweeper Touch", Desc="Removes TouchTransmitter from UnionOperation parts", Callback=function()
    local function clean(obj)
        for _, v in ipairs(obj:GetChildren()) do if v:IsA("TouchTransmitter") then v:Destroy() end end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("UnionOperation") then clean(obj) end end
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("UnionOperation") then task.wait(); clean(obj) end
    end)
    WindUI:Notify({Title="Camp", Content="Spinner/Sweeper touch disabled!", Duration=3})
end})

-- Placement Tracker (Camp & Expedition)
local function makePlacementTracker(tabRef, flagName)
    local enabled    = false
    local placements = {}
    local finished   = {}
    local myTeam     = nil
    local conns      = {}
    local function ordinal(n)
        if n==1 then return "1st" elseif n==2 then return "2nd" elseif n==3 then return "3rd" else return n.."th" end
    end
    local function getGameName(plr)
        local ok, name = try(function()
            local pd = RS:FindFirstChild("Season") and RS.Season:FindFirstChild("Players") and RS.Season.Players:FindFirstChild(plr.Name)
            return (pd and pd.Value ~= "") and pd.Value or plr.Name
        end)
        return ok and name or plr.Name
    end
    local function onFinish(plr)
        if finished[plr.Name] then return end
        finished[plr.Name] = true
        local rank = #placements + 1
        local gn   = getGameName(plr)
        table.insert(placements, {robloxName=plr.Name, gameName=gn})
        print(string.format("[Placement] %s finished %s!", gn, ordinal(rank)))
        if plr.Name == lp.Name then
            try(function() game.TextChatService.TextChannels.RBXGeneral:SendAsync(ordinal(rank)) end)
            WindUI:Notify({Title="Placement", Content="You finished "..ordinal(rank).."!", Duration=5})
        end
    end
    local function watchPad(pad)
        table.insert(conns, pad.Touched:Connect(function(hit)
            if not myTeam then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Team and plr.Team == myTeam then
                    local char = plr.Character
                    if char and hit:IsDescendantOf(char) then onFinish(plr) end
                end
            end
        end))
    end
    local function start()
        myTeam = lp.Team
        table.insert(conns, lp:GetPropertyChangedSignal("Team"):Connect(function()
            if not enabled then return end
            local nt = lp.Team
            if myTeam and nt and nt ~= myTeam then
                enabled = false
                WindUI:Notify({Title="Placement Tracker", Content="Teams merged — tracker stopped.", Duration=4})
            elseif nt and not myTeam then myTeam = nt end
        end))
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Finish" and v:IsA("BasePart") then watchPad(v) end
        end
        table.insert(conns, workspace.DescendantAdded:Connect(function(v)
            if enabled and v.Name == "Finish" and v:IsA("BasePart") then watchPad(v) end
        end))
    end
    local function stop()
        for _, c in ipairs(conns) do c:Disconnect() end
        conns = {}; placements = {}; finished = {}; myTeam = nil
    end
    tabRef:Section({ Title="Placement Tracker" })
    tabRef:Toggle({ Title="Auto Say Placement", Desc="Says your finish placement in chat and logs all to console", Value=false, Callback=function(v)
        enabled = v
        if v then placements={}; finished={}; start()
            WindUI:Notify({Title="Placement Tracker", Content="Tracking placements!", Duration=3})
        else stop() end
    end})
end
makePlacementTracker(TabCamp,  "PlacementTrackerCamp")
makePlacementTracker(TabExped, "PlacementTrackerExp")

-- ── Movie extras ──────────────────────────────────────────────────────────────
TabMovie:Section({ Title="Finish ESP" })
local _movFinishESPEnable, _movFinishESPDestroy = makeFinishESP("🏁 FINISH", Color3.fromRGB(100,255,100))
TabMovie:Toggle({ Title="Stunt Movie / Finish ESP", Desc="Shows finish parts with distance label", Value=false, Callback=function(v)
    if v then _movFinishESPEnable("Finish") else _movFinishESPDestroy() end
end})

TabMovie:Section({ Title="Challenge Extras" })
local _infectAllActive = false
TabMovie:Toggle({ Title="Infect All", Desc="Teleports to each player to infect them", Value=false, Callback=function(v)
    _infectAllActive = v
    if v then task.spawn(function()
        while _infectAllActive do
            local root = getRoot(); if not root then task.wait(0.5); continue end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and _infectAllActive then
                    local tRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then root.CFrame = tRoot.CFrame; task.wait(0.3) end
                end
            end
            task.wait(0.1)
        end
    end) end
end})

local _disableFiresConn = nil
TabMovie:Toggle({ Title="Disable Fires", Desc="Continuously removes TouchTransmitters from all parts", Value=false, Callback=function(v)
    if _disableFiresConn then _disableFiresConn:Disconnect(); _disableFiresConn = nil end
    if v then
        local function removeTT()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") then try(function() obj:Destroy() end) end
            end
        end
        removeTT()
        _disableFiresConn = RunService.Stepped:Connect(removeTT)
    end
end})

TabMovie:Button({ Title="Disable Lasers", Desc="Removes TouchTransmitters from all laser parts", Callback=function()
    local function clean(part)
        for _, v in ipairs(part:GetChildren()) do if v:IsA("TouchTransmitter") then v:Destroy() end end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("laser") then clean(obj) end
    end
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name:lower():find("laser") then task.wait(); clean(obj) end
    end)
    WindUI:Notify({Title="Movie", Content="Lasers disabled!", Duration=3})
end})

TabMovie:Toggle({ Title="Alien Egg ESP", Desc="Highlights your alien egg with distance", Value=false, Callback=function(v)
    if not v then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "AlienEggESP_BB" then try(function() obj:Destroy() end) end
        end
        return
    end
    try(function()
        local charVal = RS.Season.Players:FindFirstChild(lp.Name)
        local cv = charVal and charVal.Value; if not cv then return end
        local alien = workspace.Assets:FindFirstChild("Alien"); if not alien then return end
        for _, v2 in pairs(alien:GetDescendants()) do
            if v2.ClassName == "TextLabel" and v2.Text == cv then
                local root = v2.Parent and v2.Parent.Parent and v2.Parent.Parent.Parent
                if root and root:IsA("BasePart") then
                    local bb = Instance.new("BillboardGui"); bb.Name = "AlienEggESP_BB"
                    bb.AlwaysOnTop = true; bb.Size = UDim2.fromOffset(160,40)
                    bb.StudsOffset = Vector3.new(0,3,0); bb.Adornee = root; bb.Parent = root
                    local lbl = Instance.new("TextLabel", bb); lbl.BackgroundTransparency = 1
                    lbl.Size = UDim2.new(1,0,1,0); lbl.TextColor3 = Color3.fromRGB(100,255,100)
                    lbl.TextStrokeTransparency = 0; lbl.TextScaled = true
                    lbl.Font = Enum.Font.GothamBold; lbl.Text = "🥚 YOUR EGG"
                end
            end
        end
    end)
end})

-- ── Expedition extras ─────────────────────────────────────────────────────────
TabExped:Section({ Title="Finish ESP" })
local _expFinishESPEnable, _expFinishESPDestroy = makeFinishESP("🏁 FINISH", Color3.fromRGB(0,255,0))
TabExped:Toggle({ Title="German Alps / Finish ESP", Desc="Shows finish parts with distance label", Value=false, Callback=function(v)
    if v then _expFinishESPEnable("Finish") else _expFinishESPDestroy() end
end})

TabExped:Section({ Title="Challenge Extras" })
TabExped:Button({ Title="Disable Spinner/Sweeper Touch", Desc="Removes TouchTransmitters from UnionOperation parts", Callback=function()
    local function clean(obj)
        for _, v in ipairs(obj:GetChildren()) do if v:IsA("TouchTransmitter") then v:Destroy() end end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("UnionOperation") then clean(obj) end end
    WindUI:Notify({Title="Expedition", Content="Touch disabled on spinners/sweepers!", Duration=3})
end})

local _hawaiiDig = false
TabExped:Toggle({ Title="Hawaii Dig All", Desc="Auto fires all dig click detectors for your team", Value=false, Callback=function(v)
    _hawaiiDig = v
    if v then task.spawn(function()
        while _hawaiiDig do
            try(function()
                local assets = workspace:FindFirstChild("Assets")
                if assets and assets:FindFirstChild("Hawaii") then
                    for _, v2 in ipairs(assets.Hawaii.DiggingSpots:GetDescendants()) do
                        if v2.Name == "ClickDetector" then
                            for _ = 1, 40 do try(fireclickdetector, v2) end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end) end
end})

-- Protection toggles for Expedition
local function makeProtectionToggle(tabRef, title, desc, assetNames)
    local active = false
    local fired  = false
    tabRef:Toggle({ Title=title, Desc=desc, Value=false, Callback=function(v)
        active = v; fired = false
        if v then task.spawn(function()
            while active do
                try(function()
                    local assets = workspace:FindFirstChild("Assets"); if not assets then return end
                    local found = false
                    for _, child in ipairs(assets:GetChildren()) do
                        for _, n in ipairs(assetNames) do
                            if child.Name:lower():find(n:lower()) then found = true; break end
                        end
                        if found then break end
                    end
                    if found and not fired then
                        fired = true
                        local hum = getHumanoid(); if hum then hum.Health = 0 end
                    end
                    if not found then fired = false end
                end)
                task.wait(0.3)
            end
        end) end
    end})
end
makeProtectionToggle(TabExped, "Meatball Protection",  "Auto-dies when meatball challenge starts",   {"meatball","dodgeball","paintball"})
makeProtectionToggle(TabCamp,  "Dodgeball Protection", "Auto-dies when dodgeball challenge starts",  {"DodgeballGiver"})
makeProtectionToggle(TabCamp,  "Paintball Protection", "Auto-dies when paintball challenge starts",  {"PaintballArena","Paintball"})
makeProtectionToggle(TabMovie, "Raygun Protection",    "Auto-dies when raygun/western challenge starts", {"raygun","western"})

-- ── Player tab extras ─────────────────────────────────────────────────────────
TabPlyr:Section({ Title="FOV" })
TabPlyr:Slider({ Title="Field of View", IsTooltip=true, Step=1, Value={Min=30,Max=120,Default=70},
    Icons={From="solar:ghost-bold",To="solar:eye-bold"},
    Callback=function(v) try(function() workspace.CurrentCamera.FieldOfView = v end) end})

-- ── Client Tab extras ─────────────────────────────────────────────────────────
TabClient:Section({ Title="Client Gears" })
TabClient:Button({ Title="Equip Sword",        Desc="Equips a client-side sword from ReplicatedStorage", Callback=function()
    try(function()
        local gear = RS.Products.Gear:FindFirstChild("Sword"); if not gear then return end
        local clone = gear:Clone(); clone.Parent = lp.Backpack
        local hum = getHumanoid(); if hum then hum:EquipTool(clone) end
    end)
end})
TabClient:Button({ Title="Equip Dodgeball",    Desc="Equips a client-side dodgeball",    Callback=function()
    try(function()
        local gear = RS.Products.Gear:FindFirstChild("Dodgeball"); if not gear then return end
        local clone = gear:Clone(); clone.Parent = lp.Backpack
        local hum = getHumanoid(); if hum then hum:EquipTool(clone) end
    end)
end})
TabClient:Button({ Title="Equip PaintballGun", Desc="Equips a client-side paintball gun", Callback=function()
    try(function()
        local gear = RS.Products.Gear:FindFirstChild("PaintballGun"); if not gear then return end
        local clone = gear:Clone(); clone.Parent = lp.Backpack
        local hum = getHumanoid(); if hum then hum:EquipTool(clone) end
    end)
end})

-- ── Main Tab extras ───────────────────────────────────────────────────────────
TabMain:Section({ Title="Extras" })
TabMain:Button({ Title="Destroy Long Names", Desc="Destroys all UI text elements longer than 750 chars", Callback=function()
    local function scan(parent)
        for _, el in ipairs(parent:GetDescendants()) do
            if el:IsA("TextLabel") or el:IsA("TextButton") or el:IsA("TextBox") then
                if #el.Text > 750 then try(function() el:Destroy() end) end
            end
        end
    end
    for _, svc in ipairs(game:GetChildren()) do try(function() scan(svc) end) end
    game.DescendantAdded:Connect(function(d)
        if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and #d.Text > 750 then
            try(function() d:Destroy() end)
        end
    end)
    WindUI:Notify({Title="Main", Content="Long names destroyed + watching for new ones.", Duration=3})
end})

TabMain:Button({ Title="Get Statue When It Spawns", Desc="Continuously moves statue/bag hit to you as it spawns", Callback=function()
    local function tryGrab(v)
        if v:IsA("BasePart") and v.Name == "hit" then
            local parent = v.Parent
            if parent and (parent.Name == "Bag" or parent.Name == "SafetyStatue") then
                task.wait(0.1)
                v.CanCollide = false; v.Transparency = 1
                task.spawn(function()
                    while v and v.Parent do
                        local root = getRoot()
                        if root then try(function() v.CFrame = root.CFrame end) end
                        task.wait(0.05)
                    end
                end)
            end
        end
    end
    workspace.DescendantAdded:Connect(tryGrab)
    for _, v in pairs(workspace:GetDescendants()) do tryGrab(v) end
    WindUI:Notify({Title="Statue", Content="Now grabbing statue/bag on spawn!", Duration=3})
end})

-- ══════════════════════════════════════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════════════════════════════════════
Window:Init()
