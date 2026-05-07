local T, GetNumTalentTabs, GetNumTalents, GetTalentPrereqs = ...
return {
  GetNumTalentTabs = function()
    local n = GetNumTalentTabs()
    assert(type(n) == 'number' and n >= 0, 'expected non-negative tab count')
  end,
  GetNumTalents = function()
    return {
      validTabs = function()
        for i = 1, GetNumTalentTabs() do
          assert(GetNumTalents(i) > 0, 'tab ' .. i .. ' has no talents')
        end
      end,
      outOfRange = function()
        return T.check1(0, GetNumTalents(GetNumTalentTabs() + 1))
      end,
    }
  end,
  GetTalentPrereqs = function()
    return {
      structure = function()
        local function check(...)
          local n = select('#', ...)
          assert(n % 4 == 0, 'return count ' .. n .. ' not a multiple of 4')
          for i = 1, n, 4 do
            local tier, col = select(i, ...)
            assert(type(tier) == 'number' and tier >= 1, 'prereq tier out of range')
            assert(type(col) == 'number' and col >= 1, 'prereq column out of range')
          end
        end
        for tab = 1, GetNumTalentTabs() do
          for talentIndex = 1, GetNumTalents(tab) do
            check(GetTalentPrereqs(tab, talentIndex))
          end
        end
      end,
      outOfRange = function()
        return T.check0(GetTalentPrereqs(1, 999999))
      end,
    }
  end,
}
