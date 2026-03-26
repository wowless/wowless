local T, getfenv, getmetatable, setfenv, setmetatable = ...
local function f() end
local function g() end
local env = {}
local mt = {}
T.check1(T.env, getfenv(f))
T.check1(f, setfenv(f, env))
T.check1(env, getfenv(f))
T.check1(nil, getmetatable(env))
T.check1(env, setmetatable(env, mt))
T.check1(mt, getmetatable(env))
T.check1(env, getfenv(f))
mt.__environment = g
T.check1(g, getfenv(f))
T.check2(false, 'cannot change a protected environment', pcall(setfenv, f, T.env))
mt.__environment = nil
T.check1(env, getfenv(f))
T.check1(f, setfenv(f, T.env))
T.check1(T.env, getfenv(f))
