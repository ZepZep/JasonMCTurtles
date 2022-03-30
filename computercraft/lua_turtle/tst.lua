-- Turtle Self-tracking System
--   created by Latias1290
--   improved by ZepZep_

local x, y, z = nil
face = nil -- east 0, south 1, west 2, north 3
calibrated = false

function getFacing(x0, z0, x1, z1)
  if x1 == x0 + 1 then
    return 0
  elseif z1 == z0 + 1 then
    return 1
  elseif x1 == x0 - 1 then
    return 2
  elseif z1 == z0 - 1 then
    return 3
  end
end

-- get gps using other computers
function calibrate()
  local x0, y0, z0 = gps.locate()
  local i = 0
  while not calibrated and i < 4 do
    if turtle.forward() then
      x, y, z = gps.locate()
      calibrated = true
      face = getFacing(x0, z0, x, z)
      return true
    end
    turtle.turnRight()
    i = i+1
  end
  return false
end

function locate()
  if x ~= nil then
    return x, y, z
  else
    return nil
  end
end

function fullLocate()
  if x ~= nil then
    return tostring(x) .." ".. tostring(y) .." ".. tostring(z) .." ".. tostring(face)
  else
    return nil
  end
end

function turnLeft()
  turtle.turnLeft()
  face = face - 1
  face = face % 4
end

function turnRight()
  turtle.turnRight()
  face = face + 1
  face = face % 4
end

function forward()
  local ok, err = turtle.forward()

  if not ok then
    return ok, err
  end

  if not calibrated then
    return ok, "Not calibrated"
  end

  if face == 0 then
    x = x + 1
  elseif face == 1 then
    z = z + 1
  elseif face == 2 then
    x = x - 1
  elseif face == 3 then
    z = z - 1
  end

  return true
end

function back() -- go back
  local ok, err = turtle.back()

  if not ok then
    return ok, err
  end

  if not calibrated then
    return ok, "Not calibrated"
  end

  if face == 0 then
    x = x - 1
  elseif face == 1 then
    z = z - 1
  elseif face == 2 then
    x = x + 1
  elseif face == 3 then
    z = z + 1
  end

  return true
end

function up()
  local ok, err = turtle.up()
  if not ok then
    return ok, err
  end
  if not calibrated then
    return ok, "Not calibrated"
  end

  y = y + 1
  return true
end

function down() -- go down
  local ok, err = turtle.up()
  if not ok then
    return ok, err
  end
  if not calibrated then
    return ok, "Not calibrated"
  end

  y = y - 1
  return true
end

function jump() -- perform a jump. useless? yup!
  turtle.up()
  turtle.down()
end
