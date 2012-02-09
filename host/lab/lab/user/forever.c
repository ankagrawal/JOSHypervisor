#include <inc/lib.h>
#include <inc/stdio.h>

void
umain(void)
{
	while(1)
	{
        	cprintf("hello, world\n");
		sys_yield();
	}
//        cprintf("i am environment %08x\n", env->env_id);
}
