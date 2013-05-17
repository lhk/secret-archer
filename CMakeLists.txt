cmake_minimum_required(VERSION 2.8)
project(secret-archer)
# TODO: look for doxygen.

cmake_policy(SET CMP0012 NEW)

include(ExternalProject)

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
  # User wants Unix-libraries.
  # If he has MinGW, just MINGW will be defined.
  # If he has MSYS, both MINGW and MSYS will be defined.  
  if(MINGW)
    set(_SFML_MAKEFILE_GENERATOR "MinGW Makefiles")
    if(MSYS)
      set(_SFML_MAKEFILE_GENERATOR "MSYS Makefiles")
	endif()   
  # User wants Windows-libraries
  else()
    set(_SFML_MAKEFILE_GENERATOR "NMake Makefiles") 
  endif()
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

# FindSFML.cmake is installed to different locations on Windows and Linux.
if(LINUX)
  set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/share/SFML/cmake/Modules)
elseif(WINDOWS)
  set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/cmake/Modules)
endif()

ExternalProject_Add(
    SFML
       PREFIX ${TMPDIR}
       URL http://github.com/LaurentGomila/SFML/archive/2.0.tar.gz
       CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${SFML_INSTALL_PREFIX})

ExternalProject_Add(
    SFML_dbg
       DEPENDS SFML
       PREFIX ${TMPDIR}
       SOURCE_DIR ${TMPDIR}/src/SFML
       DOWNLOAD_COMMAND "" # necessary to persuade CMake to accept ${TMPDIR}/src/SFML as source directory.
       CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${SFML_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE:STRING=Debug -DSFML_BUILD_DOC:BOOL=TRUE)

ExternalProject_Add(
    SFGUI
       DEPENDS SFML
       PREFIX ${TMPDIR}
       DOWNLOAD_COMMAND git clone git://boxbox.org/SFGUI.git ${TMPDIR}/src/SFGUI # Custom download command to avoid downloading the SFML-submodule referenced by SFGUI.
       CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${SFGUI_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${FINDSFML_DIR} -DSFML_ROOT=${SFML_INSTALL_PREFIX} -DSFGUI_BUILD_EXAMPLES=FALSE})

ExternalProject_Add(
    SFGUI_dbg
       DEPENDS SFGUI SFML_dbg
       PREFIX ${TMPDIR}
       SOURCE_DIR ${TMPDIR}/src/SFGUI
       DOWNLOAD_COMMAND ""
       CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${SFGUI_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${FINDSFML_DIR} -DSFML_ROOT=${SFML_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE:STRING=Debug -DSFGUI_BUILD_DOC:BOOL=TRUE)

ExternalProject_Add(
   Thor
      DEPENDS SFML
      PREFIX ${TMPDIR}
      URL https://github.com/Bromeon/Thor/archive/master.zip
      CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${THOR_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX})

ExternalProject_Add(
   Thor_dbg
      DEPENDS Thor SFML_dbg 
      PREFIX ${TMPDIR}
      SOURCE_DIR ${TMPDIR}/src/Thor
      DOWNLOAD_COMMAND ""
      CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${THOR_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Debug -DTHOR_BUILD_DOC=TRUE)

add_custom_target(installDependencies
   DEPENDS SFML SFML_dbg SFGUI SFGUI_dbg Thor Thor_dbg)

      

# SFGUI does not provide a FindSFML.cmake on its own. Luckily, SFML places one of those it its installation directory.
#External
#DSFGUI_BUILD_EXAMPLES=FALSE -DSFML_INCLUDE_DIR=${SFML_INSTALL_PREFIX}/include -DCMAKE_INSTALL_PREFIX=${SFGUI_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX}

set(SFML_ROOT ${SFML_INSTALL_PREFIX})
set(CMAKE_PREFIX_PATH ${SFML_INSTALL_PREFIX})

# Finding SFML must not abort cmake-configuration: Configuration is necessary to run `make installDependencies`.
set(SFML_FIND_QUIETLY TRUE) 
find_package(SFML 2 COMPONENTS system)

if(NOT SFML_FOUND)
  message(WARNING "No SFML found. Run: `make installDependencies` and reconfigure the project afterwards.")
else()
  message(STATUS "Adding src.")
#  add_subdirectory(src)
endif()
