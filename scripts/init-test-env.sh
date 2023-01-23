rm -r testscratch
mkdir -p testscratch/patrick
export DYLD_LIBRARY_PATH="$PWD/bin/dylibs"
export HOME="$PWD/testscratch/patrick"
export ENABLE_DEBUGENV=""
export INTERCEPT_STANZA_URL="/Users/patricksli/Docs/Programming/stanzasite/resources/stanza"
export INTERCEPT_STANZAENV_URL="$PWD/build/outputs"
