#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>


// Choose a user environment to run and run it.
void
sched_yield(void)
{
	// Implement simple round-robin scheduling.
	// Search through 'envs' for a runnable environment,
	// in circular fashion starting after the previously running env,
	// and switch to the first such environment found.
	// It's OK to choose the previously running env if no other env
	// is runnable.
	// But never choose envs[0], the idle environment,
	// unless NOTHING else is runnable.

	// LAB 4: Your code here.
	int i;
	int k = 0;
	int envid = 0;
	int flag = 0;
	int f = 0;
	
//	cprintf("kern-sched_yield() -- \n");
	if(curenv)
	{
		envid_t curenvid = curenv->env_id;
		envid = ENVX(curenvid);
	}
	for(i = envid+1; k < NENV-1; k++)
	{
//		cprintf("status: %d -- %d\n", i, envs[i].env_status);
		if(envs[i].env_status == ENV_RUNNABLE)
		{
/*			cprintf("env %d is runnable\n",i);
			cprintf("*env_pgdir: %x\n", envs[i].env_pgdir);
			cprintf("eip: %x\n",envs[i].env_tf.tf_eip);
			cprintf("esp: %x\n",envs[i].env_tf.tf_esp);*/
			env_run(&envs[i]);
		}
		i++;
		if(i == NENV)
		{
			i = 1;
			continue;
		}
	}
	// Run the special idle environment when nothing else is runnable.	
	//cprintf("kern-sched_yield() -- %x\n",curenv);
	if (envs[0].env_status == ENV_RUNNABLE)
		env_run(&envs[0]);
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
		while (1)
			monitor(NULL);
	}
}
