/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* The VMM_TRAPHANDLER macro defines a globally-visible function for handling
 * a trap.  It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use VMM_TRAPHANDLER for traps where the CPU automatically pushes an error code.
 */ 
#define VMM_TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _vmm_alltraps

/* Use VMM_TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define VMM_TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _vmm_alltraps

.text

/*
; VMM_TRAPHANDLER_NOEC(vmm_vmmsyscall, VMM_SYSCALL)
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 VMM_TRAPHANDLER_NOEC(VMM_DivideByZero,T_DIVIDE)
 VMM_TRAPHANDLER(VMM_BadSegment,T_GPFLT)
 VMM_TRAPHANDLER(VMM_PageFault, T_PGFLT)
 VMM_TRAPHANDLER_NOEC(VMM_BreakPoint, T_BRKPT)
 VMM_TRAPHANDLER_NOEC(vmm_vmmsyscall, T_SYSCALL)


VMM_TRAPHANDLER_NOEC(VMM_irq_timer, IRQ_OFFSET + IRQ_TIMER)
VMM_TRAPHANDLER_NOEC(VMM_irq_kbd, IRQ_OFFSET + IRQ_KBD)
VMM_TRAPHANDLER_NOEC(VMM_irq_slave, IRQ_OFFSET + IRQ_SLAVE)
VMM_TRAPHANDLER_NOEC(VMM_irq_ide, IRQ_OFFSET + IRQ_IDE)
VMM_TRAPHANDLER_NOEC(VMM_irq_error, IRQ_OFFSET + IRQ_ERROR)
VMM_TRAPHANDLER_NOEC(VMM_irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
VMM_TRAPHANDLER_NOEC(VMM_irq_serial, IRQ_OFFSET + IRQ_SERIAL)
/*
 * Lab 3: Your code here for _alltraps
 */
_vmm_alltraps:
		pushl %ds
		pushl %es
		pushal
		movl $GD_KD, %eax
		movl %eax,%ds
		movl %eax,%es
		pushl %esp
		call vmm_trap



