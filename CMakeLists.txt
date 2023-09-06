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
target_include_directories(elune PRIVATE ${utf8h_SOURCE_DIR})
target_include_directories(
  elune PUBLIC
  ${elune_SOURCE_DIR}/liblua/include
  ${elune_BINARY_DIR}
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
lua2c(expat lxp=c)
add_library(
  luaexpat STATIC
  expat.c
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
target_compile_definitions(zlib PRIVATE Z_HAVE_UNISTD_H)
target_include_directories(zlib PUBLIC ${zlib_SOURCE_DIR})

FetchContent_Declare(
  lzlib
  GIT_REPOSITORY https://github.com/luadist/lzlib.git
  GIT_TAG 0.4.3
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(lzlib)
lua2c(zlib zlib=c)
add_library(
  lzlib STATIC
  zlib.c
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
lua2c(lsqlite3 lsqlite3=c)
add_library(
  lsqlite3 STATIC
  lsqlite3.c
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
lua2c(luafilesystem lfs=c)
add_library(
  luafilesystem STATIC
  luafilesystem.c
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
lua2c(say say=${say_SOURCE_DIR}/src/say/init.lua)
add_library(say STATIC say.c)
target_link_libraries(say elune)

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
target_link_libraries(luassert elune say)

FetchContent_Declare(
  argparse
  GIT_REPOSITORY https://github.com/luarocks/argparse
  GIT_TAG 27967d7b52295ea7885671af734332038c132837
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(argparse)
lua2c(argparse argparse=${argparse_SOURCE_DIR}/src/argparse.lua)
add_library(argparse STATIC argparse.c)
target_link_libraries(argparse elune)

FetchContent_Declare(
  date
  GIT_REPOSITORY https://github.com/tieske/date.git
  GIT_TAG e309741edc15bde2c884b0db09d8560848773b50
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(date)
lua2c(date date=${date_SOURCE_DIR}/src/date.lua)
add_library(date STATIC date.c)
target_link_libraries(date elune)

FetchContent_Declare(
  tsort
  GIT_REPOSITORY https://github.com/bungle/lua-resty-tsort
  GIT_TAG 07754a8af7c51ca5fbcf05dc5f4b1b900f1bf530
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(tsort)
lua2c(tsort resty.tsort=${tsort_SOURCE_DIR}/lib/resty/tsort.lua)
add_library(tsort STATIC tsort.c)
target_link_libraries(tsort elune)

FetchContent_Declare(
  minheap
  GIT_REPOSITORY https://github.com/mah0x211/lua-minheap
  GIT_TAG c5fe42b60cf5b3ee7ed6d33eb31be1119dfb1cd6
  SOURCE_SUBDIR disable_cmakelists_txt
)
FetchContent_MakeAvailable(minheap)
lua2c(minheap minheap=${minheap_SOURCE_DIR}/minheap.lua)
add_library(minheap STATIC minheap.c)
target_link_libraries(minheap elune)

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
target_link_libraries(luapath elune)

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
target_link_libraries(penlight elune)

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
target_link_libraries(vstruct elune)

add_library(
  wowlesslib STATIC
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
  luapath
  lyaml
  lzlib
  minheap
  penlight
  tsort
  vstruct
  wowlesslib
)

add_executable(test test.c)
target_link_libraries(
  test
  argparse
  date
  elune
  lsqlite3
  luaexpat
  luafilesystem
  luapath
  luassert
  lyaml
  lzlib
  minheap
  penlight
  tsort
  vstruct
  wowlesslib
)
