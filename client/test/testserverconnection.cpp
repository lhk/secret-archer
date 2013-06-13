#define BOOST_TEST_MAIN

#define BOOST_TEST_DYN_LINK
#include <boost/test/unit_test.hpp>

#include <boost/date_time.hpp>

#include <iostream>
#include <vector>

#include <serverconnection.h>

BOOST_AUTO_TEST_SUITE( serverconnection_test)

BOOST_AUTO_TEST_CASE( constructor_test)
{
   BOOST_CHECK_NO_THROW( ServerConnection conn("127.0.0.1", 5000) );
}

BOOST_AUTO_TEST_SUITE_END()
