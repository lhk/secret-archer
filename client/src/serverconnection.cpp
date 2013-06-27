/*
    <one line to give the library's name and an idea of what it does.>
    Copyright (C) 2013  Max Beikirch <email>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/


#include "serverconnection.h"

#include "util/log.h"
#include "util/error.h"

#include "version.h"

#include <stdlib.h>
#include <exception>

void foo() {
}
using namespace boost;
using namespace std;

ServerConnection::ServerConnection(std::string host, unsigned short port)
    : http(host, port), messageSendingThread(&ServerConnection::flush, this), terminated(false)
{
    sf::Http::Request currentRequest;
    currentRequest.setUri("hello");

    sf::Http::Response response = http.sendRequest(currentRequest);
    sf::Http::Response::Status status = response.getStatus();
    // The answer from the secret archer server is a string of the form "sad <protocol number>".
    switch (status)
    {
    case sf::Http::Response::Ok:
    {
        string body = response.getBody();
        if(body.find("sad") != -1)
        {
            unsigned int protocolIDPos =  body.find_first_not_of("sad");
            string protocolIDStr = body.substr(protocolIDPos);
            int protocolID = atoi(protocolIDStr.c_str());
            if(protocolID != version::protocolID)
                throw Error("The client's version does not match the server's version");
        }
        else
            throw Error("Received malformed handshake from server");
        break;
    }
    case sf::Http::Response::ConnectionFailed:
        throw Error("Cannot connect to server. Is the server running?");
    }

}

void ServerConnection::send(Message msg)
{
    lock_guard<mutex> lock(outgoingMessagesMutex);
    outgoingMessages.push(msg);
}

void ServerConnection::flush() {
    while(!terminated)
    {
        // The lock is reacquired before each message is sent: send shall never block for too long and it surely would if
        // the whole queue was sent before the lock is released.
        while(!outgoingMessages.empty())
        {
            Message currentMessage(SPAWN);// just initialize with something
            {
                lock_guard<mutex> lock(outgoingMessagesMutex);
                currentMessage = outgoingMessages.front();
                outgoingMessages.pop();
            } // release outgoingMessagesMutex
            sf::Http::Request currentRequest;
            currentRequest.setUri(MessageTypeToString(currentMessage.type));

            sf::Http::Response response =  http.sendRequest(currentRequest);
            sf::Http::Response::Status status = response.getStatus();
            int category = (int) trunc(status / 100);
            switch(category)
            {
               // 2xx: success
               case 2 : continue;
               // 3xx: redirection
               case 3 : Log::write("Got a 3xx response after a HTTP request."); break;
               // 4xx: client error
               case 4 : throw "Got a 4xx response after a HTTP request."; break;
               // 5xx: server error
               // Maybe we should retry on a server error?
               case 5 : Log::write("Got a 5xx response after a HTTP request.");
            }
        }
    }
}

ServerConnection::~ServerConnection()
{
    terminated = true;
    messageSendingThread.join();
}
