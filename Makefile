###################################################
# Parameters                                      #
###################################################

CHMODFL = 4711
CHOWN_USER = root
XXD = xxd -i
INSTALL = install

# others:
# VPATH =
# prefix =

# And our executables
EXECS = tester restart-pointer

###################################################
# default all                                     #
###################################################
.PHONY: all
all: exec

###################################################
# Header build deps                               #
###################################################

define XXDCMD
{ echo 'unsigned char script[] = {' && $(XXD) && echo '};' ; }<$< >$@
endef

HEADERS = $(EXECS:%=%.sh.h)
$(HEADERS): %.sh.h: %.sh; $(XXDCMD)

###################################################
# executable build deps                           #
###################################################

$(EXECS): %: suider.c %.sh.h bash.h
	@echo "Preserving environmental variables for $@: $(SAVEVARS)"
	$(CC) $(CPPFLAGS) $(CFLAGS)	 	\
		-include "$(@D)/$*.sh.h" 	\
		-include "$(<D)/bash.h" 	\
		-DSAVEVARS=$(SAVEVARS) 		\
		-o $@ $<

###################################################
# executable flags                                #
###################################################

tester: SAVEVARS=EDITOR
restart-pointer: SAVEVARS=DISPLAY:XAUTHORITY:USER

###################################################
# Boiler function                                 #
###################################################

# STAGE target-name
#
# stage-name += $(EXECS:%=%.stage-name)
# .PHONY: stage-name $(stage-name)
# stage-name: $(stage-name)
#
# Needed:
# $(stage-name): %.stage-name: dependency
#     tool
#
# Can add other dependencies:
# stage-name: other-deps
#
define STAGE =
$(1) += $$(EXECS:%=%.$(1))
.PHONY: $(1) $$($(1))
$(1): $$($(1))
endef

###################################################
# Boiler plate for exec, clean, intall, distclean #
###################################################

# initialization for stages
clean = $(HEADERS:%=%.clean)
distclean: clean

# stages
stages = exec clean install distclean
$(foreach stage,$(stages),$(eval $(call STAGE,$(stage))))

# stage definitions
EXECCMD =
$(exec): %.exec: % ; $(EXECCMD)

CLEANCMD = rm -f "$*"
$(clean): %.clean: ; $(CLEANCMD)

INSTALLCMD = $(INSTALL) -D -o $(CHOWN_USER) -m $(CHMODFL) "$*" "$(DESTDIR)$(prefix)$*"
$(install): %.install: % ; $(INSTALLCMD)

DISTCLEANCMD = rm -f "$(DESTDIR)$(prefix)$*"
$(distclean): %.distclean: ; $(DISTCLEANCMD)

#.SECONDARY:
