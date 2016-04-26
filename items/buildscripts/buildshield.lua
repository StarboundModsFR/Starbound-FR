require "/scripts/util.lua"
require "/scripts/staticrandom.lua"

function build(directory, config, parameters, level)
  if level then
    parameters.level = level
  end

  -- initialize randomization
  local seed = parameters.seed or config.seed
  if not seed then
    seed = math.random(1, 4294967295)
    parameters.seed = seed
  end

  -- select the generation profile to use
  local builderConfig = {}
  if config.builderConfig then
    builderConfig = randomFromList(config.builderConfig, parameters.seed, "builderConfig")
  end

  -- build palette swap directives
  local paletteSwaps = ""
  if builderConfig.palette then
    local palette = root.assetJson(util.absolutePath(directory, builderConfig.palette))
    local selectedSwaps = randomFromList(palette.swaps, parameters.seed, "paletteSwaps")
    for k, v in pairs(selectedSwaps) do
      paletteSwaps = string.format("%s?replace=%s=%s", paletteSwaps, k, v)
    end
  end

  -- name
  if not parameters.shortdescription and builderConfig.nameGenerator then
    parameters.shortdescription = root.generateName(util.absolutePath(directory, builderConfig.nameGenerator))
  end

  -- merge extra animationCustom
  if builderConfig.animationCustom then
    config.animationCustom = util.mergeTable(config.animationCustom or {}, builderConfig.animationCustom)
  end

  -- animation parts
  if builderConfig.animationParts then
    if parameters.animationParts == nil then parameters.animationParts = {} end
    for k, v in pairs(builderConfig.animationParts) do
      if parameters.animationParts[k] == nil then
        if type(v) == "table" then
          parameters.animationParts[k] = util.absolutePath(directory, string.gsub(v.path, "<variant>", randomIntInRange({1, v.variants}, parameters.seed, "animationPart"..k)))
        else
          parameters.animationParts[k] = v
        end

        -- use near idle frame of shield for inventory icon for now
        if k == "shield" and not parameters.inventoryIcon then
          parameters.inventoryIcon = parameters.animationParts[k]..":nearidle"
        end
      end
    end
  end

  -- TODO: special abilities / properties

  -- set price
  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", parameters.level or config.level or 1)

  -- tooltip fields
  config.tooltipFields = {}
  config.tooltipFields.subtitle = "Bouclier"
  config.tooltipFields.healthLabel = util.round((parameters.baseShieldHealth or config.baseShieldHealth or 0) * root.evalFunction("shieldLevelMultiplier", parameters.level or config.level or 1), 0)
  config.tooltipFields.cooldownLabel = parameters.cooldownTime or config.cooldownTime

  return config, parameters
end