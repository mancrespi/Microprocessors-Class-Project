@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
	.thumb						@; Use thumb instructions only
	
@; --- begin code memory
	.text						@;start the code section


.equ PERIPH_BASE,(0x40000000)					@;#define PERIPH_BASE           (0x40000000)
.equ AHB1PERIPH_BASE,(PERIPH_BASE + 0x00020000)	@;#define AHB1PERIPH_BASE       (PERIPH_BASE + 0x00020000)
.equ APB1PERIPH_BASE,(PERIPH_BASE + 0x00000000)

.equ RCC_APB1ENR, 0x40023840@;APB1PERIPH_BASE + 0x40
.equ RCC_BASE, AHB1PERIPH_BASE + (0x00003800)
.equ RCC_CFGR, RCC_BASE + (0x08)
.equ RCC_BDCR, RCC_BASE + (0x70)
.equ RCC_CSR, RCC_BASE + (0x74)

.equ RTC_BASE, (PERIPH_BASE + 0x00002800)
.equ RTC_TR, RTC_BASE + (0x00)			
.equ RTC_DR, RTC_BASE + (0x04)
.equ RTC_CR, RTC_BASE + (0x08)
.equ RTC_ISR, RTC_BASE + (0x0C)
.equ RTC_PRER, RTC_BASE + (0x10)
.equ RTC_WUTR, RTC_BASE + (0x14)
.equ RTC_CALIBR, RTC_BASE + (0x18)
.equ RTC_ALRMAR, RTC_BASE + (0x1C)
.equ RTC_ALRMBR, RTC_BASE + (0x20)
.equ RTC_WPR, RTC_BASE + (0x24)
.equ RTC_SSR, RTC_BASE + (0x28)
.equ RTC_SHIFTR, RTC_BASE + (0x2C)
.equ RTC_TSTR, RTC_BASE + (0x30)
.equ RTC_TSDR, RTC_BASE + (0x34)
.equ RTC_TSSSR, RTC_BASE + (0x38)
.equ RTC_CALR, RTC_BASE + (0x3C)
.equ RTC_TAFCR, RTC_BASE + (0x40)
.equ RTC_ALRMASSR, RTC_BASE + (0x44)
.equ RTC_ALRMBSSR, RTC_BASE + (0x48)

.equ PWR_CR, PERIPH_BASE + (0x00007000)

@;---------------------------------------------------------------------------------------

@; Useful Macros...
.macro MOV_imm32 reg val		@;example of use: MOV_imm32 r0,0x12345678 !!note: no '#' on immediate value
	movw \reg,#(0xFFFF & (\val))
	movt \reg,#((0xFFFF0000 & (\val))>>16)
.endm

.macro SET_bit addr bit
	MOV_imm32 r2,(\addr)
	ldr r1,[r2]
	ORR r1,#(1<<\bit)
	str r1,[r2]	
.endm

.macro CLEAR_bit addr bit
	MOV_imm32 r2,(\addr)
	ldr r1,[r2]
	bic r1,#(1<<\bit)
	str r1,[r2]	
.endm

.macro PORTBIT_read REG_BASE bit	@;read 'bit' of port GPIOx, return bit value in bit0 of r0 and 'Z' flag set/clear if bit=0/1
	MOV_imm32 r2,(\REG_BASE)
	ldr r0,[r2]
	ands r0,#(1<<\bit)
	lsr r0,#\bit
.endm

@;---------------------------------------------------------------------------------------
	.global BackupDomainReset
	.thumb_func
BackupDomainReset:
	push {r1,r2}
	SET_bit RCC_BDCR 16
	pop {r1,r2}
	bx lr
	
	.global RTC_PWR_enable
	.thumb_func
RTC_PWR_enable:
	push {r1,r2}
	SET_bit RCC_APB1ENR 28
	pop {r1,r2}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
	bx lr

	.global RTC_access_enable		@; writes a 1 to DBP bit
	.thumb_func
RTC_access_enable:
	push {r1,r2}
	SET_bit PWR_CR 8
	pop {r1,r2}
	bx lr
	
	.global LSI_ON
	.thumb_func
LSI_ON:
	push {r0-r2, lr}
	SET_bit RCC_CSR 0
	pop {r0-r2, lr}
	bx lr
	
	.global RTC_use_LSI
	.thumb_func
RTC_use_LSI:
	push {r1-r2, lr}
	bl LSI_ON
	pop {r1-r2, lr}
	bx lr	
	
	.global RTC_clock_enable
	.thumb_func
RTC_clock_enable:
	push {r1,r2}
	@; clear backup domain reset (just in case)
	CLEAR_bit RCC_BDCR 16
	@; select LSI as clock source
	SET_bit RCC_BDCR 9
	@; enable RTC clock
	SET_bit RCC_BDCR 15
	pop {r1,r2}
	bx lr

	.global RTC_use_24hour_time
	.thumb_func
RTC_use_24hour_time:
	push {r1,r2}
	CLEAR_bit RTC_CR 6
	pop {r1,r2}
	bx lr
	
	.global RTC_LSI_notready
	.thumb_func
RTC_LSI_notready:
	push {r1-r3, lr}
	PORTBIT_read RCC_CSR 1
	mov r1, #1
	eor r0, r0, r1
	pop  {r1-r3, lr}
	bx lr
	
	.global enter_RTCinit_mode
	.thumb_func
enter_RTCinit_mode:
	push {r0-r2, lr}
	@; key needed to undo write protection on RTC registers
	MOV_imm32 r1, RTC_WPR
	movw r0, #0xCA
	strb r0, [r1]
	movw r0, #0x53
	strb r0, [r1]
	@; counter stops to enter init mode
	SET_bit RTC_ISR 7
	bl wait_for_init_mode
	pop {r0-r2, lr}
	bx lr
	
	.global exit_RTCinit_mode
	.thumb_func
exit_RTCinit_mode:
	push {r0-r2, lr}
	@; counter continues, go back into free mode
	CLEAR_bit RTC_ISR 7
	pop {r0-r2, lr}
	bx lr
	
	.global read_INITF
	.thumb_func
read_INITF:
	PORTBIT_read RTC_ISR 6
	bx lr

@;---------------------------------------------------------------------------------------
.equ RTC_TR_MASK, 0xFF808080

	.global setTime
	.thumb_func
setTime:
	push {r0-r3, lr}
	MOV_imm32 r3, RTC_TR
	ldr r2, [r3]
	MOV_imm32 r1, RTC_TR_MASK 		@;mask for the reserve bits
	and r2, r1						@;leaves the reserved bits unchanged
	orr r0, r2
	str r0, [r3]
	pop {r0-r3, lr}
	bx lr
	
	.global read_RTC_TR
	.thumb_func
read_RTC_TR:
	push {r1, lr}
	MOV_imm32 r1, RTC_TR
	ldr r0, [r1]
	pop {r1, lr}
	bx lr
	
	.global getHRS
	.thumb_func
getHRS:
	push {r1-r3, lr}
	bl read_RTC_TR
	MOV_imm32 r1, RTC_TR_MASK
	bic r0, r1
	lsr r0, r0, #16
	and r0, r0, #0x3F
	pop {r1-r3, lr}
	bx lr
	
	.global getMIN
	.thumb_func
getMIN:
	push {r1-r3, lr}
	bl read_RTC_TR
	MOV_imm32 r1, RTC_TR_MASK
	bic r0, r1
	lsr r0, r0, #8
	and r0, r0, #0x7F
	pop {r1-r3, lr}
	bx lr
	
	.global getSEC
	.thumb_func
getSEC:
	push {r1-r3, lr}
	bl read_RTC_TR
	MOV_imm32 r1, RTC_TR_MASK
	bic r0, r1
	and r0, r0, #0x7F
	pop {r1-r3, lr}
	bx lr
	
	
.equ RTC_DR_MASK, 0xFF0000C0

	.global setDate
	.thumb_func
setDate:
	push {r0-r3, lr}
	MOV_imm32 r3, RTC_DR
	ldr r2, [r3]
	MOV_imm32 r1, RTC_DR_MASK 		@;mask for the reserve bits
	and r2, r1						@;leaves the reserved bits unchanged
	orr r0, r2
	str r0, [r3]
	pop {r0-r3, lr}
	bx lr
	
	.global read_RTC_DR
	.thumb_func
read_RTC_DR:
	push {r1, lr}
	MOV_imm32 r1, RTC_DR
	ldr r0, [r1]
	pop {r1, lr}
	bx lr
	
	.global getMO
	.thumb_func
getMO:
	push {r1-r3, lr}
	bl read_RTC_DR
	MOV_imm32 r1, RTC_DR_MASK
	bic r0, r1
	lsr r0, r0, #8
	and r0, r0, #0x1F
	pop {r1-r3, lr}
	bx lr
	
	.global getDAY
	.thumb_func
getDAY:
	push {r1-r3, lr}
	bl read_RTC_DR
	MOV_imm32 r1, RTC_DR_MASK
	bic r0, r1
	and r0, r0, #0x3F
	pop {r1-r3, lr}
	bx lr
	
	.global getYR
	.thumb_func
getYR:
	push {r1-r3, lr}
	bl read_RTC_DR
	MOV_imm32 r1, RTC_DR_MASK
	bic r0, r1
	lsr r0, r0, #16
	and r0, r0, #0xFF
	pop {r1-r3, lr}
	bx lr
