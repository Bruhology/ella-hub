-- Ella Hub — Maintenance Notice

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

local sg = Instance.new("ScreenGui")
sg.Name = "EllaHubMaintenance"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end

local normalSize = UDim2.fromOffset(320, 210)
local normalPos  = UDim2.new(0.5, -160, 0.5, -105)

local frame = Instance.new("Frame", sg)
frame.Size = normalSize
frame.Position = normalPos
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

-- White outline
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.6

-- ── Traffic Light Buttons ─────────────────────────────────────────────────────
local function makeLight(color, xPos)
    local btn = Instance.new("Frame", frame)
    btn.Size = UDim2.fromOffset(12, 12)
    btn.Position = UDim2.fromOffset(xPos, 12)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local redBtn    = makeLight(Color3.fromRGB(255, 95, 87),  12)
local yellowBtn = makeLight(Color3.fromRGB(255, 189, 46), 30)
local greenBtn  = makeLight(Color3.fromRGB(39, 201, 63),  48)

-- Red — close
local closeHit = Instance.new("TextButton", redBtn)
closeHit.Size = UDim2.fromScale(1, 1)
closeHit.BackgroundTransparency = 1
closeHit.Text = ""
closeHit.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Yellow — minimise/restore
local minimised = false
local yellowHit = Instance.new("TextButton", yellowBtn)
yellowHit.Size = UDim2.fromScale(1, 1)
yellowHit.BackgroundTransparency = 1
yellowHit.Text = ""
yellowHit.MouseButton1Click:Connect(function()
    minimised = not minimised
    TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        Size = minimised and UDim2.fromOffset(320, 36) or normalSize,
    }):Play()
end)

-- Green — fullscreen/restore
local fullscreen = false
local vp = workspace.CurrentCamera.ViewportSize
local greenHit = Instance.new("TextButton", greenBtn)
greenHit.Size = UDim2.fromScale(1, 1)
greenHit.BackgroundTransparency = 1
greenHit.Text = ""
greenHit.MouseButton1Click:Connect(function()
    fullscreen = not fullscreen
    if fullscreen then
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(vp.X, vp.Y),
            Position = UDim2.fromOffset(0, 0),
        }):Play()
    else
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = normalSize,
            Position = normalPos,
        }):Play()
    end
end)

-- ── Content ───────────────────────────────────────────────────────────────────

local icon = Instance.new("TextLabel", frame)
icon.Size = UDim2.new(1, 0, 0, 44)
icon.Position = UDim2.fromOffset(0, 28)
icon.BackgroundTransparency = 1
icon.Text = "🔧"
icon.TextSize = 32
icon.Font = Enum.Font.GothamBold
icon.TextXAlignment = Enum.TextXAlignment.Center

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 26)
title.Position = UDim2.fromOffset(10, 74)
title.BackgroundTransparency = 1
title.Text = "Ella Hub is Currently Down"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center

local msg = Instance.new("TextLabel", frame)
msg.Size = UDim2.new(1, -30, 0, 40)
msg.Position = UDim2.fromOffset(15, 104)
msg.BackgroundTransparency = 1
msg.Text = "Ella Hub is down, this is usually because it’s currently updating! check the Discord server for status updates!"
msg.TextColor3 = Color3.fromRGB(255, 255, 255)
msg.TextTransparency = 0.3
msg.TextSize = 12
msg.Font = Enum.Font.Gotham
msg.TextXAlignment = Enum.TextXAlignment.Center
msg.TextWrapped = true

local divider = Instance.new("Frame", frame)
divider.Size = UDim2.new(1, -30, 0, 1)
divider.Position = UDim2.fromOffset(15, 152)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.85
divider.BorderSizePixel = 0

local discordBtn = Instance.new("TextButton", frame)
discordBtn.Size = UDim2.new(1, -30, 0, 36)
discordBtn.Position = UDim2.fromOffset(15, 162)
discordBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.BackgroundTransparency = 0.9
discordBtn.BorderSizePixel = 0
discordBtn.Text = "📋  Copy Discord Link"
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.TextSize = 12
discordBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", discordBtn).Color = Color3.fromRGB(255, 255, 255)
discordBtn:FindFirstChildOfClass("UIStroke").Transparency = 0.7
discordBtn:FindFirstChildOfClass("UIStroke").Thickness = 1

discordBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/JEHHxynrME") end)
    discordBtn.Text = "✅  Copied!"
    discordBtn.TextColor3 = Color3.fromRGB(0, 220, 100)
    task.wait(2)
    discordBtn.Text = "📋  Copy Discord Link"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
