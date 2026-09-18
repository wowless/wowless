# elune

elune is a customized Lua 5.1 implementation extending the virtual machine with a tainted execution model based off the World of Warcraft user interface environment.

A high-level overview of how the tainted execution model works can be boiled down to these three points.

- Any untrusted (or insecure) code that writes values will "taint" whatever is being stored.
- Any trusted (or secure) code that reads tainted values will spread that taint to the current call stack.
- Any function can check whether or not the call stack is tainted to determine whether or not a privileged action should be permitted.

This project is intended to serve as a close approximation of the tainted execution model against a reference client environment, and should be accurate enough for any legitimate addon development and external tooling use cases. This project is **not** a binary-compatible implementation of taint as found within the actual game client itself, and does not aim to be fully bug-compatible with the reference client with respect to any potential security issues that can impact the live game service. Any security issues found within the reference client during development of this project have - and continue to be - submitted to Blizzard for resolution.

## Building

CMake is used for building the project. The presets defined in `CMakePresets.json` at the root of the repository represent the supported build configurations that are tested by the CI; these are Linux (GCC), macOS (Clang) and Windows (MSVC).

For a build with all components enabled in a release configuration the following CMake commands will configure and build the project in a `build/<preset>` directory. The resulting binaries for Lua can be found in `bin/Release/` and `lib/Release/` subdirectories of that folder.

```sh
cmake --preset <linux|macos|windows>
cmake --build --preset <linux|macos|windows> [--config <Debug|Release>]
```

Installation of the compiled artifacts to a specified target directory can be performed with the following command.

```sh
cmake --build --preset <linux|macos|windows> [--config <Debug|Release>] [--prefix <path to install to>] [--strip]
```

To generate a fully packaged release the following can be executed to create a set of `.tar.xz` and `.zip` files in the build directory for the selected preset.

```sh
cmake --build --preset <linux|macos|windows> [--config <Debug|Release>] --target package
```

## License

This project is based upon the original Lua 5.1 source which is available under the MIT license as documented in the `LICENSE` file at the root of the repository. All modifications atop the original source are also covered under the same original license terms.

## Contributors

- [Daniel "Meorawr" Yates](https://github.com/meorawr)
