
/**
 * @description - Gets the dimensions of a string within a window's device context.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}
 * @param {String} Str - The string for which to get the dimensions.
 * @param {Integer} hWnd - The handle to a Gui of Gui.Control object, or another window.
 * @param {VarRef} [Width] - A variable that will receive the width of the string.
 * @param {VarRef} [Height] - A variable that will receive the height of the string.
 */
GetTextExtentPoint32(str, hWnd, &Width?, &Height?) {
    ; Get the device context
    if !(hDC := DllCall('GetDC', 'Ptr', hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    ; Measure the text
    if !DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32', 'Ptr'
        , hDC, 'Ptr', StrPtr(Str), 'Int', , 'Ptr', SIZE := Buffer(8)) {
        throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
    }
    ; Release the device context
    DllCall('ReleaseDC', 'Ptr', hWnd, 'Ptr', hDC)
    Width := NumGet(SIZE, 0, 'UINT')
    Height := NumGet(SIZE, 4, 'UINT')
}

/**
 * @description - This function is similar to `GetTextExtentPoint32`, but it also will return
 * the number of character that fit within a given width, and an array of partial string
 * extent points.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 * @param {String} Str - The string for which to get the dimensions.
 * @param {Integer} hWnd - The handle to a `Gui.Control` object that has the font which you want
 * used for the function, or another type of window that has a valid device context.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. When nonzero,
 * `OutCharacterFit` is set to the number of characters that fit within the `nMaxExtent` pixels
 * in the context of the control, and `OutExtentPoints` will only contain extent points up to
 * `OutCharacterFit` number of characters. If 0, the parameter is ignored, `OutCharacterFit` is
 * assigned 0, and `OutExtentPoints` will contain the extent point for every character in the
 * string.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within the given width. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutWidth] - A variable that will receive the width of the string.
 * @param {VarRef} [OutHeight] - A variable that will receive the height of the string.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive a `IntegerArray`, a buffer
 * object containing the partial string extent points (the cumulative width of the string at
 * each character from left to right) up to `nMaxExtent` number of characters when `nMaxExtent`
 * is nonzero. When `nMaxExtent` is zero, every character in the string is represented in this
 * IntegerArray. This is not an instance of `Array`; it has only one method, `__Enum`, which you
 * can use by calling it in a loop, and it has one property, `__Item`, which you can use to access
 * items by index.
 */
GetTextExtentExPoint(Str, hWnd, nMaxExtent := 0, &OutCharacterFit?, &OutWidth?, &OutHeight?, &OutExtentPoints?) {
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    ; This counts surrogate pairs
    RegExReplace(Str, '[\x{D800}-\x{DBFF}][\x{DC00}-\x{DFFF}]', , &Count)
    Result := DllCall('Gdi32.dll\GetTextExtentExPoint'
        , 'ptr', hDC := DllCall('GetDC', 'Ptr', hWnd)           ; Device context
        , 'ptr', StrPtr(Str)                                    ; String to measure
        , 'int', StrLen(Str) + Count                            ; String length in WORDs
        , 'int', nMaxExtent                                     ; Maximum width
        , 'ptr', lpnFit := nMaxExtent ? Buffer(4) : 0           ; To receive number of characters that can fit
        , 'ptr', OutExtentPoints := IntegerArray(cchString * 4) ; An array to receives partial string extents. Here it's null.
        , 'ptr', lpSize := Buffer(8)                            ; To receive the dimensions of the string.
        , 'ptr'
    )
    DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
    if Result {
        OutCharacterFit := nMaxExtent ? NumGet(lpnFit, 0, 'int') : 0
        OutWidth := NumGet(lpSize, 0, 'int')
        OutHeight := NumGet(lpSize, 4, 'int')
        return 0
    } else {
        throw OSError('``GetTextExtentExPoint`` failed.', -1, A_LastError)
    }
}

/**
 * @description - The same as `dText.GetTextExtentExPoint`, but you are responsible for more of
 * the setup for better performance across multiple calls:
 * - Pass the string as a VarRef
 * - Provide the device context. Don't forget to release it when finished.
 * - The out-variables receive buffer objects instead of the values.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 * @param {VarRef} Str - The string for which to get the dimensions.
 * @param {Integer} hDc - The handle to the device context.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. When nonzero,
 * `lpnFit` is assigned a `Buffer` object containing the number of characters that fit within
 * `nMaxExtent` pixels in the context of the control, and `lpnDx` will only contain extent points up
 * to `lpnFit` number of characters. If 0, the parameter is ignored, `lpnFit` is assigned 0, and
 * `lpnDx` will contain the extent point for every character in the string.
 * @param {VarRef} [lpnFit] - A variable that will receive a `Buffer` object containing
 * the number of characters that fit within the given width. Retrieve the value with the expression
 * `NumGet(lpnFit, 0, 'int')`. If `nMaxExtent` is 0, this will be 0.
 * @param {VarRef} [lpnDx] - When `nMaxExtent` is nonzero, a variable that will receive an
 * `IntegerArray` object containing the partial string extent points (the cumulative width of the
 * string at each character from left to right) up to `nMaxExtent` number of characters. When
 * `nMaxExtent` is zero, every character in the string is represented in this `IntegerArray`.
 * @param {VarRef} [lpSize] - A variable that will receive a `SIZE` object. You can access the
 * width and height values from the properties { Width, Height }.
 * @param {Integer} [cchString] - If your string contains surrogate pairs, provide the length
 * of the string in WORDs. Otherwise, the length is set to the string length in characters.
 * This expression will get the length of the string in WORDs:
 * @example
 *  RegExReplace(Str, '[\x{D800}-\x{DBFF}][\x{DC00}-\x{DFFF}]', , &Count)
 *  cchString := StrLen(Str) + Count
 * @
 */
GetTextExtentExPoint2(&Str, hDc, nMaxExtent := 0, &lpnFit?, &lpnDx?, &lpSize?, cchString?) {
    if !IsSet(cchString) {
        cchString := StrLen(Str)
    }
    if !DllCall('Gdi32.dll\GetTextExtentExPoint'
        , 'ptr', hDC                                            ; Device context
        , 'ptr', StrPtr(Str)                                    ; String to measure
        , 'int', cchString                                      ; String length in WORDs
        , 'int', nMaxExtent                                     ; Maximum width
        , 'ptr', lpnFit := nMaxExtent ? Buffer(4) : 0           ; To receive number of characters that can fit
        , 'ptr', lpnDx := IntegerArray(cchString * 4)           ; An array to receives partial string extents. Here it's null.
        , 'ptr', lpSize := SIZE()                               ; To receive the dimensions of the string.
        , 'ptr'
    ) {
        throw OSError('``GetTextExtentExPoint`` failed.', -1, A_LastError)
    }
}

/**
 * @description - Wraps text to a maximum width in pixels, breaking at break points defined by the
 * `BreakClass` parameter. Any newline characters contained in the input string are replaced
 * with a space character prior to processing.
 * @param {Gui.Control|Integer} hDC_or_Control - Either a device context to use to measure the text,
 * or a control object that will be used to obtain the device context.
 * @param {VarRef} Str - A variable that will receive the result string.
 * - If you set `Str` with a string value, `WrapText` processes that value.
 * - If `hDC_or_Control` is a `Gui.Control` object, then `Str` is optional. If you leave it unset,
 * or pass it as an unset VarRef / empty string VarRef, then `WrapText` processes the contents of
 * `hDC_or_Control.Text`.
 * Example using a control object, handling the adjustment in our own code:
 * @example
 *  G := Gui()
 *  Txt := G.Add('Text', , 'Original text.')
 *  ; User does some action that changes the text content of Txt
 *  Txt.Text := 'New text that needs to stay the same width.'
 *  ; We need to adjust the height of the control, keeping the width constant
 *  NewSize := WrapText(Txt, &NewStr)
 *  ; Perhaps we want to validate the size of the text before adjusting the control
 *  if NewSize.Height <= ArbitraryMaximum {
 *      Txt.Text := NewStr
 *      Txt.Move(, , , NewSize.Height)
 *  } else {
 *      HandleTooLargeInputFromUser(Txt, NewSize, NewStr)
 *  }
 * @
 * Example using a control object, allowing `WrapText` to make the adjustments:
 * @example
 *  G := Gui()
 *  Txt := G.Add('Text', , 'Original text.')
 *  ; User does some action that changes the text content of Txt
 *  Txt.Text := 'New text that needs to stay the same width.'
 *  ; Pass `true` to have `WrapText` update the control automatically
 *  WrapText(Txt, , , , true)
 * @
 * Example usign an input string:
 * @example
 *  ; My code needs to dynamically add a control containing some arbitrary text. I know the maximum
 *  ; width, but the actual text is unknown until the user does some action. I also know that the
 *  ; control will be using the same font as another control, so we can use that as the device
 *  ; context.
 *  Str :=
 * @param {Integer} [MaxWidth] - The maximum width in pixels to wrap the text to. If unset and if
 * `hDC_or_Control` is a `Gui.Control` object, the control's current width is used.
 * @param {Func} [BreakClass='[-]'] - `BreakClass` is a RegEx character class that
 * defines what characters are valid breakpoints for splitting a line. When this function breaks
 * a line, it will do so at the greatest breakpoint that does not cause the line to exceed `MaxWidth`
 * pixels. If a single sequence of non-breakpoint characters exceeds `MaxWidth` pixels, the
 * characters are split and hyphenated, typically at the character previous to the character which
 * causes the line to exceed `MaxWidth`, but if that character is particularly thin (like an "i" in
 * a non-monospaced font) then it may be two characters previous. Newline characters are ignored
 * because they are removed from the string prior to processing anyway, and space and tab characters
 * are always considered breakpoints but they are handled separately because if a line breaks on
 * a tab or space character, the line breaks and the character is removed from the string. If a line
 * breaks on any other type of breakpoint character, the line breaks after the character and any
 * subsequent consecutive spaces or tabs are removed if any are present, and if none are present
 * nothing is removed. Since most natural breaking characters are followed by a space anyway, there's
 * there's often little need to define additional breaking characters because they would not
 * influence any new behavior from the function. The primary character for which this is not true is
 * the hyphen, which itself is a natural breakpoint character and is not usually followed by a space
 * or tab. This parameter should be defined as a character class (i.e. enclosed by square brackets)
 * because `WrapText` will add a negating '^' to the pattern string to process the input.
 */
WrapText(hDC_or_Control, &Str?, MaxWidth?, BreakClass := '[-]', AdjustControl := false) {
    if hDC_or_Control is Gui.Control {
        ; If MaxWidth is unset, use the width of the control.
        if !IsSet(MaxWidth) {
            Ctrl.GetPos(, , &MaxWidth)
        }
        try {
            Text := RegExReplace(Str || hDC_or_Control.Text, '\R', ' ')
        } catch Error as err {
            err.Extra .= ' The control`'s ``Text`` property returned a non-string value.'
            throw err
        }
        hDC := DllCall('GetDC', 'Ptr', hDC_or_Control.hWnd)
    }
    ; Replace newlines with space.
    ; Get the length of the string in WORDs.
    ; This pattern checks for any surrogate pairs.
    RegExReplace(Text, '[\x{D800}-\x{DBFF}][\x{DC00}-\x{DFFF}]', , &Count)
    ; We can just add the number of surrogate pairs to the character length to get the valid length
    ; in WORDS.
    cchString := StrLen(Text) + Count
    GetTextExtentExPoint2(&Text, hDC, 0, &Fit, &CharExtent, &Size, cchString)
    i := Delta := Previous := 0
    Lines := Initial := 1
    while ++i <= Split.Length {
        if NumGet(lpnDx, i * 4 - 4, 'int') - Delta > MaxWidth {

            ; If we have found a valid breakpoint
            if Previous {
                Str .= SubStr(Text, Initial, A_Index - Initial) '`r`n'
                Lines++
                ; Skip any additional nonprintable characters that are in sequence.
                while Ord(SubStr(Ctrl.Text, i, 1)) <= 32 {
                    i++
                }
            ; If we haven't found a valid breakpoint yet
            } else {

            }
        }

    }
}

                ; ; Start a new index var
                ; z := A_Index
                ; ; Loop backwardsthe characters to find a natural breakpoint.
                ; loop z - Initial {
                ;     c := Ord(char)
                ;     ; If it's a valid breakpoint.
                ;     if Condition(c) {
                ;         Str .= SubStr(Ctrl.Text, Initial, i - Initial) '`r`n'
                ;         Lines++
                ;         ; Skip any additional nonprintable characters that are in sequence.
                ;         while Ord(SubStr(Ctrl.Text, i, 1)) <= 32 {
                ;             i++
                ;         }
                ;         Initial := i
                ;         Delta := NumGet(lpnDx, (i - 1) * 4, 'int')
                ;         break
                ;     }
                ;     z--
                ; }
                ; ; If we didn't find a break point, we just split the word.
                ; if !i {
                ;     i := z
                ;     Str .= SubStr(Ctrl.Text, Initial, i - Initial) '`r`n'
                ;     Lines++
                ;     ; Skip any additional nonprintable characters that are in sequence.
                ;     while Ord(SubStr(Ctrl.Text, i, 1)) <= 32 {
                ;         i++
                ;     }
                ; }

; CalcTextRect(Str, hWnd, WidthLimit?) {
;     hDC := DllCall('GetDC', 'ptr', hWnd, 'ptr')
;     hFont := SendMessage(0x31, , , hWnd)  ; WM_GETFONT
;     oldFont := DllCall('SelectObject', 'ptr', hDC, 'ptr', hFont, 'ptr')

;     rc := Buffer(16, 0)  ; RECT = 4x INT (left, top, right, bottom)

;     if IsSet(WidthLimit)
;         NumPut('int', 0, 'int', 0, 'int', WidthLimit, 'int', 0, rc)  ; Set max width

;     DT_WORDBREAK := 0x10
;     DT_CALCRECT := 0x400
;     DT_LEFT := 0x0
;     DT_TOP := 0x0

;     flags := DT_CALCRECT | DT_WORDBREAK | DT_LEFT | DT_TOP

;     DllCall('DrawTextW'
;         , 'ptr', hDC
;         , 'wstr', Str
;         , 'int', -1
;         , 'ptr', rc
;         , 'uint', flags
;     )

;     width  := NumGet(rc, 8, 'int') - NumGet(rc, 0, 'int')
;     height := NumGet(rc, 12, 'int') - NumGet(rc, 4, 'int')

;     DllCall('SelectObject', 'ptr', hDC, 'ptr', oldFont)
;     DllCall('ReleaseDC', 'ptr', hWnd, 'ptr', hDC)

;     return { w: width, h: height }
; }


