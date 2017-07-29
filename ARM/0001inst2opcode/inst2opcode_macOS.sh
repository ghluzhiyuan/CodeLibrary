#!/bin/bash
toolchains_macOS/arm-linux-androideabi-as src.s -o dest.o
toolchains_macOS/arm-linux-androideabi-objdump -D dest.o

