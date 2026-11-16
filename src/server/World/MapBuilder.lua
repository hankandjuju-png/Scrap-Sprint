--!strict
--[[
	Procedural Starter Junkyard floor under Workspace.Map.
	Phase 2 Task 2: floor + spawn + landmark placeholders (Sell / Shops / Gate).
	No sell / shop / unlock logic — tags + ProximityPrompt stubs only.
]]

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local MapBuilder = {}

local MAP_NAME = "Map"
local ROOT_NAME = "StarterJunkyard"

-- Compact cartoony junkyard pad (studs)
local FLOOR_SIZE = Vector3.new(160, 2, 160)
local WALL_HEIGHT = 6
local WALL_THICKNESS = 2
local SPAWN_PAD_SIZE = Vector3.new(12, 1, 12)
local LANDMARK_PAD_SIZE = Vector3.new(10, 1, 10)
local LANDMARK_Y = 0.5 -- pad center so top sits on floor (y = 0)

-- Landmark offsets from origin (spawn at 0,0). Keep clear of 12×12 spawn pad.
local SELL_POS = Vector3.new(0, LANDMARK_Y, -22)
local TOOLS_POS = Vector3.new(-20, LANDMARK_Y, -18)
local BACKPACKS_POS = Vector3.new(20, LANDMARK_Y, -18)
-- Gate sits on the north edge, centered
local GATE_WIDTH = 28
local GATE_HEIGHT = 10
local GATE_DEPTH = 3

-- Muted asphalt / weathered concrete (green-brown junkyard)
local COLOR_FLOOR = Color3.fromRGB(78, 82, 70)
local COLOR_WALL = Color3.fromRGB(58, 60, 54)
local COLOR_SPAWN = Color3.fromRGB(96, 92, 78)
-- Bright readable landmark colors
local COLOR_SELL = Color3.fromRGB(80, 200, 90)
local COLOR_TOOLS = Color3.fromRGB(70, 150, 255)
local COLOR_BACKPACKS = Color3.fromRGB(255, 170, 50)
local COLOR_GATE = Color3.fromRGB(45, 40, 38)
local COLOR_GATE_BAR = Color3.fromRGB(90, 70, 55)

local TAG_SELL = "SellPad"
local TAG_SHOP = "ShopPad"
local TAG_GATE = "UnlockGate"

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

--[[
	Remove default Studio/Baseplate leftovers so they don't fight MapBuilder.
	Only touches Workspace-direct Baseplate and SpawnLocation (not Map descendants).
]]
local function clearDefaultWorkspaceJunk()
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end

	for _, child in Workspace:GetChildren() do
		if child:IsA("SpawnLocation") then
			child:Destroy()
		end
	end
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

local function attachBillboard(part: BasePart, text: string, textColor: Color3?)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(200, 48)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 120
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
end

local function attachPromptPlaceholder(part: BasePart, objectText: string, actionText: string)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Prompt"
	prompt.ObjectText = objectText
	prompt.ActionText = actionText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	-- Placeholder only — no server/client handlers yet
	prompt.Enabled = true
	prompt.Parent = part
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
	-- Leave a gap in the north wall where the Area 2 gate sits
	local gapHalf = GATE_WIDTH * 0.5
	local sideWidth = halfX - gapHalf

	-- North wall split around gate gap
	if sideWidth > 0 then
		local northZ = -halfZ - t * 0.5
		local leftCenterX = -gapHalf - sideWidth * 0.5
		local rightCenterX = gapHalf + sideWidth * 0.5
		makeAnchoredPart(
			"WallNorthWest",
			Vector3.new(sideWidth, WALL_HEIGHT, t),
			CFrame.new(leftCenterX, wallY, northZ),
			COLOR_WALL,
			root
		)
		makeAnchoredPart(
			"WallNorthEast",
			Vector3.new(sideWidth, WALL_HEIGHT, t),
			CFrame.new(rightCenterX, wallY, northZ),
			COLOR_WALL,
			root
		)
	end

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

local function buildLandmarkPad(
	root: Folder,
	name: string,
	position: Vector3,
	color: Color3,
	label: string,
	tag: string,
	shopType: string?,
	objectText: string,
	actionText: string
): Part
	local part = makeAnchoredPart(name, LANDMARK_PAD_SIZE, CFrame.new(position), color, root)
	CollectionService:AddTag(part, tag)
	if shopType then
		part:SetAttribute("ShopType", shopType)
	end
	attachBillboard(part, label, Color3.new(1, 1, 1))
	attachPromptPlaceholder(part, objectText, actionText)
	return part
end

local function buildLandmarks(root: Folder)
	local landmarks = Instance.new("Folder")
	landmarks.Name = "Landmarks"
	landmarks.Parent = root

	buildLandmarkPad(
		landmarks,
		"SellStation",
		SELL_POS,
		COLOR_SELL,
		"SELL",
		TAG_SELL,
		nil,
		"Sell Station",
		"Sell"
	)

	buildLandmarkPad(
		landmarks,
		"EquipmentShop",
		TOOLS_POS,
		COLOR_TOOLS,
		"TOOLS",
		TAG_SHOP,
		"Tools",
		"Equipment Shop",
		"Browse"
	)

	buildLandmarkPad(
		landmarks,
		"BackpackShop",
		BACKPACKS_POS,
		COLOR_BACKPACKS,
		"BACKPACKS",
		TAG_SHOP,
		"Backpacks",
		"Backpack Shop",
		"Browse"
	)

	-- Locked Area 2 gate barrier at north edge (visual only)
	local halfZ = FLOOR_SIZE.Z * 0.5
	local gateZ = -halfZ - GATE_DEPTH * 0.5
	local gate = makeAnchoredPart(
		"Area2Gate",
		Vector3.new(GATE_WIDTH, GATE_HEIGHT, GATE_DEPTH),
		CFrame.new(0, GATE_HEIGHT * 0.5, gateZ),
		COLOR_GATE,
		landmarks
	)
	gate.Material = Enum.Material.Metal
	CollectionService:AddTag(gate, TAG_GATE)
	gate:SetAttribute("Locked", true)
	gate:SetAttribute("AreaId", "area_industrial")
	attachBillboard(gate, "INDUSTRIAL SCRAPYARD — LOCKED", Color3.fromRGB(255, 120, 100))
	attachPromptPlaceholder(gate, "Industrial Scrapyard", "Locked")

	-- Simple vertical bars so it reads as a locked gate, not a blank wall
	local barCount = 5
	local barSpacing = GATE_WIDTH / (barCount + 1)
	for i = 1, barCount do
		local x = -GATE_WIDTH * 0.5 + barSpacing * i
		makeAnchoredPart(
			("GateBar%d"):format(i),
			Vector3.new(1, GATE_HEIGHT - 1, 0.6),
			CFrame.new(x, GATE_HEIGHT * 0.5, gateZ - GATE_DEPTH * 0.35),
			COLOR_GATE_BAR,
			landmarks
		)
	end
end

--[[
	Clears and rebuilds Workspace.Map.StarterJunkyard.
	Also strips default Baseplate / Workspace SpawnLocation if present.
	Safe to call once at server start.
]]
function MapBuilder.build()
	clearDefaultWorkspaceJunk()

	local map = ensureMapFolder()
	clearStarter(map)

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = map

	buildFloor(root)
	buildBoundary(root)
	buildSpawn(root)
	buildLandmarks(root)

	print("[ScrapSprint] MapBuilder: StarterJunkyard ready (landmarks)")
end

return MapBuilder
