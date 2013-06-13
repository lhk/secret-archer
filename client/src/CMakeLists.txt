add_subdirectory(util)

add_executable(client serverconnection.cpp main.cpp)

# we need to link ALL SFML-libraries and a subset of the boost-libraries.
target_link_libraries(client 
                      util
                      ${SFML_LIBRARIES}
                      ${Boost_THREAD_LIBRARY}
                      ${Boost_CHRONO_LIBRARY}
                      ${Boost_DATETIME_LIBRARY}
                      ${Boost_SYSTEM_LIBRARY})


