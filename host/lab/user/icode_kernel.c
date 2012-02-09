#include<inc/lib.h>

void
umain(void)
{
	int r;
        cprintf("icode: spawn /kernel\n");
        if ((r = spawn_vmmn("/kernel")) < 0)
                panic("icode: spawn /kernel: %e", r);
}
