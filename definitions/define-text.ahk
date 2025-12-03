
Display_Text_SetConstants(force := false) {
    global
    if IsSet(Display_text_constants_set) && !force {
      return
    }
    DISPLAY_SPACE_CHAR_START := 0x2000
    DISPLAY_SPACE_CHAR_END := 0x200B
    ; DISPLAY_EN_QUAD := Chr(0x2000)
    ; DISPLAY_EM_QUAD := Chr(0x2001)
    ; DISPLAY_EN := Chr(0x2002)
    ; DISPLAY_EM := Chr(0x2003)
    ; DISPLAY_THREE_PER_EM := Chr(0x2004)
    ; DISPLAY_FOUR_PER_EM := Chr(0x2005)
    ; DISPLAY_SIX_PER_EM := Chr(0x2006)
    ; DISPLAY_FIGURE := Chr(0x2007)
    ; DISPLAY_PUNCTUATION := Chr(0x2008)
    ; DISPLAY_THIN := Chr(0x2009)
    ; DISPLAY_HAIR := Chr(0x200A)
    ; DISPLAY_ZERO_WIDTH := Chr(0x200B)
}
