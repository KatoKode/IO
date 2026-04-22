/*------------------------------------------------------------------------------
    IO Implementation in x86_64 Assembly Language with C Interface
    Copyright (C) 2026  J. McIntosh

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
------------------------------------------------------------------------------*/
#include "main.h"

int main (int argc, char **argv)
{
  signal(SIGINT, sighandler);

  char path[PATH_MAX + 8];

  if (argc < 2) {
    printf("usage: demo <path>\n");
    return -1;
  }

  strncpy(path, argv[1], PATH_MAX);

  // create file

  int flags = (O_CREAT | O_DIRECT | O_RDWR | O_DSYNC | O_TRUNC);
  mode_t mode = (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

  int fd;
  if ((fd = io_creat(path, flags, mode)) < 0) {
    printf ("io_creat errno: %d\n", errno);
    return -1;
  }

  printf ("fd: %d\n", fd);

  // get recommended file transfer buffer alignment (in bytes) for the file
  // associated with file descriptor fd

  long rec_xfer_align = fpathconf (fd, _PC_REC_XFER_ALIGN);

  // allocate memory aligned buffer

  char *buffer;
#if (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600)
  if (posix_memalign((void**)&buffer, rec_xfer_align, MAX_BUF_SIZE) != 0)
    return -1;

  (void) memset(buffer, 0, MAX_BUF_SIZE);
#elif (_ISOC11_SOURCE)
  buffer = aligned_alloc(rec_xfer_align, MAX_BUF_SIZE);

  if (buffer == NULL) return -1;

  (void) memset(buffer, 0, MAX_BUF_SIZE);
#else
#error missing both routines: posix_memalign() and aligned_alloc()
#endif

  // populate the buffer with integers from 0..9999 in text format on 16-byte
  // boundaries ex: 0...............1...............2 . . . 9999............

  off_t off = 0;
  ssize_t nbyte;
  for (size_t i = 0; i < DATA_TOTAL; ++i)
  {
    nbyte = (size_t)snprintf(&buffer[off], 8, "%lu", i);

    off += nbyte;

    off += 16 - nbyte;
  }

  // align file size to a multiple of rec_xfer_align

  nbyte = ((off + rec_xfer_align - 1) / rec_xfer_align) * rec_xfer_align;

  // write buffer contents out to disk

  off = 0;
  ssize_t nwritten;
  if ((nwritten = io_pwrite(fd, buffer, nbyte, off)) < 0) {
    printf ("io_pwrite errno: %d\n", errno);
    return -1;
  }

  // sync contents and metadata to disk

  if (io_sync(fd) < 0)
  {
    printf ("io_sync errno: %d\n", errno);
    return -1;
  }

  // close file associated with file descripter fd

  if (io_close(fd) < 0)
  {
    printf ("io_close errno: %d\n", errno);
    return -1;
  }

  // zero out buffer

  (void) memset(buffer, 0, MAX_BUF_SIZE);

  // open file

  flags = (O_DIRECT | O_RDWR | O_DSYNC);

  if ((fd = io_open(path, flags)) < 0) {
    printf ("io_open errno: %d\n", errno);
    return -1;
  }

  printf ("fd: %d\n", fd);

  // fstat file associated with file descriptor fd

  struct stat st;
  if (fstat(fd, &st) < 0) {
    printf ("fstat errno: %d\n", errno);
    return -1;
  }

  // read file contents into buffer

  off = 0;
  ssize_t nread;
  if ((nread = io_pread(fd, buffer, st.st_size, off)) < 0) {
    printf ("io_pread errno: %d\n", errno);
    return -1;
  }

  printf ("nread: %lu st.st_size: %lu\n", nread, st.st_size);

  // output integers from buffer

  nbyte = 1;
  char str[16];
  size_t total = 10;
  for (size_t i = 0; i < DATA_TOTAL; ++i)
  {
    if (i >= total)
    {
      ++nbyte;
      total *= 10;
    }

    for (nread = 0; nread < nbyte; ++nread) {
      str[nread] = buffer[off + nread];
    }

    str[nread] = '\0';

    printf("nread: %ld  str: %-4s\n", nread, str);

    off += nread;

    off += 16 - nread;
  }

  // close file

  if (io_close(fd) < 0)
  {
    printf ("io_close errno: %d\n", errno);
    return -1;
  }

  free(buffer);

  return 0;
}

void sighandler (int sig)
{
  printf("caught signal %u\n", sig);
}
