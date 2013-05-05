cmake_minimum_required(VERSION 2.8)
project(secret-archer)
# TODO: look for doxygen.

set(BUILD_SFML_DOC 1 CACHE BOOL "True if you want to build the SFML documentation. ON by default.")
set(BUILD_SFML_DEBUG_LIBS 1 CACHE BOOL "True if you want to build debug variants of the SFML libs, too. Release libraries are always built.")
set(NUM_CORES 4 CACHE INTEGER "Number of cores on your machine.")
set(SFML_INSTALL_PREFIX "C:/SFML" CACHE STRING "Directory to which SFML will be installed.")

#OS detection.
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(LINUX 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(WINDOWS 1)
else()

endif()

# Check whether the OS is supported
if(NOT LINUX AND NOT WINDOWS)
  message(FATAL_ERROR "OS is not supported. Cannot continue.")
endif()

message(WARNING "Please set NUM_CORES according to your needs. NUM_CORES is 4 by default.")
#OS-specific variables.
if(LINUX)
  set(_TMPDIR "/tmp")
  set(_SFML_MAKEFILE_GENERATOR "Unix Makefiles")
  if(NOT DEFINED NEED_SUDO)
    message(WARNING "You appear to be running a Linux-system. Please set NEED_SUDO according to your needs. NEED_SUDO is false by default.")
  endif()
elseif(WINDOWS)
  set(_TMPDIR "C:/Windows/Temp")
  set(_SFML_MAKEFILE_GENERATOR "MSYS Makefiles")
endif()

# Cache all variables that will be needed during build.
set(TMPDIR ${_TMPDIR} CACHE PATH "Folder for temporary files")
set(SFML_MAKEFILE_GENERATOR ${_SFML_MAKEFILE_GENERATOR} CACHE STRING "Makefile generator for building SFML.")
if(NOT DEFINED NEED_SUDO)
  set(NEED_SUDO 0 CACHE BOOL "True if `sudo` grants administrative priviledges on your system.")
endif()

# Create tmpdir if is doesn't exist. Abort when it is a file.
if(NOT IS_DIRECTORY ${TMPDIR})
  if(EXISTS ${TMPDIR})
    message(FATAL_ERROR "tmpdir ${TMPDIR} exists and is not a directory. Cannot continue.")
  elseif()
    file(MAKE_DIRECTORY ${TMPDIR})
    message(STATUS "Creating temporary directory ${TMPDIR}.")
  endif()
endif()

# The parameter passing here is an ugly hack :(
add_custom_target(installSFML
  COMMAND ${CMAKE_COMMAND} -DTMPDIR=${TMPDIR} -DSFML_MAKEFILE_GENERATOR=${SFML_MAKEFILE_GENERATOR} -DBUILD_SFML_DOC=${BUILD_SFML_DOC} -DBUILD_SFML_DEBUG_LIBS=${BUILD_SFML_DEBUG_LIBS} -DNEED_SUDO=${NEED_SUDO} -DNUM_CORES=${NUM_CORES} -DSFML_INSTALL_PREFIX=${SFML_INSTALL_PREFIX} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/installSFML.cmake
  COMMENT "Installing SFML"
)
