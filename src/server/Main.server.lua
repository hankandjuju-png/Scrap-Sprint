--!strict
--[[
	Thin server bootstrap. Phase 1: ensure remotes exist, then print boot line.
	Do not add gameplay systems here until their phase is approved.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

Remotes.init()

print("[ScrapSprint] server boot")
