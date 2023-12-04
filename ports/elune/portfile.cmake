vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO meorawr/elune
  REF 7fc7271922fbc0a371ef15d699ffa0b2be649a81
  SHA512 3dade88ec43955ec0be1901d39f41b7f7e65aecc5e654c0efab97cdd3503a75ebece8f7d5eef3ab687d3bb319c71260a25dbca87079f3694ae50339f1a6e514e
  HEAD_REF main
)
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTING=OFF
    -DCMAKE_C_FLAGS=-D_GNU_SOURCE
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}" "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
