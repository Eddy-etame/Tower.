-- The Watcher — CLIENT BRAIN. Builds the visible body locally, follows the server's invisible LogicRoot (smooth
-- at render rate over its 10Hz replication), and layers procedural life on top. Reads server state ONE-WAY
-- (LogicRoot.CFrame + WatcherState/Boldness/Snap attributes); it NEVER writes back, so nothing here
-- can cheat the freeze/catch — those measure the server LogicRoot alone.
--
-- The life TEACHES the locked rule wordlessly: it breathes/sways and its head tracks YOU while it is alive, then
-- snaps taut-dead-still the instant you light it (weeping-angel). That stillness is the visual twin of the move
-- sound cutting out — the fair tell for the ~70% on muted phone speakers. On the frozen->waking edge (only after
-- it was HELD frozen a beat, and never more than once per cooldown) the head snaps to lock onto you and the eyes
-- flare — silent, a look not a bang; the grace window leans it forward; the surge coils then lunges. All
-- amplitudes are sub-perceptual until spent in a beat (restraint — over-juice kills the uncertainty).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local WatcherRig = require(ReplicatedStorage.Shared.WatcherRig)

local TAG = "WatcherLogicRoot"
-- these two MUST match WatcherRig's pivots — the gaze is solved in the same spine/neck frame the rig poses in
local SPINE_PIVOT = CFrame.new(0, 4.6, 0)
local NECK_PIVOT = CFrame.new(0, 7, -0.4)

local M -- the single active mount, or nil

-- a semi-implicit damped spring (ratio 1 ~ critical, <1 = organic overshoot). Sub-stepped at a fixed inner dt so
-- the explicit integrator stays inside its stability window even during a low-fps hitch (a raw dt at ~15fps with
-- the stiff notice spring would diverge and fling the head to a garbage angle).
local function spring(x, v, target, k, ratio, dt)
	local c = 2 * math.sqrt(k) * ratio
	local steps = math.max(1, math.ceil(dt / 0.02))
	local h = dt / steps
	for _ = 1, steps do
		v = v + (-k * (x - target) - c * v) * h
		x = x + v * h
	end
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

	-- follow: position lerp (clamp-snapped so the visual never lags the hitbox by more than SNAP_CLAMP — catch
	-- fairness) + a SEPARATE, turn-rate-capped rotation lerp so a large re-face never whip-spins the body
	local alpha = 1 - math.exp(-tuning.WATCHER_FOLLOW_K * dt)
	local newPos = M.renderCF.Position:Lerp(targetCF.Position, alpha)
	if (newPos - targetCF.Position).Magnitude > tuning.WATCHER_SNAP_CLAMP then
		newPos = targetCF.Position
	end
	local _, ang = M.renderCF.Rotation:ToObjectSpace(targetCF.Rotation):ToAxisAngle()
	local rotAlpha = alpha
	if ang * rotAlpha > tuning.WATCHER_TURN_RATE * dt then
		rotAlpha = (tuning.WATCHER_TURN_RATE * dt) / math.max(ang, 1e-4)
	end
	M.renderCF = CFrame.new(newPos) * M.renderCF.Rotation:Lerp(targetCF.Rotation, rotAlpha)
	local renderCF = M.renderCF

	-- ---- BOOKKEEPING (runs EVERY frame, even when culled, so a beat that fires off-screen expires off-screen
	-- and never replays stale when the player looks back) ----
	M.t += dt
	local state = logicRoot:GetAttribute("WatcherState") or "idle"
	local boldness = logicRoot:GetAttribute("Boldness") or 0

	if state == "frozen" then
		M.frozenT += dt
	end
	M.noticeCd = math.max(0, M.noticeCd - dt)

	if state ~= M.prevState then
		-- the notice beat: only when it was HELD frozen long enough (a real held-then-broke moment) and its
		-- cooldown has elapsed — so flicking your light or panning past it can never strobe the eyes/head
		if
			M.prevState == "frozen"
			and state ~= "idle"
			and M.frozenT >= tuning.WATCHER_NOTICE_ARM_SECS
			and M.noticeCd <= 0
		then
			M.noticeT = tuning.WATCHER_NOTICE_SECS
			M.eyePulse = 1
			M.noticeCd = tuning.WATCHER_NOTICE_COOLDOWN
		end
		if M.prevState == "frozen" then
			M.frozenT = 0
		end
		M.prevState = state
	end

	local aliveTarget = (state == "frozen") and 0 or 1
	local rampT = (aliveTarget > M.alive) and tuning.WATCHER_ALIVE_RAMP or tuning.WATCHER_FREEZE_DAMP
	M.alive += (aliveTarget - M.alive) * (1 - math.exp(-dt / math.max(rampT, 0.01)))
	if M.noticeT > 0 then
		M.noticeT -= dt
	end
	M.eyePulse = math.max(0, M.eyePulse - dt / tuning.WATCHER_EYE_DECAY)

	-- ---- ARTICULATION (the expensive part — skipped when far/off budget; the body just holds its last pose) ----
	if cam and (renderCF.Position - cam.CFrame.Position).Magnitude > tuning.WATCHER_CULL_DIST then
		return
	end

	local bold = 1 + math.clamp(boldness, 0, 3) * tuning.WATCHER_BOLD_SCALE
	local breath = math.sin(M.t * 2 * math.pi * tuning.WATCHER_BREATH_HZ)
	local breathRise = breath * tuning.WATCHER_BREATH_RISE * M.alive * bold
	local breathPitch = breath * tuning.WATCHER_BREATH_PITCH * M.alive
	local swayPitch = math.sin(M.t * 2 * math.pi * tuning.WATCHER_SWAY_A) * tuning.WATCHER_SWAY_PITCH * M.alive * bold
	local swayRoll = math.sin(M.t * 2 * math.pi * tuning.WATCHER_SWAY_B) * tuning.WATCHER_SWAY_ROLL * M.alive * bold

	local leanTarget = 0
	if state == "grace" or state == "advancing" then
		leanTarget = tuning.WATCHER_GRACE_LEAN
	elseif state == "coil" then
		leanTarget = tuning.WATCHER_COIL -- gathering in place (server holds ground): lean back
	elseif state == "surge" then
		leanTarget = tuning.WATCHER_SURGE_LEAN -- released lunge
	end
	M.lean, M.leanVel = spring(M.lean, M.leanVel, leanTarget, tuning.WATCHER_LEAN_K, 1, dt)

	-- gaze: aim the head at the camera (per-viewer "it is looking at ME"). Solved in the SAME spine frame the rig
	-- poses in, so the lean/sway/breath don't pull the aim off. While frozen it HOLDS its last stare.
	if state ~= "frozen" and cam then
		local spineX = CFrame.new(0, breathRise, 0) * CFrame.Angles(swayPitch + breathPitch + M.lean, 0, swayRoll)
		local spineM = renderCF * SPINE_PIVOT * spineX * SPINE_PIVOT:Inverse()
		local rel = (spineM * NECK_PIVOT):PointToObjectSpace(cam.CFrame.Position)
		local horiz = math.sqrt(rel.X * rel.X + rel.Z * rel.Z)
		local yawT = math.atan2(-rel.X, -rel.Z)
		-- hold the aim over one shoulder when the camera leaves the reachable cone (no atan2 rear-wrap whip)
		if math.abs(yawT) <= tuning.WATCHER_YAW then
			M.yawTarget = yawT
		else
			M.yawTarget = (M.yawTarget < 0) and -tuning.WATCHER_YAW or tuning.WATCHER_YAW
		end
		M.pitchTarget = math.clamp(math.atan2(rel.Y, horiz), tuning.WATCHER_PITCH_DN, tuning.WATCHER_PITCH_UP)
	end

	local hk, hr = tuning.WATCHER_HEAD_K, tuning.WATCHER_HEAD_RATIO
	if M.noticeT > 0 then
		hk, hr = tuning.WATCHER_HEAD_K_SNAP, tuning.WATCHER_NOTICE_RATIO
	end
	M.yaw, M.yawVel = spring(M.yaw, M.yawVel, M.yawTarget, hk, hr, dt)
	M.pitch, M.pitchVel = spring(M.pitch, M.pitchVel, M.pitchTarget, hk, hr, dt)
	-- clamp the spring OUTPUT to the neck limits so a stiff snap can never visibly overshoot the "cannot look
	-- further" cone (WatcherRig applies neckYaw/neckPitch unguarded)
	M.yaw = math.clamp(M.yaw, -tuning.WATCHER_YAW, tuning.WATCHER_YAW)
	M.pitch = math.clamp(M.pitch, tuning.WATCHER_PITCH_DN, tuning.WATCHER_PITCH_UP)

	local p = M.poseParams -- reuse one scratch table (no per-frame allocation)
	p.breathRise = breathRise
	p.spinePitch = swayPitch + breathPitch
	p.spineRoll = swayRoll
	p.lean = M.lean
	p.neckYaw = M.yaw
	p.neckPitch = M.pitch
	p.eyeBright = tuning.WATCHER_EYE_LO + (tuning.WATCHER_EYE_HI - tuning.WATCHER_EYE_LO) * M.eyePulse
	WatcherRig.pose(M.rig, renderCF, p)
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
		noticeCd = 0,
		frozenT = 0,
		eyePulse = 0,
		prevState = logicRoot:GetAttribute("WatcherState") or "idle",
		poseParams = {},
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

-- future-proof: clear the rig if the local player leaves
Players.LocalPlayer.AncestryChanged:Connect(function()
	if not Players.LocalPlayer.Parent then
		unmount()
	end
end)
