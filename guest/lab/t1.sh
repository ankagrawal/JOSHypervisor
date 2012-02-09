GCCPREFIX=$(shell if i386-jos-elf-objdump -i 2>&1 | grep '^elf32-i386$$' >/dev/null 2>&1; then echo 'QEMU'; fi)
echo $GCCPREFIX
GCCPREFIX=hi
echo $GCCPREFIX

