# PCI vendor-specific registers (reverse-engineering notes)

Scope: chipset/bridge **vendor-specific** config bytes touched by LAOMB target devices Award BIOS. Classic PCI config space (256 B), config mech #1.

## Access convention
* Mechanism: **CF8h/CFC h** (Config #1).
* Packing used by helpers:
  `packed = (dev << 11) | (fn << 8) | offset` (bus fixed to 0).
* Helpers:

  ```c
  unsigned char __usercall pci_cfg_read8@<al>(unsigned short packed@<cx>); // _F000:F71D
  void __usercall pci_cfg_write8(unsigned short packed@<cx>, unsigned char value@<al>); // _F000:F738
  ```

---

## Host Bridge — B0\:D0\:F0 — **Config offset 0x63** (8-bit)

**Where used:** `_F000:771E` (before shadow copy into E000:), `_F000:7637` (after shadow copy into E000:)
**Observed RMW:** `AL = read(0x63); AL &= 0x3F; AL |= 0xC0; write(0x63, AL)`, `AL = read(0x63); AL &= 0x3F; AL |= 0x80; write(0x63, AL)`

**Bit layout:**

* **bit 7**: **always set** (BIOS keeps it = 1). Likely protection/guard.
* **bit 6**: **shadow write enable** — **0 = RO**, **1 = RW** (gates writes to the shadowed region).
* **bits 5:0**: unknown/reserved — BIOS preserves.

**Purpose (empirical):** enable writes to the **E0000h–EFFFFh** shadow window just before copying 64 KiB from `5000:0000` -> `E000:0000`, then jump to `E000:80AB`.
**Safety:** only manipulate bits 7:6 as shown; preserve `[5:0]`. Expect a later re-lock elsewhere.

---

## New entry format

```
### <Component> — B<bus>:D<dev>:F<fn> — offset 0x<off> (width)
Where used: <func/addr>
RMW sequence: <brief mask/set pattern>
Bit Layout: <known bits with meanings>; unknown/reserved noted
Purpose: <one line, empirical or confirmed>
Safety: <what must be preserved / ordering constraints>
```

---
