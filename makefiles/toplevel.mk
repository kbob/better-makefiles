# -*-makefile-*-

    DIRS := . makefiles
PROGRAMS :=
    LIBS :=

default:

include makefiles/rules.mk

# Ways to make this more complicated:
#   per-target rules, variables, and overrides.
#   implement BUILD/HOST/TARGET split.
#   optionally split SRCDIR and OBJDIR.

# XXX rename foo_cfiles to foo_sources.
# XXX auto-distinguish C vs C++ link steps.
# XXX make shared libraries instead of static.
# XXX make the shared/static decision parameterized.
# XXX document include file locations.
# XXX automatically create Makefile in subdirectories.

CPPFLAGS = -Iinclude

default:
	$(error Please select a target.  "make help" for suggestions)

help:
	@echo 'Common Targets'
	@echo '    all      - builds everything, runs all tests'
	@echo '    test     - runs all tests'
	@echo '    build    - builds everything'
	@echo '    libs     - builds all libraries'
	@echo '    programs - builds all programs'
	@echo '    clean    - removes generated files'
	@echo ''
	@echo 'Individual Programs'
	@$(foreach p, $(PROGRAMS), echo '    $(patsubst ./%,%,$p)';)
	@echo ''
	@echo 'Individual Libraries'
	@$(foreach l, $(LIBS),     echo '    $(patsubst ./%,%,$l)';)
	@echo ''

.PHONY: default help all test build libs programs clean
all:	build test
build:	libs programs
libs:	$(LIBS)
programs: $(PROGRAMS)
test:
	@echo -n "Testing..."
	@sleep 0.3
	@echo -n ' 1'
	@sleep 0.3
	@echo -n ' 2'
	@sleep 0.3
	@echo -n ' 3'
	@sleep 0.3
	@echo .

junk = *~ *.o .*.d a.out core
clean:
	rm -f $(patsubst ./%,%,$(PROGRAMS) $(LIBS))
	@$(foreach d, $(DIRS), \
            echo 'rm -f [junk in $(subst ./,,$d)]';)
	@$(foreach d, $(DIRS), \
            rm -f $(subst ./,,$(foreach x, $(junk), $d/$x));)

.%.d %/.%.d: %.c
	@rm -f "$@"
	@$(CC) -M -MP -MT '$*.o $@' -MF $@ $(CPPFLAGS) $< || rm -f "$@"

-include $(join $(dir $(CFILES)), $(patsubst %.c, .%.d, $(notdir $(CFILES))))
