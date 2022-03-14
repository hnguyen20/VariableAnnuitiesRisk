#include<iostream>
using namespace std;

// An abstract class with constructor
class Base
{
public:
   int x;
public:
  virtual void fun() = 0;
  Base() { x = 5; }
};

class Derived: public Base
{
    int y;
public:
    void fun() { cout << "x = " << x << endl ; }
};

