--!strict
--[[
	Pure display helpers (cash, counts). Safe on client and server.
]]

local Format = {}

function Format.cash(amount: number): string
	local n = math.floor(amount + 0.5)
	local sign = ""
	if n < 0 then
		sign = "-"
		n = -n
	end

	local s = tostring(n)
	local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return "$" .. sign .. formatted
end

function Format.fraction(current: number, max: number): string
	return string.format("%d/%d", math.floor(current), math.floor(max))
end

return Format
