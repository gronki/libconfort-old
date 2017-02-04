# libconfort

**libconfort** is a small library written in C and modern Fortran. There are numerous excellent libraries for handling configuration files written for C. None of them has a native, easy-to-use interface for Fortran, which is the leading language for numerical computing. The intrinsic I/O handling in Fortran is decent, however it lacks the full flexibility that a proper configuration file utility provides (such as comments or quoted strings).

**libconfort**, which stands for **conf**iguration **for** **Fort**ran, is attempting to fill that niche. The library core is written in C, however all routines are wrapped into native Fortran interfaces, which provides a seamless experience for a Fortran programmer. The upcoming object interface is going to provide even better experience.

The library is still in very early stages of developement. The core and procedural interface is considered stable and ready for production use. The object interface is under development and it may change in the future.

## Setup

### Requirements

Since **libconfort** relies on the latest Fortran 2008 features, it requires **GCC 6** compiler suite. It should be freely available on most of the distributions. To build the library on CentOS 6/7, you need to do the following:
```sh
# install the scl
sudo yum install centos-release-scl
# install the GCC 6 collection
sudo yum install devtoolset-6-{gcc{,-gfortran},make}
# run the sub-shell with toolset enabled
scl enable devtoolset-6 bash
# build the library as usual...
```

### Build and installation

Installation is easy and typical. The easiest way is to install from provided rpm files. If you want or need to install it from source, first build the library by typing:
```sh
make
```
Then, install it in ``/usr/local`` by executing
```sh
sudo make install
```
or, if you want to sandbox the library for easy removal, execute:
```sh
sudo make install prefix=/opt/confort
```

## Terms of use

Distributed under the MIT License. See the LICENSE document for full text and copyright information.
