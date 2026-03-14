-- Generates runtime/modules.lua from data/modules.yaml and wowless/modules/.
-- Module source files are inlined into the output so lua2c only needs one
-- entry. A depfile is written alongside the output to track the module files.
local yaml_path = arg[1]
local output_path = arg[2]
local modules_dir = arg[3]

local t = assert(require('wowapi.yaml').parseFile(yaml_path))

local util = require('tools.util')
local sort = require('pl.tablex').sort

-- Topological sort via resty.tsort.
local tt = require('resty.tsort').new()
for name in pairs(t) do
  tt:add(name)
  for dep in pairs((t[name] or {}).deps or {}) do
    tt:add(dep, name)
  end
end
local order = assert(tt:sort())

-- Read module source files and track deps for the depfile.
local module_sources = {}
local filedeps = {}
for name in sort(t) do
  if not t[name].root then
    local path = modules_dir .. '/' .. name .. '.lua'
    local f = assert(io.open(path, 'r'), 'missing module file: ' .. path)
    module_sources[name] = f:read('*a')
    f:close()
    filedeps[path] = true
  end
end

local lines = {}
local function emit(s)
  table.insert(lines, s)
end

local function longeq(s)
  local eq = ''
  while s:find(']' .. eq .. ']', 1, true) do
    eq = eq .. '='
  end
  return eq
end

-- Load each module via loadstring_untainted so stack traces reference the source file.
for name in sort(module_sources) do
  local src = module_sources[name]
  local eq = longeq(src)
  local chunkname = '@' .. modules_dir .. '/' .. name .. '.lua'
  emit(('local %s_fn = assert(loadstring_untainted([%s['):format(name, eq))
  emit((src:gsub('\n$', '')))
  emit((']%s], %q))()'):format(eq, chunkname))
  emit('')
end

emit('return function(roots)')

-- Root module assignments (alphabetical for readability).
for name in sort(t) do
  local spec = t[name]
  if spec.root then
    if spec.root.default ~= nil then
      emit(('  local %s = roots.%s or (%s)'):format(name, name, spec.root.default))
    else
      emit(('  local %s = assert(roots.%s)'):format(name, name))
    end
  end
end

-- Non-root modules in topological order with explicit deps.
for _, name in ipairs(order) do
  local spec = t[name]
  if not spec.root then
    local deps = {}
    for dep in sort(spec.deps or {}) do
      table.insert(deps, dep)
    end
    emit(('  local %s = %s_fn(%s)'):format(name, name, table.concat(deps, ', ')))
  end
end

-- Return table (alphabetical).
emit('  return {')
for name in sort(t) do
  emit(('    %s = %s,'):format(name, name))
end
emit('  }')
emit('end')

util.writedeps(output_path, filedeps)
assert(require('pl.dir').makepath(require('pl.path').dirname(output_path)))
util.writeifchanged(output_path, table.concat(lines, '\n') .. '\n')
