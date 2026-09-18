# elune_target_copy_file(<target> SOURCE <file> [OUTPUT <file>])
#
# Copies the named SOURCE file to the build directory (or OUTPUT) when the
# named <target> is built.
function(elune_target_copy_file TARGET)
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "SOURCE;OUTPUT" "")

  if(NOT TARGET)
    message(FATAL_ERROR "Missing required argument 'TARGET' in call to elune_target_copy_file")
  elseif(NOT ARG_SOURCE)
    message(FATAL_ERROR "Missing required argument 'SOURCE' in call to elune_target_copy_file")
  endif()

  if(NOT ARG_OUTPUT)
    set(ARG_OUTPUT ${ARG_SOURCE})
  endif()

  get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  get_property(RUNTIME_OUTPUT_DIRECTORY TARGET ${TARGET} PROPERTY RUNTIME_OUTPUT_DIRECTORY)

  cmake_path(ABSOLUTE_PATH ARG_SOURCE BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" NORMALIZE)
  cmake_path(ABSOLUTE_PATH ARG_OUTPUT BASE_DIRECTORY "${RUNTIME_OUTPUT_DIRECTORY}/$<$<BOOL:${GENERATOR_IS_MULTI_CONFIG}>:$<CONFIG>/>" NORMALIZE)

  add_custom_command(
    OUTPUT ${ARG_OUTPUT}
    DEPENDS ${ARG_SOURCE}
    COMMAND ${CMAKE_COMMAND} -E copy ${ARG_SOURCE} ${ARG_OUTPUT}
    VERBATIM
  )

  set_source_files_properties(
    ${ARG_SOURCE}
    PROPERTIES
      HEADER_FILE_ONLY ON
  )

  target_sources(
    ${TARGET}
    PRIVATE
      ${ARG_SOURCE}
      ${ARG_OUTPUT}
  )
endfunction()
