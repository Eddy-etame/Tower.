-- The Watcher — CLIENT BRAIN. Builds the visible body locally, follows the server's invisible LogicRoot (smooth
-- at render rate over its 10Hz replication), and layers procedural life on top. Reads server state ONE-WAY
-- (LogicRoot.CFrame + WatcherState/Boldness/Snap attributes); it NEVER writes back, so nothing here can cheat
-- the freeze/catch — those measure the server LogicRoot alone.
--
-- The life TEACHES the locked rule wordlessly: it breathes/sways and its head tracks YOU while it is alive, then
-- snaps taut-dead-still the instant you light it (weeping-angel). That stillness is the visual twin of the move
-- sound cutting out — the fair tell for the ~70% on muted phone speakers. On the frozen->waking edge the head
-- snaps to lock onto you (silent, a look not a bang); the grace window leans it forward; the surge coils then
-- lunges. All amplitudes are sub-perceptual until spent in a beat (restraint — over-juice kills the uncertainty).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local WatcherRig = require(ReplicatedStorage.Shared.WatcherRig)

local TAG = "WatcherLogicRoot"
local NECK_PIVOT = CFrame.new(0, 7, -0.4) -- must match WatcherRig; used to aim the gaze from the head's base

local M -- the single active mount, or nil

-- a semi-implicit damped spring: ratio 1 ~ critical, <1 gives a little organic overshoot (a living correction)
local function spring(x, v, target, k, ratio, dt)
	local c = 2 * math.sqrt(k) * ratio
	v = v + (-k * (x - target) - c * v) * dt
	x = x + v * dt
	return x, v
end

local function unmount()
	if not M then
		return
	end
	if M.conn then
		M.conn:Disconnect()
	end
	WatcherRig.destroy(M.rig)
	M = nil
end

local function step(dt)
	if not M then
		return
	end
	local logicRoot = M.logicRoot
	if not logicRoot or not logicRoot.Parent then
		unmount()
		return
	end
	local cam = workspace.CurrentCamera
	local targetCF = logicRoot.CFrame

	-- hard-snap on the reset token (teleport to spawn) so the body never slides across the whole room
	local snap = logicRoot:GetAttribute("Snap") or 0
	if snap ~= M.snapToken then
		M.snapToken = snap
		M.renderCF = targetCF
	end

	-- frame-rate-independent follow, with a clamp-snap so the visual never lags the true hitbox by more than a
	-- stud (catch fairness: what you SEE stays what the server MEASURES)
	M.renderCF = M.renderCF:Lerp(targetCF, 1 - math.exp(-tuning.WATCHER_FOLLOW_K * dt))
	if (M.renderCF.Position - targetCF.Position).Magnitude > tuning.WATCHER_SNAP_CLAMP then
		M.renderCF = targetCF
	end
	local renderCF = M.renderCF

	-- cull the articulation when far / off-screen (mobile frame budget); the body just holds its last pose
	if cam and (renderCF.Position - cam.CFrame.Position).Magnitude > tuning.WATCHER_CULL_DIST then
		return
	end

	M.t += dt
	local state = logicRoot:GetAttribute("WatcherState") or "idle"
	local boldness = logicRoot:GetAttribute("Boldness") or 0

	-- transitions: the notice beat fires when it wakes (frozen -> anything moving) because you looked away
	if state ~= M.prevState then
		if M.prevState == "frozen" and state ~= "idle" then
			M.noticeT = tuning.WATCHER_NOTICE_SECS
			M.eyePulse = 1
		end
		if state == "surge" then
			M.surgeT = 0
		end
		M.prevState = state
	end
	if state == "surge" then
		M.surgeT += dt
	end

	-- aliveness envelope: life damps to 0 the instant it is lit (taut stillness), ramps back as it advances
	local aliveTarget = (state == "frozen") and 0 or 1
	local rampT = (aliveTarget > M.alive) and tuning.WATCHER_ALIVE_RAMP or tuning.WATCHER_FREEZE_DAMP
	M.alive += (aliveTarget - M.alive) * (1 - math.exp(-dt / math.max(rampT, 0.01)))

	-- breath + incommensurate sway, scaled by life (and a touch by boldness as it restores power)
	local bold = 1 + math.clamp(boldness, 0, 3) * 0.12
	local breath = math.sin(M.t * 2 * math.pi * tuning.WATCHER_BREATH_HZ)
	local breathRise = breath * tuning.WATCHER_BREATH_RISE * M.alive * bold
	local breathPitch = breath * tuning.WATCHER_BREATH_PITCH * M.alive
	local swayPitch = math.sin(M.t * 2 * math.pi * tuning.WATCHER_SWAY_A) * tuning.WATCHER_SWAY_PITCH * M.alive * bold
	local swayRoll = math.sin(M.t * 2 * math.pi * tuning.WATCHER_SWAY_B) * tuning.WATCHER_SWAY_ROLL * M.alive * bold

	-- lean: grace forward-lean (the muted-mobile twin of the move-sound) / surge coil-then-release telegraph
	local leanTarget = 0
	if state == "grace" or state == "advancing" then
		leanTarget = tuning.WATCHER_GRACE_LEAN
	elseif state == "surge" then
		leanTarget = (M.surgeT < tuning.WATCHER_COIL_SECS) and tuning.WATCHER_COIL or tuning.WATCHER_SURGE_LEAN
	end
	M.lean, M.leanVel = spring(M.lean, M.leanVel, leanTarget, tuning.WATCHER_LEAN_K, 1, dt)

	-- gaze: aim the head at the camera (per-viewer "it is looking at ME"); while frozen it HOLDS its last stare
	if state ~= "frozen" and cam then
		local rel = (renderCF * NECK_PIVOT):PointToObjectSpace(cam.CFrame.Position)
		local horiz = math.sqrt(rel.X * rel.X + rel.Z * rel.Z)
		local yawT = math.atan2(-rel.X, -rel.Z)
		local pitchT = math.atan2(rel.Y, horiz) - breathPitch * tuning.WATCHER_BREATH_HEAD_COUNTER
		M.yawTarget = math.clamp(yawT, -tuning.WATCHER_YAW, tuning.WATCHER_YAW)
		M.pitchTarget = math.clamp(pitchT, tuning.WATCHER_PITCH_DN, tuning.WATCHER_PITCH_UP)
	end

	-- head springs; the notice beat spikes stiffness + drops damping for a fast, silent snap-to-you
	local hk, hr = tuning.WATCHER_HEAD_K, tuning.WATCHER_HEAD_RATIO
	if M.noticeT > 0 then
		M.noticeT -= dt
		hk, hr = tuning.WATCHER_HEAD_K_SNAP, tuning.WATCHER_NOTICE_RATIO
	end
	M.yaw, M.yawVel = spring(M.yaw, M.yawVel, M.yawTarget, hk, hr, dt)
	M.pitch, M.pitchVel = spring(M.pitch, M.pitchVel, M.pitchTarget, hk, hr, dt)

	-- eyes: a dim rest glow (findable in the dark) that flares on the notice pulse, then decays
	M.eyePulse = math.max(0, M.eyePulse - dt / 0.45)
	local eyeBright = tuning.WATCHER_EYE_LO + (tuning.WATCHER_EYE_HI - tuning.WATCHER_EYE_LO) * M.eyePulse

	WatcherRig.pose(M.rig, renderCF, {
		breathRise = breathRise,
		spinePitch = swayPitch + breathPitch,
		spineRoll = swayRoll,
		lean = M.lean,
		neckYaw = M.yaw,
		neckPitch = M.pitch,
		eyeBright = eyeBright,
	})
end

local function mount(logicRoot)
	unmount() -- only ever one Watcher at a time
	local rig = WatcherRig.buildLocal(workspace)
	M = {
		logicRoot = logicRoot,
		rig = rig,
		renderCF = logicRoot.CFrame,
		snapToken = logicRoot:GetAttribute("Snap") or 0,
		t = 0,
		alive = 1,
		yaw = 0,
		yawVel = 0,
		pitch = 0,
		pitchVel = 0,
		yawTarget = 0,
		pitchTarget = 0,
		lean = 0,
		leanVel = 0,
		noticeT = 0,
		surgeT = 0,
		eyePulse = 0,
		prevState = logicRoot:GetAttribute("WatcherState") or "idle",
	}
	WatcherRig.pose(rig, M.renderCF, { eyeBright = tuning.WATCHER_EYE_LO }) -- pose once so it never flashes at origin
	M.conn = RunService.RenderStepped:Connect(step)
end

for _, inst in CollectionService:GetTagged(TAG) do
	mount(inst)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(mount)
CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(inst)
	if M and M.logicRoot == inst then
		unmount()
	end
end)

-- keep the linter honest that Players is used (and future-proof: clear the rig if the local player leaves)
Players.LocalPlayer.AncestryChanged:Connect(function()
	if not Players.LocalPlayer.Parent then
		unmount()
	end
end)
