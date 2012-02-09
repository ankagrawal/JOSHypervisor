
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
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
	cprintf("hello, world\n");
  80003a:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  800041:	e8 ff 00 00 00       	call   800145 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 24 50 80 00       	mov    0x805024,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 0e 1c 80 00 	movl   $0x801c0e,(%esp)
  800059:	e8 e7 00 00 00       	call   800145 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800072:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  800079:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  80007c:	e8 d0 0e 00 00       	call   800f51 <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 f6                	test   %esi,%esi
  800095:	7e 07                	jle    80009e <libmain+0x3e>
		binaryname = argv[0];
  800097:	8b 03                	mov    (%ebx),%eax
  800099:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  80009e:	c7 04 24 25 1c 80 00 	movl   $0x801c25,(%esp)
  8000a5:	e8 9b 00 00 00       	call   800145 <cprintf>
	umain(argc, argv);
  8000aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ae:	89 34 24             	mov    %esi,(%esp)
  8000b1:	e8 7e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b6:	e8 0d 00 00 00       	call   8000c8 <exit>
}
  8000bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000be:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c1:	89 ec                	mov    %ebp,%esp
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ce:	e8 f8 13 00 00       	call   8014cb <close_all>
	sys_env_destroy(0);
  8000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000da:	e8 a6 0e 00 00       	call   800f85 <sys_env_destroy>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f4:	00 00 00 
	b.cnt = 0;
  8000f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800101:	8b 45 0c             	mov    0xc(%ebp),%eax
  800104:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800108:	8b 45 08             	mov    0x8(%ebp),%eax
  80010b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800115:	89 44 24 04          	mov    %eax,0x4(%esp)
  800119:	c7 04 24 5f 01 80 00 	movl   $0x80015f,(%esp)
  800120:	e8 d8 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800125:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800135:	89 04 24             	mov    %eax,(%esp)
  800138:	e8 e3 0a 00 00       	call   800c20 <sys_cputs>

	return b.cnt;
}
  80013d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80014b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	8b 45 08             	mov    0x8(%ebp),%eax
  800155:	89 04 24             	mov    %eax,(%esp)
  800158:	e8 87 ff ff ff       	call   8000e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	53                   	push   %ebx
  800163:	83 ec 14             	sub    $0x14,%esp
  800166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800169:	8b 03                	mov    (%ebx),%eax
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800172:	83 c0 01             	add    $0x1,%eax
  800175:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800177:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017c:	75 19                	jne    800197 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800185:	00 
  800186:	8d 43 08             	lea    0x8(%ebx),%eax
  800189:	89 04 24             	mov    %eax,(%esp)
  80018c:	e8 8f 0a 00 00       	call   800c20 <sys_cputs>
		b->idx = 0;
  800191:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	83 c4 14             	add    $0x14,%esp
  80019e:	5b                   	pop    %ebx
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    
	...

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 4c             	sub    $0x4c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001db:	39 d1                	cmp    %edx,%ecx
  8001dd:	72 15                	jb     8001f4 <printnum+0x44>
  8001df:	77 07                	ja     8001e8 <printnum+0x38>
  8001e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e4:	39 d0                	cmp    %edx,%eax
  8001e6:	76 0c                	jbe    8001f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	85 db                	test   %ebx,%ebx
  8001ed:	8d 76 00             	lea    0x0(%esi),%esi
  8001f0:	7f 61                	jg     800253 <printnum+0xa3>
  8001f2:	eb 70                	jmp    800264 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800207:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80020b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80020e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800211:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800214:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800229:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022d:	e8 5e 17 00 00       	call   801990 <__udivdi3>
  800232:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800235:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	89 54 24 04          	mov    %edx,0x4(%esp)
  800247:	89 f2                	mov    %esi,%edx
  800249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024c:	e8 5f ff ff ff       	call   8001b0 <printnum>
  800251:	eb 11                	jmp    800264 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	89 74 24 04          	mov    %esi,0x4(%esp)
  800257:	89 3c 24             	mov    %edi,(%esp)
  80025a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025d:	83 eb 01             	sub    $0x1,%ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f ef                	jg     800253 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 74 24 04          	mov    %esi,0x4(%esp)
  800268:	8b 74 24 04          	mov    0x4(%esp),%esi
  80026c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80027e:	89 14 24             	mov    %edx,(%esp)
  800281:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800284:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800288:	e8 33 18 00 00       	call   801ac0 <__umoddi3>
  80028d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800291:	0f be 80 4e 1c 80 00 	movsbl 0x801c4e(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 4c             	add    $0x4c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ef:	73 0a                	jae    8002fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f4:	88 0a                	mov    %cl,(%edx)
  8002f6:	83 c2 01             	add    $0x1,%edx
  8002f9:	89 10                	mov    %edx,(%eax)
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 5c             	sub    $0x5c,%esp
  800306:	8b 7d 08             	mov    0x8(%ebp),%edi
  800309:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80030f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800316:	eb 11                	jmp    800329 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800318:	85 c0                	test   %eax,%eax
  80031a:	0f 84 02 04 00 00    	je     800722 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800320:	89 74 24 04          	mov    %esi,0x4(%esp)
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	0f b6 03             	movzbl (%ebx),%eax
  80032c:	83 c3 01             	add    $0x1,%ebx
  80032f:	83 f8 25             	cmp    $0x25,%eax
  800332:	75 e4                	jne    800318 <vprintfmt+0x1b>
  800334:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800338:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800346:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	eb 06                	jmp    80035a <vprintfmt+0x5d>
  800354:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800358:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	0f b6 13             	movzbl (%ebx),%edx
  80035d:	0f b6 c2             	movzbl %dl,%eax
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	8d 43 01             	lea    0x1(%ebx),%eax
  800366:	83 ea 23             	sub    $0x23,%edx
  800369:	80 fa 55             	cmp    $0x55,%dl
  80036c:	0f 87 93 03 00 00    	ja     800705 <vprintfmt+0x408>
  800372:	0f b6 d2             	movzbl %dl,%edx
  800375:	ff 24 95 a0 1d 80 00 	jmp    *0x801da0(,%edx,4)
  80037c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800380:	eb d6                	jmp    800358 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800382:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800385:	83 ea 30             	sub    $0x30,%edx
  800388:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80038b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800391:	83 fb 09             	cmp    $0x9,%ebx
  800394:	77 4c                	ja     8003e2 <vprintfmt+0xe5>
  800396:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800399:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80039f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003a2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003a6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003a9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003ac:	83 fb 09             	cmp    $0x9,%ebx
  8003af:	76 eb                	jbe    80039c <vprintfmt+0x9f>
  8003b1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003b7:	eb 29                	jmp    8003e2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003bf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003c2:	8b 12                	mov    (%edx),%edx
  8003c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003c7:	eb 19                	jmp    8003e2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003cc:	c1 fa 1f             	sar    $0x1f,%edx
  8003cf:	f7 d2                	not    %edx
  8003d1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003d4:	eb 82                	jmp    800358 <vprintfmt+0x5b>
  8003d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003dd:	e9 76 ff ff ff       	jmp    800358 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e6:	0f 89 6c ff ff ff    	jns    800358 <vprintfmt+0x5b>
  8003ec:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003f2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003f5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003f8:	e9 5b ff ff ff       	jmp    800358 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800400:	e9 53 ff ff ff       	jmp    800358 <vprintfmt+0x5b>
  800405:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	89 74 24 04          	mov    %esi,0x4(%esp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	ff d7                	call   *%edi
  80041c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80041f:	e9 05 ff ff ff       	jmp    800329 <vprintfmt+0x2c>
  800424:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 50 04             	lea    0x4(%eax),%edx
  80042d:	89 55 14             	mov    %edx,0x14(%ebp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	89 c2                	mov    %eax,%edx
  800434:	c1 fa 1f             	sar    $0x1f,%edx
  800437:	31 d0                	xor    %edx,%eax
  800439:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80043b:	83 f8 0f             	cmp    $0xf,%eax
  80043e:	7f 0b                	jg     80044b <vprintfmt+0x14e>
  800440:	8b 14 85 00 1f 80 00 	mov    0x801f00(,%eax,4),%edx
  800447:	85 d2                	test   %edx,%edx
  800449:	75 20                	jne    80046b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80044b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044f:	c7 44 24 08 5f 1c 80 	movl   $0x801c5f,0x8(%esp)
  800456:	00 
  800457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045b:	89 3c 24             	mov    %edi,(%esp)
  80045e:	e8 47 03 00 00       	call   8007aa <printfmt>
  800463:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800466:	e9 be fe ff ff       	jmp    800329 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80046b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046f:	c7 44 24 08 68 1c 80 	movl   $0x801c68,0x8(%esp)
  800476:	00 
  800477:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047b:	89 3c 24             	mov    %edi,(%esp)
  80047e:	e8 27 03 00 00       	call   8007aa <printfmt>
  800483:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800486:	e9 9e fe ff ff       	jmp    800329 <vprintfmt+0x2c>
  80048b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048e:	89 c3                	mov    %eax,%ebx
  800490:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800496:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	75 07                	jne    8004b2 <vprintfmt+0x1b5>
  8004ab:	c7 45 e0 6b 1c 80 00 	movl   $0x801c6b,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004b2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004b6:	7e 06                	jle    8004be <vprintfmt+0x1c1>
  8004b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bc:	75 13                	jne    8004d1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c1:	0f be 02             	movsbl (%edx),%eax
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	0f 85 99 00 00 00    	jne    800565 <vprintfmt+0x268>
  8004cc:	e9 86 00 00 00       	jmp    800557 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d8:	89 0c 24             	mov    %ecx,(%esp)
  8004db:	e8 1b 03 00 00       	call   8007fb <strnlen>
  8004e0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e3:	29 c2                	sub    %eax,%edx
  8004e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	7e d2                	jle    8004be <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004ec:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8004f0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004f3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004f6:	89 d3                	mov    %edx,%ebx
  8004f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	83 eb 01             	sub    $0x1,%ebx
  800507:	85 db                	test   %ebx,%ebx
  800509:	7f ed                	jg     8004f8 <vprintfmt+0x1fb>
  80050b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80050e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800515:	eb a7                	jmp    8004be <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 18                	je     800535 <vprintfmt+0x238>
  80051d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800520:	83 fa 5e             	cmp    $0x5e,%edx
  800523:	76 10                	jbe    800535 <vprintfmt+0x238>
					putch('?', putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800530:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800533:	eb 0a                	jmp    80053f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800535:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800543:	0f be 03             	movsbl (%ebx),%eax
  800546:	85 c0                	test   %eax,%eax
  800548:	74 05                	je     80054f <vprintfmt+0x252>
  80054a:	83 c3 01             	add    $0x1,%ebx
  80054d:	eb 29                	jmp    800578 <vprintfmt+0x27b>
  80054f:	89 fe                	mov    %edi,%esi
  800551:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800554:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055b:	7f 2e                	jg     80058b <vprintfmt+0x28e>
  80055d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800560:	e9 c4 fd ff ff       	jmp    800329 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800565:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800568:	83 c2 01             	add    $0x1,%edx
  80056b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80056e:	89 f7                	mov    %esi,%edi
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800576:	89 d3                	mov    %edx,%ebx
  800578:	85 f6                	test   %esi,%esi
  80057a:	78 9b                	js     800517 <vprintfmt+0x21a>
  80057c:	83 ee 01             	sub    $0x1,%esi
  80057f:	79 96                	jns    800517 <vprintfmt+0x21a>
  800581:	89 fe                	mov    %edi,%esi
  800583:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800586:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800589:	eb cc                	jmp    800557 <vprintfmt+0x25a>
  80058b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80058e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800591:	89 74 24 04          	mov    %esi,0x4(%esp)
  800595:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059e:	83 eb 01             	sub    $0x1,%ebx
  8005a1:	85 db                	test   %ebx,%ebx
  8005a3:	7f ec                	jg     800591 <vprintfmt+0x294>
  8005a5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005a8:	e9 7c fd ff ff       	jmp    800329 <vprintfmt+0x2c>
  8005ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 f9 01             	cmp    $0x1,%ecx
  8005b3:	7e 16                	jle    8005cb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 08             	lea    0x8(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c9:	eb 32                	jmp    8005fd <vprintfmt+0x300>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	74 18                	je     8005e7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 c1                	mov    %eax,%ecx
  8005df:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e5:	eb 16                	jmp    8005fd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c2                	mov    %eax,%edx
  8005f7:	c1 fa 1f             	sar    $0x1f,%edx
  8005fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800600:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800603:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800608:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060c:	0f 89 b1 00 00 00    	jns    8006c3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800612:	89 74 24 04          	mov    %esi,0x4(%esp)
  800616:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061d:	ff d7                	call   *%edi
				num = -(long long) num;
  80061f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800622:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800625:	f7 d8                	neg    %eax
  800627:	83 d2 00             	adc    $0x0,%edx
  80062a:	f7 da                	neg    %edx
  80062c:	e9 92 00 00 00       	jmp    8006c3 <vprintfmt+0x3c6>
  800631:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800634:	89 ca                	mov    %ecx,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 68 fc ff ff       	call   8002a6 <getuint>
  80063e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800643:	eb 7e                	jmp    8006c3 <vprintfmt+0x3c6>
  800645:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800648:	89 ca                	mov    %ecx,%edx
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 54 fc ff ff       	call   8002a6 <getuint>
			if ((long long) num < 0) {
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800658:	bb 08 00 00 00       	mov    $0x8,%ebx
  80065d:	85 d2                	test   %edx,%edx
  80065f:	79 62                	jns    8006c3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066c:	ff d7                	call   *%edi
				num = -(long long) num;
  80066e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800671:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800674:	f7 d8                	neg    %eax
  800676:	83 d2 00             	adc    $0x0,%edx
  800679:	f7 da                	neg    %edx
  80067b:	eb 46                	jmp    8006c3 <vprintfmt+0x3c6>
  80067d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800680:	89 74 24 04          	mov    %esi,0x4(%esp)
  800684:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068b:	ff d7                	call   *%edi
			putch('x', putdat);
  80068d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800691:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800698:	ff d7                	call   *%edi
			num = (unsigned long long)
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006aa:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006af:	eb 12                	jmp    8006c3 <vprintfmt+0x3c6>
  8006b1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b4:	89 ca                	mov    %ecx,%edx
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	e8 e8 fb ff ff       	call   8002a6 <getuint>
  8006be:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006c7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dd:	89 f2                	mov    %esi,%edx
  8006df:	89 f8                	mov    %edi,%eax
  8006e1:	e8 ca fa ff ff       	call   8001b0 <printnum>
  8006e6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006e9:	e9 3b fc ff ff       	jmp    800329 <vprintfmt+0x2c>
  8006ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006f1:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f8:	89 14 24             	mov    %edx,(%esp)
  8006fb:	ff d7                	call   *%edi
  8006fd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800700:	e9 24 fc ff ff       	jmp    800329 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800705:	89 74 24 04          	mov    %esi,0x4(%esp)
  800709:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800710:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800715:	80 38 25             	cmpb   $0x25,(%eax)
  800718:	0f 84 0b fc ff ff    	je     800329 <vprintfmt+0x2c>
  80071e:	89 c3                	mov    %eax,%ebx
  800720:	eb f0                	jmp    800712 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800722:	83 c4 5c             	add    $0x5c,%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 28             	sub    $0x28,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800736:	85 c0                	test   %eax,%eax
  800738:	74 04                	je     80073e <vsnprintf+0x14>
  80073a:	85 d2                	test   %edx,%edx
  80073c:	7f 07                	jg     800745 <vsnprintf+0x1b>
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800743:	eb 3b                	jmp    800780 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800745:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800748:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80074c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80074f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075d:	8b 45 10             	mov    0x10(%ebp),%eax
  800760:	89 44 24 08          	mov    %eax,0x8(%esp)
  800764:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  800772:	e8 86 fb ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800777:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80078b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078f:	8b 45 10             	mov    0x10(%ebp),%eax
  800792:	89 44 24 08          	mov    %eax,0x8(%esp)
  800796:	8b 45 0c             	mov    0xc(%ebp),%eax
  800799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	e8 82 ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	89 04 24             	mov    %eax,(%esp)
  8007cb:	e8 2d fb ff ff       	call   8002fd <vprintfmt>
	va_end(ap);
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 09                	je     8007f9 <strlen+0x19>
		n++;
  8007f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	75 f7                	jne    8007f0 <strlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 19                	je     800822 <strnlen+0x27>
  800809:	80 3b 00             	cmpb   $0x0,(%ebx)
  80080c:	74 14                	je     800822 <strnlen+0x27>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800813:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800816:	39 c8                	cmp    %ecx,%eax
  800818:	74 0d                	je     800827 <strnlen+0x2c>
  80081a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80081e:	75 f3                	jne    800813 <strnlen+0x18>
  800820:	eb 05                	jmp    800827 <strnlen+0x2c>
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800834:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80083d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	84 c9                	test   %cl,%cl
  800845:	75 f2                	jne    800839 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	85 f6                	test   %esi,%esi
  80085a:	74 18                	je     800874 <strncpy+0x2a>
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800861:	0f b6 1a             	movzbl (%edx),%ebx
  800864:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 3a 01             	cmpb   $0x1,(%edx)
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	39 ce                	cmp    %ecx,%esi
  800872:	77 ed                	ja     800861 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	89 f0                	mov    %esi,%eax
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	74 27                	je     8008b3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80088c:	83 e9 01             	sub    $0x1,%ecx
  80088f:	74 1d                	je     8008ae <strlcpy+0x36>
  800891:	0f b6 1a             	movzbl (%edx),%ebx
  800894:	84 db                	test   %bl,%bl
  800896:	74 16                	je     8008ae <strlcpy+0x36>
			*dst++ = *src++;
  800898:	88 18                	mov    %bl,(%eax)
  80089a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089d:	83 e9 01             	sub    $0x1,%ecx
  8008a0:	74 0e                	je     8008b0 <strlcpy+0x38>
			*dst++ = *src++;
  8008a2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	0f b6 1a             	movzbl (%edx),%ebx
  8008a8:	84 db                	test   %bl,%bl
  8008aa:	75 ec                	jne    800898 <strlcpy+0x20>
  8008ac:	eb 02                	jmp    8008b0 <strlcpy+0x38>
  8008ae:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b0:	c6 00 00             	movb   $0x0,(%eax)
  8008b3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 15                	je     8008de <strcmp+0x25>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	75 11                	jne    8008de <strcmp+0x25>
		p++, q++;
  8008cd:	83 c1 01             	add    $0x1,%ecx
  8008d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d3:	0f b6 01             	movzbl (%ecx),%eax
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 04                	je     8008de <strcmp+0x25>
  8008da:	3a 02                	cmp    (%edx),%al
  8008dc:	74 ef                	je     8008cd <strcmp+0x14>
  8008de:	0f b6 c0             	movzbl %al,%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	53                   	push   %ebx
  8008ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	74 23                	je     80091c <strncmp+0x34>
  8008f9:	0f b6 1a             	movzbl (%edx),%ebx
  8008fc:	84 db                	test   %bl,%bl
  8008fe:	74 24                	je     800924 <strncmp+0x3c>
  800900:	3a 19                	cmp    (%ecx),%bl
  800902:	75 20                	jne    800924 <strncmp+0x3c>
  800904:	83 e8 01             	sub    $0x1,%eax
  800907:	74 13                	je     80091c <strncmp+0x34>
		n--, p++, q++;
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090f:	0f b6 1a             	movzbl (%edx),%ebx
  800912:	84 db                	test   %bl,%bl
  800914:	74 0e                	je     800924 <strncmp+0x3c>
  800916:	3a 19                	cmp    (%ecx),%bl
  800918:	74 ea                	je     800904 <strncmp+0x1c>
  80091a:	eb 08                	jmp    800924 <strncmp+0x3c>
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800924:	0f b6 02             	movzbl (%edx),%eax
  800927:	0f b6 11             	movzbl (%ecx),%edx
  80092a:	29 d0                	sub    %edx,%eax
  80092c:	eb f3                	jmp    800921 <strncmp+0x39>

0080092e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800938:	0f b6 10             	movzbl (%eax),%edx
  80093b:	84 d2                	test   %dl,%dl
  80093d:	74 15                	je     800954 <strchr+0x26>
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	75 07                	jne    80094a <strchr+0x1c>
  800943:	eb 14                	jmp    800959 <strchr+0x2b>
  800945:	38 ca                	cmp    %cl,%dl
  800947:	90                   	nop
  800948:	74 0f                	je     800959 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f1                	jne    800945 <strchr+0x17>
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 18                	je     800984 <strfind+0x29>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 0a                	jne    80097a <strfind+0x1f>
  800970:	eb 12                	jmp    800984 <strfind+0x29>
  800972:	38 ca                	cmp    %cl,%dl
  800974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800978:	74 0a                	je     800984 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 ee                	jne    800972 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 0c             	sub    $0xc,%esp
  80098c:	89 1c 24             	mov    %ebx,(%esp)
  80098f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800993:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800997:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 30                	je     8009d4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 25                	jne    8009d1 <memset+0x4b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 20                	jne    8009d1 <memset+0x4b>
		c &= 0xFF;
  8009b1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b4:	89 d3                	mov    %edx,%ebx
  8009b6:	c1 e3 08             	shl    $0x8,%ebx
  8009b9:	89 d6                	mov    %edx,%esi
  8009bb:	c1 e6 18             	shl    $0x18,%esi
  8009be:	89 d0                	mov    %edx,%eax
  8009c0:	c1 e0 10             	shl    $0x10,%eax
  8009c3:	09 f0                	or     %esi,%eax
  8009c5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009c7:	09 d8                	or     %ebx,%eax
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
  8009cc:	fc                   	cld    
  8009cd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cf:	eb 03                	jmp    8009d4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	8b 1c 24             	mov    (%esp),%ebx
  8009d9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009dd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009e1:	89 ec                	mov    %ebp,%esp
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	89 34 24             	mov    %esi,(%esp)
  8009ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009fb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009fd:	39 c6                	cmp    %eax,%esi
  8009ff:	73 35                	jae    800a36 <memmove+0x51>
  800a01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a04:	39 d0                	cmp    %edx,%eax
  800a06:	73 2e                	jae    800a36 <memmove+0x51>
		s += n;
		d += n;
  800a08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0a:	f6 c2 03             	test   $0x3,%dl
  800a0d:	75 1b                	jne    800a2a <memmove+0x45>
  800a0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a15:	75 13                	jne    800a2a <memmove+0x45>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0e                	jne    800a2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a1c:	83 ef 04             	sub    $0x4,%edi
  800a1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a22:	c1 e9 02             	shr    $0x2,%ecx
  800a25:	fd                   	std    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	eb 09                	jmp    800a33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a30:	fd                   	std    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	eb 20                	jmp    800a56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3c:	75 15                	jne    800a53 <memmove+0x6e>
  800a3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a44:	75 0d                	jne    800a53 <memmove+0x6e>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 08                	jne    800a53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
  800a4e:	fc                   	cld    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	eb 03                	jmp    800a56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a53:	fc                   	cld    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a56:	8b 34 24             	mov    (%esp),%esi
  800a59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a5d:	89 ec                	mov    %ebp,%esp
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	89 04 24             	mov    %eax,(%esp)
  800a7b:	e8 65 ff ff ff       	call   8009e5 <memmove>
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 36                	je     800acb <memcmp+0x49>
		if (*s1 != *s2)
  800a95:	0f b6 06             	movzbl (%esi),%eax
  800a98:	0f b6 1f             	movzbl (%edi),%ebx
  800a9b:	38 d8                	cmp    %bl,%al
  800a9d:	74 20                	je     800abf <memcmp+0x3d>
  800a9f:	eb 14                	jmp    800ab5 <memcmp+0x33>
  800aa1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800aa6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	83 e9 01             	sub    $0x1,%ecx
  800ab1:	38 d8                	cmp    %bl,%al
  800ab3:	74 12                	je     800ac7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 db             	movzbl %bl,%ebx
  800abb:	29 d8                	sub    %ebx,%eax
  800abd:	eb 11                	jmp    800ad0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	83 e9 01             	sub    $0x1,%ecx
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	85 c9                	test   %ecx,%ecx
  800ac9:	75 d6                	jne    800aa1 <memcmp+0x1f>
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800adb:	89 c2                	mov    %eax,%edx
  800add:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae0:	39 d0                	cmp    %edx,%eax
  800ae2:	73 15                	jae    800af9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ae8:	38 08                	cmp    %cl,(%eax)
  800aea:	75 06                	jne    800af2 <memfind+0x1d>
  800aec:	eb 0b                	jmp    800af9 <memfind+0x24>
  800aee:	38 08                	cmp    %cl,(%eax)
  800af0:	74 07                	je     800af9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	39 c2                	cmp    %eax,%edx
  800af7:	77 f5                	ja     800aee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 04             	sub    $0x4,%esp
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 02             	movzbl (%edx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 04                	je     800b15 <strtol+0x1a>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	75 0e                	jne    800b23 <strtol+0x28>
		s++;
  800b15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	0f b6 02             	movzbl (%edx),%eax
  800b1b:	3c 20                	cmp    $0x20,%al
  800b1d:	74 f6                	je     800b15 <strtol+0x1a>
  800b1f:	3c 09                	cmp    $0x9,%al
  800b21:	74 f2                	je     800b15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b23:	3c 2b                	cmp    $0x2b,%al
  800b25:	75 0c                	jne    800b33 <strtol+0x38>
		s++;
  800b27:	83 c2 01             	add    $0x1,%edx
  800b2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b31:	eb 15                	jmp    800b48 <strtol+0x4d>
	else if (*s == '-')
  800b33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 0a                	jne    800b48 <strtol+0x4d>
		s++, neg = 1;
  800b3e:	83 c2 01             	add    $0x1,%edx
  800b41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	0f 94 c0             	sete   %al
  800b4d:	74 05                	je     800b54 <strtol+0x59>
  800b4f:	83 fb 10             	cmp    $0x10,%ebx
  800b52:	75 18                	jne    800b6c <strtol+0x71>
  800b54:	80 3a 30             	cmpb   $0x30,(%edx)
  800b57:	75 13                	jne    800b6c <strtol+0x71>
  800b59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5d:	8d 76 00             	lea    0x0(%esi),%esi
  800b60:	75 0a                	jne    800b6c <strtol+0x71>
		s += 2, base = 16;
  800b62:	83 c2 02             	add    $0x2,%edx
  800b65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6a:	eb 15                	jmp    800b81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	84 c0                	test   %al,%al
  800b6e:	66 90                	xchg   %ax,%ax
  800b70:	74 0f                	je     800b81 <strtol+0x86>
  800b72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b77:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7a:	75 05                	jne    800b81 <strtol+0x86>
		s++, base = 8;
  800b7c:	83 c2 01             	add    $0x1,%edx
  800b7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b88:	0f b6 0a             	movzbl (%edx),%ecx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b90:	80 fb 09             	cmp    $0x9,%bl
  800b93:	77 08                	ja     800b9d <strtol+0xa2>
			dig = *s - '0';
  800b95:	0f be c9             	movsbl %cl,%ecx
  800b98:	83 e9 30             	sub    $0x30,%ecx
  800b9b:	eb 1e                	jmp    800bbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ba0:	80 fb 19             	cmp    $0x19,%bl
  800ba3:	77 08                	ja     800bad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ba5:	0f be c9             	movsbl %cl,%ecx
  800ba8:	83 e9 57             	sub    $0x57,%ecx
  800bab:	eb 0e                	jmp    800bbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 15                	ja     800bca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bbb:	39 f1                	cmp    %esi,%ecx
  800bbd:	7d 0b                	jge    800bca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bbf:	83 c2 01             	add    $0x1,%edx
  800bc2:	0f af c6             	imul   %esi,%eax
  800bc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bc8:	eb be                	jmp    800b88 <strtol+0x8d>
  800bca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd0:	74 05                	je     800bd7 <strtol+0xdc>
		*endptr = (char *) s;
  800bd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bdb:	74 04                	je     800be1 <strtol+0xe6>
  800bdd:	89 c8                	mov    %ecx,%eax
  800bdf:	f7 d8                	neg    %eax
}
  800be1:	83 c4 04             	add    $0x4,%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
  800be9:	00 00                	add    %al,(%eax)
	...

00800bec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	89 1c 24             	mov    %ebx,(%esp)
  800bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 01 00 00 00       	mov    $0x1,%eax
  800c07:	89 d1                	mov    %edx,%ecx
  800c09:	89 d3                	mov    %edx,%ebx
  800c0b:	89 d7                	mov    %edx,%edi
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c11:	8b 1c 24             	mov    (%esp),%ebx
  800c14:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c18:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c1c:	89 ec                	mov    %ebp,%esp
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	89 1c 24             	mov    %ebx,(%esp)
  800c29:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c2d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 c3                	mov    %eax,%ebx
  800c3e:	89 c7                	mov    %eax,%edi
  800c40:	89 c6                	mov    %eax,%esi
  800c42:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c44:	8b 1c 24             	mov    (%esp),%ebx
  800c47:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c4b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c4f:	89 ec                	mov    %ebp,%esp
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 38             	sub    $0x38,%esp
  800c59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c67:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 cb                	mov    %ecx,%ebx
  800c71:	89 cf                	mov    %ecx,%edi
  800c73:	89 ce                	mov    %ecx,%esi
  800c75:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 28                	jle    800ca3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800c86:	00 
  800c87:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800c96:	00 
  800c97:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800c9e:	e8 c9 0b 00 00       	call   80186c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ca3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cac:	89 ec                	mov    %ebp,%esp
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	89 1c 24             	mov    %ebx,(%esp)
  800cb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cbd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd9:	8b 1c 24             	mov    (%esp),%ebx
  800cdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ce0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce4:	89 ec                	mov    %ebp,%esp
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 38             	sub    $0x38,%esp
  800cee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 28                	jle    800d39 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d15:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800d24:	00 
  800d25:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d2c:	00 
  800d2d:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800d34:	e8 33 0b 00 00       	call   80186c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d39:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d42:	89 ec                	mov    %ebp,%esp
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 38             	sub    $0x38,%esp
  800d4c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d52:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 28                	jle    800d97 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d73:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800d82:	00 
  800d83:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d8a:	00 
  800d8b:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800d92:	e8 d5 0a 00 00       	call   80186c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da0:	89 ec                	mov    %ebp,%esp
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 38             	sub    $0x38,%esp
  800daa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800df0:	e8 77 0a 00 00       	call   80186c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfe:	89 ec                	mov    %ebp,%esp
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 38             	sub    $0x38,%esp
  800e08:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e16:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 df                	mov    %ebx,%edi
  800e23:	89 de                	mov    %ebx,%esi
  800e25:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 28                	jle    800e53 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e36:	00 
  800e37:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800e4e:	e8 19 0a 00 00       	call   80186c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5c:	89 ec                	mov    %ebp,%esp
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 38             	sub    $0x38,%esp
  800e66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e74:	8b 75 18             	mov    0x18(%ebp),%esi
  800e77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 28                	jle    800eb1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800eac:	e8 bb 09 00 00       	call   80186c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eb1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eba:	89 ec                	mov    %ebp,%esp
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 38             	sub    $0x38,%esp
  800ec4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eca:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	be 00 00 00 00       	mov    $0x0,%esi
  800ed2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 f7                	mov    %esi,%edi
  800ee2:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 28                	jle    800f10 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eec:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800efb:	00 
  800efc:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f03:	00 
  800f04:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800f0b:	e8 5c 09 00 00       	call   80186c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f10:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f13:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f16:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f19:	89 ec                	mov    %ebp,%esp
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	89 1c 24             	mov    %ebx,(%esp)
  800f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f38:	89 d1                	mov    %edx,%ecx
  800f3a:	89 d3                	mov    %edx,%ebx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 d6                	mov    %edx,%esi
  800f40:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f42:	8b 1c 24             	mov    (%esp),%ebx
  800f45:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f49:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f4d:	89 ec                	mov    %ebp,%esp
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	89 1c 24             	mov    %ebx,(%esp)
  800f5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6c:	89 d1                	mov    %edx,%ecx
  800f6e:	89 d3                	mov    %edx,%ebx
  800f70:	89 d7                	mov    %edx,%edi
  800f72:	89 d6                	mov    %edx,%esi
  800f74:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f76:	8b 1c 24             	mov    (%esp),%ebx
  800f79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f81:	89 ec                	mov    %ebp,%esp
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 38             	sub    $0x38,%esp
  800f8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f91:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f99:	b8 03 00 00 00       	mov    $0x3,%eax
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	89 cb                	mov    %ecx,%ebx
  800fa3:	89 cf                	mov    %ecx,%edi
  800fa5:	89 ce                	mov    %ecx,%esi
  800fa7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 28                	jle    800fd5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 08 5f 1f 80 	movl   $0x801f5f,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  800fd0:	e8 97 08 00 00       	call   80186c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fd5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fde:	89 ec                	mov    %ebp,%esp
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    
	...

00800ff0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	05 00 00 00 30       	add    $0x30000000,%eax
  800ffb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
  801009:	89 04 24             	mov    %eax,(%esp)
  80100c:	e8 df ff ff ff       	call   800ff0 <fd2num>
  801011:	05 20 00 0d 00       	add    $0xd0020,%eax
  801016:	c1 e0 0c             	shl    $0xc,%eax
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801024:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801029:	a8 01                	test   $0x1,%al
  80102b:	74 36                	je     801063 <fd_alloc+0x48>
  80102d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801032:	a8 01                	test   $0x1,%al
  801034:	74 2d                	je     801063 <fd_alloc+0x48>
  801036:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80103b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801040:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801045:	89 c3                	mov    %eax,%ebx
  801047:	89 c2                	mov    %eax,%edx
  801049:	c1 ea 16             	shr    $0x16,%edx
  80104c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 14                	je     801068 <fd_alloc+0x4d>
  801054:	89 c2                	mov    %eax,%edx
  801056:	c1 ea 0c             	shr    $0xc,%edx
  801059:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80105c:	f6 c2 01             	test   $0x1,%dl
  80105f:	75 10                	jne    801071 <fd_alloc+0x56>
  801061:	eb 05                	jmp    801068 <fd_alloc+0x4d>
  801063:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801068:	89 1f                	mov    %ebx,(%edi)
  80106a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80106f:	eb 17                	jmp    801088 <fd_alloc+0x6d>
  801071:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801076:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80107b:	75 c8                	jne    801045 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80107d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801083:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	83 f8 1f             	cmp    $0x1f,%eax
  801096:	77 36                	ja     8010ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801098:	05 00 00 0d 00       	add    $0xd0000,%eax
  80109d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	c1 ea 16             	shr    $0x16,%edx
  8010a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ac:	f6 c2 01             	test   $0x1,%dl
  8010af:	74 1d                	je     8010ce <fd_lookup+0x41>
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	c1 ea 0c             	shr    $0xc,%edx
  8010b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bd:	f6 c2 01             	test   $0x1,%dl
  8010c0:	74 0c                	je     8010ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c5:	89 02                	mov    %eax,(%edx)
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010cc:	eb 05                	jmp    8010d3 <fd_lookup+0x46>
  8010ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	89 04 24             	mov    %eax,(%esp)
  8010e8:	e8 a0 ff ff ff       	call   80108d <fd_lookup>
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 0e                	js     8010ff <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f7:	89 50 04             	mov    %edx,0x4(%eax)
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
  801106:	83 ec 10             	sub    $0x10,%esp
  801109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80110f:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801114:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801119:	be 0c 20 80 00       	mov    $0x80200c,%esi
		if (devtab[i]->dev_id == dev_id) {
  80111e:	39 08                	cmp    %ecx,(%eax)
  801120:	75 10                	jne    801132 <dev_lookup+0x31>
  801122:	eb 04                	jmp    801128 <dev_lookup+0x27>
  801124:	39 08                	cmp    %ecx,(%eax)
  801126:	75 0a                	jne    801132 <dev_lookup+0x31>
			*dev = devtab[i];
  801128:	89 03                	mov    %eax,(%ebx)
  80112a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80112f:	90                   	nop
  801130:	eb 31                	jmp    801163 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801132:	83 c2 01             	add    $0x1,%edx
  801135:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801138:	85 c0                	test   %eax,%eax
  80113a:	75 e8                	jne    801124 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  80113c:	a1 24 50 80 00       	mov    0x805024,%eax
  801141:	8b 40 4c             	mov    0x4c(%eax),%eax
  801144:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114c:	c7 04 24 8c 1f 80 00 	movl   $0x801f8c,(%esp)
  801153:	e8 ed ef ff ff       	call   800145 <cprintf>
	*dev = 0;
  801158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	53                   	push   %ebx
  80116e:	83 ec 24             	sub    $0x24,%esp
  801171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801174:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	89 04 24             	mov    %eax,(%esp)
  801181:	e8 07 ff ff ff       	call   80108d <fd_lookup>
  801186:	85 c0                	test   %eax,%eax
  801188:	78 53                	js     8011dd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801194:	8b 00                	mov    (%eax),%eax
  801196:	89 04 24             	mov    %eax,(%esp)
  801199:	e8 63 ff ff ff       	call   801101 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 3b                	js     8011dd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011aa:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8011ae:	74 2d                	je     8011dd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011ba:	00 00 00 
	stat->st_isdir = 0;
  8011bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011c4:	00 00 00 
	stat->st_dev = dev;
  8011c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ca:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d7:	89 14 24             	mov    %edx,(%esp)
  8011da:	ff 50 14             	call   *0x14(%eax)
}
  8011dd:	83 c4 24             	add    $0x24,%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 24             	sub    $0x24,%esp
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f4:	89 1c 24             	mov    %ebx,(%esp)
  8011f7:	e8 91 fe ff ff       	call   80108d <fd_lookup>
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 5f                	js     80125f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801203:	89 44 24 04          	mov    %eax,0x4(%esp)
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	8b 00                	mov    (%eax),%eax
  80120c:	89 04 24             	mov    %eax,(%esp)
  80120f:	e8 ed fe ff ff       	call   801101 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801214:	85 c0                	test   %eax,%eax
  801216:	78 47                	js     80125f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801218:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80121b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80121f:	75 23                	jne    801244 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  801221:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801226:	8b 40 4c             	mov    0x4c(%eax),%eax
  801229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80122d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801231:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  801238:	e8 08 ef ff ff       	call   800145 <cprintf>
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  801242:	eb 1b                	jmp    80125f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801244:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801247:	8b 48 18             	mov    0x18(%eax),%ecx
  80124a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80124f:	85 c9                	test   %ecx,%ecx
  801251:	74 0c                	je     80125f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801253:	8b 45 0c             	mov    0xc(%ebp),%eax
  801256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125a:	89 14 24             	mov    %edx,(%esp)
  80125d:	ff d1                	call   *%ecx
}
  80125f:	83 c4 24             	add    $0x24,%esp
  801262:	5b                   	pop    %ebx
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	53                   	push   %ebx
  801269:	83 ec 24             	sub    $0x24,%esp
  80126c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	89 1c 24             	mov    %ebx,(%esp)
  801279:	e8 0f fe ff ff       	call   80108d <fd_lookup>
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 66                	js     8012e8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	89 44 24 04          	mov    %eax,0x4(%esp)
  801289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128c:	8b 00                	mov    (%eax),%eax
  80128e:	89 04 24             	mov    %eax,(%esp)
  801291:	e8 6b fe ff ff       	call   801101 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801296:	85 c0                	test   %eax,%eax
  801298:	78 4e                	js     8012e8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012a1:	75 23                	jne    8012c6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8012a3:	a1 24 50 80 00       	mov    0x805024,%eax
  8012a8:	8b 40 4c             	mov    0x4c(%eax),%eax
  8012ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b3:	c7 04 24 d0 1f 80 00 	movl   $0x801fd0,(%esp)
  8012ba:	e8 86 ee ff ff       	call   800145 <cprintf>
  8012bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012c4:	eb 22                	jmp    8012e8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8012cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d1:	85 c9                	test   %ecx,%ecx
  8012d3:	74 13                	je     8012e8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e3:	89 14 24             	mov    %edx,(%esp)
  8012e6:	ff d1                	call   *%ecx
}
  8012e8:	83 c4 24             	add    $0x24,%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 24             	sub    $0x24,%esp
  8012f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ff:	89 1c 24             	mov    %ebx,(%esp)
  801302:	e8 86 fd ff ff       	call   80108d <fd_lookup>
  801307:	85 c0                	test   %eax,%eax
  801309:	78 6b                	js     801376 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801312:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801315:	8b 00                	mov    (%eax),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 e2 fd ff ff       	call   801101 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 53                	js     801376 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801323:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801326:	8b 42 08             	mov    0x8(%edx),%eax
  801329:	83 e0 03             	and    $0x3,%eax
  80132c:	83 f8 01             	cmp    $0x1,%eax
  80132f:	75 23                	jne    801354 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801331:	a1 24 50 80 00       	mov    0x805024,%eax
  801336:	8b 40 4c             	mov    0x4c(%eax),%eax
  801339:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  801348:	e8 f8 ed ff ff       	call   800145 <cprintf>
  80134d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801352:	eb 22                	jmp    801376 <read+0x88>
	}
	if (!dev->dev_read)
  801354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801357:	8b 48 08             	mov    0x8(%eax),%ecx
  80135a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80135f:	85 c9                	test   %ecx,%ecx
  801361:	74 13                	je     801376 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801363:	8b 45 10             	mov    0x10(%ebp),%eax
  801366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	89 14 24             	mov    %edx,(%esp)
  801374:	ff d1                	call   *%ecx
}
  801376:	83 c4 24             	add    $0x24,%esp
  801379:	5b                   	pop    %ebx
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	57                   	push   %edi
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	83 ec 1c             	sub    $0x1c,%esp
  801385:	8b 7d 08             	mov    0x8(%ebp),%edi
  801388:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138b:	ba 00 00 00 00       	mov    $0x0,%edx
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	85 f6                	test   %esi,%esi
  80139c:	74 29                	je     8013c7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	29 d0                	sub    %edx,%eax
  8013a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a6:	03 55 0c             	add    0xc(%ebp),%edx
  8013a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013ad:	89 3c 24             	mov    %edi,(%esp)
  8013b0:	e8 39 ff ff ff       	call   8012ee <read>
		if (m < 0)
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 0e                	js     8013c7 <readn+0x4b>
			return m;
		if (m == 0)
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	74 08                	je     8013c5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013bd:	01 c3                	add    %eax,%ebx
  8013bf:	89 da                	mov    %ebx,%edx
  8013c1:	39 f3                	cmp    %esi,%ebx
  8013c3:	72 d9                	jb     80139e <readn+0x22>
  8013c5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013c7:	83 c4 1c             	add    $0x1c,%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5f                   	pop    %edi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 20             	sub    $0x20,%esp
  8013d7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013da:	89 34 24             	mov    %esi,(%esp)
  8013dd:	e8 0e fc ff ff       	call   800ff0 <fd2num>
  8013e2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e9:	89 04 24             	mov    %eax,(%esp)
  8013ec:	e8 9c fc ff ff       	call   80108d <fd_lookup>
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 05                	js     8013fc <fd_close+0x2d>
  8013f7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013fa:	74 0c                	je     801408 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013fc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801400:	19 c0                	sbb    %eax,%eax
  801402:	f7 d0                	not    %eax
  801404:	21 c3                	and    %eax,%ebx
  801406:	eb 3d                	jmp    801445 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801408:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	8b 06                	mov    (%esi),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 e8 fc ff ff       	call   801101 <dev_lookup>
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 16                	js     801435 <fd_close+0x66>
		if (dev->dev_close)
  80141f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801422:	8b 40 10             	mov    0x10(%eax),%eax
  801425:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 07                	je     801435 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80142e:	89 34 24             	mov    %esi,(%esp)
  801431:	ff d0                	call   *%eax
  801433:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801435:	89 74 24 04          	mov    %esi,0x4(%esp)
  801439:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801440:	e8 bd f9 ff ff       	call   800e02 <sys_page_unmap>
	return r;
}
  801445:	89 d8                	mov    %ebx,%eax
  801447:	83 c4 20             	add    $0x20,%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801454:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	89 04 24             	mov    %eax,(%esp)
  801461:	e8 27 fc ff ff       	call   80108d <fd_lookup>
  801466:	85 c0                	test   %eax,%eax
  801468:	78 13                	js     80147d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80146a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801471:	00 
  801472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801475:	89 04 24             	mov    %eax,(%esp)
  801478:	e8 52 ff ff ff       	call   8013cf <fd_close>
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	83 ec 18             	sub    $0x18,%esp
  801485:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801488:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801492:	00 
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 4d 03 00 00       	call   8017eb <open>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 1b                	js     8014bf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ab:	89 1c 24             	mov    %ebx,(%esp)
  8014ae:	e8 b7 fc ff ff       	call   80116a <fstat>
  8014b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b5:	89 1c 24             	mov    %ebx,(%esp)
  8014b8:	e8 91 ff ff ff       	call   80144e <close>
  8014bd:	89 f3                	mov    %esi,%ebx
	return r;
}
  8014bf:	89 d8                	mov    %ebx,%eax
  8014c1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014c7:	89 ec                	mov    %ebp,%esp
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 14             	sub    $0x14,%esp
  8014d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014d7:	89 1c 24             	mov    %ebx,(%esp)
  8014da:	e8 6f ff ff ff       	call   80144e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014df:	83 c3 01             	add    $0x1,%ebx
  8014e2:	83 fb 20             	cmp    $0x20,%ebx
  8014e5:	75 f0                	jne    8014d7 <close_all+0xc>
		close(i);
}
  8014e7:	83 c4 14             	add    $0x14,%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 58             	sub    $0x58,%esp
  8014f3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014f6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014f9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	89 04 24             	mov    %eax,(%esp)
  80150c:	e8 7c fb ff ff       	call   80108d <fd_lookup>
  801511:	89 c3                	mov    %eax,%ebx
  801513:	85 c0                	test   %eax,%eax
  801515:	0f 88 e0 00 00 00    	js     8015fb <dup+0x10e>
		return r;
	close(newfdnum);
  80151b:	89 3c 24             	mov    %edi,(%esp)
  80151e:	e8 2b ff ff ff       	call   80144e <close>

	newfd = INDEX2FD(newfdnum);
  801523:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801529:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80152c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 c9 fa ff ff       	call   801000 <fd2data>
  801537:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801539:	89 34 24             	mov    %esi,(%esp)
  80153c:	e8 bf fa ff ff       	call   801000 <fd2data>
  801541:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801544:	89 da                	mov    %ebx,%edx
  801546:	89 d8                	mov    %ebx,%eax
  801548:	c1 e8 16             	shr    $0x16,%eax
  80154b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801552:	a8 01                	test   $0x1,%al
  801554:	74 43                	je     801599 <dup+0xac>
  801556:	c1 ea 0c             	shr    $0xc,%edx
  801559:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801560:	a8 01                	test   $0x1,%al
  801562:	74 35                	je     801599 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801564:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80156b:	25 07 0e 00 00       	and    $0xe07,%eax
  801570:	89 44 24 10          	mov    %eax,0x10(%esp)
  801574:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801577:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80157b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801582:	00 
  801583:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801587:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158e:	e8 cd f8 ff ff       	call   800e60 <sys_page_map>
  801593:	89 c3                	mov    %eax,%ebx
  801595:	85 c0                	test   %eax,%eax
  801597:	78 3f                	js     8015d8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	c1 ea 0c             	shr    $0xc,%edx
  8015a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015ae:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015b2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015bd:	00 
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c9:	e8 92 f8 ff ff       	call   800e60 <sys_page_map>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 04                	js     8015d8 <dup+0xeb>
  8015d4:	89 fb                	mov    %edi,%ebx
  8015d6:	eb 23                	jmp    8015fb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e3:	e8 1a f8 ff ff       	call   800e02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f6:	e8 07 f8 ff ff       	call   800e02 <sys_page_unmap>
	return r;
}
  8015fb:	89 d8                	mov    %ebx,%eax
  8015fd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801600:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801603:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801606:	89 ec                	mov    %ebp,%esp
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    
  80160a:	00 00                	add    %al,(%eax)
  80160c:	00 00                	add    %al,(%eax)
	...

00801610 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	53                   	push   %ebx
  801614:	83 ec 14             	sub    $0x14,%esp
  801617:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801619:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  80161f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801626:	00 
  801627:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80162e:	00 
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	89 14 24             	mov    %edx,(%esp)
  801636:	e8 95 02 00 00       	call   8018d0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801642:	00 
  801643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164e:	e8 e7 02 00 00       	call   80193a <ipc_recv>
}
  801653:	83 c4 14             	add    $0x14,%esp
  801656:	5b                   	pop    %ebx
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80165f:	8b 45 08             	mov    0x8(%ebp),%eax
  801662:	8b 40 0c             	mov    0xc(%eax),%eax
  801665:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  80166a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166d:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801672:	ba 00 00 00 00       	mov    $0x0,%edx
  801677:	b8 02 00 00 00       	mov    $0x2,%eax
  80167c:	e8 8f ff ff ff       	call   801610 <fsipc>
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	8b 40 0c             	mov    0xc(%eax),%eax
  80168f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801694:	ba 00 00 00 00       	mov    $0x0,%edx
  801699:	b8 06 00 00 00       	mov    $0x6,%eax
  80169e:	e8 6d ff ff ff       	call   801610 <fsipc>
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016b5:	e8 56 ff ff ff       	call   801610 <fsipc>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 14             	sub    $0x14,%esp
  8016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cc:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016db:	e8 30 ff ff ff       	call   801610 <fsipc>
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	78 2b                	js     80170f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e4:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8016eb:	00 
  8016ec:	89 1c 24             	mov    %ebx,(%esp)
  8016ef:	e8 36 f1 ff ff       	call   80082a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f4:	a1 80 30 80 00       	mov    0x803080,%eax
  8016f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ff:	a1 84 30 80 00       	mov    0x803084,%eax
  801704:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80170f:	83 c4 14             	add    $0x14,%esp
  801712:	5b                   	pop    %ebx
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 18             	sub    $0x18,%esp
  80171b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171e:	8b 55 08             	mov    0x8(%ebp),%edx
  801721:	8b 52 0c             	mov    0xc(%edx),%edx
  801724:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  80172a:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80172f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801733:	8b 45 0c             	mov    0xc(%ebp),%eax
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801741:	e8 9f f2 ff ff       	call   8009e5 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801746:	ba 00 30 80 00       	mov    $0x803000,%edx
  80174b:	b8 04 00 00 00       	mov    $0x4,%eax
  801750:	e8 bb fe ff ff       	call   801610 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	53                   	push   %ebx
  80175b:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80175e:	8b 45 08             	mov    0x8(%ebp),%eax
  801761:	8b 40 0c             	mov    0xc(%eax),%eax
  801764:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801769:	8b 45 10             	mov    0x10(%ebp),%eax
  80176c:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801771:	ba 00 30 80 00       	mov    $0x803000,%edx
  801776:	b8 03 00 00 00       	mov    $0x3,%eax
  80177b:	e8 90 fe ff ff       	call   801610 <fsipc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	85 c0                	test   %eax,%eax
  801784:	78 17                	js     80179d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801786:	89 44 24 08          	mov    %eax,0x8(%esp)
  80178a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801791:	00 
  801792:	8b 45 0c             	mov    0xc(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 48 f2 ff ff       	call   8009e5 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80179d:	89 d8                	mov    %ebx,%eax
  80179f:	83 c4 14             	add    $0x14,%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 14             	sub    $0x14,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017af:	89 1c 24             	mov    %ebx,(%esp)
  8017b2:	e8 29 f0 ff ff       	call   8007e0 <strlen>
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8017be:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8017c4:	7f 1f                	jg     8017e5 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ca:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017d1:	e8 54 f0 ff ff       	call   80082a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 07 00 00 00       	mov    $0x7,%eax
  8017e0:	e8 2b fe ff ff       	call   801610 <fsipc>
}
  8017e5:	83 c4 14             	add    $0x14,%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	89 04 24             	mov    %eax,(%esp)
  8017f7:	e8 1f f8 ff ff       	call   80101b <fd_alloc>
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 6a                	js     80186a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  801800:	8b 45 08             	mov    0x8(%ebp),%eax
  801803:	89 44 24 04          	mov    %eax,0x4(%esp)
  801807:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80180e:	e8 17 f0 ff ff       	call   80082a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80181b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801820:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801827:	00 
  801828:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80182f:	00 
  801830:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801837:	00 
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	e8 90 00 00 00       	call   8018d0 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801840:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801847:	00 
  801848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801856:	e8 df 00 00 00       	call   80193a <ipc_recv>
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 0b                	js     80186a <open+0x7f>
		return r;
	return fd2num(fd);
  80185f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	e8 86 f7 ff ff       	call   800ff0 <fd2num>
	panic("open not implemented");
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  801873:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801876:	a1 28 50 80 00       	mov    0x805028,%eax
  80187b:	85 c0                	test   %eax,%eax
  80187d:	74 10                	je     80188f <_panic+0x23>
		cprintf("%s: ", argv0);
  80187f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801883:	c7 04 24 14 20 80 00 	movl   $0x802014,(%esp)
  80188a:	e8 b6 e8 ff ff       	call   800145 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80188f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	89 44 24 08          	mov    %eax,0x8(%esp)
  80189d:	a1 00 50 80 00       	mov    0x805000,%eax
  8018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a6:	c7 04 24 19 20 80 00 	movl   $0x802019,(%esp)
  8018ad:	e8 93 e8 ff ff       	call   800145 <cprintf>
	vcprintf(fmt, ap);
  8018b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b9:	89 04 24             	mov    %eax,(%esp)
  8018bc:	e8 23 e8 ff ff       	call   8000e4 <vcprintf>
	cprintf("\n");
  8018c1:	c7 04 24 35 1c 80 00 	movl   $0x801c35,(%esp)
  8018c8:	e8 78 e8 ff ff       	call   800145 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018cd:	cc                   	int3   
  8018ce:	eb fd                	jmp    8018cd <_panic+0x61>

008018d0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 1c             	sub    $0x1c,%esp
  8018d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018df:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  8018e2:	85 db                	test   %ebx,%ebx
  8018e4:	75 31                	jne    801917 <ipc_send+0x47>
  8018e6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8018eb:	eb 2a                	jmp    801917 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  8018ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018f0:	74 20                	je     801912 <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  8018f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018f6:	c7 44 24 08 35 20 80 	movl   $0x802035,0x8(%esp)
  8018fd:	00 
  8018fe:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801905:	00 
  801906:	c7 04 24 4c 20 80 00 	movl   $0x80204c,(%esp)
  80190d:	e8 5a ff ff ff       	call   80186c <_panic>


                sys_yield();
  801912:	e8 06 f6 ff ff       	call   800f1d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801917:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80191b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	89 04 24             	mov    %eax,(%esp)
  801929:	e8 82 f3 ff ff       	call   800cb0 <sys_ipc_try_send>
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 bb                	js     8018ed <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801932:	83 c4 1c             	add    $0x1c,%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5f                   	pop    %edi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	83 ec 10             	sub    $0x10,%esp
  801942:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801945:	8b 45 0c             	mov    0xc(%ebp),%eax
  801948:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  80194b:	85 c0                	test   %eax,%eax
  80194d:	75 05                	jne    801954 <ipc_recv+0x1a>
  80194f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801954:	89 04 24             	mov    %eax,(%esp)
  801957:	e8 f7 f2 ff ff       	call   800c53 <sys_ipc_recv>
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 24                	js     801984 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801960:	85 db                	test   %ebx,%ebx
  801962:	74 0a                	je     80196e <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801964:	a1 24 50 80 00       	mov    0x805024,%eax
  801969:	8b 40 74             	mov    0x74(%eax),%eax
  80196c:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  80196e:	85 f6                	test   %esi,%esi
  801970:	74 0a                	je     80197c <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801972:	a1 24 50 80 00       	mov    0x805024,%eax
  801977:	8b 40 78             	mov    0x78(%eax),%eax
  80197a:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  80197c:	a1 24 50 80 00       	mov    0x805024,%eax
  801981:	8b 40 70             	mov    0x70(%eax),%eax
}
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    
  80198b:	00 00                	add    %al,(%eax)
  80198d:	00 00                	add    %al,(%eax)
	...

00801990 <__udivdi3>:
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	57                   	push   %edi
  801994:	56                   	push   %esi
  801995:	83 ec 10             	sub    $0x10,%esp
  801998:	8b 45 14             	mov    0x14(%ebp),%eax
  80199b:	8b 55 08             	mov    0x8(%ebp),%edx
  80199e:	8b 75 10             	mov    0x10(%ebp),%esi
  8019a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8019a9:	75 35                	jne    8019e0 <__udivdi3+0x50>
  8019ab:	39 fe                	cmp    %edi,%esi
  8019ad:	77 61                	ja     801a10 <__udivdi3+0x80>
  8019af:	85 f6                	test   %esi,%esi
  8019b1:	75 0b                	jne    8019be <__udivdi3+0x2e>
  8019b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b8:	31 d2                	xor    %edx,%edx
  8019ba:	f7 f6                	div    %esi
  8019bc:	89 c6                	mov    %eax,%esi
  8019be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019c1:	31 d2                	xor    %edx,%edx
  8019c3:	89 f8                	mov    %edi,%eax
  8019c5:	f7 f6                	div    %esi
  8019c7:	89 c7                	mov    %eax,%edi
  8019c9:	89 c8                	mov    %ecx,%eax
  8019cb:	f7 f6                	div    %esi
  8019cd:	89 c1                	mov    %eax,%ecx
  8019cf:	89 fa                	mov    %edi,%edx
  8019d1:	89 c8                	mov    %ecx,%eax
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	5e                   	pop    %esi
  8019d7:	5f                   	pop    %edi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    
  8019da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019e0:	39 f8                	cmp    %edi,%eax
  8019e2:	77 1c                	ja     801a00 <__udivdi3+0x70>
  8019e4:	0f bd d0             	bsr    %eax,%edx
  8019e7:	83 f2 1f             	xor    $0x1f,%edx
  8019ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8019ed:	75 39                	jne    801a28 <__udivdi3+0x98>
  8019ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8019f2:	0f 86 a0 00 00 00    	jbe    801a98 <__udivdi3+0x108>
  8019f8:	39 f8                	cmp    %edi,%eax
  8019fa:	0f 82 98 00 00 00    	jb     801a98 <__udivdi3+0x108>
  801a00:	31 ff                	xor    %edi,%edi
  801a02:	31 c9                	xor    %ecx,%ecx
  801a04:	89 c8                	mov    %ecx,%eax
  801a06:	89 fa                	mov    %edi,%edx
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	5e                   	pop    %esi
  801a0c:	5f                   	pop    %edi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    
  801a0f:	90                   	nop
  801a10:	89 d1                	mov    %edx,%ecx
  801a12:	89 fa                	mov    %edi,%edx
  801a14:	89 c8                	mov    %ecx,%eax
  801a16:	31 ff                	xor    %edi,%edi
  801a18:	f7 f6                	div    %esi
  801a1a:	89 c1                	mov    %eax,%ecx
  801a1c:	89 fa                	mov    %edi,%edx
  801a1e:	89 c8                	mov    %ecx,%eax
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	5e                   	pop    %esi
  801a24:	5f                   	pop    %edi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    
  801a27:	90                   	nop
  801a28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a2c:	89 f2                	mov    %esi,%edx
  801a2e:	d3 e0                	shl    %cl,%eax
  801a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a33:	b8 20 00 00 00       	mov    $0x20,%eax
  801a38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801a3b:	89 c1                	mov    %eax,%ecx
  801a3d:	d3 ea                	shr    %cl,%edx
  801a3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a43:	0b 55 ec             	or     -0x14(%ebp),%edx
  801a46:	d3 e6                	shl    %cl,%esi
  801a48:	89 c1                	mov    %eax,%ecx
  801a4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801a4d:	89 fe                	mov    %edi,%esi
  801a4f:	d3 ee                	shr    %cl,%esi
  801a51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a5b:	d3 e7                	shl    %cl,%edi
  801a5d:	89 c1                	mov    %eax,%ecx
  801a5f:	d3 ea                	shr    %cl,%edx
  801a61:	09 d7                	or     %edx,%edi
  801a63:	89 f2                	mov    %esi,%edx
  801a65:	89 f8                	mov    %edi,%eax
  801a67:	f7 75 ec             	divl   -0x14(%ebp)
  801a6a:	89 d6                	mov    %edx,%esi
  801a6c:	89 c7                	mov    %eax,%edi
  801a6e:	f7 65 e8             	mull   -0x18(%ebp)
  801a71:	39 d6                	cmp    %edx,%esi
  801a73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a76:	72 30                	jb     801aa8 <__udivdi3+0x118>
  801a78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a7f:	d3 e2                	shl    %cl,%edx
  801a81:	39 c2                	cmp    %eax,%edx
  801a83:	73 05                	jae    801a8a <__udivdi3+0xfa>
  801a85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801a88:	74 1e                	je     801aa8 <__udivdi3+0x118>
  801a8a:	89 f9                	mov    %edi,%ecx
  801a8c:	31 ff                	xor    %edi,%edi
  801a8e:	e9 71 ff ff ff       	jmp    801a04 <__udivdi3+0x74>
  801a93:	90                   	nop
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	31 ff                	xor    %edi,%edi
  801a9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a9f:	e9 60 ff ff ff       	jmp    801a04 <__udivdi3+0x74>
  801aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801aab:	31 ff                	xor    %edi,%edi
  801aad:	89 c8                	mov    %ecx,%eax
  801aaf:	89 fa                	mov    %edi,%edx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	5e                   	pop    %esi
  801ab5:	5f                   	pop    %edi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    
	...

00801ac0 <__umoddi3>:
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	57                   	push   %edi
  801ac4:	56                   	push   %esi
  801ac5:	83 ec 20             	sub    $0x20,%esp
  801ac8:	8b 55 14             	mov    0x14(%ebp),%edx
  801acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ace:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad4:	85 d2                	test   %edx,%edx
  801ad6:	89 c8                	mov    %ecx,%eax
  801ad8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801adb:	75 13                	jne    801af0 <__umoddi3+0x30>
  801add:	39 f7                	cmp    %esi,%edi
  801adf:	76 3f                	jbe    801b20 <__umoddi3+0x60>
  801ae1:	89 f2                	mov    %esi,%edx
  801ae3:	f7 f7                	div    %edi
  801ae5:	89 d0                	mov    %edx,%eax
  801ae7:	31 d2                	xor    %edx,%edx
  801ae9:	83 c4 20             	add    $0x20,%esp
  801aec:	5e                   	pop    %esi
  801aed:	5f                   	pop    %edi
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    
  801af0:	39 f2                	cmp    %esi,%edx
  801af2:	77 4c                	ja     801b40 <__umoddi3+0x80>
  801af4:	0f bd ca             	bsr    %edx,%ecx
  801af7:	83 f1 1f             	xor    $0x1f,%ecx
  801afa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801afd:	75 51                	jne    801b50 <__umoddi3+0x90>
  801aff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801b02:	0f 87 e0 00 00 00    	ja     801be8 <__umoddi3+0x128>
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	29 f8                	sub    %edi,%eax
  801b0d:	19 d6                	sbb    %edx,%esi
  801b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	89 f2                	mov    %esi,%edx
  801b17:	83 c4 20             	add    $0x20,%esp
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    
  801b1e:	66 90                	xchg   %ax,%ax
  801b20:	85 ff                	test   %edi,%edi
  801b22:	75 0b                	jne    801b2f <__umoddi3+0x6f>
  801b24:	b8 01 00 00 00       	mov    $0x1,%eax
  801b29:	31 d2                	xor    %edx,%edx
  801b2b:	f7 f7                	div    %edi
  801b2d:	89 c7                	mov    %eax,%edi
  801b2f:	89 f0                	mov    %esi,%eax
  801b31:	31 d2                	xor    %edx,%edx
  801b33:	f7 f7                	div    %edi
  801b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b38:	f7 f7                	div    %edi
  801b3a:	eb a9                	jmp    801ae5 <__umoddi3+0x25>
  801b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b40:	89 c8                	mov    %ecx,%eax
  801b42:	89 f2                	mov    %esi,%edx
  801b44:	83 c4 20             	add    $0x20,%esp
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    
  801b4b:	90                   	nop
  801b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b54:	d3 e2                	shl    %cl,%edx
  801b56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b59:	ba 20 00 00 00       	mov    $0x20,%edx
  801b5e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801b61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b64:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b68:	89 fa                	mov    %edi,%edx
  801b6a:	d3 ea                	shr    %cl,%edx
  801b6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b70:	0b 55 f4             	or     -0xc(%ebp),%edx
  801b73:	d3 e7                	shl    %cl,%edi
  801b75:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b79:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b7c:	89 f2                	mov    %esi,%edx
  801b7e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801b81:	89 c7                	mov    %eax,%edi
  801b83:	d3 ea                	shr    %cl,%edx
  801b85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	d3 e6                	shl    %cl,%esi
  801b90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b94:	d3 ea                	shr    %cl,%edx
  801b96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b9a:	09 d6                	or     %edx,%esi
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801ba1:	d3 e7                	shl    %cl,%edi
  801ba3:	89 f2                	mov    %esi,%edx
  801ba5:	f7 75 f4             	divl   -0xc(%ebp)
  801ba8:	89 d6                	mov    %edx,%esi
  801baa:	f7 65 e8             	mull   -0x18(%ebp)
  801bad:	39 d6                	cmp    %edx,%esi
  801baf:	72 2b                	jb     801bdc <__umoddi3+0x11c>
  801bb1:	39 c7                	cmp    %eax,%edi
  801bb3:	72 23                	jb     801bd8 <__umoddi3+0x118>
  801bb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bb9:	29 c7                	sub    %eax,%edi
  801bbb:	19 d6                	sbb    %edx,%esi
  801bbd:	89 f0                	mov    %esi,%eax
  801bbf:	89 f2                	mov    %esi,%edx
  801bc1:	d3 ef                	shr    %cl,%edi
  801bc3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bc7:	d3 e0                	shl    %cl,%eax
  801bc9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bcd:	09 f8                	or     %edi,%eax
  801bcf:	d3 ea                	shr    %cl,%edx
  801bd1:	83 c4 20             	add    $0x20,%esp
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	39 d6                	cmp    %edx,%esi
  801bda:	75 d9                	jne    801bb5 <__umoddi3+0xf5>
  801bdc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801bdf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801be2:	eb d1                	jmp    801bb5 <__umoddi3+0xf5>
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	39 f2                	cmp    %esi,%edx
  801bea:	0f 82 18 ff ff ff    	jb     801b08 <__umoddi3+0x48>
  801bf0:	e9 1d ff ff ff       	jmp    801b12 <__umoddi3+0x52>
