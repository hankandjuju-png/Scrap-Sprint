--!strict
--[[
	Thin client bootstrap. Phase 1: wait for remotes, then print boot line.
	Controllers land in later phases — keep this file thin.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

Remotes.init()

print("[ScrapSprint] client boot")
