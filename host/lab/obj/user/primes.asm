
obj/user/primes:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 13 01 00 00       	call   800144 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 c2 14 00 00       	call   80151a <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("%d ", p);
  80005a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005e:	c7 04 24 20 21 80 00 	movl   $0x802120,(%esp)
  800065:	e8 23 02 00 00       	call   80028d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80006a:	e8 d7 10 00 00       	call   801146 <fork>
  80006f:	89 c7                	mov    %eax,%edi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 20                	jns    800095 <primeproc+0x61>
		panic("fork: %e", id);
  800075:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800079:	c7 44 24 08 24 21 80 	movl   $0x802124,0x8(%esp)
  800080:	00 
  800081:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800088:	00 
  800089:	c7 04 24 2d 21 80 00 	movl   $0x80212d,(%esp)
  800090:	e8 33 01 00 00       	call   8001c8 <_panic>
	if (id == 0)
  800095:	85 c0                	test   %eax,%eax
  800097:	74 a7                	je     800040 <primeproc+0xc>
		goto top;
	
	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800099:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80009c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ab:	00 
  8000ac:	89 34 24             	mov    %esi,(%esp)
  8000af:	e8 66 14 00 00       	call   80151a <ipc_recv>
  8000b4:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000b6:	89 c2                	mov    %eax,%edx
  8000b8:	c1 fa 1f             	sar    $0x1f,%edx
  8000bb:	f7 fb                	idiv   %ebx
  8000bd:	85 d2                	test   %edx,%edx
  8000bf:	74 db                	je     80009c <primeproc+0x68>
			ipc_send(id, i, 0, 0);
  8000c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000c8:	00 
  8000c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d0:	00 
  8000d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000d5:	89 3c 24             	mov    %edi,(%esp)
  8000d8:	e8 d3 13 00 00       	call   8014b0 <ipc_send>
  8000dd:	eb bd                	jmp    80009c <primeproc+0x68>

008000df <umain>:
	}
}

void
umain(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000e7:	e8 5a 10 00 00       	call   801146 <fork>
  8000ec:	89 c6                	mov    %eax,%esi
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <umain+0x33>
		panic("fork: %e", id);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 24 21 80 	movl   $0x802124,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 2d 21 80 00 	movl   $0x80212d,(%esp)
  80010d:	e8 b6 00 00 00       	call   8001c8 <_panic>
	if (id == 0)
  800112:	bb 02 00 00 00       	mov    $0x2,%ebx
  800117:	85 c0                	test   %eax,%eax
  800119:	75 05                	jne    800120 <umain+0x41>
		primeproc();
  80011b:	e8 14 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800120:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800127:	00 
  800128:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80012f:	00 
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 74 13 00 00       	call   8014b0 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  80013c:	83 c3 01             	add    $0x1,%ebx
  80013f:	eb df                	jmp    800120 <umain+0x41>
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
  80014a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80014d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800156:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  80015d:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800160:	e8 2c 0f 00 00       	call   801091 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800177:	85 f6                	test   %esi,%esi
  800179:	7e 07                	jle    800182 <libmain+0x3e>
		binaryname = argv[0];
  80017b:	8b 03                	mov    (%ebx),%eax
  80017d:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  800182:	c7 04 24 3b 21 80 00 	movl   $0x80213b,(%esp)
  800189:	e8 ff 00 00 00       	call   80028d <cprintf>
	umain(argc, argv);
  80018e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800192:	89 34 24             	mov    %esi,(%esp)
  800195:	e8 45 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  80019a:	e8 0d 00 00 00       	call   8001ac <exit>
}
  80019f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a5:	89 ec                	mov    %ebp,%esp
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    
  8001a9:	00 00                	add    %al,(%eax)
	...

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b2:	e8 94 18 00 00       	call   801a4b <close_all>
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 02 0f 00 00       	call   8010c5 <sys_env_destroy>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
  8001c5:	00 00                	add    %al,(%eax)
	...

008001c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  8001cf:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001d2:	a1 28 50 80 00       	mov    0x805028,%eax
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	74 10                	je     8001eb <_panic+0x23>
		cprintf("%s: ", argv0);
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	c7 04 24 64 21 80 00 	movl   $0x802164,(%esp)
  8001e6:	e8 a2 00 00 00       	call   80028d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f9:	a1 00 50 80 00       	mov    0x805000,%eax
  8001fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800202:	c7 04 24 69 21 80 00 	movl   $0x802169,(%esp)
  800209:	e8 7f 00 00 00       	call   80028d <cprintf>
	vcprintf(fmt, ap);
  80020e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800212:	8b 45 10             	mov    0x10(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 0f 00 00 00       	call   80022c <vcprintf>
	cprintf("\n");
  80021d:	c7 04 24 4b 21 80 00 	movl   $0x80214b,(%esp)
  800224:	e8 64 00 00 00       	call   80028d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800229:	cc                   	int3   
  80022a:	eb fd                	jmp    800229 <_panic+0x61>

0080022c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800235:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023c:	00 00 00 
	b.cnt = 0;
  80023f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800246:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 44 24 08          	mov    %eax,0x8(%esp)
  800257:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800261:	c7 04 24 a7 02 80 00 	movl   $0x8002a7,(%esp)
  800268:	e8 d0 01 00 00       	call   80043d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800273:	89 44 24 04          	mov    %eax,0x4(%esp)
  800277:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 db 0a 00 00       	call   800d60 <sys_cputs>

	return b.cnt;
}
  800285:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800293:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	e8 87 ff ff ff       	call   80022c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 14             	sub    $0x14,%esp
  8002ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b1:	8b 03                	mov    (%ebx),%eax
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002ba:	83 c0 01             	add    $0x1,%eax
  8002bd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c4:	75 19                	jne    8002df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002cd:	00 
  8002ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d1:	89 04 24             	mov    %eax,(%esp)
  8002d4:	e8 87 0a 00 00       	call   800d60 <sys_cputs>
		b->idx = 0;
  8002d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    
  8002e9:	00 00                	add    %al,(%eax)
  8002eb:	00 00                	add    %al,(%eax)
  8002ed:	00 00                	add    %al,(%eax)
	...

008002f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 4c             	sub    $0x4c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d6                	mov    %edx,%esi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800304:	8b 55 0c             	mov    0xc(%ebp),%edx
  800307:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80030a:	8b 45 10             	mov    0x10(%ebp),%eax
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800310:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800313:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031b:	39 d1                	cmp    %edx,%ecx
  80031d:	72 15                	jb     800334 <printnum+0x44>
  80031f:	77 07                	ja     800328 <printnum+0x38>
  800321:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800324:	39 d0                	cmp    %edx,%eax
  800326:	76 0c                	jbe    800334 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800328:	83 eb 01             	sub    $0x1,%ebx
  80032b:	85 db                	test   %ebx,%ebx
  80032d:	8d 76 00             	lea    0x0(%esi),%esi
  800330:	7f 61                	jg     800393 <printnum+0xa3>
  800332:	eb 70                	jmp    8003a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800334:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800338:	83 eb 01             	sub    $0x1,%ebx
  80033b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800347:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80034b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80034e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800351:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800354:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800358:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035f:	00 
  800360:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800369:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036d:	e8 3e 1b 00 00       	call   801eb0 <__udivdi3>
  800372:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800375:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	89 54 24 04          	mov    %edx,0x4(%esp)
  800387:	89 f2                	mov    %esi,%edx
  800389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038c:	e8 5f ff ff ff       	call   8002f0 <printnum>
  800391:	eb 11                	jmp    8003a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800393:	89 74 24 04          	mov    %esi,0x4(%esp)
  800397:	89 3c 24             	mov    %edi,(%esp)
  80039a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039d:	83 eb 01             	sub    $0x1,%ebx
  8003a0:	85 db                	test   %ebx,%ebx
  8003a2:	7f ef                	jg     800393 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ba:	00 
  8003bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003be:	89 14 24             	mov    %edx,(%esp)
  8003c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003c8:	e8 13 1c 00 00       	call   801fe0 <__umoddi3>
  8003cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d1:	0f be 80 85 21 80 00 	movsbl 0x802185(%eax),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003de:	83 c4 4c             	add    $0x4c,%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e9:	83 fa 01             	cmp    $0x1,%edx
  8003ec:	7e 0e                	jle    8003fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ee:	8b 10                	mov    (%eax),%edx
  8003f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 02                	mov    (%edx),%eax
  8003f7:	8b 52 04             	mov    0x4(%edx),%edx
  8003fa:	eb 22                	jmp    80041e <getuint+0x38>
	else if (lflag)
  8003fc:	85 d2                	test   %edx,%edx
  8003fe:	74 10                	je     800410 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 04             	lea    0x4(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
  80040e:	eb 0e                	jmp    80041e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800410:	8b 10                	mov    (%eax),%edx
  800412:	8d 4a 04             	lea    0x4(%edx),%ecx
  800415:	89 08                	mov    %ecx,(%eax)
  800417:	8b 02                	mov    (%edx),%eax
  800419:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800426:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	3b 50 04             	cmp    0x4(%eax),%edx
  80042f:	73 0a                	jae    80043b <sprintputch+0x1b>
		*b->buf++ = ch;
  800431:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800434:	88 0a                	mov    %cl,(%edx)
  800436:	83 c2 01             	add    $0x1,%edx
  800439:	89 10                	mov    %edx,(%eax)
}
  80043b:	5d                   	pop    %ebp
  80043c:	c3                   	ret    

0080043d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043d:	55                   	push   %ebp
  80043e:	89 e5                	mov    %esp,%ebp
  800440:	57                   	push   %edi
  800441:	56                   	push   %esi
  800442:	53                   	push   %ebx
  800443:	83 ec 5c             	sub    $0x5c,%esp
  800446:	8b 7d 08             	mov    0x8(%ebp),%edi
  800449:	8b 75 0c             	mov    0xc(%ebp),%esi
  80044c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800456:	eb 11                	jmp    800469 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800458:	85 c0                	test   %eax,%eax
  80045a:	0f 84 02 04 00 00    	je     800862 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800460:	89 74 24 04          	mov    %esi,0x4(%esp)
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800469:	0f b6 03             	movzbl (%ebx),%eax
  80046c:	83 c3 01             	add    $0x1,%ebx
  80046f:	83 f8 25             	cmp    $0x25,%eax
  800472:	75 e4                	jne    800458 <vprintfmt+0x1b>
  800474:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800478:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800486:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	eb 06                	jmp    80049a <vprintfmt+0x5d>
  800494:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800498:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	0f b6 13             	movzbl (%ebx),%edx
  80049d:	0f b6 c2             	movzbl %dl,%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8004a6:	83 ea 23             	sub    $0x23,%edx
  8004a9:	80 fa 55             	cmp    $0x55,%dl
  8004ac:	0f 87 93 03 00 00    	ja     800845 <vprintfmt+0x408>
  8004b2:	0f b6 d2             	movzbl %dl,%edx
  8004b5:	ff 24 95 c0 22 80 00 	jmp    *0x8022c0(,%edx,4)
  8004bc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c0:	eb d6                	jmp    800498 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c5:	83 ea 30             	sub    $0x30,%edx
  8004c8:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8004cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004d1:	83 fb 09             	cmp    $0x9,%ebx
  8004d4:	77 4c                	ja     800522 <vprintfmt+0xe5>
  8004d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004d9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004df:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004e6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004e9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004ec:	83 fb 09             	cmp    $0x9,%ebx
  8004ef:	76 eb                	jbe    8004dc <vprintfmt+0x9f>
  8004f1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f7:	eb 29                	jmp    800522 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004fc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800502:	8b 12                	mov    (%edx),%edx
  800504:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  800507:	eb 19                	jmp    800522 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800509:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050c:	c1 fa 1f             	sar    $0x1f,%edx
  80050f:	f7 d2                	not    %edx
  800511:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800514:	eb 82                	jmp    800498 <vprintfmt+0x5b>
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80051d:	e9 76 ff ff ff       	jmp    800498 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800522:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800526:	0f 89 6c ff ff ff    	jns    800498 <vprintfmt+0x5b>
  80052c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80052f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800532:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800535:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800538:	e9 5b ff ff ff       	jmp    800498 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800540:	e9 53 ff ff ff       	jmp    800498 <vprintfmt+0x5b>
  800545:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	ff d7                	call   *%edi
  80055c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80055f:	e9 05 ff ff ff       	jmp    800469 <vprintfmt+0x2c>
  800564:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 c2                	mov    %eax,%edx
  800574:	c1 fa 1f             	sar    $0x1f,%edx
  800577:	31 d0                	xor    %edx,%eax
  800579:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80057b:	83 f8 0f             	cmp    $0xf,%eax
  80057e:	7f 0b                	jg     80058b <vprintfmt+0x14e>
  800580:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	75 20                	jne    8005ab <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80058b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058f:	c7 44 24 08 96 21 80 	movl   $0x802196,0x8(%esp)
  800596:	00 
  800597:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059b:	89 3c 24             	mov    %edi,(%esp)
  80059e:	e8 47 03 00 00       	call   8008ea <printfmt>
  8005a3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005a6:	e9 be fe ff ff       	jmp    800469 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005af:	c7 44 24 08 9f 21 80 	movl   $0x80219f,0x8(%esp)
  8005b6:	00 
  8005b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005bb:	89 3c 24             	mov    %edi,(%esp)
  8005be:	e8 27 03 00 00       	call   8008ea <printfmt>
  8005c3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005c6:	e9 9e fe ff ff       	jmp    800469 <vprintfmt+0x2c>
  8005cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ce:	89 c3                	mov    %eax,%ebx
  8005d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	75 07                	jne    8005f2 <vprintfmt+0x1b5>
  8005eb:	c7 45 e0 a2 21 80 00 	movl   $0x8021a2,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005f2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005f6:	7e 06                	jle    8005fe <vprintfmt+0x1c1>
  8005f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005fc:	75 13                	jne    800611 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800601:	0f be 02             	movsbl (%edx),%eax
  800604:	85 c0                	test   %eax,%eax
  800606:	0f 85 99 00 00 00    	jne    8006a5 <vprintfmt+0x268>
  80060c:	e9 86 00 00 00       	jmp    800697 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800611:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800615:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800618:	89 0c 24             	mov    %ecx,(%esp)
  80061b:	e8 1b 03 00 00       	call   80093b <strnlen>
  800620:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800623:	29 c2                	sub    %eax,%edx
  800625:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800628:	85 d2                	test   %edx,%edx
  80062a:	7e d2                	jle    8005fe <vprintfmt+0x1c1>
					putch(padc, putdat);
  80062c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800630:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800633:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800636:	89 d3                	mov    %edx,%ebx
  800638:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	83 eb 01             	sub    $0x1,%ebx
  800647:	85 db                	test   %ebx,%ebx
  800649:	7f ed                	jg     800638 <vprintfmt+0x1fb>
  80064b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80064e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800655:	eb a7                	jmp    8005fe <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800657:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80065b:	74 18                	je     800675 <vprintfmt+0x238>
  80065d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800660:	83 fa 5e             	cmp    $0x5e,%edx
  800663:	76 10                	jbe    800675 <vprintfmt+0x238>
					putch('?', putdat);
  800665:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800669:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800670:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800673:	eb 0a                	jmp    80067f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800675:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800683:	0f be 03             	movsbl (%ebx),%eax
  800686:	85 c0                	test   %eax,%eax
  800688:	74 05                	je     80068f <vprintfmt+0x252>
  80068a:	83 c3 01             	add    $0x1,%ebx
  80068d:	eb 29                	jmp    8006b8 <vprintfmt+0x27b>
  80068f:	89 fe                	mov    %edi,%esi
  800691:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800694:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800697:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069b:	7f 2e                	jg     8006cb <vprintfmt+0x28e>
  80069d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006a0:	e9 c4 fd ff ff       	jmp    800469 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006a8:	83 c2 01             	add    $0x1,%edx
  8006ab:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8006ae:	89 f7                	mov    %esi,%edi
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006b6:	89 d3                	mov    %edx,%ebx
  8006b8:	85 f6                	test   %esi,%esi
  8006ba:	78 9b                	js     800657 <vprintfmt+0x21a>
  8006bc:	83 ee 01             	sub    $0x1,%esi
  8006bf:	79 96                	jns    800657 <vprintfmt+0x21a>
  8006c1:	89 fe                	mov    %edi,%esi
  8006c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c9:	eb cc                	jmp    800697 <vprintfmt+0x25a>
  8006cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006de:	83 eb 01             	sub    $0x1,%ebx
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	7f ec                	jg     8006d1 <vprintfmt+0x294>
  8006e5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006e8:	e9 7c fd ff ff       	jmp    800469 <vprintfmt+0x2c>
  8006ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f0:	83 f9 01             	cmp    $0x1,%ecx
  8006f3:	7e 16                	jle    80070b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 08             	lea    0x8(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	8b 48 04             	mov    0x4(%eax),%ecx
  800703:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800706:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800709:	eb 32                	jmp    80073d <vprintfmt+0x300>
	else if (lflag)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	74 18                	je     800727 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800725:	eb 16                	jmp    80073d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8d 50 04             	lea    0x4(%eax),%edx
  80072d:	89 55 14             	mov    %edx,0x14(%ebp)
  800730:	8b 00                	mov    (%eax),%eax
  800732:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800735:	89 c2                	mov    %eax,%edx
  800737:	c1 fa 1f             	sar    $0x1f,%edx
  80073a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800740:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800743:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800748:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80074c:	0f 89 b1 00 00 00    	jns    800803 <vprintfmt+0x3c6>
				putch('-', putdat);
  800752:	89 74 24 04          	mov    %esi,0x4(%esp)
  800756:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80075d:	ff d7                	call   *%edi
				num = -(long long) num;
  80075f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800762:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800765:	f7 d8                	neg    %eax
  800767:	83 d2 00             	adc    $0x0,%edx
  80076a:	f7 da                	neg    %edx
  80076c:	e9 92 00 00 00       	jmp    800803 <vprintfmt+0x3c6>
  800771:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800774:	89 ca                	mov    %ecx,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 68 fc ff ff       	call   8003e6 <getuint>
  80077e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800783:	eb 7e                	jmp    800803 <vprintfmt+0x3c6>
  800785:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800788:	89 ca                	mov    %ecx,%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 54 fc ff ff       	call   8003e6 <getuint>
			if ((long long) num < 0) {
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800798:	bb 08 00 00 00       	mov    $0x8,%ebx
  80079d:	85 d2                	test   %edx,%edx
  80079f:	79 62                	jns    800803 <vprintfmt+0x3c6>
				putch('-', putdat);
  8007a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007ac:	ff d7                	call   *%edi
				num = -(long long) num;
  8007ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007b4:	f7 d8                	neg    %eax
  8007b6:	83 d2 00             	adc    $0x0,%edx
  8007b9:	f7 da                	neg    %edx
  8007bb:	eb 46                	jmp    800803 <vprintfmt+0x3c6>
  8007bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8007c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007cb:	ff d7                	call   *%edi
			putch('x', putdat);
  8007cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007d8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ef:	eb 12                	jmp    800803 <vprintfmt+0x3c6>
  8007f1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f4:	89 ca                	mov    %ecx,%edx
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 e8 fb ff ff       	call   8003e6 <getuint>
  8007fe:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800803:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800807:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80080b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80080e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800812:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	89 54 24 04          	mov    %edx,0x4(%esp)
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	89 f8                	mov    %edi,%eax
  800821:	e8 ca fa ff ff       	call   8002f0 <printnum>
  800826:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800829:	e9 3b fc ff ff       	jmp    800469 <vprintfmt+0x2c>
  80082e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800831:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800834:	89 74 24 04          	mov    %esi,0x4(%esp)
  800838:	89 14 24             	mov    %edx,(%esp)
  80083b:	ff d7                	call   *%edi
  80083d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800840:	e9 24 fc ff ff       	jmp    800469 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800845:	89 74 24 04          	mov    %esi,0x4(%esp)
  800849:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800850:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800852:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800855:	80 38 25             	cmpb   $0x25,(%eax)
  800858:	0f 84 0b fc ff ff    	je     800469 <vprintfmt+0x2c>
  80085e:	89 c3                	mov    %eax,%ebx
  800860:	eb f0                	jmp    800852 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800862:	83 c4 5c             	add    $0x5c,%esp
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5f                   	pop    %edi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 28             	sub    $0x28,%esp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800876:	85 c0                	test   %eax,%eax
  800878:	74 04                	je     80087e <vsnprintf+0x14>
  80087a:	85 d2                	test   %edx,%edx
  80087c:	7f 07                	jg     800885 <vsnprintf+0x1b>
  80087e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800883:	eb 3b                	jmp    8008c0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800885:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800888:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80088c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80088f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800896:	8b 45 14             	mov    0x14(%ebp),%eax
  800899:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089d:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	c7 04 24 20 04 80 00 	movl   $0x800420,(%esp)
  8008b2:	e8 86 fb ff ff       	call   80043d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008c8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	89 04 24             	mov    %eax,(%esp)
  8008e3:	e8 82 ff ff ff       	call   80086a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008f0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	89 44 24 04          	mov    %eax,0x4(%esp)
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	89 04 24             	mov    %eax,(%esp)
  80090b:	e8 2d fb ff ff       	call   80043d <vprintfmt>
	va_end(ap);
}
  800910:	c9                   	leave  
  800911:	c3                   	ret    
	...

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	80 3a 00             	cmpb   $0x0,(%edx)
  80092e:	74 09                	je     800939 <strlen+0x19>
		n++;
  800930:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800937:	75 f7                	jne    800930 <strlen+0x10>
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 19                	je     800962 <strnlen+0x27>
  800949:	80 3b 00             	cmpb   $0x0,(%ebx)
  80094c:	74 14                	je     800962 <strnlen+0x27>
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800953:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800956:	39 c8                	cmp    %ecx,%eax
  800958:	74 0d                	je     800967 <strnlen+0x2c>
  80095a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80095e:	75 f3                	jne    800953 <strnlen+0x18>
  800960:	eb 05                	jmp    800967 <strnlen+0x2c>
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800974:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800979:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80097d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	84 c9                	test   %cl,%cl
  800985:	75 f2                	jne    800979 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	85 f6                	test   %esi,%esi
  80099a:	74 18                	je     8009b4 <strncpy+0x2a>
  80099c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009a1:	0f b6 1a             	movzbl (%edx),%ebx
  8009a4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a7:	80 3a 01             	cmpb   $0x1,(%edx)
  8009aa:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	39 ce                	cmp    %ecx,%esi
  8009b2:	77 ed                	ja     8009a1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c6:	89 f0                	mov    %esi,%eax
  8009c8:	85 c9                	test   %ecx,%ecx
  8009ca:	74 27                	je     8009f3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009cc:	83 e9 01             	sub    $0x1,%ecx
  8009cf:	74 1d                	je     8009ee <strlcpy+0x36>
  8009d1:	0f b6 1a             	movzbl (%edx),%ebx
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	74 16                	je     8009ee <strlcpy+0x36>
			*dst++ = *src++;
  8009d8:	88 18                	mov    %bl,(%eax)
  8009da:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009dd:	83 e9 01             	sub    $0x1,%ecx
  8009e0:	74 0e                	je     8009f0 <strlcpy+0x38>
			*dst++ = *src++;
  8009e2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e5:	0f b6 1a             	movzbl (%edx),%ebx
  8009e8:	84 db                	test   %bl,%bl
  8009ea:	75 ec                	jne    8009d8 <strlcpy+0x20>
  8009ec:	eb 02                	jmp    8009f0 <strlcpy+0x38>
  8009ee:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f0:	c6 00 00             	movb   $0x0,(%eax)
  8009f3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	84 c0                	test   %al,%al
  800a07:	74 15                	je     800a1e <strcmp+0x25>
  800a09:	3a 02                	cmp    (%edx),%al
  800a0b:	75 11                	jne    800a1e <strcmp+0x25>
		p++, q++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
  800a10:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a13:	0f b6 01             	movzbl (%ecx),%eax
  800a16:	84 c0                	test   %al,%al
  800a18:	74 04                	je     800a1e <strcmp+0x25>
  800a1a:	3a 02                	cmp    (%edx),%al
  800a1c:	74 ef                	je     800a0d <strcmp+0x14>
  800a1e:	0f b6 c0             	movzbl %al,%eax
  800a21:	0f b6 12             	movzbl (%edx),%edx
  800a24:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	53                   	push   %ebx
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a32:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a35:	85 c0                	test   %eax,%eax
  800a37:	74 23                	je     800a5c <strncmp+0x34>
  800a39:	0f b6 1a             	movzbl (%edx),%ebx
  800a3c:	84 db                	test   %bl,%bl
  800a3e:	74 24                	je     800a64 <strncmp+0x3c>
  800a40:	3a 19                	cmp    (%ecx),%bl
  800a42:	75 20                	jne    800a64 <strncmp+0x3c>
  800a44:	83 e8 01             	sub    $0x1,%eax
  800a47:	74 13                	je     800a5c <strncmp+0x34>
		n--, p++, q++;
  800a49:	83 c2 01             	add    $0x1,%edx
  800a4c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4f:	0f b6 1a             	movzbl (%edx),%ebx
  800a52:	84 db                	test   %bl,%bl
  800a54:	74 0e                	je     800a64 <strncmp+0x3c>
  800a56:	3a 19                	cmp    (%ecx),%bl
  800a58:	74 ea                	je     800a44 <strncmp+0x1c>
  800a5a:	eb 08                	jmp    800a64 <strncmp+0x3c>
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a61:	5b                   	pop    %ebx
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a64:	0f b6 02             	movzbl (%edx),%eax
  800a67:	0f b6 11             	movzbl (%ecx),%edx
  800a6a:	29 d0                	sub    %edx,%eax
  800a6c:	eb f3                	jmp    800a61 <strncmp+0x39>

00800a6e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a78:	0f b6 10             	movzbl (%eax),%edx
  800a7b:	84 d2                	test   %dl,%dl
  800a7d:	74 15                	je     800a94 <strchr+0x26>
		if (*s == c)
  800a7f:	38 ca                	cmp    %cl,%dl
  800a81:	75 07                	jne    800a8a <strchr+0x1c>
  800a83:	eb 14                	jmp    800a99 <strchr+0x2b>
  800a85:	38 ca                	cmp    %cl,%dl
  800a87:	90                   	nop
  800a88:	74 0f                	je     800a99 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f1                	jne    800a85 <strchr+0x17>
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 18                	je     800ac4 <strfind+0x29>
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	75 0a                	jne    800aba <strfind+0x1f>
  800ab0:	eb 12                	jmp    800ac4 <strfind+0x29>
  800ab2:	38 ca                	cmp    %cl,%dl
  800ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ab8:	74 0a                	je     800ac4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 ee                	jne    800ab2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	89 1c 24             	mov    %ebx,(%esp)
  800acf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ad3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae0:	85 c9                	test   %ecx,%ecx
  800ae2:	74 30                	je     800b14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aea:	75 25                	jne    800b11 <memset+0x4b>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 20                	jne    800b11 <memset+0x4b>
		c &= 0xFF;
  800af1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	c1 e3 08             	shl    $0x8,%ebx
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	c1 e6 18             	shl    $0x18,%esi
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	c1 e0 10             	shl    $0x10,%eax
  800b03:	09 f0                	or     %esi,%eax
  800b05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b07:	09 d8                	or     %ebx,%eax
  800b09:	c1 e9 02             	shr    $0x2,%ecx
  800b0c:	fc                   	cld    
  800b0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0f:	eb 03                	jmp    800b14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b11:	fc                   	cld    
  800b12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b14:	89 f8                	mov    %edi,%eax
  800b16:	8b 1c 24             	mov    (%esp),%ebx
  800b19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b21:	89 ec                	mov    %ebp,%esp
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	89 34 24             	mov    %esi,(%esp)
  800b2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b3d:	39 c6                	cmp    %eax,%esi
  800b3f:	73 35                	jae    800b76 <memmove+0x51>
  800b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b44:	39 d0                	cmp    %edx,%eax
  800b46:	73 2e                	jae    800b76 <memmove+0x51>
		s += n;
		d += n;
  800b48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4a:	f6 c2 03             	test   $0x3,%dl
  800b4d:	75 1b                	jne    800b6a <memmove+0x45>
  800b4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b55:	75 13                	jne    800b6a <memmove+0x45>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0e                	jne    800b6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b5c:	83 ef 04             	sub    $0x4,%edi
  800b5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b62:	c1 e9 02             	shr    $0x2,%ecx
  800b65:	fd                   	std    
  800b66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b68:	eb 09                	jmp    800b73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6a:	83 ef 01             	sub    $0x1,%edi
  800b6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b70:	fd                   	std    
  800b71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b74:	eb 20                	jmp    800b96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7c:	75 15                	jne    800b93 <memmove+0x6e>
  800b7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b84:	75 0d                	jne    800b93 <memmove+0x6e>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 08                	jne    800b93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b8b:	c1 e9 02             	shr    $0x2,%ecx
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b91:	eb 03                	jmp    800b96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b93:	fc                   	cld    
  800b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b96:	8b 34 24             	mov    (%esp),%esi
  800b99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b9d:	89 ec                	mov    %ebp,%esp
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
  800baa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	89 04 24             	mov    %eax,(%esp)
  800bbb:	e8 65 ff ff ff       	call   800b25 <memmove>
}
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd1:	85 c9                	test   %ecx,%ecx
  800bd3:	74 36                	je     800c0b <memcmp+0x49>
		if (*s1 != *s2)
  800bd5:	0f b6 06             	movzbl (%esi),%eax
  800bd8:	0f b6 1f             	movzbl (%edi),%ebx
  800bdb:	38 d8                	cmp    %bl,%al
  800bdd:	74 20                	je     800bff <memcmp+0x3d>
  800bdf:	eb 14                	jmp    800bf5 <memcmp+0x33>
  800be1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800be6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800beb:	83 c2 01             	add    $0x1,%edx
  800bee:	83 e9 01             	sub    $0x1,%ecx
  800bf1:	38 d8                	cmp    %bl,%al
  800bf3:	74 12                	je     800c07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c0             	movzbl %al,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 11                	jmp    800c10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bff:	83 e9 01             	sub    $0x1,%ecx
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	85 c9                	test   %ecx,%ecx
  800c09:	75 d6                	jne    800be1 <memcmp+0x1f>
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1b:	89 c2                	mov    %eax,%edx
  800c1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c20:	39 d0                	cmp    %edx,%eax
  800c22:	73 15                	jae    800c39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c28:	38 08                	cmp    %cl,(%eax)
  800c2a:	75 06                	jne    800c32 <memfind+0x1d>
  800c2c:	eb 0b                	jmp    800c39 <memfind+0x24>
  800c2e:	38 08                	cmp    %cl,(%eax)
  800c30:	74 07                	je     800c39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	39 c2                	cmp    %eax,%edx
  800c37:	77 f5                	ja     800c2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 04             	sub    $0x4,%esp
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4a:	0f b6 02             	movzbl (%edx),%eax
  800c4d:	3c 20                	cmp    $0x20,%al
  800c4f:	74 04                	je     800c55 <strtol+0x1a>
  800c51:	3c 09                	cmp    $0x9,%al
  800c53:	75 0e                	jne    800c63 <strtol+0x28>
		s++;
  800c55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c58:	0f b6 02             	movzbl (%edx),%eax
  800c5b:	3c 20                	cmp    $0x20,%al
  800c5d:	74 f6                	je     800c55 <strtol+0x1a>
  800c5f:	3c 09                	cmp    $0x9,%al
  800c61:	74 f2                	je     800c55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c63:	3c 2b                	cmp    $0x2b,%al
  800c65:	75 0c                	jne    800c73 <strtol+0x38>
		s++;
  800c67:	83 c2 01             	add    $0x1,%edx
  800c6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c71:	eb 15                	jmp    800c88 <strtol+0x4d>
	else if (*s == '-')
  800c73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c7a:	3c 2d                	cmp    $0x2d,%al
  800c7c:	75 0a                	jne    800c88 <strtol+0x4d>
		s++, neg = 1;
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c88:	85 db                	test   %ebx,%ebx
  800c8a:	0f 94 c0             	sete   %al
  800c8d:	74 05                	je     800c94 <strtol+0x59>
  800c8f:	83 fb 10             	cmp    $0x10,%ebx
  800c92:	75 18                	jne    800cac <strtol+0x71>
  800c94:	80 3a 30             	cmpb   $0x30,(%edx)
  800c97:	75 13                	jne    800cac <strtol+0x71>
  800c99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ca0:	75 0a                	jne    800cac <strtol+0x71>
		s += 2, base = 16;
  800ca2:	83 c2 02             	add    $0x2,%edx
  800ca5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800caa:	eb 15                	jmp    800cc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cac:	84 c0                	test   %al,%al
  800cae:	66 90                	xchg   %ax,%ax
  800cb0:	74 0f                	je     800cc1 <strtol+0x86>
  800cb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cba:	75 05                	jne    800cc1 <strtol+0x86>
		s++, base = 8;
  800cbc:	83 c2 01             	add    $0x1,%edx
  800cbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc8:	0f b6 0a             	movzbl (%edx),%ecx
  800ccb:	89 cf                	mov    %ecx,%edi
  800ccd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cd0:	80 fb 09             	cmp    $0x9,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0xa2>
			dig = *s - '0';
  800cd5:	0f be c9             	movsbl %cl,%ecx
  800cd8:	83 e9 30             	sub    $0x30,%ecx
  800cdb:	eb 1e                	jmp    800cfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cdd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 08                	ja     800ced <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 57             	sub    $0x57,%ecx
  800ceb:	eb 0e                	jmp    800cfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ced:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800cf0:	80 fb 19             	cmp    $0x19,%bl
  800cf3:	77 15                	ja     800d0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cfb:	39 f1                	cmp    %esi,%ecx
  800cfd:	7d 0b                	jge    800d0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cff:	83 c2 01             	add    $0x1,%edx
  800d02:	0f af c6             	imul   %esi,%eax
  800d05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d08:	eb be                	jmp    800cc8 <strtol+0x8d>
  800d0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d10:	74 05                	je     800d17 <strtol+0xdc>
		*endptr = (char *) s;
  800d12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d1b:	74 04                	je     800d21 <strtol+0xe6>
  800d1d:	89 c8                	mov    %ecx,%eax
  800d1f:	f7 d8                	neg    %eax
}
  800d21:	83 c4 04             	add    $0x4,%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    
  800d29:	00 00                	add    %al,(%eax)
	...

00800d2c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	89 1c 24             	mov    %ebx,(%esp)
  800d35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d39:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	89 d1                	mov    %edx,%ecx
  800d49:	89 d3                	mov    %edx,%ebx
  800d4b:	89 d7                	mov    %edx,%edi
  800d4d:	89 d6                	mov    %edx,%esi
  800d4f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d51:	8b 1c 24             	mov    (%esp),%ebx
  800d54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	89 1c 24             	mov    %ebx,(%esp)
  800d69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 c3                	mov    %eax,%ebx
  800d7e:	89 c7                	mov    %eax,%edi
  800d80:	89 c6                	mov    %eax,%esi
  800d82:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d84:	8b 1c 24             	mov    (%esp),%ebx
  800d87:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d8b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d8f:	89 ec                	mov    %ebp,%esp
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 38             	sub    $0x38,%esp
  800d99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 cb                	mov    %ecx,%ebx
  800db1:	89 cf                	mov    %ecx,%edi
  800db3:	89 ce                	mov    %ecx,%esi
  800db5:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7e 28                	jle    800de3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800dd6:	00 
  800dd7:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800dde:	e8 e5 f3 ff ff       	call   8001c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dec:	89 ec                	mov    %ebp,%esp
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	89 1c 24             	mov    %ebx,(%esp)
  800df9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dfd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	be 00 00 00 00       	mov    $0x0,%esi
  800e06:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e19:	8b 1c 24             	mov    (%esp),%ebx
  800e1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e20:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e24:	89 ec                	mov    %ebp,%esp
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 38             	sub    $0x38,%esp
  800e2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800e74:	e8 4f f3 ff ff       	call   8001c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e79:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e82:	89 ec                	mov    %ebp,%esp
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 38             	sub    $0x38,%esp
  800e8c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e92:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	89 df                	mov    %ebx,%edi
  800ea7:	89 de                	mov    %ebx,%esi
  800ea9:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800eab:	85 c0                	test   %eax,%eax
  800ead:	7e 28                	jle    800ed7 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eba:	00 
  800ebb:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800eca:	00 
  800ecb:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800ed2:	e8 f1 f2 ff ff       	call   8001c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800edd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee0:	89 ec                	mov    %ebp,%esp
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 38             	sub    $0x38,%esp
  800eea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef8:	b8 08 00 00 00       	mov    $0x8,%eax
  800efd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f00:	8b 55 08             	mov    0x8(%ebp),%edx
  800f03:	89 df                	mov    %ebx,%edi
  800f05:	89 de                	mov    %ebx,%esi
  800f07:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	7e 28                	jle    800f35 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f11:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f18:	00 
  800f19:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800f20:	00 
  800f21:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f28:	00 
  800f29:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800f30:	e8 93 f2 ff ff       	call   8001c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f35:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f38:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3e:	89 ec                	mov    %ebp,%esp
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 38             	sub    $0x38,%esp
  800f48:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f56:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	89 df                	mov    %ebx,%edi
  800f63:	89 de                	mov    %ebx,%esi
  800f65:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	7e 28                	jle    800f93 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f76:	00 
  800f77:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800f8e:	e8 35 f2 ff ff       	call   8001c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f93:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f96:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9c:	89 ec                	mov    %ebp,%esp
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 38             	sub    $0x38,%esp
  800fa6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faf:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800fb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 28                	jle    800ff1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fe4:	00 
  800fe5:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800fec:	e8 d7 f1 ff ff       	call   8001c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ff1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffa:	89 ec                	mov    %ebp,%esp
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 38             	sub    $0x38,%esp
  801004:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801007:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100d:	be 00 00 00 00       	mov    $0x0,%esi
  801012:	b8 04 00 00 00       	mov    $0x4,%eax
  801017:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101d:	8b 55 08             	mov    0x8(%ebp),%edx
  801020:	89 f7                	mov    %esi,%edi
  801022:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	7e 28                	jle    801050 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801028:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  80104b:	e8 78 f1 ff ff       	call   8001c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801050:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801053:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801056:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801059:	89 ec                	mov    %ebp,%esp
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	89 1c 24             	mov    %ebx,(%esp)
  801066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106e:	ba 00 00 00 00       	mov    $0x0,%edx
  801073:	b8 0b 00 00 00       	mov    $0xb,%eax
  801078:	89 d1                	mov    %edx,%ecx
  80107a:	89 d3                	mov    %edx,%ebx
  80107c:	89 d7                	mov    %edx,%edi
  80107e:	89 d6                	mov    %edx,%esi
  801080:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801082:	8b 1c 24             	mov    (%esp),%ebx
  801085:	8b 74 24 04          	mov    0x4(%esp),%esi
  801089:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80108d:	89 ec                	mov    %ebp,%esp
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	89 1c 24             	mov    %ebx,(%esp)
  80109a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8010ac:	89 d1                	mov    %edx,%ecx
  8010ae:	89 d3                	mov    %edx,%ebx
  8010b0:	89 d7                	mov    %edx,%edi
  8010b2:	89 d6                	mov    %edx,%esi
  8010b4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010b6:	8b 1c 24             	mov    (%esp),%ebx
  8010b9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010c1:	89 ec                	mov    %ebp,%esp
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 38             	sub    $0x38,%esp
  8010cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	89 cb                	mov    %ecx,%ebx
  8010e3:	89 cf                	mov    %ecx,%edi
  8010e5:	89 ce                	mov    %ecx,%esi
  8010e7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	7e 28                	jle    801115 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  801100:	00 
  801101:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  801110:	e8 b3 f0 ff ff       	call   8001c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801115:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801118:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80111b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80111e:	89 ec                	mov    %ebp,%esp
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    
	...

00801124 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 18             	sub    $0x18,%esp
        panic("sfork not implemented");
  80112a:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  801131:	00 
  801132:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801139:	00 
  80113a:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801141:	e8 82 f0 ff ff       	call   8001c8 <_panic>

00801146 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
  80114c:	83 ec 3c             	sub    $0x3c,%esp
        // LAB 4: Your code here.
        //panic("fork not implemented");
        envid_t envid;
        uint8_t * addr;
        int r;
        set_pgfault_handler(pgfault);
  80114f:	c7 04 24 b5 13 80 00 	movl   $0x8013b5,(%esp)
  801156:	e8 91 0c 00 00       	call   801dec <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80115b:	ba 07 00 00 00       	mov    $0x7,%edx
  801160:	89 d0                	mov    %edx,%eax
  801162:	cd 30                	int    $0x30
  801164:	89 45 d8             	mov    %eax,-0x28(%ebp)
        envid = sys_exofork();
        
	if (envid == 0) 
  801167:	85 c0                	test   %eax,%eax
  801169:	75 1c                	jne    801187 <fork+0x41>
	{
                env = &envs[ENVX(sys_getenvid())];
  80116b:	e8 21 ff ff ff       	call   801091 <sys_getenvid>
  801170:	25 ff 03 00 00       	and    $0x3ff,%eax
  801175:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801178:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117d:	a3 24 50 80 00       	mov    %eax,0x805024
                return 0;
  801182:	e9 07 02 00 00       	jmp    80138e <fork+0x248>
  801187:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80118e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801195:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
        }
	
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
	{
                if (vpd[i] & PTE_P) 
  80119c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80119f:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  8011a6:	a8 01                	test   $0x1,%al
  8011a8:	0f 84 20 01 00 00    	je     8012ce <fork+0x188>
  8011ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
		{
                        for (j = 0; j * PGSIZE + i * PTSIZE < UTOP && j < NPTENTRIES; j++) 
  8011b4:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  8011b9:	0f 87 0f 01 00 00    	ja     8012ce <fork+0x188>
  8011bf:	89 c6                	mov    %eax,%esi
  8011c1:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				int ad = j*PGSIZE+i*PTSIZE;

                                if (ad == UXSTACKTOP - PGSIZE) 
  8011cc:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  8011d1:	0f 84 cd 00 00 00    	je     8012a4 <fork+0x15e>
                                        continue;


                                pte_t p = vpt[i * NPTENTRIES + j];
  8011d7:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax

                                if ((p & PTE_P) && (p & PTE_U))
  8011de:	83 e0 05             	and    $0x5,%eax
  8011e1:	83 f8 05             	cmp    $0x5,%eax
  8011e4:	0f 85 ba 00 00 00    	jne    8012a4 <fork+0x15e>
        void *va;
        pte_t pte;

        // LAB 4: Your code here.
        //panic("duppage not implemented");
        pte = vpt[pn];
  8011ea:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax
        va = (void *)(pn * PGSIZE);

        if ((pte & PTE_P) == 0 || (pte & PTE_U) == 0)
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	83 e2 05             	and    $0x5,%edx
  8011f6:	83 fa 05             	cmp    $0x5,%edx
  8011f9:	74 1c                	je     801217 <fork+0xd1>
                panic("invalid permissions\n");
  8011fb:	c7 44 24 08 cb 24 80 	movl   $0x8024cb,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801212:	e8 b1 ef ff ff       	call   8001c8 <_panic>
        pte_t pte;

        // LAB 4: Your code here.
        //panic("duppage not implemented");
        pte = vpt[pn];
        va = (void *)(pn * PGSIZE);
  801217:	c1 e7 0c             	shl    $0xc,%edi

        if ((pte & PTE_P) == 0 || (pte & PTE_U) == 0)
                panic("invalid permissions\n");

        if ((pte & PTE_W) == 0 && (pte & PTE_COW) == 0) 
  80121a:	a9 02 08 00 00       	test   $0x802,%eax
  80121f:	75 2c                	jne    80124d <fork+0x107>
	{
		int err;
                err = sys_page_map(0, va, envid, va, PTE_P | PTE_U);
  801221:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801228:	00 
  801229:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801230:	89 44 24 08          	mov    %eax,0x8(%esp)
  801234:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123f:	e8 5c fd ff ff       	call   800fa0 <sys_page_map>
                if (err < 0)
  801244:	85 c0                	test   %eax,%eax
  801246:	79 5c                	jns    8012a4 <fork+0x15e>
  801248:	e9 4c 01 00 00       	jmp    801399 <fork+0x253>
                        return err;
        }
        else 
	{
		int err = sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW);
  80124d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801254:	00 
  801255:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801259:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80125c:	89 54 24 08          	mov    %edx,0x8(%esp)
  801260:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801264:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126b:	e8 30 fd ff ff       	call   800fa0 <sys_page_map>
                if (err < 0)
  801270:	85 c0                	test   %eax,%eax
  801272:	0f 88 21 01 00 00    	js     801399 <fork+0x253>
                        return err;
                err = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW);
  801278:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80127f:	00 
  801280:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801284:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80128b:	00 
  80128c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801297:	e8 04 fd ff ff       	call   800fa0 <sys_page_map>

                if (err < 0)
  80129c:	85 c0                	test   %eax,%eax
  80129e:	0f 88 f5 00 00 00    	js     801399 <fork+0x253>
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
	{
                if (vpd[i] & PTE_P) 
		{
                        for (j = 0; j * PGSIZE + i * PTSIZE < UTOP && j < NPTENTRIES; j++) 
  8012a4:	83 c3 01             	add    $0x1,%ebx
  8012a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012aa:	01 df                	add    %ebx,%edi
  8012ac:	89 f0                	mov    %esi,%eax
  8012ae:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
  8012b4:	0f 96 c1             	setbe  %cl
  8012b7:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  8012bd:	0f 9e c2             	setle  %dl
  8012c0:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8012c6:	84 d1                	test   %dl,%cl
  8012c8:	0f 85 fe fe ff ff    	jne    8011cc <fork+0x86>
                env = &envs[ENVX(sys_getenvid())];
                return 0;
        }
	
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
  8012ce:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8012d2:	81 45 e4 00 04 00 00 	addl   $0x400,-0x1c(%ebp)
  8012d9:	81 45 dc 00 00 40 00 	addl   $0x400000,-0x24(%ebp)
  8012e0:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
  8012e7:	0f 85 af fe ff ff    	jne    80119c <fork+0x56>
				}
                        }
                }
        }

        if (sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_P | PTE_U | PTE_W) < 0)
  8012ed:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012f4:	00 
  8012f5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012fc:	ee 
  8012fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801300:	89 04 24             	mov    %eax,(%esp)
  801303:	e8 f6 fc ff ff       	call   800ffe <sys_page_alloc>
  801308:	85 c0                	test   %eax,%eax
  80130a:	79 1c                	jns    801328 <fork+0x1e2>
                panic("sys_page_alloc could not alooc\n");
  80130c:	c7 44 24 08 4c 25 80 	movl   $0x80254c,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  80131b:	00 
  80131c:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801323:	e8 a0 ee ff ff       	call   8001c8 <_panic>
        
        extern void _pgfault_upcall(void);
	
        if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801328:	c7 44 24 04 7c 1e 80 	movl   $0x801e7c,0x4(%esp)
  80132f:	00 
  801330:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801333:	89 14 24             	mov    %edx,(%esp)
  801336:	e8 ed fa ff ff       	call   800e28 <sys_env_set_pgfault_upcall>
  80133b:	85 c0                	test   %eax,%eax
  80133d:	79 1c                	jns    80135b <fork+0x215>
                panic("failed in upcall\n");
  80133f:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801356:	e8 6d ee ff ff       	call   8001c8 <_panic>
	
        if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80135b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801362:	00 
  801363:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801366:	89 04 24             	mov    %eax,(%esp)
  801369:	e8 76 fb ff ff       	call   800ee4 <sys_env_set_status>
  80136e:	85 c0                	test   %eax,%eax
  801370:	79 1c                	jns    80138e <fork+0x248>
                panic("failed in status set\n");
  801372:	c7 44 24 08 f2 24 80 	movl   $0x8024f2,0x8(%esp)
  801379:	00 
  80137a:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  801381:	00 
  801382:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801389:	e8 3a ee ff ff       	call   8001c8 <_panic>

        return envid;
}
  80138e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801391:	83 c4 3c             	add    $0x3c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
                                pte_t p = vpt[i * NPTENTRIES + j];

                                if ((p & PTE_P) && (p & PTE_U))
				{
                                        if (duppage(envid, i * NPTENTRIES + j) < 0)
                                                panic("filing in duppage\n");
  801399:	c7 44 24 08 08 25 80 	movl   $0x802508,0x8(%esp)
  8013a0:	00 
  8013a1:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8013a8:	00 
  8013a9:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  8013b0:	e8 13 ee ff ff       	call   8001c8 <_panic>

008013b5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 24             	sub    $0x24,%esp
  8013bc:	8b 45 08             	mov    0x8(%ebp),%eax
        void *addr = (void *) utf->utf_fault_va;
  8013bf:	8b 18                	mov    (%eax),%ebx
        //   Use the read-only page table mappings at vpt
        //   (see <inc/memlayout.h>).

        // LAB 4: Your code here.
        
	pte_t pte = ((pte_t *)vpt)[VPN(addr)];
  8013c1:	89 da                	mov    %ebx,%edx
  8013c3:	c1 ea 0c             	shr    $0xc,%edx
  8013c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
        void *addr = (void *) utf->utf_fault_va;
        uint32_t err = utf->utf_err;
  8013cd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8013d1:	74 05                	je     8013d8 <pgfault+0x23>

        // LAB 4: Your code here.
        
	pte_t pte = ((pte_t *)vpt)[VPN(addr)];
        
	if(!((err & FEC_WR) != 0 && (pte & PTE_COW) != 0)) 
  8013d3:	f6 c6 08             	test   $0x8,%dh
  8013d6:	75 1c                	jne    8013f4 <pgfault+0x3f>
	{
                panic("invalid permissions\n");
  8013d8:	c7 44 24 08 cb 24 80 	movl   $0x8024cb,0x8(%esp)
  8013df:	00 
  8013e0:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013e7:	00 
  8013e8:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  8013ef:	e8 d4 ed ff ff       	call   8001c8 <_panic>
                return;
        }

        if (sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
  8013f4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013fb:	00 
  8013fc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801403:	00 
  801404:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140b:	e8 ee fb ff ff       	call   800ffe <sys_page_alloc>
  801410:	85 c0                	test   %eax,%eax
  801412:	79 1c                	jns    801430 <pgfault+0x7b>
                panic("error in sys_page_alloc\n");
  801414:	c7 44 24 08 1b 25 80 	movl   $0x80251b,0x8(%esp)
  80141b:	00 
  80141c:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801423:	00 
  801424:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  80142b:	e8 98 ed ff ff       	call   8001c8 <_panic>
        
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801430:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801436:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80143d:	00 
  80143e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801442:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801449:	e8 d7 f6 ff ff       	call   800b25 <memmove>
        
	if (sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W) < 0)
  80144e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801455:	00 
  801456:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80145a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801461:	00 
  801462:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801469:	00 
  80146a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801471:	e8 2a fb ff ff       	call   800fa0 <sys_page_map>
  801476:	85 c0                	test   %eax,%eax
  801478:	79 1c                	jns    801496 <pgfault+0xe1>
                panic("error in sys_page_map\n");
  80147a:	c7 44 24 08 34 25 80 	movl   $0x802534,0x8(%esp)
  801481:	00 
  801482:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801489:	00 
  80148a:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801491:	e8 32 ed ff ff       	call   8001c8 <_panic>
        
	sys_page_unmap(0, PFTEMP);
  801496:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80149d:	00 
  80149e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a5:	e8 98 fa ff ff       	call   800f42 <sys_page_unmap>
        //   No need to explicitly delete the old page's mapping.
        
        // LAB 4: Your code here.
        
        //panic("pgfault not implemented");
}
  8014aa:	83 c4 24             	add    $0x24,%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	57                   	push   %edi
  8014b4:	56                   	push   %esi
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 1c             	sub    $0x1c,%esp
  8014b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014bf:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  8014c2:	85 db                	test   %ebx,%ebx
  8014c4:	75 31                	jne    8014f7 <ipc_send+0x47>
  8014c6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8014cb:	eb 2a                	jmp    8014f7 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  8014cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014d0:	74 20                	je     8014f2 <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  8014d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d6:	c7 44 24 08 6c 25 80 	movl   $0x80256c,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 83 25 80 00 	movl   $0x802583,(%esp)
  8014ed:	e8 d6 ec ff ff       	call   8001c8 <_panic>


                sys_yield();
  8014f2:	e8 66 fb ff ff       	call   80105d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8014f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801503:	8b 45 08             	mov    0x8(%ebp),%eax
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	e8 e2 f8 ff ff       	call   800df0 <sys_ipc_try_send>
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 bb                	js     8014cd <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801512:	83 c4 1c             	add    $0x1c,%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5f                   	pop    %edi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	56                   	push   %esi
  80151e:	53                   	push   %ebx
  80151f:	83 ec 10             	sub    $0x10,%esp
  801522:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801525:	8b 45 0c             	mov    0xc(%ebp),%eax
  801528:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	75 05                	jne    801534 <ipc_recv+0x1a>
  80152f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 57 f8 ff ff       	call   800d93 <sys_ipc_recv>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 24                	js     801564 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801540:	85 db                	test   %ebx,%ebx
  801542:	74 0a                	je     80154e <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801544:	a1 24 50 80 00       	mov    0x805024,%eax
  801549:	8b 40 74             	mov    0x74(%eax),%eax
  80154c:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  80154e:	85 f6                	test   %esi,%esi
  801550:	74 0a                	je     80155c <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801552:	a1 24 50 80 00       	mov    0x805024,%eax
  801557:	8b 40 78             	mov    0x78(%eax),%eax
  80155a:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  80155c:	a1 24 50 80 00       	mov    0x805024,%eax
  801561:	8b 40 70             	mov    0x70(%eax),%eax
}
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
  80156b:	00 00                	add    %al,(%eax)
  80156d:	00 00                	add    %al,(%eax)
	...

00801570 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	05 00 00 00 30       	add    $0x30000000,%eax
  80157b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	89 04 24             	mov    %eax,(%esp)
  80158c:	e8 df ff ff ff       	call   801570 <fd2num>
  801591:	05 20 00 0d 00       	add    $0xd0020,%eax
  801596:	c1 e0 0c             	shl    $0xc,%eax
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8015a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8015a9:	a8 01                	test   $0x1,%al
  8015ab:	74 36                	je     8015e3 <fd_alloc+0x48>
  8015ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015b2:	a8 01                	test   $0x1,%al
  8015b4:	74 2d                	je     8015e3 <fd_alloc+0x48>
  8015b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8015bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8015c5:	89 c3                	mov    %eax,%ebx
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	c1 ea 16             	shr    $0x16,%edx
  8015cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8015cf:	f6 c2 01             	test   $0x1,%dl
  8015d2:	74 14                	je     8015e8 <fd_alloc+0x4d>
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	c1 ea 0c             	shr    $0xc,%edx
  8015d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015dc:	f6 c2 01             	test   $0x1,%dl
  8015df:	75 10                	jne    8015f1 <fd_alloc+0x56>
  8015e1:	eb 05                	jmp    8015e8 <fd_alloc+0x4d>
  8015e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015e8:	89 1f                	mov    %ebx,(%edi)
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015ef:	eb 17                	jmp    801608 <fd_alloc+0x6d>
  8015f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015fb:	75 c8                	jne    8015c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801603:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	83 f8 1f             	cmp    $0x1f,%eax
  801616:	77 36                	ja     80164e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801618:	05 00 00 0d 00       	add    $0xd0000,%eax
  80161d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801620:	89 c2                	mov    %eax,%edx
  801622:	c1 ea 16             	shr    $0x16,%edx
  801625:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80162c:	f6 c2 01             	test   $0x1,%dl
  80162f:	74 1d                	je     80164e <fd_lookup+0x41>
  801631:	89 c2                	mov    %eax,%edx
  801633:	c1 ea 0c             	shr    $0xc,%edx
  801636:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80163d:	f6 c2 01             	test   $0x1,%dl
  801640:	74 0c                	je     80164e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801642:	8b 55 0c             	mov    0xc(%ebp),%edx
  801645:	89 02                	mov    %eax,(%edx)
  801647:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80164c:	eb 05                	jmp    801653 <fd_lookup+0x46>
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80165e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 a0 ff ff ff       	call   80160d <fd_lookup>
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 0e                	js     80167f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801671:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801674:	8b 55 0c             	mov    0xc(%ebp),%edx
  801677:	89 50 04             	mov    %edx,0x4(%eax)
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	83 ec 10             	sub    $0x10,%esp
  801689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80168f:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801694:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801699:	be 0c 26 80 00       	mov    $0x80260c,%esi
		if (devtab[i]->dev_id == dev_id) {
  80169e:	39 08                	cmp    %ecx,(%eax)
  8016a0:	75 10                	jne    8016b2 <dev_lookup+0x31>
  8016a2:	eb 04                	jmp    8016a8 <dev_lookup+0x27>
  8016a4:	39 08                	cmp    %ecx,(%eax)
  8016a6:	75 0a                	jne    8016b2 <dev_lookup+0x31>
			*dev = devtab[i];
  8016a8:	89 03                	mov    %eax,(%ebx)
  8016aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016af:	90                   	nop
  8016b0:	eb 31                	jmp    8016e3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016b2:	83 c2 01             	add    $0x1,%edx
  8016b5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	75 e8                	jne    8016a4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8016bc:	a1 24 50 80 00       	mov    0x805024,%eax
  8016c1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cc:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  8016d3:	e8 b5 eb ff ff       	call   80028d <cprintf>
	*dev = 0;
  8016d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    

008016ea <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 24             	sub    $0x24,%esp
  8016f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	89 04 24             	mov    %eax,(%esp)
  801701:	e8 07 ff ff ff       	call   80160d <fd_lookup>
  801706:	85 c0                	test   %eax,%eax
  801708:	78 53                	js     80175d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801711:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801714:	8b 00                	mov    (%eax),%eax
  801716:	89 04 24             	mov    %eax,(%esp)
  801719:	e8 63 ff ff ff       	call   801681 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 3b                	js     80175d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801722:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801727:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80172e:	74 2d                	je     80175d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801730:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801733:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173a:	00 00 00 
	stat->st_isdir = 0;
  80173d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801744:	00 00 00 
	stat->st_dev = dev;
  801747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801750:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801754:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801757:	89 14 24             	mov    %edx,(%esp)
  80175a:	ff 50 14             	call   *0x14(%eax)
}
  80175d:	83 c4 24             	add    $0x24,%esp
  801760:	5b                   	pop    %ebx
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	53                   	push   %ebx
  801767:	83 ec 24             	sub    $0x24,%esp
  80176a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801770:	89 44 24 04          	mov    %eax,0x4(%esp)
  801774:	89 1c 24             	mov    %ebx,(%esp)
  801777:	e8 91 fe ff ff       	call   80160d <fd_lookup>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 5f                	js     8017df <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801780:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	8b 00                	mov    (%eax),%eax
  80178c:	89 04 24             	mov    %eax,(%esp)
  80178f:	e8 ed fe ff ff       	call   801681 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801794:	85 c0                	test   %eax,%eax
  801796:	78 47                	js     8017df <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801798:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80179b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80179f:	75 23                	jne    8017c4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  8017a1:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017a6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8017a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8017b8:	e8 d0 ea ff ff       	call   80028d <cprintf>
  8017bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  8017c2:	eb 1b                	jmp    8017df <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8017c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c7:	8b 48 18             	mov    0x18(%eax),%ecx
  8017ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cf:	85 c9                	test   %ecx,%ecx
  8017d1:	74 0c                	je     8017df <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	89 14 24             	mov    %edx,(%esp)
  8017dd:	ff d1                	call   *%ecx
}
  8017df:	83 c4 24             	add    $0x24,%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 24             	sub    $0x24,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f6:	89 1c 24             	mov    %ebx,(%esp)
  8017f9:	e8 0f fe ff ff       	call   80160d <fd_lookup>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 66                	js     801868 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	8b 00                	mov    (%eax),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 6b fe ff ff       	call   801681 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801816:	85 c0                	test   %eax,%eax
  801818:	78 4e                	js     801868 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80181d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801821:	75 23                	jne    801846 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801823:	a1 24 50 80 00       	mov    0x805024,%eax
  801828:	8b 40 4c             	mov    0x4c(%eax),%eax
  80182b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	c7 04 24 d1 25 80 00 	movl   $0x8025d1,(%esp)
  80183a:	e8 4e ea ff ff       	call   80028d <cprintf>
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801844:	eb 22                	jmp    801868 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801846:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801849:	8b 48 0c             	mov    0xc(%eax),%ecx
  80184c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801851:	85 c9                	test   %ecx,%ecx
  801853:	74 13                	je     801868 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801855:	8b 45 10             	mov    0x10(%ebp),%eax
  801858:	89 44 24 08          	mov    %eax,0x8(%esp)
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	89 14 24             	mov    %edx,(%esp)
  801866:	ff d1                	call   *%ecx
}
  801868:	83 c4 24             	add    $0x24,%esp
  80186b:	5b                   	pop    %ebx
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	53                   	push   %ebx
  801872:	83 ec 24             	sub    $0x24,%esp
  801875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187f:	89 1c 24             	mov    %ebx,(%esp)
  801882:	e8 86 fd ff ff       	call   80160d <fd_lookup>
  801887:	85 c0                	test   %eax,%eax
  801889:	78 6b                	js     8018f6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801895:	8b 00                	mov    (%eax),%eax
  801897:	89 04 24             	mov    %eax,(%esp)
  80189a:	e8 e2 fd ff ff       	call   801681 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 53                	js     8018f6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018a6:	8b 42 08             	mov    0x8(%edx),%eax
  8018a9:	83 e0 03             	and    $0x3,%eax
  8018ac:	83 f8 01             	cmp    $0x1,%eax
  8018af:	75 23                	jne    8018d4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8018b1:	a1 24 50 80 00       	mov    0x805024,%eax
  8018b6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8018b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 ee 25 80 00 	movl   $0x8025ee,(%esp)
  8018c8:	e8 c0 e9 ff ff       	call   80028d <cprintf>
  8018cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018d2:	eb 22                	jmp    8018f6 <read+0x88>
	}
	if (!dev->dev_read)
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018df:	85 c9                	test   %ecx,%ecx
  8018e1:	74 13                	je     8018f6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	89 14 24             	mov    %edx,(%esp)
  8018f4:	ff d1                	call   *%ecx
}
  8018f6:	83 c4 24             	add    $0x24,%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	57                   	push   %edi
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	83 ec 1c             	sub    $0x1c,%esp
  801905:	8b 7d 08             	mov    0x8(%ebp),%edi
  801908:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	bb 00 00 00 00       	mov    $0x0,%ebx
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
  80191a:	85 f6                	test   %esi,%esi
  80191c:	74 29                	je     801947 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80191e:	89 f0                	mov    %esi,%eax
  801920:	29 d0                	sub    %edx,%eax
  801922:	89 44 24 08          	mov    %eax,0x8(%esp)
  801926:	03 55 0c             	add    0xc(%ebp),%edx
  801929:	89 54 24 04          	mov    %edx,0x4(%esp)
  80192d:	89 3c 24             	mov    %edi,(%esp)
  801930:	e8 39 ff ff ff       	call   80186e <read>
		if (m < 0)
  801935:	85 c0                	test   %eax,%eax
  801937:	78 0e                	js     801947 <readn+0x4b>
			return m;
		if (m == 0)
  801939:	85 c0                	test   %eax,%eax
  80193b:	74 08                	je     801945 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80193d:	01 c3                	add    %eax,%ebx
  80193f:	89 da                	mov    %ebx,%edx
  801941:	39 f3                	cmp    %esi,%ebx
  801943:	72 d9                	jb     80191e <readn+0x22>
  801945:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801947:	83 c4 1c             	add    $0x1c,%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5f                   	pop    %edi
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    

0080194f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	83 ec 20             	sub    $0x20,%esp
  801957:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80195a:	89 34 24             	mov    %esi,(%esp)
  80195d:	e8 0e fc ff ff       	call   801570 <fd2num>
  801962:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801965:	89 54 24 04          	mov    %edx,0x4(%esp)
  801969:	89 04 24             	mov    %eax,(%esp)
  80196c:	e8 9c fc ff ff       	call   80160d <fd_lookup>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	85 c0                	test   %eax,%eax
  801975:	78 05                	js     80197c <fd_close+0x2d>
  801977:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80197a:	74 0c                	je     801988 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80197c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801980:	19 c0                	sbb    %eax,%eax
  801982:	f7 d0                	not    %eax
  801984:	21 c3                	and    %eax,%ebx
  801986:	eb 3d                	jmp    8019c5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	8b 06                	mov    (%esi),%eax
  801991:	89 04 24             	mov    %eax,(%esp)
  801994:	e8 e8 fc ff ff       	call   801681 <dev_lookup>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 16                	js     8019b5 <fd_close+0x66>
		if (dev->dev_close)
  80199f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a2:	8b 40 10             	mov    0x10(%eax),%eax
  8019a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	74 07                	je     8019b5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8019ae:	89 34 24             	mov    %esi,(%esp)
  8019b1:	ff d0                	call   *%eax
  8019b3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c0:	e8 7d f5 ff ff       	call   800f42 <sys_page_unmap>
	return r;
}
  8019c5:	89 d8                	mov    %ebx,%eax
  8019c7:	83 c4 20             	add    $0x20,%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	e8 27 fc ff ff       	call   80160d <fd_lookup>
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 13                	js     8019fd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019f1:	00 
  8019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f5:	89 04 24             	mov    %eax,(%esp)
  8019f8:	e8 52 ff ff ff       	call   80194f <fd_close>
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	83 ec 18             	sub    $0x18,%esp
  801a05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a12:	00 
  801a13:	8b 45 08             	mov    0x8(%ebp),%eax
  801a16:	89 04 24             	mov    %eax,(%esp)
  801a19:	e8 4d 03 00 00       	call   801d6b <open>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 1b                	js     801a3f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2b:	89 1c 24             	mov    %ebx,(%esp)
  801a2e:	e8 b7 fc ff ff       	call   8016ea <fstat>
  801a33:	89 c6                	mov    %eax,%esi
	close(fd);
  801a35:	89 1c 24             	mov    %ebx,(%esp)
  801a38:	e8 91 ff ff ff       	call   8019ce <close>
  801a3d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a3f:	89 d8                	mov    %ebx,%eax
  801a41:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a44:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a47:	89 ec                	mov    %ebp,%esp
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 14             	sub    $0x14,%esp
  801a52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a57:	89 1c 24             	mov    %ebx,(%esp)
  801a5a:	e8 6f ff ff ff       	call   8019ce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a5f:	83 c3 01             	add    $0x1,%ebx
  801a62:	83 fb 20             	cmp    $0x20,%ebx
  801a65:	75 f0                	jne    801a57 <close_all+0xc>
		close(i);
}
  801a67:	83 c4 14             	add    $0x14,%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 58             	sub    $0x58,%esp
  801a73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a79:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	89 04 24             	mov    %eax,(%esp)
  801a8c:	e8 7c fb ff ff       	call   80160d <fd_lookup>
  801a91:	89 c3                	mov    %eax,%ebx
  801a93:	85 c0                	test   %eax,%eax
  801a95:	0f 88 e0 00 00 00    	js     801b7b <dup+0x10e>
		return r;
	close(newfdnum);
  801a9b:	89 3c 24             	mov    %edi,(%esp)
  801a9e:	e8 2b ff ff ff       	call   8019ce <close>

	newfd = INDEX2FD(newfdnum);
  801aa3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801aa9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801aac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aaf:	89 04 24             	mov    %eax,(%esp)
  801ab2:	e8 c9 fa ff ff       	call   801580 <fd2data>
  801ab7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ab9:	89 34 24             	mov    %esi,(%esp)
  801abc:	e8 bf fa ff ff       	call   801580 <fd2data>
  801ac1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801ac4:	89 da                	mov    %ebx,%edx
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	c1 e8 16             	shr    $0x16,%eax
  801acb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ad2:	a8 01                	test   $0x1,%al
  801ad4:	74 43                	je     801b19 <dup+0xac>
  801ad6:	c1 ea 0c             	shr    $0xc,%edx
  801ad9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ae0:	a8 01                	test   $0x1,%al
  801ae2:	74 35                	je     801b19 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801ae4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801aeb:	25 07 0e 00 00       	and    $0xe07,%eax
  801af0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801af4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801af7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801afb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b02:	00 
  801b03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b0e:	e8 8d f4 ff ff       	call   800fa0 <sys_page_map>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 3f                	js     801b58 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1c:	89 c2                	mov    %eax,%edx
  801b1e:	c1 ea 0c             	shr    $0xc,%edx
  801b21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b28:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b2e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b32:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b3d:	00 
  801b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b49:	e8 52 f4 ff ff       	call   800fa0 <sys_page_map>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 04                	js     801b58 <dup+0xeb>
  801b54:	89 fb                	mov    %edi,%ebx
  801b56:	eb 23                	jmp    801b7b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b63:	e8 da f3 ff ff       	call   800f42 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b76:	e8 c7 f3 ff ff       	call   800f42 <sys_page_unmap>
	return r;
}
  801b7b:	89 d8                	mov    %ebx,%eax
  801b7d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b80:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b83:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b86:	89 ec                	mov    %ebp,%esp
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
  801b8a:	00 00                	add    %al,(%eax)
  801b8c:	00 00                	add    %al,(%eax)
	...

00801b90 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	53                   	push   %ebx
  801b94:	83 ec 14             	sub    $0x14,%esp
  801b97:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b99:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801b9f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801bae:	00 
  801baf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb3:	89 14 24             	mov    %edx,(%esp)
  801bb6:	e8 f5 f8 ff ff       	call   8014b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bc2:	00 
  801bc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bce:	e8 47 f9 ff ff       	call   80151a <ipc_recv>
}
  801bd3:	83 c4 14             	add    $0x14,%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	8b 40 0c             	mov    0xc(%eax),%eax
  801be5:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bed:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf7:	b8 02 00 00 00       	mov    $0x2,%eax
  801bfc:	e8 8f ff ff ff       	call   801b90 <fsipc>
}
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c0f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801c14:	ba 00 00 00 00       	mov    $0x0,%edx
  801c19:	b8 06 00 00 00       	mov    $0x6,%eax
  801c1e:	e8 6d ff ff ff       	call   801b90 <fsipc>
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c30:	b8 08 00 00 00       	mov    $0x8,%eax
  801c35:	e8 56 ff ff ff       	call   801b90 <fsipc>
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 14             	sub    $0x14,%esp
  801c43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	8b 40 0c             	mov    0xc(%eax),%eax
  801c4c:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	b8 05 00 00 00       	mov    $0x5,%eax
  801c5b:	e8 30 ff ff ff       	call   801b90 <fsipc>
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 2b                	js     801c8f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c64:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801c6b:	00 
  801c6c:	89 1c 24             	mov    %ebx,(%esp)
  801c6f:	e8 f6 ec ff ff       	call   80096a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c74:	a1 80 30 80 00       	mov    0x803080,%eax
  801c79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c7f:	a1 84 30 80 00       	mov    0x803084,%eax
  801c84:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c8f:	83 c4 14             	add    $0x14,%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 18             	sub    $0x18,%esp
  801c9b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  801ca1:	8b 52 0c             	mov    0xc(%edx),%edx
  801ca4:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  801caa:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801caf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cba:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801cc1:	e8 5f ee ff ff       	call   800b25 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801cc6:	ba 00 30 80 00       	mov    $0x803000,%edx
  801ccb:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd0:	e8 bb fe ff ff       	call   801b90 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	53                   	push   %ebx
  801cdb:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce4:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cec:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801cf1:	ba 00 30 80 00       	mov    $0x803000,%edx
  801cf6:	b8 03 00 00 00       	mov    $0x3,%eax
  801cfb:	e8 90 fe ff ff       	call   801b90 <fsipc>
  801d00:	89 c3                	mov    %eax,%ebx
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 17                	js     801d1d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801d06:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801d11:	00 
  801d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d15:	89 04 24             	mov    %eax,(%esp)
  801d18:	e8 08 ee ff ff       	call   800b25 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  801d1d:	89 d8                	mov    %ebx,%eax
  801d1f:	83 c4 14             	add    $0x14,%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	53                   	push   %ebx
  801d29:	83 ec 14             	sub    $0x14,%esp
  801d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d2f:	89 1c 24             	mov    %ebx,(%esp)
  801d32:	e8 e9 eb ff ff       	call   800920 <strlen>
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d3e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d44:	7f 1f                	jg     801d65 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801d51:	e8 14 ec ff ff       	call   80096a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d56:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5b:	b8 07 00 00 00       	mov    $0x7,%eax
  801d60:	e8 2b fe ff ff       	call   801b90 <fsipc>
}
  801d65:	83 c4 14             	add    $0x14,%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  801d71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d74:	89 04 24             	mov    %eax,(%esp)
  801d77:	e8 1f f8 ff ff       	call   80159b <fd_alloc>
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 6a                	js     801dea <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d87:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801d8e:	e8 d7 eb ff ff       	call   80096a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801d93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d96:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d9b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801da0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801da7:	00 
  801da8:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801daf:	00 
  801db0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801db7:	00 
  801db8:	89 04 24             	mov    %eax,(%esp)
  801dbb:	e8 f0 f6 ff ff       	call   8014b0 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801dc0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dc7:	00 
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd6:	e8 3f f7 ff ff       	call   80151a <ipc_recv>
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 0b                	js     801dea <open+0x7f>
		return r;
	return fd2num(fd);
  801ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de2:	89 04 24             	mov    %eax,(%esp)
  801de5:	e8 86 f7 ff ff       	call   801570 <fd2num>
	panic("open not implemented");
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//

void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	53                   	push   %ebx
  801df0:	83 ec 14             	sub    $0x14,%esp
	int r;
	if (_pgfault_handler == 0) {
  801df3:	83 3d 2c 50 80 00 00 	cmpl   $0x0,0x80502c
  801dfa:	75 6f                	jne    801e6b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801dfc:	e8 90 f2 ff ff       	call   801091 <sys_getenvid>
  801e01:	89 c3                	mov    %eax,%ebx
		if(sys_page_alloc(envid,(void*) UXSTACKTOP-PGSIZE,PTE_W|PTE_U|PTE_P)<0)
  801e03:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e0a:	00 
  801e0b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801e12:	ee 
  801e13:	89 04 24             	mov    %eax,(%esp)
  801e16:	e8 e3 f1 ff ff       	call   800ffe <sys_page_alloc>
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	79 1c                	jns    801e3b <set_pgfault_handler+0x4f>
		{
			panic("UXSTACKTOP could not be allocated\n");
  801e1f:	c7 44 24 08 14 26 80 	movl   $0x802614,0x8(%esp)
  801e26:	00 
  801e27:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801e2e:	00 
  801e2f:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  801e36:	e8 8d e3 ff ff       	call   8001c8 <_panic>
		}	
		
		if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall)<0)
  801e3b:	c7 44 24 04 7c 1e 80 	movl   $0x801e7c,0x4(%esp)
  801e42:	00 
  801e43:	89 1c 24             	mov    %ebx,(%esp)
  801e46:	e8 dd ef ff ff       	call   800e28 <sys_env_set_pgfault_upcall>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	79 1c                	jns    801e6b <set_pgfault_handler+0x7f>
		{
			panic("upcall failed\n");
  801e4f:	c7 44 24 08 46 26 80 	movl   $0x802646,0x8(%esp)
  801e56:	00 
  801e57:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801e5e:	00 
  801e5f:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  801e66:	e8 5d e3 ff ff       	call   8001c8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	a3 2c 50 80 00       	mov    %eax,0x80502c
	//cprintf("returning from set_pgfault_handler\n");
}
  801e73:	83 c4 14             	add    $0x14,%esp
  801e76:	5b                   	pop    %ebx
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	00 00                	add    %al,(%eax)
	...

00801e7c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e7c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e7d:	a1 2c 50 80 00       	mov    0x80502c,%eax
	call *%eax
  801e82:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e84:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.	
	
	addl $0x8, %esp 	// ignoring fault_va, utf_err and setting esp for pop
  801e87:	83 c4 08             	add    $0x8,%esp
	movl 0x20(%esp), %eax
  801e8a:	8b 44 24 20          	mov    0x20(%esp),%eax
	mov %eax, %ebx
  801e8e:	89 c3                	mov    %eax,%ebx
	movl 0x28(%esp), %eax
  801e90:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, %eax
  801e94:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  801e97:	89 18                	mov    %ebx,(%eax)
	movl %eax, 0x28(%esp)	
  801e99:	89 44 24 28          	mov    %eax,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e9d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e9e:	83 c4 04             	add    $0x4,%esp
	popfl
  801ea1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801ea2:	5c                   	pop    %esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ea3:	c3                   	ret    
	...

00801eb0 <__udivdi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	57                   	push   %edi
  801eb4:	56                   	push   %esi
  801eb5:	83 ec 10             	sub    $0x10,%esp
  801eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  801ebe:	8b 75 10             	mov    0x10(%ebp),%esi
  801ec1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ec9:	75 35                	jne    801f00 <__udivdi3+0x50>
  801ecb:	39 fe                	cmp    %edi,%esi
  801ecd:	77 61                	ja     801f30 <__udivdi3+0x80>
  801ecf:	85 f6                	test   %esi,%esi
  801ed1:	75 0b                	jne    801ede <__udivdi3+0x2e>
  801ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed8:	31 d2                	xor    %edx,%edx
  801eda:	f7 f6                	div    %esi
  801edc:	89 c6                	mov    %eax,%esi
  801ede:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ee1:	31 d2                	xor    %edx,%edx
  801ee3:	89 f8                	mov    %edi,%eax
  801ee5:	f7 f6                	div    %esi
  801ee7:	89 c7                	mov    %eax,%edi
  801ee9:	89 c8                	mov    %ecx,%eax
  801eeb:	f7 f6                	div    %esi
  801eed:	89 c1                	mov    %eax,%ecx
  801eef:	89 fa                	mov    %edi,%edx
  801ef1:	89 c8                	mov    %ecx,%eax
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
  801efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f00:	39 f8                	cmp    %edi,%eax
  801f02:	77 1c                	ja     801f20 <__udivdi3+0x70>
  801f04:	0f bd d0             	bsr    %eax,%edx
  801f07:	83 f2 1f             	xor    $0x1f,%edx
  801f0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f0d:	75 39                	jne    801f48 <__udivdi3+0x98>
  801f0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f12:	0f 86 a0 00 00 00    	jbe    801fb8 <__udivdi3+0x108>
  801f18:	39 f8                	cmp    %edi,%eax
  801f1a:	0f 82 98 00 00 00    	jb     801fb8 <__udivdi3+0x108>
  801f20:	31 ff                	xor    %edi,%edi
  801f22:	31 c9                	xor    %ecx,%ecx
  801f24:	89 c8                	mov    %ecx,%eax
  801f26:	89 fa                	mov    %edi,%edx
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	5e                   	pop    %esi
  801f2c:	5f                   	pop    %edi
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    
  801f2f:	90                   	nop
  801f30:	89 d1                	mov    %edx,%ecx
  801f32:	89 fa                	mov    %edi,%edx
  801f34:	89 c8                	mov    %ecx,%eax
  801f36:	31 ff                	xor    %edi,%edi
  801f38:	f7 f6                	div    %esi
  801f3a:	89 c1                	mov    %eax,%ecx
  801f3c:	89 fa                	mov    %edi,%edx
  801f3e:	89 c8                	mov    %ecx,%eax
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    
  801f47:	90                   	nop
  801f48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f4c:	89 f2                	mov    %esi,%edx
  801f4e:	d3 e0                	shl    %cl,%eax
  801f50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f53:	b8 20 00 00 00       	mov    $0x20,%eax
  801f58:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f5b:	89 c1                	mov    %eax,%ecx
  801f5d:	d3 ea                	shr    %cl,%edx
  801f5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f63:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f66:	d3 e6                	shl    %cl,%esi
  801f68:	89 c1                	mov    %eax,%ecx
  801f6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f6d:	89 fe                	mov    %edi,%esi
  801f6f:	d3 ee                	shr    %cl,%esi
  801f71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f75:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f7b:	d3 e7                	shl    %cl,%edi
  801f7d:	89 c1                	mov    %eax,%ecx
  801f7f:	d3 ea                	shr    %cl,%edx
  801f81:	09 d7                	or     %edx,%edi
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	89 f8                	mov    %edi,%eax
  801f87:	f7 75 ec             	divl   -0x14(%ebp)
  801f8a:	89 d6                	mov    %edx,%esi
  801f8c:	89 c7                	mov    %eax,%edi
  801f8e:	f7 65 e8             	mull   -0x18(%ebp)
  801f91:	39 d6                	cmp    %edx,%esi
  801f93:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f96:	72 30                	jb     801fc8 <__udivdi3+0x118>
  801f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f9f:	d3 e2                	shl    %cl,%edx
  801fa1:	39 c2                	cmp    %eax,%edx
  801fa3:	73 05                	jae    801faa <__udivdi3+0xfa>
  801fa5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801fa8:	74 1e                	je     801fc8 <__udivdi3+0x118>
  801faa:	89 f9                	mov    %edi,%ecx
  801fac:	31 ff                	xor    %edi,%edi
  801fae:	e9 71 ff ff ff       	jmp    801f24 <__udivdi3+0x74>
  801fb3:	90                   	nop
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fbf:	e9 60 ff ff ff       	jmp    801f24 <__udivdi3+0x74>
  801fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801fcb:	31 ff                	xor    %edi,%edi
  801fcd:	89 c8                	mov    %ecx,%eax
  801fcf:	89 fa                	mov    %edi,%edx
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
	...

00801fe0 <__umoddi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	83 ec 20             	sub    $0x20,%esp
  801fe8:	8b 55 14             	mov    0x14(%ebp),%edx
  801feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fee:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ff1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff4:	85 d2                	test   %edx,%edx
  801ff6:	89 c8                	mov    %ecx,%eax
  801ff8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ffb:	75 13                	jne    802010 <__umoddi3+0x30>
  801ffd:	39 f7                	cmp    %esi,%edi
  801fff:	76 3f                	jbe    802040 <__umoddi3+0x60>
  802001:	89 f2                	mov    %esi,%edx
  802003:	f7 f7                	div    %edi
  802005:	89 d0                	mov    %edx,%eax
  802007:	31 d2                	xor    %edx,%edx
  802009:	83 c4 20             	add    $0x20,%esp
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    
  802010:	39 f2                	cmp    %esi,%edx
  802012:	77 4c                	ja     802060 <__umoddi3+0x80>
  802014:	0f bd ca             	bsr    %edx,%ecx
  802017:	83 f1 1f             	xor    $0x1f,%ecx
  80201a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80201d:	75 51                	jne    802070 <__umoddi3+0x90>
  80201f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802022:	0f 87 e0 00 00 00    	ja     802108 <__umoddi3+0x128>
  802028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202b:	29 f8                	sub    %edi,%eax
  80202d:	19 d6                	sbb    %edx,%esi
  80202f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802032:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802035:	89 f2                	mov    %esi,%edx
  802037:	83 c4 20             	add    $0x20,%esp
  80203a:	5e                   	pop    %esi
  80203b:	5f                   	pop    %edi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    
  80203e:	66 90                	xchg   %ax,%ax
  802040:	85 ff                	test   %edi,%edi
  802042:	75 0b                	jne    80204f <__umoddi3+0x6f>
  802044:	b8 01 00 00 00       	mov    $0x1,%eax
  802049:	31 d2                	xor    %edx,%edx
  80204b:	f7 f7                	div    %edi
  80204d:	89 c7                	mov    %eax,%edi
  80204f:	89 f0                	mov    %esi,%eax
  802051:	31 d2                	xor    %edx,%edx
  802053:	f7 f7                	div    %edi
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	f7 f7                	div    %edi
  80205a:	eb a9                	jmp    802005 <__umoddi3+0x25>
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	83 c4 20             	add    $0x20,%esp
  802067:	5e                   	pop    %esi
  802068:	5f                   	pop    %edi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    
  80206b:	90                   	nop
  80206c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802070:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802074:	d3 e2                	shl    %cl,%edx
  802076:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802079:	ba 20 00 00 00       	mov    $0x20,%edx
  80207e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802081:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802084:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802088:	89 fa                	mov    %edi,%edx
  80208a:	d3 ea                	shr    %cl,%edx
  80208c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802090:	0b 55 f4             	or     -0xc(%ebp),%edx
  802093:	d3 e7                	shl    %cl,%edi
  802095:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802099:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80209c:	89 f2                	mov    %esi,%edx
  80209e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020a1:	89 c7                	mov    %eax,%edi
  8020a3:	d3 ea                	shr    %cl,%edx
  8020a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020ac:	89 c2                	mov    %eax,%edx
  8020ae:	d3 e6                	shl    %cl,%esi
  8020b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020b4:	d3 ea                	shr    %cl,%edx
  8020b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ba:	09 d6                	or     %edx,%esi
  8020bc:	89 f0                	mov    %esi,%eax
  8020be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8020c1:	d3 e7                	shl    %cl,%edi
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	f7 75 f4             	divl   -0xc(%ebp)
  8020c8:	89 d6                	mov    %edx,%esi
  8020ca:	f7 65 e8             	mull   -0x18(%ebp)
  8020cd:	39 d6                	cmp    %edx,%esi
  8020cf:	72 2b                	jb     8020fc <__umoddi3+0x11c>
  8020d1:	39 c7                	cmp    %eax,%edi
  8020d3:	72 23                	jb     8020f8 <__umoddi3+0x118>
  8020d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020d9:	29 c7                	sub    %eax,%edi
  8020db:	19 d6                	sbb    %edx,%esi
  8020dd:	89 f0                	mov    %esi,%eax
  8020df:	89 f2                	mov    %esi,%edx
  8020e1:	d3 ef                	shr    %cl,%edi
  8020e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020e7:	d3 e0                	shl    %cl,%eax
  8020e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ed:	09 f8                	or     %edi,%eax
  8020ef:	d3 ea                	shr    %cl,%edx
  8020f1:	83 c4 20             	add    $0x20,%esp
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	39 d6                	cmp    %edx,%esi
  8020fa:	75 d9                	jne    8020d5 <__umoddi3+0xf5>
  8020fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802102:	eb d1                	jmp    8020d5 <__umoddi3+0xf5>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	0f 82 18 ff ff ff    	jb     802028 <__umoddi3+0x48>
  802110:	e9 1d ff ff ff       	jmp    802032 <__umoddi3+0x52>
