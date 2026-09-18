include(FindPackageHandleStandardArgs)

find_path(
  readline_INCLUDE_DIR
  NAMES "readline/readline.h"
  HINTS ${readline_ROOT}
)

find_library(
  readline_LIBRARY
  NAMES readline
  HINTS ${readline_ROOT}
  PATH_SUFFIXES ${CMAKE_INSTALL_LIBDIR}
)

find_package_handle_standard_args(
  readline
  REQUIRED_VARS
    readline_LIBRARY
    readline_INCLUDE_DIR
)

mark_as_advanced(readline_FOUND)
mark_as_advanced(readline_LIBRARY)
mark_as_advanced(readline_INCLUDE_DIR)

if(readline_FOUND AND NOT TARGET readline::readline)
  add_library(readline::readline UNKNOWN IMPORTED)
  set_target_properties(
    readline::readline
    PROPERTIES
      IMPORTED_LOCATION "${readline_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${readline_INCLUDE_DIR}"
  )
endif()

set(readline_INCLUDE_DIRS "${readline_INCLUDE_DIR}")
set(readline_LIBRARIES "${readline_LIBRARY}")
