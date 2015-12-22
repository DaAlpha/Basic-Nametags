-- Created by DaAlpha
class 'Nametags'

function Nametags:__init()
	-- Settings
	self.interval = 2	-- Seconds (Default: 2)

	-- Objects
	self.timer		= Timer()
	self.disabled	= {}

	-- Network
	Network:Subscribe("ToggleMinimap", self, self.ToggleMinimap)

	-- Events
	Events:Subscribe("PostTick", self, self.PostTick)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
end

function Nametags:ToggleMinimap(state, sender)
	self.disabled[sender:GetId()] = not state or nil
end

function Nametags:PostTick()
	if self.timer:GetSeconds() > self.interval then
		local players = {}
		local positions = {}

		for p in Server:GetPlayers() do
			local id = p:GetId()

			if not self.disabled[id] then
				positions[p:GetId()] = {
					pos		= p:GetPosition(),
					color	= p:GetColor()
					}

				table.insert(players, p)
			end
		end

		Network:SendToPlayers(players, "PlayerPositions", positions)
		self.timer:Restart()
	end
end

function Nametags:PlayerQuit(args)
	self.disabled[args.player:GetId()] = nil
end

local nametags = Nametags()
