# libconfort

**libconfort** is a small library written in C and modern Fortran. There are numerous excellent libraries for handling configuration files written for C. None of them has a native, easy-to-use interface for Fortran, which is the leading language for numerical computing. The intrinsic I/O handling in Fortran is decent, however it lacks the full flexibility that a proper configuration file utility provides (such as comments or quoted strings).

**libconfort**, which stands for **conf**iguration **for** **Fort**ran, is attempting to fill that niche. The library core is written in C, however all routines are wrapped into native Fortran interfaces, which provides a seamless experience for a Fortran programmer. The upcoming object interface is going to provide even better experience.

The library is still in very early stages of developement. The core and procedural interface is considered stable and ready for production use. The object interface is under development and it may change in the future.

## Terms of use

Distributed under the Simplified BSD License. See the LICENSE document for full text and copyright info.
