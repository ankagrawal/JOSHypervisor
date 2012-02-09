
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 03 1c 00 00       	call   801c34 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800046:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80004b:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  80004c:	0f b6 d8             	movzbl %al,%ebx
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 c0 00 00 00       	and    $0xc0,%eax
  800056:	83 f8 40             	cmp    $0x40,%eax
  800059:	75 f0                	jne    80004b <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80005b:	85 c9                	test   %ecx,%ecx
  80005d:	74 0a                	je     800069 <ide_wait_ready+0x29>
  80005f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800064:	f6 c3 21             	test   $0x21,%bl
  800067:	75 05                	jne    80006e <ide_wait_ready+0x2e>
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	return 0;
}
  80006e:	5b                   	pop    %ebx
  80006f:	5d                   	pop    %ebp
  800070:	c3                   	ret    

00800071 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800071:	55                   	push   %ebp
  800072:	89 e5                	mov    %esp,%ebp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800074:	b8 00 00 00 00       	mov    $0x0,%eax
  800079:	e8 c2 ff ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80007e:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800083:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800088:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800089:	b2 f7                	mov    $0xf7,%dl
  80008b:	ec                   	in     (%dx),%al

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0; 
  80008c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800091:	a8 a1                	test   $0xa1,%al
  800093:	75 0f                	jne    8000a4 <ide_probe_disk1+0x33>
  800095:	b1 00                	mov    $0x0,%cl
  800097:	eb 10                	jmp    8000a9 <ide_probe_disk1+0x38>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0; 
	     x++)
  800099:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0; 
  80009c:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  8000a2:	74 05                	je     8000a9 <ide_probe_disk1+0x38>
  8000a4:	ec                   	in     (%dx),%al
  8000a5:	a8 a1                	test   $0xa1,%al
  8000a7:	75 f0                	jne    800099 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000a9:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000ae:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000b3:	ee                   	out    %al,(%dx)
  8000b4:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000ba:	0f 9e c0             	setle  %al
  8000bd:	0f b6 c0             	movzbl %al,%eax
	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	//cprintf("Device 1 presence: %d\n", (x < 1000));
	return (x < 1000);
}
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <ide_write>:
	return 0;
}

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 1c             	sub    $0x1c,%esp
  8000cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d1:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;
	
	assert(nsecs <= 256);
  8000d4:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8000da:	76 24                	jbe    800100 <ide_write+0x3e>
  8000dc:	c7 44 24 0c c0 38 80 	movl   $0x8038c0,0xc(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8000eb:	00 
  8000ec:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8000f3:	00 
  8000f4:	c7 04 24 e2 38 80 00 	movl   $0x8038e2,(%esp)
  8000fb:	e8 b8 1b 00 00       	call   801cb8 <_panic>

	ide_wait_ready(0);
  800100:	b8 00 00 00 00       	mov    $0x0,%eax
  800105:	e8 36 ff ff ff       	call   800040 <ide_wait_ready>
  80010a:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80010f:	89 f8                	mov    %edi,%eax
  800111:	ee                   	out    %al,(%dx)
  800112:	b2 f3                	mov    $0xf3,%dl
  800114:	89 f0                	mov    %esi,%eax
  800116:	ee                   	out    %al,(%dx)
  800117:	89 f0                	mov    %esi,%eax
  800119:	c1 e8 08             	shr    $0x8,%eax
  80011c:	b2 f4                	mov    $0xf4,%dl
  80011e:	ee                   	out    %al,(%dx)
  80011f:	89 f0                	mov    %esi,%eax
  800121:	c1 e8 10             	shr    $0x10,%eax
  800124:	b2 f5                	mov    $0xf5,%dl
  800126:	ee                   	out    %al,(%dx)
  800127:	a1 00 70 80 00       	mov    0x807000,%eax
  80012c:	83 e0 01             	and    $0x1,%eax
  80012f:	c1 e0 04             	shl    $0x4,%eax
  800132:	83 c8 e0             	or     $0xffffffe0,%eax
  800135:	c1 ee 18             	shr    $0x18,%esi
  800138:	83 e6 0f             	and    $0xf,%esi
  80013b:	09 f0                	or     %esi,%eax
  80013d:	b2 f6                	mov    $0xf6,%dl
  80013f:	ee                   	out    %al,(%dx)
  800140:	b2 f7                	mov    $0xf7,%dl
  800142:	b8 30 00 00 00       	mov    $0x30,%eax
  800147:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800148:	85 ff                	test   %edi,%edi
  80014a:	74 2a                	je     800176 <ide_write+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  80014c:	b8 01 00 00 00       	mov    $0x1,%eax
  800151:	e8 ea fe ff ff       	call   800040 <ide_wait_ready>
  800156:	85 c0                	test   %eax,%eax
  800158:	78 21                	js     80017b <ide_write+0xb9>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80015a:	89 de                	mov    %ebx,%esi
  80015c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800161:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800166:	fc                   	cld    
  800167:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800169:	83 ef 01             	sub    $0x1,%edi
  80016c:	74 08                	je     800176 <ide_write+0xb4>
  80016e:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800174:	eb d6                	jmp    80014c <ide_write+0x8a>
  800176:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  80017b:	83 c4 1c             	add    $0x1c,%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <ide_read>:
	diskno = d;
}

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 1c             	sub    $0x1c,%esp
  80018c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800192:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800195:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80019b:	76 24                	jbe    8001c1 <ide_read+0x3e>
  80019d:	c7 44 24 0c c0 38 80 	movl   $0x8038c0,0xc(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 e2 38 80 00 	movl   $0x8038e2,(%esp)
  8001bc:	e8 f7 1a 00 00       	call   801cb8 <_panic>

	ide_wait_ready(0);
  8001c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c6:	e8 75 fe ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001cb:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001d0:	89 f0                	mov    %esi,%eax
  8001d2:	ee                   	out    %al,(%dx)
  8001d3:	b2 f3                	mov    $0xf3,%dl
  8001d5:	89 f8                	mov    %edi,%eax
  8001d7:	ee                   	out    %al,(%dx)
  8001d8:	89 f8                	mov    %edi,%eax
  8001da:	c1 e8 08             	shr    $0x8,%eax
  8001dd:	b2 f4                	mov    $0xf4,%dl
  8001df:	ee                   	out    %al,(%dx)
  8001e0:	89 f8                	mov    %edi,%eax
  8001e2:	c1 e8 10             	shr    $0x10,%eax
  8001e5:	b2 f5                	mov    $0xf5,%dl
  8001e7:	ee                   	out    %al,(%dx)
  8001e8:	a1 00 70 80 00       	mov    0x807000,%eax
  8001ed:	83 e0 01             	and    $0x1,%eax
  8001f0:	c1 e0 04             	shl    $0x4,%eax
  8001f3:	83 c8 e0             	or     $0xffffffe0,%eax
  8001f6:	c1 ef 18             	shr    $0x18,%edi
  8001f9:	83 e7 0f             	and    $0xf,%edi
  8001fc:	09 f8                	or     %edi,%eax
  8001fe:	b2 f6                	mov    $0xf6,%dl
  800200:	ee                   	out    %al,(%dx)
  800201:	b2 f7                	mov    $0xf7,%dl
  800203:	b8 20 00 00 00       	mov    $0x20,%eax
  800208:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800209:	85 f6                	test   %esi,%esi
  80020b:	74 2a                	je     800237 <ide_read+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  80020d:	b8 01 00 00 00       	mov    $0x1,%eax
  800212:	e8 29 fe ff ff       	call   800040 <ide_wait_ready>
  800217:	85 c0                	test   %eax,%eax
  800219:	78 21                	js     80023c <ide_read+0xb9>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80021b:	89 df                	mov    %ebx,%edi
  80021d:	b9 80 00 00 00       	mov    $0x80,%ecx
  800222:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800227:	fc                   	cld    
  800228:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80022a:	83 ee 01             	sub    $0x1,%esi
  80022d:	74 08                	je     800237 <ide_read+0xb4>
  80022f:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800235:	eb d6                	jmp    80020d <ide_read+0x8a>
  800237:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}
	
	return 0;
}
  80023c:	83 c4 1c             	add    $0x1c,%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <ide_set_disk>:
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  80024d:	83 f8 01             	cmp    $0x1,%eax
  800250:	76 1c                	jbe    80026e <ide_set_disk+0x2a>
		panic("bad disk number");
  800252:	c7 44 24 08 eb 38 80 	movl   $0x8038eb,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 e2 38 80 00 	movl   $0x8038e2,(%esp)
  800269:	e8 4a 1a 00 00       	call   801cb8 <_panic>
	diskno = d;
  80026e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    
	...

00800280 <va_is_mapped>:
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
	return (vpd[PDX(va)] & PTE_P) && (vpt[VPN(va)] & PTE_P);
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	89 d0                	mov    %edx,%eax
  800288:	c1 e8 16             	shr    $0x16,%eax
  80028b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800292:	b8 00 00 00 00       	mov    $0x0,%eax
  800297:	f6 c1 01             	test   $0x1,%cl
  80029a:	74 0d                	je     8002a9 <va_is_mapped+0x29>
  80029c:	c1 ea 0c             	shr    $0xc,%edx
  80029f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8002a6:	83 e0 01             	and    $0x1,%eax
}
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
	return (vpt[VPN(va)] & PTE_D) != 0;
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	c1 e8 0c             	shr    $0xc,%eax
  8002b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002bb:	c1 e8 06             	shr    $0x6,%eax
  8002be:	83 e0 01             	and    $0x1,%eax
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 18             	sub    $0x18,%esp
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
	//cprintf("blockno %d, super: %x, super->s_nblocks: %d\n", blockno, super, super->s_nblocks);
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	74 0f                	je     8002df <diskaddr+0x1c>
  8002d0:	8b 15 8c b0 80 00    	mov    0x80b08c,%edx
  8002d6:	85 d2                	test   %edx,%edx
  8002d8:	74 25                	je     8002ff <diskaddr+0x3c>
  8002da:	3b 42 04             	cmp    0x4(%edx),%eax
  8002dd:	72 20                	jb     8002ff <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	c7 44 24 08 fc 38 80 	movl   $0x8038fc,0x8(%esp)
  8002ea:	00 
  8002eb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8002f2:	00 
  8002f3:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  8002fa:	e8 b9 19 00 00       	call   801cb8 <_panic>
  8002ff:	05 00 00 01 00       	add    $0x10000,%eax
  800304:	c1 e0 0c             	shl    $0xc,%eax
	return (char*) (DISKMAP + blockno * BLKSIZE);
}
  800307:	c9                   	leave  
  800308:	c3                   	ret    

00800309 <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	56                   	push   %esi
  80030d:	53                   	push   %ebx
  80030e:	83 ec 20             	sub    $0x20,%esp
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800314:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;
//	cprintf("addr: %x (DISKMAP+DISKSIZE) %x\n",addr, DISKMAP+DISKSIZE);
	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800316:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  80031c:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800322:	76 2e                	jbe    800352 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800324:	8b 50 04             	mov    0x4(%eax),%edx
  800327:	89 54 24 14          	mov    %edx,0x14(%esp)
  80032b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80032f:	8b 40 28             	mov    0x28(%eax),%eax
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  80034d:	e8 66 19 00 00       	call   801cb8 <_panic>

	// Allocate a page in the disk map region and read the
	// contents of the block from the disk into that page.
	//
	// LAB 5: Your code here
	if( (r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_W|PTE_U)) < 0)
  800352:	89 de                	mov    %ebx,%esi
  800354:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80035a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800361:	00 
  800362:	89 74 24 04          	mov    %esi,0x4(%esp)
  800366:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80036d:	e8 7c 27 00 00       	call   802aee <sys_page_alloc>
  800372:	85 c0                	test   %eax,%eax
  800374:	79 1c                	jns    800392 <bc_pgfault+0x89>
		panic("page fault could not be alloced\n");
  800376:	c7 44 24 08 50 39 80 	movl   $0x803950,0x8(%esp)
  80037d:	00 
  80037e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800385:	00 
  800386:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  80038d:	e8 26 19 00 00       	call   801cb8 <_panic>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800392:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800398:	c1 eb 0c             	shr    $0xc,%ebx
	// contents of the block from the disk into that page.
	//
	// LAB 5: Your code here
	if( (r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_W|PTE_U)) < 0)
		panic("page fault could not be alloced\n");
	ide_read(blockno*BLKSECTS, ROUNDDOWN(addr, PGSIZE), BLKSECTS); // sector size
  80039b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8003a2:	00 
  8003a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	e8 cd fd ff ff       	call   800183 <ide_read>
	

	// Sanity check the block number. (exercise for the reader:
	// why do we do this *after* reading the block in?)
	if (super && blockno >= super->s_nblocks)
  8003b6:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	74 25                	je     8003e4 <bc_pgfault+0xdb>
  8003bf:	3b 58 04             	cmp    0x4(%eax),%ebx
  8003c2:	72 20                	jb     8003e4 <bc_pgfault+0xdb>
		panic("reading non-existent block %08x\n", blockno);
  8003c4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c8:	c7 44 24 08 74 39 80 	movl   $0x803974,0x8(%esp)
  8003cf:	00 
  8003d0:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8003d7:	00 
  8003d8:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  8003df:	e8 d4 18 00 00       	call   801cb8 <_panic>

	// Check that the block we read was allocated.
	if (bitmap && block_is_free(blockno))
  8003e4:	83 3d 88 b0 80 00 00 	cmpl   $0x0,0x80b088
  8003eb:	74 2c                	je     800419 <bc_pgfault+0x110>
  8003ed:	89 1c 24             	mov    %ebx,(%esp)
  8003f0:	e8 ab 02 00 00       	call   8006a0 <block_is_free>
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	74 20                	je     800419 <bc_pgfault+0x110>
		panic("reading free block %08x\n", blockno);
  8003f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003fd:	c7 44 24 08 c4 39 80 	movl   $0x8039c4,0x8(%esp)
  800404:	00 
  800405:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  80040c:	00 
  80040d:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  800414:	e8 9f 18 00 00       	call   801cb8 <_panic>
}
  800419:	83 c4 20             	add    $0x20,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5e                   	pop    %esi
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_USER constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 28             	sub    $0x28,%esp
  800426:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800429:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80042f:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  800435:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80043a:	76 20                	jbe    80045c <flush_block+0x3c>
		panic("flush_block of bad va %08x", addr);
  80043c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800440:	c7 44 24 08 dd 39 80 	movl   $0x8039dd,0x8(%esp)
  800447:	00 
  800448:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80044f:	00 
  800450:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  800457:	e8 5c 18 00 00       	call   801cb8 <_panic>

	// LAB 5: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(va_is_mapped(addr) && va_is_dirty(addr))
  800464:	89 1c 24             	mov    %ebx,(%esp)
  800467:	e8 14 fe ff ff       	call   800280 <va_is_mapped>
  80046c:	85 c0                	test   %eax,%eax
  80046e:	74 50                	je     8004c0 <flush_block+0xa0>
  800470:	89 1c 24             	mov    %ebx,(%esp)
  800473:	e8 33 fe ff ff       	call   8002ab <va_is_dirty>
  800478:	85 c0                	test   %eax,%eax
  80047a:	74 44                	je     8004c0 <flush_block+0xa0>
	{
		ide_write(blockno*BLKSECTS, addr, BLKSECTS);
  80047c:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800483:	00 
  800484:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800488:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  80048e:	c1 ee 0c             	shr    $0xc,%esi
  800491:	c1 e6 03             	shl    $0x3,%esi
  800494:	89 34 24             	mov    %esi,(%esp)
  800497:	e8 26 fc ff ff       	call   8000c2 <ide_write>
		sys_page_map(0, addr, 0, addr, PTE_USER & ~PTE_D);
  80049c:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8004a3:	00 
  8004a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004bb:	e8 d0 25 00 00       	call   802a90 <sys_page_map>
	}
	return;
	
	panic("flush_block not implemented");
}
  8004c0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004c3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8004c6:	89 ec                	mov    %ebp,%esp
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004da:	e8 e4 fd ff ff       	call   8002c3 <diskaddr>
  8004df:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8004e6:	00 
  8004e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f1:	89 04 24             	mov    %eax,(%esp)
  8004f4:	e8 1c 21 00 00       	call   802615 <memmove>

	// smash it 
	strcpy(diskaddr(1), "OOPS!\n");
  8004f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800500:	e8 be fd ff ff       	call   8002c3 <diskaddr>
  800505:	c7 44 24 04 f8 39 80 	movl   $0x8039f8,0x4(%esp)
  80050c:	00 
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	e8 45 1f 00 00       	call   80245a <strcpy>
	flush_block(diskaddr(1));
  800515:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051c:	e8 a2 fd ff ff       	call   8002c3 <diskaddr>
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	e8 f7 fe ff ff       	call   800420 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800529:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800530:	e8 8e fd ff ff       	call   8002c3 <diskaddr>
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	e8 43 fd ff ff       	call   800280 <va_is_mapped>
  80053d:	85 c0                	test   %eax,%eax
  80053f:	75 24                	jne    800565 <check_bc+0x9b>
  800541:	c7 44 24 0c 1a 3a 80 	movl   $0x803a1a,0xc(%esp)
  800548:	00 
  800549:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  800550:	00 
  800551:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  800558:	00 
  800559:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  800560:	e8 53 17 00 00       	call   801cb8 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800565:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80056c:	e8 52 fd ff ff       	call   8002c3 <diskaddr>
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	e8 32 fd ff ff       	call   8002ab <va_is_dirty>
  800579:	85 c0                	test   %eax,%eax
  80057b:	74 24                	je     8005a1 <check_bc+0xd7>
  80057d:	c7 44 24 0c ff 39 80 	movl   $0x8039ff,0xc(%esp)
  800584:	00 
  800585:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  80058c:	00 
  80058d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800594:	00 
  800595:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  80059c:	e8 17 17 00 00       	call   801cb8 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8005a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a8:	e8 16 fd ff ff       	call   8002c3 <diskaddr>
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005b8:	e8 75 24 00 00       	call   802a32 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005c4:	e8 fa fc ff ff       	call   8002c3 <diskaddr>
  8005c9:	89 04 24             	mov    %eax,(%esp)
  8005cc:	e8 af fc ff ff       	call   800280 <va_is_mapped>
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	74 24                	je     8005f9 <check_bc+0x12f>
  8005d5:	c7 44 24 0c 19 3a 80 	movl   $0x803a19,0xc(%esp)
  8005dc:	00 
  8005dd:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8005e4:	00 
  8005e5:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
  8005ec:	00 
  8005ed:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  8005f4:	e8 bf 16 00 00       	call   801cb8 <_panic>

	// read it back in
	//cprintf("Page faulting??\n");
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800600:	e8 be fc ff ff       	call   8002c3 <diskaddr>
  800605:	c7 44 24 04 f8 39 80 	movl   $0x8039f8,0x4(%esp)
  80060c:	00 
  80060d:	89 04 24             	mov    %eax,(%esp)
  800610:	e8 d4 1e 00 00       	call   8024e9 <strcmp>
  800615:	85 c0                	test   %eax,%eax
  800617:	74 24                	je     80063d <check_bc+0x173>
  800619:	c7 44 24 0c 98 39 80 	movl   $0x803998,0xc(%esp)
  800620:	00 
  800621:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  800628:	00 
  800629:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  800630:	00 
  800631:	c7 04 24 bc 39 80 00 	movl   $0x8039bc,(%esp)
  800638:	e8 7b 16 00 00       	call   801cb8 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80063d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800644:	e8 7a fc ff ff       	call   8002c3 <diskaddr>
  800649:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800650:	00 
  800651:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  800657:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065b:	89 04 24             	mov    %eax,(%esp)
  80065e:	e8 b2 1f 00 00       	call   802615 <memmove>
	flush_block(diskaddr(1));
  800663:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066a:	e8 54 fc ff ff       	call   8002c3 <diskaddr>
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	e8 a9 fd ff ff       	call   800420 <flush_block>

	//cprintf("block cache is good\n");
}
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <bc_init>:

void
bc_init(void)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(bc_pgfault);
  80067f:	c7 04 24 09 03 80 00 	movl   $0x800309,(%esp)
  800686:	e8 89 25 00 00       	call   802c14 <set_pgfault_handler>
	check_bc();
  80068b:	e8 3a fe ff ff       	call   8004ca <check_bc>
}
  800690:	c9                   	leave  
  800691:	c3                   	ret    
	...

008006a0 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	53                   	push   %ebx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (super == 0 || blockno >= super->s_nblocks)
  8006a7:	8b 15 8c b0 80 00    	mov    0x80b08c,%edx
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	74 25                	je     8006d6 <block_is_free+0x36>
  8006b1:	39 42 04             	cmp    %eax,0x4(%edx)
  8006b4:	76 20                	jbe    8006d6 <block_is_free+0x36>
  8006b6:	89 c1                	mov    %eax,%ecx
  8006b8:	83 e1 1f             	and    $0x1f,%ecx
  8006bb:	ba 01 00 00 00       	mov    $0x1,%edx
  8006c0:	d3 e2                	shl    %cl,%edx
  8006c2:	c1 e8 05             	shr    $0x5,%eax
  8006c5:	8b 1d 88 b0 80 00    	mov    0x80b088,%ebx
  8006cb:	85 14 83             	test   %edx,(%ebx,%eax,4)
  8006ce:	0f 95 c0             	setne  %al
  8006d1:	0f b6 c0             	movzbl %al,%eax
  8006d4:	eb 05                	jmp    8006db <block_is_free+0x3b>
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
	{
		return 1;
	}
	return 0;
}
  8006db:	5b                   	pop    %ebx
  8006dc:	5d                   	pop    %ebp
  8006dd:	c3                   	ret    

008006de <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  8006e1:	80 38 2f             	cmpb   $0x2f,(%eax)
  8006e4:	75 08                	jne    8006ee <skip_slash+0x10>
		p++;
  8006e6:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8006e9:	80 38 2f             	cmpb   $0x2f,(%eax)
  8006ec:	74 f8                	je     8006e6 <skip_slash+0x8>
		p++;
	return p;
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <fs_sync>:
}

// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8006f7:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  8006fc:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  800700:	76 2a                	jbe    80072c <fs_sync+0x3c>
  800702:	b8 01 00 00 00       	mov    $0x1,%eax
  800707:	bb 01 00 00 00       	mov    $0x1,%ebx
		flush_block(diskaddr(i));
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	e8 af fb ff ff       	call   8002c3 <diskaddr>
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	e8 04 fd ff ff       	call   800420 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80071c:	83 c3 01             	add    $0x1,%ebx
  80071f:	89 d8                	mov    %ebx,%eax
  800721:	8b 15 8c b0 80 00    	mov    0x80b08c,%edx
  800727:	39 5a 04             	cmp    %ebx,0x4(%edx)
  80072a:	77 e0                	ja     80070c <fs_sync+0x1c>
		flush_block(diskaddr(i));
}
  80072c:	83 c4 14             	add    $0x14,%esp
  80072f:	5b                   	pop    %ebx
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	57                   	push   %edi
  800736:	56                   	push   %esi
  800737:	53                   	push   %ebx
  800738:	83 ec 1c             	sub    $0x1c,%esp
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.	
	int i;
	//cprintf("BLKBITSIZE = %d super->s_nblocks:; %d\n",BLKBITSIZE, super->s_nblocks);
	for (i = 0; i * BLKBITSIZE < (super->s_nblocks * BLKBITSIZE); i++)
  80073b:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  800740:	8b 78 04             	mov    0x4(%eax),%edi
  800743:	c1 e7 0f             	shl    $0xf,%edi
  800746:	85 ff                	test   %edi,%edi
  800748:	74 58                	je     8007a2 <alloc_block+0x70>
  80074a:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
			//cprintf("here2\n");
		if(block_is_free(i))
  80074f:	89 1c 24             	mov    %ebx,(%esp)
  800752:	e8 49 ff ff ff       	call   8006a0 <block_is_free>
  800757:	85 c0                	test   %eax,%eax
  800759:	74 3b                	je     800796 <alloc_block+0x64>
		{
			//cprintf("here1\n");
			bitmap[i/32] &= ~(1<<(i%32));
  80075b:	89 df                	mov    %ebx,%edi
  80075d:	c1 ff 1f             	sar    $0x1f,%edi
  800760:	c1 ef 1b             	shr    $0x1b,%edi
  800763:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
  800766:	89 d0                	mov    %edx,%eax
  800768:	c1 f8 05             	sar    $0x5,%eax
  80076b:	c1 e0 02             	shl    $0x2,%eax
  80076e:	03 05 88 b0 80 00    	add    0x80b088,%eax
  800774:	89 d1                	mov    %edx,%ecx
  800776:	83 e1 1f             	and    $0x1f,%ecx
  800779:	29 f9                	sub    %edi,%ecx
  80077b:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  800780:	d3 c2                	rol    %cl,%edx
  800782:	21 10                	and    %edx,(%eax)
			flush_block((void *)diskaddr(i));
  800784:	89 1c 24             	mov    %ebx,(%esp)
  800787:	e8 37 fb ff ff       	call   8002c3 <diskaddr>
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	e8 8c fc ff ff       	call   800420 <flush_block>
			return i;
  800794:	eb 11                	jmp    8007a7 <alloc_block+0x75>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.	
	int i;
	//cprintf("BLKBITSIZE = %d super->s_nblocks:; %d\n",BLKBITSIZE, super->s_nblocks);
	for (i = 0; i * BLKBITSIZE < (super->s_nblocks * BLKBITSIZE); i++)
  800796:	83 c3 01             	add    $0x1,%ebx
  800799:	89 d8                	mov    %ebx,%eax
  80079b:	c1 e0 0f             	shl    $0xf,%eax
  80079e:	39 f8                	cmp    %edi,%eax
  8007a0:	72 ad                	jb     80074f <alloc_block+0x1d>
  8007a2:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
		}
	}
	//cprintf("retuning from alloc_block\n");
	return -E_NO_DISK;
	panic("alloc_block not implemented");
}
  8007a7:	89 d8                	mov    %ebx,%eax
  8007a9:	83 c4 1c             	add    $0x1c,%esp
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5f                   	pop    %edi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <free_block>:
}

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8007ba:	85 c9                	test   %ecx,%ecx
  8007bc:	75 1c                	jne    8007da <free_block+0x29>
		panic("attempt to free zero block");
  8007be:	c7 44 24 08 34 3a 80 	movl   $0x803a34,0x8(%esp)
  8007c5:	00 
  8007c6:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8007cd:	00 
  8007ce:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  8007d5:	e8 de 14 00 00       	call   801cb8 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8007da:	89 c8                	mov    %ecx,%eax
  8007dc:	c1 e8 05             	shr    $0x5,%eax
  8007df:	c1 e0 02             	shl    $0x2,%eax
  8007e2:	03 05 88 b0 80 00    	add    0x80b088,%eax
  8007e8:	83 e1 1f             	and    $0x1f,%ecx
  8007eb:	ba 01 00 00 00       	mov    $0x1,%edx
  8007f0:	d3 e2                	shl    %cl,%edx
  8007f2:	09 10                	or     %edx,(%eax)
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  8007fc:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  800801:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800807:	74 1c                	je     800825 <check_super+0x2f>
		panic("bad file system magic number");
  800809:	c7 44 24 08 57 3a 80 	movl   $0x803a57,0x8(%esp)
  800810:	00 
  800811:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800818:	00 
  800819:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  800820:	e8 93 14 00 00       	call   801cb8 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800825:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80082c:	76 1c                	jbe    80084a <check_super+0x54>
		panic("file system is too large");
  80082e:	c7 44 24 08 74 3a 80 	movl   $0x803a74,0x8(%esp)
  800835:	00 
  800836:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  80083d:	00 
  80083e:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  800845:	e8 6e 14 00 00       	call   801cb8 <_panic>

//	cprintf("superblock is good\n");
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800854:	a1 8c b0 80 00       	mov    0x80b08c,%eax
  800859:	8b 70 04             	mov    0x4(%eax),%esi
  80085c:	85 f6                	test   %esi,%esi
  80085e:	74 44                	je     8008a4 <check_bitmap+0x58>
  800860:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(!block_is_free(2+i));
  800865:	8d 43 02             	lea    0x2(%ebx),%eax
  800868:	89 04 24             	mov    %eax,(%esp)
  80086b:	e8 30 fe ff ff       	call   8006a0 <block_is_free>
  800870:	85 c0                	test   %eax,%eax
  800872:	74 24                	je     800898 <check_bitmap+0x4c>
  800874:	c7 44 24 0c 8d 3a 80 	movl   $0x803a8d,0xc(%esp)
  80087b:	00 
  80087c:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  800883:	00 
  800884:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  80088b:	00 
  80088c:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  800893:	e8 20 14 00 00       	call   801cb8 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800898:	83 c3 01             	add    $0x1,%ebx
  80089b:	89 d8                	mov    %ebx,%eax
  80089d:	c1 e0 0f             	shl    $0xf,%eax
  8008a0:	39 f0                	cmp    %esi,%eax
  8008a2:	72 c1                	jb     800865 <check_bitmap+0x19>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008ab:	e8 f0 fd ff ff       	call   8006a0 <block_is_free>
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	74 24                	je     8008d8 <check_bitmap+0x8c>
  8008b4:	c7 44 24 0c a1 3a 80 	movl   $0x803aa1,0xc(%esp)
  8008bb:	00 
  8008bc:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8008c3:	00 
  8008c4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8008cb:	00 
  8008cc:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  8008d3:	e8 e0 13 00 00       	call   801cb8 <_panic>
	assert(!block_is_free(1));
  8008d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8008df:	e8 bc fd ff ff       	call   8006a0 <block_is_free>
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	74 24                	je     80090c <check_bitmap+0xc0>
  8008e8:	c7 44 24 0c b3 3a 80 	movl   $0x803ab3,0xc(%esp)
  8008ef:	00 
  8008f0:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8008f7:	00 
  8008f8:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  8008ff:	00 
  800900:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  800907:	e8 ac 13 00 00       	call   801cb8 <_panic>

	cprintf("bitmap is good\n");
  80090c:	c7 04 24 c5 3a 80 00 	movl   $0x803ac5,(%esp)
  800913:	e8 65 14 00 00       	call   801d7d <cprintf>
}
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <file_block_walk>:
// Analogy: This is like pgdir_walk for files.  
// Hint: Don't forget to clear any block you allocate.

static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 28             	sub    $0x28,%esp
  800925:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800928:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80092b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80092e:	89 c3                	mov    %eax,%ebx
  800930:	89 d6                	mov    %edx,%esi
  800932:	89 cf                	mov    %ecx,%edi
	// LAB 5: Your code here.
	if(filebno >= (NDIRECT + NINDIRECT))
  800934:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800939:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80093f:	0f 87 7e 00 00 00    	ja     8009c3 <file_block_walk+0xa4>
	{
		return -E_INVAL;
	}
	uint32_t *indirect_array;
	if(filebno < NDIRECT)
  800945:	83 fa 09             	cmp    $0x9,%edx
  800948:	77 10                	ja     80095a <file_block_walk+0x3b>
	{
		*ppdiskbno = (uint32_t *)(&f->f_direct[filebno]);
  80094a:	8d 84 93 88 00 00 00 	lea    0x88(%ebx,%edx,4),%eax
  800951:	89 01                	mov    %eax,(%ecx)
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
	
		return 0;
  800958:	eb 69                	jmp    8009c3 <file_block_walk+0xa4>
	}
	else
	{
		//filebno = filebno - NDIRECT;
		//cprintf("blockno: %d\n", filebno);
		if(f->f_indirect == 0)
  80095a:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800960:	85 c0                	test   %eax,%eax
  800962:	75 45                	jne    8009a9 <file_block_walk+0x8a>
		{
			if(alloc)
  800964:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800968:	74 54                	je     8009be <file_block_walk+0x9f>
			{
				int blockNo;
				if((blockNo = alloc_block()) == -E_NO_DISK)
  80096a:	e8 c3 fd ff ff       	call   800732 <alloc_block>
  80096f:	83 f8 f7             	cmp    $0xfffffff7,%eax
  800972:	74 4a                	je     8009be <file_block_walk+0x9f>
					return -E_NO_DISK;
				f->f_indirect = blockNo;
  800974:	89 83 b0 00 00 00    	mov    %eax,0xb0(%ebx)
				indirect_array = (uint32_t *)diskaddr(f->f_indirect);
  80097a:	89 04 24             	mov    %eax,(%esp)
  80097d:	e8 41 f9 ff ff       	call   8002c3 <diskaddr>
  800982:	89 c3                	mov    %eax,%ebx
				memset((void *)indirect_array, 0, BLKSIZE);
  800984:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80098b:	00 
  80098c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800993:	00 
  800994:	89 04 24             	mov    %eax,(%esp)
  800997:	e8 1a 1c 00 00       	call   8025b6 <memset>
				*ppdiskbno = (uint32_t *)(&indirect_array[filebno - NDIRECT]);
  80099c:	8d 44 b3 d8          	lea    -0x28(%ebx,%esi,4),%eax
  8009a0:	89 07                	mov    %eax,(%edi)
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
				return 0;
  8009a7:	eb 1a                	jmp    8009c3 <file_block_walk+0xa4>
				return -E_NO_DISK;
			}
		}
		else
		{
			indirect_array = (uint32_t *)diskaddr(f->f_indirect);
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 12 f9 ff ff       	call   8002c3 <diskaddr>
			*ppdiskbno = (uint32_t *)(&indirect_array[filebno - NDIRECT]);
  8009b1:	8d 44 b0 d8          	lea    -0x28(%eax,%esi,4),%eax
  8009b5:	89 07                	mov    %eax,(%edi)
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8009bc:	eb 05                	jmp    8009c3 <file_block_walk+0xa4>
  8009be:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		}
	}
	panic("file_block_walk not implemented");
}
  8009c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009c6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009cc:	89 ec                	mov    %ebp,%esp
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	83 ec 3c             	sub    $0x3c,%esp
  8009d9:	89 c6                	mov    %eax,%esi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  8009db:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8009e1:	05 ff 0f 00 00       	add    $0xfff,%eax
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	c1 ff 1f             	sar    $0x1f,%edi
  8009eb:	c1 ef 14             	shr    $0x14,%edi
  8009ee:	01 c7                	add    %eax,%edi
  8009f0:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  8009f3:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  8009f9:	89 d0                	mov    %edx,%eax
  8009fb:	c1 f8 1f             	sar    $0x1f,%eax
  8009fe:	c1 e8 14             	shr    $0x14,%eax
  800a01:	8d 14 10             	lea    (%eax,%edx,1),%edx
  800a04:	c1 fa 0c             	sar    $0xc,%edx
  800a07:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800a0a:	39 d7                	cmp    %edx,%edi
  800a0c:	76 4c                	jbe    800a5a <file_truncate_blocks+0x8a>
  800a0e:	89 d3                	mov    %edx,%ebx
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800a10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a17:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800a1a:	89 da                	mov    %ebx,%edx
  800a1c:	89 f0                	mov    %esi,%eax
  800a1e:	e8 fc fe ff ff       	call   80091f <file_block_walk>
  800a23:	85 c0                	test   %eax,%eax
  800a25:	78 1c                	js     800a43 <file_truncate_blocks+0x73>
		return r;
	if (*ptr) {
  800a27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a2a:	8b 00                	mov    (%eax),%eax
  800a2c:	85 c0                	test   %eax,%eax
  800a2e:	74 23                	je     800a53 <file_truncate_blocks+0x83>
		free_block(*ptr);
  800a30:	89 04 24             	mov    %eax,(%esp)
  800a33:	e8 79 fd ff ff       	call   8007b1 <free_block>
		*ptr = 0;
  800a38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800a41:	eb 10                	jmp    800a53 <file_truncate_blocks+0x83>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a47:	c7 04 24 d5 3a 80 00 	movl   $0x803ad5,(%esp)
  800a4e:	e8 2a 13 00 00       	call   801d7d <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800a53:	83 c3 01             	add    $0x1,%ebx
  800a56:	39 df                	cmp    %ebx,%edi
  800a58:	77 b6                	ja     800a10 <file_truncate_blocks+0x40>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800a5a:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800a5e:	77 1c                	ja     800a7c <file_truncate_blocks+0xac>
  800a60:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800a66:	85 c0                	test   %eax,%eax
  800a68:	74 12                	je     800a7c <file_truncate_blocks+0xac>
		free_block(f->f_indirect);
  800a6a:	89 04 24             	mov    %eax,(%esp)
  800a6d:	e8 3f fd ff ff       	call   8007b1 <free_block>
		f->f_indirect = 0;
  800a72:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800a79:	00 00 00 
	}
}
  800a7c:	83 c4 3c             	add    $0x3c,%esp
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	83 ec 18             	sub    $0x18,%esp
  800a8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800a8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800a90:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a93:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800a96:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  800a9c:	7e 09                	jle    800aa7 <file_set_size+0x23>
		file_truncate_blocks(f, newsize);
  800a9e:	89 f2                	mov    %esi,%edx
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	e8 29 ff ff ff       	call   8009d0 <file_truncate_blocks>
	f->f_size = newsize;
  800aa7:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800aad:	89 1c 24             	mov    %ebx,(%esp)
  800ab0:	e8 6b f9 ff ff       	call   800420 <flush_block>
	return 0;
}
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800abd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ac0:	89 ec                	mov    %ebp,%esp
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 2c             	sub    $0x2c,%esp
  800acd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800ad0:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800ad6:	05 ff 0f 00 00       	add    $0xfff,%eax
  800adb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800ae0:	7e 5b                	jle    800b3d <file_flush+0x79>
  800ae2:	be 00 00 00 00       	mov    $0x0,%esi
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800ae7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800aea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800af1:	89 f9                	mov    %edi,%ecx
  800af3:	89 f2                	mov    %esi,%edx
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	e8 23 fe ff ff       	call   80091f <file_block_walk>
  800afc:	85 c0                	test   %eax,%eax
  800afe:	78 1d                	js     800b1d <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  800b00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800b03:	85 c0                	test   %eax,%eax
  800b05:	74 16                	je     800b1d <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  800b07:	8b 00                	mov    (%eax),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	74 10                	je     800b1d <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  800b0d:	89 04 24             	mov    %eax,(%esp)
  800b10:	e8 ae f7 ff ff       	call   8002c3 <diskaddr>
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 03 f9 ff ff       	call   800420 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800b1d:	83 c6 01             	add    $0x1,%esi
  800b20:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800b26:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	c1 fa 1f             	sar    $0x1f,%edx
  800b30:	c1 ea 14             	shr    $0x14,%edx
  800b33:	8d 04 02             	lea    (%edx,%eax,1),%eax
  800b36:	c1 f8 0c             	sar    $0xc,%eax
  800b39:	39 f0                	cmp    %esi,%eax
  800b3b:	7f ad                	jg     800aea <file_flush+0x26>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800b3d:	89 1c 24             	mov    %ebx,(%esp)
  800b40:	e8 db f8 ff ff       	call   800420 <flush_block>
	if (f->f_indirect)
  800b45:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	74 10                	je     800b5f <file_flush+0x9b>
		flush_block(diskaddr(f->f_indirect));
  800b4f:	89 04 24             	mov    %eax,(%esp)
  800b52:	e8 6c f7 ff ff       	call   8002c3 <diskaddr>
  800b57:	89 04 24             	mov    %eax,(%esp)
  800b5a:	e8 c1 f8 ff ff       	call   800420 <flush_block>
}
  800b5f:	83 c4 2c             	add    $0x2c,%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	83 ec 28             	sub    $0x28,%esp
	// LAB 5: Your code here.
	int blockNo;
	uint32_t *addr;
	int r;
	if( (r = file_block_walk(f, filebno, &addr, 1)) < 0)
  800b6d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	e8 9d fd ff ff       	call   80091f <file_block_walk>
  800b82:	85 c0                	test   %eax,%eax
  800b84:	78 36                	js     800bbc <file_get_block+0x55>
		return r;
	if(*addr == 0)
  800b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b89:	83 38 00             	cmpl   $0x0,(%eax)
  800b8c:	75 17                	jne    800ba5 <file_get_block+0x3e>
	{
		if((blockNo = alloc_block()) < 0)
  800b8e:	66 90                	xchg   %ax,%ax
  800b90:	e8 9d fb ff ff       	call   800732 <alloc_block>
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800b9c:	85 d2                	test   %edx,%edx
  800b9e:	78 1c                	js     800bbc <file_get_block+0x55>
			return -E_NO_DISK;
		*addr = blockNo;
  800ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ba3:	89 10                	mov    %edx,(%eax)
	}
	blockNo = *addr;
	*blk = diskaddr(blockNo);
  800ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ba8:	8b 00                	mov    (%eax),%eax
  800baa:	89 04 24             	mov    %eax,(%esp)
  800bad:	e8 11 f7 ff ff       	call   8002c3 <diskaddr>
  800bb2:	8b 55 10             	mov    0x10(%ebp),%edx
  800bb5:	89 02                	mov    %eax,(%edx)
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
	panic("file_get_block not implemented");
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800bca:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800bd0:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800bd6:	e8 03 fb ff ff       	call   8006de <skip_slash>
  800bdb:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	f = &super->s_root;
  800be1:	a1 8c b0 80 00       	mov    0x80b08c,%eax
	dir = 0;
	name[0] = 0;
  800be6:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800bed:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800bf4:	74 0c                	je     800c02 <walk_path+0x44>
		*pdir = 0;
  800bf6:	8b 95 40 ff ff ff    	mov    -0xc0(%ebp),%edx
  800bfc:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800c02:	83 c0 08             	add    $0x8,%eax
  800c05:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800c0b:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800c11:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800c1c:	e9 a0 01 00 00       	jmp    800dc1 <walk_path+0x203>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800c21:	83 c6 01             	add    $0x1,%esi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800c24:	0f b6 06             	movzbl (%esi),%eax
  800c27:	3c 2f                	cmp    $0x2f,%al
  800c29:	74 04                	je     800c2f <walk_path+0x71>
  800c2b:	84 c0                	test   %al,%al
  800c2d:	75 f2                	jne    800c21 <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800c2f:	89 f3                	mov    %esi,%ebx
  800c31:	2b 9d 48 ff ff ff    	sub    -0xb8(%ebp),%ebx
  800c37:	83 fb 7f             	cmp    $0x7f,%ebx
  800c3a:	7e 0a                	jle    800c46 <walk_path+0x88>
  800c3c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800c41:	e9 c2 01 00 00       	jmp    800e08 <walk_path+0x24a>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c46:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c4a:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800c50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c54:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800c5a:	89 14 24             	mov    %edx,(%esp)
  800c5d:	e8 b3 19 00 00       	call   802615 <memmove>
		name[path - p] = '\0';
  800c62:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c69:	00 
		path = skip_slash(path);
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	e8 6d fa ff ff       	call   8006de <skip_slash>
  800c71:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800c77:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800c7d:	83 b9 84 00 00 00 01 	cmpl   $0x1,0x84(%ecx)
  800c84:	0f 85 79 01 00 00    	jne    800e03 <walk_path+0x245>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800c8a:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  800c90:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c95:	74 24                	je     800cbb <walk_path+0xfd>
  800c97:	c7 44 24 0c f2 3a 80 	movl   $0x803af2,0xc(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  800ca6:	00 
  800ca7:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  800cae:	00 
  800caf:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  800cb6:	e8 fd 0f 00 00       	call   801cb8 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	c1 fa 1f             	sar    $0x1f,%edx
  800cc0:	c1 ea 14             	shr    $0x14,%edx
  800cc3:	8d 04 02             	lea    (%edx,%eax,1),%eax
  800cc6:	c1 f8 0c             	sar    $0xc,%eax
  800cc9:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	0f 84 8a 00 00 00    	je     800d61 <walk_path+0x1a3>
  800cd7:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800cde:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ce1:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800ce7:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800ced:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf1:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800cf7:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cfb:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d01:	89 0c 24             	mov    %ecx,(%esp)
  800d04:	e8 5e fe ff ff       	call   800b67 <file_get_block>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 4b                	js     800d58 <walk_path+0x19a>
  800d0d:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800d13:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  800d19:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d23:	89 1c 24             	mov    %ebx,(%esp)
  800d26:	e8 be 17 00 00       	call   8024e9 <strcmp>
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	0f 84 82 00 00 00    	je     800db5 <walk_path+0x1f7>
  800d33:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800d39:	3b 9d 54 ff ff ff    	cmp    -0xac(%ebp),%ebx
  800d3f:	75 de                	jne    800d1f <walk_path+0x161>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800d41:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800d48:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800d4e:	39 95 44 ff ff ff    	cmp    %edx,-0xbc(%ebp)
  800d54:	77 91                	ja     800ce7 <walk_path+0x129>
  800d56:	eb 09                	jmp    800d61 <walk_path+0x1a3>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d58:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d5b:	0f 85 a7 00 00 00    	jne    800e08 <walk_path+0x24a>
  800d61:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  800d67:	80 39 00             	cmpb   $0x0,(%ecx)
  800d6a:	0f 85 93 00 00 00    	jne    800e03 <walk_path+0x245>
				if (pdir)
  800d70:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800d77:	74 0e                	je     800d87 <walk_path+0x1c9>
					*pdir = dir;
  800d79:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800d7f:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d85:	89 10                	mov    %edx,(%eax)
				if (lastelem)
  800d87:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d8b:	74 15                	je     800da2 <walk_path+0x1e4>
					strcpy(lastelem, name);
  800d8d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9a:	89 0c 24             	mov    %ecx,(%esp)
  800d9d:	e8 b8 16 00 00       	call   80245a <strcpy>
				*pf = 0;
  800da2:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800da8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800dae:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800db3:	eb 53                	jmp    800e08 <walk_path+0x24a>
  800db5:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800dbb:	89 9d 4c ff ff ff    	mov    %ebx,-0xb4(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800dc1:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  800dc7:	0f b6 01             	movzbl (%ecx),%eax
  800dca:	84 c0                	test   %al,%al
  800dcc:	74 0f                	je     800ddd <walk_path+0x21f>
  800dce:	89 ce                	mov    %ecx,%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800dd0:	3c 2f                	cmp    $0x2f,%al
  800dd2:	0f 85 49 fe ff ff    	jne    800c21 <walk_path+0x63>
  800dd8:	e9 52 fe ff ff       	jmp    800c2f <walk_path+0x71>
			}
			return r;
		}
	}

	if (pdir)
  800ddd:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800de4:	74 08                	je     800dee <walk_path+0x230>
		*pdir = dir;
  800de6:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800dec:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800dee:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800df4:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
  800dfa:	89 0a                	mov    %ecx,(%edx)
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  800e01:	eb 05                	jmp    800e08 <walk_path+0x24a>
  800e03:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  800e08:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <file_remove>:
}

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  800e19:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e23:	ba 00 00 00 00       	mov    $0x0,%edx
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	e8 8e fd ff ff       	call   800bbe <walk_path>
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 30                	js     800e64 <file_remove+0x51>
		return r;

	file_truncate_blocks(f, 0);
  800e34:	ba 00 00 00 00       	mov    $0x0,%edx
  800e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3c:	e8 8f fb ff ff       	call   8009d0 <file_truncate_blocks>
	f->f_name[0] = '\0';
  800e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e44:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  800e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4a:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  800e51:	00 00 00 
	flush_block(f);
  800e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e57:	89 04 24             	mov    %eax,(%esp)
  800e5a:	e8 c1 f5 ff ff       	call   800420 <flush_block>
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax

	return 0;
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800e6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	e8 3b fd ff ff       	call   800bbe <walk_path>
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 3c             	sub    $0x3c,%esp
  800e8e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e91:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800e94:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800e97:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9a:	01 d8                	add    %ebx,%eax
  800e9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800ea8:	77 0d                	ja     800eb7 <file_write+0x32>
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800eaa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ead:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  800eb0:	72 1d                	jb     800ecf <file_write+0x4a>
  800eb2:	e9 85 00 00 00       	jmp    800f3c <file_write+0xb7>
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
  800eb7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800eba:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	89 04 24             	mov    %eax,(%esp)
  800ec4:	e8 bb fb ff ff       	call   800a84 <file_set_size>
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	79 dd                	jns    800eaa <file_write+0x25>
  800ecd:	eb 70                	jmp    800f3f <file_write+0xba>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ecf:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800ed2:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	c1 f8 1f             	sar    $0x1f,%eax
  800edb:	c1 e8 14             	shr    $0x14,%eax
  800ede:	01 d8                	add    %ebx,%eax
  800ee0:	c1 f8 0c             	sar    $0xc,%eax
  800ee3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	89 04 24             	mov    %eax,(%esp)
  800eed:	e8 75 fc ff ff       	call   800b67 <file_get_block>
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	78 49                	js     800f3f <file_write+0xba>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800ef6:	89 da                	mov    %ebx,%edx
  800ef8:	c1 fa 1f             	sar    $0x1f,%edx
  800efb:	c1 ea 14             	shr    $0x14,%edx
  800efe:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800f01:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f06:	29 d0                	sub    %edx,%eax
  800f08:	be 00 10 00 00       	mov    $0x1000,%esi
  800f0d:	29 c6                	sub    %eax,%esi
  800f0f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f12:	2b 55 d0             	sub    -0x30(%ebp),%edx
  800f15:	39 d6                	cmp    %edx,%esi
  800f17:	76 02                	jbe    800f1b <file_write+0x96>
  800f19:	89 d6                	mov    %edx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f1b:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f23:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f26:	89 04 24             	mov    %eax,(%esp)
  800f29:	e8 e7 16 00 00       	call   802615 <memmove>
		pos += bn;
  800f2e:	01 f3                	add    %esi,%ebx
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f30:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800f33:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800f36:	76 04                	jbe    800f3c <file_write+0xb7>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
  800f38:	01 f7                	add    %esi,%edi
  800f3a:	eb 93                	jmp    800ecf <file_write+0x4a>
	}

	return count;
  800f3c:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f3f:	83 c4 3c             	add    $0x3c,%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 3c             	sub    $0x3c,%esp
  800f50:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f53:	8b 55 10             	mov    0x10(%ebp),%edx
  800f56:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;
	if (offset >= f->f_size)
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	39 d9                	cmp    %ebx,%ecx
  800f69:	0f 8e 8b 00 00 00    	jle    800ffa <file_read+0xb3>
	{
		return 0;
	}
	count = MIN(count, f->f_size - offset);
  800f6f:	29 d9                	sub    %ebx,%ecx
  800f71:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800f74:	39 d1                	cmp    %edx,%ecx
  800f76:	76 03                	jbe    800f7b <file_read+0x34>
  800f78:	89 55 cc             	mov    %edx,-0x34(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800f7b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800f7e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800f81:	01 d8                	add    %ebx,%eax
  800f83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f86:	39 d8                	cmp    %ebx,%eax
  800f88:	76 6d                	jbe    800ff7 <file_read+0xb0>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	c1 f8 1f             	sar    $0x1f,%eax
  800f96:	c1 e8 14             	shr    $0x14,%eax
  800f99:	01 d8                	add    %ebx,%eax
  800f9b:	c1 f8 0c             	sar    $0xc,%eax
  800f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	89 04 24             	mov    %eax,(%esp)
  800fa8:	e8 ba fb ff ff       	call   800b67 <file_get_block>
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 49                	js     800ffa <file_read+0xb3>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800fb1:	89 da                	mov    %ebx,%edx
  800fb3:	c1 fa 1f             	sar    $0x1f,%edx
  800fb6:	c1 ea 14             	shr    $0x14,%edx
  800fb9:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800fbc:	25 ff 0f 00 00       	and    $0xfff,%eax
  800fc1:	29 d0                	sub    %edx,%eax
  800fc3:	be 00 10 00 00       	mov    $0x1000,%esi
  800fc8:	29 c6                	sub    %eax,%esi
  800fca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800fcd:	2b 55 d0             	sub    -0x30(%ebp),%edx
  800fd0:	39 d6                	cmp    %edx,%esi
  800fd2:	76 02                	jbe    800fd6 <file_read+0x8f>
  800fd4:	89 d6                	mov    %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800fd6:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fda:	03 45 e4             	add    -0x1c(%ebp),%eax
  800fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe1:	89 3c 24             	mov    %edi,(%esp)
  800fe4:	e8 2c 16 00 00       	call   802615 <memmove>
		pos += bn;
  800fe9:	01 f3                	add    %esi,%ebx
	{
		return 0;
	}
	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800feb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800fee:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800ff1:	76 04                	jbe    800ff7 <file_read+0xb0>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
  800ff3:	01 f7                	add    %esi,%edi
  800ff5:	eb 93                	jmp    800f8a <file_read+0x43>
	}
	//cprintf("%d %s %s\n", count, buf, blk);
	return count;
  800ff7:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
  800ffa:	83 c4 3c             	add    $0x3c,%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	57                   	push   %edi
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80100e:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801014:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80101a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801020:	89 04 24             	mov    %eax,(%esp)
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	e8 93 fb ff ff       	call   800bbe <walk_path>
  80102b:	89 c3                	mov    %eax,%ebx
  80102d:	85 c0                	test   %eax,%eax
  80102f:	0f 84 ed 00 00 00    	je     801122 <file_create+0x120>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801035:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801038:	0f 85 e9 00 00 00    	jne    801127 <file_create+0x125>
  80103e:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  801044:	85 ff                	test   %edi,%edi
  801046:	0f 84 db 00 00 00    	je     801127 <file_create+0x125>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80104c:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
  801052:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801057:	74 24                	je     80107d <file_create+0x7b>
  801059:	c7 44 24 0c f2 3a 80 	movl   $0x803af2,0xc(%esp)
  801060:	00 
  801061:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 4f 3a 80 00 	movl   $0x803a4f,(%esp)
  801078:	e8 3b 0c 00 00       	call   801cb8 <_panic>
	nblock = dir->f_size / BLKSIZE;
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	c1 fa 1f             	sar    $0x1f,%edx
  801082:	c1 ea 14             	shr    $0x14,%edx
  801085:	8d 04 02             	lea    (%edx,%eax,1),%eax
  801088:	c1 f8 0c             	sar    $0xc,%eax
  80108b:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801091:	be 00 00 00 00       	mov    $0x0,%esi
  801096:	85 c0                	test   %eax,%eax
  801098:	74 56                	je     8010f0 <file_create+0xee>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80109a:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8010a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a8:	89 3c 24             	mov    %edi,(%esp)
  8010ab:	e8 b7 fa ff ff       	call   800b67 <file_get_block>
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 73                	js     801127 <file_create+0x125>
			return r;
		f = (struct File*) blk;
  8010b4:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8010ba:	89 ca                	mov    %ecx,%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010bc:	80 39 00             	cmpb   $0x0,(%ecx)
  8010bf:	74 13                	je     8010d4 <file_create+0xd2>
  8010c1:	8d 81 00 01 00 00    	lea    0x100(%ecx),%eax
// --------------------------------------------------------------

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
  8010c7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  8010cd:	89 c2                	mov    %eax,%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010cf:	80 38 00             	cmpb   $0x0,(%eax)
  8010d2:	75 08                	jne    8010dc <file_create+0xda>
				*file = &f[j];
  8010d4:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  8010da:	eb 58                	jmp    801134 <file_create+0x132>
  8010dc:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010e1:	39 c8                	cmp    %ecx,%eax
  8010e3:	75 e8                	jne    8010cd <file_create+0xcb>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8010e5:	83 c6 01             	add    $0x1,%esi
  8010e8:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  8010ee:	77 aa                	ja     80109a <file_create+0x98>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8010f0:	81 87 80 00 00 00 00 	addl   $0x1000,0x80(%edi)
  8010f7:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010fa:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801100:	89 44 24 08          	mov    %eax,0x8(%esp)
  801104:	89 74 24 04          	mov    %esi,0x4(%esp)
  801108:	89 3c 24             	mov    %edi,(%esp)
  80110b:	e8 57 fa ff ff       	call   800b67 <file_get_block>
  801110:	85 c0                	test   %eax,%eax
  801112:	78 13                	js     801127 <file_create+0x125>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801114:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80111a:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801120:	eb 12                	jmp    801134 <file_create+0x132>
  801122:	bb f3 ff ff ff       	mov    $0xfffffff3,%ebx
		return r;
	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  801127:	89 d8                	mov    %ebx,%eax
  801129:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if (dir_alloc_file(dir, &f) < 0)
		return r;
	strcpy(f->f_name, name);
  801134:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80113a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113e:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801144:	89 04 24             	mov    %eax,(%esp)
  801147:	e8 0e 13 00 00       	call   80245a <strcpy>
	*pf = f;
  80114c:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801152:	8b 45 0c             	mov    0xc(%ebp),%eax
  801155:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801157:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	e8 5f f9 ff ff       	call   800ac4 <file_flush>
  801165:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  80116a:	eb bb                	jmp    801127 <file_create+0x125>

0080116c <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  801172:	e8 fa ee ff ff       	call   800071 <ide_probe_disk1>
  801177:	85 c0                	test   %eax,%eax
  801179:	74 0e                	je     801189 <fs_init+0x1d>
		ide_set_disk(1);
  80117b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801182:	e8 bd f0 ff ff       	call   800244 <ide_set_disk>
  801187:	eb 0c                	jmp    801195 <fs_init+0x29>
	else
		ide_set_disk(0);
  801189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801190:	e8 af f0 ff ff       	call   800244 <ide_set_disk>
	
	bc_init();
  801195:	e8 df f4 ff ff       	call   800679 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  80119a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8011a1:	e8 1d f1 ff ff       	call   8002c3 <diskaddr>
  8011a6:	a3 8c b0 80 00       	mov    %eax,0x80b08c
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8011ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8011b2:	e8 0c f1 ff ff       	call   8002c3 <diskaddr>
  8011b7:	a3 88 b0 80 00       	mov    %eax,0x80b088

	check_super();
  8011bc:	e8 35 f6 ff ff       	call   8007f6 <check_super>
	check_bitmap();
  8011c1:	e8 86 f6 ff ff       	call   80084c <check_bitmap>
}
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    
	...

008011d0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	ba 20 70 80 00       	mov    $0x807020,%edx
  8011d8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  8011e2:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011e4:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011e7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011ed:	83 c0 01             	add    $0x1,%eax
  8011f0:	83 c2 10             	add    $0x10,%edx
  8011f3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011f8:	75 e8                	jne    8011e2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <serve_sync>:
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801202:	e8 e9 f4 ff ff       	call   8006f0 <fs_sync>
	return 0;
}
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <serve_remove>:
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	81 ec 14 04 00 00    	sub    $0x414,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801218:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  80121f:	00 
  801220:	8b 45 0c             	mov    0xc(%ebp),%eax
  801223:	89 44 24 04          	mov    %eax,0x4(%esp)
  801227:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  80122d:	89 1c 24             	mov    %ebx,(%esp)
  801230:	e8 e0 13 00 00       	call   802615 <memmove>
	path[MAXPATHLEN-1] = 0;
  801235:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Delete the specified file
	return file_remove(path);
  801239:	89 1c 24             	mov    %ebx,(%esp)
  80123c:	e8 d2 fb ff ff       	call   800e13 <file_remove>
}
  801241:	81 c4 14 04 00 00    	add    $0x414,%esp
  801247:	5b                   	pop    %ebx
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <openfile_lookup>:
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 18             	sub    $0x18,%esp
  801250:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801253:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801256:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;
	//cprintf("in lookup envid %d, fileid %d, *po %x\n", envid, fileid, *po);
	o = &opentab[fileid % MAXOPEN];
  801259:	89 f3                	mov    %esi,%ebx
  80125b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801261:	c1 e3 04             	shl    $0x4,%ebx
  801264:	81 c3 20 70 80 00    	add    $0x807020,%ebx
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  80126a:	8b 43 0c             	mov    0xc(%ebx),%eax
  80126d:	89 04 24             	mov    %eax,(%esp)
  801270:	e8 97 23 00 00       	call   80360c <pageref>
  801275:	83 f8 01             	cmp    $0x1,%eax
  801278:	74 10                	je     80128a <openfile_lookup+0x40>
  80127a:	39 33                	cmp    %esi,(%ebx)
  80127c:	75 0c                	jne    80128a <openfile_lookup+0x40>
		return -E_INVAL;
	*po = o;
  80127e:	8b 45 10             	mov    0x10(%ebp),%eax
  801281:	89 18                	mov    %ebx,(%eax)
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801288:	eb 05                	jmp    80128f <openfile_lookup+0x45>
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801292:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801295:	89 ec                	mov    %ebp,%esp
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80129f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a9:	8b 00                	mov    (%eax),%eax
  8012ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012af:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b2:	89 04 24             	mov    %eax,(%esp)
  8012b5:	e8 90 ff ff ff       	call   80124a <openfile_lookup>
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 13                	js     8012d1 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  8012be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c1:	8b 40 04             	mov    0x4(%eax),%eax
  8012c4:	89 04 24             	mov    %eax,(%esp)
  8012c7:	e8 f8 f7 ff ff       	call   800ac4 <file_flush>
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 24             	sub    $0x24,%esp
  8012da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e4:	8b 03                	mov    (%ebx),%eax
  8012e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ed:	89 04 24             	mov    %eax,(%esp)
  8012f0:	e8 55 ff ff ff       	call   80124a <openfile_lookup>
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 3f                	js     801338 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8012f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fc:	8b 40 04             	mov    0x4(%eax),%eax
  8012ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801303:	89 1c 24             	mov    %ebx,(%esp)
  801306:	e8 4f 11 00 00       	call   80245a <strcpy>
	ret->ret_size = o->o_file->f_size;
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	8b 50 04             	mov    0x4(%eax),%edx
  801311:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801317:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80131d:	8b 40 04             	mov    0x4(%eax),%eax
  801320:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801327:	0f 94 c0             	sete   %al
  80132a:	0f b6 c0             	movzbl %al,%eax
  80132d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801338:	83 c4 24             	add    $0x24,%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 24             	sub    $0x24,%esp
  801345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134f:	8b 03                	mov    (%ebx),%eax
  801351:	89 44 24 04          	mov    %eax,0x4(%esp)
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	89 04 24             	mov    %eax,(%esp)
  80135b:	e8 ea fe ff ff       	call   80124a <openfile_lookup>
  801360:	85 c0                	test   %eax,%eax
  801362:	78 2f                	js     801393 <serve_write+0x55>
		return r;
	r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  801364:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801367:	8b 50 0c             	mov    0xc(%eax),%edx
  80136a:	8b 52 04             	mov    0x4(%edx),%edx
  80136d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801371:	8b 53 04             	mov    0x4(%ebx),%edx
  801374:	89 54 24 08          	mov    %edx,0x8(%esp)
  801378:	83 c3 08             	add    $0x8,%ebx
  80137b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80137f:	8b 40 04             	mov    0x4(%eax),%eax
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	e8 fb fa ff ff       	call   800e85 <file_write>
	o->o_fd->fd_offset += r;
  80138a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138d:	8b 52 0c             	mov    0xc(%edx),%edx
  801390:	01 42 04             	add    %eax,0x4(%edx)
	return r;
	panic("serve_write not implemented");
}
  801393:	83 c4 24             	add    $0x24,%esp
  801396:	5b                   	pop    %ebx
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	83 ec 20             	sub    $0x20,%esp
  8013a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//
	// Hint: Use file_read.
	// Hint: The seek position is stored in the struct Fd.
	// LAB 5: Your code here
	struct OpenFile *o;
	int sz = req->req_n;
  8013a4:	8b 73 04             	mov    0x4(%ebx),%esi
	if(sz>PGSIZE)
		sz = PGSIZE;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ae:	8b 03                	mov    (%ebx),%eax
  8013b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b7:	89 04 24             	mov    %eax,(%esp)
  8013ba:	e8 8b fe ff ff       	call   80124a <openfile_lookup>
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 3a                	js     8013fd <serve_read+0x64>
		return r;
	if((r = file_read(o->o_file, ret->ret_buf, sz, o->o_fd->fd_offset)) < 0)
  8013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8013c9:	8b 52 04             	mov    0x4(%edx),%edx
  8013cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013d0:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
  8013d6:	7e 05                	jle    8013dd <serve_read+0x44>
  8013d8:	be 00 10 00 00       	mov    $0x1000,%esi
  8013dd:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e5:	8b 40 04             	mov    0x4(%eax),%eax
  8013e8:	89 04 24             	mov    %eax,(%esp)
  8013eb:	e8 57 fb ff ff       	call   800f47 <file_read>
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 09                	js     8013fd <serve_read+0x64>
		return r;
	o->o_fd->fd_offset += r;
  8013f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fa:	01 42 04             	add    %eax,0x4(%edx)
	return r;
	panic("serve_read not implemented");
}
  8013fd:	83 c4 20             	add    $0x20,%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 24             	sub    $0x24,%esp
  80140b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80140e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801411:	89 44 24 08          	mov    %eax,0x8(%esp)
  801415:	8b 03                	mov    (%ebx),%eax
  801417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	89 04 24             	mov    %eax,(%esp)
  801421:	e8 24 fe ff ff       	call   80124a <openfile_lookup>
  801426:	85 c0                	test   %eax,%eax
  801428:	78 15                	js     80143f <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  80142a:	8b 43 04             	mov    0x4(%ebx),%eax
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	8b 40 04             	mov    0x4(%eax),%eax
  801437:	89 04 24             	mov    %eax,(%esp)
  80143a:	e8 45 f6 ff ff       	call   800a84 <file_set_size>
}
  80143f:	83 c4 24             	add    $0x24,%esp
  801442:	5b                   	pop    %ebx
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <openfile_alloc>:
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 28             	sub    $0x28,%esp
  80144b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80144e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801451:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801454:	8b 7d 08             	mov    0x8(%ebp),%edi
  801457:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  80145c:	be 2c 70 80 00       	mov    $0x80702c,%esi
  801461:	89 d8                	mov    %ebx,%eax
  801463:	c1 e0 04             	shl    $0x4,%eax
  801466:	8b 04 06             	mov    (%esi,%eax,1),%eax
  801469:	89 04 24             	mov    %eax,(%esp)
  80146c:	e8 9b 21 00 00       	call   80360c <pageref>
  801471:	85 c0                	test   %eax,%eax
  801473:	74 0d                	je     801482 <openfile_alloc+0x3d>
  801475:	83 f8 01             	cmp    $0x1,%eax
  801478:	75 68                	jne    8014e2 <openfile_alloc+0x9d>
  80147a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801480:	eb 27                	jmp    8014a9 <openfile_alloc+0x64>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801482:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801489:	00 
  80148a:	89 d8                	mov    %ebx,%eax
  80148c:	c1 e0 04             	shl    $0x4,%eax
  80148f:	8b 80 2c 70 80 00    	mov    0x80702c(%eax),%eax
  801495:	89 44 24 04          	mov    %eax,0x4(%esp)
  801499:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a0:	e8 49 16 00 00       	call   802aee <sys_page_alloc>
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 4d                	js     8014f6 <openfile_alloc+0xb1>
{
				return r;
}
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8014a9:	c1 e3 04             	shl    $0x4,%ebx
  8014ac:	81 83 20 70 80 00 00 	addl   $0x400,0x807020(%ebx)
  8014b3:	04 00 00 
			*o = &opentab[i];
  8014b6:	8d 83 20 70 80 00    	lea    0x807020(%ebx),%eax
  8014bc:	89 07                	mov    %eax,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8014be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014c5:	00 
  8014c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014cd:	00 
  8014ce:	8b 83 2c 70 80 00    	mov    0x80702c(%ebx),%eax
  8014d4:	89 04 24             	mov    %eax,(%esp)
  8014d7:	e8 da 10 00 00       	call   8025b6 <memset>
			return (*o)->o_fileid;
  8014dc:	8b 07                	mov    (%edi),%eax
  8014de:	8b 00                	mov    (%eax),%eax
  8014e0:	eb 14                	jmp    8014f6 <openfile_alloc+0xb1>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8014e2:	83 c3 01             	add    $0x1,%ebx
  8014e5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8014eb:	0f 85 70 ff ff ff    	jne    801461 <openfile_alloc+0x1c>
  8014f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}
  8014f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014ff:	89 ec                	mov    %ebp,%esp
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	81 ec 24 04 00 00    	sub    $0x424,%esp
  80150d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801510:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801517:	00 
  801518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801522:	89 04 24             	mov    %eax,(%esp)
  801525:	e8 eb 10 00 00       	call   802615 <memmove>
	path[MAXPATHLEN-1] = 0;
  80152a:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80152e:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 09 ff ff ff       	call   801445 <openfile_alloc>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	0f 88 ec 00 00 00    	js     801630 <serve_open+0x12d>
		return r;
	}
	fileid = r;
	//cprintf("alloc done\n");
	// Open the file
	if (req->req_omode & O_CREAT) {
  801544:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80154b:	74 32                	je     80157f <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  80154d:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801553:	89 44 24 04          	mov    %eax,0x4(%esp)
  801557:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80155d:	89 04 24             	mov    %eax,(%esp)
  801560:	e8 9d fa ff ff       	call   801002 <file_create>
  801565:	85 c0                	test   %eax,%eax
  801567:	79 36                	jns    80159f <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801569:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801570:	0f 85 ba 00 00 00    	jne    801630 <serve_open+0x12d>
  801576:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801579:	0f 85 b1 00 00 00    	jne    801630 <serve_open+0x12d>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80157f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 cf f8 ff ff       	call   800e66 <file_open>
  801597:	85 c0                	test   %eax,%eax
  801599:	0f 88 91 00 00 00    	js     801630 <serve_open+0x12d>
		}
	}

	//cprintf("chk1 done\n");
	// Truncate
	if (req->req_omode & O_TRUNC) {
  80159f:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8015a6:	74 1a                	je     8015c2 <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  8015a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015af:	00 
  8015b0:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 c6 f4 ff ff       	call   800a84 <file_set_size>
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 6e                	js     801630 <serve_open+0x12d>
		}
	}

	//cprintf("chk2 done\n");
	// Save the file pointer
	o->o_file = f;
  8015c2:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8015c8:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015ce:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8015d1:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015d7:	8b 50 0c             	mov    0xc(%eax),%edx
  8015da:	8b 00                	mov    (%eax),%eax
  8015dc:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8015df:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e8:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015ee:	83 e2 03             	and    $0x3,%edx
  8015f1:	89 50 08             	mov    %edx,0x8(%eax)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8015f4:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fd:	8b 15 6c b0 80 00    	mov    0x80b06c,%edx
  801603:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801605:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80160b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801611:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  801614:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80161a:	8b 50 0c             	mov    0xc(%eax),%edx
  80161d:	8b 45 10             	mov    0x10(%ebp),%eax
  801620:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W;
  801622:	8b 45 14             	mov    0x14(%ebp),%eax
  801625:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801630:	81 c4 24 04 00 00    	add    $0x424,%esp
  801636:	5b                   	pop    %ebx
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 2c             	sub    $0x2c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801642:	8d 5d e0             	lea    -0x20(%ebp),%ebx
  801645:	8d 75 e4             	lea    -0x1c(%ebp),%esi
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  801648:	bf 40 b0 80 00       	mov    $0x80b040,%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80164d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801654:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801658:	a1 20 b0 80 00       	mov    0x80b020,%eax
  80165d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801661:	89 34 24             	mov    %esi,(%esp)
  801664:	e8 cd 16 00 00       	call   802d36 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[VPN(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801669:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  80166d:	75 15                	jne    801684 <serve+0x4b>
			cprintf("Invalid request from %08x: no argument page\n",
  80166f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801672:	89 44 24 04          	mov    %eax,0x4(%esp)
  801676:	c7 04 24 10 3b 80 00 	movl   $0x803b10,(%esp)
  80167d:	e8 fb 06 00 00       	call   801d7d <cprintf>
				whom);
			continue; // just leave it hanging...
  801682:	eb c9                	jmp    80164d <serve+0x14>
		}

		pg = NULL;
  801684:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  80168b:	83 f8 01             	cmp    $0x1,%eax
  80168e:	75 21                	jne    8016b1 <serve+0x78>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801690:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801694:	8d 45 dc             	lea    -0x24(%ebp),%eax
  801697:	89 44 24 08          	mov    %eax,0x8(%esp)
  80169b:	a1 20 b0 80 00       	mov    0x80b020,%eax
  8016a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 54 fe ff ff       	call   801503 <serve_open>
  8016af:	eb 40                	jmp    8016f1 <serve+0xb8>
		} else if (req < NHANDLERS && handlers[req]) {
  8016b1:	83 f8 08             	cmp    $0x8,%eax
  8016b4:	77 1f                	ja     8016d5 <serve+0x9c>
  8016b6:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	90                   	nop
  8016bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016c0:	74 13                	je     8016d5 <serve+0x9c>
			r = handlers[req](whom, fsreq);
  8016c2:	a1 20 b0 80 00       	mov    0x80b020,%eax
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ce:	89 04 24             	mov    %eax,(%esp)
  8016d1:	ff d2                	call   *%edx
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  8016d3:	eb 1c                	jmp    8016f1 <serve+0xb8>
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  8016d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e0:	c7 04 24 40 3b 80 00 	movl   $0x803b40,(%esp)
  8016e7:	e8 91 06 00 00       	call   801d7d <cprintf>
  8016ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  8016f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8016f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8016fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	e8 be 15 00 00       	call   802ccc <ipc_send>
		sys_page_unmap(0, fsreq);
  80170e:	a1 20 b0 80 00       	mov    0x80b020,%eax
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171e:	e8 0f 13 00 00       	call   802a32 <sys_page_unmap>
  801723:	e9 25 ff ff ff       	jmp    80164d <serve+0x14>

00801728 <umain>:
	}
}

void
umain(void)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80172e:	c7 05 64 b0 80 00 63 	movl   $0x803b63,0x80b064
  801735:	3b 80 00 
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801738:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80173d:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801742:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	//cprintf("FS can do I/O\n");

	serve_init();
  801744:	e8 87 fa ff ff       	call   8011d0 <serve_init>
	fs_init();
  801749:	e8 1e fa ff ff       	call   80116c <fs_init>
	//fs_test();

	serve();
  80174e:	e8 e6 fe ff ff       	call   801639 <serve>
}
  801753:	c9                   	leave  
  801754:	c3                   	ret    
  801755:	00 00                	add    %al,(%eax)
	...

00801758 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80175f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801766:	00 
  801767:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80176e:	00 
  80176f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801776:	e8 73 13 00 00       	call   802aee <sys_page_alloc>
  80177b:	85 c0                	test   %eax,%eax
  80177d:	79 20                	jns    80179f <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80177f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801783:	c7 44 24 08 66 3b 80 	movl   $0x803b66,0x8(%esp)
  80178a:	00 
  80178b:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  801792:	00 
  801793:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  80179a:	e8 19 05 00 00       	call   801cb8 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80179f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017a6:	00 
  8017a7:	a1 88 b0 80 00       	mov    0x80b088,%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8017b7:	e8 59 0e 00 00       	call   802615 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8017bc:	e8 71 ef ff ff       	call   800732 <alloc_block>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	79 20                	jns    8017e5 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8017c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017c9:	c7 44 24 08 83 3b 80 	movl   $0x803b83,0x8(%esp)
  8017d0:	00 
  8017d1:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8017d8:	00 
  8017d9:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  8017e0:	e8 d3 04 00 00       	call   801cb8 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8017e5:	89 c3                	mov    %eax,%ebx
  8017e7:	c1 fb 1f             	sar    $0x1f,%ebx
  8017ea:	c1 eb 1b             	shr    $0x1b,%ebx
  8017ed:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	c1 fa 05             	sar    $0x5,%edx
  8017f5:	c1 e2 02             	shl    $0x2,%edx
  8017f8:	89 c1                	mov    %eax,%ecx
  8017fa:	83 e1 1f             	and    $0x1f,%ecx
  8017fd:	29 d9                	sub    %ebx,%ecx
  8017ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801804:	d3 e0                	shl    %cl,%eax
  801806:	85 82 00 10 00 00    	test   %eax,0x1000(%edx)
  80180c:	75 24                	jne    801832 <fs_test+0xda>
  80180e:	c7 44 24 0c 93 3b 80 	movl   $0x803b93,0xc(%esp)
  801815:	00 
  801816:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  80181d:	00 
  80181e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801825:	00 
  801826:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  80182d:	e8 86 04 00 00       	call   801cb8 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801832:	8b 0d 88 b0 80 00    	mov    0x80b088,%ecx
  801838:	85 04 11             	test   %eax,(%ecx,%edx,1)
  80183b:	74 24                	je     801861 <fs_test+0x109>
  80183d:	c7 44 24 0c 08 3d 80 	movl   $0x803d08,0xc(%esp)
  801844:	00 
  801845:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  80184c:	00 
  80184d:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801854:	00 
  801855:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  80185c:	e8 57 04 00 00       	call   801cb8 <_panic>
	cprintf("alloc_block is good\n");
  801861:	c7 04 24 ae 3b 80 00 	movl   $0x803bae,(%esp)
  801868:	e8 10 05 00 00       	call   801d7d <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80186d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801870:	89 44 24 04          	mov    %eax,0x4(%esp)
  801874:	c7 04 24 c3 3b 80 00 	movl   $0x803bc3,(%esp)
  80187b:	e8 e6 f5 ff ff       	call   800e66 <file_open>
  801880:	85 c0                	test   %eax,%eax
  801882:	79 25                	jns    8018a9 <fs_test+0x151>
  801884:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801887:	74 40                	je     8018c9 <fs_test+0x171>
		panic("file_open /not-found: %e", r);
  801889:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80188d:	c7 44 24 08 ce 3b 80 	movl   $0x803bce,0x8(%esp)
  801894:	00 
  801895:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80189c:	00 
  80189d:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  8018a4:	e8 0f 04 00 00       	call   801cb8 <_panic>
	else if (r == 0)
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	75 1c                	jne    8018c9 <fs_test+0x171>
		panic("file_open /not-found succeeded!");
  8018ad:	c7 44 24 08 28 3d 80 	movl   $0x803d28,0x8(%esp)
  8018b4:	00 
  8018b5:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8018bc:	00 
  8018bd:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  8018c4:	e8 ef 03 00 00       	call   801cb8 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d0:	c7 04 24 e7 3b 80 00 	movl   $0x803be7,(%esp)
  8018d7:	e8 8a f5 ff ff       	call   800e66 <file_open>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	79 20                	jns    801900 <fs_test+0x1a8>
		panic("file_open /newmotd: %e", r);
  8018e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e4:	c7 44 24 08 f0 3b 80 	movl   $0x803bf0,0x8(%esp)
  8018eb:	00 
  8018ec:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8018f3:	00 
  8018f4:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  8018fb:	e8 b8 03 00 00       	call   801cb8 <_panic>
	cprintf("file_open is good\n");
  801900:	c7 04 24 07 3c 80 00 	movl   $0x803c07,(%esp)
  801907:	e8 71 04 00 00       	call   801d7d <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80190c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801913:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80191a:	00 
  80191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	e8 41 f2 ff ff       	call   800b67 <file_get_block>
  801926:	85 c0                	test   %eax,%eax
  801928:	79 20                	jns    80194a <fs_test+0x1f2>
		panic("file_get_block: %e", r);
  80192a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80192e:	c7 44 24 08 1a 3c 80 	movl   $0x803c1a,0x8(%esp)
  801935:	00 
  801936:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80193d:	00 
  80193e:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801945:	e8 6e 03 00 00       	call   801cb8 <_panic>
	if (strcmp(blk, msg) != 0)
  80194a:	8b 1d 94 3d 80 00    	mov    0x803d94,%ebx
  801950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801954:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801957:	89 04 24             	mov    %eax,(%esp)
  80195a:	e8 8a 0b 00 00       	call   8024e9 <strcmp>
  80195f:	85 c0                	test   %eax,%eax
  801961:	74 1c                	je     80197f <fs_test+0x227>
		panic("file_get_block returned wrong data");
  801963:	c7 44 24 08 48 3d 80 	movl   $0x803d48,0x8(%esp)
  80196a:	00 
  80196b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801972:	00 
  801973:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  80197a:	e8 39 03 00 00       	call   801cb8 <_panic>
	cprintf("file_get_block is good\n");
  80197f:	c7 04 24 2d 3c 80 00 	movl   $0x803c2d,(%esp)
  801986:	e8 f2 03 00 00       	call   801d7d <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80198b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198e:	0f b6 10             	movzbl (%eax),%edx
  801991:	88 10                	mov    %dl,(%eax)
	assert((vpt[VPN(blk)] & PTE_D));
  801993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801996:	c1 e8 0c             	shr    $0xc,%eax
  801999:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019a0:	a8 40                	test   $0x40,%al
  8019a2:	75 24                	jne    8019c8 <fs_test+0x270>
  8019a4:	c7 44 24 0c 46 3c 80 	movl   $0x803c46,0xc(%esp)
  8019ab:	00 
  8019ac:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8019b3:	00 
  8019b4:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8019bb:	00 
  8019bc:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  8019c3:	e8 f0 02 00 00       	call   801cb8 <_panic>
	file_flush(f);
  8019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 f1 f0 ff ff       	call   800ac4 <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  8019d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d6:	c1 e8 0c             	shr    $0xc,%eax
  8019d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019e0:	a8 40                	test   $0x40,%al
  8019e2:	74 24                	je     801a08 <fs_test+0x2b0>
  8019e4:	c7 44 24 0c 45 3c 80 	movl   $0x803c45,0xc(%esp)
  8019eb:	00 
  8019ec:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  8019f3:	00 
  8019f4:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8019fb:	00 
  8019fc:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801a03:	e8 b0 02 00 00       	call   801cb8 <_panic>
	cprintf("file_flush is good\n");
  801a08:	c7 04 24 5e 3c 80 00 	movl   $0x803c5e,(%esp)
  801a0f:	e8 69 03 00 00       	call   801d7d <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801a14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a1b:	00 
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 5d f0 ff ff       	call   800a84 <file_set_size>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	79 20                	jns    801a4b <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  801a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a2f:	c7 44 24 08 72 3c 80 	movl   $0x803c72,0x8(%esp)
  801a36:	00 
  801a37:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801a3e:	00 
  801a3f:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801a46:	e8 6d 02 00 00       	call   801cb8 <_panic>
	assert(f->f_direct[0] == 0);
  801a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4e:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801a55:	74 24                	je     801a7b <fs_test+0x323>
  801a57:	c7 44 24 0c 84 3c 80 	movl   $0x803c84,0xc(%esp)
  801a5e:	00 
  801a5f:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801a66:	00 
  801a67:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801a6e:	00 
  801a6f:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801a76:	e8 3d 02 00 00       	call   801cb8 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801a7b:	c1 e8 0c             	shr    $0xc,%eax
  801a7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a85:	a8 40                	test   $0x40,%al
  801a87:	74 24                	je     801aad <fs_test+0x355>
  801a89:	c7 44 24 0c 98 3c 80 	movl   $0x803c98,0xc(%esp)
  801a90:	00 
  801a91:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801a98:	00 
  801a99:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801aa0:	00 
  801aa1:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801aa8:	e8 0b 02 00 00       	call   801cb8 <_panic>
	cprintf("file_truncate is good\n");
  801aad:	c7 04 24 af 3c 80 00 	movl   $0x803caf,(%esp)
  801ab4:	e8 c4 02 00 00       	call   801d7d <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801ab9:	89 1c 24             	mov    %ebx,(%esp)
  801abc:	e8 4f 09 00 00       	call   802410 <strlen>
  801ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	89 04 24             	mov    %eax,(%esp)
  801acb:	e8 b4 ef ff ff       	call   800a84 <file_set_size>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	79 20                	jns    801af4 <fs_test+0x39c>
		panic("file_set_size 2: %e", r);
  801ad4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad8:	c7 44 24 08 c6 3c 80 	movl   $0x803cc6,0x8(%esp)
  801adf:	00 
  801ae0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801ae7:	00 
  801ae8:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801aef:	e8 c4 01 00 00       	call   801cb8 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	89 c2                	mov    %eax,%edx
  801af9:	c1 ea 0c             	shr    $0xc,%edx
  801afc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b03:	f6 c2 40             	test   $0x40,%dl
  801b06:	74 24                	je     801b2c <fs_test+0x3d4>
  801b08:	c7 44 24 0c 98 3c 80 	movl   $0x803c98,0xc(%esp)
  801b0f:	00 
  801b10:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801b17:	00 
  801b18:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801b1f:	00 
  801b20:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801b27:	e8 8c 01 00 00       	call   801cb8 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801b2c:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801b2f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3a:	00 
  801b3b:	89 04 24             	mov    %eax,(%esp)
  801b3e:	e8 24 f0 ff ff       	call   800b67 <file_get_block>
  801b43:	85 c0                	test   %eax,%eax
  801b45:	79 20                	jns    801b67 <fs_test+0x40f>
		panic("file_get_block 2: %e", r);
  801b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b4b:	c7 44 24 08 da 3c 80 	movl   $0x803cda,0x8(%esp)
  801b52:	00 
  801b53:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  801b5a:	00 
  801b5b:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801b62:	e8 51 01 00 00       	call   801cb8 <_panic>
	strcpy(blk, msg);
  801b67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	e8 e4 08 00 00       	call   80245a <strcpy>
	assert((vpt[VPN(blk)] & PTE_D));
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	c1 e8 0c             	shr    $0xc,%eax
  801b7c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b83:	a8 40                	test   $0x40,%al
  801b85:	75 24                	jne    801bab <fs_test+0x453>
  801b87:	c7 44 24 0c 46 3c 80 	movl   $0x803c46,0xc(%esp)
  801b8e:	00 
  801b8f:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801b96:	00 
  801b97:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801b9e:	00 
  801b9f:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801ba6:	e8 0d 01 00 00       	call   801cb8 <_panic>
	file_flush(f);
  801bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bae:	89 04 24             	mov    %eax,(%esp)
  801bb1:	e8 0e ef ff ff       	call   800ac4 <file_flush>
	assert(!(vpt[VPN(blk)] & PTE_D));
  801bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb9:	c1 e8 0c             	shr    $0xc,%eax
  801bbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bc3:	a8 40                	test   $0x40,%al
  801bc5:	74 24                	je     801beb <fs_test+0x493>
  801bc7:	c7 44 24 0c 45 3c 80 	movl   $0x803c45,0xc(%esp)
  801bce:	00 
  801bcf:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801bd6:	00 
  801bd7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801bde:	00 
  801bdf:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801be6:	e8 cd 00 00 00       	call   801cb8 <_panic>
	assert(!(vpt[VPN(f)] & PTE_D));
  801beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bee:	c1 e8 0c             	shr    $0xc,%eax
  801bf1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bf8:	a8 40                	test   $0x40,%al
  801bfa:	74 24                	je     801c20 <fs_test+0x4c8>
  801bfc:	c7 44 24 0c 98 3c 80 	movl   $0x803c98,0xc(%esp)
  801c03:	00 
  801c04:	c7 44 24 08 cd 38 80 	movl   $0x8038cd,0x8(%esp)
  801c0b:	00 
  801c0c:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  801c13:	00 
  801c14:	c7 04 24 79 3b 80 00 	movl   $0x803b79,(%esp)
  801c1b:	e8 98 00 00 00       	call   801cb8 <_panic>
	cprintf("file rewrite is good\n");
  801c20:	c7 04 24 ef 3c 80 00 	movl   $0x803cef,(%esp)
  801c27:	e8 51 01 00 00       	call   801d7d <cprintf>
}
  801c2c:	83 c4 24             	add    $0x24,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
	...

00801c34 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 18             	sub    $0x18,%esp
  801c3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c3d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c40:	8b 75 08             	mov    0x8(%ebp),%esi
  801c43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  801c46:	c7 05 90 b0 80 00 00 	movl   $0x0,0x80b090
  801c4d:	00 00 00 
	
	env = &envs[ENVX(sys_getenvid())];
  801c50:	e8 2c 0f 00 00       	call   802b81 <sys_getenvid>
  801c55:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c5a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c5d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c62:	a3 90 b0 80 00       	mov    %eax,0x80b090

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c67:	85 f6                	test   %esi,%esi
  801c69:	7e 07                	jle    801c72 <libmain+0x3e>
		binaryname = argv[0];
  801c6b:	8b 03                	mov    (%ebx),%eax
  801c6d:	a3 64 b0 80 00       	mov    %eax,0x80b064

	// call user main routine
	cprintf("calling here1234\n");
  801c72:	c7 04 24 98 3d 80 00 	movl   $0x803d98,(%esp)
  801c79:	e8 ff 00 00 00       	call   801d7d <cprintf>
	umain(argc, argv);
  801c7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c82:	89 34 24             	mov    %esi,(%esp)
  801c85:	e8 9e fa ff ff       	call   801728 <umain>

	// exit gracefully
	exit();
  801c8a:	e8 0d 00 00 00       	call   801c9c <exit>
}
  801c8f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c92:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c95:	89 ec                	mov    %ebp,%esp
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	00 00                	add    %al,(%eax)
	...

00801c9c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801ca2:	e8 c4 15 00 00       	call   80326b <close_all>
	sys_env_destroy(0);
  801ca7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cae:	e8 02 0f 00 00       	call   802bb5 <sys_env_destroy>
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    
  801cb5:	00 00                	add    %al,(%eax)
	...

00801cb8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 14             	sub    $0x14,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
  801cbf:	8d 5d 14             	lea    0x14(%ebp),%ebx
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801cc2:	a1 94 b0 80 00       	mov    0x80b094,%eax
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	74 10                	je     801cdb <_panic+0x23>
		cprintf("%s: ", argv0);
  801ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccf:	c7 04 24 c1 3d 80 00 	movl   $0x803dc1,(%esp)
  801cd6:	e8 a2 00 00 00       	call   801d7d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce9:	a1 64 b0 80 00       	mov    0x80b064,%eax
  801cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf2:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  801cf9:	e8 7f 00 00 00       	call   801d7d <cprintf>
	vcprintf(fmt, ap);
  801cfe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d02:	8b 45 10             	mov    0x10(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 0f 00 00 00       	call   801d1c <vcprintf>
	cprintf("\n");
  801d0d:	c7 04 24 fd 39 80 00 	movl   $0x8039fd,(%esp)
  801d14:	e8 64 00 00 00       	call   801d7d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d19:	cc                   	int3   
  801d1a:	eb fd                	jmp    801d19 <_panic+0x61>

00801d1c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801d25:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d2c:	00 00 00 
	b.cnt = 0;
  801d2f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d36:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d47:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d51:	c7 04 24 97 1d 80 00 	movl   $0x801d97,(%esp)
  801d58:	e8 d0 01 00 00       	call   801f2d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d5d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d67:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d6d:	89 04 24             	mov    %eax,(%esp)
  801d70:	e8 db 0a 00 00       	call   802850 <sys_cputs>

	return b.cnt;
}
  801d75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801d83:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 87 ff ff ff       	call   801d1c <vcprintf>
	va_end(ap);

	return cnt;
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	53                   	push   %ebx
  801d9b:	83 ec 14             	sub    $0x14,%esp
  801d9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801da1:	8b 03                	mov    (%ebx),%eax
  801da3:	8b 55 08             	mov    0x8(%ebp),%edx
  801da6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801daa:	83 c0 01             	add    $0x1,%eax
  801dad:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801daf:	3d ff 00 00 00       	cmp    $0xff,%eax
  801db4:	75 19                	jne    801dcf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801db6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801dbd:	00 
  801dbe:	8d 43 08             	lea    0x8(%ebx),%eax
  801dc1:	89 04 24             	mov    %eax,(%esp)
  801dc4:	e8 87 0a 00 00       	call   802850 <sys_cputs>
		b->idx = 0;
  801dc9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801dcf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801dd3:	83 c4 14             	add    $0x14,%esp
  801dd6:	5b                   	pop    %ebx
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	00 00                	add    %al,(%eax)
  801ddb:	00 00                	add    %al,(%eax)
  801ddd:	00 00                	add    %al,(%eax)
	...

00801de0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 4c             	sub    $0x4c,%esp
  801de9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801dec:	89 d6                	mov    %edx,%esi
  801dee:	8b 45 08             	mov    0x8(%ebp),%eax
  801df1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801df4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801dfa:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801e00:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801e03:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801e06:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e0b:	39 d1                	cmp    %edx,%ecx
  801e0d:	72 15                	jb     801e24 <printnum+0x44>
  801e0f:	77 07                	ja     801e18 <printnum+0x38>
  801e11:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e14:	39 d0                	cmp    %edx,%eax
  801e16:	76 0c                	jbe    801e24 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801e18:	83 eb 01             	sub    $0x1,%ebx
  801e1b:	85 db                	test   %ebx,%ebx
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	7f 61                	jg     801e83 <printnum+0xa3>
  801e22:	eb 70                	jmp    801e94 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801e24:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801e28:	83 eb 01             	sub    $0x1,%ebx
  801e2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e33:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e37:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  801e3b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801e3e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801e41:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801e44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e4f:	00 
  801e50:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e53:	89 04 24             	mov    %eax,(%esp)
  801e56:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801e59:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e5d:	e8 ee 17 00 00       	call   803650 <__udivdi3>
  801e62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801e65:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e70:	89 04 24             	mov    %eax,(%esp)
  801e73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e77:	89 f2                	mov    %esi,%edx
  801e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7c:	e8 5f ff ff ff       	call   801de0 <printnum>
  801e81:	eb 11                	jmp    801e94 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801e83:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e87:	89 3c 24             	mov    %edi,(%esp)
  801e8a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801e8d:	83 eb 01             	sub    $0x1,%ebx
  801e90:	85 db                	test   %ebx,%ebx
  801e92:	7f ef                	jg     801e83 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e98:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801e9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801eaa:	00 
  801eab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801eae:	89 14 24             	mov    %edx,(%esp)
  801eb1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801eb4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801eb8:	e8 c3 18 00 00       	call   803780 <__umoddi3>
  801ebd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec1:	0f be 80 e2 3d 80 00 	movsbl 0x803de2(%eax),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801ece:	83 c4 4c             	add    $0x4c,%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5f                   	pop    %edi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    

00801ed6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801ed9:	83 fa 01             	cmp    $0x1,%edx
  801edc:	7e 0e                	jle    801eec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801ede:	8b 10                	mov    (%eax),%edx
  801ee0:	8d 4a 08             	lea    0x8(%edx),%ecx
  801ee3:	89 08                	mov    %ecx,(%eax)
  801ee5:	8b 02                	mov    (%edx),%eax
  801ee7:	8b 52 04             	mov    0x4(%edx),%edx
  801eea:	eb 22                	jmp    801f0e <getuint+0x38>
	else if (lflag)
  801eec:	85 d2                	test   %edx,%edx
  801eee:	74 10                	je     801f00 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ef0:	8b 10                	mov    (%eax),%edx
  801ef2:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ef5:	89 08                	mov    %ecx,(%eax)
  801ef7:	8b 02                	mov    (%edx),%eax
  801ef9:	ba 00 00 00 00       	mov    $0x0,%edx
  801efe:	eb 0e                	jmp    801f0e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801f00:	8b 10                	mov    (%eax),%edx
  801f02:	8d 4a 04             	lea    0x4(%edx),%ecx
  801f05:	89 08                	mov    %ecx,(%eax)
  801f07:	8b 02                	mov    (%edx),%eax
  801f09:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

00801f10 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801f16:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801f1a:	8b 10                	mov    (%eax),%edx
  801f1c:	3b 50 04             	cmp    0x4(%eax),%edx
  801f1f:	73 0a                	jae    801f2b <sprintputch+0x1b>
		*b->buf++ = ch;
  801f21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f24:	88 0a                	mov    %cl,(%edx)
  801f26:	83 c2 01             	add    $0x1,%edx
  801f29:	89 10                	mov    %edx,(%eax)
}
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    

00801f2d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	57                   	push   %edi
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	83 ec 5c             	sub    $0x5c,%esp
  801f36:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f39:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801f3f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801f46:	eb 11                	jmp    801f59 <vprintfmt+0x2c>
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	0f 84 02 04 00 00    	je     802352 <vprintfmt+0x425>
				return;
			putch(ch, putdat);
  801f50:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f54:	89 04 24             	mov    %eax,(%esp)
  801f57:	ff d7                	call   *%edi
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801f59:	0f b6 03             	movzbl (%ebx),%eax
  801f5c:	83 c3 01             	add    $0x1,%ebx
  801f5f:	83 f8 25             	cmp    $0x25,%eax
  801f62:	75 e4                	jne    801f48 <vprintfmt+0x1b>
  801f64:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801f68:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801f6f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801f76:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801f7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f82:	eb 06                	jmp    801f8a <vprintfmt+0x5d>
  801f84:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801f88:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f8a:	0f b6 13             	movzbl (%ebx),%edx
  801f8d:	0f b6 c2             	movzbl %dl,%eax
  801f90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f93:	8d 43 01             	lea    0x1(%ebx),%eax
  801f96:	83 ea 23             	sub    $0x23,%edx
  801f99:	80 fa 55             	cmp    $0x55,%dl
  801f9c:	0f 87 93 03 00 00    	ja     802335 <vprintfmt+0x408>
  801fa2:	0f b6 d2             	movzbl %dl,%edx
  801fa5:	ff 24 95 20 3f 80 00 	jmp    *0x803f20(,%edx,4)
  801fac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801fb0:	eb d6                	jmp    801f88 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801fb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801fb5:	83 ea 30             	sub    $0x30,%edx
  801fb8:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  801fbb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801fbe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801fc1:	83 fb 09             	cmp    $0x9,%ebx
  801fc4:	77 4c                	ja     802012 <vprintfmt+0xe5>
  801fc6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801fc9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801fcc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801fcf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801fd2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801fd6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801fd9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801fdc:	83 fb 09             	cmp    $0x9,%ebx
  801fdf:	76 eb                	jbe    801fcc <vprintfmt+0x9f>
  801fe1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801fe4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801fe7:	eb 29                	jmp    802012 <vprintfmt+0xe5>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801fe9:	8b 55 14             	mov    0x14(%ebp),%edx
  801fec:	8d 5a 04             	lea    0x4(%edx),%ebx
  801fef:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801ff2:	8b 12                	mov    (%edx),%edx
  801ff4:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  801ff7:	eb 19                	jmp    802012 <vprintfmt+0xe5>

		case '.':
			if (width < 0)
  801ff9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ffc:	c1 fa 1f             	sar    $0x1f,%edx
  801fff:	f7 d2                	not    %edx
  802001:	21 55 e4             	and    %edx,-0x1c(%ebp)
  802004:	eb 82                	jmp    801f88 <vprintfmt+0x5b>
  802006:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80200d:	e9 76 ff ff ff       	jmp    801f88 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  802012:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  802016:	0f 89 6c ff ff ff    	jns    801f88 <vprintfmt+0x5b>
  80201c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80201f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802022:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802025:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802028:	e9 5b ff ff ff       	jmp    801f88 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80202d:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  802030:	e9 53 ff ff ff       	jmp    801f88 <vprintfmt+0x5b>
  802035:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  802038:	8b 45 14             	mov    0x14(%ebp),%eax
  80203b:	8d 50 04             	lea    0x4(%eax),%edx
  80203e:	89 55 14             	mov    %edx,0x14(%ebp)
  802041:	89 74 24 04          	mov    %esi,0x4(%esp)
  802045:	8b 00                	mov    (%eax),%eax
  802047:	89 04 24             	mov    %eax,(%esp)
  80204a:	ff d7                	call   *%edi
  80204c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80204f:	e9 05 ff ff ff       	jmp    801f59 <vprintfmt+0x2c>
  802054:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  802057:	8b 45 14             	mov    0x14(%ebp),%eax
  80205a:	8d 50 04             	lea    0x4(%eax),%edx
  80205d:	89 55 14             	mov    %edx,0x14(%ebp)
  802060:	8b 00                	mov    (%eax),%eax
  802062:	89 c2                	mov    %eax,%edx
  802064:	c1 fa 1f             	sar    $0x1f,%edx
  802067:	31 d0                	xor    %edx,%eax
  802069:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80206b:	83 f8 0f             	cmp    $0xf,%eax
  80206e:	7f 0b                	jg     80207b <vprintfmt+0x14e>
  802070:	8b 14 85 80 40 80 00 	mov    0x804080(,%eax,4),%edx
  802077:	85 d2                	test   %edx,%edx
  802079:	75 20                	jne    80209b <vprintfmt+0x16e>
				printfmt(putch, putdat, "error %d", err);
  80207b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207f:	c7 44 24 08 f3 3d 80 	movl   $0x803df3,0x8(%esp)
  802086:	00 
  802087:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208b:	89 3c 24             	mov    %edi,(%esp)
  80208e:	e8 47 03 00 00       	call   8023da <printfmt>
  802093:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  802096:	e9 be fe ff ff       	jmp    801f59 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80209b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80209f:	c7 44 24 08 df 38 80 	movl   $0x8038df,0x8(%esp)
  8020a6:	00 
  8020a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ab:	89 3c 24             	mov    %edi,(%esp)
  8020ae:	e8 27 03 00 00       	call   8023da <printfmt>
  8020b3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8020b6:	e9 9e fe ff ff       	jmp    801f59 <vprintfmt+0x2c>
  8020bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8020be:	89 c3                	mov    %eax,%ebx
  8020c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8020c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8020cc:	8d 50 04             	lea    0x4(%eax),%edx
  8020cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8020d2:	8b 00                	mov    (%eax),%eax
  8020d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	75 07                	jne    8020e2 <vprintfmt+0x1b5>
  8020db:	c7 45 e0 fc 3d 80 00 	movl   $0x803dfc,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8020e2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8020e6:	7e 06                	jle    8020ee <vprintfmt+0x1c1>
  8020e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8020ec:	75 13                	jne    802101 <vprintfmt+0x1d4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8020ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8020f1:	0f be 02             	movsbl (%edx),%eax
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	0f 85 99 00 00 00    	jne    802195 <vprintfmt+0x268>
  8020fc:	e9 86 00 00 00       	jmp    802187 <vprintfmt+0x25a>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802101:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802105:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802108:	89 0c 24             	mov    %ecx,(%esp)
  80210b:	e8 1b 03 00 00       	call   80242b <strnlen>
  802110:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  802113:	29 c2                	sub    %eax,%edx
  802115:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802118:	85 d2                	test   %edx,%edx
  80211a:	7e d2                	jle    8020ee <vprintfmt+0x1c1>
					putch(padc, putdat);
  80211c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  802120:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802123:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  802126:	89 d3                	mov    %edx,%ebx
  802128:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80212f:	89 04 24             	mov    %eax,(%esp)
  802132:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802134:	83 eb 01             	sub    $0x1,%ebx
  802137:	85 db                	test   %ebx,%ebx
  802139:	7f ed                	jg     802128 <vprintfmt+0x1fb>
  80213b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80213e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  802145:	eb a7                	jmp    8020ee <vprintfmt+0x1c1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802147:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80214b:	74 18                	je     802165 <vprintfmt+0x238>
  80214d:	8d 50 e0             	lea    -0x20(%eax),%edx
  802150:	83 fa 5e             	cmp    $0x5e,%edx
  802153:	76 10                	jbe    802165 <vprintfmt+0x238>
					putch('?', putdat);
  802155:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802159:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  802160:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802163:	eb 0a                	jmp    80216f <vprintfmt+0x242>
					putch('?', putdat);
				else
					putch(ch, putdat);
  802165:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802169:	89 04 24             	mov    %eax,(%esp)
  80216c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80216f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  802173:	0f be 03             	movsbl (%ebx),%eax
  802176:	85 c0                	test   %eax,%eax
  802178:	74 05                	je     80217f <vprintfmt+0x252>
  80217a:	83 c3 01             	add    $0x1,%ebx
  80217d:	eb 29                	jmp    8021a8 <vprintfmt+0x27b>
  80217f:	89 fe                	mov    %edi,%esi
  802181:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802184:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802187:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80218b:	7f 2e                	jg     8021bb <vprintfmt+0x28e>
  80218d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  802190:	e9 c4 fd ff ff       	jmp    801f59 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802195:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802198:	83 c2 01             	add    $0x1,%edx
  80219b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80219e:	89 f7                	mov    %esi,%edi
  8021a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8021a3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8021a6:	89 d3                	mov    %edx,%ebx
  8021a8:	85 f6                	test   %esi,%esi
  8021aa:	78 9b                	js     802147 <vprintfmt+0x21a>
  8021ac:	83 ee 01             	sub    $0x1,%esi
  8021af:	79 96                	jns    802147 <vprintfmt+0x21a>
  8021b1:	89 fe                	mov    %edi,%esi
  8021b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8021b6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8021b9:	eb cc                	jmp    802187 <vprintfmt+0x25a>
  8021bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8021be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8021c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8021cc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8021ce:	83 eb 01             	sub    $0x1,%ebx
  8021d1:	85 db                	test   %ebx,%ebx
  8021d3:	7f ec                	jg     8021c1 <vprintfmt+0x294>
  8021d5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8021d8:	e9 7c fd ff ff       	jmp    801f59 <vprintfmt+0x2c>
  8021dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8021e0:	83 f9 01             	cmp    $0x1,%ecx
  8021e3:	7e 16                	jle    8021fb <vprintfmt+0x2ce>
		return va_arg(*ap, long long);
  8021e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e8:	8d 50 08             	lea    0x8(%eax),%edx
  8021eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8021ee:	8b 10                	mov    (%eax),%edx
  8021f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8021f3:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8021f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8021f9:	eb 32                	jmp    80222d <vprintfmt+0x300>
	else if (lflag)
  8021fb:	85 c9                	test   %ecx,%ecx
  8021fd:	74 18                	je     802217 <vprintfmt+0x2ea>
		return va_arg(*ap, long);
  8021ff:	8b 45 14             	mov    0x14(%ebp),%eax
  802202:	8d 50 04             	lea    0x4(%eax),%edx
  802205:	89 55 14             	mov    %edx,0x14(%ebp)
  802208:	8b 00                	mov    (%eax),%eax
  80220a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80220d:	89 c1                	mov    %eax,%ecx
  80220f:	c1 f9 1f             	sar    $0x1f,%ecx
  802212:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802215:	eb 16                	jmp    80222d <vprintfmt+0x300>
	else
		return va_arg(*ap, int);
  802217:	8b 45 14             	mov    0x14(%ebp),%eax
  80221a:	8d 50 04             	lea    0x4(%eax),%edx
  80221d:	89 55 14             	mov    %edx,0x14(%ebp)
  802220:	8b 00                	mov    (%eax),%eax
  802222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802225:	89 c2                	mov    %eax,%edx
  802227:	c1 fa 1f             	sar    $0x1f,%edx
  80222a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80222d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802230:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802233:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  802238:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80223c:	0f 89 b1 00 00 00    	jns    8022f3 <vprintfmt+0x3c6>
				putch('-', putdat);
  802242:	89 74 24 04          	mov    %esi,0x4(%esp)
  802246:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80224d:	ff d7                	call   *%edi
				num = -(long long) num;
  80224f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802252:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802255:	f7 d8                	neg    %eax
  802257:	83 d2 00             	adc    $0x0,%edx
  80225a:	f7 da                	neg    %edx
  80225c:	e9 92 00 00 00       	jmp    8022f3 <vprintfmt+0x3c6>
  802261:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802264:	89 ca                	mov    %ecx,%edx
  802266:	8d 45 14             	lea    0x14(%ebp),%eax
  802269:	e8 68 fc ff ff       	call   801ed6 <getuint>
  80226e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  802273:	eb 7e                	jmp    8022f3 <vprintfmt+0x3c6>
  802275:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  802278:	89 ca                	mov    %ecx,%edx
  80227a:	8d 45 14             	lea    0x14(%ebp),%eax
  80227d:	e8 54 fc ff ff       	call   801ed6 <getuint>
			if ((long long) num < 0) {
  802282:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802285:	89 55 dc             	mov    %edx,-0x24(%ebp)
  802288:	bb 08 00 00 00       	mov    $0x8,%ebx
  80228d:	85 d2                	test   %edx,%edx
  80228f:	79 62                	jns    8022f3 <vprintfmt+0x3c6>
				putch('-', putdat);
  802291:	89 74 24 04          	mov    %esi,0x4(%esp)
  802295:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80229c:	ff d7                	call   *%edi
				num = -(long long) num;
  80229e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8022a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8022a4:	f7 d8                	neg    %eax
  8022a6:	83 d2 00             	adc    $0x0,%edx
  8022a9:	f7 da                	neg    %edx
  8022ab:	eb 46                	jmp    8022f3 <vprintfmt+0x3c6>
  8022ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 8;
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8022b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8022bb:	ff d7                	call   *%edi
			putch('x', putdat);
  8022bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8022c8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8022ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8022cd:	8d 50 04             	lea    0x4(%eax),%edx
  8022d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8022d3:	8b 00                	mov    (%eax),%eax
  8022d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8022da:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8022df:	eb 12                	jmp    8022f3 <vprintfmt+0x3c6>
  8022e1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8022e4:	89 ca                	mov    %ecx,%edx
  8022e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8022e9:	e8 e8 fb ff ff       	call   801ed6 <getuint>
  8022ee:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8022f3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8022f7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8022fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802302:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802306:	89 04 24             	mov    %eax,(%esp)
  802309:	89 54 24 04          	mov    %edx,0x4(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	89 f8                	mov    %edi,%eax
  802311:	e8 ca fa ff ff       	call   801de0 <printnum>
  802316:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  802319:	e9 3b fc ff ff       	jmp    801f59 <vprintfmt+0x2c>
  80231e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  802321:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 14 24             	mov    %edx,(%esp)
  80232b:	ff d7                	call   *%edi
  80232d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  802330:	e9 24 fc ff ff       	jmp    801f59 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802335:	89 74 24 04          	mov    %esi,0x4(%esp)
  802339:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802340:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802342:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802345:	80 38 25             	cmpb   $0x25,(%eax)
  802348:	0f 84 0b fc ff ff    	je     801f59 <vprintfmt+0x2c>
  80234e:	89 c3                	mov    %eax,%ebx
  802350:	eb f0                	jmp    802342 <vprintfmt+0x415>
				/* do nothing */;
			break;
		}
	}
}
  802352:	83 c4 5c             	add    $0x5c,%esp
  802355:	5b                   	pop    %ebx
  802356:	5e                   	pop    %esi
  802357:	5f                   	pop    %edi
  802358:	5d                   	pop    %ebp
  802359:	c3                   	ret    

0080235a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	83 ec 28             	sub    $0x28,%esp
  802360:	8b 45 08             	mov    0x8(%ebp),%eax
  802363:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  802366:	85 c0                	test   %eax,%eax
  802368:	74 04                	je     80236e <vsnprintf+0x14>
  80236a:	85 d2                	test   %edx,%edx
  80236c:	7f 07                	jg     802375 <vsnprintf+0x1b>
  80236e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802373:	eb 3b                	jmp    8023b0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  802375:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802378:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80237c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80237f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802386:	8b 45 14             	mov    0x14(%ebp),%eax
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	8b 45 10             	mov    0x10(%ebp),%eax
  802390:	89 44 24 08          	mov    %eax,0x8(%esp)
  802394:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239b:	c7 04 24 10 1f 80 00 	movl   $0x801f10,(%esp)
  8023a2:	e8 86 fb ff ff       	call   801f2d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8023a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8023aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8023ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    

008023b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8023b8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8023bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8023c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d0:	89 04 24             	mov    %eax,(%esp)
  8023d3:	e8 82 ff ff ff       	call   80235a <vsnprintf>
	va_end(ap);

	return rc;
}
  8023d8:	c9                   	leave  
  8023d9:	c3                   	ret    

008023da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8023da:	55                   	push   %ebp
  8023db:	89 e5                	mov    %esp,%ebp
  8023dd:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8023e0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8023e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f8:	89 04 24             	mov    %eax,(%esp)
  8023fb:	e8 2d fb ff ff       	call   801f2d <vprintfmt>
	va_end(ap);
}
  802400:	c9                   	leave  
  802401:	c3                   	ret    
	...

00802410 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802416:	b8 00 00 00 00       	mov    $0x0,%eax
  80241b:	80 3a 00             	cmpb   $0x0,(%edx)
  80241e:	74 09                	je     802429 <strlen+0x19>
		n++;
  802420:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802423:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802427:	75 f7                	jne    802420 <strlen+0x10>
		n++;
	return n;
}
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    

0080242b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	53                   	push   %ebx
  80242f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802435:	85 c9                	test   %ecx,%ecx
  802437:	74 19                	je     802452 <strnlen+0x27>
  802439:	80 3b 00             	cmpb   $0x0,(%ebx)
  80243c:	74 14                	je     802452 <strnlen+0x27>
  80243e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802443:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802446:	39 c8                	cmp    %ecx,%eax
  802448:	74 0d                	je     802457 <strnlen+0x2c>
  80244a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80244e:	75 f3                	jne    802443 <strnlen+0x18>
  802450:	eb 05                	jmp    802457 <strnlen+0x2c>
  802452:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  802457:	5b                   	pop    %ebx
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    

0080245a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	53                   	push   %ebx
  80245e:	8b 45 08             	mov    0x8(%ebp),%eax
  802461:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802464:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802469:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80246d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  802470:	83 c2 01             	add    $0x1,%edx
  802473:	84 c9                	test   %cl,%cl
  802475:	75 f2                	jne    802469 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  802477:	5b                   	pop    %ebx
  802478:	5d                   	pop    %ebp
  802479:	c3                   	ret    

0080247a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	56                   	push   %esi
  80247e:	53                   	push   %ebx
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
  802482:	8b 55 0c             	mov    0xc(%ebp),%edx
  802485:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802488:	85 f6                	test   %esi,%esi
  80248a:	74 18                	je     8024a4 <strncpy+0x2a>
  80248c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  802491:	0f b6 1a             	movzbl (%edx),%ebx
  802494:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802497:	80 3a 01             	cmpb   $0x1,(%edx)
  80249a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80249d:	83 c1 01             	add    $0x1,%ecx
  8024a0:	39 ce                	cmp    %ecx,%esi
  8024a2:	77 ed                	ja     802491 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    

008024a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	56                   	push   %esi
  8024ac:	53                   	push   %ebx
  8024ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8024b6:	89 f0                	mov    %esi,%eax
  8024b8:	85 c9                	test   %ecx,%ecx
  8024ba:	74 27                	je     8024e3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8024bc:	83 e9 01             	sub    $0x1,%ecx
  8024bf:	74 1d                	je     8024de <strlcpy+0x36>
  8024c1:	0f b6 1a             	movzbl (%edx),%ebx
  8024c4:	84 db                	test   %bl,%bl
  8024c6:	74 16                	je     8024de <strlcpy+0x36>
			*dst++ = *src++;
  8024c8:	88 18                	mov    %bl,(%eax)
  8024ca:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8024cd:	83 e9 01             	sub    $0x1,%ecx
  8024d0:	74 0e                	je     8024e0 <strlcpy+0x38>
			*dst++ = *src++;
  8024d2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8024d5:	0f b6 1a             	movzbl (%edx),%ebx
  8024d8:	84 db                	test   %bl,%bl
  8024da:	75 ec                	jne    8024c8 <strlcpy+0x20>
  8024dc:	eb 02                	jmp    8024e0 <strlcpy+0x38>
  8024de:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8024e0:	c6 00 00             	movb   $0x0,(%eax)
  8024e3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    

008024e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8024f2:	0f b6 01             	movzbl (%ecx),%eax
  8024f5:	84 c0                	test   %al,%al
  8024f7:	74 15                	je     80250e <strcmp+0x25>
  8024f9:	3a 02                	cmp    (%edx),%al
  8024fb:	75 11                	jne    80250e <strcmp+0x25>
		p++, q++;
  8024fd:	83 c1 01             	add    $0x1,%ecx
  802500:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802503:	0f b6 01             	movzbl (%ecx),%eax
  802506:	84 c0                	test   %al,%al
  802508:	74 04                	je     80250e <strcmp+0x25>
  80250a:	3a 02                	cmp    (%edx),%al
  80250c:	74 ef                	je     8024fd <strcmp+0x14>
  80250e:	0f b6 c0             	movzbl %al,%eax
  802511:	0f b6 12             	movzbl (%edx),%edx
  802514:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    

00802518 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
  80251b:	53                   	push   %ebx
  80251c:	8b 55 08             	mov    0x8(%ebp),%edx
  80251f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802522:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802525:	85 c0                	test   %eax,%eax
  802527:	74 23                	je     80254c <strncmp+0x34>
  802529:	0f b6 1a             	movzbl (%edx),%ebx
  80252c:	84 db                	test   %bl,%bl
  80252e:	74 24                	je     802554 <strncmp+0x3c>
  802530:	3a 19                	cmp    (%ecx),%bl
  802532:	75 20                	jne    802554 <strncmp+0x3c>
  802534:	83 e8 01             	sub    $0x1,%eax
  802537:	74 13                	je     80254c <strncmp+0x34>
		n--, p++, q++;
  802539:	83 c2 01             	add    $0x1,%edx
  80253c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80253f:	0f b6 1a             	movzbl (%edx),%ebx
  802542:	84 db                	test   %bl,%bl
  802544:	74 0e                	je     802554 <strncmp+0x3c>
  802546:	3a 19                	cmp    (%ecx),%bl
  802548:	74 ea                	je     802534 <strncmp+0x1c>
  80254a:	eb 08                	jmp    802554 <strncmp+0x3c>
  80254c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802551:	5b                   	pop    %ebx
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802554:	0f b6 02             	movzbl (%edx),%eax
  802557:	0f b6 11             	movzbl (%ecx),%edx
  80255a:	29 d0                	sub    %edx,%eax
  80255c:	eb f3                	jmp    802551 <strncmp+0x39>

0080255e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	8b 45 08             	mov    0x8(%ebp),%eax
  802564:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802568:	0f b6 10             	movzbl (%eax),%edx
  80256b:	84 d2                	test   %dl,%dl
  80256d:	74 15                	je     802584 <strchr+0x26>
		if (*s == c)
  80256f:	38 ca                	cmp    %cl,%dl
  802571:	75 07                	jne    80257a <strchr+0x1c>
  802573:	eb 14                	jmp    802589 <strchr+0x2b>
  802575:	38 ca                	cmp    %cl,%dl
  802577:	90                   	nop
  802578:	74 0f                	je     802589 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80257a:	83 c0 01             	add    $0x1,%eax
  80257d:	0f b6 10             	movzbl (%eax),%edx
  802580:	84 d2                	test   %dl,%dl
  802582:	75 f1                	jne    802575 <strchr+0x17>
  802584:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  802589:	5d                   	pop    %ebp
  80258a:	c3                   	ret    

0080258b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80258b:	55                   	push   %ebp
  80258c:	89 e5                	mov    %esp,%ebp
  80258e:	8b 45 08             	mov    0x8(%ebp),%eax
  802591:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802595:	0f b6 10             	movzbl (%eax),%edx
  802598:	84 d2                	test   %dl,%dl
  80259a:	74 18                	je     8025b4 <strfind+0x29>
		if (*s == c)
  80259c:	38 ca                	cmp    %cl,%dl
  80259e:	75 0a                	jne    8025aa <strfind+0x1f>
  8025a0:	eb 12                	jmp    8025b4 <strfind+0x29>
  8025a2:	38 ca                	cmp    %cl,%dl
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	74 0a                	je     8025b4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8025aa:	83 c0 01             	add    $0x1,%eax
  8025ad:	0f b6 10             	movzbl (%eax),%edx
  8025b0:	84 d2                	test   %dl,%dl
  8025b2:	75 ee                	jne    8025a2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8025b4:	5d                   	pop    %ebp
  8025b5:	c3                   	ret    

008025b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8025b6:	55                   	push   %ebp
  8025b7:	89 e5                	mov    %esp,%ebp
  8025b9:	83 ec 0c             	sub    $0xc,%esp
  8025bc:	89 1c 24             	mov    %ebx,(%esp)
  8025bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8025c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8025d0:	85 c9                	test   %ecx,%ecx
  8025d2:	74 30                	je     802604 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8025d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8025da:	75 25                	jne    802601 <memset+0x4b>
  8025dc:	f6 c1 03             	test   $0x3,%cl
  8025df:	75 20                	jne    802601 <memset+0x4b>
		c &= 0xFF;
  8025e1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8025e4:	89 d3                	mov    %edx,%ebx
  8025e6:	c1 e3 08             	shl    $0x8,%ebx
  8025e9:	89 d6                	mov    %edx,%esi
  8025eb:	c1 e6 18             	shl    $0x18,%esi
  8025ee:	89 d0                	mov    %edx,%eax
  8025f0:	c1 e0 10             	shl    $0x10,%eax
  8025f3:	09 f0                	or     %esi,%eax
  8025f5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8025f7:	09 d8                	or     %ebx,%eax
  8025f9:	c1 e9 02             	shr    $0x2,%ecx
  8025fc:	fc                   	cld    
  8025fd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8025ff:	eb 03                	jmp    802604 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802601:	fc                   	cld    
  802602:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802604:	89 f8                	mov    %edi,%eax
  802606:	8b 1c 24             	mov    (%esp),%ebx
  802609:	8b 74 24 04          	mov    0x4(%esp),%esi
  80260d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802611:	89 ec                	mov    %ebp,%esp
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    

00802615 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	83 ec 08             	sub    $0x8,%esp
  80261b:	89 34 24             	mov    %esi,(%esp)
  80261e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802622:	8b 45 08             	mov    0x8(%ebp),%eax
  802625:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802628:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80262b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80262d:	39 c6                	cmp    %eax,%esi
  80262f:	73 35                	jae    802666 <memmove+0x51>
  802631:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802634:	39 d0                	cmp    %edx,%eax
  802636:	73 2e                	jae    802666 <memmove+0x51>
		s += n;
		d += n;
  802638:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80263a:	f6 c2 03             	test   $0x3,%dl
  80263d:	75 1b                	jne    80265a <memmove+0x45>
  80263f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802645:	75 13                	jne    80265a <memmove+0x45>
  802647:	f6 c1 03             	test   $0x3,%cl
  80264a:	75 0e                	jne    80265a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80264c:	83 ef 04             	sub    $0x4,%edi
  80264f:	8d 72 fc             	lea    -0x4(%edx),%esi
  802652:	c1 e9 02             	shr    $0x2,%ecx
  802655:	fd                   	std    
  802656:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802658:	eb 09                	jmp    802663 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80265a:	83 ef 01             	sub    $0x1,%edi
  80265d:	8d 72 ff             	lea    -0x1(%edx),%esi
  802660:	fd                   	std    
  802661:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802663:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802664:	eb 20                	jmp    802686 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802666:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80266c:	75 15                	jne    802683 <memmove+0x6e>
  80266e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802674:	75 0d                	jne    802683 <memmove+0x6e>
  802676:	f6 c1 03             	test   $0x3,%cl
  802679:	75 08                	jne    802683 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80267b:	c1 e9 02             	shr    $0x2,%ecx
  80267e:	fc                   	cld    
  80267f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802681:	eb 03                	jmp    802686 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802683:	fc                   	cld    
  802684:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802686:	8b 34 24             	mov    (%esp),%esi
  802689:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80268d:	89 ec                	mov    %ebp,%esp
  80268f:	5d                   	pop    %ebp
  802690:	c3                   	ret    

00802691 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  802691:	55                   	push   %ebp
  802692:	89 e5                	mov    %esp,%ebp
  802694:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802697:	8b 45 10             	mov    0x10(%ebp),%eax
  80269a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80269e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a8:	89 04 24             	mov    %eax,(%esp)
  8026ab:	e8 65 ff ff ff       	call   802615 <memmove>
}
  8026b0:	c9                   	leave  
  8026b1:	c3                   	ret    

008026b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8026b2:	55                   	push   %ebp
  8026b3:	89 e5                	mov    %esp,%ebp
  8026b5:	57                   	push   %edi
  8026b6:	56                   	push   %esi
  8026b7:	53                   	push   %ebx
  8026b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8026bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8026c1:	85 c9                	test   %ecx,%ecx
  8026c3:	74 36                	je     8026fb <memcmp+0x49>
		if (*s1 != *s2)
  8026c5:	0f b6 06             	movzbl (%esi),%eax
  8026c8:	0f b6 1f             	movzbl (%edi),%ebx
  8026cb:	38 d8                	cmp    %bl,%al
  8026cd:	74 20                	je     8026ef <memcmp+0x3d>
  8026cf:	eb 14                	jmp    8026e5 <memcmp+0x33>
  8026d1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8026d6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8026db:	83 c2 01             	add    $0x1,%edx
  8026de:	83 e9 01             	sub    $0x1,%ecx
  8026e1:	38 d8                	cmp    %bl,%al
  8026e3:	74 12                	je     8026f7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8026e5:	0f b6 c0             	movzbl %al,%eax
  8026e8:	0f b6 db             	movzbl %bl,%ebx
  8026eb:	29 d8                	sub    %ebx,%eax
  8026ed:	eb 11                	jmp    802700 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8026ef:	83 e9 01             	sub    $0x1,%ecx
  8026f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8026f7:	85 c9                	test   %ecx,%ecx
  8026f9:	75 d6                	jne    8026d1 <memcmp+0x1f>
  8026fb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802700:	5b                   	pop    %ebx
  802701:	5e                   	pop    %esi
  802702:	5f                   	pop    %edi
  802703:	5d                   	pop    %ebp
  802704:	c3                   	ret    

00802705 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802705:	55                   	push   %ebp
  802706:	89 e5                	mov    %esp,%ebp
  802708:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80270b:	89 c2                	mov    %eax,%edx
  80270d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802710:	39 d0                	cmp    %edx,%eax
  802712:	73 15                	jae    802729 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802714:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802718:	38 08                	cmp    %cl,(%eax)
  80271a:	75 06                	jne    802722 <memfind+0x1d>
  80271c:	eb 0b                	jmp    802729 <memfind+0x24>
  80271e:	38 08                	cmp    %cl,(%eax)
  802720:	74 07                	je     802729 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802722:	83 c0 01             	add    $0x1,%eax
  802725:	39 c2                	cmp    %eax,%edx
  802727:	77 f5                	ja     80271e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    

0080272b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80272b:	55                   	push   %ebp
  80272c:	89 e5                	mov    %esp,%ebp
  80272e:	57                   	push   %edi
  80272f:	56                   	push   %esi
  802730:	53                   	push   %ebx
  802731:	83 ec 04             	sub    $0x4,%esp
  802734:	8b 55 08             	mov    0x8(%ebp),%edx
  802737:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80273a:	0f b6 02             	movzbl (%edx),%eax
  80273d:	3c 20                	cmp    $0x20,%al
  80273f:	74 04                	je     802745 <strtol+0x1a>
  802741:	3c 09                	cmp    $0x9,%al
  802743:	75 0e                	jne    802753 <strtol+0x28>
		s++;
  802745:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802748:	0f b6 02             	movzbl (%edx),%eax
  80274b:	3c 20                	cmp    $0x20,%al
  80274d:	74 f6                	je     802745 <strtol+0x1a>
  80274f:	3c 09                	cmp    $0x9,%al
  802751:	74 f2                	je     802745 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802753:	3c 2b                	cmp    $0x2b,%al
  802755:	75 0c                	jne    802763 <strtol+0x38>
		s++;
  802757:	83 c2 01             	add    $0x1,%edx
  80275a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802761:	eb 15                	jmp    802778 <strtol+0x4d>
	else if (*s == '-')
  802763:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80276a:	3c 2d                	cmp    $0x2d,%al
  80276c:	75 0a                	jne    802778 <strtol+0x4d>
		s++, neg = 1;
  80276e:	83 c2 01             	add    $0x1,%edx
  802771:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802778:	85 db                	test   %ebx,%ebx
  80277a:	0f 94 c0             	sete   %al
  80277d:	74 05                	je     802784 <strtol+0x59>
  80277f:	83 fb 10             	cmp    $0x10,%ebx
  802782:	75 18                	jne    80279c <strtol+0x71>
  802784:	80 3a 30             	cmpb   $0x30,(%edx)
  802787:	75 13                	jne    80279c <strtol+0x71>
  802789:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80278d:	8d 76 00             	lea    0x0(%esi),%esi
  802790:	75 0a                	jne    80279c <strtol+0x71>
		s += 2, base = 16;
  802792:	83 c2 02             	add    $0x2,%edx
  802795:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80279a:	eb 15                	jmp    8027b1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80279c:	84 c0                	test   %al,%al
  80279e:	66 90                	xchg   %ax,%ax
  8027a0:	74 0f                	je     8027b1 <strtol+0x86>
  8027a2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8027a7:	80 3a 30             	cmpb   $0x30,(%edx)
  8027aa:	75 05                	jne    8027b1 <strtol+0x86>
		s++, base = 8;
  8027ac:	83 c2 01             	add    $0x1,%edx
  8027af:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8027b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8027b6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8027b8:	0f b6 0a             	movzbl (%edx),%ecx
  8027bb:	89 cf                	mov    %ecx,%edi
  8027bd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8027c0:	80 fb 09             	cmp    $0x9,%bl
  8027c3:	77 08                	ja     8027cd <strtol+0xa2>
			dig = *s - '0';
  8027c5:	0f be c9             	movsbl %cl,%ecx
  8027c8:	83 e9 30             	sub    $0x30,%ecx
  8027cb:	eb 1e                	jmp    8027eb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8027cd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8027d0:	80 fb 19             	cmp    $0x19,%bl
  8027d3:	77 08                	ja     8027dd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8027d5:	0f be c9             	movsbl %cl,%ecx
  8027d8:	83 e9 57             	sub    $0x57,%ecx
  8027db:	eb 0e                	jmp    8027eb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8027dd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8027e0:	80 fb 19             	cmp    $0x19,%bl
  8027e3:	77 15                	ja     8027fa <strtol+0xcf>
			dig = *s - 'A' + 10;
  8027e5:	0f be c9             	movsbl %cl,%ecx
  8027e8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8027eb:	39 f1                	cmp    %esi,%ecx
  8027ed:	7d 0b                	jge    8027fa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8027ef:	83 c2 01             	add    $0x1,%edx
  8027f2:	0f af c6             	imul   %esi,%eax
  8027f5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8027f8:	eb be                	jmp    8027b8 <strtol+0x8d>
  8027fa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8027fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802800:	74 05                	je     802807 <strtol+0xdc>
		*endptr = (char *) s;
  802802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802805:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802807:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80280b:	74 04                	je     802811 <strtol+0xe6>
  80280d:	89 c8                	mov    %ecx,%eax
  80280f:	f7 d8                	neg    %eax
}
  802811:	83 c4 04             	add    $0x4,%esp
  802814:	5b                   	pop    %ebx
  802815:	5e                   	pop    %esi
  802816:	5f                   	pop    %edi
  802817:	5d                   	pop    %ebp
  802818:	c3                   	ret    
  802819:	00 00                	add    %al,(%eax)
	...

0080281c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80281c:	55                   	push   %ebp
  80281d:	89 e5                	mov    %esp,%ebp
  80281f:	83 ec 0c             	sub    $0xc,%esp
  802822:	89 1c 24             	mov    %ebx,(%esp)
  802825:	89 74 24 04          	mov    %esi,0x4(%esp)
  802829:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80282d:	ba 00 00 00 00       	mov    $0x0,%edx
  802832:	b8 01 00 00 00       	mov    $0x1,%eax
  802837:	89 d1                	mov    %edx,%ecx
  802839:	89 d3                	mov    %edx,%ebx
  80283b:	89 d7                	mov    %edx,%edi
  80283d:	89 d6                	mov    %edx,%esi
  80283f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802841:	8b 1c 24             	mov    (%esp),%ebx
  802844:	8b 74 24 04          	mov    0x4(%esp),%esi
  802848:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80284c:	89 ec                	mov    %ebp,%esp
  80284e:	5d                   	pop    %ebp
  80284f:	c3                   	ret    

00802850 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802850:	55                   	push   %ebp
  802851:	89 e5                	mov    %esp,%ebp
  802853:	83 ec 0c             	sub    $0xc,%esp
  802856:	89 1c 24             	mov    %ebx,(%esp)
  802859:	89 74 24 04          	mov    %esi,0x4(%esp)
  80285d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802861:	b8 00 00 00 00       	mov    $0x0,%eax
  802866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802869:	8b 55 08             	mov    0x8(%ebp),%edx
  80286c:	89 c3                	mov    %eax,%ebx
  80286e:	89 c7                	mov    %eax,%edi
  802870:	89 c6                	mov    %eax,%esi
  802872:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802874:	8b 1c 24             	mov    (%esp),%ebx
  802877:	8b 74 24 04          	mov    0x4(%esp),%esi
  80287b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80287f:	89 ec                	mov    %ebp,%esp
  802881:	5d                   	pop    %ebp
  802882:	c3                   	ret    

00802883 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  802883:	55                   	push   %ebp
  802884:	89 e5                	mov    %esp,%ebp
  802886:	83 ec 38             	sub    $0x38,%esp
  802889:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80288c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80288f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802892:	b9 00 00 00 00       	mov    $0x0,%ecx
  802897:	b8 0d 00 00 00       	mov    $0xd,%eax
  80289c:	8b 55 08             	mov    0x8(%ebp),%edx
  80289f:	89 cb                	mov    %ecx,%ebx
  8028a1:	89 cf                	mov    %ecx,%edi
  8028a3:	89 ce                	mov    %ecx,%esi
  8028a5:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8028a7:	85 c0                	test   %eax,%eax
  8028a9:	7e 28                	jle    8028d3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028af:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8028b6:	00 
  8028b7:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  8028be:	00 
  8028bf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8028c6:	00 
  8028c7:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  8028ce:	e8 e5 f3 ff ff       	call   801cb8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8028d3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8028d6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8028d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8028dc:	89 ec                	mov    %ebp,%esp
  8028de:	5d                   	pop    %ebp
  8028df:	c3                   	ret    

008028e0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8028e0:	55                   	push   %ebp
  8028e1:	89 e5                	mov    %esp,%ebp
  8028e3:	83 ec 0c             	sub    $0xc,%esp
  8028e6:	89 1c 24             	mov    %ebx,(%esp)
  8028e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028f1:	be 00 00 00 00       	mov    $0x0,%esi
  8028f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8028fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802904:	8b 55 08             	mov    0x8(%ebp),%edx
  802907:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802909:	8b 1c 24             	mov    (%esp),%ebx
  80290c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802910:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802914:	89 ec                	mov    %ebp,%esp
  802916:	5d                   	pop    %ebp
  802917:	c3                   	ret    

00802918 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802918:	55                   	push   %ebp
  802919:	89 e5                	mov    %esp,%ebp
  80291b:	83 ec 38             	sub    $0x38,%esp
  80291e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802921:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802924:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802927:	bb 00 00 00 00       	mov    $0x0,%ebx
  80292c:	b8 0a 00 00 00       	mov    $0xa,%eax
  802931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802934:	8b 55 08             	mov    0x8(%ebp),%edx
  802937:	89 df                	mov    %ebx,%edi
  802939:	89 de                	mov    %ebx,%esi
  80293b:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  80293d:	85 c0                	test   %eax,%eax
  80293f:	7e 28                	jle    802969 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802941:	89 44 24 10          	mov    %eax,0x10(%esp)
  802945:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80294c:	00 
  80294d:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  802954:	00 
  802955:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80295c:	00 
  80295d:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  802964:	e8 4f f3 ff ff       	call   801cb8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802969:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80296c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80296f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802972:	89 ec                	mov    %ebp,%esp
  802974:	5d                   	pop    %ebp
  802975:	c3                   	ret    

00802976 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802976:	55                   	push   %ebp
  802977:	89 e5                	mov    %esp,%ebp
  802979:	83 ec 38             	sub    $0x38,%esp
  80297c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80297f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802982:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802985:	bb 00 00 00 00       	mov    $0x0,%ebx
  80298a:	b8 09 00 00 00       	mov    $0x9,%eax
  80298f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802992:	8b 55 08             	mov    0x8(%ebp),%edx
  802995:	89 df                	mov    %ebx,%edi
  802997:	89 de                	mov    %ebx,%esi
  802999:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  80299b:	85 c0                	test   %eax,%eax
  80299d:	7e 28                	jle    8029c7 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80299f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029a3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8029aa:	00 
  8029ab:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  8029b2:	00 
  8029b3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8029ba:	00 
  8029bb:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  8029c2:	e8 f1 f2 ff ff       	call   801cb8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8029c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8029ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8029cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8029d0:	89 ec                	mov    %ebp,%esp
  8029d2:	5d                   	pop    %ebp
  8029d3:	c3                   	ret    

008029d4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8029d4:	55                   	push   %ebp
  8029d5:	89 e5                	mov    %esp,%ebp
  8029d7:	83 ec 38             	sub    $0x38,%esp
  8029da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8029dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8029e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8029ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8029f3:	89 df                	mov    %ebx,%edi
  8029f5:	89 de                	mov    %ebx,%esi
  8029f7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  8029f9:	85 c0                	test   %eax,%eax
  8029fb:	7e 28                	jle    802a25 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a01:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802a08:	00 
  802a09:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  802a10:	00 
  802a11:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802a18:	00 
  802a19:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  802a20:	e8 93 f2 ff ff       	call   801cb8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802a25:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802a28:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802a2b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802a2e:	89 ec                	mov    %ebp,%esp
  802a30:	5d                   	pop    %ebp
  802a31:	c3                   	ret    

00802a32 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  802a32:	55                   	push   %ebp
  802a33:	89 e5                	mov    %esp,%ebp
  802a35:	83 ec 38             	sub    $0x38,%esp
  802a38:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802a3b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802a3e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a41:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a46:	b8 06 00 00 00       	mov    $0x6,%eax
  802a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  802a51:	89 df                	mov    %ebx,%edi
  802a53:	89 de                	mov    %ebx,%esi
  802a55:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  802a57:	85 c0                	test   %eax,%eax
  802a59:	7e 28                	jle    802a83 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a5f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802a66:	00 
  802a67:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  802a6e:	00 
  802a6f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802a76:	00 
  802a77:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  802a7e:	e8 35 f2 ff ff       	call   801cb8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802a83:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802a86:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802a89:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802a8c:	89 ec                	mov    %ebp,%esp
  802a8e:	5d                   	pop    %ebp
  802a8f:	c3                   	ret    

00802a90 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802a90:	55                   	push   %ebp
  802a91:	89 e5                	mov    %esp,%ebp
  802a93:	83 ec 38             	sub    $0x38,%esp
  802a96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802a99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802a9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a9f:	b8 05 00 00 00       	mov    $0x5,%eax
  802aa4:	8b 75 18             	mov    0x18(%ebp),%esi
  802aa7:	8b 7d 14             	mov    0x14(%ebp),%edi
  802aaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802aad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  802ab3:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  802ab5:	85 c0                	test   %eax,%eax
  802ab7:	7e 28                	jle    802ae1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  802ab9:	89 44 24 10          	mov    %eax,0x10(%esp)
  802abd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802ac4:	00 
  802ac5:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  802acc:	00 
  802acd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802ad4:	00 
  802ad5:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  802adc:	e8 d7 f1 ff ff       	call   801cb8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802ae1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802ae4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802ae7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802aea:	89 ec                	mov    %ebp,%esp
  802aec:	5d                   	pop    %ebp
  802aed:	c3                   	ret    

00802aee <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802aee:	55                   	push   %ebp
  802aef:	89 e5                	mov    %esp,%ebp
  802af1:	83 ec 38             	sub    $0x38,%esp
  802af4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802af7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802afa:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802afd:	be 00 00 00 00       	mov    $0x0,%esi
  802b02:	b8 04 00 00 00       	mov    $0x4,%eax
  802b07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  802b10:	89 f7                	mov    %esi,%edi
  802b12:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  802b14:	85 c0                	test   %eax,%eax
  802b16:	7e 28                	jle    802b40 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  802b18:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b1c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802b23:	00 
  802b24:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  802b2b:	00 
  802b2c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802b33:	00 
  802b34:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  802b3b:	e8 78 f1 ff ff       	call   801cb8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802b40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802b43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802b46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802b49:	89 ec                	mov    %ebp,%esp
  802b4b:	5d                   	pop    %ebp
  802b4c:	c3                   	ret    

00802b4d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  802b4d:	55                   	push   %ebp
  802b4e:	89 e5                	mov    %esp,%ebp
  802b50:	83 ec 0c             	sub    $0xc,%esp
  802b53:	89 1c 24             	mov    %ebx,(%esp)
  802b56:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b5a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  802b63:	b8 0b 00 00 00       	mov    $0xb,%eax
  802b68:	89 d1                	mov    %edx,%ecx
  802b6a:	89 d3                	mov    %edx,%ebx
  802b6c:	89 d7                	mov    %edx,%edi
  802b6e:	89 d6                	mov    %edx,%esi
  802b70:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802b72:	8b 1c 24             	mov    (%esp),%ebx
  802b75:	8b 74 24 04          	mov    0x4(%esp),%esi
  802b79:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802b7d:	89 ec                	mov    %ebp,%esp
  802b7f:	5d                   	pop    %ebp
  802b80:	c3                   	ret    

00802b81 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  802b81:	55                   	push   %ebp
  802b82:	89 e5                	mov    %esp,%ebp
  802b84:	83 ec 0c             	sub    $0xc,%esp
  802b87:	89 1c 24             	mov    %ebx,(%esp)
  802b8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802b92:	ba 00 00 00 00       	mov    $0x0,%edx
  802b97:	b8 02 00 00 00       	mov    $0x2,%eax
  802b9c:	89 d1                	mov    %edx,%ecx
  802b9e:	89 d3                	mov    %edx,%ebx
  802ba0:	89 d7                	mov    %edx,%edi
  802ba2:	89 d6                	mov    %edx,%esi
  802ba4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802ba6:	8b 1c 24             	mov    (%esp),%ebx
  802ba9:	8b 74 24 04          	mov    0x4(%esp),%esi
  802bad:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802bb1:	89 ec                	mov    %ebp,%esp
  802bb3:	5d                   	pop    %ebp
  802bb4:	c3                   	ret    

00802bb5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  802bb5:	55                   	push   %ebp
  802bb6:	89 e5                	mov    %esp,%ebp
  802bb8:	83 ec 38             	sub    $0x38,%esp
  802bbb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802bbe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802bc1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802bc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  802bc9:	b8 03 00 00 00       	mov    $0x3,%eax
  802bce:	8b 55 08             	mov    0x8(%ebp),%edx
  802bd1:	89 cb                	mov    %ecx,%ebx
  802bd3:	89 cf                	mov    %ecx,%edi
  802bd5:	89 ce                	mov    %ecx,%esi
  802bd7:	cd 30                	int    $0x30
		  "c" (a2),
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	if(check && ret > 0)
  802bd9:	85 c0                	test   %eax,%eax
  802bdb:	7e 28                	jle    802c05 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  802bdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  802be1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802be8:	00 
  802be9:	c7 44 24 08 df 40 80 	movl   $0x8040df,0x8(%esp)
  802bf0:	00 
  802bf1:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802bf8:	00 
  802bf9:	c7 04 24 fc 40 80 00 	movl   $0x8040fc,(%esp)
  802c00:	e8 b3 f0 ff ff       	call   801cb8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802c05:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802c08:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802c0b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802c0e:	89 ec                	mov    %ebp,%esp
  802c10:	5d                   	pop    %ebp
  802c11:	c3                   	ret    
	...

00802c14 <set_pgfault_handler>:
// _pgfault_upcall routine when a page fault occurs.
//

void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802c14:	55                   	push   %ebp
  802c15:	89 e5                	mov    %esp,%ebp
  802c17:	53                   	push   %ebx
  802c18:	83 ec 14             	sub    $0x14,%esp
	int r;
	if (_pgfault_handler == 0) {
  802c1b:	83 3d 98 b0 80 00 00 	cmpl   $0x0,0x80b098
  802c22:	75 6f                	jne    802c93 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802c24:	e8 58 ff ff ff       	call   802b81 <sys_getenvid>
  802c29:	89 c3                	mov    %eax,%ebx
		if(sys_page_alloc(envid,(void*) UXSTACKTOP-PGSIZE,PTE_W|PTE_U|PTE_P)<0)
  802c2b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802c32:	00 
  802c33:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802c3a:	ee 
  802c3b:	89 04 24             	mov    %eax,(%esp)
  802c3e:	e8 ab fe ff ff       	call   802aee <sys_page_alloc>
  802c43:	85 c0                	test   %eax,%eax
  802c45:	79 1c                	jns    802c63 <set_pgfault_handler+0x4f>
		{
			panic("UXSTACKTOP could not be allocated\n");
  802c47:	c7 44 24 08 0c 41 80 	movl   $0x80410c,0x8(%esp)
  802c4e:	00 
  802c4f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802c56:	00 
  802c57:	c7 04 24 2f 41 80 00 	movl   $0x80412f,(%esp)
  802c5e:	e8 55 f0 ff ff       	call   801cb8 <_panic>
		}	
		
		if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall)<0)
  802c63:	c7 44 24 04 a4 2c 80 	movl   $0x802ca4,0x4(%esp)
  802c6a:	00 
  802c6b:	89 1c 24             	mov    %ebx,(%esp)
  802c6e:	e8 a5 fc ff ff       	call   802918 <sys_env_set_pgfault_upcall>
  802c73:	85 c0                	test   %eax,%eax
  802c75:	79 1c                	jns    802c93 <set_pgfault_handler+0x7f>
		{
			panic("upcall failed\n");
  802c77:	c7 44 24 08 3d 41 80 	movl   $0x80413d,0x8(%esp)
  802c7e:	00 
  802c7f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  802c86:	00 
  802c87:	c7 04 24 2f 41 80 00 	movl   $0x80412f,(%esp)
  802c8e:	e8 25 f0 ff ff       	call   801cb8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802c93:	8b 45 08             	mov    0x8(%ebp),%eax
  802c96:	a3 98 b0 80 00       	mov    %eax,0x80b098
	//cprintf("returning from set_pgfault_handler\n");
}
  802c9b:	83 c4 14             	add    $0x14,%esp
  802c9e:	5b                   	pop    %ebx
  802c9f:	5d                   	pop    %ebp
  802ca0:	c3                   	ret    
  802ca1:	00 00                	add    %al,(%eax)
	...

00802ca4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ca4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ca5:	a1 98 b0 80 00       	mov    0x80b098,%eax
	call *%eax
  802caa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802cac:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.	
	
	addl $0x8, %esp 	// ignoring fault_va, utf_err and setting esp for pop
  802caf:	83 c4 08             	add    $0x8,%esp
	movl 0x20(%esp), %eax
  802cb2:	8b 44 24 20          	mov    0x20(%esp),%eax
	mov %eax, %ebx
  802cb6:	89 c3                	mov    %eax,%ebx
	movl 0x28(%esp), %eax
  802cb8:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, %eax
  802cbc:	83 e8 04             	sub    $0x4,%eax
	movl %ebx, (%eax)
  802cbf:	89 18                	mov    %ebx,(%eax)
	movl %eax, 0x28(%esp)	
  802cc1:	89 44 24 28          	mov    %eax,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802cc5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802cc6:	83 c4 04             	add    $0x4,%esp
	popfl
  802cc9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802cca:	5c                   	pop    %esp
	
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802ccb:	c3                   	ret    

00802ccc <ipc_send>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ccc:	55                   	push   %ebp
  802ccd:	89 e5                	mov    %esp,%ebp
  802ccf:	57                   	push   %edi
  802cd0:	56                   	push   %esi
  802cd1:	53                   	push   %ebx
  802cd2:	83 ec 1c             	sub    $0x1c,%esp
  802cd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802cdb:	8b 75 14             	mov    0x14(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
  802cde:	85 db                	test   %ebx,%ebx
  802ce0:	75 31                	jne    802d13 <ipc_send+0x47>
  802ce2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802ce7:	eb 2a                	jmp    802d13 <ipc_send+0x47>
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                if(err != -E_IPC_NOT_RECV)
  802ce9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802cec:	74 20                	je     802d0e <ipc_send+0x42>
                        panic("error in recieving %d\n", err);
  802cee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cf2:	c7 44 24 08 4c 41 80 	movl   $0x80414c,0x8(%esp)
  802cf9:	00 
  802cfa:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  802d01:	00 
  802d02:	c7 04 24 63 41 80 00 	movl   $0x804163,(%esp)
  802d09:	e8 aa ef ff ff       	call   801cb8 <_panic>


                sys_yield();
  802d0e:	e8 3a fe ff ff       	call   802b4d <sys_yield>
        //panic("ipc_send not implemented");
        int err;

	if(pg == NULL)
		pg = (void*) UTOP;	
        while ((err = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802d13:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802d17:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  802d22:	89 04 24             	mov    %eax,(%esp)
  802d25:	e8 b6 fb ff ff       	call   8028e0 <sys_ipc_try_send>
  802d2a:	85 c0                	test   %eax,%eax
  802d2c:	78 bb                	js     802ce9 <ipc_send+0x1d>


                sys_yield();
        }
        return;
}
  802d2e:	83 c4 1c             	add    $0x1c,%esp
  802d31:	5b                   	pop    %ebx
  802d32:	5e                   	pop    %esi
  802d33:	5f                   	pop    %edi
  802d34:	5d                   	pop    %ebp
  802d35:	c3                   	ret    

00802d36 <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802d36:	55                   	push   %ebp
  802d37:	89 e5                	mov    %esp,%ebp
  802d39:	56                   	push   %esi
  802d3a:	53                   	push   %ebx
  802d3b:	83 ec 10             	sub    $0x10,%esp
  802d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d44:	8b 75 10             	mov    0x10(%ebp),%esi
        // LAB 4: Your code here.
        //panic("ipc_recv not implemented");
        int err;
	if(pg == NULL)
  802d47:	85 c0                	test   %eax,%eax
  802d49:	75 05                	jne    802d50 <ipc_recv+0x1a>
  802d4b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
		pg = (void *) UTOP;

        if ((err = sys_ipc_recv(pg)) < 0) 
  802d50:	89 04 24             	mov    %eax,(%esp)
  802d53:	e8 2b fb ff ff       	call   802883 <sys_ipc_recv>
  802d58:	85 c0                	test   %eax,%eax
  802d5a:	78 24                	js     802d80 <ipc_recv+0x4a>
	{
                return err;

        }

        if (from_env_store != NULL)
  802d5c:	85 db                	test   %ebx,%ebx
  802d5e:	74 0a                	je     802d6a <ipc_recv+0x34>
                *from_env_store = env->env_ipc_from;
  802d60:	a1 90 b0 80 00       	mov    0x80b090,%eax
  802d65:	8b 40 74             	mov    0x74(%eax),%eax
  802d68:	89 03                	mov    %eax,(%ebx)

        if (perm_store != NULL)
  802d6a:	85 f6                	test   %esi,%esi
  802d6c:	74 0a                	je     802d78 <ipc_recv+0x42>
                *perm_store = env->env_ipc_perm;
  802d6e:	a1 90 b0 80 00       	mov    0x80b090,%eax
  802d73:	8b 40 78             	mov    0x78(%eax),%eax
  802d76:	89 06                	mov    %eax,(%esi)

        return env->env_ipc_value;
  802d78:	a1 90 b0 80 00       	mov    0x80b090,%eax
  802d7d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802d80:	83 c4 10             	add    $0x10,%esp
  802d83:	5b                   	pop    %ebx
  802d84:	5e                   	pop    %esi
  802d85:	5d                   	pop    %ebp
  802d86:	c3                   	ret    
	...

00802d90 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802d90:	55                   	push   %ebp
  802d91:	89 e5                	mov    %esp,%ebp
  802d93:	8b 45 08             	mov    0x8(%ebp),%eax
  802d96:	05 00 00 00 30       	add    $0x30000000,%eax
  802d9b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  802d9e:	5d                   	pop    %ebp
  802d9f:	c3                   	ret    

00802da0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802da0:	55                   	push   %ebp
  802da1:	89 e5                	mov    %esp,%ebp
  802da3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802da6:	8b 45 08             	mov    0x8(%ebp),%eax
  802da9:	89 04 24             	mov    %eax,(%esp)
  802dac:	e8 df ff ff ff       	call   802d90 <fd2num>
  802db1:	05 20 00 0d 00       	add    $0xd0020,%eax
  802db6:	c1 e0 0c             	shl    $0xc,%eax
}
  802db9:	c9                   	leave  
  802dba:	c3                   	ret    

00802dbb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802dbb:	55                   	push   %ebp
  802dbc:	89 e5                	mov    %esp,%ebp
  802dbe:	57                   	push   %edi
  802dbf:	56                   	push   %esi
  802dc0:	53                   	push   %ebx
  802dc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
  802dc4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  802dc9:	a8 01                	test   $0x1,%al
  802dcb:	74 36                	je     802e03 <fd_alloc+0x48>
  802dcd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  802dd2:	a8 01                	test   $0x1,%al
  802dd4:	74 2d                	je     802e03 <fd_alloc+0x48>
  802dd6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  802ddb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  802de0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  802de5:	89 c3                	mov    %eax,%ebx
  802de7:	89 c2                	mov    %eax,%edx
  802de9:	c1 ea 16             	shr    $0x16,%edx
  802dec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  802def:	f6 c2 01             	test   $0x1,%dl
  802df2:	74 14                	je     802e08 <fd_alloc+0x4d>
  802df4:	89 c2                	mov    %eax,%edx
  802df6:	c1 ea 0c             	shr    $0xc,%edx
  802df9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  802dfc:	f6 c2 01             	test   $0x1,%dl
  802dff:	75 10                	jne    802e11 <fd_alloc+0x56>
  802e01:	eb 05                	jmp    802e08 <fd_alloc+0x4d>
  802e03:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  802e08:	89 1f                	mov    %ebx,(%edi)
  802e0a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  802e0f:	eb 17                	jmp    802e28 <fd_alloc+0x6d>
  802e11:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802e16:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802e1b:	75 c8                	jne    802de5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[VPN(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802e1d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802e23:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  802e28:	5b                   	pop    %ebx
  802e29:	5e                   	pop    %esi
  802e2a:	5f                   	pop    %edi
  802e2b:	5d                   	pop    %ebp
  802e2c:	c3                   	ret    

00802e2d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802e2d:	55                   	push   %ebp
  802e2e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802e30:	8b 45 08             	mov    0x8(%ebp),%eax
  802e33:	83 f8 1f             	cmp    $0x1f,%eax
  802e36:	77 36                	ja     802e6e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802e38:	05 00 00 0d 00       	add    $0xd0000,%eax
  802e3d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[VPN(fd)] & PTE_P)) {
  802e40:	89 c2                	mov    %eax,%edx
  802e42:	c1 ea 16             	shr    $0x16,%edx
  802e45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802e4c:	f6 c2 01             	test   $0x1,%dl
  802e4f:	74 1d                	je     802e6e <fd_lookup+0x41>
  802e51:	89 c2                	mov    %eax,%edx
  802e53:	c1 ea 0c             	shr    $0xc,%edx
  802e56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802e5d:	f6 c2 01             	test   $0x1,%dl
  802e60:	74 0c                	je     802e6e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", env->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  802e62:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e65:	89 02                	mov    %eax,(%edx)
  802e67:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  802e6c:	eb 05                	jmp    802e73 <fd_lookup+0x46>
  802e6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802e73:	5d                   	pop    %ebp
  802e74:	c3                   	ret    

00802e75 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  802e75:	55                   	push   %ebp
  802e76:	89 e5                	mov    %esp,%ebp
  802e78:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e7b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802e7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e82:	8b 45 08             	mov    0x8(%ebp),%eax
  802e85:	89 04 24             	mov    %eax,(%esp)
  802e88:	e8 a0 ff ff ff       	call   802e2d <fd_lookup>
  802e8d:	85 c0                	test   %eax,%eax
  802e8f:	78 0e                	js     802e9f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802e91:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802e94:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e97:	89 50 04             	mov    %edx,0x4(%eax)
  802e9a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  802e9f:	c9                   	leave  
  802ea0:	c3                   	ret    

00802ea1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802ea1:	55                   	push   %ebp
  802ea2:	89 e5                	mov    %esp,%ebp
  802ea4:	56                   	push   %esi
  802ea5:	53                   	push   %ebx
  802ea6:	83 ec 10             	sub    $0x10,%esp
  802ea9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802eac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  802eaf:	b8 6c b0 80 00       	mov    $0x80b06c,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  802eb4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802eb9:	be f0 41 80 00       	mov    $0x8041f0,%esi
		if (devtab[i]->dev_id == dev_id) {
  802ebe:	39 08                	cmp    %ecx,(%eax)
  802ec0:	75 10                	jne    802ed2 <dev_lookup+0x31>
  802ec2:	eb 04                	jmp    802ec8 <dev_lookup+0x27>
  802ec4:	39 08                	cmp    %ecx,(%eax)
  802ec6:	75 0a                	jne    802ed2 <dev_lookup+0x31>
			*dev = devtab[i];
  802ec8:	89 03                	mov    %eax,(%ebx)
  802eca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  802ecf:	90                   	nop
  802ed0:	eb 31                	jmp    802f03 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802ed2:	83 c2 01             	add    $0x1,%edx
  802ed5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  802ed8:	85 c0                	test   %eax,%eax
  802eda:	75 e8                	jne    802ec4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", env->env_id, dev_id);
  802edc:	a1 90 b0 80 00       	mov    0x80b090,%eax
  802ee1:	8b 40 4c             	mov    0x4c(%eax),%eax
  802ee4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eec:	c7 04 24 70 41 80 00 	movl   $0x804170,(%esp)
  802ef3:	e8 85 ee ff ff       	call   801d7d <cprintf>
	*dev = 0;
  802ef8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802efe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  802f03:	83 c4 10             	add    $0x10,%esp
  802f06:	5b                   	pop    %ebx
  802f07:	5e                   	pop    %esi
  802f08:	5d                   	pop    %ebp
  802f09:	c3                   	ret    

00802f0a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  802f0a:	55                   	push   %ebp
  802f0b:	89 e5                	mov    %esp,%ebp
  802f0d:	53                   	push   %ebx
  802f0e:	83 ec 24             	sub    $0x24,%esp
  802f11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f17:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f1e:	89 04 24             	mov    %eax,(%esp)
  802f21:	e8 07 ff ff ff       	call   802e2d <fd_lookup>
  802f26:	85 c0                	test   %eax,%eax
  802f28:	78 53                	js     802f7d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f34:	8b 00                	mov    (%eax),%eax
  802f36:	89 04 24             	mov    %eax,(%esp)
  802f39:	e8 63 ff ff ff       	call   802ea1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f3e:	85 c0                	test   %eax,%eax
  802f40:	78 3b                	js     802f7d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  802f42:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f4a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  802f4e:	74 2d                	je     802f7d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f50:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802f53:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802f5a:	00 00 00 
	stat->st_isdir = 0;
  802f5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f64:	00 00 00 
	stat->st_dev = dev;
  802f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f6a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802f70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802f77:	89 14 24             	mov    %edx,(%esp)
  802f7a:	ff 50 14             	call   *0x14(%eax)
}
  802f7d:	83 c4 24             	add    $0x24,%esp
  802f80:	5b                   	pop    %ebx
  802f81:	5d                   	pop    %ebp
  802f82:	c3                   	ret    

00802f83 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  802f83:	55                   	push   %ebp
  802f84:	89 e5                	mov    %esp,%ebp
  802f86:	53                   	push   %ebx
  802f87:	83 ec 24             	sub    $0x24,%esp
  802f8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f94:	89 1c 24             	mov    %ebx,(%esp)
  802f97:	e8 91 fe ff ff       	call   802e2d <fd_lookup>
  802f9c:	85 c0                	test   %eax,%eax
  802f9e:	78 5f                	js     802fff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802faa:	8b 00                	mov    (%eax),%eax
  802fac:	89 04 24             	mov    %eax,(%esp)
  802faf:	e8 ed fe ff ff       	call   802ea1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802fb4:	85 c0                	test   %eax,%eax
  802fb6:	78 47                	js     802fff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802fb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802fbb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  802fbf:	75 23                	jne    802fe4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			env->env_id, fdnum); 
  802fc1:	a1 90 b0 80 00       	mov    0x80b090,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802fc6:	8b 40 4c             	mov    0x4c(%eax),%eax
  802fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fd1:	c7 04 24 90 41 80 00 	movl   $0x804190,(%esp)
  802fd8:	e8 a0 ed ff ff       	call   801d7d <cprintf>
  802fdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			env->env_id, fdnum); 
		return -E_INVAL;
  802fe2:	eb 1b                	jmp    802fff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  802fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fe7:	8b 48 18             	mov    0x18(%eax),%ecx
  802fea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802fef:	85 c9                	test   %ecx,%ecx
  802ff1:	74 0c                	je     802fff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ffa:	89 14 24             	mov    %edx,(%esp)
  802ffd:	ff d1                	call   *%ecx
}
  802fff:	83 c4 24             	add    $0x24,%esp
  803002:	5b                   	pop    %ebx
  803003:	5d                   	pop    %ebp
  803004:	c3                   	ret    

00803005 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  803005:	55                   	push   %ebp
  803006:	89 e5                	mov    %esp,%ebp
  803008:	53                   	push   %ebx
  803009:	83 ec 24             	sub    $0x24,%esp
  80300c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80300f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803012:	89 44 24 04          	mov    %eax,0x4(%esp)
  803016:	89 1c 24             	mov    %ebx,(%esp)
  803019:	e8 0f fe ff ff       	call   802e2d <fd_lookup>
  80301e:	85 c0                	test   %eax,%eax
  803020:	78 66                	js     803088 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803025:	89 44 24 04          	mov    %eax,0x4(%esp)
  803029:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80302c:	8b 00                	mov    (%eax),%eax
  80302e:	89 04 24             	mov    %eax,(%esp)
  803031:	e8 6b fe ff ff       	call   802ea1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803036:	85 c0                	test   %eax,%eax
  803038:	78 4e                	js     803088 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80303a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80303d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  803041:	75 23                	jne    803066 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", env->env_id, fdnum);
  803043:	a1 90 b0 80 00       	mov    0x80b090,%eax
  803048:	8b 40 4c             	mov    0x4c(%eax),%eax
  80304b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80304f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803053:	c7 04 24 b4 41 80 00 	movl   $0x8041b4,(%esp)
  80305a:	e8 1e ed ff ff       	call   801d7d <cprintf>
  80305f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  803064:	eb 22                	jmp    803088 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  803066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803069:	8b 48 0c             	mov    0xc(%eax),%ecx
  80306c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803071:	85 c9                	test   %ecx,%ecx
  803073:	74 13                	je     803088 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  803075:	8b 45 10             	mov    0x10(%ebp),%eax
  803078:	89 44 24 08          	mov    %eax,0x8(%esp)
  80307c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80307f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803083:	89 14 24             	mov    %edx,(%esp)
  803086:	ff d1                	call   *%ecx
}
  803088:	83 c4 24             	add    $0x24,%esp
  80308b:	5b                   	pop    %ebx
  80308c:	5d                   	pop    %ebp
  80308d:	c3                   	ret    

0080308e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80308e:	55                   	push   %ebp
  80308f:	89 e5                	mov    %esp,%ebp
  803091:	53                   	push   %ebx
  803092:	83 ec 24             	sub    $0x24,%esp
  803095:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803098:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80309b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80309f:	89 1c 24             	mov    %ebx,(%esp)
  8030a2:	e8 86 fd ff ff       	call   802e2d <fd_lookup>
  8030a7:	85 c0                	test   %eax,%eax
  8030a9:	78 6b                	js     803116 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030b5:	8b 00                	mov    (%eax),%eax
  8030b7:	89 04 24             	mov    %eax,(%esp)
  8030ba:	e8 e2 fd ff ff       	call   802ea1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030bf:	85 c0                	test   %eax,%eax
  8030c1:	78 53                	js     803116 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8030c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8030c6:	8b 42 08             	mov    0x8(%edx),%eax
  8030c9:	83 e0 03             	and    $0x3,%eax
  8030cc:	83 f8 01             	cmp    $0x1,%eax
  8030cf:	75 23                	jne    8030f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", env->env_id, fdnum); 
  8030d1:	a1 90 b0 80 00       	mov    0x80b090,%eax
  8030d6:	8b 40 4c             	mov    0x4c(%eax),%eax
  8030d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030e1:	c7 04 24 d1 41 80 00 	movl   $0x8041d1,(%esp)
  8030e8:	e8 90 ec ff ff       	call   801d7d <cprintf>
  8030ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8030f2:	eb 22                	jmp    803116 <read+0x88>
	}
	if (!dev->dev_read)
  8030f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030f7:	8b 48 08             	mov    0x8(%eax),%ecx
  8030fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8030ff:	85 c9                	test   %ecx,%ecx
  803101:	74 13                	je     803116 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  803103:	8b 45 10             	mov    0x10(%ebp),%eax
  803106:	89 44 24 08          	mov    %eax,0x8(%esp)
  80310a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80310d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803111:	89 14 24             	mov    %edx,(%esp)
  803114:	ff d1                	call   *%ecx
}
  803116:	83 c4 24             	add    $0x24,%esp
  803119:	5b                   	pop    %ebx
  80311a:	5d                   	pop    %ebp
  80311b:	c3                   	ret    

0080311c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80311c:	55                   	push   %ebp
  80311d:	89 e5                	mov    %esp,%ebp
  80311f:	57                   	push   %edi
  803120:	56                   	push   %esi
  803121:	53                   	push   %ebx
  803122:	83 ec 1c             	sub    $0x1c,%esp
  803125:	8b 7d 08             	mov    0x8(%ebp),%edi
  803128:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80312b:	ba 00 00 00 00       	mov    $0x0,%edx
  803130:	bb 00 00 00 00       	mov    $0x0,%ebx
  803135:	b8 00 00 00 00       	mov    $0x0,%eax
  80313a:	85 f6                	test   %esi,%esi
  80313c:	74 29                	je     803167 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80313e:	89 f0                	mov    %esi,%eax
  803140:	29 d0                	sub    %edx,%eax
  803142:	89 44 24 08          	mov    %eax,0x8(%esp)
  803146:	03 55 0c             	add    0xc(%ebp),%edx
  803149:	89 54 24 04          	mov    %edx,0x4(%esp)
  80314d:	89 3c 24             	mov    %edi,(%esp)
  803150:	e8 39 ff ff ff       	call   80308e <read>
		if (m < 0)
  803155:	85 c0                	test   %eax,%eax
  803157:	78 0e                	js     803167 <readn+0x4b>
			return m;
		if (m == 0)
  803159:	85 c0                	test   %eax,%eax
  80315b:	74 08                	je     803165 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80315d:	01 c3                	add    %eax,%ebx
  80315f:	89 da                	mov    %ebx,%edx
  803161:	39 f3                	cmp    %esi,%ebx
  803163:	72 d9                	jb     80313e <readn+0x22>
  803165:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  803167:	83 c4 1c             	add    $0x1c,%esp
  80316a:	5b                   	pop    %ebx
  80316b:	5e                   	pop    %esi
  80316c:	5f                   	pop    %edi
  80316d:	5d                   	pop    %ebp
  80316e:	c3                   	ret    

0080316f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80316f:	55                   	push   %ebp
  803170:	89 e5                	mov    %esp,%ebp
  803172:	56                   	push   %esi
  803173:	53                   	push   %ebx
  803174:	83 ec 20             	sub    $0x20,%esp
  803177:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80317a:	89 34 24             	mov    %esi,(%esp)
  80317d:	e8 0e fc ff ff       	call   802d90 <fd2num>
  803182:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803185:	89 54 24 04          	mov    %edx,0x4(%esp)
  803189:	89 04 24             	mov    %eax,(%esp)
  80318c:	e8 9c fc ff ff       	call   802e2d <fd_lookup>
  803191:	89 c3                	mov    %eax,%ebx
  803193:	85 c0                	test   %eax,%eax
  803195:	78 05                	js     80319c <fd_close+0x2d>
  803197:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80319a:	74 0c                	je     8031a8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80319c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8031a0:	19 c0                	sbb    %eax,%eax
  8031a2:	f7 d0                	not    %eax
  8031a4:	21 c3                	and    %eax,%ebx
  8031a6:	eb 3d                	jmp    8031e5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8031a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031af:	8b 06                	mov    (%esi),%eax
  8031b1:	89 04 24             	mov    %eax,(%esp)
  8031b4:	e8 e8 fc ff ff       	call   802ea1 <dev_lookup>
  8031b9:	89 c3                	mov    %eax,%ebx
  8031bb:	85 c0                	test   %eax,%eax
  8031bd:	78 16                	js     8031d5 <fd_close+0x66>
		if (dev->dev_close)
  8031bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031c2:	8b 40 10             	mov    0x10(%eax),%eax
  8031c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8031ca:	85 c0                	test   %eax,%eax
  8031cc:	74 07                	je     8031d5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8031ce:	89 34 24             	mov    %esi,(%esp)
  8031d1:	ff d0                	call   *%eax
  8031d3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8031d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031e0:	e8 4d f8 ff ff       	call   802a32 <sys_page_unmap>
	return r;
}
  8031e5:	89 d8                	mov    %ebx,%eax
  8031e7:	83 c4 20             	add    $0x20,%esp
  8031ea:	5b                   	pop    %ebx
  8031eb:	5e                   	pop    %esi
  8031ec:	5d                   	pop    %ebp
  8031ed:	c3                   	ret    

008031ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8031ee:	55                   	push   %ebp
  8031ef:	89 e5                	mov    %esp,%ebp
  8031f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8031f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8031fe:	89 04 24             	mov    %eax,(%esp)
  803201:	e8 27 fc ff ff       	call   802e2d <fd_lookup>
  803206:	85 c0                	test   %eax,%eax
  803208:	78 13                	js     80321d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80320a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803211:	00 
  803212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803215:	89 04 24             	mov    %eax,(%esp)
  803218:	e8 52 ff ff ff       	call   80316f <fd_close>
}
  80321d:	c9                   	leave  
  80321e:	c3                   	ret    

0080321f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80321f:	55                   	push   %ebp
  803220:	89 e5                	mov    %esp,%ebp
  803222:	83 ec 18             	sub    $0x18,%esp
  803225:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803228:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80322b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803232:	00 
  803233:	8b 45 08             	mov    0x8(%ebp),%eax
  803236:	89 04 24             	mov    %eax,(%esp)
  803239:	e8 4d 03 00 00       	call   80358b <open>
  80323e:	89 c3                	mov    %eax,%ebx
  803240:	85 c0                	test   %eax,%eax
  803242:	78 1b                	js     80325f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  803244:	8b 45 0c             	mov    0xc(%ebp),%eax
  803247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80324b:	89 1c 24             	mov    %ebx,(%esp)
  80324e:	e8 b7 fc ff ff       	call   802f0a <fstat>
  803253:	89 c6                	mov    %eax,%esi
	close(fd);
  803255:	89 1c 24             	mov    %ebx,(%esp)
  803258:	e8 91 ff ff ff       	call   8031ee <close>
  80325d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80325f:	89 d8                	mov    %ebx,%eax
  803261:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803264:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803267:	89 ec                	mov    %ebp,%esp
  803269:	5d                   	pop    %ebp
  80326a:	c3                   	ret    

0080326b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80326b:	55                   	push   %ebp
  80326c:	89 e5                	mov    %esp,%ebp
  80326e:	53                   	push   %ebx
  80326f:	83 ec 14             	sub    $0x14,%esp
  803272:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  803277:	89 1c 24             	mov    %ebx,(%esp)
  80327a:	e8 6f ff ff ff       	call   8031ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80327f:	83 c3 01             	add    $0x1,%ebx
  803282:	83 fb 20             	cmp    $0x20,%ebx
  803285:	75 f0                	jne    803277 <close_all+0xc>
		close(i);
}
  803287:	83 c4 14             	add    $0x14,%esp
  80328a:	5b                   	pop    %ebx
  80328b:	5d                   	pop    %ebp
  80328c:	c3                   	ret    

0080328d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80328d:	55                   	push   %ebp
  80328e:	89 e5                	mov    %esp,%ebp
  803290:	83 ec 58             	sub    $0x58,%esp
  803293:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  803296:	89 75 f8             	mov    %esi,-0x8(%ebp)
  803299:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80329c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80329f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8032a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8032a9:	89 04 24             	mov    %eax,(%esp)
  8032ac:	e8 7c fb ff ff       	call   802e2d <fd_lookup>
  8032b1:	89 c3                	mov    %eax,%ebx
  8032b3:	85 c0                	test   %eax,%eax
  8032b5:	0f 88 e0 00 00 00    	js     80339b <dup+0x10e>
		return r;
	close(newfdnum);
  8032bb:	89 3c 24             	mov    %edi,(%esp)
  8032be:	e8 2b ff ff ff       	call   8031ee <close>

	newfd = INDEX2FD(newfdnum);
  8032c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8032c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8032cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8032cf:	89 04 24             	mov    %eax,(%esp)
  8032d2:	e8 c9 fa ff ff       	call   802da0 <fd2data>
  8032d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8032d9:	89 34 24             	mov    %esi,(%esp)
  8032dc:	e8 bf fa ff ff       	call   802da0 <fd2data>
  8032e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[VPN(ova)] & PTE_P))
  8032e4:	89 da                	mov    %ebx,%edx
  8032e6:	89 d8                	mov    %ebx,%eax
  8032e8:	c1 e8 16             	shr    $0x16,%eax
  8032eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8032f2:	a8 01                	test   $0x1,%al
  8032f4:	74 43                	je     803339 <dup+0xac>
  8032f6:	c1 ea 0c             	shr    $0xc,%edx
  8032f9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  803300:	a8 01                	test   $0x1,%al
  803302:	74 35                	je     803339 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[VPN(ova)] & PTE_USER)) < 0)
  803304:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80330b:	25 07 0e 00 00       	and    $0xe07,%eax
  803310:	89 44 24 10          	mov    %eax,0x10(%esp)
  803314:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80331b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803322:	00 
  803323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80332e:	e8 5d f7 ff ff       	call   802a90 <sys_page_map>
  803333:	89 c3                	mov    %eax,%ebx
  803335:	85 c0                	test   %eax,%eax
  803337:	78 3f                	js     803378 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[VPN(oldfd)] & PTE_USER)) < 0)
  803339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80333c:	89 c2                	mov    %eax,%edx
  80333e:	c1 ea 0c             	shr    $0xc,%edx
  803341:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  803348:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80334e:	89 54 24 10          	mov    %edx,0x10(%esp)
  803352:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803356:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80335d:	00 
  80335e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803369:	e8 22 f7 ff ff       	call   802a90 <sys_page_map>
  80336e:	89 c3                	mov    %eax,%ebx
  803370:	85 c0                	test   %eax,%eax
  803372:	78 04                	js     803378 <dup+0xeb>
  803374:	89 fb                	mov    %edi,%ebx
  803376:	eb 23                	jmp    80339b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  803378:	89 74 24 04          	mov    %esi,0x4(%esp)
  80337c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803383:	e8 aa f6 ff ff       	call   802a32 <sys_page_unmap>
	sys_page_unmap(0, nva);
  803388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80338b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80338f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803396:	e8 97 f6 ff ff       	call   802a32 <sys_page_unmap>
	return r;
}
  80339b:	89 d8                	mov    %ebx,%eax
  80339d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8033a0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8033a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8033a6:	89 ec                	mov    %ebp,%esp
  8033a8:	5d                   	pop    %ebp
  8033a9:	c3                   	ret    
  8033aa:	00 00                	add    %al,(%eax)
  8033ac:	00 00                	add    %al,(%eax)
	...

008033b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8033b0:	55                   	push   %ebp
  8033b1:	89 e5                	mov    %esp,%ebp
  8033b3:	53                   	push   %ebx
  8033b4:	83 ec 14             	sub    $0x14,%esp
  8033b7:	89 d3                	mov    %edx,%ebx
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", env->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(envs[1].env_id, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8033b9:	8b 15 c8 00 c0 ee    	mov    0xeec000c8,%edx
  8033bf:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8033c6:	00 
  8033c7:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8033ce:	00 
  8033cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033d3:	89 14 24             	mov    %edx,(%esp)
  8033d6:	e8 f1 f8 ff ff       	call   802ccc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8033db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8033e2:	00 
  8033e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8033e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8033ee:	e8 43 f9 ff ff       	call   802d36 <ipc_recv>
}
  8033f3:	83 c4 14             	add    $0x14,%esp
  8033f6:	5b                   	pop    %ebx
  8033f7:	5d                   	pop    %ebp
  8033f8:	c3                   	ret    

008033f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8033f9:	55                   	push   %ebp
  8033fa:	89 e5                	mov    %esp,%ebp
  8033fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8033ff:	8b 45 08             	mov    0x8(%ebp),%eax
  803402:	8b 40 0c             	mov    0xc(%eax),%eax
  803405:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80340a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80340d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  803412:	ba 00 00 00 00       	mov    $0x0,%edx
  803417:	b8 02 00 00 00       	mov    $0x2,%eax
  80341c:	e8 8f ff ff ff       	call   8033b0 <fsipc>
}
  803421:	c9                   	leave  
  803422:	c3                   	ret    

00803423 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  803423:	55                   	push   %ebp
  803424:	89 e5                	mov    %esp,%ebp
  803426:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803429:	8b 45 08             	mov    0x8(%ebp),%eax
  80342c:	8b 40 0c             	mov    0xc(%eax),%eax
  80342f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  803434:	ba 00 00 00 00       	mov    $0x0,%edx
  803439:	b8 06 00 00 00       	mov    $0x6,%eax
  80343e:	e8 6d ff ff ff       	call   8033b0 <fsipc>
}
  803443:	c9                   	leave  
  803444:	c3                   	ret    

00803445 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  803445:	55                   	push   %ebp
  803446:	89 e5                	mov    %esp,%ebp
  803448:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80344b:	ba 00 00 00 00       	mov    $0x0,%edx
  803450:	b8 08 00 00 00       	mov    $0x8,%eax
  803455:	e8 56 ff ff ff       	call   8033b0 <fsipc>
}
  80345a:	c9                   	leave  
  80345b:	c3                   	ret    

0080345c <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80345c:	55                   	push   %ebp
  80345d:	89 e5                	mov    %esp,%ebp
  80345f:	53                   	push   %ebx
  803460:	83 ec 14             	sub    $0x14,%esp
  803463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803466:	8b 45 08             	mov    0x8(%ebp),%eax
  803469:	8b 40 0c             	mov    0xc(%eax),%eax
  80346c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803471:	ba 00 00 00 00       	mov    $0x0,%edx
  803476:	b8 05 00 00 00       	mov    $0x5,%eax
  80347b:	e8 30 ff ff ff       	call   8033b0 <fsipc>
  803480:	85 c0                	test   %eax,%eax
  803482:	78 2b                	js     8034af <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803484:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80348b:	00 
  80348c:	89 1c 24             	mov    %ebx,(%esp)
  80348f:	e8 c6 ef ff ff       	call   80245a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803494:	a1 80 50 80 00       	mov    0x805080,%eax
  803499:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80349f:	a1 84 50 80 00       	mov    0x805084,%eax
  8034a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8034aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8034af:	83 c4 14             	add    $0x14,%esp
  8034b2:	5b                   	pop    %ebx
  8034b3:	5d                   	pop    %ebp
  8034b4:	c3                   	ret    

008034b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8034b5:	55                   	push   %ebp
  8034b6:	89 e5                	mov    %esp,%ebp
  8034b8:	83 ec 18             	sub    $0x18,%esp
  8034bb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8034be:	8b 55 08             	mov    0x8(%ebp),%edx
  8034c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8034c4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8034ca:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8034cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8034d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034da:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8034e1:	e8 2f f1 ff ff       	call   802615 <memmove>

	r = fsipc(FSREQ_WRITE, (void *)&fsipcbuf);
  8034e6:	ba 00 50 80 00       	mov    $0x805000,%edx
  8034eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8034f0:	e8 bb fe ff ff       	call   8033b0 <fsipc>
	return r;
	
	panic("devfile_write not implemented");
}
  8034f5:	c9                   	leave  
  8034f6:	c3                   	ret    

008034f7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8034f7:	55                   	push   %ebp
  8034f8:	89 e5                	mov    %esp,%ebp
  8034fa:	53                   	push   %ebx
  8034fb:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8034fe:	8b 45 08             	mov    0x8(%ebp),%eax
  803501:	8b 40 0c             	mov    0xc(%eax),%eax
  803504:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  803509:	8b 45 10             	mov    0x10(%ebp),%eax
  80350c:	a3 04 50 80 00       	mov    %eax,0x805004

	if((r = fsipc(FSREQ_READ, (void *)&fsipcbuf)) < 0)
  803511:	ba 00 50 80 00       	mov    $0x805000,%edx
  803516:	b8 03 00 00 00       	mov    $0x3,%eax
  80351b:	e8 90 fe ff ff       	call   8033b0 <fsipc>
  803520:	89 c3                	mov    %eax,%ebx
  803522:	85 c0                	test   %eax,%eax
  803524:	78 17                	js     80353d <devfile_read+0x46>
		return r;
	memmove((void *)buf, (void *)fsipcbuf.readRet.ret_buf, r);
  803526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80352a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  803531:	00 
  803532:	8b 45 0c             	mov    0xc(%ebp),%eax
  803535:	89 04 24             	mov    %eax,(%esp)
  803538:	e8 d8 f0 ff ff       	call   802615 <memmove>
	return r;	
	panic("devfile_read not implemented");
}
  80353d:	89 d8                	mov    %ebx,%eax
  80353f:	83 c4 14             	add    $0x14,%esp
  803542:	5b                   	pop    %ebx
  803543:	5d                   	pop    %ebp
  803544:	c3                   	ret    

00803545 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  803545:	55                   	push   %ebp
  803546:	89 e5                	mov    %esp,%ebp
  803548:	53                   	push   %ebx
  803549:	83 ec 14             	sub    $0x14,%esp
  80354c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80354f:	89 1c 24             	mov    %ebx,(%esp)
  803552:	e8 b9 ee ff ff       	call   802410 <strlen>
  803557:	89 c2                	mov    %eax,%edx
  803559:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80355e:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  803564:	7f 1f                	jg     803585 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  803566:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80356a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  803571:	e8 e4 ee ff ff       	call   80245a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  803576:	ba 00 00 00 00       	mov    $0x0,%edx
  80357b:	b8 07 00 00 00       	mov    $0x7,%eax
  803580:	e8 2b fe ff ff       	call   8033b0 <fsipc>
}
  803585:	83 c4 14             	add    $0x14,%esp
  803588:	5b                   	pop    %ebx
  803589:	5d                   	pop    %ebp
  80358a:	c3                   	ret    

0080358b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80358b:	55                   	push   %ebp
  80358c:	89 e5                	mov    %esp,%ebp
  80358e:	83 ec 28             	sub    $0x28,%esp

	// LAB 5: Your code here.
	struct Fd *fd;
	int r;

	if((r = fd_alloc(&fd)) < 0)
  803591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803594:	89 04 24             	mov    %eax,(%esp)
  803597:	e8 1f f8 ff ff       	call   802dbb <fd_alloc>
  80359c:	85 c0                	test   %eax,%eax
  80359e:	78 6a                	js     80360a <open+0x7f>
		return r;
	strcpy(fsipcbuf.open.req_path, path);
  8035a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8035a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035a7:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8035ae:	e8 a7 ee ff ff       	call   80245a <strcpy>
        fsipcbuf.open.req_omode = mode;
  8035b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035b6:	a3 00 54 80 00       	mov    %eax,0x805400
        ipc_send(envs[1].env_id, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8035bb:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  8035c0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8035c7:	00 
  8035c8:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8035cf:	00 
  8035d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8035d7:	00 
  8035d8:	89 04 24             	mov    %eax,(%esp)
  8035db:	e8 ec f6 ff ff       	call   802ccc <ipc_send>
        if((r = ipc_recv(NULL, fd, NULL))<0)
  8035e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8035e7:	00 
  8035e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035f6:	e8 3b f7 ff ff       	call   802d36 <ipc_recv>
  8035fb:	85 c0                	test   %eax,%eax
  8035fd:	78 0b                	js     80360a <open+0x7f>
		return r;
	return fd2num(fd);
  8035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803602:	89 04 24             	mov    %eax,(%esp)
  803605:	e8 86 f7 ff ff       	call   802d90 <fd2num>
	panic("open not implemented");
}
  80360a:	c9                   	leave  
  80360b:	c3                   	ret    

0080360c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80360c:	55                   	push   %ebp
  80360d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80360f:	8b 45 08             	mov    0x8(%ebp),%eax
  803612:	89 c2                	mov    %eax,%edx
  803614:	c1 ea 16             	shr    $0x16,%edx
  803617:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80361e:	f6 c2 01             	test   $0x1,%dl
  803621:	74 26                	je     803649 <pageref+0x3d>
		return 0;
	pte = vpt[VPN(v)];
  803623:	c1 e8 0c             	shr    $0xc,%eax
  803626:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80362d:	a8 01                	test   $0x1,%al
  80362f:	74 18                	je     803649 <pageref+0x3d>
		return 0;
	return pages[PPN(pte)].pp_ref;
  803631:	c1 e8 0c             	shr    $0xc,%eax
  803634:	8d 14 40             	lea    (%eax,%eax,2),%edx
  803637:	c1 e2 02             	shl    $0x2,%edx
  80363a:	b8 00 00 00 ef       	mov    $0xef000000,%eax
  80363f:	0f b7 44 02 08       	movzwl 0x8(%edx,%eax,1),%eax
  803644:	0f b7 c0             	movzwl %ax,%eax
  803647:	eb 05                	jmp    80364e <pageref+0x42>
  803649:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80364e:	5d                   	pop    %ebp
  80364f:	c3                   	ret    

00803650 <__udivdi3>:
  803650:	55                   	push   %ebp
  803651:	89 e5                	mov    %esp,%ebp
  803653:	57                   	push   %edi
  803654:	56                   	push   %esi
  803655:	83 ec 10             	sub    $0x10,%esp
  803658:	8b 45 14             	mov    0x14(%ebp),%eax
  80365b:	8b 55 08             	mov    0x8(%ebp),%edx
  80365e:	8b 75 10             	mov    0x10(%ebp),%esi
  803661:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803664:	85 c0                	test   %eax,%eax
  803666:	89 55 f0             	mov    %edx,-0x10(%ebp)
  803669:	75 35                	jne    8036a0 <__udivdi3+0x50>
  80366b:	39 fe                	cmp    %edi,%esi
  80366d:	77 61                	ja     8036d0 <__udivdi3+0x80>
  80366f:	85 f6                	test   %esi,%esi
  803671:	75 0b                	jne    80367e <__udivdi3+0x2e>
  803673:	b8 01 00 00 00       	mov    $0x1,%eax
  803678:	31 d2                	xor    %edx,%edx
  80367a:	f7 f6                	div    %esi
  80367c:	89 c6                	mov    %eax,%esi
  80367e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803681:	31 d2                	xor    %edx,%edx
  803683:	89 f8                	mov    %edi,%eax
  803685:	f7 f6                	div    %esi
  803687:	89 c7                	mov    %eax,%edi
  803689:	89 c8                	mov    %ecx,%eax
  80368b:	f7 f6                	div    %esi
  80368d:	89 c1                	mov    %eax,%ecx
  80368f:	89 fa                	mov    %edi,%edx
  803691:	89 c8                	mov    %ecx,%eax
  803693:	83 c4 10             	add    $0x10,%esp
  803696:	5e                   	pop    %esi
  803697:	5f                   	pop    %edi
  803698:	5d                   	pop    %ebp
  803699:	c3                   	ret    
  80369a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036a0:	39 f8                	cmp    %edi,%eax
  8036a2:	77 1c                	ja     8036c0 <__udivdi3+0x70>
  8036a4:	0f bd d0             	bsr    %eax,%edx
  8036a7:	83 f2 1f             	xor    $0x1f,%edx
  8036aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8036ad:	75 39                	jne    8036e8 <__udivdi3+0x98>
  8036af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8036b2:	0f 86 a0 00 00 00    	jbe    803758 <__udivdi3+0x108>
  8036b8:	39 f8                	cmp    %edi,%eax
  8036ba:	0f 82 98 00 00 00    	jb     803758 <__udivdi3+0x108>
  8036c0:	31 ff                	xor    %edi,%edi
  8036c2:	31 c9                	xor    %ecx,%ecx
  8036c4:	89 c8                	mov    %ecx,%eax
  8036c6:	89 fa                	mov    %edi,%edx
  8036c8:	83 c4 10             	add    $0x10,%esp
  8036cb:	5e                   	pop    %esi
  8036cc:	5f                   	pop    %edi
  8036cd:	5d                   	pop    %ebp
  8036ce:	c3                   	ret    
  8036cf:	90                   	nop
  8036d0:	89 d1                	mov    %edx,%ecx
  8036d2:	89 fa                	mov    %edi,%edx
  8036d4:	89 c8                	mov    %ecx,%eax
  8036d6:	31 ff                	xor    %edi,%edi
  8036d8:	f7 f6                	div    %esi
  8036da:	89 c1                	mov    %eax,%ecx
  8036dc:	89 fa                	mov    %edi,%edx
  8036de:	89 c8                	mov    %ecx,%eax
  8036e0:	83 c4 10             	add    $0x10,%esp
  8036e3:	5e                   	pop    %esi
  8036e4:	5f                   	pop    %edi
  8036e5:	5d                   	pop    %ebp
  8036e6:	c3                   	ret    
  8036e7:	90                   	nop
  8036e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8036ec:	89 f2                	mov    %esi,%edx
  8036ee:	d3 e0                	shl    %cl,%eax
  8036f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8036f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8036f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8036fb:	89 c1                	mov    %eax,%ecx
  8036fd:	d3 ea                	shr    %cl,%edx
  8036ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803703:	0b 55 ec             	or     -0x14(%ebp),%edx
  803706:	d3 e6                	shl    %cl,%esi
  803708:	89 c1                	mov    %eax,%ecx
  80370a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80370d:	89 fe                	mov    %edi,%esi
  80370f:	d3 ee                	shr    %cl,%esi
  803711:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803715:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803718:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80371b:	d3 e7                	shl    %cl,%edi
  80371d:	89 c1                	mov    %eax,%ecx
  80371f:	d3 ea                	shr    %cl,%edx
  803721:	09 d7                	or     %edx,%edi
  803723:	89 f2                	mov    %esi,%edx
  803725:	89 f8                	mov    %edi,%eax
  803727:	f7 75 ec             	divl   -0x14(%ebp)
  80372a:	89 d6                	mov    %edx,%esi
  80372c:	89 c7                	mov    %eax,%edi
  80372e:	f7 65 e8             	mull   -0x18(%ebp)
  803731:	39 d6                	cmp    %edx,%esi
  803733:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803736:	72 30                	jb     803768 <__udivdi3+0x118>
  803738:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80373b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80373f:	d3 e2                	shl    %cl,%edx
  803741:	39 c2                	cmp    %eax,%edx
  803743:	73 05                	jae    80374a <__udivdi3+0xfa>
  803745:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  803748:	74 1e                	je     803768 <__udivdi3+0x118>
  80374a:	89 f9                	mov    %edi,%ecx
  80374c:	31 ff                	xor    %edi,%edi
  80374e:	e9 71 ff ff ff       	jmp    8036c4 <__udivdi3+0x74>
  803753:	90                   	nop
  803754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803758:	31 ff                	xor    %edi,%edi
  80375a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80375f:	e9 60 ff ff ff       	jmp    8036c4 <__udivdi3+0x74>
  803764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803768:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80376b:	31 ff                	xor    %edi,%edi
  80376d:	89 c8                	mov    %ecx,%eax
  80376f:	89 fa                	mov    %edi,%edx
  803771:	83 c4 10             	add    $0x10,%esp
  803774:	5e                   	pop    %esi
  803775:	5f                   	pop    %edi
  803776:	5d                   	pop    %ebp
  803777:	c3                   	ret    
	...

00803780 <__umoddi3>:
  803780:	55                   	push   %ebp
  803781:	89 e5                	mov    %esp,%ebp
  803783:	57                   	push   %edi
  803784:	56                   	push   %esi
  803785:	83 ec 20             	sub    $0x20,%esp
  803788:	8b 55 14             	mov    0x14(%ebp),%edx
  80378b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80378e:	8b 7d 10             	mov    0x10(%ebp),%edi
  803791:	8b 75 0c             	mov    0xc(%ebp),%esi
  803794:	85 d2                	test   %edx,%edx
  803796:	89 c8                	mov    %ecx,%eax
  803798:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80379b:	75 13                	jne    8037b0 <__umoddi3+0x30>
  80379d:	39 f7                	cmp    %esi,%edi
  80379f:	76 3f                	jbe    8037e0 <__umoddi3+0x60>
  8037a1:	89 f2                	mov    %esi,%edx
  8037a3:	f7 f7                	div    %edi
  8037a5:	89 d0                	mov    %edx,%eax
  8037a7:	31 d2                	xor    %edx,%edx
  8037a9:	83 c4 20             	add    $0x20,%esp
  8037ac:	5e                   	pop    %esi
  8037ad:	5f                   	pop    %edi
  8037ae:	5d                   	pop    %ebp
  8037af:	c3                   	ret    
  8037b0:	39 f2                	cmp    %esi,%edx
  8037b2:	77 4c                	ja     803800 <__umoddi3+0x80>
  8037b4:	0f bd ca             	bsr    %edx,%ecx
  8037b7:	83 f1 1f             	xor    $0x1f,%ecx
  8037ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8037bd:	75 51                	jne    803810 <__umoddi3+0x90>
  8037bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8037c2:	0f 87 e0 00 00 00    	ja     8038a8 <__umoddi3+0x128>
  8037c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037cb:	29 f8                	sub    %edi,%eax
  8037cd:	19 d6                	sbb    %edx,%esi
  8037cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8037d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037d5:	89 f2                	mov    %esi,%edx
  8037d7:	83 c4 20             	add    $0x20,%esp
  8037da:	5e                   	pop    %esi
  8037db:	5f                   	pop    %edi
  8037dc:	5d                   	pop    %ebp
  8037dd:	c3                   	ret    
  8037de:	66 90                	xchg   %ax,%ax
  8037e0:	85 ff                	test   %edi,%edi
  8037e2:	75 0b                	jne    8037ef <__umoddi3+0x6f>
  8037e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8037e9:	31 d2                	xor    %edx,%edx
  8037eb:	f7 f7                	div    %edi
  8037ed:	89 c7                	mov    %eax,%edi
  8037ef:	89 f0                	mov    %esi,%eax
  8037f1:	31 d2                	xor    %edx,%edx
  8037f3:	f7 f7                	div    %edi
  8037f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037f8:	f7 f7                	div    %edi
  8037fa:	eb a9                	jmp    8037a5 <__umoddi3+0x25>
  8037fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803800:	89 c8                	mov    %ecx,%eax
  803802:	89 f2                	mov    %esi,%edx
  803804:	83 c4 20             	add    $0x20,%esp
  803807:	5e                   	pop    %esi
  803808:	5f                   	pop    %edi
  803809:	5d                   	pop    %ebp
  80380a:	c3                   	ret    
  80380b:	90                   	nop
  80380c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803810:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803814:	d3 e2                	shl    %cl,%edx
  803816:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803819:	ba 20 00 00 00       	mov    $0x20,%edx
  80381e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  803821:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803824:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803828:	89 fa                	mov    %edi,%edx
  80382a:	d3 ea                	shr    %cl,%edx
  80382c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803830:	0b 55 f4             	or     -0xc(%ebp),%edx
  803833:	d3 e7                	shl    %cl,%edi
  803835:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803839:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80383c:	89 f2                	mov    %esi,%edx
  80383e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  803841:	89 c7                	mov    %eax,%edi
  803843:	d3 ea                	shr    %cl,%edx
  803845:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803849:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80384c:	89 c2                	mov    %eax,%edx
  80384e:	d3 e6                	shl    %cl,%esi
  803850:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803854:	d3 ea                	shr    %cl,%edx
  803856:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80385a:	09 d6                	or     %edx,%esi
  80385c:	89 f0                	mov    %esi,%eax
  80385e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  803861:	d3 e7                	shl    %cl,%edi
  803863:	89 f2                	mov    %esi,%edx
  803865:	f7 75 f4             	divl   -0xc(%ebp)
  803868:	89 d6                	mov    %edx,%esi
  80386a:	f7 65 e8             	mull   -0x18(%ebp)
  80386d:	39 d6                	cmp    %edx,%esi
  80386f:	72 2b                	jb     80389c <__umoddi3+0x11c>
  803871:	39 c7                	cmp    %eax,%edi
  803873:	72 23                	jb     803898 <__umoddi3+0x118>
  803875:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803879:	29 c7                	sub    %eax,%edi
  80387b:	19 d6                	sbb    %edx,%esi
  80387d:	89 f0                	mov    %esi,%eax
  80387f:	89 f2                	mov    %esi,%edx
  803881:	d3 ef                	shr    %cl,%edi
  803883:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803887:	d3 e0                	shl    %cl,%eax
  803889:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80388d:	09 f8                	or     %edi,%eax
  80388f:	d3 ea                	shr    %cl,%edx
  803891:	83 c4 20             	add    $0x20,%esp
  803894:	5e                   	pop    %esi
  803895:	5f                   	pop    %edi
  803896:	5d                   	pop    %ebp
  803897:	c3                   	ret    
  803898:	39 d6                	cmp    %edx,%esi
  80389a:	75 d9                	jne    803875 <__umoddi3+0xf5>
  80389c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80389f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8038a2:	eb d1                	jmp    803875 <__umoddi3+0xf5>
  8038a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8038a8:	39 f2                	cmp    %esi,%edx
  8038aa:	0f 82 18 ff ff ff    	jb     8037c8 <__umoddi3+0x48>
  8038b0:	e9 1d ff ff ff       	jmp    8037d2 <__umoddi3+0x52>
