###################################################
# Parameters                                      #
###################################################

EXECS = tester restart-pointer
CHMODFL = 4711
CHOWN_USER = root
XXD = xxd -i
INSTALL = install

###################################################
# default all                                     #
###################################################
all:

.PHONY: all
all: exec

###################################################
# Clear suffixes                                  #
###################################################

.SUFFIXES:           # Delete the default suffixes
.SUFFIXES: .sh .sh.h .c # Define our suffix list
%: %.sh

###################################################
# Header build deps                               #
###################################################

%.sh.h: %.sh
	$(XXD) -i $< $@

###################################################
# executable build deps                           #
###################################################

VAR=$(subst -,_,$*)
$(EXECS): %: suider.c %.sh.h
	@echo "Preserving environmental variables for $@: $(SAVEVARS)"
	$(CC) $(CPPFLAGS) $(CFLAGS)	 	\
		-D$(VAR)_sh=script		\
		-include "$*.sh.h" 		\
		-include "bash.h" 		\
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
# stage-name = $(EXECS:%=%.stage-name)
#
# .PHONY: stage-name stage-name.loop $(stage-name)
# stage-name: stage-name.loop
# stage-name.loop: $(stage-name)
#
# Needed:
# $(stage-name): %.stage-name: dependency
#     tool
#
# Can add other dependencies:
# stage-name: other-deps
#
define STAGE =
$(1) = $$(EXECS:%=%.$(1))

.PHONY: $(1) $(1).loop $$($(1))
$(1): $(1).loop
$(1).loop: $$($(1))
endef

###################################################
# Boiler plate for exec, clean, intall, distclean #
###################################################

EXECCMD =
$(eval $(call STAGE,exec))
$(exec): %.exec: % ; $(EXECCMD)

CLEANCMD = rm -f "$*"
$(eval $(call STAGE,clean))
$(clean): %.clean: ; $(CLEANCMD)

INSTALLCMD = $(INSTALL) -D -o $(CHOWN_USER) -m $(CHMODFL) "$*" "$(DESTDIR)$(prefix)/$*"
$(eval $(call STAGE,install))
$(install): %.install: % ; $(INSTALLCMD)

DISTCLEANCMD = rm -f "$(DESTDIR)$(prefix)/$*"
$(eval $(call STAGE,distclean))
$(distclean): %.distclean: ; $(DISTCLEANCMD)
distclean: clean

#.SECONDARY:
