CHMODFL=u+s
CHMOD=sudo chmod
CHOWN=sudo chown
CHOWN_USER=root
XXD=xxd -i

%.sh.h: %.sh
	$(XXD) $< $@

tester: suider.c tester.sh.h
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-DSCRIPTFILE=\"$@.sh.h\" \
		-DSCRIPTVAR=$@_sh \
		-DSCRIPTVARLEN=$@_sh_len \
		-o $@ $<
	$(CHOWN) $(CHOWN_USER) $@
	$(CHMOD) $(CHMODFL) $@
