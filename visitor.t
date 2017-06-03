lang = require('lang')
test = require('testsuite')
st = require('symboltable')
st = st.SymbolTable:get()

print('\nStart of visitor file:')
print('\nThe symbol table.data:')
test.printtable(st._data)

local v = {}

local VisitorToQuote = {}
function VisitorToQuote:new()
  local obj = {
                _type = "VisitorToQuote",
                _codelines = {},
                _temp_declarations = {},
                _image_declarations = {},
                _stack = {},
                _ctxt = symbol(&lang.TerraImage, 'ctxt'),
              }
  setmetatable(obj, VisitorToQuote)
  VisitorToQuote.__index = VisitorToQuote


  return obj
end

ctxt = symbol(&lang.TerraImage, 'ctxt')


function VisitorToQuote:visit(node)

  assert(node._type, "Type field not set for the received node object")

  if node._type == "StencilNode" then
    local tempsym = table.remove(self._stack)

    table.insert(self._codelines, quote [tempsym] = [st._data[node._name]._terrasym]([node._offsetx],[node._offsety]) end)

    table.insert(self._image_declarations, quote var [st._data[node._name]._terrasym]  = self._ctxt[0] end)
  elseif node._type == "PlusNode" then
    local arg2sym = symbol(float)
    local arg1sym = symbol(float)
    table.insert(self._stack, arg2sym) -- for arg2
    table.insert(self._stack, arg1sym) -- for arg1

    self:visit(node._arg1)
    self:visit(node._arg2)

    local resultsym = table.remove(self._stack)

    table.insert(self._temp_declarations, quote var [arg1sym] end)
    table.insert(self._temp_declarations, quote var [arg2sym] end)

    table.insert(self._codelines, quote [resultsym] = [arg1sym] + [arg2sym] end)
  else
    error("VisitorToQuote does not know nodetype: " .. node._type)
  end
end


function VisitorToQuote:visitRoot(node)
  local rootsym = symbol(float)
  table.insert(self._stack, rootsym) -- symbol for root result
  table.insert(self._temp_declarations, quote var [rootsym] end) -- symbol for root result

  self:visit(node)

  table.insert(self._codelines, quote return [rootsym] end)
end
v.VisitorToQuote = VisitorToQuote


-------------------------------------------------------------------------------
-- tests
-------------------------------------------------------------------------------
X = lang.Image:new('X')
Y = lang.Image:new('Y')
Z = lang.Image:new('Z')

snode1 = X(0,0)
snode2 = Y(1,1)
snode3 = Z(3,3)

pnode = lang.PlusNode:new(snode1, snode2)
pnode2 = lang.PlusNode:new(pnode, snode3)

vis = VisitorToQuote:new()
-- vis:visit(snode1)
-- vis:visit(snode2)


vis:visitRoot(pnode2)

print('\nThe visitor._codelines')
test.printtable(vis._codelines)

print('\nThe visitor._image_declarations')
test.printtable(vis._image_declarations)

print('\nThe visitor._temp_declarations')
test.printtable(vis._temp_declarations)


-- now make a function out of the result
terra genfun([vis._ctxt])
    [vis._image_declarations]
    [vis._temp_declarations]
    [vis._codelines]
end

print('\nThe generated function')
print(genfun)


return v
