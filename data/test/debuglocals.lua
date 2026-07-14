local T, debuglocals = ...

-- debuglocals() has no machine-readable format: it produces a plain-text
-- dump ("name = value\n" per entry) intended for a human reading an error
-- handler's output, with locals listed first and upvalues appended after
-- them with no separator between the two groups. Only one level of table
-- recursion is ever present (elune's aux_dumpvalue caps it there, matching
-- the real client), so a nested table's own contents always render as an
-- immediately-closed empty block. Table values below are therefore left as
-- an opaque 'table' kind rather than parsed further, and likewise for
-- functions/userdata/other non-scalar kinds, which can't be reconstructed
-- from text anyway. String values are not escaped by the engine, so a
-- string containing '"' or a newline will not round-trip correctly; that's
-- an ambiguity in the source format itself, not a bug in this parser.

local function classify(text)
  if text == 'nil' then
    return 'nil'
  elseif text == 'true' then
    return 'boolean', true
  elseif text == 'false' then
    return 'boolean', false
  elseif text == '<userdata>' then
    return 'userdata'
  elseif text:sub(1, 1) == '"' and text:sub(-1) == '"' and #text >= 2 then
    return 'string', text:sub(2, -2)
  elseif text:sub(-1) == '{' then
    return 'table'
  elseif text:find(' defined ', 1, true) then
    return 'function'
  elseif tonumber(text) then
    return 'number', tonumber(text)
  else
    return 'other'
  end
end

local function parse(dump)
  local lines = {}
  for line in (dump .. '\n'):gmatch('([^\n]*)\n') do
    table.insert(lines, line)
  end
  if lines[#lines] == '' then
    table.remove(lines)
  end
  local entries = {}
  local i = 1
  while i <= #lines do
    local name, rest = lines[i]:match('^(.-) = (.*)$')
    if not name then
      error(('unparseable debuglocals line %d: %q'):format(i, lines[i]))
    end
    local kind, value = classify(rest)
    table.insert(entries, { name = name, kind = kind, value = value })
    if kind == 'table' then
      -- Skip to the matching close brace; nested entries are indented one
      -- space and can't themselves contain a bare '}' line, since a nested
      -- table's own close brace is always indented too (recursion is capped
      -- at one level by the engine).
      repeat
        i = i + 1
        if not lines[i] then
          error('unterminated table value for ' .. name)
        end
      until lines[i] == '}'
    end
    i = i + 1
  end
  return entries
end

-- Entries are Lua arrays, so they can't be handed to T.assertRecursivelyEqual
-- directly: it turns table values into sub-tests keyed by whatever keys the
-- table has, and the addon test framework requires every sub-test key to be
-- a non-empty string, which array indices aren't.
local function assertEntries(expected, actual)
  T.assertEquals(#expected, #actual, 'entry count')
  for i = 1, #expected do
    local e, a = expected[i], actual[i]
    T.assertEquals(e.name, a.name, 'entry ' .. i .. ' name')
    T.assertEquals(e.kind, a.kind, 'entry ' .. i .. ' kind')
    T.assertEquals(e.value, a.value, 'entry ' .. i .. ' value')
  end
end

return {
  parser = function()
    return {
      scalars = function()
        assertEntries({
          { name = 'a', kind = 'number', value = 1 },
          { name = 'b', kind = 'string', value = 'hello' },
          { name = 'c', kind = 'boolean', value = true },
          { name = 'd', kind = 'boolean', value = false },
          { name = 'e', kind = 'nil' },
        }, parse('a = 1\nb = "hello"\nc = true\nd = false\ne = nil\n'))
      end,
      ['empty string'] = function()
        assertEntries({ { name = 's', kind = 'string', value = '' } }, parse('s = ""\n'))
      end,
      ['negative and decimal numbers'] = function()
        assertEntries({
          { name = 'a', kind = 'number', value = -1.5 },
          { name = 'b', kind = 'number', value = 100 },
        }, parse('a = -1.5\nb = 100\n'))
      end,
      ['empty table'] = function()
        assertEntries({ { name = 't', kind = 'table' } }, parse('t = <table> {\n}\n'))
      end,
      ['table contents are opaque'] = function()
        assertEntries({ { name = 't', kind = 'table' } }, parse('t = <table> {\n 1 = 1\n 2 = 2\n}\n'))
      end,
      ['nested table stays within outer block'] = function()
        assertEntries(
          { { name = 't', kind = 'table' }, { name = 'after', kind = 'number', value = 1 } },
          parse('t = <table> {\n inner = <table> {\n }\n}\nafter = 1\n')
        )
      end,
      ['named table value'] = function()
        assertEntries({ { name = 't', kind = 'table' } }, parse('t = SomeMixin {\n}\n'))
      end,
      ['function value'] = function()
        assertEntries(
          { { name = 'f', kind = 'function' } },
          parse('f = <function> defined @Interface/AddOns/Foo/Bar.lua:12\n')
        )
      end,
      ['named function value'] = function()
        assertEntries(
          { { name = 'f', kind = 'function' } },
          parse('f = foo() defined @Interface/AddOns/Foo/Bar.lua:12\n')
        )
      end,
      ['userdata value'] = function()
        assertEntries({ { name = 'u', kind = 'userdata' } }, parse('u = <userdata>\n'))
      end,
      ['other value'] = function()
        assertEntries({ { name = 'c', kind = 'other' } }, parse('c = <thread>\n'))
      end,
      ['no trailing newline'] = function()
        assertEntries({ { name = 'a', kind = 'number', value = 1 } }, parse('a = 1'))
      end,
      empty = function()
        assertEntries({}, parse(''))
      end,
    }
  end,
  live = function()
    local upvalueVar = 'closed-over'
    -- argOne/argTwo and the locals below exist only to be captured by
    -- debuglocals() inside this function.
    -- luacheck: ignore 211 212
    local function inner(argOne, argTwo)
      local n = 42
      -- Uses upvalueVar so it's actually captured as an upvalue of inner;
      -- an unreferenced enclosing local isn't one.
      local s = upvalueVar .. '-value'
      local b = true
      local t = { 1, 2, 3 }
      local function nested() end
      -- Must not be `return debuglocals()`: as a tail call, Lua 5.1 would
      -- collapse this frame before debuglocals runs, so level 1 would land
      -- on our caller instead of on `inner` and none of these locals would
      -- be visible.
      local dump = debuglocals()
      return dump
    end
    local entries = parse(inner('one', nil))
    -- Upvalues are listed in the order they're first referenced while
    -- compiling inner's body: upvalueVar (in s's initializer) before
    -- debuglocals (in the final statement).
    assertEntries({
      { name = 'argOne', kind = 'string', value = 'one' },
      { name = 'argTwo', kind = 'nil' },
      { name = 'n', kind = 'number', value = 42 },
      { name = 's', kind = 'string', value = 'closed-over-value' },
      { name = 'b', kind = 'boolean', value = true },
      { name = 't', kind = 'table' },
      { name = 'nested', kind = 'function' },
      { name = 'upvalueVar', kind = 'string', value = 'closed-over' },
      { name = 'debuglocals', kind = 'function' },
    }, entries)
  end,
}
