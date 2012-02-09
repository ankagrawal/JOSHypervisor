
obj/user/writemotd:     file format elf32-i386


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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
	int rfd, wfd;
	char buf[512];
	int n, r;

	if ((rfd = open("/newmotd", O_RDONLY)) < 0)
  800040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800047:	00 
  800048:	c7 04 24 e0 1d 80 00 	movl   $0x801de0,(%esp)
  80004f:	e8 d7 19 00 00       	call   801a2b <open>
  800054:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 e9 1d 80 	movl   $0x801de9,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 fb 1d 80 00 	movl   $0x801dfb,(%esp)
  800079:	e8 4a 02 00 00       	call   8002c8 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 0c 1e 80 00 	movl   $0x801e0c,(%esp)
  80008d:	e8 99 19 00 00       	call   801a2b <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 12 1e 80 	movl   $0x801e12,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 fb 1d 80 00 	movl   $0x801dfb,(%esp)
  8000b3:	e8 10 02 00 00       	call   8002c8 <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  8000cd:	e8 bb 02 00 00       	call   80038d <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd e4 fd ff ff    	cmp    %edi,-0x21c(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 8c 1e 80 	movl   $0x801e8c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 fb 1d 80 00 	movl   $0x801dfb,(%esp)
  8000f1:	e8 d2 01 00 00       	call   8002c8 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 39 1e 80 00 	movl   $0x801e39,(%esp)
  8000fd:	e8 8b 02 00 00       	call   80038d <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800102:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 4a 0d 00 00       	call   800e60 <sys_cputs>
	cprintf("file descriptors %d %d\n", rfd, wfd);
	if (rfd == wfd)
		panic("open /newmotd and /motd give same file descriptor");

	cprintf("OLD MOTD\n===\n");
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 04 14 00 00       	call   80152e <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 42 1e 80 00 	movl   $0x801e42,(%esp)
  800135:	e8 53 02 00 00       	call   80038d <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 cb 11 00 00       	call   801315 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 c9 12 00 00       	call   801423 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 47 1e 80 	movl   $0x801e47,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 fb 1d 80 00 	movl   $0x801dfb,(%esp)
  800179:	e8 4a 01 00 00       	call   8002c8 <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 5a 1e 80 00 	movl   $0x801e5a,(%esp)
  800185:	e8 03 02 00 00       	call   80038d <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  80018a:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 c2 0c 00 00       	call   800e60 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 f7 12 00 00       	call   8014a5 <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 68 1e 80 	movl   $0x801e68,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 fb 1d 80 00 	movl   $0x801dfb,(%esp)
  8001cd:	e8 f6 00 00 00       	call   8002c8 <_panic>

	if ((r = ftruncate(wfd, 0)) < 0)
		panic("truncate /motd: %e", r);

	cprintf("NEW MOTD\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  8001d2:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  8001d9:	00 
  8001da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001de:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 42 13 00 00       	call   80152e <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 42 1e 80 00 	movl   $0x801e42,(%esp)
  8001f9:	e8 8f 01 00 00       	call   80038d <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 78 1e 80 	movl   $0x801e78,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 fb 1d 80 00 	movl   $0x801dfb,(%esp)
  80021d:	e8 a6 00 00 00       	call   8002c8 <_panic>

	close(rfd);
  800222:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 5e 14 00 00       	call   80168e <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 56 14 00 00       	call   80168e <close>
}
  800238:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
	...

00800244 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80024d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800256:	c7 05 24 50 80 00 00 	movl   $0x0,0x805024
  80025d:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800260:	e8 2c 0f 00 00       	call   801191 <sys_getenvid>
  800265:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80026d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800272:	a3 24 50 80 00       	mov    %eax,0x805024

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800277:	85 f6                	test   %esi,%esi
  800279:	7e 07                	jle    800282 <libmain+0x3e>
		binaryname = argv[0];
  80027b:	8b 03                	mov    (%ebx),%eax
  80027d:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	cprintf("calling here1234\n");
  800282:	c7 04 24 be 1e 80 00 	movl   $0x801ebe,(%esp)
  800289:	e8 ff 00 00 00       	call   80038d <cprintf>
	umain(argc, argv);
  80028e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800292:	89 34 24             	mov    %esi,(%esp)
  800295:	e8 9a fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80029a:	e8 0d 00 00 00       	call   8002ac <exit>
}
  80029f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002a5:	89 ec                	mov    %ebp,%esp
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    
  8002a9:	00 00                	add    %al,(%eax)
	...

008002ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002b2:	e8 54 14 00 00       	call   80170b <close_all>
	sys_env_destroy(0);
  8002b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002be:	e8 02 0f 00 00       	call   8011c5 <sys_env_destroy>
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  8002cf:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8002d2:	a1 28 50 80 00       	mov    0x805028,%eax
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	74 10                	je     8002eb <_panic+0x23>
		cprintf("%s: ", argv0);
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	c7 04 24 e7 1e 80 00 	movl   $0x801ee7,(%esp)
  8002e6:	e8 a2 00 00 00       	call   80038d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f9:	a1 00 50 80 00       	mov    0x805000,%eax
  8002fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800302:	c7 04 24 ec 1e 80 00 	movl   $0x801eec,(%esp)
  800309:	e8 7f 00 00 00       	call   80038d <cprintf>
	vcprintf(fmt, ap);
  80030e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800312:	8b 45 10             	mov    0x10(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	e8 0f 00 00 00       	call   80032c <vcprintf>
	cprintf("\n");
  80031d:	c7 04 24 ce 1e 80 00 	movl   $0x801ece,(%esp)
  800324:	e8 64 00 00 00       	call   80038d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800329:	cc                   	int3   
  80032a:	eb fd                	jmp    800329 <_panic+0x61>

0080032c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800335:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033c:	00 00 00 
	b.cnt = 0;
  80033f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800346:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800349:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	89 44 24 08          	mov    %eax,0x8(%esp)
  800357:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80035d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800361:	c7 04 24 a7 03 80 00 	movl   $0x8003a7,(%esp)
  800368:	e8 d0 01 00 00       	call   80053d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80036d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80037d:	89 04 24             	mov    %eax,(%esp)
  800380:	e8 db 0a 00 00       	call   800e60 <sys_cputs>

	return b.cnt;
}
  800385:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800393:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	89 04 24             	mov    %eax,(%esp)
  8003a0:	e8 87 ff ff ff       	call   80032c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a5:	c9                   	leave  
  8003a6:	c3                   	ret    

008003a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	53                   	push   %ebx
  8003ab:	83 ec 14             	sub    $0x14,%esp
  8003ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003b1:	8b 03                	mov    (%ebx),%eax
  8003b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ba:	83 c0 01             	add    $0x1,%eax
  8003bd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c4:	75 19                	jne    8003df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003cd:	00 
  8003ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8003d1:	89 04 24             	mov    %eax,(%esp)
  8003d4:	e8 87 0a 00 00       	call   800e60 <sys_cputs>
		b->idx = 0;
  8003d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003e3:	83 c4 14             	add    $0x14,%esp
  8003e6:	5b                   	pop    %ebx
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	00 00                	add    %al,(%eax)
  8003eb:	00 00                	add    %al,(%eax)
  8003ed:	00 00                	add    %al,(%eax)
	...

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 4c             	sub    $0x4c,%esp
  8003f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fc:	89 d6                	mov    %edx,%esi
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	8b 55 0c             	mov    0xc(%ebp),%edx
  800407:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80040a:	8b 45 10             	mov    0x10(%ebp),%eax
  80040d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800410:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800416:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041b:	39 d1                	cmp    %edx,%ecx
  80041d:	72 15                	jb     800434 <printnum+0x44>
  80041f:	77 07                	ja     800428 <printnum+0x38>
  800421:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800424:	39 d0                	cmp    %edx,%eax
  800426:	76 0c                	jbe    800434 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800428:	83 eb 01             	sub    $0x1,%ebx
  80042b:	85 db                	test   %ebx,%ebx
  80042d:	8d 76 00             	lea    0x0(%esi),%esi
  800430:	7f 61                	jg     800493 <printnum+0xa3>
  800432:	eb 70                	jmp    8004a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800434:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800438:	83 eb 01             	sub    $0x1,%ebx
  80043b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80043f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800443:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800447:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80044b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80044e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800451:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800454:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800458:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80045f:	00 
  800460:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800469:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046d:	e8 fe 16 00 00       	call   801b70 <__udivdi3>
  800472:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800475:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80047c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	89 54 24 04          	mov    %edx,0x4(%esp)
  800487:	89 f2                	mov    %esi,%edx
  800489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048c:	e8 5f ff ff ff       	call   8003f0 <printnum>
  800491:	eb 11                	jmp    8004a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800493:	89 74 24 04          	mov    %esi,0x4(%esp)
  800497:	89 3c 24             	mov    %edi,(%esp)
  80049a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	85 db                	test   %ebx,%ebx
  8004a2:	7f ef                	jg     800493 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8004ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ba:	00 
  8004bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004be:	89 14 24             	mov    %edx,(%esp)
  8004c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c8:	e8 d3 17 00 00       	call   801ca0 <__umoddi3>
  8004cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d1:	0f be 80 08 1f 80 00 	movsbl 0x801f08(%eax),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004de:	83 c4 4c             	add    $0x4c,%esp
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e9:	83 fa 01             	cmp    $0x1,%edx
  8004ec:	7e 0e                	jle    8004fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ee:	8b 10                	mov    (%eax),%edx
  8004f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f3:	89 08                	mov    %ecx,(%eax)
  8004f5:	8b 02                	mov    (%edx),%eax
  8004f7:	8b 52 04             	mov    0x4(%edx),%edx
  8004fa:	eb 22                	jmp    80051e <getuint+0x38>
	else if (lflag)
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	74 10                	je     800510 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800500:	8b 10                	mov    (%eax),%edx
  800502:	8d 4a 04             	lea    0x4(%edx),%ecx
  800505:	89 08                	mov    %ecx,(%eax)
  800507:	8b 02                	mov    (%edx),%eax
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
  80050e:	eb 0e                	jmp    80051e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 4a 04             	lea    0x4(%edx),%ecx
  800515:	89 08                	mov    %ecx,(%eax)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800526:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80052a:	8b 10                	mov    (%eax),%edx
  80052c:	3b 50 04             	cmp    0x4(%eax),%edx
  80052f:	73 0a                	jae    80053b <sprintputch+0x1b>
		*b->buf++ = ch;
  800531:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800534:	88 0a                	mov    %cl,(%edx)
  800536:	83 c2 01             	add    $0x1,%edx
  800539:	89 10                	mov    %edx,(%eax)
}
  80053b:	5d                   	pop    %ebp
  80053c:	c3                   	ret    

0080053d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
  800543:	83 ec 5c             	sub    $0x5c,%esp
  800546:	8b 7d 08             	mov    0x8(%ebp),%edi
  800549:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80054f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800556:	eb 11                	jmp    800569 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800558:	85 c0                	test   %eax,%eax
  80055a:	0f 84 02 04 00 00    	je     800962 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800560:	89 74 24 04          	mov    %esi,0x4(%esp)
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800569:	0f b6 03             	movzbl (%ebx),%eax
  80056c:	83 c3 01             	add    $0x1,%ebx
  80056f:	83 f8 25             	cmp    $0x25,%eax
  800572:	75 e4                	jne    800558 <vprintfmt+0x1b>
  800574:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800578:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80057f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800586:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800592:	eb 06                	jmp    80059a <vprintfmt+0x5d>
  800594:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800598:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	0f b6 13             	movzbl (%ebx),%edx
  80059d:	0f b6 c2             	movzbl %dl,%eax
  8005a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8005a6:	83 ea 23             	sub    $0x23,%edx
  8005a9:	80 fa 55             	cmp    $0x55,%dl
  8005ac:	0f 87 93 03 00 00    	ja     800945 <vprintfmt+0x408>
  8005b2:	0f b6 d2             	movzbl %dl,%edx
  8005b5:	ff 24 95 40 20 80 00 	jmp    *0x802040(,%edx,4)
  8005bc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c0:	eb d6                	jmp    800598 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c5:	83 ea 30             	sub    $0x30,%edx
  8005c8:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8005cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005ce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005d1:	83 fb 09             	cmp    $0x9,%ebx
  8005d4:	77 4c                	ja     800622 <vprintfmt+0xe5>
  8005d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005d9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005dc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005df:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005e2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8005e6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005e9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005ec:	83 fb 09             	cmp    $0x9,%ebx
  8005ef:	76 eb                	jbe    8005dc <vprintfmt+0x9f>
  8005f1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f7:	eb 29                	jmp    800622 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8005fc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800602:	8b 12                	mov    (%edx),%edx
  800604:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  800607:	eb 19                	jmp    800622 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  800609:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060c:	c1 fa 1f             	sar    $0x1f,%edx
  80060f:	f7 d2                	not    %edx
  800611:	21 55 e4             	and    %edx,-0x1c(%ebp)
  800614:	eb 82                	jmp    800598 <vprintfmt+0x5b>
  800616:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80061d:	e9 76 ff ff ff       	jmp    800598 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800622:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800626:	0f 89 6c ff ff ff    	jns    800598 <vprintfmt+0x5b>
  80062c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800632:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800635:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800638:	e9 5b ff ff ff       	jmp    800598 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800640:	e9 53 ff ff ff       	jmp    800598 <vprintfmt+0x5b>
  800645:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	89 74 24 04          	mov    %esi,0x4(%esp)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 04 24             	mov    %eax,(%esp)
  80065a:	ff d7                	call   *%edi
  80065c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80065f:	e9 05 ff ff ff       	jmp    800569 <vprintfmt+0x2c>
  800664:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 50 04             	lea    0x4(%eax),%edx
  80066d:	89 55 14             	mov    %edx,0x14(%ebp)
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 c2                	mov    %eax,%edx
  800674:	c1 fa 1f             	sar    $0x1f,%edx
  800677:	31 d0                	xor    %edx,%eax
  800679:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80067b:	83 f8 0f             	cmp    $0xf,%eax
  80067e:	7f 0b                	jg     80068b <vprintfmt+0x14e>
  800680:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  800687:	85 d2                	test   %edx,%edx
  800689:	75 20                	jne    8006ab <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80068b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068f:	c7 44 24 08 19 1f 80 	movl   $0x801f19,0x8(%esp)
  800696:	00 
  800697:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069b:	89 3c 24             	mov    %edi,(%esp)
  80069e:	e8 47 03 00 00       	call   8009ea <printfmt>
  8006a3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8006a6:	e9 be fe ff ff       	jmp    800569 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006af:	c7 44 24 08 22 1f 80 	movl   $0x801f22,0x8(%esp)
  8006b6:	00 
  8006b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bb:	89 3c 24             	mov    %edi,(%esp)
  8006be:	e8 27 03 00 00       	call   8009ea <printfmt>
  8006c3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006c6:	e9 9e fe ff ff       	jmp    800569 <vprintfmt+0x2c>
  8006cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006ce:	89 c3                	mov    %eax,%ebx
  8006d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 50 04             	lea    0x4(%eax),%edx
  8006df:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	75 07                	jne    8006f2 <vprintfmt+0x1b5>
  8006eb:	c7 45 e0 25 1f 80 00 	movl   $0x801f25,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006f2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006f6:	7e 06                	jle    8006fe <vprintfmt+0x1c1>
  8006f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006fc:	75 13                	jne    800711 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800701:	0f be 02             	movsbl (%edx),%eax
  800704:	85 c0                	test   %eax,%eax
  800706:	0f 85 99 00 00 00    	jne    8007a5 <vprintfmt+0x268>
  80070c:	e9 86 00 00 00       	jmp    800797 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800715:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800718:	89 0c 24             	mov    %ecx,(%esp)
  80071b:	e8 1b 03 00 00       	call   800a3b <strnlen>
  800720:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800723:	29 c2                	sub    %eax,%edx
  800725:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e d2                	jle    8006fe <vprintfmt+0x1c1>
					putch(padc, putdat);
  80072c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800730:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800733:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800736:	89 d3                	mov    %edx,%ebx
  800738:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	85 db                	test   %ebx,%ebx
  800749:	7f ed                	jg     800738 <vprintfmt+0x1fb>
  80074b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80074e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800755:	eb a7                	jmp    8006fe <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800757:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075b:	74 18                	je     800775 <vprintfmt+0x238>
  80075d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800760:	83 fa 5e             	cmp    $0x5e,%edx
  800763:	76 10                	jbe    800775 <vprintfmt+0x238>
					putch('?', putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800770:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800773:	eb 0a                	jmp    80077f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800775:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800779:	89 04 24             	mov    %eax,(%esp)
  80077c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800783:	0f be 03             	movsbl (%ebx),%eax
  800786:	85 c0                	test   %eax,%eax
  800788:	74 05                	je     80078f <vprintfmt+0x252>
  80078a:	83 c3 01             	add    $0x1,%ebx
  80078d:	eb 29                	jmp    8007b8 <vprintfmt+0x27b>
  80078f:	89 fe                	mov    %edi,%esi
  800791:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800794:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800797:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079b:	7f 2e                	jg     8007cb <vprintfmt+0x28e>
  80079d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8007a0:	e9 c4 fd ff ff       	jmp    800569 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a8:	83 c2 01             	add    $0x1,%edx
  8007ab:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8007ae:	89 f7                	mov    %esi,%edi
  8007b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007b6:	89 d3                	mov    %edx,%ebx
  8007b8:	85 f6                	test   %esi,%esi
  8007ba:	78 9b                	js     800757 <vprintfmt+0x21a>
  8007bc:	83 ee 01             	sub    $0x1,%esi
  8007bf:	79 96                	jns    800757 <vprintfmt+0x21a>
  8007c1:	89 fe                	mov    %edi,%esi
  8007c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007c9:	eb cc                	jmp    800797 <vprintfmt+0x25a>
  8007cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007dc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007de:	83 eb 01             	sub    $0x1,%ebx
  8007e1:	85 db                	test   %ebx,%ebx
  8007e3:	7f ec                	jg     8007d1 <vprintfmt+0x294>
  8007e5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007e8:	e9 7c fd ff ff       	jmp    800569 <vprintfmt+0x2c>
  8007ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f0:	83 f9 01             	cmp    $0x1,%ecx
  8007f3:	7e 16                	jle    80080b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 08             	lea    0x8(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	8b 10                	mov    (%eax),%edx
  800800:	8b 48 04             	mov    0x4(%eax),%ecx
  800803:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800806:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800809:	eb 32                	jmp    80083d <vprintfmt+0x300>
	else if (lflag)
  80080b:	85 c9                	test   %ecx,%ecx
  80080d:	74 18                	je     800827 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081d:	89 c1                	mov    %eax,%ecx
  80081f:	c1 f9 1f             	sar    $0x1f,%ecx
  800822:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800825:	eb 16                	jmp    80083d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	8d 50 04             	lea    0x4(%eax),%edx
  80082d:	89 55 14             	mov    %edx,0x14(%ebp)
  800830:	8b 00                	mov    (%eax),%eax
  800832:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800835:	89 c2                	mov    %eax,%edx
  800837:	c1 fa 1f             	sar    $0x1f,%edx
  80083a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80083d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800840:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800843:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800848:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80084c:	0f 89 b1 00 00 00    	jns    800903 <vprintfmt+0x3c6>
				putch('-', putdat);
  800852:	89 74 24 04          	mov    %esi,0x4(%esp)
  800856:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80085d:	ff d7                	call   *%edi
				num = -(long long) num;
  80085f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800862:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800865:	f7 d8                	neg    %eax
  800867:	83 d2 00             	adc    $0x0,%edx
  80086a:	f7 da                	neg    %edx
  80086c:	e9 92 00 00 00       	jmp    800903 <vprintfmt+0x3c6>
  800871:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800874:	89 ca                	mov    %ecx,%edx
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
  800879:	e8 68 fc ff ff       	call   8004e6 <getuint>
  80087e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800883:	eb 7e                	jmp    800903 <vprintfmt+0x3c6>
  800885:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800888:	89 ca                	mov    %ecx,%edx
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	e8 54 fc ff ff       	call   8004e6 <getuint>
			if ((long long) num < 0) {
  800892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800895:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800898:	bb 08 00 00 00       	mov    $0x8,%ebx
  80089d:	85 d2                	test   %edx,%edx
  80089f:	79 62                	jns    800903 <vprintfmt+0x3c6>
				putch('-', putdat);
  8008a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008ac:	ff d7                	call   *%edi
				num = -(long long) num;
  8008ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008b4:	f7 d8                	neg    %eax
  8008b6:	83 d2 00             	adc    $0x0,%edx
  8008b9:	f7 da                	neg    %edx
  8008bb:	eb 46                	jmp    800903 <vprintfmt+0x3c6>
  8008bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8008c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008cb:	ff d7                	call   *%edi
			putch('x', putdat);
  8008cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008d8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8d 50 04             	lea    0x4(%eax),%edx
  8008e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e3:	8b 00                	mov    (%eax),%eax
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008ef:	eb 12                	jmp    800903 <vprintfmt+0x3c6>
  8008f1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f4:	89 ca                	mov    %ecx,%edx
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f9:	e8 e8 fb ff ff       	call   8004e6 <getuint>
  8008fe:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800903:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800907:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80090b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80090e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800912:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091d:	89 f2                	mov    %esi,%edx
  80091f:	89 f8                	mov    %edi,%eax
  800921:	e8 ca fa ff ff       	call   8003f0 <printnum>
  800926:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800929:	e9 3b fc ff ff       	jmp    800569 <vprintfmt+0x2c>
  80092e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800931:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800934:	89 74 24 04          	mov    %esi,0x4(%esp)
  800938:	89 14 24             	mov    %edx,(%esp)
  80093b:	ff d7                	call   *%edi
  80093d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800940:	e9 24 fc ff ff       	jmp    800569 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800945:	89 74 24 04          	mov    %esi,0x4(%esp)
  800949:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800950:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800952:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800955:	80 38 25             	cmpb   $0x25,(%eax)
  800958:	0f 84 0b fc ff ff    	je     800569 <vprintfmt+0x2c>
  80095e:	89 c3                	mov    %eax,%ebx
  800960:	eb f0                	jmp    800952 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800962:	83 c4 5c             	add    $0x5c,%esp
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 28             	sub    $0x28,%esp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800976:	85 c0                	test   %eax,%eax
  800978:	74 04                	je     80097e <vsnprintf+0x14>
  80097a:	85 d2                	test   %edx,%edx
  80097c:	7f 07                	jg     800985 <vsnprintf+0x1b>
  80097e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800983:	eb 3b                	jmp    8009c0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800985:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800988:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80098c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800996:	8b 45 14             	mov    0x14(%ebp),%eax
  800999:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099d:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	c7 04 24 20 05 80 00 	movl   $0x800520,(%esp)
  8009b2:	e8 86 fb ff ff       	call   80053d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009c8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	89 04 24             	mov    %eax,(%esp)
  8009e3:	e8 82 ff ff ff       	call   80096a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009f0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	e8 2d fb ff ff       	call   80053d <vprintfmt>
	va_end(ap);
}
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    
	...

00800a20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2e:	74 09                	je     800a39 <strlen+0x19>
		n++;
  800a30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a37:	75 f7                	jne    800a30 <strlen+0x10>
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	85 c9                	test   %ecx,%ecx
  800a47:	74 19                	je     800a62 <strnlen+0x27>
  800a49:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a4c:	74 14                	je     800a62 <strnlen+0x27>
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a53:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a56:	39 c8                	cmp    %ecx,%eax
  800a58:	74 0d                	je     800a67 <strnlen+0x2c>
  800a5a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a5e:	75 f3                	jne    800a53 <strnlen+0x18>
  800a60:	eb 05                	jmp    800a67 <strnlen+0x2c>
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	53                   	push   %ebx
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a80:	83 c2 01             	add    $0x1,%edx
  800a83:	84 c9                	test   %cl,%cl
  800a85:	75 f2                	jne    800a79 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a98:	85 f6                	test   %esi,%esi
  800a9a:	74 18                	je     800ab4 <strncpy+0x2a>
  800a9c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800aa1:	0f b6 1a             	movzbl (%edx),%ebx
  800aa4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa7:	80 3a 01             	cmpb   $0x1,(%edx)
  800aaa:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	39 ce                	cmp    %ecx,%esi
  800ab2:	77 ed                	ja     800aa1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	85 c9                	test   %ecx,%ecx
  800aca:	74 27                	je     800af3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800acc:	83 e9 01             	sub    $0x1,%ecx
  800acf:	74 1d                	je     800aee <strlcpy+0x36>
  800ad1:	0f b6 1a             	movzbl (%edx),%ebx
  800ad4:	84 db                	test   %bl,%bl
  800ad6:	74 16                	je     800aee <strlcpy+0x36>
			*dst++ = *src++;
  800ad8:	88 18                	mov    %bl,(%eax)
  800ada:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800add:	83 e9 01             	sub    $0x1,%ecx
  800ae0:	74 0e                	je     800af0 <strlcpy+0x38>
			*dst++ = *src++;
  800ae2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ae5:	0f b6 1a             	movzbl (%edx),%ebx
  800ae8:	84 db                	test   %bl,%bl
  800aea:	75 ec                	jne    800ad8 <strlcpy+0x20>
  800aec:	eb 02                	jmp    800af0 <strlcpy+0x38>
  800aee:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800af0:	c6 00 00             	movb   $0x0,(%eax)
  800af3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b02:	0f b6 01             	movzbl (%ecx),%eax
  800b05:	84 c0                	test   %al,%al
  800b07:	74 15                	je     800b1e <strcmp+0x25>
  800b09:	3a 02                	cmp    (%edx),%al
  800b0b:	75 11                	jne    800b1e <strcmp+0x25>
		p++, q++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	84 c0                	test   %al,%al
  800b18:	74 04                	je     800b1e <strcmp+0x25>
  800b1a:	3a 02                	cmp    (%edx),%al
  800b1c:	74 ef                	je     800b0d <strcmp+0x14>
  800b1e:	0f b6 c0             	movzbl %al,%eax
  800b21:	0f b6 12             	movzbl (%edx),%edx
  800b24:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	53                   	push   %ebx
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	74 23                	je     800b5c <strncmp+0x34>
  800b39:	0f b6 1a             	movzbl (%edx),%ebx
  800b3c:	84 db                	test   %bl,%bl
  800b3e:	74 24                	je     800b64 <strncmp+0x3c>
  800b40:	3a 19                	cmp    (%ecx),%bl
  800b42:	75 20                	jne    800b64 <strncmp+0x3c>
  800b44:	83 e8 01             	sub    $0x1,%eax
  800b47:	74 13                	je     800b5c <strncmp+0x34>
		n--, p++, q++;
  800b49:	83 c2 01             	add    $0x1,%edx
  800b4c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4f:	0f b6 1a             	movzbl (%edx),%ebx
  800b52:	84 db                	test   %bl,%bl
  800b54:	74 0e                	je     800b64 <strncmp+0x3c>
  800b56:	3a 19                	cmp    (%ecx),%bl
  800b58:	74 ea                	je     800b44 <strncmp+0x1c>
  800b5a:	eb 08                	jmp    800b64 <strncmp+0x3c>
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b64:	0f b6 02             	movzbl (%edx),%eax
  800b67:	0f b6 11             	movzbl (%ecx),%edx
  800b6a:	29 d0                	sub    %edx,%eax
  800b6c:	eb f3                	jmp    800b61 <strncmp+0x39>

00800b6e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	74 15                	je     800b94 <strchr+0x26>
		if (*s == c)
  800b7f:	38 ca                	cmp    %cl,%dl
  800b81:	75 07                	jne    800b8a <strchr+0x1c>
  800b83:	eb 14                	jmp    800b99 <strchr+0x2b>
  800b85:	38 ca                	cmp    %cl,%dl
  800b87:	90                   	nop
  800b88:	74 0f                	je     800b99 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	0f b6 10             	movzbl (%eax),%edx
  800b90:	84 d2                	test   %dl,%dl
  800b92:	75 f1                	jne    800b85 <strchr+0x17>
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba5:	0f b6 10             	movzbl (%eax),%edx
  800ba8:	84 d2                	test   %dl,%dl
  800baa:	74 18                	je     800bc4 <strfind+0x29>
		if (*s == c)
  800bac:	38 ca                	cmp    %cl,%dl
  800bae:	75 0a                	jne    800bba <strfind+0x1f>
  800bb0:	eb 12                	jmp    800bc4 <strfind+0x29>
  800bb2:	38 ca                	cmp    %cl,%dl
  800bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bb8:	74 0a                	je     800bc4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	0f b6 10             	movzbl (%eax),%edx
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 ee                	jne    800bb2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	89 1c 24             	mov    %ebx,(%esp)
  800bcf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be0:	85 c9                	test   %ecx,%ecx
  800be2:	74 30                	je     800c14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bea:	75 25                	jne    800c11 <memset+0x4b>
  800bec:	f6 c1 03             	test   $0x3,%cl
  800bef:	75 20                	jne    800c11 <memset+0x4b>
		c &= 0xFF;
  800bf1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	c1 e3 08             	shl    $0x8,%ebx
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	c1 e6 18             	shl    $0x18,%esi
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	c1 e0 10             	shl    $0x10,%eax
  800c03:	09 f0                	or     %esi,%eax
  800c05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c07:	09 d8                	or     %ebx,%eax
  800c09:	c1 e9 02             	shr    $0x2,%ecx
  800c0c:	fc                   	cld    
  800c0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c0f:	eb 03                	jmp    800c14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c11:	fc                   	cld    
  800c12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c14:	89 f8                	mov    %edi,%eax
  800c16:	8b 1c 24             	mov    (%esp),%ebx
  800c19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c21:	89 ec                	mov    %ebp,%esp
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
  800c2b:	89 34 24             	mov    %esi,(%esp)
  800c2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c3d:	39 c6                	cmp    %eax,%esi
  800c3f:	73 35                	jae    800c76 <memmove+0x51>
  800c41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c44:	39 d0                	cmp    %edx,%eax
  800c46:	73 2e                	jae    800c76 <memmove+0x51>
		s += n;
		d += n;
  800c48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4a:	f6 c2 03             	test   $0x3,%dl
  800c4d:	75 1b                	jne    800c6a <memmove+0x45>
  800c4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c55:	75 13                	jne    800c6a <memmove+0x45>
  800c57:	f6 c1 03             	test   $0x3,%cl
  800c5a:	75 0e                	jne    800c6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c5c:	83 ef 04             	sub    $0x4,%edi
  800c5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c62:	c1 e9 02             	shr    $0x2,%ecx
  800c65:	fd                   	std    
  800c66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c68:	eb 09                	jmp    800c73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c6a:	83 ef 01             	sub    $0x1,%edi
  800c6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c70:	fd                   	std    
  800c71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c74:	eb 20                	jmp    800c96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c7c:	75 15                	jne    800c93 <memmove+0x6e>
  800c7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c84:	75 0d                	jne    800c93 <memmove+0x6e>
  800c86:	f6 c1 03             	test   $0x3,%cl
  800c89:	75 08                	jne    800c93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c8b:	c1 e9 02             	shr    $0x2,%ecx
  800c8e:	fc                   	cld    
  800c8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c91:	eb 03                	jmp    800c96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c93:	fc                   	cld    
  800c94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c96:	8b 34 24             	mov    (%esp),%esi
  800c99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c9d:	89 ec                	mov    %ebp,%esp
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca7:	8b 45 10             	mov    0x10(%ebp),%eax
  800caa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	89 04 24             	mov    %eax,(%esp)
  800cbb:	e8 65 ff ff ff       	call   800c25 <memmove>
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd1:	85 c9                	test   %ecx,%ecx
  800cd3:	74 36                	je     800d0b <memcmp+0x49>
		if (*s1 != *s2)
  800cd5:	0f b6 06             	movzbl (%esi),%eax
  800cd8:	0f b6 1f             	movzbl (%edi),%ebx
  800cdb:	38 d8                	cmp    %bl,%al
  800cdd:	74 20                	je     800cff <memcmp+0x3d>
  800cdf:	eb 14                	jmp    800cf5 <memcmp+0x33>
  800ce1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ce6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ceb:	83 c2 01             	add    $0x1,%edx
  800cee:	83 e9 01             	sub    $0x1,%ecx
  800cf1:	38 d8                	cmp    %bl,%al
  800cf3:	74 12                	je     800d07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cf5:	0f b6 c0             	movzbl %al,%eax
  800cf8:	0f b6 db             	movzbl %bl,%ebx
  800cfb:	29 d8                	sub    %ebx,%eax
  800cfd:	eb 11                	jmp    800d10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cff:	83 e9 01             	sub    $0x1,%ecx
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	85 c9                	test   %ecx,%ecx
  800d09:	75 d6                	jne    800ce1 <memcmp+0x1f>
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d20:	39 d0                	cmp    %edx,%eax
  800d22:	73 15                	jae    800d39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d28:	38 08                	cmp    %cl,(%eax)
  800d2a:	75 06                	jne    800d32 <memfind+0x1d>
  800d2c:	eb 0b                	jmp    800d39 <memfind+0x24>
  800d2e:	38 08                	cmp    %cl,(%eax)
  800d30:	74 07                	je     800d39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d32:	83 c0 01             	add    $0x1,%eax
  800d35:	39 c2                	cmp    %eax,%edx
  800d37:	77 f5                	ja     800d2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4a:	0f b6 02             	movzbl (%edx),%eax
  800d4d:	3c 20                	cmp    $0x20,%al
  800d4f:	74 04                	je     800d55 <strtol+0x1a>
  800d51:	3c 09                	cmp    $0x9,%al
  800d53:	75 0e                	jne    800d63 <strtol+0x28>
		s++;
  800d55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d58:	0f b6 02             	movzbl (%edx),%eax
  800d5b:	3c 20                	cmp    $0x20,%al
  800d5d:	74 f6                	je     800d55 <strtol+0x1a>
  800d5f:	3c 09                	cmp    $0x9,%al
  800d61:	74 f2                	je     800d55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d63:	3c 2b                	cmp    $0x2b,%al
  800d65:	75 0c                	jne    800d73 <strtol+0x38>
		s++;
  800d67:	83 c2 01             	add    $0x1,%edx
  800d6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d71:	eb 15                	jmp    800d88 <strtol+0x4d>
	else if (*s == '-')
  800d73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d7a:	3c 2d                	cmp    $0x2d,%al
  800d7c:	75 0a                	jne    800d88 <strtol+0x4d>
		s++, neg = 1;
  800d7e:	83 c2 01             	add    $0x1,%edx
  800d81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	0f 94 c0             	sete   %al
  800d8d:	74 05                	je     800d94 <strtol+0x59>
  800d8f:	83 fb 10             	cmp    $0x10,%ebx
  800d92:	75 18                	jne    800dac <strtol+0x71>
  800d94:	80 3a 30             	cmpb   $0x30,(%edx)
  800d97:	75 13                	jne    800dac <strtol+0x71>
  800d99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi
  800da0:	75 0a                	jne    800dac <strtol+0x71>
		s += 2, base = 16;
  800da2:	83 c2 02             	add    $0x2,%edx
  800da5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800daa:	eb 15                	jmp    800dc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dac:	84 c0                	test   %al,%al
  800dae:	66 90                	xchg   %ax,%ax
  800db0:	74 0f                	je     800dc1 <strtol+0x86>
  800db2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dba:	75 05                	jne    800dc1 <strtol+0x86>
		s++, base = 8;
  800dbc:	83 c2 01             	add    $0x1,%edx
  800dbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc8:	0f b6 0a             	movzbl (%edx),%ecx
  800dcb:	89 cf                	mov    %ecx,%edi
  800dcd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dd0:	80 fb 09             	cmp    $0x9,%bl
  800dd3:	77 08                	ja     800ddd <strtol+0xa2>
			dig = *s - '0';
  800dd5:	0f be c9             	movsbl %cl,%ecx
  800dd8:	83 e9 30             	sub    $0x30,%ecx
  800ddb:	eb 1e                	jmp    800dfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ddd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800de0:	80 fb 19             	cmp    $0x19,%bl
  800de3:	77 08                	ja     800ded <strtol+0xb2>
			dig = *s - 'a' + 10;
  800de5:	0f be c9             	movsbl %cl,%ecx
  800de8:	83 e9 57             	sub    $0x57,%ecx
  800deb:	eb 0e                	jmp    800dfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ded:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800df0:	80 fb 19             	cmp    $0x19,%bl
  800df3:	77 15                	ja     800e0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dfb:	39 f1                	cmp    %esi,%ecx
  800dfd:	7d 0b                	jge    800e0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800dff:	83 c2 01             	add    $0x1,%edx
  800e02:	0f af c6             	imul   %esi,%eax
  800e05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e08:	eb be                	jmp    800dc8 <strtol+0x8d>
  800e0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e10:	74 05                	je     800e17 <strtol+0xdc>
		*endptr = (char *) s;
  800e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e1b:	74 04                	je     800e21 <strtol+0xe6>
  800e1d:	89 c8                	mov    %ecx,%eax
  800e1f:	f7 d8                	neg    %eax
}
  800e21:	83 c4 04             	add    $0x4,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
  800e29:	00 00                	add    %al,(%eax)
	...

00800e2c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	89 1c 24             	mov    %ebx,(%esp)
  800e35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e39:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 01 00 00 00       	mov    $0x1,%eax
  800e47:	89 d1                	mov    %edx,%ecx
  800e49:	89 d3                	mov    %edx,%ebx
  800e4b:	89 d7                	mov    %edx,%edi
  800e4d:	89 d6                	mov    %edx,%esi
  800e4f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e51:	8b 1c 24             	mov    (%esp),%ebx
  800e54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e5c:	89 ec                	mov    %ebp,%esp
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	89 1c 24             	mov    %ebx,(%esp)
  800e69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	89 c7                	mov    %eax,%edi
  800e80:	89 c6                	mov    %eax,%esi
  800e82:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e84:	8b 1c 24             	mov    (%esp),%ebx
  800e87:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e8b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e8f:	89 ec                	mov    %ebp,%esp
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	83 ec 38             	sub    $0x38,%esp
  800e99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 28                	jle    800ee3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  800ede:	e8 e5 f3 ff ff       	call   8002c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eec:	89 ec                	mov    %ebp,%esp
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	89 1c 24             	mov    %ebx,(%esp)
  800ef9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f01:	be 00 00 00 00       	mov    $0x0,%esi
  800f06:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f19:	8b 1c 24             	mov    (%esp),%ebx
  800f1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f20:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f24:	89 ec                	mov    %ebp,%esp
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 38             	sub    $0x38,%esp
  800f2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f44:	8b 55 08             	mov    0x8(%ebp),%edx
  800f47:	89 df                	mov    %ebx,%edi
  800f49:	89 de                	mov    %ebx,%esi
  800f4b:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	7e 28                	jle    800f79 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f55:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f6c:	00 
  800f6d:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  800f74:	e8 4f f3 ff ff       	call   8002c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f79:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f82:	89 ec                	mov    %ebp,%esp
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 38             	sub    $0x38,%esp
  800f8c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f92:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	89 df                	mov    %ebx,%edi
  800fa7:	89 de                	mov    %ebx,%esi
  800fa9:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 28                	jle    800fd7 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fba:	00 
  800fbb:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fca:	00 
  800fcb:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  800fd2:	e8 f1 f2 ff ff       	call   8002c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe0:	89 ec                	mov    %ebp,%esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 38             	sub    $0x38,%esp
  800fea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	89 df                	mov    %ebx,%edi
  801005:	89 de                	mov    %ebx,%esi
  801007:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7e 28                	jle    801035 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801011:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801018:	00 
  801019:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801028:	00 
  801029:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  801030:	e8 93 f2 ff ff       	call   8002c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801035:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801038:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80103e:	89 ec                	mov    %ebp,%esp
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 38             	sub    $0x38,%esp
  801048:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80104b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80104e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	bb 00 00 00 00       	mov    $0x0,%ebx
  801056:	b8 06 00 00 00       	mov    $0x6,%eax
  80105b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105e:	8b 55 08             	mov    0x8(%ebp),%edx
  801061:	89 df                	mov    %ebx,%edi
  801063:	89 de                	mov    %ebx,%esi
  801065:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	7e 28                	jle    801093 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801076:	00 
  801077:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801086:	00 
  801087:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  80108e:	e8 35 f2 ff ff       	call   8002c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801093:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801096:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801099:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80109c:	89 ec                	mov    %ebp,%esp
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 38             	sub    $0x38,%esp
  8010a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010af:	b8 05 00 00 00       	mov    $0x5,%eax
  8010b4:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c3:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	7e 28                	jle    8010f1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010cd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  8010ec:	e8 d7 f1 ff ff       	call   8002c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010f4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010fa:	89 ec                	mov    %ebp,%esp
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 38             	sub    $0x38,%esp
  801104:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801107:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80110a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110d:	be 00 00 00 00       	mov    $0x0,%esi
  801112:	b8 04 00 00 00       	mov    $0x4,%eax
  801117:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80111a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
  801120:	89 f7                	mov    %esi,%edi
  801122:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801124:	85 c0                	test   %eax,%eax
  801126:	7e 28                	jle    801150 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801128:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801133:	00 
  801134:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  80114b:	e8 78 f1 ff ff       	call   8002c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801150:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801153:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801156:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801159:	89 ec                	mov    %ebp,%esp
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	89 1c 24             	mov    %ebx,(%esp)
  801166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80116a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116e:	ba 00 00 00 00       	mov    $0x0,%edx
  801173:	b8 0b 00 00 00       	mov    $0xb,%eax
  801178:	89 d1                	mov    %edx,%ecx
  80117a:	89 d3                	mov    %edx,%ebx
  80117c:	89 d7                	mov    %edx,%edi
  80117e:	89 d6                	mov    %edx,%esi
  801180:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801182:	8b 1c 24             	mov    (%esp),%ebx
  801185:	8b 74 24 04          	mov    0x4(%esp),%esi
  801189:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80118d:	89 ec                	mov    %ebp,%esp
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	89 1c 24             	mov    %ebx,(%esp)
  80119a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8011ac:	89 d1                	mov    %edx,%ecx
  8011ae:	89 d3                	mov    %edx,%ebx
  8011b0:	89 d7                	mov    %edx,%edi
  8011b2:	89 d6                	mov    %edx,%esi
  8011b4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011b6:	8b 1c 24             	mov    (%esp),%ebx
  8011b9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011c1:	89 ec                	mov    %ebp,%esp
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 38             	sub    $0x38,%esp
  8011cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8011de:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e1:	89 cb                	mov    %ecx,%ebx
  8011e3:	89 cf                	mov    %ecx,%edi
  8011e5:	89 ce                	mov    %ecx,%esi
  8011e7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	7e 28                	jle    801215 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011f8:	00 
  8011f9:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  801200:	00 
  801201:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801208:	00 
  801209:	c7 04 24 1c 22 80 00 	movl   $0x80221c,(%esp)
  801210:	e8 b3 f0 ff ff       	call   8002c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801215:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801218:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80121b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80121e:	89 ec                	mov    %ebp,%esp
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    
	...

00801230 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	05 00 00 00 30       	add    $0x30000000,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 df ff ff ff       	call   801230 <fd2num>
  801251:	05 20 00 0d 00       	add    $0xd0020,%eax
  801256:	c1 e0 0c             	shl    $0xc,%eax
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	57                   	push   %edi
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  801264:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801269:	a8 01                	test   $0x1,%al
  80126b:	74 36                	je     8012a3 <fd_alloc+0x48>
  80126d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801272:	a8 01                	test   $0x1,%al
  801274:	74 2d                	je     8012a3 <fd_alloc+0x48>
  801276:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80127b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801280:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801285:	89 c3                	mov    %eax,%ebx
  801287:	89 c2                	mov    %eax,%edx
  801289:	c1 ea 16             	shr    $0x16,%edx
  80128c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 14                	je     8012a8 <fd_alloc+0x4d>
  801294:	89 c2                	mov    %eax,%edx
  801296:	c1 ea 0c             	shr    $0xc,%edx
  801299:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80129c:	f6 c2 01             	test   $0x1,%dl
  80129f:	75 10                	jne    8012b1 <fd_alloc+0x56>
  8012a1:	eb 05                	jmp    8012a8 <fd_alloc+0x4d>
  8012a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8012a8:	89 1f                	mov    %ebx,(%edi)
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8012af:	eb 17                	jmp    8012c8 <fd_alloc+0x6d>
  8012b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bb:	75 c8                	jne    801285 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8012c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	83 f8 1f             	cmp    $0x1f,%eax
  8012d6:	77 36                	ja     80130e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	c1 ea 16             	shr    $0x16,%edx
  8012e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ec:	f6 c2 01             	test   $0x1,%dl
  8012ef:	74 1d                	je     80130e <fd_lookup+0x41>
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	c1 ea 0c             	shr    $0xc,%edx
  8012f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fd:	f6 c2 01             	test   $0x1,%dl
  801300:	74 0c                	je     80130e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	89 02                	mov    %eax,(%edx)
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80130c:	eb 05                	jmp    801313 <fd_lookup+0x46>
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80131e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	e8 a0 ff ff ff       	call   8012cd <fd_lookup>
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 0e                	js     80133f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801331:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801334:	8b 55 0c             	mov    0xc(%ebp),%edx
  801337:	89 50 04             	mov    %edx,0x4(%eax)
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 10             	sub    $0x10,%esp
  801349:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80134f:	b8 08 50 80 00       	mov    $0x805008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801354:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801359:	be ac 22 80 00       	mov    $0x8022ac,%esi
		if (devtab[i]->dev_id == dev_id) {
  80135e:	39 08                	cmp    %ecx,(%eax)
  801360:	75 10                	jne    801372 <dev_lookup+0x31>
  801362:	eb 04                	jmp    801368 <dev_lookup+0x27>
  801364:	39 08                	cmp    %ecx,(%eax)
  801366:	75 0a                	jne    801372 <dev_lookup+0x31>
			*dev = devtab[i];
  801368:	89 03                	mov    %eax,(%ebx)
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80136f:	90                   	nop
  801370:	eb 31                	jmp    8013a3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801372:	83 c2 01             	add    $0x1,%edx
  801375:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801378:	85 c0                	test   %eax,%eax
  80137a:	75 e8                	jne    801364 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  80137c:	a1 24 50 80 00       	mov    0x805024,%eax
  801381:	8b 40 4c             	mov    0x4c(%eax),%eax
  801384:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138c:	c7 04 24 2c 22 80 00 	movl   $0x80222c,(%esp)
  801393:	e8 f5 ef ff ff       	call   80038d <cprintf>
	*dev = 0;
  801398:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	5b                   	pop    %ebx
  8013a7:	5e                   	pop    %esi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 24             	sub    $0x24,%esp
  8013b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	e8 07 ff ff ff       	call   8012cd <fd_lookup>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 53                	js     80141d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	8b 00                	mov    (%eax),%eax
  8013d6:	89 04 24             	mov    %eax,(%esp)
  8013d9:	e8 63 ff ff ff       	call   801341 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 3b                	js     80141d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ea:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013ee:	74 2d                	je     80141d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013fa:	00 00 00 
	stat->st_isdir = 0;
  8013fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801404:	00 00 00 
	stat->st_dev = dev;
  801407:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801410:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801414:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801417:	89 14 24             	mov    %edx,(%esp)
  80141a:	ff 50 14             	call   *0x14(%eax)
}
  80141d:	83 c4 24             	add    $0x24,%esp
  801420:	5b                   	pop    %ebx
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	83 ec 24             	sub    $0x24,%esp
  80142a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801430:	89 44 24 04          	mov    %eax,0x4(%esp)
  801434:	89 1c 24             	mov    %ebx,(%esp)
  801437:	e8 91 fe ff ff       	call   8012cd <fd_lookup>
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 5f                	js     80149f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801440:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144a:	8b 00                	mov    (%eax),%eax
  80144c:	89 04 24             	mov    %eax,(%esp)
  80144f:	e8 ed fe ff ff       	call   801341 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801454:	85 c0                	test   %eax,%eax
  801456:	78 47                	js     80149f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801458:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80145f:	75 23                	jne    801484 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  801461:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801466:	8b 40 4c             	mov    0x4c(%eax),%eax
  801469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	c7 04 24 4c 22 80 00 	movl   $0x80224c,(%esp)
  801478:	e8 10 ef ff ff       	call   80038d <cprintf>
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  801482:	eb 1b                	jmp    80149f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801484:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801487:	8b 48 18             	mov    0x18(%eax),%ecx
  80148a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80148f:	85 c9                	test   %ecx,%ecx
  801491:	74 0c                	je     80149f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801493:	8b 45 0c             	mov    0xc(%ebp),%eax
  801496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149a:	89 14 24             	mov    %edx,(%esp)
  80149d:	ff d1                	call   *%ecx
}
  80149f:	83 c4 24             	add    $0x24,%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 24             	sub    $0x24,%esp
  8014ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	89 1c 24             	mov    %ebx,(%esp)
  8014b9:	e8 0f fe ff ff       	call   8012cd <fd_lookup>
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 66                	js     801528 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cc:	8b 00                	mov    (%eax),%eax
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	e8 6b fe ff ff       	call   801341 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 4e                	js     801528 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014dd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014e1:	75 23                	jne    801506 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  8014e3:	a1 24 50 80 00       	mov    0x805024,%eax
  8014e8:	8b 40 4c             	mov    0x4c(%eax),%eax
  8014eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f3:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
  8014fa:	e8 8e ee ff ff       	call   80038d <cprintf>
  8014ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801504:	eb 22                	jmp    801528 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801509:	8b 48 0c             	mov    0xc(%eax),%ecx
  80150c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801511:	85 c9                	test   %ecx,%ecx
  801513:	74 13                	je     801528 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801515:	8b 45 10             	mov    0x10(%ebp),%eax
  801518:	89 44 24 08          	mov    %eax,0x8(%esp)
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801523:	89 14 24             	mov    %edx,(%esp)
  801526:	ff d1                	call   *%ecx
}
  801528:	83 c4 24             	add    $0x24,%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 24             	sub    $0x24,%esp
  801535:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801538:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153f:	89 1c 24             	mov    %ebx,(%esp)
  801542:	e8 86 fd ff ff       	call   8012cd <fd_lookup>
  801547:	85 c0                	test   %eax,%eax
  801549:	78 6b                	js     8015b6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	8b 00                	mov    (%eax),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 e2 fd ff ff       	call   801341 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 53                	js     8015b6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801563:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801566:	8b 42 08             	mov    0x8(%edx),%eax
  801569:	83 e0 03             	and    $0x3,%eax
  80156c:	83 f8 01             	cmp    $0x1,%eax
  80156f:	75 23                	jne    801594 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  801571:	a1 24 50 80 00       	mov    0x805024,%eax
  801576:	8b 40 4c             	mov    0x4c(%eax),%eax
  801579:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80157d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801581:	c7 04 24 8d 22 80 00 	movl   $0x80228d,(%esp)
  801588:	e8 00 ee ff ff       	call   80038d <cprintf>
  80158d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801592:	eb 22                	jmp    8015b6 <read+0x88>
	}
	if (!dev->dev_read)
  801594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801597:	8b 48 08             	mov    0x8(%eax),%ecx
  80159a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80159f:	85 c9                	test   %ecx,%ecx
  8015a1:	74 13                	je     8015b6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8015a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b1:	89 14 24             	mov    %edx,(%esp)
  8015b4:	ff d1                	call   *%ecx
}
  8015b6:	83 c4 24             	add    $0x24,%esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	57                   	push   %edi
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 1c             	sub    $0x1c,%esp
  8015c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015da:	85 f6                	test   %esi,%esi
  8015dc:	74 29                	je     801607 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015de:	89 f0                	mov    %esi,%eax
  8015e0:	29 d0                	sub    %edx,%eax
  8015e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e6:	03 55 0c             	add    0xc(%ebp),%edx
  8015e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015ed:	89 3c 24             	mov    %edi,(%esp)
  8015f0:	e8 39 ff ff ff       	call   80152e <read>
		if (m < 0)
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 0e                	js     801607 <readn+0x4b>
			return m;
		if (m == 0)
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	74 08                	je     801605 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fd:	01 c3                	add    %eax,%ebx
  8015ff:	89 da                	mov    %ebx,%edx
  801601:	39 f3                	cmp    %esi,%ebx
  801603:	72 d9                	jb     8015de <readn+0x22>
  801605:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801607:	83 c4 1c             	add    $0x1c,%esp
  80160a:	5b                   	pop    %ebx
  80160b:	5e                   	pop    %esi
  80160c:	5f                   	pop    %edi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 20             	sub    $0x20,%esp
  801617:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80161a:	89 34 24             	mov    %esi,(%esp)
  80161d:	e8 0e fc ff ff       	call   801230 <fd2num>
  801622:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801625:	89 54 24 04          	mov    %edx,0x4(%esp)
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 9c fc ff ff       	call   8012cd <fd_lookup>
  801631:	89 c3                	mov    %eax,%ebx
  801633:	85 c0                	test   %eax,%eax
  801635:	78 05                	js     80163c <fd_close+0x2d>
  801637:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80163a:	74 0c                	je     801648 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80163c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801640:	19 c0                	sbb    %eax,%eax
  801642:	f7 d0                	not    %eax
  801644:	21 c3                	and    %eax,%ebx
  801646:	eb 3d                	jmp    801685 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 06                	mov    (%esi),%eax
  801651:	89 04 24             	mov    %eax,(%esp)
  801654:	e8 e8 fc ff ff       	call   801341 <dev_lookup>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 16                	js     801675 <fd_close+0x66>
		if (dev->dev_close)
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	8b 40 10             	mov    0x10(%eax),%eax
  801665:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166a:	85 c0                	test   %eax,%eax
  80166c:	74 07                	je     801675 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80166e:	89 34 24             	mov    %esi,(%esp)
  801671:	ff d0                	call   *%eax
  801673:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801675:	89 74 24 04          	mov    %esi,0x4(%esp)
  801679:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801680:	e8 bd f9 ff ff       	call   801042 <sys_page_unmap>
	return r;
}
  801685:	89 d8                	mov    %ebx,%eax
  801687:	83 c4 20             	add    $0x20,%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801694:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	89 04 24             	mov    %eax,(%esp)
  8016a1:	e8 27 fc ff ff       	call   8012cd <fd_lookup>
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 13                	js     8016bd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016b1:	00 
  8016b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 52 ff ff ff       	call   80160f <fd_close>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 18             	sub    $0x18,%esp
  8016c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016d2:	00 
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 4d 03 00 00       	call   801a2b <open>
  8016de:	89 c3                	mov    %eax,%ebx
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	78 1b                	js     8016ff <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016eb:	89 1c 24             	mov    %ebx,(%esp)
  8016ee:	e8 b7 fc ff ff       	call   8013aa <fstat>
  8016f3:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f5:	89 1c 24             	mov    %ebx,(%esp)
  8016f8:	e8 91 ff ff ff       	call   80168e <close>
  8016fd:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016ff:	89 d8                	mov    %ebx,%eax
  801701:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801704:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801707:	89 ec                	mov    %ebp,%esp
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	83 ec 14             	sub    $0x14,%esp
  801712:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801717:	89 1c 24             	mov    %ebx,(%esp)
  80171a:	e8 6f ff ff ff       	call   80168e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80171f:	83 c3 01             	add    $0x1,%ebx
  801722:	83 fb 20             	cmp    $0x20,%ebx
  801725:	75 f0                	jne    801717 <close_all+0xc>
		close(i);
}
  801727:	83 c4 14             	add    $0x14,%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 58             	sub    $0x58,%esp
  801733:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801736:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801739:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80173c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80173f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801742:	89 44 24 04          	mov    %eax,0x4(%esp)
  801746:	8b 45 08             	mov    0x8(%ebp),%eax
  801749:	89 04 24             	mov    %eax,(%esp)
  80174c:	e8 7c fb ff ff       	call   8012cd <fd_lookup>
  801751:	89 c3                	mov    %eax,%ebx
  801753:	85 c0                	test   %eax,%eax
  801755:	0f 88 e0 00 00 00    	js     80183b <dup+0x10e>
		return r;
	close(newfdnum);
  80175b:	89 3c 24             	mov    %edi,(%esp)
  80175e:	e8 2b ff ff ff       	call   80168e <close>

	newfd = INDEX2FD(newfdnum);
  801763:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801769:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80176c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	e8 c9 fa ff ff       	call   801240 <fd2data>
  801777:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801779:	89 34 24             	mov    %esi,(%esp)
  80177c:	e8 bf fa ff ff       	call   801240 <fd2data>
  801781:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801784:	89 da                	mov    %ebx,%edx
  801786:	89 d8                	mov    %ebx,%eax
  801788:	c1 e8 16             	shr    $0x16,%eax
  80178b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801792:	a8 01                	test   $0x1,%al
  801794:	74 43                	je     8017d9 <dup+0xac>
  801796:	c1 ea 0c             	shr    $0xc,%edx
  801799:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017a0:	a8 01                	test   $0x1,%al
  8017a2:	74 35                	je     8017d9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  8017a4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8017b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017c2:	00 
  8017c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ce:	e8 cd f8 ff ff       	call   8010a0 <sys_page_map>
  8017d3:	89 c3                	mov    %eax,%ebx
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 3f                	js     801818 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  8017d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	c1 ea 0c             	shr    $0xc,%edx
  8017e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017e8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fd:	00 
  8017fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801809:	e8 92 f8 ff ff       	call   8010a0 <sys_page_map>
  80180e:	89 c3                	mov    %eax,%ebx
  801810:	85 c0                	test   %eax,%eax
  801812:	78 04                	js     801818 <dup+0xeb>
  801814:	89 fb                	mov    %edi,%ebx
  801816:	eb 23                	jmp    80183b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801818:	89 74 24 04          	mov    %esi,0x4(%esp)
  80181c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801823:	e8 1a f8 ff ff       	call   801042 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801828:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80182b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801836:	e8 07 f8 ff ff       	call   801042 <sys_page_unmap>
	return r;
}
  80183b:	89 d8                	mov    %ebx,%eax
  80183d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801840:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801843:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801846:	89 ec                	mov    %ebp,%esp
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    
  80184a:	00 00                	add    %al,(%eax)
  80184c:	00 00                	add    %al,(%eax)
	...

00801850 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 14             	sub    $0x14,%esp
  801857:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801859:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  80185f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801866:	00 
  801867:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80186e:	00 
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	89 14 24             	mov    %edx,(%esp)
  801876:	e8 31 02 00 00       	call   801aac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80187b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801882:	00 
  801883:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801887:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80188e:	e8 83 02 00 00       	call   801b16 <ipc_recv>
}
  801893:	83 c4 14             	add    $0x14,%esp
  801896:	5b                   	pop    %ebx
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a5:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  8018aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ad:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8018bc:	e8 8f ff ff ff       	call   801850 <fsipc>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cf:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018de:	e8 6d ff ff ff       	call   801850 <fsipc>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f5:	e8 56 ff ff ff       	call   801850 <fsipc>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	53                   	push   %ebx
  801900:	83 ec 14             	sub    $0x14,%esp
  801903:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	b8 05 00 00 00       	mov    $0x5,%eax
  80191b:	e8 30 ff ff ff       	call   801850 <fsipc>
  801920:	85 c0                	test   %eax,%eax
  801922:	78 2b                	js     80194f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801924:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  80192b:	00 
  80192c:	89 1c 24             	mov    %ebx,(%esp)
  80192f:	e8 36 f1 ff ff       	call   800a6a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801934:	a1 80 30 80 00       	mov    0x803080,%eax
  801939:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80193f:	a1 84 30 80 00       	mov    0x803084,%eax
  801944:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80194a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80194f:	83 c4 14             	add    $0x14,%esp
  801952:	5b                   	pop    %ebx
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 18             	sub    $0x18,%esp
  80195b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80195e:	8b 55 08             	mov    0x8(%ebp),%edx
  801961:	8b 52 0c             	mov    0xc(%edx),%edx
  801964:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  80196a:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80196f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801973:	8b 45 0c             	mov    0xc(%ebp),%eax
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801981:	e8 9f f2 ff ff       	call   800c25 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801986:	ba 00 30 80 00       	mov    $0x803000,%edx
  80198b:	b8 04 00 00 00       	mov    $0x4,%eax
  801990:	e8 bb fe ff ff       	call   801850 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	53                   	push   %ebx
  80199b:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a4:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  8019a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ac:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  8019b1:	ba 00 30 80 00       	mov    $0x803000,%edx
  8019b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019bb:	e8 90 fe ff ff       	call   801850 <fsipc>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 17                	js     8019dd <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  8019c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ca:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  8019d1:	00 
  8019d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d5:	89 04 24             	mov    %eax,(%esp)
  8019d8:	e8 48 f2 ff ff       	call   800c25 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  8019dd:	89 d8                	mov    %ebx,%eax
  8019df:	83 c4 14             	add    $0x14,%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 14             	sub    $0x14,%esp
  8019ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019ef:	89 1c 24             	mov    %ebx,(%esp)
  8019f2:	e8 29 f0 ff ff       	call   800a20 <strlen>
  8019f7:	89 c2                	mov    %eax,%edx
  8019f9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8019fe:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801a04:	7f 1f                	jg     801a25 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a11:	e8 54 f0 ff ff       	call   800a6a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	b8 07 00 00 00       	mov    $0x7,%eax
  801a20:	e8 2b fe ff ff       	call   801850 <fsipc>
}
  801a25:	83 c4 14             	add    $0x14,%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  801a31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	e8 1f f8 ff ff       	call   80125b <fd_alloc>
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 6a                	js     801aaa <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a47:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801a4e:	e8 17 f0 ff ff       	call   800a6a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a56:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a5b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801a60:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a67:	00 
  801a68:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801a6f:	00 
  801a70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a77:	00 
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 2c 00 00 00       	call   801aac <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801a80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a87:	00 
  801a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a96:	e8 7b 00 00 00       	call   801b16 <ipc_recv>
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 0b                	js     801aaa <open+0x7f>
		return r;
	return fd2num(fd);
  801a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 86 f7 ff ff       	call   801230 <fd2num>
	panic("open not implemented");
}
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	57                   	push   %edi
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
  801ab5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801abb:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	75 31                	jne    801af3 <ipc_send+0x47>
  801ac2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ac7:	eb 2a                	jmp    801af3 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  801ac9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801acc:	74 20                	je     801aee <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  801ace:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad2:	c7 44 24 08 b4 22 80 	movl   $0x8022b4,0x8(%esp)
  801ad9:	00 
  801ada:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801ae1:	00 
  801ae2:	c7 04 24 cb 22 80 00 	movl   $0x8022cb,(%esp)
  801ae9:	e8 da e7 ff ff       	call   8002c8 <_panic>


                sys_yield();
  801aee:	e8 6a f6 ff ff       	call   80115d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801af3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801af7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801afb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 e6 f3 ff ff       	call   800ef0 <sys_ipc_try_send>
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 bb                	js     801ac9 <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801b0e:	83 c4 1c             	add    $0x1c,%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	56                   	push   %esi
  801b1a:	53                   	push   %ebx
  801b1b:	83 ec 10             	sub    $0x10,%esp
  801b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b24:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  801b27:	85 c0                	test   %eax,%eax
  801b29:	75 05                	jne    801b30 <ipc_recv+0x1a>
  801b2b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801b30:	89 04 24             	mov    %eax,(%esp)
  801b33:	e8 5b f3 ff ff       	call   800e93 <sys_ipc_recv>
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 24                	js     801b60 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801b3c:	85 db                	test   %ebx,%ebx
  801b3e:	74 0a                	je     801b4a <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801b40:	a1 24 50 80 00       	mov    0x805024,%eax
  801b45:	8b 40 74             	mov    0x74(%eax),%eax
  801b48:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  801b4a:	85 f6                	test   %esi,%esi
  801b4c:	74 0a                	je     801b58 <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801b4e:	a1 24 50 80 00       	mov    0x805024,%eax
  801b53:	8b 40 78             	mov    0x78(%eax),%eax
  801b56:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  801b58:	a1 24 50 80 00       	mov    0x805024,%eax
  801b5d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    
	...

00801b70 <__udivdi3>:
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	83 ec 10             	sub    $0x10,%esp
  801b78:	8b 45 14             	mov    0x14(%ebp),%eax
  801b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b7e:	8b 75 10             	mov    0x10(%ebp),%esi
  801b81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b84:	85 c0                	test   %eax,%eax
  801b86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801b89:	75 35                	jne    801bc0 <__udivdi3+0x50>
  801b8b:	39 fe                	cmp    %edi,%esi
  801b8d:	77 61                	ja     801bf0 <__udivdi3+0x80>
  801b8f:	85 f6                	test   %esi,%esi
  801b91:	75 0b                	jne    801b9e <__udivdi3+0x2e>
  801b93:	b8 01 00 00 00       	mov    $0x1,%eax
  801b98:	31 d2                	xor    %edx,%edx
  801b9a:	f7 f6                	div    %esi
  801b9c:	89 c6                	mov    %eax,%esi
  801b9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ba1:	31 d2                	xor    %edx,%edx
  801ba3:	89 f8                	mov    %edi,%eax
  801ba5:	f7 f6                	div    %esi
  801ba7:	89 c7                	mov    %eax,%edi
  801ba9:	89 c8                	mov    %ecx,%eax
  801bab:	f7 f6                	div    %esi
  801bad:	89 c1                	mov    %eax,%ecx
  801baf:	89 fa                	mov    %edi,%edx
  801bb1:	89 c8                	mov    %ecx,%eax
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	39 f8                	cmp    %edi,%eax
  801bc2:	77 1c                	ja     801be0 <__udivdi3+0x70>
  801bc4:	0f bd d0             	bsr    %eax,%edx
  801bc7:	83 f2 1f             	xor    $0x1f,%edx
  801bca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801bcd:	75 39                	jne    801c08 <__udivdi3+0x98>
  801bcf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801bd2:	0f 86 a0 00 00 00    	jbe    801c78 <__udivdi3+0x108>
  801bd8:	39 f8                	cmp    %edi,%eax
  801bda:	0f 82 98 00 00 00    	jb     801c78 <__udivdi3+0x108>
  801be0:	31 ff                	xor    %edi,%edi
  801be2:	31 c9                	xor    %ecx,%ecx
  801be4:	89 c8                	mov    %ecx,%eax
  801be6:	89 fa                	mov    %edi,%edx
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    
  801bef:	90                   	nop
  801bf0:	89 d1                	mov    %edx,%ecx
  801bf2:	89 fa                	mov    %edi,%edx
  801bf4:	89 c8                	mov    %ecx,%eax
  801bf6:	31 ff                	xor    %edi,%edi
  801bf8:	f7 f6                	div    %esi
  801bfa:	89 c1                	mov    %eax,%ecx
  801bfc:	89 fa                	mov    %edi,%edx
  801bfe:	89 c8                	mov    %ecx,%eax
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    
  801c07:	90                   	nop
  801c08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	d3 e0                	shl    %cl,%eax
  801c10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c13:	b8 20 00 00 00       	mov    $0x20,%eax
  801c18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801c1b:	89 c1                	mov    %eax,%ecx
  801c1d:	d3 ea                	shr    %cl,%edx
  801c1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c23:	0b 55 ec             	or     -0x14(%ebp),%edx
  801c26:	d3 e6                	shl    %cl,%esi
  801c28:	89 c1                	mov    %eax,%ecx
  801c2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801c2d:	89 fe                	mov    %edi,%esi
  801c2f:	d3 ee                	shr    %cl,%esi
  801c31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c3b:	d3 e7                	shl    %cl,%edi
  801c3d:	89 c1                	mov    %eax,%ecx
  801c3f:	d3 ea                	shr    %cl,%edx
  801c41:	09 d7                	or     %edx,%edi
  801c43:	89 f2                	mov    %esi,%edx
  801c45:	89 f8                	mov    %edi,%eax
  801c47:	f7 75 ec             	divl   -0x14(%ebp)
  801c4a:	89 d6                	mov    %edx,%esi
  801c4c:	89 c7                	mov    %eax,%edi
  801c4e:	f7 65 e8             	mull   -0x18(%ebp)
  801c51:	39 d6                	cmp    %edx,%esi
  801c53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c56:	72 30                	jb     801c88 <__udivdi3+0x118>
  801c58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c5f:	d3 e2                	shl    %cl,%edx
  801c61:	39 c2                	cmp    %eax,%edx
  801c63:	73 05                	jae    801c6a <__udivdi3+0xfa>
  801c65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801c68:	74 1e                	je     801c88 <__udivdi3+0x118>
  801c6a:	89 f9                	mov    %edi,%ecx
  801c6c:	31 ff                	xor    %edi,%edi
  801c6e:	e9 71 ff ff ff       	jmp    801be4 <__udivdi3+0x74>
  801c73:	90                   	nop
  801c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801c7f:	e9 60 ff ff ff       	jmp    801be4 <__udivdi3+0x74>
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801c8b:	31 ff                	xor    %edi,%edi
  801c8d:	89 c8                	mov    %ecx,%eax
  801c8f:	89 fa                	mov    %edi,%edx
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
	...

00801ca0 <__umoddi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	57                   	push   %edi
  801ca4:	56                   	push   %esi
  801ca5:	83 ec 20             	sub    $0x20,%esp
  801ca8:	8b 55 14             	mov    0x14(%ebp),%edx
  801cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cae:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cb4:	85 d2                	test   %edx,%edx
  801cb6:	89 c8                	mov    %ecx,%eax
  801cb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cbb:	75 13                	jne    801cd0 <__umoddi3+0x30>
  801cbd:	39 f7                	cmp    %esi,%edi
  801cbf:	76 3f                	jbe    801d00 <__umoddi3+0x60>
  801cc1:	89 f2                	mov    %esi,%edx
  801cc3:	f7 f7                	div    %edi
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	31 d2                	xor    %edx,%edx
  801cc9:	83 c4 20             	add    $0x20,%esp
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    
  801cd0:	39 f2                	cmp    %esi,%edx
  801cd2:	77 4c                	ja     801d20 <__umoddi3+0x80>
  801cd4:	0f bd ca             	bsr    %edx,%ecx
  801cd7:	83 f1 1f             	xor    $0x1f,%ecx
  801cda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cdd:	75 51                	jne    801d30 <__umoddi3+0x90>
  801cdf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801ce2:	0f 87 e0 00 00 00    	ja     801dc8 <__umoddi3+0x128>
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	29 f8                	sub    %edi,%eax
  801ced:	19 d6                	sbb    %edx,%esi
  801cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	83 c4 20             	add    $0x20,%esp
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    
  801cfe:	66 90                	xchg   %ax,%ax
  801d00:	85 ff                	test   %edi,%edi
  801d02:	75 0b                	jne    801d0f <__umoddi3+0x6f>
  801d04:	b8 01 00 00 00       	mov    $0x1,%eax
  801d09:	31 d2                	xor    %edx,%edx
  801d0b:	f7 f7                	div    %edi
  801d0d:	89 c7                	mov    %eax,%edi
  801d0f:	89 f0                	mov    %esi,%eax
  801d11:	31 d2                	xor    %edx,%edx
  801d13:	f7 f7                	div    %edi
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	f7 f7                	div    %edi
  801d1a:	eb a9                	jmp    801cc5 <__umoddi3+0x25>
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 20             	add    $0x20,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d34:	d3 e2                	shl    %cl,%edx
  801d36:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d39:	ba 20 00 00 00       	mov    $0x20,%edx
  801d3e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d41:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d44:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	d3 ea                	shr    %cl,%edx
  801d4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d50:	0b 55 f4             	or     -0xc(%ebp),%edx
  801d53:	d3 e7                	shl    %cl,%edi
  801d55:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d59:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d5c:	89 f2                	mov    %esi,%edx
  801d5e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	d3 ea                	shr    %cl,%edx
  801d65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	d3 e6                	shl    %cl,%esi
  801d70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d74:	d3 ea                	shr    %cl,%edx
  801d76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d7a:	09 d6                	or     %edx,%esi
  801d7c:	89 f0                	mov    %esi,%eax
  801d7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801d81:	d3 e7                	shl    %cl,%edi
  801d83:	89 f2                	mov    %esi,%edx
  801d85:	f7 75 f4             	divl   -0xc(%ebp)
  801d88:	89 d6                	mov    %edx,%esi
  801d8a:	f7 65 e8             	mull   -0x18(%ebp)
  801d8d:	39 d6                	cmp    %edx,%esi
  801d8f:	72 2b                	jb     801dbc <__umoddi3+0x11c>
  801d91:	39 c7                	cmp    %eax,%edi
  801d93:	72 23                	jb     801db8 <__umoddi3+0x118>
  801d95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d99:	29 c7                	sub    %eax,%edi
  801d9b:	19 d6                	sbb    %edx,%esi
  801d9d:	89 f0                	mov    %esi,%eax
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	d3 ef                	shr    %cl,%edi
  801da3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dad:	09 f8                	or     %edi,%eax
  801daf:	d3 ea                	shr    %cl,%edx
  801db1:	83 c4 20             	add    $0x20,%esp
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    
  801db8:	39 d6                	cmp    %edx,%esi
  801dba:	75 d9                	jne    801d95 <__umoddi3+0xf5>
  801dbc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801dbf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801dc2:	eb d1                	jmp    801d95 <__umoddi3+0xf5>
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	39 f2                	cmp    %esi,%edx
  801dca:	0f 82 18 ff ff ff    	jb     801ce8 <__umoddi3+0x48>
  801dd0:	e9 1d ff ff ff       	jmp    801cf2 <__umoddi3+0x52>
