// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW         0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
        void *addr = (void *) utf->utf_fault_va;
        uint32_t err = utf->utf_err;
        int r;

        // Check that the faulting access was (1) a write, and (2) to a
        // copy-on-write page.  If not, panic.
        // Hint:
        //   Use the read-only page table mappings at vpt
        //   (see <inc/memlayout.h>).

        // LAB 4: Your code here.
        
	pte_t pte = ((pte_t *)vpt)[VPN(addr)];
        
	if(!((err & FEC_WR) != 0 && (pte & PTE_COW) != 0)) 
	{
                panic("invalid permissions\n");
                return;
        }

        if (sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
                panic("error in sys_page_alloc\n");
        
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
        
	if (sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W) < 0)
                panic("error in sys_page_map\n");
        
	sys_page_unmap(0, PFTEMP);
        // Allocate a new page, map it at a temporary location (PFTEMP),
        // copy the data from the old page to the new page, then move the new
        // page to the old page's address.
        // Hint:
        //   You should make three system calls.
        //   No need to explicitly delete the old page's mapping.
        
        // LAB 4: Your code here.
        
        //panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why mark ours copy-on-write again
// if it was already copy-on-write?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
        void *va;
        pte_t pte;

        // LAB 4: Your code here.
        //panic("duppage not implemented");
        pte = vpt[pn];
        va = (void *)(pn * PGSIZE);

        if ((pte & PTE_P) == 0 || (pte & PTE_U) == 0)
                panic("invalid permissions\n");

        if ((pte & PTE_W) == 0 && (pte & PTE_COW) == 0) 
	{
		int err;
                err = sys_page_map(0, va, envid, va, PTE_P | PTE_U);
                if (err < 0)
                        return err;
        }
        else 
	{
		int err = sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW);
                if (err < 0)
                        return err;
                err = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW);

                if (err < 0)
                        return err;
        }
        return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "env" and the user exception stack in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
        // LAB 4: Your code here.
        //panic("fork not implemented");
        envid_t envid;
        uint8_t * addr;
        int r;
        set_pgfault_handler(pgfault);
        envid = sys_exofork();
        
	if (envid == 0) 
	{
                env = &envs[ENVX(sys_getenvid())];
                return 0;
        }
	
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
	{
                if (vpd[i] & PTE_P) 
		{
                        for (j = 0; j * PGSIZE + i * PTSIZE < UTOP && j < NPTENTRIES; j++) 
			{
				int ad = j*PGSIZE+i*PTSIZE;

                                if (ad == UXSTACKTOP - PGSIZE) 
                                        continue;


                                pte_t p = vpt[i * NPTENTRIES + j];

                                if ((p & PTE_P) && (p & PTE_U))
				{
                                        if (duppage(envid, i * NPTENTRIES + j) < 0)
                                                panic("filing in duppage\n");
				}
                        }
                }
        }

        if (sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_P | PTE_U | PTE_W) < 0)
                panic("sys_page_alloc could not alooc\n");
        
        extern void _pgfault_upcall(void);
	
        if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
                panic("failed in upcall\n");
	
        if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
                panic("failed in status set\n");

        return envid;
}

// Challenge!
int
sfork(void)
{
        panic("sfork not implemented");
        return -E_INVAL;
}

