mkdir -p bin/dylibs
gcc src/lib-curl/curl.c -lcurl -shared -o bin/dylibs/curl.so -fPIC
