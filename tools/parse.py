import re
import os
from configparser import ConfigParser

SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
PARENT_DIR = os.path.dirname(SCRIPT_DIR)
OUT_DIR    = os.path.join(PARENT_DIR, 'out')

TEXT_DUMP = os.path.join(OUT_DIR, 'BIOSINF.TXT')
BIN_IMAGE = os.path.join(OUT_DIR, 'BIOS.BIN')
INI_OUT   = os.path.join(OUT_DIR, 'bios_summary.ini')

def parse_biosinf(txt_path):
    with open(txt_path, 'r') as f:
        lines = [L.strip() for L in f]

    reset_bytes = []
    for i, L in enumerate(lines):
        if L.startswith("Bytes at reset vector"):
            reset_bytes = [int(b, 16) for b in lines[i+1].split()]
            break

    seg = off = None
    for L in lines:
        m = re.match(r'Reset Vector:\s*([0-9A-F]+):([0-9A-F]+)', L)
        if m:
            seg = int(m.group(1), 16)
            off = int(m.group(2), 16)
            break
    if seg is None:
        raise ValueError("Couldn't find reset vector line")

    ivt = {}
    in_ivt = False
    for L in lines:
        if L.startswith("IVT"):
            in_ivt = True
            continue
        if in_ivt and L:
            parts = L.split()
            num = int(parts[0], 16)
            s, o = parts[1].split(':')
            ivt[num] = (int(s, 16), int(o, 16))
    return reset_bytes, (seg, off), ivt

class BIOSImage:
    def __init__(self, bin_path):
        if not os.path.exists(bin_path):
            raise FileNotFoundError(bin_path)
        with open(bin_path, 'rb') as f:
            self.data = f.read()
        if len(self.data) != 0x10000:
            print(f"Warning: expected 65536 bytes, got {len(self.data)}")

    @staticmethod
    def phys_addr(seg, off):
        return (seg << 4) + off

def write_ini(out_path, summary):
    cfg = ConfigParser()
    cfg['General'] = {
        'binary_base_hex':        f"0x{summary['binary_base']:05X}",
        'binary_base_dec':        str(summary['binary_base']),
        'segoff_binary_base':     summary['segoff_binary_base']
    }

    rv = summary['reset_vector']
    cfg['ResetVector'] = {
        'segment_hex':  f"0x{rv['segment']:04X}",
        'segment_dec':  str(rv['segment']),
        'offset_hex':   f"0x{rv['offset']:04X}",
        'offset_dec':   str(rv['offset']),
        'phys_hex':     f"0x{rv['phys']:06X}",
        'phys_dec':     str(rv['phys']),
    }

    if 'reset_jump_target' in summary:
        rjt = summary['reset_jump_target']
        cfg['ResetJumpTarget'] = {
            'segment_hex':  f"0x{rjt['segment']:04X}",
            'segment_dec':  str(rjt['segment']),
            'offset_hex':   f"0x{rjt['offset']:04X}",
            'offset_dec':   str(rjt['offset']),
            'phys_hex':     f"0x{rjt['phys']:06X}",
            'phys_dec':     str(rjt['phys']),
            'segoff':       rjt['segoff']
        }

    for entry in summary['ivt']:
        sec = f"IVT_{entry['int_num']:02X}"
        phys = entry['phys']
        in_bios = summary['binary_base'] <= phys < (summary['binary_base'] + 0x10000)
        cfg[sec] = {
            'int_num_dec':   str(entry['int_num']),
            'int_num_hex':   f"0x{entry['int_num']:02X}",
            'segment_hex':   f"0x{entry['segment']:04X}",
            'segment_dec':   str(entry['segment']),
            'offset_hex':    f"0x{entry['offset']:04X}",
            'offset_dec':    str(entry['offset']),
            'phys_hex':      f"0x{phys:06X}",
            'phys_dec':      str(phys),
            'in_bios':       str(in_bios).lower()
        }

    with open(out_path, 'w') as f:
        cfg.write(f, space_around_delimiters=True)

def main():
    reset_bytes, (reset_seg, reset_off), ivt = parse_biosinf(TEXT_DUMP)
    bios = BIOSImage(BIN_IMAGE)

    summary = {
        'binary_base':        0xF0000,
        'segoff_binary_base': 'F000:0000',
        'reset_vector': {
            'segment': reset_seg,
            'offset':  reset_off,
            'bytes':   reset_bytes,
            'phys':    BIOSImage.phys_addr(reset_seg, reset_off)
        },
        'ivt': []
    }

    if len(reset_bytes) >= 5 and reset_bytes[0] == 0xEA:
        off = reset_bytes[1] | (reset_bytes[2] << 8)
        seg = reset_bytes[3] | (reset_bytes[4] << 8)
        summary['reset_jump_target'] = {
            'segment': seg,
            'offset':  off,
            'phys':    BIOSImage.phys_addr(seg, off),
            'segoff':  f"{seg:04X}:{off:04X}"
        }

    for num, (seg, off) in sorted(ivt.items()):
        phys = BIOSImage.phys_addr(seg, off)
        summary['ivt'].append({
            'int_num': num,
            'segment': seg,
            'offset':  off,
            'phys':    phys
        })

    write_ini(INI_OUT, summary)
    print(f"Wrote summary to {INI_OUT}")

if __name__ == '__main__':
    main()
