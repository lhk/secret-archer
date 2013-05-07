cmake_policy(SET CMP0012 NEW)

set(SFGUIDIR ${TMPDIR}/SFGUI)
# Only set sudo if there is a sudo ;-)
if(${NEED_SUDO} AND NOT WINDOWS)
  set(SUDO sudo)
else()
  set(SUDO "")
endif()

function(die)
  message(FATAL_ERROR "Unrecoverable error. Cannot continue.")
endfunction()

function(check result)
  if(NOT ${result} EQUAL 0)
    die()
  endif()
endfunction()

macro(tidySFMLRepo)
  execute_process(COMMAND make clean
                  WORKING_DIRECTORY ${SFGUIDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(RESULT)
endmacro()

# Check for an existing SFGUI-clone
if(EXISTS ${SFGUIDIR})
  message(STATUS "Removing existing SFGUI-clone")
  if(IS_DIRECTORY ${SFGUIDIR})
    execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove_directory ${SFGUIDIR})
  else()
    execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove ${SFGUIDIR})
  endif()
endif()
message(STATUS "Retrieving SFGUI from repository")

execute_process(COMMAND git clone git://boxbox.org/SFGUI.git
                 WORKING_DIRECTORY ${TMPDIR}
                 RESULT_VARIABLE RESULT)
check(${RESULT})

message(STATUS "Generating Makefile")
# FindSFML.cmake is installed to different locations on Windows and Linux.
if(LINUX)
  set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/share/SFML/cmake/Modules)
elseif(WINDOWS)
  set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/cmake/Modules)
endif()

# SFGUI does not provide a FindSFML.cmake on its own. Luckily, SFML places one of those it its installation directory.
execute_process(COMMAND ${CMAKE_COMMAND} -G ${SFML_MAKEFILE_GENERATOR} -DSFML_INCLUDE_DIR=${SFML_INSTALL_PREFIX}/include -DCMAKE_INSTALL_PREFIX=${SFGUI_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${FINDSFML_DIR}
                 WORKING_DIRECTORY ${SFGUIDIR}
                 OUTPUT_QUIET
                 RESULT_VARIABLE RESULT
                )
check(${RESULT})

message(STATUS "Building and installing SFGUI release library")
execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}
                 WORKING_DIRECTORY ${SFGUIDIR}
                 OUTPUT_QUIET
                 RESULT_VARIABLE RESULT)
check(${RESULT})

IF(${BUILD_SFML_DEBUG_LIBS})
  tidySFMLRepo()
  # If the commands are concatenated like `${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release && make install`, the working directory for make install is wrong. Why?
  message(STATUS "Building and installing SFGUI debug library")  
  execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Debug 
                  WORKING_DIRECTORY ${SFGUIDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
  execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}
                  WORKING_DIRECTORY ${SFGUIDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
ENDIF()

IF(${BUILD_SFML_DOC})
# tidySFMLRepo not necessary here. It's just about the docs.
  message(STATUS "Building and installing SFGUI docs")
  execute_process(COMMAND ${CMAKE_COMMAND} -DSFGUI_BUILD_DOC=TRUE                   
                  WORKING_DIRECTORY ${SFGUIDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
#ERROR_QUIET is currently used to suppress doxygen-warnings. Is there a way that does not eat doxygen-errors, too? We might as well ignore errors here as SFML should always be stable.
  execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}                
                  WORKING_DIRECTORY ${SFGUIDIR}
                  OUTPUT_QUIET
                  ERROR_QUIET                                    
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
ENDIF()



