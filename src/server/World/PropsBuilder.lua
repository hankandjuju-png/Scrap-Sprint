--!strict
--[[
	Phase 2 Task 3: decorative scrap props for Starter Junkyard.
	Keeps spawn pad + west shop fronts clear; marks a lane toward the north gate.
	No collectible tags / spawn zones (Phase 3).
]]

local PropsBuilder = {}

-- Shared layout constants (must match MapBuilder floor / stall row)
local FLOOR_HALF = 80
local SPAWN_CLEAR_RADIUS = 14
-- West stalls at x ≈ -70 with pads toward center; keep a buffer in front of them
local SHOP_KEEP_OUT_X = -48 -- props must be east of this near the stall Z band
local SHOP_Z_BAND = 28 -- |z| within this near shops uses SHOP_KEEP_OUT_X
local GATE_PATH_HALF_WIDTH = 6 -- clear center lane toward north gate

local COLOR_RUST = Color3.fromRGB(145, 78, 48)
local COLOR_RUST_DARK = Color3.fromRGB(95, 55, 38)
local COLOR_STEEL = Color3.fromRGB(110, 118, 125)
local COLOR_STEEL_DARK = Color3.fromRGB(72, 76, 82)
local COLOR_CRATE = Color3.fromRGB(168, 122, 62)
local COLOR_CRATE_DARK = Color3.fromRGB(120, 86, 48)
local COLOR_BARREL_TEAL = Color3.fromRGB(48, 132, 118)
local COLOR_BARREL_YELLOW = Color3.fromRGB(210, 168, 48)
local COLOR_BARREL_RED = Color3.fromRGB(168, 62, 48)
local COLOR_TIRE = Color3.fromRGB(36, 36, 40)
local COLOR_HUSK = Color3.fromRGB(88, 92, 78)
local COLOR_HUSK_CAB = Color3.fromRGB(72, 98, 118)
local COLOR_MARKER = Color3.fromRGB(230, 150, 40)
local COLOR_SCRAP_A = Color3.fromRGB(130, 95, 70)
local COLOR_SCRAP_B = Color3.fromRGB(95, 110, 95)
local COLOR_SCRAP_C = Color3.fromRGB(155, 105, 55)

local function makePart(
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	parent: Instance,
	material: Enum.Material?,
	canCollide: boolean?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = if canCollide == nil then true else canCollide
	part.Material = material or Enum.Material.Metal
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function isBlocked(x: number, z: number): boolean
	-- Spawn pad keep-out
	if math.sqrt(x * x + z * z) < SPAWN_CLEAR_RADIUS then
		return true
	end
	-- West shop fronts / glow pads
	if x < SHOP_KEEP_OUT_X and math.abs(z) < SHOP_Z_BAND then
		return true
	end
	-- Center north path toward gate (leave walking room)
	if math.abs(x) < GATE_PATH_HALF_WIDTH and z < -10 then
		return true
	end
	-- Stay on the floor with a small wall inset
	if math.abs(x) > FLOOR_HALF - 6 or math.abs(z) > FLOOR_HALF - 6 then
		return true
	end
	return false
end

local function buildCrate(parent: Instance, name: string, position: Vector3, yawDegrees: number, scale: number?)
	local s = scale or 1
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local origin = CFrame.new(position) * CFrame.Angles(0, math.rad(yawDegrees), 0)
	local body = makePart(
		"Body",
		Vector3.new(3.2 * s, 2.4 * s, 2.6 * s),
		origin * CFrame.new(0, 1.2 * s, 0),
		COLOR_CRATE,
		model,
		Enum.Material.Wood
	)
	makePart(
		"Lid",
		Vector3.new(3.4 * s, 0.35 * s, 2.8 * s),
		origin * CFrame.new(0, 2.5 * s, 0) * CFrame.Angles(0, 0, math.rad(4)),
		COLOR_CRATE_DARK,
		model,
		Enum.Material.Wood
	)
	makePart(
		"Band",
		Vector3.new(3.35 * s, 0.25 * s, 2.7 * s),
		origin * CFrame.new(0, 0.7 * s, 0),
		COLOR_STEEL_DARK,
		model,
		Enum.Material.Metal
	)
	model.PrimaryPart = body
	return model
end

local function buildBarrel(parent: Instance, name: string, position: Vector3, color: Color3, tipped: boolean?)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local height = 3.4
	local diameter = 2.2
	local barrel = Instance.new("Part")
	barrel.Name = "Drum"
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(height, diameter, diameter)
	barrel.Anchored = true
	barrel.CanCollide = true
	barrel.Material = Enum.Material.Metal
	barrel.Color = color
	barrel.TopSurface = Enum.SurfaceType.Smooth
	barrel.BottomSurface = Enum.SurfaceType.Smooth

	if tipped then
		-- Lie on side along X
		barrel.CFrame = CFrame.new(position + Vector3.new(0, diameter * 0.5, 0))
			* CFrame.Angles(0, math.rad(25), 0)
	else
		-- Stand upright (cylinder axis is X → rotate to Y)
		barrel.CFrame = CFrame.new(position + Vector3.new(0, height * 0.5, 0))
			* CFrame.Angles(0, 0, math.rad(90))
	end
	barrel.Parent = model

	local rim = Instance.new("Part")
	rim.Name = "Rim"
	rim.Shape = Enum.PartType.Cylinder
	rim.Size = Vector3.new(0.2, diameter + 0.15, diameter + 0.15)
	rim.Anchored = true
	rim.CanCollide = false
	rim.Material = Enum.Material.Metal
	rim.Color = COLOR_STEEL
	if tipped then
		rim.CFrame = barrel.CFrame * CFrame.new(height * 0.42, 0, 0)
	else
		rim.CFrame = barrel.CFrame * CFrame.new(height * 0.42, 0, 0)
	end
	rim.Parent = model

	model.PrimaryPart = barrel
	return model
end

local function buildScrapPile(parent: Instance, name: string, position: Vector3, yawDegrees: number)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local origin = CFrame.new(position) * CFrame.Angles(0, math.rad(yawDegrees), 0)
	local chunks: { { size: Vector3, offset: Vector3, color: Color3, tilt: number } } = {
		{ size = Vector3.new(5.5, 1.4, 3.8), offset = Vector3.new(0, 0.7, 0), color = COLOR_SCRAP_A, tilt = 6 },
		{ size = Vector3.new(3.2, 1.1, 2.4), offset = Vector3.new(1.4, 1.5, 0.6), color = COLOR_RUST, tilt = -12 },
		{ size = Vector3.new(2.6, 0.9, 3.0), offset = Vector3.new(-1.2, 1.35, -0.5), color = COLOR_SCRAP_B, tilt = 18 },
		{ size = Vector3.new(2.0, 0.7, 1.6), offset = Vector3.new(0.2, 2.1, 0.2), color = COLOR_SCRAP_C, tilt = -8 },
		{ size = Vector3.new(1.4, 0.55, 2.2), offset = Vector3.new(-0.6, 0.45, 1.6), color = COLOR_RUST_DARK, tilt = 22 },
	}

	local primary: Part? = nil
	for i, chunk in chunks do
		local part = makePart(
			("Chunk%d"):format(i),
			chunk.size,
			origin * CFrame.new(chunk.offset) * CFrame.Angles(0, math.rad(chunk.tilt), math.rad(chunk.tilt * 0.4)),
			chunk.color,
			model,
			if i % 2 == 0 then Enum.Material.CorrodedMetal else Enum.Material.Metal
		)
		if not primary then
			primary = part
		end
	end
	if primary then
		model.PrimaryPart = primary
	end
	return model
end

local function buildTireStack(parent: Instance, name: string, position: Vector3, count: number, yawDegrees: number)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local origin = CFrame.new(position) * CFrame.Angles(0, math.rad(yawDegrees), 0)
	local tireHeight = 0.7
	local tireDiameter = 2.8
	local primary: Part? = nil

	for i = 1, count do
		local y = tireHeight * (i - 0.5)
		local wobble = if i % 2 == 0 then 4 else -3
		local tire = Instance.new("Part")
		tire.Name = ("Tire%d"):format(i)
		tire.Shape = Enum.PartType.Cylinder
		tire.Size = Vector3.new(tireHeight, tireDiameter, tireDiameter)
		-- Stand like a tire stack (axis vertical)
		tire.CFrame = origin * CFrame.new(0, y, 0) * CFrame.Angles(0, math.rad(wobble * i), math.rad(90))
		tire.Anchored = true
		tire.CanCollide = true
		tire.Material = Enum.Material.SmoothPlastic
		tire.Color = COLOR_TIRE
		tire.TopSurface = Enum.SurfaceType.Smooth
		tire.BottomSurface = Enum.SurfaceType.Smooth
		tire.Parent = model

		-- Inner hub hint
		local hub = Instance.new("Part")
		hub.Name = ("Hub%d"):format(i)
		hub.Shape = Enum.PartType.Cylinder
		hub.Size = Vector3.new(tireHeight * 0.9, tireDiameter * 0.45, tireDiameter * 0.45)
		hub.CFrame = tire.CFrame
		hub.Anchored = true
		hub.CanCollide = false
		hub.Material = Enum.Material.Metal
		hub.Color = COLOR_STEEL
		hub.Parent = model

		if not primary then
			primary = tire
		end
	end

	if primary then
		model.PrimaryPart = primary
	end
	return model
end

local function buildPathMarker(parent: Instance, name: string, position: Vector3, yawDegrees: number)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local origin = CFrame.new(position) * CFrame.Angles(0, math.rad(yawDegrees), 0)
	-- Low cone-ish stack of cylinders (no MeshId needed)
	local base = makePart(
		"Base",
		Vector3.new(1.6, 0.35, 1.6),
		origin * CFrame.new(0, 0.175, 0),
		COLOR_STEEL_DARK,
		model,
		Enum.Material.Metal,
		false
	)
	local mid = Instance.new("Part")
	mid.Name = "Cone"
	mid.Shape = Enum.PartType.Cylinder
	mid.Size = Vector3.new(1.8, 1.1, 1.1)
	mid.CFrame = origin * CFrame.new(0, 1.1, 0) * CFrame.Angles(0, 0, math.rad(90))
	mid.Anchored = true
	mid.CanCollide = false
	mid.Material = Enum.Material.SmoothPlastic
	mid.Color = COLOR_MARKER
	mid.Parent = model

	local stripe = Instance.new("Part")
	stripe.Name = "Stripe"
	stripe.Shape = Enum.PartType.Cylinder
	stripe.Size = Vector3.new(0.35, 1.2, 1.2)
	stripe.CFrame = origin * CFrame.new(0, 1.0, 0) * CFrame.Angles(0, 0, math.rad(90))
	stripe.Anchored = true
	stripe.CanCollide = false
	stripe.Material = Enum.Material.SmoothPlastic
	stripe.Color = Color3.fromRGB(245, 245, 240)
	stripe.Parent = model

	model.PrimaryPart = base
	return model
end

local function buildVehicleHusk(parent: Instance, position: Vector3, yawDegrees: number)
	local model = Instance.new("Model")
	model.Name = "AbandonedVehicleHusk"
	model.Parent = parent

	local origin = CFrame.new(position) * CFrame.Angles(0, math.rad(yawDegrees), 0) * CFrame.Angles(0, 0, math.rad(-4))

	local chassis = makePart(
		"Chassis",
		Vector3.new(10, 1.4, 4.6),
		origin * CFrame.new(0, 1.1, 0),
		COLOR_HUSK,
		model,
		Enum.Material.CorrodedMetal
	)
	makePart(
		"Cabin",
		Vector3.new(4.2, 2.4, 4.2),
		origin * CFrame.new(-1.6, 2.8, 0),
		COLOR_HUSK_CAB,
		model,
		Enum.Material.Metal
	)
	makePart(
		"Bed",
		Vector3.new(4.8, 0.9, 4.0),
		origin * CFrame.new(2.6, 1.9, 0),
		COLOR_RUST_DARK,
		model,
		Enum.Material.CorrodedMetal
	)
	makePart(
		"Bumper",
		Vector3.new(0.6, 0.8, 4.8),
		origin * CFrame.new(-5.2, 0.9, 0),
		COLOR_STEEL,
		model,
		Enum.Material.Metal
	)

	-- Flattened wheel stubs
	local wheelOffsets = {
		Vector3.new(-3.2, 0.55, 2.5),
		Vector3.new(-3.2, 0.55, -2.5),
		Vector3.new(3.0, 0.55, 2.5),
		Vector3.new(3.0, 0.55, -2.5),
	}
	for i, offset in wheelOffsets do
		local wheel = Instance.new("Part")
		wheel.Name = ("Wheel%d"):format(i)
		wheel.Shape = Enum.PartType.Cylinder
		wheel.Size = Vector3.new(0.9, 2.2, 2.2)
		wheel.CFrame = origin * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90))
		wheel.Anchored = true
		wheel.CanCollide = true
		wheel.Material = Enum.Material.SmoothPlastic
		wheel.Color = COLOR_TIRE
		wheel.Parent = model
	end

	model.PrimaryPart = chassis
	return model
end

function PropsBuilder.build(root: Folder)
	local props = Instance.new("Folder")
	props.Name = "Props"
	props.Parent = root

	local scrapFolder = Instance.new("Folder")
	scrapFolder.Name = "ScrapPiles"
	scrapFolder.Parent = props

	local crateFolder = Instance.new("Folder")
	crateFolder.Name = "Crates"
	crateFolder.Parent = props

	local barrelFolder = Instance.new("Folder")
	barrelFolder.Name = "Barrels"
	barrelFolder.Parent = props

	local pathFolder = Instance.new("Folder")
	pathFolder.Name = "PathToGate"
	pathFolder.Parent = props

	-- Scrap piles: east / south / corners — away from west stalls + spawn
	local scrapSpots: { { name: string, pos: Vector3, yaw: number } } = {
		{ name = "ScrapPile_East", pos = Vector3.new(52, 0, 8), yaw = 18 },
		{ name = "ScrapPile_SouthEast", pos = Vector3.new(38, 0, 48), yaw = -25 },
		{ name = "ScrapPile_South", pos = Vector3.new(-8, 0, 55), yaw = 40 },
		{ name = "ScrapPile_NorthEast", pos = Vector3.new(48, 0, -42), yaw = -12 },
		{ name = "ScrapPile_FarEast", pos = Vector3.new(58, 0, -18), yaw = 55 },
	}
	for _, spot in scrapSpots do
		assert(not isBlocked(spot.pos.X, spot.pos.Z), ("scrap blocked at %s"):format(spot.name))
		buildScrapPile(scrapFolder, spot.name, spot.pos, spot.yaw)
	end

	-- Crates clustered near south/east edges
	local crateSpots: { { name: string, pos: Vector3, yaw: number, scale: number? } } = {
		{ name = "Crate_SouthA", pos = Vector3.new(18, 0, 58), yaw = 12 },
		{ name = "Crate_SouthB", pos = Vector3.new(22, 0, 54), yaw = -8, scale = 0.85 },
		{ name = "Crate_EastA", pos = Vector3.new(62, 0, 28), yaw = 30 },
		{ name = "Crate_EastB", pos = Vector3.new(58, 0, 32), yaw = -15, scale = 1.1 },
		{ name = "Crate_SouthWest", pos = Vector3.new(-40, 0, 52), yaw = 22 },
	}
	for _, spot in crateSpots do
		assert(not isBlocked(spot.pos.X, spot.pos.Z), ("crate blocked at %s"):format(spot.name))
		buildCrate(crateFolder, spot.name, spot.pos, spot.yaw, spot.scale)
	end

	-- Barrels — colorful cartoony drums
	local barrelSpots: { { name: string, pos: Vector3, color: Color3, tipped: boolean? } } = {
		{ name = "Barrel_EastTeal", pos = Vector3.new(46, 0, 22), color = COLOR_BARREL_TEAL },
		{ name = "Barrel_EastYellow", pos = Vector3.new(49, 0, 20), color = COLOR_BARREL_YELLOW },
		{ name = "Barrel_SouthRed", pos = Vector3.new(6, 0, 60), color = COLOR_BARREL_RED, tipped = true },
		{ name = "Barrel_SETeal", pos = Vector3.new(34, 0, 56), color = COLOR_BARREL_TEAL },
		{ name = "Barrel_NEYellow", pos = Vector3.new(55, 0, -36), color = COLOR_BARREL_YELLOW, tipped = true },
		{ name = "Barrel_SWRed", pos = Vector3.new(-36, 0, 48), color = COLOR_BARREL_RED },
	}
	for _, spot in barrelSpots do
		assert(not isBlocked(spot.pos.X, spot.pos.Z), ("barrel blocked at %s"):format(spot.name))
		buildBarrel(barrelFolder, spot.name, spot.pos, spot.color, spot.tipped)
	end

	-- Abandoned vehicle husk — east side, clear of shops/spawn/path
	local huskPos = Vector3.new(42, 0, -8)
	assert(not isBlocked(huskPos.X, huskPos.Z), "vehicle husk blocked")
	buildVehicleHusk(props, huskPos, 118)

	-- Tire stacks + path markers along a soft lane toward the north gate
	-- Offset slightly off center so the walking lane stays open
	local tireSpots: { { name: string, pos: Vector3, count: number, yaw: number } } = {
		{ name = "TireStack_Path1", pos = Vector3.new(-9, 0, -22), count = 3, yaw = 8 },
		{ name = "TireStack_Path2", pos = Vector3.new(9, 0, -38), count = 4, yaw = -6 },
		{ name = "TireStack_Path3", pos = Vector3.new(-10, 0, -55), count = 3, yaw = 14 },
		{ name = "TireStack_GateLeft", pos = Vector3.new(-16, 0, -68), count = 5, yaw = 0 },
		{ name = "TireStack_GateRight", pos = Vector3.new(16, 0, -68), count = 4, yaw = 5 },
	}
	for _, spot in tireSpots do
		-- Tire stacks intentionally sit beside the gate path (outside GATE_PATH_HALF_WIDTH)
		assert(math.abs(spot.pos.X) >= GATE_PATH_HALF_WIDTH, ("tire too centered: %s"):format(spot.name))
		buildTireStack(pathFolder, spot.name, spot.pos, spot.count, spot.yaw)
	end

	local markerSpots: { { name: string, pos: Vector3, yaw: number } } = {
		{ name = "PathMarker_1", pos = Vector3.new(0, 0, -16), yaw = 0 },
		{ name = "PathMarker_2", pos = Vector3.new(0, 0, -32), yaw = 0 },
		{ name = "PathMarker_3", pos = Vector3.new(0, 0, -48), yaw = 0 },
		{ name = "PathMarker_4", pos = Vector3.new(0, 0, -62), yaw = 0 },
	}
	for _, spot in markerSpots do
		buildPathMarker(pathFolder, spot.name, spot.pos, spot.yaw)
	end
end

return PropsBuilder
