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
