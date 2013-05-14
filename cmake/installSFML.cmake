cmake_policy(SET CMP0012 NEW)

include(util)

set(SFMLDIR ${TMPDIR}/SFML)

# Check for an existing SFML-clone
delete(${SFMLDIR})
git_clone(SFML git://github.com/LaurentGomila/SFML.git ${TMPDIR})
git_checkout(2.0 ${SFMLDIR})
cmake_configure(${SFMLDIR} -G${SFML_MAKEFILE_GENERATOR} -DCMAKE_INSTALL_PREFIX=${SFML_INSTALL_PREFIX})
make_install("Building and installing SFML release libraries" ${SFMLDIR})

IF(${BUILD_SFML_DEBUG_LIBS})
  cmake_configure(${SFMLDIR} -DCMAKE_BUILD_TYPE=Debug)
  make_install("Building and installing SFML debug libraries" ${SFMLDIR})
ENDIF()

IF(${BUILD_SFML_DOC})
  # ERROR_QUIET to suppress doxygen messages.
  cmake_configure(${SFMLDIR} -DSFML_BUILD_DOC=TRUE)
  make_install("Building and installing SFML docs" ${SFMLDIR} ERROR_QUIET)
ENDIF()

