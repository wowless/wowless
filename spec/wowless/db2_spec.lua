local db2 = require('wowless.db2')
local vstruct = require('vstruct')

local header = vstruct.compile([[<
  magic: s4
  record_count: u4
  x4  -- field_count: u4
  record_size: u4
  string_table_size: u4
  x4  -- table_hash: u4
  x4  -- layout_hash: u4
  x4  -- min_id: u4
  x4  -- max_id: u4
  x4  -- locale: u4
  flags: { [ 2 | x15 has_offset_map: b1 ] }
  x2  -- id_index: u2
  total_field_count: u4
  x4  -- bitpacked_data_offset: u4
  x4  -- lookup_column_count: u4
  field_storage_info_size: u4
  common_data_size: u4
  pallet_data_size: u4
  section_count: u4
]])

local section_header = vstruct.compile([[<
  x8  -- tact_key_hash: s8
  file_offset: u4
  record_count: u4
  string_table_size: u4
  x4  -- offset_records_end: u4
  x4  -- id_list_size: u4
  x4  -- relationship_data_size: u4
  x4  -- offset_map_id_count: u4
  x4  -- copy_table_count: u4
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

local function collect(data, sig)
  local rows = {}
  for k in db2.rows(data, sig) do
    table.insert(rows, k)
  end
  return rows
end

describe('db2', function()
  local tests = require('wowapi.yaml').parseFile('spec/wowless/db2tests.yaml')
  for k, v in pairs(tests) do
    it(k, function()
      local data = { header:write(v.input.header) }
      for _, sh in ipairs(v.input.section_headers) do
        table.insert(data, section_header:write(sh))
      end
      for _, f in ipairs(v.input.fields) do
        table.insert(data, field:write(f))
      end
      for _, fsi in ipairs(v.input.field_storage_infos) do
        table.insert(data, field_storage_info:write(fsi))
      end
      assert.same(v.output, collect(table.concat(data), v.sig))
    end)
  end
end)
