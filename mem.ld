/*
 * This file describes the layout of the final binary in memory.
 * Remember, some sections in the ELF will be kept (like debugging
 * information), but they won't have the allocatable flag or an address,
 * so they won't take up space on-chip.
 */

/* We start off in handle_reset, in src/startup.s  */
ENTRY(handle_reset)

/*
 * This will be put in entry 0 of the interrupt vector, and the CPU
 * will initialize the stack point with this. It's set to the end of ram.
 */
stack_end = 0x20018000;

/* The physical memory we can work with. */
MEMORY {
       RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 96K
       FLASH (rx)      : ORIGIN = 0x8000000, LENGTH = 512K
}

SECTIONS {
	/* The interrupt vector has to be the first thing in flash. */
	.isr_vec : {
		 . = ALIGN(4);
		 KEEP(*(.isr_vec))
		 . = ALIGN(4);
	} >FLASH

	/* Code can go anywhere after the interrupt vector. */
	.text : {
		. = ALIGN(4);
		*(.text)
		*(.text*)
		*(.eh_frame)

		KEEP (*(.init))
		KEEP (*(.fini))

		. = ALIGN(4);
	} >FLASH

        .init_array : {
		__init_array_start = .;
		KEEP (*(.init_array*))
		__init_array_end = .;
        } >FLASH

	/* This data can stay in flash (like const char* etc) */
	.rodata : {
		. = ALIGN(4);
		*(.rodata)
		*(.rodata*)
		. = ALIGN(4);
	} >FLASH

	/*
	 * Any global variables that need to be initialized.
	 * The default values are stored in flash, and then to
	 * make them writable src/startup.s copies them into ram.
	 */
	 data_lma_start = LOADADDR(.data);
	.data : {
		. = ALIGN(4);
		data_vma_start = .;
		*(.data)
		*(.data*)

		. = ALIGN(4);
		data_vma_end = .;
	} >RAM AT> FLASH

	/*
	 * Zero-initialized data doesn't take up any space in ram,
	 * but src/startup.s needs to zero it out prior to main().
	 */
	.bss : {
		. = ALIGN(4);
		bss_start = .;
		*(.bss)
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		bss_end = .;
	}

	.ARM.extab : {
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} >FLASH

	.ARM : {
		__exidx_start = .;
		*(.ARM.exidx*)
		__exidx_end = .;
	} >FLASH

	/DISCARD/ : {
		libc.a ( * )
		libm.a ( * )
		libgcc.a ( * )
	}
}
