local _, G = ...
G.testsuite.uiobjects = function()
  local assertEquals = G.assertEquals
  local check0 = G.check0
  local check1 = G.check1
  local check2 = G.check2
  local check3 = G.check3
  local check4 = G.check4
  return {
    Frame = function()
      return {
        ['creation with frame in name position'] = function()
          local f = CreateFrame('Frame')
          local g = CreateFrame('Frame', f)
          assert(g:GetName() == nil)
          assert(g:GetParent() == nil)
        end,
        ['creation with number name'] = function()
          assertEquals('999', CreateFrame('Frame', 999):GetName())
        end,
        ['kid order'] = function()
          return {
            ['three'] = function()
              local f = CreateFrame('Frame')
              local g = CreateFrame('Frame', nil, f)
              local h = CreateFrame('Frame', nil, f)
              local i = CreateFrame('Frame', nil, f)
              check1(3, f:GetNumChildren())
              check3(g, h, i, f:GetChildren())
              h:SetParent(nil)
              check1(2, f:GetNumChildren())
              check2(g, i, f:GetChildren())
              h:SetParent(f)
              check1(3, f:GetNumChildren())
              check3(g, i, h, f:GetChildren())
            end,
            ['two'] = function()
              local f = CreateFrame('Frame')
              local g = CreateFrame('Frame')
              local h = CreateFrame('Frame')
              g:SetParent(f)
              h:SetParent(f)
              check1(2, f:GetNumChildren())
              check2(g, h, f:GetChildren())
              g:SetParent(f)
              check1(2, f:GetNumChildren())
              check2(g, h, f:GetChildren())
            end,
          }
        end,
        ['level'] = function()
          local f = CreateFrame('Frame')
          local g = CreateFrame('Frame')
          local h = CreateFrame('Frame')
          assertEquals(0, f:GetFrameLevel())
          g:SetParent(f)
          assertEquals(1, g:GetFrameLevel())
          f:SetFrameLevel(5)
          assertEquals(5, f:GetFrameLevel())
          assertEquals(6, g:GetFrameLevel())
          f:SetParent(h)
          assertEquals(0, h:GetFrameLevel())
          assertEquals(1, f:GetFrameLevel())
          assertEquals(2, g:GetFrameLevel())
          f:SetParent(nil)
          f:SetFrameLevel(42)
          assertEquals(false, f:HasFixedFrameLevel())
          f:SetFixedFrameLevel(true)
          assertEquals(true, f:HasFixedFrameLevel())
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetParent(h)
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetFixedFrameLevel(false)
          assertEquals(false, f:HasFixedFrameLevel())
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetParent(h)
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetParent(nil)
          f:SetParent(h)
          assertEquals(1, f:GetFrameLevel())
          assertEquals(2, g:GetFrameLevel())
        end,
        ['parent keys'] = function()
          local up = CreateFrame('Frame')
          local down = CreateFrame('Frame', nil, up)
          check1(nil, down:GetParentKey())
          up.moo = down
          check1('moo', down:GetParentKey())
          check0(down:SetParentKey('cow'))
          assertEquals(up.cow, down)
          if up.ClearParentKey then
            assertEquals(nil, up.moo)
          else
            assertEquals(up.moo, down)
            check1('moo', down:GetParentKey())
            up.moo = nil
          end
          check1('cow', down:GetParentKey())
          up.cow = nil
          check1(nil, down:GetParentKey())
        end,
      }
    end,

    GameTooltip = function()
      local f = G.retn
      return {
        init = function()
          local gt = f(1, CreateFrame('GameTooltip'))
          return {
            GetAnchorType = function()
              assertEquals('ANCHOR_', f(1, gt:GetAnchorType()):sub(1, 7))
            end,
            GetChildren = function()
              f(0, gt:GetChildren())
            end,
            GetNumChildren = function()
              assertEquals(0, f(1, gt:GetNumChildren()))
            end,
            GetNumRegions = function()
              assertEquals(0, f(1, gt:GetNumRegions()))
            end,
            GetOwner = function()
              assertEquals(nil, f(1, gt:GetOwner()))
            end,
            GetRegions = function()
              f(0, gt:GetRegions())
            end,
            NumLines = function()
              assertEquals(0, f(1, gt:NumLines()))
            end,
          }
        end,
        SetOwner = function()
          return {
            AnchorTypes = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              local owner = f(1, CreateFrame('Frame'))
              local anchorTypes = {
                'ANCHOR_BOTTOM',
                'ANCHOR_BOTTOMLEFT',
                'ANCHOR_BOTTOMRIGHT',
                'ANCHOR_CURSOR',
                'ANCHOR_LEFT',
                'ANCHOR_NONE',
                'ANCHOR_PRESERVE',
                'ANCHOR_RIGHT',
                'ANCHOR_TOP',
                'ANCHOR_TOPLEFT',
                'ANCHOR_TOPRIGHT',
              }
              local tests = {}
              for _, anchorType in ipairs(anchorTypes) do
                tests[anchorType] = function()
                  f(0, gt:SetOwner(owner, anchorType))
                  assertEquals(anchorType, f(1, gt:GetAnchorType()))
                end
              end
              return tests
            end,
            InvalidAnchorType = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              local owner = f(1, CreateFrame('Frame'))
              f(0, gt:SetOwner(owner, 'invalid'))
              assertEquals('ANCHOR_LEFT', f(1, gt:GetAnchorType()))
            end,
            NoArgs = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              assertEquals(false, pcall(gt.SetOwner, gt))
            end,
            OneArg = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              local owner = f(1, CreateFrame('Frame'))
              f(0, gt:SetOwner(owner))
              return {
                GetAnchorType = function()
                  assertEquals('ANCHOR_LEFT', f(1, gt:GetAnchorType()))
                end,
                GetOwner = function()
                  assertEquals(owner, f(1, gt:GetOwner()))
                end,
                IsOwned = function()
                  assertEquals(true, f(1, gt:IsOwned(owner)))
                end,
              }
            end,
          }
        end,
      }
    end,

    ScrollFrame = function()
      return {
        SetScrollChild = function()
          local f = CreateFrame('ScrollFrame')
          assertEquals(nil, f:GetScrollChild())
          local g = CreateFrame('Frame', 'WowlessScrollFrameChild')
          f:SetScrollChild(g)
          assertEquals(g, f:GetScrollChild())
          assertEquals(f, g:GetParent())
          assertEquals(false, pcall(f.SetScrollChild, f, nil))
          assertEquals(false, pcall(f.SetScrollChild, f, 'WowlessScrollFrameChild'))
          assertEquals(false, pcall(f.SetScrollChild, f))
        end,
      }
    end,

    Texture = function()
      local t = CreateFrame('Frame'):CreateTexture()
      assertEquals('BLEND', t:GetBlendMode())
      t:SetColorTexture(0.8, 0.6, 0.4, 0.2)
      assertEquals(IsTestBuild() and 'FileData ID 0' or nil, t:GetTexture())
      check4(1, 1, 1, 1, t:GetVertexColor())
      t:SetTexture(136235)
      assertEquals(136235, t:GetTexture())
      t:SetColorTexture(0.8, 0.6, 0.4, 0.2)
      assertEquals(IsTestBuild() and 'FileData ID 0' or nil, t:GetTexture())
    end,
  }
end
