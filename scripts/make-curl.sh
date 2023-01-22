mkdir -p bin/dylibs
gcc src/lib-curl/curl.c -lcurl -dynamiclib -o bin/dylibs/libcurlbindings.dylib -fPIC
