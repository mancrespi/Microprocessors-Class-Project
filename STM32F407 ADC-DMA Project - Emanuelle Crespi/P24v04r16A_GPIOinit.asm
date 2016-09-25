@;P24v04r16A_GPIOinit.asm 2016-04-26 : GPIO port pin initializations (only) for outputs to latches (cathode, anode) and inputs from switches,
@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
	.thumb						@; Use thumb instructions only
	
@; --- begin code memory
	.text						@;start the code section

@;absolute addresses for system configuration registers being used
.equ PERIPH_BASE,(0x40000000)					@;#define PERIPH_BASE           (0x40000000)
.equ APB1PERIPH_BASE,PERIPH_BASE				@;#define APB1PERIPH_BASE       PERIPH_BASE
.equ AHB1PERIPH_BASE,(PERIPH_BASE + 0x00020000)	@;#define AHB1PERIPH_BASE       (PERIPH_BASE + 0x000?0000)
.equ RCC_BASE,(AHB1PERIPH_BASE + 0x3800)		@;#define RCC_BASE              (AHB1PERIPH_BASE + 0x?800)
.equ RCC_AHB1ENR,(RCC_BASE+0x30)

@;absolute addresses for peripherals being used (GPIO)
.equ GPIOA_BASE,(AHB1PERIPH_BASE + 0x0000)		@;address of GPIOA register group
.equ GPIOB_BASE,(AHB1PERIPH_BASE + 0x0400)		@;address of GPIOA register group
.equ GPIOC_BASE,(AHB1PERIPH_BASE + 0x0800)		@;address of GPIOA register group
.equ GPIOD_BASE,(AHB1PERIPH_BASE + 0x0C00)		@;address of GPIOA register group

@;offsets for GPIO configuration registers
.equ MODER,0x00				@;GPIO port mode register,              
.equ OTYPER,0x04			@;GPIO port output type register,        
.equ OSPEEDR,0x08			@;GPIO port output speed register,      
.equ PUPDR,0x0C				@;GPIO port pull-up/pull-down register,  
.equ IDR,0x10				@;GPIO port input data register,         
.equ ODR,0x14				@;GPIO port output data register,        
.equ BSRR,0x18				@;!!important -- this is a _word_ in which the low 16-bits set output bits and the high 16-bits reset output bit
.equ BSRRL,0x18				@;GPIO port bit set/reset low register, 
.equ BSRRH,0x1A				@;GPIO port bit set/reset high register, 
.equ LCKR,0x1C				@;GPIO port configuration lock register, 
.equ AFR1,0x20				@;GPIO alternate function registers,     
.equ AFR2,0x24				@;GPIO alternate function registers,     

@;--- useful general macros

.macro MOV_imm32 reg val		@;example of use: MOV_imm32 r0,0x12345678 !!note: no '#' on immediate value
	movw \reg,#(0xFFFF & (\val))
	movt \reg,#((0xFFFF0000 & (\val))>>16)
.endm

.macro SET_bit addr bit @;logical OR position 'bit' at 'addr' with 1 
	MOV_imm32 r2,(\addr)
	ldr r1,[r2]
	ORR r1,#(1<<\bit)
	str r1,[r2]	
.endm

.macro EDIT_bits reg, mask, patt, pattpos @;insert a bit-pattern into a register in at the requested pattern position
@; this may fail if the mask will overlap a byte-boundary in the register after shifting
	bic \reg,#((\mask)<<(\pattpos))	@;clear the bits at the destination
	orr \reg,#((\patt)<<(\pattpos)) @;insert the new pattern
.endm

	@;persistent definitions
	.equ MODER,0x00		@;GPIO port mode register offset              
	.equ OTYPER,0x04	@;GPIO port output type register offset        
	.equ OSPEEDR,0x08	@;GPIO port output speed register offset      
	.equ PUPDR,0x0C		@;GPIO port pull-up/pull-down register offset

@;--- specialized macros	

.macro 	cfgGPIO_pushpull_out GPIOx_BASE, pin @;configure GPIOx pin with push-pull output, 50MHz fast speed (RM0090 Table 27); 'x' is A-D, pin is 0-15 
	@;local (to this macro) constant definitions
	.equ MODERval,1		@; output
	.equ OTYPERval,0	@; push-pull                   
	.equ OSPEEDRval,2	@; 50mHz fast                   
	.equ PUPDRval,0		@; pu/pd 

	@;select port
	MOV_imm32 r2,(\GPIOx_BASE)	

	@;install MODERval
	ldr r1,[r2,#(MODER)]
	EDIT_bits r1,3,MODERval,(2*\pin)
	str r1,[r2,#(MODER)]

	@;install OTYPERval	
	ldr r1,[r2,#(OTYPER)]
	EDIT_bits r1,1,OTYPERval,(\pin)
	str r1,[r2,#(OTYPER)]

	@;install OSPEEDRval	
	ldr r1,[r2,#(OSPEEDR)]
	EDIT_bits r1,3,OSPEEDRval,(2*\pin)
	str r1,[r2,#(OSPEEDR)]

	@;install PUPDIRval
	ldr r1,[r2,#(PUPDR)]
	EDIT_bits r1,3,PUPDRval,(2*\pin)
	str r1,[r2,#(PUPDR)]

.endm
	
.macro 	cfgGPIO_pullup_in GPIOx_BASE, pin @;configure GPIOx pin with pullup(RM0090 Table 27); 'x' is A-D, pin is 0-15 
	@;local (to this macro) constant definitions
	.equ MODERval,0		@; input
	.equ OTYPERval,0	@; push-pull                   
	.equ OSPEEDRval,2	@; 50mHz fast                  
	.equ PUPDRval,1		@; pullup
	
	@;select port
	MOV_imm32 r2,(\GPIOx_BASE)	

	@;install MODERval	
	ldr r1,[r2,#(MODER)]
	EDIT_bits r1,3,MODERval,(2*\pin)
	str r1,[r2,#(MODER)]

	@;install OTYPERval
	ldr r1,[r2,#(OTYPER)]
	EDIT_bits r1,1,OTYPERval,(\pin)
	str r1,[r2,#(OTYPER)]

	@;install OSPEEDRval
	ldr r1,[r2,#(OSPEEDR)]
	EDIT_bits r1,3,OSPEEDRval,(2*\pin)
	str r1,[r2,#(OSPEEDR)]

	@;install PUPDIRval	
	ldr r1,[r2,#(PUPDR)]
	EDIT_bits r1,3,PUPDRval,(2*\pin)
	str r1,[r2,#(PUPDR)]

.endm
	
@--- P24 GPIO initialization functions			

	.global ST_P24DISPLAY_init		@;void ST_P24DISPLAY_init(void);	//initialize ST32F4 pins controlling P24 display pins
	.thumb_func
ST_P24DISPLAY_init:	@;using chip-pin/board-signal identifications from 'P24v04r16Apins.xls'
	@;device clock enables -- enable GPIO peripherals being used
	SET_bit RCC_AHB1ENR,0					@;enable clock for GPIOA
	SET_bit RCC_AHB1ENR,1					@;      ""         GPIOB
	SET_bit RCC_AHB1ENR,2					@;      ""         GPIOC
	SET_bit RCC_AHB1ENR,3					@;      ""         GPIOD
	
	cfgGPIO_pushpull_out  GPIOC_BASE,11	@;	88_PC11	PC11/AN_CLK
	cfgGPIO_pushpull_out  GPIOB_BASE,4	@;	75_PB4	PB4/AN_EN
	cfgGPIO_pushpull_out  GPIOD_BASE,2	@;	84_PD2	PD2/CA_CLK
	cfgGPIO_pushpull_out  GPIOC_BASE,1	@;	07_PC1	PC1/CA_EN
	cfgGPIO_pushpull_out  GPIOC_BASE,5	@;	19_PC5	PC5/CA_A/LED5-COLON
	cfgGPIO_pushpull_out  GPIOB_BASE,1	@;	21_PB1	PB1/CA_B/LED6-DIGIT4
	cfgGPIO_pushpull_out  GPIOA_BASE,1	@;	11_PA1	PA1/CA_C/LED1-DIGIT2
	cfgGPIO_pushpull_out  GPIOB_BASE,5	@;	76_PB5	PB5/CA_D/ROT_ENC-COM
	cfgGPIO_pushpull_out  GPIOB_BASE,11	@;	35_PB11	PB11/CA_E-AN_R
	cfgGPIO_pushpull_out  GPIOC_BASE,2	@;	10_PC2	PC2/CA_F/LED4-DIGIT1
	cfgGPIO_pushpull_out  GPIOC_BASE,4	@;	20_PC4	PC4/CA_G/LED2-DIGIT3
	cfgGPIO_pushpull_out  GPIOB_BASE,0	@;	22_PB0	PB0/CA_DP/LED3-AN_G
	
	bx lr

	.global ST_P24SWITCH_init		@; void ST_P24SWITCH_init(void); //initialize ST32F4 pins controlling switches
	.thumb_func
ST_P24SWITCH_init:							@;using identifications extracted from 'P24v04r16pins.xls'
	@;enable port clocks (ok to be duplicative)
	SET_bit RCC_AHB1ENR,0					@;enable clock for GPIOA
	SET_bit RCC_AHB1ENR,2					@;      ""         GPIOC
	@;configure port bit direction, speed, etc

	cfgGPIO_pullup_in GPIOA_BASE,15
	cfgGPIO_pullup_in GPIOC_BASE,8
	
	bx lr

