-- The Watcher. Server owns everything: its position, whether it is frozen (observed) or advancing, and the
-- catch. The rule, enforced here and never lied about (Trust pillar): while a player has it in view + line of
-- sight + close enough for their light to reach, it cannot move; the instant that breaks, it advances.
-- Observation is judged from the character's look (first-person body faces the camera) so it is server-side
-- and unexploitable — the client never decides whether the Watcher is frozen.

local Threat = {}

local SPAWN = Vector3.new(46, 0, 12) -- starts deep in the room, off the direct entrance->lever line

local function part(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Locked = true
	p.CanCollide = false
	p.CanQuery = false
	p.Material = Enum.Material.SmoothPlastic
	p.Color = Color3.fromRGB(10, 10, 12) -- near-black: invisible in the dark until a flashlight finds it
	for k, v in props do
		p[k] = v
	end
	p.Parent = parent
	return p
end

function Threat.build(parentFolder)
	local model = Instance.new("Model")
	model.Name = "Watcher"

	local root = part({
		Size = Vector3.new(2.4, 0.2, 2.4),
		CFrame = CFrame.new(SPAWN + Vector3.new(0, 0.2, 0)),
		Transparency = 1,
		Name = "Root",
	}, model)
	model.PrimaryPart = root

	-- a tall, gaunt, forward-leaning figure — intentional proportions (not a stubby box). Blockout, but read.
	part({
		Size = Vector3.new(1.8, 4, 0.9),
		CFrame = CFrame.new(0, 3, 0.1) * CFrame.Angles(math.rad(-8), 0, 0),
		Name = "Torso",
	}, model)
	part({ Size = Vector3.new(1.3, 2.2, 0.9), CFrame = CFrame.new(0, 6.4, -0.3), Name = "Chest" }, model)
	part({
		Size = Vector3.new(1.2, 1.3, 1.1),
		CFrame = CFrame.new(0, 7.7, -0.55) * CFrame.Angles(math.rad(14), 0, 0),
		Name = "Head",
	}, model)
	-- long thin limbs hanging
	for _, side in { -1, 1 } do
		part({
			Size = Vector3.new(0.4, 4.4, 0.4),
			CFrame = CFrame.new(side * 1.1, 4.5, 0.3) * CFrame.Angles(math.rad(6), 0, side * math.rad(4)),
			Name = "Arm",
		}, model)
		part({ Size = Vector3.new(0.5, 3.4, 0.5), CFrame = CFrame.new(side * 0.5, 1.3, 0), Name = "Leg" }, model)
	end
	-- deep-set eyes: two dim points you can just make out in the dark, so the Watcher is findable to light
	for _, ex in { -0.3, 0.3 } do
		local eye = part({
			Size = Vector3.new(0.24, 0.16, 0.2),
			CFrame = CFrame.new(ex, 7.75, -1.05),
			Color = Color3.fromRGB(190, 26, 26),
			Material = Enum.Material.Neon,
			Name = "Eye",
		}, model)
		local g = Instance.new("PointLight")
		g.Range = 4.5
		g.Brightness = 0.45
		g.Color = eye.Color
		g.Parent = eye
	end

	-- weld the body parts to the root so PivotTo moves them together
	for _, p in model:GetChildren() do
		if p ~= root and p:IsA("BasePart") then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = p
			weld.Parent = root
			p.Anchored = false
		end
	end

	model.Parent = parentFolder
	return { model = model, root = root, spawn = CFrame.new(SPAWN + Vector3.new(0, 0.2, 0)) }
end

-- the Watcher's spatial move sound: attached to it, plays ONLY while advancing, silent while frozen.
-- This is the fair-fear tell (2026 watch) — the ear hears it closing behind you with your light pointed away.
function Threat.attachSound(handle, tuning)
	local s = Instance.new("Sound")
	s.SoundId = tuning.WATCHER_MOVE_SOUND
	s.PlaybackSpeed = tuning.WATCHER_MOVE_SPEED
	s.Volume = tuning.WATCHER_MOVE_VOLUME
	s.Looped = true
	s.RollOffMode = Enum.RollOffMode.InverseTapered
	s.RollOffMinDistance = 8
	s.RollOffMaxDistance = 70
	s.Parent = handle.root
	handle.moveSound = s
end

local function setMoving(handle, moving)
	if not handle.moveSound or handle.wasMoving == moving then
		return
	end
	handle.wasMoving = moving
	if moving then
		handle.moveSound:Play()
	else
		handle.moveSound:Stop()
	end
end

local function observedBy(character, threatPos, tuning)
	local head = character:FindFirstChild("Head")
	local hrp = character.PrimaryPart
	if not head or not hrp then
		return false
	end
	local to = threatPos - head.Position
	local dist = to.Magnitude
	if dist > tuning.OBSERVE_RANGE then
		return false
	end
	-- use the head look (first person faces camera; third person faces move/camera dir) as the gaze proxy
	if head.CFrame.LookVector:Dot(to.Unit) < tuning.VIEW_DOT then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local hit = workspace:Raycast(head.Position, to, params)
	-- LOS clear (nothing but the Watcher between eye and it) = observed = frozen
	return hit == nil
		or hit.Instance:IsDescendantOf(character.Parent and character.Parent:FindFirstChild("Watcher") or character)
end

-- returns the player it catches this step, or nil. breakersDone escalates its speed (the tension curve).
-- lighting[userId] = the player is effectively lighting it (flashlight on AND charged) — only then can they
-- freeze it; a dead flashlight cannot hold it (the light-rationing anti-camp).
function Threat.step(handle, dt, players, tuning, breakersDone, lighting)
	local pos = handle.root.Position
	local aim = pos + Vector3.new(0, 3, 0) -- body-center, so "looking at it" reads reliably
	local speed = tuning.ADVANCE_SPEED + (breakersDone or 0) * tuning.ADVANCE_SPEED_PER_BREAKER
	lighting = lighting or {}

	-- frozen if ANY living player is both LIGHTING it and observing it
	for _, player in players do
		local char = player.Character
		if char and char.PrimaryPart and lighting[player.UserId] and observedBy(char, aim, tuning) then
			setMoving(handle, false) -- frozen: cut to silence (the audio teaches the rule)
			handle.unlitFor = 0
			return nil
		end
	end

	-- not observed. GRACE window: the move sound starts AT ONCE (the telegraph), but it does not gain ground
	-- for a beat — so a momentary look-away is survivable and every death is one the player heard coming (fair
	-- on mobile, where camera drag is slow). Only after grace does it actually advance.
	setMoving(handle, true)
	handle.unlitFor = (handle.unlitFor or 0) + dt
	if handle.unlitFor < tuning.GRACE_SECONDS then
		return nil -- waking, telegraphed, not yet closing
	end

	-- advance toward the nearest player STILL INSIDE THE ROOM (x <= 64: past the door they are safe,
	-- the Watcher never leaves the room, so it can never catch someone who already escaped)
	local target, best
	for _, player in players do
		local char = player.Character
		local root = char and char.PrimaryPart
		if root and root.Position.X <= 64 then
			local d = (root.Position - pos).Magnitude
			if not best or d < best then
				best = d
				target = root
			end
		end
	end
	if not target then
		setMoving(handle, false)
		return nil
	end

	if best <= tuning.CATCH_DISTANCE then
		return Threat.playerOf(players, target)
	end

	local dir = Vector3.new(target.Position.X - pos.X, 0, target.Position.Z - pos.Z)
	if dir.Magnitude > 0.1 then
		dir = dir.Unit
		local newPos = pos + dir * speed * dt
		handle.model:PivotTo(
			CFrame.lookAt(
				Vector3.new(newPos.X, pos.Y, newPos.Z),
				Vector3.new(target.Position.X, pos.Y, target.Position.Z)
			)
		)
	end
	return nil
end

function Threat.playerOf(players, root)
	for _, player in players do
		if player.Character and player.Character.PrimaryPart == root then
			return player
		end
	end
	return nil
end

function Threat.reset(handle)
	setMoving(handle, false)
	handle.unlitFor = 0
	handle.model:PivotTo(handle.spawn)
end

return Threat
