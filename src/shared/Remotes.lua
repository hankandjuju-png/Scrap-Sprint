--!strict
--[[
	Creates MVP remotes under ReplicatedStorage.ScrapSprintRemotes (server),
	or waits for them (client). Rate-limit every inbound remote in services.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "ScrapSprintRemotes"

local REMOTE_EVENTS = {
	-- server → client
	"ProfileLoaded",
	"ProfileUpdated",
	"CollectResult",
	"SellResult",
	"ShopResult",
	"Notify",
	"BackpackFull",
	-- client → server
	"RequestCollect",
	"RequestSell",
	"RequestPurchase",
	"RequestEquipTool",
}

local REMOTE_FUNCTIONS = {
	"GetShopCatalog",
}

local function getOrCreateFolder(): Folder
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if existing and existing:IsA("Folder") then
		return existing
	end

	if RunService:IsServer() then
		local folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
		return folder
	end

	local waited = ReplicatedStorage:WaitForChild(FOLDER_NAME, 30)
	assert(waited and waited:IsA("Folder"), "Missing remotes folder: " .. FOLDER_NAME)
	return waited
end

local function ensureRemoteEvent(folder: Folder, name: string): RemoteEvent
	local child = folder:FindFirstChild(name)
	if child and child:IsA("RemoteEvent") then
		return child
	end
	if child then
		child:Destroy()
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

local function ensureRemoteFunction(folder: Folder, name: string): RemoteFunction
	local child = folder:FindFirstChild(name)
	if child and child:IsA("RemoteFunction") then
		return child
	end
	if child then
		child:Destroy()
	end
	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = folder
	return remote
end

local function waitForRemote(folder: Folder, name: string, className: string): Instance
	local child = folder:FindFirstChild(name)
	if child and child.ClassName == className then
		return child
	end
	local waited = folder:WaitForChild(name, 30)
	assert(waited and waited.ClassName == className, "Missing remote: " .. name)
	return waited
end

--- Server: create all remotes. Client: wait until the folder and remotes exist.
function Remotes.init(): Folder
	local folder = getOrCreateFolder()

	if RunService:IsServer() then
		for _, name in REMOTE_EVENTS do
			ensureRemoteEvent(folder, name)
		end
		for _, name in REMOTE_FUNCTIONS do
			ensureRemoteFunction(folder, name)
		end
	else
		for _, name in REMOTE_EVENTS do
			waitForRemote(folder, name, "RemoteEvent")
		end
		for _, name in REMOTE_FUNCTIONS do
			waitForRemote(folder, name, "RemoteFunction")
		end
	end

	return folder
end

function Remotes.getEvent(name: string): RemoteEvent
	local folder = getOrCreateFolder()
	local remote = folder:FindFirstChild(name)
	if not remote or not remote:IsA("RemoteEvent") then
		remote = waitForRemote(folder, name, "RemoteEvent")
	end
	assert(remote:IsA("RemoteEvent"), "Missing RemoteEvent: " .. name)
	return remote
end

function Remotes.getFunction(name: string): RemoteFunction
	local folder = getOrCreateFolder()
	local remote = folder:FindFirstChild(name)
	if not remote or not remote:IsA("RemoteFunction") then
		remote = waitForRemote(folder, name, "RemoteFunction")
	end
	assert(remote:IsA("RemoteFunction"), "Missing RemoteFunction: " .. name)
	return remote
end

return Remotes
