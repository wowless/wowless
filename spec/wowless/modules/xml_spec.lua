describe('xml', function()
  local xmlmodule = require('wowless.modules.xml')
  local xmlcontainment = require('tools.xmlcontainment')
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

      -- Exhaustively checks every tag known to this product's schema, as a
      -- direct child of <Ui>: the schema's own containment relation
      -- (contents/extends/sealed, see xmlcontainment.legalChildren) says
      -- which of them should be accepted vs rejected, and this checks the
      -- parser actually agrees.
      --
      -- Schema-`virtual` tags (data/schemas/xml.yaml's own `virtual` flag
      -- on a tag definition -- an abstract-only base type like
      -- LayoutFrame, not the runtime `virtual="true"` attribute any
      -- concrete tag can carry) are skipped entirely: xml.lua hard-errors
      -- on instantiating one directly, regardless of context, so there's
      -- no accept/reject outcome to check.
      --
      -- A legal, singleton-backed uiobject tag (e.g. Minimap) is also
      -- skipped: the schema does consider it a legal child here, but this
      -- module alone never creates a live object (that's xmleval's job, a
      -- level up), so there's no actual double-instantiation risk in this
      -- test -- it's skipped anyway, on the theory that a containment
      -- test shouldn't need to know about object-instantiation concerns
      -- like singletons at all; if a higher-level test ever exercises
      -- these candidates through the full runtime, it will need this same
      -- exclusion for real.
      --
      -- Scoped to Ui's own direct children only, for now -- deliberately
      -- not a breadth-first walk of the whole containment tree yet. The
      -- reusable part is xmlcontainment.legalChildren itself, which
      -- already works for any parent tag; extending this to recurse into
      -- each accepted tag's own children (nesting
      -- <Ui><Accepted><Candidate/></Accepted></Ui> and so on) is future
      -- work, not a rewrite.
      describe('every tag as a child of Ui', function()
        local xml = require('build.data.products.' .. p .. '.xml')
        local uiobjects = require('build.data.products.' .. p .. '.uiobjects')
        local legal = xmlcontainment.legalChildren(xml, 'Ui')
        local function objtypeOf(tag)
          local impl = xml[tag].impl
          return type(impl) == 'table' and impl.uiobject
        end
        for tag, def in pairs(xml) do
          local objtype = legal[tag] and objtypeOf(tag)
          local singleton = objtype and uiobjects[objtype].singleton
          if not def.virtual and not singleton then
            it(tag .. (legal[tag] and ' is accepted' or ' is rejected'), function()
              local _, warnings = parse('<Ui><' .. tag .. '/></Ui>')
              if legal[tag] then
                assert.same({}, warnings)
              else
                assert.same({ tag:lower() .. ' cannot be a child of ui' }, warnings)
              end
            end)
          end
        end
      end)
    end)
  end
end)
