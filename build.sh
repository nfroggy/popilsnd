#! /bin/bash

if [ ! -d out ]
then
	mkdir out
fi

if [ ! -f popils.nes ]
then
	echo "popils.nes not found"
fi

if [ ! -d split ]
then
	echo "splitting popils rom..."
	mkdir split
	dd if=popils.nes of=split/header.bin bs=16 count=1
	dd if=popils.nes of=split/bank0.bin bs=16 skip=1 count=512
	dd if=popils.nes of=split/bank1.bin bs=16 skip=513 count=512
	dd if=popils.nes of=split/bank2.bin bs=16 skip=1025 count=512
	dd if=popils.nes of=split/bank3.bin bs=16 skip=1537 count=512
	dd if=popils.nes of=split/bank4.bin bs=16 skip=2049 count=512
	dd if=popils.nes of=split/bank5.bin bs=16 skip=2561 count=512
	dd if=popils.nes of=split/bank6.bin bs=16 skip=3073 count=512
	dd if=popils.nes of=split/bank7.bin bs=16 skip=3585 count=512
	dd if=popils.nes of=split/bank8.bin bs=16 skip=4097 count=512
	dd if=popils.nes of=split/bank9.bin bs=16 skip=4609 count=512
	dd if=popils.nes of=split/banka.bin bs=16 skip=5121 count=512
	dd if=popils.nes of=split/bankb.bin bs=16 skip=5633 count=512
	dd if=popils.nes of=split/bankc.bin bs=16 skip=6145 count=512
	dd if=popils.nes of=split/bankd.bin bs=16 skip=6657 count=512
	dd if=popils.nes of=split/banke.bin bs=16 skip=7169 count=512
	dd if=popils.nes of=split/bankf.bin bs=16 skip=7681 count=512
	dd if=popils.nes of=split/chr.bin bs=16 skip=8193 count=4096
fi

ca65 popilsnd.asm -g -l out/popilsnd.lst -o out/popilsnd.o
if [ $? -ne 0 ]
then
	echo "building popils sound engine failed"
	exit -1
fi

ca65 bankc.asm -g -o out/bankc.o
if [ $? -ne 0 ]
then
	echo "building popils sound engine failed"
	exit -1
fi

ld65 -C linker.cfg --dbgfile out/popilsnd.dbg out/popilsnd.o out/bankc.o
if [ $? -ne 0 ]
then
	echo "linking popils sound engine failed"
	exit -1
fi

echo "successfully built popils sound engine"

cat split/header.bin split/bank0.bin split/bank1.bin split/bank2.bin split/bank3.bin split/bank4.bin split/bank5.bin split/bank6.bin split/bank7.bin split/bank8.bin split/bank9.bin split/banka.bin split/bankb.bin out/bankc.bin split/bankd.bin split/banke.bin split/bankf.bin split/chr.bin > out/popils_built.nes

good_checksum="19cac66da15360bca2790288071fd5c3292738026802e0c1f6d23830a00ca6e4"
checksum="$(sha256sum out/bankc.bin | awk '{ print $1 }')"
if [ $checksum == $good_checksum ]
then
    echo "built sound engine matches original"
fi

exit 0

