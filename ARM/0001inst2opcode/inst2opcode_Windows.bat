call "toolchains_Windows/arm-linux-androideabi-as.exe" src.s -o dest.o
call "toolchains_Windows/arm-linux-androideabi-objdump.exe" -D dest.o
call pause
