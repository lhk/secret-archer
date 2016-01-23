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


#ifndef GAME_H
#define GAME_H

#include <string>
#include <queue>

#include <SFML/Network.hpp>
#include <SFML/System.hpp>

#include <boost/thread.hpp>

enum MessageType {SPAWN, JOIN};

namespace{
std::string MessageTypeToString(MessageType type){
  switch(type){
      case SPAWN : return "spawn"; break;
      case JOIN : return "join"; break;
      default: throw static_cast<int>(type) + "does not have a string equivalent.";
  }
}
}

struct Message{
  MessageType type;
  std::string what;
  Message(MessageType type, std::string what = "") : type(type), what(what){
  }
};

class ServerConnection
{
public:
    ServerConnection(std::string host, unsigned short port);
    static ServerConnection& getServerConnection(){
      static ServerConnection conn("localhost",5000);
      return conn;
    }
    
    void send(Message msg);
    /**
     * Sends all messages in @outgoingMessagesMutex. Typically used by @messageSendingThread.
     */
    void flush();
    ~ServerConnection();
private:
    // ServerConnections should be unique.
    ServerConnection& operator=(const ServerConnection& other);
    ServerConnection(const ServerConnection& other);
    
    bool terminated;
    sf::Http http;
    sf::Thread messageSendingThread;
    
    boost::condition_variable newMessagesNotifier;
    boost::mutex outgoingMessagesMutex;
    std::queue<Message> outgoingMessages;
    std::queue<Message> incomingMessages;
};

#endif // GAME_H
