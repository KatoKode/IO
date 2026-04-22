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
#define _GNU_SOURCE
#include <unistd.h>
#include </usr/include/linux/limits.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "../io/io.h"

// defines you can modify
#define DATA_SIZE     16
#define DATA_TOTAL    1000000
#define MAX_BUF_SIZE  (DATA_SIZE * DATA_TOTAL)

void sighandler (int);
