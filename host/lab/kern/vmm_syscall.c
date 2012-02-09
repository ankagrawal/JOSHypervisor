#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include<inc/env.h>
#include<inc/elf.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>
#include <inc/vmm_syscall.h>
#include <kern/vmm_syscall.h>

//struct Trapframe  vm_saved_tf ;

static envid_t
sys_getenvid(void)
{
        return curenv->env_id;
}

static void
vmm_sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	
        envid_t ev = sys_getenvid();
	user_mem_assert(&envs[ENVX(ev)], (void *)s, len, PTE_P);
//this has been added to check for inputs from timer 
/*	int k;
	for(k=0;k<200;k++)
	{
//		if((k%1000)==0)
//		{
			unsigned int i = inb(IO_TIMER1);
			cprintf("timer: %d\n",i); 
//		}
	}*/
//end of code for timer check
	cprintf("%.*s", len, s);
}


static void
Env_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{

        //cprintf("\n in Env_map_segment\n");
        //cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
        {
                pte_t *pte = pgdir_walk(pgdir, (void*)la, 1);
                if(pte == NULL)
                {
                        cprintf("could not allocate page table in Env_map_segment()!!\n");
                        return;
                }
                //cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
                //cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                la+=PGSIZE;
                pa+=PGSIZE;
        }
}

static int 
vmm_sys_env_setup_vm(void* e_addr)
{
//	cprintf("getting %x to set up\n", e_addr);
	int i, r;
	struct Page* p = NULL;
	
	if((r = page_alloc(&p)) < 0)
		return r;
	struct Env *e = (struct Env*) e_addr;
	e->env_pgdir = page2kva(p);	
	e->env_cr3 = page2pa(p);
	p->pp_ref++;
	memset(e->env_pgdir, 0, PGSIZE);

 	Env_map_segment(e->env_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
        Env_map_segment(e->env_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
        Env_map_segment(e->env_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
        Env_map_segment(e->env_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);

	e->env_pgdir[PDX(VPT)] = e->env_cr3 | PTE_P | PTE_W;
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;

	return 0;
}


static int
vmm_sys_lcr3(uint32_t cr3)
{
	cprintf("loading cr3: %x\n", cr3);
	lcr3(cr3);
	cprintf("loaded cr3\n");
	return 0;
}

static int
vmm_sys_page_alloc(envid_t envid, struct Env* e, void *va, int perm)
{
        if(envid != -1)
        {
                return -E_BAD_ENV;
        }

        if(((uint32_t)va >= UTOP) || (((uint32_t)va & 0xfff) !=0) || ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) )
        {
                return -E_INVAL;
        }

        struct Page *p;
        if(page_alloc(&p) == -E_NO_MEM)
        {
                return -E_NO_MEM;
        }
        if(page_insert(e->env_pgdir, p, va, perm) == -E_NO_MEM)
        {
                page_free(p);
                return -E_NO_MEM;
        }
        void *page_start_va = KADDR(page2pa(p));
        memset(page_start_va, 0, PGSIZE);
        return 0;
}

static int
page_map(struct Env* srcenv, void *srcva,
	     struct Env* dstenv, void *dstva, int perm)
{

	pte_t* src_pte;
	struct Page *p = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
	cprintf("%x %x\n", srcva, dstva);
/*	if( ((uint32_t)srcva >= UTOP) 
		|| (((uint32_t)srcva & 0xfff) !=0) 
		|| ((perm&(PTE_U|PTE_P)) != (PTE_U|PTE_P)) 
		|| (( (perm & PTE_W) == PTE_W) 
			&& ((((uint32_t)(*src_pte))&PTE_W) !=PTE_W)))
	{
		cprintf("failing here 1\n");
		return -E_INVAL;
	}
	
	if( ((uint32_t)dstva >= UTOP) 
		|| (((uint32_t)dstva & 0xfff) !=0) 
		|| ( (perm&(PTE_U|PTE_P)) != (PTE_U|PTE_P)) )
	{
		cprintf("failing here 2\n");
		return -E_INVAL;
	}
	//cprintf("1\n");
        if ((perm & PTE_W) && !((int)(*src_pte) & PTE_W))
                return -E_INVAL;*/
	if(page_insert(dstenv->env_pgdir, p, dstva, perm) == -E_NO_MEM)
	{
		return -E_NO_MEM;
	}
	//cprintf("2\n");
	return 0;
	panic("sys_page_map not implemented");
}

static void
vmm_segment_alloc(struct Env *e, void *va, size_t len)
{	
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
	struct Page *pg;
	for(i=0;i<numPages;i++)
	{		
	//	page_alloc(&pg);
	//	cprintf("mapped %x\n", start);
	//	if(page_insert(e->env_pgdir, pg, start, PTE_P|PTE_U|PTE_W)<0)
	//	{
		if(page_map(KERN_ENV, start, e, start, PTE_P|PTE_U|PTE_W))
		{
			panic("could not allocate memory to user environment\n");	
		}
		start += PGSIZE;
	}
}

static int
vmm_sys_load_icode(void* en, void* b, int len)
{
	cprintf("in vmm_sys_lod_icode\n");
	struct Env* e = (struct Env*)en;
	//cprintf("kern: %x %x", KERN_ENV, KERN_CR3);
        struct Proghdr *ph, *eph;
        struct Elf *ELFHDR = (struct Elf *)b;
	cprintf("%x\n", ELFHDR->e_entry);
        if(ELFHDR->e_magic != ELF_MAGIC)
        {
                panic("Process Load Error: Not a valid elf");
        }
        ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
        eph = ph + ELFHDR->e_phnum;

        for (; ph < eph; ph++)
	{
		if(ph->p_type == ELF_PROG_LOAD)
		{
			if(ph->p_type > ph->p_memsz)
			    panic("\n Panic in loa_icode\n");
			vmm_segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
		//	cprintf("suc1 %x %x\n", ph->p_va, ph);
			//lcr3(e->env_cr3);
			//cprintf("suc1 %x\n", ph);
			//memset((void *)ROUNDDOWN(ph->p_va, PGSIZE), 0, ROUNDUP(ph->p_va+ph->p_memsz, PGSIZE)-ROUNDDOWN(ph->p_va, PGSIZE));
			//cprintf("suc2\n");
			//lcr3(KERN_CR3);
			//cprintf("suc3\n");
			//memmove((void *)ph->p_va, (void *)(b+ph->p_offset), (size_t)ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
        e->env_tf.tf_ds = GD_UD | 3;
        e->env_tf.tf_es = GD_UD | 3;
        e->env_tf.tf_ss = GD_UD | 3;
        e->env_tf.tf_esp = USTACKTOP;
        e->env_tf.tf_cs = GD_UT | 3;
        e->env_status = ENV_RUNNABLE;
	e->env_tf.tf_eflags |= FL_IF;
	vmm_segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
	cprintf("exiting load_icode\n");
	return 0;
}


void
vmm_sys_env_pop_tf(void *en)
{
	//panic("***** Inside vmm_pop_tf\n");
	struct Env *user_env = (struct Env*) en;
	uint32_t* phd = user_env->env_pgdir;
	int i = 0;
/*	for(i=0; i<1024; i++)
	{
		cprintf("pgdir[%x]: %x\n", i, phd[i]);
	}
*/
	struct Trapframe tf;
	tf.tf_regs.reg_edi = user_env->env_tf.tf_regs.reg_edi;
	tf.tf_regs.reg_esi = user_env->env_tf.tf_regs.reg_esi;
	tf.tf_regs.reg_ebp = user_env->env_tf.tf_regs.reg_ebp;
	tf.tf_regs.reg_oesp = user_env->env_tf.tf_regs.reg_oesp;
	tf.tf_regs.reg_ebx = user_env->env_tf.tf_regs.reg_ebx;
	tf.tf_regs.reg_edx = user_env->env_tf.tf_regs.reg_edx;
	tf.tf_regs.reg_ecx = user_env->env_tf.tf_regs.reg_ecx;
	tf.tf_regs.reg_eax = user_env->env_tf.tf_regs.reg_eax;


	tf.tf_es = user_env->env_tf.tf_es;
	tf.tf_padding1 = user_env->env_tf.tf_padding1;
	tf.tf_ds = user_env->env_tf.tf_ds;
	tf.tf_padding2 = user_env->env_tf.tf_padding2;
	tf.tf_trapno = user_env->env_tf.tf_trapno;
	tf.tf_err = user_env->env_tf.tf_err;
	tf.tf_eip = user_env->env_tf.tf_eip;
	tf.tf_cs = user_env->env_tf.tf_cs;
	tf.tf_padding3 = user_env->env_tf.tf_padding3;
	tf.tf_eflags = user_env->env_tf.tf_eflags;
	tf.tf_esp = user_env->env_tf.tf_esp;
	tf.tf_ss = user_env->env_tf.tf_ss;
	tf.tf_padding4 = user_env->env_tf.tf_padding4;

	print_trapframe(&user_env->env_tf);
//	cprintf("pgdir: %x cr3: %x\n", user_env->env_pgdir,user_env->env_cr3);
	lcr3(user_env->env_cr3);
	cprintf("%x %x\n", &tf, tf.tf_eip);

	asm volatile("movl %0,%%esp\n"
		"\tpopal\n"
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" //skip tf_trapno and tf_errcode 
		"\tiret"
		: : "g" (&tf) : "memory");
	panic("iret failed");   //mostly to placate the compiler
}

int32_t
vmm_syscall1(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	
	int32_t ret = 0; 

	if(syscallno >= 0 && syscallno < NSYSCALLS)
        {
		switch(syscallno)
		{
			case VMM_SYS_cputs:
				vmm_sys_cputs((char*)a1, a2);
				ret = 0;
				break;
			case VMM_SYS_env_setup_vm:
				vmm_sys_env_setup_vm((void*) a1);
				break;
			case VMM_SYS_lcr3:;
				vmm_sys_lcr3(a1);
				break;
                        case VMM_SYS_page_alloc:
                                vmm_sys_page_alloc(a1, (struct Env*) a2, (void*)a3, a4);
                                break;
                        case VMM_SYS_load_icode:
                                vmm_sys_load_icode((void*)a1, (void*) a2, a3);
                                break;
			case VMM_SYS_run:
				vmm_sys_env_pop_tf((void*)a1);
				break;
		}
	}
	else	
	{
		ret = -E_INVAL;
	}

	return ret;	
}

