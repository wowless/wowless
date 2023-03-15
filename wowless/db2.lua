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
  flags: { [ 2 | x14 use_offset_map: b1 x1 ] }
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

local field = vstruct.compile([[<
  size: i2
  position: u2
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
  return w + x * 256 + y * 65536 + z * 16777216
end

local function z(content, offset)
  local e = assert(strfind(content, '\0', offset + 1, true))
  return strsub(content, offset + 1, e - 1)
end

local function rows(content, sig)
  assert(sig:sub(1, 1) == '{')
  assert(sig:sub(-1) == '}')
  local tsig = {}
  for i = 2, sig:len() - 1 do
    local c = sig:sub(i, i)
    assert(c == 's' or c == 'u')
    table.insert(tsig, c)
  end
  local cur = vstruct.cursor(content)
  local h = header:read(cur)
  assert(h.magic == 'WDC3')
  assert(h.section_count == 1) -- see string offset TODO below
  assert(h.total_field_count == #tsig)
  assert(h.total_field_count * 24 == h.field_storage_info_size)
  assert(h.flags.use_offset_map == false)
  local shs = {}
  for _ = 1, h.section_count do
    local sh = section_header:read(cur)
    assert(sh.record_count * 4 == sh.id_list_size)
    assert(sh.relationship_data_size == 0)
    assert(sh.tact_key_hash == '\0\0\0\0\0\0\0\0')
    table.insert(shs, sh)
  end
  local fs = {}
  for _ = 1, h.total_field_count do
    local f = field:read(cur)
    assert(f.size == 0 or f.size == 32)
    f.size = 32
    assert(f.position % 4 == 0)
    table.insert(fs, f)
  end
  local fsis = {}
  for i = 1, h.total_field_count do
    local fsi = field_storage_info:read(cur)
    local f = fs[i]
    assert(fsi.field_offset_bits >= f.position * 8)
    assert(fsi.field_offset_bits + fsi.field_size_bits <= f.position * 8 + f.size)
    if fsi.storage_type == 0 then
      assert(fsi.field_size_bits == 32)
      assert(fsi.additional_data_size == 0)
    elseif fsi.storage_type == 3 then
      assert(fsi.field_size_bits > 0)
      assert(fsi.field_size_bits <= 32)
      assert(fsi.additional_data_size > 0)
    elseif fsi.storage_type == 1 or fsi.storage_type == 5 then
      assert(fsi.field_size_bits > 0)
      assert(fsi.field_size_bits <= 32)
      assert(fsi.additional_data_size == 0)
    else
      error('unsupported storage type ' .. fsi.storage_type)
    end
    table.insert(fsis, fsi)
  end
  local palletpos = cur.pos
  local pos = cur.pos + h.pallet_data_size + h.common_data_size
  for _, sh in ipairs(shs) do
    assert(pos == sh.file_offset)
    pos = pos + sh.record_count * h.record_size
    pos = pos + sh.string_table_size
    pos = pos + sh.id_list_size
    pos = pos + sh.copy_table_count * 8
    pos = pos + sh.offset_map_id_count * 6
    pos = pos + sh.offset_map_id_count * 4
  end
  assert(pos == #content)
  return coroutine.wrap(function()
    for i = 1, h.section_count do
      local sh = shs[i]
      local rpos = sh.file_offset
      local ipos = rpos + sh.record_count * h.record_size + sh.string_table_size
      for _ = 1, sh.record_count do
        local t = { [0] = u4(content, ipos) }
        for k = 1, h.total_field_count do
          local foffset = rpos + fs[k].position
          local v = u4(content, foffset)
          local c = tsig[k]
          if c == 's' then
            -- TODO this is only correct in simple cases; see the WDC2 docs
            local offset = foffset + v
            t[k] = z(content, offset)
          elseif c == 'u' then
            local offset = palletpos + v * 4
            t[k] = u4(content, offset)
          else
            error('internal error')
          end
        end
        rpos = rpos + h.record_size
        ipos = ipos + 4
        coroutine.yield(t)
      end
    end
  end)
end

return {
  rows = rows,
}
