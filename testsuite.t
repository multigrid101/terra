ts = {}

debugmode = true

local function printdbg(...)
  if debugmode then
    print(...)
  end
end
ts.printdbg = printdbg

local function printtable(thetable)
  if debugmode then
    for k,v in pairs(thetable) do print(k,v) end
  end
end
ts.printtable = printtable

return ts
