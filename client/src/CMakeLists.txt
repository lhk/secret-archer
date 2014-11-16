add_subdirectory(util)

add_executable(client main.cpp control.cpp planet.cpp sendorder.cpp expandai.cpp ship.cpp explosion.cpp)

# we need to link ALL SFML-libraries
target_link_libraries(client
                      util
                      ${SFML_LIBRARIES})

add_custom_command(TARGET client POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/res"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${PROJECT_SOURCE_DIR}/res"
        "${PROJECT_BINARY_DIR}/res")
