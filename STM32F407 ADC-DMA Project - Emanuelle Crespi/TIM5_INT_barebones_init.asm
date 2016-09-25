@;TIM5_INT_barebones_init01.asm(obfuscated) wmh 2016-05-02 : obfscated version of the deblow; fix ? values to unobfuscate
@;TIM5_INT_barebones_init01.asm wmh 2016-04-29 : setup timer 5 with interrupt
@; Timer 5 initialization and the related NVIC setup is done immediately below in 'TIM5_INT_init()'.
@; Timer 5 interrupt routine 'TIM5_IRQHandler()' can be found in 'TIMx_PSV_SVC_Handlers.c'. 

	@;constants below should create  make interrupt frequency= 168000000/(TIM5_PRESCALE*TIM5_AUTORELOAD) !!check this (e.g. prescalar input is /2 or ? already
	.equ TIM5_PRESCALE,0x1DF		@;up to 16 bits
	.equ TIM5_AUTORELOAD,0x1EFF		@;up to 32 bits (TIM2 and TIM5 only)

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
	.equ TIM5,0x40000C00			@; ""		
	.equ TIM5_CNT, TIM5+0x24
	
	.global read_TIM5_CNT
	.thumb_func
read_TIM5_CNT:
	push {r1-r3, lr}
	MOV_imm32 r1, TIM5_CNT
	ldr r0, [r1]
	pop {r1-r3, lr}
	bx lr
	
	.global writeTIM5_CNT
	.thumb_func
write_TIM5_CNT:
	push {r0-r3, lr}
	MOV_imm32 r1, TIM5_CNT
	str r0, [r1]
	pop {r0-r3, lr}
	bx lr
	
	.global start_timer5
	.thumb_func
start_timer5:
	push {r0-r3, lr}
	.equ TIM5_CR1,(TIM5+0x00)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<3						@; .. TIM5 one pulse mode; will stop counting at next update event (need to set CEN again in handler)
	str r0,[r2]						@; ..
	
	@;TIM5 counter enable
	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. TIM5 counter enable; default values for everything else
	str r0,[r2]						@; ..
	pop {r0-r3, lr}
	bx lr
	
	.global TIM5_INT_init
	.thumb_func
TIM5_INT_init:	
	
	@;reset TIM5 for fresh start (also turns off TIM5 interrupt enable so things are safe)
	.set RCC_APB1RSTR,(RCC+0x20)	@;RM0090 Tables 25
	MOV_imm32 r2, (RCC_APB1RSTR)	@; .. 
	ldr r0,[r2]						@; ..
	orr r0,1<<3						@; .. RCC TIM5RST = device reset
	str r0,[r2]						@; ..
	bic r0,1<<3						@; .. suprised to find that setting this bit holds TIM in reset
	str r0,[r2]						@; ..
	
	@;TIM5 device 'ON' 
	.equ RCC_APB1ENR,(RCC+0x40)		@;RM0090 Tables 25 
	MOV_imm32 r2,RCC_APB1ENR		@; .. 
	ldr r0,[r2]						@; ..
	orr r0,1<<3						@; .. RCC ? = device enable
	str r0,[r2]						@; ..
	
	TIM5_IRQn = 50  				@;found in .pre -- where in manual? 
	
	@;set TIM5 interrupt enable in NVIC
	.equ NVIC_ISER1,(0xE000E104)			@;DDI0403D Table B3-35
	MOV_imm32 r2,NVIC_ISER1
	ldr r0,[r2]
	orr r0,1<<(TIM5_IRQn-32)
	str r0,[r2]
	
	@;clear 
	.equ NVIC_ICER1,(0xE000E184)			@;DDI0403D Table B3-34
	MOV_imm32 r2,NVIC_ICER1
	ldr r0,[r2]
	bic r0,1<<(TIM5_IRQn-32)
	str r0,[r2]
	
	@;set TIM5 priority to pending in NVIC
	.equ NVIC_ISPR1,(0xE000E200+0x06) 		@;interrupt priority byte-address from DDI0403D Table B3-36 and section B3.4.8
	MOV_imm32 r2,NVIC_ISPR1
	mov r0,#0x40
	strb r0,[r2]
	
	@;write TIM5 prescalar and auto reload values
	.equ TIM5_PSC,(TIM5+0x28)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM5_PSC			@; ..
	MOV_imm32 r0,TIM5_PRESCALE		@; ..  using .equ value set above
	str r0,[r2]						@; ..
	.equ TIM5_ARR,(TIM5+0x2C)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM5_ARR			@; ..
	MOV_imm32 r0,TIM5_AUTORELOAD	@; .. using .equ value set above
	str r0,[r2]						@; ..
	
	@;TIM5 auto-reload preload enable
	.equ TIM5_CR1,(TIM5+0x00)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<7						
	str r0,[r2]	
	
	@;set TIM5 interrupt enable
	.equ TIM5_DIER,(TIM5+0x0C)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM5_DIER			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<6						@; .. TIM5 ? = trigger interrupt enable
	str r0,[r2]						@; ..
	
	@;TIM5 update request source
	.equ TIM5_CR1,(TIM5+0x00)		@;RM0090 Tables 76
	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<2						
	str r0,[r2]	
	
	MOV_imm32 r2,TIM5_DIER			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. TIM5 ? = update interrupt enable
	str r0,[r2]						@; ..

	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<3						@; .. TIM5 one pulse mode; will stop counting at next update event (need to set CEN again in handler)
	str r0,[r2]						@; ..
	
	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	orr r0,1<<0						@; .. TIM5 counter enable; default values for everything else
	str r0,[r2]	
	
	.equ TIM5_SR,(TIM5+0x10)		@; ..
	MOV_imm32 r2,TIM5_SR			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<6						@; .. TIM5 ? =  interrupt flag
	str r0,[r2]	
	
	bx lr
	
	.global pause_TIM5
	.thumb_func
pause_TIM5:
	push {r0-r3, lr}
	MOV_imm32 r2,TIM5_CR1			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<0						@; .. TIM5 counter disable; default values for everything else
	str r0,[r2]
	pop {r0-r3, lr}
	bx lr
	
	.global clear_TIM5_TIF_UIF
	.thumb_func
clear_TIM5_TIF_UIF:
	push {r0-r3, lr}
	@;clear TIM5 trigger interrupt flag		@;RM0090 Tables 76 ?????????????????????
	.equ TIM5_SR,(TIM5+0x10)		@; ..
	MOV_imm32 r2,TIM5_SR			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<6						@; .. TIM5 ? =  interrupt flag
	str r0,[r2]						@; ..
	
	@;clear TIM5 update interrupt flag		
	.equ TIM5_SR,(TIM5+0x10)		@; ..
	MOV_imm32 r2,TIM5_SR			@; ..
	ldr r0,[r2]						@; ..
	bic r0,1<<0						@; .. TIM5 ? =  interrupt flag
	str r0,[r2]						@; ..
	
	pop {r0-r3, lr}
	bx lr
	
	
