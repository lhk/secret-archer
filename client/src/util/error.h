#ifndef ERROR_H
#define ERROR_H

#include <exception>

class Error : public std::exception
{
private:
    const char* error;
public:
    virtual const char* what(){return error;}
    Error(const char* error);
};

#endif // ERROR_H
