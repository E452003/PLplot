# tcl/bp.cmake
# CMakeLists.txt file to configure the build of tcl.

# Copyright (C) 2013 Alan W. Irwin

# This file is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.

# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this file; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

# The top-level CMakeLists.txt file that includes this file should
# have run "include(ExternalProject)" and set EP_BASE variable (and
# corresponding directory property) as well as various BP variables
# used below that configure how the External_Project functions
# operate.

# These build configuration details for Tcl adapted from information in
# <http://www.linuxfromscratch.org/blfs/view/svn/general/tcl.html>.

# Protect against configuring a build twice in one CMake call
if(tcl_configured)
  return()
endif(tcl_configured)
set(tcl_configured ON)

# List of dependencies (most of which are build tools) which should be
# ignored.
set(BP_ignored_dependencies_LIST ${extra_ignored_dependencies_list})

set(tcl_dependencies_LIST)
# Remove dependencies that should be ignored.
if(tcl_dependencies_LIST)
  list(REMOVE_ITEM tcl_dependencies_LIST ${BP_ignored_dependencies_LIST})
endif(tcl_dependencies_LIST)

set(tcl_dependencies_targets)
foreach(build_configuration ${tcl_dependencies_LIST})
  if(EXISTS ${CMAKE_SOURCE_DIR}/${build_configuration}/bp.cmake)
    include(${build_configuration}/bp.cmake)
    list(APPEND tcl_dependencies_targets build_${build_configuration})
  else(EXISTS ${CMAKE_SOURCE_DIR}/${build_configuration}/bp.cmake)
    message(STATUS "Warning: A build_configuration for ${build_configuration} does not exist so it is assumed this dependency of tcl has been installed another way.")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/${build_configuration}/bp.cmake)
endforeach(build_configuration ${tcl_dependences_LIST})

# This can be safely done only after above includes.
set(BP_PACKAGE tcl)

# Data that is related to downloads.
set(${BP_PACKAGE}_URL  http://downloads.sourceforge.net/tcl/tcl8.6.1-src.tar.gz)
set(${BP_PACKAGE}_DOWNLOAD_HASH_TYPE MD5)
set(${BP_PACKAGE}_DOWNLOAD_HASH aae4b701ee527c6e4e1a6f9c7399882e)

# Data that is related to the PATH that must be used.
# N.B. note below that we always use the unix subdirectory of the
# source tree to find the configure script.  Note, there is a macosx
# and win subdirectory there as well that contain configure scripts
# with additional options for those platforms, but for now the unix
# version of configure may be good enough for our needs for all
# platforms.
if(MSYS_PLATFORM)
  #set(BP_PATH_NODLL "${BP_PATH}")
  #set(BP_PATH "${EP_BASE}/Build/build_${BP_PACKAGE}/dll;${BP_PATH_NODLL}")
  determine_msys_path(BP_PATH "${BP_PATH}")
  # Must have all elements of env command in MSYS platform form
  determine_msys_path(source_PATH "${EP_BASE}/Source/build_${BP_PACKAGE}/unix")
  set(${BP_PACKAGE}_SET_CFLAGS "CFLAGS=$ENV{CFLAGS}")
else(MSYS_PLATFORM)
  set(source_PATH "${EP_BASE}/Source/build_${BP_PACKAGE}/unix")
  set(${BP_PACKAGE}_SET_CFLAGS "CFLAGS=$ENV{CFLAGS}")
endif(MSYS_PLATFORM)
#message(STATUS "modified BP_PATH for ${BP_PACKAGE} = ${BP_PATH}")

if(BP_HAVE_64_BIT_OS)
  set(TCL_ENABLE_64_BIT --enable-64bit)
endif(BP_HAVE_64_BIT_OS)

ExternalProject_Add(
  build_${BP_PACKAGE}
  DEPENDS ${${BP_PACKAGE}_dependencies_targets}
  URL ${${BP_PACKAGE}_URL}
  URL_HASH ${${BP_PACKAGE}_DOWNLOAD_HASH_TYPE}=${${BP_PACKAGE}_DOWNLOAD_HASH}
  CONFIGURE_COMMAND ${ENV_EXECUTABLE} PATH=${BP_PATH} ${${BP_PACKAGE}_SET_CFLAGS} ${source_PATH}/${BP_CONFIGURE_COMMAND} --mandir=${BP_CMAKE_INSTALL_PREFIX}/share/man ${TCL_ENABLE_64_BIT}
  BUILD_COMMAND ${ENV_EXECUTABLE} PATH=${BP_PATH} ${BP_PARALLEL_MAKE_COMMAND}
  INSTALL_COMMAND ${ENV_EXECUTABLE} PATH=${BP_PATH} ${BP_PARALLEL_MAKE_COMMAND} install
  )

add_custom_command(
  OUTPUT
  ${EP_BASE}/Stamp/build_${BP_PACKAGE}/build_${BP_PACKAGE}-build
  COMMAND echo "Replace build-tree locations by install-tree locations"
  COMMAND ${SED_EXECUTABLE}
  -e "s@^\\(TCL_SRC_DIR='\\).*@\\1${BP_CMAKE_INSTALL_PREFIX}/include'@"
  -e "/TCL_B/s@='\\(-L\\)\\?.*build_tcl@='\\1${BP_CMAKE_INSTALL_PREFIX}/lib@"
  -i tclConfig.sh
  APPEND
  )

add_custom_command(
  OUTPUT
  ${EP_BASE}/Stamp/build_${BP_PACKAGE}/build_${BP_PACKAGE}-install
  COMMAND echo "Install-tree fixups"
  COMMAND ${ENV_EXECUTABLE} PATH=${BP_PATH} ${BP_PARALLEL_MAKE_COMMAND} install-private-headers
  COMMAND ${LN_EXECUTABLE} -v -sf tclsh8.6 ${BP_CMAKE_INSTALL_PREFIX}/bin/tclsh
  COMMAND ${CHMOD_EXECUTABLE} -v ${SO_NUMERICAL_PERMISSIONS} ${BP_CMAKE_INSTALL_PREFIX}/lib/libtcl8.6.so
  APPEND
  )

list(APPEND build_target_LIST build_${BP_PACKAGE})
# Restore BP_PATH to original state.
set(BP_PATH "${BP_ORIGINAL_NATIVE_PATH}")
#message(STATUS "${BP_PACKAGE} restored original BP_PATH = ${BP_PATH}")