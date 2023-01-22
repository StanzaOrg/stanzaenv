mkdir -p bin/dylibs
gcc src/sysutils.c -dynamiclib -o bin/dylibs/libsysutils.dylib -fPIC
