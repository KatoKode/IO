#ifndef IO_H
#define IO_H

#include <unistd.h>
#include <sys/types.h>
#include <errno.h>

int io_close (int);
int io_creat (char const *, int, mode_t);
int io_data_sync (int);
off_t io_lseek (int, off_t, int);
int io_open (char const *, int);
int io_pread (int, void *, size_t, off_t);
int io_pwrite (int, void const *, size_t, off_t);
int io_read (int, void *, size_t);
int io_sync (int);
int io_write (int, void const *, size_t);

#endif
