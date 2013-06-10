set(testServerConnection_SOURCES "testserverconnection.cpp ../src/serverconnection.cpp")

if(Boost_UNIT_TEST_FRAMEWORK_FOUND)
  add_executable(secretarcher_test testserverconnection.cpp ../src/serverconnection.cpp)
  target_link_libraries(secretarcher_test ${Boost_LIBRARIES} ${SFML_LIBRARIES})
endif()
  
