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

local id = vstruct.compile('<u4')

local function worker(content, sig)
  assert(sig == '{s}')
  local record = vstruct.compile('<u4')
  local cur = vstruct.cursor(content)
  local h = header:read(cur)
  assert(h.magic == 'WDC3')
  assert(h.total_field_count == 1)
  assert(h.total_field_count * 24 == h.field_storage_info_size)
  assert(h.flags.use_offset_map == false)
  local shs = {}
  for _ = 1, h.section_count do
    local sh = section_header:read(cur)
    assert(sh.record_count * 4 == sh.id_list_size)
    assert(sh.tact_key_hash == '\0\0\0\0\0\0\0\0')
    table.insert(shs, sh)
  end
  local fs = {}
  for _ = 1, h.total_field_count do
    local f = field:read(cur)
    assert(f.size == 0)
    assert(f.position == 0)
    table.insert(fs, f)
  end
  local fsis = {}
  for _ = 1, h.total_field_count do
    local fsi = field_storage_info:read(cur)
    assert(fsi.storage_type == 0)
    assert(fsi.field_offset_bits == 0)
    assert(fsi.field_size_bits == 32)
    assert(fsi.additional_data_size == 0)
    table.insert(fsis, fsi)
  end
  cur:seek(nil, h.pallet_data_size)
  cur:seek(nil, h.common_data_size)
  for i = 1, h.section_count do
    local sh = shs[i]
    assert(cur.pos == sh.file_offset)
    local records = {}
    for _ = 1, sh.record_count do
      record:read(cur, records)
    end
    cur:seek(nil, sh.string_table_size)
    local ids = {}
    for _ = 1, sh.record_count do
      id:read(cur, ids)
    end
    cur:seek(nil, sh.copy_table_count * 8)
    cur:seek(nil, sh.offset_map_id_count * 6)
    assert(sh.relationship_data_size == 0)
    cur:seek(nil, sh.offset_map_id_count * 4)
    for j = 1, sh.record_count do
      coroutine.yield({ [0] = ids[j], records[j] })
    end
  end
  assert(cur.pos == #content)
end

local function rows(content, sig)
  return coroutine.wrap(function()
    worker(content, sig)
  end)
end

return {
  rows = rows,
}
