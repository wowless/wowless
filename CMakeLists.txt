cmake_minimum_required(VERSION 3.24)
project(wowless)

set(BUILD_SHARED_LIBS OFF)
set(BUILD_SUMMARY ON)
set(LUA_CPATH_CUSTOM ";" CACHE STRING "disable dynamic C Lua modules")
set(LUA_USE_READLINE OFF)

add_compile_options(-D_GNU_SOURCE -DNDEBUG -flto -O3)
add_link_options(-ffast-math)

include(FetchContent)
FetchContent_Declare(
  elune
  GIT_REPOSITORY https://github.com/meorawr/elune.git
  GIT_TAG f051f75a3e963130c2d1ad98f56868bfc6b2798d
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
FetchContent_Declare(
  lyaml
  GIT_REPOSITORY https://github.com/gvvaughan/lyaml.git
  GIT_TAG v6.2.8
)
FetchContent_Declare(
  lzlib
  GIT_REPOSITORY https://github.com/luadist/lzlib.git
  GIT_TAG 0.4.3
  SOURCE_SUBDIR foo
)
FetchContent_Declare(
  sqlite3
  URL https://www.sqlite.org/2023/sqlite-amalgamation-3410200.zip
  URL_HASH SHA3_256=c51ca72411b8453c64e0980be23bc9b9530bdc3ec1513e06fbf022ed0fd02463
)
FetchContent_Declare(
  yaml
  GIT_REPOSITORY https://github.com/yaml/libyaml.git
  GIT_TAG 0.2.5
)
FetchContent_Declare(
  zlib
  URL https://zlib.net/zlib-1.2.13.tar.gz
  URL_HASH SHA256=b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30
)
FetchContent_MakeAvailable(
  elune
  expat
  lsqlite3
  luaexpat
  luafilesystem
  lyaml
  lzlib
  sqlite3
  yaml
  zlib
)

set_property(
  SOURCE ${lyaml_SOURCE_DIR}/ext/yaml/yaml.c
  APPEND PROPERTY COMPILE_DEFINITIONS VERSION="wowless"
)
set_property(
  SOURCE ${lzlib_SOURCE_DIR}/lzlib.c
  APPEND PROPERTY INCLUDE_DIRECTORIES ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR}
)

add_executable(
  wowless
  main.c
  wowless/ext.c
  ${lsqlite3_SOURCE_DIR}/lsqlite3.c
  ${luaexpat_SOURCE_DIR}/src/lxplib.c
  ${luafilesystem_SOURCE_DIR}/src/lfs.c
  ${lyaml_SOURCE_DIR}/ext/yaml/emitter.c
  ${lyaml_SOURCE_DIR}/ext/yaml/parser.c
  ${lyaml_SOURCE_DIR}/ext/yaml/scanner.c
  ${lyaml_SOURCE_DIR}/ext/yaml/yaml.c
  ${lzlib_SOURCE_DIR}/lzlib.c
  ${sqlite3_SOURCE_DIR}/sqlite3.c
)
target_link_libraries(wowless expat liblua pthread yaml zlibstatic)

if(EMSCRIPTEN)
  target_link_options(wowless PRIVATE -sALLOW_MEMORY_GROWTH)
  target_link_libraries(wowless nodefs.js noderawfs.js)
endif()
