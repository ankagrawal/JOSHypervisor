// test user-level fault handler -- just exit when we fault

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
	cprintf("hellish\n");
	cprintf("utf->utf_err: %x\n",utf->utf_err);
	cprintf("utf->utf_regs.reg_eax: %x\n",utf->utf_regs.reg_eax);
	cprintf("utf->utf_regs.reg_ebx: %x\n",utf->utf_regs.reg_ebx);
	cprintf("utf->utf_regs.reg_ecx: %x\n",utf->utf_regs.reg_ecx);
	cprintf("utf->utf_esp: %x\n",utf->utf_esp);
	void *addr = (void*)utf->utf_fault_va;
	cprintf("I came here atleast\n");
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
	sys_env_destroy(sys_getenvid());
}

void
umain(void)
{
	set_pgfault_handler(handler);
	//envid_t envid = sys_getenvid();
	cprintf("hanlered\n");
	*(int*)0xDeadBeef = 0;
}
