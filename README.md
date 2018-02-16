# god-script
Compile a script into an executable image to run as setuid

## Getting started
Linux doesn't like setuid scripts, unlike BSD etc. So, we implement something similar to the BSD treatment of setuid scripts for Linux
* A script is placed in an executable
* That executable is setuid
* The executable forks an interpreter
* and it dumps the script through /dev/fd/? into the interpreter to execute
* The environment is also sanitized

### Prerequisites
* GNU Make
* C compiler
* XDD
* install
* Bash, Python, any other script interpreters you'd like to add

### Installing
```
make
sudo make install prefix=${prefix}/bin
```

For each script ${name}.${ext}, an executable ${name} is created which is setuid and ultimately runs the embedded script ${name}.${ext}. By embeded, I mean it's a string embedded in the executable dumped through a file-descriptor into the proper interpreter, which has been run with the current uid, euid and with the environmental variables cleared, plus selected flags to the interpreter (-p for bash, -s for python, ..)

### Adapting
Because of course the point is to adapt the system and not to use the random scripts here

* Write a script using bash, python3 or another interpreter
* For bash, in Makefile
  * Add script to SHSRC
  * If environmental variables need to be preserved add:
     ```
     $(executablename): SAVEVARS=VAR1:VAR2:...
     ```
  * See tester.sh for clues to UID, EUID, ...
* For python3, in Makefile
  * Add script to PYSRC
  * If environmental variables need to be preserved add:
     ```
     $(executablename): SAVEVARS=VAR1:VAR2:...
     ```
  * See pytester.py for clues to UID, EUID, ..
* For another interpreter
  * Copy bash.h to ${interpreter}.h
  * Adapt to your own interpreter
    * Set *shell to complete path to interpreter 
    * Set xargv to arguments to interpreter that precede the script name and arguments
      * For example, `shell=/bin/bash`, `xargv = {-p, --, NULL}` or `shell=/usr/bin/python3`, `xargv - {-s, --, NULL}`
   * Adapt Makefile to interpreter
     * Add variable for the script types ($(X)SRC, $(X)EXEC, EXECS += $(X)EXECS, SRCS += $(X)SRCS)
     * Add dependency for the type:
     ```
     $(($X)EXEC: %: suider.c ${interpreter}.h %.$(ext).h suider.h Makefile
       $(call BUILD,$(word 1,$^),$(word 2, $^),$(word 3,$^))
     ```
  * Add script to $(X)SRC
  * If environmental variables need to be preserved add to Makefile:
  ```
  $(executablename): SAVEVARS=VAR1:VAR2:...
  ```
  * See included scripts for examples
  
## Authors
* **Alex Peyser** - *Initial work* - [apeyser](https://github.com/apeyser)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the 2-Clause BSD License - see the [LICENSE.md](LICENSE.md) file for details

