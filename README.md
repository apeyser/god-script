# god-script
Compile a script into an executable image to run as setuid

Remember: this is all very bad to do, like filling your code with `goto`s or using plain words as your password.

In fact, forget that you've even seen this repo.

## Getting started
Linux doesn't like setuid scripts, unlike BSD etc. So, we implement something similar to the BSD treatment of setuid scripts for Linux
* A script is placed in an executable
* That executable is setuid
* The executable forks an interpreter
* and it dumps the script through /dev/fd/? into the interpreter to execute
* The environment is also sanitized

### Prerequisites
* GNU Make (specifically -- overly baroque Makefile)
* C compiler (any plain old-fashioned C)
* xxd (vim-common)
* install (coreutils)
* Bash, Python3, any other script interpreters you'd like to add

### Installing

```bash
make -f ${srcdir}/Makefile
sudo make -f ${srcdir}/Makefile install prefix=${prefix}/
```

For each script `${executable}.${ext}`, an executable `${executable}` is created which is setuid and ultimately runs the embedded script `${executable}.${ext}`.
By embedded, I mean it's a string embedded in the executable dumped through a file-descriptor into the proper interpreter, which has been run with the current uid, euid and with the environmental variables cleared, plus selected flags to the interpreter (`-p` for bash, `-s` for python, ..)

Works out of source directory (inferred from location of Makefile)

There are targets:
* `all` (calls `exec`)
* `exec`
* `install`
* `clean`
* `distclean` (call `clean`)
* `docs`

For every executable, there exists a target `${executable}.{exec,clean,install,distclean}` which handles that operation for `${executable}`.

### Adapting
Because of course the point is to adapt the system and not to use the random scripts here

* Write a script using **bash**, **python3** or another interpreter **x**
* For **bash**, in `Makefile`
  * Add script to `SHSRC` variable in Makefile
    * script goes in `scripts/${executable}.sh`
  * If environmental variables need to be preserved add:
     ```make
     $(executablename): SAVEVARS=VAR1:VAR2:...
     ```
  * See `scripts/tester.sh` for clues to UID, EUID, ...
* For **python3**, in `Makefile`
  * Add script to `PYSRC` variable in Makefile
    * script goes in `scripts/${executable}.py`
  * If environmental variables need to be preserved add:
     ```make
     $(executablename): SAVEVARS=VAR1:VAR2:...
     ```
  * See `scripts/pytester.py` for clues to UID, EUID, ..
* For another interpreter (interpreter **`x`**)
  * Copy bash.h to `${x}.h`
  * Adapt `${x}.h` to your own interpreter
    * Update `mkargs` function and `xargv` string array
      * Set `*shell` to complete path to interpreter (`/usr/bin/x`)
      * Set `xargv` to arguments to interpreter that precede the script name and arguments
        * For example, `shell=/bin/bash`, `xargv = {-p, --, NULL}` or `shell=/usr/bin/python3`, `xargv - {-s, --, NULL}`
        * The template function will put in `/dev/fd/$n` for the piped script and then the rest of the arguments
    * ... Or you can complete replace `mkargs` with your own code for constructing the command line to `execv`
   * Adapt Makefile to interpreter
     * Add variable for the script types (`$(X)SRC`, `$(X)EXEC`, `EXECS += $(X)EXECS`, `SRCS += $(X)SRCS`)
     * Add dependency for the type:
       ```make
       $(($X)EXEC): %: suider.c ${x}.h %.$(ext).h suider.h Makefile
         $(call BUILD,$(word 1,$^),$(word 2, $^),$(word 3,$^))
       ```
       where you need to collapse the `X`, `x` and `ext` references
  * Add script to $(X)SRC
  * If environmental variables need to be preserved add to Makefile:
    ```make
    $(executablename): SAVEVARS=VAR1:VAR2:...
    ```
  * See included scripts for examples
  
### Comments
These programs avoid the most obvious security issues with setuid scripts.

There is no race condition between starting the script and the interpreter: the script is fixed inside the executable and gets transferred through an unnamed unix pipe (using the /dev/fd/ directory for Linux) into the interpreter (a la BSD).

The environment is cleaned up: all environmental variables are removed before starting the interpreters, except for compile-time determined environmental variables. No `LD_LIBRARY_PATH` unless you decide to put it in the Makefile.

The interpreter is sanitized as much as can be done easily: '-p' for bash, '-s' for python, same should be done for other interpreters.

Of course -- all the paths in your script should be absolute!<br />
You should be careful!<br/>
Sanitze inputs!<br />
Give up EUID == 0 as soon as you can!<br />
**In fact, don't do this at all!**
  
## Authors
* **Alex Peyser** - *Initial work* - [apeyser](https://github.com/apeyser)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the 2-Clause BSD License - see the [LICENSE.md](LICENSE.md) file for details

