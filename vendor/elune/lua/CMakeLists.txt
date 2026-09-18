add_executable(lua)
add_executable(elune::lua ALIAS lua)
elune_configure_target(lua)

set_target_properties(
  lua
  PROPERTIES
    OUTPUT_NAME ${LUA_OUTPUT_NAME}
)

target_compile_definitions(
  lua
  PRIVATE
    $<$<NOT:$<PLATFORM_ID:Windows>>:_GNU_SOURCE>
)

target_link_libraries(
  lua
  PRIVATE
    elune::liblua
)

target_sources(
  lua
  PRIVATE
    lua.c
)

if(BUILD_CXX)
  get_property(_lua_sources TARGET lua PROPERTY SOURCES)
  list(FILTER _lua_sources INCLUDE REGEX "\\.c$")
  set_source_files_properties(${_lua_sources} TARGET_DIRECTORY lua PROPERTIES LANGUAGE CXX)
endif()

if(BUILD_INSTALL)
  install(
    TARGETS lua
    EXPORT elune-lua-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
  )

  install(
    EXPORT elune-lua-targets
    FILE elune-lua-targets.cmake
    NAMESPACE elune::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/elune"
    COMPONENT Development
  )
endif()
