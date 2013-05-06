cmake_policy(SET CMP0012 NEW)

set(THORDIR ${TMPDIR}/Thor)
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
                  WORKING_DIRECTORY ${THORDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(RESULT)
endmacro()

# Check for an existing Thor-clone
if(EXISTS ${THORDIR})
  message(STATUS "Removing existing Thor-clone")
  if(IS_DIRECTORY ${THORDIR})
    execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove_directory ${THORDIR})
  else()
    execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove ${THORDIR})
  endif()
endif()
message(STATUS "Retrieving Thor from repository")

execute_process(COMMAND git clone git://github.com/Bromeon/Thor.git
                 WORKING_DIRECTORY ${TMPDIR}
                 RESULT_VARIABLE RESULT)
check(${RESULT})

message(STATUS "Generating Makefile")
execute_process(COMMAND ${CMAKE_COMMAND} -G ${SFML_MAKEFILE_GENERATOR} -DSFML_INCLUDE_DIR=${SFML_INSTALL_PREFIX}/include -DCMAKE_INSTALL_PREFIX=${THOR_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX}
                 WORKING_DIRECTORY ${THORDIR}
                 OUTPUT_QUIET
                 RESULT_VARIABLE RESULT
                )
check(${RESULT})

message(STATUS "Building and installing Thor release library")
execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}
                 WORKING_DIRECTORY ${THORDIR}
                 OUTPUT_QUIET
                 RESULT_VARIABLE RESULT)
check(${RESULT})

IF(${BUILD_SFML_DEBUG_LIBS})
  tidySFMLRepo()
  # If the commands are concatenated like `${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release && make install`, the working directory for make install is wrong. Why?
  message(STATUS "Building and installing Thor debug library")  
  execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Debug 
                  WORKING_DIRECTORY ${THORDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
  execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}
                  WORKING_DIRECTORY ${THORDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
ENDIF()

IF(${BUILD_SFML_DOC})
# tidySFMLRepo not necessary here. It's just about the docs.
  message(STATUS "Building and installing Thor docs")
  execute_process(COMMAND ${CMAKE_COMMAND} -DTHOR_BUILD_DOC=TRUE                   
                  WORKING_DIRECTORY ${THORDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
#ERROR_QUIET is currently used to suppress doxygen-warnings. Is there a way that does not eat doxygen-errors, too? We might as well ignore errors here as SFML should always be stable.
  execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}                
                  WORKING_DIRECTORY ${THORDIR}
                  OUTPUT_QUIET
                  ERROR_QUIET                                    
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
ENDIF()



