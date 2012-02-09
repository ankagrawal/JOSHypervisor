#include <kern/vmm.h>
#include <kern/vmm_syscall.h>
#include <inc/string.h>
#include <inc/vmm_trap.h>
#include <inc/env.h>
#include <kern/env.h>
#include <kern/trap.h>
#include <inc/trap.h>
#include <kern/picirq.h>
#include <kern/sched.h>
#include <inc/mmu.h>

#define debug 0

static int timer_count;
struct Trapframe vm_saved_tf;

struct Segdesc vmm_gdt[] =
{
	// 0x0 - unused (always faults -- for trapping NULL far pointers)
	SEG_NULL,
	// 0x8 - kernel code segment
	[GD_KT >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 0),

	// 0x10 - kernel data segment
	[GD_KD >> 3] = SEG(STA_W, 0x0, 0xffffffff, 0),

	// 0x18 - user code segment
	[GD_UT >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 3),

	// 0x20 - user data segment
	[GD_UD >> 3] = SEG(STA_W, 0x0, 0xffffffff, 3),

	// 0x28 - tss, initialized in idt_init()
	[GD_TSS >> 3] = SEG_NULL
};

struct Pseudodesc vmm_gdt_pd = {
	sizeof(vmm_gdt) - 1, (unsigned long) vmm_gdt
};


struct Pseudodesc native_gdt_pd ;


struct Gatedesc native_idt[256] = { { 0 } };
struct Pseudodesc native_idt_pd = {
	sizeof(native_idt) - 1, (uint32_t) native_idt
};

struct Gatedesc vmm_idt[256] = { { 0 } };
struct Pseudodesc vmm_idt_pd = {
	sizeof(vmm_idt) - 1, (uint32_t) vmm_idt
};

void
print_native_regs(struct PushNativeRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

void
print_native_trapframe(struct NativeTrapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_native_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x\n", tf->tf_trapno);
	cprintf("  err  0x%08x\n", tf->tf_err);
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	cprintf("  esp  0x%08x\n", tf->tf_esp);
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

int
save_native_state()
{
	//storing the current gdt, idt to restore later
	cprintf("\nSaving host machine GDT...\t\t");
	memmove(native_gdt, gdt, gdt_pd.pd_lim);
	native_gdt_pd.pd_lim = sizeof(native_gdt_pd) - 1;
	native_gdt_pd.pd_base= (unsigned long) native_gdt;
	cprintf("[Done]\n");

	cprintf("\nSaving host machine IDT...\t\t");
	memmove(native_idt, idt, native_idt_pd.pd_lim);
	cprintf("[Done]\n");

	cprintf("Saving host machine state...\t\t");
	__asm __volatile("movl %%eax, %0\n" :"=r"(native_trap_frame.tf_regs.reg_eax));
	__asm __volatile("movl %%ecx, %0\n" :"=r"(native_trap_frame.tf_regs.reg_ecx));
	__asm __volatile("movl %%edx, %0\n" :"=r"(native_trap_frame.tf_regs.reg_edx));
	__asm __volatile("movl %%ebx, %0\n" :"=r"(native_trap_frame.tf_regs.reg_ebx));
	__asm __volatile("movl %%ebp, %0\n" :"=r"(native_trap_frame.tf_regs.reg_ebp));
	__asm __volatile("movl %%esi, %0\n" :"=r"(native_trap_frame.tf_regs.reg_esi));
	__asm __volatile("movl %%edi, %0\n" :"=r"(native_trap_frame.tf_regs.reg_edi));
	__asm __volatile("mov %%es, %0\n" :"=r"(native_trap_frame.tf_es));
	__asm __volatile("mov %%ds, %0\n" :"=r"(native_trap_frame.tf_ds));
	__asm __volatile("mov %%cs, %0\n" :"=r"(native_trap_frame.tf_cs));
	__asm __volatile("mov %%cs, %0\n" :"=r"(native_trap_frame.tf_eflags));
	__asm __volatile("pushfl");
	__asm __volatile("popl %eax");
	__asm __volatile("movl %%eax, %0\n" :"=r"(native_trap_frame.tf_eflags));
	__asm __volatile("movl %%esp, %0\n" :"=r"(native_trap_frame.tf_esp));
	__asm __volatile("mov %%ss, %0\n" :"=r"(native_trap_frame.tf_ss));
	if(debug)
		cprintf("native_gdt: %x sizeof(gdt): %d\n", native_gdt, gdt_pd.pd_lim);
	cprintf("[Done]\n");
	return 0;
}

int
vmm_resume()
{
	//load_vmm_state();
	//struct Env* guestOS = envs[ENVX(0x1004)];
        //guestOS.env_status = ENV_RUNNABLE;
	
	return 0;	
}

int
load_vmm_state()
{
	//creating vmm_gdt
	cprintf("\nSetting up global descriptor table...\t\t");	
	memmove(vmm_gdt, native_gdt, gdt_pd.pd_lim);
	cprintf("[Done]\n");	

	//loading vmm gdt into gdtr
	__asm __volatile("lgdt vmm_gdt_pd");
	
	cprintf("Setting up interrupt descriptor table...\t\t");	
	vmm_idt_init();
	cprintf("[Done]\n");	
	return 0;
}

int
restore_native_state()
{

	cprintf("\nRestoring host global descriptor table...\t\t");	
	//setting up the GDT
	memmove(gdt, native_gdt,  native_gdt_pd.pd_lim);
        //loading vmm gdt into gdtr
        __asm __volatile("lgdt gdt_pd");
	cprintf("[Done]\n");	

	//setting up the IDT
	cprintf("\nRestoring host interrupt descriptor table...\t\t");	
        memmove(idt, native_idt,  native_idt_pd.pd_lim);
	asm volatile("lidt idt_pd");

	cprintf("[Done]\nRestoring host machine stack set up...\t\t");	
	__asm __volatile("movl %%esp, %0\n" : :"m"(native_trap_frame.tf_esp));
	__asm __volatile("mov %%ss, %0\n" : :"m"(native_trap_frame.tf_ss));
	cprintf("[Done]\n");	
	
	return 0;
}

int
vmm_init( )
{
	int r;
		
	cprintf("\n\nSwitching from host to virtual machine...\n");
	cprintf("Saving the host machine context... \t\t");
	save_native_state();

	cprintf("Loading the Virtual Machine...\t\t");
	load_vmm_state();
	vmm_run();
	return 0;
}
	

int
vmm_suspend()
{
	restore_native_state();
	timer_count = 0;
	struct Env *guestOS = &(envs[ENVX(0x1004)]);
	guestOS->env_status = ENV_NOT_RUNNABLE;
	sched_yield();
	return 0;
}

int
vmm_exit()
{
	return 0;
}


void VMM_DivideByZero();
void VMM_BadSegment();
void VMM_PageFault();
void VMM_BreakPoint();	
void VMM_syscaller();
void VMM_irq_timer();
void VMM_irq_kbd();
void VMM_irq_serial();
void VMM_irq_spurious();
void VMM_irq_ide();
void VMM_irq_error();
void vmm_vmmsyscall();

void
vmm_idt_init(void)
{
	SETGATE( vmm_idt[0], 0, GD_KT, VMM_DivideByZero, 0);
	SETGATE( vmm_idt[13], 0, GD_KT, VMM_BadSegment, 0);
	SETGATE(vmm_idt[T_PGFLT], 0, GD_KT, VMM_PageFault, 0);
	SETGATE(vmm_idt[T_BRKPT], 0, GD_KT, VMM_BreakPoint, 3);
//	SETGATE(vmm_idt[VMM_SYSCALL], 0, GD_KT, vmm_vmmsyscall, 3);
	SETGATE(vmm_idt[T_SYSCALL], 0, GD_KT, vmm_vmmsyscall, 3);
	SETGATE(vmm_idt[IRQ_TIMER+IRQ_OFFSET], 0, GD_KT, VMM_irq_timer, 0);		
			
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	vmm_ts.ts_esp0 = KSTACKTOP;
	vmm_ts.ts_ss0 = GD_KD;

	// Initialize the TSS field of the gdt.
//	cprintf("gdt: %x GD_TSS: %x\n", gdt, GD_TSS);
	vmm_gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&vmm_ts),
					sizeof(struct Taskstate), 0);		
	vmm_gdt[GD_TSS >> 3].sd_s = 0;

	// Load the TSS
//	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt vmm_idt_pd");
}

void vmm_run()
{
	//envs[ENVX(0x1000)].env_status = ENV_NOT_RUNNABLE;
	//envs[ENVX(0x1001)].env_status = ENV_NOT_RUNNABLE;
	//envs[ENVX(0x1002)].env_status = ENV_NOT_RUNNABLE;
	//envs[ENVX(0x1003)].env_status = ENV_NOT_RUNNABLE;
	
	envs[ENVX(0x1004)].env_status = ENV_RUNNABLE;
	KERN_CR3 = (&envs[ENVX(0x1004)])->env_cr3;
	KERN_ENV = &envs[ENVX(0x1004)];

	env_run(&envs[ENVX(0x1004)]);
}

static void
vmm_trap_dispatch(struct Trapframe *tf)
{
	//if(tf->tf_trapno == VMM_SYSCALL)
	if(tf->tf_trapno == T_SYSCALL)
	{
		int r = vmm_syscall1(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
			tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi,
			tf->tf_regs.reg_esi );
	}
        else if(tf->tf_trapno == T_PGFLT)
	{
		cprintf("page faulted\n");
	}
	else if(tf->tf_trapno == 13)
	{	
		cprintf("General Protection Fault\n");
	}
	else if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
	{
//		restore_native_state();
		cprintf("Trap due to timer...\n");
//		sched_yield();
	}
}

void
vmm_trap(struct Trapframe *tf)
{
	asm volatile("cld" ::: "cc");
	cprintf("vmm_trap(); trapno: %d\n", tf->tf_trapno);
	assert(!(read_eflags() & FL_IF));

	if ((tf->tf_cs & 3) == 3) 
	{
	//	assert(curenv);
		//cprintf("vmm_trap(): from user space, tf->tf_regs.reg_esi = %x\n",tf->tf_regs.reg_esi);
		if(tf->tf_regs.reg_esi == -1)
		{
			cprintf("vmm.c : saving guest OS tarpframe...\n");			
			vm_saved_tf = *tf;	
		}
	//	curenv->env_tf = *tf;
	//	tf = &curenv->env_tf;
	}
	vmm_trap_dispatch(tf);
	struct Env guestOS = envs[ENVX(0x1004)];
	

//	if (curenv && curenv->env_status == ENV_RUNNABLE)
//	{
		//if(tf->tf_trapno == VMM_SYSCALL || tf->tf_trapno == 32)

		// handling the case just for CPrintf.
		if( tf->tf_trapno == T_SYSCALL )
		{		
			cprintf("vmm.c : Going back to guest kernel...\n");			

			if((tf->tf_regs.reg_esi != -1) && (tf->tf_regs.reg_esi ==0) )	
			{
				tf->tf_regs.reg_esi = 0; // clearing so that does not have the value -1
				cprintf("vm_saved_tf: \n");	
				print_native_trapframe((struct NativeTrapframe*)&vm_saved_tf);
				guestOS.env_tf = vm_saved_tf;

				//env_run(&envs[ENVX(0x1004)]);
				// pushing guest user's process trapframe on the guest kernel stack
				lcr3(guestOS.env_cr3);	
				cprintf("vmm.c :3  Going back to guest kernel... guestOS- ESP :%x\nCurrent TF:\n ",guestOS.env_tf.tf_esp);			
				print_native_trapframe((struct NativeTrapframe*)tf);

				//pushing guest user's trapframe on guest kernel stack
				//*((struct Trapframe*)guestOS.env_tf.tf_esp) = *tf;
				memmove( (void*)(guestOS.env_tf.tf_esp - 2*sizeof(struct Trapframe)), (void*)tf, sizeof(struct Trapframe));

				// adjusting guest kernel stack pointer i.e esp
				guestOS.env_tf.tf_esp -= sizeof(struct Trapframe);
			
				print_native_trapframe((struct NativeTrapframe*)tf);
			}			
			else
			{
				cprintf("Normal syscall from guest kernel... Restoring TF & Switching back...\n");	
				//print_native_trapframe((struct NativeTrapframe*)tf);
				guestOS.env_tf = *tf;
			}

			// switching to guest Kernel now.	
			env_run(&guestOS);		
			//curenv->env_status = ENV_NOT_RUNNABLE;
			print_native_trapframe((struct NativeTrapframe*)tf);
			panic("vmm panic\n");
		}
//	}
		else if(tf->tf_trapno == 32)
		{
			/*
				thought on timer interrupt, it should sched_yield() and switch to host kernel
				However, we keep sending it to guest OS for proof of concept.

 			*/
			if(timer_count == 10)
			{
				cprintf("Switching back to Host Machine...\nSuspending virtual machine...");
				vmm_suspend();
			}
			timer_count++;
			cprintf("vmm.c: Timer interrupt...switching back to guest kernel\ncurrent Trapframe:\n");			
			guestOS.env_tf = *tf;
			print_native_trapframe((struct NativeTrapframe*)tf);
			env_run(&guestOS);		
		}
		else
			panic("vmm.c: Page fault or General Protection Fault.\n");	
}

