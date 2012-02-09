
obj/user/icode_kernel:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include<inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
        cprintf("icode: spawn /kernel\n");
  80003a:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  800041:	e8 7b 01 00 00       	call   8001c1 <cprintf>
        if ((r = spawn_vmmn("/kernel")) < 0)
  800046:	c7 04 24 76 23 80 00 	movl   $0x802376,(%esp)
  80004d:	e8 99 1b 00 00       	call   801beb <spawn_vmmn>
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x42>
                panic("icode: spawn /kernel: %e", r);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 7e 23 80 	movl   $0x80237e,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 97 23 80 00 	movl   $0x802397,(%esp)
  800071:	e8 86 00 00 00       	call   8000fc <_panic>
}
  800076:	c9                   	leave  
  800077:	c3                   	ret    

00800078 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80008a:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  800091:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800094:	e8 28 0f 00 00       	call   800fc1 <sys_getenvid>
  800099:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a6:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ab:	85 f6                	test   %esi,%esi
  8000ad:	7e 07                	jle    8000b6 <libmain+0x3e>
		binaryname = argv[0];
  8000af:	8b 03                	mov    (%ebx),%eax
  8000b1:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  8000b6:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  8000bd:	e8 ff 00 00 00       	call   8001c1 <cprintf>
	umain(argc, argv);
  8000c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c6:	89 34 24             	mov    %esi,(%esp)
  8000c9:	e8 66 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ce:	e8 0d 00 00 00       	call   8000e0 <exit>
}
  8000d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000d6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000d9:	89 ec                	mov    %ebp,%esp
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    
  8000dd:	00 00                	add    %al,(%eax)
	...

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e6:	e8 50 14 00 00       	call   80153b <close_all>
	sys_env_destroy(0);
  8000eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f2:	e8 fe 0e 00 00       	call   800ff5 <sys_env_destroy>
}
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  800103:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800106:	a1 28 50 80 00       	mov    0x805028,%eax
  80010b:	85 c0                	test   %eax,%eax
  80010d:	74 10                	je     80011f <_panic+0x23>
		cprintf("%s: ", argv0);
  80010f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800113:	c7 04 24 d4 23 80 00 	movl   $0x8023d4,(%esp)
  80011a:	e8 a2 00 00 00       	call   8001c1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80011f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800122:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012d:	a1 00 50 80 00       	mov    0x805000,%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  80013d:	e8 7f 00 00 00       	call   8001c1 <cprintf>
	vcprintf(fmt, ap);
  800142:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800146:	8b 45 10             	mov    0x10(%ebp),%eax
  800149:	89 04 24             	mov    %eax,(%esp)
  80014c:	e8 0f 00 00 00       	call   800160 <vcprintf>
	cprintf("\n");
  800151:	c7 04 24 bb 23 80 00 	movl   $0x8023bb,(%esp)
  800158:	e8 64 00 00 00       	call   8001c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015d:	cc                   	int3   
  80015e:	eb fd                	jmp    80015d <_panic+0x61>

00800160 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	c7 04 24 db 01 80 00 	movl   $0x8001db,(%esp)
  80019c:	e8 cc 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 d7 0a 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001c7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 87 ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	83 ec 14             	sub    $0x14,%esp
  8001e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e5:	8b 03                	mov    (%ebx),%eax
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ee:	83 c0 01             	add    $0x1,%eax
  8001f1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	75 19                	jne    800213 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800201:	00 
  800202:	8d 43 08             	lea    0x8(%ebx),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 83 0a 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  80020d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	83 c4 14             	add    $0x14,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800243:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800246:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024b:	39 d1                	cmp    %edx,%ecx
  80024d:	72 15                	jb     800264 <printnum+0x44>
  80024f:	77 07                	ja     800258 <printnum+0x38>
  800251:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800254:	39 d0                	cmp    %edx,%eax
  800256:	76 0c                	jbe    800264 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	8d 76 00             	lea    0x0(%esi),%esi
  800260:	7f 61                	jg     8002c3 <printnum+0xa3>
  800262:	eb 70                	jmp    8002d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800277:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80027b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80027e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800281:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800284:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800288:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028f:	00 
  800290:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800299:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029d:	e8 4e 1e 00 00       	call   8020f0 <__udivdi3>
  8002a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b7:	89 f2                	mov    %esi,%edx
  8002b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002bc:	e8 5f ff ff ff       	call   800220 <printnum>
  8002c1:	eb 11                	jmp    8002d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c7:	89 3c 24             	mov    %edi,(%esp)
  8002ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cd:	83 eb 01             	sub    $0x1,%ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f ef                	jg     8002c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ea:	00 
  8002eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ee:	89 14 24             	mov    %edx,(%esp)
  8002f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002f8:	e8 23 1f 00 00       	call   802220 <__umoddi3>
  8002fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800301:	0f be 80 f5 23 80 00 	movsbl 0x8023f5(%eax),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80030e:	83 c4 4c             	add    $0x4c,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800319:	83 fa 01             	cmp    $0x1,%edx
  80031c:	7e 0e                	jle    80032c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 08             	lea    0x8(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	8b 52 04             	mov    0x4(%edx),%edx
  80032a:	eb 22                	jmp    80034e <getuint+0x38>
	else if (lflag)
  80032c:	85 d2                	test   %edx,%edx
  80032e:	74 10                	je     800340 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 04             	lea    0x4(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	eb 0e                	jmp    80034e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800356:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	3b 50 04             	cmp    0x4(%eax),%edx
  80035f:	73 0a                	jae    80036b <sprintputch+0x1b>
		*b->buf++ = ch;
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 0a                	mov    %cl,(%edx)
  800366:	83 c2 01             	add    $0x1,%edx
  800369:	89 10                	mov    %edx,(%eax)
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 5c             	sub    $0x5c,%esp
  800376:	8b 7d 08             	mov    0x8(%ebp),%edi
  800379:	8b 75 0c             	mov    0xc(%ebp),%esi
  80037c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80037f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800386:	eb 11                	jmp    800399 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800388:	85 c0                	test   %eax,%eax
  80038a:	0f 84 02 04 00 00    	je     800792 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800390:	89 74 24 04          	mov    %esi,0x4(%esp)
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	0f b6 03             	movzbl (%ebx),%eax
  80039c:	83 c3 01             	add    $0x1,%ebx
  80039f:	83 f8 25             	cmp    $0x25,%eax
  8003a2:	75 e4                	jne    800388 <vprintfmt+0x1b>
  8003a4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c2:	eb 06                	jmp    8003ca <vprintfmt+0x5d>
  8003c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003c8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	0f b6 13             	movzbl (%ebx),%edx
  8003cd:	0f b6 c2             	movzbl %dl,%eax
  8003d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003d6:	83 ea 23             	sub    $0x23,%edx
  8003d9:	80 fa 55             	cmp    $0x55,%dl
  8003dc:	0f 87 93 03 00 00    	ja     800775 <vprintfmt+0x408>
  8003e2:	0f b6 d2             	movzbl %dl,%edx
  8003e5:	ff 24 95 40 25 80 00 	jmp    *0x802540(,%edx,4)
  8003ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f0:	eb d6                	jmp    8003c8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f5:	83 ea 30             	sub    $0x30,%edx
  8003f8:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8003fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003fe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800401:	83 fb 09             	cmp    $0x9,%ebx
  800404:	77 4c                	ja     800452 <vprintfmt+0xe5>
  800406:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800409:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80040f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800412:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800416:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800419:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80041c:	83 fb 09             	cmp    $0x9,%ebx
  80041f:	76 eb                	jbe    80040c <vprintfmt+0x9f>
  800421:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800424:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800427:	eb 29                	jmp    800452 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800429:	8b 55 14             	mov    0x14(%ebp),%edx
  80042c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80042f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800432:	8b 12                	mov    (%edx),%edx
  800434:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  800437:	eb 19                	jmp    800452 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043c:	c1 fa 1f             	sar    $0x1f,%edx
  80043f:	f7 d2                	not    %edx
  800441:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800444:	eb 82                	jmp    8003c8 <vprintfmt+0x5b>
  800446:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80044d:	e9 76 ff ff ff       	jmp    8003c8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800452:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800456:	0f 89 6c ff ff ff    	jns    8003c8 <vprintfmt+0x5b>
  80045c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80045f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800462:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800465:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800468:	e9 5b ff ff ff       	jmp    8003c8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800470:	e9 53 ff ff ff       	jmp    8003c8 <vprintfmt+0x5b>
  800475:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	89 74 24 04          	mov    %esi,0x4(%esp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	ff d7                	call   *%edi
  80048c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80048f:	e9 05 ff ff ff       	jmp    800399 <vprintfmt+0x2c>
  800494:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	89 c2                	mov    %eax,%edx
  8004a4:	c1 fa 1f             	sar    $0x1f,%edx
  8004a7:	31 d0                	xor    %edx,%eax
  8004a9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004ab:	83 f8 0f             	cmp    $0xf,%eax
  8004ae:	7f 0b                	jg     8004bb <vprintfmt+0x14e>
  8004b0:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	75 20                	jne    8004db <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bf:	c7 44 24 08 06 24 80 	movl   $0x802406,0x8(%esp)
  8004c6:	00 
  8004c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cb:	89 3c 24             	mov    %edi,(%esp)
  8004ce:	e8 47 03 00 00       	call   80081a <printfmt>
  8004d3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	e9 be fe ff ff       	jmp    800399 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004df:	c7 44 24 08 ea 27 80 	movl   $0x8027ea,0x8(%esp)
  8004e6:	00 
  8004e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004eb:	89 3c 24             	mov    %edi,(%esp)
  8004ee:	e8 27 03 00 00       	call   80081a <printfmt>
  8004f3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8004f6:	e9 9e fe ff ff       	jmp    800399 <vprintfmt+0x2c>
  8004fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800506:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	85 c0                	test   %eax,%eax
  800519:	75 07                	jne    800522 <vprintfmt+0x1b5>
  80051b:	c7 45 e0 0f 24 80 00 	movl   $0x80240f,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800522:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800526:	7e 06                	jle    80052e <vprintfmt+0x1c1>
  800528:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052c:	75 13                	jne    800541 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800531:	0f be 02             	movsbl (%edx),%eax
  800534:	85 c0                	test   %eax,%eax
  800536:	0f 85 99 00 00 00    	jne    8005d5 <vprintfmt+0x268>
  80053c:	e9 86 00 00 00       	jmp    8005c7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800545:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800548:	89 0c 24             	mov    %ecx,(%esp)
  80054b:	e8 1b 03 00 00       	call   80086b <strnlen>
  800550:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800553:	29 c2                	sub    %eax,%edx
  800555:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800558:	85 d2                	test   %edx,%edx
  80055a:	7e d2                	jle    80052e <vprintfmt+0x1c1>
					putch(padc, putdat);
  80055c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800560:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800563:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800566:	89 d3                	mov    %edx,%ebx
  800568:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800574:	83 eb 01             	sub    $0x1,%ebx
  800577:	85 db                	test   %ebx,%ebx
  800579:	7f ed                	jg     800568 <vprintfmt+0x1fb>
  80057b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80057e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800585:	eb a7                	jmp    80052e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058b:	74 18                	je     8005a5 <vprintfmt+0x238>
  80058d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800590:	83 fa 5e             	cmp    $0x5e,%edx
  800593:	76 10                	jbe    8005a5 <vprintfmt+0x238>
					putch('?', putdat);
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800599:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a3:	eb 0a                	jmp    8005af <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005af:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005b3:	0f be 03             	movsbl (%ebx),%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	74 05                	je     8005bf <vprintfmt+0x252>
  8005ba:	83 c3 01             	add    $0x1,%ebx
  8005bd:	eb 29                	jmp    8005e8 <vprintfmt+0x27b>
  8005bf:	89 fe                	mov    %edi,%esi
  8005c1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cb:	7f 2e                	jg     8005fb <vprintfmt+0x28e>
  8005cd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005d0:	e9 c4 fd ff ff       	jmp    800399 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d8:	83 c2 01             	add    $0x1,%edx
  8005db:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005de:	89 f7                	mov    %esi,%edi
  8005e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005e6:	89 d3                	mov    %edx,%ebx
  8005e8:	85 f6                	test   %esi,%esi
  8005ea:	78 9b                	js     800587 <vprintfmt+0x21a>
  8005ec:	83 ee 01             	sub    $0x1,%esi
  8005ef:	79 96                	jns    800587 <vprintfmt+0x21a>
  8005f1:	89 fe                	mov    %edi,%esi
  8005f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f9:	eb cc                	jmp    8005c7 <vprintfmt+0x25a>
  8005fb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005fe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800601:	89 74 24 04          	mov    %esi,0x4(%esp)
  800605:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 eb 01             	sub    $0x1,%ebx
  800611:	85 db                	test   %ebx,%ebx
  800613:	7f ec                	jg     800601 <vprintfmt+0x294>
  800615:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800618:	e9 7c fd ff ff       	jmp    800399 <vprintfmt+0x2c>
  80061d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 16                	jle    80063b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 08             	lea    0x8(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	8b 48 04             	mov    0x4(%eax),%ecx
  800633:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800639:	eb 32                	jmp    80066d <vprintfmt+0x300>
	else if (lflag)
  80063b:	85 c9                	test   %ecx,%ecx
  80063d:	74 18                	je     800657 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064d:	89 c1                	mov    %eax,%ecx
  80064f:	c1 f9 1f             	sar    $0x1f,%ecx
  800652:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800655:	eb 16                	jmp    80066d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	89 c2                	mov    %eax,%edx
  800667:	c1 fa 1f             	sar    $0x1f,%edx
  80066a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800670:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800673:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800678:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067c:	0f 89 b1 00 00 00    	jns    800733 <vprintfmt+0x3c6>
				putch('-', putdat);
  800682:	89 74 24 04          	mov    %esi,0x4(%esp)
  800686:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80068d:	ff d7                	call   *%edi
				num = -(long long) num;
  80068f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800692:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800695:	f7 d8                	neg    %eax
  800697:	83 d2 00             	adc    $0x0,%edx
  80069a:	f7 da                	neg    %edx
  80069c:	e9 92 00 00 00       	jmp    800733 <vprintfmt+0x3c6>
  8006a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	89 ca                	mov    %ecx,%edx
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 68 fc ff ff       	call   800316 <getuint>
  8006ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8006b3:	eb 7e                	jmp    800733 <vprintfmt+0x3c6>
  8006b5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b8:	89 ca                	mov    %ecx,%edx
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bd:	e8 54 fc ff ff       	call   800316 <getuint>
			if ((long long) num < 0) {
  8006c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	79 62                	jns    800733 <vprintfmt+0x3c6>
				putch('-', putdat);
  8006d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006dc:	ff d7                	call   *%edi
				num = -(long long) num;
  8006de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e4:	f7 d8                	neg    %eax
  8006e6:	83 d2 00             	adc    $0x0,%edx
  8006e9:	f7 da                	neg    %edx
  8006eb:	eb 46                	jmp    800733 <vprintfmt+0x3c6>
  8006ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8006f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006fb:	ff d7                	call   *%edi
			putch('x', putdat);
  8006fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800701:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800708:	ff d7                	call   *%edi
			num = (unsigned long long)
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 00                	mov    (%eax),%eax
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071f:	eb 12                	jmp    800733 <vprintfmt+0x3c6>
  800721:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800724:	89 ca                	mov    %ecx,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 e8 fb ff ff       	call   800316 <getuint>
  80072e:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800733:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800737:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80073b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80073e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800742:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800746:	89 04 24             	mov    %eax,(%esp)
  800749:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074d:	89 f2                	mov    %esi,%edx
  80074f:	89 f8                	mov    %edi,%eax
  800751:	e8 ca fa ff ff       	call   800220 <printnum>
  800756:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800759:	e9 3b fc ff ff       	jmp    800399 <vprintfmt+0x2c>
  80075e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800761:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800764:	89 74 24 04          	mov    %esi,0x4(%esp)
  800768:	89 14 24             	mov    %edx,(%esp)
  80076b:	ff d7                	call   *%edi
  80076d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800770:	e9 24 fc ff ff       	jmp    800399 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800775:	89 74 24 04          	mov    %esi,0x4(%esp)
  800779:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800780:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800782:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800785:	80 38 25             	cmpb   $0x25,(%eax)
  800788:	0f 84 0b fc ff ff    	je     800399 <vprintfmt+0x2c>
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	eb f0                	jmp    800782 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800792:	83 c4 5c             	add    $0x5c,%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 28             	sub    $0x28,%esp
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 04                	je     8007ae <vsnprintf+0x14>
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	7f 07                	jg     8007b5 <vsnprintf+0x1b>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b3:	eb 3b                	jmp    8007f0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007db:	c7 04 24 50 03 80 00 	movl   $0x800350,(%esp)
  8007e2:	e8 86 fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800802:	89 44 24 08          	mov    %eax,0x8(%esp)
  800806:	8b 45 0c             	mov    0xc(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	e8 82 ff ff ff       	call   80079a <vsnprintf>
	va_end(ap);

	return rc;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800827:	8b 45 10             	mov    0x10(%ebp),%eax
  80082a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800831:	89 44 24 04          	mov    %eax,0x4(%esp)
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	89 04 24             	mov    %eax,(%esp)
  80083b:	e8 2d fb ff ff       	call   80036d <vprintfmt>
	va_end(ap);
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    
	...

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 19                	je     800892 <strnlen+0x27>
  800879:	80 3b 00             	cmpb   $0x0,(%ebx)
  80087c:	74 14                	je     800892 <strnlen+0x27>
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c8                	cmp    %ecx,%eax
  800888:	74 0d                	je     800897 <strnlen+0x2c>
  80088a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x18>
  800890:	eb 05                	jmp    800897 <strnlen+0x2c>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	75 f2                	jne    8008a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	85 f6                	test   %esi,%esi
  8008ca:	74 18                	je     8008e4 <strncpy+0x2a>
  8008cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d1:	0f b6 1a             	movzbl (%edx),%ebx
  8008d4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d7:	80 3a 01             	cmpb   $0x1,(%edx)
  8008da:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	39 ce                	cmp    %ecx,%esi
  8008e2:	77 ed                	ja     8008d1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 27                	je     800923 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008fc:	83 e9 01             	sub    $0x1,%ecx
  8008ff:	74 1d                	je     80091e <strlcpy+0x36>
  800901:	0f b6 1a             	movzbl (%edx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	74 16                	je     80091e <strlcpy+0x36>
			*dst++ = *src++;
  800908:	88 18                	mov    %bl,(%eax)
  80090a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090d:	83 e9 01             	sub    $0x1,%ecx
  800910:	74 0e                	je     800920 <strlcpy+0x38>
			*dst++ = *src++;
  800912:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800915:	0f b6 1a             	movzbl (%edx),%ebx
  800918:	84 db                	test   %bl,%bl
  80091a:	75 ec                	jne    800908 <strlcpy+0x20>
  80091c:	eb 02                	jmp    800920 <strlcpy+0x38>
  80091e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800920:	c6 00 00             	movb   $0x0,(%eax)
  800923:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800932:	0f b6 01             	movzbl (%ecx),%eax
  800935:	84 c0                	test   %al,%al
  800937:	74 15                	je     80094e <strcmp+0x25>
  800939:	3a 02                	cmp    (%edx),%al
  80093b:	75 11                	jne    80094e <strcmp+0x25>
		p++, q++;
  80093d:	83 c1 01             	add    $0x1,%ecx
  800940:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800943:	0f b6 01             	movzbl (%ecx),%eax
  800946:	84 c0                	test   %al,%al
  800948:	74 04                	je     80094e <strcmp+0x25>
  80094a:	3a 02                	cmp    (%edx),%al
  80094c:	74 ef                	je     80093d <strcmp+0x14>
  80094e:	0f b6 c0             	movzbl %al,%eax
  800951:	0f b6 12             	movzbl (%edx),%edx
  800954:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	8b 55 08             	mov    0x8(%ebp),%edx
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800962:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800965:	85 c0                	test   %eax,%eax
  800967:	74 23                	je     80098c <strncmp+0x34>
  800969:	0f b6 1a             	movzbl (%edx),%ebx
  80096c:	84 db                	test   %bl,%bl
  80096e:	74 24                	je     800994 <strncmp+0x3c>
  800970:	3a 19                	cmp    (%ecx),%bl
  800972:	75 20                	jne    800994 <strncmp+0x3c>
  800974:	83 e8 01             	sub    $0x1,%eax
  800977:	74 13                	je     80098c <strncmp+0x34>
		n--, p++, q++;
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	84 db                	test   %bl,%bl
  800984:	74 0e                	je     800994 <strncmp+0x3c>
  800986:	3a 19                	cmp    (%ecx),%bl
  800988:	74 ea                	je     800974 <strncmp+0x1c>
  80098a:	eb 08                	jmp    800994 <strncmp+0x3c>
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800991:	5b                   	pop    %ebx
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800994:	0f b6 02             	movzbl (%edx),%eax
  800997:	0f b6 11             	movzbl (%ecx),%edx
  80099a:	29 d0                	sub    %edx,%eax
  80099c:	eb f3                	jmp    800991 <strncmp+0x39>

0080099e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a8:	0f b6 10             	movzbl (%eax),%edx
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	74 15                	je     8009c4 <strchr+0x26>
		if (*s == c)
  8009af:	38 ca                	cmp    %cl,%dl
  8009b1:	75 07                	jne    8009ba <strchr+0x1c>
  8009b3:	eb 14                	jmp    8009c9 <strchr+0x2b>
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	90                   	nop
  8009b8:	74 0f                	je     8009c9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f1                	jne    8009b5 <strchr+0x17>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strfind+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strfind+0x1f>
  8009e0:	eb 12                	jmp    8009f4 <strfind+0x29>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0a                	je     8009f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	89 1c 24             	mov    %ebx,(%esp)
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 30                	je     800a44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 25                	jne    800a41 <memset+0x4b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 20                	jne    800a41 <memset+0x4b>
		c &= 0xFF;
  800a21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a24:	89 d3                	mov    %edx,%ebx
  800a26:	c1 e3 08             	shl    $0x8,%ebx
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 18             	shl    $0x18,%esi
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	c1 e0 10             	shl    $0x10,%eax
  800a33:	09 f0                	or     %esi,%eax
  800a35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a37:	09 d8                	or     %ebx,%eax
  800a39:	c1 e9 02             	shr    $0x2,%ecx
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	eb 03                	jmp    800a44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a44:	89 f8                	mov    %edi,%eax
  800a46:	8b 1c 24             	mov    (%esp),%ebx
  800a49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a51:	89 ec                	mov    %ebp,%esp
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	89 34 24             	mov    %esi,(%esp)
  800a5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 35                	jae    800aa6 <memmove+0x51>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 2e                	jae    800aa6 <memmove+0x51>
		s += n;
		d += n;
  800a78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	f6 c2 03             	test   $0x3,%dl
  800a7d:	75 1b                	jne    800a9a <memmove+0x45>
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 13                	jne    800a9a <memmove+0x45>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 0e                	jne    800a9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a8c:	83 ef 04             	sub    $0x4,%edi
  800a8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a92:	c1 e9 02             	shr    $0x2,%ecx
  800a95:	fd                   	std    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	eb 09                	jmp    800aa3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	eb 20                	jmp    800ac6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aac:	75 15                	jne    800ac3 <memmove+0x6e>
  800aae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab4:	75 0d                	jne    800ac3 <memmove+0x6e>
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	75 08                	jne    800ac3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	eb 03                	jmp    800ac6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	fc                   	cld    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac6:	8b 34 24             	mov    (%esp),%esi
  800ac9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800acd:	89 ec                	mov    %ebp,%esp
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 65 ff ff ff       	call   800a55 <memmove>
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 75 08             	mov    0x8(%ebp),%esi
  800afb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	85 c9                	test   %ecx,%ecx
  800b03:	74 36                	je     800b3b <memcmp+0x49>
		if (*s1 != *s2)
  800b05:	0f b6 06             	movzbl (%esi),%eax
  800b08:	0f b6 1f             	movzbl (%edi),%ebx
  800b0b:	38 d8                	cmp    %bl,%al
  800b0d:	74 20                	je     800b2f <memcmp+0x3d>
  800b0f:	eb 14                	jmp    800b25 <memcmp+0x33>
  800b11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	83 e9 01             	sub    $0x1,%ecx
  800b21:	38 d8                	cmp    %bl,%al
  800b23:	74 12                	je     800b37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 db             	movzbl %bl,%ebx
  800b2b:	29 d8                	sub    %ebx,%eax
  800b2d:	eb 11                	jmp    800b40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	83 e9 01             	sub    $0x1,%ecx
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	85 c9                	test   %ecx,%ecx
  800b39:	75 d6                	jne    800b11 <memcmp+0x1f>
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 15                	jae    800b69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b58:	38 08                	cmp    %cl,(%eax)
  800b5a:	75 06                	jne    800b62 <memfind+0x1d>
  800b5c:	eb 0b                	jmp    800b69 <memfind+0x24>
  800b5e:	38 08                	cmp    %cl,(%eax)
  800b60:	74 07                	je     800b69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	39 c2                	cmp    %eax,%edx
  800b67:	77 f5                	ja     800b5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 04             	sub    $0x4,%esp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 02             	movzbl (%edx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 04                	je     800b85 <strtol+0x1a>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	75 0e                	jne    800b93 <strtol+0x28>
		s++;
  800b85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	0f b6 02             	movzbl (%edx),%eax
  800b8b:	3c 20                	cmp    $0x20,%al
  800b8d:	74 f6                	je     800b85 <strtol+0x1a>
  800b8f:	3c 09                	cmp    $0x9,%al
  800b91:	74 f2                	je     800b85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b93:	3c 2b                	cmp    $0x2b,%al
  800b95:	75 0c                	jne    800ba3 <strtol+0x38>
		s++;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba1:	eb 15                	jmp    800bb8 <strtol+0x4d>
	else if (*s == '-')
  800ba3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	75 0a                	jne    800bb8 <strtol+0x4d>
		s++, neg = 1;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	85 db                	test   %ebx,%ebx
  800bba:	0f 94 c0             	sete   %al
  800bbd:	74 05                	je     800bc4 <strtol+0x59>
  800bbf:	83 fb 10             	cmp    $0x10,%ebx
  800bc2:	75 18                	jne    800bdc <strtol+0x71>
  800bc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc7:	75 13                	jne    800bdc <strtol+0x71>
  800bc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	75 0a                	jne    800bdc <strtol+0x71>
		s += 2, base = 16;
  800bd2:	83 c2 02             	add    $0x2,%edx
  800bd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	eb 15                	jmp    800bf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdc:	84 c0                	test   %al,%al
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	74 0f                	je     800bf1 <strtol+0x86>
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bea:	75 05                	jne    800bf1 <strtol+0x86>
		s++, base = 8;
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 0a             	movzbl (%edx),%ecx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xa2>
			dig = *s - '0';
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 30             	sub    $0x30,%ecx
  800c0b:	eb 1e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 57             	sub    $0x57,%ecx
  800c1b:	eb 0e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 15                	ja     800c3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2b:	39 f1                	cmp    %esi,%ecx
  800c2d:	7d 0b                	jge    800c3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c2f:	83 c2 01             	add    $0x1,%edx
  800c32:	0f af c6             	imul   %esi,%eax
  800c35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c38:	eb be                	jmp    800bf8 <strtol+0x8d>
  800c3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c40:	74 05                	je     800c47 <strtol+0xdc>
		*endptr = (char *) s;
  800c42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c4b:	74 04                	je     800c51 <strtol+0xe6>
  800c4d:	89 c8                	mov    %ecx,%eax
  800c4f:	f7 d8                	neg    %eax
}
  800c51:	83 c4 04             	add    $0x4,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    
  800c59:	00 00                	add    %al,(%eax)
	...

00800c5c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	89 1c 24             	mov    %ebx,(%esp)
  800c65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c69:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 01 00 00 00       	mov    $0x1,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c81:	8b 1c 24             	mov    (%esp),%ebx
  800c84:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c88:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c8c:	89 ec                	mov    %ebp,%esp
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	89 1c 24             	mov    %ebx,(%esp)
  800c99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 c3                	mov    %eax,%ebx
  800cae:	89 c7                	mov    %eax,%edi
  800cb0:	89 c6                	mov    %eax,%esi
  800cb2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb4:	8b 1c 24             	mov    (%esp),%ebx
  800cb7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cbb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cbf:	89 ec                	mov    %ebp,%esp
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 38             	sub    $0x38,%esp
  800cc9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ccc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 28                	jle    800d13 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800cfe:	00 
  800cff:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d06:	00 
  800d07:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800d0e:	e8 e9 f3 ff ff       	call   8000fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1c:	89 ec                	mov    %ebp,%esp
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	89 1c 24             	mov    %ebx,(%esp)
  800d29:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d2d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	be 00 00 00 00       	mov    $0x0,%esi
  800d36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d49:	8b 1c 24             	mov    (%esp),%ebx
  800d4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d50:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d54:	89 ec                	mov    %ebp,%esp
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 38             	sub    $0x38,%esp
  800d5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d64:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 28                	jle    800da9 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d85:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800d94:	00 
  800d95:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d9c:	00 
  800d9d:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800da4:	e8 53 f3 ff ff       	call   8000fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dac:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800daf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db2:	89 ec                	mov    %ebp,%esp
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	83 ec 38             	sub    $0x38,%esp
  800dbc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dbf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7e 28                	jle    800e07 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dea:	00 
  800deb:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800df2:	00 
  800df3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800dfa:	00 
  800dfb:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800e02:	e8 f5 f2 ff ff       	call   8000fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e07:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e10:	89 ec                	mov    %ebp,%esp
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 38             	sub    $0x38,%esp
  800e1a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e1d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e20:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e28:	b8 08 00 00 00       	mov    $0x8,%eax
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	89 df                	mov    %ebx,%edi
  800e35:	89 de                	mov    %ebx,%esi
  800e37:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7e 28                	jle    800e65 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e41:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e48:	00 
  800e49:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800e60:	e8 97 f2 ff ff       	call   8000fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e65:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e68:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e6b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6e:	89 ec                	mov    %ebp,%esp
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	83 ec 38             	sub    $0x38,%esp
  800e78:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e7b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e86:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	89 df                	mov    %ebx,%edi
  800e93:	89 de                	mov    %ebx,%esi
  800e95:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e97:	85 c0                	test   %eax,%eax
  800e99:	7e 28                	jle    800ec3 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800eae:	00 
  800eaf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800eb6:	00 
  800eb7:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800ebe:	e8 39 f2 ff ff       	call   8000fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ecc:	89 ec                	mov    %ebp,%esp
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 38             	sub    $0x38,%esp
  800ed6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800edc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee4:	8b 75 18             	mov    0x18(%ebp),%esi
  800ee7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 28                	jle    800f21 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800f1c:	e8 db f1 ff ff       	call   8000fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f2a:	89 ec                	mov    %ebp,%esp
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 38             	sub    $0x38,%esp
  800f34:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f37:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f3a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3d:	be 00 00 00 00       	mov    $0x0,%esi
  800f42:	b8 04 00 00 00       	mov    $0x4,%eax
  800f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	89 f7                	mov    %esi,%edi
  800f52:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f54:	85 c0                	test   %eax,%eax
  800f56:	7e 28                	jle    800f80 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f63:	00 
  800f64:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800f7b:	e8 7c f1 ff ff       	call   8000fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f83:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f86:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f89:	89 ec                	mov    %ebp,%esp
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	89 1c 24             	mov    %ebx,(%esp)
  800f96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 d3                	mov    %edx,%ebx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	89 d6                	mov    %edx,%esi
  800fb0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fb2:	8b 1c 24             	mov    (%esp),%ebx
  800fb5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fbd:	89 ec                	mov    %ebp,%esp
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	89 1c 24             	mov    %ebx,(%esp)
  800fca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fce:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800fdc:	89 d1                	mov    %edx,%ecx
  800fde:	89 d3                	mov    %edx,%ebx
  800fe0:	89 d7                	mov    %edx,%edi
  800fe2:	89 d6                	mov    %edx,%esi
  800fe4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fe6:	8b 1c 24             	mov    (%esp),%ebx
  800fe9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ff1:	89 ec                	mov    %ebp,%esp
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 38             	sub    $0x38,%esp
  800ffb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ffe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801001:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801004:	b9 00 00 00 00       	mov    $0x0,%ecx
  801009:	b8 03 00 00 00       	mov    $0x3,%eax
  80100e:	8b 55 08             	mov    0x8(%ebp),%edx
  801011:	89 cb                	mov    %ecx,%ebx
  801013:	89 cf                	mov    %ecx,%edi
  801015:	89 ce                	mov    %ecx,%esi
  801017:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801019:	85 c0                	test   %eax,%eax
  80101b:	7e 28                	jle    801045 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801021:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801028:	00 
  801029:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  801030:	00 
  801031:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  801040:	e8 b7 f0 ff ff       	call   8000fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801045:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801048:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80104e:	89 ec                	mov    %ebp,%esp
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    
	...

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	89 04 24             	mov    %eax,(%esp)
  80107c:	e8 df ff ff ff       	call   801060 <fd2num>
  801081:	05 20 00 0d 00       	add    $0xd0020,%eax
  801086:	c1 e0 0c             	shl    $0xc,%eax
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801094:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801099:	a8 01                	test   $0x1,%al
  80109b:	74 36                	je     8010d3 <fd_alloc+0x48>
  80109d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010a2:	a8 01                	test   $0x1,%al
  8010a4:	74 2d                	je     8010d3 <fd_alloc+0x48>
  8010a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8010b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	89 c2                	mov    %eax,%edx
  8010b9:	c1 ea 16             	shr    $0x16,%edx
  8010bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 14                	je     8010d8 <fd_alloc+0x4d>
  8010c4:	89 c2                	mov    %eax,%edx
  8010c6:	c1 ea 0c             	shr    $0xc,%edx
  8010c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8010cc:	f6 c2 01             	test   $0x1,%dl
  8010cf:	75 10                	jne    8010e1 <fd_alloc+0x56>
  8010d1:	eb 05                	jmp    8010d8 <fd_alloc+0x4d>
  8010d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8010d8:	89 1f                	mov    %ebx,(%edi)
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8010df:	eb 17                	jmp    8010f8 <fd_alloc+0x6d>
  8010e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010eb:	75 c8                	jne    8010b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8010f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	83 f8 1f             	cmp    $0x1f,%eax
  801106:	77 36                	ja     80113e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801108:	05 00 00 0d 00       	add    $0xd0000,%eax
  80110d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 16             	shr    $0x16,%edx
  801115:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 1d                	je     80113e <fd_lookup+0x41>
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 0c             	shr    $0xc,%edx
  801126:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 0c                	je     80113e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 02                	mov    %eax,(%edx)
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80113c:	eb 05                	jmp    801143 <fd_lookup+0x46>
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 a0 ff ff ff       	call   8010fd <fd_lookup>
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 0e                	js     80116f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801161:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801164:	8b 55 0c             	mov    0xc(%ebp),%edx
  801167:	89 50 04             	mov    %edx,0x4(%eax)
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 10             	sub    $0x10,%esp
  801179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80117f:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801184:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801189:	be a8 27 80 00       	mov    $0x8027a8,%esi
		if (devtab[i]->dev_id == dev_id) {
  80118e:	39 08                	cmp    %ecx,(%eax)
  801190:	75 10                	jne    8011a2 <dev_lookup+0x31>
  801192:	eb 04                	jmp    801198 <dev_lookup+0x27>
  801194:	39 08                	cmp    %ecx,(%eax)
  801196:	75 0a                	jne    8011a2 <dev_lookup+0x31>
			*dev = devtab[i];
  801198:	89 03                	mov    %eax,(%ebx)
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80119f:	90                   	nop
  8011a0:	eb 31                	jmp    8011d3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a2:	83 c2 01             	add    $0x1,%edx
  8011a5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	75 e8                	jne    801194 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8011ac:	a1 24 50 80 00       	mov    0x805024,%eax
  8011b1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8011b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011bc:	c7 04 24 2c 27 80 00 	movl   $0x80272c,(%esp)
  8011c3:	e8 f9 ef ff ff       	call   8001c1 <cprintf>
	*dev = 0;
  8011c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 24             	sub    $0x24,%esp
  8011e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ee:	89 04 24             	mov    %eax,(%esp)
  8011f1:	e8 07 ff ff ff       	call   8010fd <fd_lookup>
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 53                	js     80124d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801201:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801204:	8b 00                	mov    (%eax),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 63 ff ff ff       	call   801171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 3b                	js     80124d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801212:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801217:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80121e:	74 2d                	je     80124d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801220:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801223:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80122a:	00 00 00 
	stat->st_isdir = 0;
  80122d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801234:	00 00 00 
	stat->st_dev = dev;
  801237:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801240:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801244:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801247:	89 14 24             	mov    %edx,(%esp)
  80124a:	ff 50 14             	call   *0x14(%eax)
}
  80124d:	83 c4 24             	add    $0x24,%esp
  801250:	5b                   	pop    %ebx
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	83 ec 24             	sub    $0x24,%esp
  80125a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801260:	89 44 24 04          	mov    %eax,0x4(%esp)
  801264:	89 1c 24             	mov    %ebx,(%esp)
  801267:	e8 91 fe ff ff       	call   8010fd <fd_lookup>
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 5f                	js     8012cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	89 44 24 04          	mov    %eax,0x4(%esp)
  801277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127a:	8b 00                	mov    (%eax),%eax
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 ed fe ff ff       	call   801171 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801284:	85 c0                	test   %eax,%eax
  801286:	78 47                	js     8012cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801288:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80128b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80128f:	75 23                	jne    8012b4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  801291:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801296:	8b 40 4c             	mov    0x4c(%eax),%eax
  801299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  8012a8:	e8 14 ef ff ff       	call   8001c1 <cprintf>
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  8012b2:	eb 1b                	jmp    8012cf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b7:	8b 48 18             	mov    0x18(%eax),%ecx
  8012ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012bf:	85 c9                	test   %ecx,%ecx
  8012c1:	74 0c                	je     8012cf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ca:	89 14 24             	mov    %edx,(%esp)
  8012cd:	ff d1                	call   *%ecx
}
  8012cf:	83 c4 24             	add    $0x24,%esp
  8012d2:	5b                   	pop    %ebx
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 24             	sub    $0x24,%esp
  8012dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 0f fe ff ff       	call   8010fd <fd_lookup>
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 66                	js     801358 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	8b 00                	mov    (%eax),%eax
  8012fe:	89 04 24             	mov    %eax,(%esp)
  801301:	e8 6b fe ff ff       	call   801171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801306:	85 c0                	test   %eax,%eax
  801308:	78 4e                	js     801358 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80130a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80130d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801311:	75 23                	jne    801336 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801313:	a1 24 50 80 00       	mov    0x805024,%eax
  801318:	8b 40 4c             	mov    0x4c(%eax),%eax
  80131b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801323:	c7 04 24 6d 27 80 00 	movl   $0x80276d,(%esp)
  80132a:	e8 92 ee ff ff       	call   8001c1 <cprintf>
  80132f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801334:	eb 22                	jmp    801358 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801339:	8b 48 0c             	mov    0xc(%eax),%ecx
  80133c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801341:	85 c9                	test   %ecx,%ecx
  801343:	74 13                	je     801358 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801345:	8b 45 10             	mov    0x10(%ebp),%eax
  801348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801353:	89 14 24             	mov    %edx,(%esp)
  801356:	ff d1                	call   *%ecx
}
  801358:	83 c4 24             	add    $0x24,%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	53                   	push   %ebx
  801362:	83 ec 24             	sub    $0x24,%esp
  801365:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801368:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136f:	89 1c 24             	mov    %ebx,(%esp)
  801372:	e8 86 fd ff ff       	call   8010fd <fd_lookup>
  801377:	85 c0                	test   %eax,%eax
  801379:	78 6b                	js     8013e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801385:	8b 00                	mov    (%eax),%eax
  801387:	89 04 24             	mov    %eax,(%esp)
  80138a:	e8 e2 fd ff ff       	call   801171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 53                	js     8013e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801393:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801396:	8b 42 08             	mov    0x8(%edx),%eax
  801399:	83 e0 03             	and    $0x3,%eax
  80139c:	83 f8 01             	cmp    $0x1,%eax
  80139f:	75 23                	jne    8013c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8013a1:	a1 24 50 80 00       	mov    0x805024,%eax
  8013a6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8013a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	c7 04 24 8a 27 80 00 	movl   $0x80278a,(%esp)
  8013b8:	e8 04 ee ff ff       	call   8001c1 <cprintf>
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013c2:	eb 22                	jmp    8013e6 <read+0x88>
	}
	if (!dev->dev_read)
  8013c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c7:	8b 48 08             	mov    0x8(%eax),%ecx
  8013ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013cf:	85 c9                	test   %ecx,%ecx
  8013d1:	74 13                	je     8013e6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	89 14 24             	mov    %edx,(%esp)
  8013e4:	ff d1                	call   *%ecx
}
  8013e6:	83 c4 24             	add    $0x24,%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	57                   	push   %edi
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 1c             	sub    $0x1c,%esp
  8013f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
  80140a:	85 f6                	test   %esi,%esi
  80140c:	74 29                	je     801437 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140e:	89 f0                	mov    %esi,%eax
  801410:	29 d0                	sub    %edx,%eax
  801412:	89 44 24 08          	mov    %eax,0x8(%esp)
  801416:	03 55 0c             	add    0xc(%ebp),%edx
  801419:	89 54 24 04          	mov    %edx,0x4(%esp)
  80141d:	89 3c 24             	mov    %edi,(%esp)
  801420:	e8 39 ff ff ff       	call   80135e <read>
		if (m < 0)
  801425:	85 c0                	test   %eax,%eax
  801427:	78 0e                	js     801437 <readn+0x4b>
			return m;
		if (m == 0)
  801429:	85 c0                	test   %eax,%eax
  80142b:	74 08                	je     801435 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142d:	01 c3                	add    %eax,%ebx
  80142f:	89 da                	mov    %ebx,%edx
  801431:	39 f3                	cmp    %esi,%ebx
  801433:	72 d9                	jb     80140e <readn+0x22>
  801435:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801437:	83 c4 1c             	add    $0x1c,%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 20             	sub    $0x20,%esp
  801447:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144a:	89 34 24             	mov    %esi,(%esp)
  80144d:	e8 0e fc ff ff       	call   801060 <fd2num>
  801452:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801455:	89 54 24 04          	mov    %edx,0x4(%esp)
  801459:	89 04 24             	mov    %eax,(%esp)
  80145c:	e8 9c fc ff ff       	call   8010fd <fd_lookup>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	85 c0                	test   %eax,%eax
  801465:	78 05                	js     80146c <fd_close+0x2d>
  801467:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80146a:	74 0c                	je     801478 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80146c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801470:	19 c0                	sbb    %eax,%eax
  801472:	f7 d0                	not    %eax
  801474:	21 c3                	and    %eax,%ebx
  801476:	eb 3d                	jmp    8014b5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	8b 06                	mov    (%esi),%eax
  801481:	89 04 24             	mov    %eax,(%esp)
  801484:	e8 e8 fc ff ff       	call   801171 <dev_lookup>
  801489:	89 c3                	mov    %eax,%ebx
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 16                	js     8014a5 <fd_close+0x66>
		if (dev->dev_close)
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	8b 40 10             	mov    0x10(%eax),%eax
  801495:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 07                	je     8014a5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80149e:	89 34 24             	mov    %esi,(%esp)
  8014a1:	ff d0                	call   *%eax
  8014a3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b0:	e8 bd f9 ff ff       	call   800e72 <sys_page_unmap>
	return r;
}
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	83 c4 20             	add    $0x20,%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    

008014be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	e8 27 fc ff ff       	call   8010fd <fd_lookup>
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 13                	js     8014ed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014e1:	00 
  8014e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 52 ff ff ff       	call   80143f <fd_close>
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	83 ec 18             	sub    $0x18,%esp
  8014f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801502:	00 
  801503:	8b 45 08             	mov    0x8(%ebp),%eax
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	e8 4d 03 00 00       	call   80185b <open>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 1b                	js     80152f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801514:	8b 45 0c             	mov    0xc(%ebp),%eax
  801517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151b:	89 1c 24             	mov    %ebx,(%esp)
  80151e:	e8 b7 fc ff ff       	call   8011da <fstat>
  801523:	89 c6                	mov    %eax,%esi
	close(fd);
  801525:	89 1c 24             	mov    %ebx,(%esp)
  801528:	e8 91 ff ff ff       	call   8014be <close>
  80152d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801534:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801537:	89 ec                	mov    %ebp,%esp
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	83 ec 14             	sub    $0x14,%esp
  801542:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801547:	89 1c 24             	mov    %ebx,(%esp)
  80154a:	e8 6f ff ff ff       	call   8014be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80154f:	83 c3 01             	add    $0x1,%ebx
  801552:	83 fb 20             	cmp    $0x20,%ebx
  801555:	75 f0                	jne    801547 <close_all+0xc>
		close(i);
}
  801557:	83 c4 14             	add    $0x14,%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 58             	sub    $0x58,%esp
  801563:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801566:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801569:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80156c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80156f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	8b 45 08             	mov    0x8(%ebp),%eax
  801579:	89 04 24             	mov    %eax,(%esp)
  80157c:	e8 7c fb ff ff       	call   8010fd <fd_lookup>
  801581:	89 c3                	mov    %eax,%ebx
  801583:	85 c0                	test   %eax,%eax
  801585:	0f 88 e0 00 00 00    	js     80166b <dup+0x10e>
		return r;
	close(newfdnum);
  80158b:	89 3c 24             	mov    %edi,(%esp)
  80158e:	e8 2b ff ff ff       	call   8014be <close>

	newfd = INDEX2FD(newfdnum);
  801593:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801599:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80159c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	e8 c9 fa ff ff       	call   801070 <fd2data>
  8015a7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015a9:	89 34 24             	mov    %esi,(%esp)
  8015ac:	e8 bf fa ff ff       	call   801070 <fd2data>
  8015b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8015b4:	89 da                	mov    %ebx,%edx
  8015b6:	89 d8                	mov    %ebx,%eax
  8015b8:	c1 e8 16             	shr    $0x16,%eax
  8015bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c2:	a8 01                	test   $0x1,%al
  8015c4:	74 43                	je     801609 <dup+0xac>
  8015c6:	c1 ea 0c             	shr    $0xc,%edx
  8015c9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015d0:	a8 01                	test   $0x1,%al
  8015d2:	74 35                	je     801609 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8015d4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015db:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f2:	00 
  8015f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fe:	e8 cd f8 ff ff       	call   800ed0 <sys_page_map>
  801603:	89 c3                	mov    %eax,%ebx
  801605:	85 c0                	test   %eax,%eax
  801607:	78 3f                	js     801648 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	c1 ea 0c             	shr    $0xc,%edx
  801611:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801618:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80161e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801622:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801626:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80162d:	00 
  80162e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801632:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801639:	e8 92 f8 ff ff       	call   800ed0 <sys_page_map>
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	85 c0                	test   %eax,%eax
  801642:	78 04                	js     801648 <dup+0xeb>
  801644:	89 fb                	mov    %edi,%ebx
  801646:	eb 23                	jmp    80166b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801653:	e8 1a f8 ff ff       	call   800e72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801666:	e8 07 f8 ff ff       	call   800e72 <sys_page_unmap>
	return r;
}
  80166b:	89 d8                	mov    %ebx,%eax
  80166d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801670:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801673:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801676:	89 ec                	mov    %ebp,%esp
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    
  80167a:	00 00                	add    %al,(%eax)
  80167c:	00 00                	add    %al,(%eax)
	...

00801680 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	53                   	push   %ebx
  801684:	83 ec 14             	sub    $0x14,%esp
  801687:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801689:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  80168f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801696:	00 
  801697:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80169e:	00 
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	89 14 24             	mov    %edx,(%esp)
  8016a6:	e8 81 09 00 00       	call   80202c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b2:	00 
  8016b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016be:	e8 d3 09 00 00       	call   802096 <ipc_recv>
}
  8016c3:	83 c4 14             	add    $0x14,%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d5:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8016da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016dd:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ec:	e8 8f ff ff ff       	call   801680 <fsipc>
}
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ff:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	b8 06 00 00 00       	mov    $0x6,%eax
  80170e:	e8 6d ff ff ff       	call   801680 <fsipc>
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80171b:	ba 00 00 00 00       	mov    $0x0,%edx
  801720:	b8 08 00 00 00       	mov    $0x8,%eax
  801725:	e8 56 ff ff ff       	call   801680 <fsipc>
}
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	53                   	push   %ebx
  801730:	83 ec 14             	sub    $0x14,%esp
  801733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	8b 40 0c             	mov    0xc(%eax),%eax
  80173c:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801741:	ba 00 00 00 00       	mov    $0x0,%edx
  801746:	b8 05 00 00 00       	mov    $0x5,%eax
  80174b:	e8 30 ff ff ff       	call   801680 <fsipc>
  801750:	85 c0                	test   %eax,%eax
  801752:	78 2b                	js     80177f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801754:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80175b:	00 
  80175c:	89 1c 24             	mov    %ebx,(%esp)
  80175f:	e8 36 f1 ff ff       	call   80089a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801764:	a1 80 30 80 00       	mov    0x803080,%eax
  801769:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176f:	a1 84 30 80 00       	mov    0x803084,%eax
  801774:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80177f:	83 c4 14             	add    $0x14,%esp
  801782:	5b                   	pop    %ebx
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 18             	sub    $0x18,%esp
  80178b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80178e:	8b 55 08             	mov    0x8(%ebp),%edx
  801791:	8b 52 0c             	mov    0xc(%edx),%edx
  801794:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  80179a:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80179f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017aa:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8017b1:	e8 9f f2 ff ff       	call   800a55 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  8017b6:	ba 00 30 80 00       	mov    $0x803000,%edx
  8017bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c0:	e8 bb fe ff ff       	call   801680 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d4:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  8017d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017dc:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  8017e1:	ba 00 30 80 00       	mov    $0x803000,%edx
  8017e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8017eb:	e8 90 fe ff ff       	call   801680 <fsipc>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 17                	js     80180d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  8017f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fa:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801801:	00 
  801802:	8b 45 0c             	mov    0xc(%ebp),%eax
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 48 f2 ff ff       	call   800a55 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80180d:	89 d8                	mov    %ebx,%eax
  80180f:	83 c4 14             	add    $0x14,%esp
  801812:	5b                   	pop    %ebx
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	53                   	push   %ebx
  801819:	83 ec 14             	sub    $0x14,%esp
  80181c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80181f:	89 1c 24             	mov    %ebx,(%esp)
  801822:	e8 29 f0 ff ff       	call   800850 <strlen>
  801827:	89 c2                	mov    %eax,%edx
  801829:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80182e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801834:	7f 1f                	jg     801855 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801836:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801841:	e8 54 f0 ff ff       	call   80089a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 07 00 00 00       	mov    $0x7,%eax
  801850:	e8 2b fe ff ff       	call   801680 <fsipc>
}
  801855:	83 c4 14             	add    $0x14,%esp
  801858:	5b                   	pop    %ebx
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  801861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	e8 1f f8 ff ff       	call   80108b <fd_alloc>
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 6a                	js     8018da <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80187e:	e8 17 f0 ff ff       	call   80089a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801883:	8b 45 0c             	mov    0xc(%ebp),%eax
  801886:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801890:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801897:	00 
  801898:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80189f:	00 
  8018a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018a7:	00 
  8018a8:	89 04 24             	mov    %eax,(%esp)
  8018ab:	e8 7c 07 00 00       	call   80202c <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  8018b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018b7:	00 
  8018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c6:	e8 cb 07 00 00       	call   802096 <ipc_recv>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 0b                	js     8018da <open+0x7f>
		return r;
	return fd2num(fd);
  8018cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d2:	89 04 24             	mov    %eax,(%esp)
  8018d5:	e8 86 f7 ff ff       	call   801060 <fd2num>
	panic("open not implemented");
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 4c             	sub    $0x4c,%esp
  8018e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8018e8:	89 d7                	mov    %edx,%edi
  8018ea:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018ed:	8b 02                	mov    (%edx),%eax
  8018ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f4:	be 00 00 00 00       	mov    $0x0,%esi
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	75 10                	jne    80190d <init_stack+0x31>
  8018fd:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  801904:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80190b:	eb 23                	jmp    801930 <init_stack+0x54>
		string_size += strlen(argv[argc]) + 1;
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	e8 3b ef ff ff       	call   800850 <strlen>
  801915:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801919:	83 c3 01             	add    $0x1,%ebx
  80191c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801923:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801926:	85 c0                	test   %eax,%eax
  801928:	75 e3                	jne    80190d <init_stack+0x31>
  80192a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80192d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801930:	f7 de                	neg    %esi
  801932:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801938:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80193b:	89 f2                	mov    %esi,%edx
  80193d:	83 e2 fc             	and    $0xfffffffc,%edx
  801940:	89 d8                	mov    %ebx,%eax
  801942:	f7 d0                	not    %eax
  801944:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801947:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80194a:	83 e8 08             	sub    $0x8,%eax
  80194d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801950:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801955:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80195a:	0f 86 2d 01 00 00    	jbe    801a8d <init_stack+0x1b1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801960:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801967:	00 
  801968:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80196f:	00 
  801970:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801977:	e8 b2 f5 ff ff       	call   800f2e <sys_page_alloc>
  80197c:	89 c6                	mov    %eax,%esi
  80197e:	85 c0                	test   %eax,%eax
  801980:	0f 88 07 01 00 00    	js     801a8d <init_stack+0x1b1>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801986:	85 db                	test   %ebx,%ebx
  801988:	7e 40                	jle    8019ca <init_stack+0xee>
  80198a:	be 00 00 00 00       	mov    $0x0,%esi
  80198f:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801992:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801995:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  80199b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80199e:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8019a1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a8:	89 1c 24             	mov    %ebx,(%esp)
  8019ab:	e8 ea ee ff ff       	call   80089a <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019b0:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 95 ee ff ff       	call   800850 <strlen>
  8019bb:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019bf:	83 c6 01             	add    $0x1,%esi
  8019c2:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  8019c5:	7c ce                	jl     801995 <init_stack+0xb9>
  8019c7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8019ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019cd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8019d0:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8019d7:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  8019de:	74 24                	je     801a04 <init_stack+0x128>
  8019e0:	c7 44 24 0c b0 27 80 	movl   $0x8027b0,0xc(%esp)
  8019e7:	00 
  8019e8:	c7 44 24 08 d8 27 80 	movl   $0x8027d8,0x8(%esp)
  8019ef:	00 
  8019f0:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  8019f7:	00 
  8019f8:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  8019ff:	e8 f8 e6 ff ff       	call   8000fc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a07:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a0f:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801a12:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801a15:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a18:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1d:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801a22:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801a25:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a27:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a2e:	00 
  801a2f:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801a36:	ee 
  801a37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a3e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a45:	00 
  801a46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4d:	e8 7e f4 ff ff       	call   800ed0 <sys_page_map>
  801a52:	89 c6                	mov    %eax,%esi
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 21                	js     801a79 <init_stack+0x19d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a58:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a5f:	00 
  801a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a67:	e8 06 f4 ff ff       	call   800e72 <sys_page_unmap>
  801a6c:	89 c6                	mov    %eax,%esi
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 07                	js     801a79 <init_stack+0x19d>
  801a72:	be 00 00 00 00       	mov    $0x0,%esi
  801a77:	eb 14                	jmp    801a8d <init_stack+0x1b1>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a79:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a80:	00 
  801a81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a88:	e8 e5 f3 ff ff       	call   800e72 <sys_page_unmap>
	return r;
}
  801a8d:	89 f0                	mov    %esi,%eax
  801a8f:	83 c4 4c             	add    $0x4c,%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <map_segment>:

static int
map_segment(envid_t child, uintptr_t va, size_t memsz, 
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 3c             	sub    $0x3c,%esp
  801aa0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801aa3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801aa6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801aa9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801aac:	89 d0                	mov    %edx,%eax
  801aae:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ab3:	74 0d                	je     801ac2 <map_segment+0x2b>
		va -= i;
  801ab5:	29 c2                	sub    %eax,%edx
  801ab7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		memsz += i;
  801aba:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801abd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801abf:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ac2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ac6:	0f 84 12 01 00 00    	je     801bde <map_segment+0x147>
  801acc:	be 00 00 00 00       	mov    $0x0,%esi
  801ad1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801ad6:	39 f7                	cmp    %esi,%edi
  801ad8:	77 26                	ja     801b00 <map_segment+0x69>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ada:	8b 45 14             	mov    0x14(%ebp),%eax
  801add:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae1:	03 75 e4             	add    -0x1c(%ebp),%esi
  801ae4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801aeb:	89 14 24             	mov    %edx,(%esp)
  801aee:	e8 3b f4 ff ff       	call   800f2e <sys_page_alloc>
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 89 d2 00 00 00    	jns    801bcd <map_segment+0x136>
  801afb:	e9 e3 00 00 00       	jmp    801be3 <map_segment+0x14c>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b00:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b07:	00 
  801b08:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b0f:	00 
  801b10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b17:	e8 12 f4 ff ff       	call   800f2e <sys_page_alloc>
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	0f 88 bf 00 00 00    	js     801be3 <map_segment+0x14c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b24:	8b 55 10             	mov    0x10(%ebp),%edx
  801b27:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	89 04 24             	mov    %eax,(%esp)
  801b34:	e8 0c f6 ff ff       	call   801145 <seek>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	0f 88 a2 00 00 00    	js     801be3 <map_segment+0x14c>
				return r;
			if ((r = read(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b41:	89 f8                	mov    %edi,%eax
  801b43:	29 f0                	sub    %esi,%eax
  801b45:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4a:	76 05                	jbe    801b51 <map_segment+0xba>
  801b4c:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b55:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b5c:	00 
  801b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b60:	89 14 24             	mov    %edx,(%esp)
  801b63:	e8 f6 f7 ff ff       	call   80135e <read>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 77                	js     801be3 <map_segment+0x14c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b73:	03 75 e4             	add    -0x1c(%ebp),%esi
  801b76:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b7d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b81:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b88:	00 
  801b89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b90:	e8 3b f3 ff ff       	call   800ed0 <sys_page_map>
  801b95:	85 c0                	test   %eax,%eax
  801b97:	79 20                	jns    801bb9 <map_segment+0x122>
				panic("spawn: sys_page_map data: %e", r);
  801b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9d:	c7 44 24 08 f9 27 80 	movl   $0x8027f9,0x8(%esp)
  801ba4:	00 
  801ba5:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  801bac:	00 
  801bad:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  801bb4:	e8 43 e5 ff ff       	call   8000fc <_panic>
			sys_page_unmap(0, UTEMP);
  801bb9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bc0:	00 
  801bc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc8:	e8 a5 f2 ff ff       	call   800e72 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bcd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801bd3:	89 de                	mov    %ebx,%esi
  801bd5:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801bd8:	0f 87 f8 fe ff ff    	ja     801ad6 <map_segment+0x3f>
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}
  801be3:	83 c4 3c             	add    $0x3c,%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <spawn_vmmn>:



int
spawn_vmmn(const char *prog)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	57                   	push   %edi
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	81 ec 7c 02 00 00    	sub    $0x27c,%esp
	struct Proghdr *ph;
	int perm;


	//cprintf("error here\n");
	if ((r = open(prog, O_RDONLY)) < 0)
  801bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bfe:	00 
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	89 04 24             	mov    %eax,(%esp)
  801c05:	e8 51 fc ff ff       	call   80185b <open>
  801c0a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c10:	89 c7                	mov    %eax,%edi
  801c12:	85 c0                	test   %eax,%eax
  801c14:	0f 88 c8 01 00 00    	js     801de2 <spawn_vmmn+0x1f7>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801c1a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801c21:	00 
  801c22:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2c:	89 3c 24             	mov    %edi,(%esp)
  801c2f:	e8 2a f7 ff ff       	call   80135e <read>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c34:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c39:	75 0c                	jne    801c47 <spawn_vmmn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801c3b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c42:	45 4c 46 
  801c45:	74 36                	je     801c7d <spawn_vmmn+0x92>
		close(fd);
  801c47:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c4d:	89 04 24             	mov    %eax,(%esp)
  801c50:	e8 69 f8 ff ff       	call   8014be <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c55:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801c5c:	46 
  801c5d:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  801c6e:	e8 4e e5 ff ff       	call   8001c1 <cprintf>
  801c73:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  801c78:	e9 65 01 00 00       	jmp    801de2 <spawn_vmmn+0x1f7>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801c7d:	ba 07 00 00 00       	mov    $0x7,%edx
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	cd 30                	int    $0x30
  801c86:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	//cprintf("****%s %d %x %s %x\n", elf_buf, sizeof(elf_buf), elf->e_magic, elf, elf->e_entry);
	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	0f 88 48 01 00 00    	js     801ddc <spawn_vmmn+0x1f1>
		return r;
	child = r;
	cprintf("child: %x\n", child);
  801c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c98:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  801c9f:	e8 1d e5 ff ff       	call   8001c1 <cprintf>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ca4:	8b b5 90 fd ff ff    	mov    -0x270(%ebp),%esi
  801caa:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cb0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801cb3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cb9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cbf:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cc6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ccc:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)


	const char *a = "hello";
  801cd2:	c7 85 a0 fd ff ff 3b 	movl   $0x80283b,-0x260(%ebp)
  801cd9:	28 80 00 
	const char **argv = &a;
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801cdc:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801ce2:	8d 95 a0 fd ff ff    	lea    -0x260(%ebp),%edx
  801ce8:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801cee:	e8 e9 fb ff ff       	call   8018dc <init_stack>
  801cf3:	89 c7                	mov    %eax,%edi
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 e5 00 00 00    	js     801de2 <spawn_vmmn+0x1f7>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cfd:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d03:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801d0a:	00 
  801d0b:	74 65                	je     801d72 <spawn_vmmn+0x187>
	const char **argv = &a;
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d0d:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  801d14:	be 00 00 00 00       	mov    $0x0,%esi
  801d19:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801d1f:	83 3b 01             	cmpl   $0x1,(%ebx)
  801d22:	75 3b                	jne    801d5f <spawn_vmmn+0x174>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d24:	8b 43 18             	mov    0x18(%ebx),%eax
  801d27:	83 e0 02             	and    $0x2,%eax
  801d2a:	83 f8 01             	cmp    $0x1,%eax
  801d2d:	19 c0                	sbb    %eax,%eax
  801d2f:	83 e0 fe             	and    $0xfffffffe,%eax
  801d32:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
  801d35:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801d38:	8b 53 08             	mov    0x8(%ebx),%edx
  801d3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d46:	8b 43 10             	mov    0x10(%ebx),%eax
  801d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4d:	89 3c 24             	mov    %edi,(%esp)
  801d50:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d56:	e8 3c fd ff ff       	call   801a97 <map_segment>
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 5d                	js     801dbc <spawn_vmmn+0x1d1>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d5f:	83 c6 01             	add    $0x1,%esi
  801d62:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d69:	39 f0                	cmp    %esi,%eax
  801d6b:	7e 05                	jle    801d72 <spawn_vmmn+0x187>
  801d6d:	83 c3 20             	add    $0x20,%ebx
  801d70:	eb ad                	jmp    801d1f <spawn_vmmn+0x134>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d72:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d78:	89 04 24             	mov    %eax,(%esp)
  801d7b:	e8 3e f7 ff ff       	call   8014be <close>
	fd = -1;
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d80:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d90:	89 04 24             	mov    %eax,(%esp)
  801d93:	e8 1e f0 ff ff       	call   800db6 <sys_env_set_trapframe>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	79 40                	jns    801ddc <spawn_vmmn+0x1f1>
		panic("sys_env_set_trapframe: %e", r);
  801d9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da0:	c7 44 24 08 41 28 80 	movl   $0x802841,0x8(%esp)
  801da7:	00 
  801da8:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
  801daf:	00 
  801db0:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  801db7:	e8 40 e3 ff ff       	call   8000fc <_panic>
  801dbc:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);
*/
	return child;

error:
	sys_env_destroy(child);
  801dbe:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801dc4:	89 04 24             	mov    %eax,(%esp)
  801dc7:	e8 29 f2 ff ff       	call   800ff5 <sys_env_destroy>
	close(fd);
  801dcc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dd2:	89 04 24             	mov    %eax,(%esp)
  801dd5:	e8 e4 f6 ff ff       	call   8014be <close>
	return r;
  801dda:	eb 06                	jmp    801de2 <spawn_vmmn+0x1f7>
  801ddc:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  801de2:	89 f8                	mov    %edi,%eax
  801de4:	81 c4 7c 02 00 00    	add    $0x27c,%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5f                   	pop    %edi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    

00801def <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	57                   	push   %edi
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	81 ec 7c 02 00 00    	sub    $0x27c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801dfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e02:	00 
  801e03:	8b 45 08             	mov    0x8(%ebp),%eax
  801e06:	89 04 24             	mov    %eax,(%esp)
  801e09:	e8 4d fa ff ff       	call   80185b <open>
  801e0e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e14:	89 c7                	mov    %eax,%edi
  801e16:	85 c0                	test   %eax,%eax
  801e18:	0f 88 e5 01 00 00    	js     802003 <spawn+0x214>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801e1e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801e25:	00 
  801e26:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e30:	89 3c 24             	mov    %edi,(%esp)
  801e33:	e8 26 f5 ff ff       	call   80135e <read>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (read(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801e38:	3d 00 02 00 00       	cmp    $0x200,%eax
  801e3d:	75 0c                	jne    801e4b <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801e3f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801e46:	45 4c 46 
  801e49:	74 36                	je     801e81 <spawn+0x92>
		close(fd);
  801e4b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e51:	89 04 24             	mov    %eax,(%esp)
  801e54:	e8 65 f6 ff ff       	call   8014be <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801e59:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801e60:	46 
  801e61:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  801e72:	e8 4a e3 ff ff       	call   8001c1 <cprintf>
  801e77:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  801e7c:	e9 82 01 00 00       	jmp    802003 <spawn+0x214>
  801e81:	ba 07 00 00 00       	mov    $0x7,%edx
  801e86:	89 d0                	mov    %edx,%eax
  801e88:	cd 30                	int    $0x30
  801e8a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	//cprintf("*%s %d %x %s %x\n", elf_buf, sizeof(elf_buf), elf->e_magic, elf, elf->e_entry);
	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801e90:	85 c0                	test   %eax,%eax
  801e92:	0f 88 65 01 00 00    	js     801ffd <spawn+0x20e>
		return r;
	child = r;
//	cprintf("child: %x\n", child);
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801e98:	89 c6                	mov    %eax,%esi
  801e9a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ea0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801ea3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ea9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801eaf:	b9 11 00 00 00       	mov    $0x11,%ecx
  801eb4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801eb6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ebc:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801ec2:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801ec8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ecb:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ed1:	e8 06 fa ff ff       	call   8018dc <init_stack>
  801ed6:	89 c7                	mov    %eax,%edi
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	0f 88 23 01 00 00    	js     802003 <spawn+0x214>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ee0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ee6:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801eed:	00 
  801eee:	74 69                	je     801f59 <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ef0:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  801ef7:	be 00 00 00 00       	mov    $0x0,%esi
  801efc:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801f02:	83 3b 01             	cmpl   $0x1,(%ebx)
  801f05:	75 3f                	jne    801f46 <spawn+0x157>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f07:	8b 43 18             	mov    0x18(%ebx),%eax
  801f0a:	83 e0 02             	and    $0x2,%eax
  801f0d:	83 f8 01             	cmp    $0x1,%eax
  801f10:	19 c0                	sbb    %eax,%eax
  801f12:	83 e0 fe             	and    $0xfffffffe,%eax
  801f15:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		//cprintf("%x ph->p_va\n", ph->p_va);
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
  801f18:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801f1b:	8b 53 08             	mov    0x8(%ebx),%edx
  801f1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f22:	8b 43 04             	mov    0x4(%ebx),%eax
  801f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f29:	8b 43 10             	mov    0x10(%ebx),%eax
  801f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f30:	89 3c 24             	mov    %edi,(%esp)
  801f33:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f39:	e8 59 fb ff ff       	call   801a97 <map_segment>
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	0f 88 97 00 00 00    	js     801fdd <spawn+0x1ee>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f46:	83 c6 01             	add    $0x1,%esi
  801f49:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f50:	39 f0                	cmp    %esi,%eax
  801f52:	7e 05                	jle    801f59 <spawn+0x16a>
  801f54:	83 c3 20             	add    $0x20,%ebx
  801f57:	eb a9                	jmp    801f02 <spawn+0x113>
		//cprintf("%x ph->p_va\n", ph->p_va);
		if ((r = map_segment(child, ph->p_va, ph->p_memsz, 
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f59:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f5f:	89 04 24             	mov    %eax,(%esp)
  801f62:	e8 57 f5 ff ff       	call   8014be <close>
	fd = -1;
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f67:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f71:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801f77:	89 04 24             	mov    %eax,(%esp)
  801f7a:	e8 37 ee ff ff       	call   800db6 <sys_env_set_trapframe>
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	79 20                	jns    801fa3 <spawn+0x1b4>
		panic("sys_env_set_trapframe: %e", r);
  801f83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f87:	c7 44 24 08 41 28 80 	movl   $0x802841,0x8(%esp)
  801f8e:	00 
  801f8f:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801f96:	00 
  801f97:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  801f9e:	e8 59 e1 ff ff       	call   8000fc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801fa3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801faa:	00 
  801fab:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801fb1:	89 04 24             	mov    %eax,(%esp)
  801fb4:	e8 5b ee ff ff       	call   800e14 <sys_env_set_status>
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	79 40                	jns    801ffd <spawn+0x20e>
		panic("sys_env_set_status: %e", r);
  801fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc1:	c7 44 24 08 5b 28 80 	movl   $0x80285b,0x8(%esp)
  801fc8:	00 
  801fc9:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801fd0:	00 
  801fd1:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  801fd8:	e8 1f e1 ff ff       	call   8000fc <_panic>
  801fdd:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801fdf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 08 f0 ff ff       	call   800ff5 <sys_env_destroy>
	close(fd);
  801fed:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ff3:	89 04 24             	mov    %eax,(%esp)
  801ff6:	e8 c3 f4 ff ff       	call   8014be <close>
	return r;
  801ffb:	eb 06                	jmp    802003 <spawn+0x214>
  801ffd:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  802003:	89 f8                	mov    %edi,%eax
  802005:	81 c4 7c 02 00 00    	add    $0x27c,%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    

00802010 <spawnl>:

// Spawn, taking command-line arguments array directly on the stack.
int
spawnl(const char *prog, const char *arg0, ...)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	83 ec 18             	sub    $0x18,%esp
	return spawn(prog, &arg0);
  802016:	8d 45 0c             	lea    0xc(%ebp),%eax
  802019:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201d:	8b 45 08             	mov    0x8(%ebp),%eax
  802020:	89 04 24             	mov    %eax,(%esp)
  802023:	e8 c7 fd ff ff       	call   801def <spawn>
}
  802028:	c9                   	leave  
  802029:	c3                   	ret    
	...

0080202c <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	57                   	push   %edi
  802030:	56                   	push   %esi
  802031:	53                   	push   %ebx
  802032:	83 ec 1c             	sub    $0x1c,%esp
  802035:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802038:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80203b:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  80203e:	85 db                	test   %ebx,%ebx
  802040:	75 31                	jne    802073 <ipc_send+0x47>
  802042:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802047:	eb 2a                	jmp    802073 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  802049:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204c:	74 20                	je     80206e <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  80204e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802052:	c7 44 24 08 72 28 80 	movl   $0x802872,0x8(%esp)
  802059:	00 
  80205a:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  802061:	00 
  802062:	c7 04 24 89 28 80 00 	movl   $0x802889,(%esp)
  802069:	e8 8e e0 ff ff       	call   8000fc <_panic>


                sys_yield();
  80206e:	e8 1a ef ff ff       	call   800f8d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802073:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802077:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80207f:	8b 45 08             	mov    0x8(%ebp),%eax
  802082:	89 04 24             	mov    %eax,(%esp)
  802085:	e8 96 ec ff ff       	call   800d20 <sys_ipc_try_send>
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 bb                	js     802049 <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  80208e:	83 c4 1c             	add    $0x1c,%esp
  802091:	5b                   	pop    %ebx
  802092:	5e                   	pop    %esi
  802093:	5f                   	pop    %edi
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    

00802096 <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	56                   	push   %esi
  80209a:	53                   	push   %ebx
  80209b:	83 ec 10             	sub    $0x10,%esp
  80209e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a4:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	75 05                	jne    8020b0 <ipc_recv+0x1a>
  8020ab:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  8020b0:	89 04 24             	mov    %eax,(%esp)
  8020b3:	e8 0b ec ff ff       	call   800cc3 <sys_ipc_recv>
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 24                	js     8020e0 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  8020bc:	85 db                	test   %ebx,%ebx
  8020be:	74 0a                	je     8020ca <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  8020c0:	a1 24 50 80 00       	mov    0x805024,%eax
  8020c5:	8b 40 74             	mov    0x74(%eax),%eax
  8020c8:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  8020ca:	85 f6                	test   %esi,%esi
  8020cc:	74 0a                	je     8020d8 <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  8020ce:	a1 24 50 80 00       	mov    0x805024,%eax
  8020d3:	8b 40 78             	mov    0x78(%eax),%eax
  8020d6:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  8020d8:	a1 24 50 80 00       	mov    0x805024,%eax
  8020dd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    
	...

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	57                   	push   %edi
  8020f4:	56                   	push   %esi
  8020f5:	83 ec 10             	sub    $0x10,%esp
  8020f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8020fe:	8b 75 10             	mov    0x10(%ebp),%esi
  802101:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802104:	85 c0                	test   %eax,%eax
  802106:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802109:	75 35                	jne    802140 <__udivdi3+0x50>
  80210b:	39 fe                	cmp    %edi,%esi
  80210d:	77 61                	ja     802170 <__udivdi3+0x80>
  80210f:	85 f6                	test   %esi,%esi
  802111:	75 0b                	jne    80211e <__udivdi3+0x2e>
  802113:	b8 01 00 00 00       	mov    $0x1,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	f7 f6                	div    %esi
  80211c:	89 c6                	mov    %eax,%esi
  80211e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802121:	31 d2                	xor    %edx,%edx
  802123:	89 f8                	mov    %edi,%eax
  802125:	f7 f6                	div    %esi
  802127:	89 c7                	mov    %eax,%edi
  802129:	89 c8                	mov    %ecx,%eax
  80212b:	f7 f6                	div    %esi
  80212d:	89 c1                	mov    %eax,%ecx
  80212f:	89 fa                	mov    %edi,%edx
  802131:	89 c8                	mov    %ecx,%eax
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    
  80213a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802140:	39 f8                	cmp    %edi,%eax
  802142:	77 1c                	ja     802160 <__udivdi3+0x70>
  802144:	0f bd d0             	bsr    %eax,%edx
  802147:	83 f2 1f             	xor    $0x1f,%edx
  80214a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80214d:	75 39                	jne    802188 <__udivdi3+0x98>
  80214f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802152:	0f 86 a0 00 00 00    	jbe    8021f8 <__udivdi3+0x108>
  802158:	39 f8                	cmp    %edi,%eax
  80215a:	0f 82 98 00 00 00    	jb     8021f8 <__udivdi3+0x108>
  802160:	31 ff                	xor    %edi,%edi
  802162:	31 c9                	xor    %ecx,%ecx
  802164:	89 c8                	mov    %ecx,%eax
  802166:	89 fa                	mov    %edi,%edx
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    
  80216f:	90                   	nop
  802170:	89 d1                	mov    %edx,%ecx
  802172:	89 fa                	mov    %edi,%edx
  802174:	89 c8                	mov    %ecx,%eax
  802176:	31 ff                	xor    %edi,%edi
  802178:	f7 f6                	div    %esi
  80217a:	89 c1                	mov    %eax,%ecx
  80217c:	89 fa                	mov    %edi,%edx
  80217e:	89 c8                	mov    %ecx,%eax
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	5e                   	pop    %esi
  802184:	5f                   	pop    %edi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    
  802187:	90                   	nop
  802188:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	d3 e0                	shl    %cl,%eax
  802190:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802193:	b8 20 00 00 00       	mov    $0x20,%eax
  802198:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80219b:	89 c1                	mov    %eax,%ecx
  80219d:	d3 ea                	shr    %cl,%edx
  80219f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8021a6:	d3 e6                	shl    %cl,%esi
  8021a8:	89 c1                	mov    %eax,%ecx
  8021aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8021ad:	89 fe                	mov    %edi,%esi
  8021af:	d3 ee                	shr    %cl,%esi
  8021b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021bb:	d3 e7                	shl    %cl,%edi
  8021bd:	89 c1                	mov    %eax,%ecx
  8021bf:	d3 ea                	shr    %cl,%edx
  8021c1:	09 d7                	or     %edx,%edi
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	89 f8                	mov    %edi,%eax
  8021c7:	f7 75 ec             	divl   -0x14(%ebp)
  8021ca:	89 d6                	mov    %edx,%esi
  8021cc:	89 c7                	mov    %eax,%edi
  8021ce:	f7 65 e8             	mull   -0x18(%ebp)
  8021d1:	39 d6                	cmp    %edx,%esi
  8021d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021d6:	72 30                	jb     802208 <__udivdi3+0x118>
  8021d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	39 c2                	cmp    %eax,%edx
  8021e3:	73 05                	jae    8021ea <__udivdi3+0xfa>
  8021e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8021e8:	74 1e                	je     802208 <__udivdi3+0x118>
  8021ea:	89 f9                	mov    %edi,%ecx
  8021ec:	31 ff                	xor    %edi,%edi
  8021ee:	e9 71 ff ff ff       	jmp    802164 <__udivdi3+0x74>
  8021f3:	90                   	nop
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021ff:	e9 60 ff ff ff       	jmp    802164 <__udivdi3+0x74>
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80220b:	31 ff                	xor    %edi,%edi
  80220d:	89 c8                	mov    %ecx,%eax
  80220f:	89 fa                	mov    %edi,%edx
  802211:	83 c4 10             	add    $0x10,%esp
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
	...

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	57                   	push   %edi
  802224:	56                   	push   %esi
  802225:	83 ec 20             	sub    $0x20,%esp
  802228:	8b 55 14             	mov    0x14(%ebp),%edx
  80222b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802231:	8b 75 0c             	mov    0xc(%ebp),%esi
  802234:	85 d2                	test   %edx,%edx
  802236:	89 c8                	mov    %ecx,%eax
  802238:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80223b:	75 13                	jne    802250 <__umoddi3+0x30>
  80223d:	39 f7                	cmp    %esi,%edi
  80223f:	76 3f                	jbe    802280 <__umoddi3+0x60>
  802241:	89 f2                	mov    %esi,%edx
  802243:	f7 f7                	div    %edi
  802245:	89 d0                	mov    %edx,%eax
  802247:	31 d2                	xor    %edx,%edx
  802249:	83 c4 20             	add    $0x20,%esp
  80224c:	5e                   	pop    %esi
  80224d:	5f                   	pop    %edi
  80224e:	5d                   	pop    %ebp
  80224f:	c3                   	ret    
  802250:	39 f2                	cmp    %esi,%edx
  802252:	77 4c                	ja     8022a0 <__umoddi3+0x80>
  802254:	0f bd ca             	bsr    %edx,%ecx
  802257:	83 f1 1f             	xor    $0x1f,%ecx
  80225a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80225d:	75 51                	jne    8022b0 <__umoddi3+0x90>
  80225f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802262:	0f 87 e0 00 00 00    	ja     802348 <__umoddi3+0x128>
  802268:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226b:	29 f8                	sub    %edi,%eax
  80226d:	19 d6                	sbb    %edx,%esi
  80226f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802275:	89 f2                	mov    %esi,%edx
  802277:	83 c4 20             	add    $0x20,%esp
  80227a:	5e                   	pop    %esi
  80227b:	5f                   	pop    %edi
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    
  80227e:	66 90                	xchg   %ax,%ax
  802280:	85 ff                	test   %edi,%edi
  802282:	75 0b                	jne    80228f <__umoddi3+0x6f>
  802284:	b8 01 00 00 00       	mov    $0x1,%eax
  802289:	31 d2                	xor    %edx,%edx
  80228b:	f7 f7                	div    %edi
  80228d:	89 c7                	mov    %eax,%edi
  80228f:	89 f0                	mov    %esi,%eax
  802291:	31 d2                	xor    %edx,%edx
  802293:	f7 f7                	div    %edi
  802295:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802298:	f7 f7                	div    %edi
  80229a:	eb a9                	jmp    802245 <__umoddi3+0x25>
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 20             	add    $0x20,%esp
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    
  8022ab:	90                   	nop
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022b4:	d3 e2                	shl    %cl,%edx
  8022b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8022be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8022c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8022c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	d3 ea                	shr    %cl,%edx
  8022cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8022d3:	d3 e7                	shl    %cl,%edi
  8022d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022dc:	89 f2                	mov    %esi,%edx
  8022de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8022e1:	89 c7                	mov    %eax,%edi
  8022e3:	d3 ea                	shr    %cl,%edx
  8022e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8022ec:	89 c2                	mov    %eax,%edx
  8022ee:	d3 e6                	shl    %cl,%esi
  8022f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022f4:	d3 ea                	shr    %cl,%edx
  8022f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022fa:	09 d6                	or     %edx,%esi
  8022fc:	89 f0                	mov    %esi,%eax
  8022fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802301:	d3 e7                	shl    %cl,%edi
  802303:	89 f2                	mov    %esi,%edx
  802305:	f7 75 f4             	divl   -0xc(%ebp)
  802308:	89 d6                	mov    %edx,%esi
  80230a:	f7 65 e8             	mull   -0x18(%ebp)
  80230d:	39 d6                	cmp    %edx,%esi
  80230f:	72 2b                	jb     80233c <__umoddi3+0x11c>
  802311:	39 c7                	cmp    %eax,%edi
  802313:	72 23                	jb     802338 <__umoddi3+0x118>
  802315:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802319:	29 c7                	sub    %eax,%edi
  80231b:	19 d6                	sbb    %edx,%esi
  80231d:	89 f0                	mov    %esi,%eax
  80231f:	89 f2                	mov    %esi,%edx
  802321:	d3 ef                	shr    %cl,%edi
  802323:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802327:	d3 e0                	shl    %cl,%eax
  802329:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80232d:	09 f8                	or     %edi,%eax
  80232f:	d3 ea                	shr    %cl,%edx
  802331:	83 c4 20             	add    $0x20,%esp
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	39 d6                	cmp    %edx,%esi
  80233a:	75 d9                	jne    802315 <__umoddi3+0xf5>
  80233c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80233f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802342:	eb d1                	jmp    802315 <__umoddi3+0xf5>
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	0f 82 18 ff ff ff    	jb     802268 <__umoddi3+0x48>
  802350:	e9 1d ff ff ff       	jmp    802272 <__umoddi3+0x52>
