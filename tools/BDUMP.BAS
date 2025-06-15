CONST BIOSSEG = &HF000, CHUNK = 4096
DEF SEG = BIOSSEG
DIM buf AS STRING * CHUNK

OPEN "biosinf.txt" FOR OUTPUT AS #2
revHi = PEEK(&HE6E): revLo = PEEK(&HE6F)
PRINT #2, "Bytes at reset vector:"
FOR i = &HFFF0 TO &HFFF0 + 15
    PRINT #2, HEX$(PEEK(i)); " ";
NEXT i
PRINT #2, ""
PRINT #2, "Reset Vector: FFFF:0000"
PRINT #2, "IVT (int#  seg:off)"

DEF SEG = 0
FOR i = 0 TO 255
    DIM ofs AS LONG, segm AS LONG
    ofs = PEEK(i * 4) + 256& * PEEK(i * 4 + 1)
    segm = PEEK(i * 4 + 2) + 256& * PEEK(i * 4 + 3)
    PRINT #2, HEX$(i); "  "; HEX$(segm); ":"; HEX$(ofs)
NEXT i
CLOSE #2

DEF SEG = BIOSSEG

OPEN "bios.bin" FOR BINARY AS #1
FOR blk = 0 TO (65536 \ CHUNK) - 1
    DEF SEG = BIOSSEG + (blk * (CHUNK \ 16))
    FOR j = 0 TO CHUNK - 1
        MID$(buf, j + 1, 1) = CHR$(PEEK(j))
    NEXT j
    PUT #1, , buf
NEXT blk
CLOSE #1

PRINT "Done."

