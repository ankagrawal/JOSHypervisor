#ifndef VMM_SYSCALL_H
#define VMM_SYSCALL_H
#include <inc/env.h>

uint32_t KERN_CR3;
struct Env* KERN_ENV;
static void vmm_sys_cputs(const char* s, size_t len);
int32_t vmm_syscall1(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5);
static int vmm_sys_page_alloc(int, struct Env*, void*, int);
static int vmm_sys_env_setup_vm(void*);
static int vmm_sys_lcr3(uint32_t);
static void vmm_sys_env_pop_tf(void*);
static int vmm_sys_load_icode(void*, void*, int);
#endif
