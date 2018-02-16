#include "suider.h"

static char* xargv[] = {"-p", "--", NULL};

int mkargs(int argc, char *argv[], char* dev, char** shell, char*** rargv)
{
    *shell = "/bin/bash";
    *rargv = MKARGS(argc, argv, dev, xargv);
    return 0;
}
