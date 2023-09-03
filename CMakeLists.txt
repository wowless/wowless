cmake_minimum_required(VERSION 3.24)
project(wowless)

include(FetchContent)

FetchContent_Declare(
  utf8h
  GIT_REPOSITORY https://github.com/sheredom/utf8.h.git
  GIT_TAG ce48f0eda6cac8f365837edaf8298ad5c03f7f2e
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(utf8h)

FetchContent_Declare(
  elune
  GIT_REPOSITORY https://github.com/meorawr/elune.git
  GIT_TAG f051f75a3e963130c2d1ad98f56868bfc6b2798d
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(elune)
add_library(
  elune STATIC
  ${elune_SOURCE_DIR}/liblua/lapi.c
  ${elune_SOURCE_DIR}/liblua/lapi.c
  ${elune_SOURCE_DIR}/liblua/lauxlib.c
  ${elune_SOURCE_DIR}/liblua/lbaselib.c
  ${elune_SOURCE_DIR}/liblua/lbitlib.c
  ${elune_SOURCE_DIR}/liblua/lcode.c
  ${elune_SOURCE_DIR}/liblua/lcompatlib.c
  ${elune_SOURCE_DIR}/liblua/lcorolib.c
  ${elune_SOURCE_DIR}/liblua/ldblib.c
  ${elune_SOURCE_DIR}/liblua/ldebug.c
  ${elune_SOURCE_DIR}/liblua/ldo.c
  ${elune_SOURCE_DIR}/liblua/ldump.c
  ${elune_SOURCE_DIR}/liblua/lfunc.c
  ${elune_SOURCE_DIR}/liblua/lgc.c
  ${elune_SOURCE_DIR}/liblua/linit.c
  ${elune_SOURCE_DIR}/liblua/liolib.c
  ${elune_SOURCE_DIR}/liblua/llex.c
  ${elune_SOURCE_DIR}/liblua/lmanip.c
  ${elune_SOURCE_DIR}/liblua/lmathlib.c
  ${elune_SOURCE_DIR}/liblua/lmem.c
  ${elune_SOURCE_DIR}/liblua/loadlib.c
  ${elune_SOURCE_DIR}/liblua/lobject.c
  ${elune_SOURCE_DIR}/liblua/lopcodes.c
  ${elune_SOURCE_DIR}/liblua/loslib.c
  ${elune_SOURCE_DIR}/liblua/lparser.c
  ${elune_SOURCE_DIR}/liblua/lreadline.c
  ${elune_SOURCE_DIR}/liblua/lsec.c
  ${elune_SOURCE_DIR}/liblua/lseclib.c
  ${elune_SOURCE_DIR}/liblua/lstate.c
  ${elune_SOURCE_DIR}/liblua/lstatslib.c
  ${elune_SOURCE_DIR}/liblua/lstring.c
  ${elune_SOURCE_DIR}/liblua/lstrlib.c
  ${elune_SOURCE_DIR}/liblua/ltable.c
  ${elune_SOURCE_DIR}/liblua/ltablib.c
  ${elune_SOURCE_DIR}/liblua/ltm.c
  ${elune_SOURCE_DIR}/liblua/lundump.c
  ${elune_SOURCE_DIR}/liblua/lvm.c
  ${elune_SOURCE_DIR}/liblua/lzio.c
)
block()
  set(LUA_CPATH_ESCAPED "")
  set(LUA_DIRSEP_ESCAPED "/")
  set(LUA_PATH_ESCAPED "")
  set(LUAI_BITSINT 32)
  configure_file(
    ${elune_SOURCE_DIR}/liblua/include/luaconf.h.in
    ${elune_BINARY_DIR}/luaconf.h
  )
endblock()
target_include_directories(
  elune PUBLIC
  ${elune_SOURCE_DIR}/liblua/include
  ${elune_BINARY_DIR}
  ${utf8h_SOURCE_DIR}
)
target_link_libraries(elune m)

add_executable(bootstraplua ${elune_SOURCE_DIR}/lua/lua.c)
target_link_libraries(bootstraplua elune)

FetchContent_Declare(
  expat
  GIT_REPOSITORY https://github.com/libexpat/libexpat.git
  GIT_TAG R_2_5_0
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(expat)
add_library(
  expat STATIC
  ${expat_SOURCE_DIR}/expat/lib/xmlparse.c
  ${expat_SOURCE_DIR}/expat/lib/xmlrole.c
  ${expat_SOURCE_DIR}/expat/lib/xmltok.c
)
block()
  set(XML_DEV_URANDOM ON)
  configure_file(
    ${expat_SOURCE_DIR}/expat/expat_config.h.cmake
    ${expat_BINARY_DIR}/expat_config.h
  )
endblock()
target_include_directories(
  expat PUBLIC
  ${expat_SOURCE_DIR}/expat/lib
  ${expat_BINARY_DIR}
)

FetchContent_Declare(
  luaexpat
  GIT_REPOSITORY https://github.com/lunarmodules/luaexpat.git
  GIT_TAG 1.4.1
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luaexpat)
add_library(
  luaexpat STATIC
  ${luaexpat_SOURCE_DIR}/src/lxplib.c
)
target_link_libraries(luaexpat elune expat)

FetchContent_Declare(
  yaml
  GIT_REPOSITORY https://github.com/yaml/libyaml.git
  GIT_TAG 0.2.5
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(yaml)
add_library(
  yaml STATIC
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

macro(rock2c module rockspec)
  add_custom_command(
    OUTPUT ${module}.c
    COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/rock2c.lua ${rockspec}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/rock2c.lua ${rockspec}
  )
endmacro()

FetchContent_Declare(
  lyaml
  GIT_REPOSITORY https://github.com/gvvaughan/lyaml.git
  GIT_TAG v6.2.8
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lyaml)
file(WRITE ${lyaml_SOURCE_DIR}/dummy.rockspec [=[
package = 'lyaml'
build = {
  modules = {
    ['lyaml.explicit'] = 'lib/lyaml/explicit.lua',
    ['lyaml.functional'] = 'lib/lyaml/functional.lua',
    ['lyaml.implicit'] = 'lib/lyaml/implicit.lua',
    ['lyaml.init'] = 'lib/lyaml/init.lua',
  },
}
]=])
rock2c(lyaml ${lyaml_SOURCE_DIR}/dummy.rockspec)
add_library(
  lyaml STATIC
  lyaml.c
  ${lyaml_SOURCE_DIR}/ext/yaml/emitter.c
  ${lyaml_SOURCE_DIR}/ext/yaml/parser.c
  ${lyaml_SOURCE_DIR}/ext/yaml/scanner.c
  ${lyaml_SOURCE_DIR}/ext/yaml/yaml.c
)
set_property(
  SOURCE ${lyaml_SOURCE_DIR}/ext/yaml/yaml.c
  APPEND PROPERTY COMPILE_DEFINITIONS VERSION="wowless"
)
target_link_libraries(lyaml elune yaml)

FetchContent_Declare(
  zlib
  URL https://zlib.net/fossils/zlib-1.3.tar.gz
  URL_HASH SHA256=ff0ba4c292013dbc27530b3a81e1f9a813cd39de01ca5e0f8bf355702efa593e
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(zlib)
add_library(
  zlib STATIC
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

FetchContent_Declare(
  lzlib
  GIT_REPOSITORY https://github.com/luadist/lzlib.git
  GIT_TAG 0.4.3
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lzlib)
add_library(
  lzlib STATIC
  ${lzlib_SOURCE_DIR}/lzlib.c
)
target_link_libraries(lzlib elune zlib)

FetchContent_Declare(
  sqlite3
  URL https://www.sqlite.org/2023/sqlite-amalgamation-3410200.zip
  URL_HASH SHA3_256=c51ca72411b8453c64e0980be23bc9b9530bdc3ec1513e06fbf022ed0fd02463
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(sqlite3)
add_library(
  sqlite3 STATIC
  ${sqlite3_SOURCE_DIR}/sqlite3.c
)
target_include_directories(sqlite3 PUBLIC ${sqlite3_SOURCE_DIR})
target_link_libraries(sqlite3 dl pthread)

FetchContent_Declare(
  lsqlite3
  URL http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09y.zip
  URL_HASH MD5=1f937ed6bf9d5980239da516c424d7b6
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lsqlite3)
add_library(
  lsqlite3 STATIC
  ${lsqlite3_SOURCE_DIR}/lsqlite3.c
)
target_link_libraries(lsqlite3 elune sqlite3)

FetchContent_Declare(
  luafilesystem
  GIT_REPOSITORY https://github.com/lunarmodules/luafilesystem.git
  GIT_TAG v1_8_0
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luafilesystem)
add_library(
  luafilesystem STATIC
  ${luafilesystem_SOURCE_DIR}/src/lfs.c
)
target_link_libraries(luafilesystem elune)

FetchContent_Declare(
  say
  GIT_REPOSITORY https://github.com/lunarmodules/say.git
  GIT_TAG 3e1f783d0aa496eb21d16e85b2235335cb9332df
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(say)
rock2c(say ${say_SOURCE_DIR}/say-scm-1.rockspec)
add_library(say STATIC say.c)
target_link_libraries(say elune)

FetchContent_Declare(
  luassert
  GIT_REPOSITORY https://github.com/lunarmodules/luassert.git
  GIT_TAG 8c9385b1a1944a5ce0ef9dbd721ad1987cf85e9d
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luassert)
rock2c(luassert ${luassert_SOURCE_DIR}/luassert-scm-1.rockspec)
add_library(luassert STATIC luassert.c)
target_link_libraries(luassert elune say)

FetchContent_Declare(
  argparse
  GIT_REPOSITORY https://github.com/luarocks/argparse
  GIT_TAG 27967d7b52295ea7885671af734332038c132837
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(argparse)
rock2c(argparse ${argparse_SOURCE_DIR}/argparse-scm-2.rockspec)
add_library(argparse STATIC argparse.c)
target_link_libraries(argparse elune)

FetchContent_Declare(
  date
  GIT_REPOSITORY https://github.com/tieske/date.git
  GIT_TAG e309741edc15bde2c884b0db09d8560848773b50
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(date)
rock2c(date ${date_SOURCE_DIR}/date-2.2-2.rockspec)
add_library(date STATIC date.c)
target_link_libraries(date elune)

FetchContent_Declare(
  minheap
  GIT_REPOSITORY https://github.com/mah0x211/lua-minheap
  GIT_TAG c5fe42b60cf5b3ee7ed6d33eb31be1119dfb1cd6
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(minheap)
file(
  COPY_FILE
  ${minheap_SOURCE_DIR}/rockspecs/minheap-scm-1.rockspec
  ${minheap_SOURCE_DIR}/minheap-scm-1.rockspec
)
rock2c(minheap ${minheap_SOURCE_DIR}/minheap-scm-1.rockspec)
add_library(minheap STATIC minheap.c)
target_link_libraries(minheap elune)

add_custom_command(
  OUTPUT rocks.c
  COMMAND luarocks build --only-deps --tree luarocks ${CMAKE_CURRENT_SOURCE_DIR}/wowless-scm-0.rockspec
  COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
    ${CMAKE_CURRENT_SOURCE_DIR}/wowless-scm-0.rockspec
)

add_library(
  wowlesslib STATIC
  rocks.c
  wowless/ext.c
)
target_link_libraries(wowlesslib elune)

add_executable(wowless main.c)
target_link_libraries(
  wowless
  argparse
  date
  elune
  lsqlite3
  luaexpat
  luafilesystem
  luassert
  lyaml
  lzlib
  minheap
  wowlesslib
  -static
)
