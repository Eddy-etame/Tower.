-- The Watcher's visible body — a CLIENT-LOCAL cosmetic rig. The server owns only an invisible LogicRoot (the
-- hitbox the freeze/catch measure); this rig is built on each client, follows the replicated LogicRoot, and is
-- posed procedurally every frame. It is authored RENDERROOT-RELATIVE (parts hang off origin), so wherever the
-- client places the render root, the body sits centered on it — which fixes the old bug where the welded body
-- trailed ~47 studs behind the hitbox.
--
-- FULLY KINEMATIC on purpose: every part is Anchored and its world CFrame is computed and set each frame (no
-- welds, no Motor6D, no physics solver). That removes the whole class of weld/anchored-drive timing jitter — the
-- pose is deterministic and reasoned, not left to the constraint step. Rotations compose about explicit pivots.
local WatcherRig = {}

local NEAR_BLACK = Color3.fromRGB(10, 10, 12) -- invisible in the dark until a flashlight finds it
local EYE_DIM = Color3.fromRGB(120, 18, 18)
local EYE_HOT = Color3.fromRGB(235, 40, 40)

-- rest offsets relative to the render root (the same proportions the old server body used — a tall, gaunt,
-- forward-leaning figure — but now correctly root-relative)
-- SILHOUETTE PASS (2026-07-21): gaunt, asymmetric, WRONG. Arms hang past where hands should end; one
-- shoulder rides higher; the skull is narrow and tall. The proportions unsettle before it ever moves.
local REST = {
	torso = CFrame.new(0, 3.1, 0.1) * CFrame.Angles(math.rad(-8), 0, math.rad(1.5)),
	chest = CFrame.new(0.05, 6.5, -0.3) * CFrame.Angles(0, 0, math.rad(-2)),
	-- head rest is UNTILTED (faces straight -Z): the gaze fully owns where the head points, so any rest tilt
	-- would just make it aim off the player by that angle
	head = CFrame.new(0, 7.85, -0.55),
	armL = CFrame.new(-1.08, 3.95, 0.3) * CFrame.Angles(math.rad(6), 0, math.rad(-7)),
	armR = CFrame.new(1.05, 4.25, 0.3) * CFrame.Angles(math.rad(6), 0, math.rad(4)),
	legL = CFrame.new(-0.48, 1.3, 0),
	legR = CFrame.new(0.5, 1.3, 0),
	eyeL = CFrame.new(-0.28, 7.9, -1.02),
	eyeR = CFrame.new(0.32, 7.86, -1.02), -- eyes minutely uneven - readable only when it is TOO close
}

local SPINE_PIVOT = CFrame.new(0, 4.6, 0) -- the waist: breath/sway/lean rotate the upper body about here
local NECK_PIVOT = CFrame.new(0, 7, -0.4) -- base of the head: the gaze rotates the head about here
local SPINE_PIVOT_INV = SPINE_PIVOT:Inverse() -- hoisted (these are constant; never recompute per frame)
local NECK_PIVOT_INV = NECK_PIVOT:Inverse()

local function makePart(size, color, material, name)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false -- the flashlight cone stays the one shadow-caster in frame (mobile shadow budget)
	p.Locked = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color or NEAR_BLACK
	p.Size = size
	p.Name = name
	return p
end

-- build the visible rig on the local client. Returns a handle with the parts + a pose(handle, renderCF, p).
function WatcherRig.buildLocal(parent)
	local folder = Instance.new("Model")
	folder.Name = "WatcherRig"

	local h = { folder = folder, eyes = {} }
	h.torso = makePart(Vector3.new(1.55, 4.4, 0.75), NEAR_BLACK, nil, "Torso")
	h.chest = makePart(Vector3.new(1.2, 2.0, 0.8), NEAR_BLACK, nil, "Chest")
	h.head = makePart(Vector3.new(1.0, 1.5, 0.95), NEAR_BLACK, nil, "Head")
	h.armL = makePart(Vector3.new(0.32, 5.5, 0.32), NEAR_BLACK, nil, "ArmL")
	h.armR = makePart(Vector3.new(0.32, 5.3, 0.32), NEAR_BLACK, nil, "ArmR")
	h.legL = makePart(Vector3.new(0.42, 3.5, 0.45), NEAR_BLACK, nil, "LegL")
	h.legR = makePart(Vector3.new(0.44, 3.5, 0.45), NEAR_BLACK, nil, "LegR")
	for i = 1, 2 do
		h.eyes[i] = makePart(Vector3.new(0.24, 0.16, 0.2), EYE_DIM, Enum.Material.Neon, "Eye")
	end
	-- the halo: a faint red presence-glow on the head — trackable in pitch dark while it is ALIVE, gone when
	-- frozen (the light itself teaches the rule). Driven per-frame by pose() via p.haloBright.
	h.halo = Instance.new("PointLight")
	h.halo.Color = EYE_HOT
	h.halo.Brightness = 0
	h.halo.Range = 7
	h.halo.Shadows = false
	h.halo.Parent = h.head

	for _, part in { h.torso, h.chest, h.head, h.armL, h.armR, h.legL, h.legR, h.eyes[1], h.eyes[2] } do
		part.Parent = folder
	end
	folder.Parent = parent or workspace
	return h
end

-- pose the rig for this frame. renderCF = where the render root currently is; p = pose params:
--   breathRise, spinePitch, spineRoll, lean (fwd), neckYaw, neckPitch, eyeBright (0..1)
function WatcherRig.pose(h, renderCF, p)
	-- spine transform (breath rise + sway/lean pitch + sway roll) about the waist pivot
	local spineX = CFrame.new(0, p.breathRise or 0, 0)
		* CFrame.Angles((p.spinePitch or 0) + (p.lean or 0), 0, p.spineRoll or 0)
	local spineM = renderCF * SPINE_PIVOT * spineX * SPINE_PIVOT_INV
	-- neck transform (gaze) about the neck pivot, composed on top of the spine
	local neckX = CFrame.Angles(p.neckPitch or 0, p.neckYaw or 0, 0)
	local neckM = spineM * NECK_PIVOT * neckX * NECK_PIVOT_INV

	-- rigid lower body rides the render root directly
	h.torso.CFrame = renderCF * REST.torso
	h.legL.CFrame = renderCF * REST.legL
	h.legR.CFrame = renderCF * REST.legR
	-- upper body rides the spine
	h.chest.CFrame = spineM * REST.chest
	h.armL.CFrame = spineM * REST.armL
	h.armR.CFrame = spineM * REST.armR
	-- head + eyes ride the neck (so the gaze carries the eyes for free)
	h.head.CFrame = neckM * REST.head
	h.eyes[1].CFrame = neckM * REST.eyeL
	h.eyes[2].CFrame = neckM * REST.eyeR

	local c = EYE_DIM:Lerp(EYE_HOT, math.clamp(p.eyeBright or 0, 0, 1))
	h.eyes[1].Color = c
	h.eyes[2].Color = c
	if h.halo then
		h.halo.Brightness = p.haloBright or 0
	end
end

function WatcherRig.destroy(h)
	if h and h.folder then
		h.folder:Destroy()
	end
end

return WatcherRig
