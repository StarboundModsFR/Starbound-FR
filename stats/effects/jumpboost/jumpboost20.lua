function init()
  local bounds = mcontroller.boundBox()
end

function update(dt)
  mcontroller.controlModifiers({
      airJumpModifier = 1.20
    })
end

function uninit()
  
end