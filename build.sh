#! /bin/bash

if [ ! -d out ]
then
	mkdir out
fi

ca65 popilsnd.asm -g -l out/popilsnd.lst -o out/popilsnd.o
if [ $? -ne 0 ]
then
	echo "building popils sound engine failed"
	exit -1
fi

ld65 -o out/popilsnd.bin -m out/popilsnd.map -C linker.cfg out/popilsnd.o

echo "successfully built popils sound engine"

good_checksum="8b63ef19e4baa4e137a668f239e909505ab1d069c74f10b07ee2ef86cd0398e2"
checksum="$(sha256sum out/popilsnd.bin | awk ' { print $1 }')"
if [ $checksum == $good_checksum ]
then
	echo "built sound engine matches original"
fi

exit 0

