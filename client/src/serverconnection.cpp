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

void foo() {
}
using namespace boost;
using namespace std;
ServerConnection::ServerConnection(std::string host, unsigned short port)
    : http(host, port), messageSendingThread(&ServerConnection::flush, this), terminated(false)
{
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
            sf::Http::Request currentRequest = sf::Http::Request();
            currentRequest.setUri(MessageTypeToString(currentMessage.type));

            http.sendRequest(currentRequest);
        }
    }
}

ServerConnection::~ServerConnection()
{
    terminated = true;
    messageSendingThread.join();
}
