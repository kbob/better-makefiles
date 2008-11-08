# -*-makefile-*-

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


# Template for a test.
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
 include makefiles/directory.make
          d := $$(firstword $$(_dirstack))
  _dirstack := $$(wordlist 2, $$(words $$(_dirstack)), $$(_dirstack))
endef
