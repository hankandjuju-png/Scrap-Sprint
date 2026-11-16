--!strict
--[[
	Per-player cooldown helper for inbound remotes. Server services should call
	`allow` before trusting Request* payloads.
]]

local RateLimit = {}

export type Bucket = {
	_last: { [number]: number },
	_cooldown: number,
}

function RateLimit.new(cooldownSeconds: number): Bucket
	return {
		_last = {},
		_cooldown = cooldownSeconds,
	}
end

function RateLimit.allow(bucket: Bucket, player: Player): boolean
	local now = os.clock()
	local userId = player.UserId
	local last = bucket._last[userId]
	if last ~= nil and (now - last) < bucket._cooldown then
		return false
	end
	bucket._last[userId] = now
	return true
end

function RateLimit.clear(bucket: Bucket, player: Player)
	bucket._last[player.UserId] = nil
end

return RateLimit
