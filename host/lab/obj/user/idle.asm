
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
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
	binaryname = "idle";
  80003a:	c7 05 00 50 80 00 00 	movl   $0x801c00,0x805000
  800041:	1c 80 00 
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	int a[] = {3};
	while (1) {
		cprintf("going to yield idle\n");
  800044:	c7 04 24 05 1c 80 00 	movl   $0x801c05,(%esp)
  80004b:	e8 ed 00 00 00       	call   80013d <cprintf>
		sys_yield();
  800050:	e8 b8 0e 00 00       	call   800f0d <sys_yield>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800055:	cc                   	int3   
  800056:	eb ec                	jmp    800044 <umain+0x10>

00800058 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	83 ec 18             	sub    $0x18,%esp
  80005e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800061:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80006a:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  800071:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800074:	e8 c8 0e 00 00       	call   800f41 <sys_getenvid>
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 f6                	test   %esi,%esi
  80008d:	7e 07                	jle    800096 <libmain+0x3e>
		binaryname = argv[0];
  80008f:	8b 03                	mov    (%ebx),%eax
  800091:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  800096:	c7 04 24 1a 1c 80 00 	movl   $0x801c1a,(%esp)
  80009d:	e8 9b 00 00 00       	call   80013d <cprintf>
	umain(argc, argv);
  8000a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a6:	89 34 24             	mov    %esi,(%esp)
  8000a9:	e8 86 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ae:	e8 0d 00 00 00       	call   8000c0 <exit>
}
  8000b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b9:	89 ec                	mov    %ebp,%esp
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000c6:	e8 f0 13 00 00       	call   8014bb <close_all>
	sys_env_destroy(0);
  8000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d2:	e8 9e 0e 00 00       	call   800f75 <sys_env_destroy>
}
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    
  8000d9:	00 00                	add    %al,(%eax)
	...

008000dc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000ec:	00 00 00 
	b.cnt = 0;
  8000ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800100:	8b 45 08             	mov    0x8(%ebp),%eax
  800103:	89 44 24 08          	mov    %eax,0x8(%esp)
  800107:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80010d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800111:	c7 04 24 57 01 80 00 	movl   $0x800157,(%esp)
  800118:	e8 d0 01 00 00       	call   8002ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	89 04 24             	mov    %eax,(%esp)
  800130:	e8 db 0a 00 00       	call   800c10 <sys_cputs>

	return b.cnt;
}
  800135:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    

0080013d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800143:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	8b 45 08             	mov    0x8(%ebp),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 87 ff ff ff       	call   8000dc <vcprintf>
	va_end(ap);

	return cnt;
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	53                   	push   %ebx
  80015b:	83 ec 14             	sub    $0x14,%esp
  80015e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800161:	8b 03                	mov    (%ebx),%eax
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016a:	83 c0 01             	add    $0x1,%eax
  80016d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800174:	75 19                	jne    80018f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800176:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017d:	00 
  80017e:	8d 43 08             	lea    0x8(%ebx),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 87 0a 00 00       	call   800c10 <sys_cputs>
		b->idx = 0;
  800189:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	83 c4 14             	add    $0x14,%esp
  800196:	5b                   	pop    %ebx
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
  80019b:	00 00                	add    %al,(%eax)
  80019d:	00 00                	add    %al,(%eax)
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 4c             	sub    $0x4c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001cb:	39 d1                	cmp    %edx,%ecx
  8001cd:	72 15                	jb     8001e4 <printnum+0x44>
  8001cf:	77 07                	ja     8001d8 <printnum+0x38>
  8001d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d4:	39 d0                	cmp    %edx,%eax
  8001d6:	76 0c                	jbe    8001e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	8d 76 00             	lea    0x0(%esi),%esi
  8001e0:	7f 61                	jg     800243 <printnum+0xa3>
  8001e2:	eb 70                	jmp    800254 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800201:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800204:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800219:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021d:	e8 5e 17 00 00       	call   801980 <__udivdi3>
  800222:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800225:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	89 54 24 04          	mov    %edx,0x4(%esp)
  800237:	89 f2                	mov    %esi,%edx
  800239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023c:	e8 5f ff ff ff       	call   8001a0 <printnum>
  800241:	eb 11                	jmp    800254 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800243:	89 74 24 04          	mov    %esi,0x4(%esp)
  800247:	89 3c 24             	mov    %edi,(%esp)
  80024a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024d:	83 eb 01             	sub    $0x1,%ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f ef                	jg     800243 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800254:	89 74 24 04          	mov    %esi,0x4(%esp)
  800258:	8b 74 24 04          	mov    0x4(%esp),%esi
  80025c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800263:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026a:	00 
  80026b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80026e:	89 14 24             	mov    %edx,(%esp)
  800271:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800274:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800278:	e8 33 18 00 00       	call   801ab0 <__umoddi3>
  80027d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800281:	0f be 80 43 1c 80 00 	movsbl 0x801c43(%eax),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028e:	83 c4 4c             	add    $0x4c,%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800299:	83 fa 01             	cmp    $0x1,%edx
  80029c:	7e 0e                	jle    8002ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	8b 52 04             	mov    0x4(%edx),%edx
  8002aa:	eb 22                	jmp    8002ce <getuint+0x38>
	else if (lflag)
  8002ac:	85 d2                	test   %edx,%edx
  8002ae:	74 10                	je     8002c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 0e                	jmp    8002ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002df:	73 0a                	jae    8002eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e4:	88 0a                	mov    %cl,(%edx)
  8002e6:	83 c2 01             	add    $0x1,%edx
  8002e9:	89 10                	mov    %edx,(%eax)
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 5c             	sub    $0x5c,%esp
  8002f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800306:	eb 11                	jmp    800319 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800308:	85 c0                	test   %eax,%eax
  80030a:	0f 84 02 04 00 00    	je     800712 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800310:	89 74 24 04          	mov    %esi,0x4(%esp)
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800319:	0f b6 03             	movzbl (%ebx),%eax
  80031c:	83 c3 01             	add    $0x1,%ebx
  80031f:	83 f8 25             	cmp    $0x25,%eax
  800322:	75 e4                	jne    800308 <vprintfmt+0x1b>
  800324:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800328:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800336:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	eb 06                	jmp    80034a <vprintfmt+0x5d>
  800344:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800348:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	0f b6 13             	movzbl (%ebx),%edx
  80034d:	0f b6 c2             	movzbl %dl,%eax
  800350:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800353:	8d 43 01             	lea    0x1(%ebx),%eax
  800356:	83 ea 23             	sub    $0x23,%edx
  800359:	80 fa 55             	cmp    $0x55,%dl
  80035c:	0f 87 93 03 00 00    	ja     8006f5 <vprintfmt+0x408>
  800362:	0f b6 d2             	movzbl %dl,%edx
  800365:	ff 24 95 80 1d 80 00 	jmp    *0x801d80(,%edx,4)
  80036c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800370:	eb d6                	jmp    800348 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800372:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800375:	83 ea 30             	sub    $0x30,%edx
  800378:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80037b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80037e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800381:	83 fb 09             	cmp    $0x9,%ebx
  800384:	77 4c                	ja     8003d2 <vprintfmt+0xe5>
  800386:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800389:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80038f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800392:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800396:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800399:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80039c:	83 fb 09             	cmp    $0x9,%ebx
  80039f:	76 eb                	jbe    80038c <vprintfmt+0x9f>
  8003a1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a7:	eb 29                	jmp    8003d2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ac:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003af:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003b2:	8b 12                	mov    (%edx),%edx
  8003b4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003b7:	eb 19                	jmp    8003d2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8003b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bc:	c1 fa 1f             	sar    $0x1f,%edx
  8003bf:	f7 d2                	not    %edx
  8003c1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8003c4:	eb 82                	jmp    800348 <vprintfmt+0x5b>
  8003c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003cd:	e9 76 ff ff ff       	jmp    800348 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d6:	0f 89 6c ff ff ff    	jns    800348 <vprintfmt+0x5b>
  8003dc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003e2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003e5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003e8:	e9 5b ff ff ff       	jmp    800348 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ed:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003f0:	e9 53 ff ff ff       	jmp    800348 <vprintfmt+0x5b>
  8003f5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	89 74 24 04          	mov    %esi,0x4(%esp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	ff d7                	call   *%edi
  80040c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80040f:	e9 05 ff ff ff       	jmp    800319 <vprintfmt+0x2c>
  800414:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 c2                	mov    %eax,%edx
  800424:	c1 fa 1f             	sar    $0x1f,%edx
  800427:	31 d0                	xor    %edx,%eax
  800429:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80042b:	83 f8 0f             	cmp    $0xf,%eax
  80042e:	7f 0b                	jg     80043b <vprintfmt+0x14e>
  800430:	8b 14 85 e0 1e 80 00 	mov    0x801ee0(,%eax,4),%edx
  800437:	85 d2                	test   %edx,%edx
  800439:	75 20                	jne    80045b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80043b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043f:	c7 44 24 08 54 1c 80 	movl   $0x801c54,0x8(%esp)
  800446:	00 
  800447:	89 74 24 04          	mov    %esi,0x4(%esp)
  80044b:	89 3c 24             	mov    %edi,(%esp)
  80044e:	e8 47 03 00 00       	call   80079a <printfmt>
  800453:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800456:	e9 be fe ff ff       	jmp    800319 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80045b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045f:	c7 44 24 08 5d 1c 80 	movl   $0x801c5d,0x8(%esp)
  800466:	00 
  800467:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046b:	89 3c 24             	mov    %edi,(%esp)
  80046e:	e8 27 03 00 00       	call   80079a <printfmt>
  800473:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800476:	e9 9e fe ff ff       	jmp    800319 <vprintfmt+0x2c>
  80047b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047e:	89 c3                	mov    %eax,%ebx
  800480:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800486:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800497:	85 c0                	test   %eax,%eax
  800499:	75 07                	jne    8004a2 <vprintfmt+0x1b5>
  80049b:	c7 45 e0 60 1c 80 00 	movl   $0x801c60,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004a2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004a6:	7e 06                	jle    8004ae <vprintfmt+0x1c1>
  8004a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ac:	75 13                	jne    8004c1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b1:	0f be 02             	movsbl (%edx),%eax
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	0f 85 99 00 00 00    	jne    800555 <vprintfmt+0x268>
  8004bc:	e9 86 00 00 00       	jmp    800547 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	89 0c 24             	mov    %ecx,(%esp)
  8004cb:	e8 1b 03 00 00       	call   8007eb <strnlen>
  8004d0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	7e d2                	jle    8004ae <vprintfmt+0x1c1>
					putch(padc, putdat);
  8004dc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8004e0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004e3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004e6:	89 d3                	mov    %edx,%ebx
  8004e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 eb 01             	sub    $0x1,%ebx
  8004f7:	85 db                	test   %ebx,%ebx
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1fb>
  8004fb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800505:	eb a7                	jmp    8004ae <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050b:	74 18                	je     800525 <vprintfmt+0x238>
  80050d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800510:	83 fa 5e             	cmp    $0x5e,%edx
  800513:	76 10                	jbe    800525 <vprintfmt+0x238>
					putch('?', putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800520:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800523:	eb 0a                	jmp    80052f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800533:	0f be 03             	movsbl (%ebx),%eax
  800536:	85 c0                	test   %eax,%eax
  800538:	74 05                	je     80053f <vprintfmt+0x252>
  80053a:	83 c3 01             	add    $0x1,%ebx
  80053d:	eb 29                	jmp    800568 <vprintfmt+0x27b>
  80053f:	89 fe                	mov    %edi,%esi
  800541:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800544:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054b:	7f 2e                	jg     80057b <vprintfmt+0x28e>
  80054d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800550:	e9 c4 fd ff ff       	jmp    800319 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800555:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800558:	83 c2 01             	add    $0x1,%edx
  80055b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80055e:	89 f7                	mov    %esi,%edi
  800560:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800563:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800566:	89 d3                	mov    %edx,%ebx
  800568:	85 f6                	test   %esi,%esi
  80056a:	78 9b                	js     800507 <vprintfmt+0x21a>
  80056c:	83 ee 01             	sub    $0x1,%esi
  80056f:	79 96                	jns    800507 <vprintfmt+0x21a>
  800571:	89 fe                	mov    %edi,%esi
  800573:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800576:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800579:	eb cc                	jmp    800547 <vprintfmt+0x25a>
  80057b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80057e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80058c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058e:	83 eb 01             	sub    $0x1,%ebx
  800591:	85 db                	test   %ebx,%ebx
  800593:	7f ec                	jg     800581 <vprintfmt+0x294>
  800595:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800598:	e9 7c fd ff ff       	jmp    800319 <vprintfmt+0x2c>
  80059d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a0:	83 f9 01             	cmp    $0x1,%ecx
  8005a3:	7e 16                	jle    8005bb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 08             	lea    0x8(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 10                	mov    (%eax),%edx
  8005b0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b9:	eb 32                	jmp    8005ed <vprintfmt+0x300>
	else if (lflag)
  8005bb:	85 c9                	test   %ecx,%ecx
  8005bd:	74 18                	je     8005d7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 04             	lea    0x4(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cd:	89 c1                	mov    %eax,%ecx
  8005cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d5:	eb 16                	jmp    8005ed <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 04             	lea    0x4(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 c2                	mov    %eax,%edx
  8005e7:	c1 fa 1f             	sar    $0x1f,%edx
  8005ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f3:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8005f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fc:	0f 89 b1 00 00 00    	jns    8006b3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800602:	89 74 24 04          	mov    %esi,0x4(%esp)
  800606:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060d:	ff d7                	call   *%edi
				num = -(long long) num;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	e9 92 00 00 00       	jmp    8006b3 <vprintfmt+0x3c6>
  800621:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 68 fc ff ff       	call   800296 <getuint>
  80062e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800633:	eb 7e                	jmp    8006b3 <vprintfmt+0x3c6>
  800635:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 54 fc ff ff       	call   800296 <getuint>
			if ((long long) num < 0) {
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800648:	bb 08 00 00 00       	mov    $0x8,%ebx
  80064d:	85 d2                	test   %edx,%edx
  80064f:	79 62                	jns    8006b3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800651:	89 74 24 04          	mov    %esi,0x4(%esp)
  800655:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065c:	ff d7                	call   *%edi
				num = -(long long) num;
  80065e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800661:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800664:	f7 d8                	neg    %eax
  800666:	83 d2 00             	adc    $0x0,%edx
  800669:	f7 da                	neg    %edx
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x3c6>
  80066d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800670:	89 74 24 04          	mov    %esi,0x4(%esp)
  800674:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067b:	ff d7                	call   *%edi
			putch('x', putdat);
  80067d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800681:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800688:	ff d7                	call   *%edi
			num = (unsigned long long)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	ba 00 00 00 00       	mov    $0x0,%edx
  80069a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069f:	eb 12                	jmp    8006b3 <vprintfmt+0x3c6>
  8006a1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a4:	89 ca                	mov    %ecx,%edx
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 e8 fb ff ff       	call   800296 <getuint>
  8006ae:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006b7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006bb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006c6:	89 04 24             	mov    %eax,(%esp)
  8006c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006cd:	89 f2                	mov    %esi,%edx
  8006cf:	89 f8                	mov    %edi,%eax
  8006d1:	e8 ca fa ff ff       	call   8001a0 <printnum>
  8006d6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006d9:	e9 3b fc ff ff       	jmp    800319 <vprintfmt+0x2c>
  8006de:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006e1:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e8:	89 14 24             	mov    %edx,(%esp)
  8006eb:	ff d7                	call   *%edi
  8006ed:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006f0:	e9 24 fc ff ff       	jmp    800319 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800700:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800702:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800705:	80 38 25             	cmpb   $0x25,(%eax)
  800708:	0f 84 0b fc ff ff    	je     800319 <vprintfmt+0x2c>
  80070e:	89 c3                	mov    %eax,%ebx
  800710:	eb f0                	jmp    800702 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800712:	83 c4 5c             	add    $0x5c,%esp
  800715:	5b                   	pop    %ebx
  800716:	5e                   	pop    %esi
  800717:	5f                   	pop    %edi
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 28             	sub    $0x28,%esp
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800726:	85 c0                	test   %eax,%eax
  800728:	74 04                	je     80072e <vsnprintf+0x14>
  80072a:	85 d2                	test   %edx,%edx
  80072c:	7f 07                	jg     800735 <vsnprintf+0x1b>
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800733:	eb 3b                	jmp    800770 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800738:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80073c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80073f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074d:	8b 45 10             	mov    0x10(%ebp),%eax
  800750:	89 44 24 08          	mov    %eax,0x8(%esp)
  800754:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075b:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  800762:	e8 86 fb ff ff       	call   8002ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800767:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80077b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077f:	8b 45 10             	mov    0x10(%ebp),%eax
  800782:	89 44 24 08          	mov    %eax,0x8(%esp)
  800786:	8b 45 0c             	mov    0xc(%ebp),%eax
  800789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	e8 82 ff ff ff       	call   80071a <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	e8 2d fb ff ff       	call   8002ed <vprintfmt>
	va_end(ap);
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    
	...

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	80 3a 00             	cmpb   $0x0,(%edx)
  8007de:	74 09                	je     8007e9 <strlen+0x19>
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e7:	75 f7                	jne    8007e0 <strlen+0x10>
		n++;
	return n;
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f5:	85 c9                	test   %ecx,%ecx
  8007f7:	74 19                	je     800812 <strnlen+0x27>
  8007f9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007fc:	74 14                	je     800812 <strnlen+0x27>
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800803:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800806:	39 c8                	cmp    %ecx,%eax
  800808:	74 0d                	je     800817 <strnlen+0x2c>
  80080a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80080e:	75 f3                	jne    800803 <strnlen+0x18>
  800810:	eb 05                	jmp    800817 <strnlen+0x2c>
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800824:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800829:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80082d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	84 c9                	test   %cl,%cl
  800835:	75 f2                	jne    800829 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800848:	85 f6                	test   %esi,%esi
  80084a:	74 18                	je     800864 <strncpy+0x2a>
  80084c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800851:	0f b6 1a             	movzbl (%edx),%ebx
  800854:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800857:	80 3a 01             	cmpb   $0x1,(%edx)
  80085a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	39 ce                	cmp    %ecx,%esi
  800862:	77 ed                	ja     800851 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	89 f0                	mov    %esi,%eax
  800878:	85 c9                	test   %ecx,%ecx
  80087a:	74 27                	je     8008a3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80087c:	83 e9 01             	sub    $0x1,%ecx
  80087f:	74 1d                	je     80089e <strlcpy+0x36>
  800881:	0f b6 1a             	movzbl (%edx),%ebx
  800884:	84 db                	test   %bl,%bl
  800886:	74 16                	je     80089e <strlcpy+0x36>
			*dst++ = *src++;
  800888:	88 18                	mov    %bl,(%eax)
  80088a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088d:	83 e9 01             	sub    $0x1,%ecx
  800890:	74 0e                	je     8008a0 <strlcpy+0x38>
			*dst++ = *src++;
  800892:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800895:	0f b6 1a             	movzbl (%edx),%ebx
  800898:	84 db                	test   %bl,%bl
  80089a:	75 ec                	jne    800888 <strlcpy+0x20>
  80089c:	eb 02                	jmp    8008a0 <strlcpy+0x38>
  80089e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a0:	c6 00 00             	movb   $0x0,(%eax)
  8008a3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b2:	0f b6 01             	movzbl (%ecx),%eax
  8008b5:	84 c0                	test   %al,%al
  8008b7:	74 15                	je     8008ce <strcmp+0x25>
  8008b9:	3a 02                	cmp    (%edx),%al
  8008bb:	75 11                	jne    8008ce <strcmp+0x25>
		p++, q++;
  8008bd:	83 c1 01             	add    $0x1,%ecx
  8008c0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	0f b6 01             	movzbl (%ecx),%eax
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 04                	je     8008ce <strcmp+0x25>
  8008ca:	3a 02                	cmp    (%edx),%al
  8008cc:	74 ef                	je     8008bd <strcmp+0x14>
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	74 23                	je     80090c <strncmp+0x34>
  8008e9:	0f b6 1a             	movzbl (%edx),%ebx
  8008ec:	84 db                	test   %bl,%bl
  8008ee:	74 24                	je     800914 <strncmp+0x3c>
  8008f0:	3a 19                	cmp    (%ecx),%bl
  8008f2:	75 20                	jne    800914 <strncmp+0x3c>
  8008f4:	83 e8 01             	sub    $0x1,%eax
  8008f7:	74 13                	je     80090c <strncmp+0x34>
		n--, p++, q++;
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ff:	0f b6 1a             	movzbl (%edx),%ebx
  800902:	84 db                	test   %bl,%bl
  800904:	74 0e                	je     800914 <strncmp+0x3c>
  800906:	3a 19                	cmp    (%ecx),%bl
  800908:	74 ea                	je     8008f4 <strncmp+0x1c>
  80090a:	eb 08                	jmp    800914 <strncmp+0x3c>
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800914:	0f b6 02             	movzbl (%edx),%eax
  800917:	0f b6 11             	movzbl (%ecx),%edx
  80091a:	29 d0                	sub    %edx,%eax
  80091c:	eb f3                	jmp    800911 <strncmp+0x39>

0080091e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 15                	je     800944 <strchr+0x26>
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	75 07                	jne    80093a <strchr+0x1c>
  800933:	eb 14                	jmp    800949 <strchr+0x2b>
  800935:	38 ca                	cmp    %cl,%dl
  800937:	90                   	nop
  800938:	74 0f                	je     800949 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f1                	jne    800935 <strchr+0x17>
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	74 18                	je     800974 <strfind+0x29>
		if (*s == c)
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	75 0a                	jne    80096a <strfind+0x1f>
  800960:	eb 12                	jmp    800974 <strfind+0x29>
  800962:	38 ca                	cmp    %cl,%dl
  800964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800968:	74 0a                	je     800974 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	75 ee                	jne    800962 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 0c             	sub    $0xc,%esp
  80097c:	89 1c 24             	mov    %ebx,(%esp)
  80097f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800983:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800987:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800990:	85 c9                	test   %ecx,%ecx
  800992:	74 30                	je     8009c4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800994:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099a:	75 25                	jne    8009c1 <memset+0x4b>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 20                	jne    8009c1 <memset+0x4b>
		c &= 0xFF;
  8009a1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a4:	89 d3                	mov    %edx,%ebx
  8009a6:	c1 e3 08             	shl    $0x8,%ebx
  8009a9:	89 d6                	mov    %edx,%esi
  8009ab:	c1 e6 18             	shl    $0x18,%esi
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	c1 e0 10             	shl    $0x10,%eax
  8009b3:	09 f0                	or     %esi,%eax
  8009b5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009b7:	09 d8                	or     %ebx,%eax
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
  8009bc:	fc                   	cld    
  8009bd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bf:	eb 03                	jmp    8009c4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c1:	fc                   	cld    
  8009c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	8b 1c 24             	mov    (%esp),%ebx
  8009c9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009cd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009d1:	89 ec                	mov    %ebp,%esp
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	89 34 24             	mov    %esi,(%esp)
  8009de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009eb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009ed:	39 c6                	cmp    %eax,%esi
  8009ef:	73 35                	jae    800a26 <memmove+0x51>
  8009f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f4:	39 d0                	cmp    %edx,%eax
  8009f6:	73 2e                	jae    800a26 <memmove+0x51>
		s += n;
		d += n;
  8009f8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	f6 c2 03             	test   $0x3,%dl
  8009fd:	75 1b                	jne    800a1a <memmove+0x45>
  8009ff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a05:	75 13                	jne    800a1a <memmove+0x45>
  800a07:	f6 c1 03             	test   $0x3,%cl
  800a0a:	75 0e                	jne    800a1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a0c:	83 ef 04             	sub    $0x4,%edi
  800a0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a12:	c1 e9 02             	shr    $0x2,%ecx
  800a15:	fd                   	std    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a18:	eb 09                	jmp    800a23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1a:	83 ef 01             	sub    $0x1,%edi
  800a1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a20:	fd                   	std    
  800a21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a24:	eb 20                	jmp    800a46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2c:	75 15                	jne    800a43 <memmove+0x6e>
  800a2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a34:	75 0d                	jne    800a43 <memmove+0x6e>
  800a36:	f6 c1 03             	test   $0x3,%cl
  800a39:	75 08                	jne    800a43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fc                   	cld    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a41:	eb 03                	jmp    800a46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a43:	fc                   	cld    
  800a44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a46:	8b 34 24             	mov    (%esp),%esi
  800a49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a4d:	89 ec                	mov    %ebp,%esp
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a57:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	89 04 24             	mov    %eax,(%esp)
  800a6b:	e8 65 ff ff ff       	call   8009d5 <memmove>
}
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 36                	je     800abb <memcmp+0x49>
		if (*s1 != *s2)
  800a85:	0f b6 06             	movzbl (%esi),%eax
  800a88:	0f b6 1f             	movzbl (%edi),%ebx
  800a8b:	38 d8                	cmp    %bl,%al
  800a8d:	74 20                	je     800aaf <memcmp+0x3d>
  800a8f:	eb 14                	jmp    800aa5 <memcmp+0x33>
  800a91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a9b:	83 c2 01             	add    $0x1,%edx
  800a9e:	83 e9 01             	sub    $0x1,%ecx
  800aa1:	38 d8                	cmp    %bl,%al
  800aa3:	74 12                	je     800ab7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800aa5:	0f b6 c0             	movzbl %al,%eax
  800aa8:	0f b6 db             	movzbl %bl,%ebx
  800aab:	29 d8                	sub    %ebx,%eax
  800aad:	eb 11                	jmp    800ac0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	83 e9 01             	sub    $0x1,%ecx
  800ab2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab7:	85 c9                	test   %ecx,%ecx
  800ab9:	75 d6                	jne    800a91 <memcmp+0x1f>
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad0:	39 d0                	cmp    %edx,%eax
  800ad2:	73 15                	jae    800ae9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ad8:	38 08                	cmp    %cl,(%eax)
  800ada:	75 06                	jne    800ae2 <memfind+0x1d>
  800adc:	eb 0b                	jmp    800ae9 <memfind+0x24>
  800ade:	38 08                	cmp    %cl,(%eax)
  800ae0:	74 07                	je     800ae9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	39 c2                	cmp    %eax,%edx
  800ae7:	77 f5                	ja     800ade <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	83 ec 04             	sub    $0x4,%esp
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	0f b6 02             	movzbl (%edx),%eax
  800afd:	3c 20                	cmp    $0x20,%al
  800aff:	74 04                	je     800b05 <strtol+0x1a>
  800b01:	3c 09                	cmp    $0x9,%al
  800b03:	75 0e                	jne    800b13 <strtol+0x28>
		s++;
  800b05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b08:	0f b6 02             	movzbl (%edx),%eax
  800b0b:	3c 20                	cmp    $0x20,%al
  800b0d:	74 f6                	je     800b05 <strtol+0x1a>
  800b0f:	3c 09                	cmp    $0x9,%al
  800b11:	74 f2                	je     800b05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b13:	3c 2b                	cmp    $0x2b,%al
  800b15:	75 0c                	jne    800b23 <strtol+0x38>
		s++;
  800b17:	83 c2 01             	add    $0x1,%edx
  800b1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b21:	eb 15                	jmp    800b38 <strtol+0x4d>
	else if (*s == '-')
  800b23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b2a:	3c 2d                	cmp    $0x2d,%al
  800b2c:	75 0a                	jne    800b38 <strtol+0x4d>
		s++, neg = 1;
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	85 db                	test   %ebx,%ebx
  800b3a:	0f 94 c0             	sete   %al
  800b3d:	74 05                	je     800b44 <strtol+0x59>
  800b3f:	83 fb 10             	cmp    $0x10,%ebx
  800b42:	75 18                	jne    800b5c <strtol+0x71>
  800b44:	80 3a 30             	cmpb   $0x30,(%edx)
  800b47:	75 13                	jne    800b5c <strtol+0x71>
  800b49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b4d:	8d 76 00             	lea    0x0(%esi),%esi
  800b50:	75 0a                	jne    800b5c <strtol+0x71>
		s += 2, base = 16;
  800b52:	83 c2 02             	add    $0x2,%edx
  800b55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5a:	eb 15                	jmp    800b71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5c:	84 c0                	test   %al,%al
  800b5e:	66 90                	xchg   %ax,%ax
  800b60:	74 0f                	je     800b71 <strtol+0x86>
  800b62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b67:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6a:	75 05                	jne    800b71 <strtol+0x86>
		s++, base = 8;
  800b6c:	83 c2 01             	add    $0x1,%edx
  800b6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b78:	0f b6 0a             	movzbl (%edx),%ecx
  800b7b:	89 cf                	mov    %ecx,%edi
  800b7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b80:	80 fb 09             	cmp    $0x9,%bl
  800b83:	77 08                	ja     800b8d <strtol+0xa2>
			dig = *s - '0';
  800b85:	0f be c9             	movsbl %cl,%ecx
  800b88:	83 e9 30             	sub    $0x30,%ecx
  800b8b:	eb 1e                	jmp    800bab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b90:	80 fb 19             	cmp    $0x19,%bl
  800b93:	77 08                	ja     800b9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b95:	0f be c9             	movsbl %cl,%ecx
  800b98:	83 e9 57             	sub    $0x57,%ecx
  800b9b:	eb 0e                	jmp    800bab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ba0:	80 fb 19             	cmp    $0x19,%bl
  800ba3:	77 15                	ja     800bba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ba5:	0f be c9             	movsbl %cl,%ecx
  800ba8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bab:	39 f1                	cmp    %esi,%ecx
  800bad:	7d 0b                	jge    800bba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c2 01             	add    $0x1,%edx
  800bb2:	0f af c6             	imul   %esi,%eax
  800bb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb be                	jmp    800b78 <strtol+0x8d>
  800bba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc0:	74 05                	je     800bc7 <strtol+0xdc>
		*endptr = (char *) s;
  800bc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bcb:	74 04                	je     800bd1 <strtol+0xe6>
  800bcd:	89 c8                	mov    %ecx,%eax
  800bcf:	f7 d8                	neg    %eax
}
  800bd1:	83 c4 04             	add    $0x4,%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	00 00                	add    %al,(%eax)
	...

00800bdc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	89 1c 24             	mov    %ebx,(%esp)
  800be5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf7:	89 d1                	mov    %edx,%ecx
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	89 d7                	mov    %edx,%edi
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c01:	8b 1c 24             	mov    (%esp),%ebx
  800c04:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c08:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c0c:	89 ec                	mov    %ebp,%esp
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	89 1c 24             	mov    %ebx,(%esp)
  800c19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c1d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	89 c3                	mov    %eax,%ebx
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	89 c6                	mov    %eax,%esi
  800c32:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c34:	8b 1c 24             	mov    (%esp),%ebx
  800c37:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c3b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c3f:	89 ec                	mov    %ebp,%esp
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 38             	sub    $0x38,%esp
  800c49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 cb                	mov    %ecx,%ebx
  800c61:	89 cf                	mov    %ecx,%edi
  800c63:	89 ce                	mov    %ecx,%esi
  800c65:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 28                	jle    800c93 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800c8e:	e8 c9 0b 00 00       	call   80185c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c93:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c96:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c9c:	89 ec                	mov    %ebp,%esp
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	89 1c 24             	mov    %ebx,(%esp)
  800ca9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc9:	8b 1c 24             	mov    (%esp),%ebx
  800ccc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cd4:	89 ec                	mov    %ebp,%esp
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 38             	sub    $0x38,%esp
  800cde:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 28                	jle    800d29 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d05:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800d14:	00 
  800d15:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d1c:	00 
  800d1d:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800d24:	e8 33 0b 00 00       	call   80185c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d29:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d2c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d32:	89 ec                	mov    %ebp,%esp
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 38             	sub    $0x38,%esp
  800d3c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d3f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d42:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 df                	mov    %ebx,%edi
  800d57:	89 de                	mov    %ebx,%esi
  800d59:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 28                	jle    800d87 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d63:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800d72:	00 
  800d73:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d7a:	00 
  800d7b:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800d82:	e8 d5 0a 00 00       	call   80185c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d90:	89 ec                	mov    %ebp,%esp
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 38             	sub    $0x38,%esp
  800d9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 08 00 00 00       	mov    $0x8,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800de0:	e8 77 0a 00 00       	call   80185c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800deb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dee:	89 ec                	mov    %ebp,%esp
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 38             	sub    $0x38,%esp
  800df8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800e3e:	e8 19 0a 00 00       	call   80185c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4c:	89 ec                	mov    %ebp,%esp
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 38             	sub    $0x38,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e64:	8b 75 18             	mov    0x18(%ebp),%esi
  800e67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 28                	jle    800ea1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e84:	00 
  800e85:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800e9c:	e8 bb 09 00 00       	call   80185c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eaa:	89 ec                	mov    %ebp,%esp
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 38             	sub    $0x38,%esp
  800eb4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eba:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebd:	be 00 00 00 00       	mov    $0x0,%esi
  800ec2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	89 f7                	mov    %esi,%edi
  800ed2:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	7e 28                	jle    800f00 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800eeb:	00 
  800eec:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ef3:	00 
  800ef4:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800efb:	e8 5c 09 00 00       	call   80185c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f00:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f03:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f06:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f09:	89 ec                	mov    %ebp,%esp
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	89 1c 24             	mov    %ebx,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 d3                	mov    %edx,%ebx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	89 d6                	mov    %edx,%esi
  800f30:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f32:	8b 1c 24             	mov    (%esp),%ebx
  800f35:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f39:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f3d:	89 ec                	mov    %ebp,%esp
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	89 1c 24             	mov    %ebx,(%esp)
  800f4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	b8 02 00 00 00       	mov    $0x2,%eax
  800f5c:	89 d1                	mov    %edx,%ecx
  800f5e:	89 d3                	mov    %edx,%ebx
  800f60:	89 d7                	mov    %edx,%edi
  800f62:	89 d6                	mov    %edx,%esi
  800f64:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f66:	8b 1c 24             	mov    (%esp),%ebx
  800f69:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f6d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f71:	89 ec                	mov    %ebp,%esp
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 38             	sub    $0x38,%esp
  800f7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f81:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	b8 03 00 00 00       	mov    $0x3,%eax
  800f8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f91:	89 cb                	mov    %ecx,%ebx
  800f93:	89 cf                	mov    %ecx,%edi
  800f95:	89 ce                	mov    %ecx,%esi
  800f97:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 28                	jle    800fc5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 08 3f 1f 80 	movl   $0x801f3f,0x8(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fb8:	00 
  800fb9:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  800fc0:	e8 97 08 00 00       	call   80185c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fc5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fce:	89 ec                	mov    %ebp,%esp
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    
	...

00800fe0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	05 00 00 00 30       	add    $0x30000000,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	89 04 24             	mov    %eax,(%esp)
  800ffc:	e8 df ff ff ff       	call   800fe0 <fd2num>
  801001:	05 20 00 0d 00       	add    $0xd0020,%eax
  801006:	c1 e0 0c             	shl    $0xc,%eax
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801014:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 36                	je     801053 <fd_alloc+0x48>
  80101d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801022:	a8 01                	test   $0x1,%al
  801024:	74 2d                	je     801053 <fd_alloc+0x48>
  801026:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80102b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801030:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801035:	89 c3                	mov    %eax,%ebx
  801037:	89 c2                	mov    %eax,%edx
  801039:	c1 ea 16             	shr    $0x16,%edx
  80103c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80103f:	f6 c2 01             	test   $0x1,%dl
  801042:	74 14                	je     801058 <fd_alloc+0x4d>
  801044:	89 c2                	mov    %eax,%edx
  801046:	c1 ea 0c             	shr    $0xc,%edx
  801049:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80104c:	f6 c2 01             	test   $0x1,%dl
  80104f:	75 10                	jne    801061 <fd_alloc+0x56>
  801051:	eb 05                	jmp    801058 <fd_alloc+0x4d>
  801053:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801058:	89 1f                	mov    %ebx,(%edi)
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80105f:	eb 17                	jmp    801078 <fd_alloc+0x6d>
  801061:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801066:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80106b:	75 c8                	jne    801035 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80106d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801073:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801080:	8b 45 08             	mov    0x8(%ebp),%eax
  801083:	83 f8 1f             	cmp    $0x1f,%eax
  801086:	77 36                	ja     8010be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801088:	05 00 00 0d 00       	add    $0xd0000,%eax
  80108d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 16             	shr    $0x16,%edx
  801095:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 1d                	je     8010be <fd_lookup+0x41>
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 0c             	shr    $0xc,%edx
  8010a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	74 0c                	je     8010be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b5:	89 02                	mov    %eax,(%edx)
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010bc:	eb 05                	jmp    8010c3 <fd_lookup+0x46>
  8010be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 a0 ff ff ff       	call   80107d <fd_lookup>
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 0e                	js     8010ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e7:	89 50 04             	mov    %edx,0x4(%eax)
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 10             	sub    $0x10,%esp
  8010f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8010ff:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801104:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801109:	be ec 1f 80 00       	mov    $0x801fec,%esi
		if (devtab[i]->dev_id == dev_id) {
  80110e:	39 08                	cmp    %ecx,(%eax)
  801110:	75 10                	jne    801122 <dev_lookup+0x31>
  801112:	eb 04                	jmp    801118 <dev_lookup+0x27>
  801114:	39 08                	cmp    %ecx,(%eax)
  801116:	75 0a                	jne    801122 <dev_lookup+0x31>
			*dev = devtab[i];
  801118:	89 03                	mov    %eax,(%ebx)
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80111f:	90                   	nop
  801120:	eb 31                	jmp    801153 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801122:	83 c2 01             	add    $0x1,%edx
  801125:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801128:	85 c0                	test   %eax,%eax
  80112a:	75 e8                	jne    801114 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  80112c:	a1 24 50 80 00       	mov    0x805024,%eax
  801131:	8b 40 4c             	mov    0x4c(%eax),%eax
  801134:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113c:	c7 04 24 6c 1f 80 00 	movl   $0x801f6c,(%esp)
  801143:	e8 f5 ef ff ff       	call   80013d <cprintf>
	*dev = 0;
  801148:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 24             	sub    $0x24,%esp
  801161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801164:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	89 04 24             	mov    %eax,(%esp)
  801171:	e8 07 ff ff ff       	call   80107d <fd_lookup>
  801176:	85 c0                	test   %eax,%eax
  801178:	78 53                	js     8011cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	8b 00                	mov    (%eax),%eax
  801186:	89 04 24             	mov    %eax,(%esp)
  801189:	e8 63 ff ff ff       	call   8010f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 3b                	js     8011cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801192:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801197:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80119e:	74 2d                	je     8011cd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011aa:	00 00 00 
	stat->st_isdir = 0;
  8011ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011b4:	00 00 00 
	stat->st_dev = dev;
  8011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c7:	89 14 24             	mov    %edx,(%esp)
  8011ca:	ff 50 14             	call   *0x14(%eax)
}
  8011cd:	83 c4 24             	add    $0x24,%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 24             	sub    $0x24,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e4:	89 1c 24             	mov    %ebx,(%esp)
  8011e7:	e8 91 fe ff ff       	call   80107d <fd_lookup>
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 5f                	js     80124f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	8b 00                	mov    (%eax),%eax
  8011fc:	89 04 24             	mov    %eax,(%esp)
  8011ff:	e8 ed fe ff ff       	call   8010f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801204:	85 c0                	test   %eax,%eax
  801206:	78 47                	js     80124f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801208:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80120b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80120f:	75 23                	jne    801234 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  801211:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801216:	8b 40 4c             	mov    0x4c(%eax),%eax
  801219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80121d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801221:	c7 04 24 8c 1f 80 00 	movl   $0x801f8c,(%esp)
  801228:	e8 10 ef ff ff       	call   80013d <cprintf>
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  801232:	eb 1b                	jmp    80124f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801237:	8b 48 18             	mov    0x18(%eax),%ecx
  80123a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80123f:	85 c9                	test   %ecx,%ecx
  801241:	74 0c                	je     80124f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
  801246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124a:	89 14 24             	mov    %edx,(%esp)
  80124d:	ff d1                	call   *%ecx
}
  80124f:	83 c4 24             	add    $0x24,%esp
  801252:	5b                   	pop    %ebx
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 24             	sub    $0x24,%esp
  80125c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	89 1c 24             	mov    %ebx,(%esp)
  801269:	e8 0f fe ff ff       	call   80107d <fd_lookup>
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 66                	js     8012d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	8b 00                	mov    (%eax),%eax
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 6b fe ff ff       	call   8010f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	85 c0                	test   %eax,%eax
  801288:	78 4e                	js     8012d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80128d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801291:	75 23                	jne    8012b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801293:	a1 24 50 80 00       	mov    0x805024,%eax
  801298:	8b 40 4c             	mov    0x4c(%eax),%eax
  80129b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80129f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a3:	c7 04 24 b0 1f 80 00 	movl   $0x801fb0,(%esp)
  8012aa:	e8 8e ee ff ff       	call   80013d <cprintf>
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012b4:	eb 22                	jmp    8012d8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8012bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c1:	85 c9                	test   %ecx,%ecx
  8012c3:	74 13                	je     8012d8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d3:	89 14 24             	mov    %edx,(%esp)
  8012d6:	ff d1                	call   *%ecx
}
  8012d8:	83 c4 24             	add    $0x24,%esp
  8012db:	5b                   	pop    %ebx
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 24             	sub    $0x24,%esp
  8012e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	89 1c 24             	mov    %ebx,(%esp)
  8012f2:	e8 86 fd ff ff       	call   80107d <fd_lookup>
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 6b                	js     801366 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	8b 00                	mov    (%eax),%eax
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	e8 e2 fd ff ff       	call   8010f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 53                	js     801366 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801313:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801316:	8b 42 08             	mov    0x8(%edx),%eax
  801319:	83 e0 03             	and    $0x3,%eax
  80131c:	83 f8 01             	cmp    $0x1,%eax
  80131f:	75 23                	jne    801344 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801321:	a1 24 50 80 00       	mov    0x805024,%eax
  801326:	8b 40 4c             	mov    0x4c(%eax),%eax
  801329:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80132d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801331:	c7 04 24 cd 1f 80 00 	movl   $0x801fcd,(%esp)
  801338:	e8 00 ee ff ff       	call   80013d <cprintf>
  80133d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801342:	eb 22                	jmp    801366 <read+0x88>
	}
	if (!dev->dev_read)
  801344:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801347:	8b 48 08             	mov    0x8(%eax),%ecx
  80134a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80134f:	85 c9                	test   %ecx,%ecx
  801351:	74 13                	je     801366 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801353:	8b 45 10             	mov    0x10(%ebp),%eax
  801356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801361:	89 14 24             	mov    %edx,(%esp)
  801364:	ff d1                	call   *%ecx
}
  801366:	83 c4 24             	add    $0x24,%esp
  801369:	5b                   	pop    %ebx
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	83 ec 1c             	sub    $0x1c,%esp
  801375:	8b 7d 08             	mov    0x8(%ebp),%edi
  801378:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80137b:	ba 00 00 00 00       	mov    $0x0,%edx
  801380:	bb 00 00 00 00       	mov    $0x0,%ebx
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
  80138a:	85 f6                	test   %esi,%esi
  80138c:	74 29                	je     8013b7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80138e:	89 f0                	mov    %esi,%eax
  801390:	29 d0                	sub    %edx,%eax
  801392:	89 44 24 08          	mov    %eax,0x8(%esp)
  801396:	03 55 0c             	add    0xc(%ebp),%edx
  801399:	89 54 24 04          	mov    %edx,0x4(%esp)
  80139d:	89 3c 24             	mov    %edi,(%esp)
  8013a0:	e8 39 ff ff ff       	call   8012de <read>
		if (m < 0)
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 0e                	js     8013b7 <readn+0x4b>
			return m;
		if (m == 0)
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	74 08                	je     8013b5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ad:	01 c3                	add    %eax,%ebx
  8013af:	89 da                	mov    %ebx,%edx
  8013b1:	39 f3                	cmp    %esi,%ebx
  8013b3:	72 d9                	jb     80138e <readn+0x22>
  8013b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013b7:	83 c4 1c             	add    $0x1c,%esp
  8013ba:	5b                   	pop    %ebx
  8013bb:	5e                   	pop    %esi
  8013bc:	5f                   	pop    %edi
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 20             	sub    $0x20,%esp
  8013c7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ca:	89 34 24             	mov    %esi,(%esp)
  8013cd:	e8 0e fc ff ff       	call   800fe0 <fd2num>
  8013d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013d9:	89 04 24             	mov    %eax,(%esp)
  8013dc:	e8 9c fc ff ff       	call   80107d <fd_lookup>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 05                	js     8013ec <fd_close+0x2d>
  8013e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ea:	74 0c                	je     8013f8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8013f0:	19 c0                	sbb    %eax,%eax
  8013f2:	f7 d0                	not    %eax
  8013f4:	21 c3                	and    %eax,%ebx
  8013f6:	eb 3d                	jmp    801435 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ff:	8b 06                	mov    (%esi),%eax
  801401:	89 04 24             	mov    %eax,(%esp)
  801404:	e8 e8 fc ff ff       	call   8010f1 <dev_lookup>
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 16                	js     801425 <fd_close+0x66>
		if (dev->dev_close)
  80140f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801412:	8b 40 10             	mov    0x10(%eax),%eax
  801415:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141a:	85 c0                	test   %eax,%eax
  80141c:	74 07                	je     801425 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80141e:	89 34 24             	mov    %esi,(%esp)
  801421:	ff d0                	call   *%eax
  801423:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801425:	89 74 24 04          	mov    %esi,0x4(%esp)
  801429:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801430:	e8 bd f9 ff ff       	call   800df2 <sys_page_unmap>
	return r;
}
  801435:	89 d8                	mov    %ebx,%eax
  801437:	83 c4 20             	add    $0x20,%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	89 04 24             	mov    %eax,(%esp)
  801451:	e8 27 fc ff ff       	call   80107d <fd_lookup>
  801456:	85 c0                	test   %eax,%eax
  801458:	78 13                	js     80146d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80145a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801461:	00 
  801462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801465:	89 04 24             	mov    %eax,(%esp)
  801468:	e8 52 ff ff ff       	call   8013bf <fd_close>
}
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	83 ec 18             	sub    $0x18,%esp
  801475:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801478:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80147b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801482:	00 
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	89 04 24             	mov    %eax,(%esp)
  801489:	e8 4d 03 00 00       	call   8017db <open>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	85 c0                	test   %eax,%eax
  801492:	78 1b                	js     8014af <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801494:	8b 45 0c             	mov    0xc(%ebp),%eax
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	e8 b7 fc ff ff       	call   80115a <fstat>
  8014a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a5:	89 1c 24             	mov    %ebx,(%esp)
  8014a8:	e8 91 ff ff ff       	call   80143e <close>
  8014ad:	89 f3                	mov    %esi,%ebx
	return r;
}
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014b7:	89 ec                	mov    %ebp,%esp
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 14             	sub    $0x14,%esp
  8014c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014c7:	89 1c 24             	mov    %ebx,(%esp)
  8014ca:	e8 6f ff ff ff       	call   80143e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014cf:	83 c3 01             	add    $0x1,%ebx
  8014d2:	83 fb 20             	cmp    $0x20,%ebx
  8014d5:	75 f0                	jne    8014c7 <close_all+0xc>
		close(i);
}
  8014d7:	83 c4 14             	add    $0x14,%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	83 ec 58             	sub    $0x58,%esp
  8014e3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014e6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014e9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	89 04 24             	mov    %eax,(%esp)
  8014fc:	e8 7c fb ff ff       	call   80107d <fd_lookup>
  801501:	89 c3                	mov    %eax,%ebx
  801503:	85 c0                	test   %eax,%eax
  801505:	0f 88 e0 00 00 00    	js     8015eb <dup+0x10e>
		return r;
	close(newfdnum);
  80150b:	89 3c 24             	mov    %edi,(%esp)
  80150e:	e8 2b ff ff ff       	call   80143e <close>

	newfd = INDEX2FD(newfdnum);
  801513:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801519:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80151c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 c9 fa ff ff       	call   800ff0 <fd2data>
  801527:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801529:	89 34 24             	mov    %esi,(%esp)
  80152c:	e8 bf fa ff ff       	call   800ff0 <fd2data>
  801531:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801534:	89 da                	mov    %ebx,%edx
  801536:	89 d8                	mov    %ebx,%eax
  801538:	c1 e8 16             	shr    $0x16,%eax
  80153b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801542:	a8 01                	test   $0x1,%al
  801544:	74 43                	je     801589 <dup+0xac>
  801546:	c1 ea 0c             	shr    $0xc,%edx
  801549:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801550:	a8 01                	test   $0x1,%al
  801552:	74 35                	je     801589 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801554:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80155b:	25 07 0e 00 00       	and    $0xe07,%eax
  801560:	89 44 24 10          	mov    %eax,0x10(%esp)
  801564:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801567:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80156b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801572:	00 
  801573:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157e:	e8 cd f8 ff ff       	call   800e50 <sys_page_map>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 3f                	js     8015c8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	c1 ea 0c             	shr    $0xc,%edx
  801591:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801598:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80159e:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ad:	00 
  8015ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b9:	e8 92 f8 ff ff       	call   800e50 <sys_page_map>
  8015be:	89 c3                	mov    %eax,%ebx
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 04                	js     8015c8 <dup+0xeb>
  8015c4:	89 fb                	mov    %edi,%ebx
  8015c6:	eb 23                	jmp    8015eb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d3:	e8 1a f8 ff ff       	call   800df2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e6:	e8 07 f8 ff ff       	call   800df2 <sys_page_unmap>
	return r;
}
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015f0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015f3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015f6:	89 ec                	mov    %ebp,%esp
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    
  8015fa:	00 00                	add    %al,(%eax)
  8015fc:	00 00                	add    %al,(%eax)
	...

00801600 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 14             	sub    $0x14,%esp
  801607:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801609:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  80160f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801616:	00 
  801617:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80161e:	00 
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	89 14 24             	mov    %edx,(%esp)
  801626:	e8 95 02 00 00       	call   8018c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80162b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801632:	00 
  801633:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163e:	e8 e7 02 00 00       	call   80192a <ipc_recv>
}
  801643:	83 c4 14             	add    $0x14,%esp
  801646:	5b                   	pop    %ebx
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	8b 40 0c             	mov    0xc(%eax),%eax
  801655:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  80165a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165d:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	b8 02 00 00 00       	mov    $0x2,%eax
  80166c:	e8 8f ff ff ff       	call   801600 <fsipc>
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801679:	8b 45 08             	mov    0x8(%ebp),%eax
  80167c:	8b 40 0c             	mov    0xc(%eax),%eax
  80167f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801684:	ba 00 00 00 00       	mov    $0x0,%edx
  801689:	b8 06 00 00 00       	mov    $0x6,%eax
  80168e:	e8 6d ff ff ff       	call   801600 <fsipc>
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169b:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a5:	e8 56 ff ff ff       	call   801600 <fsipc>
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 14             	sub    $0x14,%esp
  8016b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bc:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016cb:	e8 30 ff ff ff       	call   801600 <fsipc>
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 2b                	js     8016ff <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016d4:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8016db:	00 
  8016dc:	89 1c 24             	mov    %ebx,(%esp)
  8016df:	e8 36 f1 ff ff       	call   80081a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016e4:	a1 80 30 80 00       	mov    0x803080,%eax
  8016e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ef:	a1 84 30 80 00       	mov    0x803084,%eax
  8016f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8016fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016ff:	83 c4 14             	add    $0x14,%esp
  801702:	5b                   	pop    %ebx
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 18             	sub    $0x18,%esp
  80170b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80170e:	8b 55 08             	mov    0x8(%ebp),%edx
  801711:	8b 52 0c             	mov    0xc(%edx),%edx
  801714:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  80171a:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80171f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801723:	8b 45 0c             	mov    0xc(%ebp),%eax
  801726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172a:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801731:	e8 9f f2 ff ff       	call   8009d5 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801736:	ba 00 30 80 00       	mov    $0x803000,%edx
  80173b:	b8 04 00 00 00       	mov    $0x4,%eax
  801740:	e8 bb fe ff ff       	call   801600 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	53                   	push   %ebx
  80174b:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801759:	8b 45 10             	mov    0x10(%ebp),%eax
  80175c:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801761:	ba 00 30 80 00       	mov    $0x803000,%edx
  801766:	b8 03 00 00 00       	mov    $0x3,%eax
  80176b:	e8 90 fe ff ff       	call   801600 <fsipc>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	85 c0                	test   %eax,%eax
  801774:	78 17                	js     80178d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801776:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801781:	00 
  801782:	8b 45 0c             	mov    0xc(%ebp),%eax
  801785:	89 04 24             	mov    %eax,(%esp)
  801788:	e8 48 f2 ff ff       	call   8009d5 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80178d:	89 d8                	mov    %ebx,%eax
  80178f:	83 c4 14             	add    $0x14,%esp
  801792:	5b                   	pop    %ebx
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	83 ec 14             	sub    $0x14,%esp
  80179c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80179f:	89 1c 24             	mov    %ebx,(%esp)
  8017a2:	e8 29 f0 ff ff       	call   8007d0 <strlen>
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8017ae:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8017b4:	7f 1f                	jg     8017d5 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ba:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017c1:	e8 54 f0 ff ff       	call   80081a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	b8 07 00 00 00       	mov    $0x7,%eax
  8017d0:	e8 2b fe ff ff       	call   801600 <fsipc>
}
  8017d5:	83 c4 14             	add    $0x14,%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  8017e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e4:	89 04 24             	mov    %eax,(%esp)
  8017e7:	e8 1f f8 ff ff       	call   80100b <fd_alloc>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 6a                	js     80185a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8017fe:	e8 17 f0 ff ff       	call   80081a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801803:	8b 45 0c             	mov    0xc(%ebp),%eax
  801806:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801810:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801817:	00 
  801818:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80181f:	00 
  801820:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801827:	00 
  801828:	89 04 24             	mov    %eax,(%esp)
  80182b:	e8 90 00 00 00       	call   8018c0 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801830:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801837:	00 
  801838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801846:	e8 df 00 00 00       	call   80192a <ipc_recv>
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 0b                	js     80185a <open+0x7f>
		return r;
	return fd2num(fd);
  80184f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 86 f7 ff ff       	call   800fe0 <fd2num>
	panic("open not implemented");
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	53                   	push   %ebx
  801860:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  801863:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801866:	a1 28 50 80 00       	mov    0x805028,%eax
  80186b:	85 c0                	test   %eax,%eax
  80186d:	74 10                	je     80187f <_panic+0x23>
		cprintf("%s: ", argv0);
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	c7 04 24 f4 1f 80 00 	movl   $0x801ff4,(%esp)
  80187a:	e8 be e8 ff ff       	call   80013d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80187f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801882:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	89 44 24 08          	mov    %eax,0x8(%esp)
  80188d:	a1 00 50 80 00       	mov    0x805000,%eax
  801892:	89 44 24 04          	mov    %eax,0x4(%esp)
  801896:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  80189d:	e8 9b e8 ff ff       	call   80013d <cprintf>
	vcprintf(fmt, ap);
  8018a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a9:	89 04 24             	mov    %eax,(%esp)
  8018ac:	e8 2b e8 ff ff       	call   8000dc <vcprintf>
	cprintf("\n");
  8018b1:	c7 04 24 2a 1c 80 00 	movl   $0x801c2a,(%esp)
  8018b8:	e8 80 e8 ff ff       	call   80013d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018bd:	cc                   	int3   
  8018be:	eb fd                	jmp    8018bd <_panic+0x61>

008018c0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 1c             	sub    $0x1c,%esp
  8018c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018cf:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  8018d2:	85 db                	test   %ebx,%ebx
  8018d4:	75 31                	jne    801907 <ipc_send+0x47>
  8018d6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8018db:	eb 2a                	jmp    801907 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  8018dd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018e0:	74 20                	je     801902 <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  8018e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e6:	c7 44 24 08 15 20 80 	movl   $0x802015,0x8(%esp)
  8018ed:	00 
  8018ee:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8018f5:	00 
  8018f6:	c7 04 24 2c 20 80 00 	movl   $0x80202c,(%esp)
  8018fd:	e8 5a ff ff ff       	call   80185c <_panic>


                sys_yield();
  801902:	e8 06 f6 ff ff       	call   800f0d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801907:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80190b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80190f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	e8 82 f3 ff ff       	call   800ca0 <sys_ipc_try_send>
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 bb                	js     8018dd <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801922:	83 c4 1c             	add    $0x1c,%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5f                   	pop    %edi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	56                   	push   %esi
  80192e:	53                   	push   %ebx
  80192f:	83 ec 10             	sub    $0x10,%esp
  801932:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  80193b:	85 c0                	test   %eax,%eax
  80193d:	75 05                	jne    801944 <ipc_recv+0x1a>
  80193f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 f7 f2 ff ff       	call   800c43 <sys_ipc_recv>
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 24                	js     801974 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801950:	85 db                	test   %ebx,%ebx
  801952:	74 0a                	je     80195e <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801954:	a1 24 50 80 00       	mov    0x805024,%eax
  801959:	8b 40 74             	mov    0x74(%eax),%eax
  80195c:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  80195e:	85 f6                	test   %esi,%esi
  801960:	74 0a                	je     80196c <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801962:	a1 24 50 80 00       	mov    0x805024,%eax
  801967:	8b 40 78             	mov    0x78(%eax),%eax
  80196a:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  80196c:	a1 24 50 80 00       	mov    0x805024,%eax
  801971:	8b 40 70             	mov    0x70(%eax),%eax
}
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    
  80197b:	00 00                	add    %al,(%eax)
  80197d:	00 00                	add    %al,(%eax)
	...

00801980 <__udivdi3>:
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	83 ec 10             	sub    $0x10,%esp
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	8b 55 08             	mov    0x8(%ebp),%edx
  80198e:	8b 75 10             	mov    0x10(%ebp),%esi
  801991:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801994:	85 c0                	test   %eax,%eax
  801996:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801999:	75 35                	jne    8019d0 <__udivdi3+0x50>
  80199b:	39 fe                	cmp    %edi,%esi
  80199d:	77 61                	ja     801a00 <__udivdi3+0x80>
  80199f:	85 f6                	test   %esi,%esi
  8019a1:	75 0b                	jne    8019ae <__udivdi3+0x2e>
  8019a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a8:	31 d2                	xor    %edx,%edx
  8019aa:	f7 f6                	div    %esi
  8019ac:	89 c6                	mov    %eax,%esi
  8019ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019b1:	31 d2                	xor    %edx,%edx
  8019b3:	89 f8                	mov    %edi,%eax
  8019b5:	f7 f6                	div    %esi
  8019b7:	89 c7                	mov    %eax,%edi
  8019b9:	89 c8                	mov    %ecx,%eax
  8019bb:	f7 f6                	div    %esi
  8019bd:	89 c1                	mov    %eax,%ecx
  8019bf:	89 fa                	mov    %edi,%edx
  8019c1:	89 c8                	mov    %ecx,%eax
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	5e                   	pop    %esi
  8019c7:	5f                   	pop    %edi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    
  8019ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019d0:	39 f8                	cmp    %edi,%eax
  8019d2:	77 1c                	ja     8019f0 <__udivdi3+0x70>
  8019d4:	0f bd d0             	bsr    %eax,%edx
  8019d7:	83 f2 1f             	xor    $0x1f,%edx
  8019da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8019dd:	75 39                	jne    801a18 <__udivdi3+0x98>
  8019df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8019e2:	0f 86 a0 00 00 00    	jbe    801a88 <__udivdi3+0x108>
  8019e8:	39 f8                	cmp    %edi,%eax
  8019ea:	0f 82 98 00 00 00    	jb     801a88 <__udivdi3+0x108>
  8019f0:	31 ff                	xor    %edi,%edi
  8019f2:	31 c9                	xor    %ecx,%ecx
  8019f4:	89 c8                	mov    %ecx,%eax
  8019f6:	89 fa                	mov    %edi,%edx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	5e                   	pop    %esi
  8019fc:	5f                   	pop    %edi
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    
  8019ff:	90                   	nop
  801a00:	89 d1                	mov    %edx,%ecx
  801a02:	89 fa                	mov    %edi,%edx
  801a04:	89 c8                	mov    %ecx,%eax
  801a06:	31 ff                	xor    %edi,%edi
  801a08:	f7 f6                	div    %esi
  801a0a:	89 c1                	mov    %eax,%ecx
  801a0c:	89 fa                	mov    %edi,%edx
  801a0e:	89 c8                	mov    %ecx,%eax
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	5e                   	pop    %esi
  801a14:	5f                   	pop    %edi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    
  801a17:	90                   	nop
  801a18:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a1c:	89 f2                	mov    %esi,%edx
  801a1e:	d3 e0                	shl    %cl,%eax
  801a20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a23:	b8 20 00 00 00       	mov    $0x20,%eax
  801a28:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801a2b:	89 c1                	mov    %eax,%ecx
  801a2d:	d3 ea                	shr    %cl,%edx
  801a2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a33:	0b 55 ec             	or     -0x14(%ebp),%edx
  801a36:	d3 e6                	shl    %cl,%esi
  801a38:	89 c1                	mov    %eax,%ecx
  801a3a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801a3d:	89 fe                	mov    %edi,%esi
  801a3f:	d3 ee                	shr    %cl,%esi
  801a41:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a45:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a4b:	d3 e7                	shl    %cl,%edi
  801a4d:	89 c1                	mov    %eax,%ecx
  801a4f:	d3 ea                	shr    %cl,%edx
  801a51:	09 d7                	or     %edx,%edi
  801a53:	89 f2                	mov    %esi,%edx
  801a55:	89 f8                	mov    %edi,%eax
  801a57:	f7 75 ec             	divl   -0x14(%ebp)
  801a5a:	89 d6                	mov    %edx,%esi
  801a5c:	89 c7                	mov    %eax,%edi
  801a5e:	f7 65 e8             	mull   -0x18(%ebp)
  801a61:	39 d6                	cmp    %edx,%esi
  801a63:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a66:	72 30                	jb     801a98 <__udivdi3+0x118>
  801a68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a6b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a6f:	d3 e2                	shl    %cl,%edx
  801a71:	39 c2                	cmp    %eax,%edx
  801a73:	73 05                	jae    801a7a <__udivdi3+0xfa>
  801a75:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801a78:	74 1e                	je     801a98 <__udivdi3+0x118>
  801a7a:	89 f9                	mov    %edi,%ecx
  801a7c:	31 ff                	xor    %edi,%edi
  801a7e:	e9 71 ff ff ff       	jmp    8019f4 <__udivdi3+0x74>
  801a83:	90                   	nop
  801a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a88:	31 ff                	xor    %edi,%edi
  801a8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a8f:	e9 60 ff ff ff       	jmp    8019f4 <__udivdi3+0x74>
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801a9b:	31 ff                	xor    %edi,%edi
  801a9d:	89 c8                	mov    %ecx,%eax
  801a9f:	89 fa                	mov    %edi,%edx
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    
	...

00801ab0 <__umoddi3>:
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	83 ec 20             	sub    $0x20,%esp
  801ab8:	8b 55 14             	mov    0x14(%ebp),%edx
  801abb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801abe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac4:	85 d2                	test   %edx,%edx
  801ac6:	89 c8                	mov    %ecx,%eax
  801ac8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801acb:	75 13                	jne    801ae0 <__umoddi3+0x30>
  801acd:	39 f7                	cmp    %esi,%edi
  801acf:	76 3f                	jbe    801b10 <__umoddi3+0x60>
  801ad1:	89 f2                	mov    %esi,%edx
  801ad3:	f7 f7                	div    %edi
  801ad5:	89 d0                	mov    %edx,%eax
  801ad7:	31 d2                	xor    %edx,%edx
  801ad9:	83 c4 20             	add    $0x20,%esp
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    
  801ae0:	39 f2                	cmp    %esi,%edx
  801ae2:	77 4c                	ja     801b30 <__umoddi3+0x80>
  801ae4:	0f bd ca             	bsr    %edx,%ecx
  801ae7:	83 f1 1f             	xor    $0x1f,%ecx
  801aea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aed:	75 51                	jne    801b40 <__umoddi3+0x90>
  801aef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801af2:	0f 87 e0 00 00 00    	ja     801bd8 <__umoddi3+0x128>
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	29 f8                	sub    %edi,%eax
  801afd:	19 d6                	sbb    %edx,%esi
  801aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b05:	89 f2                	mov    %esi,%edx
  801b07:	83 c4 20             	add    $0x20,%esp
  801b0a:	5e                   	pop    %esi
  801b0b:	5f                   	pop    %edi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    
  801b0e:	66 90                	xchg   %ax,%ax
  801b10:	85 ff                	test   %edi,%edi
  801b12:	75 0b                	jne    801b1f <__umoddi3+0x6f>
  801b14:	b8 01 00 00 00       	mov    $0x1,%eax
  801b19:	31 d2                	xor    %edx,%edx
  801b1b:	f7 f7                	div    %edi
  801b1d:	89 c7                	mov    %eax,%edi
  801b1f:	89 f0                	mov    %esi,%eax
  801b21:	31 d2                	xor    %edx,%edx
  801b23:	f7 f7                	div    %edi
  801b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b28:	f7 f7                	div    %edi
  801b2a:	eb a9                	jmp    801ad5 <__umoddi3+0x25>
  801b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b30:	89 c8                	mov    %ecx,%eax
  801b32:	89 f2                	mov    %esi,%edx
  801b34:	83 c4 20             	add    $0x20,%esp
  801b37:	5e                   	pop    %esi
  801b38:	5f                   	pop    %edi
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    
  801b3b:	90                   	nop
  801b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b40:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b44:	d3 e2                	shl    %cl,%edx
  801b46:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b49:	ba 20 00 00 00       	mov    $0x20,%edx
  801b4e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801b51:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b54:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b58:	89 fa                	mov    %edi,%edx
  801b5a:	d3 ea                	shr    %cl,%edx
  801b5c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b60:	0b 55 f4             	or     -0xc(%ebp),%edx
  801b63:	d3 e7                	shl    %cl,%edi
  801b65:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b69:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b6c:	89 f2                	mov    %esi,%edx
  801b6e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801b71:	89 c7                	mov    %eax,%edi
  801b73:	d3 ea                	shr    %cl,%edx
  801b75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	d3 e6                	shl    %cl,%esi
  801b80:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b84:	d3 ea                	shr    %cl,%edx
  801b86:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b8a:	09 d6                	or     %edx,%esi
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801b91:	d3 e7                	shl    %cl,%edi
  801b93:	89 f2                	mov    %esi,%edx
  801b95:	f7 75 f4             	divl   -0xc(%ebp)
  801b98:	89 d6                	mov    %edx,%esi
  801b9a:	f7 65 e8             	mull   -0x18(%ebp)
  801b9d:	39 d6                	cmp    %edx,%esi
  801b9f:	72 2b                	jb     801bcc <__umoddi3+0x11c>
  801ba1:	39 c7                	cmp    %eax,%edi
  801ba3:	72 23                	jb     801bc8 <__umoddi3+0x118>
  801ba5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ba9:	29 c7                	sub    %eax,%edi
  801bab:	19 d6                	sbb    %edx,%esi
  801bad:	89 f0                	mov    %esi,%eax
  801baf:	89 f2                	mov    %esi,%edx
  801bb1:	d3 ef                	shr    %cl,%edi
  801bb3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bb7:	d3 e0                	shl    %cl,%eax
  801bb9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bbd:	09 f8                	or     %edi,%eax
  801bbf:	d3 ea                	shr    %cl,%edx
  801bc1:	83 c4 20             	add    $0x20,%esp
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    
  801bc8:	39 d6                	cmp    %edx,%esi
  801bca:	75 d9                	jne    801ba5 <__umoddi3+0xf5>
  801bcc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801bcf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801bd2:	eb d1                	jmp    801ba5 <__umoddi3+0xf5>
  801bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd8:	39 f2                	cmp    %esi,%edx
  801bda:	0f 82 18 ff ff ff    	jb     801af8 <__umoddi3+0x48>
  801be0:	e9 1d ff ff ff       	jmp    801b02 <__umoddi3+0x52>
