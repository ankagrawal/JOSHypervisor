
obj/user/init:     file format elf32-i386


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

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	85 db                	test   %ebx,%ebx
  80004b:	7e 10                	jle    80005d <sum+0x29>
		tot ^= i * s[i];
  80004d:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  800051:	0f af ca             	imul   %edx,%ecx
  800054:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800056:	83 c2 01             	add    $0x1,%edx
  800059:	39 da                	cmp    %ebx,%edx
  80005b:	75 f0                	jne    80004d <sum+0x19>
		tot ^= i * s[i];
	return tot;
}
  80005d:	5b                   	pop    %ebx
  80005e:	5e                   	pop    %esi
  80005f:	5d                   	pop    %ebp
  800060:	c3                   	ret    

00800061 <umain>:
		
void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 1c             	sub    $0x1c,%esp
  80006a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, r, x, want;

	cprintf("init: running\n");
  800070:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  800077:	e8 ad 01 00 00       	call   800229 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  80007c:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  800083:	00 
  800084:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <sum>
  800090:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800095:	74 1a                	je     8000b1 <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800097:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009e:	00 
  80009f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a3:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  8000aa:	e8 7a 01 00 00       	call   800229 <cprintf>
  8000af:	eb 0c                	jmp    8000bd <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b1:	c7 04 24 ef 1c 80 00 	movl   $0x801cef,(%esp)
  8000b8:	e8 6c 01 00 00       	call   800229 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bd:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 a0 67 80 00 	movl   $0x8067a0,(%esp)
  8000cc:	e8 63 ff ff ff       	call   800034 <sum>
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	74 12                	je     8000e7 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d9:	c7 04 24 7c 1d 80 00 	movl   $0x801d7c,(%esp)
  8000e0:	e8 44 01 00 00       	call   800229 <cprintf>
  8000e5:	eb 0c                	jmp    8000f3 <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	c7 04 24 06 1d 80 00 	movl   $0x801d06,(%esp)
  8000ee:	e8 36 01 00 00       	call   800229 <cprintf>

	cprintf("init: args:");
  8000f3:	c7 04 24 1c 1d 80 00 	movl   $0x801d1c,(%esp)
  8000fa:	e8 2a 01 00 00       	call   800229 <cprintf>
	for (i = 0; i < argc; i++)
  8000ff:	85 ff                	test   %edi,%edi
  800101:	7e 1f                	jle    800122 <umain+0xc1>
  800103:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf(" '%s'", argv[i]);
  800108:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	c7 04 24 28 1d 80 00 	movl   $0x801d28,(%esp)
  800116:	e8 0e 01 00 00       	call   800229 <cprintf>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
	else
		cprintf("init: bss seems okay\n");

	cprintf("init: args:");
	for (i = 0; i < argc; i++)
  80011b:	83 c3 01             	add    $0x1,%ebx
  80011e:	39 df                	cmp    %ebx,%edi
  800120:	7f e6                	jg     800108 <umain+0xa7>
		cprintf(" '%s'", argv[i]);
	cprintf("\n");
  800122:	c7 04 24 bb 1d 80 00 	movl   $0x801dbb,(%esp)
  800129:	e8 fb 00 00 00       	call   800229 <cprintf>

	cprintf("init: exiting\n");
  80012e:	c7 04 24 2e 1d 80 00 	movl   $0x801d2e,(%esp)
  800135:	e8 ef 00 00 00       	call   800229 <cprintf>
}
  80013a:	83 c4 1c             	add    $0x1c,%esp
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5f                   	pop    %edi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    
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
  800156:	c7 05 10 7f 80 00 00 	movl   $0x0,0x807f10
  80015d:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800160:	e8 cc 0e 00 00       	call   801031 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 10 7f 80 00       	mov    %eax,0x807f10

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800177:	85 f6                	test   %esi,%esi
  800179:	7e 07                	jle    800182 <libmain+0x3e>
		binaryname = argv[0];
  80017b:	8b 03                	mov    (%ebx),%eax
  80017d:	a3 70 67 80 00       	mov    %eax,0x806770

	// call user main routine
	cprintf("calling here1234\n");
  800182:	c7 04 24 ab 1d 80 00 	movl   $0x801dab,(%esp)
  800189:	e8 9b 00 00 00       	call   800229 <cprintf>
	umain(argc, argv);
  80018e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800192:	89 34 24             	mov    %esi,(%esp)
  800195:	e8 c7 fe ff ff       	call   800061 <umain>

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
  8001b2:	e8 f4 13 00 00       	call   8015ab <close_all>
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 a2 0e 00 00       	call   801065 <sys_env_destroy>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
  8001c5:	00 00                	add    %al,(%eax)
	...

008001c8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fd:	c7 04 24 43 02 80 00 	movl   $0x800243,(%esp)
  800204:	e8 d4 01 00 00       	call   8003dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80020f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800213:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800219:	89 04 24             	mov    %eax,(%esp)
  80021c:	e8 df 0a 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 04 24             	mov    %eax,(%esp)
  80023c:	e8 87 ff ff ff       	call   8001c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	53                   	push   %ebx
  800247:	83 ec 14             	sub    $0x14,%esp
  80024a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024d:	8b 03                	mov    (%ebx),%eax
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800256:	83 c0 01             	add    $0x1,%eax
  800259:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80025b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800260:	75 19                	jne    80027b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800262:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800269:	00 
  80026a:	8d 43 08             	lea    0x8(%ebx),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	e8 8b 0a 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  800275:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	5b                   	pop    %ebx
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 4c             	sub    $0x4c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002bb:	39 d1                	cmp    %edx,%ecx
  8002bd:	72 15                	jb     8002d4 <printnum+0x44>
  8002bf:	77 07                	ja     8002c8 <printnum+0x38>
  8002c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c4:	39 d0                	cmp    %edx,%eax
  8002c6:	76 0c                	jbe    8002d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	85 db                	test   %ebx,%ebx
  8002cd:	8d 76 00             	lea    0x0(%esi),%esi
  8002d0:	7f 61                	jg     800333 <printnum+0xa3>
  8002d2:	eb 70                	jmp    800344 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002d8:	83 eb 01             	sub    $0x1,%ebx
  8002db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ff:	00 
  800300:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800309:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030d:	e8 5e 17 00 00       	call   801a70 <__udivdi3>
  800312:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800315:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	89 54 24 04          	mov    %edx,0x4(%esp)
  800327:	89 f2                	mov    %esi,%edx
  800329:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032c:	e8 5f ff ff ff       	call   800290 <printnum>
  800331:	eb 11                	jmp    800344 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800333:	89 74 24 04          	mov    %esi,0x4(%esp)
  800337:	89 3c 24             	mov    %edi,(%esp)
  80033a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f ef                	jg     800333 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	89 74 24 04          	mov    %esi,0x4(%esp)
  800348:	8b 74 24 04          	mov    0x4(%esp),%esi
  80034c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800353:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035a:	00 
  80035b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80035e:	89 14 24             	mov    %edx,(%esp)
  800361:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800364:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800368:	e8 33 18 00 00       	call   801ba0 <__umoddi3>
  80036d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800371:	0f be 80 d4 1d 80 00 	movsbl 0x801dd4(%eax),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80037e:	83 c4 4c             	add    $0x4c,%esp
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800389:	83 fa 01             	cmp    $0x1,%edx
  80038c:	7e 0e                	jle    80039c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 08             	lea    0x8(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	8b 52 04             	mov    0x4(%edx),%edx
  80039a:	eb 22                	jmp    8003be <getuint+0x38>
	else if (lflag)
  80039c:	85 d2                	test   %edx,%edx
  80039e:	74 10                	je     8003b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ae:	eb 0e                	jmp    8003be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cf:	73 0a                	jae    8003db <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d4:	88 0a                	mov    %cl,(%edx)
  8003d6:	83 c2 01             	add    $0x1,%edx
  8003d9:	89 10                	mov    %edx,(%eax)
}
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	53                   	push   %ebx
  8003e3:	83 ec 5c             	sub    $0x5c,%esp
  8003e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003f6:	eb 11                	jmp    800409 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	0f 84 02 04 00 00    	je     800802 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800400:	89 74 24 04          	mov    %esi,0x4(%esp)
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	0f b6 03             	movzbl (%ebx),%eax
  80040c:	83 c3 01             	add    $0x1,%ebx
  80040f:	83 f8 25             	cmp    $0x25,%eax
  800412:	75 e4                	jne    8003f8 <vprintfmt+0x1b>
  800414:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800418:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80041f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800426:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800432:	eb 06                	jmp    80043a <vprintfmt+0x5d>
  800434:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800438:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	0f b6 13             	movzbl (%ebx),%edx
  80043d:	0f b6 c2             	movzbl %dl,%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	8d 43 01             	lea    0x1(%ebx),%eax
  800446:	83 ea 23             	sub    $0x23,%edx
  800449:	80 fa 55             	cmp    $0x55,%dl
  80044c:	0f 87 93 03 00 00    	ja     8007e5 <vprintfmt+0x408>
  800452:	0f b6 d2             	movzbl %dl,%edx
  800455:	ff 24 95 20 1f 80 00 	jmp    *0x801f20(,%edx,4)
  80045c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800460:	eb d6                	jmp    800438 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800462:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800465:	83 ea 30             	sub    $0x30,%edx
  800468:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80046b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80046e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800471:	83 fb 09             	cmp    $0x9,%ebx
  800474:	77 4c                	ja     8004c2 <vprintfmt+0xe5>
  800476:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800479:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80047f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800482:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800486:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800489:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80048c:	83 fb 09             	cmp    $0x9,%ebx
  80048f:	76 eb                	jbe    80047c <vprintfmt+0x9f>
  800491:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800494:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800497:	eb 29                	jmp    8004c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800499:	8b 55 14             	mov    0x14(%ebp),%edx
  80049c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80049f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004a2:	8b 12                	mov    (%edx),%edx
  8004a4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8004a7:	eb 19                	jmp    8004c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8004a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ac:	c1 fa 1f             	sar    $0x1f,%edx
  8004af:	f7 d2                	not    %edx
  8004b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8004b4:	eb 82                	jmp    800438 <vprintfmt+0x5b>
  8004b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004bd:	e9 76 ff ff ff       	jmp    800438 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c6:	0f 89 6c ff ff ff    	jns    800438 <vprintfmt+0x5b>
  8004cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004d5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004d8:	e9 5b ff ff ff       	jmp    800438 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004e0:	e9 53 ff ff ff       	jmp    800438 <vprintfmt+0x5b>
  8004e5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	ff d7                	call   *%edi
  8004fc:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004ff:	e9 05 ff ff ff       	jmp    800409 <vprintfmt+0x2c>
  800504:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 50 04             	lea    0x4(%eax),%edx
  80050d:	89 55 14             	mov    %edx,0x14(%ebp)
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 c2                	mov    %eax,%edx
  800514:	c1 fa 1f             	sar    $0x1f,%edx
  800517:	31 d0                	xor    %edx,%eax
  800519:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80051b:	83 f8 0f             	cmp    $0xf,%eax
  80051e:	7f 0b                	jg     80052b <vprintfmt+0x14e>
  800520:	8b 14 85 80 20 80 00 	mov    0x802080(,%eax,4),%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	75 20                	jne    80054b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80052b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052f:	c7 44 24 08 e5 1d 80 	movl   $0x801de5,0x8(%esp)
  800536:	00 
  800537:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053b:	89 3c 24             	mov    %edi,(%esp)
  80053e:	e8 47 03 00 00       	call   80088a <printfmt>
  800543:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800546:	e9 be fe ff ff       	jmp    800409 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80054b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054f:	c7 44 24 08 ee 1d 80 	movl   $0x801dee,0x8(%esp)
  800556:	00 
  800557:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055b:	89 3c 24             	mov    %edi,(%esp)
  80055e:	e8 27 03 00 00       	call   80088a <printfmt>
  800563:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800566:	e9 9e fe ff ff       	jmp    800409 <vprintfmt+0x2c>
  80056b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800576:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800587:	85 c0                	test   %eax,%eax
  800589:	75 07                	jne    800592 <vprintfmt+0x1b5>
  80058b:	c7 45 e0 f1 1d 80 00 	movl   $0x801df1,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800592:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800596:	7e 06                	jle    80059e <vprintfmt+0x1c1>
  800598:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80059c:	75 13                	jne    8005b1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a1:	0f be 02             	movsbl (%edx),%eax
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	0f 85 99 00 00 00    	jne    800645 <vprintfmt+0x268>
  8005ac:	e9 86 00 00 00       	jmp    800637 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b8:	89 0c 24             	mov    %ecx,(%esp)
  8005bb:	e8 1b 03 00 00       	call   8008db <strnlen>
  8005c0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005c3:	29 c2                	sub    %eax,%edx
  8005c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	7e d2                	jle    80059e <vprintfmt+0x1c1>
					putch(padc, putdat);
  8005cc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005d0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005d3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005d6:	89 d3                	mov    %edx,%ebx
  8005d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	83 eb 01             	sub    $0x1,%ebx
  8005e7:	85 db                	test   %ebx,%ebx
  8005e9:	7f ed                	jg     8005d8 <vprintfmt+0x1fb>
  8005eb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f5:	eb a7                	jmp    80059e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fb:	74 18                	je     800615 <vprintfmt+0x238>
  8005fd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800600:	83 fa 5e             	cmp    $0x5e,%edx
  800603:	76 10                	jbe    800615 <vprintfmt+0x238>
					putch('?', putdat);
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800610:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800613:	eb 0a                	jmp    80061f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800623:	0f be 03             	movsbl (%ebx),%eax
  800626:	85 c0                	test   %eax,%eax
  800628:	74 05                	je     80062f <vprintfmt+0x252>
  80062a:	83 c3 01             	add    $0x1,%ebx
  80062d:	eb 29                	jmp    800658 <vprintfmt+0x27b>
  80062f:	89 fe                	mov    %edi,%esi
  800631:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800634:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800637:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063b:	7f 2e                	jg     80066b <vprintfmt+0x28e>
  80063d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800640:	e9 c4 fd ff ff       	jmp    800409 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800645:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800648:	83 c2 01             	add    $0x1,%edx
  80064b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80064e:	89 f7                	mov    %esi,%edi
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800656:	89 d3                	mov    %edx,%ebx
  800658:	85 f6                	test   %esi,%esi
  80065a:	78 9b                	js     8005f7 <vprintfmt+0x21a>
  80065c:	83 ee 01             	sub    $0x1,%esi
  80065f:	79 96                	jns    8005f7 <vprintfmt+0x21a>
  800661:	89 fe                	mov    %edi,%esi
  800663:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800666:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800669:	eb cc                	jmp    800637 <vprintfmt+0x25a>
  80066b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80066e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800671:	89 74 24 04          	mov    %esi,0x4(%esp)
  800675:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067e:	83 eb 01             	sub    $0x1,%ebx
  800681:	85 db                	test   %ebx,%ebx
  800683:	7f ec                	jg     800671 <vprintfmt+0x294>
  800685:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800688:	e9 7c fd ff ff       	jmp    800409 <vprintfmt+0x2c>
  80068d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800690:	83 f9 01             	cmp    $0x1,%ecx
  800693:	7e 16                	jle    8006ab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 08             	lea    0x8(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a9:	eb 32                	jmp    8006dd <vprintfmt+0x300>
	else if (lflag)
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	74 18                	je     8006c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bd:	89 c1                	mov    %eax,%ecx
  8006bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c5:	eb 16                	jmp    8006dd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	89 c2                	mov    %eax,%edx
  8006d7:	c1 fa 1f             	sar    $0x1f,%edx
  8006da:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e3:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ec:	0f 89 b1 00 00 00    	jns    8007a3 <vprintfmt+0x3c6>
				putch('-', putdat);
  8006f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fd:	ff d7                	call   *%edi
				num = -(long long) num;
  8006ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800702:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800705:	f7 d8                	neg    %eax
  800707:	83 d2 00             	adc    $0x0,%edx
  80070a:	f7 da                	neg    %edx
  80070c:	e9 92 00 00 00       	jmp    8007a3 <vprintfmt+0x3c6>
  800711:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800714:	89 ca                	mov    %ecx,%edx
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
  800719:	e8 68 fc ff ff       	call   800386 <getuint>
  80071e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800723:	eb 7e                	jmp    8007a3 <vprintfmt+0x3c6>
  800725:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800728:	89 ca                	mov    %ecx,%edx
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
  80072d:	e8 54 fc ff ff       	call   800386 <getuint>
			if ((long long) num < 0) {
  800732:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800735:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800738:	bb 08 00 00 00       	mov    $0x8,%ebx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	79 62                	jns    8007a3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800741:	89 74 24 04          	mov    %esi,0x4(%esp)
  800745:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074c:	ff d7                	call   *%edi
				num = -(long long) num;
  80074e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800751:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800754:	f7 d8                	neg    %eax
  800756:	83 d2 00             	adc    $0x0,%edx
  800759:	f7 da                	neg    %edx
  80075b:	eb 46                	jmp    8007a3 <vprintfmt+0x3c6>
  80075d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800760:	89 74 24 04          	mov    %esi,0x4(%esp)
  800764:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076b:	ff d7                	call   *%edi
			putch('x', putdat);
  80076d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800771:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800778:	ff d7                	call   *%edi
			num = (unsigned long long)
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
  80078a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078f:	eb 12                	jmp    8007a3 <vprintfmt+0x3c6>
  800791:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800794:	89 ca                	mov    %ecx,%edx
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	e8 e8 fb ff ff       	call   800386 <getuint>
  80079e:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007a7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007ab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007b6:	89 04 24             	mov    %eax,(%esp)
  8007b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	89 f8                	mov    %edi,%eax
  8007c1:	e8 ca fa ff ff       	call   800290 <printnum>
  8007c6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007c9:	e9 3b fc ff ff       	jmp    800409 <vprintfmt+0x2c>
  8007ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007d1:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d8:	89 14 24             	mov    %edx,(%esp)
  8007db:	ff d7                	call   *%edi
  8007dd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007e0:	e9 24 fc ff ff       	jmp    800409 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007f5:	80 38 25             	cmpb   $0x25,(%eax)
  8007f8:	0f 84 0b fc ff ff    	je     800409 <vprintfmt+0x2c>
  8007fe:	89 c3                	mov    %eax,%ebx
  800800:	eb f0                	jmp    8007f2 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800802:	83 c4 5c             	add    $0x5c,%esp
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5f                   	pop    %edi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 28             	sub    $0x28,%esp
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800816:	85 c0                	test   %eax,%eax
  800818:	74 04                	je     80081e <vsnprintf+0x14>
  80081a:	85 d2                	test   %edx,%edx
  80081c:	7f 07                	jg     800825 <vsnprintf+0x1b>
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800823:	eb 3b                	jmp    800860 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800825:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800828:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80082c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80082f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083d:	8b 45 10             	mov    0x10(%ebp),%eax
  800840:	89 44 24 08          	mov    %eax,0x8(%esp)
  800844:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084b:	c7 04 24 c0 03 80 00 	movl   $0x8003c0,(%esp)
  800852:	e8 86 fb ff ff       	call   8003dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800857:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086f:	8b 45 10             	mov    0x10(%ebp),%eax
  800872:	89 44 24 08          	mov    %eax,0x8(%esp)
  800876:	8b 45 0c             	mov    0xc(%ebp),%eax
  800879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	89 04 24             	mov    %eax,(%esp)
  800883:	e8 82 ff ff ff       	call   80080a <vsnprintf>
	va_end(ap);

	return rc;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800893:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800897:	8b 45 10             	mov    0x10(%ebp),%eax
  80089a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	89 04 24             	mov    %eax,(%esp)
  8008ab:	e8 2d fb ff ff       	call   8003dd <vprintfmt>
	va_end(ap);
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    
	...

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ce:	74 09                	je     8008d9 <strlen+0x19>
		n++;
  8008d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d7:	75 f7                	jne    8008d0 <strlen+0x10>
		n++;
	return n;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 19                	je     800902 <strnlen+0x27>
  8008e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008ec:	74 14                	je     800902 <strnlen+0x27>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f6:	39 c8                	cmp    %ecx,%eax
  8008f8:	74 0d                	je     800907 <strnlen+0x2c>
  8008fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008fe:	75 f3                	jne    8008f3 <strnlen+0x18>
  800900:	eb 05                	jmp    800907 <strnlen+0x2c>
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800919:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80091d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	84 c9                	test   %cl,%cl
  800925:	75 f2                	jne    800919 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800938:	85 f6                	test   %esi,%esi
  80093a:	74 18                	je     800954 <strncpy+0x2a>
  80093c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800947:	80 3a 01             	cmpb   $0x1,(%edx)
  80094a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	39 ce                	cmp    %ecx,%esi
  800952:	77 ed                	ja     800941 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 75 08             	mov    0x8(%ebp),%esi
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	89 f0                	mov    %esi,%eax
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 27                	je     800993 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80096c:	83 e9 01             	sub    $0x1,%ecx
  80096f:	74 1d                	je     80098e <strlcpy+0x36>
  800971:	0f b6 1a             	movzbl (%edx),%ebx
  800974:	84 db                	test   %bl,%bl
  800976:	74 16                	je     80098e <strlcpy+0x36>
			*dst++ = *src++;
  800978:	88 18                	mov    %bl,(%eax)
  80097a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80097d:	83 e9 01             	sub    $0x1,%ecx
  800980:	74 0e                	je     800990 <strlcpy+0x38>
			*dst++ = *src++;
  800982:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800985:	0f b6 1a             	movzbl (%edx),%ebx
  800988:	84 db                	test   %bl,%bl
  80098a:	75 ec                	jne    800978 <strlcpy+0x20>
  80098c:	eb 02                	jmp    800990 <strlcpy+0x38>
  80098e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800990:	c6 00 00             	movb   $0x0,(%eax)
  800993:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a2:	0f b6 01             	movzbl (%ecx),%eax
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 15                	je     8009be <strcmp+0x25>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	75 11                	jne    8009be <strcmp+0x25>
		p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 04                	je     8009be <strcmp+0x25>
  8009ba:	3a 02                	cmp    (%edx),%al
  8009bc:	74 ef                	je     8009ad <strcmp+0x14>
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 12             	movzbl (%edx),%edx
  8009c4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009d5:	85 c0                	test   %eax,%eax
  8009d7:	74 23                	je     8009fc <strncmp+0x34>
  8009d9:	0f b6 1a             	movzbl (%edx),%ebx
  8009dc:	84 db                	test   %bl,%bl
  8009de:	74 24                	je     800a04 <strncmp+0x3c>
  8009e0:	3a 19                	cmp    (%ecx),%bl
  8009e2:	75 20                	jne    800a04 <strncmp+0x3c>
  8009e4:	83 e8 01             	sub    $0x1,%eax
  8009e7:	74 13                	je     8009fc <strncmp+0x34>
		n--, p++, q++;
  8009e9:	83 c2 01             	add    $0x1,%edx
  8009ec:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ef:	0f b6 1a             	movzbl (%edx),%ebx
  8009f2:	84 db                	test   %bl,%bl
  8009f4:	74 0e                	je     800a04 <strncmp+0x3c>
  8009f6:	3a 19                	cmp    (%ecx),%bl
  8009f8:	74 ea                	je     8009e4 <strncmp+0x1c>
  8009fa:	eb 08                	jmp    800a04 <strncmp+0x3c>
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a01:	5b                   	pop    %ebx
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a04:	0f b6 02             	movzbl (%edx),%eax
  800a07:	0f b6 11             	movzbl (%ecx),%edx
  800a0a:	29 d0                	sub    %edx,%eax
  800a0c:	eb f3                	jmp    800a01 <strncmp+0x39>

00800a0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	74 15                	je     800a34 <strchr+0x26>
		if (*s == c)
  800a1f:	38 ca                	cmp    %cl,%dl
  800a21:	75 07                	jne    800a2a <strchr+0x1c>
  800a23:	eb 14                	jmp    800a39 <strchr+0x2b>
  800a25:	38 ca                	cmp    %cl,%dl
  800a27:	90                   	nop
  800a28:	74 0f                	je     800a39 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 f1                	jne    800a25 <strchr+0x17>
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	74 18                	je     800a64 <strfind+0x29>
		if (*s == c)
  800a4c:	38 ca                	cmp    %cl,%dl
  800a4e:	75 0a                	jne    800a5a <strfind+0x1f>
  800a50:	eb 12                	jmp    800a64 <strfind+0x29>
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a58:	74 0a                	je     800a64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 ee                	jne    800a52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 0c             	sub    $0xc,%esp
  800a6c:	89 1c 24             	mov    %ebx,(%esp)
  800a6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a80:	85 c9                	test   %ecx,%ecx
  800a82:	74 30                	je     800ab4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8a:	75 25                	jne    800ab1 <memset+0x4b>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 20                	jne    800ab1 <memset+0x4b>
		c &= 0xFF;
  800a91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	c1 e3 08             	shl    $0x8,%ebx
  800a99:	89 d6                	mov    %edx,%esi
  800a9b:	c1 e6 18             	shl    $0x18,%esi
  800a9e:	89 d0                	mov    %edx,%eax
  800aa0:	c1 e0 10             	shl    $0x10,%eax
  800aa3:	09 f0                	or     %esi,%eax
  800aa5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800aa7:	09 d8                	or     %ebx,%eax
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
  800aac:	fc                   	cld    
  800aad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aaf:	eb 03                	jmp    800ab4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab1:	fc                   	cld    
  800ab2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab4:	89 f8                	mov    %edi,%eax
  800ab6:	8b 1c 24             	mov    (%esp),%ebx
  800ab9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800abd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ac1:	89 ec                	mov    %ebp,%esp
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	89 34 24             	mov    %esi,(%esp)
  800ace:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800adb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800add:	39 c6                	cmp    %eax,%esi
  800adf:	73 35                	jae    800b16 <memmove+0x51>
  800ae1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae4:	39 d0                	cmp    %edx,%eax
  800ae6:	73 2e                	jae    800b16 <memmove+0x51>
		s += n;
		d += n;
  800ae8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aea:	f6 c2 03             	test   $0x3,%dl
  800aed:	75 1b                	jne    800b0a <memmove+0x45>
  800aef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af5:	75 13                	jne    800b0a <memmove+0x45>
  800af7:	f6 c1 03             	test   $0x3,%cl
  800afa:	75 0e                	jne    800b0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800afc:	83 ef 04             	sub    $0x4,%edi
  800aff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b02:	c1 e9 02             	shr    $0x2,%ecx
  800b05:	fd                   	std    
  800b06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b08:	eb 09                	jmp    800b13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b10:	fd                   	std    
  800b11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b14:	eb 20                	jmp    800b36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1c:	75 15                	jne    800b33 <memmove+0x6e>
  800b1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b24:	75 0d                	jne    800b33 <memmove+0x6e>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 08                	jne    800b33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
  800b2e:	fc                   	cld    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	eb 03                	jmp    800b36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b33:	fc                   	cld    
  800b34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b36:	8b 34 24             	mov    (%esp),%esi
  800b39:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b3d:	89 ec                	mov    %ebp,%esp
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 65 ff ff ff       	call   800ac5 <memmove>
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b71:	85 c9                	test   %ecx,%ecx
  800b73:	74 36                	je     800bab <memcmp+0x49>
		if (*s1 != *s2)
  800b75:	0f b6 06             	movzbl (%esi),%eax
  800b78:	0f b6 1f             	movzbl (%edi),%ebx
  800b7b:	38 d8                	cmp    %bl,%al
  800b7d:	74 20                	je     800b9f <memcmp+0x3d>
  800b7f:	eb 14                	jmp    800b95 <memcmp+0x33>
  800b81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b8b:	83 c2 01             	add    $0x1,%edx
  800b8e:	83 e9 01             	sub    $0x1,%ecx
  800b91:	38 d8                	cmp    %bl,%al
  800b93:	74 12                	je     800ba7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b95:	0f b6 c0             	movzbl %al,%eax
  800b98:	0f b6 db             	movzbl %bl,%ebx
  800b9b:	29 d8                	sub    %ebx,%eax
  800b9d:	eb 11                	jmp    800bb0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	83 e9 01             	sub    $0x1,%ecx
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	85 c9                	test   %ecx,%ecx
  800ba9:	75 d6                	jne    800b81 <memcmp+0x1f>
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc0:	39 d0                	cmp    %edx,%eax
  800bc2:	73 15                	jae    800bd9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bc8:	38 08                	cmp    %cl,(%eax)
  800bca:	75 06                	jne    800bd2 <memfind+0x1d>
  800bcc:	eb 0b                	jmp    800bd9 <memfind+0x24>
  800bce:	38 08                	cmp    %cl,(%eax)
  800bd0:	74 07                	je     800bd9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	39 c2                	cmp    %eax,%edx
  800bd7:	77 f5                	ja     800bce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 04             	sub    $0x4,%esp
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 02             	movzbl (%edx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 04                	je     800bf5 <strtol+0x1a>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	75 0e                	jne    800c03 <strtol+0x28>
		s++;
  800bf5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf8:	0f b6 02             	movzbl (%edx),%eax
  800bfb:	3c 20                	cmp    $0x20,%al
  800bfd:	74 f6                	je     800bf5 <strtol+0x1a>
  800bff:	3c 09                	cmp    $0x9,%al
  800c01:	74 f2                	je     800bf5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c03:	3c 2b                	cmp    $0x2b,%al
  800c05:	75 0c                	jne    800c13 <strtol+0x38>
		s++;
  800c07:	83 c2 01             	add    $0x1,%edx
  800c0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c11:	eb 15                	jmp    800c28 <strtol+0x4d>
	else if (*s == '-')
  800c13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 0a                	jne    800c28 <strtol+0x4d>
		s++, neg = 1;
  800c1e:	83 c2 01             	add    $0x1,%edx
  800c21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c28:	85 db                	test   %ebx,%ebx
  800c2a:	0f 94 c0             	sete   %al
  800c2d:	74 05                	je     800c34 <strtol+0x59>
  800c2f:	83 fb 10             	cmp    $0x10,%ebx
  800c32:	75 18                	jne    800c4c <strtol+0x71>
  800c34:	80 3a 30             	cmpb   $0x30,(%edx)
  800c37:	75 13                	jne    800c4c <strtol+0x71>
  800c39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c3d:	8d 76 00             	lea    0x0(%esi),%esi
  800c40:	75 0a                	jne    800c4c <strtol+0x71>
		s += 2, base = 16;
  800c42:	83 c2 02             	add    $0x2,%edx
  800c45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4a:	eb 15                	jmp    800c61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	84 c0                	test   %al,%al
  800c4e:	66 90                	xchg   %ax,%ax
  800c50:	74 0f                	je     800c61 <strtol+0x86>
  800c52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c57:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5a:	75 05                	jne    800c61 <strtol+0x86>
		s++, base = 8;
  800c5c:	83 c2 01             	add    $0x1,%edx
  800c5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
  800c66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c68:	0f b6 0a             	movzbl (%edx),%ecx
  800c6b:	89 cf                	mov    %ecx,%edi
  800c6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c70:	80 fb 09             	cmp    $0x9,%bl
  800c73:	77 08                	ja     800c7d <strtol+0xa2>
			dig = *s - '0';
  800c75:	0f be c9             	movsbl %cl,%ecx
  800c78:	83 e9 30             	sub    $0x30,%ecx
  800c7b:	eb 1e                	jmp    800c9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 08                	ja     800c8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c85:	0f be c9             	movsbl %cl,%ecx
  800c88:	83 e9 57             	sub    $0x57,%ecx
  800c8b:	eb 0e                	jmp    800c9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c90:	80 fb 19             	cmp    $0x19,%bl
  800c93:	77 15                	ja     800caa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c95:	0f be c9             	movsbl %cl,%ecx
  800c98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9b:	39 f1                	cmp    %esi,%ecx
  800c9d:	7d 0b                	jge    800caa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c9f:	83 c2 01             	add    $0x1,%edx
  800ca2:	0f af c6             	imul   %esi,%eax
  800ca5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ca8:	eb be                	jmp    800c68 <strtol+0x8d>
  800caa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb0:	74 05                	je     800cb7 <strtol+0xdc>
		*endptr = (char *) s;
  800cb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cbb:	74 04                	je     800cc1 <strtol+0xe6>
  800cbd:	89 c8                	mov    %ecx,%eax
  800cbf:	f7 d8                	neg    %eax
}
  800cc1:	83 c4 04             	add    $0x4,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
  800cc9:	00 00                	add    %al,(%eax)
	...

00800ccc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	89 1c 24             	mov    %ebx,(%esp)
  800cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce7:	89 d1                	mov    %edx,%ecx
  800ce9:	89 d3                	mov    %edx,%ebx
  800ceb:	89 d7                	mov    %edx,%edi
  800ced:	89 d6                	mov    %edx,%esi
  800cef:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf1:	8b 1c 24             	mov    (%esp),%ebx
  800cf4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cfc:	89 ec                	mov    %ebp,%esp
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 c3                	mov    %eax,%ebx
  800d1e:	89 c7                	mov    %eax,%edi
  800d20:	89 c6                	mov    %eax,%esi
  800d22:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d24:	8b 1c 24             	mov    (%esp),%ebx
  800d27:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d2b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d2f:	89 ec                	mov    %ebp,%esp
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 38             	sub    $0x38,%esp
  800d39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d47:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 cb                	mov    %ecx,%ebx
  800d51:	89 cf                	mov    %ecx,%edi
  800d53:	89 ce                	mov    %ecx,%esi
  800d55:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7e 28                	jle    800d83 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d66:	00 
  800d67:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d76:	00 
  800d77:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800d7e:	e8 c9 0b 00 00       	call   80194c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d83:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d86:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d89:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8c:	89 ec                	mov    %ebp,%esp
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	89 1c 24             	mov    %ebx,(%esp)
  800d99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d9d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	be 00 00 00 00       	mov    $0x0,%esi
  800da6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db9:	8b 1c 24             	mov    (%esp),%ebx
  800dbc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dc0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dc4:	89 ec                	mov    %ebp,%esp
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 38             	sub    $0x38,%esp
  800dce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	89 de                	mov    %ebx,%esi
  800deb:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 28                	jle    800e19 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df5:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800e04:	00 
  800e05:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e0c:	00 
  800e0d:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800e14:	e8 33 0b 00 00       	call   80194c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e19:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e1f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e22:	89 ec                	mov    %ebp,%esp
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 38             	sub    $0x38,%esp
  800e2c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e2f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e32:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	89 df                	mov    %ebx,%edi
  800e47:	89 de                	mov    %ebx,%esi
  800e49:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	7e 28                	jle    800e77 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e53:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800e62:	00 
  800e63:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e6a:	00 
  800e6b:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800e72:	e8 d5 0a 00 00       	call   80194c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e80:	89 ec                	mov    %ebp,%esp
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 38             	sub    $0x38,%esp
  800e8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e90:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e98:	b8 08 00 00 00       	mov    $0x8,%eax
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	89 df                	mov    %ebx,%edi
  800ea5:	89 de                	mov    %ebx,%esi
  800ea7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	7e 28                	jle    800ed5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ead:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ec8:	00 
  800ec9:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800ed0:	e8 77 0a 00 00       	call   80194c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800edb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ede:	89 ec                	mov    %ebp,%esp
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 38             	sub    $0x38,%esp
  800ee8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eeb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	89 df                	mov    %ebx,%edi
  800f03:	89 de                	mov    %ebx,%esi
  800f05:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f07:	85 c0                	test   %eax,%eax
  800f09:	7e 28                	jle    800f33 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f16:	00 
  800f17:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f26:	00 
  800f27:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800f2e:	e8 19 0a 00 00       	call   80194c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f33:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f36:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3c:	89 ec                	mov    %ebp,%esp
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 38             	sub    $0x38,%esp
  800f46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f54:	8b 75 18             	mov    0x18(%ebp),%esi
  800f57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 28                	jle    800f91 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f74:	00 
  800f75:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800f8c:	e8 bb 09 00 00       	call   80194c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f91:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f94:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f97:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9a:	89 ec                	mov    %ebp,%esp
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 38             	sub    $0x38,%esp
  800fa4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800faa:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fad:	be 00 00 00 00       	mov    $0x0,%esi
  800fb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc0:	89 f7                	mov    %esi,%edi
  800fc2:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	7e 28                	jle    800ff0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fe3:	00 
  800fe4:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800feb:	e8 5c 09 00 00       	call   80194c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ff0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff9:	89 ec                	mov    %ebp,%esp
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	89 1c 24             	mov    %ebx,(%esp)
  801006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 0b 00 00 00       	mov    $0xb,%eax
  801018:	89 d1                	mov    %edx,%ecx
  80101a:	89 d3                	mov    %edx,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 d6                	mov    %edx,%esi
  801020:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801022:	8b 1c 24             	mov    (%esp),%ebx
  801025:	8b 74 24 04          	mov    0x4(%esp),%esi
  801029:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80102d:	89 ec                	mov    %ebp,%esp
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	89 1c 24             	mov    %ebx,(%esp)
  80103a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	ba 00 00 00 00       	mov    $0x0,%edx
  801047:	b8 02 00 00 00       	mov    $0x2,%eax
  80104c:	89 d1                	mov    %edx,%ecx
  80104e:	89 d3                	mov    %edx,%ebx
  801050:	89 d7                	mov    %edx,%edi
  801052:	89 d6                	mov    %edx,%esi
  801054:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801056:	8b 1c 24             	mov    (%esp),%ebx
  801059:	8b 74 24 04          	mov    0x4(%esp),%esi
  80105d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801061:	89 ec                	mov    %ebp,%esp
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 38             	sub    $0x38,%esp
  80106b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80106e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801071:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	b9 00 00 00 00       	mov    $0x0,%ecx
  801079:	b8 03 00 00 00       	mov    $0x3,%eax
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 cb                	mov    %ecx,%ebx
  801083:	89 cf                	mov    %ecx,%edi
  801085:	89 ce                	mov    %ecx,%esi
  801087:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7e 28                	jle    8010b5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801091:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801098:	00 
  801099:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  8010b0:	e8 97 08 00 00       	call   80194c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010be:	89 ec                	mov    %ebp,%esp
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    
	...

008010d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	89 04 24             	mov    %eax,(%esp)
  8010ec:	e8 df ff ff ff       	call   8010d0 <fd2num>
  8010f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801104:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801109:	a8 01                	test   $0x1,%al
  80110b:	74 36                	je     801143 <fd_alloc+0x48>
  80110d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801112:	a8 01                	test   $0x1,%al
  801114:	74 2d                	je     801143 <fd_alloc+0x48>
  801116:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80111b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801120:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801125:	89 c3                	mov    %eax,%ebx
  801127:	89 c2                	mov    %eax,%edx
  801129:	c1 ea 16             	shr    $0x16,%edx
  80112c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	74 14                	je     801148 <fd_alloc+0x4d>
  801134:	89 c2                	mov    %eax,%edx
  801136:	c1 ea 0c             	shr    $0xc,%edx
  801139:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80113c:	f6 c2 01             	test   $0x1,%dl
  80113f:	75 10                	jne    801151 <fd_alloc+0x56>
  801141:	eb 05                	jmp    801148 <fd_alloc+0x4d>
  801143:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801148:	89 1f                	mov    %ebx,(%edi)
  80114a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80114f:	eb 17                	jmp    801168 <fd_alloc+0x6d>
  801151:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801156:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115b:	75 c8                	jne    801125 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80115d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801163:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	83 f8 1f             	cmp    $0x1f,%eax
  801176:	77 36                	ja     8011ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801178:	05 00 00 0d 00       	add    $0xd0000,%eax
  80117d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801180:	89 c2                	mov    %eax,%edx
  801182:	c1 ea 16             	shr    $0x16,%edx
  801185:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118c:	f6 c2 01             	test   $0x1,%dl
  80118f:	74 1d                	je     8011ae <fd_lookup+0x41>
  801191:	89 c2                	mov    %eax,%edx
  801193:	c1 ea 0c             	shr    $0xc,%edx
  801196:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119d:	f6 c2 01             	test   $0x1,%dl
  8011a0:	74 0c                	je     8011ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	89 02                	mov    %eax,(%edx)
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8011ac:	eb 05                	jmp    8011b3 <fd_lookup+0x46>
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 a0 ff ff ff       	call   80116d <fd_lookup>
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 0e                	js     8011df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8011d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d7:	89 50 04             	mov    %edx,0x4(%eax)
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    

008011e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 10             	sub    $0x10,%esp
  8011e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8011ef:	b8 78 67 80 00       	mov    $0x806778,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8011f4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f9:	be 8c 21 80 00       	mov    $0x80218c,%esi
		if (devtab[i]->dev_id == dev_id) {
  8011fe:	39 08                	cmp    %ecx,(%eax)
  801200:	75 10                	jne    801212 <dev_lookup+0x31>
  801202:	eb 04                	jmp    801208 <dev_lookup+0x27>
  801204:	39 08                	cmp    %ecx,(%eax)
  801206:	75 0a                	jne    801212 <dev_lookup+0x31>
			*dev = devtab[i];
  801208:	89 03                	mov    %eax,(%ebx)
  80120a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80120f:	90                   	nop
  801210:	eb 31                	jmp    801243 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801212:	83 c2 01             	add    $0x1,%edx
  801215:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801218:	85 c0                	test   %eax,%eax
  80121a:	75 e8                	jne    801204 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  80121c:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801221:	8b 40 4c             	mov    0x4c(%eax),%eax
  801224:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122c:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  801233:	e8 f1 ef ff ff       	call   800229 <cprintf>
	*dev = 0;
  801238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80123e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	53                   	push   %ebx
  80124e:	83 ec 24             	sub    $0x24,%esp
  801251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801254:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	89 04 24             	mov    %eax,(%esp)
  801261:	e8 07 ff ff ff       	call   80116d <fd_lookup>
  801266:	85 c0                	test   %eax,%eax
  801268:	78 53                	js     8012bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801274:	8b 00                	mov    (%eax),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 63 ff ff ff       	call   8011e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 3b                	js     8012bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801282:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801287:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80128e:	74 2d                	je     8012bd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801290:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801293:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80129a:	00 00 00 
	stat->st_isdir = 0;
  80129d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a4:	00 00 00 
	stat->st_dev = dev;
  8012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b7:	89 14 24             	mov    %edx,(%esp)
  8012ba:	ff 50 14             	call   *0x14(%eax)
}
  8012bd:	83 c4 24             	add    $0x24,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 24             	sub    $0x24,%esp
  8012ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	89 1c 24             	mov    %ebx,(%esp)
  8012d7:	e8 91 fe ff ff       	call   80116d <fd_lookup>
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 5f                	js     80133f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	8b 00                	mov    (%eax),%eax
  8012ec:	89 04 24             	mov    %eax,(%esp)
  8012ef:	e8 ed fe ff ff       	call   8011e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 47                	js     80133f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012fb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012ff:	75 23                	jne    801324 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  801301:	a1 10 7f 80 00       	mov    0x807f10,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801306:	8b 40 4c             	mov    0x4c(%eax),%eax
  801309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	c7 04 24 2c 21 80 00 	movl   $0x80212c,(%esp)
  801318:	e8 0c ef ff ff       	call   800229 <cprintf>
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  801322:	eb 1b                	jmp    80133f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801324:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801327:	8b 48 18             	mov    0x18(%eax),%ecx
  80132a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80132f:	85 c9                	test   %ecx,%ecx
  801331:	74 0c                	je     80133f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801333:	8b 45 0c             	mov    0xc(%ebp),%eax
  801336:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133a:	89 14 24             	mov    %edx,(%esp)
  80133d:	ff d1                	call   *%ecx
}
  80133f:	83 c4 24             	add    $0x24,%esp
  801342:	5b                   	pop    %ebx
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 24             	sub    $0x24,%esp
  80134c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	89 1c 24             	mov    %ebx,(%esp)
  801359:	e8 0f fe ff ff       	call   80116d <fd_lookup>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 66                	js     8013c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	89 44 24 04          	mov    %eax,0x4(%esp)
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	8b 00                	mov    (%eax),%eax
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	e8 6b fe ff ff       	call   8011e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801376:	85 c0                	test   %eax,%eax
  801378:	78 4e                	js     8013c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80137d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801381:	75 23                	jne    8013a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801383:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801388:	8b 40 4c             	mov    0x4c(%eax),%eax
  80138b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80138f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801393:	c7 04 24 50 21 80 00 	movl   $0x802150,(%esp)
  80139a:	e8 8a ee ff ff       	call   800229 <cprintf>
  80139f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013a4:	eb 22                	jmp    8013c8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013b1:	85 c9                	test   %ecx,%ecx
  8013b3:	74 13                	je     8013c8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	89 14 24             	mov    %edx,(%esp)
  8013c6:	ff d1                	call   *%ecx
}
  8013c8:	83 c4 24             	add    $0x24,%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 24             	sub    $0x24,%esp
  8013d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013df:	89 1c 24             	mov    %ebx,(%esp)
  8013e2:	e8 86 fd ff ff       	call   80116d <fd_lookup>
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 6b                	js     801456 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f5:	8b 00                	mov    (%eax),%eax
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 e2 fd ff ff       	call   8011e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 53                	js     801456 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801403:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801406:	8b 42 08             	mov    0x8(%edx),%eax
  801409:	83 e0 03             	and    $0x3,%eax
  80140c:	83 f8 01             	cmp    $0x1,%eax
  80140f:	75 23                	jne    801434 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801411:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801416:	8b 40 4c             	mov    0x4c(%eax),%eax
  801419:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80141d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801421:	c7 04 24 6d 21 80 00 	movl   $0x80216d,(%esp)
  801428:	e8 fc ed ff ff       	call   800229 <cprintf>
  80142d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801432:	eb 22                	jmp    801456 <read+0x88>
	}
	if (!dev->dev_read)
  801434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801437:	8b 48 08             	mov    0x8(%eax),%ecx
  80143a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80143f:	85 c9                	test   %ecx,%ecx
  801441:	74 13                	je     801456 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801443:	8b 45 10             	mov    0x10(%ebp),%eax
  801446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801451:	89 14 24             	mov    %edx,(%esp)
  801454:	ff d1                	call   *%ecx
}
  801456:	83 c4 24             	add    $0x24,%esp
  801459:	5b                   	pop    %ebx
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	57                   	push   %edi
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
  801462:	83 ec 1c             	sub    $0x1c,%esp
  801465:	8b 7d 08             	mov    0x8(%ebp),%edi
  801468:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	bb 00 00 00 00       	mov    $0x0,%ebx
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
  80147a:	85 f6                	test   %esi,%esi
  80147c:	74 29                	je     8014a7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147e:	89 f0                	mov    %esi,%eax
  801480:	29 d0                	sub    %edx,%eax
  801482:	89 44 24 08          	mov    %eax,0x8(%esp)
  801486:	03 55 0c             	add    0xc(%ebp),%edx
  801489:	89 54 24 04          	mov    %edx,0x4(%esp)
  80148d:	89 3c 24             	mov    %edi,(%esp)
  801490:	e8 39 ff ff ff       	call   8013ce <read>
		if (m < 0)
  801495:	85 c0                	test   %eax,%eax
  801497:	78 0e                	js     8014a7 <readn+0x4b>
			return m;
		if (m == 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	74 08                	je     8014a5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149d:	01 c3                	add    %eax,%ebx
  80149f:	89 da                	mov    %ebx,%edx
  8014a1:	39 f3                	cmp    %esi,%ebx
  8014a3:	72 d9                	jb     80147e <readn+0x22>
  8014a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a7:	83 c4 1c             	add    $0x1c,%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 20             	sub    $0x20,%esp
  8014b7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ba:	89 34 24             	mov    %esi,(%esp)
  8014bd:	e8 0e fc ff ff       	call   8010d0 <fd2num>
  8014c2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c9:	89 04 24             	mov    %eax,(%esp)
  8014cc:	e8 9c fc ff ff       	call   80116d <fd_lookup>
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 05                	js     8014dc <fd_close+0x2d>
  8014d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014da:	74 0c                	je     8014e8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8014dc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8014e0:	19 c0                	sbb    %eax,%eax
  8014e2:	f7 d0                	not    %eax
  8014e4:	21 c3                	and    %eax,%ebx
  8014e6:	eb 3d                	jmp    801525 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ef:	8b 06                	mov    (%esi),%eax
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 e8 fc ff ff       	call   8011e1 <dev_lookup>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 16                	js     801515 <fd_close+0x66>
		if (dev->dev_close)
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	8b 40 10             	mov    0x10(%eax),%eax
  801505:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150a:	85 c0                	test   %eax,%eax
  80150c:	74 07                	je     801515 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80150e:	89 34 24             	mov    %esi,(%esp)
  801511:	ff d0                	call   *%eax
  801513:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801515:	89 74 24 04          	mov    %esi,0x4(%esp)
  801519:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801520:	e8 bd f9 ff ff       	call   800ee2 <sys_page_unmap>
	return r;
}
  801525:	89 d8                	mov    %ebx,%eax
  801527:	83 c4 20             	add    $0x20,%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	89 04 24             	mov    %eax,(%esp)
  801541:	e8 27 fc ff ff       	call   80116d <fd_lookup>
  801546:	85 c0                	test   %eax,%eax
  801548:	78 13                	js     80155d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80154a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801551:	00 
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 52 ff ff ff       	call   8014af <fd_close>
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	83 ec 18             	sub    $0x18,%esp
  801565:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801568:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80156b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801572:	00 
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 4d 03 00 00       	call   8018cb <open>
  80157e:	89 c3                	mov    %eax,%ebx
  801580:	85 c0                	test   %eax,%eax
  801582:	78 1b                	js     80159f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801584:	8b 45 0c             	mov    0xc(%ebp),%eax
  801587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158b:	89 1c 24             	mov    %ebx,(%esp)
  80158e:	e8 b7 fc ff ff       	call   80124a <fstat>
  801593:	89 c6                	mov    %eax,%esi
	close(fd);
  801595:	89 1c 24             	mov    %ebx,(%esp)
  801598:	e8 91 ff ff ff       	call   80152e <close>
  80159d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80159f:	89 d8                	mov    %ebx,%eax
  8015a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015a7:	89 ec                	mov    %ebp,%esp
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    

008015ab <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 14             	sub    $0x14,%esp
  8015b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015b7:	89 1c 24             	mov    %ebx,(%esp)
  8015ba:	e8 6f ff ff ff       	call   80152e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bf:	83 c3 01             	add    $0x1,%ebx
  8015c2:	83 fb 20             	cmp    $0x20,%ebx
  8015c5:	75 f0                	jne    8015b7 <close_all+0xc>
		close(i);
}
  8015c7:	83 c4 14             	add    $0x14,%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 58             	sub    $0x58,%esp
  8015d3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015d6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015d9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e9:	89 04 24             	mov    %eax,(%esp)
  8015ec:	e8 7c fb ff ff       	call   80116d <fd_lookup>
  8015f1:	89 c3                	mov    %eax,%ebx
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	0f 88 e0 00 00 00    	js     8016db <dup+0x10e>
		return r;
	close(newfdnum);
  8015fb:	89 3c 24             	mov    %edi,(%esp)
  8015fe:	e8 2b ff ff ff       	call   80152e <close>

	newfd = INDEX2FD(newfdnum);
  801603:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801609:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80160c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	e8 c9 fa ff ff       	call   8010e0 <fd2data>
  801617:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801619:	89 34 24             	mov    %esi,(%esp)
  80161c:	e8 bf fa ff ff       	call   8010e0 <fd2data>
  801621:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801624:	89 da                	mov    %ebx,%edx
  801626:	89 d8                	mov    %ebx,%eax
  801628:	c1 e8 16             	shr    $0x16,%eax
  80162b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801632:	a8 01                	test   $0x1,%al
  801634:	74 43                	je     801679 <dup+0xac>
  801636:	c1 ea 0c             	shr    $0xc,%edx
  801639:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801640:	a8 01                	test   $0x1,%al
  801642:	74 35                	je     801679 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801644:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80164b:	25 07 0e 00 00       	and    $0xe07,%eax
  801650:	89 44 24 10          	mov    %eax,0x10(%esp)
  801654:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801657:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80165b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801662:	00 
  801663:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801667:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166e:	e8 cd f8 ff ff       	call   800f40 <sys_page_map>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	85 c0                	test   %eax,%eax
  801677:	78 3f                	js     8016b8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	c1 ea 0c             	shr    $0xc,%edx
  801681:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801688:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80168e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801692:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801696:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80169d:	00 
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a9:	e8 92 f8 ff ff       	call   800f40 <sys_page_map>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 04                	js     8016b8 <dup+0xeb>
  8016b4:	89 fb                	mov    %edi,%ebx
  8016b6:	eb 23                	jmp    8016db <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c3:	e8 1a f8 ff ff       	call   800ee2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d6:	e8 07 f8 ff ff       	call   800ee2 <sys_page_unmap>
	return r;
}
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016e0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016e3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016e6:	89 ec                	mov    %ebp,%esp
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    
  8016ea:	00 00                	add    %al,(%eax)
  8016ec:	00 00                	add    %al,(%eax)
	...

008016f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 14             	sub    $0x14,%esp
  8016f7:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016f9:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8016ff:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801706:	00 
  801707:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80170e:	00 
  80170f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801713:	89 14 24             	mov    %edx,(%esp)
  801716:	e8 95 02 00 00       	call   8019b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801722:	00 
  801723:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801727:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172e:	e8 e7 02 00 00       	call   801a1a <ipc_recv>
}
  801733:	83 c4 14             	add    $0x14,%esp
  801736:	5b                   	pop    %ebx
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  80174a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174d:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801752:	ba 00 00 00 00       	mov    $0x0,%edx
  801757:	b8 02 00 00 00       	mov    $0x2,%eax
  80175c:	e8 8f ff ff ff       	call   8016f0 <fsipc>
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801769:	8b 45 08             	mov    0x8(%ebp),%eax
  80176c:	8b 40 0c             	mov    0xc(%eax),%eax
  80176f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	b8 06 00 00 00       	mov    $0x6,%eax
  80177e:	e8 6d ff ff ff       	call   8016f0 <fsipc>
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	b8 08 00 00 00       	mov    $0x8,%eax
  801795:	e8 56 ff ff ff       	call   8016f0 <fsipc>
}
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 14             	sub    $0x14,%esp
  8017a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ac:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8017bb:	e8 30 ff ff ff       	call   8016f0 <fsipc>
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 2b                	js     8017ef <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c4:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8017cb:	00 
  8017cc:	89 1c 24             	mov    %ebx,(%esp)
  8017cf:	e8 36 f1 ff ff       	call   80090a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d4:	a1 80 30 80 00       	mov    0x803080,%eax
  8017d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017df:	a1 84 30 80 00       	mov    0x803084,%eax
  8017e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017ef:	83 c4 14             	add    $0x14,%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 18             	sub    $0x18,%esp
  8017fb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801801:	8b 52 0c             	mov    0xc(%edx),%edx
  801804:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  80180a:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80180f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181a:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801821:	e8 9f f2 ff ff       	call   800ac5 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801826:	ba 00 30 80 00       	mov    $0x803000,%edx
  80182b:	b8 04 00 00 00       	mov    $0x4,%eax
  801830:	e8 bb fe ff ff       	call   8016f0 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	53                   	push   %ebx
  80183b:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 40 0c             	mov    0xc(%eax),%eax
  801844:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801849:	8b 45 10             	mov    0x10(%ebp),%eax
  80184c:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801851:	ba 00 30 80 00       	mov    $0x803000,%edx
  801856:	b8 03 00 00 00       	mov    $0x3,%eax
  80185b:	e8 90 fe ff ff       	call   8016f0 <fsipc>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	85 c0                	test   %eax,%eax
  801864:	78 17                	js     80187d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801866:	89 44 24 08          	mov    %eax,0x8(%esp)
  80186a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801871:	00 
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 48 f2 ff ff       	call   800ac5 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80187d:	89 d8                	mov    %ebx,%eax
  80187f:	83 c4 14             	add    $0x14,%esp
  801882:	5b                   	pop    %ebx
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	53                   	push   %ebx
  801889:	83 ec 14             	sub    $0x14,%esp
  80188c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80188f:	89 1c 24             	mov    %ebx,(%esp)
  801892:	e8 29 f0 ff ff       	call   8008c0 <strlen>
  801897:	89 c2                	mov    %eax,%edx
  801899:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80189e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8018a4:	7f 1f                	jg     8018c5 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8018a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018aa:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018b1:	e8 54 f0 ff ff       	call   80090a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8018c0:	e8 2b fe ff ff       	call   8016f0 <fsipc>
}
  8018c5:	83 c4 14             	add    $0x14,%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  8018d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d4:	89 04 24             	mov    %eax,(%esp)
  8018d7:	e8 1f f8 ff ff       	call   8010fb <fd_alloc>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 6a                	js     80194a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  8018ee:	e8 17 f0 ff ff       	call   80090a <strcpy>
        fsipcbuf.open.req_omode = mode;
  8018f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f6:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018fb:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801900:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801907:	00 
  801908:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80190f:	00 
  801910:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801917:	00 
  801918:	89 04 24             	mov    %eax,(%esp)
  80191b:	e8 90 00 00 00       	call   8019b0 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801920:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801927:	00 
  801928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801936:	e8 df 00 00 00       	call   801a1a <ipc_recv>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 0b                	js     80194a <open+0x7f>
		return r;
	return fd2num(fd);
  80193f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	e8 86 f7 ff ff       	call   8010d0 <fd2num>
	panic("open not implemented");
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  801953:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801956:	a1 14 7f 80 00       	mov    0x807f14,%eax
  80195b:	85 c0                	test   %eax,%eax
  80195d:	74 10                	je     80196f <_panic+0x23>
		cprintf("%s: ", argv0);
  80195f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801963:	c7 04 24 94 21 80 00 	movl   $0x802194,(%esp)
  80196a:	e8 ba e8 ff ff       	call   800229 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80196f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801972:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	89 44 24 08          	mov    %eax,0x8(%esp)
  80197d:	a1 70 67 80 00       	mov    0x806770,%eax
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	c7 04 24 99 21 80 00 	movl   $0x802199,(%esp)
  80198d:	e8 97 e8 ff ff       	call   800229 <cprintf>
	vcprintf(fmt, ap);
  801992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801996:	8b 45 10             	mov    0x10(%ebp),%eax
  801999:	89 04 24             	mov    %eax,(%esp)
  80199c:	e8 27 e8 ff ff       	call   8001c8 <vcprintf>
	cprintf("\n");
  8019a1:	c7 04 24 bb 1d 80 00 	movl   $0x801dbb,(%esp)
  8019a8:	e8 7c e8 ff ff       	call   800229 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019ad:	cc                   	int3   
  8019ae:	eb fd                	jmp    8019ad <_panic+0x61>

008019b0 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 1c             	sub    $0x1c,%esp
  8019b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019bf:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  8019c2:	85 db                	test   %ebx,%ebx
  8019c4:	75 31                	jne    8019f7 <ipc_send+0x47>
  8019c6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8019cb:	eb 2a                	jmp    8019f7 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  8019cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019d0:	74 20                	je     8019f2 <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  8019d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d6:	c7 44 24 08 b5 21 80 	movl   $0x8021b5,0x8(%esp)
  8019dd:	00 
  8019de:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8019e5:	00 
  8019e6:	c7 04 24 cc 21 80 00 	movl   $0x8021cc,(%esp)
  8019ed:	e8 5a ff ff ff       	call   80194c <_panic>


                sys_yield();
  8019f2:	e8 06 f6 ff ff       	call   800ffd <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8019f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 82 f3 ff ff       	call   800d90 <sys_ipc_try_send>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 bb                	js     8019cd <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801a12:	83 c4 1c             	add    $0x1c,%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 10             	sub    $0x10,%esp
  801a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a28:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	75 05                	jne    801a34 <ipc_recv+0x1a>
  801a2f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	e8 f7 f2 ff ff       	call   800d33 <sys_ipc_recv>
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 24                	js     801a64 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801a40:	85 db                	test   %ebx,%ebx
  801a42:	74 0a                	je     801a4e <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801a44:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801a49:	8b 40 74             	mov    0x74(%eax),%eax
  801a4c:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  801a4e:	85 f6                	test   %esi,%esi
  801a50:	74 0a                	je     801a5c <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801a52:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801a57:	8b 40 78             	mov    0x78(%eax),%eax
  801a5a:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  801a5c:	a1 10 7f 80 00       	mov    0x807f10,%eax
  801a61:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    
  801a6b:	00 00                	add    %al,(%eax)
  801a6d:	00 00                	add    %al,(%eax)
	...

00801a70 <__udivdi3>:
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	83 ec 10             	sub    $0x10,%esp
  801a78:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a7e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a84:	85 c0                	test   %eax,%eax
  801a86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801a89:	75 35                	jne    801ac0 <__udivdi3+0x50>
  801a8b:	39 fe                	cmp    %edi,%esi
  801a8d:	77 61                	ja     801af0 <__udivdi3+0x80>
  801a8f:	85 f6                	test   %esi,%esi
  801a91:	75 0b                	jne    801a9e <__udivdi3+0x2e>
  801a93:	b8 01 00 00 00       	mov    $0x1,%eax
  801a98:	31 d2                	xor    %edx,%edx
  801a9a:	f7 f6                	div    %esi
  801a9c:	89 c6                	mov    %eax,%esi
  801a9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801aa1:	31 d2                	xor    %edx,%edx
  801aa3:	89 f8                	mov    %edi,%eax
  801aa5:	f7 f6                	div    %esi
  801aa7:	89 c7                	mov    %eax,%edi
  801aa9:	89 c8                	mov    %ecx,%eax
  801aab:	f7 f6                	div    %esi
  801aad:	89 c1                	mov    %eax,%ecx
  801aaf:	89 fa                	mov    %edi,%edx
  801ab1:	89 c8                	mov    %ecx,%eax
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    
  801aba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ac0:	39 f8                	cmp    %edi,%eax
  801ac2:	77 1c                	ja     801ae0 <__udivdi3+0x70>
  801ac4:	0f bd d0             	bsr    %eax,%edx
  801ac7:	83 f2 1f             	xor    $0x1f,%edx
  801aca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801acd:	75 39                	jne    801b08 <__udivdi3+0x98>
  801acf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ad2:	0f 86 a0 00 00 00    	jbe    801b78 <__udivdi3+0x108>
  801ad8:	39 f8                	cmp    %edi,%eax
  801ada:	0f 82 98 00 00 00    	jb     801b78 <__udivdi3+0x108>
  801ae0:	31 ff                	xor    %edi,%edi
  801ae2:	31 c9                	xor    %ecx,%ecx
  801ae4:	89 c8                	mov    %ecx,%eax
  801ae6:	89 fa                	mov    %edi,%edx
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	5e                   	pop    %esi
  801aec:	5f                   	pop    %edi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    
  801aef:	90                   	nop
  801af0:	89 d1                	mov    %edx,%ecx
  801af2:	89 fa                	mov    %edi,%edx
  801af4:	89 c8                	mov    %ecx,%eax
  801af6:	31 ff                	xor    %edi,%edi
  801af8:	f7 f6                	div    %esi
  801afa:	89 c1                	mov    %eax,%ecx
  801afc:	89 fa                	mov    %edi,%edx
  801afe:	89 c8                	mov    %ecx,%eax
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    
  801b07:	90                   	nop
  801b08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b0c:	89 f2                	mov    %esi,%edx
  801b0e:	d3 e0                	shl    %cl,%eax
  801b10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b13:	b8 20 00 00 00       	mov    $0x20,%eax
  801b18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b1b:	89 c1                	mov    %eax,%ecx
  801b1d:	d3 ea                	shr    %cl,%edx
  801b1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b23:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b26:	d3 e6                	shl    %cl,%esi
  801b28:	89 c1                	mov    %eax,%ecx
  801b2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b2d:	89 fe                	mov    %edi,%esi
  801b2f:	d3 ee                	shr    %cl,%esi
  801b31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b3b:	d3 e7                	shl    %cl,%edi
  801b3d:	89 c1                	mov    %eax,%ecx
  801b3f:	d3 ea                	shr    %cl,%edx
  801b41:	09 d7                	or     %edx,%edi
  801b43:	89 f2                	mov    %esi,%edx
  801b45:	89 f8                	mov    %edi,%eax
  801b47:	f7 75 ec             	divl   -0x14(%ebp)
  801b4a:	89 d6                	mov    %edx,%esi
  801b4c:	89 c7                	mov    %eax,%edi
  801b4e:	f7 65 e8             	mull   -0x18(%ebp)
  801b51:	39 d6                	cmp    %edx,%esi
  801b53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b56:	72 30                	jb     801b88 <__udivdi3+0x118>
  801b58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b5f:	d3 e2                	shl    %cl,%edx
  801b61:	39 c2                	cmp    %eax,%edx
  801b63:	73 05                	jae    801b6a <__udivdi3+0xfa>
  801b65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b68:	74 1e                	je     801b88 <__udivdi3+0x118>
  801b6a:	89 f9                	mov    %edi,%ecx
  801b6c:	31 ff                	xor    %edi,%edi
  801b6e:	e9 71 ff ff ff       	jmp    801ae4 <__udivdi3+0x74>
  801b73:	90                   	nop
  801b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b78:	31 ff                	xor    %edi,%edi
  801b7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b7f:	e9 60 ff ff ff       	jmp    801ae4 <__udivdi3+0x74>
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801b8b:	31 ff                	xor    %edi,%edi
  801b8d:	89 c8                	mov    %ecx,%eax
  801b8f:	89 fa                	mov    %edi,%edx
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
	...

00801ba0 <__umoddi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	83 ec 20             	sub    $0x20,%esp
  801ba8:	8b 55 14             	mov    0x14(%ebp),%edx
  801bab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bae:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bb4:	85 d2                	test   %edx,%edx
  801bb6:	89 c8                	mov    %ecx,%eax
  801bb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bbb:	75 13                	jne    801bd0 <__umoddi3+0x30>
  801bbd:	39 f7                	cmp    %esi,%edi
  801bbf:	76 3f                	jbe    801c00 <__umoddi3+0x60>
  801bc1:	89 f2                	mov    %esi,%edx
  801bc3:	f7 f7                	div    %edi
  801bc5:	89 d0                	mov    %edx,%eax
  801bc7:	31 d2                	xor    %edx,%edx
  801bc9:	83 c4 20             	add    $0x20,%esp
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    
  801bd0:	39 f2                	cmp    %esi,%edx
  801bd2:	77 4c                	ja     801c20 <__umoddi3+0x80>
  801bd4:	0f bd ca             	bsr    %edx,%ecx
  801bd7:	83 f1 1f             	xor    $0x1f,%ecx
  801bda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bdd:	75 51                	jne    801c30 <__umoddi3+0x90>
  801bdf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801be2:	0f 87 e0 00 00 00    	ja     801cc8 <__umoddi3+0x128>
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	29 f8                	sub    %edi,%eax
  801bed:	19 d6                	sbb    %edx,%esi
  801bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	89 f2                	mov    %esi,%edx
  801bf7:	83 c4 20             	add    $0x20,%esp
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    
  801bfe:	66 90                	xchg   %ax,%ax
  801c00:	85 ff                	test   %edi,%edi
  801c02:	75 0b                	jne    801c0f <__umoddi3+0x6f>
  801c04:	b8 01 00 00 00       	mov    $0x1,%eax
  801c09:	31 d2                	xor    %edx,%edx
  801c0b:	f7 f7                	div    %edi
  801c0d:	89 c7                	mov    %eax,%edi
  801c0f:	89 f0                	mov    %esi,%eax
  801c11:	31 d2                	xor    %edx,%edx
  801c13:	f7 f7                	div    %edi
  801c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c18:	f7 f7                	div    %edi
  801c1a:	eb a9                	jmp    801bc5 <__umoddi3+0x25>
  801c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 c8                	mov    %ecx,%eax
  801c22:	89 f2                	mov    %esi,%edx
  801c24:	83 c4 20             	add    $0x20,%esp
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    
  801c2b:	90                   	nop
  801c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c34:	d3 e2                	shl    %cl,%edx
  801c36:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c39:	ba 20 00 00 00       	mov    $0x20,%edx
  801c3e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c41:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c44:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	d3 ea                	shr    %cl,%edx
  801c4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c50:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c53:	d3 e7                	shl    %cl,%edi
  801c55:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c59:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c5c:	89 f2                	mov    %esi,%edx
  801c5e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c61:	89 c7                	mov    %eax,%edi
  801c63:	d3 ea                	shr    %cl,%edx
  801c65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c6c:	89 c2                	mov    %eax,%edx
  801c6e:	d3 e6                	shl    %cl,%esi
  801c70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c74:	d3 ea                	shr    %cl,%edx
  801c76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c7a:	09 d6                	or     %edx,%esi
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c81:	d3 e7                	shl    %cl,%edi
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	f7 75 f4             	divl   -0xc(%ebp)
  801c88:	89 d6                	mov    %edx,%esi
  801c8a:	f7 65 e8             	mull   -0x18(%ebp)
  801c8d:	39 d6                	cmp    %edx,%esi
  801c8f:	72 2b                	jb     801cbc <__umoddi3+0x11c>
  801c91:	39 c7                	cmp    %eax,%edi
  801c93:	72 23                	jb     801cb8 <__umoddi3+0x118>
  801c95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c99:	29 c7                	sub    %eax,%edi
  801c9b:	19 d6                	sbb    %edx,%esi
  801c9d:	89 f0                	mov    %esi,%eax
  801c9f:	89 f2                	mov    %esi,%edx
  801ca1:	d3 ef                	shr    %cl,%edi
  801ca3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ca7:	d3 e0                	shl    %cl,%eax
  801ca9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cad:	09 f8                	or     %edi,%eax
  801caf:	d3 ea                	shr    %cl,%edx
  801cb1:	83 c4 20             	add    $0x20,%esp
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	39 d6                	cmp    %edx,%esi
  801cba:	75 d9                	jne    801c95 <__umoddi3+0xf5>
  801cbc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801cbf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801cc2:	eb d1                	jmp    801c95 <__umoddi3+0xf5>
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	0f 82 18 ff ff ff    	jb     801be8 <__umoddi3+0x48>
  801cd0:	e9 1d ff ff ff       	jmp    801bf2 <__umoddi3+0x52>
