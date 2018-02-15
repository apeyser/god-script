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
%: suider.c %.sh.h
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
all: $(EXECS)

.PHONY: clean
clean: ; rm -f $(EXECS)

.PHONY: install
install: $(EXECS)
	[ -d "$(DESTDIR)$(prefix)" ] || mkdir -p "$(DESTDIR)$(prefix)"
	for exec in $(EXECS); do \
		install -o $(CHOWN_USER) -m $(CHMODFL) "$$exec" "$(DESTDIR)$(prefix)"; \
	done

#.SECONDARY:
