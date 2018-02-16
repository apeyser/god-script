/*************************************************
 *  Copyright 2018 Alexander Peyser
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ***************************************************/

#include "suider.h"

extern char **environ;

char** cleanenv() {
    char** ret = NULL;
    size_t retlen = 0;
    size_t retindex = 0;

    char* tok;
    char* const savevars = strdup(STR(SAVEVARS));
    AE(savevars);

    for (tok = strtok(savevars, ":");
         tok;
         tok = strtok(NULL, ":"))
    {
        const int toklen = strlen(tok);
        char** env;
        
        for (env = environ; *env; env++) {
            if (! strncmp(tok, *env, toklen)
                && (*env)[toklen] == '=')
            {
                AE(ret = realloc(ret, retlen += sizeof(char*)));
                ret[retindex++] = *env;
                break;
            }
        }
    }

    AE(ret = realloc(ret, retlen += sizeof(char*)));
    ret[retindex] = NULL;

    return ret;
}

void execute(int argc, char* argv[], int rd) {
    int devlen;
    char* dev;

    char** rargv; char* shell;
    
    E(devlen = snprintf(NULL, 0, "/dev/fd/%i", rd));
    AE(dev = malloc((devlen+1)*sizeof(char)));
    E(snprintf(dev, devlen+1, "/dev/fd/%i", rd));
    
    E(mkargs(argc, argv, dev, &shell, &rargv));
    environ = cleanenv();
    E(execv(shell, rargv));
}

// cleanenv && mkargs do not clean up memory allocations:
// an image swap will immediately follow
void reader(int rd, int wr, int argc, char* argv[]) {
    pid_t f;

    E(f = fork());
    if (f > 0) return;
    
    //E(setuid(geteuid())); // become only root   

    E(close(wr));
    execute(argc, argv, rd);
}

void writer(int rd, int wr) {
    E(seteuid(getuid())); // give up root

    E(close(rd));
    E(write(wr, script, sizeof(script)));
    E(close(wr));
}

int main(int argc, char* argv[]) {
    int fd[2];
    int wstatus;

    E(pipe(fd));

    reader(fd[0], fd[1], argc, argv);
    writer(fd[0], fd[1]);
    E(wait(&wstatus));

    if (WIFEXITED(wstatus))
        return WEXITSTATUS(wstatus);

    return -127; // core dump or such
}
