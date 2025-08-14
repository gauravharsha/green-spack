#!/bin/bash

set -euo

# # Prerequisite -- assuming this already exists in the cluster PC
# apt update
# apt install file bzip2 ca-certificates g++ gcc gfortran git gzip lsb-release patch python3 tar unzip xz-utils zstd

# # Uncomment to download and use spack
# git clone --depth=2 https://github.com/spack/spack.git
# . spack/share/spack/setup-env.sh

source spack/share/spack/setup-env.sh

# Dependencies for Green
spack install eigen
spack install hdf5
spack install blas
spack install cmake
spack install boost
spack install fftw

# load the installed codes
spack load eigen hdf5 blas cmake boost fftw

# Clone repos
git clone https://github.com/ALPSCore/ALPSCore
git clone https://github.com/opencollab/arpack-ng
git clone https://github.com/Q-Solvers/EDLib
git clone https://github.com/Green-Phys/seet_solvers

# 1. install ALPSCore
cmake -S ALPSCore -B build --install-prefix `pwd`/install/ALPSCore
cmake --build build -j 32
cmake --build build -t test install
rm -rf build

# 2. install ARPack
cmake -S arpack-ng -B build \
  --install-prefix `pwd`/install/arpack  -DMPI=ON \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build -j 32
cmake --build build -t test install
rm -rf build

# 3. install EDLib
cmake -S EDLib -B build --install-prefix `pwd`/install/EDLib \
  -DCMAKE_BUILD_TYPE=Release \
  -DALPSCore_DIR=`pwd`/install/ALPSCore/share/ALPSCore \
  -DARPACK_DIR=`pwd`/install/arpack -DUSE_MPI=MPI
cmake --build build -j 32
cmake --build build -t install
rm -rf build

# 4. install seet_solvers
cmake -S seet_solvers -B build \
   --install-prefix `pwd`/install/seet_solvers \
   -DCMAKE_BUILD_TYPE=Release         \
   -DALPSCore_DIR=`pwd`/install/ALPSCore/share/ALPSCore  \
   -DARPACK_DIR=`pwd`/install/arpack \
   -DEDLib_DIR=`pwd`/install/EDLib/share/EDLib/cmake \
   -DUSE_MPI=MPI
cmake --build build -j 32
cmake --build build -t install
rm -rf build

# 5. install SEET/MBPT code
git clone https://github.com/Green-Phys/green-mbpt
cd green-mbpt
git checkout SEET
cd ..
cmake -S green-mbpt -B build \
   --install-prefix `pwd`/install/green-mbpt \
   -DCMAKE_BUILD_TYPE=Release
cmake --build build -j 32
cmake --build build -t test install
rm -rf build