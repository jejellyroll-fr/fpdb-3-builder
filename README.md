# fpdb-3-builder Project Documentation

## Overview

The `fpdb-3-builder` project is a global build system designed to compile the FPDB-3 application across multiple platforms, including Linux, Windows, macOS, and macOS ARM. This project facilitates the building of FPDB-3 along with its submodules, which include the `poker-eval` library and its Python binding `pypoker-eval`.

## Project Structure

### FPDB-3

[FPDB-3](https://github.com/jejellyroll-fr/fpdb-3) is a poker tool that includes a HUD (Heads-Up Display) and a replayer. It is an adaptation of the original FPDB project updated for Python 3.11. The project aims to improve poker analysis tools and is a personal development project for enhancing Python skills.

### Submodules

1. **[poker-eval](https://github.com/jejellyroll-fr/poker-eval/)**: A library used for poker hand evaluation. It has been updated to include support for various poker variants like 5-card PLO, 5-card PLO8, and 6-card PLO.

2. **[pypoker-eval](https://github.com/jejellyroll-fr/pypoker-eval)**: A Python binding for `poker-eval`, updated for Python 3. The project plans to add support for additional poker variants.

## Build Instructions

### Prerequisites

- Ensure you have Python 3.11.9 installed.
- Use Anaconda or Pip for managing dependencies.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jejellyroll-fr/fpdb-3-builder
   cd fpdb-3-builder
   ```


### Building the Project

To build the FPDB-3 project along with its submodules, simply run the following command in your terminal:

```bash
./build.sh
```

## Running the Application

- Before starting FPDB3 copy config files in you home folder:
  ```bash
  ./install.sh 
  ```
- For linux you need to install python lib in an env and run it a terminal:
  ```bash
  ./fpdb-x86_64.AppImage
  ```
- For windows or macos, just double clic on fpdb.exe or fpdb.app exectable:


## Bug Reporting

For bug reports and feature requests, please use the appropriate repo

## Contact

For further assistance, you can reach out via email at jejellyroll.fr@gmail.com 

## License

This project is open-source and available under a free software license.