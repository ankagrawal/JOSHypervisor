// Fork a binary tree of processes and display their structure.

#include <inc/lib.h>

#define DEPTH 3

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
		return;

	cprintf("\nbeg forkchild\n");
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
	cprintf("%x%c\n", nxt, branch);
	cprintf("%s\n", nxt);
	cprintf("\nend forkchild\n");
	if (fork() == 0) {
		forktree(nxt);
		exit();
	}
}

void
forktree(const char *cur)
{
	cprintf("\nbeg forktree\n");
	cprintf("%04x: I am '%x'\n", sys_getenvid(), cur);
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
	cprintf("%04x: I am '%x'\n", sys_getenvid(), &cur);
	cprintf("\nend forktree\n");

	forkchild(cur, '0');
	forkchild(cur, '1');
}

void
umain(void)
{
	forktree("");
}

