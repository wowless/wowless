cmake_minimum_required(VERSION 3.24)
project(wowless LANGUAGES C)

# https://gitlab.kitware.com/cmake/cmake/-/issues/25245
cmake_policy(SET CMP0116 OLD)

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
  GIT_TAG 7fc7271922fbc0a371ef15d699ffa0b2be649a81
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
  set(LUA_DISABLE_LOADLIB ON)
  set(LUA_PATH_ESCAPED "")
  set(LUAI_BITSINT 32)
  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(LUA_DIRSEP_ESCAPED "/")
    set(LUA_USE_LINUX OFF)
    set(LUA_USE_MACOS ON)
    set(LUA_USE_POSIX ON)
    set(LUA_USE_WINDOWS OFF)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(LUA_DIRSEP_ESCAPED "/")
    set(LUA_USE_LINUX ON)
    set(LUA_USE_MACOS OFF)
    set(LUA_USE_POSIX ON)
    set(LUA_USE_WINDOWS OFF)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(LUA_DIRSEP_ESCAPED "\\\\")
    set(LUA_USE_LINUX OFF)
    set(LUA_USE_MACOS OFF)
    set(LUA_USE_POSIX OFF)
    set(LUA_USE_WINDOWS ON)
  else()
    message(FATAL_ERROR "unsupported platform")
  endif()
  configure_file(
    ${elune_SOURCE_DIR}/liblua/include/luaconf.h.in
    ${elune_BINARY_DIR}/luaconf.h
  )
endblock()
target_include_directories(elune PRIVATE ${utf8h_SOURCE_DIR})
target_include_directories(
  elune PUBLIC
  ${elune_SOURCE_DIR}/liblua/include
  ${elune_BINARY_DIR}
)
target_link_libraries(
  elune PRIVATE
  $<$<PLATFORM_ID:Darwin,Linux>:m>
  $<$<PLATFORM_ID:Windows>:bcrypt>
)
set_target_properties(elune PROPERTIES C_STANDARD 11)

add_executable(bootstraplua ${elune_SOURCE_DIR}/lua/lua.c)
target_link_libraries(bootstraplua PRIVATE elune)

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
target_compile_definitions(expat PUBLIC XML_STATIC)

function(lua2c name)
  set(deps ${ARGN})
  list(TRANSFORM deps REPLACE "^.*=" "")
  list(REMOVE_ITEM deps c)
  add_custom_command(
    OUTPUT ${name}.c
    COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua ${name} ${ARGN}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua ${deps}
  )
endfunction()

FetchContent_Declare(
  luaexpat
  GIT_REPOSITORY https://github.com/lunarmodules/luaexpat.git
  GIT_TAG 1.4.1
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luaexpat)
lua2c(luaexpat lxp=c)
add_library(
  luaexpat STATIC
  luaexpat.c
  ${luaexpat_SOURCE_DIR}/src/lxplib.c
)
target_link_libraries(luaexpat PRIVATE elune expat)

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
target_compile_definitions(yaml PUBLIC YAML_DECLARE_STATIC)

FetchContent_Declare(
  lyaml
  GIT_REPOSITORY https://github.com/gvvaughan/lyaml.git
  GIT_TAG v6.2.8
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lyaml)
lua2c(
  lyaml
  lyaml=${lyaml_SOURCE_DIR}/lib/lyaml/init.lua
  lyaml.explicit=${lyaml_SOURCE_DIR}/lib/lyaml/explicit.lua
  lyaml.functional=${lyaml_SOURCE_DIR}/lib/lyaml/functional.lua
  lyaml.implicit=${lyaml_SOURCE_DIR}/lib/lyaml/implicit.lua
  yaml=c
)
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
target_link_libraries(lyaml PRIVATE elune yaml)

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
target_compile_definitions(zlib PRIVATE $<$<PLATFORM_ID:Darwin,Linux>:Z_HAVE_UNISTD_H>)
target_include_directories(zlib PUBLIC ${zlib_SOURCE_DIR})

FetchContent_Declare(
  lzlib
  GIT_REPOSITORY https://github.com/luadist/lzlib.git
  GIT_TAG 0.4.3
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lzlib)
lua2c(lzlib zlib=c)
add_library(
  lzlib STATIC
  lzlib.c
  ${lzlib_SOURCE_DIR}/lzlib.c
)
target_link_libraries(lzlib PRIVATE elune zlib)

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
target_link_libraries(sqlite3 PRIVATE $<$<PLATFORM_ID:Darwin,Linux>:dl pthread>)

FetchContent_Declare(
  lsqlite3
  URL http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09y.zip
  URL_HASH MD5=1f937ed6bf9d5980239da516c424d7b6
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lsqlite3)
lua2c(lsqlite3 lsqlite3=c)
add_library(
  lsqlite3 STATIC
  lsqlite3.c
  ${lsqlite3_SOURCE_DIR}/lsqlite3.c
)
target_link_libraries(lsqlite3 PRIVATE elune sqlite3)

FetchContent_Declare(
  luafilesystem
  GIT_REPOSITORY https://github.com/lunarmodules/luafilesystem.git
  GIT_TAG v1_8_0
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luafilesystem)
lua2c(luafilesystem lfs=c)
add_library(
  luafilesystem STATIC
  luafilesystem.c
  ${luafilesystem_SOURCE_DIR}/src/lfs.c
)
target_link_libraries(luafilesystem PRIVATE elune)

FetchContent_Declare(
  say
  GIT_REPOSITORY https://github.com/lunarmodules/say.git
  GIT_TAG 3e1f783d0aa496eb21d16e85b2235335cb9332df
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(say)
lua2c(say say=${say_SOURCE_DIR}/src/say/init.lua)
add_library(say STATIC say.c)
target_link_libraries(say PRIVATE elune)

FetchContent_Declare(
  luassert
  GIT_REPOSITORY https://github.com/lunarmodules/luassert.git
  GIT_TAG 8c9385b1a1944a5ce0ef9dbd721ad1987cf85e9d
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luassert)
lua2c(
  luassert
  luassert.compatibility=${luassert_SOURCE_DIR}/src/compatibility.lua
  luassert.state=${luassert_SOURCE_DIR}/src/state.lua
  luassert.util=${luassert_SOURCE_DIR}/src/util.lua
  luassert.spy=${luassert_SOURCE_DIR}/src/spy.lua
  luassert.stub=${luassert_SOURCE_DIR}/src/stub.lua
  luassert.assert=${luassert_SOURCE_DIR}/src/assert.lua
  luassert.modifiers=${luassert_SOURCE_DIR}/src/modifiers.lua
  luassert.assertions=${luassert_SOURCE_DIR}/src/assertions.lua
  luassert.array=${luassert_SOURCE_DIR}/src/array.lua
  luassert.namespaces=${luassert_SOURCE_DIR}/src/namespaces.lua
  luassert.match=${luassert_SOURCE_DIR}/src/match.lua
  luassert.mock=${luassert_SOURCE_DIR}/src/mock.lua
  luassert=${luassert_SOURCE_DIR}/src/init.lua
  luassert.matchers=${luassert_SOURCE_DIR}/src/matchers/init.lua
  luassert.matchers.core=${luassert_SOURCE_DIR}/src/matchers/core.lua
  luassert.matchers.composite=${luassert_SOURCE_DIR}/src/matchers/composite.lua
  luassert.formatters=${luassert_SOURCE_DIR}/src/formatters/init.lua
  luassert.formatters.binarystring=${luassert_SOURCE_DIR}/src/formatters/binarystring.lua
  luassert.languages.ar=${luassert_SOURCE_DIR}/src/languages/ar.lua
  luassert.languages.de=${luassert_SOURCE_DIR}/src/languages/de.lua
  luassert.languages.en=${luassert_SOURCE_DIR}/src/languages/en.lua
  luassert.languages.fr=${luassert_SOURCE_DIR}/src/languages/fr.lua
  luassert.languages.is=${luassert_SOURCE_DIR}/src/languages/is.lua
  luassert.languages.ja=${luassert_SOURCE_DIR}/src/languages/ja.lua
  luassert.languages.ko=${luassert_SOURCE_DIR}/src/languages/ko.lua
  luassert.languages.nl=${luassert_SOURCE_DIR}/src/languages/nl.lua
  luassert.languages.ru=${luassert_SOURCE_DIR}/src/languages/ru.lua
  luassert.languages.ua=${luassert_SOURCE_DIR}/src/languages/ua.lua
  luassert.languages.zh=${luassert_SOURCE_DIR}/src/languages/zh.lua
)
add_library(luassert STATIC luassert.c)
target_link_libraries(luassert PRIVATE elune)

FetchContent_Declare(
  argparse
  GIT_REPOSITORY https://github.com/luarocks/argparse
  GIT_TAG 27967d7b52295ea7885671af734332038c132837
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(argparse)
lua2c(argparse argparse=${argparse_SOURCE_DIR}/src/argparse.lua)
add_library(argparse STATIC argparse.c)
target_link_libraries(argparse PRIVATE elune)

FetchContent_Declare(
  date
  GIT_REPOSITORY https://github.com/tieske/date.git
  GIT_TAG e309741edc15bde2c884b0db09d8560848773b50
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(date)
lua2c(date date=${date_SOURCE_DIR}/src/date.lua)
add_library(date STATIC date.c)
target_link_libraries(date PRIVATE elune)

FetchContent_Declare(
  tsort
  GIT_REPOSITORY https://github.com/bungle/lua-resty-tsort
  GIT_TAG 07754a8af7c51ca5fbcf05dc5f4b1b900f1bf530
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(tsort)
lua2c(tsort resty.tsort=${tsort_SOURCE_DIR}/lib/resty/tsort.lua)
add_library(tsort STATIC tsort.c)
target_link_libraries(tsort PRIVATE elune)

FetchContent_Declare(
  minheap
  GIT_REPOSITORY https://github.com/mah0x211/lua-minheap
  GIT_TAG c5fe42b60cf5b3ee7ed6d33eb31be1119dfb1cd6
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(minheap)
lua2c(minheap minheap=${minheap_SOURCE_DIR}/minheap.lua)
add_library(minheap STATIC minheap.c)
target_link_libraries(minheap PRIVATE elune)

FetchContent_Declare(
  luapath
  GIT_REPOSITORY https://github.com/moteus/lua-path
  GIT_TAG 5a32c7052e84cdb9dcbcd45648aae3f6927376ac
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luapath)
lua2c(
  luapath
  path=${luapath_SOURCE_DIR}/lua/path.lua
  path.fs=${luapath_SOURCE_DIR}/lua/path/fs.lua
  path.findfile=${luapath_SOURCE_DIR}/lua/path/findfile.lua
  path.lfs.fs=${luapath_SOURCE_DIR}/lua/path/lfs/fs.lua
  path.syscall.fs=${luapath_SOURCE_DIR}/lua/path/syscall/fs.lua
  path.lfs.impl.fs=${luapath_SOURCE_DIR}/lua/path/lfs/impl/fs.lua
  path.module=${luapath_SOURCE_DIR}/lua/path/module.lua
  path.win32.alien.fs=${luapath_SOURCE_DIR}/lua/path/win32/alien/fs.lua
  path.win32.alien.types=${luapath_SOURCE_DIR}/lua/path/win32/alien/types.lua
  path.win32.alien.utils=${luapath_SOURCE_DIR}/lua/path/win32/alien/utils.lua
  path.win32.alien.wcs=${luapath_SOURCE_DIR}/lua/path/win32/alien/wcs.lua
  path.win32.ffi.fs=${luapath_SOURCE_DIR}/lua/path/win32/ffi/fs.lua
  path.win32.ffi.types=${luapath_SOURCE_DIR}/lua/path/win32/ffi/types.lua
  path.win32.ffi.wcs=${luapath_SOURCE_DIR}/lua/path/win32/ffi/wcs.lua
  path.win32.fs=${luapath_SOURCE_DIR}/lua/path/win32/fs.lua
  path.win32.wcs=${luapath_SOURCE_DIR}/lua/path/win32/wcs.lua
)
add_library(luapath STATIC luapath.c)
target_link_libraries(luapath PRIVATE elune)

FetchContent_Declare(
  penlight
  GIT_REPOSITORY https://github.com/lunarmodules/penlight
  GIT_TAG 3bf03267b2571ba3cfa676a10528dd7b9a0db404
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(penlight)
lua2c(
  penlight
  pl=${penlight_SOURCE_DIR}/lua/pl/init.lua
  pl.strict=${penlight_SOURCE_DIR}/lua/pl/strict.lua
  pl.dir=${penlight_SOURCE_DIR}/lua/pl/dir.lua
  pl.operator=${penlight_SOURCE_DIR}/lua/pl/operator.lua
  pl.input=${penlight_SOURCE_DIR}/lua/pl/input.lua
  pl.config=${penlight_SOURCE_DIR}/lua/pl/config.lua
  pl.seq=${penlight_SOURCE_DIR}/lua/pl/seq.lua
  pl.stringio=${penlight_SOURCE_DIR}/lua/pl/stringio.lua
  pl.text=${penlight_SOURCE_DIR}/lua/pl/text.lua
  pl.test=${penlight_SOURCE_DIR}/lua/pl/test.lua
  pl.tablex=${penlight_SOURCE_DIR}/lua/pl/tablex.lua
  pl.app=${penlight_SOURCE_DIR}/lua/pl/app.lua
  pl.stringx=${penlight_SOURCE_DIR}/lua/pl/stringx.lua
  pl.lexer=${penlight_SOURCE_DIR}/lua/pl/lexer.lua
  pl.utils=${penlight_SOURCE_DIR}/lua/pl/utils.lua
  pl.compat=${penlight_SOURCE_DIR}/lua/pl/compat.lua
  pl.sip=${penlight_SOURCE_DIR}/lua/pl/sip.lua
  pl.permute=${penlight_SOURCE_DIR}/lua/pl/permute.lua
  pl.pretty=${penlight_SOURCE_DIR}/lua/pl/pretty.lua
  pl.class=${penlight_SOURCE_DIR}/lua/pl/class.lua
  pl.List=${penlight_SOURCE_DIR}/lua/pl/List.lua
  pl.data=${penlight_SOURCE_DIR}/lua/pl/data.lua
  pl.Date=${penlight_SOURCE_DIR}/lua/pl/Date.lua
  pl.luabalanced=${penlight_SOURCE_DIR}/lua/pl/luabalanced.lua
  pl.comprehension=${penlight_SOURCE_DIR}/lua/pl/comprehension.lua
  pl.path=${penlight_SOURCE_DIR}/lua/pl/path.lua
  pl.array2d=${penlight_SOURCE_DIR}/lua/pl/array2d.lua
  pl.func=${penlight_SOURCE_DIR}/lua/pl/func.lua
  pl.lapp=${penlight_SOURCE_DIR}/lua/pl/lapp.lua
  pl.file=${penlight_SOURCE_DIR}/lua/pl/file.lua
  pl.template=${penlight_SOURCE_DIR}/lua/pl/template.lua
  pl.Map=${penlight_SOURCE_DIR}/lua/pl/Map.lua
  pl.MultiMap=${penlight_SOURCE_DIR}/lua/pl/MultiMap.lua
  pl.OrderedMap=${penlight_SOURCE_DIR}/lua/pl/OrderedMap.lua
  pl.Set=${penlight_SOURCE_DIR}/lua/pl/Set.lua
  pl.xml=${penlight_SOURCE_DIR}/lua/pl/xml.lua
  pl.url=${penlight_SOURCE_DIR}/lua/pl/url.lua
  pl.types=${penlight_SOURCE_DIR}/lua/pl/types.lua
  pl.import_into=${penlight_SOURCE_DIR}/lua/pl/import_into.lua
)
add_library(penlight STATIC penlight.c)
target_link_libraries(penlight PRIVATE elune)

FetchContent_Declare(
  vstruct
  GIT_REPOSITORY https://github.com/toxicfrog/vstruct
  GIT_TAG b6889e3b275e9f9532b5dff4917e903b17e22730
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(vstruct)
lua2c(
  vstruct
  vstruct.api=${vstruct_SOURCE_DIR}/api.lua
  vstruct.ast=${vstruct_SOURCE_DIR}/ast.lua
  vstruct.ast.Bitpack=${vstruct_SOURCE_DIR}/ast/Bitpack.lua
  vstruct.ast.IO=${vstruct_SOURCE_DIR}/ast/IO.lua
  vstruct.ast.List=${vstruct_SOURCE_DIR}/ast/List.lua
  vstruct.ast.Name=${vstruct_SOURCE_DIR}/ast/Name.lua
  vstruct.ast.Node=${vstruct_SOURCE_DIR}/ast/Node.lua
  vstruct.ast.Repeat=${vstruct_SOURCE_DIR}/ast/Repeat.lua
  vstruct.ast.Root=${vstruct_SOURCE_DIR}/ast/Root.lua
  vstruct.ast.Table=${vstruct_SOURCE_DIR}/ast/Table.lua
  vstruct.compat1x=${vstruct_SOURCE_DIR}/compat1x.lua
  vstruct.cursor=${vstruct_SOURCE_DIR}/cursor.lua
  vstruct.frexp=${vstruct_SOURCE_DIR}/frexp.lua
  vstruct=${vstruct_SOURCE_DIR}/init.lua
  vstruct.io=${vstruct_SOURCE_DIR}/io.lua
  vstruct.io.a=${vstruct_SOURCE_DIR}/io/a.lua
  vstruct.io.b=${vstruct_SOURCE_DIR}/io/b.lua
  vstruct.io.bigendian=${vstruct_SOURCE_DIR}/io/bigendian.lua
  vstruct.io.c=${vstruct_SOURCE_DIR}/io/c.lua
  vstruct.io.defaults=${vstruct_SOURCE_DIR}/io/defaults.lua
  vstruct.io.endianness=${vstruct_SOURCE_DIR}/io/endianness.lua
  vstruct.io.f=${vstruct_SOURCE_DIR}/io/f.lua
  vstruct.io.hostendian=${vstruct_SOURCE_DIR}/io/hostendian.lua
  vstruct.io.i=${vstruct_SOURCE_DIR}/io/i.lua
  vstruct.io.littleendian=${vstruct_SOURCE_DIR}/io/littleendian.lua
  vstruct.io.m=${vstruct_SOURCE_DIR}/io/m.lua
  vstruct.io.p=${vstruct_SOURCE_DIR}/io/p.lua
  vstruct.io.s=${vstruct_SOURCE_DIR}/io/s.lua
  vstruct.io.seekb=${vstruct_SOURCE_DIR}/io/seekb.lua
  vstruct.io.seekf=${vstruct_SOURCE_DIR}/io/seekf.lua
  vstruct.io.seekto=${vstruct_SOURCE_DIR}/io/seekto.lua
  vstruct.io.u=${vstruct_SOURCE_DIR}/io/u.lua
  vstruct.io.x=${vstruct_SOURCE_DIR}/io/x.lua
  vstruct.io.z=${vstruct_SOURCE_DIR}/io/z.lua
  vstruct.lexer=${vstruct_SOURCE_DIR}/lexer.lua
)
add_library(vstruct STATIC vstruct.c)
target_link_libraries(vstruct PRIVATE elune)

function(add_lua_executable name main)
  set(luamain ${name}luamain.c)
  add_custom_command(
    OUTPUT ${luamain}
    COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/luamain.lua ${luamain} ${main} ${ARGN}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/luamain.lua ${main}
  )
  add_executable(${name} ${luamain})
  target_link_libraries(${name} PRIVATE ${ARGN} elune)
endfunction()

lua2c(wowlessyaml wowapi.yaml=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/yaml.lua)
add_library(wowlessyaml wowlessyaml.c)
target_link_libraries(wowlessyaml PRIVATE elune)

add_lua_executable(
  yaml2lua
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/yaml2lua.lua
  luafilesystem
  lyaml
  penlight
  wowlessyaml
)

function(yaml2lua basename)
  set(input ${CMAKE_CURRENT_SOURCE_DIR}/data/${basename}.yaml)
  set(output runtime/${basename}.lua)
  add_custom_command(
    OUTPUT ${output}
    COMMAND yaml2lua ${input} ${output}
    DEPENDS yaml2lua ${input}
  )
endfunction()

yaml2lua(flavors)
yaml2lua(products)
yaml2lua(stringenums)

lua2c(toolsutil tools.util=${CMAKE_CURRENT_SOURCE_DIR}/tools/util.lua)
add_library(toolsutil toolsutil.c)
target_link_libraries(toolsutil PRIVATE elune)

lua2c(wowlessutil wowless.util=${CMAKE_CURRENT_SOURCE_DIR}/wowless/util.lua)
add_library(wowlessutil wowlessutil.c)
target_link_libraries(wowlessutil PRIVATE elune)

FetchContent_Declare(
  cjson
  GIT_REPOSITORY https://github.com/openresty/lua-cjson
  GIT_TAG 2bfad8f5eeb821357d2ada29506e864ff7ec947e
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(cjson)
add_library(
  cjson
  ${cjson_SOURCE_DIR}/fpconv.c
  ${cjson_SOURCE_DIR}/lua_cjson.c
  ${cjson_SOURCE_DIR}/strbuf.c
)
target_link_libraries(cjson PRIVATE elune)
lua2c(luacjson cjson=c)
add_library(luacjson luacjson.c)
target_link_libraries(luacjson PRIVATE cjson elune)

add_lua_executable(
  listfile
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/listfile.lua
  argparse
  luacjson
  luafilesystem
  penlight
  toolsutil
)

file(
  MAKE_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/generated
  ${CMAKE_CURRENT_BINARY_DIR}/runtime
  ${CMAKE_CURRENT_BINARY_DIR}/stamp
)

add_custom_command(
  OUTPUT stamp/listfile.txt
  BYPRODUCTS runtime/listfile.lua
  COMMAND listfile ${CMAKE_CURRENT_SOURCE_DIR}/vendor/dbdefs/manifest.json generated/listfile.lua
  COMMAND ${CMAKE_COMMAND} -E copy_if_different generated/listfile.lua runtime/listfile.lua
  COMMAND ${CMAKE_COMMAND} -E touch stamp/listfile.txt
  DEPENDS listfile ${CMAKE_CURRENT_SOURCE_DIR}/vendor/dbdefs/manifest.json
)
# TODO rationalize with lua2c
add_custom_command(
  OUTPUT runtimelistfile.c
  COMMAND bootstraplua
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
    runtimelistfile
    runtime.listfile=runtime/listfile.lua
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua stamp/listfile.txt
)
add_library(runtimelistfile STATIC runtimelistfile.c)
target_link_libraries(runtimelistfile PRIVATE elune)

add_lua_executable(
  dblist
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/dblist.lua
  argparse
  lsqlite3
  luafilesystem
  lyaml
  penlight
  toolsutil
  wowlessyaml
)

FetchContent_Declare(
  lpeg
  URL http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.2.tar.gz
  URL_HASH MD5=d342571886f1abcb7afe6a83d024d583
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lpeg)
lua2c(lpeg lpeg=c)
add_library(
  lpeg STATIC
  lpeg.c
  ${lpeg_SOURCE_DIR}/lpcap.c
  ${lpeg_SOURCE_DIR}/lpcode.c
  ${lpeg_SOURCE_DIR}/lpprint.c
  ${lpeg_SOURCE_DIR}/lptree.c
  ${lpeg_SOURCE_DIR}/lpvm.c
)
target_link_libraries(lpeg PRIVATE elune)

FetchContent_Declare(
  luadbd
  GIT_REPOSITORY https://github.com/lua-wow-tools/luadbd
  GIT_TAG 600ca1dcc83f9dee7ca165b27d17f7d0355db6e2
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luadbd)
lua2c(
  luadbd
  luadbd.parser=${luadbd_SOURCE_DIR}/luadbd/parser.lua
  luadbd.sig=${luadbd_SOURCE_DIR}/luadbd/sig.lua
)
add_library(luadbd STATIC luadbd.c)
target_link_libraries(luadbd PRIVATE elune)

add_lua_executable(
  dbdefs
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/dbdefs.lua
  argparse
  lpeg
  luadbd
  luafilesystem
  lyaml
  penlight
  toolsutil
  wowlessyaml
)

add_lua_executable(
  prep
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/prep.lua
  argparse
  luafilesystem
  luapath
  lyaml
  penlight
  toolsutil
  wowlessutil
  wowlessyaml
)

# TODO derive this from data/products.yaml, or vice versa
list(
  APPEND products
  wow
  wowt
  wowxptr
  wow_classic
  wow_classic_era
  wow_classic_era_ptr
  wow_classic_ptr
)
foreach(product ${products})
  add_custom_command(
    OUTPUT stamp/${product}.txt
    BYPRODUCTS runtime/${product}.lua
    COMMAND prep ${product}
      --output ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}.lua
      --stamp ${CMAKE_NINJA_OUTPUT_PATH_PREFIX}stamp/${product}.txt
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}.lua
      ${CMAKE_CURRENT_BINARY_DIR}/runtime/${product}.lua
    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/stamp/${product}.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPFILE ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}.lua.d
    DEPENDS prep
  )
  # TODO rationalize with lua2c
  add_custom_command(
    OUTPUT datalua_${product}.c
    COMMAND bootstraplua
      ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
      datalua_${product}
      build.products.${product}.data=runtime/${product}.lua
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua stamp/${product}.txt
  )
  add_library(datalua_${product} STATIC datalua_${product}.c)
  target_link_libraries(datalua_${product} PRIVATE elune)
  list(APPEND dataluas datalua_${product})
endforeach()

add_lua_executable(
  tactkeys
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/tactkeys.lua
  argparse
  luafilesystem
  penlight
  toolsutil
)

add_custom_command(
  OUTPUT stamp/tactkeys.txt
  BYPRODUCTS runtime/tactkeys.lua
  COMMAND tactkeys ${CMAKE_CURRENT_SOURCE_DIR}/vendor/tactkeys/WoW.txt generated/tactkeys.lua
  COMMAND ${CMAKE_COMMAND} -E copy_if_different generated/tactkeys.lua runtime/tactkeys.lua
  COMMAND ${CMAKE_COMMAND} -E touch stamp/tactkeys.txt
  DEPENDS tactkeys ${CMAKE_CURRENT_SOURCE_DIR}/vendor/tactkeys/WoW.txt
)
# TODO rationalize with lua2c
add_custom_command(
  OUTPUT runtimetactkeys.c
  COMMAND bootstraplua
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua
    runtimetactkeys
    runtime.tactkeys=runtime/tactkeys.lua
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua stamp/tactkeys.txt
)
add_library(runtimetactkeys STATIC runtimetactkeys.c)
target_link_libraries(runtimetactkeys PRIVATE elune)

lua2c(toolssqlite3ext tools.sqlite3ext=c)
add_library(toolssqlite3ext STATIC tools/sqlite3ext.c toolssqlite3ext.c)
target_link_libraries(toolssqlite3ext PRIVATE elune sqlite3)

lua2c(toolsdbc tools.dbc=${CMAKE_CURRENT_SOURCE_DIR}/tools/dbc.lua)
add_library(toolsdbc STATIC toolsdbc.c)
target_link_libraries(toolsdbc PRIVATE elune)

FetchContent_Declare(
  dbc
  URL https://luarocks.org/manifests/foxlit/luadbc-1.12-1.src.rock
  URL_HASH SHA256=70dcd264f6789d9a6f421652564ec0a3e46f16cfddf830d9b23a5cf0979f20f6
  DOWNLOAD_NAME luadbc-1.12-1.src.rock.zip
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(dbc)
file(
  ARCHIVE_EXTRACT
  INPUT ${dbc_SOURCE_DIR}/luadbc-1.12.zip
  DESTINATION ${dbc_SOURCE_DIR}
)
lua2c(
  dbc
  dbc=${dbc_SOURCE_DIR}/luadbc/dbc/init.lua
  dbc.bin=${dbc_SOURCE_DIR}/luadbc/dbc/bin.lua
)
add_library(dbc STATIC dbc.c)
target_link_libraries(dbc PRIVATE elune)

add_lua_executable(
  sqlite
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/sqlite.lua
  argparse
  dbc
  lsqlite3
  luafilesystem
  penlight
  toolsdbc
  toolssqlite3ext
)

FetchContent_Declare(
  md5
  GIT_REPOSITORY https://github.com/keplerproject/md5
  GIT_TAG e6f25516910239111f06e2b838bf2f991161ba83
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(md5)
lua2c(
  md5
  md5=${md5_SOURCE_DIR}/src/md5.lua
  md5.core=c
)
add_library(
  md5 STATIC
  md5.c
  ${md5_SOURCE_DIR}/src/md5.c
  ${md5_SOURCE_DIR}/src/md5lib.c
)
target_link_libraries(md5 PRIVATE elune)

FetchContent_Declare(
  luasocket
  GIT_REPOSITORY https://github.com/lunarmodules/luasocket
  GIT_TAG 8c2ff7217e2a205eb107a6f48b04ff1b2b3090a1
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luasocket)
lua2c(
  luasocket
  ltn12=${luasocket_SOURCE_DIR}/src/ltn12.lua
  mime=${luasocket_SOURCE_DIR}/src/mime.lua
  mime.core=c
  socket=${luasocket_SOURCE_DIR}/src/socket.lua
  socket.core=c
  socket.headers=${luasocket_SOURCE_DIR}/src/headers.lua
  socket.http=${luasocket_SOURCE_DIR}/src/http.lua
  socket.url=${luasocket_SOURCE_DIR}/src/url.lua
)
add_library(
  luasocket STATIC
  luasocket.c
  ${luasocket_SOURCE_DIR}/src/auxiliar.c
  ${luasocket_SOURCE_DIR}/src/buffer.c
  ${luasocket_SOURCE_DIR}/src/compat.c
  ${luasocket_SOURCE_DIR}/src/except.c
  ${luasocket_SOURCE_DIR}/src/inet.c
  ${luasocket_SOURCE_DIR}/src/io.c
  ${luasocket_SOURCE_DIR}/src/luasocket.c
  ${luasocket_SOURCE_DIR}/src/mime.c
  ${luasocket_SOURCE_DIR}/src/options.c
  ${luasocket_SOURCE_DIR}/src/timeout.c
  ${luasocket_SOURCE_DIR}/src/select.c
  ${luasocket_SOURCE_DIR}/src/tcp.c
  ${luasocket_SOURCE_DIR}/src/udp.c
  $<$<PLATFORM_ID:Darwin,Linux>:${luasocket_SOURCE_DIR}/src/usocket.c>
  $<$<PLATFORM_ID:Windows>:${luasocket_SOURCE_DIR}/src/wsocket.c>
)
target_link_libraries(luasocket PRIVATE elune $<$<PLATFORM_ID:Windows>:ws2_32>)

FetchContent_Declare(
  casc
  URL https://luarocks.org/manifests/foxlit/luacasc-1.15-0.src.rock
  URL_HASH SHA256=af37a4f6494f0fd707a66bed50a236622645b937c31fd4a2ef6a33b6c1a3e1b0
  DOWNLOAD_NAME luacasc-1.15-0.src.rock.zip
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(casc)
file(
  ARCHIVE_EXTRACT
  INPUT ${casc_SOURCE_DIR}/luacasc-1.15.zip
  DESTINATION ${casc_SOURCE_DIR}
)
lua2c(
  casc
  casc=${casc_SOURCE_DIR}/luacasc/casc/init.lua
  casc.bin=${casc_SOURCE_DIR}/luacasc/casc/bin.lua
  casc.binc=c
  casc.blte=${casc_SOURCE_DIR}/luacasc/casc/blte.lua
  casc.bspatch=${casc_SOURCE_DIR}/luacasc/casc/bspatch.lua
  casc.dbc=${casc_SOURCE_DIR}/luacasc/casc/dbc.lua
  casc.encoding=${casc_SOURCE_DIR}/luacasc/casc/encoding.lua
  casc.install=${casc_SOURCE_DIR}/luacasc/casc/install.lua
  casc.jenkins96=${casc_SOURCE_DIR}/luacasc/casc/jenkins96.lua
  casc.md5=${casc_SOURCE_DIR}/luacasc/casc/md5.lua
  casc.platform=${casc_SOURCE_DIR}/luacasc/casc/platform.lua
  casc.ribbit=${casc_SOURCE_DIR}/luacasc/casc/ribbit.lua
  casc.root=${casc_SOURCE_DIR}/luacasc/casc/root.lua
)
add_library(
  casc STATIC
  casc.c
  ${casc_SOURCE_DIR}/luacasc/casc/bin.c
)
target_link_libraries(casc PRIVATE elune)

add_lua_executable(
  fetch
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/fetch.lua
  argparse
  casc
  dbc
  luaexpat
  luafilesystem
  luapath
  luasocket
  lzlib
  md5
  penlight
  runtimelistfile
  runtimetactkeys
  toolsdbc
)

FetchContent_Declare(
  libpng
  GIT_REPOSITORY https://github.com/glennrp/libpng
  GIT_TAG f8e5fa92b0e37ab597616f554bee254157998227
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(libpng)
configure_file(
  ${libpng_SOURCE_DIR}/scripts/pnglibconf.h.prebuilt
  ${libpng_SOURCE_DIR}/pnglibconf.h
)
add_library(
  libpng STATIC
  ${libpng_SOURCE_DIR}/arm/arm_init.c
  ${libpng_SOURCE_DIR}/arm/filter_neon.S
  ${libpng_SOURCE_DIR}/arm/filter_neon_intrinsics.c
  ${libpng_SOURCE_DIR}/arm/palette_neon_intrinsics.c
  ${libpng_SOURCE_DIR}/png.c
  ${libpng_SOURCE_DIR}/pngerror.c
  ${libpng_SOURCE_DIR}/pngget.c
  ${libpng_SOURCE_DIR}/pngmem.c
  ${libpng_SOURCE_DIR}/pngpread.c
  ${libpng_SOURCE_DIR}/pngread.c
  ${libpng_SOURCE_DIR}/pngrio.c
  ${libpng_SOURCE_DIR}/pngrtran.c
  ${libpng_SOURCE_DIR}/pngrutil.c
  ${libpng_SOURCE_DIR}/pngset.c
  ${libpng_SOURCE_DIR}/pngtrans.c
  ${libpng_SOURCE_DIR}/pngwio.c
  ${libpng_SOURCE_DIR}/pngwrite.c
  ${libpng_SOURCE_DIR}/pngwtran.c
  ${libpng_SOURCE_DIR}/pngwutil.c
)
target_include_directories(libpng PUBLIC ${libpng_SOURCE_DIR})
target_link_libraries(libpng PRIVATE zlib)

FetchContent_Declare(
  imagemagick
  GIT_REPOSITORY https://github.com/ImageMagick/ImageMagick6
  GIT_TAG 41e02a5b17b3f64565839134197fe169a838dd12
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(imagemagick)
file(WRITE ${imagemagick_SOURCE_DIR}/magick/magick-baseconfig.h.in [=[
#define MAGICKCORE_HAVE_STDINT_H
#define MAGICKCORE_HAVE_STRING_H
#define MAGICKCORE_HDRI_ENABLE 0
#define MAGICKCORE_CONFIGURE_RELATIVE_PATH "foo"
#define MAGICKCORE_LIBRARY_PATH "foo"
#define MAGICKCORE_LIBRARY_RELATIVE_PATH "foo"
#define MAGICKCORE_PACKAGE_NAME "ImageMagick"
#define MAGICKCORE_PNG_DELEGATE
#define MAGICKCORE_QUANTUM_DEPTH 16
#define MAGICKCORE_SHARE_RELATIVE_PATH "foo"
#define MAGICKCORE_SHAREARCH_BASEDIRNAME "foo"
#define MAGICKCORE_SIZEOF_VOID_P 8
#define MAGICKCORE_STDC_HEADERS
#cmakedefine MAGICKCORE_HAVE__ALIGNED_MALLOC
#cmakedefine MAGICKCORE_HAVE_UNISTD_H
#cmakedefine ssize_t @ssize_t@
]=])
block()
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(MAGICKCORE_HAVE__ALIGNED_MALLOC ON)
    set(ssize_t int)
  else()
    set(MAGICKCORE_HAVE_UNISTD_H ON)
  endif()
  configure_file(
    ${imagemagick_SOURCE_DIR}/magick/magick-baseconfig.h.in
    ${imagemagick_SOURCE_DIR}/magick/magick-baseconfig.h
  )
endblock()
block()
  set(DOCUMENTATION_PATH foo)
  set(PACKAGE_LIB_VERSION 0x69C)
  set(PACKAGE_NAME ImageMagick)
  set(PACKAGE_RELEASE_DATE 2023-09-04)
  set(PACKAGE_VERSION_ADDENDUM -94)
  set(MAGICK_GIT_REVISION 41e02a5b17b3f64565839134197fe169a838dd12)
  set(MAGICK_LIB_VERSION_NUMBER 6,0,0)
  set(MAGICK_LIB_VERSION_TEXT 6.9.12)
  set(MAGICK_LIBRARY_CURRENT 6)
  set(MAGICK_LIBRARY_CURRENT_MIN 6)
  set(MAGICK_TARGET_CPU x86_64)
  set(MAGICKPP_LIB_VERSION_TEXT 6.9.12)
  set(MAGICKPP_LIBRARY_CURRENT 8)
  set(MAGICKPP_LIBRARY_CURRENT_MIN 8)
  set(MAGICKPP_LIBRARY_VERSION_INFO 8:0:0)
  configure_file(
    ${imagemagick_SOURCE_DIR}/magick/version.h.in
    ${imagemagick_SOURCE_DIR}/magick/version.h
  )
endblock()
add_library(
  imagemagick STATIC
  ${imagemagick_SOURCE_DIR}/coders/aai.c
  ${imagemagick_SOURCE_DIR}/coders/art.c
  ${imagemagick_SOURCE_DIR}/coders/avs.c
  ${imagemagick_SOURCE_DIR}/coders/bgr.c
  ${imagemagick_SOURCE_DIR}/coders/bmp.c
  ${imagemagick_SOURCE_DIR}/coders/braille.c
  ${imagemagick_SOURCE_DIR}/coders/bytebuffer-private.h
  ${imagemagick_SOURCE_DIR}/coders/cals.c
  ${imagemagick_SOURCE_DIR}/coders/caption.c
  ${imagemagick_SOURCE_DIR}/coders/cin.c
  ${imagemagick_SOURCE_DIR}/coders/cip.c
  ${imagemagick_SOURCE_DIR}/coders/clip.c
  ${imagemagick_SOURCE_DIR}/coders/clipboard.c
  ${imagemagick_SOURCE_DIR}/coders/cmyk.c
  ${imagemagick_SOURCE_DIR}/coders/cut.c
  ${imagemagick_SOURCE_DIR}/coders/dcm.c
  ${imagemagick_SOURCE_DIR}/coders/dds.c
  ${imagemagick_SOURCE_DIR}/coders/debug.c
  ${imagemagick_SOURCE_DIR}/coders/dib.c
  ${imagemagick_SOURCE_DIR}/coders/djvu.c
  ${imagemagick_SOURCE_DIR}/coders/dng.c
  ${imagemagick_SOURCE_DIR}/coders/dot.c
  ${imagemagick_SOURCE_DIR}/coders/dps.c
  ${imagemagick_SOURCE_DIR}/coders/dpx.c
  ${imagemagick_SOURCE_DIR}/coders/emf.c
  ${imagemagick_SOURCE_DIR}/coders/ept.c
  ${imagemagick_SOURCE_DIR}/coders/exr.c
  ${imagemagick_SOURCE_DIR}/coders/fax.c
  ${imagemagick_SOURCE_DIR}/coders/fd.c
  ${imagemagick_SOURCE_DIR}/coders/fits.c
  ${imagemagick_SOURCE_DIR}/coders/flif.c
  ${imagemagick_SOURCE_DIR}/coders/fpx.c
  ${imagemagick_SOURCE_DIR}/coders/ghostscript-private.h
  ${imagemagick_SOURCE_DIR}/coders/gif.c
  ${imagemagick_SOURCE_DIR}/coders/gradient.c
  ${imagemagick_SOURCE_DIR}/coders/gray.c
  ${imagemagick_SOURCE_DIR}/coders/hald.c
  ${imagemagick_SOURCE_DIR}/coders/hdr.c
  ${imagemagick_SOURCE_DIR}/coders/heic.c
  ${imagemagick_SOURCE_DIR}/coders/histogram.c
  ${imagemagick_SOURCE_DIR}/coders/hrz.c
  ${imagemagick_SOURCE_DIR}/coders/html.c
  ${imagemagick_SOURCE_DIR}/coders/icon.c
  ${imagemagick_SOURCE_DIR}/coders/info.c
  ${imagemagick_SOURCE_DIR}/coders/inline.c
  ${imagemagick_SOURCE_DIR}/coders/ipl.c
  ${imagemagick_SOURCE_DIR}/coders/jbig.c
  ${imagemagick_SOURCE_DIR}/coders/jnx.c
  ${imagemagick_SOURCE_DIR}/coders/jp2.c
  ${imagemagick_SOURCE_DIR}/coders/jpeg.c
  ${imagemagick_SOURCE_DIR}/coders/json.c
  ${imagemagick_SOURCE_DIR}/coders/label.c
  ${imagemagick_SOURCE_DIR}/coders/mac.c
  ${imagemagick_SOURCE_DIR}/coders/magick.c
  ${imagemagick_SOURCE_DIR}/coders/map.c
  ${imagemagick_SOURCE_DIR}/coders/mask.c
  ${imagemagick_SOURCE_DIR}/coders/mat.c
  ${imagemagick_SOURCE_DIR}/coders/matte.c
  ${imagemagick_SOURCE_DIR}/coders/meta.c
  ${imagemagick_SOURCE_DIR}/coders/miff.c
  ${imagemagick_SOURCE_DIR}/coders/mono.c
  ${imagemagick_SOURCE_DIR}/coders/mpc.c
  ${imagemagick_SOURCE_DIR}/coders/mpr.c
  ${imagemagick_SOURCE_DIR}/coders/msl.c
  ${imagemagick_SOURCE_DIR}/coders/mtv.c
  ${imagemagick_SOURCE_DIR}/coders/mvg.c
  ${imagemagick_SOURCE_DIR}/coders/null.c
  ${imagemagick_SOURCE_DIR}/coders/otb.c
  ${imagemagick_SOURCE_DIR}/coders/palm.c
  ${imagemagick_SOURCE_DIR}/coders/pango.c
  ${imagemagick_SOURCE_DIR}/coders/pattern.c
  ${imagemagick_SOURCE_DIR}/coders/pcd.c
  ${imagemagick_SOURCE_DIR}/coders/pcl.c
  ${imagemagick_SOURCE_DIR}/coders/pcx.c
  ${imagemagick_SOURCE_DIR}/coders/pdb.c
  ${imagemagick_SOURCE_DIR}/coders/pdf.c
  ${imagemagick_SOURCE_DIR}/coders/pes.c
  ${imagemagick_SOURCE_DIR}/coders/pgx.c
  ${imagemagick_SOURCE_DIR}/coders/pict.c
  ${imagemagick_SOURCE_DIR}/coders/pix.c
  ${imagemagick_SOURCE_DIR}/coders/plasma.c
  ${imagemagick_SOURCE_DIR}/coders/png.c
  ${imagemagick_SOURCE_DIR}/coders/pnm.c
  ${imagemagick_SOURCE_DIR}/coders/preview.c
  ${imagemagick_SOURCE_DIR}/coders/ps.c
  ${imagemagick_SOURCE_DIR}/coders/ps2.c
  ${imagemagick_SOURCE_DIR}/coders/ps3.c
  ${imagemagick_SOURCE_DIR}/coders/psd-private.h
  ${imagemagick_SOURCE_DIR}/coders/psd.c
  ${imagemagick_SOURCE_DIR}/coders/pwp.c
  ${imagemagick_SOURCE_DIR}/coders/raw.c
  ${imagemagick_SOURCE_DIR}/coders/rgb.c
  ${imagemagick_SOURCE_DIR}/coders/rgf.c
  ${imagemagick_SOURCE_DIR}/coders/rla.c
  ${imagemagick_SOURCE_DIR}/coders/rle.c
  ${imagemagick_SOURCE_DIR}/coders/scr.c
  ${imagemagick_SOURCE_DIR}/coders/screenshot.c
  ${imagemagick_SOURCE_DIR}/coders/sct.c
  ${imagemagick_SOURCE_DIR}/coders/sfw.c
  ${imagemagick_SOURCE_DIR}/coders/sgi.c
  ${imagemagick_SOURCE_DIR}/coders/sixel.c
  ${imagemagick_SOURCE_DIR}/coders/stegano.c
  ${imagemagick_SOURCE_DIR}/coders/sun.c
  ${imagemagick_SOURCE_DIR}/coders/svg.c
  ${imagemagick_SOURCE_DIR}/coders/tga.c
  ${imagemagick_SOURCE_DIR}/coders/thumbnail.c
  ${imagemagick_SOURCE_DIR}/coders/tiff.c
  ${imagemagick_SOURCE_DIR}/coders/tile.c
  ${imagemagick_SOURCE_DIR}/coders/tim.c
  ${imagemagick_SOURCE_DIR}/coders/ttf.c
  ${imagemagick_SOURCE_DIR}/coders/txt.c
  ${imagemagick_SOURCE_DIR}/coders/uil.c
  ${imagemagick_SOURCE_DIR}/coders/url.c
  ${imagemagick_SOURCE_DIR}/coders/uyvy.c
  ${imagemagick_SOURCE_DIR}/coders/vicar.c
  ${imagemagick_SOURCE_DIR}/coders/vid.c
  ${imagemagick_SOURCE_DIR}/coders/video.c
  ${imagemagick_SOURCE_DIR}/coders/viff.c
  ${imagemagick_SOURCE_DIR}/coders/vips.c
  ${imagemagick_SOURCE_DIR}/coders/wbmp.c
  ${imagemagick_SOURCE_DIR}/coders/webp.c
  ${imagemagick_SOURCE_DIR}/coders/wmf.c
  ${imagemagick_SOURCE_DIR}/coders/wpg.c
  ${imagemagick_SOURCE_DIR}/coders/x.c
  ${imagemagick_SOURCE_DIR}/coders/xbm.c
  ${imagemagick_SOURCE_DIR}/coders/xc.c
  ${imagemagick_SOURCE_DIR}/coders/xcf.c
  ${imagemagick_SOURCE_DIR}/coders/xpm.c
  ${imagemagick_SOURCE_DIR}/coders/xps.c
  ${imagemagick_SOURCE_DIR}/coders/xwd.c
  ${imagemagick_SOURCE_DIR}/coders/ycbcr.c
  ${imagemagick_SOURCE_DIR}/coders/yuv.c
  ${imagemagick_SOURCE_DIR}/magick/accelerate.c
  ${imagemagick_SOURCE_DIR}/magick/animate.c
  ${imagemagick_SOURCE_DIR}/magick/annotate.c
  ${imagemagick_SOURCE_DIR}/magick/artifact.c
  ${imagemagick_SOURCE_DIR}/magick/attribute.c
  ${imagemagick_SOURCE_DIR}/magick/blob.c
  ${imagemagick_SOURCE_DIR}/magick/cache-view.c
  ${imagemagick_SOURCE_DIR}/magick/cache.c
  ${imagemagick_SOURCE_DIR}/magick/channel.c
  ${imagemagick_SOURCE_DIR}/magick/cipher.c
  ${imagemagick_SOURCE_DIR}/magick/client.c
  ${imagemagick_SOURCE_DIR}/magick/coder.c
  ${imagemagick_SOURCE_DIR}/magick/color.c
  ${imagemagick_SOURCE_DIR}/magick/colormap.c
  ${imagemagick_SOURCE_DIR}/magick/colorspace.c
  ${imagemagick_SOURCE_DIR}/magick/compare.c
  ${imagemagick_SOURCE_DIR}/magick/composite.c
  ${imagemagick_SOURCE_DIR}/magick/compress.c
  ${imagemagick_SOURCE_DIR}/magick/configure.c
  ${imagemagick_SOURCE_DIR}/magick/constitute.c
  ${imagemagick_SOURCE_DIR}/magick/decorate.c
  ${imagemagick_SOURCE_DIR}/magick/delegate.c
  ${imagemagick_SOURCE_DIR}/magick/deprecate.c
  ${imagemagick_SOURCE_DIR}/magick/display.c
  ${imagemagick_SOURCE_DIR}/magick/distort.c
  ${imagemagick_SOURCE_DIR}/magick/distribute-cache.c
  ${imagemagick_SOURCE_DIR}/magick/draw.c
  ${imagemagick_SOURCE_DIR}/magick/effect.c
  ${imagemagick_SOURCE_DIR}/magick/enhance.c
  ${imagemagick_SOURCE_DIR}/magick/exception.c
  ${imagemagick_SOURCE_DIR}/magick/feature.c
  ${imagemagick_SOURCE_DIR}/magick/fourier.c
  ${imagemagick_SOURCE_DIR}/magick/fx.c
  ${imagemagick_SOURCE_DIR}/magick/gem.c
  ${imagemagick_SOURCE_DIR}/magick/geometry.c
  ${imagemagick_SOURCE_DIR}/magick/hashmap.c
  ${imagemagick_SOURCE_DIR}/magick/histogram.c
  ${imagemagick_SOURCE_DIR}/magick/identify.c
  ${imagemagick_SOURCE_DIR}/magick/image-view.c
  ${imagemagick_SOURCE_DIR}/magick/image.c
  ${imagemagick_SOURCE_DIR}/magick/layer.c
  ${imagemagick_SOURCE_DIR}/magick/list.c
  ${imagemagick_SOURCE_DIR}/magick/locale.c
  ${imagemagick_SOURCE_DIR}/magick/log.c
  ${imagemagick_SOURCE_DIR}/magick/mac.c
  ${imagemagick_SOURCE_DIR}/magick/magic.c
  ${imagemagick_SOURCE_DIR}/magick/magick.c
  ${imagemagick_SOURCE_DIR}/magick/matrix.c
  ${imagemagick_SOURCE_DIR}/magick/memory.c
  ${imagemagick_SOURCE_DIR}/magick/mime.c
  ${imagemagick_SOURCE_DIR}/magick/module.c
  ${imagemagick_SOURCE_DIR}/magick/monitor.c
  ${imagemagick_SOURCE_DIR}/magick/montage.c
  ${imagemagick_SOURCE_DIR}/magick/morphology.c
  ${imagemagick_SOURCE_DIR}/magick/nt-base.c
  ${imagemagick_SOURCE_DIR}/magick/nt-feature.c
  ${imagemagick_SOURCE_DIR}/magick/opencl.c
  ${imagemagick_SOURCE_DIR}/magick/option.c
  ${imagemagick_SOURCE_DIR}/magick/paint.c
  ${imagemagick_SOURCE_DIR}/magick/pixel.c
  ${imagemagick_SOURCE_DIR}/magick/policy.c
  ${imagemagick_SOURCE_DIR}/magick/prepress.c
  ${imagemagick_SOURCE_DIR}/magick/profile.c
  ${imagemagick_SOURCE_DIR}/magick/property.c
  ${imagemagick_SOURCE_DIR}/magick/quantize.c
  ${imagemagick_SOURCE_DIR}/magick/quantum-export.c
  ${imagemagick_SOURCE_DIR}/magick/quantum-import.c
  ${imagemagick_SOURCE_DIR}/magick/quantum.c
  ${imagemagick_SOURCE_DIR}/magick/random.c
  ${imagemagick_SOURCE_DIR}/magick/registry.c
  ${imagemagick_SOURCE_DIR}/magick/resample.c
  ${imagemagick_SOURCE_DIR}/magick/resize.c
  ${imagemagick_SOURCE_DIR}/magick/resource.c
  ${imagemagick_SOURCE_DIR}/magick/segment.c
  ${imagemagick_SOURCE_DIR}/magick/semaphore.c
  ${imagemagick_SOURCE_DIR}/magick/shear.c
  ${imagemagick_SOURCE_DIR}/magick/signature.c
  ${imagemagick_SOURCE_DIR}/magick/splay-tree.c
  ${imagemagick_SOURCE_DIR}/magick/static.c
  ${imagemagick_SOURCE_DIR}/magick/statistic.c
  ${imagemagick_SOURCE_DIR}/magick/stream.c
  ${imagemagick_SOURCE_DIR}/magick/string.c
  ${imagemagick_SOURCE_DIR}/magick/thread.c
  ${imagemagick_SOURCE_DIR}/magick/threshold.c
  ${imagemagick_SOURCE_DIR}/magick/timer.c
  ${imagemagick_SOURCE_DIR}/magick/token.c
  ${imagemagick_SOURCE_DIR}/magick/transform.c
  ${imagemagick_SOURCE_DIR}/magick/type.c
  ${imagemagick_SOURCE_DIR}/magick/utility.c
  ${imagemagick_SOURCE_DIR}/magick/version.c
  ${imagemagick_SOURCE_DIR}/magick/vision.c
  ${imagemagick_SOURCE_DIR}/magick/visual-effects.c
  ${imagemagick_SOURCE_DIR}/magick/vms.c
  ${imagemagick_SOURCE_DIR}/magick/widget.c
  ${imagemagick_SOURCE_DIR}/magick/xml-tree.c
  ${imagemagick_SOURCE_DIR}/magick/xwindow.c
  ${imagemagick_SOURCE_DIR}/wand/animate.c
  ${imagemagick_SOURCE_DIR}/wand/compare.c
  ${imagemagick_SOURCE_DIR}/wand/composite.c
  ${imagemagick_SOURCE_DIR}/wand/conjure.c
  ${imagemagick_SOURCE_DIR}/wand/convert.c
  ${imagemagick_SOURCE_DIR}/wand/deprecate.c
  ${imagemagick_SOURCE_DIR}/wand/display.c
  ${imagemagick_SOURCE_DIR}/wand/drawing-wand.c
  ${imagemagick_SOURCE_DIR}/wand/identify.c
  ${imagemagick_SOURCE_DIR}/wand/import.c
  ${imagemagick_SOURCE_DIR}/wand/magick-image.c
  ${imagemagick_SOURCE_DIR}/wand/magick-property.c
  ${imagemagick_SOURCE_DIR}/wand/magick-wand.c
  ${imagemagick_SOURCE_DIR}/wand/mogrify.c
  ${imagemagick_SOURCE_DIR}/wand/montage.c
  ${imagemagick_SOURCE_DIR}/wand/pixel-iterator.c
  ${imagemagick_SOURCE_DIR}/wand/pixel-wand.c
  ${imagemagick_SOURCE_DIR}/wand/stream.c
  ${imagemagick_SOURCE_DIR}/wand/wand-view.c
  ${imagemagick_SOURCE_DIR}/wand/wand.c
)
target_include_directories(imagemagick PUBLIC ${imagemagick_SOURCE_DIR})
target_compile_definitions(imagemagick PUBLIC $<$<PLATFORM_ID:Windows>:_LIB>)
target_link_libraries(imagemagick PRIVATE libpng zlib $<$<PLATFORM_ID:Windows>:urlmon>)

FetchContent_Declare(
  luamagick
  GIT_REPOSITORY https://github.com/lua-wow-tools/luamagick
  GIT_TAG 91ade4c984835fc57bdb3b399e2d7a5fa3b63546
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(luamagick)
lua2c(luamagick luamagick=c)
add_library(luamagick STATIC luamagick.c ${luamagick_SOURCE_DIR}/luamagick.c)
target_link_libraries(luamagick PRIVATE elune imagemagick)

lua2c(
  wowlessrender
  wowless.blp=${CMAKE_CURRENT_SOURCE_DIR}/wowless/blp.lua
  wowless.render=${CMAKE_CURRENT_SOURCE_DIR}/wowless/render.lua
  wowless.png=${CMAKE_CURRENT_SOURCE_DIR}/wowless/png.lua
)
add_library(wowlessrender STATIC wowlessrender.c)
target_link_libraries(wowlessrender PRIVATE elune)

add_lua_executable(
  render
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/render.lua
  argparse
  casc
  luafilesystem
  luamagick
  luasocket
  lyaml
  lzlib
  md5
  penlight
  runtimetactkeys
  vstruct
  wowlessrender
  wowlessyaml
)

add_lua_executable(
  gentest
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/gentest.lua
  argparse
  luafilesystem
  penlight
  toolsutil
)

lua2c(runtimeproducts runtime.products=runtime/products.lua)
add_library(runtimeproducts STATIC runtimeproducts.c)
target_link_libraries(runtimeproducts PRIVATE elune)

add_lua_executable(
  bump
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/bump.lua
  argparse
  casc
  luafilesystem
  luasocket
  lyaml
  lzlib
  md5
  penlight
  runtimeproducts
  wowlessyaml
)

yaml2lua(impl)
yaml2lua(uiobjectimpl)

foreach(product ${products})
  foreach(yaml apis build config cvars events globals structures uiobjects xml)
    yaml2lua(products/${product}/${yaml})
    list(
      APPEND yamlluas
      build.data.products.${product}.${yaml}=runtime/products/${product}/${yaml}.lua
    )
  endforeach()
endforeach()
list(
  APPEND
  schemas
  addons
  any
  apis
  build
  config
  cvars
  docs
  events
  flavors
  globals
  impl
  products
  schema
  schematype
  state
  stringenums
  structures
  type
  uiobjectimpl
  uiobjects
  xml
)
foreach(schema ${schemas})
  yaml2lua(schemas/${schema})
  list(APPEND yamlluas build.data.schemas.${schema}=runtime/schemas/${schema}.lua)
endforeach()
list(
  APPEND
  states
  Addons
  Bindings
  CVars
  Calendar
  ModifiedClicks
  System
  Talents
  Time
  Units
)
foreach(state ${states})
  yaml2lua(state/${state})
  list(APPEND yamlluas build.data.state.${state}=runtime/state/${state}.lua)
endforeach()

lua2c(
  wowapischema
  build.data.flavors=runtime/flavors.lua
  build.data.impl=runtime/impl.lua
  build.data.products=runtime/products.lua
  build.data.stringenums=runtime/stringenums.lua
  build.data.uiobjectimpl=runtime/uiobjectimpl.lua
  ${yamlluas}
  wowapi.data=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/data.lua
  wowapi.schema=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/schema.lua
)
add_library(wowapischema STATIC wowapischema.c)
target_link_libraries(wowapischema PRIVATE elune)

add_lua_executable(
  docs
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/docs.lua
  argparse
  luafilesystem
  luapath
  lyaml
  penlight
  toolsutil
  wowapischema
  wowlessyaml
)

add_lua_executable(
  errsv
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/errsv.lua
  luafilesystem
  lyaml
  penlight
  wowlessyaml
)

file(GENERATE OUTPUT runtime/platform.lua CONTENT "\
return '\
$<$<PLATFORM_ID:Darwin>:mac>\
$<$<PLATFORM_ID:Linux>:linux>\
$<$<PLATFORM_ID:Windows>:windows>\
'\n")

lua2c(
  wowlesslib
  runtime.flavors=runtime/flavors.lua
  runtime.platform=runtime/platform.lua
  runtime.stringenums=runtime/stringenums.lua
  wowapi.loader=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/loader.lua
  wowapi.uiobjects=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/uiobjects.lua
  wowless.api=${CMAKE_CURRENT_SOURCE_DIR}/wowless/api.lua
  wowless.env=${CMAKE_CURRENT_SOURCE_DIR}/wowless/env.lua
  wowless.ext=c
  wowless.hlist=${CMAKE_CURRENT_SOURCE_DIR}/wowless/hlist.lua
  wowless.loader=${CMAKE_CURRENT_SOURCE_DIR}/wowless/loader.lua
  wowless.profiler=${CMAKE_CURRENT_SOURCE_DIR}/wowless/profiler.lua
  wowless.runner=${CMAKE_CURRENT_SOURCE_DIR}/wowless/runner.lua
  wowless.typecheck=${CMAKE_CURRENT_SOURCE_DIR}/wowless/typecheck.lua
  wowless.xml=${CMAKE_CURRENT_SOURCE_DIR}/wowless/xml.lua
)
add_library(
  wowlesslib STATIC
  wowlesslib.c
  wowless/ext.c
)
target_link_libraries(wowlesslib PRIVATE elune)

add_lua_executable(
  wowless
  ${CMAKE_CURRENT_SOURCE_DIR}/wowless.lua
  argparse
  ${dataluas}
  date
  lsqlite3
  luaexpat
  luafilesystem
  luapath
  lyaml
  lzlib
  minheap
  penlight
  runtimeproducts
  tsort
  wowlesslib
  wowlessrender
  wowlessutil
  wowlessyaml
)

add_lua_executable(
  runtests
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/runtests.lua
  argparse
  ${dataluas}
  date
  lsqlite3
  luaexpat
  luafilesystem
  luapath
  luassert
  lyaml
  lzlib
  minheap
  penlight
  runtimeproducts
  say
  tsort
  vstruct
  wowapischema
  wowlesslib
  wowlessrender
  wowlessutil
  wowlessyaml
)
