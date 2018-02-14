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

%: VAR=$(subst -,_,$*)
%: suider.c %.sh.h
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-DSCRIPTFILE=\"$*.sh.h\" \
		-DSCRIPTVAR=$(VAR)_sh \
		-DSCRIPTVARLEN=$(VAR)_sh_len \
		-o $@ $<
	$(CHOWN) $(CHOWN_USER) $@
	$(CHMOD) $(CHMODFL) $@

EXECS = tester restart-pointer
all: $(EXECS)

clean: ; rm -f $(EXECS)
