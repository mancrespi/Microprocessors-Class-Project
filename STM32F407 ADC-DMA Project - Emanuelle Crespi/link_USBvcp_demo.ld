/* linkBlinkySTM32F4_01.ld wmh 2013-02-03 : linker script adapted to STM32F4 */
/* LINKSimpleLPC1768_01.ld wmh 2011-11-10 linker script for NXP LPC1768 */
/* adapted from http://embeddedfreak.wordpress.com/2009/08/09/cortex-m3-blinky-in-assembly/  */
/* Simple linker script for Cortex-M3 */

/*
 * Define the supported output formats - elf32-littlearm is the
 *  default
 */
OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")


OUTPUT_ARCH(arm)				/* Define the target architecture */
/* ENTRY(Reset_Handler) */ 			/* 'Reset_Handler()' executable is in hw10_09STM32DiscoveryVCP_06/main_with_function_structs12.c at 0x080100F9; */
SECTIONS 						/* Define the memory layout for the board */
{
/*
	.cs3.interrupt_vector 0x0800000 :
	{
		KEEP(*(.cs3.interrupt_vector));			/* collect .cs3.interrupt_vector section here 	
	}
*/	
	.flash 0x08000000 :			/* to agree what STLINK shows us for the STM32F4 */
	{
		KEEP(*(.cs3.interrupt_vector));			/* collect .cs3.interrupt_vector section here */
		/*. = . + (0x400 - . );*/	 			/* skip over the rest of memory up to 0x08000400 -- see http://www.math.utah.edu/docs/info/ld_3.html  */
		*(.text .text.*);						/* memory for application is going to start here */
		*(.rodata .rodata.*);					/* Collect the const variables here */				 
		__sidata = .;						/* end marker */
	}

 /* set areas for initialized and uninitialized data */
 	.data_at_ram 0x20000000: AT (LOADADDR(.flash) + SIZEOF(.flash))
	{
		__sdata = .;
		*(.data .data.*);						
		__edata = .;							
		__sbss = .;
			*(.bss .bss.*);						
		__ebss = .;
	}
 
 /* Set __cs3_stack to point the end of RAM memory */
	__cs3_stack = 0x20000000 + (64 * 1024);		/* now limited to 1st 1/2 of RAM */	
	
/* definitions below replace 'Default_Handler' assignment in vector table in SimpleStartSTM32F4_02.asm at link-time */
	OTG_FS_WKUP_IRQHandler = 0x08010105; 		/* USB service routine in upper memory */	
	OTG_FS_IRQHandler = 0x080100f1;				/* USB service routine in upper memory */
}

