require "/scripts/util.lua"

function build(directory, config, parameters, level)
  if level then
    parameters.level = level
  end

  -- set price
  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", parameters.level or config.level or 1)

  -- tooltip fields
  config.tooltipFields = {}
  config.tooltipFields.subtitle = "Bouclier"
  config.tooltipFields.healthLabel = util.round((parameters.baseShieldHealth or config.baseShieldHealth or 0) * root.evalFunction("shieldLevelMultiplier", parameters.level or config.level or 1), 0)
  config.tooltipFields.cooldownLabel = parameters.cooldownTime or config.cooldownTime
  
  return config, parameters
end