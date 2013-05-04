set(SFMLDIR ${TMPDIR}/SFML)
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
                  WORKING_DIRECTORY ${SFMLDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(RESULT)
endmacro()

# Check for an existing SFML-clone
if(EXISTS ${SFMLDIR})
  message(STATUS "Removing existing SFML-clone")
  if(IS_DIRECTORY ${SFMLDIR})
    execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove_directory ${SFMLDIR})
  else()
    execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove ${SFMLDIR})
  endif()
endif()
message(STATUS "Retrieving SFML from repository")

execute_process(COMMAND git clone git://github.com/LaurentGomila/SFML.git
                 WORKING_DIRECTORY ${TMPDIR}
                 RESULT_VARIABLE RESULT)
check(${RESULT})
    
message(STATUS "Checking out version 2.0")
execute_process(COMMAND git checkout 2.0
                 WORKING_DIRECTORY ${SFMLDIR}
                 OUTPUT_QUIET
                 ERROR_QUIET
                 RESULT_VARIABLE RESULT 	
                 )
check(${RESULT})

message(STATUS "Generating Makefile")
execute_process(COMMAND ${CMAKE_COMMAND} -G ${SFML_MAKEFILE_GENERATOR} -DCMAKE_INSTALL_PREFIX=${SFML_INSTALL_PREFIX}
                 WORKING_DIRECTORY ${SFMLDIR}
                 OUTPUT_QUIET
                 RESULT_VARIABLE RESULT
                )
check(${RESULT})

message(STATUS "Building and installing SFML release libraries")
execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}
                 WORKING_DIRECTORY ${SFMLDIR}
                 OUTPUT_QUIET
                 RESULT_VARIABLE RESULT)
check(${RESULT})

IF(${BUILD_SFML_DEBUG_LIBS})
  tidySFMLRepo()
  # If the commands are concatenated like `${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release && make install`, the working directory for make install is wrong. Why?
  message(STATUS "Building and installing SFML debug libraries")  
  execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Debug 
                  WORKING_DIRECTORY ${SFMLDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
  execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}
                  WORKING_DIRECTORY ${SFMLDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
ENDIF()

IF(${BUILD_SFML_DOC})
# tidySFMLRepo not necessary here. It's just about the docs.
  message(STATUS "Building and installing SFML docs")
  execute_process(COMMAND ${CMAKE_COMMAND} -DSFML_BUILD_DOC=TRUE                   
                  WORKING_DIRECTORY ${SFMLDIR}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
#ERROR_QUIET is currently used to suppress doxygen-warnings. Is there a way that does not eat doxygen-errors, too? We might as well ignore errors here as SFML should always be stable.
  execute_process(COMMAND ${SUDO} make install -j${NUM_CORES}                
                  WORKING_DIRECTORY ${SFMLDIR}
                  OUTPUT_QUIET
                  ERROR_QUIET                                    
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
ENDIF()



