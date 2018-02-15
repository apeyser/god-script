#include <stdlib.h>
#include <unistd.h>

int mkargs(int argc, char *argv[], char* dev, char** shell, char*** rargv)
{
    const size_t extra = 2;
    const size_t nargc = argc+extra;
    char* *nargv;
    size_t i;

    if (! (nargv = malloc((nargc+1)*sizeof(char**))))
        return -1;
    
    i = 0;
    nargv[i++] = argv[0];
    nargv[i++] = "-s";
    nargv[i++] = dev;

    for (; i < nargc+1; i++)
        nargv[i] = argv[i-extra];

    *shell = "/usr/bin/python3";
    *rargv = nargv;
    return 0;
}
