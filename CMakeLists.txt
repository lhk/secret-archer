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
set(FORCE_EXTERNALS 0 CACHE BOOL "True if you want cmake to create targets that build SFML, SFGUI, Thor and Boost even if those are already installed. OFF by default.")

# Finding SFML must not abort cmake-configuration: Configuration is necessary to run `make installDependencies`.
set(SFML_FIND_QUIETLY TRUE) 
find_package(SFML 2 COMPONENTS system network)

# shared_ptr is header only and cannot be found by find_package. However, if Boost finds the specified libraries, shared_ptr will be available in the include directory.
find_package(Boost COMPONENTS thread date_time chrono system  # required by `make client`
                              unit_test_framework)            # required by `make test`

if(NOT SFML_FOUND OR NOT Boost_FOUND OR FORCE_EXTERNALS)
  # At least one dependency is missing. We need a temporary folder to download it.
  if(LINUX)
    set(_TMPDIR "/tmp")
  elseif(WINDOWS)
    set(_TMPDIR "C:/Windows/Temp") 
  endif()
  set(TMPDIR ${_TMPDIR} CACHE PATH "Folder for temporary files")
  # Create tmpdir if is doesn't exist. Abort when it is a file.
  if(NOT IS_DIRECTORY ${TMPDIR})
    if(EXISTS ${TMPDIR})
      message(FATAL_ERROR "tmpdir ${TMPDIR} exists and is not a directory. Cannot continue.")
    elseif()
      file(MAKE_DIRECTORY ${TMPDIR})
      message(STATUS "Creating temporary directory ${TMPDIR}.")
    endif()
  endif()
  message(WARNING "Missing at least one dependency. Run `make help` to figure out the missing one(s).")
else()
  message(STATUS "Requirements are met. Adding src and setting include directories.")
  include_directories(${SFML_INCLUDE_DIR} ${Boost_INCLUDE_DIRS} client/src)
  add_subdirectory(client)
endif()

if(NOT SFML_FOUND OR FORCE_EXTERNALS)
  set(SFML_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/SFML" CACHE STRING "Directory to which SFML will be installed.")
  set(SFML_ROOT ${SFML_INSTALL_PREFIX})
  set(CMAKE_PREFIX_PATH ${SFML_INSTALL_PREFIX})
  # FindSFML.cmake is installed to different locations on Windows and Linux.
  if(LINUX)
    set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/share/SFML/cmake/Modules)
  elseif(WINDOWS)
    set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/cmake/Modules)
  endif()

  ExternalProject_Add(
    SFML
       PREFIX ${TMPDIR}
       URL https://github.com/LaurentGomila/SFML/archive/2.0.zip
       CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${SFML_INSTALL_PREFIX})

  ExternalProject_Add(
    SFML_dbg
       DEPENDS SFML
       PREFIX ${TMPDIR}
       SOURCE_DIR ${TMPDIR}/src/SFML
       DOWNLOAD_COMMAND "" # necessary to persuade CMake to accept ${TMPDIR}/src/SFML as source directory.
       CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${SFML_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE:STRING=Debug -DSFML_BUILD_DOC:BOOL=TRUE)

  message(STATUS "Adding target `SFML` that installs SFML for you (try `make SFML`)")
endif()

if(NOT Boost_FOUND OR FORCE_EXTERNALS)
  set(BOOST_ROOT ${BOOST_INSTALL_PREFIX})
  set(BOOST_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/Boost" CACHE STRING "Directory to which Boost will be installed.")
  # For Boost, the download size for zip and tar.gz differs by ~30MB (with tar.gz being smaller). For Linux, we use tar.gz, for windows we must use zip yet.
  set(BOOST_PATH ${TMPDIR}/src/Boost)
  if(LINUX)
    set(BOOST_DOWNLOAD_URI http://downloads.sourceforge.net/boost/boost_1_53_0.tar.bz2)
    set(BOOST_BOOTSTRAP_SCRIPT ./bootstrap.sh)
  elseif(WINDOWS)
    set(BOOST_DOWNLOAD_URI http://downloads.sourceforge.net/boost/boost_1_53_0.zip)
    set(BOOST_BOOTSTRAP_SCRIPT bootstrap.bat)
  endif()

  # From the boost libraries, we need:
  # * shared_ptr (in smart_ptr, header only)
  # * threads (in thread)
  #   thread requires the following libraries to be built:
  #   * chrono
  #   * datetime
  #    * system

  ExternalProject_Add(
    Boost
     PREFIX ${TMPDIR}
     URL ${BOOST_DOWNLOAD_URI}
     CONFIGURE_COMMAND "" # Boost cannot be automatically configured as it is neither using cmake nor configure.
     UPDATE_COMMAND cd ${BOOST_PATH}  && ${BOOST_BOOTSTRAP_SCRIPT}                                                         # builds b2/bjam in BOOST_ROOT.
     BUILD_COMMAND cd ${BOOST_PATH}   && ${BOOST_PATH}/bjam -j${NUM_CORES} tools/bcp                                               # builds bcp
     INSTALL_COMMAND cd ${BOOST_PATH} && ${BOOST_PATH}/dist/bin/bcp --boost=${TMPDIR}/src/Boost smart_ptr thread ${BOOST_INSTALL_PREFIX}) # copies smart_ptr to extlibs/boost
    
  ExternalProject_Add_Step(
    Boost installlibs
     COMMAND ${BOOST_PATH}/bjam install -j${NUM_CORES} --prefix=${BOOST_INSTALL_PREFIX} --build-type=complete --layout=versioned --threading=multi --with-thread --with-chrono --with-date_time --with-test
     COMMENT "Building libraries"
     WORKING_DIRECTORY ${BOOST_PATH}
     DEPENDEES install
  )

  ExternalProject_Add_Step(
    Boost createExtlibs
     COMMAND ${CMAKE_COMMAND} -E make_directory ${BOOST_INSTALL_PREFIX}
     COMMENT "Setting up directories"
     DEPENDERS mkdir
     ALWAYS TRUE)
  message(STATUS "Adding target `Boost` that installs the boost-libraries for you (try `make Boost`)")
endif()

# The installation of Thor and SFGUI is not necessary yet.
if(FALSE)
  set(THOR_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/Thor" CACHE STRING "Directory to which Thor will be installed.")
  set(SFGUI_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/extlibs/SFGUI" CACHE STRING "Directory to which SFGUI will be installed.")
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
endif()

message(WARNING "Please set NUM_CORES according to your needs. NUM_CORES is 4 by default.")

