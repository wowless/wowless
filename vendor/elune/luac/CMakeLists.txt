add_executable(luac)
add_executable(elune::luac ALIAS luac)
elune_configure_target(luac)

set_target_properties(
  luac
  PROPERTIES
    OUTPUT_NAME ${LUAC_OUTPUT_NAME}
)

target_include_directories(
  luac
  PRIVATE
    $<TARGET_GENEX_EVAL:liblua,$<TARGET_PROPERTY:liblua,INCLUDE_DIRECTORIES>>
)

target_link_libraries(
  luac
  PRIVATE
    $<TARGET_GENEX_EVAL:liblua,$<TARGET_PROPERTY:liblua,LINK_LIBRARIES>>
    $<TARGET_OBJECTS:liblua>
)

target_sources(
  luac
  PRIVATE
    luac.c
)

if(BUILD_CXX)
  get_property(_luac_sources TARGET luac PROPERTY SOURCES)
  list(FILTER _luac_sources INCLUDE REGEX "\\.c$")
  set_source_files_properties(${_luac_sources} TARGET_DIRECTORY luac PROPERTIES LANGUAGE CXX)
endif()

if(BUILD_INSTALL)
  install(
    TARGETS luac
    EXPORT elune-luac-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
  )

  install(
    EXPORT elune-luac-targets
    FILE elune-luac-targets.cmake
    NAMESPACE elune::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/elune"
    COMPONENT Development
  )
endif()
