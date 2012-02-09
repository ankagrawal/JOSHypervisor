#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <inc/string.h>
#include <kern/vmm.h>

static struct Taskstate ts;
extern int adt[];
/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}

void DivideByZero();
void BadSegment();
void PageFault();
void BreakPoint();	
void syscaller();
void irq_timer();
void irq_kbd();
void irq_serial();
void irq_spurious();
void irq_ide();
void irq_error();
void vmm_syscall();

void
idt_init(void)
{
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	SETGATE( idt[0], 0, GD_KT, DivideByZero, 0);
	SETGATE( idt[13], 0, GD_KT, BadSegment, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, PageFault, 0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, BreakPoint, 3);
	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscaller, 3);
	SETGATE(idt[VMM_SYSCALL], 0, GD_KT, vmm_syscall, 3);
	SETGATE(idt[IRQ_TIMER+IRQ_OFFSET], 0, GD_KT, irq_timer, 0);		
			
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate), 0);		
	gdt[GD_TSS >> 3].sd_s = 0;

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	cprintf("  err  0x%08x\n", tf->tf_err);
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	cprintf("  esp  0x%08x\n", tf->tf_esp);
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
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

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	// Handle clock interrupts.
	// LAB 4: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	//cprintf("in trp_dispatch with tf->tf_trapno: %d\n", tf->tf_trapno);
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
		return;
	}

	if(tf->tf_trapno == T_BRKPT)
		monitor(tf);
	else if(tf->tf_trapno == T_PGFLT)
		page_fault_handler(tf);	

	else if(tf->tf_trapno == VMM_SYSCALL)
	{
		cprintf("Welcome to the Virtual Reality!!!\n");
		vmm_init();
	}
	else if(tf->tf_trapno == T_SYSCALL)
	{
		//print_trapframe(tf);
		int r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
			tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi,
			tf->tf_regs.reg_esi );
			//cprintf("\n**returning from syscall with value: %d\n",r);	
			//cprintf("curenv %d\n", curenv->env_id);
		tf->tf_regs.reg_eax = r;
	}
	else if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
		sched_yield();
	}
	// Unexpected trap: The user process or the kernel has a bug.
	else
	{	
		 cprintf("unknown trapping\n");
		  print_trapframe(tf);
		 cprintf("%x %x %x %x\n", curenv->env_id, curenv->env_tf.tf_eip, *(int* )curenv->env_tf.tf_eip, *((int*)curenv->env_tf.tf_eip - 1));
		 if (tf->tf_cs == GD_KT)
			panic("unhandled trap in kernel");
		else
		 {	
			cprintf("destroying the env now\n");
			env_destroy(curenv);
			return;
	 	}
        }
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
	//print_trapframe(tf);
	if ((tf->tf_cs & 3) == 3) 
	{
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		//cprintf("trapping from user mode\n");
		assert(curenv);
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
	//cprintf("returning from trap_dispatch\n");

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
	{
		env_run(curenv);
	}
	else
	{
		sched_yield();
	}
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
//	cprintf("fault_va = %x at kern-trap.c\n",fault_va);
	// Handle kernel-mode page faults.
/*	if(tf->tf_cs == GD_KT)
	{
		print_trapframe(tf);
		panic("page faulted in kernel");
	}*/
	// LAB 3: Your code here.
	
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall != NULL)	
	{
		user_mem_assert(curenv, (void *)(UXSTACKTOP-1), 1, PTE_P|PTE_W|PTE_U);
	        //Page fault in user stack. 	
		if( (curenv->env_tf.tf_esp < (UXSTACKTOP - PGSIZE)))
		{

			struct UTrapframe utf;

		 	utf.utf_fault_va = fault_va;
		        utf.utf_err = curenv->env_tf.tf_err;
			utf.utf_regs = curenv->env_tf.tf_regs;
			utf.utf_eip = curenv->env_tf.tf_eip;
			utf.utf_eflags =  curenv->env_tf.tf_eflags;
			utf.utf_esp = curenv->env_tf.tf_esp;	
			lcr3(curenv->env_cr3); // set so as to be able to use memset
						
			memmove((void *)((UXSTACKTOP ) - sizeof(struct UTrapframe) ), &utf, sizeof(struct UTrapframe));

			// +1 , esp set on the address just after writing the UTrapframe 
		  	curenv->env_tf.tf_esp = (UXSTACKTOP - sizeof(struct UTrapframe));      		
			curenv->env_tf.tf_eip =  (uintptr_t)curenv->env_pgfault_upcall;
			env_run(curenv);
			
		}
		else if( (curenv->env_tf.tf_esp - 4 - sizeof(struct UTrapframe)) > (UXSTACKTOP - PGSIZE)) // page fault in Exception stack
		{

			struct UTrapframe utf;

		 	utf.utf_fault_va = fault_va;
		        utf.utf_err = curenv->env_tf.tf_err;
			utf.utf_regs = curenv->env_tf.tf_regs;
			utf.utf_eip = curenv->env_tf.tf_eip;
			utf.utf_eflags =  curenv->env_tf.tf_eflags;
			utf.utf_esp = curenv->env_tf.tf_esp;	
			
			
			//pushing scratch space
			lcr3(curenv->env_cr3); // set so as to be able to use memset
			//*(uintptr_t*)(curenv->env_tf.tf_esp) = 0;
			//memset((void *)curenv->env_tf.tf_esp, 0, sizeof(int));
			memmove((void *)(curenv->env_tf.tf_esp - 4 - sizeof(struct UTrapframe)), (void *)&utf, sizeof(struct UTrapframe));
			
			// moving the esp forward
		  	curenv->env_tf.tf_esp = (curenv->env_tf.tf_esp - 4 - sizeof(struct UTrapframe) );
			//curenv->env_tf.tf_eip =  curenv->env_tf.env_pgfault_upcall;
			curenv->env_tf.tf_eip =  (uintptr_t)curenv->env_pgfault_upcall;
			env_run(curenv);
				
		}
		 
	}

	 // Exception stack overflow
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

void
break_point_handler(struct Trapframe *tf)
{
	monitor(tf);	
}

