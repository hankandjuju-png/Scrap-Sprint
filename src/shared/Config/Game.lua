--!strict
--[[
	Global game limits. Tune numbers here only — no hardcoded gameplay magic.
]]

return {
	MaxPlayers = 12,
	AutosaveSeconds = 60,
	-- Collectible soft caps (stubs until CollectibleService)
	MaxCollectiblesPerZone = 25,
	MaxCollectiblesPerServer = 120,
	CollectRespawnSeconds = 8,
}
