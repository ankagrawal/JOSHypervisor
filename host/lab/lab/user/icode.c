#include <inc/lib.h>

void
umain(void)
{
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
/*
	cprintf("icode startup\n");

	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
	close(fd);
*/
	cprintf("icode: spawn /vmmn\n");
	if ((r = spawnl("/vmm", "heylo")) < 0)
		panic("icode: spawn /vmm: %e", r);
/*
	cprintf("icode: spawn /kernel\n");
	if ((r = spawn_vmmn("/vmm")) < 0)
		panic("icode: spawn /kernel: %e", r);
*/
	cprintf("icode: exiting %x\n", r);
}
