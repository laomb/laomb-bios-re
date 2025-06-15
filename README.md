# Laomb BIOS RE

Tools and documentation for reverse engineering legacy x86 AWARD BIOS used in LAOMB target machine.

- `tools/BDUMP.BAS`: dumps 64KB BIOS ROM to `BIOS.BIN`
- `tools/parse.py`: parses `BIOSINF.TXT` to `bios_summary.ini`
- `markup.md`: notes on BIOS reverse engineering
- `out/`: contains raw and parsed BIOS dumps as well as the ida64 database.

Focus: reset vector analysis, IVT mapping, and norhtbridge / southbridge interactions.
