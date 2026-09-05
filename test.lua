--[[
	Ella's Decompiler
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- Config
-- ═══════════════════════════════════════════════════════════════════════════

local SCAN_DELAY        = 0.05   -- pause between each script to avoid hitching
local DECOMPILE_TIMEOUT = 1      -- seconds to wait for a single decompile() call
local MAX_ROUNDS        = 5      -- safety re-scan passes for late-streamed scripts
local CLIPBOARD_LIMIT   = 500 * 1024 -- ~500KB cap - large payloads can crash the client
local BRAND             = "Ella's Decompiler"

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

local getgenv = getgenv or function() return _G end
local env = getgenv()

-- ═══════════════════════════════════════════════════════════════════════════
-- Small helpers
-- ═══════════════════════════════════════════════════════════════════════════

local function sanitize(name)
	return string.gsub(tostring(name), '[<>:"/\\|?*%c]', "_"):sub(1, 50)
end

local function isCoreScript(scr)
	local ok, isDescendant = pcall(function()
		return scr:IsDescendantOf(game:GetService("CoreGui"))
			or scr:IsDescendantOf(game:GetService("CorePackages"))
	end)
	return ok and isDescendant
end

local function makeGui()
	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 2e9
	local ok = pcall(function()
		local getHiddenUi = env.gethui or function() return game:GetService("CoreGui") end
		gui.Parent = getHiddenUi()
	end)
	if not ok then
		pcall(function() gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end)
	end
	return gui
end

-- Isolated, crash-resistant clipboard write. Runs off the main call stack and
-- never lets a bad setclipboard implementation take anything else down with it.
local function copyToClipboardSafe(text, onDone)
	task.spawn(function()
		local fn = env.setclipboard or setclipboard or env.toclipboard
			or (env.Clipboard and env.Clipboard.set)
			or (syn and syn.write_clipboard)
		if not fn then
			onDone(false, "no clipboard function available")
			return
		end
		local ok, err = pcall(fn, text)
		onDone(ok, err)
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Identify the game + decompiler availability
-- ═══════════════════════════════════════════════════════════════════════════

local gameName = "UnknownGame"
pcall(function()
	gameName = game:GetService("MarketplaceService"):GetProductInfoAsync(game.PlaceId).Name
end)

local FOLDER_NAME = "decompile_" .. sanitize(gameName) .. "_" .. tostring(game.PlaceId)
	.. "_" .. HttpService:GenerateGUID(false):sub(1, 6)

local hasDecompiler = false
pcall(function()
	if decompile then
		local t = Instance.new("LocalScript")
		t.Parent = game:GetService("ReplicatedStorage")
		local ok, r = pcall(decompile, t)
		t:Destroy()
		hasDecompiler = ok and r ~= nil
	end
end)

if not hasDecompiler then
	local errGui = makeGui()
	errGui.Name = "EllaDecompilerError"
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0.45, 0, 0, 80)
	f.Position = UDim2.new(0.275, 0, 0, 10)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	f.BorderSizePixel = 0
	f.Parent = errGui
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local p = Instance.new("UIPadding", f)
	p.PaddingLeft = UDim.new(0, 12)
	p.PaddingRight = UDim.new(0, 12)
	p.PaddingTop = UDim.new(0, 10)
	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(1, 0, 0, 22)
	t.BackgroundTransparency = 1
	t.TextColor3 = Color3.fromRGB(255, 80, 80)
	t.TextScaled = true
	t.Font = Enum.Font.GothamBold
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Text = "No Decompiler Available"
	local m = Instance.new("TextLabel", f)
	m.Size = UDim2.new(1, 0, 0, 36)
	m.Position = UDim2.new(0, 0, 0, 28)
	m.BackgroundTransparency = 1
	m.TextColor3 = Color3.fromRGB(200, 200, 200)
	m.TextScaled = true
	m.Font = Enum.Font.Gotham
	m.TextXAlignment = Enum.TextXAlignment.Left
	m.TextWrapped = true
	m.Text = "Your executor does not have a working decompiler.\nPlease use an executor that supports decompiling."
	task.wait(8)
	pcall(function() errGui:Destroy() end)
	return
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Decompile + file writing
-- ═══════════════════════════════════════════════════════════════════════════

local function safeDecompile(scr)
	local output, finished = "-- Failed or empty output", false
	task.spawn(function()
		local ok, result = pcall(decompile, scr)
		output = (ok and result and result ~= "") and result or "-- Failed or empty output"
		finished = true
	end)
	local waited = 0
	while not finished and waited < DECOMPILE_TIMEOUT do
		task.wait(0.1)
		waited += 0.1
	end
	if not finished then
		output = "-- Timed out after " .. DECOMPILE_TIMEOUT .. "s"
	end
	return output
end

local createdDirs = {}
local function ensureDir(path)
	if createdDirs[path] then return end
	local current = ""
	for part in string.gmatch(path, "[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		if not createdDirs[current] then
			createdDirs[current] = true
			pcall(env.makefolder or makefolder, current)
		end
	end
	createdDirs[path] = true
end

local function buildScriptData(scr)
	local parts = {}
	local cur = scr.Parent
	while cur and cur ~= game do
		table.insert(parts, 1, sanitize(cur.Name))
		cur = cur.Parent
	end
	local ext = scr:IsA("LocalScript") and ".local.lua"
		or scr:IsA("ModuleScript") and ".module.lua"
		or ".server.lua"
	local dir = FOLDER_NAME .. "/" .. table.concat(parts, "/")
	local path = dir .. "/" .. sanitize(scr.Name) .. ext
	return { dir = dir, path = path }
end

local function collectAllScripts()
	local found = {}
	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("LuaSourceContainer") and not isCoreScript(obj) then
			table.insert(found, obj)
		end
	end
	return found
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════════════════════════════════════════

local screenGui = makeGui()
screenGui.Name = "EllaDecompilerGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0, 182)
frame.Position = UDim2.new(0.25, 0, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local pad = Instance.new("UIPadding", frame)
pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingRight = UDim.new(0, 10)
pad.PaddingTop = UDim.new(0, 8)

local function makeLabel(y, h, color, font, text)
	local l = Instance.new("TextLabel", frame)
	l.Size = UDim2.new(1, 0, 0, h)
	l.Position = UDim2.new(0, 0, 0, y)
	l.BackgroundTransparency = 1
	l.TextColor3 = color
	l.TextScaled = true
	l.Font = font
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	return l
end

local titleLabel    = makeLabel(0,   20, Color3.fromRGB(255, 200, 50),  Enum.Font.GothamBold, BRAND .. " - " .. gameName)
local statusLabel   = makeLabel(24,  18, Color3.fromRGB(200, 200, 200), Enum.Font.Gotham,     "Scanning...")
local scriptLabel   = makeLabel(46,  16, Color3.fromRGB(150, 150, 150), Enum.Font.Code,       "")

local barBg = Instance.new("Frame", frame)
barBg.Size = UDim2.new(1, 0, 0, 14)
barBg.Position = UDim2.new(0, 0, 0, 68)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)

local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)

local etaLabel       = makeLabel(87,  14, Color3.fromRGB(120, 120, 120), Enum.Font.Gotham,     "")
local statsLabel     = makeLabel(105, 14, Color3.fromRGB(180, 180, 180), Enum.Font.GothamBold, "Passed: 0  |  Failed: 0")
local savedLabel     = makeLabel(123, 14, Color3.fromRGB(80, 200, 255),  Enum.Font.Gotham,     "Folder: " .. FOLDER_NAME)
local clipboardLabel = makeLabel(141, 14, Color3.fromRGB(150, 150, 150), Enum.Font.Gotham,     "")

local passedCount, failedCount, totalKnownScripts = 0, 0, 0
local fileCounter = 0 -- real running counter, replaces the old buggy #processed fallback

local function updateStats()
	statsLabel.Text = string.format("Passed: %d  |  Failed: %d", passedCount, failedCount)
	local ratio = passedCount / math.max(passedCount + failedCount, 1)
	statsLabel.TextColor3 = Color3.fromRGB(math.floor(255 * (1 - ratio)), math.floor(255 * ratio), 80)
end

local lastGuiUpdate = 0
local function updateGui(scriptPath, elapsed, eta, finished)
	local now = os.clock()
	local processedTotal = passedCount + failedCount
	if not finished and (now - lastGuiUpdate < 0.3) and (processedTotal % 5 ~= 0) then
		return
	end
	lastGuiUpdate = now

	local percent = totalKnownScripts > 0 and math.floor((processedTotal / totalKnownScripts) * 100) or 0
	barFill.Size = UDim2.new(totalKnownScripts > 0 and (processedTotal / totalKnownScripts) or 0, 0, 1, 0)
	statusLabel.Text = string.format("Scripts: %d / %d  (%d%%)", processedTotal, totalKnownScripts, percent)
	scriptLabel.Text = scriptPath or ""

	if finished then
		etaLabel.Text = string.format("Took %ds | Done!", elapsed)
		titleLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
		barFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
		savedLabel.Text = "Saved: " .. FOLDER_NAME
	else
		etaLabel.Text = string.format("Elapsed: %ds | ETA: ~%ds", elapsed, eta)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Processing loop
-- ═══════════════════════════════════════════════════════════════════════════

local processed = {}

-- Small, hard-capped clipboard buffer. Kept intentionally tiny (500KB default)
-- because building/holding one giant multi-MB string for setclipboard is what
-- was likely crashing the client before.
local clipboardChunks = {}
local clipboardSize = 0
local clipboardFull = false

local function processScriptList(scriptList, startTime)
	for _, scr in ipairs(scriptList) do
		task.wait(SCAN_DELAY > 0 and SCAN_DELAY or nil)

		if not processed[scr] then
			processed[scr] = true

			local fullName = ""
			pcall(function() fullName = scr:GetFullName() end)

			local ok, err = pcall(function()
				if not scr or not scr.Parent then error("destroyed") end

				local data = buildScriptData(scr)
				local rawSource = safeDecompile(scr)
				local source = "-- " .. BRAND .. "\n-- Original: " .. fullName .. "\n\n" .. rawSource

				ensureDir(data.dir)
				local written = pcall(env.writefile or writefile, data.path, source)
				if not written then
					fileCounter += 1
					local flatPath = FOLDER_NAME .. "/" .. fileCounter .. "_" .. sanitize(scr.Name) .. ".lua"
					ensureDir(FOLDER_NAME)
					pcall(env.writefile or writefile, flatPath, source)
				end

				-- append to clipboard buffer only while under the cap, and only
				-- for source that actually decompiled (skip empty/timeout noise)
				if not clipboardFull and rawSource ~= "-- Failed or empty output"
					and not rawSource:match("^%-%- Timed out") then
					local chunk = "\n" .. string.rep("=", 50) .. "\n-- " .. fullName .. "\n"
						.. string.rep("=", 50) .. "\n" .. rawSource .. "\n"
					if clipboardSize + #chunk > CLIPBOARD_LIMIT then
						clipboardFull = true
					else
						clipboardSize += #chunk
						table.insert(clipboardChunks, chunk)
					end
				end
			end)

			if ok then
				passedCount += 1
			else
				failedCount += 1
				warn("[" .. BRAND .. "] FAILED " .. fullName .. ": " .. tostring(err))
			end
			updateStats()

			local processedTotal = passedCount + failedCount
			local elapsed = math.floor(os.clock() - startTime)
			local rate = processedTotal / math.max(os.clock() - startTime, 0.001)
			local remaining = totalKnownScripts - processedTotal
			local eta = math.floor(remaining / math.max(rate, 0.001))
			updateGui(fullName, elapsed, eta, false)
		end
	end
end

local startTime = os.clock()
local round = 1

-- Listen for late-streamed scripts instead of repeatedly re-walking the whole
-- game tree every round - cheaper than a full GetDescendants() rescan each pass.
local lateArrivals = {}
local descendantAddedConn = game.DescendantAdded:Connect(function(obj)
	if obj:IsA("LuaSourceContainer") and not processed[obj] and not isCoreScript(obj) then
		table.insert(lateArrivals, obj)
	end
end)

repeat
	local scripts = collectAllScripts()
	local newScripts = {}
	for _, scr in ipairs(scripts) do
		if not processed[scr] then table.insert(newScripts, scr) end
	end
	for _, scr in ipairs(lateArrivals) do
		if not processed[scr] then table.insert(newScripts, scr) end
	end
	lateArrivals = {}

	if #newScripts == 0 then break end

	totalKnownScripts += #newScripts
	statusLabel.Text = string.format("Pass %d: %d new scripts found", round, #newScripts)
	task.wait(0.5)
	processScriptList(newScripts, startTime)
	round += 1
until round > MAX_ROUNDS

descendantAddedConn:Disconnect()

local totalTime = math.floor(os.clock() - startTime)
updateGui("All done!", totalTime, 0, true)

-- ═══════════════════════════════════════════════════════════════════════════
-- Clipboard copy (isolated + size-capped, to avoid crashing the client)
-- ═══════════════════════════════════════════════════════════════════════════

clipboardLabel.Text = "Copying to clipboard..."
clipboardLabel.TextColor3 = Color3.fromRGB(200, 200, 100)

local header = "-- " .. BRAND .. "\n-- Game: " .. gameName .. " (" .. tostring(game.PlaceId) .. ")\n"
	.. "-- Scripts: " .. passedCount .. " passed, " .. failedCount .. " failed\n"
local clipboardText = header .. table.concat(clipboardChunks)

copyToClipboardSafe(clipboardText, function(ok, err)
	if ok then
		clipboardLabel.TextColor3 = Color3.fromRGB(80, 255, 150)
		local sizeNote = clipboardFull and (" (capped at " .. math.floor(CLIPBOARD_LIMIT / 1024) .. "KB)") or ""
		clipboardLabel.Text = "Copied " .. math.floor(#clipboardText / 1024) .. "KB to clipboard!" .. sizeNote
	else
		clipboardLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
		clipboardLabel.Text = "Clipboard copy failed: " .. tostring(err)
	end
end)

-- manual fallback, same as before, in case setclipboard is flaky on your executor
env._ELLA_DECOMPILE_DUMP = clipboardText

task.wait(15)
pcall(function() screenGui:Destroy() end)
