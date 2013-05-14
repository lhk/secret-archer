cmake_policy(SET CMP0012 NEW)

include(util)

set(THORDIR ${TMPDIR}/Thor)
# Check for an existing Thor-clone
delete(${THORDIR})
git_clone(Thor git://github.com/Bromeon/Thor.git ${TMPDIR})

cmake_configure(${THORDIR} -G${SFML_MAKEFILE_GENERATOR} -DSFML_INCLUDE_DIR=${SFML_INSTALL_PREFIX}/include -DCMAKE_INSTALL_PREFIX=${THOR_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX})
make_install(${MAKE_PROGRAM} "Building and installing Thor release library" ${THORDIR})

if(${BUILD_SFML_DEBUG_LIBS})
  cmake_configure(${THORDIR} -DCMAKE_BUILD_TYPE=Debug)
  make_install(${MAKE_PROGRAM} "Building and installing Thor debug library" ${THORDIR})
endif()

if(${BUILD_SFML_DOC})
  cmake_configure(${THORDIR} -DTHOR_BUILD_DOC=TRUE)
  make_install(${MAKE_PROGRAM} "Building and installing Thor docs" ${THORDIR} ERROR_QUIET)
endif()
