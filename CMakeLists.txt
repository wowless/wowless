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
  CONFIGURE_COMMAND cmake --preset linux
  BUILD_COMMAND cmake --build --preset linux --target install
  INSTALL_COMMAND true
)

ExternalProject_Add(
  luarocks
  URL https://luarocks.org/releases/luarocks-3.9.2.tar.gz
  URL_HASH SHA1=116a4ce0bfe945045d9e6b28dedc270b2d7a3ebd
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ./configure --with-lua=../../../elune-prefix/src/elune/build/linux/install --prefix=../../../../luarocks
  BUILD_COMMAND make
  INSTALL_COMMAND make install
)
add_dependencies(luarocks elune)

add_library(ext MODULE wowless/ext.c)
add_dependencies(ext elune)
set_target_properties(ext PROPERTIES PREFIX "")
target_include_directories(ext PRIVATE build/cmake/elune-prefix/src/elune/build/linux/install/include/lua5.1)
