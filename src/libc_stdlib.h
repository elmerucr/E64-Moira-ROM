#ifndef LIBC_STDINT_H
#define LIBC_STDINT_H

#include "libc_stddef.h"

void *malloc(size_t bytes);
void *realloc(void *ptr, size_t size);
void free(void *ptr);

#endif
