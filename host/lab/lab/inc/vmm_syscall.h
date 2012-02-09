#ifndef JOS_INC_VMM_SYSCALL_H
#define JOS_INC_VMM_SYSCALL_H

/* system call numbers */
enum
{
	VMM_SYS_cputs = 0,
	VMM_SYS_env_setup_vm,
	VMM_SYS_page_alloc,
	VMM_SYS_lcr3,
	VMM_SYS_load_icode,
	VMM_SYS_run,
	VMM_SYS_cgetc,
	VMM_SYS_getenvid,
	VMM_SYS_env_destroy,
	VMM_SYS_page_map,
	VMM_SYS_page_unmap,
	VMM_SYS_exofork,
	VMM_SYS_env_set_status,
	VMM_SYS_env_set_trapframe,
	VMM_SYS_env_set_pgfault_upcall,
	VMM_SYS_yield,
	VMM_SYS_ipc_try_send,
	VMM_SYS_ipc_recv,
	VMM_NSYSCALLS
};

#endif /* !JOS_INC_VMM_SYSCALL_H */
