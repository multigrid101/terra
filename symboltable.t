st = {}

SymbolTable = {}
SymbolTable._doesexist = false
SymbolTable._selfptr = nil
function SymbolTable:new()
   local obj = {
         _data = {},
         -- _doesexist = false,
         -- _selfptr = nil,
         }
  setmetatable(obj,self)
  self.__index = self

  return obj
end
-- SymbolTable._selfptr = SymbolTable:new()


function SymbolTable:get()
  if SymbolTable._doesexist then
    return SymbolTable._selfptr
  else
    SymbolTable._selfptr = SymbolTable:new()
    SymbolTable._doesexist = true
    return SymbolTable._selfptr
  end
end

st.SymbolTable = SymbolTable
-- call new() to re-initialize symboltable
-- call get() to get pointer to singleton object. but careful: this object may
--      already be populated with data from unit-tests

-------------------------------------------------------------------------------
-- tests
-------------------------------------------------------------------------------
local ts = require('testsuite')

function doit()
  local thetable = SymbolTable:get()

  thetable._data.asdf = 123
  ts.printdbg(thetable._data.asdf)

  local othertable = SymbolTable:get() -- make sure that singleton pattern works
  ts.printdbg(othertable._data.asdf)

  othertable._data.foo = 234
  ts.printdbg(othertable._data.foo)
  ts.printdbg(thetable._data.foo)

end
doit()
-------------------------------------------------------------------------------
-- END tests
-------------------------------------------------------------------------------
return st
