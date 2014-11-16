#ifndef PLANET_H
#define PLANET_H

#include <SFML/System.hpp>

struct Planet
{
  sf::Vector2f position;
  int radius;
  int ships;
  int playernumber;
  float timer;
};

#endif // PLANET_H
