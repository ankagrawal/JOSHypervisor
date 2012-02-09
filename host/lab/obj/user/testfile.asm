
obj/user/testfile:     file format elf32-i386


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
  80002c:	e8 b7 05 00 00       	call   8005e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;

	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800048:	e8 bd 0d 00 00       	call   800e0a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 34 80 00    	mov    %ebx,0x803400
	ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800053:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800058:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80005f:	00 
  800060:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  800067:	00 
  800068:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80006f:	00 
  800070:	89 04 24             	mov    %eax,(%esp)
  800073:	e8 4c 15 00 00       	call   8015c4 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800078:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80007f:	00 
  800080:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800087:	cc 
  800088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008f:	e8 9a 15 00 00       	call   80162e <ipc_recv>
}
  800094:	83 c4 14             	add    $0x14,%esp
  800097:	5b                   	pop    %ebx
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <umain>:

void
umain(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	53                   	push   %ebx
  80009e:	81 ec c4 02 00 00    	sub    $0x2c4,%esp
	struct Fd *fd;
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];
	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000a9:	b8 80 21 80 00       	mov    $0x802180,%eax
  8000ae:	e8 81 ff ff ff       	call   800034 <xopen>
  8000b3:	85 c0                	test   %eax,%eax
  8000b5:	79 25                	jns    8000dc <umain+0x42>
  8000b7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000ba:	74 3c                	je     8000f8 <umain+0x5e>
		panic("serve_open /not-found: %e", r);
  8000bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c0:	c7 44 24 08 8b 21 80 	movl   $0x80218b,0x8(%esp)
  8000c7:	00 
  8000c8:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000cf:	00 
  8000d0:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8000d7:	e8 90 05 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000dc:	c7 44 24 08 1c 23 80 	movl   $0x80231c,0x8(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000eb:	00 
  8000ec:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8000f3:	e8 74 05 00 00       	call   80066c <_panic>
	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 b5 21 80 00       	mov    $0x8021b5,%eax
  800102:	e8 2d ff ff ff       	call   800034 <xopen>
  800107:	85 c0                	test   %eax,%eax
  800109:	79 20                	jns    80012b <umain+0x91>
		panic("serve_open /newmotd: %e", r);
  80010b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010f:	c7 44 24 08 be 21 80 	movl   $0x8021be,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800126:	e8 41 05 00 00       	call   80066c <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  80012b:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  800132:	75 12                	jne    800146 <umain+0xac>
  800134:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  80013b:	75 09                	jne    800146 <umain+0xac>
  80013d:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800144:	74 1c                	je     800162 <umain+0xc8>
		panic("serve_open did not fill struct Fd correctly\n");
  800146:	c7 44 24 08 40 23 80 	movl   $0x802340,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  80015d:	e8 0a 05 00 00       	call   80066c <_panic>
	cprintf("serve_open is good\n");
  800162:	c7 04 24 d6 21 80 00 	movl   $0x8021d6,(%esp)
  800169:	e8 c3 05 00 00       	call   800731 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80016e:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80017f:	ff 15 20 50 80 00    	call   *0x805020
  800185:	85 c0                	test   %eax,%eax
  800187:	79 20                	jns    8001a9 <umain+0x10f>
		panic("file_stat: %e", r);
  800189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018d:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  800194:	00 
  800195:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80019c:	00 
  80019d:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8001a4:	e8 c3 04 00 00       	call   80066c <_panic>
	if (strlen(msg) != st.st_size)
  8001a9:	a1 00 50 80 00       	mov    0x805000,%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 0a 0c 00 00       	call   800dc0 <strlen>
  8001b6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  8001b9:	74 34                	je     8001ef <umain+0x155>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001bb:	a1 00 50 80 00       	mov    0x805000,%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 f8 0b 00 00       	call   800dc0 <strlen>
  8001c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d3:	c7 44 24 08 70 23 80 	movl   $0x802370,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8001ea:	e8 7d 04 00 00       	call   80066c <_panic>
	cprintf("file_stat is good\n");
  8001ef:	c7 04 24 f8 21 80 00 	movl   $0x8021f8,(%esp)
  8001f6:	e8 36 05 00 00       	call   800731 <cprintf>
	cprintf("offset in umain %x\n",FVA->fd_offset);
  8001fb:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	c7 04 24 0b 22 80 00 	movl   $0x80220b,(%esp)
  80020b:	e8 21 05 00 00       	call   800731 <cprintf>
	memset(buf, 0, sizeof buf);
  800210:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021f:	00 
  800220:	8d 9d 5c fd ff ff    	lea    -0x2a4(%ebp),%ebx
  800226:	89 1c 24             	mov    %ebx,(%esp)
  800229:	e8 38 0d 00 00       	call   800f66 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80022e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800235:	00 
  800236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80023a:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800241:	ff 15 14 50 80 00    	call   *0x805014
  800247:	85 c0                	test   %eax,%eax
  800249:	79 20                	jns    80026b <umain+0x1d1>
		panic("file_read: %e", r);
  80024b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024f:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800266:	e8 01 04 00 00       	call   80066c <_panic>
	if (strcmp(buf, msg) != 0)
  80026b:	a1 00 50 80 00       	mov    0x805000,%eax
  800270:	89 44 24 04          	mov    %eax,0x4(%esp)
  800274:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	e8 17 0c 00 00       	call   800e99 <strcmp>
  800282:	85 c0                	test   %eax,%eax
  800284:	74 1c                	je     8002a2 <umain+0x208>
		panic("file_read returned wrong data");
  800286:	c7 44 24 08 2d 22 80 	movl   $0x80222d,0x8(%esp)
  80028d:	00 
  80028e:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800295:	00 
  800296:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  80029d:	e8 ca 03 00 00       	call   80066c <_panic>
	cprintf("file_read is good\n");
  8002a2:	c7 04 24 4b 22 80 00 	movl   $0x80224b,(%esp)
  8002a9:	e8 83 04 00 00       	call   800731 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002ae:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002b5:	ff 15 1c 50 80 00    	call   *0x80501c
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	79 20                	jns    8002df <umain+0x245>
		panic("file_close: %e", r);
  8002bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c3:	c7 44 24 08 5e 22 80 	movl   $0x80225e,0x8(%esp)
  8002ca:	00 
  8002cb:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8002d2:	00 
  8002d3:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8002da:	e8 8d 03 00 00       	call   80066c <_panic>
	cprintf("file_close is good\n");
  8002df:	c7 04 24 6d 22 80 00 	movl   $0x80226d,(%esp)
  8002e6:	e8 46 04 00 00       	call   800731 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002eb:	b8 00 c0 cc cc       	mov    $0xccccc000,%eax
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002f5:	8b 50 04             	mov    0x4(%eax),%edx
  8002f8:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8002fb:	8b 50 08             	mov    0x8(%eax),%edx
  8002fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800301:	8b 40 0c             	mov    0xc(%eax),%eax
  800304:	89 45 f4             	mov    %eax,-0xc(%ebp)
	sys_page_unmap(0, FVA);
  800307:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80030e:	cc 
  80030f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800316:	e8 c7 10 00 00       	call   8013e2 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80031b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800322:	00 
  800323:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 15 14 50 80 00    	call   *0x805014
  800339:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80033c:	74 20                	je     80035e <umain+0x2c4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80033e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800342:	c7 44 24 08 98 23 80 	movl   $0x802398,0x8(%esp)
  800349:	00 
  80034a:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800351:	00 
  800352:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800359:	e8 0e 03 00 00       	call   80066c <_panic>
	cprintf("stale fileid is good\n");
  80035e:	c7 04 24 81 22 80 00 	movl   $0x802281,(%esp)
  800365:	e8 c7 03 00 00       	call   800731 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80036a:	ba 02 01 00 00       	mov    $0x102,%edx
  80036f:	b8 97 22 80 00       	mov    $0x802297,%eax
  800374:	e8 bb fc ff ff       	call   800034 <xopen>
  800379:	85 c0                	test   %eax,%eax
  80037b:	79 20                	jns    80039d <umain+0x303>
		panic("serve_open /new-file: %e", r);
  80037d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800381:	c7 44 24 08 a1 22 80 	movl   $0x8022a1,0x8(%esp)
  800388:	00 
  800389:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  800390:	00 
  800391:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800398:	e8 cf 02 00 00       	call   80066c <_panic>
	cprintf("writing %s\n", msg);
  80039d:	a1 00 50 80 00       	mov    0x805000,%eax
  8003a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a6:	c7 04 24 ba 22 80 00 	movl   $0x8022ba,(%esp)
  8003ad:	e8 7f 03 00 00       	call   800731 <cprintf>
	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8003b2:	8b 1d 18 50 80 00    	mov    0x805018,%ebx
  8003b8:	a1 00 50 80 00       	mov    0x805000,%eax
  8003bd:	89 04 24             	mov    %eax,(%esp)
  8003c0:	e8 fb 09 00 00       	call   800dc0 <strlen>
  8003c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c9:	a1 00 50 80 00       	mov    0x805000,%eax
  8003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003d9:	ff d3                	call   *%ebx
  8003db:	89 c3                	mov    %eax,%ebx
  8003dd:	a1 00 50 80 00       	mov    0x805000,%eax
  8003e2:	89 04 24             	mov    %eax,(%esp)
  8003e5:	e8 d6 09 00 00       	call   800dc0 <strlen>
  8003ea:	39 c3                	cmp    %eax,%ebx
  8003ec:	74 20                	je     80040e <umain+0x374>
		panic("file_write: %e", r);
  8003ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f2:	c7 44 24 08 c6 22 80 	movl   $0x8022c6,0x8(%esp)
  8003f9:	00 
  8003fa:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800401:	00 
  800402:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800409:	e8 5e 02 00 00       	call   80066c <_panic>
	cprintf("file_write is good\n");
  80040e:	c7 04 24 d5 22 80 00 	movl   $0x8022d5,(%esp)
  800415:	e8 17 03 00 00       	call   800731 <cprintf>

	FVA->fd_offset = 0;
  80041a:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800421:	00 00 00 
	memset(buf, 0, sizeof buf);
  800424:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80042b:	00 
  80042c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800433:	00 
  800434:	8d 9d 5c fd ff ff    	lea    -0x2a4(%ebp),%ebx
  80043a:	89 1c 24             	mov    %ebx,(%esp)
  80043d:	e8 24 0b 00 00       	call   800f66 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800442:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800449:	00 
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800455:	ff 15 14 50 80 00    	call   *0x805014
  80045b:	89 c3                	mov    %eax,%ebx
  80045d:	85 c0                	test   %eax,%eax
  80045f:	79 20                	jns    800481 <umain+0x3e7>
		panic("file_read after file_write: %e", r);
  800461:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800465:	c7 44 24 08 d0 23 80 	movl   $0x8023d0,0x8(%esp)
  80046c:	00 
  80046d:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800474:	00 
  800475:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  80047c:	e8 eb 01 00 00       	call   80066c <_panic>
	if (r != strlen(msg))
  800481:	a1 00 50 80 00       	mov    0x805000,%eax
  800486:	89 04 24             	mov    %eax,(%esp)
  800489:	e8 32 09 00 00       	call   800dc0 <strlen>
  80048e:	39 c3                	cmp    %eax,%ebx
  800490:	74 20                	je     8004b2 <umain+0x418>
		panic("file_read after file_write returned wrong length: %d", r);
  800492:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800496:	c7 44 24 08 f0 23 80 	movl   $0x8023f0,0x8(%esp)
  80049d:	00 
  80049e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8004a5:	00 
  8004a6:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8004ad:	e8 ba 01 00 00       	call   80066c <_panic>
	if (strcmp(buf, msg) != 0)
  8004b2:	a1 00 50 80 00       	mov    0x805000,%eax
  8004b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bb:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 d0 09 00 00       	call   800e99 <strcmp>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 32                	je     8004ff <umain+0x465>
	{
		cprintf("read after write %s\n", buf);
  8004cd:	8d 85 5c fd ff ff    	lea    -0x2a4(%ebp),%eax
  8004d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d7:	c7 04 24 e9 22 80 00 	movl   $0x8022e9,(%esp)
  8004de:	e8 4e 02 00 00       	call   800731 <cprintf>
		panic("file_read after file_write returned wrong data");
  8004e3:	c7 44 24 08 28 24 80 	movl   $0x802428,0x8(%esp)
  8004ea:	00 
  8004eb:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8004f2:	00 
  8004f3:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8004fa:	e8 6d 01 00 00       	call   80066c <_panic>
	}
	cprintf("file_read after file_write is good\n");
  8004ff:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  800506:	e8 26 02 00 00       	call   800731 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80050b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800512:	00 
  800513:	c7 04 24 80 21 80 00 	movl   $0x802180,(%esp)
  80051a:	e8 5c 19 00 00       	call   801e7b <open>
  80051f:	85 c0                	test   %eax,%eax
  800521:	79 25                	jns    800548 <umain+0x4ae>
  800523:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800526:	74 3c                	je     800564 <umain+0x4ca>
		panic("open /not-found: %e", r);
  800528:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052c:	c7 44 24 08 91 21 80 	movl   $0x802191,0x8(%esp)
  800533:	00 
  800534:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80053b:	00 
  80053c:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800543:	e8 24 01 00 00       	call   80066c <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800548:	c7 44 24 08 fe 22 80 	movl   $0x8022fe,0x8(%esp)
  80054f:	00 
  800550:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800557:	00 
  800558:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  80055f:	e8 08 01 00 00       	call   80066c <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800564:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80056b:	00 
  80056c:	c7 04 24 b5 21 80 00 	movl   $0x8021b5,(%esp)
  800573:	e8 03 19 00 00       	call   801e7b <open>
  800578:	85 c0                	test   %eax,%eax
  80057a:	79 20                	jns    80059c <umain+0x502>
		panic("open /newmotd: %e", r);
  80057c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800580:	c7 44 24 08 c4 21 80 	movl   $0x8021c4,0x8(%esp)
  800587:	00 
  800588:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80058f:	00 
  800590:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  800597:	e8 d0 00 00 00       	call   80066c <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80059c:	05 00 00 0d 00       	add    $0xd0000,%eax
  8005a1:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  8005a4:	83 38 66             	cmpl   $0x66,(%eax)
  8005a7:	75 0c                	jne    8005b5 <umain+0x51b>
  8005a9:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  8005ad:	75 06                	jne    8005b5 <umain+0x51b>
  8005af:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8005b3:	74 1c                	je     8005d1 <umain+0x537>
		panic("open did not fill struct Fd correctly\n");
  8005b5:	c7 44 24 08 7c 24 80 	movl   $0x80247c,0x8(%esp)
  8005bc:	00 
  8005bd:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8005c4:	00 
  8005c5:	c7 04 24 a5 21 80 00 	movl   $0x8021a5,(%esp)
  8005cc:	e8 9b 00 00 00       	call   80066c <_panic>
	cprintf("open is good\n");
  8005d1:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  8005d8:	e8 54 01 00 00       	call   800731 <cprintf>
}
  8005dd:	81 c4 c4 02 00 00    	add    $0x2c4,%esp
  8005e3:	5b                   	pop    %ebx
  8005e4:	5d                   	pop    %ebp
  8005e5:	c3                   	ret    
	...

008005e8 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
  8005ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005f1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  8005fa:	c7 05 28 50 80 00 00 	movl   $0x0,0x805028
  800601:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  800604:	e8 28 0f 00 00       	call   801531 <sys_getenvid>
  800609:	25 ff 03 00 00       	and    $0x3ff,%eax
  80060e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800611:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800616:	a3 28 50 80 00       	mov    %eax,0x805028

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80061b:	85 f6                	test   %esi,%esi
  80061d:	7e 07                	jle    800626 <libmain+0x3e>
		binaryname = argv[0];
  80061f:	8b 03                	mov    (%ebx),%eax
  800621:	a3 04 50 80 00       	mov    %eax,0x805004

	// call user main routine
	cprintf("calling here1234\n");
  800626:	c7 04 24 ca 24 80 00 	movl   $0x8024ca,(%esp)
  80062d:	e8 ff 00 00 00       	call   800731 <cprintf>
	umain(argc, argv);
  800632:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800636:	89 34 24             	mov    %esi,(%esp)
  800639:	e8 5c fa ff ff       	call   80009a <umain>

	// exit gracefully
	exit();
  80063e:	e8 0d 00 00 00       	call   800650 <exit>
}
  800643:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800646:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800649:	89 ec                	mov    %ebp,%esp
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    
  80064d:	00 00                	add    %al,(%eax)
	...

00800650 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800656:	e8 00 15 00 00       	call   801b5b <close_all>
	sys_env_destroy(0);
  80065b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800662:	e8 fe 0e 00 00       	call   801565 <sys_env_destroy>
}
  800667:	c9                   	leave  
  800668:	c3                   	ret    
  800669:	00 00                	add    %al,(%eax)
	...

0080066c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	53                   	push   %ebx
  800670:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  800673:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800676:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	74 10                	je     80068f <_panic+0x23>
		cprintf("%s: ", argv0);
  80067f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800683:	c7 04 24 f3 24 80 00 	movl   $0x8024f3,(%esp)
  80068a:	e8 a2 00 00 00       	call   800731 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80068f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800692:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069d:	a1 04 50 80 00       	mov    0x805004,%eax
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  8006ad:	e8 7f 00 00 00       	call   800731 <cprintf>
	vcprintf(fmt, ap);
  8006b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 0f 00 00 00       	call   8006d0 <vcprintf>
	cprintf("\n");
  8006c1:	c7 04 24 da 24 80 00 	movl   $0x8024da,(%esp)
  8006c8:	e8 64 00 00 00       	call   800731 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cd:	cc                   	int3   
  8006ce:	eb fd                	jmp    8006cd <_panic+0x61>

008006d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006e0:	00 00 00 
	b.cnt = 0;
  8006e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800701:	89 44 24 04          	mov    %eax,0x4(%esp)
  800705:	c7 04 24 4b 07 80 00 	movl   $0x80074b,(%esp)
  80070c:	e8 cc 01 00 00       	call   8008dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800711:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800721:	89 04 24             	mov    %eax,(%esp)
  800724:	e8 d7 0a 00 00       	call   801200 <sys_cputs>

	return b.cnt;
}
  800729:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800737:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80073a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	e8 87 ff ff ff       	call   8006d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	83 ec 14             	sub    $0x14,%esp
  800752:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800755:	8b 03                	mov    (%ebx),%eax
  800757:	8b 55 08             	mov    0x8(%ebp),%edx
  80075a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80075e:	83 c0 01             	add    $0x1,%eax
  800761:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800763:	3d ff 00 00 00       	cmp    $0xff,%eax
  800768:	75 19                	jne    800783 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80076a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800771:	00 
  800772:	8d 43 08             	lea    0x8(%ebx),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 83 0a 00 00       	call   801200 <sys_cputs>
		b->idx = 0;
  80077d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800783:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800787:	83 c4 14             	add    $0x14,%esp
  80078a:	5b                   	pop    %ebx
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    
  80078d:	00 00                	add    %al,(%eax)
	...

00800790 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	57                   	push   %edi
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	83 ec 4c             	sub    $0x4c,%esp
  800799:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079c:	89 d6                	mov    %edx,%esi
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bb:	39 d1                	cmp    %edx,%ecx
  8007bd:	72 15                	jb     8007d4 <printnum+0x44>
  8007bf:	77 07                	ja     8007c8 <printnum+0x38>
  8007c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c4:	39 d0                	cmp    %edx,%eax
  8007c6:	76 0c                	jbe    8007d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c8:	83 eb 01             	sub    $0x1,%ebx
  8007cb:	85 db                	test   %ebx,%ebx
  8007cd:	8d 76 00             	lea    0x0(%esi),%esi
  8007d0:	7f 61                	jg     800833 <printnum+0xa3>
  8007d2:	eb 70                	jmp    800844 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007d8:	83 eb 01             	sub    $0x1,%ebx
  8007db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8007e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8007eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8007ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8007f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007ff:	00 
  800800:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800809:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080d:	e8 ee 16 00 00       	call   801f00 <__udivdi3>
  800812:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800815:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800818:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80081c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	89 54 24 04          	mov    %edx,0x4(%esp)
  800827:	89 f2                	mov    %esi,%edx
  800829:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80082c:	e8 5f ff ff ff       	call   800790 <printnum>
  800831:	eb 11                	jmp    800844 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800833:	89 74 24 04          	mov    %esi,0x4(%esp)
  800837:	89 3c 24             	mov    %edi,(%esp)
  80083a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80083d:	83 eb 01             	sub    $0x1,%ebx
  800840:	85 db                	test   %ebx,%ebx
  800842:	7f ef                	jg     800833 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800844:	89 74 24 04          	mov    %esi,0x4(%esp)
  800848:	8b 74 24 04          	mov    0x4(%esp),%esi
  80084c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80084f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800853:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80085a:	00 
  80085b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80085e:	89 14 24             	mov    %edx,(%esp)
  800861:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800864:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800868:	e8 c3 17 00 00       	call   802030 <__umoddi3>
  80086d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800871:	0f be 80 14 25 80 00 	movsbl 0x802514(%eax),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80087e:	83 c4 4c             	add    $0x4c,%esp
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800889:	83 fa 01             	cmp    $0x1,%edx
  80088c:	7e 0e                	jle    80089c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80088e:	8b 10                	mov    (%eax),%edx
  800890:	8d 4a 08             	lea    0x8(%edx),%ecx
  800893:	89 08                	mov    %ecx,(%eax)
  800895:	8b 02                	mov    (%edx),%eax
  800897:	8b 52 04             	mov    0x4(%edx),%edx
  80089a:	eb 22                	jmp    8008be <getuint+0x38>
	else if (lflag)
  80089c:	85 d2                	test   %edx,%edx
  80089e:	74 10                	je     8008b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008a5:	89 08                	mov    %ecx,(%eax)
  8008a7:	8b 02                	mov    (%edx),%eax
  8008a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ae:	eb 0e                	jmp    8008be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8008b0:	8b 10                	mov    (%eax),%edx
  8008b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008b5:	89 08                	mov    %ecx,(%eax)
  8008b7:	8b 02                	mov    (%edx),%eax
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8008c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8008ca:	8b 10                	mov    (%eax),%edx
  8008cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8008cf:	73 0a                	jae    8008db <sprintputch+0x1b>
		*b->buf++ = ch;
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	88 0a                	mov    %cl,(%edx)
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	89 10                	mov    %edx,(%eax)
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	83 ec 5c             	sub    $0x5c,%esp
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008f6:	eb 11                	jmp    800909 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	0f 84 02 04 00 00    	je     800d02 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  800900:	89 74 24 04          	mov    %esi,0x4(%esp)
  800904:	89 04 24             	mov    %eax,(%esp)
  800907:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800909:	0f b6 03             	movzbl (%ebx),%eax
  80090c:	83 c3 01             	add    $0x1,%ebx
  80090f:	83 f8 25             	cmp    $0x25,%eax
  800912:	75 e4                	jne    8008f8 <vprintfmt+0x1b>
  800914:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800918:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80091f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800926:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	eb 06                	jmp    80093a <vprintfmt+0x5d>
  800934:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800938:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093a:	0f b6 13             	movzbl (%ebx),%edx
  80093d:	0f b6 c2             	movzbl %dl,%eax
  800940:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800943:	8d 43 01             	lea    0x1(%ebx),%eax
  800946:	83 ea 23             	sub    $0x23,%edx
  800949:	80 fa 55             	cmp    $0x55,%dl
  80094c:	0f 87 93 03 00 00    	ja     800ce5 <vprintfmt+0x408>
  800952:	0f b6 d2             	movzbl %dl,%edx
  800955:	ff 24 95 60 26 80 00 	jmp    *0x802660(,%edx,4)
  80095c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800960:	eb d6                	jmp    800938 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800962:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800965:	83 ea 30             	sub    $0x30,%edx
  800968:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80096b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80096e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800971:	83 fb 09             	cmp    $0x9,%ebx
  800974:	77 4c                	ja     8009c2 <vprintfmt+0xe5>
  800976:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800979:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80097c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80097f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800982:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800986:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800989:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80098c:	83 fb 09             	cmp    $0x9,%ebx
  80098f:	76 eb                	jbe    80097c <vprintfmt+0x9f>
  800991:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800994:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800997:	eb 29                	jmp    8009c2 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800999:	8b 55 14             	mov    0x14(%ebp),%edx
  80099c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80099f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8009a2:	8b 12                	mov    (%edx),%edx
  8009a4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8009a7:	eb 19                	jmp    8009c2 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  8009a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ac:	c1 fa 1f             	sar    $0x1f,%edx
  8009af:	f7 d2                	not    %edx
  8009b1:	21 55 e4             	and    %edx,-0x1c(%ebp)
  8009b4:	eb 82                	jmp    800938 <vprintfmt+0x5b>
  8009b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8009bd:	e9 76 ff ff ff       	jmp    800938 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8009c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009c6:	0f 89 6c ff ff ff    	jns    800938 <vprintfmt+0x5b>
  8009cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8009d5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009d8:	e9 5b ff ff ff       	jmp    800938 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8009e0:	e9 53 ff ff ff       	jmp    800938 <vprintfmt+0x5b>
  8009e5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8d 50 04             	lea    0x4(%eax),%edx
  8009ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f5:	8b 00                	mov    (%eax),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	ff d7                	call   *%edi
  8009fc:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8009ff:	e9 05 ff ff ff       	jmp    800909 <vprintfmt+0x2c>
  800a04:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a07:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0a:	8d 50 04             	lea    0x4(%eax),%edx
  800a0d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a10:	8b 00                	mov    (%eax),%eax
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	c1 fa 1f             	sar    $0x1f,%edx
  800a17:	31 d0                	xor    %edx,%eax
  800a19:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800a1b:	83 f8 0f             	cmp    $0xf,%eax
  800a1e:	7f 0b                	jg     800a2b <vprintfmt+0x14e>
  800a20:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800a27:	85 d2                	test   %edx,%edx
  800a29:	75 20                	jne    800a4b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  800a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2f:	c7 44 24 08 25 25 80 	movl   $0x802525,0x8(%esp)
  800a36:	00 
  800a37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3b:	89 3c 24             	mov    %edi,(%esp)
  800a3e:	e8 47 03 00 00       	call   800d8a <printfmt>
  800a43:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800a46:	e9 be fe ff ff       	jmp    800909 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800a4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a4f:	c7 44 24 08 2e 25 80 	movl   $0x80252e,0x8(%esp)
  800a56:	00 
  800a57:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5b:	89 3c 24             	mov    %edi,(%esp)
  800a5e:	e8 27 03 00 00       	call   800d8a <printfmt>
  800a63:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800a66:	e9 9e fe ff ff       	jmp    800909 <vprintfmt+0x2c>
  800a6b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800a73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a76:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a79:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7c:	8d 50 04             	lea    0x4(%eax),%edx
  800a7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a82:	8b 00                	mov    (%eax),%eax
  800a84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	75 07                	jne    800a92 <vprintfmt+0x1b5>
  800a8b:	c7 45 e0 31 25 80 00 	movl   $0x802531,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a92:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800a96:	7e 06                	jle    800a9e <vprintfmt+0x1c1>
  800a98:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a9c:	75 13                	jne    800ab1 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800aa1:	0f be 02             	movsbl (%edx),%eax
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	0f 85 99 00 00 00    	jne    800b45 <vprintfmt+0x268>
  800aac:	e9 86 00 00 00       	jmp    800b37 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ab5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ab8:	89 0c 24             	mov    %ecx,(%esp)
  800abb:	e8 1b 03 00 00       	call   800ddb <strnlen>
  800ac0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800ac3:	29 c2                	sub    %eax,%edx
  800ac5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ac8:	85 d2                	test   %edx,%edx
  800aca:	7e d2                	jle    800a9e <vprintfmt+0x1c1>
					putch(padc, putdat);
  800acc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800ad0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ad3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800adc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800adf:	89 04 24             	mov    %eax,(%esp)
  800ae2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ae4:	83 eb 01             	sub    $0x1,%ebx
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	7f ed                	jg     800ad8 <vprintfmt+0x1fb>
  800aeb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800aee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800af5:	eb a7                	jmp    800a9e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800af7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800afb:	74 18                	je     800b15 <vprintfmt+0x238>
  800afd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800b00:	83 fa 5e             	cmp    $0x5e,%edx
  800b03:	76 10                	jbe    800b15 <vprintfmt+0x238>
					putch('?', putdat);
  800b05:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b09:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b10:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b13:	eb 0a                	jmp    800b1f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800b15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b19:	89 04 24             	mov    %eax,(%esp)
  800b1c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b23:	0f be 03             	movsbl (%ebx),%eax
  800b26:	85 c0                	test   %eax,%eax
  800b28:	74 05                	je     800b2f <vprintfmt+0x252>
  800b2a:	83 c3 01             	add    $0x1,%ebx
  800b2d:	eb 29                	jmp    800b58 <vprintfmt+0x27b>
  800b2f:	89 fe                	mov    %edi,%esi
  800b31:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800b34:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b3b:	7f 2e                	jg     800b6b <vprintfmt+0x28e>
  800b3d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800b40:	e9 c4 fd ff ff       	jmp    800909 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b45:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800b4e:	89 f7                	mov    %esi,%edi
  800b50:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b53:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	85 f6                	test   %esi,%esi
  800b5a:	78 9b                	js     800af7 <vprintfmt+0x21a>
  800b5c:	83 ee 01             	sub    $0x1,%esi
  800b5f:	79 96                	jns    800af7 <vprintfmt+0x21a>
  800b61:	89 fe                	mov    %edi,%esi
  800b63:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800b66:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b69:	eb cc                	jmp    800b37 <vprintfmt+0x25a>
  800b6b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800b6e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b75:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b7c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b7e:	83 eb 01             	sub    $0x1,%ebx
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	7f ec                	jg     800b71 <vprintfmt+0x294>
  800b85:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800b88:	e9 7c fd ff ff       	jmp    800909 <vprintfmt+0x2c>
  800b8d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b90:	83 f9 01             	cmp    $0x1,%ecx
  800b93:	7e 16                	jle    800bab <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  800b95:	8b 45 14             	mov    0x14(%ebp),%eax
  800b98:	8d 50 08             	lea    0x8(%eax),%edx
  800b9b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b9e:	8b 10                	mov    (%eax),%edx
  800ba0:	8b 48 04             	mov    0x4(%eax),%ecx
  800ba3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800ba6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ba9:	eb 32                	jmp    800bdd <vprintfmt+0x300>
	else if (lflag)
  800bab:	85 c9                	test   %ecx,%ecx
  800bad:	74 18                	je     800bc7 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  800baf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb2:	8d 50 04             	lea    0x4(%eax),%edx
  800bb5:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb8:	8b 00                	mov    (%eax),%eax
  800bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bbd:	89 c1                	mov    %eax,%ecx
  800bbf:	c1 f9 1f             	sar    $0x1f,%ecx
  800bc2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bc5:	eb 16                	jmp    800bdd <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 50 04             	lea    0x4(%eax),%edx
  800bcd:	89 55 14             	mov    %edx,0x14(%ebp)
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bd5:	89 c2                	mov    %eax,%edx
  800bd7:	c1 fa 1f             	sar    $0x1f,%edx
  800bda:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800be0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800be3:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800be8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bec:	0f 89 b1 00 00 00    	jns    800ca3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800bf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bfd:	ff d7                	call   *%edi
				num = -(long long) num;
  800bff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c02:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c05:	f7 d8                	neg    %eax
  800c07:	83 d2 00             	adc    $0x0,%edx
  800c0a:	f7 da                	neg    %edx
  800c0c:	e9 92 00 00 00       	jmp    800ca3 <vprintfmt+0x3c6>
  800c11:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c14:	89 ca                	mov    %ecx,%edx
  800c16:	8d 45 14             	lea    0x14(%ebp),%eax
  800c19:	e8 68 fc ff ff       	call   800886 <getuint>
  800c1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800c23:	eb 7e                	jmp    800ca3 <vprintfmt+0x3c6>
  800c25:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800c28:	89 ca                	mov    %ecx,%edx
  800c2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c2d:	e8 54 fc ff ff       	call   800886 <getuint>
			if ((long long) num < 0) {
  800c32:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c35:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c38:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c3d:	85 d2                	test   %edx,%edx
  800c3f:	79 62                	jns    800ca3 <vprintfmt+0x3c6>
				putch('-', putdat);
  800c41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c45:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c4c:	ff d7                	call   *%edi
				num = -(long long) num;
  800c4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c51:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c54:	f7 d8                	neg    %eax
  800c56:	83 d2 00             	adc    $0x0,%edx
  800c59:	f7 da                	neg    %edx
  800c5b:	eb 46                	jmp    800ca3 <vprintfmt+0x3c6>
  800c5d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800c60:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c64:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c6b:	ff d7                	call   *%edi
			putch('x', putdat);
  800c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c71:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c78:	ff d7                	call   *%edi
			num = (unsigned long long)
  800c7a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7d:	8d 50 04             	lea    0x4(%eax),%edx
  800c80:	89 55 14             	mov    %edx,0x14(%ebp)
  800c83:	8b 00                	mov    (%eax),%eax
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c8f:	eb 12                	jmp    800ca3 <vprintfmt+0x3c6>
  800c91:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c94:	89 ca                	mov    %ecx,%edx
  800c96:	8d 45 14             	lea    0x14(%ebp),%eax
  800c99:	e8 e8 fb ff ff       	call   800886 <getuint>
  800c9e:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ca3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800ca7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800cae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cb6:	89 04 24             	mov    %eax,(%esp)
  800cb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cbd:	89 f2                	mov    %esi,%edx
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	e8 ca fa ff ff       	call   800790 <printnum>
  800cc6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800cc9:	e9 3b fc ff ff       	jmp    800909 <vprintfmt+0x2c>
  800cce:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800cd1:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd8:	89 14 24             	mov    %edx,(%esp)
  800cdb:	ff d7                	call   *%edi
  800cdd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800ce0:	e9 24 fc ff ff       	jmp    800909 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ce5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800cf0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800cf2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cf5:	80 38 25             	cmpb   $0x25,(%eax)
  800cf8:	0f 84 0b fc ff ff    	je     800909 <vprintfmt+0x2c>
  800cfe:	89 c3                	mov    %eax,%ebx
  800d00:	eb f0                	jmp    800cf2 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  800d02:	83 c4 5c             	add    $0x5c,%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 28             	sub    $0x28,%esp
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	74 04                	je     800d1e <vsnprintf+0x14>
  800d1a:	85 d2                	test   %edx,%edx
  800d1c:	7f 07                	jg     800d25 <vsnprintf+0x1b>
  800d1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d23:	eb 3b                	jmp    800d60 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d28:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800d2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d36:	8b 45 14             	mov    0x14(%ebp),%eax
  800d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d44:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4b:	c7 04 24 c0 08 80 00 	movl   $0x8008c0,(%esp)
  800d52:	e8 86 fb ff ff       	call   8008dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d5a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d68:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d72:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	89 04 24             	mov    %eax,(%esp)
  800d83:	e8 82 ff ff ff       	call   800d0a <vsnprintf>
	va_end(ap);

	return rc;
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d90:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d93:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d97:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	89 04 24             	mov    %eax,(%esp)
  800dab:	e8 2d fb ff ff       	call   8008dd <vprintfmt>
	va_end(ap);
}
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    
	...

00800dc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800dce:	74 09                	je     800dd9 <strlen+0x19>
		n++;
  800dd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dd7:	75 f7                	jne    800dd0 <strlen+0x10>
		n++;
	return n;
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de5:	85 c9                	test   %ecx,%ecx
  800de7:	74 19                	je     800e02 <strnlen+0x27>
  800de9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800dec:	74 14                	je     800e02 <strnlen+0x27>
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800df3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800df6:	39 c8                	cmp    %ecx,%eax
  800df8:	74 0d                	je     800e07 <strnlen+0x2c>
  800dfa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dfe:	75 f3                	jne    800df3 <strnlen+0x18>
  800e00:	eb 05                	jmp    800e07 <strnlen+0x2c>
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	84 c9                	test   %cl,%cl
  800e25:	75 f2                	jne    800e19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e35:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e38:	85 f6                	test   %esi,%esi
  800e3a:	74 18                	je     800e54 <strncpy+0x2a>
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e41:	0f b6 1a             	movzbl (%edx),%ebx
  800e44:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e47:	80 3a 01             	cmpb   $0x1,(%edx)
  800e4a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e4d:	83 c1 01             	add    $0x1,%ecx
  800e50:	39 ce                	cmp    %ecx,%esi
  800e52:	77 ed                	ja     800e41 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
  800e5d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e66:	89 f0                	mov    %esi,%eax
  800e68:	85 c9                	test   %ecx,%ecx
  800e6a:	74 27                	je     800e93 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e6c:	83 e9 01             	sub    $0x1,%ecx
  800e6f:	74 1d                	je     800e8e <strlcpy+0x36>
  800e71:	0f b6 1a             	movzbl (%edx),%ebx
  800e74:	84 db                	test   %bl,%bl
  800e76:	74 16                	je     800e8e <strlcpy+0x36>
			*dst++ = *src++;
  800e78:	88 18                	mov    %bl,(%eax)
  800e7a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e7d:	83 e9 01             	sub    $0x1,%ecx
  800e80:	74 0e                	je     800e90 <strlcpy+0x38>
			*dst++ = *src++;
  800e82:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e85:	0f b6 1a             	movzbl (%edx),%ebx
  800e88:	84 db                	test   %bl,%bl
  800e8a:	75 ec                	jne    800e78 <strlcpy+0x20>
  800e8c:	eb 02                	jmp    800e90 <strlcpy+0x38>
  800e8e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e90:	c6 00 00             	movb   $0x0,(%eax)
  800e93:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ea2:	0f b6 01             	movzbl (%ecx),%eax
  800ea5:	84 c0                	test   %al,%al
  800ea7:	74 15                	je     800ebe <strcmp+0x25>
  800ea9:	3a 02                	cmp    (%edx),%al
  800eab:	75 11                	jne    800ebe <strcmp+0x25>
		p++, q++;
  800ead:	83 c1 01             	add    $0x1,%ecx
  800eb0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800eb3:	0f b6 01             	movzbl (%ecx),%eax
  800eb6:	84 c0                	test   %al,%al
  800eb8:	74 04                	je     800ebe <strcmp+0x25>
  800eba:	3a 02                	cmp    (%edx),%al
  800ebc:	74 ef                	je     800ead <strcmp+0x14>
  800ebe:	0f b6 c0             	movzbl %al,%eax
  800ec1:	0f b6 12             	movzbl (%edx),%edx
  800ec4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	53                   	push   %ebx
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	74 23                	je     800efc <strncmp+0x34>
  800ed9:	0f b6 1a             	movzbl (%edx),%ebx
  800edc:	84 db                	test   %bl,%bl
  800ede:	74 24                	je     800f04 <strncmp+0x3c>
  800ee0:	3a 19                	cmp    (%ecx),%bl
  800ee2:	75 20                	jne    800f04 <strncmp+0x3c>
  800ee4:	83 e8 01             	sub    $0x1,%eax
  800ee7:	74 13                	je     800efc <strncmp+0x34>
		n--, p++, q++;
  800ee9:	83 c2 01             	add    $0x1,%edx
  800eec:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800eef:	0f b6 1a             	movzbl (%edx),%ebx
  800ef2:	84 db                	test   %bl,%bl
  800ef4:	74 0e                	je     800f04 <strncmp+0x3c>
  800ef6:	3a 19                	cmp    (%ecx),%bl
  800ef8:	74 ea                	je     800ee4 <strncmp+0x1c>
  800efa:	eb 08                	jmp    800f04 <strncmp+0x3c>
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f01:	5b                   	pop    %ebx
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f04:	0f b6 02             	movzbl (%edx),%eax
  800f07:	0f b6 11             	movzbl (%ecx),%edx
  800f0a:	29 d0                	sub    %edx,%eax
  800f0c:	eb f3                	jmp    800f01 <strncmp+0x39>

00800f0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	8b 45 08             	mov    0x8(%ebp),%eax
  800f14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f18:	0f b6 10             	movzbl (%eax),%edx
  800f1b:	84 d2                	test   %dl,%dl
  800f1d:	74 15                	je     800f34 <strchr+0x26>
		if (*s == c)
  800f1f:	38 ca                	cmp    %cl,%dl
  800f21:	75 07                	jne    800f2a <strchr+0x1c>
  800f23:	eb 14                	jmp    800f39 <strchr+0x2b>
  800f25:	38 ca                	cmp    %cl,%dl
  800f27:	90                   	nop
  800f28:	74 0f                	je     800f39 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f2a:	83 c0 01             	add    $0x1,%eax
  800f2d:	0f b6 10             	movzbl (%eax),%edx
  800f30:	84 d2                	test   %dl,%dl
  800f32:	75 f1                	jne    800f25 <strchr+0x17>
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f45:	0f b6 10             	movzbl (%eax),%edx
  800f48:	84 d2                	test   %dl,%dl
  800f4a:	74 18                	je     800f64 <strfind+0x29>
		if (*s == c)
  800f4c:	38 ca                	cmp    %cl,%dl
  800f4e:	75 0a                	jne    800f5a <strfind+0x1f>
  800f50:	eb 12                	jmp    800f64 <strfind+0x29>
  800f52:	38 ca                	cmp    %cl,%dl
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	74 0a                	je     800f64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f5a:	83 c0 01             	add    $0x1,%eax
  800f5d:	0f b6 10             	movzbl (%eax),%edx
  800f60:	84 d2                	test   %dl,%dl
  800f62:	75 ee                	jne    800f52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	89 1c 24             	mov    %ebx,(%esp)
  800f6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	74 30                	je     800fb4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f8a:	75 25                	jne    800fb1 <memset+0x4b>
  800f8c:	f6 c1 03             	test   $0x3,%cl
  800f8f:	75 20                	jne    800fb1 <memset+0x4b>
		c &= 0xFF;
  800f91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f94:	89 d3                	mov    %edx,%ebx
  800f96:	c1 e3 08             	shl    $0x8,%ebx
  800f99:	89 d6                	mov    %edx,%esi
  800f9b:	c1 e6 18             	shl    $0x18,%esi
  800f9e:	89 d0                	mov    %edx,%eax
  800fa0:	c1 e0 10             	shl    $0x10,%eax
  800fa3:	09 f0                	or     %esi,%eax
  800fa5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800fa7:	09 d8                	or     %ebx,%eax
  800fa9:	c1 e9 02             	shr    $0x2,%ecx
  800fac:	fc                   	cld    
  800fad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800faf:	eb 03                	jmp    800fb4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fb1:	fc                   	cld    
  800fb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fb4:	89 f8                	mov    %edi,%eax
  800fb6:	8b 1c 24             	mov    (%esp),%ebx
  800fb9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fbd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fc1:	89 ec                	mov    %ebp,%esp
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	89 34 24             	mov    %esi,(%esp)
  800fce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800fd8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800fdb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800fdd:	39 c6                	cmp    %eax,%esi
  800fdf:	73 35                	jae    801016 <memmove+0x51>
  800fe1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fe4:	39 d0                	cmp    %edx,%eax
  800fe6:	73 2e                	jae    801016 <memmove+0x51>
		s += n;
		d += n;
  800fe8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fea:	f6 c2 03             	test   $0x3,%dl
  800fed:	75 1b                	jne    80100a <memmove+0x45>
  800fef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ff5:	75 13                	jne    80100a <memmove+0x45>
  800ff7:	f6 c1 03             	test   $0x3,%cl
  800ffa:	75 0e                	jne    80100a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ffc:	83 ef 04             	sub    $0x4,%edi
  800fff:	8d 72 fc             	lea    -0x4(%edx),%esi
  801002:	c1 e9 02             	shr    $0x2,%ecx
  801005:	fd                   	std    
  801006:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801008:	eb 09                	jmp    801013 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80100a:	83 ef 01             	sub    $0x1,%edi
  80100d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801010:	fd                   	std    
  801011:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801013:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801014:	eb 20                	jmp    801036 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801016:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80101c:	75 15                	jne    801033 <memmove+0x6e>
  80101e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801024:	75 0d                	jne    801033 <memmove+0x6e>
  801026:	f6 c1 03             	test   $0x3,%cl
  801029:	75 08                	jne    801033 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80102b:	c1 e9 02             	shr    $0x2,%ecx
  80102e:	fc                   	cld    
  80102f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801031:	eb 03                	jmp    801036 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801033:	fc                   	cld    
  801034:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801036:	8b 34 24             	mov    (%esp),%esi
  801039:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80103d:	89 ec                	mov    %ebp,%esp
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801047:	8b 45 10             	mov    0x10(%ebp),%eax
  80104a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801051:	89 44 24 04          	mov    %eax,0x4(%esp)
  801055:	8b 45 08             	mov    0x8(%ebp),%eax
  801058:	89 04 24             	mov    %eax,(%esp)
  80105b:	e8 65 ff ff ff       	call   800fc5 <memmove>
}
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	8b 75 08             	mov    0x8(%ebp),%esi
  80106b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80106e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801071:	85 c9                	test   %ecx,%ecx
  801073:	74 36                	je     8010ab <memcmp+0x49>
		if (*s1 != *s2)
  801075:	0f b6 06             	movzbl (%esi),%eax
  801078:	0f b6 1f             	movzbl (%edi),%ebx
  80107b:	38 d8                	cmp    %bl,%al
  80107d:	74 20                	je     80109f <memcmp+0x3d>
  80107f:	eb 14                	jmp    801095 <memcmp+0x33>
  801081:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801086:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80108b:	83 c2 01             	add    $0x1,%edx
  80108e:	83 e9 01             	sub    $0x1,%ecx
  801091:	38 d8                	cmp    %bl,%al
  801093:	74 12                	je     8010a7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801095:	0f b6 c0             	movzbl %al,%eax
  801098:	0f b6 db             	movzbl %bl,%ebx
  80109b:	29 d8                	sub    %ebx,%eax
  80109d:	eb 11                	jmp    8010b0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80109f:	83 e9 01             	sub    $0x1,%ecx
  8010a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a7:	85 c9                	test   %ecx,%ecx
  8010a9:	75 d6                	jne    801081 <memcmp+0x1f>
  8010ab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010c0:	39 d0                	cmp    %edx,%eax
  8010c2:	73 15                	jae    8010d9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010c8:	38 08                	cmp    %cl,(%eax)
  8010ca:	75 06                	jne    8010d2 <memfind+0x1d>
  8010cc:	eb 0b                	jmp    8010d9 <memfind+0x24>
  8010ce:	38 08                	cmp    %cl,(%eax)
  8010d0:	74 07                	je     8010d9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010d2:	83 c0 01             	add    $0x1,%eax
  8010d5:	39 c2                	cmp    %eax,%edx
  8010d7:	77 f5                	ja     8010ce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ea:	0f b6 02             	movzbl (%edx),%eax
  8010ed:	3c 20                	cmp    $0x20,%al
  8010ef:	74 04                	je     8010f5 <strtol+0x1a>
  8010f1:	3c 09                	cmp    $0x9,%al
  8010f3:	75 0e                	jne    801103 <strtol+0x28>
		s++;
  8010f5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010f8:	0f b6 02             	movzbl (%edx),%eax
  8010fb:	3c 20                	cmp    $0x20,%al
  8010fd:	74 f6                	je     8010f5 <strtol+0x1a>
  8010ff:	3c 09                	cmp    $0x9,%al
  801101:	74 f2                	je     8010f5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801103:	3c 2b                	cmp    $0x2b,%al
  801105:	75 0c                	jne    801113 <strtol+0x38>
		s++;
  801107:	83 c2 01             	add    $0x1,%edx
  80110a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801111:	eb 15                	jmp    801128 <strtol+0x4d>
	else if (*s == '-')
  801113:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80111a:	3c 2d                	cmp    $0x2d,%al
  80111c:	75 0a                	jne    801128 <strtol+0x4d>
		s++, neg = 1;
  80111e:	83 c2 01             	add    $0x1,%edx
  801121:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801128:	85 db                	test   %ebx,%ebx
  80112a:	0f 94 c0             	sete   %al
  80112d:	74 05                	je     801134 <strtol+0x59>
  80112f:	83 fb 10             	cmp    $0x10,%ebx
  801132:	75 18                	jne    80114c <strtol+0x71>
  801134:	80 3a 30             	cmpb   $0x30,(%edx)
  801137:	75 13                	jne    80114c <strtol+0x71>
  801139:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80113d:	8d 76 00             	lea    0x0(%esi),%esi
  801140:	75 0a                	jne    80114c <strtol+0x71>
		s += 2, base = 16;
  801142:	83 c2 02             	add    $0x2,%edx
  801145:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80114a:	eb 15                	jmp    801161 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80114c:	84 c0                	test   %al,%al
  80114e:	66 90                	xchg   %ax,%ax
  801150:	74 0f                	je     801161 <strtol+0x86>
  801152:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801157:	80 3a 30             	cmpb   $0x30,(%edx)
  80115a:	75 05                	jne    801161 <strtol+0x86>
		s++, base = 8;
  80115c:	83 c2 01             	add    $0x1,%edx
  80115f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801168:	0f b6 0a             	movzbl (%edx),%ecx
  80116b:	89 cf                	mov    %ecx,%edi
  80116d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801170:	80 fb 09             	cmp    $0x9,%bl
  801173:	77 08                	ja     80117d <strtol+0xa2>
			dig = *s - '0';
  801175:	0f be c9             	movsbl %cl,%ecx
  801178:	83 e9 30             	sub    $0x30,%ecx
  80117b:	eb 1e                	jmp    80119b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80117d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801180:	80 fb 19             	cmp    $0x19,%bl
  801183:	77 08                	ja     80118d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801185:	0f be c9             	movsbl %cl,%ecx
  801188:	83 e9 57             	sub    $0x57,%ecx
  80118b:	eb 0e                	jmp    80119b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80118d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801190:	80 fb 19             	cmp    $0x19,%bl
  801193:	77 15                	ja     8011aa <strtol+0xcf>
			dig = *s - 'A' + 10;
  801195:	0f be c9             	movsbl %cl,%ecx
  801198:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80119b:	39 f1                	cmp    %esi,%ecx
  80119d:	7d 0b                	jge    8011aa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80119f:	83 c2 01             	add    $0x1,%edx
  8011a2:	0f af c6             	imul   %esi,%eax
  8011a5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8011a8:	eb be                	jmp    801168 <strtol+0x8d>
  8011aa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8011ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011b0:	74 05                	je     8011b7 <strtol+0xdc>
		*endptr = (char *) s;
  8011b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011b5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8011b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011bb:	74 04                	je     8011c1 <strtol+0xe6>
  8011bd:	89 c8                	mov    %ecx,%eax
  8011bf:	f7 d8                	neg    %eax
}
  8011c1:	83 c4 04             	add    $0x4,%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5f                   	pop    %edi
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    
  8011c9:	00 00                	add    %al,(%eax)
	...

008011cc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	89 1c 24             	mov    %ebx,(%esp)
  8011d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e7:	89 d1                	mov    %edx,%ecx
  8011e9:	89 d3                	mov    %edx,%ebx
  8011eb:	89 d7                	mov    %edx,%edi
  8011ed:	89 d6                	mov    %edx,%esi
  8011ef:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011f1:	8b 1c 24             	mov    (%esp),%ebx
  8011f4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011f8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011fc:	89 ec                	mov    %ebp,%esp
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	89 1c 24             	mov    %ebx,(%esp)
  801209:	89 74 24 04          	mov    %esi,0x4(%esp)
  80120d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801219:	8b 55 08             	mov    0x8(%ebp),%edx
  80121c:	89 c3                	mov    %eax,%ebx
  80121e:	89 c7                	mov    %eax,%edi
  801220:	89 c6                	mov    %eax,%esi
  801222:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801224:	8b 1c 24             	mov    (%esp),%ebx
  801227:	8b 74 24 04          	mov    0x4(%esp),%esi
  80122b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80122f:	89 ec                	mov    %ebp,%esp
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	83 ec 38             	sub    $0x38,%esp
  801239:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80123c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80123f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801242:	b9 00 00 00 00       	mov    $0x0,%ecx
  801247:	b8 0d 00 00 00       	mov    $0xd,%eax
  80124c:	8b 55 08             	mov    0x8(%ebp),%edx
  80124f:	89 cb                	mov    %ecx,%ebx
  801251:	89 cf                	mov    %ecx,%edi
  801253:	89 ce                	mov    %ecx,%esi
  801255:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801257:	85 c0                	test   %eax,%eax
  801259:	7e 28                	jle    801283 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801266:	00 
  801267:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  80127e:	e8 e9 f3 ff ff       	call   80066c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801283:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801286:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801289:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128c:	89 ec                	mov    %ebp,%esp
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	89 1c 24             	mov    %ebx,(%esp)
  801299:	89 74 24 04          	mov    %esi,0x4(%esp)
  80129d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a1:	be 00 00 00 00       	mov    $0x0,%esi
  8012a6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012ab:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012b9:	8b 1c 24             	mov    (%esp),%ebx
  8012bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012c0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012c4:	89 ec                	mov    %ebp,%esp
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 38             	sub    $0x38,%esp
  8012ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e7:	89 df                	mov    %ebx,%edi
  8012e9:	89 de                	mov    %ebx,%esi
  8012eb:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	7e 28                	jle    801319 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f5:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012fc:	00 
  8012fd:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801304:	00 
  801305:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80130c:	00 
  80130d:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801314:	e8 53 f3 ff ff       	call   80066c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801319:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80131c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80131f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801322:	89 ec                	mov    %ebp,%esp
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 38             	sub    $0x38,%esp
  80132c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80132f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801332:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801335:	bb 00 00 00 00       	mov    $0x0,%ebx
  80133a:	b8 09 00 00 00       	mov    $0x9,%eax
  80133f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801342:	8b 55 08             	mov    0x8(%ebp),%edx
  801345:	89 df                	mov    %ebx,%edi
  801347:	89 de                	mov    %ebx,%esi
  801349:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	7e 28                	jle    801377 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80134f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801353:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80135a:	00 
  80135b:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801362:	00 
  801363:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80136a:	00 
  80136b:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801372:	e8 f5 f2 ff ff       	call   80066c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801377:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80137a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80137d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801380:	89 ec                	mov    %ebp,%esp
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 38             	sub    $0x38,%esp
  80138a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80138d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801390:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801393:	bb 00 00 00 00       	mov    $0x0,%ebx
  801398:	b8 08 00 00 00       	mov    $0x8,%eax
  80139d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a3:	89 df                	mov    %ebx,%edi
  8013a5:	89 de                	mov    %ebx,%esi
  8013a7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	7e 28                	jle    8013d5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8013b8:	00 
  8013b9:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  8013c0:	00 
  8013c1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8013c8:	00 
  8013c9:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  8013d0:	e8 97 f2 ff ff       	call   80066c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013de:	89 ec                	mov    %ebp,%esp
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 38             	sub    $0x38,%esp
  8013e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8013fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801401:	89 df                	mov    %ebx,%edi
  801403:	89 de                	mov    %ebx,%esi
  801405:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801407:	85 c0                	test   %eax,%eax
  801409:	7e 28                	jle    801433 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80140b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801416:	00 
  801417:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801426:	00 
  801427:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  80142e:	e8 39 f2 ff ff       	call   80066c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801433:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801436:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801439:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80143c:	89 ec                	mov    %ebp,%esp
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 38             	sub    $0x38,%esp
  801446:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801449:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80144c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80144f:	b8 05 00 00 00       	mov    $0x5,%eax
  801454:	8b 75 18             	mov    0x18(%ebp),%esi
  801457:	8b 7d 14             	mov    0x14(%ebp),%edi
  80145a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80145d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801460:	8b 55 08             	mov    0x8(%ebp),%edx
  801463:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801465:	85 c0                	test   %eax,%eax
  801467:	7e 28                	jle    801491 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801469:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801474:	00 
  801475:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  80147c:	00 
  80147d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801484:	00 
  801485:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  80148c:	e8 db f1 ff ff       	call   80066c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801491:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801494:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801497:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80149a:	89 ec                	mov    %ebp,%esp
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 38             	sub    $0x38,%esp
  8014a4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014a7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014aa:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ad:	be 00 00 00 00       	mov    $0x0,%esi
  8014b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c0:	89 f7                	mov    %esi,%edi
  8014c2:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	7e 28                	jle    8014f0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014cc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014d3:	00 
  8014d4:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  8014db:	00 
  8014dc:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8014e3:	00 
  8014e4:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  8014eb:	e8 7c f1 ff ff       	call   80066c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014f0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014f3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014f6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014f9:	89 ec                	mov    %ebp,%esp
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	89 1c 24             	mov    %ebx,(%esp)
  801506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150e:	ba 00 00 00 00       	mov    $0x0,%edx
  801513:	b8 0b 00 00 00       	mov    $0xb,%eax
  801518:	89 d1                	mov    %edx,%ecx
  80151a:	89 d3                	mov    %edx,%ebx
  80151c:	89 d7                	mov    %edx,%edi
  80151e:	89 d6                	mov    %edx,%esi
  801520:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801522:	8b 1c 24             	mov    (%esp),%ebx
  801525:	8b 74 24 04          	mov    0x4(%esp),%esi
  801529:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80152d:	89 ec                	mov    %ebp,%esp
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	83 ec 0c             	sub    $0xc,%esp
  801537:	89 1c 24             	mov    %ebx,(%esp)
  80153a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80153e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 02 00 00 00       	mov    $0x2,%eax
  80154c:	89 d1                	mov    %edx,%ecx
  80154e:	89 d3                	mov    %edx,%ebx
  801550:	89 d7                	mov    %edx,%edi
  801552:	89 d6                	mov    %edx,%esi
  801554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801556:	8b 1c 24             	mov    (%esp),%ebx
  801559:	8b 74 24 04          	mov    0x4(%esp),%esi
  80155d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801561:	89 ec                	mov    %ebp,%esp
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 38             	sub    $0x38,%esp
  80156b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80156e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801571:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801574:	b9 00 00 00 00       	mov    $0x0,%ecx
  801579:	b8 03 00 00 00       	mov    $0x3,%eax
  80157e:	8b 55 08             	mov    0x8(%ebp),%edx
  801581:	89 cb                	mov    %ecx,%ebx
  801583:	89 cf                	mov    %ecx,%edi
  801585:	89 ce                	mov    %ecx,%esi
  801587:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  801589:	85 c0                	test   %eax,%eax
  80158b:	7e 28                	jle    8015b5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801591:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801598:	00 
  801599:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  8015a0:	00 
  8015a1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8015a8:	00 
  8015a9:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  8015b0:	e8 b7 f0 ff ff       	call   80066c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015be:	89 ec                	mov    %ebp,%esp
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    
	...

008015c4 <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	57                   	push   %edi
  8015c8:	56                   	push   %esi
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 1c             	sub    $0x1c,%esp
  8015cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015d3:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  8015d6:	85 db                	test   %ebx,%ebx
  8015d8:	75 31                	jne    80160b <ipc_send+0x47>
  8015da:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8015df:	eb 2a                	jmp    80160b <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  8015e1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015e4:	74 20                	je     801606 <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  8015e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ea:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  8015f1:	00 
  8015f2:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8015f9:	00 
  8015fa:	c7 04 24 61 28 80 00 	movl   $0x802861,(%esp)
  801601:	e8 66 f0 ff ff       	call   80066c <_panic>


                sys_yield();
  801606:	e8 f2 fe ff ff       	call   8014fd <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80160b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80160f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801613:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	89 04 24             	mov    %eax,(%esp)
  80161d:	e8 6e fc ff ff       	call   801290 <sys_ipc_try_send>
  801622:	85 c0                	test   %eax,%eax
  801624:	78 bb                	js     8015e1 <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  801626:	83 c4 1c             	add    $0x1c,%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5f                   	pop    %edi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	56                   	push   %esi
  801632:	53                   	push   %ebx
  801633:	83 ec 10             	sub    $0x10,%esp
  801636:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801639:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163c:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  80163f:	85 c0                	test   %eax,%eax
  801641:	75 05                	jne    801648 <ipc_recv+0x1a>
  801643:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  801648:	89 04 24             	mov    %eax,(%esp)
  80164b:	e8 e3 fb ff ff       	call   801233 <sys_ipc_recv>
  801650:	85 c0                	test   %eax,%eax
  801652:	78 24                	js     801678 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  801654:	85 db                	test   %ebx,%ebx
  801656:	74 0a                	je     801662 <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  801658:	a1 28 50 80 00       	mov    0x805028,%eax
  80165d:	8b 40 74             	mov    0x74(%eax),%eax
  801660:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  801662:	85 f6                	test   %esi,%esi
  801664:	74 0a                	je     801670 <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  801666:	a1 28 50 80 00       	mov    0x805028,%eax
  80166b:	8b 40 78             	mov    0x78(%eax),%eax
  80166e:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  801670:	a1 28 50 80 00       	mov    0x805028,%eax
  801675:	8b 40 70             	mov    0x70(%eax),%eax
}
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    
	...

00801680 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	05 00 00 00 30       	add    $0x30000000,%eax
  80168b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	89 04 24             	mov    %eax,(%esp)
  80169c:	e8 df ff ff ff       	call   801680 <fd2num>
  8016a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  8016b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016b9:	a8 01                	test   $0x1,%al
  8016bb:	74 36                	je     8016f3 <fd_alloc+0x48>
  8016bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016c2:	a8 01                	test   $0x1,%al
  8016c4:	74 2d                	je     8016f3 <fd_alloc+0x48>
  8016c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	c1 ea 16             	shr    $0x16,%edx
  8016dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016df:	f6 c2 01             	test   $0x1,%dl
  8016e2:	74 14                	je     8016f8 <fd_alloc+0x4d>
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	c1 ea 0c             	shr    $0xc,%edx
  8016e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016ec:	f6 c2 01             	test   $0x1,%dl
  8016ef:	75 10                	jne    801701 <fd_alloc+0x56>
  8016f1:	eb 05                	jmp    8016f8 <fd_alloc+0x4d>
  8016f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016f8:	89 1f                	mov    %ebx,(%edi)
  8016fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016ff:	eb 17                	jmp    801718 <fd_alloc+0x6d>
  801701:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801706:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80170b:	75 c8                	jne    8016d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80170d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801713:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	83 f8 1f             	cmp    $0x1f,%eax
  801726:	77 36                	ja     80175e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801728:	05 00 00 0d 00       	add    $0xd0000,%eax
  80172d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  801730:	89 c2                	mov    %eax,%edx
  801732:	c1 ea 16             	shr    $0x16,%edx
  801735:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80173c:	f6 c2 01             	test   $0x1,%dl
  80173f:	74 1d                	je     80175e <fd_lookup+0x41>
  801741:	89 c2                	mov    %eax,%edx
  801743:	c1 ea 0c             	shr    $0xc,%edx
  801746:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80174d:	f6 c2 01             	test   $0x1,%dl
  801750:	74 0c                	je     80175e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801752:	8b 55 0c             	mov    0xc(%ebp),%edx
  801755:	89 02                	mov    %eax,(%edx)
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80175c:	eb 05                	jmp    801763 <fd_lookup+0x46>
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80176b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80176e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 a0 ff ff ff       	call   80171d <fd_lookup>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 0e                	js     80178f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801781:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801784:	8b 55 0c             	mov    0xc(%ebp),%edx
  801787:	89 50 04             	mov    %edx,0x4(%eax)
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 10             	sub    $0x10,%esp
  801799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80179f:	b8 0c 50 80 00       	mov    $0x80500c,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017a9:	be ec 28 80 00       	mov    $0x8028ec,%esi
		if (devtab[i]->dev_id == dev_id) {
  8017ae:	39 08                	cmp    %ecx,(%eax)
  8017b0:	75 10                	jne    8017c2 <dev_lookup+0x31>
  8017b2:	eb 04                	jmp    8017b8 <dev_lookup+0x27>
  8017b4:	39 08                	cmp    %ecx,(%eax)
  8017b6:	75 0a                	jne    8017c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8017b8:	89 03                	mov    %eax,(%ebx)
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017bf:	90                   	nop
  8017c0:	eb 31                	jmp    8017f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017c2:	83 c2 01             	add    $0x1,%edx
  8017c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	75 e8                	jne    8017b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  8017cc:	a1 28 50 80 00       	mov    0x805028,%eax
  8017d1:	8b 40 4c             	mov    0x4c(%eax),%eax
  8017d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  8017e3:	e8 49 ef ff ff       	call   800731 <cprintf>
	*dev = 0;
  8017e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	5b                   	pop    %ebx
  8017f7:	5e                   	pop    %esi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 24             	sub    $0x24,%esp
  801801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 07 ff ff ff       	call   80171d <fd_lookup>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 53                	js     80186d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801824:	8b 00                	mov    (%eax),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 63 ff ff ff       	call   801791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 3b                	js     80186d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801832:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801837:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80183e:	74 2d                	je     80186d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801840:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801843:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184a:	00 00 00 
	stat->st_isdir = 0;
  80184d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801854:	00 00 00 
	stat->st_dev = dev;
  801857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801864:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801867:	89 14 24             	mov    %edx,(%esp)
  80186a:	ff 50 14             	call   *0x14(%eax)
}
  80186d:	83 c4 24             	add    $0x24,%esp
  801870:	5b                   	pop    %ebx
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 24             	sub    $0x24,%esp
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801880:	89 44 24 04          	mov    %eax,0x4(%esp)
  801884:	89 1c 24             	mov    %ebx,(%esp)
  801887:	e8 91 fe ff ff       	call   80171d <fd_lookup>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 5f                	js     8018ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801893:	89 44 24 04          	mov    %eax,0x4(%esp)
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	8b 00                	mov    (%eax),%eax
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 ed fe ff ff       	call   801791 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 47                	js     8018ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018af:	75 23                	jne    8018d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  8018b1:	a1 28 50 80 00       	mov    0x805028,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018b6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8018b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  8018c8:	e8 64 ee ff ff       	call   800731 <cprintf>
  8018cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  8018d2:	eb 1b                	jmp    8018ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8018da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018df:	85 c9                	test   %ecx,%ecx
  8018e1:	74 0c                	je     8018ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	89 14 24             	mov    %edx,(%esp)
  8018ed:	ff d1                	call   *%ecx
}
  8018ef:	83 c4 24             	add    $0x24,%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 24             	sub    $0x24,%esp
  8018fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	89 1c 24             	mov    %ebx,(%esp)
  801909:	e8 0f fe ff ff       	call   80171d <fd_lookup>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 66                	js     801978 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801915:	89 44 24 04          	mov    %eax,0x4(%esp)
  801919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191c:	8b 00                	mov    (%eax),%eax
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	e8 6b fe ff ff       	call   801791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801926:	85 c0                	test   %eax,%eax
  801928:	78 4e                	js     801978 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80192d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801931:	75 23                	jne    801956 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  801933:	a1 28 50 80 00       	mov    0x805028,%eax
  801938:	8b 40 4c             	mov    0x4c(%eax),%eax
  80193b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80193f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801943:	c7 04 24 b0 28 80 00 	movl   $0x8028b0,(%esp)
  80194a:	e8 e2 ed ff ff       	call   800731 <cprintf>
  80194f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801954:	eb 22                	jmp    801978 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801959:	8b 48 0c             	mov    0xc(%eax),%ecx
  80195c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801961:	85 c9                	test   %ecx,%ecx
  801963:	74 13                	je     801978 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801965:	8b 45 10             	mov    0x10(%ebp),%eax
  801968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801973:	89 14 24             	mov    %edx,(%esp)
  801976:	ff d1                	call   *%ecx
}
  801978:	83 c4 24             	add    $0x24,%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 24             	sub    $0x24,%esp
  801985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	89 1c 24             	mov    %ebx,(%esp)
  801992:	e8 86 fd ff ff       	call   80171d <fd_lookup>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 6b                	js     801a06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a5:	8b 00                	mov    (%eax),%eax
  8019a7:	89 04 24             	mov    %eax,(%esp)
  8019aa:	e8 e2 fd ff ff       	call   801791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 53                	js     801a06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019b6:	8b 42 08             	mov    0x8(%edx),%eax
  8019b9:	83 e0 03             	and    $0x3,%eax
  8019bc:	83 f8 01             	cmp    $0x1,%eax
  8019bf:	75 23                	jne    8019e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8019c1:	a1 28 50 80 00       	mov    0x805028,%eax
  8019c6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8019c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	c7 04 24 cd 28 80 00 	movl   $0x8028cd,(%esp)
  8019d8:	e8 54 ed ff ff       	call   800731 <cprintf>
  8019dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019e2:	eb 22                	jmp    801a06 <read+0x88>
	}
	if (!dev->dev_read)
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019ef:	85 c9                	test   %ecx,%ecx
  8019f1:	74 13                	je     801a06 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a01:	89 14 24             	mov    %edx,(%esp)
  801a04:	ff d1                	call   *%ecx
}
  801a06:	83 c4 24             	add    $0x24,%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	57                   	push   %edi
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 1c             	sub    $0x1c,%esp
  801a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a25:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2a:	85 f6                	test   %esi,%esi
  801a2c:	74 29                	je     801a57 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a2e:	89 f0                	mov    %esi,%eax
  801a30:	29 d0                	sub    %edx,%eax
  801a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a36:	03 55 0c             	add    0xc(%ebp),%edx
  801a39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a3d:	89 3c 24             	mov    %edi,(%esp)
  801a40:	e8 39 ff ff ff       	call   80197e <read>
		if (m < 0)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 0e                	js     801a57 <readn+0x4b>
			return m;
		if (m == 0)
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	74 08                	je     801a55 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a4d:	01 c3                	add    %eax,%ebx
  801a4f:	89 da                	mov    %ebx,%edx
  801a51:	39 f3                	cmp    %esi,%ebx
  801a53:	72 d9                	jb     801a2e <readn+0x22>
  801a55:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a57:	83 c4 1c             	add    $0x1c,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 20             	sub    $0x20,%esp
  801a67:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a6a:	89 34 24             	mov    %esi,(%esp)
  801a6d:	e8 0e fc ff ff       	call   801680 <fd2num>
  801a72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a75:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a79:	89 04 24             	mov    %eax,(%esp)
  801a7c:	e8 9c fc ff ff       	call   80171d <fd_lookup>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 05                	js     801a8c <fd_close+0x2d>
  801a87:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a8a:	74 0c                	je     801a98 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a8c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801a90:	19 c0                	sbb    %eax,%eax
  801a92:	f7 d0                	not    %eax
  801a94:	21 c3                	and    %eax,%ebx
  801a96:	eb 3d                	jmp    801ad5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9f:	8b 06                	mov    (%esi),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 e8 fc ff ff       	call   801791 <dev_lookup>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 16                	js     801ac5 <fd_close+0x66>
		if (dev->dev_close)
  801aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab2:	8b 40 10             	mov    0x10(%eax),%eax
  801ab5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aba:	85 c0                	test   %eax,%eax
  801abc:	74 07                	je     801ac5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801abe:	89 34 24             	mov    %esi,(%esp)
  801ac1:	ff d0                	call   *%eax
  801ac3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ac5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad0:	e8 0d f9 ff ff       	call   8013e2 <sys_page_unmap>
	return r;
}
  801ad5:	89 d8                	mov    %ebx,%eax
  801ad7:	83 c4 20             	add    $0x20,%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	89 04 24             	mov    %eax,(%esp)
  801af1:	e8 27 fc ff ff       	call   80171d <fd_lookup>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 13                	js     801b0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801afa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b01:	00 
  801b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b05:	89 04 24             	mov    %eax,(%esp)
  801b08:	e8 52 ff ff ff       	call   801a5f <fd_close>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 18             	sub    $0x18,%esp
  801b15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b22:	00 
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	89 04 24             	mov    %eax,(%esp)
  801b29:	e8 4d 03 00 00       	call   801e7b <open>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 1b                	js     801b4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3b:	89 1c 24             	mov    %ebx,(%esp)
  801b3e:	e8 b7 fc ff ff       	call   8017fa <fstat>
  801b43:	89 c6                	mov    %eax,%esi
	close(fd);
  801b45:	89 1c 24             	mov    %ebx,(%esp)
  801b48:	e8 91 ff ff ff       	call   801ade <close>
  801b4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b57:	89 ec                	mov    %ebp,%esp
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 14             	sub    $0x14,%esp
  801b62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 6f ff ff ff       	call   801ade <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b6f:	83 c3 01             	add    $0x1,%ebx
  801b72:	83 fb 20             	cmp    $0x20,%ebx
  801b75:	75 f0                	jne    801b67 <close_all+0xc>
		close(i);
}
  801b77:	83 c4 14             	add    $0x14,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 58             	sub    $0x58,%esp
  801b83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	89 04 24             	mov    %eax,(%esp)
  801b9c:	e8 7c fb ff ff       	call   80171d <fd_lookup>
  801ba1:	89 c3                	mov    %eax,%ebx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 e0 00 00 00    	js     801c8b <dup+0x10e>
		return r;
	close(newfdnum);
  801bab:	89 3c 24             	mov    %edi,(%esp)
  801bae:	e8 2b ff ff ff       	call   801ade <close>

	newfd = INDEX2FD(newfdnum);
  801bb3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bb9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 c9 fa ff ff       	call   801690 <fd2data>
  801bc7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bc9:	89 34 24             	mov    %esi,(%esp)
  801bcc:	e8 bf fa ff ff       	call   801690 <fd2data>
  801bd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  801bd4:	89 da                	mov    %ebx,%edx
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	c1 e8 16             	shr    $0x16,%eax
  801bdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801be2:	a8 01                	test   $0x1,%al
  801be4:	74 43                	je     801c29 <dup+0xac>
  801be6:	c1 ea 0c             	shr    $0xc,%edx
  801be9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bf0:	a8 01                	test   $0x1,%al
  801bf2:	74 35                	je     801c29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  801bf4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bfb:	25 07 0e 00 00       	and    $0xe07,%eax
  801c00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c12:	00 
  801c13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1e:	e8 1d f8 ff ff       	call   801440 <sys_page_map>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 3f                	js     801c68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  801c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	c1 ea 0c             	shr    $0xc,%edx
  801c31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c4d:	00 
  801c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c59:	e8 e2 f7 ff ff       	call   801440 <sys_page_map>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 04                	js     801c68 <dup+0xeb>
  801c64:	89 fb                	mov    %edi,%ebx
  801c66:	eb 23                	jmp    801c8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c73:	e8 6a f7 ff ff       	call   8013e2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c86:	e8 57 f7 ff ff       	call   8013e2 <sys_page_unmap>
	return r;
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c96:	89 ec                	mov    %ebp,%esp
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    
  801c9a:	00 00                	add    %al,(%eax)
  801c9c:	00 00                	add    %al,(%eax)
	...

00801ca0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 14             	sub    $0x14,%esp
  801ca7:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ca9:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  801caf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cb6:	00 
  801cb7:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801cbe:	00 
  801cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc3:	89 14 24             	mov    %edx,(%esp)
  801cc6:	e8 f9 f8 ff ff       	call   8015c4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ccb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cd2:	00 
  801cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cde:	e8 4b f9 ff ff       	call   80162e <ipc_recv>
}
  801ce3:	83 c4 14             	add    $0x14,%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf5:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.set_size.req_size = newsize;
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	a3 04 30 80 00       	mov    %eax,0x803004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	b8 02 00 00 00       	mov    $0x2,%eax
  801d0c:	e8 8f ff ff ff       	call   801ca0 <fsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1f:	a3 00 30 80 00       	mov    %eax,0x803000
	return fsipc(FSREQ_FLUSH, NULL);
  801d24:	ba 00 00 00 00       	mov    $0x0,%edx
  801d29:	b8 06 00 00 00       	mov    $0x6,%eax
  801d2e:	e8 6d ff ff ff       	call   801ca0 <fsipc>
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d40:	b8 08 00 00 00       	mov    $0x8,%eax
  801d45:	e8 56 ff ff ff       	call   801ca0 <fsipc>
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 14             	sub    $0x14,%esp
  801d53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	8b 40 0c             	mov    0xc(%eax),%eax
  801d5c:	a3 00 30 80 00       	mov    %eax,0x803000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d61:	ba 00 00 00 00       	mov    $0x0,%edx
  801d66:	b8 05 00 00 00       	mov    $0x5,%eax
  801d6b:	e8 30 ff ff ff       	call   801ca0 <fsipc>
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 2b                	js     801d9f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d74:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801d7b:	00 
  801d7c:	89 1c 24             	mov    %ebx,(%esp)
  801d7f:	e8 86 f0 ff ff       	call   800e0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d84:	a1 80 30 80 00       	mov    0x803080,%eax
  801d89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d8f:	a1 84 30 80 00       	mov    0x803084,%eax
  801d94:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d9a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d9f:	83 c4 14             	add    $0x14,%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 18             	sub    $0x18,%esp
  801dab:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dae:	8b 55 08             	mov    0x8(%ebp),%edx
  801db1:	8b 52 0c             	mov    0xc(%edx),%edx
  801db4:	89 15 00 30 80 00    	mov    %edx,0x803000
	fsipcbuf.write.req_n = n;
  801dba:	a3 04 30 80 00       	mov    %eax,0x803004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dca:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  801dd1:	e8 ef f1 ff ff       	call   800fc5 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  801dd6:	ba 00 30 80 00       	mov    $0x803000,%edx
  801ddb:	b8 04 00 00 00       	mov    $0x4,%eax
  801de0:	e8 bb fe ff ff       	call   801ca0 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	53                   	push   %ebx
  801deb:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	8b 40 0c             	mov    0xc(%eax),%eax
  801df4:	a3 00 30 80 00       	mov    %eax,0x803000
	fsipcbuf.read.req_n = n;
  801df9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfc:	a3 04 30 80 00       	mov    %eax,0x803004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  801e01:	ba 00 30 80 00       	mov    $0x803000,%edx
  801e06:	b8 03 00 00 00       	mov    $0x3,%eax
  801e0b:	e8 90 fe ff ff       	call   801ca0 <fsipc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 17                	js     801e2d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  801e16:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1a:	c7 44 24 04 00 30 80 	movl   $0x803000,0x4(%esp)
  801e21:	00 
  801e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e25:	89 04 24             	mov    %eax,(%esp)
  801e28:	e8 98 f1 ff ff       	call   800fc5 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  801e2d:	89 d8                	mov    %ebx,%eax
  801e2f:	83 c4 14             	add    $0x14,%esp
  801e32:	5b                   	pop    %ebx
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	53                   	push   %ebx
  801e39:	83 ec 14             	sub    $0x14,%esp
  801e3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e3f:	89 1c 24             	mov    %ebx,(%esp)
  801e42:	e8 79 ef ff ff       	call   800dc0 <strlen>
  801e47:	89 c2                	mov    %eax,%edx
  801e49:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e4e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e54:	7f 1f                	jg     801e75 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e5a:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801e61:	e8 a4 ef ff ff       	call   800e0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e66:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6b:	b8 07 00 00 00       	mov    $0x7,%eax
  801e70:	e8 2b fe ff ff       	call   801ca0 <fsipc>
}
  801e75:	83 c4 14             	add    $0x14,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 1f f8 ff ff       	call   8016ab <fd_alloc>
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 6a                	js     801efa <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  801e9e:	e8 67 ef ff ff       	call   800e0a <strcpy>
        fsipcbuf.open.req_omode = mode;
  801ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea6:	a3 00 34 80 00       	mov    %eax,0x803400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801eab:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  801eb0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801eb7:	00 
  801eb8:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801ebf:	00 
  801ec0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ec7:	00 
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 f4 f6 ff ff       	call   8015c4 <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  801ed0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed7:	00 
  801ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee6:	e8 43 f7 ff ff       	call   80162e <ipc_recv>
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 0b                	js     801efa <open+0x7f>
		return r;
	return fd2num(fd);
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 86 f7 ff ff       	call   801680 <fd2num>
	panic("open not implemented");
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    
  801efc:	00 00                	add    %al,(%eax)
	...

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	83 ec 10             	sub    $0x10,%esp
  801f08:	8b 45 14             	mov    0x14(%ebp),%eax
  801f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f0e:	8b 75 10             	mov    0x10(%ebp),%esi
  801f11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f14:	85 c0                	test   %eax,%eax
  801f16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f19:	75 35                	jne    801f50 <__udivdi3+0x50>
  801f1b:	39 fe                	cmp    %edi,%esi
  801f1d:	77 61                	ja     801f80 <__udivdi3+0x80>
  801f1f:	85 f6                	test   %esi,%esi
  801f21:	75 0b                	jne    801f2e <__udivdi3+0x2e>
  801f23:	b8 01 00 00 00       	mov    $0x1,%eax
  801f28:	31 d2                	xor    %edx,%edx
  801f2a:	f7 f6                	div    %esi
  801f2c:	89 c6                	mov    %eax,%esi
  801f2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	89 f8                	mov    %edi,%eax
  801f35:	f7 f6                	div    %esi
  801f37:	89 c7                	mov    %eax,%edi
  801f39:	89 c8                	mov    %ecx,%eax
  801f3b:	f7 f6                	div    %esi
  801f3d:	89 c1                	mov    %eax,%ecx
  801f3f:	89 fa                	mov    %edi,%edx
  801f41:	89 c8                	mov    %ecx,%eax
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	5e                   	pop    %esi
  801f47:	5f                   	pop    %edi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    
  801f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f50:	39 f8                	cmp    %edi,%eax
  801f52:	77 1c                	ja     801f70 <__udivdi3+0x70>
  801f54:	0f bd d0             	bsr    %eax,%edx
  801f57:	83 f2 1f             	xor    $0x1f,%edx
  801f5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f5d:	75 39                	jne    801f98 <__udivdi3+0x98>
  801f5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f62:	0f 86 a0 00 00 00    	jbe    802008 <__udivdi3+0x108>
  801f68:	39 f8                	cmp    %edi,%eax
  801f6a:	0f 82 98 00 00 00    	jb     802008 <__udivdi3+0x108>
  801f70:	31 ff                	xor    %edi,%edi
  801f72:	31 c9                	xor    %ecx,%ecx
  801f74:	89 c8                	mov    %ecx,%eax
  801f76:	89 fa                	mov    %edi,%edx
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
  801f7f:	90                   	nop
  801f80:	89 d1                	mov    %edx,%ecx
  801f82:	89 fa                	mov    %edi,%edx
  801f84:	89 c8                	mov    %ecx,%eax
  801f86:	31 ff                	xor    %edi,%edi
  801f88:	f7 f6                	div    %esi
  801f8a:	89 c1                	mov    %eax,%ecx
  801f8c:	89 fa                	mov    %edi,%edx
  801f8e:	89 c8                	mov    %ecx,%eax
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    
  801f97:	90                   	nop
  801f98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f9c:	89 f2                	mov    %esi,%edx
  801f9e:	d3 e0                	shl    %cl,%eax
  801fa0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fa3:	b8 20 00 00 00       	mov    $0x20,%eax
  801fa8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801fab:	89 c1                	mov    %eax,%ecx
  801fad:	d3 ea                	shr    %cl,%edx
  801faf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fb3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801fb6:	d3 e6                	shl    %cl,%esi
  801fb8:	89 c1                	mov    %eax,%ecx
  801fba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801fbd:	89 fe                	mov    %edi,%esi
  801fbf:	d3 ee                	shr    %cl,%esi
  801fc1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fc5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fcb:	d3 e7                	shl    %cl,%edi
  801fcd:	89 c1                	mov    %eax,%ecx
  801fcf:	d3 ea                	shr    %cl,%edx
  801fd1:	09 d7                	or     %edx,%edi
  801fd3:	89 f2                	mov    %esi,%edx
  801fd5:	89 f8                	mov    %edi,%eax
  801fd7:	f7 75 ec             	divl   -0x14(%ebp)
  801fda:	89 d6                	mov    %edx,%esi
  801fdc:	89 c7                	mov    %eax,%edi
  801fde:	f7 65 e8             	mull   -0x18(%ebp)
  801fe1:	39 d6                	cmp    %edx,%esi
  801fe3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fe6:	72 30                	jb     802018 <__udivdi3+0x118>
  801fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801feb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fef:	d3 e2                	shl    %cl,%edx
  801ff1:	39 c2                	cmp    %eax,%edx
  801ff3:	73 05                	jae    801ffa <__udivdi3+0xfa>
  801ff5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801ff8:	74 1e                	je     802018 <__udivdi3+0x118>
  801ffa:	89 f9                	mov    %edi,%ecx
  801ffc:	31 ff                	xor    %edi,%edi
  801ffe:	e9 71 ff ff ff       	jmp    801f74 <__udivdi3+0x74>
  802003:	90                   	nop
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80200f:	e9 60 ff ff ff       	jmp    801f74 <__udivdi3+0x74>
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80201b:	31 ff                	xor    %edi,%edi
  80201d:	89 c8                	mov    %ecx,%eax
  80201f:	89 fa                	mov    %edi,%edx
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
	...

00802030 <__umoddi3>:
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	83 ec 20             	sub    $0x20,%esp
  802038:	8b 55 14             	mov    0x14(%ebp),%edx
  80203b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80203e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802041:	8b 75 0c             	mov    0xc(%ebp),%esi
  802044:	85 d2                	test   %edx,%edx
  802046:	89 c8                	mov    %ecx,%eax
  802048:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80204b:	75 13                	jne    802060 <__umoddi3+0x30>
  80204d:	39 f7                	cmp    %esi,%edi
  80204f:	76 3f                	jbe    802090 <__umoddi3+0x60>
  802051:	89 f2                	mov    %esi,%edx
  802053:	f7 f7                	div    %edi
  802055:	89 d0                	mov    %edx,%eax
  802057:	31 d2                	xor    %edx,%edx
  802059:	83 c4 20             	add    $0x20,%esp
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    
  802060:	39 f2                	cmp    %esi,%edx
  802062:	77 4c                	ja     8020b0 <__umoddi3+0x80>
  802064:	0f bd ca             	bsr    %edx,%ecx
  802067:	83 f1 1f             	xor    $0x1f,%ecx
  80206a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80206d:	75 51                	jne    8020c0 <__umoddi3+0x90>
  80206f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802072:	0f 87 e0 00 00 00    	ja     802158 <__umoddi3+0x128>
  802078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207b:	29 f8                	sub    %edi,%eax
  80207d:	19 d6                	sbb    %edx,%esi
  80207f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	89 f2                	mov    %esi,%edx
  802087:	83 c4 20             	add    $0x20,%esp
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
  80208e:	66 90                	xchg   %ax,%ax
  802090:	85 ff                	test   %edi,%edi
  802092:	75 0b                	jne    80209f <__umoddi3+0x6f>
  802094:	b8 01 00 00 00       	mov    $0x1,%eax
  802099:	31 d2                	xor    %edx,%edx
  80209b:	f7 f7                	div    %edi
  80209d:	89 c7                	mov    %eax,%edi
  80209f:	89 f0                	mov    %esi,%eax
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	f7 f7                	div    %edi
  8020a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a8:	f7 f7                	div    %edi
  8020aa:	eb a9                	jmp    802055 <__umoddi3+0x25>
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 20             	add    $0x20,%esp
  8020b7:	5e                   	pop    %esi
  8020b8:	5f                   	pop    %edi
  8020b9:	5d                   	pop    %ebp
  8020ba:	c3                   	ret    
  8020bb:	90                   	nop
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020c4:	d3 e2                	shl    %cl,%edx
  8020c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8020ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8020d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	d3 ea                	shr    %cl,%edx
  8020dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8020e3:	d3 e7                	shl    %cl,%edi
  8020e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020ec:	89 f2                	mov    %esi,%edx
  8020ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020f1:	89 c7                	mov    %eax,%edi
  8020f3:	d3 ea                	shr    %cl,%edx
  8020f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020fc:	89 c2                	mov    %eax,%edx
  8020fe:	d3 e6                	shl    %cl,%esi
  802100:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802104:	d3 ea                	shr    %cl,%edx
  802106:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80210a:	09 d6                	or     %edx,%esi
  80210c:	89 f0                	mov    %esi,%eax
  80210e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802111:	d3 e7                	shl    %cl,%edi
  802113:	89 f2                	mov    %esi,%edx
  802115:	f7 75 f4             	divl   -0xc(%ebp)
  802118:	89 d6                	mov    %edx,%esi
  80211a:	f7 65 e8             	mull   -0x18(%ebp)
  80211d:	39 d6                	cmp    %edx,%esi
  80211f:	72 2b                	jb     80214c <__umoddi3+0x11c>
  802121:	39 c7                	cmp    %eax,%edi
  802123:	72 23                	jb     802148 <__umoddi3+0x118>
  802125:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802129:	29 c7                	sub    %eax,%edi
  80212b:	19 d6                	sbb    %edx,%esi
  80212d:	89 f0                	mov    %esi,%eax
  80212f:	89 f2                	mov    %esi,%edx
  802131:	d3 ef                	shr    %cl,%edi
  802133:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802137:	d3 e0                	shl    %cl,%eax
  802139:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80213d:	09 f8                	or     %edi,%eax
  80213f:	d3 ea                	shr    %cl,%edx
  802141:	83 c4 20             	add    $0x20,%esp
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	39 d6                	cmp    %edx,%esi
  80214a:	75 d9                	jne    802125 <__umoddi3+0xf5>
  80214c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80214f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802152:	eb d1                	jmp    802125 <__umoddi3+0xf5>
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	0f 82 18 ff ff ff    	jb     802078 <__umoddi3+0x48>
  802160:	e9 1d ff ff ff       	jmp    802082 <__umoddi3+0x52>
