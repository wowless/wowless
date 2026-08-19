describe('xml', function()
  local xmlmodule = require('wowless.modules.xml')
  local function hasWarning(warnings, pattern)
    for _, w in ipairs(warnings) do
      if w:find(pattern, 1, true) then
        return true
      end
    end
    return false
  end
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local datalua = require('build.products.' .. p .. '.data')
      local parse = xmlmodule(datalua, { QueueEvent = function() end })
      -- ButtonText/NormalFont share a type (FontString/Font) with generic
      -- layered regions but belong to Button's own substitution group, not
      -- the generic one -- see issue #778.
      local cases = {
        ['rejects a Button-only child nested in an unrelated container'] = {
          xml = '<Ui><SimpleHTML><ButtonText/></SimpleHTML></Ui>',
          pattern = 'buttontext cannot be a child of simplehtml',
          expectWarning = true,
        },
        ['rejects a Button-only child at the document root'] = {
          xml = '<Ui><NormalFont/></Ui>',
          pattern = 'normalfont cannot be a child of ui',
          expectWarning = true,
        },
        ['still accepts those tags under their real parent'] = {
          xml = '<Ui><Button><ButtonText/><NormalFont/></Button></Ui>',
          pattern = 'cannot be a child of',
          expectWarning = false,
        },
        ['still accepts a plain FontString wherever generic layered regions go'] = {
          xml = '<Ui><SimpleHTML><FontString/></SimpleHTML></Ui>',
          pattern = 'cannot be a child of',
          expectWarning = false,
        },
      }
      for name, case in pairs(cases) do
        it(name, function()
          local _, warnings = parse(case.xml)
          assert.same(case.expectWarning, hasWarning(warnings, case.pattern))
        end)
      end
    end)
  end
end)
