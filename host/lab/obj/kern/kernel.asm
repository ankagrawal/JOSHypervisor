
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 f0 11 00 	lgdtl  0x11f018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Leave a few words on the stack for the user trap frame
	movl	$(bootstacktop-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc ef 11 f0       	mov    $0xf011efbc,%esp

	# now to C code
	call	i386_init
f0100038:	e8 a7 00 00 00       	call   f01000e4 <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 c0 67 10 f0 	movl   $0xf01067c0,(%esp)
f010005f:	e8 a7 39 00 00       	call   f0103a0b <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 65 39 00 00       	call   f01039d8 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 93 6b 10 f0 	movl   $0xf0106b93,(%esp)
f010007a:	e8 8c 39 00 00       	call   f0103a0b <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d 60 23 1e f0 00 	cmpl   $0x0,0xf01e2360
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 60 23 1e f0    	mov    %esi,0xf01e2360

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 da 67 10 f0 	movl   $0xf01067da,(%esp)
f01000b9:	e8 4d 39 00 00       	call   f0103a0b <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 0e 39 00 00       	call   f01039d8 <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 93 6b 10 f0 	movl   $0xf0106b93,(%esp)
f01000d1:	e8 35 39 00 00       	call   f0103a0b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 de 06 00 00       	call   f01007c0 <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <i386_init>:

#include <kern/vmm.h>

void
i386_init(void)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000ea:	b8 f2 43 1e f0       	mov    $0xf01e43f2,%eax
f01000ef:	2d 49 23 1e f0       	sub    $0xf01e2349,%eax
f01000f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000ff:	00 
f0100100:	c7 04 24 49 23 1e f0 	movl   $0xf01e2349,(%esp)
f0100107:	e8 da 52 00 00       	call   f01053e6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 a4 04 00 00       	call   f01005b5 <cons_init>
	//cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
//	extern int _binary_obj_user_abc_size[];
//	cprintf("obj: %x ()\n",_binary_obj_user_abc_size);	
	i386_detect_memory();
f0100111:	e8 75 15 00 00       	call   f010168b <i386_detect_memory>
	i386_vm_init();
f0100116:	e8 07 16 00 00       	call   f0101722 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010011b:	90                   	nop
f010011c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100120:	e8 ec 2f 00 00       	call   f0103111 <env_init>
	idt_init();
f0100125:	e8 16 39 00 00       	call   f0103a40 <idt_init>
	// Lab 4 multitasking initialization functions
	pic_init();
f010012a:	e8 1a 38 00 00       	call   f0103949 <pic_init>
	kclock_init();
f010012f:	90                   	nop
f0100130:	e8 53 37 00 00       	call   f0103888 <kclock_init>
	// Should always have an idle process as first one.
	cprintf("creating idle\n");
f0100135:	c7 04 24 f2 67 10 f0 	movl   $0xf01067f2,(%esp)
f010013c:	e8 ca 38 00 00       	call   f0103a0b <cprintf>
	ENV_CREATE(user_idle);
f0100141:	c7 44 24 04 a1 dc 00 	movl   $0xdca1,0x4(%esp)
f0100148:	00 
f0100149:	c7 04 24 c4 f3 11 f0 	movl   $0xf011f3c4,(%esp)
f0100150:	e8 b4 35 00 00       	call   f0103709 <env_create>

	// Start fs.
	ENV_CREATE(fs_fs);
f0100155:	c7 44 24 04 74 83 01 	movl   $0x18374,0x4(%esp)
f010015c:	00 
f010015d:	c7 04 24 7e 1c 19 f0 	movl   $0xf0191c7e,(%esp)
f0100164:	e8 a0 35 00 00       	call   f0103709 <env_create>
	ENV_CREATE(user_icode_kernel);
f0100169:	c7 44 24 04 40 ed 00 	movl   $0xed40,0x4(%esp)
f0100170:	00 
f0100171:	c7 04 24 c5 7c 1b f0 	movl   $0xf01b7cc5,(%esp)
f0100178:	e8 8c 35 00 00       	call   f0103709 <env_create>
	cprintf("creating icode\n");
f010017d:	c7 04 24 01 68 10 f0 	movl   $0xf0106801,(%esp)
f0100184:	e8 82 38 00 00       	call   f0103a0b <cprintf>
	ENV_CREATE(user_icode);
f0100189:	c7 44 24 04 39 ed 00 	movl   $0xed39,0x4(%esp)
f0100190:	00 
f0100191:	c7 04 24 a3 52 17 f0 	movl   $0xf01752a3,(%esp)
f0100198:	e8 6c 35 00 00       	call   f0103709 <env_create>
	//ENV_CREATE(user_mem_check
	//ENV_CREATE(user_mem_check);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010019d:	e8 9e 3f 00 00       	call   f0104140 <sched_yield>
	...

f01001b0 <delay>:
static void cons_intr(int (*proc)(void));
static void cons_putc(int c);
// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001b3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001b8:	ec                   	in     (%dx),%al
f01001b9:	ec                   	in     (%dx),%al
f01001ba:	ec                   	in     (%dx),%al
f01001bb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001bc:	5d                   	pop    %ebp
f01001bd:	c3                   	ret    

f01001be <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001be:	55                   	push   %ebp
f01001bf:	89 e5                	mov    %esp,%ebp
f01001c1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c6:	ec                   	in     (%dx),%al
f01001c7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001ce:	f6 c2 01             	test   $0x1,%dl
f01001d1:	74 09                	je     f01001dc <serial_proc_data+0x1e>
f01001d3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d9:	0f b6 c0             	movzbl %al,%eax
}
f01001dc:	5d                   	pop    %ebp
f01001dd:	c3                   	ret    

f01001de <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001de:	55                   	push   %ebp
f01001df:	89 e5                	mov    %esp,%ebp
f01001e1:	57                   	push   %edi
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	83 ec 0c             	sub    $0xc,%esp
f01001e7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001e9:	bb a4 25 1e f0       	mov    $0xf01e25a4,%ebx
f01001ee:	bf a0 23 1e f0       	mov    $0xf01e23a0,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001f3:	eb 1e                	jmp    f0100213 <cons_intr+0x35>
		if (c == 0)
f01001f5:	85 c0                	test   %eax,%eax
f01001f7:	74 1a                	je     f0100213 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001f9:	8b 13                	mov    (%ebx),%edx
f01001fb:	88 04 17             	mov    %al,(%edi,%edx,1)
f01001fe:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100201:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100206:	0f 94 c2             	sete   %dl
f0100209:	0f b6 d2             	movzbl %dl,%edx
f010020c:	83 ea 01             	sub    $0x1,%edx
f010020f:	21 d0                	and    %edx,%eax
f0100211:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100213:	ff d6                	call   *%esi
f0100215:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100218:	75 db                	jne    f01001f5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010021a:	83 c4 0c             	add    $0xc,%esp
f010021d:	5b                   	pop    %ebx
f010021e:	5e                   	pop    %esi
f010021f:	5f                   	pop    %edi
f0100220:	5d                   	pop    %ebp
f0100221:	c3                   	ret    

f0100222 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100222:	55                   	push   %ebp
f0100223:	89 e5                	mov    %esp,%ebp
f0100225:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100228:	b8 ba 04 10 f0       	mov    $0xf01004ba,%eax
f010022d:	e8 ac ff ff ff       	call   f01001de <cons_intr>
}
f0100232:	c9                   	leave  
f0100233:	c3                   	ret    

f0100234 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100234:	55                   	push   %ebp
f0100235:	89 e5                	mov    %esp,%ebp
f0100237:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010023a:	83 3d 84 23 1e f0 00 	cmpl   $0x0,0xf01e2384
f0100241:	74 0a                	je     f010024d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100243:	b8 be 01 10 f0       	mov    $0xf01001be,%eax
f0100248:	e8 91 ff ff ff       	call   f01001de <cons_intr>
}
f010024d:	c9                   	leave  
f010024e:	c3                   	ret    

f010024f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010024f:	55                   	push   %ebp
f0100250:	89 e5                	mov    %esp,%ebp
f0100252:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100255:	e8 da ff ff ff       	call   f0100234 <serial_intr>
	kbd_intr();
f010025a:	e8 c3 ff ff ff       	call   f0100222 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010025f:	8b 15 a0 25 1e f0    	mov    0xf01e25a0,%edx
f0100265:	b8 00 00 00 00       	mov    $0x0,%eax
f010026a:	3b 15 a4 25 1e f0    	cmp    0xf01e25a4,%edx
f0100270:	74 21                	je     f0100293 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100272:	0f b6 82 a0 23 1e f0 	movzbl -0xfe1dc60(%edx),%eax
f0100279:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010027c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100282:	0f 94 c1             	sete   %cl
f0100285:	0f b6 c9             	movzbl %cl,%ecx
f0100288:	83 e9 01             	sub    $0x1,%ecx
f010028b:	21 ca                	and    %ecx,%edx
f010028d:	89 15 a0 25 1e f0    	mov    %edx,0xf01e25a0
		return c;
	}
	return 0;
}
f0100293:	c9                   	leave  
f0100294:	c3                   	ret    

f0100295 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100295:	55                   	push   %ebp
f0100296:	89 e5                	mov    %esp,%ebp
f0100298:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010029b:	e8 af ff ff ff       	call   f010024f <cons_getc>
f01002a0:	85 c0                	test   %eax,%eax
f01002a2:	74 f7                	je     f010029b <getchar+0x6>
		/* do nothing */;
	return c;
}
f01002a4:	c9                   	leave  
f01002a5:	c3                   	ret    

f01002a6 <iscons>:

int
iscons(int fdnum)
{
f01002a6:	55                   	push   %ebp
f01002a7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01002a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01002ae:	5d                   	pop    %ebp
f01002af:	c3                   	ret    

f01002b0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002b0:	55                   	push   %ebp
f01002b1:	89 e5                	mov    %esp,%ebp
f01002b3:	57                   	push   %edi
f01002b4:	56                   	push   %esi
f01002b5:	53                   	push   %ebx
f01002b6:	83 ec 2c             	sub    $0x2c,%esp
f01002b9:	89 c7                	mov    %eax,%edi
f01002bb:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002c1:	a8 20                	test   $0x20,%al
f01002c3:	75 21                	jne    f01002e6 <cons_putc+0x36>
f01002c5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002ca:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01002cf:	e8 dc fe ff ff       	call   f01001b0 <delay>
f01002d4:	89 f2                	mov    %esi,%edx
f01002d6:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002d7:	a8 20                	test   $0x20,%al
f01002d9:	75 0b                	jne    f01002e6 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002db:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002de:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002e4:	75 e9                	jne    f01002cf <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01002e6:	89 fa                	mov    %edi,%edx
f01002e8:	89 f8                	mov    %edi,%eax
f01002ea:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ed:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002f2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f3:	b2 79                	mov    $0x79,%dl
f01002f5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002f6:	84 c0                	test   %al,%al
f01002f8:	78 21                	js     f010031b <cons_putc+0x6b>
f01002fa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002ff:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100304:	e8 a7 fe ff ff       	call   f01001b0 <delay>
f0100309:	89 f2                	mov    %esi,%edx
f010030b:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010030c:	84 c0                	test   %al,%al
f010030e:	78 0b                	js     f010031b <cons_putc+0x6b>
f0100310:	83 c3 01             	add    $0x1,%ebx
f0100313:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100319:	75 e9                	jne    f0100304 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100320:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100324:	ee                   	out    %al,(%dx)
f0100325:	b2 7a                	mov    $0x7a,%dl
f0100327:	b8 0d 00 00 00       	mov    $0xd,%eax
f010032c:	ee                   	out    %al,(%dx)
f010032d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100332:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if(!(c & ~0xFF))
f0100333:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100339:	75 06                	jne    f0100341 <cons_putc+0x91>
		c |= 0x700;
f010033b:	81 cf 00 07 00 00    	or     $0x700,%edi
	//cprintf("%d\n", COLOR);

	switch (c & 0xff) {
f0100341:	89 f8                	mov    %edi,%eax
f0100343:	25 ff 00 00 00       	and    $0xff,%eax
f0100348:	83 f8 09             	cmp    $0x9,%eax
f010034b:	0f 84 83 00 00 00    	je     f01003d4 <cons_putc+0x124>
f0100351:	83 f8 09             	cmp    $0x9,%eax
f0100354:	7f 0c                	jg     f0100362 <cons_putc+0xb2>
f0100356:	83 f8 08             	cmp    $0x8,%eax
f0100359:	0f 85 a9 00 00 00    	jne    f0100408 <cons_putc+0x158>
f010035f:	90                   	nop
f0100360:	eb 18                	jmp    f010037a <cons_putc+0xca>
f0100362:	83 f8 0a             	cmp    $0xa,%eax
f0100365:	8d 76 00             	lea    0x0(%esi),%esi
f0100368:	74 40                	je     f01003aa <cons_putc+0xfa>
f010036a:	83 f8 0d             	cmp    $0xd,%eax
f010036d:	8d 76 00             	lea    0x0(%esi),%esi
f0100370:	0f 85 92 00 00 00    	jne    f0100408 <cons_putc+0x158>
f0100376:	66 90                	xchg   %ax,%ax
f0100378:	eb 38                	jmp    f01003b2 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010037a:	0f b7 05 90 23 1e f0 	movzwl 0xf01e2390,%eax
f0100381:	66 85 c0             	test   %ax,%ax
f0100384:	0f 84 e8 00 00 00    	je     f0100472 <cons_putc+0x1c2>
			crt_pos--;
f010038a:	83 e8 01             	sub    $0x1,%eax
f010038d:	66 a3 90 23 1e f0    	mov    %ax,0xf01e2390
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100393:	0f b7 c0             	movzwl %ax,%eax
f0100396:	66 81 e7 00 ff       	and    $0xff00,%di
f010039b:	83 cf 20             	or     $0x20,%edi
f010039e:	8b 15 8c 23 1e f0    	mov    0xf01e238c,%edx
f01003a4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003a8:	eb 7b                	jmp    f0100425 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003aa:	66 83 05 90 23 1e f0 	addw   $0x50,0xf01e2390
f01003b1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003b2:	0f b7 05 90 23 1e f0 	movzwl 0xf01e2390,%eax
f01003b9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003bf:	c1 e8 10             	shr    $0x10,%eax
f01003c2:	66 c1 e8 06          	shr    $0x6,%ax
f01003c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c9:	c1 e0 04             	shl    $0x4,%eax
f01003cc:	66 a3 90 23 1e f0    	mov    %ax,0xf01e2390
f01003d2:	eb 51                	jmp    f0100425 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01003d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d9:	e8 d2 fe ff ff       	call   f01002b0 <cons_putc>
		cons_putc(' ');
f01003de:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e3:	e8 c8 fe ff ff       	call   f01002b0 <cons_putc>
		cons_putc(' ');
f01003e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ed:	e8 be fe ff ff       	call   f01002b0 <cons_putc>
		cons_putc(' ');
f01003f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f7:	e8 b4 fe ff ff       	call   f01002b0 <cons_putc>
		cons_putc(' ');
f01003fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0100401:	e8 aa fe ff ff       	call   f01002b0 <cons_putc>
f0100406:	eb 1d                	jmp    f0100425 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100408:	0f b7 05 90 23 1e f0 	movzwl 0xf01e2390,%eax
f010040f:	0f b7 c8             	movzwl %ax,%ecx
f0100412:	8b 15 8c 23 1e f0    	mov    0xf01e238c,%edx
f0100418:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010041c:	83 c0 01             	add    $0x1,%eax
f010041f:	66 a3 90 23 1e f0    	mov    %ax,0xf01e2390
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100425:	66 81 3d 90 23 1e f0 	cmpw   $0x7cf,0xf01e2390
f010042c:	cf 07 
f010042e:	76 42                	jbe    f0100472 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100430:	a1 8c 23 1e f0       	mov    0xf01e238c,%eax
f0100435:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010043c:	00 
f010043d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100443:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100447:	89 04 24             	mov    %eax,(%esp)
f010044a:	e8 f6 4f 00 00       	call   f0105445 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010044f:	8b 15 8c 23 1e f0    	mov    0xf01e238c,%edx
f0100455:	b8 80 07 00 00       	mov    $0x780,%eax
f010045a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100460:	83 c0 01             	add    $0x1,%eax
f0100463:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100468:	75 f0                	jne    f010045a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010046a:	66 83 2d 90 23 1e f0 	subw   $0x50,0xf01e2390
f0100471:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100472:	8b 0d 88 23 1e f0    	mov    0xf01e2388,%ecx
f0100478:	89 cb                	mov    %ecx,%ebx
f010047a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047f:	89 ca                	mov    %ecx,%edx
f0100481:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100482:	0f b7 35 90 23 1e f0 	movzwl 0xf01e2390,%esi
f0100489:	83 c1 01             	add    $0x1,%ecx
f010048c:	89 f0                	mov    %esi,%eax
f010048e:	66 c1 e8 08          	shr    $0x8,%ax
f0100492:	89 ca                	mov    %ecx,%edx
f0100494:	ee                   	out    %al,(%dx)
f0100495:	b8 0f 00 00 00       	mov    $0xf,%eax
f010049a:	89 da                	mov    %ebx,%edx
f010049c:	ee                   	out    %al,(%dx)
f010049d:	89 f0                	mov    %esi,%eax
f010049f:	89 ca                	mov    %ecx,%edx
f01004a1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004a2:	83 c4 2c             	add    $0x2c,%esp
f01004a5:	5b                   	pop    %ebx
f01004a6:	5e                   	pop    %esi
f01004a7:	5f                   	pop    %edi
f01004a8:	5d                   	pop    %ebp
f01004a9:	c3                   	ret    

f01004aa <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01004aa:	55                   	push   %ebp
f01004ab:	89 e5                	mov    %esp,%ebp
f01004ad:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01004b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01004b3:	e8 f8 fd ff ff       	call   f01002b0 <cons_putc>
}
f01004b8:	c9                   	leave  
f01004b9:	c3                   	ret    

f01004ba <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004ba:	55                   	push   %ebp
f01004bb:	89 e5                	mov    %esp,%ebp
f01004bd:	53                   	push   %ebx
f01004be:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004c1:	ba 64 00 00 00       	mov    $0x64,%edx
f01004c6:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01004c7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004cc:	a8 01                	test   $0x1,%al
f01004ce:	0f 84 d9 00 00 00    	je     f01005ad <kbd_proc_data+0xf3>
f01004d4:	b2 60                	mov    $0x60,%dl
f01004d6:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01004d7:	3c e0                	cmp    $0xe0,%al
f01004d9:	75 11                	jne    f01004ec <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01004db:	83 0d 80 23 1e f0 40 	orl    $0x40,0xf01e2380
f01004e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01004e7:	e9 c1 00 00 00       	jmp    f01005ad <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01004ec:	84 c0                	test   %al,%al
f01004ee:	79 32                	jns    f0100522 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01004f0:	8b 15 80 23 1e f0    	mov    0xf01e2380,%edx
f01004f6:	f6 c2 40             	test   $0x40,%dl
f01004f9:	75 03                	jne    f01004fe <kbd_proc_data+0x44>
f01004fb:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01004fe:	0f b6 c0             	movzbl %al,%eax
f0100501:	0f b6 80 40 68 10 f0 	movzbl -0xfef97c0(%eax),%eax
f0100508:	83 c8 40             	or     $0x40,%eax
f010050b:	0f b6 c0             	movzbl %al,%eax
f010050e:	f7 d0                	not    %eax
f0100510:	21 c2                	and    %eax,%edx
f0100512:	89 15 80 23 1e f0    	mov    %edx,0xf01e2380
f0100518:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010051d:	e9 8b 00 00 00       	jmp    f01005ad <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100522:	8b 15 80 23 1e f0    	mov    0xf01e2380,%edx
f0100528:	f6 c2 40             	test   $0x40,%dl
f010052b:	74 0c                	je     f0100539 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010052d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100530:	83 e2 bf             	and    $0xffffffbf,%edx
f0100533:	89 15 80 23 1e f0    	mov    %edx,0xf01e2380
	}

	shift |= shiftcode[data];
f0100539:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010053c:	0f b6 90 40 68 10 f0 	movzbl -0xfef97c0(%eax),%edx
f0100543:	0b 15 80 23 1e f0    	or     0xf01e2380,%edx
f0100549:	0f b6 88 40 69 10 f0 	movzbl -0xfef96c0(%eax),%ecx
f0100550:	31 ca                	xor    %ecx,%edx
f0100552:	89 15 80 23 1e f0    	mov    %edx,0xf01e2380

	c = charcode[shift & (CTL | SHIFT)][data];
f0100558:	89 d1                	mov    %edx,%ecx
f010055a:	83 e1 03             	and    $0x3,%ecx
f010055d:	8b 0c 8d 40 6a 10 f0 	mov    -0xfef95c0(,%ecx,4),%ecx
f0100564:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100568:	f6 c2 08             	test   $0x8,%dl
f010056b:	74 1a                	je     f0100587 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010056d:	89 d9                	mov    %ebx,%ecx
f010056f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100572:	83 f8 19             	cmp    $0x19,%eax
f0100575:	77 05                	ja     f010057c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100577:	83 eb 20             	sub    $0x20,%ebx
f010057a:	eb 0b                	jmp    f0100587 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010057c:	83 e9 41             	sub    $0x41,%ecx
f010057f:	83 f9 19             	cmp    $0x19,%ecx
f0100582:	77 03                	ja     f0100587 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100584:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100587:	f7 d2                	not    %edx
f0100589:	f6 c2 06             	test   $0x6,%dl
f010058c:	75 1f                	jne    f01005ad <kbd_proc_data+0xf3>
f010058e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100594:	75 17                	jne    f01005ad <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100596:	c7 04 24 11 68 10 f0 	movl   $0xf0106811,(%esp)
f010059d:	e8 69 34 00 00       	call   f0103a0b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01005a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ac:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005ad:	89 d8                	mov    %ebx,%eax
f01005af:	83 c4 14             	add    $0x14,%esp
f01005b2:	5b                   	pop    %ebx
f01005b3:	5d                   	pop    %ebp
f01005b4:	c3                   	ret    

f01005b5 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01005b5:	55                   	push   %ebp
f01005b6:	89 e5                	mov    %esp,%ebp
f01005b8:	57                   	push   %edi
f01005b9:	56                   	push   %esi
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01005be:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01005c3:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01005c6:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01005cb:	0f b7 00             	movzwl (%eax),%eax
f01005ce:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005d2:	74 11                	je     f01005e5 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005d4:	c7 05 88 23 1e f0 b4 	movl   $0x3b4,0xf01e2388
f01005db:	03 00 00 
f01005de:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005e3:	eb 16                	jmp    f01005fb <cons_init+0x46>
	} else {
		*cp = was;
f01005e5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005ec:	c7 05 88 23 1e f0 d4 	movl   $0x3d4,0xf01e2388
f01005f3:	03 00 00 
f01005f6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01005fb:	8b 0d 88 23 1e f0    	mov    0xf01e2388,%ecx
f0100601:	89 cb                	mov    %ecx,%ebx
f0100603:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100608:	89 ca                	mov    %ecx,%edx
f010060a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010060b:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060e:	89 ca                	mov    %ecx,%edx
f0100610:	ec                   	in     (%dx),%al
f0100611:	0f b6 f8             	movzbl %al,%edi
f0100614:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100617:	b8 0f 00 00 00       	mov    $0xf,%eax
f010061c:	89 da                	mov    %ebx,%edx
f010061e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010061f:	89 ca                	mov    %ecx,%edx
f0100621:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100622:	89 35 8c 23 1e f0    	mov    %esi,0xf01e238c
	crt_pos = pos;
f0100628:	0f b6 c8             	movzbl %al,%ecx
f010062b:	09 cf                	or     %ecx,%edi
f010062d:	66 89 3d 90 23 1e f0 	mov    %di,0xf01e2390

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100634:	e8 e9 fb ff ff       	call   f0100222 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100639:	0f b7 05 58 f3 11 f0 	movzwl 0xf011f358,%eax
f0100640:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100645:	89 04 24             	mov    %eax,(%esp)
f0100648:	e8 8b 32 00 00       	call   f01038d8 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010064d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100652:	b8 00 00 00 00       	mov    $0x0,%eax
f0100657:	89 da                	mov    %ebx,%edx
f0100659:	ee                   	out    %al,(%dx)
f010065a:	b2 fb                	mov    $0xfb,%dl
f010065c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100661:	ee                   	out    %al,(%dx)
f0100662:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100667:	b8 0c 00 00 00       	mov    $0xc,%eax
f010066c:	89 ca                	mov    %ecx,%edx
f010066e:	ee                   	out    %al,(%dx)
f010066f:	b2 f9                	mov    $0xf9,%dl
f0100671:	b8 00 00 00 00       	mov    $0x0,%eax
f0100676:	ee                   	out    %al,(%dx)
f0100677:	b2 fb                	mov    $0xfb,%dl
f0100679:	b8 03 00 00 00       	mov    $0x3,%eax
f010067e:	ee                   	out    %al,(%dx)
f010067f:	b2 fc                	mov    $0xfc,%dl
f0100681:	b8 00 00 00 00       	mov    $0x0,%eax
f0100686:	ee                   	out    %al,(%dx)
f0100687:	b2 f9                	mov    $0xf9,%dl
f0100689:	b8 01 00 00 00       	mov    $0x1,%eax
f010068e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068f:	b2 fd                	mov    $0xfd,%dl
f0100691:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100692:	3c ff                	cmp    $0xff,%al
f0100694:	0f 95 c0             	setne  %al
f0100697:	0f b6 f0             	movzbl %al,%esi
f010069a:	89 35 84 23 1e f0    	mov    %esi,0xf01e2384
f01006a0:	89 da                	mov    %ebx,%edx
f01006a2:	ec                   	in     (%dx),%al
f01006a3:	89 ca                	mov    %ecx,%edx
f01006a5:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a6:	85 f6                	test   %esi,%esi
f01006a8:	75 0c                	jne    f01006b6 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f01006aa:	c7 04 24 1d 68 10 f0 	movl   $0xf010681d,(%esp)
f01006b1:	e8 55 33 00 00       	call   f0103a0b <cprintf>
}
f01006b6:	83 c4 1c             	add    $0x1c,%esp
f01006b9:	5b                   	pop    %ebx
f01006ba:	5e                   	pop    %esi
f01006bb:	5f                   	pop    %edi
f01006bc:	5d                   	pop    %ebp
f01006bd:	c3                   	ret    
	...

f01006c0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006c3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006c6:	5d                   	pop    %ebp
f01006c7:	c3                   	ret    

f01006c8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006c8:	55                   	push   %ebp
f01006c9:	89 e5                	mov    %esp,%ebp
f01006cb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ce:	c7 04 24 50 6a 10 f0 	movl   $0xf0106a50,(%esp)
f01006d5:	e8 31 33 00 00       	call   f0103a0b <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006da:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006e1:	00 
f01006e2:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006e9:	f0 
f01006ea:	c7 04 24 54 6c 10 f0 	movl   $0xf0106c54,(%esp)
f01006f1:	e8 15 33 00 00       	call   f0103a0b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f6:	c7 44 24 08 a5 67 10 	movl   $0x1067a5,0x8(%esp)
f01006fd:	00 
f01006fe:	c7 44 24 04 a5 67 10 	movl   $0xf01067a5,0x4(%esp)
f0100705:	f0 
f0100706:	c7 04 24 78 6c 10 f0 	movl   $0xf0106c78,(%esp)
f010070d:	e8 f9 32 00 00       	call   f0103a0b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100712:	c7 44 24 08 49 23 1e 	movl   $0x1e2349,0x8(%esp)
f0100719:	00 
f010071a:	c7 44 24 04 49 23 1e 	movl   $0xf01e2349,0x4(%esp)
f0100721:	f0 
f0100722:	c7 04 24 9c 6c 10 f0 	movl   $0xf0106c9c,(%esp)
f0100729:	e8 dd 32 00 00       	call   f0103a0b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010072e:	c7 44 24 08 f2 43 1e 	movl   $0x1e43f2,0x8(%esp)
f0100735:	00 
f0100736:	c7 44 24 04 f2 43 1e 	movl   $0xf01e43f2,0x4(%esp)
f010073d:	f0 
f010073e:	c7 04 24 c0 6c 10 f0 	movl   $0xf0106cc0,(%esp)
f0100745:	e8 c1 32 00 00       	call   f0103a0b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074a:	b8 f1 47 1e f0       	mov    $0xf01e47f1,%eax
f010074f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100754:	89 c2                	mov    %eax,%edx
f0100756:	c1 fa 1f             	sar    $0x1f,%edx
f0100759:	c1 ea 16             	shr    $0x16,%edx
f010075c:	8d 04 02             	lea    (%edx,%eax,1),%eax
f010075f:	c1 f8 0a             	sar    $0xa,%eax
f0100762:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100766:	c7 04 24 e4 6c 10 f0 	movl   $0xf0106ce4,(%esp)
f010076d:	e8 99 32 00 00       	call   f0103a0b <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100772:	b8 00 00 00 00       	mov    $0x0,%eax
f0100777:	c9                   	leave  
f0100778:	c3                   	ret    

f0100779 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	57                   	push   %edi
f010077d:	56                   	push   %esi
f010077e:	53                   	push   %ebx
f010077f:	83 ec 1c             	sub    $0x1c,%esp
f0100782:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n",commands[i].name, commands[i].desc);
f0100787:	be e4 6f 10 f0       	mov    $0xf0106fe4,%esi
f010078c:	bf e0 6f 10 f0       	mov    $0xf0106fe0,%edi
f0100791:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100794:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100798:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f010079b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079f:	c7 04 24 69 6a 10 f0 	movl   $0xf0106a69,(%esp)
f01007a6:	e8 60 32 00 00       	call   f0103a0b <cprintf>
f01007ab:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01007ae:	83 fb 60             	cmp    $0x60,%ebx
f01007b1:	75 de                	jne    f0100791 <mon_help+0x18>
		cprintf("%s - %s\n",commands[i].name, commands[i].desc);
	return 0;
}
f01007b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b8:	83 c4 1c             	add    $0x1c,%esp
f01007bb:	5b                   	pop    %ebx
f01007bc:	5e                   	pop    %esi
f01007bd:	5f                   	pop    %edi
f01007be:	5d                   	pop    %ebp
f01007bf:	c3                   	ret    

f01007c0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	57                   	push   %edi
f01007c4:	56                   	push   %esi
f01007c5:	53                   	push   %ebx
f01007c6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007c9:	c7 04 24 10 6d 10 f0 	movl   $0xf0106d10,(%esp)
f01007d0:	e8 36 32 00 00       	call   f0103a0b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007d5:	c7 04 24 34 6d 10 f0 	movl   $0xf0106d34,(%esp)
f01007dc:	e8 2a 32 00 00       	call   f0103a0b <cprintf>

	if (tf != NULL)
f01007e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007e5:	74 0d                	je     f01007f4 <monitor+0x34>
		print_trapframe(tf);	
f01007e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ea:	89 04 24             	mov    %eax,(%esp)
f01007ed:	e8 91 34 00 00       	call   f0103c83 <print_trapframe>
f01007f2:	eb 0c                	jmp    f0100800 <monitor+0x40>
	else
		cprintf("tf is null\n");
f01007f4:	c7 04 24 72 6a 10 f0 	movl   $0xf0106a72,(%esp)
f01007fb:	e8 0b 32 00 00       	call   f0103a0b <cprintf>

	cprintf("just before while of coming out of monitor\n");
f0100800:	c7 04 24 5c 6d 10 f0 	movl   $0xf0106d5c,(%esp)
f0100807:	e8 ff 31 00 00       	call   f0103a0b <cprintf>
	while (1) {
		buf = readline("K> ");
f010080c:	c7 04 24 7e 6a 10 f0 	movl   $0xf0106a7e,(%esp)
f0100813:	e8 48 49 00 00       	call   f0105160 <readline>
f0100818:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010081a:	85 c0                	test   %eax,%eax
f010081c:	74 ee                	je     f010080c <monitor+0x4c>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010081e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100825:	be 00 00 00 00       	mov    $0x0,%esi
f010082a:	eb 06                	jmp    f0100832 <monitor+0x72>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010082c:	c6 03 00             	movb   $0x0,(%ebx)
f010082f:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100832:	0f b6 03             	movzbl (%ebx),%eax
f0100835:	84 c0                	test   %al,%al
f0100837:	74 6c                	je     f01008a5 <monitor+0xe5>
f0100839:	0f be c0             	movsbl %al,%eax
f010083c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100840:	c7 04 24 82 6a 10 f0 	movl   $0xf0106a82,(%esp)
f0100847:	e8 42 4b 00 00       	call   f010538e <strchr>
f010084c:	85 c0                	test   %eax,%eax
f010084e:	75 dc                	jne    f010082c <monitor+0x6c>
			*buf++ = 0;
		if (*buf == 0)
f0100850:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100853:	74 50                	je     f01008a5 <monitor+0xe5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100855:	83 fe 0f             	cmp    $0xf,%esi
f0100858:	75 16                	jne    f0100870 <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010085a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100861:	00 
f0100862:	c7 04 24 87 6a 10 f0 	movl   $0xf0106a87,(%esp)
f0100869:	e8 9d 31 00 00       	call   f0103a0b <cprintf>
f010086e:	eb 9c                	jmp    f010080c <monitor+0x4c>
			return 0;
		}
		argv[argc++] = buf;
f0100870:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100874:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100877:	0f b6 03             	movzbl (%ebx),%eax
f010087a:	84 c0                	test   %al,%al
f010087c:	75 0e                	jne    f010088c <monitor+0xcc>
f010087e:	66 90                	xchg   %ax,%ax
f0100880:	eb b0                	jmp    f0100832 <monitor+0x72>
			buf++;
f0100882:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100885:	0f b6 03             	movzbl (%ebx),%eax
f0100888:	84 c0                	test   %al,%al
f010088a:	74 a6                	je     f0100832 <monitor+0x72>
f010088c:	0f be c0             	movsbl %al,%eax
f010088f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100893:	c7 04 24 82 6a 10 f0 	movl   $0xf0106a82,(%esp)
f010089a:	e8 ef 4a 00 00       	call   f010538e <strchr>
f010089f:	85 c0                	test   %eax,%eax
f01008a1:	74 df                	je     f0100882 <monitor+0xc2>
f01008a3:	eb 8d                	jmp    f0100832 <monitor+0x72>
			buf++;
	}
	argv[argc] = 0;
f01008a5:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008ac:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008ad:	85 f6                	test   %esi,%esi
f01008af:	90                   	nop
f01008b0:	0f 84 56 ff ff ff    	je     f010080c <monitor+0x4c>
f01008b6:	bb e0 6f 10 f0       	mov    $0xf0106fe0,%ebx
f01008bb:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008c0:	8b 03                	mov    (%ebx),%eax
f01008c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c9:	89 04 24             	mov    %eax,(%esp)
f01008cc:	e8 48 4a 00 00       	call   f0105319 <strcmp>
f01008d1:	85 c0                	test   %eax,%eax
f01008d3:	75 23                	jne    f01008f8 <monitor+0x138>
			return commands[i].func(argc, argv, tf);
f01008d5:	6b ff 0c             	imul   $0xc,%edi,%edi
f01008d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01008db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008df:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e6:	89 34 24             	mov    %esi,(%esp)
f01008e9:	ff 97 e8 6f 10 f0    	call   *-0xfef9018(%edi)

	cprintf("just before while of coming out of monitor\n");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008ef:	85 c0                	test   %eax,%eax
f01008f1:	78 28                	js     f010091b <monitor+0x15b>
f01008f3:	e9 14 ff ff ff       	jmp    f010080c <monitor+0x4c>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008f8:	83 c7 01             	add    $0x1,%edi
f01008fb:	83 c3 0c             	add    $0xc,%ebx
f01008fe:	83 ff 08             	cmp    $0x8,%edi
f0100901:	75 bd                	jne    f01008c0 <monitor+0x100>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100903:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100906:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090a:	c7 04 24 a4 6a 10 f0 	movl   $0xf0106aa4,(%esp)
f0100911:	e8 f5 30 00 00       	call   f0103a0b <cprintf>
f0100916:	e9 f1 fe ff ff       	jmp    f010080c <monitor+0x4c>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
	cprintf("coming out of monitor\n");
f010091b:	c7 04 24 ba 6a 10 f0 	movl   $0xf0106aba,(%esp)
f0100922:	e8 e4 30 00 00       	call   f0103a0b <cprintf>
}
f0100927:	83 c4 5c             	add    $0x5c,%esp
f010092a:	5b                   	pop    %ebx
f010092b:	5e                   	pop    %esi
f010092c:	5f                   	pop    %edi
f010092d:	5d                   	pop    %ebp
f010092e:	c3                   	ret    

f010092f <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010092f:	55                   	push   %ebp
f0100930:	89 e5                	mov    %esp,%ebp
f0100932:	57                   	push   %edi
f0100933:	56                   	push   %esi
f0100934:	53                   	push   %ebx
f0100935:	81 ec 4c 01 00 00    	sub    $0x14c,%esp
	// Your code here.
	int ebp_lst, ebp_cur, ebp_prev, eip_cur, args[5];
	//__asm __volatile("movl %%ebp, %0;":"=r"(ebp_cur));
	ebp_cur = (uint32_t)read_ebp();
f010093b:	89 eb                	mov    %ebp,%ebx
	cprintf("Stack backtrace:\n");
f010093d:	c7 04 24 d1 6a 10 f0 	movl   $0xf0106ad1,(%esp)
f0100944:	e8 c2 30 00 00       	call   f0103a0b <cprintf>
	eip_cur = (uint32_t)read_eip();
f0100949:	e8 72 fd ff ff       	call   f01006c0 <read_eip>
f010094e:	89 c7                	mov    %eax,%edi
f0100950:	c7 85 e4 fe ff ff 01 	movl   $0x1,-0x11c(%ebp)
f0100957:	00 00 00 
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
	{
		if(ebp_cur == 0)
f010095a:	83 fb 01             	cmp    $0x1,%ebx
f010095d:	19 c0                	sbb    %eax,%eax
f010095f:	f7 d0                	not    %eax
f0100961:	21 85 e4 fe ff ff    	and    %eax,-0x11c(%ebp)
			k =0;				
		memset(e, 0, sizeof(struct Eipdebuginfo));
f0100967:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
f010096e:	00 
f010096f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100976:	00 
f0100977:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010097e:	e8 63 4a 00 00       	call   f01053e6 <memset>
		debuginfo_eip(eip_cur, e);
f0100983:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010098a:	00 
f010098b:	89 3c 24             	mov    %edi,(%esp)
f010098e:	e8 5b 3f 00 00       	call   f01048ee <debuginfo_eip>
		__asm __volatile("movl 8(%1), %0;":"=r"(args[0]):"r"(ebp_cur));
f0100993:	8b 43 08             	mov    0x8(%ebx),%eax
f0100996:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
		__asm __volatile("movl 12(%1), %0;":"=r"(args[1]):"r"(ebp_cur));
f010099c:	8b 4b 0c             	mov    0xc(%ebx),%ecx
f010099f:	89 8d dc fe ff ff    	mov    %ecx,-0x124(%ebp)
		__asm __volatile("movl 16(%1), %0;":"=r"(args[2]):"r"(ebp_cur));
f01009a5:	8b 43 10             	mov    0x10(%ebx),%eax
f01009a8:	89 85 d8 fe ff ff    	mov    %eax,-0x128(%ebp)
		__asm __volatile("movl 20(%1), %0;":"=r"(args[3]):"r"(ebp_cur));
f01009ae:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01009b1:	89 8d d4 fe ff ff    	mov    %ecx,-0x12c(%ebp)
		__asm __volatile("movl 24(%1), %0;":"=r"(args[4]):"r"(ebp_cur));
f01009b7:	8b 43 18             	mov    0x18(%ebx),%eax
f01009ba:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
		char s[256];
		strcpy(s, e->eip_fn_name);
f01009c0:	be 00 00 00 00       	mov    $0x0,%esi
f01009c5:	8b 46 08             	mov    0x8(%esi),%eax
f01009c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009cc:	8d 8d e8 fe ff ff    	lea    -0x118(%ebp),%ecx
f01009d2:	89 0c 24             	mov    %ecx,(%esp)
f01009d5:	e8 b0 48 00 00       	call   f010528a <strcpy>
		s[e->eip_fn_namelen] = '\0';
f01009da:	8b 46 0c             	mov    0xc(%esi),%eax
f01009dd:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f01009e4:	00 
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n", ebp_cur, eip_cur, args[0], args[1], args[2], args[3], args[4]);
f01009e5:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
f01009eb:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01009ef:	8b 8d d4 fe ff ff    	mov    -0x12c(%ebp),%ecx
f01009f5:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01009f9:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
f01009ff:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100a03:	8b 8d dc fe ff ff    	mov    -0x124(%ebp),%ecx
f0100a09:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100a0d:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
f0100a13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a17:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100a1f:	c7 04 24 88 6d 10 f0 	movl   $0xf0106d88,(%esp)
f0100a26:	e8 e0 2f 00 00       	call   f0103a0b <cprintf>
		cprintf("%s:%d:  %s+%d\n", e->eip_file, e->eip_line,s, eip_cur-e->eip_fn_addr);
f0100a2b:	8b 56 04             	mov    0x4(%esi),%edx
f0100a2e:	8b 06                	mov    (%esi),%eax
f0100a30:	2b 7e 10             	sub    0x10(%esi),%edi
f0100a33:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100a37:	8d 8d e8 fe ff ff    	lea    -0x118(%ebp),%ecx
f0100a3d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a41:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a49:	c7 04 24 e3 6a 10 f0 	movl   $0xf0106ae3,(%esp)
f0100a50:	e8 b6 2f 00 00       	call   f0103a0b <cprintf>

		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
f0100a55:	8b 7b 04             	mov    0x4(%ebx),%edi
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		
f0100a58:	8b 1b                	mov    (%ebx),%ebx
	ebp_cur = (uint32_t)read_ebp();
	cprintf("Stack backtrace:\n");
	eip_cur = (uint32_t)read_eip();
	struct Eipdebuginfo *e = NULL;
	int k =1;
	while(k != 0)	
f0100a5a:	83 bd e4 fe ff ff 00 	cmpl   $0x0,-0x11c(%ebp)
f0100a61:	0f 85 f3 fe ff ff    	jne    f010095a <mon_backtrace+0x2b>
		__asm __volatile("movl 4(%1), %0;":"=r"(eip_cur):"r"(ebp_cur));
		__asm __volatile("movl (%1), %0;":"=r"(ebp_cur):"r"(ebp_cur));		

	} 
	return 0;
}
f0100a67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a6c:	81 c4 4c 01 00 00    	add    $0x14c,%esp
f0100a72:	5b                   	pop    %ebx
f0100a73:	5e                   	pop    %esi
f0100a74:	5f                   	pop    %edi
f0100a75:	5d                   	pop    %ebp
f0100a76:	c3                   	ret    

f0100a77 <showmap>:
	res -= 1;
	return res;
}

void showmap(uintptr_t start)
{
f0100a77:	55                   	push   %ebp
f0100a78:	89 e5                	mov    %esp,%ebp
f0100a7a:	83 ec 38             	sub    $0x38,%esp
f0100a7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100a80:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100a83:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100a86:	8b 75 08             	mov    0x8(%ebp),%esi
    cprintf("%x\n", start);
f0100a89:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a8d:	c7 04 24 b4 85 10 f0 	movl   $0xf01085b4,(%esp)
f0100a94:	e8 72 2f 00 00       	call   f0103a0b <cprintf>
    pte_t *pte = pgdir_walk(boot_pgdir, (void *)start, 0);
f0100a99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100aa0:	00 
f0100aa1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aa5:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0100aaa:	89 04 24             	mov    %eax,(%esp)
f0100aad:	e8 3d 07 00 00       	call   f01011ef <pgdir_walk>
f0100ab2:	89 c3                	mov    %eax,%ebx
    if(pte == NULL)
f0100ab4:	85 c0                	test   %eax,%eax
f0100ab6:	75 15                	jne    f0100acd <showmap+0x56>
    {
      cprintf("There is no page table entry for page starting at address: %x\n", start);
f0100ab8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100abc:	c7 04 24 bc 6d 10 f0 	movl   $0xf0106dbc,(%esp)
f0100ac3:	e8 43 2f 00 00       	call   f0103a0b <cprintf>
      return;
f0100ac8:	e9 8d 00 00 00       	jmp    f0100b5a <showmap+0xe3>
    }
    if(*pte == 0)
f0100acd:	8b 38                	mov    (%eax),%edi
f0100acf:	85 ff                	test   %edi,%edi
f0100ad1:	75 12                	jne    f0100ae5 <showmap+0x6e>
    {
      cprintf("There is no page table entry for page starting at address: %x .. Seems the the virtual address is not mapped\n",start);
f0100ad3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ad7:	c7 04 24 fc 6d 10 f0 	movl   $0xf0106dfc,(%esp)
f0100ade:	e8 28 2f 00 00       	call   f0103a0b <cprintf>
      return;
f0100ae3:	eb 75                	jmp    f0100b5a <showmap+0xe3>
    }
    unsigned int perm = (unsigned int) (*pte&0xfff);
f0100ae5:	89 f8                	mov    %edi,%eax
f0100ae7:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100aec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
    cprintf("\nVirtual Address\tPhysical Address\tPermissions\n");
f0100aef:	c7 04 24 6c 6e 10 f0 	movl   $0xf0106e6c,(%esp)
f0100af6:	e8 10 2f 00 00       	call   f0103a0b <cprintf>
    cprintf("%x\t\t%x\t\t",start, (*pte&~0xfff));
f0100afb:	8b 03                	mov    (%ebx),%eax
f0100afd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b02:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b06:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b0a:	c7 04 24 f2 6a 10 f0 	movl   $0xf0106af2,(%esp)
f0100b11:	e8 f5 2e 00 00       	call   f0103a0b <cprintf>
    if((perm&0x1)==1)
f0100b16:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0100b1c:	74 0c                	je     f0100b2a <showmap+0xb3>
      cprintf("PTE_P");
f0100b1e:	c7 04 24 fb 6a 10 f0 	movl   $0xf0106afb,(%esp)
f0100b25:	e8 e1 2e 00 00       	call   f0103a0b <cprintf>
    if((perm&0x2)==2)
f0100b2a:	f6 45 e4 02          	testb  $0x2,-0x1c(%ebp)
f0100b2e:	74 0c                	je     f0100b3c <showmap+0xc5>
      cprintf(",PTE_U");
f0100b30:	c7 04 24 01 6b 10 f0 	movl   $0xf0106b01,(%esp)
f0100b37:	e8 cf 2e 00 00       	call   f0103a0b <cprintf>
    if((perm&0x4)==4)
f0100b3c:	f6 45 e4 04          	testb  $0x4,-0x1c(%ebp)
f0100b40:	74 0c                	je     f0100b4e <showmap+0xd7>
      cprintf(",PTE_W");
f0100b42:	c7 04 24 08 6b 10 f0 	movl   $0xf0106b08,(%esp)
f0100b49:	e8 bd 2e 00 00       	call   f0103a0b <cprintf>
    cprintf("\n");
f0100b4e:	c7 04 24 93 6b 10 f0 	movl   $0xf0106b93,(%esp)
f0100b55:	e8 b1 2e 00 00       	call   f0103a0b <cprintf>
    return;
}
f0100b5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100b5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100b60:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100b63:	89 ec                	mov    %ebp,%esp
f0100b65:	5d                   	pop    %ebp
f0100b66:	c3                   	ret    

f0100b67 <alloc_page>:
	}
	return 0;
}

int alloc_page(int argc, char**argv, struct Trapframe *tf)
{
f0100b67:	55                   	push   %ebp
f0100b68:	89 e5                	mov    %esp,%ebp
f0100b6a:	83 ec 28             	sub    $0x28,%esp
	if(argc>1)
f0100b6d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100b71:	7e 0e                	jle    f0100b81 <alloc_page+0x1a>
	{
		cprintf("Invalid arguments\n");
f0100b73:	c7 04 24 0f 6b 10 f0 	movl   $0xf0106b0f,(%esp)
f0100b7a:	e8 8c 2e 00 00       	call   f0103a0b <cprintf>
		return 0;
f0100b7f:	eb 67                	jmp    f0100be8 <alloc_page+0x81>
	}
	struct Page *p;
	if(page_alloc(&p)==0)
f0100b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b84:	89 04 24             	mov    %eax,(%esp)
f0100b87:	e8 13 06 00 00       	call   f010119f <page_alloc>
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	66 90                	xchg   %ax,%ax
f0100b90:	75 4a                	jne    f0100bdc <alloc_page+0x75>
	{
		cprintf("\t%x\n\n",PADDR(p));
f0100b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b95:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b9a:	77 20                	ja     f0100bbc <alloc_page+0x55>
f0100b9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ba0:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0100ba7:	f0 
f0100ba8:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
f0100baf:	00 
f0100bb0:	c7 04 24 22 6b 10 f0 	movl   $0xf0106b22,(%esp)
f0100bb7:	e8 c9 f4 ff ff       	call   f0100085 <_panic>
f0100bbc:	05 00 00 00 10       	add    $0x10000000,%eax
f0100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bc5:	c7 04 24 31 6b 10 f0 	movl   $0xf0106b31,(%esp)
f0100bcc:	e8 3a 2e 00 00       	call   f0103a0b <cprintf>
		p->pp_ref = 1;
f0100bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100bd4:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
f0100bda:	eb 0c                	jmp    f0100be8 <alloc_page+0x81>
	}
	else
		cprintf("page could not be allocated\n");
f0100bdc:	c7 04 24 37 6b 10 f0 	movl   $0xf0106b37,(%esp)
f0100be3:	e8 23 2e 00 00       	call   f0103a0b <cprintf>
	return 0;
	
}
f0100be8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bed:	c9                   	leave  
f0100bee:	c3                   	ret    

f0100bef <atoi>:
    cprintf("\n");
    return;
}

int atoi(char *s)
{
f0100bef:	55                   	push   %ebp
f0100bf0:	89 e5                	mov    %esp,%ebp
f0100bf2:	57                   	push   %edi
f0100bf3:	56                   	push   %esi
f0100bf4:	53                   	push   %ebx
f0100bf5:	83 ec 1c             	sub    $0x1c,%esp
f0100bf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int l = strlen(s)-1;
f0100bfb:	89 1c 24             	mov    %ebx,(%esp)
f0100bfe:	e8 3d 46 00 00       	call   f0105240 <strlen>
f0100c03:	89 c7                	mov    %eax,%edi
	int sum = 0;
	int i = 0;
	while(l-->=0)	  
f0100c05:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c0f:	89 f9                	mov    %edi,%ecx
f0100c11:	83 e9 01             	sub    $0x1,%ecx
f0100c14:	78 12                	js     f0100c28 <atoi+0x39>
	{
	  sum =(sum*10)+(s[i++]-48);
f0100c16:	8d 34 80             	lea    (%eax,%eax,4),%esi
f0100c19:	0f be 0c 13          	movsbl (%ebx,%edx,1),%ecx
f0100c1d:	8d 44 71 d0          	lea    -0x30(%ecx,%esi,2),%eax
f0100c21:	83 c2 01             	add    $0x1,%edx
int atoi(char *s)
{
	int l = strlen(s)-1;
	int sum = 0;
	int i = 0;
	while(l-->=0)	  
f0100c24:	39 fa                	cmp    %edi,%edx
f0100c26:	75 ee                	jne    f0100c16 <atoi+0x27>
	{
	  sum =(sum*10)+(s[i++]-48);
	}
	return sum;
}
f0100c28:	83 c4 1c             	add    $0x1c,%esp
f0100c2b:	5b                   	pop    %ebx
f0100c2c:	5e                   	pop    %esi
f0100c2d:	5f                   	pop    %edi
f0100c2e:	5d                   	pop    %ebp
f0100c2f:	c3                   	ret    

f0100c30 <HexToDecimal>:
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line
	
unsigned int HexToDecimal(char * in)
{
f0100c30:	55                   	push   %ebp
f0100c31:	89 e5                	mov    %esp,%ebp
f0100c33:	57                   	push   %edi
f0100c34:	56                   	push   %esi
f0100c35:	53                   	push   %ebx
f0100c36:	83 ec 1c             	sub    $0x1c,%esp
f0100c39:	8b 75 08             	mov    0x8(%ebp),%esi
	unsigned int res = 1, i = 0;
	char ch = *(in + 9);
f0100c3c:	0f b6 5e 09          	movzbl 0x9(%esi),%ebx
	int len = strlen(in);
f0100c40:	89 34 24             	mov    %esi,(%esp)
f0100c43:	e8 f8 45 00 00       	call   f0105240 <strlen>
	while(len > 2)
f0100c48:	bf 01 00 00 00       	mov    $0x1,%edi
f0100c4d:	83 f8 02             	cmp    $0x2,%eax
f0100c50:	7e 36                	jle    f0100c88 <HexToDecimal+0x58>
#include <inc/malloc.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line
	
unsigned int HexToDecimal(char * in)
f0100c52:	ba 02 00 00 00       	mov    $0x2,%edx
f0100c57:	29 c2                	sub    %eax,%edx
f0100c59:	89 d0                	mov    %edx,%eax
f0100c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c60:	ba 00 00 00 00       	mov    $0x0,%edx
	unsigned int res = 1, i = 0;
	char ch = *(in + 9);
	int len = strlen(in);
	while(len > 2)
	{
		int temp = ch;
f0100c65:	0f be db             	movsbl %bl,%ebx
		if(temp > 0x39)
f0100c68:	83 fb 39             	cmp    $0x39,%ebx
f0100c6b:	7e 05                	jle    f0100c72 <HexToDecimal+0x42>
		{
			temp = temp - 97 + 10;
f0100c6d:	83 eb 57             	sub    $0x57,%ebx
f0100c70:	eb 03                	jmp    f0100c75 <HexToDecimal+0x45>
		}
		else
			temp -= 0x30;
f0100c72:	83 eb 30             	sub    $0x30,%ebx
		res += (0x00000001 << (4*i)) * temp;
f0100c75:	d3 e3                	shl    %cl,%ebx
f0100c77:	01 df                	add    %ebx,%edi
		i++;
		len--;
		ch = *(in + 9 - i);
f0100c79:	0f b6 5c 16 08       	movzbl 0x8(%esi,%edx,1),%ebx
f0100c7e:	83 ea 01             	sub    $0x1,%edx
f0100c81:	83 c1 04             	add    $0x4,%ecx
unsigned int HexToDecimal(char * in)
{
	unsigned int res = 1, i = 0;
	char ch = *(in + 9);
	int len = strlen(in);
	while(len > 2)
f0100c84:	39 c2                	cmp    %eax,%edx
f0100c86:	75 dd                	jne    f0100c65 <HexToDecimal+0x35>
f0100c88:	8d 47 ff             	lea    -0x1(%edi),%eax
		len--;
		ch = *(in + 9 - i);
	}
	res -= 1;
	return res;
}
f0100c8b:	83 c4 1c             	add    $0x1c,%esp
f0100c8e:	5b                   	pop    %ebx
f0100c8f:	5e                   	pop    %esi
f0100c90:	5f                   	pop    %edi
f0100c91:	5d                   	pop    %ebp
f0100c92:	c3                   	ret    

f0100c93 <changeperm>:
	return 0;
	
}

int changeperm(int argc, char**argv, struct Trapframe *tf)
{
f0100c93:	55                   	push   %ebp
f0100c94:	89 e5                	mov    %esp,%ebp
f0100c96:	56                   	push   %esi
f0100c97:	53                   	push   %ebx
f0100c98:	83 ec 10             	sub    $0x10,%esp
f0100c9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	unsigned int perm = HexToDecimal(argv[2]);
f0100c9e:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ca1:	89 04 24             	mov    %eax,(%esp)
f0100ca4:	e8 87 ff ff ff       	call   f0100c30 <HexToDecimal>
f0100ca9:	89 c6                	mov    %eax,%esi
	unsigned int va = atoi(argv[1]);
f0100cab:	8b 43 04             	mov    0x4(%ebx),%eax
f0100cae:	89 04 24             	mov    %eax,(%esp)
f0100cb1:	e8 39 ff ff ff       	call   f0100bef <atoi>
	if(perm>7)
f0100cb6:	83 fe 07             	cmp    $0x7,%esi
f0100cb9:	76 0e                	jbe    f0100cc9 <changeperm+0x36>
	{
	  cprintf("Invalid permissions: enter either 1, 2, or 4\n");
f0100cbb:	c7 04 24 c0 6e 10 f0 	movl   $0xf0106ec0,(%esp)
f0100cc2:	e8 44 2d 00 00       	call   f0103a0b <cprintf>
	  return 0;
f0100cc7:	eb 46                	jmp    f0100d0f <changeperm+0x7c>
	}
	pte_t *pte = pgdir_walk(boot_pgdir, (void *)va, 0);
f0100cc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100cd0:	00 
f0100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd5:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0100cda:	89 04 24             	mov    %eax,(%esp)
f0100cdd:	e8 0d 05 00 00       	call   f01011ef <pgdir_walk>
	if(pte != NULL) {
f0100ce2:	85 c0                	test   %eax,%eax
f0100ce4:	74 1d                	je     f0100d03 <changeperm+0x70>
	      *pte = *pte &~0xfff;
	      *pte = *pte | perm | PTE_P;
f0100ce6:	83 ce 01             	or     $0x1,%esi
f0100ce9:	8b 10                	mov    (%eax),%edx
f0100ceb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100cf1:	09 d6                	or     %edx,%esi
f0100cf3:	89 30                	mov    %esi,(%eax)
	      cprintf("changed\n");
f0100cf5:	c7 04 24 54 6b 10 f0 	movl   $0xf0106b54,(%esp)
f0100cfc:	e8 0a 2d 00 00       	call   f0103a0b <cprintf>
	      return 0; 
f0100d01:	eb 0c                	jmp    f0100d0f <changeperm+0x7c>
	}
	else
	{
	    cprintf("Page Table entry not found!\n");
f0100d03:	c7 04 24 5d 6b 10 f0 	movl   $0xf0106b5d,(%esp)
f0100d0a:	e8 fc 2c 00 00       	call   f0103a0b <cprintf>
	}
	return 0;
}
f0100d0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d14:	83 c4 10             	add    $0x10,%esp
f0100d17:	5b                   	pop    %ebx
f0100d18:	5e                   	pop    %esi
f0100d19:	5d                   	pop    %ebp
f0100d1a:	c3                   	ret    

f0100d1b <free_page>:
		cprintf("\tfree\n\n");
	return 0;
}

int free_page(int argc, char**argv, struct Trapframe *tf)
{
f0100d1b:	55                   	push   %ebp
f0100d1c:	89 e5                	mov    %esp,%ebp
f0100d1e:	83 ec 18             	sub    $0x18,%esp
	if(argc>2)
f0100d21:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100d25:	7e 0e                	jle    f0100d35 <free_page+0x1a>
	{
		cprintf("Invalid arguments\n");
f0100d27:	c7 04 24 0f 6b 10 f0 	movl   $0xf0106b0f,(%esp)
f0100d2e:	e8 d8 2c 00 00       	call   f0103a0b <cprintf>
		return 0;
f0100d33:	eb 51                	jmp    f0100d86 <free_page+0x6b>
	}
	unsigned int va = HexToDecimal(argv[1]);
f0100d35:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d38:	8b 40 04             	mov    0x4(%eax),%eax
f0100d3b:	89 04 24             	mov    %eax,(%esp)
f0100d3e:	e8 ed fe ff ff       	call   f0100c30 <HexToDecimal>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100d43:	c1 e8 0c             	shr    $0xc,%eax
f0100d46:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f0100d4c:	72 1c                	jb     f0100d6a <free_page+0x4f>
		panic("pa2page called with invalid pa");
f0100d4e:	c7 44 24 08 f0 6e 10 	movl   $0xf0106ef0,0x8(%esp)
f0100d55:	f0 
f0100d56:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100d5d:	00 
f0100d5e:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f0100d65:	e8 1b f3 ff ff       	call   f0100085 <_panic>
	return &pages[PPN(pa)];
f0100d6a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d6d:	c1 e0 02             	shl    $0x2,%eax
	struct Page *p = pa2page(va);
	if(p!=NULL)
f0100d70:	03 05 9c 43 1e f0    	add    0xf01e439c,%eax
f0100d76:	74 0e                	je     f0100d86 <free_page+0x6b>
	{
		p->pp_ref = 0;
f0100d78:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		page_free(p);
f0100d7e:	89 04 24             	mov    %eax,(%esp)
f0100d81:	e8 60 01 00 00       	call   f0100ee6 <page_free>
	}
	return 0;
}
f0100d86:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d8b:	c9                   	leave  
f0100d8c:	c3                   	ret    

f0100d8d <page_status>:
	}
	return 0;
}

int page_status(int argc, char**argv, struct Trapframe *tf)
{
f0100d8d:	55                   	push   %ebp
f0100d8e:	89 e5                	mov    %esp,%ebp
f0100d90:	53                   	push   %ebx
f0100d91:	83 ec 14             	sub    $0x14,%esp
	if(argc>2)
f0100d94:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100d98:	7e 0e                	jle    f0100da8 <page_status+0x1b>
	{
		cprintf("Invalid arguments\n");
f0100d9a:	c7 04 24 0f 6b 10 f0 	movl   $0xf0106b0f,(%esp)
f0100da1:	e8 65 2c 00 00       	call   f0103a0b <cprintf>
		return 0;
f0100da6:	eb 71                	jmp    f0100e19 <page_status+0x8c>
	}
	unsigned int va = HexToDecimal(argv[1]);	
f0100da8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dab:	8b 40 04             	mov    0x4(%eax),%eax
f0100dae:	89 04 24             	mov    %eax,(%esp)
f0100db1:	e8 7a fe ff ff       	call   f0100c30 <HexToDecimal>
f0100db6:	89 c3                	mov    %eax,%ebx
	cprintf("%x\n",va);
f0100db8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dbc:	c7 04 24 b4 85 10 f0 	movl   $0xf01085b4,(%esp)
f0100dc3:	e8 43 2c 00 00       	call   f0103a0b <cprintf>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100dc8:	c1 eb 0c             	shr    $0xc,%ebx
f0100dcb:	3b 1d 90 43 1e f0    	cmp    0xf01e4390,%ebx
f0100dd1:	72 1c                	jb     f0100def <page_status+0x62>
		panic("pa2page called with invalid pa");
f0100dd3:	c7 44 24 08 f0 6e 10 	movl   $0xf0106ef0,0x8(%esp)
f0100dda:	f0 
f0100ddb:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100de2:	00 
f0100de3:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f0100dea:	e8 96 f2 ff ff       	call   f0100085 <_panic>
	struct Page *p = pa2page(va);
	if(p->pp_ref>0)
f0100def:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f0100df2:	a1 9c 43 1e f0       	mov    0xf01e439c,%eax
f0100df7:	66 83 7c 90 08 00    	cmpw   $0x0,0x8(%eax,%edx,4)
f0100dfd:	74 0e                	je     f0100e0d <page_status+0x80>
		cprintf("\tallocated\n\n");
f0100dff:	c7 04 24 88 6b 10 f0 	movl   $0xf0106b88,(%esp)
f0100e06:	e8 00 2c 00 00       	call   f0103a0b <cprintf>
f0100e0b:	eb 0c                	jmp    f0100e19 <page_status+0x8c>
	else
		cprintf("\tfree\n\n");
f0100e0d:	c7 04 24 95 6b 10 f0 	movl   $0xf0106b95,(%esp)
f0100e14:	e8 f2 2b 00 00       	call   f0103a0b <cprintf>
	return 0;
}
f0100e19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e1e:	83 c4 14             	add    $0x14,%esp
f0100e21:	5b                   	pop    %ebx
f0100e22:	5d                   	pop    %ebp
f0100e23:	c3                   	ret    

f0100e24 <showmappings>:
	}
	return sum;
}

int showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100e24:	55                   	push   %ebp
f0100e25:	89 e5                	mov    %esp,%ebp
f0100e27:	57                   	push   %edi
f0100e28:	56                   	push   %esi
f0100e29:	53                   	push   %ebx
f0100e2a:	83 ec 1c             	sub    $0x1c,%esp
f0100e2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if(argc < 2)
	{
	    cprintf("invalid arguments\n");
	    return 0;
f0100e30:	bb 01 00 00 00       	mov    $0x1,%ebx
	return sum;
}

int showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if(argc < 2)
f0100e35:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100e39:	7f 0e                	jg     f0100e49 <showmappings+0x25>
	{
	    cprintf("invalid arguments\n");
f0100e3b:	c7 04 24 9d 6b 10 f0 	movl   $0xf0106b9d,(%esp)
f0100e42:	e8 c4 2b 00 00       	call   f0103a0b <cprintf>
	    return 0;
f0100e47:	eb 2d                	jmp    f0100e76 <showmappings+0x52>
	}
	uintptr_t va, end;
	int i = 1;
	while(i<argc) 
	{
	  va = HexToDecimal(argv[i]);
f0100e49:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100e4c:	89 04 24             	mov    %eax,(%esp)
f0100e4f:	e8 dc fd ff ff       	call   f0100c30 <HexToDecimal>
f0100e54:	89 c6                	mov    %eax,%esi
	  cprintf("va: %x\n",va);
f0100e56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5a:	c7 04 24 b0 6b 10 f0 	movl   $0xf0106bb0,(%esp)
f0100e61:	e8 a5 2b 00 00       	call   f0103a0b <cprintf>
	  showmap(va);	
f0100e66:	89 34 24             	mov    %esi,(%esp)
f0100e69:	e8 09 fc ff ff       	call   f0100a77 <showmap>
	  i++;
f0100e6e:	83 c3 01             	add    $0x1,%ebx
	    cprintf("invalid arguments\n");
	    return 0;
	}
	uintptr_t va, end;
	int i = 1;
	while(i<argc) 
f0100e71:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100e74:	7f d3                	jg     f0100e49 <showmappings+0x25>
	  cprintf("va: %x\n",va);
	  showmap(va);	
	  i++;
	}
	return 0;
}
f0100e76:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7b:	83 c4 1c             	add    $0x1c,%esp
f0100e7e:	5b                   	pop    %ebx
f0100e7f:	5e                   	pop    %esi
f0100e80:	5f                   	pop    %edi
f0100e81:	5d                   	pop    %ebp
f0100e82:	c3                   	ret    
	...

f0100e90 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0100e90:	55                   	push   %ebp
f0100e91:	89 e5                	mov    %esp,%ebp
f0100e93:	83 ec 0c             	sub    $0xc,%esp
f0100e96:	89 1c 24             	mov    %ebx,(%esp)
f0100e99:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e9d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100ea1:	89 c3                	mov    %eax,%ebx
f0100ea3:	89 d7                	mov    %edx,%edi
	// Initialize boot_freemem if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
f0100ea5:	83 3d b4 25 1e f0 00 	cmpl   $0x0,0xf01e25b4
f0100eac:	75 0a                	jne    f0100eb8 <boot_alloc+0x28>
		boot_freemem = end;
f0100eae:	c7 05 b4 25 1e f0 f2 	movl   $0xf01e43f2,0xf01e25b4
f0100eb5:	43 1e f0 

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	//		(hint: look in types.h for some handy macros)
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100eb8:	a1 b4 25 1e f0       	mov    0xf01e25b4,%eax
f0100ebd:	8d 4c 38 ff          	lea    -0x1(%eax,%edi,1),%ecx
f0100ec1:	89 c8                	mov    %ecx,%eax
f0100ec3:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ec8:	f7 f7                	div    %edi
f0100eca:	89 c8                	mov    %ecx,%eax
f0100ecc:	29 d0                	sub    %edx,%eax
	//	Step 2: save current value of boot_freemem as allocated chunk
	v = boot_freemem;
	//	Step 3: increase boot_freemem to record allocation
	boot_freemem += n;	
f0100ece:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
f0100ed1:	89 1d b4 25 1e f0    	mov    %ebx,0xf01e25b4
	//	Step 4: return allocated chunk
	//cprintf("boot_freemem %x", boot_freemem);

	return v;
}
f0100ed7:	8b 1c 24             	mov    (%esp),%ebx
f0100eda:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100ede:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100ee2:	89 ec                	mov    %ebp,%esp
f0100ee4:	5d                   	pop    %ebp
f0100ee5:	c3                   	ret    

f0100ee6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100ee6:	55                   	push   %ebp
f0100ee7:	89 e5                	mov    %esp,%ebp
f0100ee9:	8b 45 08             	mov    0x8(%ebp),%eax
	LIST_INSERT_HEAD(&page_free_list, pp,pp_link);
f0100eec:	8b 15 b8 25 1e f0    	mov    0xf01e25b8,%edx
f0100ef2:	89 10                	mov    %edx,(%eax)
f0100ef4:	85 d2                	test   %edx,%edx
f0100ef6:	74 09                	je     f0100f01 <page_free+0x1b>
f0100ef8:	8b 15 b8 25 1e f0    	mov    0xf01e25b8,%edx
f0100efe:	89 42 04             	mov    %eax,0x4(%edx)
f0100f01:	a3 b8 25 1e f0       	mov    %eax,0xf01e25b8
f0100f06:	c7 40 04 b8 25 1e f0 	movl   $0xf01e25b8,0x4(%eax)
}
f0100f0d:	5d                   	pop    %ebp
f0100f0e:	c3                   	ret    

f0100f0f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100f0f:	55                   	push   %ebp
f0100f10:	89 e5                	mov    %esp,%ebp
f0100f12:	83 ec 04             	sub    $0x4,%esp
f0100f15:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f18:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100f1c:	83 ea 01             	sub    $0x1,%edx
f0100f1f:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100f23:	66 85 d2             	test   %dx,%dx
f0100f26:	75 08                	jne    f0100f30 <page_decref+0x21>
		page_free(pp);
f0100f28:	89 04 24             	mov    %eax,(%esp)
f0100f2b:	e8 b6 ff ff ff       	call   f0100ee6 <page_free>
}
f0100f30:	c9                   	leave  
f0100f31:	c3                   	ret    

f0100f32 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100f32:	55                   	push   %ebp
f0100f33:	89 e5                	mov    %esp,%ebp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100f35:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0100f3a:	85 c0                	test   %eax,%eax
f0100f3c:	74 08                	je     f0100f46 <tlb_invalidate+0x14>
f0100f3e:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f41:	39 50 5c             	cmp    %edx,0x5c(%eax)
f0100f44:	75 06                	jne    f0100f4c <tlb_invalidate+0x1a>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f49:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100f4c:	5d                   	pop    %ebp
f0100f4d:	c3                   	ret    

f0100f4e <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f4e:	55                   	push   %ebp
f0100f4f:	89 e5                	mov    %esp,%ebp
f0100f51:	53                   	push   %ebx
f0100f52:	83 ec 14             	sub    $0x14,%esp
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	int i, last_used_page;
	LIST_INIT(&page_free_list);
f0100f55:	c7 05 b8 25 1e f0 00 	movl   $0x0,0xf01e25b8
f0100f5c:	00 00 00 
		if(i<20){
			cprintf("pages[%d] %x\n", i, &pages[i]);
			cprintf("first: %x\n",LIST_FIRST(&page_free_list));}
	 	//cprintf("next: %x\n",link));
	}*/
	pages[0].pp_ref = 1;
f0100f5f:	a1 9c 43 1e f0       	mov    0xf01e439c,%eax
f0100f64:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	for(i = 1;i<basemem/PGSIZE;i++)
f0100f6a:	81 3d ac 25 1e f0 ff 	cmpl   $0x1fff,0xf01e25ac
f0100f71:	1f 00 00 
f0100f74:	76 65                	jbe    f0100fdb <page_init+0x8d>
f0100f76:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f7b:	ba 01 00 00 00       	mov    $0x1,%edx
	{
		pages[i].pp_ref = 0;
f0100f80:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100f83:	c1 e0 02             	shl    $0x2,%eax
f0100f86:	8b 0d 9c 43 1e f0    	mov    0xf01e439c,%ecx
f0100f8c:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100f93:	8b 0d b8 25 1e f0    	mov    0xf01e25b8,%ecx
f0100f99:	8b 1d 9c 43 1e f0    	mov    0xf01e439c,%ebx
f0100f9f:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
f0100fa2:	85 c9                	test   %ecx,%ecx
f0100fa4:	74 11                	je     f0100fb7 <page_init+0x69>
f0100fa6:	89 c3                	mov    %eax,%ebx
f0100fa8:	03 1d 9c 43 1e f0    	add    0xf01e439c,%ebx
f0100fae:	8b 0d b8 25 1e f0    	mov    0xf01e25b8,%ecx
f0100fb4:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100fb7:	03 05 9c 43 1e f0    	add    0xf01e439c,%eax
f0100fbd:	a3 b8 25 1e f0       	mov    %eax,0xf01e25b8
f0100fc2:	c7 40 04 b8 25 1e f0 	movl   $0xf01e25b8,0x4(%eax)
			cprintf("pages[%d] %x\n", i, &pages[i]);
			cprintf("first: %x\n",LIST_FIRST(&page_free_list));}
	 	//cprintf("next: %x\n",link));
	}*/
	pages[0].pp_ref = 1;
	for(i = 1;i<basemem/PGSIZE;i++)
f0100fc9:	83 c2 01             	add    $0x1,%edx
f0100fcc:	89 d0                	mov    %edx,%eax
f0100fce:	8b 0d ac 25 1e f0    	mov    0xf01e25ac,%ecx
f0100fd4:	c1 e9 0c             	shr    $0xc,%ecx
f0100fd7:	39 d1                	cmp    %edx,%ecx
f0100fd9:	77 a5                	ja     f0100f80 <page_init+0x32>
f0100fdb:	b8 80 07 00 00       	mov    $0x780,%eax
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	for(i=IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++)
	{
		pages[i].pp_ref = 1;
f0100fe0:	8b 15 9c 43 1e f0    	mov    0xf01e439c,%edx
f0100fe6:	66 c7 44 02 08 01 00 	movw   $0x1,0x8(%edx,%eax,1)
f0100fed:	83 c0 0c             	add    $0xc,%eax
	for(i = 1;i<basemem/PGSIZE;i++)
	{
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
	for(i=IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++)
f0100ff0:	3d 00 0c 00 00       	cmp    $0xc00,%eax
f0100ff5:	75 e9                	jne    f0100fe0 <page_init+0x92>
	{
		pages[i].pp_ref = 1;
	}
	for(i=EXTPHYSMEM/PGSIZE;i<(ROUNDUP((PADDR(end)), PGSIZE)/PGSIZE);i++)
f0100ff7:	b8 f2 43 1e f0       	mov    $0xf01e43f2,%eax
f0100ffc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101001:	76 2a                	jbe    f010102d <page_init+0xdf>
f0101003:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0101008:	c1 e8 0c             	shr    $0xc,%eax
f010100b:	3d 00 01 00 00       	cmp    $0x100,%eax
f0101010:	76 43                	jbe    f0101055 <page_init+0x107>
	{
		pages[i].pp_ref = 1;
f0101012:	8b 15 9c 43 1e f0    	mov    0xf01e439c,%edx
f0101018:	66 c7 82 08 0c 00 00 	movw   $0x1,0xc08(%edx)
f010101f:	01 00 
f0101021:	b9 01 01 00 00       	mov    $0x101,%ecx
f0101026:	ba 01 01 00 00       	mov    $0x101,%edx
f010102b:	eb 20                	jmp    f010104d <page_init+0xff>
	}
	for(i=IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++)
	{
		pages[i].pp_ref = 1;
	}
	for(i=EXTPHYSMEM/PGSIZE;i<(ROUNDUP((PADDR(end)), PGSIZE)/PGSIZE);i++)
f010102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101031:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0101038:	f0 
f0101039:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
f0101040:	00 
f0101041:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101048:	e8 38 f0 ff ff       	call   f0100085 <_panic>
f010104d:	39 d0                	cmp    %edx,%eax
f010104f:	0f 87 b1 00 00 00    	ja     f0101106 <page_init+0x1b8>
	{
		pages[i].pp_ref = 1;
	}
	unsigned tempadd1 = (unsigned) PADDR(boot_freemem);
f0101055:	8b 15 b4 25 1e f0    	mov    0xf01e25b4,%edx
f010105b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101061:	77 20                	ja     f0101083 <page_init+0x135>
f0101063:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101067:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f010106e:	f0 
f010106f:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0101076:	00 
f0101077:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010107e:	e8 02 f0 ff ff       	call   f0100085 <_panic>
	for(i=(ROUNDUP((PADDR(end)),PGSIZE)/PGSIZE);i <= tempadd1/PGSIZE;i++)
f0101083:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101089:	c1 ea 0c             	shr    $0xc,%edx
f010108c:	6b c8 0c             	imul   $0xc,%eax,%ecx
f010108f:	eb 13                	jmp    f01010a4 <page_init+0x156>
	{
		pages[i].pp_ref = 1;
f0101091:	8b 1d 9c 43 1e f0    	mov    0xf01e439c,%ebx
f0101097:	66 c7 44 0b 08 01 00 	movw   $0x1,0x8(%ebx,%ecx,1)
	for(i=EXTPHYSMEM/PGSIZE;i<(ROUNDUP((PADDR(end)), PGSIZE)/PGSIZE);i++)
	{
		pages[i].pp_ref = 1;
	}
	unsigned tempadd1 = (unsigned) PADDR(boot_freemem);
	for(i=(ROUNDUP((PADDR(end)),PGSIZE)/PGSIZE);i <= tempadd1/PGSIZE;i++)
f010109e:	83 c0 01             	add    $0x1,%eax
f01010a1:	83 c1 0c             	add    $0xc,%ecx
f01010a4:	39 c2                	cmp    %eax,%edx
f01010a6:	73 e9                	jae    f0101091 <page_init+0x143>
	{
		pages[i].pp_ref = 1;
	}
	for(i=((unsigned)tempadd1/PGSIZE)+1;i<npage;i++)
f01010a8:	83 c2 01             	add    $0x1,%edx
f01010ab:	6b c2 0c             	imul   $0xc,%edx,%eax
f01010ae:	eb 4c                	jmp    f01010fc <page_init+0x1ae>
	{
		pages[i].pp_ref = 0;
f01010b0:	8b 0d 9c 43 1e f0    	mov    0xf01e439c,%ecx
f01010b6:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f01010bd:	8b 0d b8 25 1e f0    	mov    0xf01e25b8,%ecx
f01010c3:	8b 1d 9c 43 1e f0    	mov    0xf01e439c,%ebx
f01010c9:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
f01010cc:	85 c9                	test   %ecx,%ecx
f01010ce:	74 11                	je     f01010e1 <page_init+0x193>
f01010d0:	89 c3                	mov    %eax,%ebx
f01010d2:	03 1d 9c 43 1e f0    	add    0xf01e439c,%ebx
f01010d8:	8b 0d b8 25 1e f0    	mov    0xf01e25b8,%ecx
f01010de:	89 59 04             	mov    %ebx,0x4(%ecx)
f01010e1:	89 c1                	mov    %eax,%ecx
f01010e3:	03 0d 9c 43 1e f0    	add    0xf01e439c,%ecx
f01010e9:	89 0d b8 25 1e f0    	mov    %ecx,0xf01e25b8
f01010ef:	c7 41 04 b8 25 1e f0 	movl   $0xf01e25b8,0x4(%ecx)
	unsigned tempadd1 = (unsigned) PADDR(boot_freemem);
	for(i=(ROUNDUP((PADDR(end)),PGSIZE)/PGSIZE);i <= tempadd1/PGSIZE;i++)
	{
		pages[i].pp_ref = 1;
	}
	for(i=((unsigned)tempadd1/PGSIZE)+1;i<npage;i++)
f01010f6:	83 c2 01             	add    $0x1,%edx
f01010f9:	83 c0 0c             	add    $0xc,%eax
f01010fc:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0101102:	72 ac                	jb     f01010b0 <page_init+0x162>
f0101104:	eb 1a                	jmp    f0101120 <page_init+0x1d2>
	{
		pages[i].pp_ref = 1;
	}
	for(i=EXTPHYSMEM/PGSIZE;i<(ROUNDUP((PADDR(end)), PGSIZE)/PGSIZE);i++)
	{
		pages[i].pp_ref = 1;
f0101106:	6b d2 0c             	imul   $0xc,%edx,%edx
f0101109:	8b 1d 9c 43 1e f0    	mov    0xf01e439c,%ebx
f010110f:	66 c7 44 1a 08 01 00 	movw   $0x1,0x8(%edx,%ebx,1)
	}
	for(i=IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++)
	{
		pages[i].pp_ref = 1;
	}
	for(i=EXTPHYSMEM/PGSIZE;i<(ROUNDUP((PADDR(end)), PGSIZE)/PGSIZE);i++)
f0101116:	83 c1 01             	add    $0x1,%ecx
f0101119:	89 ca                	mov    %ecx,%edx
f010111b:	e9 2d ff ff ff       	jmp    f010104d <page_init+0xff>
		if(pages[i].pp_ref == 0) 
		{
                	c_free++;
		}

}
f0101120:	83 c4 14             	add    $0x14,%esp
f0101123:	5b                   	pop    %ebx
f0101124:	5d                   	pop    %ebp
f0101125:	c3                   	ret    

f0101126 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101126:	55                   	push   %ebp
f0101127:	89 e5                	mov    %esp,%ebp
f0101129:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;
	pgdir = &pgdir[PDX(va)];
	//cprintf("*pgdir@%x\n",*pgdir);
	//*pgdir = *pgdir;//| PTE_P;
	if (!(*pgdir & PTE_P))
f010112c:	89 d1                	mov    %edx,%ecx
f010112e:	c1 e9 16             	shr    $0x16,%ecx
f0101131:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
f0101134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101139:	f6 c1 01             	test   $0x1,%cl
f010113c:	74 5f                	je     f010119d <check_va2pa+0x77>
	{
		return ~0;
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010113e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101144:	89 c8                	mov    %ecx,%eax
f0101146:	c1 e8 0c             	shr    $0xc,%eax
f0101149:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f010114f:	72 20                	jb     f0101171 <check_va2pa+0x4b>
f0101151:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101155:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f010115c:	f0 
f010115d:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
f0101164:	00 
f0101165:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010116c:	e8 14 ef ff ff       	call   f0100085 <_panic>
        //cprintf("*p: %x",*p);
	//cprintf("Function check_va2pa(),\n\t: PTE_ADDR(p[PTX(va)]) = %x p[PTX(va)]: %x PTX(va): %x\n",PTE_ADDR(p[PTX(va)]), p[PTX(va)], PTX(va));
	//*p = *p | PTE_P;
	if (!(p[PTX(va)] & PTE_P))
f0101171:	c1 ea 0c             	shr    $0xc,%edx
f0101174:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010117a:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0101181:	a8 01                	test   $0x1,%al
f0101183:	75 13                	jne    f0101198 <check_va2pa+0x72>
	{
		cprintf("Check Perm 2");
f0101185:	c7 04 24 15 76 10 f0 	movl   $0xf0107615,(%esp)
f010118c:	e8 7a 28 00 00       	call   f0103a0b <cprintf>
f0101191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return ~0;
f0101196:	eb 05                	jmp    f010119d <check_va2pa+0x77>
	}
	return PTE_ADDR(p[PTX(va)]);
f0101198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f010119d:	c9                   	leave  
f010119e:	c3                   	ret    

f010119f <page_alloc>:
//   -E_NO_MEM -- otherwise 
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
int
page_alloc(struct Page **pp_store)
{	
f010119f:	55                   	push   %ebp
f01011a0:	89 e5                	mov    %esp,%ebp
f01011a2:	83 ec 18             	sub    $0x18,%esp
f01011a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	*pp_store = LIST_FIRST(&page_free_list); // page_free_list points to the first element of the free list
f01011a8:	8b 15 b8 25 1e f0    	mov    0xf01e25b8,%edx
f01011ae:	89 11                	mov    %edx,(%ecx)
	if(*pp_store != NULL)
f01011b0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01011b5:	85 d2                	test   %edx,%edx
f01011b7:	74 34                	je     f01011ed <page_alloc+0x4e>
	{
		LIST_REMOVE(*pp_store, pp_link);
f01011b9:	8b 02                	mov    (%edx),%eax
f01011bb:	85 c0                	test   %eax,%eax
f01011bd:	74 06                	je     f01011c5 <page_alloc+0x26>
f01011bf:	8b 52 04             	mov    0x4(%edx),%edx
f01011c2:	89 50 04             	mov    %edx,0x4(%eax)
f01011c5:	8b 01                	mov    (%ecx),%eax
f01011c7:	8b 50 04             	mov    0x4(%eax),%edx
f01011ca:	8b 00                	mov    (%eax),%eax
f01011cc:	89 02                	mov    %eax,(%edx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f01011ce:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01011d5:	00 
f01011d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011dd:	00 
f01011de:	8b 01                	mov    (%ecx),%eax
f01011e0:	89 04 24             	mov    %eax,(%esp)
f01011e3:	e8 fe 41 00 00       	call   f01053e6 <memset>
f01011e8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
	{
		return -E_NO_MEM;
	}
	//return pp_store;
}
f01011ed:	c9                   	leave  
f01011ee:	c3                   	ret    

f01011ef <pgdir_walk>:
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// more permissive than strictly necessary.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01011ef:	55                   	push   %ebp
f01011f0:	89 e5                	mov    %esp,%ebp
f01011f2:	56                   	push   %esi
f01011f3:	53                   	push   %ebx
f01011f4:	83 ec 20             	sub    $0x20,%esp
f01011f7:	8b 55 10             	mov    0x10(%ebp),%edx
	int c = 0;
	if(create==3)
f01011fa:	83 fa 03             	cmp    $0x3,%edx
f01011fd:	0f 84 4f 01 00 00    	je     f0101352 <pgdir_walk+0x163>
	}
	if(c==3)
		cprintf("\nIn pgdir_walk()..\n");
	/*Walking throgh the pgdir to get page table  */
	unsigned int pgdir_index =(unsigned int)va >> PDXSHIFT;
        physaddr_t phy_pgdir = PADDR(pgdir);
f0101203:	8b 45 08             	mov    0x8(%ebp),%eax
f0101206:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010120b:	77 20                	ja     f010122d <pgdir_walk+0x3e>
f010120d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101211:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0101218:	f0 
f0101219:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0101220:	00 
f0101221:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101228:	e8 58 ee ff ff       	call   f0100085 <_panic>
		c = 3;
	}
	if(c==3)
		cprintf("\nIn pgdir_walk()..\n");
	/*Walking throgh the pgdir to get page table  */
	unsigned int pgdir_index =(unsigned int)va >> PDXSHIFT;
f010122d:	8b 75 0c             	mov    0xc(%ebp),%esi
        physaddr_t phy_pgdir = PADDR(pgdir);
	//*pt_base gives the base of page table
        physaddr_t pt_base = phy_pgdir + (pgdir_index*4) ;
f0101230:	89 f1                	mov    %esi,%ecx
f0101232:	c1 e9 16             	shr    $0x16,%ecx
f0101235:	8d 9c 88 00 00 00 10 	lea    0x10000000(%eax,%ecx,4),%ebx
	//vpt_base is the virtual address for the physical address of the page table
        uintptr_t *vpt_base = ((unsigned int *)KADDR(pt_base));
f010123c:	89 d8                	mov    %ebx,%eax
f010123e:	c1 e8 0c             	shr    $0xc,%eax
f0101241:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f0101247:	72 20                	jb     f0101269 <pgdir_walk+0x7a>
f0101249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010124d:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0101254:	f0 
f0101255:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f010125c:	00 
f010125d:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101264:	e8 1c ee ff ff       	call   f0100085 <_panic>
f0101269:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
 	//vpt_base is 0 if there is nothing mapped.. pgdir cannot hold a garbage value.. If pgdir holds a garbage value then no check can determine the presence or absence of a mapping
	if((*(int *)vpt_base) == 0) 
f010126f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101272:	0f 85 88 00 00 00    	jne    f0101300 <pgdir_walk+0x111>
	{
		if(create==0)
f0101278:	85 d2                	test   %edx,%edx
f010127a:	0f 84 c6 00 00 00    	je     f0101346 <pgdir_walk+0x157>
			return NULL;
		struct Page *pp;
		int status = page_alloc(&pp);
f0101280:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101283:	89 04 24             	mov    %eax,(%esp)
f0101286:	e8 14 ff ff ff       	call   f010119f <page_alloc>
		if(status != 0)
f010128b:	85 c0                	test   %eax,%eax
f010128d:	0f 85 b3 00 00 00    	jne    f0101346 <pgdir_walk+0x157>
			return NULL;
		pp->pp_ref = 1;
f0101293:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101296:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010129f:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f01012a5:	c1 f8 02             	sar    $0x2,%eax
f01012a8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01012ae:	c1 e0 0c             	shl    $0xc,%eax
		//int frame_index =(pp-pages)/sizeof(struct Page);

		*vpt_base = page2pa(pp);
f01012b1:	89 03                	mov    %eax,(%ebx)

		pte_t* phy_frame = (pte_t *)KADDR(*vpt_base);
f01012b3:	89 c2                	mov    %eax,%edx
f01012b5:	c1 ea 0c             	shr    $0xc,%edx
f01012b8:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f01012be:	72 20                	jb     f01012e0 <pgdir_walk+0xf1>
f01012c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012c4:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f01012cb:	f0 
f01012cc:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f01012d3:	00 
f01012d4:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01012db:	e8 a5 ed ff ff       	call   f0100085 <_panic>
	
		memset(phy_frame, 0, PGSIZE);
f01012e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01012e7:	00 
f01012e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012ef:	00 
f01012f0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012f5:	89 04 24             	mov    %eax,(%esp)
f01012f8:	e8 e9 40 00 00       	call   f01053e6 <memset>
		/*
		Setting up permission for page table address in PGDIR
		*/
		*vpt_base = *vpt_base | PTE_P | PTE_U | PTE_W;
f01012fd:	83 0b 07             	orl    $0x7,(%ebx)
	}	
	//return vpt_base;
	unsigned int pt_index =(unsigned int )va >> PTXSHIFT;
	pt_index &= 0x3ff ;
	physaddr_t pte = ((*(unsigned int *)vpt_base) & ~0xfff) + (pt_index*4); 
f0101300:	8b 03                	mov    (%ebx),%eax
f0101302:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101307:	c1 ee 0a             	shr    $0xa,%esi
f010130a:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101310:	01 f0                	add    %esi,%eax
	
	pte_t* vpte;
	vpte = (pte_t*)KADDR(pte);
f0101312:	89 c2                	mov    %eax,%edx
f0101314:	c1 ea 0c             	shr    $0xc,%edx
f0101317:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f010131d:	72 20                	jb     f010133f <pgdir_walk+0x150>
f010131f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101323:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f010132a:	f0 
f010132b:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f0101332:	00 
f0101333:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010133a:	e8 46 ed ff ff       	call   f0100085 <_panic>
f010133f:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return vpte;
f0101344:	eb 05                	jmp    f010134b <pgdir_walk+0x15c>
f0101346:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010134b:	83 c4 20             	add    $0x20,%esp
f010134e:	5b                   	pop    %ebx
f010134f:	5e                   	pop    %esi
f0101350:	5d                   	pop    %ebp
f0101351:	c3                   	ret    
	{
		create = 0;
		c = 3;
	}
	if(c==3)
		cprintf("\nIn pgdir_walk()..\n");
f0101352:	c7 04 24 22 76 10 f0 	movl   $0xf0107622,(%esp)
f0101359:	e8 ad 26 00 00       	call   f0103a0b <cprintf>
f010135e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101363:	e9 9b fe ff ff       	jmp    f0101203 <pgdir_walk+0x14>

f0101368 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101368:	55                   	push   %ebp
f0101369:	89 e5                	mov    %esp,%ebp
f010136b:	57                   	push   %edi
f010136c:	56                   	push   %esi
f010136d:	53                   	push   %ebx
f010136e:	83 ec 2c             	sub    $0x2c,%esp
f0101371:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here. 
	const void* orig_va = va;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
f0101374:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101377:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010137a:	89 c3                	mov    %eax,%ebx
f010137c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
f0101382:	03 45 10             	add    0x10(%ebp),%eax
f0101385:	05 ff 0f 00 00       	add    $0xfff,%eax
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
f010138a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010138f:	29 d8                	sub    %ebx,%eax
f0101391:	c1 e8 0c             	shr    $0xc,%eax
f0101394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        pte_t* stemp;
        int i;
        for( i =0 ; i < numPages;i++)
f0101397:	85 c0                	test   %eax,%eax
f0101399:	74 4c                	je     f01013e7 <user_mem_check+0x7f>
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here. 
	const void* orig_va = va;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
f010139b:	be 00 00 00 00       	mov    $0x0,%esi
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
        pte_t* stemp;
        int i;
        for( i =0 ; i < numPages;i++)
        {
                stemp = pgdir_walk(curenv->env_pgdir, start, 0);
f01013a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013a7:	00 
f01013a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013ac:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f01013b1:	8b 40 5c             	mov    0x5c(%eax),%eax
f01013b4:	89 04 24             	mov    %eax,(%esp)
f01013b7:	e8 33 fe ff ff       	call   f01011ef <pgdir_walk>

                if( stemp== NULL || ((*stemp) & perm) != perm )
f01013bc:	85 c0                	test   %eax,%eax
f01013be:	74 08                	je     f01013c8 <user_mem_check+0x60>
f01013c0:	8b 00                	mov    (%eax),%eax
f01013c2:	21 f8                	and    %edi,%eax
f01013c4:	39 c7                	cmp    %eax,%edi
f01013c6:	74 0f                	je     f01013d7 <user_mem_check+0x6f>
                {
			user_mem_check_addr = (uintptr_t)orig_va;
f01013c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013cb:	a3 bc 25 1e f0       	mov    %eax,0xf01e25bc
f01013d0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                        return -E_FAULT;
f01013d5:	eb 15                	jmp    f01013ec <user_mem_check+0x84>
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
        pte_t* stemp;
        int i;
        for( i =0 ; i < numPages;i++)
f01013d7:	83 c6 01             	add    $0x1,%esi
f01013da:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01013dd:	73 08                	jae    f01013e7 <user_mem_check+0x7f>
                if( stemp== NULL || ((*stemp) & perm) != perm )
                {
			user_mem_check_addr = (uintptr_t)orig_va;
                        return -E_FAULT;
                }
                start += PGSIZE;
f01013df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013e5:	eb b9                	jmp    f01013a0 <user_mem_check+0x38>
f01013e7:	b8 00 00 00 00       	mov    $0x0,%eax
		va = start;
        }
	return 0;
}
f01013ec:	83 c4 2c             	add    $0x2c,%esp
f01013ef:	5b                   	pop    %ebx
f01013f0:	5e                   	pop    %esi
f01013f1:	5f                   	pop    %edi
f01013f2:	5d                   	pop    %ebp
f01013f3:	c3                   	ret    

f01013f4 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01013f4:	55                   	push   %ebp
f01013f5:	89 e5                	mov    %esp,%ebp
f01013f7:	53                   	push   %ebx
f01013f8:	83 ec 14             	sub    $0x14,%esp
f01013fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01013fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101401:	83 c8 04             	or     $0x4,%eax
f0101404:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101408:	8b 45 10             	mov    0x10(%ebp),%eax
f010140b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010140f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101412:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101416:	89 1c 24             	mov    %ebx,(%esp)
f0101419:	e8 4a ff ff ff       	call   f0101368 <user_mem_check>
f010141e:	85 c0                	test   %eax,%eax
f0101420:	79 24                	jns    f0101446 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101422:	a1 bc 25 1e f0       	mov    0xf01e25bc,%eax
f0101427:	89 44 24 08          	mov    %eax,0x8(%esp)
f010142b:	8b 43 4c             	mov    0x4c(%ebx),%eax
f010142e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101432:	c7 04 24 64 70 10 f0 	movl   $0xf0107064,(%esp)
f0101439:	e8 cd 25 00 00       	call   f0103a0b <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010143e:	89 1c 24             	mov    %ebx,(%esp)
f0101441:	e8 c0 1e 00 00       	call   f0103306 <env_destroy>
	}
}
f0101446:	83 c4 14             	add    $0x14,%esp
f0101449:	5b                   	pop    %ebx
f010144a:	5d                   	pop    %ebp
f010144b:	c3                   	ret    

f010144c <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010144c:	55                   	push   %ebp
f010144d:	89 e5                	mov    %esp,%ebp
f010144f:	53                   	push   %ebx
f0101450:	83 ec 14             	sub    $0x14,%esp
f0101453:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *p;
	p = pgdir_walk( pgdir, va, 0);
f0101456:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010145d:	00 
f010145e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101461:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101465:	8b 45 08             	mov    0x8(%ebp),%eax
f0101468:	89 04 24             	mov    %eax,(%esp)
f010146b:	e8 7f fd ff ff       	call   f01011ef <pgdir_walk>
	if(p==NULL) 
f0101470:	85 c0                	test   %eax,%eax
f0101472:	75 13                	jne    f0101487 <page_lookup+0x3b>
	{
		cprintf("null in page_lookup\n");
f0101474:	c7 04 24 36 76 10 f0 	movl   $0xf0107636,(%esp)
f010147b:	e8 8b 25 00 00       	call   f0103a0b <cprintf>
f0101480:	ba 00 00 00 00       	mov    $0x0,%edx
		return NULL;
f0101485:	eb 40                	jmp    f01014c7 <page_lookup+0x7b>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101487:	8b 10                	mov    (%eax),%edx
f0101489:	c1 ea 0c             	shr    $0xc,%edx
f010148c:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0101492:	72 1c                	jb     f01014b0 <page_lookup+0x64>
		panic("pa2page called with invalid pa");
f0101494:	c7 44 24 08 f0 6e 10 	movl   $0xf0106ef0,0x8(%esp)
f010149b:	f0 
f010149c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f01014a3:	00 
f01014a4:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f01014ab:	e8 d5 eb ff ff       	call   f0100085 <_panic>
	return &pages[PPN(pa)];
f01014b0:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01014b3:	c1 e2 02             	shl    $0x2,%edx
f01014b6:	03 15 9c 43 1e f0    	add    0xf01e439c,%edx
	}
	physaddr_t pageframe_base = *p;
	//cprintf("p %x *p %x pageframe_base %x (pageframe_base&~0xfff) %x\n", p, *p, pageframe_base, (pageframe_base & ~0xfff));
	struct Page *page = pa2page(pageframe_base & ~0xfff);
	//cprintf("page: %x\n",page);
	if(pte_store!=NULL && *pte_store!=0)
f01014bc:	85 db                	test   %ebx,%ebx
f01014be:	74 07                	je     f01014c7 <page_lookup+0x7b>
f01014c0:	83 3b 00             	cmpl   $0x0,(%ebx)
f01014c3:	74 02                	je     f01014c7 <page_lookup+0x7b>
		*pte_store = p;
f01014c5:	89 03                	mov    %eax,(%ebx)
	//cprintf("hello\n");
	//cprintf("returning %x from page_lookup\n",page);
	return page;
}
f01014c7:	89 d0                	mov    %edx,%eax
f01014c9:	83 c4 14             	add    $0x14,%esp
f01014cc:	5b                   	pop    %ebx
f01014cd:	5d                   	pop    %ebp
f01014ce:	c3                   	ret    

f01014cf <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01014cf:	55                   	push   %ebp
f01014d0:	89 e5                	mov    %esp,%ebp
f01014d2:	83 ec 38             	sub    $0x38,%esp
f01014d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014db:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014de:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte_store;
	struct Page *page = page_lookup(pgdir, va, &pte_store);
f01014e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01014e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014eb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01014ef:	89 3c 24             	mov    %edi,(%esp)
f01014f2:	e8 55 ff ff ff       	call   f010144c <page_lookup>
f01014f7:	89 c3                	mov    %eax,%ebx
	if(page==NULL)
f01014f9:	85 c0                	test   %eax,%eax
f01014fb:	74 24                	je     f0101521 <page_remove+0x52>
		return;	
	page_decref(page);
f01014fd:	89 04 24             	mov    %eax,(%esp)
f0101500:	e8 0a fa ff ff       	call   f0100f0f <page_decref>

	//cleaning the existing pagetable entry
	*pte_store = 0;
f0101505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101508:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(page->pp_ref == 0)
f010150e:	66 83 7b 08 00       	cmpw   $0x0,0x8(%ebx)
f0101513:	75 0c                	jne    f0101521 <page_remove+0x52>
		tlb_invalidate(pgdir, va);
f0101515:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101519:	89 3c 24             	mov    %edi,(%esp)
f010151c:	e8 11 fa ff ff       	call   f0100f32 <tlb_invalidate>
}
f0101521:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101524:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101527:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010152a:	89 ec                	mov    %ebp,%esp
f010152c:	5d                   	pop    %ebp
f010152d:	c3                   	ret    

f010152e <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//		
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f010152e:	55                   	push   %ebp
f010152f:	89 e5                	mov    %esp,%ebp
f0101531:	83 ec 28             	sub    $0x28,%esp
f0101534:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101537:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010153a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010153d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101540:	8b 7d 10             	mov    0x10(%ebp),%edi
	//cprintf("\nIn Function page_insert()..\n");
        pte_t *pte = pgdir_walk(pgdir,va,1);
f0101543:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010154a:	00 
f010154b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010154f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101552:	89 04 24             	mov    %eax,(%esp)
f0101555:	e8 95 fc ff ff       	call   f01011ef <pgdir_walk>
f010155a:	89 c3                	mov    %eax,%ebx
	//cprintf("pte %x, *pte: %x page2pa(pp): %x\n",pte, *pte, page2pa(pp));
        if(pte == NULL)
f010155c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101561:	85 db                	test   %ebx,%ebx
f0101563:	74 70                	je     f01015d5 <page_insert+0xa7>
                return -E_NO_MEM;

        if(((*pte) & PTE_P) != 0)
f0101565:	8b 03                	mov    (%ebx),%eax
f0101567:	a8 01                	test   $0x1,%al
f0101569:	74 33                	je     f010159e <page_insert+0x70>
	{
                if(PTE_ADDR(*pte) != page2pa(pp))
f010156b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101570:	89 f2                	mov    %esi,%edx
f0101572:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f0101578:	c1 fa 02             	sar    $0x2,%edx
f010157b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101581:	c1 e2 0c             	shl    $0xc,%edx
f0101584:	39 d0                	cmp    %edx,%eax
f0101586:	74 11                	je     f0101599 <page_insert+0x6b>
		{
			//cprintf("page remove calling va: %x\n", va);
                        page_remove(pgdir,va);
f0101588:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010158c:	8b 45 08             	mov    0x8(%ebp),%eax
f010158f:	89 04 24             	mov    %eax,(%esp)
f0101592:	e8 38 ff ff ff       	call   f01014cf <page_remove>
f0101597:	eb 05                	jmp    f010159e <page_insert+0x70>
                }
		else
		{
                        pp->pp_ref--;
f0101599:	66 83 6e 08 01       	subw   $0x1,0x8(%esi)
		cprintf("could not do page_alloc for pte\n");
		return -E_NO_MEM;
	}*/
        *pte = page2pa(pp);

	*pte = *pte | perm | PTE_P;
f010159e:	8b 45 14             	mov    0x14(%ebp),%eax
f01015a1:	83 c8 01             	or     $0x1,%eax
f01015a4:	89 f2                	mov    %esi,%edx
f01015a6:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f01015ac:	c1 fa 02             	sar    $0x2,%edx
f01015af:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01015b5:	c1 e2 0c             	shl    $0xc,%edx
f01015b8:	09 d0                	or     %edx,%eax
f01015ba:	89 03                	mov    %eax,(%ebx)
	//cprintf("*va before pgdir_walk with 1 %x va: %x\n",*(int *)va, va);
        pp->pp_ref = pp->pp_ref + 1;
f01015bc:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
	//cprintf("Again ==> perm = %x, *pte =%x\n ",perm, *pte);
        tlb_invalidate(pgdir,va);
f01015c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c8:	89 04 24             	mov    %eax,(%esp)
f01015cb:	e8 62 f9 ff ff       	call   f0100f32 <tlb_invalidate>
f01015d0:	b8 00 00 00 00       	mov    $0x0,%eax
        return 0;
}
f01015d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01015d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01015db:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01015de:	89 ec                	mov    %ebp,%esp
f01015e0:	5d                   	pop    %ebp
f01015e1:	c3                   	ret    

f01015e2 <boot_map_segment>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f01015e2:	55                   	push   %ebp
f01015e3:	89 e5                	mov    %esp,%ebp
f01015e5:	57                   	push   %edi
f01015e6:	56                   	push   %esi
f01015e7:	53                   	push   %ebx
f01015e8:	83 ec 2c             	sub    $0x2c,%esp
f01015eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01015ee:	89 d3                	mov    %edx,%ebx
f01015f0:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	for(i =0;i<(size/PGSIZE);i++)
f01015f3:	c1 e9 0c             	shr    $0xc,%ecx
f01015f6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01015f9:	85 c9                	test   %ecx,%ecx
f01015fb:	74 54                	je     f0101651 <boot_map_segment+0x6f>
f01015fd:	be 00 00 00 00       	mov    $0x0,%esi
		if(pte == NULL)
		{
			cprintf("could not allocate page table in boot_map_segment\n");
			return;
		}	
		*pte = pa | PTE_P | perm;
f0101602:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101605:	83 c8 01             	or     $0x1,%eax
f0101608:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
	int i;
	for(i =0;i<(size/PGSIZE);i++)
	{
		pte_t *pte = pgdir_walk(pgdir, (void*)la, 1);
f010160b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101612:	00 
f0101613:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101617:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010161a:	89 04 24             	mov    %eax,(%esp)
f010161d:	e8 cd fb ff ff       	call   f01011ef <pgdir_walk>
		if(pte == NULL)
f0101622:	85 c0                	test   %eax,%eax
f0101624:	75 0e                	jne    f0101634 <boot_map_segment+0x52>
		{
			cprintf("could not allocate page table in boot_map_segment\n");
f0101626:	c7 04 24 9c 70 10 f0 	movl   $0xf010709c,(%esp)
f010162d:	e8 d9 23 00 00       	call   f0103a0b <cprintf>
			return;
f0101632:	eb 1d                	jmp    f0101651 <boot_map_segment+0x6f>
		}	
		*pte = pa | PTE_P | perm;
f0101634:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101637:	09 fa                	or     %edi,%edx
f0101639:	89 10                	mov    %edx,(%eax)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
	int i;
	for(i =0;i<(size/PGSIZE);i++)
f010163b:	83 c6 01             	add    $0x1,%esi
f010163e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101641:	73 0e                	jae    f0101651 <boot_map_segment+0x6f>
		{
			cprintf("could not allocate page table in boot_map_segment\n");
			return;
		}	
		*pte = pa | PTE_P | perm;
		la+=PGSIZE;
f0101643:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		pa+=PGSIZE;
f0101649:	81 c7 00 10 00 00    	add    $0x1000,%edi
f010164f:	eb ba                	jmp    f010160b <boot_map_segment+0x29>
	}	
}
f0101651:	83 c4 2c             	add    $0x2c,%esp
f0101654:	5b                   	pop    %ebx
f0101655:	5e                   	pop    %esi
f0101656:	5f                   	pop    %edi
f0101657:	5d                   	pop    %ebp
f0101658:	c3                   	ret    

f0101659 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0101659:	55                   	push   %ebp
f010165a:	89 e5                	mov    %esp,%ebp
f010165c:	83 ec 18             	sub    $0x18,%esp
f010165f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101662:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101665:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101667:	89 04 24             	mov    %eax,(%esp)
f010166a:	e8 f1 21 00 00       	call   f0103860 <mc146818_read>
f010166f:	89 c6                	mov    %eax,%esi
f0101671:	83 c3 01             	add    $0x1,%ebx
f0101674:	89 1c 24             	mov    %ebx,(%esp)
f0101677:	e8 e4 21 00 00       	call   f0103860 <mc146818_read>
f010167c:	c1 e0 08             	shl    $0x8,%eax
f010167f:	09 f0                	or     %esi,%eax
}
f0101681:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101684:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101687:	89 ec                	mov    %ebp,%esp
f0101689:	5d                   	pop    %ebp
f010168a:	c3                   	ret    

f010168b <i386_detect_memory>:

void
i386_detect_memory(void)
{
f010168b:	55                   	push   %ebp
f010168c:	89 e5                	mov    %esp,%ebp
f010168e:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0101691:	b8 15 00 00 00       	mov    $0x15,%eax
f0101696:	e8 be ff ff ff       	call   f0101659 <nvram_read>
f010169b:	c1 e0 0a             	shl    $0xa,%eax
f010169e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01016a3:	a3 ac 25 1e f0       	mov    %eax,0xf01e25ac
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f01016a8:	b8 17 00 00 00       	mov    $0x17,%eax
f01016ad:	e8 a7 ff ff ff       	call   f0101659 <nvram_read>
f01016b2:	c1 e0 0a             	shl    $0xa,%eax
f01016b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01016ba:	a3 b0 25 1e f0       	mov    %eax,0xf01e25b0

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f01016bf:	85 c0                	test   %eax,%eax
f01016c1:	74 0c                	je     f01016cf <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f01016c3:	05 00 00 10 00       	add    $0x100000,%eax
f01016c8:	a3 a8 25 1e f0       	mov    %eax,0xf01e25a8
f01016cd:	eb 0a                	jmp    f01016d9 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f01016cf:	a1 ac 25 1e f0       	mov    0xf01e25ac,%eax
f01016d4:	a3 a8 25 1e f0       	mov    %eax,0xf01e25a8

	npage = maxpa / PGSIZE;
f01016d9:	a1 a8 25 1e f0       	mov    0xf01e25a8,%eax
f01016de:	89 c2                	mov    %eax,%edx
f01016e0:	c1 ea 0c             	shr    $0xc,%edx
f01016e3:	89 15 90 43 1e f0    	mov    %edx,0xf01e4390

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f01016e9:	c1 e8 0a             	shr    $0xa,%eax
f01016ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016f0:	c7 04 24 d0 70 10 f0 	movl   $0xf01070d0,(%esp)
f01016f7:	e8 0f 23 00 00       	call   f0103a0b <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f01016fc:	a1 b0 25 1e f0       	mov    0xf01e25b0,%eax
f0101701:	c1 e8 0a             	shr    $0xa,%eax
f0101704:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101708:	a1 ac 25 1e f0       	mov    0xf01e25ac,%eax
f010170d:	c1 e8 0a             	shr    $0xa,%eax
f0101710:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101714:	c7 04 24 4b 76 10 f0 	movl   $0xf010764b,(%esp)
f010171b:	e8 eb 22 00 00       	call   f0103a0b <cprintf>
}
f0101720:	c9                   	leave  
f0101721:	c3                   	ret    

f0101722 <i386_vm_init>:
        // a virtual page table at virtual address VPT.
        // (For now, you don't have understand the greater purpose of the
        // following two lines.)


{
f0101722:	55                   	push   %ebp
f0101723:	89 e5                	mov    %esp,%ebp
f0101725:	57                   	push   %edi
f0101726:	56                   	push   %esi
f0101727:	53                   	push   %ebx
f0101728:	83 ec 4c             	sub    $0x4c,%esp
	uint32_t cr0;
	size_t n;

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f010172b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101730:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101735:	e8 56 f7 ff ff       	call   f0100e90 <boot_alloc>
f010173a:	89 45 bc             	mov    %eax,-0x44(%ebp)
	memset(pgdir, 0, PGSIZE);
f010173d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101744:	00 
f0101745:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010174c:	00 
f010174d:	89 04 24             	mov    %eax,(%esp)
f0101750:	e8 91 3c 00 00       	call   f01053e6 <memset>
	boot_pgdir = pgdir;
f0101755:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0101758:	a3 98 43 1e f0       	mov    %eax,0xf01e4398
	boot_cr3 = PADDR(pgdir);
f010175d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101762:	77 20                	ja     f0101784 <i386_vm_init+0x62>
f0101764:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101768:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f010176f:	f0 
f0101770:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
f0101777:	00 
f0101778:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010177f:	e8 01 e9 ff ff       	call   f0100085 <_panic>
f0101784:	05 00 00 00 10       	add    $0x10000000,%eax
f0101789:	a3 94 43 1e f0       	mov    %eax,0xf01e4394
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f010178e:	89 c2                	mov    %eax,%edx
f0101790:	83 ca 03             	or     $0x3,%edx
f0101793:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0101796:	89 91 fc 0e 00 00    	mov    %edx,0xefc(%ecx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f010179c:	83 c8 05             	or     $0x5,%eax
f010179f:	89 81 f4 0e 00 00    	mov    %eax,0xef4(%ecx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npage' is the number of physical pages in memory.
	// User-level programs will get read-only access to the array as well.
	// Your code goes here:
	pages = (struct Page *)boot_alloc (npage*sizeof(struct Page), PGSIZE);
f01017a5:	a1 90 43 1e f0       	mov    0xf01e4390,%eax
f01017aa:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01017ad:	c1 e0 02             	shl    $0x2,%eax
f01017b0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017b5:	e8 d6 f6 ff ff       	call   f0100e90 <boot_alloc>
f01017ba:	a3 9c 43 1e f0       	mov    %eax,0xf01e439c
	//cprintf("size: %d\n",sizeof(struct Page));
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc (NENV*sizeof(struct Env), PGSIZE);
f01017bf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017c4:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01017c9:	e8 c2 f6 ff ff       	call   f0100e90 <boot_alloc>
f01017ce:	a3 c0 25 1e f0       	mov    %eax,0xf01e25c0
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	//cprintf("pages %x\n", pages);
	page_init();
f01017d3:	e8 76 f7 ff ff       	call   f0100f4e <page_init>

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.	
	int i = 0;
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f01017d8:	a1 b8 25 1e f0       	mov    0xf01e25b8,%eax
f01017dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01017e0:	85 c0                	test   %eax,%eax
f01017e2:	0f 84 89 00 00 00    	je     f0101871 <i386_vm_init+0x14f>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01017e8:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f01017ee:	c1 f8 02             	sar    $0x2,%eax
f01017f1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01017f7:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01017fa:	89 c2                	mov    %eax,%edx
f01017fc:	c1 ea 0c             	shr    $0xc,%edx
f01017ff:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0101805:	72 41                	jb     f0101848 <i386_vm_init+0x126>
f0101807:	eb 1f                	jmp    f0101828 <i386_vm_init+0x106>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101809:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f010180f:	c1 f8 02             	sar    $0x2,%eax
f0101812:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101818:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010181b:	89 c2                	mov    %eax,%edx
f010181d:	c1 ea 0c             	shr    $0xc,%edx
f0101820:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0101826:	72 20                	jb     f0101848 <i386_vm_init+0x126>
f0101828:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010182c:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0101833:	f0 
f0101834:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010183b:	00 
f010183c:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f0101843:	e8 3d e8 ff ff       	call   f0100085 <_panic>
	{
		memset(page2kva(pp0), 0x97, 128);
f0101848:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010184f:	00 
f0101850:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101857:	00 
f0101858:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010185d:	89 04 24             	mov    %eax,(%esp)
f0101860:	e8 81 3b 00 00       	call   f01053e6 <memset>

	// if there's a page that shouldn't be on
	// the free list, try to make sure it
	// eventually causes trouble.	
	int i = 0;
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0101865:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101868:	8b 00                	mov    (%eax),%eax
f010186a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010186d:	85 c0                	test   %eax,%eax
f010186f:	75 98                	jne    f0101809 <i386_vm_init+0xe7>
	{
		memset(page2kva(pp0), 0x97, 128);
	}	

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
f0101871:	a1 b8 25 1e f0       	mov    0xf01e25b8,%eax
f0101876:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101879:	85 c0                	test   %eax,%eax
f010187b:	0f 84 e9 01 00 00    	je     f0101a6a <i386_vm_init+0x348>
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
f0101881:	8b 1d 9c 43 1e f0    	mov    0xf01e439c,%ebx
f0101887:	39 d8                	cmp    %ebx,%eax
f0101889:	72 5f                	jb     f01018ea <i386_vm_init+0x1c8>
		assert(pp0 < pages + npage);
f010188b:	8b 35 90 43 1e f0    	mov    0xf01e4390,%esi
f0101891:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0101894:	8d 3c 93             	lea    (%ebx,%edx,4),%edi
f0101897:	39 f8                	cmp    %edi,%eax
f0101899:	73 77                	jae    f0101912 <i386_vm_init+0x1f0>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010189b:	89 5d c0             	mov    %ebx,-0x40(%ebp)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010189e:	89 c2                	mov    %eax,%edx
f01018a0:	29 da                	sub    %ebx,%edx
f01018a2:	c1 fa 02             	sar    $0x2,%edx
f01018a5:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01018ab:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
f01018ae:	85 d2                	test   %edx,%edx
f01018b0:	0f 84 95 00 00 00    	je     f010194b <i386_vm_init+0x229>
		assert(page2pa(pp0) != IOPHYSMEM);
f01018b6:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f01018bc:	0f 84 b5 00 00 00    	je     f0101977 <i386_vm_init+0x255>
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
f01018c2:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01018c8:	0f 84 d5 00 00 00    	je     f01019a3 <i386_vm_init+0x281>
		assert(page2pa(pp0) != EXTPHYSMEM);
f01018ce:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f01018d4:	0f 85 19 01 00 00    	jne    f01019f3 <i386_vm_init+0x2d1>
f01018da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018e0:	e9 ea 00 00 00       	jmp    f01019cf <i386_vm_init+0x2ad>
		memset(page2kva(pp0), 0x97, 128);
	}	

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp0 >= pages);
f01018e5:	39 d8                	cmp    %ebx,%eax
f01018e7:	90                   	nop
f01018e8:	73 24                	jae    f010190e <i386_vm_init+0x1ec>
f01018ea:	c7 44 24 0c 67 76 10 	movl   $0xf0107667,0xc(%esp)
f01018f1:	f0 
f01018f2:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01018f9:	f0 
f01018fa:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0101901:	00 
f0101902:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101909:	e8 77 e7 ff ff       	call   f0100085 <_panic>
		assert(pp0 < pages + npage);
f010190e:	39 f8                	cmp    %edi,%eax
f0101910:	72 24                	jb     f0101936 <i386_vm_init+0x214>
f0101912:	c7 44 24 0c 89 76 10 	movl   $0xf0107689,0xc(%esp)
f0101919:	f0 
f010191a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101921:	f0 
f0101922:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f0101929:	00 
f010192a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101931:	e8 4f e7 ff ff       	call   f0100085 <_panic>
f0101936:	89 c2                	mov    %eax,%edx
f0101938:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010193b:	c1 fa 02             	sar    $0x2,%edx
f010193e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101944:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp0) != 0);
f0101947:	85 d2                	test   %edx,%edx
f0101949:	75 24                	jne    f010196f <i386_vm_init+0x24d>
f010194b:	c7 44 24 0c 9d 76 10 	movl   $0xf010769d,0xc(%esp)
f0101952:	f0 
f0101953:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010195a:	f0 
f010195b:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
f0101962:	00 
f0101963:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010196a:	e8 16 e7 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp0) != IOPHYSMEM);
f010196f:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f0101975:	75 24                	jne    f010199b <i386_vm_init+0x279>
f0101977:	c7 44 24 0c af 76 10 	movl   $0xf01076af,0xc(%esp)
f010197e:	f0 
f010197f:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101986:	f0 
f0101987:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f010198e:	00 
f010198f:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101996:	e8 ea e6 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
f010199b:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01019a1:	75 24                	jne    f01019c7 <i386_vm_init+0x2a5>
f01019a3:	c7 44 24 0c f4 70 10 	movl   $0xf01070f4,0xc(%esp)
f01019aa:	f0 
f01019ab:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01019b2:	f0 
f01019b3:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f01019ba:	00 
f01019bb:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01019c2:	e8 be e6 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp0) != EXTPHYSMEM);
f01019c7:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f01019cd:	75 36                	jne    f0101a05 <i386_vm_init+0x2e3>
f01019cf:	c7 44 24 0c c9 76 10 	movl   $0xf01076c9,0xc(%esp)
f01019d6:	f0 
f01019d7:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01019de:	f0 
f01019df:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f01019e6:	00 
f01019e7:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01019ee:	e8 92 e6 ff ff       	call   f0100085 <_panic>
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
f01019f3:	8b 0d b4 25 1e f0    	mov    0xf01e25b4,%ecx
f01019f9:	83 e9 01             	sub    $0x1,%ecx
f01019fc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101a02:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101a05:	89 d1                	mov    %edx,%ecx
f0101a07:	c1 e9 0c             	shr    $0xc,%ecx
f0101a0a:	39 f1                	cmp    %esi,%ecx
f0101a0c:	72 20                	jb     f0101a2e <i386_vm_init+0x30c>
f0101a0e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a12:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0101a19:	f0 
f0101a1a:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101a21:	00 
f0101a22:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f0101a29:	e8 57 e6 ff ff       	call   f0100085 <_panic>
f0101a2e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101a34:	39 55 c4             	cmp    %edx,-0x3c(%ebp)
f0101a37:	75 24                	jne    f0101a5d <i386_vm_init+0x33b>
f0101a39:	c7 44 24 0c 18 71 10 	movl   $0xf0107118,0xc(%esp)
f0101a40:	f0 
f0101a41:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101a48:	f0 
f0101a49:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f0101a50:	00 
f0101a51:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101a58:	e8 28 e6 ff ff       	call   f0100085 <_panic>
	LIST_FOREACH(pp0, &page_free_list, pp_link)
	{
		memset(page2kva(pp0), 0x97, 128);
	}	

	LIST_FOREACH(pp0, &page_free_list, pp_link) {
f0101a5d:	8b 00                	mov    (%eax),%eax
f0101a5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101a62:	85 c0                	test   %eax,%eax
f0101a64:	0f 85 7b fe ff ff    	jne    f01018e5 <i386_vm_init+0x1c3>
		assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp0) != EXTPHYSMEM);
		assert(page2kva(pp0) != ROUNDDOWN(boot_freemem - 1, PGSIZE));
	}
	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101a6a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101a71:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101a78:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101a7f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101a82:	89 04 24             	mov    %eax,(%esp)
f0101a85:	e8 15 f7 ff ff       	call   f010119f <page_alloc>
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	74 24                	je     f0101ab2 <i386_vm_init+0x390>
f0101a8e:	c7 44 24 0c e4 76 10 	movl   $0xf01076e4,0xc(%esp)
f0101a95:	f0 
f0101a96:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101a9d:	f0 
f0101a9e:	c7 44 24 04 59 01 00 	movl   $0x159,0x4(%esp)
f0101aa5:	00 
f0101aa6:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101aad:	e8 d3 e5 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101ab2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101ab5:	89 04 24             	mov    %eax,(%esp)
f0101ab8:	e8 e2 f6 ff ff       	call   f010119f <page_alloc>
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	74 24                	je     f0101ae5 <i386_vm_init+0x3c3>
f0101ac1:	c7 44 24 0c fa 76 10 	movl   $0xf01076fa,0xc(%esp)
f0101ac8:	f0 
f0101ac9:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101ad0:	f0 
f0101ad1:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f0101ad8:	00 
f0101ad9:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101ae0:	e8 a0 e5 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101ae5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae8:	89 04 24             	mov    %eax,(%esp)
f0101aeb:	e8 af f6 ff ff       	call   f010119f <page_alloc>
f0101af0:	85 c0                	test   %eax,%eax
f0101af2:	74 24                	je     f0101b18 <i386_vm_init+0x3f6>
f0101af4:	c7 44 24 0c 10 77 10 	movl   $0xf0107710,0xc(%esp)
f0101afb:	f0 
f0101afc:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101b03:	f0 
f0101b04:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
f0101b0b:	00 
f0101b0c:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101b13:	e8 6d e5 ff ff       	call   f0100085 <_panic>

	assert(pp0);
f0101b18:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101b1b:	85 c9                	test   %ecx,%ecx
f0101b1d:	75 24                	jne    f0101b43 <i386_vm_init+0x421>
f0101b1f:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f0101b26:	f0 
f0101b27:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
f0101b36:	00 
f0101b37:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101b3e:	e8 42 e5 ff ff       	call   f0100085 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b43:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101b46:	85 d2                	test   %edx,%edx
f0101b48:	74 04                	je     f0101b4e <i386_vm_init+0x42c>
f0101b4a:	39 d1                	cmp    %edx,%ecx
f0101b4c:	75 24                	jne    f0101b72 <i386_vm_init+0x450>
f0101b4e:	c7 44 24 0c 26 77 10 	movl   $0xf0107726,0xc(%esp)
f0101b55:	f0 
f0101b56:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101b5d:	f0 
f0101b5e:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0101b65:	00 
f0101b66:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101b6d:	e8 13 e5 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b75:	85 c0                	test   %eax,%eax
f0101b77:	74 09                	je     f0101b82 <i386_vm_init+0x460>
f0101b79:	39 c2                	cmp    %eax,%edx
f0101b7b:	74 05                	je     f0101b82 <i386_vm_init+0x460>
f0101b7d:	39 c1                	cmp    %eax,%ecx
f0101b7f:	90                   	nop
f0101b80:	75 24                	jne    f0101ba6 <i386_vm_init+0x484>
f0101b82:	c7 44 24 0c 50 71 10 	movl   $0xf0107150,0xc(%esp)
f0101b89:	f0 
f0101b8a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101b91:	f0 
f0101b92:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
f0101b99:	00 
f0101b9a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101ba1:	e8 df e4 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101ba6:	8b 35 9c 43 1e f0    	mov    0xf01e439c,%esi
	assert(page2pa(pp0) < npage*PGSIZE);
f0101bac:	8b 1d 90 43 1e f0    	mov    0xf01e4390,%ebx
f0101bb2:	c1 e3 0c             	shl    $0xc,%ebx
f0101bb5:	29 f1                	sub    %esi,%ecx
f0101bb7:	c1 f9 02             	sar    $0x2,%ecx
f0101bba:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101bc0:	c1 e1 0c             	shl    $0xc,%ecx
f0101bc3:	39 d9                	cmp    %ebx,%ecx
f0101bc5:	72 24                	jb     f0101beb <i386_vm_init+0x4c9>
f0101bc7:	c7 44 24 0c 38 77 10 	movl   $0xf0107738,0xc(%esp)
f0101bce:	f0 
f0101bcf:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101bd6:	f0 
f0101bd7:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f0101bde:	00 
f0101bdf:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101be6:	e8 9a e4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npage*PGSIZE);
f0101beb:	29 f2                	sub    %esi,%edx
f0101bed:	c1 fa 02             	sar    $0x2,%edx
f0101bf0:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101bf6:	c1 e2 0c             	shl    $0xc,%edx
f0101bf9:	39 d3                	cmp    %edx,%ebx
f0101bfb:	77 24                	ja     f0101c21 <i386_vm_init+0x4ff>
f0101bfd:	c7 44 24 0c 54 77 10 	movl   $0xf0107754,0xc(%esp)
f0101c04:	f0 
f0101c05:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101c0c:	f0 
f0101c0d:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0101c14:	00 
f0101c15:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101c1c:	e8 64 e4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npage*PGSIZE);
f0101c21:	29 f0                	sub    %esi,%eax
f0101c23:	c1 f8 02             	sar    $0x2,%eax
f0101c26:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101c2c:	c1 e0 0c             	shl    $0xc,%eax
f0101c2f:	39 c3                	cmp    %eax,%ebx
f0101c31:	77 24                	ja     f0101c57 <i386_vm_init+0x535>
f0101c33:	c7 44 24 0c 70 77 10 	movl   $0xf0107770,0xc(%esp)
f0101c3a:	f0 
f0101c3b:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101c42:	f0 
f0101c43:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0101c4a:	00 
f0101c4b:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101c52:	e8 2e e4 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c57:	8b 1d b8 25 1e f0    	mov    0xf01e25b8,%ebx
	LIST_INIT(&page_free_list);
f0101c5d:	c7 05 b8 25 1e f0 00 	movl   $0x0,0xf01e25b8
f0101c64:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101c67:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101c6a:	89 04 24             	mov    %eax,(%esp)
f0101c6d:	e8 2d f5 ff ff       	call   f010119f <page_alloc>
f0101c72:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101c75:	74 24                	je     f0101c9b <i386_vm_init+0x579>
f0101c77:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0101c7e:	f0 
f0101c7f:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101c86:	f0 
f0101c87:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0101c8e:	00 
f0101c8f:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101c96:	e8 ea e3 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101c9e:	89 04 24             	mov    %eax,(%esp)
f0101ca1:	e8 40 f2 ff ff       	call   f0100ee6 <page_free>
	page_free(pp1);
f0101ca6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ca9:	89 04 24             	mov    %eax,(%esp)
f0101cac:	e8 35 f2 ff ff       	call   f0100ee6 <page_free>
	page_free(pp2);
f0101cb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101cb4:	89 04 24             	mov    %eax,(%esp)
f0101cb7:	e8 2a f2 ff ff       	call   f0100ee6 <page_free>
	pp0 = pp1 = pp2 = 0;
f0101cbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101cc3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101cca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101cd1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101cd4:	89 04 24             	mov    %eax,(%esp)
f0101cd7:	e8 c3 f4 ff ff       	call   f010119f <page_alloc>
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	74 24                	je     f0101d04 <i386_vm_init+0x5e2>
f0101ce0:	c7 44 24 0c e4 76 10 	movl   $0xf01076e4,0xc(%esp)
f0101ce7:	f0 
f0101ce8:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101cef:	f0 
f0101cf0:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0101cf7:	00 
f0101cf8:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101cff:	e8 81 e3 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101d04:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101d07:	89 04 24             	mov    %eax,(%esp)
f0101d0a:	e8 90 f4 ff ff       	call   f010119f <page_alloc>
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	74 24                	je     f0101d37 <i386_vm_init+0x615>
f0101d13:	c7 44 24 0c fa 76 10 	movl   $0xf01076fa,0xc(%esp)
f0101d1a:	f0 
f0101d1b:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0101d2a:	00 
f0101d2b:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101d32:	e8 4e e3 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101d37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d3a:	89 04 24             	mov    %eax,(%esp)
f0101d3d:	e8 5d f4 ff ff       	call   f010119f <page_alloc>
f0101d42:	85 c0                	test   %eax,%eax
f0101d44:	74 24                	je     f0101d6a <i386_vm_init+0x648>
f0101d46:	c7 44 24 0c 10 77 10 	movl   $0xf0107710,0xc(%esp)
f0101d4d:	f0 
f0101d4e:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101d55:	f0 
f0101d56:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f0101d5d:	00 
f0101d5e:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101d65:	e8 1b e3 ff ff       	call   f0100085 <_panic>
	assert(pp0);
f0101d6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101d6d:	85 d2                	test   %edx,%edx
f0101d6f:	75 24                	jne    f0101d95 <i386_vm_init+0x673>
f0101d71:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f0101d78:	f0 
f0101d79:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101d80:	f0 
f0101d81:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0101d88:	00 
f0101d89:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101d90:	e8 f0 e2 ff ff       	call   f0100085 <_panic>
	assert(pp1 && pp1 != pp0);
f0101d95:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101d98:	85 c9                	test   %ecx,%ecx
f0101d9a:	74 04                	je     f0101da0 <i386_vm_init+0x67e>
f0101d9c:	39 ca                	cmp    %ecx,%edx
f0101d9e:	75 24                	jne    f0101dc4 <i386_vm_init+0x6a2>
f0101da0:	c7 44 24 0c 26 77 10 	movl   $0xf0107726,0xc(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101daf:	f0 
f0101db0:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0101db7:	00 
f0101db8:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101dbf:	e8 c1 e2 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101dc7:	85 c0                	test   %eax,%eax
f0101dc9:	74 08                	je     f0101dd3 <i386_vm_init+0x6b1>
f0101dcb:	39 c1                	cmp    %eax,%ecx
f0101dcd:	74 04                	je     f0101dd3 <i386_vm_init+0x6b1>
f0101dcf:	39 c2                	cmp    %eax,%edx
f0101dd1:	75 24                	jne    f0101df7 <i386_vm_init+0x6d5>
f0101dd3:	c7 44 24 0c 50 71 10 	movl   $0xf0107150,0xc(%esp)
f0101dda:	f0 
f0101ddb:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101de2:	f0 
f0101de3:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0101dea:	00 
f0101deb:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101df2:	e8 8e e2 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101df7:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101dfa:	89 04 24             	mov    %eax,(%esp)
f0101dfd:	e8 9d f3 ff ff       	call   f010119f <page_alloc>
f0101e02:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101e05:	74 24                	je     f0101e2b <i386_vm_init+0x709>
f0101e07:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0101e0e:	f0 
f0101e0f:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101e16:	f0 
f0101e17:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0101e1e:	00 
f0101e1f:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101e26:	e8 5a e2 ff ff       	call   f0100085 <_panic>

	// give free list back
	page_free_list = fl;
f0101e2b:	89 1d b8 25 1e f0    	mov    %ebx,0xf01e25b8

	// free the pages we took
	page_free(pp0);
f0101e31:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101e34:	89 04 24             	mov    %eax,(%esp)
f0101e37:	e8 aa f0 ff ff       	call   f0100ee6 <page_free>
	page_free(pp1);
f0101e3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101e3f:	89 04 24             	mov    %eax,(%esp)
f0101e42:	e8 9f f0 ff ff       	call   f0100ee6 <page_free>
	page_free(pp2);
f0101e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e4a:	89 04 24             	mov    %eax,(%esp)
f0101e4d:	e8 94 f0 ff ff       	call   f0100ee6 <page_free>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101e52:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101e59:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0101e60:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101e67:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101e6a:	89 04 24             	mov    %eax,(%esp)
f0101e6d:	e8 2d f3 ff ff       	call   f010119f <page_alloc>
f0101e72:	85 c0                	test   %eax,%eax
f0101e74:	74 24                	je     f0101e9a <i386_vm_init+0x778>
f0101e76:	c7 44 24 0c e4 76 10 	movl   $0xf01076e4,0xc(%esp)
f0101e7d:	f0 
f0101e7e:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101e85:	f0 
f0101e86:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101e8d:	00 
f0101e8e:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101e95:	e8 eb e1 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101e9a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101e9d:	89 04 24             	mov    %eax,(%esp)
f0101ea0:	e8 fa f2 ff ff       	call   f010119f <page_alloc>
f0101ea5:	85 c0                	test   %eax,%eax
f0101ea7:	74 24                	je     f0101ecd <i386_vm_init+0x7ab>
f0101ea9:	c7 44 24 0c fa 76 10 	movl   $0xf01076fa,0xc(%esp)
f0101eb0:	f0 
f0101eb1:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101eb8:	f0 
f0101eb9:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101ec0:	00 
f0101ec1:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101ec8:	e8 b8 e1 ff ff       	call   f0100085 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101ecd:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101ed0:	89 04 24             	mov    %eax,(%esp)
f0101ed3:	e8 c7 f2 ff ff       	call   f010119f <page_alloc>
f0101ed8:	85 c0                	test   %eax,%eax
f0101eda:	74 24                	je     f0101f00 <i386_vm_init+0x7de>
f0101edc:	c7 44 24 0c 10 77 10 	movl   $0xf0107710,0xc(%esp)
f0101ee3:	f0 
f0101ee4:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101eeb:	f0 
f0101eec:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101ef3:	00 
f0101ef4:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101efb:	e8 85 e1 ff ff       	call   f0100085 <_panic>

	assert(pp0);
f0101f00:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101f03:	85 d2                	test   %edx,%edx
f0101f05:	75 24                	jne    f0101f2b <i386_vm_init+0x809>
f0101f07:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f0101f0e:	f0 
f0101f0f:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101f16:	f0 
f0101f17:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101f1e:	00 
f0101f1f:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101f26:	e8 5a e1 ff ff       	call   f0100085 <_panic>
	assert(pp1 && pp1 != pp0);
f0101f2b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101f2e:	85 c9                	test   %ecx,%ecx
f0101f30:	74 04                	je     f0101f36 <i386_vm_init+0x814>
f0101f32:	39 ca                	cmp    %ecx,%edx
f0101f34:	75 24                	jne    f0101f5a <i386_vm_init+0x838>
f0101f36:	c7 44 24 0c 26 77 10 	movl   $0xf0107726,0xc(%esp)
f0101f3d:	f0 
f0101f3e:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101f45:	f0 
f0101f46:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101f4d:	00 
f0101f4e:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101f55:	e8 2b e1 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101f5d:	85 c0                	test   %eax,%eax
f0101f5f:	74 08                	je     f0101f69 <i386_vm_init+0x847>
f0101f61:	39 c1                	cmp    %eax,%ecx
f0101f63:	74 04                	je     f0101f69 <i386_vm_init+0x847>
f0101f65:	39 c2                	cmp    %eax,%edx
f0101f67:	75 24                	jne    f0101f8d <i386_vm_init+0x86b>
f0101f69:	c7 44 24 0c 50 71 10 	movl   $0xf0107150,0xc(%esp)
f0101f70:	f0 
f0101f71:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101f78:	f0 
f0101f79:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101f80:	00 
f0101f81:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101f88:	e8 f8 e0 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f8d:	8b 1d b8 25 1e f0    	mov    0xf01e25b8,%ebx
	LIST_INIT(&page_free_list);
f0101f93:	c7 05 b8 25 1e f0 00 	movl   $0x0,0xf01e25b8
f0101f9a:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101f9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fa0:	89 04 24             	mov    %eax,(%esp)
f0101fa3:	e8 f7 f1 ff ff       	call   f010119f <page_alloc>
f0101fa8:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101fab:	74 24                	je     f0101fd1 <i386_vm_init+0x8af>
f0101fad:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0101fb4:	f0 
f0101fb5:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0101fbc:	f0 
f0101fbd:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101fc4:	00 
f0101fc5:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0101fcc:	e8 b4 e0 ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f0101fd1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0101fd4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101fdf:	00 
f0101fe0:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0101fe5:	89 04 24             	mov    %eax,(%esp)
f0101fe8:	e8 5f f4 ff ff       	call   f010144c <page_lookup>
f0101fed:	85 c0                	test   %eax,%eax
f0101fef:	74 24                	je     f0102015 <i386_vm_init+0x8f3>
f0101ff1:	c7 44 24 0c 70 71 10 	movl   $0xf0107170,0xc(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102000:	f0 
f0102001:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102008:	00 
f0102009:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102010:	e8 70 e0 ff ff       	call   f0100085 <_panic>
	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0102015:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010201c:	00 
f010201d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102024:	00 
f0102025:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102028:	89 44 24 04          	mov    %eax,0x4(%esp)
f010202c:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102031:	89 04 24             	mov    %eax,(%esp)
f0102034:	e8 f5 f4 ff ff       	call   f010152e <page_insert>
f0102039:	85 c0                	test   %eax,%eax
f010203b:	78 24                	js     f0102061 <i386_vm_init+0x93f>
f010203d:	c7 44 24 0c a8 71 10 	movl   $0xf01071a8,0xc(%esp)
f0102044:	f0 
f0102045:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010204c:	f0 
f010204d:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102054:	00 
f0102055:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010205c:	e8 24 e0 ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102061:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102064:	89 04 24             	mov    %eax,(%esp)
f0102067:	e8 7a ee ff ff       	call   f0100ee6 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f010206c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102073:	00 
f0102074:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010207b:	00 
f010207c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010207f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102083:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102088:	89 04 24             	mov    %eax,(%esp)
f010208b:	e8 9e f4 ff ff       	call   f010152e <page_insert>
f0102090:	85 c0                	test   %eax,%eax
f0102092:	74 24                	je     f01020b8 <i386_vm_init+0x996>
f0102094:	c7 44 24 0c d4 71 10 	movl   $0xf01071d4,0xc(%esp)
f010209b:	f0 
f010209c:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01020a3:	f0 
f01020a4:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f01020ab:	00 
f01020ac:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01020b3:	e8 cd df ff ff       	call   f0100085 <_panic>
	//cprintf("Just after Insert=> pp1->pp_ref == %d\n",pp1->pp_ref);
	//cprintf("boot_pgdir[0] %x, page2pa(pp0) %x\n",PTE_ADDR(boot_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01020b8:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01020bd:	8b 08                	mov    (%eax),%ecx
f01020bf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01020c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01020c8:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f01020ce:	c1 fa 02             	sar    $0x2,%edx
f01020d1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01020d7:	c1 e2 0c             	shl    $0xc,%edx
f01020da:	39 d1                	cmp    %edx,%ecx
f01020dc:	74 24                	je     f0102102 <i386_vm_init+0x9e0>
f01020de:	c7 44 24 0c 00 72 10 	movl   $0xf0107200,0xc(%esp)
f01020e5:	f0 
f01020e6:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01020ed:	f0 
f01020ee:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01020f5:	00 
f01020f6:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01020fd:	e8 83 df ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f0102102:	ba 00 00 00 00       	mov    $0x0,%edx
f0102107:	e8 1a f0 ff ff       	call   f0101126 <check_va2pa>
f010210c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010210f:	89 d1                	mov    %edx,%ecx
f0102111:	2b 0d 9c 43 1e f0    	sub    0xf01e439c,%ecx
f0102117:	c1 f9 02             	sar    $0x2,%ecx
f010211a:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0102120:	c1 e1 0c             	shl    $0xc,%ecx
f0102123:	39 c8                	cmp    %ecx,%eax
f0102125:	74 24                	je     f010214b <i386_vm_init+0xa29>
f0102127:	c7 44 24 0c 28 72 10 	movl   $0xf0107228,0xc(%esp)
f010212e:	f0 
f010212f:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102136:	f0 
f0102137:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f010213e:	00 
f010213f:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102146:	e8 3a df ff ff       	call   f0100085 <_panic>

	//cprintf("pp1->pp_ref == %d\n",pp1->pp_ref);
	assert(pp1->pp_ref == 1);
f010214b:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0102150:	74 24                	je     f0102176 <i386_vm_init+0xa54>
f0102152:	c7 44 24 0c a9 77 10 	movl   $0xf01077a9,0xc(%esp)
f0102159:	f0 
f010215a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102161:	f0 
f0102162:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102169:	00 
f010216a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102171:	e8 0f df ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f0102176:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102179:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f010217e:	74 24                	je     f01021a4 <i386_vm_init+0xa82>
f0102180:	c7 44 24 0c ba 77 10 	movl   $0xf01077ba,0xc(%esp)
f0102187:	f0 
f0102188:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010218f:	f0 
f0102190:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102197:	00 
f0102198:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010219f:	e8 e1 de ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01021a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021ab:	00 
f01021ac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021b3:	00 
f01021b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01021b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01021bb:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01021c0:	89 04 24             	mov    %eax,(%esp)
f01021c3:	e8 66 f3 ff ff       	call   f010152e <page_insert>
f01021c8:	85 c0                	test   %eax,%eax
f01021ca:	74 24                	je     f01021f0 <i386_vm_init+0xace>
f01021cc:	c7 44 24 0c 58 72 10 	movl   $0xf0107258,0xc(%esp)
f01021d3:	f0 
f01021d4:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01021db:	f0 
f01021dc:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f01021e3:	00 
f01021e4:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01021eb:	e8 95 de ff ff       	call   f0100085 <_panic>
	//cprintf("Assertion:\n\t check_va2pa(boot_pgdir, PGSIZE) %x, page2pa(pp2) %x\n",check_va2pa(boot_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01021f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021f5:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01021fa:	e8 27 ef ff ff       	call   f0101126 <check_va2pa>
f01021ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102202:	89 d1                	mov    %edx,%ecx
f0102204:	2b 0d 9c 43 1e f0    	sub    0xf01e439c,%ecx
f010220a:	c1 f9 02             	sar    $0x2,%ecx
f010220d:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0102213:	c1 e1 0c             	shl    $0xc,%ecx
f0102216:	39 c8                	cmp    %ecx,%eax
f0102218:	74 24                	je     f010223e <i386_vm_init+0xb1c>
f010221a:	c7 44 24 0c 90 72 10 	movl   $0xf0107290,0xc(%esp)
f0102221:	f0 
f0102222:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102229:	f0 
f010222a:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0102231:	00 
f0102232:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102239:	e8 47 de ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010223e:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0102243:	74 24                	je     f0102269 <i386_vm_init+0xb47>
f0102245:	c7 44 24 0c cb 77 10 	movl   $0xf01077cb,0xc(%esp)
f010224c:	f0 
f010224d:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102254:	f0 
f0102255:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f010225c:	00 
f010225d:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102264:	e8 1c de ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102269:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010226c:	89 04 24             	mov    %eax,(%esp)
f010226f:	e8 2b ef ff ff       	call   f010119f <page_alloc>
f0102274:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102277:	74 24                	je     f010229d <i386_vm_init+0xb7b>
f0102279:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0102280:	f0 
f0102281:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102288:	f0 
f0102289:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102290:	00 
f0102291:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102298:	e8 e8 dd ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010229d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01022a4:	00 
f01022a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022ac:	00 
f01022ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022b4:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01022b9:	89 04 24             	mov    %eax,(%esp)
f01022bc:	e8 6d f2 ff ff       	call   f010152e <page_insert>
f01022c1:	85 c0                	test   %eax,%eax
f01022c3:	74 24                	je     f01022e9 <i386_vm_init+0xbc7>
f01022c5:	c7 44 24 0c 58 72 10 	movl   $0xf0107258,0xc(%esp)
f01022cc:	f0 
f01022cd:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01022d4:	f0 
f01022d5:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f01022dc:	00 
f01022dd:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01022e4:	e8 9c dd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01022e9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022ee:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01022f3:	e8 2e ee ff ff       	call   f0101126 <check_va2pa>
f01022f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01022fb:	89 d1                	mov    %edx,%ecx
f01022fd:	2b 0d 9c 43 1e f0    	sub    0xf01e439c,%ecx
f0102303:	c1 f9 02             	sar    $0x2,%ecx
f0102306:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f010230c:	c1 e1 0c             	shl    $0xc,%ecx
f010230f:	39 c8                	cmp    %ecx,%eax
f0102311:	74 24                	je     f0102337 <i386_vm_init+0xc15>
f0102313:	c7 44 24 0c 90 72 10 	movl   $0xf0107290,0xc(%esp)
f010231a:	f0 
f010231b:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102322:	f0 
f0102323:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f010232a:	00 
f010232b:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102332:	e8 4e dd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0102337:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f010233c:	74 24                	je     f0102362 <i386_vm_init+0xc40>
f010233e:	c7 44 24 0c cb 77 10 	movl   $0xf01077cb,0xc(%esp)
f0102345:	f0 
f0102346:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010234d:	f0 
f010234e:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0102355:	00 
f0102356:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010235d:	e8 23 dd ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	//cprintf("\n^^^^^^^^^^^^^^line: %d \n", __LINE__);
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102362:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102365:	89 04 24             	mov    %eax,(%esp)
f0102368:	e8 32 ee ff ff       	call   f010119f <page_alloc>
f010236d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102370:	74 24                	je     f0102396 <i386_vm_init+0xc74>
f0102372:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0102379:	f0 
f010237a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102381:	f0 
f0102382:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102389:	00 
f010238a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102391:	e8 ef dc ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0102396:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f010239b:	8b 00                	mov    (%eax),%eax
f010239d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023a2:	89 c2                	mov    %eax,%edx
f01023a4:	c1 ea 0c             	shr    $0xc,%edx
f01023a7:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f01023ad:	72 20                	jb     f01023cf <i386_vm_init+0xcad>
f01023af:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023b3:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f01023ba:	f0 
f01023bb:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01023c2:	00 
f01023c3:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01023ca:	e8 b6 dc ff ff       	call   f0100085 <_panic>
f01023cf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023de:	00 
f01023df:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023e6:	00 
f01023e7:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01023ec:	89 04 24             	mov    %eax,(%esp)
f01023ef:	e8 fb ed ff ff       	call   f01011ef <pgdir_walk>
f01023f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023f7:	83 c2 04             	add    $0x4,%edx
f01023fa:	39 d0                	cmp    %edx,%eax
f01023fc:	74 24                	je     f0102422 <i386_vm_init+0xd00>
f01023fe:	c7 44 24 0c c0 72 10 	movl   $0xf01072c0,0xc(%esp)
f0102405:	f0 
f0102406:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010240d:	f0 
f010240e:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102415:	00 
f0102416:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010241d:	e8 63 dc ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0102422:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0102429:	00 
f010242a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102431:	00 
f0102432:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102435:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102439:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f010243e:	89 04 24             	mov    %eax,(%esp)
f0102441:	e8 e8 f0 ff ff       	call   f010152e <page_insert>
f0102446:	85 c0                	test   %eax,%eax
f0102448:	74 24                	je     f010246e <i386_vm_init+0xd4c>
f010244a:	c7 44 24 0c 00 73 10 	movl   $0xf0107300,0xc(%esp)
f0102451:	f0 
f0102452:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102459:	f0 
f010245a:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102461:	00 
f0102462:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102469:	e8 17 dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f010246e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102473:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102478:	e8 a9 ec ff ff       	call   f0101126 <check_va2pa>
f010247d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102480:	89 d1                	mov    %edx,%ecx
f0102482:	2b 0d 9c 43 1e f0    	sub    0xf01e439c,%ecx
f0102488:	c1 f9 02             	sar    $0x2,%ecx
f010248b:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0102491:	c1 e1 0c             	shl    $0xc,%ecx
f0102494:	39 c8                	cmp    %ecx,%eax
f0102496:	74 24                	je     f01024bc <i386_vm_init+0xd9a>
f0102498:	c7 44 24 0c 90 72 10 	movl   $0xf0107290,0xc(%esp)
f010249f:	f0 
f01024a0:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01024a7:	f0 
f01024a8:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f01024af:	00 
f01024b0:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01024b7:	e8 c9 db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01024bc:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f01024c1:	74 24                	je     f01024e7 <i386_vm_init+0xdc5>
f01024c3:	c7 44 24 0c cb 77 10 	movl   $0xf01077cb,0xc(%esp)
f01024ca:	f0 
f01024cb:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01024da:	00 
f01024db:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01024e2:	e8 9e db ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024ee:	00 
f01024ef:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024f6:	00 
f01024f7:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01024fc:	89 04 24             	mov    %eax,(%esp)
f01024ff:	e8 eb ec ff ff       	call   f01011ef <pgdir_walk>
f0102504:	f6 00 04             	testb  $0x4,(%eax)
f0102507:	75 24                	jne    f010252d <i386_vm_init+0xe0b>
f0102509:	c7 44 24 0c 3c 73 10 	movl   $0xf010733c,0xc(%esp)
f0102510:	f0 
f0102511:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102518:	f0 
f0102519:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102520:	00 
f0102521:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102528:	e8 58 db ff ff       	call   f0100085 <_panic>
	assert(boot_pgdir[0] & PTE_U);
f010252d:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102532:	f6 00 04             	testb  $0x4,(%eax)
f0102535:	75 24                	jne    f010255b <i386_vm_init+0xe39>
f0102537:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f010253e:	f0 
f010253f:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102546:	f0 
f0102547:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f010254e:	00 
f010254f:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102556:	e8 2a db ff ff       	call   f0100085 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f010255b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102562:	00 
f0102563:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010256a:	00 
f010256b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010256e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102572:	89 04 24             	mov    %eax,(%esp)
f0102575:	e8 b4 ef ff ff       	call   f010152e <page_insert>
f010257a:	85 c0                	test   %eax,%eax
f010257c:	78 24                	js     f01025a2 <i386_vm_init+0xe80>
f010257e:	c7 44 24 0c 70 73 10 	movl   $0xf0107370,0xc(%esp)
f0102585:	f0 
f0102586:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010258d:	f0 
f010258e:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102595:	00 
f0102596:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010259d:	e8 e3 da ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01025a9:	00 
f01025aa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025b1:	00 
f01025b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01025b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01025b9:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01025be:	89 04 24             	mov    %eax,(%esp)
f01025c1:	e8 68 ef ff ff       	call   f010152e <page_insert>
f01025c6:	85 c0                	test   %eax,%eax
f01025c8:	74 24                	je     f01025ee <i386_vm_init+0xecc>
f01025ca:	c7 44 24 0c a4 73 10 	movl   $0xf01073a4,0xc(%esp)
f01025d1:	f0 
f01025d2:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01025d9:	f0 
f01025da:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01025e1:	00 
f01025e2:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01025e9:	e8 97 da ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025f5:	00 
f01025f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025fd:	00 
f01025fe:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102603:	89 04 24             	mov    %eax,(%esp)
f0102606:	e8 e4 eb ff ff       	call   f01011ef <pgdir_walk>
f010260b:	f6 00 04             	testb  $0x4,(%eax)
f010260e:	74 24                	je     f0102634 <i386_vm_init+0xf12>
f0102610:	c7 44 24 0c dc 73 10 	movl   $0xf01073dc,0xc(%esp)
f0102617:	f0 
f0102618:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010261f:	f0 
f0102620:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0102627:	00 
f0102628:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010262f:	e8 51 da ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0102634:	ba 00 00 00 00       	mov    $0x0,%edx
f0102639:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f010263e:	e8 e3 ea ff ff       	call   f0101126 <check_va2pa>
f0102643:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102646:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f010264c:	c1 fa 02             	sar    $0x2,%edx
f010264f:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102655:	c1 e2 0c             	shl    $0xc,%edx
f0102658:	39 d0                	cmp    %edx,%eax
f010265a:	74 24                	je     f0102680 <i386_vm_init+0xf5e>
f010265c:	c7 44 24 0c 14 74 10 	movl   $0xf0107414,0xc(%esp)
f0102663:	f0 
f0102664:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010266b:	f0 
f010266c:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0102673:	00 
f0102674:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010267b:	e8 05 da ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0102680:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102685:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f010268a:	e8 97 ea ff ff       	call   f0101126 <check_va2pa>
f010268f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102692:	89 d1                	mov    %edx,%ecx
f0102694:	2b 0d 9c 43 1e f0    	sub    0xf01e439c,%ecx
f010269a:	c1 f9 02             	sar    $0x2,%ecx
f010269d:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01026a3:	c1 e1 0c             	shl    $0xc,%ecx
f01026a6:	39 c8                	cmp    %ecx,%eax
f01026a8:	74 24                	je     f01026ce <i386_vm_init+0xfac>
f01026aa:	c7 44 24 0c 40 74 10 	movl   $0xf0107440,0xc(%esp)
f01026b1:	f0 
f01026b2:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01026b9:	f0 
f01026ba:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01026c1:	00 
f01026c2:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01026c9:	e8 b7 d9 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01026ce:	66 83 7a 08 02       	cmpw   $0x2,0x8(%edx)
f01026d3:	74 24                	je     f01026f9 <i386_vm_init+0xfd7>
f01026d5:	c7 44 24 0c f2 77 10 	movl   $0xf01077f2,0xc(%esp)
f01026dc:	f0 
f01026dd:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01026e4:	f0 
f01026e5:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f01026ec:	00 
f01026ed:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01026f4:	e8 8c d9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f01026f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01026fc:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102701:	74 24                	je     f0102727 <i386_vm_init+0x1005>
f0102703:	c7 44 24 0c 03 78 10 	movl   $0xf0107803,0xc(%esp)
f010270a:	f0 
f010270b:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102712:	f0 
f0102713:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010271a:	00 
f010271b:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102722:	e8 5e d9 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0102727:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010272a:	89 04 24             	mov    %eax,(%esp)
f010272d:	e8 6d ea ff ff       	call   f010119f <page_alloc>
f0102732:	85 c0                	test   %eax,%eax
f0102734:	75 08                	jne    f010273e <i386_vm_init+0x101c>
f0102736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102739:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010273c:	74 24                	je     f0102762 <i386_vm_init+0x1040>
f010273e:	c7 44 24 0c 70 74 10 	movl   $0xf0107470,0xc(%esp)
f0102745:	f0 
f0102746:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010274d:	f0 
f010274e:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102755:	00 
f0102756:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010275d:	e8 23 d9 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0102762:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102769:	00 
f010276a:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f010276f:	89 04 24             	mov    %eax,(%esp)
f0102772:	e8 58 ed ff ff       	call   f01014cf <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102777:	ba 00 00 00 00       	mov    $0x0,%edx
f010277c:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102781:	e8 a0 e9 ff ff       	call   f0101126 <check_va2pa>
f0102786:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102789:	74 24                	je     f01027af <i386_vm_init+0x108d>
f010278b:	c7 44 24 0c 94 74 10 	movl   $0xf0107494,0xc(%esp)
f0102792:	f0 
f0102793:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010279a:	f0 
f010279b:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01027a2:	00 
f01027a3:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01027aa:	e8 d6 d8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f01027af:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027b4:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01027b9:	e8 68 e9 ff ff       	call   f0101126 <check_va2pa>
f01027be:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01027c1:	89 d1                	mov    %edx,%ecx
f01027c3:	2b 0d 9c 43 1e f0    	sub    0xf01e439c,%ecx
f01027c9:	c1 f9 02             	sar    $0x2,%ecx
f01027cc:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01027d2:	c1 e1 0c             	shl    $0xc,%ecx
f01027d5:	39 c8                	cmp    %ecx,%eax
f01027d7:	74 24                	je     f01027fd <i386_vm_init+0x10db>
f01027d9:	c7 44 24 0c 40 74 10 	movl   $0xf0107440,0xc(%esp)
f01027e0:	f0 
f01027e1:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01027e8:	f0 
f01027e9:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01027f0:	00 
f01027f1:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01027f8:	e8 88 d8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f01027fd:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0102802:	74 24                	je     f0102828 <i386_vm_init+0x1106>
f0102804:	c7 44 24 0c a9 77 10 	movl   $0xf01077a9,0xc(%esp)
f010280b:	f0 
f010280c:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102813:	f0 
f0102814:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f010281b:	00 
f010281c:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102823:	e8 5d d8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102828:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010282b:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102830:	74 24                	je     f0102856 <i386_vm_init+0x1134>
f0102832:	c7 44 24 0c 03 78 10 	movl   $0xf0107803,0xc(%esp)
f0102839:	f0 
f010283a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102841:	f0 
f0102842:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102849:	00 
f010284a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102851:	e8 2f d8 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0102856:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010285d:	00 
f010285e:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102863:	89 04 24             	mov    %eax,(%esp)
f0102866:	e8 64 ec ff ff       	call   f01014cf <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f010286b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102870:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102875:	e8 ac e8 ff ff       	call   f0101126 <check_va2pa>
f010287a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010287d:	74 24                	je     f01028a3 <i386_vm_init+0x1181>
f010287f:	c7 44 24 0c 94 74 10 	movl   $0xf0107494,0xc(%esp)
f0102886:	f0 
f0102887:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010288e:	f0 
f010288f:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102896:	00 
f0102897:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010289e:	e8 e2 d7 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f01028a3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028a8:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01028ad:	e8 74 e8 ff ff       	call   f0101126 <check_va2pa>
f01028b2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028b5:	74 24                	je     f01028db <i386_vm_init+0x11b9>
f01028b7:	c7 44 24 0c b8 74 10 	movl   $0xf01074b8,0xc(%esp)
f01028be:	f0 
f01028bf:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01028c6:	f0 
f01028c7:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01028ce:	00 
f01028cf:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01028d6:	e8 aa d7 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01028db:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01028de:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01028e3:	74 24                	je     f0102909 <i386_vm_init+0x11e7>
f01028e5:	c7 44 24 0c 14 78 10 	movl   $0xf0107814,0xc(%esp)
f01028ec:	f0 
f01028ed:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01028f4:	f0 
f01028f5:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01028fc:	00 
f01028fd:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102904:	e8 7c d7 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102909:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010290c:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102911:	74 24                	je     f0102937 <i386_vm_init+0x1215>
f0102913:	c7 44 24 0c 03 78 10 	movl   $0xf0107803,0xc(%esp)
f010291a:	f0 
f010291b:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102922:	f0 
f0102923:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f010292a:	00 
f010292b:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102932:	e8 4e d7 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f0102937:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010293a:	89 04 24             	mov    %eax,(%esp)
f010293d:	e8 5d e8 ff ff       	call   f010119f <page_alloc>
f0102942:	85 c0                	test   %eax,%eax
f0102944:	75 08                	jne    f010294e <i386_vm_init+0x122c>
f0102946:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102949:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f010294c:	74 24                	je     f0102972 <i386_vm_init+0x1250>
f010294e:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f0102955:	f0 
f0102956:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f010295d:	f0 
f010295e:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102965:	00 
f0102966:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f010296d:	e8 13 d7 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102972:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102975:	89 04 24             	mov    %eax,(%esp)
f0102978:	e8 22 e8 ff ff       	call   f010119f <page_alloc>
f010297d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102980:	74 24                	je     f01029a6 <i386_vm_init+0x1284>
f0102982:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0102989:	f0 
f010298a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102991:	f0 
f0102992:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102999:	00 
f010299a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01029a1:	e8 df d6 ff ff       	call   f0100085 <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01029a6:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f01029ab:	8b 08                	mov    (%eax),%ecx
f01029ad:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01029b3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01029b6:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f01029bc:	c1 fa 02             	sar    $0x2,%edx
f01029bf:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01029c5:	c1 e2 0c             	shl    $0xc,%edx
f01029c8:	39 d1                	cmp    %edx,%ecx
f01029ca:	74 24                	je     f01029f0 <i386_vm_init+0x12ce>
f01029cc:	c7 44 24 0c 00 72 10 	movl   $0xf0107200,0xc(%esp)
f01029d3:	f0 
f01029d4:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f01029db:	f0 
f01029dc:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01029e3:	00 
f01029e4:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01029eb:	e8 95 d6 ff ff       	call   f0100085 <_panic>
	boot_pgdir[0] = 0;
f01029f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01029f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029f9:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f01029fe:	74 24                	je     f0102a24 <i386_vm_init+0x1302>
f0102a00:	c7 44 24 0c ba 77 10 	movl   $0xf01077ba,0xc(%esp)
f0102a07:	f0 
f0102a08:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102a0f:	f0 
f0102a10:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102a17:	00 
f0102a18:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102a1f:	e8 61 d6 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102a24:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a2d:	89 04 24             	mov    %eax,(%esp)
f0102a30:	e8 b1 e4 ff ff       	call   f0100ee6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f0102a35:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102a3c:	00 
f0102a3d:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102a44:	00 
f0102a45:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102a4a:	89 04 24             	mov    %eax,(%esp)
f0102a4d:	e8 9d e7 ff ff       	call   f01011ef <pgdir_walk>
f0102a52:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f0102a55:	8b 0d 98 43 1e f0    	mov    0xf01e4398,%ecx
f0102a5b:	83 c1 04             	add    $0x4,%ecx
f0102a5e:	8b 11                	mov    (%ecx),%edx
f0102a60:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102a66:	89 d6                	mov    %edx,%esi
f0102a68:	c1 ee 0c             	shr    $0xc,%esi
f0102a6b:	3b 35 90 43 1e f0    	cmp    0xf01e4390,%esi
f0102a71:	72 20                	jb     f0102a93 <i386_vm_init+0x1371>
f0102a73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102a77:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0102a7e:	f0 
f0102a7f:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102a86:	00 
f0102a87:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102a8e:	e8 f2 d5 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a93:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102a99:	39 d0                	cmp    %edx,%eax
f0102a9b:	74 24                	je     f0102ac1 <i386_vm_init+0x139f>
f0102a9d:	c7 44 24 0c 25 78 10 	movl   $0xf0107825,0xc(%esp)
f0102aa4:	f0 
f0102aa5:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102aac:	f0 
f0102aad:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102ab4:	00 
f0102ab5:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102abc:	e8 c4 d5 ff ff       	call   f0100085 <_panic>
	boot_pgdir[PDX(va)] = 0;
f0102ac1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0102ac7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102aca:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102ad0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ad3:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f0102ad9:	c1 f8 02             	sar    $0x2,%eax
f0102adc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ae2:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102ae5:	89 c2                	mov    %eax,%edx
f0102ae7:	c1 ea 0c             	shr    $0xc,%edx
f0102aea:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0102af0:	72 20                	jb     f0102b12 <i386_vm_init+0x13f0>
f0102af2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102af6:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102b05:	00 
f0102b06:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f0102b0d:	e8 73 d5 ff ff       	call   f0100085 <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102b12:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b19:	00 
f0102b1a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102b21:	00 
f0102b22:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b27:	89 04 24             	mov    %eax,(%esp)
f0102b2a:	e8 b7 28 00 00       	call   f01053e6 <memset>
	page_free(pp0);
f0102b2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102b32:	89 04 24             	mov    %eax,(%esp)
f0102b35:	e8 ac e3 ff ff       	call   f0100ee6 <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102b3a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b41:	00 
f0102b42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b49:	00 
f0102b4a:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102b4f:	89 04 24             	mov    %eax,(%esp)
f0102b52:	e8 98 e6 ff ff       	call   f01011ef <pgdir_walk>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102b57:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102b5a:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f0102b60:	c1 fa 02             	sar    $0x2,%edx
f0102b63:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102b69:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102b6c:	89 d0                	mov    %edx,%eax
f0102b6e:	c1 e8 0c             	shr    $0xc,%eax
f0102b71:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f0102b77:	72 20                	jb     f0102b99 <i386_vm_init+0x1477>
f0102b79:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b7d:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0102b84:	f0 
f0102b85:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102b8c:	00 
f0102b8d:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f0102b94:	e8 ec d4 ff ff       	call   f0100085 <_panic>
	ptep = page2kva(pp0);
f0102b99:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102b9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102ba2:	f6 00 01             	testb  $0x1,(%eax)
f0102ba5:	75 11                	jne    f0102bb8 <i386_vm_init+0x1496>
f0102ba7:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init()
f0102bad:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102bb3:	f6 00 01             	testb  $0x1,(%eax)
f0102bb6:	74 24                	je     f0102bdc <i386_vm_init+0x14ba>
f0102bb8:	c7 44 24 0c 3d 78 10 	movl   $0xf010783d,0xc(%esp)
f0102bbf:	f0 
f0102bc0:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102bc7:	f0 
f0102bc8:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102bcf:	00 
f0102bd0:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102bd7:	e8 a9 d4 ff ff       	call   f0100085 <_panic>
f0102bdc:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102bdf:	39 d0                	cmp    %edx,%eax
f0102be1:	75 d0                	jne    f0102bb3 <i386_vm_init+0x1491>
		assert((ptep[i] & PTE_P) == 0);
	boot_pgdir[0] = 0;
f0102be3:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102be8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102bee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102bf1:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102bf7:	89 1d b8 25 1e f0    	mov    %ebx,0xf01e25b8

	// free the pages we took
	page_free(pp0);
f0102bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c00:	89 04 24             	mov    %eax,(%esp)
f0102c03:	e8 de e2 ff ff       	call   f0100ee6 <page_free>
	page_free(pp1);
f0102c08:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102c0b:	89 04 24             	mov    %eax,(%esp)
f0102c0e:	e8 d3 e2 ff ff       	call   f0100ee6 <page_free>
	page_free(pp2);
f0102c13:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c16:	89 04 24             	mov    %eax,(%esp)
f0102c19:	e8 c8 e2 ff ff       	call   f0100ee6 <page_free>
	
	cprintf("page_check() succeeded!\n");
f0102c1e:	c7 04 24 54 78 10 f0 	movl   $0xf0107854,(%esp)
f0102c25:	e8 e1 0d 00 00       	call   f0103a0b <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:	
	boot_map_segment(boot_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
f0102c2a:	a1 9c 43 1e f0       	mov    0xf01e439c,%eax
f0102c2f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c34:	77 20                	ja     f0102c56 <i386_vm_init+0x1534>
f0102c36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c3a:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0102c41:	f0 
f0102c42:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f0102c49:	00 
f0102c4a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102c51:	e8 2f d4 ff ff       	call   f0100085 <_panic>
f0102c56:	8b 15 90 43 1e f0    	mov    0xf01e4390,%edx
f0102c5c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102c5f:	8d 0c 95 ff 0f 00 00 	lea    0xfff(,%edx,4),%ecx
f0102c66:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c6c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c73:	00 
f0102c74:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c79:	89 04 24             	mov    %eax,(%esp)
f0102c7c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c81:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102c86:	e8 57 e9 ff ff       	call   f01015e2 <boot_map_segment>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_segment(boot_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0102c8b:	a1 c0 25 1e f0       	mov    0xf01e25c0,%eax
f0102c90:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c95:	77 20                	ja     f0102cb7 <i386_vm_init+0x1595>
f0102c97:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c9b:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0102ca2:	f0 
f0102ca3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f0102caa:	00 
f0102cab:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102cb2:	e8 ce d3 ff ff       	call   f0100085 <_panic>
f0102cb7:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102cbe:	00 
f0102cbf:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cc4:	89 04 24             	mov    %eax,(%esp)
f0102cc7:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102ccc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102cd1:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102cd6:	e8 07 e9 ff ff       	call   f01015e2 <boot_map_segment>
			
			//we estart here bhithout bakchodi!
			//padh gaye poot kumhaar ke, solah dooni aath!!!
			################################################3
	*/
	boot_map_segment(boot_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
f0102cdb:	bb 00 70 11 f0       	mov    $0xf0117000,%ebx
f0102ce0:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ce6:	77 20                	ja     f0102d08 <i386_vm_init+0x15e6>
f0102ce8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cec:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0102cf3:	f0 
f0102cf4:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
f0102cfb:	00 
f0102cfc:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102d03:	e8 7d d3 ff ff       	call   f0100085 <_panic>
f0102d08:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d0f:	00 
f0102d10:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d16:	89 04 24             	mov    %eax,(%esp)
f0102d19:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d1e:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102d23:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102d28:	e8 b5 e8 ff ff       	call   f01015e2 <boot_map_segment>
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 

	//2^32 = 0xffffffff+1
	boot_map_segment(boot_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);
f0102d2d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d34:	00 
f0102d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d3c:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102d41:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d46:	a1 98 43 1e f0       	mov    0xf01e4398,%eax
f0102d4b:	e8 92 e8 ff ff       	call   f01015e2 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0102d50:	8b 35 98 43 1e f0    	mov    0xf01e4398,%esi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0102d56:	6b 05 90 43 1e f0 0c 	imul   $0xc,0xf01e4390,%eax
f0102d5d:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d67:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102d6a:	bf 00 00 00 00       	mov    $0x0,%edi
f0102d6f:	eb 70                	jmp    f0102de1 <i386_vm_init+0x16bf>
	for (i = 0; i < n; i += PGSIZE)
	{
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d71:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0102d77:	89 f0                	mov    %esi,%eax
f0102d79:	e8 a8 e3 ff ff       	call   f0101126 <check_va2pa>
f0102d7e:	8b 15 9c 43 1e f0    	mov    0xf01e439c,%edx
f0102d84:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d8a:	77 20                	ja     f0102dac <i386_vm_init+0x168a>
f0102d8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d90:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0102d97:	f0 
f0102d98:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0102d9f:	00 
f0102da0:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102da7:	e8 d9 d2 ff ff       	call   f0100085 <_panic>
f0102dac:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f0102db3:	39 d0                	cmp    %edx,%eax
f0102db5:	74 24                	je     f0102ddb <i386_vm_init+0x16b9>
f0102db7:	c7 44 24 0c 04 75 10 	movl   $0xf0107504,0xc(%esp)
f0102dbe:	f0 
f0102dbf:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102dc6:	f0 
f0102dc7:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0102dce:	00 
f0102dcf:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102dd6:	e8 aa d2 ff ff       	call   f0100085 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ddb:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102de1:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0102de4:	77 8b                	ja     f0102d71 <i386_vm_init+0x164f>
f0102de6:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102deb:	8d 97 00 00 c0 ee    	lea    -0x11400000(%edi),%edx
f0102df1:	89 f0                	mov    %esi,%eax
f0102df3:	e8 2e e3 ff ff       	call   f0101126 <check_va2pa>
f0102df8:	8b 15 c0 25 1e f0    	mov    0xf01e25c0,%edx
f0102dfe:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102e04:	77 20                	ja     f0102e26 <i386_vm_init+0x1704>
f0102e06:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e0a:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0102e11:	f0 
f0102e12:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0102e19:	00 
f0102e1a:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102e21:	e8 5f d2 ff ff       	call   f0100085 <_panic>
f0102e26:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f0102e2d:	39 d0                	cmp    %edx,%eax
f0102e2f:	74 24                	je     f0102e55 <i386_vm_init+0x1733>
f0102e31:	c7 44 24 0c 38 75 10 	movl   $0xf0107538,0xc(%esp)
f0102e38:	f0 
f0102e39:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102e40:	f0 
f0102e41:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0102e48:	00 
f0102e49:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102e50:	e8 30 d2 ff ff       	call   f0100085 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	}
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e55:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102e5b:	81 ff 00 f0 01 00    	cmp    $0x1f000,%edi
f0102e61:	75 88                	jne    f0102deb <i386_vm_init+0x16c9>
f0102e63:	bf 00 00 00 00       	mov    $0x0,%edi
f0102e68:	eb 3b                	jmp    f0102ea5 <i386_vm_init+0x1783>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e6a:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0102e70:	89 f0                	mov    %esi,%eax
f0102e72:	e8 af e2 ff ff       	call   f0101126 <check_va2pa>
f0102e77:	39 c7                	cmp    %eax,%edi
f0102e79:	74 24                	je     f0102e9f <i386_vm_init+0x177d>
f0102e7b:	c7 44 24 0c 6c 75 10 	movl   $0xf010756c,0xc(%esp)
f0102e82:	f0 
f0102e83:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102e8a:	f0 
f0102e8b:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
f0102e92:	00 
f0102e93:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102e9a:	e8 e6 d1 ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
f0102e9f:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102ea5:	a1 90 43 1e f0       	mov    0xf01e4390,%eax
f0102eaa:	c1 e0 0c             	shl    $0xc,%eax
f0102ead:	39 c7                	cmp    %eax,%edi
f0102eaf:	72 b9                	jb     f0102e6a <i386_vm_init+0x1748>
f0102eb1:	bf 00 80 bf ef       	mov    $0xefbf8000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102eb6:	81 c3 00 80 40 20    	add    $0x20408000,%ebx
f0102ebc:	89 fa                	mov    %edi,%edx
f0102ebe:	89 f0                	mov    %esi,%eax
f0102ec0:	e8 61 e2 ff ff       	call   f0101126 <check_va2pa>
f0102ec5:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102ec8:	39 d0                	cmp    %edx,%eax
f0102eca:	74 24                	je     f0102ef0 <i386_vm_init+0x17ce>
f0102ecc:	c7 44 24 0c 94 75 10 	movl   $0xf0107594,0xc(%esp)
f0102ed3:	f0 
f0102ed4:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102edb:	f0 
f0102edc:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f0102ee3:	00 
f0102ee4:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102eeb:	e8 95 d1 ff ff       	call   f0100085 <_panic>
f0102ef0:	81 c7 00 10 00 00    	add    $0x1000,%edi
	// check phys mem
	for (i = 0; i < npage * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ef6:	81 ff 00 00 c0 ef    	cmp    $0xefc00000,%edi
f0102efc:	75 be                	jne    f0102ebc <i386_vm_init+0x179a>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102efe:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0102f03:	89 f0                	mov    %esi,%eax
f0102f05:	e8 1c e2 ff ff       	call   f0101126 <check_va2pa>
f0102f0a:	ba 00 00 00 00       	mov    $0x0,%edx
f0102f0f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f12:	74 24                	je     f0102f38 <i386_vm_init+0x1816>
f0102f14:	c7 44 24 0c dc 75 10 	movl   $0xf01075dc,0xc(%esp)
f0102f1b:	f0 
f0102f1c:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102f23:	f0 
f0102f24:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
f0102f2b:	00 
f0102f2c:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102f33:	e8 4d d1 ff ff       	call   f0100085 <_panic>

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) 
	{
		switch (i) 
f0102f38:	8d 82 45 fc ff ff    	lea    -0x3bb(%edx),%eax
f0102f3e:	83 f8 04             	cmp    $0x4,%eax
f0102f41:	77 2e                	ja     f0102f71 <i386_vm_init+0x184f>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f0102f43:	83 3c 96 00          	cmpl   $0x0,(%esi,%edx,4)
f0102f47:	0f 85 80 00 00 00    	jne    f0102fcd <i386_vm_init+0x18ab>
f0102f4d:	c7 44 24 0c 6d 78 10 	movl   $0xf010786d,0xc(%esp)
f0102f54:	f0 
f0102f55:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102f5c:	f0 
f0102f5d:	c7 44 24 04 b3 01 00 	movl   $0x1b3,0x4(%esp)
f0102f64:	00 
f0102f65:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102f6c:	e8 14 d1 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0102f71:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f0102f77:	76 2a                	jbe    f0102fa3 <i386_vm_init+0x1881>
				assert(pgdir[i]);
f0102f79:	83 3c 96 00          	cmpl   $0x0,(%esi,%edx,4)
f0102f7d:	75 4e                	jne    f0102fcd <i386_vm_init+0x18ab>
f0102f7f:	c7 44 24 0c 6d 78 10 	movl   $0xf010786d,0xc(%esp)
f0102f86:	f0 
f0102f87:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102f8e:	f0 
f0102f8f:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f0102f96:	00 
f0102f97:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102f9e:	e8 e2 d0 ff ff       	call   f0100085 <_panic>
			else
				assert(pgdir[i] == 0);
f0102fa3:	83 3c 96 00          	cmpl   $0x0,(%esi,%edx,4)
f0102fa7:	74 24                	je     f0102fcd <i386_vm_init+0x18ab>
f0102fa9:	c7 44 24 0c 76 78 10 	movl   $0xf0107876,0xc(%esp)
f0102fb0:	f0 
f0102fb1:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0102fb8:	f0 
f0102fb9:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0102fc0:	00 
f0102fc1:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f0102fc8:	e8 b8 d0 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) 
f0102fcd:	83 c2 01             	add    $0x1,%edx
f0102fd0:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0102fd6:	0f 85 5c ff ff ff    	jne    f0102f38 <i386_vm_init+0x1816>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0102fdc:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0102fdf:	8b 82 00 0f 00 00    	mov    0xf00(%edx),%eax
f0102fe5:	89 02                	mov    %eax,(%edx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102fe7:	a1 94 43 1e f0       	mov    0xf01e4394,%eax
f0102fec:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102fef:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0102ff2:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102ff7:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ffa:	0f 22 c0             	mov    %eax,%cr0
	lcr0(cr0);
	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0102ffd:	0f 01 15 50 f3 11 f0 	lgdtl  0xf011f350
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103004:	b8 23 00 00 00       	mov    $0x23,%eax
f0103009:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010300b:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010300d:	b0 10                	mov    $0x10,%al
f010300f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103011:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103013:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0103015:	ea 1c 30 10 f0 08 00 	ljmp   $0x8,$0xf010301c
	asm volatile("lldt %%ax" :: "a" (0));
f010301c:	b0 00                	mov    $0x0,%al
f010301e:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f0103021:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103027:	a1 94 43 1e f0       	mov    0xf01e4394,%eax
f010302c:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
	
}
f010302f:	83 c4 4c             	add    $0x4c,%esp
f0103032:	5b                   	pop    %ebx
f0103033:	5e                   	pop    %esi
f0103034:	5f                   	pop    %edi
f0103035:	5d                   	pop    %ebp
f0103036:	c3                   	ret    
	...

f0103040 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103040:	55                   	push   %ebp
f0103041:	89 e5                	mov    %esp,%ebp
f0103043:	53                   	push   %ebx
f0103044:	8b 45 08             	mov    0x8(%ebp),%eax
f0103047:	8b 4d 0c             	mov    0xc(%ebp),%ecx

//	cprintf("\nIn envid2env\n");
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010304a:	85 c0                	test   %eax,%eax
f010304c:	75 0e                	jne    f010305c <envid2env+0x1c>
		*env_store = curenv;
f010304e:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103053:	89 01                	mov    %eax,(%ecx)
f0103055:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010305a:	eb 54                	jmp    f01030b0 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010305c:	89 c2                	mov    %eax,%edx
f010305e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103064:	6b d2 7c             	imul   $0x7c,%edx,%edx
f0103067:	03 15 c0 25 1e f0    	add    0xf01e25c0,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010306d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103071:	74 05                	je     f0103078 <envid2env+0x38>
f0103073:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0103076:	74 0d                	je     f0103085 <envid2env+0x45>
		*env_store = 0;
f0103078:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f010307e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103083:	eb 2b                	jmp    f01030b0 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103085:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103089:	74 1e                	je     f01030a9 <envid2env+0x69>
f010308b:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103090:	39 c2                	cmp    %eax,%edx
f0103092:	74 15                	je     f01030a9 <envid2env+0x69>
f0103094:	8b 5a 50             	mov    0x50(%edx),%ebx
f0103097:	3b 58 4c             	cmp    0x4c(%eax),%ebx
f010309a:	74 0d                	je     f01030a9 <envid2env+0x69>
		*env_store = 0;
f010309c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f01030a2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01030a7:	eb 07                	jmp    f01030b0 <envid2env+0x70>
	}

	*env_store = e;
f01030a9:	89 11                	mov    %edx,(%ecx)
f01030ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01030b0:	5b                   	pop    %ebx
f01030b1:	5d                   	pop    %ebp
f01030b2:	c3                   	ret    

f01030b3 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01030b3:	55                   	push   %ebp
f01030b4:	89 e5                	mov    %esp,%ebp
f01030b6:	83 ec 18             	sub    $0x18,%esp
		//lcr3(boot_cr3);
	//print_trapframe(tf);
	asm volatile("movl %0,%%esp\n"
f01030b9:	8b 65 08             	mov    0x8(%ebp),%esp
f01030bc:	61                   	popa   
f01030bd:	07                   	pop    %es
f01030be:	1f                   	pop    %ds
f01030bf:	83 c4 08             	add    $0x8,%esp
f01030c2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01030c3:	c7 44 24 08 84 78 10 	movl   $0xf0107884,0x8(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
f01030d2:	00 
f01030d3:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f01030da:	e8 a6 cf ff ff       	call   f0100085 <_panic>

f01030df <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01030df:	55                   	push   %ebp
f01030e0:	89 e5                	mov    %esp,%ebp
f01030e2:	83 ec 18             	sub    $0x18,%esp
f01030e5:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.
	//cprintf("%d is going to run\n",e->env_id);
	if(curenv != e)
f01030e8:	39 05 c4 25 1e f0    	cmp    %eax,0xf01e25c4
f01030ee:	74 14                	je     f0103104 <env_run+0x25>
	{	
		curenv = e;
f01030f0:	a3 c4 25 1e f0       	mov    %eax,0xf01e25c4
		e->env_runs += 1;
f01030f5:	83 40 58 01          	addl   $0x1,0x58(%eax)
f01030f9:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f01030fe:	8b 40 60             	mov    0x60(%eax),%eax
f0103101:	0f 22 d8             	mov    %eax,%cr3
	//{
//	if(e->env_id == 0x1001)
//	print_trapframe(&curenv->env_tf);
//	if(curenv->env_id != 0x1004)
//	cprintf("running %x\n", curenv->env_id);
	env_pop_tf(&curenv->env_tf);
f0103104:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103109:	89 04 24             	mov    %eax,(%esp)
f010310c:	e8 a2 ff ff ff       	call   f01030b3 <env_pop_tf>

f0103111 <env_init>:
			//padh gaye poot kumhaar ke, solah dooni aath!!!
			################################################3
	*/
void
env_init(void)
{
f0103111:	55                   	push   %ebp
f0103112:	89 e5                	mov    %esp,%ebp
f0103114:	83 ec 18             	sub    $0x18,%esp

	cprintf("\n in env_init\n");	
f0103117:	c7 04 24 9b 78 10 f0 	movl   $0xf010789b,(%esp)
f010311e:	e8 e8 08 00 00       	call   f0103a0b <cprintf>
f0103123:	b8 84 ef 01 00       	mov    $0x1ef84,%eax
	int i;
	for(i=NENV-1;i>=0;i--)
	{
		envs[i].env_id = 0;
f0103128:	8b 15 c0 25 1e f0    	mov    0xf01e25c0,%edx
f010312e:	c7 44 02 4c 00 00 00 	movl   $0x0,0x4c(%edx,%eax,1)
f0103135:	00 
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f0103136:	8b 15 c8 25 1e f0    	mov    0xf01e25c8,%edx
f010313c:	8b 0d c0 25 1e f0    	mov    0xf01e25c0,%ecx
f0103142:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
f0103146:	85 d2                	test   %edx,%edx
f0103148:	74 14                	je     f010315e <env_init+0x4d>
f010314a:	89 c1                	mov    %eax,%ecx
f010314c:	03 0d c0 25 1e f0    	add    0xf01e25c0,%ecx
f0103152:	83 c1 44             	add    $0x44,%ecx
f0103155:	8b 15 c8 25 1e f0    	mov    0xf01e25c8,%edx
f010315b:	89 4a 48             	mov    %ecx,0x48(%edx)
f010315e:	89 c2                	mov    %eax,%edx
f0103160:	03 15 c0 25 1e f0    	add    0xf01e25c0,%edx
f0103166:	89 15 c8 25 1e f0    	mov    %edx,0xf01e25c8
f010316c:	c7 42 48 c8 25 1e f0 	movl   $0xf01e25c8,0x48(%edx)
f0103173:	83 e8 7c             	sub    $0x7c,%eax
env_init(void)
{

	cprintf("\n in env_init\n");	
	int i;
	for(i=NENV-1;i>=0;i--)
f0103176:	83 f8 84             	cmp    $0xffffff84,%eax
f0103179:	75 ad                	jne    f0103128 <env_init+0x17>
	{
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
	}
}
f010317b:	c9                   	leave  
f010317c:	c3                   	ret    

f010317d <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f010317d:	55                   	push   %ebp
f010317e:	89 e5                	mov    %esp,%ebp
f0103180:	57                   	push   %edi
f0103181:	56                   	push   %esi
f0103182:	53                   	push   %ebx
f0103183:	83 ec 2c             	sub    $0x2c,%esp
f0103186:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103189:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103190:	3b 3d c4 25 1e f0    	cmp    0xf01e25c4,%edi
f0103196:	75 08                	jne    f01031a0 <env_free+0x23>
f0103198:	a1 94 43 1e f0       	mov    0xf01e4394,%eax
f010319d:	0f 22 d8             	mov    %eax,%cr3
f01031a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031a3:	c1 e0 02             	shl    $0x2,%eax
f01031a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01031a9:	8b 47 5c             	mov    0x5c(%edi),%eax
f01031ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01031af:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01031b2:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01031b8:	0f 84 bb 00 00 00    	je     f0103279 <env_free+0xfc>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01031be:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f01031c4:	89 f0                	mov    %esi,%eax
f01031c6:	c1 e8 0c             	shr    $0xc,%eax
f01031c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01031cc:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f01031d2:	72 20                	jb     f01031f4 <env_free+0x77>
f01031d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01031d8:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f01031df:	f0 
f01031e0:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f01031e7:	00 
f01031e8:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f01031ef:	e8 91 ce ff ff       	call   f0100085 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01031f7:	c1 e2 16             	shl    $0x16,%edx
f01031fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01031fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0103202:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103209:	01 
f010320a:	74 17                	je     f0103223 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010320c:	89 d8                	mov    %ebx,%eax
f010320e:	c1 e0 0c             	shl    $0xc,%eax
f0103211:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103214:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103218:	8b 47 5c             	mov    0x5c(%edi),%eax
f010321b:	89 04 24             	mov    %eax,(%esp)
f010321e:	e8 ac e2 ff ff       	call   f01014cf <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103223:	83 c3 01             	add    $0x1,%ebx
f0103226:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010322c:	75 d4                	jne    f0103202 <env_free+0x85>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010322e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103231:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103234:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010323b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010323e:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f0103244:	72 1c                	jb     f0103262 <env_free+0xe5>
		panic("pa2page called with invalid pa");
f0103246:	c7 44 24 08 f0 6e 10 	movl   $0xf0106ef0,0x8(%esp)
f010324d:	f0 
f010324e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0103255:	00 
f0103256:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f010325d:	e8 23 ce ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0103262:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103265:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103268:	c1 e0 02             	shl    $0x2,%eax
f010326b:	03 05 9c 43 1e f0    	add    0xf01e439c,%eax
f0103271:	89 04 24             	mov    %eax,(%esp)
f0103274:	e8 96 dc ff ff       	call   f0100f0f <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103279:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010327d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103284:	0f 85 16 ff ff ff    	jne    f01031a0 <env_free+0x23>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f010328a:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f010328d:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0103294:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010329b:	c1 e8 0c             	shr    $0xc,%eax
f010329e:	3b 05 90 43 1e f0    	cmp    0xf01e4390,%eax
f01032a4:	72 1c                	jb     f01032c2 <env_free+0x145>
		panic("pa2page called with invalid pa");
f01032a6:	c7 44 24 08 f0 6e 10 	movl   $0xf0106ef0,0x8(%esp)
f01032ad:	f0 
f01032ae:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f01032b5:	00 
f01032b6:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f01032bd:	e8 c3 cd ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f01032c2:	6b c0 0c             	imul   $0xc,%eax,%eax
f01032c5:	03 05 9c 43 1e f0    	add    0xf01e439c,%eax
f01032cb:	89 04 24             	mov    %eax,(%esp)
f01032ce:	e8 3c dc ff ff       	call   f0100f0f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01032d3:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f01032da:	a1 c8 25 1e f0       	mov    0xf01e25c8,%eax
f01032df:	89 47 44             	mov    %eax,0x44(%edi)
f01032e2:	85 c0                	test   %eax,%eax
f01032e4:	74 0b                	je     f01032f1 <env_free+0x174>
f01032e6:	8d 57 44             	lea    0x44(%edi),%edx
f01032e9:	a1 c8 25 1e f0       	mov    0xf01e25c8,%eax
f01032ee:	89 50 48             	mov    %edx,0x48(%eax)
f01032f1:	89 3d c8 25 1e f0    	mov    %edi,0xf01e25c8
f01032f7:	c7 47 48 c8 25 1e f0 	movl   $0xf01e25c8,0x48(%edi)
}
f01032fe:	83 c4 2c             	add    $0x2c,%esp
f0103301:	5b                   	pop    %ebx
f0103302:	5e                   	pop    %esi
f0103303:	5f                   	pop    %edi
f0103304:	5d                   	pop    %ebp
f0103305:	c3                   	ret    

f0103306 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0103306:	55                   	push   %ebp
f0103307:	89 e5                	mov    %esp,%ebp
f0103309:	53                   	push   %ebx
f010330a:	83 ec 14             	sub    $0x14,%esp
f010330d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("\nin env_destroy\n");
f0103310:	c7 04 24 aa 78 10 f0 	movl   $0xf01078aa,(%esp)
f0103317:	e8 ef 06 00 00       	call   f0103a0b <cprintf>
	env_free(e);
f010331c:	89 1c 24             	mov    %ebx,(%esp)
f010331f:	e8 59 fe ff ff       	call   f010317d <env_free>

	if (curenv == e) {
f0103324:	39 1d c4 25 1e f0    	cmp    %ebx,0xf01e25c4
f010332a:	75 0f                	jne    f010333b <env_destroy+0x35>
		curenv = NULL;
f010332c:	c7 05 c4 25 1e f0 00 	movl   $0x0,0xf01e25c4
f0103333:	00 00 00 
		//cprintf("\nyielding from env_destroy\n");
		sched_yield();
f0103336:	e8 05 0e 00 00       	call   f0104140 <sched_yield>
	}
}
f010333b:	83 c4 14             	add    $0x14,%esp
f010333e:	5b                   	pop    %ebx
f010333f:	5d                   	pop    %ebp
f0103340:	c3                   	ret    

f0103341 <segment_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
f0103341:	55                   	push   %ebp
f0103342:	89 e5                	mov    %esp,%ebp
f0103344:	57                   	push   %edi
f0103345:	56                   	push   %esi
f0103346:	53                   	push   %ebx
f0103347:	83 ec 3c             	sub    $0x3c,%esp
f010334a:	89 c7                	mov    %eax,%edi
	//   You should round va down, and round (va + len) up.

	//cprintf("\nin segment_alloc\n");
	
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
f010334c:	89 d3                	mov    %edx,%ebx
f010334e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
f0103354:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
f010335b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103360:	29 d8                	sub    %ebx,%eax
f0103362:	c1 e8 0c             	shr    $0xc,%eax
f0103365:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Page *pg;
	for(i=0;i<numPages;i++)
f0103368:	85 c0                	test   %eax,%eax
f010336a:	74 5f                	je     f01033cb <segment_alloc+0x8a>
	//   You should round va down, and round (va + len) up.

	//cprintf("\nin segment_alloc\n");
	
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
f010336c:	be 00 00 00 00       	mov    $0x0,%esi
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
	struct Page *pg;
	for(i=0;i<numPages;i++)
	{
		page_alloc(&pg);
f0103371:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103374:	89 04 24             	mov    %eax,(%esp)
f0103377:	e8 23 de ff ff       	call   f010119f <page_alloc>
		if(page_insert(e->env_pgdir, pg, start, PTE_P|PTE_U|PTE_W)==-E_NO_MEM)
f010337c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103383:	00 
f0103384:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103388:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010338b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010338f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103392:	89 04 24             	mov    %eax,(%esp)
f0103395:	e8 94 e1 ff ff       	call   f010152e <page_insert>
f010339a:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010339d:	75 1c                	jne    f01033bb <segment_alloc+0x7a>
		{
			panic("could not allocate memory to user environment\n");	
f010339f:	c7 44 24 08 d4 78 10 	movl   $0xf01078d4,0x8(%esp)
f01033a6:	f0 
f01033a7:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f01033ae:	00 
f01033af:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f01033b6:	e8 ca cc ff ff       	call   f0100085 <_panic>
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
	struct Page *pg;
	for(i=0;i<numPages;i++)
f01033bb:	83 c6 01             	add    $0x1,%esi
f01033be:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01033c1:	76 08                	jbe    f01033cb <segment_alloc+0x8a>
		page_alloc(&pg);
		if(page_insert(e->env_pgdir, pg, start, PTE_P|PTE_U|PTE_W)==-E_NO_MEM)
		{
			panic("could not allocate memory to user environment\n");	
		}
		start += PGSIZE;
f01033c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033c9:	eb a6                	jmp    f0103371 <segment_alloc+0x30>
	}

}
f01033cb:	83 c4 3c             	add    $0x3c,%esp
f01033ce:	5b                   	pop    %ebx
f01033cf:	5e                   	pop    %esi
f01033d0:	5f                   	pop    %edi
f01033d1:	5d                   	pop    %ebp
f01033d2:	c3                   	ret    

f01033d3 <Env_map_segment>:
}


static void
Env_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f01033d3:	55                   	push   %ebp
f01033d4:	89 e5                	mov    %esp,%ebp
f01033d6:	57                   	push   %edi
f01033d7:	56                   	push   %esi
f01033d8:	53                   	push   %ebx
f01033d9:	83 ec 2c             	sub    $0x2c,%esp
f01033dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01033df:	89 d3                	mov    %edx,%ebx
f01033e1:	8b 7d 08             	mov    0x8(%ebp),%edi

	//cprintf("\n in Env_map_segment\n");
	//cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
f01033e4:	c1 e9 0c             	shr    $0xc,%ecx
f01033e7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01033ea:	85 c9                	test   %ecx,%ecx
f01033ec:	74 54                	je     f0103442 <Env_map_segment+0x6f>
f01033ee:	be 00 00 00 00       	mov    $0x0,%esi
                {
                        cprintf("could not allocate page table in Env_map_segment()!!\n");
                        return;
                }
		//cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
f01033f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033f6:	83 c8 01             	or     $0x1,%eax
f01033f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//cprintf("\n in Env_map_segment\n");
	//cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
        {
                pte_t *pte = pgdir_walk(pgdir, (void*)la, 1);
f01033fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103403:	00 
f0103404:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103408:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010340b:	89 04 24             	mov    %eax,(%esp)
f010340e:	e8 dc dd ff ff       	call   f01011ef <pgdir_walk>
                if(pte == NULL)
f0103413:	85 c0                	test   %eax,%eax
f0103415:	75 0e                	jne    f0103425 <Env_map_segment+0x52>
                {
                        cprintf("could not allocate page table in Env_map_segment()!!\n");
f0103417:	c7 04 24 04 79 10 f0 	movl   $0xf0107904,(%esp)
f010341e:	e8 e8 05 00 00       	call   f0103a0b <cprintf>
                        return;
f0103423:	eb 1d                	jmp    f0103442 <Env_map_segment+0x6f>
                }
		//cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
f0103425:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103428:	09 fa                	or     %edi,%edx
f010342a:	89 10                	mov    %edx,(%eax)
{

	//cprintf("\n in Env_map_segment\n");
	//cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
f010342c:	83 c6 01             	add    $0x1,%esi
f010342f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103432:	73 0e                	jae    f0103442 <Env_map_segment+0x6f>
                        return;
                }
		//cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
		//cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                la+=PGSIZE;
f0103434:	81 c3 00 10 00 00    	add    $0x1000,%ebx
                pa+=PGSIZE;
f010343a:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0103440:	eb ba                	jmp    f01033fc <Env_map_segment+0x29>
        }
}
f0103442:	83 c4 2c             	add    $0x2c,%esp
f0103445:	5b                   	pop    %ebx
f0103446:	5e                   	pop    %esi
f0103447:	5f                   	pop    %edi
f0103448:	5d                   	pop    %ebp
f0103449:	c3                   	ret    

f010344a <env_alloc>:
//	-E_NO_FREE_ENV if NVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010344a:	55                   	push   %ebp
f010344b:	89 e5                	mov    %esp,%ebp
f010344d:	53                   	push   %ebx
f010344e:	83 ec 24             	sub    $0x24,%esp
	//cprintf("\nin env_alloc\n");
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0103451:	8b 1d c8 25 1e f0    	mov    0xf01e25c8,%ebx
f0103457:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010345c:	85 db                	test   %ebx,%ebx
f010345e:	0f 84 9f 02 00 00    	je     f0103703 <env_alloc+0x2b9>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0103464:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	//cprintf("\nin env_setup_vm\n");

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f010346b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010346e:	89 04 24             	mov    %eax,(%esp)
f0103471:	e8 29 dd ff ff       	call   f010119f <page_alloc>
f0103476:	85 c0                	test   %eax,%eax
f0103478:	0f 88 85 02 00 00    	js     f0103703 <env_alloc+0x2b9>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010347e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103481:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f0103487:	c1 f8 02             	sar    $0x2,%eax
f010348a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103490:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0103493:	89 c2                	mov    %eax,%edx
f0103495:	c1 ea 0c             	shr    $0xc,%edx
f0103498:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f010349e:	72 20                	jb     f01034c0 <env_alloc+0x76>
f01034a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034a4:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f01034ab:	f0 
f01034ac:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01034b3:	00 
f01034b4:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f01034bb:	e8 c5 cb ff ff       	call   f0100085 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	// set e->env_pgdir and e->env_cr3,
	e->env_pgdir = page2kva(p);
f01034c0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01034c5:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_cr3 = page2pa(p);
f01034c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034cb:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f01034d1:	c1 f8 02             	sar    $0x2,%eax
f01034d4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01034da:	c1 e0 0c             	shl    $0xc,%eax
f01034dd:	89 43 60             	mov    %eax,0x60(%ebx)
	p->pp_ref++;
f01034e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034e3:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	memset(e->env_pgdir, 0, PGSIZE);
f01034e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01034ef:	00 
f01034f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01034f7:	00 
f01034f8:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01034fb:	89 04 24             	mov    %eax,(%esp)
f01034fe:	e8 e3 1e 00 00       	call   f01053e6 <memset>
	
	// setting the kernel portion of the address space in the environment page dir.
	Env_map_segment(e->env_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
f0103503:	8b 15 9c 43 1e f0    	mov    0xf01e439c,%edx
f0103509:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010350f:	77 20                	ja     f0103531 <env_alloc+0xe7>
f0103511:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103515:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f010351c:	f0 
f010351d:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
f0103524:	00 
f0103525:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f010352c:	e8 54 cb ff ff       	call   f0100085 <_panic>
f0103531:	a1 90 43 1e f0       	mov    0xf01e4390,%eax
f0103536:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103539:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f0103540:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103546:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103549:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103550:	00 
f0103551:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103557:	89 14 24             	mov    %edx,(%esp)
f010355a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010355f:	e8 6f fe ff ff       	call   f01033d3 <Env_map_segment>
	Env_map_segment(e->env_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f0103564:	8b 15 c0 25 1e f0    	mov    0xf01e25c0,%edx
f010356a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103570:	77 20                	ja     f0103592 <env_alloc+0x148>
f0103572:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103576:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f010357d:	f0 
f010357e:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f0103585:	00 
f0103586:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f010358d:	e8 f3 ca ff ff       	call   f0100085 <_panic>
f0103592:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103595:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010359c:	00 
f010359d:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01035a3:	89 14 24             	mov    %edx,(%esp)
f01035a6:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01035ab:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01035b0:	e8 1e fe ff ff       	call   f01033d3 <Env_map_segment>
	Env_map_segment(e->env_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
f01035b5:	ba 00 70 11 f0       	mov    $0xf0117000,%edx
f01035ba:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01035c0:	77 20                	ja     f01035e2 <env_alloc+0x198>
f01035c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01035c6:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f01035cd:	f0 
f01035ce:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
f01035d5:	00 
f01035d6:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f01035dd:	e8 a3 ca ff ff       	call   f0100085 <_panic>
f01035e2:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01035e5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01035ec:	00 
f01035ed:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01035f3:	89 14 24             	mov    %edx,(%esp)
f01035f6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01035fb:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0103600:	e8 ce fd ff ff       	call   f01033d3 <Env_map_segment>
	Env_map_segment(e->env_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);
f0103605:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103608:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010360f:	00 
f0103610:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103617:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010361c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103621:	e8 ad fd ff ff       	call   f01033d3 <Env_map_segment>
	{
		e->env_pgdir[i] = boot_pgdir[i];
	}	*/
	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0103626:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103629:	8b 53 60             	mov    0x60(%ebx),%edx
f010362c:	83 ca 03             	or     $0x3,%edx
f010362f:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0103635:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103638:	8b 53 60             	mov    0x60(%ebx),%edx
f010363b:	83 ca 05             	or     $0x5,%edx
f010363e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103644:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0103647:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	if (generation <= 0)	// Don't create a negative env_id.
f010364d:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103653:	7f 05                	jg     f010365a <env_alloc+0x210>
f0103655:	b9 00 10 00 00       	mov    $0x1000,%ecx
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f010365a:	89 da                	mov    %ebx,%edx
f010365c:	2b 15 c0 25 1e f0    	sub    0xf01e25c0,%edx
f0103662:	c1 fa 02             	sar    $0x2,%edx
f0103665:	69 c2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%eax
f010366b:	09 c8                	or     %ecx,%eax
f010366d:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103670:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103673:	89 43 50             	mov    %eax,0x50(%ebx)
	//cprintf("making runnable %d\n", e->env_id);
	e->env_status = ENV_RUNNABLE;
f0103676:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f010367d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103684:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010368b:	00 
f010368c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103693:	00 
f0103694:	89 1c 24             	mov    %ebx,(%esp)
f0103697:	e8 4a 1d 00 00       	call   f01053e6 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f010369c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01036a2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01036a8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01036ae:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01036b5:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	e->env_tf.tf_eflags |= FL_IF;
f01036bb:	8b 53 38             	mov    0x38(%ebx),%edx
f01036be:	80 ce 02             	or     $0x2,%dh
f01036c1:	89 53 38             	mov    %edx,0x38(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01036c4:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01036cb:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// If this is the file server (e == &envs[1]) give it I/O privileges.
	// LAB 5: Your code here.
	if(e == &envs[1])
f01036d2:	a1 c0 25 1e f0       	mov    0xf01e25c0,%eax
f01036d7:	83 c0 7c             	add    $0x7c,%eax
f01036da:	39 d8                	cmp    %ebx,%eax
f01036dc:	75 06                	jne    f01036e4 <env_alloc+0x29a>
	{
		e->env_tf.tf_eflags = e->env_tf.tf_eflags | FL_IOPL_3;
f01036de:	80 ce 30             	or     $0x30,%dh
f01036e1:	89 50 38             	mov    %edx,0x38(%eax)
	}
	// commit the allocation
	LIST_REMOVE(e, env_link);
f01036e4:	8b 43 44             	mov    0x44(%ebx),%eax
f01036e7:	85 c0                	test   %eax,%eax
f01036e9:	74 06                	je     f01036f1 <env_alloc+0x2a7>
f01036eb:	8b 53 48             	mov    0x48(%ebx),%edx
f01036ee:	89 50 48             	mov    %edx,0x48(%eax)
f01036f1:	8b 43 48             	mov    0x48(%ebx),%eax
f01036f4:	8b 53 44             	mov    0x44(%ebx),%edx
f01036f7:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f01036f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01036fc:	89 18                	mov    %ebx,(%eax)
f01036fe:	b8 00 00 00 00       	mov    $0x0,%eax

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103703:	83 c4 24             	add    $0x24,%esp
f0103706:	5b                   	pop    %ebx
f0103707:	5d                   	pop    %ebp
f0103708:	c3                   	ret    

f0103709 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size)
{
f0103709:	55                   	push   %ebp
f010370a:	89 e5                	mov    %esp,%ebp
f010370c:	57                   	push   %edi
f010370d:	56                   	push   %esi
f010370e:	53                   	push   %ebx
f010370f:	83 ec 3c             	sub    $0x3c,%esp

	struct Env *e;
	//      -E_NO_FREE_ENV if NVS environments are allocated
//      -E_NO_MEM on memory exhau
	int retCode = env_alloc(&e, 0);
f0103712:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103719:	00 
f010371a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010371d:	89 04 24             	mov    %eax,(%esp)
f0103720:	e8 25 fd ff ff       	call   f010344a <env_alloc>
	if(retCode == -E_NO_FREE_ENV)
f0103725:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0103728:	75 1c                	jne    f0103746 <env_create+0x3d>
	{
		panic("Maximum numbers of processes are already running!!");
f010372a:	c7 44 24 08 3c 79 10 	movl   $0xf010793c,0x8(%esp)
f0103731:	f0 
f0103732:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0103739:	00 
f010373a:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f0103741:	e8 3f c9 ff ff       	call   f0100085 <_panic>
	}	
	if(retCode == -E_NO_MEM)
f0103746:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103749:	75 1c                	jne    f0103767 <env_create+0x5e>
	{
		panic("Out Of Memory while creating environment!!");
f010374b:	c7 44 24 08 70 79 10 	movl   $0xf0107970,0x8(%esp)
f0103752:	f0 
f0103753:	c7 44 24 04 ac 01 00 	movl   $0x1ac,0x4(%esp)
f010375a:	00 
f010375b:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f0103762:	e8 1e c9 ff ff       	call   f0100085 <_panic>
	}	

	load_icode(e, binary, size); 	
f0103767:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010376a:	8b 47 60             	mov    0x60(%edi),%eax
f010376d:	0f 22 d8             	mov    %eax,%cr3

	// LAB 3: Your code here.
	lcr3(e->env_cr3);

        struct Proghdr *ph, *eph;
        struct Elf *ELFHDR = (struct Elf *)binary;
f0103770:	8b 45 08             	mov    0x8(%ebp),%eax
f0103773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if(ELFHDR->e_magic != ELF_MAGIC)
f0103776:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010377c:	74 1c                	je     f010379a <env_create+0x91>
        {
                panic("Process Load Error: Not a valid elf");
f010377e:	c7 44 24 08 9c 79 10 	movl   $0xf010799c,0x8(%esp)
f0103785:	f0 
f0103786:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f010378d:	00 
f010378e:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f0103795:	e8 eb c8 ff ff       	call   f0100085 <_panic>
        }
        ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f010379a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010379d:	03 5b 1c             	add    0x1c(%ebx),%ebx
        eph = ph + ELFHDR->e_phnum;
f01037a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01037a3:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi
f01037a7:	c1 e6 05             	shl    $0x5,%esi
f01037aa:	8d 34 33             	lea    (%ebx,%esi,1),%esi

        for (; ph < eph; ph++)
f01037ad:	39 f3                	cmp    %esi,%ebx
f01037af:	0f 83 88 00 00 00    	jae    f010383d <env_create+0x134>
	{
		if(ph->p_type == ELF_PROG_LOAD)
f01037b5:	83 3b 01             	cmpl   $0x1,(%ebx)
f01037b8:	75 78                	jne    f0103832 <env_create+0x129>
		{
			if(ph->p_type > ph->p_memsz)
f01037ba:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01037bd:	85 c9                	test   %ecx,%ecx
f01037bf:	75 1c                	jne    f01037dd <env_create+0xd4>
			    panic("\n Panic in loa_icode\n");
f01037c1:	c7 44 24 08 bb 78 10 	movl   $0xf01078bb,0x8(%esp)
f01037c8:	f0 
f01037c9:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f01037d0:	00 
f01037d1:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f01037d8:	e8 a8 c8 ff ff       	call   f0100085 <_panic>
			segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01037dd:	8b 53 08             	mov    0x8(%ebx),%edx
f01037e0:	89 f8                	mov    %edi,%eax
f01037e2:	e8 5a fb ff ff       	call   f0103341 <segment_alloc>
			memset((void *)ROUNDDOWN(ph->p_va, PGSIZE), 0, ROUNDUP(ph->p_va+ph->p_memsz, PGSIZE)-ROUNDDOWN(ph->p_va, PGSIZE));
f01037e7:	8b 43 08             	mov    0x8(%ebx),%eax
f01037ea:	89 c2                	mov    %eax,%edx
f01037ec:	03 53 14             	add    0x14(%ebx),%edx
f01037ef:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f01037f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01037fa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103800:	29 c2                	sub    %eax,%edx
f0103802:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103806:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010380d:	00 
f010380e:	89 04 24             	mov    %eax,(%esp)
f0103811:	e8 d0 1b 00 00       	call   f01053e6 <memset>
			memmove((void *)ph->p_va, (void *)(binary+ph->p_offset), (size_t)ph->p_filesz);
f0103816:	8b 43 10             	mov    0x10(%ebx),%eax
f0103819:	89 44 24 08          	mov    %eax,0x8(%esp)
f010381d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103820:	03 43 04             	add    0x4(%ebx),%eax
f0103823:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103827:	8b 43 08             	mov    0x8(%ebx),%eax
f010382a:	89 04 24             	mov    %eax,(%esp)
f010382d:	e8 13 1c 00 00       	call   f0105445 <memmove>
                panic("Process Load Error: Not a valid elf");
        }
        ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
        eph = ph + ELFHDR->e_phnum;

        for (; ph < eph; ph++)
f0103832:	83 c3 20             	add    $0x20,%ebx
f0103835:	39 de                	cmp    %ebx,%esi
f0103837:	0f 87 78 ff ff ff    	ja     f01037b5 <env_create+0xac>
			memset((void *)ROUNDDOWN(ph->p_va, PGSIZE), 0, ROUNDUP(ph->p_va+ph->p_memsz, PGSIZE)-ROUNDDOWN(ph->p_va, PGSIZE));
			memmove((void *)ph->p_va, (void *)(binary+ph->p_offset), (size_t)ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
f010383d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103840:	8b 42 18             	mov    0x18(%edx),%eax
f0103843:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0103846:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010384b:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103850:	89 f8                	mov    %edi,%eax
f0103852:	e8 ea fa ff ff       	call   f0103341 <segment_alloc>
	{
		panic("Out Of Memory while creating environment!!");
	}	

	load_icode(e, binary, size); 	
}
f0103857:	83 c4 3c             	add    $0x3c,%esp
f010385a:	5b                   	pop    %ebx
f010385b:	5e                   	pop    %esi
f010385c:	5f                   	pop    %edi
f010385d:	5d                   	pop    %ebp
f010385e:	c3                   	ret    
	...

f0103860 <mc146818_read>:
#include <kern/picirq.h>


unsigned
mc146818_read(unsigned reg)
{
f0103860:	55                   	push   %ebp
f0103861:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103863:	ba 70 00 00 00       	mov    $0x70,%edx
f0103868:	8b 45 08             	mov    0x8(%ebp),%eax
f010386b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010386c:	b2 71                	mov    $0x71,%dl
f010386e:	ec                   	in     (%dx),%al
f010386f:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0103872:	5d                   	pop    %ebp
f0103873:	c3                   	ret    

f0103874 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103874:	55                   	push   %ebp
f0103875:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103877:	ba 70 00 00 00       	mov    $0x70,%edx
f010387c:	8b 45 08             	mov    0x8(%ebp),%eax
f010387f:	ee                   	out    %al,(%dx)
f0103880:	b2 71                	mov    $0x71,%dl
f0103882:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103885:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103886:	5d                   	pop    %ebp
f0103887:	c3                   	ret    

f0103888 <kclock_init>:


void
kclock_init(void)
{
f0103888:	55                   	push   %ebp
f0103889:	89 e5                	mov    %esp,%ebp
f010388b:	83 ec 18             	sub    $0x18,%esp
f010388e:	ba 43 00 00 00       	mov    $0x43,%edx
f0103893:	b8 34 00 00 00       	mov    $0x34,%eax
f0103898:	ee                   	out    %al,(%dx)
f0103899:	b2 40                	mov    $0x40,%dl
f010389b:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f01038a0:	ee                   	out    %al,(%dx)
f01038a1:	b8 2e 00 00 00       	mov    $0x2e,%eax
f01038a6:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f01038a7:	c7 04 24 c0 79 10 f0 	movl   $0xf01079c0,(%esp)
f01038ae:	e8 58 01 00 00       	call   f0103a0b <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f01038b3:	0f b7 05 58 f3 11 f0 	movzwl 0xf011f358,%eax
f01038ba:	25 fe ff 00 00       	and    $0xfffe,%eax
f01038bf:	89 04 24             	mov    %eax,(%esp)
f01038c2:	e8 11 00 00 00       	call   f01038d8 <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f01038c7:	c7 04 24 e3 79 10 f0 	movl   $0xf01079e3,(%esp)
f01038ce:	e8 38 01 00 00       	call   f0103a0b <cprintf>
}
f01038d3:	c9                   	leave  
f01038d4:	c3                   	ret    
f01038d5:	00 00                	add    %al,(%eax)
	...

f01038d8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01038d8:	55                   	push   %ebp
f01038d9:	89 e5                	mov    %esp,%ebp
f01038db:	56                   	push   %esi
f01038dc:	53                   	push   %ebx
f01038dd:	83 ec 10             	sub    $0x10,%esp
f01038e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e3:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01038e5:	66 a3 58 f3 11 f0    	mov    %ax,0xf011f358
	if (!didinit)
f01038eb:	83 3d cc 25 1e f0 00 	cmpl   $0x0,0xf01e25cc
f01038f2:	74 4e                	je     f0103942 <irq_setmask_8259A+0x6a>
f01038f4:	ba 21 00 00 00       	mov    $0x21,%edx
f01038f9:	ee                   	out    %al,(%dx)
f01038fa:	89 f0                	mov    %esi,%eax
f01038fc:	66 c1 e8 08          	shr    $0x8,%ax
f0103900:	b2 a1                	mov    $0xa1,%dl
f0103902:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103903:	c7 04 24 fe 79 10 f0 	movl   $0xf01079fe,(%esp)
f010390a:	e8 fc 00 00 00       	call   f0103a0b <cprintf>
f010390f:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0103914:	0f b7 f6             	movzwl %si,%esi
f0103917:	f7 d6                	not    %esi
f0103919:	0f a3 de             	bt     %ebx,%esi
f010391c:	73 10                	jae    f010392e <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010391e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103922:	c7 04 24 b4 7e 10 f0 	movl   $0xf0107eb4,(%esp)
f0103929:	e8 dd 00 00 00       	call   f0103a0b <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010392e:	83 c3 01             	add    $0x1,%ebx
f0103931:	83 fb 10             	cmp    $0x10,%ebx
f0103934:	75 e3                	jne    f0103919 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103936:	c7 04 24 93 6b 10 f0 	movl   $0xf0106b93,(%esp)
f010393d:	e8 c9 00 00 00       	call   f0103a0b <cprintf>
}
f0103942:	83 c4 10             	add    $0x10,%esp
f0103945:	5b                   	pop    %ebx
f0103946:	5e                   	pop    %esi
f0103947:	5d                   	pop    %ebp
f0103948:	c3                   	ret    

f0103949 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103949:	55                   	push   %ebp
f010394a:	89 e5                	mov    %esp,%ebp
f010394c:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010394f:	c7 05 cc 25 1e f0 01 	movl   $0x1,0xf01e25cc
f0103956:	00 00 00 
f0103959:	ba 21 00 00 00       	mov    $0x21,%edx
f010395e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103963:	ee                   	out    %al,(%dx)
f0103964:	b2 a1                	mov    $0xa1,%dl
f0103966:	ee                   	out    %al,(%dx)
f0103967:	b2 20                	mov    $0x20,%dl
f0103969:	b8 11 00 00 00       	mov    $0x11,%eax
f010396e:	ee                   	out    %al,(%dx)
f010396f:	b2 21                	mov    $0x21,%dl
f0103971:	b8 20 00 00 00       	mov    $0x20,%eax
f0103976:	ee                   	out    %al,(%dx)
f0103977:	b8 04 00 00 00       	mov    $0x4,%eax
f010397c:	ee                   	out    %al,(%dx)
f010397d:	b8 03 00 00 00       	mov    $0x3,%eax
f0103982:	ee                   	out    %al,(%dx)
f0103983:	b2 a0                	mov    $0xa0,%dl
f0103985:	b8 11 00 00 00       	mov    $0x11,%eax
f010398a:	ee                   	out    %al,(%dx)
f010398b:	b2 a1                	mov    $0xa1,%dl
f010398d:	b8 28 00 00 00       	mov    $0x28,%eax
f0103992:	ee                   	out    %al,(%dx)
f0103993:	b8 02 00 00 00       	mov    $0x2,%eax
f0103998:	ee                   	out    %al,(%dx)
f0103999:	b8 01 00 00 00       	mov    $0x1,%eax
f010399e:	ee                   	out    %al,(%dx)
f010399f:	b2 20                	mov    $0x20,%dl
f01039a1:	b8 68 00 00 00       	mov    $0x68,%eax
f01039a6:	ee                   	out    %al,(%dx)
f01039a7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01039ac:	ee                   	out    %al,(%dx)
f01039ad:	b2 a0                	mov    $0xa0,%dl
f01039af:	b8 68 00 00 00       	mov    $0x68,%eax
f01039b4:	ee                   	out    %al,(%dx)
f01039b5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01039ba:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01039bb:	0f b7 05 58 f3 11 f0 	movzwl 0xf011f358,%eax
f01039c2:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01039c6:	74 0b                	je     f01039d3 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01039c8:	0f b7 c0             	movzwl %ax,%eax
f01039cb:	89 04 24             	mov    %eax,(%esp)
f01039ce:	e8 05 ff ff ff       	call   f01038d8 <irq_setmask_8259A>
}
f01039d3:	c9                   	leave  
f01039d4:	c3                   	ret    
f01039d5:	00 00                	add    %al,(%eax)
	...

f01039d8 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01039d8:	55                   	push   %ebp
f01039d9:	89 e5                	mov    %esp,%ebp
f01039db:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01039de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ef:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039fa:	c7 04 24 25 3a 10 f0 	movl   $0xf0103a25,(%esp)
f0103a01:	e8 77 12 00 00       	call   f0104c7d <vprintfmt>
	return cnt;
}
f0103a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a09:	c9                   	leave  
f0103a0a:	c3                   	ret    

f0103a0b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a0b:	55                   	push   %ebp
f0103a0c:	89 e5                	mov    %esp,%ebp
f0103a0e:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0103a11:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103a14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a1b:	89 04 24             	mov    %eax,(%esp)
f0103a1e:	e8 b5 ff ff ff       	call   f01039d8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a23:	c9                   	leave  
f0103a24:	c3                   	ret    

f0103a25 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a25:	55                   	push   %ebp
f0103a26:	89 e5                	mov    %esp,%ebp
f0103a28:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103a2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a2e:	89 04 24             	mov    %eax,(%esp)
f0103a31:	e8 74 ca ff ff       	call   f01004aa <cputchar>
	*cnt++;
}
f0103a36:	c9                   	leave  
f0103a37:	c3                   	ret    
	...

f0103a40 <idt_init>:
void irq_error();
void vmm_syscall();

void
idt_init(void)
{
f0103a40:	55                   	push   %ebp
f0103a41:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	SETGATE( idt[0], 0, GD_KT, DivideByZero, 0);
f0103a43:	b8 e0 40 10 f0       	mov    $0xf01040e0,%eax
f0103a48:	66 a3 e0 25 1e f0    	mov    %ax,0xf01e25e0
f0103a4e:	66 c7 05 e2 25 1e f0 	movw   $0x8,0xf01e25e2
f0103a55:	08 00 
f0103a57:	c6 05 e4 25 1e f0 00 	movb   $0x0,0xf01e25e4
f0103a5e:	c6 05 e5 25 1e f0 8e 	movb   $0x8e,0xf01e25e5
f0103a65:	c1 e8 10             	shr    $0x10,%eax
f0103a68:	66 a3 e6 25 1e f0    	mov    %ax,0xf01e25e6
	SETGATE( idt[13], 0, GD_KT, BadSegment, 0);
f0103a6e:	b8 e6 40 10 f0       	mov    $0xf01040e6,%eax
f0103a73:	66 a3 48 26 1e f0    	mov    %ax,0xf01e2648
f0103a79:	66 c7 05 4a 26 1e f0 	movw   $0x8,0xf01e264a
f0103a80:	08 00 
f0103a82:	c6 05 4c 26 1e f0 00 	movb   $0x0,0xf01e264c
f0103a89:	c6 05 4d 26 1e f0 8e 	movb   $0x8e,0xf01e264d
f0103a90:	c1 e8 10             	shr    $0x10,%eax
f0103a93:	66 a3 4e 26 1e f0    	mov    %ax,0xf01e264e
	SETGATE(idt[T_PGFLT], 0, GD_KT, PageFault, 0);
f0103a99:	b8 ea 40 10 f0       	mov    $0xf01040ea,%eax
f0103a9e:	66 a3 50 26 1e f0    	mov    %ax,0xf01e2650
f0103aa4:	66 c7 05 52 26 1e f0 	movw   $0x8,0xf01e2652
f0103aab:	08 00 
f0103aad:	c6 05 54 26 1e f0 00 	movb   $0x0,0xf01e2654
f0103ab4:	c6 05 55 26 1e f0 8e 	movb   $0x8e,0xf01e2655
f0103abb:	c1 e8 10             	shr    $0x10,%eax
f0103abe:	66 a3 56 26 1e f0    	mov    %ax,0xf01e2656
	SETGATE(idt[T_BRKPT], 0, GD_KT, BreakPoint, 3);
f0103ac4:	b8 ee 40 10 f0       	mov    $0xf01040ee,%eax
f0103ac9:	66 a3 f8 25 1e f0    	mov    %ax,0xf01e25f8
f0103acf:	66 c7 05 fa 25 1e f0 	movw   $0x8,0xf01e25fa
f0103ad6:	08 00 
f0103ad8:	c6 05 fc 25 1e f0 00 	movb   $0x0,0xf01e25fc
f0103adf:	c6 05 fd 25 1e f0 ee 	movb   $0xee,0xf01e25fd
f0103ae6:	c1 e8 10             	shr    $0x10,%eax
f0103ae9:	66 a3 fe 25 1e f0    	mov    %ax,0xf01e25fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscaller, 3);
f0103aef:	b8 f4 40 10 f0       	mov    $0xf01040f4,%eax
f0103af4:	66 a3 60 27 1e f0    	mov    %ax,0xf01e2760
f0103afa:	66 c7 05 62 27 1e f0 	movw   $0x8,0xf01e2762
f0103b01:	08 00 
f0103b03:	c6 05 64 27 1e f0 00 	movb   $0x0,0xf01e2764
f0103b0a:	c6 05 65 27 1e f0 ee 	movb   $0xee,0xf01e2765
f0103b11:	c1 e8 10             	shr    $0x10,%eax
f0103b14:	66 a3 66 27 1e f0    	mov    %ax,0xf01e2766
	SETGATE(idt[VMM_SYSCALL], 0, GD_KT, vmm_syscall, 3);
f0103b1a:	b8 fa 40 10 f0       	mov    $0xf01040fa,%eax
f0103b1f:	66 a3 e0 29 1e f0    	mov    %ax,0xf01e29e0
f0103b25:	66 c7 05 e2 29 1e f0 	movw   $0x8,0xf01e29e2
f0103b2c:	08 00 
f0103b2e:	c6 05 e4 29 1e f0 00 	movb   $0x0,0xf01e29e4
f0103b35:	c6 05 e5 29 1e f0 ee 	movb   $0xee,0xf01e29e5
f0103b3c:	c1 e8 10             	shr    $0x10,%eax
f0103b3f:	66 a3 e6 29 1e f0    	mov    %ax,0xf01e29e6
	SETGATE(idt[IRQ_TIMER+IRQ_OFFSET], 0, GD_KT, irq_timer, 0);		
f0103b45:	b8 04 41 10 f0       	mov    $0xf0104104,%eax
f0103b4a:	66 a3 e0 26 1e f0    	mov    %ax,0xf01e26e0
f0103b50:	66 c7 05 e2 26 1e f0 	movw   $0x8,0xf01e26e2
f0103b57:	08 00 
f0103b59:	c6 05 e4 26 1e f0 00 	movb   $0x0,0xf01e26e4
f0103b60:	c6 05 e5 26 1e f0 8e 	movb   $0x8e,0xf01e26e5
f0103b67:	c1 e8 10             	shr    $0x10,%eax
f0103b6a:	66 a3 e6 26 1e f0    	mov    %ax,0xf01e26e6
			
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b70:	c7 05 e4 2d 1e f0 00 	movl   $0xefc00000,0xf01e2de4
f0103b77:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103b7a:	66 c7 05 e8 2d 1e f0 	movw   $0x10,0xf01e2de8
f0103b81:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b83:	66 c7 05 48 f3 11 f0 	movw   $0x68,0xf011f348
f0103b8a:	68 00 
f0103b8c:	b8 e0 2d 1e f0       	mov    $0xf01e2de0,%eax
f0103b91:	66 a3 4a f3 11 f0    	mov    %ax,0xf011f34a
f0103b97:	89 c2                	mov    %eax,%edx
f0103b99:	c1 ea 10             	shr    $0x10,%edx
f0103b9c:	88 15 4c f3 11 f0    	mov    %dl,0xf011f34c
f0103ba2:	c6 05 4e f3 11 f0 40 	movb   $0x40,0xf011f34e
f0103ba9:	c1 e8 18             	shr    $0x18,%eax
f0103bac:	a2 4f f3 11 f0       	mov    %al,0xf011f34f
					sizeof(struct Taskstate), 0);		
	gdt[GD_TSS >> 3].sd_s = 0;
f0103bb1:	c6 05 4d f3 11 f0 89 	movb   $0x89,0xf011f34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103bb8:	b8 28 00 00 00       	mov    $0x28,%eax
f0103bbd:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0103bc0:	0f 01 1d 5c f3 11 f0 	lidtl  0xf011f35c
}
f0103bc7:	5d                   	pop    %ebp
f0103bc8:	c3                   	ret    

f0103bc9 <break_point_handler>:
	env_destroy(curenv);
}

void
break_point_handler(struct Trapframe *tf)
{
f0103bc9:	55                   	push   %ebp
f0103bca:	89 e5                	mov    %esp,%ebp
f0103bcc:	83 ec 18             	sub    $0x18,%esp
	monitor(tf);	
f0103bcf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bd2:	89 04 24             	mov    %eax,(%esp)
f0103bd5:	e8 e6 cb ff ff       	call   f01007c0 <monitor>
}
f0103bda:	c9                   	leave  
f0103bdb:	c3                   	ret    

f0103bdc <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103bdc:	55                   	push   %ebp
f0103bdd:	89 e5                	mov    %esp,%ebp
f0103bdf:	53                   	push   %ebx
f0103be0:	83 ec 14             	sub    $0x14,%esp
f0103be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103be6:	8b 03                	mov    (%ebx),%eax
f0103be8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bec:	c7 04 24 12 7a 10 f0 	movl   $0xf0107a12,(%esp)
f0103bf3:	e8 13 fe ff ff       	call   f0103a0b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103bf8:	8b 43 04             	mov    0x4(%ebx),%eax
f0103bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bff:	c7 04 24 21 7a 10 f0 	movl   $0xf0107a21,(%esp)
f0103c06:	e8 00 fe ff ff       	call   f0103a0b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c0b:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c12:	c7 04 24 30 7a 10 f0 	movl   $0xf0107a30,(%esp)
f0103c19:	e8 ed fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c1e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103c21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c25:	c7 04 24 3f 7a 10 f0 	movl   $0xf0107a3f,(%esp)
f0103c2c:	e8 da fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c31:	8b 43 10             	mov    0x10(%ebx),%eax
f0103c34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c38:	c7 04 24 4e 7a 10 f0 	movl   $0xf0107a4e,(%esp)
f0103c3f:	e8 c7 fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c44:	8b 43 14             	mov    0x14(%ebx),%eax
f0103c47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c4b:	c7 04 24 5d 7a 10 f0 	movl   $0xf0107a5d,(%esp)
f0103c52:	e8 b4 fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c57:	8b 43 18             	mov    0x18(%ebx),%eax
f0103c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c5e:	c7 04 24 6c 7a 10 f0 	movl   $0xf0107a6c,(%esp)
f0103c65:	e8 a1 fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c6a:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c71:	c7 04 24 7b 7a 10 f0 	movl   $0xf0107a7b,(%esp)
f0103c78:	e8 8e fd ff ff       	call   f0103a0b <cprintf>
}
f0103c7d:	83 c4 14             	add    $0x14,%esp
f0103c80:	5b                   	pop    %ebx
f0103c81:	5d                   	pop    %ebp
f0103c82:	c3                   	ret    

f0103c83 <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0103c83:	55                   	push   %ebp
f0103c84:	89 e5                	mov    %esp,%ebp
f0103c86:	53                   	push   %ebx
f0103c87:	83 ec 14             	sub    $0x14,%esp
f0103c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103c8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c91:	c7 04 24 8a 7a 10 f0 	movl   $0xf0107a8a,(%esp)
f0103c98:	e8 6e fd ff ff       	call   f0103a0b <cprintf>
	print_regs(&tf->tf_regs);
f0103c9d:	89 1c 24             	mov    %ebx,(%esp)
f0103ca0:	e8 37 ff ff ff       	call   f0103bdc <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ca5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cad:	c7 04 24 9c 7a 10 f0 	movl   $0xf0107a9c,(%esp)
f0103cb4:	e8 52 fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103cb9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc1:	c7 04 24 af 7a 10 f0 	movl   $0xf0107aaf,(%esp)
f0103cc8:	e8 3e fd ff ff       	call   f0103a0b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ccd:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103cd0:	83 f8 13             	cmp    $0x13,%eax
f0103cd3:	77 09                	ja     f0103cde <print_trapframe+0x5b>
		return excnames[trapno];
f0103cd5:	8b 14 85 a0 7d 10 f0 	mov    -0xfef8260(,%eax,4),%edx
f0103cdc:	eb 1c                	jmp    f0103cfa <print_trapframe+0x77>
	if (trapno == T_SYSCALL)
f0103cde:	ba c2 7a 10 f0       	mov    $0xf0107ac2,%edx
f0103ce3:	83 f8 30             	cmp    $0x30,%eax
f0103ce6:	74 12                	je     f0103cfa <print_trapframe+0x77>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ce8:	8d 48 e0             	lea    -0x20(%eax),%ecx
f0103ceb:	ba dd 7a 10 f0       	mov    $0xf0107add,%edx
f0103cf0:	83 f9 0f             	cmp    $0xf,%ecx
f0103cf3:	76 05                	jbe    f0103cfa <print_trapframe+0x77>
f0103cf5:	ba ce 7a 10 f0       	mov    $0xf0107ace,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103cfa:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d02:	c7 04 24 f0 7a 10 f0 	movl   $0xf0107af0,(%esp)
f0103d09:	e8 fd fc ff ff       	call   f0103a0b <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f0103d0e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103d11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d15:	c7 04 24 02 7b 10 f0 	movl   $0xf0107b02,(%esp)
f0103d1c:	e8 ea fc ff ff       	call   f0103a0b <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103d21:	8b 43 30             	mov    0x30(%ebx),%eax
f0103d24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d28:	c7 04 24 11 7b 10 f0 	movl   $0xf0107b11,(%esp)
f0103d2f:	e8 d7 fc ff ff       	call   f0103a0b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103d34:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d3c:	c7 04 24 20 7b 10 f0 	movl   $0xf0107b20,(%esp)
f0103d43:	e8 c3 fc ff ff       	call   f0103a0b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d48:	8b 43 38             	mov    0x38(%ebx),%eax
f0103d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d4f:	c7 04 24 33 7b 10 f0 	movl   $0xf0107b33,(%esp)
f0103d56:	e8 b0 fc ff ff       	call   f0103a0b <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d5b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d62:	c7 04 24 42 7b 10 f0 	movl   $0xf0107b42,(%esp)
f0103d69:	e8 9d fc ff ff       	call   f0103a0b <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d6e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d76:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f0103d7d:	e8 89 fc ff ff       	call   f0103a0b <cprintf>
}
f0103d82:	83 c4 14             	add    $0x14,%esp
f0103d85:	5b                   	pop    %ebx
f0103d86:	5d                   	pop    %ebp
f0103d87:	c3                   	ret    

f0103d88 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d88:	55                   	push   %ebp
f0103d89:	89 e5                	mov    %esp,%ebp
f0103d8b:	83 ec 68             	sub    $0x68,%esp
f0103d8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103d91:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103d94:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103d97:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103d9a:	0f 20 d6             	mov    %cr2,%esi
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall != NULL)	
f0103d9d:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103da2:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103da6:	0f 84 1e 01 00 00    	je     f0103eca <page_fault_handler+0x142>
	{
		user_mem_assert(curenv, (void *)(UXSTACKTOP-1), 1, PTE_P|PTE_W|PTE_U);
f0103dac:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103db3:	00 
f0103db4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103dbb:	00 
f0103dbc:	c7 44 24 04 ff ff bf 	movl   $0xeebfffff,0x4(%esp)
f0103dc3:	ee 
f0103dc4:	89 04 24             	mov    %eax,(%esp)
f0103dc7:	e8 28 d6 ff ff       	call   f01013f4 <user_mem_assert>
	        //Page fault in user stack. 	
		if( (curenv->env_tf.tf_esp < (UXSTACKTOP - PGSIZE)))
f0103dcc:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103dd1:	8b 40 3c             	mov    0x3c(%eax),%eax
f0103dd4:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f0103dd9:	77 73                	ja     f0103e4e <page_fault_handler+0xc6>
		{

			struct UTrapframe utf;

		 	utf.utf_fault_va = fault_va;
f0103ddb:	89 75 b4             	mov    %esi,-0x4c(%ebp)
		        utf.utf_err = curenv->env_tf.tf_err;
f0103dde:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103de3:	8b 50 2c             	mov    0x2c(%eax),%edx
f0103de6:	89 55 b8             	mov    %edx,-0x48(%ebp)
			utf.utf_regs = curenv->env_tf.tf_regs;
f0103de9:	8d 55 bc             	lea    -0x44(%ebp),%edx
f0103dec:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103df1:	89 d7                	mov    %edx,%edi
f0103df3:	89 c6                	mov    %eax,%esi
f0103df5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			utf.utf_eip = curenv->env_tf.tf_eip;
f0103df7:	8b 50 30             	mov    0x30(%eax),%edx
f0103dfa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			utf.utf_eflags =  curenv->env_tf.tf_eflags;
f0103dfd:	8b 50 38             	mov    0x38(%eax),%edx
f0103e00:	89 55 e0             	mov    %edx,-0x20(%ebp)
			utf.utf_esp = curenv->env_tf.tf_esp;	
f0103e03:	8b 50 3c             	mov    0x3c(%eax),%edx
f0103e06:	89 55 e4             	mov    %edx,-0x1c(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103e09:	8b 40 60             	mov    0x60(%eax),%eax
f0103e0c:	0f 22 d8             	mov    %eax,%cr3
			lcr3(curenv->env_cr3); // set so as to be able to use memset
						
			memmove((void *)((UXSTACKTOP ) - sizeof(struct UTrapframe) ), &utf, sizeof(struct UTrapframe));
f0103e0f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0103e16:	00 
f0103e17:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f0103e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e1e:	c7 04 24 cc ff bf ee 	movl   $0xeebfffcc,(%esp)
f0103e25:	e8 1b 16 00 00       	call   f0105445 <memmove>

			// +1 , esp set on the address just after writing the UTrapframe 
		  	curenv->env_tf.tf_esp = (UXSTACKTOP - sizeof(struct UTrapframe));      		
f0103e2a:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103e2f:	c7 40 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%eax)
			curenv->env_tf.tf_eip =  (uintptr_t)curenv->env_pgfault_upcall;
f0103e36:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103e3b:	8b 50 64             	mov    0x64(%eax),%edx
f0103e3e:	89 50 30             	mov    %edx,0x30(%eax)
			env_run(curenv);
f0103e41:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103e46:	89 04 24             	mov    %eax,(%esp)
f0103e49:	e8 91 f2 ff ff       	call   f01030df <env_run>
			
		}
		else if( (curenv->env_tf.tf_esp - 4 - sizeof(struct UTrapframe)) > (UXSTACKTOP - PGSIZE)) // page fault in Exception stack
f0103e4e:	83 e8 38             	sub    $0x38,%eax
f0103e51:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
f0103e56:	76 72                	jbe    f0103eca <page_fault_handler+0x142>
		{

			struct UTrapframe utf;

		 	utf.utf_fault_va = fault_va;
f0103e58:	89 75 b4             	mov    %esi,-0x4c(%ebp)
		        utf.utf_err = curenv->env_tf.tf_err;
f0103e5b:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103e60:	8b 50 2c             	mov    0x2c(%eax),%edx
f0103e63:	89 55 b8             	mov    %edx,-0x48(%ebp)
			utf.utf_regs = curenv->env_tf.tf_regs;
f0103e66:	8d 55 bc             	lea    -0x44(%ebp),%edx
f0103e69:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103e6e:	89 d7                	mov    %edx,%edi
f0103e70:	89 c6                	mov    %eax,%esi
f0103e72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			utf.utf_eip = curenv->env_tf.tf_eip;
f0103e74:	8b 50 30             	mov    0x30(%eax),%edx
f0103e77:	89 55 dc             	mov    %edx,-0x24(%ebp)
			utf.utf_eflags =  curenv->env_tf.tf_eflags;
f0103e7a:	8b 50 38             	mov    0x38(%eax),%edx
f0103e7d:	89 55 e0             	mov    %edx,-0x20(%ebp)
			utf.utf_esp = curenv->env_tf.tf_esp;	
f0103e80:	8b 50 3c             	mov    0x3c(%eax),%edx
f0103e83:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103e86:	8b 50 60             	mov    0x60(%eax),%edx
f0103e89:	0f 22 da             	mov    %edx,%cr3
			
			//pushing scratch space
			lcr3(curenv->env_cr3); // set so as to be able to use memset
			//*(uintptr_t*)(curenv->env_tf.tf_esp) = 0;
			//memset((void *)curenv->env_tf.tf_esp, 0, sizeof(int));
			memmove((void *)(curenv->env_tf.tf_esp - 4 - sizeof(struct UTrapframe)), (void *)&utf, sizeof(struct UTrapframe));
f0103e8c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0103e93:	00 
f0103e94:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f0103e97:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e9b:	8b 40 3c             	mov    0x3c(%eax),%eax
f0103e9e:	83 e8 38             	sub    $0x38,%eax
f0103ea1:	89 04 24             	mov    %eax,(%esp)
f0103ea4:	e8 9c 15 00 00       	call   f0105445 <memmove>
			
			// moving the esp forward
		  	curenv->env_tf.tf_esp = (curenv->env_tf.tf_esp - 4 - sizeof(struct UTrapframe) );
f0103ea9:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103eae:	83 68 3c 38          	subl   $0x38,0x3c(%eax)
			//curenv->env_tf.tf_eip =  curenv->env_tf.env_pgfault_upcall;
			curenv->env_tf.tf_eip =  (uintptr_t)curenv->env_pgfault_upcall;
f0103eb2:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103eb7:	8b 50 64             	mov    0x64(%eax),%edx
f0103eba:	89 50 30             	mov    %edx,0x30(%eax)
			env_run(curenv);
f0103ebd:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103ec2:	89 04 24             	mov    %eax,(%esp)
f0103ec5:	e8 15 f2 ff ff       	call   f01030df <env_run>
		 
	}

	 // Exception stack overflow
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103eca:	8b 43 30             	mov    0x30(%ebx),%eax
f0103ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ed1:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103ed5:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103eda:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103edd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee1:	c7 04 24 40 7d 10 f0 	movl   $0xf0107d40,(%esp)
f0103ee8:	e8 1e fb ff ff       	call   f0103a0b <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103eed:	89 1c 24             	mov    %ebx,(%esp)
f0103ef0:	e8 8e fd ff ff       	call   f0103c83 <print_trapframe>
	env_destroy(curenv);
f0103ef5:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103efa:	89 04 24             	mov    %eax,(%esp)
f0103efd:	e8 04 f4 ff ff       	call   f0103306 <env_destroy>
}
f0103f02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103f05:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103f08:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103f0b:	89 ec                	mov    %ebp,%esp
f0103f0d:	5d                   	pop    %ebp
f0103f0e:	c3                   	ret    

f0103f0f <trap>:
        }
}

void
trap(struct Trapframe *tf)
{
f0103f0f:	55                   	push   %ebp
f0103f10:	89 e5                	mov    %esp,%ebp
f0103f12:	57                   	push   %edi
f0103f13:	56                   	push   %esi
f0103f14:	83 ec 20             	sub    $0x20,%esp
f0103f17:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f1a:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f1b:	9c                   	pushf  
f0103f1c:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f1d:	f6 c4 02             	test   $0x2,%ah
f0103f20:	74 24                	je     f0103f46 <trap+0x37>
f0103f22:	c7 44 24 0c 64 7b 10 	movl   $0xf0107b64,0xc(%esp)
f0103f29:	f0 
f0103f2a:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0103f31:	f0 
f0103f32:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f0103f39:	00 
f0103f3a:	c7 04 24 7d 7b 10 f0 	movl   $0xf0107b7d,(%esp)
f0103f41:	e8 3f c1 ff ff       	call   f0100085 <_panic>
	//print_trapframe(tf);
	if ((tf->tf_cs & 3) == 3) 
f0103f46:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f4a:	83 e0 03             	and    $0x3,%eax
f0103f4d:	83 f8 03             	cmp    $0x3,%eax
f0103f50:	75 3c                	jne    f0103f8e <trap+0x7f>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		//cprintf("trapping from user mode\n");
		assert(curenv);
f0103f52:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0103f57:	85 c0                	test   %eax,%eax
f0103f59:	75 24                	jne    f0103f7f <trap+0x70>
f0103f5b:	c7 44 24 0c 89 7b 10 	movl   $0xf0107b89,0xc(%esp)
f0103f62:	f0 
f0103f63:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0103f6a:	f0 
f0103f6b:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
f0103f72:	00 
f0103f73:	c7 04 24 7d 7b 10 f0 	movl   $0xf0107b7d,(%esp)
f0103f7a:	e8 06 c1 ff ff       	call   f0100085 <_panic>
		curenv->env_tf = *tf;
f0103f7f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103f84:	89 c7                	mov    %eax,%edi
f0103f86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103f88:	8b 35 c4 25 1e f0    	mov    0xf01e25c4,%esi

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	//cprintf("in trp_dispatch with tf->tf_trapno: %d\n", tf->tf_trapno);
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103f8e:	8b 46 28             	mov    0x28(%esi),%eax
f0103f91:	83 f8 27             	cmp    $0x27,%eax
f0103f94:	75 19                	jne    f0103faf <trap+0xa0>
		cprintf("Spurious interrupt on irq 7\n");
f0103f96:	c7 04 24 90 7b 10 f0 	movl   $0xf0107b90,(%esp)
f0103f9d:	e8 69 fa ff ff       	call   f0103a0b <cprintf>
		print_trapframe(tf);
f0103fa2:	89 34 24             	mov    %esi,(%esp)
f0103fa5:	e8 d9 fc ff ff       	call   f0103c83 <print_trapframe>
f0103faa:	e9 13 01 00 00       	jmp    f01040c2 <trap+0x1b3>
		return;
	}

	if(tf->tf_trapno == T_BRKPT)
f0103faf:	83 f8 03             	cmp    $0x3,%eax
f0103fb2:	75 11                	jne    f0103fc5 <trap+0xb6>
		monitor(tf);
f0103fb4:	89 34 24             	mov    %esi,(%esp)
f0103fb7:	90                   	nop
f0103fb8:	e8 03 c8 ff ff       	call   f01007c0 <monitor>
f0103fbd:	8d 76 00             	lea    0x0(%esi),%esi
f0103fc0:	e9 fd 00 00 00       	jmp    f01040c2 <trap+0x1b3>
	else if(tf->tf_trapno == T_PGFLT)
f0103fc5:	83 f8 0e             	cmp    $0xe,%eax
f0103fc8:	75 10                	jne    f0103fda <trap+0xcb>
		page_fault_handler(tf);	
f0103fca:	89 34 24             	mov    %esi,(%esp)
f0103fcd:	8d 76 00             	lea    0x0(%esi),%esi
f0103fd0:	e8 b3 fd ff ff       	call   f0103d88 <page_fault_handler>
f0103fd5:	e9 e8 00 00 00       	jmp    f01040c2 <trap+0x1b3>

	else if(tf->tf_trapno == VMM_SYSCALL)
f0103fda:	3d 80 00 00 00       	cmp    $0x80,%eax
f0103fdf:	90                   	nop
f0103fe0:	75 16                	jne    f0103ff8 <trap+0xe9>
	{
		cprintf("Welcome to the Virtual Reality!!!\n");
f0103fe2:	c7 04 24 64 7d 10 f0 	movl   $0xf0107d64,(%esp)
f0103fe9:	e8 1d fa ff ff       	call   f0103a0b <cprintf>
		vmm_init();
f0103fee:	e8 90 1b 00 00       	call   f0105b83 <vmm_init>
f0103ff3:	e9 ca 00 00 00       	jmp    f01040c2 <trap+0x1b3>
	}
	else if(tf->tf_trapno == T_SYSCALL)
f0103ff8:	83 f8 30             	cmp    $0x30,%eax
f0103ffb:	90                   	nop
f0103ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104000:	75 35                	jne    f0104037 <trap+0x128>
	{
		//print_trapframe(tf);
		int r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0104002:	8b 46 04             	mov    0x4(%esi),%eax
f0104005:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104009:	8b 06                	mov    (%esi),%eax
f010400b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010400f:	8b 46 10             	mov    0x10(%esi),%eax
f0104012:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104016:	8b 46 18             	mov    0x18(%esi),%eax
f0104019:	89 44 24 08          	mov    %eax,0x8(%esp)
f010401d:	8b 46 14             	mov    0x14(%esi),%eax
f0104020:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104024:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104027:	89 04 24             	mov    %eax,(%esp)
f010402a:	e8 be 01 00 00       	call   f01041ed <syscall>
			tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi,
			tf->tf_regs.reg_esi );
			//cprintf("\n**returning from syscall with value: %d\n",r);	
			//cprintf("curenv %d\n", curenv->env_id);
		tf->tf_regs.reg_eax = r;
f010402f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104032:	e9 8b 00 00 00       	jmp    f01040c2 <trap+0x1b3>
	}
	else if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104037:	83 f8 20             	cmp    $0x20,%eax
f010403a:	75 09                	jne    f0104045 <trap+0x136>
		sched_yield();
f010403c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104040:	e8 fb 00 00 00       	call   f0104140 <sched_yield>
	}
	// Unexpected trap: The user process or the kernel has a bug.
	else
	{	
		 cprintf("unknown trapping\n");
f0104045:	c7 04 24 ad 7b 10 f0 	movl   $0xf0107bad,(%esp)
f010404c:	e8 ba f9 ff ff       	call   f0103a0b <cprintf>
		  print_trapframe(tf);
f0104051:	89 34 24             	mov    %esi,(%esp)
f0104054:	e8 2a fc ff ff       	call   f0103c83 <print_trapframe>
		 cprintf("%x %x %x %x\n", curenv->env_id, curenv->env_tf.tf_eip, *(int* )curenv->env_tf.tf_eip, *((int*)curenv->env_tf.tf_eip - 1));
f0104059:	8b 15 c4 25 1e f0    	mov    0xf01e25c4,%edx
f010405f:	8b 42 30             	mov    0x30(%edx),%eax
f0104062:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0104065:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104069:	8b 08                	mov    (%eax),%ecx
f010406b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010406f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104073:	8b 42 4c             	mov    0x4c(%edx),%eax
f0104076:	89 44 24 04          	mov    %eax,0x4(%esp)
f010407a:	c7 04 24 bf 7b 10 f0 	movl   $0xf0107bbf,(%esp)
f0104081:	e8 85 f9 ff ff       	call   f0103a0b <cprintf>
		 if (tf->tf_cs == GD_KT)
f0104086:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010408b:	75 1c                	jne    f01040a9 <trap+0x19a>
			panic("unhandled trap in kernel");
f010408d:	c7 44 24 08 cc 7b 10 	movl   $0xf0107bcc,0x8(%esp)
f0104094:	f0 
f0104095:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
f010409c:	00 
f010409d:	c7 04 24 7d 7b 10 f0 	movl   $0xf0107b7d,(%esp)
f01040a4:	e8 dc bf ff ff       	call   f0100085 <_panic>
		else
		 {	
			cprintf("destroying the env now\n");
f01040a9:	c7 04 24 e5 7b 10 f0 	movl   $0xf0107be5,(%esp)
f01040b0:	e8 56 f9 ff ff       	call   f0103a0b <cprintf>
			env_destroy(curenv);
f01040b5:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f01040ba:	89 04 24             	mov    %eax,(%esp)
f01040bd:	e8 44 f2 ff ff       	call   f0103306 <env_destroy>
	//cprintf("returning from trap_dispatch\n");

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
f01040c2:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f01040c7:	85 c0                	test   %eax,%eax
f01040c9:	74 0e                	je     f01040d9 <trap+0x1ca>
f01040cb:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01040cf:	75 08                	jne    f01040d9 <trap+0x1ca>
	{
		env_run(curenv);
f01040d1:	89 04 24             	mov    %eax,(%esp)
f01040d4:	e8 06 f0 ff ff       	call   f01030df <env_run>
	}
	else
	{
		sched_yield();
f01040d9:	e8 62 00 00 00       	call   f0104140 <sched_yield>
	...

f01040e0 <DivideByZero>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 TRAPHANDLER_NOEC(DivideByZero,T_DIVIDE)
f01040e0:	6a 00                	push   $0x0
f01040e2:	6a 00                	push   $0x0
f01040e4:	eb 48                	jmp    f010412e <_alltraps>

f01040e6 <BadSegment>:
 TRAPHANDLER(BadSegment,T_GPFLT)
f01040e6:	6a 0d                	push   $0xd
f01040e8:	eb 44                	jmp    f010412e <_alltraps>

f01040ea <PageFault>:
 TRAPHANDLER(PageFault, T_PGFLT)
f01040ea:	6a 0e                	push   $0xe
f01040ec:	eb 40                	jmp    f010412e <_alltraps>

f01040ee <BreakPoint>:
 TRAPHANDLER_NOEC(BreakPoint, T_BRKPT)
f01040ee:	6a 00                	push   $0x0
f01040f0:	6a 03                	push   $0x3
f01040f2:	eb 3a                	jmp    f010412e <_alltraps>

f01040f4 <syscaller>:
 TRAPHANDLER_NOEC(syscaller, T_SYSCALL)
f01040f4:	6a 00                	push   $0x0
f01040f6:	6a 30                	push   $0x30
f01040f8:	eb 34                	jmp    f010412e <_alltraps>

f01040fa <vmm_syscall>:
 TRAPHANDLER_NOEC(vmm_syscall, VMM_SYSCALL)
f01040fa:	6a 00                	push   $0x0
f01040fc:	68 80 00 00 00       	push   $0x80
f0104101:	eb 2b                	jmp    f010412e <_alltraps>
f0104103:	90                   	nop

f0104104 <irq_timer>:


TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET + IRQ_TIMER)
f0104104:	6a 00                	push   $0x0
f0104106:	6a 20                	push   $0x20
f0104108:	eb 24                	jmp    f010412e <_alltraps>

f010410a <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET + IRQ_KBD)
f010410a:	6a 00                	push   $0x0
f010410c:	6a 21                	push   $0x21
f010410e:	eb 1e                	jmp    f010412e <_alltraps>

f0104110 <irq_slave>:
TRAPHANDLER_NOEC(irq_slave, IRQ_OFFSET + IRQ_SLAVE)
f0104110:	6a 00                	push   $0x0
f0104112:	6a 22                	push   $0x22
f0104114:	eb 18                	jmp    f010412e <_alltraps>

f0104116 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET + IRQ_IDE)
f0104116:	6a 00                	push   $0x0
f0104118:	6a 2e                	push   $0x2e
f010411a:	eb 12                	jmp    f010412e <_alltraps>

f010411c <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET + IRQ_ERROR)
f010411c:	6a 00                	push   $0x0
f010411e:	6a 33                	push   $0x33
f0104120:	eb 0c                	jmp    f010412e <_alltraps>

f0104122 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f0104122:	6a 00                	push   $0x0
f0104124:	6a 27                	push   $0x27
f0104126:	eb 06                	jmp    f010412e <_alltraps>

f0104128 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET + IRQ_SERIAL)
f0104128:	6a 00                	push   $0x0
f010412a:	6a 24                	push   $0x24
f010412c:	eb 00                	jmp    f010412e <_alltraps>

f010412e <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
		pushl %ds
f010412e:	1e                   	push   %ds
		pushl %es
f010412f:	06                   	push   %es
		pushal
f0104130:	60                   	pusha  
		movl $GD_KD, %eax
f0104131:	b8 10 00 00 00       	mov    $0x10,%eax
		movl %eax,%ds
f0104136:	8e d8                	mov    %eax,%ds
		movl %eax,%es
f0104138:	8e c0                	mov    %eax,%es
		pushl %esp
f010413a:	54                   	push   %esp
		call trap
f010413b:	e8 cf fd ff ff       	call   f0103f0f <trap>

f0104140 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104140:	55                   	push   %ebp
f0104141:	89 e5                	mov    %esp,%ebp
f0104143:	56                   	push   %esi
f0104144:	53                   	push   %ebx
f0104145:	83 ec 10             	sub    $0x10,%esp
	int envid = 0;
	int flag = 0;
	int f = 0;
	
//	cprintf("kern-sched_yield() -- \n");
	if(curenv)
f0104148:	8b 15 c4 25 1e f0    	mov    0xf01e25c4,%edx
f010414e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104153:	85 d2                	test   %edx,%edx
f0104155:	74 08                	je     f010415f <sched_yield+0x1f>
	{
		envid_t curenvid = curenv->env_id;
		envid = ENVX(curenvid);
f0104157:	8b 42 4c             	mov    0x4c(%edx),%eax
f010415a:	25 ff 03 00 00       	and    $0x3ff,%eax
	}
	for(i = envid+1; k < NENV-1; k++)
f010415f:	83 c0 01             	add    $0x1,%eax
	{
//		cprintf("status: %d -- %d\n", i, envs[i].env_status);
		if(envs[i].env_status == ENV_RUNNABLE)
f0104162:	8b 1d c0 25 1e f0    	mov    0xf01e25c0,%ebx
f0104168:	6b c8 7c             	imul   $0x7c,%eax,%ecx
f010416b:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f010416e:	83 79 54 01          	cmpl   $0x1,0x54(%ecx)
f0104172:	75 16                	jne    f010418a <sched_yield+0x4a>
f0104174:	eb 0c                	jmp    f0104182 <sched_yield+0x42>
f0104176:	6b c8 7c             	imul   $0x7c,%eax,%ecx
f0104179:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f010417c:	83 79 54 01          	cmpl   $0x1,0x54(%ecx)
f0104180:	75 12                	jne    f0104194 <sched_yield+0x54>
		{
/*			cprintf("env %d is runnable\n",i);
			cprintf("*env_pgdir: %x\n", envs[i].env_pgdir);
			cprintf("eip: %x\n",envs[i].env_tf.tf_eip);
			cprintf("esp: %x\n",envs[i].env_tf.tf_esp);*/
			env_run(&envs[i]);
f0104182:	89 0c 24             	mov    %ecx,(%esp)
f0104185:	e8 55 ef ff ff       	call   f01030df <env_run>
f010418a:	ba 00 00 00 00       	mov    $0x0,%edx
		}
		i++;
		if(i == NENV)
f010418f:	be 01 00 00 00       	mov    $0x1,%esi
			cprintf("*env_pgdir: %x\n", envs[i].env_pgdir);
			cprintf("eip: %x\n",envs[i].env_tf.tf_eip);
			cprintf("esp: %x\n",envs[i].env_tf.tf_esp);*/
			env_run(&envs[i]);
		}
		i++;
f0104194:	83 c0 01             	add    $0x1,%eax
		if(i == NENV)
f0104197:	3d 00 04 00 00       	cmp    $0x400,%eax
f010419c:	75 02                	jne    f01041a0 <sched_yield+0x60>
f010419e:	89 f0                	mov    %esi,%eax
	if(curenv)
	{
		envid_t curenvid = curenv->env_id;
		envid = ENVX(curenvid);
	}
	for(i = envid+1; k < NENV-1; k++)
f01041a0:	83 c2 01             	add    $0x1,%edx
f01041a3:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f01041a9:	75 cb                	jne    f0104176 <sched_yield+0x36>
			continue;
		}
	}
	// Run the special idle environment when nothing else is runnable.	
	//cprintf("kern-sched_yield() -- %x\n",curenv);
	if (envs[0].env_status == ENV_RUNNABLE)
f01041ab:	83 7b 54 01          	cmpl   $0x1,0x54(%ebx)
f01041af:	75 08                	jne    f01041b9 <sched_yield+0x79>
		env_run(&envs[0]);
f01041b1:	89 1c 24             	mov    %ebx,(%esp)
f01041b4:	e8 26 ef ff ff       	call   f01030df <env_run>
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
f01041b9:	c7 04 24 f0 7d 10 f0 	movl   $0xf0107df0,(%esp)
f01041c0:	e8 46 f8 ff ff       	call   f0103a0b <cprintf>
		while (1)
			monitor(NULL);
f01041c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01041cc:	e8 ef c5 ff ff       	call   f01007c0 <monitor>
f01041d1:	eb f2                	jmp    f01041c5 <sched_yield+0x85>
	...

f01041e0 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01041e0:	55                   	push   %ebp
f01041e1:	89 e5                	mov    %esp,%ebp
f01041e3:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f01041e8:	8b 40 4c             	mov    0x4c(%eax),%eax
	return curenv->env_id;
}
f01041eb:	5d                   	pop    %ebp
f01041ec:	c3                   	ret    

f01041ed <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01041ed:	55                   	push   %ebp
f01041ee:	89 e5                	mov    %esp,%ebp
f01041f0:	83 ec 38             	sub    $0x38,%esp
f01041f3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01041f6:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01041f9:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01041fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01041ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104202:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Return any appropriate return value.
	// LAB 3: Your code here.
	
	int32_t ret = 0; 
//	PRINTD("in kern-syscall no: %d a1: %x\n", syscallno, a1);
	if(syscallno >= 0 && syscallno < NSYSCALLS)
f0104205:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010420a:	83 fa 0d             	cmp    $0xd,%edx
f010420d:	0f 87 96 05 00 00    	ja     f01047a9 <syscall+0x5bc>
        {
		switch(syscallno)
f0104213:	0f 87 8b 05 00 00    	ja     f01047a4 <syscall+0x5b7>
f0104219:	ff 24 95 5c 7e 10 f0 	jmp    *-0xfef81a4(,%edx,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	
        envid_t ev = sys_getenvid();
f0104220:	e8 bb ff ff ff       	call   f01041e0 <sys_getenvid>
	user_mem_assert(&envs[ENVX(ev)], (void *)s, len, PTE_P);
f0104225:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
f010422c:	00 
f010422d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104231:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104235:	25 ff 03 00 00       	and    $0x3ff,%eax
f010423a:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010423d:	03 05 c0 25 1e f0    	add    0xf01e25c0,%eax
f0104243:	89 04 24             	mov    %eax,(%esp)
f0104246:	e8 a9 d1 ff ff       	call   f01013f4 <user_mem_assert>
			unsigned int i = inb(IO_TIMER1);
			cprintf("timer: %d\n",i); 
//		}
	}*/
//end of code for timer check
	cprintf("%.*s", len, s);
f010424b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010424f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104253:	c7 04 24 22 7e 10 f0 	movl   $0xf0107e22,(%esp)
f010425a:	e8 ac f7 ff ff       	call   f0103a0b <cprintf>
f010425f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104264:	e9 40 05 00 00       	jmp    f01047a9 <syscall+0x5bc>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104269:	e8 e1 bf ff ff       	call   f010024f <cons_getc>
				sys_cputs((char*)a1, a2);
				ret = 0;
				break;
			case SYS_cgetc:
				ret = sys_cgetc();
				break;
f010426e:	66 90                	xchg   %ax,%ax
f0104270:	e9 34 05 00 00       	jmp    f01047a9 <syscall+0x5bc>
			case SYS_getenvid:
				ret = sys_getenvid();
f0104275:	8d 76 00             	lea    0x0(%esi),%esi
f0104278:	e8 63 ff ff ff       	call   f01041e0 <sys_getenvid>
				break;
f010427d:	8d 76 00             	lea    0x0(%esi),%esi
f0104280:	e9 24 05 00 00       	jmp    f01047a9 <syscall+0x5bc>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104285:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010428c:	00 
f010428d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104290:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104294:	89 34 24             	mov    %esi,(%esp)
f0104297:	e8 a4 ed ff ff       	call   f0103040 <envid2env>
f010429c:	85 c0                	test   %eax,%eax
f010429e:	0f 88 05 05 00 00    	js     f01047a9 <syscall+0x5bc>
		return r;
	env_destroy(e);
f01042a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042a7:	89 04 24             	mov    %eax,(%esp)
f01042aa:	e8 57 f0 ff ff       	call   f0103306 <env_destroy>
f01042af:	b8 00 00 00 00       	mov    $0x0,%eax
f01042b4:	e9 f0 04 00 00       	jmp    f01047a9 <syscall+0x5bc>
				break;
			case SYS_env_destroy:
				ret = sys_env_destroy((envid_t)a1);
				break;
			case SYS_page_alloc:
				ret = sys_page_alloc(a1, (void *)a2, a3);
f01042b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	//   allocated!

	// LAB 4: Your code here.
	//cprintf("in sys_page_alloc... va %x\n", va);
	struct Env *en;
	if(envid2env(envid, &en, perm)==-E_BAD_ENV)
f01042bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01042c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01042c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042c7:	89 34 24             	mov    %esi,(%esp)
f01042ca:	e8 71 ed ff ff       	call   f0103040 <envid2env>
f01042cf:	89 c2                	mov    %eax,%edx
f01042d1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01042d6:	83 fa fe             	cmp    $0xfffffffe,%edx
f01042d9:	0f 84 ca 04 00 00    	je     f01047a9 <syscall+0x5bc>
	{
		return -E_BAD_ENV;
	}

	if(((uint32_t)va >= UTOP) || (((uint32_t)va & 0xfff) !=0) || ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) )
f01042df:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01042e5:	0f 87 d5 00 00 00    	ja     f01043c0 <syscall+0x1d3>
f01042eb:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f01042f1:	0f 85 c9 00 00 00    	jne    f01043c0 <syscall+0x1d3>
f01042f7:	89 d8                	mov    %ebx,%eax
f01042f9:	83 e0 05             	and    $0x5,%eax
f01042fc:	83 f8 05             	cmp    $0x5,%eax
f01042ff:	0f 85 bb 00 00 00    	jne    f01043c0 <syscall+0x1d3>
//		cprintf("is va aligned: %d\n",(uint32_t)va&0xfff);
		return -E_INVAL;
	}
	
	struct Page *p;
	if(page_alloc(&p) == -E_NO_MEM)
f0104305:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104308:	89 04 24             	mov    %eax,(%esp)
f010430b:	e8 8f ce ff ff       	call   f010119f <page_alloc>
f0104310:	89 c2                	mov    %eax,%edx
f0104312:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104317:	83 fa fc             	cmp    $0xfffffffc,%edx
f010431a:	0f 84 89 04 00 00    	je     f01047a9 <syscall+0x5bc>
	{
		return -E_NO_MEM;
	}
	if(page_insert(en->env_pgdir, p, va, perm) == -E_NO_MEM)
f0104320:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104324:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010432b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010432f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104332:	8b 40 5c             	mov    0x5c(%eax),%eax
f0104335:	89 04 24             	mov    %eax,(%esp)
f0104338:	e8 f1 d1 ff ff       	call   f010152e <page_insert>
f010433d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104340:	75 15                	jne    f0104357 <syscall+0x16a>
	{
		page_free(p);
f0104342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104345:	89 04 24             	mov    %eax,(%esp)
f0104348:	e8 99 cb ff ff       	call   f0100ee6 <page_free>
f010434d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104352:	e9 52 04 00 00       	jmp    f01047a9 <syscall+0x5bc>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0104357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010435a:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f0104360:	c1 f8 02             	sar    $0x2,%eax
f0104363:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104369:	c1 e0 0c             	shl    $0xc,%eax
		return -E_NO_MEM;
	}
	void *page_start_va = KADDR(page2pa(p));
f010436c:	89 c2                	mov    %eax,%edx
f010436e:	c1 ea 0c             	shr    $0xc,%edx
f0104371:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0104377:	72 20                	jb     f0104399 <syscall+0x1ac>
f0104379:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010437d:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0104384:	f0 
f0104385:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
f010438c:	00 
f010438d:	c7 04 24 27 7e 10 f0 	movl   $0xf0107e27,(%esp)
f0104394:	e8 ec bc ff ff       	call   f0100085 <_panic>
	//cprintf("start_va: %x , va: %x\n", page_start_va, va);
	memset(page_start_va, 0, PGSIZE);
f0104399:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01043a0:	00 
f01043a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01043a8:	00 
f01043a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01043ae:	89 04 24             	mov    %eax,(%esp)
f01043b1:	e8 30 10 00 00       	call   f01053e6 <memset>
f01043b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01043bb:	e9 e9 03 00 00       	jmp    f01047a9 <syscall+0x5bc>
f01043c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043c5:	e9 df 03 00 00       	jmp    f01047a9 <syscall+0x5bc>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01043ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01043d0:	e8 6b fd ff ff       	call   f0104140 <sched_yield>
			case SYS_yield:
				sys_yield();
				ret = 0;
				break;
			case SYS_page_map:
				ret = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f01043d5:	8b 5d 1c             	mov    0x1c(%ebp),%ebx

	// LAB 4: Your code here.
//	cprintf("in sys_page_map...\n");
//	cprintf("addr in map: %x src: %x\n",dstva, srcva);
	struct Env *srcenv, *dstenv;
	if(envid2env(srcenvid, &srcenv, perm)==-E_BAD_ENV || envid2env(dstenvid, &dstenv, perm)==-E_BAD_ENV)
f01043d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01043dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043e3:	89 34 24             	mov    %esi,(%esp)
f01043e6:	e8 55 ec ff ff       	call   f0103040 <envid2env>
f01043eb:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01043ee:	0f 84 b1 00 00 00    	je     f01044a5 <syscall+0x2b8>
f01043f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01043f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01043fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104402:	89 04 24             	mov    %eax,(%esp)
f0104405:	e8 36 ec ff ff       	call   f0103040 <envid2env>
f010440a:	83 f8 fe             	cmp    $0xfffffffe,%eax
f010440d:	0f 84 92 00 00 00    	je     f01044a5 <syscall+0x2b8>
		return -E_BAD_ENV;
	}

	pte_t* src_pte;
	//cprintf("1\n");
	struct Page *p = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0104413:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104416:	89 44 24 08          	mov    %eax,0x8(%esp)
f010441a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010441e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104421:	8b 40 5c             	mov    0x5c(%eax),%eax
f0104424:	89 04 24             	mov    %eax,(%esp)
f0104427:	e8 20 d0 ff ff       	call   f010144c <page_lookup>
	//cprintf("2\n");

	if( ((uint32_t)srcva >= UTOP) 
f010442c:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104432:	77 7b                	ja     f01044af <syscall+0x2c2>
f0104434:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010443a:	75 73                	jne    f01044af <syscall+0x2c2>
f010443c:	89 da                	mov    %ebx,%edx
f010443e:	83 e2 05             	and    $0x5,%edx
f0104441:	83 fa 05             	cmp    $0x5,%edx
f0104444:	75 69                	jne    f01044af <syscall+0x2c2>
f0104446:	89 da                	mov    %ebx,%edx
f0104448:	83 e2 02             	and    $0x2,%edx
f010444b:	74 08                	je     f0104455 <syscall+0x268>
f010444d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104450:	f6 01 02             	testb  $0x2,(%ecx)
f0104453:	74 5a                	je     f01044af <syscall+0x2c2>
			&& ((((uint32_t)(*src_pte))&PTE_W) !=PTE_W)))
	{
		return -E_INVAL;
	}
	
	if( ((uint32_t)dstva >= UTOP) 
f0104455:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010445c:	77 51                	ja     f01044af <syscall+0x2c2>
f010445e:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104465:	75 48                	jne    f01044af <syscall+0x2c2>
		|| ( (perm&(PTE_U|PTE_P)) != (PTE_U|PTE_P)) )
	{
		return -E_INVAL;
	}
	//cprintf("1\n");
        if ((perm & PTE_W) && !((int)(*src_pte) & PTE_W))
f0104467:	85 d2                	test   %edx,%edx
f0104469:	74 08                	je     f0104473 <syscall+0x286>
f010446b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010446e:	f6 02 02             	testb  $0x2,(%edx)
f0104471:	74 3c                	je     f01044af <syscall+0x2c2>
                return -E_INVAL;
	if(page_insert(dstenv->env_pgdir, p, dstva, perm) == -E_NO_MEM)
f0104473:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104477:	8b 55 18             	mov    0x18(%ebp),%edx
f010447a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010447e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104482:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104485:	8b 40 5c             	mov    0x5c(%eax),%eax
f0104488:	89 04 24             	mov    %eax,(%esp)
f010448b:	e8 9e d0 ff ff       	call   f010152e <page_insert>
f0104490:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104493:	0f 95 c0             	setne  %al
f0104496:	0f b6 c0             	movzbl %al,%eax
f0104499:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f01044a0:	e9 04 03 00 00       	jmp    f01047a9 <syscall+0x5bc>
f01044a5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01044aa:	e9 fa 02 00 00       	jmp    f01047a9 <syscall+0x5bc>
f01044af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01044b4:	e9 f0 02 00 00       	jmp    f01047a9 <syscall+0x5bc>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	
	struct Env *env;
	if(envid2env(envid, &env, 1)==-E_BAD_ENV)
f01044b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01044c0:	00 
f01044c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01044c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044c8:	89 34 24             	mov    %esi,(%esp)
f01044cb:	e8 70 eb ff ff       	call   f0103040 <envid2env>
f01044d0:	89 c2                	mov    %eax,%edx
f01044d2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01044d7:	83 fa fe             	cmp    $0xfffffffe,%edx
f01044da:	0f 84 c9 02 00 00    	je     f01047a9 <syscall+0x5bc>
	{
		return -E_BAD_ENV;
	}

	if((uint32_t)va >= UTOP || ((uint32_t)va & 0xfff) != 0)
f01044e0:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01044e6:	77 24                	ja     f010450c <syscall+0x31f>
f01044e8:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f01044ee:	75 1c                	jne    f010450c <syscall+0x31f>
	{
		return -E_INVAL;
	}

	page_remove(env->env_pgdir, va);	
f01044f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01044f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01044f7:	8b 40 5c             	mov    0x5c(%eax),%eax
f01044fa:	89 04 24             	mov    %eax,(%esp)
f01044fd:	e8 cd cf ff ff       	call   f01014cf <page_remove>
f0104502:	b8 00 00 00 00       	mov    $0x0,%eax
f0104507:	e9 9d 02 00 00       	jmp    f01047a9 <syscall+0x5bc>
f010450c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104511:	e9 93 02 00 00       	jmp    f01047a9 <syscall+0x5bc>
	// will appear to return 0.
	
	// LAB 4: Your code here.
	//cprintf("in sys_exofork...\n");
	struct Env *child;
	int status = env_alloc(&child, curenv->env_id);
f0104516:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f010451b:	8b 40 4c             	mov    0x4c(%eax),%eax
f010451e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104522:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104525:	89 04 24             	mov    %eax,(%esp)
f0104528:	e8 1d ef ff ff       	call   f010344a <env_alloc>
f010452d:	89 c2                	mov    %eax,%edx
	if(status == -E_NO_MEM)
f010452f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104534:	83 fa fc             	cmp    $0xfffffffc,%edx
f0104537:	0f 84 6c 02 00 00    	je     f01047a9 <syscall+0x5bc>
		return -E_NO_MEM;
	if(status == -E_NO_FREE_ENV)
f010453d:	b0 fb                	mov    $0xfb,%al
f010453f:	83 fa fb             	cmp    $0xfffffffb,%edx
f0104542:	0f 84 61 02 00 00    	je     f01047a9 <syscall+0x5bc>
		return -E_NO_FREE_ENV;

	child->env_status = ENV_NOT_RUNNABLE;
f0104548:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010454b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	child->env_tf = curenv->env_tf;
f0104552:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104555:	8b 35 c4 25 1e f0    	mov    0xf01e25c4,%esi
f010455b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104560:	89 c7                	mov    %eax,%edi
f0104562:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// exofork returns zero to child	
	child->env_tf.tf_regs.reg_eax = 0;
f0104564:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104567:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

//	curenv->env_tf.tf_regs.reg_eax = child->env_id;
	//cprintf("returning child env: %d from paret env : %d\n", child->env_id, curenv->env_id);
	return child->env_id;
f010456e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104571:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104574:	e9 30 02 00 00       	jmp    f01047a9 <syscall+0x5bc>
	// envid's status.

	// LAB 4: Your code here.
	//cprintf("in sys_set_status...\n");
	struct Env *en;
	if(envid2env(envid, &en, 1) == -E_BAD_ENV)
f0104579:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104580:	00 
f0104581:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104584:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104588:	89 34 24             	mov    %esi,(%esp)
f010458b:	e8 b0 ea ff ff       	call   f0103040 <envid2env>
f0104590:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104593:	0f 84 10 02 00 00    	je     f01047a9 <syscall+0x5bc>
	}	
	if((en->env_status == ENV_RUNNABLE) && (en->env_status == ENV_NOT_RUNNABLE))
	{
		return -E_INVAL;
	}
	en->env_status = status;
f0104599:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010459c:	89 78 54             	mov    %edi,0x54(%eax)
f010459f:	b8 00 00 00 00       	mov    $0x0,%eax
f01045a4:	e9 00 02 00 00       	jmp    f01047a9 <syscall+0x5bc>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *en;
	if(envid2env(envid, &en, 1) == -E_BAD_ENV)
f01045a9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01045b0:	00 
f01045b1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01045b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b8:	89 34 24             	mov    %esi,(%esp)
f01045bb:	e8 80 ea ff ff       	call   f0103040 <envid2env>
f01045c0:	89 c2                	mov    %eax,%edx
f01045c2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01045c7:	83 fa fe             	cmp    $0xfffffffe,%edx
f01045ca:	0f 84 d9 01 00 00    	je     f01047a9 <syscall+0x5bc>
	struct Env *env1;
	env1 = &envs[ENVX(envid)];
	//cprintf("diff %x %x\n",en, env1);
	//DIFFERENCE BETWEEN ENVX and ENVID2ENV
	//------------------------------------------------------------------
	user_mem_assert(en, func, 1, PTE_P|PTE_U);
f01045d0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01045d7:	00 
f01045d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01045df:	00 
f01045e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01045e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01045e7:	89 04 24             	mov    %eax,(%esp)
f01045ea:	e8 05 ce ff ff       	call   f01013f4 <user_mem_assert>
	en->env_pgfault_upcall =  func;
f01045ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01045f2:	89 78 64             	mov    %edi,0x64(%eax)
f01045f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01045fa:	e9 aa 01 00 00       	jmp    f01047a9 <syscall+0x5bc>
	// LAB 4: Your code here.
	//cprintf("in try to send\n");
        struct Env * env;
        struct Page * page = NULL;
        int r;
        if (envid2env(envid, &env, 0) < 0)
f01045ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104606:	00 
f0104607:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010460a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010460e:	89 34 24             	mov    %esi,(%esp)
f0104611:	e8 2a ea ff ff       	call   f0103040 <envid2env>
f0104616:	89 c2                	mov    %eax,%edx
f0104618:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010461d:	85 d2                	test   %edx,%edx
f010461f:	0f 88 84 01 00 00    	js     f01047a9 <syscall+0x5bc>
	{
                return -E_BAD_ENV;
	}
        if (env->env_ipc_recving == 0)
f0104625:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104628:	b0 f9                	mov    $0xf9,%al
f010462a:	83 7a 68 00          	cmpl   $0x0,0x68(%edx)
f010462e:	0f 84 75 01 00 00    	je     f01047a9 <syscall+0x5bc>
				break;
			case SYS_env_set_pgfault_upcall:
				ret = sys_env_set_pgfault_upcall(a1, (void *)a2);
				break;
			case SYS_ipc_try_send:
				ret = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104634:	8b 45 14             	mov    0x14(%ebp),%eax
                return -E_BAD_ENV;
	}
        if (env->env_ipc_recving == 0)
                return -E_IPC_NOT_RECV;
	
        if (srcva < (void *)UTOP) 
f0104637:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f010463c:	77 42                	ja     f0104680 <syscall+0x493>
	{
                if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_U & ~PTE_P & ~PTE_W & PTE_AVAIL) != 0)
f010463e:	8b 55 18             	mov    0x18(%ebp),%edx
f0104641:	81 e2 05 0e 00 00    	and    $0xe05,%edx
f0104647:	83 fa 05             	cmp    $0x5,%edx
f010464a:	0f 85 b5 00 00 00    	jne    f0104705 <syscall+0x518>
                        return -E_INVAL;

                if (PGOFF(srcva) != 0)
f0104650:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104655:	0f 85 aa 00 00 00    	jne    f0104705 <syscall+0x518>
                        return -E_INVAL;
                if ((page = page_lookup(curenv->env_pgdir, srcva, NULL)) == NULL)
f010465b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104662:	00 
f0104663:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104667:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f010466c:	8b 40 5c             	mov    0x5c(%eax),%eax
f010466f:	89 04 24             	mov    %eax,(%esp)
f0104672:	e8 d5 cd ff ff       	call   f010144c <page_lookup>
f0104677:	85 c0                	test   %eax,%eax
f0104679:	75 18                	jne    f0104693 <syscall+0x4a6>
f010467b:	e9 85 00 00 00       	jmp    f0104705 <syscall+0x518>
                        return -E_INVAL;
        }

        if (srcva >= (void *)UTOP)
                env->env_ipc_perm = 0;
f0104680:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)

        env->env_ipc_recving = 0;
f0104687:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010468a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
f0104691:	eb 41                	jmp    f01046d4 <syscall+0x4e7>
f0104693:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104696:	c7 42 68 00 00 00 00 	movl   $0x0,0x68(%edx)
        if (srcva < (void *)UTOP && env->env_ipc_dstva < (void *)UTOP) 
f010469d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01046a0:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01046a3:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01046a9:	77 29                	ja     f01046d4 <syscall+0x4e7>
	{
                if ((r = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) < 0)
f01046ab:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01046ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01046b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01046b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ba:	8b 42 5c             	mov    0x5c(%edx),%eax
f01046bd:	89 04 24             	mov    %eax,(%esp)
f01046c0:	e8 69 ce ff ff       	call   f010152e <page_insert>
f01046c5:	89 c2                	mov    %eax,%edx
f01046c7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01046cc:	85 d2                	test   %edx,%edx
f01046ce:	0f 88 d5 00 00 00    	js     f01047a9 <syscall+0x5bc>
                        return -E_NO_MEM;
        }

        env->env_ipc_value = value;
f01046d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046d7:	89 78 70             	mov    %edi,0x70(%eax)

        env->env_status = ENV_RUNNABLE;
f01046da:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046dd:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)

        env->env_ipc_perm = perm;
f01046e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046e7:	8b 55 18             	mov    0x18(%ebp),%edx
f01046ea:	89 50 78             	mov    %edx,0x78(%eax)

        env->env_ipc_from = curenv->env_id;
f01046ed:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f01046f2:	8b 50 4c             	mov    0x4c(%eax),%edx
f01046f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046f8:	89 50 74             	mov    %edx,0x74(%eax)
f01046fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104700:	e9 a4 00 00 00       	jmp    f01047a9 <syscall+0x5bc>
f0104705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010470a:	e9 9a 00 00 00       	jmp    f01047a9 <syscall+0x5bc>
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	curenv->env_tf.tf_regs.reg_eax = 0;
f010470f:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0104714:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	// LAB 4: Your code here.
        curenv->env_ipc_recving = 1;
f010471b:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0104720:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f0104727:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f010472c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        
	if (PGOFF(dstva) != 0)
f0104733:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104739:	75 69                	jne    f01047a4 <syscall+0x5b7>
                return -E_INVAL;
        curenv->env_ipc_dstva = dstva;
f010473b:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0104740:	89 70 6c             	mov    %esi,0x6c(%eax)
        sched_yield();
f0104743:	e8 f8 f9 ff ff       	call   f0104140 <sched_yield>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *en;
	if(envid2env(envid, &en, 1) == -E_BAD_ENV)
f0104748:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010474f:	00 
f0104750:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104753:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104757:	89 34 24             	mov    %esi,(%esp)
f010475a:	e8 e1 e8 ff ff       	call   f0103040 <envid2env>
f010475f:	89 c2                	mov    %eax,%edx
f0104761:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104766:	83 fa fe             	cmp    $0xfffffffe,%edx
f0104769:	74 3e                	je     f01047a9 <syscall+0x5bc>
				break;
			case SYS_ipc_recv:
				sys_ipc_recv((void *)a1);
				break;
			case SYS_env_set_trapframe:
				ret = sys_env_set_trapframe((envid_t)a1, (struct Trapframe*)a2);
f010476b:	89 fe                	mov    %edi,%esi
	if(envid2env(envid, &en, 1) == -E_BAD_ENV)
	{
		en = NULL;
		return -E_BAD_ENV;
	}
	if(tf!=NULL && (tf->tf_eflags=(tf->tf_eflags|FL_IF)))
f010476d:	b0 fd                	mov    $0xfd,%al
f010476f:	85 ff                	test   %edi,%edi
f0104771:	74 36                	je     f01047a9 <syscall+0x5bc>
f0104773:	81 4f 38 00 02 00 00 	orl    $0x200,0x38(%edi)
	{
		cprintf("in set trap tf %x, tf->tf_eip %x\n", tf, tf->tf_eip); 
f010477a:	8b 47 30             	mov    0x30(%edi),%eax
f010477d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104781:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104785:	c7 04 24 38 7e 10 f0 	movl   $0xf0107e38,(%esp)
f010478c:	e8 7a f2 ff ff       	call   f0103a0b <cprintf>
		en->env_tf = *tf;
f0104791:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104794:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104799:	89 c7                	mov    %eax,%edi
f010479b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010479d:	b8 00 00 00 00       	mov    $0x0,%eax
f01047a2:	eb 05                	jmp    f01047a9 <syscall+0x5bc>
f01047a4:	b8 00 00 00 00       	mov    $0x0,%eax
		ret = -E_INVAL;
	}

	return ret;	
	//panic("syscall not implemented");
}
f01047a9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01047ac:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01047af:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01047b2:	89 ec                	mov    %ebp,%esp
f01047b4:	5d                   	pop    %ebp
f01047b5:	c3                   	ret    
	...

f01047c0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01047c0:	55                   	push   %ebp
f01047c1:	89 e5                	mov    %esp,%ebp
f01047c3:	57                   	push   %edi
f01047c4:	56                   	push   %esi
f01047c5:	53                   	push   %ebx
f01047c6:	83 ec 14             	sub    $0x14,%esp
f01047c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01047cc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01047cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01047d2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01047d5:	8b 1a                	mov    (%edx),%ebx
f01047d7:	8b 01                	mov    (%ecx),%eax
f01047d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f01047dc:	39 c3                	cmp    %eax,%ebx
f01047de:	0f 8f 9c 00 00 00    	jg     f0104880 <stab_binsearch+0xc0>
f01047e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01047eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01047ee:	01 d8                	add    %ebx,%eax
f01047f0:	89 c7                	mov    %eax,%edi
f01047f2:	c1 ef 1f             	shr    $0x1f,%edi
f01047f5:	01 c7                	add    %eax,%edi
f01047f7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01047f9:	39 df                	cmp    %ebx,%edi
f01047fb:	7c 33                	jl     f0104830 <stab_binsearch+0x70>
f01047fd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104800:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104803:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104808:	39 f0                	cmp    %esi,%eax
f010480a:	0f 84 bc 00 00 00    	je     f01048cc <stab_binsearch+0x10c>
f0104810:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0104814:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0104818:	89 f8                	mov    %edi,%eax
			m--;
f010481a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010481d:	39 d8                	cmp    %ebx,%eax
f010481f:	7c 0f                	jl     f0104830 <stab_binsearch+0x70>
f0104821:	0f b6 0a             	movzbl (%edx),%ecx
f0104824:	83 ea 0c             	sub    $0xc,%edx
f0104827:	39 f1                	cmp    %esi,%ecx
f0104829:	75 ef                	jne    f010481a <stab_binsearch+0x5a>
f010482b:	e9 9e 00 00 00       	jmp    f01048ce <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104830:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104833:	eb 3c                	jmp    f0104871 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104835:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104838:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010483a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010483d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104844:	eb 2b                	jmp    f0104871 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0104846:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104849:	76 14                	jbe    f010485f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010484b:	83 e8 01             	sub    $0x1,%eax
f010484e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104851:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104854:	89 02                	mov    %eax,(%edx)
f0104856:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010485d:	eb 12                	jmp    f0104871 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010485f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104862:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0104864:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104868:	89 c3                	mov    %eax,%ebx
f010486a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0104871:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104874:	0f 8d 71 ff ff ff    	jge    f01047eb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010487a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010487e:	75 0f                	jne    f010488f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0104880:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104883:	8b 03                	mov    (%ebx),%eax
f0104885:	83 e8 01             	sub    $0x1,%eax
f0104888:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010488b:	89 02                	mov    %eax,(%edx)
f010488d:	eb 57                	jmp    f01048e6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010488f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104892:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104894:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104897:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104899:	39 c1                	cmp    %eax,%ecx
f010489b:	7d 28                	jge    f01048c5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010489d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01048a0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01048a3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01048a8:	39 f2                	cmp    %esi,%edx
f01048aa:	74 19                	je     f01048c5 <stab_binsearch+0x105>
f01048ac:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01048b0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f01048b4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048b7:	39 c1                	cmp    %eax,%ecx
f01048b9:	7d 0a                	jge    f01048c5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01048bb:	0f b6 1a             	movzbl (%edx),%ebx
f01048be:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048c1:	39 f3                	cmp    %esi,%ebx
f01048c3:	75 ef                	jne    f01048b4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01048c5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01048c8:	89 02                	mov    %eax,(%edx)
f01048ca:	eb 1a                	jmp    f01048e6 <stab_binsearch+0x126>
	}
}
f01048cc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01048ce:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01048d1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01048d4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01048d8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01048db:	0f 82 54 ff ff ff    	jb     f0104835 <stab_binsearch+0x75>
f01048e1:	e9 60 ff ff ff       	jmp    f0104846 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01048e6:	83 c4 14             	add    $0x14,%esp
f01048e9:	5b                   	pop    %ebx
f01048ea:	5e                   	pop    %esi
f01048eb:	5f                   	pop    %edi
f01048ec:	5d                   	pop    %ebp
f01048ed:	c3                   	ret    

f01048ee <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01048ee:	55                   	push   %ebp
f01048ef:	89 e5                	mov    %esp,%ebp
f01048f1:	83 ec 58             	sub    $0x58,%esp
f01048f4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01048f7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01048fa:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01048fd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104900:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104903:	c7 03 94 7e 10 f0    	movl   $0xf0107e94,(%ebx)
	info->eip_line = 0;
f0104909:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104910:	c7 43 08 94 7e 10 f0 	movl   $0xf0107e94,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104917:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010491e:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104921:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104928:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010492e:	76 1a                	jbe    f010494a <debuginfo_eip+0x5c>
f0104930:	be 24 61 11 f0       	mov    $0xf0116124,%esi
f0104935:	c7 45 c4 91 27 11 f0 	movl   $0xf0112791,-0x3c(%ebp)
f010493c:	b8 90 27 11 f0       	mov    $0xf0112790,%eax
f0104941:	c7 45 c0 08 86 10 f0 	movl   $0xf0108608,-0x40(%ebp)
f0104948:	eb 16                	jmp    f0104960 <debuginfo_eip+0x72>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010494a:	ba 00 00 20 00       	mov    $0x200000,%edx
f010494f:	8b 02                	mov    (%edx),%eax
f0104951:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104954:	8b 42 04             	mov    0x4(%edx),%eax
		stabstr = usd->stabstr;
f0104957:	8b 4a 08             	mov    0x8(%edx),%ecx
f010495a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f010495d:	8b 72 0c             	mov    0xc(%edx),%esi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104960:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0104963:	0f 83 a1 01 00 00    	jae    f0104b0a <debuginfo_eip+0x21c>
f0104969:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010496d:	0f 85 97 01 00 00    	jne    f0104b0a <debuginfo_eip+0x21c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104973:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010497a:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010497d:	c1 f8 02             	sar    $0x2,%eax
f0104980:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104986:	83 e8 01             	sub    $0x1,%eax
f0104989:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010498c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010498f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104992:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104996:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010499d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01049a0:	e8 1b fe ff ff       	call   f01047c0 <stab_binsearch>
	if (lfile == 0)
f01049a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a8:	85 c0                	test   %eax,%eax
f01049aa:	0f 84 5a 01 00 00    	je     f0104b0a <debuginfo_eip+0x21c>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01049b9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01049bc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01049bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01049c3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01049ca:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01049cd:	e8 ee fd ff ff       	call   f01047c0 <stab_binsearch>

	if (lfun <= rfun) {
f01049d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01049d5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01049d8:	7f 35                	jg     f0104a0f <debuginfo_eip+0x121>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049da:	6b c0 0c             	imul   $0xc,%eax,%eax
f01049dd:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01049e0:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01049e3:	89 f2                	mov    %esi,%edx
f01049e5:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01049e8:	39 d0                	cmp    %edx,%eax
f01049ea:	73 06                	jae    f01049f2 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01049ec:	03 45 c4             	add    -0x3c(%ebp),%eax
f01049ef:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01049f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01049f5:	6b c2 0c             	imul   $0xc,%edx,%eax
f01049f8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01049fb:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f01049ff:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104a02:	29 c7                	sub    %eax,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104a04:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104a07:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104a0a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104a0d:	eb 0f                	jmp    f0104a1e <debuginfo_eip+0x130>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104a0f:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104a12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104a18:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a1e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104a25:	00 
f0104a26:	8b 43 08             	mov    0x8(%ebx),%eax
f0104a29:	89 04 24             	mov    %eax,(%esp)
f0104a2c:	e8 8a 09 00 00       	call   f01053bb <strfind>
f0104a31:	2b 43 08             	sub    0x8(%ebx),%eax
f0104a34:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104a37:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104a3a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104a3d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a41:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0104a48:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104a4b:	e8 70 fd ff ff       	call   f01047c0 <stab_binsearch>
	if(lline <= rline) {
f0104a50:	8b 55 d0             	mov    -0x30(%ebp),%edx
		info->eip_line = rline;
f0104a53:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0104a56:	0f 9e c0             	setle  %al
f0104a59:	0f b6 c0             	movzbl %al,%eax
f0104a5c:	83 e8 01             	sub    $0x1,%eax
f0104a5f:	09 d0                	or     %edx,%eax
f0104a61:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0104a64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104a67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a6a:	89 55 bc             	mov    %edx,-0x44(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a6d:	39 d0                	cmp    %edx,%eax
f0104a6f:	7c 58                	jl     f0104ac9 <debuginfo_eip+0x1db>
	       && stabs[lline].n_type != N_SOL
f0104a71:	6b f8 0c             	imul   $0xc,%eax,%edi
f0104a74:	03 7d c0             	add    -0x40(%ebp),%edi
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a77:	0f b6 4f 04          	movzbl 0x4(%edi),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a7b:	80 f9 84             	cmp    $0x84,%cl
f0104a7e:	74 34                	je     f0104ab4 <debuginfo_eip+0x1c6>
f0104a80:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104a83:	6b d2 0c             	imul   $0xc,%edx,%edx
f0104a86:	03 55 c0             	add    -0x40(%ebp),%edx
f0104a89:	eb 19                	jmp    f0104aa4 <debuginfo_eip+0x1b6>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a8b:	83 e8 01             	sub    $0x1,%eax
f0104a8e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a91:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0104a94:	7f 33                	jg     f0104ac9 <debuginfo_eip+0x1db>
f0104a96:	89 d7                	mov    %edx,%edi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a98:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a9c:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a9f:	80 f9 84             	cmp    $0x84,%cl
f0104aa2:	74 10                	je     f0104ab4 <debuginfo_eip+0x1c6>
f0104aa4:	80 f9 64             	cmp    $0x64,%cl
f0104aa7:	75 e2                	jne    f0104a8b <debuginfo_eip+0x19d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104aa9:	83 7f 08 00          	cmpl   $0x0,0x8(%edi)
f0104aad:	74 dc                	je     f0104a8b <debuginfo_eip+0x19d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104aaf:	3b 45 bc             	cmp    -0x44(%ebp),%eax
f0104ab2:	7c 15                	jl     f0104ac9 <debuginfo_eip+0x1db>
f0104ab4:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104ab7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104aba:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0104abd:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0104ac0:	39 f0                	cmp    %esi,%eax
f0104ac2:	73 05                	jae    f0104ac9 <debuginfo_eip+0x1db>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ac4:	03 45 c4             	add    -0x3c(%ebp),%eax
f0104ac7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ac9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104acc:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104acf:	7d 41                	jge    f0104b12 <debuginfo_eip+0x224>
		for (lline = lfun + 1;
f0104ad1:	83 c0 01             	add    $0x1,%eax
f0104ad4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ad7:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0104ada:	7e 36                	jle    f0104b12 <debuginfo_eip+0x224>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104adc:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104adf:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104ae2:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f0104ae7:	75 29                	jne    f0104b12 <debuginfo_eip+0x224>
		     lline++)
			info->eip_fn_narg++;
f0104ae9:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104aed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104af0:	83 c0 01             	add    $0x1,%eax
f0104af3:	89 45 d4             	mov    %eax,-0x2c(%ebp)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104af6:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0104af9:	7e 17                	jle    f0104b12 <debuginfo_eip+0x224>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104afb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104afe:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104b01:	80 7c 81 04 a0       	cmpb   $0xa0,0x4(%ecx,%eax,4)
f0104b06:	74 e1                	je     f0104ae9 <debuginfo_eip+0x1fb>
f0104b08:	eb 08                	jmp    f0104b12 <debuginfo_eip+0x224>
f0104b0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b0f:	90                   	nop
f0104b10:	eb 05                	jmp    f0104b17 <debuginfo_eip+0x229>
f0104b12:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0104b17:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104b1a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104b1d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104b20:	89 ec                	mov    %ebp,%esp
f0104b22:	5d                   	pop    %ebp
f0104b23:	c3                   	ret    
	...

f0104b30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104b30:	55                   	push   %ebp
f0104b31:	89 e5                	mov    %esp,%ebp
f0104b33:	57                   	push   %edi
f0104b34:	56                   	push   %esi
f0104b35:	53                   	push   %ebx
f0104b36:	83 ec 4c             	sub    $0x4c,%esp
f0104b39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104b3c:	89 d6                	mov    %edx,%esi
f0104b3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b41:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b44:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b47:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104b4a:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b4d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104b50:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104b53:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104b56:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b5b:	39 d1                	cmp    %edx,%ecx
f0104b5d:	72 15                	jb     f0104b74 <printnum+0x44>
f0104b5f:	77 07                	ja     f0104b68 <printnum+0x38>
f0104b61:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b64:	39 d0                	cmp    %edx,%eax
f0104b66:	76 0c                	jbe    f0104b74 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b68:	83 eb 01             	sub    $0x1,%ebx
f0104b6b:	85 db                	test   %ebx,%ebx
f0104b6d:	8d 76 00             	lea    0x0(%esi),%esi
f0104b70:	7f 61                	jg     f0104bd3 <printnum+0xa3>
f0104b72:	eb 70                	jmp    f0104be4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104b74:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0104b78:	83 eb 01             	sub    $0x1,%ebx
f0104b7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104b7f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b83:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104b87:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0104b8b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104b8e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104b91:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b94:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104b98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104b9f:	00 
f0104ba0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104ba3:	89 04 24             	mov    %eax,(%esp)
f0104ba6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ba9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104bad:	e8 8e 19 00 00       	call   f0106540 <__udivdi3>
f0104bb2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104bb5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104bb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104bbc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104bc0:	89 04 24             	mov    %eax,(%esp)
f0104bc3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104bc7:	89 f2                	mov    %esi,%edx
f0104bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bcc:	e8 5f ff ff ff       	call   f0104b30 <printnum>
f0104bd1:	eb 11                	jmp    f0104be4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104bd3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104bd7:	89 3c 24             	mov    %edi,(%esp)
f0104bda:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104bdd:	83 eb 01             	sub    $0x1,%ebx
f0104be0:	85 db                	test   %ebx,%ebx
f0104be2:	7f ef                	jg     f0104bd3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104be4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104be8:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104bec:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104bef:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104bf3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104bfa:	00 
f0104bfb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104bfe:	89 14 24             	mov    %edx,(%esp)
f0104c01:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c04:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c08:	e8 63 1a 00 00       	call   f0106670 <__umoddi3>
f0104c0d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104c11:	0f be 80 9e 7e 10 f0 	movsbl -0xfef8162(%eax),%eax
f0104c18:	89 04 24             	mov    %eax,(%esp)
f0104c1b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104c1e:	83 c4 4c             	add    $0x4c,%esp
f0104c21:	5b                   	pop    %ebx
f0104c22:	5e                   	pop    %esi
f0104c23:	5f                   	pop    %edi
f0104c24:	5d                   	pop    %ebp
f0104c25:	c3                   	ret    

f0104c26 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104c26:	55                   	push   %ebp
f0104c27:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104c29:	83 fa 01             	cmp    $0x1,%edx
f0104c2c:	7e 0e                	jle    f0104c3c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104c2e:	8b 10                	mov    (%eax),%edx
f0104c30:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104c33:	89 08                	mov    %ecx,(%eax)
f0104c35:	8b 02                	mov    (%edx),%eax
f0104c37:	8b 52 04             	mov    0x4(%edx),%edx
f0104c3a:	eb 22                	jmp    f0104c5e <getuint+0x38>
	else if (lflag)
f0104c3c:	85 d2                	test   %edx,%edx
f0104c3e:	74 10                	je     f0104c50 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104c40:	8b 10                	mov    (%eax),%edx
f0104c42:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104c45:	89 08                	mov    %ecx,(%eax)
f0104c47:	8b 02                	mov    (%edx),%eax
f0104c49:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c4e:	eb 0e                	jmp    f0104c5e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104c50:	8b 10                	mov    (%eax),%edx
f0104c52:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104c55:	89 08                	mov    %ecx,(%eax)
f0104c57:	8b 02                	mov    (%edx),%eax
f0104c59:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104c5e:	5d                   	pop    %ebp
f0104c5f:	c3                   	ret    

f0104c60 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104c60:	55                   	push   %ebp
f0104c61:	89 e5                	mov    %esp,%ebp
f0104c63:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104c66:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104c6a:	8b 10                	mov    (%eax),%edx
f0104c6c:	3b 50 04             	cmp    0x4(%eax),%edx
f0104c6f:	73 0a                	jae    f0104c7b <sprintputch+0x1b>
		*b->buf++ = ch;
f0104c71:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c74:	88 0a                	mov    %cl,(%edx)
f0104c76:	83 c2 01             	add    $0x1,%edx
f0104c79:	89 10                	mov    %edx,(%eax)
}
f0104c7b:	5d                   	pop    %ebp
f0104c7c:	c3                   	ret    

f0104c7d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104c7d:	55                   	push   %ebp
f0104c7e:	89 e5                	mov    %esp,%ebp
f0104c80:	57                   	push   %edi
f0104c81:	56                   	push   %esi
f0104c82:	53                   	push   %ebx
f0104c83:	83 ec 5c             	sub    $0x5c,%esp
f0104c86:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c89:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104c8f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104c96:	eb 11                	jmp    f0104ca9 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104c98:	85 c0                	test   %eax,%eax
f0104c9a:	0f 84 02 04 00 00    	je     f01050a2 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
f0104ca0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ca4:	89 04 24             	mov    %eax,(%esp)
f0104ca7:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ca9:	0f b6 03             	movzbl (%ebx),%eax
f0104cac:	83 c3 01             	add    $0x1,%ebx
f0104caf:	83 f8 25             	cmp    $0x25,%eax
f0104cb2:	75 e4                	jne    f0104c98 <vprintfmt+0x1b>
f0104cb4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104cb8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104cbf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104cc6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cd2:	eb 06                	jmp    f0104cda <vprintfmt+0x5d>
f0104cd4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104cd8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cda:	0f b6 13             	movzbl (%ebx),%edx
f0104cdd:	0f b6 c2             	movzbl %dl,%eax
f0104ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104ce3:	8d 43 01             	lea    0x1(%ebx),%eax
f0104ce6:	83 ea 23             	sub    $0x23,%edx
f0104ce9:	80 fa 55             	cmp    $0x55,%dl
f0104cec:	0f 87 93 03 00 00    	ja     f0105085 <vprintfmt+0x408>
f0104cf2:	0f b6 d2             	movzbl %dl,%edx
f0104cf5:	ff 24 95 e0 7f 10 f0 	jmp    *-0xfef8020(,%edx,4)
f0104cfc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104d00:	eb d6                	jmp    f0104cd8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104d02:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d05:	83 ea 30             	sub    $0x30,%edx
f0104d08:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f0104d0b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104d0e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104d11:	83 fb 09             	cmp    $0x9,%ebx
f0104d14:	77 4c                	ja     f0104d62 <vprintfmt+0xe5>
f0104d16:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104d19:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104d1c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0104d1f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104d22:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0104d26:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104d29:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104d2c:	83 fb 09             	cmp    $0x9,%ebx
f0104d2f:	76 eb                	jbe    f0104d1c <vprintfmt+0x9f>
f0104d31:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104d34:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d37:	eb 29                	jmp    f0104d62 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104d39:	8b 55 14             	mov    0x14(%ebp),%edx
f0104d3c:	8d 5a 04             	lea    0x4(%edx),%ebx
f0104d3f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104d42:	8b 12                	mov    (%edx),%edx
f0104d44:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f0104d47:	eb 19                	jmp    f0104d62 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
f0104d49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d4c:	c1 fa 1f             	sar    $0x1f,%edx
f0104d4f:	f7 d2                	not    %edx
f0104d51:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0104d54:	eb 82                	jmp    f0104cd8 <vprintfmt+0x5b>
f0104d56:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0104d5d:	e9 76 ff ff ff       	jmp    f0104cd8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0104d62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d66:	0f 89 6c ff ff ff    	jns    f0104cd8 <vprintfmt+0x5b>
f0104d6c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104d6f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104d72:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104d75:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104d78:	e9 5b ff ff ff       	jmp    f0104cd8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104d7d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0104d80:	e9 53 ff ff ff       	jmp    f0104cd8 <vprintfmt+0x5b>
f0104d85:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104d88:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d8b:	8d 50 04             	lea    0x4(%eax),%edx
f0104d8e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d91:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d95:	8b 00                	mov    (%eax),%eax
f0104d97:	89 04 24             	mov    %eax,(%esp)
f0104d9a:	ff d7                	call   *%edi
f0104d9c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0104d9f:	e9 05 ff ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
f0104da4:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104da7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104daa:	8d 50 04             	lea    0x4(%eax),%edx
f0104dad:	89 55 14             	mov    %edx,0x14(%ebp)
f0104db0:	8b 00                	mov    (%eax),%eax
f0104db2:	89 c2                	mov    %eax,%edx
f0104db4:	c1 fa 1f             	sar    $0x1f,%edx
f0104db7:	31 d0                	xor    %edx,%eax
f0104db9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0104dbb:	83 f8 0f             	cmp    $0xf,%eax
f0104dbe:	7f 0b                	jg     f0104dcb <vprintfmt+0x14e>
f0104dc0:	8b 14 85 40 81 10 f0 	mov    -0xfef7ec0(,%eax,4),%edx
f0104dc7:	85 d2                	test   %edx,%edx
f0104dc9:	75 20                	jne    f0104deb <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
f0104dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104dcf:	c7 44 24 08 af 7e 10 	movl   $0xf0107eaf,0x8(%esp)
f0104dd6:	f0 
f0104dd7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ddb:	89 3c 24             	mov    %edi,(%esp)
f0104dde:	e8 47 03 00 00       	call   f010512a <printfmt>
f0104de3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0104de6:	e9 be fe ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104deb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104def:	c7 44 24 08 86 76 10 	movl   $0xf0107686,0x8(%esp)
f0104df6:	f0 
f0104df7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104dfb:	89 3c 24             	mov    %edi,(%esp)
f0104dfe:	e8 27 03 00 00       	call   f010512a <printfmt>
f0104e03:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104e06:	e9 9e fe ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
f0104e0b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104e0e:	89 c3                	mov    %eax,%ebx
f0104e10:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e16:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104e19:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1c:	8d 50 04             	lea    0x4(%eax),%edx
f0104e1f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e22:	8b 00                	mov    (%eax),%eax
f0104e24:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104e27:	85 c0                	test   %eax,%eax
f0104e29:	75 07                	jne    f0104e32 <vprintfmt+0x1b5>
f0104e2b:	c7 45 e0 b8 7e 10 f0 	movl   $0xf0107eb8,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0104e32:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0104e36:	7e 06                	jle    f0104e3e <vprintfmt+0x1c1>
f0104e38:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104e3c:	75 13                	jne    f0104e51 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104e3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104e41:	0f be 02             	movsbl (%edx),%eax
f0104e44:	85 c0                	test   %eax,%eax
f0104e46:	0f 85 99 00 00 00    	jne    f0104ee5 <vprintfmt+0x268>
f0104e4c:	e9 86 00 00 00       	jmp    f0104ed7 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e51:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104e55:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104e58:	89 0c 24             	mov    %ecx,(%esp)
f0104e5b:	e8 fb 03 00 00       	call   f010525b <strnlen>
f0104e60:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e63:	29 c2                	sub    %eax,%edx
f0104e65:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104e68:	85 d2                	test   %edx,%edx
f0104e6a:	7e d2                	jle    f0104e3e <vprintfmt+0x1c1>
					putch(padc, putdat);
f0104e6c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0104e70:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104e73:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104e76:	89 d3                	mov    %edx,%ebx
f0104e78:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e7c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e7f:	89 04 24             	mov    %eax,(%esp)
f0104e82:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e84:	83 eb 01             	sub    $0x1,%ebx
f0104e87:	85 db                	test   %ebx,%ebx
f0104e89:	7f ed                	jg     f0104e78 <vprintfmt+0x1fb>
f0104e8b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104e8e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104e95:	eb a7                	jmp    f0104e3e <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104e97:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104e9b:	74 18                	je     f0104eb5 <vprintfmt+0x238>
f0104e9d:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104ea0:	83 fa 5e             	cmp    $0x5e,%edx
f0104ea3:	76 10                	jbe    f0104eb5 <vprintfmt+0x238>
					putch('?', putdat);
f0104ea5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ea9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104eb0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104eb3:	eb 0a                	jmp    f0104ebf <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0104eb5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104eb9:	89 04 24             	mov    %eax,(%esp)
f0104ebc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ebf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0104ec3:	0f be 03             	movsbl (%ebx),%eax
f0104ec6:	85 c0                	test   %eax,%eax
f0104ec8:	74 05                	je     f0104ecf <vprintfmt+0x252>
f0104eca:	83 c3 01             	add    $0x1,%ebx
f0104ecd:	eb 29                	jmp    f0104ef8 <vprintfmt+0x27b>
f0104ecf:	89 fe                	mov    %edi,%esi
f0104ed1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104ed4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104ed7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104edb:	7f 2e                	jg     f0104f0b <vprintfmt+0x28e>
f0104edd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104ee0:	e9 c4 fd ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ee5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ee8:	83 c2 01             	add    $0x1,%edx
f0104eeb:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0104eee:	89 f7                	mov    %esi,%edi
f0104ef0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104ef3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104ef6:	89 d3                	mov    %edx,%ebx
f0104ef8:	85 f6                	test   %esi,%esi
f0104efa:	78 9b                	js     f0104e97 <vprintfmt+0x21a>
f0104efc:	83 ee 01             	sub    $0x1,%esi
f0104eff:	79 96                	jns    f0104e97 <vprintfmt+0x21a>
f0104f01:	89 fe                	mov    %edi,%esi
f0104f03:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104f06:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104f09:	eb cc                	jmp    f0104ed7 <vprintfmt+0x25a>
f0104f0b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104f0e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104f11:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f15:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104f1c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104f1e:	83 eb 01             	sub    $0x1,%ebx
f0104f21:	85 db                	test   %ebx,%ebx
f0104f23:	7f ec                	jg     f0104f11 <vprintfmt+0x294>
f0104f25:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0104f28:	e9 7c fd ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
f0104f2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104f30:	83 f9 01             	cmp    $0x1,%ecx
f0104f33:	7e 16                	jle    f0104f4b <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
f0104f35:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f38:	8d 50 08             	lea    0x8(%eax),%edx
f0104f3b:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f3e:	8b 10                	mov    (%eax),%edx
f0104f40:	8b 48 04             	mov    0x4(%eax),%ecx
f0104f43:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0104f46:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f49:	eb 32                	jmp    f0104f7d <vprintfmt+0x300>
	else if (lflag)
f0104f4b:	85 c9                	test   %ecx,%ecx
f0104f4d:	74 18                	je     f0104f67 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
f0104f4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f52:	8d 50 04             	lea    0x4(%eax),%edx
f0104f55:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f58:	8b 00                	mov    (%eax),%eax
f0104f5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f5d:	89 c1                	mov    %eax,%ecx
f0104f5f:	c1 f9 1f             	sar    $0x1f,%ecx
f0104f62:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f65:	eb 16                	jmp    f0104f7d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
f0104f67:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f6a:	8d 50 04             	lea    0x4(%eax),%edx
f0104f6d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f70:	8b 00                	mov    (%eax),%eax
f0104f72:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f75:	89 c2                	mov    %eax,%edx
f0104f77:	c1 fa 1f             	sar    $0x1f,%edx
f0104f7a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104f7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104f80:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f83:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f0104f88:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104f8c:	0f 89 b1 00 00 00    	jns    f0105043 <vprintfmt+0x3c6>
				putch('-', putdat);
f0104f92:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f96:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104f9d:	ff d7                	call   *%edi
				num = -(long long) num;
f0104f9f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104fa2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fa5:	f7 d8                	neg    %eax
f0104fa7:	83 d2 00             	adc    $0x0,%edx
f0104faa:	f7 da                	neg    %edx
f0104fac:	e9 92 00 00 00       	jmp    f0105043 <vprintfmt+0x3c6>
f0104fb1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104fb4:	89 ca                	mov    %ecx,%edx
f0104fb6:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fb9:	e8 68 fc ff ff       	call   f0104c26 <getuint>
f0104fbe:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
f0104fc3:	eb 7e                	jmp    f0105043 <vprintfmt+0x3c6>
f0104fc5:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0104fc8:	89 ca                	mov    %ecx,%edx
f0104fca:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fcd:	e8 54 fc ff ff       	call   f0104c26 <getuint>
			if ((long long) num < 0) {
f0104fd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fd5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104fd8:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104fdd:	85 d2                	test   %edx,%edx
f0104fdf:	79 62                	jns    f0105043 <vprintfmt+0x3c6>
				putch('-', putdat);
f0104fe1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fe5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104fec:	ff d7                	call   *%edi
				num = -(long long) num;
f0104fee:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104ff1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104ff4:	f7 d8                	neg    %eax
f0104ff6:	83 d2 00             	adc    $0x0,%edx
f0104ff9:	f7 da                	neg    %edx
f0104ffb:	eb 46                	jmp    f0105043 <vprintfmt+0x3c6>
f0104ffd:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0105000:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105004:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010500b:	ff d7                	call   *%edi
			putch('x', putdat);
f010500d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105011:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105018:	ff d7                	call   *%edi
			num = (unsigned long long)
f010501a:	8b 45 14             	mov    0x14(%ebp),%eax
f010501d:	8d 50 04             	lea    0x4(%eax),%edx
f0105020:	89 55 14             	mov    %edx,0x14(%ebp)
f0105023:	8b 00                	mov    (%eax),%eax
f0105025:	ba 00 00 00 00       	mov    $0x0,%edx
f010502a:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010502f:	eb 12                	jmp    f0105043 <vprintfmt+0x3c6>
f0105031:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105034:	89 ca                	mov    %ecx,%edx
f0105036:	8d 45 14             	lea    0x14(%ebp),%eax
f0105039:	e8 e8 fb ff ff       	call   f0104c26 <getuint>
f010503e:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105043:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0105047:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010504b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010504e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105052:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105056:	89 04 24             	mov    %eax,(%esp)
f0105059:	89 54 24 04          	mov    %edx,0x4(%esp)
f010505d:	89 f2                	mov    %esi,%edx
f010505f:	89 f8                	mov    %edi,%eax
f0105061:	e8 ca fa ff ff       	call   f0104b30 <printnum>
f0105066:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0105069:	e9 3b fc ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
f010506e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105071:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105074:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105078:	89 14 24             	mov    %edx,(%esp)
f010507b:	ff d7                	call   *%edi
f010507d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0105080:	e9 24 fc ff ff       	jmp    f0104ca9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105085:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105089:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105090:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105092:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105095:	80 38 25             	cmpb   $0x25,(%eax)
f0105098:	0f 84 0b fc ff ff    	je     f0104ca9 <vprintfmt+0x2c>
f010509e:	89 c3                	mov    %eax,%ebx
f01050a0:	eb f0                	jmp    f0105092 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
f01050a2:	83 c4 5c             	add    $0x5c,%esp
f01050a5:	5b                   	pop    %ebx
f01050a6:	5e                   	pop    %esi
f01050a7:	5f                   	pop    %edi
f01050a8:	5d                   	pop    %ebp
f01050a9:	c3                   	ret    

f01050aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01050aa:	55                   	push   %ebp
f01050ab:	89 e5                	mov    %esp,%ebp
f01050ad:	83 ec 28             	sub    $0x28,%esp
f01050b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01050b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01050b6:	85 c0                	test   %eax,%eax
f01050b8:	74 04                	je     f01050be <vsnprintf+0x14>
f01050ba:	85 d2                	test   %edx,%edx
f01050bc:	7f 07                	jg     f01050c5 <vsnprintf+0x1b>
f01050be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050c3:	eb 3b                	jmp    f0105100 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01050c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050c8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01050cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01050cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01050d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01050dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01050e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01050e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050eb:	c7 04 24 60 4c 10 f0 	movl   $0xf0104c60,(%esp)
f01050f2:	e8 86 fb ff ff       	call   f0104c7d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01050f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01050fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01050fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0105100:	c9                   	leave  
f0105101:	c3                   	ret    

f0105102 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105102:	55                   	push   %ebp
f0105103:	89 e5                	mov    %esp,%ebp
f0105105:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0105108:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f010510b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010510f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105112:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105116:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010511d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105120:	89 04 24             	mov    %eax,(%esp)
f0105123:	e8 82 ff ff ff       	call   f01050aa <vsnprintf>
	va_end(ap);

	return rc;
}
f0105128:	c9                   	leave  
f0105129:	c3                   	ret    

f010512a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010512a:	55                   	push   %ebp
f010512b:	89 e5                	mov    %esp,%ebp
f010512d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0105130:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0105133:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105137:	8b 45 10             	mov    0x10(%ebp),%eax
f010513a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010513e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105141:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105145:	8b 45 08             	mov    0x8(%ebp),%eax
f0105148:	89 04 24             	mov    %eax,(%esp)
f010514b:	e8 2d fb ff ff       	call   f0104c7d <vprintfmt>
	va_end(ap);
}
f0105150:	c9                   	leave  
f0105151:	c3                   	ret    
	...

f0105160 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105160:	55                   	push   %ebp
f0105161:	89 e5                	mov    %esp,%ebp
f0105163:	57                   	push   %edi
f0105164:	56                   	push   %esi
f0105165:	53                   	push   %ebx
f0105166:	83 ec 1c             	sub    $0x1c,%esp
f0105169:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010516c:	85 c0                	test   %eax,%eax
f010516e:	74 10                	je     f0105180 <readline+0x20>
		cprintf("%s", prompt);
f0105170:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105174:	c7 04 24 86 76 10 f0 	movl   $0xf0107686,(%esp)
f010517b:	e8 8b e8 ff ff       	call   f0103a0b <cprintf>

	i = 0;
	echoing = iscons(0);
f0105180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105187:	e8 1a b1 ff ff       	call   f01002a6 <iscons>
f010518c:	89 c7                	mov    %eax,%edi
f010518e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105193:	e8 fd b0 ff ff       	call   f0100295 <getchar>
f0105198:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010519a:	85 c0                	test   %eax,%eax
f010519c:	79 17                	jns    f01051b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010519e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051a2:	c7 04 24 9f 81 10 f0 	movl   $0xf010819f,(%esp)
f01051a9:	e8 5d e8 ff ff       	call   f0103a0b <cprintf>
f01051ae:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01051b3:	eb 76                	jmp    f010522b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01051b5:	83 f8 08             	cmp    $0x8,%eax
f01051b8:	74 08                	je     f01051c2 <readline+0x62>
f01051ba:	83 f8 7f             	cmp    $0x7f,%eax
f01051bd:	8d 76 00             	lea    0x0(%esi),%esi
f01051c0:	75 19                	jne    f01051db <readline+0x7b>
f01051c2:	85 f6                	test   %esi,%esi
f01051c4:	7e 15                	jle    f01051db <readline+0x7b>
			if (echoing)
f01051c6:	85 ff                	test   %edi,%edi
f01051c8:	74 0c                	je     f01051d6 <readline+0x76>
				cputchar('\b');
f01051ca:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01051d1:	e8 d4 b2 ff ff       	call   f01004aa <cputchar>
			i--;
f01051d6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01051d9:	eb b8                	jmp    f0105193 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f01051db:	83 fb 1f             	cmp    $0x1f,%ebx
f01051de:	66 90                	xchg   %ax,%ax
f01051e0:	7e 23                	jle    f0105205 <readline+0xa5>
f01051e2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01051e8:	7f 1b                	jg     f0105205 <readline+0xa5>
			if (echoing)
f01051ea:	85 ff                	test   %edi,%edi
f01051ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01051f0:	74 08                	je     f01051fa <readline+0x9a>
				cputchar(c);
f01051f2:	89 1c 24             	mov    %ebx,(%esp)
f01051f5:	e8 b0 b2 ff ff       	call   f01004aa <cputchar>
			buf[i++] = c;
f01051fa:	88 9e 60 2e 1e f0    	mov    %bl,-0xfe1d1a0(%esi)
f0105200:	83 c6 01             	add    $0x1,%esi
f0105203:	eb 8e                	jmp    f0105193 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105205:	83 fb 0a             	cmp    $0xa,%ebx
f0105208:	74 05                	je     f010520f <readline+0xaf>
f010520a:	83 fb 0d             	cmp    $0xd,%ebx
f010520d:	75 84                	jne    f0105193 <readline+0x33>
			if (echoing)
f010520f:	85 ff                	test   %edi,%edi
f0105211:	74 0c                	je     f010521f <readline+0xbf>
				cputchar('\n');
f0105213:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010521a:	e8 8b b2 ff ff       	call   f01004aa <cputchar>
			buf[i] = 0;
f010521f:	c6 86 60 2e 1e f0 00 	movb   $0x0,-0xfe1d1a0(%esi)
f0105226:	b8 60 2e 1e f0       	mov    $0xf01e2e60,%eax
			return buf;
		}
	}
}
f010522b:	83 c4 1c             	add    $0x1c,%esp
f010522e:	5b                   	pop    %ebx
f010522f:	5e                   	pop    %esi
f0105230:	5f                   	pop    %edi
f0105231:	5d                   	pop    %ebp
f0105232:	c3                   	ret    
	...

f0105240 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105240:	55                   	push   %ebp
f0105241:	89 e5                	mov    %esp,%ebp
f0105243:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105246:	b8 00 00 00 00       	mov    $0x0,%eax
f010524b:	80 3a 00             	cmpb   $0x0,(%edx)
f010524e:	74 09                	je     f0105259 <strlen+0x19>
		n++;
f0105250:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105253:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105257:	75 f7                	jne    f0105250 <strlen+0x10>
		n++;
	return n;
}
f0105259:	5d                   	pop    %ebp
f010525a:	c3                   	ret    

f010525b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010525b:	55                   	push   %ebp
f010525c:	89 e5                	mov    %esp,%ebp
f010525e:	53                   	push   %ebx
f010525f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105265:	85 c9                	test   %ecx,%ecx
f0105267:	74 19                	je     f0105282 <strnlen+0x27>
f0105269:	80 3b 00             	cmpb   $0x0,(%ebx)
f010526c:	74 14                	je     f0105282 <strnlen+0x27>
f010526e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105273:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105276:	39 c8                	cmp    %ecx,%eax
f0105278:	74 0d                	je     f0105287 <strnlen+0x2c>
f010527a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010527e:	75 f3                	jne    f0105273 <strnlen+0x18>
f0105280:	eb 05                	jmp    f0105287 <strnlen+0x2c>
f0105282:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105287:	5b                   	pop    %ebx
f0105288:	5d                   	pop    %ebp
f0105289:	c3                   	ret    

f010528a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010528a:	55                   	push   %ebp
f010528b:	89 e5                	mov    %esp,%ebp
f010528d:	53                   	push   %ebx
f010528e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105294:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105299:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010529d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01052a0:	83 c2 01             	add    $0x1,%edx
f01052a3:	84 c9                	test   %cl,%cl
f01052a5:	75 f2                	jne    f0105299 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01052a7:	5b                   	pop    %ebx
f01052a8:	5d                   	pop    %ebp
f01052a9:	c3                   	ret    

f01052aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01052aa:	55                   	push   %ebp
f01052ab:	89 e5                	mov    %esp,%ebp
f01052ad:	56                   	push   %esi
f01052ae:	53                   	push   %ebx
f01052af:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052b5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01052b8:	85 f6                	test   %esi,%esi
f01052ba:	74 18                	je     f01052d4 <strncpy+0x2a>
f01052bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01052c1:	0f b6 1a             	movzbl (%edx),%ebx
f01052c4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01052c7:	80 3a 01             	cmpb   $0x1,(%edx)
f01052ca:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01052cd:	83 c1 01             	add    $0x1,%ecx
f01052d0:	39 ce                	cmp    %ecx,%esi
f01052d2:	77 ed                	ja     f01052c1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01052d4:	5b                   	pop    %ebx
f01052d5:	5e                   	pop    %esi
f01052d6:	5d                   	pop    %ebp
f01052d7:	c3                   	ret    

f01052d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01052d8:	55                   	push   %ebp
f01052d9:	89 e5                	mov    %esp,%ebp
f01052db:	56                   	push   %esi
f01052dc:	53                   	push   %ebx
f01052dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01052e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01052e6:	89 f0                	mov    %esi,%eax
f01052e8:	85 c9                	test   %ecx,%ecx
f01052ea:	74 27                	je     f0105313 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f01052ec:	83 e9 01             	sub    $0x1,%ecx
f01052ef:	74 1d                	je     f010530e <strlcpy+0x36>
f01052f1:	0f b6 1a             	movzbl (%edx),%ebx
f01052f4:	84 db                	test   %bl,%bl
f01052f6:	74 16                	je     f010530e <strlcpy+0x36>
			*dst++ = *src++;
f01052f8:	88 18                	mov    %bl,(%eax)
f01052fa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01052fd:	83 e9 01             	sub    $0x1,%ecx
f0105300:	74 0e                	je     f0105310 <strlcpy+0x38>
			*dst++ = *src++;
f0105302:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105305:	0f b6 1a             	movzbl (%edx),%ebx
f0105308:	84 db                	test   %bl,%bl
f010530a:	75 ec                	jne    f01052f8 <strlcpy+0x20>
f010530c:	eb 02                	jmp    f0105310 <strlcpy+0x38>
f010530e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105310:	c6 00 00             	movb   $0x0,(%eax)
f0105313:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0105315:	5b                   	pop    %ebx
f0105316:	5e                   	pop    %esi
f0105317:	5d                   	pop    %ebp
f0105318:	c3                   	ret    

f0105319 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105319:	55                   	push   %ebp
f010531a:	89 e5                	mov    %esp,%ebp
f010531c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010531f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105322:	0f b6 01             	movzbl (%ecx),%eax
f0105325:	84 c0                	test   %al,%al
f0105327:	74 15                	je     f010533e <strcmp+0x25>
f0105329:	3a 02                	cmp    (%edx),%al
f010532b:	75 11                	jne    f010533e <strcmp+0x25>
		p++, q++;
f010532d:	83 c1 01             	add    $0x1,%ecx
f0105330:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105333:	0f b6 01             	movzbl (%ecx),%eax
f0105336:	84 c0                	test   %al,%al
f0105338:	74 04                	je     f010533e <strcmp+0x25>
f010533a:	3a 02                	cmp    (%edx),%al
f010533c:	74 ef                	je     f010532d <strcmp+0x14>
f010533e:	0f b6 c0             	movzbl %al,%eax
f0105341:	0f b6 12             	movzbl (%edx),%edx
f0105344:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105346:	5d                   	pop    %ebp
f0105347:	c3                   	ret    

f0105348 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105348:	55                   	push   %ebp
f0105349:	89 e5                	mov    %esp,%ebp
f010534b:	53                   	push   %ebx
f010534c:	8b 55 08             	mov    0x8(%ebp),%edx
f010534f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105352:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105355:	85 c0                	test   %eax,%eax
f0105357:	74 23                	je     f010537c <strncmp+0x34>
f0105359:	0f b6 1a             	movzbl (%edx),%ebx
f010535c:	84 db                	test   %bl,%bl
f010535e:	74 24                	je     f0105384 <strncmp+0x3c>
f0105360:	3a 19                	cmp    (%ecx),%bl
f0105362:	75 20                	jne    f0105384 <strncmp+0x3c>
f0105364:	83 e8 01             	sub    $0x1,%eax
f0105367:	74 13                	je     f010537c <strncmp+0x34>
		n--, p++, q++;
f0105369:	83 c2 01             	add    $0x1,%edx
f010536c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010536f:	0f b6 1a             	movzbl (%edx),%ebx
f0105372:	84 db                	test   %bl,%bl
f0105374:	74 0e                	je     f0105384 <strncmp+0x3c>
f0105376:	3a 19                	cmp    (%ecx),%bl
f0105378:	74 ea                	je     f0105364 <strncmp+0x1c>
f010537a:	eb 08                	jmp    f0105384 <strncmp+0x3c>
f010537c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105381:	5b                   	pop    %ebx
f0105382:	5d                   	pop    %ebp
f0105383:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105384:	0f b6 02             	movzbl (%edx),%eax
f0105387:	0f b6 11             	movzbl (%ecx),%edx
f010538a:	29 d0                	sub    %edx,%eax
f010538c:	eb f3                	jmp    f0105381 <strncmp+0x39>

f010538e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010538e:	55                   	push   %ebp
f010538f:	89 e5                	mov    %esp,%ebp
f0105391:	8b 45 08             	mov    0x8(%ebp),%eax
f0105394:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105398:	0f b6 10             	movzbl (%eax),%edx
f010539b:	84 d2                	test   %dl,%dl
f010539d:	74 15                	je     f01053b4 <strchr+0x26>
		if (*s == c)
f010539f:	38 ca                	cmp    %cl,%dl
f01053a1:	75 07                	jne    f01053aa <strchr+0x1c>
f01053a3:	eb 14                	jmp    f01053b9 <strchr+0x2b>
f01053a5:	38 ca                	cmp    %cl,%dl
f01053a7:	90                   	nop
f01053a8:	74 0f                	je     f01053b9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01053aa:	83 c0 01             	add    $0x1,%eax
f01053ad:	0f b6 10             	movzbl (%eax),%edx
f01053b0:	84 d2                	test   %dl,%dl
f01053b2:	75 f1                	jne    f01053a5 <strchr+0x17>
f01053b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01053b9:	5d                   	pop    %ebp
f01053ba:	c3                   	ret    

f01053bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01053bb:	55                   	push   %ebp
f01053bc:	89 e5                	mov    %esp,%ebp
f01053be:	8b 45 08             	mov    0x8(%ebp),%eax
f01053c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01053c5:	0f b6 10             	movzbl (%eax),%edx
f01053c8:	84 d2                	test   %dl,%dl
f01053ca:	74 18                	je     f01053e4 <strfind+0x29>
		if (*s == c)
f01053cc:	38 ca                	cmp    %cl,%dl
f01053ce:	75 0a                	jne    f01053da <strfind+0x1f>
f01053d0:	eb 12                	jmp    f01053e4 <strfind+0x29>
f01053d2:	38 ca                	cmp    %cl,%dl
f01053d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01053d8:	74 0a                	je     f01053e4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01053da:	83 c0 01             	add    $0x1,%eax
f01053dd:	0f b6 10             	movzbl (%eax),%edx
f01053e0:	84 d2                	test   %dl,%dl
f01053e2:	75 ee                	jne    f01053d2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01053e4:	5d                   	pop    %ebp
f01053e5:	c3                   	ret    

f01053e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01053e6:	55                   	push   %ebp
f01053e7:	89 e5                	mov    %esp,%ebp
f01053e9:	83 ec 0c             	sub    $0xc,%esp
f01053ec:	89 1c 24             	mov    %ebx,(%esp)
f01053ef:	89 74 24 04          	mov    %esi,0x4(%esp)
f01053f3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01053f7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01053fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01053fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105400:	85 c9                	test   %ecx,%ecx
f0105402:	74 30                	je     f0105434 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105404:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010540a:	75 25                	jne    f0105431 <memset+0x4b>
f010540c:	f6 c1 03             	test   $0x3,%cl
f010540f:	75 20                	jne    f0105431 <memset+0x4b>
		c &= 0xFF;
f0105411:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105414:	89 d3                	mov    %edx,%ebx
f0105416:	c1 e3 08             	shl    $0x8,%ebx
f0105419:	89 d6                	mov    %edx,%esi
f010541b:	c1 e6 18             	shl    $0x18,%esi
f010541e:	89 d0                	mov    %edx,%eax
f0105420:	c1 e0 10             	shl    $0x10,%eax
f0105423:	09 f0                	or     %esi,%eax
f0105425:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0105427:	09 d8                	or     %ebx,%eax
f0105429:	c1 e9 02             	shr    $0x2,%ecx
f010542c:	fc                   	cld    
f010542d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010542f:	eb 03                	jmp    f0105434 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105431:	fc                   	cld    
f0105432:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105434:	89 f8                	mov    %edi,%eax
f0105436:	8b 1c 24             	mov    (%esp),%ebx
f0105439:	8b 74 24 04          	mov    0x4(%esp),%esi
f010543d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105441:	89 ec                	mov    %ebp,%esp
f0105443:	5d                   	pop    %ebp
f0105444:	c3                   	ret    

f0105445 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105445:	55                   	push   %ebp
f0105446:	89 e5                	mov    %esp,%ebp
f0105448:	83 ec 08             	sub    $0x8,%esp
f010544b:	89 34 24             	mov    %esi,(%esp)
f010544e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105452:	8b 45 08             	mov    0x8(%ebp),%eax
f0105455:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0105458:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010545b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f010545d:	39 c6                	cmp    %eax,%esi
f010545f:	73 35                	jae    f0105496 <memmove+0x51>
f0105461:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105464:	39 d0                	cmp    %edx,%eax
f0105466:	73 2e                	jae    f0105496 <memmove+0x51>
		s += n;
		d += n;
f0105468:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010546a:	f6 c2 03             	test   $0x3,%dl
f010546d:	75 1b                	jne    f010548a <memmove+0x45>
f010546f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105475:	75 13                	jne    f010548a <memmove+0x45>
f0105477:	f6 c1 03             	test   $0x3,%cl
f010547a:	75 0e                	jne    f010548a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f010547c:	83 ef 04             	sub    $0x4,%edi
f010547f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105482:	c1 e9 02             	shr    $0x2,%ecx
f0105485:	fd                   	std    
f0105486:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105488:	eb 09                	jmp    f0105493 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010548a:	83 ef 01             	sub    $0x1,%edi
f010548d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105490:	fd                   	std    
f0105491:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105493:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105494:	eb 20                	jmp    f01054b6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105496:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010549c:	75 15                	jne    f01054b3 <memmove+0x6e>
f010549e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01054a4:	75 0d                	jne    f01054b3 <memmove+0x6e>
f01054a6:	f6 c1 03             	test   $0x3,%cl
f01054a9:	75 08                	jne    f01054b3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f01054ab:	c1 e9 02             	shr    $0x2,%ecx
f01054ae:	fc                   	cld    
f01054af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054b1:	eb 03                	jmp    f01054b6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01054b3:	fc                   	cld    
f01054b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01054b6:	8b 34 24             	mov    (%esp),%esi
f01054b9:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01054bd:	89 ec                	mov    %ebp,%esp
f01054bf:	5d                   	pop    %ebp
f01054c0:	c3                   	ret    

f01054c1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01054c1:	55                   	push   %ebp
f01054c2:	89 e5                	mov    %esp,%ebp
f01054c4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01054c7:	8b 45 10             	mov    0x10(%ebp),%eax
f01054ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01054d8:	89 04 24             	mov    %eax,(%esp)
f01054db:	e8 65 ff ff ff       	call   f0105445 <memmove>
}
f01054e0:	c9                   	leave  
f01054e1:	c3                   	ret    

f01054e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01054e2:	55                   	push   %ebp
f01054e3:	89 e5                	mov    %esp,%ebp
f01054e5:	57                   	push   %edi
f01054e6:	56                   	push   %esi
f01054e7:	53                   	push   %ebx
f01054e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01054eb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01054ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01054f1:	85 c9                	test   %ecx,%ecx
f01054f3:	74 36                	je     f010552b <memcmp+0x49>
		if (*s1 != *s2)
f01054f5:	0f b6 06             	movzbl (%esi),%eax
f01054f8:	0f b6 1f             	movzbl (%edi),%ebx
f01054fb:	38 d8                	cmp    %bl,%al
f01054fd:	74 20                	je     f010551f <memcmp+0x3d>
f01054ff:	eb 14                	jmp    f0105515 <memcmp+0x33>
f0105501:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0105506:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010550b:	83 c2 01             	add    $0x1,%edx
f010550e:	83 e9 01             	sub    $0x1,%ecx
f0105511:	38 d8                	cmp    %bl,%al
f0105513:	74 12                	je     f0105527 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0105515:	0f b6 c0             	movzbl %al,%eax
f0105518:	0f b6 db             	movzbl %bl,%ebx
f010551b:	29 d8                	sub    %ebx,%eax
f010551d:	eb 11                	jmp    f0105530 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010551f:	83 e9 01             	sub    $0x1,%ecx
f0105522:	ba 00 00 00 00       	mov    $0x0,%edx
f0105527:	85 c9                	test   %ecx,%ecx
f0105529:	75 d6                	jne    f0105501 <memcmp+0x1f>
f010552b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0105530:	5b                   	pop    %ebx
f0105531:	5e                   	pop    %esi
f0105532:	5f                   	pop    %edi
f0105533:	5d                   	pop    %ebp
f0105534:	c3                   	ret    

f0105535 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105535:	55                   	push   %ebp
f0105536:	89 e5                	mov    %esp,%ebp
f0105538:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010553b:	89 c2                	mov    %eax,%edx
f010553d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105540:	39 d0                	cmp    %edx,%eax
f0105542:	73 15                	jae    f0105559 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105544:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0105548:	38 08                	cmp    %cl,(%eax)
f010554a:	75 06                	jne    f0105552 <memfind+0x1d>
f010554c:	eb 0b                	jmp    f0105559 <memfind+0x24>
f010554e:	38 08                	cmp    %cl,(%eax)
f0105550:	74 07                	je     f0105559 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105552:	83 c0 01             	add    $0x1,%eax
f0105555:	39 c2                	cmp    %eax,%edx
f0105557:	77 f5                	ja     f010554e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105559:	5d                   	pop    %ebp
f010555a:	c3                   	ret    

f010555b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010555b:	55                   	push   %ebp
f010555c:	89 e5                	mov    %esp,%ebp
f010555e:	57                   	push   %edi
f010555f:	56                   	push   %esi
f0105560:	53                   	push   %ebx
f0105561:	83 ec 04             	sub    $0x4,%esp
f0105564:	8b 55 08             	mov    0x8(%ebp),%edx
f0105567:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010556a:	0f b6 02             	movzbl (%edx),%eax
f010556d:	3c 20                	cmp    $0x20,%al
f010556f:	74 04                	je     f0105575 <strtol+0x1a>
f0105571:	3c 09                	cmp    $0x9,%al
f0105573:	75 0e                	jne    f0105583 <strtol+0x28>
		s++;
f0105575:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105578:	0f b6 02             	movzbl (%edx),%eax
f010557b:	3c 20                	cmp    $0x20,%al
f010557d:	74 f6                	je     f0105575 <strtol+0x1a>
f010557f:	3c 09                	cmp    $0x9,%al
f0105581:	74 f2                	je     f0105575 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105583:	3c 2b                	cmp    $0x2b,%al
f0105585:	75 0c                	jne    f0105593 <strtol+0x38>
		s++;
f0105587:	83 c2 01             	add    $0x1,%edx
f010558a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0105591:	eb 15                	jmp    f01055a8 <strtol+0x4d>
	else if (*s == '-')
f0105593:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010559a:	3c 2d                	cmp    $0x2d,%al
f010559c:	75 0a                	jne    f01055a8 <strtol+0x4d>
		s++, neg = 1;
f010559e:	83 c2 01             	add    $0x1,%edx
f01055a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01055a8:	85 db                	test   %ebx,%ebx
f01055aa:	0f 94 c0             	sete   %al
f01055ad:	74 05                	je     f01055b4 <strtol+0x59>
f01055af:	83 fb 10             	cmp    $0x10,%ebx
f01055b2:	75 18                	jne    f01055cc <strtol+0x71>
f01055b4:	80 3a 30             	cmpb   $0x30,(%edx)
f01055b7:	75 13                	jne    f01055cc <strtol+0x71>
f01055b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01055bd:	8d 76 00             	lea    0x0(%esi),%esi
f01055c0:	75 0a                	jne    f01055cc <strtol+0x71>
		s += 2, base = 16;
f01055c2:	83 c2 02             	add    $0x2,%edx
f01055c5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01055ca:	eb 15                	jmp    f01055e1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01055cc:	84 c0                	test   %al,%al
f01055ce:	66 90                	xchg   %ax,%ax
f01055d0:	74 0f                	je     f01055e1 <strtol+0x86>
f01055d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01055d7:	80 3a 30             	cmpb   $0x30,(%edx)
f01055da:	75 05                	jne    f01055e1 <strtol+0x86>
		s++, base = 8;
f01055dc:	83 c2 01             	add    $0x1,%edx
f01055df:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01055e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01055e6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01055e8:	0f b6 0a             	movzbl (%edx),%ecx
f01055eb:	89 cf                	mov    %ecx,%edi
f01055ed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01055f0:	80 fb 09             	cmp    $0x9,%bl
f01055f3:	77 08                	ja     f01055fd <strtol+0xa2>
			dig = *s - '0';
f01055f5:	0f be c9             	movsbl %cl,%ecx
f01055f8:	83 e9 30             	sub    $0x30,%ecx
f01055fb:	eb 1e                	jmp    f010561b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f01055fd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0105600:	80 fb 19             	cmp    $0x19,%bl
f0105603:	77 08                	ja     f010560d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0105605:	0f be c9             	movsbl %cl,%ecx
f0105608:	83 e9 57             	sub    $0x57,%ecx
f010560b:	eb 0e                	jmp    f010561b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010560d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0105610:	80 fb 19             	cmp    $0x19,%bl
f0105613:	77 15                	ja     f010562a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0105615:	0f be c9             	movsbl %cl,%ecx
f0105618:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010561b:	39 f1                	cmp    %esi,%ecx
f010561d:	7d 0b                	jge    f010562a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010561f:	83 c2 01             	add    $0x1,%edx
f0105622:	0f af c6             	imul   %esi,%eax
f0105625:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105628:	eb be                	jmp    f01055e8 <strtol+0x8d>
f010562a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010562c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105630:	74 05                	je     f0105637 <strtol+0xdc>
		*endptr = (char *) s;
f0105632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105635:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105637:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010563b:	74 04                	je     f0105641 <strtol+0xe6>
f010563d:	89 c8                	mov    %ecx,%eax
f010563f:	f7 d8                	neg    %eax
}
f0105641:	83 c4 04             	add    $0x4,%esp
f0105644:	5b                   	pop    %ebx
f0105645:	5e                   	pop    %esi
f0105646:	5f                   	pop    %edi
f0105647:	5d                   	pop    %ebp
f0105648:	c3                   	ret    
f0105649:	00 00                	add    %al,(%eax)
f010564b:	00 00                	add    %al,(%eax)
f010564d:	00 00                	add    %al,(%eax)
	...

f0105650 <vmm_resume>:
	return 0;
}

int
vmm_resume()
{
f0105650:	55                   	push   %ebp
f0105651:	89 e5                	mov    %esp,%ebp
	//load_vmm_state();
	//struct Env* guestOS = envs[ENVX(0x1004)];
        //guestOS.env_status = ENV_RUNNABLE;
	
	return 0;	
}
f0105653:	b8 00 00 00 00       	mov    $0x0,%eax
f0105658:	5d                   	pop    %ebp
f0105659:	c3                   	ret    

f010565a <vmm_exit>:
	return 0;
}

int
vmm_exit()
{
f010565a:	55                   	push   %ebp
f010565b:	89 e5                	mov    %esp,%ebp
	return 0;
}
f010565d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105662:	5d                   	pop    %ebp
f0105663:	c3                   	ret    

f0105664 <vmm_idt_init>:
void VMM_irq_error();
void vmm_vmmsyscall();

void
vmm_idt_init(void)
{
f0105664:	55                   	push   %ebp
f0105665:	89 e5                	mov    %esp,%ebp
	SETGATE( vmm_idt[0], 0, GD_KT, VMM_DivideByZero, 0);
f0105667:	b8 2c 5e 10 f0       	mov    $0xf0105e2c,%eax
f010566c:	66 a3 60 3a 1e f0    	mov    %ax,0xf01e3a60
f0105672:	66 c7 05 62 3a 1e f0 	movw   $0x8,0xf01e3a62
f0105679:	08 00 
f010567b:	c6 05 64 3a 1e f0 00 	movb   $0x0,0xf01e3a64
f0105682:	c6 05 65 3a 1e f0 8e 	movb   $0x8e,0xf01e3a65
f0105689:	c1 e8 10             	shr    $0x10,%eax
f010568c:	66 a3 66 3a 1e f0    	mov    %ax,0xf01e3a66
	SETGATE( vmm_idt[13], 0, GD_KT, VMM_BadSegment, 0);
f0105692:	b8 32 5e 10 f0       	mov    $0xf0105e32,%eax
f0105697:	66 a3 c8 3a 1e f0    	mov    %ax,0xf01e3ac8
f010569d:	66 c7 05 ca 3a 1e f0 	movw   $0x8,0xf01e3aca
f01056a4:	08 00 
f01056a6:	c6 05 cc 3a 1e f0 00 	movb   $0x0,0xf01e3acc
f01056ad:	c6 05 cd 3a 1e f0 8e 	movb   $0x8e,0xf01e3acd
f01056b4:	c1 e8 10             	shr    $0x10,%eax
f01056b7:	66 a3 ce 3a 1e f0    	mov    %ax,0xf01e3ace
	SETGATE(vmm_idt[T_PGFLT], 0, GD_KT, VMM_PageFault, 0);
f01056bd:	b8 36 5e 10 f0       	mov    $0xf0105e36,%eax
f01056c2:	66 a3 d0 3a 1e f0    	mov    %ax,0xf01e3ad0
f01056c8:	66 c7 05 d2 3a 1e f0 	movw   $0x8,0xf01e3ad2
f01056cf:	08 00 
f01056d1:	c6 05 d4 3a 1e f0 00 	movb   $0x0,0xf01e3ad4
f01056d8:	c6 05 d5 3a 1e f0 8e 	movb   $0x8e,0xf01e3ad5
f01056df:	c1 e8 10             	shr    $0x10,%eax
f01056e2:	66 a3 d6 3a 1e f0    	mov    %ax,0xf01e3ad6
	SETGATE(vmm_idt[T_BRKPT], 0, GD_KT, VMM_BreakPoint, 3);
f01056e8:	b8 3a 5e 10 f0       	mov    $0xf0105e3a,%eax
f01056ed:	66 a3 78 3a 1e f0    	mov    %ax,0xf01e3a78
f01056f3:	66 c7 05 7a 3a 1e f0 	movw   $0x8,0xf01e3a7a
f01056fa:	08 00 
f01056fc:	c6 05 7c 3a 1e f0 00 	movb   $0x0,0xf01e3a7c
f0105703:	c6 05 7d 3a 1e f0 ee 	movb   $0xee,0xf01e3a7d
f010570a:	c1 e8 10             	shr    $0x10,%eax
f010570d:	66 a3 7e 3a 1e f0    	mov    %ax,0xf01e3a7e
//	SETGATE(vmm_idt[VMM_SYSCALL], 0, GD_KT, vmm_vmmsyscall, 3);
	SETGATE(vmm_idt[T_SYSCALL], 0, GD_KT, vmm_vmmsyscall, 3);
f0105713:	b8 40 5e 10 f0       	mov    $0xf0105e40,%eax
f0105718:	66 a3 e0 3b 1e f0    	mov    %ax,0xf01e3be0
f010571e:	66 c7 05 e2 3b 1e f0 	movw   $0x8,0xf01e3be2
f0105725:	08 00 
f0105727:	c6 05 e4 3b 1e f0 00 	movb   $0x0,0xf01e3be4
f010572e:	c6 05 e5 3b 1e f0 ee 	movb   $0xee,0xf01e3be5
f0105735:	c1 e8 10             	shr    $0x10,%eax
f0105738:	66 a3 e6 3b 1e f0    	mov    %ax,0xf01e3be6
	SETGATE(vmm_idt[IRQ_TIMER+IRQ_OFFSET], 0, GD_KT, VMM_irq_timer, 0);		
f010573e:	b8 46 5e 10 f0       	mov    $0xf0105e46,%eax
f0105743:	66 a3 60 3b 1e f0    	mov    %ax,0xf01e3b60
f0105749:	66 c7 05 62 3b 1e f0 	movw   $0x8,0xf01e3b62
f0105750:	08 00 
f0105752:	c6 05 64 3b 1e f0 00 	movb   $0x0,0xf01e3b64
f0105759:	c6 05 65 3b 1e f0 8e 	movb   $0x8e,0xf01e3b65
f0105760:	c1 e8 10             	shr    $0x10,%eax
f0105763:	66 a3 66 3b 1e f0    	mov    %ax,0xf01e3b66
			
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	vmm_ts.ts_esp0 = KSTACKTOP;
f0105769:	c7 05 64 42 1e f0 00 	movl   $0xefc00000,0xf01e4264
f0105770:	00 c0 ef 
	vmm_ts.ts_ss0 = GD_KD;
f0105773:	66 c7 05 68 42 1e f0 	movw   $0x10,0xf01e4268
f010577a:	10 00 

	// Initialize the TSS field of the gdt.
//	cprintf("gdt: %x GD_TSS: %x\n", gdt, GD_TSS);
	vmm_gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&vmm_ts),
f010577c:	66 c7 05 a8 f3 11 f0 	movw   $0x68,0xf011f3a8
f0105783:	68 00 
f0105785:	b8 60 42 1e f0       	mov    $0xf01e4260,%eax
f010578a:	66 a3 aa f3 11 f0    	mov    %ax,0xf011f3aa
f0105790:	89 c2                	mov    %eax,%edx
f0105792:	c1 ea 10             	shr    $0x10,%edx
f0105795:	88 15 ac f3 11 f0    	mov    %dl,0xf011f3ac
f010579b:	c6 05 ae f3 11 f0 40 	movb   $0x40,0xf011f3ae
f01057a2:	c1 e8 18             	shr    $0x18,%eax
f01057a5:	a2 af f3 11 f0       	mov    %al,0xf011f3af
					sizeof(struct Taskstate), 0);		
	vmm_gdt[GD_TSS >> 3].sd_s = 0;
f01057aa:	c6 05 ad f3 11 f0 89 	movb   $0x89,0xf011f3ad

	// Load the TSS
//	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt vmm_idt_pd");
f01057b1:	0f 01 1d bc f3 11 f0 	lidtl  0xf011f3bc
}
f01057b8:	5d                   	pop    %ebp
f01057b9:	c3                   	ret    

f01057ba <print_native_regs>:
	sizeof(vmm_idt) - 1, (uint32_t) vmm_idt
};

void
print_native_regs(struct PushNativeRegs *regs)
{
f01057ba:	55                   	push   %ebp
f01057bb:	89 e5                	mov    %esp,%ebp
f01057bd:	53                   	push   %ebx
f01057be:	83 ec 14             	sub    $0x14,%esp
f01057c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01057c4:	8b 03                	mov    (%ebx),%eax
f01057c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057ca:	c7 04 24 12 7a 10 f0 	movl   $0xf0107a12,(%esp)
f01057d1:	e8 35 e2 ff ff       	call   f0103a0b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01057d6:	8b 43 04             	mov    0x4(%ebx),%eax
f01057d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057dd:	c7 04 24 21 7a 10 f0 	movl   $0xf0107a21,(%esp)
f01057e4:	e8 22 e2 ff ff       	call   f0103a0b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01057e9:	8b 43 08             	mov    0x8(%ebx),%eax
f01057ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057f0:	c7 04 24 30 7a 10 f0 	movl   $0xf0107a30,(%esp)
f01057f7:	e8 0f e2 ff ff       	call   f0103a0b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01057fc:	8b 43 0c             	mov    0xc(%ebx),%eax
f01057ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105803:	c7 04 24 3f 7a 10 f0 	movl   $0xf0107a3f,(%esp)
f010580a:	e8 fc e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010580f:	8b 43 10             	mov    0x10(%ebx),%eax
f0105812:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105816:	c7 04 24 4e 7a 10 f0 	movl   $0xf0107a4e,(%esp)
f010581d:	e8 e9 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0105822:	8b 43 14             	mov    0x14(%ebx),%eax
f0105825:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105829:	c7 04 24 5d 7a 10 f0 	movl   $0xf0107a5d,(%esp)
f0105830:	e8 d6 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105835:	8b 43 18             	mov    0x18(%ebx),%eax
f0105838:	89 44 24 04          	mov    %eax,0x4(%esp)
f010583c:	c7 04 24 6c 7a 10 f0 	movl   $0xf0107a6c,(%esp)
f0105843:	e8 c3 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0105848:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010584b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010584f:	c7 04 24 7b 7a 10 f0 	movl   $0xf0107a7b,(%esp)
f0105856:	e8 b0 e1 ff ff       	call   f0103a0b <cprintf>
}
f010585b:	83 c4 14             	add    $0x14,%esp
f010585e:	5b                   	pop    %ebx
f010585f:	5d                   	pop    %ebp
f0105860:	c3                   	ret    

f0105861 <print_native_trapframe>:

void
print_native_trapframe(struct NativeTrapframe *tf)
{
f0105861:	55                   	push   %ebp
f0105862:	89 e5                	mov    %esp,%ebp
f0105864:	53                   	push   %ebx
f0105865:	83 ec 14             	sub    $0x14,%esp
f0105868:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010586b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010586f:	c7 04 24 8a 7a 10 f0 	movl   $0xf0107a8a,(%esp)
f0105876:	e8 90 e1 ff ff       	call   f0103a0b <cprintf>
	print_native_regs(&tf->tf_regs);
f010587b:	89 1c 24             	mov    %ebx,(%esp)
f010587e:	e8 37 ff ff ff       	call   f01057ba <print_native_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0105883:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0105887:	89 44 24 04          	mov    %eax,0x4(%esp)
f010588b:	c7 04 24 9c 7a 10 f0 	movl   $0xf0107a9c,(%esp)
f0105892:	e8 74 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0105897:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010589b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010589f:	c7 04 24 af 7a 10 f0 	movl   $0xf0107aaf,(%esp)
f01058a6:	e8 60 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  trap 0x%08x\n", tf->tf_trapno);
f01058ab:	8b 43 28             	mov    0x28(%ebx),%eax
f01058ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058b2:	c7 04 24 af 81 10 f0 	movl   $0xf01081af,(%esp)
f01058b9:	e8 4d e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f01058be:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01058c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058c5:	c7 04 24 02 7b 10 f0 	movl   $0xf0107b02,(%esp)
f01058cc:	e8 3a e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01058d1:	8b 43 30             	mov    0x30(%ebx),%eax
f01058d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058d8:	c7 04 24 11 7b 10 f0 	movl   $0xf0107b11,(%esp)
f01058df:	e8 27 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01058e4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01058e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058ec:	c7 04 24 20 7b 10 f0 	movl   $0xf0107b20,(%esp)
f01058f3:	e8 13 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01058f8:	8b 43 38             	mov    0x38(%ebx),%eax
f01058fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058ff:	c7 04 24 33 7b 10 f0 	movl   $0xf0107b33,(%esp)
f0105906:	e8 00 e1 ff ff       	call   f0103a0b <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f010590b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010590e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105912:	c7 04 24 42 7b 10 f0 	movl   $0xf0107b42,(%esp)
f0105919:	e8 ed e0 ff ff       	call   f0103a0b <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010591e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0105922:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105926:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f010592d:	e8 d9 e0 ff ff       	call   f0103a0b <cprintf>
}
f0105932:	83 c4 14             	add    $0x14,%esp
f0105935:	5b                   	pop    %ebx
f0105936:	5d                   	pop    %ebp
f0105937:	c3                   	ret    

f0105938 <restore_native_state>:
	return 0;
}

int
restore_native_state()
{
f0105938:	55                   	push   %ebp
f0105939:	89 e5                	mov    %esp,%ebp
f010593b:	83 ec 18             	sub    $0x18,%esp

	cprintf("\nRestoring host global descriptor table...\t\t");	
f010593e:	c7 04 24 74 82 10 f0 	movl   $0xf0108274,(%esp)
f0105945:	e8 c1 e0 ff ff       	call   f0103a0b <cprintf>
	//setting up the GDT
	memmove(gdt, native_gdt,  native_gdt_pd.pd_lim);
f010594a:	0f b7 05 ec 43 1e f0 	movzwl 0xf01e43ec,%eax
f0105951:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105955:	c7 44 24 04 40 43 1e 	movl   $0xf01e4340,0x4(%esp)
f010595c:	f0 
f010595d:	c7 04 24 20 f3 11 f0 	movl   $0xf011f320,(%esp)
f0105964:	e8 dc fa ff ff       	call   f0105445 <memmove>
        //loading vmm gdt into gdtr
        __asm __volatile("lgdt gdt_pd");
f0105969:	0f 01 15 50 f3 11 f0 	lgdtl  0xf011f350
	cprintf("[Done]\n");	
f0105970:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f0105977:	e8 8f e0 ff ff       	call   f0103a0b <cprintf>

	//setting up the IDT
	cprintf("\nRestoring host interrupt descriptor table...\t\t");	
f010597c:	c7 04 24 a4 82 10 f0 	movl   $0xf01082a4,(%esp)
f0105983:	e8 83 e0 ff ff       	call   f0103a0b <cprintf>
        memmove(idt, native_idt,  native_idt_pd.pd_lim);
f0105988:	0f b7 05 b6 f3 11 f0 	movzwl 0xf011f3b6,%eax
f010598f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105993:	c7 44 24 04 60 32 1e 	movl   $0xf01e3260,0x4(%esp)
f010599a:	f0 
f010599b:	c7 04 24 e0 25 1e f0 	movl   $0xf01e25e0,(%esp)
f01059a2:	e8 9e fa ff ff       	call   f0105445 <memmove>
	asm volatile("lidt idt_pd");
f01059a7:	0f 01 1d 5c f3 11 f0 	lidtl  0xf011f35c

	cprintf("[Done]\nRestoring host machine stack set up...\t\t");	
f01059ae:	c7 04 24 d4 82 10 f0 	movl   $0xf01082d4,(%esp)
f01059b5:	e8 51 e0 ff ff       	call   f0103a0b <cprintf>
	__asm __volatile("movl %%esp, %0\n" : :"m"(native_trap_frame.tf_esp));
f01059ba:	89 25 1c 43 1e f0    	mov    %esp,0xf01e431c
	__asm __volatile("mov %%ss, %0\n" : :"m"(native_trap_frame.tf_ss));
f01059c0:	8c 15 20 43 1e f0    	mov    %ss,0xf01e4320
	cprintf("[Done]\n");	
f01059c6:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f01059cd:	e8 39 e0 ff ff       	call   f0103a0b <cprintf>
	
	return 0;
}
f01059d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d7:	c9                   	leave  
f01059d8:	c3                   	ret    

f01059d9 <load_vmm_state>:
	return 0;	
}

int
load_vmm_state()
{
f01059d9:	55                   	push   %ebp
f01059da:	89 e5                	mov    %esp,%ebp
f01059dc:	83 ec 18             	sub    $0x18,%esp
	//creating vmm_gdt
	cprintf("\nSetting up global descriptor table...\t\t");	
f01059df:	c7 04 24 04 83 10 f0 	movl   $0xf0108304,(%esp)
f01059e6:	e8 20 e0 ff ff       	call   f0103a0b <cprintf>
	memmove(vmm_gdt, native_gdt, gdt_pd.pd_lim);
f01059eb:	0f b7 05 50 f3 11 f0 	movzwl 0xf011f350,%eax
f01059f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059f6:	c7 44 24 04 40 43 1e 	movl   $0xf01e4340,0x4(%esp)
f01059fd:	f0 
f01059fe:	c7 04 24 80 f3 11 f0 	movl   $0xf011f380,(%esp)
f0105a05:	e8 3b fa ff ff       	call   f0105445 <memmove>
	cprintf("[Done]\n");	
f0105a0a:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f0105a11:	e8 f5 df ff ff       	call   f0103a0b <cprintf>

	//loading vmm gdt into gdtr
	__asm __volatile("lgdt vmm_gdt_pd");
f0105a16:	0f 01 15 b0 f3 11 f0 	lgdtl  0xf011f3b0
	
	cprintf("Setting up interrupt descriptor table...\t\t");	
f0105a1d:	c7 04 24 30 83 10 f0 	movl   $0xf0108330,(%esp)
f0105a24:	e8 e2 df ff ff       	call   f0103a0b <cprintf>
	vmm_idt_init();
f0105a29:	e8 36 fc ff ff       	call   f0105664 <vmm_idt_init>
	cprintf("[Done]\n");	
f0105a2e:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f0105a35:	e8 d1 df ff ff       	call   f0103a0b <cprintf>
	return 0;
}
f0105a3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a3f:	c9                   	leave  
f0105a40:	c3                   	ret    

f0105a41 <save_native_state>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

int
save_native_state()
{
f0105a41:	55                   	push   %ebp
f0105a42:	89 e5                	mov    %esp,%ebp
f0105a44:	83 ec 18             	sub    $0x18,%esp
	//storing the current gdt, idt to restore later
	cprintf("\nSaving host machine GDT...\t\t");
f0105a47:	c7 04 24 c6 81 10 f0 	movl   $0xf01081c6,(%esp)
f0105a4e:	e8 b8 df ff ff       	call   f0103a0b <cprintf>
	memmove(native_gdt, gdt, gdt_pd.pd_lim);
f0105a53:	0f b7 05 50 f3 11 f0 	movzwl 0xf011f350,%eax
f0105a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a5e:	c7 44 24 04 20 f3 11 	movl   $0xf011f320,0x4(%esp)
f0105a65:	f0 
f0105a66:	c7 04 24 40 43 1e f0 	movl   $0xf01e4340,(%esp)
f0105a6d:	e8 d3 f9 ff ff       	call   f0105445 <memmove>
	native_gdt_pd.pd_lim = sizeof(native_gdt_pd) - 1;
f0105a72:	66 c7 05 ec 43 1e f0 	movw   $0x5,0xf01e43ec
f0105a79:	05 00 
	native_gdt_pd.pd_base= (unsigned long) native_gdt;
f0105a7b:	c7 05 ee 43 1e f0 40 	movl   $0xf01e4340,0xf01e43ee
f0105a82:	43 1e f0 
	cprintf("[Done]\n");
f0105a85:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f0105a8c:	e8 7a df ff ff       	call   f0103a0b <cprintf>

	cprintf("\nSaving host machine IDT...\t\t");
f0105a91:	c7 04 24 e4 81 10 f0 	movl   $0xf01081e4,(%esp)
f0105a98:	e8 6e df ff ff       	call   f0103a0b <cprintf>
	memmove(native_idt, idt, native_idt_pd.pd_lim);
f0105a9d:	0f b7 05 b6 f3 11 f0 	movzwl 0xf011f3b6,%eax
f0105aa4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105aa8:	c7 44 24 04 e0 25 1e 	movl   $0xf01e25e0,0x4(%esp)
f0105aaf:	f0 
f0105ab0:	c7 04 24 60 32 1e f0 	movl   $0xf01e3260,(%esp)
f0105ab7:	e8 89 f9 ff ff       	call   f0105445 <memmove>
	cprintf("[Done]\n");
f0105abc:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f0105ac3:	e8 43 df ff ff       	call   f0103a0b <cprintf>

	cprintf("Saving host machine state...\t\t");
f0105ac8:	c7 04 24 5c 83 10 f0 	movl   $0xf010835c,(%esp)
f0105acf:	e8 37 df ff ff       	call   f0103a0b <cprintf>
	__asm __volatile("movl %%eax, %0\n" :"=r"(native_trap_frame.tf_regs.reg_eax));
f0105ad4:	89 c0                	mov    %eax,%eax
f0105ad6:	a3 fc 42 1e f0       	mov    %eax,0xf01e42fc
	__asm __volatile("movl %%ecx, %0\n" :"=r"(native_trap_frame.tf_regs.reg_ecx));
f0105adb:	89 c8                	mov    %ecx,%eax
f0105add:	a3 f8 42 1e f0       	mov    %eax,0xf01e42f8
	__asm __volatile("movl %%edx, %0\n" :"=r"(native_trap_frame.tf_regs.reg_edx));
f0105ae2:	89 d0                	mov    %edx,%eax
f0105ae4:	a3 f4 42 1e f0       	mov    %eax,0xf01e42f4
	__asm __volatile("movl %%ebx, %0\n" :"=r"(native_trap_frame.tf_regs.reg_ebx));
f0105ae9:	89 d8                	mov    %ebx,%eax
f0105aeb:	a3 f0 42 1e f0       	mov    %eax,0xf01e42f0
	__asm __volatile("movl %%ebp, %0\n" :"=r"(native_trap_frame.tf_regs.reg_ebp));
f0105af0:	89 e8                	mov    %ebp,%eax
f0105af2:	a3 e8 42 1e f0       	mov    %eax,0xf01e42e8
	__asm __volatile("movl %%esi, %0\n" :"=r"(native_trap_frame.tf_regs.reg_esi));
f0105af7:	89 f0                	mov    %esi,%eax
f0105af9:	a3 e4 42 1e f0       	mov    %eax,0xf01e42e4
	__asm __volatile("movl %%edi, %0\n" :"=r"(native_trap_frame.tf_regs.reg_edi));
f0105afe:	89 f8                	mov    %edi,%eax
f0105b00:	a3 e0 42 1e f0       	mov    %eax,0xf01e42e0
	__asm __volatile("mov %%es, %0\n" :"=r"(native_trap_frame.tf_es));
f0105b05:	66 8c c0             	mov    %es,%ax
f0105b08:	66 a3 00 43 1e f0    	mov    %ax,0xf01e4300
	__asm __volatile("mov %%ds, %0\n" :"=r"(native_trap_frame.tf_ds));
f0105b0e:	66 8c d8             	mov    %ds,%ax
f0105b11:	66 a3 04 43 1e f0    	mov    %ax,0xf01e4304
	__asm __volatile("mov %%cs, %0\n" :"=r"(native_trap_frame.tf_cs));
f0105b17:	66 8c c8             	mov    %cs,%ax
f0105b1a:	66 a3 14 43 1e f0    	mov    %ax,0xf01e4314
	__asm __volatile("mov %%cs, %0\n" :"=r"(native_trap_frame.tf_eflags));
f0105b20:	8c c8                	mov    %cs,%eax
	__asm __volatile("pushfl");
f0105b22:	9c                   	pushf  
	__asm __volatile("popl %eax");
f0105b23:	58                   	pop    %eax
	__asm __volatile("movl %%eax, %0\n" :"=r"(native_trap_frame.tf_eflags));
f0105b24:	89 c0                	mov    %eax,%eax
f0105b26:	a3 18 43 1e f0       	mov    %eax,0xf01e4318
	__asm __volatile("movl %%esp, %0\n" :"=r"(native_trap_frame.tf_esp));
f0105b2b:	89 e0                	mov    %esp,%eax
f0105b2d:	a3 1c 43 1e f0       	mov    %eax,0xf01e431c
	__asm __volatile("mov %%ss, %0\n" :"=r"(native_trap_frame.tf_ss));
f0105b32:	66 8c d0             	mov    %ss,%ax
f0105b35:	66 a3 20 43 1e f0    	mov    %ax,0xf01e4320
	if(debug)
		cprintf("native_gdt: %x sizeof(gdt): %d\n", native_gdt, gdt_pd.pd_lim);
	cprintf("[Done]\n");
f0105b3b:	c7 04 24 be 81 10 f0 	movl   $0xf01081be,(%esp)
f0105b42:	e8 c4 de ff ff       	call   f0103a0b <cprintf>
	return 0;
}
f0105b47:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b4c:	c9                   	leave  
f0105b4d:	c3                   	ret    

f0105b4e <vmm_run>:
	// Load the IDT
	asm volatile("lidt vmm_idt_pd");
}

void vmm_run()
{
f0105b4e:	55                   	push   %ebp
f0105b4f:	89 e5                	mov    %esp,%ebp
f0105b51:	83 ec 18             	sub    $0x18,%esp
	//envs[ENVX(0x1000)].env_status = ENV_NOT_RUNNABLE;
	//envs[ENVX(0x1001)].env_status = ENV_NOT_RUNNABLE;
	//envs[ENVX(0x1002)].env_status = ENV_NOT_RUNNABLE;
	//envs[ENVX(0x1003)].env_status = ENV_NOT_RUNNABLE;
	
	envs[ENVX(0x1004)].env_status = ENV_RUNNABLE;
f0105b54:	a1 c0 25 1e f0       	mov    0xf01e25c0,%eax
f0105b59:	c7 80 44 02 00 00 01 	movl   $0x1,0x244(%eax)
f0105b60:	00 00 00 
	KERN_CR3 = (&envs[ENVX(0x1004)])->env_cr3;
f0105b63:	a1 c0 25 1e f0       	mov    0xf01e25c0,%eax
f0105b68:	05 f0 01 00 00       	add    $0x1f0,%eax
f0105b6d:	8b 50 60             	mov    0x60(%eax),%edx
f0105b70:	89 15 e8 43 1e f0    	mov    %edx,0xf01e43e8
	KERN_ENV = &envs[ENVX(0x1004)];
f0105b76:	a3 e4 43 1e f0       	mov    %eax,0xf01e43e4

	env_run(&envs[ENVX(0x1004)]);
f0105b7b:	89 04 24             	mov    %eax,(%esp)
f0105b7e:	e8 5c d5 ff ff       	call   f01030df <env_run>

f0105b83 <vmm_init>:
	return 0;
}

int
vmm_init( )
{
f0105b83:	55                   	push   %ebp
f0105b84:	89 e5                	mov    %esp,%ebp
f0105b86:	83 ec 18             	sub    $0x18,%esp
	int r;
		
	cprintf("\n\nSwitching from host to virtual machine...\n");
f0105b89:	c7 04 24 7c 83 10 f0 	movl   $0xf010837c,(%esp)
f0105b90:	e8 76 de ff ff       	call   f0103a0b <cprintf>
	cprintf("Saving the host machine context... \t\t");
f0105b95:	c7 04 24 ac 83 10 f0 	movl   $0xf01083ac,(%esp)
f0105b9c:	e8 6a de ff ff       	call   f0103a0b <cprintf>
	save_native_state();
f0105ba1:	e8 9b fe ff ff       	call   f0105a41 <save_native_state>

	cprintf("Loading the Virtual Machine...\t\t");
f0105ba6:	c7 04 24 d4 83 10 f0 	movl   $0xf01083d4,(%esp)
f0105bad:	e8 59 de ff ff       	call   f0103a0b <cprintf>
	load_vmm_state();
f0105bb2:	e8 22 fe ff ff       	call   f01059d9 <load_vmm_state>
	vmm_run();
f0105bb7:	e8 92 ff ff ff       	call   f0105b4e <vmm_run>
	return 0;
}
f0105bbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bc1:	c9                   	leave  
f0105bc2:	c3                   	ret    

f0105bc3 <vmm_suspend>:
	

int
vmm_suspend()
{
f0105bc3:	55                   	push   %ebp
f0105bc4:	89 e5                	mov    %esp,%ebp
f0105bc6:	83 ec 08             	sub    $0x8,%esp
	restore_native_state();
f0105bc9:	e8 6a fd ff ff       	call   f0105938 <restore_native_state>
	timer_count = 0;
f0105bce:	c7 05 c8 42 1e f0 00 	movl   $0x0,0xf01e42c8
f0105bd5:	00 00 00 
	struct Env *guestOS = &(envs[ENVX(0x1004)]);
	guestOS->env_status = ENV_NOT_RUNNABLE;
f0105bd8:	a1 c0 25 1e f0       	mov    0xf01e25c0,%eax
f0105bdd:	c7 80 44 02 00 00 02 	movl   $0x2,0x244(%eax)
f0105be4:	00 00 00 
	sched_yield();
f0105be7:	e8 54 e5 ff ff       	call   f0104140 <sched_yield>

f0105bec <vmm_trap>:
	}
}

void
vmm_trap(struct Trapframe *tf)
{
f0105bec:	55                   	push   %ebp
f0105bed:	89 e5                	mov    %esp,%ebp
f0105bef:	81 ec b8 00 00 00    	sub    $0xb8,%esp
f0105bf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105bf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105bfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105bfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("cld" ::: "cc");
f0105c01:	fc                   	cld    
	cprintf("vmm_trap(); trapno: %d\n", tf->tf_trapno);
f0105c02:	8b 43 28             	mov    0x28(%ebx),%eax
f0105c05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c09:	c7 04 24 02 82 10 f0 	movl   $0xf0108202,(%esp)
f0105c10:	e8 f6 dd ff ff       	call   f0103a0b <cprintf>
f0105c15:	9c                   	pushf  
f0105c16:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0105c17:	f6 c4 02             	test   $0x2,%ah
f0105c1a:	74 24                	je     f0105c40 <vmm_trap+0x54>
f0105c1c:	c7 44 24 0c 64 7b 10 	movl   $0xf0107b64,0xc(%esp)
f0105c23:	f0 
f0105c24:	c7 44 24 08 74 76 10 	movl   $0xf0107674,0x8(%esp)
f0105c2b:	f0 
f0105c2c:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0105c33:	00 
f0105c34:	c7 04 24 1a 82 10 f0 	movl   $0xf010821a,(%esp)
f0105c3b:	e8 45 a4 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) 
f0105c40:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0105c44:	83 e0 03             	and    $0x3,%eax
f0105c47:	83 f8 03             	cmp    $0x3,%eax
f0105c4a:	75 20                	jne    f0105c6c <vmm_trap+0x80>
	{
	//	assert(curenv);
		//cprintf("vmm_trap(): from user space, tf->tf_regs.reg_esi = %x\n",tf->tf_regs.reg_esi);
		if(tf->tf_regs.reg_esi == -1)
f0105c4c:	83 7b 04 ff          	cmpl   $0xffffffff,0x4(%ebx)
f0105c50:	75 1a                	jne    f0105c6c <vmm_trap+0x80>
		{
			cprintf("vmm.c : saving guest OS tarpframe...\n");			
f0105c52:	c7 04 24 f8 83 10 f0 	movl   $0xf01083f8,(%esp)
f0105c59:	e8 ad dd ff ff       	call   f0103a0b <cprintf>
			vm_saved_tf = *tf;	
f0105c5e:	bf a0 43 1e f0       	mov    $0xf01e43a0,%edi
f0105c63:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105c68:	89 de                	mov    %ebx,%esi
f0105c6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

static void
vmm_trap_dispatch(struct Trapframe *tf)
{
	//if(tf->tf_trapno == VMM_SYSCALL)
	if(tf->tf_trapno == T_SYSCALL)
f0105c6c:	8b 43 28             	mov    0x28(%ebx),%eax
f0105c6f:	83 f8 30             	cmp    $0x30,%eax
f0105c72:	75 2f                	jne    f0105ca3 <vmm_trap+0xb7>
	{
		int r = vmm_syscall1(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0105c74:	8b 43 04             	mov    0x4(%ebx),%eax
f0105c77:	89 44 24 14          	mov    %eax,0x14(%esp)
f0105c7b:	8b 03                	mov    (%ebx),%eax
f0105c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105c81:	8b 43 10             	mov    0x10(%ebx),%eax
f0105c84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c88:	8b 43 18             	mov    0x18(%ebx),%eax
f0105c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c8f:	8b 43 14             	mov    0x14(%ebx),%eax
f0105c92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c96:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105c99:	89 04 24             	mov    %eax,(%esp)
f0105c9c:	e8 28 03 00 00       	call   f0105fc9 <vmm_syscall1>
f0105ca1:	eb 37                	jmp    f0105cda <vmm_trap+0xee>
			tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi,
			tf->tf_regs.reg_esi );
	}
        else if(tf->tf_trapno == T_PGFLT)
f0105ca3:	83 f8 0e             	cmp    $0xe,%eax
f0105ca6:	75 0e                	jne    f0105cb6 <vmm_trap+0xca>
	{
		cprintf("page faulted\n");
f0105ca8:	c7 04 24 25 82 10 f0 	movl   $0xf0108225,(%esp)
f0105caf:	e8 57 dd ff ff       	call   f0103a0b <cprintf>
f0105cb4:	eb 24                	jmp    f0105cda <vmm_trap+0xee>
	}
	else if(tf->tf_trapno == 13)
f0105cb6:	83 f8 0d             	cmp    $0xd,%eax
f0105cb9:	75 0e                	jne    f0105cc9 <vmm_trap+0xdd>
	{	
		cprintf("General Protection Fault\n");
f0105cbb:	c7 04 24 33 82 10 f0 	movl   $0xf0108233,(%esp)
f0105cc2:	e8 44 dd ff ff       	call   f0103a0b <cprintf>
f0105cc7:	eb 11                	jmp    f0105cda <vmm_trap+0xee>
	}
	else if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0105cc9:	83 f8 20             	cmp    $0x20,%eax
f0105ccc:	75 0c                	jne    f0105cda <vmm_trap+0xee>
	{
//		restore_native_state();
		cprintf("Trap due to timer...\n");
f0105cce:	c7 04 24 4d 82 10 f0 	movl   $0xf010824d,(%esp)
f0105cd5:	e8 31 dd ff ff       	call   f0103a0b <cprintf>
		}
	//	curenv->env_tf = *tf;
	//	tf = &curenv->env_tf;
	}
	vmm_trap_dispatch(tf);
	struct Env guestOS = envs[ENVX(0x1004)];
f0105cda:	8d bd 6c ff ff ff    	lea    -0x94(%ebp),%edi
f0105ce0:	8b 35 c0 25 1e f0    	mov    0xf01e25c0,%esi
f0105ce6:	81 c6 f0 01 00 00    	add    $0x1f0,%esi
f0105cec:	b9 1f 00 00 00       	mov    $0x1f,%ecx
f0105cf1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
//	if (curenv && curenv->env_status == ENV_RUNNABLE)
//	{
		//if(tf->tf_trapno == VMM_SYSCALL || tf->tf_trapno == 32)

		// handling the case just for CPrintf.
		if( tf->tf_trapno == T_SYSCALL )
f0105cf3:	8b 43 28             	mov    0x28(%ebx),%eax
f0105cf6:	83 f8 30             	cmp    $0x30,%eax
f0105cf9:	0f 85 b7 00 00 00    	jne    f0105db6 <vmm_trap+0x1ca>
		{		
			cprintf("vmm.c : Going back to guest kernel...\n");			
f0105cff:	c7 04 24 20 84 10 f0 	movl   $0xf0108420,(%esp)
f0105d06:	e8 00 dd ff ff       	call   f0103a0b <cprintf>

			if((tf->tf_regs.reg_esi != -1) && (tf->tf_regs.reg_esi ==0) )	
f0105d0b:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
f0105d0f:	75 7c                	jne    f0105d8d <vmm_trap+0x1a1>
			{
				tf->tf_regs.reg_esi = 0; // clearing so that does not have the value -1
f0105d11:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
				cprintf("vm_saved_tf: \n");	
f0105d18:	c7 04 24 63 82 10 f0 	movl   $0xf0108263,(%esp)
f0105d1f:	e8 e7 dc ff ff       	call   f0103a0b <cprintf>
				print_native_trapframe((struct NativeTrapframe*)&vm_saved_tf);
f0105d24:	c7 04 24 a0 43 1e f0 	movl   $0xf01e43a0,(%esp)
f0105d2b:	e8 31 fb ff ff       	call   f0105861 <print_native_trapframe>
				guestOS.env_tf = vm_saved_tf;
f0105d30:	8d bd 6c ff ff ff    	lea    -0x94(%ebp),%edi
f0105d36:	be a0 43 1e f0       	mov    $0xf01e43a0,%esi
f0105d3b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105d40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0105d42:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105d45:	0f 22 d8             	mov    %eax,%cr3

				//env_run(&envs[ENVX(0x1004)]);
				// pushing guest user's process trapframe on the guest kernel stack
				lcr3(guestOS.env_cr3);	
				cprintf("vmm.c :3  Going back to guest kernel... guestOS- ESP :%x\nCurrent TF:\n ",guestOS.env_tf.tf_esp);			
f0105d48:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0105d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d4f:	c7 04 24 48 84 10 f0 	movl   $0xf0108448,(%esp)
f0105d56:	e8 b0 dc ff ff       	call   f0103a0b <cprintf>
				print_native_trapframe((struct NativeTrapframe*)tf);
f0105d5b:	89 1c 24             	mov    %ebx,(%esp)
f0105d5e:	e8 fe fa ff ff       	call   f0105861 <print_native_trapframe>

				//pushing guest user's trapframe on guest kernel stack
				//*((struct Trapframe*)guestOS.env_tf.tf_esp) = *tf;
				memmove( (void*)(guestOS.env_tf.tf_esp - 2*sizeof(struct Trapframe)), (void*)tf, sizeof(struct Trapframe));
f0105d63:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105d6a:	00 
f0105d6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d6f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0105d72:	2d 88 00 00 00       	sub    $0x88,%eax
f0105d77:	89 04 24             	mov    %eax,(%esp)
f0105d7a:	e8 c6 f6 ff ff       	call   f0105445 <memmove>

				// adjusting guest kernel stack pointer i.e esp
				guestOS.env_tf.tf_esp -= sizeof(struct Trapframe);
f0105d7f:	83 6d a8 44          	subl   $0x44,-0x58(%ebp)
			
				print_native_trapframe((struct NativeTrapframe*)tf);
f0105d83:	89 1c 24             	mov    %ebx,(%esp)
f0105d86:	e8 d6 fa ff ff       	call   f0105861 <print_native_trapframe>
f0105d8b:	eb 1b                	jmp    f0105da8 <vmm_trap+0x1bc>
			}			
			else
			{
				cprintf("Normal syscall from guest kernel... Restoring TF & Switching back...\n");	
f0105d8d:	c7 04 24 90 84 10 f0 	movl   $0xf0108490,(%esp)
f0105d94:	e8 72 dc ff ff       	call   f0103a0b <cprintf>
				//print_native_trapframe((struct NativeTrapframe*)tf);
				guestOS.env_tf = *tf;
f0105d99:	8d bd 6c ff ff ff    	lea    -0x94(%ebp),%edi
f0105d9f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105da4:	89 de                	mov    %ebx,%esi
f0105da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			}

			// switching to guest Kernel now.	
			env_run(&guestOS);		
f0105da8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0105dae:	89 04 24             	mov    %eax,(%esp)
f0105db1:	e8 29 d3 ff ff       	call   f01030df <env_run>
			//curenv->env_status = ENV_NOT_RUNNABLE;
			print_native_trapframe((struct NativeTrapframe*)tf);
			panic("vmm panic\n");
		}
//	}
		else if(tf->tf_trapno == 32)
f0105db6:	83 f8 20             	cmp    $0x20,%eax
f0105db9:	75 52                	jne    f0105e0d <vmm_trap+0x221>
			/*
				thought on timer interrupt, it should sched_yield() and switch to host kernel
				However, we keep sending it to guest OS for proof of concept.

 			*/
			if(timer_count == 10)
f0105dbb:	83 3d c8 42 1e f0 0a 	cmpl   $0xa,0xf01e42c8
f0105dc2:	75 11                	jne    f0105dd5 <vmm_trap+0x1e9>
			{
				cprintf("Switching back to Host Machine...\nSuspending virtual machine...");
f0105dc4:	c7 04 24 d8 84 10 f0 	movl   $0xf01084d8,(%esp)
f0105dcb:	e8 3b dc ff ff       	call   f0103a0b <cprintf>
				vmm_suspend();
f0105dd0:	e8 ee fd ff ff       	call   f0105bc3 <vmm_suspend>
			}
			timer_count++;
f0105dd5:	83 05 c8 42 1e f0 01 	addl   $0x1,0xf01e42c8
			cprintf("vmm.c: Timer interrupt...switching back to guest kernel\ncurrent Trapframe:\n");			
f0105ddc:	c7 04 24 18 85 10 f0 	movl   $0xf0108518,(%esp)
f0105de3:	e8 23 dc ff ff       	call   f0103a0b <cprintf>
			guestOS.env_tf = *tf;
f0105de8:	8d bd 6c ff ff ff    	lea    -0x94(%ebp),%edi
f0105dee:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105df3:	89 de                	mov    %ebx,%esi
f0105df5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			print_native_trapframe((struct NativeTrapframe*)tf);
f0105df7:	89 1c 24             	mov    %ebx,(%esp)
f0105dfa:	e8 62 fa ff ff       	call   f0105861 <print_native_trapframe>
			env_run(&guestOS);		
f0105dff:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0105e05:	89 04 24             	mov    %eax,(%esp)
f0105e08:	e8 d2 d2 ff ff       	call   f01030df <env_run>
		}
		else
			panic("vmm.c: Page fault or General Protection Fault.\n");	
f0105e0d:	c7 44 24 08 64 85 10 	movl   $0xf0108564,0x8(%esp)
f0105e14:	f0 
f0105e15:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0105e1c:	00 
f0105e1d:	c7 04 24 1a 82 10 f0 	movl   $0xf010821a,(%esp)
f0105e24:	e8 5c a2 ff ff       	call   f0100085 <_panic>
f0105e29:	00 00                	add    %al,(%eax)
	...

f0105e2c <VMM_DivideByZero>:

/*
; VMM_TRAPHANDLER_NOEC(vmm_vmmsyscall, VMM_SYSCALL)
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 VMM_TRAPHANDLER_NOEC(VMM_DivideByZero,T_DIVIDE)
f0105e2c:	6a 00                	push   $0x0
f0105e2e:	6a 00                	push   $0x0
f0105e30:	eb 3e                	jmp    f0105e70 <_vmm_alltraps>

f0105e32 <VMM_BadSegment>:
 VMM_TRAPHANDLER(VMM_BadSegment,T_GPFLT)
f0105e32:	6a 0d                	push   $0xd
f0105e34:	eb 3a                	jmp    f0105e70 <_vmm_alltraps>

f0105e36 <VMM_PageFault>:
 VMM_TRAPHANDLER(VMM_PageFault, T_PGFLT)
f0105e36:	6a 0e                	push   $0xe
f0105e38:	eb 36                	jmp    f0105e70 <_vmm_alltraps>

f0105e3a <VMM_BreakPoint>:
 VMM_TRAPHANDLER_NOEC(VMM_BreakPoint, T_BRKPT)
f0105e3a:	6a 00                	push   $0x0
f0105e3c:	6a 03                	push   $0x3
f0105e3e:	eb 30                	jmp    f0105e70 <_vmm_alltraps>

f0105e40 <vmm_vmmsyscall>:
 VMM_TRAPHANDLER_NOEC(vmm_vmmsyscall, T_SYSCALL)
f0105e40:	6a 00                	push   $0x0
f0105e42:	6a 30                	push   $0x30
f0105e44:	eb 2a                	jmp    f0105e70 <_vmm_alltraps>

f0105e46 <VMM_irq_timer>:


VMM_TRAPHANDLER_NOEC(VMM_irq_timer, IRQ_OFFSET + IRQ_TIMER)
f0105e46:	6a 00                	push   $0x0
f0105e48:	6a 20                	push   $0x20
f0105e4a:	eb 24                	jmp    f0105e70 <_vmm_alltraps>

f0105e4c <VMM_irq_kbd>:
VMM_TRAPHANDLER_NOEC(VMM_irq_kbd, IRQ_OFFSET + IRQ_KBD)
f0105e4c:	6a 00                	push   $0x0
f0105e4e:	6a 21                	push   $0x21
f0105e50:	eb 1e                	jmp    f0105e70 <_vmm_alltraps>

f0105e52 <VMM_irq_slave>:
VMM_TRAPHANDLER_NOEC(VMM_irq_slave, IRQ_OFFSET + IRQ_SLAVE)
f0105e52:	6a 00                	push   $0x0
f0105e54:	6a 22                	push   $0x22
f0105e56:	eb 18                	jmp    f0105e70 <_vmm_alltraps>

f0105e58 <VMM_irq_ide>:
VMM_TRAPHANDLER_NOEC(VMM_irq_ide, IRQ_OFFSET + IRQ_IDE)
f0105e58:	6a 00                	push   $0x0
f0105e5a:	6a 2e                	push   $0x2e
f0105e5c:	eb 12                	jmp    f0105e70 <_vmm_alltraps>

f0105e5e <VMM_irq_error>:
VMM_TRAPHANDLER_NOEC(VMM_irq_error, IRQ_OFFSET + IRQ_ERROR)
f0105e5e:	6a 00                	push   $0x0
f0105e60:	6a 33                	push   $0x33
f0105e62:	eb 0c                	jmp    f0105e70 <_vmm_alltraps>

f0105e64 <VMM_irq_spurious>:
VMM_TRAPHANDLER_NOEC(VMM_irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f0105e64:	6a 00                	push   $0x0
f0105e66:	6a 27                	push   $0x27
f0105e68:	eb 06                	jmp    f0105e70 <_vmm_alltraps>

f0105e6a <VMM_irq_serial>:
VMM_TRAPHANDLER_NOEC(VMM_irq_serial, IRQ_OFFSET + IRQ_SERIAL)
f0105e6a:	6a 00                	push   $0x0
f0105e6c:	6a 24                	push   $0x24
f0105e6e:	eb 00                	jmp    f0105e70 <_vmm_alltraps>

f0105e70 <_vmm_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_vmm_alltraps:
		pushl %ds
f0105e70:	1e                   	push   %ds
		pushl %es
f0105e71:	06                   	push   %es
		pushal
f0105e72:	60                   	pusha  
		movl $GD_KD, %eax
f0105e73:	b8 10 00 00 00       	mov    $0x10,%eax
		movl %eax,%ds
f0105e78:	8e d8                	mov    %eax,%ds
		movl %eax,%es
f0105e7a:	8e c0                	mov    %eax,%es
		pushl %esp
f0105e7c:	54                   	push   %esp
		call vmm_trap
f0105e7d:	e8 6a fd ff ff       	call   f0105bec <vmm_trap>
	...

f0105e90 <Env_map_segment>:
}


static void
Env_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0105e90:	55                   	push   %ebp
f0105e91:	89 e5                	mov    %esp,%ebp
f0105e93:	57                   	push   %edi
f0105e94:	56                   	push   %esi
f0105e95:	53                   	push   %ebx
f0105e96:	83 ec 2c             	sub    $0x2c,%esp
f0105e99:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105e9c:	89 d3                	mov    %edx,%ebx
f0105e9e:	8b 7d 08             	mov    0x8(%ebp),%edi

        //cprintf("\n in Env_map_segment\n");
        //cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
f0105ea1:	c1 e9 0c             	shr    $0xc,%ecx
f0105ea4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0105ea7:	85 c9                	test   %ecx,%ecx
f0105ea9:	74 54                	je     f0105eff <Env_map_segment+0x6f>
f0105eab:	be 00 00 00 00       	mov    $0x0,%esi
                {
                        cprintf("could not allocate page table in Env_map_segment()!!\n");
                        return;
                }
                //cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
f0105eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105eb3:	83 c8 01             	or     $0x1,%eax
f0105eb6:	89 45 dc             	mov    %eax,-0x24(%ebp)
        //cprintf("\n in Env_map_segment\n");
        //cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
        {
                pte_t *pte = pgdir_walk(pgdir, (void*)la, 1);
f0105eb9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105ec0:	00 
f0105ec1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ec8:	89 04 24             	mov    %eax,(%esp)
f0105ecb:	e8 1f b3 ff ff       	call   f01011ef <pgdir_walk>
                if(pte == NULL)
f0105ed0:	85 c0                	test   %eax,%eax
f0105ed2:	75 0e                	jne    f0105ee2 <Env_map_segment+0x52>
                {
                        cprintf("could not allocate page table in Env_map_segment()!!\n");
f0105ed4:	c7 04 24 04 79 10 f0 	movl   $0xf0107904,(%esp)
f0105edb:	e8 2b db ff ff       	call   f0103a0b <cprintf>
                        return;
f0105ee0:	eb 1d                	jmp    f0105eff <Env_map_segment+0x6f>
                }
                //cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
f0105ee2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105ee5:	09 fa                	or     %edi,%edx
f0105ee7:	89 10                	mov    %edx,(%eax)
{

        //cprintf("\n in Env_map_segment\n");
        //cprintf("la %x, pa %x\n",la, pa);
        int i;
        for(i =0;i<(size/PGSIZE);i++)
f0105ee9:	83 c6 01             	add    $0x1,%esi
f0105eec:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0105eef:	73 0e                	jae    f0105eff <Env_map_segment+0x6f>
                        return;
                }
                //cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                *pte = pa | PTE_P | perm;
                //cprintf("*pte: %x ,pte: %x\n",*pte, pte);
                la+=PGSIZE;
f0105ef1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
                pa+=PGSIZE;
f0105ef7:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0105efd:	eb ba                	jmp    f0105eb9 <Env_map_segment+0x29>
        }
}
f0105eff:	83 c4 2c             	add    $0x2c,%esp
f0105f02:	5b                   	pop    %ebx
f0105f03:	5e                   	pop    %esi
f0105f04:	5f                   	pop    %edi
f0105f05:	5d                   	pop    %ebp
f0105f06:	c3                   	ret    

f0105f07 <vmm_segment_alloc>:
	panic("sys_page_map not implemented");
}

static void
vmm_segment_alloc(struct Env *e, void *va, size_t len)
{	
f0105f07:	55                   	push   %ebp
f0105f08:	89 e5                	mov    %esp,%ebp
f0105f0a:	57                   	push   %edi
f0105f0b:	56                   	push   %esi
f0105f0c:	53                   	push   %ebx
f0105f0d:	83 ec 3c             	sub    $0x3c,%esp
f0105f10:	89 c6                	mov    %eax,%esi
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
f0105f12:	89 d3                	mov    %edx,%ebx
f0105f14:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
f0105f1a:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
f0105f21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105f26:	29 d8                	sub    %ebx,%eax
f0105f28:	c1 e8 0c             	shr    $0xc,%eax
f0105f2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	struct Page *pg;
	for(i=0;i<numPages;i++)
f0105f2e:	85 c0                	test   %eax,%eax
f0105f30:	0f 84 8b 00 00 00    	je     f0105fc1 <vmm_segment_alloc+0xba>

static void
vmm_segment_alloc(struct Env *e, void *va, size_t len)
{	
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
f0105f36:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
page_map(struct Env* srcenv, void *srcva,
	     struct Env* dstenv, void *dstva, int perm)
{

	pte_t* src_pte;
	struct Page *p = page_lookup(srcenv->env_pgdir, srcva, &src_pte);
f0105f3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105f40:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f48:	a1 e4 43 1e f0       	mov    0xf01e43e4,%eax
f0105f4d:	8b 40 5c             	mov    0x5c(%eax),%eax
f0105f50:	89 04 24             	mov    %eax,(%esp)
f0105f53:	e8 f4 b4 ff ff       	call   f010144c <page_lookup>
f0105f58:	89 c7                	mov    %eax,%edi
	cprintf("%x %x\n", srcva, dstva);
f0105f5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f62:	c7 04 24 c5 7b 10 f0 	movl   $0xf0107bc5,(%esp)
f0105f69:	e8 9d da ff ff       	call   f0103a0b <cprintf>
		return -E_INVAL;
	}
	//cprintf("1\n");
        if ((perm & PTE_W) && !((int)(*src_pte) & PTE_W))
                return -E_INVAL;*/
	if(page_insert(dstenv->env_pgdir, p, dstva, perm) == -E_NO_MEM)
f0105f6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0105f75:	00 
f0105f76:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f7e:	8b 46 5c             	mov    0x5c(%esi),%eax
f0105f81:	89 04 24             	mov    %eax,(%esp)
f0105f84:	e8 a5 b5 ff ff       	call   f010152e <page_insert>
f0105f89:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0105f8c:	75 1c                	jne    f0105faa <vmm_segment_alloc+0xa3>
	//	cprintf("mapped %x\n", start);
	//	if(page_insert(e->env_pgdir, pg, start, PTE_P|PTE_U|PTE_W)<0)
	//	{
		if(page_map(KERN_ENV, start, e, start, PTE_P|PTE_U|PTE_W))
		{
			panic("could not allocate memory to user environment\n");	
f0105f8e:	c7 44 24 08 d4 78 10 	movl   $0xf01078d4,0x8(%esp)
f0105f95:	f0 
f0105f96:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0105f9d:	00 
f0105f9e:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f0105fa5:	e8 db a0 ff ff       	call   f0100085 <_panic>
	int i;
        void* start  =(void*) ROUNDDOWN((uint32_t)va,PGSIZE);
        void* end = (void*) ROUNDUP(((uint32_t)va+len), PGSIZE);
        uint32_t numPages = ((uint32_t)end - (uint32_t)start) / PGSIZE;
	struct Page *pg;
	for(i=0;i<numPages;i++)
f0105faa:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0105fae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105fb1:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0105fb4:	73 0b                	jae    f0105fc1 <vmm_segment_alloc+0xba>
	//	{
		if(page_map(KERN_ENV, start, e, start, PTE_P|PTE_U|PTE_W))
		{
			panic("could not allocate memory to user environment\n");	
		}
		start += PGSIZE;
f0105fb6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0105fbc:	e9 7c ff ff ff       	jmp    f0105f3d <vmm_segment_alloc+0x36>
	}
}
f0105fc1:	83 c4 3c             	add    $0x3c,%esp
f0105fc4:	5b                   	pop    %ebx
f0105fc5:	5e                   	pop    %esi
f0105fc6:	5f                   	pop    %edi
f0105fc7:	5d                   	pop    %ebp
f0105fc8:	c3                   	ret    

f0105fc9 <vmm_syscall1>:
	panic("iret failed");   //mostly to placate the compiler
}

int32_t
vmm_syscall1(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105fc9:	55                   	push   %ebp
f0105fca:	89 e5                	mov    %esp,%ebp
f0105fcc:	81 ec 88 00 00 00    	sub    $0x88,%esp
f0105fd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105fd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105fd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105fdb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105fe1:	8b 75 10             	mov    0x10(%ebp),%esi
f0105fe4:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Return any appropriate return value.
	// LAB 3: Your code here.
	
	int32_t ret = 0; 

	if(syscallno >= 0 && syscallno < NSYSCALLS)
f0105fe7:	83 f8 0d             	cmp    $0xd,%eax
f0105fea:	0f 87 2a 05 00 00    	ja     f010651a <vmm_syscall1+0x551>
        {
		switch(syscallno)
f0105ff0:	83 f8 05             	cmp    $0x5,%eax
f0105ff3:	0f 87 28 05 00 00    	ja     f0106521 <vmm_syscall1+0x558>
f0105ff9:	ff 24 85 f0 85 10 f0 	jmp    *-0xfef7a10(,%eax,4)
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	
        envid_t ev = sys_getenvid();
	user_mem_assert(&envs[ENVX(ev)], (void *)s, len, PTE_P);
f0106000:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
f0106007:	00 
f0106008:	89 74 24 08          	mov    %esi,0x8(%esp)
f010600c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106010:	a1 c4 25 1e f0       	mov    0xf01e25c4,%eax
f0106015:	8b 40 4c             	mov    0x4c(%eax),%eax
f0106018:	25 ff 03 00 00       	and    $0x3ff,%eax
f010601d:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0106020:	03 05 c0 25 1e f0    	add    0xf01e25c0,%eax
f0106026:	89 04 24             	mov    %eax,(%esp)
f0106029:	e8 c6 b3 ff ff       	call   f01013f4 <user_mem_assert>
			unsigned int i = inb(IO_TIMER1);
			cprintf("timer: %d\n",i); 
//		}
	}*/
//end of code for timer check
	cprintf("%.*s", len, s);
f010602e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106032:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106036:	c7 04 24 22 7e 10 f0 	movl   $0xf0107e22,(%esp)
f010603d:	e8 c9 d9 ff ff       	call   f0103a0b <cprintf>
f0106042:	b8 00 00 00 00       	mov    $0x0,%eax
f0106047:	e9 da 04 00 00       	jmp    f0106526 <vmm_syscall1+0x55d>
static int 
vmm_sys_env_setup_vm(void* e_addr)
{
//	cprintf("getting %x to set up\n", e_addr);
	int i, r;
	struct Page* p = NULL;
f010604c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	if((r = page_alloc(&p)) < 0)
f0106053:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106056:	89 04 24             	mov    %eax,(%esp)
f0106059:	e8 41 b1 ff ff       	call   f010119f <page_alloc>
f010605e:	85 c0                	test   %eax,%eax
f0106060:	0f 88 bb 04 00 00    	js     f0106521 <vmm_syscall1+0x558>
f0106066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106069:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f010606f:	c1 f8 02             	sar    $0x2,%eax
f0106072:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0106078:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010607b:	89 c2                	mov    %eax,%edx
f010607d:	c1 ea 0c             	shr    $0xc,%edx
f0106080:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f0106086:	72 20                	jb     f01060a8 <vmm_syscall1+0xdf>
f0106088:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010608c:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f0106093:	f0 
f0106094:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010609b:	00 
f010609c:	c7 04 24 7a 6b 10 f0 	movl   $0xf0106b7a,(%esp)
f01060a3:	e8 dd 9f ff ff       	call   f0100085 <_panic>
		return r;
	struct Env *e = (struct Env*) e_addr;
	e->env_pgdir = page2kva(p);	
f01060a8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01060ad:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_cr3 = page2pa(p);
f01060b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060b3:	89 c2                	mov    %eax,%edx
f01060b5:	2b 15 9c 43 1e f0    	sub    0xf01e439c,%edx
f01060bb:	c1 fa 02             	sar    $0x2,%edx
f01060be:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01060c4:	c1 e2 0c             	shl    $0xc,%edx
f01060c7:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f01060ca:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	memset(e->env_pgdir, 0, PGSIZE);
f01060cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01060d6:	00 
f01060d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01060de:	00 
f01060df:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01060e2:	89 04 24             	mov    %eax,(%esp)
f01060e5:	e8 fc f2 ff ff       	call   f01053e6 <memset>

 	Env_map_segment(e->env_pgdir, UPAGES, ROUNDUP(npage*sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U | PTE_P);
f01060ea:	8b 15 9c 43 1e f0    	mov    0xf01e439c,%edx
f01060f0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01060f6:	77 20                	ja     f0106118 <vmm_syscall1+0x14f>
f01060f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01060fc:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0106103:	f0 
f0106104:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010610b:	00 
f010610c:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f0106113:	e8 6d 9f ff ff       	call   f0100085 <_panic>
f0106118:	a1 90 43 1e f0       	mov    0xf01e4390,%eax
f010611d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0106120:	8d 0c 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%ecx
f0106127:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010612d:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0106130:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0106137:	00 
f0106138:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010613e:	89 14 24             	mov    %edx,(%esp)
f0106141:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0106146:	e8 45 fd ff ff       	call   f0105e90 <Env_map_segment>
        Env_map_segment(e->env_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f010614b:	8b 15 c0 25 1e f0    	mov    0xf01e25c0,%edx
f0106151:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106157:	77 20                	ja     f0106179 <vmm_syscall1+0x1b0>
f0106159:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010615d:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f0106164:	f0 
f0106165:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f010616c:	00 
f010616d:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f0106174:	e8 0c 9f ff ff       	call   f0100085 <_panic>
f0106179:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010617c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0106183:	00 
f0106184:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010618a:	89 14 24             	mov    %edx,(%esp)
f010618d:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0106192:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0106197:	e8 f4 fc ff ff       	call   f0105e90 <Env_map_segment>
        Env_map_segment(e->env_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P| PTE_W);
f010619c:	ba 00 70 11 f0       	mov    $0xf0117000,%edx
f01061a1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01061a7:	77 20                	ja     f01061c9 <vmm_syscall1+0x200>
f01061a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01061ad:	c7 44 24 08 9c 6e 10 	movl   $0xf0106e9c,0x8(%esp)
f01061b4:	f0 
f01061b5:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01061bc:	00 
f01061bd:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f01061c4:	e8 bc 9e ff ff       	call   f0100085 <_panic>
f01061c9:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01061cc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01061d3:	00 
f01061d4:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01061da:	89 14 24             	mov    %edx,(%esp)
f01061dd:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01061e2:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01061e7:	e8 a4 fc ff ff       	call   f0105e90 <Env_map_segment>
        Env_map_segment(e->env_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_P| PTE_W);
f01061ec:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01061ef:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01061f6:	00 
f01061f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01061fe:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0106203:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0106208:	e8 83 fc ff ff       	call   f0105e90 <Env_map_segment>

	e->env_pgdir[PDX(VPT)] = e->env_cr3 | PTE_P | PTE_W;
f010620d:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0106210:	8b 53 60             	mov    0x60(%ebx),%edx
f0106213:	83 ca 03             	or     $0x3,%edx
f0106216:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f010621c:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010621f:	8b 53 60             	mov    0x60(%ebx),%edx
f0106222:	83 ca 05             	or     $0x5,%edx
f0106225:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
f010622b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106230:	e9 f1 02 00 00       	jmp    f0106526 <vmm_syscall1+0x55d>


static int
vmm_sys_lcr3(uint32_t cr3)
{
	cprintf("loading cr3: %x\n", cr3);
f0106235:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106239:	c7 04 24 a7 85 10 f0 	movl   $0xf01085a7,(%esp)
f0106240:	e8 c6 d7 ff ff       	call   f0103a0b <cprintf>
f0106245:	0f 22 db             	mov    %ebx,%cr3
	lcr3(cr3);
	cprintf("loaded cr3\n");
f0106248:	c7 04 24 b8 85 10 f0 	movl   $0xf01085b8,(%esp)
f010624f:	e8 b7 d7 ff ff       	call   f0103a0b <cprintf>
f0106254:	b8 00 00 00 00       	mov    $0x0,%eax
			case VMM_SYS_env_setup_vm:
				vmm_sys_env_setup_vm((void*) a1);
				break;
			case VMM_SYS_lcr3:;
				vmm_sys_lcr3(a1);
				break;
f0106259:	e9 c8 02 00 00       	jmp    f0106526 <vmm_syscall1+0x55d>
}

static int
vmm_sys_page_alloc(envid_t envid, struct Env* e, void *va, int perm)
{
        if(envid != -1)
f010625e:	83 fb ff             	cmp    $0xffffffff,%ebx
f0106261:	0f 85 ba 02 00 00    	jne    f0106521 <vmm_syscall1+0x558>
        {
                return -E_BAD_ENV;
        }

        if(((uint32_t)va >= UTOP) || (((uint32_t)va & 0xfff) !=0) || ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) )
f0106267:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010626d:	8d 76 00             	lea    0x0(%esi),%esi
f0106270:	0f 87 ab 02 00 00    	ja     f0106521 <vmm_syscall1+0x558>
f0106276:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010627c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106280:	0f 85 9b 02 00 00    	jne    f0106521 <vmm_syscall1+0x558>
				break;
			case VMM_SYS_lcr3:;
				vmm_sys_lcr3(a1);
				break;
                        case VMM_SYS_page_alloc:
                                vmm_sys_page_alloc(a1, (struct Env*) a2, (void*)a3, a4);
f0106286:	8b 5d 18             	mov    0x18(%ebp),%ebx
        if(envid != -1)
        {
                return -E_BAD_ENV;
        }

        if(((uint32_t)va >= UTOP) || (((uint32_t)va & 0xfff) !=0) || ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) )
f0106289:	89 d8                	mov    %ebx,%eax
f010628b:	83 e0 05             	and    $0x5,%eax
f010628e:	83 f8 05             	cmp    $0x5,%eax
f0106291:	0f 85 8a 02 00 00    	jne    f0106521 <vmm_syscall1+0x558>
        {
                return -E_INVAL;
        }

        struct Page *p;
        if(page_alloc(&p) == -E_NO_MEM)
f0106297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010629a:	89 04 24             	mov    %eax,(%esp)
f010629d:	e8 fd ae ff ff       	call   f010119f <page_alloc>
f01062a2:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01062a5:	0f 84 76 02 00 00    	je     f0106521 <vmm_syscall1+0x558>
        {
                return -E_NO_MEM;
        }
        if(page_insert(e->env_pgdir, p, va, perm) == -E_NO_MEM)
f01062ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01062af:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01062b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062ba:	8b 46 5c             	mov    0x5c(%esi),%eax
f01062bd:	89 04 24             	mov    %eax,(%esp)
f01062c0:	e8 69 b2 ff ff       	call   f010152e <page_insert>
f01062c5:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01062c8:	75 15                	jne    f01062df <vmm_syscall1+0x316>
        {
                page_free(p);
f01062ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062cd:	89 04 24             	mov    %eax,(%esp)
f01062d0:	e8 11 ac ff ff       	call   f0100ee6 <page_free>
f01062d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01062da:	e9 47 02 00 00       	jmp    f0106526 <vmm_syscall1+0x55d>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01062df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062e2:	2b 05 9c 43 1e f0    	sub    0xf01e439c,%eax
f01062e8:	c1 f8 02             	sar    $0x2,%eax
f01062eb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01062f1:	c1 e0 0c             	shl    $0xc,%eax
                return -E_NO_MEM;
        }
        void *page_start_va = KADDR(page2pa(p));
f01062f4:	89 c2                	mov    %eax,%edx
f01062f6:	c1 ea 0c             	shr    $0xc,%edx
f01062f9:	3b 15 90 43 1e f0    	cmp    0xf01e4390,%edx
f01062ff:	72 20                	jb     f0106321 <vmm_syscall1+0x358>
f0106301:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106305:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f010630c:	f0 
f010630d:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
f0106314:	00 
f0106315:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f010631c:	e8 64 9d ff ff       	call   f0100085 <_panic>
        memset(page_start_va, 0, PGSIZE);
f0106321:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0106328:	00 
f0106329:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0106330:	00 
f0106331:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0106336:	89 04 24             	mov    %eax,(%esp)
f0106339:	e8 a8 f0 ff ff       	call   f01053e6 <memset>
f010633e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106343:	e9 de 01 00 00       	jmp    f0106526 <vmm_syscall1+0x55d>
}

static int
vmm_sys_load_icode(void* en, void* b, int len)
{
	cprintf("in vmm_sys_lod_icode\n");
f0106348:	c7 04 24 c4 85 10 f0 	movl   $0xf01085c4,(%esp)
f010634f:	e8 b7 d6 ff ff       	call   f0103a0b <cprintf>
	struct Env* e = (struct Env*)en;
	//cprintf("kern: %x %x", KERN_ENV, KERN_CR3);
        struct Proghdr *ph, *eph;
        struct Elf *ELFHDR = (struct Elf *)b;
f0106354:	89 75 94             	mov    %esi,-0x6c(%ebp)
	cprintf("%x\n", ELFHDR->e_entry);
f0106357:	8b 46 18             	mov    0x18(%esi),%eax
f010635a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010635e:	c7 04 24 b4 85 10 f0 	movl   $0xf01085b4,(%esp)
f0106365:	e8 a1 d6 ff ff       	call   f0103a0b <cprintf>
        if(ELFHDR->e_magic != ELF_MAGIC)
f010636a:	8b 45 94             	mov    -0x6c(%ebp),%eax
f010636d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0106373:	74 1c                	je     f0106391 <vmm_syscall1+0x3c8>
        {
                panic("Process Load Error: Not a valid elf");
f0106375:	c7 44 24 08 9c 79 10 	movl   $0xf010799c,0x8(%esp)
f010637c:	f0 
f010637d:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0106384:	00 
f0106385:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f010638c:	e8 f4 9c ff ff       	call   f0100085 <_panic>

static int
vmm_sys_load_icode(void* en, void* b, int len)
{
	cprintf("in vmm_sys_lod_icode\n");
	struct Env* e = (struct Env*)en;
f0106391:	89 df                	mov    %ebx,%edi
	cprintf("%x\n", ELFHDR->e_entry);
        if(ELFHDR->e_magic != ELF_MAGIC)
        {
                panic("Process Load Error: Not a valid elf");
        }
        ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0106393:	8b 5d 94             	mov    -0x6c(%ebp),%ebx
f0106396:	03 5b 1c             	add    0x1c(%ebx),%ebx
        eph = ph + ELFHDR->e_phnum;
f0106399:	8b 55 94             	mov    -0x6c(%ebp),%edx
f010639c:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi
f01063a0:	c1 e6 05             	shl    $0x5,%esi
f01063a3:	8d 34 33             	lea    (%ebx,%esi,1),%esi

        for (; ph < eph; ph++)
f01063a6:	39 f3                	cmp    %esi,%ebx
f01063a8:	73 39                	jae    f01063e3 <vmm_syscall1+0x41a>
	{
		if(ph->p_type == ELF_PROG_LOAD)
f01063aa:	83 3b 01             	cmpl   $0x1,(%ebx)
f01063ad:	75 2d                	jne    f01063dc <vmm_syscall1+0x413>
		{
			if(ph->p_type > ph->p_memsz)
f01063af:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01063b2:	85 c9                	test   %ecx,%ecx
f01063b4:	75 1c                	jne    f01063d2 <vmm_syscall1+0x409>
			    panic("\n Panic in loa_icode\n");
f01063b6:	c7 44 24 08 bb 78 10 	movl   $0xf01078bb,0x8(%esp)
f01063bd:	f0 
f01063be:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f01063c5:	00 
f01063c6:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f01063cd:	e8 b3 9c ff ff       	call   f0100085 <_panic>
			vmm_segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01063d2:	8b 53 08             	mov    0x8(%ebx),%edx
f01063d5:	89 f8                	mov    %edi,%eax
f01063d7:	e8 2b fb ff ff       	call   f0105f07 <vmm_segment_alloc>
                panic("Process Load Error: Not a valid elf");
        }
        ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
        eph = ph + ELFHDR->e_phnum;

        for (; ph < eph; ph++)
f01063dc:	83 c3 20             	add    $0x20,%ebx
f01063df:	39 de                	cmp    %ebx,%esi
f01063e1:	77 c7                	ja     f01063aa <vmm_syscall1+0x3e1>
			//cprintf("suc3\n");
			//memmove((void *)ph->p_va, (void *)(b+ph->p_offset), (size_t)ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
f01063e3:	8b 55 94             	mov    -0x6c(%ebp),%edx
f01063e6:	8b 42 18             	mov    0x18(%edx),%eax
f01063e9:	89 47 30             	mov    %eax,0x30(%edi)
        e->env_tf.tf_ds = GD_UD | 3;
f01063ec:	66 c7 47 24 23 00    	movw   $0x23,0x24(%edi)
        e->env_tf.tf_es = GD_UD | 3;
f01063f2:	66 c7 47 20 23 00    	movw   $0x23,0x20(%edi)
        e->env_tf.tf_ss = GD_UD | 3;
f01063f8:	66 c7 47 40 23 00    	movw   $0x23,0x40(%edi)
        e->env_tf.tf_esp = USTACKTOP;
f01063fe:	c7 47 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%edi)
        e->env_tf.tf_cs = GD_UT | 3;
f0106405:	66 c7 47 34 1b 00    	movw   $0x1b,0x34(%edi)
        e->env_status = ENV_RUNNABLE;
f010640b:	c7 47 54 01 00 00 00 	movl   $0x1,0x54(%edi)
	e->env_tf.tf_eflags |= FL_IF;
f0106412:	81 4f 38 00 02 00 00 	orl    $0x200,0x38(%edi)
	vmm_segment_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0106419:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010641e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0106423:	89 f8                	mov    %edi,%eax
f0106425:	e8 dd fa ff ff       	call   f0105f07 <vmm_segment_alloc>
	cprintf("exiting load_icode\n");
f010642a:	c7 04 24 da 85 10 f0 	movl   $0xf01085da,(%esp)
f0106431:	e8 d5 d5 ff ff       	call   f0103a0b <cprintf>
f0106436:	b8 00 00 00 00       	mov    $0x0,%eax
                        case VMM_SYS_page_alloc:
                                vmm_sys_page_alloc(a1, (struct Env*) a2, (void*)a3, a4);
                                break;
                        case VMM_SYS_load_icode:
                                vmm_sys_load_icode((void*)a1, (void*) a2, a3);
                                break;
f010643b:	e9 e6 00 00 00       	jmp    f0106526 <vmm_syscall1+0x55d>
	{
		cprintf("pgdir[%x]: %x\n", i, phd[i]);
	}
*/
	struct Trapframe tf;
	tf.tf_regs.reg_edi = user_env->env_tf.tf_regs.reg_edi;
f0106440:	8b 03                	mov    (%ebx),%eax
f0106442:	89 45 a0             	mov    %eax,-0x60(%ebp)
	tf.tf_regs.reg_esi = user_env->env_tf.tf_regs.reg_esi;
f0106445:	8b 43 04             	mov    0x4(%ebx),%eax
f0106448:	89 45 a4             	mov    %eax,-0x5c(%ebp)
	tf.tf_regs.reg_ebp = user_env->env_tf.tf_regs.reg_ebp;
f010644b:	8b 43 08             	mov    0x8(%ebx),%eax
f010644e:	89 45 a8             	mov    %eax,-0x58(%ebp)
	tf.tf_regs.reg_oesp = user_env->env_tf.tf_regs.reg_oesp;
f0106451:	8b 43 0c             	mov    0xc(%ebx),%eax
f0106454:	89 45 ac             	mov    %eax,-0x54(%ebp)
	tf.tf_regs.reg_ebx = user_env->env_tf.tf_regs.reg_ebx;
f0106457:	8b 43 10             	mov    0x10(%ebx),%eax
f010645a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	tf.tf_regs.reg_edx = user_env->env_tf.tf_regs.reg_edx;
f010645d:	8b 43 14             	mov    0x14(%ebx),%eax
f0106460:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	tf.tf_regs.reg_ecx = user_env->env_tf.tf_regs.reg_ecx;
f0106463:	8b 43 18             	mov    0x18(%ebx),%eax
f0106466:	89 45 b8             	mov    %eax,-0x48(%ebp)
	tf.tf_regs.reg_eax = user_env->env_tf.tf_regs.reg_eax;
f0106469:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010646c:	89 45 bc             	mov    %eax,-0x44(%ebp)


	tf.tf_es = user_env->env_tf.tf_es;
f010646f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0106473:	66 89 45 c0          	mov    %ax,-0x40(%ebp)
	tf.tf_padding1 = user_env->env_tf.tf_padding1;
f0106477:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010647b:	66 89 45 c2          	mov    %ax,-0x3e(%ebp)
	tf.tf_ds = user_env->env_tf.tf_ds;
f010647f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0106483:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
	tf.tf_padding2 = user_env->env_tf.tf_padding2;
f0106487:	0f b7 43 26          	movzwl 0x26(%ebx),%eax
f010648b:	66 89 45 c6          	mov    %ax,-0x3a(%ebp)
	tf.tf_trapno = user_env->env_tf.tf_trapno;
f010648f:	8b 43 28             	mov    0x28(%ebx),%eax
f0106492:	89 45 c8             	mov    %eax,-0x38(%ebp)
	tf.tf_err = user_env->env_tf.tf_err;
f0106495:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0106498:	89 45 cc             	mov    %eax,-0x34(%ebp)
	tf.tf_eip = user_env->env_tf.tf_eip;
f010649b:	8b 43 30             	mov    0x30(%ebx),%eax
f010649e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	tf.tf_cs = user_env->env_tf.tf_cs;
f01064a1:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01064a5:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
	tf.tf_padding3 = user_env->env_tf.tf_padding3;
f01064a9:	0f b7 43 36          	movzwl 0x36(%ebx),%eax
f01064ad:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
	tf.tf_eflags = user_env->env_tf.tf_eflags;
f01064b1:	8b 43 38             	mov    0x38(%ebx),%eax
f01064b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	tf.tf_esp = user_env->env_tf.tf_esp;
f01064b7:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01064ba:	89 45 dc             	mov    %eax,-0x24(%ebp)
	tf.tf_ss = user_env->env_tf.tf_ss;
f01064bd:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01064c1:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
	tf.tf_padding4 = user_env->env_tf.tf_padding4;
f01064c5:	0f b7 43 42          	movzwl 0x42(%ebx),%eax
f01064c9:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)

	print_trapframe(&user_env->env_tf);
f01064cd:	89 1c 24             	mov    %ebx,(%esp)
f01064d0:	e8 ae d7 ff ff       	call   f0103c83 <print_trapframe>
f01064d5:	8b 43 60             	mov    0x60(%ebx),%eax
f01064d8:	0f 22 d8             	mov    %eax,%cr3
//	cprintf("pgdir: %x cr3: %x\n", user_env->env_pgdir,user_env->env_cr3);
	lcr3(user_env->env_cr3);
	cprintf("%x %x\n", &tf, tf.tf_eip);
f01064db:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01064de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01064e2:	8d 5d a0             	lea    -0x60(%ebp),%ebx
f01064e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01064e9:	c7 04 24 c5 7b 10 f0 	movl   $0xf0107bc5,(%esp)
f01064f0:	e8 16 d5 ff ff       	call   f0103a0b <cprintf>

	asm volatile("movl %0,%%esp\n"
f01064f5:	89 dc                	mov    %ebx,%esp
f01064f7:	61                   	popa   
f01064f8:	07                   	pop    %es
f01064f9:	1f                   	pop    %ds
f01064fa:	83 c4 08             	add    $0x8,%esp
f01064fd:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" //skip tf_trapno and tf_errcode 
		"\tiret"
		: : "g" (&tf) : "memory");
	panic("iret failed");   //mostly to placate the compiler
f01064fe:	c7 44 24 08 84 78 10 	movl   $0xf0107884,0x8(%esp)
f0106505:	f0 
f0106506:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f010650d:	00 
f010650e:	c7 04 24 94 85 10 f0 	movl   $0xf0108594,(%esp)
f0106515:	e8 6b 9b ff ff       	call   f0100085 <_panic>
f010651a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010651f:	eb 05                	jmp    f0106526 <vmm_syscall1+0x55d>
f0106521:	b8 00 00 00 00       	mov    $0x0,%eax
	{
		ret = -E_INVAL;
	}

	return ret;	
}
f0106526:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106529:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010652c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010652f:	89 ec                	mov    %ebp,%esp
f0106531:	5d                   	pop    %ebp
f0106532:	c3                   	ret    
	...

f0106540 <__udivdi3>:
f0106540:	55                   	push   %ebp
f0106541:	89 e5                	mov    %esp,%ebp
f0106543:	57                   	push   %edi
f0106544:	56                   	push   %esi
f0106545:	83 ec 10             	sub    $0x10,%esp
f0106548:	8b 45 14             	mov    0x14(%ebp),%eax
f010654b:	8b 55 08             	mov    0x8(%ebp),%edx
f010654e:	8b 75 10             	mov    0x10(%ebp),%esi
f0106551:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106554:	85 c0                	test   %eax,%eax
f0106556:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0106559:	75 35                	jne    f0106590 <__udivdi3+0x50>
f010655b:	39 fe                	cmp    %edi,%esi
f010655d:	77 61                	ja     f01065c0 <__udivdi3+0x80>
f010655f:	85 f6                	test   %esi,%esi
f0106561:	75 0b                	jne    f010656e <__udivdi3+0x2e>
f0106563:	b8 01 00 00 00       	mov    $0x1,%eax
f0106568:	31 d2                	xor    %edx,%edx
f010656a:	f7 f6                	div    %esi
f010656c:	89 c6                	mov    %eax,%esi
f010656e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0106571:	31 d2                	xor    %edx,%edx
f0106573:	89 f8                	mov    %edi,%eax
f0106575:	f7 f6                	div    %esi
f0106577:	89 c7                	mov    %eax,%edi
f0106579:	89 c8                	mov    %ecx,%eax
f010657b:	f7 f6                	div    %esi
f010657d:	89 c1                	mov    %eax,%ecx
f010657f:	89 fa                	mov    %edi,%edx
f0106581:	89 c8                	mov    %ecx,%eax
f0106583:	83 c4 10             	add    $0x10,%esp
f0106586:	5e                   	pop    %esi
f0106587:	5f                   	pop    %edi
f0106588:	5d                   	pop    %ebp
f0106589:	c3                   	ret    
f010658a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106590:	39 f8                	cmp    %edi,%eax
f0106592:	77 1c                	ja     f01065b0 <__udivdi3+0x70>
f0106594:	0f bd d0             	bsr    %eax,%edx
f0106597:	83 f2 1f             	xor    $0x1f,%edx
f010659a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010659d:	75 39                	jne    f01065d8 <__udivdi3+0x98>
f010659f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01065a2:	0f 86 a0 00 00 00    	jbe    f0106648 <__udivdi3+0x108>
f01065a8:	39 f8                	cmp    %edi,%eax
f01065aa:	0f 82 98 00 00 00    	jb     f0106648 <__udivdi3+0x108>
f01065b0:	31 ff                	xor    %edi,%edi
f01065b2:	31 c9                	xor    %ecx,%ecx
f01065b4:	89 c8                	mov    %ecx,%eax
f01065b6:	89 fa                	mov    %edi,%edx
f01065b8:	83 c4 10             	add    $0x10,%esp
f01065bb:	5e                   	pop    %esi
f01065bc:	5f                   	pop    %edi
f01065bd:	5d                   	pop    %ebp
f01065be:	c3                   	ret    
f01065bf:	90                   	nop
f01065c0:	89 d1                	mov    %edx,%ecx
f01065c2:	89 fa                	mov    %edi,%edx
f01065c4:	89 c8                	mov    %ecx,%eax
f01065c6:	31 ff                	xor    %edi,%edi
f01065c8:	f7 f6                	div    %esi
f01065ca:	89 c1                	mov    %eax,%ecx
f01065cc:	89 fa                	mov    %edi,%edx
f01065ce:	89 c8                	mov    %ecx,%eax
f01065d0:	83 c4 10             	add    $0x10,%esp
f01065d3:	5e                   	pop    %esi
f01065d4:	5f                   	pop    %edi
f01065d5:	5d                   	pop    %ebp
f01065d6:	c3                   	ret    
f01065d7:	90                   	nop
f01065d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01065dc:	89 f2                	mov    %esi,%edx
f01065de:	d3 e0                	shl    %cl,%eax
f01065e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01065e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01065e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01065eb:	89 c1                	mov    %eax,%ecx
f01065ed:	d3 ea                	shr    %cl,%edx
f01065ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01065f3:	0b 55 ec             	or     -0x14(%ebp),%edx
f01065f6:	d3 e6                	shl    %cl,%esi
f01065f8:	89 c1                	mov    %eax,%ecx
f01065fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
f01065fd:	89 fe                	mov    %edi,%esi
f01065ff:	d3 ee                	shr    %cl,%esi
f0106601:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106605:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106608:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010660b:	d3 e7                	shl    %cl,%edi
f010660d:	89 c1                	mov    %eax,%ecx
f010660f:	d3 ea                	shr    %cl,%edx
f0106611:	09 d7                	or     %edx,%edi
f0106613:	89 f2                	mov    %esi,%edx
f0106615:	89 f8                	mov    %edi,%eax
f0106617:	f7 75 ec             	divl   -0x14(%ebp)
f010661a:	89 d6                	mov    %edx,%esi
f010661c:	89 c7                	mov    %eax,%edi
f010661e:	f7 65 e8             	mull   -0x18(%ebp)
f0106621:	39 d6                	cmp    %edx,%esi
f0106623:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106626:	72 30                	jb     f0106658 <__udivdi3+0x118>
f0106628:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010662b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010662f:	d3 e2                	shl    %cl,%edx
f0106631:	39 c2                	cmp    %eax,%edx
f0106633:	73 05                	jae    f010663a <__udivdi3+0xfa>
f0106635:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0106638:	74 1e                	je     f0106658 <__udivdi3+0x118>
f010663a:	89 f9                	mov    %edi,%ecx
f010663c:	31 ff                	xor    %edi,%edi
f010663e:	e9 71 ff ff ff       	jmp    f01065b4 <__udivdi3+0x74>
f0106643:	90                   	nop
f0106644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106648:	31 ff                	xor    %edi,%edi
f010664a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010664f:	e9 60 ff ff ff       	jmp    f01065b4 <__udivdi3+0x74>
f0106654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106658:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010665b:	31 ff                	xor    %edi,%edi
f010665d:	89 c8                	mov    %ecx,%eax
f010665f:	89 fa                	mov    %edi,%edx
f0106661:	83 c4 10             	add    $0x10,%esp
f0106664:	5e                   	pop    %esi
f0106665:	5f                   	pop    %edi
f0106666:	5d                   	pop    %ebp
f0106667:	c3                   	ret    
	...

f0106670 <__umoddi3>:
f0106670:	55                   	push   %ebp
f0106671:	89 e5                	mov    %esp,%ebp
f0106673:	57                   	push   %edi
f0106674:	56                   	push   %esi
f0106675:	83 ec 20             	sub    $0x20,%esp
f0106678:	8b 55 14             	mov    0x14(%ebp),%edx
f010667b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010667e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0106681:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106684:	85 d2                	test   %edx,%edx
f0106686:	89 c8                	mov    %ecx,%eax
f0106688:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010668b:	75 13                	jne    f01066a0 <__umoddi3+0x30>
f010668d:	39 f7                	cmp    %esi,%edi
f010668f:	76 3f                	jbe    f01066d0 <__umoddi3+0x60>
f0106691:	89 f2                	mov    %esi,%edx
f0106693:	f7 f7                	div    %edi
f0106695:	89 d0                	mov    %edx,%eax
f0106697:	31 d2                	xor    %edx,%edx
f0106699:	83 c4 20             	add    $0x20,%esp
f010669c:	5e                   	pop    %esi
f010669d:	5f                   	pop    %edi
f010669e:	5d                   	pop    %ebp
f010669f:	c3                   	ret    
f01066a0:	39 f2                	cmp    %esi,%edx
f01066a2:	77 4c                	ja     f01066f0 <__umoddi3+0x80>
f01066a4:	0f bd ca             	bsr    %edx,%ecx
f01066a7:	83 f1 1f             	xor    $0x1f,%ecx
f01066aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01066ad:	75 51                	jne    f0106700 <__umoddi3+0x90>
f01066af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01066b2:	0f 87 e0 00 00 00    	ja     f0106798 <__umoddi3+0x128>
f01066b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01066bb:	29 f8                	sub    %edi,%eax
f01066bd:	19 d6                	sbb    %edx,%esi
f01066bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01066c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01066c5:	89 f2                	mov    %esi,%edx
f01066c7:	83 c4 20             	add    $0x20,%esp
f01066ca:	5e                   	pop    %esi
f01066cb:	5f                   	pop    %edi
f01066cc:	5d                   	pop    %ebp
f01066cd:	c3                   	ret    
f01066ce:	66 90                	xchg   %ax,%ax
f01066d0:	85 ff                	test   %edi,%edi
f01066d2:	75 0b                	jne    f01066df <__umoddi3+0x6f>
f01066d4:	b8 01 00 00 00       	mov    $0x1,%eax
f01066d9:	31 d2                	xor    %edx,%edx
f01066db:	f7 f7                	div    %edi
f01066dd:	89 c7                	mov    %eax,%edi
f01066df:	89 f0                	mov    %esi,%eax
f01066e1:	31 d2                	xor    %edx,%edx
f01066e3:	f7 f7                	div    %edi
f01066e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01066e8:	f7 f7                	div    %edi
f01066ea:	eb a9                	jmp    f0106695 <__umoddi3+0x25>
f01066ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01066f0:	89 c8                	mov    %ecx,%eax
f01066f2:	89 f2                	mov    %esi,%edx
f01066f4:	83 c4 20             	add    $0x20,%esp
f01066f7:	5e                   	pop    %esi
f01066f8:	5f                   	pop    %edi
f01066f9:	5d                   	pop    %ebp
f01066fa:	c3                   	ret    
f01066fb:	90                   	nop
f01066fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106700:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106704:	d3 e2                	shl    %cl,%edx
f0106706:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106709:	ba 20 00 00 00       	mov    $0x20,%edx
f010670e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0106711:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106714:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106718:	89 fa                	mov    %edi,%edx
f010671a:	d3 ea                	shr    %cl,%edx
f010671c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106720:	0b 55 f4             	or     -0xc(%ebp),%edx
f0106723:	d3 e7                	shl    %cl,%edi
f0106725:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106729:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010672c:	89 f2                	mov    %esi,%edx
f010672e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0106731:	89 c7                	mov    %eax,%edi
f0106733:	d3 ea                	shr    %cl,%edx
f0106735:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106739:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010673c:	89 c2                	mov    %eax,%edx
f010673e:	d3 e6                	shl    %cl,%esi
f0106740:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106744:	d3 ea                	shr    %cl,%edx
f0106746:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010674a:	09 d6                	or     %edx,%esi
f010674c:	89 f0                	mov    %esi,%eax
f010674e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0106751:	d3 e7                	shl    %cl,%edi
f0106753:	89 f2                	mov    %esi,%edx
f0106755:	f7 75 f4             	divl   -0xc(%ebp)
f0106758:	89 d6                	mov    %edx,%esi
f010675a:	f7 65 e8             	mull   -0x18(%ebp)
f010675d:	39 d6                	cmp    %edx,%esi
f010675f:	72 2b                	jb     f010678c <__umoddi3+0x11c>
f0106761:	39 c7                	cmp    %eax,%edi
f0106763:	72 23                	jb     f0106788 <__umoddi3+0x118>
f0106765:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106769:	29 c7                	sub    %eax,%edi
f010676b:	19 d6                	sbb    %edx,%esi
f010676d:	89 f0                	mov    %esi,%eax
f010676f:	89 f2                	mov    %esi,%edx
f0106771:	d3 ef                	shr    %cl,%edi
f0106773:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106777:	d3 e0                	shl    %cl,%eax
f0106779:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010677d:	09 f8                	or     %edi,%eax
f010677f:	d3 ea                	shr    %cl,%edx
f0106781:	83 c4 20             	add    $0x20,%esp
f0106784:	5e                   	pop    %esi
f0106785:	5f                   	pop    %edi
f0106786:	5d                   	pop    %ebp
f0106787:	c3                   	ret    
f0106788:	39 d6                	cmp    %edx,%esi
f010678a:	75 d9                	jne    f0106765 <__umoddi3+0xf5>
f010678c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010678f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0106792:	eb d1                	jmp    f0106765 <__umoddi3+0xf5>
f0106794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106798:	39 f2                	cmp    %esi,%edx
f010679a:	0f 82 18 ff ff ff    	jb     f01066b8 <__umoddi3+0x48>
f01067a0:	e9 1d ff ff ff       	jmp    f01066c2 <__umoddi3+0x52>
