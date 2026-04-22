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
%ifndef IO_INC
%define IO_INC  1

; Syscall numbers (very stable)
%define __NR_read       0
%define __NR_write      1
%define __NR_open       2
%define __NR_close      3
%define __NR_lseek      8
%define __NR_pread64    17
%define __NR_pwrite64   18
%define __NR_fsync      74
%define __NR_fdatasync  75

EINTR   EQU   4
EIO     EQU   5

%endif
