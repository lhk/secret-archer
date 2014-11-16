#include "control.h"

using namespace sf;

Control::Control(VideoMode resolution)
  : resolution(resolution)
{
  // initialize the game
  // create the game and start the AIs
  for(int i = 0; i < 10; i++)
    {
      Planet testplanet;
      testplanet.playernumber = 1;
      testplanet.radius = rand() * 40 + 10;
      testplanet.ships = 5;
      testplanet.timer = 0;
      Vector2f position;
      position.x =
    }

}


void Control::update(Time elapsedTime)
{
}


bool Control::order(const SendOrder &order)
{

}
