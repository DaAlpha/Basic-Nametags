-- Created by DaAlpha
class 'Nametags'

function Nametags:__init()
  -- Settings
  self.textSize   = 16  -- pt (Default: 16)
  self.barHeight  = 2   -- px (Default: 2)
  self.maxHealth  = Color(20, 220, 20)
  self.minHealth  = Color(200, 80, 20)
  self.command    = "/minimap"

  -- Objects
  self.miniblips  = true

  -- Events
  Events:Subscribe("Render", self, self.Render)
  Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
end

function Nametags:Render()
  if Game:GetState() ~= GUIState.Game then return end

  local localPos = LocalPlayer:GetPosition()

  -- Draw streamed players
  for p in Client:GetStreamedPlayers() do
    local pos3      = p:GetBonePosition("ragdoll_Head") + Vector3(0, 0.3, 0)
    local color     = p:GetColor()
    local mapPos    = Render:WorldToMinimap(pos3)
    local pos, onsc = Render:WorldToScreen(pos3)

    -- Minimap
    Render:FillCircle(mapPos, 6, Color(0, 0, 0, 180))
    Render:FillCircle(mapPos, 5, color)

    -- Tag
    if onsc then
      local dist    = localPos:Distance(p:GetPosition())
      local scale   = math.clamp(1 - dist / 1000, 0.75, 1)
      local alpha   = 255 * scale
      local sColor  = Color(0, 0, 0, 180 * scale ^ 2)

      local name      = p:GetName()
      local nameSize  = Render:GetTextSize(name, self.textSize, scale)

      local health    = p:GetHealth()
      local barSize   = Vector2(math.max(nameSize.x, 50 * scale), self.barHeight)
      local barPos    = pos - Vector2(barSize.x / 2, barSize.y)
      local barColor  = math.lerp(self.minHealth, self.maxHealth, health ^ 2)
      barColor.a      = alpha

      -- Healthbar
      Render:FillArea(barPos - Vector2(1, 1), barSize + Vector2(2, 2), sColor)
      Render:FillArea(barPos, Vector2(barSize.x * health, barSize.y), barColor)

      local textPos = pos - Vector2(nameSize.x / 2 + 1, self.barHeight + nameSize.y + 1)
      color.a = alpha

      -- Name
      Render:DrawText(textPos + Vector2(1, 1), name, sColor, self.textSize, scale)
      Render:DrawText(textPos, name, color, self.textSize, scale)
    end
  end

  -- Draw non-streamed minimap blips
  if self.miniblips then
    for p in Client:GetPlayers() do
      if not IsValid(p, true) and p:GetValue("Position") then
        local mapPos = Render:WorldToMinimap(p:GetValue("Position"))

        Render:FillCircle(mapPos, 5, Color(0, 0, 0, 180))
        Render:FillCircle(mapPos, 4, p:GetColor())
      end
    end
  end
end

function Nametags:LocalPlayerChat(args)
  if args.text:lower() ~= self.command then return end

  self.miniblips = not self.miniblips

  Network:Send("ToggleMinimap", self.miniblips)

  if self.miniblips then
    Chat:Print("Minimap blips enabled.", Color.Lime)
  else
    Chat:Print("Minimap blips disabled.", Color.Red)
  end
  return false
end

Nametags()
