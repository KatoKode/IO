/*------------------------------------------------------------------------------
    IO Implementation in x86_64 Assembly Language with C interface
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
