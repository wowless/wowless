include(elune-fetch-acutest)

add_executable(luatest)
add_executable(elune::luatest ALIAS luatest)
elune_configure_target(luatest)

target_link_libraries(
  luatest
  PRIVATE
    elune::liblua
    # TODO: Bump CMake requirement to 3.26 and change this to BUILD_LOCAL_INTERFACE.
    $<BUILD_INTERFACE:mity::acutest>
)

target_sources(
  luatest
  PRIVATE
    luatest.c
)

elune_target_copy_file(
  luatest
  SOURCE luatest_scriptcases.lua
  OUTPUT luatest_scriptcases.lua
)

elune_target_copy_file(
  luatest
  SOURCE luatest_coroutine.lua
  OUTPUT luatest_coroutine.lua
)

elune_target_copy_file(
  luatest
  SOURCE luatest_profiling.lua
  OUTPUT luatest_profiling.lua
)

if(BUILD_CXX)
  get_property(_luatest_sources TARGET luatest PROPERTY SOURCES)
  list(FILTER _luatest_sources INCLUDE REGEX "\\.c$")
  set_source_files_properties(${_luatest_sources} TARGET_DIRECTORY luatest PROPERTIES LANGUAGE CXX)
endif()
