local h = {}

local function numentries(thetable)
  local count = 0
  for k,v in pairs(thetable) do count = count + 1 end

  return count
end
h.numentries = numentries

return h
