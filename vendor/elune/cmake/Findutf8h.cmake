include(FindPackageHandleStandardArgs)

find_path(
  utf8h_INCLUDE_DIR
  NAMES "utf8.h"
  PATH_SUFFIXES "utf8h"
  HINTS ${utf8h_ROOT}
)

find_package_handle_standard_args(
  utf8h
  REQUIRED_VARS
    utf8h_INCLUDE_DIR
)

mark_as_advanced(utf8h_FOUND)
mark_as_advanced(utf8h_INCLUDE_DIR)

if(utf8h_FOUND AND NOT TARGET sheredom::utf8h)
  add_library(sheredom::utf8h INTERFACE IMPORTED)
  set_target_properties(
    sheredom::utf8h
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${utf8h_INCLUDE_DIR}"
  )
endif()

set(utf8h_INCLUDE_DIRS "${utf8h_INCLUDE_DIR}")
