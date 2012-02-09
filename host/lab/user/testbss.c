// test reads and writes to a large bss

#include <inc/lib.h>

#define ARRAYSIZE (1024*1024)

uint32_t bigarray[ARRAYSIZE];

void
umain(void)
{
	int i;

	cprintf("Making sure bss works right...\n");
	cprintf("going into the array\n");
	for (i = 0; i < ARRAYSIZE; i++)
	{
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
		if(i%ARRAYSIZE == 0)
			cprintf("page %d allocated\n",(i / PGSIZE));
	}
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);
	cprintf("bigarray: %x, bigarray+ARRAYSIZE %x, bigarray+(ARRAYSIZE)+1024 %x\n", bigarray, bigarray+ARRAYSIZE, bigarray+(ARRAYSIZE)+1024);
	cprintf("Yes, good.  Now doing a wild write off the end...\n");
	bigarray[ARRAYSIZE+1024] = 0;
	panic("SHOULD HAVE TRAPPED!!!");
}
