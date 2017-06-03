lang = require('lang')
v = require('visitor')
test = require('testsuite')
h = require('helpers')

st = require('symboltable')
st = st.SymbolTable:new() -- need this extra line to have access to unique symbol table an  re-initialize it

C = terralib.includecstring([[
#include <stdio.h>
#include <stdlib.h>
]])


X = lang.Image:new('X')
Y = lang.Image:new('Y')
Z = lang.Image:new('Z')

snode1 = X(0,0) -- TODO this can be made more compact with operator overloading
snode2 = Y(1,1)
snode3 = Z(3,3)
pnode = lang.PlusNode:new(snode1, snode2)
pnode2 = lang.PlusNode:new(pnode, snode3)


vis = v.VisitorToQuote:new()
vis:visitRoot(pnode2)


terra evalCostLocal([vis._ctxt]) : float
    [vis._image_declarations]
    [vis._temp_declarations]
    [vis._codelines]
end
print(evalCostLocal)
-------------------------------------------------------------------------------
-- helpers start
-------------------------------------------------------------------------------
print('\nthe helpers')
terra allocate(ctxt : &&lang.TerraImage)
  var numptrs = [h.numentries(st._data)]
  @ctxt = [&lang.TerraImage](C.malloc(numptrs * sizeof(lang.TerraImage)))

  escape
    local count = 0
    for key, im in pairs(st._data) do
      emit quote
        (@ctxt)[ [count] ]._data = [&float](C.malloc(1000 * sizeof(float)))
      end
    count = count + 1
    end
  end

end
print(allocate)

-- allocation must be carried out BEFORE this function is called
terra initialize(ctxt : &&lang.TerraImage)
  escape
    local count = 0
    for key, im in pairs(st._data) do
      emit quote
        for k = 0,1000 do
          (@ctxt)[ [count] ]._data[k] = 0.3f
        end
      end
    count = count + 1
    end
  end
end
print(initialize)

terra evalCostGlobal([vis._ctxt]) : float
  var totalCost = 0.0f
  for k = 0,1000 do
    totalCost = totalCost + evalCostLocal([vis._ctxt])
  end
  return totalCost
end


-------------------------------------------------------------------------------
-- helpers end
-------------------------------------------------------------------------------


terra test1() -- only evaluate cost locally
  var thectxt : &lang.TerraImage
  allocate(&thectxt)
  initialize(&thectxt)

  var thecost = evalCostLocal(thectxt)
  C.printf('The local cost is: %f\n', thecost)
end
test1()


terra test2() -- evaluate global cost
  var thectxt : &lang.TerraImage
  allocate(&thectxt)
  initialize(&thectxt)

  var thecost = evalCostGlobal(thectxt)
  C.printf('The global cost is: %f\n', thecost)
end
test2()
