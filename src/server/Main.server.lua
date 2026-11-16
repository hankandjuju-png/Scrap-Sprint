--!strict
--[[
	Thin server bootstrap. Remotes first, then starter map, then boot print.
	Do not add gameplay systems here until their phase is approved.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

Remotes.init()

local MapBuilder = require(script.Parent:WaitForChild("World"):WaitForChild("MapBuilder"))
MapBuilder.build()

print("[ScrapSprint] server boot")
