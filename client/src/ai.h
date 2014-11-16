#ifndef AI_H
#define AI_H

class Control;

class AI
{
public:
  // TODO: Rename playernumber -> playerID?
  virtual void Update(Control& control, int playernumber) = 0;
};

#endif // AI_H
