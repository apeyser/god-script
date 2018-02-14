#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

#include SCRIPTFILE

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

extern char **environ;

void error(const char *s) {
    perror(s);
    exit(-1);
}

#define ERROR(f) if ((f) < 0) error(#f)
#define AE(f) if (!(f)) error(#f)

char** cleanenv() {
    char** ret = NULL;
    size_t retlen = 0;
    char* tok;
    size_t toks;
    char* const savevars = strdup(SAVEVARS);
    AE(savevars);

    toks = 0;
    tok = strtok(savevars, ":");
    while (tok) {
        const int toklen = strlen(tok);
        char** env;
        
        for (env = environ; *env; env++) {
            char* const envstr = strdup(*env);
            AE(envstr);
            
            if (! strncmp(tok, envstr, toklen)
                && envstr[toklen] == '=')
            {
                retlen += sizeof(char*);
                AE(ret = realloc(ret, retlen));
                ret[toks++] = envstr;
                break;
            }
        }
        tok = strtok(NULL, ":");
    }

    retlen += sizeof(char*);
    AE(ret = realloc(ret, retlen));
    ret[toks] = NULL;

    return ret;
}

char *const *mkargs(int argc, char *argv[]) {
    const size_t extra = 4;
    const size_t nargc = argc+extra;
    char* *nargv;
    size_t i;
    
    AE(nargv = malloc((nargc+1)*sizeof(char**)));
    i = 0;
    nargv[i++] = argv[0];
    nargv[i++] = "--noprofile";
    nargv[i++] = "--norc";
    nargv[i++] = "-s";
    nargv[i++] = "--";
    
    for (i = 1; i < argc+1; i++)
        nargv[i+extra] = argv[i];

    return nargv;
}

void reader(int rd, int wr, int argc, char* argv[]) {
    pid_t f;
    
    ERROR(f = fork());
    if (f > 0) return;
    
    ERROR(setuid(geteuid()));
    ERROR(close(wr));
    ERROR(dup2(rd, 0));
    ERROR(close(rd));

    environ = cleanenv();
    ERROR(execv("/bin/bash", mkargs(argc, argv)));
}

void writer(int rd, int wr) {
    ERROR(seteuid(getuid()));
    ERROR(close(rd));
    ERROR(write(wr, SCRIPTVAR, SCRIPTVARLEN));
    ERROR(close(wr));
}

int main(int argc, char* argv[]) {
    int fd[2];
    int wstatus;

    ERROR(pipe(fd));

    reader(fd[0], fd[1], argc, argv);
    writer(fd[0], fd[1]);
    ERROR(wait(&wstatus));

    if (WIFEXITED(wstatus))
        return WEXITSTATUS(wstatus);

    return -1;
}
