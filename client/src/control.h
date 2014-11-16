#ifndef CONTROL_H
#define CONTROL_H

#include <vector>
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>

#include "planet.h"
#include "sendorder.h"
#include "ai.h"
#include "ship.h"
#include "explosion.h"

class Control
{
public:
  std::vector<Planet> planets;
  std::vector<Ship> ships;
  std::vector<AI> ais;
  std::vector<Explosion> explosions; // <- brauchen wir für jeden Effekt eine eigene Klasse??

  std::vector<SendOrder> sendOrders;

  // TODO: move the resources to their class or provide one ResourceLoader that holds all resources.
  sf::Texture shipTexture;
  sf::Texture planetTexture;

  sf::Texture explosionTexture;
  sf::Sound explosionSound;

  sf::Font font;

  sf::VideoMode resolution;
private:
  bool send(Ship& ship, const Planet& target);
  bool send(const Planet& from, const Planet& to, unsigned int amount);
public:
  bool order(const SendOrder& order);
  void update(sf::Time elapsedTime);
  Control(sf::VideoMode resolution);

};

#endif // CONTROL_H
