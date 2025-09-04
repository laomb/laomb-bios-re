# BIOS Provided IVT on LAOMB target device

| IVT Entry | Vector (hex) | Segment\:Offset | Short description                                                                        |
| --------: | :----------- | --------------- | ---------------------------------------------------------------------------------------- |
|        00 | 00h          | F000\:EF6F      | **CPU**: Divide error                                                                    |
|        01 | 01h          | F000\:EF6F      | **CPU**: Single-step (trap)                                                              |
|        02 | 02h          | F000\:E2C3      | **CPU**: NMI handler                                                                     |
|        03 | 03h          | F000\:EF6F      | **CPU**: Breakpoint (INT3)                                                               |
|        04 | 04h          | F000\:EF6F      | **CPU**: Overflow (INTO)                                                                 |
|        05 | 05h          | C000:5293       | **BIOS/Video**: Print-Screen (historical) / BOUND on 286+; here hooked by VGA option ROM |
|        06 | 06h          | F000\:E14C      | **CPU**: Invalid opcode                                                                  |
|        07 | 07h          | F000\:EF6F      | **CPU**: Device not available (later CPUs) / reserved on 8086                            |
|        08 | 08h          | F000\:FEA5      | **IRQ0**: PIT timer tick / BIOS time services                                            |
|        09 | 09h          | F000\:E987      | **IRQ1**: Keyboard hardware interrupt                                                    |
|        10 | 0Ah          | F000\:EF6F      | **IRQ2** (cascade) – platform dependent                                                  |
|        11 | 0Bh          | F000\:EF6F      | **IRQ3**: usually COM2/4 (platform dependent)                                            |
|        12 | 0Ch          | F000\:EF6F      | **IRQ4**: usually COM1/3                                                                 |
|        13 | 0Dh          | F000\:EF6F      | **IRQ5**: LPT2 / sound / free (depends)                                                  |
|        14 | 0Eh          | F000\:EF57      | **IRQ6**: Floppy disk controller                                                         |
|        15 | 0Fh          | F000\:EF6F      | **IRQ7**: LPT1 / spurious                                                                |
|        16 | 10h          | C000:34B4       | **BIOS**: Video services (INT 10h) – hooked by VGA ROM                                   |
|        17 | 11h          | F000\:F84D      | **BIOS**: Equipment list                                                                 |
|        18 | 12h          | F000\:F841      | **BIOS**: Conventional memory size                                                       |
|        19 | 13h          | F000:9BE4       | **BIOS**: Disk services (INT 13h)                                                        |
|        20 | 14h          | F000\:E739      | **BIOS**: Serial port services (INT 14h)                                                 |
|        21 | 15h          | F000\:F859      | **BIOS**: System services (A20, wait, E820 via AX=E820h, etc.)                           |
|        22 | 16h          | F000\:E82E      | **BIOS**: Keyboard services (INT 16h)                                                    |
|        23 | 17h          | F000\:EFD2      | **BIOS**: Printer services (INT 17h)                                                     |
|        24 | 18h          | F000\:E7A4      | **BIOS**: ROM BASIC / boot fail vector                                                   |
|        25 | 19h          | F000\:E6F2      | **BIOS**: Bootstrap loader (INT 19h)                                                     |
|        26 | 1Ah          | F000\:FE6E      | **BIOS**: RTC/CMOS/time-of-day                                                           |
|        27 | 1Bh          | F000\:FF53      | **DOS/BIOS hook**: Ctrl-Break (usually DOS uses)                                         |
|        28 | 1Ch          | F000\:FF53      | **BIOS hook**: User timer tick (post-IRQ0)                                               |
|        29 | 1Dh          | F000\:FF53      | **BIOS data**: Video parameter table pointer                                             |
|        30 | 1Eh          | C000:2157       | **BIOS data**: Diskette parameter table pointer                                          |
|        31 | 1Fh          | F000\:EFC7      | **BIOS data**: Graphics char gen / CGA table pointer                                     |
|        32 | 20h          | C000:6961       | **DOS API** (INT 20h) – not BIOS; here points into VGA ROM (stub/hook)                   |
|        33 | 21h          | F000\:EF6F      | **DOS API** (INT 21h) – not BIOS; ROM stub/placeholder                                   |
|        34 | 22h          | F000\:EF6F      | **DOS/BIOS**: Device control/break (rare); typically DOS – stub here                     |
|        35 | 23h          | F000\:EF6F      | **DOS**: Ctrl-C/termination vector – stub                                                |
|        36 | 24h          | F000\:EF6F      | **DOS**: Critical error handler – stub                                                   |
|        37 | 25h          | F000\:EF6F      | **DOS**: Absolute disk read – stub                                                       |
|        38 | 26h          | F000\:EF6F      | **DOS**: Absolute disk write – stub                                                      |
|        39 | 27h          | F000\:EF6F      | **DOS**: Terminate & stay resident – stub                                                |
|        40 | 28h          | F000\:EF6F      | **DOS**: Idle (Int 28h) – stub                                                           |
|        41 | 29h          | F000\:EF6F      | **DOS**: Fast console output – stub                                                      |
|        42 | 2Ah          | F000\:EF6F      | **DOS**: Date/time – stub                                                                |
|        43 | 2Bh          | F000\:EF6F      | **DOS**: Parse filename – stub                                                           |
|        44 | 2Ch          | F000\:EF6F      | **DOS**: Get time – stub                                                                 |
|        45 | 2Dh          | F000\:EF6F      | **DOS**: Get date – stub                                                                 |
|        46 | 2Eh          | F000\:EF6F      | **DOS**: Network redirector – stub                                                       |
|        47 | 2Fh          | F000\:EF6F      | **DOS**: Multiplex (INT 2Fh) – stub                                                      |
|        48 | 30h          | F000\:EF6F      | **DOS**: Version – stub                                                                  |
|        49 | 31h          | F000\:EF6F      | **DOS**: TSR services – stub                                                             |
|        50 | 32h          | F000\:EF6F      | **BIOS/DOS**: DPB pointer (varies) – stub                                                |
|        51 | 33h          | F000\:EF6F      | **Mouse driver** (INT 33h) – not BIOS; stub unless driver loaded                         |
|        52 | 34h          | F000\:EF6F      | **DOS**: Internal – stub                                                                 |
|        53 | 35h          | F000\:EF6F      | **DOS**: Get/set vector – stub                                                           |
|        54 | 36h          | F000\:EF6F      | **DOS**: Disk reset – stub                                                               |
|        55 | 37h          | F000\:EF6F      | **DOS**: Switch character device – stub                                                  |
|        56 | 38h          | F000\:EF6F      | **DOS**: Country info – stub                                                             |
|        57 | 39h          | F000\:EF6F      | **DOS**: Create – stub                                                                   |
|        58 | 3Ah          | F000\:EF6F      | **DOS**: Delete – stub                                                                   |
|        59 | 3Bh          | F000\:EF6F      | **DOS**: Change directory – stub                                                         |
|        60 | 3Ch          | F000\:EF6F      | **DOS**: Create file – stub                                                              |
|        61 | 3Dh          | F000\:EF6F      | **DOS**: Open file – stub                                                                |
|        62 | 3Eh          | F000\:EF6F      | **DOS**: Close file – stub                                                               |
|        63 | 3Fh          | F000\:EF6F      | **DOS**: Read file – stub                                                                |
|        64 | 40h          | F000\:EF6F      | **DOS**: Write file – stub                                                               |
|        65 | 41h          | F000\:EF6F      | **DOS**: Delete file – stub                                                              |
|        66 | 42h          | F000\:EF6F      | **DOS**: Lseek – stub                                                                    |
|        67 | 43h          | F000\:EF6F      | **DOS**: File attributes – stub                                                          |
|        68 | 44h          | F000\:EF6F      | **DOS**: IOCTL – stub                                                                    |
|        69 | 45h          | F000\:EF6F      | **DOS**: Duplicate handle – stub                                                         |
|        70 | 46h          | F000\:EF6F      | **DOS**: Force dup – stub                                                                |
|        71 | 47h          | F000\:EC59      | **DOS**: Get current dir – stub                                                          |
|        72 | 48h          | F000\:EFD5      | **DOS**: Allocate memory – stub                                                          |
|        73 | 49h          | F000\:F065      | **DOS**: Free memory – stub                                                              |
|        74 | 4Ah          | C000:6561       | **DOS**: Resize block – here hooked by **VGA ROM** (unusual; likely shared stub)         |
|        75 | 4Bh          | F000\:EF6F      | **DOS**: Exec – stub                                                                     |
|        76 | 4Ch          | F000\:EF6F      | **DOS**: Terminate with return code – stub                                               |
|        77 | 4Dh          | F000\:EF6F      | **DOS**: Get return code – stub                                                          |
|        78 | 4Eh          | F000\:EF6F      | **DOS**: Find first – stub                                                               |
|        79 | 4Fh          | F000\:EF6F      | **DOS**: Find next – stub                                                                |
|        80 | 50h          | F000\:EF6F      | **DOS**: Set PSP – stub                                                                  |
|        81 | 51h          | F000\:EF6F      | **DOS**: Get PSP – stub                                                                  |
|        82 | 52h          | F000\:EF6F      | **DOS**: SysVars pointer – stub                                                          |
|        83 | 53h          | F000\:EF6F      | **DOS**: Internal – stub                                                                 |
|        84 | 54h          | F000\:EF6F      | **DOS**: Get verify flag – stub                                                          |
|        85 | 55h          | F000\:EF6F      | **DOS**: Set verify flag – stub                                                          |
|        86 | 56h          | F000\:EF6F      | **DOS**: Rename – stub                                                                   |
|        87 | 57h          | F000\:EF6F      | **DOS**: File date/time – stub                                                           |
|        88 | 58h          | F000\:EF6F      | **DOS**: Alloc strategy – stub                                                           |
|        89 | 59h          | F000\:EF6F      | **DOS**: Get/Set memory strategy – stub                                                  |
|        90 | 5Ah          | F000\:EF6F      | **DOS**: Create temp file – stub                                                         |
|        91 | 5Bh          | F000\:EF6F      | **DOS**: Create new file – stub                                                          |
|        92 | 5Ch          | F000\:EF6F      | **DOS**: Locking – stub                                                                  |
|        93 | 5Dh          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|        94 | 5Eh          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|        95 | 5Fh          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|        96 | 60h          | F000\:EF6F      | **DOS**: Internal – stub                                                                 |
|        97 | 61h          | F000\:EF6F      | **DOS**: Internal – stub                                                                 |
|        98 | 62h          | F000\:EF6F      | **DOS**: European DOS – stub                                                             |
|        99 | 63h          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|       100 | 64h          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|       101 | 65h          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|       102 | 66h          | F000\:EF6F      | **DOS**: Network – stub                                                                  |
|       103 | 67h          | F000\:EF6F      | **DOS**: XMS/EMS stubs (varies) – stub                                                   |
|       104 | 68h          | F000\:EF6F      | **DOS**: Device drivers – stub                                                           |
|       105 | 69h          | F000\:EF6F      | **DOS**: Device drivers – stub                                                           |
|       106 | 6Ah          | F000\:EF6F      | **DOS**: Device drivers – stub                                                           |
|       107 | 6Bh          | F000\:EF6F      | **DOS**: Device drivers – stub                                                           |
|       108 | 6Ch          | F000\:EF6F      | **DOS**: Extended open – stub                                                            |
|       109 | 6Dh          | F000\:EF6F      | **DOS**: Country info – stub                                                             |
|       110 | 6Eh          | F000\:EF6F      | **DOS**: Multi-tasker/mouse – stub                                                       |
|       111 | 6Fh          | F000\:EF6F      | **DOS**: Reserved – stub                                                                 |
|       112 | 70h          | F000\:EF6F      | **IRQ8**: RTC – typically BIOS handles here (AT)                                         |
|       113 | 71h          | F000\:EF6F      | **IRQ9**: Redirected IRQ2 (AT)                                                           |
|       114 | 72h          | F000\:EF6F      | **IRQ10**: Device-specific (AT)                                                          |
|       115 | 73h          | F000\:EF6F      | **IRQ11**: Device-specific (AT)                                                          |
|       116 | 74h          | C000:34B4       | **IRQ12**: PS/2 mouse (often) – here via VGA ROM hook                                    |
|       117 | 75h          | F000\:EF6F      | **IRQ13**: FPU error (AT)                                                                |
|       118 | 76h          | F000\:EF6F      | **IRQ14**: Primary IDE                                                                   |
|       119 | 77h          | F000\:BC23      | **IRQ15**: Secondary IDE / device-specific                                               |
|       120 | 78h          | F000\:ECF3      | **BIOS/Platform**: typically unused; stub                                                |
|       121 | 79h          | F000\:EF6F      | **Reserved/unused** (stub)                                                               |
|       122 | 7Ah          | F000\:EF6F      | **Reserved/unused** (stub)                                                               |
|       123 | 7Bh          | F000\:BD14      | **Reserved/unused** (stub)                                                               |
|       124 | 7Ch          | F000\:F0FC      | **Reserved/unused** (stub)                                                               |
|       125 | 7Dh          | F000\:ED00      | **Reserved/unused** (stub)                                                               |
|       126 | 7Eh          | F000\:ED24      | **Reserved/unused** (stub)                                                               |
