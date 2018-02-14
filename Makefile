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
	$(XXD) $< $@

SCRIPTVAR=$(subst -,_,$*)_sh
%: suider.c %.sh.h
	@echo "Preserving environmental variables for $@: $(SAVEVARS)"
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-DSCRIPTFILE=\"$*.sh.h\" \
		-DSCRIPTVAR=$(SCRIPTVAR) \
		-DSCRIPTVARLEN=$(SCRIPTVAR)_len \
		-DSAVEVARS=\"$(SAVEVARS)\" \
		-o $@ $<
	$(CHOWN) $(CHOWN_USER) $@
	$(CHMOD) $(CHMODFL) $@
	@echo

tester: SAVEVARS=EDITOR
restart-pointer: SAVEVARS=DISPLAY:XAUTHORITY:USER

EXECS = tester restart-pointer
all: $(EXECS)
clean: ; rm -f $(EXECS)

.SECONDARY:
