@;TIM2_INT_barebones_init.asm wmh 2016-04-29 : setup timer 5 with interrupt
@; Timer 2 initialization and the related NVIC setup is done immediately below in 'TIM2_INT_init()'. 

	@;constants below should create  make interrupt frequency= 168000000/(TIM2_PRESCALE*TIM2_AUTORELOAD) !!check this (e.g. prescalar input is /2 or ? already
	.equ TIM2_PRESCALE,0x0002		@;up to 16 bits
	.equ TIM2_AUTORELOAD,0x00000076		@;up to 32 bits (TIM2 and TIM5 only)

@; --- characterize target syntax, processor
	.syntax unified					@; ARM Unified Assembler Language (UAL). 
	.thumb							@; Use thumb instructions only

.macro MOV_imm32 reg val			@;example of use: MOV_imm32 r0,0x12345678 !!note: no '#' on immediate value
	movw \reg,#(0xFFFF & (\val))
	movt \reg,#((0xFFFF0000 & (\val))>>16)
.endm
	
@; --- begin code memory
	.text							@;start the code section
	
	.equ RCC,0x40023800				@;device addresses from RM0090 Table 2
	.equ TIM2,0x40000000			@; ""		
	.equ TIM2_CNT, TIM2+0x24
	
	.global read_TIM2_CNT
	.thumb_func
read_TIM2_CNT:
	push {r1-r3, lr}
	MOV_imm32 r1, TIM2_CNT
	ldr r0, [r1]
	pop {r1-r3, lr}
	bx lr
	
	.global writeTIM2_CNT
	.thumb_func
write_TIM2_CNT:
	push {r0-r3, lr}
	MOV_imm32 r1, TIM2_CNT
	str r0, [r1]
	pop {r0-r3, lr}
	bx lr
	
	
	.global TIM2_INT_init
	.thumb_func
TIM2_INT_init:	
	
	@;reset TIM2 for fresh start (also turns off TIM2 interrupt enable so things are safe)
	.set RCC_APB1RSTR,(RCC+0x20)	@;RM0090 Tables 25
	MOV_imm32 r2, (RCC_APB1RSTR)	@; .. 
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. RCC TIM2RST = device reset
	str r0,[r2]						@; ..
	bic r0,1<<0						@; .. suprised to find that setting this bit holds TIM in reset
	str r0,[r2]						@; ..
	
	@;TIM2 device 'ON' 
	.equ RCC_APB1ENR,(RCC+0x40)		@;RM0090 Tables 25 
	MOV_imm32 r2,RCC_APB1ENR		@; .. 
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. RCC ? = device enable
	str r0,[r2]						@; ..
	
	TIM2_IRQn = 28  				@;found in .pre -- where in manual? 
	
	@;set TIM2 interrupt enable in NVIC
	.equ NVIC_ISER0,(0xE000E100)			@;DDI0403D Table B3-35
	MOV_imm32 r2,NVIC_ISER0
	ldr r0,[r2]
	orr r0,1<<(TIM2_IRQn)
	str r0,[r2]
	
	@;clear 
	.equ NVIC_ICER0,(0xE000E180)			@;DDI0403D Table B3-34
	MOV_imm32 r2,NVIC_ICER0
	ldr r0,[r2]
	bic r0,1<<(TIM2_IRQn)
	str r0,[r2]
	
	@;set TIM2 priority to pending in NVIC
	.equ NVIC_ISPR0,(0xE000E200+0x03) 		@;interrupt priority byte-address from DDI0403D Table B3-36 and section B3.4.8
	MOV_imm32 r2,NVIC_ISPR0
	mov r0,#0x30
	strb r0,[r2]
	
	@;write TIM2 prescalar and auto reload values
	.equ TIM2_PSC,(TIM2+0x28)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM2_PSC			@; ..
	MOV_imm32 r0,TIM2_PRESCALE		@; ..  using .equ value set above
	str r0,[r2]						@; ..
	.equ TIM2_ARR,(TIM2+0x2C)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM2_ARR			@; ..
	MOV_imm32 r0,TIM2_AUTORELOAD	@; .. using .equ value set above
	str r0,[r2]						@; ..
	
	@;TIM2 auto-reload preload enable
	.equ TIM2_CR1,(TIM2+0x00)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM2_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<7						
	str r0,[r2]	
	
	@;set TIM2 interrupt enable
	.equ TIM2_DIER,(TIM2+0x0C)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM2_DIER			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<6						@; .. TIM2 ? = trigger interrupt enable
	str r0,[r2]						@; ..
	
	@;TIM2 update request source
	.equ TIM2_CR1,(TIM2+0x00)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM2_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<2						
	str r0,[r2]	
	
	MOV_imm32 r2,TIM2_DIER			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. TIM2 ? = update interrupt enable
	str r0,[r2]						@; ..

	MOV_imm32 r2,TIM2_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<3						@; .. TIM2 one pulse mode; will stop counting at next update event (need to set CEN again in handler)
	str r0,[r2]						@; ..
	
	MOV_imm32 r2,TIM2_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. TIM2 counter enable; default values for everything else
	str r0,[r2]	
	
	.equ TIM2_SR,(TIM2+0x10)		@; ..
	MOV_imm32 r2,TIM2_SR			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<6						@; .. TIM2 ? =  interrupt flag
	str r0,[r2]	
	
	bx lr

	.global start_timer2
	.thumb_func
start_timer2:
	push {r0-r3, lr}
	@;TIM2 counter enable
	MOV_imm32 r2,TIM2_CR1			@; ..
	ldr r1,[r2]						@; ..
	orr r1,1<<0						@; .. TIM2 counter enable; default values for everything else
	str r1,[r2]						@; ..
	pop {r0-r3, lr}
	bx lr
	
	.global pause_TIM2
	.thumb_func
pause_TIM2:
	push {r0-r3, lr}
	MOV_imm32 r2,TIM2_CR1			@; ..
	ldr r1,[r2]						@; ..
	bic r1,1<<0						@; .. TIM5 counter disable; default values for everything else
	str r1,[r2]
	pop {r0-r3, lr}
	bx lr

	.global clear_TIM2_TIF_UIF
	.thumb_func
clear_TIM2_TIF_UIF:
	push {r0-r3, lr}
	@;clear TIM2 trigger interrupt flag		@;RM0090 Tables 76 ?????????????????????
	.equ TIM2_SR,(TIM2+0x10)		@; ..
	MOV_imm32 r2,TIM2_SR			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<6						@; .. TIM2 ? =  interrupt flag
	str r0,[r2]						@; ..
	
	@;clear TIM2 update interrupt flag		
	.equ TIM2_SR,(TIM2+0x10)		@; ..
	MOV_imm32 r2,TIM2_SR			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<0						@; .. TIM2 ? =  interrupt flag
	str r0,[r2]						@; ..
	
	pop {r0-r3, lr}
	bx lr
	