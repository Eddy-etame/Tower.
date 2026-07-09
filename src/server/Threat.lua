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

	part({ Size = Vector3.new(2, 5, 1), CFrame = CFrame.new(0, 3, 0), Name = "Body" }, model)
	part({ Size = Vector3.new(1.5, 1.5, 1.4), CFrame = CFrame.new(0, 6.2, 0), Name = "Head" }, model)
	-- faint eyes: two dim points you can just make out in the dark, so the Watcher is findable to light
	for _, ex in { -0.35, 0.35 } do
		local eye = part({
			Size = Vector3.new(0.28, 0.28, 0.28),
			CFrame = CFrame.new(ex, 6.35, -0.7),
			Color = Color3.fromRGB(180, 30, 30),
			Material = Enum.Material.Neon,
			Name = "Eye",
		}, model)
		local g = Instance.new("PointLight")
		g.Range = 5
		g.Brightness = 0.5
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

-- returns the player it catches this step, or nil
function Threat.step(handle, dt, players, tuning)
	local pos = handle.root.Position
	local aim = pos + Vector3.new(0, 3, 0) -- body-center, so "looking at it" reads reliably

	-- frozen if ANY living player is observing it
	for _, player in players do
		local char = player.Character
		if char and char.PrimaryPart and observedBy(char, aim, tuning) then
			return nil -- held
		end
	end

	-- otherwise advance toward the nearest player STILL INSIDE THE ROOM (x <= 64: past the door they are safe,
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
		return nil
	end

	if best <= tuning.CATCH_DISTANCE then
		return Threat.playerOf(players, target)
	end

	local dir = Vector3.new(target.Position.X - pos.X, 0, target.Position.Z - pos.Z)
	if dir.Magnitude > 0.1 then
		dir = dir.Unit
		local newPos = pos + dir * tuning.ADVANCE_SPEED * dt
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
	handle.model:PivotTo(handle.spawn)
end

return Threat
