@ ; - PendSV can used to defer requests to switch task context from both SysTick interrupts and SVC calls and thus avoid
@ ; preempting/delaying a hardware interrupt with a SysTick or SVC task-switch call.
@ ; If either SysTick or SVC are called to switch tasks they can instead
@ ;set up data for the task-switch to be done by PendSV, then set PendSV flag and return. If what is being returned to is a task
@ ; then PendSV will fire and execution will switch to the new task. If what is being returned to is an IRQ, then because PendSV's priority 
@ ; has been set lower (the assumption) than all other IRQs, the task switch will be deferred until all of the other IRQs are processed. 
@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
	.thumb						@; Use thumb instructions only

@ ;*** definitions ***
@ ;
@ ; NVIC interrupt control registers -- not used for system interrupts
@ ;.equ NVIC_ISERbase,0xE000E100
@ ;.equ NVIC_ICERbase,0xE000E180
@ ;.equ NVIC_ISPbase,0xE000E200
@ ;.equ NVIC_ICPbase,0xE000E280
@ ;.equ NVIC_IABbase,0xE000E300
@ ;.equ NVIC_IPRbase,0xE000E400
@ ;
@ ; system interrupt numbers are of academic interest (only) -- we dont use them
@ ;.equ SvcHandlerExcep,-4
@ ;.equ PendSVExcep,-2
@ ;.equ SysTickExcep,-1
@ ;
@ ;registers used for SysTick, SVC, and PendSV initializations, drawn from DDI0439 and DDI0403D
	
.equ SYST_CSR, 0xE000E010
.equ SCR, 0xE000ED10 
.equ CCR, 0xE000ED14 
.equ SHPR1, 0xE000ED18 
.equ SHPR2, 0xE000ED1C 
.equ SHPR3, 0xE000ED20 
.equ SHCSR, 0xE000ED24
.equ ICSR, 0xE000ED04 
.equ PENDSVSET, 28 
.equ PENDSVCLR, 27
.equ SysTick_PR, SHPR3+3 
.equ PendSV_PR, SHPR3+2 
.equ SvcHandler_PR, SHPR2+3

.macro MOV_imm32 reg val
	movw \reg,#(0xFFFF & (\val)) 
	movt \reg,#((0xFFFF0000 & (\val))>>16) 
.endm

@; --- begin code memory
	.text						@;start the code section

	.word 0
	.word 0
task1:
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	
	.word 0
	.word 0
task2:
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0

task_table_beg:	
				.word =task1
				.word =task2
task_table_end:

current_task:   .word 0

.global task_table_SIZE
task_table_SIZE: .word 2
	
@ ;SvcHandler interrupt hardware setup. 
	.global SvcHandlerInt_init
	.thumb_func
SvcHandlerInt_init:
	push {r1-r3, lr}			@ ;void SvcHandler_init(int priority); //configure SVC interrupt with 0x00<priority<0xF0 (low four bits are ignored) 
	@ ;establish SVC priority
	MOV_imm32 r1,SvcHandler_PR	@ ;byte-address of SVC priority register
	strb r0, [r1]				@ ;function argument= interrupt priority (only upper 4 bits of STM32F407 priority are used) 
	@; task table init setup 
	ldr  r1, =current_task
	mov  r2, #0 
	str  r2, [r1]
	
	pop {r1-r3, lr}				@ ;set priority
	bx lr

@ ;PendSV interrupt hardware setup.  
	.global PendSvInt_init
	.thumb_func 
PendSvInt_init:
	push {r0-r3, lr}	@ ;void PendSV_init(int priority); //configure PendSV interrupt with 0x00<priority<0xF0 (low four bits are ignored) 
	@ ;PendSV priority should be lowest (highest numerical) so it only occurs if no other interrupts are running
	@ ;establish PenSV priority
	MOV_imm32 r1,PendSV_PR		@ ;get byte-address of PendSV priority register
	strb r0, [r1]				@ ;function argument= interrupt priority (only upper 4 bits of STM32F407 priority are used) 
	
	MOV_imm32 r2, ICSR			@ ;set priority	
	ldr  r0, [r2]
	orr  r0, 1<<PENDSVSET
	str  r0, [r2]
	pop {r0-r3, lr}
	bx lr
	
	.global PendSVInt_clear
	.thumb_func
PendSVInt_clear:
	push {r0-r3, lr}	@ ;void PendSV_init(int priority); //configure PendSV interrupt with 0x00<priority<0xF0 (low four bits are ignored) 
	MOV_imm32 r2, ICSR			@ ;remove pending status of PendSV
	ldr  r0, [r2]
	orr  r0, 1<<PENDSVCLR
	str  r0, [r2]
	pop {r0-r3, lr}
	bx lr

	.global SVC_trap
	.thumb_func
SVC_trap:
	cmp r0, #0
	beq svc0
	cmp r0, #1
	beq svc1
	cmp r0, #2
	beq svc2
	cmp r0, #3
	beq svc3
	cmp r0, #4
	beq svc4
	cmp r0, #5
	beq svc5
	cmp r0, #6
	beq svc6
	svc0:
		svc #0	
		bx lr
	svc1:
		svc #1
		bx lr
	svc2:
		svc #2
		bx lr
	svc3:
		svc #3
		bx lr
	svc4:
		svc #4
		bx lr
	svc5:
		svc #5
		bx lr
	svc6:
		svc #6
		bx lr
	
	@; return pointer to next task save location
	.global get_next_task
	.thumb_func
get_next_task:
	push {r1-r3, lr}
	ldr  r1, =current_task
	ldr	 r0, [r1]				@; r0 is index
	ldr  r3, =task_table_SIZE
	ldr  r2, [r3]				@; r2 is table size
	cmp  r0, r2
	
	@; process next task index
	it  eq
	moveq r0, #-1

	add r3, r0, #1				@; r3 is index+1
	str r3, [r1]				@; current_task holds index+1
	
	mov  r2, r0					@; r2 = index
	ldr  r3, =task_table_beg
	ldr  r0, [r3, r2] 			@; r0 = task_table_beg[index]
	
	pop  {r1-r3, lr}
	bx lr
	
	.ltorg
@ ;create a literal pool here for any constants defined above.
