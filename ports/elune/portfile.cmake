vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO meorawr/elune
  REF f3c72f0670fd32dd4938a1d68616b8f4e9f6b66d
  SHA512 5e7ced7527eaa31e001dee07b62fa81fc4971a3e4ee93353e094ff87a7e991548170159c8f38d25b0bf3781f9bd405be03c3dcf3427df874a672b7b92b459306
  HEAD_REF main
)
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTING=OFF
    -DLUA_USE_READLINE=OFF
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}" "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
