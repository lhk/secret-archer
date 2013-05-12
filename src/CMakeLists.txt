include_directories(${SFML_INCLUDE_DIR})

add_executable(testSFML testSFML.cpp)

target_link_libraries(testSFML ${SFML_LIBRARIES})


