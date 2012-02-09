
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

00800020 <_start-0xc>:

	# Set the stack pointer
#	movl	$(bootstacktop),%esp

	# now to C code
	push $0
  800020:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
  800026:	00 00                	add    %al,(%eax)
  800028:	fb                   	sti    
  800029:	4f                   	dec    %edi
  80002a:	52                   	push   %edx
  80002b:	e4 6a                	in     $0x6a,%al

0080002c <_start>:
  80002c:	6a 00                	push   $0x0
	push $0
  80002e:	6a 00                	push   $0x0
	call	i386_init
  800030:	e8 af 00 00 00       	call   8000e4 <i386_init>
	...

00800040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
  800047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
  80004a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800051:	8b 45 08             	mov    0x8(%ebp),%eax
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 80 1d 80 00 	movl   $0x801d80,(%esp)
  80005f:	e8 39 15 00 00       	call   80159d <cprintf>
	vcprintf(fmt, ap);
  800064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800068:	8b 45 10             	mov    0x10(%ebp),%eax
  80006b:	89 04 24             	mov    %eax,(%esp)
  80006e:	e8 c9 14 00 00       	call   80153c <vcprintf>
	cprintf("\n");
  800073:	c7 04 24 a6 1e 80 00 	movl   $0x801ea6,(%esp)
  80007a:	e8 1e 15 00 00       	call   80159d <cprintf>
	va_end(ap);
}
  80007f:	83 c4 14             	add    $0x14,%esp
  800082:	5b                   	pop    %ebx
  800083:	5d                   	pop    %ebp
  800084:	c3                   	ret    

00800085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800085:	55                   	push   %ebp
  800086:	89 e5                	mov    %esp,%ebp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	83 ec 10             	sub    $0x10,%esp
  80008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
  800090:	83 3d a0 fc 80 00 00 	cmpl   $0x0,0x80fca0
  800097:	75 3d                	jne    8000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
  800099:	89 35 a0 fc 80 00    	mov    %esi,0x80fca0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
  80009f:	fa                   	cli    
  8000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  8000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
  8000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b2:	c7 04 24 9a 1d 80 00 	movl   $0x801d9a,(%esp)
  8000b9:	e8 df 14 00 00       	call   80159d <cprintf>
	vcprintf(fmt, ap);
  8000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c2:	89 34 24             	mov    %esi,(%esp)
  8000c5:	e8 72 14 00 00       	call   80153c <vcprintf>
	cprintf("\n");
  8000ca:	c7 04 24 a6 1e 80 00 	movl   $0x801ea6,(%esp)
  8000d1:	e8 c7 14 00 00       	call   80159d <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
  8000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000dd:	e8 ee 01 00 00       	call   8002d0 <monitor>
  8000e2:	eb f2                	jmp    8000d6 <_panic+0x51>

008000e4 <i386_init>:
}


void
i386_init(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
		cprintf("\n******************\nWelcome to Guest JOS...\n********************\n");
  8000ea:	c7 04 24 08 1e 80 00 	movl   $0x801e08,(%esp)
  8000f1:	e8 a7 14 00 00       	call   80159d <cprintf>
		env_init();
  8000f6:	e8 15 17 00 00       	call   801810 <env_init>
		cprintf("Running User binary abc...\n");
  8000fb:	c7 04 24 b2 1d 80 00 	movl   $0x801db2,(%esp)
  800102:	e8 96 14 00 00       	call   80159d <cprintf>
		ENV_CREATE(abc);
  800107:	c7 44 24 04 89 cc 00 	movl   $0xcc89,0x4(%esp)
  80010e:	00 
  80010f:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  800116:	e8 25 19 00 00       	call   801a40 <env_create>
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <test_backtrace>:
#include <kern/env.h>

// Test the stack backtrace function (lab 1 only/)
void
test_backtrace(int x)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	53                   	push   %ebx
  800121:	83 ec 14             	sub    $0x14,%esp
  800124:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
  800127:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012b:	c7 04 24 ce 1d 80 00 	movl   $0x801dce,(%esp)
  800132:	e8 66 14 00 00       	call   80159d <cprintf>
	if (x > 0)
  800137:	85 db                	test   %ebx,%ebx
  800139:	7e 0d                	jle    800148 <test_backtrace+0x2b>
		test_backtrace(x-1);
  80013b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80013e:	89 04 24             	mov    %eax,(%esp)
  800141:	e8 d7 ff ff ff       	call   80011d <test_backtrace>
  800146:	eb 1c                	jmp    800164 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
  800148:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80014f:	00 
  800150:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800157:	00 
  800158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015f:	e8 a4 02 00 00       	call   800408 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
  800164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800168:	c7 04 24 ea 1d 80 00 	movl   $0x801dea,(%esp)
  80016f:	e8 29 14 00 00       	call   80159d <cprintf>
}
  800174:	83 c4 14             	add    $0x14,%esp
  800177:	5b                   	pop    %ebx
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
	...

0080017c <getchar>:
        sys_cputs(&c, 1);
}

int
getchar(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
        int r = 0;
        // sys_cgetc does not block, but getchar should.
        //while ((r = sys_cgetc()) == 0);
                //sys_yield();
        return r;
}
  80017f:	b8 00 00 00 00       	mov    $0x0,%eax
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	83 ec 28             	sub    $0x28,%esp
        char c = ch;
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	88 45 f7             	mov    %al,-0x9(%ebp)

        // Unlike standard Unix's putchar,
        // the cputchar function _always_ outputs to the system console.
        sys_cputs(&c, 1);
  800192:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800199:	00 
  80019a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 12 07 00 00       	call   8008b7 <sys_cputs>
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    
	...

008001b0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
  8001b3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
  8001be:	c7 04 24 4a 1e 80 00 	movl   $0x801e4a,(%esp)
  8001c5:	e8 d3 13 00 00       	call   80159d <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
  8001ca:	c7 44 24 08 2c 00 80 	movl   $0x1080002c,0x8(%esp)
  8001d1:	10 
  8001d2:	c7 44 24 04 2c 00 80 	movl   $0x80002c,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  8001e1:	e8 b7 13 00 00       	call   80159d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
  8001e6:	c7 44 24 08 75 1d 80 	movl   $0x10801d75,0x8(%esp)
  8001ed:	10 
  8001ee:	c7 44 24 04 75 1d 80 	movl   $0x801d75,0x4(%esp)
  8001f5:	00 
  8001f6:	c7 04 24 24 1f 80 00 	movl   $0x801f24,(%esp)
  8001fd:	e8 9b 13 00 00       	call   80159d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
  800202:	c7 44 24 08 91 fc 80 	movl   $0x1080fc91,0x8(%esp)
  800209:	10 
  80020a:	c7 44 24 04 91 fc 80 	movl   $0x80fc91,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 48 1f 80 00 	movl   $0x801f48,(%esp)
  800219:	e8 7f 13 00 00       	call   80159d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
  80021e:	c7 44 24 08 a4 10 81 	movl   $0x108110a4,0x8(%esp)
  800225:	10 
  800226:	c7 44 24 04 a4 10 81 	movl   $0x8110a4,0x4(%esp)
  80022d:	00 
  80022e:	c7 04 24 6c 1f 80 00 	movl   $0x801f6c,(%esp)
  800235:	e8 63 13 00 00       	call   80159d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
  80023a:	b8 a3 14 81 00       	mov    $0x8114a3,%eax
  80023f:	2d 2c 00 80 00       	sub    $0x80002c,%eax
  800244:	89 c2                	mov    %eax,%edx
  800246:	c1 fa 1f             	sar    $0x1f,%edx
  800249:	c1 ea 16             	shr    $0x16,%edx
  80024c:	8d 04 02             	lea    (%edx,%eax,1),%eax
  80024f:	c1 f8 0a             	sar    $0xa,%eax
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	c7 04 24 90 1f 80 00 	movl   $0x801f90,(%esp)
  80025d:	e8 3b 13 00 00       	call   80159d <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
  800262:	b8 00 00 00 00       	mov    $0x0,%eax
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n",commands[i].name, commands[i].desc);
  80026f:	a1 a4 20 80 00       	mov    0x8020a4,%eax
  800274:	89 44 24 08          	mov    %eax,0x8(%esp)
  800278:	a1 a0 20 80 00       	mov    0x8020a0,%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	c7 04 24 63 1e 80 00 	movl   $0x801e63,(%esp)
  800288:	e8 10 13 00 00       	call   80159d <cprintf>
  80028d:	a1 b0 20 80 00       	mov    0x8020b0,%eax
  800292:	89 44 24 08          	mov    %eax,0x8(%esp)
  800296:	a1 ac 20 80 00       	mov    0x8020ac,%eax
  80029b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029f:	c7 04 24 63 1e 80 00 	movl   $0x801e63,(%esp)
  8002a6:	e8 f2 12 00 00       	call   80159d <cprintf>
  8002ab:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  8002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b4:	a1 b8 20 80 00       	mov    0x8020b8,%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	c7 04 24 63 1e 80 00 	movl   $0x801e63,(%esp)
  8002c4:	e8 d4 12 00 00       	call   80159d <cprintf>
	return 0;
}
  8002c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
  8002d9:	c7 04 24 bc 1f 80 00 	movl   $0x801fbc,(%esp)
  8002e0:	e8 b8 12 00 00       	call   80159d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
  8002e5:	c7 04 24 e0 1f 80 00 	movl   $0x801fe0,(%esp)
  8002ec:	e8 ac 12 00 00       	call   80159d <cprintf>


	while (1) {
		buf = readline("K> ");
  8002f1:	c7 04 24 6c 1e 80 00 	movl   $0x801e6c,(%esp)
  8002f8:	e8 73 0d 00 00       	call   801070 <readline>
  8002fd:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
  8002ff:	85 c0                	test   %eax,%eax
  800301:	74 ee                	je     8002f1 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
  800303:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
  80030a:	be 00 00 00 00       	mov    $0x0,%esi
  80030f:	eb 06                	jmp    800317 <monitor+0x47>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
  800311:	c6 03 00             	movb   $0x0,(%ebx)
  800314:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  800317:	0f b6 03             	movzbl (%ebx),%eax
  80031a:	84 c0                	test   %al,%al
  80031c:	74 6d                	je     80038b <monitor+0xbb>
  80031e:	0f be c0             	movsbl %al,%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	c7 04 24 70 1e 80 00 	movl   $0x801e70,(%esp)
  80032c:	e8 4d 0f 00 00       	call   80127e <strchr>
  800331:	85 c0                	test   %eax,%eax
  800333:	75 dc                	jne    800311 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
  800335:	80 3b 00             	cmpb   $0x0,(%ebx)
  800338:	74 51                	je     80038b <monitor+0xbb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
  80033a:	83 fe 0f             	cmp    $0xf,%esi
  80033d:	8d 76 00             	lea    0x0(%esi),%esi
  800340:	75 16                	jne    800358 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
  800342:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 75 1e 80 00 	movl   $0x801e75,(%esp)
  800351:	e8 47 12 00 00       	call   80159d <cprintf>
  800356:	eb 99                	jmp    8002f1 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
  800358:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
  80035c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
  80035f:	0f b6 03             	movzbl (%ebx),%eax
  800362:	84 c0                	test   %al,%al
  800364:	75 0c                	jne    800372 <monitor+0xa2>
  800366:	eb af                	jmp    800317 <monitor+0x47>
			buf++;
  800368:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
  80036b:	0f b6 03             	movzbl (%ebx),%eax
  80036e:	84 c0                	test   %al,%al
  800370:	74 a5                	je     800317 <monitor+0x47>
  800372:	0f be c0             	movsbl %al,%eax
  800375:	89 44 24 04          	mov    %eax,0x4(%esp)
  800379:	c7 04 24 70 1e 80 00 	movl   $0x801e70,(%esp)
  800380:	e8 f9 0e 00 00       	call   80127e <strchr>
  800385:	85 c0                	test   %eax,%eax
  800387:	74 df                	je     800368 <monitor+0x98>
  800389:	eb 8c                	jmp    800317 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
  80038b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  800392:	00 

	// Lookup and invoke the command
	if (argc == 0)
  800393:	85 f6                	test   %esi,%esi
  800395:	0f 84 56 ff ff ff    	je     8002f1 <monitor+0x21>
  80039b:	bb a0 20 80 00       	mov    $0x8020a0,%ebx
  8003a0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
  8003a5:	8b 03                	mov    (%ebx),%eax
  8003a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ab:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	e8 53 0e 00 00       	call   801209 <strcmp>
  8003b6:	85 c0                	test   %eax,%eax
  8003b8:	75 23                	jne    8003dd <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
  8003ba:	6b ff 0c             	imul   $0xc,%edi,%edi
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c4:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8003c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cb:	89 34 24             	mov    %esi,(%esp)
  8003ce:	ff 97 a8 20 80 00    	call   *0x8020a8(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	78 28                	js     800400 <monitor+0x130>
  8003d8:	e9 14 ff ff ff       	jmp    8002f1 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
  8003dd:	83 c7 01             	add    $0x1,%edi
  8003e0:	83 c3 0c             	add    $0xc,%ebx
  8003e3:	83 ff 03             	cmp    $0x3,%edi
  8003e6:	75 bd                	jne    8003a5 <monitor+0xd5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
  8003e8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8003eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ef:	c7 04 24 92 1e 80 00 	movl   $0x801e92,(%esp)
  8003f6:	e8 a2 11 00 00       	call   80159d <cprintf>
  8003fb:	e9 f1 fe ff ff       	jmp    8002f1 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
  800400:	83 c4 5c             	add    $0x5c,%esp
  800403:	5b                   	pop    %ebx
  800404:	5e                   	pop    %esi
  800405:	5f                   	pop    %edi
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	57                   	push   %edi
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
  80040e:	81 ec 4c 01 00 00    	sub    $0x14c,%esp
	// Your code here.
	int ebp_lst, ebp_cur, ebp_prev, eip_cur, args[5];
	//__asm __volatile("movl %%ebp, %0;":"=r"(ebp_cur));
	ebp_cur = (uint32_t)read_ebp();
  800414:	89 eb                	mov    %ebp,%ebx
	cprintf("Stack backtrace:\n");
  800416:	c7 04 24 a8 1e 80 00 	movl   $0x801ea8,(%esp)
  80041d:	e8 7b 11 00 00       	call   80159d <cprintf>
	eip_cur = (uint32_t)read_eip();
  800422:	e8 89 fd ff ff       	call   8001b0 <read_eip>
  800427:	89 c7                	mov    %eax,%edi
  800429:	c7 85 e4 fe ff ff 01 	movl   $0x1,-0x11c(%ebp)
  800430:	00 00 00 
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
	{
		if(ebp_cur == 0)
  800433:	83 fb 01             	cmp    $0x1,%ebx
  800436:	19 c0                	sbb    %eax,%eax
  800438:	f7 d0                	not    %eax
  80043a:	21 85 e4 fe ff ff    	and    %eax,-0x11c(%ebp)
			k =0;				
		memset(e, 0, sizeof(struct Eipdebuginfo));
  800440:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
  800447:	00 
  800448:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80044f:	00 
  800450:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800457:	e8 7a 0e 00 00       	call   8012d6 <memset>
		debuginfo_eip(eip_cur, e);
  80045c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800463:	00 
  800464:	89 3c 24             	mov    %edi,(%esp)
  800467:	e8 12 02 00 00       	call   80067e <debuginfo_eip>
		__asm __volatile("movl 8(%1), %0;":"=r"(args[0]):"r"(ebp_cur));
  80046c:	8b 43 08             	mov    0x8(%ebx),%eax
  80046f:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
		__asm __volatile("movl 12(%1), %0;":"=r"(args[1]):"r"(ebp_cur));
  800475:	8b 4b 0c             	mov    0xc(%ebx),%ecx
  800478:	89 8d dc fe ff ff    	mov    %ecx,-0x124(%ebp)
		__asm __volatile("movl 16(%1), %0;":"=r"(args[2]):"r"(ebp_cur));
  80047e:	8b 43 10             	mov    0x10(%ebx),%eax
  800481:	89 85 d8 fe ff ff    	mov    %eax,-0x128(%ebp)
		__asm __volatile("movl 20(%1), %0;":"=r"(args[3]):"r"(ebp_cur));
  800487:	8b 4b 14             	mov    0x14(%ebx),%ecx
  80048a:	89 8d d4 fe ff ff    	mov    %ecx,-0x12c(%ebp)
		__asm __volatile("movl 24(%1), %0;":"=r"(args[4]):"r"(ebp_cur));
  800490:	8b 43 18             	mov    0x18(%ebx),%eax
  800493:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
		char s[256];
		strcpy(s, e->eip_fn_name);
  800499:	be 00 00 00 00       	mov    $0x0,%esi
  80049e:	8b 46 08             	mov    0x8(%esi),%eax
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	8d 8d e8 fe ff ff    	lea    -0x118(%ebp),%ecx
  8004ab:	89 0c 24             	mov    %ecx,(%esp)
  8004ae:	e8 c7 0c 00 00       	call   80117a <strcpy>
		s[e->eip_fn_namelen] = '\0';
  8004b3:	8b 46 0c             	mov    0xc(%esi),%eax
  8004b6:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
  8004bd:	00 
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", ebp_cur, eip_cur, args[0], args[1], args[2], args[3], args[4]);
  8004be:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
  8004c4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8004c8:	8b 8d d4 fe ff ff    	mov    -0x12c(%ebp),%ecx
  8004ce:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8004d2:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
  8004d8:	89 44 24 14          	mov    %eax,0x14(%esp)
  8004dc:	8b 8d dc fe ff ff    	mov    -0x124(%ebp),%ecx
  8004e2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004e6:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8004f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f8:	c7 04 24 08 20 80 00 	movl   $0x802008,(%esp)
  8004ff:	e8 99 10 00 00       	call   80159d <cprintf>
		cprintf("%s:%d:  %s+%d\n", e->eip_file, e->eip_line,s, eip_cur-e->eip_fn_addr);
  800504:	8b 56 04             	mov    0x4(%esi),%edx
  800507:	8b 06                	mov    (%esi),%eax
  800509:	2b 7e 10             	sub    0x10(%esi),%edi
  80050c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800510:	8d 8d e8 fe ff ff    	lea    -0x118(%ebp),%ecx
  800516:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80051a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80051e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800522:	c7 04 24 ba 1e 80 00 	movl   $0x801eba,(%esp)
  800529:	e8 6f 10 00 00       	call   80159d <cprintf>

		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
  80052e:	8b 7b 04             	mov    0x4(%ebx),%edi
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		
  800531:	8b 1b                	mov    (%ebx),%ebx
	ebp_cur = (uint32_t)read_ebp();
	cprintf("Stack backtrace:\n");
	eip_cur = (uint32_t)read_eip();
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
  800533:	83 bd e4 fe ff ff 00 	cmpl   $0x0,-0x11c(%ebp)
  80053a:	0f 85 f3 fe ff ff    	jne    800433 <mon_backtrace+0x2b>
		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		

	} 
	return 0;
}
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	81 c4 4c 01 00 00    	add    $0x14c,%esp
  80054b:	5b                   	pop    %ebx
  80054c:	5e                   	pop    %esi
  80054d:	5f                   	pop    %edi
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 14             	sub    $0x14,%esp
  800559:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80055c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80055f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
  800565:	8b 1a                	mov    (%edx),%ebx
  800567:	8b 01                	mov    (%ecx),%eax
  800569:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
  80056c:	39 c3                	cmp    %eax,%ebx
  80056e:	0f 8f 9c 00 00 00    	jg     800610 <stab_binsearch+0xc0>
  800574:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
  80057b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80057e:	01 d8                	add    %ebx,%eax
  800580:	89 c7                	mov    %eax,%edi
  800582:	c1 ef 1f             	shr    $0x1f,%edi
  800585:	01 c7                	add    %eax,%edi
  800587:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
  800589:	39 df                	cmp    %ebx,%edi
  80058b:	7c 33                	jl     8005c0 <stab_binsearch+0x70>
  80058d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
  800590:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800593:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
  800598:	39 f0                	cmp    %esi,%eax
  80059a:	0f 84 bc 00 00 00    	je     80065c <stab_binsearch+0x10c>
  8005a0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
  8005a4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
  8005a8:	89 f8                	mov    %edi,%eax
			m--;
  8005aa:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
  8005ad:	39 d8                	cmp    %ebx,%eax
  8005af:	7c 0f                	jl     8005c0 <stab_binsearch+0x70>
  8005b1:	0f b6 0a             	movzbl (%edx),%ecx
  8005b4:	83 ea 0c             	sub    $0xc,%edx
  8005b7:	39 f1                	cmp    %esi,%ecx
  8005b9:	75 ef                	jne    8005aa <stab_binsearch+0x5a>
  8005bb:	e9 9e 00 00 00       	jmp    80065e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
  8005c0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
  8005c3:	eb 3c                	jmp    800601 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
  8005c5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005c8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
  8005ca:	8d 5f 01             	lea    0x1(%edi),%ebx
  8005cd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  8005d4:	eb 2b                	jmp    800601 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
  8005d6:	3b 55 0c             	cmp    0xc(%ebp),%edx
  8005d9:	76 14                	jbe    8005ef <stab_binsearch+0x9f>
			*region_right = m - 1;
  8005db:	83 e8 01             	sub    $0x1,%eax
  8005de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e4:	89 02                	mov    %eax,(%edx)
  8005e6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  8005ed:	eb 12                	jmp    800601 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
  8005ef:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005f2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
  8005f4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  8005f8:	89 c3                	mov    %eax,%ebx
  8005fa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
  800601:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
  800604:	0f 8d 71 ff ff ff    	jge    80057b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
  80060a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060e:	75 0f                	jne    80061f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
  800610:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800613:	8b 03                	mov    (%ebx),%eax
  800615:	83 e8 01             	sub    $0x1,%eax
  800618:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80061b:	89 02                	mov    %eax,(%edx)
  80061d:	eb 57                	jmp    800676 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  80061f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800622:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
  800624:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800627:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800629:	39 c1                	cmp    %eax,%ecx
  80062b:	7d 28                	jge    800655 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
  80062d:	8d 14 40             	lea    (%eax,%eax,2),%edx
  800630:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800633:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
  800638:	39 f2                	cmp    %esi,%edx
  80063a:	74 19                	je     800655 <stab_binsearch+0x105>
  80063c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
  800640:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
  800644:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800647:	39 c1                	cmp    %eax,%ecx
  800649:	7d 0a                	jge    800655 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
  80064b:	0f b6 1a             	movzbl (%edx),%ebx
  80064e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
  800651:	39 f3                	cmp    %esi,%ebx
  800653:	75 ef                	jne    800644 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
  800655:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800658:	89 02                	mov    %eax,(%edx)
  80065a:	eb 1a                	jmp    800676 <stab_binsearch+0x126>
	}
}
  80065c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
  80065e:	8d 14 40             	lea    (%eax,%eax,2),%edx
  800661:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800664:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
  800668:	3b 55 0c             	cmp    0xc(%ebp),%edx
  80066b:	0f 82 54 ff ff ff    	jb     8005c5 <stab_binsearch+0x75>
  800671:	e9 60 ff ff ff       	jmp    8005d6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
  800676:	83 c4 14             	add    $0x14,%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 48             	sub    $0x48,%esp
  800684:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800687:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80068a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80068d:	8b 75 08             	mov    0x8(%ebp),%esi
  800690:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
  800693:	c7 03 c4 20 80 00    	movl   $0x8020c4,(%ebx)
	info->eip_line = 0;
  800699:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
  8006a0:	c7 43 08 c4 20 80 00 	movl   $0x8020c4,0x8(%ebx)
	info->eip_fn_namelen = 9;
  8006a7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
  8006ae:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
  8006b1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
  8006b8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
  8006be:	76 12                	jbe    8006d2 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  8006c0:	b8 a0 62 20 00       	mov    $0x2062a0,%eax
  8006c5:	3d 69 3e 20 00       	cmp    $0x203e69,%eax
  8006ca:	0f 86 a2 01 00 00    	jbe    800872 <debuginfo_eip+0x1f4>
  8006d0:	eb 1c                	jmp    8006ee <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
  8006d2:	c7 44 24 08 ce 20 80 	movl   $0x8020ce,0x8(%esp)
  8006d9:	00 
  8006da:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8006e1:	00 
  8006e2:	c7 04 24 db 20 80 00 	movl   $0x8020db,(%esp)
  8006e9:	e8 97 f9 ff ff       	call   800085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  8006ee:	80 3d 9f 62 20 00 00 	cmpb   $0x0,0x20629f
  8006f5:	0f 85 77 01 00 00    	jne    800872 <debuginfo_eip+0x1f4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
  8006fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
  800702:	b8 68 3e 20 00       	mov    $0x203e68,%eax
  800707:	2d 10 00 20 00       	sub    $0x200010,%eax
  80070c:	c1 f8 02             	sar    $0x2,%eax
  80070f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  800715:	83 e8 01             	sub    $0x1,%eax
  800718:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  80071b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  80071e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800721:	89 74 24 04          	mov    %esi,0x4(%esp)
  800725:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  80072c:	b8 10 00 20 00       	mov    $0x200010,%eax
  800731:	e8 1a fe ff ff       	call   800550 <stab_binsearch>
	if (lfile == 0)
  800736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800739:	85 c0                	test   %eax,%eax
  80073b:	0f 84 31 01 00 00    	je     800872 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
  800741:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
  800744:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800747:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  80074a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  80074d:	8d 55 dc             	lea    -0x24(%ebp),%edx
  800750:	89 74 24 04          	mov    %esi,0x4(%esp)
  800754:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
  80075b:	b8 10 00 20 00       	mov    $0x200010,%eax
  800760:	e8 eb fd ff ff       	call   800550 <stab_binsearch>

	if (lfun <= rfun) {
  800765:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800768:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80076b:	7f 3c                	jg     8007a9 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
  80076d:	6b c0 0c             	imul   $0xc,%eax,%eax
  800770:	8b 80 10 00 20 00    	mov    0x200010(%eax),%eax
  800776:	ba a0 62 20 00       	mov    $0x2062a0,%edx
  80077b:	81 ea 69 3e 20 00    	sub    $0x203e69,%edx
  800781:	39 d0                	cmp    %edx,%eax
  800783:	73 08                	jae    80078d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  800785:	05 69 3e 20 00       	add    $0x203e69,%eax
  80078a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
  80078d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800790:	6b d0 0c             	imul   $0xc,%eax,%edx
  800793:	8b 92 18 00 20 00    	mov    0x200018(%edx),%edx
  800799:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
  80079c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
  80079e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
  8007a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a7:	eb 0f                	jmp    8007b8 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
  8007a9:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
  8007ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
  8007b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  8007b8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8007bf:	00 
  8007c0:	8b 43 08             	mov    0x8(%ebx),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 e0 0a 00 00       	call   8012ab <strfind>
  8007cb:	2b 43 08             	sub    0x8(%ebx),%eax
  8007ce:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  8007d1:	8d 4d d0             	lea    -0x30(%ebp),%ecx
  8007d4:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  8007d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007db:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
  8007e2:	b8 10 00 20 00       	mov    $0x200010,%eax
  8007e7:	e8 64 fd ff ff       	call   800550 <stab_binsearch>
	if(lline <= rline) {
  8007ec:	8b 55 d0             	mov    -0x30(%ebp),%edx
		info->eip_line = rline;
  8007ef:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8007f2:	0f 9e c0             	setle  %al
  8007f5:	0f b6 c0             	movzbl %al,%eax
  8007f8:	83 e8 01             	sub    $0x1,%eax
  8007fb:	09 d0                	or     %edx,%eax
  8007fd:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
  800800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800803:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800806:	6b d0 0c             	imul   $0xc,%eax,%edx
  800809:	81 c2 18 00 20 00    	add    $0x200018,%edx
  80080f:	eb 06                	jmp    800817 <debuginfo_eip+0x199>

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline) {
		info->eip_line = rline;
	} else {
		info->eip_line = -1;
  800811:	83 e8 01             	sub    $0x1,%eax
  800814:	83 ea 0c             	sub    $0xc,%edx
  800817:	89 c6                	mov    %eax,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
  800819:	39 f8                	cmp    %edi,%eax
  80081b:	7c 24                	jl     800841 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
  80081d:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
  800821:	80 f9 84             	cmp    $0x84,%cl
  800824:	74 65                	je     80088b <debuginfo_eip+0x20d>
  800826:	80 f9 64             	cmp    $0x64,%cl
  800829:	75 e6                	jne    800811 <debuginfo_eip+0x193>
  80082b:	83 3a 00             	cmpl   $0x0,(%edx)
  80082e:	66 90                	xchg   %ax,%ax
  800830:	74 df                	je     800811 <debuginfo_eip+0x193>
  800832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800838:	eb 51                	jmp    80088b <debuginfo_eip+0x20d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
  80083a:	05 69 3e 20 00       	add    $0x203e69,%eax
  80083f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
  800841:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800844:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800847:	7d 30                	jge    800879 <debuginfo_eip+0x1fb>
		for (lline = lfun + 1;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
  80084f:	ba 10 00 20 00       	mov    $0x200010,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
  800854:	eb 08                	jmp    80085e <debuginfo_eip+0x1e0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
  800856:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
  80085a:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
  80085e:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
  800861:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800864:	7d 13                	jge    800879 <debuginfo_eip+0x1fb>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
  800866:	6b c0 0c             	imul   $0xc,%eax,%eax
  800869:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
  80086e:	74 e6                	je     800856 <debuginfo_eip+0x1d8>
  800870:	eb 07                	jmp    800879 <debuginfo_eip+0x1fb>
  800872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800877:	eb 05                	jmp    80087e <debuginfo_eip+0x200>
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
  80087e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800881:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800884:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800887:	89 ec                	mov    %ebp,%esp
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
  80088b:	6b c6 0c             	imul   $0xc,%esi,%eax
  80088e:	8b 80 10 00 20 00    	mov    0x200010(%eax),%eax
  800894:	ba a0 62 20 00       	mov    $0x2062a0,%edx
  800899:	81 ea 69 3e 20 00    	sub    $0x203e69,%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	72 97                	jb     80083a <debuginfo_eip+0x1bc>
  8008a3:	eb 9c                	jmp    800841 <debuginfo_eip+0x1c3>
  8008a5:	00 00                	add    %al,(%eax)
	...

008008a8 <getEnvID>:
  //              panic("syscall %d returned %d (> 0)", num, ret);
        return ret;
}

void getEnvID(char* msg)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
	//VMM_ID = curenv.env_id; 	
//	cprintf("%s\n",msg);
	VMM_ID = -1;	
  8008ab:	c7 05 a4 fc 80 00 ff 	movl   $0xffffffff,0x80fca4
  8008b2:	ff ff ff 
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 10             	sub    $0x10,%esp
  8008bd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008c0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008c3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_cputs() From Guest OS...");
  8008c6:	c7 04 24 e9 20 80 00 	movl   $0x8020e9,(%esp)
  8008cd:	e8 d6 ff ff ff       	call   8008a8 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e3:	89 c3                	mov    %eax,%ebx
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	cd 30                	int    $0x30
void
sys_cputs(const char *s, size_t len)
{
	getEnvID("sys_cputs() From Guest OS...");
        syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, VMM_ID);
}
  8008e9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8008ec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8008ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8008f2:	89 ec                	mov    %ebp,%esp
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <sys_env_setup_vm>:

int
sys_env_setup_vm(void *e )
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 10             	sub    $0x10,%esp
  8008fc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008ff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800902:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_env_setup() From Guest OS...");
  800905:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  80090c:	e8 97 ff ff ff       	call   8008a8 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  80091c:	b8 01 00 00 00       	mov    $0x1,%eax
  800921:	8b 55 08             	mov    0x8(%ebp),%edx
  800924:	89 cb                	mov    %ecx,%ebx
  800926:	89 cf                	mov    %ecx,%edi
  800928:	cd 30                	int    $0x30
sys_env_setup_vm(void *e )
{
	getEnvID("sys_env_setup() From Guest OS...");
	int r = syscall(SYS_env_setup_vm, 0, (uint32_t)e, 0, 0, 0, VMM_ID);
	return r;
}
  80092a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80092d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800930:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800933:	89 ec                	mov    %ebp,%esp
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <sys_page_alloc>:

int
sys_page_alloc(int i, struct Env* e, void* va, int perm)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 10             	sub    $0x10,%esp
  80093d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800940:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800943:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_page_alloc() From Guest OS...");
  800946:	c7 04 24 48 21 80 00 	movl   $0x802148,(%esp)
  80094d:	e8 56 ff ff ff       	call   8008a8 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  800952:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  800958:	b8 02 00 00 00       	mov    $0x2,%eax
  80095d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800960:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800966:	8b 55 08             	mov    0x8(%ebp),%edx
  800969:	cd 30                	int    $0x30
sys_page_alloc(int i, struct Env* e, void* va, int perm)
{
	getEnvID("sys_page_alloc() From Guest OS...");
	int r = syscall(SYS_page_alloc, 0, i, (uint32_t)e, (uint32_t)va, perm, VMM_ID);
	return r;
}
  80096b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80096e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800971:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800974:	89 ec                	mov    %ebp,%esp
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <sys_load_icode>:


int
sys_load_icode(void* e, void* b, int len)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 10             	sub    $0x10,%esp
  80097e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800981:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800984:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_load_icode() From Guest OS...");
  800987:	c7 04 24 6c 21 80 00 	movl   $0x80216c,(%esp)
  80098e:	e8 15 ff ff ff       	call   8008a8 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  800993:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  800999:	bf 00 00 00 00       	mov    $0x0,%edi
  80099e:	b8 04 00 00 00       	mov    $0x4,%eax
  8009a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ac:	cd 30                	int    $0x30
sys_load_icode(void* e, void* b, int len)
{
	getEnvID("sys_load_icode() From Guest OS...");
	int r = syscall(SYS_load_icode, 0, (uint32_t)e, (uint32_t)b, len, 0, VMM_ID);
	return r;
}
  8009ae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009b1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009b4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009b7:	89 ec                	mov    %ebp,%esp
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <sys_lcr3>:

int
sys_lcr3(uint32_t cr3)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 10             	sub    $0x10,%esp
  8009c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_lcr3() From Guest OS...");
  8009ca:	c7 04 24 06 21 80 00 	movl   $0x802106,(%esp)
  8009d1:	e8 d2 fe ff ff       	call   8008a8 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  8009d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009db:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  8009e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8009e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e9:	89 cb                	mov    %ecx,%ebx
  8009eb:	89 cf                	mov    %ecx,%edi
  8009ed:	cd 30                	int    $0x30
sys_lcr3(uint32_t cr3)
{
	getEnvID("sys_lcr3() From Guest OS...");
	int r = syscall(SYS_lcr3, 0, cr3, 0, 0, 0, VMM_ID);
	return r;
}
  8009ef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009f8:	89 ec                	mov    %ebp,%esp
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <sys_env_pop_tf>:

int
sys_env_pop_tf(uint32_t e)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 10             	sub    $0x10,%esp
  800a02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	getEnvID("sys_env_pop_tf() From Guest OS...");
  800a0b:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  800a12:	e8 91 fe ff ff       	call   8008a8 <getEnvID>
        // 
        // The last clause tells the assembler that this can
        // potentially change the condition codes and arbitrary
        // memory locations.

        asm volatile("int %1\n"
  800a17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a1c:	8b 35 a4 fc 80 00    	mov    0x80fca4,%esi
  800a22:	b8 05 00 00 00       	mov    $0x5,%eax
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2a:	89 cb                	mov    %ecx,%ebx
  800a2c:	89 cf                	mov    %ecx,%edi
  800a2e:	cd 30                	int    $0x30
sys_env_pop_tf(uint32_t e)
{
	getEnvID("sys_env_pop_tf() From Guest OS...");
	int r = syscall(SYS_run, 0, e, 0, 0, 0, VMM_ID);
	return r;
}
  800a30:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a33:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a36:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a39:	89 ec                	mov    %ebp,%esp
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    
  800a3d:	00 00                	add    %al,(%eax)
	...

00800a40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	83 ec 4c             	sub    $0x4c,%esp
  800a49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a4c:	89 d6                	mov    %edx,%esi
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a57:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a60:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a63:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6b:	39 d1                	cmp    %edx,%ecx
  800a6d:	72 15                	jb     800a84 <printnum+0x44>
  800a6f:	77 07                	ja     800a78 <printnum+0x38>
  800a71:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	76 0c                	jbe    800a84 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800a78:	83 eb 01             	sub    $0x1,%ebx
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	8d 76 00             	lea    0x0(%esi),%esi
  800a80:	7f 61                	jg     800ae3 <printnum+0xa3>
  800a82:	eb 70                	jmp    800af4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a84:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800a88:	83 eb 01             	sub    $0x1,%ebx
  800a8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a93:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800a97:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  800a9b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800a9e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800aa1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800aa4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800aa8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800aaf:	00 
  800ab0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ab9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800abd:	e8 4e 10 00 00       	call   801b10 <__udivdi3>
  800ac2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ac5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ac8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800acc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ad0:	89 04 24             	mov    %eax,(%esp)
  800ad3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad7:	89 f2                	mov    %esi,%edx
  800ad9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800adc:	e8 5f ff ff ff       	call   800a40 <printnum>
  800ae1:	eb 11                	jmp    800af4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ae3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae7:	89 3c 24             	mov    %edi,(%esp)
  800aea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800aed:	83 eb 01             	sub    $0x1,%ebx
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	7f ef                	jg     800ae3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	
	putch("0123456789abcdef"[num % base], putdat);
  800af4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800afc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800aff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b0a:	00 
  800b0b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b0e:	89 14 24             	mov    %edx,(%esp)
  800b11:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b14:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b18:	e8 23 11 00 00       	call   801c40 <__umoddi3>
  800b1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b21:	0f be 80 b2 21 80 00 	movsbl 0x8021b2(%eax),%eax
  800b28:	89 04 24             	mov    %eax,(%esp)
  800b2b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800b2e:	83 c4 4c             	add    $0x4c,%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b39:	83 fa 01             	cmp    $0x1,%edx
  800b3c:	7e 0e                	jle    800b4c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b3e:	8b 10                	mov    (%eax),%edx
  800b40:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b43:	89 08                	mov    %ecx,(%eax)
  800b45:	8b 02                	mov    (%edx),%eax
  800b47:	8b 52 04             	mov    0x4(%edx),%edx
  800b4a:	eb 22                	jmp    800b6e <getuint+0x38>
	else if (lflag)
  800b4c:	85 d2                	test   %edx,%edx
  800b4e:	74 10                	je     800b60 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b50:	8b 10                	mov    (%eax),%edx
  800b52:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b55:	89 08                	mov    %ecx,(%eax)
  800b57:	8b 02                	mov    (%edx),%eax
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	eb 0e                	jmp    800b6e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b60:	8b 10                	mov    (%eax),%edx
  800b62:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b65:	89 08                	mov    %ecx,(%eax)
  800b67:	8b 02                	mov    (%edx),%eax
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b76:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800b7a:	8b 10                	mov    (%eax),%edx
  800b7c:	3b 50 04             	cmp    0x4(%eax),%edx
  800b7f:	73 0a                	jae    800b8b <sprintputch+0x1b>
		*b->buf++ = ch;
  800b81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b84:	88 0a                	mov    %cl,(%edx)
  800b86:	83 c2 01             	add    $0x1,%edx
  800b89:	89 10                	mov    %edx,(%eax)
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 4c             	sub    $0x4c,%esp
  800b96:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	eb 11                	jmp    800bb2 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	0f 84 16 04 00 00    	je     800fbf <vprintfmt+0x432>
				return;
			putch(ch, putdat);
  800ba9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bad:	89 04 24             	mov    %eax,(%esp)
  800bb0:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bb2:	0f b6 03             	movzbl (%ebx),%eax
  800bb5:	83 c3 01             	add    $0x1,%ebx
  800bb8:	83 f8 25             	cmp    $0x25,%eax
  800bbb:	75 e4                	jne    800ba1 <vprintfmt+0x14>
  800bbd:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800bc1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800bc8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800bcf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800bd6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800bdd:	89 d9                	mov    %ebx,%ecx
  800bdf:	eb 06                	jmp    800be7 <vprintfmt+0x5a>
  800be1:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800be5:	89 d9                	mov    %ebx,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800be7:	0f b6 01             	movzbl (%ecx),%eax
  800bea:	0f b6 d0             	movzbl %al,%edx
  800bed:	8d 59 01             	lea    0x1(%ecx),%ebx
  800bf0:	83 e8 23             	sub    $0x23,%eax
  800bf3:	3c 55                	cmp    $0x55,%al
  800bf5:	0f 87 a5 03 00 00    	ja     800fa0 <vprintfmt+0x413>
  800bfb:	0f b6 c0             	movzbl %al,%eax
  800bfe:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
  800c05:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800c09:	eb da                	jmp    800be5 <vprintfmt+0x58>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c0b:	83 ea 30             	sub    $0x30,%edx
  800c0e:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800c11:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800c14:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c17:	83 fa 09             	cmp    $0x9,%edx
  800c1a:	77 43                	ja     800c5f <vprintfmt+0xd2>
  800c1c:	8b 55 d0             	mov    -0x30(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c1f:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800c22:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800c25:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800c29:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800c2c:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800c2f:	83 f9 09             	cmp    $0x9,%ecx
  800c32:	76 eb                	jbe    800c1f <vprintfmt+0x92>
  800c34:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800c37:	eb 26                	jmp    800c5f <vprintfmt+0xd2>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c39:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3c:	8d 50 04             	lea    0x4(%eax),%edx
  800c3f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c42:	8b 00                	mov    (%eax),%eax
  800c44:	89 45 d0             	mov    %eax,-0x30(%ebp)
			goto process_precision;
  800c47:	eb 16                	jmp    800c5f <vprintfmt+0xd2>

		case '.':
			if (width < 0)
  800c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c4c:	c1 f8 1f             	sar    $0x1f,%eax
  800c4f:	f7 d0                	not    %eax
  800c51:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800c54:	eb 8f                	jmp    800be5 <vprintfmt+0x58>
  800c56:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800c5d:	eb 86                	jmp    800be5 <vprintfmt+0x58>

		process_precision:
			if (width < 0)
  800c5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c63:	79 80                	jns    800be5 <vprintfmt+0x58>
  800c65:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800c68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c6b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c72:	e9 6e ff ff ff       	jmp    800be5 <vprintfmt+0x58>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c77:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800c7b:	e9 65 ff ff ff       	jmp    800be5 <vprintfmt+0x58>
  800c80:	89 5d cc             	mov    %ebx,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c83:	8b 45 14             	mov    0x14(%ebp),%eax
  800c86:	8d 50 04             	lea    0x4(%eax),%edx
  800c89:	89 55 14             	mov    %edx,0x14(%ebp)
  800c8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c90:	8b 00                	mov    (%eax),%eax
  800c92:	89 04 24             	mov    %eax,(%esp)
  800c95:	ff d7                	call   *%edi
  800c97:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800c9a:	e9 13 ff ff ff       	jmp    800bb2 <vprintfmt+0x25>
  800c9f:	89 5d cc             	mov    %ebx,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ca2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca5:	8d 50 04             	lea    0x4(%eax),%edx
  800ca8:	89 55 14             	mov    %edx,0x14(%ebp)
  800cab:	8b 00                	mov    (%eax),%eax
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	c1 fa 1f             	sar    $0x1f,%edx
  800cb2:	31 d0                	xor    %edx,%eax
  800cb4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800cb6:	83 f8 06             	cmp    $0x6,%eax
  800cb9:	7f 0b                	jg     800cc6 <vprintfmt+0x139>
  800cbb:	8b 14 85 98 23 80 00 	mov    0x802398(,%eax,4),%edx
  800cc2:	85 d2                	test   %edx,%edx
  800cc4:	75 20                	jne    800ce6 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800cc6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cca:	c7 44 24 08 c3 21 80 	movl   $0x8021c3,0x8(%esp)
  800cd1:	00 
  800cd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd6:	89 3c 24             	mov    %edi,(%esp)
  800cd9:	e8 69 03 00 00       	call   801047 <printfmt>
  800cde:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800ce1:	e9 cc fe ff ff       	jmp    800bb2 <vprintfmt+0x25>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800ce6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cea:	c7 44 24 08 cc 21 80 	movl   $0x8021cc,0x8(%esp)
  800cf1:	00 
  800cf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf6:	89 3c 24             	mov    %edi,(%esp)
  800cf9:	e8 49 03 00 00       	call   801047 <printfmt>
  800cfe:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800d01:	e9 ac fe ff ff       	jmp    800bb2 <vprintfmt+0x25>
  800d06:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800d09:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d0f:	89 55 c8             	mov    %edx,-0x38(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d12:	8b 45 14             	mov    0x14(%ebp),%eax
  800d15:	8d 50 04             	lea    0x4(%eax),%edx
  800d18:	89 55 14             	mov    %edx,0x14(%ebp)
  800d1b:	8b 00                	mov    (%eax),%eax
  800d1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	75 07                	jne    800d2b <vprintfmt+0x19e>
  800d24:	c7 45 d4 cf 21 80 00 	movl   $0x8021cf,-0x2c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800d2b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800d2f:	7e 06                	jle    800d37 <vprintfmt+0x1aa>
  800d31:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800d35:	75 13                	jne    800d4a <vprintfmt+0x1bd>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d37:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800d3a:	0f be 01             	movsbl (%ecx),%eax
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	0f 85 99 00 00 00    	jne    800dde <vprintfmt+0x251>
  800d45:	e9 86 00 00 00       	jmp    800dd0 <vprintfmt+0x243>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d4a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d51:	89 04 24             	mov    %eax,(%esp)
  800d54:	e8 f2 03 00 00       	call   80114b <strnlen>
  800d59:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800d5c:	29 c2                	sub    %eax,%edx
  800d5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d61:	85 d2                	test   %edx,%edx
  800d63:	7e d2                	jle    800d37 <vprintfmt+0x1aa>
					putch(padc, putdat);
  800d65:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800d69:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800d6c:	89 5d c8             	mov    %ebx,-0x38(%ebp)
  800d6f:	89 d3                	mov    %edx,%ebx
  800d71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d75:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d78:	89 04 24             	mov    %eax,(%esp)
  800d7b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d7d:	83 eb 01             	sub    $0x1,%ebx
  800d80:	85 db                	test   %ebx,%ebx
  800d82:	7f ed                	jg     800d71 <vprintfmt+0x1e4>
  800d84:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  800d87:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800d8e:	eb a7                	jmp    800d37 <vprintfmt+0x1aa>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800d94:	74 18                	je     800dae <vprintfmt+0x221>
  800d96:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d99:	83 fa 5e             	cmp    $0x5e,%edx
  800d9c:	76 10                	jbe    800dae <vprintfmt+0x221>
					putch('?', putdat);
  800d9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800da2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800da9:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dac:	eb 0a                	jmp    800db8 <vprintfmt+0x22b>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800dae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800db2:	89 04 24             	mov    %eax,(%esp)
  800db5:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800db8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800dbc:	0f be 03             	movsbl (%ebx),%eax
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	74 05                	je     800dc8 <vprintfmt+0x23b>
  800dc3:	83 c3 01             	add    $0x1,%ebx
  800dc6:	eb 29                	jmp    800df1 <vprintfmt+0x264>
  800dc8:	89 fe                	mov    %edi,%esi
  800dca:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800dcd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800dd0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dd4:	7f 2e                	jg     800e04 <vprintfmt+0x277>
  800dd6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800dd9:	e9 d4 fd ff ff       	jmp    800bb2 <vprintfmt+0x25>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dde:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800de1:	83 c2 01             	add    $0x1,%edx
  800de4:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800de7:	89 f7                	mov    %esi,%edi
  800de9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800dec:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800def:	89 d3                	mov    %edx,%ebx
  800df1:	85 f6                	test   %esi,%esi
  800df3:	78 9b                	js     800d90 <vprintfmt+0x203>
  800df5:	83 ee 01             	sub    $0x1,%esi
  800df8:	79 96                	jns    800d90 <vprintfmt+0x203>
  800dfa:	89 fe                	mov    %edi,%esi
  800dfc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800dff:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e02:	eb cc                	jmp    800dd0 <vprintfmt+0x243>
  800e04:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800e07:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e15:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e17:	83 eb 01             	sub    $0x1,%ebx
  800e1a:	85 db                	test   %ebx,%ebx
  800e1c:	7f ec                	jg     800e0a <vprintfmt+0x27d>
  800e1e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e21:	e9 8c fd ff ff       	jmp    800bb2 <vprintfmt+0x25>
  800e26:	89 5d cc             	mov    %ebx,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e29:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800e2d:	7e 16                	jle    800e45 <vprintfmt+0x2b8>
		return va_arg(*ap, long long);
  800e2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e32:	8d 50 08             	lea    0x8(%eax),%edx
  800e35:	89 55 14             	mov    %edx,0x14(%ebp)
  800e38:	8b 10                	mov    (%eax),%edx
  800e3a:	8b 48 04             	mov    0x4(%eax),%ecx
  800e3d:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800e40:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800e43:	eb 34                	jmp    800e79 <vprintfmt+0x2ec>
	else if (lflag)
  800e45:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e49:	74 18                	je     800e63 <vprintfmt+0x2d6>
		return va_arg(*ap, long);
  800e4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4e:	8d 50 04             	lea    0x4(%eax),%edx
  800e51:	89 55 14             	mov    %edx,0x14(%ebp)
  800e54:	8b 00                	mov    (%eax),%eax
  800e56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e59:	89 c1                	mov    %eax,%ecx
  800e5b:	c1 f9 1f             	sar    $0x1f,%ecx
  800e5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800e61:	eb 16                	jmp    800e79 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800e63:	8b 45 14             	mov    0x14(%ebp),%eax
  800e66:	8d 50 04             	lea    0x4(%eax),%edx
  800e69:	89 55 14             	mov    %edx,0x14(%ebp)
  800e6c:	8b 00                	mov    (%eax),%eax
  800e6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	c1 fa 1f             	sar    $0x1f,%edx
  800e76:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e79:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800e84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e88:	0f 89 d3 00 00 00    	jns    800f61 <vprintfmt+0x3d4>
				putch('-', putdat);
  800e8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e92:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e99:	ff d7                	call   *%edi
				num = -(long long) num;
  800e9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ea1:	f7 d8                	neg    %eax
  800ea3:	83 d2 00             	adc    $0x0,%edx
  800ea6:	f7 da                	neg    %edx
  800ea8:	e9 b4 00 00 00       	jmp    800f61 <vprintfmt+0x3d4>
  800ead:	89 5d cc             	mov    %ebx,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800eb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800eb3:	8d 45 14             	lea    0x14(%ebp),%eax
  800eb6:	e8 7b fc ff ff       	call   800b36 <getuint>
  800ebb:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800ec0:	e9 9c 00 00 00       	jmp    800f61 <vprintfmt+0x3d4>

		case 'k':
			COLOR = getuint(&ap, 0);
  800ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eca:	8d 45 14             	lea    0x14(%ebp),%eax
  800ecd:	e8 64 fc ff ff       	call   800b36 <getuint>
			COLOR = COLOR | ~0xFF;
  800ed2:	0d 00 ff ff ff       	or     $0xffffff00,%eax
  800ed7:	a3 00 30 80 00       	mov    %eax,0x803000
			goto reswitch;
  800edc:	e9 04 fd ff ff       	jmp    800be5 <vprintfmt+0x58>
  800ee1:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ee4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ee7:	8d 45 14             	lea    0x14(%ebp),%eax
  800eea:	e8 47 fc ff ff       	call   800b36 <getuint>
			if ((long long) num < 0) {
  800eef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ef2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ef5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800efa:	85 d2                	test   %edx,%edx
  800efc:	79 63                	jns    800f61 <vprintfmt+0x3d4>
				putch('-', putdat);
  800efe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f02:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f09:	ff d7                	call   *%edi
				num = -(long long) num;
  800f0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f11:	f7 d8                	neg    %eax
  800f13:	83 d2 00             	adc    $0x0,%edx
  800f16:	f7 da                	neg    %edx
  800f18:	eb 47                	jmp    800f61 <vprintfmt+0x3d4>
  800f1a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800f1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f21:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f28:	ff d7                	call   *%edi
			putch('x', putdat);
  800f2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f35:	ff d7                	call   *%edi
			num = (unsigned long long)
  800f37:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3a:	8d 50 04             	lea    0x4(%eax),%edx
  800f3d:	89 55 14             	mov    %edx,0x14(%ebp)
  800f40:	8b 00                	mov    (%eax),%eax
  800f42:	ba 00 00 00 00       	mov    $0x0,%edx
  800f47:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f4c:	eb 13                	jmp    800f61 <vprintfmt+0x3d4>
  800f4e:	89 5d cc             	mov    %ebx,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f51:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f54:	8d 45 14             	lea    0x14(%ebp),%eax
  800f57:	e8 da fb ff ff       	call   800b36 <getuint>
  800f5c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f61:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800f65:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f69:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800f6c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f74:	89 04 24             	mov    %eax,(%esp)
  800f77:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f7b:	89 f2                	mov    %esi,%edx
  800f7d:	89 f8                	mov    %edi,%eax
  800f7f:	e8 bc fa ff ff       	call   800a40 <printnum>
  800f84:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800f87:	e9 26 fc ff ff       	jmp    800bb2 <vprintfmt+0x25>
  800f8c:	89 5d cc             	mov    %ebx,-0x34(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f93:	89 14 24             	mov    %edx,(%esp)
  800f96:	ff d7                	call   *%edi
  800f98:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800f9b:	e9 12 fc ff ff       	jmp    800bb2 <vprintfmt+0x25>
  800fa0:	89 cb                	mov    %ecx,%ebx
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fa2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800fad:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800faf:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fb2:	80 38 25             	cmpb   $0x25,(%eax)
  800fb5:	0f 84 f7 fb ff ff    	je     800bb2 <vprintfmt+0x25>
  800fbb:	89 c3                	mov    %eax,%ebx
  800fbd:	eb f0                	jmp    800faf <vprintfmt+0x422>
				/* do nothing */;
			break;
		}
	}
}
  800fbf:	83 c4 4c             	add    $0x4c,%esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 28             	sub    $0x28,%esp
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	74 04                	je     800fdb <vsnprintf+0x14>
  800fd7:	85 d2                	test   %edx,%edx
  800fd9:	7f 07                	jg     800fe2 <vsnprintf+0x1b>
  800fdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe0:	eb 3b                	jmp    80101d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800fe9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ff3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ffa:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801001:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801004:	89 44 24 04          	mov    %eax,0x4(%esp)
  801008:	c7 04 24 70 0b 80 00 	movl   $0x800b70,(%esp)
  80100f:	e8 79 fb ff ff       	call   800b8d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801014:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801017:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801025:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801028:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80102c:	8b 45 10             	mov    0x10(%ebp),%eax
  80102f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801033:	8b 45 0c             	mov    0xc(%ebp),%eax
  801036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	e8 82 ff ff ff       	call   800fc7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80104d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801054:	8b 45 10             	mov    0x10(%ebp),%eax
  801057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	89 04 24             	mov    %eax,(%esp)
  801068:	e8 20 fb ff ff       	call   800b8d <vprintfmt>
	va_end(ap);
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    
	...

00801070 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 1c             	sub    $0x1c,%esp
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
  80107c:	85 c0                	test   %eax,%eax
  80107e:	74 10                	je     801090 <readline+0x20>
		cprintf("%s", prompt);
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	c7 04 24 cc 21 80 00 	movl   $0x8021cc,(%esp)
  80108b:	e8 0d 05 00 00       	call   80159d <cprintf>
  801090:	be 00 00 00 00       	mov    $0x0,%esi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
  801095:	bf c0 fc 80 00       	mov    $0x80fcc0,%edi
		cprintf("%s", prompt);

	i = 0;
	echoing = 1;
	while (1) {
		c = getchar();
  80109a:	e8 dd f0 ff ff       	call   80017c <getchar>
  80109f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 17                	jns    8010bc <readline+0x4c>
			cprintf("read error: %e\n", c);
  8010a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a9:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  8010b0:	e8 e8 04 00 00       	call   80159d <cprintf>
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
  8010ba:	eb 65                	jmp    801121 <readline+0xb1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010bc:	83 f8 08             	cmp    $0x8,%eax
  8010bf:	74 05                	je     8010c6 <readline+0x56>
  8010c1:	83 f8 7f             	cmp    $0x7f,%eax
  8010c4:	75 15                	jne    8010db <readline+0x6b>
  8010c6:	85 f6                	test   %esi,%esi
  8010c8:	7e 11                	jle    8010db <readline+0x6b>
			if (echoing)
				cputchar('\b');
  8010ca:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010d1:	e8 b0 f0 ff ff       	call   800186 <cputchar>
			i--;
  8010d6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010d9:	eb bf                	jmp    80109a <readline+0x2a>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010db:	83 fb 1f             	cmp    $0x1f,%ebx
  8010de:	66 90                	xchg   %ax,%ax
  8010e0:	7e 1b                	jle    8010fd <readline+0x8d>
  8010e2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010e8:	7f 13                	jg     8010fd <readline+0x8d>
			if (echoing)
				cputchar(c);
  8010ea:	89 1c 24             	mov    %ebx,(%esp)
  8010ed:	8d 76 00             	lea    0x0(%esi),%esi
  8010f0:	e8 91 f0 ff ff       	call   800186 <cputchar>
			buf[i++] = c;
  8010f5:	88 1c 37             	mov    %bl,(%edi,%esi,1)
  8010f8:	83 c6 01             	add    $0x1,%esi
  8010fb:	eb 9d                	jmp    80109a <readline+0x2a>
		} else if (c == '\n' || c == '\r') {
  8010fd:	83 fb 0a             	cmp    $0xa,%ebx
  801100:	74 05                	je     801107 <readline+0x97>
  801102:	83 fb 0d             	cmp    $0xd,%ebx
  801105:	75 93                	jne    80109a <readline+0x2a>
			if (echoing)
				cputchar('\n');
  801107:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80110e:	66 90                	xchg   %ax,%ax
  801110:	e8 71 f0 ff ff       	call   800186 <cputchar>
			buf[i] = 0;
  801115:	c6 86 c0 fc 80 00 00 	movb   $0x0,0x80fcc0(%esi)
  80111c:	b8 c0 fc 80 00       	mov    $0x80fcc0,%eax
			return buf;
		}
	}
}
  801121:	83 c4 1c             	add    $0x1c,%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    
  801129:	00 00                	add    %al,(%eax)
  80112b:	00 00                	add    %al,(%eax)
  80112d:	00 00                	add    %al,(%eax)
	...

00801130 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801136:	b8 00 00 00 00       	mov    $0x0,%eax
  80113b:	80 3a 00             	cmpb   $0x0,(%edx)
  80113e:	74 09                	je     801149 <strlen+0x19>
		n++;
  801140:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801143:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801147:	75 f7                	jne    801140 <strlen+0x10>
		n++;
	return n;
}
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	53                   	push   %ebx
  80114f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801152:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801155:	85 c9                	test   %ecx,%ecx
  801157:	74 19                	je     801172 <strnlen+0x27>
  801159:	80 3b 00             	cmpb   $0x0,(%ebx)
  80115c:	74 14                	je     801172 <strnlen+0x27>
  80115e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801163:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801166:	39 c8                	cmp    %ecx,%eax
  801168:	74 0d                	je     801177 <strnlen+0x2c>
  80116a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80116e:	75 f3                	jne    801163 <strnlen+0x18>
  801170:	eb 05                	jmp    801177 <strnlen+0x2c>
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801177:	5b                   	pop    %ebx
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	53                   	push   %ebx
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801184:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801189:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80118d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801190:	83 c2 01             	add    $0x1,%edx
  801193:	84 c9                	test   %cl,%cl
  801195:	75 f2                	jne    801189 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801197:	5b                   	pop    %ebx
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011a8:	85 f6                	test   %esi,%esi
  8011aa:	74 18                	je     8011c4 <strncpy+0x2a>
  8011ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8011b1:	0f b6 1a             	movzbl (%edx),%ebx
  8011b4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011b7:	80 3a 01             	cmpb   $0x1,(%edx)
  8011ba:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011bd:	83 c1 01             	add    $0x1,%ecx
  8011c0:	39 ce                	cmp    %ecx,%esi
  8011c2:	77 ed                	ja     8011b1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011d6:	89 f0                	mov    %esi,%eax
  8011d8:	85 c9                	test   %ecx,%ecx
  8011da:	74 27                	je     801203 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8011dc:	83 e9 01             	sub    $0x1,%ecx
  8011df:	74 1d                	je     8011fe <strlcpy+0x36>
  8011e1:	0f b6 1a             	movzbl (%edx),%ebx
  8011e4:	84 db                	test   %bl,%bl
  8011e6:	74 16                	je     8011fe <strlcpy+0x36>
			*dst++ = *src++;
  8011e8:	88 18                	mov    %bl,(%eax)
  8011ea:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011ed:	83 e9 01             	sub    $0x1,%ecx
  8011f0:	74 0e                	je     801200 <strlcpy+0x38>
			*dst++ = *src++;
  8011f2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011f5:	0f b6 1a             	movzbl (%edx),%ebx
  8011f8:	84 db                	test   %bl,%bl
  8011fa:	75 ec                	jne    8011e8 <strlcpy+0x20>
  8011fc:	eb 02                	jmp    801200 <strlcpy+0x38>
  8011fe:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801200:	c6 00 00             	movb   $0x0,(%eax)
  801203:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801212:	0f b6 01             	movzbl (%ecx),%eax
  801215:	84 c0                	test   %al,%al
  801217:	74 15                	je     80122e <strcmp+0x25>
  801219:	3a 02                	cmp    (%edx),%al
  80121b:	75 11                	jne    80122e <strcmp+0x25>
		p++, q++;
  80121d:	83 c1 01             	add    $0x1,%ecx
  801220:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801223:	0f b6 01             	movzbl (%ecx),%eax
  801226:	84 c0                	test   %al,%al
  801228:	74 04                	je     80122e <strcmp+0x25>
  80122a:	3a 02                	cmp    (%edx),%al
  80122c:	74 ef                	je     80121d <strcmp+0x14>
  80122e:	0f b6 c0             	movzbl %al,%eax
  801231:	0f b6 12             	movzbl (%edx),%edx
  801234:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	8b 55 08             	mov    0x8(%ebp),%edx
  80123f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801242:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801245:	85 c0                	test   %eax,%eax
  801247:	74 23                	je     80126c <strncmp+0x34>
  801249:	0f b6 1a             	movzbl (%edx),%ebx
  80124c:	84 db                	test   %bl,%bl
  80124e:	74 24                	je     801274 <strncmp+0x3c>
  801250:	3a 19                	cmp    (%ecx),%bl
  801252:	75 20                	jne    801274 <strncmp+0x3c>
  801254:	83 e8 01             	sub    $0x1,%eax
  801257:	74 13                	je     80126c <strncmp+0x34>
		n--, p++, q++;
  801259:	83 c2 01             	add    $0x1,%edx
  80125c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80125f:	0f b6 1a             	movzbl (%edx),%ebx
  801262:	84 db                	test   %bl,%bl
  801264:	74 0e                	je     801274 <strncmp+0x3c>
  801266:	3a 19                	cmp    (%ecx),%bl
  801268:	74 ea                	je     801254 <strncmp+0x1c>
  80126a:	eb 08                	jmp    801274 <strncmp+0x3c>
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801271:	5b                   	pop    %ebx
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801274:	0f b6 02             	movzbl (%edx),%eax
  801277:	0f b6 11             	movzbl (%ecx),%edx
  80127a:	29 d0                	sub    %edx,%eax
  80127c:	eb f3                	jmp    801271 <strncmp+0x39>

0080127e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	8b 45 08             	mov    0x8(%ebp),%eax
  801284:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801288:	0f b6 10             	movzbl (%eax),%edx
  80128b:	84 d2                	test   %dl,%dl
  80128d:	74 15                	je     8012a4 <strchr+0x26>
		if (*s == c)
  80128f:	38 ca                	cmp    %cl,%dl
  801291:	75 07                	jne    80129a <strchr+0x1c>
  801293:	eb 14                	jmp    8012a9 <strchr+0x2b>
  801295:	38 ca                	cmp    %cl,%dl
  801297:	90                   	nop
  801298:	74 0f                	je     8012a9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80129a:	83 c0 01             	add    $0x1,%eax
  80129d:	0f b6 10             	movzbl (%eax),%edx
  8012a0:	84 d2                	test   %dl,%dl
  8012a2:	75 f1                	jne    801295 <strchr+0x17>
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012b5:	0f b6 10             	movzbl (%eax),%edx
  8012b8:	84 d2                	test   %dl,%dl
  8012ba:	74 18                	je     8012d4 <strfind+0x29>
		if (*s == c)
  8012bc:	38 ca                	cmp    %cl,%dl
  8012be:	75 0a                	jne    8012ca <strfind+0x1f>
  8012c0:	eb 12                	jmp    8012d4 <strfind+0x29>
  8012c2:	38 ca                	cmp    %cl,%dl
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	74 0a                	je     8012d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012ca:	83 c0 01             	add    $0x1,%eax
  8012cd:	0f b6 10             	movzbl (%eax),%edx
  8012d0:	84 d2                	test   %dl,%dl
  8012d2:	75 ee                	jne    8012c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	89 1c 24             	mov    %ebx,(%esp)
  8012df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012f0:	85 c9                	test   %ecx,%ecx
  8012f2:	74 30                	je     801324 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012fa:	75 25                	jne    801321 <memset+0x4b>
  8012fc:	f6 c1 03             	test   $0x3,%cl
  8012ff:	75 20                	jne    801321 <memset+0x4b>
		c &= 0xFF;
  801301:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801304:	89 d3                	mov    %edx,%ebx
  801306:	c1 e3 08             	shl    $0x8,%ebx
  801309:	89 d6                	mov    %edx,%esi
  80130b:	c1 e6 18             	shl    $0x18,%esi
  80130e:	89 d0                	mov    %edx,%eax
  801310:	c1 e0 10             	shl    $0x10,%eax
  801313:	09 f0                	or     %esi,%eax
  801315:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801317:	09 d8                	or     %ebx,%eax
  801319:	c1 e9 02             	shr    $0x2,%ecx
  80131c:	fc                   	cld    
  80131d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80131f:	eb 03                	jmp    801324 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801321:	fc                   	cld    
  801322:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801324:	89 f8                	mov    %edi,%eax
  801326:	8b 1c 24             	mov    (%esp),%ebx
  801329:	8b 74 24 04          	mov    0x4(%esp),%esi
  80132d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801331:	89 ec                	mov    %ebp,%esp
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	89 34 24             	mov    %esi,(%esp)
  80133e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801342:	8b 45 08             	mov    0x8(%ebp),%eax
  801345:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801348:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80134b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80134d:	39 c6                	cmp    %eax,%esi
  80134f:	73 35                	jae    801386 <memmove+0x51>
  801351:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801354:	39 d0                	cmp    %edx,%eax
  801356:	73 2e                	jae    801386 <memmove+0x51>
		s += n;
		d += n;
  801358:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80135a:	f6 c2 03             	test   $0x3,%dl
  80135d:	75 1b                	jne    80137a <memmove+0x45>
  80135f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801365:	75 13                	jne    80137a <memmove+0x45>
  801367:	f6 c1 03             	test   $0x3,%cl
  80136a:	75 0e                	jne    80137a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80136c:	83 ef 04             	sub    $0x4,%edi
  80136f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801372:	c1 e9 02             	shr    $0x2,%ecx
  801375:	fd                   	std    
  801376:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801378:	eb 09                	jmp    801383 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80137a:	83 ef 01             	sub    $0x1,%edi
  80137d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801380:	fd                   	std    
  801381:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801383:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801384:	eb 20                	jmp    8013a6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801386:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80138c:	75 15                	jne    8013a3 <memmove+0x6e>
  80138e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801394:	75 0d                	jne    8013a3 <memmove+0x6e>
  801396:	f6 c1 03             	test   $0x3,%cl
  801399:	75 08                	jne    8013a3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80139b:	c1 e9 02             	shr    $0x2,%ecx
  80139e:	fc                   	cld    
  80139f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013a1:	eb 03                	jmp    8013a6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013a3:	fc                   	cld    
  8013a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013a6:	8b 34 24             	mov    (%esp),%esi
  8013a9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ad:	89 ec                	mov    %ebp,%esp
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8013b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 65 ff ff ff       	call   801335 <memmove>
}
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    

008013d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	57                   	push   %edi
  8013d6:	56                   	push   %esi
  8013d7:	53                   	push   %ebx
  8013d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8013db:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013e1:	85 c9                	test   %ecx,%ecx
  8013e3:	74 36                	je     80141b <memcmp+0x49>
		if (*s1 != *s2)
  8013e5:	0f b6 06             	movzbl (%esi),%eax
  8013e8:	0f b6 1f             	movzbl (%edi),%ebx
  8013eb:	38 d8                	cmp    %bl,%al
  8013ed:	74 20                	je     80140f <memcmp+0x3d>
  8013ef:	eb 14                	jmp    801405 <memcmp+0x33>
  8013f1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8013f6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8013fb:	83 c2 01             	add    $0x1,%edx
  8013fe:	83 e9 01             	sub    $0x1,%ecx
  801401:	38 d8                	cmp    %bl,%al
  801403:	74 12                	je     801417 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801405:	0f b6 c0             	movzbl %al,%eax
  801408:	0f b6 db             	movzbl %bl,%ebx
  80140b:	29 d8                	sub    %ebx,%eax
  80140d:	eb 11                	jmp    801420 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80140f:	83 e9 01             	sub    $0x1,%ecx
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	85 c9                	test   %ecx,%ecx
  801419:	75 d6                	jne    8013f1 <memcmp+0x1f>
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80142b:	89 c2                	mov    %eax,%edx
  80142d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801430:	39 d0                	cmp    %edx,%eax
  801432:	73 15                	jae    801449 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801434:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801438:	38 08                	cmp    %cl,(%eax)
  80143a:	75 06                	jne    801442 <memfind+0x1d>
  80143c:	eb 0b                	jmp    801449 <memfind+0x24>
  80143e:	38 08                	cmp    %cl,(%eax)
  801440:	74 07                	je     801449 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801442:	83 c0 01             	add    $0x1,%eax
  801445:	39 c2                	cmp    %eax,%edx
  801447:	77 f5                	ja     80143e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	57                   	push   %edi
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
  801451:	83 ec 04             	sub    $0x4,%esp
  801454:	8b 55 08             	mov    0x8(%ebp),%edx
  801457:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80145a:	0f b6 02             	movzbl (%edx),%eax
  80145d:	3c 20                	cmp    $0x20,%al
  80145f:	74 04                	je     801465 <strtol+0x1a>
  801461:	3c 09                	cmp    $0x9,%al
  801463:	75 0e                	jne    801473 <strtol+0x28>
		s++;
  801465:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801468:	0f b6 02             	movzbl (%edx),%eax
  80146b:	3c 20                	cmp    $0x20,%al
  80146d:	74 f6                	je     801465 <strtol+0x1a>
  80146f:	3c 09                	cmp    $0x9,%al
  801471:	74 f2                	je     801465 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801473:	3c 2b                	cmp    $0x2b,%al
  801475:	75 0c                	jne    801483 <strtol+0x38>
		s++;
  801477:	83 c2 01             	add    $0x1,%edx
  80147a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801481:	eb 15                	jmp    801498 <strtol+0x4d>
	else if (*s == '-')
  801483:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80148a:	3c 2d                	cmp    $0x2d,%al
  80148c:	75 0a                	jne    801498 <strtol+0x4d>
		s++, neg = 1;
  80148e:	83 c2 01             	add    $0x1,%edx
  801491:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801498:	85 db                	test   %ebx,%ebx
  80149a:	0f 94 c0             	sete   %al
  80149d:	74 05                	je     8014a4 <strtol+0x59>
  80149f:	83 fb 10             	cmp    $0x10,%ebx
  8014a2:	75 18                	jne    8014bc <strtol+0x71>
  8014a4:	80 3a 30             	cmpb   $0x30,(%edx)
  8014a7:	75 13                	jne    8014bc <strtol+0x71>
  8014a9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8014ad:	8d 76 00             	lea    0x0(%esi),%esi
  8014b0:	75 0a                	jne    8014bc <strtol+0x71>
		s += 2, base = 16;
  8014b2:	83 c2 02             	add    $0x2,%edx
  8014b5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014ba:	eb 15                	jmp    8014d1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014bc:	84 c0                	test   %al,%al
  8014be:	66 90                	xchg   %ax,%ax
  8014c0:	74 0f                	je     8014d1 <strtol+0x86>
  8014c2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8014c7:	80 3a 30             	cmpb   $0x30,(%edx)
  8014ca:	75 05                	jne    8014d1 <strtol+0x86>
		s++, base = 8;
  8014cc:	83 c2 01             	add    $0x1,%edx
  8014cf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014d8:	0f b6 0a             	movzbl (%edx),%ecx
  8014db:	89 cf                	mov    %ecx,%edi
  8014dd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8014e0:	80 fb 09             	cmp    $0x9,%bl
  8014e3:	77 08                	ja     8014ed <strtol+0xa2>
			dig = *s - '0';
  8014e5:	0f be c9             	movsbl %cl,%ecx
  8014e8:	83 e9 30             	sub    $0x30,%ecx
  8014eb:	eb 1e                	jmp    80150b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8014ed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8014f0:	80 fb 19             	cmp    $0x19,%bl
  8014f3:	77 08                	ja     8014fd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8014f5:	0f be c9             	movsbl %cl,%ecx
  8014f8:	83 e9 57             	sub    $0x57,%ecx
  8014fb:	eb 0e                	jmp    80150b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8014fd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801500:	80 fb 19             	cmp    $0x19,%bl
  801503:	77 15                	ja     80151a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801505:	0f be c9             	movsbl %cl,%ecx
  801508:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80150b:	39 f1                	cmp    %esi,%ecx
  80150d:	7d 0b                	jge    80151a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80150f:	83 c2 01             	add    $0x1,%edx
  801512:	0f af c6             	imul   %esi,%eax
  801515:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801518:	eb be                	jmp    8014d8 <strtol+0x8d>
  80151a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80151c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801520:	74 05                	je     801527 <strtol+0xdc>
		*endptr = (char *) s;
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801525:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801527:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80152b:	74 04                	je     801531 <strtol+0xe6>
  80152d:	89 c8                	mov    %ecx,%eax
  80152f:	f7 d8                	neg    %eax
}
  801531:	83 c4 04             	add    $0x4,%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    
  801539:	00 00                	add    %al,(%eax)
	...

0080153c <vcprintf>:
}
*/

int
vcprintf(const char *fmt, va_list ap)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	81 ec 28 01 00 00    	sub    $0x128,%esp
        struct printbuf b;

        b.idx = 0;
  801545:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154c:	00 00 00 
        b.cnt = 0;
  80154f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801556:	00 00 00 
        vprintfmt((void*)putch, &b, fmt, ap);
  801559:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801560:	8b 45 08             	mov    0x8(%ebp),%eax
  801563:	89 44 24 08          	mov    %eax,0x8(%esp)
  801567:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80156d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801571:	c7 04 24 b7 15 80 00 	movl   $0x8015b7,(%esp)
  801578:	e8 10 f6 ff ff       	call   800b8d <vprintfmt>
        sys_cputs(b.buf, b.idx);
  80157d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 22 f3 ff ff       	call   8008b7 <sys_cputs>

        return b.cnt;
}
  801595:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <cprintf>:


int
cprintf(const char *fmt, ...)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	83 ec 18             	sub    $0x18,%esp
        return b.cnt;
}


int
cprintf(const char *fmt, ...)
  8015a3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ad:	89 04 24             	mov    %eax,(%esp)
  8015b0:	e8 87 ff ff ff       	call   80153c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <putch>:
        char buf[256];
};

static void
putch(int ch, void* b1)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 14             	sub    $0x14,%esp
	//cputchar(ch);
	//*cnt++;
	struct printbuf* b = (struct printbuf*) b1;
  8015be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        b->buf[b->idx++] = ch;
  8015c1:	8b 03                	mov    (%ebx),%eax
  8015c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8015ca:	83 c0 01             	add    $0x1,%eax
  8015cd:	89 03                	mov    %eax,(%ebx)
        if (b->idx == 256-1) {
  8015cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015d4:	75 19                	jne    8015ef <putch+0x38>
                sys_cputs(b->buf, b->idx);
  8015d6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8015dd:	00 
  8015de:	8d 43 08             	lea    0x8(%ebx),%eax
  8015e1:	89 04 24             	mov    %eax,(%esp)
  8015e4:	e8 ce f2 ff ff       	call   8008b7 <sys_cputs>
                b->idx = 0;
  8015e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        }
        b->cnt++;
  8015ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015f3:	83 c4 14             	add    $0x14,%esp
  8015f6:	5b                   	pop    %ebx
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    
  8015f9:	00 00                	add    %al,(%eax)
  8015fb:	00 00                	add    %al,(%eax)
  8015fd:	00 00                	add    %al,(%eax)
	...

00801600 <envid2env>:

struct Trapframe user_tf;

int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	8b 45 08             	mov    0x8(%ebp),%eax
  801607:	8b 4d 0c             	mov    0xc(%ebp),%ecx
        struct Env *e;

        if (envid == 0) {
  80160a:	85 c0                	test   %eax,%eax
  80160c:	75 0e                	jne    80161c <envid2env+0x1c>
                *env_store = curenv;
  80160e:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  801613:	89 01                	mov    %eax,(%ecx)
  801615:	b8 00 00 00 00       	mov    $0x0,%eax
                return 0;
  80161a:	eb 4c                	jmp    801668 <envid2env+0x68>
        }
        e = &envs[envid];
  80161c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80161f:	81 c2 e0 00 81 00    	add    $0x8100e0,%edx
        if (e->env_status == ENV_FREE || e->env_id != envid) {
  801625:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
  801629:	74 05                	je     801630 <envid2env+0x30>
  80162b:	39 42 4c             	cmp    %eax,0x4c(%edx)
  80162e:	74 0d                	je     80163d <envid2env+0x3d>
                *env_store = 0;
  801630:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  801636:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
                return -E_BAD_ENV;
  80163b:	eb 2b                	jmp    801668 <envid2env+0x68>
        }
        if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  80163d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801641:	74 1e                	je     801661 <envid2env+0x61>
  801643:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  801648:	39 c2                	cmp    %eax,%edx
  80164a:	74 15                	je     801661 <envid2env+0x61>
  80164c:	8b 5a 50             	mov    0x50(%edx),%ebx
  80164f:	3b 58 4c             	cmp    0x4c(%eax),%ebx
  801652:	74 0d                	je     801661 <envid2env+0x61>
                *env_store = 0;
  801654:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  80165a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
                return -E_BAD_ENV;
  80165f:	eb 07                	jmp    801668 <envid2env+0x68>
        }
        *env_store = e;
  801661:	89 11                	mov    %edx,(%ecx)
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
        return 0;
}
  801668:	5b                   	pop    %ebx
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <get_userTrapframe>:
	env_run(curenv);	
	
}

void get_userTrapframe(struct Trapframe* tf)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	89 34 24             	mov    %esi,(%esp)
  801674:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801678:	8b 75 08             	mov    0x8(%ebp),%esi
	user_tf = *tf;
  80167b:	bf 60 10 81 00       	mov    $0x811060,%edi
  801680:	b9 11 00 00 00       	mov    $0x11,%ecx
  801685:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
}
  801687:	8b 34 24             	mov    (%esp),%esi
  80168a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80168e:	89 ec                	mov    %ebp,%esp
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <print_regs>:
	segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);*/
}

void
print_regs(struct PushRegs *regs)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	83 ec 14             	sub    $0x14,%esp
  801699:	8b 5d 08             	mov    0x8(%ebp),%ebx
        cprintf("  edi  0x%08x\n", regs->reg_edi);
  80169c:	8b 03                	mov    (%ebx),%eax
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	c7 04 24 c4 23 80 00 	movl   $0x8023c4,(%esp)
  8016a9:	e8 ef fe ff ff       	call   80159d <cprintf>
        cprintf("  esi  0x%08x\n", regs->reg_esi);
  8016ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8016b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b5:	c7 04 24 d3 23 80 00 	movl   $0x8023d3,(%esp)
  8016bc:	e8 dc fe ff ff       	call   80159d <cprintf>
        cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  8016c1:	8b 43 08             	mov    0x8(%ebx),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	c7 04 24 e2 23 80 00 	movl   $0x8023e2,(%esp)
  8016cf:	e8 c9 fe ff ff       	call   80159d <cprintf>
        cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  8016d4:	8b 43 0c             	mov    0xc(%ebx),%eax
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	c7 04 24 f1 23 80 00 	movl   $0x8023f1,(%esp)
  8016e2:	e8 b6 fe ff ff       	call   80159d <cprintf>
        cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  8016e7:	8b 43 10             	mov    0x10(%ebx),%eax
  8016ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ee:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  8016f5:	e8 a3 fe ff ff       	call   80159d <cprintf>
        cprintf("  edx  0x%08x\n", regs->reg_edx);
  8016fa:	8b 43 14             	mov    0x14(%ebx),%eax
  8016fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801701:	c7 04 24 0f 24 80 00 	movl   $0x80240f,(%esp)
  801708:	e8 90 fe ff ff       	call   80159d <cprintf>
        cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  80170d:	8b 43 18             	mov    0x18(%ebx),%eax
  801710:	89 44 24 04          	mov    %eax,0x4(%esp)
  801714:	c7 04 24 1e 24 80 00 	movl   $0x80241e,(%esp)
  80171b:	e8 7d fe ff ff       	call   80159d <cprintf>
        cprintf("  eax  0x%08x\n", regs->reg_eax);
  801720:	8b 43 1c             	mov    0x1c(%ebx),%eax
  801723:	89 44 24 04          	mov    %eax,0x4(%esp)
  801727:	c7 04 24 2d 24 80 00 	movl   $0x80242d,(%esp)
  80172e:	e8 6a fe ff ff       	call   80159d <cprintf>
}
  801733:	83 c4 14             	add    $0x14,%esp
  801736:	5b                   	pop    %ebx
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	53                   	push   %ebx
  80173d:	83 ec 14             	sub    $0x14,%esp
  801740:	8b 5d 08             	mov    0x8(%ebp),%ebx
        cprintf("TRAP frame at %p\n", tf);
  801743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801747:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  80174e:	e8 4a fe ff ff       	call   80159d <cprintf>
        print_regs(&tf->tf_regs);
  801753:	89 1c 24             	mov    %ebx,(%esp)
  801756:	e8 37 ff ff ff       	call   801692 <print_regs>
        cprintf("  es   0x----%04x\n", tf->tf_es);
  80175b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	c7 04 24 4e 24 80 00 	movl   $0x80244e,(%esp)
  80176a:	e8 2e fe ff ff       	call   80159d <cprintf>
        cprintf("  ds   0x----%04x\n", tf->tf_ds);
  80176f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
  801773:	89 44 24 04          	mov    %eax,0x4(%esp)
  801777:	c7 04 24 61 24 80 00 	movl   $0x802461,(%esp)
  80177e:	e8 1a fe ff ff       	call   80159d <cprintf>
        cprintf("  trap 0x%08x\n", tf->tf_trapno);
  801783:	8b 43 28             	mov    0x28(%ebx),%eax
  801786:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178a:	c7 04 24 74 24 80 00 	movl   $0x802474,(%esp)
  801791:	e8 07 fe ff ff       	call   80159d <cprintf>
        cprintf("  err  0x%08x\n", tf->tf_err);
  801796:	8b 43 2c             	mov    0x2c(%ebx),%eax
  801799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179d:	c7 04 24 83 24 80 00 	movl   $0x802483,(%esp)
  8017a4:	e8 f4 fd ff ff       	call   80159d <cprintf>
        cprintf("  eip  0x%08x\n", tf->tf_eip);
  8017a9:	8b 43 30             	mov    0x30(%ebx),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	c7 04 24 92 24 80 00 	movl   $0x802492,(%esp)
  8017b7:	e8 e1 fd ff ff       	call   80159d <cprintf>
        cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8017bc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	c7 04 24 a1 24 80 00 	movl   $0x8024a1,(%esp)
  8017cb:	e8 cd fd ff ff       	call   80159d <cprintf>
        cprintf("  flag 0x%08x\n", tf->tf_eflags);
  8017d0:	8b 43 38             	mov    0x38(%ebx),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  8017de:	e8 ba fd ff ff       	call   80159d <cprintf>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  8017e3:	8b 43 3c             	mov    0x3c(%ebx),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	c7 04 24 c3 24 80 00 	movl   $0x8024c3,(%esp)
  8017f1:	e8 a7 fd ff ff       	call   80159d <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  8017f6:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
  8017fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fe:	c7 04 24 d2 24 80 00 	movl   $0x8024d2,(%esp)
  801805:	e8 93 fd ff ff       	call   80159d <cprintf>
}
  80180a:	83 c4 14             	add    $0x14,%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <env_init>:
        return 0;
}

void
env_init(void)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	57                   	push   %edi
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	81 ec 9c 00 00 00    	sub    $0x9c,%esp

        cprintf("\n in env_init in user\n");
  80181c:	c7 04 24 e5 24 80 00 	movl   $0x8024e5,(%esp)
  801823:	e8 75 fd ff ff       	call   80159d <cprintf>
	cprintf("inserting\n");
  801828:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  80182f:	e8 69 fd ff ff       	call   80159d <cprintf>
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
  801834:	be 5c 01 81 00       	mov    $0x81015c,%esi
  801839:	8d 7c 24 0c          	lea    0xc(%esp),%edi
  80183d:	b9 1f 00 00 00       	mov    $0x1f,%ecx
  801842:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801844:	c7 44 24 08 e0 00 81 	movl   $0x8100e0,0x8(%esp)
  80184b:	00 
  80184c:	a1 04 30 80 00       	mov    0x803004,%eax
  801851:	83 e8 01             	sub    $0x1,%eax
  801854:	89 44 24 04          	mov    %eax,0x4(%esp)
  801858:	c7 04 24 07 25 80 00 	movl   $0x802507,(%esp)
  80185f:	e8 39 fd ff ff       	call   80159d <cprintf>
        for(i=nenv-1;i>=0;i--)
  801864:	8b 15 04 30 80 00    	mov    0x803004,%edx
  80186a:	89 d0                	mov    %edx,%eax
  80186c:	83 e8 01             	sub    $0x1,%eax
  80186f:	78 49                	js     8018ba <env_init+0xaa>
  801871:	6b d2 7c             	imul   $0x7c,%edx,%edx
  801874:	81 c2 e0 00 81 00    	add    $0x8100e0,%edx
  80187a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80187d:	05 e0 00 81 00       	add    $0x8100e0,%eax
        *env_store = e;
        return 0;
}

void
env_init(void)
  801882:	bb e0 00 81 00       	mov    $0x8100e0,%ebx
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
        for(i=nenv-1;i>=0;i--)
        {
                envs[i].env_id = 0;
  801887:	c7 42 d0 00 00 00 00 	movl   $0x0,-0x30(%edx)
  80188e:	89 c6                	mov    %eax,%esi
                LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
  801890:	8b 0d c4 00 81 00    	mov    0x8100c4,%ecx
  801896:	89 48 44             	mov    %ecx,0x44(%eax)
  801899:	85 c9                	test   %ecx,%ecx
  80189b:	74 06                	je     8018a3 <env_init+0x93>
  80189d:	8d 78 44             	lea    0x44(%eax),%edi
  8018a0:	89 79 48             	mov    %edi,0x48(%ecx)
  8018a3:	89 35 c4 00 81 00    	mov    %esi,0x8100c4
  8018a9:	c7 40 48 c4 00 81 00 	movl   $0x8100c4,0x48(%eax)
  8018b0:	83 ea 7c             	sub    $0x7c,%edx
  8018b3:	83 e8 7c             	sub    $0x7c,%eax
        cprintf("\n in env_init in user\n");
	cprintf("inserting\n");
        int i;
//	sys_page_alloc(envs);
	cprintf("nenv: %d %x %x\n", nenv-1, envs, envs[1]);
        for(i=nenv-1;i>=0;i--)
  8018b6:	39 da                	cmp    %ebx,%edx
  8018b8:	75 cd                	jne    801887 <env_init+0x77>
        {
                envs[i].env_id = 0;
                LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
        }
	cprintf("calling allloc\n");
  8018ba:	c7 04 24 17 25 80 00 	movl   $0x802517,(%esp)
  8018c1:	e8 d7 fc ff ff       	call   80159d <cprintf>
//	struct Env *e;
//	env_alloc(&e, 0);
}
  8018c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5f                   	pop    %edi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <env_run>:
}

*/
void
env_run(struct Env *e)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 18             	sub    $0x18,%esp
  8018d7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018da:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018dd:	8b 75 08             	mov    0x8(%ebp),%esi
		curenv = e;
		e->env_runs += 1;
		sys_lcr3(curenv->env_cr3);
	}
	return;*/
	curenv = e;
  8018e0:	89 35 c0 00 81 00    	mov    %esi,0x8100c0
	cprintf("\n\n ***userKernel, env.c:337***** Guest Kernel to Guest User now, inside env_run().... \n\n");
  8018e6:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  8018ed:	e8 ab fc ff ff       	call   80159d <cprintf>
	sys_env_pop_tf((uint32_t)e);
  8018f2:	89 34 24             	mov    %esi,(%esp)
  8018f5:	e8 02 f1 ff ff       	call   8009fc <sys_env_pop_tf>

	// guest user process returned from vm monitor due to trap, runnig it again
	 //asm volatile("movl %0,%%esp\n"
	asm volatile (" call get_userTrapframe\n":::"memory");
  8018fa:	e8 6c fd ff ff       	call   80166b <get_userTrapframe>
	cprintf("\n\n ******** The HACK BEGINS..... guest kernel, inside env_run().... \n\n");
  8018ff:	c7 04 24 f8 25 80 00 	movl   $0x8025f8,(%esp)
  801906:	e8 92 fc ff ff       	call   80159d <cprintf>
	print_trapframe(&user_tf);
  80190b:	c7 04 24 60 10 81 00 	movl   $0x811060,(%esp)
  801912:	e8 22 fe ff ff       	call   801739 <print_trapframe>
                "\tpopl %%ds\n"
                "\taddl $0x8,%%esp\n" //skip tf_trapno and tf_errcode 
                "\tiret"
                : : "g" (&tf) : "memory");
*/		
	curenv->env_tf = user_tf;
  801917:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  80191c:	be 60 10 81 00       	mov    $0x811060,%esi
  801921:	b9 11 00 00 00       	mov    $0x11,%ecx
  801926:	89 c7                	mov    %eax,%edi
  801928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env_run(curenv);	
  80192a:	a1 c0 00 81 00       	mov    0x8100c0,%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 9a ff ff ff       	call   8018d1 <env_run>
	
}
  801937:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80193a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80193d:	89 ec                	mov    %ebp,%esp
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <load_icode>:
}


void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 18             	sub    $0x18,%esp
	cprintf("in load icode\n");
  801947:	c7 04 24 27 25 80 00 	movl   $0x802527,(%esp)
  80194e:	e8 4a fc ff ff       	call   80159d <cprintf>
	sys_load_icode((void*)e, (void*)binary, size);
  801953:	8b 45 10             	mov    0x10(%ebp),%eax
  801956:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	89 04 24             	mov    %eax,(%esp)
  801967:	e8 0c f0 ff ff       	call   800978 <sys_load_icode>
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
	segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);*/
}
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <env_alloc>:



int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	53                   	push   %ebx
  801972:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;
	cprintf("list: %x\n", env_free_list);
  801975:	a1 c4 00 81 00       	mov    0x8100c4,%eax
  80197a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197e:	c7 04 24 36 25 80 00 	movl   $0x802536,(%esp)
  801985:	e8 13 fc ff ff       	call   80159d <cprintf>
	if (!(e = LIST_FIRST(&env_free_list)))
  80198a:	8b 1d c4 00 81 00    	mov    0x8100c4,%ebx
  801990:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  801995:	85 db                	test   %ebx,%ebx
  801997:	0f 84 9d 00 00 00    	je     801a3a <env_alloc+0xcc>
	
//	Env_map_segment(e->env_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
//	Env_map_segment(e->env_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
//	Env_map_segment(e->env_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
//	Env_map_segment(e->env_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);
	cprintf("kool");
  80199d:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  8019a4:	e8 f4 fb ff ff       	call   80159d <cprintf>
	cprintf("passing %x to set up vm\n", e);
  8019a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ad:	c7 04 24 45 25 80 00 	movl   $0x802545,(%esp)
  8019b4:	e8 e4 fb ff ff       	call   80159d <cprintf>
	sys_env_setup_vm(e);
  8019b9:	89 1c 24             	mov    %ebx,(%esp)
  8019bc:	e8 35 ef ff ff       	call   8008f6 <sys_env_setup_vm>
	}

	if ((r = env_setup_vm(e)) < 0)
		return r;

	generation = ((e->env_id) & ~(1024 - 1));
  8019c1:	8b 43 4c             	mov    0x4c(%ebx),%eax
	if (generation <= 0)	// Don't create a negative env_id.
  8019c4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
  8019c9:	7f 05                	jg     8019d0 <env_alloc+0x62>
  8019cb:	b8 01 00 00 00       	mov    $0x1,%eax
		generation = 1;
	e->env_id = generation | (e - envs);
  8019d0:	89 da                	mov    %ebx,%edx
  8019d2:	81 ea e0 00 81 00    	sub    $0x8100e0,%edx
  8019d8:	c1 fa 02             	sar    $0x2,%edx
  8019db:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
  8019e1:	09 d0                	or     %edx,%eax
  8019e3:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	e->env_parent_id = parent_id;
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
  8019ec:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
  8019f3:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;

	e->env_tf.tf_eflags |= FL_IF;
*/
	e->env_pgfault_upcall = 0;
  8019fa:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
  801a01:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	LIST_REMOVE(e, env_link);
  801a08:	8b 43 44             	mov    0x44(%ebx),%eax
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	74 06                	je     801a15 <env_alloc+0xa7>
  801a0f:	8b 53 48             	mov    0x48(%ebx),%edx
  801a12:	89 50 48             	mov    %edx,0x48(%eax)
  801a15:	8b 43 48             	mov    0x48(%ebx),%eax
  801a18:	8b 53 44             	mov    0x44(%ebx),%edx
  801a1b:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	89 18                	mov    %ebx,(%eax)

	cprintf(" pgdir: %x out of envalloc\n", e->env_pgdir);
  801a22:	8b 43 5c             	mov    0x5c(%ebx),%eax
  801a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a29:	c7 04 24 5e 25 80 00 	movl   $0x80255e,(%esp)
  801a30:	e8 68 fb ff ff       	call   80159d <cprintf>
  801a35:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a3a:	83 c4 14             	add    $0x14,%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <env_create>:
}


void
env_create(uint8_t *binary, size_t size)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 38             	sub    $0x38,%esp
  801a46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a52:	8b 75 0c             	mov    0xc(%ebp),%esi
	cprintf("binary: %x %d\n", binary, size);
  801a55:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a59:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a5d:	c7 04 24 7a 25 80 00 	movl   $0x80257a,(%esp)
  801a64:	e8 34 fb ff ff       	call   80159d <cprintf>
	struct Env *e;
	int retCode = env_alloc(&e, 0);
  801a69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a70:	00 
  801a71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a74:	89 04 24             	mov    %eax,(%esp)
  801a77:	e8 f2 fe ff ff       	call   80196e <env_alloc>
  801a7c:	89 c3                	mov    %eax,%ebx
	cprintf("cr3: %x id: %x\n", e->env_cr3, e->env_id);
  801a7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a81:	8b 50 4c             	mov    0x4c(%eax),%edx
  801a84:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a88:	8b 40 60             	mov    0x60(%eax),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	c7 04 24 89 25 80 00 	movl   $0x802589,(%esp)
  801a96:	e8 02 fb ff ff       	call   80159d <cprintf>
	if(retCode == -E_NO_FREE_ENV)
  801a9b:	83 fb fb             	cmp    $0xfffffffb,%ebx
  801a9e:	75 0e                	jne    801aae <env_create+0x6e>
	{
		cprintf("Maximum numbers of processes are already running!!\n");
  801aa0:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  801aa7:	e8 f1 fa ff ff       	call   80159d <cprintf>
		return;
  801aac:	eb 3c                	jmp    801aea <env_create+0xaa>
	}	
	if(retCode == -E_NO_MEM)
  801aae:	83 fb fc             	cmp    $0xfffffffc,%ebx
  801ab1:	75 0e                	jne    801ac1 <env_create+0x81>
	{
		cprintf("Out Of Memory while creating environment!!");
  801ab3:	c7 04 24 74 26 80 00 	movl   $0x802674,(%esp)
  801aba:	e8 de fa ff ff       	call   80159d <cprintf>
		return;
  801abf:	eb 29                	jmp    801aea <env_create+0xaa>
	}	

	load_icode(e, binary, size); 
  801ac1:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ac5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 6d fe ff ff       	call   801941 <load_icode>
	print_trapframe(&e->env_tf);
  801ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad7:	89 04 24             	mov    %eax,(%esp)
  801ada:	e8 5a fc ff ff       	call   801739 <print_trapframe>
	env_run(e);
  801adf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae2:	89 04 24             	mov    %eax,(%esp)
  801ae5:	e8 e7 fd ff ff       	call   8018d1 <env_run>
}
  801aea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801aed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801af0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801af3:	89 ec                	mov    %ebp,%esp
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    
	...

00801af8 <umain>:
#include <inc/lib.h>
#include <inc/stdio.h>

void
umain(void)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 18             	sub    $0x18,%esp
        cprintf("hello, world\n");
  801afe:	c7 04 24 a0 26 80 00 	movl   $0x8026a0,(%esp)
  801b05:	e8 93 fa ff ff       	call   80159d <cprintf>
//        cprintf("i am environment %08x\n", env->env_id);
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    
  801b0c:	00 00                	add    %al,(%eax)
	...

00801b10 <__udivdi3>:
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	57                   	push   %edi
  801b14:	56                   	push   %esi
  801b15:	83 ec 10             	sub    $0x10,%esp
  801b18:	8b 45 14             	mov    0x14(%ebp),%eax
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1e:	8b 75 10             	mov    0x10(%ebp),%esi
  801b21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b24:	85 c0                	test   %eax,%eax
  801b26:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801b29:	75 35                	jne    801b60 <__udivdi3+0x50>
  801b2b:	39 fe                	cmp    %edi,%esi
  801b2d:	77 61                	ja     801b90 <__udivdi3+0x80>
  801b2f:	85 f6                	test   %esi,%esi
  801b31:	75 0b                	jne    801b3e <__udivdi3+0x2e>
  801b33:	b8 01 00 00 00       	mov    $0x1,%eax
  801b38:	31 d2                	xor    %edx,%edx
  801b3a:	f7 f6                	div    %esi
  801b3c:	89 c6                	mov    %eax,%esi
  801b3e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801b41:	31 d2                	xor    %edx,%edx
  801b43:	89 f8                	mov    %edi,%eax
  801b45:	f7 f6                	div    %esi
  801b47:	89 c7                	mov    %eax,%edi
  801b49:	89 c8                	mov    %ecx,%eax
  801b4b:	f7 f6                	div    %esi
  801b4d:	89 c1                	mov    %eax,%ecx
  801b4f:	89 fa                	mov    %edi,%edx
  801b51:	89 c8                	mov    %ecx,%eax
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
  801b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b60:	39 f8                	cmp    %edi,%eax
  801b62:	77 1c                	ja     801b80 <__udivdi3+0x70>
  801b64:	0f bd d0             	bsr    %eax,%edx
  801b67:	83 f2 1f             	xor    $0x1f,%edx
  801b6a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b6d:	75 39                	jne    801ba8 <__udivdi3+0x98>
  801b6f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801b72:	0f 86 a0 00 00 00    	jbe    801c18 <__udivdi3+0x108>
  801b78:	39 f8                	cmp    %edi,%eax
  801b7a:	0f 82 98 00 00 00    	jb     801c18 <__udivdi3+0x108>
  801b80:	31 ff                	xor    %edi,%edi
  801b82:	31 c9                	xor    %ecx,%ecx
  801b84:	89 c8                	mov    %ecx,%eax
  801b86:	89 fa                	mov    %edi,%edx
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	5e                   	pop    %esi
  801b8c:	5f                   	pop    %edi
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    
  801b8f:	90                   	nop
  801b90:	89 d1                	mov    %edx,%ecx
  801b92:	89 fa                	mov    %edi,%edx
  801b94:	89 c8                	mov    %ecx,%eax
  801b96:	31 ff                	xor    %edi,%edi
  801b98:	f7 f6                	div    %esi
  801b9a:	89 c1                	mov    %eax,%ecx
  801b9c:	89 fa                	mov    %edi,%edx
  801b9e:	89 c8                	mov    %ecx,%eax
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	5e                   	pop    %esi
  801ba4:	5f                   	pop    %edi
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    
  801ba7:	90                   	nop
  801ba8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bac:	89 f2                	mov    %esi,%edx
  801bae:	d3 e0                	shl    %cl,%eax
  801bb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bb3:	b8 20 00 00 00       	mov    $0x20,%eax
  801bb8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801bbb:	89 c1                	mov    %eax,%ecx
  801bbd:	d3 ea                	shr    %cl,%edx
  801bbf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bc3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801bc6:	d3 e6                	shl    %cl,%esi
  801bc8:	89 c1                	mov    %eax,%ecx
  801bca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801bcd:	89 fe                	mov    %edi,%esi
  801bcf:	d3 ee                	shr    %cl,%esi
  801bd1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bd5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdb:	d3 e7                	shl    %cl,%edi
  801bdd:	89 c1                	mov    %eax,%ecx
  801bdf:	d3 ea                	shr    %cl,%edx
  801be1:	09 d7                	or     %edx,%edi
  801be3:	89 f2                	mov    %esi,%edx
  801be5:	89 f8                	mov    %edi,%eax
  801be7:	f7 75 ec             	divl   -0x14(%ebp)
  801bea:	89 d6                	mov    %edx,%esi
  801bec:	89 c7                	mov    %eax,%edi
  801bee:	f7 65 e8             	mull   -0x18(%ebp)
  801bf1:	39 d6                	cmp    %edx,%esi
  801bf3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801bf6:	72 30                	jb     801c28 <__udivdi3+0x118>
  801bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bfb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bff:	d3 e2                	shl    %cl,%edx
  801c01:	39 c2                	cmp    %eax,%edx
  801c03:	73 05                	jae    801c0a <__udivdi3+0xfa>
  801c05:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801c08:	74 1e                	je     801c28 <__udivdi3+0x118>
  801c0a:	89 f9                	mov    %edi,%ecx
  801c0c:	31 ff                	xor    %edi,%edi
  801c0e:	e9 71 ff ff ff       	jmp    801b84 <__udivdi3+0x74>
  801c13:	90                   	nop
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801c1f:	e9 60 ff ff ff       	jmp    801b84 <__udivdi3+0x74>
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801c2b:	31 ff                	xor    %edi,%edi
  801c2d:	89 c8                	mov    %ecx,%eax
  801c2f:	89 fa                	mov    %edi,%edx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
	...

00801c40 <__umoddi3>:
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	83 ec 20             	sub    $0x20,%esp
  801c48:	8b 55 14             	mov    0x14(%ebp),%edx
  801c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c51:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c54:	85 d2                	test   %edx,%edx
  801c56:	89 c8                	mov    %ecx,%eax
  801c58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c5b:	75 13                	jne    801c70 <__umoddi3+0x30>
  801c5d:	39 f7                	cmp    %esi,%edi
  801c5f:	76 3f                	jbe    801ca0 <__umoddi3+0x60>
  801c61:	89 f2                	mov    %esi,%edx
  801c63:	f7 f7                	div    %edi
  801c65:	89 d0                	mov    %edx,%eax
  801c67:	31 d2                	xor    %edx,%edx
  801c69:	83 c4 20             	add    $0x20,%esp
  801c6c:	5e                   	pop    %esi
  801c6d:	5f                   	pop    %edi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    
  801c70:	39 f2                	cmp    %esi,%edx
  801c72:	77 4c                	ja     801cc0 <__umoddi3+0x80>
  801c74:	0f bd ca             	bsr    %edx,%ecx
  801c77:	83 f1 1f             	xor    $0x1f,%ecx
  801c7a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c7d:	75 51                	jne    801cd0 <__umoddi3+0x90>
  801c7f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801c82:	0f 87 e0 00 00 00    	ja     801d68 <__umoddi3+0x128>
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	29 f8                	sub    %edi,%eax
  801c8d:	19 d6                	sbb    %edx,%esi
  801c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c95:	89 f2                	mov    %esi,%edx
  801c97:	83 c4 20             	add    $0x20,%esp
  801c9a:	5e                   	pop    %esi
  801c9b:	5f                   	pop    %edi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    
  801c9e:	66 90                	xchg   %ax,%ax
  801ca0:	85 ff                	test   %edi,%edi
  801ca2:	75 0b                	jne    801caf <__umoddi3+0x6f>
  801ca4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca9:	31 d2                	xor    %edx,%edx
  801cab:	f7 f7                	div    %edi
  801cad:	89 c7                	mov    %eax,%edi
  801caf:	89 f0                	mov    %esi,%eax
  801cb1:	31 d2                	xor    %edx,%edx
  801cb3:	f7 f7                	div    %edi
  801cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb8:	f7 f7                	div    %edi
  801cba:	eb a9                	jmp    801c65 <__umoddi3+0x25>
  801cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	83 c4 20             	add    $0x20,%esp
  801cc7:	5e                   	pop    %esi
  801cc8:	5f                   	pop    %edi
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    
  801ccb:	90                   	nop
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cd4:	d3 e2                	shl    %cl,%edx
  801cd6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801cd9:	ba 20 00 00 00       	mov    $0x20,%edx
  801cde:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801ce1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801ce4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ce8:	89 fa                	mov    %edi,%edx
  801cea:	d3 ea                	shr    %cl,%edx
  801cec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cf0:	0b 55 f4             	or     -0xc(%ebp),%edx
  801cf3:	d3 e7                	shl    %cl,%edi
  801cf5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cf9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801cfc:	89 f2                	mov    %esi,%edx
  801cfe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801d01:	89 c7                	mov    %eax,%edi
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801d0c:	89 c2                	mov    %eax,%edx
  801d0e:	d3 e6                	shl    %cl,%esi
  801d10:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d14:	d3 ea                	shr    %cl,%edx
  801d16:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d1a:	09 d6                	or     %edx,%esi
  801d1c:	89 f0                	mov    %esi,%eax
  801d1e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801d21:	d3 e7                	shl    %cl,%edi
  801d23:	89 f2                	mov    %esi,%edx
  801d25:	f7 75 f4             	divl   -0xc(%ebp)
  801d28:	89 d6                	mov    %edx,%esi
  801d2a:	f7 65 e8             	mull   -0x18(%ebp)
  801d2d:	39 d6                	cmp    %edx,%esi
  801d2f:	72 2b                	jb     801d5c <__umoddi3+0x11c>
  801d31:	39 c7                	cmp    %eax,%edi
  801d33:	72 23                	jb     801d58 <__umoddi3+0x118>
  801d35:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d39:	29 c7                	sub    %eax,%edi
  801d3b:	19 d6                	sbb    %edx,%esi
  801d3d:	89 f0                	mov    %esi,%eax
  801d3f:	89 f2                	mov    %esi,%edx
  801d41:	d3 ef                	shr    %cl,%edi
  801d43:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d47:	d3 e0                	shl    %cl,%eax
  801d49:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d4d:	09 f8                	or     %edi,%eax
  801d4f:	d3 ea                	shr    %cl,%edx
  801d51:	83 c4 20             	add    $0x20,%esp
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    
  801d58:	39 d6                	cmp    %edx,%esi
  801d5a:	75 d9                	jne    801d35 <__umoddi3+0xf5>
  801d5c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801d5f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801d62:	eb d1                	jmp    801d35 <__umoddi3+0xf5>
  801d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	0f 82 18 ff ff ff    	jb     801c88 <__umoddi3+0x48>
  801d70:	e9 1d ff ff ff       	jmp    801c92 <__umoddi3+0x52>
