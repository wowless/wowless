# elune

elune is a customized Lua 5.1 implementation extending the virtual machine with
a tainted execution model based off the World of Warcraft user interface
environment.

A high-level overview of how the tainted execution model works can be boiled
down to these three points.

- Any untrusted (or insecure) code that writes values will "taint" whatever is
  being stored.
- Any trusted (or secure) code that reads tainted values will spread that taint
  to the current call stack.
- Any function can check whether or not the call stack is tainted to determine
  whether or not a privileged action should be permitted.

This project is intended to serve as a close approximation of the tainted
execution model against a reference client environment, and should be accurate
enough for any legitimate addon development and external tooling use cases.
This project is **not** a binary-compatible implementation of taint as found
within the actual game client itself, and does not aim to be fully bug-
compatible with the reference client with respect to any potential security
issues that can impact the live game service. Any security issues found within
the reference client during development of this project have - and continue to
be - submitted to Blizzard for resolution.

## Building

This copy is vendored into [wowless](https://github.com/wowless/wowless),
trimmed to only the sources wowless actually builds (`liblua/`, the public
headers, and `lua/lua.c`), and compiled directly by wowless's own top-level
`CMakeLists.txt` rather than elune's own CMake build. Elune's own build
system (CMake presets, packaging, CI) and standalone test harness were
dropped from this copy; see the [upstream
repository](https://github.com/meorawr/elune) for those and for the
project's own release history.

## License

This project is based upon the original Lua 5.1 source which is available under
the MIT license as documented in the `LICENSE` file at the root of the
repository. All modifications atop the original source are also covered under
the same original license terms.

## Contributors

- [Daniel "Meorawr" Yates](https://github.com/meorawr)
