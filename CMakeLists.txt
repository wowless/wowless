cmake_minimum_required(VERSION 3.24)

set(CMAKE_TOOLCHAIN_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake
    CACHE STRING "Vcpkg toolchain file")

project(wowless LANGUAGES C)

include(FetchContent)

set(elune_SOURCE_DIR vendor/elune)
set(elune_BINARY_DIR ${CMAKE_BINARY_DIR}/_deps/elune-build)
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
  ${elune_SOURCE_DIR}/liblua/lzio.c)
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
configure_file(${elune_SOURCE_DIR}/liblua/include/luaconf.h.in
               ${elune_BINARY_DIR}/luaconf.h)
endblock()
find_path(UTF8H_INCLUDE_DIRS utf8h/utf8.h)
target_include_directories(elune PRIVATE ${UTF8H_INCLUDE_DIRS}/utf8h)
target_include_directories(elune PUBLIC ${elune_SOURCE_DIR}/liblua/include
                                        ${elune_BINARY_DIR})
target_link_libraries(elune PRIVATE $<$<PLATFORM_ID:Darwin,Linux>:m>
                                    $<$<PLATFORM_ID:Windows>:bcrypt>)
target_compile_definitions(elune
                           PRIVATE $<$<PLATFORM_ID:Darwin,Linux>:_GNU_SOURCE>)
set_target_properties(elune PROPERTIES C_STANDARD 11)

add_executable(bootstraplua ${elune_SOURCE_DIR}/lua/lua.c)
target_link_libraries(bootstraplua PRIVATE elune)

find_package(expat CONFIG REQUIRED)

function(lua2c name)
  foreach(arg ${ARGN})
    string(FIND ${arg} "=" eqpos)
    math(EXPR eqposy "${eqpos} + 1")
    string(SUBSTRING ${arg} 0 ${eqpos} package)
    string(SUBSTRING ${arg} ${eqposy} -1 file)
    if(${file} STREQUAL "p")
      list(APPEND preloads ${package})
    elseif(NOT (${file} STREQUAL "c"))
      string(REPLACE "." "_" pkg ${package})
      set(output lua2c/${pkg}.c)
      set(cmd ${CMAKE_CURRENT_SOURCE_DIR}/tools/file2c.lua)
      add_custom_command(
        OUTPUT ${output}
        COMMAND bootstraplua ${cmd} ${package} ${file} ${output}
        DEPENDS ${cmd} ${file})
      list(APPEND deps ${output})
    endif()
  endforeach()
  add_custom_command(
    OUTPUT ${name}.c
    COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua ${name}
            ${ARGN}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2c.lua ${deps})
  add_library(${name} STATIC ${name}.c tools/file2c.h tools/lua2c.h ${deps})
  target_include_directories(${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
  target_link_libraries(${name} PRIVATE elune ${preloads})
endfunction()

FetchContent_Declare(
  luaexpat
  GIT_REPOSITORY https://github.com/lunarmodules/luaexpat.git
  GIT_TAG 1.4.1
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(luaexpat)
lua2c(luaexpat lxp=c)
target_sources(luaexpat PRIVATE ${luaexpat_SOURCE_DIR}/src/lxplib.c)
target_link_libraries(luaexpat PRIVATE expat::expat)

find_package(yaml CONFIG REQUIRED)

find_package(ZLIB REQUIRED)

find_package(unofficial-sqlite3 CONFIG REQUIRED)

lua2c(wowlesssqlite wowless.sqlite=c)
target_sources(wowlesssqlite PRIVATE wowless/sqlite.c)
target_link_libraries(wowlesssqlite PRIVATE unofficial::sqlite3::sqlite3)

FetchContent_Declare(
  luafilesystem
  GIT_REPOSITORY https://github.com/lunarmodules/luafilesystem.git
  GIT_TAG v1_8_0
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(luafilesystem)
lua2c(luafilesystem lfs=c)
target_sources(luafilesystem PRIVATE ${luafilesystem_SOURCE_DIR}/src/lfs.c)

FetchContent_Declare(
  say
  GIT_REPOSITORY https://github.com/lunarmodules/say.git
  GIT_TAG 3e1f783d0aa496eb21d16e85b2235335cb9332df
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(say)
lua2c(say say=${say_SOURCE_DIR}/src/say/init.lua)

FetchContent_Declare(
  luassert
  GIT_REPOSITORY https://github.com/lunarmodules/luassert.git
  GIT_TAG 8c9385b1a1944a5ce0ef9dbd721ad1987cf85e9d
  SOURCE_SUBDIR disable_cmakelists_txt)
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
  say=p)

FetchContent_Declare(
  argparse
  GIT_REPOSITORY https://github.com/luarocks/argparse
  GIT_TAG 27967d7b52295ea7885671af734332038c132837
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(argparse)
lua2c(argparse argparse=${argparse_SOURCE_DIR}/src/argparse.lua)

FetchContent_Declare(
  date
  GIT_REPOSITORY https://github.com/tieske/date.git
  GIT_TAG e309741edc15bde2c884b0db09d8560848773b50
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(date)
lua2c(date date=${date_SOURCE_DIR}/src/date.lua)

FetchContent_Declare(
  tsort
  GIT_REPOSITORY https://github.com/bungle/lua-resty-tsort
  GIT_TAG 07754a8af7c51ca5fbcf05dc5f4b1b900f1bf530
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(tsort)
lua2c(tsort resty.tsort=${tsort_SOURCE_DIR}/lib/resty/tsort.lua)

FetchContent_Declare(
  minheap
  GIT_REPOSITORY https://github.com/mah0x211/lua-minheap
  GIT_TAG c5fe42b60cf5b3ee7ed6d33eb31be1119dfb1cd6
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(minheap)
lua2c(minheap minheap=${minheap_SOURCE_DIR}/minheap.lua)

FetchContent_Declare(
  luapath
  GIT_REPOSITORY https://github.com/moteus/lua-path
  GIT_TAG 5a32c7052e84cdb9dcbcd45648aae3f6927376ac
  SOURCE_SUBDIR disable_cmakelists_txt)
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
  path.win32.wcs=${luapath_SOURCE_DIR}/lua/path/win32/wcs.lua)

FetchContent_Declare(
  penlight
  GIT_REPOSITORY https://github.com/lunarmodules/penlight
  GIT_TAG 3bf03267b2571ba3cfa676a10528dd7b9a0db404
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(penlight)
lua2c(
  penlight
  luafilesystem=p
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
  pl.import_into=${penlight_SOURCE_DIR}/lua/pl/import_into.lua)

FetchContent_Declare(
  vstruct
  GIT_REPOSITORY https://github.com/toxicfrog/vstruct
  GIT_TAG b6889e3b275e9f9532b5dff4917e903b17e22730
  SOURCE_SUBDIR disable_cmakelists_txt)
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
  vstruct.lexer=${vstruct_SOURCE_DIR}/lexer.lua)

add_library(luamain STATIC tools/luamain.c tools/luamain.h tools/lua2c.h
                           tools/file2c.h)
target_include_directories(luamain PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(luamain PUBLIC elune)

function(add_lua_executable name main)
  add_custom_command(
    OUTPUT ${name}luafile.c
    COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/file2c.lua main
            ${main} ${name}luafile.c
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/file2c.lua ${main})
  set(luamain ${name}luamain.c)
  add_custom_command(
    OUTPUT ${luamain}
    COMMAND bootstraplua ${CMAKE_CURRENT_SOURCE_DIR}/tools/luamain.lua
            ${luamain} ${ARGN}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tools/luamain.lua ${main})
  add_executable(${name} ${luamain} ${name}luafile.c)
  target_include_directories(${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
  target_link_libraries(${name} PRIVATE ${ARGN} luamain)
endfunction()

lua2c(wowlessyaml wowapi.cyaml=c
      wowapi.yaml=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/yaml.lua)
target_sources(wowlessyaml PRIVATE wowapi/cyaml.c)
target_link_libraries(wowlessyaml PRIVATE yaml)

add_lua_executable(yaml2lua ${CMAKE_CURRENT_SOURCE_DIR}/tools/yaml2lua.lua
                   penlight wowlessyaml)
add_lua_executable(lua2yaml ${CMAKE_CURRENT_SOURCE_DIR}/tools/lua2yaml.lua
                   penlight wowlessyaml)

function(yaml2lua basename)
  set(input ${CMAKE_CURRENT_SOURCE_DIR}/data/${basename}.yaml)
  set(output runtime/${basename}.lua)
  add_custom_command(
    OUTPUT ${output}
    COMMAND yaml2lua ${input} ${output}
    DEPENDS yaml2lua ${input})
endfunction()

yaml2lua(families)
yaml2lua(gametypes)
yaml2lua(modules)
yaml2lua(products)
yaml2lua(stringenums)

lua2c(toolsutil tools.util=${CMAKE_CURRENT_SOURCE_DIR}/tools/util.lua)

add_lua_executable(sqls ${CMAKE_CURRENT_SOURCE_DIR}/tools/sqls.lua penlight
                   toolsutil wowlessyaml)
add_custom_command(
  COMMENT "Collecting SQL"
  OUTPUT stamp/sqls.txt
  BYPRODUCTS runtime/sqls.yaml
  COMMAND sqls ${CMAKE_CURRENT_BINARY_DIR}/generated/sqls.yaml
  COMMAND
    ${CMAKE_COMMAND} -E copy_if_different
    ${CMAKE_CURRENT_BINARY_DIR}/generated/sqls.yaml
    ${CMAKE_CURRENT_BINARY_DIR}/runtime/sqls.yaml
  COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/stamp/sqls.txt
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPFILE generated/sqls.yaml.d
  DEPENDS sqls data/sql.yaml)
add_custom_target(stamp_sqls DEPENDS stamp/sqls.txt)

lua2c(wowlessutil luapath=p wowless.mixin=c
      wowless.util=${CMAKE_CURRENT_SOURCE_DIR}/wowless/util.lua)
target_sources(wowlessutil PRIVATE wowless/mixin.c)

FetchContent_Declare(
  cjson
  GIT_REPOSITORY https://github.com/openresty/lua-cjson
  GIT_TAG 2bfad8f5eeb821357d2ada29506e864ff7ec947e
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(cjson)
lua2c(luacjson cjson=c)
target_sources(
  luacjson PRIVATE ${cjson_SOURCE_DIR}/fpconv.c ${cjson_SOURCE_DIR}/lua_cjson.c
                   ${cjson_SOURCE_DIR}/strbuf.c)

add_lua_executable(listfile ${CMAKE_CURRENT_SOURCE_DIR}/tools/listfile.lua
                   argparse luacjson penlight toolsutil)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/generated
     ${CMAKE_CURRENT_BINARY_DIR}/lua2c ${CMAKE_CURRENT_BINARY_DIR}/runtime
     ${CMAKE_CURRENT_BINARY_DIR}/stamp)

add_custom_command(
  OUTPUT stamp/listfile.txt
  BYPRODUCTS runtime/listfile.lua
  COMMAND listfile ${CMAKE_CURRENT_SOURCE_DIR}/vendor/dbdefs/manifest.json
          generated/listfile.lua
  COMMAND ${CMAKE_COMMAND} -E copy_if_different generated/listfile.lua
          runtime/listfile.lua
  COMMAND ${CMAKE_COMMAND} -E touch stamp/listfile.txt
  DEPENDS listfile ${CMAKE_CURRENT_SOURCE_DIR}/vendor/dbdefs/manifest.json)
add_custom_target(listfilelua DEPENDS stamp/listfile.txt)
lua2c(runtimelistfile runtime.listfile=runtime/listfile.lua)
add_dependencies(runtimelistfile listfilelua)

# TODO derive this from data/products.yaml, or vice versa
list(
  APPEND
  products
  wow
  wowt
  wowxptr
  wow_anniversary
  wow_beta
  wow_classic
  wow_classic_beta
  wow_classic_era
  wow_classic_era_ptr
  wow_classic_ptr)

add_lua_executable(
  dblist
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/dblist.lua
  argparse
  penlight
  toolsutil
  wowlesssqlite
  wowlessyaml)

foreach(product ${products})
  set(f ${product}_dblist.lua)
  add_custom_command(
    OUTPUT stamp/${f}
    BYPRODUCTS runtime/${f}
    COMMAND dblist ${product}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different generated/${f} runtime/${f}
    COMMAND ${CMAKE_COMMAND} -E touch stamp/${f}
    DEPENDS dblist runtime/sqls.yaml runtime/${product}.lua)
  add_custom_target(stamp_${product}_dblist DEPENDS stamp/${f})
  add_dependencies(stamp_${product}_dblist datalua_${product}_lua stamp_sqls)
endforeach()

FetchContent_Declare(
  lpeg
  URL http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.1.0.tar.gz
  URL_HASH MD5=842a538b403b5639510c9b6fffd2c75b
  SOURCE_SUBDIR disable_cmakelists_txt
  TLS_VERIFY OFF)
FetchContent_MakeAvailable(lpeg)
lua2c(lpeg lpeg=c)
target_sources(
  lpeg
  PRIVATE ${lpeg_SOURCE_DIR}/lpcap.c ${lpeg_SOURCE_DIR}/lpcode.c
          ${lpeg_SOURCE_DIR}/lpcset.c ${lpeg_SOURCE_DIR}/lpprint.c
          ${lpeg_SOURCE_DIR}/lptree.c ${lpeg_SOURCE_DIR}/lpvm.c)

FetchContent_Declare(
  luadbd
  GIT_REPOSITORY https://github.com/lua-wow-tools/luadbd
  GIT_TAG 600ca1dcc83f9dee7ca165b27d17f7d0355db6e2
  SOURCE_SUBDIR disable_cmakelists_txt)
FetchContent_MakeAvailable(luadbd)
lua2c(luadbd luadbd.parser=${luadbd_SOURCE_DIR}/luadbd/parser.lua)

add_lua_executable(
  dbdefs
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/dbdefs.lua
  argparse
  lpeg
  luadbd
  penlight
  toolsutil)

foreach(product ${products})
  set(f ${product}_dbdefs.lua)
  add_custom_command(
    OUTPUT stamp/${f}
    BYPRODUCTS runtime/${f}
    COMMAND dbdefs ${product} ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different generated/${f} runtime/${f}
    COMMAND ${CMAKE_COMMAND} -E touch stamp/${f}
    DEPFILE generated/${f}.d
    DEPENDS dbdefs runtime/${product}_dblist.lua
            runtime/products/${product}/build.lua)
  add_custom_target(stamp_${product}_dbdefs DEPENDS stamp/${f})
  add_dependencies(stamp_${product}_dbdefs stamp_${product}_dblist)
endforeach()

add_lua_executable(
  prep
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/prep.lua
  argparse
  penlight
  toolsutil
  wowlessutil
  wowlessyaml)

foreach(product ${products})
  add_custom_command(
    OUTPUT stamp/${product}.txt
    BYPRODUCTS runtime/${product}.lua generated/${product}_stubs.c
    COMMAND
      prep ${product} --sqls ${CMAKE_CURRENT_BINARY_DIR}/runtime/sqls.yaml
      --output ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}.lua --coutput
      ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}_stubs.c
    COMMAND
      ${CMAKE_COMMAND} -E copy_if_different
      ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}.lua
      ${CMAKE_CURRENT_BINARY_DIR}/runtime/${product}.lua
    COMMAND ${CMAKE_COMMAND} -E touch
            ${CMAKE_CURRENT_BINARY_DIR}/stamp/${product}.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPFILE generated/${product}.lua.d
    DEPENDS prep runtime/sqls.yaml)
  add_custom_target(datalua_${product}_lua DEPENDS stamp/${product}.txt)
  add_dependencies(datalua_${product}_lua stamp_sqls)
  lua2c(datalua_${product}
        build.products.${product}.data=runtime/${product}.lua
        build.products.${product}.stubs=c)
  target_sources(
    datalua_${product}
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/generated/${product}_stubs.c)
  add_dependencies(datalua_${product} datalua_${product}_lua)
  list(APPEND dataluas datalua_${product})
endforeach()

lua2c(toolssqlite3ext tools.sqlite3ext=c)
target_sources(toolssqlite3ext PRIVATE tools/sqlite3ext.c)
target_link_libraries(toolssqlite3ext PRIVATE unofficial::sqlite3::sqlite3)

add_lua_executable(
  sqlite
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/sqlite.lua
  argparse
  penlight
  toolsdb2
  toolssqlite3ext
  wowlesssqlite)

foreach(product ${products})
  add_custom_command(
    OUTPUT ${product}_schema.sqlite3
    COMMAND sqlite ${product}
    DEPENDS sqlite runtime/${product}_dbdefs.lua runtime/${product}_dblist.lua)
  list(APPEND schemadbs ${product}_schema.sqlite3)
  add_custom_command(
    OUTPUT ${product}_data.sqlite3
    COMMAND sqlite -f ${product}
    DEPENDS sqlite runtime/${product}_dbdefs.lua runtime/${product}_dblist.lua
            ${product}_fetch.txt)
endforeach()

find_package(CURL REQUIRED)
find_package(OpenSSL REQUIRED)

add_library(tactless STATIC vendor/tactless/tactless.c
                            vendor/tactless/tactless.h)
target_include_directories(tactless PUBLIC vendor/tactless)
target_link_libraries(tactless PRIVATE OpenSSL::Crypto CURL::libcurl ZLIB::ZLIB)

lua2c(toolstactless tactless=c)
target_sources(toolstactless PRIVATE tools/tactless.c)
target_link_libraries(toolstactless PRIVATE tactless)

lua2c(wowlesstoc wowless.toc=${CMAKE_CURRENT_SOURCE_DIR}/wowless/toc.lua)

add_lua_executable(
  fetch
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/fetch.lua
  argparse
  luaexpat
  luapath
  penlight
  runtimegametypes
  runtimelistfile
  toolsdb2
  toolstactless
  toolsutil
  wowlesstoc)

foreach(product ${products})
  set(out ${product}_fetch.txt)
  add_custom_command(
    OUTPUT ${out}
    COMMAND fetch ${product}
    COMMAND ${CMAKE_COMMAND} -E touch ${out}
    DEPENDS fetch runtime/${product}_dblist.lua
            runtime/products/${product}/build.lua)
endforeach()

lua2c(wowlessblp vstruct=p
      wowless.blp=${CMAKE_CURRENT_SOURCE_DIR}/wowless/blp.lua)

lua2c(wowlessrender
      wowless.render=${CMAKE_CURRENT_SOURCE_DIR}/wowless/render.lua)

add_lua_executable(gentest ${CMAKE_CURRENT_SOURCE_DIR}/tools/gentest.lua
                   argparse penlight toolsutil wowlessyaml)

foreach(product ${products})
  set(d ${CMAKE_CURRENT_BINARY_DIR}/products/${product}/WowlessData)
  set(staging ${CMAKE_CURRENT_BINARY_DIR}/products/${product}/gentest-staging)
  file(MAKE_DIRECTORY ${d} ${staging})
  macro(gentest file name)
    set(staged ${staging}/${file})
    set(out ${d}/${file})
    list(APPEND outs ${out})
    add_custom_command(
      OUTPUT ${staged}
      COMMAND gentest ${product} ${name} ${staged}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      DEPFILE ${staged}.d
      DEPENDS gentest)
    add_custom_command(
      OUTPUT ${out}
      COMMAND ${CMAKE_COMMAND} -DSRC=${staged} -DDST_DIR=${d} -P
              ${CMAKE_CURRENT_SOURCE_DIR}/cmake/copy_executable.cmake
      DEPENDS ${staged})
  endmacro()
  gentest(WowlessData.toc toc)
  gentest(build.lua build)
  gentest(config.lua config)
  gentest(cvars.lua cvars)
  gentest(events.lua events)
  gentest(globalapis.lua globalapis)
  gentest(globals.lua globals)
  gentest(impltests.lua impltests)
  gentest(luaobjects.lua luaobjects)
  gentest(namespaceapis.lua namespaceapis)
  gentest(product.lua product)
  gentest(uiobjectapis.lua uiobjectapis)
  add_custom_command(
    OUTPUT ${product}_addon.txt
    COMMAND ${CMAKE_COMMAND} -E touch ${product}_addon.txt
    DEPENDS ${outs})
  list(APPEND addons ${product}_addon.txt)
endforeach()
add_custom_command(
  OUTPUT addons.txt
  COMMAND ${CMAKE_COMMAND} -E touch addons.txt
  DEPENDS ${addons})

lua2c(runtimegametypes runtime.gametypes=runtime/gametypes.lua)
lua2c(runtimeproducts runtime.products=runtime/products.lua)

add_lua_executable(
  bump
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/bump.lua
  argparse
  penlight
  runtimeproducts
  toolstactless
  wowlessyaml)
foreach(product ${products})
  add_custom_target(
    bump-${product}
    COMMAND bump ${product}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endforeach()
add_custom_target(
  bump-all
  COMMAND bump
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

yaml2lua(impl)
yaml2lua(scripttypes)
yaml2lua(sql)
yaml2lua(test)
yaml2lua(uiobjectimpl)

foreach(product ${products})
  foreach(
    yaml
    apis
    build
    config
    cvars
    docs
    events
    globals
    luaobjects
    structures
    uiobjects
    xml)
    yaml2lua(products/${product}/${yaml})
    list(
      APPEND
      yamlluas
      build.data.products.${product}.${yaml}=runtime/products/${product}/${yaml}.lua
    )
  endforeach()
endforeach()
list(
  APPEND
  schemas
  apis
  build
  config
  cvars
  docs
  doctable
  events
  families
  function
  gametypes
  globals
  impl
  luaobjects
  modules
  products
  schema
  schematype
  scripttypes
  sql
  stringenums
  structures
  test
  type
  uiobjectimpl
  uiobjects
  xml)
foreach(schema ${schemas})
  yaml2lua(schemas/${schema})
  list(APPEND yamlluas
       build.data.schemas.${schema}=runtime/schemas/${schema}.lua)
endforeach()

lua2c(
  wowapischema
  build.data.families=runtime/families.lua
  build.data.gametypes=runtime/gametypes.lua
  build.data.impl=runtime/impl.lua
  build.data.modules=runtime/modules.lua
  build.data.products=runtime/products.lua
  build.data.scripttypes=runtime/scripttypes.lua
  build.data.sql=runtime/sql.lua
  build.data.stringenums=runtime/stringenums.lua
  build.data.test=runtime/test.lua
  build.data.uiobjectimpl=runtime/uiobjectimpl.lua
  ${yamlluas}
  luapath=p
  wowapi.data=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/data.lua
  wowapi.schema=${CMAKE_CURRENT_SOURCE_DIR}/wowapi/schema.lua)

lua2c(toolstedit tools.tedit=${CMAKE_CURRENT_SOURCE_DIR}/tools/tedit.lua)

add_lua_executable(
  docs
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/docs.lua
  argparse
  penlight
  toolstedit
  toolsutil
  tsort
  wowapischema
  wowlessyaml)
foreach(product ${products})
  add_custom_target(
    docs-${product}
    COMMAND docs ${product}
    DEPENDS ${product}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  list(APPEND docsallcmds COMMAND docs ${product})
endforeach()
add_custom_target(
  docs-all
  ${docsallcmds}
  DEPENDS ${products}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_lua_executable(errsv ${CMAKE_CURRENT_SOURCE_DIR}/tools/errsv.lua penlight
                   wowlessyaml)

lua2c(toolsdb2 tools.db2=${CMAKE_CURRENT_SOURCE_DIR}/tools/db2.lua vstruct=p)

add_lua_executable(db2dump ${CMAKE_CURRENT_SOURCE_DIR}/tools/db2dump.lua
                   argparse penlight toolsdb2)

add_lua_executable(rewrite ${CMAKE_CURRENT_SOURCE_DIR}/tools/rewrite.lua
                   argparse penlight wowlessyaml)

add_lua_executable(schema ${CMAKE_CURRENT_SOURCE_DIR}/tools/schema.lua argparse
                   penlight wowapischema wowlessyaml)

add_lua_executable(yedit ${CMAKE_CURRENT_SOURCE_DIR}/tools/yedit.lua argparse
                   penlight toolstedit wowlessyaml)

file(
  GENERATE
  OUTPUT runtime/platform.lua
  CONTENT
    "\
return '\
$<$<PLATFORM_ID:Darwin>:mac>\
$<$<PLATFORM_ID:Linux>:linux>\
$<$<PLATFORM_ID:Windows>:windows>\
'\n")

lua2c(
  wowlesslib
  luapath=p
  runtime.modules=runtime/modules.lua
  runtime.platform=runtime/platform.lua
  runtime.stringenums=runtime/stringenums.lua
  wowless.bubblewrap=c
  wowless.env=${CMAKE_CURRENT_SOURCE_DIR}/wowless/env.lua
  wowless.ext=c
  wowless.hlist=${CMAKE_CURRENT_SOURCE_DIR}/wowless/hlist.lua
  wowless.luaobject=c
  wowless.modules=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules.lua
  wowless.modules.addons=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/addons.lua
  wowless.modules.api=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/api.lua
  wowless.modules.apiloader=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/apiloader.lua
  wowless.modules.atlas=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/atlas.lua
  wowless.modules.calendar=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/calendar.lua
  wowless.modules.cvars=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/cvars.lua
  wowless.modules.datetime=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/datetime.lua
  wowless.modules.dirty=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/dirty.lua
  wowless.modules.env=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/env.lua
  wowless.modules.events=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/events.lua
  wowless.modules.fontinstance=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/fontinstance.lua
  wowless.modules.funcheck=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/funcheck.lua
  wowless.modules.funtainer=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/funtainer.lua
  wowless.modules.gencode=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/gencode.lua
  wowless.modules.loader=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/loader.lua
  wowless.modules.luaobjects=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/luaobjects.lua
  wowless.modules.macrotext=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/macrotext.lua
  wowless.modules.mainloop=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/mainloop.lua
  wowless.modules.parentkey=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/parentkey.lua
  wowless.modules.platform=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/platform.lua
  wowless.modules.points=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/points.lua
  wowless.modules.region=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/region.lua
  wowless.modules.scripts=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/scripts.lua
  wowless.modules.security=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/security.lua
  wowless.modules.sqlitedb=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/sqlitedb.lua
  wowless.modules.sqls=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/sqls.lua
  wowless.modules.statusbar=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/statusbar.lua
  wowless.modules.system=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/system.lua
  wowless.modules.talents=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/talents.lua
  wowless.modules.templates=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/templates.lua
  wowless.modules.time=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/time.lua
  wowless.modules.typecheck=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/typecheck.lua
  wowless.modules.uiobjectloader=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/uiobjectloader.lua
  wowless.modules.uiobjects=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/uiobjects.lua
  wowless.modules.uiobjecttypes=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/uiobjecttypes.lua
  wowless.modules.units=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/units.lua
  wowless.modules.visibility=${CMAKE_CURRENT_SOURCE_DIR}/wowless/modules/visibility.lua
  wowless.profiler=${CMAKE_CURRENT_SOURCE_DIR}/wowless/profiler.lua
  wowless.runner=${CMAKE_CURRENT_SOURCE_DIR}/wowless/runner.lua
  wowless.xml=${CMAKE_CURRENT_SOURCE_DIR}/wowless/xml.lua)
target_sources(wowlesslib PRIVATE wowless/bubblewrap.c wowless/ext.c
                                  wowless/luaobject.c)

add_lua_executable(
  wowless
  ${CMAKE_CURRENT_SOURCE_DIR}/wowless.lua
  argparse
  ${dataluas}
  date
  luaexpat
  minheap
  penlight
  runtimegametypes
  runtimeproducts
  tsort
  wowlesslib
  wowlessrender
  wowlesssqlite
  wowlesstoc
  wowlessutil
  wowlessyaml)

# Wowless runs are resource intensive.
set_property(GLOBAL PROPERTY JOB_POOLS wowless_run=5)

set(outdeps)
set(outs)
set(pngs)
foreach(product ${products})
  set(out products/${product}/log.txt)
  list(APPEND outs ${out})
  list(APPEND outdeps stamp_${product}_dbdefs stamp_${product}_dblist)
  add_custom_target(
    ${product} DEPENDS wowless testaddon.txt ${product}_addon.txt
                       ${product}_data.sqlite3)
  add_dependencies(${product} stamp_${product}_dbdefs stamp_${product}_dblist)
  add_custom_command(
    OUTPUT ${out}
    COMMAND
      wowless run -p ${product} -e5 -a ${CMAKE_CURRENT_BINARY_DIR}/addon/Wowless
      -a ${CMAKE_CURRENT_BINARY_DIR}/products/${product}/WowlessData -o
      ${CMAKE_CURRENT_BINARY_DIR}/${out}
    JOB_POOL wowless_run
    DEPENDS wowless testaddon.txt ${product}_addon.txt ${product}_data.sqlite3
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  add_custom_command(
    OUTPUT products/${product}/frame0.yaml products/${product}/frame1.yaml
    COMMAND wowless run -p ${product} -e0 -o
            ${CMAKE_CURRENT_BINARY_DIR}/products/${product}/frame0.txt --frame0
    JOB_POOL wowless_run
    DEPENDS wowless ${product}_data.sqlite3
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  add_custom_command(
    OUTPUT products/${product}/frame0.png
    COMMAND render products/${product}/frame0.yaml
    DEPENDS render products/${product}/frame0.yaml
            runtime/products/${product}/build.lua)
  add_custom_command(
    OUTPUT products/${product}/frame1.png
    COMMAND render products/${product}/frame1.yaml
    DEPENDS render products/${product}/frame1.yaml
            runtime/products/${product}/build.lua)
  list(APPEND pngs products/${product}/frame0.png
       products/${product}/frame1.png)
endforeach()
add_custom_target(outs DEPENDS ${outs})
add_dependencies(outs ${outdeps})
add_custom_target(pngs DEPENDS ${pngs})
add_dependencies(pngs ${outdeps})

add_lua_executable(
  runtests
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/runtests.lua
  argparse
  ${dataluas}
  date
  luaexpat
  luassert
  minheap
  penlight
  runtimegametypes
  runtimeproducts
  toolstedit
  tsort
  wowapischema
  wowlessblp
  wowlesslib
  wowlessrender
  wowlesssqlite
  wowlesstoc
  wowlessutil
  wowlessyaml)

set(d ${CMAKE_CURRENT_BINARY_DIR}/addon/Wowless)
file(MAKE_DIRECTORY ${d} ${CMAKE_CURRENT_BINARY_DIR}/staging/addon/Wowless)
set(testaddon_outs)
foreach(
  f
  arraydiff.lua
  evenmoreintrinsic.xml
  framework.lua
  funtainer.lua
  generated.lua
  init.lua
  luaobjects.lua
  statemachine.lua
  test.lua
  uiobjects.lua
  util.lua
  Wowless.toc)
  set(out ${d}/${f})
  list(APPEND testaddon_outs ${out})
  add_custom_command(
    OUTPUT ${out}
    COMMAND
      ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/addon/Wowless/${f}
      -DDST_DIR=${d} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/copy_executable.cmake
    DEPENDS addon/Wowless/${f})
endforeach()
set(out ${d}/test.xml)
set(staging ${CMAKE_CURRENT_BINARY_DIR}/staging/addon/Wowless/test.xml)
list(APPEND testaddon_outs ${out})
add_custom_command(
  OUTPUT ${out}
  COMMAND
    ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/addon/Wowless/test.xml
    -DDST=${staging} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/preprocess_line.cmake
  COMMAND ${CMAKE_COMMAND} -DSRC=${staging} -DDST_DIR=${d} -P
          ${CMAKE_CURRENT_SOURCE_DIR}/cmake/copy_executable.cmake
  DEPENDS addon/Wowless/test.xml cmake/preprocess_line.cmake)
add_custom_command(
  OUTPUT testaddon.txt
  COMMAND ${CMAKE_COMMAND} -E touch testaddon.txt
  DEPENDS ${testaddon_outs})

set(specs
    spec/addon/arraydiff_spec.lua
    spec/addon/framework_spec.lua
    spec/addon/statemachine_spec.lua
    spec/addon/util_spec.lua
    spec/data/apis_spec.lua
    spec/data/config_spec.lua
    spec/data/docs_spec.lua
    spec/data/events_spec.lua
    spec/data/families_spec.lua
    spec/data/gametypes_spec.lua
    spec/data/globals_spec.lua
    spec/data/impl_spec.lua
    spec/data/sql_spec.lua
    spec/data/structures_spec.lua
    spec/data/test_spec.lua
    spec/data/scripttypes_spec.lua
    spec/data/uiobjectimpl_spec.lua
    spec/data/uiobjects_spec.lua
    spec/data/xml_spec.lua
    spec/data/yaml_spec.lua
    spec/elune_spec.lua
    spec/tools/tedit_spec.lua
    spec/wowapi/schema_spec.lua
    spec/wowapi/yaml_spec.lua
    spec/wowless/addon_spec.lua
    spec/wowless/blp_spec.lua
    spec/wowless/bubblewrap_spec.lua
    spec/wowless/hlist_spec.lua
    spec/wowless/modules/funcheck_spec.lua
    spec/wowless/modules/typecheck_spec.lua
    spec/wowless/sqlite_spec.lua
    spec/wowless/toc_spec.lua
    spec/wowless/util_spec.lua)
add_custom_command(
  COMMENT "Running tests"
  OUTPUT test.out
  COMMAND runtests -o ${CMAKE_CURRENT_BINARY_DIR}/test.out ${specs}
  DEPENDS runtests addons.txt ${schemadbs} ${specs} spec/wowless/temp.blp
          testaddon.txt
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_target(test DEPENDS test.out)

add_lua_executable(yamlfmt ${CMAKE_CURRENT_SOURCE_DIR}/tools/yamlfmt.lua
                   penlight wowlessyaml)

find_package(SDL3 CONFIG REQUIRED)
find_package(SDL3_image CONFIG REQUIRED)
lua2c(toolssdl tools.sdl=c)
target_sources(toolssdl PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/tools/sdl.c)
target_link_libraries(
  toolssdl
  PRIVATE
    SDL3::SDL3
    $<IF:$<TARGET_EXISTS:SDL3_image::SDL3_image-shared>,SDL3_image::SDL3_image-shared,SDL3_image::SDL3_image-static>
)
add_lua_executable(
  render
  ${CMAKE_CURRENT_SOURCE_DIR}/tools/sdlrender.lua
  argparse
  penlight
  toolssdl
  toolstactless
  wowlessblp
  wowlessutil
  wowlessyaml)

add_custom_target(
  bump-dbdefs
  COMMAND ${GIT_EXECUTABLE} -C vendor/dbdefs checkout master
  COMMAND ${GIT_EXECUTABLE} -C vendor/dbdefs pull
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_lua_executable(warnings ${CMAKE_CURRENT_SOURCE_DIR}/tools/warnings.lua
                   wowlessyaml)
