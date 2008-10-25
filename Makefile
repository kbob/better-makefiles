            dirs := lib programs
        programs := buildtool
#        libtype := static

buildtool_cfiles := buildtool.c

default: all

include makefiles/toplevel.mk
