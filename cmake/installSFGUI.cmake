cmake_policy(SET CMP0012 NEW)

include(util)

set(SFGUIDIR ${TMPDIR}/SFGUI)
# Only set sudo if there is a sudo ;-)
if(${NEED_SUDO} AND NOT WINDOWS)
  set(SUDO sudo)
else()
  set(SUDO "")
endif()

# Check for an existing SFGUI-clone
delete(${SFGUIDIR})
git_clone(SFGUI git://boxbox.org/SFGUI.git ${TMPDIR})

# FindSFML.cmake is installed to different locations on Windows and Linux.
if(LINUX)
  set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/share/SFML/cmake/Modules)
elseif(WINDOWS)
  set(FINDSFML_DIR ${SFML_INSTALL_PREFIX}/cmake/Modules)
endif()

# SFGUI does not provide a FindSFML.cmake on its own. Luckily, SFML places one of those it its installation directory.
cmake_configure(${SFGUIDIR} -G${SFML_MAKEFILE_GENERATOR} -DSFML_INCLUDE_DIR=${SFML_INSTALL_PREFIX}/include -DCMAKE_INSTALL_PREFIX=${SFGUI_INSTALL_PREFIX} -DSFML_ROOT=${SFML_INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${FINDSFML_DIR})
make_install("Building and installing SFGUI release library" ${SFGUIDIR})

if(${BUILD_SFML_DEBUG_LIBS})
  cmake_configure(${SFGUIDIR} -DCMAKE_BUILD_TYPE=Debug)
  make_install("Building and installing SFGUI debug library" ${SFGUIDIR})
endif()

if(${BUILD_SFML_DOC})
  cmake_configure(${SFGUIDIR} -DSFGUI_BUILD_DOC=TRUE)
  make_install("Building and installing SFGUI docs" ${SFGUIDIR} ERROR_QUIET)
endif()

set(CMAKE_MODULE_PATH ${_CMAKE_MODULE_PATH})