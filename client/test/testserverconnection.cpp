#define BOOST_TEST_MAIN

#define BOOST_TEST_DYN_LINK
#include <boost/test/unit_test.hpp>
#include <boost/date_time.hpp>
#include <boost/chrono.hpp>
#include <boost/timer.hpp>

#include <iostream>
#include <vector>

#include <serverconnection.h>


using namespace std;

BOOST_AUTO_TEST_SUITE( serverconnection_test)

BOOST_AUTO_TEST_CASE( constructor_test)
{
   BOOST_REQUIRE_NO_THROW( ServerConnection conn("127.0.0.1", 5000) );
}

BOOST_AUTO_TEST_CASE( performance_test)
{
    const int messageCount = 1000;
    const boost::posix_time::ptime then = boost::posix_time::microsec_clock::local_time();
    boost::timer timer;
    {
    ServerConnection conn("127.0.0.1", 5000);    
    for(int i = 0; i < messageCount; i++)
        conn.send(JOIN);
    } // destroy conn: waits for the messages to arrive.
    const boost::posix_time::time_duration elapsedTime = boost::posix_time::microsec_clock::local_time()-then;
    const double elapsedSeconds = elapsedTime.total_milliseconds()/1000.f;
    cout << messageCount << " messages in " << elapsedSeconds << " seconds" << endl;
    cout << "That's " << messageCount/elapsedSeconds << " messages per second" << endl;
    // The server should be able to handle more than 50 join requests per second.
    BOOST_WARN(messageCount/elapsedSeconds < 50);
}

BOOST_AUTO_TEST_SUITE_END()
