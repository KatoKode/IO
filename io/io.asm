; ──────────────────────────────────────────────────────────────────────────────
;   IO Implementation in x86_64 Assembly Language with C Interface
;   Copyright (C) 2026  J. McIntosh
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
; ──────────────────────────────────────────────────────────────────────────────
%ifndef IO_ASM
%define IO_ASM

extern __errno_location

; Mark the stack as non-executable
section .note.GNU-stack noalloc noexec nowrite progbits

; RIP-relative (Position Independent Code - PIC)
DEFAULT REL

%include "io.inc"

section .text

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   int io_close (int fd)
;
; param:
;
;   edi = fd
;
; return:
;
;   eax = 0 (success) | -1 (failure)
;
; stack:
;
;   DWORD [rbp - 8] = edi (fd)
; ──────────────────────────────────────────────────────────────────────────────

      global io_close:function

io_close:

; prologue

      push      rbp
      mov       rbp, rsp
      sub       rsp, 16
      mov       DWORD [rbp - 8], edi

; if (close(fd) == 0) {

      mov       edi, DWORD [rbp - 8]
      mov       rax, __NR_close
      syscall

;   return 0;

      test      rax, rax
      jz        .epilogue

; }
;   syscall does not set the errno
;   value when an error occurs.

      mov       rdi, rax
      call      set_errno

; return -1;

      mov       eax, -1

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   int io_creat (char const *path, int flags, mode_t mode)
;
; param:
;
;   rdi = path
;   esi = flags
;   edx = mode
;
; return
;
;   eax = file descriptor # (success) | -1 (failure)
;
; stack
;
;   QWORD [rbp - 8]   = rdi (path)
;   DWORD [rbp - 16]  = esi (flags)
;   DWORD [rbp - 24]  = edx (mode)
;
; NOTE: __NR_open is used to create a file instead of __NR_creat. This gives the
;       user the option of using O_WRONLY or O_RDWR.
; ──────────────────────────────────────────────────────────────────────────────

      global io_creat:function

io_creat:

; prologue
      push      rbp
      mov       rbp, rsp
      sub       rsp, 32
      mov       QWORD [rbp - 8], rdi
      mov       DWORD [rbp - 16], esi
      mov       DWORD [rbp - 24], edx

; do {

.loop:

;   int fd;
;   if ((fd = open(path, flags, mode)) >= 0)

      mov       rdi, QWORD [rbp - 8]
      mov       esi, DWORD [rbp - 16]
      mov       edx, DWORD [rbp - 24]
      mov       rax, __NR_open
      syscall

;     return fd;

      test      rax, rax
      jns       .epilogue

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

; } while (errno == EINTR);

      call      get_errno
      cmp       rax, EINTR
      je        .loop

; return -1;

      mov       eax, -1

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   int io_data_sync (int fd);
;
; param:
;
;   edi = fd
;
; return:
;
;   eax = 0 (success) | -1 (failure)
; ──────────────────────────────────────────────────────────────────────────────

      global io_data_sync:function

io_data_sync:

; do {

.loop:

      mov       rax, __NR_fdatasync
      syscall
      test      rax, rax
      jz        .epilogue

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

; } while (errno == EINTR);

      call      get_errno
      cmp       rax, EINTR
      je        .loop

; return -1;

      mov       eax, -1

.epilogue:

      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   off_t io_lseek (int fd, off_t offset, int whence)
;
; param:
;
;   edi = fd
;   rsi = offset
;   edx = whence
;
; return
;
;   rax = offset from beginning of file (success) | -1 (failure)
; ──────────────────────────────────────────────────────────────────────────────

      global io_lseek:function

io_lseek:

      mov       rax, __NR_lseek
      syscall
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   int io_open (char const *path, int flags)
;
; param:
;
;   rdi = path
;   esi = flags
;
; return
;
;   eax = file descriptor # (success) | -1 (failure)
;
; stack
;
;   QWORD [rbp - 8]   = rdi (path)
;   DWORD [rbp - 16]  = esi (flags)
; ──────────────────────────────────────────────────────────────────────────────

      global io_open:function

io_open:

; prologue

      push      rbp
      mov       rbp, rsp
      sub       rsp, 16
      mov       QWORD [rbp - 8], rdi
      mov       DWORD [rbp - 16], esi

; do {

.loop:

;   int fd;
;   if ((fd = open(path, flags)) >= 0)

      mov       rdi, QWORD [rbp - 8]
      mov       esi, DWORD [rbp - 16]
      xor       edx, edx
      mov       rax, __NR_open
      syscall

;     return fd;

      test      rax, rax
      jns       .epilogue

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

; } while (errno == EINTR);

      call      get_errno
      cmp       rax, EINTR
      je        .loop

; return -1;

      mov       eax, -1

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   ssize_t io_pread (int fd, void *buf, size_t nbyte, off_t offset)
;
; param:
;
;   edi = fd
;   rsi = buf
;   rdx = nbyte
;   rcx = offset
;
; return
;
;   rax = # of bytes read (success) | -1 (failure)
;
; stack
;
;   DWORD [rbp - 8]   = edi (fd)
;   QWORD [rbp - 16]  = rsi (buf)
;   QWORD [rbp - 24]  = rdx (nbyte)
;   QWORD [rbp - 32]  = rcx (offset)
;   QWORD [rbp - 40]  = (nread)
; ──────────────────────────────────────────────────────────────────────────────

      global io_pread:function

io_pread:

; prologue

      push      rbp
      mov       rbp, rsp
      sub       rsp, 48
      mov       DWORD [rbp - 8], edi
      mov       QWORD [rbp - 16], rsi
      mov       QWORD [rbp - 24], rdx
      mov       QWORD [rbp - 32], rcx

; ssize_t nread = 0;

      mov       QWORD [rbp - 40], 0

; do {

.do_while:

;   if ((n = pread(fd, &((char *)buf)[nread],
;           nbyte - nread, offset + nread)) < 0)
;   {
      mov       edi, DWORD [rbp - 8]    ; edi = fd
      mov       rsi, QWORD [rbp - 16]   ; rsi = buf
      mov       rax, QWORD [rbp - 40]   ; rax = nread
      add       rsi, rax                ; rsi = &buf[nread]
      mov       rdx, QWORD [rbp - 24]   ; rdx = nbyte
      sub       rdx, rax                ; rdx = nbyte - nread
      mov       r10, QWORD [rbp - 32]   ; r10 = offset
      add       r10, rax                ; r10 = offset + nread

      mov       rax, __NR_pread64
      syscall
      test      rax, rax
      jns       .else

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

;     if (errno != EINTR)

      call      get_errno
      cmp       rax, EINTR
      je        .end_if

;       return -1;

      mov       rax, -1
      jmp       .epilogue

.end_if:

;     errno = 0;

      call      clr_errno
      jmp       .end_if_else

;   } else {

.else:

;   if (n == 0) return nread  /* EOF */

      test      rax, rax
      jnz       .end_if_2
      mov       rax, [rbp - 40]
      jmp       .epilogue

.end_if_2:

;   nread += n;

      mov       rcx, QWORD [rbp - 40]
      add       rax, rcx
      mov       QWORD [rbp - 40], rax

;   }

.end_if_else:

; } while (nread < nbyte)

      mov       rax, QWORD [rbp - 40]
      mov       rcx, QWORD [rbp - 24]
      cmp       rax, rcx
      jae       .epilogue
      jmp       .do_while

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   ssize_t io_pwrite (int fd, void const *buf, size_t nbyte, off_t offset);
;
; param:
;
;   edi = fd
;   rsi = buf
;   rdx = nbyte
;   rcx = offset
;
; return:
;
;   rax = # of bytes read (success) | -1 (failure)
;
; stack:
;
;   DWORD [rbp - 8]   = edi (fd)
;   QWORD [rbp - 16]  = rsi (buf)
;   QWORD [rbp - 24]  = rdx (nbyte)
;   QWORD [rbp - 32]  = rcx (offset)
;   QWORD [rbp - 40]  = (nwritten)
;
; brief:  If syscall __NR_pwrite64 returns zero bytes written, then io_pwrite
;         will return -1 and errno will be set to EIO.
; ──────────────────────────────────────────────────────────────────────────────

      global io_pwrite:function

io_pwrite:

; prologue

      push      rbp
      mov       rbp, rsp
      sub       rsp, 48
      mov       DWORD [rbp - 8], edi
      mov       QWORD [rbp - 16], rsi
      mov       QWORD [rbp - 24], rdx
      mov       QWORD [rbp - 32], rcx

; ssize_t nwritten = 0;

      mov       QWORD [rbp - 40], 0

      call      clr_errno

; do {

.do_while:

;   if ((n = pwrite(fd, &((char *)buf)[nwritten],
;           nbyte - nwritten, offset + nwritten)) <= 0)
;   {
      mov       edi, DWORD [rbp - 8]    ; edi = fd
      mov       rsi, QWORD [rbp - 16]   ; rsi = buf
      mov       rax, QWORD [rbp - 40]   ; rax = nwritten
      add       rsi, rax                ; rsi = &buf[nwritten]
      mov       rdx, QWORD [rbp - 24]   ; rdx = nbyte
      sub       rdx, rax                ; rdx = nbyte - nwritten
      mov       r10, QWORD [rbp - 32]   ; r10 = offset
      add       r10, rax                ; r10 = offset + nwritten

      mov       rax, __NR_pwrite64
      syscall
      test      rax, rax
      js        .n_lt_zero
      jz        .n_eq_zero
      jmp       .else

.n_eq_zero:

      mov       rdi, EIO
      call      set_errno
      mov       eax, -1
      jmp       .epilogue

.n_lt_zero:

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

;     if (errno != EINTR)

      call      get_errno
      cmp       rax, EINTR
      je        .end_if_1

;       return -1;

      mov       eax, -1
      jmp       .epilogue

.end_if_1:

;     errno = 0;

      call      clr_errno
      jmp       .end_if_else

;   } else {

.else:

;   nwritten += n;

      mov       rcx, QWORD [rbp - 40]
      add       rax, rcx
      mov       QWORD [rbp - 40], rax

;   }

.end_if_else:

; } while (nwritten < nbyte);

      mov       rax, QWORD [rbp - 40]
      mov       rcx, QWORD [rbp - 24]
      cmp       rax, rcx
      jae       .epilogue
      jmp       .do_while

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   ssize_t io_read (int fd, void *buf, size_t nbyte)
;
; param:
;
;   edi = fd
;   rsi = buf
;   rdx = nbyte
;
; return
;
;   rax = # of bytes read (success) | -1 (failure)
;
; stack
;
;   DWORD [rbp - 8]   = edi (fd)
;   QWORD [rbp - 16]  = rsi (buf)
;   QWORD [rbp - 24]  = rdx (nbyte)
;   QWORD [rbp - 32]  = (nread)
; ──────────────────────────────────────────────────────────────────────────────

      global io_read:function

io_read:

; prologue

      push      rbp
      mov       rbp, rsp
      sub       rsp, 32
      mov       DWORD [rbp - 8], edi
      mov       QWORD [rbp - 16], rsi
      mov       QWORD [rbp - 24], rdx

; ssize_t nread = 0;

      mov       QWORD [rbp - 32], 0

; do {

.do_while:

;   if ((n = read(fd, &((char *)buf)[nread], nbyte - nread)) < 0)
;   {
      mov       edi, DWORD [rbp - 8]    ; edi = fd
      mov       rsi, QWORD [rbp - 16]   ; rsi = buf
      mov       rax, QWORD [rbp - 32]   ; rax = nread
      add       rsi, rax                ; rsi = &buf[nread]
      mov       rdx, QWORD [rbp - 24]   ; rdx = nbyte
      sub       rdx, rax                ; rdx = nbyte - nread

      mov       rax, __NR_read
      syscall
      test      rax, rax
      jns       .else

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

;     if (errno != EINTR)

      call      get_errno
      cmp       rax, EINTR
      je        .end_if

;       return -1;

      mov       rax, -1
      jmp       .epilogue

.end_if:

;     errno = 0;

      call      clr_errno
      jmp       .end_if_else

;   } else {

.else:

;   if (n == 0) return nread  /* EOF */

      test      rax, rax
      jnz       .end_if_2
      mov       rax, [rbp - 32]
      jmp       .epilogue

.end_if_2:

;   nread += n;

      mov       rcx, QWORD [rbp - 32]
      add       rax, rcx
      mov       QWORD [rbp - 32], rax

;   }

.end_if_else:

; } while (nread < nbyte)

      mov       rax, QWORD [rbp - 32]
      mov       rcx, QWORD [rbp - 24]
      cmp       rax, rcx
      jae       .epilogue
      jmp       .do_while

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   int io_sync (int fd);
;
; param:
;
;   edi = fd
;
; return:
;
;   eax = 0 (success) | -1 (failure)
; ──────────────────────────────────────────────────────────────────────────────

      global io_sync:function

io_sync:

; do {

.loop:

      mov       rax, __NR_fsync
      syscall
      test      rax, rax
      jz        .epilogue

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

; } while (errno == EINTR);

      call      get_errno
      cmp       rax, EINTR
      je        .loop

; return -1;

      mov       eax, -1

.epilogue:

      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   ssize_t io_write (int fd, void const *buf, size_t nbyte);
;
; param:
;
;   edi = fd
;   rsi = buf
;   rdx = nbyte
;
; return:
;
;   rax = # of bytes read (success) | -1 (failure)
;
; stack:
;
;   DWORD [rbp - 8]   = edi (fd)
;   QWORD [rbp - 16]  = rsi (buf)
;   QWORD [rbp - 24]  = rdx (nbyte)
;   QWORD [rbp - 32]  = (nwritten)
;
; brief:  If syscall __NR_write returns zero bytes written, then io_pwrite
;         will return -1 and errno will be set to EIO.
; ──────────────────────────────────────────────────────────────────────────────

      global io_write:function

io_write:

; prologue

      push      rbp
      mov       rbp, rsp
      sub       rsp, 32
      mov       DWORD [rbp - 8], edi
      mov       QWORD [rbp - 16], rsi
      mov       QWORD [rbp - 24], rdx

; ssize_t nwritten = 0;

      mov       QWORD [rbp - 32], 0

      call      clr_errno

; do {

.do_while:

;   if ((n = write(fd, &((char *)buf)[nwritten],
;           nbyte - nwritten)) <= 0)
;   {
      mov       edi, DWORD [rbp - 8]    ; edi = fd
      mov       rsi, QWORD [rbp - 16]   ; rsi = buf
      mov       rax, QWORD [rbp - 32]   ; rax = nwritten
      add       rsi, rax                ; rsi = &buf[nwritten]
      mov       rdx, QWORD [rbp - 24]   ; rdx = nbyte
      sub       rdx, rax                ; rdx = nbyte - nwritten

      mov       rax, __NR_write
      syscall
      test      rax, rax
      js        .n_lt_zero
      jz        .n_eq_zero
      jmp       .else

.n_eq_zero:

      mov       rdi, EIO
      call      set_errno
      mov       eax, -1
      jmp       .epilogue

.n_lt_zero:

;     syscall does not set the errno
;     value when an error occurs.

      mov       rdi, rax
      call      set_errno

;     if (errno != EINTR)

      call      get_errno
      cmp       rax, EINTR
      je        .end_if_1

;       return -1;

      mov       eax, -1
      jmp       .epilogue

.end_if_1:

;     errno = 0;

      call      clr_errno
      jmp       .end_if_else

;   } else {

.else:

;   nwritten += n;

      mov       rcx, QWORD [rbp - 32]
      add       rax, rcx
      mov       QWORD [rbp - 32], rax

;   }

.end_if_else:

; } while (nwritten < nbyte);

      mov       rax, QWORD [rbp - 32]
      mov       rcx, QWORD [rbp - 24]
      cmp       rax, rcx
      jae       .epilogue
      jmp       .do_while

.epilogue:

      mov       rsp, rbp
      pop       rbp
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   void clr_errno ();
; ──────────────────────────────────────────────────────────────────────────────

clr_errno:

      call      __errno_location wrt ..plt
      xor       rcx, rcx
      mov       QWORD [rax], rcx
      ret

; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   long get_errno ();
;
; param:
;
;   rdi = errno
; ──────────────────────────────────────────────────────────────────────────────

get_errno:

      call      __errno_location wrt ..plt
      mov       rax, QWORD [rax]
      ret


; ──────────────────────────────────────────────────────────────────────────────
; C definition:
;
;   void set_errno (long errno);
;
; param:
;
;   rdi = negative errno value
; ──────────────────────────────────────────────────────────────────────────────

set_errno:

      neg       rdi
      push      rdi
      call      __errno_location wrt ..plt
      pop       QWORD [rax]
      ret

%endif
