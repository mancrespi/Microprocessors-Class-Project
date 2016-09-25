@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
	.thumb						@; Use thumb instructions only
	
	.equ VCP_init, 0x08010001
@; --- begin code memory
	.text						@;start the code section

.macro MOV_32 reg val		@;example of use: MOV_imm32 r0,0x12345678 !!note: no '#' on immediate value
	movw \reg,#(0xFFFF & (\val))
	movt \reg,#((0xFFFF0000 & (\val))>>16)
.endm

	.global pVCP_init
	.thumb_func
pVCP_init:
	push {r1-r3, r7, lr}
	MOV_32 r3, VCP_init
	blx r3
	pop {r1-r3, r7, lr}
	bx lr
