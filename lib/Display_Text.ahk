
; Dependencies:
#Include ..\struct\Display_SIZE.ahk
#Include ..\struct\Display_IntegerArray.ahk

/**
    The WinAPI text functions here require string length measured in WORDs. `StrLen()` handles this
    for us, as noted here: {@link https://www.autohotkey.com/docs/v2/lib/Chr.htm}
    "Unicode supplementary characters (where Number is in the range 0x10000 to 0x10FFFF) are counted
    as two characters. That is, the length of the return value as reported by StrLen may be 1 or 2.
    For further explanation, see String Encoding."
    {@link https://www.autohotkey.com/docs/v2/Concepts.htm#string-encoding}

    ; The functions all require a device context handle. You can get an `hDC` from a control, gui, or
    ; even external windows.
   @example
    if hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd) {
        ; do something
    } else {
        err := OSError()
        ; handle error
    }
   @

    You can use the same handle multiple times as needed if you're certain nothing else will be needing
    to use the device context while your function is executing (i.e. the Gui window's appearence won't
    need updated). When you call `GetDC`, the device context is locked until you release it. Your
    code should release it as soon as it completes its last action that requires the handle.

   @example
    if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
        err := OSError()
        ; handle error
    }
   @

   If you need help understanding how to handle OS errors, read the section "OSError" here:
   {@link https://www.autohotkey.com/docs/v2/lib/Error.htm}
   I started writing up a helper before realizing AHK already handles it, but if you
   feel like more clarification would be helpful:
   {@link https://gist.github.com/Nich-Cebolla/c8eea56ac8ab27767e31629a0a9b0b2f/}


*/

; -------------------------

/**
 * @description - Gets the dimensions of a string within a window's device context.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}
 * @param {Integer} hDC - A handle to the device context you want used to measure the string.
 * @param {String} Str - The string to measure.
 * @param {VarRef} OutSIZE - A variable that will receive a SIZE object with properties { Width, Height }
 * @returns {Boolean} - If the function succeeds, the return value is nonzero. If the function fails,
 * the return value is zero.
 */
GetTextExtentPoint32(hDC, Str, &OutSIZE) {
    ; Measure the text
    return DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', hDC
        , 'Ptr', StrPtr(Str)
        , 'Int', StrLen(Str)
        , 'Ptr', OutSIZE := SIZE()
        , 'Int'
    )
}

/**
 * @description - `GetTextExtentExPoint` is similar to `GetTextExtentPoint32`, but has several additional
 * functions to work with. `GetTextExtentExPoint` measures a string's dimensions and the width (extent
 * point) in pixels of each character's position in the string.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 * An example function call is available in file {@link examples\example_Text_GetTextExtentExPoint.ahk}
 * @param {String} Str - The string to measure.
 * @param {Integer} hDC - The handle to the device context you want to use when measuring the string.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. When nonzero,
 * `OutCharacterFit` is set to the number of characters that fit within the `nMaxExtent` pixels
 * in the context of the control, and `OutExtentPoints` will only contain extent points up to
 * `OutCharacterFit` number of characters. If 0, `nMaxExtent` is ignored, `OutCharacterFit` is
 * assigned 0, and `OutExtentPoints` will contain the extent point for every character in the
 * string.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within the given width. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutSIZE] - A variable that will receive a SIZE object with properties { Width, Height }
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`, a buffer
 * object containing the partial string extent points (the cumulative width of the string at
 * each character from left to right measured from the beginning of the string to the right-side of
 * the character). If `nMaxExtent` is nonzer0, the number if extent points contained by`OutExtentPoints`
 * will equal `OutCharacterFit`. If `nMaxExtent` is zero, `OutExtentPoints` will contain the extent
 * point for every character in the string. `OutExtentPoints` is not an instance of `Array`; it has
 * only one method, `__Enum`, which you can use by calling it in a loop, and it has one property,
 * `__Item`, which you can use to access items by index.
 */
GetTextExtentExPoint(Str, hDC, nMaxExtent := 0, &OutCharacterFit?, &OutSIZE?, &OutExtentPoints?) {
    Result := DllCall('Gdi32.dll\GetTextExtentExPoint'
        , 'ptr', hDC
        , 'ptr', StrPtr(Str)                                    ; String to measure
        , 'int', StrLen(Str)                                    ; String length in WORDs
        , 'int', nMaxExtent                                     ; Maximum width
        , 'ptr', lpnFit := nMaxExtent ? Buffer(4) : 0           ; To receive number of characters that can fit
        , 'ptr', OutExtentPoints := IntegerArray(StrLen(Str)  * 4) ; An array to receives partial string extents. Here it's null.
        , 'ptr', OutSIZE := SIZE()                              ; To receive the dimensions of the string.
        , 'ptr'
    )
    DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
    if Result {
        OutCharacterFit := nMaxExtent ? NumGet(lpnFit, 0, 'int') : 0
    } else {
        return 1
    }
}

/**
 * @description - Wraps text to a maximum width in pixels, breaking at break points defined by the
 * `BreakChars` parameter. Any newline characters contained in the input string are replaced
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
 * @param {Func} [BreakChars='[-]'] - `BreakChars` is a RegEx character class that
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
WrapText(Context, &Str?, MaxWidth?, BreakChars := '-', AdjustControl := false, Newline := '`r`n', &OutLineCount?) {
    if IsObject(Context) {
        if HasProp(Context, 'hWnd') {
            ; If MaxWidth is unset, use the width of the control.
            if !IsSet(MaxWidth) {
                Context.GetPos(, , &MaxWidth)
            }
            if IsSet(Str) {
                Text := RegExReplace(Str, '\R', ' ')
            } else {
                if IsObject(Context.Text) {
                    throw TypeError('``Context.Text`` returned an object.', -1, 'Type(Context.Text) == ' Type(Context.Text))
                } else {
                    Text := RegExReplace(Context.Text, '\R', ' ')
                }
            }
            if !(hDC := DllCall('GetDC', 'Ptr', Context.hWnd)) {
                throw OSError('``GetDc`` failed.', -1, A_LastError)
            }
        } else {
            _Throw(1, A_LineNumber, A_ThisFunc)
        }
    } else if IsNumber(Context) {
        if !IsSet(Str) || !IsSet(MaxWidth) {
            _Throw(2, A_LineNumber, A_ThisFunc)
        }
        hDC := Context
        Text := RegExReplace(Str, '\R', ' ')
    } else {
        _Throw(1, A_LineNumber, A_ThisFunc)
    }

    ; Measure the width of a hyphen
    hyphen := '-'
    if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
        , hDC, 'Ptr', StrPtr(hyphen), 'Int', 1, 'Ptr', lpSize := Buffer(8)) {
        throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
    }
    hyphen := NumGet(lpSize, 0, 'uint')

    ; `MaxWidth` must at least be large enough such that the loops can iterate once or twice
    ; before reaching the beginning of the substring. I decided I'll use "W" as my baseline for
    ; this.
    W := 'W'
    if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
        , hDC, 'Ptr', StrPtr(W), 'Int', 1, 'Ptr', lpSize) {
        throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
    }
    W := NumGet(lpSize, 0, 'uint')
    if MaxWidth < W * 3 + hyphen {
        throw ValueError('``MaxWidth`` must be at least three times the width of "W" plus the width of "-" in the device context.', -1, 'Input ``MaxWidth``: ' MaxWidth '; Minimum: ' (W * 3 + hyphen))
    }

    ; Check the string for the presence of break characters
    z := InStr(Text, '`t') ? 1 : 0
    if BreakChars {
        _BreakChars := ''
        for ch in StrSplit(BreakChars) {
            if InStr(Text, ch) {
                _BreakChars .= ch
            }
        }
        if _BreakChars {
            _BreakChars := RegExReplace(StrReplace(_BreakChars, '\', '\\'), '(\]|-)', '\$1')
            BreakChars := '([' _BreakChars '])[^' _BreakChars ']*$'
            z += 2
        }
    }
    if InStr(Text, '`s') {
        z += 4
    }
    switch z {
        case 0: Proc := _Proc_0
        case 1: Proc := _Proc_1.Bind('`t')      ; Tabs
        case 2: Proc := _Proc_2                 ; Break chars
        case 3: Proc := _Proc_3.Bind('`t')      ; Tabs + break chars
        case 4: Proc := _Proc_1.Bind('`s')      ; Spaces
        case 5: Proc := _Proc_4                 ; Spaces + tabs
        case 6: Proc := _Proc_3.Bind('`s')      ; Spaces + break chars
        case 7: Proc := _Proc_5                 ; Spaces + tabs + break chars
    }
    OutLineCount := 0
    loop {
        OutLineCount++
        cchString := StrLen(Text)
        if !DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hDC                                            ; Device context
            , 'ptr', StrPtr(Text)                                   ; String to measure
            , 'int', cchString                                      ; String length in WORDs
            , 'int', MaxWidth                                       ; Maximum width
            , 'ptr', lpnFit := Buffer(4)                            ; To receive number of characters that can fit
            , 'ptr', lpnDx := IntegerArray(cchString * 4)           ; An array to receives partial string extents. Here it's null.
            , 'ptr', lpSize                                         ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            throw OSError('``GetTextExtentExPoint`` failed.', -1, A_LastError)
        }
        if NumGet(lpnFit, 0, 'uint') >= cchString {
            break
        }
        fit := NumGet(lpnFit, 0, 'uint')
        Proc()
    }
    Str .= Text
    if AdjustControl {
        Context.Move(, , , OutLineCount * NumGet(lpSize, 4, 'uint'))
        Context.Text := Str
    }

    return OutLineCount * NumGet(lpSize, 4, 'uint')

    ; No break characters or whitespace
    _Proc_0() {
        local n := 0
        ; a := []
        ; for z in lpnDx {
        ;     a.Push(z)
        ; }
        ; sleep 1
        loop fit - 1 {
            if lpnDx[fit - n] + hyphen <= MaxWidth {
                break
            }
            n++
        }
        Str .= SubStr(Text, 1, fit - n) '-' Newline
        Text := SubStr(Text, fit + n + 2)
    }
    ; Has spaces or tabs
    _Proc_1(ch) {
        if (Pos := InStr(SubStr(Text, 1, fit), ch, , , -1)) && Pos <= fit {
            Str .= SubStr(Text, 1, Pos - 1) Newline
            Text := SubStr(Text, Pos + 1)
        } else {
            _Proc_0()
        }
    }
    ; Has break characters
    _Proc_2() {
        if RegExMatch(SubStr(Text, 1, fit), BreakChars, &Match) {
            Str .= SubStr(Text, 1, Match.Pos) Newline
            Text := SubStr(Text, Match.Pos + 1)
        } else {
            _Proc_0()
        }
    }
    ; Has either spaces / tabs, and break characters
    _Proc_3(ch) {
        Part := SubStr(Text, 1, fit)
        Pos_W := InStr(Part, ch, , , -1)
        Pos_B := RegExMatch(Part, BreakChars, &Match)
        if Pos_W > Pos_B {
            Str .= SubStr(Text, 1, Pos_W - 1) Newline
            Text := SubStr(Text, Pos_W + 1)
        } else if Pos_B > Pos_W {
            Str .= SubStr(Text, 1, Match.Pos) Newline
            Text := SubStr(Text, Match.Pos + 1)
        } else {
            _Proc_0()
        }
    }
    ; Has spaces and tabs
    _Proc_4() {
        Part := SubStr(Text, 1, fit)
        Pos := Max(InStr(Part, '`t', , , -1), InStr(Part, '`s', , , -1))
        if Pos {
            Str .= SubStr(Text, 1, Pos - 1) Newline
            Text := SubStr(Text, Pos + 1)
        } else {
            _Proc_0()
        }
    }
    ; Has spaces, tabs, and break characters
    _Proc_5() {
        Part := SubStr(Text, 1, fit)
        Pos_W := Max(InStr(Part, '`t', , , -1), InStr(Part, '`s', , , -1))
        Pos_B := RegExMatch(Part, BreakChars, &Match)
        if Pos_W > Pos_B {
            Str .= SubStr(Text, 1, Pos_W - 1) Newline
            Text := SubStr(Text, Pos_W + 1)
        } else if Pos_B > Pos_W {
            Str .= SubStr(Text, 1, Match.Pos) Newline
            Text := SubStr(Text, Match.Pos + 1)
        } else {
            _Proc_0()
        }
    }

    _Throw(Id, Line, Fn) {
        switch Id {
            case 1: err := TypeError('``Context`` must be either a number representing a handle to'
                ' a device context, or an object with an ``hWnd`` property.', -2, 'Type(Context) == '
                Type(Context))
            case 2:
                if IsSet(Str) {
                    Extra := '``MaxWidth`` is unset.'
                } else if IsSet(MaxWidth) {
                    Extra := '``Str`` is unset.'
                } else {
                    Extra := '``Str`` and ``MaxWidth`` are unset.'
                }
                err := UnsetError('``Str`` and ``MaxWidth`` must be set when ``Context`` is a number.', -2, Extra)
        }
        err.What := Fn
        err.Line := Line
        throw err
    }
}

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


