-- UNO hub

if _G.UNORunning then
warn("[LUX-Ora] prev instance")
end
_G.UNORunning = false
_G.__UNOMainOriginalPos = nil
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
if not LP then
local _lpConn
_lpConn = Players.PlayerAdded:Connect(function(p) LP = p end)
local _t0 = tick()
while not LP and tick() - _t0 < 15 do task.wait(0.1) end
if _lpConn then _lpConn:Disconnect() end
end
if not LP then
warn("[Y-out] no LP")
return
end
local pgui = LP:WaitForChild("PlayerGui", 20)
if not pgui then
warn("[Y-out] no PlayerGui")
return
end
pcall(function()
local oldApi = _G.AlvaroTPBat
if type(oldApi) == "table" and type(oldApi.stop) == "function" then oldApi.stop() end
end)
pcall(function() if type(stopUnwalk) == "function" then stopUnwalk() end end)
pcall(function()
if _G.YoutMarkerConn then _G.YoutMarkerConn:Disconnect() end
local oldMarker = Workspace:FindFirstChild("YoutTPBatLastPosition")
if oldMarker then oldMarker:Destroy() end
_G.YoutMarkerConn = nil
_G.YoutGetLastMarkerCFrame = nil
_G.YoutClearLastMarker = nil
_G.AlvaroTPBat = nil
_G.AlvaroTP = nil
end)
local camera = Workspace.CurrentCamera

-- Intro style: 1 = minimal black, 2 = UNO blue title + music (this source)
selectedIntroStyle = 2
pcall(function()
    local cfgName = "UNO_" .. tostring(LP.UserId) .. ".json"
    local readFn = (type(readfile) == "function" and readfile) or (syn and syn.readfile)
    local isFn = (type(isfile) == "function" and isfile) or (syn and syn.isfile)
    if type(readFn) ~= "function" then return end
    if type(isFn) == "function" then
        local okE, r = pcall(isFn, cfgName)
        if not (okE and r) then return end
    end
    local ok, raw = pcall(readFn, cfgName)
    if not ok or type(raw) ~= "string" then return end
    local okJ, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    if okJ and type(data) == "table" then
        local v = tonumber(data.introStyle) or data.introStyle
        if v == 1 or v == "1" then selectedIntroStyle = 1
        elseif v == 2 or v == "2" then selectedIntroStyle = 2 end
        if tonumber(data.floatingButtonScale) then floatingButtonScalePref = tonumber(data.floatingButtonScale) end
        if tonumber(data.uiScale) then uiScalePref = tonumber(data.uiScale) end
    end
end)

do
if selectedIntroStyle == 1 then
local _TS = game:GetService("TweenService")
local _introGui = Instance.new("ScreenGui")
_introGui.Name = "UNOOnTopIntro"
_introGui.ResetOnSpawn = false
_introGui.IgnoreGuiInset = true
_introGui.DisplayOrder = 100000
pcall(function() if syn and syn.protect_gui then syn.protect_gui(_introGui) end end)
if not pcall(function() _introGui.Parent = game:GetService("CoreGui") end) then _introGui.Parent = pgui end
local bg = Instance.new("Frame", _introGui)
bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromRGB(4,18,12); bg.BorderSizePixel = 0
local title = Instance.new("TextLabel", _introGui)
title.Size = UDim2.new(0.9,0,0,70); title.Position = UDim2.fromScale(0.5,0.48); title.AnchorPoint = Vector2.new(0.5,0.5)
title.BackgroundTransparency = 1; title.Text = "UNO 🎄"; title.TextColor3 = Color3.fromRGB(205,35,55)
title.Font = Enum.Font.GothamBlack; title.TextScaled = true; title.TextTransparency = 1; title.ZIndex = 10
local hint = Instance.new("TextLabel", _introGui)
hint.Size = UDim2.new(0.8,0,0,24); hint.Position = UDim2.fromScale(0.5,0.58); hint.AnchorPoint = Vector2.new(0.5,0.5)
hint.BackgroundTransparency = 1; hint.Text = "tap to continue"; hint.TextColor3 = Color3.fromRGB(200,210,220)
hint.Font = Enum.Font.GothamMedium; hint.TextSize = 14; hint.TextTransparency = 1; hint.ZIndex = 11
local skip = Instance.new("TextButton", _introGui); skip.Size = UDim2.fromScale(1,1); skip.BackgroundTransparency = 1; skip.Text = ""; skip.ZIndex = 20
local closed = false
local function closeIntro()
if closed then return end; closed = true
pcall(function() _TS:Create(title, TweenInfo.new(0.25), {TextTransparency=1}):Play(); _TS:Create(hint, TweenInfo.new(0.25), {TextTransparency=1}):Play(); _TS:Create(bg, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play() end)
task.delay(0.35, function() pcall(function() _introGui:Destroy() end) end)
end
skip.Activated:Connect(closeIntro)
_TS:Create(title, TweenInfo.new(0.5), {TextTransparency=0}):Play()
_TS:Create(hint, TweenInfo.new(0.6), {TextTransparency=0.2}):Play()
task.delay(5, closeIntro)
else
-- INTRO 2: UNO.VS + slideshow
local _TS = game:GetService("TweenService")
local _introGui = Instance.new("ScreenGui")
_introGui.Name = "UNOOnTopIntro"
_introGui.ResetOnSpawn = false
_introGui.IgnoreGuiInset = true
_introGui.DisplayOrder = 100000
pcall(function()
if syn and syn.protect_gui then syn.protect_gui(_introGui) end
end)
if not pcall(function() _introGui.Parent = game:GetService("CoreGui") end) then
_introGui.Parent = pgui
end

do
    local imgs = {
        "rbxassetid://91675587151546","rbxassetid://121013211871608","rbxassetid://121484797021617",
        "rbxassetid://98355642612772","rbxassetid://125911497430726","rbxassetid://103898154028764",
        "rbxassetid://139661567144007","rbxassetid://82117178279085","rbxassetid://106100522015525"
    }
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.new(0,0,0); bg.BorderSizePixel = 0; bg.ZIndex = 1; bg.Parent = _introGui
    local a = Instance.new("ImageLabel", bg)
    a.Size = UDim2.new(1,0,1,0); a.BackgroundTransparency = 1; a.ScaleType = Enum.ScaleType.Crop; a.ZIndex = 2; a.Image = imgs[1]
    local b = Instance.new("ImageLabel", bg)
    b.Size = UDim2.new(1,0,1,0); b.BackgroundTransparency = 1; b.ScaleType = Enum.ScaleType.Crop; b.ZIndex = 1; b.ImageTransparency = 1
    task.spawn(function()
        local i, showA = 1, true
        for _ = 1, 40 do
            if not (_introGui and _introGui.Parent) then break end
            i = (i % #imgs) + 1
            local front = showA and a or b
            local back = showA and b or a
            back.ZIndex = 3; front.ZIndex = 2
            back.Image = imgs[i]; back.ImageTransparency = 1
            pcall(function()
                _TS:Create(back, TweenInfo.new(0.12), {ImageTransparency = 0}):Play()
                _TS:Create(front, TweenInfo.new(0.12), {ImageTransparency = 1}):Play()
            end)
            showA = not showA
            task.wait(0.28)
        end
    end)
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 80)
title.Position = UDim2.new(0, 0, 0.5, -40)
title.BackgroundTransparency = 1
title.Text = "UNO 🎄"
title.TextColor3 = Color3.fromRGB(205, 35, 55)
title.TextTransparency = 0
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.ZIndex = 10
title.Parent = _introGui
local stroke = Instance.new("UIStroke", title)
stroke.Color = Color3.fromRGB(0, 0, 0)
stroke.Thickness = 2.5
stroke.Transparency = 0.1

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, 0, 0, 28)
hint.Position = UDim2.new(0, 0, 0.5, 50)
hint.BackgroundTransparency = 1
hint.Text = "tap to continue"
hint.TextColor3 = Color3.fromRGB(220, 220, 230)
hint.TextTransparency = 0.25
hint.Font = Enum.Font.GothamBold
hint.TextSize = 16
hint.ZIndex = 11
hint.Parent = _introGui

local introSound = Instance.new("Sound")
introSound.Name = "UNOIntroMusic"
introSound.Volume = 0.65
introSound.Looped = false
introSound.Parent = game:GetService("SoundService")
task.spawn(function()
    pcall(function()
        local getAsset = getcustomasset or getsynasset
        local file = "ZeyHubb_IntroSong_FromVideo.mp3"
        if getAsset then
            local okA, asset = pcall(getAsset, file)
            if okA and type(asset) == "string" and asset ~= "" then
                introSound.SoundId = asset
                introSound:Play()
                return
            end
        end
        introSound.SoundId = "rbxassetid://1837696875"
        introSound:Play()
    end)
end)

local closed = false
local skipBtn
local function closeIntro()
if closed then return end
closed = true
pcall(function() introSound:Stop() end)
pcall(function()
_TS:Create(title, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
_TS:Create(stroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
_TS:Create(hint, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
_TS:Create(skipBtn, TweenInfo.new(0.25), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
end)
task.delay(0.3, function()
pcall(function() if _introGui and _introGui.Parent then _introGui:Destroy() end end)
end)
end

local tapBtn = Instance.new("TextButton")
tapBtn.Name = "TapToContinue"
tapBtn.Size = UDim2.new(1, 0, 1, 0)
tapBtn.BackgroundTransparency = 1
tapBtn.Text = ""
tapBtn.ZIndex = 20
tapBtn.Parent = _introGui
tapBtn.Activated:Connect(closeIntro)

skipBtn = Instance.new("TextButton")
skipBtn.Name = "SkipIntroButton"
skipBtn.AnchorPoint = Vector2.new(1, 0)
skipBtn.Position = UDim2.new(1, -20, 0, 20)
skipBtn.Size = UDim2.fromOffset(116, 38)
skipBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
skipBtn.BackgroundTransparency = 0
skipBtn.BorderSizePixel = 0
skipBtn.Text = "SKIP INTRO"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextSize = 14
skipBtn.AutoButtonColor = true
skipBtn.ZIndex = 30
skipBtn.Parent = _introGui
Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 8)
skipBtn.Activated:Connect(closeIntro)

task.delay(6, closeIntro)
end -- intro 2
end -- intro root
_G.YoutRunning = true
_G.YoutSession = (_G.YoutSession or 0) + 1
local _mySession = _G.YoutSession
local YOUT_LANGUAGE = "en"
local function localizeYoutInterface(root) end
local function youtTranslate(source) return source end
local _tick = tick
local _clamp = math.clamp
local _floor = math.floor
local _abs = math.abs
local _huge = math.huge
local _sqrt = math.sqrt
local _V3new = Vector3.new
local _V3zero = Vector3.zero
local _CFnew = CFrame.new
local _CFlookAt = CFrame.lookAt
local _RayParams_new = RaycastParams.new
local _GetPlayersCached
do
local cache, cacheTime = nil, 0
_GetPlayersCached = function()
local now = _tick()
if cache and now - cacheTime < 0.03 then return cache end
cache = Players:GetPlayers()
cacheTime = now
return cache
end
end
local function waitForCharReady(char, timeout)
timeout = timeout or 5
local deadline = _tick() + timeout
while (not char) or (not char.Parent)
or (not char:FindFirstChild("HumanoidRootPart"))
or (not char:FindFirstChildOfClass("Humanoid")) do
if _tick() > deadline then return false end
task.wait(0.05)
end
return true
end
NS = 60
CS = 29
LAGGER_SPEED = 15
LAGGER_CARRY_SPEED = 24.5
MEDUSA_COOLDOWN = 25
BAT_AIMBOT_SPEED = 58
-- Bat V2 constants (Auto Bat uses this engine)
AUTO_BAT_V2_DIST = 1.0
AUTO_BAT_V2_HEIGHT = 1.5
AUTO_BAT_V2_V_OFF = 0.0
AUTO_BAT_V2_HIT_DIST = 4.5
AUTO_BAT_V2_SWING_CD = 0.08
autoBatV2SwingEnabled = true
autoBatV2HitCooldown = false
_batV2Conn = nil
function getAimbotChaseSpeed()
    return tonumber(BAT_AIMBOT_SPEED) or 58
end
bypassAimbotVersion = "v1"
selectedAimbotMode = "v2"
bypassAimbotVersion = "v1"  -- bat bypass v1/v2
selectedBatAimMode = "v2"
bypassAimbotVersion = tostring(bypassAimbotVersion or "v1")
instantResetVersion = "V1"  -- V1 / V2 from Zey style

antiBypassEnabled = false
ANTI_BYPASS_SPEED = 58
safeModeEnabled = false
safeModeSetVisual = nil
flingShieldEnabled = false
flingShieldSetVisual = nil
autoResetOnMedEnabled = false
autoResetOnMedSetVisual = nil
playerESPEnabled = false
playerESPSetVisual = nil
tracerESPEnabled = false
tracerESPSetVisual = nil
allLockButtonsEnabled = false
allLockButtonsSetVisual = nil
autoSaveEnabled = true
autoSaveSetVisual = nil
introStyle = selectedIntroStyle or 2
introStyleLabel = nil
buttonScaleLabel = nil


-- ============================================================
-- SWORD / BAT SKINS (client-side mesh replica)
-- ============================================================
do
local SKINS = {
	DiamondSword = {
		cat = "Bat", label = "Diamond Sword",
		mesh = "rbxassetid://8827558932", tex = "rbxassetid://8827558969",
		scale = Vector3.new(0.2, 0.2, 0.2),
		c0 = CFrame.new(-0.05, -0.1, -0.12) * CFrame.Angles(math.rad(90), math.rad(180), 300),
		view = 4.9,
	},
	Katana = {
		cat = "Bat", label = "Katana",
		mesh = "rbxassetid://13528902482", tex = "rbxassetid://13528902373",
		scale = Vector3.new(1.4, 1.4, 1.4),
		c0 = CFrame.new(0, 0.6, 0) * CFrame.Angles(math.rad(270), math.rad(180), math.rad(180)),
		view = 6.6,
	},
	GoldenDeagle = {
		cat = "Medusa", label = "Golden Desert Eagle",
		mesh = "rbxassetid://430251413", tex = "rbxassetid://435840335",
		scale = Vector3.new(0.01, 0.01, 0.01),
		c0 = CFrame.new(0, 0, -0.8) * CFrame.Angles(math.rad(330), math.rad(180), 0),
		view = 3.0,
	},
}
local function categoryOf(tool)
	local n = tool.Name:lower()
	if n:find("bat") or n:find("slap") or n:find("sword") then return "Bat" end
	if n:find("medusa") or n:find("head") then return "Medusa" end
	return nil
end
local chosen = { Bat = "DiamondSword", Medusa = "GoldenDeagle" }
local tracked = setmetatable({}, { __mode = "k" })
local function buildReplica(tool, skinKey)
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	local existing = handle:FindFirstChild("LocalReplica")
	if existing then existing:Destroy() end
	local data = SKINS[skinKey]
	if not data then return end
	handle.Transparency = 1
	handle.CanQuery = false
	handle.CanTouch = false
	local model = Instance.new("Model")
	model.Name = "LocalReplica"
	local part = Instance.new("Part")
	part.Name = "MainPart"
	part.Size = Vector3.new(1, 1, 1)
	part.Transparency = 0
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Anchored = false
	part.Parent = model
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = data.mesh
	mesh.TextureId = data.tex
	mesh.Scale = data.scale
	mesh.Parent = part
	local weld = Instance.new("Motor6D")
	weld.Part0 = handle
	weld.Part1 = part
	weld.C0 = data.c0
	weld.Parent = part
	model.Parent = handle
	tracked[tool] = model
	local guard
	guard = handle:GetPropertyChangedSignal("Transparency"):Connect(function()
		if not tool.Parent then guard:Disconnect() return end
		if handle.Transparency ~= 1 then handle.Transparency = 1 end
	end)
end
local function teardown(tool)
	local model = tracked[tool]
	if model then model:Destroy() end
	tracked[tool] = nil
	local handle = tool:FindFirstChild("Handle")
	if handle then
		handle.Transparency = 0
		handle.CanQuery = true
		handle.CanTouch = true
	end
end
local function onChildAdded(child)
	if not child:IsA("Tool") then return end
	local cat = categoryOf(child)
	if not cat then return end
	buildReplica(child, chosen[cat])
	child.AncestryChanged:Connect(function(_, parent)
		if not parent then teardown(child) end
	end)
	child.ChildAdded:Connect(function(c)
		if c.Name == "Handle" then
			task.defer(function() buildReplica(child, chosen[categoryOf(child) or "Bat"]) end)
		end
	end)
end
local function hookCharacter(char)
	for _, c in ipairs(char:GetChildren()) do onChildAdded(c) end
	char.ChildAdded:Connect(onChildAdded)
end
if LP.Character then hookCharacter(LP.Character) end
LP.CharacterAdded:Connect(hookCharacter)
function _G.setSkin(cat, skinKey)
	if not SKINS[skinKey] or SKINS[skinKey].cat ~= cat then return end
	chosen[cat] = skinKey
	local char = LP.Character
	if not char then return end
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") and categoryOf(c) == cat then
			buildReplica(c, skinKey)
		end
	end
end
_G.NoxSkins = SKINS
_G.NoxChosenSkin = chosen
end

ANTI_BYPASS_HIT_DIST = 13
ANTI_BYPASS_LEAD = 3
BYPASS_AIMBOT_SPEED = 60
CONFIG_FILE = "UNO_" .. tostring(LP.UserId) .. ".json"
BAT_V2_HIT_DIST = 4.5
_isDraggingButton = false
backgroundIndex = 1
backgroundImages = {
    "rbxassetid://128151913478635",
    "rbxassetid://118286231279314",
    "rbxassetid://108776436013357",
    "rbxassetid://112906199272015",
    "rbxassetid://128549834133763",
    "rbxassetid://99549449023827",
    "rbxassetid://97439100737148",
    "rbxassetid://124654028814298",
    "rbxassetid://116676839486825",
}
-- Source Button Images picker: DEFAULT plus seven atlas images.
buttonImageAssets = {
    "DEFAULT",
    "rbxassetid://95675906925077", -- idle black square
}
buttonImageActiveAsset = "rbxassetid://137797027684580" -- active blue square
buttonImageIndex = 2
AUTO_STEAL_BAR_IMAGE = "rbxassetid://118269189807670"
_G.__NoxButtonImageButtons = {}
-- Sprite atlas coordinates copied from the reference button layout (128x96 cells).
buttonImageAtlasCells = {
    DropBR = {0, 4}, AutoLeft = {3, 4}, AutoBat = {0, 3}, AutoRight = {3, 3},
    TpDown = {1, 2}, Carry = {2, 2}, Lagger1 = {1, 1}, Lagger2 = {2, 1},
}
backgroundImageTransparency = 0.35
backgroundMode = "Image"
backgroundSelectorLabel = nil
backgroundColorMatch = false
stealBarMatch = false
stealBarStyle = "V1"
kickWarningEnabled = false
ragdollCountdownEnabled = true
ragdollStealEnabled = true
floatingButtonScale = (type(floatingButtonScalePref)=='number' and floatingButtonScalePref) or 1
_floatingUIScales = {}
if type(uiScalePref)=='number' then uiScaleValue = uiScalePref end

_G.__NoxBackgroundButtons = {}
function refreshBackgroundButtons()
    for i, button in ipairs(_G.__NoxBackgroundButtons or {}) do
        local stroke = button and button:FindFirstChildOfClass("UIStroke")
        if stroke then
            local selected = i == tonumber(backgroundIndex)
            stroke.Color = selected and (selectedColor or Color3.fromRGB(70, 200, 255)) or Color3.fromRGB(82, 86, 96)
            stroke.Thickness = selected and 2.2 or 1
            stroke.Transparency = selected and 0 or 0.35
        end
    end
end
function refreshNoxButtonImageButtons()
    for i, button in ipairs(_G.__NoxButtonImageButtons or {}) do
        local stroke = button and button:FindFirstChildOfClass("UIStroke")
        if stroke then
            local selected = i == tonumber(buttonImageIndex)
            stroke.Color = selected and (selectedColor or Color3.fromRGB(70, 200, 255)) or Color3.fromRGB(82, 86, 96)
            stroke.Thickness = selected and 2.2 or 1
            stroke.Transparency = selected and 0 or 0.4
        end
    end
end
function applyNoxButtonImage(index)
    buttonImageIndex = math.clamp(math.floor(tonumber(index) or buttonImageIndex or 2), 1, #buttonImageAssets)
    local asset = buttonImageAssets[buttonImageIndex] or "DEFAULT"
    local function applyToFrame(frame, active)
        if not frame then return end
        local image = frame:FindFirstChild("ButtonSkinImage")
        if not image then return end
        if asset == "DEFAULT" then
            image.Image = ""
            image.Visible = false
            image.ImageRectSize = Vector2.zero
            image.ImageRectOffset = Vector2.zero
        else
            local use = asset
            if active and type(buttonImageActiveAsset) == "string" and buttonImageActiveAsset ~= "" then
                use = buttonImageActiveAsset
            end
            image.Image = use
            image.Visible = true
            image.ImageTransparency = 0
            image.ImageColor3 = Color3.new(1, 1, 1)
            image.ScaleType = Enum.ScaleType.Stretch
            image.ImageRectSize = Vector2.zero
            image.ImageRectOffset = Vector2.zero
            image.ZIndex = 10
        end
    end
    if MobilePanel then
        for _, button in ipairs(MobilePanel:GetChildren()) do
            if button:IsA("TextButton") then
                local isOn = button:GetAttribute("MobActive") == true
                applyToFrame(button, isOn)
            end
        end
    end
    if instaResetFloatingButton then
        local f = instaResetFloatingButton:FindFirstChild("Frame") or instaResetFloatingButton
        applyToFrame(f, f and f:GetAttribute("MobActive") == true)
    end
    if antiBypassFloatingButton then
        local f = antiBypassFloatingButton:FindFirstChild("Frame") or antiBypassFloatingButton
        applyToFrame(f, f and f:GetAttribute("MobActive") == true)
    end
    refreshNoxButtonImageButtons()
    return true
end

function selectNoxButtonImage(index)
    if not tonumber(index) or index < 1 or index > #buttonImageAssets then return false end
    applyNoxButtonImage(index)
    if saveAllSettings then pcall(saveAllSettings, true) end
    return true
end
function applyBackgroundMode(mode)
    backgroundMode = mode or backgroundMode or "Image"
    if not main then return end
    main.BackgroundColor3 = Color3.fromRGB(4, 8, 14)
    main.BackgroundTransparency = (backgroundMode == "None") and 0 or 1
    local bgImage = main:FindFirstChild("BackgroundImage")
    if not bgImage then
        bgImage = Instance.new("ImageLabel")
        bgImage.Name = "BackgroundImage"
        bgImage.Parent = main
    end
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Position = UDim2.new(0, 0, 0, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 2
    bgImage.Active = false
    local asset = (type(backgroundImages) == "table" and backgroundImages[tonumber(backgroundIndex) or 1]) or "rbxassetid://128151913478635"
    if backgroundMode == "None" then
        bgImage.Visible = false
        bgImage.Image = ""
        bgImage.ImageTransparency = 1
    else
        bgImage.Visible = true
        bgImage.Image = asset
        bgImage.ImageTransparency = math.clamp(tonumber(backgroundImageTransparency) or 0.25, 0, 1)
        bgImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
    local overlay = main:FindFirstChild("MenuReadabilityOverlay")
    if overlay then
        overlay.Visible = backgroundMode ~= "None"
        overlay.BackgroundTransparency = 0.48
    end
    if backgroundSelectorLabel then
        backgroundSelectorLabel.Text = backgroundMode == "None" and "None" or ("Background " .. tostring(backgroundIndex or 1))
    end
end

function selectNoxBackground(index)
    if type(backgroundImages) ~= "table" or #backgroundImages == 0 then return false end
    index = math.floor(tonumber(index) or 1)
    if index < 1 or index > #backgroundImages then return false end
    backgroundIndex = index
    backgroundMode = "Image"
    applyBackgroundMode(backgroundMode)
    if saveAllSettings then pcall(saveAllSettings, true) end
    return true
end
function setBackgroundColorMatch(on)
    backgroundColorMatch = on == true
    applyBackgroundMode(backgroundMode or "Image")
    if saveAllSettings then pcall(saveAllSettings, true) end
end
function applyStealBarStyle(style)
    style = style or stealBarStyle or "V1"
    stealBarStyle = (style == "V2") and "V2" or "V1"
    if not pbFrame then return end
    local accent = selectedColor or Color3.fromRGB(205, 35, 55)
    local track = pbFrame:FindFirstChild("BarBg", true) or pbFrame:FindFirstChild("StealProgressTrack", true)
    local fill = (track and (track:FindFirstChild("Fill") or track:FindFirstChild("StealProgressFill"))) or pbFrame:FindFirstChild("Fill", true)
    local trackStroke = track and track:FindFirstChildOfClass("UIStroke")
    local outerStroke = pbFrame:FindFirstChild("OuterStroke")
    local fillGradient = fill and fill:FindFirstChildOfClass("UIGradient")
    local corner = pbFrame:FindFirstChildOfClass("UICorner")
    if stealBarStyle == "V2" then
        -- V2: padded fill, rounder, accent heavy (Zey-like)
        if corner then corner.CornerRadius = UDim.new(0, 14) end
        if track then
            track.BackgroundColor3 = Color3.fromRGB(2, 8, 14)
            if trackStroke then
                trackStroke.Color = accent
                trackStroke.Thickness = 1.8
                trackStroke.Transparency = 0.18
            end
        end
        if fill then
            fill.BackgroundColor3 = accent
            if fillGradient then
                fillGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, accent:Lerp(Color3.new(1,1,1), 0.45)),
                    ColorSequenceKeypoint.new(0.50, accent),
                    ColorSequenceKeypoint.new(1.00, accent:Lerp(Color3.new(0,0,0), 0.25)),
                })
            end
            -- pad attribute for progress updates
            fill:SetAttribute("StylePad", 2)
        end
        if outerStroke then
            outerStroke.Color = accent
            outerStroke.Thickness = 1.8
            outerStroke.Transparency = 0.15
        end
        pbFrame.BackgroundColor3 = Color3.fromRGB(4, 10, 18)
    else
        -- V1: classic clean bar
        if corner then corner.CornerRadius = UDim.new(0, 10) end
        if track then
            track.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
            if trackStroke then
                trackStroke.Color = Color3.fromRGB(92, 96, 104)
                trackStroke.Thickness = 1
                trackStroke.Transparency = 0.35
            end
        end
        if fill then
            fill.BackgroundColor3 = Color3.fromRGB(205, 35, 55)
            if fillGradient then
                fillGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(120, 210, 255)),
                    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(205, 35, 55)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 110, 200)),
                })
            end
            fill:SetAttribute("StylePad", 0)
        end
        if outerStroke then
            outerStroke.Color = Color3.fromRGB(80, 80, 90)
            outerStroke.Thickness = 1
            outerStroke.Transparency = 0.3
        end
        pbFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 14)
    end
    if stealBarMatch and stealBarStyle == "V1" then
        -- optional accent match on V1
        if fill then fill.BackgroundColor3 = accent end
        if outerStroke then outerStroke.Color = accent end
    end
end
function applyStealBarMatch()
    applyStealBarStyle(stealBarStyle or "V1")
end

function setStealBarMatch(on)
    stealBarMatch = on == true
    applyStealBarMatch()
    if saveAllSettings then pcall(saveAllSettings, true) end
end
local COLOR_THEMES = {
["Normal"] = Color3.fromRGB(0, 0, 0),
["Blue"] = Color3.fromRGB(205, 35, 55),
["UNO Purple"] = Color3.fromRGB(112, 68, 150),
["Christmas"] = Color3.fromRGB(205, 35, 55),
["Yellow"] = Color3.fromRGB(255, 210, 50),
["Red"] = Color3.fromRGB(255, 70, 90),
["Green"] = Color3.fromRGB(80, 220, 120),
["Pink"] = Color3.fromRGB(255, 120, 180),
["Purple"] = Color3.fromRGB(170, 130, 215),
["Orange"] = Color3.fromRGB(255, 140, 40),
}
currentColorTheme = "Christmas"
selectedColor = Color3.fromRGB(205, 35, 55)
THEME_ORDER = {"Christmas"}
-- UNO Christmas accent (holly red)
UNO_ACCENT = Color3.fromRGB(205, 35, 55)
UNO_ACCENT_DIM = Color3.fromRGB(115, 20, 35)
UNO_BG = Color3.fromRGB(4, 18, 12)
UNO_PANEL = Color3.fromRGB(8, 27, 18)


function getThemeColor() return selectedColor or Color3.fromRGB(205, 35, 55) end


-- UNO extras (safe, all pcall-wrapped)
_G.__UNONavy = _G.__UNONavy or {}
function playUNOMenuSound()
    pcall(function()
        local parent = (gui and gui.Parent and gui) or (pgui) or game:GetService("SoundService")
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://15293826982"
        s.Volume = 0.4
        s.Parent = parent
        s:Play()
        task.delay(0.03, function()
            pcall(function()
                local s2 = Instance.new("Sound")
                s2.SoundId = "rbxassetid://9125397624"
                s2.Volume = 0.25
                s2.Parent = parent
                s2:Play()
                task.delay(1.5, function() pcall(function() s2:Destroy() end) end)
            end)
        end)
        task.delay(1.5, function() pcall(function() s:Destroy() end) end)
    end)
end

local function makeNavyBorder(target, thickness, speed)
    if not target or not target:IsA("GuiObject") then return end
    pcall(function()
        for _, c in ipairs(target:GetChildren()) do
            if c.Name == "UNONavyStroke" then c:Destroy() end
        end
        local stroke = Instance.new("UIStroke")
        stroke.Name = "UNONavyStroke"
        stroke.Thickness = thickness or 2.2
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.1
        stroke.Parent = target
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(125, 18, 32)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(235, 235, 220)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(30, 145, 78)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(235, 235, 220)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(125, 18, 32)),
        })
        grad.Parent = stroke
        table.insert(_G.__UNONavy, {g = grad, sp = speed or 3})
        if not _G.__UNONavyLoop then
            _G.__UNONavyLoop = true
            task.spawn(function()
                while true do
                    for i = #_G.__UNONavy, 1, -1 do
                        local e = _G.__UNONavy[i]
                        if e.g and e.g.Parent then
                            e.g.Rotation = (e.g.Rotation + e.sp) % 360
                        else
                            table.remove(_G.__UNONavy, i)
                        end
                    end
                    task.wait(0.03)
                end
            end)
        end
    end)
end

local _idleTok = 0
local function setupIdleFade()
    if not main then return end
    pcall(function()
        local base = main.BackgroundTransparency
        local function wake()
            _idleTok = _idleTok + 1
            local my = _idleTok
            pcall(function()
                TS:Create(main, TweenInfo.new(0.2), {BackgroundTransparency = base}):Play()
            end)
            task.delay(2.5, function()
                if my == _idleTok and main and main.Parent then
                    pcall(function()
                        TS:Create(main, TweenInfo.new(0.35), {
                            BackgroundTransparency = math.clamp(base + 0.35, 0, 0.85)
                        }):Play()
                    end)
                end
            end)
        end
        main.InputBegan:Connect(function() wake() end)
        for _, d in ipairs(main:GetDescendants()) do
            if d:IsA("GuiButton") then
                d.MouseButton1Down:Connect(function()
                    pcall(playUNOMenuSound)
                    wake()
                end)
            end
        end
        wake()
    end)
end

function youtGradient(c)
return ColorSequence.new({
ColorSequenceKeypoint.new(0.00, c:Lerp(Color3.new(1,1,1), 0.55)),
ColorSequenceKeypoint.new(0.45, c),
ColorSequenceKeypoint.new(1.00, c:Lerp(Color3.new(0,0,0), 0.35)),
})
end
function youtGradientSoft(c) return youtGradient(c) end

function youtGradientDark(c) return youtGradient(c) end

function applyYoutGradientToLabel(label, c)
if not label then return end
local grad = label:FindFirstChildOfClass("UIGradient")
if not grad then
grad = Instance.new("UIGradient", label)
end
grad.Rotation = 0
grad.Color = youtGradient(c)
end
local _lastThemeUpdate = 0
local _lastThemeColor = nil

local function applyCyberMenuLook()
if not main then return end
main.BackgroundColor3 = Color3.fromRGB(3, 7, 14)
main.BackgroundTransparency = (backgroundMode == "None") and 0.02 or 0.12
local g = main:FindFirstChild("NoxCyberGrad") or main:FindFirstChild("UNOGrad")
if not g then
g = Instance.new("UIGradient")
g.Name = "UNOGrad"
g.Parent = main
end
g.Name = "UNOGrad"
g.Rotation = 130
g.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 28, 48)),
ColorSequenceKeypoint.new(0.28, Color3.fromRGB(6, 14, 26)),
ColorSequenceKeypoint.new(0.62, Color3.fromRGB(3, 8, 16)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(1, 3, 8)),
})
-- outer glow stroke
local ms = main:FindFirstChild("UNOMenuStroke")
if not ms then
ms = Instance.new("UIStroke")
ms.Name = "UNOMenuStroke"
ms.Parent = main
end
ms.Color = Color3.fromRGB(205, 35, 55)
ms.Thickness = 1.6
ms.Transparency = 0.28
-- soft inner highlight line under header if missing
local topLine = main:FindFirstChild("UNOTopAccent")
if not topLine then
topLine = Instance.new("Frame")
topLine.Name = "UNOTopAccent"
topLine.Size = UDim2.new(1, -24, 0, 2)
topLine.Position = UDim2.new(0, 12, 0, 0)
topLine.BackgroundColor3 = Color3.fromRGB(205, 35, 55)
topLine.BackgroundTransparency = 0.25
topLine.BorderSizePixel = 0
topLine.ZIndex = 50
topLine.Parent = main
local tg = Instance.new("UIGradient", topLine)
tg.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(205, 35, 55)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 240, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(205, 35, 55)),
})
end
end

function applyColorTheme(themeName)
themeName = "Blue"
local color = Color3.fromRGB(205, 35, 55)
currentColorTheme = "Christmas"
selectedColor = color
updateAllUIThemeColors(color)
pcall(applyCyberMenuLook)
if backgroundMode then pcall(applyBackgroundMode, backgroundMode) end
if stealBarMatch then pcall(applyStealBarMatch) end
-- repaint floating buttons only
if MobilePanel then
for _, btn in ipairs(MobilePanel:GetChildren()) do
if btn:IsA("TextButton") then
paintFloatingBtn(btn, btn:GetAttribute("MobActive") == true)
end
end
end
saveAllSettings(true)
end
_uicStroke = nil
_uicAvatarStroke = nil
_uicHandle = nil
_uicLine = nil
function updateAllUIThemeColors(color)
local now = _tick()
if color == _lastThemeColor and now - _lastThemeUpdate < 0.1 then return end
_lastThemeUpdate = now
_lastThemeColor = color
if progressFill then
progressFill.BackgroundColor3 = Color3.fromRGB(205, 35, 55)
progressFill.BackgroundTransparency = 0
local grad = progressFill:FindFirstChildOfClass("UIGradient")
if grad then
grad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(168, 172, 180)),
ColorSequenceKeypoint.new(0.42, Color3.fromRGB(245, 246, 248)),
ColorSequenceKeypoint.new(0.70, Color3.fromRGB(226, 228, 232)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(184, 188, 196)),
})
grad.Rotation = 0
end
end
if pbFrame then
local progressTrack = pbFrame:FindFirstChild("BarBg", true)
if progressTrack then
progressTrack.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
local trackStroke = progressTrack:FindFirstChildOfClass("UIStroke")
if trackStroke then trackStroke.Color = Color3.fromRGB(92, 96, 104) end
end
local border = pbFrame:FindFirstChild("OuterStroke") or pbFrame:FindFirstChildOfClass("UIStroke")
if border then border.Color = Color3.fromRGB(80, 80, 90) end
local fpsNeon = pbFrame:FindFirstChild("FPSNeon", true)
if fpsNeon then fpsNeon.TextColor3 = Color3.fromRGB(255, 255, 255) end
local pingNeon = pbFrame:FindFirstChild("PingNeon", true)
if pingNeon then pingNeon.TextColor3 = Color3.fromRGB(255, 255, 255) end
end
if _uicStroke then _uicStroke.Color = color end
if _uicAvatarStroke then _uicAvatarStroke.Color = color end
if _uicHandle then _uicHandle.TextColor3 = color end
if _uicLine then _uicLine.BackgroundColor3 = color end
-- theme color applies to floating mobile buttons only (not overhead speed counter)

for _, tab in ipairs(tabButtons or {}) do
local isActive = tab:FindFirstChild("Underline") and tab.Underline.Visible
if isActive then
tab.TextColor3 = Color3.fromRGB(255, 255, 255)
tab.BackgroundColor3 = color
tab.BackgroundTransparency = 0
local tg = tab:FindFirstChild("TabBgGrad")
if tg then tg.Color = youtGradient(color) end
else
tab.TextColor3 = Color3.fromRGB(255, 255, 255)
tab.BackgroundColor3 = Color3.fromRGB(35, 22, 48)
tab.BackgroundTransparency = 1
end
local ul = tab:FindFirstChild("Underline")
if ul then ul.BackgroundColor3 = color end
local s = tab:FindFirstChild("TabStroke")
if s then s.Color = color end
end
if _G.__YoutRefreshESPTheme then pcall(_G.__YoutRefreshESPTheme, color) end
if main then
local titleFrame = main:FindFirstChild("Frame")
if titleFrame then
for _, child in ipairs(titleFrame:GetDescendants()) do
if child:IsA("UIStroke") and child.Color == Color3.fromRGB(180, 180, 190) then
child.Color = color
end
end
end
end
if colorSelectorLabel then
colorSelectorLabel.Text = currentColorTheme
colorSelectorLabel.TextColor3 = color
end
refreshBackgroundButtons()
if _G._youtStealSlide then
_G._youtStealSlide.BackgroundColor3 = color
local sg = _G._youtStealSlide:FindFirstChildOfClass("UIGradient")
if sg then sg.Color = youtGradient(color) end
local ss = _G._youtStealSlide:FindFirstChildOfClass("UIStroke")
if ss then ss.Color = color end
end
if miniBtn then
local stroke = miniBtn:FindFirstChildOfClass("UIStroke")
if stroke then stroke.Color = Color3.fromRGB(70, 160, 220) end
end
if MobilePanel then
for _, btn in ipairs(MobilePanel:GetChildren()) do
if btn:IsA("TextButton") and btn:FindFirstChild("BtnGrad") then
paintFloatingBtn(btn, btn:GetAttribute("MobActive") == true)
end
end
end
if backgroundColorMatch then pcall(applyBackgroundMode, backgroundMode or "Image") end
if stealBarMatch then pcall(applyStealBarMatch) end
end
-- ============================================================
-- CUSTOM SKINS (ported from Rival Hub / VX7 style)
-- ============================================================
local SKIN_TAG = "NoxCustomSkin_"
local _originalAppearance = nil
local outfitSelectorLabel = nil
local currentOutfitIndex = 1

local OUTFITS = {
    { label = "OFF" },
    {
        label = "Outfit 1",
        hideOriginalHead = true,
        clearOriginalWearables = true,
        bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
        items = {10997283529, 125085889448130},
    },
    {
        label = "Outfit 2",
        clearOriginalWearables = true,
        bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
        items = {125157548394108, 123231522991173, 74827642361405},
    },
    {
        label = "Outfit 3",
        clearOriginalWearables = true,
        bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
        face = 86109936998865,
        items = {136644276218918, 132022106987543, 131740907052260},
    },
    {
        label = "Outfit 4",
        headless = true,
        clearOriginalWearables = true,
        bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
        items = {119331031817124, 84952305140948},
    },
    {
        label = "Outfit 5",
        headless = true,
        clearOriginalWearables = true,
        bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
        items = {18902416696, 17739456422, 116750288839357, 12842417046, 122223069519702},
    },
    {
        label = "Outfit 6",
        clearOriginalWearables = true,
        items = {13935333090, 16110951997, 10632503818},
    },
    {
        label = "Outfit 7",
        headless = true,
        clearOriginalWearables = true,
        items = {74891470, 4390891467, 91274263831244, 128424248603010, 91151766440767, 17044638424},
    },
    {
        label = "Outfit 8",
        headless = true,
        hideRightLeg = true,
        clearOriginalWearables = true,
        items = {76479271580913, 1402432199, 140627490971265, 128912609563885, 17449551560, 5796531729, 139607718},
    },
    {
        label = "Outfit 9",
        hideLeftLeg = true,
        hideRightLeg = true,
        clearOriginalWearables = true,
        items = {70414871864071, 14863917259, 133498027006138, 82277826177074},
    },
    {
        label = "Outfit 10",
        accessory = 10159600649,
        shirt = "http://www.roblox.com/asset/?id=9683332638",
        pants = "http://www.roblox.com/asset/?id=93182020184041",
        headless = true,
    },
    {
        label = "Outfit 11",
        accessory = 1744060292,
        shirt = "http://www.roblox.com/asset/?id=9683332638",
        pants = "http://www.roblox.com/asset/?id=93182020184041",
        headless = true,
    },
    {
        label = "Outfit 12",
        clearOriginalWearables = true,
        items = {107377896731216, 215718515, 82831174733357, 122851471549264, 139051312584295, 124572458012582, 105029428205930},
    },
    {
        label = "Outfit 13",
        clearOriginalWearables = true,
        items = {76059443, 74891470, 1180433861, 8781331764, 8682542843},
    },
    {
        label = "Outfit 14",
        clearOriginalWearables = true,
        items = {82831174733357, 139051312584295, 107062966543626, 71184246276344, 111383282415116, 78289009309744, 71017311084699},
    },
    {
        label = "Outfit 15",
        clearOriginalWearables = true,
        items = {10928435480, 6913613757, 9683332649},
        bundleItems = {263995361762992},
    },
}

local function _skinLoadObjects(id)
    local ok, res = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(id))
    end)
    if ok and type(res) == "table" and #res > 0 then return res end
    ok, res = pcall(function()
        return game:GetService("InsertService"):LoadAsset(tonumber(id) or 0)
    end)
    if ok and res then return { res } end
    return nil
end

local _skinBundleAssetCache = {}
local function _skinResolveBundleAssets(bundleId)
    bundleId = tonumber(bundleId)
    if not bundleId then return {} end
    if _skinBundleAssetCache[bundleId] then return _skinBundleAssetCache[bundleId] end
    local ids = {}
    local ok, details = pcall(function()
        return game:GetService("AssetService"):GetBundleDetailsAsync(bundleId)
    end)
    if ok and details and type(details.Items) == "table" then
        for _, item in ipairs(details.Items) do
            if item.Type == "Asset" and tonumber(item.Id) then
                ids[#ids + 1] = tonumber(item.Id)
            end
        end
    end
    _skinBundleAssetCache[bundleId] = ids
    return ids
end

local function _skinSanitize(container)
    local objects = container:GetDescendants()
    if container:IsA("BasePart") then table.insert(objects, container) end
    for _, object in ipairs(objects) do
        if object:IsA("LuaSourceContainer") then
            pcall(function() object:Destroy() end)
        elseif object:IsA("BasePart") then
            object.Anchored = false
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = false
            object.Massless = true
            object.CastShadow = false
        end
    end
end

local function _skinFindAtt(char, name)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("Attachment") and p.Name == name and p.Parent and p.Parent:IsA("BasePart")
            and not p:FindFirstAncestorWhichIsA("Accessory") then
            return p
        end
    end
end

local function _skinClearVisuals(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if tostring(child.Name):sub(1, #SKIN_TAG) == SKIN_TAG then
            pcall(function() child:Destroy() end)
        end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local ot = part:GetAttribute("NoxSkinOrigT")
            if ot ~= nil then
                part.Transparency = ot
                part.LocalTransparencyModifier = 0
                part:SetAttribute("NoxSkinOrigT", nil)
            end
            local olt = part:GetAttribute("NoxSkinOrigLT")
            if olt ~= nil then
                part.LocalTransparencyModifier = olt
                part:SetAttribute("NoxSkinOrigLT", nil)
            end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            local ot = part:GetAttribute("NoxSkinOrigT")
            if ot ~= nil then
                part.Transparency = ot
                part:SetAttribute("NoxSkinOrigT", nil)
            end
        end
    end
end

local function _skinHidePart(part)
    if not part or not part:IsA("BasePart") then return end
    if part:GetAttribute("NoxSkinOrigLT") == nil then
        part:SetAttribute("NoxSkinOrigLT", part.LocalTransparencyModifier)
    end
    if part:GetAttribute("NoxSkinOrigT") == nil then
        part:SetAttribute("NoxSkinOrigT", part.Transparency)
    end
    part.LocalTransparencyModifier = 1
    part.Transparency = 1
end

local function _skinHideHead(char)
    local head = char:FindFirstChild("Head")
    if head then
        _skinHidePart(head)
        for _, d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                if d:GetAttribute("NoxSkinOrigT") == nil then
                    d:SetAttribute("NoxSkinOrigT", d.Transparency)
                end
                d.Transparency = 1
            end
        end
    end
end

local function _skinHideLeg(char, side)
    for _, name in ipairs({side .. "UpperLeg", side .. "LowerLeg", side .. "Foot", side .. " Leg"}) do
        local p = char:FindFirstChild(name)
        if p then _skinHidePart(p) end
    end
end

local function _skinClearWearables(char)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            if not child:GetAttribute("NoxSkinLocal") then
                if child:IsA("Shirt") then child.ShirtTemplate = "" end
                if child:IsA("Pants") then child.PantsTemplate = "" end
                if child:IsA("ShirtGraphic") then child.Graphic = "" end
            end
        elseif (child:IsA("Accessory") or child:IsA("Accoutrement")) and not child:GetAttribute("NoxSkinLocal") then
            for _, obj in ipairs(child:GetDescendants()) do
                if obj:IsA("BasePart") then
                    _skinHidePart(obj)
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    if obj:GetAttribute("NoxSkinOrigT") == nil then
                        obj:SetAttribute("NoxSkinOrigT", obj.Transparency)
                    end
                    obj.Transparency = 1
                end
            end
        end
    end
end

local function _skinAttachAccessory(char, assetId)
    local objs = _skinLoadObjects(assetId)
    if not objs then return false end
    local attached = false
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    for _, root in ipairs(objs) do
        local accessories = {}
        if root:IsA("Accessory") then
            table.insert(accessories, root:Clone())
        else
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("Accessory") then table.insert(accessories, d:Clone()) end
            end
            -- classic clothing
            local function cloneClothing(src)
                local c = src:Clone()
                c.Name = SKIN_TAG .. "cloth_" .. tostring(assetId)
                c:SetAttribute("NoxSkinLocal", true)
                c.Parent = char
                attached = true
            end
            if root:IsA("Shirt") or root:IsA("Pants") or root:IsA("ShirtGraphic") then
                cloneClothing(root)
            end
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then
                    cloneClothing(d)
                end
            end
        end
        for _, acc in ipairs(accessories) do
            local handle = acc:FindFirstChild("Handle") or acc:FindFirstChildWhichIsA("BasePart", true)
            if handle then
                _skinSanitize(acc)
                acc.Name = SKIN_TAG .. "acc_" .. tostring(assetId)
                acc:SetAttribute("NoxSkinLocal", true)
                local addedByHumanoid = false
                if humanoid then
                    addedByHumanoid = pcall(function() humanoid:AddAccessory(acc) end)
                end
                if not addedByHumanoid or acc.Parent ~= char then
                    acc.Parent = char
                end
                local sourceAtt
                for _, child in ipairs(handle:GetChildren()) do
                    if child:IsA("Attachment") and _skinFindAtt(char, child.Name) then
                        sourceAtt = child
                        break
                    end
                end
                local targetAtt = sourceAtt and _skinFindAtt(char, sourceAtt.Name)
                local targetPart = (targetAtt and targetAtt.Parent) or char:FindFirstChild("Head")
                    or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    or char:FindFirstChild("HumanoidRootPart")
                if targetPart and targetPart:IsA("BasePart") then
                    local existingWeld = handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChild("AdaptAccessoryWeld")
                    if not existingWeld then
                        if targetAtt and sourceAtt then
                            handle.CFrame = targetAtt.WorldCFrame * sourceAtt.CFrame:Inverse()
                        else
                            handle.CFrame = targetPart.CFrame
                        end
                        local w = Instance.new("WeldConstraint")
                        w.Name = "NoxSkinAccessoryWeld"
                        w.Part0 = targetPart
                        w.Part1 = handle
                        w.Parent = handle
                    end
                    attached = true
                else
                    pcall(function() acc:Destroy() end)
                end
            end
        end
        -- body parts fallback
        local BODY = {
            Head=true, UpperTorso=true, LowerTorso=true, Torso=true,
            LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
            RightUpperArm=true, RightLowerArm=true, RightHand=true,
            LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true,
            RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
            ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true,
        }
        local holder = Instance.new("Model")
        holder.Name = SKIN_TAG .. "body_" .. tostring(assetId)
        holder:SetAttribute("NoxSkinLocal", true)
        local partsAdded = 0
        local candidates = {}
        if root:IsA("BasePart") then table.insert(candidates, root) end
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BasePart") and not d:FindFirstAncestorWhichIsA("Accessory") then
                table.insert(candidates, d)
            end
        end
        for _, source in ipairs(candidates) do
            if BODY[source.Name] then
                local target = char:FindFirstChild(source.Name)
                if target and target:IsA("BasePart") then
                    local clone = source:Clone()
                    _skinSanitize(clone)
                    for _, ch in ipairs(clone:GetDescendants()) do
                        if ch:IsA("JointInstance") or ch:IsA("Constraint") or ch:IsA("LuaSourceContainer") then
                            pcall(function() ch:Destroy() end)
                        end
                    end
                    clone.Name = source.Name
                    clone.CFrame = target.CFrame
                    clone.Parent = holder
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = target
                    w.Part1 = clone
                    w.Parent = clone
                    partsAdded = partsAdded + 1
                end
            end
        end
        if partsAdded > 0 then
            holder.Parent = char
            attached = true
        else
            holder:Destroy()
        end
        pcall(function() root:Destroy() end)
    end
    return attached
end

local function captureOriginalAppearance(char)
    if not char or _originalAppearance then return end
    local data = { bodyColors = nil, shirt = nil, pants = nil }
    local bc = char:FindFirstChildWhichIsA("BodyColors")
    if bc then
        data.bodyColors = {
            head = bc.HeadColor3, torso = bc.TorsoColor3,
            leftArm = bc.LeftArmColor3, rightArm = bc.RightArmColor3,
            leftLeg = bc.LeftLegColor3, rightLeg = bc.RightLegColor3,
        }
    end
    local sh = char:FindFirstChildWhichIsA("Shirt")
    if sh then data.shirt = sh.ShirtTemplate end
    local pa = char:FindFirstChildWhichIsA("Pants")
    if pa then data.pants = pa.PantsTemplate end
    _originalAppearance = data
end

local function applyNoOutfit(char)
    if not char then char = LP.Character end
    if not char then return end
    _skinClearVisuals(char)
    if _originalAppearance and _originalAppearance.bodyColors then
        local bc = char:FindFirstChildWhichIsA("BodyColors") or Instance.new("BodyColors")
        local o = _originalAppearance.bodyColors
        bc.HeadColor3, bc.TorsoColor3 = o.head, o.torso
        bc.LeftArmColor3, bc.RightArmColor3 = o.leftArm, o.rightArm
        bc.LeftLegColor3, bc.RightLegColor3 = o.leftLeg, o.rightLeg
        bc.Parent = char
    end
    if _originalAppearance and _originalAppearance.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.ShirtTemplate = _originalAppearance.shirt
        s.Parent = char
    end
    if _originalAppearance and _originalAppearance.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.PantsTemplate = _originalAppearance.pants
        p.Parent = char
    end
    for _, a in ipairs(char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then h.Transparency = 0; h.LocalTransparencyModifier = 0 end
        end
    end
end

local function clearPreviousOutfitAssets(char)
    _skinClearVisuals(char)
end

function applyHomeroOutfit(char)
    -- kept for compatibility; routes through applyOutfitByIndex
    if currentOutfitIndex and OUTFITS[currentOutfitIndex] then
        applyOutfitByIndex(currentOutfitIndex)
    end
end

function applyOutfitByIndex(index)
    index = tonumber(index) or 1
    if index < 1 then index = 1 end
    if index > #OUTFITS then index = #OUTFITS end
    currentOutfitIndex = index
    local opt = OUTFITS[index]
    if not opt then return end
    local char = LP and LP.Character
    if not char then return end
    if not char:FindFirstChildOfClass("Humanoid") then return end
    captureOriginalAppearance(char)
    _skinClearVisuals(char)

    if opt.label == "OFF" or index == 1 then
        applyNoOutfit(char)
        if outfitSelectorLabel then outfitSelectorLabel.Text = opt.label end
        return
    end

    if opt.clearOriginalWearables then _skinClearWearables(char) end
    if opt.headless or opt.hideOriginalHead then _skinHideHead(char) end
    if opt.hideLeftLeg then _skinHideLeg(char, "Left") end
    if opt.hideRightLeg then _skinHideLeg(char, "Right") end

    if opt.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"
        s.ShirtTemplate = opt.shirt
        s:SetAttribute("NoxSkinLocal", true)
        s.Parent = char
    end
    if opt.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"
        p.PantsTemplate = opt.pants
        p:SetAttribute("NoxSkinLocal", true)
        p.Parent = char
    end

    local allIds = {}
    for _, id in ipairs(opt.bodyItems or {}) do table.insert(allIds, id) end
    for _, id in ipairs(opt.items or {}) do table.insert(allIds, id) end
    for _, bundleId in ipairs(opt.bundleItems or {}) do
        for _, assetId in ipairs(_skinResolveBundleAssets(bundleId)) do
            table.insert(allIds, assetId)
        end
    end
    if opt.accessory then table.insert(allIds, opt.accessory) end
    if opt.face then table.insert(allIds, opt.face) end

    for _, id in ipairs(allIds) do
        pcall(_skinAttachAccessory, char, id)
    end

    if outfitSelectorLabel then outfitSelectorLabel.Text = opt.label end
    pcall(function() if saveAllSettings then saveAllSettings(true) end end)
end

function cycleOutfit(delta)
    local n = #OUTFITS
    if n < 1 then return end
    local nextIdx = ((currentOutfitIndex - 1 + (delta or 1)) % n) + 1
    applyOutfitByIndex(nextIdx)
end
-- ============================================================
selectedStealMode = "V1"
speedMode = false
antiRagdollMode = "off"
antiDieEnabled = false
antiBatEnabled = false
antiFlingEnabled = false
jumpEnabled = false
laggerToggled = false
laggerCarryToggled = false
autoBrainrotSpeedEnabled = false
autoCarryEnabled = false
autoCarryMode = "WHEN NEAR"
autoCarrySetVisual = nil
autoCarryModeLabel = nil
autoCarryOverrideActive = false
autoCarryPreviousState = nil
autoCarryHeartbeatConn = nil
autoCarryStealConn = nil
autoCarryCharConn = nil
autoSpinEnabled = false
autoSpinSetVisual = nil
SPIN_BOT_SPEED = 40
SPIN_BOT_CONN = nil
SPIN_BOT_STEP_CONN = nil
SPIN_BOT_SAFE_POS = nil
SPIN_BOT_ACTIVE = false
medusaCounterEnabled = false
batCounterEnabled = false
autoLeftEnabled = false
autoRightEnabled = false
autoBatEnabled = false
dropMode = 1
antiLagEnabled = false
removeAccessoriesEnabled = false
stretchEnabled = false
stretchFOV = 120
uiLocked = false
local noxMoveLockButton = nil
local noxMenuPositionMigrated = false
mobileButtonsLocked = false
uiScaleValue = 88
espEnabled = false
espLineEnabled = false
vividGraphicsEnabled = false
_vividEffects = {}
setVividVisual = nil
hideButtonsEnabled = false
setHideButtonsVisual = nil
if _G.__NoxControllerShiftCleanup then pcall(_G.__NoxControllerShiftCleanup) end
controllerLockShiftEnabled = false -- removed from visual
controllerLockShiftKey = Enum.KeyCode.ButtonR3
controllerShiftRenderConn = nil
controllerShiftCharacter = nil
controllerShiftOriginalAutoRotate = nil
controllerShiftOriginalCameraOffset = nil
controllerShiftStateButton = nil
controllerShiftBindButton = nil
controllerShiftListening = false
controllerShiftInputConnection = nil
bodyLockEnabled = false
bodyLockRange = 20
bodyLockRangeBox = nil
_bodyLockConn = nil
_blSuppressCount = 0
_blWasEnabled = false
_blRestoreTimer = nil
_blSmoothRestore = false
savedProgressBarPos = nil
savedButtonPositions = {}
savedMobilePanelPos = nil
instaResetFloatingPos = nil
instaResetFloatingButton = nil
neonWeatherEnabled = false
skyTheme = "Off"
skySelectorLabel = nil
_originalLighting = nil
setNeonWeatherVisual = nil
currentAnimPack = "Off"
originalTryardAnims = nil
tryardHeartbeatConn = nil
animSelectorLabel = nil
lastMoveDir = _V3zero
local CoreGui = game:GetService("CoreGui")
local InfiniteJump = { enabled = false, jumpPower = 55, minVelocity = 35, fallClamp = -120, jumpConn = nil, heartbeatConn = nil }
local function applyJump(root)
if not root then return end
pcall(function()
root.Velocity = _V3new(root.Velocity.X, InfiniteJump.jumpPower, root.Velocity.Z)
end)
end
local function onJumpRequest()
if not InfiniteJump.enabled then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if root then applyJump(root) end
end
local function onHeartbeat()
if not InfiniteJump.enabled then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then return end
local jumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump == true)
if jumpHeld and root.Velocity.Y < InfiniteJump.minVelocity then
applyJump(root)
end
if root.Velocity.Y < InfiniteJump.fallClamp then
root.Velocity = _V3new(root.Velocity.X, InfiniteJump.fallClamp, root.Velocity.Z)
end
end
local function connectEvents()
if InfiniteJump.jumpConn then InfiniteJump.jumpConn:Disconnect() end
if InfiniteJump.heartbeatConn then InfiniteJump.heartbeatConn:Disconnect() end
InfiniteJump.jumpConn = UIS.JumpRequest:Connect(onJumpRequest)
InfiniteJump.heartbeatConn = RunService.Heartbeat:Connect(onHeartbeat)
end
function InfiniteJump.start()
if InfiniteJump.enabled then return end
InfiniteJump.enabled = true
connectEvents()
end
function InfiniteJump.stop()
InfiniteJump.enabled = false
if InfiniteJump.jumpConn then InfiniteJump.jumpConn:Disconnect(); InfiniteJump.jumpConn = nil end
if InfiniteJump.heartbeatConn then InfiniteJump.heartbeatConn:Disconnect(); InfiniteJump.heartbeatConn = nil end
end
function InfiniteJump.setJumpPower(power)
power = tonumber(power) or 55
InfiniteJump.jumpPower = _clamp(power, 10, 200)
end
function InfiniteJump.isRunning() return InfiniteJump.enabled == true end
-- InfiniteJump starts only from toggle/config

-- Speed-tab Hold Infinite Jump (independent from Anti Bat Infinite Jump)
local SpeedHoldInfJump = {
    enabled = false,
    jumpPower = 50,
    holdPressed = false,
    holdActive = false,
    controllerActive = false,
    mobilePressed = false,
    mobileActive = false,
    inputBegan = nil,
    inputEnded = nil,
    heartbeat = nil,
    mobileHooks = {},
}
local function _speedHoldApplyBoost()
    if not SpeedHoldInfJump.enabled then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X, SpeedHoldInfJump.jumpPower, v.Z)
    end)
end
local function _speedHoldStopState()
    SpeedHoldInfJump.holdPressed = false
    SpeedHoldInfJump.holdActive = false
    SpeedHoldInfJump.controllerActive = false
    SpeedHoldInfJump.mobilePressed = false
    SpeedHoldInfJump.mobileActive = false
end
local function _speedHoldHookJumpButton(btn)
    if not btn or btn.Name ~= "JumpButton" or not btn:IsA("GuiButton") then return end
    if SpeedHoldInfJump.mobileHooks[btn] then return end
    SpeedHoldInfJump.mobileHooks[btn] = true
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch or not SpeedHoldInfJump.enabled then return end
        SpeedHoldInfJump.mobilePressed = true
        task.delay(0.12, function()
            if SpeedHoldInfJump.mobilePressed and SpeedHoldInfJump.enabled then
                SpeedHoldInfJump.mobileActive = true
                _speedHoldApplyBoost()
            end
        end)
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            SpeedHoldInfJump.mobilePressed = false
            SpeedHoldInfJump.mobileActive = false
        end
    end)
end
function startSpeedHoldInfJump()
    if SpeedHoldInfJump.enabled then return end
    SpeedHoldInfJump.enabled = true
    if SpeedHoldInfJump.inputBegan then pcall(function() SpeedHoldInfJump.inputBegan:Disconnect() end) end
    if SpeedHoldInfJump.inputEnded then pcall(function() SpeedHoldInfJump.inputEnded:Disconnect() end) end
    if SpeedHoldInfJump.heartbeat then pcall(function() SpeedHoldInfJump.heartbeat:Disconnect() end) end
    SpeedHoldInfJump.inputBegan = UIS.InputBegan:Connect(function(input, gp)
        if not SpeedHoldInfJump.enabled then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
            SpeedHoldInfJump.holdPressed = true
            task.delay(0.1, function()
                if SpeedHoldInfJump.holdPressed and SpeedHoldInfJump.enabled then
                    SpeedHoldInfJump.holdActive = true
                    _speedHoldApplyBoost()
                end
            end)
        end
        if input.KeyCode == Enum.KeyCode.ButtonA and tostring(input.UserInputType):find("Gamepad") then
            SpeedHoldInfJump.controllerActive = true
        end
    end)
    SpeedHoldInfJump.inputEnded = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
            SpeedHoldInfJump.holdPressed = false
            SpeedHoldInfJump.holdActive = false
        end
        if input.KeyCode == Enum.KeyCode.ButtonA then
            SpeedHoldInfJump.controllerActive = false
        end
    end)
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, d in ipairs(pg:GetDescendants()) do _speedHoldHookJumpButton(d) end
        pg.DescendantAdded:Connect(function(d) task.defer(_speedHoldHookJumpButton, d) end)
    end
    SpeedHoldInfJump.heartbeat = RunService.Heartbeat:Connect(function()
        if not SpeedHoldInfJump.enabled then return end
        local active = SpeedHoldInfJump.holdActive
            or SpeedHoldInfJump.mobileActive
            or SpeedHoldInfJump.controllerActive
        if active then
            _speedHoldApplyBoost()
        end
    end)
end
function stopSpeedHoldInfJump()
    SpeedHoldInfJump.enabled = false
    _speedHoldStopState()
    if SpeedHoldInfJump.inputBegan then pcall(function() SpeedHoldInfJump.inputBegan:Disconnect() end); SpeedHoldInfJump.inputBegan = nil end
    if SpeedHoldInfJump.inputEnded then pcall(function() SpeedHoldInfJump.inputEnded:Disconnect() end); SpeedHoldInfJump.inputEnded = nil end
    if SpeedHoldInfJump.heartbeat then pcall(function() SpeedHoldInfJump.heartbeat:Disconnect() end); SpeedHoldInfJump.heartbeat = nil end
end
function setSpeedHoldInfJump(on)
    if on then startSpeedHoldInfJump() else stopSpeedHoldInfJump() end
    if infJumpSpeedSetVisual then infJumpSpeedSetVisual(SpeedHoldInfJump.enabled) end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return SpeedHoldInfJump.enabled
end
_G.SpeedHoldInfJump = SpeedHoldInfJump

function getActiveMoveSpeed()
if laggerCarryToggled then return LAGGER_CARRY_SPEED
elseif laggerToggled then return LAGGER_SPEED
elseif speedMode then return CS
else return NS end
end
function getSpeedModeName()
if laggerToggled or laggerCarryToggled then return "LAGGER"
elseif speedMode then return "CARRY"
else return "NORMAL" end
end
local _s2VelState = _G.__YoutSpeedHookState
if type(_s2VelState) ~= "table" then
_s2VelState = {
hooked = false,
velChecked = setmetatable({}, { __mode = "k" }),
root = nil,
v = _V3zero,
}
_G.__YoutSpeedHookState = _s2VelState
end
local _velChecked = _s2VelState.velChecked
local _hookedVelParts = {}
local _hookVelSupported = nil
local function _hookVelHRP(hrp)
if not hrp then return end
_s2VelState.root = hrp
_velChecked[hrp] = true
if _s2VelState.hooked then return end
if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function"
or type(newcclosure) ~= "function" or type(checkcaller) ~= "function" then
return
end
local ok = pcall(function()
local mt = getrawmetatable(game)
if not mt then return end
setreadonly(mt, false)
local originalIndex = rawget(mt, "__index")
local originalNewIndex = rawget(mt, "__newindex")
local function isOurRoot(t, k)
local tk = tostring(k)
if tk ~= "AssemblyLinearVelocity" and tk ~= "Velocity" then return false end
if typeof(t) ~= "Instance" or not t:IsA("BasePart") then return false end
local tn = t.Name
if tn ~= "HumanoidRootPart" and tn ~= "Torso" and tn ~= "UpperTorso" then return false end
local char = LP.Character
return char ~= nil and t:IsDescendantOf(char)
end
if type(originalIndex) == "function" or type(originalIndex) == "table" then
local replacementIndex = newcclosure(function(self, key)
if not checkcaller() then
local good, mine = pcall(isOurRoot, self, key)
if good and mine then return _s2VelState.v end
end
if type(originalIndex) == "function" then
return originalIndex(self, key)
else
return originalIndex[key]
end
end)
mt.__index = replacementIndex
end
if type(originalNewIndex) == "function" then
local replacementNewIndex = newcclosure(function(self, key, value)
if not checkcaller() then
local good, mine = pcall(isOurRoot, self, key)
if good and mine then
_s2VelState.v = value
return
end
end
return originalNewIndex(self, key, value)
end)
mt.__newindex = replacementNewIndex
end
setreadonly(mt, true)
_s2VelState.hooked = true
end)
if not ok then _s2VelState.hooked = false end
end
local function _setupVelChecked(char)
_velChecked = setmetatable({}, { __mode = "k" })
_s2VelState.velChecked = _velChecked
if not char then _s2VelState.root = nil; return nil end
local hrp = char:WaitForChild("HumanoidRootPart", 5)
if hrp then
_s2VelState.root = hrp
_velChecked[hrp] = true
end
return hrp
end
if LP.Character then
local _hrp0 = _setupVelChecked(LP.Character)
_hookVelHRP(_hrp0)
end
local function _isRagdollState(hum)
if not hum then return true end
local st = hum:GetState()
return hum.PlatformStand
or st == Enum.HumanoidStateType.Physics
or st == Enum.HumanoidStateType.Ragdoll
or st == Enum.HumanoidStateType.FallingDown
end
local _youtVelRng = Random.new()
local function _applyVelocitySpeed(dir, speed, hrp)
if not hrp or not hrp.Parent then return end
if autoBatEnabled or antiBypassEnabled then return end
if type(speed) ~= "number" or speed ~= speed or speed <= 0 or speed == math.huge then return end
local verticalVelocity = hrp.AssemblyLinearVelocity.Y
if dir and dir.Magnitude > 0.05 then
pcall(function()
if hrp.SetNetworkOwner then hrp:SetNetworkOwner(LP) end
end)
local unit = dir.Unit
local jx = _youtVelRng:NextNumber(-0.003, 0.003)
local jz = _youtVelRng:NextNumber(-0.003, 0.003)
_s2VelState.v = _V3new(unit.X * 16 + jx, verticalVelocity, unit.Z * 16 + jz)
hrp.AssemblyLinearVelocity = _V3new(unit.X * speed + jx, verticalVelocity, unit.Z * speed + jz)
_G.__YoutLiveSpeed = { t = os.clock(), v = speed }
else
_s2VelState.v = _V3new(0, verticalVelocity, 0)
hrp.AssemblyLinearVelocity = _V3new(0, verticalVelocity, 0)
end
end
function getAutoPathSpeed()
if laggerCarryToggled or laggerToggled then return LAGGER_SPEED end
return NS
end
currentAnimPack = "Off"
animSelectorLabel = nil
local ANIM_PACKS = {
["Hit Harder"] = {idle1="rbxassetid://133806214992291",idle2="rbxassetid://94970088341563",walk="rbxassetid://707897309",run="rbxassetid://707861613",jump="rbxassetid://116936326516985",fall="rbxassetid://116936326516985",climb="rbxassetid://507765644"},
["Crazy"] = {idle1="rbxassetid://133806214992291",idle2="rbxassetid://94970088341563",walk="rbxassetid://134824450619865",run="rbxassetid://134824450619865",jump="rbxassetid://121454505477205",fall="rbxassetid://94788218468396",climb="rbxassetid://121454505477205"},
["Zombie"] = {idle1="rbxassetid://616158929",idle2="rbxassetid://616158929",walk="rbxassetid://616168032",run="rbxassetid://616163682",jump="rbxassetid://616161997",fall="rbxassetid://616157476",climb="rbxassetid://616156119"},
["Ninja"] = {idle1="rbxassetid://656117400",idle2="rbxassetid://656117400",walk="rbxassetid://656121766",run="rbxassetid://656118852",jump="rbxassetid://656117878",fall="rbxassetid://656115606",climb="rbxassetid://656114359"},
["Knight"] = {idle1="rbxassetid://657595757",idle2="rbxassetid://657595757",walk="rbxassetid://657552124",run="rbxassetid://657564596",jump="rbxassetid://658409194",fall="rbxassetid://657600338",climb="rbxassetid://658360781"},
["Elder"] = {idle1="rbxassetid://845397899",idle2="rbxassetid://845397899",walk="rbxassetid://845403856",run="rbxassetid://845386501",jump="rbxassetid://845398858",fall="rbxassetid://845397673",climb="rbxassetid://845392038"},
["Levitate"] = {idle1="rbxassetid://616006778",idle2="rbxassetid://616006778",walk="rbxassetid://616013216",run="rbxassetid://616013216",jump="rbxassetid://616008936",fall="rbxassetid://616005863",climb="rbxassetid://616003713"},
}
ANIM_PACK_ORDER = {"Off","Hit Harder","Crazy","Zombie","Ninja","Knight","Elder","Levitate"}
_animPackOriginal = nil
local function _animGetAnimate(char)
return char and char:FindFirstChild("Animate")
end
local function _animSetId(anim, id)
if anim and id then pcall(function() anim.AnimationId = id end) end
end
local function _animGet(animate, folder, name)
local f = animate and animate:FindFirstChild(folder)
return f and f:FindFirstChild(name)
end
local function _animBackup(char, animate)
if _animPackOriginal then return end
_animPackOriginal = {}
for _, pair in ipairs({{"idle","Animation1"},{"idle","Animation2"},{"walk","WalkAnim"},{"run","RunAnim"},{"jump","JumpAnim"},{"fall","FallAnim"},{"climb","ClimbAnim"}}) do
local a = _animGet(animate, pair[1], pair[2])
if a then _animPackOriginal[pair[1].."_"..pair[2]] = a.AnimationId end
end
end
local function _animApplyIds(char, animate, pack)
if not pack or not animate then return end
_animSetId(_animGet(animate,"idle","Animation1"), pack.idle1)
_animSetId(_animGet(animate,"idle","Animation2"), pack.idle2 or pack.idle1)
_animSetId(_animGet(animate,"walk","WalkAnim"), pack.walk)
_animSetId(_animGet(animate,"run","RunAnim"), pack.run)
_animSetId(_animGet(animate,"jump","JumpAnim"), pack.jump)
_animSetId(_animGet(animate,"fall","FallAnim"), pack.fall)
_animSetId(_animGet(animate,"climb","ClimbAnim"), pack.climb)
pcall(function()
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end
end)
end
function startAnimPack(packName)
currentAnimPack = packName or "Off"
local char = LP.Character
if not char then return end
local animate = _animGetAnimate(char) or char:WaitForChild("Animate", 3)
if not animate then return end
_animBackup(char, animate)
if currentAnimPack == "Off" or not ANIM_PACKS[currentAnimPack] then
if _animPackOriginal then
local restore = {}
for k,v in pairs(_animPackOriginal) do
local folder, name = k:match("^(.-)_(.+)$")
if folder then _animSetId(_animGet(animate, folder, name), v) end
end
end
return
end
_animApplyIds(char, animate, ANIM_PACKS[currentAnimPack])
end
local function stopAnimPack()
startAnimPack("Off")
end
local function applyAnimPack(packName)
startAnimPack(packName)
end
local function saveOriginalAnims(char) end

DEFAULT_KB = {
DropBrainrot = {kb = Enum.KeyCode.X, gp = nil},
AutoLeft = {kb = Enum.KeyCode.Z, gp = nil},
AutoRight = {kb = Enum.KeyCode.C, gp = nil},
AutoBat = {kb = Enum.KeyCode.E, gp = nil},
TPFloor = {kb = Enum.KeyCode.F, gp = nil},
GuiHide = {kb = Enum.KeyCode.LeftControl, gp = nil},
CarryToggle = {kb = Enum.KeyCode.Q, gp = nil},
LaggerMode = {kb = Enum.KeyCode.R, gp = nil},
InstaReset = {kb = Enum.KeyCode.H, gp = nil},
AntiBypass = {kb = Enum.KeyCode.B, gp = nil},
}
KB = {
DropBrainrot = {kb = DEFAULT_KB.DropBrainrot.kb, gp = DEFAULT_KB.DropBrainrot.gp},
AutoLeft = {kb = DEFAULT_KB.AutoLeft.kb, gp = DEFAULT_KB.AutoLeft.gp},
AutoRight = {kb = DEFAULT_KB.AutoRight.kb, gp = DEFAULT_KB.AutoRight.gp},
AutoBat = {kb = DEFAULT_KB.AutoBat.kb, gp = DEFAULT_KB.AutoBat.gp},
TPFloor = {kb = DEFAULT_KB.TPFloor.kb, gp = DEFAULT_KB.TPFloor.gp},
GuiHide = {kb = DEFAULT_KB.GuiHide.kb, gp = DEFAULT_KB.GuiHide.gp},
CarryToggle = {kb = DEFAULT_KB.CarryToggle.kb, gp = DEFAULT_KB.CarryToggle.gp},
LaggerMode = {kb = DEFAULT_KB.LaggerMode.kb, gp = DEFAULT_KB.LaggerMode.gp},
InstaReset = {kb = DEFAULT_KB.InstaReset.kb, gp = DEFAULT_KB.InstaReset.gp},
AntiBypass = {kb = DEFAULT_KB.AntiBypass.kb, gp = DEFAULT_KB.AntiBypass.gp},
}
_isResetting = false
_lastSavedJSON = nil
_isLoading = false
CONFIG = { AUTO_STEAL_ENABLED = false, STEAL_RANGE = 61 }
local plots = Workspace:FindFirstChild("Plots")
local stealConnection = nil
local Steal = { AutoStealEnabled = false, StealRadius = CONFIG.STEAL_RANGE, StealDuration = 1.3, StealDelay = 0.25, Data = {} }
local isStealing = false
local autoGrabSetDelayRadius = 9
local autoGrabStopTime = 0.96
local autoGrabStopEnabled = true
local _plotsCache = nil
local _plotsCacheTime = 0
local function getPlotsRoot()
local now = _tick()
if _plotsCache and now - _plotsCacheTime < 2 and _plotsCache.Parent then
return _plotsCache
end
_plotsCache = workspace:FindFirstChild("Plots")
_plotsCacheTime = now
return _plotsCache
end
local function isMyPlotByName(plotName)
local plotsRoot = getPlotsRoot()
if not plotsRoot then return false end
local plot = plotsRoot:FindFirstChild(plotName)
if not plot then return false end
local sign = plot:FindFirstChild("PlotSign")
if sign then
local yb = sign:FindFirstChild("YourBase")
if yb and yb:IsA("BillboardGui") then
return yb.Enabled == true
end
end
return false
end
local function findNearestPrompt()
local char = LP.Character
if not char then return nil, nil end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return nil, nil end
local plotsRoot = getPlotsRoot()
if not plotsRoot then return nil, nil end
local nearestPrompt, nearestDist, nearestName = nil, _huge, nil
local rpos = root.Position
for _, plot in ipairs(plotsRoot:GetChildren()) do
if isMyPlotByName(plot.Name) then continue end
local pods = plot:FindFirstChild("AnimalPodiums")
if not pods then continue end
for _, pod in ipairs(pods:GetChildren()) do
pcall(function()
local base = pod:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
if spawn then
local sp = spawn.Position
local dx = sp.X - rpos.X
local dy = sp.Y - rpos.Y
local dz = sp.Z - rpos.Z
local dist = _sqrt(dx*dx + dy*dy + dz*dz)
if dist < nearestDist and dist <= Steal.StealRadius then
local att = spawn:FindFirstChild("PromptAttachment")
if att then
for _, child in ipairs(att:GetChildren()) do
if child:IsA("ProximityPrompt") and child.ActionText and child.ActionText:find("Steal") then
nearestPrompt = child
nearestDist = dist
nearestName = pod.Name
break
end
end
end
end
end
end)
end
end
return nearestPrompt, nearestName
end
local function executeSteal(prompt, podName)
if isStealing then return end
if math.random(30) == 1 then
for p in pairs(Steal.Data) do
if not p.Parent then Steal.Data[p] = nil end
end
end
if not Steal.Data[prompt] then
Steal.Data[prompt] = { hold = {}, trigger = {}, ready = true }
pcall(function()
if getconnections then
for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
if c.Function then table.insert(Steal.Data[prompt].hold, c.Function) end
end
for _, c in ipairs(getconnections(prompt.Triggered)) do
if c.Function then table.insert(Steal.Data[prompt].trigger, c.Function) end
end
end
end)
end
local data = Steal.Data[prompt]
if not data.ready then return end
data.ready = false
isStealing = true
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
if progressPct then progressPct.Text = "0%" end
task.spawn(function()
for _, f in ipairs(data.hold) do task.spawn(f) end
local startTime = _tick()
local duration = Steal.StealDuration
local promptFired = false
if autoGrabStopEnabled then
while isStealing and Steal.AutoStealEnabled do
local elapsed = _tick() - startTime
if elapsed >= autoGrabStopTime then break end
local progress = _clamp(elapsed / duration, 0, 1)
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(progress, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
if progressPct then progressPct.Text = _floor(progress * 100) .. "%" end
if not prompt.Parent or not prompt.Parent.Parent then break end
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then
break
end
task.wait()
end
local stopProgress = _clamp(autoGrabStopTime / duration, 0, 1)
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(stopProgress, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(stopProgress, 0, 1, 0) end
if progressPct then progressPct.Text = _floor(stopProgress * 100) .. "%" end
local phase2Timeout = math.max(2.99 - autoGrabStopTime - math.max(duration - autoGrabStopTime, 0), 0.05)
local phase2Start = _tick()
while isStealing and Steal.AutoStealEnabled do
if _tick() - phase2Start >= phase2Timeout then
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
if progressPct then progressPct.Text = "0%" end
data.ready = true
isStealing = false
task.wait()
local newPrompt, newName = findNearestPrompt()
if newPrompt then executeSteal(newPrompt, newName) end
return
end
if not prompt.Parent or not prompt.Parent.Parent then
isStealing = false
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
if progressPct then progressPct.Text = "0%" end
data.ready = true
return
end
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if hrp then
local dist = (hrp.Position - prompt.Parent.Parent.Position).Magnitude
if dist <= autoGrabSetDelayRadius then
break
elseif dist > Steal.StealRadius then
isStealing = false
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
if progressPct then progressPct.Text = "0%" end
data.ready = true
return
end
end
task.wait()
end
if isStealing and Steal.AutoStealEnabled then
local fillStart = _tick()
local fillDuration = math.max(duration - autoGrabStopTime, 0.05)
while true do
local fp = _clamp((_tick() - fillStart) / fillDuration, 0, 1)
local totalProgress = stopProgress + fp * (1 - stopProgress)
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(totalProgress, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(totalProgress, 0, 1, 0) end
if progressPct then progressPct.Text = _floor(totalProgress * 100) .. "%" end
if fp >= 1 and not promptFired then
promptFired = true
pcall(function()
if #data.trigger > 0 then
for _, f in ipairs(data.trigger) do task.spawn(f) end
else
local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
if remote and podName then remote:FireServer(podName) end
end
end)
break
end
task.wait()
end
end
else
while isStealing and Steal.AutoStealEnabled do
local elapsed = _tick() - startTime
local progress = _clamp(elapsed / duration, 0, 1)
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(progress, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
if progressPct then progressPct.Text = _floor(progress * 100) .. "%" end
if not prompt.Parent or not prompt.Parent.Parent then break end
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then break end
if elapsed >= duration and not promptFired then
promptFired = true
pcall(function()
if #data.trigger > 0 then
for _, f in ipairs(data.trigger) do task.spawn(f) end
else
local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
if remote and podName then remote:FireServer(podName) end
end
end)
break
end
task.wait()
end
end
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
if progressPct then progressPct.Text = "0%" end
data.ready = true
isStealing = false
end)
end
_G.YoutV2Steal = _G.YoutV2Steal or {
enabled = false, radius = 10, primeRange = 80, holdMin = 1.3, holdMax = 2.6,
entryDelay = 0.25, cooldown = 0.05,
animals = {}, promptCache = {}, internalCache = {},
state = {active = false, startTime = 0, phase = "idle", label = "", lastResult = "", lastResultTime = 0},
plotSync = {caches = {}, connections = {}}, plots = nil, syncReady = false,
scanThread = nil, conn = nil, lastScan = 0,
animalsData = nil, channelFolder = nil, routeRemote = nil, requestData = nil
}
local function _yv2Root()
local c = LP.Character
return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")) or nil
end
local function _yv2SplitPath(path)
if typeof(path) == "table" then return path end
local out = {}
for p in string.gmatch(tostring(path), "[^%.]+") do table.insert(out, tonumber(p) or p) end
return out
end
local function _yv2ResolvePath(path, root)
local cur, par, key = root, nil, nil
for _, p in ipairs(_yv2SplitPath(path)) do
par = cur; key = p; cur = cur and cur[p] or nil
end
return cur, par, key
end
local function _yv2ApplyDiff(channelName, packet)
local cache = _G.YoutV2Steal.plotSync.caches[channelName]
if typeof(cache) ~= "table" then return end
local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
local cur, par, key = _yv2ResolvePath(path, cache)
if action == "Changed" then
if par then par[key] = a end
elseif action == "ArrayInsert" then
if cur then table.insert(cur, b, a) end
elseif action == "ArrayRemoved" then
if cur then table.remove(cur, b) end
elseif action == "DictionaryInsert" then
if cur then cur[b] = a end
elseif action == "DictionaryRemoved" then
if cur then cur[b] = nil end
end
end
local function _yv2AttachChannel(remote, plots, requestData)
local A = _G.YoutV2Steal
if A.plotSync.connections[remote] then return end
local channelName = tostring(remote.Name)
if not plots:FindFirstChild(channelName) then return end
if requestData and A.plotSync.caches[channelName] == nil then
local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
A.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
elseif A.plotSync.caches[channelName] == nil then
A.plotSync.caches[channelName] = {}
end
A.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
for _, packet in ipairs(queue) do _yv2ApplyDiff(channelName, packet) end
end)
end
local function _yv2EnsureSync()
local A = _G.YoutV2Steal
if A.syncReady then return true end
local ok = pcall(function()
A.plots = workspace:WaitForChild("Plots", 8)
local rs = game:GetService("ReplicatedStorage")
local pkgs = rs:FindFirstChild("Packages")
local datas = rs:FindFirstChild("Datas")
if not (pkgs and datas and A.plots) then return end
A.animalsData = require(datas:WaitForChild("Animals", 10))
local sync = pkgs:FindFirstChild("Synchronizer") or pkgs:WaitForChild("Synchronizer", 10)
if not sync then return end
A.channelFolder = sync:FindFirstChild("Channel") or sync:WaitForChild("Channel", 10)
A.routeRemote = sync:FindFirstChild("CommunicationRoute") or sync:WaitForChild("CommunicationRoute", 10)
A.requestData = sync:FindFirstChild("RequestData")
if A.channelFolder then
for _, child in ipairs(A.channelFolder:GetChildren()) do
if child:IsA("RemoteEvent") then _yv2AttachChannel(child, A.plots, A.requestData) end
end
A.channelFolder.ChildAdded:Connect(function(child)
if child:IsA("RemoteEvent") then _yv2AttachChannel(child, A.plots, A.requestData) end
end)
end
if A.routeRemote then
A.routeRemote.OnClientEvent:Connect(function(actions)
for _, action in ipairs(actions) do
local kind, cn = action[1], tostring(action[2])
if A.plots and A.plots:FindFirstChild(cn) then
if kind == "ListenerAdded" then
local r = A.channelFolder and A.channelFolder:FindFirstChild(cn)
if r and r:IsA("RemoteEvent") then _yv2AttachChannel(r, A.plots, A.requestData) end
elseif kind == "ListenerRemoved" then
for remote, conn in pairs(A.plotSync.connections) do
if tostring(remote.Name) == cn then
pcall(function() conn:Disconnect() end)
A.plotSync.connections[remote] = nil
A.plotSync.caches[cn] = nil
break
end
end
end
end
end
end)
end
A.syncReady = true
end)
return ok and A.syncReady == true
end
local function _yv2PlotOwner(plot)
local sign = plot and plot:FindFirstChild("PlotSign")
local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
local label = frame and frame:FindFirstChild("TextLabel")
if not label or label.Text == "Empty Base" then return nil end
return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end
local function _yv2IsMyBase(animalData)
local A = _G.YoutV2Steal
if not animalData or not animalData.plot or not A.plots then return false end
local plot = A.plots:FindFirstChild(animalData.plot)
if not plot then return false end
local owner = _yv2PlotOwner(plot)
return owner == LP.DisplayName or owner == LP.Name
end
local function _yv2PodiumFor(animalData)
local A = _G.YoutV2Steal
local plot = A.plots and A.plots:FindFirstChild(animalData.plot)
local pds = plot and plot:FindFirstChild("AnimalPodiums")
return pds and pds:FindFirstChild(animalData.slot) or nil
end
local function _yv2AnimalPos(animalData)
local pod = _yv2PodiumFor(animalData)
return pod and pod:GetPivot().Position or nil
end
local function _yv2DistToAnimal(animalData)
local root = _yv2Root()
local pos = _yv2AnimalPos(animalData)
return root and pos and (root.Position - pos).Magnitude or math.huge
end
local function _yv2FindPrompt(animalData)
local A = _G.YoutV2Steal
if not animalData then return nil end
local cached = A.promptCache[animalData.uid]
if cached and cached.Parent then return cached end
local pod = _yv2PodiumFor(animalData)
if not pod then return nil end
for _, p in ipairs(pod:GetDescendants()) do
if p:IsA("ProximityPrompt") then A.promptCache[animalData.uid] = p return p end
end
return nil
end
local function _yv2BuildCallbacks(prompt)
local A = _G.YoutV2Steal
if A.internalCache[prompt] then return end
local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
pcall(function()
if getconnections then
local holds = getconnections(prompt.PromptButtonHoldBegan) or getconnections(prompt.HoldBegan) or {}
for _, c in ipairs(holds) do
if type(c.Function) == "function" then table.insert(data.holdCallbacks, c.Function) end
end
local triggers = getconnections(prompt.Triggered) or {}
for _, c in ipairs(triggers) do
if type(c.Function) == "function" then table.insert(data.triggerCallbacks, c.Function) end
end
end
end)
A.internalCache[prompt] = data
end
local function _yv2SetBar(p)
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0) end
if progressPct then progressPct.Text = _floor(math.clamp(p, 0, 1) * 100) .. "%" end
end
local function _yv2ResetBar()
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
if progressPct then progressPct.Text = "0%" end
end
local function _yv2Execute(prompt, animalData)
local A = _G.YoutV2Steal
if not prompt or not prompt.Parent or not animalData then return false end
if A.state.active then return false end
if _tick() - (A.state.lastResultTime or 0) < (A.cooldown or 0.05) then return false end
_yv2BuildCallbacks(prompt)
local data = A.internalCache[prompt]
if not data or not data.ready then return false end
data.ready = false
A.state.active = true
A.state.startTime = _tick()
A.state.phase = "holding"
A.state.label = animalData.name or "Animal"
task.spawn(function()
local t0 = A.state.startTime
local stops = {0.70, 0.75, 0.80, 0.85, 0.90}
local SEMI_STOP = stops[math.random(1, #stops)]
if #data.holdCallbacks > 0 then
for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end
else
pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end)
end
while A.enabled and selectedStealMode == "V2" and CONFIG.AUTO_STEAL_ENABLED and _tick() - t0 < (A.holdMin or 1.3) do
local rawP = (_tick() - t0) / (A.holdMax or 2.6)
_yv2SetBar(math.min(rawP, SEMI_STOP))
task.wait()
end
A.state.phase = "waitingRange"
local alreadyInRange = _yv2DistToAnimal(animalData) <= (tonumber(A.radius) or 10)
local fired = false
while A.enabled and selectedStealMode == "V2" and CONFIG.AUTO_STEAL_ENABLED and prompt.Parent do
local elapsed = _tick() - t0
if elapsed > (A.holdMax or 2.6) then break end
local rawP2 = elapsed / (A.holdMax or 2.6)
_yv2SetBar(math.min(rawP2, SEMI_STOP))
if _yv2DistToAnimal(animalData) <= (tonumber(A.radius) or 10) then
if not alreadyInRange then task.wait(A.entryDelay or 0.25) end
if A.enabled and selectedStealMode == "V2" and CONFIG.AUTO_STEAL_ENABLED then
if #data.triggerCallbacks > 0 then
for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
else
pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
end
fired = true
end
break
end
task.wait()
end
A.state.lastResult = fired and ("Stole " .. tostring(A.state.label)) or "Missed"
A.state.active = false
A.state.phase = "idle"
A.state.lastResultTime = _tick()
if fired then _yv2SetBar(1) end
task.wait(A.cooldown or 0.05)
data.ready = true
_yv2ResetBar()
end)
return true
end
local function _yv2ScanAllPlots()
local A = _G.YoutV2Steal
if not _yv2EnsureSync() then return 0 end
local newCache = {}
for _, plot in ipairs(A.plots:GetChildren()) do
local cache = A.plotSync.caches[plot.Name]
local animalList = cache and cache.AnimalList
if typeof(animalList) == "table" then
for slot, animalData in pairs(animalList) do
if type(animalData) == "table" then
local animalName = animalData.Index
local info = A.animalsData and A.animalsData[animalName]
if info then
table.insert(newCache, {
name = info.DisplayName or animalName,
plot = plot.Name,
slot = tostring(slot),
uid = plot.Name .. "_" .. tostring(slot)
})
end
end
end
end
end
A.animals = newCache
return #newCache
end
local function _yv2PickClosest()
local A = _G.YoutV2Steal
local root = _yv2Root()
if not root then return nil end
local best, bestDist = nil, math.huge
for _, data in ipairs(A.animals) do
if not _yv2IsMyBase(data) then
local pos = _yv2AnimalPos(data)
local dist = pos and (root.Position - pos).Magnitude or math.huge
if dist <= (A.primeRange or 80) and dist < bestDist then
best, bestDist = data, dist
end
end
end
return best
end
local function _yv2EnsureScanThread()
local A = _G.YoutV2Steal
if A.scanThread then return end
A.scanThread = task.spawn(function()
while _G.YoutV2Steal do
if A.enabled or selectedStealMode == "V2" then pcall(_yv2ScanAllPlots) end
task.wait(5)
end
end)
end
function stopAutoStealV2()
local A = _G.YoutV2Steal
A.enabled = false
if A.conn then A.conn:Disconnect() A.conn = nil end
A.state.active = false
A.state.phase = "idle"
_yv2ResetBar()
end
function startAutoStealV2()
local A = _G.YoutV2Steal
A.radius = 10
A.enabled = true
pcall(_yv2EnsureSync)
_yv2EnsureScanThread()
pcall(_yv2ScanAllPlots)
if A.conn then A.conn:Disconnect() A.conn = nil end
A.conn = RunService.Heartbeat:Connect(function()
if not A.enabled or not CONFIG.AUTO_STEAL_ENABLED or selectedStealMode ~= "V2" or A.state.active then return end
local target = _yv2PickClosest()
if not target then
if _tick() - (A.lastScan or 0) > 1.2 then
A.lastScan = _tick()
pcall(_yv2ScanAllPlots)
end
return
end
local prompt = _yv2FindPrompt(target)
if prompt then _yv2Execute(prompt, target) end
end)
end
local function _startAutoStealV1()
if stealConnection then
local connected = false
pcall(function() connected = stealConnection.Connected == true end)
if connected then
Steal.StealRadius = CONFIG.STEAL_RANGE
Steal.AutoStealEnabled = true
return true
end
pcall(function() stealConnection:Disconnect() end)
stealConnection = nil
end
Steal.StealRadius = CONFIG.STEAL_RANGE
Steal.AutoStealEnabled = true
stealConnection = RunService.Heartbeat:Connect(function()
if not Steal.AutoStealEnabled or isStealing then return end
if selectedStealMode ~= "V1" then return end
local p, n = findNearestPrompt()
if p then executeSteal(p, n) end
end)
return true
end
local function _stopAutoStealV1()
if stealConnection then
stealConnection:Disconnect()
stealConnection = nil
end
isStealing = false
Steal.AutoStealEnabled = false
if progressFill then
TS:Create(progressFill, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 1, 0) }):Play()
end
if progressPct then progressPct.Text = "0%" end
end
function startAutoSteal()
if _G._youtGrabBillboardShow then pcall(_G._youtGrabBillboardShow) end
_stopAutoStealV1()
stopAutoStealV2()
CONFIG.AUTO_STEAL_ENABLED = true
if selectedStealMode == "V2" then
startAutoStealV2()
else
_startAutoStealV1()
end
if _G._NoxRagdollStealSync then task.defer(_G._NoxRagdollStealSync) end
return true
end
function stopAutoSteal()
if _G._youtGrabBillboardHide then pcall(_G._youtGrabBillboardHide) end
_stopAutoStealV1()
stopAutoStealV2()
CONFIG.AUTO_STEAL_ENABLED = false
if progressFill then
TS:Create(progressFill, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 1, 0) }):Play()
end
if progressPct then progressPct.Text = "0%" end
end

local _noxRagdollStealPaused = false
local _noxRagdollStealStateConn = nil
local function _noxIsRagdolled(humanoid)
    if not humanoid then return false end
    local state = humanoid:GetState()
    return state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
end
local function _noxSyncRagdollSteal()
    local char = LP and LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local shouldPause = ragdollStealEnabled == true
        and CONFIG.AUTO_STEAL_ENABLED == true
        and _noxIsRagdolled(humanoid)
    if shouldPause and not _noxRagdollStealPaused then
        _noxRagdollStealPaused = true
        if selectedStealMode == "V2" then
            stopAutoStealV2()
        else
            _stopAutoStealV1()
        end
    elseif not shouldPause and _noxRagdollStealPaused then
        _noxRagdollStealPaused = false
        if CONFIG.AUTO_STEAL_ENABLED == true then startAutoSteal() end
    end
end
_G._NoxRagdollStealSync = _noxSyncRagdollSteal
local function _noxBindRagdollSteal(character)
    if _noxRagdollStealStateConn then
        pcall(function() _noxRagdollStealStateConn:Disconnect() end)
        _noxRagdollStealStateConn = nil
    end
    local humanoid = character and (character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5))
    if not humanoid then return end
    _noxRagdollStealStateConn = humanoid.StateChanged:Connect(function()
        task.defer(_noxSyncRagdollSteal)
    end)
    task.defer(_noxSyncRagdollSteal)
end
function setRagdollStealEnabled(on)
    ragdollStealEnabled = on == true
    _noxSyncRagdollSteal()
    if saveAllSettings then pcall(saveAllSettings, true) end
    return ragdollStealEnabled
end
LP.CharacterAdded:Connect(function(character)
    task.delay(0.35, function() _noxBindRagdollSteal(character) end)
end)
if LP.Character then task.defer(function() _noxBindRagdollSteal(LP.Character) end) end
medusaDebounce = false
medusaLastUsed = 0
dropActive = false
lastDropTime = 0
lastMoveDir = _V3new(0,0,0)
origFOV = nil
fovEnabled = false
fovValue = 70
customFovConn = nil
_anyKeyListening = false
_aimbotConn = nil
_prevAutoRotate = nil
enemySpeedConn = nil
movementLoop = nil
steppedConn = nil
alConn = nil
arConn = nil
infJumpConn = nil
stretchConn = nil
stretchFovConn = nil
antiLagDescConn = nil
medusaResetConns = {}
dropConnections = {}
enemySpeedLabels = {}
Conns = {autoSteal = nil, batCounter = nil, anchor = {}, progress = nil, autoLeft = nil, autoRight = nil}
keyButtonRefs = {}
progressFill = nil
progressPct = nil
pbFrame = nil
speedLabel = nil
modeValLbl = nil
normalBox, carryBox, laggerBox, lagger2Box, radInput, batSpeedBox, uiScaleBox = nil, nil, nil, nil, nil, nil, nil
modeSelectBtn, dropModeBtnRef = nil, nil
autoBatSetVisual, autoLeftSetVisual, autoRightSetVisual, setBatCounterVisual, setMedusaVisual = nil, nil, nil, nil, nil
setAntiRagVisual, setAntiLagVisual, setLockUIVisual, setInstaGrab = nil, nil, nil, nil
setAntiDieVisual = nil
setWarningHighPingVisual = nil
warningHighPingEnabled = false
warningHighPingFrame = nil
buttonShapeMode = "Square"
setAntiFlingVisual = nil
setESPVIsual = nil
setESPLineVisual = nil
mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight, mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2 = nil, nil, nil, nil, nil, nil, nil, nil
miniBtn, main, gui = nil, nil, nil
MobilePanel = nil
instaResetFloatingButton = nil
showGui = nil
hideGui = nil
mainUIScale = nil
animSelectorLabel = nil
pbScale = nil
pbDeviceScale = 1
tabButtons = nil
colorSelectorLabel = nil
GAMEPAD_KEYS = {
[Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true,
[Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true,
[Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true,
[Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true,
[Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true,
[Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true,
[Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true,
[Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true,
}
MOVE_KEYS = {
[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
[Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
[Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
[Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
}
BAT_COUNTER_SLAP_LIST = {
"Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
"Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
"Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}
AP = {
L1 = _V3new(-476.48, -6.28, 92.73),
L2 = _V3new(-483.12, -4.95, 94.80),
L_FACE = _V3new(-482.25, -4.96, 92.09),
R1 = _V3new(-476.16, -6.52, 25.62),
R2 = _V3new(-483.06, -5.03, 25.48),
R_FACE = _V3new(-482.06, -6.93, 35.47),
}
function isGamepadInput(inp)
return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil
end
function isBindableInput(inp)
if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
end
function kbMatch(entry, input)
if not entry or not input then return false end
if typeof(input) == "EnumItem" then
return input == entry.kb or (entry.gp and input == entry.gp) or false
end
if not input.KeyCode then return false end
if input.UserInputType == Enum.UserInputType.Keyboard then
return input.KeyCode == entry.kb
end
if isGamepadInput(input) then
return input.KeyCode == entry.gp
end
return false
end
function resetProgressBar()
if progressPct then progressPct.Text = "0%" end
if setProgressFillSmooth then setProgressFillSmooth(UDim2.new(0, 0, 1, 0)) elseif progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
end
TP_DOWN_OFFSET = 0.1
_G._VynxTPDownMode = (_G._VynxTPDownMode == "half") and "half" or "full"
if _G._VynxAutoTPDownEnabled == nil then _G._VynxAutoTPDownEnabled = false end
_G._VynxAutoTPDownHeightTrigger = tonumber(_G._VynxAutoTPDownHeightTrigger) or 20
local function _tpIsCarryingBrainrot(char)
if not char then return false end
if LP:GetAttribute("Stealing") == true or char:GetAttribute("Stealing") == true then
return true
end
for _, child in ipairs(char:GetChildren()) do
if child:IsA("Tool") then
local n = child.Name:lower()
if not (n:find("bat") or n:find("slap")) then return true end
end
end
return false
end
local function _runTPDownHalf()
pcall(function()
local c = LP.Character
if not c then return end
local hrp = c:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local hum = c:FindFirstChildOfClass("Humanoid")
if not hum then return end
local rp = _RayParams_new()
rp.FilterDescendantsInstances = {c}
rp.FilterType = Enum.RaycastFilterType.Exclude
local hit = workspace:Raycast(hrp.Position, _V3new(0, -500, 0), rp)
if hit then
hrp.AssemblyLinearVelocity = _V3zero
hrp.AssemblyAngularVelocity = _V3zero
local hh = hum.HipHeight or 2
local hy = hrp.Size.Y / 2
hrp.CFrame = _CFnew(hit.Position.X, hit.Position.Y + hh + hy + (TP_DOWN_OFFSET or 0.1), hit.Position.Z)
hrp.AssemblyLinearVelocity = _V3zero
end
end)
end
local function _runTPDownFull()
pcall(function()
local c = LP.Character
if not c then return end
local hrp = c:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local _, yaw = hrp.CFrame:ToEulerAnglesYXZ()
hrp.CFrame = _CFnew(hrp.Position.X, -7.00, hrp.Position.Z) * CFrame.Angles(0, yaw, 0)
hrp.AssemblyLinearVelocity = _V3zero
end)
end
local function executeTPDown()
if dropActive or _G.IsDropping then return end
local char = LP.Character
if not char then return end
local hrp = char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 or hrp.Anchored or hum.Sit or hum.SeatPart then return end
if _G._VynxTPDownMode == "half" then
_runTPDownHalf()
else
_runTPDownFull()
end
end
function doTpDown()
executeTPDown()
end
local _tpAutoConn = RunService.Heartbeat:Connect(function()
if _G._VynxAutoTPDownEnabled ~= true then return end
local char = LP.Character
if not char then return end
if not _tpIsCarryingBrainrot(char) then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
local rp = _RayParams_new()
rp.FilterDescendantsInstances = {char}
rp.FilterType = Enum.RaycastFilterType.Exclude
local hit = workspace:Raycast(root.Position, _V3new(0, -2000, 0), rp)
if not hit then return end
local trigger = tonumber(_G._VynxAutoTPDownHeightTrigger) or 20
if root.Position.Y - hit.Position.Y > trigger then
executeTPDown()
end
end)
_G._VynxRunTPDown = executeTPDown
_G._VynxSetTPDownMode = function(m)
_G._VynxTPDownMode = (m == "half") and "half" or "full"
return _G._VynxTPDownMode
end
_G._VynxTPDownIsAutoOn = function() return _G._VynxAutoTPDownEnabled == true end
local _tpDownTick = executeTPDown
local _tpDownHoldConn = nil
local function startTpDownHold()
if _tpDownHoldConn then return end
_tpDownHoldConn = RunService.Heartbeat:Connect(function()
local entry = KB.TPFloor
if not entry then return end
local kc = entry.gp or entry.kb
if not kc then return end
if UIS:IsKeyDown(kc) then
pcall(_tpDownTick)
end
end)
end
startTpDownHold()
local AntiRagdollV2 = {
Enabled = false,
Connection = nil,
ResetCooldown = 0,
}
local function startAntiRagdollV2()
if AntiRagdollV2.Connection then return end
AntiRagdollV2.Enabled = true
AntiRagdollV2.Connection = RunService.Heartbeat:Connect(function()
if not AntiRagdollV2.Enabled then return end
local char = LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")
if not hum or not root or hum.Health <= 0 then return end
if dropActive or _G.IsDropping then return end
local state = hum:GetState()
local now = _tick()
if state == Enum.HumanoidStateType.Physics or
state == Enum.HumanoidStateType.Ragdoll or
state == Enum.HumanoidStateType.FallingDown then
if now - AntiRagdollV2.ResetCooldown > 0.15 then
AntiRagdollV2.ResetCooldown = now
pcall(function()
hum:ChangeState(Enum.HumanoidStateType.GettingUp)
root.Velocity = _V3zero
root.RotVelocity = _V3zero
root.AssemblyLinearVelocity = _V3zero
root.AssemblyAngularVelocity = _V3zero
for _, obj in ipairs(char:GetDescendants()) do
if obj:IsA("Motor6D") then obj.Enabled = true end
if obj:IsA("Constraint") then obj.Enabled = true end
end
workspace.CurrentCamera.CameraSubject = hum
local PM = LP.PlayerScripts:FindFirstChild("PlayerModule")
if PM then
local CM = require(PM:FindFirstChild("ControlModule"))
if CM then CM:Enable() end
end
hum.AutoRotate = true
hum.PlatformStand = false
hum.Sit = false
end)
end
end
end)
end
local function stopAntiRagdollV2()
AntiRagdollV2.Enabled = false
if AntiRagdollV2.Connection then
AntiRagdollV2.Connection:Disconnect()
AntiRagdollV2.Connection = nil
end
AntiRagdollV2.ResetCooldown = 0
end
LP.CharacterAdded:Connect(function()
task.wait(0.5)
if antiRagdollMode == "v2" then
if AntiRagdollV2.Connection then
AntiRagdollV2.Connection:Disconnect()
AntiRagdollV2.Connection = nil
end
startAntiRagdollV2()
end
end)
function setAntiRagdollMode(mode)
if mode == "v2" then
startAntiRagdollV2()
antiRagdollMode = "v2"
else
stopAntiRagdollV2()
antiRagdollMode = "off"
end
if setAntiRagVisual then setAntiRagVisual(antiRagdollMode == "v2") end
saveAllSettings(true)
end
_antiDieEnabled = false
_antiDieStopped = false
_antiDieSources = { toggle = false, autobat = false }
_antiDie = {
enabled = false, loop = nil, healthConn = nil, charConn = nil,
lastHealTime = 0, invincibleUntil = 0,
config = {
healthThreshold = 50,
invincibilityFrames = 0.75,
fallDamageProtection = false,
ragdollProtection = true,
autoRevive = true,
},
}
function _antiDie.SuperHeal(hum)
if not hum or not hum.Parent then return end
local maxHealth = hum.MaxHealth or 100
if maxHealth <= 0 or maxHealth == math.huge then maxHealth = 100 end
pcall(function()
hum.Health = maxHealth
if hum.MaxHealth < maxHealth then hum.MaxHealth = maxHealth end
end)
_antiDie.invincibleUntil = _tick() + _antiDie.config.invincibilityFrames
_antiDie.lastHealTime = _tick()
pcall(function()
local char = hum.Parent
if not char then return end
for _, child in ipairs(char:GetChildren()) do
if child:IsA("NumberValue") then
local name = child.Name:lower()
if name:find("health") or name:find("hp") or name:find("life") then
child.Value = maxHealth
end
end
if child:IsA("BoolValue") and child.Name:lower():find("dead") then
child.Value = false
end
end
end)
end
function _antiDie.PreventDamage(root, hum)
if not hum then return end
if hum.Health < (hum.MaxHealth or 100) then _antiDie.SuperHeal(hum) end
if _tick() < _antiDie.invincibleUntil then
if hum.Health < (hum.MaxHealth or 100) then
hum.Health = hum.MaxHealth or 100
end
end
if _antiDie.config.ragdollProtection then
local state = hum:GetState()
if state == Enum.HumanoidStateType.Physics or
state == Enum.HumanoidStateType.Ragdoll or
state == Enum.HumanoidStateType.FallingDown or
state == Enum.HumanoidStateType.Dead then
pcall(function()
hum:ChangeState(Enum.HumanoidStateType.GettingUp)
hum:ChangeState(Enum.HumanoidStateType.Running)
end)
_antiDie.SuperHeal(hum)
if root then
pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
end
end
end
if hum.Health <= 0 then
_antiDie.SuperHeal(hum)
pcall(function()
hum:ChangeState(Enum.HumanoidStateType.GettingUp)
hum:ChangeState(Enum.HumanoidStateType.Running)
end)
if root then
pcall(function()
root.CFrame = CFrame.new(root.Position + Vector3.new(0, 2, 0))
root.AssemblyLinearVelocity = Vector3.zero
end)
end
end
end
function _antiDie.AutoRevive()
if not _antiDie.config.autoRevive then return end
local char = LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")
if not hum then return end
if hum.Health <= 0 then
_antiDie.SuperHeal(hum)
pcall(function()
hum:ChangeState(Enum.HumanoidStateType.GettingUp)
hum:ChangeState(Enum.HumanoidStateType.Running)
end)
if root then
pcall(function()
root.CFrame = CFrame.new(root.Position + Vector3.new(0, 3, 0))
root.AssemblyLinearVelocity = Vector3.zero
end)
end
end
end
function _antiDie.AttachHealth(char)
if _antiDie.healthConn then _antiDie.healthConn:Disconnect(); _antiDie.healthConn = nil end
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum then hum = char and char:WaitForChild("Humanoid", 3) end
if not hum then return end
_antiDie.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
if not _antiDie.enabled then return end
if hum.Health < (hum.MaxHealth or 100) then _antiDie.SuperHeal(hum) end
if hum.Health <= 0 then _antiDie.AutoRevive() end
end)
if hum.Health < (hum.MaxHealth or 100) then _antiDie.SuperHeal(hum) end
end
function _antiDie.StartEngine()
if _antiDie.enabled and _antiDie.loop then return end
_antiDie.enabled = true
_antiDieEnabled = true
antiDieEnabled = true
if _antiDie.loop then _antiDie.loop:Disconnect(); _antiDie.loop = nil end
if _antiDie.healthConn then _antiDie.healthConn:Disconnect(); _antiDie.healthConn = nil end
_antiDie.loop = RunService.Heartbeat:Connect(function()
if not _antiDie.enabled then return end
local char = LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")
if not hum then return end
if hum.Health <= 0 then _antiDie.AutoRevive()
elseif hum.Health <= _antiDie.config.healthThreshold then _antiDie.SuperHeal(hum)
elseif hum.Health < (hum.MaxHealth or 100) then _antiDie.SuperHeal(hum) end
_antiDie.PreventDamage(root, hum)
end)
if LP.Character then _antiDie.AttachHealth(LP.Character) end
if _antiDie.charConn then _antiDie.charConn:Disconnect(); _antiDie.charConn = nil end
_antiDie.charConn = LP.CharacterAdded:Connect(function(char)
if not _antiDie.enabled then return end
task.wait(0.05)
_antiDie.AttachHealth(char)
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then _antiDie.SuperHeal(hum) end
end)
end
function _antiDie.StopEngine()
_antiDie.enabled = false
_antiDieEnabled = false
antiDieEnabled = false
if _antiDie.loop then _antiDie.loop:Disconnect(); _antiDie.loop = nil end
if _antiDie.healthConn then _antiDie.healthConn:Disconnect(); _antiDie.healthConn = nil end
if _antiDie.charConn then _antiDie.charConn:Disconnect(); _antiDie.charConn = nil end
pcall(function()
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum then return end
hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
hum.BreakJointsOnDeath = true
if hum.MaxHealth == math.huge or hum.MaxHealth <= 0 then
hum.MaxHealth = 100
hum.Health = math.min(hum.Health, 100)
end
end)
end
function _antiDieSetEnabled(enabled)
enabled = enabled == true
if enabled == _antiDieEnabled then return end
if enabled then
_antiDie.StartEngine()
else
_antiDie.StopEngine()
end
end
function _antiDieRefresh()
if _antiDieStopped then return end
local manual = _antiDieSources.toggle
_antiDieSetEnabled(manual or _antiDieSources.autobat)
end
_G.__CrystalAntiDieSource = function(source, enabled)
if _antiDieStopped or _antiDieSources[source] == nil then return end
_antiDieSources[source] = enabled == true
_antiDieRefresh()
end
_G.__CrystalAntiDieSet = function(enabled)
_G.__CrystalAntiDieSource("autobat", enabled)
end
_G.__CrystalAntiDieIsEnabled = function() return _antiDieEnabled end
_G.__CrystalAntiDieStop = function()
_antiDieStopped = true
_antiDieSources.toggle = false
_antiDieSources.autobat = false
_antiDieSetEnabled(false)
end
function activateOnCharacter(char)
if not _antiDieEnabled then return end
_antiDie.AttachHealth(char)
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then _antiDie.SuperHeal(hum) end
end
AntiDieModule = {
enabled = false,
start = function()
AntiDieModule.enabled = true
antiDieEnabled = true
_antiDieStopped = false
_G.__CrystalAntiDieSource("toggle", true)
end,
stop = function()
AntiDieModule.enabled = false
antiDieEnabled = false
_G.__CrystalAntiDieSource("toggle", false)
end,
}
_G.AntiDie = AntiDieModule
local AntiBat = { Connection = nil }
function stopAntiBat()
antiBatEnabled = false
if AntiBat.Connection then
AntiBat.Connection:Disconnect()
AntiBat.Connection = nil
end
end
function startAntiBat()
stopAntiBat()
antiBatEnabled = true
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
AntiBat.Connection = RunService.Heartbeat:Connect(function()
if not antiBatEnabled then return end
if not root or not root.Parent then
root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not root then return end
end
local vel = root.AssemblyLinearVelocity
local flat = Vector3.new(vel.X, 0, vel.Z)
root.AssemblyLinearVelocity = Vector3.new(500, vel.Y, 500)
RunService.RenderStepped:Wait()
if root and root.Parent then
local y2 = root.AssemblyLinearVelocity.Y
root.AssemblyLinearVelocity = Vector3.new(flat.X, y2, flat.Z)
end
end)
end
LP.CharacterAdded:Connect(function()
task.wait(0.3)
if antiBatEnabled then startAntiBat() end
end)
setAntiFlingVisual = nil
local _antiFlingState = {
connection = nil,
threshold = 80,
spinThreshold = 40,
}
local _ANTI_FLING_DRIVE_GRACE = 0.3
local function _afHubSpeedLive()
local live = _G.__YoutLiveSpeed
if type(live) ~= "table" then return false end
local stamp, speed = tonumber(live.t), tonumber(live.v)
if not stamp or not speed or speed <= 0 then return false end
return (os.clock() - stamp) <= _ANTI_FLING_DRIVE_GRACE
end
local function _afOwnMoverActive()
if autoBatEnabled then return true end
if autoLeftEnabled or autoRightEnabled then return true end
return false
end
function startAntiFling()
if _antiFlingState.connection then return end
antiFlingEnabled = true
_antiFlingState.connection = RunService.Heartbeat:Connect(function()
if not antiFlingEnabled then return end
local character = LP.Character
if not character then return end
local root = character:FindFirstChild("HumanoidRootPart")
if not root then return end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid and (humanoid.Health <= 0 or humanoid.SeatPart) then return end
if dropActive or _G.IsDropping then return end
if _afOwnMoverActive() then return end
if _afHubSpeedLive() then return end
local velocity = root.AssemblyLinearVelocity
local flat = Vector3.new(velocity.X, 0, velocity.Z)
if flat.Magnitude > _antiFlingState.threshold then
pcall(function()
root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
root.AssemblyAngularVelocity = Vector3.zero
end)
return
end
if root.AssemblyAngularVelocity.Magnitude > _antiFlingState.spinThreshold then
pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
end
end)
end
function stopAntiFling()
antiFlingEnabled = false
if _antiFlingState.connection then
_antiFlingState.connection:Disconnect()
_antiFlingState.connection = nil
end
end
LP.CharacterAdded:Connect(function()
task.wait(0.3)
if antiFlingEnabled then startAntiFling() end
end)
local espEnabled = espEnabled or false
local espActivePlayers = {}
local espLoopConn = nil
local Camera = workspace.CurrentCamera
local GUI2_ESP_COLOR = Color3.fromRGB(139, 72, 246)
local GUI2_ESP_TEXT_STROKE = Color3.fromRGB(48, 16, 92)
local function getESPThemeColors(accent)
local c = getThemeColor() or accent or Color3.fromRGB(245, 245, 250)
return c, Color3.fromRGB(0, 0, 0)
end
local function createESP() end

function toggleESP() end

function stopESPLine() end

function startESPLine() end

function updateEnemySpeedLabels()
_enemySpeedAcc = _enemySpeedAcc + 1
if _enemySpeedAcc < 6 then return end
_enemySpeedAcc = 0
local color = getThemeColor()
local players = _GetPlayersCached()
for i = 1, #players do
local player = players[i]
if player ~= LP then
local char = player.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hrp and hum and hum.Health > 0 then
local v = hrp.AssemblyLinearVelocity
local speed = _sqrt(v.X*v.X + v.Z*v.Z)
local label = enemySpeedLabels[player]
if not label then
local head = char:FindFirstChild("Head")
if head then
local bb = Instance.new("BillboardGui")
bb.Size = UDim2.new(0, 100, 0, 25)
bb.StudsOffset = _V3new(0, 5.5, 0)
bb.AlwaysOnTop = true
bb.Name = "EnemySpeedGui"
bb.Parent = head
local tl = Instance.new("TextLabel", bb)
tl.Size = UDim2.new(1, 0, 1, 0)
tl.BackgroundTransparency = 1
tl.TextColor3 = color
tl.Font = Enum.Font.GothamBold
tl.TextScaled = true
tl.TextStrokeTransparency = 0
tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
enemySpeedLabels[player] = tl
label = tl
end
elseif label.Parent and label.Parent.Parent ~= char then
local head = char:FindFirstChild("Head")
if head then label.Parent.Parent = head end
end
if label then
label.Text = string.format("%.1f", speed)
if label.TextColor3 ~= color then label.TextColor3 = color end
end
else
local label = enemySpeedLabels[player]
if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
enemySpeedLabels[player] = nil
end
end
end
end
function startEnemySpeed()
if enemySpeedConn then enemySpeedConn:Disconnect() end
enemySpeedConn = RunService.Heartbeat:Connect(updateEnemySpeedLabels)
end
function stopEnemySpeed()
if enemySpeedConn then enemySpeedConn:Disconnect(); enemySpeedConn = nil end
end
local function getClosestTargetBody()
local char = LP.Character
if not char then return nil end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return nil end
local rpos = root.Position
local closest, minDist = nil, _huge
local plist = _GetPlayersCached()
for i = 1, #plist do
local plr = plist[i]
if plr ~= LP then
local c = plr.Character
if c then
local tRoot = c:FindFirstChild("HumanoidRootPart")
if tRoot then
local hum = c:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 then
local dx = tRoot.Position.X - rpos.X
local dy = tRoot.Position.Y - rpos.Y
local dz = tRoot.Position.Z - rpos.Z
local d = dx*dx + dy*dy + dz*dz
if d < minDist then minDist = d; closest = tRoot end
end
end
end
end
end
return closest
end
local function _bodyLockTick()
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then return end
local target = getClosestTargetBody()
if not target then
if not hum.AutoRotate then hum.AutoRotate = true end
return
end
local dist = (target.Position - root.Position).Magnitude
if dist > bodyLockRange then
if not hum.AutoRotate then hum.AutoRotate = true end
return
end
if hum.AutoRotate then hum.AutoRotate = false end
local targetVel = target.AssemblyLinearVelocity
local speed3 = targetVel.Magnitude
local predictTime = _clamp(speed3 / 80, 0.08, 0.35)
local predictedPos = target.Position + targetVel * predictTime
local targetHead = target.Parent and target.Parent:FindFirstChild("Head")
local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y
local myHeight = root.Position.Y + (hum.HipHeight or 0)
local heightDiff = targetHeight - myHeight
local verticalCorrection = _clamp(heightDiff * 0.15, -1.5, 1.5)
local flatTarget = _V3new(predictedPos.X, root.Position.Y + verticalCorrection, predictedPos.Z)
local toPredict = flatTarget - root.Position
if toPredict.Magnitude > 0.1 then
local goalCF = _CFlookAt(root.Position, flatTarget)
local diffCF = root.CFrame:Inverse() * goalCF
local _, ry, _ = diffCF:ToEulerAnglesXYZ()
ry = _clamp(ry, -2.5, 2.5)
root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(_V3new(0, ry * 42, 0))
end
end
function startBodyLock()
if _bodyLockConn then _bodyLockConn:Disconnect() end
local acc = 0
_bodyLockConn = RunService.Heartbeat:Connect(function(dt)
if not bodyLockEnabled then return end
if _blSuppressCount > 0 then return end
acc = acc + dt
if acc < 0.033 then return end
acc = 0
_bodyLockTick()
end)
end
function stopBodyLock()
if _bodyLockConn then
_bodyLockConn:Disconnect()
_bodyLockConn = nil
end
local c = LP.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if root then
root.AssemblyAngularVelocity = _V3zero
root.AssemblyLinearVelocity = _V3new(root.AssemblyLinearVelocity.X, -0.1, root.AssemblyLinearVelocity.Z)
end
local hum2 = c and c:FindFirstChildOfClass("Humanoid")
if hum2 then hum2.AutoRotate = true end
end
function _suppressBodyLock()
_blSuppressCount = _blSuppressCount + 1
if _blSuppressCount == 1 and bodyLockEnabled then
_blWasEnabled = true
stopBodyLock()
if bodyLockSetVisual then bodyLockSetVisual(false) end
if _blRestoreTimer then
task.cancel(_blRestoreTimer)
_blRestoreTimer = nil
end
_blSmoothRestore = false
end
end
function _unsuppressBodyLock(delayed)
if _blSuppressCount > 0 then
_blSuppressCount = _blSuppressCount - 1
end
if _blSuppressCount == 0 and _blWasEnabled then
_blWasEnabled = false
if _blRestoreTimer then
pcall(task.cancel, _blRestoreTimer)
_blRestoreTimer = nil
end
local function restore()
_blRestoreTimer = nil
if bodyLockEnabled then
_blSmoothRestore = true
startBodyLock()
if bodyLockSetVisual then bodyLockSetVisual(true) end
task.delay(0.5, function() _blSmoothRestore = false end)
end
end
if delayed then
_blRestoreTimer = task.delay(1, restore)
else
restore()
end
end
end
function setupSpeedIndicator(char)
local head = char:WaitForChild("Head", 5)
if not head then return end
local oldBB = head:FindFirstChild("YoutSpeedIndicator")
if oldBB then oldBB:Destroy() end
local bb = Instance.new("BillboardGui", head)
bb.Name = "YoutSpeedIndicator"
bb.Size = UDim2.fromOffset(200, 34)
bb.StudsOffset = Vector3.new(0, 3.2, 0)
bb.AlwaysOnTop = true
bb.LightInfluence = 0
bb.MaxDistance = 0
speedLabel = Instance.new("TextLabel", bb)
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "0.0  -  " .. getSpeedModeName()
speedLabel.TextColor3 = getThemeColor()
speedLabel.Font = Enum.Font.GothamBlack
speedLabel.TextSize = 22
speedLabel.TextXAlignment = Enum.TextXAlignment.Center
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.TextStrokeTransparency = 0
speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
local slStroke = Instance.new("UIStroke", speedLabel)
slStroke.Color = Color3.fromRGB(0, 0, 0)
slStroke.Thickness = 1.5
slStroke.Transparency = 0.2
applyShimmerToText(speedLabel, 0.9)
end
function refreshSpeedModeLabel()
if modeValLbl then
if laggerCarryToggled then modeValLbl.Text = "Lagger Carry"
elseif laggerToggled then modeValLbl.Text = "Lagger Normal"
elseif speedMode then modeValLbl.Text = "Carry"
else modeValLbl.Text = "Normal" end
end
if setCarryModeVisual then setCarryModeVisual(speedMode) end
if setLaggerModeVisual then setLaggerModeVisual(laggerToggled) end
if setLaggerCarryVisual then setLaggerCarryVisual(laggerCarryToggled) end
end
function resetMovementState()
refreshSpeedModeLabel()
if mobSetCarry then mobSetCarry(speedMode) end
if setLaggerModeVisual then setLaggerModeVisual(laggerToggled) end
if setLaggerCarryVisual then setLaggerCarryVisual(laggerCarryToggled) end
end
function toggleCarryMode()
if laggerToggled or laggerCarryToggled then
laggerToggled = false; laggerCarryToggled = false; speedMode = true
else speedMode = not speedMode end
resetMovementState()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
pcall(saveAllSettings, true)
end
function toggleLaggerMode()
if laggerCarryToggled then laggerCarryToggled = false end
speedMode = false; laggerToggled = not laggerToggled
resetMovementState()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
pcall(saveAllSettings, true)
end
function toggleLaggerCarryMode()
if laggerToggled then laggerToggled = false end
speedMode = false; laggerCarryToggled = not laggerCarryToggled
resetMovementState()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
pcall(saveAllSettings, true)
end
function toggleLaggerCycle()
if speedMode then
speedMode = false
laggerToggled = true
laggerCarryToggled = false
elseif laggerToggled then
speedMode = false
laggerToggled = false
laggerCarryToggled = true
else
speedMode = true
laggerToggled = false
laggerCarryToggled = false
end
resetMovementState()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
pcall(saveAllSettings, true)
end
-- ============================================================
-- AUTO BRAINROT SPEED
-- Walking = NS (normal). Holding brainrot = CS (carry). Automatic.
-- ============================================================
local autoBrainrotSpeedEnabled = false
local autoBrainrotSpeedSetVisual = nil
local _absConn = nil
local _absForced = false          -- true while we forced carry speed
local _absUserWantedCarry = false -- user's manual carry toggle before we forced

local function _isHoldingBrainrot()
    local char = LP and LP.Character
    if not char then return false end

    -- attributes
    local ok, res = pcall(function() return LP:GetAttribute("Stealing") end)
    if ok and res == true then return true end
    ok, res = pcall(function() return char:GetAttribute("Stealing") end)
    if ok and res == true then return true end
    for attrName, attrValue in pairs(char:GetAttributes()) do
        local n = string.lower(tostring(attrName))
        if attrValue == true and (
            n:find("carrying", 1, true) or n:find("stealing", 1, true)
            or n:find("isstealing", 1, true) or n:find("hasbrainrot", 1, true)
            or n:find("brainrot", 1, true)
        ) then
            return true
        end
    end

    -- child name markers (brainrot / animal / carry)
    for _, child in ipairs(char:GetChildren()) do
        local n = string.lower(child.Name)
        if n:find("brainrot", 1, true) or n:find("brain", 1, true)
            or n:find("animal", 1, true) or n:find("carry", 1, true)
            or n:find("stolen", 1, true) or n:find("held", 1, true)
            or n:find("steal", 1, true) then
            return true
        end
    end

    -- walkspeed heuristic used by this game when carrying
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local ws = tonumber(hum.WalkSpeed)
        if ws and ws > 0 and ws < 25 and ws ~= 16 then
            return true
        end
    end
    return false
end

-- expose for Auto Spin
_G.__NoxIsCarryingAnimal = _isHoldingBrainrot

local function _absApplyCarry()
    -- force carry speed, remember if user already had carry on
    if not _absForced then
        _absUserWantedCarry = (speedMode == true)
        _absForced = true
    end
    if not speedMode then
        speedMode = true
        laggerToggled = false
        laggerCarryToggled = false
        if resetMovementState then pcall(resetMovementState) end
        if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
        if refreshSpeedModeLabel then pcall(refreshSpeedModeLabel) end
        if setCarryModeVisual then pcall(setCarryModeVisual, true) end
    end
end

local function _absApplyNormal()
    if not _absForced then return end
    _absForced = false
    -- restore only if user did not manually want carry
    if not _absUserWantedCarry then
        speedMode = false
        if resetMovementState then pcall(resetMovementState) end
        if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
        if refreshSpeedModeLabel then pcall(refreshSpeedModeLabel) end
        if setCarryModeVisual then pcall(setCarryModeVisual, false) end
    end
    _absUserWantedCarry = false
end

local function _absTick()
    if not autoBrainrotSpeedEnabled then return end
    -- don't fight lagger modes
    if laggerToggled or laggerCarryToggled then return end
    if _isHoldingBrainrot() then
        _absApplyCarry()
    else
        _absApplyNormal()
    end
end

function stopAutoBrainrotSpeed(preserve)
    if preserve ~= true then autoBrainrotSpeedEnabled = false end
    if _absConn then pcall(function() _absConn:Disconnect() end); _absConn = nil end
    _absApplyNormal()
    if preserve ~= true and autoBrainrotSpeedSetVisual then
        pcall(function() autoBrainrotSpeedSetVisual(false) end)
    end
end

function setAutoBrainrotSpeedEnabled(on)
    autoBrainrotSpeedEnabled = on == true
    if autoBrainrotSpeedSetVisual then
        pcall(function() autoBrainrotSpeedSetVisual(autoBrainrotSpeedEnabled) end)
    end
    if not autoBrainrotSpeedEnabled then
        stopAutoBrainrotSpeed(false)
        if saveAllSettings then pcall(saveAllSettings, true) end
        return false
    end
    if not _absConn then
        local nextT = 0
        _absConn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if now < nextT then return end
            nextT = now + 0.06
            _absTick()
        end)
    end
    _absTick()
    if saveAllSettings then pcall(saveAllSettings, true) end
    print("[UNO] Auto Brainrot Speed", autoBrainrotSpeedEnabled and "ON" or "OFF")
    return true
end

-- legacy aliases so old calls don't error
function stopAutoCarry(preserveEnabled)
    stopAutoBrainrotSpeed(preserveEnabled)
end
function setAutoCarryEnabled(on)
    return setAutoBrainrotSpeedEnabled(on)
end
function setAutoCarryMode(mode)
    return true
end
autoCarryEnabled = false -- kept as alias mirror
autoCarrySetVisual = nil
autoCarryModeLabel = nil

function stopAutoLeft()
if alConn then alConn:Disconnect(); alConn = nil end
alPhase = 1
local char = LP.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum:Move(_V3zero, false) end
end
if autoLeftSetVisual then autoLeftSetVisual(false) end
if mobSetAutoLeft then mobSetAutoLeft(false) end
_unsuppressBodyLock(true)
end
function startAutoLeft()
if autoRightEnabled then
autoRightEnabled = false
stopAutoRight()
if autoRightSetVisual then autoRightSetVisual(false) end
if mobSetAutoRight then mobSetAutoRight(false) end
end
disableAllAimbots()
_suppressBodyLock()
if alConn then alConn:Disconnect() end
alPhase = 1
alConn = RunService.Heartbeat:Connect(function()
if not autoLeftEnabled then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
local hum = char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
local spd = NS
if alPhase == 1 then
local tgt = _V3new(AP.L1.X, root.Position.Y, AP.L1.Z)
if (tgt - root.Position).Magnitude < 1 then
alPhase = 2
local d = AP.L2 - root.Position
local mv = _V3new(d.X, 0, d.Z).Unit
hum:Move(mv, false)
root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
return
end
local d = AP.L1 - root.Position
local mv = _V3new(d.X, 0, d.Z).Unit
hum:Move(mv, false)
root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
elseif alPhase == 2 then
local tgt = _V3new(AP.L2.X, root.Position.Y, AP.L2.Z)
if (tgt - root.Position).Magnitude < 1 then
hum:Move(_V3zero, false)
root.AssemblyLinearVelocity = _V3zero
autoLeftEnabled = false
if alConn then alConn:Disconnect(); alConn = nil end
alPhase = 1
if autoLeftSetVisual then autoLeftSetVisual(false) end
if mobSetAutoLeft then mobSetAutoLeft(false) end
_unsuppressBodyLock(true)
local facePos = _V3new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z)
if (facePos - root.Position).Magnitude > 0.01 then
root.CFrame = _CFnew(root.Position, facePos)
end
return
end
local d = AP.L2 - root.Position
local mv = _V3new(d.X, 0, d.Z).Unit
hum:Move(mv, false)
root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
end
end)
end
function stopAutoRight()
if arConn then arConn:Disconnect(); arConn = nil end
arPhase = 1
local char = LP.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum:Move(_V3zero, false) end
end
if autoRightSetVisual then autoRightSetVisual(false) end
if mobSetAutoRight then mobSetAutoRight(false) end
_unsuppressBodyLock(true)
end
function startAutoRight()
if autoLeftEnabled then
autoLeftEnabled = false
stopAutoLeft()
if autoLeftSetVisual then autoLeftSetVisual(false) end
if mobSetAutoLeft then mobSetAutoLeft(false) end
end
disableAllAimbots()
_suppressBodyLock()
if arConn then arConn:Disconnect() end
arPhase = 1
arConn = RunService.Heartbeat:Connect(function()
if not autoRightEnabled then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
local hum = char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
local spd = NS
if arPhase == 1 then
local tgt = _V3new(AP.R1.X, root.Position.Y, AP.R1.Z)
if (tgt - root.Position).Magnitude < 1 then
arPhase = 2
local d = AP.R2 - root.Position
local mv = _V3new(d.X, 0, d.Z).Unit
hum:Move(mv, false)
root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
return
end
local d = AP.R1 - root.Position
local mv = _V3new(d.X, 0, d.Z).Unit
hum:Move(mv, false)
root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
elseif arPhase == 2 then
local tgt = _V3new(AP.R2.X, root.Position.Y, AP.R2.Z)
if (tgt - root.Position).Magnitude < 1 then
hum:Move(_V3zero, false)
root.AssemblyLinearVelocity = _V3zero
autoRightEnabled = false
if arConn then arConn:Disconnect(); arConn = nil end
arPhase = 1
if autoRightSetVisual then autoRightSetVisual(false) end
if mobSetAutoRight then mobSetAutoRight(false) end
_unsuppressBodyLock(true)
local facePos = _V3new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z)
if (facePos - root.Position).Magnitude > 0.01 then
root.CFrame = _CFnew(root.Position, facePos)
end
return
end
local d = AP.R2 - root.Position
local mv = _V3new(d.X, 0, d.Z).Unit
hum:Move(mv, false)
root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
end
end)
end
function getClosestTarget()
local char = LP.Character
if not char then return nil end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return nil end
local rpos = root.Position
local closest, minDist = nil, _huge
local plist = _GetPlayersCached()
for i = 1, #plist do
local plr = plist[i]
if plr ~= LP then
local c = plr.Character
if c then
local tRoot = c:FindFirstChild("HumanoidRootPart")
if tRoot then
local hum = c:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 then
local dx = tRoot.Position.X - rpos.X
local dy = tRoot.Position.Y - rpos.Y
local dz = tRoot.Position.Z - rpos.Z
local d = dx*dx + dy*dy + dz*dz
if d < minDist then minDist = d; closest = tRoot end
end
end
end
end
end
return closest
end
function trySwing()
pcall(function()
local char = LP.Character
if not char then return end
local currentTool = char:FindFirstChildOfClass("Tool")
if currentTool and not isBatTool(currentTool) then return end
local bat = findBat()
if bat then
if bat.Parent ~= char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then pcall(function() hum:EquipTool(bat) end) end
end
pcall(function() bat:Activate() end)
end
end)
end

-- ============================================================
-- AIMBOT V2 (Clover NewBatAimbot — velocity history / anti-spoof)
-- ============================================================
local BatAimbotState = { enabled = false, hittingCooldown = false }
local BAT_AIMBOT_CONFIG = {
    chaseSpeed = 58,
    aimHeight = 3.7,
    yBoost = 19.5,
    yVelY = 0.8,
    minJumpY = 13,
    yClamp = Vector2.new(-70, 110),
    lerpAlpha = 0.8,
    predictLead = 0.14,
    lookAheadOffset = 0.3,
    tiltSpeed = 42,
    swingCooldown = 0.08,
    velTrackClamp = 150,
    velSpoofMag = 250,
    velSpoofDiffBase = 80,
    velTrackSamples = 6,
    velSmooth = 0.5,
}
local BatVTrack = { records = {} }
local batAimbotConnV2 = nil

local function _noxBatFindBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("bat") or n:find("slap") then return tool end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("bat") or n:find("slap") then return tool end
            end
        end
    end
    return nil
end

local function _noxBatGetClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local d = (tRoot.Position - root.Position).Magnitude
                if d < minDist then minDist = d; closest = tRoot end
            end
        end
    end
    return closest
end

local function _noxBatGetTrueVelocity(root, now)
    if not root or not root.Parent then return Vector3.zero end
    local rec = BatVTrack.records[root]
    if not rec then
        rec = { s = {}, vel = Vector3.zero, ready = false }
        BatVTrack.records[root] = rec
    end
    local pos = root.Position
    local last = rec.s[#rec.s]
    if last then
        local dt = now - last.t
        if dt > 1/240 and dt < 0.2 then
            local raw = (pos - last.pos) / dt
            local c = BAT_AIMBOT_CONFIG.velTrackClamp
            local clamped = Vector3.new(
                math.clamp(raw.X, -c, c),
                math.clamp(raw.Y, -c, c),
                math.clamp(raw.Z, -c, c)
            )
            if rec.ready then
                rec.vel = rec.vel:Lerp(clamped, BAT_AIMBOT_CONFIG.velSmooth)
            else
                rec.vel = clamped
                rec.ready = true
            end
        end
    end
    table.insert(rec.s, { pos = pos, t = now })
    while #rec.s > BAT_AIMBOT_CONFIG.velTrackSamples do table.remove(rec.s, 1) end
    return rec.vel
end

local function _noxBatReadVelocity(target, now)
    local raw = target.AssemblyLinearVelocity
    local tracked = _noxBatGetTrueVelocity(target, now)
    if not tracked or tracked.Magnitude < 0.5 then
        if raw.Magnitude > 400 then return Vector3.zero end
        return raw
    end
    local diff = (raw - tracked).Magnitude
    local rawMag, trackMag = raw.Magnitude, tracked.Magnitude
    if rawMag > BAT_AIMBOT_CONFIG.velSpoofMag then return tracked end
    if diff > math.max(BAT_AIMBOT_CONFIG.velSpoofDiffBase, trackMag * 1.5) then return tracked end
    return raw
end

local _batVtLastClean = 0
local function _noxBatVTrackCleanup(now)
    if now - _batVtLastClean < 5 then return end
    _batVtLastClean = now
    for r in pairs(BatVTrack.records) do
        if not r.Parent then BatVTrack.records[r] = nil end
    end
end

local function _noxBatSwingBat()
    if BatAimbotState.hittingCooldown then return end
    BatAimbotState.hittingCooldown = true
    pcall(function()
        local c = LP.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local tool = _noxBatFindBat()
        if tool then
            if tool.Parent ~= c and hum then pcall(function() hum:EquipTool(tool) end) end
            local remote = tool:FindFirstChildOfClass("RemoteEvent")
            if remote then pcall(function() remote:FireServer() end)
            else pcall(function() tool:Activate() end) end
        end
    end)
    task.delay(BAT_AIMBOT_CONFIG.swingCooldown, function() BatAimbotState.hittingCooldown = false end)
end

local function startAimbotV2()
    if batAimbotConnV2 then batAimbotConnV2:Disconnect() end
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
        hum0.AutoRotate = false
    end
    if type(_suppressBodyLock) == "function" then pcall(_suppressBodyLock) end
    BatAimbotState.enabled = true
    batAimbotConnV2 = RunService.RenderStepped:Connect(function()
        if not BatAimbotState.enabled or not autoBatEnabled then return end
        if tostring(selectedAimbotMode or "v1"):lower() ~= "v2" then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local bat = _noxBatFindBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target = _noxBatGetClosestTarget()
        if not target then return end
        local now = os.clock()
        _noxBatVTrackCleanup(now)
        BAT_AIMBOT_CONFIG.chaseSpeed = getAimbotChaseSpeed()
        local targetVel = _noxBatReadVelocity(target, now)
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * BAT_AIMBOT_CONFIG.predictLead
        predictPos = predictPos + target.CFrame.LookVector * BAT_AIMBOT_CONFIG.lookAheadOffset
        local direction = predictPos - myPos
        local flat = Vector3.new(direction.X, 0, direction.Z)
        if flat.Magnitude < 0.001 then return end
        local flatDir = flat.Unit
        local desiredHeight = targetPos.Y + BAT_AIMBOT_CONFIG.aimHeight
        local yVel = (desiredHeight - myPos.Y) * BAT_AIMBOT_CONFIG.yBoost + targetVel.Y * BAT_AIMBOT_CONFIG.yVelY
        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, BAT_AIMBOT_CONFIG.minJumpY)
        end
        yVel = math.clamp(yVel, BAT_AIMBOT_CONFIG.yClamp.X, BAT_AIMBOT_CONFIG.yClamp.Y)
        local spd = BAT_AIMBOT_CONFIG.chaseSpeed
        local desiredVel = Vector3.new(flatDir.X * spd, yVel, flatDir.Z * spd)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, BAT_AIMBOT_CONFIG.lerpAlpha)
        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local curCF = root.CFrame
            local diffCF = curCF:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(
                Vector3.new(rx * BAT_AIMBOT_CONFIG.tiltSpeed, ry * BAT_AIMBOT_CONFIG.tiltSpeed, rz * BAT_AIMBOT_CONFIG.tiltSpeed)
            )
        end
        if (targetPos - myPos).Magnitude < 14 then
            _noxBatSwingBat()
        end
    end)
end

local function stopAimbotV2()
    BatAimbotState.enabled = false
    if batAimbotConnV2 then batAimbotConnV2:Disconnect(); batAimbotConnV2 = nil end
    BatVTrack.records = {}
    BatAimbotState.hittingCooldown = false
end

_G.NoxAimbotV2 = {
    start = startAimbotV2,
    stop = stopAimbotV2,
    state = BatAimbotState,
    config = BAT_AIMBOT_CONFIG,
}

function stopAimbotAdapt()
pcall(stopAimbotV2)
if _aimbotConn then
pcall(function() _aimbotConn:Disconnect() end)
_aimbotConn = nil
end
if _batV2Conn then
pcall(function() _batV2Conn:Disconnect() end)
_batV2Conn = nil
end
autoBatV2HitCooldown = false
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate
hum.PlatformStand = false
pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
end
if root then
root.AssemblyLinearVelocity = _V3new(0, -0.1, 0)
root.AssemblyAngularVelocity = _V3zero
end
_prevAutoRotate = nil
lastMoveDir = _V3zero
_unsuppressBodyLock(true)
end
function startAimbotAdapt()
-- route by selectedAimbotMode: v1 = classic, v2 = clover velocity-track
if tostring(selectedAimbotMode or "v1"):lower() == "v2" then
    stopAimbotV2()
    if _batV2Conn then pcall(function() _batV2Conn:Disconnect() end); _batV2Conn = nil end
    startAimbotV2()
    return
end
stopAimbotV2()
-- Bat V1 engine (classic)
if _batV2Conn then return end
_suppressBodyLock()
local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum0 then
if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
hum0.AutoRotate = false
end
_batV2Conn = RunService.Heartbeat:Connect(function()
if not autoBatEnabled then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
local hum = char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
-- equip bat if needed
if not char:FindFirstChildOfClass("Tool") then
local bat = findBat and findBat() or nil
if bat then pcall(function() hum:EquipTool(bat) end) end
end
local target = getClosestTarget and getClosestTarget() or nil
if target then
local targetVel = target.AssemblyLinearVelocity or _V3zero
local moveDir = targetVel.Magnitude > 0.1 and targetVel.Unit or target.CFrame.LookVector
local offset = moveDir * (AUTO_BAT_V2_DIST or 1.0) + _V3new(0, (AUTO_BAT_V2_HEIGHT or 1.5) + (AUTO_BAT_V2_V_OFF or 0), 0)
local desiredPos = target.Position + offset
local toTarget = desiredPos - root.Position
local spd = getAimbotChaseSpeed()
if toTarget.Magnitude > 0.5 then
local moveVec = toTarget.Unit * spd
root.AssemblyLinearVelocity = _V3new(moveVec.X, moveVec.Y, moveVec.Z)
else
root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.95
if root.AssemblyLinearVelocity.Magnitude < 1 then
root.AssemblyLinearVelocity = _V3zero
end
end
-- face target lightly
local flat = _V3new(desiredPos.X - root.Position.X, 0, desiredPos.Z - root.Position.Z)
if flat.Magnitude > 0.1 then
local goalCF = _CFlookAt(root.Position, _V3new(desiredPos.X, root.Position.Y, desiredPos.Z))
local diffCF = root.CFrame:Inverse() * goalCF
local _, ry, _ = diffCF:ToEulerAnglesXYZ()
ry = _clamp(ry, -2.5, 2.5)
root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(_V3new(0, ry * 42, 0))
end
local distToTarget = (root.Position - target.Position).Magnitude
if distToTarget <= (AUTO_BAT_V2_HIT_DIST or 4.5) then
if not autoBatV2HitCooldown then
autoBatV2HitCooldown = true
pcall(function()
local tool = char:FindFirstChildOfClass("Tool") or (findBat and findBat())
if tool then
if tool.Parent ~= char then pcall(function() hum:EquipTool(tool) end) end
local remote = tool:FindFirstChildOfClass("RemoteEvent")
if remote then pcall(function() remote:FireServer() end)
else pcall(function() tool:Activate() end) end
end
end)
task.delay(AUTO_BAT_V2_SWING_CD or 0.08, function() autoBatV2HitCooldown = false end)
end
end
else
root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.9
if root.AssemblyLinearVelocity.Magnitude < 1 then
root.AssemblyLinearVelocity = _V3zero
end
end
end)
_aimbotConn = _batV2Conn
end
function disableAutoBat()
autoBatEnabled = false
if autoBatSetVisual then autoBatSetVisual(false) end
if mobSetAutoBat then mobSetAutoBat(false) end
stopAimbotAdapt()
end
function enableAutoBat()
if type(safeModeTryStart) == "function" and not safeModeTryStart() then return end
if autoLeftEnabled then
autoLeftEnabled = false
if autoLeftSetVisual then autoLeftSetVisual(false) end
stopAutoLeft()
end
if autoRightEnabled then
autoRightEnabled = false
if autoRightSetVisual then autoRightSetVisual(false) end
stopAutoRight()
end
autoBatEnabled = true
if autoBatSetVisual then autoBatSetVisual(true) end
if mobSetAutoBat then mobSetAutoBat(true) end
-- Bat V4 uses normal adapt aimbot path
if tostring(selectedAimbotMode or "") == "v4" then
    selectedAimbotMode = "v4"
    pcall(function() _G.AIMBOT_MODE = "normal" end)
end
startAimbotAdapt()
end
antiBypassSetVisual = nil
antiBypassFloatingButton = nil
antiBypassFloatingPos = nil
antiBypassFloatingSetVisual = nil
do
local circleConnection = nil
local circleSafetyConn = nil
local targetPlayer = nil
local function getBypassBat(char)
local equipped = char and char:FindFirstChildOfClass("Tool")
if equipped then
local name = equipped.Name:lower()
if name:find("bat", 1, true) or name:find("slap", 1, true) then return equipped end
end
local backpack = LP:FindFirstChildOfClass("Backpack")
if backpack then
for _, tool in ipairs(backpack:GetChildren()) do
if tool:IsA("Tool") then
local name = tool.Name:lower()
if name:find("bat", 1, true) or name:find("slap", 1, true) then return tool end
end
end
end
return nil
end
local function getNearestBypassTarget()
local char = LP.Character
if not char then return nil end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return nil end
local myPos = root.Position
local nearestDist = math.huge
local nearestPlr = nil
local MAX_TARGET_DISTANCE = 250
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LP and p.Character then
local otherRoot = p.Character:FindFirstChild("HumanoidRootPart")
local otherHum = p.Character:FindFirstChildOfClass("Humanoid")
if otherRoot and otherHum and otherHum.Health > 0 then
local dist = (myPos - otherRoot.Position).Magnitude
if dist <= MAX_TARGET_DISTANCE and dist < nearestDist then
nearestDist = dist
nearestPlr = p
end
end
end
end
return nearestPlr
end
local function clearAngV()
local c = LP.Character
local r = c and c:FindFirstChild("HumanoidRootPart")
if r then
local a = r:FindFirstChild("_NoxBypass_AngV"); if a then a:Destroy() end
local at = r:FindFirstChild("_NoxBypass_Att"); if at then at:Destroy() end
end
end
local function ensureAngV(r)
if not r then return nil end
local a = r:FindFirstChild("_NoxBypass_AngV"); if a then a:Destroy() end
local at = r:FindFirstChild("_NoxBypass_Att"); if at then at:Destroy() end
local att = Instance.new("Attachment")
att.Name = "_NoxBypass_Att"
att.Parent = r
local angV = Instance.new("AngularVelocity")
angV.Name = "_NoxBypass_AngV"
angV.Attachment0 = att
angV.RelativeTo = Enum.ActuatorRelativeTo.World
angV.MaxTorque = math.huge
angV.AngularVelocity = Vector3.zero
angV.Parent = r
return angV
end
local function stopCircleCombat()
if circleConnection then
circleConnection:Disconnect()
circleConnection = nil
end
if circleSafetyConn then
circleSafetyConn:Disconnect()
circleSafetyConn = nil
end
clearAngV()
targetPlayer = nil
if _G.__NoxBubbleAimbotState then
_G.__NoxBubbleAimbotState.target = nil
_G.__NoxBubbleAimbotState.nextSwingAt = 0
end
local char = LP.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum.AutoRotate = true end
local root = char:FindFirstChild("HumanoidRootPart")
if root then root.AssemblyAngularVelocity = Vector3.zero end
end
end
local function startCircleCombat()
if circleConnection then return end
local bubbleAimbot = _G.__NoxBubbleAimbotState or { nextSwingAt = 0, target = nil, intendedVelocity = Vector3.zero }
_G.__NoxBubbleAimbotState = bubbleAimbot
circleConnection = RunService.RenderStepped:Connect(function()
if not antiBypassEnabled then
if circleConnection then circleConnection:Disconnect(); circleConnection = nil end
if circleSafetyConn then circleSafetyConn:Disconnect(); circleSafetyConn = nil end
clearAngV()
return
end
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
if not root or not humanoid or humanoid.Health <= 0 then
clearAngV()
return
end
humanoid.AutoRotate = false
local angV = root:FindFirstChild("_NoxBypass_AngV")
if not angV or not angV.Parent then angV = ensureAngV(root) end
local bat = getBypassBat(char)
if bat and bat.Parent ~= char then
pcall(humanoid.EquipTool, humanoid, bat)
end
if not bat then return end
targetPlayer = getNearestBypassTarget()
local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
local targetHum = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
if not targetRoot or not targetHum or targetHum.Health <= 0 then
bubbleAimbot.target = nil
if angV then angV.AngularVelocity = Vector3.zero end
humanoid.AutoRotate = true
return
end
bubbleAimbot.target = targetRoot
local targetVel = targetRoot.AssemblyLinearVelocity or Vector3.zero
-- V5 = Clover velocity-track anti-bypass chase
if tostring(bypassAimbotVersion or "v1"):lower() == "v5" then
    local now = os.clock()
    if type(_noxBatReadVelocity) == "function" then
        targetVel = _noxBatReadVelocity(targetRoot, now)
    end
    local myPos = root.Position
    local targetPos = targetRoot.Position
    local predictLead = 0.14
    local lookAhead = 0.3
    local predictPos = targetPos + targetVel * predictLead + targetRoot.CFrame.LookVector * lookAhead
    local direction = predictPos - myPos
    local flat = Vector3.new(direction.X, 0, direction.Z)
    local spd = tonumber(ANTI_BYPASS_SPEED) or 58
    if spd ~= spd or spd <= 0 or spd == math.huge then spd = 58 end
    if flat.Magnitude > 0.001 then
        local flatDir = flat.Unit
        local aimHeight = 3.7
        local yBoost = 19.5
        local desiredHeight = targetPos.Y + aimHeight
        local yVel = (desiredHeight - myPos.Y) * yBoost + targetVel.Y * 0.8
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end
        yVel = math.clamp(yVel, -70, 110)
        local desiredVel = Vector3.new(flatDir.X * spd, yVel, flatDir.Z * spd)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        bubbleAimbot.intendedVelocity = desiredVel
        if angV then
            local goalCF = CFrame.lookAt(myPos, predictPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            angV.AngularVelocity = Vector3.new(0, math.clamp(ry * 42, -28, 28), 0)
        end
        if (targetPos - myPos).Magnitude <= 14 then
            local now2 = tick()
            if now2 >= (bubbleAimbot.nextSwingAt or 0) then
                bubbleAimbot.nextSwingAt = now2 + 0.08
                pcall(bat.Activate, bat)
                local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
                if remote then pcall(function() remote:FireServer() end) end
            end
        end
    end
    return
end

-- V6 = Aimbot Mode 1 style (PrimeVS classic chase)
if tostring(bypassAimbotVersion or "v1"):lower() == "v6" then
    local myPos = root.Position
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.AssemblyLinearVelocity or Vector3.zero
    local predict = targetPos + targetVel * 0.18
    local delta = predict - myPos
    local flat = Vector3.new(delta.X, 0, delta.Z)
    local spd = tonumber(ANTI_BYPASS_SPEED) or 58
    if flat.Magnitude > 0.1 then
        local dir = flat.Unit
        local yVel = math.clamp((targetPos.Y + 3.5 - myPos.Y) * 12 + targetVel.Y * 0.5, -50, 90)
        root.AssemblyLinearVelocity = Vector3.new(dir.X * spd, yVel, dir.Z * spd)
        bubbleAimbot.intendedVelocity = root.AssemblyLinearVelocity
        if angV then
            local yaw = math.atan2(-dir.X, -dir.Z)
            angV.AngularVelocity = Vector3.new(0, math.clamp((yaw - math.rad(root.Orientation.Y + 180)) * 25, -30, 30), 0)
        end
        if (targetPos - myPos).Magnitude <= 12 then
            local now2 = tick()
            if now2 >= (bubbleAimbot.nextSwingAt or 0) then
                bubbleAimbot.nextSwingAt = now2 + 0.1
                pcall(bat.Activate, bat)
                local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
                if remote then pcall(function() remote:FireServer() end) end
            end
        end
    end
    return
end
-- V7 = Aimbot Mode 2 style (PrimeVS AV2 prediction-heavy)
if tostring(bypassAimbotVersion or "v1"):lower() == "v7" then
    local myPos = root.Position
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.AssemblyLinearVelocity or Vector3.zero
    local predTime = 0.22
    local predicted = targetPos + targetVel * predTime
    local horizVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    if horizVel.Magnitude > 1 then predicted = predicted + horizVel.Unit * 3 end
    local aimPoint = predicted - myPos
    local spd = tonumber(ANTI_BYPASS_SPEED) or 58
    if aimPoint.Magnitude > 1 then
        root.AssemblyLinearVelocity = aimPoint.Unit * spd
        bubbleAimbot.intendedVelocity = root.AssemblyLinearVelocity
        if angV and aimPoint.Magnitude > 0.1 then
            local flat = Vector3.new(aimPoint.X, 0, aimPoint.Z)
            if flat.Magnitude > 0.1 then
                local goal = CFrame.lookAt(myPos, myPos + flat)
                local _, y1 = root.CFrame:ToOrientation()
                local _, y2 = goal:ToOrientation()
                angV.AngularVelocity = Vector3.new(0, math.clamp((y2 - y1) * 40, -35, 35), 0)
            end
        end
        if (targetPos - myPos).Magnitude <= 13 then
            local now2 = tick()
            if now2 >= (bubbleAimbot.nextSwingAt or 0) then
                bubbleAimbot.nextSwingAt = now2 + 0.12
                pcall(bat.Activate, bat)
            end
        end
    end
    return
end
-- V8 = Bat V2 style (PrimeVS BatV2)
if tostring(bypassAimbotVersion or "v1"):lower() == "v8" then
    local myPos = root.Position
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.AssemblyLinearVelocity or Vector3.zero
    local ping = 0.08
    local predicted = targetPos + targetVel * (0.22 + ping)
    local horiz = Vector3.new(predicted.X - myPos.X, 0, predicted.Z - myPos.Z)
    local spd = tonumber(ANTI_BYPASS_SPEED) or 55
    if horiz.Magnitude > 1 then
        local dir = horiz.Unit
        local yVel = math.clamp((targetPos.Y + 4.5 - myPos.Y) * 14 + targetVel.Y * 0.6, -60, 100)
        root.AssemblyLinearVelocity = Vector3.new(dir.X * spd, yVel, dir.Z * spd)
        bubbleAimbot.intendedVelocity = root.AssemblyLinearVelocity
        if angV then
            angV.AngularVelocity = Vector3.new(0, math.clamp(math.atan2(-dir.X, -dir.Z) * 20, -40, 40), 0)
        end
        if (targetPos - myPos).Magnitude <= 13 then
            local now2 = tick()
            if now2 >= (bubbleAimbot.nextSwingAt or 0) then
                bubbleAimbot.nextSwingAt = now2 + 0.08
                pcall(bat.Activate, bat)
                local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
                if remote then pcall(function() remote:FireServer() end) end
            end
        end
    end
    return
end
local aimPos = targetRoot.Position + targetRoot.CFrame.LookVector * (targetVel.Magnitude < 0.1 and 1.5 or 5)
local delta = aimPos - root.Position
local horizontal = Vector3.new(delta.X, 0, delta.Z)
local distance = delta.Magnitude
local spd = tonumber(ANTI_BYPASS_SPEED) or 58
if spd ~= spd or spd <= 0 or spd == math.huge then spd = 58 end
if delta.Magnitude > 0.01 and horizontal.Magnitude > 0.01 and angV then
local curY = root.Orientation.Y
local yawD = (math.deg(math.atan2(-horizontal.X, -horizontal.Z)) - curY + 180) % 360 - 180
local curX = root.Orientation.X
local pitchD = (math.deg(math.atan2(delta.Y, horizontal.Magnitude)) - curX + 180) % 360 - 180
local rotY = math.clamp(math.rad(yawD) * 40, -28, 28)
local rotX = math.clamp(math.rad(pitchD) * 40, -28, 28)
local yawR = math.rad(root.Orientation.Y)
local fwd = Vector3.new(math.cos(yawR), 0, -math.sin(yawR))
angV.AngularVelocity = Vector3.new(0, rotY, 0) + fwd * rotX
elseif angV then
angV.AngularVelocity = Vector3.zero
end
local unit = horizontal.Magnitude > 0.1 and horizontal.Unit or Vector3.zero
local vertVel = math.clamp((aimPos.Y + 3.7 - root.Position.Y) * 19.5 + targetVel.Y * 0.8, -70, 110)
if humanoid.FloorMaterial ~= Enum.Material.Air then
vertVel = math.max(vertVel, 13)
end
local intended = Vector3.new(unit.X * spd, vertVel, unit.Z * spd)
bubbleAimbot.intendedVelocity = intended
root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(intended, 0.8)
if _s2VelState then
_s2VelState.v = Vector3.new(unit.X * 16, vertVel, unit.Z * 16)
end
if horizontal.Magnitude > 0.3 then
pcall(function() humanoid:Move(unit, false) end)
else
pcall(function() humanoid:Move(Vector3.zero, false) end)
end
if distance <= 12 then
local now = tick()
if now >= (bubbleAimbot.nextSwingAt or 0) then
bubbleAimbot.nextSwingAt = now + 0.08
pcall(bat.Activate, bat)
local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
if remote then pcall(function() remote:FireServer() end) end
end
end
end)
circleSafetyConn = RunService.Heartbeat:Connect(function()
if not antiBypassEnabled then
if circleSafetyConn then circleSafetyConn:Disconnect(); circleSafetyConn = nil end
return
end
local c = LP.Character
local r = c and c:FindFirstChild("HumanoidRootPart")
if not r then return end
local v = r.AssemblyLinearVelocity
if math.abs(v.X) > 350 or math.abs(v.Z) > 350 then
r.AssemblyLinearVelocity = bubbleAimbot.intendedVelocity or Vector3.zero
end
end)
end

-- Hunter-style Bat Bypass V2 (TPBat)
local TPBat = {
    Enabled = false,
    Connection = nil,
    Target = nil,
    SwingCooldown = false,
    LastSwing = 0,
    PrevAutoRotate = nil,
}
local function tpBatFindBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("bat", 1, true) or n:find("slap", 1, true) then return tool end
        end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("bat", 1, true) or n:find("slap", 1, true) then return tool end
            end
        end
    end
    return nil
end
local function tpBatClosest()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, 1e9 end
    local closest, minD = nil, 1e9
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tr = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tr and hum and hum.Health > 0 then
                local d = (tr.Position - root.Position).Magnitude
                if d < minD then minD, closest = d, tr end
            end
        end
    end
    return closest, minD
end
function TPBat.Start()
    if TPBat.Connection then pcall(function() TPBat.Connection:Disconnect() end) TPBat.Connection = nil end
    TPBat.Enabled = true
    TPBat.Target = nil
    TPBat.SwingCooldown = false
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then TPBat.PrevAutoRotate = hum.AutoRotate; hum.AutoRotate = false end
    local speed = tonumber(BYPASS_AIMBOT_SPEED) or tonumber(BAT_AIMBOT_SPEED) or 58
    TPBat.Connection = RunService.Heartbeat:Connect(function()
        if not TPBat.Enabled then return end
        local c = LP.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not root or not h or h.Health <= 0 then return end
        local bat = c:FindFirstChildOfClass("Tool") or tpBatFindBat()
        if bat and bat.Parent ~= c then pcall(function() h:EquipTool(bat) end) end
        local target, dist = tpBatClosest()
        if not target then TPBat.Target = nil; return end
        TPBat.Target = target
        local tpos = target.Position
        local tvel = target.AssemblyLinearVelocity
        local lead = (tvel.Magnitude > 1) and (tvel.Unit * 2) or Vector3.zero
        local aim = tpos + lead + Vector3.new(0, 1.2, 0)
        local look = aim - root.Position
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.05 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position + flat)
        end
        local dir = flat.Magnitude > 0.05 and flat.Unit or Vector3.zero
        root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, root.AssemblyLinearVelocity.Y, dir.Z * speed)
        if bat and not TPBat.SwingCooldown and dist < 12 then
            local now = tick()
            if now - TPBat.LastSwing >= 0.08 then
                TPBat.SwingCooldown = true
                TPBat.LastSwing = now
                pcall(function() bat:Activate() end)
                task.delay(0.08, function() TPBat.SwingCooldown = false end)
            end
        end
    end)
end
function TPBat.Stop()
    if TPBat.Connection then pcall(function() TPBat.Connection:Disconnect() end) TPBat.Connection = nil end
    TPBat.Enabled = false
    TPBat.Target = nil
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then pcall(function() root.AssemblyLinearVelocity = Vector3.zero end) end
    if hum then hum.AutoRotate = (TPBat.PrevAutoRotate == nil) and true or TPBat.PrevAutoRotate end
end
_G.UNOTPBat = TPBat


function startAntiBypass()
if type(safeModeTryStart) == "function" and not safeModeTryStart() then return end
if antiBypassEnabled then return end
if autoBatEnabled and disableAutoBat then pcall(disableAutoBat) end
antiBypassEnabled = true
if type(_suppressBodyLock) == "function" then pcall(_suppressBodyLock) end
local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum0 and _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
-- V2 = Hunter TPBat style, V1 = original circle combat
if tostring(bypassAimbotVersion or "v1") == "v2" then
    pcall(function() if TPBat and TPBat.Start then TPBat.Start() end end)
else
    startCircleCombat()
end
if antiBypassSetVisual then antiBypassSetVisual(true) end
if antiBypassFloatingSetVisual then antiBypassFloatingSetVisual(true) end
end
function stopAntiBypass()
pcall(function() if TPBat and TPBat.Stop then TPBat.Stop() end end)
antiBypassEnabled = false
stopCircleCombat()
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate
hum.PlatformStand = false
pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
end
if root then
root.AssemblyLinearVelocity = Vector3.new(0, -0.1, 0)
root.AssemblyAngularVelocity = Vector3.zero
end
_prevAutoRotate = nil
if type(_unsuppressBodyLock) == "function" then pcall(_unsuppressBodyLock, true) end
if antiBypassSetVisual then antiBypassSetVisual(false) end
if antiBypassFloatingSetVisual then antiBypassFloatingSetVisual(false) end
end
function toggleAntiBypass()
if antiBypassEnabled then
stopAntiBypass()
else
startAntiBypass()
end
if saveAllSettings then pcall(saveAllSettings, true) end
return antiBypassEnabled
end
_G.YoutAntiBypass = {
start = startAntiBypass,
stop = stopAntiBypass,
toggle = toggleAntiBypass,
isOn = function() return antiBypassEnabled end,
}
_G.NoxAntiBypass = _G.YoutAntiBypass
end
spamBatEnabled = spamBatEnabled or false
spamBatSetVisual = nil
_G._NoxSpamBatThread = nil
distanceRingEnabled = false
distanceRingSetVisual = nil
warningHighPingEnabled = false
setWarningHighPingVisual = nil
function toggleWarningHighPing(on) warningHighPingEnabled = false end
function startDistanceRing() end
function stopDistanceRing() end
function toggleDistanceRing(on) distanceRingEnabled = false end
function _G._NoxIsBatTool(tool)
if not tool or not tool:IsA("Tool") then return false end
local n = tool.Name:lower()
return n:find("bat", 1, true) ~= nil or n:find("slap", 1, true) ~= nil
end
function _G._NoxGetEquippedBat()
local char = LP.Character
if not char then return nil end
for _, t in ipairs(char:GetChildren()) do
if _G._NoxIsBatTool(t) then return t end
end
return nil
end
function startSpamBat()
if _G._NoxSpamBatThread then return end
spamBatEnabled = true
_G._NoxSpamBatThread = task.spawn(function()
while spamBatEnabled do
local bat = _G._NoxGetEquippedBat()
if bat then
pcall(function()
bat:Activate()
local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
if ev then ev:FireServer() end
end)
task.wait(0.08)
else
task.wait(0.15)
end
end
_G._NoxSpamBatThread = nil
end)
end
function stopSpamBat()
spamBatEnabled = false
_G._NoxSpamBatThread = nil
end
function toggleSpamBat(on)
if on then startSpamBat() else stopSpamBat() end
if spamBatSetVisual then spamBatSetVisual(spamBatEnabled) end
end
function _G._NoxIsCarryingAnimal()
local char = LP.Character
if not char then return false end
if LP:GetAttribute("Stealing") == true or char:GetAttribute("Stealing") == true then
return true
end
for _, child in ipairs(char:GetChildren()) do
if child:IsA("Tool") then
local n = child.Name:lower()
if not (n:find("bat") or n:find("slap") or n:find("medusa") or n:find("head") or n:find("stone")) then
return true
end
end
end
return false
end
function _G._NoxEnsureCarryTag()
if _G._NoxCarryTagBillboard and _G._NoxCarryTagBillboard.Parent then return _G._NoxCarryTagBillboard end
local bb = Instance.new("BillboardGui")
bb.Name = "NoxCarryWarn"
bb.Size = UDim2.new(0, 320, 0, 52)
bb.StudsOffset = Vector3.new(0, 4.2, 0)
bb.AlwaysOnTop = true
bb.MaxDistance = 200
bb.Enabled = false
local frame = Instance.new("Frame", bb)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(200, 30, 40)
stroke.Thickness = 2
stroke.Transparency = 0.05
local lbl = Instance.new("TextLabel", frame)
lbl.Name = "WarnLabel"
lbl.Size = UDim2.new(1, -12, 1, 0)
lbl.Position = UDim2.new(0, 6, 0, 0)
lbl.BackgroundTransparency = 1
lbl.Text = "Don't be reckless, stupid"
lbl.TextColor3 = Color3.fromRGB(140, 20, 30)
lbl.Font = Enum.Font.GothamBlack
lbl.TextScaled = true
lbl.ZIndex = 2
local constraint = Instance.new("UITextSizeConstraint", lbl)
constraint.MaxTextSize = 18
constraint.MinTextSize = 12
_G._NoxCarryTagBillboard = bb
return bb
end
function startCarryTagLoop()
if _G._NoxCarryTagThread then return end
_G._NoxCarryTagThread = task.spawn(function()
while true do
local carrying = false
pcall(function() carrying = _G._NoxIsCarryingAnimal() end)
local char = LP.Character
local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
local bb = _G._NoxEnsureCarryTag()
if carrying and head then
if bb.Adornee ~= head or bb.Parent ~= head then
bb.Parent = head
bb.Adornee = head
end
bb.Enabled = true
else
bb.Enabled = false
end
task.wait(0.12)
end
end)
end
function findBat()
local char = LP.Character
if not char then return nil end
for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
local t = char:FindFirstChild(name)
if t and t:IsA("Tool") then return t end
end
local bp = LP:FindFirstChildOfClass("Backpack")
if bp then
for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
local t = bp:FindFirstChild(name)
if t and t:IsA("Tool") then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then pcall(function() hum:EquipTool(t) end) end
return t
end
end
end
for _, ch in ipairs(char:GetChildren()) do
if ch:IsA("Tool") and (ch.Name:lower():find("bat") or ch.Name:lower():find("slap")) then
return ch
end
end
return nil
end
function isBatTool(tool)
if not tool then return false end
for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
if tool.Name == name then return true end
end
return tool.Name:lower():find("bat") or tool.Name:lower():find("slap")
end
function findBatForCounter()
local char = LP.Character
if not char then return nil end
local backpack = LP:FindFirstChildOfClass("Backpack")
for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
local tool = char:FindFirstChild(name) or (backpack and backpack:FindFirstChild(name))
if tool then return tool end
end
for _, child in ipairs(char:GetChildren()) do
if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
return child
end
end
if backpack then
for _, child in ipairs(backpack:GetChildren()) do
if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
return child
end
end
end
return nil
end
function swingBatForCounter(bat, character)
local humanoid = character:FindFirstChildOfClass("Humanoid")
if bat.Parent ~= character and humanoid then
pcall(function() humanoid:EquipTool(bat) end)
task.wait(0.05)
end
local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
if remote and remote:IsA("RemoteEvent") then
pcall(function() remote:FireServer() end)
task.wait(0.1)
pcall(function() remote:FireServer() end)
else
pcall(function() bat:Activate() end)
task.wait(0.1)
pcall(function() bat:Activate() end)
end
end
batCounterDebounce = false
function stopBatCounter()
if Conns.batCounter then
Conns.batCounter:Disconnect()
Conns.batCounter = nil
end
batCounterDebounce = false
end
function startBatCounter()
if Conns.batCounter then return end
Conns.batCounter = RunService.Heartbeat:Connect(function()
if not batCounterEnabled then return end
if batCounterDebounce then return end
local character = LP.Character
if not character then return end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end
local state = humanoid:GetState()
if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
batCounterDebounce = true
_suppressBodyLock()
task.spawn(function()
task.wait(0.15)
local bat = findBatForCounter()
if bat then swingBatForCounter(bat, character) end
task.wait(0.3)
batCounterDebounce = false
_unsuppressBodyLock(true)
end)
end
end)
end
function findMedusa()
local c = LP.Character
if not c then return nil end
for _, t in ipairs(c:GetChildren()) do
if t:IsA("Tool") then
local n = t.Name:lower()
if n:find("medusa") or n:find("head") or n:find("stone") then return t end
end
end
local bp = LP:FindFirstChild("Backpack")
if bp then
for _, t in ipairs(bp:GetChildren()) do
if t:IsA("Tool") then
local n = t.Name:lower()
if n:find("medusa") or n:find("head") or n:find("stone") then return t end
end
end
end
return nil
end
function useMedusaCounter()
if medusaDebounce then return end
if _tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
local c = LP.Character
if not c then return end
medusaDebounce = true
local med = findMedusa()
if not med then medusaDebounce = false; return end
if med.Parent ~= c then
local hum2 = c:FindFirstChildOfClass("Humanoid")
if hum2 then hum2:EquipTool(med) end
end
pcall(function() med:Activate() end)
medusaLastUsed = _tick()
medusaDebounce = false
end
function onAnchorChanged(part)
return part:GetPropertyChangedSignal("Anchored"):Connect(function()
if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then useMedusaCounter() end
end)
end
function setupMedusaCounter(char)
for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
Conns.anchor = {}
if not char or not medusaCounterEnabled then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then
table.insert(Conns.anchor, onAnchorChanged(part))
end
end
table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part)
if part:IsA("BasePart") then
table.insert(Conns.anchor, onAnchorChanged(part))
end
end))
end
function stopMedusaCounter()
for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
Conns.anchor = {}
end
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150
local _dropConn = nil
function stopDropBrainrot()
dropActive = false
if _dropConn then
_dropConn:Disconnect()
_dropConn = nil
end
for _, t in ipairs(dropConnections) do
if type(t) == "thread" then pcall(task.cancel, t)
elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
end
dropConnections = {}
local c = LP.Character
if c then
local root = c:FindFirstChild("HumanoidRootPart")
if root then root.AssemblyLinearVelocity = _V3zero end
end
if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
if mobSetDropBR then mobSetDropBR(false) end
end
function runDropBrainrot()
if dropActive then return end
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
if dropMode == 1 then
local speedH = 0
if root then
local vel = root.AssemblyLinearVelocity
speedH = _V3new(vel.X, 0, vel.Z).Magnitude
end
local cooldown = (speedH > 5) and 0.6 or 0.25
if _tick() - lastDropTime < cooldown then return end
lastDropTime = _tick()
dropActive = true
if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
if mobSetDropBR then mobSetDropBR(true) end
local wasAutoBat = false
if autoBatEnabled then
wasAutoBat = true
disableAutoBat()
if autoBatSetVisual then autoBatSetVisual(false) end
if mobSetAutoBat then mobSetAutoBat(false) end
end
local function finishDrop(threadRef)
if threadRef and dropConnections then
for i = #dropConnections, 1, -1 do
if dropConnections[i] == threadRef then
table.remove(dropConnections, i)
break
end
end
end
dropActive = false
local c = LP.Character
if c then
local r = c:FindFirstChild("HumanoidRootPart")
local h = c:FindFirstChildOfClass("Humanoid")
if r then
r.AssemblyLinearVelocity = _V3zero
r.AssemblyAngularVelocity = _V3zero
if r.Position.Y < -100 then
r.CFrame = _CFnew(r.Position.X, 5, r.Position.Z)
end
local rp = RaycastParams.new()
rp.FilterDescendantsInstances = {c}
rp.FilterType = Enum.RaycastFilterType.Exclude
local rr = workspace:Raycast(r.Position, _V3new(0, -2000, 0), rp)
if rr then
local off = (h and h.HipHeight or 2) + (r.Size.Y / 2)
r.CFrame = _CFnew(r.Position.X, rr.Position.Y + off, r.Position.Z)
end
if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Running) end
end
end
if wasAutoBat then
enableAutoBat()
if autoBatSetVisual then autoBatSetVisual(true) end
if mobSetAutoBat then mobSetAutoBat(true) end
end
if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
if mobSetDropBR then mobSetDropBR(false) end
end
local flingThread = nil
flingThread = task.spawn(function()
local startTime = _tick()
while dropActive and (_tick() - startTime) < 0.25 do
RunService.Heartbeat:Wait()
local c = LP.Character
local r = c and c:FindFirstChild("HumanoidRootPart")
if not r then break end
local vel = r.AssemblyLinearVelocity
vel = _V3new(0, vel.Y, 0)
r.AssemblyLinearVelocity = vel * 10000 + _V3new(0, 10000, 0)
RunService.RenderStepped:Wait()
if r and r.Parent then r.AssemblyLinearVelocity = vel end
RunService.Stepped:Wait()
if r and r.Parent then r.AssemblyLinearVelocity = vel + _V3new(0, 0.1, 0) end
end
finishDrop(flingThread)
end)
table.insert(dropConnections, flingThread)
task.delay(0.35, function()
if dropActive then finishDrop(flingThread) end
end)
return
end
if autoBatEnabled then
autoBatEnabled = false
if autoBatSetVisual then autoBatSetVisual(false) end
if mobSetAutoBat then mobSetAutoBat(false) end
if stopAimbotAdapt then stopAimbotAdapt() end
end
dropActive = true
if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
if mobSetDropBR then mobSetDropBR(false) end
local t0 = _tick()
if _dropConn then _dropConn:Disconnect() end
_dropConn = RunService.Heartbeat:Connect(function()
local r = char and char:FindFirstChild("HumanoidRootPart")
if not r then
if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
dropActive = false
if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
if mobSetDropBR then mobSetDropBR(false) end
return
end
if _tick() - t0 >= DROP_ASCEND_DURATION then
if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
local rp = _RayParams_new()
rp.FilterDescendantsInstances = {char}
rp.FilterType = Enum.RaycastFilterType.Exclude
local rr = workspace:Raycast(r.Position, _V3new(0, -2000, 0), rp)
if rr then
local hum2 = char:FindFirstChildOfClass("Humanoid")
local off = ((hum2 and hum2.HipHeight) or 2) + (r.Size.Y / 2)
r.CFrame = _CFnew(r.Position.X, rr.Position.Y + off, r.Position.Z)
r.AssemblyLinearVelocity = _V3zero
end
dropActive = false
if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
if mobSetDropBR then mobSetDropBR(false) end
return
end
r.Velocity = _V3new(r.Velocity.X, DROP_ASCEND_SPEED, r.Velocity.Z)
end)
end
function executeDropWithToggle(setVisual)
if dropActive then return end
task.spawn(function()
if setVisual then setVisual(true) end
runDropBrainrot()
while dropActive do task.wait() end
task.wait(0.1)
if setVisual then setVisual(false) end
end)
end
local _alSaved = setmetatable({}, { __mode = "k" })
local _alDetached = {}
local _alAnimators = setmetatable({}, { __mode = "k" })
local _alStoppedTracks = setmetatable({}, { __mode = "k" })
local _alGeneration = 0
local _alScanCancel = nil
local _alConns = {}
local _alLightOrig = nil
local _alRunning = false
local AL_LOW_FLAGS = {
{"DFIntClusterSenderMaxJoinBandwidthBps", "2100000000"},
{"DFIntClusterSenderMaxUpdateBandwidthBps", "2100000000"},
{"DFIntServerFramesBetweenJoins", "1"},
{"DFIntRaknetBandwidthInfluxHundredthsPercentageV2", "10000"},
{"DFIntConnectionMTUSize", "1400"},
{"FIntRakNetResendBufferArrayLength", "1024"},
{"DFIntRakNetNakResendDelayMsMax", "1"},
{"DFIntWaitOnUpdateNetworkLoopEndedMS", "100"},
{"DFIntWaitOnRecvFromLoopEndedMS", "100"},
{"DFIntLargePacketQueueSizeCutoffMB", "1000"},
{"DFIntSendRakNetStatsInterval", "2147483647"},
{"DFIntRakNetLoopMs", "1"},
{"DFIntRakNetSelectTimeoutMs", "1"},
{"DFIntNetworkClusterPacketCacheNumParallelTasks", "8"},
{"DFIntReplicationDataCacheNumParallelTasks", "8"},
{"DFIntMegaReplicatorNumParallelTasks", "16"},
{"DFIntMaxProcessPacketsStepsPerCyclic", "512"},
{"DFIntMaxProcessPacketsStepsAccumulated", "0"},
{"DFIntMaxProcessPacketsJobScaling", "1000"},
{"DFIntClientPacketMaxFrameMicroseconds", "200000"},
{"DFIntClientPacketExcessMicroseconds", "10000"},
{"DFIntClientPacketMinMicroseconds", "1"},
{"DFIntClientPacketMaxDelayMs", "1"},
{"DFIntMaxWaitTimeBeforeForcePacketProcessMS", "1"},
{"DFIntMaxFrameBufferSize", "4"},
{"DFIntBufferCompressionThreshold", "100"},
{"DFIntOverrideISRReplicatorStepBandwidthBytes", "131072"},
{"DFIntTaskSchedulerJobInitThreads", "8"},
{"DFIntTaskSchedulerJobInGameThreads", "8"},
{"FIntTaskSchedulerAutoThreadLimit", "16"},
{"FIntTaskSchedulerAsyncTasksMinimumThreadCount", "4"},
{"DFIntRuntimeConcurrency", "16"},
{"FIntSimWorldTaskQueueParallelTasks", "20"},
{"DFIntHttpBatchLimit", "256"},
{"FIntHttpBatchLimit", "256"},
{"DFIntHttpCurlConnectionCacheSize", "512"},
{"FIntDefaultMeshCacheSizeMB", "512"},
{"DFIntMemCacheMaxCapacityMB", "256"},
{"DFIntNumAssetsMaxToPreload", "1"},
{"DFFlagEnableSoundPreloading", "false"},
{"FFlagSlimContentProvider", "true"},
{"DFFlagDebugSkipMeshVoxelizer", "true"},
{"DFFlagTextureQualityOverrideEnabled", "true"},
{"DFIntTextureQualityOverride", "0"},
{"FIntDebugTextureManagerSkipMips", "7"},
{"DFIntDebugLimitMinTextureResolutionWhenSkipMips", "8"},
{"FFlagTM2SkipMipsForUnstreamable2", "true"},
{"DFFlagDoNotSkipMipsBasedOnSystemMemoryPS", "true"},
{"FFlagRenderUseTextureManager224", "false"},
{"DFIntDebugFRMQualityLevelOverride", "1"},
{"DFFlagDebugPauseVoxelizer", "true"},
{"FFlagFastGPULightCulling3", "true"},
{"FIntRenderLocalLightFadeInMs", "0"},
{"FIntRenderLocalLightUpdatesMax", "1"},
{"FIntRenderShadowmapBias", "0"},
{"FIntSSAOMipLevels", "0"},
{"FIntDebugForceMSAASamples", "1"},
{"FIntDebugFRMOptionalMSAALevelOverride", "0"},
{"FIntRobloxGuiBlurIntensity", "0"},
{"FIntFRMMinGrassDistance", "0"},
{"FIntFRMMaxGrassDistance", "0"},
{"DFFlagCoreScriptTelemetry2", "false"},
{"DFFlagBrowserTrackerIdTelemetryEnabled", "false"},
{"FFlagPerfDataOnTelemetryV2", "false"},
{"FFlagSendRenderFidelityTelemetry2", "false"},
{"FFlagEnableTelemetryServiceMemoryCPUInfo", "false"},
{"DFIntTelemetryProfilerHundredthsPercentage", "0"},
{"FIntTelemetryProfilerFrequency", "0"},
{"FIntPerformanceTelemetryQueueProcessLimit", "0"},
{"DFIntContentProviderPreloadHangTelemetryHundredthsPercentage", "0"},
}
local function _alApplyLowFlags()
local env = (getgenv and getgenv()) or _G
local setter = rawget(env, "setfflag") or rawget(_G, "set_fflag")
local getter = rawget(env, "getfflag") or rawget(_G, "get_fflag")
if type(setter) ~= "function" then return end
for _, flag in ipairs(AL_LOW_FLAGS) do
local canSet = true
if type(getter) == "function" then
local ok, current = pcall(getter, flag[1])
canSet = ok and current ~= nil
end
if canSet then pcall(setter, flag[1], tostring(flag[2])) end
end
end
local function _alSaveLighting()
if _alLightOrig then return end
_alLightOrig = {
Brightness = Lighting.Brightness,
ClockTime = Lighting.ClockTime,
OutdoorAmbient = Lighting.OutdoorAmbient,
Ambient = Lighting.Ambient,
GlobalShadows = Lighting.GlobalShadows,
EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
FogStart = Lighting.FogStart,
FogEnd = Lighting.FogEnd,
}
end
local function _alApplyLowPermanentSettings()
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
pcall(function()
UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
end)
pcall(function()
Lighting.GlobalShadows = false
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.FogStart = 0
Lighting.FogEnd = 1e10
end)
pcall(function()
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then
atmosphere.Density = 0
atmosphere.Glare = 0
atmosphere.Haze = 0
end
end)
pcall(function()
local terrain = workspace:FindFirstChildOfClass("Terrain")
if terrain then
terrain.Decoration = false
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
local clouds = terrain:FindFirstChildOfClass("Clouds")
if clouds then clouds.Enabled = false end
end
end)
end
local function _alChange(object, property, value)
pcall(function()
local original = object[property]
if original == value then return end
object[property] = value
local bucket = _alSaved[object]
if not bucket then bucket = {}; _alSaved[object] = bucket end
if not bucket[property] then bucket[property] = { value = original } end
end)
end
local function _alIsProtectedVisual(object)
local char = LP.Character
if char and (object == char or object:IsDescendantOf(char)) then return true end
local parent = object
while parent and parent ~= workspace do
if parent:IsA("LayerCollector") or parent:IsA("GuiObject") or parent:IsA("GuiBase2d") then
return true
end
local name = parent.Name or ""
if name:match("^Crystal") or name:match("^Eclipse") or name:match("^ESP_")
or name:match("^BloodHounds") or name:match("^Yout") then
return true
end
parent = parent.Parent
end
return false
end
function applyAntiLagDerender(obj)
pcall(function()
if not _alRunning then return end
if _alIsProtectedVisual(obj) then return end
if obj:IsA("Terrain") then
_alChange(obj, "Decoration", false)
_alChange(obj, "WaterWaveSize", 0)
_alChange(obj, "WaterWaveSpeed", 0)
_alChange(obj, "WaterReflectance", 0)
_alChange(obj, "WaterTransparency", 1)
end
if obj:IsA("BasePart") then
_alChange(obj, "Material", Enum.Material.Plastic)
_alChange(obj, "MaterialVariant", "")
_alChange(obj, "Reflectance", 0)
_alChange(obj, "CastShadow", false)
if obj:IsA("MeshPart") then
_alChange(obj, "TextureID", "")
_alChange(obj, "RenderFidelity", Enum.RenderFidelity.Performance)
_alChange(obj, "DoubleSided", false)
elseif obj:IsA("PartOperation") then
_alChange(obj, "RenderFidelity", Enum.RenderFidelity.Performance)
end
elseif obj:IsA("SpecialMesh") then
_alChange(obj, "TextureId", "")
elseif obj:IsA("SurfaceAppearance") then
_alDetached[obj] = true
_alChange(obj, "Parent", nil)
elseif obj:IsA("Decal") or obj:IsA("Texture") then
_alChange(obj, "Transparency", 1)
_alChange(obj, "Texture", "")
elseif obj:IsA("ParticleEmitter") then
_alChange(obj, "Enabled", false)
_alChange(obj, "Rate", 0)
pcall(function() obj:Clear() end)
elseif obj:IsA("Trail") then
_alChange(obj, "Enabled", false)
pcall(function() obj:Clear() end)
elseif obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke")
or obj:IsA("Sparkles") or obj:IsA("Light") or obj:IsA("PostEffect")
or obj:IsA("Clouds") then
_alChange(obj, "Enabled", false)
elseif obj:IsA("Atmosphere") then
_alChange(obj, "Density", 0)
_alChange(obj, "Haze", 0)
_alChange(obj, "Glare", 0)
elseif obj:IsA("Sky") then
for _, face in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","SunTextureId","MoonTextureId"}) do
_alChange(obj, face, "")
end
_alChange(obj, "StarCount", 0)
_alChange(obj, "CelestialBodiesShown", false)
elseif obj:IsA("Shirt") then
_alChange(obj, "ShirtTemplate", "")
elseif obj:IsA("Pants") then
_alChange(obj, "PantsTemplate", "")
elseif obj:IsA("ShirtGraphic") then
_alChange(obj, "Graphic", "")
elseif obj:IsA("Animator") then
if not _alAnimators[obj] then
local char = LP.Character
if not (char and obj:IsDescendantOf(char)) then
_alAnimators[obj] = true
local token = _alGeneration
local ok, conn = pcall(function()
return obj.AnimationPlayed:Connect(function(track)
if not _alRunning or _alGeneration ~= token then return end
task.defer(function()
if _alRunning and _alGeneration == token then
pcall(function() track:Stop(0) end)
end
end)
end)
end)
if ok then table.insert(_alConns, conn) end
pcall(function()
for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
if track.IsPlaying then
_alStoppedTracks[track] = {
animator = obj,
time = track.TimePosition,
speed = track.Speed,
}
track:Stop(0)
end
end
end)
end
end
end
end)
end
function enableAntiLag()
if _alRunning then return end
_alRunning = true
antiLagEnabled = true
pcall(function()
local lighting = game:GetService("Lighting")
if not _G.__YoutFPSOrig then
_G.__YoutFPSOrig = {
GlobalShadows = lighting.GlobalShadows,
FogEnd = lighting.FogEnd,
Brightness = lighting.Brightness,
EnvironmentDiffuseScale = lighting.EnvironmentDiffuseScale,
EnvironmentSpecularScale = lighting.EnvironmentSpecularScale,
}
end
lighting.GlobalShadows = false
lighting.FogEnd = 9e9
lighting.Brightness = 2
lighting.EnvironmentDiffuseScale = 0
lighting.EnvironmentSpecularScale = 0
for _, v in ipairs(lighting:GetChildren()) do
if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
or v:IsA("DepthOfFieldEffect") then
v.Enabled = false
end
end
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
pcall(function()
UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
end)
end)
end
function disableAntiLag()
if not _alRunning then
antiLagEnabled = false
return
end
_alRunning = false
antiLagEnabled = false
pcall(function()
local lighting = game:GetService("Lighting")
local orig = _G.__YoutFPSOrig
if orig then
lighting.GlobalShadows = orig.GlobalShadows
lighting.FogEnd = orig.FogEnd
lighting.Brightness = orig.Brightness
lighting.EnvironmentDiffuseScale = orig.EnvironmentDiffuseScale
lighting.EnvironmentSpecularScale = orig.EnvironmentSpecularScale
end
settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
end)
end
function applyStretchFOV(val)
local cam = workspace.CurrentCamera
if cam then pcall(function() cam.FieldOfView = val end) end
end
function enableStretch()
if stretchConn then return end
stretchEnabled = false
local cam = workspace.CurrentCamera
if not cam then return end
origFOV = cam.FieldOfView or 70
applyStretchFOV(stretchFOV)
stretchConn = RunService.RenderStepped:Connect(function()
if not stretchEnabled then
stretchConn:Disconnect()
stretchConn = nil
return
end
local c = workspace.CurrentCamera
if c then c.CFrame = c.CFrame * _CFnew(0,0,0,1,0,0,0,0.7,0,0,0,1) end
end)
if stretchFovConn then stretchFovConn:Disconnect() end
stretchFovConn = RunService.RenderStepped:Connect(function()
if stretchEnabled then applyStretchFOV(stretchFOV)
else stretchFovConn:Disconnect(); stretchFovConn = nil end
end)
end
function disableStretch()
stretchEnabled = false
if stretchConn then stretchConn:Disconnect(); stretchConn = nil end
if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end
local cam = workspace.CurrentCamera
if cam then pcall(function() cam.FieldOfView = origFOV or 70 end) end
end
local function saveLightingState()
if _originalLighting then return end
_originalLighting = {
Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows,
FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
FogColor = Lighting.FogColor, Ambient = Lighting.Ambient,
ColorCorrection = nil, Bloom = nil,
}
for _, e in ipairs(Lighting:GetChildren()) do
if e:IsA("ColorCorrectionEffect") then
_originalLighting.ColorCorrection = { Enabled = e.Enabled, Brightness = e.Brightness, Contrast = e.Contrast, Saturation = e.Saturation, TintColor = e.TintColor }
elseif e:IsA("BloomEffect") then
_originalLighting.Bloom = { Enabled = e.Enabled, Intensity = e.Intensity, Size = e.Size, Threshold = e.Threshold }
end
end
end
local function restoreLightingState()
if not _originalLighting then return end
local old = _originalLighting
Lighting.Brightness = old.Brightness
Lighting.ClockTime = old.ClockTime
Lighting.OutdoorAmbient = old.OutdoorAmbient
Lighting.GlobalShadows = old.GlobalShadows
Lighting.FogEnd = old.FogEnd
Lighting.FogStart = old.FogStart
Lighting.FogColor = old.FogColor
Lighting.Ambient = old.Ambient
if old.ColorCorrection then
local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if cc then
cc.Enabled = old.ColorCorrection.Enabled; cc.Brightness = old.ColorCorrection.Brightness
cc.Contrast = old.ColorCorrection.Contrast; cc.Saturation = old.ColorCorrection.Saturation
cc.TintColor = old.ColorCorrection.TintColor
end
end
if old.Bloom then
local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
if bloom then
bloom.Enabled = old.Bloom.Enabled; bloom.Intensity = old.Bloom.Intensity
bloom.Size = old.Bloom.Size; bloom.Threshold = old.Bloom.Threshold
end
end
end
SKY_PRESETS_LIST = {"Off"}
SKY_PRESETS = {}
function applyCustomSky(mode) end
function enableVividGraphics() vividGraphicsEnabled = false end
function disableVividGraphics() vividGraphicsEnabled = false end
function toggleVividGraphics(on) vividGraphicsEnabled = false end
function applyHideButtons(state)
hideButtonsEnabled = state
if MobilePanel then
for _, child in ipairs(MobilePanel:GetChildren()) do
if child:IsA("TextButton") then
child.Visible = not state
end
end
end
if instaResetFloatingButton then
local frame = instaResetFloatingButton:FindFirstChild("Frame")
if frame then frame.Visible = not state end
end
if antiBypassFloatingButton then
local frame = antiBypassFloatingButton:FindFirstChild("Frame")
if frame then frame.Visible = not state end
end
end
function toggleHideButtons(on)
applyHideButtons(on)
if setHideButtonsVisual then setHideButtonsVisual(on) end
saveAllSettings(true)
end
function applyButtonShape(shape)
buttonShapeMode = (shape == "Circle") and "Circle" or "Square"
local function applyTo(frame)
if not frame then return end
local corner = frame:FindFirstChildOfClass("UICorner")
if not corner then corner = Instance.new("UICorner", frame) end
corner.CornerRadius = buttonShapeMode == "Circle" and UDim.new(1, 0) or UDim.new(0, 12)
local image = frame:FindFirstChild("ButtonSkinImage")
local imageCorner = image and image:FindFirstChildOfClass("UICorner")
if imageCorner then imageCorner.CornerRadius = corner.CornerRadius end
end
if MobilePanel then
for _, child in ipairs(MobilePanel:GetChildren()) do
if child:IsA("TextButton") then applyTo(child) end
end
end
if instaResetFloatingButton then applyTo(instaResetFloatingButton:FindFirstChild("Frame")) end
if antiBypassFloatingButton then applyTo(antiBypassFloatingButton:FindFirstChild("Frame")) end
end
function setButtonShape(shape)
applyButtonShape(shape)
saveAllSettings(true)
end
function paintFloatingBtn(btnFrame, active)
if not btnFrame then return end
-- UNO custom button skins (idle / active)
do
    local skin = btnFrame:FindFirstChild("ButtonSkinImage")
    local idleAsset = (type(buttonImageAssets) == "table" and buttonImageAssets[tonumber(buttonImageIndex) or 2]) or nil
    if skin and type(idleAsset) == "string" and idleAsset ~= "DEFAULT" then
        if active and type(buttonImageActiveAsset) == "string" and buttonImageActiveAsset ~= "" then
            skin.Image = buttonImageActiveAsset
        else
            skin.Image = idleAsset
        end
        skin.Visible = true
        skin.ImageTransparency = 0
        skin.ScaleType = Enum.ScaleType.Stretch
        skin.ImageRectSize = Vector2.zero
        skin.ImageRectOffset = Vector2.zero
    end
end
local bg = btnFrame:FindFirstChild("BtnGrad")
local label = btnFrame:FindFirstChild("TextLabel")
local stroke = btnFrame:FindFirstChildOfClass("UIStroke")
local icon = btnFrame:FindFirstChild("BtnIcon")
if icon then icon.Visible = false end
local pumpkin = btnFrame:FindFirstChild("PumpkinIcon")
if pumpkin then pcall(function() pumpkin:Destroy() end) end
local sheen = btnFrame:FindFirstChild("UNOSheen")
if not sheen then
sheen = Instance.new("Frame")
sheen.Name = "UNOSheen"
sheen.Size = UDim2.new(0.72, 0, 0, 1)
sheen.Position = UDim2.new(0.14, 0, 0, 3)
sheen.BorderSizePixel = 0
sheen.BackgroundColor3 = Color3.fromRGB(200, 240, 255)
sheen.BackgroundTransparency = 0.55
sheen.ZIndex = (btnFrame.ZIndex or 10) + 2
sheen.Parent = btnFrame
Instance.new("UICorner", sheen).CornerRadius = UDim.new(1, 0)
end
local theme = (typeof(getThemeColor) == "function" and getThemeColor()) or Color3.fromRGB(205, 35, 55)
btnFrame.BackgroundTransparency = 0.04
if bg then
bg.Enabled = true
bg.Rotation = 118
end
if active then
btnFrame.BackgroundColor3 = theme:Lerp(Color3.fromRGB(4, 10, 20), 0.12)
if bg then
bg.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 235, 255)),
ColorSequenceKeypoint.new(0.40, theme),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 90, 160)),
})
end
if label then
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.4
label.TextStrokeColor3 = Color3.fromRGB(0, 30, 60)
label.Font = Enum.Font.GothamBlack
end
if stroke then
stroke.Color = Color3.fromRGB(220, 245, 255)
stroke.Thickness = 1.55
stroke.Transparency = 0.08
end
sheen.BackgroundTransparency = 0.35
else
btnFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
if bg then
bg.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(22, 32, 48)),
ColorSequenceKeypoint.new(0.50, Color3.fromRGB(10, 14, 22)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(4, 6, 12)),
})
end
if label then
label.TextColor3 = Color3.fromRGB(210, 225, 240)
label.TextStrokeTransparency = 0.65
label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
label.Font = Enum.Font.GothamBold
end
if stroke then
stroke.Color = Color3.fromRGB(56, 160, 230)
stroke.Thickness = 1.15
stroke.Transparency = 0.4
end
sheen.BackgroundTransparency = 0.7
end
end

function applyFloatingButtonScale()
for _, uiScale in ipairs(_floatingUIScales) do
if uiScale and uiScale.Parent then
uiScale.Scale = floatingButtonScale
end
end
end
local function drag(f, dragZoneHeight)
local dn, ds, sp, di = false, nil, nil, nil
local endConn = nil
local zone = dragZoneHeight or 99999
local function stopDrag()
local wasDragging = dn
dn = false
di = nil
if endConn then
endConn:Disconnect()
endConn = nil
end
if wasDragging then
    if MobilePanel then
        for _, btn in ipairs(MobilePanel:GetChildren()) do
            if btn:IsA("GuiObject") then
                pcall(function()
                    btn:SetAttribute("_NoxLockOX", nil)
                    btn:SetAttribute("_NoxLockOY", nil)
                    btn:SetAttribute("_NoxLockSX", nil)
                    btn:SetAttribute("_NoxLockSY", nil)
                end)
            end
        end
    end
    local bypassFrame = antiBypassFloatingButton and antiBypassFloatingButton:FindFirstChild("Frame")
    if bypassFrame then
        for _, attr in ipairs({"_NoxLockOX", "_NoxLockOY", "_NoxLockSX", "_NoxLockSY"}) do pcall(function() bypassFrame:SetAttribute(attr, nil) end) end
        antiBypassFloatingPos = {XScale=bypassFrame.Position.X.Scale, XOffset=bypassFrame.Position.X.Offset, YScale=bypassFrame.Position.Y.Scale, YOffset=bypassFrame.Position.Y.Offset, Layout="UpperRightSpecialV3"}
    end
    task.defer(function() pcall(saveAllSettings, true) end)
end
end
f.InputBegan:Connect(function(i)
if uiLocked then return end
if _isDraggingButton then return end
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
local framePos = f.AbsolutePosition
if i.Position.Y > framePos.Y + zone then return end
dn = true; ds = i.Position; sp = f.Position
if endConn then endConn:Disconnect() end
endConn = i.Changed:Connect(function()
if i.UserInputState == Enum.UserInputState.End then stopDrag() end
end)
end
end)
f.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
stopDrag()
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
stopDrag()
end
end)
f.InputChanged:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
end)
UIS.InputChanged:Connect(function(i)
if i == di and dn then
if uiLocked then stopDrag(); return end
if _isDraggingButton then return end
if not ds or not sp then return end
local dX = (i.Position.X - ds.X)
local dY = (i.Position.Y - ds.Y)
local nX = sp.X.Offset + dX
local nY = sp.Y.Offset + dY
f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
-- All Lock: move every mobile/floating button by the same delta
if (allLockButtonsEnabled == true or _G.__NoxAllLockButtons == true) and MobilePanel then
    for _, btn in ipairs(MobilePanel:GetChildren()) do
        if btn:IsA("GuiObject") and btn ~= f then
            local bp = btn.Position
            -- store original on first move of this drag
            if not btn:GetAttribute("_NoxLockOX") then
                btn:SetAttribute("_NoxLockOX", bp.X.Offset)
                btn:SetAttribute("_NoxLockOY", bp.Y.Offset)
                btn:SetAttribute("_NoxLockSX", bp.X.Scale)
                btn:SetAttribute("_NoxLockSY", bp.Y.Scale)
            end
            local ox = btn:GetAttribute("_NoxLockOX") or bp.X.Offset
            local oy = btn:GetAttribute("_NoxLockOY") or bp.Y.Offset
            local sx = btn:GetAttribute("_NoxLockSX") or bp.X.Scale
            local sy = btn:GetAttribute("_NoxLockSY") or bp.Y.Scale
            btn.Position = UDim2.new(sx, ox + dX, sy, oy + dY)
        end
    end
    local bypassFrame = antiBypassFloatingButton and antiBypassFloatingButton:FindFirstChild("Frame")
    if bypassFrame and bypassFrame ~= f then
        if not bypassFrame:GetAttribute("_NoxLockOX") then
            bypassFrame:SetAttribute("_NoxLockOX", bypassFrame.Position.X.Offset)
            bypassFrame:SetAttribute("_NoxLockOY", bypassFrame.Position.Y.Offset)
            bypassFrame:SetAttribute("_NoxLockSX", bypassFrame.Position.X.Scale)
            bypassFrame:SetAttribute("_NoxLockSY", bypassFrame.Position.Y.Scale)
        end
        local sx = bypassFrame:GetAttribute("_NoxLockSX") or bypassFrame.Position.X.Scale
        local sy = bypassFrame:GetAttribute("_NoxLockSY") or bypassFrame.Position.Y.Scale
        local ox = bypassFrame:GetAttribute("_NoxLockOX") or bypassFrame.Position.X.Offset
        local oy = bypassFrame:GetAttribute("_NoxLockOY") or bypassFrame.Position.Y.Offset
        bypassFrame.Position = UDim2.new(sx, ox + dX, sy, oy + dY)
    end
end
end
end)
end

-- clear lock attrs on drag end is handled by stopDrag wrap below

_G.__YoutSpeedEngine = _G.__YoutSpeedEngine or { started = false, conn = nil }
_G.__YoutSpeedEngine.signal = nil
do
local _ok, _sig = pcall(function() return RunService.PreSimulation end)
_G.__YoutSpeedEngine.signal = (_ok and _sig) or RunService.Heartbeat
end
function _spd_isRagdollState(hum)
if not hum then return true end
local st = hum:GetState()
return hum.PlatformStand or st == Enum.HumanoidStateType.Physics
or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
end
function _spd_shouldUseStealSpeed(isStealing)
if speedMode then return true end
if isStealing and CONFIG.AUTO_STEAL_ENABLED then return true end
return false
end
function _spd_getSelectedBoostSpeed()
if laggerToggled or laggerCarryToggled then return LAGGER_SPEED end
return NS
end
function _spd_getSelectedStealSpeed()
if laggerCarryToggled then return LAGGER_CARRY_SPEED end
if laggerToggled then return LAGGER_SPEED end
return CS
end
function _spd_getTargetSpeed(isStealing)
if _spd_shouldUseStealSpeed(isStealing) then return _spd_getSelectedStealSpeed() end
return _spd_getSelectedBoostSpeed()
end
local function _spd_resetMovement()
lastMoveDir = _V3zero
_s2VelState.v = _V3new(0, _s2VelState.v.Y or 0, 0)
end
local function _spd_stop()
if _G.__YoutSpeedEngine.conn then
_G.__YoutSpeedEngine.conn:Disconnect()
_G.__YoutSpeedEngine.conn = nil
end
_spd_resetMovement()
end
function _spd_start()
_spd_stop()
_G.__YoutSpeedEngine.started = true
_G.__YoutSpeedEngine.acc = 0
_G.__YoutSpeedEngine.conn = _G.__YoutSpeedEngine.signal:Connect(function(dt)
_G.__YoutSpeedEngine.acc = (_G.__YoutSpeedEngine.acc or 0) + (dt or 0)
if _G.__YoutSpeedEngine.acc < 0.016 then return end
_G.__YoutSpeedEngine.acc = 0
local character = LP.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
if not humanoid or not root or humanoid.Health <= 0 then return end
if autoBatEnabled or autoLeftEnabled or autoRightEnabled
or dropActive or _G.IsDropping then
_spd_resetMovement()
return
end
if _spd_isRagdollState(humanoid) then
lastMoveDir = _V3zero
return
end
if _s2VelState.root ~= root or not _velChecked[root] then
lastMoveDir = _V3zero
_setupVelChecked(character)
_hookVelHRP(root)
end
local direction
if humanoid.MoveDirection.Magnitude > 0 then
lastMoveDir = humanoid.MoveDirection
direction = humanoid.MoveDirection
elseif lastMoveDir.Magnitude > 0 then
for key in pairs(MOVE_KEYS) do
if UIS:IsKeyDown(key) then
direction = lastMoveDir
break
end
end
end
local selectedSpeed = _spd_getTargetSpeed(LP:GetAttribute("Stealing") == true)
_applyVelocitySpeed(direction, tonumber(selectedSpeed) or 16, root)
end)
end
function _spd_applyNow()
local character = LP.Character
local hum = character and character:FindFirstChildOfClass("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
if not hum or not root or hum.Health <= 0 or _spd_isRagdollState(hum) then return end
local direction = hum.MoveDirection.Magnitude > 0.05 and hum.MoveDirection or nil
_applyVelocitySpeed(direction, _spd_getTargetSpeed(LP:GetAttribute("Stealing") == true), root)
end
function _spd_refresh()
_spd_start()
end
_G.__YoutRefreshSpeedEngine = _spd_refresh
_G.__YoutStopSpeedEngine = _spd_stop
_G.__YoutApplySpeedNow = _spd_applyNow
pcall(_spd_start)
LP.CharacterAdded:Connect(function(character)
task.wait(0.5)
_spd_resetMovement()
local root = character:WaitForChild("HumanoidRootPart", 5)
if root then _setupVelChecked(character); _hookVelHRP(root) end
_spd_start()
end)
LP.CharacterRemoving:Connect(function()
_spd_stop()
_s2VelState.root = nil
end)
function setupMovementAndIndicators(char)
if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
if movementLoop then movementLoop:Disconnect(); movementLoop = nil end
local ccAcc = 0
steppedConn = RunService.Heartbeat:Connect(function(dt)
ccAcc = ccAcc + dt
if ccAcc < 0.05 then return end
ccAcc = 0
local plist = _GetPlayersCached()
for i = 1, #plist do
local p = plist[i]
if p ~= LP then
local ch = p.Character
if ch then
local parts = ch:GetChildren()
for j = 1, #parts do
local part = parts[j]
if part:IsA("BasePart") and part.CanCollide then
part.CanCollide = false
end
end
end
end
end
end)
movementLoop = RunService.RenderStepped:Connect(function()
local char2 = LP.Character
if not char2 then return end
local hum = char2:FindFirstChildOfClass("Humanoid")
local hrp = char2:FindFirstChild("HumanoidRootPart")
if not hum or not hrp then return end
if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then
if _isRagdollState(hum) then
lastMoveDir = _V3zero
else
local md = hum.MoveDirection
if md.Magnitude > 0 then
lastMoveDir = md
end
end
end
if speedLabel then
local displaySpeed = getActiveMoveSpeed()
speedLabel.Text = string.format("%.1f  -  %s", displaySpeed, getSpeedModeName())
end
end)
setupSpeedIndicator(char)
startEnemySpeed()
end
local function refreshNoxMoveLockButton()
if not noxMoveLockButton or not noxMoveLockButton.Parent then return end
local locked = uiLocked == true
noxMoveLockButton.Text = locked and "🔒" or "🔓"
noxMoveLockButton.BackgroundColor3 = locked and Color3.fromRGB(36, 22, 48) or Color3.fromRGB(22, 16, 30)
noxMoveLockButton.TextColor3 = locked and Color3.fromRGB(205, 175, 235) or Color3.fromRGB(255, 255, 255)
local outline = noxMoveLockButton:FindFirstChild("LockOutline")
if outline then outline.Color = Color3.fromRGB(145, 95, 185) end
end
function toggleLockUI(state)
if state == nil then uiLocked = not uiLocked else uiLocked = state == true end
refreshNoxMoveLockButton()
if saveAllSettings then pcall(saveAllSettings, true) end
end
local function refreshControllerShiftControls()
if controllerShiftStateButton and controllerShiftStateButton.Parent then
controllerShiftStateButton.Text = controllerLockShiftEnabled and "LOCK SHIFT: ON" or "LOCK SHIFT: OFF"
controllerShiftStateButton.BackgroundColor3 = controllerLockShiftEnabled and Color3.fromRGB(92, 54, 125) or Color3.fromRGB(30, 22, 38)
end
if controllerShiftBindButton and controllerShiftBindButton.Parent then
controllerShiftBindButton.Text = controllerShiftListening and "PRESS BUTTON" or ((controllerLockShiftKey and controllerLockShiftKey.Name) or "ButtonR3")
end
end
function setControllerLockShift(state, suppressSave)
local enable = state == true
controllerLockShiftEnabled = enable
if controllerShiftRenderConn then pcall(function() controllerShiftRenderConn:Disconnect() end); controllerShiftRenderConn = nil end
if not enable then
local oldCharacter = controllerShiftCharacter
local oldHumanoid = oldCharacter and oldCharacter:FindFirstChildOfClass("Humanoid")
if oldHumanoid then
    if controllerShiftOriginalAutoRotate ~= nil then pcall(function() oldHumanoid.AutoRotate = controllerShiftOriginalAutoRotate end) end
    if controllerShiftOriginalCameraOffset then pcall(function() oldHumanoid.CameraOffset = controllerShiftOriginalCameraOffset end) end
end
controllerShiftCharacter = nil
controllerShiftOriginalAutoRotate = nil
controllerShiftOriginalCameraOffset = nil
else
local character = LP.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if character and humanoid then
    if controllerShiftCharacter ~= character then
        controllerShiftCharacter = character
        controllerShiftOriginalAutoRotate = humanoid.AutoRotate
        controllerShiftOriginalCameraOffset = humanoid.CameraOffset
    end
    pcall(function() humanoid.CameraOffset = Vector3.new(1.6, 0, 0); humanoid.AutoRotate = false end)
    controllerShiftRenderConn = RunService.RenderStepped:Connect(function()
        if not controllerLockShiftEnabled or LP.Character ~= character then return end
        local currentHumanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        if not currentHumanoid or not root or not camera then return end
        local look = camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.001 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook.Unit)
        end
    end)
end
end
refreshControllerShiftControls()
if not suppressSave and saveAllSettings then pcall(saveAllSettings, true) end
return controllerLockShiftEnabled
end
_G.__NoxControllerShiftCleanup = function()
    if controllerShiftRenderConn then pcall(function() controllerShiftRenderConn:Disconnect() end); controllerShiftRenderConn = nil end
    local oldCharacter = controllerShiftCharacter
    local oldHumanoid = oldCharacter and oldCharacter:FindFirstChildOfClass("Humanoid")
    if oldHumanoid then
        if controllerShiftOriginalAutoRotate ~= nil then pcall(function() oldHumanoid.AutoRotate = controllerShiftOriginalAutoRotate end) end
        if controllerShiftOriginalCameraOffset then pcall(function() oldHumanoid.CameraOffset = controllerShiftOriginalCameraOffset end) end
    end
    controllerLockShiftEnabled = false
end
if _G.__NoxControllerShiftRespawnConnection then pcall(function() _G.__NoxControllerShiftRespawnConnection:Disconnect() end) end
_G.__NoxControllerShiftRespawnConnection = LP.CharacterAdded:Connect(function()
    task.delay(0.35, function()
        if controllerLockShiftEnabled then setControllerLockShift(true, true) end
    end)
end)
function disableAllAimbots()
if autoBatEnabled then
disableAutoBat()
if autoBatSetVisual then autoBatSetVisual(false) end
if mobSetAutoBat then mobSetAutoBat(false) end
end
end
function stopAllBackgroundTasks()
if movementLoop then movementLoop:Disconnect(); movementLoop = nil end
if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
stopEnemySpeed()
if stretchEnabled then disableStretch() end
if stretchConn then stretchConn:Disconnect(); stretchConn = nil end
if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end
if AntiRagdollV2.Enabled then stopAntiRagdollV2() end
if antiDieEnabled then AntiDieModule.stop() end
if antiBatEnabled then stopAntiBat() end
if antiFlingEnabled then stopAntiFling() end
stopBatCounter()
stopBatCounterV2()
stopMedusaCounter()
stopAutoSteal()
if stopAutoCarry then stopAutoCarry(true) end
if setAutoSpinEnabled then setAutoSpinEnabled(false) end
disableAutoBat()
stopAutoLeft()
stopAutoRight()
if antiLagEnabled then disableAntiLag() end
if espEnabled then toggleESP(false) end
if espLineEnabled then stopESPLine() end
if dropActive then stopDropBrainrot() end
if bodyLockEnabled then stopBodyLock() end
_blSuppressCount = 0
_blWasEnabled = false
if _blRestoreTimer then pcall(task.cancel, _blRestoreTimer); _blRestoreTimer = nil end
if _bodyLockConn then _bodyLockConn:Disconnect(); _bodyLockConn = nil end
for _, t in ipairs(dropConnections) do
if type(t) == "thread" then pcall(task.cancel, t)
elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
end
dropConnections = {}
dropActive = false
alPhase = 1
arPhase = 1
lastDropTime = 0
medusaDebounce = false
medusaLastUsed = 0
if _G.__YoutStopSpeedEngine then pcall(_G.__YoutStopSpeedEngine) end
end
local _youtConfigReady = false
local _youtSaveState = {lastAt = 0, queued = false, writing = false, revision = 0}
local function resolveYoutFileApi()
    local env = (getgenv and getgenv()) or _G
    local readCandidates = {readfile, syn and syn.readfile, env.readfile}
    local writeCandidates = {writefile, syn and syn.writefile, env.writefile}
    local readFn, writeFn
    for _, fn in pairs(readCandidates) do if type(fn) == "function" then readFn = fn; break end end
    for _, fn in pairs(writeCandidates) do if type(fn) == "function" then writeFn = fn; break end end
    return readFn, writeFn
end

local function youtFileExists(path)
    local readFn = resolveYoutFileApi()
    if not readFn then return false end
    local ok, data = pcall(readFn, path)
    return ok and type(data) == "string"
end
function buildConfigTable()
local config = {
normalSpeed = NS, carrySpeed = CS,
laggerSpeed1 = LAGGER_SPEED, laggerSpeed2 = LAGGER_CARRY_SPEED,
stealRadius = CONFIG.STEAL_RANGE,
antiRagdollMode = antiRagdollMode, antiDieEnabled = antiDieEnabled,
antiBatEnabled = antiBatEnabled,
antiBat = antiBatEnabled,
instantResetVersion = instantResetVersion,
stealBarStyle = stealBarStyle,
selectedBatAimMode = selectedBatAimMode or selectedAimbotMode,
aimbotSpeedMode = aimbotSpeedMode,
aimbotLaggerSpeed = AIMBOT_LAGGER_SPEED,
bypassAimbotVersion = bypassAimbotVersion, selectedAimbotMode = selectedAimbotMode,
infJump = InfiniteJump.enabled,
antiFling = antiFlingEnabled,
antiBypassEnabled = antiBypassEnabled,
autoBat = autoBatEnabled, autoLeft = autoLeftEnabled, autoRight = autoRightEnabled,
selectedStealMode = selectedStealMode,
autoSteal = CONFIG.AUTO_STEAL_ENABLED,
medusaCounter = medusaCounterEnabled, batCounter = batCounterEnabled,
batCounterV2 = batCounterV2Enabled,
laggerToggled = laggerToggled, laggerCarryToggled = laggerCarryToggled,
carryMode = speedMode, autoBrainrotSpeedEnabled = autoBrainrotSpeedEnabled, autoSpinEnabled = autoSpinEnabled, spinBotSpeed = SPIN_BOT_SPEED, safeModeEnabled = safeModeEnabled, flingShieldEnabled = flingShieldEnabled, autoResetOnMedEnabled = autoResetOnMedEnabled, playerESPEnabled = playerESPEnabled, tracerESPEnabled = tracerESPEnabled, allLockButtonsEnabled = allLockButtonsEnabled, autoSaveEnabled = autoSaveEnabled,
batAimbotSpeed = BAT_AIMBOT_SPEED,
dropMode = dropMode,
uiFont = _G.__NoxUiFont or "Gotham",
infiniteJump = InfiniteJump and InfiniteJump.isRunning and InfiniteJump.isRunning() or false,
speedHoldInfJump = SpeedHoldInfJump and SpeedHoldInfJump.enabled == true,
 stretchEnabled = stretchEnabled, stretchFOV = stretchFOV, cameraFOV = cameraFOV,
uiScale = uiScaleValue, animPack = currentAnimPack, controllerLockShiftEnabled = controllerLockShiftEnabled, controllerLockShiftKey = controllerLockShiftKey and controllerLockShiftKey.Name or "ButtonR3",
espEnabled = espEnabled,
espLineEnabled = espLineEnabled,
vividGraphics = vividGraphicsEnabled,
hideButtons = hideButtonsEnabled,
antiLag = antiLagEnabled,
skyTheme = skyTheme, mobileButtonPositions = savedButtonPositions,
warningHighPing = warningHighPingEnabled, buttonShape = buttonShapeMode,
spamBat = spamBatEnabled, distanceRing = distanceRingEnabled,
dropBrainrotKey = {kb = KB.DropBrainrot.kb and KB.DropBrainrot.kb.Name, gp = KB.DropBrainrot.gp and KB.DropBrainrot.gp.Name},
autoLeftKey = {kb = KB.AutoLeft.kb and KB.AutoLeft.kb.Name, gp = KB.AutoLeft.gp and KB.AutoLeft.gp.Name},
autoRightKey = {kb = KB.AutoRight.kb and KB.AutoRight.kb.Name, gp = KB.AutoRight.gp and KB.AutoRight.gp.Name},
autoBatKey = {kb = KB.AutoBat.kb and KB.AutoBat.kb.Name, gp = KB.AutoBat.gp and KB.AutoBat.gp.Name},
tpFloorKey = {kb = KB.TPFloor.kb and KB.TPFloor.kb.Name, gp = KB.TPFloor.gp and KB.TPFloor.gp.Name},
guiHideKey = {kb = KB.GuiHide.kb and KB.GuiHide.kb.Name, gp = KB.GuiHide.gp and KB.GuiHide.gp.Name},
carryToggleKey = {kb = KB.CarryToggle.kb and KB.CarryToggle.kb.Name, gp = KB.CarryToggle.gp and KB.CarryToggle.gp.Name},
laggerModeKey = {kb = KB.LaggerMode.kb and KB.LaggerMode.kb.Name, gp = KB.LaggerMode.gp and KB.LaggerMode.gp.Name},
instaResetKey = {kb = KB.InstaReset.kb and KB.InstaReset.kb.Name, gp = KB.InstaReset.gp and KB.InstaReset.gp.Name},
antiBypassKey = {kb = KB.AntiBypass.kb and KB.AntiBypass.kb.Name, gp = KB.AntiBypass.gp and KB.AntiBypass.gp.Name},
antiBypassSpeed = ANTI_BYPASS_SPEED,
antiBypassFloatingPos = antiBypassFloatingPos,
instaResetFloatingPos = instaResetFloatingPos,
bodyLockEnabled = bodyLockEnabled, bodyLockRange = bodyLockRange,
progressBarPos = savedProgressBarPos, horizontalAutoSteal = true, menuLeftTall = true, lockUI = uiLocked, menuPositionLowered = true,
backgroundIndex = backgroundIndex,
backgroundImageTransparency = backgroundImageTransparency,
backgroundMode = backgroundMode,
buttonImageIndex = buttonImageIndex,
backgroundColorMatch = backgroundColorMatch,
stealBarMatch = stealBarMatch,
kickWarning = kickWarningEnabled,
ragdollCountdown = ragdollCountdownEnabled,
ragdollSteal = ragdollStealEnabled,
floatingButtonScale = floatingButtonScale, introStyle = introStyle or selectedIntroStyle or 2,
outfitIndex = currentOutfitIndex, themeColor = currentColorTheme,
}
if main then
local basePos = _G.__YoutMainOriginalPos or main.Position
config.mainPosition = {
XScale = basePos.X.Scale,
XOffset = basePos.X.Offset,
YScale = basePos.Y.Scale,
YOffset = basePos.Y.Offset,
}
end
if pbFrame then
config.progressBarPos = {XScale = pbFrame.Position.X.Scale, XOffset = pbFrame.Position.X.Offset, YScale = pbFrame.Position.Y.Scale, YOffset = pbFrame.Position.Y.Offset}
end
if MobilePanel then
config.mobilePanelPos = {XScale = 0, XOffset = 10, YScale = 0, YOffset = 0}
for _, btn in ipairs(MobilePanel:GetChildren()) do
if btn:IsA("TextButton") then
savedButtonPositions[btn.Name] = {X = btn.Position.X.Offset, Y = btn.Position.Y.Offset, XScale = btn.Position.X.Scale, YScale = btn.Position.Y.Scale, Layout = "UpperRightV2"}
end
end
config.mobileButtonPositions = savedButtonPositions
end
return config
end
function saveAllSettings(force)
    -- Ignore constructor/autosave calls until the existing config has been loaded once.
    if not _youtConfigReady then return false end
    if _isResetting or _isLoading then return true end
    local config = buildConfigTable()
    config.configVersion = 2
    config.userId = LP.UserId
    local encodedOk, settingsJSON = pcall(function() return HS:JSONEncode(config) end)
    if not encodedOk then return false end
    if not force and settingsJSON == _lastSavedJSON then return true end
    if _youtSaveState.writing or (not force and _tick() - _youtSaveState.lastAt < 0.25) then
        if not _youtSaveState.queued then
            _youtSaveState.queued = true
            task.delay(0.25, function()
                _youtSaveState.queued = false
                saveAllSettings(true)
            end)
        end
        return true
    end
    local readFn, writeFn = resolveYoutFileApi()
    if not readFn or not writeFn then
        warn("[Y-out Save] Executor file API is unavailable.")
        return false
    end
    _youtSaveState.writing = true
    _youtSaveState.revision = _youtSaveState.revision + 1
    config.revision = _youtSaveState.revision
    config.savedAt = os.time()
    local json = HS:JSONEncode(config)
    local ok = pcall(function()
        if youtFileExists(CONFIG_FILE) then
            local previous = readFn(CONFIG_FILE)
            if type(previous) == "string" then writeFn(CONFIG_FILE .. ".backup", previous) end
        end
        writeFn(CONFIG_FILE, json)
        local readBack = readFn(CONFIG_FILE)
        if readBack ~= json then error("save verification failed") end
        HS:JSONDecode(readBack)
    end)
    _youtSaveState.writing = false
    _youtSaveState.lastAt = _tick()
    if ok then
        _lastSavedJSON = settingsJSON
    else
        warn("[Y-out Save] Write or verification failed.")
    end
    return ok
end

do
    local readFn, writeFn = resolveYoutFileApi()
    if readFn and writeFn then
        local oldPath = "BloodHounds_" .. tostring(LP.UserId) .. ".json"
        local okOld, old = pcall(readFn, oldPath)
        local okNew, _ = pcall(readFn, CONFIG_FILE)
        if okOld and type(old) == "string" and not okNew then
            pcall(writeFn, CONFIG_FILE, old)
            warn("[Yout] Config migrada de " .. oldPath .. " a " .. CONFIG_FILE)
        end
    end
end
function loadAllSettings()
local readFn = resolveYoutFileApi()
if not readFn or not youtFileExists(CONFIG_FILE) then return false end
local success, data = pcall(function() return HS:JSONDecode(readFn(CONFIG_FILE)) end)
if not success or not data then return false end
_isLoading = true
NS = data.normalSpeed or NS
CS = data.carrySpeed or CS
LAGGER_SPEED = data.laggerSpeed1 or LAGGER_SPEED
LAGGER_CARRY_SPEED = data.laggerSpeed2 or LAGGER_CARRY_SPEED
CONFIG.STEAL_RANGE = data.stealRadius or CONFIG.STEAL_RANGE
if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
if tonumber(data.configVersion) >= 2 and data.lockUI ~= nil then
uiLocked = data.lockUI
else
uiLocked = false
end
mobileButtonsLocked = false
if data.antiRagdollMode then
antiRagdollMode = data.antiRagdollMode
else
antiRagdollMode = data.antiRagdoll and "v2" or "off"
end
antiDieEnabled = data.antiDieEnabled == true
warningHighPingEnabled = data.warningHighPing == true
spamBatEnabled = data.spamBat == true
distanceRingEnabled = data.distanceRing == true
if spamBatEnabled then task.defer(function() pcall(toggleSpamBat, true) end) end
buttonShapeMode = (data.buttonShape == "Circle") and "Circle" or "Square"
antiBatEnabled = (data.antiBat == true)
if data.instantResetVersion == "V2" or data.instantResetVersion == "V1" then instantResetVersion = data.instantResetVersion end
if data.stealBarStyle == "V2" or data.stealBarStyle == "V1" then stealBarStyle = data.stealBarStyle end
pcall(function() if applyStealBarStyle then applyStealBarStyle(stealBarStyle) end end)
if data.selectedBatAimMode == "v2" or data.selectedBatAimMode == "v3" then selectedBatAimMode = data.selectedBatAimMode; selectedAimbotMode = data.selectedBatAimMode end
if data.aimbotSpeedMode == "lagger" or data.aimbotSpeedMode == "normal" then aimbotSpeedMode = data.aimbotSpeedMode end
if data.aimbotLaggerSpeed then AIMBOT_LAGGER_SPEED = tonumber(data.aimbotLaggerSpeed) or AIMBOT_LAGGER_SPEED end
if data.bypassAimbotVersion then bypassAimbotVersion = tostring(data.bypassAimbotVersion) end
if data.selectedAimbotMode then selectedAimbotMode = tostring(data.selectedAimbotMode) end
if data.infJump == true then pcall(function() InfiniteJump.start() end) elseif data.infJump == false then pcall(function() InfiniteJump.stop() end) end
antiFlingEnabled = data.antiFling == true
antiBypassEnabled = data.antiBypassEnabled == true
if data.bypassAimbotVersion == "v1" or data.bypassAimbotVersion == "v2" then bypassAimbotVersion = data.bypassAimbotVersion end
selectedStealMode = (data.selectedStealMode == "V2") and "V2" or "V1"
Steal.StealRadius = CONFIG.STEAL_RANGE
if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
CONFIG.AUTO_STEAL_ENABLED = data.autoSteal == true
medusaCounterEnabled = data.medusaCounter == true
kickWarningEnabled = data.kickWarning == nil and kickWarningEnabled or data.kickWarning == true
ragdollCountdownEnabled = data.ragdollCountdown == nil and ragdollCountdownEnabled or data.ragdollCountdown == true
ragdollStealEnabled = data.ragdollSteal == nil and ragdollStealEnabled or data.ragdollSteal == true
backgroundColorMatch = data.backgroundColorMatch == true
stealBarMatch = data.stealBarMatch == true
batCounterEnabled = data.batCounter == true
batCounterV2Enabled = data.batCounterV2 == true
antiLagEnabled = data.antiLag == true
laggerToggled = data.laggerToggled or false
speedMode = data.carryMode or false
autoBrainrotSpeedEnabled = data.autoBrainrotSpeedEnabled == true or data.autoCarryEnabled == true
autoSpinEnabled = data.autoSpinEnabled == true
safeModeEnabled = data.safeModeEnabled == true
flingShieldEnabled = data.flingShieldEnabled == true
autoResetOnMedEnabled = data.autoResetOnMedEnabled == true
playerESPEnabled = data.playerESPEnabled == true
tracerESPEnabled = data.tracerESPEnabled == true
allLockButtonsEnabled = data.allLockButtonsEnabled == true
if data.autoSaveEnabled ~= nil then autoSaveEnabled = data.autoSaveEnabled == true end
SPIN_BOT_SPEED = math.clamp(tonumber(data.spinBotSpeed) or SPIN_BOT_SPEED or 40, 1, 80)
laggerCarryToggled = data.laggerCarryToggled or false
uiScaleValue = _clamp(tonumber(data.uiScale) or 88, 50, 150)
if updateMainResponsiveScale then updateMainResponsiveScale() elseif mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
if pbScale then pbScale.Scale = math.clamp(uiScaleValue / 100, 0.60, 1.20) end
espEnabled = data.espEnabled or false
espLineEnabled = data.espLineEnabled or false
if espEnabled then pcall(toggleESP, true) else pcall(toggleESP, false) end
vividGraphicsEnabled = data.vividGraphics == true
hideButtonsEnabled = data.hideButtons == true
controllerLockShiftEnabled = data.controllerLockShiftEnabled == true
if type(data.controllerLockShiftKey) == "string" then
    local keyOk, savedKey = pcall(function() return Enum.KeyCode[data.controllerLockShiftKey] end)
    if keyOk and savedKey and tostring(savedKey.Name):match("^Button") then controllerLockShiftKey = savedKey end
end
local loadedTheme = data.themeColor or data.colorTheme or "UNO Purple"
if loadedTheme == "Blue" then loadedTheme = "UNO Purple" end
currentColorTheme = loadedTheme
selectedColor = COLOR_THEMES["Blue"] or Color3.fromRGB(205, 35, 55)
task.defer(function() updateAllUIThemeColors(selectedColor) end)
skyTheme = data.skyTheme or "Off"
if skyTheme ~= "Off" then pcall(applyCustomSky, skyTheme) end
if skySelectorLabel then skySelectorLabel.Text = skyTheme end
if data.animPack and ANIM_PACKS[data.animPack] then
pcall(startAnimPack, data.animPack)
else
currentAnimPack = "Off"
stopAnimPack()
end
local function lk(e, d)
if type(d) ~= "table" then return end
local savedKb = d.kb and Enum.KeyCode[d.kb]
local savedGp = d.gp and Enum.KeyCode[d.gp]
if savedKb then
e.kb = savedKb
e.gp = nil
elseif savedGp then
e.kb = nil
e.gp = savedGp
end
end
lk(KB.DropBrainrot, data.dropBrainrotKey)
lk(KB.AutoLeft, data.autoLeftKey)
lk(KB.AutoRight, data.autoRightKey)
lk(KB.AutoBat, data.autoBatKey)
lk(KB.TPFloor, data.tpFloorKey)
lk(KB.GuiHide, data.guiHideKey)
lk(KB.CarryToggle, data.carryToggleKey)
lk(KB.LaggerMode, data.laggerModeKey)
lk(KB.InstaReset, data.instaResetKey)
lk(KB.AntiBypass, data.antiBypassKey)
if data.antiBypassSpeed then ANTI_BYPASS_SPEED = tonumber(data.antiBypassSpeed) or ANTI_BYPASS_SPEED end
if data.antiBypassFloatingPos then antiBypassFloatingPos = data.antiBypassFloatingPos end
if data.mobileButtonPositions then savedButtonPositions = data.mobileButtonPositions end
if data.mobilePanelPos then savedMobilePanelPos = data.mobilePanelPos end
if main then
    if data.menuLeftTall == true and data.mainPosition then
        main.Position = UDim2.new(data.mainPosition.XScale or 0, data.mainPosition.XOffset or 12, data.mainPosition.YScale or 0, data.mainPosition.YOffset or 48)
    else
        main.Position = UDim2.new(0, 12, 0, 48)
        noxMenuPositionMigrated = true
        if uiScaleValue < 78 then uiScaleValue = 88 end
        if updateMainResponsiveScale then updateMainResponsiveScale() end
    end
end
if data.instaResetFloatingPos then instaResetFloatingPos = data.instaResetFloatingPos end
if data.progressBarPos and data.horizontalAutoSteal == true then savedProgressBarPos = data.progressBarPos else savedProgressBarPos = nil end
if data.bodyLockEnabled ~= nil then
bodyLockEnabled = data.bodyLockEnabled
if bodyLockEnabled then
task.defer(function()
if bodyLockSetVisual then bodyLockSetVisual(true) end
startBodyLock()
end)
end
end
if data.bodyLockRange then
bodyLockRange = data.bodyLockRange
if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
end
dropMode = data.dropMode or 1
if data.uiFont then _G.__NoxUiFont = data.uiFont end
if data.infiniteJump then pcall(function() InfiniteJump.start() end) elseif data.infiniteJump == false then pcall(function() InfiniteJump.stop() end) end
if data.speedHoldInfJump then pcall(startSpeedHoldInfJump) else pcall(stopSpeedHoldInfJump) end
stretchEnabled = data.stretchEnabled == true
stretchFOV = tonumber(data.stretchFOV) or stretchFOV or 120
cameraFOV = tonumber(data.cameraFOV) or cameraFOV or 70
BAT_AIMBOT_SPEED = data.batAimbotSpeed or BAT_AIMBOT_SPEED or 58
backgroundIndex = 1
if type(backgroundImages) == "table" and #backgroundImages > 0 then
    backgroundIndex = math.clamp(math.floor(tonumber(data.backgroundIndex) or 1), 1, #backgroundImages)
end
backgroundImageTransparency = tonumber(data.backgroundImageTransparency) or 0
if backgroundImageTransparency >= 1 then backgroundImageTransparency = 0 end
backgroundMode = data.backgroundMode or "Image"
buttonImageIndex = 2
if type(buttonImageAssets) == "table" and #buttonImageAssets > 0 then
    buttonImageIndex = math.clamp(math.floor(tonumber(data.buttonImageIndex) or 2), 1, #buttonImageAssets)
end
floatingButtonScale = tonumber(data.floatingButtonScale) or 1
if data.introStyle ~= nil then
    local v = tonumber(data.introStyle) or data.introStyle
    introStyle = (v == 1 or v == "1") and 1 or 2
    selectedIntroStyle = introStyle
end
if introStyleLabel then introStyleLabel.Text = "INTRO " .. tostring(introStyle or 2) end
if buttonScaleLabel then buttonScaleLabel.Text = string.format("%.0f%%", (floatingButtonScale or 1) * 100) end
if applyFloatingButtonScale then pcall(applyFloatingButtonScale) end
if data.outfitIndex and data.outfitIndex >= 1 and data.outfitIndex <= #OUTFITS then
currentOutfitIndex = data.outfitIndex
task.defer(function()
pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
if outfitSelectorLabel then
outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label
end
end)
end
if _G._youtStealModeSetter then
task.defer(function() _G._youtStealModeSetter(selectedStealMode) end)
end
if vividGraphicsEnabled then
task.defer(function() pcall(enableVividGraphics) end)
else
task.defer(function() pcall(disableVividGraphics) end)
end
autoBatEnabled = data.autoBat == true
autoLeftEnabled = data.autoLeft == true
autoRightEnabled = data.autoRight == true
-- These modes are mutually exclusive; keep only one active if an old file has conflicts.
if antiBypassEnabled then autoBatEnabled = false end
if autoBatEnabled then autoLeftEnabled = false; autoRightEnabled = false
elseif autoLeftEnabled then autoRightEnabled = false end
if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
refreshSpeedModeLabel()
local cacheOk, cachedJson = pcall(function() return HS:JSONEncode(buildConfigTable()) end)
_lastSavedJSON = cacheOk and cachedJson or nil
_isLoading = false
return true
end
function forceResetUI()
if normalBox then normalBox.Text = tostring(NS) end
if carryBox then carryBox.Text = tostring(CS) end
if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED) end
if lagger2Box then lagger2Box.Text = tostring(LAGGER_CARRY_SPEED) end
if batSpeedBox then batSpeedBox.Text = tostring(getAimbotChaseSpeed()) end
if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
local function safeSet(fn, val) if fn then fn(val) end end
safeSet(autoCarrySetVisual, false)
if autoCarryModeLabel then autoCarryModeLabel.Text = "WHEN NEAR" end
safeSet(autoBatSetVisual, false)
safeSet(autoLeftSetVisual, false)
safeSet(autoRightSetVisual, false)
safeSet(setBatCounterVisual, false)
safeSet(setBatCounterV2Visual, false)
safeSet(setMedusaVisual, false)
safeSet(setAntiLagVisual, false)
safeSet(setLockUIVisual, false)
safeSet(setInstaGrab, false)
safeSet(setWarningHighPingVisual, false)
warningHighPingEnabled = false
setButtonShape("Square")
safeSet(setESPVIsual, false)
safeSet(setESPLineVisual, false)
safeSet(setVividVisual, false)
safeSet(setHideButtonsVisual, false)
safeSet(bodyLockSetVisual, false)
safeSet(setAntiDieVisual, false)
safeSet(setAntiBatVisual, false)
safeSet(setAntiFlingVisual, false)
safeSet(setAntiRagVisual, false)
backgroundColorMatch = false
stealBarMatch = false
backgroundIndex = 1
backgroundImageTransparency = 0
backgroundMode = "Image"
kickWarningEnabled = true
ragdollCountdownEnabled = true
ragdollStealEnabled = true
safeSet(backgroundColorMatchVisual, false)
safeSet(stealBarMatchVisual, false)
safeSet(kickWarningVisual, true)
safeSet(ragdollCountdownVisual, true)
safeSet(ragdollStealVisual, true)
if _G._NoxSetKickWarningEnabled then pcall(_G._NoxSetKickWarningEnabled, true) end
if _G._NoxSetRagdollCountdownEnabled then pcall(_G._NoxSetRagdollCountdownEnabled, true) end
if _G._NoxRagdollStealSync then pcall(_G._NoxRagdollStealSync) end
pcall(applyBackgroundMode, "Image")
refreshBackgroundButtons()
applyStealBarMatch()
disableVividGraphics()
applyHideButtons(false)
if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
safeSet(mobSetAutoBat, false)
safeSet(mobSetAutoLeft, false)
safeSet(mobSetAutoRight, false)
safeSet(mobSetDropBR, false)
safeSet(mobSetTpDown, false)
safeSet(mobSetCarry, false)
safeSet(mobSetLagger1, false)
safeSet(mobSetLagger2, false)
refreshSpeedModeLabel()
updateProgressBarVisibility()
disableAntiLag()
if stopAntiBat then stopAntiBat() end
if stopAntiFling then stopAntiFling() end
if stopESPLine then stopESPLine() end
skyTheme = "Off"
pcall(applyCustomSky, "Off")
if skySelectorLabel then skySelectorLabel.Text = "Off" end
if antiDieEnabled then
AntiDieModule.stop()
antiDieEnabled = false
end
for _, ref in ipairs(keyButtonRefs) do
local entry = ref.entry
local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
ref.btn.Text = label
end
currentColorTheme = "Christmas"
selectedColor = Color3.fromRGB(205, 35, 55)
updateAllUIThemeColors(selectedColor)
if miniBtn then
local stroke = miniBtn:FindFirstChildOfClass("UIStroke")
if stroke then stroke.Color = Color3.fromRGB(42, 43, 47) end
end
if MobilePanel then
for _, btn in ipairs(MobilePanel:GetChildren()) do
if btn:IsA("TextButton") then
local label = btn:FindFirstChildOfClass("TextLabel")
if label then
local isActive = btn.BackgroundColor3 == selectedColor
if not isActive then label.TextColor3 = selectedColor end
end
end
end
end
saveAllSettings(true)
end
function resetFloatingPositions()
if MobilePanel then
savedButtonPositions = {}
for _, btn in ipairs(MobilePanel:GetChildren()) do
if btn:IsA("TextButton") and btn.Name then
local defX, defY = getDefaultButtonPosition(btn.Name)
btn.Position = UDim2.new(1, defX, 0, defY)
end
end
end
if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then
local x, y = getDefaultSpecialButtonPosition("InstaReset")
instaResetFloatingButton.Frame.Position = UDim2.new(1, x, 0, y)
instaResetFloatingPos = nil
end
if antiBypassFloatingButton and antiBypassFloatingButton:FindFirstChild("Frame") then
local x, y = getDefaultSpecialButtonPosition("BatBypass")
antiBypassFloatingButton.Frame.Position = UDim2.new(1, x, 0, y)
antiBypassFloatingPos = nil
end
if pbFrame then
pbFrame.AnchorPoint = Vector2.new(0.5, 0.5)
pbFrame.Position = UDim2.new(0.5, 0, 0.82, 0)
savedProgressBarPos = nil
end
savedMobilePanelPos = nil
saveAllSettings(true)
end
function resetToFactoryDefaults()
_isResetting = true
local ok, err = pcall(function()
stopAutoSteal()
if stopAutoCarry then stopAutoCarry(false) end
if setAutoSpinEnabled then pcall(setAutoSpinEnabled, false) end
stopBatCounter()
stopBatCounterV2()
stopMedusaCounter()
if AntiRagdollV2.Enabled then stopAntiRagdollV2() end
if antiDieEnabled then AntiDieModule.stop() end
if antiBatEnabled and stopAntiBat then stopAntiBat() end
if antiFlingEnabled and stopAntiFling then stopAntiFling() end
disableAutoBat()
stopBodyLock()
if espEnabled then toggleESP(false) end
if espLineEnabled and stopESPLine then stopESPLine() end
if stretchEnabled then disableStretch() end
if antiLagEnabled then disableAntiLag() end
if vividGraphicsEnabled then disableVividGraphics() end
if hideButtonsEnabled then applyHideButtons(false) end
if dropActive then stopDropBrainrot() end
skyTheme = "Off"
pcall(applyCustomSky, "Off")
if skySelectorLabel then skySelectorLabel.Text = "Off" end
if antiDieEnabled then AntiDieModule.stop(); antiDieEnabled = false end
NS = 60; CS = 29; LAGGER_SPEED = 15; LAGGER_CARRY_SPEED = 24.5
CONFIG.STEAL_RANGE = 61
speedMode = false; laggerToggled = false; laggerCarryToggled = false
autoBrainrotSpeedEnabled = false; autoSpinEnabled = false; SPIN_BOT_SPEED = 40
antiRagdollMode = "off"; antiDieEnabled = false
antiBatEnabled = false
antiFlingEnabled = false
medusaCounterEnabled = false; batCounterEnabled = false; batCounterV2Enabled = false
autoBatEnabled = false; autoLeftEnabled = false; autoRightEnabled = false
antiLagEnabled = false
uiLocked = false; mobileButtonsLocked = false
controllerLockShiftKey = Enum.KeyCode.ButtonR3
setControllerLockShift(false, true)
CONFIG.AUTO_STEAL_ENABLED = false
selectedStealMode = "V1"
if _G._youtStealModeSetter then pcall(_G._youtStealModeSetter, "V1") end
BAT_AIMBOT_SPEED = 58
dropMode = 1; stretchEnabled = false; stretchFOV = 120
uiScaleValue = 88
if updateMainResponsiveScale then updateMainResponsiveScale() elseif mainUIScale then mainUIScale.Scale = 1 end
if pbScale then pbScale.Scale = math.clamp((uiScaleValue or 88) / 100, 0.60, 1.20) end
espEnabled = false; espLineEnabled = false; vividGraphicsEnabled = false; hideButtonsEnabled = false
bodyLockEnabled = false; bodyLockRange = 20
warningHighPingEnabled = false
kickWarningEnabled = true
ragdollCountdownEnabled = true
ragdollStealEnabled = true
backgroundColorMatch = false
stealBarMatch = false
buttonShapeMode = "Square"
backgroundIndex = 1; backgroundImageTransparency = 0; backgroundMode = "Image"
buttonImageIndex = 2
applyNoxButtonImage(buttonImageIndex or 2)
floatingButtonScale = 1
currentAnimPack = "Off"; stopAnimPack()
currentOutfitIndex = 1
currentColorTheme = "Christmas"; selectedColor = Color3.fromRGB(205, 35, 55)
if main then main.Position = UDim2.new(0, 12, 0, 48); _G.__YoutMainOriginalPos = main.Position end
for key, val in pairs(DEFAULT_KB) do
if KB[key] then KB[key].kb = val.kb; KB[key].gp = val.gp end
end
resetFloatingPositions()
forceResetUI()
updateProgressBarVisibility()
refreshSpeedModeLabel()
_lastSavedJSON = nil
end)
_isResetting = false
if not ok then warn("[resetToFactoryDefaults]", err) end
if ok then saveAllSettings(true) end
return ok
end
function updateProgressBarVisibility()
if pbFrame then pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED end
if stealBarMatch then pcall(applyStealBarMatch) end
end
function applyShimmerToText(obj, speed)
speed = speed or 0.8
local color = getThemeColor()
local grad = Instance.new("UIGradient", obj)
grad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, color),
ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200,200,200)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200,200,200)),
ColorSequenceKeypoint.new(1, color),
})
grad.Rotation = 45
grad.Offset = Vector2.new(0,0)
task.spawn(function()
local t = 0
while grad and grad.Parent do
t = t + 0.02
grad.Offset = Vector2.new(math.sin(t * speed) * 0.4, 0)
task.wait(0.04)
end
end)
return grad
end
function getDefaultButtonPosition(btnName)
local BTN_W, BTN_H = 54, 54
local GAP, RIGHT_MARGIN, TOP_MARGIN = 8, 12, 12
local GROUP_WIDTH = 2 * BTN_W + GAP
local orderMap = { DropBR = 0, AutoLeft = 1, AutoBat = 2, AutoRight = 3, TpDown = 4, Carry = 5, Lagger1 = 6, Lagger2 = 7, SpeedPlus = 8, SpeedMinus = 9 }
local order = orderMap[btnName] or 0
local row = _floor(order / 2)
local col = order % 2
local xOffset = -RIGHT_MARGIN - GROUP_WIDTH + col * (BTN_W + GAP)
return xOffset, TOP_MARGIN + row * (BTN_H + GAP)
end
function getDefaultSpecialButtonPosition(buttonName)
local specialX = -12 - (2 * 54 + 8) - 6 - 54
if buttonName == "InstaReset" then return specialX, 12 end
if buttonName == "BatBypass" then return specialX, 72 end
return specialX, 12
end
do
if not _G.InstaResetLoaded then
_G.InstaResetLoaded = true
local state = _G._YoutInstaResetState
if type(state) ~= "table" then
state = {
busy = false, busyAt = 0,
token = 0,
cameraConn = nil, cameraHeld = false, cameraHeldAt = 0,
speed = 1000000,
wantAntiDie = nil,
wantAntiBat = nil,
}
_G._YoutInstaResetState = state
end
local HOLD_TIME = 1.5
local FALLBACK = 1.2
local WAIT_RESPAWN = 8
local function suspendGuards()
if _antiDieEnabled then
state.wantAntiDie = true
pcall(function() _antiDieSetEnabled(false) end)
end
if AntiDieModule and AntiDieModule.enabled then
state.wantAntiDie = true
pcall(function() AntiDieModule.stop() end)
end
if antiBatEnabled then
state.wantAntiBat = true
pcall(stopAntiBat)
end
end
local function restoreGuards()
if state.wantAntiDie then
state.wantAntiDie = nil
pcall(function()
antiDieEnabled = true
if AntiDieModule then AntiDieModule.start() end
if _antiDieSetEnabled then _antiDieSetEnabled(true) end
end)
end
if state.wantAntiBat then
state.wantAntiBat = nil
pcall(function() if antiBatEnabled then startAntiBat() end end)
end
end
local function holdCamera(oldChar)
local cam = workspace.CurrentCamera
if not cam then return end
if state.cameraHeld and (os.clock() - (state.cameraHeldAt or 0)) < 5 then return end
state.cameraHeld = true
state.cameraHeldAt = os.clock()
local heldCFrame, heldFocus = cam.CFrame, cam.Focus
pcall(function()
cam.CameraType = Enum.CameraType.Scriptable
cam.CFrame = heldCFrame
cam.Focus = heldFocus
end)
state.cameraConn = RunService.RenderStepped:Connect(function()
if workspace.CurrentCamera ~= cam then return end
cam.CameraType = Enum.CameraType.Scriptable
cam.CFrame = heldCFrame
cam.Focus = heldFocus
end)
task.spawn(function()
local elapsed = 0
while LP.Character == oldChar and elapsed < 3 do
elapsed = elapsed + task.wait()
end
if state.cameraConn then
pcall(function() state.cameraConn:Disconnect() end)
state.cameraConn = nil
end
state.cameraHeld = false
local newCam = workspace.CurrentCamera or cam
if newCam then
pcall(function()
newCam.CameraType = Enum.CameraType.Custom
local newChar = LP.Character
local hum = newChar and newChar:FindFirstChildOfClass("Humanoid")
if hum then newCam.CameraSubject = hum end
end)
end
end)
end
local function flingUp(character)
local root = character and character:FindFirstChild("HumanoidRootPart")
if not (root and root:IsA("BasePart")) then return false end
local hum = character:FindFirstChildOfClass("Humanoid")
if hum then
pcall(function()
hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
hum.BreakJointsOnDeath = true
hum.PlatformStand = true
hum:ChangeState(Enum.HumanoidStateType.Freefall)
end)
end
local vel = Vector3.new(0, math.clamp(state.speed, 1000, 10000000), 0)
local function pulse()
if not root.Parent then return false end
return pcall(function()
root.AssemblyAngularVelocity = Vector3.zero
root.AssemblyLinearVelocity = vel
end)
end
if not pulse() then return false end
task.spawn(function()
local elapsed = 0
while elapsed < HOLD_TIME do
elapsed = elapsed + RunService.Heartbeat:Wait()
if not root.Parent then return end
if LP.Character ~= character then return end
pulse()
end
end)
return true
end
local function hardKill(character)
local hum = character and character:FindFirstChildOfClass("Humanoid")
if not hum then return end
pcall(function()
hum.PlatformStand = false
hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
hum.BreakJointsOnDeath = true
if hum.MaxHealth == math.huge or hum.MaxHealth <= 0 then hum.MaxHealth = 100 end
hum.Health = 0
end)
pcall(function() character:BreakJoints() end)
end
local function doReset()
local character = LP.Character
local hum = character and character:FindFirstChildOfClass("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
if not (character and hum and root and root:IsA("BasePart")) then
return
end
if state.busy and (os.clock() - (state.busyAt or 0)) < 5 then return end
state.busy = true
state.busyAt = os.clock()
state.token = (state.token or 0) + 1
local myToken = state.token
suspendGuards()
task.spawn(function()
holdCamera(character)
if not flingUp(character) then
hardKill(character)
end
local elapsed = 0
while LP.Character == character and elapsed < FALLBACK do
elapsed = elapsed + task.wait()
end
if LP.Character == character then
local hum2 = character:FindFirstChildOfClass("Humanoid")
if hum2 and hum2.Health > 0 then
hardKill(character)
end
end
local waited = 0
while LP.Character == character and waited < WAIT_RESPAWN do
waited = waited + task.wait()
end
if state.token ~= myToken then return end
state.busy = false
restoreGuards()
end)
end
RunService.Heartbeat:Connect(function()
if not state.wantAntiDie then return end
if state.busy and (os.clock() - (state.busyAt or 0)) < 10 then
if _antiDieEnabled then pcall(function() _antiDieSetEnabled(false) end) end
if AntiDieModule and AntiDieModule.enabled then pcall(function() AntiDieModule.stop() end) end
return
end
if (os.clock() - (state.busyAt or 0)) >= 10 then
state.busy = false
restoreGuards()
end
end)
LP.CharacterAdded:Connect(function()
state.cameraHeld = false
if state.cameraConn then
pcall(function() state.cameraConn:Disconnect() end)
state.cameraConn = nil
end
end)
local _lastRequest = 0
_G.InstaReset = {
Trigger = function()
local now = os.clock()
if now - _lastRequest < 0.15 then return end
_lastRequest = now
doReset()
end,
}
_G.VynxDoInstaReset = _G.InstaReset.Trigger
end
end

function openNoxAntiBatPanel()
if _G.__NoxAntiBatPanel and _G.__NoxAntiBatPanel.Parent then
_G.__NoxAntiBatPanel.Enabled = true
return
end
local pg = pgui or (LP and LP:FindFirstChild("PlayerGui"))
local screen = Instance.new("ScreenGui")
screen.Name = "NoxAntiBatPanel"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 50000
screen.Parent = (function()
local ok, cg = pcall(function() return game:GetService("CoreGui") end)
if ok and cg and pcall(function() local t=Instance.new("Folder"); t.Parent=cg; t:Destroy() end) then return cg end
return pg
end)()
_G.__NoxAntiBatPanel = screen
local box = Instance.new("Frame", screen)
box.Name = "Panel"
box.Size = UDim2.fromOffset(280, 200)
box.Position = UDim2.new(0.5, -140, 0.5, -100)
box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
box.BackgroundTransparency = 0
box.BorderSizePixel = 0
box.Active = true
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
local st = Instance.new("UIStroke", box)
st.Color = Color3.fromRGB(80, 80, 85)
st.Thickness = 1.5
local title = Instance.new("TextLabel", box)
title.Size = UDim2.new(0.6, 0, 0, 28)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.Text = "nox anti bat"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
local closeBtn = Instance.new("TextButton", box)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function()
screen.Enabled = false
end)
local lockOpen = true
local lockBtn = Instance.new("TextButton", box)
lockBtn.Size = UDim2.fromOffset(56, 24)
lockBtn.Position = UDim2.new(1, -100, 0, 10)
lockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
lockBtn.Text = "OPEN"
lockBtn.TextColor3 = Color3.fromRGB(80, 255, 160)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 11
lockBtn.BorderSizePixel = 0
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 6)
local dragging, dstart, pstart = false, nil, nil
lockBtn.MouseButton1Click:Connect(function()
lockOpen = not lockOpen
lockBtn.Text = lockOpen and "OPEN" or "LOCK"
lockBtn.TextColor3 = lockOpen and Color3.fromRGB(80, 255, 160) or Color3.fromRGB(255, 200, 60)
end)
box.InputBegan:Connect(function(inp)
if not lockOpen then return end
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
dragging = true
dstart = inp.Position
pstart = box.Position
end
end)
UIS.InputChanged:Connect(function(inp)
if not dragging or not lockOpen then return end
if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
local d = inp.Position - dstart
box.Position = UDim2.new(pstart.X.Scale, pstart.X.Offset + d.X, pstart.Y.Scale, pstart.Y.Offset + d.Y)
end)
UIS.InputEnded:Connect(function(inp)
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)
local function makeToggle(y, label, getOn, setOn)
local btn = Instance.new("TextButton", box)
btn.Size = UDim2.new(1, -24, 0, 40)
btn.Position = UDim2.fromOffset(12, y)
btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
btn.BorderSizePixel = 0
btn.Text = ""
btn.AutoButtonColor = false
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local lbl = Instance.new("TextLabel", btn)
lbl.Size = UDim2.new(0.65, 0, 1, 0)
lbl.Position = UDim2.fromOffset(12, 0)
lbl.BackgroundTransparency = 1
lbl.Text = label
lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 13
lbl.TextXAlignment = Enum.TextXAlignment.Left
local state = Instance.new("TextLabel", btn)
state.Size = UDim2.fromOffset(50, 24)
state.Position = UDim2.new(1, -60, 0.5, -12)
state.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
state.Text = getOn() and "ON" or "OFF"
state.TextColor3 = getOn() and Color3.fromRGB(80, 255, 160) or Color3.fromRGB(200, 200, 200)
state.Font = Enum.Font.GothamBlack
state.TextSize = 12
Instance.new("UICorner", state).CornerRadius = UDim.new(0, 6)
local function refresh()
local on = getOn()
state.Text = on and "ON" or "OFF"
state.TextColor3 = on and Color3.fromRGB(80, 255, 160) or Color3.fromRGB(200, 200, 200)
state.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
end
btn.MouseButton1Click:Connect(function()
setOn(not getOn())
refresh()
pcall(saveAllSettings, true)
end)
refresh()
end
makeToggle(52, "Anti Bat", function() return antiBatEnabled == true end, function(v)
antiBatEnabled = v
if v then startAntiBat() else stopAntiBat() end
end)
makeToggle(100, "Infinite Jump", function() return InfiniteJump.isRunning() end, function(v)
if v then InfiniteJump.start() else InfiniteJump.stop() end
end)
end

function buildGui()
local ROW_BG = Color3.fromRGB(28, 20, 36)
local ROW_BORDER = Color3.fromRGB(40,40,48)
local WHITE = Color3.fromRGB(255,255,255)
local INP = Color3.fromRGB(0,0,0)
local GUI_W, GUI_H = 370, 620
local GUI_NAMES = {"Yout", "NoxDuels", "YoutMobilePanel", "TpBatButton", "InstaResetButton",
"YoutSpeedIndicator", "YoutBootErrors"}
local _okCg, _coreGui = pcall(function() return game:GetService("CoreGui") end)
local _pgOld = LP:FindFirstChild("PlayerGui")
for _, n in ipairs(GUI_NAMES) do
if _okCg and _coreGui then
local okFind, oldCg = pcall(function() return _coreGui:FindFirstChild(n) end)
if okFind and oldCg then pcall(function() oldCg:Destroy() end) end
end
if _pgOld then
local okFind2, o = pcall(function() return _pgOld:FindFirstChild(n) end)
if okFind2 and o then pcall(function() o:Destroy() end) end
end
end
gui = Instance.new("ScreenGui")
gui.Name = "NoxDuels"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.IgnoreGuiInset = true
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
local guiOk = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not guiOk then gui.Parent = LP:WaitForChild("PlayerGui") end
main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
main.Position = UDim2.new(0, 12, 0, 48)
main.BackgroundColor3 = Color3.fromRGB(18, 12, 26)
main.BackgroundTransparency = 0.04
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
local mainWhiteBorder = Instance.new("UIStroke", main)
mainWhiteBorder.Name = "MainWhiteBorder"
mainWhiteBorder.Color = Color3.fromRGB(205, 35, 55)
mainWhiteBorder.Thickness = 1.55
mainWhiteBorder.Transparency = 0.22
do
local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BackgroundImage"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://128151913478635"
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 2
bgImage.ImageTransparency = 0
bgImage.Active = false
bgImage.Parent = main
end
local menuReadabilityOverlay = Instance.new("Frame", main)
menuReadabilityOverlay.Name = "MenuReadabilityOverlay"
menuReadabilityOverlay.Size = UDim2.new(1, 0, 1, 0)
menuReadabilityOverlay.Position = UDim2.new(0, 0, 0, 0)
menuReadabilityOverlay.BackgroundColor3 = Color3.fromRGB(2, 6, 14)
menuReadabilityOverlay.BackgroundTransparency = 0.42
menuReadabilityOverlay.BorderSizePixel = 0
menuReadabilityOverlay.Active = false
menuReadabilityOverlay.ZIndex = 3
Instance.new("UICorner", menuReadabilityOverlay).CornerRadius = UDim.new(0, 18)
local scriptHeader = Instance.new("Frame", main)
scriptHeader.Name = "ScriptHeader"
scriptHeader.Size = UDim2.new(1, -20, 0, 104)
scriptHeader.Position = UDim2.new(0, 10, 0, 0)
scriptHeader.BackgroundTransparency = 1
scriptHeader.BorderSizePixel = 0
scriptHeader.ClipsDescendants = true
scriptHeader.ZIndex = 8
Instance.new("UICorner", scriptHeader).CornerRadius = UDim.new(0, 13)
local scriptLogo = Instance.new("TextLabel", scriptHeader)
scriptLogo.Name = "ScriptLogo"
scriptLogo.AnchorPoint = Vector2.new(0.5, 0.5)
scriptLogo.Position = UDim2.new(0.5, 0, 0.42, 0)
scriptLogo.Size = UDim2.new(0, 160, 0, 48)
scriptLogo.BackgroundTransparency = 1
scriptLogo.Text = "UNO 🎄"
scriptLogo.TextColor3 = Color3.fromRGB(230, 245, 255)
scriptLogo.Font = Enum.Font.GothamBlack
scriptLogo.TextSize = 22
scriptLogo.TextStrokeColor3 = Color3.fromRGB(30, 140, 220)
scriptLogo.TextStrokeTransparency = 0.25
do
local menuInvite = Instance.new("TextLabel")
menuInvite.Name = "UNOMenuInvite"
menuInvite.Size = UDim2.new(0, 160, 0, 12)
menuInvite.AnchorPoint = Vector2.new(0.5, 0)
menuInvite.Position = UDim2.new(0.5, 0, 0.42, 22)
menuInvite.BackgroundTransparency = 1
menuInvite.Text = "https://discord.gg/HKkHgBv5V"
menuInvite.TextColor3 = Color3.fromRGB(120, 170, 210)
menuInvite.Font = Enum.Font.Gotham
menuInvite.TextSize = 8
menuInvite.TextXAlignment = Enum.TextXAlignment.Center
menuInvite.ZIndex = (scriptLogo.ZIndex or 10)
menuInvite.Parent = scriptHeader
end
scriptLogo.TextXAlignment = Enum.TextXAlignment.Center
scriptLogo.TextYAlignment = Enum.TextYAlignment.Center
scriptLogo.TextStrokeColor3 = Color3.fromRGB(145, 95, 185)
scriptLogo.TextStrokeTransparency = 0
scriptLogo.ZIndex = 10
local scriptName = Instance.new("TextLabel", scriptHeader)
scriptName.Name = "ScriptName"
scriptName.Size = UDim2.new(1, 0, 0, 22)
scriptName.Position = UDim2.new(0, 0, 1, -26)
scriptName.BackgroundTransparency = 1
scriptName.Text = "DUELS"
scriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptName.Font = Enum.Font.GothamBold
scriptName.TextSize = 16
scriptName.TextXAlignment = Enum.TextXAlignment.Center
scriptName.TextYAlignment = Enum.TextYAlignment.Center
scriptName.ZIndex = 10
local scriptIdLbl = Instance.new("TextLabel", scriptHeader)
scriptIdLbl.Name = "ScriptIdLabel"
scriptIdLbl.Visible = false
scriptIdLbl.Size = UDim2.new(1, 0, 0, 22)
scriptIdLbl.Position = UDim2.new(0, 0, 1, -28)
scriptIdLbl.BackgroundTransparency = 1
scriptIdLbl.Text = ""
scriptIdLbl.TextColor3 = Color3.fromRGB(145, 105, 180)
scriptIdLbl.Font = Enum.Font.GothamBold
scriptIdLbl.TextSize = 14
scriptIdLbl.TextXAlignment = Enum.TextXAlignment.Center
scriptIdLbl.TextYAlignment = Enum.TextYAlignment.Center
scriptIdLbl.ZIndex = 10
mainUIScale = Instance.new("UIScale", main)
mainUIScale.Scale = 1
local mainViewportConnection, mainCameraConnection
updateMainResponsiveScale = function()
    local camera = workspace.CurrentCamera
    local fit = 1
    if camera then
        local viewport = camera.ViewportSize
        fit = math.min((viewport.X - 24) / GUI_W, (viewport.Y - 72) / GUI_H)
    end
    fit = math.clamp(fit, 0.50, 1.15)
    local preference = math.clamp((tonumber(uiScaleValue) or 88) / 88, 0.55, 1.7)
    if mainUIScale then mainUIScale.Scale = math.clamp(fit * preference, 0.58, 1.15) end
end
local function bindMainViewport()
    if mainViewportConnection then mainViewportConnection:Disconnect(); mainViewportConnection = nil end
    local camera = workspace.CurrentCamera
    if camera then mainViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMainResponsiveScale) end
    updateMainResponsiveScale()
end
bindMainViewport()
mainCameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindMainViewport)
gui.Destroying:Connect(function()
    if mainViewportConnection then mainViewportConnection:Disconnect() end
    if mainCameraConnection then mainCameraConnection:Disconnect() end
end)
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 72)
closeBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
closeBtn.BackgroundTransparency = 1
closeBtn.BorderSizePixel = 0
closeBtn.Text = "-"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 30
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 200
noxMoveLockButton = Instance.new("TextButton", main)
noxMoveLockButton.Name = "MoveLockButton"
noxMoveLockButton.Size = UDim2.fromOffset(34, 34)
noxMoveLockButton.Position = UDim2.new(1, -42, 0, 8)
noxMoveLockButton.BorderSizePixel = 0
noxMoveLockButton.AutoButtonColor = false
noxMoveLockButton.Font = Enum.Font.GothamBold
noxMoveLockButton.TextSize = 19
noxMoveLockButton.ZIndex = 201
Instance.new("UICorner", noxMoveLockButton).CornerRadius = UDim.new(0, 9)
local noxLockOutline = Instance.new("UIStroke", noxMoveLockButton)
noxLockOutline.Name = "LockOutline"
noxLockOutline.Thickness = 1.2
noxLockOutline.Transparency = 0.15
refreshNoxMoveLockButton()
noxMoveLockButton.Activated:Connect(function() toggleLockUI() end)
closeBtn.MouseEnter:Connect(function()
TS:Create(closeBtn, TweenInfo.new(0.12), {TextColor3 = getThemeColor()}):Play()
end)
closeBtn.MouseLeave:Connect(function()
TS:Create(closeBtn, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
miniBtn = Instance.new("TextButton", gui)
miniBtn.Name = "MinimizedFrame"
miniBtn.Size = UDim2.new(0, 128, 0, 36)
miniBtn.Position = UDim2.new(0, 18, 0, 60)
miniBtn.BackgroundColor3 = Color3.fromRGB(6, 12, 20)
miniBtn.BackgroundTransparency = 0.05
miniBtn.BorderSizePixel = 0
miniBtn.Text = ""
miniBtn.AutoButtonColor = false
miniBtn.ZIndex = 20
miniBtn.Visible = false
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 10)
local miniGrad = Instance.new("UIGradient", miniBtn)
miniGrad.Rotation = 90
miniGrad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(18, 36, 58)),
ColorSequenceKeypoint.new(0.55, Color3.fromRGB(8, 14, 24)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(4, 8, 14)),
})
local miniStroke = Instance.new("UIStroke", miniBtn)
miniStroke.Color = Color3.fromRGB(205, 35, 55)
miniStroke.Thickness = 1.2
miniStroke.Transparency = 0.25
local miniTitle = Instance.new("TextLabel", miniBtn)
miniTitle.Name = "MiniTitle"
miniTitle.Size = UDim2.new(1, -8, 1, 0)
miniTitle.Position = UDim2.new(0, 4, 0, 0)
miniTitle.BackgroundTransparency = 1
miniTitle.Text = "UNO 🎄"
miniTitle.TextColor3 = Color3.fromRGB(205, 35, 55)
miniTitle.Font = Enum.Font.GothamBlack
miniTitle.TextSize = 11
miniTitle.TextXAlignment = Enum.TextXAlignment.Center
miniTitle.TextYAlignment = Enum.TextYAlignment.Center
miniTitle.TextStrokeColor3 = Color3.fromRGB(0, 30, 60)
miniTitle.TextStrokeTransparency = 0.4
miniTitle.ZIndex = 21
main.Visible = true
local _mainAnimating = false
local mainOriginalPos = main.Position
_G.__YoutMainOriginalPos = mainOriginalPos
main:GetPropertyChangedSignal("Position"):Connect(function()
if not _mainAnimating then
mainOriginalPos = main.Position
_G.__YoutMainOriginalPos = mainOriginalPos
end
end)
local mainDragHandle = Instance.new("TextButton", main)
mainDragHandle.Name = "MenuDragHandle"
mainDragHandle.Size = UDim2.new(1, -88, 0, 64)
mainDragHandle.Position = UDim2.new(0, 0, 0, 0)
mainDragHandle.BackgroundTransparency = 1
mainDragHandle.BorderSizePixel = 0
mainDragHandle.Text = ""
mainDragHandle.AutoButtonColor = false
mainDragHandle.Active = true
mainDragHandle.ZIndex = 9
local menuDragging, menuDragInput, menuDragStart, menuStartPos = false, nil, nil, nil
local menuDragConnections = {}
menuDragConnections[#menuDragConnections + 1] = mainDragHandle.InputBegan:Connect(function(input)
if uiLocked then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
menuDragging = true; menuDragInput = input; menuDragStart = input.Position; menuStartPos = main.Position
end
end)
menuDragConnections[#menuDragConnections + 1] = UIS.InputChanged:Connect(function(input)
if not menuDragging or uiLocked then return end
local touchMove = menuDragInput and menuDragInput.UserInputType == Enum.UserInputType.Touch and input == menuDragInput
local mouseMove = menuDragInput and menuDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
if not touchMove and not mouseMove then return end
local delta = input.Position - menuDragStart
main.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
end)
menuDragConnections[#menuDragConnections + 1] = UIS.InputEnded:Connect(function(input)
if not menuDragging then return end
local ended = input == menuDragInput or (menuDragInput and menuDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
if not ended then return end
menuDragging = false; menuDragInput = nil; menuDragStart = nil; menuStartPos = nil
if not uiLocked then pcall(saveAllSettings, true) end
end)
gui.Destroying:Connect(function()
for _, connection in ipairs(menuDragConnections) do pcall(function() connection:Disconnect() end) end
end)
local animScale = Instance.new("UIScale", main)
animScale.Scale = 1
local _openTween, _closeTween = nil, nil
showGui = function()
if not main then return end
if _openTween then _openTween:Cancel() end
if _closeTween then _closeTween:Cancel() end
_mainAnimating = true
main.Visible = true
miniBtn.Visible = false
main.Position = UDim2.new(mainOriginalPos.X.Scale, mainOriginalPos.X.Offset - 60, mainOriginalPos.Y.Scale, mainOriginalPos.Y.Offset)
animScale.Scale = 0.5
local info = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
_openTween = TS:Create(main, info, {Position = mainOriginalPos})
TS:Create(animScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
_openTween:Play()
_openTween.Completed:Connect(function()
_openTween = nil
_mainAnimating = false
end)
end
hideGui = function()
if not main or not main.Visible then return end
if _openTween then _openTween:Cancel() end
if _closeTween then _closeTween:Cancel() end
_mainAnimating = true
local targetPos = UDim2.new(mainOriginalPos.X.Scale, mainOriginalPos.X.Offset - 60, mainOriginalPos.Y.Scale, mainOriginalPos.Y.Offset)
local info = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
_closeTween = TS:Create(main, info, {Position = targetPos})
TS:Create(animScale, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.5}):Play()
_closeTween:Play()
_closeTween.Completed:Connect(function()
main.Visible = false
miniBtn.Visible = true
_closeTween = nil
_mainAnimating = false
end)
end
closeBtn.MouseButton1Click:Connect(hideGui)
miniBtn.MouseButton1Click:Connect(showGui)
local tabBar = Instance.new("Frame", main)
tabBar.Name = "TopTabs"
tabBar.Size = UDim2.new(1, -16, 0, 44)
tabBar.Position = UDim2.new(0, 8, 0, 108)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 10
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingLeft = UDim.new(0, 4); tabPad.PaddingRight = UDim.new(0, 4)
local tabContent = Instance.new("Frame", main)
tabContent.Size = UDim2.new(1, -16, 1, -168)
tabContent.Position = UDim2.new(0, 8, 0, 158)
tabContent.BackgroundTransparency = 1
tabContent.ClipsDescendants = true
tabContent.ZIndex = 5
local tabs = {"Speed", "Combat", "Steal", "Visual", "Config", "Keybinds"}
tabButtons = {}
local contentPages = {}
for i, name in ipairs(tabs) do
local btn = Instance.new("TextButton", tabBar)
btn.Size = UDim2.new(0.2, -6, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(35, 22, 48)
btn.BackgroundTransparency = 1
btn.BorderSizePixel = 0
btn.Text = name
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBlack
btn.TextSize = 12
btn.AutoButtonColor = false
btn.ZIndex = 11
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
local tabBgGrad = Instance.new("UIGradient", btn)
tabBgGrad.Name = "TabBgGrad"
tabBgGrad.Color = youtGradient(getThemeColor())
tabBgGrad.Rotation = 0
local tabStroke = Instance.new("UIStroke", btn)
tabStroke.Name = "TabStroke"
tabStroke.Color = getThemeColor()
tabStroke.Thickness = 1
tabStroke.Transparency = 1
tabStroke.Enabled = false
local underline = Instance.new("Frame", btn)
underline.Name = "Underline"
underline.Size = UDim2.new(0.6, 0, 0, 4)
underline.Position = UDim2.new(0.2, 0, 1, -3)
underline.AnchorPoint = Vector2.new(0, 0)
underline.BackgroundColor3 = getThemeColor()
underline.BorderSizePixel = 0
underline.Visible = false
underline.ZIndex = 12
Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)
local page = Instance.new("ScrollingFrame", tabContent)
page.Size = UDim2.new(1, 0, 1, 0)
page.Position = UDim2.new(0, 0, 0, 0)
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.ClipsDescendants = true
page.ScrollBarThickness = 6
page.ScrollBarImageColor3 = Color3.fromRGB(56, 170, 240)
page.ScrollBarImageTransparency = 0
page.CanvasSize = UDim2.new(0, 0, 0, 0)
page.AutomaticCanvasSize = Enum.AutomaticSize.Y
page.ScrollingDirection = Enum.ScrollingDirection.Y
page.ElasticBehavior = Enum.ElasticBehavior.Always
page.ScrollingEnabled = true
page.ZIndex = 6
page.Visible = (i == 1)
local layout = Instance.new("UIListLayout", page)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local padding = Instance.new("UIPadding", page)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 160)
contentPages[name] = page
btn.MouseButton1Click:Connect(function()
for _, pg2 in pairs(contentPages) do pg2.Visible = false end
page.Visible = true
for _, b in ipairs(tabButtons) do
local ul = b:FindFirstChild("Underline")
if ul then ul.Visible = false end
local bs = b:FindFirstChild("TabStroke")
TS:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
BackgroundTransparency = 1,
BackgroundColor3 = Color3.fromRGB(10, 18, 30),
TextColor3 = Color3.fromRGB(255, 255, 255)
}):Play()
if bs then TS:Create(bs, TweenInfo.new(0.2), {Transparency = 1}):Play() end
end
local ul = btn:FindFirstChild("Underline")
if ul then ul.Visible = true end
local bs = btn:FindFirstChild("TabStroke")
TS:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
BackgroundTransparency = 0,
BackgroundColor3 = getThemeColor(),
TextColor3 = Color3.fromRGB(255, 255, 255)
}):Play()
if bs then TS:Create(bs, TweenInfo.new(0.22), {Transparency = 0.3}):Play() end
end)
btn.MouseEnter:Connect(function()
if btn:FindFirstChild("Underline") and btn.Underline.Visible then return end
TS:Create(btn, TweenInfo.new(0.15), {
BackgroundTransparency = 0.55,
TextColor3 = Color3.fromRGB(255, 255, 255)
}):Play()
end)
btn.MouseLeave:Connect(function()
if btn:FindFirstChild("Underline") and btn.Underline.Visible then return end
TS:Create(btn, TweenInfo.new(0.15), {
BackgroundTransparency = 1,
TextColor3 = Color3.fromRGB(255, 255, 255)
}):Play()
end)
table.insert(tabButtons, btn)
end
if tabButtons[1] then
local ul = tabButtons[1]:FindFirstChild("Underline")
if ul then ul.Visible = true end
tabButtons[1].BackgroundColor3 = getThemeColor()
tabButtons[1].BackgroundTransparency = 0
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
local bs = tabButtons[1]:FindFirstChild("TabStroke")
if bs then bs.Transparency = 0.3 end
end
local pageCounters = {}
local function getNextOrder(page)
if not pageCounters[page] then pageCounters[page] = 0 end
pageCounters[page] = pageCounters[page] + 1
return pageCounters[page]
end
local function mkSect(page, txt)
local f = Instance.new("Frame", page)
f.Size = UDim2.new(1, 0, 0, 30)
f.BackgroundTransparency = 1
f.BorderSizePixel = 0
f.LayoutOrder = getNextOrder(page)
f.ZIndex = 7
local accent = Instance.new("Frame", f)
accent.Name = "SectAccent"
accent.Size = UDim2.new(0, 3, 0, 16)
accent.Position = UDim2.new(0, 5, 0.5, -8)
accent.AnchorPoint = Vector2.new(0, 0.5)
accent.BackgroundColor3 = Color3.fromRGB(205, 35, 55)
accent.BorderSizePixel = 0
accent.ZIndex = 8
Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
local accentGrad = Instance.new("UIGradient", accent)
accentGrad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 240, 255)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 140, 230)),
})
accentGrad.Rotation = 90
local l = Instance.new("TextLabel", f)
l.Size = UDim2.new(0.55, -24, 1, 0)
l.Position = UDim2.new(0, 14, 0, 0)
l.BackgroundTransparency = 1
l.Text = txt:upper()
l.TextColor3 = Color3.fromRGB(220, 240, 255)
l.Font = Enum.Font.GothamBlack
l.TextSize = 12
l.TextXAlignment = Enum.TextXAlignment.Left
l.TextStrokeColor3 = Color3.fromRGB(0, 40, 80)
l.TextStrokeTransparency = 0.55
l.ZIndex = 8
local line = Instance.new("Frame", f)
line.Name = "SectLine"
line.Size = UDim2.new(0, 130, 0, 1)
line.Position = UDim2.new(1, -6, 0.5, 0)
line.AnchorPoint = Vector2.new(1, 0.5)
line.BackgroundColor3 = Color3.fromRGB(205, 35, 55)
line.BorderSizePixel = 0
line.ZIndex = 8
local lineGrad = Instance.new("UIGradient", line)
lineGrad.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0.00, 0.25),
NumberSequenceKeypoint.new(1.00, 1.00),
})
return f
end
local function mkRow(page, h)
local f = Instance.new("Frame", page)
local compactHeight = math.max(36, math.floor((h or 42) * 1.0))
f.Size = UDim2.new(1, -4, 0, compactHeight)
f.BackgroundColor3 = Color3.fromRGB(8, 14, 24)
f.BackgroundTransparency = 0.35
f.BorderSizePixel = 0
f.LayoutOrder = getNextOrder(page)
f.ZIndex = 7
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
local settingBorder = Instance.new("UIStroke", f)
settingBorder.Name = "SettingWhiteBorder"
settingBorder.Color = Color3.fromRGB(56, 160, 230)
settingBorder.Thickness = 1
settingBorder.Transparency = 0.55
return f
end
local function mkLabel(row, txt)
local l = Instance.new("TextLabel", row)
l.Size = UDim2.new(0.55, 0, 1, 0)
l.Position = UDim2.new(0, 12, 0, 0)
l.BackgroundTransparency = 1
l.Text = txt
l.TextColor3 = Color3.fromRGB(255, 255, 255)
l.Font = Enum.Font.GothamBold
l.TextSize = 15
l.TextXAlignment = Enum.TextXAlignment.Left
l.TextTruncate = Enum.TextTruncate.AtEnd
l.TextStrokeColor3 = Color3.fromRGB(0,0,0)
l.TextStrokeTransparency = 0.5
l.ZIndex = 8
return l
end
local function mkPill(row, offset)
local pill = Instance.new("Frame", row)
pill.Name = "Track"
pill.Size = UDim2.new(0, 50, 0, 28)
pill.AnchorPoint = Vector2.new(1, 0.5)
pill.Position = UDim2.new(1, -18, 0.5, 0)
pill.BackgroundTransparency = 1
pill.BorderSizePixel = 0
pill.ZIndex = 8
local dot = Instance.new("Frame", pill)
dot.Name = "Knob"
dot.Size = UDim2.new(1, 0, 1, 0)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0.5, 0)
dot.BackgroundColor3 = Color3.fromRGB(220, 55, 65)
dot.BorderSizePixel = 0
dot.ZIndex = 9
Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 10)
local dotStroke = Instance.new("UIStroke", dot)
dotStroke.Color = Color3.fromRGB(120, 120, 140)
dotStroke.Thickness = 1
dotStroke.Transparency = 0.5
dotStroke.Name = "KnobStroke"
local stateIcon = Instance.new("TextLabel", dot)
stateIcon.Name = "StateIcon"
stateIcon.Size = UDim2.new(1, 0, 1, 0)
stateIcon.BackgroundTransparency = 1
stateIcon.Text = "OFF"
stateIcon.TextColor3 = WHITE
stateIcon.Font = Enum.Font.GothamBlack
stateIcon.TextSize = 13
stateIcon.TextXAlignment = Enum.TextXAlignment.Center
stateIcon.TextYAlignment = Enum.TextYAlignment.Center
stateIcon.ZIndex = 11
return pill, dot
end
local function animPill(pill, dot, on)
local dotStroke = dot:FindFirstChild("KnobStroke")
local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local stateIcon = dot:FindFirstChild("StateIcon")
local themeC = (getThemeColor and getThemeColor()) or Color3.fromRGB(205, 35, 55)
local onColor = themeC
local offColor = Color3.fromRGB(6, 10, 16)
if pill then
pcall(function()
pill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pill.BackgroundTransparency = 0
end)
end
TS:Create(dot, fadeInfo, {
BackgroundColor3 = on and onColor or offColor,
BackgroundTransparency = 0,
}):Play()
if stateIcon then
stateIcon.Text = on and "ON" or "OFF"
stateIcon.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,160,180)
end
if dotStroke then
TS:Create(dotStroke, fadeInfo, {
Color = on and onColor or offColor,
Transparency = 0.15,
}):Play()
end
end
local function mkToggle(page, txt, cb)
local row = mkRow(page, 42)
local commandLabel = mkLabel(row, txt)
commandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
local pill, dot = mkPill(row, 62)
local on = false
local function sv(s)
on = s
animPill(pill, dot, s)
commandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
end
local clk = Instance.new("TextButton", pill)
clk.Size = UDim2.new(1,0,1,0)
clk.BackgroundTransparency = 1
clk.Text = ""
clk.AutoButtonColor = false
clk.ZIndex = 10
clk.MouseButton1Click:Connect(function()
on = not on
sv(on)
pcall(cb, on)
pcall(saveAllSettings, true)
end)
return sv
end
local function mkSelector(parent, default, options, cb)
local container = Instance.new("Frame", parent)
container.Size = UDim2.new(0, 160, 1, 0)
container.Position = UDim2.new(1, -168, 0, 0)
container.BackgroundTransparency = 1
container.ZIndex = 8
local leftBtn = Instance.new("TextButton", container)
leftBtn.Size = UDim2.new(0, 32, 0, 30)
leftBtn.Position = UDim2.new(0, 0, 0.5, -15)
leftBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
leftBtn.BackgroundTransparency = 0
leftBtn.BorderSizePixel = 0
leftBtn.Text = "<"
leftBtn.TextColor3 = WHITE
leftBtn.Font = Enum.Font.GothamBold
leftBtn.TextSize = 13
leftBtn.AutoButtonColor = false
leftBtn.ZIndex = 9
Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
local label = Instance.new("TextLabel", container)
label.Size = UDim2.new(0, 84, 0, 30)
label.Position = UDim2.new(0.5, -42, 0.5, -15)
label.BackgroundTransparency = 1
label.Text = default
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Center
label.ZIndex = 9
local rightBtn = Instance.new("TextButton", container)
rightBtn.Size = UDim2.new(0, 32, 0, 30)
rightBtn.Position = UDim2.new(1, -32, 0.5, -15)
rightBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rightBtn.BackgroundTransparency = 0
rightBtn.BorderSizePixel = 0
rightBtn.Text = ">"
rightBtn.TextColor3 = WHITE
rightBtn.Font = Enum.Font.GothamBold
rightBtn.TextSize = 13
rightBtn.AutoButtonColor = false
rightBtn.ZIndex = 9
Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
local function updateLabel(newText) label.Text = newText end
local function flashButton(btn)
local oldColor, oldText = btn.BackgroundColor3, btn.TextColor3
local accent = btn.Parent:GetAttribute("ButtonAccentColor") or Color3.fromRGB(0, 0, 0)
btn.BackgroundColor3 = accent
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
task.delay(0.16, function()
if btn and btn.Parent then
btn.BackgroundColor3 = oldColor
btn.TextColor3 = oldText
end
end)
end
leftBtn.MouseButton1Click:Connect(function()
flashButton(leftBtn)
if cb then cb(-1, updateLabel); pcall(saveAllSettings, true) end
end)
rightBtn.MouseButton1Click:Connect(function()
flashButton(rightBtn)
if cb then cb(1, updateLabel); pcall(saveAllSettings, true) end
end)
return label
end
local function mkBox(parent, default, w, xOff, cb)
local tb = Instance.new("TextBox", parent)
local bw = w or 50
local xo = math.max(xOff or 56, bw + 12)
tb.Size = UDim2.new(0, bw, 0, 28)
tb.Position = UDim2.new(1, -xo, 0.5, -14)
tb.BackgroundColor3 = INP
tb.BackgroundTransparency = 0.7
tb.BorderSizePixel = 0
tb.Text = tostring(default)
tb.TextColor3 = WHITE
tb.Font = Enum.Font.GothamBold
tb.TextSize = 12
tb.ClearTextOnFocus = false
tb.ZIndex = 8
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
local bs = Instance.new("UIStroke", tb)
bs.Color = ROW_BORDER
bs.Thickness = 1.2
bs.Transparency = 0.25
tb.Focused:Connect(function() TS:Create(bs, TweenInfo.new(0.12), {Color = getThemeColor(), Transparency = 0}):Play() end)
tb.FocusLost:Connect(function()
TS:Create(bs, TweenInfo.new(0.12), {Color = ROW_BORDER, Transparency = 0.25}):Play()
if cb then
local n = tonumber(tb.Text)
if n then cb(n) else tb.Text = tostring(default) end
pcall(saveAllSettings, true)
end
end)
return tb
end
local function mkKeyButton(parent, kbEntry)
local btn = Instance.new("TextButton", parent)
btn.Size = UDim2.new(0, 88, 0, 28)
btn.Position = UDim2.new(1, -96, 0.5, -14)
btn.BackgroundColor3 = INP
btn.BackgroundTransparency = 0.5
btn.BorderSizePixel = 0
local function getLabel() return (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None" end
btn.Text = getLabel()
btn.TextColor3 = WHITE
btn.Font = Enum.Font.GothamBold
btn.TextSize = 10
btn.ZIndex = 8
btn.AutoButtonColor = false
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
local bs = Instance.new("UIStroke", btn)
bs.Color = ROW_BORDER
bs.Thickness = 1
local li = false; local lc; local pv = btn.Text; local listenStart = 0
btn.Activated:Connect(function()
if li then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end
pv = btn.Text; li = true; _anyKeyListening = true; listenStart = _tick(); btn.Text = "..."; btn.TextColor3 = WHITE
lc = UIS.InputBegan:Connect(function(inp)
if not li then return end
if inp.KeyCode == Enum.KeyCode.Escape then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end
local isGp = isGamepadInput(inp)
if isGp and _tick()-listenStart < 0.15 then return end
if not isBindableInput(inp) then return end
btn.Text = inp.KeyCode.Name; pv = inp.KeyCode.Name; btn.TextColor3 = WHITE
li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end
kbEntry.kb = nil
kbEntry.gp = nil
if isGp then kbEntry.gp = inp.KeyCode else kbEntry.kb = inp.KeyCode end
pcall(saveAllSettings, true)
end)
end)
table.insert(keyButtonRefs, {btn = btn, entry = kbEntry})
return btn
end
local function addKeybindRow(page, labelText, kbEntry)
local row = mkRow(page, 40)
mkLabel(row, labelText)
mkKeyButton(row, kbEntry)
end
local speedPage = contentPages["Speed"]
mkSect(speedPage, "Movement Speeds")

do local row = mkRow(speedPage, 42); mkLabel(row, "Normal Speed"); normalBox = mkBox(row, NS, 50, 56, function(v) if v > 0 and v <= 500 then NS = v; if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end end end) end
do local row = mkRow(speedPage, 42); mkLabel(row, "Carry Speed"); carryBox = mkBox(row, CS, 50, 56, function(v) if v > 0 and v <= 500 then CS = v; if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end end end) end
do local row = mkRow(speedPage, 42); mkLabel(row, "Lagger Normal Speed"); laggerBox = mkBox(row, LAGGER_SPEED, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED = v; if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end end end) end
do local row = mkRow(speedPage, 42); mkLabel(row, "Lagger Carry Speed"); lagger2Box = mkBox(row, LAGGER_CARRY_SPEED, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_CARRY_SPEED = v; if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end end end) end
mkSect(speedPage, "Active Mode")
do
local row = mkRow(speedPage, 42)
mkLabel(row, "Current Mode")
modeValLbl = Instance.new("TextLabel", row)
modeValLbl.Size = UDim2.new(0, 110, 1, 0)
modeValLbl.Position = UDim2.new(1, -118, 0, 0)
modeValLbl.BackgroundTransparency = 1
modeValLbl.Text = "Normal"
modeValLbl.TextColor3 = WHITE
modeValLbl.Font = Enum.Font.GothamBold
modeValLbl.TextSize = 12
modeValLbl.TextXAlignment = Enum.TextXAlignment.Right
modeValLbl.ZIndex = 8
local clk = Instance.new("TextButton", row)
clk.Size = UDim2.new(1,0,1,0)
clk.BackgroundTransparency = 1
clk.Text = ""
clk.AutoButtonColor = false
clk.ZIndex = 8
clk.MouseButton1Click:Connect(function() toggleCarryMode() end)
end
mkSect(speedPage, "Auto Brainrot Speed")
autoBrainrotSpeedSetVisual = mkToggle(speedPage, "Auto Brainrot Speed", function(on)
    setAutoBrainrotSpeedEnabled(on == true)
end)
if autoBrainrotSpeedSetVisual then autoBrainrotSpeedSetVisual(autoBrainrotSpeedEnabled == true) end
-- alias for old visual refs
autoCarrySetVisual = autoBrainrotSpeedSetVisual

mkSect(speedPage, "Auto Movement")
autoLeftSetVisual = mkToggle(speedPage, "Auto Left", function(on)
autoLeftEnabled = on
if on then startAutoLeft() else stopAutoLeft() end
if mobSetAutoLeft then mobSetAutoLeft(on) end
end)
autoRightSetVisual = mkToggle(speedPage, "Auto Right", function(on)
autoRightEnabled = on
if on then startAutoRight() else stopAutoRight() end
if mobSetAutoRight then mobSetAutoRight(on) end
end)
-- FOV slider
do
    cameraFOV = cameraFOV or 70
    local row = mkRow(speedPage, 56)
    row.Name = "FOVSliderRow"
    local title = mkLabel(row, "FOV")
    title.Size = UDim2.new(0, 40, 1, 0)
    local valueLbl = Instance.new("TextLabel", row)
    valueLbl.Size = UDim2.fromOffset(36, 20)
    valueLbl.Position = UDim2.new(1, -42, 0.5, -10)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(math.floor(cameraFOV or 70))
    valueLbl.TextColor3 = Color3.fromRGB(255,255,255)
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 12
    valueLbl.ZIndex = 9
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -100, 0, 6)
    track.Position = UDim2.new(0, 48, 0.5, -3)
    track.BackgroundColor3 = Color3.fromRGB(40,40,48)
    track.BorderSizePixel = 0
    track.ZIndex = 8
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = getThemeColor()
    fill.BorderSizePixel = 0
    fill.ZIndex = 9
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", track)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 10
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local FOV_MIN, FOV_MAX = 40, 120
    local function setFOVFromAlpha(a)
        a = math.clamp(a, 0, 1)
        local val = FOV_MIN + (FOV_MAX - FOV_MIN) * a
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valueLbl.Text = tostring(math.floor(val + 0.5))
        cameraFOV = val
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam and not stretchEnabled then cam.FieldOfView = val end
        end)
    end
    setFOVFromAlpha(((cameraFOV or 70) - FOV_MIN) / (FOV_MAX - FOV_MIN))
    local dragging = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local abs = track.AbsolutePosition.X
            local w = track.AbsoluteSize.X
            if w > 0 then setFOVFromAlpha((inp.Position.X - abs) / w) end
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local abs = track.AbsolutePosition.X
            local w = track.AbsoluteSize.X
            if w > 0 then setFOVFromAlpha((inp.Position.X - abs) / w) end
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then dragging = false; pcall(saveAllSettings, true) end
        end
    end)
end
stretchSetVisual = mkToggle(speedPage, "Stretch Rez", function(on)
    if on then enableStretch(); stretchEnabled = true
    else disableStretch(); pcall(function() local c=workspace.CurrentCamera; if c then c.FieldOfView = cameraFOV or 70 end end) end
    pcall(saveAllSettings, true)
end)
if stretchSetVisual then stretchSetVisual(stretchEnabled) end

do
infJumpSpeedSetVisual = mkToggle(speedPage, "Hold Inf Jump", function(on)
    setSpeedHoldInfJump(on)
end)
if infJumpSpeedSetVisual then
    infJumpSpeedSetVisual(SpeedHoldInfJump and SpeedHoldInfJump.enabled == true)
end
end

-- ============================================================
-- AUTO SPIN (NEW) — fast spin around self, only while holding animal
-- ============================================================
local function _noxStopSpinRuntime()
    if SPIN_BOT_CONN then pcall(function() SPIN_BOT_CONN:Disconnect() end); SPIN_BOT_CONN = nil end
    if SPIN_BOT_STEP_CONN then pcall(function() SPIN_BOT_STEP_CONN:Disconnect() end); SPIN_BOT_STEP_CONN = nil end
    SPIN_BOT_ACTIVE = false
    local char = LP and LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if root then root.AssemblyAngularVelocity = Vector3.zero end
    if hum then hum.AutoRotate = true end
end

local function _noxIsHoldingForSpin()
    if type(_G.__NoxIsCarryingAnimal) == "function" then
        local ok, res = pcall(_G.__NoxIsCarryingAnimal)
        if ok and res then return true end
    end
    local char = LP and LP.Character
    if not char then return false end
    if LP:GetAttribute("Stealing") == true or char:GetAttribute("Stealing") == true then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local ws = hum and tonumber(hum.WalkSpeed) or 16
    if ws > 0 and ws < 25 and ws ~= 16 then return true end
    for _, child in ipairs(char:GetChildren()) do
        local n = string.lower(child.Name)
        if n:find("brain", 1, true) or n:find("animal", 1, true)
            or n:find("carry", 1, true) or n:find("steal", 1, true)
            or n:find("held", 1, true) or n:find("stolen", 1, true) then
            return true
        end
    end
    return false
end

local function _noxStartSpinRuntime()
    _noxStopSpinRuntime()
    if not autoSpinEnabled then return end

    SPIN_BOT_CONN = RunService.RenderStepped:Connect(function(dt)
        if not autoSpinEnabled then return end
        local char = LP and LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end

        if not _noxIsHoldingForSpin() then
            if SPIN_BOT_ACTIVE then
                hum.AutoRotate = true
                root.AssemblyAngularVelocity = Vector3.zero
                SPIN_BOT_ACTIVE = false
            end
            return
        end

        SPIN_BOT_ACTIVE = true
        hum.AutoRotate = false
        -- Fast spin around self (Y axis only). Keep position & velocity.
        local speed = tonumber(SPIN_BOT_SPEED) or 40
        -- speed is roughly revolutions intensity; convert to rad/s-ish via dt
        local pos = root.Position
        local vel = root.AssemblyLinearVelocity
        local _, yaw = root.CFrame:ToOrientation()
        local newYaw = yaw + (speed * math.min(dt or 0.016, 0.05))
        root.CFrame = CFrame.new(pos) * CFrame.Angles(0, newYaw, 0)
        root.AssemblyLinearVelocity = vel
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

function setAutoSpinEnabled(on)
    autoSpinEnabled = on == true
    if autoSpinSetVisual then
        pcall(function() autoSpinSetVisual(autoSpinEnabled) end)
    end
    if autoSpinEnabled then
        _noxStartSpinRuntime()
        print("[UNO] Auto Spin ON")
    else
        _noxStopSpinRuntime()
        print("[UNO] Auto Spin OFF")
    end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return autoSpinEnabled
end

_G.NoxSpinBot = {
    setEnabled = setAutoSpinEnabled,
    isEnabled = function() return autoSpinEnabled == true end,
    setSpeed = function(v) SPIN_BOT_SPEED = math.clamp(tonumber(v) or 40, 5, 120) end,
    getSpeed = function() return SPIN_BOT_SPEED end,
}

local combatPage = contentPages["Combat"]

-- ============================================================
-- SAFE MODE (from PrimeVS) — locks combat while holding / duel countdown
-- ============================================================
local function _safeModeHoldingBrainrot()
    if type(_G.__NoxIsCarryingAnimal) == "function" then
        local ok, res = pcall(_G.__NoxIsCarryingAnimal)
        if ok and res then return true end
    end
    local char = LP and LP.Character
    if not char then return false end
    if LP:GetAttribute("Stealing") == true or char:GetAttribute("Stealing") == true then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local ws = hum and tonumber(hum.WalkSpeed)
    if ws and ws > 0 and ws < 25 and ws ~= 16 then return true end
    return false
end

local function _safeModeForceStop(reason)
    local stopped = false
    if autoBatEnabled and disableAutoBat then pcall(disableAutoBat); stopped = true end
    if antiBypassEnabled and stopAntiBypass then pcall(stopAntiBypass); stopped = true end
    if autoLeftEnabled and stopAutoLeft then pcall(stopAutoLeft); autoLeftEnabled = false; stopped = true end
    if autoRightEnabled and stopAutoRight then pcall(stopAutoRight); autoRightEnabled = false; stopped = true end
    if stopped then print("[UNO] Safe Mode lock:", reason or "SAFE") end
end

function safeModeIsLocked()
    if not safeModeEnabled then return false end
    return _safeModeHoldingBrainrot()
end

function safeModeTryStart()
    if safeModeIsLocked() then
        _safeModeForceStop("SAFE MODE LOCK")
        return false
    end
    return true
end

function setSafeModeEnabled(on)
    safeModeEnabled = on == true
    if safeModeSetVisual then pcall(function() safeModeSetVisual(safeModeEnabled) end) end
    if safeModeEnabled then
        if not _G.__NoxSafeModeMonitor then
            _G.__NoxSafeModeMonitor = true
            RunService.Heartbeat:Connect(function()
                if safeModeEnabled and safeModeIsLocked() then
                    _safeModeForceStop("SAFE MODE LOCK")
                end
            end)
        end
    end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return safeModeEnabled
end

-- ============================================================
-- FLING SHIELD (from PrimeVS)
-- ============================================================
local _flingShieldConn = nil
local FLING_MAX_LIN = 160
local FLING_MAX_ANG = 45
local FLING_AIMBOT_LIN = 220
local FLING_AIMBOT_ANG = 60

local function _flingShieldApply(root, maxLin, maxAng)
    if not root or not root.Parent then return end
    local pv = root.AssemblyLinearVelocity
    local ph = Vector3.new(pv.X, 0, pv.Z)
    if ph.Magnitude > maxLin * 1.2 then
        local scale = (maxLin * 1.05) / ph.Magnitude
        root.AssemblyLinearVelocity = Vector3.new(pv.X * scale, pv.Y, pv.Z * scale)
    end
    if root.AssemblyAngularVelocity.Magnitude > maxAng then
        root.AssemblyAngularVelocity = Vector3.zero
    end
    -- clamp other nearby player flings on us is already covered by velocity clamp
end

function startFlingShield()
    flingShieldEnabled = true
    if _flingShieldConn then pcall(function() _flingShieldConn:Disconnect() end); _flingShieldConn = nil end
    _flingShieldConn = RunService.Heartbeat:Connect(function()
        if not flingShieldEnabled then return end
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local aimOn = autoBatEnabled == true or antiBypassEnabled == true
        local maxLin = aimOn and FLING_AIMBOT_LIN or FLING_MAX_LIN
        local maxAng = aimOn and FLING_AIMBOT_ANG or FLING_MAX_ANG
        _flingShieldApply(root, maxLin, maxAng)
    end)
end

function stopFlingShield()
    flingShieldEnabled = false
    if _flingShieldConn then pcall(function() _flingShieldConn:Disconnect() end); _flingShieldConn = nil end
end

function setFlingShieldEnabled(on)
    if on then startFlingShield() else stopFlingShield() end
    if flingShieldSetVisual then pcall(function() flingShieldSetVisual(flingShieldEnabled) end) end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return flingShieldEnabled
end

-- ============================================================
-- AUTO RESET ON MED FLING (from PrimeVS)
-- ============================================================
local _medResetState = { conns = {}, enabled = false, medTriggered = false, lastFire = 0, cooldown = 2.25, charConn = nil }

local function _medResetShouldFire(part)
    if not _medResetState.enabled then return false end
    if _medResetState.medTriggered then return false end
    if tick() - (_medResetState.lastFire or 0) < (_medResetState.cooldown or 2.25) then return false end
    if not part or not part.Parent then return false end
    if part:FindFirstAncestorOfClass("Tool") or part:FindFirstAncestorOfClass("Accessory") then return false end
    return part.Anchored == true and part.Transparency == 1
end

local function _medResetFireOnce(part)
    if not _medResetShouldFire(part) then return end
    _medResetState.medTriggered = true
    _medResetState.lastFire = tick()
    task.delay(2.3, function()
        if _medResetState.enabled and _G.InstaReset and _G.InstaReset.Trigger then
            pcall(_G.InstaReset.Trigger)
        end
    end)
end

local function _medResetBindChar(char)
    for _, c in ipairs(_medResetState.conns) do pcall(function() c:Disconnect() end) end
    _medResetState.conns = {}
    _medResetState.medTriggered = false
    if not char then return end
    table.insert(_medResetState.conns, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(_medResetState.conns, part:GetPropertyChangedSignal("Anchored"):Connect(function()
                _medResetFireOnce(part)
            end))
            _medResetFireOnce(part)
        end
    end))
    table.insert(_medResetState.conns, char.AncestryChanged:Connect(function(_, parent)
        if not parent then _medResetState.medTriggered = false end
    end))
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(_medResetState.conns, part:GetPropertyChangedSignal("Anchored"):Connect(function()
                _medResetFireOnce(part)
            end))
            _medResetFireOnce(part)
        end
    end
end

function setAutoResetOnMed(on)
    autoResetOnMedEnabled = on == true
    _medResetState.enabled = autoResetOnMedEnabled
    if autoResetOnMedSetVisual then pcall(function() autoResetOnMedSetVisual(autoResetOnMedEnabled) end) end
    if autoResetOnMedEnabled then
        if LP.Character then _medResetBindChar(LP.Character) end
        if not _medResetState.charConn then
            _medResetState.charConn = LP.CharacterAdded:Connect(function(c)
                task.defer(function() _medResetBindChar(c) end)
            end)
        end
    else
        for _, c in ipairs(_medResetState.conns) do pcall(function() c:Disconnect() end) end
        _medResetState.conns = {}
        _medResetState.medTriggered = false
    end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return autoResetOnMedEnabled
end

-- ============================================================
-- PLAYER ESP + TRACER ESP
-- ============================================================
local _playerESP = {} -- [player] = {hl, bb, label}
local _tracerESP = {} -- [player] = beam/attachment pair
local _espLoopConn = nil
local _tracerAtt0 = nil

local function _clearPlayerESP()
    for plr, data in pairs(_playerESP) do
        pcall(function() if data.hl then data.hl:Destroy() end end)
        pcall(function() if data.bb then data.bb:Destroy() end end)
    end
    _playerESP = {}
end

local function _clearTracerESP()
    for plr, data in pairs(_tracerESP) do
        pcall(function() if data.beam then data.beam:Destroy() end end)
        pcall(function() if data.att1 then data.att1:Destroy() end end)
    end
    _tracerESP = {}
    if _tracerAtt0 then pcall(function() _tracerAtt0:Destroy() end); _tracerAtt0 = nil end
end

local function _espUpdate()
    local char = LP.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if playerESPEnabled then
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                if tRoot and tHum and tHum.Health > 0 then
                    seen[plr] = true
                    local data = _playerESP[plr]
                    if not data then
                        data = {}
                        local hl = Instance.new("Highlight")
                        hl.Name = "NoxPlayerESP"
                        hl.FillColor = selectedColor or Color3.fromRGB(70, 200, 255)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.65
                        hl.OutlineTransparency = 0.2
                        hl.Adornee = plr.Character
                        hl.Parent = plr.Character
                        data.hl = hl
                        if head then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "NoxPlayerESPName"
                            bb.Size = UDim2.fromOffset(120, 22)
                            bb.StudsOffset = Vector3.new(0, 2.6, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = head
                            bb.Parent = head
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.fromScale(1, 1)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = plr.DisplayName or plr.Name
                            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                            lbl.TextStrokeTransparency = 0.3
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            data.bb = bb
                        end
                        _playerESP[plr] = data
                    else
                        if data.hl and data.hl.Parent then
                            data.hl.FillColor = selectedColor or Color3.fromRGB(70, 200, 255)
                            data.hl.Adornee = plr.Character
                        end
                    end
                end
            end
        end
        for plr, data in pairs(_playerESP) do
            if not seen[plr] then
                pcall(function() if data.hl then data.hl:Destroy() end end)
                pcall(function() if data.bb then data.bb:Destroy() end end)
                _playerESP[plr] = nil
            end
        end
    end
    if tracerESPEnabled and myRoot then
        if not _tracerAtt0 or not _tracerAtt0.Parent then
            _tracerAtt0 = Instance.new("Attachment")
            _tracerAtt0.Name = "NoxTracerAtt0"
            _tracerAtt0.Parent = myRoot
        end
        local seenT = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    seenT[plr] = true
                    local data = _tracerESP[plr]
                    if not data or not data.beam or not data.beam.Parent then
                        local att1 = Instance.new("Attachment")
                        att1.Name = "NoxTracerAtt1"
                        att1.Parent = tRoot
                        local beam = Instance.new("Beam")
                        beam.Name = "NoxTracerBeam"
                        beam.Attachment0 = _tracerAtt0
                        beam.Attachment1 = att1
                        beam.Width0 = 0.12
                        beam.Width1 = 0.04
                        beam.FaceCamera = true
                        beam.Color = ColorSequence.new(selectedColor or Color3.fromRGB(70, 200, 255))
                        beam.Transparency = NumberSequence.new(0.15)
                        beam.Parent = myRoot
                        _tracerESP[plr] = { beam = beam, att1 = att1 }
                    else
                        data.beam.Color = ColorSequence.new(selectedColor or Color3.fromRGB(70, 200, 255))
                    end
                end
            end
        end
        for plr, data in pairs(_tracerESP) do
            if not seenT[plr] then
                pcall(function() if data.beam then data.beam:Destroy() end end)
                pcall(function() if data.att1 then data.att1:Destroy() end end)
                _tracerESP[plr] = nil
            end
        end
    end
end

local function _ensureESPLoop()
    if _espLoopConn then return end
    _espLoopConn = RunService.Heartbeat:Connect(function()
        if not playerESPEnabled and not tracerESPEnabled then return end
        _espUpdate()
    end)
end

function setPlayerESPEnabled(on)
    playerESPEnabled = on == true
    if playerESPSetVisual then pcall(function() playerESPSetVisual(playerESPEnabled) end) end
    if playerESPEnabled then
        _ensureESPLoop()
        _espUpdate()
    else
        _clearPlayerESP()
    end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return playerESPEnabled
end

function setTracerESPEnabled(on)
    tracerESPEnabled = on == true
    if tracerESPSetVisual then pcall(function() tracerESPSetVisual(tracerESPEnabled) end) end
    if tracerESPEnabled then
        _ensureESPLoop()
        _espUpdate()
    else
        _clearTracerESP()
    end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return tracerESPEnabled
end

-- ============================================================
-- ALL LOCK BUTTONS — move all mobile buttons together
-- ============================================================
function setAllLockButtons(on)
    allLockButtonsEnabled = on == true
    _G.__NoxAllLockButtons = allLockButtonsEnabled
    if allLockButtonsSetVisual then pcall(function() allLockButtonsSetVisual(allLockButtonsEnabled) end) end
    if saveAllSettings then pcall(saveAllSettings, true) end
    return allLockButtonsEnabled
end

-- Hook mobile panel drag to support group move when all-lock is on
_G.__NoxGetAllLock = function() return allLockButtonsEnabled == true end

mkSect(combatPage, "Defense")
safeModeSetVisual = mkToggle(combatPage, "Safe Mode", function(on)
    setSafeModeEnabled(on == true)
end)
if safeModeSetVisual then safeModeSetVisual(safeModeEnabled == true) end
flingShieldSetVisual = mkToggle(combatPage, "Fling Shield", function(on)
    setFlingShieldEnabled(on == true)
end)
if flingShieldSetVisual then flingShieldSetVisual(flingShieldEnabled == true) end
setAntiFlingVisual = mkToggle(combatPage, "Anti Fling", function(on)
    antiFlingEnabled = on == true
    if antiFlingEnabled then startAntiFling() else stopAntiFling() end
    if saveAllSettings then pcall(saveAllSettings, true) end
end)
if setAntiFlingVisual then setAntiFlingVisual(antiFlingEnabled == true) end
autoResetOnMedSetVisual = mkToggle(combatPage, "Auto Reset On Med", function(on)
    setAutoResetOnMed(on == true)
end)
if autoResetOnMedSetVisual then autoResetOnMedSetVisual(autoResetOnMedEnabled == true) end
setAntiRagVisual = mkToggle(combatPage, "Anti Ragdoll", function(on)
if on then startAntiRagdollV2(); antiRagdollMode = "v2" else stopAntiRagdollV2(); antiRagdollMode = "off" end
saveAllSettings(true)
end)
if setAntiRagVisual then setAntiRagVisual(antiRagdollMode == "v2") end
ragdollStealVisual = mkToggle(combatPage, "Ragdoll Steal", function(on)
    setRagdollStealEnabled(on)
end)
if ragdollStealVisual then ragdollStealVisual(ragdollStealEnabled) end
setAntiDieVisual = mkToggle(combatPage, "Anti Die", function(on)
antiDieEnabled = on
if on then AntiDieModule.start() else AntiDieModule.stop() end
saveAllSettings(true)
end)
if setAntiDieVisual then setAntiDieVisual(antiDieEnabled) end
-- Instant Reset V1 / V2 (optional, from Zey style)
do
    local row = mkRow(combatPage, 42)
    mkLabel(row, "Instant Reset")
    local v1 = Instance.new("TextButton", row)
    v1.Size = UDim2.fromOffset(48, 28)
    v1.Position = UDim2.new(1, -108, 0.5, -14)
    v1.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
    v1.Text = "V1"
    v1.TextColor3 = Color3.fromRGB(255,255,255)
    v1.Font = Enum.Font.GothamBlack
    v1.TextSize = 12
    v1.AutoButtonColor = false
    v1.ZIndex = 10
    Instance.new("UICorner", v1).CornerRadius = UDim.new(0, 8)
    local v2 = Instance.new("TextButton", row)
    v2.Size = UDim2.fromOffset(48, 28)
    v2.Position = UDim2.new(1, -54, 0.5, -14)
    v2.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
    v2.Text = "V2"
    v2.TextColor3 = Color3.fromRGB(255,255,255)
    v2.Font = Enum.Font.GothamBlack
    v2.TextSize = 12
    v2.AutoButtonColor = false
    v2.ZIndex = 10
    Instance.new("UICorner", v2).CornerRadius = UDim.new(0, 8)
    local function paintIR(ver)
        instantResetVersion = ver
        v1.BackgroundColor3 = (ver == "V1") and getThemeColor() or Color3.fromRGB(12, 18, 28)
        v2.BackgroundColor3 = (ver == "V2") and getThemeColor() or Color3.fromRGB(12, 18, 28)
        if _G.__ZeyHubbInstantResetSetVersion then pcall(_G.__ZeyHubbInstantResetSetVersion, ver) end
        if _G.InstaReset and _G.InstaReset.SetVersion then pcall(_G.InstaReset.SetVersion, ver) end
        if saveAllSettings then pcall(saveAllSettings, true) end
    end
    paintIR(instantResetVersion or "V1")
    v1.MouseButton1Click:Connect(function() paintIR("V1") end)
    v2.MouseButton1Click:Connect(function() paintIR("V2") end)
end
do
local row = mkRow(combatPage, 42)
mkLabel(row, "Anti Bat")
local openBtn = Instance.new("TextButton", row)
openBtn.Size = UDim2.fromOffset(64, 28)
openBtn.Position = UDim2.new(1, -72, 0.5, -14)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openBtn.BackgroundTransparency = 0
openBtn.BorderSizePixel = 0
openBtn.Text = "OPEN"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 12
openBtn.AutoButtonColor = false
openBtn.ZIndex = 10
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)
openBtn.MouseButton1Click:Connect(function()
if type(openNoxAntiBatPanel) == "function" then openNoxAntiBatPanel() end
end)
end
mkSect(combatPage, "Attack")
autoSpinSetVisual = mkToggle(combatPage, "Auto Spin", function(on)
    setAutoSpinEnabled(on == true)
end)
if autoSpinSetVisual then autoSpinSetVisual(autoSpinEnabled == true) end
do local row = mkRow(combatPage, 42); mkLabel(row, "Spin Speed"); mkBox(row, SPIN_BOT_SPEED, 50, 56, function(v)
    if v and v >= 5 and v <= 120 then
        SPIN_BOT_SPEED = v
        if saveAllSettings then pcall(saveAllSettings, true) end
    end
end) end
-- Auto Bat = Bat V2 engine (old aimbot + NORMAL/LAGGER menu removed)
autoBatSetVisual = mkToggle(combatPage, "Auto Bat", function(on)
if on then enableAutoBat() else disableAutoBat() end
if mobSetAutoBat then mobSetAutoBat(on) end
end)
do
    local row = mkRow(combatPage, 42)
    mkLabel(row, "Bat Aim")
    local modes = {"v2", "v3", "v4"}
    local idx = 1
    for i, v in ipairs(modes) do
        if v == tostring(selectedAimbotMode or selectedBatAimMode or "v2"):lower() then idx = i break end
    end
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.fromOffset(44, 24)
    lbl.Position = UDim2.new(1, -128, 0.5, -12)
    lbl.BackgroundTransparency = 1
    lbl.Text = (modes[idx] == "v4" and "BAT V4" or ("BAT " .. string.upper(modes[idx])))
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.ZIndex = 9
    local function setMode(i)
        idx = ((i - 1) % #modes) + 1
        selectedAimbotMode = modes[idx]
        lbl.Text = (modes[idx] == "v4" and "BAT V4" or ("BAT " .. string.upper(modes[idx])))
        if autoBatEnabled then
            pcall(function()
                if disableAutoBat then disableAutoBat() end
                if enableAutoBat then enableAutoBat() end
            end)
        end
        pcall(saveAllSettings, true)
    end
    local prev = Instance.new("TextButton", row)
    prev.Size = UDim2.fromOffset(28, 24)
    prev.Position = UDim2.new(1, -168, 0.5, -12)
    prev.BackgroundColor3 = Color3.fromRGB(20,20,24)
    prev.Text = "<"
    prev.TextColor3 = Color3.fromRGB(255,255,255)
    prev.Font = Enum.Font.GothamBlack
    prev.TextSize = 14
    prev.AutoButtonColor = false
    prev.ZIndex = 9
    Instance.new("UICorner", prev).CornerRadius = UDim.new(0, 6)
    local nextb = Instance.new("TextButton", row)
    nextb.Size = UDim2.fromOffset(28, 24)
    nextb.Position = UDim2.new(1, -72, 0.5, -12)
    nextb.BackgroundColor3 = Color3.fromRGB(20,20,24)
    nextb.Text = ">"
    nextb.TextColor3 = Color3.fromRGB(255,255,255)
    nextb.Font = Enum.Font.GothamBlack
    nextb.TextSize = 14
    nextb.AutoButtonColor = false
    nextb.ZIndex = 9
    Instance.new("UICorner", nextb).CornerRadius = UDim.new(0, 6)
    prev.MouseButton1Click:Connect(function() setMode(idx - 1) end)
    nextb.MouseButton1Click:Connect(function() setMode(idx + 1) end)
end

do
    local row = mkRow(combatPage, 42)
    mkLabel(row, "Bat Bypass Ver")
    local modes = {"v1", "v2"}
    local idx = 1
    for i, v in ipairs(modes) do
        if v == tostring(bypassAimbotVersion or "v1"):lower() then idx = i break end
    end
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.fromOffset(44, 24)
    lbl.Position = UDim2.new(1, -128, 0.5, -12)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(modes[idx])
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.ZIndex = 9
    local function setMode(i)
        idx = ((i - 1) % #modes) + 1
        bypassAimbotVersion = modes[idx]
        lbl.Text = string.upper(modes[idx])
        if antiBypassEnabled then
            pcall(function()
                if stopAntiBypass then stopAntiBypass() end
                if startAntiBypass then startAntiBypass() end
            end)
        end
        pcall(saveAllSettings, true)
    end
    local prev = Instance.new("TextButton", row)
    prev.Size = UDim2.fromOffset(28, 24)
    prev.Position = UDim2.new(1, -168, 0.5, -12)
    prev.BackgroundColor3 = Color3.fromRGB(20,20,24)
    prev.Text = "<"
    prev.TextColor3 = Color3.fromRGB(255,255,255)
    prev.Font = Enum.Font.GothamBlack
    prev.TextSize = 14
    prev.ZIndex = 9
    Instance.new("UICorner", prev).CornerRadius = UDim.new(0, 6)
    local nextb = Instance.new("TextButton", row)
    nextb.Size = UDim2.fromOffset(28, 24)
    nextb.Position = UDim2.new(1, -72, 0.5, -12)
    nextb.BackgroundColor3 = Color3.fromRGB(20,20,24)
    nextb.Text = ">"
    nextb.TextColor3 = Color3.fromRGB(255,255,255)
    nextb.Font = Enum.Font.GothamBlack
    nextb.TextSize = 14
    nextb.ZIndex = 9
    Instance.new("UICorner", nextb).CornerRadius = UDim.new(0, 6)
    prev.MouseButton1Click:Connect(function() setMode(idx - 1) end)
    nextb.MouseButton1Click:Connect(function() setMode(idx + 1) end)
end

do local row = mkRow(combatPage, 42); mkLabel(row, "Bat Aimbot Speed"); batSpeedBox = mkBox(row, BAT_AIMBOT_SPEED, 50, 56, function(v)
if v and v > 0 and v <= 200 then BAT_AIMBOT_SPEED = v end
end) end
spamBatSetVisual = mkToggle(combatPage, "Spam Bat", function(on)
toggleSpamBat(on)
end)
if spamBatSetVisual then spamBatSetVisual(spamBatEnabled) end

antiBypassSetVisual = mkToggle(combatPage, "Bat Bypass V2", function(on)
if on then if not antiBypassEnabled then startAntiBypass() end else if antiBypassEnabled then stopAntiBypass() end end
end)
if antiBypassSetVisual then antiBypassSetVisual(antiBypassEnabled) end

do local row = mkRow(combatPage, 42); mkLabel(row, "Bat Bypass Speed"); mkBox(row, ANTI_BYPASS_SPEED, 50, 56, function(v) if v and v > 0 and v <= 200 then ANTI_BYPASS_SPEED = v end end) end
mkSect(combatPage, "Targeting")
bodyLockSetVisual = mkToggle(combatPage, "Lock Enemy", function(on)
bodyLockEnabled = on
if on then
if _blSuppressCount == 0 then startBodyLock() end
else
stopBodyLock()
end
end)
do
local row = mkRow(combatPage, 42)
mkLabel(row, "Lock Enemy Range")
bodyLockRangeBox = mkBox(row, bodyLockRange, 50, 56, function(v)
if v and v > 0 then
bodyLockRange = _clamp(_floor(v), 5, 200)
if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
end
end)
end
mkSect(combatPage, "Counters")
setBatCounterVisual = mkToggle(combatPage, "Bat Counter", function(on)
batCounterEnabled = on
if on then startBatCounter() else stopBatCounter() end
end)
setMedusaVisual = mkToggle(combatPage, "Medusa Counter", function(on)
medusaCounterEnabled = on
if on then
if LP.Character then setupMedusaCounter(LP.Character) else stopMedusaCounter() end
else
stopMedusaCounter()
end
if setMedusaVisual then setMedusaVisual(on) end
end)
mkSect(combatPage, "Drop")
dropBrainrotSetVisual = mkToggle(combatPage, "Drop Brainrot", function(on)
if on then
executeDropWithToggle(function(v)
dropBrainrotSetVisual(v)
if mobSetDropBR then mobSetDropBR(v) end
end)
end
end)
setDropVisual = dropBrainrotSetVisual
do
local row = mkRow(combatPage, 42)
mkLabel(row, "Drop Mode")
dropModeBtnRef = mkSelector(row, dropMode == 1 and "Fling" or "Jump Drop", {"Fling", "Jump Drop"}, function(dir, update)
if dropActive then stopDropBrainrot() end
dropMode = dropMode == 1 and 2 or 1
update(dropMode == 1 and "Fling" or "Jump Drop")
end)
end
local stealPage = contentPages["Steal"]
if stealPage then
    mkSect(stealPage, "Auto Steal")
    -- V1 / V2 style
    do
        local row = mkRow(stealPage, 42)
        mkLabel(row, "Steal Style")
        local v1 = Instance.new("TextButton", row)
        v1.Size = UDim2.fromOffset(48, 28)
        v1.Position = UDim2.new(1, -108, 0.5, -14)
        v1.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
        v1.Text = "V1"
        v1.TextColor3 = Color3.fromRGB(255,255,255)
        v1.Font = Enum.Font.GothamBlack
        v1.TextSize = 12
        v1.AutoButtonColor = false
        v1.ZIndex = 10
        Instance.new("UICorner", v1).CornerRadius = UDim.new(0, 8)
        local v2 = Instance.new("TextButton", row)
        v2.Size = UDim2.fromOffset(48, 28)
        v2.Position = UDim2.new(1, -54, 0.5, -14)
        v2.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
        v2.Text = "V2"
        v2.TextColor3 = Color3.fromRGB(255,255,255)
        v2.Font = Enum.Font.GothamBlack
        v2.TextSize = 12
        v2.AutoButtonColor = false
        v2.ZIndex = 10
        Instance.new("UICorner", v2).CornerRadius = UDim.new(0, 8)
        local function paintSteal(style)
            stealBarStyle = style
            v1.BackgroundColor3 = (style == "V1") and getThemeColor() or Color3.fromRGB(12, 18, 28)
            v2.BackgroundColor3 = (style == "V2") and getThemeColor() or Color3.fromRGB(12, 18, 28)
            pcall(applyStealBarStyle, style)
            if saveAllSettings then pcall(saveAllSettings, true) end
        end
        stealBarStyle = stealBarStyle or "V1"
        paintSteal(stealBarStyle)
        v1.MouseButton1Click:Connect(function() paintSteal("V1") end)
        v2.MouseButton1Click:Connect(function() paintSteal("V2") end)
    end
    autoStealSetVisual = mkToggle(stealPage, "Auto Steal", function(on)
        CONFIG.AUTO_STEAL_ENABLED = on == true
        if on then pcall(startAutoSteal) else pcall(function() if stealConnection then stealConnection:Disconnect(); stealConnection = nil end end) end
        if saveAllSettings then pcall(saveAllSettings, true) end
    end)
    if autoStealSetVisual then autoStealSetVisual(CONFIG.AUTO_STEAL_ENABLED == true) end
    do
        local row = mkRow(stealPage, 42)
        mkLabel(row, "Steal Range")
        mkBox(row, CONFIG.STEAL_RANGE or 65, 50, 56, function(v)
            if v and v > 0 then
                CONFIG.STEAL_RANGE = v
                if Steal then Steal.StealRadius = v end
            end
        end)
    end
end

local visualPage = contentPages["Visual"]
mkSect(visualPage, "Warnings & Timers")
kickWarningVisual = mkToggle(visualPage, "Ragdoll Countdown", function(on)
    if _G._NoxSetRagdollCountdownEnabled then _G._NoxSetRagdollCountdownEnabled(on) end
end)
if kickWarningVisual then kickWarningVisual(kickWarningEnabled) end
if ragdollCountdownVisual then ragdollCountdownVisual(ragdollCountdownEnabled) end

mkSect(visualPage, "Menu Background")
do
    local row = mkRow(visualPage, 58)
    local container = Instance.new("ScrollingFrame", row)
    container.Size = UDim2.new(1, -10, 1, -6)
    container.Position = UDim2.new(0, 5, 0, 3)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.ZIndex = 8
    container.ScrollingDirection = Enum.ScrollingDirection.X
    container.ScrollBarThickness = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.X
    local galleryLayout = Instance.new("UIListLayout", container)
    galleryLayout.FillDirection = Enum.FillDirection.Horizontal
    galleryLayout.Padding = UDim.new(0, 6)
    galleryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    local galleryPadding = Instance.new("UIPadding", container)
    galleryPadding.PaddingLeft = UDim.new(0, 40)
    galleryPadding.PaddingRight = UDim.new(0, 40)
    local bgButtons = {}
    _G.__NoxBackgroundButtons = bgButtons

    local function refreshBgStrokes()
        for i, btn in ipairs(bgButtons) do
            local st = btn and btn:FindFirstChildOfClass("UIStroke")
            if st then
                local selected = (i == tonumber(backgroundIndex)) and (backgroundMode ~= "None")
                st.Color = selected and Color3.fromRGB(205, 35, 55) or Color3.fromRGB(70, 90, 110)
                st.Thickness = selected and 2.2 or 1
                st.Transparency = selected and 0.1 or 0.4
            end
        end
        if backgroundSelectorLabel then
            backgroundSelectorLabel.Text = (backgroundMode == "None") and "None" or ("BG " .. tostring(backgroundIndex or 1))
        end
    end

    local function changeBg(step)
        local list = backgroundImages or {}
        local count = #list
        if count <= 0 then return end
        backgroundIndex = ((tonumber(backgroundIndex) or 1) - 1 + step) % count + 1
        backgroundMode = "Image"
        pcall(applyBackgroundMode, "Image")
        refreshBgStrokes()
        if saveAllSettings then pcall(saveAllSettings, true) end
    end

    local leftArrow = Instance.new("TextButton", row)
    leftArrow.Size = UDim2.new(0, 34, 0, 40)
    leftArrow.Position = UDim2.new(0, 4, 0.5, -20)
    leftArrow.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
    leftArrow.Text = "<"
    leftArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftArrow.Font = Enum.Font.GothamBlack
    leftArrow.TextSize = 18
    leftArrow.ZIndex = 12
    leftArrow.AutoButtonColor = false
    Instance.new("UICorner", leftArrow).CornerRadius = UDim.new(0, 8)

    local rightArrow = Instance.new("TextButton", row)
    rightArrow.Size = UDim2.new(0, 34, 0, 40)
    rightArrow.Position = UDim2.new(1, -38, 0.5, -20)
    rightArrow.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
    rightArrow.Text = ">"
    rightArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightArrow.Font = Enum.Font.GothamBlack
    rightArrow.TextSize = 18
    rightArrow.ZIndex = 12
    rightArrow.AutoButtonColor = false
    Instance.new("UICorner", rightArrow).CornerRadius = UDim.new(0, 8)

    leftArrow.MouseButton1Click:Connect(function() changeBg(-1) end)
    rightArrow.MouseButton1Click:Connect(function() changeBg(1) end)

    for i, asset in ipairs(backgroundImages or {}) do
        local btn = Instance.new("ImageButton", container)
        btn.Size = UDim2.new(0, 62, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.Image = tostring(asset or "")
        btn.ScaleType = Enum.ScaleType.Crop
        btn.ZIndex = 9
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
        local st = Instance.new("UIStroke", btn)
        st.Color = Color3.fromRGB(70, 90, 110)
        st.Thickness = 1
        st.Transparency = 0.35
        bgButtons[i] = btn
        local idx = i
        btn.MouseButton1Click:Connect(function()
            backgroundIndex = idx
            backgroundMode = "Image"
            pcall(applyBackgroundMode, "Image")
            refreshBgStrokes()
            if saveAllSettings then pcall(saveAllSettings, true) end
        end)
    end
    refreshBgStrokes()
    backgroundSelectorLabel = backgroundSelectorLabel or Instance.new("TextLabel")
end

mkSect(visualPage, "Fonts")
do
local FONT_ORDER = {"Gotham","GothamBold","GothamBlack","SourceSans","Arcade"}
local FONT_MAP = {
Gotham = Enum.Font.Gotham,
GothamBold = Enum.Font.GothamBold,
GothamBlack = Enum.Font.GothamBlack,
SourceSans = Enum.Font.SourceSans,
Arcade = Enum.Font.Arcade,
}
_G.__NoxUiFont = _G.__NoxUiFont or "Gotham"
local fi = 1
for i,n in ipairs(FONT_ORDER) do if n == _G.__NoxUiFont then fi = i break end end
local row = mkRow(visualPage, 42)
mkLabel(row, "UI Font")
_G.__NoxFontSelectorLabel = mkSelector(row, FONT_ORDER[fi], FONT_ORDER, function(dir, update)
fi = 1
for i, fontName in ipairs(FONT_ORDER) do
if fontName == _G.__NoxUiFont then fi = i break end
end
fi = fi + (dir or 1)
if fi < 1 then fi = #FONT_ORDER end
if fi > #FONT_ORDER then fi = 1 end
_G.__NoxUiFont = FONT_ORDER[fi]
local f = FONT_MAP[_G.__NoxUiFont] or Enum.Font.Gotham
pcall(function()
local function applyFontRoot(root)
if not root then return end
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
d.Font = f
end
end
end
applyFontRoot(gui)
applyFontRoot(MobilePanel)
if antiBypassFloatingButton then applyFontRoot(antiBypassFloatingButton) end
if instaResetFloatingButton then applyFontRoot(instaResetFloatingButton) end
pcall(function()
local pg = LP:FindFirstChild("PlayerGui")
if pg then
for _, g in ipairs(pg:GetChildren()) do
if g:IsA("ScreenGui") and (g.Name:find("Yout") or g.Name:find("Nox") or g.Name:find("Mobile")) then
applyFontRoot(g)
end
end
end
end)
end)
update(FONT_ORDER[fi])
pcall(saveAllSettings, true)
end)
end
mkSect(visualPage, "Animation Pack")
do
local row = mkRow(visualPage, 42)
mkLabel(row, "Animation Pack")
local packIdx = 1
for i,n in ipairs(ANIM_PACK_ORDER or {"Off"}) do
if n == (currentAnimPack or "Off") then packIdx = i break end
end
animSelectorLabel = nil
local function updatePackLabel(lbl)
if lbl then lbl.Text = ANIM_PACK_ORDER[packIdx] or "Off" end
end
local sel = mkSelector(row, ANIM_PACK_ORDER[packIdx] or "Off", ANIM_PACK_ORDER, function(dir, update)
packIdx = 1
for i, packName in ipairs(ANIM_PACK_ORDER) do
if packName == currentAnimPack then packIdx = i break end
end
packIdx = packIdx + (dir or 1)
if packIdx < 1 then packIdx = #ANIM_PACK_ORDER end
if packIdx > #ANIM_PACK_ORDER then packIdx = 1 end
local name = ANIM_PACK_ORDER[packIdx]
currentAnimPack = name
startAnimPack(name)
update(name)
pcall(saveAllSettings, true)
end)
animSelectorLabel = sel
end
mkSect(visualPage, "Custom Skins")
do
    local skinRow = mkRow(visualPage, 48)
    skinRow.BackgroundColor3 = Color3.fromRGB(100, 158, 198)
    skinRow.BackgroundTransparency = 0
    Instance.new("UICorner", skinRow).CornerRadius = UDim.new(0, 10)
    local skinStroke = Instance.new("UIStroke", skinRow)
    skinStroke.Color = getThemeColor()
    skinStroke.Thickness = 1.2
    skinStroke.Transparency = 0.35

    local prevBtn = Instance.new("TextButton", skinRow)
    prevBtn.Name = "SkinPrev"
    prevBtn.Size = UDim2.fromOffset(44, 32)
    prevBtn.Position = UDim2.new(0, 10, 0.5, -16)
    prevBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    prevBtn.BorderSizePixel = 0
    prevBtn.Text = "<"
    prevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    prevBtn.Font = Enum.Font.GothamBlack
    prevBtn.TextSize = 18
    prevBtn.AutoButtonColor = false
    prevBtn.ZIndex = 9
    Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0, 8)
    local prevStroke = Instance.new("UIStroke", prevBtn)
    prevStroke.Color = getThemeColor()
    prevStroke.Thickness = 1
    prevStroke.Transparency = 0.4

    local nextBtn = Instance.new("TextButton", skinRow)
    nextBtn.Name = "SkinNext"
    nextBtn.Size = UDim2.fromOffset(44, 32)
    nextBtn.Position = UDim2.new(1, -54, 0.5, -16)
    nextBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    nextBtn.BorderSizePixel = 0
    nextBtn.Text = ">"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.Font = Enum.Font.GothamBlack
    nextBtn.TextSize = 18
    nextBtn.AutoButtonColor = false
    nextBtn.ZIndex = 9
    Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 8)
    local nextStroke = Instance.new("UIStroke", nextBtn)
    nextStroke.Color = getThemeColor()
    nextStroke.Thickness = 1
    nextStroke.Transparency = 0.4

    local nameBox = Instance.new("Frame", skinRow)
    nameBox.Name = "SkinNameBox"
    nameBox.Size = UDim2.new(1, -120, 0, 32)
    nameBox.Position = UDim2.new(0, 60, 0.5, -16)
    nameBox.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
    nameBox.BorderSizePixel = 0
    nameBox.ZIndex = 8
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)

    outfitSelectorLabel = Instance.new("TextLabel", nameBox)
    outfitSelectorLabel.Name = "SkinLabel"
    outfitSelectorLabel.Size = UDim2.new(1, -8, 1, 0)
    outfitSelectorLabel.Position = UDim2.fromOffset(4, 0)
    outfitSelectorLabel.BackgroundTransparency = 1
    outfitSelectorLabel.Text = (OUTFITS[currentOutfitIndex] and OUTFITS[currentOutfitIndex].label) or "OFF"
    outfitSelectorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    outfitSelectorLabel.Font = Enum.Font.GothamBold
    outfitSelectorLabel.TextSize = 13
    outfitSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
    outfitSelectorLabel.ZIndex = 9

    prevBtn.MouseButton1Click:Connect(function()
        cycleOutfit(-1)
    end)
    nextBtn.MouseButton1Click:Connect(function()
        cycleOutfit(1)
    end)
    prevBtn.MouseEnter:Connect(function()
        TS:Create(prevBtn, TweenInfo.new(0.12), {BackgroundColor3 = getThemeColor()}):Play()
    end)
    prevBtn.MouseLeave:Connect(function()
        TS:Create(prevBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20, 24, 34)}):Play()
    end)
    nextBtn.MouseEnter:Connect(function()
        TS:Create(nextBtn, TweenInfo.new(0.12), {BackgroundColor3 = getThemeColor()}):Play()
    end)
    nextBtn.MouseLeave:Connect(function()
        TS:Create(nextBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20, 24, 34)}):Play()
    end)
end
mkSect(visualPage, "Intro")
do
    local row = mkRow(visualPage, 42)
    mkLabel(row, "Intro Style")
    introStyleLabel = Instance.new("TextLabel", row)
    introStyleLabel.Size = UDim2.fromOffset(72, 26)
    introStyleLabel.Position = UDim2.new(1, -150, 0.5, -13)
    introStyleLabel.BackgroundColor3 = Color3.fromRGB(8, 14, 22)
    introStyleLabel.BorderSizePixel = 0
    introStyleLabel.Text = "INTRO " .. tostring(introStyle or 2)
    introStyleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    introStyleLabel.Font = Enum.Font.GothamBold
    introStyleLabel.TextSize = 12
    introStyleLabel.ZIndex = 9
    Instance.new("UICorner", introStyleLabel).CornerRadius = UDim.new(0, 7)
    local function setIntro(v)
        introStyle = (v == 1) and 1 or 2
        if introStyleLabel then introStyleLabel.Text = "INTRO " .. tostring(introStyle) end
        if saveAllSettings then pcall(saveAllSettings, true) end
    end
    local prev = Instance.new("TextButton", row)
    prev.Size = UDim2.fromOffset(28, 26)
    prev.Position = UDim2.new(1, -186, 0.5, -13)
    prev.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
    prev.Text = "<"
    prev.TextColor3 = Color3.fromRGB(255, 255, 255)
    prev.Font = Enum.Font.GothamBlack
    prev.TextSize = 14
    prev.AutoButtonColor = false
    prev.ZIndex = 9
    Instance.new("UICorner", prev).CornerRadius = UDim.new(0, 7)
    local nextb = Instance.new("TextButton", row)
    nextb.Size = UDim2.fromOffset(28, 26)
    nextb.Position = UDim2.new(1, -70, 0.5, -13)
    nextb.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
    nextb.Text = ">"
    nextb.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextb.Font = Enum.Font.GothamBlack
    nextb.TextSize = 14
    nextb.AutoButtonColor = false
    nextb.ZIndex = 9
    Instance.new("UICorner", nextb).CornerRadius = UDim.new(0, 7)
    prev.MouseButton1Click:Connect(function() setIntro(introStyle == 1 and 2 or 1) end)
    nextb.MouseButton1Click:Connect(function() setIntro(introStyle == 1 and 2 or 1) end)
end
do
    local hint = mkRow(visualPage, 26)
    local lbl = Instance.new("TextLabel", hint)
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.fromOffset(8, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Intro 1 = minimal  ·  Intro 2 = UNO + music (next load)"
    lbl.TextColor3 = Color3.fromRGB(140, 160, 180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 8
end

mkSect(visualPage, "Interface")
setHideButtonsVisual = mkToggle(visualPage, "Hide Button", function(on) toggleHideButtons(on) end)
if setHideButtonsVisual then setHideButtonsVisual(hideButtonsEnabled) end

mkSect(visualPage, "Display")
do
local row = mkRow(visualPage, 42)
mkLabel(row, "UI Scale")
uiScaleBox = mkBox(row, uiScaleValue, 50, 56, function(v)
local n = _clamp(_floor(v+0.5), 50, 150)
uiScaleValue = n
if updateMainResponsiveScale then updateMainResponsiveScale() elseif mainUIScale then mainUIScale.Scale = n/100 end
if pbScale then pbScale.Scale = math.clamp(n/100, 0.60, 1.20) end
if refreshScalePresetButtons then pcall(refreshScalePresetButtons) end
if saveAllSettings then pcall(saveAllSettings, true) end
end)
end
do
    local row = mkRow(visualPage, 42)
    mkLabel(row, "Presets")
    local presets = {65, 75, 90, 100, 110}
    local startX = -(#presets * 34 + 8)
    for i, value in ipairs(presets) do
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.fromOffset(32, 24)
        btn.Position = UDim2.new(1, startX + (i-1)*34, 0.5, -12)
        btn.BackgroundColor3 = Color3.fromRGB(10, 16, 24)
        btn.BorderSizePixel = 0
        btn.Text = tostring(value)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.ZIndex = 9
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local st = Instance.new("UIStroke", btn)
        st.Color = Color3.fromRGB(205, 35, 55)
        st.Thickness = 0.9
        st.Transparency = 0.55
        btn.Activated:Connect(function()
            uiScaleValue = value
            if updateMainResponsiveScale then updateMainResponsiveScale() elseif mainUIScale then mainUIScale.Scale = value/100 end
            if pbScale then pbScale.Scale = math.clamp(value/100, 0.60, 1.20) end
            if uiScaleBox then uiScaleBox.Text = tostring(value) end
            if refreshScalePresetButtons then pcall(refreshScalePresetButtons) end
            if saveAllSettings then pcall(saveAllSettings, true) end
        end)
    end
end

mkSect(visualPage, "Button Scale")
do
    local row = mkRow(visualPage, 42)
    mkLabel(row, "Mobile Buttons")
    buttonScaleLabel = Instance.new("TextLabel", row)
    buttonScaleLabel.Size = UDim2.fromOffset(56, 26)
    buttonScaleLabel.Position = UDim2.new(1, -64, 0.5, -13)
    buttonScaleLabel.BackgroundColor3 = Color3.fromRGB(8, 14, 22)
    buttonScaleLabel.BorderSizePixel = 0
    buttonScaleLabel.Text = string.format("%.0f%%", (floatingButtonScale or 1)*100)
    buttonScaleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonScaleLabel.Font = Enum.Font.GothamBold
    buttonScaleLabel.TextSize = 12
    buttonScaleLabel.ZIndex = 9
    Instance.new("UICorner", buttonScaleLabel).CornerRadius = UDim.new(0, 7)
end
do
    local row = mkRow(visualPage, 42)
    mkLabel(row, "Size")
    local scales = {0.70, 0.85, 1.00, 1.15, 1.30}
    local labels = {"70", "85", "100", "115", "130"}
    local startX = -(#scales * 34 + 8)
    for i, sc in ipairs(scales) do
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.fromOffset(32, 24)
        btn.Position = UDim2.new(1, startX + (i-1)*34, 0.5, -12)
        btn.BackgroundColor3 = Color3.fromRGB(10, 16, 24)
        btn.BorderSizePixel = 0
        btn.Text = labels[i]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.ZIndex = 9
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local st = Instance.new("UIStroke", btn)
        st.Color = Color3.fromRGB(205, 35, 55)
        st.Thickness = 0.9
        st.Transparency = 0.55
        btn.Activated:Connect(function()
            floatingButtonScale = sc
            if applyFloatingButtonScale then pcall(applyFloatingButtonScale) end
            if buttonScaleLabel then buttonScaleLabel.Text = labels[i] .. "%" end
            if saveAllSettings then pcall(saveAllSettings, true) end
        end)
    end
end

mkSect(visualPage, "Effects")
setAntiLagVisual = mkToggle(visualPage, "FPS Boost", function(on)
if on then enableAntiLag() else disableAntiLag() end
end)
mkSect(visualPage, "Overlays")
playerESPSetVisual = mkToggle(visualPage, "Player ESP", function(on)
    setPlayerESPEnabled(on == true)
end)
if playerESPSetVisual then playerESPSetVisual(playerESPEnabled == true) end
tracerESPSetVisual = mkToggle(visualPage, "Tracer ESP", function(on)
    setTracerESPEnabled(on == true)
end)
if tracerESPSetVisual then tracerESPSetVisual(tracerESPEnabled == true) end
setESPLineVisual = mkToggle(visualPage, "ESP Line", function(on)
if on then startESPLine() else stopESPLine() end
end)
allLockButtonsSetVisual = mkToggle(visualPage, "All Lock Buttons", function(on)
    setAllLockButtons(on == true)
end)
if allLockButtonsSetVisual then allLockButtonsSetVisual(allLockButtonsEnabled == true) end
local configPage = contentPages["Config"]
mkSect(configPage, "Automation")
mkSect(configPage, "Config")
autoSaveSetVisual = mkToggle(configPage, "Auto Save", function(on)
    autoSaveEnabled = on == true
    if autoSaveSetVisual then autoSaveSetVisual(autoSaveEnabled) end
    if saveAllSettings then pcall(saveAllSettings, true) end
end)
if autoSaveSetVisual then autoSaveSetVisual(autoSaveEnabled ~= false) end
do
    local row = mkRow(configPage, 42)
    local saveBtn = Instance.new("TextButton", row)
    saveBtn.Size = UDim2.new(1, -8, 0, 32)
    saveBtn.Position = UDim2.new(0, 4, 0.5, -16)
    saveBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
    saveBtn.Text = "SAVE CONFIG"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 13
    saveBtn.AutoButtonColor = true
    saveBtn.ZIndex = 9
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    saveBtn.MouseButton1Click:Connect(function()
        local ok = false
        if saveAllSettings then ok = saveAllSettings(true) end
        saveBtn.Text = ok and "SAVED!" or "SAVE FAILED"
        task.delay(1.2, function() if saveBtn and saveBtn.Parent then saveBtn.Text = "SAVE CONFIG" end end)
    end)
end
setInstaGrab = mkToggle(configPage, "Auto Steal", function(on)
CONFIG.AUTO_STEAL_ENABLED = on
if on then pcall(startAutoSteal) else stopAutoSteal() end
updateProgressBarVisibility()
end)
do
local row = mkRow(configPage, 42)
mkLabel(row, "Steal Radius")
radInput = mkBox(row, CONFIG.STEAL_RANGE, 50, 56, function(v)
if v and v >= 5 and v <= 300 then
CONFIG.STEAL_RANGE = _floor(v+0.5)
Steal.StealRadius = CONFIG.STEAL_RANGE
radInput.Text = tostring(CONFIG.STEAL_RANGE)
saveAllSettings(true)
end
end)
end
mkSect(configPage, "Management")
    do
        local row = mkRow(configPage, 44)
        row.Size = UDim2.new(1, 0, 0, 40)
        local saveBtn = Instance.new("TextButton", row)
        saveBtn.Size = UDim2.new(1, -12, 0.8, 0)
        saveBtn.Position = UDim2.new(0, 6, 0.1, 0)
        saveBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
        saveBtn.BorderSizePixel = 0
        saveBtn.Text = "SAVE CONFIG"
        saveBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.TextSize = 13
        saveBtn.AutoButtonColor = false
        saveBtn.ZIndex = 8
        Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 10)
        local saveStroke = Instance.new("UIStroke", saveBtn)
        saveStroke.Color = getThemeColor()
        saveStroke.Thickness = 1.5
        saveStroke.Transparency = 0.4
        saveBtn.MouseEnter:Connect(function()
            TS:Create(saveBtn, TweenInfo.new(0.15), {BackgroundColor3 = getThemeColor()}):Play()
            TS:Create(saveBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        end)
        saveBtn.MouseLeave:Connect(function()
            TS:Create(saveBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
            TS:Create(saveBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(20, 20, 25)}):Play()
        end)
        saveBtn.MouseButton1Click:Connect(function()
            local ok = saveAllSettings(true)
            saveBtn.Text = ok and "SAVED" or "ERROR"
            task.delay(1.2, function()
                if saveBtn and saveBtn.Parent then saveBtn.Text = "SAVE CONFIG" end
            end)
        end)
    end
do
local row = mkRow(configPage, 44)
row.Size = UDim2.new(1, 0, 0, 40)
local resetPosBtn = Instance.new("TextButton", row)
resetPosBtn.Size = UDim2.new(1, -12, 0.8, 0)
resetPosBtn.Position = UDim2.new(0, 6, 0.1, 0)
resetPosBtn.BackgroundColor3 = Color3.fromRGB(115, 170, 210)
resetPosBtn.BorderSizePixel = 0
resetPosBtn.Text = "RESET POSITIONS"
resetPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetPosBtn.Font = Enum.Font.GothamBold
resetPosBtn.TextSize = 13
resetPosBtn.AutoButtonColor = false
resetPosBtn.ZIndex = 8
Instance.new("UICorner", resetPosBtn).CornerRadius = UDim.new(0, 10)
local resetStroke = Instance.new("UIStroke", resetPosBtn)
resetStroke.Color = getThemeColor()
resetStroke.Thickness = 1.5
resetStroke.Transparency = 0.4
resetPosBtn.MouseEnter:Connect(function()
TS:Create(resetPosBtn, TweenInfo.new(0.15), {BackgroundColor3 = getThemeColor()}):Play()
TS:Create(resetPosBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
resetPosBtn.MouseLeave:Connect(function()
TS:Create(resetPosBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(115, 170, 210)}):Play()
TS:Create(resetPosBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
local resetDebounce = false
resetPosBtn.MouseButton1Click:Connect(function()
if resetDebounce then return end
resetDebounce = true
resetFloatingPositions()
resetPosBtn.Text = "RESET"
task.delay(1.2, function()
if resetPosBtn and resetPosBtn.Parent then
resetPosBtn.Text = "RESET POSITIONS"
resetDebounce = false
end
end)
end)
end
do
local row = mkRow(configPage, 44)
row.Size = UDim2.new(1, 0, 0, 40)
local delBtn = Instance.new("TextButton", row)
delBtn.Size = UDim2.new(1, -12, 0.8, 0)
delBtn.Position = UDim2.new(0, 6, 0.1, 0)
delBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
delBtn.BorderSizePixel = 0
delBtn.Text = "RESET ALL SETTINGS"
delBtn.TextColor3 = Color3.fromRGB(170, 30, 50)
delBtn.Font = Enum.Font.GothamBold
delBtn.TextSize = 13
delBtn.AutoButtonColor = false
delBtn.ZIndex = 8
Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 10)
local delStroke = Instance.new("UIStroke", delBtn)
delStroke.Color = Color3.fromRGB(200, 60, 80)
delStroke.Thickness = 1.5
delStroke.Transparency = 0.4
delBtn.MouseEnter:Connect(function()
TS:Create(delBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 50, 70)}):Play()
TS:Create(delBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
delBtn.MouseLeave:Connect(function()
TS:Create(delBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
TS:Create(delBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(170, 30, 50)}):Play()
end)
local deleteState = 0
local originalDeleteText = "RESET ALL SETTINGS"
local delDebounce = false
delBtn.MouseButton1Click:Connect(function()
if delDebounce then return end
if deleteState == 0 then
deleteState = 1
delBtn.Text = "CONFIRM?"
delBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
delBtn.TextColor3 = Color3.fromRGB(160, 0, 0)
task.delay(2, function()
if delBtn and delBtn.Parent and deleteState == 1 then
deleteState = 0
delBtn.Text = originalDeleteText
delBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
delBtn.TextColor3 = Color3.fromRGB(170, 30, 50)
end
end)
elseif deleteState == 1 then
delDebounce = true
local invoked, success = pcall(resetToFactoryDefaults)
success = invoked and success
delBtn.Text = success and "SETTINGS RESET" or "ERROR"
delBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
delBtn.TextColor3 = Color3.fromRGB(170, 30, 50)
deleteState = 0
task.delay(1.5, function()
if delBtn and delBtn.Parent then
delBtn.Text = originalDeleteText
delBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
delBtn.TextColor3 = Color3.fromRGB(170, 30, 50)
delDebounce = false
end
end)
end
end)
end
local keyPage = contentPages["Keybinds"]
mkSect(keyPage, "Keybinds")
do
local resetRow = mkRow(keyPage, 40)
mkLabel(resetRow, "Reset All Keybinds")
local resetBtn = Instance.new("TextButton", resetRow)
resetBtn.Size = UDim2.new(0, 92, 0, 24)
resetBtn.Position = UDim2.new(1, -100, 0.5, -12)
resetBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
resetBtn.BorderSizePixel = 0
resetBtn.Text = "RESET"
resetBtn.TextColor3 = Color3.fromRGB(170, 30, 50)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 11
resetBtn.ZIndex = 9
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 7)
resetBtn.MouseButton1Click:Connect(function()
for key, value in pairs(DEFAULT_KB) do
if KB[key] then KB[key].kb = value.kb; KB[key].gp = value.gp end
end
for _, ref in ipairs(keyButtonRefs) do
local entry = ref.entry
ref.btn.Text = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
end
resetBtn.Text = "RESET"
task.defer(function() saveAllSettings(true) end)
task.delay(1, function()
if resetBtn and resetBtn.Parent then resetBtn.Text = "RESET" end
end)
end)
end
mkSect(keyPage, "Movement")
addKeybindRow(keyPage, "Carry Mode", KB.CarryToggle)
addKeybindRow(keyPage, "Lagger Mode", KB.LaggerMode)
addKeybindRow(keyPage, "Auto Left", KB.AutoLeft)
addKeybindRow(keyPage, "Auto Right", KB.AutoRight)
mkSect(keyPage, "Combat")
addKeybindRow(keyPage, "Auto Bat", KB.AutoBat)
addKeybindRow(keyPage, "Bat Bypass V2", KB.AntiBypass)
mkSect(keyPage, "Utility")
addKeybindRow(keyPage, "Drop Brainrot", KB.DropBrainrot)
addKeybindRow(keyPage, "Insta Reset", KB.InstaReset)
addKeybindRow(keyPage, "TP Down", KB.TPFloor)
addKeybindRow(keyPage, "Hide GUI", KB.GuiHide)
local spacer = Instance.new("Frame", keyPage)
spacer.Size = UDim2.new(1, 0, 0, 16)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = getNextOrder(keyPage)
spacer.ZIndex = 7
local WIDTH, HEIGHT = 320, 58
local ACCENT_COLOR = Color3.fromRGB(145, 95, 185)
local TRACK_COLOR = Color3.fromRGB(0, 0, 0)
local PURPLE_COLOR = Color3.fromRGB(170, 130, 215)
pbFrame = Instance.new("Frame", gui)
pbFrame.Name = "YoutAutoGrabBar"
pbFrame.Size = UDim2.fromOffset(WIDTH, HEIGHT)
pbFrame.Position = UDim2.new(0.5, 0, 0.82, 0)
pbFrame.AnchorPoint = Vector2.new(0.5, 0.5)
pbFrame.BackgroundColor3 = Color3.fromRGB(4, 10, 18)
pbFrame.BackgroundTransparency = 1
pbFrame.BorderSizePixel = 0
pbFrame.Active = true
pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED
pbFrame.ZIndex = 500
pbFrame.ClipsDescendants = true
local stealBarImg = Instance.new("ImageLabel", pbFrame)
stealBarImg.Name = "StealBarSkin"
stealBarImg.Size = UDim2.new(1, 0, 1, 0)
stealBarImg.Position = UDim2.new(0, 0, 0, 0)
stealBarImg.BackgroundTransparency = 1
stealBarImg.Image = (type(AUTO_STEAL_BAR_IMAGE) == "string" and AUTO_STEAL_BAR_IMAGE) or "rbxassetid://118269189807670"
stealBarImg.ScaleType = Enum.ScaleType.Stretch
stealBarImg.ZIndex = 501
stealBarImg.Active = false
pbScale = Instance.new("UIScale", pbFrame)
pbScale.Scale = math.clamp((tonumber(uiScaleValue) or 88) / 100, 0.60, 1.20)
pbDeviceScale = 1
if savedProgressBarPos then
pbFrame.Position = UDim2.new(savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or 0, savedProgressBarPos.YScale or 0.82, savedProgressBarPos.YOffset or 0)
end
Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(0, 14)
local pbOuterStroke = Instance.new("UIStroke", pbFrame)
pbOuterStroke.Name = "OuterStroke"
pbOuterStroke.Color = Color3.fromRGB(205, 35, 55)
pbOuterStroke.Thickness = 1.7
pbOuterStroke.Transparency = 0.18
-- subtle glass gradient on steal bar
local pbGrad = pbFrame:FindFirstChild("UNOStealGrad")
if not pbGrad then
pbGrad = Instance.new("UIGradient")
pbGrad.Name = "UNOStealGrad"
pbGrad.Parent = pbFrame
end
pbGrad.Rotation = 90
pbGrad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(18, 36, 56)),
ColorSequenceKeypoint.new(0.55, Color3.fromRGB(6, 12, 22)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(3, 6, 12)),
})
local autoStealTitle = Instance.new("TextLabel", pbFrame)
autoStealTitle.Name = "AutoStealTitle"
autoStealTitle.Size = UDim2.new(0, 68, 0, 18)
autoStealTitle.Position = UDim2.new(0, 9, 0, 4)
autoStealTitle.BackgroundTransparency = 1
autoStealTitle.Text = "AUTO STEAL"
autoStealTitle.TextColor3 = Color3.fromRGB(200, 235, 255)
autoStealTitle.Font = Enum.Font.GothamBlack
autoStealTitle.TextSize = 11
autoStealTitle.TextStrokeColor3 = Color3.fromRGB(20, 100, 180)
autoStealTitle.TextStrokeTransparency = 0.45
autoStealTitle.TextXAlignment = Enum.TextXAlignment.Left
autoStealTitle.ZIndex = 510
local percentTop = Instance.new("TextLabel", pbFrame)
percentTop.Name = "PercentTop"
percentTop.Size = UDim2.new(0, 42, 0, 20)
percentTop.Position = UDim2.new(0, 82, 0, 2)
percentTop.BackgroundTransparency = 1
percentTop.Text = "0%"
percentTop.TextColor3 = Color3.fromRGB(255, 255, 255)
percentTop.Font = Enum.Font.GothamBlack
percentTop.TextSize = 13
percentTop.TextXAlignment = Enum.TextXAlignment.Center
percentTop.ZIndex = 510
local radiusLbl = Instance.new("TextLabel", pbFrame)
radiusLbl.Name = "RadiusLbl"
radiusLbl.Size = UDim2.new(0, 72, 0, 18)
radiusLbl.Position = UDim2.new(0, 132, 0, 4)
radiusLbl.BackgroundTransparency = 1
radiusLbl.Text = "R: " .. tostring(CONFIG.STEAL_RANGE or 61)
radiusLbl.TextColor3 = ACCENT_COLOR
radiusLbl.Font = Enum.Font.GothamBold
radiusLbl.TextSize = 8
radiusLbl.TextXAlignment = Enum.TextXAlignment.Center
radiusLbl.TextYAlignment = Enum.TextYAlignment.Center
radiusLbl.ZIndex = 510
local fpsNeon = Instance.new("TextLabel", pbFrame)
fpsNeon.Name = "FPSNeon"
fpsNeon.Size = UDim2.new(0, 104, 0, 18)
fpsNeon.Position = UDim2.new(1, -112, 0, 4)
fpsNeon.BackgroundTransparency = 1
fpsNeon.Text = "FPS:60 | 0ms"
fpsNeon.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsNeon.Font = Enum.Font.GothamBold
fpsNeon.TextSize = 8
fpsNeon.TextWrapped = true
fpsNeon.TextXAlignment = Enum.TextXAlignment.Center
fpsNeon.TextYAlignment = Enum.TextYAlignment.Center
fpsNeon.ZIndex = 510
local pbBarBg = Instance.new("Frame", pbFrame)
pbBarBg.Name = "BarBg"
pbBarBg.Size = UDim2.new(1, -20, 0, 14)
pbBarBg.Position = UDim2.new(0, 10, 0, 32)
pbBarBg.BackgroundColor3 = Color3.fromRGB(2, 6, 12)
pbBarBg.BorderSizePixel = 0
pbBarBg.ClipsDescendants = true
pbBarBg.ZIndex = 508
pbBarBg.BackgroundTransparency = 0.05
Instance.new("UICorner", pbBarBg).CornerRadius = UDim.new(1,0)
local pbBarStroke = Instance.new("UIStroke", pbBarBg)
pbBarStroke.Color = Color3.fromRGB(56, 160, 230)
pbBarStroke.Thickness = 1.2
pbBarStroke.Transparency = 0.35
progressFill = Instance.new("Frame", pbBarBg)
progressFill.Name = "Fill"
progressFill.AnchorPoint = Vector2.new(0, 0)
progressFill.Position = UDim2.new(0, 0, 0, 0)
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(205, 35, 55)
progressFill.BackgroundTransparency = 0
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 509
progressFill.ClipsDescendants = true
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
local fillGrad = Instance.new("UIGradient", progressFill)
fillGrad.Rotation = 0
fillGrad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 240, 255)),
ColorSequenceKeypoint.new(0.45, Color3.fromRGB(205, 35, 55)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 100, 190)),
})
local _autoStealFillTween
setProgressFillSmooth = function(targetSize)
if not progressFill or not progressFill.Parent then return end
if _autoStealFillTween then pcall(function() _autoStealFillTween:Cancel() end) end
local pad = tonumber(progressFill:GetAttribute("StylePad")) or 0
if pad > 0 and typeof(targetSize) == "UDim2" then
    local s = targetSize.X.Scale
    targetSize = UDim2.new(s, -pad * 2, 1, -pad * 2)
    progressFill.Position = UDim2.new(0, pad, 0, pad)
else
    progressFill.Position = UDim2.new(0, 0, 0, 0)
end
_autoStealFillTween = TS:Create(progressFill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
_autoStealFillTween:Play()
end
local fillGrad = Instance.new("UIGradient", progressFill)
fillGrad.Rotation = 0
pcall(function() if applyStealBarStyle then applyStealBarStyle(stealBarStyle or "V1") end end)

fillGrad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(120, 210, 255)),
ColorSequenceKeypoint.new(0.45, Color3.fromRGB(205, 35, 55)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 110, 200)),
})
fillGrad.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0.00, 0.08),
NumberSequenceKeypoint.new(0.42, 0.02),
NumberSequenceKeypoint.new(0.70, 0.05),
NumberSequenceKeypoint.new(1.00, 0.12),
})
local dotsContainer = Instance.new("Frame", progressFill)
dotsContainer.Name = "Dots"
dotsContainer.Size = UDim2.new(1, 0, 1, 0)
dotsContainer.Position = UDim2.new(0, 0, 0, 0)
dotsContainer.BackgroundTransparency = 1
dotsContainer.ZIndex = 510
local _stealDots = {}
for i = 1, 24 do
local dot = Instance.new("Frame", dotsContainer)
dot.Size = UDim2.fromOffset(2, 2)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
local x = ((i - 1) % 12) / 11
local y = (i <= 12) and 0.34 or 0.68
dot.Position = UDim2.new(x, 0, y, 0)
dot.BackgroundColor3 = Color3.fromRGB(205, 209, 216)
dot.BackgroundTransparency = 0.5
dot.BorderSizePixel = 0
dot.ZIndex = 511
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
table.insert(_stealDots, dot)
end
progressPct = Instance.new("TextLabel", pbBarBg)
progressPct.Name = "ProgressPct"; progressPct.Size = UDim2.new(1,0,1,0); progressPct.BackgroundTransparency = 1
progressPct.Text = "0%"; progressPct.TextTransparency = 1; progressPct.ZIndex = 1
progressPct:GetPropertyChangedSignal("Text"):Connect(function() percentTop.Text = progressPct.Text end)
task.spawn(function()
local lastFrame = _tick(); local fpsSamples = {}; local fpsAvg = 60
local conn = RunService.RenderStepped:Connect(function()
local now=_tick(); local dt=now-lastFrame; lastFrame=now
if dt>0 then table.insert(fpsSamples,1/dt); if #fpsSamples>30 then table.remove(fpsSamples,1) end
local sum=0; for _,v in ipairs(fpsSamples) do sum=sum+v end; fpsAvg=sum/#fpsSamples end
end)
while pbFrame and pbFrame.Parent do
local ping=0; pcall(function() ping=LP:GetNetworkPing()*1000 end)
fpsNeon.Text=string.format("FPS:%d | %dms", _floor(fpsAvg+0.5), _floor(ping+0.5))
radiusLbl.Text="R: "..tostring(CONFIG.STEAL_RANGE or Steal.StealRadius or 61)
task.wait(0.75)
end
if conn then conn:Disconnect() end
end)
_G._youtGrabBillboardShow = function() end
_G._youtGrabBillboardHide = function() end
drag(pbFrame)
end
function createMobilePanel()
local panel = Instance.new("ScreenGui")
panel.Name = "UNOMobilePanel"
panel.ResetOnSpawn = false
panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
local okPanel = pcall(function() panel.Parent = game:GetService("CoreGui") end)
if not okPanel then panel.Parent = LP:WaitForChild("PlayerGui") end
local BTN_W, BTN_H = 54, 54
local buttons = {}
local buttonNames = {"DropBR", "AutoLeft", "AutoBat", "AutoRight", "TpDown", "Carry", "Lagger1", "Lagger2"}
local buttonTexts = {"DROP\nBR", "AUTO\nLEFT", "BAT\nAIMBOT", "AUTO\nRIGHT", "TP\nDOWN", "CARRY\nSPD", "LAGGER\nNORMAL", "LAGGER\nCARRY"}
local function createButton(name, text, order, isToggle, callback)
local btn = Instance.new("TextButton", panel)
btn.Name = name
btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
btn.BorderSizePixel = 0
btn.Text = ""
btn.AutoButtonColor = false
btn.ZIndex = 10
btn.AnchorPoint = Vector2.new(0, 0)
local savedPos = savedButtonPositions[name]
if savedPos and savedPos.Layout == "UpperRightV2" and tonumber(savedPos.XScale) and tonumber(savedPos.YScale) and tonumber(savedPos.X) then
btn.Position = UDim2.new(savedPos.XScale, savedPos.X, savedPos.YScale, savedPos.Y or 0)
else
local defX, defY = getDefaultButtonPosition(name)
btn.Position = UDim2.new(1, defX, 0, defY)
end
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn.BackgroundTransparency = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)
local bgGrad = Instance.new("UIGradient", btn)
bgGrad.Name = "BtnGrad"
bgGrad.Enabled = false
local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(70, 150, 210)
stroke.Thickness = 1.1
stroke.Transparency = 0.35
stroke.Name = "NormalStroke"
local sheen = Instance.new("Frame", btn)
sheen.Name = "UNOSheen"
sheen.Size = UDim2.new(1, 0, 0, 2)
sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sheen.BackgroundTransparency = 0.78
sheen.BorderSizePixel = 0
sheen.ZIndex = 12
Instance.new("UICorner", sheen).CornerRadius = UDim.new(1, 0)
local buttonSkinImage = Instance.new("ImageLabel", btn)
buttonSkinImage.Name = "ButtonSkinImage"
buttonSkinImage.Size = UDim2.fromScale(1, 1)
buttonSkinImage.Position = UDim2.fromScale(0, 0)
buttonSkinImage.BackgroundTransparency = 1
buttonSkinImage.BorderSizePixel = 0
buttonSkinImage.Image = ""
buttonSkinImage.ImageColor3 = Color3.new(1, 1, 1)
buttonSkinImage.ImageTransparency = 0
buttonSkinImage.ImageRectSize = Vector2.zero
buttonSkinImage.ScaleType = Enum.ScaleType.Stretch
buttonSkinImage.Active = false
buttonSkinImage.Selectable = false
buttonSkinImage.Visible = false
buttonSkinImage.ZIndex = 10
Instance.new("UICorner", buttonSkinImage).CornerRadius = UDim.new(0, 12)
local label = Instance.new("TextLabel", btn)
label.Name = "TextLabel"
label.Size = UDim2.new(1, 0, 1, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.Text = text
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBlack
label.TextSize = 10
label.TextWrapped = true
label.TextStrokeTransparency = 1
label.ZIndex = 11
local uiScale = Instance.new("UIScale", btn)
uiScale.Scale = floatingButtonScale
table.insert(_floatingUIScales, uiScale)
local active = false
local function setActive(state)
active = state
btn:SetAttribute("MobActive", state and true or false)
paintFloatingBtn(btn, state)
end
setActive(false)
local dragging = false
local hasMoved = false
local dragStart = nil
local startPos = nil
local movedDistance = 0
local function onInputBegan(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true; hasMoved = false; movedDistance = 0
dragStart = input.Position; startPos = btn.Position
_isDraggingButton = true
end
end
local function onInputChanged(input)
if not dragging then return end
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
local delta = input.Position - dragStart
movedDistance = delta.Magnitude
if not uiLocked then
hasMoved = true
btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end
end
local function onInputEnded(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
if dragging then
if movedDistance < 12 then
if isToggle then
if callback then callback(setActive) end
else
if callback then callback(setActive, active) end
end
elseif not uiLocked and hasMoved then
savedButtonPositions[name] = {X = btn.Position.X.Offset, Y = btn.Position.Y.Offset, XScale = btn.Position.X.Scale, YScale = btn.Position.Y.Scale, Layout = "UpperRightV2"}
task.defer(function() pcall(saveAllSettings, true) end)
end
dragging = false; hasMoved = false
dragStart = nil; startPos = nil; movedDistance = 0
_isDraggingButton = false
end
end
end
btn.InputBegan:Connect(onInputBegan)
btn.InputChanged:Connect(onInputChanged)
btn.InputEnded:Connect(onInputEnded)
UIS.InputEnded:Connect(function(inp)
if inp.UserInputType ~= Enum.UserInputType.Touch
and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
if dragging then onInputEnded(inp) end
end)
buttons[name] = {btn = btn, setActive = setActive, label = label}
applyNoxButtonImage(buttonImageIndex)
return setActive
end
for i, name in ipairs(buttonNames) do
local text = buttonTexts[i]
local callback
if name == "DropBR" then
callback = function(setActive)
if autoBatEnabled then return end
setActive(true)
executeDropWithToggle(function(v)
if dropBrainrotSetVisual then dropBrainrotSetVisual(v) end
end)
task.delay(0.3, function() setActive(false) end)
end
elseif name == "AutoLeft" then
callback = function(setActive)
autoLeftEnabled = not autoLeftEnabled
setActive(autoLeftEnabled)
if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
end
elseif name == "AutoBat" then
callback = function(setActive)
if not autoBatEnabled then enableAutoBat() else disableAutoBat() end
setActive(autoBatEnabled)
end
elseif name == "AutoRight" then
callback = function(setActive)
autoRightEnabled = not autoRightEnabled
setActive(autoRightEnabled)
if autoRightEnabled then startAutoRight() else stopAutoRight() end
if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
end
elseif name == "TpDown" then
callback = function(setActive)
doTpDown()
setActive(true)
task.delay(0.2, function() setActive(false) end)
end
elseif name == "Carry" then
callback = function(setActive)
if not speedMode then
speedMode = true; laggerToggled = false; laggerCarryToggled = false; setActive(true)
if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
else
speedMode = false; setActive(false)
end
refreshSpeedModeLabel()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
end
elseif name == "Lagger1" then
callback = function(setActive)
if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end
if not laggerToggled then
laggerToggled = true; laggerCarryToggled = false; setActive(true)
if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
else
laggerToggled = false; setActive(false)
end
refreshSpeedModeLabel()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
end
elseif name == "Lagger2" then
callback = function(setActive)
if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end
if not laggerCarryToggled then
laggerCarryToggled = true; laggerToggled = false; setActive(true)
if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
else
laggerCarryToggled = false; setActive(false)
end
refreshSpeedModeLabel()
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
end
elseif name == "SpeedPlus" then
callback = function(setActive)
CS = math.clamp((CS or 29) + 2, 10, 120)
if carryBox then carryBox.Text = tostring(CS) end
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
pcall(saveAllSettings, true)
setActive(true)
task.delay(0.15, function() setActive(false) end)
end
elseif name == "SpeedMinus" then
callback = function(setActive)
CS = math.clamp((CS or 29) - 2, 10, 120)
if carryBox then carryBox.Text = tostring(CS) end
if _G.__YoutApplySpeedNow then pcall(_G.__YoutApplySpeedNow) end
pcall(saveAllSettings, true)
setActive(true)
task.delay(0.15, function() setActive(false) end)
end
end
local setActive = createButton(name, text, i-1, true, callback)
if name == "AutoBat" then mobSetAutoBat = setActive end
if name == "AutoLeft" then mobSetAutoLeft = setActive end
if name == "AutoRight" then mobSetAutoRight = setActive end
if name == "DropBR" then mobSetDropBR = setActive end
if name == "TpDown" then mobSetTpDown = setActive end
if name == "Carry" then mobSetCarry = setActive end
if name == "Lagger1" then mobSetLagger1 = setActive end
if name == "Lagger2" then mobSetLagger2 = setActive end
end
if buttons.AutoBat and buttons.AutoBat.setActive then buttons.AutoBat.setActive(autoBatEnabled) end
if buttons.AutoLeft and buttons.AutoLeft.setActive then buttons.AutoLeft.setActive(autoLeftEnabled) end
if buttons.AutoRight and buttons.AutoRight.setActive then buttons.AutoRight.setActive(autoRightEnabled) end
if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(speedMode) end
if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(laggerToggled) end
if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(laggerCarryToggled) end
return panel
end
function createAntiBypassFloatingButton()
local panel = Instance.new("ScreenGui")
panel.Name = "BatBypassButton"
panel.ResetOnSpawn = false
panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
panel.DisplayOrder = 80
pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
local okPanel = pcall(function() panel.Parent = game:GetService("CoreGui") end)
if not okPanel then panel.Parent = LP:WaitForChild("PlayerGui") end
local btnFrame = Instance.new("Frame", panel)
btnFrame.Size = UDim2.new(0, 54, 0, 54)
btnFrame.Name = "Frame"
if antiBypassFloatingPos and antiBypassFloatingPos.Layout == "UpperRightSpecialV3" then
btnFrame.Position = UDim2.new(antiBypassFloatingPos.XScale or 0, antiBypassFloatingPos.XOffset or 114, antiBypassFloatingPos.YScale or 0, antiBypassFloatingPos.YOffset or 72)
else
local x, y = getDefaultSpecialButtonPosition("BatBypass")
btnFrame.Position = UDim2.new(1, x, 0, y)
end
btnFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
btnFrame.BorderSizePixel = 0
btnFrame.Active = true
btnFrame.Visible = not hideButtonsEnabled
btnFrame.ZIndex = 20
Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 6)
local bgGrad = Instance.new("UIGradient", btnFrame); bgGrad.Name = "BtnGrad"; bgGrad.Rotation = 90
local label = Instance.new("TextLabel", btnFrame)
label.Name = "TextLabel"; label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1
label.Text = "BAT\nBYPASS"; label.TextColor3 = Color3.fromRGB(255,255,255)
label.Font = Enum.Font.GothamBlack; label.TextSize = 10; label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Center; label.TextYAlignment = Enum.TextYAlignment.Center
label.ZIndex = 21
local uiScale = Instance.new("UIScale", btnFrame); uiScale.Scale = floatingButtonScale
table.insert(_floatingUIScales, uiScale)
local function setActive(state) paintFloatingBtn(btnFrame, state) end
antiBypassFloatingSetVisual = setActive; setActive(antiBypassEnabled)
-- clickable overlay (fixes press when at default position)
local clickBtn = Instance.new("TextButton", btnFrame)
clickBtn.Name = "ClickHit"
clickBtn.Size = UDim2.fromScale(1, 1)
clickBtn.Position = UDim2.fromScale(0, 0)
clickBtn.BackgroundTransparency = 1
clickBtn.Text = ""
clickBtn.ZIndex = 25
clickBtn.AutoButtonColor = false
clickBtn.Active = true
local dragging, hasMoved, dragStart, startPos = false, false, nil, nil
local function onBegan(inp)
if uiLocked then return end
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position
end
end
clickBtn.InputBegan:Connect(onBegan)
btnFrame.InputBegan:Connect(function(inp)
if uiLocked then return end
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position
end
end)
btnFrame.InputChanged:Connect(function(inp)
if not dragging then return end
if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
local delta = inp.Position - dragStart
if delta.Magnitude > 12 then hasMoved = true end
if hasMoved and not uiLocked then
btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end
end)
local function onEnded(inp)
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
if dragging then
if not hasMoved then
toggleAntiBypass()
setActive(antiBypassEnabled)
elseif not uiLocked and hasMoved then
antiBypassFloatingPos = {XScale=btnFrame.Position.X.Scale,XOffset=btnFrame.Position.X.Offset,YScale=btnFrame.Position.Y.Scale,YOffset=btnFrame.Position.Y.Offset,Layout="UpperRightSpecialV3"}
task.defer(function() pcall(saveAllSettings, true) end)
end
dragging = false
hasMoved = false
end
end
end
btnFrame.InputEnded:Connect(onEnded)
clickBtn.InputEnded:Connect(onEnded)
clickBtn.MouseButton1Click:Connect(function()
if not hasMoved and not dragging then
toggleAntiBypass()
setActive(antiBypassEnabled)
end
end)
antiBypassFloatingButton = panel
return panel
end
function createInstaResetFloatingButton()
local panel = Instance.new("ScreenGui")
panel.Name = "InstaResetButton"
panel.ResetOnSpawn = false
panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
panel.DisplayOrder = 23
pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
local okPanel = pcall(function() panel.Parent = game:GetService("CoreGui") end)
if not okPanel then panel.Parent = LP:WaitForChild("PlayerGui") end
local btnFrame = Instance.new("Frame", panel)
btnFrame.Size = UDim2.new(0, 54, 0, 54)
btnFrame.Name = "Frame"
if instaResetFloatingPos and instaResetFloatingPos.Layout == "UpperRightSpecialV3" then
btnFrame.Position = UDim2.new(instaResetFloatingPos.XScale or 0, instaResetFloatingPos.XOffset or 114, instaResetFloatingPos.YScale or 0, instaResetFloatingPos.YOffset or 12)
else
local x, y = getDefaultSpecialButtonPosition("InstaReset")
btnFrame.Position = UDim2.new(1, x, 0, y)
end
btnFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
btnFrame.BorderSizePixel = 0
btnFrame.ZIndex = 20
Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(1, 0)
local resetOutline = Instance.new("UIStroke", btnFrame)
resetOutline.Name = "PurpleOutline"
resetOutline.Color = Color3.fromRGB(205, 35, 55)
resetOutline.Thickness = 1.15
resetOutline.Transparency = 0.3
local bgGrad = Instance.new("UIGradient", btnFrame)
bgGrad.Name = "BtnGrad"
bgGrad.Rotation = 125
bgGrad.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(28, 32, 40)),
ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 14, 18)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(6, 7, 10)),
})
local label = Instance.new("TextLabel", btnFrame)
label.Size = UDim2.new(1, -4, 1, -4)
label.Position = UDim2.new(0, 2, 0, 2)
label.BackgroundTransparency = 1
label.Text = "RESET"
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.TextColor3 = Color3.fromRGB(230, 240, 255)
label.Font = Enum.Font.GothamBlack
label.TextSize = 11
label.TextWrapped = false
label.ZIndex = 21
paintFloatingBtn(btnFrame, false)
local uiScale = Instance.new("UIScale", btnFrame)
uiScale.Scale = floatingButtonScale
table.insert(_floatingUIScales, uiScale)
local dragging, hasMoved, dragStart, startPos, activeInput
local RESET_TAP_THRESHOLD = 12
local function pointInside(pos)
local ap = btnFrame.AbsolutePosition
local as = btnFrame.AbsoluteSize
return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end
local function setActive(state)
if state then
TS:Create(btnFrame, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
TS:Create(label, TweenInfo.new(0.05), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
else
paintFloatingBtn(btnFrame, false)
end
end
btnFrame.InputBegan:Connect(function(inp)
if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
if activeInput then return end
activeInput = inp
dragging = true; hasMoved = false
dragStart = inp.Position; startPos = btnFrame.Position
end
end)
UIS.InputChanged:Connect(function(inp)
if not dragging or not activeInput then return end
local isTouchMove = activeInput.UserInputType == Enum.UserInputType.Touch and inp == activeInput
local isMouseMove = activeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseMovement
if not isTouchMove and not isMouseMove then return end
local delta = inp.Position - dragStart
if delta.Magnitude > RESET_TAP_THRESHOLD then hasMoved = true end
if hasMoved and not uiLocked then
btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
UIS.InputEnded:Connect(function(inp)
if inp ~= activeInput then return end
if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
if dragging then
local delta = inp.Position - dragStart
local validTap = not hasMoved and delta.Magnitude <= RESET_TAP_THRESHOLD and pointInside(inp.Position)
if validTap then
setActive(true)
if _G.InstaReset and _G.InstaReset.Trigger then _G.InstaReset.Trigger() end
task.delay(0.2, function() setActive(false) end)
elseif not uiLocked and hasMoved then
instaResetFloatingPos = {XScale = btnFrame.Position.X.Scale, XOffset = btnFrame.Position.X.Offset, YScale = btnFrame.Position.Y.Scale, YOffset = btnFrame.Position.Y.Offset, Layout = "UpperRightSpecialV3"}
pcall(saveAllSettings, true)
end
dragging = false; hasMoved = false
activeInput = nil
end
end)
instaResetFloatingButton = panel
return panel
end
batCounterV2Enabled = false
setBatCounterV2Visual = nil
function startBatCounterV2() end
function stopBatCounterV2() end
function toggleBatCounterV2() return false end
function executeBatCounterV2() end
function updateUIFromLoaded()
task.wait()
if normalBox then normalBox.Text = tostring(NS) end
if carryBox then carryBox.Text = tostring(CS) end
if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED) end
if lagger2Box then lagger2Box.Text = tostring(LAGGER_CARRY_SPEED) end
if batSpeedBox then batSpeedBox.Text = tostring(getAimbotChaseSpeed()) end
if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
refreshSpeedModeLabel()
if autoBrainrotSpeedSetVisual then autoBrainrotSpeedSetVisual(autoBrainrotSpeedEnabled) end

if autoBrainrotSpeedEnabled then setAutoBrainrotSpeedEnabled(true) end
if autoSpinEnabled and setAutoSpinEnabled then setAutoSpinEnabled(true) end
if autoSpinSetVisual then autoSpinSetVisual(autoSpinEnabled) end
if infJumpSpeedSetVisual then infJumpSpeedSetVisual(SpeedHoldInfJump and SpeedHoldInfJump.enabled == true) end
if spamBatSetVisual then spamBatSetVisual(spamBatEnabled) end
if stretchSetVisual then stretchSetVisual(stretchEnabled) end
if colorSelectorLabel then colorSelectorLabel.Text = currentColorTheme or "Normal" end
if animSelectorLabel then animSelectorLabel.Text = currentAnimPack or "Off" end
local fontValue = Enum.Font[_G.__NoxUiFont or "Gotham"] or Enum.Font.Gotham
if gui then
for _, item in ipairs(gui:GetDescendants()) do
if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then item.Font = fontValue end
end
end
if _G.__NoxFontSelectorLabel then _G.__NoxFontSelectorLabel.Text = _G.__NoxUiFont or "Gotham" end
if camera and not stretchEnabled then pcall(function() camera.FieldOfView = cameraFOV end) end
for _, ref in ipairs(keyButtonRefs) do
local entry = ref.entry
local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
ref.btn.Text = label
end
if savedProgressBarPos and pbFrame then
pbFrame.Position = UDim2.new(savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or 0, savedProgressBarPos.YScale or 0.82, savedProgressBarPos.YOffset or 0)
end
if applyBackgroundMode then pcall(applyBackgroundMode, backgroundMode or "Image") end
refreshBackgroundButtons()
applyNoxButtonImage(buttonImageIndex)
refreshNoxButtonImageButtons()
if backgroundColorMatchVisual then backgroundColorMatchVisual(backgroundColorMatch) end
if stealBarMatchVisual then stealBarMatchVisual(stealBarMatch) end
if kickWarningVisual then kickWarningVisual(kickWarningEnabled) end
if ragdollCountdownVisual then ragdollCountdownVisual(ragdollCountdownEnabled) end
if ragdollStealVisual then ragdollStealVisual(ragdollStealEnabled) end
if stealBarMatch then pcall(applyStealBarMatch) end
if _G._NoxSetKickWarningEnabled then pcall(_G._NoxSetKickWarningEnabled, kickWarningEnabled) end
if _G._NoxSetRagdollCountdownEnabled then pcall(_G._NoxSetRagdollCountdownEnabled, ragdollCountdownEnabled) end
if _G._NoxRagdollStealSync then pcall(_G._NoxRagdollStealSync) end
applyFloatingButtonScale()
refreshNoxMoveLockButton()
setControllerLockShift(false, true)
if antiRagdollMode == "v2" then
if setAntiRagVisual then setAntiRagVisual(true) end
startAntiRagdollV2()
else
if setAntiRagVisual then setAntiRagVisual(false) end
end
if antiDieEnabled then
if setAntiDieVisual then setAntiDieVisual(true) end
AntiDieModule.start()
else
if setAntiDieVisual then setAntiDieVisual(false) end
end
if antiBatEnabled then
if setAntiBatVisual then setAntiBatVisual(true) end
startAntiBat()
else
if setAntiBatVisual then setAntiBatVisual(false) end
end
if antiFlingEnabled then
if setAntiFlingVisual then setAntiFlingVisual(true) end
startAntiFling()
else
if setAntiFlingVisual then setAntiFlingVisual(false) end
stopAntiFling()
end
if CONFIG.AUTO_STEAL_ENABLED and setInstaGrab then setInstaGrab(true); pcall(startAutoSteal) end
if medusaCounterEnabled then
if setMedusaVisual then setMedusaVisual(true) end
if LP.Character then setupMedusaCounter(LP.Character) end
else
if setMedusaVisual then setMedusaVisual(false) end
stopMedusaCounter()
end
if batCounterEnabled and setBatCounterVisual then
setBatCounterVisual(true)
startBatCounter()
end
if autoBatEnabled then
if autoBatSetVisual then autoBatSetVisual(true) end
pcall(enableAutoBat)
else
if autoBatSetVisual then autoBatSetVisual(false) end
end
if autoLeftEnabled then
if autoLeftSetVisual then autoLeftSetVisual(true) end
pcall(startAutoLeft)
else
if autoLeftSetVisual then autoLeftSetVisual(false) end
end
if autoRightEnabled then
if autoRightSetVisual then autoRightSetVisual(true) end
pcall(startAutoRight)
else
if autoRightSetVisual then autoRightSetVisual(false) end
end
if antiBypassEnabled then
if antiBypassSetVisual then antiBypassSetVisual(true) end
pcall(startAntiBypass)
else
if antiBypassSetVisual then antiBypassSetVisual(false) end
end
if batCounterV2Enabled and setBatCounterV2Visual then
setBatCounterV2Visual(true)
startBatCounterV2()
end
if antiLagEnabled then
if setAntiLagVisual then setAntiLagVisual(true) end
enableAntiLag()
else
if setAntiLagVisual then setAntiLagVisual(false) end
disableAntiLag()
end
if espEnabled then
toggleESP(true)
if setESPVIsual then setESPVIsual(true) end
else
toggleESP(false)
if setESPVIsual then setESPVIsual(false) end
end
if espLineEnabled then
if setESPLineVisual then setESPLineVisual(true) end
startESPLine()
else
if setESPLineVisual then setESPLineVisual(false) end
stopESPLine()
end
if vividGraphicsEnabled then
enableVividGraphics()
if setVividVisual then setVividVisual(true) end
else
disableVividGraphics()
if setVividVisual then setVividVisual(false) end
end
if stretchEnabled then
enableStretch()
if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end
else
if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
end
if mobSetAutoBat then mobSetAutoBat(autoBatEnabled) end
if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
if mobSetCarry then mobSetCarry(speedMode) end
if mobSetLagger1 then mobSetLagger1(laggerToggled) end
if mobSetLagger2 then mobSetLagger2(laggerCarryToggled) end
if bodyLockEnabled and bodyLockSetVisual then
if _blSuppressCount == 0 then
bodyLockSetVisual(true)
startBodyLock()
else
bodyLockSetVisual(false)
end
end
updateProgressBarVisibility()
startEnemySpeed()
toggleLockUI(uiLocked)
pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
if outfitSelectorLabel then outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label end
end
_bootErrors = {}
function _bootSection(name, fn)
print("[Y-out Boot] Iniciando:", name)
local ok, err = pcall(fn)
if not ok then
print("[Y-out Boot] FALLÓ:", name, tostring(err))
table.insert(_bootErrors, {name = name, err = tostring(err)})
warn("[Y-out Boot] Error en '" .. name .. "': " .. tostring(err))
else
print("[Y-out Boot] OK:", name)
end
return ok
end

-- Optional Ragdoll Countdown (ported behavior; the old Medusa/Ragdoll timer overlay is removed).
do
    local countdownSerial = 0
    local activeCountdownGui = nil
    local countdownStateConn = nil
    local playerGuiOnStart = LP and LP:FindFirstChildOfClass("PlayerGui")
    local legacyTimers = playerGuiOnStart and playerGuiOnStart:FindFirstChild("NoxStatusTimers")
    if legacyTimers then pcall(function() legacyTimers:Destroy() end) end
    local function destroyRagdollCountdown()
        countdownSerial = countdownSerial + 1
        if activeCountdownGui then
            pcall(function() activeCountdownGui:Destroy() end)
            activeCountdownGui = nil
        end
        local playerGui = LP and LP:FindFirstChildOfClass("PlayerGui")
        local old = playerGui and playerGui:FindFirstChild("NoxRagdollCountdown")
        if old then pcall(function() old:Destroy() end) end
    end
    -- Bat ragdoll = 2.8s, Medusa freeze = 3.2s
    local RAGDOLL_BAT_DURATION = 2.8
    local RAGDOLL_MEDUSA_DURATION = 3.2
    local function isMedusaFreeze(character, humanoid)
        if not character then return false end
        if humanoid and humanoid.PlatformStand then return true end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Anchored == true and part.Transparency == 1 then
                return true
            end
        end
        -- nearby enemy holding medusa/stone/head
        pcall(function()
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local tool = plr.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local n = tool.Name:lower()
                        if n:find("medusa", 1, true) or n:find("stone", 1, true) or n:find("head", 1, true) then
                            local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                            if tr and (tr.Position - root.Position).Magnitude < 25 then
                                return true
                            end
                        end
                    end
                end
            end
        end)
        return false
    end
    local function showRagdollCountdown(character, duration)
        if not ragdollCountdownEnabled or not character then return end
        local head = character:FindFirstChild("Head")
        local playerGui = LP and (LP:FindFirstChildOfClass("PlayerGui") or pgui)
        if not head or not playerGui then return end
        duration = tonumber(duration) or RAGDOLL_BAT_DURATION
        if duration < 0.5 then duration = RAGDOLL_BAT_DURATION end
        destroyRagdollCountdown()
        countdownSerial = countdownSerial + 1
        local serial = countdownSerial
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NoxRagdollCountdown"
        billboard.Size = UDim2.fromOffset(112, 34)
        billboard.StudsOffset = Vector3.new(0, 0.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = playerGui
        activeCountdownGui = billboard
        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextColor3 = selectedColor or Color3.fromRGB(255, 255, 255)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.15
        label.Text = ""
        local tenths = math.floor(duration * 10 + 0.01)
        task.spawn(function()
            for tenth = tenths, 0, -1 do
                if serial ~= countdownSerial or not ragdollCountdownEnabled or not billboard.Parent then return end
                label.Text = string.format("%.1f", tenth / 10)
                label.TextColor3 = selectedColor or Color3.fromRGB(255, 255, 255)
                task.wait(0.1)
            end
            if serial == countdownSerial and ragdollCountdownEnabled and billboard.Parent then
                label.Text = "READY!"
                task.wait(0.55)
                if serial == countdownSerial and billboard.Parent then billboard:Destroy() end
                if activeCountdownGui == billboard then activeCountdownGui = nil end
            end
        end)
    end
    local function bindRagdollCountdown(character)
        if countdownStateConn then
            pcall(function() countdownStateConn:Disconnect() end)
            countdownStateConn = nil
        end
        local humanoid = character and (character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5))
        if not humanoid then return end
        local wasRagdolled = false
        local function checkState()
            local state = humanoid:GetState()
            local isRagdolled = state == Enum.HumanoidStateType.Physics
                or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.FallingDown
                or humanoid.PlatformStand == true
            if isRagdolled and not wasRagdolled then
                local dur = isMedusaFreeze(character, humanoid) and RAGDOLL_MEDUSA_DURATION or RAGDOLL_BAT_DURATION
                showRagdollCountdown(character, dur)
            end
            wasRagdolled = isRagdolled
        end
        countdownStateConn = humanoid.StateChanged:Connect(function() checkState() end)
        checkState()
    end
    _G._NoxSetRagdollCountdownEnabled = function(on)
        ragdollCountdownEnabled = on == true
        if not ragdollCountdownEnabled then
            if countdownStateConn then
                pcall(function() countdownStateConn:Disconnect() end)
                countdownStateConn = nil
            end
            destroyRagdollCountdown()
        elseif LP.Character then
            bindRagdollCountdown(LP.Character)
        end
        if saveAllSettings then pcall(saveAllSettings, true) end
        return ragdollCountdownEnabled
    end
    if LP.Character then task.defer(function() bindRagdollCountdown(LP.Character) end) end
    LP.CharacterAdded:Connect(function(character)
        task.delay(0.3, function() bindRagdollCountdown(character) end)
    end)
end

-- Brainrot ENTER (from ZeyHubb)
do
local introGeneration=0 local wasHoldingBrainrot=false local activeIntroGui=nil local function isHoldingBrainrot()local char=LP and LP.Character if not char then return false end if LP:GetAttribute("Stealing")==true or char:GetAttribute("Stealing")==true then return true end local function nameIsBrainrot(n)n=tostring(n or""):lower()if n==""then return false end if n:find("bat",1,true)or n:find("sword",1,true)or n:find("katana",1,true)or n:find("gun",1,true)or n:find("medusa",1,true)or n:find("slap",1,true)or n:find("weapon",1,true)or n:find("bypass",1,true)or n:find("tool",1,true)then return false end return n:find("brainrot",1,true)~=nil or n:find("animal",1,true)~=nil or n:find("stolen",1,true)~=nil end for _,entry in ipairs({"StealHold","IsCarrying","Carrying"})do local inst=char:FindFirstChild(entry,true)if inst and inst:IsA("BoolValue")and inst.Value==true then for _,child in ipairs(char:GetChildren())do if(child:IsA("Tool")or child:IsA("Model"))and nameIsBrainrot(child.Name)then return true end end end end for _,child in ipairs(char:GetChildren())do if(child:IsA("Tool")or child:IsA("Model"))and nameIsBrainrot(child.Name)then return true end end return false end local function playBrainrotIntro(myGeneration)if activeIntroGui then pcall(function()activeIntroGui:Destroy()end)end local playerGui=LP and(LP:FindFirstChildOfClass("PlayerGui")or LP:WaitForChild("PlayerGui",5))if not playerGui or myGeneration~=introGeneration or not isHoldingBrainrot()then return end local introGui=Instance.new("ScreenGui")introGui.Name="BrainrotEnterIntro"introGui.ResetOnSpawn=false introGui.IgnoreGuiInset=true introGui.DisplayOrder=1000000 introGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling introGui.Parent=playerGui activeIntroGui=introGui local strip=Instance.new("Frame")
strip.Name="EnterStrip"
strip.AnchorPoint=Vector2.new(0.5,0.5)
strip.Position=UDim2.new(0.5,0,-0.2,0)
strip.Size=UDim2.fromOffset(260,36)
strip.BackgroundColor3=Color3.fromRGB(6,12,20)
strip.BackgroundTransparency=0.05
strip.BorderSizePixel=0
strip.ClipsDescendants=true
strip.ZIndex=2
strip.Parent=introGui
Instance.new("UICorner",strip).CornerRadius=UDim.new(1,0)
local completeBorder=Instance.new("UIStroke",strip)
completeBorder.Name="CompleteLoadingBorder"
completeBorder.Color=Color3.fromRGB(30,145,78)
completeBorder.Thickness=1.4
completeBorder.Transparency=0.45
completeBorder.ZIndex=6
local scale=Instance.new("UIScale",strip)
scale.Scale=0.92
local lineFill=Instance.new("Frame",strip)
lineFill.Name="LoadingLine"
lineFill.Size=UDim2.new(0,0,1,0)
lineFill.Position=UDim2.new(0,0,0,0)
lineFill.BackgroundColor3=Color3.fromRGB(30,145,78)
lineFill.BackgroundTransparency=0.08
lineFill.BorderSizePixel=0
lineFill.ZIndex=3
Instance.new("UICorner",lineFill).CornerRadius=UDim.new(1,0)
local lfGrad=Instance.new("UIGradient",lineFill)
lfGrad.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0.00,Color3.fromRGB(120,210,255)),
ColorSequenceKeypoint.new(0.45,Color3.fromRGB(30,145,78)),
ColorSequenceKeypoint.new(1.00,Color3.fromRGB(125,18,32)),
})
local label=Instance.new("TextLabel",strip)
label.Name="EnterLabel"
label.Size=UDim2.new(1,-28,1,-10)
label.Position=UDim2.fromOffset(14,5)
label.BackgroundTransparency=1
label.Text="DON'T ENTER"
label.TextColor3=Color3.fromRGB(210,235,255)
label.TextStrokeTransparency=0.55
label.TextStrokeColor3=Color3.fromRGB(0,30,60)
label.Font=Enum.Font.GothamBold
label.TextScaled=true
label.TextWrapped=true
label.ZIndex=5
local limit=Instance.new("UITextSizeConstraint",label)
limit.MinTextSize=10
limit.MaxTextSize=14
local function stillValid()return myGeneration==introGeneration and introGui.Parent~=nil and isHoldingBrainrot()end
local function abortIf()if stillValid()then return false end if introGui.Parent then introGui:Destroy()end if activeIntroGui==introGui then activeIntroGui=nil end return true end
local arrival=TS:Create(strip,TweenInfo.new(0.7,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromScale(0.5,0.11)})
TS:Create(scale,TweenInfo.new(0.7,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1}):Play()
arrival:Play()
arrival.Completed:Wait()
if abortIf()then return end
local fillTween=TS:Create(lineFill,TweenInfo.new(2.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.new(1,0,1,0)})
fillTween:Play()
local t0=tick()
while fillTween.PlaybackState==Enum.PlaybackState.Playing do
if abortIf()then pcall(function()fillTween:Cancel()end) return end
task.wait(0.03)
if tick()-t0>3 then break end
end
lineFill.Size=UDim2.new(1,0,1,0)
TS:Create(completeBorder,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=0.1,Thickness=1.8}):Play()
label.Text="ENTER"
label.TextTransparency=1
TS:Create(label,TweenInfo.new(0.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0}):Play()
task.wait(0.45)
if abortIf()then return end
TS:Create(scale,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Scale=0.96}):Play()
TS:Create(strip,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
TS:Create(lineFill,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
TS:Create(label,TweenInfo.new(0.35),{TextTransparency=1}):Play()
TS:Create(completeBorder,TweenInfo.new(0.35),{Transparency=1}):Play()
task.wait(0.5)
if introGui.Parent then introGui:Destroy()end
if activeIntroGui==introGui then activeIntroGui=nil end end task.spawn(function()while true do local holding=isHoldingBrainrot()if holding and not wasHoldingBrainrot then introGeneration=introGeneration+1 local thisGeneration=introGeneration task.spawn(function()playBrainrotIntro(thisGeneration)end)elseif not holding and wasHoldingBrainrot then introGeneration=introGeneration+1 if activeIntroGui then pcall(function()activeIntroGui:Destroy()end)activeIntroGui=nil end end wasHoldingBrainrot=holding task.wait(0.1)end end)end


-- UNO invite (tiny in menu + above head)
do
    local UNO_INVITE = "https://discord.gg/HKkHgBv5V"
    local function attachUNOInvite(character)
        if not character or not character.Parent then return end
        local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 8)
        if not head then return end
        local prev = head:FindFirstChild("UNOInviteBillboard")
        if prev then prev:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "UNOInviteBillboard"
        bb.Adornee = head
        bb.Size = UDim2.fromOffset(180, 18)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 120
        bb.Parent = head
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.Text = UNO_INVITE
        lbl.TextColor3 = Color3.fromRGB(160, 210, 255)
        lbl.TextStrokeTransparency = 0.35
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 20, 40)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 9
        lbl.TextScaled = false
    end
    if LP.Character then task.defer(attachUNOInvite, LP.Character) end
    LP.CharacterAdded:Connect(function(c) task.delay(0.35, function() if LP.Character == c then attachUNOInvite(c) end end) end)
    _G.__UNOInvite = UNO_INVITE
end
_bootSection("buildGui", function()
task.defer(function()
pcall(function() applyColorTheme("Blue") end)
pcall(applyCyberMenuLook)
end)

local ok, err = pcall(buildGui)
if not ok then
warn("[UNO] buildGui failed: " .. tostring(err))
print("[UNO] buildGui failed:", err)
else
    task.defer(function()
        pcall(function() if main then makeNavyBorder(main, 2.8, 3.5) end end)
        pcall(function() if pbFrame then makeNavyBorder(pbFrame, 2.4, 3.2) end end)
        pcall(setupIdleFade)
        pcall(function() if scriptLogo then scriptLogo.Text = "UNO 🎄" end end)
    end)
end
end)
if gui then pcall(function() gui.Enabled = true; gui.DisplayOrder = 100 end) end
if main then pcall(function() main.Visible = true end) end
if type(showGui) == "function" then pcall(showGui) end
if gui and main then
_bootSection("loadAllSettings", function()
if loadAllSettings() then
updateUIFromLoaded()
end
end)
_youtConfigReady = true
if noxMenuPositionMigrated then
    noxMenuPositionMigrated = false
    pcall(saveAllSettings, true)
end
local _noxAutoSaveWarned = false
task.spawn(function()
    while gui and gui.Parent do
        if _youtConfigReady and not _isLoading and not _isResetting and autoSaveEnabled ~= false then
            local readFn, writeFn = resolveYoutFileApi()
            if type(readFn) == "function" and type(writeFn) == "function" then
                local ok = saveAllSettings(false)
                if not ok and not _noxAutoSaveWarned then
                    warn("[UNO AutoSave] Couldn't verify config write; check executor file APIs.")
                    _noxAutoSaveWarned = true
                elseif ok then
                    _noxAutoSaveWarned = false
                end
            elseif not _noxAutoSaveWarned then
                warn("[UNO AutoSave] Executor readfile/writefile APIs are unavailable; local config cannot persist.")
                _noxAutoSaveWarned = true
            end
        end
        task.wait(0.5)
    end
end)
_bootSection("createMobilePanel", function()
MobilePanel = createMobilePanel()
applyButtonShape(buttonShapeMode)
pcall(function() applyNoxButtonImage(buttonImageIndex or 2) end)
end)
_bootSection("createAntiBypassFloatingButton", function()
antiBypassFloatingButton = createAntiBypassFloatingButton()
end)
_bootSection("noxExtras", function()
pcall(function()
if startCarryTagLoop then startCarryTagLoop() end
if autoBrainrotSpeedEnabled and setAutoBrainrotSpeedEnabled then setAutoBrainrotSpeedEnabled(true) end

if safeModeEnabled and setSafeModeEnabled then setSafeModeEnabled(true) end
if flingShieldEnabled and setFlingShieldEnabled then setFlingShieldEnabled(true) end
if autoResetOnMedEnabled and setAutoResetOnMed then setAutoResetOnMed(true) end
if playerESPEnabled and setPlayerESPEnabled then setPlayerESPEnabled(true) end
if tracerESPEnabled and setTracerESPEnabled then setTracerESPEnabled(true) end
if allLockButtonsEnabled and setAllLockButtons then setAllLockButtons(true) end

if spamBatEnabled and toggleSpamBat then toggleSpamBat(true) end
if distanceRingEnabled and toggleDistanceRing then toggleDistanceRing(true) end
if warningHighPingEnabled and toggleWarningHighPing then toggleWarningHighPing(true) end
end)
end)
_bootSection("createInstaResetFloatingButton", function()
instaResetFloatingButton = createInstaResetFloatingButton()
end)
if hideButtonsEnabled then
_bootSection("applyHideButtons", function()
applyHideButtons(true)
if setHideButtonsVisual then setHideButtonsVisual(true) end
end)
end
_bootSection("localizeYoutInterface", function()
if gui then localizeYoutInterface(gui) end
if MobilePanel then localizeYoutInterface(MobilePanel) end
if instaResetFloatingButton then localizeYoutInterface(instaResetFloatingButton) end
end)
if LP.Character then
task.spawn(function()
task.wait(0.1)
if waitForCharReady(LP.Character, 5) then
pcall(function() captureOriginalAppearance(LP.Character) end)
pcall(function() setupMovementAndIndicators(LP.Character) end)
if currentAnimPack ~= "Off" then
pcall(function() startAnimPack(currentAnimPack) end)
end
pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
end
end)
end
if #_bootErrors > 0 then
task.defer(function()
pcall(function()
local env = (getgenv and getgenv()) or _G
local writeFn = env.writefile or (syn and syn.writefile)
if type(writeFn) == "function" then
local log = "[Y-out Boot Errors] " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
for _, e in ipairs(_bootErrors) do
log = log .. e.name .. ": " .. e.err .. "\n"
end
pcall(writeFn, "Yout_boot_errors.txt", log)
warn("[Y-out] boot errors logged")
end
end)
end)
task.defer(function()
pcall(function()
local errGui = Instance.new("ScreenGui")
errGui.Name = "YoutBootErrors"
errGui.ResetOnSpawn = false
errGui.DisplayOrder = 999
local okCg, cg = pcall(function() return game:GetService("CoreGui") end)
if okCg and cg then
pcall(function() errGui.Parent = cg end)
end
if not errGui.Parent then errGui.Parent = LP:WaitForChild("PlayerGui") end
local frame = Instance.new("Frame", errGui)
frame.Size = UDim2.new(0, 460, 0, 60 + #_bootErrors * 22)
frame.Position = UDim2.new(0, 10, 1, -80 - #_bootErrors * 22)
frame.BackgroundColor3 = Color3.fromRGB(40, 10, 15)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 80, 90)
stroke.Thickness = 1.5
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Y-out: " .. #_bootErrors .. " sección(es) fallaron"
title.TextColor3 = Color3.fromRGB(255, 100, 110)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
for i, e in ipairs(_bootErrors) do
local lbl = Instance.new("TextLabel", frame)
lbl.Size = UDim2.new(1, -20, 0, 18)
lbl.Position = UDim2.new(0, 10, 0, 34 + (i - 1) * 20)
lbl.BackgroundTransparency = 1
lbl.Text = "• " .. e.name .. ": " .. e.err:sub(1, 110)
lbl.TextColor3 = Color3.fromRGB(255, 180, 180)
lbl.Font = Enum.Font.Code
lbl.TextSize = 10
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextTruncate = Enum.TextTruncate.AtEnd
end
local copyBtn = Instance.new("TextButton", frame)
copyBtn.Size = UDim2.new(0, 100, 0, 22)
copyBtn.Position = UDim2.new(0, 10, 1, -30)
copyBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 30)
copyBtn.Text = "COPIAR LOG"
copyBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.BorderSizePixel = 0
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
copyBtn.MouseButton1Click:Connect(function()
local buf = ""
for _, e in ipairs(_bootErrors) do
buf = buf .. e.name .. ": " .. e.err .. "\n"
end
pcall(function()
if setclipboard then setclipboard(buf) end
end)
copyBtn.Text = "¡COPIADO!"
task.delay(1.2, function() copyBtn.Text = "COPIAR LOG" end)
end)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 60, 0, 22)
closeBtn.Position = UDim2.new(1, -70, 1, -30)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 30)
closeBtn.Text = "CERRAR"
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
pcall(function() errGui:Destroy() end)
end)
task.delay(60, function()
pcall(function() errGui:Destroy() end)
end)
end)
end)
end
else
warn("[Y-out] buildGui failed")
end
if LP and LP.CharacterAdded then
pcall(function()
local _respawnQueue = 0
LP.CharacterAdded:Connect(function(char)
pcall(function()
_respawnQueue = _respawnQueue + 1
local myId = _respawnQueue
if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
isStealing = false
if stopAutoLeft then stopAutoLeft() end
if stopAutoRight then stopAutoRight() end
if stopBatCounter then stopBatCounter() end
if stopBatCounterV2 then stopBatCounterV2() end
if stopMedusaCounter then stopMedusaCounter() end
if stopDropBrainrot then stopDropBrainrot() end
if autoBatEnabled and disableAutoBat then disableAutoBat() end
if bodyLockEnabled and stopBodyLock then stopBodyLock() end
local deadline = _tick() + 5
while (not char.Parent) or (not char:FindFirstChild("HumanoidRootPart")) or (not char:FindFirstChildOfClass("Humanoid")) do
if _tick() > deadline then return end
if myId ~= _respawnQueue then return end
task.wait(0.05)
end
_hookedVelParts = {}
local _hrpRespawn = _setupVelChecked(char)
_hookVelHRP(_hrpRespawn)
if not _originalAppearance then task.defer(function() captureOriginalAppearance(char) end) end
if setupMovementAndIndicators then setupMovementAndIndicators(char) end
if antiRagdollMode == "v2" then startAntiRagdollV2() end
if antiBatEnabled then startAntiBat() end
if antiFlingEnabled then startAntiFling() end
if AntiDieModule.enabled then task.defer(function() activateOnCharacter(char) end) end
if CONFIG.AUTO_STEAL_ENABLED then pcall(startAutoSteal) end
if bodyLockEnabled and _blSuppressCount == 0 then startBodyLock() end
if medusaCounterEnabled then
setupMedusaCounter(char)
if setMedusaVisual then setMedusaVisual(true) end
else
stopMedusaCounter()
if setMedusaVisual then setMedusaVisual(false) end
end
if batCounterEnabled then startBatCounter() end
if batCounterV2Enabled then startBatCounterV2() end
if currentAnimPack ~= "Off" then task.wait(0.3); startAnimPack(currentAnimPack) end
updateProgressBarVisibility()
refreshSpeedModeLabel()
pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
if outfitSelectorLabel then outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label end
end)
end)
end)
end
lastLaggerToggle = 0
LAGGER_COOLDOWN = 0.3
if _G.__NoxDuelsKeybindInputConnection then
pcall(function() _G.__NoxDuelsKeybindInputConnection:Disconnect() end)
end
_G.__NoxDuelsKeybindInputConnection = UIS.InputBegan:Connect(function(input, gpe)
if _anyKeyListening then return end
if input.UserInputType == Enum.UserInputType.Keyboard then
if gpe or UIS:GetFocusedTextBox() then return end
elseif not isGamepadInput(input) then
return
end
if not isBindableInput(input) then return end
local kc = input.KeyCode
if not kc then return end
if kbMatch(KB.LaggerMode, input) then
if _tick() - lastLaggerToggle >= LAGGER_COOLDOWN then
lastLaggerToggle = _tick()
toggleLaggerCycle()
end
return
end
if kbMatch(KB.CarryToggle, input) then toggleCarryMode(); return end
if kbMatch(KB.DropBrainrot, input) then
if not dropActive then
if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
executeDropWithToggle(dropBrainrotSetVisual)
end
return
end
if kbMatch(KB.TPFloor, input) then doTpDown(); return end
if kbMatch(KB.InstaReset, input) then
if _G.InstaReset and _G.InstaReset.Trigger then _G.InstaReset.Trigger() end
return
end
if kbMatch(KB.AutoLeft, input) then
autoLeftEnabled = not autoLeftEnabled
if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
pcall(saveAllSettings, true)
return
end
if kbMatch(KB.AutoRight, input) then
autoRightEnabled = not autoRightEnabled
if autoRightEnabled then startAutoRight() else stopAutoRight() end
if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
pcall(saveAllSettings, true)
return
end
if kbMatch(KB.AutoBat, input) then
if not autoBatEnabled then
enableAutoBat()
if autoBatSetVisual then autoBatSetVisual(true) end
if mobSetAutoBat then mobSetAutoBat(true) end
else
disableAutoBat()
if autoBatSetVisual then autoBatSetVisual(false) end
if mobSetAutoBat then mobSetAutoBat(false) end
end
pcall(saveAllSettings, true)
return
end
if kbMatch(KB.AntiBypass, input) then
pcall(function()
if type(toggleAntiBypass) == "function" then
toggleAntiBypass()
elseif antiBypassEnabled then
if type(stopAntiBypass) == "function" then stopAntiBypass() end
else
if type(startAntiBypass) == "function" then startAntiBypass() end
end
if antiBypassSetVisual then antiBypassSetVisual(antiBypassEnabled) end
if antiBypassFloatingSetVisual then antiBypassFloatingSetVisual(antiBypassEnabled) end
end)
return
end
if kbMatch(KB.GuiHide, input) then
if main then
if main.Visible then hideGui() else showGui() end
end
return
end
end)
