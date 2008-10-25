# caller is the makefile that included rules.mk.
# d is the directory where caller lives.
caller := $(lastword $(filter-out makefiles/toplevel.mk makefiles/rules.mk, \
                                  $(MAKEFILE_LIST)))
     d := $(dir $(caller))
# $(info From $(caller))

# Evaluate to verify that a make variable is defined simply (nonrecursively).
define assert_simple
 ifeq "$$(flavor $1)" "recursive"
   $$(error $1 is defined recursively in $$(caller).  Use := )
 endif
endef

# Verify that module variables are nonrecursive.
module_vars := dirs programs libs
$(foreach v, $(module_vars), $(eval $(call assert_simple, $v)))

# Collect the subdirectories and targets.
    DIRS += $(dirs:%=$d%)
PROGRAMS += $(programs:%=$d%)
    LIBS += $(libs:%=$d%.$(libext))

# Template for a program.
define program_template
 $$(eval $$(call assert_simple, $(1)_cfiles))
 $$(eval $$(call assert_simple, $(1)_libs))
 $(2)_cfiles := $$($(1)_cfiles:%=$d%)
 $(2)_ofiles := $$($(2)_cfiles:.c=.o)
   $(2)_libs := $$($(1)_libs:=.$(libext))
      CFILES += $$($(2)_cfiles)
 $(2): $$($(2)_ofiles) $$($(2)_libs)
	$$(strip $$(LINK.o) $$^ $$($(2)_ldlibs) $$(LDLIBS) -o $$@)
endef

# Template for a library.
define lib_template
 $(2)_cfiles := $$($(1)_cfiles:%=$d%)
 $(2)_ofiles := $$($(2)_cfiles:%.c=%.o)
      CFILES += $$($(2)_cfiles)
 vpath $(1).$$(libext) $$(dir $2)
 ifeq "$$(libtype)" "static"
  $(2).a: $$($(2)_ofiles)
	$$(AR) crv $$@ $$?
 else ifeq "$$(libtype)" "dynamic"
  $(2).so: $$($(2)_ofiles)
	$$(CC) -shared $$(LDFLAGS) $$(TARGET_ARCH) $$? -o $$@
 endif
endef

$(foreach p, $(programs), $(eval $(call program_template,$p,$d$p)))
$(foreach l, $(libs),     $(eval $(call     lib_template,$l,$d$l)))

# Reset the module variables and import each subdirectory's makefile.

   _dirs := $(dirs)
    dirs :=
programs :=
    libs :=

include $(_dirs:%=$d%/module.mk makefiles/rules.mk)
