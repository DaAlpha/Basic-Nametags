-- Created by DaAlpha
class 'Nametags'

function Nametags:__init()
	-- Settings
	self.interval = 2	-- Seconds (Default: 2)

	-- Objects
	self.timer = Timer()

	-- Events
	Events:Subscribe("PostTick", self, self.PostTick)
end

function Nametags:PostTick()
	if self.timer:GetSeconds() > self.interval then
		local positions = {}
		for p in Server:GetPlayers() do
			positions[p:GetId()] = {
				pos		= p:GetPosition(),
				color	= p:GetColor()
				}
		end

		Network:Broadcast("PlayerPositions", positions)
		self.timer:Restart()
	end
end

local nametags = Nametags()
