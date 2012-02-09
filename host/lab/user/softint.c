// buggy program - causes an illegal software interrupt

#include <inc/lib.h>

void
umain(void)
{
	asm volatile("int $5");	// page fault
}

