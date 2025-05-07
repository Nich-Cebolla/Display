
OUT_DEFAULT_PRECIS := 0
OUT_STRING_PRECIS := 1
OUT_CHARACTER_PRECIS := 2
OUT_STROKE_PRECIS := 3
OUT_TT_PRECIS := 4
OUT_DEVICE_PRECIS := 5
OUT_RASTER_PRECIS := 6
OUT_TT_ONLY_PRECIS := 7
OUT_OUTLINE_PRECIS := 8
OUT_SCREEN_OUTLINE_PRECIS := 9
OUT_PS_ONLY_PRECIS := 10

CLIP_DEFAULT_PRECIS := 0
CLIP_STROKE_PRECIS := 2
CLIP_LH_ANGLES := 1<<4
CLIP_EMBEDDED := 8<<4
CLIP_TT_ALWAYS := 2<<4      ; not used
CLIP_MASK := 0xf            ; not used
CLIP_CHARACTER_PRECIS := 1  ; not used

DEFAULT_QUALITY := 0
DRAFT_QUALITY := 1
PROOF_QUALITY := 2
NONANTIALIASED_QUALITY := 3
ANTIALIASED_QUALITY := 4
CLEARTYPE_QUALITY := 5
CLEARTYPE_NATURAL_QUALITY := 6

DEFAULT_PITCH := 0
FIXED_PITCH := 1
VARIABLE_PITCH := 2
MONO_FONT := 8

/** Font families */
FF_DONTCARE := 0<<4      ; Don't care or don't know.
FF_ROMAN := 1<<4         ; Variable stroke width, serifed. Times Roman, Century Schoolbook, etc.
FF_SWISS := 2<<4         ; Variable stroke width, sans-serifed. Helvetica, Swiss, etc.
FF_MODERN := 3<<4        ; Constant stroke width, serifed or sans-serifed. Pica, Elite, Courier, etc.
FF_SCRIPT := 4<<4        ; Cursive, etc.
FF_DECORATIVE := 5<<4    ; Old English, etc.
FF_MODERN := 3<<4        ; Constant stroke width, serifed or sans-serifed. Pica, Elite, Courier, etc.

/* Font Weights */
FW_DONTCARE := 0
FW_THIN := 100
FW_EXTRALIGHT := 200
FW_LIGHT := 300
FW_NORMAL := 400
FW_MEDIUM := 500
FW_SEMIBOLD := 600
FW_BOLD := 700
FW_EXTRABOLD := 800
FW_HEAVY := 900

FW_ULTRALIGHT := FW_EXTRALIGHT
FW_REGULAR := FW_NORMAL
FW_DEMIBOLD := FW_SEMIBOLD
FW_ULTRABOLD := FW_EXTRABOLD
FW_BLACK := FW_HEAVY
