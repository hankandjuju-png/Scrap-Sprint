--!strict
--[[
	Phase 2 Task 3: starter junkyard lighting + mild outdoor haze.
	Cartoony scrapyard daytime — warm, readable, not grimdark.
]]

local Lighting = game:GetService("Lighting")

local Atmosphere = {}

local function ensureAtmosphere()
	local existing = Lighting:FindFirstChildOfClass("Atmosphere")
	if existing then
		return existing
	end
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "Atmosphere"
	atmosphere.Parent = Lighting
	return atmosphere
end

--[[
	Applies once at map build. Safe to call again (idempotent overwrite).
]]
function Atmosphere.apply()
	-- Late-afternoon scrapyard sun: warm, bright, readable colors
	Lighting.ClockTime = 15.5
	Lighting.Brightness = 2.35
	Lighting.Ambient = Color3.fromRGB(118, 128, 142)
	Lighting.OutdoorAmbient = Color3.fromRGB(148, 155, 168)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 214, 170)
	Lighting.ColorShift_Bottom = Color3.fromRGB(95, 110, 88)
	Lighting.EnvironmentDiffuseScale = 0.55
	Lighting.EnvironmentSpecularScale = 0.35
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.35
	Lighting.GeographicLatitude = 28

	local fog = ensureAtmosphere()
	fog.Density = 0.22
	fog.Offset = 0.12
	fog.Color = Color3.fromRGB(198, 205, 215)
	fog.Decay = Color3.fromRGB(170, 155, 130)
	fog.Glare = 0.12
	fog.Haze = 1.4
end

return Atmosphere
