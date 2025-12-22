# popilsnd

This is a disassembly of the sound engine from the NES version of *Magical Puzzle Popils* by Tengen.

A prototype of *Magical Puzzle Popils* was recently dumped by the Video Game History Foundation, but was missing the first 32KB of data. Miraculously the game still boots and is fully playable, but it's missing all the music and sound effects. This project aims to document the *Popils* sound engine to assist anyone who wants to recreate the missing data.

## Build instructions
1. Clone the repo with `git clone --recurse-submodules`.
1. Run "build.sh". It will compile the assembler if necessary, assemble the sound engine, and verify that the checksum matches