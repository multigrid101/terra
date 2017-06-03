-- takes an IR from lang.t and transfroms it to a function that is able to e.g. evaluate the cost
local lang = require('lang')

foo = {}
terra foo.myfunc(a:int)
  return 2*a
end

function getquote(bla,k)
  return `bla+k
end

function getcompositequote(bla)
  return `[getquote(bla,1)] + [getquote(bla,2)] + foo.['myfunc'](3)
end

terra doit(i:int)
  return [getcompositequote(i)]
end

doit:printpretty()

print('')
print(doit(3))
