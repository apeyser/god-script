#include "suider.h"

static char* xargv[] = {"-s", "--", NULL};

int mkargs(int argc, char *argv[], char* dev, char** shell, char*** rargv)
{
    *shell = "/usr/bin/python3";
    *rargv = MKARGS(argc, argv, dev, xargv);
    return 0;
}
