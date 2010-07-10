#include "one.h"
#include "one_private.h"

const char *one_b()
{
    two_a();
    return "This is one B.";
}

#ifdef TEST_ONE_B

int main()
{
    return *one_b() != 'T';
}

#endif /* TEST_ONE_B */
