#define _WIN32_WINNT 0x0600 
#include <windows.h>
#include <stdint.h>
#include <stdlib.h>
#include <stanza.h>

//Return a value from the windows registry.
STANZA_EXPORTED_SYMBOL char* windows_get_registry (uint64_t key, char* sub_key, char* value) {
  //Allocate an initial guess of 512 bytes for storing the registry key.
  uint64_t sz = 512;
  void* buf = malloc(sz);

  //Fill the allocated buffer with the string read from the registry.
  //The function returns ERROR_MORE_DATA if the buffer was not large enough to store the string.
  uint64_t flags = REG_SZ | REG_EXPAND_SZ;
  LSTATUS status = RegGetValueA((HKEY)key, sub_key, value, flags, NULL, buf, (DWORD*)&sz);
  if (status == ERROR_MORE_DATA) {
    //If the buffer was not large enough, then allocate the true amount of memory
    //needed and read the string again.
    buf = realloc(buf, sz);
    status = RegGetValueA((HKEY)key, sub_key, value, flags, NULL, buf, (DWORD*)&sz);
  }

  //If there was an error in reading the string, then return null.
  if (status) {
    free(buf);
    return NULL;
  }

  //Otherwise, return the string.
  return buf;
}

//Set a value in the windows registry.
STANZA_EXPORTED_SYMBOL uint32_t windows_set_registry (uint64_t key, char* sub_key, char* value, char* data, uint64_t num_bytes) {
  return RegSetKeyValueA((HKEY)key, sub_key, value, REG_SZ, data, (DWORD)num_bytes);
}
