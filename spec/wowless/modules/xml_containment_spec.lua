-- Exercises wowless/modules/xml.lua's containment check directly (not
-- through the full addon/runtime pipeline -- see tools/xmlcontainment.lua's
-- comment for why the relation itself is pure structural data) for every
-- tag known to each product's xml.yaml, as a direct child of <Ui>: the
-- schema's own containment relation (contents/extends/sealed, see
-- xmlcontainment.legalChildren) says which of them should be accepted vs
-- rejected, and this checks the parser actually agrees.
--
-- Schema-`virtual` tags (data/schemas/xml.yaml's own `virtual` flag on a
-- tag definition -- an abstract-only base type like LayoutFrame, not the
-- runtime `virtual="true"` attribute any concrete tag can carry) are
-- skipped entirely: xml.lua hard-errors on instantiating one directly,
-- regardless of context, so there's no accept/reject outcome to check.
--
-- A legal, singleton-backed uiobject tag (e.g. Minimap) is also skipped:
-- the schema does consider it a legal child here, but this module alone
-- never creates a live object (that's xmleval's job, a level up), so
-- there's no actual double-instantiation risk in this test -- it's
-- skipped anyway, on the theory that a containment test shouldn't need to
-- know about object-instantiation concerns like singletons at all; if a
-- higher-level test ever exercises these candidates through the full
-- runtime, it will need this same exclusion for real.
--
-- Scoped to Ui's own direct children only, for now -- deliberately not a
-- breadth-first walk of the whole containment tree yet. The reusable part
-- is xmlcontainment.legalChildren itself, which already works for any
-- parent tag; extending this file to recurse into each accepted tag's own
-- children (nesting <Ui><Accepted><Candidate/></Accepted></Ui> and so on)
-- is future work, not a rewrite.
describe('xml containment', function()
  local xmlmodule = require('wowless.modules.xml')
  local xmlcontainment = require('tools.xmlcontainment')

  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local xml = require('build.data.products.' .. p .. '.xml')
      local uiobjects = require('build.data.products.' .. p .. '.uiobjects')
      local datalua = require('build.products.' .. p .. '.data')
      local legal = xmlcontainment.legalChildren(xml, 'Ui')
      local parse = xmlmodule(datalua, { QueueEvent = function() end })

      local function objtypeOf(tag)
        local impl = xml[tag].impl
        return type(impl) == 'table' and impl.uiobject
      end

      for tag, def in pairs(xml) do
        local objtype = legal[tag] and objtypeOf(tag)
        local singleton = objtype and uiobjects[objtype].singleton
        if not def.virtual and not singleton then
          it(tag .. (legal[tag] and ' is accepted as a child of Ui' or ' is rejected as a child of Ui'), function()
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
  end
end)
