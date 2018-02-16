#ifndef SUIDER_H
#define SUIDER_H

#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include <stdio.h>

// called to exit on error
void error(const char *s) {
    perror(s);
    exit(-1);
}

// macros for error with check
#define E(f)  if ((f) < 0) error(#f)
#define AE(f) if (!(f))    error(#f)

// stringify a MACRO
#define STR_EXPAND(tok) #tok
#define STR(tok) STR_EXPAND(tok)

///////////////////////////////////////////////////////
// prototype for *.*.h
//
// int argc, char *argv[] : from main
// char* dev: path to fd feeding the script, /dev/fd/n
// char** shell: returns name of shell to run
// char*** rargv: return new argv for execv
//
// return <0 on failure
int mkargs(
  int argc, char *argv[], char* dev,
  char** shell, char*** rargv
);

///////////////////////////////////////////////////////
// internal common code for mkargs
// xargc includes NULL: xargv = {"z", ..., NULL}
// returns new argv array for excecv
//
char** mkargs_(int const argc, char * argv[], char* const dev,
               size_t const xargc, char** const xargv)
{
    // copy all argv including NULL
    // all xargv and replace NULL with dev
    char** const nargv
        = malloc(sizeof(char**) * (argc + 1 + xargc));
    char** argvi = argv;
    char** nargvi = nargv;
    char** xargvi = xargv;

    AE(nargv);
    
    *(nargvi++) = *(argvi++); // argv[0]
    while (*xargvi) { // copy xtra-argv
        *(nargvi++) = *(xargvi++);
    }
    *(nargvi++) = dev; // add dev (NULL in xargv)

    while (*argvi) { // add argv[1..]
        *(nargvi++) = *(argvi++);
    }
    *nargvi = NULL; // add NULL at end

    return nargv;
}

///////////////////////////////////////////////////////
// Macro for mkargs_
// adds sizeof array, means xargv MUST be char*[]
//
#define MKARGS(argc, argv, dev, xargv) \
    mkargs_(argc, argv, dev, sizeof(xargv)/sizeof(xargv[0]), xargv)

#endif
