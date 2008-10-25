# -*-makefile-*-

CPPFLAGS := -Iinclude

# Will we build static or dynamic libraries?

 libtype ?= dynamic
ifeq "$(libtype)" "static"
  libext := a
else ifeq "$(libtype)" "dynamic"
  libext := so
else
 $(error unknown libtype "$(libtype)")
endif

    DIRS := . makefiles
PROGRAMS :=
    LIBS :=
   TESTS :=

include makefiles/rules.mk

# Ways to make this more complicated:
#   per-target rules, variables, and overrides.
#   implement BUILD/HOST/TARGET split.
#   optionally split SRCDIR and OBJDIR.

# XXX rename foo_cfiles to foo_sources, split into C and C++.
# XXX auto-distinguish C vs C++ link steps.
# XXX document include file locations. (./include)
# XXX automatically create Makefile in subdirectories.
# XXX rename module.mk to Module.make.
# XXX could derive the location of mkrules from the path to toplevel...
# XXX install rules?

.PHONY: default help all test tests build programs libs clean

help:
	@echo 'Common Targets'
	@echo '    all (default) - build everything, run all tests'
	@echo '    test          - run all tests'
	@echo '    build         - build everything'
	@echo '    programs      - build all programs'
	@echo '    libs          - build all libraries'
	@echo '    tests         - build all tests'
	@echo '    clean         - remove generated files'
	@echo ''
	@echo 'Individual Programs'
	@$(foreach p, $(PROGRAMS), echo '    $(patsubst ./%,%,$p)';)
	@echo ''
	@echo 'Individual Libraries'
	@$(foreach l, $(LIBS),     echo '    $(patsubst ./%,%,$l)';)
	@echo ''
	@echo 'Individual Tests'
	@$(foreach t, $(TESTS),    echo '    $(patsubst ./%,%,$t)';)
	@echo ''

all:	build test

test:
	@$(foreach t, $(TESTS), \
	    echo 'Test $t'; \
	    $t;)

build:	libs programs tests

programs: $(PROGRAMS)

libs:	$(LIBS)

tests:	$(TESTS)

junk := *~ *.o *.so *.a .*.d a.out core
clean:
	rm -f $(patsubst ./%,%,$(PROGRAMS))
	rm -f $(patsubst ./%,%,$(LIBS))
	rm -f $(patsubst ./%,%,$(TESTS))
	@$(foreach d, $(DIRS), \
            echo 'rm -f [junk in $(subst ./,,$d)]'; \
            rm -f $(subst ./,,$(foreach x, $(junk), $d/$x));)

# C source dependency generation.
.%.d %/.%.d: %.c
	@rm -f "$@"
	@$(CC) -M -MP -MT '$*.o $@' -MF $@ $(CPPFLAGS) $< || rm -f "$@"

-include $(join $(dir $(CFILES)), $(patsubst %.c, .%.d, $(notdir $(CFILES))))
