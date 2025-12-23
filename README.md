# popilsnd

This is a disassembly of the sound engine from the NES version of *Magical Puzzle Popils* by Tengen.

A prototype of *Magical Puzzle Popils* was recently dumped by the Video Game History Foundation, but was missing the first 32KB of data. Miraculously the game still boots and is fully playable, but it's missing all the music and sound effects. This project aims to document the *Popils* sound engine to assist anyone who wants to recreate the missing data.

The code in this repo corresponds to the area starting at $1812A in the .nes file dumped by the VGHF. This starts at $811A in NES memory when bank C is mapped in the $8000-9FFF area.

## Build instructions
1. Make sure ca65 and ld65 are in your PATH.
1. Run "build.sh". It will assemble the sound engine, and verify that the checksum matches.
