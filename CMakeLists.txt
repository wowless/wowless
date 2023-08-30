cmake_minimum_required(VERSION 3.24)
project(wowless)

set(BUILD_SHARED_LIBS OFF)
set(BUILD_SUMMARY ON)
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
  SOURCE_SUBDIR disable_cmakelists_txt
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
  SOURCE_SUBDIR disable_cmakelists_txt
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
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_Declare(
  zlib
  URL https://zlib.net/fossils/zlib-1.3.tar.gz
  URL_HASH SHA256=ff0ba4c292013dbc27530b3a81e1f9a813cd39de01ca5e0f8bf355702efa593e
  SOURCE_SUBDIR disable_cmakelists_txt
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

add_custom_command(
  OUTPUT rocks.c
  COMMAND luarocks build --only-deps --tree luarocks ${CMAKE_CURRENT_SOURCE_DIR}/wowless-scm-0.rockspec
  COMMAND bash -c \"lua ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua > rocks.c\"
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
    ${CMAKE_CURRENT_SOURCE_DIR}/wowless-scm-0.rockspec
)

add_library(
  expat OBJECT
  ${expat_SOURCE_DIR}/expat/lib/xmlparse.c
  ${expat_SOURCE_DIR}/expat/lib/xmlrole.c
  ${expat_SOURCE_DIR}/expat/lib/xmltok.c
)
target_include_directories(expat PUBLIC ${expat_SOURCE_DIR}/expat/lib)

add_library(
  luaexpat OBJECT
  ${luaexpat_SOURCE_DIR}/src/lxplib.c
)
target_link_libraries(luaexpat expat)

add_library(
  yaml OBJECT
  ${yaml_SOURCE_DIR}/src/api.c
  ${yaml_SOURCE_DIR}/src/dumper.c
  ${yaml_SOURCE_DIR}/src/emitter.c
  ${yaml_SOURCE_DIR}/src/loader.c
  ${yaml_SOURCE_DIR}/src/parser.c
  ${yaml_SOURCE_DIR}/src/reader.c
  ${yaml_SOURCE_DIR}/src/scanner.c
  ${yaml_SOURCE_DIR}/src/writer.c
)
set_property(
  SOURCE ${yaml_SOURCE_DIR}/src/api.c
  APPEND PROPERTY COMPILE_DEFINITIONS
  YAML_VERSION_MAJOR=0
  YAML_VERSION_MINOR=2
  YAML_VERSION_PATCH=5
  YAML_VERSION_STRING="0.2.5"
)
target_include_directories(yaml PUBLIC ${yaml_SOURCE_DIR}/include)

add_library(
  lyaml OBJECT
  ${lyaml_SOURCE_DIR}/ext/yaml/emitter.c
  ${lyaml_SOURCE_DIR}/ext/yaml/parser.c
  ${lyaml_SOURCE_DIR}/ext/yaml/scanner.c
  ${lyaml_SOURCE_DIR}/ext/yaml/yaml.c
)
set_property(
  SOURCE ${lyaml_SOURCE_DIR}/ext/yaml/yaml.c
  APPEND PROPERTY COMPILE_DEFINITIONS VERSION="wowless"
)
target_link_libraries(lyaml yaml)

add_library(
  zlib OBJECT
  ${zlib_SOURCE_DIR}/adler32.c
  ${zlib_SOURCE_DIR}/crc32.c
  ${zlib_SOURCE_DIR}/compress.c
  ${zlib_SOURCE_DIR}/deflate.c
  ${zlib_SOURCE_DIR}/gzclose.c
  ${zlib_SOURCE_DIR}/gzlib.c
  ${zlib_SOURCE_DIR}/gzread.c
  ${zlib_SOURCE_DIR}/gzwrite.c
  ${zlib_SOURCE_DIR}/inflate.c
  ${zlib_SOURCE_DIR}/infback.c
  ${zlib_SOURCE_DIR}/inftrees.c
  ${zlib_SOURCE_DIR}/inffast.c
  ${zlib_SOURCE_DIR}/trees.c
  ${zlib_SOURCE_DIR}/uncompr.c
  ${zlib_SOURCE_DIR}/zutil.c
)
target_include_directories(zlib PUBLIC ${zlib_SOURCE_DIR})

add_library(
  lzlib OBJECT
  ${lzlib_SOURCE_DIR}/lzlib.c
)
target_link_libraries(lzlib zlib)

add_executable(
  wowless
  main.c
  rocks.c
  wowless/ext.c
  ${lsqlite3_SOURCE_DIR}/lsqlite3.c
  ${luafilesystem_SOURCE_DIR}/src/lfs.c
  ${sqlite3_SOURCE_DIR}/sqlite3.c
)
target_link_libraries(wowless expat liblua luaexpat lyaml lzlib pthread yaml zlib -static)
