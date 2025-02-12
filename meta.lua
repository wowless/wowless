---@meta

---@param f function
---@return any
function debug.getfunctionstats(f) end

---@param f function
---@return function
function debug.newcfunction(f) end

---@param f function
---@return function
function debug.newsecurefunction(f) end

---@param taint string?
function debug.setnewclosuretaint(taint) end

---@param enabled boolean
function debug.setprofilingenabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_issecure)
---@return boolean secure
function issecure() end

---@param a number
---@param b number
---@return number
function mod(a, b) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_securecallfunction)
---@generic A, R
---@param func fun(...: A): ...:R
---@param ... A
---@return R ...
function securecallfunction(func, ...) end

---@param delim string
---@param str string
---@return string ...
function strsplit(delim, str) end
