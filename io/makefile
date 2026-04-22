#-------------------------------------------------------------------------------
#   IO Implementation in x86_64 Assembly Language with C Interface
#   Copyright (C) 2026  J. McIntosh
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, write to the Free Software Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-------------------------------------------------------------------------------
# makefile for libio.o
CFLAGS   := -O3 -march=native -m64 -mno-avx512f -flto -Wall \
						-Werror=format-security -D_FORTIFY_SOURCE=2 \
						-fstack-protector-strong -fasynchronous-unwind-tables \
						-fexceptions -pipe

LDFLAGS  := -O3 -Wl,-z,relro -Wl,-z,now -Wl,-z,defs

ASMFLAGS := -Ox

.PHONY: all clean

all: libio.so

libio.so: io.ao io.o
	gcc $(LDFLAGS) -shared -o $@ $^

io.o: io.c
	gcc $(CFLAGS) -fPIC -c $< -o $@

io.ao: io.asm
	nasm $(ASMFLAGS) -f elf64 $< -o $@

clean:
	rm -f libio.so io.o io.ao
