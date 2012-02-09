// Ping-pong a counter between two processes.
// Only need to start one of these -- splits into two with fork.

#include <inc/lib.h>

void
umain(void)
{
	envid_t who;
	cprintf("I am ping pong\n");
	if ((who = fork()) != 0) {
		// get the ball rolling
		cprintf("in parent\n");
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		cprintf("recieving\n");
		uint32_t i = ipc_recv(&who, 0, 0);
		cprintf("in child\n");
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
		if (i == 10)
			return;
		i++;
		cprintf("sending %d\n",i);
		ipc_send(who, i, 0, 0);
		if (i == 10)
			return;
	}
		
}

