local bit = require('bit')
local vstruct = require('vstruct')

local header = vstruct.compile([[<
  magic: s4
  record_count: u4
  field_count: u4
  record_size: u4
  string_table_size: u4
  table_hash: u4
  layout_hash: u4
  min_id: u4
  max_id: u4
  locale: u4
  flags: { [ 2 | x13 ignore_id_index: b1 x1 has_offset_map: b1 ] }
  id_index: u2
  total_field_count: u4
  bitpacked_data_offset: u4
  lookup_column_count: u4
  field_storage_info_size: u4
  common_data_size: u4
  pallet_data_size: u4
  section_count: u4
]])

local section_header = vstruct.compile([[<
  tact_key_hash: s8
  file_offset: u4
  record_count: u4
  string_table_size: u4
  offset_records_end: u4
  id_list_size: u4
  relationship_data_size: u4
  offset_map_id_count: u4
  copy_table_count: u4
]])

local field_storage_info = vstruct.compile([[<
  field_offset_bits: u2
  field_size_bits: u2
  additional_data_size: u4
  storage_type: u4
  cx1: u4
  cx2: u4
  cx3: u4
]])

local strbyte = string.byte
local strfind = string.find
local strsub = string.sub

local function u4(content, offset)
  local w, x, y, z = strbyte(content, offset + 1, offset + 4)
  return w + (x or 0) * 256 + (y or 0) * 65536 + (z or 0) * 16777216
end

local function z(content, offset)
  local e = assert(strfind(content, '\0', offset + 1, true))
  return strsub(content, offset + 1, e - 1)
end

local function i4tou4(x)
  return x >= 0 and x or 2 ^ 32 + x
end

local zerohash = '\0\0\0\0\0\0\0\0'

local goodsigs = {
  i = true,
  s = true,
  u = true,
}

local function rows(content, sig)
  assert(sig:sub(1, 1) == '{')
  assert(sig:sub(-1) == '}')
  local tsig = {}
  for i = 2, sig:len() - 1 do
    local c = sig:sub(i, i)
    assert(goodsigs[c], 'unexpected sig char ' .. c)
    table.insert(tsig, c)
  end
  local cur = vstruct.cursor(content)
  local h = header:read(cur)
  assert(h.magic == 'WDC4')
  assert(h.section_count >= 0)
  assert(h.total_field_count == #tsig)
  assert(h.total_field_count * 24 == h.field_storage_info_size)
  assert(h.flags.has_offset_map == false)
  local shs = {}
  for i = 1, h.section_count do
    local sh = section_header:read(cur)
    assert(sh.id_list_size == 0 or sh.record_count * 4 == sh.id_list_size)
    -- Hack: first section must not be encrypted, all others must be.
    assert((i == 1) == (sh.tact_key_hash == zerohash))
    table.insert(shs, sh)
  end
  cur:seek(nil, h.total_field_count * 4) -- ignore struct field_structure
  local fsis = {}
  local common_offsets = {}
  local common_offset = 0
  local pallet_offsets = {}
  local pallet_offset = 0
  for _ = 1, h.total_field_count do
    local fsi = field_storage_info:read(cur)
    -- Hacky check to ensure field can be read by masking a u4.
    assert(fsi.field_size_bits + math.fmod(fsi.field_offset_bits, 8) <= 32)
    assert(fsi.field_offset_bits + fsi.field_size_bits <= h.record_size * 8)
    if fsi.storage_type == 0 then
      assert(fsi.additional_data_size == 0)
    elseif fsi.storage_type == 2 then
      assert(fsi.field_size_bits == 0)
    elseif fsi.storage_type == 3 then
      assert(fsi.field_size_bits > 0)
      assert(fsi.additional_data_size > 0)
    elseif fsi.storage_type == 1 or fsi.storage_type == 5 then
      assert(fsi.field_size_bits > 0)
      assert(fsi.additional_data_size == 0)
    else
      error('unsupported storage type ' .. fsi.storage_type)
    end
    table.insert(fsis, fsi)
    table.insert(common_offsets, common_offset)
    table.insert(pallet_offsets, pallet_offset)
    if fsi.storage_type == 2 then
      common_offset = common_offset + fsi.additional_data_size
    elseif fsi.storage_type == 3 then
      pallet_offset = pallet_offset + fsi.additional_data_size
    end
  end
  assert(common_offset == h.common_data_size)
  assert(pallet_offset == h.pallet_data_size)
  local palletpos = cur.pos
  local commonpos = palletpos + h.pallet_data_size
  local encpos = commonpos + h.common_data_size
  local pos = encpos
  for _, sh in ipairs(shs) do
    if sh.tact_key_hash ~= zerohash then
      local count = u4(content, pos)
      pos = pos + 4 + count * 4
    end
  end
  for _, sh in ipairs(shs) do
    assert(pos == sh.file_offset)
    pos = pos + sh.record_count * h.record_size
    pos = pos + sh.string_table_size
    pos = pos + sh.id_list_size
    pos = pos + sh.copy_table_count * 8
    pos = pos + sh.offset_map_id_count * 6
    pos = pos + sh.relationship_data_size
    pos = pos + sh.offset_map_id_count * 4
  end
  assert(pos == #content)
  local commons = {}
  for i, fsi in ipairs(fsis) do
    local common = {}
    if fsi.storage_type == 2 then
      local start = commonpos + common_offsets[i]
      for c = start, start + fsi.additional_data_size - 1, 8 do
        local recordid = u4(content, c)
        local value = u4(content, c + 4)
        common[recordid] = value
      end
    end
    table.insert(commons, common)
  end
  local roffset = 0
  for i = 2, #shs do
    roffset = roffset + shs[i].record_count * h.record_size
  end
  return coroutine.wrap(function()
    -- Only process the first section for now; the rest are encrypted.
    if h.section_count > 0 then
      local sh = shs[1]
      local rpos = sh.file_offset
      local ipos = rpos + sh.record_count * h.record_size + sh.string_table_size
      local cpos = ipos + sh.id_list_size
      local copytable = {}
      for _ = 1, sh.copy_table_count do
        local newid = u4(content, cpos)
        local copiedid = u4(content, cpos + 4)
        copytable[copiedid] = copytable[copiedid] or {}
        table.insert(copytable[copiedid], newid)
        cpos = cpos + 8
      end
      for _ = 1, sh.record_count do
        local t = {}
        for k = 1, h.total_field_count do
          local fsi = fsis[k]
          if fsi.storage_type ~= 2 then
            local foffset = math.floor(fsi.field_offset_bits / 8)
            local boffset = fsi.field_offset_bits - foffset * 8
            local mask = 2 ^ (boffset + fsi.field_size_bits) - 2 ^ boffset
            local v = u4(content, rpos + foffset)
            local vv = i4tou4(bit.rshift(bit.band(v, mask), boffset))
            if fsi.storage_type == 0 then
              -- TODO fix this for sections besides the first
              t[k] = tsig[k] == 's' and z(content, rpos + foffset + vv - roffset) or vv
            elseif fsi.storage_type == 1 or fsi.storage_type == 5 then
              t[k] = vv
            elseif fsi.storage_type == 3 then
              t[k] = u4(content, palletpos + pallet_offsets[k] + vv * 4)
            else
              error('internal error')
            end
          end
        end
        if sh.id_list_size > 0 then
          t[0] = u4(content, ipos)
          ipos = ipos + 4
        elseif not h.flags.ignore_id_index then
          t[0] = t[h.id_index + 1]
        end
        for k = 1, h.total_field_count do
          local fsi = fsis[k]
          if fsi.storage_type == 2 then
            t[k] = commons[k][t[0]] or fsi.cx1
          end
        end
        rpos = rpos + h.record_size
        local copies = {}
        for _, newid in ipairs(copytable[t[0]] or {}) do
          local tt = { [0] = newid }
          for k = 1, h.total_field_count do
            tt[k] = t[k]
          end
          table.insert(copies, tt)
        end
        coroutine.yield(t)
        for k = #copies, 1, -1 do
          coroutine.yield(copies[k])
        end
      end
    end
  end)
end

return {
  rows = rows,
}
