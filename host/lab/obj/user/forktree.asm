
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 5b 01 00 00       	call   80018c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 38             	sub    $0x38,%esp
  80003a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80003d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800043:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800047:	89 1c 24             	mov    %ebx,(%esp)
  80004a:	e8 b1 08 00 00       	call   800900 <strlen>
  80004f:	83 f8 02             	cmp    $0x2,%eax
  800052:	7f 7a                	jg     8000ce <forkchild+0x9a>
		return;

	cprintf("\nbeg forkchild\n");
  800054:	c7 04 24 60 21 80 00 	movl   $0x802160,(%esp)
  80005b:	e8 11 02 00 00       	call   800271 <cprintf>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800060:	89 f0                	mov    %esi,%eax
  800062:	0f be f0             	movsbl %al,%esi
  800065:	89 74 24 10          	mov    %esi,0x10(%esp)
  800069:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80006d:	c7 44 24 08 70 21 80 	movl   $0x802170,0x8(%esp)
  800074:	00 
  800075:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80007c:	00 
  80007d:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800080:	89 1c 24             	mov    %ebx,(%esp)
  800083:	e8 1a 08 00 00       	call   8008a2 <snprintf>
	cprintf("%x%c\n", nxt, branch);
  800088:	89 74 24 08          	mov    %esi,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 75 21 80 00 	movl   $0x802175,(%esp)
  800097:	e8 d5 01 00 00       	call   800271 <cprintf>
	cprintf("%s\n", nxt);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	c7 04 24 7b 21 80 00 	movl   $0x80217b,(%esp)
  8000a7:	e8 c5 01 00 00       	call   800271 <cprintf>
	cprintf("\nend forkchild\n");
  8000ac:	c7 04 24 7f 21 80 00 	movl   $0x80217f,(%esp)
  8000b3:	e8 b9 01 00 00       	call   800271 <cprintf>
	if (fork() == 0) {
  8000b8:	e8 69 10 00 00       	call   801126 <fork>
  8000bd:	85 c0                	test   %eax,%eax
  8000bf:	75 0d                	jne    8000ce <forkchild+0x9a>
		forktree(nxt);
  8000c1:	89 1c 24             	mov    %ebx,(%esp)
  8000c4:	e8 0f 00 00 00       	call   8000d8 <forktree>
		exit();
  8000c9:	e8 26 01 00 00       	call   8001f4 <exit>
	}
}
  8000ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000d1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000d4:	89 ec                	mov    %ebp,%esp
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <forktree>:

void
forktree(const char *cur)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 14             	sub    $0x14,%esp
	cprintf("\nbeg forktree\n");
  8000df:	c7 04 24 8f 21 80 00 	movl   $0x80218f,(%esp)
  8000e6:	e8 86 01 00 00       	call   800271 <cprintf>
	cprintf("%04x: I am '%x'\n", sys_getenvid(), cur);
  8000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ee:	e8 7e 0f 00 00       	call   801071 <sys_getenvid>
  8000f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fb:	c7 04 24 9e 21 80 00 	movl   $0x80219e,(%esp)
  800102:	e8 6a 01 00 00       	call   800271 <cprintf>
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	e8 62 0f 00 00       	call   801071 <sys_getenvid>
  80010f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	c7 04 24 af 21 80 00 	movl   $0x8021af,(%esp)
  80011e:	e8 4e 01 00 00       	call   800271 <cprintf>
	cprintf("%04x: I am '%x'\n", sys_getenvid(), &cur);
  800123:	e8 49 0f 00 00       	call   801071 <sys_getenvid>
  800128:	8d 55 08             	lea    0x8(%ebp),%edx
  80012b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80012f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800133:	c7 04 24 9e 21 80 00 	movl   $0x80219e,(%esp)
  80013a:	e8 32 01 00 00       	call   800271 <cprintf>
	cprintf("\nend forktree\n");
  80013f:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  800146:	e8 26 01 00 00       	call   800271 <cprintf>

	forkchild(cur, '0');
  80014b:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800152:	00 
  800153:	8b 45 08             	mov    0x8(%ebp),%eax
  800156:	89 04 24             	mov    %eax,(%esp)
  800159:	e8 d6 fe ff ff       	call   800034 <forkchild>
	forkchild(cur, '1');
  80015e:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800165:	00 
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 c3 fe ff ff       	call   800034 <forkchild>
}
  800171:	83 c4 14             	add    $0x14,%esp
  800174:	5b                   	pop    %ebx
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <umain>:

void
umain(void)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  80017d:	c7 04 24 bf 21 80 00 	movl   $0x8021bf,(%esp)
  800184:	e8 4f ff ff ff       	call   8000d8 <forktree>
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    
	...

0080018c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 18             	sub    $0x18,%esp
  800192:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800195:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800198:	8b 75 08             	mov    0x8(%ebp),%esi
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80019e:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  8001a5:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  8001a8:	e8 c4 0e 00 00       	call   801071 <sys_getenvid>
  8001ad:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ba:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bf:	85 f6                	test   %esi,%esi
  8001c1:	7e 07                	jle    8001ca <libmain+0x3e>
		binaryname = argv[0];
  8001c3:	8b 03                	mov    (%ebx),%eax
  8001c5:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  8001ca:	c7 04 24 cf 21 80 00 	movl   $0x8021cf,(%esp)
  8001d1:	e8 9b 00 00 00       	call   800271 <cprintf>
	umain(argc, argv);
  8001d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001da:	89 34 24             	mov    %esi,(%esp)
  8001dd:	e8 95 ff ff ff       	call   800177 <umain>

	// exit gracefully
	exit();
  8001e2:	e8 0d 00 00 00       	call   8001f4 <exit>
}
  8001e7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001ea:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001ed:	89 ec                	mov    %ebp,%esp
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
  8001f1:	00 00                	add    %al,(%eax)
	...

008001f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001fa:	e8 6c 17 00 00       	call   80196b <close_all>
	sys_env_destroy(0);
  8001ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800206:	e8 9a 0e 00 00       	call   8010a5 <sys_env_destroy>
}
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    
  80020d:	00 00                	add    %al,(%eax)
	...

00800210 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800219:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800220:	00 00 00 
	b.cnt = 0;
  800223:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	c7 04 24 8b 02 80 00 	movl   $0x80028b,(%esp)
  80024c:	e8 cc 01 00 00       	call   80041d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800251:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 d7 0a 00 00       	call   800d40 <sys_cputs>

	return b.cnt;
}
  800269:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800277:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80027a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	e8 87 ff ff ff       	call   800210 <vcprintf>
	va_end(ap);

	return cnt;
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	53                   	push   %ebx
  80028f:	83 ec 14             	sub    $0x14,%esp
  800292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800295:	8b 03                	mov    (%ebx),%eax
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029e:	83 c0 01             	add    $0x1,%eax
  8002a1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a8:	75 19                	jne    8002c3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002aa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b1:	00 
  8002b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	e8 83 0a 00 00       	call   800d40 <sys_cputs>
		b->idx = 0;
  8002bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	83 c4 14             	add    $0x14,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fb:	39 d1                	cmp    %edx,%ecx
  8002fd:	72 15                	jb     800314 <printnum+0x44>
  8002ff:	77 07                	ja     800308 <printnum+0x38>
  800301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800304:	39 d0                	cmp    %edx,%eax
  800306:	76 0c                	jbe    800314 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	83 eb 01             	sub    $0x1,%ebx
  80030b:	85 db                	test   %ebx,%ebx
  80030d:	8d 76 00             	lea    0x0(%esi),%esi
  800310:	7f 61                	jg     800373 <printnum+0xa3>
  800312:	eb 70                	jmp    800384 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800327:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80032b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80032e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800331:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800334:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033f:	00 
  800340:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	e8 9e 1b 00 00       	call   801ef0 <__udivdi3>
  800352:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800355:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	89 54 24 04          	mov    %edx,0x4(%esp)
  800367:	89 f2                	mov    %esi,%edx
  800369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036c:	e8 5f ff ff ff       	call   8002d0 <printnum>
  800371:	eb 11                	jmp    800384 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800373:	89 74 24 04          	mov    %esi,0x4(%esp)
  800377:	89 3c 24             	mov    %edi,(%esp)
  80037a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f ef                	jg     800373 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	89 74 24 04          	mov    %esi,0x4(%esp)
  800388:	8b 74 24 04          	mov    0x4(%esp),%esi
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039a:	00 
  80039b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80039e:	89 14 24             	mov    %edx,(%esp)
  8003a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003a8:	e8 73 1c 00 00       	call   802020 <__umoddi3>
  8003ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b1:	0f be 80 f8 21 80 00 	movsbl 0x8021f8(%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003be:	83 c4 4c             	add    $0x4c,%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c9:	83 fa 01             	cmp    $0x1,%edx
  8003cc:	7e 0e                	jle    8003dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	eb 22                	jmp    8003fe <getuint+0x38>
	else if (lflag)
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	74 10                	je     8003f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 0e                	jmp    8003fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800406:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	3b 50 04             	cmp    0x4(%eax),%edx
  80040f:	73 0a                	jae    80041b <sprintputch+0x1b>
		*b->buf++ = ch;
  800411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800414:	88 0a                	mov    %cl,(%edx)
  800416:	83 c2 01             	add    $0x1,%edx
  800419:	89 10                	mov    %edx,(%eax)
}
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	83 ec 5c             	sub    $0x5c,%esp
  800426:	8b 7d 08             	mov    0x8(%ebp),%edi
  800429:	8b 75 0c             	mov    0xc(%ebp),%esi
  80042c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800436:	eb 11                	jmp    800449 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800438:	85 c0                	test   %eax,%eax
  80043a:	0f 84 02 04 00 00    	je     800842 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800440:	89 74 24 04          	mov    %esi,0x4(%esp)
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 03             	movzbl (%ebx),%eax
  80044c:	83 c3 01             	add    $0x1,%ebx
  80044f:	83 f8 25             	cmp    $0x25,%eax
  800452:	75 e4                	jne    800438 <vprintfmt+0x1b>
  800454:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800458:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800466:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80046d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800472:	eb 06                	jmp    80047a <vprintfmt+0x5d>
  800474:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800478:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	0f b6 13             	movzbl (%ebx),%edx
  80047d:	0f b6 c2             	movzbl %dl,%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800483:	8d 43 01             	lea    0x1(%ebx),%eax
  800486:	83 ea 23             	sub    $0x23,%edx
  800489:	80 fa 55             	cmp    $0x55,%dl
  80048c:	0f 87 93 03 00 00    	ja     800825 <vprintfmt+0x408>
  800492:	0f b6 d2             	movzbl %dl,%edx
  800495:	ff 24 95 40 23 80 00 	jmp    *0x802340(,%edx,4)
  80049c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a0:	eb d6                	jmp    800478 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a5:	83 ea 30             	sub    $0x30,%edx
  8004a8:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8004ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004b1:	83 fb 09             	cmp    $0x9,%ebx
  8004b4:	77 4c                	ja     800502 <vprintfmt+0xe5>
  8004b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004cc:	83 fb 09             	cmp    $0x9,%ebx
  8004cf:	76 eb                	jbe    8004bc <vprintfmt+0x9f>
  8004d1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d7:	eb 29                	jmp    800502 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004e2:	8b 12                	mov    (%edx),%edx
  8004e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8004e7:	eb 19                	jmp    800502 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8004e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ec:	c1 fa 1f             	sar    $0x1f,%edx
  8004ef:	f7 d2                	not    %edx
  8004f1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8004f4:	eb 82                	jmp    800478 <vprintfmt+0x5b>
  8004f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004fd:	e9 76 ff ff ff       	jmp    800478 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800502:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800506:	0f 89 6c ff ff ff    	jns    800478 <vprintfmt+0x5b>
  80050c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80050f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800512:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800515:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800518:	e9 5b ff ff ff       	jmp    800478 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800520:	e9 53 ff ff ff       	jmp    800478 <vprintfmt+0x5b>
  800525:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	89 74 24 04          	mov    %esi,0x4(%esp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	ff d7                	call   *%edi
  80053c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80053f:	e9 05 ff ff ff       	jmp    800449 <vprintfmt+0x2c>
  800544:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 c2                	mov    %eax,%edx
  800554:	c1 fa 1f             	sar    $0x1f,%edx
  800557:	31 d0                	xor    %edx,%eax
  800559:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80055b:	83 f8 0f             	cmp    $0xf,%eax
  80055e:	7f 0b                	jg     80056b <vprintfmt+0x14e>
  800560:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  800567:	85 d2                	test   %edx,%edx
  800569:	75 20                	jne    80058b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80056b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056f:	c7 44 24 08 09 22 80 	movl   $0x802209,0x8(%esp)
  800576:	00 
  800577:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057b:	89 3c 24             	mov    %edi,(%esp)
  80057e:	e8 47 03 00 00       	call   8008ca <printfmt>
  800583:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800586:	e9 be fe ff ff       	jmp    800449 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80058b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058f:	c7 44 24 08 12 22 80 	movl   $0x802212,0x8(%esp)
  800596:	00 
  800597:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059b:	89 3c 24             	mov    %edi,(%esp)
  80059e:	e8 27 03 00 00       	call   8008ca <printfmt>
  8005a3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005a6:	e9 9e fe ff ff       	jmp    800449 <vprintfmt+0x2c>
  8005ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	75 07                	jne    8005d2 <vprintfmt+0x1b5>
  8005cb:	c7 45 e0 15 22 80 00 	movl   $0x802215,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005d2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005d6:	7e 06                	jle    8005de <vprintfmt+0x1c1>
  8005d8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005dc:	75 13                	jne    8005f1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e1:	0f be 02             	movsbl (%edx),%eax
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	0f 85 99 00 00 00    	jne    800685 <vprintfmt+0x268>
  8005ec:	e9 86 00 00 00       	jmp    800677 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f8:	89 0c 24             	mov    %ecx,(%esp)
  8005fb:	e8 1b 03 00 00       	call   80091b <strnlen>
  800600:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800603:	29 c2                	sub    %eax,%edx
  800605:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800608:	85 d2                	test   %edx,%edx
  80060a:	7e d2                	jle    8005de <vprintfmt+0x1c1>
					putch(padc, putdat);
  80060c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800610:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800613:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800616:	89 d3                	mov    %edx,%ebx
  800618:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 eb 01             	sub    $0x1,%ebx
  800627:	85 db                	test   %ebx,%ebx
  800629:	7f ed                	jg     800618 <vprintfmt+0x1fb>
  80062b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80062e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800635:	eb a7                	jmp    8005de <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800637:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063b:	74 18                	je     800655 <vprintfmt+0x238>
  80063d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800640:	83 fa 5e             	cmp    $0x5e,%edx
  800643:	76 10                	jbe    800655 <vprintfmt+0x238>
					putch('?', putdat);
  800645:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800649:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800650:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800653:	eb 0a                	jmp    80065f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800655:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800663:	0f be 03             	movsbl (%ebx),%eax
  800666:	85 c0                	test   %eax,%eax
  800668:	74 05                	je     80066f <vprintfmt+0x252>
  80066a:	83 c3 01             	add    $0x1,%ebx
  80066d:	eb 29                	jmp    800698 <vprintfmt+0x27b>
  80066f:	89 fe                	mov    %edi,%esi
  800671:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800674:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800677:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067b:	7f 2e                	jg     8006ab <vprintfmt+0x28e>
  80067d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800680:	e9 c4 fd ff ff       	jmp    800449 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800685:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800688:	83 c2 01             	add    $0x1,%edx
  80068b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80068e:	89 f7                	mov    %esi,%edi
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800696:	89 d3                	mov    %edx,%ebx
  800698:	85 f6                	test   %esi,%esi
  80069a:	78 9b                	js     800637 <vprintfmt+0x21a>
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	79 96                	jns    800637 <vprintfmt+0x21a>
  8006a1:	89 fe                	mov    %edi,%esi
  8006a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006a6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006a9:	eb cc                	jmp    800677 <vprintfmt+0x25a>
  8006ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006be:	83 eb 01             	sub    $0x1,%ebx
  8006c1:	85 db                	test   %ebx,%ebx
  8006c3:	7f ec                	jg     8006b1 <vprintfmt+0x294>
  8006c5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006c8:	e9 7c fd ff ff       	jmp    800449 <vprintfmt+0x2c>
  8006cd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7e 16                	jle    8006eb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 08             	lea    0x8(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 10                	mov    (%eax),%edx
  8006e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e9:	eb 32                	jmp    80071d <vprintfmt+0x300>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	74 18                	je     800707 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fd:	89 c1                	mov    %eax,%ecx
  8006ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800702:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800705:	eb 16                	jmp    80071d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800715:	89 c2                	mov    %eax,%edx
  800717:	c1 fa 1f             	sar    $0x1f,%edx
  80071a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800720:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800723:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800728:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072c:	0f 89 b1 00 00 00    	jns    8007e3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800732:	89 74 24 04          	mov    %esi,0x4(%esp)
  800736:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80073d:	ff d7                	call   *%edi
				num = -(long long) num;
  80073f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800742:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800745:	f7 d8                	neg    %eax
  800747:	83 d2 00             	adc    $0x0,%edx
  80074a:	f7 da                	neg    %edx
  80074c:	e9 92 00 00 00       	jmp    8007e3 <vprintfmt+0x3c6>
  800751:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800754:	89 ca                	mov    %ecx,%edx
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 68 fc ff ff       	call   8003c6 <getuint>
  80075e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800763:	eb 7e                	jmp    8007e3 <vprintfmt+0x3c6>
  800765:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800768:	89 ca                	mov    %ecx,%edx
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 54 fc ff ff       	call   8003c6 <getuint>
			if ((long long) num < 0) {
  800772:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800775:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800778:	bb 08 00 00 00       	mov    $0x8,%ebx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	79 62                	jns    8007e3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800781:	89 74 24 04          	mov    %esi,0x4(%esp)
  800785:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80078c:	ff d7                	call   *%edi
				num = -(long long) num;
  80078e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800791:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800794:	f7 d8                	neg    %eax
  800796:	83 d2 00             	adc    $0x0,%edx
  800799:	f7 da                	neg    %edx
  80079b:	eb 46                	jmp    8007e3 <vprintfmt+0x3c6>
  80079d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8007a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ab:	ff d7                	call   *%edi
			putch('x', putdat);
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ca:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cf:	eb 12                	jmp    8007e3 <vprintfmt+0x3c6>
  8007d1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d4:	89 ca                	mov    %ecx,%edx
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d9:	e8 e8 fb ff ff       	call   8003c6 <getuint>
  8007de:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007e7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	89 f8                	mov    %edi,%eax
  800801:	e8 ca fa ff ff       	call   8002d0 <printnum>
  800806:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800809:	e9 3b fc ff ff       	jmp    800449 <vprintfmt+0x2c>
  80080e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800811:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800814:	89 74 24 04          	mov    %esi,0x4(%esp)
  800818:	89 14 24             	mov    %edx,(%esp)
  80081b:	ff d7                	call   *%edi
  80081d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800820:	e9 24 fc ff ff       	jmp    800449 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800825:	89 74 24 04          	mov    %esi,0x4(%esp)
  800829:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800830:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800832:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800835:	80 38 25             	cmpb   $0x25,(%eax)
  800838:	0f 84 0b fc ff ff    	je     800449 <vprintfmt+0x2c>
  80083e:	89 c3                	mov    %eax,%ebx
  800840:	eb f0                	jmp    800832 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800842:	83 c4 5c             	add    $0x5c,%esp
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5f                   	pop    %edi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 28             	sub    $0x28,%esp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800856:	85 c0                	test   %eax,%eax
  800858:	74 04                	je     80085e <vsnprintf+0x14>
  80085a:	85 d2                	test   %edx,%edx
  80085c:	7f 07                	jg     800865 <vsnprintf+0x1b>
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800863:	eb 3b                	jmp    8008a0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800865:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800868:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80086c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80086f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087d:	8b 45 10             	mov    0x10(%ebp),%eax
  800880:	89 44 24 08          	mov    %eax,0x8(%esp)
  800884:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088b:	c7 04 24 00 04 80 00 	movl   $0x800400,(%esp)
  800892:	e8 86 fb ff ff       	call   80041d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800897:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008af:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	e8 82 ff ff ff       	call   80084a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008d0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	e8 2d fb ff ff       	call   80041d <vprintfmt>
	va_end(ap);
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 09                	je     800919 <strlen+0x19>
		n++;
  800910:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800913:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800917:	75 f7                	jne    800910 <strlen+0x10>
		n++;
	return n;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 19                	je     800942 <strnlen+0x27>
  800929:	80 3b 00             	cmpb   $0x0,(%ebx)
  80092c:	74 14                	je     800942 <strnlen+0x27>
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800933:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800936:	39 c8                	cmp    %ecx,%eax
  800938:	74 0d                	je     800947 <strnlen+0x2c>
  80093a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80093e:	75 f3                	jne    800933 <strnlen+0x18>
  800940:	eb 05                	jmp    800947 <strnlen+0x2c>
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800959:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800960:	83 c2 01             	add    $0x1,%edx
  800963:	84 c9                	test   %cl,%cl
  800965:	75 f2                	jne    800959 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	85 f6                	test   %esi,%esi
  80097a:	74 18                	je     800994 <strncpy+0x2a>
  80097c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800981:	0f b6 1a             	movzbl (%edx),%ebx
  800984:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800987:	80 3a 01             	cmpb   $0x1,(%edx)
  80098a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098d:	83 c1 01             	add    $0x1,%ecx
  800990:	39 ce                	cmp    %ecx,%esi
  800992:	77 ed                	ja     800981 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a6:	89 f0                	mov    %esi,%eax
  8009a8:	85 c9                	test   %ecx,%ecx
  8009aa:	74 27                	je     8009d3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009ac:	83 e9 01             	sub    $0x1,%ecx
  8009af:	74 1d                	je     8009ce <strlcpy+0x36>
  8009b1:	0f b6 1a             	movzbl (%edx),%ebx
  8009b4:	84 db                	test   %bl,%bl
  8009b6:	74 16                	je     8009ce <strlcpy+0x36>
			*dst++ = *src++;
  8009b8:	88 18                	mov    %bl,(%eax)
  8009ba:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009bd:	83 e9 01             	sub    $0x1,%ecx
  8009c0:	74 0e                	je     8009d0 <strlcpy+0x38>
			*dst++ = *src++;
  8009c2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c5:	0f b6 1a             	movzbl (%edx),%ebx
  8009c8:	84 db                	test   %bl,%bl
  8009ca:	75 ec                	jne    8009b8 <strlcpy+0x20>
  8009cc:	eb 02                	jmp    8009d0 <strlcpy+0x38>
  8009ce:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009d0:	c6 00 00             	movb   $0x0,(%eax)
  8009d3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009e2:	0f b6 01             	movzbl (%ecx),%eax
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 15                	je     8009fe <strcmp+0x25>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	75 11                	jne    8009fe <strcmp+0x25>
		p++, q++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	84 c0                	test   %al,%al
  8009f8:	74 04                	je     8009fe <strcmp+0x25>
  8009fa:	3a 02                	cmp    (%edx),%al
  8009fc:	74 ef                	je     8009ed <strcmp+0x14>
  8009fe:	0f b6 c0             	movzbl %al,%eax
  800a01:	0f b6 12             	movzbl (%edx),%edx
  800a04:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	53                   	push   %ebx
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a12:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a15:	85 c0                	test   %eax,%eax
  800a17:	74 23                	je     800a3c <strncmp+0x34>
  800a19:	0f b6 1a             	movzbl (%edx),%ebx
  800a1c:	84 db                	test   %bl,%bl
  800a1e:	74 24                	je     800a44 <strncmp+0x3c>
  800a20:	3a 19                	cmp    (%ecx),%bl
  800a22:	75 20                	jne    800a44 <strncmp+0x3c>
  800a24:	83 e8 01             	sub    $0x1,%eax
  800a27:	74 13                	je     800a3c <strncmp+0x34>
		n--, p++, q++;
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2f:	0f b6 1a             	movzbl (%edx),%ebx
  800a32:	84 db                	test   %bl,%bl
  800a34:	74 0e                	je     800a44 <strncmp+0x3c>
  800a36:	3a 19                	cmp    (%ecx),%bl
  800a38:	74 ea                	je     800a24 <strncmp+0x1c>
  800a3a:	eb 08                	jmp    800a44 <strncmp+0x3c>
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a41:	5b                   	pop    %ebx
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a44:	0f b6 02             	movzbl (%edx),%eax
  800a47:	0f b6 11             	movzbl (%ecx),%edx
  800a4a:	29 d0                	sub    %edx,%eax
  800a4c:	eb f3                	jmp    800a41 <strncmp+0x39>

00800a4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	74 15                	je     800a74 <strchr+0x26>
		if (*s == c)
  800a5f:	38 ca                	cmp    %cl,%dl
  800a61:	75 07                	jne    800a6a <strchr+0x1c>
  800a63:	eb 14                	jmp    800a79 <strchr+0x2b>
  800a65:	38 ca                	cmp    %cl,%dl
  800a67:	90                   	nop
  800a68:	74 0f                	je     800a79 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 f1                	jne    800a65 <strchr+0x17>
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	0f b6 10             	movzbl (%eax),%edx
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	74 18                	je     800aa4 <strfind+0x29>
		if (*s == c)
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	75 0a                	jne    800a9a <strfind+0x1f>
  800a90:	eb 12                	jmp    800aa4 <strfind+0x29>
  800a92:	38 ca                	cmp    %cl,%dl
  800a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a98:	74 0a                	je     800aa4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 ee                	jne    800a92 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	89 1c 24             	mov    %ebx,(%esp)
  800aaf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	74 30                	je     800af4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 25                	jne    800af1 <memset+0x4b>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 20                	jne    800af1 <memset+0x4b>
		c &= 0xFF;
  800ad1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	c1 e3 08             	shl    $0x8,%ebx
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	c1 e6 18             	shl    $0x18,%esi
  800ade:	89 d0                	mov    %edx,%eax
  800ae0:	c1 e0 10             	shl    $0x10,%eax
  800ae3:	09 f0                	or     %esi,%eax
  800ae5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ae7:	09 d8                	or     %ebx,%eax
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
  800aec:	fc                   	cld    
  800aed:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aef:	eb 03                	jmp    800af4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af1:	fc                   	cld    
  800af2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af4:	89 f8                	mov    %edi,%eax
  800af6:	8b 1c 24             	mov    (%esp),%ebx
  800af9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800afd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b01:	89 ec                	mov    %ebp,%esp
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	89 34 24             	mov    %esi,(%esp)
  800b0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b18:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b1b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b1d:	39 c6                	cmp    %eax,%esi
  800b1f:	73 35                	jae    800b56 <memmove+0x51>
  800b21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b24:	39 d0                	cmp    %edx,%eax
  800b26:	73 2e                	jae    800b56 <memmove+0x51>
		s += n;
		d += n;
  800b28:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2a:	f6 c2 03             	test   $0x3,%dl
  800b2d:	75 1b                	jne    800b4a <memmove+0x45>
  800b2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b35:	75 13                	jne    800b4a <memmove+0x45>
  800b37:	f6 c1 03             	test   $0x3,%cl
  800b3a:	75 0e                	jne    800b4a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b3c:	83 ef 04             	sub    $0x4,%edi
  800b3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b42:	c1 e9 02             	shr    $0x2,%ecx
  800b45:	fd                   	std    
  800b46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b48:	eb 09                	jmp    800b53 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4a:	83 ef 01             	sub    $0x1,%edi
  800b4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b50:	fd                   	std    
  800b51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b53:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b54:	eb 20                	jmp    800b76 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5c:	75 15                	jne    800b73 <memmove+0x6e>
  800b5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b64:	75 0d                	jne    800b73 <memmove+0x6e>
  800b66:	f6 c1 03             	test   $0x3,%cl
  800b69:	75 08                	jne    800b73 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b6b:	c1 e9 02             	shr    $0x2,%ecx
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b71:	eb 03                	jmp    800b76 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	fc                   	cld    
  800b74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b76:	8b 34 24             	mov    (%esp),%esi
  800b79:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b7d:	89 ec                	mov    %ebp,%esp
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b87:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	89 04 24             	mov    %eax,(%esp)
  800b9b:	e8 65 ff ff ff       	call   800b05 <memmove>
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb1:	85 c9                	test   %ecx,%ecx
  800bb3:	74 36                	je     800beb <memcmp+0x49>
		if (*s1 != *s2)
  800bb5:	0f b6 06             	movzbl (%esi),%eax
  800bb8:	0f b6 1f             	movzbl (%edi),%ebx
  800bbb:	38 d8                	cmp    %bl,%al
  800bbd:	74 20                	je     800bdf <memcmp+0x3d>
  800bbf:	eb 14                	jmp    800bd5 <memcmp+0x33>
  800bc1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bc6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bcb:	83 c2 01             	add    $0x1,%edx
  800bce:	83 e9 01             	sub    $0x1,%ecx
  800bd1:	38 d8                	cmp    %bl,%al
  800bd3:	74 12                	je     800be7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800bd5:	0f b6 c0             	movzbl %al,%eax
  800bd8:	0f b6 db             	movzbl %bl,%ebx
  800bdb:	29 d8                	sub    %ebx,%eax
  800bdd:	eb 11                	jmp    800bf0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdf:	83 e9 01             	sub    $0x1,%ecx
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	85 c9                	test   %ecx,%ecx
  800be9:	75 d6                	jne    800bc1 <memcmp+0x1f>
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bfb:	89 c2                	mov    %eax,%edx
  800bfd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c00:	39 d0                	cmp    %edx,%eax
  800c02:	73 15                	jae    800c19 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c08:	38 08                	cmp    %cl,(%eax)
  800c0a:	75 06                	jne    800c12 <memfind+0x1d>
  800c0c:	eb 0b                	jmp    800c19 <memfind+0x24>
  800c0e:	38 08                	cmp    %cl,(%eax)
  800c10:	74 07                	je     800c19 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c12:	83 c0 01             	add    $0x1,%eax
  800c15:	39 c2                	cmp    %eax,%edx
  800c17:	77 f5                	ja     800c0e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 04             	sub    $0x4,%esp
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2a:	0f b6 02             	movzbl (%edx),%eax
  800c2d:	3c 20                	cmp    $0x20,%al
  800c2f:	74 04                	je     800c35 <strtol+0x1a>
  800c31:	3c 09                	cmp    $0x9,%al
  800c33:	75 0e                	jne    800c43 <strtol+0x28>
		s++;
  800c35:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c38:	0f b6 02             	movzbl (%edx),%eax
  800c3b:	3c 20                	cmp    $0x20,%al
  800c3d:	74 f6                	je     800c35 <strtol+0x1a>
  800c3f:	3c 09                	cmp    $0x9,%al
  800c41:	74 f2                	je     800c35 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c43:	3c 2b                	cmp    $0x2b,%al
  800c45:	75 0c                	jne    800c53 <strtol+0x38>
		s++;
  800c47:	83 c2 01             	add    $0x1,%edx
  800c4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c51:	eb 15                	jmp    800c68 <strtol+0x4d>
	else if (*s == '-')
  800c53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c5a:	3c 2d                	cmp    $0x2d,%al
  800c5c:	75 0a                	jne    800c68 <strtol+0x4d>
		s++, neg = 1;
  800c5e:	83 c2 01             	add    $0x1,%edx
  800c61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c68:	85 db                	test   %ebx,%ebx
  800c6a:	0f 94 c0             	sete   %al
  800c6d:	74 05                	je     800c74 <strtol+0x59>
  800c6f:	83 fb 10             	cmp    $0x10,%ebx
  800c72:	75 18                	jne    800c8c <strtol+0x71>
  800c74:	80 3a 30             	cmpb   $0x30,(%edx)
  800c77:	75 13                	jne    800c8c <strtol+0x71>
  800c79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7d:	8d 76 00             	lea    0x0(%esi),%esi
  800c80:	75 0a                	jne    800c8c <strtol+0x71>
		s += 2, base = 16;
  800c82:	83 c2 02             	add    $0x2,%edx
  800c85:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8a:	eb 15                	jmp    800ca1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8c:	84 c0                	test   %al,%al
  800c8e:	66 90                	xchg   %ax,%ax
  800c90:	74 0f                	je     800ca1 <strtol+0x86>
  800c92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c97:	80 3a 30             	cmpb   $0x30,(%edx)
  800c9a:	75 05                	jne    800ca1 <strtol+0x86>
		s++, base = 8;
  800c9c:	83 c2 01             	add    $0x1,%edx
  800c9f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca8:	0f b6 0a             	movzbl (%edx),%ecx
  800cab:	89 cf                	mov    %ecx,%edi
  800cad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cb0:	80 fb 09             	cmp    $0x9,%bl
  800cb3:	77 08                	ja     800cbd <strtol+0xa2>
			dig = *s - '0';
  800cb5:	0f be c9             	movsbl %cl,%ecx
  800cb8:	83 e9 30             	sub    $0x30,%ecx
  800cbb:	eb 1e                	jmp    800cdb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cbd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cc0:	80 fb 19             	cmp    $0x19,%bl
  800cc3:	77 08                	ja     800ccd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cc5:	0f be c9             	movsbl %cl,%ecx
  800cc8:	83 e9 57             	sub    $0x57,%ecx
  800ccb:	eb 0e                	jmp    800cdb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ccd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 15                	ja     800cea <strtol+0xcf>
			dig = *s - 'A' + 10;
  800cd5:	0f be c9             	movsbl %cl,%ecx
  800cd8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cdb:	39 f1                	cmp    %esi,%ecx
  800cdd:	7d 0b                	jge    800cea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cdf:	83 c2 01             	add    $0x1,%edx
  800ce2:	0f af c6             	imul   %esi,%eax
  800ce5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ce8:	eb be                	jmp    800ca8 <strtol+0x8d>
  800cea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf0:	74 05                	je     800cf7 <strtol+0xdc>
		*endptr = (char *) s;
  800cf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cf5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cf7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cfb:	74 04                	je     800d01 <strtol+0xe6>
  800cfd:	89 c8                	mov    %ecx,%eax
  800cff:	f7 d8                	neg    %eax
}
  800d01:	83 c4 04             	add    $0x4,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
  800d09:	00 00                	add    %al,(%eax)
	...

00800d0c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	89 1c 24             	mov    %ebx,(%esp)
  800d15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d19:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	89 d1                	mov    %edx,%ecx
  800d29:	89 d3                	mov    %edx,%ebx
  800d2b:	89 d7                	mov    %edx,%edi
  800d2d:	89 d6                	mov    %edx,%esi
  800d2f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d31:	8b 1c 24             	mov    (%esp),%ebx
  800d34:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d38:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d3c:	89 ec                	mov    %ebp,%esp
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	89 1c 24             	mov    %ebx,(%esp)
  800d49:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d4d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 c3                	mov    %eax,%ebx
  800d5e:	89 c7                	mov    %eax,%edi
  800d60:	89 c6                	mov    %eax,%esi
  800d62:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d64:	8b 1c 24             	mov    (%esp),%ebx
  800d67:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d6b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d6f:	89 ec                	mov    %ebp,%esp
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 38             	sub    $0x38,%esp
  800d79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	89 cb                	mov    %ecx,%ebx
  800d91:	89 cf                	mov    %ecx,%edi
  800d93:	89 ce                	mov    %ecx,%esi
  800d95:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 28                	jle    800dc3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800da6:	00 
  800da7:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800dae:	00 
  800daf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800db6:	00 
  800db7:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800dbe:	e8 49 0f 00 00       	call   801d0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcc:	89 ec                	mov    %ebp,%esp
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	89 1c 24             	mov    %ebx,(%esp)
  800dd9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ddd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	be 00 00 00 00       	mov    $0x0,%esi
  800de6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800deb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df9:	8b 1c 24             	mov    (%esp),%ebx
  800dfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e00:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e04:	89 ec                	mov    %ebp,%esp
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	83 ec 38             	sub    $0x38,%esp
  800e0e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e11:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e14:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 28                	jle    800e59 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e35:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800e44:	00 
  800e45:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e4c:	00 
  800e4d:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800e54:	e8 b3 0e 00 00       	call   801d0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e59:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e62:	89 ec                	mov    %ebp,%esp
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 38             	sub    $0x38,%esp
  800e6c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e72:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	89 df                	mov    %ebx,%edi
  800e87:	89 de                	mov    %ebx,%esi
  800e89:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7e 28                	jle    800eb7 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e93:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e9a:	00 
  800e9b:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800eaa:	00 
  800eab:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800eb2:	e8 55 0e 00 00       	call   801d0c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ebd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec0:	89 ec                	mov    %ebp,%esp
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 38             	sub    $0x38,%esp
  800eca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ecd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed8:	b8 08 00 00 00       	mov    $0x8,%eax
  800edd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	89 df                	mov    %ebx,%edi
  800ee5:	89 de                	mov    %ebx,%esi
  800ee7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 28                	jle    800f15 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800f00:	00 
  800f01:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f08:	00 
  800f09:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800f10:	e8 f7 0d 00 00       	call   801d0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f15:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f18:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1e:	89 ec                	mov    %ebp,%esp
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 38             	sub    $0x38,%esp
  800f28:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f36:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	89 df                	mov    %ebx,%edi
  800f43:	89 de                	mov    %ebx,%esi
  800f45:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	7e 28                	jle    800f73 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f56:	00 
  800f57:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800f6e:	e8 99 0d 00 00       	call   801d0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f73:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f76:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f79:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7c:	89 ec                	mov    %ebp,%esp
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 38             	sub    $0x38,%esp
  800f86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f94:	8b 75 18             	mov    0x18(%ebp),%esi
  800f97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	7e 28                	jle    800fd1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fad:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800fcc:	e8 3b 0d 00 00       	call   801d0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fd1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fda:	89 ec                	mov    %ebp,%esp
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 38             	sub    $0x38,%esp
  800fe4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fea:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fed:	be 00 00 00 00       	mov    $0x0,%esi
  800ff2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ff7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ffa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffd:	8b 55 08             	mov    0x8(%ebp),%edx
  801000:	89 f7                	mov    %esi,%edi
  801002:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	7e 28                	jle    801030 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801008:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801013:	00 
  801014:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  80101b:	00 
  80101c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801023:	00 
  801024:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  80102b:	e8 dc 0c 00 00       	call   801d0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801030:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801033:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801036:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801039:	89 ec                	mov    %ebp,%esp
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	89 1c 24             	mov    %ebx,(%esp)
  801046:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104e:	ba 00 00 00 00       	mov    $0x0,%edx
  801053:	b8 0b 00 00 00       	mov    $0xb,%eax
  801058:	89 d1                	mov    %edx,%ecx
  80105a:	89 d3                	mov    %edx,%ebx
  80105c:	89 d7                	mov    %edx,%edi
  80105e:	89 d6                	mov    %edx,%esi
  801060:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801062:	8b 1c 24             	mov    (%esp),%ebx
  801065:	8b 74 24 04          	mov    0x4(%esp),%esi
  801069:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80106d:	89 ec                	mov    %ebp,%esp
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	89 1c 24             	mov    %ebx,(%esp)
  80107a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	b8 02 00 00 00       	mov    $0x2,%eax
  80108c:	89 d1                	mov    %edx,%ecx
  80108e:	89 d3                	mov    %edx,%ebx
  801090:	89 d7                	mov    %edx,%edi
  801092:	89 d6                	mov    %edx,%esi
  801094:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801096:	8b 1c 24             	mov    (%esp),%ebx
  801099:	8b 74 24 04          	mov    0x4(%esp),%esi
  80109d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010a1:	89 ec                	mov    %ebp,%esp
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	83 ec 38             	sub    $0x38,%esp
  8010ab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010b1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	89 cb                	mov    %ecx,%ebx
  8010c3:	89 cf                	mov    %ecx,%edi
  8010c5:	89 ce                	mov    %ecx,%esi
  8010c7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	7e 28                	jle    8010f5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 08 ff 24 80 	movl   $0x8024ff,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  8010f0:	e8 17 0c 00 00       	call   801d0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010f5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010f8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010fe:	89 ec                	mov    %ebp,%esp
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    
	...

00801104 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 18             	sub    $0x18,%esp
        panic("sfork not implemented");
  80110a:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801121:	e8 e6 0b 00 00       	call   801d0c <_panic>

00801126 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	83 ec 3c             	sub    $0x3c,%esp
        // LAB 4: Your code here.
        //panic("fork not implemented");
        envid_t envid;
        uint8_t * addr;
        int r;
        set_pgfault_handler(pgfault);
  80112f:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  801136:	e8 35 0c 00 00       	call   801d70 <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80113b:	ba 07 00 00 00       	mov    $0x7,%edx
  801140:	89 d0                	mov    %edx,%eax
  801142:	cd 30                	int    $0x30
  801144:	89 45 d8             	mov    %eax,-0x28(%ebp)
        envid = sys_exofork();
        
	if (envid == 0) 
  801147:	85 c0                	test   %eax,%eax
  801149:	75 1c                	jne    801167 <fork+0x41>
	{
                env = &envs[ENVX(sys_getenvid())];
  80114b:	e8 21 ff ff ff       	call   801071 <sys_getenvid>
  801150:	25 ff 03 00 00       	and    $0x3ff,%eax
  801155:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115d:	a3 24 50 80 00       	mov    %eax,0x805024
                return 0;
  801162:	e9 07 02 00 00       	jmp    80136e <fork+0x248>
  801167:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80116e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801175:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
        }
	
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
	{
                if (vpd[i] & PTE_P) 
  80117c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80117f:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  801186:	a8 01                	test   $0x1,%al
  801188:	0f 84 20 01 00 00    	je     8012ae <fork+0x188>
  80118e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801191:	8b 45 dc             	mov    -0x24(%ebp),%eax
		{
                        for (j = 0; j * PGSIZE + i * PTSIZE < UTOP && j < NPTENTRIES; j++) 
  801194:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
  801199:	0f 87 0f 01 00 00    	ja     8012ae <fork+0x188>
  80119f:	89 c6                	mov    %eax,%esi
  8011a1:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				int ad = j*PGSIZE+i*PTSIZE;

                                if (ad == UXSTACKTOP - PGSIZE) 
  8011ac:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  8011b1:	0f 84 cd 00 00 00    	je     801284 <fork+0x15e>
                                        continue;


                                pte_t p = vpt[i * NPTENTRIES + j];
  8011b7:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax

                                if ((p & PTE_P) && (p & PTE_U))
  8011be:	83 e0 05             	and    $0x5,%eax
  8011c1:	83 f8 05             	cmp    $0x5,%eax
  8011c4:	0f 85 ba 00 00 00    	jne    801284 <fork+0x15e>
        void *va;
        pte_t pte;

        // LAB 4: Your code here.
        //panic("duppage not implemented");
        pte = vpt[pn];
  8011ca:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax
        va = (void *)(pn * PGSIZE);

        if ((pte & PTE_P) == 0 || (pte & PTE_U) == 0)
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	83 e2 05             	and    $0x5,%edx
  8011d6:	83 fa 05             	cmp    $0x5,%edx
  8011d9:	74 1c                	je     8011f7 <fork+0xd1>
                panic("invalid permissions\n");
  8011db:	c7 44 24 08 4b 25 80 	movl   $0x80254b,0x8(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  8011f2:	e8 15 0b 00 00       	call   801d0c <_panic>
        pte_t pte;

        // LAB 4: Your code here.
        //panic("duppage not implemented");
        pte = vpt[pn];
        va = (void *)(pn * PGSIZE);
  8011f7:	c1 e7 0c             	shl    $0xc,%edi

        if ((pte & PTE_P) == 0 || (pte & PTE_U) == 0)
                panic("invalid permissions\n");

        if ((pte & PTE_W) == 0 && (pte & PTE_COW) == 0) 
  8011fa:	a9 02 08 00 00       	test   $0x802,%eax
  8011ff:	75 2c                	jne    80122d <fork+0x107>
	{
		int err;
                err = sys_page_map(0, va, envid, va, PTE_P | PTE_U);
  801201:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801208:	00 
  801209:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80120d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801210:	89 44 24 08          	mov    %eax,0x8(%esp)
  801214:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121f:	e8 5c fd ff ff       	call   800f80 <sys_page_map>
                if (err < 0)
  801224:	85 c0                	test   %eax,%eax
  801226:	79 5c                	jns    801284 <fork+0x15e>
  801228:	e9 4c 01 00 00       	jmp    801379 <fork+0x253>
                        return err;
        }
        else 
	{
		int err = sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW);
  80122d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801234:	00 
  801235:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801239:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80123c:	89 54 24 08          	mov    %edx,0x8(%esp)
  801240:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801244:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124b:	e8 30 fd ff ff       	call   800f80 <sys_page_map>
                if (err < 0)
  801250:	85 c0                	test   %eax,%eax
  801252:	0f 88 21 01 00 00    	js     801379 <fork+0x253>
                        return err;
                err = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW);
  801258:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80125f:	00 
  801260:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801264:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80126b:	00 
  80126c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801270:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801277:	e8 04 fd ff ff       	call   800f80 <sys_page_map>

                if (err < 0)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	0f 88 f5 00 00 00    	js     801379 <fork+0x253>
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
	{
                if (vpd[i] & PTE_P) 
		{
                        for (j = 0; j * PGSIZE + i * PTSIZE < UTOP && j < NPTENTRIES; j++) 
  801284:	83 c3 01             	add    $0x1,%ebx
  801287:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80128a:	01 df                	add    %ebx,%edi
  80128c:	89 f0                	mov    %esi,%eax
  80128e:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
  801294:	0f 96 c1             	setbe  %cl
  801297:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  80129d:	0f 9e c2             	setle  %dl
  8012a0:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8012a6:	84 d1                	test   %dl,%cl
  8012a8:	0f 85 fe fe ff ff    	jne    8011ac <fork+0x86>
                env = &envs[ENVX(sys_getenvid())];
                return 0;
        }
	
        int i, j;
        for (i = 0; i * PTSIZE < UTOP; i++) 
  8012ae:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8012b2:	81 45 e4 00 04 00 00 	addl   $0x400,-0x1c(%ebp)
  8012b9:	81 45 dc 00 00 40 00 	addl   $0x400000,-0x24(%ebp)
  8012c0:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
  8012c7:	0f 85 af fe ff ff    	jne    80117c <fork+0x56>
				}
                        }
                }
        }

        if (sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_P | PTE_U | PTE_W) < 0)
  8012cd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d4:	00 
  8012d5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012dc:	ee 
  8012dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	e8 f6 fc ff ff       	call   800fde <sys_page_alloc>
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	79 1c                	jns    801308 <fork+0x1e2>
                panic("sys_page_alloc could not alooc\n");
  8012ec:	c7 44 24 08 cc 25 80 	movl   $0x8025cc,0x8(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  8012fb:	00 
  8012fc:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801303:	e8 04 0a 00 00       	call   801d0c <_panic>
        
        extern void _pgfault_upcall(void);
	
        if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801308:	c7 44 24 04 00 1e 80 	movl   $0x801e00,0x4(%esp)
  80130f:	00 
  801310:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801313:	89 14 24             	mov    %edx,(%esp)
  801316:	e8 ed fa ff ff       	call   800e08 <sys_env_set_pgfault_upcall>
  80131b:	85 c0                	test   %eax,%eax
  80131d:	79 1c                	jns    80133b <fork+0x215>
                panic("failed in upcall\n");
  80131f:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801336:	e8 d1 09 00 00       	call   801d0c <_panic>
	
        if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80133b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801342:	00 
  801343:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 76 fb ff ff       	call   800ec4 <sys_env_set_status>
  80134e:	85 c0                	test   %eax,%eax
  801350:	79 1c                	jns    80136e <fork+0x248>
                panic("failed in status set\n");
  801352:	c7 44 24 08 72 25 80 	movl   $0x802572,0x8(%esp)
  801359:	00 
  80135a:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
  801361:	00 
  801362:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801369:	e8 9e 09 00 00       	call   801d0c <_panic>

        return envid;
}
  80136e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801371:	83 c4 3c             	add    $0x3c,%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
                                pte_t p = vpt[i * NPTENTRIES + j];

                                if ((p & PTE_P) && (p & PTE_U))
				{
                                        if (duppage(envid, i * NPTENTRIES + j) < 0)
                                                panic("filing in duppage\n");
  801379:	c7 44 24 08 88 25 80 	movl   $0x802588,0x8(%esp)
  801380:	00 
  801381:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801388:	00 
  801389:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801390:	e8 77 09 00 00       	call   801d0c <_panic>

00801395 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 24             	sub    $0x24,%esp
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
        void *addr = (void *) utf->utf_fault_va;
  80139f:	8b 18                	mov    (%eax),%ebx
        //   Use the read-only page table mappings at vpt
        //   (see <inc/memlayout.h>).

        // LAB 4: Your code here.
        
	pte_t pte = ((pte_t *)vpt)[VPN(addr)];
  8013a1:	89 da                	mov    %ebx,%edx
  8013a3:	c1 ea 0c             	shr    $0xc,%edx
  8013a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
        void *addr = (void *) utf->utf_fault_va;
        uint32_t err = utf->utf_err;
  8013ad:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8013b1:	74 05                	je     8013b8 <pgfault+0x23>

        // LAB 4: Your code here.
        
	pte_t pte = ((pte_t *)vpt)[VPN(addr)];
        
	if(!((err & FEC_WR) != 0 && (pte & PTE_COW) != 0)) 
  8013b3:	f6 c6 08             	test   $0x8,%dh
  8013b6:	75 1c                	jne    8013d4 <pgfault+0x3f>
	{
                panic("invalid permissions\n");
  8013b8:	c7 44 24 08 4b 25 80 	movl   $0x80254b,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  8013cf:	e8 38 09 00 00       	call   801d0c <_panic>
                return;
        }

        if (sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
  8013d4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013db:	00 
  8013dc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013e3:	00 
  8013e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013eb:	e8 ee fb ff ff       	call   800fde <sys_page_alloc>
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	79 1c                	jns    801410 <pgfault+0x7b>
                panic("error in sys_page_alloc\n");
  8013f4:	c7 44 24 08 9b 25 80 	movl   $0x80259b,0x8(%esp)
  8013fb:	00 
  8013fc:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801403:	00 
  801404:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  80140b:	e8 fc 08 00 00       	call   801d0c <_panic>
        
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801410:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801416:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80141d:	00 
  80141e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801422:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801429:	e8 d7 f6 ff ff       	call   800b05 <memmove>
        
	if (sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W) < 0)
  80142e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801435:	00 
  801436:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80143a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801441:	00 
  801442:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801449:	00 
  80144a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801451:	e8 2a fb ff ff       	call   800f80 <sys_page_map>
  801456:	85 c0                	test   %eax,%eax
  801458:	79 1c                	jns    801476 <pgfault+0xe1>
                panic("error in sys_page_map\n");
  80145a:	c7 44 24 08 b4 25 80 	movl   $0x8025b4,0x8(%esp)
  801461:	00 
  801462:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801469:	00 
  80146a:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801471:	e8 96 08 00 00       	call   801d0c <_panic>
        
	sys_page_unmap(0, PFTEMP);
  801476:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80147d:	00 
  80147e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801485:	e8 98 fa ff ff       	call   800f22 <sys_page_unmap>
        //   No need to explicitly delete the old page's mapping.
        
        // LAB 4: Your code here.
        
        //panic("pgfault not implemented");
}
  80148a:	83 c4 24             	add    $0x24,%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	05 00 00 00 30       	add    $0x30000000,%eax
  80149b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    

008014a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	89 04 24             	mov    %eax,(%esp)
  8014ac:	e8 df ff ff ff       	call   801490 <fd2num>
  8014b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	57                   	push   %edi
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8014c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014c9:	a8 01                	test   $0x1,%al
  8014cb:	74 36                	je     801503 <fd_alloc+0x48>
  8014cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014d2:	a8 01                	test   $0x1,%al
  8014d4:	74 2d                	je     801503 <fd_alloc+0x48>
  8014d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8014db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8014e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	c1 ea 16             	shr    $0x16,%edx
  8014ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8014ef:	f6 c2 01             	test   $0x1,%dl
  8014f2:	74 14                	je     801508 <fd_alloc+0x4d>
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	c1 ea 0c             	shr    $0xc,%edx
  8014f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8014fc:	f6 c2 01             	test   $0x1,%dl
  8014ff:	75 10                	jne    801511 <fd_alloc+0x56>
  801501:	eb 05                	jmp    801508 <fd_alloc+0x4d>
  801503:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801508:	89 1f                	mov    %ebx,(%edi)
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80150f:	eb 17                	jmp    801528 <fd_alloc+0x6d>
  801511:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801516:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80151b:	75 c8                	jne    8014e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80151d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801523:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	83 f8 1f             	cmp    $0x1f,%eax
  801536:	77 36                	ja     80156e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801538:	05 00 00 0d 00       	add    $0xd0000,%eax
  80153d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801540:	89 c2                	mov    %eax,%edx
  801542:	c1 ea 16             	shr    $0x16,%edx
  801545:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80154c:	f6 c2 01             	test   $0x1,%dl
  80154f:	74 1d                	je     80156e <fd_lookup+0x41>
  801551:	89 c2                	mov    %eax,%edx
  801553:	c1 ea 0c             	shr    $0xc,%edx
  801556:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155d:	f6 c2 01             	test   $0x1,%dl
  801560:	74 0c                	je     80156e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801562:	8b 55 0c             	mov    0xc(%ebp),%edx
  801565:	89 02                	mov    %eax,(%edx)
  801567:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80156c:	eb 05                	jmp    801573 <fd_lookup+0x46>
  80156e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80157e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
  801585:	89 04 24             	mov    %eax,(%esp)
  801588:	e8 a0 ff ff ff       	call   80152d <fd_lookup>
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 0e                	js     80159f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801591:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
  801597:	89 50 04             	mov    %edx,0x4(%eax)
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 10             	sub    $0x10,%esp
  8015a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8015af:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015b9:	be 68 26 80 00       	mov    $0x802668,%esi
		if (devtab[i]->dev_id == dev_id) {
  8015be:	39 08                	cmp    %ecx,(%eax)
  8015c0:	75 10                	jne    8015d2 <dev_lookup+0x31>
  8015c2:	eb 04                	jmp    8015c8 <dev_lookup+0x27>
  8015c4:	39 08                	cmp    %ecx,(%eax)
  8015c6:	75 0a                	jne    8015d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8015c8:	89 03                	mov    %eax,(%ebx)
  8015ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015cf:	90                   	nop
  8015d0:	eb 31                	jmp    801603 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015d2:	83 c2 01             	add    $0x1,%edx
  8015d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	75 e8                	jne    8015c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8015dc:	a1 24 50 80 00       	mov    0x805024,%eax
  8015e1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8015e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ec:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  8015f3:	e8 79 ec ff ff       	call   800271 <cprintf>
	*dev = 0;
  8015f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 24             	sub    $0x24,%esp
  801611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161b:	8b 45 08             	mov    0x8(%ebp),%eax
  80161e:	89 04 24             	mov    %eax,(%esp)
  801621:	e8 07 ff ff ff       	call   80152d <fd_lookup>
  801626:	85 c0                	test   %eax,%eax
  801628:	78 53                	js     80167d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801634:	8b 00                	mov    (%eax),%eax
  801636:	89 04 24             	mov    %eax,(%esp)
  801639:	e8 63 ff ff ff       	call   8015a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 3b                	js     80167d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801642:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80164e:	74 2d                	je     80167d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801650:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801653:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80165a:	00 00 00 
	stat->st_isdir = 0;
  80165d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801664:	00 00 00 
	stat->st_dev = dev;
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801674:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801677:	89 14 24             	mov    %edx,(%esp)
  80167a:	ff 50 14             	call   *0x14(%eax)
}
  80167d:	83 c4 24             	add    $0x24,%esp
  801680:	5b                   	pop    %ebx
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 24             	sub    $0x24,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	89 1c 24             	mov    %ebx,(%esp)
  801697:	e8 91 fe ff ff       	call   80152d <fd_lookup>
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 5f                	js     8016ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	8b 00                	mov    (%eax),%eax
  8016ac:	89 04 24             	mov    %eax,(%esp)
  8016af:	e8 ed fe ff ff       	call   8015a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 47                	js     8016ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016bb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8016bf:	75 23                	jne    8016e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  8016c1:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8016c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  8016d8:	e8 94 eb ff ff       	call   800271 <cprintf>
  8016dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  8016e2:	eb 1b                	jmp    8016ff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8016e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e7:	8b 48 18             	mov    0x18(%eax),%ecx
  8016ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ef:	85 c9                	test   %ecx,%ecx
  8016f1:	74 0c                	je     8016ff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fa:	89 14 24             	mov    %edx,(%esp)
  8016fd:	ff d1                	call   *%ecx
}
  8016ff:	83 c4 24             	add    $0x24,%esp
  801702:	5b                   	pop    %ebx
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	53                   	push   %ebx
  801709:	83 ec 24             	sub    $0x24,%esp
  80170c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801712:	89 44 24 04          	mov    %eax,0x4(%esp)
  801716:	89 1c 24             	mov    %ebx,(%esp)
  801719:	e8 0f fe ff ff       	call   80152d <fd_lookup>
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 66                	js     801788 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172c:	8b 00                	mov    (%eax),%eax
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	e8 6b fe ff ff       	call   8015a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801736:	85 c0                	test   %eax,%eax
  801738:	78 4e                	js     801788 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80173d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801741:	75 23                	jne    801766 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801743:	a1 24 50 80 00       	mov    0x805024,%eax
  801748:	8b 40 4c             	mov    0x4c(%eax),%eax
  80174b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	c7 04 24 2d 26 80 00 	movl   $0x80262d,(%esp)
  80175a:	e8 12 eb ff ff       	call   800271 <cprintf>
  80175f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801764:	eb 22                	jmp    801788 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801769:	8b 48 0c             	mov    0xc(%eax),%ecx
  80176c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801771:	85 c9                	test   %ecx,%ecx
  801773:	74 13                	je     801788 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801775:	8b 45 10             	mov    0x10(%ebp),%eax
  801778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801783:	89 14 24             	mov    %edx,(%esp)
  801786:	ff d1                	call   *%ecx
}
  801788:	83 c4 24             	add    $0x24,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	53                   	push   %ebx
  801792:	83 ec 24             	sub    $0x24,%esp
  801795:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801798:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179f:	89 1c 24             	mov    %ebx,(%esp)
  8017a2:	e8 86 fd ff ff       	call   80152d <fd_lookup>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 6b                	js     801816 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b5:	8b 00                	mov    (%eax),%eax
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	e8 e2 fd ff ff       	call   8015a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 53                	js     801816 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c6:	8b 42 08             	mov    0x8(%edx),%eax
  8017c9:	83 e0 03             	and    $0x3,%eax
  8017cc:	83 f8 01             	cmp    $0x1,%eax
  8017cf:	75 23                	jne    8017f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8017d1:	a1 24 50 80 00       	mov    0x805024,%eax
  8017d6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8017d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	c7 04 24 4a 26 80 00 	movl   $0x80264a,(%esp)
  8017e8:	e8 84 ea ff ff       	call   800271 <cprintf>
  8017ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017f2:	eb 22                	jmp    801816 <read+0x88>
	}
	if (!dev->dev_read)
  8017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f7:	8b 48 08             	mov    0x8(%eax),%ecx
  8017fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ff:	85 c9                	test   %ecx,%ecx
  801801:	74 13                	je     801816 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801803:	8b 45 10             	mov    0x10(%ebp),%eax
  801806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80180a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	89 14 24             	mov    %edx,(%esp)
  801814:	ff d1                	call   *%ecx
}
  801816:	83 c4 24             	add    $0x24,%esp
  801819:	5b                   	pop    %ebx
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	83 ec 1c             	sub    $0x1c,%esp
  801825:	8b 7d 08             	mov    0x8(%ebp),%edi
  801828:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	bb 00 00 00 00       	mov    $0x0,%ebx
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
  80183a:	85 f6                	test   %esi,%esi
  80183c:	74 29                	je     801867 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80183e:	89 f0                	mov    %esi,%eax
  801840:	29 d0                	sub    %edx,%eax
  801842:	89 44 24 08          	mov    %eax,0x8(%esp)
  801846:	03 55 0c             	add    0xc(%ebp),%edx
  801849:	89 54 24 04          	mov    %edx,0x4(%esp)
  80184d:	89 3c 24             	mov    %edi,(%esp)
  801850:	e8 39 ff ff ff       	call   80178e <read>
		if (m < 0)
  801855:	85 c0                	test   %eax,%eax
  801857:	78 0e                	js     801867 <readn+0x4b>
			return m;
		if (m == 0)
  801859:	85 c0                	test   %eax,%eax
  80185b:	74 08                	je     801865 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80185d:	01 c3                	add    %eax,%ebx
  80185f:	89 da                	mov    %ebx,%edx
  801861:	39 f3                	cmp    %esi,%ebx
  801863:	72 d9                	jb     80183e <readn+0x22>
  801865:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801867:	83 c4 1c             	add    $0x1c,%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5f                   	pop    %edi
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
  801874:	83 ec 20             	sub    $0x20,%esp
  801877:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80187a:	89 34 24             	mov    %esi,(%esp)
  80187d:	e8 0e fc ff ff       	call   801490 <fd2num>
  801882:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801885:	89 54 24 04          	mov    %edx,0x4(%esp)
  801889:	89 04 24             	mov    %eax,(%esp)
  80188c:	e8 9c fc ff ff       	call   80152d <fd_lookup>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	85 c0                	test   %eax,%eax
  801895:	78 05                	js     80189c <fd_close+0x2d>
  801897:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80189a:	74 0c                	je     8018a8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80189c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8018a0:	19 c0                	sbb    %eax,%eax
  8018a2:	f7 d0                	not    %eax
  8018a4:	21 c3                	and    %eax,%ebx
  8018a6:	eb 3d                	jmp    8018e5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018af:	8b 06                	mov    (%esi),%eax
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 e8 fc ff ff       	call   8015a1 <dev_lookup>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 16                	js     8018d5 <fd_close+0x66>
		if (dev->dev_close)
  8018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c2:	8b 40 10             	mov    0x10(%eax),%eax
  8018c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	74 07                	je     8018d5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8018ce:	89 34 24             	mov    %esi,(%esp)
  8018d1:	ff d0                	call   *%eax
  8018d3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e0:	e8 3d f6 ff ff       	call   800f22 <sys_page_unmap>
	return r;
}
  8018e5:	89 d8                	mov    %ebx,%eax
  8018e7:	83 c4 20             	add    $0x20,%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 27 fc ff ff       	call   80152d <fd_lookup>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 13                	js     80191d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80190a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801911:	00 
  801912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801915:	89 04 24             	mov    %eax,(%esp)
  801918:	e8 52 ff ff ff       	call   80186f <fd_close>
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 18             	sub    $0x18,%esp
  801925:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801928:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80192b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801932:	00 
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	89 04 24             	mov    %eax,(%esp)
  801939:	e8 4d 03 00 00       	call   801c8b <open>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	85 c0                	test   %eax,%eax
  801942:	78 1b                	js     80195f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801944:	8b 45 0c             	mov    0xc(%ebp),%eax
  801947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194b:	89 1c 24             	mov    %ebx,(%esp)
  80194e:	e8 b7 fc ff ff       	call   80160a <fstat>
  801953:	89 c6                	mov    %eax,%esi
	close(fd);
  801955:	89 1c 24             	mov    %ebx,(%esp)
  801958:	e8 91 ff ff ff       	call   8018ee <close>
  80195d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801964:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801967:	89 ec                	mov    %ebp,%esp
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	53                   	push   %ebx
  80196f:	83 ec 14             	sub    $0x14,%esp
  801972:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801977:	89 1c 24             	mov    %ebx,(%esp)
  80197a:	e8 6f ff ff ff       	call   8018ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80197f:	83 c3 01             	add    $0x1,%ebx
  801982:	83 fb 20             	cmp    $0x20,%ebx
  801985:	75 f0                	jne    801977 <close_all+0xc>
		close(i);
}
  801987:	83 c4 14             	add    $0x14,%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 58             	sub    $0x58,%esp
  801993:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801996:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801999:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80199c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80199f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	89 04 24             	mov    %eax,(%esp)
  8019ac:	e8 7c fb ff ff       	call   80152d <fd_lookup>
  8019b1:	89 c3                	mov    %eax,%ebx
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	0f 88 e0 00 00 00    	js     801a9b <dup+0x10e>
		return r;
	close(newfdnum);
  8019bb:	89 3c 24             	mov    %edi,(%esp)
  8019be:	e8 2b ff ff ff       	call   8018ee <close>

	newfd = INDEX2FD(newfdnum);
  8019c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8019c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8019cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019cf:	89 04 24             	mov    %eax,(%esp)
  8019d2:	e8 c9 fa ff ff       	call   8014a0 <fd2data>
  8019d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8019d9:	89 34 24             	mov    %esi,(%esp)
  8019dc:	e8 bf fa ff ff       	call   8014a0 <fd2data>
  8019e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8019e4:	89 da                	mov    %ebx,%edx
  8019e6:	89 d8                	mov    %ebx,%eax
  8019e8:	c1 e8 16             	shr    $0x16,%eax
  8019eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019f2:	a8 01                	test   $0x1,%al
  8019f4:	74 43                	je     801a39 <dup+0xac>
  8019f6:	c1 ea 0c             	shr    $0xc,%edx
  8019f9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a00:	a8 01                	test   $0x1,%al
  801a02:	74 35                	je     801a39 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801a04:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a0b:	25 07 0e 00 00       	and    $0xe07,%eax
  801a10:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a22:	00 
  801a23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2e:	e8 4d f5 ff ff       	call   800f80 <sys_page_map>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 3f                	js     801a78 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801a39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3c:	89 c2                	mov    %eax,%edx
  801a3e:	c1 ea 0c             	shr    $0xc,%edx
  801a41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a48:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a5d:	00 
  801a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a69:	e8 12 f5 ff ff       	call   800f80 <sys_page_map>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 04                	js     801a78 <dup+0xeb>
  801a74:	89 fb                	mov    %edi,%ebx
  801a76:	eb 23                	jmp    801a9b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a78:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a83:	e8 9a f4 ff ff       	call   800f22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a96:	e8 87 f4 ff ff       	call   800f22 <sys_page_unmap>
	return r;
}
  801a9b:	89 d8                	mov    %ebx,%eax
  801a9d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801aa0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801aa3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801aa6:	89 ec                	mov    %ebp,%esp
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    
  801aaa:	00 00                	add    %al,(%eax)
  801aac:	00 00                	add    %al,(%eax)
	...

00801ab0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 14             	sub    $0x14,%esp
  801ab7:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ab9:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801abf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ac6:	00 
  801ac7:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801ace:	00 
  801acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad3:	89 14 24             	mov    %edx,(%esp)
  801ad6:	e8 4d 03 00 00       	call   801e28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801adb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ae2:	00 
  801ae3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aee:	e8 9f 03 00 00       	call   801e92 <ipc_recv>
}
  801af3:	83 c4 14             	add    $0x14,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	8b 40 0c             	mov    0xc(%eax),%eax
  801b05:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0d:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b12:	ba 00 00 00 00       	mov    $0x0,%edx
  801b17:	b8 02 00 00 00       	mov    $0x2,%eax
  801b1c:	e8 8f ff ff ff       	call   801ab0 <fsipc>
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801b34:	ba 00 00 00 00       	mov    $0x0,%edx
  801b39:	b8 06 00 00 00       	mov    $0x6,%eax
  801b3e:	e8 6d ff ff ff       	call   801ab0 <fsipc>
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b50:	b8 08 00 00 00       	mov    $0x8,%eax
  801b55:	e8 56 ff ff ff       	call   801ab0 <fsipc>
}
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 14             	sub    $0x14,%esp
  801b63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6c:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 05 00 00 00       	mov    $0x5,%eax
  801b7b:	e8 30 ff ff ff       	call   801ab0 <fsipc>
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 2b                	js     801baf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b84:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801b8b:	00 
  801b8c:	89 1c 24             	mov    %ebx,(%esp)
  801b8f:	e8 b6 ed ff ff       	call   80094a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b94:	a1 80 30 80 00       	mov    0x803080,%eax
  801b99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b9f:	a1 84 30 80 00       	mov    0x803084,%eax
  801ba4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801baf:	83 c4 14             	add    $0x14,%esp
  801bb2:	5b                   	pop    %ebx
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 18             	sub    $0x18,%esp
  801bbb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  801bc1:	8b 52 0c             	mov    0xc(%edx),%edx
  801bc4:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  801bca:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bda:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801be1:	e8 1f ef ff ff       	call   800b05 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801be6:	ba 00 30 80 00       	mov    $0x803000,%edx
  801beb:	b8 04 00 00 00       	mov    $0x4,%eax
  801bf0:	e8 bb fe ff ff       	call   801ab0 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	53                   	push   %ebx
  801bfb:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	8b 40 0c             	mov    0xc(%eax),%eax
  801c04:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801c09:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0c:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801c11:	ba 00 30 80 00       	mov    $0x803000,%edx
  801c16:	b8 03 00 00 00       	mov    $0x3,%eax
  801c1b:	e8 90 fe ff ff       	call   801ab0 <fsipc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 17                	js     801c3d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801c26:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c2a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801c31:	00 
  801c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 c8 ee ff ff       	call   800b05 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  801c3d:	89 d8                	mov    %ebx,%eax
  801c3f:	83 c4 14             	add    $0x14,%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	83 ec 14             	sub    $0x14,%esp
  801c4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c4f:	89 1c 24             	mov    %ebx,(%esp)
  801c52:	e8 a9 ec ff ff       	call   800900 <strlen>
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801c5e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801c64:	7f 1f                	jg     801c85 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801c71:	e8 d4 ec ff ff       	call   80094a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c76:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7b:	b8 07 00 00 00       	mov    $0x7,%eax
  801c80:	e8 2b fe ff ff       	call   801ab0 <fsipc>
}
  801c85:	83 c4 14             	add    $0x14,%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	89 04 24             	mov    %eax,(%esp)
  801c97:	e8 1f f8 ff ff       	call   8014bb <fd_alloc>
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 6a                	js     801d0a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca7:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801cae:	e8 97 ec ff ff       	call   80094a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb6:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cbb:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801cc0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cc7:	00 
  801cc8:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801ccf:	00 
  801cd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cd7:	00 
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	e8 48 01 00 00       	call   801e28 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801ce0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ce7:	00 
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf6:	e8 97 01 00 00       	call   801e92 <ipc_recv>
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 0b                	js     801d0a <open+0x7f>
		return r;
	return fd2num(fd);
  801cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d02:	89 04 24             	mov    %eax,(%esp)
  801d05:	e8 86 f7 ff ff       	call   801490 <fd2num>
	panic("open not implemented");
}
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  801d13:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801d16:	a1 28 50 80 00       	mov    0x805028,%eax
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	74 10                	je     801d2f <_panic+0x23>
		cprintf("%s: ", argv0);
  801d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d23:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  801d2a:	e8 42 e5 ff ff       	call   800271 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3d:	a1 00 50 80 00       	mov    0x805000,%eax
  801d42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d46:	c7 04 24 75 26 80 00 	movl   $0x802675,(%esp)
  801d4d:	e8 1f e5 ff ff       	call   800271 <cprintf>
	vcprintf(fmt, ap);
  801d52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d56:	8b 45 10             	mov    0x10(%ebp),%eax
  801d59:	89 04 24             	mov    %eax,(%esp)
  801d5c:	e8 af e4 ff ff       	call   800210 <vcprintf>
	cprintf("\n");
  801d61:	c7 04 24 be 21 80 00 	movl   $0x8021be,(%esp)
  801d68:	e8 04 e5 ff ff       	call   800271 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d6d:	cc                   	int3   
  801d6e:	eb fd                	jmp    801d6d <_panic+0x61>

00801d70 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//

void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	53                   	push   %ebx
  801d74:	83 ec 14             	sub    $0x14,%esp
	int r;
	if (_pgfault_handler == 0) {
  801d77:	83 3d 2c 50 80 00 00 	cmpl   $0x0,0x80502c
  801d7e:	75 6f                	jne    801def <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801d80:	e8 ec f2 ff ff       	call   801071 <sys_getenvid>
  801d85:	89 c3                	mov    %eax,%ebx
		if(sys_page_alloc(envid,(void*) UXSTACKTOP-PGSIZE,PTE_W|PTE_U|PTE_P)<0)
  801d87:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d8e:	00 
  801d8f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801d96:	ee 
  801d97:	89 04 24             	mov    %eax,(%esp)
  801d9a:	e8 3f f2 ff ff       	call   800fde <sys_page_alloc>
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	79 1c                	jns    801dbf <set_pgfault_handler+0x4f>
		{
			panic("UXSTACKTOP could not be allocated\n");
  801da3:	c7 44 24 08 94 26 80 	movl   $0x802694,0x8(%esp)
  801daa:	00 
  801dab:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801db2:	00 
  801db3:	c7 04 24 b8 26 80 00 	movl   $0x8026b8,(%esp)
  801dba:	e8 4d ff ff ff       	call   801d0c <_panic>
		}	
		
		if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall)<0)
  801dbf:	c7 44 24 04 00 1e 80 	movl   $0x801e00,0x4(%esp)
  801dc6:	00 
  801dc7:	89 1c 24             	mov    %ebx,(%esp)
  801dca:	e8 39 f0 ff ff       	call   800e08 <sys_env_set_pgfault_upcall>
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	79 1c                	jns    801def <set_pgfault_handler+0x7f>
		{
			panic("upcall failed\n");
  801dd3:	c7 44 24 08 c6 26 80 	movl   $0x8026c6,0x8(%esp)
  801dda:	00 
  801ddb:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801de2:	00 
  801de3:	c7 04 24 b8 26 80 00 	movl   $0x8026b8,(%esp)
  801dea:	e8 1d ff ff ff       	call   801d0c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801def:	8b 45 08             	mov    0x8(%ebp),%eax
  801df2:	a3 2c 50 80 00       	mov    %eax,0x80502c
	//cprintf("returning from set_pgfault_handler\n");
}
  801df7:	83 c4 14             	add    $0x14,%esp
  801dfa:	5b                   	pop    %ebx
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	00 00                	add    %al,(%eax)
	...

00801e00 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e00:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e01:	a1 2c 50 80 00       	mov    0x80502c,%eax
	call *%eax
  801e06:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e08:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.	
	
	addl $0x8, %esp 	// ignoring fault_va, utf_err and setting esp for pop
  801e0b:	83 c4 08             	add    $0x8,%esp
	movl 0x20(%esp), %eax
  801e0e:	8b 44 24 20          	mov    0x20(%esp),%eax
	mov %eax, %ebx
  801e12:	89 c3                	mov    %eax,%ebx
	movl 0x28(%esp), %eax
  801e14:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, %eax
  801e18:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  801e1b:	89 18                	mov    %ebx,(%eax)
	movl %eax, 0x28(%esp)	
  801e1d:	89 44 24 28          	mov    %eax,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e21:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e22:	83 c4 04             	add    $0x4,%esp
	popfl
  801e25:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e26:	5c                   	pop    %esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e27:	c3                   	ret    

00801e28 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	57                   	push   %edi
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 1c             	sub    $0x1c,%esp
  801e31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e37:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  801e3a:	85 db                	test   %ebx,%ebx
  801e3c:	75 31                	jne    801e6f <ipc_send+0x47>
  801e3e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e43:	eb 2a                	jmp    801e6f <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  801e45:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e48:	74 20                	je     801e6a <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  801e4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e4e:	c7 44 24 08 d5 26 80 	movl   $0x8026d5,0x8(%esp)
  801e55:	00 
  801e56:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801e5d:	00 
  801e5e:	c7 04 24 ec 26 80 00 	movl   $0x8026ec,(%esp)
  801e65:	e8 a2 fe ff ff       	call   801d0c <_panic>


                sys_yield();
  801e6a:	e8 ce f1 ff ff       	call   80103d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e6f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e73:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e77:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 4a ef ff ff       	call   800dd0 <sys_ipc_try_send>
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 bb                	js     801e45 <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 10             	sub    $0x10,%esp
  801e9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	75 05                	jne    801eac <ipc_recv+0x1a>
  801ea7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 bf ee ff ff       	call   800d73 <sys_ipc_recv>
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	78 24                	js     801edc <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801eb8:	85 db                	test   %ebx,%ebx
  801eba:	74 0a                	je     801ec6 <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801ebc:	a1 24 50 80 00       	mov    0x805024,%eax
  801ec1:	8b 40 74             	mov    0x74(%eax),%eax
  801ec4:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  801ec6:	85 f6                	test   %esi,%esi
  801ec8:	74 0a                	je     801ed4 <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801eca:	a1 24 50 80 00       	mov    0x805024,%eax
  801ecf:	8b 40 78             	mov    0x78(%eax),%eax
  801ed2:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  801ed4:	a1 24 50 80 00       	mov    0x805024,%eax
  801ed9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	5b                   	pop    %ebx
  801ee0:	5e                   	pop    %esi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    
	...

00801ef0 <__udivdi3>:
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	57                   	push   %edi
  801ef4:	56                   	push   %esi
  801ef5:	83 ec 10             	sub    $0x10,%esp
  801ef8:	8b 45 14             	mov    0x14(%ebp),%eax
  801efb:	8b 55 08             	mov    0x8(%ebp),%edx
  801efe:	8b 75 10             	mov    0x10(%ebp),%esi
  801f01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f04:	85 c0                	test   %eax,%eax
  801f06:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f09:	75 35                	jne    801f40 <__udivdi3+0x50>
  801f0b:	39 fe                	cmp    %edi,%esi
  801f0d:	77 61                	ja     801f70 <__udivdi3+0x80>
  801f0f:	85 f6                	test   %esi,%esi
  801f11:	75 0b                	jne    801f1e <__udivdi3+0x2e>
  801f13:	b8 01 00 00 00       	mov    $0x1,%eax
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	f7 f6                	div    %esi
  801f1c:	89 c6                	mov    %eax,%esi
  801f1e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f21:	31 d2                	xor    %edx,%edx
  801f23:	89 f8                	mov    %edi,%eax
  801f25:	f7 f6                	div    %esi
  801f27:	89 c7                	mov    %eax,%edi
  801f29:	89 c8                	mov    %ecx,%eax
  801f2b:	f7 f6                	div    %esi
  801f2d:	89 c1                	mov    %eax,%ecx
  801f2f:	89 fa                	mov    %edi,%edx
  801f31:	89 c8                	mov    %ecx,%eax
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    
  801f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f40:	39 f8                	cmp    %edi,%eax
  801f42:	77 1c                	ja     801f60 <__udivdi3+0x70>
  801f44:	0f bd d0             	bsr    %eax,%edx
  801f47:	83 f2 1f             	xor    $0x1f,%edx
  801f4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f4d:	75 39                	jne    801f88 <__udivdi3+0x98>
  801f4f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f52:	0f 86 a0 00 00 00    	jbe    801ff8 <__udivdi3+0x108>
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	0f 82 98 00 00 00    	jb     801ff8 <__udivdi3+0x108>
  801f60:	31 ff                	xor    %edi,%edi
  801f62:	31 c9                	xor    %ecx,%ecx
  801f64:	89 c8                	mov    %ecx,%eax
  801f66:	89 fa                	mov    %edi,%edx
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    
  801f6f:	90                   	nop
  801f70:	89 d1                	mov    %edx,%ecx
  801f72:	89 fa                	mov    %edi,%edx
  801f74:	89 c8                	mov    %ecx,%eax
  801f76:	31 ff                	xor    %edi,%edi
  801f78:	f7 f6                	div    %esi
  801f7a:	89 c1                	mov    %eax,%ecx
  801f7c:	89 fa                	mov    %edi,%edx
  801f7e:	89 c8                	mov    %ecx,%eax
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	5e                   	pop    %esi
  801f84:	5f                   	pop    %edi
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    
  801f87:	90                   	nop
  801f88:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f8c:	89 f2                	mov    %esi,%edx
  801f8e:	d3 e0                	shl    %cl,%eax
  801f90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f93:	b8 20 00 00 00       	mov    $0x20,%eax
  801f98:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f9b:	89 c1                	mov    %eax,%ecx
  801f9d:	d3 ea                	shr    %cl,%edx
  801f9f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fa3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801fa6:	d3 e6                	shl    %cl,%esi
  801fa8:	89 c1                	mov    %eax,%ecx
  801faa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801fad:	89 fe                	mov    %edi,%esi
  801faf:	d3 ee                	shr    %cl,%esi
  801fb1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fb5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fbb:	d3 e7                	shl    %cl,%edi
  801fbd:	89 c1                	mov    %eax,%ecx
  801fbf:	d3 ea                	shr    %cl,%edx
  801fc1:	09 d7                	or     %edx,%edi
  801fc3:	89 f2                	mov    %esi,%edx
  801fc5:	89 f8                	mov    %edi,%eax
  801fc7:	f7 75 ec             	divl   -0x14(%ebp)
  801fca:	89 d6                	mov    %edx,%esi
  801fcc:	89 c7                	mov    %eax,%edi
  801fce:	f7 65 e8             	mull   -0x18(%ebp)
  801fd1:	39 d6                	cmp    %edx,%esi
  801fd3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fd6:	72 30                	jb     802008 <__udivdi3+0x118>
  801fd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fdb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fdf:	d3 e2                	shl    %cl,%edx
  801fe1:	39 c2                	cmp    %eax,%edx
  801fe3:	73 05                	jae    801fea <__udivdi3+0xfa>
  801fe5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801fe8:	74 1e                	je     802008 <__udivdi3+0x118>
  801fea:	89 f9                	mov    %edi,%ecx
  801fec:	31 ff                	xor    %edi,%edi
  801fee:	e9 71 ff ff ff       	jmp    801f64 <__udivdi3+0x74>
  801ff3:	90                   	nop
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fff:	e9 60 ff ff ff       	jmp    801f64 <__udivdi3+0x74>
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80200b:	31 ff                	xor    %edi,%edi
  80200d:	89 c8                	mov    %ecx,%eax
  80200f:	89 fa                	mov    %edi,%edx
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
	...

00802020 <__umoddi3>:
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	83 ec 20             	sub    $0x20,%esp
  802028:	8b 55 14             	mov    0x14(%ebp),%edx
  80202b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80202e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802031:	8b 75 0c             	mov    0xc(%ebp),%esi
  802034:	85 d2                	test   %edx,%edx
  802036:	89 c8                	mov    %ecx,%eax
  802038:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80203b:	75 13                	jne    802050 <__umoddi3+0x30>
  80203d:	39 f7                	cmp    %esi,%edi
  80203f:	76 3f                	jbe    802080 <__umoddi3+0x60>
  802041:	89 f2                	mov    %esi,%edx
  802043:	f7 f7                	div    %edi
  802045:	89 d0                	mov    %edx,%eax
  802047:	31 d2                	xor    %edx,%edx
  802049:	83 c4 20             	add    $0x20,%esp
  80204c:	5e                   	pop    %esi
  80204d:	5f                   	pop    %edi
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    
  802050:	39 f2                	cmp    %esi,%edx
  802052:	77 4c                	ja     8020a0 <__umoddi3+0x80>
  802054:	0f bd ca             	bsr    %edx,%ecx
  802057:	83 f1 1f             	xor    $0x1f,%ecx
  80205a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80205d:	75 51                	jne    8020b0 <__umoddi3+0x90>
  80205f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802062:	0f 87 e0 00 00 00    	ja     802148 <__umoddi3+0x128>
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	29 f8                	sub    %edi,%eax
  80206d:	19 d6                	sbb    %edx,%esi
  80206f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802075:	89 f2                	mov    %esi,%edx
  802077:	83 c4 20             	add    $0x20,%esp
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax
  802080:	85 ff                	test   %edi,%edi
  802082:	75 0b                	jne    80208f <__umoddi3+0x6f>
  802084:	b8 01 00 00 00       	mov    $0x1,%eax
  802089:	31 d2                	xor    %edx,%edx
  80208b:	f7 f7                	div    %edi
  80208d:	89 c7                	mov    %eax,%edi
  80208f:	89 f0                	mov    %esi,%eax
  802091:	31 d2                	xor    %edx,%edx
  802093:	f7 f7                	div    %edi
  802095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802098:	f7 f7                	div    %edi
  80209a:	eb a9                	jmp    802045 <__umoddi3+0x25>
  80209c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	83 c4 20             	add    $0x20,%esp
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    
  8020ab:	90                   	nop
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020b4:	d3 e2                	shl    %cl,%edx
  8020b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8020be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8020c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	d3 ea                	shr    %cl,%edx
  8020cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8020d3:	d3 e7                	shl    %cl,%edi
  8020d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020dc:	89 f2                	mov    %esi,%edx
  8020de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020e1:	89 c7                	mov    %eax,%edi
  8020e3:	d3 ea                	shr    %cl,%edx
  8020e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020ec:	89 c2                	mov    %eax,%edx
  8020ee:	d3 e6                	shl    %cl,%esi
  8020f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020f4:	d3 ea                	shr    %cl,%edx
  8020f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020fa:	09 d6                	or     %edx,%esi
  8020fc:	89 f0                	mov    %esi,%eax
  8020fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802101:	d3 e7                	shl    %cl,%edi
  802103:	89 f2                	mov    %esi,%edx
  802105:	f7 75 f4             	divl   -0xc(%ebp)
  802108:	89 d6                	mov    %edx,%esi
  80210a:	f7 65 e8             	mull   -0x18(%ebp)
  80210d:	39 d6                	cmp    %edx,%esi
  80210f:	72 2b                	jb     80213c <__umoddi3+0x11c>
  802111:	39 c7                	cmp    %eax,%edi
  802113:	72 23                	jb     802138 <__umoddi3+0x118>
  802115:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802119:	29 c7                	sub    %eax,%edi
  80211b:	19 d6                	sbb    %edx,%esi
  80211d:	89 f0                	mov    %esi,%eax
  80211f:	89 f2                	mov    %esi,%edx
  802121:	d3 ef                	shr    %cl,%edi
  802123:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802127:	d3 e0                	shl    %cl,%eax
  802129:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80212d:	09 f8                	or     %edi,%eax
  80212f:	d3 ea                	shr    %cl,%edx
  802131:	83 c4 20             	add    $0x20,%esp
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	39 d6                	cmp    %edx,%esi
  80213a:	75 d9                	jne    802115 <__umoddi3+0xf5>
  80213c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80213f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802142:	eb d1                	jmp    802115 <__umoddi3+0xf5>
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	0f 82 18 ff ff ff    	jb     802068 <__umoddi3+0x48>
  802150:	e9 1d ff ff ff       	jmp    802072 <__umoddi3+0x52>
