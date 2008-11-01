/* bbtest - black box test. */

#include "one.h"
#include <stdio.h>

int main()
{
    return *one() != 'T';
}
