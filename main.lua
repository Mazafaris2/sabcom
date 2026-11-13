-- =============================================================================
-- 070Hub (clean host build)
-- No LPH macro stubs / no namecall anti-tamper (polsec-safe, less runtime noise)
-- Config save/load kept
-- =============================================================================

pcall(function()
	if type(getgenv) ~= "function" then
		getgenv = function() return _G end
	end
end)

-- minimal GUI protect helper (no metatable hooks)
pcall(function()
	if getgenv().__yenProtectGui then return end
	getgenv().__yenProtectGui = function(gui)
		pcall(function()
			if syn and syn.protect_gui then syn.protect_gui(gui) end
		end)
		pcall(function()
			if type(protect_gui) == "function" then protect_gui(gui) end
		end)
	end
	getgenv().__yenAntiRoot = function() return nil end
	getgenv().__YEN = {
		protect = getgenv().__yenProtectGui,
		antiRoot = function() end,
		antiTamper = function() return false end,
		unprotect = function() end,
	}
end)

-- =====================================================================
-- 070Hub | Blue / Purple theme (forced accents)
-- Animated UI accents
-- =====================================================================

local Players, RunService, UserInputService, TweenService, HttpService, Lighting, localPlayer, isConfigReady, isAutoBatBusy
local originalCollisionStates, healthLoopConnection, characterHealthConnection, healthConnections, isHealthLockEnabled, predictionData, isMobileDevice
local desktopBypassPower, mobileBypassPower, text, isSpeedBypassEnabled, speedBypassPower, thread, speedBypassPanel, isSpeedPanelDismissed, blockListPayload, uiControl
local keybindButton, secondaryButton, speedModeLabel, updateSpeedBypassVisual, speedPanelPosition, defaultPanelPosition, speedPanelScale, panelAnimationToken, speedPanelToggle, speedToggleScale
local speedToggleImage, speedToggleStroke, speedToggleGradient, getAutoBatMovementSpeed, refreshAutoBatModeControls, normalizeBatCounterSettings, updateBatCounterVersionIndicator, refreshQuickActionVisibility, primaryColor, secondaryColor
local tertiaryColor, createPurpleColorSequence, applyPurpleGradient, addPurpleGloss, setPurpleControlActive, removeExistingVisionGui, showLoadingIndicator, hideLoadingIndicator, startAutoTeleport
local stopAutoTeleport, counterPauseUntil, pauseCounterChecks, stealV1DelayRadius, stealV2DelayRadius, stealPercentages, autoStealVersion, stealV1Radius, stealV2Radius, selectorHighlight
local updateStealVersionUi, updateStealRadiusUi, startAutoSteal, stopAutoSteal, stopAutoPathMovement, stopAutoLeft, stopAutoRight, startAutoLeft, startAutoRight, createLocalPlayerBillboard
local ensureLocalPlayerBillboard, disableWalkAnimation, restoreWalkAnimation, jumpInputState, stopInfiniteJumpLoop, startInfiniteJumpLoop
local read070Config, reset070Config
do
	repeat
		task.wait()
	until game:IsLoaded()

	Players = game:GetService("Players")
	RunService = game:GetService("RunService")
	UserInputService = game:GetService("UserInputService")
	TweenService = game:GetService("TweenService")
	HttpService = game:GetService("HttpService")
	Lighting = game:GetService("Lighting")
	localPlayer = Players.LocalPlayer

	-- mute ALL console spam — only final load line is allowed
	do
		local _print, _warn = print, warn
		getgenv()._070RealPrint = _print
		getgenv()._070RealWarn = _warn
		print = function(...) end
		warn = function(...) end
		getgenv()._070DebugPrint = function() end
	end

	loadExternalUIImage = function(inputValue, secondaryInput)
		local genv = getgenv and getgenv() or _G
		local value = rawget(genv, "getcustomasset") or rawget(genv, "getsynasset")
		local value2 = rawget(genv, "isfile")
		local value3 = rawget(genv, "writefile")

		if type(value) == "function" and type(value3) == "function" then
			local isActive = type(value2) == "function" and value2(secondaryInput)

			if not isActive then
				local ok, result = pcall(function()
					return game:HttpGet(inputValue)
				end)

				if ok and type(result) == "string" and #result > 0 then
					isActive = pcall(value3, secondaryInput, result)
				end
			end

			if isActive then
				local ok, result = pcall(value, secondaryInput)
				if ok and result then
					return result
				end
			end
		end

		return inputValue
	end

	_070_SPEED_BYPASS_IMAGE_URL = "https://files.catbox.moe/4s7q0i.png"
	_070_HUB_IMAGE_URL = "rbxassetid://103010175848787"

	pcall(function()
		-- do not force fpscap on boot (some environments kick)
	end)

	
	isConfigReady = false
uiTheme = "BluePurple"

-- =====================================================================
-- GLOBAL PERSIST (getgenv) — works from any scope, outfits + all toggles
-- =====================================================================
do
	local HttpService = game:GetService("HttpService")
	local FILE = "070Hub.json"
	local UI_FILE = "070Hub_UIConfig.json"

	local env = getgenv()
	local lastWritten = {}
	local saveGeneration = 0
	local savePending = false

	local function wf(name, data)
		local encoded, payload = pcall(HttpService.JSONEncode, HttpService, data)
		if not encoded then return false end
		local writers = table.pack(writefile, syn and syn.write_file, syn and syn.writefile, fluxus and fluxus.writefile, env.writefile)
		for i = 1, writers.n do
			if type(writers[i]) == "function" then
				local ok, result = pcall(writers[i], name, payload)
				if ok and result ~= false then return true end
			end
		end
		return false
	end

	local function rf(name)
		local readers = table.pack(readfile, syn and syn.read_file, syn and syn.readfile, fluxus and fluxus.readfile, env.readfile)
		for i = 1, readers.n do
			if type(readers[i]) == "function" then
				local ok, result = pcall(readers[i], name)
				if ok and type(result) == "string" and #result > 1 then return result end
			end
		end
		return nil
	end

	local function sameConfig(a, b)
		if a == b then return true end
		if type(a) ~= "table" or type(b) ~= "table" then return false end
		for key, value in pairs(a) do
			if not sameConfig(value, b[key]) then return false end
		end
		for key in pairs(b) do
			if a[key] == nil then return false end
		end
		return true
	end

	local function writeChanged(name, data)
		if sameConfig(lastWritten[name], data) then return true end
		if not wf(name, data) then return false end
		lastWritten[name] = data
		return true
	end

	local function collectConfig()
		local cfg = getgenv()._070UIConfig or _G._070UIConfig or {}
		local data = {
			normalSpeed = tonumber(rawget(_G, "NS")) or tonumber(NS) or 60,
			carrySpeed = tonumber(rawget(_G, "CS")) or tonumber(CS) or 30,
			antiRagdoll = (antiRagdollEnabled == true),
			antiBat = false,
			unwalk = (unwalkEnabled == true),
			autoStealEnabled = (type(Steal) == "table" and Steal.AutoStealEnabled == true),
			infiniteJump = (infJumpEnabled == true),
			medusaCounter = (medusaCounterEnabled == true),
			medCounter = (_G._070MedCounterEnabled == true) or (medusaCounterEnabled == true),
			batCounter = (batCounterEnabled == true) or (batCounterV2Enabled == true),
			carryMode = (speedMode == true),
			laggerMode = (laggerToggled == true),
			laggerCarryMode = (laggerPhase == 2),
			laggerSpeed = tonumber(LAGGER_SPEED) or 35,
			laggerCarrySpeed = tonumber(LAGGER_CARRY_SPEED) or 18,
			autoBat = (autoBatEnabled == true),
			autoSwing = (autoSwingEnabled ~= false),
			mirrorTP = (mirrorTPEnabled ~= false),
			tpBatAutoSwing = (tpBatAutoSwingEnabled ~= false),
			autoBatMode = tostring(autoBatMode or "Vision"),
			autoBatSpeed = tonumber(AUTO_BAT_SPEED) or 60,
			tpBatEnabled = (tpBatEnabled == true),
			espEnabled = (espEnabled == true),
			espTracersEnabled = (espTracersEnabled == true),
			showE01Warning = (showE01Warning == true) or (_G.showE01Warning == true),
			ragdollCountdownEnabled = (ragdollCountdownEnabled == true),
			antiLag = (antiLagEnabled == true),
			fieldOfView = tonumber(fieldOfView) or 70,
			fieldOfViewEnabled = (fieldOfViewEnabled == true),
			stretchRez = (stretchRezEnabled == true),
			autoTPEnabled = (autoTPEnabled == true),
			autoTPHeight = tonumber(autoTPHeight) or 5,
			showUIOnExecute = (showUIOnExecute ~= false),
			showMobileButtons = (showMobileButtons ~= false),
			qaLocked = (qaLocked == true),
			showSpeedBypassPanel = false,
			speedBypassPCPower = desktopBypassPower,
			speedBypassMobilePower = mobileBypassPower,
			speedBypassMode = text,
			speedBypassPosition = speedPanelPosition and table.clone(speedPanelPosition),
			laggerAutoBatSpeed = tonumber(LAGGER_AUTO_BAT_SPEED),
			uiScale = tonumber(uiScaleValue) or 100,
			stealBarScale = tonumber(stealBarScaleValue) or 100,
			uiAccentR = tonumber(uiAccentR) or 140,
			uiAccentG = tonumber(uiAccentG) or 100,
			uiAccentB = tonumber(uiAccentB) or 255,
			uiBgAsset = tostring(getgenv()._070CurrentBgAsset or getgenv()._070DefaultBgAsset or "119161957039576"),
			qaPositions = (function()
				local positions = {}
				pcall(function()
					if type(qaFrames) == "table" then
						for i, fr in ipairs(qaFrames) do
							if fr and fr.Parent then
								positions[i] = { fr.Position.X.Offset, fr.Position.Y.Offset }
							end
						end
					end
				end)
				return positions
			end)(),
			autoStealRadius = (type(Steal) == "table" and tonumber(Steal.StealRadius)) or 14,
			autoStealV1Radius = tonumber(stealV1Radius) or 14,
			autoStealV2Radius = tonumber(stealV2Radius) or 15,
			autoStealV1DelayRadius = tonumber(stealV1DelayRadius) or 14,
			autoStealV2DelayRadius = tonumber(stealV2DelayRadius) or 15,
			autoStealV1Percent = (stealPercentages and tonumber(stealPercentages.V1)) or 55,
			autoStealV2Percent = (stealPercentages and tonumber(stealPercentages.V2)) or 60,
			autoStealVersion = "V1",
			antiDie = (_G.__070AntiDieOn == true),
			uiTheme = tostring(uiTheme or "Normal"),
			headless = (_G._070Headless == true),
			halo = (_G._070Halo == true),
			hideStealBarUI = (_G._070HideStealBarUI == true),
			christmas = (false),
			skinChangerEnabled = (type(cfg) == "table" and cfg.skinChangerEnabled == true),
			skinSelection = (type(cfg) == "table" and tonumber(cfg.skinSelection)) or 1,
			customSkinId = (type(cfg) == "table" and tonumber(cfg.customSkinId)) or nil,
			medCounter = (_G._070MedCounterEnabled == true),
			baseXRay = (_G._070BaseXRay == true),
			brainrotXRay = (_G._070BrainrotXRay == true) or ((_G._070BRX and _G._070BRX.enabled) == true),
			bodyLock = false,
			bodyLockRange = (_G._070BodyLock and tonumber(_G._070BodyLock.range)) or 25,
			batKatanaEnabled = false,
			batSkin = (function()
				local s = "Original"
				pcall(function()
					if getgenv()._070GetBatSkins then
						local _, cur = getgenv()._070GetBatSkins()
						if type(cur) == "string" then s = cur end
					end
					if _G._070Visuals and _G._070Visuals.GetBatSkin then
						s = _G._070Visuals.GetBatSkin() or s
					end
				end)
				return s
			end)(),
			motionTrails = (function()
				local on = false
				pcall(function()
					if getgenv()._070GetTrails then on = getgenv()._070GetTrails() == true end
				end)
				return on
			end)(),
			trailColorR = (function()
				local r = 170
				pcall(function()
					if getgenv()._070GetTrailColor then
						local c = getgenv()._070GetTrailColor()
						if typeof(c) == "Color3" then r = math.floor(c.R * 255 + 0.5) end
					end
				end)
				return r
			end)(),
			trailColorG = (function()
				local g = 120
				pcall(function()
					if getgenv()._070GetTrailColor then
						local c = getgenv()._070GetTrailColor()
						if typeof(c) == "Color3" then g = math.floor(c.G * 255 + 0.5) end
					end
				end)
				return g
			end)(),
			trailColorB = (function()
				local b = 255
				pcall(function()
					if getgenv()._070GetTrailColor then
						local c = getgenv()._070GetTrailColor()
						if typeof(c) == "Color3" then b = math.floor(c.B * 255 + 0.5) end
					end
				end)
				return b
			end)(),
			haloColorR = tonumber(_G._070HaloR) or 190,
			haloColorG = tonumber(_G._070HaloG) or 110,
			haloColorB = tonumber(_G._070HaloB) or 255,
			-- animations
			animPack = (function()
				local n = nil
				pcall(function()
					if getgenv()._070GetAnimPack then
						n = select(1, getgenv()._070GetAnimPack())
					end
				end)
				return type(n) == "string" and n or nil
			end)(),
			animPackEnabled = (function()
				local on = false
				pcall(function()
					if getgenv()._070GetAnimPack then
						local n, e = getgenv()._070GetAnimPack()
						on = e == true or (type(n) == "string" and n ~= "")
					end
				end)
				return on
			end)(),
		}
		local previous = env._070Persist or {}
		data.keybinds = {}
		if type(previous.keybinds) == "table" then
			for name, bind in pairs(previous.keybinds) do
				if type(bind) == "table" then data.keybinds[name] = table.clone(bind) end
			end
		end
		for name, bind in pairs(KB or {}) do
			if type(bind) == "table" then
				data.keybinds[name] = { kb = bind.kb and bind.kb.Name, gp = bind.gp and bind.gp.Name }
			end
		end
		return data
	end

	local function flushConfig()
		if not isConfigReady then return false end
		local data = collectConfig()
		local ok = writeChanged(FILE, data)
		writeChanged(UI_FILE, {
			skinChangerEnabled = data.skinChangerEnabled,
			skinSelection = data.skinSelection,
			customSkinId = data.customSkinId,
		})
		env._070Persist = data
		_G._070Persist = data
		return ok
	end

	local function saveAll(immediate)
		if not isConfigReady then return false end
		saveGeneration += 1
		local generation = saveGeneration
		savePending = not immediate
		if immediate then return flushConfig() end
		task.delay(0.2, function()
			if env._070SaveAll ~= saveAll or generation ~= saveGeneration then return end
			savePending = false
			flushConfig()
		end)
		return true
	end
	env._070SaveAll = saveAll

	reset070Config = function()
		saveGeneration += 1
		savePending = false
		table.clear(lastWritten)
		for _, name in ipairs({ FILE, UI_FILE, "070AntiBatConfig.json" }) do
			wf(name, {})
			if type(delfile) == "function" then pcall(delfile, name) end
		end
		env._070Persist = nil
		_G._070Persist = nil
	end

	localPlayer.OnTeleport:Connect(function(state)
		if savePending and env._070SaveAll == saveAll and state == Enum.TeleportState.Started then
			saveAll(true)
		end
	end)

	read070Config = function()
		local raw = rf(FILE)
		if raw then
			local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
			if ok and type(data) == "table" and next(data) then return data end
		end
		local data = env._070Persist or _G._070Persist
		return type(data) == "table" and data or nil
	end

	getgenv()._070LoadAll = function()
		local data = read070Config()
		if not data then return nil end
		env._070Persist = data
		_G._070Persist = data
		-- outfits always
		local cfg = getgenv()._070UIConfig or {}
		if data.skinChangerEnabled ~= nil then cfg.skinChangerEnabled = data.skinChangerEnabled == true end
		if type(data.skinSelection) == "number" then cfg.skinSelection = data.skinSelection end
		if type(data.customSkinId) == "number" then cfg.customSkinId = data.customSkinId end
		getgenv()._070UIConfig = cfg
		_G._070UIConfig = cfg
		-- restore keybinds
		pcall(function()
			if type(data.keybinds) == "table" and type(KB) == "table" then
				for name, bind in pairs(data.keybinds) do
					if type(bind) == "table" and type(KB[name]) == "table" then
						KB[name].kb = type(bind.kb) == "string" and Enum.KeyCode[bind.kb] or nil
						KB[name].gp = type(bind.gp) == "string" and Enum.KeyCode[bind.gp] or nil
					end
				end
			end
		end)
		-- restore animations
		pcall(function()
			if data.animPackEnabled and type(data.animPack) == "string" and data.animPack ~= "" then
				getgenv()._070PendingAnimPack = data.animPack
				if getgenv()._070SetAnimPack then
					getgenv()._070SetAnimPack(data.animPack)
				end
			end
		end)
		-- restore UI accent + background
		pcall(function()
			if type(data.uiAccentR) == "number" then uiAccentR = data.uiAccentR end
			if type(data.uiAccentG) == "number" then uiAccentG = data.uiAccentG end
			if type(data.uiAccentB) == "number" then uiAccentB = data.uiAccentB end
			if type(data.uiBgAsset) == "string" and data.uiBgAsset ~= "" then
				local raw = tostring(data.uiBgAsset)
				if raw:lower() == "none" or raw:lower() == "nobg" then
					getgenv()._070CurrentBgAsset = "none"
				else
					getgenv()._070CurrentBgAsset = raw:gsub("%D", "")
				end
			end
			getgenv()._070AccentR = uiAccentR
			getgenv()._070AccentG = uiAccentG
			getgenv()._070AccentB = uiAccentB
		end)
		task.defer(function()
			task.wait(0.5)
			pcall(function()
				local r = tonumber(uiAccentR) or 140
				local g = tonumber(uiAccentG) or 100
				local b = tonumber(uiAccentB) or 255
				if getgenv()._070ApplyUiAccent then
					getgenv()._070ApplyUiAccent(r, g, b)
				end
				local id = getgenv()._070CurrentBgAsset or data.uiBgAsset or getgenv()._070DefaultBgAsset
				if id and getgenv()._070ApplyUiBackground then
					getgenv()._070ApplyUiBackground(tostring(id))
				end
			end)
			task.wait(1)
			pcall(function()
				local id = getgenv()._070CurrentBgAsset
				if id and getgenv()._070ApplyUiBackground then
					getgenv()._070ApplyUiBackground(tostring(id))
				end
			end)
		end)
		pcall(function()
			_G._070BatKatanaEnabled = false
		end)
		-- restore bat skin + trails + colors
		pcall(function()
			if type(data.batSkin) == "string" and data.batSkin ~= "" then
				getgenv()._070PendingBatSkin = data.batSkin
				task.defer(function()
					task.wait(0.8)
					if getgenv()._070SetBatSkin then
						getgenv()._070SetBatSkin(data.batSkin)
					end
				end)
			end
			if type(data.trailColorR) == "number" then
				task.defer(function()
					task.wait(0.9)
					if getgenv()._070SetTrailColor then
						getgenv()._070SetTrailColor(data.trailColorR, data.trailColorG or 120, data.trailColorB or 255)
					end
				end)
			end
			if type(data.haloColorR) == "number" then
				_G._070HaloR = data.haloColorR
				_G._070HaloG = data.haloColorG or 110
				_G._070HaloB = data.haloColorB or 255
			end
			if data.motionTrails == true then
				task.defer(function()
					task.wait(1)
					if getgenv()._070SetTrails then
						getgenv()._070SetTrails(true)
					end
				end)
			end
			if data.hideStealBarUI == true then
				_G._070HideStealBarUI = true
				task.defer(function()
					task.wait(0.8)
					pcall(function()
						if getgenv()._070SetStealBarHidden then
							getgenv()._070SetStealBarHidden(true)
						end
					end)
					task.wait(1.5)
					pcall(function()
						if getgenv()._070SetStealBarHidden then
							getgenv()._070SetStealBarHidden(true)
						end
					end)
				end)
			end
		end)
		print("[070] LOADED ✓ outfits=", cfg.skinSelection, "anim=", data.animPack, "accent=", uiAccentR, uiAccentG, uiAccentB, "bg=", getgenv()._070CurrentBgAsset)
		return data
	end

	-- load early
	task.defer(function()
		getgenv()._070LoadAll()
	end)
end


	pcall(function()
		(getgenv and getgenv() or _G)._070BootDone = false
	end)

	-- 070 exact speeds
	NS = 60
	CS = 30
end

uiScaleValue = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 75 or 100
stealBarScaleValue = 100
uiAccentR, uiAccentG, uiAccentB = 70, 150, 255

	getgenv()._070DefaultBgAsset = "103010175848787"
	getgenv()._070WhiteBgAsset = "124210976977975"
	getgenv()._070BlackBgAsset = "123207688823036"
	getgenv()._070PinkBgAsset = "116660005581591"
	getgenv()._070GreenBgAsset = "100735382166617"
	getgenv()._070CurrentBgAsset = "103010175848787"
	getgenv()._070ApplyUiBackground = function(assetId)
		local raw = tostring(assetId or getgenv()._070CurrentBgAsset or "103010175848787")
		local noBg = (raw:lower() == "none" or raw:lower() == "nobg" or raw:lower():find("no background", 1, true) ~= nil)
		local id
		if noBg then
			id = "none"
		else
			id = raw:gsub("%D", "")
			if id == "" or id == "120888993576533" then id = "103010175848787" end
		end
		getgenv()._070CurrentBgAsset = id
		local url = (id ~= "none") and ("rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420") or ""
		local function paint(img)
			if not img or not img:IsA("ImageLabel") then return end
			-- keep wallpaper clipped to rounded UI (no sharp corners)
			img.ScaleType = Enum.ScaleType.Crop
			img.ClipsDescendants = true
			local corner = img:FindFirstChild("HubBgCorner")
			if not corner then
				corner = img:FindFirstChildOfClass("UICorner")
			end
			if not corner then
				corner = Instance.new("UICorner")
				corner.Name = "HubBgCorner"
				corner.Parent = img
			end
			-- match parent frame corner if available
			local parentCorner = img.Parent and img.Parent:FindFirstChildOfClass("UICorner")
			if parentCorner then
				corner.CornerRadius = parentCorner.CornerRadius
			else
				corner.CornerRadius = UDim.new(0, 16)
			end
			if img.Parent and img.Parent:IsA("GuiObject") then
				img.Parent.ClipsDescendants = true
			end
			if id == "none" then
				img.Image = ""
				img.Visible = true
				img.ImageTransparency = 1
				img.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
				img.BackgroundTransparency = 0
			else
				img.Image = url
				img.Visible = true
				img.ImageTransparency = 0
				img.BackgroundTransparency = 1
			end
		end
		pcall(function()
			paint(getgenv()._070HubBackground)
		end)
		pcall(function()
			if id == "none" then
				local bg = getgenv()._070HubBackground
				if bg and bg.Parent and bg.Parent:IsA("Frame") then
					bg.Parent.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
					bg.Parent.BackgroundTransparency = 0
				end
			end
		end)
		-- spin bot wallpaper
		pcall(function()
			local bg = getgenv()._070SpinBotBg
			if bg and bg.Parent then
				paint(bg)
			end
			-- find live spin UI if ref lost
			for _, root in ipairs({ game:GetService("CoreGui"), game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") }) do
				if root then
					local ui = root:FindFirstChild("070SpinBotUI")
					if ui then
						local img = ui:FindFirstChild("SpinBotBg", true)
						if img then
							getgenv()._070SpinBotBg = img
							paint(img)
						end
					end
				end
			end
		end)
		pcall(function()
			local gui = getgenv()._070MainGui
			if gui then
				for _, d in ipairs(gui:GetDescendants()) do
					if d:IsA("ImageLabel") and (d.Name == "HubBg" or d.Name == "Background" or d.Name == "UIBackground" or d.Name == "SpinBotBg") then
						paint(d)
					end
				end
			end
		end)
	end

qaLocked = true
qaFrames = {}
qaDefaultPos = {}
showMobileButtons = true
LAGGER_SPEED = 35
LAGGER_CARRY_SPEED = 18
speedMode = false
antiRagdollEnabled = false
infJumpEnabled = false
laggerToggled = false
laggerPhase = 0

-- =====================================================================
-- =====================================================================
-- SPIN BOT MODULE (Config toggle shows/hides UI)
-- Grounded · Slow 600 / Normal 1500 / Fast 5000 / Very Fast 10000 / Max 50000 deg/s
-- Single keybind (PC + controller) · No super jump · Soft release
-- =====================================================================
do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local LP = Players.LocalPlayer

	local MODES = {
		Slow     = 600,
		Normal   = 1500,
		Fast     = 5000,
		VeryFast = 10000,
		Max      = 500000,
	}

	local MODE_ORDER = { "Slow", "Normal", "Fast", "VeryFast", "Max" }

	local State = {
		Armed = false,
		Spinning = false,
		Mode = "Normal",
		Speed = MODES.Normal,
		Conn = nil,
		Angle = 0,
		DropUntil = 0,
		JumpUntil = 0,
		LastHealth = nil,
		HitUntil = 0,
		GroundY = nil,
		Listening = false,
		BindKb = Enum.KeyCode.X,
		BindGp = nil,
		UIVisible = false,
	}

	local HIT_COOLDOWN = 0.18
	local Visuals = { trail = nil, att0 = nil, att1 = nil, part = nil }
	local SAVE_FILE = "070Spin_Binds.json"

	local function saveBinds()
		pcall(function()
			if not writefile then return end
			local HttpService = game:GetService("HttpService")
			local data = {
				kb = State.BindKb and State.BindKb.Name or nil,
				gp = State.BindGp and State.BindGp.Name or nil,
				mode = State.Mode,
			}
			writefile(SAVE_FILE, HttpService:JSONEncode(data))
		end)
	end

	local function loadBinds()
		pcall(function()
			if not (isfile and readfile and isfile(SAVE_FILE)) then return end
			local HttpService = game:GetService("HttpService")
			local data = HttpService:JSONDecode(readfile(SAVE_FILE))
			if type(data) ~= "table" then return end
			if type(data.kb) == "string" and Enum.KeyCode[data.kb] then
				State.BindKb = Enum.KeyCode[data.kb]
			end
			if type(data.gp) == "string" and Enum.KeyCode[data.gp] then
				State.BindGp = Enum.KeyCode[data.gp]
			end
			if type(data.mode) == "string" and MODES[data.mode] then
				State.Mode = data.mode
				State.Speed = MODES[data.mode]
			end
		end)
	end
	loadBinds()

	local function getChar()
		return LP.Character
	end

	local function getRoot()
		local c = getChar()
		return c and c:FindFirstChild("HumanoidRootPart")
	end

	local function getHum()
		local c = getChar()
		return c and c:FindFirstChildOfClass("Humanoid")
	end

	local function clearVisuals()
		for _, key in ipairs({ "trail", "att0", "att1", "part" }) do
			local obj = Visuals[key]
			if obj then
				pcall(function() obj:Destroy() end)
				Visuals[key] = nil
			end
		end
		local char = getChar()
		if char then
			local back = char:FindFirstChild("070SpinBack")
			if back then pcall(function() back:Destroy() end) end
		end
	end

	local function setupVisuals()
		clearVisuals()
		local char = getChar()
		local root = getRoot()
		if not char or not root then return end

		local back = Instance.new("Part")
		back.Name = "070SpinBack"
		back.Size = Vector3.new(0.2, 0.2, 0.2)
		back.Transparency = 1
		back.CanCollide = false
		back.CanTouch = false
		back.CanQuery = false
		back.Massless = true
		back.Parent = char
		Visuals.part = back

		local weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = back
		weld.C0 = CFrame.new(0, 0, 1.15)
		weld.Parent = back

		local att0 = Instance.new("Attachment")
		att0.Position = Vector3.new(0, 1.1, 0)
		att0.Parent = back
		Visuals.att0 = att0

		local att1 = Instance.new("Attachment")
		att1.Position = Vector3.new(0, -1.1, 0)
		att1.Parent = back
		Visuals.att1 = att1

		local trail = Instance.new("Trail")
		trail.Attachment0 = att0
		trail.Attachment1 = att1
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 140, 255)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(170, 80, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 40, 255)),
		})
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.15),
			NumberSequenceKeypoint.new(1, 0.9),
		})
		trail.Lifetime = 1.2
		trail.MinLength = 0.05
		trail.MaxLength = 36
		trail.LightEmission = 1
		trail.LightInfluence = 0
		trail.FaceCamera = true
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3.6),
			NumberSequenceKeypoint.new(0.4, 2.4),
			NumberSequenceKeypoint.new(1, 0.2),
		})
		trail.Parent = back
		Visuals.trail = trail
	end

	local function groundY(root, hum)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { getChar() }
		local origin = root.Position + Vector3.new(0, 4, 0)
		local hit = Workspace:Raycast(origin, Vector3.new(0, -100, 0), params)
		if hit then
			local hip = (hum and hum.HipHeight) or 2
			return hit.Position.Y + hip + root.Size.Y * 0.5
		end
		return nil
	end

	local function looksLikeBrainrot(inst)
		if not inst then return false end
		local n = string.lower(tostring(inst.Name))
		if n:find("brainrot", 1, true) or n:find("brain rot", 1, true) or n:find("animal", 1, true) then
			return true
		end
		if inst:IsA("Tool") then
			if n:find("bat", 1, true) or n:find("slap", 1, true) then return false end
			if n:find("sword", 1, true) or n:find("gun", 1, true) then return false end
			if n:find("coil", 1, true) or n:find("speed", 1, true) then return false end
			return true
		end
		if inst:IsA("Model") and (n:find("brainrot", 1, true) or n:find("animal", 1, true)) then
			return true
		end
		return false
	end

	local function isHoldingBrainrot()
		local char = getChar()
		if not char then return false end
		local ok, attr = pcall(function()
			return LP:GetAttribute("Stealing") or char:GetAttribute("Stealing")
		end)
		if ok and (attr == true or attr == 1) then return true end
		for _, child in ipairs(char:GetChildren()) do
			if (child:IsA("Tool") or child:IsA("Model")) and looksLikeBrainrot(child) then
				return true
			end
		end
		for _, name in ipairs({ "Carrying", "IsCarrying", "Carried", "Holding", "Grabbed", "HasGrab", "Stealing" }) do
			local v = char:FindFirstChild(name, true)
			if v then
				if v:IsA("BoolValue") and v.Value == true then return true end
				if v:IsA("ObjectValue") and v.Value ~= nil then return true end
				if v:IsA("StringValue") and v.Value ~= "" then return true end
			end
		end
		return false
	end

	local function isAirborne(hum)
		if not hum then return false end
		local st = hum:GetState()
		return st == Enum.HumanoidStateType.Jumping
			or st == Enum.HumanoidStateType.Freefall
			or hum.FloorMaterial == Enum.Material.Air
	end

	local function isRagdoll(hum)
		if not hum then return true end
		local st = hum:GetState()
		return hum.PlatformStand
			or st == Enum.HumanoidStateType.Physics
			or st == Enum.HumanoidStateType.Ragdoll
			or st == Enum.HumanoidStateType.FallingDown
	end

	local function stopSpinOnly()
		State.Spinning = false
		State.GroundY = nil
		clearVisuals()
		local root = getRoot()
		if root then
			pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
		end
		local hum = getHum()
		if hum then pcall(function() hum.AutoRotate = true end) end
	end

	local function startSpinOnly()
		if State.Spinning then return end
		State.Spinning = true
		local root = getRoot()
		local hum = getHum()
		if root then
			local look = root.CFrame.LookVector
			State.Angle = math.atan2(-look.X, -look.Z)
			State.GroundY = groundY(root, hum)
		end
		if hum then
			pcall(function() hum.AutoRotate = false end)
			State.LastHealth = hum.Health
		end
		pcall(setupVisuals)
	end

	local function stopAll()
		State.Armed = false
		if State.Conn then
			pcall(function() State.Conn:Disconnect() end)
			State.Conn = nil
		end
		stopSpinOnly()
	end

	-- soft release only — NO super jump / NO forced Y boost
	local function releaseSpinSoft(duration)
		State.DropUntil = tick() + (duration or 0.85)
		State.JumpUntil = tick() + (duration or 0.85)
		State.GroundY = nil
		local root = getRoot()
		local hum = getHum()
		if root then
			pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
		end
		if hum then
			pcall(function() hum.AutoRotate = true end)
		end
	end

	local function startArmed()
		stopAll()
		State.Armed = true
		local holdAccum = 0

		State.Conn = RunService.Heartbeat:Connect(function(dt)
			if not State.Armed then return end
			dt = math.clamp(dt or 0.016, 0, 0.05)

			-- soft release window: no CFrame plant, no forced velocity
			if tick() < (State.DropUntil or 0) then
				local root = getRoot()
				local hum = getHum()
				if hum then pcall(function() hum.AutoRotate = true end) end
				if root then root.AssemblyAngularVelocity = Vector3.zero end
				return
			end

			holdAccum = holdAccum + dt
			local doCheck = holdAccum >= 0.08
			if doCheck then holdAccum = 0 end

			local holding = State.Spinning
			if doCheck then
				holding = false
				pcall(function() holding = isHoldingBrainrot() end)
			end

			if not holding then
				if State.Spinning then
					stopSpinOnly()
					if paintUI then paintUI() end
				end
				return
			end

			if not State.Spinning then
				startSpinOnly()
				if paintUI then paintUI() end
			end

			local root = getRoot()
			local hum = getHum()
			if not root or not hum or hum.Health <= 0 then return end
			if isRagdoll(hum) then
				root.AssemblyAngularVelocity = Vector3.zero
				return
			end

			hum.AutoRotate = false

			if State.LastHealth and hum.Health < State.LastHealth - 0.5 then
				State.HitUntil = tick() + HIT_COOLDOWN
			end
			State.LastHealth = hum.Health

			local degPerSec = math.clamp(tonumber(State.Speed) or MODES.Normal, 1, 500000)

			if tick() < State.HitUntil then
				root.AssemblyAngularVelocity = Vector3.zero
				return
			end

			State.Angle = State.Angle + math.rad(degPerSec) * dt

			local pos = root.Position
			local lv = root.AssemblyLinearVelocity
			local jumping = tick() < State.JumpUntil or isAirborne(hum)

			if jumping then
				-- natural jump only — do not touch linear velocity
				root.CFrame = CFrame.new(pos) * CFrame.Angles(0, State.Angle, 0)
				root.AssemblyAngularVelocity = Vector3.zero
			else
				local gy = groundY(root, hum)
				if gy then State.GroundY = gy end
				local y = State.GroundY or pos.Y
				root.CFrame = CFrame.new(pos.X, y, pos.Z) * CFrame.Angles(0, State.Angle, 0)
				local yv = lv.Y
				if yv > 0 then yv = 0 end
				root.AssemblyLinearVelocity = Vector3.new(lv.X, yv, lv.Z)
				root.AssemblyAngularVelocity = Vector3.zero
			end

			if not Visuals.trail or not Visuals.trail.Parent then
				pcall(setupVisuals)
			end
		end)
	end

	local paintUI
	local gui, frame, mini, spinRight, modeRight, statusRight, bindRight

	local function setArmed(on)
		if on then startArmed() else stopAll() end
		if paintUI then paintUI() end
	end

	local function setMode(name)
		if not MODES[name] then return end
		State.Mode = name
		State.Speed = MODES[name]
		saveBinds()
		if paintUI then paintUI() end
	end

	local function bindLabel()
		local kb = State.BindKb and State.BindKb.Name or "NONE"
		local gp = State.BindGp and State.BindGp.Name or "NONE"
		return kb .. " / " .. gp
	end

	local function destroySpinUI()
		pcall(function()
			if gui then gui:Destroy() end
		end)
		gui, frame, mini, spinRight, modeRight, statusRight, bindRight = nil, nil, nil, nil, nil, nil, nil
		State.UIVisible = false
	end

	local function buildSpinUI()
		destroySpinUI()

		-- clean any leftover
		pcall(function()
			for _, parent in ipairs({ game:GetService("CoreGui"), LP:FindFirstChildOfClass("PlayerGui") }) do
				if parent then
					local old = parent:FindFirstChild("070SpinBotUI")
					if old then old:Destroy() end
				end
			end
		end)

		gui = Instance.new("ScreenGui")
		gui.Name = "070SpinBotUI"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		pcall(function() gui.Parent = game:GetService("CoreGui") end)
		if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
		pcall(function()
			if getgenv().__yenProtectGui then getgenv().__yenProtectGui(gui) end
		end)

		local WHITE = Color3.fromRGB(255, 255, 255)
		local MUTED = Color3.fromRGB(200, 200, 210)

		frame = Instance.new("Frame")
		frame.Name = "Main"
		frame.Size = UDim2.fromOffset(220, 132)
		frame.Position = UDim2.new(0, 18, 0.38, 0)
		frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

		-- wallpaper bg (follows hub wallpaper)
		local spinBg = Instance.new("ImageLabel")
		spinBg.Name = "SpinBotBg"
		spinBg.Size = UDim2.fromScale(1, 1)
		spinBg.BackgroundTransparency = 1
		spinBg.ScaleType = Enum.ScaleType.Crop
		spinBg.ZIndex = 0
		spinBg.Parent = frame
		Instance.new("UICorner", spinBg).CornerRadius = UDim.new(0, 10)
		local shade = Instance.new("Frame")
		shade.Size = UDim2.fromScale(1, 1)
		shade.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
		shade.BackgroundTransparency = 0.45
		shade.BorderSizePixel = 0
		shade.ZIndex = 1
		shade.Parent = frame
		Instance.new("UICorner", shade).CornerRadius = UDim.new(0, 10)
		getgenv()._070SpinBotBg = spinBg
		pcall(function()
			local id = tostring(getgenv()._070CurrentBgAsset or "103010175848787"):gsub("%D", "")
			spinBg.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420"
		end)

		-- minimize chip (UI hides, script stays alive)
		mini = Instance.new("TextButton")
		mini.Name = "MiniChip"
		mini.Size = UDim2.fromOffset(92, 26)
		mini.Position = frame.Position
		mini.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
		mini.BorderSizePixel = 0
		mini.Font = Enum.Font.GothamBlack
		mini.TextSize = 11
		mini.TextColor3 = Color3.fromRGB(230, 220, 255)
		mini.Text = "SPIN"
		mini.Visible = false
		mini.AutoButtonColor = false
		mini.Parent = gui
		Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 8)
		local miniStroke = Instance.new("UIStroke")
		miniStroke.Color = Color3.fromRGB(80, 100, 180)
		miniStroke.Thickness = 1
		miniStroke.Transparency = 0.35
		miniStroke.Parent = mini

		local uiOpen = true
		local function setUIOpen(open)
			uiOpen = open
			frame.Visible = open
			mini.Visible = not open
			if not open then
				mini.Position = frame.Position
				if State.Armed and State.Spinning then
					mini.Text = "SPIN · ON"
					mini.TextColor3 = Color3.fromRGB(120, 255, 160)
				elseif State.Armed then
					mini.Text = "SPIN · WAIT"
					mini.TextColor3 = Color3.fromRGB(255, 220, 120)
				else
					mini.Text = "SPIN"
					mini.TextColor3 = Color3.fromRGB(230, 220, 255)
				end
			end
		end

		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.fromOffset(18, 18)
		closeBtn.Position = UDim2.new(1, -22, 0, 4)
		closeBtn.BackgroundColor3 = Color3.fromRGB(30, 28, 40)
		closeBtn.BorderSizePixel = 0
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 12
		closeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
		closeBtn.Text = "–"
		closeBtn.AutoButtonColor = false
		closeBtn.ZIndex = 20
		closeBtn.Parent = frame
		Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
		closeBtn.MouseButton1Click:Connect(function()
			setUIOpen(false)
		end)
		mini.MouseButton1Click:Connect(function()
			setUIOpen(true)
		end)

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(80, 100, 180)
		stroke.Thickness = 1.2
		stroke.Transparency = 0.35
		stroke.Parent = frame

		local list = Instance.new("Frame")
		list.Size = UDim2.new(1, -16, 1, -28)
		list.Position = UDim2.fromOffset(8, 22)
		list.BackgroundTransparency = 1
		list.ZIndex = 5
		list.Parent = frame
		Instance.new("UIListLayout", list).Padding = UDim.new(0, 4)

		local function makeRow(order, leftText, rightText, rightColor)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 22)
			row.BackgroundTransparency = 1
			row.LayoutOrder = order
			row.ZIndex = 6
			row.Parent = list

			local left = Instance.new("TextLabel")
			left.Size = UDim2.new(0.45, 0, 1, 0)
			left.BackgroundTransparency = 1
			left.Font = Enum.Font.GothamBlack
			left.TextSize = 11
			left.TextColor3 = WHITE
			left.TextXAlignment = Enum.TextXAlignment.Left
			left.Text = leftText
			left.ZIndex = 7
			left.Parent = row

			local right = Instance.new("TextButton")
			right.Size = UDim2.new(0.55, 0, 1, 0)
			right.Position = UDim2.new(0.45, 0, 0, 0)
			right.BackgroundTransparency = 1
			right.Font = Enum.Font.GothamBlack
			right.TextSize = 11
			right.TextColor3 = rightColor or WHITE
			right.TextXAlignment = Enum.TextXAlignment.Right
			right.Text = rightText
			right.AutoButtonColor = false
			right.ZIndex = 7
			right.Parent = row
			return right
		end

		spinRight = makeRow(1, "SPIN", "OFF", WHITE)
		modeRight = makeRow(2, "MODE", "NORMAL", WHITE)
		statusRight = makeRow(3, "STATUS", "IDLE", MUTED)
		bindRight = makeRow(4, "KEYBIND", bindLabel(), WHITE)

		modeRight.MouseButton1Click:Connect(function()
			local idx = 1
			for i, name in ipairs(MODE_ORDER) do
				if name == State.Mode then
					idx = i
					break
				end
			end
			local nextMode = MODE_ORDER[(idx % #MODE_ORDER) + 1]
			setMode(nextMode)
		end)
		spinRight.MouseButton1Click:Connect(function()
			setArmed(not State.Armed)
		end)
		bindRight.MouseButton1Click:Connect(function()
			State.Listening = true
			bindRight.Text = "PRESS KEY / BUTTON..."
			bindRight.TextColor3 = Color3.fromRGB(255, 220, 120)
		end)

		paintUI = function()
			if not spinRight then return end
			if State.Armed then
				spinRight.Text = "ON"
				spinRight.TextColor3 = Color3.fromRGB(120, 255, 160)
			else
				spinRight.Text = "OFF"
				spinRight.TextColor3 = WHITE
			end
			modeRight.Text = (State.Mode == "VeryFast") and "VERY FAST" or (State.Mode == "Max") and "MAX" or string.upper(State.Mode)
			modeRight.TextColor3 = WHITE
			if not State.Armed then
				statusRight.Text = "IDLE"
				statusRight.TextColor3 = MUTED
			elseif State.Spinning then
				statusRight.Text = "SPINNING"
				statusRight.TextColor3 = Color3.fromRGB(120, 255, 160)
			else
				statusRight.Text = "WAITING"
				statusRight.TextColor3 = Color3.fromRGB(255, 220, 120)
			end
			if not State.Listening then
				bindRight.Text = bindLabel()
				bindRight.TextColor3 = WHITE
			end
			-- refresh mini chip if collapsed
			pcall(function()
				if mini and mini.Visible then
					if State.Armed and State.Spinning then
						mini.Text = "SPIN · ON"
						mini.TextColor3 = Color3.fromRGB(120, 255, 160)
					elseif State.Armed then
						mini.Text = "SPIN · WAIT"
						mini.TextColor3 = Color3.fromRGB(255, 220, 120)
					else
						mini.Text = "SPIN"
						mini.TextColor3 = Color3.fromRGB(230, 220, 255)
					end
				end
			end)
		end

		task.spawn(function()
			while gui and gui.Parent do
				task.wait(0.15)
				if State.Armed then paintUI() end
			end
		end)

		-- drag main frame
		do
			local dragging, startPos, startInput
			frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					startPos = frame.Position
					startInput = input.Position
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if not dragging then return end
				if input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch then
					local d = input.Position - startInput
					frame.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + d.X,
						startPos.Y.Scale, startPos.Y.Offset + d.Y
					)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
		end

		-- drag mini chip
		do
			local dragging, startPos, startInput
			mini.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					startPos = mini.Position
					startInput = input.Position
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if not dragging then return end
				if input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch then
					local d = input.Position - startInput
					mini.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + d.X,
						startPos.Y.Scale, startPos.Y.Offset + d.Y
					)
					frame.Position = mini.Position
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
		end

		State.UIVisible = true
		paintUI()
	end

	-- Input listener (always active when module is loaded)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not State.UIVisible then return end

		-- one listener: keyboard sets PC, gamepad sets controller
		if State.Listening then
			if input.KeyCode == Enum.KeyCode.Escape then
				State.Listening = false
				paintUI()
				return
			end
			if input.KeyCode == Enum.KeyCode.Unknown then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				State.BindKb = input.KeyCode
				State.Listening = false
				saveBinds()
				paintUI()
				return
			end
			local n = input.KeyCode.Name
			if n:find("Button") then
				State.BindGp = input.KeyCode
				State.Listening = false
				saveBinds()
				paintUI()
				return
			end
			return
		end

		local kc = input.KeyCode
		local hit = false
		if State.BindKb and kc == State.BindKb and input.UserInputType == Enum.UserInputType.Keyboard then
			hit = true
		end
		if State.BindGp and kc == State.BindGp then
			hit = true
		end

		if hit then
			-- soft release only — no super jump
			if State.Spinning or State.Armed then
				releaseSpinSoft(0.9)
			end
		end

		-- natural jump: only open jump window, never boost Y
		if not gpe and (kc == Enum.KeyCode.Space or kc == Enum.KeyCode.ButtonA) then
			if State.Spinning or State.Armed then
				State.JumpUntil = tick() + 0.75
				local hum = getHum()
				if hum then
					pcall(function()
						hum.AutoRotate = true
						-- let game jump handle height — do NOT set AssemblyLinearVelocity.Y
					end)
				end
			end
		end
	end)

	local function setSpinBotEnabled(on)
		on = on == true
		if on then
			buildSpinUI()
		else
			stopAll()
			destroySpinUI()
		end
		getgenv()._070SpinBotEnabled = on
	end

	getgenv()._070SetSpinBot = setSpinBotEnabled
	getgenv()._070IsSpinBot = function()
		return State.UIVisible == true
	end

	LP.CharacterAdded:Connect(function()
		stopSpinOnly()
		task.wait(0.5)
		if State.Armed and State.UIVisible then
			startArmed()
		end
	end)

	do end -- muted
end


-- =====================================================================
-- VISUALS: Bat Skins + Motion Trails (from burger wallpaper 070)
-- =====================================================================
do
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local purple = Color3.fromRGB(170, 120, 255)
	local cyan = Color3.fromRGB(100, 220, 255)
	local dark = Color3.fromRGB(28, 30, 42)
	local white = Color3.fromRGB(240, 240, 255)

	local BAT_SKINS = {
		"Original", "Katana", "Neon Bat", "Obsidian",
		"Crimson Katana", "Crystal Blade", "War Hammer",
	}

	local state = {
		batSkin = "Original",
		trails = false,
		trailColor1 = purple,
		trailColor2 = cyan,
	}

	local toolRecords = {}
	local trailObjects = {}
	local connections = {}
	local containerConnections = {}
	local alive = true

	local function own(inst)
		pcall(function()
			if syn and syn.protect_gui then syn.protect_gui(inst) end
		end)
		return inst
	end

	local function disconnect(list)
		for _, c in ipairs(list) do
			pcall(function() c:Disconnect() end)
		end
		table.clear(list)
	end

	local function removeObjects(list)
		for _, o in ipairs(list) do
			pcall(function() o:Destroy() end)
		end
		table.clear(list)
	end

	local function snapshot(part, props)
		local data = {}
		for _, p in ipairs(props) do
			pcall(function() data[p] = part[p] end)
		end
		return data
	end

	local function restore(part, data)
		if not part or not data then return end
		for k, v in pairs(data) do
			pcall(function() part[k] = v end)
		end
	end

	local function isBat(tool)
		return tool and tool:IsA("Tool") and string.find(string.lower(tool.Name), "bat", 1, true) ~= nil
	end

	local function restoreTool(record)
		if record.folder then
			pcall(function() record.folder:Destroy() end)
			record.folder = nil
		end
		for object, saved in pairs(record.original) do
			restore(object, saved)
		end
		table.clear(record.original)
	end

	local function createCosmetic(record)
		local tool = record.tool
		local handle = tool:FindFirstChild("Handle")
		if not handle or not handle:IsA("BasePart") or state.batSkin == "Original" then
			return
		end
		for _, descendant in ipairs(tool:GetDescendants()) do
			if descendant:IsA("BasePart") then
				record.original[descendant] = snapshot(descendant, { "LocalTransparencyModifier", "CastShadow" })
				descendant.LocalTransparencyModifier = 1
				descendant.CastShadow = false
			end
		end
		local folder = own(Instance.new("Model"))
		folder.Name = "070BatCosmetic"
		folder.Parent = tool
		record.folder = folder
		local skin = state.batSkin
		local accent = skin == "Crimson Katana" and Color3.fromRGB(255, 58, 97)
			or (skin == "Crystal Blade" and cyan or purple)

		local function part(name, size, offset, color, material, shape)
			local object = own(Instance.new("Part"))
			object.Name = "070" .. name
			object.Size = size
			object.Color = color
			object.Material = material or Enum.Material.Metal
			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Massless = true
			object.CastShadow = false
			object.Anchored = false
			object.TopSurface = Enum.SurfaceType.Smooth
			object.BottomSurface = Enum.SurfaceType.Smooth
			if shape then object.Shape = shape end
			object.CFrame = handle.CFrame * offset
			object.Parent = folder
			local weld = Instance.new("WeldConstraint")
			weld.Name = "070CosmeticWeld"
			weld.Part0 = handle
			weld.Part1 = object
			weld.Parent = object
			return object
		end

		local rotate = CFrame.Angles(0, 0, math.pi / 2)
		local grip = Color3.fromRGB(27, 29, 42)
		part("Grip", Vector3.new(0.22, 1.1, 0.22), CFrame.new(0, -0.42, 0), grip)

		if skin == "Neon Bat" or skin == "Obsidian" then
			local barrelColor = skin == "Obsidian" and Color3.fromRGB(34, 32, 48) or accent
			local barrelMaterial = skin == "Obsidian" and Enum.Material.Slate or Enum.Material.Neon
			part("BatBarrel", Vector3.new(2.45, 0.5, 0.5), CFrame.new(0, 1.14, 0) * rotate, barrelColor, barrelMaterial, Enum.PartType.Cylinder)
			for _, y in ipairs({ 0.1, 1.1, 2.15 }) do
				part("BatBand", Vector3.new(0.09, 0.53, 0.53), CFrame.new(0, y, 0) * rotate, accent, Enum.Material.Neon, Enum.PartType.Cylinder)
			end
		elseif skin == "War Hammer" then
			part("HammerShaft", Vector3.new(0.23, 2.2, 0.23), CFrame.new(0, 0.75, 0), Color3.fromRGB(84, 88, 111))
			part("HammerHead", Vector3.new(1.65, 0.85, 0.65), CFrame.new(0, 2.02, 0), dark)
			part("HammerCore", Vector3.new(0.14, 0.92, 0.7), CFrame.new(0, 2.02, 0), accent, Enum.Material.Neon)
			for _, x in ipairs({ -0.78, 0.78 }) do
				part("HammerCap", Vector3.new(0.16, 0.92, 0.72), CFrame.new(x, 2.02, 0), accent, Enum.Material.Neon)
			end
		else
			local crystal = skin == "Crystal Blade"
			local metalColor = skin == "Katana" and Color3.fromRGB(211, 225, 240) or dark
			part("Blade", Vector3.new(crystal and 0.42 or 0.25, 2.65, 0.12), CFrame.new(0, 1.25, 0), metalColor)
			part("BladeEdge", Vector3.new(0.07, 2.68, 0.14), CFrame.new(crystal and 0.23 or 0.145, 1.25, 0), accent, Enum.Material.Neon)
			part("Guard", Vector3.new(crystal and 0.9 or 0.65, 0.12, 0.35), CFrame.new(0, -0.15, 0), accent, Enum.Material.Neon)
			if crystal then
				part("CrystalCore", Vector3.new(0.12, 2.75, 0.16), CFrame.new(0, 1.25, 0), cyan, Enum.Material.Neon)
				part("CrystalPommel", Vector3.new(0.27, 0.27, 0.27), CFrame.new(0, -1.0, 0), cyan, Enum.Material.Neon, Enum.PartType.Ball)
			else
				for index = 0, 5 do
					part("GripWrap", Vector3.new(0.235, 0.07, 0.235), CFrame.new(0, -0.85 + index * 0.14, 0), accent, Enum.Material.Metal)
				end
			end
		end
	end

	local function setBatSkin(preset)
		if not alive then return false end
		local ok = false
		for _, name in ipairs(BAT_SKINS) do
			if name == preset then ok = true break end
		end
		if not ok then return false end
		state.batSkin = preset
		_G._070BatKatanaEnabled = false
		for _, record in pairs(toolRecords) do
			restoreTool(record)
			createCosmetic(record)
		end
		-- persist immediately
		pcall(function()
			if getgenv()._070SaveAll then getgenv()._070SaveAll() end
		end)
		return true
	end

	local function rebuildTrails()
		removeObjects(trailObjects)
		if not alive or not state.trails or not player.Character then return end
		local character = player.Character
		local function addTrail(part)
			if not part or not part:IsA("BasePart") then return end
			local top = own(Instance.new("Attachment"))
			top.Name = "070TrailTop"
			top.Position = Vector3.new(0, 0.25, 0)
			top.Parent = part
			trailObjects[#trailObjects + 1] = top
			local bottom = own(Instance.new("Attachment"))
			bottom.Name = "070TrailBottom"
			bottom.Position = Vector3.new(0, -0.25, 0)
			bottom.Parent = part
			trailObjects[#trailObjects + 1] = bottom
			local trail = own(Instance.new("Trail"))
			trail.Name = "070MotionTrail"
			trail.Attachment0 = top
			trail.Attachment1 = bottom
			trail.Color = ColorSequence.new(state.trailColor1 or purple, state.trailColor2 or cyan)
			trail.Lifetime = 0.18
			trail.MinLength = 0.15
			trail.MaxLength = 8
			trail.LightEmission = 0.35
			trail.FaceCamera = true
			trail.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(1, 1),
			})
			trail.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			})
			trail.Parent = part
			trailObjects[#trailObjects + 1] = trail
		end
		local left = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
		local right = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		if left or right then
			addTrail(left)
			addTrail(right)
		else
			addTrail(character:FindFirstChild("HumanoidRootPart"))
		end
	end

	local function setTrails(enabled)
		if not alive then return false end
		state.trails = enabled == true
		rebuildTrails()
		pcall(function()
			if getgenv()._070SaveAll then getgenv()._070SaveAll() end
		end)
		return true
	end

	local function trackTool(tool)
		if not alive or not isBat(tool) then return end
		if toolRecords[tool] then return end
		local record = { tool = tool, original = {}, connections = {} }
		toolRecords[tool] = record
		createCosmetic(record)
		record.connections[#record.connections + 1] = tool.ChildAdded:Connect(function(child)
			if child.Name == "Handle" then
				task.defer(function()
					if alive and toolRecords[tool] == record then
						restoreTool(record)
						createCosmetic(record)
					end
				end)
			end
		end)
		record.connections[#record.connections + 1] = tool.AncestryChanged:Connect(function()
			task.defer(function()
				if not alive or toolRecords[tool] ~= record then return end
				local backpack = player:FindFirstChildOfClass("Backpack")
				local character = player.Character
				if (backpack and tool:IsDescendantOf(backpack))
					or (character and tool:IsDescendantOf(character)) then
					return
				end
				restoreTool(record)
				disconnect(record.connections)
				toolRecords[tool] = nil
			end)
		end)
	end

	local function bindContainers()
		disconnect(containerConnections)
		local character = player.Character
		local backpack = player:FindFirstChildOfClass("Backpack")
		local containers = {}
		if character then containers[#containers + 1] = character end
		if backpack then containers[#containers + 1] = backpack end
		for _, container in ipairs(containers) do
			for _, child in ipairs(container:GetChildren()) do
				trackTool(child)
			end
			containerConnections[#containerConnections + 1] = container.ChildAdded:Connect(function(child)
				trackTool(child)
				if container == player.Character and child:IsA("BasePart") and state.trails then
					rebuildTrails()
				end
			end)
		end
		rebuildTrails()
	end

	connections[#connections + 1] = player.CharacterAdded:Connect(function()
		task.defer(function()
			if alive then bindContainers() end
		end)
	end)
	connections[#connections + 1] = player.CharacterRemoving:Connect(function(character)
		removeObjects(trailObjects)
		for tool, record in pairs(toolRecords) do
			if tool:IsDescendantOf(character) then
				restoreTool(record)
				disconnect(record.connections)
				toolRecords[tool] = nil
			end
		end
	end)
	connections[#connections + 1] = player.ChildAdded:Connect(function(child)
		if child:IsA("Backpack") then
			task.defer(function()
				if alive then bindContainers() end
			end)
		end
	end)
	task.defer(bindContainers)

	local function setTrailColor(c1, c2, c3)
		if typeof(c1) == "Color3" then
			state.trailColor1 = c1
			if typeof(c2) == "Color3" then
				state.trailColor2 = c2
			else
				state.trailColor2 = c1:Lerp(Color3.new(1, 1, 1), 0.45)
			end
		elseif type(c1) == "number" and type(c2) == "number" and type(c3) == "number" then
			state.trailColor1 = Color3.fromRGB(c1, c2, c3)
			state.trailColor2 = state.trailColor1:Lerp(Color3.new(1, 1, 1), 0.45)
		end
		if state.trails then rebuildTrails() end
		pcall(function()
			local p = getgenv()._070Persist or _G._070Persist
			if type(p) ~= "table" then p = {}; getgenv()._070Persist = p; _G._070Persist = p end
			p.trailColorR = math.floor(state.trailColor1.R * 255 + 0.5)
			p.trailColorG = math.floor(state.trailColor1.G * 255 + 0.5)
			p.trailColorB = math.floor(state.trailColor1.B * 255 + 0.5)
			if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
		end)
		return true
	end

	getgenv()._070SetBatSkin = setBatSkin
	getgenv()._070SetTrails = setTrails
	getgenv()._070SetTrailColor = setTrailColor
	getgenv()._070GetTrailColor = function()
		return state.trailColor1, state.trailColor2
	end
	getgenv()._070GetBatSkins = function()
		return BAT_SKINS, state.batSkin
	end
	getgenv()._070GetTrails = function()
		return state.trails
	end
	_G._070Visuals = {
		SetBatSkin = setBatSkin,
		SetTrails = setTrails,
		SetTrailColor = setTrailColor,
		GetBatSkin = function() return state.batSkin end,
		GetTrails = function() return state.trails end,
		GetTrailColor = function() return state.trailColor1, state.trailColor2 end,
		Skins = BAT_SKINS,
	}

	do end -- muted
end



-- ========== 070 exact speed method ==========
do
	local MOVE_KEYS = {
		[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
		[Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
		[Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
		[Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
	}
	local lastMoveDir = Vector3.zero
	local velChecked = {}
	local hookedVelParts = {}

	local function setupVelChecked(char)
		velChecked = {}
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			pcall(function() hrp = char:WaitForChild("HumanoidRootPart", 5) end)
		end
		if hrp then velChecked[hrp] = true end
		return hrp
	end

	local function hookVelHRP(hrp)
		if not hrp or hookedVelParts[hrp] then return end
		if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function" then return end
		hookedVelParts[hrp] = true
		pcall(function()
			local mt = getrawmetatable(hrp)
			if not mt then return end
			setreadonly(mt, false)
			local originalVelIndex = rawget(mt, "__index")
			local wrapper = function(self, key)
				if (not checkcaller or not checkcaller()) and velChecked[self] and (key == "AssemblyLinearVelocity" or key == "Velocity") then
					local real
					if type(originalVelIndex) == "function" then
						real = originalVelIndex(self, key)
					elseif type(originalVelIndex) == "table" then
						real = originalVelIndex[key]
					end
					if typeof(real) == "Vector3" and real.Magnitude > 20 then
						return real.Unit * 20
					end
					return real
				end
				if type(originalVelIndex) == "function" then
					return originalVelIndex(self, key)
				elseif type(originalVelIndex) == "table" then
					return originalVelIndex[key]
				end
			end
			if type(newcclosure) == "function" then
				mt.__index = newcclosure(wrapper)
			else
				mt.__index = wrapper
			end
			setreadonly(mt, true)
		end)
	end

	if localPlayer.Character then
		hookVelHRP(setupVelChecked(localPlayer.Character))
	end
	localPlayer.CharacterAdded:Connect(function(char)
		hookedVelParts = {}
		task.defer(function()
			hookVelHRP(setupVelChecked(char))
		end)
	end)

	local function getActiveMoveSpeed()
		-- Printed mapping: laggerPhase 2 = lagger carry, 1 = lagger, speedMode = carry
		if laggerToggled and laggerPhase == 2 then
			return tonumber(LAGGER_CARRY_SPEED) or 18
		elseif laggerToggled and (laggerPhase == 1 or laggerPhase ~= 0) then
			return tonumber(LAGGER_SPEED) or 35
		elseif speedMode then
			return tonumber(CS) or 30
		end
		return tonumber(NS) or 60
	end

	local function applyVelocitySpeed(dir, speed)
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not char or not hum or not root or hum.Health <= 0 then return end
		local yVel = root.AssemblyLinearVelocity.Y
		pcall(function()
			local ok, v = pcall(function() return root:GetVelocityAtPosition(root.Position) end)
			if ok and typeof(v) == "Vector3" then yVel = v.Y end
		end)
		if dir and dir.Magnitude > 0.05 then
			pcall(function()
				if root.SetNetworkOwner then root:SetNetworkOwner(localPlayer) end
			end)
			local unit = Vector3.new(dir.X, 0, dir.Z)
			if unit.Magnitude > 0.01 then unit = unit.Unit else unit = dir.Unit end
			local nextVel = Vector3.new(unit.X * speed, yVel, unit.Z * speed)
			pcall(function() root.AssemblyLinearVelocity = nextVel end)
			pcall(function() root.Velocity = nextVel end)
		else
			local nextVel = Vector3.new(0, yVel, 0)
			pcall(function() root.AssemblyLinearVelocity = nextVel end)
			pcall(function() root.Velocity = nextVel end)
		end
	end

	local function isRagdollState(hum)
		if not hum then return true end
		local st = hum:GetState()
		return hum.PlatformStand
			or st == Enum.HumanoidStateType.Physics
			or st == Enum.HumanoidStateType.Ragdoll
			or st == Enum.HumanoidStateType.FallingDown
	end

	RunService.RenderStepped:Connect(function()
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end
		if isRagdollState(hum) then
			lastMoveDir = Vector3.zero
			return
		end
		if autoBatEnabled == true or tpBatEnabled == true then return end

		local md = hum.MoveDirection
		local spd = getActiveMoveSpeed()
		local dir = nil
		if md.Magnitude > 0 then
			lastMoveDir = md
			dir = md
		elseif lastMoveDir.Magnitude > 0 then
			for key in pairs(MOVE_KEYS) do
				if UserInputService:IsKeyDown(key) then
					dir = lastMoveDir
					break
				end
			end
		end
		applyVelocitySpeed(dir, spd)
	end)
end
-- ========== end 070 speed ==========

medusaCounterEnabled = false
medusaCounterBlocked = true
medusaCounterBlockToken = 0
batCounterEnabled = false
batCounterV2Enabled = false
batCounterV2Mode = "Desync Aimbot"
batCounterVersion = "V1"
batCounterVersionHighlight = nil
countdownSoundActive = false
countdownSoundConn = nil

do
	local primaryValue = false
	espEnabled = false
	espTracersEnabled = false
	ragdollCountdownEnabled = primaryValue
end

do
	do
		do
			espArrowButton = nil
			setESPVisual = nil
			setESPTracersVisual = nil
			setRagdollCountdownVisual = nil
			espDetailsOpen = false
			espDetailsRows = {}
			espObjects = {}
			espConn = nil
			espGui = nil

			do
				local primaryValue = false
				medusaCounterDebounce = false
				medusaCounterLastUsed = 0
				dropActive = primaryValue
			end
		end

		autoLeftEnabled = false
		autoRightEnabled = false
		autoLeftSetVisual = nil
		autoRightSetVisual = nil
		speedLabel = nil
		ragdollCountdownLabel = nil
		autoBatEnabled = false
		autoBatConn = nil
		isAutoBatBusy = false
		autoSwingEnabled = true
		mirrorTPEnabled = true
		unwalkEnabled = false
		tpBatAutoSwingEnabled = true
		autoBatSetVisual = nil
		autoBatMode = "Vision"
		autoBatDefaultButton = nil
		autoBatBypassButton = nil
		autoBatArrowButton = nil
		autoBatModeHighlight = nil
		autoBatDetailsOpen = false
		autoBatDetailsRows = {}
		autoStealArrowButton = nil
		autoStealDetailsOpen = false
-- =====================================================================
-- 070Hub
-- =====================================================================
		autoStealDetailsRows = {}
		autoBatSpeedRow = nil
		bypassAutoBatSpeedRow = nil
		laggerAutoBatSpeedRow = nil
		bypassLaggerAutoBatSpeedRow = nil

		do
			local primaryValue = utf8.char(9650)
			local secondaryValue = utf8.char(9660)
			AUTO_BAT_ARROW_OPEN = primaryValue
			AUTO_BAT_ARROW_CLOSED = secondaryValue
		end
	end

	do
		tpBatEnabled = false
		tpBatConn = nil
		tpBatVoidConn = nil
		tpBatPreVoidConn = nil
		tpBatHitCooldown = false
		tpBatHumanoid = nil
		tpBatRoot = nil
		tpBatStartPosition = nil
		tpBatLastSafePosition = nil
		originalCollisionStates = setmetatable({}, { __mode = "k" })
		healthLoopConnection = nil
		characterHealthConnection = nil
		healthConnections = {}
		isHealthLockEnabled = false
		DESYNC_VOID_Y_LIMIT = -500
		DESYNC_COUNTER_VOID_Y = -35
		DESYNC_AIMBOT_RANGE = 100
		predictionData = {}
		setTPBatVisual = nil
		tpBatArrowButton = nil
		setTPBatAutoSwingVisual = nil
		tpBatDetailsOpen = false
		tpBatDetailsRows = {}
		showUIOnExecute = true
		setShowUIOnExecuteVisual = nil
		showSpeedBypassPanel = false
		setShowSpeedBypassPanelVisual = function() end
		-- Speed Bypass REMOVED
		isSpeedBypassEnabled = false
		isMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		desktopBypassPower = 97000
		mobileBypassPower = 72000
		text = isMobileDevice and "Mobile" or "PC"
		isSpeedBypassEnabled = false
		speedBypassPower = isMobileDevice and mobileBypassPower or desktopBypassPower
		thread = nil
		speedBypassPanel = nil
		isSpeedPanelDismissed = false
		blockListPayload = nil
		uiControl = nil
		keybindButton = nil
		secondaryButton = nil
		speedModeLabel = nil
		updateSpeedBypassVisual = nil
		speedPanelPosition = nil
		defaultPanelPosition = nil
		speedPanelScale = nil
		panelAnimationToken = 0
		speedPanelToggle = nil
		speedToggleScale = nil
		speedToggleImage = nil
		speedToggleStroke = nil
		speedToggleGradient = nil
		setShowMobileButtonsVisual = nil
		setLockMobileButtonsVisual = nil
		_autoBatHadTarget = false
		AUTO_BAT_SPEED = 60
		BYPASS_AUTO_BAT_SPEED = 60
		LAGGER_AUTO_BAT_SPEED = 45
		BYPASS_LAGGER_AUTO_BAT_SPEED = 30
		ANTI_BAT_BYPASS_VERT_SPEED = 52
		ANTI_BAT_BYPASS_DIST = -2.8
		ANTI_BAT_BYPASS_HEIGHT = 4.75
		ANTI_BAT_BYPASS_V_OFF = 1
		ANTI_BAT_BYPASS_TURN_SPEED = 285
		ANTI_BAT_BYPASS_MAX_TURN_RATE = 28

		do
			local primaryValue = 0.25
			ANTI_BAT_BYPASS_MAX_PREDICTION_SPEED = 80
			ANTI_BAT_BYPASS_MAX_LEAD = 0.12
			ANTI_BAT_BYPASS_VELOCITY_SMOOTHING = primaryValue
		end
	end

	do
		_antiBatBypassPredictionData = {}

		do
			local function featureHelperB()
				return AUTO_BAT_SPEED
			end

			getAutoBatMovementSpeed = function()
				local bypass = tostring(autoBatMode) == "AntiBatBypass"
				if laggerToggled and (laggerPhase == 1 or laggerPhase == 2) then
					if bypass then
						return BYPASS_LAGGER_AUTO_BAT_SPEED or 30
					end
					return LAGGER_AUTO_BAT_SPEED
				end
				if bypass then
					return BYPASS_AUTO_BAT_SPEED or 60
				end
				return featureHelperB()
			end
		end
	end

	do
		local function featureHelperB(inputValue, secondaryInput)
			if not inputValue then
				return
			end
			inputValue.Visible = true
			-- 2-button layout only (V1 Vision + V2 AntiBatBypass)
			local isV2 = (tostring(autoBatMode or "Vision") == "AntiBatBypass") or secondaryInput == true
			local pos = isV2 and UDim2.new(0.5, 2, 0, 2) or UDim2.new(0, 1, 0, 2)
			inputValue.Size = UDim2.new(0.5, -4, 1, -4)
			TweenService:Create(
				inputValue,
				TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = pos, Size = UDim2.new(0.5, -4, 1, -4) }
			):Play()
		end

		refreshAutoBatModeControls = function()
			local isActive = autoBatMode == "AntiBatBypass"
			featureHelperB(autoBatModeHighlight, isActive)

			local function featureHelperC(inputValue, visible)
				if not inputValue then
					return
				end

				inputValue.Visible = visible
				inputValue.Size = visible and UDim2.new(1, 0, 0, 40) or UDim2.new(1, 0, 0, 0)
				inputValue.BackgroundTransparency = visible and 0.34 or 1
			end

			featureHelperC(autoBatSpeedRow, autoBatDetailsOpen and not isActive)
			-- Lagger Auto Bat Speed UI permanently removed
			featureHelperC(laggerAutoBatSpeedRow, false)
			featureHelperC(bypassAutoBatSpeedRow, autoBatDetailsOpen and isActive)
			featureHelperC(bypassLaggerAutoBatSpeedRow, false)

			if autoBatDefaultButton then
				autoBatDefaultButton.BackgroundTransparency = 1
				autoBatDefaultButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			end

			if autoBatBypassButton then
				autoBatBypassButton.BackgroundTransparency = 1
				autoBatBypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
end

-- =====================================================================
-- 070Hub
-- =====================================================================
do
	do
		normalizeBatCounterSettings = function()
			-- V2/V3 removed — V1 only
			batCounterVersion = "V1"
			batCounterV2Mode = "Desync Aimbot"
			batCounterV2Enabled = false
			batCounterEnabled = batCounterEnabled or false
		end

		updateBatCounterVersionIndicator = function()
			if batCounterVersionHighlight then
				TweenService:Create(
					batCounterVersionHighlight,
					TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0, 1, 0, 2) }
				):Play()
			end
		end

		refreshQuickActionVisibility = function()
			for _, primaryValue in ipairs(qaFrames) do
				if primaryValue then
					primaryValue.Visible = showMobileButtons
				end
			end
		end

		primaryColor = Color3.fromRGB(uiAccentR or 70, uiAccentG or 150, uiAccentB or 255)
		secondaryColor = Color3.fromRGB(
			math.clamp(math.floor((uiAccentR or 140) * 0.55 + 40), 0, 255),
			math.clamp(math.floor((uiAccentG or 100) * 0.55 + 80), 0, 255),
			math.clamp(math.floor((uiAccentB or 255) * 0.85 + 40), 0, 255)
		)
		tertiaryColor = Color3.fromRGB(
			math.clamp(math.floor((uiAccentR or 140) * 0.7 + 80), 0, 255),
			math.clamp(math.floor((uiAccentG or 100) * 0.7 + 80), 0, 255),
			math.clamp(math.floor((uiAccentB or 255) * 0.7 + 40), 0, 255)
		)

		getgenv()._070ApplyUiAccent = function(r, g, b)
			r = math.clamp(math.floor(tonumber(r) or uiAccentR or 140), 0, 255)
			g = math.clamp(math.floor(tonumber(g) or uiAccentG or 100), 0, 255)
			b = math.clamp(math.floor(tonumber(b) or uiAccentB or 255), 0, 255)
			uiAccentR, uiAccentG, uiAccentB = r, g, b
			primaryColor = Color3.fromRGB(r, g, b)
			secondaryColor = Color3.fromRGB(
				math.clamp(math.floor(r * 0.55 + 40), 0, 255),
				math.clamp(math.floor(g * 0.55 + 80), 0, 255),
				math.clamp(math.floor(b * 0.85 + 40), 0, 255)
			)
			tertiaryColor = Color3.fromRGB(
				math.clamp(math.floor(r * 0.7 + 80), 0, 255),
				math.clamp(math.floor(g * 0.7 + 80), 0, 255),
				math.clamp(math.floor(b * 0.7 + 40), 0, 255)
			)
			getgenv()._070AccentR = r
			getgenv()._070AccentG = g
			getgenv()._070AccentB = b
			getgenv()._070AccentColor = Color3.fromRGB(r, g, b)
			getgenv()._070AccentColor2 = secondaryColor
			getgenv()._070AccentColor3 = tertiaryColor
			_G.__070AnimColor = Color3.fromRGB(r, g, b)
			getgenv().__070AnimColor = Color3.fromRGB(r, g, b)
			pcall(function()
				if _G._070RefreshKatanaColors then
					_G._070RefreshKatanaColors()
				end
			end)
			-- black accent -> black hub + steal bar background
			pcall(function()
				if r <= 50 and g <= 50 and b <= 55 then
					local id = getgenv()._070BlackBgAsset or "123207688823036"
					getgenv()._070CurrentBgAsset = tostring(id)
					if getgenv()._070ApplyUiBackground then
						getgenv()._070ApplyUiBackground(id)
					end
				elseif r == 220 and g == 220 and b == 230 then
					local id = getgenv()._070WhiteBgAsset or "124210976977975"
					getgenv()._070CurrentBgAsset = tostring(id)
					if getgenv()._070ApplyUiBackground then
						getgenv()._070ApplyUiBackground(id)
					end
				elseif r >= 240 and g <= 110 and b >= 160 then
					local id = getgenv()._070PinkBgAsset or "116660005581591"
					getgenv()._070CurrentBgAsset = tostring(id)
					if getgenv()._070ApplyUiBackground then
						getgenv()._070ApplyUiBackground(id)
					end
				elseif g >= 180 and r <= 120 and b <= 140 then
					local id = getgenv()._070GreenBgAsset or "100735382166617"
					getgenv()._070CurrentBgAsset = tostring(id)
					if getgenv()._070ApplyUiBackground then
						getgenv()._070ApplyUiBackground(id)
					end
				end
			end)
			-- sync theme accent if theme system exists
			pcall(function()
				if getgenv()._070ApplyTheme then
					-- many theme packs use string names; try a custom table path
				end
			end)

			local function paintESP()
				-- structured espObjects
				if type(espObjects) == "table" then
					for _, obj in pairs(espObjects) do
						if type(obj) == "table" then
							if obj.box then
								pcall(function()
									for _, d in ipairs(obj.box:GetDescendants()) do
										if d:IsA("UIStroke") then d.Color = primaryColor end
									end
									local st = obj.box:FindFirstChildOfClass("UIStroke")
									if st then st.Color = primaryColor end
								end)
							end
							if obj.tracer then
								pcall(function()
									obj.tracer.BackgroundColor3 = Color3.fromRGB(185, 100, 255)
									if obj.tracer:IsA("Frame") then
										obj.tracer.BorderColor3 = Color3.fromRGB(185, 100, 255)
									end
								end)
							end
							if obj.speedLbl then
								pcall(function() obj.speedLbl.TextColor3 = Color3.fromRGB(185, 100, 255) end)
							end
						end
					end
				end
				-- FPS FIX: no CoreGui:GetDescendants; only paint structured espObjects above
				pcall(function()
					if espGui and espGui.Parent then
						for _, d in ipairs(espGui:GetChildren()) do
							if d:IsA("UIStroke") then d.Color = Color3.fromRGB(185, 100, 255) end
						end
					end
				end)
			end
			pcall(paintESP)

			-- mobile QA / purple controls strokes
			pcall(function()
				if type(qaFrames) == "table" then
					for _, fr in ipairs(qaFrames) do
						if fr then
							for _, d in ipairs(fr:GetDescendants()) do
								if d:IsA("UIStroke") and (d.Name == "070Stroke" or d.Parent == fr) then
									-- leave inactive ones muted; active handled by setPurpleControlActive
								end
							end
							local grad = fr:FindFirstChild("070Gradient")
							if grad and grad:IsA("UIGradient") and createPurpleColorSequence then
								pcall(function() grad.Color = createPurpleColorSequence() end)
							end
						end
					end
				end
			end)

			-- steal bar
			pcall(function()
				if getgenv()._070RefreshStealBarAccent then
					getgenv()._070RefreshStealBarAccent()
				end
			end)

			-- hub title — FPS: skip CoreGui scan
			pcall(function() end)

			-- FPS FIX: was 15× paintESP (each scanned CoreGui); paint once is enough
			task.defer(function()
				task.wait(0.35)
				pcall(paintESP)
			end)

			-- local head speed text
			pcall(function()
				local col = Color3.fromRGB(r, g, b)
				local xmas = false
				local speedCol = xmas and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(185, 100, 255)
				if speedLabel and speedLabel.Parent then
					speedLabel.TextColor3 = speedCol
					local grad = speedLabel:FindFirstChild("070SpeedGrad")
					if grad and grad:IsA("UIGradient") then
						if xmas then
							grad.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 70)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 40, 40)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 180, 70)),
							})
						else
							grad.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 80, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 180, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 100, 255)),
							})
						end
					end
				end
				if ragdollCountdownLabel and ragdollCountdownLabel.Parent then
					ragdollCountdownLabel.TextColor3 = col
				end
				-- all head speed billboards in workspace
				for _, plr in ipairs(Players:GetPlayers()) do
					local head = plr.Character and plr.Character:FindFirstChild("Head")
					if head then
						for _, d in ipairs(head:GetDescendants()) do
							if d:IsA("TextLabel") and (tostring(d.Text):find("Speed") or d.Parent and d.Parent.Name == "070HubOtherSpeed") then
								d.TextColor3 = speedCol
							end
						end
					end
				end
			end)
			print("[070] UI accent =", r, g, b, "(ESP+tracers+bar+head text)")
		end
		getgenv()._070ApplyUiAccent(uiAccentR, uiAccentG, uiAccentB)

		pcall(function()
			if getgenv then
				local genv = getgenv()

				if genv.__070ESPDrawings then
					for _, _070ESPDrawing in ipairs(genv.__070ESPDrawings) do
						pcall(function()
							_070ESPDrawing:Remove()
						end)
					end

					genv.__070ESPDrawings = nil
				end

				genv._070ESPEnabled = false
			end

			local findFirstChild = localPlayer.FindFirstChild

			for _, primaryValue in ipairs({ game:GetService("CoreGui"), findFirstChild(localPlayer, "PlayerGui") }) do
				if primaryValue then
					local adaptESPVisual = primaryValue:FindFirstChild("070ESP_Visual")

					if adaptESPVisual then
						adaptESPVisual:Destroy()
					end
				end
			end
		end)

		do
			local function featureHelperB()
				local colorSequence = ColorSequence.new
				local workingData = {}
				local primaryValue = ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 160, 255))
				local secondaryValue = ColorSequenceKeypoint.new(0.55, primaryColor)
				local new = ColorSequenceKeypoint.new
				local foregroundColor = Color3.fromRGB
				local currentObject = 170
				local currentItem = 86
				local targetObject = 255
				workingData[1] = primaryValue
				workingData[2] = secondaryValue

				do
					local values = table.pack(new(1, foregroundColor(currentObject, currentItem, targetObject)))
					table.move(values, 1, values.n, 3, workingData)
				end

				return colorSequence(workingData)
			end

			createPurpleColorSequence = function()
				local a = primaryColor or Color3.fromRGB(140, 100, 255)
				local b = secondaryColor or Color3.fromRGB(70, 140, 255)
				local c = tertiaryColor or Color3.fromRGB(180, 170, 255)
				return ColorSequence.new({
					ColorSequenceKeypoint.new(0, b),
					ColorSequenceKeypoint.new(0.5, a),
					ColorSequenceKeypoint.new(1, c),
				})
			end

			featureHelperA = function(inputValue, secondaryInput)
				if not inputValue then
					return
				end

				for _, child in ipairs(inputValue:GetChildren()) do
					if
						not (
							child == secondaryInput
							or child:IsA("BillboardGui") and child.Name == "070HubOtherSpeed"
						)
					then
						if
							child:IsA("BillboardGui")
							and (
								child.Name == "070HubHeadTitle" or child.Name == "070HubBrand"
								or child.Name == "070HeadBB"
								or child.Name == "070HeadBB2"
								or child.Name:lower():find("speed")
							)
						then
							pcall(function()
								child:Destroy()
							end)
						elseif child:IsA("BillboardGui") then
							for _, descendant in ipairs(child:GetDescendants()) do
								if descendant:IsA("TextLabel") then
									local primaryValue = string.lower(descendant.Text or "")

									if primaryValue:find("discord%.gg/") or primaryValue:find("speed:") then
										pcall(function()
											child:Destroy()
										end)

										break
									end
-- =====================================================================
-- 070Hub
-- =====================================================================
								end
							end
						end
					end
				end
			end

			applyPurpleGradient = function(parent, rotation, inputValue)
				local _070GradGradient = parent:FindFirstChild("070Gradient") or Instance.new("UIGradient")
				_070GradGradient.Name = "070Gradient"
				_070GradGradient.Color = featureHelperB()
				_070GradGradient.Rotation = rotation or 90
				_070GradGradient.Enabled = inputValue == true
				_070GradGradient.Parent = parent
				return _070GradGradient
			end
		end
	end

	do
		addPurpleGloss = function(parent, zIndex)
			parent.ClipsDescendants = true
			local _070GradGloss = parent:FindFirstChild("070Gloss") or Instance.new("Frame")
			_070GradGloss.Name = "070Gloss"
			_070GradGloss.Size = UDim2.new(1, 0, 0.45, 0)
			_070GradGloss.Position = UDim2.new(0, 0, 0, 0)
			_070GradGloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			_070GradGloss.BackgroundTransparency = 0.72
			_070GradGloss.BorderSizePixel = 0
			_070GradGloss.Visible = false

			if not zIndex then
				zIndex = (parent.ZIndex or 1) + 1
			end

			_070GradGloss.ZIndex = zIndex

			_070GradGloss.Parent = parent;
			(_070GradGloss:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", _070GradGloss)).CornerRadius =
				UDim.new(1, 0)
			local uiGradient = _070GradGloss:FindFirstChild("VisionGlossGradient") or Instance.new("UIGradient")
			uiGradient.Name = "VisionGlossGradient"
			local numberSequence = NumberSequence.new
			local workingData = {}
			local primaryValue = NumberSequenceKeypoint.new(0, 0.35)
			local secondaryValue = NumberSequenceKeypoint.new(0.6, 0.78)
			local new = NumberSequenceKeypoint.new
			local currentObject = 1
			workingData[1] = primaryValue
			workingData[2] = secondaryValue

			do
				local values = table.pack(new(1, currentObject))
				table.move(values, 1, values.n, 3, workingData)
			end

			uiGradient.Transparency = numberSequence(workingData)
			uiGradient.Rotation = 90
			uiGradient.Parent = _070GradGloss
			return _070GradGloss
		end

		setPurpleControlActive = function(inputValue, secondaryInput)
			if not inputValue then
				return
			end
			local primaryValue = inputValue:FindFirstChild("070Gradient")

			if primaryValue then
				primaryValue.Enabled = secondaryInput == true
			end

			local _070GradGloss = inputValue:FindFirstChild("070Gloss")

			if _070GradGloss then
				_070GradGloss.Visible = secondaryInput == true
			end

			local _070GradStroke = inputValue:FindFirstChild("070Stroke")

			if _070GradStroke then
				TweenService:Create(
					_070GradStroke,
					TweenInfo.new(0.16),
					{ Color = primaryColor, Transparency = secondaryInput and 0.18 or 0.72 }
				):Play()
			end
		end

		do
			local function featureHelperB(inputValue)
				if not inputValue or not inputValue:IsA("ScreenGui") then
					return false
				end
				local primaryValue = string.lower(inputValue.Name or "")
				if
					primaryValue:find("070") and primaryValue:find("hub")
					or primaryValue == "070hubmobile"
					or primaryValue == "070hub"
				then
					return true
				end
				return false
			end

			removeExistingVisionGui = function()
				local findFirstChild = localPlayer.FindFirstChild
				local primaryValue = "PlayerGui"

				for _, secondaryValue in ipairs({
					game:GetService("CoreGui"),
					findFirstChild(localPlayer, primaryValue),
				}) do
					if secondaryValue then
						for _, child in ipairs(secondaryValue:GetChildren()) do
							if featureHelperB(child) then
								pcall(function()
									child:Destroy()
								end)
							end
						end
					end
				end
			end
		end
	end

	do
		-- intro removed
		showLoadingIndicator = function() end
		hideLoadingIndicator = function() end
	end
end


	setBatCounterVisual = nil
	startBatCounter = nil
	stopBatCounter = nil
	fieldOfView = 70
	fieldOfViewEnabled = false
	setFovVisual = nil
	fieldOfViewConn = nil
	stretchRezEnabled = false
	stretchRezY = 0.7
	stretchRezConn1 = nil
	stretchRezConn2 = nil
	setStretchRezVisual = nil
	antiLagEnabled = false
	antiLagDescConn = nil
	setAntiLagVisual = nil
	_anyKeyListening = false
	_keyListenBlockUntil = 0
	autoTPEnabled = false
	autoTPHeight = 20
	autoTPConn = nil
	setAutoTPVisual = nil
	startAutoTeleport = nil
	stopAutoTeleport = nil
	counterStateGuard = false
	counterPauseUntil = 0

	pauseCounterChecks = function(inputValue)
		counterPauseUntil = math.max(counterPauseUntil, tick() + (inputValue or 2))
	end

	KB = {
		DropBrainrot = { kb = Enum.KeyCode.X, gp = nil },
		AutoLeft = { kb = Enum.KeyCode.Z, gp = nil },
		AutoRight = { kb = Enum.KeyCode.C, gp = nil },
		AutoBat = { kb = Enum.KeyCode.E, gp = nil },
		BypassAimbot = { kb = Enum.KeyCode.B, gp = Enum.KeyCode.ButtonY },
		DesyncAimbot = { kb = Enum.KeyCode.V, gp = nil },
		TPFloor = { kb = Enum.KeyCode.F, gp = nil },
		GuiHide = { kb = Enum.KeyCode.LeftControl, gp = nil },
		SpeedBypassGui = { kb = nil, gp = nil },
		SpeedBypassToggle = { kb = nil, gp = nil },
		SpeedToggle = { kb = Enum.KeyCode.Q, gp = nil },
		LaggerToggle = { kb = Enum.KeyCode.R, gp = nil },
	}

	_vhKeyButtons = {}

	refreshAllKeyButtons = function()
		if not _vhKeyButtons then
			return
		end

		for k, primaryValue in pairs(_vhKeyButtons) do
			if primaryValue and primaryValue.Parent then
				primaryValue.Text = k.gp and k.gp.Name or k.kb and k.kb.Name or "None"
			end
		end

		if keybindButton then
			keybindButton.Text = KB.SpeedBypassToggle.gp and KB.SpeedBypassToggle.gp.Name
				or KB.SpeedBypassToggle.kb and KB.SpeedBypassToggle.kb.Name
				or "None"
		end
	end

	clearDuplicateKeybind = function(inputValue, secondaryInput, tertiaryInput)
		if not inputValue or inputValue == Enum.KeyCode.Unknown then
			return
		end

		for _, primaryValue in pairs(KB) do
			if primaryValue ~= tertiaryInput then
				if
					not (
						tertiaryInput == KB.GuiHide and primaryValue == KB.SpeedBypassGui
						or tertiaryInput == KB.SpeedBypassGui and primaryValue == KB.GuiHide
					)
				then
					if secondaryInput and primaryValue.gp == inputValue then
						primaryValue.gp = nil
					end

					if not secondaryInput and primaryValue.kb == inputValue then
						primaryValue.kb = nil
					end
				end
			end
		end

		refreshAllKeyButtons()
	end

	isKeybindLocked = function()
		-- true while picking a key OR briefly after (stops bind key from firing features / kick)
		if _anyKeyListening then
			return true
		end
		return tick() < (_keyListenBlockUntil or 0)
	end

-- =====================================================================
-- 070Hub
-- =====================================================================
	do
		local direction = Vector3.new(-476.47, -6.28, 25.58)
		local secondaryDirection = Vector3.new(-483.12, -6.49, 94.81)
		AP_L1 = direction
		AP_L2 = secondaryDirection
	end

do
	local direction = Vector3.new(-476.16, -6.52, 25.62)
	local secondaryDirection = Vector3.new(-483.12, -5.03, 25.48)
	AP_R1 = direction
	AP_R2 = secondaryDirection
end

local featureHelperB, featureHelperC, featureHelperD, featureHelperE

do
	do
		local isActive, featureHelperF, featureHelperG, featureHelperH

		do
			featureHelperB = function()
				if laggerToggled and laggerPhase == 1 then
					return LAGGER_SPEED
				end

				if laggerToggled and laggerPhase == 2 then
					return LAGGER_CARRY_SPEED
				end
				return speedMode and CS or NS
			end

			featureHelperC = function()
				return laggerToggled and LAGGER_SPEED or NS
			end

			featureHelperD = function()
				return laggerToggled and LAGGER_SPEED or NS
			end

			featureHelperE = function(inputValue)
				if not inputValue then
					return true
				end
				local state = inputValue:GetState()
				return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll
			end

			Steal = {
				AutoStealEnabled = false,
				StealRadius = 12,
				StealDuration = 1.3,
				StealDelay = 0.12,
				Data = {},
			}

			Conns = {
				autoSteal = nil,
				batCounter = nil,
				medusaCounter = {},
			}

			MEDUSA_COUNTER_COOLDOWN = 25
			RAGDOLL_COUNTDOWN_SECONDS = 3
			MEDUSA_BLOCK_SECONDS = 6
			progressRadLbl = nil
			progressFill = nil
			progressPct = nil
			progressBarScale = nil
			isActive = false
			stealV1DelayRadius = 14
			stealV2DelayRadius = 15
			stealPercentages = { V1 = 85, V2 = 85 }
			autoStealVersion = "V1"
			stealV1Radius = 14
			stealV2Radius = 15
			selectorHighlight = nil

			updateStealVersionUi = function()
				Steal.StealRadius = autoStealVersion == "V2" and stealV2Radius or stealV1Radius

				if selectorHighlight then
					TweenService
						:Create(
							selectorHighlight,
							TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Position = autoStealVersion == "V2" and UDim2.new(0.5, 4, 0, 2)
									or UDim2.new(0, 1, 0, 2),
							}
						)
						:Play()
				end

				if radInput then
					radInput.Text = tostring(Steal.StealRadius)
				end
			end

			featureHelperF = function()
				if progressPct then
					progressPct.Text = "0%"
				end

				if progressFill then
					progressFill.Size = UDim2.new(0, 0, 1, 0)
					progressFill.BackgroundTransparency = 0.35
				end
			end

			featureHelperG = function(inputValue)
				local amount = math.clamp(tonumber(inputValue) or 0, 0, 1)

				if progressFill then
					progressFill.BackgroundTransparency = 0
					if amount > 0.01 then
						progressFill.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
						local g = progressFill:FindFirstChild("VisionProgressGradient")
						if g then
							g.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 80, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 120, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 60, 255)),
							})
						end
					else
						progressFill.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
					end
					progressFill.Size = UDim2.new(amount, 0, 1, 0)
				end

				if progressPct then
					progressPct.Text = math.floor(amount * 100 + 0.5) .. "%"
					if amount > 0.01 then
						progressPct.TextColor3 = Color3.fromRGB(230, 180, 255)
					else
						progressPct.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				pcall(function()
					local bar = progressFill and progressFill.Parent and progressFill.Parent.Parent
					if bar and bar.Name == "StealBar" then
						local st = bar:FindFirstChildOfClass("UIStroke")
						if st then
							if amount > 0.01 then
								st.Color = Color3.fromRGB(220, 100, 255)
								st.Transparency = 0
								st.Thickness = 2.8
							else
								st.Color = Color3.fromRGB(140, 100, 255)
								st.Transparency = 0.2
								st.Thickness = 1.4
							end
						end
					end
				end)
				-- always drive circle MiroStealBar / VX7 bar
				pcall(function()
					if getgenv()._070SetStealBar then
						getgenv()._070SetStealBar(amount * 100)
					elseif _G.StealBar and _G.StealBar.SetProgress then
						_G.StealBar.SetProgress(amount)
					end
				end)
			end

			updateStealRadiusUi = function()
				if radInput then
					radInput.Text = tostring(Steal.StealRadius)
				end

				if progressRadLbl then
					progressRadLbl.Text = string.format("R: %.1f", Steal.StealRadius)
				end
			end

			do
				local function featureHelperI()
					local character = localPlayer.Character

					if character then
						character = character:FindFirstChild("HumanoidRootPart")
							or character:FindFirstChild("UpperTorso")
							or character:FindFirstChild("Torso")
					end

					return character or nil
				end

				local function featureHelperJ(inputValue)
					inputValue = inputValue and inputValue:FindFirstChild("PlotSign")
					inputValue = inputValue and inputValue:FindFirstChild("YourBase")
-- =====================================================================
-- 070Hub
-- =====================================================================
					return inputValue and inputValue:IsA("BillboardGui") and inputValue.Enabled == true
				end

				featureHelperH = function()
					local primaryValue = featureHelperI()
					local plots = workspace:FindFirstChild("Plots")
					if not primaryValue or not plots then
						return nil, nil, nil
					end
					local huge = math.huge
					local secondaryValue = nil
					local name = nil

					for _, child in ipairs(plots:GetChildren()) do
						if child:IsA("Model") and not featureHelperJ(child) then
							local animalPodiums = child:FindFirstChild("AnimalPodiums")

							if animalPodiums then
								for _, child2 in ipairs(animalPodiums:GetChildren()) do
									local currentObject = child2:FindFirstChild("Base")
									currentObject = currentObject and currentObject:FindFirstChild("Spawn")

									if currentObject then
										local magnitude = (currentObject.Position - primaryValue.Position).Magnitude

										if magnitude <= Steal.StealRadius and magnitude < huge then
											local promptAttachment = currentObject:FindFirstChild("PromptAttachment")
											local currentItem = nil

											if promptAttachment then
												currentItem = nil

												for _, child3 in ipairs(promptAttachment:GetChildren()) do
													if
														child3:IsA("ProximityPrompt")
														and tostring(child3.ActionText):find("Steal")
													then
														currentItem = child3
														break
													else
														currentItem = nil
													end
												end
											end

											if not currentItem then
												for _, descendant in ipairs(currentObject:GetDescendants()) do
													if
														descendant:IsA("ProximityPrompt")
														and tostring(descendant.ActionText):find("Steal")
													then
														currentItem = descendant
														break
													end
												end
											end

											if currentItem then
												name = child2.Name
												huge = magnitude
												secondaryValue = currentItem
											end
										end
									end
								end
							end
						end
					end

					return secondaryValue, huge, name
				end
			end
		end

		do
			local featureHelperI = nil

			featureHelperI = function(inputValue, secondaryInput)
				if isActive or not inputValue then
					return
				end

				if not Steal.Data[inputValue] then
					Steal.Data[inputValue] = { hold = {}, trigger = {}, ready = true }

					pcall(function()
						if getconnections then
							for _, primaryValue in ipairs(getconnections(inputValue.PromptButtonHoldBegan)) do
								if primaryValue.Function then
									table.insert(Steal.Data[inputValue].hold, primaryValue.Function)
								end
							end

							for _, primaryValue in ipairs(getconnections(inputValue.Triggered)) do
								if primaryValue.Function then
									table.insert(Steal.Data[inputValue].trigger, primaryValue.Function)
								end
							end
						end
					end)
				end

				local primaryValue = Steal.Data[inputValue]

				if primaryValue.ready then
					primaryValue.ready = false
					isActive = true
					featureHelperF()

					task.spawn(function()
						for _, secondaryValue in ipairs(primaryValue.hold) do
							task.spawn(secondaryValue)
						end
						-- robust steal: also fire proximity prompt if available
						pcall(function()
							if fireproximityprompt then
								fireproximityprompt(inputValue)
							end
						end)
						pcall(function()
							inputValue.HoldDuration = 0
						end)
						pcall(function()
							if inputValue.InputHoldBegin then inputValue:InputHoldBegin() end
						end)

						local startTime = tick()

						if autoStealVersion == "V2" then
							local amount = 1.35 * (stealPercentages.V2 or 85) / 100

							while
								isActive
								and Steal.AutoStealEnabled
								and autoStealVersion == "V2"
								and tick() - startTime < amount
							do
								local secondaryValue = 1.5
								local currentObject = 0
								featureHelperG(math.clamp((tick() - startTime) / secondaryValue, currentObject, 1))
								task.wait()
							end

							local function featureHelperJ()
								local character = localPlayer.Character

								if character then
									character = character:FindFirstChild("HumanoidRootPart")
										or character:FindFirstChild("UpperTorso")
										or character:FindFirstChild("Torso")
								end

								local parent = inputValue and inputValue.Parent

								if parent then
									parent = parent:IsA("Attachment") and parent.Parent or parent
								end

								return character
										and parent
										and parent:IsA("BasePart")
										and (character.Position - parent.Position).Magnitude
-- =====================================================================
-- 070Hub
-- =====================================================================
									or math.huge
							end

							local isReady = featureHelperJ() <= stealV2DelayRadius
							local rangeCheckResult = nil
							local isComplete

							while true do
								local parent = isActive
									and Steal.AutoStealEnabled
									and autoStealVersion == "V2"
									and inputValue.Parent
								isComplete = false

								if parent then
									local calculatedValue = tick() - startTime

									if not (1.5 < calculatedValue) then
										featureHelperG(math.clamp(calculatedValue / 1.5, 0, 1))

										if featureHelperJ() <= stealV2DelayRadius then
											rangeCheckResult = 1
											break
										else
											task.wait()
											continue
										end
									end
								end

								break
							end

							if rangeCheckResult == 1 then
								if not isReady then
									task.wait(0.3)
								end

								if isActive and Steal.AutoStealEnabled and autoStealVersion == "V2" then
									for _, secondaryValue in ipairs(primaryValue.trigger) do
										task.spawn(secondaryValue)
									end

									pcall(function()
										if fireproximityprompt then fireproximityprompt(inputValue) end
										if inputValue.InputHoldEnd then inputValue:InputHoldEnd() end
										if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
											_G.AutoCarrySpeed.WatchPickup(1.25)
										end
									end)

									isComplete = true
								end
							end

							if isComplete then
								featureHelperG(1)
							end

							task.wait(0.05)
						else
							local amount = math.max(0.05, 1.35 * (stealPercentages[autoStealVersion] or 85) / 100)

							while true do
								if isActive and Steal.AutoStealEnabled then
									local calculatedValue = tick() - startTime

									if not (amount <= calculatedValue) then
										featureHelperG(math.clamp(calculatedValue / Steal.StealDuration, 0, 1))

										if not (not inputValue.Parent or not inputValue.Parent.Parent) then
											local character = localPlayer.Character
											character = character and character:FindFirstChild("HumanoidRootPart")
											if
												not (
													character
													and (character.Position - inputValue.Parent.Parent.Position).Magnitude
														> Steal.StealRadius
												)
											then
												task.wait()
												continue
											end
										end
									end
								end

								break
							end

							local calculatedValue = math.clamp(amount / Steal.StealDuration, 0, 1)
							featureHelperG(calculatedValue)
							local secondaryAmount = math.max(Steal.StealDuration - amount, 0.05)
							local remainingAmount = math.max(3 - amount - secondaryAmount, 0.05)
							local phaseStartTime = tick()
							local stealCompletionReason = nil

							while true do
								if isActive and Steal.AutoStealEnabled then
									if remainingAmount <= tick() - phaseStartTime then
										stealCompletionReason = 2
										break
									elseif not inputValue.Parent or not inputValue.Parent.Parent then
										stealCompletionReason = 3
										break
									else
										local character = localPlayer.Character
										character = character and character:FindFirstChild("HumanoidRootPart")

										if character then
											local magnitude = (character.Position - inputValue.Parent.Parent.Position).Magnitude

											if magnitude <= stealV1DelayRadius then
												stealCompletionReason = 1
												break
											elseif not (Steal.StealRadius < magnitude) then
												task.wait()
												continue
											end
										else
											task.wait()
											continue
										end
									end
								else
									stealCompletionReason = 1
									break
								end

								break
							end

							if stealCompletionReason ~= 1 then
								if stealCompletionReason == 2 then
									featureHelperF()
									primaryValue.ready = true
									isActive = false
									task.wait()
									featureHelperI(inputValue, secondaryInput)
									return
								end

								if stealCompletionReason == 3 then
									featureHelperF()
									primaryValue.ready = true
									isActive = false
									return
								end

								featureHelperF()
								primaryValue.ready = true
								isActive = false
-- =====================================================================
-- 070Hub
-- =====================================================================
								return
							end

							if isActive and Steal.AutoStealEnabled then
								local finalPhaseStartTime = tick()

								while true do
									local progress = math.clamp((tick() - finalPhaseStartTime) / secondaryAmount, 0, 1)
									featureHelperG(calculatedValue + progress * (1 - calculatedValue))
									if not (progress >= 1) then
										task.wait()
										continue
									end
									break
								end

								for _, secondaryValue in ipairs(primaryValue.trigger) do
									task.spawn(secondaryValue)
								end
							end
						end

						featureHelperF()
						primaryValue.ready = true
						isActive = false
					end)

					return
				end
			end

			setAutoStealRadius = function(inputValue)
				local numericValue = tonumber(inputValue)
				if not numericValue then
					return Steal.StealRadius
				end
				Steal.StealRadius = math.clamp(numericValue, 0.5, 200)

				if autoStealVersion == "V2" then
					stealV2Radius = Steal.StealRadius
				else
					stealV1Radius = Steal.StealRadius
				end

				updateStealRadiusUi()
				return Steal.StealRadius
			end

			startAutoSteal = function()
				if Conns.autoSteal then
					return
				end
				Steal.AutoStealEnabled = true
				local nextScan = 0

				Conns.autoSteal = RunService.Heartbeat:Connect(function()
					if not Steal.AutoStealEnabled or isActive then
						return
					end
					local now = os.clock()
					if now < nextScan then
						return
					end
					nextScan = now + 0.06
					local primaryValue, secondaryValue, currentObject = featureHelperH()

					if primaryValue then
						featureHelperI(primaryValue, currentObject)
					end
				end)
			end
		end

		stopAutoSteal = function()
			Steal.AutoStealEnabled = false

			if Conns.autoSteal then
				Conns.autoSteal:Disconnect()
				Conns.autoSteal = nil
			end

			isActive = false
			featureHelperF()
		end
	end

	do
		local _070VelocitySpoofState

		do
			-- FPS: was every Stepped; throttle to ~2.5 Hz
			do
				-- FPS: only disable collision on common body parts, every 1.25s
				local lastCol = 0
				local PART_NAMES = { HumanoidRootPart = true, UpperTorso = true, LowerTorso = true, Torso = true, Head = true }
				RunService.Heartbeat:Connect(function()
					local now = tick()
					if now - lastCol < 1.25 then return end
					lastCol = now
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= localPlayer and player.Character then
							for _, ch in ipairs(player.Character:GetChildren()) do
								if ch:IsA("BasePart") and PART_NAMES[ch.Name] and ch.CanCollide then
									ch.CanCollide = false
								end
							end
						end
					end
				end)
			end

			do
				local genv = getgenv and getgenv() or _G
				_070VelocitySpoofState = genv.__070VelocitySpoofState

				if type(_070VelocitySpoofState) ~= "table" then
					_070VelocitySpoofState = { velocity = Vector3.zero, hooked = false }
					genv.__070VelocitySpoofState = _070VelocitySpoofState
				end
			end
		end

		-- FPS FIX: do NOT install game-wide __index/__newindex hooks (huge FPS cost)
		_070VelocitySpoofState.hooked = true

		do
			local function featureHelperF(inputValue, secondaryInput)
				if not inputValue or not inputValue.Parent then
					return
				end
				local x = secondaryInput.X
				local z = secondaryInput.Z
				if math.sqrt(x * x + z * z) < 0.05 then
					return
				end

				pcall(function()
					local assemblyLinearVelocity = inputValue.AssemblyLinearVelocity
					local unit = Vector3.new(x, 0, z).Unit
					_070VelocitySpoofState.velocity = Vector3.new(unit.X * 16, assemblyLinearVelocity.Y, unit.Z * 16)
					inputValue.AssemblyLinearVelocity = Vector3.new(x, assemblyLinearVelocity.Y, z)
				end)
			end

			local function featureHelperG(inputValue)
				if not inputValue or not inputValue.Parent then
					return
				end

				pcall(function()
					_070VelocitySpoofState.velocity = Vector3.new(0, inputValue.AssemblyLinearVelocity.Y, 0)
				end)
			end

			if _070VelocitySpoofState.speedConnection then
				pcall(function()
					_070VelocitySpoofState.speedConnection:Disconnect()
				end)

				_070VelocitySpoofState.speedConnection = nil
			end

			_070VelocitySpoofState.speedConnection = RunService.PreSimulation:Connect(function()
				local character = localPlayer.Character
				if not character then
					return
				end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local primaryValue = character:FindFirstChild("HumanoidRootPart")
				if not humanoid or not primaryValue then
					return
				end

				if featureHelperE(humanoid) then
					featureHelperG(primaryValue)
					return
				end

				if not autoBatEnabled and not tpBatEnabled and not autoLeftEnabled and not autoRightEnabled then
					local moveDirection = humanoid.MoveDirection
					local secondaryValue

					if antiRagdollEnabled and getAntiRagdollMoveDirection then
						secondaryValue = getAntiRagdollMoveDirection(humanoid)

						if not (secondaryValue.Magnitude > 0.05) then
							secondaryValue = moveDirection
						end
					else
						secondaryValue = moveDirection
					end

					if secondaryValue.Magnitude > 0.05 then
						local unit = Vector3.new(secondaryValue.X, 0, secondaryValue.Z).Unit

						if antiRagdollEnabled and AR2 then
							AR2.LastMoveDirection = unit
						end

						featureHelperF(primaryValue, unit * featureHelperB())
					else
						local isActive = antiRagdollEnabled and AR2 and not featureHelperE(humanoid)

						if isActive then
							isActive = tick() >= (AR2.MovementResumeUntil or 0)
						end

						if isActive then
							AR2.LastMoveDirection = Vector3.zero
						end

						featureHelperG(primaryValue)
					end
				end
			end)
		end
	end
end

do
	do
		local primaryValue = 0
		local secondaryValue = nil

		RunService.RenderStepped:Connect(function()
			local startTime = tick()
			if startTime - primaryValue < 0.2 then
				return
			end
			primaryValue = startTime

			if speedLabel and speedLabel.Parent then
				local character = localPlayer.Character
				local currentObject = character and character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				character = character and character:FindFirstChild("Head")

				if character then
					featureHelperA(character, speedLabel.Parent)
				end

				if currentObject and humanoidRootPart then
					local labelText

					if
						currentObject.MoveDirection.Magnitude > 0
						or Vector3.new(humanoidRootPart.Velocity.X, 0, humanoidRootPart.Velocity.Z).Magnitude > 1
						or autoLeftEnabled
						or autoRightEnabled
					then
						labelText = string.format(
							"Speed: %.1f",
							autoBatEnabled and _autoBatHadTarget and getAutoBatMovementSpeed()
								or (autoLeftEnabled or autoRightEnabled) and featureHelperC()
								or featureHelperB()
						)
					else
						labelText = "Speed: 0.0"
					end
-- =====================================================================
-- 070Hub
-- =====================================================================

					local acc = Color3.fromRGB(
						getgenv()._070AccentR or uiAccentR or 140,
						getgenv()._070AccentG or uiAccentG or 100,
						getgenv()._070AccentB or uiAccentB or 255
					)
					local xmas = false
					local speedCol = xmas and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(185, 100, 255)
					speedLabel.TextColor3 = speedCol
					local grad = speedLabel:FindFirstChild("070SpeedGrad")
					if grad and grad:IsA("UIGradient") then
						if xmas then
							grad.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 70)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 40, 40)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 180, 70)),
							})
						else
							grad.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 80, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 180, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 100, 255)),
							})
						end
					end
					if ragdollCountdownLabel and ragdollCountdownLabel.Parent then
						ragdollCountdownLabel.TextColor3 = acc
					end
					if secondaryValue ~= labelText then
						secondaryValue = labelText
						speedLabel.Text = labelText
					end
				end
			end

			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				character = character and character:FindFirstChild("Head")

				if player ~= localPlayer and character then
					featureHelperA(character)
				end
			end
		end)
	end

	do
		local featureHelperF

		do
			Players.PlayerAdded:Connect(function(player)
				if player == localPlayer then
					return
				end

				player.CharacterAdded:Connect(function(character)
					task.wait(0.3)
					character = character and character:FindFirstChild("Head")

					if character then
						featureHelperA(character)
					end
				end)
			end)

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					player.CharacterAdded:Connect(function(character)
						task.wait(0.3)
						character = character and character:FindFirstChild("Head")

						if character then
							featureHelperA(character)
						end
					end)

					if player.Character then
						task.spawn(function()
							local head = player.Character and player.Character:FindFirstChild("Head")

							if head then
								featureHelperA(head)
							end
						end)
					end
				end
			end

			alConn = nil
			arConn = nil
			alPhase = 1
			arPhase = 1
			autoPathProxy = nil

			do
				local function featureHelperG()
					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
					if not character or not humanoidRootPart then
						return nil
					end

					if not autoPathProxy or autoPathProxy.Parent ~= character then
						if autoPathProxy then
							autoPathProxy:Destroy()
						end

						autoPathProxy = Instance.new("Part")
						autoPathProxy.Name = "VisionAutoPathProxy"
						autoPathProxy.Size = Vector3.new(1, 1, 1)
						autoPathProxy.Transparency = 1
						autoPathProxy.CanCollide = false
						autoPathProxy.Massless = true
						autoPathProxy.Parent = character
						local primaryControl = Instance.new("Weld")
						primaryControl.Part0 = humanoidRootPart
						primaryControl.Part1 = autoPathProxy
						primaryControl.C0 = CFrame.new(0, 0, 0)
						primaryControl.Parent = autoPathProxy
					end

					return autoPathProxy
				end

				stopAutoPathMovement = function()
					if autoPathProxy then
						autoPathProxy.AssemblyLinearVelocity = Vector3.zero
					end

					local character = localPlayer.Character
					character = character and character:FindFirstChildOfClass("Humanoid")

					if character then
						character:Move(Vector3.zero, false)
					end
				end

				featureHelperF = function(assemblyLinearVelocity, inputValue)
					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
					character = character and character:FindFirstChildOfClass("Humanoid")
					local primaryValue = featureHelperG()

					if primaryValue then
						primaryValue.AssemblyLinearVelocity = assemblyLinearVelocity
					elseif humanoidRootPart then
						humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
					end

					if character then
						if inputValue and inputValue.Magnitude > 0.05 then
							character:Move(inputValue, false)
						else
							character:Move(Vector3.zero, false)
						end
					end
				end
			end
		end

		do
			local function featureHelperG(inputValue, secondaryInput, tertiaryInput)
				local character = localPlayer.Character
				if not character then
					return false
				end
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not humanoid then
					return false
				end
				local amount = inputValue - humanoidRootPart.Position
				local direction = Vector3.new(amount.X, 0, amount.Z)

				if direction.Magnitude < 0.05 then
					if tertiaryInput then
						local secondaryDirection = Vector3.zero
-- =====================================================================
-- 070Hub
-- =====================================================================
						featureHelperF(Vector3.new(0, tertiaryInput, 0), secondaryDirection)
						return true
					end

					stopAutoPathMovement()
					return false
				end

				local unit = direction.Unit
				featureHelperF(
					Vector3.new(
						unit.X * secondaryInput,
						tertiaryInput or humanoidRootPart.AssemblyLinearVelocity.Y,
						unit.Z * secondaryInput
					),
					unit
				)
				return true
			end

			stopAutoLeft = function()
				if alConn then
					alConn:Disconnect()
					alConn = nil
				end

				alPhase = 1
				stopAutoPathMovement()

				if autoLeftSetVisual then
					autoLeftSetVisual(false)
				end
			end

			stopAutoRight = function()
				if arConn then
					arConn:Disconnect()
					arConn = nil
				end

				arPhase = 1
				stopAutoPathMovement()

				if autoRightSetVisual then
					autoRightSetVisual(false)
				end
			end

			startAutoLeft = function()
				if alConn then
					alConn:Disconnect()
				end

				alPhase = 1

				alConn = RunService.Heartbeat:Connect(function()
					if not autoLeftEnabled then
						return
					end
					local character = localPlayer.Character
					if not character then
						return
					end
					local primaryValue = character:FindFirstChild("HumanoidRootPart")
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if not primaryValue or not humanoid then
						return
					end

					if featureHelperE(humanoid) then
						stopAutoPathMovement()
						return
					end
					local secondaryValue = featureHelperD()

					if alPhase == 1 then
						local worldPosition = primaryValue.Position

						if (Vector3.new(AP_L1.X, primaryValue.Position.Y, AP_L1.Z) - worldPosition).Magnitude < 1 then
							alPhase = 2
							featureHelperG(AP_L2, secondaryValue)
							return
						end

						featureHelperG(AP_L1, secondaryValue)
					elseif alPhase == 2 then
						local worldPosition = primaryValue.Position

						if (Vector3.new(AP_L2.X, primaryValue.Position.Y, AP_L2.Z) - worldPosition).Magnitude < 1 then
							stopAutoPathMovement()
							autoLeftEnabled = false

							if alConn then
								alConn:Disconnect()
								alConn = nil
							end

							alPhase = 1

							if autoLeftSetVisual then
								autoLeftSetVisual(false)
							end

							return
						end

						featureHelperG(AP_L2, secondaryValue)
					end
				end)
			end

			startAutoRight = function()
				if arConn then
					arConn:Disconnect()
				end

				arPhase = 1

				arConn = RunService.Heartbeat:Connect(function()
					if not autoRightEnabled then
						return
					end
					local character = localPlayer.Character
					if not character then
						return
					end
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if not humanoidRootPart or not humanoid then
						return
					end

					if featureHelperE(humanoid) then
						stopAutoPathMovement()
						return
					end
					local primaryValue = featureHelperD()

					if arPhase == 1 then
						local worldPosition = humanoidRootPart.Position

						if
							(Vector3.new(AP_R1.X, humanoidRootPart.Position.Y, AP_R1.Z) - worldPosition).Magnitude < 1
						then
							arPhase = 2
							featureHelperG(AP_R2, primaryValue)
							return
						end

						featureHelperG(AP_R1, primaryValue)
-- =====================================================================
-- 070Hub
-- =====================================================================
					elseif arPhase == 2 then
						local worldPosition = humanoidRootPart.Position
						local secondaryValue = 1

						if
							(Vector3.new(AP_R2.X, humanoidRootPart.Position.Y, AP_R2.Z) - worldPosition).Magnitude
							< secondaryValue
						then
							stopAutoPathMovement()
							autoRightEnabled = false

							if arConn then
								arConn:Disconnect()
								arConn = nil
							end

							arPhase = 1

							if autoRightSetVisual then
								autoRightSetVisual(false)
							end

							return
						end

						featureHelperG(AP_R2, primaryValue)
					end
				end)
			end
		end
	end
end

do
	createLocalPlayerBillboard = function(inputValue)
		local head = inputValue:WaitForChild("Head", 5)
		if not head then
			return
		end
		featureHelperA(head)
		local primaryControl = Instance.new("BillboardGui", head)
		primaryControl.Name = "070HeadBB2"
		primaryControl.Size = UDim2.new(0, 180, 0, 76)
		primaryControl.StudsOffset = Vector3.new(0, 2.65, 0)
		primaryControl.AlwaysOnTop = true
		primaryControl.ResetOnSpawn = false
		primaryControl.LightInfluence = 0
		ragdollCountdownLabel = Instance.new("TextLabel", primaryControl)
		ragdollCountdownLabel.Name = "RagdollCountdownText"
		ragdollCountdownLabel.Size = UDim2.new(1, 0, 0, 36)
		ragdollCountdownLabel.Position = UDim2.new(0, 0, 0, 0)
		ragdollCountdownLabel.BackgroundTransparency = 1
		ragdollCountdownLabel.Text = ""
		ragdollCountdownLabel.Visible = false
		ragdollCountdownLabel.TextColor3 = primaryColor
		ragdollCountdownLabel.Font = Enum.Font.GothamBlack
		ragdollCountdownLabel.TextSize = 28
		ragdollCountdownLabel.ZIndex = 10
		ragdollCountdownLabel.TextStrokeTransparency = 0
		ragdollCountdownLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		speedLabel = Instance.new("TextLabel", primaryControl)
		speedLabel.Size = UDim2.new(1, 0, 0, 24)
		speedLabel.Position = UDim2.new(0, 0, 0, 47)
		speedLabel.BackgroundTransparency = 1
		speedLabel.Text = "Speed: 0.0"
		speedLabel.Font = Enum.Font.GothamBlack
		speedLabel.TextScaled = false
		speedLabel.TextSize = 18
		speedLabel.TextStrokeTransparency = 0.2
		speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		local xmas0 = false
		local acc0 = xmas0 and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(185, 100, 255)
		speedLabel.TextColor3 = acc0
		do
			local g = Instance.new("UIGradient")
			g.Name = "070SpeedGrad"
			if xmas0 then
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 70)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 40, 40)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 180, 70)),
				})
			else
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 80, 255)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 180, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 100, 255)),
				})
			end
			g.Parent = speedLabel
		end
		ragdollCountdownLabel.TextColor3 = acc0
	end

	ensureLocalPlayerBillboard = function()
		local character = localPlayer.Character
		if not character then
			return
		end

		if
			ragdollCountdownLabel
			and ragdollCountdownLabel.Parent
			and ragdollCountdownLabel:IsDescendantOf(character)
		then
			return
		end
		createLocalPlayerBillboard(character)
	end

	AR2 = {
		Enabled = false,
		Connection = nil,
		ResetCooldown = 0,
		RagdollStart = nil,
		TimerActive = false,
		RagdollActive = false,
		CountersTriggered = false,
		StateConnection = nil,
		TrackedHumanoid = nil,
		LastMoveDirection = Vector3.zero,
		MovementResumeUntil = 0,
		ControlModule = nil,
	}

	local RAGDOLL_DISPLAY_SECONDS = 2.4
	local countdownConnection
	local lastCountdownAt = -math.huge
	local trackedCharacter
	local characterConnections = {}

	AR2.StopCountdown = function()
		if countdownConnection then
			countdownConnection:Disconnect()
			countdownConnection = nil
		end
		if ragdollCountdownLabel and ragdollCountdownLabel.Parent then
			ragdollCountdownLabel.Visible = false
			ragdollCountdownLabel.Text = ""
		end
	end

	AR2.ShowCountdown = function(character, duration)
		if not ragdollCountdownEnabled or not character or localPlayer.Character ~= character then
			return
		end
		if (isCountdownCounterBlocked and isCountdownCounterBlocked())
			or not character:FindFirstChild("Head")
		then
			return
		end
		local startedAt = os.clock()
		if not duration and startedAt - lastCountdownAt < 0.15 then
			return
		end
		lastCountdownAt = startedAt

		AR2.StopCountdown()
		ensureLocalPlayerBillboard()
		local label = ragdollCountdownLabel
		if not label or not label:IsDescendantOf(character) then
			return
		end

		local seconds = duration or RAGDOLL_DISPLAY_SECONDS
		local function updateCountdown()
			if not ragdollCountdownEnabled or localPlayer.Character ~= character or not label.Parent
				or (isCountdownCounterBlocked and isCountdownCounterBlocked())
			then
				AR2.StopCountdown()
				return
			end

			local elapsed = os.clock() - startedAt
			local remaining = seconds - elapsed
			local transparency
			if remaining > 0.05 then
				label.Text = string.format("%.1f", remaining)
				transparency = math.min((elapsed % 0.1) * 9, 0.36)
			elseif remaining > -0.1 then
				label.Text = "0"
				transparency = 0
			else
				local promptAge = -remaining - 0.1
				if promptAge >= 1.24 then
					AR2.StopCountdown()
					return
				end
				label.Text = "STEAL!"
				transparency = math.max(1 - promptAge / 0.12, (promptAge - 1.12) / 0.12, 0)
			end

			label.Visible = true
			label.TextTransparency = transparency
			label.TextStrokeTransparency = transparency
		end

		countdownConnection = RunService.Heartbeat:Connect(updateCountdown)
		updateCountdown()
	end

	local function unbindCountdownCharacter()
		for _, connection in ipairs(characterConnections) do
			connection:Disconnect()
		end
		table.clear(characterConnections)
		trackedCharacter = nil
		lastCountdownAt = -math.huge
		AR2.StopCountdown()
	end

	local function bindCountdownCharacter(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
		if not humanoid or localPlayer.Character ~= character or trackedCharacter == character then
			return
		end
		unbindCountdownCharacter()
		trackedCharacter = character

		local lastHealth = humanoid.Health
		characterConnections[1] = humanoid.HealthChanged:Connect(function(health)
			if health > 0 and health < lastHealth then
				AR2.ShowCountdown(character)
			end
			lastHealth = health
		end)
		characterConnections[2] = humanoid.StateChanged:Connect(function(_, state)
			if humanoid.Health > 0 and (
				state == Enum.HumanoidStateType.Physics
				or state == Enum.HumanoidStateType.Ragdoll
				or state == Enum.HumanoidStateType.FallingDown
			) then
				AR2.ShowCountdown(character)
			end
		end)
		characterConnections[3] = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
			if humanoid.Health > 0 and humanoid.PlatformStand then
				AR2.ShowCountdown(character)
			end
		end)
		characterConnections[4] = humanoid.Died:Connect(AR2.StopCountdown)
	end

	localPlayer.CharacterAdded:Connect(bindCountdownCharacter)
	localPlayer.CharacterRemoving:Connect(function(character)
		if trackedCharacter == character then
			unbindCountdownCharacter()
		end
	end)
	if localPlayer.Character then
		task.defer(bindCountdownCharacter, localPlayer.Character)
	end

	do
		local function featureHelperF()
			if not autoTPEnabled then
				return
			end
			counterStateGuard = true

			if stopAutoTeleport then
				stopAutoTeleport()
			else
				autoTPEnabled = false
			end

			if setAutoTPVisual then
				setAutoTPVisual(false)
			end

			if saveConfig then
				saveConfig()
			end
		end

		local function featureHelperG()
			if not counterStateGuard then
				return
			end

			if isCountdownCounterBlocked and isCountdownCounterBlocked() then
				return
			end
			counterStateGuard = false
			autoTPEnabled = true

			if setAutoTPVisual then
				setAutoTPVisual(true)
			end

			if startAutoTeleport then
-- =====================================================================
-- 070Hub
-- =====================================================================
				startAutoTeleport()
			end

			if saveConfig then
				saveConfig()
			end
		end

		clearRagdollCountdownTimer = function()
			AR2.TimerActive = false
			AR2.RagdollStart = nil
			AR2.TimerDuration = nil
			AR2.ForcedTimer = false
			AR2.RagdollLostAt = nil
			featureHelperG()
		end

		updateAntiRagdollTimer = function(ragdollStart, inputValue)
			if inputValue and AR2.RagdollCountdownDone and not AR2.ForcedTimer then
				return
			end

			if not inputValue then
				AR2.RagdollCountdownDone = false
			end

			if inputValue and not AR2.TimerActive then
				featureHelperF()
				AR2.RagdollStart = ragdollStart
				AR2.TimerActive = true
				AR2.TimerDuration = AR2.TimerDuration or RAGDOLL_COUNTDOWN_SECONDS
				AR2.ForcedTimer = AR2.ForcedTimer == true
				AR2.RagdollLostAt = nil
			elseif inputValue then
				AR2.RagdollLostAt = nil
			elseif not inputValue and not AR2.ForcedTimer and AR2.TimerActive then
				AR2.RagdollLostAt = AR2.RagdollLostAt or ragdollStart
				if not (ragdollStart - AR2.RagdollLostAt < 0.25) then
					clearRagdollCountdownTimer()
					return
				end
				inputValue = true
			elseif not inputValue and not AR2.ForcedTimer then
				clearRagdollCountdownTimer()
				return
			end

			if AR2.TimerActive and AR2.RagdollStart then
				local amount = ragdollStart - AR2.RagdollStart
				local timerDuration = AR2.TimerDuration or RAGDOLL_COUNTDOWN_SECONDS

				if amount >= timerDuration then
					AR2.TimerActive = false
					AR2.RagdollStart = nil
					AR2.TimerDuration = nil
					AR2.ForcedTimer = false
					AR2.RagdollLostAt = nil
					AR2.RagdollCountdownDone = true
					featureHelperG()
				end
			end
		end

		forceRagdollCountdownFor = function(timerDuration)
			if isCountdownCounterBlocked and isCountdownCounterBlocked() then
				clearRagdollCountdownTimer()
				return
			end
			AR2.TimerToken = (AR2.TimerToken or 0) + 1
			local timerToken = AR2.TimerToken
			AR2.RagdollStart = tick()
			AR2.TimerActive = true
			AR2.TimerDuration = timerDuration or RAGDOLL_COUNTDOWN_SECONDS
			AR2.ForcedTimer = true
			AR2.RagdollCountdownDone = false
			updateAntiRagdollTimer(tick(), true)

			task.spawn(function()
				while AR2.TimerActive and AR2.TimerToken == timerToken do
					local primaryValue = true
					updateAntiRagdollTimer(tick(), primaryValue)
					task.wait(0.05)
				end
			end)
		end

		setCountdownSoundActive = function(inputValue)
			countdownSoundActive = inputValue == true

			if countdownSoundActive then
				if autoTPEnabled then
					counterStateGuard = true
				end

				clearRagdollCountdownTimer()
				AR2.StopCountdown()

				if autoBatEnabled and disableAutoBat then
					disableAutoBat()

					if autoBatSetVisual then
						autoBatSetVisual(false)
					end
				end

				if tpBatEnabled and setDesyncAimbotEnabled then
					do end -- desync removed

					if setTPBatVisual then
						setTPBatVisual(false)
					end
				end

				if autoTPEnabled then
					if stopAutoTeleport then
						stopAutoTeleport()
					else
						autoTPEnabled = false
					end

					if setAutoTPVisual then
						setAutoTPVisual(false)
					end
				end
			else
				featureHelperG()
			end
		end
	end
end

do
	monitorCountdownSound = function(inputValue)
		if not inputValue or inputValue.Name ~= "Countdown" or not inputValue:IsA("Sound") then
			return
		end

		if countdownSoundConn then
			countdownSoundConn:Disconnect()
			countdownSoundConn = nil
		end

		setCountdownSoundActive(true)

-- =====================================================================
-- 070Hub
-- =====================================================================
		countdownSoundConn = RunService.Heartbeat:Connect(function()
			if not inputValue.Parent or not inputValue.Playing or inputValue.TimePosition >= 5 then
				setCountdownSoundActive(false)

				if countdownSoundConn then
					countdownSoundConn:Disconnect()
					countdownSoundConn = nil
				end
			end
		end)
	end

	workspace.ChildAdded:Connect(function(child)
		if child.Name == "Countdown" and child:IsA("Sound") then
			monitorCountdownSound(child)
		end
	end)

	do
		local countdown = workspace:FindFirstChild("Countdown")

		if countdown and countdown:IsA("Sound") then
			monitorCountdownSound(countdown)
		end
	end
end

do
	isCountdownCounterBlocked = function()
		return countdownSoundActive == true
	end

	triggerAntiRagdollCounters = function(inputValue)
		if tick() < (counterPauseUntil or 0) then
			return
		end
		local primaryValue = isCountdownCounterBlocked and isCountdownCounterBlocked()
		local secondaryValue = isMedusaCounterBlocked and isMedusaCounterBlocked()
		local humanoid = inputValue and inputValue:FindFirstChildOfClass("Humanoid")
		local isActive = not humanoid or humanoid.Health <= 0

		if not isActive then
			local dead = Enum.HumanoidStateType.Dead
			isActive = humanoid:GetState() == dead
		end

		if isActive then
			pauseCounterChecks(2)
			return
		end

		if primaryValue then
			clearRagdollCountdownTimer()
		elseif ragdollCountdownEnabled and not secondaryValue then
			forceRagdollCountdownFor(RAGDOLL_COUNTDOWN_SECONDS)
		end

		if not batCounterEnabled and not batCounterV2Enabled then
			return
		end

		if batCounterEnabled and findBatForCounter and swingBatForCounter then
			local currentObject = findBatForCounter()

			if currentObject then
				swingBatForCounter(currentObject, inputValue)
			end
		end

		if primaryValue then
			return
		end

		if secondaryValue then
			return
		end

		if batCounterV2Enabled and triggerBatCounterV2 then
			triggerBatCounterV2()
		end
	end

	isAntiRagdollState = function(inputValue)
		return inputValue == Enum.HumanoidStateType.Physics
			or inputValue == Enum.HumanoidStateType.Ragdoll
			or inputValue == Enum.HumanoidStateType.FallingDown
	end

	getAntiRagdollMoveDirection = function(inputValue)
		local currentCamera = workspace.CurrentCamera
		local direction = Vector3.zero
		local isActive = false

		if currentCamera then
			local secondaryDirection =
				Vector3.new(currentCamera.CFrame.LookVector.X, 0, currentCamera.CFrame.LookVector.Z)
			local thirdDirection =
				Vector3.new(currentCamera.CFrame.RightVector.X, 0, currentCamera.CFrame.RightVector.Z)

			if secondaryDirection.Magnitude > 0 then
				secondaryDirection = secondaryDirection.Unit
			end

			if thirdDirection.Magnitude > 0 then
				thirdDirection = thirdDirection.Unit
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
				direction = direction + secondaryDirection
				isActive = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
				direction = direction - secondaryDirection
				isActive = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
				direction = direction + thirdDirection
				isActive = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
				direction = direction - thirdDirection
				isActive = true
			end
		end

		if not isActive and (UserInputService.TouchEnabled or UserInputService.GamepadEnabled) then
			if not AR2.ControlModule then
				local playerModule = localPlayer:FindFirstChild("PlayerScripts")
					and localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
				playerModule = playerModule and playerModule:FindFirstChild("ControlModule")

				if playerModule then
					local ok, controlModule = pcall(require, playerModule)

					if ok then
						AR2.ControlModule = controlModule
					end
				end
			end

			local controlModule = AR2.ControlModule

			if controlModule and controlModule.GetMoveVector and currentCamera then
				local ok, result = pcall(function()
					return controlModule:GetMoveVector()
				end)

-- =====================================================================
-- 070Hub
-- =====================================================================
				if ok and typeof(result) == "Vector3" and result.Magnitude > 0.05 then
					local secondaryDirection =
						Vector3.new(currentCamera.CFrame.LookVector.X, 0, currentCamera.CFrame.LookVector.Z)
					local thirdDirection =
						Vector3.new(currentCamera.CFrame.RightVector.X, 0, currentCamera.CFrame.RightVector.Z)

					if secondaryDirection.Magnitude > 0 then
						secondaryDirection = secondaryDirection.Unit
					end

					if thirdDirection.Magnitude > 0 then
						thirdDirection = thirdDirection.Unit
					end

					direction = thirdDirection * result.X + secondaryDirection * -result.Z
					isActive = direction.Magnitude > 0.05
				end
			end
		end

		if not isActive and inputValue then
			local secondaryDirection = Vector3.new(inputValue.MoveDirection.X, 0, inputValue.MoveDirection.Z)

			if secondaryDirection.Magnitude > 0.05 then
				isActive = true
				direction = secondaryDirection
			end
		end

		if isActive and direction.Magnitude > 0.05 then
			AR2.LastMoveDirection = direction.Unit
		end

		local touchEnabled = not isActive and (UserInputService.TouchEnabled or UserInputService.GamepadEnabled)

		if touchEnabled then
			touchEnabled = tick() < (AR2.MovementResumeUntil or 0)
		end

		if touchEnabled and AR2.LastMoveDirection.Magnitude > 0.05 then
			return AR2.LastMoveDirection
		end
		return isActive and AR2.LastMoveDirection or Vector3.zero
	end

	zeroAntiRagdollVelocity = function(inputValue, secondaryInput)
		local primaryValue = getAntiRagdollMoveDirection(secondaryInput)

		if primaryValue.Magnitude > 0.05 then
			local amount = primaryValue.Unit * featureHelperB()
			inputValue.Velocity = Vector3.new(amount.X, 0, amount.Z)
			inputValue.AssemblyLinearVelocity = Vector3.new(amount.X, 0, amount.Z)
		else
			inputValue.Velocity = Vector3.new()
			inputValue.AssemblyLinearVelocity = Vector3.new()
		end

		inputValue.RotVelocity = Vector3.new()
		inputValue.AssemblyAngularVelocity = Vector3.new()
	end

	handleAntiRagdollStarted = function(inputValue, secondaryInput, tertiaryInput, fourthInput)
		AR2.MovementResumeUntil = (tertiaryInput or tick()) + 1

		if not AR2.RagdollActive then
			AR2.RagdollActive = true
		end

		if fourthInput ~= Enum.HumanoidStateType.FallingDown and not AR2.CountersTriggered then
			AR2.CountersTriggered = true
			triggerAntiRagdollCounters(inputValue, tertiaryInput)
		end

		if secondaryInput then
			zeroAntiRagdollVelocity(secondaryInput, inputValue and inputValue:FindFirstChildOfClass("Humanoid"))
		end
	end

	startAntiRagdoll = function()
		if AR2.Connection then
			return
		end
		AR2.Enabled = true

		AR2.Connection = RunService.Heartbeat:Connect(function()
			if not AR2.Enabled then
				return
			end
			local character = localPlayer.Character
			if not character then
				return
			end
			local primaryValue = character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not primaryValue or not humanoidRootPart or primaryValue.Health <= 0 then
				pauseCounterChecks(2)
				AR2.RagdollActive = false
				AR2.CountersTriggered = false
				return
			end

			if AR2.TrackedHumanoid ~= primaryValue then
				if AR2.StateConnection then
					AR2.StateConnection:Disconnect()
					AR2.StateConnection = nil
				end

				AR2.TrackedHumanoid = primaryValue

				AR2.StateConnection = primaryValue.StateChanged:Connect(function(old, new)
					if not AR2.Enabled then
						return
					end
					local character2 = localPlayer.Character
					local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")
					local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

					if not humanoid or humanoid.Health <= 0 or new == Enum.HumanoidStateType.Dead then
						pauseCounterChecks(2)
						AR2.RagdollActive = false
						AR2.CountersTriggered = false
						return
					end

					if isAntiRagdollState(new) then
						handleAntiRagdollStarted(character2, humanoidRootPart2, tick(), new)
					else
						AR2.RagdollActive = false
						AR2.CountersTriggered = false
					end
				end)
			end

			local state = primaryValue:GetState()
			local startTime = tick()

			if isAntiRagdollState(state) then
				handleAntiRagdollStarted(character, humanoidRootPart, startTime, state)

				if startTime - AR2.ResetCooldown > 0.15 then
					AR2.ResetCooldown = startTime

					pcall(function()
						primaryValue:ChangeState(Enum.HumanoidStateType.GettingUp)
						humanoidRootPart.Anchored = false
						zeroAntiRagdollVelocity(humanoidRootPart, primaryValue)

						for _, descendant in ipairs(character:GetDescendants()) do
							if descendant:IsA("Motor6D") then
-- =====================================================================
-- 070Hub
-- =====================================================================
								descendant.Enabled = true
							end

							if descendant:IsA("Constraint") then
								descendant.Enabled = true
							end
						end

						workspace.CurrentCamera.CameraSubject = primaryValue
						local secondaryValue = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")

						if secondaryValue then
							local module = require(secondaryValue:FindFirstChild("ControlModule"))

							if module then
								module:Enable()
							end
						end

						primaryValue.AutoRotate = true
						primaryValue.PlatformStand = false
						primaryValue.Sit = false
					end)
				end
			else
				AR2.RagdollActive = false
				AR2.CountersTriggered = false
			end
		end)
	end

	stopAntiRagdoll = function()
		AR2.Enabled = false

		if AR2.Connection then
			AR2.Connection:Disconnect()
			AR2.Connection = nil
		end

		if AR2.StateConnection then
			AR2.StateConnection:Disconnect()
			AR2.StateConnection = nil
		end

		AR2.TrackedHumanoid = nil
		AR2.RagdollActive = false
		AR2.CountersTriggered = false
		AR2.LastMoveDirection = Vector3.zero
		AR2.MovementResumeUntil = 0
		AR2.ControlModule = nil
	end

	do
		local clone = nil

		disableWalkAnimation = function()
			local character = localPlayer.Character
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				for _, primaryValue in ipairs(humanoid:GetPlayingAnimationTracks()) do
					pcall(function()
						primaryValue:Stop()
					end)
				end
			end

			local animate = character:FindFirstChild("Animate")

			if animate then
				clone = animate:Clone()
				animate:Destroy()
			end
		end

		restoreWalkAnimation = function()
			unwalkEnabled = false
			local character = localPlayer.Character

			if character and clone then
				clone:Clone().Parent = character
				clone = nil
			end
		end
	end
end

localPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)

	if unwalkEnabled then
		disableWalkAnimation()
	end
end)

clearESPPlayer = function(inputValue)
	local primaryValue = espObjects[inputValue]
	if not primaryValue then
		return
	end

	if primaryValue.box then
		pcall(function()
			primaryValue.box:Destroy()
		end)
	end

	if primaryValue.speedBillboard then
		pcall(function()
			primaryValue.speedBillboard:Destroy()
		end)
	end

	if primaryValue.tracer then
		pcall(function()
			primaryValue.tracer:Destroy()
		end)
	end

	espObjects[inputValue] = nil
end

clearESP = function()
	for k in pairs(espObjects) do
		clearESPPlayer(k)
	end
end

getESPViewportPoint = function(inputValue, secondaryInput)
	local viewportSize = inputValue.ViewportSize
	local secondaryDirection = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	local primaryValue = inputValue:WorldToViewportPoint(secondaryInput)
	local screenPoint = Vector2.new(primaryValue.X, primaryValue.Y)

	if primaryValue.Z < 0 then
		screenPoint = secondaryDirection - screenPoint - secondaryDirection
	end

	local y = screenPoint.Y
	return Vector2.new(math.clamp(screenPoint.X, 4, viewportSize.X - 4), math.clamp(y, 4, viewportSize.Y - 4))
end

ensureESPGui = function()
	if espGui and espGui.Parent then
		return espGui
	end
	espGui = Instance.new("ScreenGui")
-- =====================================================================
-- 070Hub
-- =====================================================================
	espGui.Name = "VisionESP"
	espGui.ResetOnSpawn = false
	espGui.IgnoreGuiInset = true
	espGui.DisplayOrder = 5

	pcall(function()
		espGui.Parent = gethui and gethui() or game:GetService("CoreGui")
	end)

	if not espGui.Parent then
		espGui.Parent = localPlayer:WaitForChild("PlayerGui")
	end

	return espGui
end

ensureESPPlayer = function(inputValue)
	if inputValue == localPlayer then
		return nil
	end
	local character = inputValue.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local head = character and character:FindFirstChild("Head")

	if not character or not humanoidRootPart then
		clearESPPlayer(inputValue)

		return nil
	end

	local workingData = espObjects[inputValue] or {}
	local primaryValue = ensureESPGui()

	if not workingData.box or workingData.box.Parent ~= primaryValue then
		if workingData.box then
			pcall(function()
				workingData.box:Destroy()
			end)
		end

		local primaryControl = Instance.new("Frame", primaryValue)
		primaryControl.Name = "VisionESPBox_" .. inputValue.Name
		primaryControl.BackgroundTransparency = 1
		primaryControl.BorderSizePixel = 0
		primaryControl.Visible = false
		primaryControl.ZIndex = 2
		local gradientControl = Instance.new("UIStroke", primaryControl)
		-- never black: force visible ESP outline
		local espCol = Color3.fromRGB(185, 100, 255)
		if false then
			espCol = Color3.fromRGB(40, 180, 70)
		end
		gradientControl.Color = espCol
		gradientControl.Thickness = 2
		gradientControl.Transparency = 0
		gradientControl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		primaryControl.BackgroundTransparency = 1
		primaryControl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		workingData.box = primaryControl
		workingData.boxStroke = gradientControl
	end

	if head and (not workingData.speedBillboard or workingData.speedBillboard.Parent ~= head) then
		if workingData.speedBillboard then
			pcall(function()
				workingData.speedBillboard:Destroy()
			end)
		end

		local _070HubOtherSpeed = head:FindFirstChild("070HubOtherSpeed")

		if _070HubOtherSpeed then
			pcall(function()
				_070HubOtherSpeed:Destroy()
			end)
		end

		local billboardGui = Instance.new("BillboardGui", head)
		billboardGui.Name = "070HubOtherSpeed"
		billboardGui.Size = UDim2.new(0, 100, 0, 22)
		billboardGui.StudsOffset = Vector3.new(0, 3.1, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.ResetOnSpawn = false
		billboardGui.LightInfluence = 0
		billboardGui.Enabled = espEnabled
		local primaryControl = Instance.new("TextLabel", billboardGui)
		primaryControl.Size = UDim2.new(1, 0, 1, 0)
		primaryControl.BackgroundTransparency = 1
		primaryControl.Text = "Speed: 0.0"
		primaryControl.TextColor3 = Color3.fromRGB(185, 100, 255)
		primaryControl.Font = Enum.Font.GothamBlack
		primaryControl.TextScaled = false
		primaryControl.TextSize = 18
		primaryControl.TextStrokeTransparency = 0
		primaryControl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		workingData.speedBillboard = billboardGui
		workingData.speedLbl = primaryControl
		workingData.speedDisplayed = 0
	end

	if espTracersEnabled and not workingData.tracer then
		local rowContainer = Instance.new("Frame", primaryValue)
		rowContainer.Name = "VisionESPTracer_" .. inputValue.Name
		-- color applied below
		rowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		rowContainer.BackgroundColor3 = (getgenv()._070AccentColor or primaryColor)
		rowContainer.BackgroundTransparency = 0
		rowContainer.BorderSizePixel = 0
		rowContainer.Visible = false
		rowContainer.ZIndex = 1
		workingData.tracer = rowContainer
	elseif not espTracersEnabled and workingData.tracer then
		pcall(function()
			workingData.tracer:Destroy()
		end)

		workingData.tracer = nil
	end

	espObjects[inputValue] = workingData
	return workingData, humanoidRootPart
end

updateESP = function()
	local function espAccent()
		if false then
			return Color3.fromRGB(40, 180, 70)
		end
		return Color3.fromRGB(185, 100, 255)
	end
	local ACC = espAccent()
	getgenv()._070AccentColor = ACC
	_G.__070AnimColor = ACC

	local currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return
	end
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local primaryValue, secondaryValue = ensureESPPlayer(player)

			if primaryValue then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					character = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
				end

				if not secondaryValue or not humanoid or humanoid.Health <= 0 then
					if primaryValue.box then
						primaryValue.box.Visible = false
					end

					if primaryValue.speedBillboard then
						primaryValue.speedBillboard.Enabled = false
					end

					if primaryValue.tracer then
						primaryValue.tracer.Visible = false
					end
				else
					local currentObject =
						currentCamera:WorldToViewportPoint(secondaryValue.Position + Vector3.new(0, 3.2, 0))
					local currentItem =
						currentCamera:WorldToViewportPoint(secondaryValue.Position + Vector3.new(0, -3, 0))

-- =====================================================================
-- 070Hub
-- =====================================================================
					if primaryValue.tracer then
						local targetObject = espTracersEnabled and humanoidRootPart and character
						local visible = false

						if targetObject then
							local uiElement = getESPViewportPoint(currentCamera, humanoidRootPart.Position)
							local stateToken = getESPViewportPoint(currentCamera, character.Position)
							local amount = stateToken - uiElement
							primaryValue.tracer.Position =
								UDim2.fromOffset((uiElement.X + stateToken.X) / 2, (uiElement.Y + stateToken.Y) / 2)
							primaryValue.tracer.Size = UDim2.fromOffset(amount.Magnitude, 1.5)
							primaryValue.tracer.Rotation = math.deg(math.atan2(amount.Y, amount.X))
							primaryValue.tracer.BackgroundColor3 = ACC
							visible = true
						end

						primaryValue.tracer.Visible = visible
					end

					if currentObject.Z > 0 and currentItem.Z > 0 then
						local amount = math.abs(currentItem.Y - currentObject.Y)
						local calculatedValue = amount * 0.55
						local secondaryAmount = (currentObject.X + currentItem.X) / 2
						local remainingAmount = (currentObject.Y + currentItem.Y) / 2

						if primaryValue.box then
							primaryValue.box.Position =
								UDim2.new(0, secondaryAmount - calculatedValue / 2, 0, remainingAmount - amount / 2)
							primaryValue.box.Size = UDim2.new(0, calculatedValue, 0, amount)
							primaryValue.box.Visible = espEnabled
							local boxStroke = primaryValue.box:FindFirstChildOfClass("UIStroke")
							if boxStroke then
								boxStroke.Color = ACC
							end
						end

						if primaryValue.speedLbl then
							local assemblyLinearVelocity = secondaryValue.AssemblyLinearVelocity
							local magnitude =
								Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

							if not (humanoid.MoveDirection.Magnitude > 0 or magnitude > 1) then
								primaryValue.speedDisplayed = 0
							else
								primaryValue.speedDisplayed = math.floor(math.max(magnitude, humanoid.WalkSpeed) + 0.5)
							end

							primaryValue.speedLbl.Text = string.format("Speed: %.1f", primaryValue.speedDisplayed or 0)
							primaryValue.speedLbl.TextColor3 = (false) and Color3.fromRGB(220, 40, 40) or ACC
						end

						if primaryValue.speedBillboard then
							primaryValue.speedBillboard.Enabled = espEnabled
						end
					elseif primaryValue.box then
						primaryValue.box.Visible = false
					end
				end
			end
		end
	end

	for k in pairs(espObjects) do
		if not k.Parent or not espEnabled and not espTracersEnabled then
			clearESPPlayer(k)
		end
	end
end

refreshESP = function()
	if espEnabled or espTracersEnabled then
		if not espConn then
			-- FPS: throttle ESP to ~30 Hz
			local lastEsp = 0
			espConn = RunService.Heartbeat:Connect(function()
				local now = tick()
				if now - lastEsp < 0.033 then return end
				lastEsp = now
				updateESP()
			end)
		end

		updateESP()
	else
		if espConn then
			espConn:Disconnect()
			espConn = nil
		end

		clearESP()
	end
end

clearESP()

-- ========== Refex Infinite Jump (SINGLE / HOLD) — exact port ==========
infJumpMode = "HOLD"
jumpMode = "HOLD"
infJumpPower = 50
infJumpPowerRuntime = 50
JumpState = {
	holdPressed = false,
	holdActive = false,
	controllerActive = false,
	mobilePressed = false,
	mobileActive = false,
	hooked = {},
}
jumpInputState = JumpState

local holdJumpPressed = false
local holdJumpActive = false
local _infJumpLast = 0

local function infJumpIsEnabled()
	return infJumpEnabled == true
end

local function getInfJumpMode()
	local m = tostring(infJumpMode or jumpMode or "HOLD"):upper()
	if m == "TAP" or m == "SINGLE" or m == "MANUAL" then
		return "SINGLE"
	end
	return "HOLD"
end

local function applyInfiniteJumpBoost(boost)
	if not infJumpIsEnabled() then
		return
	end
	local char = localPlayer.Character
	if not char then
		return
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then
		return
	end
	boost = math.clamp(tonumber(boost) or 50, 15, 200)
	local velocity = root.AssemblyLinearVelocity
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, boost, velocity.Z)
	end)
	pcall(function()
		root.Velocity = Vector3.new(velocity.X, boost, velocity.Z)
	end)
	pcall(function()
		hum.Jump = true
	end)
end

local function doInfJumpOnce()
	if not infJumpIsEnabled() then
		return
	end
	if UserInputService:GetFocusedTextBox() then
		return
	end
	local now = os.clock()
	if now - _infJumpLast < 0.08 then
		return
	end
	_infJumpLast = now
	local jumpPower = math.clamp(
		tonumber(infJumpPower) or tonumber(infJumpPowerRuntime) or 50,
		15,
		200
	)
	applyInfiniteJumpBoost(jumpPower)
end

function applyInfJumpBoost(boost)
	applyInfiniteJumpBoost(boost or infJumpPower or 50)
end

stopInfiniteJumpLoop = function()
	holdJumpActive = false
end
startInfiniteJumpLoop = function()
	holdJumpActive = true
end

function startHoldInfJump()
	infJumpEnabled = true
	holdJumpPressed = true
	holdJumpActive = true
end

function stopHoldInfJump()
	holdJumpPressed = false
	holdJumpActive = false
end

pcall(function()
	-- Mobile + keyboard jump attempts
	UserInputService.JumpRequest:Connect(function()
		if not infJumpIsEnabled() then
			return
		end
		if UserInputService:GetFocusedTextBox() then
			return
		end
		-- SINGLE and HOLD both get a boost on JumpRequest;
		-- HOLD continuous boost is handled while key held
		doInfJumpOnce()
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		local isControllerJump = input.KeyCode == Enum.KeyCode.ButtonA
		if (gp and not isControllerJump) or UserInputService:GetFocusedTextBox() then
			return
		end
		if input.KeyCode ~= Enum.KeyCode.Space and not isControllerJump then
			return
		end
		holdJumpPressed = true
		local jumpPower = math.clamp(
			tonumber(infJumpPower) or tonumber(infJumpPowerRuntime) or 50,
			15,
			200
		)
		if getInfJumpMode() == "SINGLE" then
			doInfJumpOnce()
			holdJumpPressed = false
			holdJumpActive = false
			return
		end
		doInfJumpOnce()
		task.delay(0.12, function()
			if holdJumpPressed and infJumpIsEnabled() and getInfJumpMode() == "HOLD" then
				holdJumpActive = true
				applyInfiniteJumpBoost(jumpPower)
			end
		end)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode ~= Enum.KeyCode.Space and input.KeyCode ~= Enum.KeyCode.ButtonA then
			-- mobile: still clear if touch ended while jumping
			if input.UserInputType == Enum.UserInputType.Touch and JumpState.mobilePressed then
				JumpState.mobilePressed = false
				holdJumpPressed = false
				holdJumpActive = false
			end
			return
		end
		holdJumpPressed = false
		holdJumpActive = false
		JumpState.mobilePressed = false
	end)

	-- Mobile / JumpRequest (phone jump button)
	pcall(function()
		UserInputService.JumpRequest:Connect(function()
			if not infJumpIsEnabled() then return end
			if UserInputService:GetFocusedTextBox() then return end
			holdJumpPressed = true
			JumpState.mobilePressed = true
			local jumpPower = math.clamp(
				tonumber(infJumpPower) or tonumber(infJumpPowerRuntime) or 50,
				15,
				200
			)
			if getInfJumpMode() == "SINGLE" then
				doInfJumpOnce()
				holdJumpPressed = false
				holdJumpActive = false
				JumpState.mobilePressed = false
				return
			end
			doInfJumpOnce()
			task.delay(0.1, function()
				if (holdJumpPressed or JumpState.mobilePressed) and infJumpIsEnabled() then
					holdJumpActive = true
					applyInfiniteJumpBoost(jumpPower)
				end
			end)
		end)
	end)

	-- Keep boost while mobile jump held (Humanoid.Jump true)
	task.spawn(function()
		local function hookHum(hum)
			if not hum or JumpState.hooked[hum] then return end
			JumpState.hooked[hum] = true
			hum:GetPropertyChangedSignal("Jump"):Connect(function()
				if not infJumpIsEnabled() then return end
				if hum.Jump then
					holdJumpPressed = true
					JumpState.mobilePressed = true
					doInfJumpOnce()
					holdJumpActive = true
				else
					holdJumpPressed = false
					holdJumpActive = false
					JumpState.mobilePressed = false
				end
			end)
		end
		local function onChar(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hookHum(hum) end
			if char then
				char.ChildAdded:Connect(function(c)
					if c:IsA("Humanoid") then hookHum(c) end
				end)
			end
		end
		if localPlayer.Character then onChar(localPlayer.Character) end
		localPlayer.CharacterAdded:Connect(onChar)
	end)

	RunService.Heartbeat:Connect(function()
		if not infJumpIsEnabled() then
			holdJumpActive = false
			return
		end
		if not holdJumpPressed and not JumpState.mobilePressed then
			return
		end
		if holdJumpActive and getInfJumpMode() == "HOLD" then
			applyInfiniteJumpBoost(
				math.clamp(tonumber(infJumpPower) or tonumber(infJumpPowerRuntime) or 50, 15, 200)
			)
		end
	end)

	-- Keep runtime flag aligned after character loads
	localPlayer.CharacterAdded:Connect(function()
		task.defer(function()
			-- preserve enabled state across respawn
			if infJumpEnabled then
				infJumpEnabled = true
			end
		end)
	end)
end)
-- ========== end Refex Infinite Jump ==========

local featureHelperA, featureHelperB, featureHelperC, featureHelperD, featureHelperE, featureHelperF, featureHelperG, featureHelperH, featureHelperI, featureHelperJ
local featureHelperK, featureHelperL, featureHelperM, counterStateGuard, featureHelperN, featureHelperO

do
	do
		local activeConnection, featureHelperP, featureHelperQ, featureHelperR

		do
			do
				featureHelperA = function(inputValue)
					infJumpEnabled = inputValue == true
					if not infJumpMode or infJumpMode == "manual" or infJumpMode == "Manual" then
						infJumpMode = "HOLD"
					end
					jumpMode = infJumpMode
				end
			end

			DROP_ASCEND_DURATION = 0.18
			DROP_ASCEND_SPEED = 150

			do
				local isActive = false
				activeConnection = nil
				featureHelperP = nil

				featureHelperQ = function()
					if autoTPEnabled then
						isActive = true

						if stopAutoTeleport then
							stopAutoTeleport()
						else
							autoTPEnabled = false

							if autoTPConn then
								if autoTPConn.Disconnect then
									autoTPConn:Disconnect()
								else
									task.cancel(autoTPConn)
								end

								autoTPConn = nil
							end
						end

						if setAutoTPVisual then
							setAutoTPVisual(false)
						end
					else
						isActive = false
					end
				end

				featureHelperR = function()
					dropActive = false

					if activeConnection then
						activeConnection:Disconnect()
						activeConnection = nil
					end

					if isActive then
						isActive = false
						autoTPEnabled = true

						if setAutoTPVisual then
							setAutoTPVisual(true)
						end

						if startAutoTeleport then
							startAutoTeleport()
						end
					end
				end
			end
-- =====================================================================
-- 070Hub
-- =====================================================================
		end

		do
			do
				local function featureHelperS()
					if dropActive then
						return
					end
					dropActive = true
					featureHelperQ()

					if autoBatEnabled then
						disableAutoBat()

						if autoBatSetVisual then
							autoBatSetVisual(false)
						end
					end

					local character = localPlayer.Character
					if not character then
						featureHelperR()
						return
					end

					if not character:FindFirstChild("HumanoidRootPart") then
						featureHelperR()
						return
					end
					local startTime = tick()

					activeConnection = RunService.Heartbeat:Connect(function()
						if not dropActive then
							featureHelperR()
							return
						end
						local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
						if not humanoidRootPart then
							featureHelperR()
							return
						end

						if DROP_ASCEND_DURATION <= tick() - startTime then
							if activeConnection then
								activeConnection:Disconnect()
								activeConnection = nil
							end

							local humanoid = character:FindFirstChildOfClass("Humanoid")
							local primaryValue = humanoid
								and featureHelperP
								and featureHelperP(character, humanoidRootPart, humanoid)

							if primaryValue then
								humanoidRootPart.CFrame =
									CFrame.new(humanoidRootPart.Position.X, primaryValue, humanoidRootPart.Position.Z)
								humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							end

							featureHelperR()
							return
						end

						local velocity = humanoidRootPart.Velocity
						humanoidRootPart.Velocity = Vector3.new(velocity.X, DROP_ASCEND_SPEED, velocity.Z)
					end)
				end

				featureHelperB = function()
					if isCountdownCounterBlocked and isCountdownCounterBlocked() then
						return
					end

					if dropActive or tpBatEnabled then
						return
					end
					featureHelperS()
				end
			end
		end

		featureHelperP = function(inputValue, secondaryInput, tertiaryInput)
			local worldPosition = secondaryInput.Position
			if worldPosition.Y <= -7 then
				return -7
			end
			local amount = (tertiaryInput.HipHeight or 2) + secondaryInput.Size.Y * 0.5 + 0.2
			local workingData = { "invis", "wall", "trigger", "barrier", "clip", "ghost" }

			local function featureHelperS(fourthInput)
				while fourthInput and fourthInput ~= workspace do
					local primaryValue = string.lower(fourthInput.Name or "")

					for _, secondaryValue in ipairs(workingData) do
						if primaryValue:find(secondaryValue, 1, true) then
							return fourthInput, true
						end
					end

					fourthInput = fourthInput.Parent
				end

				return nil, false
			end

			local function featureHelperT(fourthInput)
				if fourthInput == workspace.Terrain then
					return false
				end

				if not fourthInput or not fourthInput:IsA("BasePart") then
					return true
				end

				if not fourthInput.CanCollide then
					return true
				end
				local isActive = (fourthInput.Transparency or 0) >= 0.75

				if not isActive then
					isActive = (fourthInput.LocalTransparencyModifier or 0) >= 0.75
				end

				if isActive then
					return true
				end
				local primaryValue, secondaryValue = featureHelperS(fourthInput)
				return secondaryValue
			end

			local function featureHelperU(fourthInput)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true
				local filterDescendantsInstances = { inputValue }

				for i = 1, 80 do
					raycastParams.FilterDescendantsInstances = filterDescendantsInstances
					local hit = workspace:Raycast(fourthInput, Vector3.new(0, -7 - fourthInput.Y, 0), raycastParams)
					if not hit then
						return nil
					end
					local primaryControl = hit.Instance

					if featureHelperT(primaryControl) then
						local primaryValue, secondaryValue = featureHelperS(primaryControl)
						table.insert(filterDescendantsInstances, secondaryValue and primaryValue or primaryControl)
						continue
					end

-- =====================================================================
-- 070Hub
-- =====================================================================
					return hit.Position.Y
				end

				return nil
			end

			local calculatedValue =
				math.max(0.75, math.min(2, math.max(secondaryInput.Size.X, secondaryInput.Size.Z) * 0.55))
			local animationProperties = {}
			local direction = Vector3.zero
			local secondaryDirection = Vector3.new(calculatedValue, 0, 0)
			local thirdDirection = Vector3.new(-calculatedValue, 0, 0)
			local fourthDirection = Vector3.new(0, 0, calculatedValue)
			local fifthDirection = Vector3.new(0, 0, -calculatedValue)
			local sixthDirection = Vector3.new(calculatedValue * 0.7, 0, calculatedValue * 0.7)
			local seventhDirection = Vector3.new(-calculatedValue * 0.7, 0, calculatedValue * 0.7)
			local eighthDirection = Vector3.new
			local ninthDirection = Vector3.new(calculatedValue * 0.7, 0, -calculatedValue * 0.7)
			animationProperties[1] = direction
			animationProperties[2] = secondaryDirection
			animationProperties[3] = thirdDirection
			animationProperties[4] = fourthDirection
			animationProperties[5] = fifthDirection
			animationProperties[6] = sixthDirection
			animationProperties[7] = seventhDirection
			animationProperties[8] = ninthDirection

			do
				local values = table.pack(eighthDirection(-calculatedValue * 0.7, 0, -calculatedValue * 0.7))
				table.move(values, 1, values.n, 9, animationProperties)
			end

			local primaryValue = featureHelperU(worldPosition + Vector3.new(0, 0.25, 0))

			if not primaryValue then
				for i = 2, #animationProperties do
					local secondaryValue =
						featureHelperU(worldPosition + animationProperties[i] + Vector3.new(0, 0.25, 0))

					if secondaryValue and (not primaryValue or secondaryValue > primaryValue) then
						primaryValue = secondaryValue
					end
				end
			end

			if primaryValue then
				local secondaryAmount = primaryValue + amount
				if worldPosition.Y - 0.35 <= secondaryAmount then
					return nil
				end
				return math.max(secondaryAmount, -7)
			end

			return -7
		end

		do
			local function featureHelperS(inputValue)
				local character = localPlayer.Character
				if not character then
					return
				end
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local primaryValue = character:FindFirstChildOfClass("Humanoid")
				if not primaryValue then
					return
				end

				if not inputValue then
					if primaryValue.FloorMaterial ~= Enum.Material.Air then
						return
					end

					if humanoidRootPart.Position.Y < autoTPHeight then
						return
					end
				end

				local secondaryValue = featureHelperP(character, humanoidRootPart, primaryValue)
				if not secondaryValue then
					return
				end
				local cframe = CFrame.Angles
				local cFrame = humanoidRootPart.CFrame
				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position.X,
					secondaryValue,
					humanoidRootPart.Position.Z
				) * cframe(0, select(2, cFrame:ToEulerAnglesYXZ()), 0)
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
			end

			startAutoTeleport = function()
				if isCountdownCounterBlocked and isCountdownCounterBlocked() then
					autoTPEnabled = false

					if setAutoTPVisual then
						setAutoTPVisual(false)
					end

					return false
				end

				if autoTPConn then
					autoTPConn:Disconnect()
					autoTPConn = nil
				end

				autoTPConn = RunService.Heartbeat:Connect(function()
					if not autoTPEnabled then
						return
					end
					local character = localPlayer.Character
					if not character then
						return
					end
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					if not humanoidRootPart then
						return
					end
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					local isActive = humanoid and featureHelperP(character, humanoidRootPart, humanoid)
					isActive = isActive and humanoidRootPart.Position.Y - isActive > autoTPHeight

					if
						not isActive
						and humanoid
						and humanoid.FloorMaterial == Enum.Material.Air
						and humanoidRootPart.Position.Y >= autoTPHeight
					then
						isActive = true
					end

					if isActive then
						pcall(function()
							featureHelperS(true)
						end)
					end
				end)
			end

			stopAutoTeleport = function()
				autoTPEnabled = false

				if autoTPConn then
					autoTPConn:Disconnect()
					autoTPConn = nil
-- =====================================================================
-- 070Hub
-- =====================================================================
				end
			end

			featureHelperC = function()
				if isCountdownCounterBlocked and isCountdownCounterBlocked() then
					return
				end

				pcall(function()
					featureHelperS(true)
				end)
			end
		end
	end

	do
		applyFieldOfView = function()
			local currentCamera = workspace.CurrentCamera

			if currentCamera and fieldOfViewEnabled and currentCamera.FieldOfView ~= fieldOfView then
				pcall(function()
					currentCamera.FieldOfView = fieldOfView
				end)
			end
		end

		resetFieldOfView = function()
			local currentCamera = workspace.CurrentCamera

			if currentCamera and currentCamera.FieldOfView ~= 70 then
				pcall(function()
					currentCamera.FieldOfView = 70
				end)
			end
		end

		featureHelperD = function()
			fieldOfViewEnabled = true

			if fieldOfViewConn then
				fieldOfViewConn:Disconnect()
			end

			fieldOfViewConn = RunService.RenderStepped:Connect(function()
				if not fieldOfViewEnabled then
					return
				end
				local currentCamera = workspace.CurrentCamera

				if currentCamera and currentCamera.FieldOfView ~= fieldOfView then
					pcall(function()
						currentCamera.FieldOfView = fieldOfView
					end)
				end
			end)
		end

		featureHelperE = function()
			fieldOfViewEnabled = false

			if fieldOfViewConn then
				fieldOfViewConn:Disconnect()
				fieldOfViewConn = nil
			end

			resetFieldOfView()
		end

		featureHelperF = function()
			if stretchRezEnabled then
				return
			end

			if fieldOfViewEnabled then
				featureHelperE()

				if setFovVisual then
					setFovVisual(false)
				end
			end

			stretchRezEnabled = true
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				pcall(function()
					currentCamera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
					currentCamera.FieldOfView = fieldOfView
				end)
			end

			if stretchRezConn1 then
				stretchRezConn1:Disconnect()
				stretchRezConn1 = nil
			end

			if stretchRezConn2 then
				stretchRezConn2:Disconnect()
				stretchRezConn2 = nil
			end

			stretchRezConn1 = RunService.RenderStepped:Connect(function()
				if not stretchRezEnabled then
					return
				end
				local currentCamera2 = workspace.CurrentCamera

				if currentCamera2 and currentCamera2.FieldOfView ~= fieldOfView then
					pcall(function()
						currentCamera2.FieldOfView = fieldOfView
					end)
				end
			end)

			stretchRezConn2 = RunService.RenderStepped:Connect(function()
				if not stretchRezEnabled then
					return
				end
				local currentCamera2 = workspace.CurrentCamera

				if currentCamera2 then
					currentCamera2.CFrame = currentCamera2.CFrame
						* CFrame.new(0, 0, 0, 1, 0, 0, 0, stretchRezY, 0, 0, 0, 1)
				end
			end)
		end

		featureHelperG = function()
			stretchRezEnabled = false

			if stretchRezConn1 then
				stretchRezConn1:Disconnect()
				stretchRezConn1 = nil
			end

			if stretchRezConn2 then
				stretchRezConn2:Disconnect()
				stretchRezConn2 = nil
			end

			pcall(function()
				workspace.CurrentCamera.FieldOfView = 70
			end)

			return
		end

		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if stretchRezEnabled then
				stretchRezEnabled = false
-- =====================================================================
-- 070Hub
-- =====================================================================
				task.wait(0.1)
				featureHelperF()
			end

			if fieldOfViewEnabled then
				featureHelperD()
			end
		end)

		do
			local function featureHelperP(inputValue)
				pcall(function()
					local primaryValue = setfflag or set_fflag
					if not primaryValue then
						return
					end
					primaryValue(
						UserInputService.TouchEnabled and "DebugSkyGray" or "DebugSkyGray",
						inputValue and "True" or "False"
					)
				end)
			end

			local function featureHelperQ()
				pcall(function()
					local _070InstantGraySky = Lighting:FindFirstChild("VisionInstantGraySky")

					if not _070InstantGraySky then
						_070InstantGraySky = Instance.new("Atmosphere")
						_070InstantGraySky.Name = "VisionInstantGraySky"
						_070InstantGraySky.Parent = Lighting
					end

					_070InstantGraySky.Density = 0.45
					_070InstantGraySky.Offset = 0.15
					_070InstantGraySky.Color = Color3.fromRGB(145, 145, 145)
					_070InstantGraySky.Decay = Color3.fromRGB(95, 95, 95)
					_070InstantGraySky.Glare = 0
					_070InstantGraySky.Haze = 2
					Lighting.FogColor = Color3.fromRGB(95, 95, 128)
				end)
			end

			local function featureHelperR()
				featureHelperP(false)

				pcall(function()
					local _070InstantGraySky = Lighting:FindFirstChild("VisionInstantGraySky")

					if _070InstantGraySky then
						_070InstantGraySky:Destroy()
					end
				end)
			end

			local function featureHelperS(inputValue)
				pcall(function()
					if inputValue:IsA("BasePart") then
						inputValue.Material = Enum.Material.Plastic
						inputValue.Reflectance = 0
					elseif inputValue:IsA("Decal") or inputValue:IsA("Texture") then
						inputValue.Transparency = 1
					end
				end)
			end

			local function featureHelperT()
				featureHelperP(true)

				pcall(function()
					Lighting.GlobalShadows = false
					Lighting.FogEnd = 100000
					Lighting.Brightness = 1
					Lighting.EnvironmentDiffuseScale = 0
					Lighting.EnvironmentSpecularScale = 0

					for _, child in pairs(Lighting:GetChildren()) do
						if
							child:IsA("BloomEffect")
							or child:IsA("SunRaysEffect")
							or child:IsA("ColorCorrectionEffect")
							or child:IsA("BlurEffect")
							or child:IsA("DepthOfFieldEffect")
						then
							child.Enabled = false
						end
					end
				end)

				featureHelperQ()
			end

			enableAntiLag = function()
				if antiLagEnabled then
					return
				end
				antiLagEnabled = true
				featureHelperT()
				-- FPS FIX: batch workspace scan over frames instead of freezing 1–3s
				task.spawn(function()
					local list = workspace:GetDescendants()
					local i = 1
					while antiLagEnabled and i <= #list do
						local stop = math.min(i + 80, #list)
						for j = i, stop do
							pcall(featureHelperS, list[j])
						end
						i = stop + 1
						task.wait()
					end
				end)

				if antiLagDescConn then
					antiLagDescConn:Disconnect()
				end

				antiLagDescConn = workspace.DescendantAdded:Connect(function(descendant)
					if not antiLagEnabled then
						return
					end
					featureHelperS(descendant)
				end)
			end

			disableAntiLag = function()
				antiLagEnabled = false

				if antiLagDescConn then
					antiLagDescConn:Disconnect()
					antiLagDescConn = nil
				end

				featureHelperR()
			end
		end
	end

	do
		do
			findMedusaCounterTool = function()
				-- VX7-style medusa tool finder
				local character = localPlayer.Character
				if not character then
					return nil
				end
				for _, child in ipairs(character:GetChildren()) do
					if child:IsA("Tool") then
						local n = child.Name:lower()
						if n:find("medusa") or n:find("head") or n:find("stone") then
							return child
						end
					end
				end
				local backpack = localPlayer:FindFirstChild("Backpack")
				if backpack then
					for _, child in ipairs(backpack:GetChildren()) do
						if child:IsA("Tool") then
							local n = child.Name:lower()
							if n:find("medusa") or n:find("head") or n:find("stone") or n:find("petrif") then
								return child
							end
						end
					end
				end
				return nil
			end

			useMedusaCounter = function()
				-- VX7 useMedusa logic (cooldown 25s, equip + Activate)
				if medusaCounterDebounce then
					return
				end
				if os.clock() - (medusaCounterLastUsed or 0) < (MEDUSA_COUNTER_COOLDOWN or 25) then
					return
				end
				local character = localPlayer.Character
				if not character then
					return
				end
				medusaCounterDebounce = true
				local tool = findMedusaCounterTool()
				if not tool then
					medusaCounterDebounce = false
					return
				end
				if tool.Parent ~= character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						pcall(function() humanoid:EquipTool(tool) end)
					end
				end
				pcall(function()
					tool:Activate()
				end)
				medusaCounterLastUsed = os.clock()
				medusaCounterDebounce = false
			end

			handleMedusaDetected = function()
				medusaCounterBlocked = true
				medusaCounterBlockToken = medusaCounterBlockToken + 1
				local primaryValue = medusaCounterBlockToken

				if ragdollCountdownEnabled then
					forceRagdollCountdownFor(MEDUSA_BLOCK_SECONDS)
					AR2.ShowCountdown(localPlayer.Character, MEDUSA_BLOCK_SECONDS)
				end

				task.delay(MEDUSA_BLOCK_SECONDS, function()
					if primaryValue == medusaCounterBlockToken then
						medusaCounterBlocked = false
					end
				end)

				if medusaCounterEnabled then
					useMedusaCounter()
				end
			end

			needsMedusaDetector = function()
				return medusaCounterEnabled or batCounterEnabled or batCounterV2Enabled or ragdollCountdownEnabled
			end

			isMedusaCounterBlocked = function()
				return medusaCounterBlocked == true
			end

			checkMedusaCounterPart = function(inputValue)
				if
					needsMedusaDetector()
					and inputValue
					and inputValue:IsA("BasePart")
					and inputValue.Anchored
					and inputValue.Transparency >= 0.95
				then
					handleMedusaDetected()
				end
			end

			watchMedusaCounterPart = function(inputValue)
				local activeConnection = inputValue:GetPropertyChangedSignal("Anchored"):Connect(function()
					checkMedusaCounterPart(inputValue)
				end)

				local propertyConnection = inputValue:GetPropertyChangedSignal("Transparency"):Connect(function()
					checkMedusaCounterPart(inputValue)
				end)

				return {
					Disconnect = function()
						pcall(function()
							activeConnection:Disconnect()
						end)

						pcall(function()
							propertyConnection:Disconnect()
						end)
					end,
				}
			end

			setupMedusaCounter = function(inputValue)
				for _, primaryValue in pairs(Conns.medusaCounter) do
					pcall(function()
						primaryValue:Disconnect()
					end)
				end

				Conns.medusaCounter = {}

				if not inputValue then
					return
				end

				for _, descendant in ipairs(inputValue:GetDescendants()) do
					if descendant:IsA("BasePart") then
						table.insert(Conns.medusaCounter, watchMedusaCounterPart(descendant))
						checkMedusaCounterPart(descendant)
					end
				end

				table.insert(
					Conns.medusaCounter,
					inputValue.DescendantAdded:Connect(function(descendant)
						if descendant:IsA("BasePart") then
							table.insert(Conns.medusaCounter, watchMedusaCounterPart(descendant))
							checkMedusaCounterPart(descendant)
						end

						return
					end)
				)
-- =====================================================================
-- 070Hub
-- =====================================================================

				return
			end

			stopMedusaCounter = function()
				if needsMedusaDetector() then
					return
				end

				for _, primaryValue in pairs(Conns.medusaCounter) do
					pcall(function()
						primaryValue:Disconnect()
					end)
				end

				Conns.medusaCounter = {}
				medusaCounterDebounce = false
			end

			BAT_COUNTER_SLAP_LIST = {
				"Bat",
				"Slap",
				"Iron Slap",
				"Gold Slap",
				"Diamond Slap",
				"Emerald Slap",
				"Ruby Slap",
				"Dark Matter Slap",
				"Flame Slap",
				"Nuclear Slap",
				"Galaxy Slap",
				"Glitched Slap",
			}

			findBatForCounter = function()
				local character = localPlayer.Character

				if character then
					local primaryValue = localPlayer:FindFirstChildOfClass("Backpack")

					for _, secondaryValue in ipairs(BAT_COUNTER_SLAP_LIST) do
						local currentObject = character:FindFirstChild(secondaryValue)
							or primaryValue and primaryValue:FindFirstChild(secondaryValue)
						if currentObject then
							return currentObject
						end
					end

					for _, child in ipairs(character:GetChildren()) do
						if child:IsA("Tool") and child.Name:lower():find("bat") then
							return child
						end
					end

					if primaryValue then
						for _, child in ipairs(primaryValue:GetChildren()) do
							if child:IsA("Tool") and child.Name:lower():find("bat") then
								return child
							end
						end
					end

					return nil
				end
			end

			getEquippedAutoBatTool = function(inputValue)
				if not inputValue then
					return nil
				end

				for _, child in ipairs(inputValue:GetChildren()) do
					local normalizedName = child.Name:lower()
					if child:IsA("Tool") and normalizedName:find("bat") then
						return child
					end
				end

				return nil
			end

			featureHelperH = function()
				local character = localPlayer.Character
				if not character then
					return nil
				end
				local bat = character:FindFirstChild("Bat")
				if bat and bat:IsA("Tool") then
					return bat
				end
				local backpack = localPlayer:FindFirstChild("Backpack")

				if backpack then
					local bat2 = backpack:FindFirstChild("Bat")

					if bat2 and bat2:IsA("Tool") then
						pcall(function()
							bat2.Parent = character
						end)

						return bat2
					end
				end

				return nil
			end

			do
				local function featureHelperP()
					for _, primaryValue in ipairs(healthConnections) do
						pcall(function()
							primaryValue:Disconnect()
						end)
					end

					healthConnections = {}

					if healthLoopConnection then
						healthLoopConnection:Disconnect()
						healthLoopConnection = nil
					end
				end

				local function featureHelperQ(inputValue)
					featureHelperP()
					local humanoid

					if inputValue then
						humanoid = inputValue:FindFirstChildOfClass("Humanoid")
							or inputValue:WaitForChild("Humanoid", 5)
					else
						humanoid = inputValue
					end

					if not humanoid or not isHealthLockEnabled then
						return
					end

					pcall(function()
						humanoid.MaxHealth = math.huge
						humanoid.Health = math.huge
						humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					end)

					table.insert(
						healthConnections,
						humanoid.StateChanged:Connect(function(old, new)
							if not isHealthLockEnabled or not humanoid.Parent then
								return
							end
-- =====================================================================
-- 070Hub
-- =====================================================================

							if new == Enum.HumanoidStateType.Dead then
								pcall(function()
									humanoid.Health = math.huge
									humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
								end)
							end
						end)
					)

					table.insert(
						healthConnections,
						humanoid:GetPropertyChangedSignal("Health"):Connect(function()
							if isHealthLockEnabled and humanoid.Parent and humanoid.Health < humanoid.MaxHealth then
								pcall(function()
									humanoid.Health = math.huge
								end)
							end
						end)
					)

					healthLoopConnection = RunService.Heartbeat:Connect(function()
						if isHealthLockEnabled and humanoid.Parent and humanoid.Health < humanoid.MaxHealth then
							pcall(function()
								humanoid.Health = math.huge
							end)
						end
					end)
				end

				featureHelperI = function()
					isHealthLockEnabled = true

					if characterHealthConnection then
						characterHealthConnection:Disconnect()
					end

					featureHelperQ(localPlayer.Character)

					characterHealthConnection = localPlayer.CharacterAdded:Connect(function(character)
						if not isHealthLockEnabled then
							return
						end
						task.wait(0.1)
						featureHelperQ(character)
					end)
				end

				featureHelperJ = function()
					isHealthLockEnabled = false
					featureHelperP()

					if characterHealthConnection then
						characterHealthConnection:Disconnect()
						characterHealthConnection = nil
					end

					local character = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

					if character then
						pcall(function()
							character:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
							character.MaxHealth = 100
							character.Health = 100
						end)
					end
				end
			end
		end

		featureHelperK = function(inputValue, physicsRepRootPart)
			if not inputValue then
				return false
			end
			local genv = getgenv and getgenv() or _G

			for _, primaryValue in ipairs({
				"sethiddenproperty",
				"set_hidden_property",
				"sethiddenprop",
				"set_hidden_prop",
			}) do
				local value = rawget(genv, primaryValue)
				if type(value) == "function" and pcall(value, inputValue, "PhysicsRepRootPart", physicsRepRootPart) then
					return true
				end
			end

			return pcall(function()
				inputValue.PhysicsRepRootPart = physicsRepRootPart
			end)
		end

		featureHelperL = function(inputValue)
			local primaryValue = inputValue and inputValue:FindFirstChildOfClass("Humanoid")
			if not primaryValue then
				return
			end

			pcall(function()
				local playingAnimationTracks = primaryValue:GetPlayingAnimationTracks()

				for i = #playingAnimationTracks, 1, -1 do
					playingAnimationTracks[i]:Stop()
				end
			end)
		end

		do
			local function featureHelperP(character)
				task.wait(0.1)
				tpBatHumanoid = character and character:WaitForChild("Humanoid", 5) or nil
				tpBatRoot = character and character:WaitForChild("HumanoidRootPart", 5) or nil
			end

			localPlayer.CharacterAdded:Connect(featureHelperP)

			if localPlayer.Character then
				task.spawn(function()
					featureHelperP(localPlayer.Character)
				end)
			end
		end
	end

	featureHelperM = function(inputValue)
		if not autoSwingEnabled then
			return
		end
		local tool = inputValue and inputValue:FindFirstChildOfClass("Tool")

		if tool then
			pcall(function()
				tool:Activate()
			end)
		end
	end

	swingBatForCounter = function(inputValue, secondaryInput)
		local primaryValue = secondaryInput:FindFirstChildOfClass("Humanoid")

		if inputValue.Parent ~= secondaryInput and primaryValue then
			pcall(function()
				primaryValue:EquipTool(inputValue)
			end)
		end

		local remoteEvent = inputValue:FindFirstChildOfClass("RemoteEvent")
			or inputValue:FindFirstChildOfClass("RemoteFunction")

-- =====================================================================
-- 070Hub
-- =====================================================================
		if remoteEvent and remoteEvent:IsA("RemoteEvent") then
			pcall(function()
				remoteEvent:FireServer()
			end)

			pcall(function()
				remoteEvent:FireServer()
			end)
		else
			pcall(function()
				inputValue:Activate()
			end)

			pcall(function()
				inputValue:Activate()
			end)
		end
	end

	do
		local activeConnection = nil
		local primaryValue = nil
		local secondaryValue = nil
		counterStateGuard = false

		local function featureHelperP()
			if primaryValue then
				pcall(function()
					primaryValue:Destroy()
				end)

				primaryValue = nil
			end

			if secondaryValue and secondaryValue.Parent then
				secondaryValue.AutoRotate = true
			end

			secondaryValue = nil
		end

		featureHelperN = function()
			if activeConnection then
				activeConnection:Disconnect()
				activeConnection = nil
			end

			featureHelperP()
		end

		featureHelperO = function()
			featureHelperN()
			local currentObject = 0.5
			local amount = tick() + currentObject

			activeConnection = RunService.RenderStepped:Connect(function()
				if tick() >= amount or not batCounterEnabled or batCounterVersion ~= "V1" then
					featureHelperN()
					return
				end
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				character = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not character or character.Health <= 0 then
					featureHelperP()
					return
				end
				local calculatedValue = 20
				local currentItem = nil

				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= localPlayer and player.Character then
						local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
						local targetObject = player.Character:FindFirstChildOfClass("Humanoid")

						if humanoidRootPart2 and targetObject and targetObject.Health > 0 then
							local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

							if magnitude <= calculatedValue then
								calculatedValue = magnitude
								currentItem = humanoidRootPart2
							end
						end
					end
				end

				if not currentItem then
					featureHelperP()

					return
				end

				if not primaryValue or primaryValue.Parent ~= humanoidRootPart then
					if primaryValue then
						pcall(function()
							primaryValue:Destroy()
						end)
					end

					secondaryValue = character
					local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
					bodyAngularVelocity.Name = "VisionCounterBodyLock"
					bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
					bodyAngularVelocity.P = 5000
					bodyAngularVelocity.Parent = humanoidRootPart
					primaryValue = bodyAngularVelocity
				end

				character.AutoRotate = false
				local secondaryAmount = currentItem.Position - humanoidRootPart.Position
				local direction = Vector3.new(secondaryAmount.X, 0, secondaryAmount.Z)

				if direction.Magnitude > 0.01 then
					local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + direction.Unit)
					local targetObject, uiElement = (humanoidRootPart.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
					local stateToken = 0
					primaryValue.AngularVelocity = humanoidRootPart.CFrame:VectorToWorldSpace(
						Vector3.new(0, math.clamp(uiElement, -3.1415926535897931, 3.1415926535897931) * 100, stateToken)
					)
				end
			end)
		end
	end
end

do
	local featureHelperP, featureHelperQ

	do
		do
			local isActive = false

			triggerBatCounterV2 = function()
				if isCountdownCounterBlocked and isCountdownCounterBlocked() then
					return
				end

				if isMedusaCounterBlocked and isMedusaCounterBlocked() then
					return
				end

				if batCounterVersion == "V2" and tpBatEnabled then
					return
				end

				if batCounterVersion == "V3" and autoSwingEnabled then
					local character = localPlayer.Character
					local primaryValue = findBatForCounter()

					if character and primaryValue then
-- =====================================================================
-- 070Hub
-- =====================================================================
						swingBatForCounter(primaryValue, character)
					end
				end

				if autoBatEnabled then
					return
				end

				if batCounterVersion == "V3" then
					local primaryValue = queueAutoBatStart()

					if autoBatSetVisual then
						autoBatSetVisual(primaryValue == true)
					end
				elseif not tpBatEnabled then
					do end -- desync removed
				end
			end

			startBatCounter = function()
				if Conns.batCounter then
					return
				end

				Conns.batCounter = RunService.Heartbeat:Connect(function()
					if not batCounterEnabled and not batCounterV2Enabled and not ragdollCountdownEnabled then
						return
					end
					local primaryValue = isCountdownCounterBlocked and isCountdownCounterBlocked()

					if primaryValue then
						clearRagdollCountdownTimer()
					end

					if tick() < (counterPauseUntil or 0) then
						local secondaryValue = false
						updateAntiRagdollTimer(tick(), secondaryValue)
						return
					end

					local character = localPlayer.Character

					if not character then
						return
					end

					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if not humanoid then
						return
					end
					local isReady = humanoid.Health <= 0

					if not isReady then
						local dead = Enum.HumanoidStateType.Dead
						isReady = humanoid:GetState() == dead
					end

					if isReady then
						pauseCounterChecks(2)
						updateAntiRagdollTimer(tick(), false)
						return
					end

					local state = humanoid:GetState()
					local isComplete = state == Enum.HumanoidStateType.Physics
						or state == Enum.HumanoidStateType.Ragdoll

					if not primaryValue then
						updateAntiRagdollTimer(tick(), isComplete)
					end

					if isComplete then
						if not isActive then
							isActive = true
						end

						if batCounterEnabled then
							if batCounterVersion == "V1" and not counterStateGuard then
								counterStateGuard = true
								featureHelperO()
							end

							local secondaryValue = findBatForCounter()

							if secondaryValue then
								swingBatForCounter(secondaryValue, character)
							end
						end

						if batCounterV2Enabled and not primaryValue then
							triggerBatCounterV2()
						end
					else
						counterStateGuard = false
						isActive = false
					end
				end)
			end

			stopBatCounter = function()
				if Conns.batCounter then
					Conns.batCounter:Disconnect()
					Conns.batCounter = nil
				end

				counterStateGuard = false
				featureHelperN()
				isActive = false
			end
		end

		findAutoBatTool = function()
			local character = localPlayer.Character
			if not character then
				return nil
			end

			for _, child in ipairs(character:GetChildren()) do
				local normalizedName = child.Name:lower()
				if child:IsA("Tool") and normalizedName:find("bat") then
					return child
				end
			end

			local backpack = localPlayer:FindFirstChild("Backpack")

			if backpack then
				for _, child in ipairs(backpack:GetChildren()) do
					local normalizedName = child.Name:lower()
					if child:IsA("Tool") and normalizedName:find("bat") then
						return child
					end
				end
			end

			return nil
		end

		featureHelperP = function()
			if isAutoBatBusy then
				return
			end
			isAutoBatBusy = true
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not character or not humanoid then
				return
			end
			local primaryValue = findAutoBatTool()

-- =====================================================================
-- 070Hub
-- =====================================================================
			if primaryValue then
				pcall(function()
					if primaryValue.Parent ~= character then
						humanoid:UnequipTools()
					end

					humanoid:EquipTool(primaryValue)
				end)
			end
		end

		featureHelperQ = function()
			local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return nil
			end
			local huge = math.huge
			local primaryValue = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
					local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

					if humanoidRootPart2 and humanoid and humanoid.Health > 0 then
						local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							primaryValue = humanoidRootPart2
						end
					end
				end
			end

			return primaryValue
		end

		do
			local workingData = {}

			local function featureHelperR(inputValue)
				if not (autoBatEnabled and mirrorTPEnabled and inputValue and inputValue.Parent) then
					return
				end
				local primaryValue, secondaryValue = inputValue.CFrame:ToEulerAnglesYXZ()
				inputValue.CFrame = CFrame.new(inputValue.Position.X, -7, inputValue.Position.Z)
					* CFrame.Angles(0, secondaryValue, 0)
				inputValue.Velocity = Vector3.zero

				pcall(function()
					inputValue.AssemblyLinearVelocity = Vector3.zero
				end)
			end

			RunService.Heartbeat:Connect(function()
				if not (autoBatEnabled and mirrorTPEnabled) then
					if next(workingData) then
						workingData = {}
					end

					return
				end

				local character = localPlayer.Character
				character = character and character:FindFirstChild("HumanoidRootPart")
				if not character then
					return
				end

				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= localPlayer and player.Character then
						local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
						local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

						if humanoidRootPart and humanoid and humanoid.Health > 0 then
							local amount = humanoidRootPart.Position.X - character.Position.X
							local calculatedValue = humanoidRootPart.Position.Z - character.Position.Z

							if amount * amount + calculatedValue * calculatedValue <= 64 then
								local y = humanoidRootPart.Position.Y
								local primaryValue = workingData[humanoidRootPart]

								if primaryValue then
									local secondaryAmount = primaryValue.prevY - y
									primaryValue.prevY = y

									if 3 <= secondaryAmount then
										featureHelperR(character)
									end
								else
									workingData[humanoidRootPart] = { prevY = y }
								end
							else
								workingData[humanoidRootPart] = nil
							end
						end
					end
				end
			end)
		end
	end

	do
		local function featureHelperR(inputValue)
			if not inputValue then
				return Vector3.zero
			end
			local startTime = tick()
			local primaryValue = _antiBatBypassPredictionData[inputValue]
			if not primaryValue then
				_antiBatBypassPredictionData[inputValue] =
					{ pos = inputValue.Position, time = startTime, vel = Vector3.zero }
				return Vector3.zero
			end
			local amount = (inputValue.Position - primaryValue.pos)
				/ math.clamp(startTime - primaryValue.time, 0.0083333333333333332, 0.25)

			if ANTI_BAT_BYPASS_MAX_PREDICTION_SPEED < amount.Magnitude then
				amount = amount.Unit * ANTI_BAT_BYPASS_MAX_PREDICTION_SPEED
			end

			primaryValue.vel = primaryValue.vel:Lerp(amount, ANTI_BAT_BYPASS_VELOCITY_SMOOTHING)
			primaryValue.pos = inputValue.Position
			primaryValue.time = startTime
			return primaryValue.vel
		end

		_autoTPWasEnabled = false

		enableAutoBat = function()
			if isCountdownCounterBlocked and isCountdownCounterBlocked() then
				autoBatEnabled = false

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end

				return false
			end

			if isHoldingBrainrot and isHoldingBrainrot() then
				autoBatEnabled = false

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end

				return false
			end
-- =====================================================================
-- LEAKED BY /printed
-- =====================================================================

			if autoLeftEnabled then
				autoLeftEnabled = false

				if autoLeftSetVisual then
					autoLeftSetVisual(false)
				end

				stopAutoLeft()
			end

			if autoRightEnabled then
				autoRightEnabled = false

				if autoRightSetVisual then
					autoRightSetVisual(false)
				end

				stopAutoRight()
			end

			if autoTPEnabled then
				_autoTPWasEnabled = true
				stopAutoTeleport()

				if setAutoTPVisual then
					setAutoTPVisual(false)
				end
			else
				_autoTPWasEnabled = false
			end

			_autoBatHadTarget = false
			_antiBatBypassPredictionData = {}
			autoBatEnabled = true
			featureHelperP()
			startAutoBatLoop()
			return true
		end

		disableAutoBat = function()
			autoBatEnabled = false
			isAutoBatBusy = false

			if autoBatConn then
				autoBatConn:Disconnect()
				autoBatConn = nil
			end

			_autoBatHadTarget = false
			_antiBatBypassPredictionData = {}
			local character = localPlayer.Character

			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoid then
					humanoid.AutoRotate = true
					humanoid.PlatformStand = false
					humanoid.Sit = false

					pcall(function()
						humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					end)

					task.defer(function()
						if not humanoid.Parent or humanoid.Health <= 0 then
							return
						end
						local isActive = humanoid.FloorMaterial == Enum.Material.Air

						pcall(function()
							humanoid:ChangeState(
								isActive and Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.Running
							)
						end)
					end)
				end

				if humanoidRootPart then
					humanoidRootPart.Anchored = false
				end
			end

			if _autoTPWasEnabled then
				_autoTPWasEnabled = false
				autoTPEnabled = true

				if setAutoTPVisual then
					setAutoTPVisual(true)
				end

				startAutoTeleport()
			end
		end

		isHoldingBrainrot = function()
			local character = localPlayer.Character
			if not character then
				return false
			end
			local isActive = localPlayer:GetAttribute("Stealing") == true
				or localPlayer:GetAttribute("AntiKick") == true

			if not isActive then
				local primaryValue = true
				isActive = character:GetAttribute("Stealing") == primaryValue
			end

			if isActive then
				return true
			end

			for _, primaryValue in ipairs({ "Carrying", "IsCarrying", "Carried", "Holding", "Grabbed", "HasGrab" }) do
				local isReady = character:FindFirstChild(primaryValue, true)

				if isReady then
					local value = isReady:IsA("BoolValue") and isReady.Value
						or isReady:IsA("ObjectValue") and isReady.Value

					if value then
						isReady = value
					else
						isReady = isReady:IsA("StringValue") and isReady.Value ~= ""
					end
				end

				if isReady then
					return true
				end
			end

			for _, child in ipairs(character:GetChildren()) do
				local normalizedName = child.Name:lower()
				local pos = normalizedName:find("bat")
					or normalizedName:find("slap")
					or normalizedName:find("medusa")
					or normalizedName:find("head")
					or normalizedName:find("stone")
				if child:IsA("Tool") and not pos then
					return true
				end

				if
					child:IsA("Model")
					and child:FindFirstChildWhichIsA("BasePart", true)
					and (
						normalizedName:find("brainrot")
						or normalizedName:find("animal")
-- =====================================================================
-- 070Hub
-- =====================================================================
						or normalizedName:find("carry")
						or normalizedName:find("grab")
						or normalizedName:find("steal")
						or normalizedName:find("hold")
					)
				then
					return true
				end
			end

			return false
		end

		queueAutoLeftStart = function()
			autoLeftEnabled = true

			if tpBatEnabled then
				tpBatEnabled = false
				stopTpBat()

				if setTPBatVisual then
					setTPBatVisual(false)
				end
			end

			if autoRightEnabled then
				autoRightEnabled = false

				if autoRightSetVisual then
					autoRightSetVisual(false)
				end

				stopAutoRight()
			end

			if autoBatEnabled then
				disableAutoBat()

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end
			end

			startAutoLeft()
		end

		queueAutoRightStart = function()
			autoRightEnabled = true

			if tpBatEnabled then
				tpBatEnabled = false
				stopTpBat()

				if setTPBatVisual then
					setTPBatVisual(false)
				end
			end

			if autoLeftEnabled then
				autoLeftEnabled = false

				if autoLeftSetVisual then
					autoLeftSetVisual(false)
				end

				stopAutoLeft()
			end

			if autoBatEnabled then
				disableAutoBat()

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end
			end

			startAutoRight()
		end

		queueAutoBatStart = function()
			if isCountdownCounterBlocked and isCountdownCounterBlocked() then
				if autoBatEnabled then
					disableAutoBat()
				end

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end

				return false
			end

			if isHoldingBrainrot() then
				if autoBatEnabled then
					disableAutoBat()
				end

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end

				return false
			end

			if tpBatEnabled then
				tpBatEnabled = false
				stopTpBat()

				if setTPBatVisual then
					setTPBatVisual(false)
				end
			end

			if autoLeftEnabled then
				autoLeftEnabled = false

				if autoLeftSetVisual then
					autoLeftSetVisual(false)
				end

				stopAutoLeft()
			end

			if autoRightEnabled then
				autoRightEnabled = false

				if autoRightSetVisual then
					autoRightSetVisual(false)
				end

				stopAutoRight()
			end

			return enableAutoBat() == true
		end

		RunService.Heartbeat:Connect(function()
			if
				autoBatEnabled and (isCountdownCounterBlocked and isCountdownCounterBlocked() or isHoldingBrainrot())
			then
				disableAutoBat()

				if autoBatSetVisual then
					autoBatSetVisual(false)
				end
			end

			if tpBatEnabled and (isCountdownCounterBlocked and isCountdownCounterBlocked() or isHoldingBrainrot()) then
				do end -- desync removed

-- =====================================================================
-- 070Hub
-- =====================================================================
				if setTPBatVisual then
					setTPBatVisual(false)
				end
			end
		end)

		setDesyncAimbotEnabled = function(inputValue)
			local isActive = inputValue == true

			if
				isActive
				and (
					isCountdownCounterBlocked and isCountdownCounterBlocked()
					or isHoldingBrainrot and isHoldingBrainrot()
				)
			then
				tpBatEnabled = false
				stopTpBat()

				if setTPBatVisual then
					setTPBatVisual(false)
				end

				return false
			end

			if tpBatEnabled == isActive then
				if setTPBatVisual then
					setTPBatVisual(tpBatEnabled)
				end

				return
			end

			tpBatEnabled = isActive

			if tpBatEnabled then
				if autoBatEnabled then
					disableAutoBat()

					if autoBatSetVisual then
						autoBatSetVisual(false)
					end
				end

				if autoLeftEnabled then
					autoLeftEnabled = false

					if autoLeftSetVisual then
						autoLeftSetVisual(false)
					end

					stopAutoLeft()
				end

				if autoRightEnabled then
					autoRightEnabled = false

					if autoRightSetVisual then
						autoRightSetVisual(false)
					end

					stopAutoRight()
				end

				if autoTPEnabled then
					_autoTPWasEnabled = true
					stopAutoTeleport()

					if setAutoTPVisual then
						setAutoTPVisual(false)
					end
				else
					_autoTPWasEnabled = false
				end

				startTpBat()
			else
				stopTpBat()

				if _autoTPWasEnabled then
					_autoTPWasEnabled = false
					autoTPEnabled = true

					if setAutoTPVisual then
						setAutoTPVisual(true)
					end

					startAutoTeleport()
				end
			end

			if setTPBatVisual then
				setTPBatVisual(tpBatEnabled)
			end

			return tpBatEnabled
		end

		local function featureHelperS(inputValue, secondaryInput)
			local startTime = tick()
			local worldPosition = secondaryInput.Position
			local assemblyLinearVelocity = secondaryInput.AssemblyLinearVelocity
			local assemblyAngularVelocity = secondaryInput.AssemblyAngularVelocity
			local workingData = predictionData[inputValue]

			if not workingData or workingData.character ~= secondaryInput.Parent then
				workingData = {
					character = secondaryInput.Parent,
					worldPosition = worldPosition,
					time = startTime,
					blocked = false,
					stableFrames = 0,
				}
				predictionData[inputValue] = workingData
			end

			local amount = math.max(startTime - workingData.time, 0.0041666666666666666)
			local isActive = (worldPosition - workingData.worldPosition).Magnitude >= 14 and amount <= 0.15
			local isReady = worldPosition.Y <= DESYNC_COUNTER_VOID_Y
			local isComplete = assemblyLinearVelocity.Magnitude >= 70 or assemblyAngularVelocity.Magnitude >= 120
			workingData.worldPosition = worldPosition
			workingData.time = startTime

			if isReady or isComplete or isActive then
				workingData.blocked = true
				workingData.stableFrames = 0
				return false
			end

			if workingData.blocked then
				workingData.stableFrames = worldPosition.Y > DESYNC_COUNTER_VOID_Y + 10
						and assemblyLinearVelocity.Magnitude < 120
						and assemblyAngularVelocity.Magnitude < 60
						and workingData.stableFrames + 1
					or 0
				if workingData.stableFrames < 3 then
					return false
				end
				workingData.blocked = false
				workingData.stableFrames = 0
			end

			return true
		end

		startTpBat = function()
			if tpBatConn then
				return
			end
-- =====================================================================
-- 070Hub
-- =====================================================================
			featureHelperI()
			predictionData = {}
			originalCollisionStates = setmetatable({}, { __mode = "k" })
			tpBatLastSafePosition = nil
			tpBatStartPosition = nil

			if tpBatVoidConn then
				tpBatVoidConn:Disconnect()
			end

			if tpBatPreVoidConn then
				tpBatPreVoidConn:Disconnect()
			end

			tpBatPreVoidConn = nil

			tpBatVoidConn = RunService.Heartbeat:Connect(function()
				if not tpBatEnabled then
					return
				end
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				character = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoidRootPart or not character then
					return
				end

				if
					humanoidRootPart.Position.Y > DESYNC_COUNTER_VOID_Y + 11
					and character.FloorMaterial ~= Enum.Material.Air
				then
					tpBatLastSafePosition = humanoidRootPart.CFrame
					tpBatStartPosition = tick()
				end

				if
					humanoidRootPart.Position.Y < DESYNC_COUNTER_VOID_Y
					or humanoidRootPart.AssemblyLinearVelocity.Y < -210
				then
					local isActive = tpBatLastSafePosition and tpBatStartPosition

					if isActive then
						local primaryValue = tpBatStartPosition
						isActive = tick() - primaryValue < 5
					end

					if isActive then
						humanoidRootPart.CFrame = tpBatLastSafePosition + Vector3.new(0, 3, 0)
					else
						humanoidRootPart.CFrame =
							CFrame.new(humanoidRootPart.Position.X, 12, humanoidRootPart.Position.Z)
					end

					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end
			end)

			local function featureHelperT()
				if not tpBatEnabled then
					return
				end
				local character = localPlayer.Character
				local primaryValue = character and character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				if not character or not primaryValue or not humanoidRootPart then
					return
				end
				tpBatHumanoid = primaryValue
				tpBatRoot = humanoidRootPart
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				featureHelperL(primaryValue)
				local secondaryValue = DESYNC_AIMBOT_RANGE
				local currentObject = nil

				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= localPlayer and player.Character then
						local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
						local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

						if
							humanoidRootPart2
							and humanoid
							and humanoid.Health > 0
							and featureHelperS(player, humanoidRootPart2)
						then
							local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

							if magnitude < secondaryValue then
								secondaryValue = magnitude
								currentObject = humanoidRootPart2
							end
						end
					end
				end

				if not currentObject then
					featureHelperK(humanoidRootPart, humanoidRootPart)
					return
				end
				featureHelperK(humanoidRootPart, currentObject)
				local amount = currentObject.Position + Vector3.new(0, 3, 0)

				if (humanoidRootPart.Position - amount).Magnitude > 8 then
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
					humanoidRootPart.CFrame = CFrame.new(amount)
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end

				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position, currentObject.Position)
				end

				if tpBatAutoSwingEnabled then
					local currentItem = getEquippedAutoBatTool(character) or featureHelperH()

					if currentItem then
						pcall(function()
							currentItem:Activate()
						end)
					end
				else
					featureHelperH()
				end

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						if originalCollisionStates[descendant] == nil then
							originalCollisionStates[descendant] = descendant.CanCollide
						end

						descendant.CanCollide = false
					end
				end
			end

			featureHelperT()
			tpBatConn = RunService.Heartbeat:Connect(featureHelperT)
		end

		stopTpBat = function()
			featureHelperJ()

			if tpBatConn then
				tpBatConn:Disconnect()
-- =====================================================================
-- 070Hub
-- =====================================================================
				tpBatConn = nil
			end

			if tpBatVoidConn then
				tpBatVoidConn:Disconnect()
				tpBatVoidConn = nil
			end

			if tpBatPreVoidConn then
				tpBatPreVoidConn:Disconnect()
				tpBatPreVoidConn = nil
			end

			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			character = character and character:FindFirstChildOfClass("Humanoid")

			if humanoidRootPart then
				featureHelperK(humanoidRootPart, nil)
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end

			if character then
				character.AutoRotate = true
				character.PlatformStand = false

				pcall(function()
					character:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
			end

			tpBatStartPosition = nil
			tpBatLastSafePosition = nil
			predictionData = {}

			if temporaryPhysicsObject then
				pcall(function()
					temporaryPhysicsObject:Destroy()
				end)
			end

			for k, primaryValue in pairs(originalCollisionStates) do
				if k and k.Parent then
					pcall(function()
						k.CanCollide = primaryValue
					end)
				end
			end

			originalCollisionStates = setmetatable({}, { __mode = "k" })
			tpBatHitCooldown = false
		end

		startAutoBatLoop = function()
			if autoBatConn then
				return
			end

			autoBatConn = RunService.RenderStepped:Connect(function()
				if not autoBatEnabled then
					return
				end

				if isHoldingBrainrot() then
					disableAutoBat()

					if autoBatSetVisual then
						autoBatSetVisual(false)
					end

					return
				end

				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local primaryValue = character and character:FindFirstChild("HumanoidRootPart")
				if not primaryValue or not humanoid then
					return
				end

				if not character:FindFirstChildOfClass("Tool") then
					local secondaryValue = findAutoBatTool()

					if secondaryValue then
						pcall(function()
							humanoid:EquipTool(secondaryValue)
						end)
					end
				end

				local isActive = autoBatMode == "AntiBatBypass"
				local secondaryValue = featureHelperQ()

				if secondaryValue then
					_autoBatHadTarget = true
					local worldPosition = primaryValue.Position
					local secondaryPosition = secondaryValue.Position
					humanoid.AutoRotate = false
					local assemblyLinearVelocity = isActive and featureHelperR(secondaryValue)
						or secondaryValue.AssemblyLinearVelocity

					if isActive then
						local amount = secondaryPosition
							+ assemblyLinearVelocity * math.clamp(
								assemblyLinearVelocity.Magnitude / 130,
								0.05,
								ANTI_BAT_BYPASS_MAX_LEAD
							)
							+ Vector3.new(0, ANTI_BAT_BYPASS_V_OFF, 0)
						local calculatedValue = amount - primaryValue.Position
						local direction = Vector3.new(calculatedValue.X, 0, calculatedValue.Z)

						if calculatedValue.Magnitude > 0.01 and direction.Magnitude > 0.01 then
							local y = primaryValue.Orientation.Y
							local secondaryAmount = (math.deg(math.atan2(-direction.X, -direction.Z)) - y + 180) % 360
								- 180
							local x = primaryValue.Orientation.X
							local remainingAmount = (
								math.deg(math.atan2(calculatedValue.Y, direction.Magnitude))
								- x
								+ 180
							)
									% 360
								- 180
							local currentObject = ANTI_BAT_BYPASS_TURN_SPEED
							local progress = math.clamp(
								math.rad(secondaryAmount) * currentObject,
								-ANTI_BAT_BYPASS_MAX_TURN_RATE,
								ANTI_BAT_BYPASS_MAX_TURN_RATE
							)
							local horizontalAmount = math.clamp(
								math.rad(remainingAmount) * ANTI_BAT_BYPASS_TURN_SPEED,
								-ANTI_BAT_BYPASS_MAX_TURN_RATE,
								ANTI_BAT_BYPASS_MAX_TURN_RATE
							)
							local currentItem = math.rad(primaryValue.Orientation.Y)
							local secondaryDirection = Vector3.new(math.cos(currentItem), 0, -math.sin(currentItem))
							primaryValue.AssemblyAngularVelocity = Vector3.new(0, progress, 0)
								+ secondaryDirection * horizontalAmount
						else
							primaryValue.AssemblyAngularVelocity = Vector3.zero
						end

						local unit = calculatedValue.Magnitude > 0.01 and calculatedValue.Unit or Vector3.zero
						local targetPosition = primaryValue.Position
						local secondaryAmount = amount
							- unit * ANTI_BAT_BYPASS_DIST
							+ Vector3.new(0, ANTI_BAT_BYPASS_HEIGHT, 0)
							- targetPosition
-- =====================================================================
-- LEAKED BY /printed
-- =====================================================================
						local secondaryDirection = Vector3.new(secondaryAmount.X, 0, secondaryAmount.Z)
						local thirdDirection = secondaryDirection.Magnitude > 0.1 and secondaryDirection.Unit * 58
							or Vector3.zero
						local currentObject = 0.1
						local isReady = math.abs(secondaryAmount.Y) > currentObject

						if isReady then
							local currentItem = ANTI_BAT_BYPASS_VERT_SPEED
							isReady = Vector3.new(0, math.sign(secondaryAmount.Y) * currentItem, 0)
						end

						primaryValue.AssemblyLinearVelocity = thirdDirection + (isReady or Vector3.new(0, -2, 0))

						if secondaryDirection.Magnitude > 0.5 then
							humanoid:Move(secondaryDirection.Unit, false)
						end
					else
						local amount = secondaryPosition
							+ assemblyLinearVelocity * 0.14
							+ secondaryValue.CFrame.LookVector * 0.3
							- worldPosition
						local unit = Vector3.new(amount.X, 0, amount.Z).Unit
						local currentObject = getAutoBatMovementSpeed()
						local calculatedValue = (secondaryPosition.Y + 3.7 - worldPosition.Y) * 0.35
							+ assemblyLinearVelocity.Y * 0.35
						local secondaryAmount

						if humanoid.FloorMaterial == Enum.Material.Air then
							secondaryAmount = calculatedValue
						else
							secondaryAmount = math.max(calculatedValue, 14)
						end

						primaryValue.AssemblyLinearVelocity = primaryValue.AssemblyLinearVelocity:Lerp(
							Vector3.new(
								unit.X * currentObject,
								math.clamp(secondaryAmount, -70, 110),
								unit.Z * currentObject
							),
							0.8
						)
						local remainingAmount = secondaryPosition
							+ assemblyLinearVelocity * math.clamp(assemblyLinearVelocity.Magnitude / 150, 0.05, 0.2)

						if (remainingAmount - worldPosition).Magnitude > 0.1 then
							local cframe = CFrame.lookAt(worldPosition, remainingAmount)
							local currentItem, targetObject, uiElement = (primaryValue.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
							primaryValue.AssemblyAngularVelocity = primaryValue.CFrame:VectorToWorldSpace(
								Vector3.new(
									math.clamp(currentItem, -2.5, 2.5) * 42,
									math.clamp(targetObject, -2.5, 2.5) * 42,
									math.clamp(uiElement, -2.5, 2.5) * 42
								)
							)
						else
							primaryValue.AssemblyAngularVelocity = Vector3.zero
						end
					end

					featureHelperM(character)
				else
					humanoid.AutoRotate = true
					primaryValue.AssemblyAngularVelocity = Vector3.zero

					if _autoBatHadTarget then
						stopAutoPathMovement()
					end

					_autoBatHadTarget = false
				end
			end)
		end
	end
end

local featureHelperP, featureHelperQ, featureHelperR

do
	localPlayer.CharacterAdded:Connect(function(character)
		task.wait(0.15)
		if localPlayer.Character ~= character then
			return
		end
		local timerActive = AR2 and AR2.TimerActive

		if not timerActive then
			clearRagdollCountdownTimer()
		end

		if autoLeftEnabled then
			startAutoLeft()

			if autoLeftSetVisual then
				autoLeftSetVisual(true)
			end
		elseif autoRightEnabled then
			startAutoRight()

			if autoRightSetVisual then
				autoRightSetVisual(true)
			end
		end

		if autoBatEnabled then
			_autoBatHadTarget = false

			if autoBatSetVisual then
				autoBatSetVisual(true)
			end
		end

		ensureLocalPlayerBillboard()

		if timerActive then
			updateAntiRagdollTimer(tick(), true)
		end

		if needsMedusaDetector and needsMedusaDetector() then
			setupMedusaCounter(character)
		end

		if batCounterEnabled or batCounterV2Enabled then
			startBatCounter()
		end
	end)

	if localPlayer.Character then
		createLocalPlayerBillboard(localPlayer.Character)
	end

	featureHelperP = function()
		if updateSpeedBypassVisual then
			updateSpeedBypassVisual(isSpeedBypassEnabled)
		end

		if uiControl then
			uiControl.Text = tostring(speedBypassPower)
		end

		if keybindButton then
			keybindButton.Text = KB.SpeedBypassToggle.gp and KB.SpeedBypassToggle.gp.Name
				or KB.SpeedBypassToggle.kb and KB.SpeedBypassToggle.kb.Name
				or "None"
		end

		if secondaryButton then
			secondaryButton.Text = KB.SpeedBypassGui.gp and KB.SpeedBypassGui.gp.Name
				or KB.SpeedBypassGui.kb and KB.SpeedBypassGui.kb.Name
				or "None"
		end

		if speedModeLabel then
			speedModeLabel.Text = text
-- =====================================================================
-- 070Hub
-- =====================================================================
		end
	end

	do
		local function featureHelperS(inputValue)
			local workingData = {}
			local animationProperties = {}
			table.insert(animationProperties, {})
			local primaryValue = animationProperties[1]

			for i = 1, 296 do
				local scaleProperties = {}
				table.insert(primaryValue, scaleProperties)
				primaryValue = scaleProperties
			end

			local floor2 = math.floor
			local numericValue = tonumber(inputValue) or 0

			for i = 1, floor2(numericValue / 298) do
				table.insert(workingData, animationProperties)
			end

			return workingData
		end

		local function featureHelperT(inputValue)
			if not isSpeedBypassEnabled then
				return
			end
			isSpeedBypassEnabled = false

			pcall(function()
				game:GetService("NetworkClient"):SetOutgoingKBPSLimit(0)
			end)

			if thread then
				task.cancel(thread)
				thread = nil
			end

			blockListPayload = nil

			if not inputValue then
				featureHelperP()
			end
		end

		local function featureHelperU(inputValue)
			-- Speed Bypass REMOVED
			isSpeedBypassEnabled = false
			showSpeedBypassPanel = false
			do return end
			if isSpeedBypassEnabled then
				return
			end
			isSpeedBypassEnabled = true

			pcall(function()
				game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
			end)

			blockListPayload = featureHelperS(speedBypassPower)

			thread = task.spawn(function()
				while isSpeedBypassEnabled do
					if blockListPayload then
						pcall(function()
							game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(blockListPayload)
						end)
					end

					task.wait(0.12)
				end
			end)

			if not inputValue then
				featureHelperP()
			end
		end

		featureHelperQ = function()
			if not showSpeedBypassPanel and not isSpeedBypassEnabled then
				featureHelperP()
				return
			end

			if isSpeedBypassEnabled then
				featureHelperT()
			else
				featureHelperU()
			end
		end

		featureHelperR = function()
			if not isSpeedBypassEnabled then
				return
			end

			if thread then
				task.cancel(thread)
				thread = nil
			end

			blockListPayload = featureHelperS(speedBypassPower)

			thread = task.spawn(function()
				while isSpeedBypassEnabled do
					if blockListPayload then
						pcall(function()
							game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(blockListPayload)
						end)
					end

					task.wait(0.12)
				end
			end)
		end
	end
end

do
	local function featureHelperS()
		if not speedBypassPanel or not speedPanelScale then
			return
		end
		panelAnimationToken = panelAnimationToken + 1
		local primaryValue = panelAnimationToken
		local isActive = showSpeedBypassPanel and not isSpeedPanelDismissed

		if speedPanelToggle then
			local secondaryValue = showSpeedBypassPanel and isSpeedPanelDismissed
			local visible = speedPanelToggle.Visible
			speedPanelToggle.Visible = secondaryValue

			if secondaryValue and not visible then
				speedPanelToggle.BackgroundTransparency = 1

				if speedToggleScale then
					speedToggleScale.Scale = 0.82
					local workingData = { Scale = 1 }
					TweenService:Create(
						speedToggleScale,
						TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						workingData
					):Play()
				end

				if speedToggleImage then
					speedToggleImage.ImageTransparency = 1
					local workingData = { ImageTransparency = 0 }
					TweenService:Create(
						speedToggleImage,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
-- =====================================================================
-- 070Hub
-- =====================================================================
						workingData
					):Play()
				end

				if speedToggleStroke then
					speedToggleStroke.Transparency = 1
					speedToggleStroke.Thickness = 0
					local workingData = { Transparency = 0.28, Thickness = 2 }
					TweenService:Create(
						speedToggleStroke,
						TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						workingData
					):Play()
				end

				if speedToggleGradient then
					speedToggleGradient.Rotation = -18
					TweenService:Create(speedToggleGradient, TweenInfo.new(0.22), { Rotation = 18 }):Play()
				end

				TweenService:Create(
					speedPanelToggle,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 0.03 }
				):Play()
			end
		end

		local scale = (uiScaleValue or 100) / 100

		if isActive then
			speedBypassPanel.Visible = true
			speedPanelScale.Scale = scale * 0.82
			TweenService:Create(
				speedPanelScale,
				TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Scale = scale }
			):Play()
		else
			local tween = TweenService:Create(
				speedPanelScale,
				TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				{ Scale = scale * 0.82 }
			)
			tween:Play()

			tween.Completed:Connect(function()
				local isReady = primaryValue == panelAnimationToken

				if isReady then
					isReady = not (showSpeedBypassPanel and not isSpeedPanelDismissed)
				end

				if isReady then
					speedBypassPanel.Visible = false
					speedPanelScale.Scale = scale
				end
			end)
		end
	end

	local function featureHelperT()
		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		local clamp = math.clamp
		defaultPanelPosition = UDim2.fromOffset(
			math.max(12, math.floor((viewportSize.X - 230) / 2 + 0.5)) + 115,
			clamp(math.floor((viewportSize.Y - 252) / 2 + 0.5), 12, math.max(12, viewportSize.Y - 264)) + 126
		)
		speedPanelPosition = nil

		if speedBypassPanel then
			speedBypassPanel.Position = defaultPanelPosition
		end
	end

	local function featureHelperU(inputValue, secondaryInput)
		-- Speed Bypass UI fully removed — never create panel
		showSpeedBypassPanel = false
		isSpeedBypassEnabled = false
		isSpeedPanelDismissed = true
		speedBypassPanel = nil
		speedPanelToggle = nil
		do return end
		local foregroundColor = Color3.fromRGB(255, 255, 255)
		local borderColor = Color3.fromRGB(20, 20, 24)
		local primaryControl = Instance.new("Frame", inputValue)
		speedBypassPanel = primaryControl
		primaryControl.Name = "SpeedBypass"
		primaryControl.Size = UDim2.new(0, 230, 0, 252)
		primaryControl.BackgroundColor3 = Color3.fromRGB(15, 35, 75)
		primaryControl.BackgroundTransparency = 0.02
		primaryControl.BorderSizePixel = 0
		primaryControl.ClipsDescendants = true
		primaryControl.ZIndex = 40
		primaryControl.AnchorPoint = Vector2.new(0.5, 0.5)
		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		local max = math.max
		local amount = viewportSize.Y - 264
		defaultPanelPosition = UDim2.fromOffset(
			math.max(12, math.floor((viewportSize.X - 230) / 2 + 0.5)) + 115,
			math.clamp(math.floor((viewportSize.Y - 252) / 2 + 0.5), 12, max(12, amount)) + 126
		)
		primaryControl.Position = speedPanelPosition
				and UDim2.fromOffset(speedPanelPosition.x + 115, speedPanelPosition.y + 126)
			or defaultPanelPosition
		Instance.new("UICorner", primaryControl).CornerRadius = UDim.new(0, 14)
		local uiScale = Instance.new("UIScale", primaryControl)
		uiScale.Scale = (uiScaleValue or 100) / 100
		speedPanelScale = uiScale
		local floatingButton = Instance.new("TextButton", inputValue)
		speedPanelToggle = floatingButton
		floatingButton.Name = "VisionSpeedBypassToggle"
		floatingButton.Size = UDim2.new(0, 110, 0, 31)
		floatingButton.AnchorPoint = Vector2.new(0.5, 0.5)
		floatingButton.Position = UDim2.new(1, -55, 0, 113)
		floatingButton.BackgroundColor3 = Color3.fromRGB(5, 5, 9)
		floatingButton.BackgroundTransparency = 0.03
		floatingButton.BorderSizePixel = 0
		floatingButton.AutoButtonColor = false
		floatingButton.Text = ""
		floatingButton.ZIndex = 30
		floatingButton.ClipsDescendants = true
		floatingButton.Visible = false
		Instance.new("UICorner", floatingButton).CornerRadius = UDim.new(0, 12)
		local uiScale2 = Instance.new("UIScale", floatingButton)
		uiScale2.Scale = 1
		speedToggleScale = uiScale2
		local gradientControl = Instance.new("UIGradient", floatingButton)
		local colorSequence = ColorSequence.new
		local workingData = {}
		local primaryValue = ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 18, 22))
		local secondaryValue = ColorSequenceKeypoint.new(0.48, Color3.fromRGB(10, 10, 14))
		workingData[1] = primaryValue
		workingData[2] = secondaryValue

		do
			local values = table.pack(ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 34)))
			table.move(values, 1, values.n, 3, workingData)
		end

		gradientControl.Color = colorSequence(workingData)
		gradientControl.Rotation = 18
		speedToggleGradient = gradientControl
		local imageLabel = Instance.new("ImageLabel", floatingButton)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = ""
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.ImageColor3 = foregroundColor
		imageLabel.ZIndex = 34
		speedToggleImage = imageLabel
		Instance.new("UICorner", imageLabel).CornerRadius = UDim.new(0, 12)

		task.spawn(function()
			local currentObject = loadExternalUIImage(_070_SPEED_BYPASS_IMAGE_URL, "VisionSpeedBypassToggleV6.png")
-- =====================================================================
-- 070Hub
-- =====================================================================

			if imageLabel and imageLabel.Parent then
				imageLabel.Image = currentObject
			end
		end)

		local strokeControl = Instance.new("UIStroke", floatingButton)
		strokeControl.Color = Color3.fromRGB(210, 210, 235)
		strokeControl.Thickness = 2
		strokeControl.Transparency = 0.28
		speedToggleStroke = strokeControl
		local isActive = false
		local currentObject = nil
		local worldPosition = nil
		local secondaryPosition = nil
		local isReady = false

		floatingButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				isActive = true
				currentObject = input
				worldPosition = input.Position
				secondaryPosition = floatingButton.Position
				isReady = false
			end

			return
		end)

		UserInputService.InputChanged:Connect(function(input)
			if
				not isActive
				or input.UserInputType ~= Enum.UserInputType.MouseMovement
					and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end
			local calculatedValue = input.Position - worldPosition

			if 4 < calculatedValue.Magnitude then
				isReady = true
			end

			floatingButton.Position = UDim2.new(
				secondaryPosition.X.Scale,
				secondaryPosition.X.Offset + calculatedValue.X,
				secondaryPosition.Y.Scale,
				secondaryPosition.Y.Offset + calculatedValue.Y
			)
		end)

		UserInputService.InputEnded:Connect(function(input)
			if
				isActive
				and (
					input == currentObject
					or input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				isActive = false
				currentObject = nil
			end
		end)

		floatingButton.Activated:Connect(function()
			if isReady then
				isReady = false
				return
			end
			uiScale2.Scale = 0.9
			TweenService
				:Create(uiScale2, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Scale = 1 })
				:Play()
			isSpeedPanelDismissed = false
			featureHelperS()
		end)

		local overlayControl = Instance.new("Frame", primaryControl)
		overlayControl.Size = UDim2.new(1, 0, 0, 38)
		overlayControl.BackgroundTransparency = 1
		overlayControl.BorderSizePixel = 0
		overlayControl.ZIndex = 41
		overlayControl.Active = true
		local label = Instance.new("TextLabel", overlayControl)
		label.Size = UDim2.new(1, -52, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = "070 SPEED BYPASS"
		label.TextColor3 = primaryColor
		label.TextSize = 14
		label.Font = Enum.Font.GothamBlack
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 42
		local headerButton = Instance.new("TextButton", overlayControl)
		headerButton.Size = UDim2.new(1, -50, 1, 0)
		headerButton.BackgroundTransparency = 1
		headerButton.Text = ""
		headerButton.ZIndex = 43
		local toggleButton = Instance.new("TextButton", overlayControl)
		toggleButton.Size = UDim2.new(0, 28, 0, 28)
		toggleButton.Position = UDim2.new(1, -38, 0, 5)
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		toggleButton.BackgroundTransparency = 0
		toggleButton.BorderSizePixel = 0
		toggleButton.Text = ""
		toggleButton.AutoButtonColor = false
		toggleButton.ZIndex = 45
		Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 7)
		local detailControl = Instance.new("UIStroke", toggleButton)
		detailControl.Color = borderColor
		detailControl.Thickness = 1
		detailControl.Transparency = 0.52
		detailControl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local rowContainer = Instance.new("Frame", toggleButton)
		rowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		rowContainer.Size = UDim2.new(0, 5, 0, 2)
		rowContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
		rowContainer.BackgroundColor3 = foregroundColor
		rowContainer.BackgroundTransparency = 0.15
		rowContainer.BorderSizePixel = 0
		rowContainer.ZIndex = 44
		Instance.new("UICorner", rowContainer).CornerRadius = UDim.new(1, 0)

		toggleButton.Activated:Connect(function()
			isSpeedPanelDismissed = true
			featureHelperS()
		end)

		local isComplete = false
			local lastBatV2State = false

		headerButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				isComplete = true
			end
		end)

		if secondaryInput then
			secondaryInput(headerButton, primaryControl)
		end

		UserInputService.InputEnded:Connect(function(input)
			if
				isComplete
-- =====================================================================
-- 070Hub
-- =====================================================================
				and (
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				isComplete = false

				speedPanelPosition = {
					x = math.floor(primaryControl.Position.X.Offset - 115 + 0.5),
					y = math.floor(primaryControl.Position.Y.Offset - 126 + 0.5),
				}

				saveConfig()
			end
		end)

		local innerContainer = Instance.new("Frame", primaryControl)
		innerContainer.Size = UDim2.new(1, -24, 0, 30)
		innerContainer.Position = UDim2.new(0, 12, 0, 38)
		innerContainer.BackgroundTransparency = 1
		innerContainer.ZIndex = 41
		local secondaryControl = Instance.new("TextButton", innerContainer)
		secondaryControl.AnchorPoint = Vector2.new(0.5, 0.5)
		secondaryControl.Size = UDim2.new(0.5, -3, 1, 0)
		secondaryControl.Position = UDim2.new(0.25, -1.5, 0.5, 0)
		secondaryControl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		secondaryControl.BackgroundTransparency = 0
		secondaryControl.BorderSizePixel = 0
		secondaryControl.Text = "PC"
		secondaryControl.TextColor3 = foregroundColor
		secondaryControl.Font = Enum.Font.GothamBlack
		secondaryControl.TextSize = 11
		secondaryControl.ZIndex = 42
		secondaryControl.AutoButtonColor = false
		Instance.new("UICorner", secondaryControl).CornerRadius = UDim.new(0, 8)
		local modeButton = Instance.new("TextButton", innerContainer)
		modeButton.AnchorPoint = Vector2.new(0.5, 0.5)
		modeButton.Size = UDim2.new(0.5, -3, 1, 0)
		modeButton.Position = UDim2.new(0.75, 1.5, 0.5, 0)
		modeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		modeButton.BackgroundTransparency = 0
		modeButton.BorderSizePixel = 0
		modeButton.Text = "MOBILE"
		modeButton.TextColor3 = foregroundColor
		modeButton.Font = Enum.Font.GothamBlack
		modeButton.TextSize = 10
		modeButton.ZIndex = 42
		modeButton.AutoButtonColor = false
		Instance.new("UICorner", modeButton).CornerRadius = UDim.new(0, 8)
		local uiStroke = Instance.new("UIStroke", secondaryControl)
		uiStroke.Color = borderColor
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.52
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local tertiaryControl = Instance.new("UIStroke", modeButton)
		tertiaryControl.Color = borderColor
		tertiaryControl.Thickness = 1
		tertiaryControl.Transparency = 0.52
		tertiaryControl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local uiScale3 = Instance.new("UIScale", secondaryControl)
		uiScale3.Scale = 1
		local uiScale4 = Instance.new("UIScale", modeButton)
		uiScale4.Scale = 1
		local obj2 = setmetatable({}, { __mode = "k" })

		local function featureHelperV(tertiaryInput)
			local calculatedValue = (obj2[tertiaryInput] or 0) + 1
			obj2[tertiaryInput] = calculatedValue
			tertiaryInput.Scale = 0.9
			local tween = TweenService:Create(
				tertiaryInput,
				TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Scale = 1.04 }
			)
			tween:Play()

			tween.Completed:Connect(function()
				if calculatedValue ~= obj2[tertiaryInput] then
					return
				end
				local animationProperties = { Scale = 1 }
				TweenService:Create(
					tertiaryInput,
					TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					animationProperties
				):Play()
			end)
		end

		local function featureHelperW()
			secondaryControl.TextColor3 = foregroundColor
			modeButton.TextColor3 = foregroundColor
			TweenService:Create(
				uiStroke,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Transparency = text == "PC" and 0.12 or 0.52, Thickness = text == "PC" and 1.5 or 1 }
			):Play()

			TweenService
				:Create(tertiaryControl, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = text == "Mobile" and 0.12 or 0.52,
					Thickness = text == "Mobile" and 1.5 or 1,
				})
				:Play()
		end

		local function featureHelperX(tertiaryInput)
			if isKeybindLocked() then
				return
			end

			if text == "PC" then
				desktopBypassPower = speedBypassPower
			else
				mobileBypassPower = speedBypassPower
			end

			text = tertiaryInput
			speedBypassPower = text == "PC" and desktopBypassPower or mobileBypassPower
			featureHelperW()
			featureHelperP()
			featureHelperR()
			saveConfig()
		end

		secondaryControl.Activated:Connect(function()
			featureHelperV(uiScale3)
			featureHelperX("PC")
		end)

		modeButton.Activated:Connect(function()
			featureHelperV(uiScale4)
			featureHelperX("Mobile")
		end)

		featureHelperW()

		local function createFrame(tertiaryInput, labelText)
			local controlContainer = Instance.new("Frame", primaryControl)
			controlContainer.Size = UDim2.new(1, -24, 0, 36)
			controlContainer.Position = UDim2.new(0, 12, 0, tertiaryInput)
			controlContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
			controlContainer.BackgroundTransparency = 0
			controlContainer.BorderSizePixel = 0
			controlContainer.ZIndex = 41
			Instance.new("UICorner", controlContainer).CornerRadius = UDim.new(0, 8)
			local uiStroke2 = Instance.new("UIStroke", controlContainer)
			uiStroke2.Color = borderColor
			uiStroke2.Thickness = 1
			uiStroke2.Transparency = 0.52
-- =====================================================================
-- 070Hub
-- =====================================================================
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local secondaryLabel = Instance.new("TextLabel", controlContainer)
			secondaryLabel.Size = UDim2.new(0.5, 0, 1, 0)
			secondaryLabel.Position = UDim2.new(0, 12, 0, 0)
			secondaryLabel.BackgroundTransparency = 1
			secondaryLabel.Text = labelText
			secondaryLabel.TextColor3 = foregroundColor
			secondaryLabel.TextSize = 11
			secondaryLabel.Font = Enum.Font.GothamBold
			secondaryLabel.TextXAlignment = Enum.TextXAlignment.Left
			secondaryLabel.ZIndex = 42
			return controlContainer
		end

		local uiToggle = createFrame(76, "UI Toggle")
		secondaryButton = Instance.new("TextButton", uiToggle)
		secondaryButton.Size = UDim2.new(0, 50, 0, 28)
		secondaryButton.Position = UDim2.new(1, -58, 0.5, -14)
		secondaryButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		secondaryButton.BackgroundTransparency = 0
		secondaryButton.BorderSizePixel = 0
		secondaryButton.Text = KB.SpeedBypassGui.gp and KB.SpeedBypassGui.gp.Name
			or KB.SpeedBypassGui.kb and KB.SpeedBypassGui.kb.Name
			or "None"
		secondaryButton.TextColor3 = foregroundColor
		secondaryButton.TextSize = 9
		secondaryButton.Font = Enum.Font.GothamBold
		secondaryButton.ZIndex = 42
		secondaryButton.AutoButtonColor = false
		Instance.new("UICorner", secondaryButton).CornerRadius = UDim.new(0, 8)
		local uiStroke2 = Instance.new("UIStroke", secondaryButton)
		uiStroke2.Color = borderColor
		uiStroke2.Thickness = 1
		uiStroke2.Transparency = 0.52
		uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		secondaryButton.Activated:Connect(function()
			if isKeybindLocked() then
				return
			end
			_anyKeyListening = true
			_keyListenBlockUntil = tick() + 0.35
			secondaryButton.Text = "..."
			local isWaitingForInput = true
			local startTime = tick()
			local activeConnection = nil

			activeConnection = UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.Escape then
					isWaitingForInput = false
					_anyKeyListening = false
					local currentItem = 0.25
					_keyListenBlockUntil = tick() + 0.65
					activeConnection:Disconnect()
					featureHelperP()
					return
				end

				local isControllerInput = input.UserInputType and input.UserInputType.Name:match("^Gamepad") ~= nil
				if isControllerInput and tick() - startTime < 0.15 then
					return
				end

				if
					input.KeyCode ~= Enum.KeyCode.Unknown
					and (input.UserInputType == Enum.UserInputType.Keyboard or isControllerInput)
				then
					clearDuplicateKeybind(input.KeyCode, isControllerInput, KB.SpeedBypassGui)

					if isControllerInput then
						KB.SpeedBypassGui.gp = input.KeyCode
						KB.SpeedBypassGui.kb = nil
					else
						KB.SpeedBypassGui.kb = input.KeyCode
						KB.SpeedBypassGui.gp = nil
					end

					isWaitingForInput = false
					_anyKeyListening = false
					local currentItem = 0.25
					_keyListenBlockUntil = tick() + currentItem
					activeConnection:Disconnect()
					refreshAllKeyButtons()
					featureHelperP()
					saveConfig()
				end
			end)

			task.delay(3, function()
				if isWaitingForInput then
					isWaitingForInput = false
					_anyKeyListening = false
					local currentItem = 0.25
					_keyListenBlockUntil = tick() + currentItem

					if activeConnection then
						activeConnection:Disconnect()
					end

					featureHelperP()
				end
			end)
		end)

		local keybind = createFrame(118, "Keybind")
		keybindButton = Instance.new("TextButton", keybind)
		keybindButton.Size = UDim2.new(0, 50, 0, 28)
		keybindButton.Position = UDim2.new(1, -58, 0.5, -14)
		keybindButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		keybindButton.BackgroundTransparency = 0
		keybindButton.BorderSizePixel = 0
		keybindButton.Text = KB.SpeedBypassToggle.gp and KB.SpeedBypassToggle.gp.Name
			or KB.SpeedBypassToggle.kb and KB.SpeedBypassToggle.kb.Name
			or "None"
		keybindButton.TextColor3 = foregroundColor
		keybindButton.TextSize = 9
		keybindButton.Font = Enum.Font.GothamBold
		keybindButton.ZIndex = 42
		keybindButton.AutoButtonColor = false
		Instance.new("UICorner", keybindButton).CornerRadius = UDim.new(0, 8)
		local auxiliaryControl = Instance.new("UIStroke", keybindButton)
		auxiliaryControl.Color = borderColor
		auxiliaryControl.Thickness = 1
		auxiliaryControl.Transparency = 0.52
		auxiliaryControl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local currentItem = createFrame(160, "Speed")
		uiControl = Instance.new("TextBox", currentItem)
		uiControl.Size = UDim2.new(0, 38, 0, 22)
		uiControl.Position = UDim2.new(1, -46, 0.5, -11)
		uiControl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		uiControl.BackgroundTransparency = 0
		uiControl.BorderSizePixel = 0
		uiControl.Text = tostring(speedBypassPower)
		uiControl.TextColor3 = foregroundColor
		uiControl.TextSize = 9
		uiControl.Font = Enum.Font.GothamBold
		uiControl.ClearTextOnFocus = false
		uiControl.ZIndex = 42
		Instance.new("UICorner", uiControl).CornerRadius = UDim.new(0, 7)
		local uiStroke3 = Instance.new("UIStroke", uiControl)
		uiStroke3.Color = borderColor
		uiStroke3.Thickness = 1
		uiStroke3.Transparency = 0.52
		uiStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		uiControl.FocusLost:Connect(function()
			local numericValue = tonumber(uiControl.Text)

			if numericValue then
				speedBypassPower = math.floor(math.clamp(numericValue, 10000, text == "PC" and 150000 or 100000))
-- =====================================================================
-- 070Hub
-- =====================================================================
			else
				speedBypassPower = text == "PC" and 97000 or 72000
			end

			if text == "PC" then
				desktopBypassPower = speedBypassPower
			else
				mobileBypassPower = speedBypassPower
			end

			featureHelperP()
			featureHelperR()
			saveConfig()
		end)

		keybindButton.Activated:Connect(function()
			if isKeybindLocked() then
				return
			end
			_anyKeyListening = true
			_keyListenBlockUntil = tick() + 0.35
			keybindButton.Text = "..."
			local isWaitingForInput = true
			local startTime = tick()
			local activeConnection = nil

			activeConnection = UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.Escape then
					isWaitingForInput = false
					_anyKeyListening = false
					local targetObject = 0.25
					_keyListenBlockUntil = tick() + targetObject
					activeConnection:Disconnect()
					featureHelperP()
					return
				end

				local isControllerInput = input.UserInputType and input.UserInputType.Name:match("^Gamepad") ~= nil
				if isControllerInput and tick() - startTime < 0.15 then
					return
				end

				if
					input.KeyCode ~= Enum.KeyCode.Unknown
					and (input.UserInputType == Enum.UserInputType.Keyboard or isControllerInput)
				then
					clearDuplicateKeybind(input.KeyCode, isControllerInput, KB.SpeedBypassToggle)

					if isControllerInput then
						KB.SpeedBypassToggle.gp = input.KeyCode
						KB.SpeedBypassToggle.kb = nil
					else
						KB.SpeedBypassToggle.kb = input.KeyCode
						KB.SpeedBypassToggle.gp = nil
					end

					isWaitingForInput = false
					_anyKeyListening = false
					_keyListenBlockUntil = tick() + 0.25
					activeConnection:Disconnect()
					refreshAllKeyButtons()
					featureHelperP()
					saveConfig()
				end
			end)

			task.delay(3, function()
				if isWaitingForInput then
					isWaitingForInput = false
					_anyKeyListening = false
					_keyListenBlockUntil = tick() + 0.25

					if activeConnection then
						activeConnection:Disconnect()
					end

					featureHelperP()
				end
			end)
		end)

		local enableButton = Instance.new("TextButton", primaryControl)
		enableButton.AnchorPoint = Vector2.new(0.5, 0.5)
		enableButton.Size = UDim2.new(1, -24, 0, 38)
		enableButton.Position = UDim2.new(0.5, 0, 0, 223)
		enableButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		enableButton.BackgroundTransparency = 0
		enableButton.BorderSizePixel = 0
		enableButton.Text = "DISABLED"
		enableButton.TextColor3 = foregroundColor
		enableButton.TextSize = 11
		enableButton.Font = Enum.Font.GothamBold
		enableButton.ZIndex = 42
		enableButton.AutoButtonColor = false
		Instance.new("UICorner", enableButton).CornerRadius = UDim.new(0, 7)
		local uiStroke4 = Instance.new("UIStroke", enableButton)
		uiStroke4.Color = borderColor
		uiStroke4.Thickness = 1
		uiStroke4.Transparency = 0.52
		uiStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local uiScale5 = Instance.new("UIScale", enableButton)
		uiScale5.Scale = 1
		local targetObject = isSpeedBypassEnabled
		local uiElement = 0

		updateSpeedBypassVisual = function(tertiaryInput)
			enableButton.Text = tertiaryInput and "ENABLED" or "DISABLED"
			enableButton.TextColor3 = foregroundColor
			enableButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			uiStroke4.Color = borderColor
			if targetObject == tertiaryInput then
				return
			end
			targetObject = tertiaryInput
			uiElement = uiElement + 1
			local stateToken = uiElement
			local calculatedValue = tertiaryInput and 1.5 or 1
			tertiaryInput = tertiaryInput and 0.12 or 0.52
			uiScale5.Scale = 0.9
			uiStroke4.Thickness = 2.5
			uiStroke4.Transparency = 0.04
			enableButton.TextTransparency = 0.45
			local tween = TweenService:Create(
				uiScale5,
				TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Scale = 1.04 }
			)
			tween:Play()
			TweenService:Create(
				enableButton,
				TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 0 }
			):Play()
			TweenService:Create(
				uiStroke4,
				TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Thickness = calculatedValue, Transparency = tertiaryInput }
			):Play()

			tween.Completed:Connect(function()
				if stateToken ~= uiElement then
					return
				end
				TweenService
					:Create(
						uiScale5,
						TweenInfo.new(0.17, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{ Scale = 1 }
					)
					:Play()
-- =====================================================================
-- 070Hub
-- =====================================================================
			end)
		end

		enableButton.Activated:Connect(function()
			if isKeybindLocked() then
				return
			end
			featureHelperQ()
		end)

		speedModeLabel = nil
		featureHelperP()
		featureHelperS()
	end

	saveConfig = function()
		return getgenv()._070SaveAll()
	end

	setInstaGrab = nil
	setInfJumpVisual = nil
	setAntiRagVisual = nil
	setMedusaVisual = nil
	setAutoSwingVisual = nil
	setMirrorTPVisual = nil
	normalBox = nil
	carryBox = nil
	laggerBox = nil
	laggerCarryBox = nil
	radInput = nil
	autoBatSpeedBox = nil
	bypassAutoBatSpeedBox = nil
	laggerAutoBatSpeedBox = nil
	bypassLaggerAutoBatSpeedBox = nil
	autoTPHeightBox = nil
	fieldOfViewBox = nil
	scaleBox = nil
	mainGuiScale = nil
	modeValLbl = nil

	refreshSpeedModeLabel = function()
		if modeValLbl then
			modeValLbl.Text = laggerToggled and (laggerPhase == 2 and "Lagger Carry" or "Lagger")
				or speedMode and "Carry"
				or "Normal"
		end
	end

	toggleCarryMode = function()
		if laggerToggled then
			laggerToggled = false
			laggerPhase = 0
			speedMode = true
		else
			speedMode = not speedMode
		end

-- =====================================================================
-- 070Hub
-- =====================================================================
		refreshSpeedModeLabel()
		saveConfig()
	end

	toggleLaggerMode = function()
		if not laggerToggled then
			speedMode = false
			laggerToggled = true
			laggerPhase = 2
		elseif laggerPhase == 2 then
			laggerPhase = 1
		else
			laggerPhase = 2
		end

		refreshSpeedModeLabel()
		saveConfig()
	end

	local function featureHelperV(inputValue)
		if laggerToggled and laggerPhase == inputValue then
			laggerToggled = false
			laggerPhase = 0
		else
			speedMode = false
			laggerToggled = true
			laggerPhase = inputValue
		end

		refreshSpeedModeLabel()
	end

	buildGui = function()
		local foregroundColor
		foregroundColor = Color3.fromRGB(15, 35, 75)
		local borderColor
		borderColor = Color3.fromRGB(20, 20, 26)
		local panelColor
		panelColor = Color3.fromRGB(45, 45, 62)
		local textColor
		textColor = Color3.fromRGB(255, 255, 255)
		removeExistingVisionGui()
		local screenGui
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "070HubMobile"
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 10
		screenGui.IgnoreGuiInset = true

		if not pcall(function()
			screenGui.Parent = game:GetService("CoreGui")
		end) then
			screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
		end
		-- YEN protect main hub GUI (anti-copy, no gameplay impact)
		pcall(function()
			if getgenv().__yenProtectGui then
				getgenv().__yenProtectGui(screenGui)
			elseif getgenv().__YEN and getgenv().__YEN.protect then
				getgenv().__YEN.protect(screenGui)
			end
		end)

		local featureHelperW

		featureHelperW = function(inputValue, secondaryInput, tertiaryInput)
			local primaryValue = secondaryInput or inputValue
			local isActive = nil
			local worldPosition = nil
			local absolutePosition = nil
			local secondaryPosition = nil

			local function featureHelperX(fourthInput, fifthInput)
				local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
					or Vector2.new(1920, 1080)
				local absoluteSize = primaryValue.AbsoluteSize

				if absoluteSize.X <= 0 then
					absoluteSize = Vector2.new(primaryValue.Size.X.Offset, absoluteSize.Y)
				end

				if absoluteSize.Y <= 0 then
					absoluteSize = Vector2.new(absoluteSize.X, primaryValue.Size.Y.Offset)
				end

				return math.clamp(fourthInput, 0, math.max(0, viewportSize.X - absoluteSize.X)),
					math.clamp(fifthInput, 0, math.max(0, viewportSize.Y - absoluteSize.Y))
			end

			local function featureHelperY(fourthInput, fifthInput)
				local secondaryValue, currentObject = featureHelperX(fourthInput, fifthInput)
				local absoluteSize = primaryValue.AbsoluteSize

				if absoluteSize.X <= 0 then
					absoluteSize = Vector2.new(primaryValue.Size.X.Offset, absoluteSize.Y)
				end

				if absoluteSize.Y <= 0 then
					absoluteSize = Vector2.new(absoluteSize.X, primaryValue.Size.Y.Offset)
				end

				local anchorPoint = primaryValue.AnchorPoint or Vector2.zero
				primaryValue.Position = UDim2.fromOffset(
					secondaryValue + absoluteSize.X * anchorPoint.X,
					currentObject + absoluteSize.Y * anchorPoint.Y
				)
			end

			inputValue.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					isActive = true
					worldPosition = input.Position
					absolutePosition = primaryValue.AbsolutePosition
					secondaryPosition = primaryValue.Position
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					isActive = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if not isActive then
					return
				end

				if
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				then
					local amount = input.Position - worldPosition

					if tertiaryInput then
						featureHelperY(absolutePosition.X + amount.X, absolutePosition.Y + amount.Y)
					else
						primaryValue.Position = UDim2.new(
							secondaryPosition.X.Scale,
							secondaryPosition.X.Offset + amount.X,
							secondaryPosition.Y.Scale,
							secondaryPosition.Y.Offset + amount.Y
						)
					end
				end
			end)

			if tertiaryInput then
				task.defer(function()
					featureHelperY(primaryValue.AbsolutePosition.X, primaryValue.AbsolutePosition.Y)
				end)
			end
		end

-- =====================================================================
-- 070Hub
-- =====================================================================
		featureHelperU(screenGui, featureHelperW)
		local primaryControl
		primaryControl = Instance.new("Frame", screenGui)
		primaryControl.Size = UDim2.new(0, 430, 0, 460)
		primaryControl.AnchorPoint = Vector2.new(0.5, 0.5)
		primaryControl.Position = UDim2.new(0, 215, 0, 310)
		primaryControl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		primaryControl.BackgroundTransparency = 1
		primaryControl.BorderSizePixel = 0
		primaryControl.ClipsDescendants = true
		Instance.new("UICorner", primaryControl).CornerRadius = UDim.new(0, 16)
		do
			local hubBg = Instance.new("ImageLabel")
			hubBg.Name = "070HubBackground"
			hubBg.Size = UDim2.fromScale(1, 1)
			hubBg.Position = UDim2.fromScale(0, 0)
			hubBg.BackgroundTransparency = 1
			hubBg.BorderSizePixel = 0
			hubBg.Image = "rbxassetid://103010175848787"
			hubBg.ScaleType = Enum.ScaleType.Crop
			hubBg.ImageTransparency = 0
			hubBg.ZIndex = 1
			hubBg.ClipsDescendants = true
			hubBg.Parent = primaryControl
			-- match main window corner radius so wallpaper is curved, not sharp
			local bgCorner = Instance.new("UICorner")
			bgCorner.Name = "HubBgCorner"
			bgCorner.CornerRadius = UDim.new(0, 16)
			bgCorner.Parent = hubBg
			getgenv()._070HubBackground = hubBg
			primaryControl.ClipsDescendants = true
		end
		-- Hub background image (forced visible)
		do
			pcall(function()
				screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			end)
			-- backgrounds removed (Visible Hub style solid blue glass)
		end
		mainGuiScale = Instance.new("UIScale", primaryControl)
		mainGuiScale.Scale = uiScaleValue / 100
		primaryControl.Visible = false
		local floatingButton

		do
			local rowContainer = Instance.new("Frame", primaryControl)
			rowContainer.Size = UDim2.new(1, 0, 0, 44)
			rowContainer.Position = UDim2.new(0, 0, 0, 0)
			rowContainer.BackgroundTransparency = 1
			rowContainer.BorderSizePixel = 0
			rowContainer.ZIndex = 5
			featureHelperW(rowContainer, primaryControl)
			local label = Instance.new("TextLabel", rowContainer)
			label.Size = UDim2.new(1, -92, 0, 24)
			label.Position = UDim2.new(0, 18, 0, 10)
			label.BackgroundTransparency = 1
			label.Text = "070Hub"
			label.TextColor3 = Color3.fromRGB(120, 100, 255)
			label.Font = Enum.Font.GothamBlack
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextStrokeTransparency = 1
			label.ZIndex = 6
			floatingButton = Instance.new("TextButton", rowContainer)
		end

		floatingButton.Size = UDim2.new(0, 28, 0, 28)
		floatingButton.Position = UDim2.new(1, -42, 0, 8)
		floatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		floatingButton.BackgroundTransparency = 0
		floatingButton.BorderSizePixel = 0
		floatingButton.Text = ""
		floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		floatingButton.Font = Enum.Font.Gotham
		floatingButton.TextSize = 18
		floatingButton.AutoButtonColor = false
		floatingButton.ZIndex = 10
		Instance.new("UICorner", floatingButton).CornerRadius = UDim.new(0, 7)
		local uiStroke = Instance.new("UIStroke", floatingButton)
		uiStroke.Color = Color3.fromRGB(34, 34, 40)
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.52
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local gradientControl = Instance.new("Frame", floatingButton)
		gradientControl.AnchorPoint = Vector2.new(0.5, 0.5)
		gradientControl.Size = UDim2.new(0, 5, 0, 2)
		gradientControl.Position = UDim2.new(0.5, 0, 0.5, 0)
		gradientControl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		gradientControl.BackgroundTransparency = 0.04
		gradientControl.BorderSizePixel = 0
		gradientControl.ZIndex = 11
		Instance.new("UICorner", gradientControl).CornerRadius = UDim.new(1, 0)

		floatingButton.MouseEnter:Connect(function()
			TweenService:Create(
				floatingButton,
				TweenInfo.new(0.12),
				{ BackgroundTransparency = 0.06, TextColor3 = Color3.fromRGB(255, 255, 255) }
			):Play()
		end)

		floatingButton.MouseLeave:Connect(function()
			TweenService:Create(
				floatingButton,
				TweenInfo.new(0.12),
				{ BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255) }
			):Play()
		end)

		local headerButton
		headerButton = Instance.new("TextButton", screenGui)
		headerButton.Size = UDim2.new(0, 110, 0, 31)
		headerButton.AnchorPoint = Vector2.new(1, 0)
		headerButton.Position = UDim2.new(1, -20, 0, 8)
		headerButton.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
		headerButton.BackgroundTransparency = 0.08
		headerButton.BorderSizePixel = 0
		headerButton.AutoButtonColor = false
		headerButton.ZIndex = 30
		headerButton.ClipsDescendants = true
		headerButton.Text = "070Hub"
		headerButton.Font = Enum.Font.GothamBlack
		headerButton.TextSize = 13
		headerButton.TextColor3 = Color3.fromRGB(110, 130, 255)
		headerButton.TextTransparency = 0
		headerButton.Visible = false
		getgenv()._070HeaderButton = headerButton
		Instance.new("UICorner", headerButton).CornerRadius = UDim.new(0, 12)
		do
			local g = Instance.new("UIGradient")
			g.Name = "070HeaderGrad"
			g.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 100, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 160, 255)),
			})
			g.Rotation = 0
			g.Parent = headerButton
			local st = Instance.new("UIStroke")
			st.Color = Color3.fromRGB(70, 160, 255)
			st.Thickness = 1.2
			st.Transparency = 0.35
			st.Parent = headerButton
		end
		local strokeControl
		strokeControl = Instance.new("UIScale", headerButton)
		strokeControl.Scale = 1
		local imageLabel, overlayControl, primaryValue, featureHelperX, featureHelperY, featureHelperZ, createFrame

		do
			local uiGradient = Instance.new("UIGradient", headerButton)
			local colorSequence = ColorSequence.new
			local workingData = {}
			local secondaryValue = ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 48, 95))
			local currentObject = ColorSequenceKeypoint.new(0.48, Color3.fromRGB(10, 10, 14))
			local new = ColorSequenceKeypoint.new
			local currentItem = 1
			local gradientColor = Color3.fromRGB
			workingData[1] = secondaryValue
			workingData[2] = currentObject

			do
				local values = table.pack(new(currentItem, gradientColor(28, 28, 34)))
				table.move(values, 1, values.n, 3, workingData)
			end

			uiGradient.Color = colorSequence(workingData)
			uiGradient.Rotation = 14
			imageLabel = Instance.new("ImageLabel", headerButton)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = ""
			imageLabel.ScaleType = Enum.ScaleType.Stretch
			imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			imageLabel.ImageTransparency = 0
			imageLabel.ZIndex = 34
			Instance.new("UICorner", imageLabel).CornerRadius = UDim.new(0, 12)

			-- logo image disabled; show text name only
			pcall(function()
				if imageLabel then
					imageLabel.Image = ""
					imageLabel.Visible = false
				end
			end)
			pcall(function()
				if headerButton then
					local isHalloween = false
					local pillText = isHalloween and Color3.fromRGB(140, 160, 255) or Color3.fromRGB(120, 100, 255)
					headerButton.Text = "070Hub"
					headerButton.TextColor3 = pillText
					headerButton.Font = Enum.Font.GothamBold
					headerButton.TextSize = 14
					headerButton.BackgroundColor3 = isHalloween and Color3.fromRGB(30, 10, 8) or Color3.fromRGB(8, 14, 30)
					headerButton.Visible = true
					for _, c in ipairs(headerButton:GetDescendants()) do
						if c:IsA("TextLabel") or c:IsA("TextButton") then
							c.Text = "070Hub"
							c.Visible = true
							c.TextColor3 = pillText
						end
					end
				end
			end)

			overlayControl = Instance.new("UIStroke", headerButton)
			overlayControl.Color = Color3.fromRGB(210, 210, 218)
			overlayControl.Thickness = 2
			overlayControl.Transparency = 0.18
			featureHelperW(headerButton)
			primaryValue = showUIOnExecute
			local amount = 0
			local targetObject = nil
			local secondaryDirection = Vector2.zero
			local activeConnection = nil

-- =====================================================================
-- 070Hub
-- =====================================================================
			local function featureHelperAA(inputValue)
				if inputValue ~= amount or not primaryValue or not targetObject then
					return
				end
				local calculatedValue =
					math.max(0, targetObject.AbsoluteCanvasSize.Y - targetObject.AbsoluteWindowSize.Y)
				targetObject.CanvasPosition =
					Vector2.new(secondaryDirection.X, math.clamp(secondaryDirection.Y, 0, calculatedValue))
			end

			featureHelperX = function(inputValue)
				amount = amount + 1
				local uiElement = amount

				if activeConnection then
					activeConnection:Disconnect()
					activeConnection = nil
				end

				if not inputValue and targetObject then
					secondaryDirection = targetObject.CanvasPosition
				end

				primaryValue = inputValue

				if inputValue then
							headerButton.BackgroundTransparency = 1
					headerButton.TextColor3 = (_G.__070AnimColor or primaryColor)
					strokeControl.Scale = 1
					imageLabel.ImageTransparency = 0
					overlayControl.Transparency = 1
					overlayControl.Thickness = 0
					primaryControl.AnchorPoint = Vector2.new(0.5, 0.5)
					primaryControl.BackgroundTransparency = 0.02
					mainGuiScale.Scale = uiScaleValue / 100 * 0.82
					featureHelperAA(uiElement)
					primaryControl.Visible = true
					if headerButton then
						headerButton.Visible = false
						headerButton.Text = ""
						headerButton.TextTransparency = 1
						headerButton.BackgroundTransparency = 1
					end

					activeConnection = RunService.RenderStepped:Connect(function()
						featureHelperAA(uiElement)
					end)

					local animationProperties = { Scale = uiScaleValue / 100 }
					local tween = TweenService:Create(
						mainGuiScale,
						TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						animationProperties
					)
					tween:Play()

					tween.Completed:Connect(function()
						if uiElement ~= amount then
							return
						end
						featureHelperAA(uiElement)

						if activeConnection then
							activeConnection:Disconnect()
							activeConnection = nil
						end
					end)
				else
					-- minimized floating pill
					local isHalloween = false
					local pillBg = isHalloween and Color3.fromRGB(30, 10, 8) or Color3.fromRGB(8, 14, 30)
					local pillText = isHalloween and Color3.fromRGB(140, 160, 255) or Color3.fromRGB(120, 100, 255)
					local pillStroke = isHalloween and Color3.fromRGB(255, 175, 80) or Color3.fromRGB(70, 170, 255)

					headerButton.Visible = true
					headerButton.Text = "070Hub"
					headerButton.Font = Enum.Font.GothamBold
					headerButton.TextSize = 14
					headerButton.TextColor3 = pillText
					headerButton.TextTransparency = 0
					headerButton.BackgroundColor3 = pillBg
					headerButton.BackgroundTransparency = 0.02
					headerButton.AutoButtonColor = false

					if imageLabel then
						imageLabel.Visible = false
						imageLabel.ImageTransparency = 1
					end
					if strokeControl then
						strokeControl.Scale = 1
					end
					if overlayControl then
						overlayControl.Color = pillStroke
						overlayControl.Thickness = 1.5
						overlayControl.Transparency = 0.25
					end

					local scaleProperties = { Scale = uiScaleValue / 100 * 0.82 }
					local tween = TweenService:Create(
						mainGuiScale,
						TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						scaleProperties
					)
					tween:Play()

					tween.Completed:Connect(function()
						if uiElement == amount and not primaryValue then
							primaryControl.Visible = false
							mainGuiScale.Scale = uiScaleValue / 100
							-- keep pill colors after panel hides
							headerButton.TextColor3 = pillText
							headerButton.BackgroundColor3 = pillBg
							headerButton.BackgroundTransparency = 0.05
						end
					end)
				end

				TweenService:Create(uiGradient, TweenInfo.new(0.22), { Rotation = inputValue and 18 or -18 }):Play()
			end

			floatingButton.Activated:Connect(function()
				featureHelperX(false)
			end)

			local function featureHelperAB()
				strokeControl.Scale = 0.9
				TweenService:Create(
					strokeControl,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end

			headerButton.Activated:Connect(function()
				featureHelperX(not primaryValue)
				featureHelperAB()
			end)

			featureHelperY = function()
				amount = amount + 1
				primaryControl.Visible = true
				headerButton.BackgroundTransparency = 1
				headerButton.TextTransparency = 1
				headerButton.Text = ""
				headerButton.Visible = false
				overlayControl.Transparency = 1
				overlayControl.Thickness = 0
				primaryControl.AnchorPoint = Vector2.new(0.5, 0.5)
				primaryControl.BackgroundTransparency = 0.35
				mainGuiScale.Scale = uiScaleValue / 100 * 0.72

				for _, uiElement in ipairs(qaFrames) do
					local stateToken = uiElement:FindFirstChildOfClass("UIScale")

					if stateToken then
						stateToken.Scale = uiScaleValue / 100
					end
				end

				TweenService:Create(
					mainGuiScale,
					TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = uiScaleValue / 100 }
				):Play()
				TweenService:Create(
					primaryControl,
					TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 0.02 }
				):Play()
				-- cascade visible rows
				task.defer(function()
					local sf = scrollingFrame
					if not sf then return end
					local delay = 0
					local kids = {}
					for _, ch in ipairs(sf:GetChildren()) do
						if ch:IsA("Frame") and ch.Visible then
							table.insert(kids, ch)
						end
					end
					table.sort(kids, function(a, b) return (a.LayoutOrder or 0) < (b.LayoutOrder or 0) end)
					for _, ch in ipairs(kids) do
						local t0 = ch.BackgroundTransparency
						ch.BackgroundTransparency = 1
						task.delay(delay, function()
							if ch and ch.Parent then
								TweenService:Create(ch, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									BackgroundTransparency = math.clamp(t0 < 1 and t0 or 0.34, 0.15, 0.5)
								}):Play()
							end
						end)
						delay = delay + 0.025
					end
				end)
			end
-- =====================================================================
-- 070Hub
-- =====================================================================

			-- accent pulse line under header
			do
				local pulse = Instance.new("Frame", primaryControl)
				pulse.Name = "AccentPulseBar"
				pulse.Size = UDim2.new(0.35, 0, 0, 2)
				pulse.Position = UDim2.new(0.325, 0, 0, 42)
				pulse.BackgroundColor3 = primaryColor
				pulse.BorderSizePixel = 0
				pulse.ZIndex = 25
				Instance.new("UICorner", pulse).CornerRadius = UDim.new(1, 0)
				task.spawn(function()
					while pulse and pulse.Parent do
						local tw = TweenService:Create(pulse, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							Position = UDim2.new(0.55, 0, 0, 42),
							BackgroundTransparency = 0.15
						})
						tw:Play(); tw.Completed:Wait()
						if not pulse.Parent then break end
						tw = TweenService:Create(pulse, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							Position = UDim2.new(0.1, 0, 0, 42),
							BackgroundTransparency = 0.45
						})
						tw:Play(); tw.Completed:Wait()
					end
				end)
			end

			-- LEFT sidebar tabs: 2 top, avatar mid, 2 bottom
			local SIDE_W = 86
			local tabBarFrame = Instance.new("Frame", primaryControl)
			tabBarFrame.Name = "CategoryTabs"
			tabBarFrame.Size = UDim2.new(0, SIDE_W, 1, -48)
			tabBarFrame.Position = UDim2.new(0, 6, 0, 42)
			tabBarFrame.BackgroundTransparency = 1
			tabBarFrame.BorderSizePixel = 0
			tabBarFrame.ZIndex = 20
			tabBarFrame.ClipsDescendants = false

			local function makeCatTab(name, parent, order)
				local b = Instance.new("TextButton", parent)
				b.Name = "Tab_" .. name
				b.Size = UDim2.new(1, -10, 0, 36)
				b.BackgroundColor3 = Color3.fromRGB(22, 20, 32)
				b.BackgroundTransparency = 1
				b.Text = name
				b.TextColor3 = Color3.fromRGB(140, 140, 155)
				b.Font = Enum.Font.GothamBold
				b.TextSize = 10
				b.TextWrapped = true
				b.AutoButtonColor = false
				b.ZIndex = 21
				b.LayoutOrder = order or 0
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
				local st = Instance.new("UIStroke", b)
				st.Name = "TabStroke"
				st.Color = Color3.fromRGB(120, 100, 255)
				st.Thickness = 1
				st.Transparency = 1
				local und = Instance.new("Frame", b)
				und.Name = "Underline"
				und.AnchorPoint = Vector2.new(0, 0.5)
				und.Position = UDim2.new(0, 2, 0.5, 0)
				und.Size = UDim2.new(0, 0, 0, 14)
				und.BackgroundColor3 = Color3.fromRGB(140, 120, 255)
				und.BorderSizePixel = 0
				und.ZIndex = 22
				Instance.new("UICorner", und).CornerRadius = UDim.new(1, 0)
				return b
			end

			-- Top two tabs (tight under top)
			local topTabs = Instance.new("Frame", tabBarFrame)
			topTabs.Name = "TopTabs"
			topTabs.Size = UDim2.new(1, 0, 0, 98)
			topTabs.Position = UDim2.new(0, 0, 0, 6)
			topTabs.BackgroundTransparency = 1
			topTabs.ZIndex = 21
			local topLay = Instance.new("UIListLayout", topTabs)
			topLay.FillDirection = Enum.FillDirection.Vertical
			topLay.Padding = UDim.new(0, 5)
			topLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
			topLay.SortOrder = Enum.SortOrder.LayoutOrder
			local topPad = Instance.new("UIPadding", topTabs)
			topPad.PaddingLeft = UDim.new(0, 4)
			topPad.PaddingRight = UDim.new(0, 4)

			-- Avatar circle (middle) — face-forward, well lit
			local avatarHolder = Instance.new("Frame", tabBarFrame)
			avatarHolder.Name = "AvatarHolder"
			avatarHolder.Size = UDim2.fromOffset(62, 62)
			avatarHolder.AnchorPoint = Vector2.new(0.5, 0.5)
			avatarHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
			avatarHolder.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
			avatarHolder.BackgroundTransparency = 1
			avatarHolder.BorderSizePixel = 0
			avatarHolder.ZIndex = 22
			avatarHolder.ClipsDescendants = true
			Instance.new("UICorner", avatarHolder).CornerRadius = UDim.new(1, 0)
			local avStroke = Instance.new("UIStroke", avatarHolder)
			avStroke.Color = Color3.fromRGB(150, 130, 255)
			avStroke.Thickness = 2
			avStroke.Transparency = 0.15
			local avatarVp = Instance.new("ViewportFrame", avatarHolder)
			avatarVp.Name = "AvatarViewport"
			avatarVp.Size = UDim2.fromScale(1, 1)
			avatarVp.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
			avatarVp.BackgroundTransparency = 1
			avatarVp.BorderSizePixel = 0
			avatarVp.ZIndex = 23
			avatarVp.Ambient = Color3.fromRGB(230, 230, 245)
			avatarVp.LightColor = Color3.fromRGB(255, 255, 255)
			avatarVp.LightDirection = Vector3.new(0, -0.5, -1)
			Instance.new("UICorner", avatarVp).CornerRadius = UDim.new(1, 0)
			getgenv()._070AvatarViewport = avatarVp
			getgenv()._070AvatarHolder = avatarHolder

			-- Bottom two tabs (tight from bottom)
			local botTabs = Instance.new("Frame", tabBarFrame)
			botTabs.Name = "BotTabs"
			botTabs.Size = UDim2.new(1, 0, 0, 98)
			botTabs.Position = UDim2.new(0, 0, 1, -104)
			botTabs.BackgroundTransparency = 1
			botTabs.ZIndex = 21
			local botLay = Instance.new("UIListLayout", botTabs)
			botLay.FillDirection = Enum.FillDirection.Vertical
			botLay.Padding = UDim.new(0, 5)
			botLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
			botLay.SortOrder = Enum.SortOrder.LayoutOrder
			local botPad = Instance.new("UIPadding", botTabs)
			botPad.PaddingLeft = UDim.new(0, 4)
			botPad.PaddingRight = UDim.new(0, 4)

			-- Avatar face (static headshot, slightly zoomed out)
			task.spawn(function()
				if not avatarHolder then return end
				-- hide 3d viewport if present
				if avatarVp then
					avatarVp.Visible = false
					avatarVp.BackgroundTransparency = 1
				end
				avatarHolder.BackgroundTransparency = 1
				avatarHolder.ClipsDescendants = true

				local headshot = avatarHolder:FindFirstChild("AvatarHeadshot")
				if not headshot then
					headshot = Instance.new("ImageLabel")
					headshot.Name = "AvatarHeadshot"
					headshot.Parent = avatarHolder
				end
				headshot.BackgroundTransparency = 1
				headshot.BorderSizePixel = 0
				headshot.ZIndex = 23
				headshot.ScaleType = Enum.ScaleType.Crop
				headshot.Visible = true
				-- slightly zoomed out so full face + a bit of shoulders show
				headshot.Size = UDim2.fromScale(1.15, 1.15)
				headshot.Position = UDim2.fromScale(-0.075, -0.04)
				Instance.new("UICorner", headshot).CornerRadius = UDim.new(1, 0)
				-- ensure only one corner
				for _, c in ipairs(headshot:GetChildren()) do
					if c:IsA("UICorner") and c ~= headshot:FindFirstChildOfClass("UICorner") then
						pcall(function() c:Destroy() end)
					end
				end
				if not headshot:FindFirstChildOfClass("UICorner") then
					Instance.new("UICorner", headshot).CornerRadius = UDim.new(1, 0)
				end

				local function setHeadshot()
					local uid = localPlayer.UserId
					-- Avatar bust is slightly more zoomed out than HeadShot
					headshot.Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=420&h=420", uid)
					headshot.ImageTransparency = 0
				end
				setHeadshot()
				localPlayer.CharacterAdded:Connect(function()
					task.delay(0.5, setHeadshot)
					task.delay(2, setHeadshot)
				end)
				getgenv()._070ReloadAvatar = setHeadshot
			end)

			local scrollingFrame = Instance.new("ScrollingFrame", primaryControl)
			targetObject = scrollingFrame
			scrollingFrame.Size = UDim2.new(1, -(SIDE_W + 14), 1, -56)
			scrollingFrame.Position = UDim2.new(0, SIDE_W + 10, 0, 48)
			scrollingFrame.BackgroundTransparency = 1
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.ClipsDescendants = true
			scrollingFrame.ScrollBarThickness = 0
			scrollingFrame.ScrollBarImageTransparency = 1
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			local uiListLayout = Instance.new("UIListLayout", scrollingFrame)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Padding = UDim.new(0, 6)
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			local uiPadding = Instance.new("UIPadding", scrollingFrame)
			uiPadding.PaddingLeft = UDim.new(0, 16)
			uiPadding.PaddingRight = UDim.new(0, 16)
			uiPadding.PaddingTop = UDim.new(0, 6)
			uiPadding.PaddingBottom = UDim.new(0, 20)
			local calculatedValue = 0

			local function featureHelperLayoutOrder()
				calculatedValue = calculatedValue + 1
				return calculatedValue
			end

			-- K9RS-style tabs: MOVEMENT / COMBAT / VISUAL
			local currentSectionCategory = "MOVEMENT"
			local sectionToCategory = {
				["Normal Mode"] = "MOVEMENT",
				["Lagger Mode"] = "MOVEMENT",
				["Speed Mode"] = "MOVEMENT",
				["Automation"] = "COMBAT",
				["Bat Aimbot"] = "COMBAT",
				["Drop"] = "COMBAT",
				["Teleport"] = "COMBAT",
				["Defense"] = "COMBAT",
				["Counters"] = "COMBAT",
				["Performance"] = "VISUAL",
				["UI Settings"] = "CONFIG",
				["Mobile UI Settings"] = "CONFIG",
				["Animations"] = "VISUAL",
				["Settings"] = "CONFIG",
			}
			getgenv()._070ActiveTab = "MOVEMENT"
			local tabButtons = {}

			local _tabAnimToken = 0
			local _sfBasePos = scrollingFrame.Position
			local function applyCategoryFilterRaw()
				local active = tostring(getgenv()._070ActiveTab or "MOVEMENT")
				local kids = {}
				for _, child in ipairs(scrollingFrame:GetChildren()) do
					if child:IsA("Frame") then
						table.insert(kids, child)
					end
				end
				table.sort(kids, function(a, b)
					return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
				end)
				local lastCat = "MOVEMENT"
				for _, child in ipairs(kids) do
					local cat = child:GetAttribute("070Category")
					if cat and cat ~= "" then
						lastCat = cat
					else
						child:SetAttribute("070Category", lastCat)
						cat = lastCat
					end
					local show = (cat == active)
					if not show then
						child.Visible = false
					else
						local isDetail = false
						pcall(function()
							if type(autoStealDetailsRows) == "table" then
								for _, r in ipairs(autoStealDetailsRows) do
									if r == child then isDetail = true break end
								end
							end
							if type(autoBatDetailsRows) == "table" then
								for _, r in ipairs(autoBatDetailsRows) do
									if r == child then isDetail = true break end
								end
							end
						end)
						if isDetail then
							local open = false
							pcall(function()
								if autoStealDetailsOpen and type(autoStealDetailsRows) == "table" then
									for _, r in ipairs(autoStealDetailsRows) do
										if r == child then open = autoStealDetailsOpen break end
									end
								end
								if autoBatDetailsOpen and type(autoBatDetailsRows) == "table" then
									for _, r in ipairs(autoBatDetailsRows) do
										if r == child then open = autoBatDetailsOpen break end
									end
								end
							end)
							if open then
								child.Visible = true
								if child.AbsoluteSize.Y < 8 or child.Size.Y.Offset == 0 then
									local h = child:GetAttribute("AutoStealSelectorRow") and 32 or 40
									if child:GetAttribute("AutoBatSelectorRow") then h = 40 end
									child.Size = UDim2.new(1, 0, 0, h)
									child.BackgroundTransparency = child:GetAttribute("AutoStealSelectorRow") and 1 or 0.34
								end
							else
								child.Visible = false
								child.Size = UDim2.new(1, 0, 0, 0)
							end
						else
							child.Visible = true
						end
					end
				end
			end

			local function applyCategoryFilter(skipAnim)
				if skipAnim == true then
					applyCategoryFilterRaw()
					scrollingFrame.Position = _sfBasePos
					return
				end
				_tabAnimToken = _tabAnimToken + 1
				local token = _tabAnimToken
				-- slide out toward left tabs
				local outPos = UDim2.new(
					_sfBasePos.X.Scale, _sfBasePos.X.Offset - 36,
					_sfBasePos.Y.Scale, _sfBasePos.Y.Offset
				)
				local twOut = TweenService:Create(
					scrollingFrame,
					TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ Position = outPos }
				)
				twOut:Play()
				twOut.Completed:Connect(function()
					if token ~= _tabAnimToken then return end
					applyCategoryFilterRaw()
					scrollingFrame.CanvasPosition = Vector2.new(0, 0)
					-- start further left, slide in
					scrollingFrame.Position = UDim2.new(
						_sfBasePos.X.Scale, _sfBasePos.X.Offset - 52,
						_sfBasePos.Y.Scale, _sfBasePos.Y.Offset
					)
					TweenService:Create(
						scrollingFrame,
						TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = _sfBasePos }
					):Play()
				end)
			end
			getgenv()._070ApplyCategoryFilter = applyCategoryFilter
			getgenv()._070ScrollingFrame = scrollingFrame
			scrollingFrame.ChildAdded:Connect(function(ch)
				task.defer(function()
					if not ch:IsA("Frame") then return end
					if not ch:GetAttribute("070Category") then
						ch:SetAttribute("070Category", currentSectionCategory or "MOVEMENT")
					end
					local active = tostring(getgenv()._070ActiveTab or "MOVEMENT")
					local cat = ch:GetAttribute("070Category")
					ch.Visible = (cat == active) and ch.Visible
					if cat ~= active then ch.Visible = false end
				end)
			end)

			featureHelperZ = function(inputValue)
				local cat = sectionToCategory[inputValue] or currentSectionCategory
				currentSectionCategory = cat
				-- category marker only — no section title text (user request)
				local rowContainer = Instance.new("Frame", scrollingFrame)
				rowContainer.Name = "SectionMarker_" .. tostring(inputValue):gsub("%s+", "")
				rowContainer.Size = UDim2.new(1, 0, 0, 0)
				rowContainer.BackgroundTransparency = 1
				rowContainer.LayoutOrder = featureHelperLayoutOrder()
				rowContainer:SetAttribute("070Category", cat)
				rowContainer.Visible = false
			end

			createFrame = function(inputValue)
				local h = math.max(inputValue or 40, 40)
				local rowContainer = Instance.new("Frame", scrollingFrame)
				rowContainer.Size = UDim2.new(1, 0, 0, h)
				rowContainer.BackgroundColor3 = borderColor
				rowContainer.BackgroundTransparency = 1
				rowContainer.BorderSizePixel = 0
				rowContainer.ClipsDescendants = false
				rowContainer.LayoutOrder = featureHelperLayoutOrder()
				rowContainer:SetAttribute("070Category", currentSectionCategory)
				rowContainer.Visible = (currentSectionCategory == tostring(getgenv()._070ActiveTab or "MOVEMENT"))
				rowContainer.ClipsDescendants = true
				rowContainer.ZIndex = 4
				-- entrance tween
				task.defer(function()
					if not rowContainer.Parent then return end
					if not rowContainer.Visible then
						rowContainer.BackgroundTransparency = 0.34
						return
					end
					rowContainer.BackgroundTransparency = 1
					TweenService:Create(rowContainer, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.55
					}):Play()
				end)
				Instance.new("UICorner", rowContainer).CornerRadius = UDim.new(0, 8)
				local detailControl = Instance.new("UIStroke", rowContainer)
				detailControl.Color = panelColor
				detailControl.Thickness = 1
				detailControl.Transparency = 0.52
				local secondaryControl = Instance.new("UIGradient", rowContainer)
				-- hover / press micro-animation
				rowContainer.MouseEnter:Connect(function()
					if not rowContainer.Visible then return end
					TweenService:Create(rowContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.18
					}):Play()
					if detailControl then
						TweenService:Create(detailControl, TweenInfo.new(0.15), {
							Transparency = 0.25,
							Color = primaryColor
						}):Play()
					end
				end)
				rowContainer.MouseLeave:Connect(function()
					TweenService:Create(rowContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.55
					}):Play()
					if detailControl then
						TweenService:Create(detailControl, TweenInfo.new(0.2), {
							Transparency = 0.52,
							Color = panelColor
						}):Play()
					end
				end)


				secondaryControl.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 30, 78)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 12, 34)),
				})

				secondaryControl.Rotation = 0
				return rowContainer
			end
		end

		local featureHelperAA

		featureHelperAA = function(inputValue)
			inputValue.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			inputValue.BackgroundTransparency = 0
			inputValue.BorderSizePixel = 0
			local uiStroke2 = inputValue:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", inputValue)
			uiStroke2.Color = Color3.fromRGB(34, 34, 40)
			uiStroke2.Thickness = 1
			uiStroke2.Transparency = 0.08
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			return uiStroke2
		end

		local createTextLabel

		createTextLabel = function(inputValue, labelText)
			local label = Instance.new("TextLabel", inputValue)
			label.Size = UDim2.new(0.56, 0, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = labelText
			label.TextColor3 = textColor
			label.Font = Enum.Font.GothamBold
			label.TextSize = 12
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.ZIndex = 5
			return label
		end

		local featureHelperAB

		featureHelperAB = function(parentRow, rightPad)
			rightPad = tonumber(rightPad) or 28
			-- larger, cleaner iOS-style switch
			local track = Instance.new("Frame")
			track.Name = "PillTrack"
			track.Size = UDim2.fromOffset(30, 16)
			track.AnchorPoint = Vector2.new(1, 0.5)
			track.Position = UDim2.new(1, -(rightPad + 4), 0.5, 0)
			track.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
			track.BackgroundTransparency = 0
			track.BorderSizePixel = 0
			track.ZIndex = 12
			track.ClipsDescendants = true
			track.Parent = parentRow
			Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
			local trackStroke = Instance.new("UIStroke")
			trackStroke.Name = "TrackStroke"
			trackStroke.Color = Color3.fromRGB(55, 55, 65)
			trackStroke.Thickness = 1
			trackStroke.Transparency = 0.4
			trackStroke.Parent = track

			local knob = Instance.new("Frame")
			knob.Name = "PillKnob"
			knob.Size = UDim2.fromOffset(12, 12)
			knob.AnchorPoint = Vector2.new(0, 0.5)
			knob.Position = UDim2.new(0, 2, 0.5, 0)
			knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
			knob.BorderSizePixel = 0
			knob.ZIndex = 13
			knob.Parent = track
			Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

			return track, knob, nil
		end

		featureHelperAC = function(a, b, on)
			on = on and true or false
			local ON_COL = Color3.fromRGB(120, 100, 255)
			local OFF_COL = Color3.fromRGB(36, 36, 44)
			local track, knob
			if a and a.Name == "PillTrack" then
				track, knob = a, b or a:FindFirstChild("PillKnob")
			elseif a and a.Name == "PillKnob" then
				knob, track = a, a.Parent
			elseif a and a:IsA("Frame") and a:FindFirstChild("PillKnob") then
				track, knob = a, a:FindFirstChild("PillKnob")
			else
				track, knob = a, b
			end
			if not track or not track:IsA("Frame") then return end
			track.Visible = true
			pcall(function()
				TweenService:Create(track, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = on and ON_COL or OFF_COL
				}):Play()
			end)
			local ts = track:FindFirstChild("TrackStroke")
			if ts then
				ts.Color = on and Color3.fromRGB(180, 160, 255) or Color3.fromRGB(55, 55, 65)
				ts.Transparency = on and 0.2 or 0.35
			end
			if knob and knob:IsA("GuiObject") then
				knob.Visible = true
				knob.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
				local goal = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				pcall(function()
					TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = goal
					}):Play()
				end)
			end
		end

		featureHelperAD = function(inputValue, secondaryInput)
		if not inputValue or inputValue == "" or tostring(inputValue):find("REMOVED") or tostring(inputValue):find("SKIP") then
			return function() end
		end
			local secondaryValue = createFrame(32)
			createTextLabel(secondaryValue, inputValue)
			local currentObject, currentItem, targetObject = featureHelperAB(secondaryValue, 28)
			local isActive = false

			local function featureHelperAE(tertiaryInput)
				isActive = tertiaryInput
				featureHelperAC(currentItem, targetObject, tertiaryInput)
			end

			local toggleButton = Instance.new("TextButton", currentObject)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 5

			toggleButton.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAE(isActive)
				secondaryInput(isActive)
				saveConfig()
			end)

			return featureHelperAE
		end

		local createTextBox

		createTextBox = function(inputValue, secondaryInput, tertiaryInput, fourthInput, fifthInput)
			local textBox = Instance.new("TextBox", inputValue)
			textBox.Size = UDim2.new(0, tertiaryInput or 50, 0, 24)
			textBox.Position = UDim2.new(1, -(fourthInput or 58), 0.5, -12)
			textBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			textBox.BackgroundTransparency = 0
			textBox.BorderSizePixel = 0
			textBox.Text = tostring(secondaryInput)
			textBox.TextColor3 = textColor
			textBox.Font = Enum.Font.GothamBold
-- =====================================================================
-- 070Hub
-- =====================================================================
			textBox.TextSize = 11
			textBox.ClearTextOnFocus = false
			textBox.ZIndex = 5
			Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 7)
			local uiStroke2 = Instance.new("UIStroke", textBox)
			uiStroke2.Color = Color3.fromRGB(34, 34, 40)
			uiStroke2.Thickness = 1
			uiStroke2.Transparency = 0.52
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			textBox.Focused:Connect(function()
				TweenService
					:Create(uiStroke2, TweenInfo.new(0.1), { Color = Color3.fromRGB(34, 34, 40), Transparency = 0.08 })
					:Play()
			end)

			local function commitBox()
				if not fifthInput then return end
				local numericValue = tonumber(textBox.Text)
				if numericValue then
					fifthInput(numericValue)
					pcall(function()
						if getgenv()._070SaveAll then getgenv()._070SaveAll(true)
						elseif saveConfig then saveConfig() end
					end)
				else
					textBox.Text = tostring(secondaryInput)
				end
			end

			textBox.FocusLost:Connect(function()
				TweenService
					:Create(uiStroke2, TweenInfo.new(0.1), { Color = Color3.fromRGB(34, 34, 40), Transparency = 0.08 })
					:Play()
				commitBox()
			end)

			textBox:GetPropertyChangedSignal("Text"):Connect(function()
				-- live update while typing numbers
				local numericValue = tonumber(textBox.Text)
				if numericValue and fifthInput then
					fifthInput(numericValue)
				end
			end)

			return textBox
		end

		local featureHelperAE, featureHelperAF

		local workingData = {
			[Enum.KeyCode.ButtonA] = true,
			[Enum.KeyCode.ButtonB] = true,
			[Enum.KeyCode.ButtonX] = true,
			[Enum.KeyCode.ButtonY] = true,
			[Enum.KeyCode.ButtonL1] = true,
			[Enum.KeyCode.ButtonR1] = true,
			[Enum.KeyCode.ButtonL2] = true,
			[Enum.KeyCode.ButtonR2] = true,
			[Enum.KeyCode.ButtonL3] = true,
			[Enum.KeyCode.ButtonR3] = true,
			[Enum.KeyCode.ButtonStart] = true,
			[Enum.KeyCode.ButtonSelect] = true,
			[Enum.KeyCode.DPadUp] = true,
			[Enum.KeyCode.DPadDown] = true,
			[Enum.KeyCode.DPadLeft] = true,
			[Enum.KeyCode.DPadRight] = true,
		}

		featureHelperAE = function(inputValue)
			return inputValue and inputValue.UserInputType and inputValue.UserInputType.Name:match("^Gamepad") ~= nil
		end

		featureHelperAF = function(inputValue)
			if not inputValue or inputValue.KeyCode == Enum.KeyCode.Unknown then
				return false
			end

			if inputValue.UserInputType == Enum.UserInputType.Keyboard then
				return true
			end
			return featureHelperAE(inputValue) and workingData[inputValue.KeyCode] == true
		end

		local featureHelperAG

		featureHelperAG = function(inputValue, secondaryInput)
			if secondaryInput then
				local isActive = secondaryInput == inputValue.kb

				if isActive then
					secondaryInput = isActive
				else
					secondaryInput = inputValue.gp and secondaryInput == inputValue.gp
				end
			end

			return secondaryInput
		end

		local createTextButton

		createTextButton = function(inputValue, secondaryInput, tertiaryInput)
			local toggleButton = Instance.new("TextButton", inputValue)
			toggleButton.Size = UDim2.new(0, 54, 0, 28)
			toggleButton.Position = UDim2.new(1, -58, 0.5, -14)
			toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			toggleButton.BackgroundTransparency = 0
			toggleButton.BorderSizePixel = 0

			local function featureHelperAH()
				return secondaryInput.gp and secondaryInput.gp.Name
					or secondaryInput.kb and secondaryInput.kb.Name
					or "None"
			end

			toggleButton.Text = featureHelperAH()
			toggleButton.TextColor3 = textColor
			toggleButton.Font = Enum.Font.GothamBold
			toggleButton.TextSize = 9
			toggleButton.ZIndex = 5
			Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)
			local uiStroke2 = Instance.new("UIStroke", toggleButton)
			uiStroke2.Color = Color3.fromRGB(34, 34, 40)
			uiStroke2.Thickness = 1
			uiStroke2.Transparency = 0.52
			uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local isActive = false
			local activeConnection = nil
			local labelText = toggleButton.Text
			local amount = 0

			toggleButton.Activated:Connect(function()
				if isActive then
					isActive = false
					local secondaryValue = 0.25
					_keyListenBlockUntil = tick() + secondaryValue
					_anyKeyListening = false

					if activeConnection then
						activeConnection:Disconnect()
						activeConnection = nil
					end

					toggleButton.Text = labelText
					toggleButton.TextColor3 = textColor
					TweenService
						:Create(
							uiStroke2,
							TweenInfo.new(0.1),
							{ Color = Color3.fromRGB(34, 34, 40), Transparency = 0.08 }
						)
						:Play()
					return
				end

				if isKeybindLocked() then
					return
				end
				labelText = toggleButton.Text
				isActive = true
				_anyKeyListening = true
				local secondaryValue = 0.25
-- =====================================================================
-- 070Hub
-- =====================================================================
				_keyListenBlockUntil = tick() + secondaryValue
				amount = tick()
				toggleButton.Text = "..."
				toggleButton.TextColor3 = textColor
				TweenService
					:Create(uiStroke2, TweenInfo.new(0.1), { Color = Color3.fromRGB(34, 34, 40), Transparency = 0.08 })
					:Play()

				-- Capture on InputEnded so the bind press does NOT also fire the feature (kick risk)
				activeConnection = UserInputService.InputEnded:Connect(function(input)
					if not isActive then
						return
					end

					if input.KeyCode == Enum.KeyCode.Escape then
						isActive = false
						_keyListenBlockUntil = tick() + 0.55
						_anyKeyListening = false

						if activeConnection then
							activeConnection:Disconnect()
							activeConnection = nil
						end

						toggleButton.Text = labelText
						toggleButton.TextColor3 = textColor
						TweenService:Create(
							uiStroke2,
							TweenInfo.new(0.1),
							{ Color = Color3.fromRGB(34, 34, 40), Transparency = 0.08 }
						):Play()
						return
					end

					local currentObject = featureHelperAE(input)
					if currentObject and tick() - amount < 0.2 then
						return
					end

					if not featureHelperAF(input) then
						return
					end
					clearDuplicateKeybind(input.KeyCode, currentObject, secondaryInput)
					toggleButton.Text = input.KeyCode.Name
					labelText = input.KeyCode.Name
					toggleButton.TextColor3 = textColor
					TweenService
						:Create(
							uiStroke2,
							TweenInfo.new(0.1),
							{ Color = Color3.fromRGB(34, 34, 40), Transparency = 0.08 }
						)
						:Play()
					isActive = false
					-- block feature key handlers so this key does not activate bind immediately
					_keyListenBlockUntil = tick() + 0.65
					_anyKeyListening = false

					if activeConnection then
						activeConnection:Disconnect()
						activeConnection = nil
					end

					if tertiaryInput then
						pcall(tertiaryInput, input.KeyCode, currentObject)
					end

					refreshAllKeyButtons()
					pcall(function()
						if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
					end)
				end)
			end)

			_vhKeyButtons[secondaryInput] = toggleButton
			return toggleButton
		end

		local featureHelperAH

		featureHelperAH = function(inputValue, secondaryInput, tertiaryInput, fourthInput)
			local secondaryValue = createFrame(32)
			createTextLabel(secondaryValue, inputValue)

			if secondaryInput then
				createTextButton(secondaryValue, secondaryInput, function(gp, fifthInput)
					if fifthInput then
						secondaryInput.gp = gp
						secondaryInput.kb = nil
					else
						secondaryInput.kb = gp
						secondaryInput.gp = nil
					end

					if fourthInput then
						fourthInput(gp, fifthInput)
					end
				end)
			end

			local currentObject = featureHelperAB
			secondaryInput = secondaryInput and 76 or 28
			local currentItem, targetObject, uiElement = currentObject(secondaryValue, secondaryInput)
			local isActive = false

			local function featureHelperAI(fifthInput)
				isActive = fifthInput
				featureHelperAC(targetObject, uiElement, fifthInput)
			end

			local detailControl = Instance.new("TextButton", currentItem)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 5

			detailControl.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)

				if tertiaryInput then
					tertiaryInput(isActive)
				end

				saveConfig()
			end)

			return featureHelperAI
		end

		do
			local isActive = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
			local rowContainer = Instance.new("Frame", screenGui)
			rowContainer.Name = "StealBar_DISABLED"
			rowContainer.AnchorPoint = Vector2.new(0.5, 1)
			rowContainer.Size = UDim2.new(0, 0, 0, 0)
			rowContainer.Position = UDim2.new(0, -9999, 0, -9999)
			rowContainer.BackgroundColor3 = foregroundColor
			rowContainer.BackgroundTransparency = 1
			rowContainer.BorderSizePixel = 0
			rowContainer.Active = false
			rowContainer.Visible = false
			rowContainer.ZIndex = 0
			rowContainer.ClipsDescendants = true
			-- fully disabled
			progressBarScale = Instance.new("UIScale", rowContainer)
			progressBarScale.Scale = uiScaleValue / 100
			Instance.new("UICorner", rowContainer).CornerRadius = UDim.new(0, 12)
			local uiStroke2 = Instance.new("UIStroke", rowContainer)
			uiStroke2.Color = Color3.fromRGB(140, 100, 255)
			uiStroke2.Thickness = 1.4
			uiStroke2.Transparency = 0.2
			featureHelperW(rowContainer)
			-- VX7-style STEAL label
			local stealTitleLbl = Instance.new("TextLabel", rowContainer)
			stealTitleLbl.Name = "StealTitle"
			stealTitleLbl.Size = UDim2.new(0, 52, 0, 12)
			stealTitleLbl.Position = UDim2.new(0, 12, 0, 4)
			stealTitleLbl.BackgroundTransparency = 1
			stealTitleLbl.Text = "STEAL"
			stealTitleLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
			stealTitleLbl.Font = Enum.Font.GothamBold
			stealTitleLbl.TextSize = 10
			stealTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
			stealTitleLbl.ZIndex = 51

			progressPct = Instance.new("TextLabel", rowContainer)
			progressPct.Size = UDim2.new(0, 52, 0, 18)
			progressPct.Position = UDim2.new(0, 12, 0, 16)
			progressPct.BackgroundTransparency = 1
			progressPct.Text = "0%"
			progressPct.TextColor3 = Color3.fromRGB(255, 255, 255)
			progressPct.Font = Enum.Font.GothamBlack
			progressPct.TextSize = 16
			progressPct.TextXAlignment = Enum.TextXAlignment.Left
			progressPct.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			progressPct.TextStrokeTransparency = 0.5
			progressPct.ZIndex = 51
			progressRadLbl = Instance.new("TextLabel", rowContainer)
			progressRadLbl.Size = UDim2.new(0, 88, 0, 18)
			progressRadLbl.Position = UDim2.new(1, -92, 0, 2)
			progressRadLbl.BackgroundTransparency = 1
			progressRadLbl.Text = string.format("R %.1f", Steal.StealRadius)
			progressRadLbl.TextColor3 = Color3.fromRGB(180, 180, 195)
			progressRadLbl.Font = Enum.Font.GothamBlack
			progressRadLbl.TextXAlignment = Enum.TextXAlignment.Right
			progressRadLbl.TextTruncate = Enum.TextTruncate.AtEnd
			progressRadLbl.TextSize = 13
			progressRadLbl.TextXAlignment = Enum.TextXAlignment.Right
			progressRadLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			progressRadLbl.TextStrokeTransparency = 0.5
			progressRadLbl.ZIndex = 51
			local label = Instance.new("TextLabel", rowContainer)
			label.Size = UDim2.new(1, -20, 0, 14)
			label.Position = UDim2.new(0, 11, 0, 22)
			label.BackgroundTransparency = 1
			label.Text = "FPS --   PING --"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 11
			label.TextXAlignment = Enum.TextXAlignment.Center
			label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			label.TextStrokeTransparency = 0.65
			label.ZIndex = 51

			task.spawn(function()
				local startTime = tick()
				local amount = 0
				local calculatedValue = 0

				while label and label.Parent do
					amount = amount + 1
					local phaseStartTime = tick()

					if phaseStartTime - startTime >= 0.5 then
						local secondaryAmount = math.floor(amount / (phaseStartTime - startTime))

						local ok, result = pcall(function()
							return localPlayer:GetNetworkPing() * 1000
						end)

						if ok and result then
							calculatedValue = math.floor(result)
						end

						label.Text = string.format("FPS: %d  PING: %dms", secondaryAmount, calculatedValue)
						amount = 0
						startTime = phaseStartTime
					end

					task.wait()
				end
			end)

			local innerContainer = Instance.new("Frame", rowContainer)
			innerContainer.Size = UDim2.new(1, -20, 0, 14)
			innerContainer.Position = UDim2.new(0, 10, 1, -17)
			innerContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			innerContainer.BackgroundTransparency = 0
			innerContainer.BorderSizePixel = 0
			innerContainer.ZIndex = 51
			innerContainer.ClipsDescendants = true
			Instance.new("UICorner", innerContainer).CornerRadius = UDim.new(1, 0)
			local detailControl = Instance.new("UIStroke", innerContainer)
			detailControl.Color = Color3.fromRGB(28, 28, 34)
			detailControl.Thickness = 1
			detailControl.Transparency = 0.2
			detailControl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			progressFill = Instance.new("Frame", innerContainer)
		end

		progressFill.Size = UDim2.fromScale(0, 1)
		progressFill.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
		progressFill.BackgroundTransparency = 0
		progressFill.BorderSizePixel = 0
		progressFill.ZIndex = 52
		progressFill.ClipsDescendants = true
		Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

		do
			local uiGradient = Instance.new("UIGradient", progressFill)
			uiGradient.Name = "VisionProgressGradient"
			local colorSequence = ColorSequence.new
			local animationProperties = {}
			local secondaryValue = ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255))
			local currentObject = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 100, 255))
			local new = ColorSequenceKeypoint.new
			local gradientColor = Color3.fromRGB
			animationProperties[1] = secondaryValue
			animationProperties[2] = currentObject

			do
				local values = table.pack(new(1, gradientColor(40, 120, 255)))
				table.move(values, 1, values.n, 3, animationProperties)
			end

			uiGradient.Color = colorSequence(animationProperties)
			uiGradient.Rotation = 90
		end

		-- DESTROY original steal UI completely (circle MiroStealBar only)
		pcall(function()
			if progressFill then
				local p = progressFill.Parent
				while p and p.Name ~= "StealBar" and p.Name ~= "StealBar_DISABLED" and not p:IsA("ScreenGui") do
					p = p.Parent
				end
				if p and (p.Name == "StealBar" or p.Name == "StealBar_DISABLED") then
					p:Destroy()
				end
			end
		end)
		progressFill = nil
		progressPct = nil

		
		-- CategoryTabs wired (left sidebar: 2 top, avatar mid, 2 bottom)
		do
			local tabBarFrame = primaryControl:FindFirstChild("CategoryTabs")
			if tabBarFrame then
				local topTabs = tabBarFrame:FindFirstChild("TopTabs")
				local botTabs = tabBarFrame:FindFirstChild("BotTabs")
				local namesTop = {"MOVEMENT", "COMBAT"}
				local namesBot = {"VISUAL", "CONFIG"}
				local btns = {}
				-- clear any leftover TextButtons
				for _, c in ipairs(tabBarFrame:GetDescendants()) do
					if c:IsA("TextButton") and c.Name:find("Tab_") then c:Destroy() end
				end
				local function paintTabs()
					local active = tostring(getgenv()._070ActiveTab or "MOVEMENT")
					for n, b in pairs(btns) do
						local on = (n == active)
						-- no background / shadow — text + side accent only
						b.BackgroundTransparency = 1
						-- darker + higher contrast so tabs are easy to read on wallpapers
						b.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(48, 48, 54)
						b.TextStrokeTransparency = on and 0.55 or 0.35
						b.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						local st = b:FindFirstChild("TabStroke") or b:FindFirstChildOfClass("UIStroke")
						if st then st.Transparency = 1 end
						local und = b:FindFirstChild("Underline")
						if und then
							TweenService:Create(und, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Size = on and UDim2.new(0, 3, 0, 16) or UDim2.new(0, 0, 0, 16),
								BackgroundTransparency = on and 0 or 1
							}):Play()
						end
					end
				end
				local function wireTab(name, parent, order)
					local b = Instance.new("TextButton", parent)
					b.Name = "Tab_" .. name
					b.Size = UDim2.new(1, -8, 0, 44)
					b.BackgroundTransparency = 1
					b.BorderSizePixel = 0
					b.Text = name
					b.TextColor3 = Color3.fromRGB(48, 48, 54)
					b.TextStrokeTransparency = 0.35
					b.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					b.Font = Enum.Font.GothamBold
					b.TextSize = 12
					b.TextWrapped = true
					b.AutoButtonColor = false
					b.ZIndex = 21
					b.LayoutOrder = order
					local st = Instance.new("UIStroke", b)
					st.Name = "TabStroke"
					st.Transparency = 1
					local und = Instance.new("Frame", b)
					und.Name = "Underline"
					und.AnchorPoint = Vector2.new(0, 0.5)
					und.Position = UDim2.new(0, 2, 0.5, 0)
					und.Size = UDim2.new(0, 0, 0, 14)
					und.BackgroundColor3 = Color3.fromRGB(140, 120, 255)
					und.BackgroundTransparency = 1
					und.BorderSizePixel = 0
					und.ZIndex = 22
					Instance.new("UICorner", und).CornerRadius = UDim.new(1, 0)
					btns[name] = b
					b.MouseButton1Click:Connect(function()
						getgenv()._070ActiveTab = name
						paintTabs()
						-- soft fade on content
						pcall(function()
							local sf = getgenv()._070ScrollingFrame
							if not sf then return end
							for _, ch in ipairs(sf:GetChildren()) do
								if ch:IsA("Frame") and ch.Visible then
									local startT = ch.BackgroundTransparency
									ch.BackgroundTransparency = math.min(1, startT + 0.35)
									TweenService:Create(ch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										BackgroundTransparency = math.clamp(startT, 0.15, 0.5)
									}):Play()
								end
							end
						end)
						if getgenv()._070ApplyCategoryFilter then
							getgenv()._070ApplyCategoryFilter()
						end
						-- re-expand open detail rows on this tab only
						task.defer(function()
							if name == "COMBAT" then
								if autoStealDetailsOpen and type(autoStealDetailsRows) == "table" then
									for _, row in ipairs(autoStealDetailsRows) do
										if row and row.Parent then
											local skip = row:GetAttribute("AutoStealV2Only") and autoStealVersion ~= "V2"
											if not skip then
												row.Visible = true
												row.Size = UDim2.new(1, 0, 0, 32)
												row.BackgroundTransparency = row:GetAttribute("AutoStealSelectorRow") and 1 or 0.34
											end
										end
									end
								end
								if autoBatDetailsOpen and type(autoBatDetailsRows) == "table" then
									for _, row in ipairs(autoBatDetailsRows) do
										if row and row.Parent then
											local drop = false
											pcall(function()
												for _, d in ipairs(row:GetDescendants()) do
													if d:IsA("TextLabel") and tostring(d.Text) == "Lagger Auto Bat Speed" then
														drop = true
														break
													end
												end
											end)
											if not drop then
												row.Visible = true
												row.Size = UDim2.new(1, 0, 0, 40)
											end
										end
									end
									pcall(function() if refreshAutoBatModeControls then refreshAutoBatModeControls() end end)
								end
							end
						end)
					end)
				end
				-- place tabs: 2 top, 2 bottom around avatar
				if topTabs then
					for i, name in ipairs(namesTop) do
						wireTab(name, topTabs, i)
					end
				end
				if botTabs then
					for i, name in ipairs(namesBot) do
						wireTab(name, botTabs, i)
					end
				end
				paintTabs()
				task.defer(function()
					if getgenv()._070ApplyCategoryFilter then
						getgenv()._070ApplyCategoryFilter(true) -- no slide on first paint
					end
					if getgenv()._070ReloadAvatar then
						pcall(getgenv()._070ReloadAvatar)
					end
				end)
			end
		end

		featureHelperZ("Normal Mode")
		local secondaryValue = createFrame(32)
		createTextLabel(secondaryValue, "Normal Speed")

		normalBox = createTextBox(secondaryValue, NS, 50, 58, function(inputValue)
			if inputValue > 0 then
				NS = inputValue
			end
			saveConfig()
		end)

		local currentObject = createFrame(32)
		createTextLabel(currentObject, "Carry Speed")

		carryBox = createTextBox(currentObject, CS, 50, 56, function(inputValue)
			if inputValue > 0 then
				CS = inputValue
			end
			saveConfig()
		end)

local currentItem = createFrame(32)
		createTextLabel(currentItem, "Speed Key")

		createTextButton(currentItem, KB.SpeedToggle, function(gp, inputValue)
			if inputValue then
				KB.SpeedToggle.gp = gp
				KB.SpeedToggle.kb = nil
			else
				KB.SpeedToggle.kb = gp
				KB.SpeedToggle.gp = nil
			end

			saveConfig()
		end)

		featureHelperZ("Lagger Mode")
-- =====================================================================
-- 070Hub
-- =====================================================================
		local targetObject = createFrame(32)
		createTextLabel(targetObject, "Lagger Normal Speed")

		laggerBox = createTextBox(targetObject, LAGGER_SPEED, 50, 58, function(inputValue)
			if inputValue > 0 then
				LAGGER_SPEED = inputValue
			end

			saveConfig()
		end)

		local uiElement = createFrame(40)
		createTextLabel(uiElement, "Lagger Carry Speed")

		laggerCarryBox = createTextBox(uiElement, LAGGER_CARRY_SPEED, 50, 58, function(inputValue)
			if inputValue > 0 then
				LAGGER_CARRY_SPEED = inputValue
			end

			saveConfig()
		end)

		local stateToken = createFrame(32)
		createTextLabel(stateToken, "Lagger Key")

		createTextButton(stateToken, KB.LaggerToggle, function(gp, inputValue)
			if inputValue then
				KB.LaggerToggle.gp = gp
				KB.LaggerToggle.kb = nil
			else
				KB.LaggerToggle.kb = gp
				KB.LaggerToggle.gp = nil
			end

			saveConfig()
		end)

		featureHelperZ("Speed Mode")
		local glossOverlay = createFrame(40)
		createTextLabel(glossOverlay, "Mode")
		modeValLbl = Instance.new("TextLabel", glossOverlay)
		modeValLbl.Size = UDim2.new(0, 96, 1, 0)
		modeValLbl.Position = UDim2.new(1, -104, 0, 0)
		modeValLbl.BackgroundTransparency = 1
		modeValLbl.TextColor3 = primaryColor
		modeValLbl.Font = Enum.Font.GothamBlack
		modeValLbl.TextSize = 11
		modeValLbl.TextXAlignment = Enum.TextXAlignment.Right
		modeValLbl.TextStrokeTransparency = 1
		modeValLbl.ZIndex = 5
		refreshSpeedModeLabel()
		featureHelperZ("Automation")

		do
			local detailsRow = createFrame(32)
			createTextLabel(detailsRow, "Auto Steal")
			autoStealArrowButton = Instance.new("TextButton", detailsRow)
			autoStealArrowButton.Size = UDim2.new(0, 32, 0, 24)
			autoStealArrowButton.Position = UDim2.new(1, -68, 0.5, -12)
			featureHelperAA(autoStealArrowButton)
			autoStealArrowButton.Text = autoStealDetailsOpen and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED
			autoStealArrowButton.TextColor3 = textColor
			autoStealArrowButton.Font = Enum.Font.GothamBlack
			autoStealArrowButton.TextSize = 14
			autoStealArrowButton.ZIndex = 6
			autoStealArrowButton.AutoButtonColor = false
			Instance.new("UICorner", autoStealArrowButton).CornerRadius = UDim.new(0, 7)
			autoStealArrowButton.Visible = false -- only show when Auto Steal is ON
			local settingsRow, toggleContainer, optionRow = featureHelperAB(detailsRow, 12)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				featureHelperAC(toggleContainer, optionRow, inputValue)
			end

			setInstaGrab = featureHelperAI
			local toggleButton = Instance.new("TextButton", settingsRow)
			toggleButton.Size = UDim2.fromScale(1, 1)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 14

			local function refreshAutoStealDetailsUi()
				local enabled = Steal and Steal.AutoStealEnabled == true
				-- only show detail rows when Auto Steal is ON
				local show = enabled and autoStealDetailsOpen
				if autoStealArrowButton then
					autoStealArrowButton.Visible = enabled
					autoStealArrowButton.Text = (enabled and autoStealDetailsOpen) and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED
				end
				for _, detailsRow in ipairs(autoStealDetailsRows) do
					local shouldShow = show
					if shouldShow then
						shouldShow = not (detailsRow:GetAttribute("AutoStealV2Only") and autoStealVersion ~= "V2")
					end
					local activeTab = tostring(getgenv()._070ActiveTab or "MOVEMENT")
					local rowCat = detailsRow:GetAttribute("070Category") or "COMBAT"
					if shouldShow and rowCat == activeTab then
						detailsRow.Visible = true
						detailsRow.Size = UDim2.new(1, 0, 0, 0)
						detailsRow.BackgroundTransparency = 1
						local amount = detailsRow:GetAttribute("AutoStealSelectorRow") and 1 or 0.34
						TweenService:Create(
							detailsRow,
							TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{ Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = amount }
						):Play()
					else
						TweenService:Create(
							detailsRow,
							TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{ Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }
						):Play()
						task.delay(0.13, function()
							if detailsRow.Parent and not (Steal and Steal.AutoStealEnabled and autoStealDetailsOpen) then
								detailsRow.Visible = false
							end
						end)
					end
				end
				pcall(function()
					if getgenv()._070ApplyCategoryFilter then getgenv()._070ApplyCategoryFilter() end
				end)
			end
			getgenv()._070RefreshAutoStealDetails = refreshAutoStealDetailsUi

			toggleButton.Activated:Connect(function()
				isActive = not isActive
				featureHelperAI(isActive)

				if isActive then
					if not pcall(startAutoSteal) then
						Steal.AutoStealEnabled = false
						featureHelperAI(false)
						autoStealDetailsOpen = false
					else
						-- open radius UI when enabling
						autoStealDetailsOpen = true
					end
				else
					stopAutoSteal()
					autoStealDetailsOpen = false
				end

				refreshAutoStealDetailsUi()
				saveConfig()
			end)
		end

		autoStealArrowButton.Activated:Connect(function()
			local refresh = getgenv()._070RefreshAutoStealDetails
			if not (Steal and Steal.AutoStealEnabled) then
				autoStealDetailsOpen = false
				if refresh then refresh() end
				return
			end
			autoStealDetailsOpen = not autoStealDetailsOpen
			if refresh then refresh() end
			if updateStealVersionUi then updateStealVersionUi() end
		end)

		autoStealVersion = "V1"
		if updateStealVersionUi then updateStealVersionUi() end
		local detailsRow = createFrame(32)
		detailsRow.Visible = autoStealDetailsOpen
		table.insert(autoStealDetailsRows, detailsRow)

		if not autoStealDetailsOpen then
			detailsRow.Size = UDim2.new(1, 0, 0, 0)
			detailsRow.BackgroundTransparency = 1
		end

		createTextLabel(detailsRow, "Radius")

		radInput = createTextBox(detailsRow, Steal.StealRadius, 50, 56, function(inputValue)
			if inputValue >= 0.5 and inputValue <= 200 then
				setAutoStealRadius(inputValue)
			else
				radInput.Text = tostring(Steal.StealRadius)
			end

			updateStealRadiusUi()
			saveConfig()
		end)

		updateStealRadiusUi()
		featureHelperZ("Bat Aimbot")

		do
			local settingsRow = createFrame(40)
			createTextLabel(settingsRow, "Bat Aimbot")
			autoBatArrowButton = Instance.new("TextButton", settingsRow)
			autoBatArrowButton.Size = UDim2.new(0, 28, 0, 22)
			autoBatArrowButton.Position = UDim2.new(1, -124, 0.5, -11)
			featureHelperAA(autoBatArrowButton)
			autoBatArrowButton.Text = autoBatDetailsOpen and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED
			autoBatArrowButton.TextColor3 = textColor
			autoBatArrowButton.Font = Enum.Font.GothamBlack
			autoBatArrowButton.TextSize = 15
			autoBatArrowButton.ZIndex = 6
			autoBatArrowButton.AutoButtonColor = false
			Instance.new("UICorner", autoBatArrowButton).CornerRadius = UDim.new(0, 7)

			createTextButton(settingsRow, KB.AutoBat, function(gp, inputValue)
				if inputValue then
					KB.AutoBat.gp = gp
					KB.AutoBat.kb = nil
				else
					KB.AutoBat.kb = gp
					KB.AutoBat.gp = nil
				end

				saveConfig()
			end)

			-- keybind ~-58; toggle left of keybind; arrow further left with gap
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(settingsRow, 62)
			settingsRow.ClipsDescendants = false
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				featureHelperAC(optionRow, toggleBorder, inputValue)
			end

			autoBatSetVisual = featureHelperAI
			local detailControl = Instance.new("TextButton", toggleContainer)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 5

			detailControl.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)

				if isActive then
					queueAutoBatStart()
-- =====================================================================
-- 070Hub
-- =====================================================================
				else
					disableAutoBat()
				end

				saveConfig()
			end)
		end

		autoBatArrowButton.Activated:Connect(function()
			autoBatDetailsOpen = not autoBatDetailsOpen
			autoBatArrowButton.Text = autoBatDetailsOpen and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED

			for _, settingsRow in ipairs(autoBatDetailsRows) do
				-- never show Lagger Auto Bat Speed rows
				local skipLagger = false
				pcall(function()
					for _, d in ipairs(settingsRow:GetDescendants()) do
						if d:IsA("TextLabel") and tostring(d.Text) == "Lagger Auto Bat Speed" then
							skipLagger = true
							break
						end
					end
				end)
				if skipLagger or settingsRow == laggerAutoBatSpeedRow or settingsRow == bypassLaggerAutoBatSpeedRow then
					settingsRow.Visible = false
					settingsRow.Size = UDim2.new(1, 0, 0, 0)
				elseif autoBatDetailsOpen then
					local activeTab = tostring(getgenv()._070ActiveTab or "MOVEMENT")
					local rowCat = settingsRow:GetAttribute("070Category") or "COMBAT"
					if rowCat == activeTab then
						settingsRow.Visible = true
						settingsRow.Size = UDim2.new(1, 0, 0, 0)
						settingsRow.BackgroundTransparency = 1
						local amount = settingsRow:GetAttribute("AutoBatSelectorRow") and 1 or 0.34
						TweenService
							:Create(settingsRow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Size = UDim2.new(1, 0, 0, 40),
								BackgroundTransparency = amount,
							})
							:Play()
					else
						settingsRow.Visible = false
						settingsRow.Size = UDim2.new(1, 0, 0, 0)
					end
				else
					TweenService:Create(
						settingsRow,
						TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{ Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }
					):Play()

					task.delay(0.15, function()
						if not autoBatDetailsOpen and settingsRow.Parent then
							settingsRow.Visible = false
						end
					end)
				end
			end

			refreshAutoBatModeControls()
			pcall(function()
				if getgenv()._070ApplyCategoryFilter then getgenv()._070ApplyCategoryFilter() end
			end)
		end)

		do
			local settingsRow = createFrame(40)
			settingsRow.Visible = autoBatDetailsOpen
			table.insert(autoBatDetailsRows, settingsRow)
			settingsRow:SetAttribute("AutoBatSelectorRow", true)

			-- Bypass Aimbot keybind (PC + Controller)
			do
				local kbRow = createFrame(40)
				createTextLabel(kbRow, "Bypass Aimbot Key")
				createTextButton(kbRow, KB.BypassAimbot, function(gp, inputValue)
					if not KB.BypassAimbot then return end
					if inputValue then
						KB.BypassAimbot.gp = gp
						KB.BypassAimbot.kb = nil
					else
						KB.BypassAimbot.kb = gp
						KB.BypassAimbot.gp = nil
					end
					pcall(function() if saveConfig then saveConfig() end end)
					pcall(function() if getgenv()._070SaveAll then getgenv()._070SaveAll() end end)
				end)
				table.insert(autoBatDetailsRows, kbRow)
				if not autoBatDetailsOpen then
					kbRow.Size = UDim2.new(1, 0, 0, 0)
					kbRow.BackgroundTransparency = 1
					kbRow.Visible = false
				end
			end


			if not autoBatDetailsOpen then
				settingsRow.Size = UDim2.new(1, 0, 0, 0)
				settingsRow.BackgroundTransparency = 1
			end

			settingsRow.ClipsDescendants = false
			settingsRow.BackgroundTransparency = 1
			local uiStroke2 = settingsRow:FindFirstChildOfClass("UIStroke")

			if uiStroke2 then
				uiStroke2:Destroy()
			end

			local uiGradient = settingsRow:FindFirstChildOfClass("UIGradient")

			if uiGradient then
				uiGradient:Destroy()
			end

			local rowContainer = Instance.new("Frame", settingsRow)
			rowContainer.Size = UDim2.new(1, -10, 0, 28)
			rowContainer.Position = UDim2.new(0, 5, 0.5, -14)
			rowContainer.BackgroundTransparency = 1
			rowContainer.BorderSizePixel = 0
			rowContainer.ClipsDescendants = false
			rowContainer.ZIndex = 5
			Instance.new("UICorner", rowContainer).CornerRadius = UDim.new(0, 8)
			autoBatModeHighlight = Instance.new("Frame", rowContainer)
			autoBatModeHighlight:SetAttribute("VisionButtonPurple", true)
			autoBatModeHighlight.Size = UDim2.new(0.5, -4, 1, -4)
			do
				local m = tostring(autoBatMode or "Vision")
				if m == "V3" then
					autoBatModeHighlight.Position = UDim2.new(0.5, 2, 0, 2)
				elseif m == "AntiBatBypass" then
					autoBatModeHighlight.Position = UDim2.new(0.5, 2, 0, 2)
				else
					autoBatModeHighlight.Position = UDim2.new(0, 1, 0, 2)
				end
			end
			autoBatModeHighlight.BackgroundColor3 = tertiaryColor
			autoBatModeHighlight.BackgroundTransparency = 0.08
			autoBatModeHighlight.BorderSizePixel = 0
			autoBatModeHighlight.ZIndex = 6
			Instance.new("UICorner", autoBatModeHighlight).CornerRadius = UDim.new(0, 6)
			autoBatDefaultButton = Instance.new("TextButton", rowContainer)
			autoBatDefaultButton.Size = UDim2.new(0.5, -2, 1, 0)
			autoBatDefaultButton.Position = UDim2.new(0, 0, 0, 0)
			autoBatDefaultButton.BackgroundTransparency = 1
			autoBatDefaultButton.BorderSizePixel = 0
			autoBatDefaultButton.Text = "Normal"
			autoBatDefaultButton.Font = Enum.Font.GothamBlack
			autoBatDefaultButton.TextSize = 10
			autoBatDefaultButton.ZIndex = 7
			autoBatDefaultButton.AutoButtonColor = false
			autoBatDefaultButton.ClipsDescendants = true
			Instance.new("UICorner", autoBatDefaultButton).CornerRadius = UDim.new(0, 7)
			local detailControl = Instance.new("UIStroke", autoBatDefaultButton)
			detailControl.Color = panelColor
			detailControl.Thickness = 1
			detailControl.Transparency = 0.52
			detailControl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			autoBatDefaultButton.MouseEnter:Connect(function()
				TweenService:Create(autoBatDefaultButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.86 }):Play()
			end)

			autoBatDefaultButton.MouseLeave:Connect(function()
				TweenService:Create(autoBatDefaultButton, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
			end)

			autoBatBypassButton = Instance.new("TextButton", rowContainer)
		end

		autoBatBypassButton.Size = UDim2.new(0.5, -2, 1, 0)
		autoBatBypassButton.Position = UDim2.new(0.5, 2, 0, 0)
		autoBatBypassButton.BackgroundTransparency = 1
		autoBatBypassButton.BorderSizePixel = 0
		autoBatBypassButton.Text = "Bypass"
		autoBatBypassButton.Font = Enum.Font.GothamBlack
		autoBatBypassButton.TextSize = 10
		autoBatBypassButton.ZIndex = 7
		autoBatBypassButton.AutoButtonColor = false
		autoBatBypassButton.ClipsDescendants = true
		Instance.new("UICorner", autoBatBypassButton).CornerRadius = UDim.new(0, 7)
		local uiStroke2 = Instance.new("UIStroke", autoBatBypassButton)
		uiStroke2.Color = panelColor
		uiStroke2.Thickness = 1
		uiStroke2.Transparency = 0.52
		uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		autoBatBypassButton.MouseEnter:Connect(function()
			TweenService:Create(autoBatBypassButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.86 }):Play()
		end)

		autoBatBypassButton.MouseLeave:Connect(function()
			TweenService:Create(autoBatBypassButton, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
		end)

		autoBatDefaultButton.Activated:Connect(function()
			autoBatMode = "Vision"
			if getgenv()._070StopAutoBatV3 then pcall(getgenv()._070StopAutoBatV3) end
			refreshAutoBatModeControls()
			if autoBatEnabled then
				pcall(disableAutoBat)
				pcall(enableAutoBat)
			end
			saveConfig()
		end)

		autoBatBypassButton.Activated:Connect(function()
			autoBatMode = "AntiBatBypass"
			if getgenv()._070StopAutoBatV3 then pcall(getgenv()._070StopAutoBatV3) end
			refreshAutoBatModeControls()
			if autoBatEnabled then
				pcall(disableAutoBat)
				pcall(enableAutoBat)
			end
			saveConfig()
		end)

		autoBatV3Button = Instance.new("TextButton", autoBatBypassButton.Parent)
		autoBatV3Button.Size = UDim2.new(0.333, -3, 1, 0)
		autoBatV3Button.Position = UDim2.new(0.666, 3, 0, 0)
		autoBatV3Button.BackgroundTransparency = 1
		autoBatV3Button.BorderSizePixel = 0
		autoBatV3Button.Text = "V3"
		autoBatV3Button.Font = Enum.Font.GothamBlack
		autoBatV3Button.TextSize = 10
		autoBatV3Button.TextColor3 = Color3.fromRGB(0, 255, 255)
		autoBatV3Button.ZIndex = 7
		autoBatV3Button.AutoButtonColor = false
		Instance.new("UICorner", autoBatV3Button).CornerRadius = UDim.new(0, 7)
		do
			local st = Instance.new("UIStroke", autoBatV3Button)
			st.Thickness = 1
			st.Transparency = 0.52
			st.Color = Color3.fromRGB(40, 50, 70)
		end
		autoBatV3Button.Activated:Connect(function()
			autoBatMode = "V3"
			refreshAutoBatModeControls()
			if autoBatEnabled then
				if getgenv()._070StartAutoBatV3 then pcall(getgenv()._070StartAutoBatV3) end
			end
			saveConfig()
		end)
		autoBatV3Button.Visible = false
		autoBatV3Button.Size = UDim2.new(0, 0, 0, 0)
		-- only Vision + AntiBatBypass remain
		if autoBatDefaultButton then
			autoBatDefaultButton.Size = UDim2.new(0.5, -2, 1, 0)
			autoBatDefaultButton.Position = UDim2.new(0, 0, 0, 0)
		end
		if autoBatBypassButton then
			autoBatBypassButton.Size = UDim2.new(0.5, -2, 1, 0)
			autoBatBypassButton.Position = UDim2.new(0.5, 2, 0, 0)
		end

		refreshAutoBatModeControls()

		do
			local settingsRow = createFrame(32)
			settingsRow.Visible = autoBatDetailsOpen
			table.insert(autoBatDetailsRows, settingsRow)

			if not autoBatDetailsOpen then
				settingsRow.Size = UDim2.new(1, 0, 0, 0)
				settingsRow.BackgroundTransparency = 1
			end

			createTextLabel(settingsRow, "Auto Swing")
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(settingsRow, 28)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				featureHelperAC(optionRow, toggleBorder, inputValue)
			end

			setAutoSwingVisual = featureHelperAI
			local toggleButton = Instance.new("TextButton", toggleContainer)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 5

			toggleButton.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)
				autoSwingEnabled = isActive
				saveConfig()
			end)
		end

		do
			local settingsRow = createFrame(32)
			settingsRow.Visible = autoBatDetailsOpen
			table.insert(autoBatDetailsRows, settingsRow)

			if not autoBatDetailsOpen then
				settingsRow.Size = UDim2.new(1, 0, 0, 0)
				settingsRow.BackgroundTransparency = 1
			end

			createTextLabel(settingsRow, "Mirror TP")
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(settingsRow, 28)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				mirrorTPEnabled = inputValue
				featureHelperAC(optionRow, toggleBorder, inputValue)
			end

			setMirrorTPVisual = featureHelperAI
			local toggleButton = Instance.new("TextButton", toggleContainer)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 5

			toggleButton.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)
				saveConfig()
			end)
		end

		local settingsRow = createFrame(32)
		settingsRow.Visible = autoBatDetailsOpen
		table.insert(autoBatDetailsRows, settingsRow)

		if not autoBatDetailsOpen then
			settingsRow.Size = UDim2.new(1, 0, 0, 0)
			settingsRow.BackgroundTransparency = 1
		end

		createTextLabel(settingsRow, "Bat Aimbot Speed")
		autoBatSpeedRow = settingsRow

		autoBatSpeedBox = createTextBox(settingsRow, AUTO_BAT_SPEED, 50, 56, function(inputValue)
			if inputValue > 0 then
				AUTO_BAT_SPEED = inputValue
				BYPASS_AUTO_BAT_SPEED = inputValue

				if bypassAutoBatSpeedBox then
					bypassAutoBatSpeedBox.Text = tostring(inputValue)
				end
			else
				autoBatSpeedBox.Text = tostring(AUTO_BAT_SPEED)
			end

			saveConfig()
		end)

		local toggleContainer = createFrame(32)
		toggleContainer.Visible = autoBatDetailsOpen
		table.insert(autoBatDetailsRows, toggleContainer)

		if not autoBatDetailsOpen then
			toggleContainer.Size = UDim2.new(1, 0, 0, 0)
			toggleContainer.BackgroundTransparency = 1
		end

		createTextLabel(toggleContainer, "Bat Aimbot Speed")
		bypassAutoBatSpeedRow = toggleContainer

		bypassAutoBatSpeedBox = createTextBox(toggleContainer, AUTO_BAT_SPEED, 50, 56, function(inputValue)
			if inputValue > 0 then
				AUTO_BAT_SPEED = inputValue
				BYPASS_AUTO_BAT_SPEED = inputValue

				if autoBatSpeedBox then
					autoBatSpeedBox.Text = tostring(inputValue)
				end
			else
				bypassAutoBatSpeedBox.Text = tostring(AUTO_BAT_SPEED)
			end

			saveConfig()
		end)

		local optionRow = createFrame(32)
		optionRow.Visible = autoBatDetailsOpen
		table.insert(autoBatDetailsRows, optionRow)

		if not autoBatDetailsOpen then
			optionRow.Size = UDim2.new(1, 0, 0, 0)
			optionRow.BackgroundTransparency = 1
		end

		-- Lagger Auto Bat Speed REMOVED
		laggerAutoBatSpeedRow = nil
		laggerAutoBatSpeedBox = nil
		pcall(function()
			for i = #autoBatDetailsRows, 1, -1 do
				if autoBatDetailsRows[i] == optionRow then
					table.remove(autoBatDetailsRows, i)
				end
			end
			optionRow:Destroy()
		end)

		local toggleBorder = createFrame(32)
		toggleBorder.Visible = autoBatDetailsOpen
		table.insert(autoBatDetailsRows, toggleBorder)

		if not autoBatDetailsOpen then
			toggleBorder.Size = UDim2.new(1, 0, 0, 0)
			toggleBorder.BackgroundTransparency = 1
		end

		-- bypass Lagger Auto Bat Speed REMOVED
		bypassLaggerAutoBatSpeedRow = nil
		bypassLaggerAutoBatSpeedBox = nil
		pcall(function()
			for i = #autoBatDetailsRows, 1, -1 do
				if autoBatDetailsRows[i] == toggleBorder then
					table.remove(autoBatDetailsRows, i)
				end
			end
			toggleBorder:Destroy()
		end)

		refreshAutoBatModeControls()

		if setAutoSwingVisual then
			setAutoSwingVisual(autoSwingEnabled)
		end

		if setMirrorTPVisual then
			setMirrorTPVisual(mirrorTPEnabled)
		end

		-- Anti Die + expand arrow (same style as Auto Bat) + Anti Fling child row
		do
			local settingsRow = createFrame(40)
			createTextLabel(settingsRow, "Anti Die")

			local antiDieDetailsOpen = false
			local antiDieArrowButton = Instance.new("TextButton", settingsRow)
			antiDieArrowButton.Size = UDim2.new(0, 28, 0, 22)
			antiDieArrowButton.Position = UDim2.new(1, -86, 0.5, -11)
			featureHelperAA(antiDieArrowButton)
			antiDieArrowButton.Text = AUTO_BAT_ARROW_CLOSED
			antiDieArrowButton.TextColor3 = textColor
			antiDieArrowButton.Font = Enum.Font.GothamBlack
			antiDieArrowButton.TextSize = 15
			antiDieArrowButton.ZIndex = 6
			antiDieArrowButton.AutoButtonColor = false
			Instance.new("UICorner", antiDieArrowButton).CornerRadius = UDim.new(0, 7)

			-- toggle further right (pad 8), arrow left of it with gap
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(settingsRow, 12)
			local isActive = false
			local function featureHelperAI(inputValue)
				isActive = inputValue
				featureHelperAC(optionRow, toggleBorder, inputValue)
			end
			setTPBatVisual = featureHelperAI

			local detailControl = Instance.new("TextButton", toggleContainer)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 6
			detailControl.Activated:Connect(function()
				if isKeybindLocked() then return end
				isActive = not isActive
				featureHelperAI(isActive)
				local on = isActive == true
				_G.__070AntiDieOn = on
				tpBatEnabled = false
				if stopTpBat then pcall(stopTpBat) end
				if setDesyncAimbotEnabled then
					setDesyncAimbotEnabled(on)
				elseif on and startAntiDie then
					startAntiDie()
				elseif (not on) and stopAntiDie then
					stopAntiDie()
				end
				saveConfig()
			end)

			-- Anti Fling detail row (same size/style as other detail rows)
			local flingRow = createFrame(40)
			flingRow.Visible = false
			flingRow.Size = UDim2.new(1, 0, 0, 0)
			flingRow.BackgroundTransparency = 1
			createTextLabel(flingRow, "Anti Fling")
			local flingToggleContainer, flingOptionRow, flingToggleBorder = featureHelperAB(flingRow, 40)
			local flingActive = false
			local function setFlingVisual(on)
				flingActive = on
				featureHelperAC(flingOptionRow, flingToggleBorder, on)
			end
			local flingBtn = Instance.new("TextButton", flingToggleContainer)
			flingBtn.Size = UDim2.new(1, 0, 1, 0)
			flingBtn.BackgroundTransparency = 1
			flingBtn.Text = ""
			flingBtn.ZIndex = 6
			flingBtn.Activated:Connect(function()
				if isKeybindLocked() then return end
				local on = not flingActive
				setFlingVisual(on)
				if on then
					if getgenv()._070StartAntiFling then getgenv()._070StartAntiFling() end
				else
					if getgenv()._070StopAntiFling then getgenv()._070StopAntiFling() end
				end
			end)

			antiDieArrowButton.Activated:Connect(function()
				antiDieDetailsOpen = not antiDieDetailsOpen
				antiDieArrowButton.Text = antiDieDetailsOpen and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED
				if antiDieDetailsOpen then
					flingRow.Visible = true
					flingRow.Size = UDim2.new(1, 0, 0, 40)
					flingRow.BackgroundTransparency = 0.34
				else
					flingRow.Visible = false
					flingRow.Size = UDim2.new(1, 0, 0, 0)
					flingRow.BackgroundTransparency = 1
				end
			end)
		end

		
		-- hide Lagger Auto Bat Speed rows only
		pcall(function()
			if laggerAutoBatSpeedRow then
				laggerAutoBatSpeedRow.Visible = false
				laggerAutoBatSpeedRow.Size = UDim2.new(1, 0, 0, 0)
			end
		end)

		
		-- strip Lagger Auto Bat Speed from auto bat details permanently
		pcall(function()
			local kept = {}
			for _, row in ipairs(autoBatDetailsRows or {}) do
				local drop = false
				for _, d in ipairs(row:GetDescendants()) do
					if d:IsA("TextLabel") and tostring(d.Text) == "Lagger Auto Bat Speed" then
						drop = true
						break
					end
				end
				if drop then
					row.Visible = false
					row.Size = UDim2.new(1, 0, 0, 0)
				else
					table.insert(kept, row)
				end
			end
			autoBatDetailsRows = kept
			if laggerAutoBatSpeedRow then
				laggerAutoBatSpeedRow.Visible = false
				laggerAutoBatSpeedRow.Size = UDim2.new(1, 0, 0, 0)
			end
		end)

		setTPBatAutoSwingVisual = function() end

		-- Auto Movement (Auto Left / Auto Right) REMOVED from UI
		autoLeftSetVisual = function() end
		autoRightSetVisual = function() end


		featureHelperZ("Drop")
		local settingsSection = createFrame(32)
		createTextLabel(settingsSection, "Drop Brainrot")

		createTextButton(settingsSection, KB.DropBrainrot, function(gp, inputValue)
			if inputValue then
				KB.DropBrainrot.gp = gp
				KB.DropBrainrot.kb = nil
			else
				KB.DropBrainrot.kb = gp
				KB.DropBrainrot.gp = nil
			end

			saveConfig()
		end)

		featureHelperZ("Teleport")

		setAutoTPVisual = featureHelperAD("Auto TP", function(inputValue)
			if inputValue and isCountdownCounterBlocked and isCountdownCounterBlocked() then
				autoTPEnabled = false

				task.defer(function()
					if setAutoTPVisual then
						setAutoTPVisual(false)
					end
				end)

				return
			end

			autoTPEnabled = inputValue

			if inputValue then
				startAutoTeleport()
			else
				stopAutoTeleport()
			end

			saveConfig()
		end)

		local detailsPanel = createFrame(32)
		createTextLabel(detailsPanel, "Auto TP Height")

		autoTPHeightBox = createTextBox(detailsPanel, autoTPHeight, 50, 56, function(inputValue)
			if inputValue >= 0 and inputValue <= 50 then
				autoTPHeight = inputValue
			else
				autoTPHeightBox.Text = tostring(autoTPHeight)
			end

			saveConfig()
		end)

		local toggleIndicator = createFrame(32)
		createTextLabel(toggleIndicator, "TP Down")

		createTextButton(toggleIndicator, KB.TPFloor, function(gp, inputValue)
			if inputValue then
				KB.TPFloor.gp = gp
				KB.TPFloor.kb = nil
			else
				KB.TPFloor.kb = gp
				KB.TPFloor.gp = nil
			end

			saveConfig()
		end)

		featureHelperZ("Defense")

		do
			local expandableSection = createFrame(32)
			createTextLabel(expandableSection, "Infinite Jump")
			local actionContainer, layoutValue, scaleController = featureHelperAB(expandableSection, 28)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				featureHelperAC(layoutValue, scaleController, inputValue)
			end

			setInfJumpVisual = featureHelperAI
-- =====================================================================
-- 070Hub
-- =====================================================================
			local detailControl = Instance.new("TextButton", actionContainer)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 5

			detailControl.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)
				featureHelperA(isActive)
			end)
		end

		setAntiRagVisual = featureHelperAD("Anti Ragdoll", function(inputValue)
			antiRagdollEnabled = inputValue

			if inputValue then
				startAntiRagdoll()
			else
				stopAntiRagdoll()
			end
		end)

		setUnwalkVisual = featureHelperAD("Unwalk", function(inputValue)
			unwalkEnabled = inputValue

			if inputValue then
				task.spawn(function()
					pcall(disableWalkAnimation)
				end)
			else
				pcall(restoreWalkAnimation)
			end
		end)

		-- Anti Bat REMOVED
		setAntiBatVisual = function() end
		_G._070AntiBatEnabled = false


		featureHelperZ("Counters")


		-- Med Counter
		setMedCounterVisual = featureHelperAD("Med Counter", function(on)
			if getgenv()._070SetMedCounter then getgenv()._070SetMedCounter(on) end
			saveConfig()
		end)

		-- Body Lock REMOVED
		setBodyLockVisual = function() end


		do
			local expandableSection = createFrame(40)
			createTextLabel(expandableSection, "Bat Counter")
			local actionContainer, layoutValue, scaleController = featureHelperAB(expandableSection, 28)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue

				if batCounterVersion == "V1" then
					batCounterEnabled = inputValue
					batCounterV2Enabled = false
				else
					batCounterEnabled = false
					batCounterV2Enabled = inputValue
				end

				normalizeBatCounterSettings()
				featureHelperAC(layoutValue, scaleController, inputValue)

				if inputValue then
					startBatCounter()
				elseif not ragdollCountdownEnabled then
					stopBatCounter()
				end

				updateBatCounterVersionIndicator()
			end

			setBatCounterVisual = featureHelperAI
			local toggleButton = Instance.new("TextButton", actionContainer)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 5

			toggleButton.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				featureHelperAI(not isActive)
				saveConfig()
			end)

			-- Counter Version panel removed (V1 only)
			batCounterVersion = "V1"
			normalizeBatCounterSettings()
		end

		updateBatCounterVersionIndicator()
		featureHelperZ("Performance")

		do
			local expandableSection = createFrame(40)
			createTextLabel(expandableSection, "ESP")
			espArrowButton = Instance.new("TextButton", expandableSection)
			espArrowButton.Size = UDim2.new(0, 28, 0, 22)
			espArrowButton.Position = UDim2.new(1, -86, 0.5, -11)
			featureHelperAA(espArrowButton)
			espArrowButton.Text = espDetailsOpen and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED
			espArrowButton.TextColor3 = textColor
			espArrowButton.Font = Enum.Font.GothamBlack
			espArrowButton.TextSize = 14
			espArrowButton.ZIndex = 6
			espArrowButton.AutoButtonColor = false
			Instance.new("UICorner", espArrowButton).CornerRadius = UDim.new(0, 7)
			-- same gap as Anti Die: toggle right, arrow left
			local actionContainer, layoutValue, scaleController = featureHelperAB(expandableSection, 12)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				espEnabled = inputValue
				featureHelperAC(layoutValue, scaleController, inputValue)
			end

			setESPVisual = featureHelperAI
			local toggleButton = Instance.new("TextButton", actionContainer)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 5

			toggleButton.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)
				refreshESP()
				saveConfig()
			end)
		end

		espArrowButton.Activated:Connect(function()
			espDetailsOpen = not espDetailsOpen
			espArrowButton.Text = espDetailsOpen and AUTO_BAT_ARROW_OPEN or AUTO_BAT_ARROW_CLOSED

			for _, expandableSection in ipairs(espDetailsRows) do
				if espDetailsOpen then
					expandableSection.Visible = true
					expandableSection.Size = UDim2.new(1, 0, 0, 0)
					expandableSection.BackgroundTransparency = 1
					TweenService:Create(
						expandableSection,
						TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 0.34 }
					):Play()
				else
					TweenService:Create(
						expandableSection,
						TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{ Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }
					):Play()

					task.delay(0.15, function()
						if not espDetailsOpen and expandableSection.Parent then
							expandableSection.Visible = false
						end
					end)
				end
			end
		end)

		do
			local expandableSection = createFrame(32)
			expandableSection.Visible = espDetailsOpen
			table.insert(espDetailsRows, expandableSection)

			if not espDetailsOpen then
				expandableSection.Size = UDim2.new(1, 0, 0, 0)
				expandableSection.BackgroundTransparency = 1
			end

			createTextLabel(expandableSection, "Show Tracer")
			local actionContainer, layoutValue, scaleController = featureHelperAB(expandableSection, 28)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				espTracersEnabled = inputValue
				featureHelperAC(layoutValue, scaleController, inputValue)
			end

			setESPTracersVisual = featureHelperAI
			local toggleButton = Instance.new("TextButton", actionContainer)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 5

			toggleButton.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)
				refreshESP()
				saveConfig()
			end)
		end

		do
			local expandableSection = createFrame(32)
			expandableSection.Visible = espDetailsOpen
-- =====================================================================
-- 070Hub
-- =====================================================================
			table.insert(espDetailsRows, expandableSection)

			if not espDetailsOpen then
				expandableSection.Size = UDim2.new(1, 0, 0, 0)
				expandableSection.BackgroundTransparency = 1
			end

			createTextLabel(expandableSection, "Ragdoll Countdown")
			local actionContainer, layoutValue, scaleController = featureHelperAB(expandableSection, 28)
			local isActive = false

			local function featureHelperAI(inputValue)
				isActive = inputValue
				ragdollCountdownEnabled = inputValue
				featureHelperAC(layoutValue, scaleController, inputValue)

				if inputValue then
					ensureLocalPlayerBillboard()
					startBatCounter()
				elseif not batCounterEnabled and not batCounterV2Enabled then
					stopBatCounter()
				end

				if not inputValue then
					AR2.StopCountdown()
				end
			end

			setRagdollCountdownVisual = featureHelperAI
			local detailControl = Instance.new("TextButton", actionContainer)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 5

			detailControl.Activated:Connect(function()
				if isKeybindLocked() then
					return
				end
				isActive = not isActive
				featureHelperAI(isActive)
				saveConfig()
			end)
		end

		do
			local duration = 2.6
			local heartbeat, warningGui, warningLabel, warningFill
			local startedAt, previousCharacter

			local function stopWarning()
				if heartbeat then
					heartbeat:Disconnect()
					heartbeat = nil
				end
				if warningGui then
					warningGui:Destroy()
					warningGui, warningLabel, warningFill = nil, nil, nil
				end
				startedAt, previousCharacter = nil, nil
			end

			local function buildWarningGui()
				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
				if not playerGui then return end

				warningGui = Instance.new("ScreenGui")
				warningGui.Name = "070E01Warning"
				warningGui.ResetOnSpawn = false
				warningGui.IgnoreGuiInset = true
				warningGui.DisplayOrder = 4000

				local bar = Instance.new("Frame", warningGui)
				bar.AnchorPoint = Vector2.new(0.5, 0)
				bar.Position = UDim2.new(0.5, 0, 0, 18)
				bar.Size = UDim2.fromOffset(300, 36)
				bar.BackgroundColor3 = Color3.new(0, 0, 0)
				bar.BackgroundTransparency = 0.34
				bar.BorderSizePixel = 0
				Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

				local track = Instance.new("Frame", bar)
				track.Position = UDim2.fromOffset(3, 3)
				track.Size = UDim2.new(1, -6, 1, -6)
				track.BackgroundColor3 = Color3.new(0, 0, 0)
				track.BackgroundTransparency = 0.48
				track.BorderSizePixel = 0
				track.ClipsDescendants = true
				Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

				warningFill = Instance.new("Frame", track)
				warningFill.Size = UDim2.fromScale(0, 1)
				warningFill.BackgroundColor3 = Color3.fromRGB(180, 200, 255)
				warningFill.BackgroundTransparency = 0.48
				warningFill.BorderSizePixel = 0
				Instance.new("UICorner", warningFill).CornerRadius = UDim.new(1, 0)

				warningLabel = Instance.new("TextLabel", bar)
				warningLabel.Size = UDim2.fromScale(1, 1)
				warningLabel.BackgroundTransparency = 1
				warningLabel.Font = Enum.Font.GothamBlack
				warningLabel.TextSize = 14
				warningLabel.TextStrokeTransparency = 0.18
				warningLabel.ZIndex = 2

				warningGui.Parent = playerGui
			end

			local function updateWarning()
				local character = localPlayer.Character
				if character ~= previousCharacter then
					startedAt = nil
					previousCharacter = character
				end

				if not character or not isHoldingBrainrot() then
					startedAt = nil
					if warningGui then warningGui.Enabled = false end
					return
				end

				local now = os.clock()
				startedAt = startedAt or now
				if not warningGui or not warningGui.Parent then buildWarningGui() end
				if not warningGui or not warningGui.Parent then return end

				local progress = math.clamp((now - startedAt) / duration, 0, 1)
				local ready = progress >= 1
				warningGui.Enabled = true
				warningLabel.Text = ready and "STEAL" or "DONT STEAL"
				warningLabel.TextColor3 = ready and Color3.fromRGB(180, 200, 255) or Color3.fromRGB(60, 75, 110)
				warningFill.Size = UDim2.fromScale(progress, 1)
			end

			local function applyWarning(enabled)
				showE01Warning = enabled == true
				_G.showE01Warning = showE01Warning
				-- write persist immediately so rejoin always sees it
				pcall(function()
					local p = getgenv()._070Persist
					if type(p) ~= "table" then
						p = {}
						getgenv()._070Persist = p
						_G._070Persist = p
					end
					p.showE01Warning = showE01Warning
				end)
				if showE01Warning then
					if not heartbeat then
						local elapsed = 0
						heartbeat = RunService.Heartbeat:Connect(function(dt)
							elapsed += dt
							if elapsed < 0.05 then return end
							elapsed = 0
							updateWarning()
						end)
						updateWarning()
					end
				else
					stopWarning()
				end
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
				end)
			end

			local setWarningToggle = featureHelperAD("Show E01 Warning", applyWarning)
			setShowE01WarningVisual = function(enabled)
				setWarningToggle(enabled)
				applyWarning(enabled)
			end
			screenGui.Destroying:Connect(stopWarning)
		end

		setAntiLagVisual = featureHelperAD("Anti Lag", function(inputValue)
			if inputValue then
				enableAntiLag()
			else
				disableAntiLag()
			end

			saveConfig()
		end)

		setBaseXRayVisual = featureHelperAD("X-Ray Base", function(on)
			if getgenv()._070SetBaseXRay then getgenv()._070SetBaseXRay(on) end
			saveConfig()
		end)

		setBrainrotXRayVisual = featureHelperAD("X-Ray Brainrot", function(on)
			if getgenv()._070SetBrainrotXRay then getgenv()._070SetBrainrotXRay(on) end
			saveConfig()
		end)


		setStretchRezVisual = featureHelperAD("Strech Res", function(inputValue)
			if inputValue then
				featureHelperF()
			else
				featureHelperG()
			end

			saveConfig()
		end)

		setFovVisual = featureHelperAD("FOV Change", function(inputValue)
			if inputValue then
				if stretchRezEnabled then
					featureHelperG()

					if setStretchRezVisual then
						setStretchRezVisual(false)
					end
				end

				featureHelperD()
			else
				featureHelperE()
			end

			saveConfig()
		end)

		local expandableSection = createFrame(32)
		createTextLabel(expandableSection, "FOV Value")

		fieldOfViewBox = createTextBox(expandableSection, fieldOfView, 50, 56, function(inputValue)
			if inputValue >= 40 and inputValue <= 120 then
				fieldOfView = inputValue
				applyFieldOfView()

				if stretchRezEnabled and workspace.CurrentCamera then
					workspace.CurrentCamera.FieldOfView = fieldOfView
				end
			else
				fieldOfViewBox.Text = tostring(fieldOfView)
			end

			saveConfig()
		end)

		-- Headless
		do
			local rowH = createFrame(32)
			createTextLabel(rowH, "Headless")
			local toggleContainerH, optionRowH, toggleBorderH = featureHelperAB(rowH, 28)
			local headlessOn = _G._070Headless == true
			local function setHeadlessVis(v)
				headlessOn = v
				featureHelperAC(optionRowH, toggleBorderH, v)
			end
			setHeadlessVis(headlessOn)
			local btnH = Instance.new("TextButton", toggleContainerH)
			btnH.Size = UDim2.new(1, 0, 1, 0)
			btnH.BackgroundTransparency = 1
			btnH.Text = ""
			btnH.ZIndex = 8
			btnH.Activated:Connect(function()
				local on = not (_G._070Headless == true)
				_G._070Headless = on
				if getgenv()._070SetHeadless then
					getgenv()._070SetHeadless(on)
				end
				setHeadlessVis(on)
				pcall(function() if saveConfig then saveConfig() end end)
			end)
		end

		-- Purple Halo
		do
			local row = createFrame(36)
			createTextLabel(row, "Halo")
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(row, 28)
			local on = _G._070Halo == true
			local function setVis(v)
				on = v
				featureHelperAC(optionRow, toggleBorder, v)
			end
			setVis(on)
			local btn = Instance.new("TextButton", toggleContainer)
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.ZIndex = 8
			btn.Activated:Connect(function()
				local v = not (_G._070Halo == true)
				if getgenv()._070SetHalo then
					getgenv()._070SetHalo(v)
				else
					_G._070Halo = v
				end
				setVis(v)
				pcall(function() if saveConfig then saveConfig() end end)
			end)
			getgenv()._070SetHaloVisual = setVis
		end

		-- Outfits / skin changer removed completely

		-- Bat Katana Skin button REMOVED (was laggy)


		do
			local amount = 66
			local actionContainer = 58
			local currentCamera = workspace.CurrentCamera
			currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
			local x = currentCamera.X
			local y = currentCamera.Y

			local function featureHelperAI()
				for _, layoutValue in ipairs(qaFrames) do
					local uiScale = layoutValue:FindFirstChildOfClass("UIScale")

					if uiScale then
						uiScale.Scale = uiScaleValue / 100
					end
				end
			end

			local function featureHelperAJ(inputValue, secondaryInput)
				local isActive = false
				local calculatedValue = 0
				local secondaryAmount = 0
				local remainingAmount = 0
				local progress = 0

				local function featureHelperAK()
					if not isActive then
						return
					end
					isActive = false
					pcall(function()
						if saveConfig then saveConfig() end
						if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					end)
				end

				local function featureHelperAL(input)
					if qaLocked then
						return
					end

					if
						input.UserInputType ~= Enum.UserInputType.Touch
						and input.UserInputType ~= Enum.UserInputType.MouseButton1
					then
						return
					end
					isActive = true
					calculatedValue = input.Position.X
					secondaryAmount = input.Position.Y
					remainingAmount = inputValue.Position.X.Offset
					progress = inputValue.Position.Y.Offset
				end

				local function featureHelperAM(input)
					if not isActive or qaLocked then
						return
					end

					if
						input.UserInputType ~= Enum.UserInputType.Touch
						and input.UserInputType ~= Enum.UserInputType.MouseMovement
					then
						return
					end
					local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
						or Vector2.new(x, y)
					local absoluteSize = inputValue.AbsoluteSize
					local horizontalAmount = math.clamp(
						remainingAmount + input.Position.X - calculatedValue,
-- =====================================================================
-- 070Hub
-- =====================================================================
						0,
						viewportSize.X - absoluteSize.X
					)
					local verticalAmount =
						math.clamp(progress + input.Position.Y - secondaryAmount, 0, viewportSize.Y - absoluteSize.Y)
					inputValue.Position = UDim2.new(0, horizontalAmount, 0, verticalAmount)
				end

				local function featureHelperAN(input)
					if
						input.UserInputType ~= Enum.UserInputType.Touch
						and input.UserInputType ~= Enum.UserInputType.MouseButton1
					then
						return
					end
					featureHelperAK()
				end

				inputValue.InputBegan:Connect(featureHelperAL)
				inputValue.InputChanged:Connect(featureHelperAM)
				inputValue.InputEnded:Connect(featureHelperAN)

				if secondaryInput then
					secondaryInput.InputBegan:Connect(featureHelperAL)
					secondaryInput.InputChanged:Connect(featureHelperAM)
					secondaryInput.InputEnded:Connect(featureHelperAN)
				end

				UserInputService.InputChanged:Connect(function(input)
					if isActive and not qaLocked then
						featureHelperAM(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.Touch
						or input.UserInputType == Enum.UserInputType.MouseButton1
					then
						featureHelperAK()
					end
				end)
			end

			local function featureHelperAK(labelText, inputValue, secondaryInput)
				local rowContainer = Instance.new("Frame", screenGui)
				rowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
				rowContainer.Size = UDim2.new(0, 66, 0, actionContainer)
				rowContainer.Position = UDim2.new(0, inputValue + amount / 2, 0, secondaryInput + actionContainer / 2)
				rowContainer.BackgroundColor3 = borderColor
				rowContainer.BackgroundTransparency = 0.02
				rowContainer.BorderSizePixel = 0
				rowContainer.ZIndex = 30
				rowContainer.Active = true
				rowContainer.ClipsDescendants = true
				rowContainer.Visible = showMobileButtons
				Instance.new("UICorner", rowContainer).CornerRadius = UDim.new(0, 14)
				local uiScale = Instance.new("UIScale", rowContainer)
				uiScale.Scale = uiScaleValue / 100
				rowContainer:SetAttribute("VisionMobileButtonPurple", true)
				local layoutValue = applyPurpleGradient(rowContainer, 90, false)
				layoutValue.Color = createPurpleColorSequence()
				addPurpleGloss(rowContainer, 31)
				local toggleButton = Instance.new("TextButton", rowContainer)
				toggleButton.Size = UDim2.new(1, 0, 1, 0)
				toggleButton.BackgroundTransparency = 1
				toggleButton.Text = labelText
				toggleButton.TextColor3 = textColor
				toggleButton.Font = Enum.Font.GothamBlack
				toggleButton.TextSize = 9
				toggleButton.TextWrapped = true
				toggleButton.TextStrokeTransparency = 1
				toggleButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				toggleButton.ZIndex = 32
				toggleButton.AutoButtonColor = false
				toggleButton.Active = true
				toggleButton.Selectable = true

				toggleButton.InputBegan:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.Touch
						or input.UserInputType == Enum.UserInputType.MouseButton1
					then
						local animationProperties = { Scale = uiScaleValue / 100 * 0.92 }
						TweenService:Create(
							uiScale,
							TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							animationProperties
						):Play()
					end
				end)

				toggleButton.InputEnded:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.Touch
						or input.UserInputType == Enum.UserInputType.MouseButton1
					then
						local animationProperties = { Scale = uiScaleValue / 100 }
						TweenService:Create(
							uiScale,
							TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							animationProperties
						):Play()
					end
				end)

				table.insert(qaFrames, rowContainer)
				table.insert(qaDefaultPos, { inputValue + amount / 2, secondaryInput + actionContainer / 2 })
				featureHelperAJ(rowContainer, toggleButton)
				return rowContainer, toggleButton, layoutValue
			end

			local calculatedValue = math.max(12, x - amount * 2 + 10 + 14)
			local secondaryAmount = math.floor(y / 2 - (actionContainer * 6 + 40) / 2)

			local function featureHelperAL(inputValue, secondaryInput, tertiaryInput)
				if not inputValue or not inputValue.Parent then
					return
				end
				TweenService:Create(inputValue, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = tertiaryInput and secondaryColor or borderColor,
					BackgroundTransparency = 0.02,
				}):Play()

				if secondaryInput then
					secondaryInput.Enabled = tertiaryInput == true
				end

				setPurpleControlActive(inputValue, tertiaryInput)
				local toggleButton = inputValue:FindFirstChildOfClass("TextButton")

				if toggleButton then
					toggleButton.TextStrokeTransparency = 1
				end
			end

			local layoutValue, scaleController, sectionContainer =
				featureHelperAK("DROP\nBRAINROT", calculatedValue, secondaryAmount)
			-- BAT AIMBOT = Normal (Vision) | BAT V2 = Bypass
			local secondCandidate, thirdCandidate, fourthCandidate =
				featureHelperAK("BAT\nAIMBOT", calculatedValue + amount + 10, secondaryAmount)
			local batV2Frame, batV2Btn, batV2Stroke =
				featureHelperAK("BAT\nV2", calculatedValue, secondaryAmount + actionContainer + 10)
			local eighthCandidate, ninthCandidate, tenthCandidate =
				featureHelperAK("TP\nDOWN", calculatedValue + amount + 10, secondaryAmount + actionContainer + 10)
			local eleventhCandidate, twelfthCandidate, thirteenthCandidate = featureHelperAK(
				"CARRY\nSPD",
				calculatedValue,
				secondaryAmount + (actionContainer + 10) * 2
			)
			local fourteenthCandidate, fifteenthCandidate, sixteenthCandidate =
				featureHelperAK("LAGGER\nNORMAL", calculatedValue + amount + 10, secondaryAmount + (actionContainer + 10) * 2)
			local laggerButton, laggerButtonLabel, laggerButtonStroke = featureHelperAK(
				"LAGGER\nCARRY",
				calculatedValue,
				secondaryAmount + (actionContainer + 10) * 3
			)

			-- Reliable mobile/PC tap (drag handlers on parent often block Activated)
			local function bindMobileTap(btn, fn)
				if not btn then return end
				btn.Active = true
				btn.Selectable = true
				btn.AutoButtonColor = false
				local downPos, downClock
				local function run()
					pcall(fn)
				end
				btn.Activated:Connect(run)
				btn.MouseButton1Click:Connect(run)
				btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch
						or input.UserInputType == Enum.UserInputType.MouseButton1 then
						downPos = input.Position
						downClock = os.clock()
					end
				end)
				btn.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.Touch
						and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end
					if not downPos then return end
					local moved = (input.Position - downPos).Magnitude
					local dt = os.clock() - (downClock or 0)
					downPos = nil
					-- treat as tap if not dragged far
					if moved < 24 and dt < 0.5 then
						run()
					end
				end)
			end

			bindMobileTap(scaleController, function()
				if dropActive then return end
				task.spawn(featureHelperB)
			end)

			local function toggleBatAimbot(modeName, frame, stroke)
				local isThisMode = autoBatEnabled and tostring(autoBatMode) == modeName
				local wantOn = not isThisMode
				if wantOn then
					autoBatMode = modeName
					pcall(function()
						if refreshAutoBatModeControls then
							refreshAutoBatModeControls(modeName == "AntiBatBypass")
						end
					end)
					-- restart if already on different mode
					if autoBatEnabled and type(disableAutoBat) == "function" then
						pcall(disableAutoBat)
						autoBatEnabled = false
					end
					local ok = false
					if type(queueAutoBatStart) == "function" then
						ok = queueAutoBatStart() == true
					elseif type(enableAutoBat) == "function" then
						ok = enableAutoBat() == true
					end
					autoBatEnabled = ok and true or false
				else
					if type(disableAutoBat) == "function" then
						disableAutoBat()
					end
					autoBatEnabled = false
				end
				if autoBatSetVisual then
					autoBatSetVisual(autoBatEnabled == true)
				end
				-- highlight correct button
				local normalOn = autoBatEnabled and tostring(autoBatMode) == "Vision"
				local bypassOn = autoBatEnabled and tostring(autoBatMode) == "AntiBatBypass"
				featureHelperAL(secondCandidate, fourthCandidate, normalOn)
				featureHelperAL(batV2Frame, batV2Stroke, bypassOn)
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					if saveConfig then saveConfig() end
				end)
			end

			-- BAT AIMBOT = Normal (Vision)
			bindMobileTap(thirdCandidate, function()
				toggleBatAimbot("Vision", secondCandidate, fourthCandidate)
			end)

			-- BAT V2 = Bypass
			bindMobileTap(batV2Btn, function()
				toggleBatAimbot("AntiBatBypass", batV2Frame, batV2Stroke)
			end)

			bindMobileTap(ninthCandidate, function()
				task.spawn(featureHelperC)
				featureHelperAL(eighthCandidate, tenthCandidate, true)
				task.delay(0.1, function()
					featureHelperAL(eighthCandidate, tenthCandidate, false)
				end)
			end)

			-- CARRY SPD
			bindMobileTap(twelfthCandidate, function()
				if type(toggleCarryMode) == "function" then
					toggleCarryMode()
				else
					if laggerToggled then
						laggerToggled = false
						laggerPhase = 0
						speedMode = true
					else
						speedMode = not speedMode
					end
					if refreshSpeedModeLabel then refreshSpeedModeLabel() end
				end
				featureHelperAL(eleventhCandidate, thirteenthCandidate, speedMode == true)
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					if saveConfig then saveConfig() end
				end)
			end)

			-- LAGGER CARRY (phase 2)
			bindMobileTap(laggerButtonLabel, function()
				if laggerToggled and laggerPhase == 2 then
					laggerToggled = false
					laggerPhase = 0
				else
					speedMode = false
					laggerToggled = true
					laggerPhase = 2
				end
				if refreshSpeedModeLabel then refreshSpeedModeLabel() end
				featureHelperAL(laggerButton, laggerButtonStroke, laggerToggled and laggerPhase == 2)
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					if saveConfig then saveConfig() end
				end)
			end)

			-- LAGGER NORMAL (phase 1)
			bindMobileTap(fifteenthCandidate, function()
				if laggerToggled and laggerPhase == 1 then
					laggerToggled = false
					laggerPhase = 0
				else
					speedMode = false
					laggerToggled = true
					laggerPhase = 1
				end
				if refreshSpeedModeLabel then refreshSpeedModeLabel() end
				featureHelperAL(fourteenthCandidate, sixteenthCandidate, laggerToggled and laggerPhase == 1)
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					if saveConfig then saveConfig() end
				end)
			end)

			local isActive = false
			local isReady = false
			local isComplete = false
			local lastLaggerState = false
			local lastCarryState = false
			local lastSpeedState = false
			local isWaitingForInput = false

			RunService.Heartbeat:Connect(function()
				if autoLeftEnabled ~= isActive then
					isActive = autoLeftEnabled
					featureHelperAL(configValue, firstCandidate, isActive)
				end

				if autoRightEnabled ~= isReady then
					isReady = autoRightEnabled
					featureHelperAL(fifthCandidate, seventhCandidate, isReady)
				end

				do
					local normalOn = autoBatEnabled and tostring(autoBatMode) == "Vision"
					local bypassOn = autoBatEnabled and tostring(autoBatMode) == "AntiBatBypass"
					if normalOn ~= isComplete then
						isComplete = normalOn
						featureHelperAL(secondCandidate, fourthCandidate, normalOn)
					end
					if bypassOn ~= lastBatV2State then
						lastBatV2State = bypassOn
						featureHelperAL(batV2Frame, batV2Stroke, bypassOn)
					end
				end

				if dropActive ~= lastLaggerState then
					lastLaggerState = dropActive
					featureHelperAL(layoutValue, sectionContainer, lastLaggerState)
				end

				if speedMode ~= lastCarryState then
					lastCarryState = speedMode
-- =====================================================================
-- 070Hub
-- =====================================================================
					featureHelperAL(eleventhCandidate, thirteenthCandidate, lastCarryState)
				end

				local isControllerInput = laggerToggled and laggerPhase == 2
				local isCandidate = laggerToggled and laggerPhase == 1

				if isControllerInput ~= lastSpeedState then
					lastSpeedState = isControllerInput
					featureHelperAL(laggerButton, laggerButtonStroke, lastSpeedState)
				end

				if isCandidate ~= isWaitingForInput then
					isWaitingForInput = isCandidate
					featureHelperAL(fourteenthCandidate, sixteenthCandidate, isWaitingForInput)
				end

			end)

			featureHelperAI()
		end

		-- restore saved mobile button positions
		pcall(function()
			local positions = nil
			local persist = getgenv()._070Persist or _G._070Persist
			if type(persist) == "table" and type(persist.qaPositions) == "table" then
				positions = persist.qaPositions
			end
			if type(positions) ~= "table" and type(_savedCfg) == "table" then
				positions = _savedCfg.qaPositions
			end
			if type(positions) == "table" then
				for i, qaPosition in ipairs(positions) do
					if qaFrames[i] and type(qaPosition) == "table" and qaPosition[1] and qaPosition[2] then
						qaFrames[i].Position = UDim2.new(0, qaPosition[1], 0, qaPosition[2])
					end
				end
			end
		end)
		refreshQuickActionVisibility()
		
		-- Bat skins + trails (burger wallpaper visuals)
		do
			local settingsRow = createFrame(40)
			createTextLabel(settingsRow, "Bat Skin")
			local skins = { "Original", "Katana", "Neon Bat", "Obsidian", "Crimson Katana", "Crystal Blade", "War Hammer" }
			local idx = 1
			local cur = "Original"
			pcall(function()
				local pending = getgenv()._070PendingBatSkin
				if type(pending) == "string" and pending ~= "" then
					cur = pending
					if getgenv()._070SetBatSkin then getgenv()._070SetBatSkin(pending) end
				end
				local list, current = getgenv()._070GetBatSkins()
				if type(list) == "table" then skins = list end
				if type(current) == "string" and current ~= "" then cur = current end
				local persist = getgenv()._070Persist
				if type(persist) == "table" and type(persist.batSkin) == "string" then
					cur = persist.batSkin
				end
			end)
			for i, n in ipairs(skins) do
				if n == cur then idx = i break end
			end
			local btn = Instance.new("TextButton", settingsRow)
			btn.Size = UDim2.new(0, 120, 0, 26)
			btn.Position = UDim2.new(1, -130, 0.5, -13)
			btn.BackgroundColor3 = Color3.fromRGB(30, 28, 45)
			btn.BackgroundTransparency = 0.15
			btn.BorderSizePixel = 0
			btn.Text = tostring(skins[idx])
			btn.TextColor3 = Color3.fromRGB(210, 190, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 11
			btn.AutoButtonColor = false
			btn.ZIndex = 6
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
			btn.MouseButton1Click:Connect(function()
				idx = idx % #skins + 1
				btn.Text = skins[idx]
				pcall(function()
					if getgenv()._070SetBatSkin then
						getgenv()._070SetBatSkin(skins[idx])
					end
				end)
				pcall(saveConfig)
			end)
		end

		do
			local settingsRow = createFrame(40)
			createTextLabel(settingsRow, "Motion Trails")
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(settingsRow, 28)
			local isActive = false
			pcall(function()
				if getgenv()._070GetTrails then
					isActive = getgenv()._070GetTrails() == true
				end
			end)
			local function paint(on)
				isActive = on
				featureHelperAC(optionRow, toggleBorder, on)
			end
			paint(isActive)
			local detailControl = Instance.new("TextButton", toggleContainer)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 5
			detailControl.Activated:Connect(function()
				if isKeybindLocked and isKeybindLocked() then return end
				paint(not isActive)
				pcall(function()
					if getgenv()._070SetTrails then
						getgenv()._070SetTrails(isActive)
					end
				end)
				pcall(saveConfig)
			end)
		end

featureHelperZ("UI Settings")
		local actionContainer = createFrame(32)
		createTextLabel(actionContainer, "UI Toggle")

		createTextButton(actionContainer, KB.GuiHide, function(gp, inputValue)
			if inputValue then
				KB.GuiHide.gp = gp
				KB.GuiHide.kb = nil
			else
				KB.GuiHide.kb = gp
				KB.GuiHide.gp = nil
			end

			featureHelperP()
			saveConfig()
		end)

		setShowUIOnExecuteVisual = featureHelperAD("Show UI on Execute", function(inputValue)
			showUIOnExecute = inputValue
			saveConfig()
		end)

		if setShowUIOnExecuteVisual then
			setShowUIOnExecuteVisual(showUIOnExecute)
		end

		setShowSpeedBypassPanelVisual = function() end
		showSpeedBypassPanel = false
		isSpeedPanelDismissed = true

		if setShowSpeedBypassPanelVisual then
			setShowSpeedBypassPanelVisual(showSpeedBypassPanel)
		end

		featureHelperZ("Mobile UI Settings")
		local layoutValue = createFrame(32)
		createTextLabel(layoutValue, "UI Size")

		scaleBox = createTextBox(layoutValue, uiScaleValue, 50, 56, function(inputValue)
			uiScaleValue = math.clamp(math.floor(inputValue + 0.5), 50, 125)

			if mainGuiScale then
				mainGuiScale.Scale = uiScaleValue / 100
			end

			if progressBarScale then
				progressBarScale.Scale = uiScaleValue / 100
			end

			for _, scaleController in ipairs(qaFrames) do
				local sectionContainer = scaleController:FindFirstChildOfClass("UIScale")

				if sectionContainer then
					sectionContainer.Scale = uiScaleValue / 100
				end
			end

			if speedBypassPanel then
				local scaleController = speedBypassPanel:FindFirstChildOfClass("UIScale")

				if scaleController then
					scaleController.Scale = uiScaleValue / 100
				end
			end

			if scaleBox then
				scaleBox.Text = tostring(uiScaleValue)
			end

			saveConfig()
		end)

		setShowMobileButtonsVisual = featureHelperAD("Show Mobile Buttons", function(inputValue)
			showMobileButtons = inputValue
			refreshQuickActionVisibility()
			saveConfig()
		end)

		if setShowMobileButtonsVisual then
			setShowMobileButtonsVisual(showMobileButtons)
		end

		setLockMobileButtonsVisual = featureHelperAD("Lock Mobile Buttons", function(inputValue)
			qaLocked = inputValue
			saveConfig()
		end)

		-- Speed Bypass option removed completely
		showSpeedBypassPanel = false

		if setLockMobileButtonsVisual then
			setLockMobileButtonsVisual(qaLocked)
		end

		do
			local row = createFrame(40)
			createTextLabel(row, "Auto Steal UI")
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(row, 28)
			local function setVis(v)
				featureHelperAC(optionRow, toggleBorder, v == true)
			end
			setVis(_G._070HideStealBarUI ~= true)
			local btn = Instance.new("TextButton", toggleContainer)
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.ZIndex = 5
			btn.Activated:Connect(function()
				local show = (_G._070HideStealBarUI == true) -- if currently hidden, show next
				_G._070HideStealBarUI = not show
				setVis(show)
				pcall(function()
					if getgenv()._070SetStealBarHidden then
						getgenv()._070SetStealBarHidden(not show)
					end
				end)
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					if saveConfig then saveConfig() end
				end)
			end)
		end


		do
			local stealBarRow = createFrame(32)
			createTextLabel(stealBarRow, "Steal Bar Size")
			stealBarScaleBox = createTextBox(stealBarRow, stealBarScaleValue or 100, 50, 56, function(inputValue)
				stealBarScaleValue = math.clamp(math.floor((tonumber(inputValue) or 100) + 0.5), 50, 200)
				pcall(function()
					if getgenv()._070ApplyStealBarScale then
						getgenv()._070ApplyStealBarScale(stealBarScaleValue)
					end
				end)
				if stealBarScaleBox then
					stealBarScaleBox.Text = tostring(stealBarScaleValue)
				end
				pcall(function()
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
					if saveConfig then saveConfig() end
				end)
			end)
		end

		-- UI Color option removed

		do
			local scaleController = createFrame(32)
			local detailControl = Instance.new("TextLabel", scaleController)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = "Reset Mobile Button Positions"
			detailControl.TextColor3 = Color3.fromRGB(255, 255, 255)
			detailControl.TextStrokeTransparency = 1
			detailControl.TextTransparency = 0
			detailControl.Font = Enum.Font.GothamBold
			detailControl.TextSize = 11
			detailControl.TextXAlignment = Enum.TextXAlignment.Center
			detailControl.ZIndex = 5
			local toggleButton = Instance.new("TextButton", scaleController)
			toggleButton.Size = UDim2.new(1, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = ""
			toggleButton.ZIndex = 2

			toggleButton.Activated:Connect(function()
				for i, sectionContainer in ipairs(qaFrames) do
					if qaDefaultPos[i] then
						sectionContainer.Position = UDim2.new(0, qaDefaultPos[i][1], 0, qaDefaultPos[i][2])
					end
				end
-- =====================================================================
-- 070Hub
-- =====================================================================

				saveConfig()
			end)
		end


		featureHelperZ("Animations")

		do
			local headerRow = createFrame(40)
			createTextLabel(headerRow, "Anim Pack")

			local currentName = "Off"
			pcall(function()
				local n, on = nil, false
				if getgenv()._070GetAnimPack then
					n, on = getgenv()._070GetAnimPack()
				end
				if on == true and type(n) == "string" and n ~= "" then
					currentName = n
				end
			end)

			local selectedLbl = Instance.new("TextLabel", headerRow)
			selectedLbl.Name = "AnimPackSelected"
			selectedLbl.Size = UDim2.new(0, 86, 0, 24)
			selectedLbl.Position = UDim2.new(1, -176, 0.5, -12)
			selectedLbl.BackgroundTransparency = 1
			selectedLbl.Text = currentName
			selectedLbl.TextColor3 = Color3.fromRGB(185, 160, 255)
			selectedLbl.Font = Enum.Font.GothamBold
			selectedLbl.TextSize = 10
			selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
			selectedLbl.TextTruncate = Enum.TextTruncate.AtEnd
			selectedLbl.ZIndex = 25
			selectedLbl.Active = false

			local openBtn = Instance.new("TextButton", headerRow)
			openBtn.Name = "AnimPackOpenBtn"
			openBtn.Size = UDim2.new(0, 80, 0, 28)
			openBtn.Position = UDim2.new(1, -84, 0.5, -14)
			openBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
			openBtn.BackgroundTransparency = 0
			openBtn.Text = "Open"
			openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			openBtn.Font = Enum.Font.GothamBold
			openBtn.TextSize = 13
			openBtn.ZIndex = 30
			openBtn.Active = true
			openBtn.Selectable = true
			openBtn.AutoButtonColor = true
			Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)

			local animPanelGui = nil
			local lastToggle = 0
			local opening = false

			local function closeAnimPanel()
				if animPanelGui then
					pcall(function() animPanelGui:Destroy() end)
				end
				animPanelGui = nil
				opening = false
				openBtn.Text = "Open"
			end

			local function getPackNames()
				local packNames = { "Off" }
				pcall(function()
					local packs = getgenv()._070AnimPacks
					if type(packs) ~= "table" then packs = rawget(_G, "ANIMATION_PACKS") end
					if type(packs) == "table" then
						local keys = {}
						for k in pairs(packs) do
							if type(k) == "string" then table.insert(keys, k) end
						end
						table.sort(keys)
						for _, k in ipairs(keys) do table.insert(packNames, k) end
					end
				end)
				if #packNames <= 1 then
					for _, k in ipairs({
						"Adidas Sports", "Adidas Community", "Ninja", "Robot",
						"Stylish", "Superhero", "Toy", "Zombie", "Cartoony", "Elder"
					}) do
						table.insert(packNames, k)
					end
				end
				return packNames
			end

			local function openAnimPanel(forceClose)
				local now = tick()
				if now - lastToggle < 0.35 then
					return -- ignore double-fire from Activated+Click+Touch
				end
				lastToggle = now

				if forceClose or (animPanelGui and animPanelGui.Parent) then
					closeAnimPanel()
					return
				end
				if opening then return end
				opening = true

				local ok, err = pcall(function()
					closeAnimPanel()
					opening = true
					openBtn.Text = "Close"

					local gui = Instance.new("ScreenGui")
					gui.Name = "070AnimPackPanel"
					gui.ResetOnSpawn = false
					gui.IgnoreGuiInset = true
					gui.DisplayOrder = 10000
					gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
					gui.Enabled = true

					local parented = false
					pcall(function()
						if gethui then
							gui.Parent = gethui()
							parented = gui.Parent ~= nil
						end
					end)
					if not parented then
						pcall(function()
							gui.Parent = game:GetService("CoreGui")
							parented = gui.Parent ~= nil
						end)
					end
					if not parented then
						gui.Parent = localPlayer:WaitForChild("PlayerGui")
					end
					animPanelGui = gui
					pcall(function()
						if getgenv().__yenProtectGui then getgenv().__yenProtectGui(gui) end
					end)

					local frame = Instance.new("Frame")
					frame.Size = UDim2.fromOffset(280, 360)
					frame.Position = UDim2.new(0.5, -140, 0.5, -180)
					frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
					frame.BorderSizePixel = 0
					frame.ZIndex = 100
					frame.Active = true
					frame.Parent = gui
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
					local fst = Instance.new("UIStroke", frame)
					fst.Color = Color3.fromRGB(140, 120, 255)
					fst.Thickness = 1.5

					local title = Instance.new("TextLabel", frame)
					title.Size = UDim2.new(1, -48, 0, 36)
					title.Position = UDim2.new(0, 14, 0, 6)
					title.BackgroundTransparency = 1
					title.Text = "Animation Packs"
					title.TextColor3 = Color3.fromRGB(185, 160, 255)
					title.Font = Enum.Font.GothamBlack
					title.TextSize = 16
					title.TextXAlignment = Enum.TextXAlignment.Left
					title.ZIndex = 101

					local close = Instance.new("TextButton", frame)
					close.Size = UDim2.fromOffset(30, 30)
					close.Position = UDim2.new(1, -38, 0, 8)
					close.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
					close.Text = "X"
					close.TextColor3 = Color3.fromRGB(255, 255, 255)
					close.Font = Enum.Font.GothamBold
					close.TextSize = 14
					close.ZIndex = 102
					close.AutoButtonColor = true
					Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
					close.Activated:Connect(closeAnimPanel)
					close.MouseButton1Click:Connect(closeAnimPanel)

					local scroll = Instance.new("ScrollingFrame", frame)
					scroll.Size = UDim2.new(1, -20, 1, -54)
					scroll.Position = UDim2.new(0, 10, 0, 46)
					scroll.BackgroundTransparency = 1
					scroll.BorderSizePixel = 0
					scroll.ScrollBarThickness = 5
					scroll.ScrollBarImageColor3 = Color3.fromRGB(140, 120, 255)
					scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
					scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
					scroll.ZIndex = 101
					scroll.Active = true
					local lay = Instance.new("UIListLayout", scroll)
					lay.Padding = UDim.new(0, 6)
					lay.SortOrder = Enum.SortOrder.LayoutOrder

					local packNames = getPackNames()
					for order, name in ipairs(packNames) do
						local b = Instance.new("TextButton", scroll)
						b.Size = UDim2.new(1, -6, 0, 36)
						b.BackgroundColor3 = (name == currentName) and Color3.fromRGB(70, 50, 130) or Color3.fromRGB(24, 22, 36)
						b.Text = "  " .. name
						b.TextColor3 = Color3.fromRGB(240, 235, 255)
						b.Font = Enum.Font.GothamBold
						b.TextSize = 13
						b.TextXAlignment = Enum.TextXAlignment.Left
						b.AutoButtonColor = true
						b.LayoutOrder = order
						b.ZIndex = 102
						Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
						b.Activated:Connect(function()
							currentName = name
							selectedLbl.Text = name
							pcall(function()
								if name == "Off" then
									if getgenv()._070SetAnimPack then getgenv()._070SetAnimPack(nil) end
									if getgenv()._070ClearAnimPack then getgenv()._070ClearAnimPack() end
									getgenv()._070PendingAnimPack = nil
								else
									if getgenv()._070SetAnimPack then getgenv()._070SetAnimPack(name) end
									getgenv()._070PendingAnimPack = name
								end
								if saveConfig then saveConfig() end
								if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
							end)
							for _, ch in ipairs(scroll:GetChildren()) do
								if ch:IsA("TextButton") then
									local on = ch.Text:gsub("^%s+", "") == name
									ch.BackgroundColor3 = on and Color3.fromRGB(70, 50, 130) or Color3.fromRGB(24, 22, 36)
								end
							end
						end)
					end

					-- drag panel
					local dragging, dragStart, startPos
					title.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							dragStart = input.Position
							startPos = frame.Position
						end
					end)
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
						end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if not dragging then return end
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							local d = input.Position - dragStart
							frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
						end
					end)
					opening = false
				end)
				if not ok then
					opening = false
					openBtn.Text = "Open"
					pcall(function()
						local rp = getgenv()._070RealPrint or print
						rp("[070] Anim pack panel error:", err)
					end)
				end
			end

			-- ONE click path only (Activated+Click was opening then instantly closing)
			openBtn.Activated:Connect(function()
				openAnimPanel()
			end)

			getgenv()._070ToggleAnimPackPanel = openAnimPanel
			getgenv()._070OpenAnimPackPanel = openAnimPanel
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if isKeybindLocked() then
				return
			end

			if input.UserInputType == Enum.UserInputType.Keyboard then
				if UserInputService:GetFocusedTextBox() then
					return
				end
			elseif not featureHelperAE(input) then
				return
			end

			if not featureHelperAF(input) then
				return
			end
			local keyCode = input.KeyCode
			if gameProcessed then
				return
			end
			local scaleController = featureHelperAG(KB.GuiHide, keyCode)
			local sectionContainer = featureHelperAG(KB.SpeedBypassGui, keyCode)

			if scaleController or sectionContainer then
				if scaleController then
					featureHelperX(not primaryValue)
				end

				if sectionContainer then
					isSpeedPanelDismissed = not isSpeedPanelDismissed
					featureHelperS()
				end

				return
			end

			if featureHelperAG(KB.LaggerToggle, keyCode) then
				toggleLaggerMode()
				saveConfig()
			elseif featureHelperAG(KB.SpeedToggle, keyCode) then
				toggleCarryMode()
				saveConfig()
			elseif featureHelperAG(KB.DropBrainrot, keyCode) then
				featureHelperB()
			elseif featureHelperAG(KB.TPFloor, keyCode) then
				featureHelperC()
			elseif featureHelperAG(KB.DesyncAimbot, keyCode) then
				-- keybind removed for Anti Die; ignore
				saveConfig()
			elseif featureHelperAG(KB.SpeedBypassToggle, keyCode) then
				featureHelperQ()
			elseif featureHelperAG(KB.AutoLeft, keyCode) then
				autoLeftEnabled = not autoLeftEnabled

				if autoLeftEnabled then
					queueAutoLeftStart()
				else
					stopAutoLeft()
				end

				if autoLeftSetVisual then
					autoLeftSetVisual(autoLeftEnabled)
				end
			elseif featureHelperAG(KB.AutoRight, keyCode) then
				autoRightEnabled = not autoRightEnabled

				if autoRightEnabled then
					queueAutoRightStart()
				else
					stopAutoRight()
				end

				if autoRightSetVisual then
					autoRightSetVisual(autoRightEnabled)
				end
			elseif featureHelperAG(KB.AutoBat, keyCode) then
				if not autoBatEnabled then
					local configValue = queueAutoBatStart()

					if autoBatSetVisual then
						autoBatSetVisual(configValue == true)
					end
				else
					disableAutoBat()

					if autoBatSetVisual then
						autoBatSetVisual(false)
					end
				end
			elseif KB.BypassAimbot and featureHelperAG(KB.BypassAimbot, keyCode) then
				-- toggle Bypass Aimbot mode (AntiBatBypass)
				local inBypass = (tostring(autoBatMode or "") == "AntiBatBypass") and autoBatEnabled == true
				if inBypass then
					-- turn OFF
					disableAutoBat()
					if autoBatSetVisual then autoBatSetVisual(false) end
				else
					-- turn ON in bypass mode
					autoBatMode = "AntiBatBypass"
					pcall(function()
						if getgenv()._070StopAutoBatV3 then pcall(getgenv()._070StopAutoBatV3) end
						if refreshAutoBatModeControls then refreshAutoBatModeControls() end
					end)
					if not autoBatEnabled then
						local configValue = queueAutoBatStart()
						if autoBatSetVisual then autoBatSetVisual(configValue == true) end
					else
						if autoBatSetVisual then autoBatSetVisual(true) end
					end
				end
				pcall(function() if saveConfig then saveConfig() end end)
				pcall(function() if getgenv()._070SaveAll then getgenv()._070SaveAll() end end)
			end
		end)

		if primaryValue then
			featureHelperY()
		else
			primaryControl.Visible = false
			headerButton.Visible = true
			headerButton.BackgroundTransparency = 0.03
			headerButton.Text = "070Hub"
			headerButton.TextColor3 = Color3.fromRGB(110, 130, 255)
			headerButton.TextTransparency = 0
			imageLabel.ImageTransparency = 1
			strokeControl.Scale = 1
			overlayControl.Transparency = 0.18
			overlayControl.Thickness = 2
		end

		-- ===================== SETTINGS: SAVE / RESET CONFIG =====================
		featureHelperZ("Settings")


		-- Spin Bot panel toggle
		do
			local settingsRow = createFrame(40)
			createTextLabel(settingsRow, "Spin Bot")
			local toggleContainer, optionRow, toggleBorder = featureHelperAB(settingsRow, 28)
			local isActive = getgenv()._070SpinBotEnabled == true
			local function paint(on)
				isActive = on == true
				featureHelperAC(optionRow, toggleBorder, isActive)
			end
			paint(isActive)
			local detailControl = Instance.new("TextButton", toggleContainer)
			detailControl.Size = UDim2.new(1, 0, 1, 0)
			detailControl.BackgroundTransparency = 1
			detailControl.Text = ""
			detailControl.ZIndex = 5
			detailControl.Activated:Connect(function()
				if isKeybindLocked and isKeybindLocked() then return end
				paint(not isActive)
				pcall(function()
					if getgenv()._070SetSpinBot then
						getgenv()._070SetSpinBot(isActive)
					end
				end)
			end)
			if isActive then
				task.defer(function()
					task.wait(0.6)
					pcall(function()
						if getgenv()._070SetSpinBot then getgenv()._070SetSpinBot(true) end
					end)
				end)
			end
		end


		-- Motion Trails + Halo color pickers (Config)
		do
			local PRESETS = {
				{ name = "Purple", c = Color3.fromRGB(185, 100, 255) },
				{ name = "Blue", c = Color3.fromRGB(70, 150, 255) },
				{ name = "Cyan", c = Color3.fromRGB(60, 220, 255) },
				{ name = "Green", c = Color3.fromRGB(40, 200, 90) },
				{ name = "Red", c = Color3.fromRGB(230, 50, 60) },
				{ name = "Pink", c = Color3.fromRGB(255, 90, 180) },
				{ name = "Orange", c = Color3.fromRGB(255, 150, 50) },
				{ name = "White", c = Color3.fromRGB(245, 245, 255) },
			}

			local function makeColorRow(title, getColor, setColor)
				local row = createFrame(36)
				createTextLabel(row, title)
				local preview = Instance.new("Frame", row)
				preview.Size = UDim2.new(0, 18, 0, 18)
				preview.Position = UDim2.new(1, -168, 0.5, -9)
				preview.BorderSizePixel = 0
				preview.ZIndex = 8
				Instance.new("UICorner", preview).CornerRadius = UDim.new(1, 0)
				pcall(function()
					local c = getColor()
					if typeof(c) == "Color3" then preview.BackgroundColor3 = c end
				end)

				local openBtn = Instance.new("TextButton", row)
				openBtn.Size = UDim2.new(0, 72, 0, 24)
				openBtn.Position = UDim2.new(1, -78, 0.5, -12)
				openBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
				openBtn.BackgroundTransparency = 0.1
				openBtn.Text = "Color"
				openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				openBtn.Font = Enum.Font.GothamBold
				openBtn.TextSize = 12
				openBtn.ZIndex = 8
				openBtn.AutoButtonColor = false
				Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 7)

				local palette = createFrame(40)
				palette.Visible = false
				palette.Size = UDim2.new(1, 0, 0, 0)
				palette.BackgroundTransparency = 1
				palette.ClipsDescendants = true

				local holder = Instance.new("Frame", palette)
				holder.Size = UDim2.new(1, -10, 1, -6)
				holder.Position = UDim2.new(0, 5, 0, 3)
				holder.BackgroundTransparency = 1
				holder.ZIndex = 9
				local lay = Instance.new("UIListLayout", holder)
				lay.FillDirection = Enum.FillDirection.Horizontal
				lay.Padding = UDim.new(0, 4)
				lay.HorizontalAlignment = Enum.HorizontalAlignment.Left
				lay.VerticalAlignment = Enum.VerticalAlignment.Center

				local open = false
				local function setOpen(v)
					open = v
					openBtn.Text = v and "Close" or "Color"
					if v then
						palette.Visible = true
						palette.Size = UDim2.new(1, 0, 0, 36)
					else
						palette.Size = UDim2.new(1, 0, 0, 0)
						palette.Visible = false
					end
				end

				for _, p in ipairs(PRESETS) do
					local sw = Instance.new("TextButton", holder)
					sw.Size = UDim2.new(0, 28, 0, 28)
					sw.BackgroundColor3 = p.c
					sw.Text = ""
					sw.ZIndex = 10
					sw.AutoButtonColor = true
					Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
					local stroke = Instance.new("UIStroke", sw)
					stroke.Color = Color3.fromRGB(255, 255, 255)
					stroke.Transparency = 0.7
					stroke.Thickness = 1
					sw.Activated:Connect(function()
						pcall(function() setColor(p.c) end)
						preview.BackgroundColor3 = p.c
						setOpen(false)
						pcall(function() if saveConfig then saveConfig() end end)
					end)
				end

				openBtn.Activated:Connect(function()
					if isKeybindLocked and isKeybindLocked() then return end
					setOpen(not open)
				end)
			end

			makeColorRow("Trails Color", function()
				if getgenv()._070GetTrailColor then
					return getgenv()._070GetTrailColor()
				end
				return Color3.fromRGB(170, 120, 255)
			end, function(c)
				if getgenv()._070SetTrailColor then
					getgenv()._070SetTrailColor(c)
				end
			end)

			makeColorRow("Halo Color", function()
				if getgenv()._070GetHaloColor then
					return getgenv()._070GetHaloColor()
				end
				return Color3.fromRGB(190, 110, 255)
			end, function(c)
				if getgenv()._070SetHaloColor then
					getgenv()._070SetHaloColor(c)
				end
			end)
		end

		-- Wallpaper picker (Config / Settings)
		do
			local WALLPAPERS = {
				{ name = "Default", id = "103010175848787" },
				{ name = "New", id = "99175615017066" },
				{ name = "White", id = "124210976977975" },
				{ name = "Black", id = "123207688823036" },
				{ name = "Pink", id = "116660005581591" },
				{ name = "A", id = "109091384423844" },
				{ name = "B", id = "132283695161729" },
				{ name = "C", id = "82086972847508" },
				{ name = "No Background", id = "none" },
			}

			local row = createFrame(36)
			createTextLabel(row, "Wallpaper")
			local openBtn = Instance.new("TextButton")
			openBtn.Size = UDim2.new(0, 72, 0, 24)
			openBtn.Position = UDim2.new(1, -80, 0.5, -12)
			openBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
			openBtn.Text = "Open"
			openBtn.TextColor3 = Color3.fromRGB(220, 210, 255)
			openBtn.Font = Enum.Font.GothamBold
			openBtn.TextSize = 11
			openBtn.AutoButtonColor = false
			openBtn.Parent = row
			Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

			local function openWallpaperUI()
				pcall(function()
					for _, parent in ipairs({ game:GetService("CoreGui"), localPlayer:FindFirstChild("PlayerGui") }) do
						if parent then
							local old = parent:FindFirstChild("070WallpaperUI")
							if old then old:Destroy() end
						end
					end
				end)

				local gui = Instance.new("ScreenGui")
				gui.Name = "070WallpaperUI"
				gui.ResetOnSpawn = false
				gui.IgnoreGuiInset = true
				gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				pcall(function() gui.Parent = game:GetService("CoreGui") end)
				if not gui.Parent then gui.Parent = localPlayer:WaitForChild("PlayerGui") end

				local panel = Instance.new("Frame")
				panel.Size = UDim2.fromOffset(292, 300)
				panel.Position = UDim2.new(0.5, -146, 0.5, -150)
				panel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
				panel.BorderSizePixel = 0
				panel.ClipsDescendants = false
				panel.Parent = gui
				Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
				local st = Instance.new("UIStroke")
				st.Color = Color3.fromRGB(100, 90, 180)
				st.Thickness = 1.2
				st.Parent = panel

				local title = Instance.new("TextLabel")
				title.Size = UDim2.new(1, -40, 0, 28)
				title.Position = UDim2.fromOffset(12, 6)
				title.BackgroundTransparency = 1
				title.Font = Enum.Font.GothamBlack
				title.TextSize = 14
				title.TextColor3 = Color3.fromRGB(230, 220, 255)
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Text = "WALLPAPERS"
				title.Parent = panel

				local close = Instance.new("TextButton")
				close.Size = UDim2.fromOffset(22, 22)
				close.Position = UDim2.new(1, -28, 0, 8)
				close.BackgroundColor3 = Color3.fromRGB(35, 32, 48)
				close.Text = "X"
				close.TextColor3 = Color3.fromRGB(220, 220, 230)
				close.Font = Enum.Font.GothamBold
				close.TextSize = 12
				close.Parent = panel
				Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
				close.Activated:Connect(function() gui:Destroy() end)

				local grid = Instance.new("Frame")
				grid.Size = UDim2.new(1, -20, 1, -44)
				grid.Position = UDim2.fromOffset(10, 36)
				grid.BackgroundTransparency = 1
				grid.Parent = panel
				local layout = Instance.new("UIGridLayout")
				layout.CellSize = UDim2.fromOffset(78, 78)
				layout.CellPadding = UDim2.fromOffset(8, 8)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Parent = grid

				local current = tostring(getgenv()._070CurrentBgAsset or ""):gsub("%D", "")

				for i, wp in ipairs(WALLPAPERS) do
					local cell = Instance.new("ImageButton")
					local isNone = (tostring(wp.id) == "none")
					cell.BackgroundColor3 = isNone and Color3.fromRGB(12, 12, 16) or Color3.fromRGB(22, 22, 30)
					if isNone then
						cell.Image = ""
					else
						cell.Image = "rbxthumb://type=Asset&id=" .. wp.id .. "&w=150&h=150"
					end
					cell.ScaleType = Enum.ScaleType.Crop
					cell.AutoButtonColor = false
					cell.LayoutOrder = i
					cell.Parent = grid
					Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)
					local border = Instance.new("UIStroke")
					border.Thickness = 1.5
					border.Color = (current == wp.id) and Color3.fromRGB(140, 120, 255) or Color3.fromRGB(50, 50, 60)
					border.Parent = cell
					local name = Instance.new("TextLabel")
					name.Size = UDim2.new(1, 0, 0, 16)
					name.Position = UDim2.new(0, 0, 1, -16)
					name.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					name.BackgroundTransparency = 0.35
					name.Font = Enum.Font.GothamBold
					name.TextSize = 9
					name.TextColor3 = Color3.fromRGB(240, 240, 245)
					name.Text = wp.name
					name.Parent = cell
					cell.Activated:Connect(function()
						getgenv()._070CurrentBgAsset = wp.id
						if getgenv()._070ApplyUiBackground then
							getgenv()._070ApplyUiBackground(wp.id)
						end
						pcall(function()
							if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
						end)
						gui:Destroy()
					end)
				end

				-- drag
				local dragging, dragStart, startPos
				panel.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						dragStart = input.Position
						startPos = panel.Position
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						local d = input.Position - dragStart
						panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
					end
				end)
			end

			openBtn.Activated:Connect(openWallpaperUI)
		end

		pcall(function()
			if getgenv()._070ApplyCategoryFilter then getgenv()._070ApplyCategoryFilter() end
		end)

		do
			local row = createFrame(44)
			createTextLabel(row, "Config")

			local saveBtn = Instance.new("TextButton", row)
			saveBtn.Size = UDim2.new(0, 70, 0, 28)
			saveBtn.Position = UDim2.new(1, -150, 0.5, -14)
			saveBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 255)
			saveBtn.BackgroundTransparency = 0
			saveBtn.BorderSizePixel = 0
			saveBtn.Text = "SAVE"
			saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			saveBtn.Font = Enum.Font.GothamBlack
			saveBtn.TextSize = 12
			saveBtn.AutoButtonColor = false
			saveBtn.ZIndex = 8
			Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
			local ss = Instance.new("UIStroke", saveBtn)
			ss.Color = Color3.fromRGB(140, 210, 255)
			ss.Thickness = 1.6

			local resetBtn = Instance.new("TextButton", row)
			resetBtn.Size = UDim2.new(0, 70, 0, 28)
			resetBtn.Position = UDim2.new(1, -74, 0.5, -14)
			resetBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 55)
			resetBtn.BackgroundTransparency = 0
			resetBtn.BorderSizePixel = 0
			resetBtn.Text = "RESET"
			resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			resetBtn.Font = Enum.Font.GothamBlack
			resetBtn.TextSize = 12
			resetBtn.AutoButtonColor = false
			resetBtn.ZIndex = 8
			Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)
			local rs = Instance.new("UIStroke", resetBtn)
			rs.Color = Color3.fromRGB(255, 120, 130)
			rs.Thickness = 1.4

			saveBtn.Activated:Connect(function()
				local success, result = pcall(getgenv()._070SaveAll, true)
				local ok = success and result == true
				saveBtn.Text = ok and "SAVED!" or "FAIL"
				saveBtn.BackgroundColor3 = ok and Color3.fromRGB(35, 180, 90) or Color3.fromRGB(180, 40, 40)
				task.delay(1.4, function()
					if saveBtn and saveBtn.Parent then
						saveBtn.Text = "SAVE"
						saveBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 255)
					end
				end)
				print(ok and "[070] SAVED (settings + keybinds + outfits + animations)" or "[070] SAVE FAILED")
			end)

			resetBtn.Activated:Connect(function()
				local wasConfigReady = isConfigReady
				isConfigReady = false
				reset070Config()
				_savedCfg = nil
				getgenv()._070PendingAnimPack = nil
				getgenv()._070UIConfig = { skinChangerEnabled = false, skinSelection = 1 }
				_G._070UIConfig = getgenv()._070UIConfig
				pcall(function()
					if type(KB) == "table" then
						for _, bind in pairs(KB) do
							if type(bind) == "table" then bind.kb, bind.gp = nil, nil end
						end
					end
					if refreshAllKeyButtons then refreshAllKeyButtons() end
					if getgenv()._070SetAnimPack then getgenv()._070SetAnimPack(nil) end
				end)
				pcall(function()
					if stopAutoSteal then stopAutoSteal() end
					if stopAntiRagdoll then stopAntiRagdoll() end
					if disableAutoBat then disableAutoBat() end
					if stopTpBat then stopTpBat() end
					if stopAutoTeleport then stopAutoTeleport() end
					if setShowE01WarningVisual then setShowE01WarningVisual(false) end
					ragdollCountdownEnabled = false
					if setRagdollCountdownVisual then setRagdollCountdownVisual(false) end
					if AR2 and AR2.StopCountdown then AR2.StopCountdown() end
					antiRagdollEnabled, infJumpEnabled, unwalkEnabled = false, false, false
					medusaCounterEnabled, batCounterEnabled, autoBatEnabled = false, false, false
					tpBatEnabled, espEnabled, autoTPEnabled = false, false, false
					laggerToggled, speedMode = false, false
					_G._070AntiBatEnabled = false
					_G._070MedCounterEnabled = false
					_G._070BaseXRay = false
					_G._070BrainrotXRay = false
					if _G._070BodyLock then _G._070BodyLock.enabled = false end
					if Steal then Steal.AutoStealEnabled = false end
					if getgenv()._070SetMedCounter then getgenv()._070SetMedCounter(false) end
					if getgenv()._070SetBaseXRay then getgenv()._070SetBaseXRay(false) end
					if getgenv()._070SetBrainrotXRay then getgenv()._070SetBrainrotXRay(false) end
					if getgenv()._070SetBodyLock then getgenv()._070SetBodyLock(false) end
				end)
				pcall(function()
					for _, fn in ipairs({setAntiRagVisual,setInfJumpVisual,setUnwalkVisual,setAntiBatVisual,setInstaGrab,autoBatSetVisual,setTPBatVisual,setESPVisual,setAutoTPVisual,setMedusaVisual,setMedCounterVisual,setBaseXRayVisual,setBrainrotXRayVisual,setBodyLockVisual}) do
						if fn then pcall(fn, false) end
					end
				end)
				isConfigReady = wasConfigReady
				resetBtn.Text = "DONE"
				task.delay(1.2, function()
					if resetBtn and resetBtn.Parent then resetBtn.Text = "RESET" end
				end)
				do end -- muted
			end)
		end



	end


	_savedCfg = nil

	-- =====================================================================
	-- HARD PERSIST: every toggle / number survives rejoin until disabled
	-- =====================================================================
	local function persistApply(data)
		if type(data) ~= "table" then return end
		-- numbers / modes first
		if type(data.normalSpeed) == "number" then NS = data.normalSpeed end
		if type(data.carrySpeed) == "number" then CS = data.carrySpeed end
		if type(data.laggerSpeed) == "number" then LAGGER_SPEED = data.laggerSpeed end
		if type(data.laggerCarrySpeed) == "number" then LAGGER_CARRY_SPEED = data.laggerCarrySpeed end
		if type(data.autoBatSpeed) == "number" then AUTO_BAT_SPEED = data.autoBatSpeed end
		if type(data.autoStealV1Radius) == "number" then stealV1Radius = data.autoStealV1Radius end
		if type(data.autoStealV2Radius) == "number" then stealV2Radius = data.autoStealV2Radius end
		if type(data.autoStealV1DelayRadius) == "number" then stealV1DelayRadius = data.autoStealV1DelayRadius end
		if type(data.autoStealV2DelayRadius) == "number" then stealV2DelayRadius = data.autoStealV2DelayRadius end
		if type(data.autoStealV1Percent) == "number" and stealPercentages then stealPercentages.V1 = data.autoStealV1Percent end
		if type(data.autoStealV2Percent) == "number" and stealPercentages then stealPercentages.V2 = data.autoStealV2Percent end
		autoStealVersion = "V1" -- UI version selector removed; always V1
		if Steal and type(data.autoStealRadius) == "number" then Steal.StealRadius = data.autoStealRadius end
		if data.autoBatMode == "Vision" or data.autoBatMode == "AntiBatBypass" then autoBatMode = (data.autoBatMode == "AntiBatBypass") and "Vision" or data.autoBatMode end
		if type(data.uiScale) == "number" then uiScaleValue = data.uiScale end
		if type(data.stealBarScale) == "number" then stealBarScaleValue = math.clamp(math.floor(data.stealBarScale + 0.5), 50, 200) end
		if type(data.uiAccentR) == "number" then uiAccentR = math.clamp(math.floor(data.uiAccentR), 0, 255) end
		if type(data.uiAccentG) == "number" then uiAccentG = math.clamp(math.floor(data.uiAccentG), 0, 255) end
		if type(data.uiAccentB) == "number" then uiAccentB = math.clamp(math.floor(data.uiAccentB), 0, 255) end
		if type(data.uiBgAsset) == "string" and data.uiBgAsset ~= "" then
			getgenv()._070CurrentBgAsset = data.uiBgAsset
		elseif (uiAccentR or 0) == 220 and (uiAccentG or 0) == 220 and (uiAccentB or 0) == 230 then
			getgenv()._070CurrentBgAsset = getgenv()._070WhiteBgAsset or "124210976977975"
		else
			getgenv()._070CurrentBgAsset = getgenv()._070DefaultBgAsset or "119161957039576"
		end
		task.defer(function()
			task.wait(0.4)
			pcall(function()
				if getgenv()._070ApplyUiAccent then
					getgenv()._070ApplyUiAccent(uiAccentR, uiAccentG, uiAccentB)
				end
				if getgenv()._070ApplyUiBackground then
					getgenv()._070ApplyUiBackground(getgenv()._070CurrentBgAsset)
				end
			end)
		end)
		task.defer(function()
			task.wait(0.6)
			pcall(function()
				if getgenv()._070ApplyStealBarScale then
					getgenv()._070ApplyStealBarScale(stealBarScaleValue)
				end
				if stealBarScaleBox then stealBarScaleBox.Text = tostring(stealBarScaleValue) end
			end)
		end)
		if type(data.autoTPHeight) == "number" then autoTPHeight = data.autoTPHeight end
		if type(data.fieldOfView) == "number" then fieldOfView = data.fieldOfView end
		if type(data.speedBypassPCPower) == "number" then desktopBypassPower = data.speedBypassPCPower end
		if type(data.speedBypassMobilePower) == "number" then mobileBypassPower = data.speedBypassMobilePower end

		-- flags (raw state)
		antiRagdollEnabled = data.antiRagdoll == true
		unwalkEnabled = data.unwalk == true
		infJumpEnabled = data.infiniteJump == true
		medusaCounterEnabled = data.medusaCounter == true
		batCounterEnabled = data.batCounter == true
		autoSwingEnabled = data.autoSwing ~= false
		mirrorTPEnabled = data.mirrorTP ~= false
		tpBatAutoSwingEnabled = data.tpBatAutoSwing ~= false
		autoBatEnabled = data.autoBat == true
		tpBatEnabled = data.tpBatEnabled == true
		espEnabled = data.espEnabled == true
		espTracersEnabled = data.espTracersEnabled == true
		showE01Warning = data.showE01Warning == true
		if data.normalSpeed then NS = tonumber(data.normalSpeed) or NS end
		if data.carrySpeed then CS = tonumber(data.carrySpeed) or CS end
		_G.showE01Warning = showE01Warning
		_G._070Halo = data.halo == true
		_G._070HideStealBarUI = data.hideStealBarUI == true
		
-- SAFE BOOT GUARD: force risky systems off after load
task.defer(function()
	task.wait(0.2)
	pcall(function()
		if type(stopAutoSteal) == "function" then stopAutoSteal() end
	end)
	pcall(function()
		if Steal then Steal.AutoStealEnabled = false end
		laggerToggled = false
		laggerPhase = 0
		isSpeedBypassEnabled = false
	end)
	pcall(function()
		if type(stopAutoTeleport) == "function" then stopAutoTeleport() end
	end)
end)

_G._070Christmas = false
		task.defer(function()
			task.wait(0.5)
			pcall(function()
				if getgenv()._070SetStealBarHidden then
					getgenv()._070SetStealBarHidden(_G._070HideStealBarUI == true)
				end
			end)
			-- retry apply after bar builds
			task.wait(1.2)
			pcall(function()
				if getgenv()._070SetStealBarHidden then
					getgenv()._070SetStealBarHidden(_G._070HideStealBarUI == true)
				end
			end)
		end)
		pcall(function()
			local p = getgenv()._070Persist
			if type(p) == "table" then p.showE01Warning = showE01Warning end
		end)
		ragdollCountdownEnabled = data.ragdollCountdownEnabled == true
		antiLagEnabled = data.antiLag == true
		fieldOfViewEnabled = data.fieldOfViewEnabled == true
		stretchRezEnabled = data.stretchRez == true
		autoTPEnabled = data.autoTPEnabled == true
		showMobileButtons = data.showMobileButtons ~= false
		qaLocked = data.qaLocked == true
		showSpeedBypassPanel = false -- Speed Bypass removed
		isSpeedBypassEnabled = false
		-- SAFE BOOT: never auto-start combat/network features (instant kick risk)
		-- User must toggle them on again after execute
		if Steal then Steal.AutoStealEnabled = false end
		laggerToggled = false
		laggerPhase = 0
		speedMode = false
		isSpeedBypassEnabled = false
		autoTPEnabled = false
		_G.__070AntiDieOn = false
		-- remember saved prefs without enabling loops yet
		pcall(function()
			getgenv()._070SavedCombat = {
				autoSteal = data.autoStealEnabled == true,
				lagger = data.laggerMode == true,
				laggerCarry = data.laggerCarryMode == true,
				carry = data.carryMode == true,
				antiDie = data.antiDie == true,
				autoTP = data.autoTPEnabled == true,
			}
		end)
		-- only enable if explicitly saved true (never auto-on)
		_G._070AntiBatEnabled = false -- Anti Bat removed
		_G._070AntiBatInfJumpEnabled = false
		if not _G._070AntiBatEnabled then
			pcall(function()
				if _G._070AntiBat and _G._070AntiBat.setEnabled then
					_G._070AntiBat.setEnabled(false)
				end
			end)
		end
		-- Med / XRay / BodyLock flags
		_G._070MedCounterEnabled = data.medCounter == true
		medusaCounterEnabled = data.medCounter == true or data.medusaCounter == true
		_G._070BaseXRay = data.baseXRay == true
		_G._070BrainrotXRay = data.brainrotXRay == true
		if _G._070BRX then _G._070BRX.enabled = data.brainrotXRay == true end
		_G._070BodyLock = _G._070BodyLock or { enabled = false, range = 25, conn = nil }
		_G._070BodyLock.enabled = false -- safe boot
		if type(data.bodyLockRange) == "number" then _G._070BodyLock.range = data.bodyLockRange end

		-- outfit into UIConfig
		local cfg = getgenv()._070UIConfig or {}
		if data.skinChangerEnabled ~= nil then cfg.skinChangerEnabled = data.skinChangerEnabled == true end
		if type(data.skinSelection) == "number" then cfg.skinSelection = data.skinSelection end
		if type(data.customSkinId) == "number" then cfg.customSkinId = data.customSkinId end
		getgenv()._070UIConfig = cfg
		_G._070UIConfig = cfg
	end

	local function persistApplyVisualsAndStart()
		local data = _savedCfg
		if type(data) ~= "table" then return end
		pcall(function()
			if normalBox then normalBox.Text = tostring(NS) end
			if carryBox then carryBox.Text = tostring(CS) end
			if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED) end
			if laggerCarryBox then laggerCarryBox.Text = tostring(LAGGER_CARRY_SPEED) end
			if autoBatSpeedBox then autoBatSpeedBox.Text = tostring(AUTO_BAT_SPEED) end
			if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPHeight) end
			if fieldOfViewBox then fieldOfViewBox.Text = tostring(fieldOfView) end
			if radInput then radInput.Text = tostring(Steal and Steal.StealRadius or 14) end
		end)
		-- visuals + start features
		pcall(function()
			if setAntiRagVisual then setAntiRagVisual(antiRagdollEnabled) end
			if antiRagdollEnabled and startAntiRagdoll then startAntiRagdoll() end
		end)
		pcall(function()
			if setUnwalkVisual then setUnwalkVisual(unwalkEnabled) end
			if unwalkEnabled and disableWalkAnimation then disableWalkAnimation() end
		end)
		pcall(function()
			if setInfJumpVisual then setInfJumpVisual(infJumpEnabled) end
			if infJumpEnabled and featureHelperA then featureHelperA(true) end
		end)
		pcall(function()
			if setMedusaVisual then setMedusaVisual(medusaCounterEnabled) end
			if medusaCounterEnabled and setupMedusaCounter and localPlayer.Character then
				setupMedusaCounter(localPlayer.Character)
			end
		end)
		pcall(function()
			if setBatCounterVisual then setBatCounterVisual(batCounterEnabled) end
		end)
		pcall(function()
			if setAntiBatVisual then setAntiBatVisual(_G._070AntiBatEnabled == true) end
			if _G._070AntiBat and _G._070AntiBat.setEnabled then
				if _G._070AntiBat.setInfJump then
					_G._070AntiBat.setInfJump(false)
				end
				_G._070AntiBat.setEnabled(_G._070AntiBatEnabled == true)
			end
		end)
		-- Med Counter
		pcall(function()
			local on = _G._070MedCounterEnabled == true or medusaCounterEnabled == true
			if setMedCounterVisual then setMedCounterVisual(on) end
			if setMedusaVisual then setMedusaVisual(on) end
			if getgenv()._070SetMedCounter then getgenv()._070SetMedCounter(on) end
			if on and setupMedusaCounter and localPlayer.Character then
				setupMedusaCounter(localPlayer.Character)
			end
		end)
		-- X-Ray Base
		pcall(function()
			local on = _G._070BaseXRay == true
			if setBaseXRayVisual then setBaseXRayVisual(on) end
			if getgenv()._070SetBaseXRay then getgenv()._070SetBaseXRay(on) end
		end)
		-- X-Ray Brainrot
		pcall(function()
			local on = _G._070BrainrotXRay == true
			if setBrainrotXRayVisual then setBrainrotXRayVisual(on) end
			if getgenv()._070SetBrainrotXRay then getgenv()._070SetBrainrotXRay(on) end
		end)
		-- Body Lock
		pcall(function()
			local on = _G._070BodyLock and _G._070BodyLock.enabled == true
			if setBodyLockVisual then setBodyLockVisual(on) end
			if getgenv()._070SetBodyLock then getgenv()._070SetBodyLock(on) end
			if on and type(getgenv()._070SetBodyLockRange) == "function" and _G._070BodyLock then
				getgenv()._070SetBodyLockRange(_G._070BodyLock.range or 25)
			end
		end)
		pcall(function()
			if setAutoSwingVisual then setAutoSwingVisual(autoSwingEnabled) end
			if setMirrorTPVisual then setMirrorTPVisual(mirrorTPEnabled) end
			if setTPBatAutoSwingVisual then setTPBatAutoSwingVisual(tpBatAutoSwingEnabled) end
		end)
		pcall(function()
			if autoBatSetVisual then autoBatSetVisual(autoBatEnabled) end
			if autoBatEnabled and queueAutoBatStart then queueAutoBatStart() end
		end)
		pcall(function()
			if setTPBatVisual then setTPBatVisual(tpBatEnabled) end
			if tpBatEnabled and startTpBat then startTpBat() end
		end)
		pcall(function()
			if setInstaGrab then setInstaGrab(Steal and Steal.AutoStealEnabled == true) end
			if Steal and Steal.AutoStealEnabled and startAutoSteal then startAutoSteal() end
		end)
		pcall(function()
			if setAutoTPVisual then setAutoTPVisual(autoTPEnabled) end
			if autoTPEnabled and startAutoTeleport then startAutoTeleport() end
		end)
		pcall(function()
			if setESPVisual then setESPVisual(espEnabled) end
			if setESPTracersVisual then setESPTracersVisual(espTracersEnabled) end
			if setShowE01WarningVisual then setShowE01WarningVisual(showE01Warning == true) end
			showE01Warning = showE01Warning == true
			_G.showE01Warning = showE01Warning
			pcall(function()
				if getgenv()._070SetHaloVisual then
					getgenv()._070SetHaloVisual(_G._070Halo == true)
				end
				if _G._070Halo and getgenv()._070SetHalo then
					getgenv()._070SetHalo(true)
				end
				if getgenv()._070SetChristmasVisual then
					getgenv()._070SetChristmasVisual(false)
				end
				if _G._070Christmas and getgenv()._070SetChristmas then
					getgenv()._070SetChristmas(true)
				end
			end)
			if setRagdollCountdownVisual then setRagdollCountdownVisual(ragdollCountdownEnabled) end
		end)
		pcall(function()
			if setFovVisual then setFovVisual(fieldOfViewEnabled) end
			if setStretchRezVisual then setStretchRezVisual(stretchRezEnabled) end
		end)
		pcall(function()
			if setShowMobileButtonsVisual then setShowMobileButtonsVisual(showMobileButtons) end
			if setLockMobileButtonsVisual then setLockMobileButtonsVisual(qaLocked) end
			if refreshQuickActionVisibility then refreshQuickActionVisibility() end
		end)
		pcall(function()
			if laggerToggled then
				-- restore phase via existing helpers if any
				if refreshSpeedModeLabel then refreshSpeedModeLabel() end
			elseif speedMode and toggleCarryMode then
				-- already set speedMode
				if refreshSpeedModeLabel then refreshSpeedModeLabel() end
			end
			if refreshAutoBatModeControls then refreshAutoBatModeControls() end
			if updateStealRadiusUi then updateStealRadiusUi() end
			if updateStealVersionUi then updateStealVersionUi() end
		end)
		print("[070] Persist applied · autoSteal=", Steal and Steal.AutoStealEnabled, "antiRag=", antiRagdollEnabled, "infJump=", infJumpEnabled)
	end

	loadConfigKeys = function()
		local operationResult = read070Config()
		if not operationResult then return end
		_savedCfg = operationResult
		pcall(persistApply, operationResult)
		if operationResult.headless == true then _G._070Headless = true end
		pcall(function()
			if operationResult.headless and getgenv()._070SetHeadless then getgenv()._070SetHeadless(true) end
		end)
		-- restore outfit / skin forever until disabled
		pcall(function()
			local cfg = getgenv()._070UIConfig or {}
			if type(operationResult.skinSelection) == "number" then
				cfg.skinSelection = operationResult.skinSelection
			end
			if operationResult.skinChangerEnabled ~= nil then
				cfg.skinChangerEnabled = operationResult.skinChangerEnabled == true
			end
			if type(operationResult.customSkinId) == "number" then
				cfg.customSkinId = operationResult.customSkinId
			end
			getgenv()._070UIConfig = cfg
			_G._070UIConfig = cfg
		end)

		local function featureHelperW(inputValue, secondaryInput)
			if type(secondaryInput) ~= "table" then
				return
			end
			inputValue.kb = nil
			inputValue.gp = nil

			if secondaryInput.kb and Enum.KeyCode[secondaryInput.kb] then
				inputValue.kb = Enum.KeyCode[secondaryInput.kb]
			end

			if secondaryInput.gp and Enum.KeyCode[secondaryInput.gp] then
				inputValue.gp = Enum.KeyCode[secondaryInput.gp]
			end
		end

-- =====================================================================
-- 070Hub
-- =====================================================================
		featureHelperW(KB.DropBrainrot, operationResult.dropBrainrotKey)
		featureHelperW(KB.AutoLeft, operationResult.autoLeftKey)
		featureHelperW(KB.AutoRight, operationResult.autoRightKey)
		featureHelperW(KB.AutoBat, operationResult.autoBatKey)
		featureHelperW(KB.DesyncAimbot, operationResult.desyncAimbotKey)
		featureHelperW(KB.LaggerToggle, operationResult.laggerToggleKey)
		featureHelperW(KB.TPFloor, operationResult.tpFloorKey)
		featureHelperW(KB.GuiHide, operationResult.guiHideKey)
		featureHelperW(KB.SpeedBypassGui, operationResult.speedBypassGuiKey)
		featureHelperW(KB.SpeedBypassToggle, operationResult.speedBypassToggleKey)
		featureHelperW(KB.SpeedToggle, operationResult.speedToggleKey)

		if
			type(operationResult.speedBypassToggleKey) ~= "table"
			and type(operationResult.speedBypassKey) == "string"
			and Enum.KeyCode[operationResult.speedBypassKey]
		then
			KB.SpeedBypassToggle.kb = Enum.KeyCode[operationResult.speedBypassKey]
			KB.SpeedBypassToggle.gp = nil
		end

		if operationResult.normalSpeed then
			NS = operationResult.normalSpeed
		end

		if operationResult.carrySpeed then
			CS = operationResult.carrySpeed
		end

		stealV1Radius = type(operationResult.autoStealV1Radius) == "number"
				and math.clamp(operationResult.autoStealV1Radius, 0.5, 200)
			or 9.1
		stealV2Radius = type(operationResult.autoStealV2Radius) == "number"
				and math.clamp(operationResult.autoStealV2Radius, 0.5, 200)
			or 10

		if
			type(operationResult.autoStealRadius) == "number"
			and operationResult.autoStealV1Radius == nil
			and operationResult.autoStealV2Radius == nil
		then
			if operationResult.autoStealVersion == "V2" then
				stealV2Radius = math.clamp(operationResult.autoStealRadius, 0.5, 200)
			else
				stealV1Radius = math.clamp(operationResult.autoStealRadius, 0.5, 200)
			end
		end

		if type(operationResult.autoStealV1DelayRadius) == "number" then
			stealV1DelayRadius = math.clamp(operationResult.autoStealV1DelayRadius, 0.5, 200)
		else
			stealV1DelayRadius = 14
		end

		if type(operationResult.autoStealV2DelayRadius) == "number" then
			stealV2DelayRadius = math.clamp(operationResult.autoStealV2DelayRadius, 0.5, 200)
		else
			stealV2DelayRadius = 15
		end

		stealPercentages.V1 = type(operationResult.autoStealV1Percent) == "number"
				and math.clamp(operationResult.autoStealV1Percent, 1, 100)
			or 75
		stealPercentages.V2 = type(operationResult.autoStealV2Percent) == "number"
				and math.clamp(operationResult.autoStealV2Percent, 1, 100)
			or 85

		if operationResult.autoStealVersion == "V1" or operationResult.autoStealVersion == "V2" then
			autoStealVersion = operationResult.autoStealVersion
		else
			autoStealVersion = "V1"
		end

		Steal.StealRadius = autoStealVersion == "V2" and stealV2Radius or stealV1Radius
		updateStealRadiusUi()
		updateStealVersionUi()

		if operationResult.laggerSpeed and type(operationResult.laggerSpeed) == "number" then
			LAGGER_SPEED = operationResult.laggerSpeed
		end

		if operationResult.laggerCarrySpeed and type(operationResult.laggerCarrySpeed) == "number" then
			LAGGER_CARRY_SPEED = operationResult.laggerCarrySpeed
		end

		if operationResult.autoBatMode == "Vision" or operationResult.autoBatMode == "AntiBatBypass" then
			autoBatMode = operationResult.autoBatMode
		end

		if operationResult.autoSwing ~= nil then
			autoSwingEnabled = operationResult.autoSwing == true
		else
			autoSwingEnabled = true
		end

		if operationResult.mirrorTP ~= nil then
			mirrorTPEnabled = operationResult.mirrorTP == true
		else
			mirrorTPEnabled = true
		end

		if operationResult.unwalk ~= nil then
			unwalkEnabled = operationResult.unwalk == true
		else
			unwalkEnabled = false
		end

		if operationResult.tpBatAutoSwing ~= nil then
			tpBatAutoSwingEnabled = operationResult.tpBatAutoSwing == true
		else
			tpBatAutoSwingEnabled = true
		end

		batCounterVersion = "V1"

		normalizeBatCounterSettings()

		if type(operationResult.autoBatSpeed) == "number" and operationResult.autoBatSpeed > 0 then
			AUTO_BAT_SPEED = operationResult.autoBatSpeed
		elseif type(operationResult.bypassAutoBatSpeed) == "number" and operationResult.bypassAutoBatSpeed > 0 then
			AUTO_BAT_SPEED = operationResult.bypassAutoBatSpeed
		end

		BYPASS_AUTO_BAT_SPEED = AUTO_BAT_SPEED

		if type(operationResult.laggerAutoBatSpeed) == "number" and operationResult.laggerAutoBatSpeed > 0 then
			LAGGER_AUTO_BAT_SPEED = operationResult.laggerAutoBatSpeed
		elseif
			type(operationResult.bypassLaggerAutoBatSpeed) == "number"
			and operationResult.bypassLaggerAutoBatSpeed > 0
		then
			LAGGER_AUTO_BAT_SPEED = operationResult.bypassLaggerAutoBatSpeed
		end

		BYPASS_LAGGER_AUTO_BAT_SPEED = LAGGER_AUTO_BAT_SPEED

		tpBatEnabled = false

-- =====================================================================
-- 070Hub
-- =====================================================================
		if operationResult.autoTPHeight and type(operationResult.autoTPHeight) == "number" then
			autoTPHeight = math.clamp(operationResult.autoTPHeight, 0, 50)
		end

		if operationResult.fieldOfView and type(operationResult.fieldOfView) == "number" then
			fieldOfView = math.clamp(operationResult.fieldOfView, 40, 120)
		end

		if operationResult.fieldOfViewEnabled ~= nil then
			fieldOfViewEnabled = operationResult.fieldOfViewEnabled == true
		end

		if operationResult.stretchRez ~= nil then
			stretchRezEnabled = operationResult.stretchRez == true
		end

		if stretchRezEnabled and fieldOfViewEnabled then
			fieldOfViewEnabled = false
		end

		if operationResult.showUIOnExecute ~= nil then
			showUIOnExecute = operationResult.showUIOnExecute == true
		else
			showUIOnExecute = true
		end

		if operationResult.showSpeedBypassPanel ~= nil then
			showSpeedBypassPanel = false -- Speed Bypass removed
			isSpeedBypassEnabled = false
		else
			showSpeedBypassPanel = false
		end

		if type(operationResult.speedBypassPCPower) == "number" then
			desktopBypassPower = math.floor(math.clamp(operationResult.speedBypassPCPower, 10000, 150000))
		end

		if type(operationResult.speedBypassMobilePower) == "number" then
			mobileBypassPower = math.floor(math.clamp(operationResult.speedBypassMobilePower, 10000, 100000))
		end

		if operationResult.speedBypassMode == "PC" or operationResult.speedBypassMode == "Mobile" then
			text = operationResult.speedBypassMode
		end

		if isMobileDevice then
			text = "Mobile"
		end

		if
			type(operationResult.speedBypassPower) == "number"
			and type(operationResult.speedBypassPCPower) ~= "number"
			and type(operationResult.speedBypassMobilePower) ~= "number"
		then
			if text == "PC" then
				desktopBypassPower = math.floor(math.clamp(operationResult.speedBypassPower, 10000, 150000))
			else
				mobileBypassPower = math.floor(math.clamp(operationResult.speedBypassPower, 10000, 100000))
			end
		end

		speedBypassPower = text == "PC" and desktopBypassPower or mobileBypassPower

		if
			type(operationResult.speedBypassPosition) == "table"
			and type(operationResult.speedBypassPosition.x) == "number"
			and type(operationResult.speedBypassPosition.y) == "number"
		then
			speedPanelPosition =
				{ x = operationResult.speedBypassPosition.x, y = operationResult.speedBypassPosition.y }
		end

		if operationResult.showMobileButtons ~= nil then
			showMobileButtons = operationResult.showMobileButtons == true
		end

		if operationResult.qaLocked ~= nil then
			qaLocked = operationResult.qaLocked == true
		end

		if operationResult.uiScale and type(operationResult.uiScale) == "number" then
			uiScaleValue = math.clamp(math.floor(operationResult.uiScale + 0.5), 50, 125)
		end

		if operationResult.espEnabled ~= nil then
			espEnabled = operationResult.espEnabled == true
		end

		if operationResult.espTracersEnabled ~= nil then
			espTracersEnabled = operationResult.espTracersEnabled == true
		end

		if operationResult.antiLag ~= nil then
			antiLagEnabled = operationResult.antiLag == true
		end

		if operationResult.ragdollCountdownEnabled ~= nil then
			ragdollCountdownEnabled = operationResult.ragdollCountdownEnabled == true
		end

		if operationResult.antiDie ~= nil then
			_G.__070AntiDieOn = operationResult.antiDie == true
		end
		if operationResult.uiTheme == "Normal" then
			uiTheme = operationResult.uiTheme
		end
	end

	loadConfigState = function()
		local primaryValue = _savedCfg
		if not primaryValue then
			return
		end

		if normalBox then
			normalBox.Text = tostring(NS)
		end

		if carryBox then
			carryBox.Text = tostring(CS)
		end

		updateStealRadiusUi()

		if laggerBox then
			laggerBox.Text = tostring(LAGGER_SPEED)
		end

		if laggerCarryBox then
			laggerCarryBox.Text = tostring(LAGGER_CARRY_SPEED)
		end

		if autoBatSpeedBox then
			autoBatSpeedBox.Text = tostring(AUTO_BAT_SPEED)
		end

		if bypassAutoBatSpeedBox then
			bypassAutoBatSpeedBox.Text = tostring(AUTO_BAT_SPEED)
		end

		if laggerAutoBatSpeedBox then
			laggerAutoBatSpeedBox.Text = tostring(LAGGER_AUTO_BAT_SPEED)
		end

		if bypassLaggerAutoBatSpeedBox then
			bypassLaggerAutoBatSpeedBox.Text = tostring(LAGGER_AUTO_BAT_SPEED)
		end

		if setTPBatVisual then
			setTPBatVisual(tpBatEnabled)
		end

		if tpBatEnabled then
			startTpBat()
		else
			stopTpBat()
		end

-- =====================================================================
-- 070Hub
-- =====================================================================
		if setStretchRezVisual then
			setStretchRezVisual(stretchRezEnabled)
		end

		refreshAutoBatModeControls()
		refreshAllKeyButtons()

		if setShowUIOnExecuteVisual then
			setShowUIOnExecuteVisual(showUIOnExecute)
		end

		if setShowSpeedBypassPanelVisual then
			setShowSpeedBypassPanelVisual(showSpeedBypassPanel)
		end

		if speedBypassPanel and speedPanelPosition then
			speedBypassPanel.Position = UDim2.fromOffset(speedPanelPosition.x + 115, speedPanelPosition.y + 126)
		end

		featureHelperP()
		featureHelperS()

		if setShowMobileButtonsVisual then
			setShowMobileButtonsVisual(showMobileButtons)
		end

		if setLockMobileButtonsVisual then
			setLockMobileButtonsVisual(qaLocked)
		end

		refreshQuickActionVisibility()

		if autoTPHeightBox then
			autoTPHeightBox.Text = tostring(autoTPHeight)
		end

		if fieldOfViewBox then
			fieldOfViewBox.Text = tostring(fieldOfView)
		end

		if setFovVisual then
			setFovVisual(fieldOfViewEnabled)
		end

		if fieldOfViewEnabled then
			featureHelperD()
		else
			featureHelperE()
		end

		if setESPVisual then
			setESPVisual(espEnabled)
		end

		if setESPTracersVisual then
			setESPTracersVisual(espTracersEnabled)
		end

		if setRagdollCountdownVisual then
			setRagdollCountdownVisual(ragdollCountdownEnabled)
		end

		if setBatCounterVisual then
			setBatCounterVisual(primaryValue.batCounter == true)
		end

		refreshESP()

		if setAntiLagVisual then
			setAntiLagVisual(antiLagEnabled)
		end

		if antiLagEnabled then
			antiLagEnabled = false
			enableAntiLag()
		else
			disableAntiLag()
		end

		if scaleBox then
			scaleBox.Text = tostring(uiScaleValue)
		end

		if mainGuiScale then
			mainGuiScale.Scale = uiScaleValue / 100
		end

		if speedBypassPanel then
			local uiScale = speedBypassPanel:FindFirstChildOfClass("UIScale")

			if uiScale then
				uiScale.Scale = uiScaleValue / 100
			end
		end

		if progressBarScale then
			progressBarScale.Scale = uiScaleValue / 100
		end

		do
			local positions = primaryValue.qaPositions
			if type(positions) ~= "table" then
				local persist = getgenv()._070Persist or _G._070Persist
				if type(persist) == "table" then positions = persist.qaPositions end
			end
			if type(positions) == "table" then
				for i, qaPosition in ipairs(positions) do
					if qaFrames[i] and type(qaPosition) == "table" and qaPosition[1] and qaPosition[2] then
						qaFrames[i].Position = UDim2.new(0, qaPosition[1], 0, qaPosition[2])
					end
				end
			end
		end

		for _, secondaryValue in ipairs(qaFrames) do
			local currentObject = secondaryValue:FindFirstChildOfClass("UIScale")

			if currentObject then
				currentObject.Scale = uiScaleValue / 100
			end
		end

		if batCounterEnabled or batCounterV2Enabled or ragdollCountdownEnabled then
			startBatCounter()
		end

		-- medusa removed

		task.spawn(function()
			local function featureHelperW(inputValue)
				pcall(inputValue)
			end

			featureHelperW(function()
				if primaryValue.antiRagdoll then
					antiRagdollEnabled = true

					if setAntiRagVisual then
						setAntiRagVisual(true)
					end

					startAntiRagdoll()
				end
			end)

			if setUnwalkVisual then
				setUnwalkVisual(unwalkEnabled)
			end

			featureHelperW(function()
				if unwalkEnabled then
					disableWalkAnimation()
				end
			end)

-- =====================================================================
-- 070Hub
-- =====================================================================
			featureHelperW(function()
				if primaryValue.infiniteJump then
					featureHelperA(true)

					if setInfJumpVisual then
						setInfJumpVisual(true)
					end
				end
			end)

			featureHelperW(function()
				if primaryValue.medusaCounter then
					medusaCounterEnabled = true
					if setMedusaVisual then setMedusaVisual(true) end
					if setupMedusaCounter and localPlayer.Character then
						pcall(setupMedusaCounter, localPlayer.Character)
					end
				else
					medusaCounterEnabled = false
				end
			end)

			featureHelperW(function()
				if primaryValue.batCounter then
					batCounterEnabled = true
					if setBatCounterVisual then setBatCounterVisual(true) end
				end
			end)

			featureHelperW(function()
				local wantAnti = primaryValue.antiBat == true
				pcall(function()
					_G._070AntiBatInfJumpEnabled = false
					if _G._070AntiBat and _G._070AntiBat.setInfJump then
						_G._070AntiBat.setInfJump(false)
					end
					if wantAnti then
						if _G._070AntiBat and _G._070AntiBat.setEnabled then
							_G._070AntiBat.setEnabled(true)
						else
							_G._070AntiBatEnabled = true
						end
						if setAntiBatVisual then setAntiBatVisual(true) end
					else
						_G._070AntiBatEnabled = false
						if _G._070AntiBat and _G._070AntiBat.setEnabled then
							_G._070AntiBat.setEnabled(false)
						end
						if setAntiBatVisual then setAntiBatVisual(false) end
					end
				end)
			end)

			if primaryValue.laggerMode then
				laggerToggled = true
				speedMode = false
				laggerPhase = primaryValue.laggerCarryMode and 2 or 1
			elseif primaryValue.carryMode then
				speedMode = false
				toggleCarryMode()
			end

			refreshSpeedModeLabel()

			featureHelperW(function()
				if primaryValue.autoTPEnabled then
					autoTPEnabled = true

					if setAutoTPVisual then
						setAutoTPVisual(true)
					end

					startAutoTeleport()
				end
			end)

			if setAutoSwingVisual then
				setAutoSwingVisual(autoSwingEnabled)
			end

			if setMirrorTPVisual then
				setMirrorTPVisual(mirrorTPEnabled)
			end

			if setTPBatAutoSwingVisual then
				setTPBatAutoSwingVisual(tpBatAutoSwingEnabled)
			end

			featureHelperW(function()
				if primaryValue.autoBat then
					autoBatEnabled = true

					if autoBatSetVisual then
						autoBatSetVisual(true)
					end

					queueAutoBatStart()
				end
			end)

			featureHelperW(function()
				if primaryValue.autoStealEnabled then
					Steal.AutoStealEnabled = true

					if setInstaGrab then
						setInstaGrab(true)
					end

					startAutoSteal()
				end
			end)

			featureHelperW(function()
				-- Anti Die persist
				local wantAntiDie = primaryValue.antiDie == true
				if wantAntiDie then
					_G.__070AntiDieOn = true
					if setDesyncAimbotEnabled then
						setDesyncAimbotEnabled(true)
					elseif startAntiDie then
						startAntiDie()
					elseif getgenv()._070StartAntiDie then
						getgenv()._070StartAntiDie()
					end
					if setTPBatVisual then
						pcall(setTPBatVisual, true)
					end
				end
			end)

			featureHelperW(function()
				-- Anim pack persist
				if primaryValue.animPackEnabled and type(primaryValue.animPack) == "string" then
					pcall(function()
						if getgenv()._070SetAnimPack then
							getgenv()._070SetAnimPack(primaryValue.animPack)
						end
					end)
				end
			end)

			featureHelperW(function()
				if primaryValue.stretchRez then
					stretchRezEnabled = false

					if setStretchRezVisual then
						setStretchRezVisual(true)
					end

					featureHelperF()
				end
			end)
		end)
	end
end

showLoadingIndicator()
loadConfigKeys()

task.spawn(function()
	if not pcall(buildGui) then
		hideLoadingIndicator()
		return
	end
	task.wait(0.15)
	pcall(loadConfigState)
	pcall(function()
		local data = getgenv()._070LoadAll and getgenv()._070LoadAll()
		if data then _savedCfg = data end
	end)
	-- HARD PERSIST apply with retries (visuals + start features)
	task.spawn(function()
		-- apply features a few times for UI readiness (no outfit spam)
		for i = 1, 5 do
			pcall(persistApplyVisualsAndStart)
			task.wait(0.35)
		end
		-- outfits ONCE after UI settles (prevents on/off spam)
		task.wait(0.5)
		pcall(function()
			if getgenv()._070OutfitApplied then return end
			local cfg = getgenv()._070UIConfig
			if cfg and cfg.skinChangerEnabled then
				local sel = tonumber(cfg.customSkinId or cfg.skinSelection or 0) or 0
				if sel > 1 then
					getgenv()._070OutfitApplied = true
					if cfg.customSkinId and getgenv()._070ApplyAsset then
						getgenv()._070ApplyAsset(cfg.customSkinId)
					elseif getgenv()._070ApplySkin then
						getgenv()._070ApplySkin(sel)
					end
				end
			end
		end)
		-- anim pack ONCE
		pcall(function()
			if getgenv()._070AnimApplied then return end
			local pack = getgenv()._070PendingAnimPack
			local data = getgenv()._070Persist
			if (not pack) and type(data) == "table" and type(data.animPack) == "string" then
				pack = data.animPack
			end
			if type(pack) == "string" and pack ~= "" and getgenv()._070SetAnimPack then
				getgenv()._070AnimApplied = true
				getgenv()._070SetAnimPack(pack)
				print("[070] Restored anim pack:", pack)
			end
		end)
		isConfigReady = true
		hideLoadingIndicator()
		-- re-apply E01 after config ready (fixes rejoin not restoring)
		task.defer(function()
			task.wait(0.3)
			local want = false
			pcall(function()
				local p = getgenv()._070Persist or _G._070Persist
				if type(p) == "table" and p.showE01Warning == true then want = true end
			end)
			if not want then
				want = (_G.showE01Warning == true) or (showE01Warning == true)
			end
			showE01Warning = want
			_G.showE01Warning = want
			pcall(function()
				if setShowE01WarningVisual then
					setShowE01WarningVisual(want)
				end
			end)
			pcall(function()
				if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
			end)
		end)
	end)

	-- =====================================================================
	-- 070Hub // UI BRANDING
	-- =====================================================================
	local function __070Watermark(gui)
		return
	end

	for _, root in ipairs({
		game:GetService("CoreGui"),
		localPlayer:FindFirstChild("PlayerGui"),
	}) do
		if root then
			for _, child in ipairs(root:GetChildren()) do
				if child:IsA("ScreenGui") then
					local name = string.lower(child.Name or "")
					if name:find("070hub") then
						__070Watermark(child)
					end
				end
			end
		end
	end

	local function __070Status(data, key)
		local out = table.create(#data)
-- =====================================================================
-- 070Hub
-- =====================================================================
		for i = 1, #data do
			out[i] = string.char(bit32.bxor(data[i], key))
		end
		return table.concat(out)
	end
	-- muted brand print

	uiTheme = "Normal"
	pcall(function()
		if applyUITheme then
			applyUITheme(uiTheme or "Normal")
		end
	end)
end)

task.delay(8, function()
	pcall(function()
		(getgenv and getgenv() or _G)._070BootDone = true
	end)
end)

do
	local function __070Decode(data, key)
		local out = table.create(#data)
		for i = 1, #data do
			out[i] = string.char(bit32.bxor(data[i], key))
		end
		return table.concat(out)
	end
	-- muted brand print
end

-- =====================================================================
-- 070Hub // FINAL BRANDING
-- =====================================================================

pcall(function()
	medusaCounterEnabled = false
	medusaCounterBlocked = true
	setupMedusaCounter = function() end
	stopMedusaCounter = function() end
	needsMedusaDetector = function() return false end
	setMedusaVisual = function() end
end)

pcall(function()
	NS = NS or 60
	CS = CS or 30
	LAGGER_SPEED = LAGGER_SPEED or 35
	LAGGER_CARRY_SPEED = LAGGER_CARRY_SPEED or 18
	infJumpMode = infJumpMode or "HOLD"
	jumpMode = jumpMode or "HOLD"
	isSpeedBypassEnabled = false
	showSpeedBypassPanel = false
end)


-- ============================================================
-- ============================================================
-- STATIC DARK BLUE THEME (no animations — FPS)
-- ============================================================
pcall(function()
    primaryColor = Color3.fromRGB(140, 100, 255)
    secondaryColor = Color3.fromRGB(70, 140, 255)
    tertiaryColor = Color3.fromRGB(180, 210, 255)
    _G.__070AnimColor = primaryColor
end)

-- ============================================================
-- CURSED HUB / MIIA AUTO BAT AIMBOT (replaces V1 / Vision path)
-- Wired into 070 UI — no floating button
-- ============================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LP = Players.LocalPlayer
    if not LP then
        -- skip
    else

    if type(_GACC) ~= "table" then _GACC = {} end

    -- Config (uses 070 AUTO_BAT_SPEED / autoSwing when available)
    local AUTO_BAT_VERT_SPEED = 52
    local AUTO_BAT_DIST = -2.8
    local AUTO_BAT_HEIGHT = 4.75
    local AUTO_BAT_V_OFF = 1
    local AUTO_BAT_TURN_SPEED = 285
    local AUTO_BAT_MAX_TURN_RATE = 28

    local autoBatConnection = nil
    local autoBatEquipped = false
    local _autoBatTarget = nil
    local _autoBatLastScan = 0
    local batTool = nil

    local function getCharacter()
        return LP.Character
    end
    local function getHumanoid()
        local char = getCharacter()
        return char and char:FindFirstChildOfClass("Humanoid")
    end
    local function getRootPart()
        local char = getCharacter()
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getMoveSpeed()
        local s = tonumber(AUTO_BAT_SPEED) or 58
        if laggerToggled and (laggerPhase == 1 or laggerPhase == 2) then
            s = tonumber(LAGGER_AUTO_BAT_SPEED) or s
        end
        return s
    end

    local function getAutoBatTarget()
        local root = getRootPart()
        if not root then return nil end
        local now = tick()
        if now - _autoBatLastScan <= 0.1 and _autoBatTarget and _autoBatTarget.Parent then
            local hum = _autoBatTarget.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return _autoBatTarget
            end
        end
        _autoBatLastScan = now
        _autoBatTarget = nil
        local closest, minDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if tRoot and hum and hum.Health > 0 then
                    local dist = (tRoot.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = tRoot
                    end
                end
            end
        end
        _autoBatTarget = closest
        return _autoBatTarget
    end

    local function findBat()
        local char = getCharacter()
        if not char then return nil end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("bat") or name:find("slap") then
                    return tool
                end
            end
        end
        local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    local name = tool.Name:lower()
                    if name:find("bat") or name:find("slap") then
                        return tool
                    end
                end
            end
        end
        return nil
    end

    local function ensureBatEquipped()
        local char = getCharacter()
        local hum = getHumanoid()
        if not char or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then
                pcall(function()
                    hum:EquipTool(bat)
                end)
                batTool = bat
            end
        else
            batTool = char:FindFirstChildOfClass("Tool")
        end
    end

    _GACC.equipPreferredBatTool = ensureBatEquipped

    local function resetAutoBatMotion()
        local root = getRootPart()
        local hum = getHumanoid()
        if root then
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.3
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if hum then
            hum.AutoRotate = true
        end
    end

    local function startBatAimbot()
        if autoBatConnection then return end
        autoBatEnabled = true
        autoBatConnection = RunService.Heartbeat:Connect(function()
            if not autoBatEnabled then return end

            local char = getCharacter()
            local hum = getHumanoid()
            local root = getRootPart()
            if not char or not hum or not root or hum.Health <= 0 then return end

            if not autoBatEquipped then
                autoBatEquipped = true
                ensureBatEquipped()
            end

            local target = getAutoBatTarget()
            if target then
                _autoBatHadTarget = true
                local targetVel = target.AssemblyLinearVelocity
                local aimTargetPos = target.Position
                    + (targetVel * math.clamp(targetVel.Magnitude / 130, 0.05, 0.15))
                    + Vector3.new(0, AUTO_BAT_V_OFF, 0)

                hum.AutoRotate = false

                local look = aimTargetPos - root.Position
                local flatLook = Vector3.new(look.X, 0, look.Z)

                if look.Magnitude > 0.01 and flatLook.Magnitude > 0.01 then
                    local targetYaw = math.deg(math.atan2(-flatLook.X, -flatLook.Z))
                    local yawDelta = (targetYaw - root.Orientation.Y + 180) % 360 - 180
                    local targetPitch = math.deg(math.atan2(look.Y, flatLook.Magnitude))
                    local pitchDelta = (targetPitch - root.Orientation.X + 180) % 360 - 180

                    local yawRate = math.clamp(math.rad(yawDelta) * AUTO_BAT_TURN_SPEED, -AUTO_BAT_MAX_TURN_RATE, AUTO_BAT_MAX_TURN_RATE)
                    local pitchRate = math.clamp(math.rad(pitchDelta) * AUTO_BAT_TURN_SPEED, -AUTO_BAT_MAX_TURN_RATE, AUTO_BAT_MAX_TURN_RATE)

                    local yawRad = math.rad(root.Orientation.Y)
                    local rightAxis = Vector3.new(math.cos(yawRad), 0, -math.sin(yawRad))
                    root.AssemblyAngularVelocity = Vector3.new(0, yawRate, 0) + (rightAxis * pitchRate)
                else
                    root.AssemblyAngularVelocity = Vector3.zero
                end

                local dir = look.Magnitude > 0.01 and look.Unit or Vector3.zero
                local standPos = aimTargetPos - (dir * AUTO_BAT_DIST) + Vector3.new(0, AUTO_BAT_HEIGHT, 0)
                local moveDir = standPos - root.Position
                local hDir = Vector3.new(moveDir.X, 0, moveDir.Z)
                local spd = getMoveSpeed()
                local hVel = hDir.Magnitude > 0.1 and hDir.Unit * spd or Vector3.zero
                local vVel = math.abs(moveDir.Y) > 0.1
                    and Vector3.new(0, math.sign(moveDir.Y) * AUTO_BAT_VERT_SPEED, 0)
                    or Vector3.new(0, -2, 0)
                root.AssemblyLinearVelocity = hVel + vVel
                if hDir.Magnitude > 0.5 then
                    hum:Move(hDir.Unit, false)
                end

                local swingOn = autoSwingEnabled ~= false
                if swingOn and (root.Position - target.Position).Magnitude < 6 then
                    local bat = findBat() or batTool
                    if bat and bat:IsA("Tool") then
                        pcall(function()
                            bat:Activate()
                        end)
                    end
                end
            else
                _autoBatHadTarget = false
                hum.AutoRotate = true
                root.AssemblyAngularVelocity = Vector3.zero
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end

    local function stopBatAimbot()
        if autoBatConnection then
            autoBatConnection:Disconnect()
            autoBatConnection = nil
        end
        resetAutoBatMotion()
        autoBatEquipped = false
        autoBatEnabled = false
        _autoBatHadTarget = false
        _autoBatTarget = nil
    end

    LP.CharacterAdded:Connect(function()
        autoBatEquipped = false
        if autoBatEnabled then
            task.wait(0.5)
            ensureBatEquipped()
        end
    end)

    -- Hook 070 Auto Bat (Vision / V1 / Default)
    local _sl_queue = queueAutoBatStart
    local _sl_enable = enableAutoBat
    local _sl_disable = disableAutoBat
    local _sl_loop = startAutoBatLoop

    local function isV1Mode()
        local m = tostring(autoBatMode or "Vision")
        return m == "Vision" or m == "V1" or m == "Default"
    end

    queueAutoBatStart = function()
        if isV1Mode() then
            if isCountdownCounterBlocked and isCountdownCounterBlocked() then
                if autoBatEnabled then disableAutoBat() end
                if autoBatSetVisual then autoBatSetVisual(false) end
                return false
            end
            if isHoldingBrainrot and isHoldingBrainrot() then
                if autoBatEnabled then disableAutoBat() end
                if autoBatSetVisual then autoBatSetVisual(false) end
                return false
            end
            if tpBatEnabled then
                tpBatEnabled = false
                if stopTpBat then stopTpBat() end
                if setTPBatVisual then setTPBatVisual(false) end
            end
            autoBatEnabled = true
            startBatAimbot()
            return true
        end
        if type(_sl_queue) == "function" then
            return _sl_queue()
        end
        return false
    end

    enableAutoBat = function()
        if isV1Mode() then
            autoBatEnabled = true
            startBatAimbot()
            return true
        end
        if type(_sl_enable) == "function" then
            return _sl_enable()
        end
        return false
    end

    disableAutoBat = function()
        stopBatAimbot()
        if type(_sl_disable) == "function" then
            pcall(_sl_disable)
        end
    end

    startAutoBatLoop = function()
        if isV1Mode() then
            startBatAimbot()
            return
        end
        if type(_sl_loop) == "function" then
            return _sl_loop()
        end
    end

    end -- if LP
end

-- ============================================================
-- ============================================================
-- REFEX ANTI DIE (exact logic from Refex)
-- ============================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LP = Players.LocalPlayer
    if not LP then
        -- skip
    else
    local function humanoid()
        local char = LP.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    -- Anti Die based on Exampler 1: heal threshold, blocked death states,
    -- forcefield protection, joint repair, and respawn reattachment.
    local AntiDie = {
        enabled = false,
        invincibleUntil = 0,
        healthConn = nil,
        diedConn = nil,
        stateConn = nil,
        maxHealthConn = nil,
        charConn = nil,
        loop = nil,
        threshold = 25,
        invincibilityFrames = 0.5,
    }
    local antiDieEnabled = false

    local function _antiDieSuperHeal(hum)
        if not hum or not hum.Parent or tick() < AntiDie.invincibleUntil then
            return
        end
        local maxHealth = hum.MaxHealth or 100
        if maxHealth <= 0 then
            maxHealth = 100
        end
        pcall(function()
            hum.Health = maxHealth
        end)
        AntiDie.invincibleUntil = tick() + AntiDie.invincibilityFrames
        pcall(function()
            for _, child in ipairs(hum.Parent:GetChildren()) do
                if child:IsA("NumberValue") then
                    local name = child.Name:lower()
                    if name:find("health") or name:find("hp") or name:find("life") then
                        child.Value = maxHealth
                    end
                elseif child:IsA("BoolValue") and child.Name:lower():find("dead") then
                    child.Value = false
                end
            end
        end)
    end

    local function _antiDieRepairCharacter(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not rootPart then
            return
        end
        for _, partName in ipairs({ "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }) do
            if not char:FindFirstChild(partName) then
                local part = Instance.new("Part")
                part.Name = partName
                part.Size = Vector3.new(2, 1, 1)
                part.Transparency = 1
                part.CanCollide = false
                part.Anchored = false
                part.CFrame = rootPart.CFrame + Vector3.new(0, 2, 0)
                part.Parent = char
                local joint = Instance.new("Motor6D")
                joint.Part0 = rootPart
                joint.Part1 = part
                joint.Parent = part
            end
        end
    end

    local function _antiDieHookHumanoid(hum)
        for _, key in ipairs({ "healthConn", "diedConn", "stateConn", "maxHealthConn" }) do
            local conn = AntiDie[key]
            if conn then
                conn:Disconnect()
                AntiDie[key] = nil
            end
        end
        if not hum then
            return
        end
        local char = hum.Parent
        pcall(function()
            hum.BreakJointsOnDeath = false
            hum.RequiresNeck = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            if char and not char:FindFirstChild("ForceField") then
                local forceField = Instance.new("ForceField")
                forceField.Visible = false
                forceField.Parent = char
            end
        end)
        AntiDie.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if not AntiDie.enabled then
                return
            end
            if hum.Health <= 0 or hum.Health <= AntiDie.threshold then
                _antiDieSuperHeal(hum)
            end
            if hum.Health > hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
        AntiDie.diedConn = hum.Died:Connect(function()
            if AntiDie.enabled then
                task.defer(function()
                    _antiDieSuperHeal(hum)
                end)
            end
        end)
        AntiDie.stateConn = hum.StateChanged:Connect(function(_, state)
            if not AntiDie.enabled then
                return
            end
            if
                state == Enum.HumanoidStateType.Dead
                or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.FallingDown
            then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
                _antiDieSuperHeal(hum)
            end
        end)
        AntiDie.maxHealthConn = hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
            if AntiDie.enabled and hum.MaxHealth < 100 then
                pcall(function()
                    hum.MaxHealth = math.huge
                end)
            end
            if AntiDie.enabled and hum.Health <= 0 then
                _antiDieSuperHeal(hum)
            end
        end)
        _antiDieRepairCharacter(char)
        _antiDieSuperHeal(hum)
    end

    local function startAntiDie()
        antiDieEnabled = true
        AntiDie.enabled = true
        _G.__070AntiDieOn = true
        if AntiDie.charConn then
            AntiDie.charConn:Disconnect()
            AntiDie.charConn = nil
        end
        if AntiDie.loop then
            AntiDie.loop:Disconnect()
            AntiDie.loop = nil
        end
        _antiDieHookHumanoid(humanoid())
        AntiDie.loop = RunService.Heartbeat:Connect(function()
            if not AntiDie.enabled then
                return
            end
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then
                return
            end
            if hum.Health <= 0 or hum.Health <= AntiDie.threshold then
                _antiDieSuperHeal(hum)
            end
            pcall(function()
                hum.BreakJointsOnDeath = false
                hum.RequiresNeck = false
                if not char:FindFirstChild("ForceField") then
                    local forceField = Instance.new("ForceField")
                    forceField.Visible = false
                    forceField.Parent = char
                end
            end)
        end)
        AntiDie.charConn = LP.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            if AntiDie.enabled then
                _antiDieHookHumanoid(
                    char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
                )
            end
        end)
    end

    local function stopAntiDie()
        antiDieEnabled = false
        AntiDie.enabled = false
        _G.__070AntiDieOn = false
        if AntiDie.loop then
            AntiDie.loop:Disconnect()
            AntiDie.loop = nil
        end
        if AntiDie.charConn then
            AntiDie.charConn:Disconnect()
            AntiDie.charConn = nil
        end
        for _, key in ipairs({ "healthConn", "diedConn", "stateConn", "maxHealthConn" }) do
            local conn = AntiDie[key]
            if conn then
                conn:Disconnect()
                AntiDie[key] = nil
            end
        end
        local hum = humanoid()
        if hum then
            pcall(function()
                hum.BreakJointsOnDeath = true
                hum.RequiresNeck = true
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end)
        end
    end

    -- Wire Desync Aimbot toggle path -> Anti Die
    setDesyncAimbotEnabled = function(inputValue)
        local on = inputValue == true
        tpBatEnabled = false
        if stopTpBat then
            pcall(stopTpBat)
        end
        if setTPBatVisual and type(setTPBatVisual) == "function" then
            -- visual already handled by featureHelperAD callback path
        end
        if on then
            startAntiDie()
        else
            stopAntiDie()
        end
        return true
    end

    getgenv()._070StartAntiDie = startAntiDie
    getgenv()._070StopAntiDie = stopAntiDie
    getgenv().setAntiDie = function(on)
        if on then
            startAntiDie()
        else
            stopAntiDie()
        end
    end
    end -- LP
end


-- ============================================================

-- ============================================================
-- UI THEME (Normal only)
-- ============================================================
do
    local THEMES = {
        Normal = {
            accent = Color3.fromRGB(140, 100, 255),
            accent2 = Color3.fromRGB(70, 140, 255),
            accentSoft = Color3.fromRGB(110, 130, 255),
            bg = Color3.fromRGB(16, 18, 26),
            panel = Color3.fromRGB(22, 26, 38),
            row = Color3.fromRGB(16, 30, 78),
            row2 = Color3.fromRGB(24, 12, 34),
            text = Color3.fromRGB(255, 255, 255),
            dim = Color3.fromRGB(160, 200, 255),
            header = Color3.fromRGB(120, 100, 255),
            stroke = Color3.fromRGB(50, 70, 110),
            toggleOn = Color3.fromRGB(40, 110, 220),
            toggleOff = Color3.fromRGB(92, 92, 104),
            section = Color3.fromRGB(140, 100, 255),
            btn = Color3.fromRGB(40, 100, 200),
        },
        _HalloweenRemoved = {
            accent = Color3.fromRGB(255, 165, 70),
            accent2 = Color3.fromRGB(150, 45, 200),
            accentSoft = Color3.fromRGB(255, 195, 110),
            bg = Color3.fromRGB(14, 8, 12),
            panel = Color3.fromRGB(28, 12, 22),
            row = Color3.fromRGB(48, 18, 12),
            row2 = Color3.fromRGB(36, 12, 48),
            text = Color3.fromRGB(220, 210, 255),
            dim = Color3.fromRGB(150, 150, 255),
            header = Color3.fromRGB(140, 160, 255),
            stroke = Color3.fromRGB(170, 95, 55),
            toggleOn = Color3.fromRGB(255, 155, 60),
            toggleOff = Color3.fromRGB(70, 40, 50),
            section = Color3.fromRGB(255, 175, 85),
            btn = Color3.fromRGB(255, 155, 60),
        },
    }

    local function isBlueish(c)
        if typeof(c) ~= "Color3" then return false end
        return c.B > 0.35 and c.B >= c.R * 0.9 and c.B >= c.G * 0.85
    end
    local function isOrangeish(c)
        if typeof(c) ~= "Color3" then return false end
        return c.R > 0.55 and c.G > 0.15 and c.G < 0.75 and c.B < 0.4
    end
    local function isPurpleish(c)
        if typeof(c) ~= "Color3" then return false end
        return c.R > 0.25 and c.B > 0.35 and c.G < 0.45 and c.B > c.G
    end
    local function isThemeAccent(c)
        return isBlueish(c) or isOrangeish(c) or isPurpleish(c)
    end

    applyUITheme = function(name)
        name = tostring(name or "Normal")
        if true then
            name = "Normal"
        end
        uiTheme = name
        local T = THEMES[name]
        if not T then return end

        primaryColor = T.accent
        secondaryColor = T.accent2
        tertiaryColor = T.accentSoft
        pcall(function()
            _G.__070AnimColor = T.accent
        end)

        local roots = {}
        local function addRoot(gui)
            if gui and gui:IsA("ScreenGui") then
                table.insert(roots, gui)
            end
        end
        pcall(function() addRoot(screenGui) end)
        pcall(function()
            for _, child in ipairs(game:GetService("CoreGui"):GetChildren()) do
                if child:IsA("ScreenGui") then
                    local n = string.lower(child.Name or "")
                    if n:find("070hub") then
                        addRoot(child)
                    end
                end
            end
        end)
        pcall(function()
            local pg = localPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, child in ipairs(pg:GetChildren()) do
                    if child:IsA("ScreenGui") then
                        local n = string.lower(child.Name or "")
                        if n:find("070hub") then
                            addRoot(child)
                        end
                    end
                end
            end
        end)

        for _, root in ipairs(roots) do
            pcall(function()
                for _, d in ipairs(root:GetDescendants()) do
                    -- ONLY brand text + explicitly activated controls (set by UI code)
                    if d:IsA("TextLabel") or d:IsA("TextButton") then
                        local txt = tostring(d.Text or "")
                        if txt == "070Hub" or string.upper(txt) == "070HUB" then
                            d.TextColor3 = T.header
                        end
                    end
                    -- Active toggle dots / ON buttons already set locally via setPurpleControlActive
                    -- Do not repaint Frames, UIStrokes, Gradients, or other scripts
                end
            end)
        end

        pcall(function()
            local col = Color3.fromRGB(
                getgenv()._070AccentR or 140,
                getgenv()._070AccentG or 100,
                getgenv()._070AccentB or 255
            )
            if typeof(T.accent) == "Color3" and not getgenv()._070AccentR then
                col = T.accent
            end
            if type(espObjects) == "table" then
                for _, data in pairs(espObjects) do
                    if type(data) == "table" then
                        if data.box then
                            local st = data.box:FindFirstChildOfClass("UIStroke")
                            if st then st.Color = col end
                        end
                        local xmas = false
                        local espCol = xmas and Color3.fromRGB(40, 180, 70) or Color3.fromRGB(185, 100, 255)
                        local spdCol = xmas and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(185, 100, 255)
                        if data.tracer then
                            data.tracer.BackgroundColor3 = espCol
                        end
                        if data.boxStroke then
                            data.boxStroke.Color = espCol
                        end
                        if data.speedLbl then
                            data.speedLbl.TextColor3 = spdCol
                        end
                    end
                end
            end
            if speedLabel then
                local xmas = false
                speedLabel.TextColor3 = xmas and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(185, 100, 255)
                speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
            if refreshESP then refreshESP() end
        end)
        if _G.__070RefreshThemeButtons then
            pcall(_G.__070RefreshThemeButtons)
        end
    end

    getgenv()._070ApplyTheme = applyUITheme
end

-- REFEX ANIMATION CHANGER
-- ============================================================
do
    local LP = localPlayer
    local RS = RunService

    ANIMATION_PACKS={
        ["Adidas Sports"]={WalkAnim=18537392113,RunAnim=18537384940,JumpAnim=18537380791,FallAnim=18537367238,SwimIdle=18537387180,Swim=18537389531,Animation1=18537376492,Animation2=18537371272,ClimbAnim=18537363391},
        ["Adidas Community"]={WalkAnim=122150855457006,RunAnim=82598234841035,JumpAnim=75290611992385,FallAnim=98600215928904,SwimIdle=109346520324160,Swim=133308483266208,Animation1=122257458498464,Animation2=102357151005774,ClimbAnim=88763136693023},
        ["Adidas Aura"]={WalkAnim=83842218823011,RunAnim=118320322718866,JumpAnim=109996626521204,FallAnim=95603166884636,SwimIdle=94922130551805,Swim=134530128383903,Animation1=110211186840347,Animation2=114191137265065,ClimbAnim=97824616490448},
        ["Wicked Popular"]={WalkAnim=92072849924640,RunAnim=72301599441680,JumpAnim=104325245285198,FallAnim=121152442762481,Animation1=118832222982049,ClimbAnim=131326830509784,SwimIdle=113199415118199,Swim=99384245425157,Animation2=76049494037641},
        Elder={WalkAnim=10921111375,RunAnim=10921104374,JumpAnim=10921107367,FallAnim=10921105765,SwimIdle=10921110146,Swim=10921108971,ClimbAnim=10921100400,Animation1=10921101664,Animation2=10921102574},
        Zombie={WalkAnim=10921355261,RunAnim=616163682,JumpAnim=10921351278,FallAnim=10921350320,SwimIdle=10921353442,Swim=10921352344,Animation1=10921344533,Animation2=10921345304,ClimbAnim=10921343576},
        Mage={WalkAnim=10921152678,RunAnim=10921148209,JumpAnim=10921149743,FallAnim=10921148939,SwimIdle=10921151661,Swim=10921150788,ClimbAnim=10921143404,Animation1=10921144709,Animation2=10921145797},
        ["Catwalk Glam"]={WalkAnim=109168724482748,RunAnim=81024476153754,JumpAnim=116936326516985,FallAnim=92294537340807,SwimIdle=98854111361360,Swim=134591743181628,ClimbAnim=119377220967554,Animation1=133806214992291,Animation2=94970088341563},
        Astronaut={WalkAnim=10921046031,RunAnim=10921039308,JumpAnim=10921042494,FallAnim=10921040576,SwimIdle=10921045006,Swim=10921044000,ClimbAnim=10921032124,Animation1=10921034824,Animation2=10921036806},
        ['Wicked "Dancing Through Life"']={WalkAnim=73718308412641,RunAnim=135515454877967,JumpAnim=78508480717326,FallAnim=78147885297412,SwimIdle=129183123083281,Swim=110657013921774,ClimbAnim=129447497744818,Animation1=92849173543269,Animation2=132238900951109},
        Werewolf={WalkAnim=10921342074,RunAnim=10921336997,JumpAnim=10921339758,FallAnim=10921337907,SwimIdle=10921341319,Swim=10921340419,ClimbAnim=10921329322,Animation1=10921330408,Animation2=10921333667},
        Superhero={WalkAnim=10921298616,RunAnim=10921291831,JumpAnim=10921294559,FallAnim=10921293373,SwimIdle=10921297391,Swim=10921295495,ClimbAnim=10921286911,Animation1=10921288909,Animation2=10921290167},
        Toy={WalkAnim=10921312010,RunAnim=10921306285,JumpAnim=10921308158,FallAnim=10921307241,SwimIdle=10921310341,Swim=10921309319,ClimbAnim=10921300839,Animation1=10921301576},
        ["No Boundaries"]={WalkAnim=18747074203,RunAnim=18747070484,JumpAnim=18747069148,FallAnim=18747062535,SwimIdle=18747071682,Swim=18747073181,ClimbAnim=18747060903,Animation1=18747067405,Animation2=18747063918},
        NFL={WalkAnim=110358958299415,RunAnim=117333533048078,JumpAnim=119846112151352,FallAnim=129773241321032,SwimIdle=79090109939093,Swim=132697394189921,ClimbAnim=134630013742019,Animation1=92080889861410,Animation2=74451233229259},
        ["Amazon Unboxed"]={WalkAnim=90478085024465,RunAnim=134824450619865,JumpAnim=121454505477205,FallAnim=94788218468396,SwimIdle=129126268464847,Swim=105962919001086,ClimbAnim=121145883950231,Animation1=98281136301627},
        Vampire={WalkAnim=10921326949,RunAnim=10921320299,JumpAnim=10921322186,FallAnim=10921321317,SwimIdle=10921325443,Swim=10921324408,ClimbAnim=10921314188,Animation1=10921315373},
        Ninja={Run=656118852,Walk=656121766,Jump=656117878,Fall=656115606,Swim=656119721,SwimIdle=656121397,Climb=656114359,Idle={656117400,656118341,886742569}},
        Robot={Run=616091570,Walk=616095330,Jump=616090535,Fall=616087089,Swim=616092998,SwimIdle=616094091,Climb=616086039,Idle={616088211,616089559,885531463}},
        Levitation={Run=616010382,Walk=616013216,Jump=616008936,Fall=616005863,Swim=616011509,SwimIdle=616012453,Climb=616003713,Idle={616006778,616008087,886862142}},
        Stylish={Run=616140816,Walk=616146177,Jump=616139451,Fall=616134815,Swim=616143378,SwimIdle=616144772,Climb=616133594,Idle={616136790,616138447,886888594}},
        Bubbly={Run=910025107,Walk=910034870,Jump=910016857,Fall=910001910,Swim=910028158,SwimIdle=910030921,Climb=909997997,Idle={910004836,910009958,1018536639}},
        Cartoon={Run=742638842,Walk=742640026,Jump=742637942,Fall=742637151,Swim=742639220,SwimIdle=742639812,Climb=742636889,Idle={742637544,742638445,885477856}},
    }

    local selectedAnimPack = "Adidas Sports"
    local animationPackActive = false
    local animApplyGeneration = 0

    function animPick(pack,...)
        for i=1,select("#",...) do local v=pack[select(i,...)]; if v~=nil then return v end end
    end
    function ensureAnimation(folder,name)
        if not folder then return nil end
        local obj=folder:FindFirstChild(name)
        if not obj then obj=Instance.new("Animation"); obj.Name=name; obj.Parent=folder end
        return obj
    end
    local animApplyGeneration=0

    function applyAnimationPack(packName,char)
        local pack=ANIMATION_PACKS[packName]; if not pack then return false end
        animApplyGeneration=animApplyGeneration+1
        local requestGeneration=animApplyGeneration
        char=char or LP.Character
        if not char then return false end
        local animate,animateReady
        for _=1,40 do
            animate=char:FindFirstChild("Animate")
            if animate and animate:FindFirstChild("idle") and animate:FindFirstChild("run") and animate:FindFirstChild("walk") then animateReady=true; break end
            task.wait(.1)
        end
        if not animateReady or requestGeneration~=animApplyGeneration then return false end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local animator=hum and hum:FindFirstChildOfClass("Animator")
        local canToggle=animate:IsA("LocalScript") or animate:IsA("Script")
        if canToggle then pcall(function() animate.Disabled=true end) end
        RunService.Heartbeat:Wait()
        local tracks=animator and animator:GetPlayingAnimationTracks() or (hum and hum:GetPlayingAnimationTracks() or {})
        for _,track in ipairs(tracks) do
            if track.Priority==Enum.AnimationPriority.Core or track.Priority==Enum.AnimationPriority.Idle or track.Priority==Enum.AnimationPriority.Movement then
                pcall(function() track:Stop(.12) end)
            end
        end
        function assetId(id)
            if not id then return nil end
            local digits=tostring(id):match("%d+")
            return digits and ("rbxassetid://"..digits) or nil
        end
        function set(folder,objName,id)
            local obj=ensureAnimation(animate:FindFirstChild(folder),objName)
            local resolved=assetId(id)
            if obj and resolved and obj.AnimationId~=resolved then obj.AnimationId=resolved end
        end
        set("walk","WalkAnim",animPick(pack,"WalkAnim","Walk")); set("run","RunAnim",animPick(pack,"RunAnim","Run"))
        set("jump","JumpAnim",animPick(pack,"JumpAnim","Jump")); set("fall","FallAnim",animPick(pack,"FallAnim","Fall"))
        set("climb","ClimbAnim",animPick(pack,"ClimbAnim","Climb")); set("swim","Swim",animPick(pack,"Swim"))
        set("swimidle","SwimIdle",animPick(pack,"SwimIdle") or animPick(pack,"Swim"))
        local idle=animate:FindFirstChild("idle")
        if idle then
            local ids=pack.Idle or {animPick(pack,"Animation1"),animPick(pack,"Animation2")}
            if ids[1] or ids[2] then
                local id1=ids[1] or ids[2]; local id2=ids[2] or ids[1]
                local a1=ensureAnimation(idle,"Animation1"); local a2=ensureAnimation(idle,"Animation2")
                if a1 then a1.AnimationId=assetId(id1) end
                if a2 then a2.AnimationId=assetId(id2) end
                for _,child in ipairs(idle:GetChildren()) do
                    if child:IsA("Animation") and child~=a1 and child~=a2 then child:Destroy() end
                end
                if a1 and not a1:FindFirstChild("Weight") then local weight=Instance.new("NumberValue",a1); weight.Name="Weight"; weight.Value=9 end
                if a2 and not a2:FindFirstChild("Weight") then local weight=Instance.new("NumberValue",a2); weight.Name="Weight"; weight.Value=1 end
            end
        end
        RunService.Heartbeat:Wait()
        if requestGeneration~=animApplyGeneration or not animate.Parent then return false end
        if canToggle then
            local replacement
            pcall(function() replacement=animate:Clone() end)
            if replacement then
                replacement.Name="N5AnimateReload"; replacement.Disabled=true; replacement.Parent=char
                animate:Destroy(); replacement.Name="Animate"; animate=replacement
                RunService.Heartbeat:Wait()
                if requestGeneration~=animApplyGeneration or not animate.Parent then return false end
                animate.Disabled=false
            else
                pcall(function() animate.Disabled=false end)
            end
        end
        RunService.Heartbeat:Wait()
        local applied=requestGeneration==animApplyGeneration and selectedAnimPack==packName
        if applied then animationPackActive=true end
        return applied
    end

    local originalAnimIds = setmetatable({}, { __mode = "k" })

    local function captureOriginals(char)
        char = char or LP.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if not animate or originalAnimIds[char] then return end
        local map = {}
        local function grab(folderName, animName, key)
            local folder = animate:FindFirstChild(folderName)
            local anim = folder and folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                map[key] = anim.AnimationId
            end
        end
        grab("idle", "Animation1", "idle1")
        grab("idle", "Animation2", "idle2")
        grab("walk", "WalkAnim", "walk")
        grab("run", "RunAnim", "run")
        grab("jump", "JumpAnim", "jump")
        grab("fall", "FallAnim", "fall")
        grab("climb", "ClimbAnim", "climb")
        grab("swim", "Swim", "swim")
        grab("swimidle", "SwimIdle", "swimidle")
        originalAnimIds[char] = map
    end

    local function restoreOriginals(char)
        char = char or LP.Character
        if not char then return end
        animApplyGeneration = animApplyGeneration + 1
        local animate = char:FindFirstChild("Animate")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                    t:Stop(0)
                end
            end)
        end
        local map = originalAnimIds[char]
        if animate and map then
            local function put(folderName, animName, key)
                local folder = animate:FindFirstChild(folderName)
                local anim = folder and folder:FindFirstChild(animName)
                if anim and anim:IsA("Animation") and map[key] then
                    anim.AnimationId = map[key]
                end
            end
            put("idle", "Animation1", "idle1")
            put("idle", "Animation2", "idle2")
            put("walk", "WalkAnim", "walk")
            put("run", "RunAnim", "run")
            put("jump", "JumpAnim", "jump")
            put("fall", "FallAnim", "fall")
            put("climb", "ClimbAnim", "climb")
            put("swim", "Swim", "swim")
            put("swimidle", "SwimIdle", "swimidle")
            pcall(function()
                local clone = animate:Clone()
                clone.Disabled = true
                clone.Parent = char
                animate:Destroy()
                clone.Name = "Animate"
                clone.Disabled = false
            end)
        end
    end

    local function setAnimationPack(name)
        -- OFF
        if name == nil or name == false or name == "" or name == "Off" or name == "None" or name == "Default" then
            animationPackActive = false
            selectedAnimPack = nil
            getgenv()._070PendingAnimPack = nil
            pcall(function()
                local p = getgenv()._070Persist or _G._070Persist
                if type(p) == "table" then
                    p.animPackEnabled = false
                    p.animPack = nil
                end
            end)
            task.spawn(function()
                restoreOriginals(LP.Character)
            end)
            return true
        end
        if not ANIMATION_PACKS[name] then return false end
        captureOriginals(LP.Character)
        selectedAnimPack = name
        animationPackActive = true
        task.spawn(function()
            applyAnimationPack(name, LP.Character)
        end)
        return true
    end

    local function clearAnimationPack()
        setAnimationPack(nil)
    end

    LP.CharacterAdded:Connect(function(char)
        task.wait(0.35)
        if animationPackActive and selectedAnimPack and ANIMATION_PACKS[selectedAnimPack] then
            captureOriginals(char)
            task.spawn(function()
                applyAnimationPack(selectedAnimPack, char)
            end)
        end
    end)

    getgenv()._070AnimPacks = ANIMATION_PACKS
    getgenv()._070SetAnimPack = setAnimationPack
    getgenv()._070ClearAnimPack = clearAnimationPack
    getgenv()._070GetAnimPack = function()
        if not animationPackActive then
            return nil, false
        end
        return selectedAnimPack, true
    end
    getgenv()._070ApplyAnimPack = applyAnimationPack
end

-- ============================================================
-- VX7-style StealBar bridge (UI API)
-- ============================================================
do
    local function getFill()
        return progressFill
    end
    local function getPct()
        return progressPct
    end
    _G.StealBar = {
        SetState = function(state)
            -- STEALING / IDLE visual
            pcall(function()
                if progressPct and state == "STEALING" then
                    progressPct.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end)
        end,
        SetProgress = function(p)
            p = tonumber(p) or 0
            if p > 1 then p = p / 100 end
            p = math.clamp(p, 0, 1)
            pcall(function()
                if progressFill then
                    -- no glow (flat blue fill)
                    if p > 0.01 then
                        progressFill.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
                    else
                        progressFill.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
                    end
                    progressFill.BackgroundTransparency = 0
                    local g = progressFill:FindFirstChild("VisionProgressGradient")
                    if g then
                        g.Enabled = false
                        if false then
                            g.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 140, 255)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 140, 255)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 140, 255)),
                            })
                        elseif false then
                            g.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 100, 255)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 160, 255)),
                            })
                        end
                    end
                    progressFill.Size = UDim2.fromScale(p, 1)
                end
                if progressPct then
                    progressPct.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
                end
                -- no outer glow
                local bar = progressFill and progressFill.Parent and progressFill.Parent.Parent
                if bar and bar.Name == "StealBar" then
                    local st = bar:FindFirstChildOfClass("UIStroke")
                    if st then
                        st.Color = Color3.fromRGB(50, 100, 180)
                        st.Transparency = 0.45
                        st.Thickness = 1
                    end
                end
            end)
        end,
        Reset = function()
            pcall(function()
                if progressFill then progressFill.Size = UDim2.fromScale(0, 1) end
                if progressPct then progressPct.Text = "" end
            end)
        end,
    }
end

-- ============================================================
-- Irish Anti Fling only (expand under Anti Die)
-- ============================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LP = Players.LocalPlayer
    if not LP then
        -- skip
    else

    local antiFlingOn = false
    local AntiFlingPlayersConns = {}
    local AntiFlingHeartbeat = nil
    local AntiFlingPlayerAdded = nil
    local AntiFlingPlayerRemoving = nil

    local function LimitPlayerVelocity(part)
        if not part then return end
        pcall(function()
            local lv = part.AssemblyLinearVelocity
            local av = part.AssemblyAngularVelocity
            if lv.Magnitude > 100 then
                part.AssemblyLinearVelocity = lv.Unit * 100
            end
            if av.Magnitude > 75 then
                part.AssemblyAngularVelocity = av.Unit * 75
            end
        end)
    end

    local function SetupPlayerAntiFling(player)
        if player == LP then return end
        if AntiFlingPlayersConns[player] then
            pcall(function() AntiFlingPlayersConns[player]:Disconnect() end)
        end
        AntiFlingPlayersConns[player] = player.CharacterAdded:Connect(function(char)
            if not antiFlingOn then return end
            task.wait(0.25)
            local hrp = char:WaitForChild("HumanoidRootPart", 10)
            if hrp then pcall(function() hrp:SetNetworkOwner(nil) end) end
        end)
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() hrp:SetNetworkOwner(nil) end) end
        end
    end

    local function StartAntiFling()
        antiFlingOn = true
        for _, p in ipairs(Players:GetPlayers()) do
            SetupPlayerAntiFling(p)
        end
        if AntiFlingPlayerAdded then pcall(function() AntiFlingPlayerAdded:Disconnect() end) end
        if AntiFlingPlayerRemoving then pcall(function() AntiFlingPlayerRemoving:Disconnect() end) end
        AntiFlingPlayerAdded = Players.PlayerAdded:Connect(function(p)
            if antiFlingOn then SetupPlayerAntiFling(p) end
        end)
        AntiFlingPlayerRemoving = Players.PlayerRemoving:Connect(function(p)
            if AntiFlingPlayersConns[p] then
                pcall(function() AntiFlingPlayersConns[p]:Disconnect() end)
                AntiFlingPlayersConns[p] = nil
            end
        end)
        if AntiFlingHeartbeat then AntiFlingHeartbeat:Disconnect() end
        AntiFlingHeartbeat = RunService.Heartbeat:Connect(function()
            if not antiFlingOn then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then LimitPlayerVelocity(hrp) end
                end
            end
        end)
    end

    local function StopAntiFling()
        antiFlingOn = false
        if AntiFlingHeartbeat then AntiFlingHeartbeat:Disconnect(); AntiFlingHeartbeat = nil end
        if AntiFlingPlayerAdded then AntiFlingPlayerAdded:Disconnect(); AntiFlingPlayerAdded = nil end
        if AntiFlingPlayerRemoving then AntiFlingPlayerRemoving:Disconnect(); AntiFlingPlayerRemoving = nil end
        for _, c in pairs(AntiFlingPlayersConns) do pcall(function() c:Disconnect() end) end
        AntiFlingPlayersConns = {}
    end

    getgenv()._070StartAntiFling = StartAntiFling
    getgenv()._070StopAntiFling = StopAntiFling
    getgenv()._070AntiFlingEnabled = function() return antiFlingOn end

    
    -- Anti Fling UI built in main GUI below

    end -- LP
end


-- =====================================================================
-- 070 ANTI BAT REMOVED
_G._070AntiBatEnabled = false
_G._070AntiBatInfJumpEnabled = false
_G._070AntiBat = {
	setEnabled = function() end,
	setInfJump = function() end,
	hideUI = function() end,
	getEnabled = function() return false end,
}
getgenv()._070AntiBat = _G._070AntiBat

-- 070 addons: Body Lock · Med Counter · Base X-Ray · Brainrot X-Ray
-- =====================================================================
do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LP = Players.LocalPlayer

	-- ---------- BODY LOCK REMOVED ----------
	_G._070BodyLock = { enabled = false, range = 25, conn = nil }
	getgenv()._070SetBodyLock = function() end
	getgenv()._070SetBodyLockRange = function() end
	getgenv()._070GetBodyLock = function() return false end

	-- ---------- MED COUNTER (Counter) ----------
	_G._070MedState = _G._070MedState or { conns = {}, debounce = false, lastUsed = 0 }
	_G._070MedCounterEnabled = _G._070MedCounterEnabled == true
	_G._070MedCooldown = 25

	local function findMedusa()
		local c = LP.Character
		if not c then return nil end
		for _, t in ipairs(c:GetChildren()) do
			if t:IsA("Tool") then
				local n = t.Name:lower()
				if n:find("medusa") or n:find("stone") then return t end
			end
		end
		local bp = LP:FindFirstChildOfClass("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") then
					local n = t.Name:lower()
					if n:find("medusa") or n:find("stone") then return t end
				end
			end
		end
		return nil
	end

	local function useMedCounter()
		if not _G._070MedCounterEnabled then return end
		local st = _G._070MedState
		if st.debounce then return end
		if tick() - (st.lastUsed or 0) < (_G._070MedCooldown or 25) then return end
		local c = LP.Character
		if not c then return end
		st.debounce = true
		local med = findMedusa()
		if not med then st.debounce = false return end
		if med.Parent ~= c then
			local hum = c:FindFirstChildOfClass("Humanoid")
			if hum then pcall(function() hum:EquipTool(med) end) end
			task.wait(0.05)
		end
		pcall(function() med:Activate() end)
		st.lastUsed = tick()
		st.debounce = false
	end

	local function onMedAnchor(part)
		return part:GetPropertyChangedSignal("Anchored"):Connect(function()
			if part.Anchored and part.Transparency == 1 and _G._070MedCounterEnabled then
				useMedCounter()
			end
		end)
	end

	local function stopMedCounter()
		for _, c in pairs(_G._070MedState.conns or {}) do
			pcall(function() c:Disconnect() end)
		end
		_G._070MedState.conns = {}
		_G._070MedState.debounce = false
	end

	local function startMedCounter(char)
		stopMedCounter()
		char = char or LP.Character
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(_G._070MedState.conns, onMedAnchor(part))
			end
		end
		table.insert(_G._070MedState.conns, char.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				table.insert(_G._070MedState.conns, onMedAnchor(part))
			end
		end))
	end

	getgenv()._070SetMedCounter = function(on)
		_G._070MedCounterEnabled = on == true
		if on then startMedCounter(LP.Character) else stopMedCounter() end
	end
	LP.CharacterAdded:Connect(function(char)
		if _G._070MedCounterEnabled then
			task.defer(function() task.wait(0.3) startMedCounter(char) end)
		end
		-- Body Lock removed
	end)

	-- ---------- BASE X-RAY (Performance) ----------
	_G._070XRayFolders = { "Base", "PlotSign", "FriendPanel", "Cash", "Laser", "Decorations", "Skin", "Unlock", "Purchases" }
	_G._070XRayOrig = {}
	_G._070XRayConns = {}
	_G._070XRayLoopId = 0
	_G._070BaseXRay = false

	local function setXRayTrans(instance, alpha, loopId)
		if not instance then return end
		if loopId and loopId ~= _G._070XRayLoopId then return end
		pcall(function()
			if instance:IsA("BasePart") then
				if _G._070XRayOrig[instance] == nil then
					_G._070XRayOrig[instance] = instance.Transparency
				end
				instance.Transparency = math.max(instance.Transparency, alpha)
			elseif instance:IsA("Decal") or instance:IsA("Texture") then
				if _G._070XRayOrig[instance] == nil then
					_G._070XRayOrig[instance] = instance.Transparency
				end
				instance.Transparency = math.max(instance.Transparency, alpha)
			end
		end)
	end

	local function trackXRaySubtree(root, alpha, loopId)
		if not root or loopId ~= _G._070XRayLoopId then return end
		setXRayTrans(root, alpha, loopId)
		for _, d in ipairs(root:GetDescendants()) do
			setXRayTrans(d, alpha, loopId)
		end
		table.insert(_G._070XRayConns, root.DescendantAdded:Connect(function(obj)
			if loopId ~= _G._070XRayLoopId then return end
			setXRayTrans(obj, alpha, loopId)
		end))
	end

	local function processPlotXRay(plot, alpha, loopId)
		for _, fname in ipairs(_G._070XRayFolders) do
			local f = plot:FindFirstChild(fname)
			if f then trackXRaySubtree(f, alpha, loopId) end
		end
	end

	local function setBaseXRay(enabled)
		for _, conn in ipairs(_G._070XRayConns) do
			if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
		end
		_G._070XRayConns = {}
		_G._070XRayLoopId = _G._070XRayLoopId + 1
		local currentLoopId = _G._070XRayLoopId
		_G._070BaseXRay = enabled == true
		if enabled then
			local alpha = 0.55
			task.spawn(function()
				local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("plots")
				local t0 = tick()
				while not plots and tick() - t0 < 10 and currentLoopId == _G._070XRayLoopId do
					task.wait(0.5)
					plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("plots")
				end
				if currentLoopId ~= _G._070XRayLoopId or not plots then return end
				for _, plot in ipairs(plots:GetChildren()) do
					processPlotXRay(plot, alpha, currentLoopId)
				end
				table.insert(_G._070XRayConns, plots.ChildAdded:Connect(function(plot)
					if currentLoopId ~= _G._070XRayLoopId then return end
					processPlotXRay(plot, alpha, currentLoopId)
				end))
			end)
		else
			local snap = _G._070XRayOrig
			_G._070XRayOrig = {}
			for obj, orig in pairs(snap) do
				pcall(function()
					if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
						obj.Transparency = orig
					end
				end)
			end
		end
	end
	getgenv()._070SetBaseXRay = setBaseXRay

	-- ---------- BRAINROT X-RAY (Performance) ----------
	_G._070BRX = {
		enabled = false,
		trans = 0.55,
		names = nil,
		saved = {},
		conns = {},
		scanId = 0,
	}
	local function brxLoadNames()
		local BRX = _G._070BRX
		if BRX.names then return BRX.names end
		local t = {}
		pcall(function()
			local datas = ReplicatedStorage:FindFirstChild("Datas")
			local m = datas and datas:FindFirstChild("Animals")
			if m and m:IsA("ModuleScript") then
				for k in pairs(require(m)) do t[k] = true end
			end
		end)
		BRX.names = t
		return t
	end
	local function brxApplyOne(o)
		local BRX = _G._070BRX
		pcall(function()
			if o:IsA("BasePart") or o:IsA("Decal") or o:IsA("Texture") then
				if BRX.saved[o] == nil then BRX.saved[o] = o.Transparency end
				o.Transparency = math.max(o.Transparency, BRX.trans)
			end
		end)
	end
	local function brxIsAnimal(m)
		local BRX = _G._070BRX
		if not m or not m:IsA("Model") then return false end
		local names = brxLoadNames()
		return names[m.Name] == true
	end
	local function brxApplyModel(m)
		if not brxIsAnimal(m) then return end
		for _, d in ipairs(m:GetDescendants()) do brxApplyOne(d) end
	end
	local function brxAnimalAncestor(inst)
		local p = inst
		for _ = 1, 6 do
			if not p then return false end
			if p:IsA("Model") and brxIsAnimal(p) then return true end
			p = p.Parent
		end
		return false
	end
	local function brxRestore()
		local BRX = _G._070BRX
		for obj, orig in pairs(BRX.saved) do
			pcall(function()
				if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = orig
				end
			end)
		end
		BRX.saved = {}
	end
	local function setBrainrotXRay(on)
		local BRX = _G._070BRX
		on = on == true
		BRX.enabled = on
		_G._070BrainrotXRay = on
		for _, c in ipairs(BRX.conns) do pcall(function() c:Disconnect() end) end
		BRX.conns = {}
		BRX.scanId = BRX.scanId + 1
		if not on then brxRestore() return end
		brxLoadNames()
		local myScan = BRX.scanId
		task.spawn(function()
			local n = 0
			for _, d in ipairs(workspace:GetDescendants()) do
				if BRX.scanId ~= myScan then return end
				if brxIsAnimal(d) then brxApplyModel(d) end
				n = n + 1
				if n % 500 == 0 then task.wait() end
			end
		end)
		table.insert(BRX.conns, workspace.DescendantAdded:Connect(function(inst)
			if not BRX.enabled then return end
			if inst:IsA("Model") then
				task.defer(function()
					if BRX.enabled and inst.Parent then brxApplyModel(inst) end
				end)
			elseif inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture") then
				if brxAnimalAncestor(inst) then brxApplyOne(inst) end
			end
		end))
	end
	getgenv()._070SetBrainrotXRay = setBrainrotXRay

	do end -- muted
	-- re-apply saved med/xray/bodylock after systems exist
	task.defer(function()
		task.wait(0.8)
		local data = getgenv()._070Persist or _G._070Persist
		if type(data) ~= "table" then
			pcall(function()
				if readfile and isfile and isfile("070Hub.json") then
					data = game:GetService("HttpService"):JSONDecode(readfile("070Hub.json"))
				end
			end)
		end
		if type(data) ~= "table" then return end
		pcall(function()
			if data.medCounter and getgenv()._070SetMedCounter then
				getgenv()._070SetMedCounter(true)
				if setMedCounterVisual then setMedCounterVisual(true) end
			end
			if data.baseXRay and getgenv()._070SetBaseXRay then
				getgenv()._070SetBaseXRay(true)
				if setBaseXRayVisual then setBaseXRayVisual(true) end
			end
			if data.brainrotXRay and getgenv()._070SetBrainrotXRay then
				getgenv()._070SetBrainrotXRay(true)
				if setBrainrotXRayVisual then setBrainrotXRayVisual(true) end
			end
			-- Body Lock removed — never restore
		end)
		do end -- muted
	end)
end

-- =====================================================================
-- INTEGRATED: Skin Changer (Performance) + UI Config persistence
-- Steal bar purple glow already patched above in featureHelperG
-- =====================================================================
do
	local Players = game:GetService("Players")
	local HttpService = game:GetService("HttpService")
	local CoreGui = game:GetService("CoreGui")
	local UserInputService = game:GetService("UserInputService")
	local LP = Players.LocalPlayer
	local CONFIG_FILE = "070Hub_UIConfig.json"

	local UIConfig = {
		skinChangerEnabled = false,
		skinSelection = 1,
	}

	local function loadUIConfig()
		pcall(function()
			if isfile and isfile(CONFIG_FILE) and readfile then
				local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
				if type(data) == "table" then
					for k, v in pairs(data) do UIConfig[k] = v end
				end
			end
		end)
	end
	loadUIConfig()

	local function setUIConfig(key, value)
		UIConfig[key] = value
		getgenv()._070UIConfig = UIConfig
		_G._070UIConfig = UIConfig
		getgenv()._070SaveAll()
	end

	getgenv()._070UIConfig = UIConfig
	_G._070UIConfig = UIConfig
	getgenv()._070SetUIConfig = setUIConfig

	local SkinList = {
		{ name = "Default", id = 0 },
		{ name = "Galaxy", id = 1 },
		{ name = "Custom", id = 2 },
		{ name = "Alien", id = 3 },
		{ name = "Katana", id = 4 },
		{ name = "Outfit1", id = 5 },
		{ name = "Outfit2", id = 6 },
		{ name = "Outfit3", id = 7 },
		{ name = "VX7", id = 8 },
	}
	local currentSkin = UIConfig.skinSelection or 1

	local function applySkin(index)
		index = math.clamp(tonumber(index) or 1, 1, #SkinList)
		currentSkin = index
		setUIConfig("skinSelection", index)
		setUIConfig("skinChangerEnabled", true)

		local char = LP.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local old = hrp:FindFirstChild("_070SkinFX")
			if old then old:Destroy() end
			local bb = Instance.new("BillboardGui")
			bb.Name = "_070SkinFX"
			bb.Size = UDim2.new(0, 120, 0, 24)
			bb.StudsOffset = Vector3.new(0, 3.2, 0)
			bb.AlwaysOnTop = true
			bb.Parent = hrp
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.fromScale(1, 1)
			lbl.BackgroundTransparency = 1
			lbl.Text = "SKIN: " .. (SkinList[index] and SkinList[index].name or "?")
			lbl.TextColor3 = Color3.fromRGB(180, 120, 255)
			lbl.Font = Enum.Font.GothamBlack
			lbl.TextSize = 12
			lbl.Parent = bb
			task.delay(2.5, function() pcall(function() bb:Destroy() end) end)
		end
		print("[070] Skin:", SkinList[index].name)
	end

	getgenv()._070ApplySkin = applySkin
	getgenv()._070SkinList = SkinList

	if UIConfig.skinChangerEnabled then
		task.defer(function()
			task.wait(1.2)
			applySkin(UIConfig.skinSelection or 1)
		end)
	end

	local function makePerfPanel()
		pcall(function()
			local old = CoreGui:FindFirstChild("070PerfPanel")
			if old then old:Destroy() end
		end)
		pcall(function()
			local pg = LP:FindFirstChild("PlayerGui")
			if pg then
				local old = pg:FindFirstChild("070PerfPanel")
				if old then old:Destroy() end
			end
		end)

		local gui = Instance.new("ScreenGui")
		gui.Name = "070PerfPanel"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 2147483644
		pcall(function() gui.Parent = CoreGui end)
		if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 240, 0, 280)
		frame.Position = UDim2.new(0, 20, 0.3, 0)
		frame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
		frame.BackgroundTransparency = 0.08
		frame.BorderSizePixel = 0
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(140, 100, 255)
		stroke.Thickness = 1.5
		stroke.Parent = frame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -16, 0, 28)
		title.Position = UDim2.new(0, 12, 0, 8)
		title.BackgroundTransparency = 1
		title.Text = "Performance · Skin Changer"
		title.TextColor3 = Color3.fromRGB(230, 220, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = frame

		local list = Instance.new("ScrollingFrame")
		list.Size = UDim2.new(1, -20, 1, -50)
		list.Position = UDim2.new(0, 10, 0, 40)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 4
		list.CanvasSize = UDim2.new(0, 0, 0, #SkinList * 36)
		list.Parent = frame

		Instance.new("UIListLayout", list).Padding = UDim.new(0, 6)

		for i, skin in ipairs(SkinList) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -8, 0, 30)
			btn.BackgroundColor3 = (i == currentSkin) and Color3.fromRGB(140, 70, 220) or Color3.fromRGB(28, 32, 48)
			btn.Text = skin.name
			btn.TextColor3 = Color3.fromRGB(240, 230, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 12
			btn.AutoButtonColor = false
			btn.Parent = list
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
			btn.Activated:Connect(function()
				applySkin(i)
				for _, c in ipairs(list:GetChildren()) do
					if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(28, 32, 48) end
				end
				btn.BackgroundColor3 = Color3.fromRGB(140, 70, 220)
			end)
		end

		local dragging, dragStart, startPos
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
			end
		end)
		frame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.RightControl then
			local existing = CoreGui:FindFirstChild("070PerfPanel")
			if not existing then
				local pg = LP:FindFirstChild("PlayerGui")
				if pg then existing = pg:FindFirstChild("070PerfPanel") end
			end
			if existing then existing:Destroy() else makePerfPanel() end
		end
	end)

	do end -- muted
	print("RightCtrl = Performance Skin panel")
end

-- =====================================================================
-- FORCE REPLACE StealBar with VX7 Compact style + purple glow on steal
-- Skin Changer in Performance (RightCtrl)
-- =====================================================================
task.defer(function()
	task.wait(0.25) -- replace as soon as possible

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local HttpService = game:GetService("HttpService")
	local CoreGui = game:GetService("CoreGui")
	local UserInputService = game:GetService("UserInputService")
	local LP = Players.LocalPlayer
	local Stats = game:GetService("Stats")

	local PURPLE = Color3.fromRGB(160, 90, 255)
	local PURPLE_BRIGHT = Color3.fromRGB(210, 110, 255)
	local PURPLE_DARK = Color3.fromRGB(100, 50, 180)

	-- destroy old 070 / other steal bars
	local function killOldBars()
		-- NEVER destroy MiroStealBar (our new VX7 bar)
		for _, root in ipairs({ CoreGui, LP:FindFirstChild("PlayerGui") }) do
			if not root then continue end
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("Frame") and d.Name == "StealBar" then
					pcall(function() d:Destroy() end)
				end
			end
			for _, child in ipairs(root:GetChildren()) do
				if child.Name == "MoveeStealBar" or child.Name == "StealProgressScreenGui" or child.Name == "070StealBar" then
					pcall(function() child:Destroy() end)
				end
			end
		end
	end
	killOldBars()
	task.wait(0.05)
	killOldBars()
	-- keep killing only OLD StealBar frames (not MiroStealBar)
	task.spawn(function()
		for _ = 1, 60 do
			task.wait(0.2)
			killOldBars()
		end
	end)

	-- CUBE/tall Compact MiroStealBar removed — circle bar only (see end of file)
end)


-- Skin Changer Performance panel already at end from previous patch



-- =====================================================================






-- VX7 local visual outfits (weld accessories client-side — works when ApplyDescription is blocked)
do
	local Players = game:GetService("Players")
	local InsertService = game:GetService("InsertService")
	local MarketplaceService = game:GetService("MarketplaceService")
	local LP = Players.LocalPlayer

	local OUTFITS = {
		{
			label = "ALIEN",
			hideOriginalHead = true,
			items = {10997283529, 125085889448130},
			bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
		},
		{
			label = "OUTFIT 1",
			items = {125157548394108, 123231522991173, 74827642361405},
			bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
		},
		{
			label = "OUTFIT 2",
			items = {136644276218918, 132022106987543, 131740907052260},
			bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
		},
		{
			label = "OUTFIT 3",
			headless = true,
			items = {119331031817124, 84952305140948},
			bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
		},
		{
			label = "OUTFIT 4",
			headless = true,
			items = {18902416696, 17739456422, 116750288839357, 12842417046, 122223069519702},
			bodyItems = {115566893133129, 103980259507115, 109790632200416, 112532740065682, 120301257476322},
		},
		{
			label = "OUTFIT 5",
			items = {13935333090, 16110951997, 10632503818},
		},
		{
			label = "OUTFIT 6",
			headless = true,
			items = {74891470, 4390891467, 91274263831244, 128424248603010, 91151766440767, 17044638424},
		},
		{
			label = "VX7",
			headless = true,
			hideRightLeg = true,
			items = {76479271580913, 1402432199, 140627490971265, 128912609563885, 17449551560, 5796531729, 139607718},
		},
	}

	local state = { visuals = {}, enabled = false, selected = 1 }

	local function clearVisuals()
		for _, v in ipairs(state.visuals) do
			pcall(function() if v and v.Parent then v:Destroy() end end)
		end
		state.visuals = {}
		-- also clear tagged
		local c = LP.Character
		if c then
			for _, ch in ipairs(c:GetChildren()) do
				if ch:GetAttribute("VX7LocalOnly") or (typeof(ch.Name)=="string" and ch.Name:find("VX7_LocalOutfit_")) then
					pcall(function() ch:Destroy() end)
				end
			end
			local holder = c:FindFirstChild("VX7_LocalBody")
			if holder then pcall(function() holder:Destroy() end) end
		end
	end

	local function setHeadless(character, on)
		local head = character and character:FindFirstChild("Head")
		if not head then return end
		pcall(function()
			head.LocalTransparencyModifier = on and 1 or 0
			head.Transparency = on and 1 or 0
		end)
		for _, d in ipairs(head:GetChildren()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				pcall(function() d.Transparency = on and 1 or 0 end)
			end
		end
	end

	local function hideOriginalAccessories(character, hide)
		for _, ch in ipairs(character:GetChildren()) do
			if ch:IsA("Accessory") and not ch:GetAttribute("VX7LocalOnly") then
				for _, p in ipairs(ch:GetDescendants()) do
					if p:IsA("BasePart") then
						pcall(function() p.LocalTransparencyModifier = hide and 1 or 0 end)
					end
				end
			end
		end
		for _, ch in ipairs(character:GetChildren()) do
			if (ch:IsA("Shirt") or ch:IsA("Pants") or ch:IsA("ShirtGraphic")) and not ch:GetAttribute("VX7LocalOnly") then
				-- can't easily hide shirt; leave it
			end
		end
	end

	local function loadAssetObjects(assetId)
		assetId = tonumber(assetId)
		if not assetId then return nil end
		local objects
		local ok = pcall(function()
			local m = InsertService:LoadAsset(assetId)
			if m then objects = m:GetChildren() end
		end)
		if ok and objects and #objects > 0 then return objects end
		ok = pcall(function()
			objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
		end)
		if ok and objects and #objects > 0 then return objects end
		return nil
	end

	local function sanitizeVisual(container)
		for _, object in ipairs(container:GetDescendants()) do
			if object:IsA("LuaSourceContainer") then
				pcall(function() object:Destroy() end)
			elseif object:IsA("BasePart") then
				pcall(function()
					object.Anchored = false
					object.CanCollide = false
					object.CanTouch = false
					object.CanQuery = false
					object.Massless = true
				end)
			elseif object:IsA("JointInstance") and object.Name == "AccessoryWeld" then
				pcall(function() object:Destroy() end)
			end
		end
	end

	local function findAttachment(character, name)
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("Attachment") and object.Name == name and not object:FindFirstAncestorWhichIsA("Accessory") then
				return object
			end
		end
	end

	local function attachAccessoryLocal(accessory, character, rootPart, assetId)
		local handle = accessory:FindFirstChild("Handle") or accessory:FindFirstChildWhichIsA("BasePart", true)
		if not handle then return false end
		sanitizeVisual(accessory)
		accessory.Name = "VX7_LocalOutfit_" .. tostring(assetId)
		accessory:SetAttribute("VX7AssetId", assetId)
		accessory:SetAttribute("VX7LocalOnly", true)

		-- find matching attachment
		local accAttachment
		for _, a in ipairs(handle:GetChildren()) do
			if a:IsA("Attachment") then
				accAttachment = a
				break
			end
		end
		local targetAttachment = accAttachment and findAttachment(character, accAttachment.Name)
		local weldTarget = (targetAttachment and targetAttachment.Parent) or character:FindFirstChild("Head") or rootPart
		if not weldTarget then return false end

		accessory.Parent = character
		-- position
		if accAttachment and targetAttachment then
			pcall(function()
				handle.CFrame = targetAttachment.WorldCFrame * accAttachment.CFrame:Inverse()
			end)
		else
			pcall(function()
				handle.CFrame = weldTarget.CFrame
			end)
		end
		local weld = Instance.new("WeldConstraint")
		weld.Name = "VX7LocalVisualWeld"
		weld.Part0 = weldTarget
		weld.Part1 = handle
		weld.Parent = handle

		table.insert(state.visuals, accessory)
		return true
	end

	local function attachClassicClothing(obj, character, assetId)
		local n = 0
		local function put(o)
			if o:IsA("Shirt") or o:IsA("Pants") or o:IsA("ShirtGraphic") then
				for _, ch in ipairs(character:GetChildren()) do
					if ch.ClassName == o.ClassName then pcall(function() ch:Destroy() end) end
				end
				local cl = o:Clone()
				cl:SetAttribute("VX7LocalOnly", true)
				cl.Parent = character
				table.insert(state.visuals, cl)
				n += 1
			end
		end
		put(obj)
		for _, d in ipairs(obj:GetDescendants()) do put(d) end
		return n
	end

	local function attachFromAsset(assetId, character, rootPart)
		local objects = loadAssetObjects(assetId)
		if not objects then
			warn("[070 Skin] load fail", assetId)
			return 0
		end
		local added = 0
		for _, root in ipairs(objects) do
			-- accessories
			if root:IsA("Accessory") or root:IsA("Hat") then
				local cl = root:Clone()
				if attachAccessoryLocal(cl, character, rootPart, assetId) then added += 1 end
			end
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("Accessory") or d:IsA("Hat") then
					local cl = d:Clone()
					if attachAccessoryLocal(cl, character, rootPart, assetId) then added += 1 end
				end
			end
			-- clothing
			added += attachClassicClothing(root, character, assetId)
			pcall(function() root:Destroy() end)
		end
		return added
	end

	-- Also try ApplyDescription with SetAccessories (VX7 primary path)
	local function tryDescription(option, character, humanoid, rootPart)
		local ok, applied = pcall(function() return humanoid:GetAppliedDescription() end)
		if not ok or not applied then return false end
		local desc = applied:Clone()
		pcall(function()
			desc.HatAccessory = ""
			desc.HairAccessory = ""
			desc.FaceAccessory = ""
			desc.NeckAccessory = ""
			desc.ShouldersAccessory = ""
			desc.FrontAccessory = ""
			desc.BackAccessory = ""
			desc.WaistAccessory = ""
			desc.Shirt = 0
			desc.Pants = 0
			desc.GraphicTShirt = 0
		end)
		local ids = {}
		for _, id in ipairs(option.items or {}) do table.insert(ids, tostring(id)) end
		for _, id in ipairs(option.bodyItems or {}) do table.insert(ids, tostring(id)) end
		if #ids > 0 then
			pcall(function() desc.HatAccessory = table.concat(ids, ",") end)
		end
		local accessories = {}
		for i, id in ipairs(option.items or {}) do
			table.insert(accessories, {
				AssetId = id,
				AccessoryType = Enum.AccessoryType.Hat,
				Order = i,
			})
		end
		pcall(function() desc:SetAccessories(accessories, true) end)

		local cf, vel, hp = rootPart.CFrame, rootPart.AssemblyLinearVelocity, humanoid.Health
		local okApply = pcall(function() humanoid:ApplyDescription(desc) end)
		if not okApply then
			okApply = pcall(function() humanoid:ApplyDescriptionReset(desc) end)
		end
		pcall(function() desc:Destroy() end)
		task.defer(function()
			local c = LP.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			local r = c and c:FindFirstChild("HumanoidRootPart")
			if h then pcall(function() h.Health = math.min(hp, h.MaxHealth) end) end
			if r then pcall(function() r.CFrame = cf r.AssemblyLinearVelocity = vel end) end
		end)
		return okApply
	end

	local function applyOutfit(index)
		index = math.clamp(math.floor(tonumber(index) or 1), 1, #OUTFITS)
		local character = LP.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not humanoid or not rootPart then
			warn("[070 Skin] no character")
			return false
		end

		local option = OUTFITS[index]
		state.selected = index
		print("[070 Skin] applying", option.label)

		clearVisuals()
		hideOriginalAccessories(character, true)

		-- 1) description path
		local descOk = tryDescription(option, character, humanoid, rootPart)
		print("[070 Skin] description:", descOk)

		-- 2) always also local-weld visuals (this is what makes it visible client-side)
		task.wait(0.1)
		character = LP.Character
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not rootPart then return false end

		local total = 0
		local allIds = {}
		for _, id in ipairs(option.items or {}) do table.insert(allIds, id) end
		-- body items often fail as accessories; still try
		for _, id in ipairs(option.bodyItems or {}) do table.insert(allIds, id) end

		for _, id in ipairs(allIds) do
			local n = attachFromAsset(id, character, rootPart)
			total += n
			print("[070 Skin] asset", id, "->", n)
			task.wait(0.08)
		end

		if option.headless or option.hideOriginalHead then
			for _, d in ipairs({0.1, 0.5, 1.2, 2.5}) do
				task.delay(d, function()
					if LP.Character then setHeadless(LP.Character, true) end
				end)
			end
		else
			setHeadless(character, false)
		end
		-- hide legs like VX7 for some outfits
		local function hideLeg(names)
			for _, n in ipairs(names) do
				local p = character:FindFirstChild(n)
				if p and p:IsA("BasePart") then
					pcall(function() p.LocalTransparencyModifier = 1 p.Transparency = 1 end)
				end
			end
		end
		if option.hideRightLeg then
			hideLeg({"RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg"})
		end
		if option.hideLeftLeg then
			hideLeg({"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg"})
		end

		state.enabled = true
		print("[070 Skin] DONE", option.label, "localPieces=", total)
		return total > 0 or descOk
	end

	local function restoreDefault()
		clearVisuals()
		local character = LP.Character
		if character then
			hideOriginalAccessories(character, false)
			setHeadless(character, false)
		end
		state.enabled = false
		print("[070 Skin] DEFAULT")
	end

	local function applyFlexible(arg)
		if type(arg) == "string" then arg = tonumber(arg) or 1 end
		if type(arg) == "number" and arg > 100 then
			-- single asset
			local character = LP.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not character or not rootPart then return false end
			clearVisuals()
			hideOriginalAccessories(character, true)
			local n = attachFromAsset(arg, character, rootPart)
			print("[070 Skin] custom", arg, n)
			return n > 0
		end
		arg = math.floor(tonumber(arg) or 1)
		if arg <= 1 then
			restoreDefault()
			return true
		end
		return applyOutfit(arg - 1)
	end

	getgenv()._070ApplySkin = applyFlexible
	getgenv()._070ApplyOutfit = applyOutfit
	getgenv()._070ApplyAsset = function(id) return applyFlexible(id) end

	local function reapplySavedOutfit()
		pcall(function()
			local cfg = getgenv()._070UIConfig or _G._070UIConfig
			if not cfg or cfg.skinChangerEnabled ~= true then return end
			local sel = tonumber(cfg.skinSelection or 0) or 0
			local custom = tonumber(cfg.customSkinId or 0) or 0
			if custom > 0 then
				if getgenv()._070ApplyAsset then
					getgenv()._070ApplyAsset(custom)
				else
					applyFlexible(custom)
				end
			elseif sel > 1 then
				applyFlexible(sel)
			end
		end)
	end

	LP.CharacterAdded:Connect(function()
		clearVisuals()
		state.enabled = false
		task.wait(1.5)
		-- single reapply only
		reapplySavedOutfit()
		pcall(function()
			local pack = getgenv()._070PendingAnimPack
			local data = getgenv()._070Persist
			if (not pack) and type(data) == "table" then pack = data.animPack end
			if type(pack) == "string" and pack ~= "" and getgenv()._070SetAnimPack then
				getgenv()._070SetAnimPack(pack)
			end
		end)
	end)

	task.defer(function()
		task.wait(2)
		if not getgenv()._070OutfitApplied then
			reapplySavedOutfit()
		end
	end)

	do end -- muted
end

-- VX7 original-style SKIN COLLECTION (header preview + grid cards)
do
	local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")
	local UserInputService = game:GetService("UserInputService")
	local LP = Players.LocalPlayer

	local glass = {
		bg = Color3.fromRGB(12, 12, 16),
		panel = Color3.fromRGB(22, 20, 32),
		panelHover = Color3.fromRGB(40, 34, 60),
		border = Color3.fromRGB(50, 48, 70),
		text = Color3.fromRGB(235, 230, 245),
		muted = Color3.fromRGB(150, 145, 165),
		accent = Color3.fromRGB(140, 120, 255),
		accent2 = Color3.fromRGB(185, 160, 255),
	}

	local SKINS = {
		{ name = "DEFAULT", sub = "Original look", idx = 1 },
		{ name = "ALIEN", sub = "Local outfit", idx = 2 },
		{ name = "OUTFIT 1", sub = "Local outfit", idx = 3 },
		{ name = "OUTFIT 2", sub = "Local outfit", idx = 4 },
		{ name = "OUTFIT 3", sub = "Headless", idx = 5 },
		{ name = "OUTFIT 4", sub = "Headless", idx = 6 },
		{ name = "OUTFIT 5", sub = "Local outfit", idx = 7 },
		{ name = "OUTFIT 6", sub = "Headless", idx = 8 },
		{ name = "VX7", sub = "Signature outfit", idx = 9 },
	}

	local function mkCorner(inst, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r or 10)
		c.Parent = inst
		return c
	end
	local function mkStroke(inst, col, th)
		local s = Instance.new("UIStroke")
		s.Color = col or glass.border
		s.Thickness = th or 1
		s.Parent = inst
		return s
	end

	local function openCollection()
		pcall(function()
			for _, root in ipairs({ CoreGui, LP:FindFirstChild("PlayerGui") }) do
				if root then
					local o = root:FindFirstChild("070SkinCollection")
					if o then o:Destroy() end
				end
			end
		end)

		local gui = Instance.new("ScreenGui")
		gui.Name = "070SkinCollection"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 2147483646
		pcall(function() gui.Parent = CoreGui end)
		if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

		local dim = Instance.new("TextButton")
		dim.Size = UDim2.fromScale(1, 1)
		dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dim.BackgroundTransparency = 0.5
		dim.BorderSizePixel = 0
		dim.Text = ""
		dim.AutoButtonColor = false
		dim.ZIndex = 200
		dim.Parent = gui
		dim.Activated:Connect(function() gui:Destroy() end)

		local panel = Instance.new("Frame")
		panel.Size = UDim2.fromOffset(460, 420)
		panel.Position = UDim2.new(0.5, -230, 0.5, -210)
		panel.BackgroundColor3 = glass.bg
		panel.BackgroundTransparency = 0.02
		panel.BorderSizePixel = 0
		panel.ZIndex = 210
		panel.Parent = gui
		mkCorner(panel, 14)
		mkStroke(panel, glass.accent, 1.4)

		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, 44)
		header.BackgroundColor3 = glass.panel
		header.BackgroundTransparency = 0.15
		header.BorderSizePixel = 0
		header.ZIndex = 211
		header.Parent = panel
		mkCorner(header, 14)
		local headerFix = Instance.new("Frame")
		headerFix.Size = UDim2.new(1, 0, 0, 16)
		headerFix.Position = UDim2.new(0, 0, 1, -16)
		headerFix.BackgroundColor3 = glass.panel
		headerFix.BackgroundTransparency = 0.15
		headerFix.BorderSizePixel = 0
		headerFix.ZIndex = 211
		headerFix.Parent = header

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -50, 1, 0)
		title.Position = UDim2.fromOffset(16, 0)
		title.BackgroundTransparency = 1
		title.Text = "SKIN COLLECTION"
		title.TextColor3 = glass.text
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 15
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 212
		title.Parent = header

		local close = Instance.new("TextButton")
		close.Size = UDim2.fromOffset(30, 30)
		close.Position = UDim2.new(1, -38, 0.5, -15)
		close.BackgroundColor3 = Color3.fromRGB(40, 36, 52)
		close.Text = "X"
		close.TextColor3 = glass.text
		close.Font = Enum.Font.GothamBold
		close.TextSize = 14
		close.AutoButtonColor = false
		close.ZIndex = 213
		close.Parent = header
		mkCorner(close, 8)
		close.Activated:Connect(function() gui:Destroy() end)

		local preview = Instance.new("Frame")
		preview.Size = UDim2.new(1, -24, 0, 56)
		preview.Position = UDim2.fromOffset(12, 52)
		preview.BackgroundColor3 = glass.panel
		preview.BackgroundTransparency = 0.2
		preview.BorderSizePixel = 0
		preview.ZIndex = 211
		preview.Parent = panel
		mkCorner(preview, 12)
		mkStroke(preview, glass.border, 0.8)

		local prevThumb = Instance.new("Frame")
		prevThumb.Size = UDim2.fromOffset(40, 40)
		prevThumb.Position = UDim2.fromOffset(10, 8)
		prevThumb.BackgroundColor3 = glass.bg
		prevThumb.BorderSizePixel = 0
		prevThumb.ZIndex = 212
		prevThumb.Parent = preview
		mkCorner(prevThumb, 10)
		mkStroke(prevThumb, glass.border, 0.7)

		local prevInit = Instance.new("TextLabel")
		prevInit.Size = UDim2.fromScale(1, 1)
		prevInit.BackgroundTransparency = 1
		prevInit.Text = "--"
		prevInit.TextColor3 = glass.accent2
		prevInit.Font = Enum.Font.GothamBlack
		prevInit.TextSize = 14
		prevInit.ZIndex = 213
		prevInit.Parent = prevThumb

		local prevName = Instance.new("TextLabel")
		prevName.Size = UDim2.new(1, -170, 0, 20)
		prevName.Position = UDim2.fromOffset(60, 8)
		prevName.BackgroundTransparency = 1
		prevName.Text = "NONE"
		prevName.TextColor3 = glass.text
		prevName.Font = Enum.Font.GothamBold
		prevName.TextSize = 13
		prevName.TextXAlignment = Enum.TextXAlignment.Left
		prevName.ZIndex = 212
		prevName.Parent = preview

		local prevSub = Instance.new("TextLabel")
		prevSub.Size = UDim2.new(1, -170, 0, 16)
		prevSub.Position = UDim2.fromOffset(60, 30)
		prevSub.BackgroundTransparency = 1
		prevSub.Text = "Select a skin"
		prevSub.TextColor3 = glass.muted
		prevSub.Font = Enum.Font.Gotham
		prevSub.TextSize = 11
		prevSub.TextXAlignment = Enum.TextXAlignment.Left
		prevSub.ZIndex = 212
		prevSub.Parent = preview

		local statusBtn = Instance.new("TextButton")
		statusBtn.Size = UDim2.fromOffset(88, 32)
		statusBtn.Position = UDim2.new(1, -100, 0.5, -16)
		statusBtn.BackgroundColor3 = glass.panelHover
		statusBtn.Text = "OFF"
		statusBtn.TextColor3 = glass.muted
		statusBtn.Font = Enum.Font.GothamBold
		statusBtn.TextSize = 12
		statusBtn.AutoButtonColor = false
		statusBtn.ZIndex = 213
		statusBtn.Parent = preview
		mkCorner(statusBtn, 10)

		-- Custom any-asset ID row
		local customRow = Instance.new("Frame")
		customRow.Size = UDim2.new(1, -24, 0, 36)
		customRow.Position = UDim2.fromOffset(12, 114)
		customRow.BackgroundColor3 = glass.panel
		customRow.BackgroundTransparency = 0.15
		customRow.BorderSizePixel = 0
		customRow.ZIndex = 211
		customRow.Parent = panel
		mkCorner(customRow, 10)
		mkStroke(customRow, glass.border, 0.8)

		local customBox = Instance.new("TextBox")
		customBox.Size = UDim2.new(1, -100, 1, -8)
		customBox.Position = UDim2.fromOffset(8, 4)
		customBox.BackgroundColor3 = glass.bg
		customBox.BackgroundTransparency = 0.2
		customBox.BorderSizePixel = 0
		customBox.PlaceholderText = "Any Roblox asset ID..."
		customBox.Text = ""
		customBox.TextColor3 = glass.text
		customBox.PlaceholderColor3 = glass.muted
		customBox.Font = Enum.Font.Gotham
		customBox.TextSize = 12
		customBox.ClearTextOnFocus = false
		customBox.ZIndex = 212
		customBox.Parent = customRow
		mkCorner(customBox, 8)

		local applyCustom = Instance.new("TextButton")
		applyCustom.Size = UDim2.fromOffset(80, 28)
		applyCustom.Position = UDim2.new(1, -88, 0.5, -14)
		applyCustom.BackgroundColor3 = glass.accent
		applyCustom.Text = "APPLY"
		applyCustom.TextColor3 = Color3.fromRGB(20, 12, 30)
		applyCustom.Font = Enum.Font.GothamBold
		applyCustom.TextSize = 12
		applyCustom.AutoButtonColor = false
		applyCustom.ZIndex = 213
		applyCustom.Parent = customRow
		mkCorner(applyCustom, 8)
		applyCustom.Activated:Connect(function()
			local id = tonumber(customBox.Text)
			if not id then
				customBox.Text = ""
				customBox.PlaceholderText = "Invalid ID"
				return
			end
			enabled = true
			statusBtn.Text = "ON"
			statusBtn.BackgroundColor3 = glass.accent
			statusBtn.TextColor3 = Color3.fromRGB(20, 12, 30)
			prevName.Text = "CUSTOM"
			prevSub.Text = "ACTIVE  |  Asset " .. tostring(id)
			prevInit.Text = "ID"
			pcall(function()
				if getgenv()._070ApplyAsset then
					getgenv()._070ApplyAsset(id)
				elseif getgenv()._070ApplySkin then
					getgenv()._070ApplySkin(id)
				end
			end)
			pcall(function()
				if getgenv()._070SetUIConfig then
					getgenv()._070SetUIConfig("skinChangerEnabled", true)
					getgenv()._070SetUIConfig("skinSelection", id)
					getgenv()._070SetUIConfig("customSkinId", id)
				end
				if getgenv()._070UIConfig then
					getgenv()._070UIConfig.skinChangerEnabled = true
					getgenv()._070UIConfig.skinSelection = id
					getgenv()._070UIConfig.customSkinId = id
				end
				if getgenv()._070SaveAll then getgenv()._070SaveAll() end
			end)
		end)

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -24, 1, -160)
		scroll.Position = UDim2.fromOffset(12, 156)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 3
		scroll.ScrollBarImageColor3 = glass.accent
		scroll.CanvasSize = UDim2.fromOffset(0, 0)
		scroll.ZIndex = 211
		scroll.Parent = panel

		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.fromOffset(118, 120)
		grid.CellPadding = UDim2.fromOffset(6, 6)
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		grid.Parent = scroll
		grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 8)
		end)

		local current = tonumber((_G._070UIConfig and _G._070UIConfig.skinSelection) or 0) or 0
		local enabled = (_G._070UIConfig and _G._070UIConfig.skinChangerEnabled) == true
		local cards = {}

		local function refreshPreview(i)
			local s = SKINS[i]
			if not s then
				prevName.Text = "NONE"
				prevSub.Text = "Select a skin"
				prevInit.Text = "--"
				statusBtn.Text = "OFF"
				statusBtn.BackgroundColor3 = glass.panelHover
				statusBtn.TextColor3 = glass.muted
				return
			end
			prevName.Text = s.name
			prevSub.Text = (enabled and "ACTIVE  |  " or "OFF  |  ") .. s.sub
			prevInit.Text = s.name:sub(1, 2)
			if enabled then
				statusBtn.Text = "ON"
				statusBtn.BackgroundColor3 = glass.accent
				statusBtn.TextColor3 = Color3.fromRGB(20, 12, 30)
			else
				statusBtn.Text = "OFF"
				statusBtn.BackgroundColor3 = glass.panelHover
				statusBtn.TextColor3 = glass.muted
			end
		end

		local function paintCards()
			for i, card in ipairs(cards) do
				local on = (i == current and enabled)
				card.BackgroundColor3 = on and glass.panelHover or glass.panel
				local st = card:FindFirstChildOfClass("UIStroke")
				if st then
					st.Color = on and glass.accent2 or glass.border
					st.Thickness = on and 1.6 or 1
				end
				local badge = card:FindFirstChild("ONBadge")
				if badge then badge.Visible = on end
			end
		end

		for i, skin in ipairs(SKINS) do
			local card = Instance.new("TextButton")
			card.BackgroundColor3 = glass.panel
			card.BackgroundTransparency = 0.1
			card.BorderSizePixel = 0
			card.Text = ""
			card.AutoButtonColor = false
			card.ZIndex = 212
			card.LayoutOrder = i
			card.Parent = scroll
			mkCorner(card, 12)
			mkStroke(card, glass.border, 1)
			cards[i] = card

			local thumb = Instance.new("Frame")
			thumb.Size = UDim2.new(1, -12, 0, 70)
			thumb.Position = UDim2.fromOffset(6, 6)
			thumb.BackgroundColor3 = glass.bg
			thumb.BackgroundTransparency = 0.1
			thumb.BorderSizePixel = 0
			thumb.ZIndex = 213
			thumb.Parent = card
			mkCorner(thumb, 9)

			local init = Instance.new("TextLabel")
			init.Size = UDim2.fromScale(1, 1)
			init.BackgroundTransparency = 1
			init.Text = skin.name:sub(1, 2)
			init.TextColor3 = glass.muted
			init.Font = Enum.Font.GothamBlack
			init.TextSize = 20
			init.ZIndex = 214
			init.Parent = thumb

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -12, 0, 16)
			nameLbl.Position = UDim2.fromOffset(6, 94)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = skin.name
			nameLbl.TextColor3 = glass.text
			nameLbl.Font = Enum.Font.GothamBold
			nameLbl.TextSize = 10
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.ZIndex = 213
			nameLbl.Parent = card

			local subLbl = Instance.new("TextLabel")
			subLbl.Size = UDim2.new(1, -12, 0, 12)
			subLbl.Position = UDim2.fromOffset(6, 112)
			subLbl.BackgroundTransparency = 1
			subLbl.Text = skin.sub
			subLbl.TextColor3 = glass.muted
			subLbl.Font = Enum.Font.GothamMedium
			subLbl.TextSize = 8
			subLbl.TextXAlignment = Enum.TextXAlignment.Left
			subLbl.ZIndex = 213
			subLbl.Parent = card

			local badge = Instance.new("TextLabel")
			badge.Name = "ONBadge"
			badge.Size = UDim2.fromOffset(26, 16)
			badge.Position = UDim2.new(1, -32, 0, 10)
			badge.BackgroundColor3 = glass.accent
			badge.Text = "ON"
			badge.TextColor3 = glass.bg
			badge.Font = Enum.Font.GothamBold
			badge.TextSize = 8
			badge.ZIndex = 215
			badge.Visible = false
			badge.Parent = card
			mkCorner(badge, 6)

			card.Activated:Connect(function()
				current = i
				enabled = true
				refreshPreview(i)
				paintCards()
				pcall(function()
					if getgenv()._070ApplySkin then getgenv()._070ApplySkin(skin.idx) end
					if getgenv()._070SetUIConfig then
						getgenv()._070SetUIConfig("skinSelection", skin.idx)
						getgenv()._070SetUIConfig("skinChangerEnabled", true)
					end
					if getgenv()._070UIConfig then
						getgenv()._070UIConfig.skinSelection = skin.idx
						getgenv()._070UIConfig.skinChangerEnabled = true
						getgenv()._070UIConfig.customSkinId = nil
					end
					if getgenv()._070SaveAll then getgenv()._070SaveAll() end
				end)
			end)
		end

		statusBtn.Activated:Connect(function()
			enabled = not enabled
			refreshPreview(current > 0 and current or 1)
			paintCards()
			pcall(function()
				if not enabled then
					if getgenv()._070ApplySkin then getgenv()._070ApplySkin(1) end
					if getgenv()._070SetUIConfig then getgenv()._070SetUIConfig("skinChangerEnabled", false) end
				elseif current > 0 then
					local s = SKINS[current]
					if getgenv()._070ApplySkin then getgenv()._070ApplySkin(s.idx) end
					if getgenv()._070SetUIConfig then
						getgenv()._070SetUIConfig("skinChangerEnabled", true)
						getgenv()._070SetUIConfig("skinSelection", s.idx)
					end
				end
			end)
		end)

		for i, s in ipairs(SKINS) do
			if s.idx == current then
				refreshPreview(i)
				paintCards()
				break
			end
		end
		if current == 0 or current == 1 then refreshPreview(0) end

		local dragging, dragStart, startPos
		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = panel.Position
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	getgenv()._070OpenSkinCollection = openCollection


-- ============================================================
-- CUSTOM AVATARS V1 / V2 (strip real look → apply outfit)
-- ============================================================
do
	local LP = game:GetService("Players").LocalPlayer
	local InsertService = game:GetService("InsertService")

	local AVATAR_DEFS = {
		[1] = {
			label = "V1",
			accessory = 10159600649,
			offset = Vector3.new(0, 1, -0.2),
			shirt = "http://www.roblox.com/asset/?id=9683332638",
			pants = "http://www.roblox.com/asset/?id=93182020184041",
			headMesh = "http://www.roblox.com/asset/?id=134079402",
			headTexture = "http://www.roblox.com/asset/?id=133940918",
			headlessKorblox = true,
			preview = 10159600649,
		},
		[2] = {
			label = "V2",
			accessory = 1744060292,
			offset = Vector3.new(0, 1.3, -0.2),
			shirt = "http://www.roblox.com/asset/?id=9683332638",
			pants = "http://www.roblox.com/asset/?id=93182020184041",
			headMesh = "http://www.roblox.com/asset/?id=134079402",
			headTexture = "http://www.roblox.com/asset/?id=133940918",
			headlessKorblox = true,
			preview = 1744060292,
		},
	}

	local TAG = "070AV_"
	local hiddenStore = {} -- [char] = { {inst, prop, val}, ... }
	local applying = false

	local function loadObjects(id)
		id = tonumber(id)
		if not id then return nil end
		local ok, res = pcall(function()
			return game:GetObjects("rbxassetid://" .. tostring(id))
		end)
		if ok and type(res) == "table" and #res > 0 then return res end
		ok, res = pcall(function()
			return InsertService:LoadAsset(id)
		end)
		if ok and res then
			if typeof(res) == "Instance" then return { res } end
			if type(res) == "table" then return res end
		end
		return nil
	end

	local function stash(char, inst, prop, val)
		hiddenStore[char] = hiddenStore[char] or {}
		table.insert(hiddenStore[char], { inst, prop, val })
	end

	local function hideOriginalAccessories(char)
		if not char then return end
		for _, d in ipairs(char:GetChildren()) do
			if d:IsA("Accessory") or d:IsA("Hat") then
				-- destroy local visual (client-only effect via LocalTransparency on handle)
				local handle = d:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					stash(char, handle, "LocalTransparencyModifier", handle.LocalTransparencyModifier)
					stash(char, handle, "Transparency", handle.Transparency)
					pcall(function()
						handle.LocalTransparencyModifier = 1
						handle.Transparency = 1
					end)
					for _, c in ipairs(handle:GetDescendants()) do
						if c:IsA("Decal") or c:IsA("Texture") then
							stash(char, c, "Transparency", c.Transparency)
							pcall(function() c.Transparency = 1 end)
						elseif c:IsA("BasePart") then
							stash(char, c, "LocalTransparencyModifier", c.LocalTransparencyModifier)
							pcall(function() c.LocalTransparencyModifier = 1 c.Transparency = 1 end)
						end
					end
				end
				pcall(function()
					d:SetAttribute(TAG .. "Hidden", true)
				end)
			end
		end
		-- hide body layers that fight the outfit
		for _, n in ipairs({"ShirtGraphic", "BodyColors"}) do
			local o = char:FindFirstChild(n)
			if o and o:IsA("ShirtGraphic") then
				stash(char, o, "Graphic", o.Graphic)
				pcall(function() o.Graphic = "" end)
			end
		end
	end

	local function clearCustomPieces(char)
		if not char then return end
		for _, d in ipairs(char:GetChildren()) do
			if typeof(d.Name) == "string" then
				if d.Name:sub(1, #TAG) == TAG
					or d.Name == "AuFfitAccessory"
					or d.Name == "Korblox_RightLeg"
					or d.Name == "070LocalAvatar_Acc" then
					pcall(function() d:Destroy() end)
				end
			end
		end
	end

	local function restoreOriginal(char)
		if not char then return end
		clearCustomPieces(char)
		local list = hiddenStore[char]
		if list then
			for _, e in ipairs(list) do
				local inst, prop, val = e[1], e[2], e[3]
				pcall(function()
					if inst and inst.Parent then
						inst[prop] = val
					end
				end)
			end
			hiddenStore[char] = nil
		end
		-- head restore
		local head = char:FindFirstChild("Head")
		if head then
			pcall(function()
				head.Transparency = 0
				head.LocalTransparencyModifier = 0
			end)
			for _, d in ipairs(head:GetChildren()) do
				if d:IsA("Decal") or d:IsA("Texture") then
					pcall(function() d.Transparency = 0 end)
				end
			end
		end
		for _, n in ipairs({"RightUpperLeg","RightLowerLeg","RightFoot","Right Leg","LeftUpperLeg","LeftLowerLeg","LeftFoot","Left Leg"}) do
			local p = char:FindFirstChild(n)
			if p and p:IsA("BasePart") then
				pcall(function()
					p.Transparency = 0
					p.LocalTransparencyModifier = 0
				end)
			end
		end
	end

	local function applyHeadlessKorblox(char)
		local head = char:FindFirstChild("Head")
		if head then
			pcall(function()
				head.Transparency = 1
				head.LocalTransparencyModifier = 1
			end)
			for _, d in ipairs(head:GetChildren()) do
				if d:IsA("Decal") or d:IsA("Texture") then
					pcall(function() d.Transparency = 1 end)
				end
			end
			if not head:IsA("MeshPart") then
				local sm = head:FindFirstChildOfClass("SpecialMesh")
				if not sm then
					sm = Instance.new("SpecialMesh")
					sm.Name = TAG .. "HeadMesh"
					sm.Parent = head
				end
				pcall(function()
					sm.MeshId = "http://www.roblox.com/asset/?id=134079402"
					sm.TextureId = "http://www.roblox.com/asset/?id=133940918"
					sm.Scale = Vector3.new(1.25, 1.25, 1.25)
				end)
			end
		end
		for _, n in ipairs({"RightUpperLeg","RightLowerLeg","RightFoot","Right Leg"}) do
			local p = char:FindFirstChild(n)
			if p and p:IsA("BasePart") then
				pcall(function()
					p.Transparency = 1
					p.LocalTransparencyModifier = 1
				end)
			end
		end
		-- korblox leg mesh local
		pcall(function()
			local objs = loadObjects(139607718)
			if not objs then return end
			local handle
			for _, o in ipairs(objs) do
				if o:IsA("BasePart") then handle = o break end
				local f = o:FindFirstChildWhichIsA("BasePart", true)
				if f then handle = f break end
			end
			local rleg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("HumanoidRootPart")
			if handle and rleg then
				local h = handle:Clone()
				h.Name = "Korblox_RightLeg"
				h.CanCollide = false
				h.Massless = true
				h.Anchored = false
				h.Parent = char
				local w = Instance.new("Weld")
				w.Part0 = rleg
				w.Part1 = h
				w.C0 = CFrame.new()
				w.Parent = h
			end
			for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
		end)
	end

	local function applyOutfit(option, char)
		if not option or not char then return false end
		-- 1) wipe previous custom pieces
		clearCustomPieces(char)
		-- 2) hide real accessories / layers
		hideOriginalAccessories(char)
		local head = char:FindFirstChild("Head")
		-- 3) shirt / pants
		if option.shirt then
			local s = char:FindFirstChildWhichIsA("Shirt")
			if not s then
				s = Instance.new("Shirt")
				s.Name = TAG .. "Shirt"
				s.Parent = char
			else
				stash(char, s, "ShirtTemplate", s.ShirtTemplate)
			end
			s.ShirtTemplate = option.shirt
		end
		if option.pants then
			local p = char:FindFirstChildWhichIsA("Pants")
			if not p then
				p = Instance.new("Pants")
				p.Name = TAG .. "Pants"
				p.Parent = char
			else
				stash(char, p, "PantsTemplate", p.PantsTemplate)
			end
			p.PantsTemplate = option.pants
		end
		-- 4) main accessory
		if option.accessory and head then
			local objs = loadObjects(option.accessory)
			if objs then
				local placed = false
				for _, o in ipairs(objs) do
					if o:IsA("Accessory") then
						local acc = o:Clone()
						acc.Name = TAG .. "Acc"
						pcall(function() acc.Parent = char end)
						placed = true
					end
				end
				if not placed then
					local handle
					for _, o in ipairs(objs) do
						if o:IsA("BasePart") then handle = o break end
						local f = o:FindFirstChildWhichIsA("BasePart", true)
						if f then handle = f break end
						local hh = o:FindFirstChild("Handle", true)
						if hh and hh:IsA("BasePart") then handle = hh break end
					end
					if handle then
						local h = handle:Clone()
						h.Name = "AuFfitAccessory"
						h.CanCollide = false
						h.Massless = true
						h.Anchored = false
						h.Parent = char
						local weld = Instance.new("Weld")
						weld.Part0 = head
						weld.Part1 = h
						weld.C0 = CFrame.new(option.offset or Vector3.zero)
						weld.Parent = h
					end
				end
				for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
			end
		end
		-- 5) headless + korblox
		if option.headlessKorblox then
			applyHeadlessKorblox(char)
		end
		return true
	end

	local function applyAvatarByIndex(index, char)
		index = math.clamp(tonumber(index) or 1, 1, 2)
		local option = AVATAR_DEFS[index]
		if not option then return false end
		char = char or LP.Character
		if not char then return false end
		if applying then return false end
		applying = true
		local ok = false
		pcall(function()
			char:WaitForChild("Head", 6)
			char:WaitForChild("HumanoidRootPart", 5)
			for _ = 1, 3 do
				if applyOutfit(option, char) then
					ok = true
					break
				end
				task.wait(0.12)
			end
		end)
		applying = false
		getgenv()._070AvatarIndex = index
		return ok
	end

	local function clearAvatar()
		local char = LP.Character
		if char then
			restoreOriginal(char)
		end
		getgenv()._070AvatarIndex = 0
	end

	getgenv()._070ApplyAvatarIndex = applyAvatarByIndex
	getgenv()._070ClearAvatar = clearAvatar
	getgenv()._070AvatarDefs = AVATAR_DEFS

	LP.CharacterAdded:Connect(function(char)
		local idx = tonumber(getgenv()._070AvatarIndex) or 0
		if idx >= 1 then
			task.delay(1.0, function()
				if tonumber(getgenv()._070AvatarIndex) == idx then
					applyAvatarByIndex(idx, char)
				end
			end)
			task.delay(2.2, function()
				if tonumber(getgenv()._070AvatarIndex) == idx then
					applyAvatarByIndex(idx, char)
				end
			end)
		end
	end)
end





	-- after applying skins, refresh sidebar face to real current look
	local _oldApply = getgenv()._070ApplySkin
	pcall(function()
		if type(getgenv()._070ApplySkin) == "function" then
			local orig = getgenv()._070ApplySkin
			getgenv()._070ApplySkin = function(...)
				local r = orig(...)
				task.delay(0.4, function()
					if getgenv()._070ReloadAvatar then pcall(getgenv()._070ReloadAvatar) end
				end)
				return r
			end
		end
	end)
	do end -- muted
end

-- =====================================================================

-- =====================================================================

-- =====================================================================

-- =====================================================================
-- =====================================================================
-- 070 Steal Bar — solid black rework, no glow, NEVER auto-destroyed
-- =====================================================================
do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local CoreGui = game:GetService("CoreGui")
	local UserInputService = game:GetService("UserInputService")
	local LP = Players.LocalPlayer

	local PURPLE = Color3.fromRGB(90, 130, 255)
	local PURPLE_BRIGHT = Color3.fromRGB(90, 130, 255)
	local PURPLE_DIM = Color3.fromRGB(50, 50, 58)
	local BLACK = Color3.fromRGB(0, 0, 0)

	local function wipeOthersOnly()
		-- FPS: only named FindFirstChild — never CoreGui:GetDescendants
		for _, root in ipairs({ CoreGui, LP:FindFirstChild("PlayerGui") }) do
			if not root then continue end
			for _, n in ipairs({"MoveeStealBar", "StealProgressScreenGui", "070StealBar"}) do
				local c = root:FindFirstChild(n)
				if c then pcall(function() c:Destroy() end) end
			end
		end
	end

	local guiRef = nil
	local setProgressRef = nil

	local function buildBar()
		-- if already alive, keep it
		if guiRef and guiRef.Parent then
			return
		end
		-- remove only OUR previous dead ref
		pcall(function()
			for _, root in ipairs({ CoreGui, LP:FindFirstChild("PlayerGui") }) do
				if root then
					local old = root:FindFirstChild("MiroStealBar")
					if old then old:Destroy() end
				end
			end
		end)

		local gui = Instance.new("ScreenGui")
		gui.Name = "MiroStealBar"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 2147483646
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		pcall(function() gui.Parent = CoreGui end)
		if not gui.Parent then
			gui.Parent = LP:WaitForChild("PlayerGui")
		end
		guiRef = gui
		getgenv()._070StealBarGui = gui
		if _G._070HideStealBarUI == true then
			pcall(function() gui.Enabled = false end)
		end

		local frame = Instance.new("Frame")
		frame.Name = "StealProgressGui"
		frame.Size = UDim2.fromOffset(340, 58)
		frame.Position = UDim2.new(0.5, -170, 1, -128)
		local barScale = Instance.new("UIScale")
		barScale.Name = "StealBarUIScale"
		barScale.Scale = math.clamp((tonumber(stealBarScaleValue) or 100) / 100, 0.5, 2)
		barScale.Parent = frame
		getgenv()._070ApplyStealBarScale = function(pct)
			stealBarScaleValue = math.clamp(math.floor((tonumber(pct) or 100) + 0.5), 50, 200)
			if barScale and barScale.Parent then
				barScale.Scale = stealBarScaleValue / 100
			end
			pcall(function()
				local g = guiRef
				if g then
					local f = g:FindFirstChild("StealProgressGui")
					local s = f and f:FindFirstChild("StealBarUIScale")
					if s then s.Scale = stealBarScaleValue / 100 end
				end
			end)
		end
		-- solid black reworked shell
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 0
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.ClipsDescendants = true
		frame.Visible = true
		frame.ZIndex = 300
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(45, 45, 52)
		stroke.Thickness = 1
		stroke.Transparency = 0.25
		stroke.Parent = frame

		-- top row: STEAL | FPS | PING
		local statusLbl = Instance.new("TextLabel")
		statusLbl.Name = "StealStatus"
		statusLbl.Size = UDim2.fromOffset(56, 18)
		statusLbl.Position = UDim2.fromOffset(14, 8)
		statusLbl.BackgroundTransparency = 1
		statusLbl.Text = "STEAL"
		statusLbl.TextColor3 = Color3.fromRGB(230, 230, 235)
		statusLbl.Font = Enum.Font.GothamBlack
		statusLbl.TextSize = 12
		statusLbl.TextXAlignment = Enum.TextXAlignment.Left
		statusLbl.ZIndex = 305
		statusLbl.Parent = frame

		local pctLbl = Instance.new("TextLabel")
		pctLbl.Name = "StealPct"
		pctLbl.Size = UDim2.fromOffset(48, 18)
		pctLbl.Position = UDim2.new(1, -60, 0, 8)
		pctLbl.BackgroundTransparency = 1
		pctLbl.Text = "0%"
		pctLbl.TextColor3 = Color3.fromRGB(160, 160, 170)
		pctLbl.Font = Enum.Font.GothamBold
		pctLbl.TextSize = 11
		pctLbl.TextXAlignment = Enum.TextXAlignment.Right
		pctLbl.Visible = true
		pctLbl.ZIndex = 305
		pctLbl.Parent = frame

		local fpsTag = Instance.new("TextLabel")
		fpsTag.Size = UDim2.fromOffset(26, 14)
		fpsTag.Position = UDim2.fromOffset(78, 10)
		fpsTag.BackgroundTransparency = 1
		fpsTag.Text = "FPS"
		fpsTag.TextColor3 = Color3.fromRGB(110, 110, 120)
		fpsTag.Font = Enum.Font.GothamBold
		fpsTag.TextSize = 9
		fpsTag.ZIndex = 305
		fpsTag.Parent = frame

		local fpsVal = Instance.new("TextLabel")
		fpsVal.Size = UDim2.fromOffset(36, 16)
		fpsVal.Position = UDim2.fromOffset(104, 9)
		fpsVal.BackgroundTransparency = 1
		fpsVal.Text = "--"
		fpsVal.TextColor3 = Color3.fromRGB(255, 255, 255)
		fpsVal.Font = Enum.Font.GothamMedium
		fpsVal.TextSize = 12
		fpsVal.ZIndex = 305
		fpsVal.Parent = frame

		local pingTag = Instance.new("TextLabel")
		pingTag.Size = UDim2.fromOffset(30, 14)
		pingTag.Position = UDim2.fromOffset(150, 10)
		pingTag.BackgroundTransparency = 1
		pingTag.Text = "PING"
		pingTag.TextColor3 = Color3.fromRGB(110, 110, 120)
		pingTag.Font = Enum.Font.GothamBold
		pingTag.TextSize = 9
		pingTag.ZIndex = 305
		pingTag.Parent = frame

		local pingVal = Instance.new("TextLabel")
		pingVal.Size = UDim2.fromOffset(40, 16)
		pingVal.Position = UDim2.fromOffset(180, 9)
		pingVal.BackgroundTransparency = 1
		pingVal.Text = "--"
		pingVal.TextColor3 = Color3.fromRGB(255, 255, 255)
		pingVal.Font = Enum.Font.GothamMedium
		pingVal.TextSize = 12
		pingVal.ZIndex = 305
		pingVal.Parent = frame

		-- progress track
		local track = Instance.new("Frame")
		track.Name = "StealTrack"
		track.Size = UDim2.new(1, -28, 0, 10)
		track.Position = UDim2.new(0, 14, 1, -20)
		track.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		track.BackgroundTransparency = 0
		track.BorderSizePixel = 0
		track.ClipsDescendants = true
		track.ZIndex = 302
		track.Parent = frame
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

				local fill = Instance.new("Frame")
		fill.Name = "StealFill"
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
		fill.BorderSizePixel = 0
		fill.ClipsDescendants = true
		fill.ZIndex = 303
		fill.Parent = track
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, PURPLE_DIM),
			ColorSequenceKeypoint.new(0.4, PURPLE),
			ColorSequenceKeypoint.new(0.7, PURPLE_BRIGHT),
			ColorSequenceKeypoint.new(1, PURPLE_DIM),
		})
		grad.Rotation = -8
		grad.Parent = fill

		local gloss = Instance.new("Frame")
		gloss.Size = UDim2.new(1, 0, 0.4, 0)
		gloss.BackgroundColor3 = Color3.new(1, 1, 1)
		gloss.BackgroundTransparency = 0.78
		gloss.BorderSizePixel = 0
		gloss.ZIndex = 304
		gloss.Parent = fill
		Instance.new("UICorner", gloss).CornerRadius = UDim.new(1, 0)

		task.spawn(function()
			while fill and fill.Parent do
				local tw = TweenService:Create(grad, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(0.5, 0) })
				tw:Play()
				tw.Completed:Wait()
				if not fill.Parent then break end
				tw = TweenService:Create(grad, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(-0.5, 0) })
				tw:Play()
				tw.Completed:Wait()
			end
		end)

		local frames, lastT = 0, tick()
		local function updateFpsPing()
			if not gui or not gui.Parent then return end
			if not fpsVal or not fpsVal.Parent then return end
			local now = tick()
			local dt = now - lastT
			if dt >= 0.4 then
				local fps = frames / math.max(dt, 0.001)
				fpsVal.Text = tostring(math.clamp(math.floor(fps + 0.5), 0, 999))
				frames = 0
				lastT = now
				local ping = 0
				pcall(function()
					ping = math.floor((LP:GetNetworkPing() or 0) * 1000 + 0.5)
				end)
				if ping <= 0 then
					pcall(function()
						local st = game:GetService("Stats")
						local net = st and st:FindFirstChild("Network")
						local item = net and (net:FindFirstChild("ServerStatsItem") or net:FindFirstChild("ServerStats"))
						if item then
							local pingItem = item:FindFirstChild("Data Ping") or item:FindFirstChild("Ping")
							if pingItem and pingItem.GetValue then
								ping = math.floor(pingItem:GetValue() + 0.5)
							end
						end
					end)
				end
				if pingVal and pingVal.Parent then
					pingVal.Text = tostring(math.max(0, ping))
				end
			end
		end
		RunService.Heartbeat:Connect(function()
			frames += 1
		end)
		task.spawn(function()
			while gui and gui.Parent do
				task.wait(1)
				updateFpsPing()
			end
		end)

		local glowOn, glowToken = false, 0
		local shadeLayer = frame:FindFirstChild("StealBarBgShade")
		local function accentCols()
			local a = getgenv()._070AccentColor or primaryColor or Color3.fromRGB(140, 100, 255)
			local b = getgenv()._070AccentColor2 or secondaryColor or Color3.fromRGB(70, 140, 255)
			local c = getgenv()._070AccentColor3 or tertiaryColor or Color3.fromRGB(180, 170, 255)
			return a, b, c
		end
		getgenv()._070RefreshStealBarAccent = function()
			local a, b, c = accentCols()
			if fill then fill.BackgroundColor3 = a end
			if grad then
				pcall(function()
					grad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, b),
						ColorSequenceKeypoint.new(0.5, a),
						ColorSequenceKeypoint.new(1, c),
					})
				end)
			end
		end
		local function startGlow()
			-- glow removed
		end
		local function stopGlow()
			-- glow removed
			glowOn = false
		end

		function setProgress(p)
			if not fill or not fill.Parent then return end
			p = tonumber(p) or 0
			if p > 1 then p = p / 100 end
			p = math.clamp(p, 0, 1)
			TweenService:Create(fill, TweenInfo.new(0.08), { Size = UDim2.new(p, 0, 1, 0) }):Play()
			if pctLbl then
				pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
				pctLbl.Visible = true
			end
			pcall(function() stopGlow() end)
			if statusLbl then
				statusLbl.TextColor3 = p > 0.01 and Color3.fromRGB(90, 130, 255) or Color3.fromRGB(230, 230, 235)
			end
			fill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
		end
		setProgressRef = setProgress

		_G.StealBar = {
			SetProgress = setProgress,
			SetState = function(s)
				if tostring(s or ""):upper():find("STEAL") then
					statusLbl.Text = "STEAL"
				end
			end,
			Reset = function() setProgress(0) end,
		}
		getgenv()._070SetStealBar = function(pct)
			setProgress((pct or 0) / 100)
		end

		-- drag
		local dragging, dragStart, startPos
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)

		do end -- muted
	end

	-- build once, then guardian keeps it alive forever
	task.defer(function()
		task.wait(0.3)
		wipeOthersOnly()
		buildBar()

		-- hook progress
		task.spawn(function()
			for _ = 1, 150 do
				task.wait(0.1)
				if type(featureHelperG) == "function" then
					local old = featureHelperG
					featureHelperG = function(v)
						old(v)
						if setProgressRef then
							setProgressRef(math.clamp(tonumber(v) or 0, 0, 1))
						elseif _G.StealBar and _G.StealBar.SetProgress then
							_G.StealBar.SetProgress(math.clamp(tonumber(v) or 0, 0, 1))
						end
					end
					do end -- muted
					break
				end
			end
		end)

		-- guardian: if something deletes the bar, recreate it
		task.spawn(function()
			while true do
				task.wait(8)
				pcall(wipeOthersOnly)
				if not guiRef or not guiRef.Parent then
					buildBar()
				end
			end
		end)
	end)
end


-- apply saved bg on boot (do not wipe saved accent/bg)
pcall(function()
	getgenv()._070DefaultBgAsset = getgenv()._070DefaultBgAsset or "119161957039576"
	task.defer(function()
		task.wait(1.2)
		local id = getgenv()._070CurrentBgAsset or getgenv()._070DefaultBgAsset or "119161957039576"
		if getgenv()._070ApplyUiBackground then
			getgenv()._070ApplyUiBackground(tostring(id))
		end
		local r = tonumber(getgenv()._070AccentR or uiAccentR) or 140
		local g = tonumber(getgenv()._070AccentG or uiAccentG) or 100
		local b = tonumber(getgenv()._070AccentB or uiAccentB) or 255
		if getgenv()._070ApplyUiAccent then
			getgenv()._070ApplyUiAccent(r, g, b)
		end
	end)
end)



-- =====================================================================
-- Purple Halo (Visual)
-- =====================================================================
do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LP = Players.LocalPlayer

	local haloPart, haloConn
	_G._070Halo = _G._070Halo == true

	local function clearHalo()
		if haloConn then pcall(function() haloConn:Disconnect() end) haloConn = nil end
		if haloPart then pcall(function() haloPart:Destroy() end) haloPart = nil end
		local char = LP.Character
		if char then
			for _, d in ipairs(char:GetChildren()) do
				if d.Name == "070PurpleHalo"
					or d.Name == "070HaloGlow"
					or d.Name == "HaloSeg"
					or d.Name == "HaloGlowSeg" then
					pcall(function() d:Destroy() end)
				end
			end
		end
	end

	local function attachHalo(char)
		clearHalo()
		if not _G._070Halo then return end
		char = char or LP.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end

		local anchor = Instance.new("Part")
		anchor.Name = "070PurpleHalo"
		anchor.Size = Vector3.new(0.15, 0.15, 0.15)
		anchor.Transparency = 1
		anchor.CanCollide = false
		anchor.CanTouch = false
		anchor.CanQuery = false
		anchor.Massless = true
		anchor.CastShadow = false
		anchor.Parent = char
		haloPart = anchor

		local weld = Instance.new("Weld")
		weld.Part0 = head
		weld.Part1 = anchor
		weld.C0 = CFrame.new(0, 1.45, 0)
		weld.Parent = anchor

		local PURPLE = Color3.fromRGB(
			tonumber(_G._070HaloR) or 190,
			tonumber(_G._070HaloG) or 110,
			tonumber(_G._070HaloB) or 255
		)
		local radius = 1.15
		local segments = 36
		local tube = 0.1 -- ring thickness

		local function addRing(rad, y, sizeY, sizeZ, color, transparency, name)
			for i = 1, segments do
				local mid = ((i - 0.5) / segments) * math.pi * 2
				local arc = (1 / segments) * math.pi * 2
				local chord = 2 * rad * math.sin(arc * 0.5) * 1.12

				local seg = Instance.new("Part")
				seg.Name = name
				seg.Shape = Enum.PartType.Block
				seg.Size = Vector3.new(chord, sizeY, sizeZ)
				seg.Material = Enum.Material.Neon
				seg.Color = color
				seg.Transparency = transparency
				seg.CanCollide = false
				seg.CanTouch = false
				seg.CanQuery = false
				seg.Massless = true
				seg.CastShadow = false
				seg.Parent = char

				-- X axis = tangent so segments form a smooth circle
				local pos = Vector3.new(math.cos(mid) * rad, y, math.sin(mid) * rad)
				local right = Vector3.new(-math.sin(mid), 0, math.cos(mid))
				local up = Vector3.yAxis
				local look = right:Cross(up).Unit
				local cf = CFrame.fromMatrix(pos, right, up, look)

				local sw = Instance.new("Weld")
				sw.Part0 = anchor
				sw.Part1 = seg
				sw.C0 = cf
				sw.Parent = seg
			end
		end

		-- main bright ring
		addRing(radius, 0, tube, tube, PURPLE, 0, "HaloSeg")
		-- soft outer glow ring
		local glowCol = PURPLE:Lerp(Color3.new(0, 0, 0), 0.25)
		addRing(radius + 0.06, 0, tube * 0.7, tube * 1.6, glowCol, 0.5, "HaloGlowSeg")

		local light = Instance.new("PointLight")
		light.Name = "HaloGlow"
		light.Color = PURPLE
		light.Brightness = 3.2
		light.Range = 9
		light.Parent = anchor

		local t0 = tick()
		haloConn = RunService.RenderStepped:Connect(function()
			if not anchor.Parent or not _G._070Halo then
				clearHalo()
				return
			end
			local pulse = (math.sin((tick() - t0) * 2.4) + 1) * 0.5
			if light and light.Parent then
				light.Brightness = 2.4 + pulse * 1.8
			end
			local base = Color3.fromRGB(
				tonumber(_G._070HaloR) or 190,
				tonumber(_G._070HaloG) or 110,
				tonumber(_G._070HaloB) or 255
			)
			local col = base:Lerp(Color3.new(1, 1, 1), pulse * 0.25)
			for _, d in ipairs(char:GetChildren()) do
				if d.Name == "HaloSeg" and d:IsA("BasePart") then
					d.Color = col
				elseif d.Name == "HaloGlowSeg" and d:IsA("BasePart") then
					d.Transparency = 0.45 + pulse * 0.2
				end
			end
		end)
	end

local function setHalo(on)
		_G._070Halo = on == true
		if _G._070Halo then
			attachHalo(LP.Character)
		else
			clearHalo()
		end
		pcall(function()
			if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
		end)
	end

	local function setHaloColor(r, g, b)
		if typeof(r) == "Color3" then
			_G._070HaloR = math.floor(r.R * 255 + 0.5)
			_G._070HaloG = math.floor(r.G * 255 + 0.5)
			_G._070HaloB = math.floor(r.B * 255 + 0.5)
		elseif type(r) == "number" then
			_G._070HaloR = math.clamp(math.floor(r), 0, 255)
			_G._070HaloG = math.clamp(math.floor(g or 110), 0, 255)
			_G._070HaloB = math.clamp(math.floor(b or 255), 0, 255)
		end
		-- rebuild if on
		if _G._070Halo then
			attachHalo(LP.Character)
		end
		pcall(function()
			local p = getgenv()._070Persist or _G._070Persist
			if type(p) ~= "table" then p = {}; getgenv()._070Persist = p; _G._070Persist = p end
			p.haloColorR = _G._070HaloR
			p.haloColorG = _G._070HaloG
			p.haloColorB = _G._070HaloB
			if getgenv()._070SaveAll then getgenv()._070SaveAll(true) end
		end)
		return true
	end

	getgenv()._070SetHalo = setHalo
	getgenv()._070SetHaloColor = setHaloColor
	getgenv()._070GetHalo = function() return _G._070Halo == true end
	getgenv()._070GetHaloColor = function()
		return Color3.fromRGB(
			tonumber(_G._070HaloR) or 190,
			tonumber(_G._070HaloG) or 110,
			tonumber(_G._070HaloB) or 255
		)
	end

	LP.CharacterAdded:Connect(function(char)
		task.wait(0.4)
		if _G._070Halo then attachHalo(char) end
	end)

	-- restore from save
	task.defer(function()
		task.wait(1)
		local want = false
		pcall(function()
			local p = getgenv()._070Persist or _G._070Persist
			if type(p) == "table" and p.halo == true then want = true end
		end)
		if want or _G._070Halo == true then
			setHalo(true)
		end
	end)
end





-- force ESP tracers — FPS: only paint known espObjects refs (no CoreGui:GetDescendants)
task.spawn(function()
	local PURPLE = Color3.fromRGB(185, 100, 255)
	local GREEN = Color3.fromRGB(40, 180, 70)
	local RED = Color3.fromRGB(220, 40, 40)
	while true do
		task.wait(2.5) -- was 0.4
		if type(espObjects) ~= "table" then continue end
		local col = PURPLE
		local speedCol = PURPLE
		pcall(function()
			for _, data in pairs(espObjects) do
				if type(data) == "table" then
					if data.tracer and data.tracer.Parent then
						data.tracer.BackgroundColor3 = col
						pcall(function() data.tracer.BorderColor3 = col end)
					end
					if data.boxStroke and data.boxStroke.Parent then
						data.boxStroke.Color = col
						data.boxStroke.Transparency = 0
					end
					if data.box and data.box.Parent then
						data.box.BackgroundTransparency = 1
						local st = data.boxStroke or data.box:FindFirstChildOfClass("UIStroke")
						if st then st.Color = col; st.Transparency = 0 end
					end
					if data.speedLbl and data.speedLbl.Parent then
						data.speedLbl.TextColor3 = speedCol
					end
				end
			end
		end)
	end
end)

-- force Speed text — FPS: only update known labels, no CoreGui:GetDescendants
task.spawn(function()
	local PURPLE = Color3.fromRGB(185, 100, 255)
	local SEQ_P = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 80, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 100, 255)),
	})
	while true do
		task.wait(2.5)
		pcall(function()
			if speedLabel and speedLabel.Parent then
				speedLabel.TextColor3 = PURPLE
				local grad = speedLabel:FindFirstChild("070SpeedGrad")
				if grad and grad:IsA("UIGradient") then grad.Color = SEQ_P end
			end
			if type(espObjects) == "table" then
				for _, data in pairs(espObjects) do
					if type(data) == "table" and data.speedLbl and data.speedLbl.Parent then
						data.speedLbl.TextColor3 = PURPLE
					end
				end
			end
		end)
	end
end)

-- force 070Hub title — FPS: disabled CoreGui scan; title set once at build
-- (active tab color is handled by UI click handlers)
task.spawn(function()
	while true do
		task.wait(30) -- noop keep-alive, was scanning CoreGui every 0.6s
		task.wait(0)
	end
end)

_G._070Christmas = false
getgenv()._070SetChristmas = function() end
getgenv()._070GetChristmas = function() return false end

-- Auto Steal UI hide (persists)
getgenv()._070SetStealBarHidden = function(hidden)
	_G._070HideStealBarUI = hidden == true
	local show = not _G._070HideStealBarUI
	pcall(function()
		local function apply(root)
			if not root then return end
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("ScreenGui") then
					local n = string.lower(tostring(d.Name or ""))
					if n:find("steal") or n:find("progress") then
						-- only our steal progress bar
						if d:FindFirstChild("StealProgressGui", true) or d.Name == "StealProgressGui" or n:find("stealprogress") or n:find("070") then
							d.Enabled = show
						end
					end
				end
				if d:IsA("Frame") and d.Name == "StealProgressGui" then
					d.Visible = show
					local sg = d:FindFirstAncestorOfClass("ScreenGui")
					if sg then sg.Enabled = show end
				end
			end
		end
		apply(game:GetService("CoreGui"))
		local lp = game:GetService("Players").LocalPlayer
		if lp then apply(lp:FindFirstChild("PlayerGui")) end
		pcall(function() if gethui then apply(gethui()) end end)
		-- direct ref if hub set one
		if getgenv()._070StealBarGui then
			local g = getgenv()._070StealBarGui
			if typeof(g) == "Instance" then
				if g:IsA("ScreenGui") then g.Enabled = show end
				if g:IsA("GuiObject") then g.Visible = show end
			end
		end
	end)
	pcall(function()
		if getgenv()._070SaveAll then getgenv()._070SaveAll() end
	end)
end

-- re-apply hide only when needed (FPS: was every 1.5s + full GetDescendants)
task.spawn(function()
	while true do
		task.wait(8)
		pcall(function()
			if _G._070HideStealBarUI == true and getgenv()._070StealBarGui then
				local g = getgenv()._070StealBarGui
				if typeof(g) == "Instance" then
					if g:IsA("ScreenGui") then g.Enabled = false end
					if g:IsA("GuiObject") then g.Visible = false end
				end
			end
		end)
	end
end)




-- removed features stubs
getgenv()._070ToggleEmotesPanel = function() end
getgenv()._070ApplyAvatarIndex = function() end
getgenv()._070ClearAvatar = function() end
getgenv()._070AvatarIndex = 0
