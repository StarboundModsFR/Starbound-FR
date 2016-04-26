function init()
  local bounds = mcontroller.boundBox()
end

function update(dt)
  mcontroller.controlModifiers({
      runModifier = 1.20
    })
end

function uninit()
  
end