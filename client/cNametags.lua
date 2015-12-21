-- Created by DaAlpha
class 'Nametags'

function Nametags:__init()
	-- Settings
	self.textSize	= 16	-- pt (Default: 16)
	self.barHeight	= 2		-- px (Default: 2)
	self.maxHealth	= Color(20, 220, 20)
	self.minHealth	= Color(200, 80, 20)

	-- Objects
	self.positions	= {}

	-- Network
	Network:Subscribe("PlayerPositions", self, self.PlayerPositions)

	-- Events
	Events:Subscribe("Render", self, self.Render)
end

function Nametags:PlayerPositions(positions)
	positions[LocalPlayer:GetId()] = nil
	self.positions = positions
end

function Nametags:Render()
	if Game:GetState() ~= GUIState.Game then return end

	local localPos	= LocalPlayer:GetPosition()
	local streamed	= {}

	for p in Client:GetStreamedPlayers() do
		local pos3		= p:GetBonePosition("ragdoll_Head") + Vector3(0, 0.3, 0)
		local color		= p:GetColor()
		local mapPos	= Render:WorldToMinimap(pos3)
		local pos, onsc	= Render:WorldToScreen(pos3)

		Render:FillCircle(mapPos, 6, Color(0, 0, 0, 180))
		Render:FillCircle(mapPos, 5, color)

		if onsc then
			local dist		= localPos:Distance(p:GetPosition())
			local scale		= math.clamp(1 - dist / 1000, 0.75, 1)
			local alpha		= 255 * scale
			local sColor	= Color(0, 0, 0, 180 * scale ^ 2)

			local name		= p:GetName()
			local nameSize	= Render:GetTextSize(name, self.textSize, scale)

			local health	= p:GetHealth()
			local barSize	= Vector2(math.max(nameSize.x, 50 * scale), self.barHeight)
			local barPos	= pos - Vector2(barSize.x / 2, barSize.y)
			local barColor	= math.lerp(self.minHealth, self.maxHealth, health ^ 2)
			barColor.a		= alpha

			Render:FillArea(barPos - Vector2(1, 1), barSize + Vector2(2, 2), sColor)
			Render:FillArea(barPos, Vector2(barSize.x * health, barSize.y), barColor)

			local textPos	= pos - Vector2(nameSize.x / 2, self.barHeight + nameSize.y + 1)
			color.a			= alpha

			Render:DrawText(textPos + Vector2(1, 1), name, sColor, self.textSize, scale)
			Render:DrawText(textPos, name, color, self.textSize, scale)
		end

		streamed[p:GetId()] = true
	end

	for id, data in pairs(self.positions) do
		if not streamed[id] then
			local mapPos = Render:WorldToMinimap(data.pos)

			Render:FillCircle(mapPos, 5, Color(0, 0, 0, 180))
			Render:FillCircle(mapPos, 4, data.color)
		end
	end
end

local nametags = Nametags()
