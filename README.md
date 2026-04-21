# SYSCALL_IO
Linux file operations written in pure x86_64 assembly with a C interface as a Shared-Library.

# libio — Minimal, High-Performance I/O Library in x86_64 Assembly

Designed for performance-critical applications that need direct I/O (`O_DIRECT`), synchronized writes (`O_DSYNC`).

## Features

- **Pure x86_64 assembly implementation** — minimal overhead, full syscall ABI control
- **EINTR-safe** — all operations correctly handle interrupted syscalls (except `close`, which follows modern best practices)
- **Direct I/O ready** — proper alignment handling via `fpathconf(_PC_REC_XFER_ALIGN)`
- **Zero-copy / low-level focus** — `io_pread` / `io_pwrite` with partial-transfer retry loops
- **Zero runtime dependencies** — only glibc for `__errno_location` (and optional C headers)
- **Hard-coded, stable flag values** — `io_flags.inc` lets you avoid `<fcntl.h>` entirely if desired
- **Professional build system** — separate shared library + demo, with debug symbols and noexecstack protection
- **GPL-2.0 licensed** — fully open source

## Why This Library?

Most libc I/O wrappers add unnecessary overhead and hide important error conditions. This library gives you:

- Direct access to Linux syscalls (`open`, `pread64`, `pwrite64`, `fsync`, `fdatasync`, etc.)
- Predictable behavior for high-performance storage engines, databases, or embedded systems
- Clear, well-commented assembly that is easy to audit and extend
- Runtime-correct alignment for `O_DIRECT` (no hard-coded 4096 assumptions)

## Quick Start

### 1. Build the library and demo
```bash
# Use the convenience script in the root folder:
sh ./io_make.sh
# Or use make in the individual folders
cd ./io/id
make clean; make    # builds libio.so
cd ../demo
make clean; make    # builds the demo binary
```
### 2. Run the demo
```bash
cd demo
./go_demo.sh
```
The demo creates ./out.txt (containing 10,000 integers (0–9999) stored in fixed 16-byte records) using O_CREAT | O_DIRECT | O_RDWR | O_DSYNC | O_TRUNC, then re-opens the file and reads the data back.
## API
All functions are declared in io/io.h:
```C
int   io_close(int fd);
int   io_creat(const char *path, int flags, mode_t mode);
int   io_open(const char *path, int flags);
ssize_t io_pread(int fd, void *buf, size_t nbyte, off_t offset);
ssize_t io_pwrite(int fd, const void *buf, size_t nbyte, off_t offset);
int   io_data_sync(int fd);
int   io_sync(int fd);
```
### Key Design Notes

+ io_creat uses the open syscall (more flexible than the legacy creat syscall)
+ io_pread / io_pwrite / io_read / io_write automatically retry on partial transfers and handle EINTR
+ io_pwrite and io_write treat a zero-byte return from pwrite64 or write as an error (EIO)
+ io_close does not retry on EINTR (modern Linux best practice to avoid fd-reuse races)
