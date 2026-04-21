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
# From the project root
cd io
make                # builds libio.so
cd ../demo
make                # builds the demo binary
