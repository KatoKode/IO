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
