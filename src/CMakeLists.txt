set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

find_package(SFML 2 COMPONENTS system REQUIRED)
include_directories(${SFML_INCLUDE_DIR})

add_executable(testSFML testSFML.cpp)

target_link_libraries(testSFML ${SFML_LIBRARIES})


