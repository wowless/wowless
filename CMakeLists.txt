cmake_minimum_required(VERSION 3.24)
project(wowless)

set(BUILD_SHARED_LIBS OFF)
set(BUILD_SUMMARY ON)
set(LUA_USE_READLINE OFF)
set(LUA_DISABLE_LOADLIB ON)

add_compile_options(-D_GNU_SOURCE -DNDEBUG -flto -O3)
add_link_options(-ffast-math)

include(FetchContent)
FetchContent_Declare(
  elune
  GIT_REPOSITORY https://github.com/meorawr/elune.git
  GIT_TAG 7fc7271922fbc0a371ef15d699ffa0b2be649a81
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
  URL_HASH MD5=1f937ed6bf9d5980239da516c424d7b6
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
  URL https://zlib.net/fossils/zlib-1.3.tar.gz
  URL_HASH SHA256=ff0ba4c292013dbc27530b3a81e1f9a813cd39de01ca5e0f8bf355702efa593e
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

add_custom_command(
  OUTPUT rocks.c
  COMMAND luarocks build --only-deps --tree luarocks ${CMAKE_CURRENT_SOURCE_DIR}/wowless-scm-0.rockspec
  COMMAND bash -c \"lua ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua > rocks.c\"
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
    ${CMAKE_CURRENT_SOURCE_DIR}/wowless-scm-0.rockspec
)

add_executable(
  wowless
  main.c
  rocks.c
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
target_link_libraries(wowless expat liblua pthread yaml zlibstatic -static)
