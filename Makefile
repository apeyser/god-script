all:

CHMODFL=u+s
CHMOD=sudo chmod
CHOWN=sudo chown
CHOWN_USER=root
XXD=xxd -i

.SUFFIXES:           # Delete the default suffixes
.SUFFIXES: .sh .sh.h .c # Define our suffix list
%: %.sh

%.sh.h: %.sh
	$(XXD) -i $< $@

VAR=$(subst -,_,$*)
%: suider.c %.sh.h
	@echo "Preserving environmental variables for $@: $(SAVEVARS)"
	$(CC) $(CPPFLAGS) $(CFLAGS)	 	\
		-D$(VAR)_sh=script			\
		-include "$*.sh.h" 		\
		-include "bash.h" 		\
		-DSAVEVARS=$(SAVEVARS) 		\
		-o $@ $<
	$(CHOWN) $(CHOWN_USER) $@
	$(CHMOD) $(CHMODFL) $@
	@echo

tester: SAVEVARS=EDITOR
restart-pointer: SAVEVARS=DISPLAY:XAUTHORITY:USER

EXECS = tester restart-pointer
all: $(EXECS)
clean: ; rm -f $(EXECS)

#.SECONDARY:
