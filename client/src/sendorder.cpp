#include "sendorder.h"
SendOrder::SendOrder(const Planet &from, const Planet &to, int amount)
  :from(from), to(to), amount(amount)
{
}
