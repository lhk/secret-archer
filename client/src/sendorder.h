#ifndef SENDORDER_H
#define SENDORDER_H
#include <planet.h>

class SendOrder
{
public:
  const Planet& from;
  const Planet& to;
  int amount;

  SendOrder(const Planet& from, const Planet& to, int amount);
};

#endif // SENDORDER_H
