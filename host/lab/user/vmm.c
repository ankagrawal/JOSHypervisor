#include <inc/lib.h>

void
umain(int argc, char **argv)
{
//	asm __volatile("cli");
	int k = 3;
	while(k>0)
	{
		int i = 0;
		k--;
		vmm_call();
		sys_yield();
	}
}
