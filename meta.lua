---@meta

---@param f function
---@return any
function debug.getfunctionstats(f) end

---@return taint string?
function debug.getstacktaint() end

---@return mode string
function debug.gettaintmode() end

---@param f function
---@return function
function debug.newsecurefunction(f) end

---@param taint string?
function debug.setnewclosuretaint(taint) end

---@param enabled boolean
function debug.setprofilingenabled(enabled) end

---@param taint string?
function debug.setstacktaint(taint) end

---@param mode string
function debug.settaintmode(mode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_issecure)
---@return boolean secure
function issecure() end

---@param chunk string
---@param name string?
---@return function?
---@return string?
function loadstring_untainted(chunk, name) end

---@param a number
---@param b number
---@return number
function mod(a, b) end

---@param delim string
---@param str string
---@return string ...
function strsplit(delim, str) end
