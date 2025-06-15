
#### _rv_entry_point
- If we have already posted (keyboard conotroller)
    - If we are not in protected mode (smsw ax) check for PE bit
        - Call [pusle_northbridge_if_cmos_flag_clear](#pusle_northbridge_if_cmos_flag_clear)
        - 
    - otherwise, trigger a cpu reset via the keyboard controller

#### pusle_northbridge_if_cmos_flag_clear
- If the CMOS flag (`cmos[0x8F]`) is zero
    - If the soft reset flag is set to `1234h`
        - Write `0xAA` into `cmos[0x8F]`
    - Otherwise don't write anything to the cmos.

    - Select PCI device 0,7,0
    - Wait one I/O tick
    - Read value at offset 0x47
    - Set the first bit of the read value
    - Write the value back
    - Loop 800 I/O ticks
    - Clear the first bit of the read value
    - Write the value back
- Otherwise, return preemptively
