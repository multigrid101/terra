st = require('symboltable')
st = st.SymbolTable:get()

st._runtimesymbols = {}

Xlbl = label('X')
st._runtimesymbols['X'] = Xlbl

Ylbl = label('Y')
st._runtimesymbols['Y'] = Ylbl


mystruct = terralib.types.newstruct('mystruct')

table.insert(mystruct.entries, {field = Xlbl, type = &float})
table.insert(mystruct.entries, {field = Ylbl, type = &float})


terra applyfun()
end

