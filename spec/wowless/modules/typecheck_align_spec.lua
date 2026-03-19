local stringenums = require('runtime.stringenums')
local units = require('wowless.modules.units')()

-- mock_cgencode mirrors the real cgencode's behavior using the same runtime data,
-- so the C stub checks (which receive cgencode as upvalue) and the Lua typecheck
-- (which builds stringenumchecks from runtime.stringenums) both use the same source.
local mock_cgencode = {
  CheckStringEnum = function(value, enumname)
    local es = stringenums[enumname]
    return es and es[value:upper()]
  end,
  IsLuaObject = function(_ud, _typename)
    return false
  end,
  IsUiObject = function(_ud, _typename)
    return false
  end,
  log = function() end,
}

local ctc = require('wowless.ctypecheck')(mock_cgencode)

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

  -- run_aligned: for each value in vset (plus nil unless skip_nil), assert C and Lua agree.
  -- cfn(v) -> bool: whether C accepts value v
  -- lfn(v) -> bool: whether Lua accepts value v
  -- skip_nil: set true when nil has a known mismatch (documented in known mismatches)
  local function run_aligned(label, cfn, lfn, vset, skip_nil)
    describe(label, function()
      if not skip_nil then
        it('nil', function()
          assert.equal(cfn(nil), lfn(nil))
        end)
      end
      for _, v in ipairs(vset) do
        it(tostring(v), function()
          assert.equal(cfn(v), lfn(v))
        end)
      end
    end)
  end

  -- Standard value set covering the main Lua types (nil tested separately above).
  local values = { false, true, 0, 1, '0', '42', 'foo', {}, print }
  -- Values without numeric strings: used for enum cases (known mismatch on '0'/'42').
  local values_no_numstr = { false, true, 0, 1, 'foo', {}, print }

  local function simple_cfn(fn_key)
    return function(v)
      return caccepts(ctc[fn_key], v)
    end
  end

  local function simple_lfn(spec, isout)
    return function(v)
      return laccepts(spec, v, isout)
    end
  end

  local function typed_cfn(fn_key, tname)
    return function(v)
      return caccepts(ctc[fn_key], v, tname)
    end
  end

  describe('stub input checks', function()
    run_aligned('boolean', simple_cfn('stubcheckboolean'), simple_lfn({ type = 'boolean' }), values)
    run_aligned(
      'nilable boolean',
      simple_cfn('stubchecknilableboolean'),
      simple_lfn({ type = 'boolean', nilable = true }),
      values
    )
    run_aligned('number', simple_cfn('stubchecknumber'), simple_lfn({ type = 'number' }), values)
    run_aligned(
      'nilable number',
      simple_cfn('stubchecknilablenumber'),
      simple_lfn({ type = 'number', nilable = true }),
      values
    )
    run_aligned('string', simple_cfn('stubcheckstring'), simple_lfn({ type = 'string' }), values)
    run_aligned(
      'nilable string',
      simple_cfn('stubchecknilablestring'),
      simple_lfn({ type = 'string', nilable = true }),
      values
    )
    run_aligned('function', simple_cfn('stubcheckfunction'), simple_lfn({ type = 'function' }), values)
    run_aligned(
      'nilable function',
      simple_cfn('stubchecknilablefunction'),
      simple_lfn({ type = 'function', nilable = true }),
      values
    )
    run_aligned('table', simple_cfn('stubchecktable'), simple_lfn({ type = 'table' }), values)
    run_aligned(
      'nilable table',
      simple_cfn('stubchecknilabletable'),
      simple_lfn({ type = 'table', nilable = true }),
      values
    )
    run_aligned('unit', simple_cfn('stubcheckunit'), simple_lfn({ type = 'unit' }), values)
    run_aligned(
      'nilable unit',
      simple_cfn('stubchecknilableunit'),
      simple_lfn({ type = 'unit', nilable = true }),
      values
    )
    run_aligned('unknown', simple_cfn('stubcheckunknown'), simple_lfn({ type = 'unknown' }), values)
    run_aligned(
      'nilable unknown',
      simple_cfn('stubchecknilableunknown'),
      simple_lfn({ type = 'unknown', nilable = true }),
      values
    )
    -- enum: numeric strings excluded due to known mismatch (see below)
    run_aligned('enum', simple_cfn('stubcheckenum'), simple_lfn({ type = { enum = 'TestEnum' } }), values_no_numstr)
    run_aligned(
      'nilable enum',
      simple_cfn('stubchecknilableenum'),
      simple_lfn({ type = { enum = 'TestEnum' }, nilable = true }),
      values_no_numstr
    )
    -- stringenum: valid and invalid values; non-string types rejected by both
    local se_values = { false, true, 0, 1, 'foo', 'CENTER', 'TOPLEFT', {}, print }
    run_aligned(
      'stringenum',
      typed_cfn('stubcheckstringenum', 'FramePoint'),
      simple_lfn({ type = { stringenum = 'FramePoint' } }),
      se_values
    )
    run_aligned(
      'nilable stringenum',
      typed_cfn('stubchecknilablestringenum', 'FramePoint'),
      simple_lfn({ type = { stringenum = 'FramePoint' }, nilable = true }),
      se_values
    )
    -- luaobject/uiobject: only non-object values tested here (both reject);
    -- acceptance of real objects is covered by in-game tests.
    local obj_values = { false, true, 0, 1, '42', 'foo', {}, print }
    run_aligned(
      'luaobject',
      typed_cfn('stubcheckluaobject', 'Funtainer'),
      simple_lfn({ type = { luaobject = 'Funtainer' } }),
      obj_values
    )
    run_aligned(
      'nilable luaobject',
      typed_cfn('stubchecknilableluaobject', 'Funtainer'),
      simple_lfn({ type = { luaobject = 'Funtainer' }, nilable = true }),
      obj_values
    )
    -- uiobject typename is lowercased by the C check; pass lowercase here to match
    run_aligned(
      'uiobject',
      typed_cfn('stubcheckuiobject', 'frame'),
      simple_lfn({ type = { uiobject = 'Frame' } }),
      obj_values
    )
    run_aligned(
      'nilable uiobject',
      typed_cfn('stubchecknilableuiobject', 'frame'),
      simple_lfn({ type = { uiobject = 'Frame' }, nilable = true }),
      obj_values
    )
  end)

  describe('impl input checks', function()
    run_aligned('number', simple_cfn('implchecknumber'), simple_lfn({ type = 'number' }), values)
    run_aligned(
      'nilable number',
      simple_cfn('implchecknilablenumber'),
      simple_lfn({ type = 'number', nilable = true }),
      values
    )
    run_aligned('string', simple_cfn('implcheckstring'), simple_lfn({ type = 'string' }), values)
    run_aligned(
      'nilable string',
      simple_cfn('implchecknilablestring'),
      simple_lfn({ type = 'string', nilable = true }),
      values
    )
    run_aligned('function', simple_cfn('implcheckfunction'), simple_lfn({ type = 'function' }), values)
    run_aligned(
      'nilable function',
      simple_cfn('implchecknilablefunction'),
      simple_lfn({ type = 'function', nilable = true }),
      values
    )
    run_aligned('table', simple_cfn('implchecktable'), simple_lfn({ type = 'table' }), values)
    run_aligned(
      'nilable table',
      simple_cfn('implchecknilabletable'),
      simple_lfn({ type = 'table', nilable = true }),
      values
    )
    run_aligned('unknown', simple_cfn('implcheckunknown'), simple_lfn({ type = 'unknown' }), values)
    run_aligned(
      'nilable unknown',
      simple_cfn('implchecknilableunknown'),
      simple_lfn({ type = 'unknown', nilable = true }),
      values
    )
  end)

  describe('impl output checks', function()
    run_aligned('boolean', simple_cfn('imploutputboolean'), simple_lfn({ type = 'boolean' }, true), values)
    run_aligned(
      'nilable boolean',
      simple_cfn('imploutputnilableboolean'),
      simple_lfn({ type = 'boolean', nilable = true }, true),
      values
    )
    run_aligned('number', simple_cfn('imploutputnumber'), simple_lfn({ type = 'number' }, true), values)
    run_aligned(
      'nilable number',
      simple_cfn('imploutputnilablenumber'),
      simple_lfn({ type = 'number', nilable = true }, true),
      values
    )
    run_aligned('string', simple_cfn('imploutputstring'), simple_lfn({ type = 'string' }, true), values)
    run_aligned(
      'nilable string',
      simple_cfn('imploutputnilablestring'),
      simple_lfn({ type = 'string', nilable = true }, true),
      values
    )
    run_aligned('function', simple_cfn('imploutputfunction'), simple_lfn({ type = 'function' }, true), values)
    run_aligned(
      'nilable function',
      simple_cfn('imploutputnilablefunction'),
      simple_lfn({ type = 'function', nilable = true }, true),
      values
    )
    run_aligned('table', simple_cfn('imploutputtable'), simple_lfn({ type = 'table' }, true), values)
    run_aligned(
      'nilable table',
      simple_cfn('imploutputnilabletable'),
      simple_lfn({ type = 'table', nilable = true }, true),
      values
    )
    run_aligned(
      'nilable unknown',
      simple_cfn('imploutputnilableunknown'),
      simple_lfn({ type = 'unknown', nilable = true }, true),
      values
    )
    -- imploutputunknown (non-nilable): nil excluded due to known mismatch (see below)
    run_aligned('unknown', simple_cfn('imploutputunknown'), simple_lfn({ type = 'unknown' }, true), values, true)
  end)

  -- Known mismatches between typecheck.h and typecheck.lua.
  -- When a mismatch is fixed, remove the test here and restore the value to the
  -- run_aligned call above (re-add '0'/'42' to enum, nil to imploutputunknown).
  describe('known mismatches', function()
    it('stubcheckenum rejects numeric strings that typecheck.lua accepts', function()
      -- C stub requires LUA_TNUMBER; typecheck.lua coerces via tonumber().
      -- Use '1' (a valid TestEnum value as string) for a clean accept on the Lua side.
      assert.is_false(caccepts(ctc.stubcheckenum, '1'))
      assert.is_true(laccepts({ type = { enum = 'TestEnum' } }, '1'))
    end)
    it('stubchecknilableenum rejects numeric strings that typecheck.lua accepts', function()
      assert.is_false(caccepts(ctc.stubchecknilableenum, '1'))
      assert.is_true(laccepts({ type = { enum = 'TestEnum' }, nilable = true }, '1'))
    end)
    it('imploutputunknown accepts nil that typecheck.lua rejects', function()
      -- C impl output check is a no-op; typecheck.lua enforces non-nilable
      assert.is_true(caccepts(ctc.imploutputunknown, nil))
      assert.is_false(laccepts({ type = 'unknown' }, nil, true))
    end)
  end)
end)
