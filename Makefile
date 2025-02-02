# Note: It is important to make sure you include the <bsd.kmod.mk> makefile after declaring the KMOD and SRCS variables.


# Enumerate Source files for kernel module
SRCS=g_anop.c

# Declare Name of kernel module
KMOD=geom_anop

CFLAGS=-g -O0 -g3

# Include kernel module makefile
.include <bsd.kmod.mk>

test1: md0 load md0.nop xd0 unload

test2: md0 load md0.nop unload 
	mdconfig -du md0

test3: md0 load md0.nop
	mdconfig -du md0
	kldunload -f geom_anop

test4: md0 load md0.nop fio xd0 unload

md0:
	mdconfig -a -s 64m -u md0 -t malloc -o noasync -o nocache
	sleep 1

md0.nop:
	gnop create -v /dev/md0 
	sleep 1

xd0:
	gnop destroy -v md0.nop
	mdconfig -du md0 -o force

dd:
        #skip=$(($RANDOM % 1024*1024))
	dd if=/dev/md0.nop of=/dev/null bs=512 count=1 skip=7

fio:
	fio --name=randrw --ioengine=posixaio --rw=randrw --rwmixread=70 --direct=1 --numjobs=8 --iodepth=64 --blocksize=4K --filename=/dev/md0.nop
