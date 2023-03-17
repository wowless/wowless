local db2 = require('wowless.db2')
local vstruct = require('vstruct')

local header = vstruct.compile([[<
  magic: s4
  x4  -- record_count: u4
  x4  -- field_count: u4
  record_size: u4
  x4  -- string_table_size: u4
  x4  -- table_hash: u4
  x4  -- layout_hash: u4
  x4  -- min_id: u4
  x4  -- max_id: u4
  x4  -- locale: u4
  x2  -- flags: { [ 2 | x15 has_offset_map: b1 ] }
  x2  -- id_index: u2
  total_field_count: u4
  x4  -- bitpacked_data_offset: u4
  x4  -- lookup_column_count: u4
  field_storage_info_size: u4
  x4  -- common_data_size: u4
  x4  -- pallet_data_size: u4
  section_count: u4
]])

local section_header = vstruct.compile([[<
  x8  -- tact_key_hash: s8
  file_offset: u4
  x4  -- record_count: u4
  x4  -- string_table_size: u4
  x4  -- offset_records_end: u4
  x4  -- id_list_size: u4
  x4  -- relationship_data_size: u4
  x4  -- offset_map_id_count: u4
  x4  -- copy_table_count: u4
]])

local field = vstruct.compile([[<
  x2  -- size: i2
  position: u2
]])

local field_storage_info = vstruct.compile([[<
  field_offset_bits: u2
  field_size_bits: u2
  x4  -- additional_data_size: u4
  x4  -- storage_type: u4
  x4  -- cx1: u4
  x4  -- cx2: u4
  x4  -- cx3: u4
]])

local function spec2data(spec)
  local data = {}
  table.insert(
    data,
    header:write({
      field_storage_info_size = 24 * #spec.fields,
      magic = 'WDC3',
      record_size = 4 * #spec.fields,
      section_count = #spec.sections,
      total_field_count = #spec.fields,
    })
  )
  for _ in ipairs(spec.sections) do
    table.insert(
      data,
      section_header:write({
        file_offset = 112 + 28 * #spec.fields,
      })
    )
  end
  for i in ipairs(spec.fields) do
    table.insert(
      data,
      field:write({
        position = (i - 1) * 4,
      })
    )
  end
  for i in ipairs(spec.fields) do
    table.insert(
      data,
      field_storage_info:write({
        field_offset_bits = (i - 1) * 32,
        field_size_bits = 32,
      })
    )
  end
  return table.concat(data)
end

local function collect(data, sig)
  local rows = {}
  for row in db2.rows(data, sig) do
    table.insert(rows, row)
  end
  return rows
end

describe('db2', function()
  local tests = require('wowapi.yaml').parseFile('spec/wowless/db2tests.yaml')
  for k, v in pairs(tests) do
    it(k, function()
      assert.same(v.output, collect(spec2data(v.input), v.sig))
    end)
  end
end)
