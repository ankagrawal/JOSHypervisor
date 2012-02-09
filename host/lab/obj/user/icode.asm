
obj/user/icode:     file format elf32-i386


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
  80002c:	e8 6b 00 00 00       	call   80009c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003a:	c7 05 00 50 80 00 a0 	movl   $0x8023a0,0x805000
  800041:	23 80 00 
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
	close(fd);
*/
	cprintf("icode: spawn /vmmn\n");
  800044:	c7 04 24 a6 23 80 00 	movl   $0x8023a6,(%esp)
  80004b:	e8 95 01 00 00       	call   8001e5 <cprintf>
	if ((r = spawnl("/vmm", "heylo")) < 0)
  800050:	c7 44 24 04 ba 23 80 	movl   $0x8023ba,0x4(%esp)
  800057:	00 
  800058:	c7 04 24 c0 23 80 00 	movl   $0x8023c0,(%esp)
  80005f:	e8 dc 1f 00 00       	call   802040 <spawnl>
  800064:	85 c0                	test   %eax,%eax
  800066:	79 20                	jns    800088 <umain+0x54>
		panic("icode: spawn /vmm: %e", r);
  800068:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006c:	c7 44 24 08 c5 23 80 	movl   $0x8023c5,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80007b:	00 
  80007c:	c7 04 24 db 23 80 00 	movl   $0x8023db,(%esp)
  800083:	e8 98 00 00 00       	call   800120 <_panic>
/*
	cprintf("icode: spawn /kernel\n");
	if ((r = spawn_vmmn("/vmm")) < 0)
		panic("icode: spawn /kernel: %e", r);
*/
	cprintf("icode: exiting %x\n", r);
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 e8 23 80 00 	movl   $0x8023e8,(%esp)
  800093:	e8 4d 01 00 00       	call   8001e5 <cprintf>
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
  8000a2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8000ae:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  8000b5:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  8000b8:	e8 34 0f 00 00       	call   800ff1 <sys_getenvid>
  8000bd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ca:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cf:	85 f6                	test   %esi,%esi
  8000d1:	7e 07                	jle    8000da <libmain+0x3e>
		binaryname = argv[0];
  8000d3:	8b 03                	mov    (%ebx),%eax
  8000d5:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  8000da:	c7 04 24 fb 23 80 00 	movl   $0x8023fb,(%esp)
  8000e1:	e8 ff 00 00 00       	call   8001e5 <cprintf>
	umain(argc, argv);
  8000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ea:	89 34 24             	mov    %esi,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f2:	e8 0d 00 00 00       	call   800104 <exit>
}
  8000f7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000fa:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000fd:	89 ec                	mov    %ebp,%esp
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010a:	e8 5c 14 00 00       	call   80156b <close_all>
	sys_env_destroy(0);
  80010f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800116:	e8 0a 0f 00 00       	call   801025 <sys_env_destroy>
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    
  80011d:	00 00                	add    %al,(%eax)
	...

00800120 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80012a:	a1 28 50 80 00       	mov    0x805028,%eax
  80012f:	85 c0                	test   %eax,%eax
  800131:	74 10                	je     800143 <_panic+0x23>
		cprintf("%s: ", argv0);
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	c7 04 24 24 24 80 00 	movl   $0x802424,(%esp)
  80013e:	e8 a2 00 00 00       	call   8001e5 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800143:	8b 45 0c             	mov    0xc(%ebp),%eax
  800146:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014a:	8b 45 08             	mov    0x8(%ebp),%eax
  80014d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800151:	a1 00 50 80 00       	mov    0x805000,%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	c7 04 24 29 24 80 00 	movl   $0x802429,(%esp)
  800161:	e8 7f 00 00 00       	call   8001e5 <cprintf>
	vcprintf(fmt, ap);
  800166:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80016a:	8b 45 10             	mov    0x10(%ebp),%eax
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 0f 00 00 00       	call   800184 <vcprintf>
	cprintf("\n");
  800175:	c7 04 24 0b 24 80 00 	movl   $0x80240b,(%esp)
  80017c:	e8 64 00 00 00       	call   8001e5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800181:	cc                   	int3   
  800182:	eb fd                	jmp    800181 <_panic+0x61>

00800184 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80018d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800194:	00 00 00 
	b.cnt = 0;
  800197:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b9:	c7 04 24 ff 01 80 00 	movl   $0x8001ff,(%esp)
  8001c0:	e8 d8 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 e3 0a 00 00       	call   800cc0 <sys_cputs>

	return b.cnt;
}
  8001dd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001eb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	e8 87 ff ff ff       	call   800184 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 14             	sub    $0x14,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 03                	mov    (%ebx),%eax
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800212:	83 c0 01             	add    $0x1,%eax
  800215:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	75 19                	jne    800237 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800225:	00 
  800226:	8d 43 08             	lea    0x8(%ebx),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 8f 0a 00 00       	call   800cc0 <sys_cputs>
		b->idx = 0;
  800231:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800237:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    
	...

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 4c             	sub    $0x4c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d6                	mov    %edx,%esi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800264:	8b 55 0c             	mov    0xc(%ebp),%edx
  800267:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
  80026d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800270:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800273:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800276:	b9 00 00 00 00       	mov    $0x0,%ecx
  80027b:	39 d1                	cmp    %edx,%ecx
  80027d:	72 15                	jb     800294 <printnum+0x44>
  80027f:	77 07                	ja     800288 <printnum+0x38>
  800281:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800284:	39 d0                	cmp    %edx,%eax
  800286:	76 0c                	jbe    800294 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	8d 76 00             	lea    0x0(%esi),%esi
  800290:	7f 61                	jg     8002f3 <printnum+0xa3>
  800292:	eb 70                	jmp    800304 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002a7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bf:	00 
  8002c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	e8 4e 1e 00 00       	call   802120 <__udivdi3>
  8002d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e7:	89 f2                	mov    %esi,%edx
  8002e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ec:	e8 5f ff ff ff       	call   800250 <printnum>
  8002f1:	eb 11                	jmp    800304 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f7:	89 3c 24             	mov    %edi,(%esp)
  8002fa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fd:	83 eb 01             	sub    $0x1,%ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f ef                	jg     8002f3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 74 24 04          	mov    %esi,0x4(%esp)
  800308:	8b 74 24 04          	mov    0x4(%esp),%esi
  80030c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80031e:	89 14 24             	mov    %edx,(%esp)
  800321:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800324:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800328:	e8 23 1f 00 00       	call   802250 <__umoddi3>
  80032d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800331:	0f be 80 45 24 80 00 	movsbl 0x802445(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 4c             	add    $0x4c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800386:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	3b 50 04             	cmp    0x4(%eax),%edx
  80038f:	73 0a                	jae    80039b <sprintputch+0x1b>
		*b->buf++ = ch;
  800391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800394:	88 0a                	mov    %cl,(%edx)
  800396:	83 c2 01             	add    $0x1,%edx
  800399:	89 10                	mov    %edx,(%eax)
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 5c             	sub    $0x5c,%esp
  8003a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003b6:	eb 11                	jmp    8003c9 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 02 04 00 00    	je     8007c2 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 03             	movzbl (%ebx),%eax
  8003cc:	83 c3 01             	add    $0x1,%ebx
  8003cf:	83 f8 25             	cmp    $0x25,%eax
  8003d2:	75 e4                	jne    8003b8 <vprintfmt+0x1b>
  8003d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	eb 06                	jmp    8003fa <vprintfmt+0x5d>
  8003f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003f8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	0f b6 13             	movzbl (%ebx),%edx
  8003fd:	0f b6 c2             	movzbl %dl,%eax
  800400:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800403:	8d 43 01             	lea    0x1(%ebx),%eax
  800406:	83 ea 23             	sub    $0x23,%edx
  800409:	80 fa 55             	cmp    $0x55,%dl
  80040c:	0f 87 93 03 00 00    	ja     8007a5 <vprintfmt+0x408>
  800412:	0f b6 d2             	movzbl %dl,%edx
  800415:	ff 24 95 80 25 80 00 	jmp    *0x802580(,%edx,4)
  80041c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800420:	eb d6                	jmp    8003f8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800422:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800425:	83 ea 30             	sub    $0x30,%edx
  800428:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80042b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80042e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800431:	83 fb 09             	cmp    $0x9,%ebx
  800434:	77 4c                	ja     800482 <vprintfmt+0xe5>
  800436:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800439:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80043f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800442:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800446:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800449:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80044c:	83 fb 09             	cmp    $0x9,%ebx
  80044f:	76 eb                	jbe    80043c <vprintfmt+0x9f>
  800451:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800454:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800457:	eb 29                	jmp    800482 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800459:	8b 55 14             	mov    0x14(%ebp),%edx
  80045c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80045f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800462:	8b 12                	mov    (%edx),%edx
  800464:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  800467:	eb 19                	jmp    800482 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800469:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80046c:	c1 fa 1f             	sar    $0x1f,%edx
  80046f:	f7 d2                	not    %edx
  800471:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800474:	eb 82                	jmp    8003f8 <vprintfmt+0x5b>
  800476:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80047d:	e9 76 ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800482:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800486:	0f 89 6c ff ff ff    	jns    8003f8 <vprintfmt+0x5b>
  80048c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800492:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800495:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800498:	e9 5b ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004a0:	e9 53 ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>
  8004a5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 04 24             	mov    %eax,(%esp)
  8004ba:	ff d7                	call   *%edi
  8004bc:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004bf:	e9 05 ff ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  8004c4:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	89 c2                	mov    %eax,%edx
  8004d4:	c1 fa 1f             	sar    $0x1f,%edx
  8004d7:	31 d0                	xor    %edx,%eax
  8004d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004db:	83 f8 0f             	cmp    $0xf,%eax
  8004de:	7f 0b                	jg     8004eb <vprintfmt+0x14e>
  8004e0:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	75 20                	jne    80050b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  8004eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ef:	c7 44 24 08 56 24 80 	movl   $0x802456,0x8(%esp)
  8004f6:	00 
  8004f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fb:	89 3c 24             	mov    %edi,(%esp)
  8004fe:	e8 47 03 00 00       	call   80084a <printfmt>
  800503:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800506:	e9 be fe ff ff       	jmp    8003c9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80050b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80050f:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  800516:	00 
  800517:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051b:	89 3c 24             	mov    %edi,(%esp)
  80051e:	e8 27 03 00 00       	call   80084a <printfmt>
  800523:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800526:	e9 9e fe ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  80052b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80052e:	89 c3                	mov    %eax,%ebx
  800530:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800536:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800547:	85 c0                	test   %eax,%eax
  800549:	75 07                	jne    800552 <vprintfmt+0x1b5>
  80054b:	c7 45 e0 5f 24 80 00 	movl   $0x80245f,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800552:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800556:	7e 06                	jle    80055e <vprintfmt+0x1c1>
  800558:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055c:	75 13                	jne    800571 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800561:	0f be 02             	movsbl (%edx),%eax
  800564:	85 c0                	test   %eax,%eax
  800566:	0f 85 99 00 00 00    	jne    800605 <vprintfmt+0x268>
  80056c:	e9 86 00 00 00       	jmp    8005f7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800571:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800575:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800578:	89 0c 24             	mov    %ecx,(%esp)
  80057b:	e8 1b 03 00 00       	call   80089b <strnlen>
  800580:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800583:	29 c2                	sub    %eax,%edx
  800585:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800588:	85 d2                	test   %edx,%edx
  80058a:	7e d2                	jle    80055e <vprintfmt+0x1c1>
					putch(padc, putdat);
  80058c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800590:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800593:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800596:	89 d3                	mov    %edx,%ebx
  800598:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a4:	83 eb 01             	sub    $0x1,%ebx
  8005a7:	85 db                	test   %ebx,%ebx
  8005a9:	7f ed                	jg     800598 <vprintfmt+0x1fb>
  8005ab:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005b5:	eb a7                	jmp    80055e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bb:	74 18                	je     8005d5 <vprintfmt+0x238>
  8005bd:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c0:	83 fa 5e             	cmp    $0x5e,%edx
  8005c3:	76 10                	jbe    8005d5 <vprintfmt+0x238>
					putch('?', putdat);
  8005c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d3:	eb 0a                	jmp    8005df <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d9:	89 04 24             	mov    %eax,(%esp)
  8005dc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005df:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005e3:	0f be 03             	movsbl (%ebx),%eax
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	74 05                	je     8005ef <vprintfmt+0x252>
  8005ea:	83 c3 01             	add    $0x1,%ebx
  8005ed:	eb 29                	jmp    800618 <vprintfmt+0x27b>
  8005ef:	89 fe                	mov    %edi,%esi
  8005f1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fb:	7f 2e                	jg     80062b <vprintfmt+0x28e>
  8005fd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800600:	e9 c4 fd ff ff       	jmp    8003c9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800605:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800608:	83 c2 01             	add    $0x1,%edx
  80060b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80060e:	89 f7                	mov    %esi,%edi
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800616:	89 d3                	mov    %edx,%ebx
  800618:	85 f6                	test   %esi,%esi
  80061a:	78 9b                	js     8005b7 <vprintfmt+0x21a>
  80061c:	83 ee 01             	sub    $0x1,%esi
  80061f:	79 96                	jns    8005b7 <vprintfmt+0x21a>
  800621:	89 fe                	mov    %edi,%esi
  800623:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800626:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800629:	eb cc                	jmp    8005f7 <vprintfmt+0x25a>
  80062b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80062e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800631:	89 74 24 04          	mov    %esi,0x4(%esp)
  800635:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80063c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063e:	83 eb 01             	sub    $0x1,%ebx
  800641:	85 db                	test   %ebx,%ebx
  800643:	7f ec                	jg     800631 <vprintfmt+0x294>
  800645:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800648:	e9 7c fd ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  80064d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800650:	83 f9 01             	cmp    $0x1,%ecx
  800653:	7e 16                	jle    80066b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 08             	lea    0x8(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	8b 48 04             	mov    0x4(%eax),%ecx
  800663:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800666:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800669:	eb 32                	jmp    80069d <vprintfmt+0x300>
	else if (lflag)
  80066b:	85 c9                	test   %ecx,%ecx
  80066d:	74 18                	je     800687 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067d:	89 c1                	mov    %eax,%ecx
  80067f:	c1 f9 1f             	sar    $0x1f,%ecx
  800682:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800685:	eb 16                	jmp    80069d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 00                	mov    (%eax),%eax
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	89 c2                	mov    %eax,%edx
  800697:	c1 fa 1f             	sar    $0x1f,%edx
  80069a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006a3:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ac:	0f 89 b1 00 00 00    	jns    800763 <vprintfmt+0x3c6>
				putch('-', putdat);
  8006b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bd:	ff d7                	call   *%edi
				num = -(long long) num;
  8006bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006c5:	f7 d8                	neg    %eax
  8006c7:	83 d2 00             	adc    $0x0,%edx
  8006ca:	f7 da                	neg    %edx
  8006cc:	e9 92 00 00 00       	jmp    800763 <vprintfmt+0x3c6>
  8006d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d4:	89 ca                	mov    %ecx,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 68 fc ff ff       	call   800346 <getuint>
  8006de:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8006e3:	eb 7e                	jmp    800763 <vprintfmt+0x3c6>
  8006e5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006e8:	89 ca                	mov    %ecx,%edx
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 54 fc ff ff       	call   800346 <getuint>
			if ((long long) num < 0) {
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	79 62                	jns    800763 <vprintfmt+0x3c6>
				putch('-', putdat);
  800701:	89 74 24 04          	mov    %esi,0x4(%esp)
  800705:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070c:	ff d7                	call   *%edi
				num = -(long long) num;
  80070e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800711:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800714:	f7 d8                	neg    %eax
  800716:	83 d2 00             	adc    $0x0,%edx
  800719:	f7 da                	neg    %edx
  80071b:	eb 46                	jmp    800763 <vprintfmt+0x3c6>
  80071d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800720:	89 74 24 04          	mov    %esi,0x4(%esp)
  800724:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072b:	ff d7                	call   *%edi
			putch('x', putdat);
  80072d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800731:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800738:	ff d7                	call   *%edi
			num = (unsigned long long)
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8d 50 04             	lea    0x4(%eax),%edx
  800740:	89 55 14             	mov    %edx,0x14(%ebp)
  800743:	8b 00                	mov    (%eax),%eax
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074f:	eb 12                	jmp    800763 <vprintfmt+0x3c6>
  800751:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800754:	89 ca                	mov    %ecx,%edx
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 e8 fb ff ff       	call   800346 <getuint>
  80075e:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800763:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800767:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80076b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80076e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800772:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800776:	89 04 24             	mov    %eax,(%esp)
  800779:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077d:	89 f2                	mov    %esi,%edx
  80077f:	89 f8                	mov    %edi,%eax
  800781:	e8 ca fa ff ff       	call   800250 <printnum>
  800786:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800789:	e9 3b fc ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  80078e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800791:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800794:	89 74 24 04          	mov    %esi,0x4(%esp)
  800798:	89 14 24             	mov    %edx,(%esp)
  80079b:	ff d7                	call   *%edi
  80079d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007a0:	e9 24 fc ff ff       	jmp    8003c9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007b5:	80 38 25             	cmpb   $0x25,(%eax)
  8007b8:	0f 84 0b fc ff ff    	je     8003c9 <vprintfmt+0x2c>
  8007be:	89 c3                	mov    %eax,%ebx
  8007c0:	eb f0                	jmp    8007b2 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  8007c2:	83 c4 5c             	add    $0x5c,%esp
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5f                   	pop    %edi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 28             	sub    $0x28,%esp
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	74 04                	je     8007de <vsnprintf+0x14>
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	7f 07                	jg     8007e5 <vsnprintf+0x1b>
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e3:	eb 3b                	jmp    800820 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 44 24 08          	mov    %eax,0x8(%esp)
  800804:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	c7 04 24 80 03 80 00 	movl   $0x800380,(%esp)
  800812:	e8 86 fb ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800828:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80082b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082f:	8b 45 10             	mov    0x10(%ebp),%eax
  800832:	89 44 24 08          	mov    %eax,0x8(%esp)
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	e8 82 ff ff ff       	call   8007ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800850:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800853:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800857:	8b 45 10             	mov    0x10(%ebp),%eax
  80085a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800861:	89 44 24 04          	mov    %eax,0x4(%esp)
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	89 04 24             	mov    %eax,(%esp)
  80086b:	e8 2d fb ff ff       	call   80039d <vprintfmt>
	va_end(ap);
}
  800870:	c9                   	leave  
  800871:	c3                   	ret    
	...

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	80 3a 00             	cmpb   $0x0,(%edx)
  80088e:	74 09                	je     800899 <strlen+0x19>
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
		n++;
	return n;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a5:	85 c9                	test   %ecx,%ecx
  8008a7:	74 19                	je     8008c2 <strnlen+0x27>
  8008a9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008ac:	74 14                	je     8008c2 <strnlen+0x27>
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008b3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b6:	39 c8                	cmp    %ecx,%eax
  8008b8:	74 0d                	je     8008c7 <strnlen+0x2c>
  8008ba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008be:	75 f3                	jne    8008b3 <strnlen+0x18>
  8008c0:	eb 05                	jmp    8008c7 <strnlen+0x2c>
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	75 f2                	jne    8008d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f8:	85 f6                	test   %esi,%esi
  8008fa:	74 18                	je     800914 <strncpy+0x2a>
  8008fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800901:	0f b6 1a             	movzbl (%edx),%ebx
  800904:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800907:	80 3a 01             	cmpb   $0x1,(%edx)
  80090a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090d:	83 c1 01             	add    $0x1,%ecx
  800910:	39 ce                	cmp    %ecx,%esi
  800912:	77 ed                	ja     800901 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 75 08             	mov    0x8(%ebp),%esi
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800926:	89 f0                	mov    %esi,%eax
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 27                	je     800953 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80092c:	83 e9 01             	sub    $0x1,%ecx
  80092f:	74 1d                	je     80094e <strlcpy+0x36>
  800931:	0f b6 1a             	movzbl (%edx),%ebx
  800934:	84 db                	test   %bl,%bl
  800936:	74 16                	je     80094e <strlcpy+0x36>
			*dst++ = *src++;
  800938:	88 18                	mov    %bl,(%eax)
  80093a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80093d:	83 e9 01             	sub    $0x1,%ecx
  800940:	74 0e                	je     800950 <strlcpy+0x38>
			*dst++ = *src++;
  800942:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800945:	0f b6 1a             	movzbl (%edx),%ebx
  800948:	84 db                	test   %bl,%bl
  80094a:	75 ec                	jne    800938 <strlcpy+0x20>
  80094c:	eb 02                	jmp    800950 <strlcpy+0x38>
  80094e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800950:	c6 00 00             	movb   $0x0,(%eax)
  800953:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	0f b6 01             	movzbl (%ecx),%eax
  800965:	84 c0                	test   %al,%al
  800967:	74 15                	je     80097e <strcmp+0x25>
  800969:	3a 02                	cmp    (%edx),%al
  80096b:	75 11                	jne    80097e <strcmp+0x25>
		p++, q++;
  80096d:	83 c1 01             	add    $0x1,%ecx
  800970:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800973:	0f b6 01             	movzbl (%ecx),%eax
  800976:	84 c0                	test   %al,%al
  800978:	74 04                	je     80097e <strcmp+0x25>
  80097a:	3a 02                	cmp    (%edx),%al
  80097c:	74 ef                	je     80096d <strcmp+0x14>
  80097e:	0f b6 c0             	movzbl %al,%eax
  800981:	0f b6 12             	movzbl (%edx),%edx
  800984:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	8b 55 08             	mov    0x8(%ebp),%edx
  80098f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800992:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800995:	85 c0                	test   %eax,%eax
  800997:	74 23                	je     8009bc <strncmp+0x34>
  800999:	0f b6 1a             	movzbl (%edx),%ebx
  80099c:	84 db                	test   %bl,%bl
  80099e:	74 24                	je     8009c4 <strncmp+0x3c>
  8009a0:	3a 19                	cmp    (%ecx),%bl
  8009a2:	75 20                	jne    8009c4 <strncmp+0x3c>
  8009a4:	83 e8 01             	sub    $0x1,%eax
  8009a7:	74 13                	je     8009bc <strncmp+0x34>
		n--, p++, q++;
  8009a9:	83 c2 01             	add    $0x1,%edx
  8009ac:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009af:	0f b6 1a             	movzbl (%edx),%ebx
  8009b2:	84 db                	test   %bl,%bl
  8009b4:	74 0e                	je     8009c4 <strncmp+0x3c>
  8009b6:	3a 19                	cmp    (%ecx),%bl
  8009b8:	74 ea                	je     8009a4 <strncmp+0x1c>
  8009ba:	eb 08                	jmp    8009c4 <strncmp+0x3c>
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c4:	0f b6 02             	movzbl (%edx),%eax
  8009c7:	0f b6 11             	movzbl (%ecx),%edx
  8009ca:	29 d0                	sub    %edx,%eax
  8009cc:	eb f3                	jmp    8009c1 <strncmp+0x39>

008009ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	74 15                	je     8009f4 <strchr+0x26>
		if (*s == c)
  8009df:	38 ca                	cmp    %cl,%dl
  8009e1:	75 07                	jne    8009ea <strchr+0x1c>
  8009e3:	eb 14                	jmp    8009f9 <strchr+0x2b>
  8009e5:	38 ca                	cmp    %cl,%dl
  8009e7:	90                   	nop
  8009e8:	74 0f                	je     8009f9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f1                	jne    8009e5 <strchr+0x17>
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	74 18                	je     800a24 <strfind+0x29>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	75 0a                	jne    800a1a <strfind+0x1f>
  800a10:	eb 12                	jmp    800a24 <strfind+0x29>
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a18:	74 0a                	je     800a24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 ee                	jne    800a12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	89 1c 24             	mov    %ebx,(%esp)
  800a2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a40:	85 c9                	test   %ecx,%ecx
  800a42:	74 30                	je     800a74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4a:	75 25                	jne    800a71 <memset+0x4b>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 20                	jne    800a71 <memset+0x4b>
		c &= 0xFF;
  800a51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a54:	89 d3                	mov    %edx,%ebx
  800a56:	c1 e3 08             	shl    $0x8,%ebx
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	c1 e6 18             	shl    $0x18,%esi
  800a5e:	89 d0                	mov    %edx,%eax
  800a60:	c1 e0 10             	shl    $0x10,%eax
  800a63:	09 f0                	or     %esi,%eax
  800a65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a67:	09 d8                	or     %ebx,%eax
  800a69:	c1 e9 02             	shr    $0x2,%ecx
  800a6c:	fc                   	cld    
  800a6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6f:	eb 03                	jmp    800a74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a71:	fc                   	cld    
  800a72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a74:	89 f8                	mov    %edi,%eax
  800a76:	8b 1c 24             	mov    (%esp),%ebx
  800a79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a81:	89 ec                	mov    %ebp,%esp
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	89 34 24             	mov    %esi,(%esp)
  800a8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a9d:	39 c6                	cmp    %eax,%esi
  800a9f:	73 35                	jae    800ad6 <memmove+0x51>
  800aa1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 2e                	jae    800ad6 <memmove+0x51>
		s += n;
		d += n;
  800aa8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	f6 c2 03             	test   $0x3,%dl
  800aad:	75 1b                	jne    800aca <memmove+0x45>
  800aaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab5:	75 13                	jne    800aca <memmove+0x45>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 0e                	jne    800aca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800abc:	83 ef 04             	sub    $0x4,%edi
  800abf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	fd                   	std    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac8:	eb 09                	jmp    800ad3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad0:	fd                   	std    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad4:	eb 20                	jmp    800af6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adc:	75 15                	jne    800af3 <memmove+0x6e>
  800ade:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae4:	75 0d                	jne    800af3 <memmove+0x6e>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 08                	jne    800af3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
  800aee:	fc                   	cld    
  800aef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	eb 03                	jmp    800af6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af3:	fc                   	cld    
  800af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af6:	8b 34 24             	mov    (%esp),%esi
  800af9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800afd:	89 ec                	mov    %ebp,%esp
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b07:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	89 04 24             	mov    %eax,(%esp)
  800b1b:	e8 65 ff ff ff       	call   800a85 <memmove>
}
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	74 36                	je     800b6b <memcmp+0x49>
		if (*s1 != *s2)
  800b35:	0f b6 06             	movzbl (%esi),%eax
  800b38:	0f b6 1f             	movzbl (%edi),%ebx
  800b3b:	38 d8                	cmp    %bl,%al
  800b3d:	74 20                	je     800b5f <memcmp+0x3d>
  800b3f:	eb 14                	jmp    800b55 <memcmp+0x33>
  800b41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	83 e9 01             	sub    $0x1,%ecx
  800b51:	38 d8                	cmp    %bl,%al
  800b53:	74 12                	je     800b67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 11                	jmp    800b70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	83 e9 01             	sub    $0x1,%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	85 c9                	test   %ecx,%ecx
  800b69:	75 d6                	jne    800b41 <memcmp+0x1f>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b80:	39 d0                	cmp    %edx,%eax
  800b82:	73 15                	jae    800b99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b88:	38 08                	cmp    %cl,(%eax)
  800b8a:	75 06                	jne    800b92 <memfind+0x1d>
  800b8c:	eb 0b                	jmp    800b99 <memfind+0x24>
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	74 07                	je     800b99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	39 c2                	cmp    %eax,%edx
  800b97:	77 f5                	ja     800b8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 04             	sub    $0x4,%esp
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 02             	movzbl (%edx),%eax
  800bad:	3c 20                	cmp    $0x20,%al
  800baf:	74 04                	je     800bb5 <strtol+0x1a>
  800bb1:	3c 09                	cmp    $0x9,%al
  800bb3:	75 0e                	jne    800bc3 <strtol+0x28>
		s++;
  800bb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	0f b6 02             	movzbl (%edx),%eax
  800bbb:	3c 20                	cmp    $0x20,%al
  800bbd:	74 f6                	je     800bb5 <strtol+0x1a>
  800bbf:	3c 09                	cmp    $0x9,%al
  800bc1:	74 f2                	je     800bb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc3:	3c 2b                	cmp    $0x2b,%al
  800bc5:	75 0c                	jne    800bd3 <strtol+0x38>
		s++;
  800bc7:	83 c2 01             	add    $0x1,%edx
  800bca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bd1:	eb 15                	jmp    800be8 <strtol+0x4d>
	else if (*s == '-')
  800bd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bda:	3c 2d                	cmp    $0x2d,%al
  800bdc:	75 0a                	jne    800be8 <strtol+0x4d>
		s++, neg = 1;
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	0f 94 c0             	sete   %al
  800bed:	74 05                	je     800bf4 <strtol+0x59>
  800bef:	83 fb 10             	cmp    $0x10,%ebx
  800bf2:	75 18                	jne    800c0c <strtol+0x71>
  800bf4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf7:	75 13                	jne    800c0c <strtol+0x71>
  800bf9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfd:	8d 76 00             	lea    0x0(%esi),%esi
  800c00:	75 0a                	jne    800c0c <strtol+0x71>
		s += 2, base = 16;
  800c02:	83 c2 02             	add    $0x2,%edx
  800c05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0a:	eb 15                	jmp    800c21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0c:	84 c0                	test   %al,%al
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	74 0f                	je     800c21 <strtol+0x86>
  800c12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c17:	80 3a 30             	cmpb   $0x30,(%edx)
  800c1a:	75 05                	jne    800c21 <strtol+0x86>
		s++, base = 8;
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 0a             	movzbl (%edx),%ecx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 08                	ja     800c3d <strtol+0xa2>
			dig = *s - '0';
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 30             	sub    $0x30,%ecx
  800c3b:	eb 1e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c40:	80 fb 19             	cmp    $0x19,%bl
  800c43:	77 08                	ja     800c4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c45:	0f be c9             	movsbl %cl,%ecx
  800c48:	83 e9 57             	sub    $0x57,%ecx
  800c4b:	eb 0e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c50:	80 fb 19             	cmp    $0x19,%bl
  800c53:	77 15                	ja     800c6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5b:	39 f1                	cmp    %esi,%ecx
  800c5d:	7d 0b                	jge    800c6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c5f:	83 c2 01             	add    $0x1,%edx
  800c62:	0f af c6             	imul   %esi,%eax
  800c65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c68:	eb be                	jmp    800c28 <strtol+0x8d>
  800c6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c70:	74 05                	je     800c77 <strtol+0xdc>
		*endptr = (char *) s;
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c7b:	74 04                	je     800c81 <strtol+0xe6>
  800c7d:	89 c8                	mov    %ecx,%eax
  800c7f:	f7 d8                	neg    %eax
}
  800c81:	83 c4 04             	add    $0x4,%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    
  800c89:	00 00                	add    %al,(%eax)
	...

00800c8c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	89 1c 24             	mov    %ebx,(%esp)
  800c95:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c99:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	89 d3                	mov    %edx,%ebx
  800cab:	89 d7                	mov    %edx,%edi
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb1:	8b 1c 24             	mov    (%esp),%ebx
  800cb4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cb8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cbc:	89 ec                	mov    %ebp,%esp
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	89 1c 24             	mov    %ebx,(%esp)
  800cc9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ccd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 c3                	mov    %eax,%ebx
  800cde:	89 c7                	mov    %eax,%edi
  800ce0:	89 c6                	mov    %eax,%esi
  800ce2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce4:	8b 1c 24             	mov    (%esp),%ebx
  800ce7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ceb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cef:	89 ec                	mov    %ebp,%esp
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 38             	sub    $0x38,%esp
  800cf9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cfc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 28                	jle    800d43 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d26:	00 
  800d27:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d36:	00 
  800d37:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800d3e:	e8 dd f3 ff ff       	call   800120 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4c:	89 ec                	mov    %ebp,%esp
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	89 1c 24             	mov    %ebx,(%esp)
  800d59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d79:	8b 1c 24             	mov    (%esp),%ebx
  800d7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d80:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d84:	89 ec                	mov    %ebp,%esp
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 38             	sub    $0x38,%esp
  800d8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d94:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 28                	jle    800dd9 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db5:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800dc4:	00 
  800dc5:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800dcc:	00 
  800dcd:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800dd4:	e8 47 f3 ff ff       	call   800120 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ddc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ddf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de2:	89 ec                	mov    %ebp,%esp
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	83 ec 38             	sub    $0x38,%esp
  800dec:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800def:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 28                	jle    800e37 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e13:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e22:	00 
  800e23:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e2a:	00 
  800e2b:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e32:	e8 e9 f2 ff ff       	call   800120 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e40:	89 ec                	mov    %ebp,%esp
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 38             	sub    $0x38,%esp
  800e4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e50:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7e 28                	jle    800e95 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e71:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e78:	00 
  800e79:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e80:	00 
  800e81:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e88:	00 
  800e89:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e90:	e8 8b f2 ff ff       	call   800120 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e95:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e98:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9e:	89 ec                	mov    %ebp,%esp
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 38             	sub    $0x38,%esp
  800ea8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eae:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	89 df                	mov    %ebx,%edi
  800ec3:	89 de                	mov    %ebx,%esi
  800ec5:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 28                	jle    800ef3 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800eee:	e8 2d f2 ff ff       	call   800120 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ef3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800efc:	89 ec                	mov    %ebp,%esp
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 38             	sub    $0x38,%esp
  800f06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f14:	8b 75 18             	mov    0x18(%ebp),%esi
  800f17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f25:	85 c0                	test   %eax,%eax
  800f27:	7e 28                	jle    800f51 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f34:	00 
  800f35:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f44:	00 
  800f45:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800f4c:	e8 cf f1 ff ff       	call   800120 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f51:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f54:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f57:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5a:	89 ec                	mov    %ebp,%esp
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 38             	sub    $0x38,%esp
  800f64:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f67:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6d:	be 00 00 00 00       	mov    $0x0,%esi
  800f72:	b8 04 00 00 00       	mov    $0x4,%eax
  800f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f80:	89 f7                	mov    %esi,%edi
  800f82:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f84:	85 c0                	test   %eax,%eax
  800f86:	7e 28                	jle    800fb0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f93:	00 
  800f94:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fa3:	00 
  800fa4:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800fab:	e8 70 f1 ff ff       	call   800120 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fb0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb9:	89 ec                	mov    %ebp,%esp
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	89 1c 24             	mov    %ebx,(%esp)
  800fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fca:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fd8:	89 d1                	mov    %edx,%ecx
  800fda:	89 d3                	mov    %edx,%ebx
  800fdc:	89 d7                	mov    %edx,%edi
  800fde:	89 d6                	mov    %edx,%esi
  800fe0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fe2:	8b 1c 24             	mov    (%esp),%ebx
  800fe5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fe9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fed:	89 ec                	mov    %ebp,%esp
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	89 1c 24             	mov    %ebx,(%esp)
  800ffa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ffe:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801002:	ba 00 00 00 00       	mov    $0x0,%edx
  801007:	b8 02 00 00 00       	mov    $0x2,%eax
  80100c:	89 d1                	mov    %edx,%ecx
  80100e:	89 d3                	mov    %edx,%ebx
  801010:	89 d7                	mov    %edx,%edi
  801012:	89 d6                	mov    %edx,%esi
  801014:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801016:	8b 1c 24             	mov    (%esp),%ebx
  801019:	8b 74 24 04          	mov    0x4(%esp),%esi
  80101d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801021:	89 ec                	mov    %ebp,%esp
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 38             	sub    $0x38,%esp
  80102b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801031:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801034:	b9 00 00 00 00       	mov    $0x0,%ecx
  801039:	b8 03 00 00 00       	mov    $0x3,%eax
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 cb                	mov    %ecx,%ebx
  801043:	89 cf                	mov    %ecx,%edi
  801045:	89 ce                	mov    %ecx,%esi
  801047:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	7e 28                	jle    801075 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801051:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801058:	00 
  801059:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  801070:	e8 ab f0 ff ff       	call   800120 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801075:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801078:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107e:	89 ec                	mov    %ebp,%esp
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    
	...

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 df ff ff ff       	call   801090 <fd2num>
  8010b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8010c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010c9:	a8 01                	test   $0x1,%al
  8010cb:	74 36                	je     801103 <fd_alloc+0x48>
  8010cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010d2:	a8 01                	test   $0x1,%al
  8010d4:	74 2d                	je     801103 <fd_alloc+0x48>
  8010d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8010e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	c1 ea 16             	shr    $0x16,%edx
  8010ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8010ef:	f6 c2 01             	test   $0x1,%dl
  8010f2:	74 14                	je     801108 <fd_alloc+0x4d>
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	c1 ea 0c             	shr    $0xc,%edx
  8010f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8010fc:	f6 c2 01             	test   $0x1,%dl
  8010ff:	75 10                	jne    801111 <fd_alloc+0x56>
  801101:	eb 05                	jmp    801108 <fd_alloc+0x4d>
  801103:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801108:	89 1f                	mov    %ebx,(%edi)
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80110f:	eb 17                	jmp    801128 <fd_alloc+0x6d>
  801111:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801116:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111b:	75 c8                	jne    8010e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801123:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	83 f8 1f             	cmp    $0x1f,%eax
  801136:	77 36                	ja     80116e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801138:	05 00 00 0d 00       	add    $0xd0000,%eax
  80113d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801140:	89 c2                	mov    %eax,%edx
  801142:	c1 ea 16             	shr    $0x16,%edx
  801145:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114c:	f6 c2 01             	test   $0x1,%dl
  80114f:	74 1d                	je     80116e <fd_lookup+0x41>
  801151:	89 c2                	mov    %eax,%edx
  801153:	c1 ea 0c             	shr    $0xc,%edx
  801156:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115d:	f6 c2 01             	test   $0x1,%dl
  801160:	74 0c                	je     80116e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801162:	8b 55 0c             	mov    0xc(%ebp),%edx
  801165:	89 02                	mov    %eax,(%edx)
  801167:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80116c:	eb 05                	jmp    801173 <fd_lookup+0x46>
  80116e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 a0 ff ff ff       	call   80112d <fd_lookup>
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 0e                	js     80119f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801191:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801194:	8b 55 0c             	mov    0xc(%ebp),%edx
  801197:	89 50 04             	mov    %edx,0x4(%eax)
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    

008011a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 10             	sub    $0x10,%esp
  8011a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8011af:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8011b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b9:	be e8 27 80 00       	mov    $0x8027e8,%esi
		if (devtab[i]->dev_id == dev_id) {
  8011be:	39 08                	cmp    %ecx,(%eax)
  8011c0:	75 10                	jne    8011d2 <dev_lookup+0x31>
  8011c2:	eb 04                	jmp    8011c8 <dev_lookup+0x27>
  8011c4:	39 08                	cmp    %ecx,(%eax)
  8011c6:	75 0a                	jne    8011d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8011c8:	89 03                	mov    %eax,(%ebx)
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011cf:	90                   	nop
  8011d0:	eb 31                	jmp    801203 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d2:	83 c2 01             	add    $0x1,%edx
  8011d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	75 e8                	jne    8011c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8011dc:	a1 24 50 80 00       	mov    0x805024,%eax
  8011e1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8011e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ec:	c7 04 24 6c 27 80 00 	movl   $0x80276c,(%esp)
  8011f3:	e8 ed ef ff ff       	call   8001e5 <cprintf>
	*dev = 0;
  8011f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 24             	sub    $0x24,%esp
  801211:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801214:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	89 04 24             	mov    %eax,(%esp)
  801221:	e8 07 ff ff ff       	call   80112d <fd_lookup>
  801226:	85 c0                	test   %eax,%eax
  801228:	78 53                	js     80127d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801231:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801234:	8b 00                	mov    (%eax),%eax
  801236:	89 04 24             	mov    %eax,(%esp)
  801239:	e8 63 ff ff ff       	call   8011a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 3b                	js     80127d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801242:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801247:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80124e:	74 2d                	je     80127d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801250:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801253:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80125a:	00 00 00 
	stat->st_isdir = 0;
  80125d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801264:	00 00 00 
	stat->st_dev = dev;
  801267:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801270:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801274:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801277:	89 14 24             	mov    %edx,(%esp)
  80127a:	ff 50 14             	call   *0x14(%eax)
}
  80127d:	83 c4 24             	add    $0x24,%esp
  801280:	5b                   	pop    %ebx
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 24             	sub    $0x24,%esp
  80128a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801290:	89 44 24 04          	mov    %eax,0x4(%esp)
  801294:	89 1c 24             	mov    %ebx,(%esp)
  801297:	e8 91 fe ff ff       	call   80112d <fd_lookup>
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 5f                	js     8012ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012aa:	8b 00                	mov    (%eax),%eax
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	e8 ed fe ff ff       	call   8011a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 47                	js     8012ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012bb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012bf:	75 23                	jne    8012e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  8012c1:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  8012d8:	e8 08 ef ff ff       	call   8001e5 <cprintf>
  8012dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  8012e2:	eb 1b                	jmp    8012ff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8012e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e7:	8b 48 18             	mov    0x18(%eax),%ecx
  8012ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ef:	85 c9                	test   %ecx,%ecx
  8012f1:	74 0c                	je     8012ff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	89 14 24             	mov    %edx,(%esp)
  8012fd:	ff d1                	call   *%ecx
}
  8012ff:	83 c4 24             	add    $0x24,%esp
  801302:	5b                   	pop    %ebx
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	53                   	push   %ebx
  801309:	83 ec 24             	sub    $0x24,%esp
  80130c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801312:	89 44 24 04          	mov    %eax,0x4(%esp)
  801316:	89 1c 24             	mov    %ebx,(%esp)
  801319:	e8 0f fe ff ff       	call   80112d <fd_lookup>
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 66                	js     801388 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	89 44 24 04          	mov    %eax,0x4(%esp)
  801329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132c:	8b 00                	mov    (%eax),%eax
  80132e:	89 04 24             	mov    %eax,(%esp)
  801331:	e8 6b fe ff ff       	call   8011a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801336:	85 c0                	test   %eax,%eax
  801338:	78 4e                	js     801388 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80133d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801341:	75 23                	jne    801366 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801343:	a1 24 50 80 00       	mov    0x805024,%eax
  801348:	8b 40 4c             	mov    0x4c(%eax),%eax
  80134b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80134f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801353:	c7 04 24 ad 27 80 00 	movl   $0x8027ad,(%esp)
  80135a:	e8 86 ee ff ff       	call   8001e5 <cprintf>
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801364:	eb 22                	jmp    801388 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	8b 48 0c             	mov    0xc(%eax),%ecx
  80136c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801371:	85 c9                	test   %ecx,%ecx
  801373:	74 13                	je     801388 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801375:	8b 45 10             	mov    0x10(%ebp),%eax
  801378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801383:	89 14 24             	mov    %edx,(%esp)
  801386:	ff d1                	call   *%ecx
}
  801388:	83 c4 24             	add    $0x24,%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 24             	sub    $0x24,%esp
  801395:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801398:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	89 1c 24             	mov    %ebx,(%esp)
  8013a2:	e8 86 fd ff ff       	call   80112d <fd_lookup>
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 6b                	js     801416 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	8b 00                	mov    (%eax),%eax
  8013b7:	89 04 24             	mov    %eax,(%esp)
  8013ba:	e8 e2 fd ff ff       	call   8011a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 53                	js     801416 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c6:	8b 42 08             	mov    0x8(%edx),%eax
  8013c9:	83 e0 03             	and    $0x3,%eax
  8013cc:	83 f8 01             	cmp    $0x1,%eax
  8013cf:	75 23                	jne    8013f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8013d1:	a1 24 50 80 00       	mov    0x805024,%eax
  8013d6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	c7 04 24 ca 27 80 00 	movl   $0x8027ca,(%esp)
  8013e8:	e8 f8 ed ff ff       	call   8001e5 <cprintf>
  8013ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013f2:	eb 22                	jmp    801416 <read+0x88>
	}
	if (!dev->dev_read)
  8013f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f7:	8b 48 08             	mov    0x8(%eax),%ecx
  8013fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ff:	85 c9                	test   %ecx,%ecx
  801401:	74 13                	je     801416 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801403:	8b 45 10             	mov    0x10(%ebp),%eax
  801406:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	89 14 24             	mov    %edx,(%esp)
  801414:	ff d1                	call   *%ecx
}
  801416:	83 c4 24             	add    $0x24,%esp
  801419:	5b                   	pop    %ebx
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	57                   	push   %edi
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	83 ec 1c             	sub    $0x1c,%esp
  801425:	8b 7d 08             	mov    0x8(%ebp),%edi
  801428:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142b:	ba 00 00 00 00       	mov    $0x0,%edx
  801430:	bb 00 00 00 00       	mov    $0x0,%ebx
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	85 f6                	test   %esi,%esi
  80143c:	74 29                	je     801467 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80143e:	89 f0                	mov    %esi,%eax
  801440:	29 d0                	sub    %edx,%eax
  801442:	89 44 24 08          	mov    %eax,0x8(%esp)
  801446:	03 55 0c             	add    0xc(%ebp),%edx
  801449:	89 54 24 04          	mov    %edx,0x4(%esp)
  80144d:	89 3c 24             	mov    %edi,(%esp)
  801450:	e8 39 ff ff ff       	call   80138e <read>
		if (m < 0)
  801455:	85 c0                	test   %eax,%eax
  801457:	78 0e                	js     801467 <readn+0x4b>
			return m;
		if (m == 0)
  801459:	85 c0                	test   %eax,%eax
  80145b:	74 08                	je     801465 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145d:	01 c3                	add    %eax,%ebx
  80145f:	89 da                	mov    %ebx,%edx
  801461:	39 f3                	cmp    %esi,%ebx
  801463:	72 d9                	jb     80143e <readn+0x22>
  801465:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801467:	83 c4 1c             	add    $0x1c,%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5f                   	pop    %edi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	56                   	push   %esi
  801473:	53                   	push   %ebx
  801474:	83 ec 20             	sub    $0x20,%esp
  801477:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80147a:	89 34 24             	mov    %esi,(%esp)
  80147d:	e8 0e fc ff ff       	call   801090 <fd2num>
  801482:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801485:	89 54 24 04          	mov    %edx,0x4(%esp)
  801489:	89 04 24             	mov    %eax,(%esp)
  80148c:	e8 9c fc ff ff       	call   80112d <fd_lookup>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	85 c0                	test   %eax,%eax
  801495:	78 05                	js     80149c <fd_close+0x2d>
  801497:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80149a:	74 0c                	je     8014a8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80149c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8014a0:	19 c0                	sbb    %eax,%eax
  8014a2:	f7 d0                	not    %eax
  8014a4:	21 c3                	and    %eax,%ebx
  8014a6:	eb 3d                	jmp    8014e5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014af:	8b 06                	mov    (%esi),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 e8 fc ff ff       	call   8011a1 <dev_lookup>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 16                	js     8014d5 <fd_close+0x66>
		if (dev->dev_close)
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	8b 40 10             	mov    0x10(%eax),%eax
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	74 07                	je     8014d5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8014ce:	89 34 24             	mov    %esi,(%esp)
  8014d1:	ff d0                	call   *%eax
  8014d3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e0:	e8 bd f9 ff ff       	call   800ea2 <sys_page_unmap>
	return r;
}
  8014e5:	89 d8                	mov    %ebx,%eax
  8014e7:	83 c4 20             	add    $0x20,%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	89 04 24             	mov    %eax,(%esp)
  801501:	e8 27 fc ff ff       	call   80112d <fd_lookup>
  801506:	85 c0                	test   %eax,%eax
  801508:	78 13                	js     80151d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80150a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801511:	00 
  801512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801515:	89 04 24             	mov    %eax,(%esp)
  801518:	e8 52 ff ff ff       	call   80146f <fd_close>
}
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	83 ec 18             	sub    $0x18,%esp
  801525:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801528:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80152b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801532:	00 
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	89 04 24             	mov    %eax,(%esp)
  801539:	e8 4d 03 00 00       	call   80188b <open>
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	85 c0                	test   %eax,%eax
  801542:	78 1b                	js     80155f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801544:	8b 45 0c             	mov    0xc(%ebp),%eax
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	89 1c 24             	mov    %ebx,(%esp)
  80154e:	e8 b7 fc ff ff       	call   80120a <fstat>
  801553:	89 c6                	mov    %eax,%esi
	close(fd);
  801555:	89 1c 24             	mov    %ebx,(%esp)
  801558:	e8 91 ff ff ff       	call   8014ee <close>
  80155d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801564:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801567:	89 ec                	mov    %ebp,%esp
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 14             	sub    $0x14,%esp
  801572:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801577:	89 1c 24             	mov    %ebx,(%esp)
  80157a:	e8 6f ff ff ff       	call   8014ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80157f:	83 c3 01             	add    $0x1,%ebx
  801582:	83 fb 20             	cmp    $0x20,%ebx
  801585:	75 f0                	jne    801577 <close_all+0xc>
		close(i);
}
  801587:	83 c4 14             	add    $0x14,%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5d                   	pop    %ebp
  80158c:	c3                   	ret    

0080158d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	83 ec 58             	sub    $0x58,%esp
  801593:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801596:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801599:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80159c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80159f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 7c fb ff ff       	call   80112d <fd_lookup>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	0f 88 e0 00 00 00    	js     80169b <dup+0x10e>
		return r;
	close(newfdnum);
  8015bb:	89 3c 24             	mov    %edi,(%esp)
  8015be:	e8 2b ff ff ff       	call   8014ee <close>

	newfd = INDEX2FD(newfdnum);
  8015c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cf:	89 04 24             	mov    %eax,(%esp)
  8015d2:	e8 c9 fa ff ff       	call   8010a0 <fd2data>
  8015d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015d9:	89 34 24             	mov    %esi,(%esp)
  8015dc:	e8 bf fa ff ff       	call   8010a0 <fd2data>
  8015e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8015e4:	89 da                	mov    %ebx,%edx
  8015e6:	89 d8                	mov    %ebx,%eax
  8015e8:	c1 e8 16             	shr    $0x16,%eax
  8015eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f2:	a8 01                	test   $0x1,%al
  8015f4:	74 43                	je     801639 <dup+0xac>
  8015f6:	c1 ea 0c             	shr    $0xc,%edx
  8015f9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801600:	a8 01                	test   $0x1,%al
  801602:	74 35                	je     801639 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801604:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80160b:	25 07 0e 00 00       	and    $0xe07,%eax
  801610:	89 44 24 10          	mov    %eax,0x10(%esp)
  801614:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801617:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801622:	00 
  801623:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162e:	e8 cd f8 ff ff       	call   800f00 <sys_page_map>
  801633:	89 c3                	mov    %eax,%ebx
  801635:	85 c0                	test   %eax,%eax
  801637:	78 3f                	js     801678 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801639:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	c1 ea 0c             	shr    $0xc,%edx
  801641:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801648:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80164e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801652:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801656:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80165d:	00 
  80165e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801669:	e8 92 f8 ff ff       	call   800f00 <sys_page_map>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	85 c0                	test   %eax,%eax
  801672:	78 04                	js     801678 <dup+0xeb>
  801674:	89 fb                	mov    %edi,%ebx
  801676:	eb 23                	jmp    80169b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801678:	89 74 24 04          	mov    %esi,0x4(%esp)
  80167c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801683:	e8 1a f8 ff ff       	call   800ea2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801688:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80168b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801696:	e8 07 f8 ff ff       	call   800ea2 <sys_page_unmap>
	return r;
}
  80169b:	89 d8                	mov    %ebx,%eax
  80169d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016a0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016a6:	89 ec                	mov    %ebp,%esp
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    
  8016aa:	00 00                	add    %al,(%eax)
  8016ac:	00 00                	add    %al,(%eax)
	...

008016b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 14             	sub    $0x14,%esp
  8016b7:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b9:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8016bf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016c6:	00 
  8016c7:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8016ce:	00 
  8016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d3:	89 14 24             	mov    %edx,(%esp)
  8016d6:	e8 81 09 00 00       	call   80205c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016e2:	00 
  8016e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ee:	e8 d3 09 00 00       	call   8020c6 <ipc_recv>
}
  8016f3:	83 c4 14             	add    $0x14,%esp
  8016f6:	5b                   	pop    %ebx
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  80170a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170d:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	b8 02 00 00 00       	mov    $0x2,%eax
  80171c:	e8 8f ff ff ff       	call   8016b0 <fsipc>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 06 00 00 00       	mov    $0x6,%eax
  80173e:	e8 6d ff ff ff       	call   8016b0 <fsipc>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 08 00 00 00       	mov    $0x8,%eax
  801755:	e8 56 ff ff ff       	call   8016b0 <fsipc>
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 14             	sub    $0x14,%esp
  801763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 40 0c             	mov    0xc(%eax),%eax
  80176c:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 05 00 00 00       	mov    $0x5,%eax
  80177b:	e8 30 ff ff ff       	call   8016b0 <fsipc>
  801780:	85 c0                	test   %eax,%eax
  801782:	78 2b                	js     8017af <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801784:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80178b:	00 
  80178c:	89 1c 24             	mov    %ebx,(%esp)
  80178f:	e8 36 f1 ff ff       	call   8008ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801794:	a1 80 30 80 00       	mov    0x803080,%eax
  801799:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179f:	a1 84 30 80 00       	mov    0x803084,%eax
  8017a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017af:	83 c4 14             	add    $0x14,%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 18             	sub    $0x18,%esp
  8017bb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017be:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c4:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  8017ca:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8017e1:	e8 9f f2 ff ff       	call   800a85 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  8017e6:	ba 00 30 80 00       	mov    $0x803000,%edx
  8017eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f0:	e8 bb fe ff ff       	call   8016b0 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801809:	8b 45 10             	mov    0x10(%ebp),%eax
  80180c:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801811:	ba 00 30 80 00       	mov    $0x803000,%edx
  801816:	b8 03 00 00 00       	mov    $0x3,%eax
  80181b:	e8 90 fe ff ff       	call   8016b0 <fsipc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	85 c0                	test   %eax,%eax
  801824:	78 17                	js     80183d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801826:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801831:	00 
  801832:	8b 45 0c             	mov    0xc(%ebp),%eax
  801835:	89 04 24             	mov    %eax,(%esp)
  801838:	e8 48 f2 ff ff       	call   800a85 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80183d:	89 d8                	mov    %ebx,%eax
  80183f:	83 c4 14             	add    $0x14,%esp
  801842:	5b                   	pop    %ebx
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 14             	sub    $0x14,%esp
  80184c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80184f:	89 1c 24             	mov    %ebx,(%esp)
  801852:	e8 29 f0 ff ff       	call   800880 <strlen>
  801857:	89 c2                	mov    %eax,%edx
  801859:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80185e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801864:	7f 1f                	jg     801885 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801866:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80186a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801871:	e8 54 f0 ff ff       	call   8008ca <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801876:	ba 00 00 00 00       	mov    $0x0,%edx
  80187b:	b8 07 00 00 00       	mov    $0x7,%eax
  801880:	e8 2b fe ff ff       	call   8016b0 <fsipc>
}
  801885:	83 c4 14             	add    $0x14,%esp
  801888:	5b                   	pop    %ebx
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  801891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801894:	89 04 24             	mov    %eax,(%esp)
  801897:	e8 1f f8 ff ff       	call   8010bb <fd_alloc>
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 6a                	js     80190a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018ae:	e8 17 f0 ff ff       	call   8008ca <strcpy>
        fsipcbuf.open.req_omode = mode;
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018bb:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  8018c0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018c7:	00 
  8018c8:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8018cf:	00 
  8018d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018d7:	00 
  8018d8:	89 04 24             	mov    %eax,(%esp)
  8018db:	e8 7c 07 00 00       	call   80205c <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  8018e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e7:	00 
  8018e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f6:	e8 cb 07 00 00       	call   8020c6 <ipc_recv>
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 0b                	js     80190a <open+0x7f>
		return r;
	return fd2num(fd);
  8018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	e8 86 f7 ff ff       	call   801090 <fd2num>
	panic("open not implemented");
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 4c             	sub    $0x4c,%esp
  801915:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801918:	89 d7                	mov    %edx,%edi
  80191a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80191d:	8b 02                	mov    (%edx),%eax
  80191f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801924:	be 00 00 00 00       	mov    $0x0,%esi
  801929:	85 c0                	test   %eax,%eax
  80192b:	75 10                	jne    80193d <init_stack+0x31>
  80192d:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  801934:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80193b:	eb 23                	jmp    801960 <init_stack+0x54>
		string_size += strlen(argv[argc]) + 1;
  80193d:	89 04 24             	mov    %eax,(%esp)
  801940:	e8 3b ef ff ff       	call   800880 <strlen>
  801945:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801949:	83 c3 01             	add    $0x1,%ebx
  80194c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801953:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801956:	85 c0                	test   %eax,%eax
  801958:	75 e3                	jne    80193d <init_stack+0x31>
  80195a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80195d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801960:	f7 de                	neg    %esi
  801962:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801968:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80196b:	89 f2                	mov    %esi,%edx
  80196d:	83 e2 fc             	and    $0xfffffffc,%edx
  801970:	89 d8                	mov    %ebx,%eax
  801972:	f7 d0                	not    %eax
  801974:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801977:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80197a:	83 e8 08             	sub    $0x8,%eax
  80197d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801980:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801985:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80198a:	0f 86 2d 01 00 00    	jbe    801abd <init_stack+0x1b1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801990:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801997:	00 
  801998:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80199f:	00 
  8019a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a7:	e8 b2 f5 ff ff       	call   800f5e <sys_page_alloc>
  8019ac:	89 c6                	mov    %eax,%esi
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	0f 88 07 01 00 00    	js     801abd <init_stack+0x1b1>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019b6:	85 db                	test   %ebx,%ebx
  8019b8:	7e 40                	jle    8019fa <init_stack+0xee>
  8019ba:	be 00 00 00 00       	mov    $0x0,%esi
  8019bf:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8019c2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8019c5:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  8019cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019ce:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8019d1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8019d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d8:	89 1c 24             	mov    %ebx,(%esp)
  8019db:	e8 ea ee ff ff       	call   8008ca <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019e0:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8019e3:	89 04 24             	mov    %eax,(%esp)
  8019e6:	e8 95 ee ff ff       	call   800880 <strlen>
  8019eb:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019ef:	83 c6 01             	add    $0x1,%esi
  8019f2:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  8019f5:	7c ce                	jl     8019c5 <init_stack+0xb9>
  8019f7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8019fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801a00:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a07:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801a0e:	74 24                	je     801a34 <init_stack+0x128>
  801a10:	c7 44 24 0c f0 27 80 	movl   $0x8027f0,0xc(%esp)
  801a17:	00 
  801a18:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  801a1f:	00 
  801a20:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  801a27:	00 
  801a28:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  801a2f:	e8 ec e6 ff ff       	call   800120 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a37:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a3f:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801a42:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801a45:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a48:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a4d:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801a52:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801a55:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a57:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a5e:	00 
  801a5f:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801a66:	ee 
  801a67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a75:	00 
  801a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7d:	e8 7e f4 ff ff       	call   800f00 <sys_page_map>
  801a82:	89 c6                	mov    %eax,%esi
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 21                	js     801aa9 <init_stack+0x19d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a88:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a8f:	00 
  801a90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a97:	e8 06 f4 ff ff       	call   800ea2 <sys_page_unmap>
  801a9c:	89 c6                	mov    %eax,%esi
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 07                	js     801aa9 <init_stack+0x19d>
  801aa2:	be 00 00 00 00       	mov    $0x0,%esi
  801aa7:	eb 14                	jmp    801abd <init_stack+0x1b1>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801aa9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ab0:	00 
  801ab1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab8:	e8 e5 f3 ff ff       	call   800ea2 <sys_page_unmap>
	return r;
}
  801abd:	89 f0                	mov    %esi,%eax
  801abf:	83 c4 4c             	add    $0x4c,%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5f                   	pop    %edi
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <map_segment>:

static int
map_segment(envid_t child, uintptr_t va, size_t memsz, 
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	57                   	push   %edi
  801acb:	56                   	push   %esi
  801acc:	53                   	push   %ebx
  801acd:	83 ec 3c             	sub    $0x3c,%esp
  801ad0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ad3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801ad6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801ad9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801adc:	89 d0                	mov    %edx,%eax
  801ade:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ae3:	74 0d                	je     801af2 <map_segment+0x2b>
		va -= i;
  801ae5:	29 c2                	sub    %eax,%edx
  801ae7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		memsz += i;
  801aea:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801aed:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801aef:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801af2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801af6:	0f 84 12 01 00 00    	je     801c0e <map_segment+0x147>
  801afc:	be 00 00 00 00       	mov    $0x0,%esi
  801b01:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801b06:	39 f7                	cmp    %esi,%edi
  801b08:	77 26                	ja     801b30 <map_segment+0x69>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b11:	03 75 e4             	add    -0x1c(%ebp),%esi
  801b14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b1b:	89 14 24             	mov    %edx,(%esp)
  801b1e:	e8 3b f4 ff ff       	call   800f5e <sys_page_alloc>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	0f 89 d2 00 00 00    	jns    801bfd <map_segment+0x136>
  801b2b:	e9 e3 00 00 00       	jmp    801c13 <map_segment+0x14c>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b30:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b37:	00 
  801b38:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b3f:	00 
  801b40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b47:	e8 12 f4 ff ff       	call   800f5e <sys_page_alloc>
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	0f 88 bf 00 00 00    	js     801c13 <map_segment+0x14c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b54:	8b 55 10             	mov    0x10(%ebp),%edx
  801b57:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	89 04 24             	mov    %eax,(%esp)
  801b64:	e8 0c f6 ff ff       	call   801175 <seek>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	0f 88 a2 00 00 00    	js     801c13 <map_segment+0x14c>
				return r;
			if ((r = read(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b71:	89 f8                	mov    %edi,%eax
  801b73:	29 f0                	sub    %esi,%eax
  801b75:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b7a:	76 05                	jbe    801b81 <map_segment+0xba>
  801b7c:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b85:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b8c:	00 
  801b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b90:	89 14 24             	mov    %edx,(%esp)
  801b93:	e8 f6 f7 ff ff       	call   80138e <read>
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 77                	js     801c13 <map_segment+0x14c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b9c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ba3:	03 75 e4             	add    -0x1c(%ebp),%esi
  801ba6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801baa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801bad:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bb1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bb8:	00 
  801bb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc0:	e8 3b f3 ff ff       	call   800f00 <sys_page_map>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	79 20                	jns    801be9 <map_segment+0x122>
				panic("spawn: sys_page_map data: %e", r);
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	c7 44 24 08 39 28 80 	movl   $0x802839,0x8(%esp)
  801bd4:	00 
  801bd5:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  801bdc:	00 
  801bdd:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  801be4:	e8 37 e5 ff ff       	call   800120 <_panic>
			sys_page_unmap(0, UTEMP);
  801be9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bf0:	00 
  801bf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf8:	e8 a5 f2 ff ff       	call   800ea2 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bfd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c03:	89 de                	mov    %ebx,%esi
  801c05:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801c08:	0f 87 f8 fe ff ff    	ja     801b06 <map_segment+0x3f>
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}
  801c13:	83 c4 3c             	add    $0x3c,%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5f                   	pop    %edi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <spawn_vmmn>:



int
spawn_vmmn(const char *prog)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	57                   	push   %edi
  801c1f:	56                   	push   %esi
  801c20:	53                   	push   %ebx
  801c21:	81 ec 7c 02 00 00    	sub    $0x27c,%esp
	struct Proghdr *ph;
	int perm;


	//cprintf("error here\n");
	if ((r = open(prog, O_RDONLY)) < 0)
  801c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c2e:	00 
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c32:	89 04 24             	mov    %eax,(%esp)
  801c35:	e8 51 fc ff ff       	call   80188b <open>
  801c3a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c40:	89 c7                	mov    %eax,%edi
  801c42:	85 c0                	test   %eax,%eax
  801c44:	0f 88 c8 01 00 00    	js     801e12 <spawn_vmmn+0x1f7>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801c4a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801c51:	00 
  801c52:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5c:	89 3c 24             	mov    %edi,(%esp)
  801c5f:	e8 2a f7 ff ff       	call   80138e <read>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c64:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c69:	75 0c                	jne    801c77 <spawn_vmmn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801c6b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c72:	45 4c 46 
  801c75:	74 36                	je     801cad <spawn_vmmn+0x92>
		close(fd);
  801c77:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c7d:	89 04 24             	mov    %eax,(%esp)
  801c80:	e8 69 f8 ff ff       	call   8014ee <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c85:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801c8c:	46 
  801c8d:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801c93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c97:	c7 04 24 56 28 80 00 	movl   $0x802856,(%esp)
  801c9e:	e8 42 e5 ff ff       	call   8001e5 <cprintf>
  801ca3:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  801ca8:	e9 65 01 00 00       	jmp    801e12 <spawn_vmmn+0x1f7>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801cad:	ba 07 00 00 00       	mov    $0x7,%edx
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	cd 30                	int    $0x30
  801cb6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	//cprintf("****%s %d %x %s %x\n", elf_buf, sizeof(elf_buf), elf->e_magic, elf, elf->e_entry);
	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	0f 88 48 01 00 00    	js     801e0c <spawn_vmmn+0x1f1>
		return r;
	child = r;
	cprintf("child: %x\n", child);
  801cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc8:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  801ccf:	e8 11 e5 ff ff       	call   8001e5 <cprintf>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cd4:	8b b5 90 fd ff ff    	mov    -0x270(%ebp),%esi
  801cda:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ce0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801ce3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ce9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cef:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cf4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cf6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cfc:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)


	const char *a = "hello";
  801d02:	c7 85 a0 fd ff ff 7b 	movl   $0x80287b,-0x260(%ebp)
  801d09:	28 80 00 
	const char **argv = &a;
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801d0c:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801d12:	8d 95 a0 fd ff ff    	lea    -0x260(%ebp),%edx
  801d18:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d1e:	e8 e9 fb ff ff       	call   80190c <init_stack>
  801d23:	89 c7                	mov    %eax,%edi
  801d25:	85 c0                	test   %eax,%eax
  801d27:	0f 88 e5 00 00 00    	js     801e12 <spawn_vmmn+0x1f7>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d2d:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d33:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801d3a:	00 
  801d3b:	74 65                	je     801da2 <spawn_vmmn+0x187>
	const char **argv = &a;
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d3d:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  801d44:	be 00 00 00 00       	mov    $0x0,%esi
  801d49:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801d4f:	83 3b 01             	cmpl   $0x1,(%ebx)
  801d52:	75 3b                	jne    801d8f <spawn_vmmn+0x174>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d54:	8b 43 18             	mov    0x18(%ebx),%eax
  801d57:	83 e0 02             	and    $0x2,%eax
  801d5a:	83 f8 01             	cmp    $0x1,%eax
  801d5d:	19 c0                	sbb    %eax,%eax
  801d5f:	83 e0 fe             	and    $0xfffffffe,%eax
  801d62:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
  801d65:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801d68:	8b 53 08             	mov    0x8(%ebx),%edx
  801d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d6f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d72:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d76:	8b 43 10             	mov    0x10(%ebx),%eax
  801d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7d:	89 3c 24             	mov    %edi,(%esp)
  801d80:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d86:	e8 3c fd ff ff       	call   801ac7 <map_segment>
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 5d                	js     801dec <spawn_vmmn+0x1d1>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d8f:	83 c6 01             	add    $0x1,%esi
  801d92:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d99:	39 f0                	cmp    %esi,%eax
  801d9b:	7e 05                	jle    801da2 <spawn_vmmn+0x187>
  801d9d:	83 c3 20             	add    $0x20,%ebx
  801da0:	eb ad                	jmp    801d4f <spawn_vmmn+0x134>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801da2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801da8:	89 04 24             	mov    %eax,(%esp)
  801dab:	e8 3e f7 ff ff       	call   8014ee <close>
	fd = -1;
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801db0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801db6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dba:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801dc0:	89 04 24             	mov    %eax,(%esp)
  801dc3:	e8 1e f0 ff ff       	call   800de6 <sys_env_set_trapframe>
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	79 40                	jns    801e0c <spawn_vmmn+0x1f1>
		panic("sys_env_set_trapframe: %e", r);
  801dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd0:	c7 44 24 08 81 28 80 	movl   $0x802881,0x8(%esp)
  801dd7:	00 
  801dd8:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
  801ddf:	00 
  801de0:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  801de7:	e8 34 e3 ff ff       	call   800120 <_panic>
  801dec:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);
*/
	return child;

error:
	sys_env_destroy(child);
  801dee:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801df4:	89 04 24             	mov    %eax,(%esp)
  801df7:	e8 29 f2 ff ff       	call   801025 <sys_env_destroy>
	close(fd);
  801dfc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e02:	89 04 24             	mov    %eax,(%esp)
  801e05:	e8 e4 f6 ff ff       	call   8014ee <close>
	return r;
  801e0a:	eb 06                	jmp    801e12 <spawn_vmmn+0x1f7>
  801e0c:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  801e12:	89 f8                	mov    %edi,%eax
  801e14:	81 c4 7c 02 00 00    	add    $0x27c,%esp
  801e1a:	5b                   	pop    %ebx
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	57                   	push   %edi
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	81 ec 7c 02 00 00    	sub    $0x27c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801e2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e32:	00 
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	89 04 24             	mov    %eax,(%esp)
  801e39:	e8 4d fa ff ff       	call   80188b <open>
  801e3e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e44:	89 c7                	mov    %eax,%edi
  801e46:	85 c0                	test   %eax,%eax
  801e48:	0f 88 e5 01 00 00    	js     802033 <spawn+0x214>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801e4e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801e55:	00 
  801e56:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e60:	89 3c 24             	mov    %edi,(%esp)
  801e63:	e8 26 f5 ff ff       	call   80138e <read>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801e68:	3d 00 02 00 00       	cmp    $0x200,%eax
  801e6d:	75 0c                	jne    801e7b <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801e6f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801e76:	45 4c 46 
  801e79:	74 36                	je     801eb1 <spawn+0x92>
		close(fd);
  801e7b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	e8 65 f6 ff ff       	call   8014ee <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801e89:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801e90:	46 
  801e91:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9b:	c7 04 24 56 28 80 00 	movl   $0x802856,(%esp)
  801ea2:	e8 3e e3 ff ff       	call   8001e5 <cprintf>
  801ea7:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  801eac:	e9 82 01 00 00       	jmp    802033 <spawn+0x214>
  801eb1:	ba 07 00 00 00       	mov    $0x7,%edx
  801eb6:	89 d0                	mov    %edx,%eax
  801eb8:	cd 30                	int    $0x30
  801eba:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	//cprintf("*%s %d %x %s %x\n", elf_buf, sizeof(elf_buf), elf->e_magic, elf, elf->e_entry);
	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	0f 88 65 01 00 00    	js     80202d <spawn+0x20e>
		return r;
	child = r;
//	cprintf("child: %x\n", child);
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ec8:	89 c6                	mov    %eax,%esi
  801eca:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ed0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801ed3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ed9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801edf:	b9 11 00 00 00       	mov    $0x11,%ecx
  801ee4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801ee6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801eec:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801ef2:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801ef8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efb:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f01:	e8 06 fa ff ff       	call   80190c <init_stack>
  801f06:	89 c7                	mov    %eax,%edi
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	0f 88 23 01 00 00    	js     802033 <spawn+0x214>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f10:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f16:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801f1d:	00 
  801f1e:	74 69                	je     801f89 <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f20:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  801f27:	be 00 00 00 00       	mov    $0x0,%esi
  801f2c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801f32:	83 3b 01             	cmpl   $0x1,(%ebx)
  801f35:	75 3f                	jne    801f76 <spawn+0x157>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f37:	8b 43 18             	mov    0x18(%ebx),%eax
  801f3a:	83 e0 02             	and    $0x2,%eax
  801f3d:	83 f8 01             	cmp    $0x1,%eax
  801f40:	19 c0                	sbb    %eax,%eax
  801f42:	83 e0 fe             	and    $0xfffffffe,%eax
  801f45:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		//cprintf("%x ph->p_va\n", ph->p_va);
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
  801f48:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801f4b:	8b 53 08             	mov    0x8(%ebx),%edx
  801f4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f52:	8b 43 04             	mov    0x4(%ebx),%eax
  801f55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f59:	8b 43 10             	mov    0x10(%ebx),%eax
  801f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f60:	89 3c 24             	mov    %edi,(%esp)
  801f63:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f69:	e8 59 fb ff ff       	call   801ac7 <map_segment>
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	0f 88 97 00 00 00    	js     80200d <spawn+0x1ee>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f76:	83 c6 01             	add    $0x1,%esi
  801f79:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f80:	39 f0                	cmp    %esi,%eax
  801f82:	7e 05                	jle    801f89 <spawn+0x16a>
  801f84:	83 c3 20             	add    $0x20,%ebx
  801f87:	eb a9                	jmp    801f32 <spawn+0x113>
		//cprintf("%x ph->p_va\n", ph->p_va);
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f89:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f8f:	89 04 24             	mov    %eax,(%esp)
  801f92:	e8 57 f5 ff ff       	call   8014ee <close>
	fd = -1;
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f97:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa1:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801fa7:	89 04 24             	mov    %eax,(%esp)
  801faa:	e8 37 ee ff ff       	call   800de6 <sys_env_set_trapframe>
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	79 20                	jns    801fd3 <spawn+0x1b4>
		panic("sys_env_set_trapframe: %e", r);
  801fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb7:	c7 44 24 08 81 28 80 	movl   $0x802881,0x8(%esp)
  801fbe:	00 
  801fbf:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801fc6:	00 
  801fc7:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  801fce:	e8 4d e1 ff ff       	call   800120 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801fd3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fda:	00 
  801fdb:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801fe1:	89 04 24             	mov    %eax,(%esp)
  801fe4:	e8 5b ee ff ff       	call   800e44 <sys_env_set_status>
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	79 40                	jns    80202d <spawn+0x20e>
		panic("sys_env_set_status: %e", r);
  801fed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff1:	c7 44 24 08 9b 28 80 	movl   $0x80289b,0x8(%esp)
  801ff8:	00 
  801ff9:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  802000:	00 
  802001:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  802008:	e8 13 e1 ff ff       	call   800120 <_panic>
  80200d:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  80200f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802015:	89 04 24             	mov    %eax,(%esp)
  802018:	e8 08 f0 ff ff       	call   801025 <sys_env_destroy>
	close(fd);
  80201d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802023:	89 04 24             	mov    %eax,(%esp)
  802026:	e8 c3 f4 ff ff       	call   8014ee <close>
	return r;
  80202b:	eb 06                	jmp    802033 <spawn+0x214>
  80202d:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  802033:	89 f8                	mov    %edi,%eax
  802035:	81 c4 7c 02 00 00    	add    $0x27c,%esp
  80203b:	5b                   	pop    %ebx
  80203c:	5e                   	pop    %esi
  80203d:	5f                   	pop    %edi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <spawnl>:

// Spawn, taking command-line arguments array directly on the stack.
int
spawnl(const char *prog, const char *arg0, ...)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 18             	sub    $0x18,%esp
	return spawn(prog, &arg0);
  802046:	8d 45 0c             	lea    0xc(%ebp),%eax
  802049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204d:	8b 45 08             	mov    0x8(%ebp),%eax
  802050:	89 04 24             	mov    %eax,(%esp)
  802053:	e8 c7 fd ff ff       	call   801e1f <spawn>
}
  802058:	c9                   	leave  
  802059:	c3                   	ret    
	...

0080205c <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	57                   	push   %edi
  802060:	56                   	push   %esi
  802061:	53                   	push   %ebx
  802062:	83 ec 1c             	sub    $0x1c,%esp
  802065:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802068:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80206b:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  80206e:	85 db                	test   %ebx,%ebx
  802070:	75 31                	jne    8020a3 <ipc_send+0x47>
  802072:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802077:	eb 2a                	jmp    8020a3 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  802079:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207c:	74 20                	je     80209e <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  80207e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802082:	c7 44 24 08 b2 28 80 	movl   $0x8028b2,0x8(%esp)
  802089:	00 
  80208a:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  802091:	00 
  802092:	c7 04 24 c9 28 80 00 	movl   $0x8028c9,(%esp)
  802099:	e8 82 e0 ff ff       	call   800120 <_panic>


                sys_yield();
  80209e:	e8 1a ef ff ff       	call   800fbd <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8020a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020af:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b2:	89 04 24             	mov    %eax,(%esp)
  8020b5:	e8 96 ec ff ff       	call   800d50 <sys_ipc_try_send>
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	78 bb                	js     802079 <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  8020be:	83 c4 1c             	add    $0x1c,%esp
  8020c1:	5b                   	pop    %ebx
  8020c2:	5e                   	pop    %esi
  8020c3:	5f                   	pop    %edi
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    

008020c6 <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	56                   	push   %esi
  8020ca:	53                   	push   %ebx
  8020cb:	83 ec 10             	sub    $0x10,%esp
  8020ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d4:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	75 05                	jne    8020e0 <ipc_recv+0x1a>
  8020db:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  8020e0:	89 04 24             	mov    %eax,(%esp)
  8020e3:	e8 0b ec ff ff       	call   800cf3 <sys_ipc_recv>
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	78 24                	js     802110 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  8020ec:	85 db                	test   %ebx,%ebx
  8020ee:	74 0a                	je     8020fa <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  8020f0:	a1 24 50 80 00       	mov    0x805024,%eax
  8020f5:	8b 40 74             	mov    0x74(%eax),%eax
  8020f8:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  8020fa:	85 f6                	test   %esi,%esi
  8020fc:	74 0a                	je     802108 <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  8020fe:	a1 24 50 80 00       	mov    0x805024,%eax
  802103:	8b 40 78             	mov    0x78(%eax),%eax
  802106:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  802108:	a1 24 50 80 00       	mov    0x805024,%eax
  80210d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    
	...

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	83 ec 10             	sub    $0x10,%esp
  802128:	8b 45 14             	mov    0x14(%ebp),%eax
  80212b:	8b 55 08             	mov    0x8(%ebp),%edx
  80212e:	8b 75 10             	mov    0x10(%ebp),%esi
  802131:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802134:	85 c0                	test   %eax,%eax
  802136:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802139:	75 35                	jne    802170 <__udivdi3+0x50>
  80213b:	39 fe                	cmp    %edi,%esi
  80213d:	77 61                	ja     8021a0 <__udivdi3+0x80>
  80213f:	85 f6                	test   %esi,%esi
  802141:	75 0b                	jne    80214e <__udivdi3+0x2e>
  802143:	b8 01 00 00 00       	mov    $0x1,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	f7 f6                	div    %esi
  80214c:	89 c6                	mov    %eax,%esi
  80214e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802151:	31 d2                	xor    %edx,%edx
  802153:	89 f8                	mov    %edi,%eax
  802155:	f7 f6                	div    %esi
  802157:	89 c7                	mov    %eax,%edi
  802159:	89 c8                	mov    %ecx,%eax
  80215b:	f7 f6                	div    %esi
  80215d:	89 c1                	mov    %eax,%ecx
  80215f:	89 fa                	mov    %edi,%edx
  802161:	89 c8                	mov    %ecx,%eax
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	39 f8                	cmp    %edi,%eax
  802172:	77 1c                	ja     802190 <__udivdi3+0x70>
  802174:	0f bd d0             	bsr    %eax,%edx
  802177:	83 f2 1f             	xor    $0x1f,%edx
  80217a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80217d:	75 39                	jne    8021b8 <__udivdi3+0x98>
  80217f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802182:	0f 86 a0 00 00 00    	jbe    802228 <__udivdi3+0x108>
  802188:	39 f8                	cmp    %edi,%eax
  80218a:	0f 82 98 00 00 00    	jb     802228 <__udivdi3+0x108>
  802190:	31 ff                	xor    %edi,%edi
  802192:	31 c9                	xor    %ecx,%ecx
  802194:	89 c8                	mov    %ecx,%eax
  802196:	89 fa                	mov    %edi,%edx
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	5e                   	pop    %esi
  80219c:	5f                   	pop    %edi
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    
  80219f:	90                   	nop
  8021a0:	89 d1                	mov    %edx,%ecx
  8021a2:	89 fa                	mov    %edi,%edx
  8021a4:	89 c8                	mov    %ecx,%eax
  8021a6:	31 ff                	xor    %edi,%edi
  8021a8:	f7 f6                	div    %esi
  8021aa:	89 c1                	mov    %eax,%ecx
  8021ac:	89 fa                	mov    %edi,%edx
  8021ae:	89 c8                	mov    %ecx,%eax
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	5e                   	pop    %esi
  8021b4:	5f                   	pop    %edi
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    
  8021b7:	90                   	nop
  8021b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021bc:	89 f2                	mov    %esi,%edx
  8021be:	d3 e0                	shl    %cl,%eax
  8021c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8021c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8021cb:	89 c1                	mov    %eax,%ecx
  8021cd:	d3 ea                	shr    %cl,%edx
  8021cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8021d6:	d3 e6                	shl    %cl,%esi
  8021d8:	89 c1                	mov    %eax,%ecx
  8021da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8021dd:	89 fe                	mov    %edi,%esi
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021eb:	d3 e7                	shl    %cl,%edi
  8021ed:	89 c1                	mov    %eax,%ecx
  8021ef:	d3 ea                	shr    %cl,%edx
  8021f1:	09 d7                	or     %edx,%edi
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	89 f8                	mov    %edi,%eax
  8021f7:	f7 75 ec             	divl   -0x14(%ebp)
  8021fa:	89 d6                	mov    %edx,%esi
  8021fc:	89 c7                	mov    %eax,%edi
  8021fe:	f7 65 e8             	mull   -0x18(%ebp)
  802201:	39 d6                	cmp    %edx,%esi
  802203:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802206:	72 30                	jb     802238 <__udivdi3+0x118>
  802208:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80220b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	39 c2                	cmp    %eax,%edx
  802213:	73 05                	jae    80221a <__udivdi3+0xfa>
  802215:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802218:	74 1e                	je     802238 <__udivdi3+0x118>
  80221a:	89 f9                	mov    %edi,%ecx
  80221c:	31 ff                	xor    %edi,%edi
  80221e:	e9 71 ff ff ff       	jmp    802194 <__udivdi3+0x74>
  802223:	90                   	nop
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	31 ff                	xor    %edi,%edi
  80222a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80222f:	e9 60 ff ff ff       	jmp    802194 <__udivdi3+0x74>
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80223b:	31 ff                	xor    %edi,%edi
  80223d:	89 c8                	mov    %ecx,%eax
  80223f:	89 fa                	mov    %edi,%edx
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
	...

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	57                   	push   %edi
  802254:	56                   	push   %esi
  802255:	83 ec 20             	sub    $0x20,%esp
  802258:	8b 55 14             	mov    0x14(%ebp),%edx
  80225b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802261:	8b 75 0c             	mov    0xc(%ebp),%esi
  802264:	85 d2                	test   %edx,%edx
  802266:	89 c8                	mov    %ecx,%eax
  802268:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80226b:	75 13                	jne    802280 <__umoddi3+0x30>
  80226d:	39 f7                	cmp    %esi,%edi
  80226f:	76 3f                	jbe    8022b0 <__umoddi3+0x60>
  802271:	89 f2                	mov    %esi,%edx
  802273:	f7 f7                	div    %edi
  802275:	89 d0                	mov    %edx,%eax
  802277:	31 d2                	xor    %edx,%edx
  802279:	83 c4 20             	add    $0x20,%esp
  80227c:	5e                   	pop    %esi
  80227d:	5f                   	pop    %edi
  80227e:	5d                   	pop    %ebp
  80227f:	c3                   	ret    
  802280:	39 f2                	cmp    %esi,%edx
  802282:	77 4c                	ja     8022d0 <__umoddi3+0x80>
  802284:	0f bd ca             	bsr    %edx,%ecx
  802287:	83 f1 1f             	xor    $0x1f,%ecx
  80228a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80228d:	75 51                	jne    8022e0 <__umoddi3+0x90>
  80228f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802292:	0f 87 e0 00 00 00    	ja     802378 <__umoddi3+0x128>
  802298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229b:	29 f8                	sub    %edi,%eax
  80229d:	19 d6                	sbb    %edx,%esi
  80229f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a5:	89 f2                	mov    %esi,%edx
  8022a7:	83 c4 20             	add    $0x20,%esp
  8022aa:	5e                   	pop    %esi
  8022ab:	5f                   	pop    %edi
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    
  8022ae:	66 90                	xchg   %ax,%ax
  8022b0:	85 ff                	test   %edi,%edi
  8022b2:	75 0b                	jne    8022bf <__umoddi3+0x6f>
  8022b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b9:	31 d2                	xor    %edx,%edx
  8022bb:	f7 f7                	div    %edi
  8022bd:	89 c7                	mov    %eax,%edi
  8022bf:	89 f0                	mov    %esi,%eax
  8022c1:	31 d2                	xor    %edx,%edx
  8022c3:	f7 f7                	div    %edi
  8022c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c8:	f7 f7                	div    %edi
  8022ca:	eb a9                	jmp    802275 <__umoddi3+0x25>
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 20             	add    $0x20,%esp
  8022d7:	5e                   	pop    %esi
  8022d8:	5f                   	pop    %edi
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022e4:	d3 e2                	shl    %cl,%edx
  8022e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8022ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8022f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8022f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022f8:	89 fa                	mov    %edi,%edx
  8022fa:	d3 ea                	shr    %cl,%edx
  8022fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802300:	0b 55 f4             	or     -0xc(%ebp),%edx
  802303:	d3 e7                	shl    %cl,%edi
  802305:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802309:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80230c:	89 f2                	mov    %esi,%edx
  80230e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802311:	89 c7                	mov    %eax,%edi
  802313:	d3 ea                	shr    %cl,%edx
  802315:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802319:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80231c:	89 c2                	mov    %eax,%edx
  80231e:	d3 e6                	shl    %cl,%esi
  802320:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802324:	d3 ea                	shr    %cl,%edx
  802326:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80232a:	09 d6                	or     %edx,%esi
  80232c:	89 f0                	mov    %esi,%eax
  80232e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802331:	d3 e7                	shl    %cl,%edi
  802333:	89 f2                	mov    %esi,%edx
  802335:	f7 75 f4             	divl   -0xc(%ebp)
  802338:	89 d6                	mov    %edx,%esi
  80233a:	f7 65 e8             	mull   -0x18(%ebp)
  80233d:	39 d6                	cmp    %edx,%esi
  80233f:	72 2b                	jb     80236c <__umoddi3+0x11c>
  802341:	39 c7                	cmp    %eax,%edi
  802343:	72 23                	jb     802368 <__umoddi3+0x118>
  802345:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802349:	29 c7                	sub    %eax,%edi
  80234b:	19 d6                	sbb    %edx,%esi
  80234d:	89 f0                	mov    %esi,%eax
  80234f:	89 f2                	mov    %esi,%edx
  802351:	d3 ef                	shr    %cl,%edi
  802353:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802357:	d3 e0                	shl    %cl,%eax
  802359:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80235d:	09 f8                	or     %edi,%eax
  80235f:	d3 ea                	shr    %cl,%edx
  802361:	83 c4 20             	add    $0x20,%esp
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
  802368:	39 d6                	cmp    %edx,%esi
  80236a:	75 d9                	jne    802345 <__umoddi3+0xf5>
  80236c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80236f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802372:	eb d1                	jmp    802345 <__umoddi3+0xf5>
  802374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	0f 82 18 ff ff ff    	jb     802298 <__umoddi3+0x48>
  802380:	e9 1d ff ff ff       	jmp    8022a2 <__umoddi3+0x52>
