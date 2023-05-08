cmake_minimum_required(VERSION 3.24)
project(wowless)

include(ExternalProject)
ExternalProject_Add(
  elune
  GIT_REPOSITORY https://github.com/meorawr/elune
  GIT_TAG f051f75a3e963130c2d1ad98f56868bfc6b2798d
  GIT_SHALLOW 1
  UPDATE_DISCONNECTED 1
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND cmake --preset linux -DLUA_ROOT=build/rocks
  BUILD_COMMAND cmake --build --preset linux
  INSTALL_COMMAND cmake --install build/linux --prefix ${CMAKE_BINARY_DIR}/elune
)

ExternalProject_Add(
  luarocks
  URL https://luarocks.org/releases/luarocks-3.9.2.tar.gz
  URL_HASH SHA1=116a4ce0bfe945045d9e6b28dedc270b2d7a3ebd
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ./configure --with-lua=${CMAKE_BINARY_DIR}/elune --prefix=${CMAKE_BINARY_DIR}/luarocks
  BUILD_COMMAND make
  INSTALL_COMMAND make install
)
add_dependencies(luarocks elune)

add_library(ext MODULE wowless/ext.c)
add_dependencies(ext elune)
set_target_properties(ext PROPERTIES PREFIX "")
target_include_directories(ext PRIVATE ${CMAKE_BINARY_DIR}/elune/include/lua5.1)

ExternalProject_Add(
  sqlite3
  URL https://www.sqlite.org/2023/sqlite-autoconf-3410200.tar.gz
  URL_HASH SHA3_256=1ebb5539dd6fde9a0f89e8ab765af0b9f02010fc6baf6985b54781a38c00020a
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_BINARY_DIR}/sqlite3
  BUILD_COMMAND make
  INSTALL_COMMAND make install
)

ExternalProject_Add(
  expat
  URL https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz
  URL_HASH SHA1=061c1232188dff35e44aa7137aec7757d3d90d27
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND autoreconf && ./configure --prefix=${CMAKE_BINARY_DIR}/expat
  BUILD_COMMAND make
  INSTALL_COMMAND make install
)
