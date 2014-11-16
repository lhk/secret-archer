#ifndef EXPANDAI_H
#define EXPANDAI_H

#include "ai.h"
#include "control.h"

class ExpandAI : public AI
{
public:
  void Update(Control &control, int playernumber);
  ExpandAI();
};

#endif // EXPANDAI_H
