This is the simulator for UniZK, an accelerator for  Zero-Knowledge Proof with unified hardware and flexible kernel mapping.

## Thirdparty
The codes of the following third-party libraries are sourced from:
- ecdsa: <https://github.com/0xPolygonZero/plonky2-ecdsa/tree/bdb6504bca250db1548cdcce2407d4e334990c33>
- imgcrop: <https://github.com/ChickenLover/plonky2-zkedit/tree/d20567361bd405716f6736a88dc263978f267d62>
- plonky2: <https://github.com/0xPolygonZero/plonky2/tree/30b47998262642be54da5acf03dfca31af4d93f7>
- plonky2v0.1: <https://github.com/polymerdao/plonky2/tree/4cb0b48df1d227d5461a4c28ed025aaea64e2e62>
- proto-neural-zkp: <https://github.com/worldcoin/proto-neural-zkp/tree/b2b514ac0857fd5e1cb5da9399fcd6020b1730e3>
- ramsim: RamSim is an enhanced version of Ramulator2, adding support for simulating computation latency and data dependencies. Most of its source code is derived from <https://github.com/CMU-SAFARI/ramulator2/tree/b7c70275f04126c647edb989270cc429776955d1>.
- sha256: <https://github.com/polymerdao/plonky2-sha256/tree/06d128e78ed8d29b21d58294b069e852c1866f8d>
- sha256-starky: <https://github.com/tumberger/plonky2/tree/474ed82c385b446f89bc18e648b5ad7d5d94ce06>

We appreciate the contributions of these open-source authors.

## How to get started
### Prerequiste
- A recent Linux distribution (recommended: Ubuntu 22.04)
- rust 1.80
- g++ 11.4
- cmake 3.22

### Configure the environment
The `dependency.sh` script installs the C++ build tools, CMake, Git, curl, CA certificates, and nightly Rust. Existing Rust installations and nightly toolchains are reused. Run it with root privileges:

```
./dependency.sh
```

To run UniZK in a Docker container, the `docker.sh` script creates or reuses the `unizk` container, installs the dependencies, selects nightly Rust for `/UniZK`, and builds RamSim. It then leaves an interactive shell open in `/UniZK` with Cargo available. Use this command:

```
./docker.sh
```

The project directory is bind-mounted directly at `/UniZK`, so edits on the host are immediately visible in the container and vice versa. Rebuild or rerun the program to apply source changes. The script resolves the project directory from its own location, regardless of the current working directory.

Setup runs on each invocation; Rust is reused and the RamSim build is incremental. The initial setup requires internet access to download packages, Rust, and RamSim's C++ dependencies. Setup stops on errors before opening the shell. Files created by the container's root user in the mounted directory will be owned by root on the host.

Containers created by the old script must be replaced to use the new mount. The script will stop with instructions to preserve the old container by stopping and renaming it before rerunning `./docker.sh`. Installed tools in the old container are not transferred to the new one.

### Use a nightly toolchain for Plonky2
```
rustup override set nightly
```

### Build RamSim
```
cd thirdparty/ramsim
mkdir build
cd build
cmake ..
make -j
```
### Run tests on CPU
```
./run_cpu_test.sh
```

### Run tests for plonky2
```
./run_plonky2_test.sh
```
### Run tests for starky and recursive proof
```
./run_starky_test.sh
```

A log file with the name of the application, such as “sha256.log”, will appear in the folder with the simulation results.

## Notes
### Disk space
Trace files can take up a lot of disk space. Ensure you have enough space when testing large applications and remember to clean up the files after testing!

### GPU
The GPU performance can be evaluated using the GPU implementation of Plonky2 (available at <https://github.com/sideprotocol/plonky2-gpu/tree/d6430874ae76e6cfc45d995fa3cf8b84fad70404>) with our CPU-based application code located in the `examples` directory.
