#include <SFML/System.hpp>
#include <SFML/Network.hpp>

#include <boost/thread.hpp>
#include <boost/date_time.hpp>

#include <iostream>
#include <vector>

#include <serverconnection.h>

using namespace std;
using namespace sf;

int vain() {
// Create a new HTTP client
    sf::Http http;
// We'll work on http://www.sfml-dev.org
    http.setHost("http://www.sfml-dev.org");
// Prepare a request to get the 'features.php' page
    sf::Http::Request request("features.php");
// Send the request
    sf::Http::Response response = http.sendRequest(request);
// Check the status code and display the result
    sf::Http::Response::Status status = response.getStatus();
    if (status == sf::Http::Response::Ok)
    {
        std::cout << response.getBody() << std::endl;
    }
    else
    {
        std::cout << "Error " << status << std::endl;
    }

}


int main()
{
  
//   vector<Http> b (50);
//   vector<Http> a = b;
     boost::chrono::steady_clock::time_point now = boost::chrono::steady_clock::now();
  {
   ServerConnection conn("192.168.178.34", 5001);
   cout << "Sending 10000 messages..." << endl;
   for(int i = 0; i < 10000; i++)
   {
     conn.send(Message(JOIN));
   }
  }
  boost::chrono::duration<double> dur = boost::chrono::steady_clock::now()- now;
   cout << "Sending the messages took " << dur.count() << " seconds" << endl;
   cout << "That's " << 10000/ dur.count() << " messages per second" << endl;
}
