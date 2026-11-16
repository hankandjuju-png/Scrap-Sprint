--!strict
--[[
	Shared type aliases for Scrap Sprint. ProfileV1 matches the master plan;
	no DataStore load/save yet — stubs only.
]]

export type InventoryEntry = {
	id: string,
	rarity: string?,
}

export type ProfileSettings = {
	music: boolean,
	sfx: boolean,
}

export type DailyStub = {
	lastClaimDay: number,
	streak: number,
}

export type ProfileV1 = {
	schemaVersion: number,
	cash: number,
	totalCashEarned: number,
	totalCollected: number,
	toolId: string,
	backpackId: string,
	inventory: { InventoryEntry },
	discoveries: { [string]: boolean },
	unlockedAreas: { string },
	settings: ProfileSettings,
	-- reserved (not used in MVP gameplay)
	rebirths: number,
	achievements: { [string]: boolean },
	daily: DailyStub,
}

return {}
