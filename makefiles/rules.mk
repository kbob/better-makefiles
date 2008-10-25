# caller is the makefile that included rules.mk.
# d is the directory where caller lives.
         extra := makefiles/toplevel.mk makefiles/rules.mk
        caller := $(lastword $(filter-out $(extra), $(MAKEFILE_LIST)))
             d := $(dir $(caller))
# $(info From $(caller))

# Evaluate to verify that a make variable is defined simply (nonrecursively).
define assert_simple
 ifeq "$$(flavor $1)" "recursive"
   $$(error $1 is defined recursively in $$(caller).  Use := )
 endif
endef

# Change all dir/libfoo.{so,a} => -Ldir -lfoo; pass others unchanged.
define munge_prereqs
 $(foreach l, $(filter-out %.a %.so,$1), $l) \
 $(foreach l, $(filter %.a,$1), \
              $(patsubst lib%.a, -L$(dir $l) -l%, $(notdir $l))) \
 $(foreach l, $(filter %.so,$1), \
              $(patsubst lib%.so, -L$(dir $l) -l%, $(notdir $l)))
endef

# Verify that module variables are nonrecursive.
   module_vars := dirs programs libs tests
$(foreach v, $(module_vars), $(eval $(call assert_simple, $v)))

# Collect the subdirectories and targets.
          DIRS += $(dirs:%=$d%)
      PROGRAMS += $(programs:%=$d%)
          LIBS += $(libs:%=$d%.$(libext))
         TESTS += $(tests:%=$d%)

# Template for a program.
define program_template

 # Verify that foo_cfiles and foo_libs are nonrecursive.
 $$(eval $$(call assert_simple, $(1)_cfiles))
 $$(eval $$(call assert_simple, $(1)_libs))

   $(2)_cfiles := $$($(1)_cfiles:%=$d%)
   $(2)_ofiles := $$($(2)_cfiles:.c=.o)
     $(2)_libs := $$($(1)_libs:=.$(libext))
        CFILES += $$($(2)_cfiles)

 # foo's link rule
 $(2): $$($(2)_ofiles) $$($(2)_libs)
	$$(strip $$(LINK.o) $$(call munge_prereqs, $$^) \
                            $$($(2)_ldlibs) $$(LDLIBS) -o $$@)

endef

# Template for a library.
define lib_template

 # Verify that libfoo_cfiles is nonrecursive.
 $$(eval $$(call assert_simple, $(1)_cfiles))

   $(2)_cfiles := $$($(1)_cfiles:%=$d%)
   $(2)_ofiles := $$($(2)_cfiles:%.c=%.o)
        CFILES += $$($(2)_cfiles)

 vpath $(1).$$(libext) $$(dir $2)

 ifeq "$$(libtype)" "static"

  # libfoo's static link rule
  $(2).a: $$($(2)_ofiles)
	$$(AR) crv $$@ $$?

 else ifeq "$$(libtype)" "dynamic"

  export LD_LIBRARY_PATH = $$(dir $2):$(LD_LIBRARY_PATH)

  # libfoo's dynamic link rule
  $(2).so: $$($(2)_ofiles)
	$$(CC) -shared $$(LDFLAGS) $$(TARGET_ARCH) $$? -o $$@

 endif
endef

define test_template

 # Verify that testfoo_cfiles and testfoo_libs are nonrecursive.
 $$(eval $$(call assert_simple, $(1)_cfiles))
 $$(eval $$(call assert_simple, $(1)_libs))

   $(2)_cfiles := $$($(1)_cfiles:%=$d%)
   $(2)_ofiles := $$($(2)_cfiles:.c=.o)
     $(2)_libs := $$($(1)_libs:=.$(libext))
 $(2)_CPPFLAGS := $$($(1)_CPPFLAGS)
        CFILES += $$($(2)_cfiles)

 $(2):	$$($(2)_cfiles) $$($(2)_libs)
	$$(strip $$(LINK.c) $$($(2)_CPPFLAGS) \
			    $$(call munge_prereqs, $$^) \
	                    $$($(2)_ldlibs) $$(LDLIBS) -o $$@)

endef

# Template for a subdirectory.
define dir_template

 # Reset the module variables, then include the subdirectory's makefile.
       dirs :=
   programs :=
       libs :=
      tests :=
  _dirstack := $$d $$(_dirstack)
          d := $$d$1/
 include $$(d)Dir.make
 include makefiles/rules.mk
          d := $$(firstword $$(_dirstack))
  _dirstack := $$(wordlist 2, $$(words $$(_dirstack)), $$(_dirstack))
endef

# Expand the templates for all the programs, libs, tests, and dirs in
# this module.
$(foreach p, $(programs), $(eval $(call program_template,$p,$d$p)))
$(foreach l, $(libs),     $(eval $(call     lib_template,$l,$d$l)))
$(foreach t, $(tests),    $(eval $(call    test_template,$t,$d$t)))
$(foreach i, $(dirs),     $(eval $(call     dir_template,$i,$d$i)))
