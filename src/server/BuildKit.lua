-- Shared construction kit: one palette, one part helper, one room builder used by every stage, so the whole
-- experience reads as one place. Blockout on purpose (Bible: prototypes are fast, simple, cheap) but cold,
-- jittered, materialled — never flat default gray.
local BuildKit = {}

BuildKit.WALL = Color3.fromRGB(92, 95, 90)
BuildKit.FLOOR = Color3.fromRGB(70, 72, 71)
BuildKit.CEIL = Color3.fromRGB(46, 48, 50)
BuildKit.TRIM = Color3.fromRGB(56, 48, 40)
BuildKit.PAPER = Color3.fromRGB(214, 208, 194)
BuildKit.INK = Color3.fromRGB(34, 32, 28)
BuildKit.RED = Color3.fromRGB(210, 60, 60)
BuildKit.GREEN = Color3.fromRGB(70, 200, 90)

function BuildKit.jitter(base)
	local function ch(v)
		return math.clamp(v + math.random(-8, 8), 0, 255)
	end
	return Color3.fromRGB(ch(base.R * 255), ch(base.G * 255), ch(base.B * 255))
end

function BuildKit.part(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Locked = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.Concrete
	p.Color = BuildKit.WALL
	for k, v in props do
		p[k] = v
	end
	p.Parent = parent
	return p
end

-- a rectangular room with floor, ceiling, four walls, and an optional door gap on the +X (east) wall.
-- returns the door-gap center so the caller can place a door/exit there.
function BuildKit.room(folder, b, opts)
	opts = opts or {}
	local cx, cz = (b.minX + b.maxX) / 2, (b.minZ + b.maxZ) / 2
	local w, d = b.maxX - b.minX, b.maxZ - b.minZ
	local h = opts.height or 11
	BuildKit.part({
		Size = Vector3.new(w, 0.2, d),
		CFrame = CFrame.new(cx, 0.1, cz),
		Color = BuildKit.jitter(BuildKit.FLOOR),
		Name = "Floor",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(w + 2, 0.5, d + 2),
		CFrame = CFrame.new(cx, h + 0.25, cz),
		Color = BuildKit.jitter(BuildKit.CEIL),
		Name = "Ceiling",
	}, folder)
	-- south + north walls
	BuildKit.part({
		Size = Vector3.new(w, h, 1),
		CFrame = CFrame.new(cx, h / 2, b.minZ),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(w, h, 1),
		CFrame = CFrame.new(cx, h / 2, b.maxZ),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	-- west wall (entrance side; solid)
	BuildKit.part({
		Size = Vector3.new(1, h, d),
		CFrame = CFrame.new(b.minX, h / 2, cz),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	-- east wall with a door gap (z -3..3)
	local gapHalf = opts.doorHalf or 3
	BuildKit.part({
		Size = Vector3.new(1, h, d / 2 - gapHalf),
		CFrame = CFrame.new(b.maxX, h / 2, b.minZ + (d / 2 - gapHalf) / 2),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(1, h, d / 2 - gapHalf),
		CFrame = CFrame.new(b.maxX, h / 2, b.maxZ - (d / 2 - gapHalf) / 2),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(1, h - gapHalf * 2 - 2, gapHalf * 2),
		CFrame = CFrame.new(b.maxX, h - (h - gapHalf * 2 - 2) / 2, cz),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Lintel",
	}, folder)
	-- baseboards
	BuildKit.part({
		Size = Vector3.new(w, 0.9, 0.5),
		CFrame = CFrame.new(cx, 0.55, b.minZ + 0.4),
		Color = BuildKit.TRIM,
		Material = Enum.Material.WoodPlanks,
		Name = "Baseboard",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(w, 0.9, 0.5),
		CFrame = CFrame.new(cx, 0.55, b.maxZ - 0.4),
		Color = BuildKit.TRIM,
		Material = Enum.Material.WoodPlanks,
		Name = "Baseboard",
	}, folder)
	return { doorCenter = Vector3.new(b.maxX, 4, cz), center = Vector3.new(cx, 3.5, cz) }
end

-- a ceiling light pool (dark gaps between; horror lights as sparse pools, never uniform fill)
function BuildKit.pool(folder, x, y, z, color, brightness, range)
	local bulb = BuildKit.part({
		Size = Vector3.new(1.6, 0.3, 1.6),
		CFrame = CFrame.new(x, y, z),
		Color = color,
		Material = Enum.Material.Neon,
		Name = "Fixture",
	}, folder)
	local sl = Instance.new("SpotLight")
	sl.Face = Enum.NormalId.Bottom
	sl.Angle = 78
	sl.Range = range or 26
	sl.Brightness = brightness or 1.6
	sl.Color = color
	sl.Shadows = false
	sl.Parent = bulb
	return bulb
end

-- a wall sign (SurfaceGui text) — used for stage titles and stub markers
function BuildKit.sign(folder, cframe, text, color)
	local board = BuildKit.part({
		Size = Vector3.new(0.4, 4, 9),
		CFrame = cframe,
		Color = Color3.fromRGB(24, 23, 22),
		Material = Enum.Material.SmoothPlastic,
		Name = "Sign",
	}, folder)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 400)
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.92, 0.92)
	label.Position = UDim2.fromScale(0.04, 0.04)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SpecialElite
	label.TextColor3 = color or BuildKit.PAPER
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
	return label
end

-- an interaction pad the player walks onto to proceed (used for stub-encounter "proceed" and transitions)
function BuildKit.pad(folder, position, color)
	return BuildKit.part({
		Size = Vector3.new(6, 0.3, 6),
		CFrame = CFrame.new(position),
		Color = color or BuildKit.GREEN,
		Material = Enum.Material.Neon,
		Name = "Pad",
	}, folder)
end

return BuildKit
