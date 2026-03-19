local stringenums = require('runtime.stringenums')
local units = require('wowless.modules.units')()

-- mock_cgencode mirrors the real cgencode's behavior using the same runtime data,
-- so the C stub checks (which receive cgencode as upvalue) and the Lua typecheck
-- (which builds stringenumchecks from runtime.stringenums) both use the same source.
local mock_cgencode = {
  CheckStringEnum = function(value, enumname)
    local es = stringenums[enumname]
    if not es then
      error('internal error: unknown string enum: ' .. enumname)
    end
    return es[value:upper()]
  end,
  IsLuaObject = function(_ud, _typename)
    return false
  end,
  IsUiObject = function(_ud, _typename)
    return false
  end,
  log = function() end,
}

local ctc = require('wowless.modules.ctypecheck')(mock_cgencode)

local typecheck = require('wowless.modules.typecheck')(
  { addons = {} }, -- addons
  { -- datalua
    globals = { Enum = { TestEnum = { A = 1, B = 2 } } },
    structures = { TestStruct = { fields = {} } },
    uiobjects = { Frame = true },
  },
  nil, -- env
  { -- mock luaobjects: always reject
    Coerce = function()
      return nil
    end,
    UserData = function()
      return nil
    end,
  },
  { -- mock uiobjects: always reject
    UserData = function()
      return nil
    end,
  },
  { -- mock uiobjecttypes
    IsObjectType = function()
      return false
    end,
  },
  units
)

local function caccepts(fn, ...)
  return (pcall(fn, ...))
end

local function laccepts(spec, value, isout)
  -- warn=true means a soft/advisory error (e.g. invalid enum value); the call
  -- still succeeds and the value is passed through, so treat it as accepted.
  local _, err, warn = typecheck(spec, value, isout)
  return err == nil or warn ~= nil
end

describe('typecheck align', function()
  local all_values = { false, true, 0, 1, '0', '42', 'foo', 'TOPLEFT', {}, print }

  -- Type matrix: each row drives all tests for that type.
  --   name:     suffix used to build cfn keys (e.g. 'boolean' -> 'stubcheckboolean')
  --   ltype:    Lua type spec value passed to typecheck
  --   sections: set of prefix strings where this type has an aligned C function;
  --             types absent from a section assert ctc[prefix..name] is nil,
  --             reminding authors to add aligned tests when a C function is added
  --   tparam:   extra C parameter for typed checks (stringenum, luaobject, uiobject)
  local type_matrix = {
    {
      name = 'boolean',
      ltype = 'boolean',
      sections = { stubcheck = true, imploutput = true },
    },
    {
      name = 'number',
      ltype = 'number',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    {
      name = 'string',
      ltype = 'string',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    {
      name = 'function',
      ltype = 'function',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    {
      name = 'table',
      ltype = 'table',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    {
      name = 'unit',
      ltype = 'unit',
      sections = { stubcheck = true },
    },
    {
      name = 'unknown',
      ltype = 'unknown',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    {
      name = 'enum',
      ltype = { enum = 'TestEnum' },
      sections = { stubcheck = true },
    },
    {
      name = 'stringenum',
      ltype = { stringenum = 'FramePoint' },
      sections = { stubcheck = true },
      tparam = 'FramePoint',
    },
    {
      name = 'luaobject',
      ltype = { luaobject = 'Funtainer' },
      sections = { stubcheck = true },
      tparam = 'Funtainer',
    },
    {
      name = 'uiobject',
      ltype = { uiobject = 'Frame' },
      sections = { stubcheck = true },
      tparam = 'frame', -- C lowercases the typename
    },
    -- Types with no C function
    { name = 'FileAsset', ltype = 'FileAsset', sections = {} },
    { name = 'uiAddon', ltype = 'uiAddon', sections = {} },
    { name = 'any', ltype = 'any', sections = {} },
    { name = 'gender', ltype = 'gender', sections = {} },
    { name = 'oneornil', ltype = 'oneornil', sections = {} },
    { name = 'tostring', ltype = 'tostring', sections = {} },
    { name = 'structure', ltype = { structure = 'TestStruct' }, sections = {} },
    { name = 'arrayof', ltype = { arrayof = 'number' }, sections = {} },
  }

  local section_defs = {
    { label = 'stub input checks', prefix = 'stubcheck', isout = false },
    { label = 'impl input checks', prefix = 'implcheck', isout = false },
    { label = 'impl output checks', prefix = 'imploutput', isout = true },
  }

  for _, sec in ipairs(section_defs) do
    describe(sec.label, function()
      for _, td in ipairs(type_matrix) do
        if td.sections[sec.prefix] then
          -- C alignment: compare C acceptance against Lua acceptance.
          for _, nilable in ipairs({ false, true }) do
            local key = sec.prefix .. (nilable and 'nilable' or '') .. td.name
            local spec = { type = td.ltype, nilable = nilable or nil }
            local tparam = td.tparam
            describe((nilable and 'nilable ' or '') .. td.name, function()
              it('nil', function()
                assert.equal(caccepts(ctc[key], nil, tparam), laccepts(spec, nil, sec.isout))
              end)
              for _, v in ipairs(all_values) do
                it(tostring(v), function()
                  assert.equal(caccepts(ctc[key], v, tparam), laccepts(spec, v, sec.isout))
                end)
              end
            end)
          end
        else
          -- No C function: assert nil and validate Lua doesn't throw.
          local name, prefix = td.name, sec.prefix
          it('not yet implemented: ' .. prefix .. name, function()
            assert.is_nil(ctc[prefix .. name])
          end)
          it('not yet implemented: ' .. prefix .. 'nilable' .. name, function()
            assert.is_nil(ctc[prefix .. 'nilable' .. name])
          end)
          for _, nilable in ipairs({ false, true }) do
            local spec = { type = td.ltype, nilable = nilable or nil }
            describe((nilable and 'nilable ' or '') .. name, function()
              it('nil', function()
                typecheck(spec, nil, sec.isout)
              end)
              for _, v in ipairs(all_values) do
                it(tostring(v), function()
                  typecheck(spec, v, sec.isout)
                end)
              end
            end)
          end
        end
      end
    end)
  end
end)
