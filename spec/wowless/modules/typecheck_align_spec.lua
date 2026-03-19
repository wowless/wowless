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
  nil, -- addons
  { -- datalua
    globals = { Enum = { TestEnum = { A = 1, B = 2 } } },
    structures = {},
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
  -- Types that have typecheck.lua handling but no dedicated C function yet.
  -- If a new C function is added, this assertion will fail, reminding the author
  -- to add a corresponding aligned test case.
  describe('not yet implemented in C', function()
    local not_yet_implemented = {
      -- FileAsset and uiAddon: mapped to string check in cinputtypes, no own C fn
      'stubcheckFileAsset',
      'stubchecknilableFileAsset',
      'stubcheckuiAddon',
      'stubchecknilableuiAddon',
      -- impl checks not yet added for these types
      'implcheckboolean',
      'implchecknilableboolean',
      'implcheckenum',
      'implchecknilableenum',
      'implcheckunit',
      'implchecknilableunit',
      'implcheckstringenum',
      'implchecknilablestringenum',
      'implcheckluaobject',
      'implchecknilableluaobject',
      'implcheckuiobject',
      'implchecknilableuiobject',
      -- output checks not in coutputtypes
      'imploutputenum',
      'imploutputnilableenum',
      'imploutputunit',
      'imploutputnilableunit',
      'imploutputstringenum',
      'imploutputnilablestringenum',
      'imploutputluaobject',
      'imploutputnilableluaobject',
      'imploutputuiobject',
      'imploutputnilableuiobject',
    }
    for _, k in ipairs(not_yet_implemented) do
      it(k, function()
        assert.is_nil(ctc[k])
      end)
    end
  end)

  local all_values = { false, true, 0, 1, '0', '42', 'foo', 'TOPLEFT', {}, print }

  -- run_aligned: for each value in all_values (plus nil), assert C and Lua agree.
  -- cfn(v) -> bool: whether C accepts value v
  -- lfn(v) -> bool: whether Lua accepts value v
  local function run_aligned(label, cfn, lfn)
    describe(label, function()
      it('nil', function()
        assert.equal(cfn(nil), lfn(nil))
      end)
      for _, v in ipairs(all_values) do
        it(tostring(v), function()
          assert.equal(cfn(v), lfn(v))
        end)
      end
    end)
  end

  -- Type matrix: each row drives all aligned tests for that type.
  --   name:     suffix used to build cfn keys (e.g. 'boolean' -> 'stubcheckboolean')
  --   ltype:    Lua type spec value (string for simple types, table for complex)
  --   sections: set of prefix strings this type appears in
  --   tparam:   extra C parameter for typed checks (stringenum, luaobject)
  --   tparam_c: extra C parameter override when it differs from what's in ltype (uiobject)
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
      tparam_c = 'frame', -- C lowercases the typename
    },
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
          local function make_cfn(nilable)
            local key = sec.prefix .. (nilable and 'nilable' or '') .. td.name
            local tparam = td.tparam_c or td.tparam
            return function(v)
              return caccepts(ctc[key], v, tparam)
            end
          end
          local function make_lfn(nilable)
            local spec = { type = td.ltype, nilable = nilable or nil }
            return function(v)
              return laccepts(spec, v, sec.isout)
            end
          end
          run_aligned(td.name, make_cfn(false), make_lfn(false))
          run_aligned('nilable ' .. td.name, make_cfn(true), make_lfn(true))
        end
      end
    end)
  end
end)
