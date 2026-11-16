--!strict
--[[
	Procedural Starter Junkyard floor under Workspace.Map.
	Phase 2 Task 2: floor + spawn + scrapyard stall landmarks + gate.
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

-- Stall footprint (local: open front along -Z, back toward +Z)
local STALL_WIDTH = 12
local STALL_DEPTH = 8
local POST_THICK = 0.85
local POST_HEIGHT = 8
local COUNTER_HEIGHT = 3.1
local COUNTER_THICK = 0.7
local ROOF_OVERHANG = 1.2
local ROOF_FRONT_Y = 9.2
local ROOF_BACK_Y = 7.0
local PAD_DIAMETER = 10
local PAD_THICK = 0.35
local PAD_FRONT_OFFSET = STALL_DEPTH * 0.5 + PAD_DIAMETER * 0.45

-- Side-edge placement: stalls on left/right, spawn stays clear in the middle
local EDGE_INSET = 10 -- stall center distance inward from floor edge
local HALF_X = FLOOR_SIZE.X * 0.5
local WEST_X = -(HALF_X - EDGE_INSET)
local EAST_X = HALF_X - EDGE_INSET
-- West: Tools (north) + Sell (south). East: Backpacks. Gate stays north.
local TOOLS_Z = -28
local SELL_Z = 28
local BACKPACKS_Z = 0

-- Gate sits on the north edge, centered
local GATE_WIDTH = 28
local GATE_HEIGHT = 10
local GATE_DEPTH = 3

-- Floor / boundary
local COLOR_FLOOR = Color3.fromRGB(78, 82, 70)
local COLOR_WALL = Color3.fromRGB(58, 60, 54)
local COLOR_SPAWN = Color3.fromRGB(96, 92, 78)

-- Scrapyard stall palette (rusted metal / dirty tarp — not clean carnival wood)
local COLOR_POST = Color3.fromRGB(92, 58, 38)
local COLOR_POST_DARK = Color3.fromRGB(62, 42, 32)
local COLOR_SLAT_A = Color3.fromRGB(78, 52, 36)
local COLOR_SLAT_B = Color3.fromRGB(105, 72, 48)
local COLOR_COUNTER = Color3.fromRGB(70, 68, 62)
local COLOR_ROOF_DIRTY = Color3.fromRGB(88, 84, 70)
local COLOR_ROOF_RUST = Color3.fromRGB(120, 68, 42)
local COLOR_ROOF_OLIVE = Color3.fromRGB(70, 78, 52)
local COLOR_PAD_BASE = Color3.fromRGB(42, 40, 36)
local COLOR_GATE = Color3.fromRGB(45, 40, 38)
local COLOR_GATE_BAR = Color3.fromRGB(90, 70, 55)

-- Accent glows / labels per landmark
local ACCENT_SELL = Color3.fromRGB(90, 210, 95)
local ACCENT_TOOLS = Color3.fromRGB(90, 165, 255)
local ACCENT_BACKPACKS = Color3.fromRGB(255, 165, 55)

local TAG_SELL = "SellPad"
local TAG_SHOP = "ShopPad"
local TAG_GATE = "UnlockGate"

export type StallConfig = {
	name: string,
	position: Vector3,
	yawDegrees: number, -- local -Z (open front) → world facing
	label: string,
	labelColor: Color3,
	accent: Color3,
	tag: string,
	shopType: string?,
	objectText: string,
	actionText: string,
	roofStripeA: Color3,
	roofStripeB: Color3,
}

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

local function makePart(
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	parent: Instance,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.Material = material or Enum.Material.Concrete
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function attachBillboard(part: BasePart, text: string, textColor: Color3, studsOffset: Vector3?)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(220, 56)
	billboard.StudsOffset = studsOffset or Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 140
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0.15
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
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	-- Placeholder only — no server/client handlers yet
	prompt.Enabled = true
	prompt.Parent = part
end

local function buildFloor(root: Folder)
	local halfY = FLOOR_SIZE.Y * 0.5
	makePart("Floor", FLOOR_SIZE, CFrame.new(0, -halfY, 0), COLOR_FLOOR, root)
end

local function buildBoundary(root: Folder)
	local halfX = FLOOR_SIZE.X * 0.5
	local halfZ = FLOOR_SIZE.Z * 0.5
	local wallY = WALL_HEIGHT * 0.5
	local t = WALL_THICKNESS
	local gapHalf = GATE_WIDTH * 0.5
	local sideWidth = halfX - gapHalf

	if sideWidth > 0 then
		local northZ = -halfZ - t * 0.5
		local leftCenterX = -gapHalf - sideWidth * 0.5
		local rightCenterX = gapHalf + sideWidth * 0.5
		makePart(
			"WallNorthWest",
			Vector3.new(sideWidth, WALL_HEIGHT, t),
			CFrame.new(leftCenterX, wallY, northZ),
			COLOR_WALL,
			root
		)
		makePart(
			"WallNorthEast",
			Vector3.new(sideWidth, WALL_HEIGHT, t),
			CFrame.new(rightCenterX, wallY, northZ),
			COLOR_WALL,
			root
		)
	end

	makePart(
		"WallSouth",
		Vector3.new(FLOOR_SIZE.X + t * 2, WALL_HEIGHT, t),
		CFrame.new(0, wallY, halfZ + t * 0.5),
		COLOR_WALL,
		root
	)
	makePart(
		"WallEast",
		Vector3.new(t, WALL_HEIGHT, FLOOR_SIZE.Z),
		CFrame.new(halfX + t * 0.5, wallY, 0),
		COLOR_WALL,
		root
	)
	makePart(
		"WallWest",
		Vector3.new(t, WALL_HEIGHT, FLOOR_SIZE.Z),
		CFrame.new(-halfX - t * 0.5, wallY, 0),
		COLOR_WALL,
		root
	)
end

local function buildSpawn(root: Folder)
	makePart(
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
	Open-front scrap stall (reference silhouette): corner posts, counter,
	side/back slats, slanted striped roof, glowing stand pad in front.
	InteractionPad carries CollectionService tag + ProximityPrompt stub.
]]
local function buildScrapStall(parent: Instance, config: StallConfig): Model
	local model = Instance.new("Model")
	model.Name = config.name
	model.Parent = parent

	local origin = CFrame.new(config.position) * CFrame.Angles(0, math.rad(config.yawDegrees), 0)
	local halfW = STALL_WIDTH * 0.5
	local halfD = STALL_DEPTH * 0.5
	local postInset = POST_THICK * 0.5

	local function localPart(
		name: string,
		size: Vector3,
		localCf: CFrame,
		color: Color3,
		material: Enum.Material?
	): Part
		return makePart(name, size, origin * localCf, color, model, material)
	end

	-- Four rusted corner girders
	local postY = POST_HEIGHT * 0.5
	local corners: { { name: string, x: number, z: number } } = {
		{ name = "PostFL", x = -halfW + postInset, z = -halfD + postInset },
		{ name = "PostFR", x = halfW - postInset, z = -halfD + postInset },
		{ name = "PostBL", x = -halfW + postInset, z = halfD - postInset },
		{ name = "PostBR", x = halfW - postInset, z = halfD - postInset },
	}
	for _, c in corners do
		localPart(
			c.name,
			Vector3.new(POST_THICK, POST_HEIGHT, POST_THICK),
			CFrame.new(c.x, postY, c.z),
			COLOR_POST,
			Enum.Material.CorrodedMetal
		)
	end

	-- Front counter beam (waist height)
	localPart(
		"Counter",
		Vector3.new(STALL_WIDTH - POST_THICK * 1.5, COUNTER_THICK, 1.4),
		CFrame.new(0, COUNTER_HEIGHT, -halfD + 0.9),
		COLOR_COUNTER,
		Enum.Material.Metal
	)

	-- Side + back horizontal scrap slats (3 each)
	local slatThickness = 0.45
	local slatDepth = STALL_DEPTH - POST_THICK
	local slatHeights = { 1.6, 3.4, 5.2 }
	for i, y in slatHeights do
		local color = if i % 2 == 0 then COLOR_SLAT_B else COLOR_SLAT_A
		localPart(
			("SlatLeft%d"):format(i),
			Vector3.new(slatThickness, 0.55, slatDepth),
			CFrame.new(-halfW + postInset, y, 0),
			color,
			Enum.Material.CorrodedMetal
		)
		localPart(
			("SlatRight%d"):format(i),
			Vector3.new(slatThickness, 0.55, slatDepth),
			CFrame.new(halfW - postInset, y, 0),
			color,
			Enum.Material.CorrodedMetal
		)
		localPart(
			("SlatBack%d"):format(i),
			Vector3.new(STALL_WIDTH - POST_THICK, 0.55, slatThickness),
			CFrame.new(0, y, halfD - postInset),
			if i == 2 then COLOR_POST_DARK else color,
			Enum.Material.Metal
		)
	end

	-- Slanted corrugated / dirty-tarp roof (stripes along width)
	local stripeCount = 5
	local roofWidth = STALL_WIDTH + ROOF_OVERHANG * 2
	local roofDepth = STALL_DEPTH + ROOF_OVERHANG
	local stripeW = roofWidth / stripeCount
	local pitch = math.atan2(ROOF_FRONT_Y - ROOF_BACK_Y, roofDepth)
	local roofMidY = (ROOF_FRONT_Y + ROOF_BACK_Y) * 0.5
	local roofThickness = 0.35
	for i = 1, stripeCount do
		local x = -roofWidth * 0.5 + stripeW * (i - 0.5)
		local stripeColor = if i % 2 == 1 then config.roofStripeA else config.roofStripeB
		-- Slight dent: alternate material / tiny Y jitter
		local dent = if i % 2 == 0 then 0.08 else 0
		localPart(
			("RoofStripe%d"):format(i),
			Vector3.new(stripeW - 0.05, roofThickness, roofDepth),
			CFrame.new(x, roofMidY + dent, ROOF_OVERHANG * 0.15) * CFrame.Angles(pitch, 0, 0),
			stripeColor,
			if i % 2 == 1 then Enum.Material.Metal else Enum.Material.CorrodedMetal
		)
	end

	-- Oil-stained glowing stand zone in front of counter (interaction target)
	local pad = Instance.new("Part")
	pad.Name = "InteractionPad"
	pad.Shape = Enum.PartType.Cylinder
	pad.Size = Vector3.new(PAD_THICK, PAD_DIAMETER, PAD_DIAMETER)
	-- Cylinder axis is X; lay flat and place in front along local -Z
	pad.CFrame = origin * CFrame.new(0, PAD_THICK * 0.5, -PAD_FRONT_OFFSET) * CFrame.Angles(0, 0, math.rad(90))
	pad.Anchored = true
	pad.CanCollide = false
	pad.Material = Enum.Material.Neon
	pad.Color = config.accent
	pad.Transparency = 0.35
	pad.TopSurface = Enum.SurfaceType.Smooth
	pad.BottomSurface = Enum.SurfaceType.Smooth
	pad.Parent = model

	local padRing = Instance.new("Part")
	padRing.Name = "PadStain"
	padRing.Shape = Enum.PartType.Cylinder
	padRing.Size = Vector3.new(PAD_THICK * 0.6, PAD_DIAMETER + 1.4, PAD_DIAMETER + 1.4)
	padRing.CFrame = origin * CFrame.new(0, PAD_THICK * 0.25, -PAD_FRONT_OFFSET) * CFrame.Angles(0, 0, math.rad(90))
	padRing.Anchored = true
	padRing.CanCollide = false
	padRing.Material = Enum.Material.Concrete
	padRing.Color = COLOR_PAD_BASE
	padRing.Transparency = 0.15
	padRing.TopSurface = Enum.SurfaceType.Smooth
	padRing.BottomSurface = Enum.SurfaceType.Smooth
	padRing.Parent = model

	local light = Instance.new("PointLight")
	light.Name = "PadGlow"
	light.Brightness = 1.4
	light.Range = 14
	light.Color = config.accent
	light.Parent = pad

	-- Unrotated anchor so the floating label sits above the roof cleanly
	local labelAnchor = localPart(
		"LabelAnchor",
		Vector3.new(0.4, 0.4, 0.4),
		CFrame.new(0, ROOF_FRONT_Y + 1.5, -1),
		config.accent,
		Enum.Material.SmoothPlastic
	)
	labelAnchor.Transparency = 1
	labelAnchor.CanCollide = false
	attachBillboard(labelAnchor, config.label, config.labelColor, Vector3.new(0, 2, 0))

	CollectionService:AddTag(pad, config.tag)
	if config.shopType then
		pad:SetAttribute("ShopType", config.shopType)
	end
	attachPromptPlaceholder(pad, config.objectText, config.actionText)

	local primary = model:FindFirstChild("Counter")
	if primary and primary:IsA("BasePart") then
		model.PrimaryPart = primary
	end

	return model
end

local function buildGate(landmarks: Folder)
	local halfZ = FLOOR_SIZE.Z * 0.5
	local gateZ = -halfZ - GATE_DEPTH * 0.5
	local gate = makePart(
		"Area2Gate",
		Vector3.new(GATE_WIDTH, GATE_HEIGHT, GATE_DEPTH),
		CFrame.new(0, GATE_HEIGHT * 0.5, gateZ),
		COLOR_GATE,
		landmarks,
		Enum.Material.Metal
	)
	CollectionService:AddTag(gate, TAG_GATE)
	gate:SetAttribute("Locked", true)
	gate:SetAttribute("AreaId", "area_industrial")
	attachBillboard(gate, "INDUSTRIAL SCRAPYARD — LOCKED", Color3.fromRGB(255, 120, 100), Vector3.new(0, 2, 0))
	attachPromptPlaceholder(gate, "Industrial Scrapyard", "Locked")

	local barCount = 5
	local barSpacing = GATE_WIDTH / (barCount + 1)
	for i = 1, barCount do
		local x = -GATE_WIDTH * 0.5 + barSpacing * i
		makePart(
			("GateBar%d"):format(i),
			Vector3.new(1, GATE_HEIGHT - 1, 0.6),
			CFrame.new(x, GATE_HEIGHT * 0.5, gateZ - GATE_DEPTH * 0.35),
			COLOR_GATE_BAR,
			landmarks,
			Enum.Material.CorrodedMetal
		)
	end
end

local function buildLandmarks(root: Folder)
	local landmarks = Instance.new("Folder")
	landmarks.Name = "Landmarks"
	landmarks.Parent = root

	-- West edge (−X): open front faces center (+X). Local front is −Z → yaw −90°.
	buildScrapStall(landmarks, {
		name = "EquipmentShop",
		position = Vector3.new(WEST_X, 0, TOOLS_Z),
		yawDegrees = -90,
		label = "TOOLS",
		labelColor = ACCENT_TOOLS,
		accent = ACCENT_TOOLS,
		tag = TAG_SHOP,
		shopType = "Tools",
		objectText = "Equipment Shop",
		actionText = "Browse",
		roofStripeA = COLOR_ROOF_OLIVE,
		roofStripeB = Color3.fromRGB(55, 72, 95),
	})

	buildScrapStall(landmarks, {
		name = "SellStation",
		position = Vector3.new(WEST_X, 0, SELL_Z),
		yawDegrees = -90,
		label = "SELL",
		labelColor = ACCENT_SELL,
		accent = ACCENT_SELL,
		tag = TAG_SELL,
		shopType = nil,
		objectText = "Sell Station",
		actionText = "Sell",
		roofStripeA = COLOR_ROOF_DIRTY,
		roofStripeB = Color3.fromRGB(55, 95, 58),
	})

	-- East edge (+X): open front faces center (−X). Local front −Z → yaw +90°.
	buildScrapStall(landmarks, {
		name = "BackpackShop",
		position = Vector3.new(EAST_X, 0, BACKPACKS_Z),
		yawDegrees = 90,
		label = "BACKPACKS",
		labelColor = ACCENT_BACKPACKS,
		accent = ACCENT_BACKPACKS,
		tag = TAG_SHOP,
		shopType = "Backpacks",
		objectText = "Backpack Shop",
		actionText = "Browse",
		roofStripeA = COLOR_ROOF_RUST,
		roofStripeB = Color3.fromRGB(95, 78, 48),
	})

	buildGate(landmarks)
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
