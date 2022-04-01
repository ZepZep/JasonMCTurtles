-- Turtle Self-tracking System
--   created by Latias1290
--   improved by ZepZep_

x, y, z = nil
face = nil -- east 0, south 1, west 2, north 3
calibrated = false

local directions = {
  [0] = {x=1, z=0},
  [1] = {x=0, z=1},
  [2] = {x=-1, z=0},
  [3] = {x=0, z=-1}
}

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
  calibrated = false
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
  return true
end

function turnRight()
  turtle.turnRight()
  face = face + 1
  face = face % 4
  return true
end

function forward()
  local ok, err = turtle.forward()

  if not ok then
    return ok, err
  end

  if not calibrated then
    return ok, "Not calibrated"
  end

  local delta = directions[face]
  x = x + delta.x
  z = z + delta.z

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

  local delta = directions[face]
  x = x - delta.x
  z = z - delta.z

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
  local ok, err = turtle.down()
  if not ok then
    return ok, err
  end
  if not calibrated then
    return ok, "Not calibrated"
  end

  y = y - 1
  return true
end

function signum(v)
  if v < 0 then
    return -1
  elseif v > 0 then
    return 1
  else
    return 0
  end
end

function facingOK(fx, fz, cdir)
  local dx = fx - x
  local dz = fz - z

  local moveDelta = directions[cdir]
  local sdx = signum(moveDelta.x)
  local sdz = signum(moveDelta.z)

  if sdx ~= 0 and signum(dx) == sdx then
    return true
  elseif sdz ~= 0 and signum(dz) == sdz then
    return true
  else
    return false
  end
end

function moveFace(fdir)
  if face == fdir then
    return false, "already here"
  end

  local distL = fdir - (face - 1) % 4
  local distR = fdir - (face + 1) % 4

  if distL == 0 then
    turnLeft()
  elseif distR == 0 then
    turnRight()
  else
    turnRight()
    turnRight()
  end
  return true
end

function moveTowards(fx, fy, fz, fdir)
  if not calibrated then
    return false, "Not calibrated"
  end

  if x == fx and z == fz then
    local dy = fy - y
    if dy < 0 then
      return down()
    elseif dy > 0 then
      return up()
    else
      return moveFace(fdir)
    end
  else
    if facingOK(fx, fz, face) then
      return forward()
    elseif facingOK(fx, fz, (face+1) % 4) then
      turnRight()
      return forward()
    elseif facingOK(fx, fz, (face-1) % 4) then
      turnLeft()
      return forward()
    else
      turnRight()
      turnRight()
      return forward()
    end
  end
end
