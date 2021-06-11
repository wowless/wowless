local lfs = require('lfs')

local function loadToc(toc)
  local result = {}
  for line in io.lines(toc) do
    line = line:match('^%s*(.-)%s*$'):gsub('\\', '/')
    if line ~= '' and line:sub(1, 1) ~= '#' then
      local f = assert(io.open(line, "rb"))
      local content = f:read('*all')
      f:close()
      if content:sub(1, 3) == '\239\187\191' then
        content = content:sub(4)
      end
      if line:sub(-4) == '.lua' then
        table.insert(result, assert(loadstring(content)))
      elseif line:sub(-4) == '.xml' then
        print('ignoring xml file ' .. line)
      else
        print('ignoring unknown file type ' .. line)
      end
    end
  end
  return result
end

lfs.chdir('wowui/classic/FrameXML')
loadToc('FrameXML.toc')
