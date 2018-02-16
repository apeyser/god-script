##################################################
#  Copyright 2018 Alexander Peyser
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
####################################################

###################################################
# Set paths                                       #
###################################################

srcdir = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VPATH = $(srcdir)

builddir = $(CURDIR)
$(info $$srcdir is [$(srcdir)])
$(info $$builddir is [$(builddir)])

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
SHSRC = scripts/tester.sh scripts/restart-pointer.sh
SHEXEC = $(SHSRC:scripts/%.sh=%)
PYSRC = scripts/pytester.py
PYEXEC = $(PYSRC:scripts/%.py=%)

SRCS = $(SHSRC) $(PYSRC)
EXECS = $(SHEXEC) $(PYEXEC)

# And default variables
CFLAGS = -g -Wall

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

HEADERS = $(SRCS:scripts/%=%.h)
$(HEADERS): %.h: scripts/% Makefile; $(XXDCMD)

###################################################
# executable build deps                           #
###################################################

# BUILD suider.c script-header xxd-header
define BUILD
@echo "Preserving environmental variables for $@: $(SAVEVARS)"
$(CC) $(CPPFLAGS) $(CFLAGS)	\
	-include "$(3)"	 	\
	-include "$(2)" 	\
	-DSAVEVARS=$(SAVEVARS) 	\
	-o $@ "$(1)"
endef

$(SHEXEC): %: suider.c bash.h %.sh.h suider.h Makefile
	$(call BUILD,$(word 1,$^),$(word 2,$^),$(word 3,$^))

$(PYEXEC): %: suider.c python.h %.py.h suider.h Makefile
	$(call BUILD,$(word 1,$^),$(word 2,$^),$(word 3,$^))

###################################################
# executable flags                                #
###################################################

tester: SAVEVARS=EDITOR:XXD:WINDOWID
restart-pointer: SAVEVARS=DISPLAY:XAUTHORITY:USER
pytester: SAVEVARS=EDITOR:XXD:WINDOWID

###################################################
# markdown                                        #
###################################################

README.html: README.md
	markdown $< >$@

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
define STAGE
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

.PHONY: docs
docs: README.html

#.SECONDARY:
