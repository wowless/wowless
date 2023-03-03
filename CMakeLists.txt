cmake_minimum_required(VERSION 3.24)
project(wowless)

set(BUILD_SHARED_LIBS OFF)
set(BUILD_LUA OFF)
set(BUILD_LUAC OFF)
set(EXPAT_BUILD_EXAMPLES OFF)
set(EXPAT_BUILD_TESTS OFF)
set(EXPAT_BUILD_TOOLS OFF)
set(LUA_CPATH_CUSTOM ";" CACHE STRING "disable dynamic C Lua modules")

add_compile_options(-D_GNU_SOURCE -DNDEBUG -flto -O3)

include(FetchContent)
FetchContent_Declare(
  elune
  GIT_REPOSITORY https://github.com/meorawr/elune.git
  GIT_TAG 43c8c48ccbfe09084bc3ef42f745f253c228e26e
)
FetchContent_Declare(
  expat
  GIT_REPOSITORY https://github.com/libexpat/libexpat.git
  GIT_TAG R_2_5_0
  SOURCE_SUBDIR expat
)
FetchContent_Declare(
  lsqlite3
  URL http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09y.zip
  URL_HASH MD5=57d7a8bf5ae15d22044ed64343a39d89
)
FetchContent_Declare(
  luaexpat
  GIT_REPOSITORY https://github.com/lunarmodules/luaexpat.git
  GIT_TAG 1.4.1
)
FetchContent_Declare(
  luafilesystem
  GIT_REPOSITORY https://github.com/lunarmodules/luafilesystem.git
  GIT_TAG v1_8_0
)
FetchContent_MakeAvailable(
  elune
  expat
  lsqlite3
  luaexpat
  luafilesystem
)

add_executable(
  wowless
  main.c
  wowless/ext.c
  ${lsqlite3_SOURCE_DIR}/lsqlite3.c
  ${lsqlite3_SOURCE_DIR}/sqlite3.c
  ${luaexpat_SOURCE_DIR}/src/lxplib.c
  ${luafilesystem_SOURCE_DIR}/src/lfs.c
)
target_link_libraries(wowless expat liblua pthread)

if(EMSCRIPTEN)
  target_link_options(
    wowless PRIVATE
    -sALLOW_MEMORY_GROWTH
    --preload-file=${wowless_SOURCE_DIR}/wowless.lua@wowless.lua
    --preload-file=${wowless_SOURCE_DIR}/wowless@wowless
    --preload-file=${wowless_SOURCE_DIR}/build/flavors.lua@build/flavors.lua
    --preload-file=${wowless_SOURCE_DIR}/build/products/wow@build/products/wow
    --preload-file=${wowless_SOURCE_DIR}/extracts/wow@extracts/wow
    --preload-file=${wowless_SOURCE_DIR}/wowapi@wowapi
    --preload-file=/usr/local/share/lua/5.1
  )
endif()
