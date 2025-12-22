#! /bin/bash

if [ ! -f asm6f/asm6f ] || find asm6f -type f -newer asm6f/asm6f | grep -q .
then
	echo "building asm6f..."
	cd asm6f
	make
	if [ $? -ne 0 ]
	then
		echo "building asm6f failed"
		exit -1
	fi
	cd ..
fi

if [ ! -d out ]
then
	mkdir out
fi

asm6f/asm6f popilsnd.asm out/popilsnd.bin out/popilsnd.lst
if [ $? -ne 0 ]
then
	echo "building popils sound engine failed"
	exit -1
fi
echo "successfully built popils sound engine"

good_checksum="79f8d5affc706edddded7444cb5b34bc1cabdfc6b9e1260a27d70bce74b54a9d"
checksum="$(sha256sum out/popilsnd.bin | awk ' { print $1 }')"
if [ $checksum == $good_checksum ]
then
	echo "built sound engine matches original"
fi

exit 0

