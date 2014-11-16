#include <iostream>
#include <SFML/Graphics.hpp>
#include <vector>

using namespace std;
using namespace sf;

int main(){
  VideoMode resolution = VideoMode::getDesktopMode();
  RenderWindow window(resolution, "secret-archer", Style::Fullscreen);

  RectangleShape background;
  background.setSize(Vector2f(resolution.width, resolution.height));

  Texture* backgroundTexture = new Texture();
  backgroundTexture->loadFromFile("../res/space.png");

  background.setTexture(backgroundTexture);

  while (window.isOpen())
    {
      sf::Event event;
      while (window.pollEvent(event))
        {
          if( event.type == sf::Event::Closed ||
              event.type == sf::Event::KeyPressed &&
              event.key.code == sf::Keyboard::Escape)
            window.close();
        }

      window.clear();
      window.draw(background);
      window.display();
    }

  return 0;
}
