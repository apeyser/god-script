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

all = $(EXECS:%=%.all)
.PHONY: all $(all)
all: $(all)
$(all): %.all: %
	@echo "Executable: $*"

clean = $(EXECS:%=%.clean)
.PHONY: clean $(clean)
clean: $(clean)
$(clean): %.clean:
	rm -rf "$*"

install = $(EXECS:%=%.install) 
.PHONY: install $(install)
install: $(install)
$(install): %.install: %
	install -D -o $(CHOWN_USER) -m $(CHMODFL) "$*" "$(DESTDIR)$(prefix)/$*"

#.SECONDARY:
