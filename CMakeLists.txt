cmake_minimum_required(VERSION 2.8)
project(secret-archer)
# TODO: look for doxygen.

cmake_policy(SET CMP0012 NEW)

#OS detection.
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(LINUX 1)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(WINDOWS 1)
else()
  message(FATAL_ERROR "OS is not supported. Cannot continue.")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

set(BUILD_SFML_DOC 1 CACHE BOOL "True if you want to build the SFML documentation. ON by default.")
set(BUILD_SFML_DEBUG_LIBS 1 CACHE BOOL "True if you want to build debug variants of the SFML libs, too. Release libraries are always built.")
set(NUM_CORES 4 CACHE INTEGER "Number of cores on your machine.")

set(SFML_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/SFML" CACHE STRING "Directory to which SFML will be installed.")
set(THOR_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/Thor" CACHE STRING "Directory to which Thor will be installed.")
set(SFGUI_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/SFGUI" CACHE STRING "Directory to which SFGUI will be installed.")

message(WARNING "Please set NUM_CORES according to your needs. NUM_CORES is 4 by default.")
#OS-specific variables.
if(LINUX)
  set(_TMPDIR "/tmp")
  set(_SFML_MAKEFILE_GENERATOR "Unix Makefiles")
elseif(WINDOWS)
  set(_TMPDIR "C:/Windows/Temp")
  set(_SFML_MAKEFILE_GENERATOR "MSYS Makefiles")
endif()

# Cache all variables that will be needed during build.
set(TMPDIR ${_TMPDIR} CACHE PATH "Folder for temporary files")
set(SFML_MAKEFILE_GENERATOR ${_SFML_MAKEFILE_GENERATOR} CACHE STRING "Makefile generator for building SFML.")

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
  COMMAND ${CMAKE_COMMAND} -DTMPDIR=${TMPDIR} -DSFML_MAKEFILE_GENERATOR=${SFML_MAKEFILE_GENERATOR} -DBUILD_SFML_DOC=${BUILD_SFML_DOC} -DBUILD_SFML_DEBUG_LIBS=${BUILD_SFML_DEBUG_LIBS} -DNUM_CORES=${NUM_CORES} -DSFML_INSTALL_PREFIX=${SFML_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/installSFML.cmake
  COMMENT "Installing SFML"
)

add_custom_target(installThor
  COMMAND ${CMAKE_COMMAND} -DTMPDIR=${TMPDIR} -DSFML_MAKEFILE_GENERATOR=${SFML_MAKEFILE_GENERATOR} -DBUILD_SFML_DOC=${BUILD_SFML_DOC} -DBUILD_SFML_DEBUG_LIBS=${BUILD_SFML_DEBUG_LIBS} -DNUM_CORES=${NUM_CORES} -DSFML_INSTALL_PREFIX=${SFML_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH} -DTHOR_INSTALL_PREFIX=${THOR_INSTALL_PREFIX} -DWINDOWS=${WINDOWS} -DLINUX=${LINUX} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/installThor.cmake 
  COMMENT "Installing Thor"
)

add_custom_target(installSFGUI
  COMMAND ${CMAKE_COMMAND} -DTMPDIR=${TMPDIR} -DSFML_MAKEFILE_GENERATOR=${SFML_MAKEFILE_GENERATOR} -DBUILD_SFML_DOC=${BUILD_SFML_DOC} -DBUILD_SFML_DEBUG_LIBS=${BUILD_SFML_DEBUG_LIBS} -DNUM_CORES=${NUM_CORES} -DSFML_INSTALL_PREFIX=${SFML_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH} -DSFGUI_INSTALL_PREFIX=${SFGUI_INSTALL_PREFIX} -DWINDOWS=${WINDOWS} -DLINUX=${LINUX} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake/installSFGUI.cmake
  COMMENT "Installing SFGUI"
)

add_custom_target(installDependencies
                  DEPENDS installSFML installThor installSFGUI)

set(SFML_ROOT ${SFML_INSTALL_PREFIX})
set(CMAKE_PREFIX_PATH ${SFML_INSTALL_PREFIX})

# Finding SFML must not abort cmake-configuration: Configuration is necessary to run `make installDependencies`.
set(SFML_FIND_QUIETLY TRUE) 
find_package(SFML 2 COMPONENTS system)

if(NOT SFML_FOUND)
  message(WARNING "No SFML found. Run: `make installDependencies` and reconfigure the project afterwards.")
else()
  add_subdirectory(src)
endif()
