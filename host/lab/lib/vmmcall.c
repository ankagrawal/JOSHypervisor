#include <inc/syscall.h>
#include <inc/lib.h>


static inline int32_t 
vmmcall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
        int32_t ret;


        asm volatile("int %1\n"
                : "=a" (ret)
                : "i" (VMM_SYSCALL),
                  "a" (num),
                  "d" (a1),
                  "c" (a2),
                  "b" (a3),
                  "D" (a4),
                  "S" (a5)
                : "cc", "memory");
	cprintf("here\n");
        if(check && ret > 0)
                panic("syscall %d returned %d (> 0)", num, ret);
        return ret;
}

void
vmm_call()
{
	cprintf("in cal\n");
	vmmcall(100, 0, 0, 0, 0, 0, 0);
}

