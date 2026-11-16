--!strict
--[[
	Procedural Starter Junkyard floor under Workspace.Map.
	Phase 2 Task 1 only: flat playable ground, spawn, low boundary.
	No sell / shop / gate landmarks.
]]

local Workspace = game:GetService("Workspace")

local MapBuilder = {}

local MAP_NAME = "Map"
local ROOT_NAME = "StarterJunkyard"

-- Compact cartoony junkyard pad (studs)
local FLOOR_SIZE = Vector3.new(160, 2, 160)
local WALL_HEIGHT = 6
local WALL_THICKNESS = 2
local SPAWN_PAD_SIZE = Vector3.new(12, 1, 12)

-- Muted asphalt / weathered concrete (green-brown junkyard)
local COLOR_FLOOR = Color3.fromRGB(78, 82, 70)
local COLOR_WALL = Color3.fromRGB(58, 60, 54)
local COLOR_SPAWN = Color3.fromRGB(96, 92, 78)

local function ensureMapFolder(): Folder
	local existing = Workspace:FindFirstChild(MAP_NAME)
	if existing and existing:IsA("Folder") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = MAP_NAME
	folder.Parent = Workspace
	return folder
end

local function clearStarter(map: Folder)
	local previous = map:FindFirstChild(ROOT_NAME)
	if previous then
		previous:Destroy()
	end
end

local function makeAnchoredPart(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.Material = Enum.Material.Concrete
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function buildFloor(root: Folder)
	-- Top of floor at y = 0 so characters stand on solid ground near origin
	local halfY = FLOOR_SIZE.Y * 0.5
	makeAnchoredPart(
		"Floor",
		FLOOR_SIZE,
		CFrame.new(0, -halfY, 0),
		COLOR_FLOOR,
		root
	)
end

local function buildBoundary(root: Folder)
	local halfX = FLOOR_SIZE.X * 0.5
	local halfZ = FLOOR_SIZE.Z * 0.5
	local wallY = WALL_HEIGHT * 0.5
	local t = WALL_THICKNESS

	makeAnchoredPart(
		"WallNorth",
		Vector3.new(FLOOR_SIZE.X + t * 2, WALL_HEIGHT, t),
		CFrame.new(0, wallY, -halfZ - t * 0.5),
		COLOR_WALL,
		root
	)
	makeAnchoredPart(
		"WallSouth",
		Vector3.new(FLOOR_SIZE.X + t * 2, WALL_HEIGHT, t),
		CFrame.new(0, wallY, halfZ + t * 0.5),
		COLOR_WALL,
		root
	)
	makeAnchoredPart(
		"WallEast",
		Vector3.new(t, WALL_HEIGHT, FLOOR_SIZE.Z),
		CFrame.new(halfX + t * 0.5, wallY, 0),
		COLOR_WALL,
		root
	)
	makeAnchoredPart(
		"WallWest",
		Vector3.new(t, WALL_HEIGHT, FLOOR_SIZE.Z),
		CFrame.new(-halfX - t * 0.5, wallY, 0),
		COLOR_WALL,
		root
	)
end

local function buildSpawn(root: Folder)
	-- Slight raised pad near center so spawn is visually clear
	makeAnchoredPart(
		"SpawnPad",
		SPAWN_PAD_SIZE,
		CFrame.new(0, SPAWN_PAD_SIZE.Y * 0.5, 0),
		COLOR_SPAWN,
		root
	)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.new(0, SPAWN_PAD_SIZE.Y + 0.5, 0)
	spawn.Anchored = true
	spawn.Material = Enum.Material.Concrete
	spawn.Color = Color3.fromRGB(110, 105, 88)
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Duration = 0
	spawn.Neutral = true
	spawn.Parent = root
end

--[[
	Clears and rebuilds Workspace.Map.StarterJunkyard.
	Safe to call once at server start.
]]
function MapBuilder.build()
	local map = ensureMapFolder()
	clearStarter(map)

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = map

	buildFloor(root)
	buildBoundary(root)
	buildSpawn(root)

	print("[ScrapSprint] MapBuilder: StarterJunkyard ready")
end

return MapBuilder
