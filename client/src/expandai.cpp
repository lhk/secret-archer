#include "expandai.h"
#include <algorithm>

using namespace std;

void ExpandAI::Update(Control &control, int playernumber)
{
  vector<Planet> friendlyPlanets(control.planets.size());
  copy_if(control.planets.begin(), control.planets.end(), friendlyPlanets.begin(),
          [playernumber](Planet& planet){return planet.playernumber ==  playernumber;});
  vector<Planet> hostilePlanets(control.planets.size());
  copy_if(control.planets.begin(), control.planets.end(), hostilePlanets.begin(),
          [playernumber](Planet& planet){return planet.playernumber != playernumber;});

  // either we or the enemy has lost all their planets. The game is over.
  if(friendlyPlanets.size() == 0 || hostilePlanets.size() == 0)
    return;

  const Planet& target = control.planets.at(0);

  for(Planet p: friendlyPlanets){
      // TODO: Sinn?
      if(p.ships > target.ships) continue;
      if(p.ships > 2) return;
      control.order(SendOrder(p, target, 1));
    }


}

ExpandAI::ExpandAI()
{

}
