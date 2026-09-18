include(FindPackageHandleStandardArgs)

find_path(
  acutest_INCLUDE_DIR
  NAMES "acutest.h"
  PATH_SUFFIXES "acutest"
  HINTS ${acutest_ROOT}
)

find_package_handle_standard_args(
  acutest
  REQUIRED_VARS
    acutest_INCLUDE_DIR
)

mark_as_advanced(acutest_FOUND)
mark_as_advanced(acutest_INCLUDE_DIR)

if(acutest_FOUND AND NOT TARGET mity::acutest)
  add_library(mity::acutest INTERFACE IMPORTED)
  set_target_properties(
    mity::acutest
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${acutest_INCLUDE_DIR}"
  )
endif()

set(acutest_INCLUDE_DIRS "${acutest_INCLUDE_DIR}")
