#include <SFML/Graphics.hpp>

#include <iostream>

#include <math.h>

using namespace std;
using namespace sf;

int main(){
    cout << "hi" << endl;
    sf::RenderWindow window(sf::VideoMode(1920, 1080), "hello");
    sf::RectangleShape rect(sf::Vector2f(150,150));
    sf::RectangleShape rect2(sf::Vector2f(150,150));
    rect.setPosition(500,500);
    rect2.setPosition(500,500);
    rect.setFillColor(Color(255,0,0));

    sf::Color col(255,0,0);
    col.a = 127;
    rect.setFillColor(col);
    sf::Color col2(0,255,0);
    col2.a = 127;
    rect2.setFillColor(col2);

    sf::Clock clock;

    while (window.isOpen())
   {
   // turn rectangle
   float angle = sin(clock.getElapsedTime().asSeconds()) *360;
   rect.setRotation(angle);
   rect2.setRotation(-angle);
   // Process events
   sf::Event event;
   while (window.pollEvent(event))
   {
   // Close window : exit
   if (event.type == sf::Event::Closed)
   window.close();
   }
   // Clear screen
   window.clear(sf::Color(0,0,255));
   // Draw the sprite
   window.draw(rect);
   window.draw(rect2);
   // Update the window
   window.display();
   }
}
