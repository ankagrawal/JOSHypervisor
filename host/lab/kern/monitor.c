// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <inc/malloc.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line
	
unsigned int HexToDecimal(char * in)
{
	unsigned int res = 1, i = 0;
	char ch = *(in + 9);
	int len = strlen(in);
	while(len > 2)
	{
		int temp = ch;
		if(temp > 0x39)
		{
			temp = temp - 97 + 10;
		}
		else
			temp -= 0x30;
		res += (0x00000001 << (4*i)) * temp;
		i++;
		len--;
		ch = *(in + 9 - i);
	}
	res -= 1;
	return res;
}

void showmap(uintptr_t start)
{
    cprintf("%x\n", start);
    pte_t *pte = pgdir_walk(boot_pgdir, (void *)start, 0);
    if(pte == NULL)
    {
      cprintf("There is no page table entry for page starting at address: %x\n", start);
      return;
    }
    if(*pte == 0)
    {
      cprintf("There is no page table entry for page starting at address: %x .. Seems the the virtual address is not mapped\n",start);
      return;
    }
    unsigned int perm = (unsigned int) (*pte&0xfff);
    
    cprintf("\nVirtual Address\tPhysical Address\tPermissions\n");
    cprintf("%x\t\t%x\t\t",start, (*pte&~0xfff));
    if((perm&0x1)==1)
      cprintf("PTE_P");
    if((perm&0x2)==2)
      cprintf(",PTE_U");
    if((perm&0x4)==4)
      cprintf(",PTE_W");
    cprintf("\n");
    return;
}

int atoi(char *s)
{
	int l = strlen(s)-1;
	int sum = 0;
	int i = 0;
	while(l-->=0)	  
	{
	  sum =(sum*10)+(s[i++]-48);
	}
	return sum;
}

int showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if(argc < 2)
	{
	    cprintf("invalid arguments\n");
	    return 0;
	}
	uintptr_t va, end;
	int i = 1;
	while(i<argc) 
	{
	  va = HexToDecimal(argv[i]);
	  cprintf("va: %x\n",va);
	  showmap(va);	
	  i++;
	}
	return 0;
}

int page_status(int argc, char**argv, struct Trapframe *tf)
{
	if(argc>2)
	{
		cprintf("Invalid arguments\n");
		return 0;
	}
	unsigned int va = HexToDecimal(argv[1]);	
	cprintf("%x\n",va);
	struct Page *p = pa2page(va);
	if(p->pp_ref>0)
		cprintf("\tallocated\n\n");
	else
		cprintf("\tfree\n\n");
	return 0;
}

int free_page(int argc, char**argv, struct Trapframe *tf)
{
	if(argc>2)
	{
		cprintf("Invalid arguments\n");
		return 0;
	}
	unsigned int va = HexToDecimal(argv[1]);
	struct Page *p = pa2page(va);
	if(p!=NULL)
	{
		p->pp_ref = 0;
		page_free(p);
	}
	return 0;
}

int alloc_page(int argc, char**argv, struct Trapframe *tf)
{
	if(argc>1)
	{
		cprintf("Invalid arguments\n");
		return 0;
	}
	struct Page *p;
	if(page_alloc(&p)==0)
	{
		cprintf("\t%x\n\n",PADDR(p));
		p->pp_ref = 1;
	}
	else
		cprintf("page could not be allocated\n");
	return 0;
	
}

int changeperm(int argc, char**argv, struct Trapframe *tf)
{
	unsigned int perm = HexToDecimal(argv[2]);
	unsigned int va = atoi(argv[1]);
	if(perm>7)
	{
	  cprintf("Invalid permissions: enter either 1, 2, or 4\n");
	  return 0;
	}
	pte_t *pte = pgdir_walk(boot_pgdir, (void *)va, 0);
	if(pte != NULL) {
	      *pte = *pte &~0xfff;
	      *pte = *pte | perm | PTE_P;
	      cprintf("changed\n");
	      return 0; 
	}
	else
	{
	    cprintf("Page Table entry not found!\n");
	}
	return 0;
}

struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display BACKTRACE information of the current function", mon_backtrace},
	{"showmappings", "Display the mapping of the range of virtual/linear addresses",showmappings},
	{"changeperm", "Change the permission of a page",changeperm},
	{"alloc_page", "Allocate a page", alloc_page},
	{"page_status", "Status of a page", page_status},
	{"free_page", "Free a page", free_page}
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n",commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int ebp_lst, ebp_cur, ebp_prev, eip_cur, args[5];
	//__asm __volatile("movl %%ebp, %0;":"=r"(ebp_cur));
	ebp_cur = (uint32_t)read_ebp();
	cprintf("Stack backtrace:\n");
	eip_cur = (uint32_t)read_eip();
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
	{
		if(ebp_cur == 0)
			k =0;				
		memset(e, 0, sizeof(struct Eipdebuginfo));
		debuginfo_eip(eip_cur, e);
		__asm __volatile("movl 8(%1), %0;":"=r"(args[0]):"r"(ebp_cur));
		__asm __volatile("movl 12(%1), %0;":"=r"(args[1]):"r"(ebp_cur));
		__asm __volatile("movl 16(%1), %0;":"=r"(args[2]):"r"(ebp_cur));
		__asm __volatile("movl 20(%1), %0;":"=r"(args[3]):"r"(ebp_cur));
		__asm __volatile("movl 24(%1), %0;":"=r"(args[4]):"r"(ebp_cur));
		char s[256];
		strcpy(s, e->eip_fn_name);
		s[e->eip_fn_namelen] = '\0';
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", ebp_cur, eip_cur, args[0], args[1], args[2], args[3], args[4]);
		cprintf("%s:%d:  %s+%d\n", e->eip_file, e->eip_line,s, eip_cur-e->eip_fn_addr);

		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		

	} 
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);	
	else
		cprintf("tf is null\n");

	cprintf("just before while of coming out of monitor\n");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
	cprintf("coming out of monitor\n");
}

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
	return callerpc;
}
