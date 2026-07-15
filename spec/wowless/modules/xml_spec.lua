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
      local parse = xmlmodule(datalua)
      -- ButtonText/NormalFont share a type (FontString/Font) with generic
      -- layered regions but belong to Button's own substitution group, not
      -- the generic one -- see issue #778.
      it('rejects a Button-only child nested in an unrelated container', function()
        local _, warnings = parse('<Ui><SimpleHTML><ButtonText/></SimpleHTML></Ui>')
        assert(hasWarning(warnings, 'buttontext cannot be a child of simplehtml'))
      end)
      it('rejects a Button-only child at the document root', function()
        local _, warnings = parse('<Ui><NormalFont/></Ui>')
        assert(hasWarning(warnings, 'normalfont cannot be a child of ui'))
      end)
      it('still accepts those tags under their real parent', function()
        local _, warnings = parse('<Ui><Button><ButtonText/><NormalFont/></Button></Ui>')
        assert.False(hasWarning(warnings, 'cannot be a child of'))
      end)
      it('still accepts a plain FontString wherever generic layered regions go', function()
        local _, warnings = parse('<Ui><SimpleHTML><FontString/></SimpleHTML></Ui>')
        assert.False(hasWarning(warnings, 'cannot be a child of'))
      end)
    end)
  end
end)
