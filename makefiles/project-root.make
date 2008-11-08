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

include makefiles/functions.make
include makefiles/templates.make
include makefiles/directory.make

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
	@echo '# junk = $(junk)'
	@$(foreach d, $(DIRS), \
            echo 'rm -f [junk in $(subst ./,,$d)]'; \
            rm -f $(subst ./,,$(foreach x, $(junk), $d/$x));)

# C source dependency generation.
.%.d %/.%.d: %.c
	@rm -f "$@"
	@$(CC) -M -MP -MT '$*.o $@' -MF $@ $(CPPFLAGS) $< || rm -f "$@"

-include $(join $(dir $(CFILES)), $(patsubst %.c, .%.d, $(notdir $(CFILES))))
