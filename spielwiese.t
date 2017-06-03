struct Context {
  foo : int,
  bar : int
}

terra apply(c : &&opaque)
  return c[234]
end

-- terra doit()
--   var c : Context
--   c.foo = 123
--   c.bar = 234

--   return apply(c)
-- end
-- print(doit())
