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

local function u1(content, offset)
  return strbyte(content, offset + 1)
end

local function u2(content, offset)
  local w, x = strbyte(content, offset + 1, offset + 2)
  return w + x * 256
end

local function u3(content, offset)
  local w, x, y = strbyte(content, offset + 1, offset + 3)
  return w + x * 256 + y * 65536
end

local function u4(content, offset)
  local w, x, y, z = strbyte(content, offset + 1, offset + 4)
  return w + x * 256 + y * 65536 + z * 16777216
end

local function u5(content, offset)
  local w, x, y, z, zz = strbyte(content, offset + 1, offset + 5)
  return w + x * 256 + y * 65536 + z * 16777216 + zz * 4294967296
end

local un = {
  [1] = u1,
  [2] = u2,
  [3] = u3,
  [4] = u4,
  [5] = u5,
}

local function z(content, offset)
  local e = assert(strfind(content, '\0', offset + 1, true))
  return strsub(content, offset + 1, e - 1)
end

local function div(a, b)
  return math.floor(a / b)
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
  for i = 1, sig:len() - 2 do
    local c = sig:sub(i + 1, i + 1)
    if c ~= '.' then
      assert(goodsigs[c], 'unexpected sig char ' .. c)
      table.insert(tsig, { sig = c, field = i })
    end
  end
  local cur = vstruct.cursor(content)
  local h = header:read(cur)
  assert(h.magic == 'WDC4')
  assert(h.section_count >= 0)
  assert(h.total_field_count >= #tsig)
  assert(h.total_field_count * 24 == h.field_storage_info_size)
  assert(h.flags.has_offset_map == false)
  local shs = {}
  for i = 1, h.section_count do
    local sh = section_header:read(cur)
    assert(sh.id_list_size == 0 or sh.record_count * 4 == sh.id_list_size)
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
    if fsi.storage_type == 0 then
      assert(fsi.additional_data_size == 0)
      assert(fsi.field_offset_bits % 8 == 0)
      assert(fsi.field_offset_bits < h.bitpacked_data_offset * 8)
      assert(fsi.field_size_bits % 8 == 0)
      assert(fsi.field_size_bits <= 32)
      assert(fsi.cx1 == 0)
      assert(fsi.cx2 == 0)
      assert(fsi.cx3 == 0)
    elseif fsi.storage_type == 2 then
      assert(fsi.field_size_bits == 0)
      assert(fsi.cx2 == 0)
      assert(fsi.cx3 == 0)
    elseif fsi.storage_type == 3 then
      assert(fsi.field_size_bits > 0)
      assert(fsi.field_size_bits <= 32)
      assert(fsi.field_offset_bits >= h.bitpacked_data_offset * 8)
      assert(fsi.additional_data_size > 0)
      assert(fsi.cx3 == 0)
    elseif fsi.storage_type == 1 or fsi.storage_type == 5 then
      assert(fsi.field_size_bits > 0)
      assert(fsi.field_size_bits <= 32)
      assert(fsi.field_offset_bits >= h.bitpacked_data_offset * 8)
      assert(fsi.additional_data_size == 0)
      assert(fsi.cx3 == 0)
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
  do
    local roffset = 0
    for i = #shs, 1, -1 do
      shs[i].xoffset = roffset
      roffset = roffset + shs[i].record_count * h.record_size
    end
    local soffset = 0
    for i = 1, #shs do
      shs[i].xoffset = shs[i].xoffset + soffset
      soffset = soffset + shs[i].string_table_size
    end
  end
  return coroutine.wrap(function()
    for _, sh in ipairs(shs) do
      local rpos = sh.file_offset
      local spos = rpos + sh.record_count * h.record_size
      local ipos = spos + sh.string_table_size
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
        for k, ts in ipairs(tsig) do
          local fsi = fsis[ts.field]
          local fob = fsi.field_offset_bits
          local fsb = fsi.field_size_bits
          if fsi.storage_type == 0 then
            local foffset = fob / 8
            local v = un[fsb / 8](content, rpos + foffset)
            if ts.sig == 's' then
              local s = rpos + foffset + v - sh.xoffset
              t[k] = s >= spos and s < ipos and z(content, s) or ''
            else
              t[k] = v
            end
          elseif fsi.storage_type ~= 2 then
            local loff = div(fob, 8)
            local hoff = div(fob + fsb - 1, 8)
            local v = un[hoff - loff + 1](content, rpos + loff)
            local vv = div(v, 2 ^ (fob % 8)) % (2 ^ fsb)
            if fsi.storage_type == 1 or fsi.storage_type == 5 then
              t[k] = vv
            elseif fsi.storage_type == 3 then
              local p = u4(content, palletpos + pallet_offsets[ts.field] + vv * 4)
              if ts.sig == 'i' and p >= 2 ^ 31 then
                p = p - 2 ^ 32
              end
              t[k] = p
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
        if t[0] ~= 0 then
          for k, ts in ipairs(tsig) do
            local fsi = fsis[ts.field]
            if fsi.storage_type == 2 then
              t[k] = commons[ts.field][t[0]] or fsi.cx1
            end
          end
          local copies = {}
          for _, newid in ipairs(copytable[t[0]] or {}) do
            local tt = { [0] = newid }
            for k = 1, #tsig do
              tt[k] = t[k]
            end
            table.insert(copies, tt)
          end
          coroutine.yield(t)
          for k = #copies, 1, -1 do
            coroutine.yield(copies[k])
          end
        end
        rpos = rpos + h.record_size
      end
    end
  end)
end

return {
  rows = rows,
}