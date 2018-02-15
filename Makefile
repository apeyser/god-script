all:

EXECS = tester restart-pointer
CHMODFL = 4711
CHOWN_USER = root
XXD = xxd -i

.SUFFIXES:           # Delete the default suffixes
.SUFFIXES: .sh .sh.h .c # Define our suffix list
%: %.sh

%.sh.h: %.sh
	$(XXD) -i $< $@

VAR=$(subst -,_,$*)
$(EXECS): %: suider.c %.sh.h
	@echo "Preserving environmental variables for $@: $(SAVEVARS)"
	$(CC) $(CPPFLAGS) $(CFLAGS)	 	\
		-D$(VAR)_sh=script		\
		-include "$*.sh.h" 		\
		-include "bash.h" 		\
		-DSAVEVARS=$(SAVEVARS) 		\
		-o $@ $<

tester: SAVEVARS=EDITOR
restart-pointer: SAVEVARS=DISPLAY:XAUTHORITY:USER

.PHONY: all
all: exec

.PHONY: exec
exec: exec.loop

exec = $(EXECS:%=%.exec)
.PHONY: exec.loop $(exec)
exec.loop: $(exec)
$(exec): %.exec: %
	@echo "Executable: $*"

.PHONY: clean
clean: clean.loop

clean = $(EXECS:%=%.clean)
.PHONY: clean.loop $(clean)
clean.loop: $(clean)
$(clean): %.clean:
	rm -rf "$*"

.PHONY: install
install: install.loop

install = $(EXECS:%=%.install) 
.PHONY: install.loop $(install)
install.loop: $(install)
$(install): %.install: %
	install -D -o $(CHOWN_USER) -m $(CHMODFL) "$*" "$(DESTDIR)$(prefix)/$*"

.PHONY: distclean
distclean: clean distclean.loop

distclean = $(EXECS:%=%.distclean)
.PHONY: distclean.loop $(distclean)
distclean.loop: $(distclean)
$(distclean): %.distclean:
	rm -f "$*" "$(DESTDIR)$(prefix)/$*"

#.SECONDARY:
