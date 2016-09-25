@;display_led_switch_drivers.asm 2016-04-26 : 
@;  uses LED and switches identified on "P24_LED-switch_concept_drawing.pdf" handout 
@;  pins accessed by observing the wiring in "P24v04r16A.brd" schematic
@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
	.thumb						@; Use thumb instructions only
	
@; --- begin code memory
	.text						@;start the code section

@; includes only those definitions required for the this test
.equ PERIPH_BASE,(0x40000000)					@;#define PERIPH_BASE           (0x40000000)
.equ AHB1PERIPH_BASE,(PERIPH_BASE + 0x00020000)	@;#define AHB1PERIPH_BASE       (PERIPH_BASE + 0x00020000)
.equ GPIOA_BASE,(AHB1PERIPH_BASE + 0x0000)		@;#define GPIOA_BASE            (AHB1PERIPH_BASE + 0x0000)
.equ GPIOB_BASE,(AHB1PERIPH_BASE + 0x0400)		@;#define GPIOB_BASE            (AHB1PERIPH_BASE + 0x0400)
.equ GPIOC_BASE,(AHB1PERIPH_BASE + 0x0800)		@;#define GPIOC_BASE            (AHB1PERIPH_BASE + 0x0800)
.equ GPIOD_BASE,(AHB1PERIPH_BASE + 0x0C00)		@;#define GPIOD_BASE            (AHB1PERIPH_BASE + 0x0C00)
.equ IDR,0x10				@;__IO uint32_t IDR;      /*!< GPIO port input data register,         Address offset: 0x10      */
.equ ODR,0x14				@;__IO uint32_t ODR;      /*!< GPIO port output data register,        Address offset: 0x14      */
.equ BSRR,0x18				@;!!added to original.  This is a _word_, where the low 16-bits sets bits and the high 16-bits clear bits

.macro MOV_32 reg val		@;example of use: MOV_imm32 r0,0x12345678 !!note: no '#' on immediate value
	movw \reg,#(0xFFFF & (\val))
	movt \reg,#((0xFFFF0000 & (\val))>>16)
.endm
	
.macro WRITE_port GPIOx_BASE bit value	@;set 'bit' of port GPIOx to value {0,1}
	MOV_32 r2,(\GPIOx_BASE)
	.ifeq \value	@;must write to upper 16 bits of BSSR to clear the bit
		mov r1,#( 1<<(16+\bit))
	.else			@;write to lower 16 bits of BSSR to set the bit
		mov r1,#( 1<<(\bit))
	.endif
	str r1,[r2,#BSRR]	
.endm

.macro READ_port GPIOx_BASE bit	@;read 'bit' of port GPIOx, return bit value in bit0 of r0 and 'Z' flag set/clear if bit=0/1
	MOV_32 r2,(\GPIOx_BASE)
	ldr r0,[r2,#IDR]
	ands r0,#(1<<\bit)
	lsr r0,#\bit
.endm	

.macro DISABLE_anode GPIOx pin
	WRITE_port \GPIOx \pin 1
.endm

.macro SET_anode GPIOx pin
	WRITE_port \GPIOx \pin 0
.endm

	.global turn_off_Anodes
	.thumb_func
turn_off_Anodes:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOC_BASE 4 1
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOB_BASE 0 1
	WRITE_port GPIOB_BASE 5 1
	pop {r0-r3, lr}
	bx lr
	
	.global clock_Anods
	.thumb_func
clock_Anods:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 11 0
	WRITE_port GPIOC_BASE 11 1
	pop {r0-r3, lr}
	bx lr
	
	.global clock_Caths
	.thumb_func
clock_Caths:
	push {r0-r3, lr}
	WRITE_port GPIOD_BASE 2 0
	WRITE_port GPIOD_BASE 2 1
	pop {r0-r3, lr}
	bx lr

	.global enable_Caths
	.thumb_func
enable_Caths:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 1 0
	pop {r0-r3, lr}
	bx lr

	.global disable_Caths
	.thumb_func
disable_Caths:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 1 1
	pop {r0-r3, lr}
	bx lr

	.global enable_Anods
	.thumb_func
enable_Anods:
	push {r0-r3, lr}
	WRITE_port GPIOB_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global disable_Anods
	.thumb_func
disable_Anods:
	push {r0-r3, lr}
	WRITE_port GPIOB_BASE 4 1
	pop {r0-r3, lr}
	bx lr

	.global turn_off_Cathodes
	.thumb_func
turn_off_Cathodes:
	push {r0-r3, lr}
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOC_BASE 4 1
	WRITE_port GPIOB_BASE 0 1
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOB_BASE 0 1
	pop {r0-r3, lr}
	bx lr
	
	
	.global turn_off_LEDs
	.thumb_func
turn_off_LEDs:
	push {r0-r3, lr}
	bl disable_Caths
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOC_BASE 4 1
	WRITE_port GPIOB_BASE 0 1
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 1
	bl clock_Caths
	bl enable_Caths
	pop {r0-r3, lr}
	bx lr

	.global clear_digit
	.thumb_func
clear_digit:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 4 1
	pop {r0-r3, lr}
	bx lr
	
	.global display_0
	.thumb_func
display_0:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 1
	pop {r0-r3, lr}
	bx lr
	
	.global display_1
	.thumb_func
display_1:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 4 1
	pop {r0-r3, lr}
	bx lr
	
	.global display_2
	.thumb_func
display_2:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr
	
	.global display_3
	.thumb_func
display_3:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_4
	.thumb_func
display_4:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_5
	.thumb_func
display_5:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_6
	.thumb_func
display_6:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_7
	.thumb_func
display_7:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 1
	pop {r0-r3, lr}
	bx lr

	.global display_8
	.thumb_func
display_8:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_9
	.thumb_func
display_9:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 1
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_A
	.thumb_func
display_A:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_b
	.thumb_func
display_b:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr
	
	.global display_C
	.thumb_func
display_C:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 1
	pop {r0-r3, lr}
	bx lr

	.global display_d
	.thumb_func
display_d:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 1
	WRITE_port GPIOB_BASE 1 0
	WRITE_port GPIOA_BASE 1 0
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 1
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global display_E
	.thumb_func
display_E:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOB_BASE 5 0
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr
	
	.global display_F
	.thumb_func
display_F:
	push {r0-r3, lr}
	WRITE_port GPIOC_BASE 5 0
	WRITE_port GPIOB_BASE 1 1
	WRITE_port GPIOA_BASE 1 1
	WRITE_port GPIOB_BASE 5 1
	WRITE_port GPIOB_BASE 11 0
	WRITE_port GPIOC_BASE 2 0
	WRITE_port GPIOC_BASE 4 0
	pop {r0-r3, lr}
	bx lr

	.global colon_setup
	.thumb_func
colon_setup:
	push {r0-r3, lr}
	SET_anode GPIOC_BASE 5
	pop {r0-r3, lr}
	bx lr
	
	.global colon_undo
	.thumb_func
colon_undo:
	push {r0-r3, lr}
	DISABLE_anode GPIOC_BASE 5
	pop {r0-r3, lr}
	bx lr

	.global enable_rotEnc
	.thumb_func
enable_rotEnc:
	push {r0-r3, lr}
	SET_anode GPIOB_BASE 5
	pop {r0-r3, lr}
	bx lr
	
	.global disable_rotEnc
	.thumb_func
disable_rotEnc:
	push {r0-r3, lr}
	DISABLE_anode GPIOB_BASE 5
	pop {r0-r3, lr}
	bx lr
	
	.global dig_1_setup
	.thumb_func
dig_1_setup:
	push {r0-r3, lr}
	SET_anode GPIOC_BASE 2
	pop {r0-r3, lr}
	bx lr
	
	.global dig_1_undo
	.thumb_func
dig_1_undo:
	push {r0-r3, lr}
	DISABLE_anode GPIOC_BASE 2
	pop {r0-r3, lr}
	bx lr
	
	.global dig_2_setup
	.thumb_func
dig_2_setup:
	push {r0-r3, lr}
	SET_anode GPIOA_BASE 1
	pop {r0-r3, lr}
	bx lr

	.global dig_2_undo
	.thumb_func
dig_2_undo:
	push {r0-r3, lr}
	DISABLE_anode GPIOA_BASE 1
	pop {r0-r3, lr}
	bx lr
	
	.global dig_3_setup
	.thumb_func
dig_3_setup:
	push {r0-r3, lr}
	SET_anode GPIOC_BASE 4
	pop {r0-r3, lr}
	bx lr

	.global dig_3_undo
	.thumb_func
dig_3_undo:
	push {r0-r3, lr}
	DISABLE_anode GPIOC_BASE 4
	pop {r0-r3, lr}
	bx lr
	
	.global dig_4_setup
	.thumb_func
dig_4_setup:
	push {r0-r3, lr}
	SET_anode GPIOB_BASE 1
	pop {r0-r3, lr}
	bx lr
	
	.global dig_4_undo
	.thumb_func
dig_4_undo:
	push {r0-r3, lr}
	DISABLE_anode GPIOB_BASE 1
	pop {r0-r3, lr}
	bx lr

	.global init_GREEN
	.thumb_func
init_GREEN:
	push {r0-r3, lr}
	SET_anode GPIOB_BASE 0
	pop {r0-r3, lr}
	bx lr
	
	.global init_RED
	.thumb_func
init_RED:
	push {r0-r3, lr}
	SET_anode GPIOB_BASE 11
	pop {r0-r3, lr}
	bx lr
	
	.global undo_GREEN
	.thumb_func
undo_GREEN:
	push {r0-r3, lr}
	DISABLE_anode GPIOB_BASE 0
	pop {r0-r3, lr}
	bx lr
	
	.global undo_RED
	.thumb_func
undo_RED:
	push {r0-r3, lr}
	DISABLE_anode GPIOB_BASE 11 
	pop {r0-r3, lr}
	bx lr
	
	.global led_1_setup
	.thumb_func
led_1_setup:
	@; CA/PA1
	push {r0, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq unset_1
		WRITE_port GPIOA_BASE 1 0
		@;PORTBIT_write GPIOB_BASE 0 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	unset_1:
		WRITE_port GPIOA_BASE 1 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	
	.global led_2_setup
	.thumb_func
led_2_setup:
	@; CA/PC4
	push {r0, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq unset_2
		WRITE_port GPIOC_BASE 4 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	unset_2:
		WRITE_port GPIOC_BASE 4 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	
	.global led_3_setup
	.thumb_func
led_3_setup:
	@; CA/PB0
	push {r0, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq unset_3
		WRITE_port GPIOB_BASE 0 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	unset_3:
		WRITE_port GPIOB_BASE 0 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	
	.global led_4_setup
	.thumb_func
led_4_setup:
	@; CA/PC2
	push {r0, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq unset_4
		WRITE_port GPIOC_BASE 2 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	unset_4:
		WRITE_port GPIOC_BASE 2 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	
	.global led_5_setup
	.thumb_func
led_5_setup:
	@; CA/PC5
	push {r0, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq unset_5
		WRITE_port GPIOC_BASE 5 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	unset_5:
		WRITE_port GPIOC_BASE 5 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr

	.global led_6_setup
	.thumb_func
led_6_setup:
	@; CA/PB1
	push {r0, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq unset_6
		WRITE_port GPIOB_BASE 1 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
	unset_6:
		WRITE_port GPIOB_BASE 1 1
		bl clock_Caths
		bl enable_Caths
		pop  {r0, lr}
		bx lr
		
		
	.global read_1_2
	.thumb_func
read_1_2:
	push {r1-r3, lr}
	READ_port GPIOB_BASE 5
	pop {r1-r3, lr}	
	bx lr

	.global read_3_4
	.thumb_func
read_3_4:
	push {r1-r3, lr}	
	READ_port GPIOB_BASE 11
	pop {r1-r3, lr}
	
	bx lr

	.global read_5_6
	.thumb_func
read_5_6:
	push {r1-r3, lr}	
	READ_port GPIOB_BASE 0
	pop {r1-r3, lr}	
	bx lr
	
	.global read_7_8
	.thumb_func
read_7_8:
	push {r1-r3, lr}
	READ_port GPIOB_BASE 1
	pop {r1-r3, lr}
	bx lr

	.global read_9_10
	.thumb_func
read_9_10:
	push {r1-r3, lr}
	READ_port GPIOC_BASE 4
	pop {r1-r3, lr}
	bx lr
	
	.global read_11_12
	.thumb_func
read_11_12:
	push {r1-r3, lr}
	READ_port GPIOC_BASE 5
	pop {r1-r3, lr}
	bx lr

	.global read_13
	.thumb_func
read_13:
	push {r1-r3, lr}
	READ_port GPIOA_BASE 1
	pop {r1-r3, lr}
	bx lr
	
	.global setup_1_2
	.thumb_func
setup_1_2:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_1_2
		WRITE_port GPIOB_BASE 5 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_1_2:
		WRITE_port GPIOB_BASE 5 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
		
	.global setup_3_4
	.thumb_func
setup_3_4:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_3_4
		WRITE_port GPIOB_BASE 11 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_3_4:
		WRITE_port GPIOB_BASE 11 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
	
	.global setup_5_6
	.thumb_func
setup_5_6:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_5_6
		WRITE_port GPIOB_BASE 0 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_5_6:
		WRITE_port GPIOB_BASE 0 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
	
	.global setup_7_8
	.thumb_func
setup_7_8:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_7_8
		WRITE_port GPIOB_BASE 1 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_7_8:
		WRITE_port GPIOB_BASE 1 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
	
	.global setup_9_10
	.thumb_func
setup_9_10:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_9_10
		WRITE_port GPIOC_BASE 4 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_9_10:
		WRITE_port GPIOC_BASE 4 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
	
	.global setup_11_12
	.thumb_func
setup_11_12:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_11_12
		WRITE_port GPIOC_BASE 5 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_11_12:
		WRITE_port GPIOC_BASE 5 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
	
	.global setup_13
	.thumb_func
setup_13:
	push {r0-r3, lr}
	bl  disable_Caths
	
	cmp r0, #1
	beq disable_13
		WRITE_port GPIOA_BASE 1 0
		bl clock_Caths
		bl enable_Caths
		pop  {r0-r3, lr}
		bx lr
	disable_13:
		WRITE_port GPIOA_BASE 1 1
		bl clock_Caths
		bl enable_Caths
		pop {r0-r3, lr}
		bx lr
	
	@; true if any even buttons have been pressed
	.global read_PC8
	.thumb_func
read_PC8:
	push {r1-r3, lr}
	READ_port GPIOC_BASE 8
	pop {r1-r3, lr}
	bx lr
	
	@; true if any odd buttons have been pressed
	.global read_PA15
	.thumb_func
read_PA15:
	push {r1-r3, lr}
	READ_port GPIOA_BASE 15
	pop {r1-r3, lr}
	bx lr
	