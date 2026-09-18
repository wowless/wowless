add_library(liblua-headers INTERFACE)
add_library(elune::liblua-headers ALIAS liblua-headers)

target_include_directories(
  liblua-headers
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_sources(
  liblua-headers
  PUBLIC
    FILE_SET HEADERS
    BASE_DIRS
      ${CMAKE_CURRENT_BINARY_DIR}/include
      ${CMAKE_CURRENT_SOURCE_DIR}/include
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/include/luaconf.h
      ${CMAKE_CURRENT_SOURCE_DIR}/include/lauxlib.h
      ${CMAKE_CURRENT_SOURCE_DIR}/include/lua.h
      ${CMAKE_CURRENT_SOURCE_DIR}/include/lua.hpp
      ${CMAKE_CURRENT_SOURCE_DIR}/include/lualib.h
)

add_library(liblua)
add_library(elune::liblua ALIAS liblua)
elune_configure_target(liblua)

set_target_properties(
  liblua
  PROPERTIES
    DEFINE_SYMBOL "LUA_BUILD_EXPORT"
    OUTPUT_NAME ${LIBLUA_OUTPUT_NAME}
)

target_compile_definitions(
  liblua
  PRIVATE
    $<$<NOT:$<PLATFORM_ID:Windows>>:_GNU_SOURCE>
    $<$<IN_LIST:$<CONFIG>,${LUA_ASSERT_CONFIGS}>:LUA_USE_ASSERT>
    $<$<IN_LIST:$<CONFIG>,${LUA_APICHECK_CONFIGS}>:LUA_USE_APICHECK>
)

target_include_directories(
  liblua
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(
  liblua
  PUBLIC
    elune::liblua-headers
  PRIVATE
    # TODO: Bump CMake requirement to 3.26 and change this to BUILD_LOCAL_INTERFACE.
    $<BUILD_INTERFACE:sheredom::utf8h>
    $<$<PLATFORM_ID:Darwin,Linux>:m>
    $<$<PLATFORM_ID:Windows>:bcrypt>
    $<$<BOOL:${LUA_USE_POSIX}>:${CMAKE_DL_LIBS}>
    $<$<BOOL:${LUA_USE_READLINE}>:readline::readline>
)

target_sources(
  liblua
  PRIVATE
    # Core sources
    lapi.c            lapi.h
    lcode.c           lcode.h
    ldebug.c          ldebug.h
    ldo.c             ldo.h
    ldump.c
    lfunc.c           lfunc.h
    lgc.c             lgc.h
    llex.c            llex.h
                      llimits.h
    lmanip.c          lmanip.h
    lmem.c            lmem.h
    lobject.c         lobject.h
    lopcodes.c        lopcodes.h
    lparser.c         lparser.h
    lsec.c            lsec.h
    lstate.c          lstate.h
    lstring.c         lstring.h
    ltable.c          ltable.h
    ltm.c             ltm.h
    lundump.c         lundump.h
    lvm.c             lvm.h
    lzio.c            lzio.h

    # Library sources
    lauxlib.c
    lbaselib.c
    lbitlib.c
    lcompatlib.c
    lcorolib.c
    ldblib.c
    liolib.c
    lmathlib.c
    loadlib.c
    loslib.c
    lreadline.c       lreadline.h
    lseclib.c
    lstatslib.c
    lstrlib.c
    ltablib.c
    linit.c
)

if(BUILD_CXX)
  get_property(_liblua_sources TARGET liblua PROPERTY SOURCES)
  list(FILTER _liblua_sources INCLUDE REGEX "\\.c$")
  set_source_files_properties(${_liblua_sources} TARGET_DIRECTORY liblua PROPERTIES LANGUAGE CXX)
endif()

if(BUILD_INSTALL)
  install(
    TARGETS liblua liblua-headers
    EXPORT elune-liblua-targets
    RUNTIME
      DESTINATION ${CMAKE_INSTALL_BINDIR}
      COMPONENT Runtime
    LIBRARY
      DESTINATION ${CMAKE_INSTALL_LIBDIR}
      COMPONENT Runtime
    ARCHIVE
      DESTINATION ${CMAKE_INSTALL_LIBDIR}
      COMPONENT Development
    FILE_SET HEADERS
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
      COMPONENT Development
  )

  install(
    EXPORT elune-liblua-targets
    FILE elune-liblua-targets.cmake
    NAMESPACE elune::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/elune"
    COMPONENT Development
  )
endif()
