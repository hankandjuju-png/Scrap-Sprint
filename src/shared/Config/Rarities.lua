--!strict
--[[
	Rarity weight / display stubs for collectibles.
]]

return {
	Order = { "common", "uncommon", "rare", "epic", "legendary", "mythical" },
	ById = {
		common = { id = "common", weight = 60, color = Color3.fromRGB(180, 180, 180) },
		uncommon = { id = "uncommon", weight = 25, color = Color3.fromRGB(80, 200, 120) },
		rare = { id = "rare", weight = 10, color = Color3.fromRGB(80, 140, 255) },
		epic = { id = "epic", weight = 4, color = Color3.fromRGB(180, 80, 255) },
		legendary = { id = "legendary", weight = 0.9, color = Color3.fromRGB(255, 180, 40) },
		mythical = { id = "mythical", weight = 0.1, color = Color3.fromRGB(255, 60, 120) },
	},
}
