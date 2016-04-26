require "/scripts/vec2.lua"
require "/interface/games/fossilgame/sprite.lua"

Tool = {}
Tool.name = "Outils"
Tool.area = {{0,0}}
Tool.size = {1,1}
Tool.sprite = Sprite:new("/interface/games/fossilgame/images/brushtool.png", {16,16}, {2,1}, 2)
Tool.sprite.animationCycle = 0.1

function Tool:new(tileLevel, uses)
  local newTool = {
    level = tileLevel,
    uses = uses or -1,
    animationTimer = 0,
    triggerPosition = {0,0}
  }
  setmetatable(newTool, extend(self))
  return newTool
end

function Tool:trigger()
end

function Tool:release()
end

function Tool:update(dt)
  if self.animationTimer > 0 then
    self.animationTimer = self.animationTimer - dt
  end
  if self.sound and self.playSound then
    console.playSound(self.sound, 0, 1.0)
    self.playSound = false
  end
end

function Tool:triggerAction()
  self.animationTimer = self.animationCycle
  self.triggerPosition = mousePosition()
  self.playSound = true
end

function Tool:hoverTiles()
  local tiles = {}
  for _,offset in ipairs(self.area) do
    local screenOffset = {offset[1] * self.level.tileSize, offset[2] * self.level.tileSize}
    local screenTilePos = vec2.add(self:position(), screenOffset)
    local tilePos = self.level:tilePosition(screenTilePos)
    if tilePos == false then return {} end
    table.insert(tiles, tilePos)
  end
  return tiles
end

function Tool:tileArea(tilePosition)
  local area = {}
  local offset = {0,0}
  for _,tile in pairs(self.area) do
    tile = {math.floor(tile[1]), math.floor(tile[2])}
    if tile[1] < -offset[1] then offset[1] = -tile[1] end
    if tile[2] < -offset[2] then offset[2] = -tile[2] end
    table.insert(area, tile)
  end
  for k,tile in pairs(area) do
    area[k] = vec2.add(tile, offset)
  end
  return area
end

function Tool:position()
  if self.animationTimer > 0 then
    return self.triggerPosition
  else
    return mousePosition()
  end
end

function Tool:canUse()
  return self.uses > 0 or self.uses == -1
end

function Tool:draw()
  if self:canUse() then
    for _,tile in ipairs(self:hoverTiles()) do
      local screenX = tile[1] * self.level.tileSize + self.level.position[1]
      local screenY = tile[2] * self.level.tileSize + self.level.position[2]
      console.canvasDrawRect({screenX, screenY, screenX + self.level.tileSize, screenY + self.level.tileSize}, {255, 255, 255, 100})
    end
  end

  if self.sprite then
    if self.animationTimer > 0 then
      self.sprite:setCell(1)
    else
      self.sprite:setCell(0)
    end
    self.sprite:draw(self:position())
  end
end

BrushTool = Tool:new()
BrushTool.name = "Brosse"
BrushTool.animationCycle = 0.1
BrushTool.sprite = Sprite:new("/interface/games/fossilgame/images/brushtool.png", {16,16}, {2,1}, 2)
BrushTool.sprite.origin = {8,8}
BrushTool.sprite.scale = 2
BrushTool.sound = "/sfx/blocks/footstep_sand2.ogg"

function BrushTool:trigger()
  self.firing = true
end


function BrushTool:update(dt)
  self.triggerPosition = mousePosition()
  Tool.update(self, dt)

  if self.firing then
    for _,tile in ipairs(self:hoverTiles()) do
      if not self.level:rockAt(tile) and self.level:dirtAt(tile) then
        self:triggerAction()
        self.level:removeDirt(tile)
      end
    end
  end
end

function BrushTool:release()
  self.firing = false
end

HammerTool = Tool:new()
HammerTool.name = "Marteau"
HammerTool.area = {{-0.5, -0.5}, {0.5, -0.5}, {-0.5, 0.5}, {0.5, 0.5}}
HammerTool.size = {2,2}
HammerTool.animationCycle = 0.25
HammerTool.sprite = Sprite:new("/interface/games/fossilgame/images/hammertool.png", {32,32}, {2,1}, 2)
HammerTool.sprite.origin = {12,12}
HammerTool.sprite.scale = 2
HammerTool.sound = "/sfx/tools/pickaxe_hit.ogg"

function HammerTool:trigger()
  if self:canUse() then
    local tiles = self:hoverTiles()
    if #tiles > 0 then
      self.uses = self.uses - 1
      for _,tile in ipairs(tiles) do
        if self.level:rockAt(tile) then
          self.level:removeRock(tile)
        elseif self.level:dirtAt(tile) or self.level:fossilAt(tile) then
          self.level:removeDirt(tile)
          self.level:damageFossil()
        end

        if self.level:rockAt(tile) or self.level:dirtAt(tile) or self.level:fossilAt(tile) then
          self:triggerAction()
        end
      end
    end
  end
end

PickaxeTool = Tool:new()
PickaxeTool.name = "Pioche"
PickaxeTool.area = {{0,0},{1,0},{-1,0},{0,1},{0,-1}}
PickaxeTool.size = {3,3}
PickaxeTool.animationCycle = 0.25
PickaxeTool.sprite = Sprite:new("/interface/games/fossilgame/images/picktool.png", {32,32}, {2,1}, 2)
PickaxeTool.sprite.origin = {12,12}
PickaxeTool.sprite.scale = 2
PickaxeTool.sound = "/sfx/tools/pickaxe_orebckup.ogg"

function PickaxeTool:trigger()
  if self:canUse() then
    local tiles = self:hoverTiles()
    if #tiles > 0 then
      self.uses = self.uses - 1
      for _,tile in ipairs(self:hoverTiles()) do
        if self.level:rockAt(tile) then
          self.level:removeRock(tile)
        elseif self.level:dirtAt(tile) or self.level:fossilAt(tile) then
          self.level:removeDirt(tile)
          self.level:damageFossil()
        end

        if self.level:rockAt(tile) or self.level:dirtAt(tile) or self.level:fossilAt(tile) then
          self:triggerAction()
        end
      end
    end
  end
end