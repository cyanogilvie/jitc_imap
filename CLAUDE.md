# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Tcl/C IMAP client library implementation that uses the JIT C (jitc) Tcl package for high-performance IMAP protocol parsing. The codebase consists of:

1. An IMAP protocol parser implemented using tcllemon (a Tcl wrapper for the Lemon parser generator) and re2c (a fast lexer generator)
2. C code for handling IMAP messages and responses
3. Tcl code for interfacing with the C implementation

The library parses IMAP server responses into structured JSON representations that can be easily manipulated from Tcl.

## Build Commands

```bash
# Build the Tcllemon shared library
make

# Run tests
make test

# Clean build artifacts
make clean
```

## Key Components

### Parser Generation

The parsing system works through multiple stages:

1. The IMAP protocol grammar is defined in `imap.y` using Lemon parser generator syntax
2. The `tcllemon` tool converts this grammar into C code
3. The re2c tool is used to generate lexer code for tokenizing IMAP messages
4. These components are combined into a JIT-compiled Tcl extension

### Runtime Components

- `imap.tcl`: Main Tcl interface that loads the JIT C implementation
- `imap.c`/`imap.h`: C code for IMAP protocol handling
- `tcllemon.c`: Implementation of the Lemon parser generator as a Tcl extension
- `libtcllemon.so`: Compiled shared library for the tcllemon parser generator

### Architecture

The system operates as follows:

1. IMAP messages are fed to the `parse_response` function
2. Messages are tokenized and parsed according to the IMAP grammar
3. Parsed responses are converted to structured JSON objects
4. These structured objects can be manipulated and queried from Tcl

## Development Workflow

When making changes:

1. Modify the grammar in `imap.y` if you need to support new IMAP commands or response formats
2. Add corresponding literal definitions in `imap.h` if needed
3. Update parsing logic in `imap.c` 
4. Run `make test` to verify your changes

## Dependencies

- Tcl 8.7
- jitc (JIT Compiler for Tcl)
- chantricks Tcl package
- rl_json Tcl package (version 0.15.3 or later)
- dedup Tcl package (version 0.9.5 or later)
- re2c (for regenerating lexer code) (bundled in the jitc package)

## Testing

Test cases are provided in `test.tcl`. Run them with:

```bash
make test
```

or directly with:

```bash
tclsh8.7 test.tcl
```
