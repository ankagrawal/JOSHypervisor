
obj/user/abc:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>
#include <inc/stdio.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
        cprintf("hello, world\n");
  80003a:	c7 04 24 e0 1b 80 00 	movl   $0x801be0,(%esp)
  800041:	e8 e7 00 00 00       	call   80012d <cprintf>
//        cprintf("i am environment %08x\n", env->env_id);
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	83 ec 18             	sub    $0x18,%esp
  80004e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800051:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80005a:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  800061:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800064:	e8 c8 0e 00 00       	call   800f31 <sys_getenvid>
  800069:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x3e>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  800086:	c7 04 24 ee 1b 80 00 	movl   $0x801bee,(%esp)
  80008d:	e8 9b 00 00 00       	call   80012d <cprintf>
	umain(argc, argv);
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 96 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009e:	e8 0d 00 00 00       	call   8000b0 <exit>
}
  8000a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a9:	89 ec                	mov    %ebp,%esp
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 f0 13 00 00       	call   8014ab <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 9e 0e 00 00       	call   800f65 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000dc:	00 00 00 
	b.cnt = 0;
  8000df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 47 01 80 00 	movl   $0x800147,(%esp)
  800108:	e8 d0 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 db 0a 00 00       	call   800c00 <sys_cputs>

	return b.cnt;
}
  800125:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800133:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 87 ff ff ff       	call   8000cc <vcprintf>
	va_end(ap);

	return cnt;
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	53                   	push   %ebx
  80014b:	83 ec 14             	sub    $0x14,%esp
  80014e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800151:	8b 03                	mov    (%ebx),%eax
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
  800156:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015a:	83 c0 01             	add    $0x1,%eax
  80015d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80015f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800164:	75 19                	jne    80017f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800166:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80016d:	00 
  80016e:	8d 43 08             	lea    0x8(%ebx),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 87 0a 00 00       	call   800c00 <sys_cputs>
		b->idx = 0;
  800179:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80017f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800183:	83 c4 14             	add    $0x14,%esp
  800186:	5b                   	pop    %ebx
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
  80018b:	00 00                	add    %al,(%eax)
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 5e 17 00 00       	call   801970 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 33 18 00 00       	call   801aa0 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 17 1c 80 00 	movsbl 0x801c17(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0e                	jle    80029c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 08             	lea    0x8(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x38>
	else if (lflag)
  80029c:	85 d2                	test   %edx,%edx
  80029e:	74 10                	je     8002b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	88 0a                	mov    %cl,(%edx)
  8002d6:	83 c2 01             	add    $0x1,%edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 5c             	sub    $0x5c,%esp
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f6:	eb 11                	jmp    800309 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 02 04 00 00    	je     800702 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800300:	89 74 24 04          	mov    %esi,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 03             	movzbl (%ebx),%eax
  80030c:	83 c3 01             	add    $0x1,%ebx
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 e4                	jne    8002f8 <vprintfmt+0x1b>
  800314:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800318:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800326:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	eb 06                	jmp    80033a <vprintfmt+0x5d>
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800338:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 13             	movzbl (%ebx),%edx
  80033d:	0f b6 c2             	movzbl %dl,%eax
  800340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800343:	8d 43 01             	lea    0x1(%ebx),%eax
  800346:	83 ea 23             	sub    $0x23,%edx
  800349:	80 fa 55             	cmp    $0x55,%dl
  80034c:	0f 87 93 03 00 00    	ja     8006e5 <vprintfmt+0x408>
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	ff 24 95 60 1d 80 00 	jmp    *0x801d60(,%edx,4)
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800365:	83 ea 30             	sub    $0x30,%edx
  800368:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80036b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800371:	83 fb 09             	cmp    $0x9,%ebx
  800374:	77 4c                	ja     8003c2 <vprintfmt+0xe5>
  800376:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800379:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80037f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800382:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800386:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80038c:	83 fb 09             	cmp    $0x9,%ebx
  80038f:	76 eb                	jbe    80037c <vprintfmt+0x9f>
  800391:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800394:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800397:	eb 29                	jmp    8003c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800399:	8b 55 14             	mov    0x14(%ebp),%edx
  80039c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a2:	8b 12                	mov    (%edx),%edx
  8003a4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003a7:	eb 19                	jmp    8003c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ac:	c1 fa 1f             	sar    $0x1f,%edx
  8003af:	f7 d2                	not    %edx
  8003b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003b4:	eb 82                	jmp    800338 <vprintfmt+0x5b>
  8003b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003bd:	e9 76 ff ff ff       	jmp    800338 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c6:	0f 89 6c ff ff ff    	jns    800338 <vprintfmt+0x5b>
  8003cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003d5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003d8:	e9 5b ff ff ff       	jmp    800338 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003e5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	89 04 24             	mov    %eax,(%esp)
  8003fa:	ff d7                	call   *%edi
  8003fc:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8003ff:	e9 05 ff ff ff       	jmp    800309 <vprintfmt+0x2c>
  800404:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 50 04             	lea    0x4(%eax),%edx
  80040d:	89 55 14             	mov    %edx,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 c2                	mov    %eax,%edx
  800414:	c1 fa 1f             	sar    $0x1f,%edx
  800417:	31 d0                	xor    %edx,%eax
  800419:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 0f             	cmp    $0xf,%eax
  80041e:	7f 0b                	jg     80042b <vprintfmt+0x14e>
  800420:	8b 14 85 c0 1e 80 00 	mov    0x801ec0(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	75 20                	jne    80044b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800436:	00 
  800437:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043b:	89 3c 24             	mov    %edi,(%esp)
  80043e:	e8 47 03 00 00       	call   80078a <printfmt>
  800443:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800446:	e9 be fe ff ff       	jmp    800309 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044f:	c7 44 24 08 31 1c 80 	movl   $0x801c31,0x8(%esp)
  800456:	00 
  800457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045b:	89 3c 24             	mov    %edi,(%esp)
  80045e:	e8 27 03 00 00       	call   80078a <printfmt>
  800463:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800466:	e9 9e fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  80046b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046e:	89 c3                	mov    %eax,%ebx
  800470:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800476:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800487:	85 c0                	test   %eax,%eax
  800489:	75 07                	jne    800492 <vprintfmt+0x1b5>
  80048b:	c7 45 e0 34 1c 80 00 	movl   $0x801c34,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800492:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800496:	7e 06                	jle    80049e <vprintfmt+0x1c1>
  800498:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049c:	75 13                	jne    8004b1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a1:	0f be 02             	movsbl (%edx),%eax
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	0f 85 99 00 00 00    	jne    800545 <vprintfmt+0x268>
  8004ac:	e9 86 00 00 00       	jmp    800537 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	89 0c 24             	mov    %ecx,(%esp)
  8004bb:	e8 1b 03 00 00       	call   8007db <strnlen>
  8004c0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c3:	29 c2                	sub    %eax,%edx
  8004c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	7e d2                	jle    80049e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004cc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8004d0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004d3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004d6:	89 d3                	mov    %edx,%ebx
  8004d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	85 db                	test   %ebx,%ebx
  8004e9:	7f ed                	jg     8004d8 <vprintfmt+0x1fb>
  8004eb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f5:	eb a7                	jmp    80049e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fb:	74 18                	je     800515 <vprintfmt+0x238>
  8004fd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800500:	83 fa 5e             	cmp    $0x5e,%edx
  800503:	76 10                	jbe    800515 <vprintfmt+0x238>
					putch('?', putdat);
  800505:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800509:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800510:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800513:	eb 0a                	jmp    80051f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800523:	0f be 03             	movsbl (%ebx),%eax
  800526:	85 c0                	test   %eax,%eax
  800528:	74 05                	je     80052f <vprintfmt+0x252>
  80052a:	83 c3 01             	add    $0x1,%ebx
  80052d:	eb 29                	jmp    800558 <vprintfmt+0x27b>
  80052f:	89 fe                	mov    %edi,%esi
  800531:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800534:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	7f 2e                	jg     80056b <vprintfmt+0x28e>
  80053d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800540:	e9 c4 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800548:	83 c2 01             	add    $0x1,%edx
  80054b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80054e:	89 f7                	mov    %esi,%edi
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800556:	89 d3                	mov    %edx,%ebx
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 9b                	js     8004f7 <vprintfmt+0x21a>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 96                	jns    8004f7 <vprintfmt+0x21a>
  800561:	89 fe                	mov    %edi,%esi
  800563:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800566:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800569:	eb cc                	jmp    800537 <vprintfmt+0x25a>
  80056b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80056e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800571:	89 74 24 04          	mov    %esi,0x4(%esp)
  800575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	85 db                	test   %ebx,%ebx
  800583:	7f ec                	jg     800571 <vprintfmt+0x294>
  800585:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800588:	e9 7c fd ff ff       	jmp    800309 <vprintfmt+0x2c>
  80058d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800590:	83 f9 01             	cmp    $0x1,%ecx
  800593:	7e 16                	jle    8005ab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 08             	lea    0x8(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a9:	eb 32                	jmp    8005dd <vprintfmt+0x300>
	else if (lflag)
  8005ab:	85 c9                	test   %ecx,%ecx
  8005ad:	74 18                	je     8005c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	eb 16                	jmp    8005dd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c2                	mov    %eax,%edx
  8005d7:	c1 fa 1f             	sar    $0x1f,%edx
  8005da:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e3:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8005e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ec:	0f 89 b1 00 00 00    	jns    8006a3 <vprintfmt+0x3c6>
				putch('-', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fd:	ff d7                	call   *%edi
				num = -(long long) num;
  8005ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800602:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800605:	f7 d8                	neg    %eax
  800607:	83 d2 00             	adc    $0x0,%edx
  80060a:	f7 da                	neg    %edx
  80060c:	e9 92 00 00 00       	jmp    8006a3 <vprintfmt+0x3c6>
  800611:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 68 fc ff ff       	call   800286 <getuint>
  80061e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800623:	eb 7e                	jmp    8006a3 <vprintfmt+0x3c6>
  800625:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 54 fc ff ff       	call   800286 <getuint>
			if ((long long) num < 0) {
  800632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800635:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800638:	bb 08 00 00 00       	mov    $0x8,%ebx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	79 62                	jns    8006a3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800641:	89 74 24 04          	mov    %esi,0x4(%esp)
  800645:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064c:	ff d7                	call   *%edi
				num = -(long long) num;
  80064e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800651:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800654:	f7 d8                	neg    %eax
  800656:	83 d2 00             	adc    $0x0,%edx
  800659:	f7 da                	neg    %edx
  80065b:	eb 46                	jmp    8006a3 <vprintfmt+0x3c6>
  80065d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800660:	89 74 24 04          	mov    %esi,0x4(%esp)
  800664:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066b:	ff d7                	call   *%edi
			putch('x', putdat);
  80066d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800671:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800678:	ff d7                	call   *%edi
			num = (unsigned long long)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
  80068a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068f:	eb 12                	jmp    8006a3 <vprintfmt+0x3c6>
  800691:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800694:	89 ca                	mov    %ecx,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 e8 fb ff ff       	call   800286 <getuint>
  80069e:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006a7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006ab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006b6:	89 04 24             	mov    %eax,(%esp)
  8006b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bd:	89 f2                	mov    %esi,%edx
  8006bf:	89 f8                	mov    %edi,%eax
  8006c1:	e8 ca fa ff ff       	call   800190 <printnum>
  8006c6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006c9:	e9 3b fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  8006ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006d1:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d8:	89 14 24             	mov    %edx,(%esp)
  8006db:	ff d7                	call   *%edi
  8006dd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006e0:	e9 24 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006f5:	80 38 25             	cmpb   $0x25,(%eax)
  8006f8:	0f 84 0b fc ff ff    	je     800309 <vprintfmt+0x2c>
  8006fe:	89 c3                	mov    %eax,%ebx
  800700:	eb f0                	jmp    8006f2 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800702:	83 c4 5c             	add    $0x5c,%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 28             	sub    $0x28,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 04                	je     80071e <vsnprintf+0x14>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7f 07                	jg     800725 <vsnprintf+0x1b>
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800723:	eb 3b                	jmp    800760 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80072c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80072f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073d:	8b 45 10             	mov    0x10(%ebp),%eax
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  800752:	e8 86 fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800757:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076f:	8b 45 10             	mov    0x10(%ebp),%eax
  800772:	89 44 24 08          	mov    %eax,0x8(%esp)
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
  800779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	e8 82 ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800793:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800797:	8b 45 10             	mov    0x10(%ebp),%eax
  80079a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	e8 2d fb ff ff       	call   8002dd <vprintfmt>
	va_end(ap);
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 09                	je     8007d9 <strlen+0x19>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	85 c9                	test   %ecx,%ecx
  8007e7:	74 19                	je     800802 <strnlen+0x27>
  8007e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007ec:	74 14                	je     800802 <strnlen+0x27>
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f6:	39 c8                	cmp    %ecx,%eax
  8007f8:	74 0d                	je     800807 <strnlen+0x2c>
  8007fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007fe:	75 f3                	jne    8007f3 <strnlen+0x18>
  800800:	eb 05                	jmp    800807 <strnlen+0x2c>
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800814:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80081d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	84 c9                	test   %cl,%cl
  800825:	75 f2                	jne    800819 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	85 f6                	test   %esi,%esi
  80083a:	74 18                	je     800854 <strncpy+0x2a>
  80083c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800841:	0f b6 1a             	movzbl (%edx),%ebx
  800844:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800847:	80 3a 01             	cmpb   $0x1,(%edx)
  80084a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	39 ce                	cmp    %ecx,%esi
  800852:	77 ed                	ja     800841 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
  800863:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800866:	89 f0                	mov    %esi,%eax
  800868:	85 c9                	test   %ecx,%ecx
  80086a:	74 27                	je     800893 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80086c:	83 e9 01             	sub    $0x1,%ecx
  80086f:	74 1d                	je     80088e <strlcpy+0x36>
  800871:	0f b6 1a             	movzbl (%edx),%ebx
  800874:	84 db                	test   %bl,%bl
  800876:	74 16                	je     80088e <strlcpy+0x36>
			*dst++ = *src++;
  800878:	88 18                	mov    %bl,(%eax)
  80087a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087d:	83 e9 01             	sub    $0x1,%ecx
  800880:	74 0e                	je     800890 <strlcpy+0x38>
			*dst++ = *src++;
  800882:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800885:	0f b6 1a             	movzbl (%edx),%ebx
  800888:	84 db                	test   %bl,%bl
  80088a:	75 ec                	jne    800878 <strlcpy+0x20>
  80088c:	eb 02                	jmp    800890 <strlcpy+0x38>
  80088e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800890:	c6 00 00             	movb   $0x0,(%eax)
  800893:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a2:	0f b6 01             	movzbl (%ecx),%eax
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 15                	je     8008be <strcmp+0x25>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	75 11                	jne    8008be <strcmp+0x25>
		p++, q++;
  8008ad:	83 c1 01             	add    $0x1,%ecx
  8008b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 04                	je     8008be <strcmp+0x25>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	74 ef                	je     8008ad <strcmp+0x14>
  8008be:	0f b6 c0             	movzbl %al,%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	74 23                	je     8008fc <strncmp+0x34>
  8008d9:	0f b6 1a             	movzbl (%edx),%ebx
  8008dc:	84 db                	test   %bl,%bl
  8008de:	74 24                	je     800904 <strncmp+0x3c>
  8008e0:	3a 19                	cmp    (%ecx),%bl
  8008e2:	75 20                	jne    800904 <strncmp+0x3c>
  8008e4:	83 e8 01             	sub    $0x1,%eax
  8008e7:	74 13                	je     8008fc <strncmp+0x34>
		n--, p++, q++;
  8008e9:	83 c2 01             	add    $0x1,%edx
  8008ec:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ef:	0f b6 1a             	movzbl (%edx),%ebx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	74 0e                	je     800904 <strncmp+0x3c>
  8008f6:	3a 19                	cmp    (%ecx),%bl
  8008f8:	74 ea                	je     8008e4 <strncmp+0x1c>
  8008fa:	eb 08                	jmp    800904 <strncmp+0x3c>
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800904:	0f b6 02             	movzbl (%edx),%eax
  800907:	0f b6 11             	movzbl (%ecx),%edx
  80090a:	29 d0                	sub    %edx,%eax
  80090c:	eb f3                	jmp    800901 <strncmp+0x39>

0080090e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800918:	0f b6 10             	movzbl (%eax),%edx
  80091b:	84 d2                	test   %dl,%dl
  80091d:	74 15                	je     800934 <strchr+0x26>
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	75 07                	jne    80092a <strchr+0x1c>
  800923:	eb 14                	jmp    800939 <strchr+0x2b>
  800925:	38 ca                	cmp    %cl,%dl
  800927:	90                   	nop
  800928:	74 0f                	je     800939 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f1                	jne    800925 <strchr+0x17>
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 18                	je     800964 <strfind+0x29>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	75 0a                	jne    80095a <strfind+0x1f>
  800950:	eb 12                	jmp    800964 <strfind+0x29>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800958:	74 0a                	je     800964 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 ee                	jne    800952 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 0c             	sub    $0xc,%esp
  80096c:	89 1c 24             	mov    %ebx,(%esp)
  80096f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800973:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800977:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800980:	85 c9                	test   %ecx,%ecx
  800982:	74 30                	je     8009b4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800984:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098a:	75 25                	jne    8009b1 <memset+0x4b>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 20                	jne    8009b1 <memset+0x4b>
		c &= 0xFF;
  800991:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800994:	89 d3                	mov    %edx,%ebx
  800996:	c1 e3 08             	shl    $0x8,%ebx
  800999:	89 d6                	mov    %edx,%esi
  80099b:	c1 e6 18             	shl    $0x18,%esi
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	c1 e0 10             	shl    $0x10,%eax
  8009a3:	09 f0                	or     %esi,%eax
  8009a5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009a7:	09 d8                	or     %ebx,%eax
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
  8009ac:	fc                   	cld    
  8009ad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009af:	eb 03                	jmp    8009b4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b1:	fc                   	cld    
  8009b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b4:	89 f8                	mov    %edi,%eax
  8009b6:	8b 1c 24             	mov    (%esp),%ebx
  8009b9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009c1:	89 ec                	mov    %ebp,%esp
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 08             	sub    $0x8,%esp
  8009cb:	89 34 24             	mov    %esi,(%esp)
  8009ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009db:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009dd:	39 c6                	cmp    %eax,%esi
  8009df:	73 35                	jae    800a16 <memmove+0x51>
  8009e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e4:	39 d0                	cmp    %edx,%eax
  8009e6:	73 2e                	jae    800a16 <memmove+0x51>
		s += n;
		d += n;
  8009e8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	f6 c2 03             	test   $0x3,%dl
  8009ed:	75 1b                	jne    800a0a <memmove+0x45>
  8009ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f5:	75 13                	jne    800a0a <memmove+0x45>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 0e                	jne    800a0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8009fc:	83 ef 04             	sub    $0x4,%edi
  8009ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a02:	c1 e9 02             	shr    $0x2,%ecx
  800a05:	fd                   	std    
  800a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	eb 09                	jmp    800a13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0a:	83 ef 01             	sub    $0x1,%edi
  800a0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a10:	fd                   	std    
  800a11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a14:	eb 20                	jmp    800a36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1c:	75 15                	jne    800a33 <memmove+0x6e>
  800a1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a24:	75 0d                	jne    800a33 <memmove+0x6e>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 08                	jne    800a33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
  800a2e:	fc                   	cld    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a31:	eb 03                	jmp    800a36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a33:	fc                   	cld    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a36:	8b 34 24             	mov    (%esp),%esi
  800a39:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a3d:	89 ec                	mov    %ebp,%esp
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a47:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	e8 65 ff ff ff       	call   8009c5 <memmove>
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	74 36                	je     800aab <memcmp+0x49>
		if (*s1 != *s2)
  800a75:	0f b6 06             	movzbl (%esi),%eax
  800a78:	0f b6 1f             	movzbl (%edi),%ebx
  800a7b:	38 d8                	cmp    %bl,%al
  800a7d:	74 20                	je     800a9f <memcmp+0x3d>
  800a7f:	eb 14                	jmp    800a95 <memcmp+0x33>
  800a81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a8b:	83 c2 01             	add    $0x1,%edx
  800a8e:	83 e9 01             	sub    $0x1,%ecx
  800a91:	38 d8                	cmp    %bl,%al
  800a93:	74 12                	je     800aa7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800a95:	0f b6 c0             	movzbl %al,%eax
  800a98:	0f b6 db             	movzbl %bl,%ebx
  800a9b:	29 d8                	sub    %ebx,%eax
  800a9d:	eb 11                	jmp    800ab0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	83 e9 01             	sub    $0x1,%ecx
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	85 c9                	test   %ecx,%ecx
  800aa9:	75 d6                	jne    800a81 <memcmp+0x1f>
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac0:	39 d0                	cmp    %edx,%eax
  800ac2:	73 15                	jae    800ad9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ac8:	38 08                	cmp    %cl,(%eax)
  800aca:	75 06                	jne    800ad2 <memfind+0x1d>
  800acc:	eb 0b                	jmp    800ad9 <memfind+0x24>
  800ace:	38 08                	cmp    %cl,(%eax)
  800ad0:	74 07                	je     800ad9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	39 c2                	cmp    %eax,%edx
  800ad7:	77 f5                	ja     800ace <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aea:	0f b6 02             	movzbl (%edx),%eax
  800aed:	3c 20                	cmp    $0x20,%al
  800aef:	74 04                	je     800af5 <strtol+0x1a>
  800af1:	3c 09                	cmp    $0x9,%al
  800af3:	75 0e                	jne    800b03 <strtol+0x28>
		s++;
  800af5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	0f b6 02             	movzbl (%edx),%eax
  800afb:	3c 20                	cmp    $0x20,%al
  800afd:	74 f6                	je     800af5 <strtol+0x1a>
  800aff:	3c 09                	cmp    $0x9,%al
  800b01:	74 f2                	je     800af5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b03:	3c 2b                	cmp    $0x2b,%al
  800b05:	75 0c                	jne    800b13 <strtol+0x38>
		s++;
  800b07:	83 c2 01             	add    $0x1,%edx
  800b0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b11:	eb 15                	jmp    800b28 <strtol+0x4d>
	else if (*s == '-')
  800b13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b1a:	3c 2d                	cmp    $0x2d,%al
  800b1c:	75 0a                	jne    800b28 <strtol+0x4d>
		s++, neg = 1;
  800b1e:	83 c2 01             	add    $0x1,%edx
  800b21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	0f 94 c0             	sete   %al
  800b2d:	74 05                	je     800b34 <strtol+0x59>
  800b2f:	83 fb 10             	cmp    $0x10,%ebx
  800b32:	75 18                	jne    800b4c <strtol+0x71>
  800b34:	80 3a 30             	cmpb   $0x30,(%edx)
  800b37:	75 13                	jne    800b4c <strtol+0x71>
  800b39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3d:	8d 76 00             	lea    0x0(%esi),%esi
  800b40:	75 0a                	jne    800b4c <strtol+0x71>
		s += 2, base = 16;
  800b42:	83 c2 02             	add    $0x2,%edx
  800b45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4a:	eb 15                	jmp    800b61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4c:	84 c0                	test   %al,%al
  800b4e:	66 90                	xchg   %ax,%ax
  800b50:	74 0f                	je     800b61 <strtol+0x86>
  800b52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b57:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5a:	75 05                	jne    800b61 <strtol+0x86>
		s++, base = 8;
  800b5c:	83 c2 01             	add    $0x1,%edx
  800b5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b68:	0f b6 0a             	movzbl (%edx),%ecx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b70:	80 fb 09             	cmp    $0x9,%bl
  800b73:	77 08                	ja     800b7d <strtol+0xa2>
			dig = *s - '0';
  800b75:	0f be c9             	movsbl %cl,%ecx
  800b78:	83 e9 30             	sub    $0x30,%ecx
  800b7b:	eb 1e                	jmp    800b9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b80:	80 fb 19             	cmp    $0x19,%bl
  800b83:	77 08                	ja     800b8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b85:	0f be c9             	movsbl %cl,%ecx
  800b88:	83 e9 57             	sub    $0x57,%ecx
  800b8b:	eb 0e                	jmp    800b9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b90:	80 fb 19             	cmp    $0x19,%bl
  800b93:	77 15                	ja     800baa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800b95:	0f be c9             	movsbl %cl,%ecx
  800b98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b9b:	39 f1                	cmp    %esi,%ecx
  800b9d:	7d 0b                	jge    800baa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800b9f:	83 c2 01             	add    $0x1,%edx
  800ba2:	0f af c6             	imul   %esi,%eax
  800ba5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ba8:	eb be                	jmp    800b68 <strtol+0x8d>
  800baa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb0:	74 05                	je     800bb7 <strtol+0xdc>
		*endptr = (char *) s;
  800bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bbb:	74 04                	je     800bc1 <strtol+0xe6>
  800bbd:	89 c8                	mov    %ecx,%eax
  800bbf:	f7 d8                	neg    %eax
}
  800bc1:	83 c4 04             	add    $0x4,%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
  800bc9:	00 00                	add    %al,(%eax)
	...

00800bcc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	89 1c 24             	mov    %ebx,(%esp)
  800bd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 01 00 00 00       	mov    $0x1,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf1:	8b 1c 24             	mov    (%esp),%ebx
  800bf4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bf8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bfc:	89 ec                	mov    %ebp,%esp
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	89 1c 24             	mov    %ebx,(%esp)
  800c09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	89 c6                	mov    %eax,%esi
  800c22:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c24:	8b 1c 24             	mov    (%esp),%ebx
  800c27:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c2b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c2f:	89 ec                	mov    %ebp,%esp
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 38             	sub    $0x38,%esp
  800c39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 28                	jle    800c83 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800c66:	00 
  800c67:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800c7e:	e8 c9 0b 00 00       	call   80184c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c83:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c86:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c89:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8c:	89 ec                	mov    %ebp,%esp
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800ca1:	be 00 00 00 00       	mov    $0x0,%esi
  800ca6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb9:	8b 1c 24             	mov    (%esp),%ebx
  800cbc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc4:	89 ec                	mov    %ebp,%esp
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 38             	sub    $0x38,%esp
  800cce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 28                	jle    800d19 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf5:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800d04:	00 
  800d05:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d0c:	00 
  800d0d:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800d14:	e8 33 0b 00 00       	call   80184c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d19:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d1f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d22:	89 ec                	mov    %ebp,%esp
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 38             	sub    $0x38,%esp
  800d2c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d2f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d32:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 28                	jle    800d77 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d53:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800d62:	00 
  800d63:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d6a:	00 
  800d6b:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800d72:	e8 d5 0a 00 00       	call   80184c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d80:	89 ec                	mov    %ebp,%esp
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 38             	sub    $0x38,%esp
  800d8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d90:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 28                	jle    800dd5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db8:	00 
  800db9:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800dd0:	e8 77 0a 00 00       	call   80184c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ddb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dde:	89 ec                	mov    %ebp,%esp
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 38             	sub    $0x38,%esp
  800de8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800deb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 28                	jle    800e33 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e16:	00 
  800e17:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e26:	00 
  800e27:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800e2e:	e8 19 0a 00 00       	call   80184c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e33:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e36:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3c:	89 ec                	mov    %ebp,%esp
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 38             	sub    $0x38,%esp
  800e46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e54:	8b 75 18             	mov    0x18(%ebp),%esi
  800e57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 28                	jle    800e91 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e74:	00 
  800e75:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e84:	00 
  800e85:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800e8c:	e8 bb 09 00 00       	call   80184c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e91:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e94:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e97:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9a:	89 ec                	mov    %ebp,%esp
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 38             	sub    $0x38,%esp
  800ea4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eaa:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	be 00 00 00 00       	mov    $0x0,%esi
  800eb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	89 f7                	mov    %esi,%edi
  800ec2:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 28                	jle    800ef0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800edb:	00 
  800edc:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ee3:	00 
  800ee4:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800eeb:	e8 5c 09 00 00       	call   80184c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ef0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef9:	89 ec                	mov    %ebp,%esp
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	89 1c 24             	mov    %ebx,(%esp)
  800f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f13:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f18:	89 d1                	mov    %edx,%ecx
  800f1a:	89 d3                	mov    %edx,%ebx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	89 d6                	mov    %edx,%esi
  800f20:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f22:	8b 1c 24             	mov    (%esp),%ebx
  800f25:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f29:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f2d:	89 ec                	mov    %ebp,%esp
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	89 1c 24             	mov    %ebx,(%esp)
  800f3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f42:	ba 00 00 00 00       	mov    $0x0,%edx
  800f47:	b8 02 00 00 00       	mov    $0x2,%eax
  800f4c:	89 d1                	mov    %edx,%ecx
  800f4e:	89 d3                	mov    %edx,%ebx
  800f50:	89 d7                	mov    %edx,%edi
  800f52:	89 d6                	mov    %edx,%esi
  800f54:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f56:	8b 1c 24             	mov    (%esp),%ebx
  800f59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f61:	89 ec                	mov    %ebp,%esp
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 38             	sub    $0x38,%esp
  800f6b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f6e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f71:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f79:	b8 03 00 00 00       	mov    $0x3,%eax
  800f7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f81:	89 cb                	mov    %ecx,%ebx
  800f83:	89 cf                	mov    %ecx,%edi
  800f85:	89 ce                	mov    %ecx,%esi
  800f87:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 1f 1f 80 	movl   $0x801f1f,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  800fb0:	e8 97 08 00 00       	call   80184c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fb5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fbe:	89 ec                	mov    %ebp,%esp
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
	...

00800fd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe9:	89 04 24             	mov    %eax,(%esp)
  800fec:	e8 df ff ff ff       	call   800fd0 <fd2num>
  800ff1:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ff6:	c1 e0 0c             	shl    $0xc,%eax
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801004:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801009:	a8 01                	test   $0x1,%al
  80100b:	74 36                	je     801043 <fd_alloc+0x48>
  80100d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801012:	a8 01                	test   $0x1,%al
  801014:	74 2d                	je     801043 <fd_alloc+0x48>
  801016:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80101b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801020:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801025:	89 c3                	mov    %eax,%ebx
  801027:	89 c2                	mov    %eax,%edx
  801029:	c1 ea 16             	shr    $0x16,%edx
  80102c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80102f:	f6 c2 01             	test   $0x1,%dl
  801032:	74 14                	je     801048 <fd_alloc+0x4d>
  801034:	89 c2                	mov    %eax,%edx
  801036:	c1 ea 0c             	shr    $0xc,%edx
  801039:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80103c:	f6 c2 01             	test   $0x1,%dl
  80103f:	75 10                	jne    801051 <fd_alloc+0x56>
  801041:	eb 05                	jmp    801048 <fd_alloc+0x4d>
  801043:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801048:	89 1f                	mov    %ebx,(%edi)
  80104a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80104f:	eb 17                	jmp    801068 <fd_alloc+0x6d>
  801051:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801056:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80105b:	75 c8                	jne    801025 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80105d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801063:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801070:	8b 45 08             	mov    0x8(%ebp),%eax
  801073:	83 f8 1f             	cmp    $0x1f,%eax
  801076:	77 36                	ja     8010ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801078:	05 00 00 0d 00       	add    $0xd0000,%eax
  80107d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801080:	89 c2                	mov    %eax,%edx
  801082:	c1 ea 16             	shr    $0x16,%edx
  801085:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108c:	f6 c2 01             	test   $0x1,%dl
  80108f:	74 1d                	je     8010ae <fd_lookup+0x41>
  801091:	89 c2                	mov    %eax,%edx
  801093:	c1 ea 0c             	shr    $0xc,%edx
  801096:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109d:	f6 c2 01             	test   $0x1,%dl
  8010a0:	74 0c                	je     8010ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a5:	89 02                	mov    %eax,(%edx)
  8010a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010ac:	eb 05                	jmp    8010b3 <fd_lookup+0x46>
  8010ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	89 04 24             	mov    %eax,(%esp)
  8010c8:	e8 a0 ff ff ff       	call   80106d <fd_lookup>
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 0e                	js     8010df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d7:	89 50 04             	mov    %edx,0x4(%eax)
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 10             	sub    $0x10,%esp
  8010e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8010ef:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8010f4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010f9:	be cc 1f 80 00       	mov    $0x801fcc,%esi
		if (devtab[i]->dev_id == dev_id) {
  8010fe:	39 08                	cmp    %ecx,(%eax)
  801100:	75 10                	jne    801112 <dev_lookup+0x31>
  801102:	eb 04                	jmp    801108 <dev_lookup+0x27>
  801104:	39 08                	cmp    %ecx,(%eax)
  801106:	75 0a                	jne    801112 <dev_lookup+0x31>
			*dev = devtab[i];
  801108:	89 03                	mov    %eax,(%ebx)
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80110f:	90                   	nop
  801110:	eb 31                	jmp    801143 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801112:	83 c2 01             	add    $0x1,%edx
  801115:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801118:	85 c0                	test   %eax,%eax
  80111a:	75 e8                	jne    801104 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  80111c:	a1 24 50 80 00       	mov    0x805024,%eax
  801121:	8b 40 4c             	mov    0x4c(%eax),%eax
  801124:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112c:	c7 04 24 4c 1f 80 00 	movl   $0x801f4c,(%esp)
  801133:	e8 f5 ef ff ff       	call   80012d <cprintf>
	*dev = 0;
  801138:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	53                   	push   %ebx
  80114e:	83 ec 24             	sub    $0x24,%esp
  801151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801154:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	89 04 24             	mov    %eax,(%esp)
  801161:	e8 07 ff ff ff       	call   80106d <fd_lookup>
  801166:	85 c0                	test   %eax,%eax
  801168:	78 53                	js     8011bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801174:	8b 00                	mov    (%eax),%eax
  801176:	89 04 24             	mov    %eax,(%esp)
  801179:	e8 63 ff ff ff       	call   8010e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 3b                	js     8011bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801182:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801187:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80118e:	74 2d                	je     8011bd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801190:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801193:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80119a:	00 00 00 
	stat->st_isdir = 0;
  80119d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011a4:	00 00 00 
	stat->st_dev = dev;
  8011a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b7:	89 14 24             	mov    %edx,(%esp)
  8011ba:	ff 50 14             	call   *0x14(%eax)
}
  8011bd:	83 c4 24             	add    $0x24,%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 24             	sub    $0x24,%esp
  8011ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d4:	89 1c 24             	mov    %ebx,(%esp)
  8011d7:	e8 91 fe ff ff       	call   80106d <fd_lookup>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 5f                	js     80123f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	8b 00                	mov    (%eax),%eax
  8011ec:	89 04 24             	mov    %eax,(%esp)
  8011ef:	e8 ed fe ff ff       	call   8010e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 47                	js     80123f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011fb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8011ff:	75 23                	jne    801224 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  801201:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801206:	8b 40 4c             	mov    0x4c(%eax),%eax
  801209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801211:	c7 04 24 6c 1f 80 00 	movl   $0x801f6c,(%esp)
  801218:	e8 10 ef ff ff       	call   80012d <cprintf>
  80121d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  801222:	eb 1b                	jmp    80123f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801227:	8b 48 18             	mov    0x18(%eax),%ecx
  80122a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80122f:	85 c9                	test   %ecx,%ecx
  801231:	74 0c                	je     80123f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801233:	8b 45 0c             	mov    0xc(%ebp),%eax
  801236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123a:	89 14 24             	mov    %edx,(%esp)
  80123d:	ff d1                	call   *%ecx
}
  80123f:	83 c4 24             	add    $0x24,%esp
  801242:	5b                   	pop    %ebx
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	53                   	push   %ebx
  801249:	83 ec 24             	sub    $0x24,%esp
  80124c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801252:	89 44 24 04          	mov    %eax,0x4(%esp)
  801256:	89 1c 24             	mov    %ebx,(%esp)
  801259:	e8 0f fe ff ff       	call   80106d <fd_lookup>
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 66                	js     8012c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126c:	8b 00                	mov    (%eax),%eax
  80126e:	89 04 24             	mov    %eax,(%esp)
  801271:	e8 6b fe ff ff       	call   8010e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801276:	85 c0                	test   %eax,%eax
  801278:	78 4e                	js     8012c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80127d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801281:	75 23                	jne    8012a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801283:	a1 24 50 80 00       	mov    0x805024,%eax
  801288:	8b 40 4c             	mov    0x4c(%eax),%eax
  80128b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80128f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801293:	c7 04 24 90 1f 80 00 	movl   $0x801f90,(%esp)
  80129a:	e8 8e ee ff ff       	call   80012d <cprintf>
  80129f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012a4:	eb 22                	jmp    8012c8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8012ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b1:	85 c9                	test   %ecx,%ecx
  8012b3:	74 13                	je     8012c8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c3:	89 14 24             	mov    %edx,(%esp)
  8012c6:	ff d1                	call   *%ecx
}
  8012c8:	83 c4 24             	add    $0x24,%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 24             	sub    $0x24,%esp
  8012d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012df:	89 1c 24             	mov    %ebx,(%esp)
  8012e2:	e8 86 fd ff ff       	call   80106d <fd_lookup>
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 6b                	js     801356 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	8b 00                	mov    (%eax),%eax
  8012f7:	89 04 24             	mov    %eax,(%esp)
  8012fa:	e8 e2 fd ff ff       	call   8010e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 53                	js     801356 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801303:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801306:	8b 42 08             	mov    0x8(%edx),%eax
  801309:	83 e0 03             	and    $0x3,%eax
  80130c:	83 f8 01             	cmp    $0x1,%eax
  80130f:	75 23                	jne    801334 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801311:	a1 24 50 80 00       	mov    0x805024,%eax
  801316:	8b 40 4c             	mov    0x4c(%eax),%eax
  801319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801321:	c7 04 24 ad 1f 80 00 	movl   $0x801fad,(%esp)
  801328:	e8 00 ee ff ff       	call   80012d <cprintf>
  80132d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801332:	eb 22                	jmp    801356 <read+0x88>
	}
	if (!dev->dev_read)
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	8b 48 08             	mov    0x8(%eax),%ecx
  80133a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80133f:	85 c9                	test   %ecx,%ecx
  801341:	74 13                	je     801356 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801343:	8b 45 10             	mov    0x10(%ebp),%eax
  801346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	89 14 24             	mov    %edx,(%esp)
  801354:	ff d1                	call   *%ecx
}
  801356:	83 c4 24             	add    $0x24,%esp
  801359:	5b                   	pop    %ebx
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	57                   	push   %edi
  801360:	56                   	push   %esi
  801361:	53                   	push   %ebx
  801362:	83 ec 1c             	sub    $0x1c,%esp
  801365:	8b 7d 08             	mov    0x8(%ebp),%edi
  801368:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80136b:	ba 00 00 00 00       	mov    $0x0,%edx
  801370:	bb 00 00 00 00       	mov    $0x0,%ebx
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
  80137a:	85 f6                	test   %esi,%esi
  80137c:	74 29                	je     8013a7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80137e:	89 f0                	mov    %esi,%eax
  801380:	29 d0                	sub    %edx,%eax
  801382:	89 44 24 08          	mov    %eax,0x8(%esp)
  801386:	03 55 0c             	add    0xc(%ebp),%edx
  801389:	89 54 24 04          	mov    %edx,0x4(%esp)
  80138d:	89 3c 24             	mov    %edi,(%esp)
  801390:	e8 39 ff ff ff       	call   8012ce <read>
		if (m < 0)
  801395:	85 c0                	test   %eax,%eax
  801397:	78 0e                	js     8013a7 <readn+0x4b>
			return m;
		if (m == 0)
  801399:	85 c0                	test   %eax,%eax
  80139b:	74 08                	je     8013a5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139d:	01 c3                	add    %eax,%ebx
  80139f:	89 da                	mov    %ebx,%edx
  8013a1:	39 f3                	cmp    %esi,%ebx
  8013a3:	72 d9                	jb     80137e <readn+0x22>
  8013a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013a7:	83 c4 1c             	add    $0x1c,%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 20             	sub    $0x20,%esp
  8013b7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ba:	89 34 24             	mov    %esi,(%esp)
  8013bd:	e8 0e fc ff ff       	call   800fd0 <fd2num>
  8013c2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 9c fc ff ff       	call   80106d <fd_lookup>
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 05                	js     8013dc <fd_close+0x2d>
  8013d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013da:	74 0c                	je     8013e8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013dc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8013e0:	19 c0                	sbb    %eax,%eax
  8013e2:	f7 d0                	not    %eax
  8013e4:	21 c3                	and    %eax,%ebx
  8013e6:	eb 3d                	jmp    801425 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	8b 06                	mov    (%esi),%eax
  8013f1:	89 04 24             	mov    %eax,(%esp)
  8013f4:	e8 e8 fc ff ff       	call   8010e1 <dev_lookup>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 16                	js     801415 <fd_close+0x66>
		if (dev->dev_close)
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	8b 40 10             	mov    0x10(%eax),%eax
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 07                	je     801415 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80140e:	89 34 24             	mov    %esi,(%esp)
  801411:	ff d0                	call   *%eax
  801413:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801415:	89 74 24 04          	mov    %esi,0x4(%esp)
  801419:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801420:	e8 bd f9 ff ff       	call   800de2 <sys_page_unmap>
	return r;
}
  801425:	89 d8                	mov    %ebx,%eax
  801427:	83 c4 20             	add    $0x20,%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801434:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	89 04 24             	mov    %eax,(%esp)
  801441:	e8 27 fc ff ff       	call   80106d <fd_lookup>
  801446:	85 c0                	test   %eax,%eax
  801448:	78 13                	js     80145d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80144a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801451:	00 
  801452:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801455:	89 04 24             	mov    %eax,(%esp)
  801458:	e8 52 ff ff ff       	call   8013af <fd_close>
}
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 18             	sub    $0x18,%esp
  801465:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801468:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80146b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801472:	00 
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	89 04 24             	mov    %eax,(%esp)
  801479:	e8 4d 03 00 00       	call   8017cb <open>
  80147e:	89 c3                	mov    %eax,%ebx
  801480:	85 c0                	test   %eax,%eax
  801482:	78 1b                	js     80149f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801484:	8b 45 0c             	mov    0xc(%ebp),%eax
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148b:	89 1c 24             	mov    %ebx,(%esp)
  80148e:	e8 b7 fc ff ff       	call   80114a <fstat>
  801493:	89 c6                	mov    %eax,%esi
	close(fd);
  801495:	89 1c 24             	mov    %ebx,(%esp)
  801498:	e8 91 ff ff ff       	call   80142e <close>
  80149d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80149f:	89 d8                	mov    %ebx,%eax
  8014a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014a7:	89 ec                	mov    %ebp,%esp
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    

008014ab <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 14             	sub    $0x14,%esp
  8014b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014b7:	89 1c 24             	mov    %ebx,(%esp)
  8014ba:	e8 6f ff ff ff       	call   80142e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bf:	83 c3 01             	add    $0x1,%ebx
  8014c2:	83 fb 20             	cmp    $0x20,%ebx
  8014c5:	75 f0                	jne    8014b7 <close_all+0xc>
		close(i);
}
  8014c7:	83 c4 14             	add    $0x14,%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 58             	sub    $0x58,%esp
  8014d3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014d6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014d9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	89 04 24             	mov    %eax,(%esp)
  8014ec:	e8 7c fb ff ff       	call   80106d <fd_lookup>
  8014f1:	89 c3                	mov    %eax,%ebx
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	0f 88 e0 00 00 00    	js     8015db <dup+0x10e>
		return r;
	close(newfdnum);
  8014fb:	89 3c 24             	mov    %edi,(%esp)
  8014fe:	e8 2b ff ff ff       	call   80142e <close>

	newfd = INDEX2FD(newfdnum);
  801503:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801509:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80150c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80150f:	89 04 24             	mov    %eax,(%esp)
  801512:	e8 c9 fa ff ff       	call   800fe0 <fd2data>
  801517:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801519:	89 34 24             	mov    %esi,(%esp)
  80151c:	e8 bf fa ff ff       	call   800fe0 <fd2data>
  801521:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801524:	89 da                	mov    %ebx,%edx
  801526:	89 d8                	mov    %ebx,%eax
  801528:	c1 e8 16             	shr    $0x16,%eax
  80152b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801532:	a8 01                	test   $0x1,%al
  801534:	74 43                	je     801579 <dup+0xac>
  801536:	c1 ea 0c             	shr    $0xc,%edx
  801539:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801540:	a8 01                	test   $0x1,%al
  801542:	74 35                	je     801579 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801544:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80154b:	25 07 0e 00 00       	and    $0xe07,%eax
  801550:	89 44 24 10          	mov    %eax,0x10(%esp)
  801554:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801557:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801562:	00 
  801563:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801567:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156e:	e8 cd f8 ff ff       	call   800e40 <sys_page_map>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	85 c0                	test   %eax,%eax
  801577:	78 3f                	js     8015b8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801579:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	c1 ea 0c             	shr    $0xc,%edx
  801581:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801588:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80158e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801592:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801596:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80159d:	00 
  80159e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a9:	e8 92 f8 ff ff       	call   800e40 <sys_page_map>
  8015ae:	89 c3                	mov    %eax,%ebx
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 04                	js     8015b8 <dup+0xeb>
  8015b4:	89 fb                	mov    %edi,%ebx
  8015b6:	eb 23                	jmp    8015db <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c3:	e8 1a f8 ff ff       	call   800de2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d6:	e8 07 f8 ff ff       	call   800de2 <sys_page_unmap>
	return r;
}
  8015db:	89 d8                	mov    %ebx,%eax
  8015dd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015e0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015e3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015e6:	89 ec                	mov    %ebp,%esp
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    
  8015ea:	00 00                	add    %al,(%eax)
  8015ec:	00 00                	add    %al,(%eax)
	...

008015f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f9:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8015ff:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801606:	00 
  801607:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80160e:	00 
  80160f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801613:	89 14 24             	mov    %edx,(%esp)
  801616:	e8 95 02 00 00       	call   8018b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80161b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801622:	00 
  801623:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162e:	e8 e7 02 00 00       	call   80191a <ipc_recv>
}
  801633:	83 c4 14             	add    $0x14,%esp
  801636:	5b                   	pop    %ebx
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	8b 40 0c             	mov    0xc(%eax),%eax
  801645:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  80164a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164d:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	b8 02 00 00 00       	mov    $0x2,%eax
  80165c:	e8 8f ff ff ff       	call   8015f0 <fsipc>
}
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	8b 40 0c             	mov    0xc(%eax),%eax
  80166f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801674:	ba 00 00 00 00       	mov    $0x0,%edx
  801679:	b8 06 00 00 00       	mov    $0x6,%eax
  80167e:	e8 6d ff ff ff       	call   8015f0 <fsipc>
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 08 00 00 00       	mov    $0x8,%eax
  801695:	e8 56 ff ff ff       	call   8015f0 <fsipc>
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 14             	sub    $0x14,%esp
  8016a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ac:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016bb:	e8 30 ff ff ff       	call   8015f0 <fsipc>
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 2b                	js     8016ef <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c4:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8016cb:	00 
  8016cc:	89 1c 24             	mov    %ebx,(%esp)
  8016cf:	e8 36 f1 ff ff       	call   80080a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d4:	a1 80 30 80 00       	mov    0x803080,%eax
  8016d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016df:	a1 84 30 80 00       	mov    0x803084,%eax
  8016e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016ef:	83 c4 14             	add    $0x14,%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 18             	sub    $0x18,%esp
  8016fb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801701:	8b 52 0c             	mov    0xc(%edx),%edx
  801704:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  80170a:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80170f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801713:	8b 45 0c             	mov    0xc(%ebp),%eax
  801716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171a:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801721:	e8 9f f2 ff ff       	call   8009c5 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801726:	ba 00 30 80 00       	mov    $0x803000,%edx
  80172b:	b8 04 00 00 00       	mov    $0x4,%eax
  801730:	e8 bb fe ff ff       	call   8015f0 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801749:	8b 45 10             	mov    0x10(%ebp),%eax
  80174c:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801751:	ba 00 30 80 00       	mov    $0x803000,%edx
  801756:	b8 03 00 00 00       	mov    $0x3,%eax
  80175b:	e8 90 fe ff ff       	call   8015f0 <fsipc>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	85 c0                	test   %eax,%eax
  801764:	78 17                	js     80177d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801766:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801771:	00 
  801772:	8b 45 0c             	mov    0xc(%ebp),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 48 f2 ff ff       	call   8009c5 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80177d:	89 d8                	mov    %ebx,%eax
  80177f:	83 c4 14             	add    $0x14,%esp
  801782:	5b                   	pop    %ebx
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	83 ec 14             	sub    $0x14,%esp
  80178c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80178f:	89 1c 24             	mov    %ebx,(%esp)
  801792:	e8 29 f0 ff ff       	call   8007c0 <strlen>
  801797:	89 c2                	mov    %eax,%edx
  801799:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80179e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8017a4:	7f 1f                	jg     8017c5 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017aa:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017b1:	e8 54 f0 ff ff       	call   80080a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8017c0:	e8 2b fe ff ff       	call   8015f0 <fsipc>
}
  8017c5:	83 c4 14             	add    $0x14,%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  8017d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	e8 1f f8 ff ff       	call   800ffb <fd_alloc>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 6a                	js     80184a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017ee:	e8 17 f0 ff ff       	call   80080a <strcpy>
        fsipcbuf.open.req_omode = mode;
  8017f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f6:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fb:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801800:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801807:	00 
  801808:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80180f:	00 
  801810:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801817:	00 
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 90 00 00 00       	call   8018b0 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801820:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801827:	00 
  801828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801836:	e8 df 00 00 00       	call   80191a <ipc_recv>
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 0b                	js     80184a <open+0x7f>
		return r;
	return fd2num(fd);
  80183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801842:	89 04 24             	mov    %eax,(%esp)
  801845:	e8 86 f7 ff ff       	call   800fd0 <fd2num>
	panic("open not implemented");
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  801853:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801856:	a1 28 50 80 00       	mov    0x805028,%eax
  80185b:	85 c0                	test   %eax,%eax
  80185d:	74 10                	je     80186f <_panic+0x23>
		cprintf("%s: ", argv0);
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	c7 04 24 d4 1f 80 00 	movl   $0x801fd4,(%esp)
  80186a:	e8 be e8 ff ff       	call   80012d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80186f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801872:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187d:	a1 00 50 80 00       	mov    0x805000,%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	c7 04 24 d9 1f 80 00 	movl   $0x801fd9,(%esp)
  80188d:	e8 9b e8 ff ff       	call   80012d <cprintf>
	vcprintf(fmt, ap);
  801892:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801896:	8b 45 10             	mov    0x10(%ebp),%eax
  801899:	89 04 24             	mov    %eax,(%esp)
  80189c:	e8 2b e8 ff ff       	call   8000cc <vcprintf>
	cprintf("\n");
  8018a1:	c7 04 24 fe 1b 80 00 	movl   $0x801bfe,(%esp)
  8018a8:	e8 80 e8 ff ff       	call   80012d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018ad:	cc                   	int3   
  8018ae:	eb fd                	jmp    8018ad <_panic+0x61>

008018b0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 1c             	sub    $0x1c,%esp
  8018b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018bf:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  8018c2:	85 db                	test   %ebx,%ebx
  8018c4:	75 31                	jne    8018f7 <ipc_send+0x47>
  8018c6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8018cb:	eb 2a                	jmp    8018f7 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  8018cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018d0:	74 20                	je     8018f2 <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  8018d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d6:	c7 44 24 08 f5 1f 80 	movl   $0x801ff5,0x8(%esp)
  8018dd:	00 
  8018de:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8018e5:	00 
  8018e6:	c7 04 24 0c 20 80 00 	movl   $0x80200c,(%esp)
  8018ed:	e8 5a ff ff ff       	call   80184c <_panic>


                sys_yield();
  8018f2:	e8 06 f6 ff ff       	call   800efd <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8018f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801903:	8b 45 08             	mov    0x8(%ebp),%eax
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 82 f3 ff ff       	call   800c90 <sys_ipc_try_send>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 bb                	js     8018cd <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801912:	83 c4 1c             	add    $0x1c,%esp
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5f                   	pop    %edi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	83 ec 10             	sub    $0x10,%esp
  801922:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  80192b:	85 c0                	test   %eax,%eax
  80192d:	75 05                	jne    801934 <ipc_recv+0x1a>
  80192f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801934:	89 04 24             	mov    %eax,(%esp)
  801937:	e8 f7 f2 ff ff       	call   800c33 <sys_ipc_recv>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 24                	js     801964 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801940:	85 db                	test   %ebx,%ebx
  801942:	74 0a                	je     80194e <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801944:	a1 24 50 80 00       	mov    0x805024,%eax
  801949:	8b 40 74             	mov    0x74(%eax),%eax
  80194c:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  80194e:	85 f6                	test   %esi,%esi
  801950:	74 0a                	je     80195c <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801952:	a1 24 50 80 00       	mov    0x805024,%eax
  801957:	8b 40 78             	mov    0x78(%eax),%eax
  80195a:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  80195c:	a1 24 50 80 00       	mov    0x805024,%eax
  801961:	8b 40 70             	mov    0x70(%eax),%eax
}
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	5b                   	pop    %ebx
  801968:	5e                   	pop    %esi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    
  80196b:	00 00                	add    %al,(%eax)
  80196d:	00 00                	add    %al,(%eax)
	...

00801970 <__udivdi3>:
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	57                   	push   %edi
  801974:	56                   	push   %esi
  801975:	83 ec 10             	sub    $0x10,%esp
  801978:	8b 45 14             	mov    0x14(%ebp),%eax
  80197b:	8b 55 08             	mov    0x8(%ebp),%edx
  80197e:	8b 75 10             	mov    0x10(%ebp),%esi
  801981:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801984:	85 c0                	test   %eax,%eax
  801986:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801989:	75 35                	jne    8019c0 <__udivdi3+0x50>
  80198b:	39 fe                	cmp    %edi,%esi
  80198d:	77 61                	ja     8019f0 <__udivdi3+0x80>
  80198f:	85 f6                	test   %esi,%esi
  801991:	75 0b                	jne    80199e <__udivdi3+0x2e>
  801993:	b8 01 00 00 00       	mov    $0x1,%eax
  801998:	31 d2                	xor    %edx,%edx
  80199a:	f7 f6                	div    %esi
  80199c:	89 c6                	mov    %eax,%esi
  80199e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019a1:	31 d2                	xor    %edx,%edx
  8019a3:	89 f8                	mov    %edi,%eax
  8019a5:	f7 f6                	div    %esi
  8019a7:	89 c7                	mov    %eax,%edi
  8019a9:	89 c8                	mov    %ecx,%eax
  8019ab:	f7 f6                	div    %esi
  8019ad:	89 c1                	mov    %eax,%ecx
  8019af:	89 fa                	mov    %edi,%edx
  8019b1:	89 c8                	mov    %ecx,%eax
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	5e                   	pop    %esi
  8019b7:	5f                   	pop    %edi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    
  8019ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019c0:	39 f8                	cmp    %edi,%eax
  8019c2:	77 1c                	ja     8019e0 <__udivdi3+0x70>
  8019c4:	0f bd d0             	bsr    %eax,%edx
  8019c7:	83 f2 1f             	xor    $0x1f,%edx
  8019ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8019cd:	75 39                	jne    801a08 <__udivdi3+0x98>
  8019cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8019d2:	0f 86 a0 00 00 00    	jbe    801a78 <__udivdi3+0x108>
  8019d8:	39 f8                	cmp    %edi,%eax
  8019da:	0f 82 98 00 00 00    	jb     801a78 <__udivdi3+0x108>
  8019e0:	31 ff                	xor    %edi,%edi
  8019e2:	31 c9                	xor    %ecx,%ecx
  8019e4:	89 c8                	mov    %ecx,%eax
  8019e6:	89 fa                	mov    %edi,%edx
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	5e                   	pop    %esi
  8019ec:	5f                   	pop    %edi
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    
  8019ef:	90                   	nop
  8019f0:	89 d1                	mov    %edx,%ecx
  8019f2:	89 fa                	mov    %edi,%edx
  8019f4:	89 c8                	mov    %ecx,%eax
  8019f6:	31 ff                	xor    %edi,%edi
  8019f8:	f7 f6                	div    %esi
  8019fa:	89 c1                	mov    %eax,%ecx
  8019fc:	89 fa                	mov    %edi,%edx
  8019fe:	89 c8                	mov    %ecx,%eax
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	5e                   	pop    %esi
  801a04:	5f                   	pop    %edi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    
  801a07:	90                   	nop
  801a08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a0c:	89 f2                	mov    %esi,%edx
  801a0e:	d3 e0                	shl    %cl,%eax
  801a10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a13:	b8 20 00 00 00       	mov    $0x20,%eax
  801a18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801a1b:	89 c1                	mov    %eax,%ecx
  801a1d:	d3 ea                	shr    %cl,%edx
  801a1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a23:	0b 55 ec             	or     -0x14(%ebp),%edx
  801a26:	d3 e6                	shl    %cl,%esi
  801a28:	89 c1                	mov    %eax,%ecx
  801a2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801a2d:	89 fe                	mov    %edi,%esi
  801a2f:	d3 ee                	shr    %cl,%esi
  801a31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a3b:	d3 e7                	shl    %cl,%edi
  801a3d:	89 c1                	mov    %eax,%ecx
  801a3f:	d3 ea                	shr    %cl,%edx
  801a41:	09 d7                	or     %edx,%edi
  801a43:	89 f2                	mov    %esi,%edx
  801a45:	89 f8                	mov    %edi,%eax
  801a47:	f7 75 ec             	divl   -0x14(%ebp)
  801a4a:	89 d6                	mov    %edx,%esi
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	f7 65 e8             	mull   -0x18(%ebp)
  801a51:	39 d6                	cmp    %edx,%esi
  801a53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a56:	72 30                	jb     801a88 <__udivdi3+0x118>
  801a58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a5f:	d3 e2                	shl    %cl,%edx
  801a61:	39 c2                	cmp    %eax,%edx
  801a63:	73 05                	jae    801a6a <__udivdi3+0xfa>
  801a65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801a68:	74 1e                	je     801a88 <__udivdi3+0x118>
  801a6a:	89 f9                	mov    %edi,%ecx
  801a6c:	31 ff                	xor    %edi,%edi
  801a6e:	e9 71 ff ff ff       	jmp    8019e4 <__udivdi3+0x74>
  801a73:	90                   	nop
  801a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a78:	31 ff                	xor    %edi,%edi
  801a7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a7f:	e9 60 ff ff ff       	jmp    8019e4 <__udivdi3+0x74>
  801a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801a8b:	31 ff                	xor    %edi,%edi
  801a8d:	89 c8                	mov    %ecx,%eax
  801a8f:	89 fa                	mov    %edi,%edx
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    
	...

00801aa0 <__umoddi3>:
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	83 ec 20             	sub    $0x20,%esp
  801aa8:	8b 55 14             	mov    0x14(%ebp),%edx
  801aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aae:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab4:	85 d2                	test   %edx,%edx
  801ab6:	89 c8                	mov    %ecx,%eax
  801ab8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801abb:	75 13                	jne    801ad0 <__umoddi3+0x30>
  801abd:	39 f7                	cmp    %esi,%edi
  801abf:	76 3f                	jbe    801b00 <__umoddi3+0x60>
  801ac1:	89 f2                	mov    %esi,%edx
  801ac3:	f7 f7                	div    %edi
  801ac5:	89 d0                	mov    %edx,%eax
  801ac7:	31 d2                	xor    %edx,%edx
  801ac9:	83 c4 20             	add    $0x20,%esp
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    
  801ad0:	39 f2                	cmp    %esi,%edx
  801ad2:	77 4c                	ja     801b20 <__umoddi3+0x80>
  801ad4:	0f bd ca             	bsr    %edx,%ecx
  801ad7:	83 f1 1f             	xor    $0x1f,%ecx
  801ada:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801add:	75 51                	jne    801b30 <__umoddi3+0x90>
  801adf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801ae2:	0f 87 e0 00 00 00    	ja     801bc8 <__umoddi3+0x128>
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	29 f8                	sub    %edi,%eax
  801aed:	19 d6                	sbb    %edx,%esi
  801aef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	89 f2                	mov    %esi,%edx
  801af7:	83 c4 20             	add    $0x20,%esp
  801afa:	5e                   	pop    %esi
  801afb:	5f                   	pop    %edi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    
  801afe:	66 90                	xchg   %ax,%ax
  801b00:	85 ff                	test   %edi,%edi
  801b02:	75 0b                	jne    801b0f <__umoddi3+0x6f>
  801b04:	b8 01 00 00 00       	mov    $0x1,%eax
  801b09:	31 d2                	xor    %edx,%edx
  801b0b:	f7 f7                	div    %edi
  801b0d:	89 c7                	mov    %eax,%edi
  801b0f:	89 f0                	mov    %esi,%eax
  801b11:	31 d2                	xor    %edx,%edx
  801b13:	f7 f7                	div    %edi
  801b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b18:	f7 f7                	div    %edi
  801b1a:	eb a9                	jmp    801ac5 <__umoddi3+0x25>
  801b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b20:	89 c8                	mov    %ecx,%eax
  801b22:	89 f2                	mov    %esi,%edx
  801b24:	83 c4 20             	add    $0x20,%esp
  801b27:	5e                   	pop    %esi
  801b28:	5f                   	pop    %edi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    
  801b2b:	90                   	nop
  801b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b34:	d3 e2                	shl    %cl,%edx
  801b36:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b39:	ba 20 00 00 00       	mov    $0x20,%edx
  801b3e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801b41:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b44:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b48:	89 fa                	mov    %edi,%edx
  801b4a:	d3 ea                	shr    %cl,%edx
  801b4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b50:	0b 55 f4             	or     -0xc(%ebp),%edx
  801b53:	d3 e7                	shl    %cl,%edi
  801b55:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b59:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b5c:	89 f2                	mov    %esi,%edx
  801b5e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801b61:	89 c7                	mov    %eax,%edi
  801b63:	d3 ea                	shr    %cl,%edx
  801b65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b6c:	89 c2                	mov    %eax,%edx
  801b6e:	d3 e6                	shl    %cl,%esi
  801b70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b74:	d3 ea                	shr    %cl,%edx
  801b76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b7a:	09 d6                	or     %edx,%esi
  801b7c:	89 f0                	mov    %esi,%eax
  801b7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801b81:	d3 e7                	shl    %cl,%edi
  801b83:	89 f2                	mov    %esi,%edx
  801b85:	f7 75 f4             	divl   -0xc(%ebp)
  801b88:	89 d6                	mov    %edx,%esi
  801b8a:	f7 65 e8             	mull   -0x18(%ebp)
  801b8d:	39 d6                	cmp    %edx,%esi
  801b8f:	72 2b                	jb     801bbc <__umoddi3+0x11c>
  801b91:	39 c7                	cmp    %eax,%edi
  801b93:	72 23                	jb     801bb8 <__umoddi3+0x118>
  801b95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b99:	29 c7                	sub    %eax,%edi
  801b9b:	19 d6                	sbb    %edx,%esi
  801b9d:	89 f0                	mov    %esi,%eax
  801b9f:	89 f2                	mov    %esi,%edx
  801ba1:	d3 ef                	shr    %cl,%edi
  801ba3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ba7:	d3 e0                	shl    %cl,%eax
  801ba9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bad:	09 f8                	or     %edi,%eax
  801baf:	d3 ea                	shr    %cl,%edx
  801bb1:	83 c4 20             	add    $0x20,%esp
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	39 d6                	cmp    %edx,%esi
  801bba:	75 d9                	jne    801b95 <__umoddi3+0xf5>
  801bbc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801bbf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801bc2:	eb d1                	jmp    801b95 <__umoddi3+0xf5>
  801bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	0f 82 18 ff ff ff    	jb     801ae8 <__umoddi3+0x48>
  801bd0:	e9 1d ff ff ff       	jmp    801af2 <__umoddi3+0x52>
