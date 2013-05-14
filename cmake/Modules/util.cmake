# Contains some useful functions and macros.

function(die)
  message(FATAL_ERROR "Unrecoverable error. Cannot continue.")
endfunction()

function(check result)
  if(NOT ${result} EQUAL 0)
    die()
  endif()
endfunction()

# Cleans the repo specified in repodir.
macro(make_clean repodir)
  execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} clean
                  WORKING_DIRECTORY ${repodir}
                  OUTPUT_QUIET
                  RESULT_VARIABLE RESULT)
  check(RESULT)
endmacro()

# Deletes the given file or folder.
function(delete file_or_folder)
if(EXISTS ${file_or_folder})
    message(STATUS "Removing ${file_or_folder}")
    if(IS_DIRECTORY ${file_or_folder})	  
      execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove_directory ${file_or_folder})
    else()
      execute_process(COMMAND ${SUDO} ${CMAKE_COMMAND} -E remove ${file_or_folder})
    endif()
endif()
endfunction()

# Clones the repo specified in remote to path/remote.
# Name is the name of the remote.
function(git_clone name remote path)
  message(STATUS "Retrieving ${name} from repository")

  execute_process(COMMAND git clone ${remote}
                  WORKING_DIRECTORY ${path}
                  RESULT_VARIABLE RESULT)
  check(${RESULT})
endfunction()

# Checks out a revision in the git repository specified in path.
function(git_checkout version path)
  message(STATUS "Checking out version ${version}")
  execute_process(COMMAND git checkout ${version}
                  WORKING_DIRECTORY ${path}
                  OUTPUT_QUIET
                  ERROR_QUIET
                  RESULT_VARIABLE RESULT 	
                  )
  check(${RESULT})
endfunction()

# You may specify additional parameters after path.
# If you want to run `cmake -DDOC=TRUE -DDEBUG=FALSE` for a cmake-project in /tmp/dir, write:
# cmake_configure(/tmp/dir -DDOC=TRUE -DDEBUG=FALSE)
function(cmake_configure path)
  message(STATUS "Generating Makefile")
  if(${ARGC} EQUAL 1) # true if no additional arguments are passed
  # We need to run cmake at least once, in case there are no additional arguments.
    execute_process(COMMAND ${CMAKE_COMMAND} .
                    WORKING_DIRECTORY ${path}
                    OUTPUT_QUIET
                    RESULT_VARIABLE RESULT
                   )
    check(${RESULT})
    return()
  endif()
  #opt is one additional argument.
  execute_process(COMMAND ${CMAKE_COMMAND} ${ARGN}
                  WORKING_DIRECTORY ${path}
                  #OUTPUT_QUIET
				  #ERROR_QUIET
                  RESULT_VARIABLE RESULT
                 )   	
  check(${RESULT})
endfunction()

# ERROR_QUIET may be passed as additional argument.
function(make_install make_program msg path)
  message(STATUS ${msg})
  # res is -1 if nmake is not used. nmake does not support the j-switch.
  STRING(FIND "${make_program}" "nmake" res)
  if(DEFINED NUM_CORES AND res EQUAL -1)
     execute_process(COMMAND ${make_program} install -j${NUM_CORES}
	                 WORKING_DIRECTORY ${path}
                     #OUTPUT_QUIET
					 #${ARGN}
                     RESULT_VARIABLE RESULT)
  else()
    execute_process(COMMAND ${make_program} install
                    WORKING_DIRECTORY ${path}
                    #OUTPUT_QUIET
					#${ARGN}
                    RESULT_VARIABLE RESULT)
  endif()
check(${RESULT})
endfunction()