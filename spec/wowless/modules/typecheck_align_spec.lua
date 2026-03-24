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
  GetUiAddon = function(_value)
    return nil -- empty addons
  end,
  GetUnit = units.GetUnit,
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
  local all_values = {
    ['nil'] = {},
    ['false'] = { value = false },
    ['true'] = { value = true },
    ['0'] = { value = 0 },
    ['1'] = { value = 1 },
    ['\'0\''] = { value = '0' },
    ['\'42\''] = { value = '42' },
    ['\'foo\''] = { value = 'foo' },
    ['\'TOPLEFT\''] = { value = 'TOPLEFT' },
    ['{}'] = { value = {} },
    ['print'] = { value = print },
  }

  -- Type matrix: each entry drives all tests for that type.
  --   key:      suffix used to build cfn keys (e.g. 'boolean' -> 'stubcheckboolean')
  --   ltype:    Lua type spec value passed to typecheck
  --   sections: set of prefix strings where this type has an aligned C function;
  --             types absent from a section assert ctc[prefix..name] is nil,
  --             reminding authors to add aligned tests when a C function is added
  --   tparam:   extra C parameter for typed checks (stringenum, luaobject, uiobject)
  local type_matrix = {
    boolean = {
      ltype = 'boolean',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    number = {
      ltype = 'number',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    string = {
      ltype = 'string',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    ['function'] = {
      ltype = 'function',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    table = {
      ltype = 'table',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    unit = {
      ltype = 'unit',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    unknown = {
      ltype = 'unknown',
      sections = { stubcheck = true }, -- not valid in impl inputs/outputs
    },
    enum = {
      ltype = { enum = 'TestEnum' },
      sections = { stubcheck = true },
    },
    stringenum = {
      ltype = { stringenum = 'FramePoint' },
      sections = { stubcheck = true },
      tparam = 'FramePoint',
    },
    luaobject = {
      ltype = { luaobject = 'Funtainer' },
      sections = { stubcheck = true },
      tparam = 'Funtainer',
    },
    uiobject = {
      ltype = { uiobject = 'Frame' },
      sections = { stubcheck = true },
      tparam = 'frame', -- C lowercases the typename
    },
    fileasset = {
      ltype = 'FileAsset',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    ['nil'] = {
      ltype = 'nil',
      sections = { stubcheck = true, implcheck = true, imploutput = true },
    },
    uiaddon = { ltype = 'uiAddon', sections = { stubcheck = true, implcheck = true } },
    -- Types with no C function
    any = { ltype = 'any', sections = {} },
    gender = { ltype = 'gender', sections = {} },
    oneornil = { ltype = 'oneornil', sections = {} },
    tostring = { ltype = 'tostring', sections = {} },
    structure = { ltype = { structure = 'TestStruct' }, sections = {} },
    arrayof = { ltype = { arrayof = 'number' }, sections = {} },
  }

  local section_defs = {
    ['stub input checks'] = { prefix = 'stubcheck', isout = false },
    ['impl input checks'] = { prefix = 'implcheck', isout = false },
    ['impl output checks'] = { prefix = 'imploutput', isout = true },
  }

  for label, sec in pairs(section_defs) do
    describe(label, function()
      for name, td in pairs(type_matrix) do
        if td.sections[sec.prefix] then
          -- C alignment: compare C acceptance against Lua acceptance.
          for _, nilable in ipairs({ false, true }) do
            local key = sec.prefix .. (nilable and 'nilable' or '') .. name
            local spec = { type = td.ltype, nilable = nilable or nil }
            local tparam = td.tparam
            describe((nilable and 'nilable ' or '') .. name, function()
              for vname, vt in pairs(all_values) do
                it(vname, function()
                  assert.equal(caccepts(ctc[key], vt.value, tparam), laccepts(spec, vt.value, sec.isout))
                end)
              end
            end)
          end
        else
          -- No C function: assert nil and validate Lua doesn't throw.
          local prefix = sec.prefix
          it('not yet implemented: ' .. prefix .. name, function()
            assert.is_nil(ctc[prefix .. name])
          end)
          it('not yet implemented: ' .. prefix .. 'nilable' .. name, function()
            assert.is_nil(ctc[prefix .. 'nilable' .. name])
          end)
          for _, nilable in ipairs({ false, true }) do
            local spec = { type = td.ltype, nilable = nilable or nil }
            describe((nilable and 'nilable ' or '') .. name, function()
              for vname, vt in pairs(all_values) do
                it(vname, function()
                  typecheck(spec, vt.value, sec.isout)
                end)
              end
            end)
          end
        end
      end
    end)
  end
end)
