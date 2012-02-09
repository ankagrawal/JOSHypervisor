// yield the processor to other environments

#include <inc/lib.h>

void
umain(void)
{
	int i;
	cprintf("in sys_yield\n");
	cprintf("Hello, I am environment %08x.\n", sys_getenvid());
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			env->env_id, i);
	}
	cprintf("All done in environment %08x.\n", env->env_id);
}