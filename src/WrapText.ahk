
#include SelectFontIntoDc.ahk
#include ..\struct
#include Display_IntegerArray.ahk
#include Display_Size.ahk

class WrapText {

    /**
     * @description - Wraps text to a maximum width in pixels.
     *
     * {@link WrapText} measures the input text
     *
     * If one or more characters between `Options.MinExtent` and `Options.MaxExtent` are break
     * characters, then:
     * - If the break character closest to `Options.MaxExtent` is a whitespace character, then the
     *   line wraps before the whitespace character. Any extra whitespace characters are trimmed from
     *   each line.
     * - If the break character closest to `Options.MaxExtent` is not a whitespace character, then
     *   the line wraps after the character.
     *
     * If there are no break characters, then the line is wrapped after the character closest to
     * `Options.MaxExtent`. A hyphen may be added depending on the character and the input options.
     * `WrapText` ensures that adding a hyphen does not cause the line to exceed `Options.MaxExtent`.
     *
     * Additional details:
     * - When `Options.MeasureLines` is false, and if `WrapText` is directed to use hyphens where
     *   appropriate, there is a small chance that some measurements may be off by one or two pixels. This
     *   is caused by the way `WrapText` handles hyphens. If `Options.MeasureLines` is false, any
     *   measurement that involves a hyphen is produced by adding the width of a hyphen to the width of
     *   a line. This does not account for kerning and other system-dependent conditions, and may produce
     *   an incorrect value. If your application requires precise adherence to `Options.MaxExtent`, set this
     *   to a nonzero value. When false, the possible incorrect values produced by `WrapText` are:
     *   - The width of any line that is hyphenated can potentially be one or two pixels over
     *     `Options.MaxExtent` or one or two pixels under `Options.MinExtent`.
     *   - The value received by `OutWidth` may be one or two pixels off in either direction from the
     *     actual width.
     * - All consecutive end of line characters are converted to a single space character prior to processing.
     * - When making the decision to add additional characters to `Options.BreakChars`, keep in mind that,
     *   if a break character will always be followed by a whitespace character, then adding it to
     *   `Options.BreakChars` will only change the amount of time it takes `WrapText` to process the input.
     *   It will not change the output string. If there is a possibility that the character is followed by
     *   a non-whitespace character, and it is a character that you believe is a natural break character for
     *   your project, then you should add it to the list.
     * - There's no harm if the input string ultimately does not contain one or more of the characters
     *   from `Options.BreakChars`; the string is checked to see if it contains at least one of each
     *   character. If any character is absent, it is purged from the list of possible break characters to
     *   save processing time.
     * - If there are only spaces (and no tabs) in the input string, `WrapText` only checks for spaces
     *   when searching for whitespace, and vise-versa.
     * - A hyphen is never added after a break character, even if the break character is alphanumeric and
     *   the related option is true.
     * - If the difference between `Options.MaxExtent` and `Options.MinExtent` is relatively small,
     *   there is a possibility that no valid wrap position is available within a substring. If this occurs,
     *   `WrapText` will always choose to wrap at an extent less than `Options.MaxExtent`, resulting in a
     *   line shorter than `Options.MinExtent`.
     * - Similar to the above point, if `WrapText` trims whitespace characters from the end of a line,
     *   this can cause the line to be shorter than `Options.MinExtent`.
     *
     * @param {Gui.Control|Integer|Object} Context - Either a handle to the device context to use to
     * measure the text, a `Gui.Control` object, or an object with an `hWnd` property.
     *
     * @param {VarRef} [Str] - The input string, and/or a variable that will receive the result string.
     * - `Str` is required when `Context` is a handle to a device context.
     * - If you set `Str` with a string value, `WrapText` always processes that value, and sets the
     * variable with the resulting string before `WrapText` returns.
     * - If `Context` is an object, then `Str` is optional. If you leave it unset, or pass it as an unset
     * VarRef / empty string VarRef, then `WrapText` processes the contents of `Context.Text`. If the
     * object does not have a `Text` property, AHK will throw an error.
     *
     * @param {Object} [Options] - An object containing zero or more options as properties.
     * It should be documented that `WrapText` changes the base of your `Options` object. In most cases
     * this information be safely ignored; I included it for completeness. See
     * src/dDefaultOptions.ahk for more information.
     *
     * @param {Boolean} [Options.AdjustObject = false] - If `Options.AdjustObject == true`, then `WrapText`
     * expects `Context` to be an object with a `Text` property and a `Move` method, such as a `Gui.Control`
     * object. Before `WrapText` exits, `WrapText` removes any soft hyphens from the result string, then
     * sets the `Context.Text` property with the result string, then calls `Context.Move`. The width
     * used is `Options.MaxExtent`. The height used depends on the value of `Options.MeasureLines`. If
     * `Options.MeasureLines` is nonzero, then `OutHeight` is set with the cumulative height of the
     * string, and its value gets used. If `Options.MeasureLines` is false, the height is set to
     * `sz.H * LineCount` where `sz` is the  {@link Display_Size} object produced from the last `GetTextExtentExPoint`
     * function call. In general this will be pretty close to the true height of the string, but should
     * be expected to be slightly off.
     *
     * @param {String} [Options.BreakChars = "-"] - `BreakChars` is a list of characters that defines what
     * characters are valid breakpoints for splitting a line other than a space or tab. Do not include
     * any separators between the characters. Do not escape any characters. See the function description
     * for a description of `WrapText`'s process.
     *
     * @param {Boolean} [Options.HyphenateLetters = true] - When true, `WrapText` hyphenates the line if
     * the last character in the line causes `IsAlpha(char)` to return true. This option is only invoked
     * if a line does not contain any break characters between `Options.MinExtent` and `Options.MaxExtent`.
     *
     * @param {Boolean} [Options.HyphenateNumbers = false] - When true, `WrapText` hyphenates the line if
     * the last character in the line causes `IsNumber(char)` to return true. This option is only invoked
     * if a line does not contain any break characters between `Options.MinExtent` and `Options.MaxExtent`.
     *
     * @param {Integer} [Options.MaxExtent] - The maximum width of a line in pixels. This is optional when
     * `Context` is an object with a `GetPos` method, such as a `Gui.Control` object. If `Options.MaxExtent`
     * is unset, `Context.GetPos(, , &MaxExtent)` is called. The maximum width must be at least three times
     * the width of a "W" character in the device context.
     *
     * @param {Boolean|Array} [Options.MeasureLines] - When a nonzero value, `WrapText` will measure
     * each line during processing. This allows `WrapText` to set `OutHeight` with the correct height
     * of the string, and `OutWidth` with an accurate width of the string (see the note about this
     * in the function description). If `Options.MeasureLines` is an array object, `WrapText` will also
     * add each  {@link Display_Size} object that is produced from the measurement to that array. For large strings
     * or many consecutive function calls, you should set the capacity of the array to what you expect
     * it will need prior to calling `WrapText`. If `WrapText` is false, no additional measurements occur.
     *
     * @param {Number} [Options.MinExtent] - Sets the minimum width of a line, directing {@link WrapText}
     * to require each line to be at least the minimum before inserting a line break.
     *
     * If `Options.MinExtent` is between 0 and 1, the minimum width of a line is
     * `Ceil(Options.MinExtent * Options.MaxExtent)`. Use this to specify a minimum width as a proportion
     * of the maximum. If `Options.MinExtent` is greater than 1, `Options.MinExtent` is used as the
     * minimum width of a line, in pixels.
     *
     * `Options.MinExtent` directs `WrapText` to break each line at an extent point no less than the minimum.
     * This is useful in most situations, but particularly in situations where the input string contains
     * words/substrings that are generally pretty long relative to `Options.MaxExtent`. `WrapText`'s default
     * behavior might cause a line to be very short, in a way that would be aesthetically unnatural or
     * displeasing. When `Options.MinExtent` is set, if a substring does not contain a valid break character
     * between `Options.MinExtent` and `Options.MaxExtent`, then it will wrap the line at or around
     * `Options.MaxExtent` (depending on the values of the other options) as if there were no break
     * characters in the entire line. The example below depicts the default behavior without
     * `Options.MinExtent`.
     *
     * @example
     * Ctrl := (G := Gui()).AddText()
     * Ctrl.Text := 'She sang supercalifradulisticexpialidocious then went on her merry way.'
     * hdc := DllCall('GetDC', 'Ptr', Ctrl.hWnd, 'Ptr')
     * sz := GetTextExtentPoint32(hdc, 'She sang supercalifradulisticexpialidoc')
     * LineCount := WrapText(Ctrl, &Str, { MaxExtent: sz.W, AdjustObject: true })
     * Split := StrSplit(Ctrl.Text, '`r`n')
     * MsgBox(Split[1]) ; She sang
     * MsgBox(Split[2]) ; supercalifradulisticexpialidocious then
     * MsgBox(Split[3]) ; went on her merry way.
     * @
     *
     * @param {String} [Options.EndOfLine = "`r`n"] - The end of line character(s) to use.
     *
     * @param {Boolean} [Options.ZeroWidthSpace = true] - When true, if the input text contains Zero Width
     * Space characters (code point U+200B), they will be treated as soft hyphens and will be used as
     * a break character. When a line breaks at a Zero Width Space character, a visible hyphen is placed
     * after the Zero Width Space character and the line wraps after the hyphen. When false, Zero Width
     * Space characters are ignored and when a hard break is necessary, `WrapText` breaks the line at the
     * greatest extent which satisfies the other options. When false and if hyphens are used, a substring
     * may be hyphenated at any position in the word. Generally this should be left true; if no U+200B
     * characters are present in the input string, `WrapText` adjusts its process to avoid using resources
     * searching for them.
     *
     * @param {VarRef} [OutWidth] - A variable that will receive the width of the line with the greatest
     * width in the result string.
     *
     * @param {VarRef} [OutHeight] - A variable that will receive the cumulative height of each line.
     * This only receives a value if `Options.MeasureLines` is nonzero.
     *
     * @returns {Integer} - The number of lines the text was split into.
     */
    static Call(Context, &Str?, Options?, &OutWidth?, &OutHeight?) {
        local Pos
        options := WrapText.Options(Options ?? unset)
        if IsObject(Context) {
            if HasProp(Context, 'hWnd') {
                ; If MaxExtent is unset, use the width of the control.
                if Options.MaxExtent {
                    MaxExtent := Options.MaxExtent
                } else {
                    Context.GetPos(, , &MaxExtent)
                }
                if IsSet(Str) {
                    Text := RegExReplace(Str, '\R+', ' ')
                } else if IsObject(Context.Text) {
                    throw TypeError('``Context.Text`` returned an object.',
                    , 'Type(Context.Text) == ' Type(Context.Text))
                } else {
                    Text := RegExReplace(Context.Text, '\R+', ' ')
                }
                font_context := SelectFontIntoDc(Context.hWnd)
                hdc := font_context.hdc
            } else {
                _Throw(1, A_LineNumber, A_ThisFunc)
            }
        } else if IsNumber(Context) {
            if !IsSet(Str) || !Options.MaxExtent {
                _Throw(2, A_LineNumber, A_ThisFunc)
            }
            MaxExtent := Options.MaxExtent
            hdc := Context
            Text := RegExReplace(Str, '\R+', ' ')
        } else {
            _Throw(1, A_LineNumber, A_ThisFunc)
        }

        ; Set MinExtent
        if IsNumber(Options.MinExtent) {
            if Options.MinExtent < 1 {
                MinExtent := Ceil(MaxExtent * Options.MinExtent)
            } else {
                MinExtent := Options.MinExtent
            }
        } else {
            MinExtent := 0
        }

        ; Initialize the buffers
        fitBuf := Buffer(4)
        Extent := Display_IntegerArray(StrLen(Text))
        sz := Display_Size()

        ; Measure the width of a hyphen
        hyphen := '-'
        if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
            , hdc, 'Ptr', StrPtr(hyphen), 'Int', 1, 'Ptr', sz, 'Int') {
            throw OSError()
        }
        hyphen := sz.W

        ; `MaxExtent` must at least be large enough such that the loops can iterate once or twice
        ; before reaching the beginning of the substring.
        if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
            , hdc, 'Ptr', StrPtr('W'), 'Int', 1, 'Ptr', sz, 'Int') {
            throw OSError()
        }
        if MaxExtent < sz.W * 3 {
            throw ValueError('``Options.MaxExtent`` must be at least three times the width of "W" in the device'
            ' context.', -1, '``Options.MaxExtent``: ' MaxExtent '; Function minimum: ' (sz.W * 3))
        }

        ; Set the condition determining whether a hyphen is used.
        if Options.HyphenateLetters {
            Hyphenate := Options.HyphenateNumbers
            ? () => IsAlnum(SubStr(Text, Pos, 1))
            : () => IsAlpha(SubStr(Text, Pos, 1))
            _Proc_0 := _Proc_0_1
        } else if Options.HyphenateNumbers {
            Hyphenate := () => IsNumber(SubStr(Text, Pos, 1))
            _Proc_0 := _Proc_0_1
        } else {
            _Proc_0 := _Proc_0_0
        }

        ; Check the string for the presence of break characters
        BreakChars := ''
        z := InStr(Text, '`t') ? 1 : 0
        if Options.BreakChars {
            _BreakChars := ''
            for ch in StrSplit(Options.BreakChars) {
                if InStr(Text, ch) {
                    _BreakChars .= ch
                }
            }
            if Options.RespectSoftHyphen && InStr(Text, Chr(0x200B)) {
                _BreakChars .= Chr(0x200B)
                _Proc_B := _Proc_B_1
            } else {
                _Proc_B := _Proc_B_0
            }
            if _BreakChars {
                _BreakChars := RegExReplace(StrReplace(_BreakChars, '\', '\\'), '(\]|-)', '\$1')
                BreakChars := '([' _BreakChars '])[^' _BreakChars ']*$'
                z += 2
            }
        } else if Options.RespectSoftHyphen && InStr(Text, Chr(0x200B)) {
            BreakChars := '([' Chr(0x200B) '])[^' Chr(0x200B) ']*$'
            z += 2
            _Proc_B := _Proc_B_1
        } else {
            _Proc_B := _Proc_B_0
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

        if Options.MeasureLines {
            OutHeight := 0
            ; I half the hyphen's width here to limit the number of instances when a line gets measured
            ; and its width exceed `Options.MaxExtent`, causing some steps to be repeated. When preemptively
            ; testing the width of a line, if I add the entire width of a hyphen to the line's width, this
            ; can occasionally cause `WrapText` to skip a breakpoint that should have been used due to the
            ; imprecise measurement. If I don't test the lines, or test the lines by adding a width that
            ; is too small, there is a greater likelihood that some steps must be repeated. I don't
            ; expect any fonts are designed in a way that more than half of the hyphen's width is tucked
            ; into the previous font's space, and so I figure this is an acceptable approach.
            hyphen *= 0.5
            if Options.MeasureLines is Array {
                Measurements := Options.MeasureLines
                Set := _Set_1
            } else {
                Set := _Set_2
            }
        } else {
            Set := _Set_3
        }

        eol := Options.EndOfLine
        LineCount := 0
        OutWidth := 0
        Str := ''
        VarSetStrCapacity(&Str, StrLen(Text))

        ; Core loop
        loop {
            Len := StrLen(Text)
            ptr := StrPtr(Text)
            if !DllCall('Gdi32.dll\GetTextExtentExPoint'
                , 'ptr', hdc                ; Device context
                , 'ptr', ptr                ; String to measure
                , 'int', Len                ; String length in WORDs
                , 'int', MaxExtent          ; Maximum width
                , 'ptr', fitBuf             ; To receive number of characters that can fit
                , 'ptr', Extent             ; A buffer to receives partial string extents.
                , 'ptr', sz                 ; To receive the dimensions of the string.
                , 'ptr'
            ) {
                throw OSError()
            }
            if (fit := NumGet(fitBuf, 0, 'uint')) >= Len {
                break
            }
            LineCount++
            if Proc() {
                break
            }
        }

        ; Add last piece to the string
        if Text {
            Set(StrLen(Text))
            Str := Trim(Str, '`r`n`s`t')
            LineCount++
        }

        ; Release dc, disable error handler
        if IsObject(Context) {
            if Options.AdjustObject {
                Context.Text := Str
                if Options.MeasureLines {
                    Context.Move(, , MaxExtent, OutHeight)
                } else {
                    Context.Move(, , MaxExtent, sz.H * LineCount)
                }
            }
            font_context()
        }

        return LineCount

        ; No break characters or whitespace
        ; With hyphens
        _Proc_0_1() {
            Pos := NumGet(fitBuf, 0, 'uint')
            ; The loop checks if a hyphen should be added given the last character, and if so,
            ; checks if adding the hyphen will possibly cause the line to exceed `MaxExtent`.
            loop Pos - 1 {
                if Hyphenate() {
                    if Extent[Pos] + hyphen <= MaxExtent {
                        if Set(Pos, '-') {
                            Pos--
                        } else {
                            return _TrimRight()
                        }
                    } else {
                        Pos--
                    }
                } else {
                    Set(Pos)
                    return _TrimRight()
                }
            }
        }
        ; No break characters or whitespace
        ; Without hyphens
        _Proc_0_0() {
            Set(NumGet(fitBuf, 0, 'uint'))
            return _TrimRight()
        }
        ; Has spaces or tabs
        _Proc_1(ch) {
            if (Pos := InStr(SubStr(Text, 1, fit), ch, , , -1)) && Extent[Pos] >= MinExtent {
                return _Proc_W()
            } else {
                return _Proc_0()
            }
        }
        ; Has break characters
        _Proc_2() {
            if (Pos := RegExMatch(SubStr(Text, 1, fit), BreakChars)) && Extent[Pos] >= MinExtent {
                return _Proc_B()
            } else {
                return _Proc_0()
            }
        }
        ; Has either spaces / tabs, and break characters
        _Proc_3(ch) {
            Part := SubStr(Text, 1, fit)
            Pos := Max(Pos_B := RegExMatch(Part, BreakChars), Pos_W := InStr(Part, ch, , , -1))
            if !Pos || Extent[Pos] < MinExtent {
                return _Proc_0()
            } else if Pos_W > Pos_B {
                return _Proc_W()
            } else {
                return _Proc_B()
            }
        }
        ; Has spaces and tabs
        _Proc_4() {
            Part := SubStr(Text, 1, fit)
            Pos := Max(InStr(Part, '`t', , , -1), InStr(Part, '`s', , , -1))
            if Pos && Extent[Pos] >= MinExtent {
                return _Proc_W()
            } else {
                return _Proc_0()
            }
        }
        ; Has spaces, tabs, and break characters
        _Proc_5() {
            Part := SubStr(Text, 1, fit)
            Pos := Max(
                Pos_B := RegExMatch(Part, BreakChars)
              , Pos_W := Max(
                    InStr(Part, '`t', , , -1)
                  , InStr(Part, '`s', , , -1)
                )
            )
            if !Pos || Extent[Pos] < MinExtent {
                return _Proc_0()
            } else if Pos_W > Pos_B {
                return _Proc_W()
            } else {
                return _Proc_B()
            }
        }
        ; Breaking at a break character
        ; With soft hyphen
        _Proc_B_1() {
            if NumGet(ptr, (Pos - 1) * 2, 'str') == 0x200B {
                ; If adding the hyphen does not cause the width to exceed the max
                if Extent[Pos] + hyphen <= MaxExtent {
                    if Set(Pos, '-') {
                        ; Adjust `fit` to just before the ZWS, then re-check the string
                        fit := Pos - 1
                        return Proc()
                    }
                } else {
                    fit := Pos - 1
                    return Proc()
                }
            } else {
                Set(Pos)
            }
            return _TrimRight()
        }
        ; Breaking at a break character
        ; Without soft hyphen
        _Proc_B_0() {
            Set(Pos)
            return _TrimRight()
        }
        ; Breaking at a whitespace character
        _Proc_W() {
            _TrimLeft()
            ; If after trimming the whitespace, the length of the line is too short
            if Extent[Pos - 1] < MinExtent {
                return _Proc_0()
            } else {
                Set(Pos - 1)
                return _TrimRight()
            }
        }
        _ReleaseDC(Thrown, *) {
            DllCall('ReleaseDC', 'Ptr', Context.hWnd, 'Ptr', hdc, 'Int')
            OnError(_ReleaseDC, 0)
            throw Thrown
        }
        ; Measure string, add size object to array
        _Set_1(SetPos, AddHyphen := '') {
            Part := SubStr(Text, 1, SetPos) AddHyphen
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', hdc
                , 'Ptr', StrPtr(Part)
                , 'Int', StrLen(Part)
                , 'Ptr', measure_sz := Display_Size()
                , 'Int'
            ) {
                if measure_sz.W > MaxExtent {
                    return 1
                }
                Measurements.Push(measure_sz)
                OutWidth := Max(OutWidth, measure_sz.W)
                OutHeight += sz.H
                Str .= Part eol
            } else {
                throw OSError()
            }
        }
        ; Measure string, no array
        _Set_2(SetPos, AddHyphen := '') {
            Part := SubStr(Text, 1, SetPos) AddHyphen
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', hdc
                , 'Ptr', StrPtr(Part)
                , 'Int', StrLen(Part)
                , 'Ptr', sz
                , 'Int'
            ) {
                if sz.W > MaxExtent {
                    return 1
                }
                OutWidth := Max(OutWidth, sz.W)
                OutHeight += sz.H
                Str .= Part eol
            } else {
                throw OSError()
            }
        }
        ; Don't measure string
        _Set_3(SetPos, AddHyphen := false) {
            if AddHyphen {
                if Extent[SetPos] + hyphen > MaxExtent {
                    return 1
                }
                Part := SubStr(Text, 1, SetPos) '-'
                OutWidth := Max(OutWidth, Extent[SetPos] + hyphen)
                Str .= Part eol
            } else {
                Part := SubStr(Text, 1, SetPos)
                OutWidth := Max(OutWidth, Extent[SetPos])
                Str .= Part eol
            }
        }
        _Throw(Id, Line, Fn) {
            switch Id {
                case 1: err := TypeError('``Context`` must be either a number representing a handle to'
                    ' a device context, or an object with an ``hWnd`` property.', -2, 'Type(Context) == '
                    Type(Context))
                case 2:
                    if IsSet(Str) {
                        Extra := '``Options.MaxExtent`` is unset.'
                    } else if Options.MaxExtent {
                        Extra := '``Str`` is unset.'
                    } else {
                        Extra := '``Str`` and ``Options.MaxExtent`` are unset.'
                    }
                    err := UnsetError('``Str`` and ``Options.MaxExtent`` must be set when ``Context`` is a number.', -2, Extra)
            }
            err.What := Fn
            err.Line := Line
            throw err
        }
        _TrimRight() {
            ; Trim whitespace right
            while NumGet(ptr, Pos * 2, 'str') < 33 {
                Pos++
                if Pos > Len {
                    Text := ''
                    return 1
                }
            }
            Text := SubStr(Text, Pos + 1)
        }
        _TrimLeft() {
            while NumGet(ptr, (Pos - 2) * 2, 'str') < 33 {
                Pos--
            }
        }
    }

    /**
     * @classdesc - Handles the input options.
     */
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.AdjustObject := false
            proto.BreakChars := '-'
            proto.EndOfLine := '`r`n'
            proto.HyphenateLetters := true
            proto.HyphenateNumbers := true
            proto.MaxExtent := ''
            proto.MeasureLines := false
            proto.MinExtent := ''
            proto.RespectSoftHyphen := true
        }

        __New(options?) {
            if IsSet(options) {
                if IsSet(WrapTextConfig) {
                    for prop in WrapText.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        } else if HasProp(WrapTextConfig, prop) {
                            this.%prop% := WrapTextConfig.%prop%
                        }
                    }
                } else {
                    for prop in WrapText.Options.Prototype.OwnProps() {
                        if HasProp(options, prop) {
                            this.%prop% := options.%prop%
                        }
                    }
                }
            } else if IsSet(WrapTextConfig) {
                for prop in WrapText.Options.Prototype.OwnProps() {
                    if HasProp(WrapTextConfig, prop) {
                        this.%prop% := WrapTextConfig.%prop%
                    }
                }
            }
            if this.HasOwnProp('__Class') {
                this.DeleteProp('__Class')
            }
        }
    }
}

class InsertHyphenationPoints {
    /**
     * @description - `InsertHyphenationPoints` uses a simple heuristic to insert more natural hyphenation
     * points into the input text. `InsertHyphenationPoints` uses character 0x200B, "Zero Width Space".
     * While not every hyphenation point will feel completely natural, the result with `WrapText`
     * will be much more consistent with what people expect regarding hyphenated words. This should
     * be used with strings that consist of mostly English words. Because the heuristic approximates
     * syllable boundaries, `InsertSoftHyphens` is not intended to be used with non-word text.
     * @param {VarRef} Str - This variable should contain the string to have soft hyphens inserted
     * into. It will be modified directly
     * @param {Integer} [Mode = 1] - Either 1 or 2. At this time, don't use 2. It needs more work.
     */
    static Call(&Str, Mode := 1) {
        Str := RegExReplace(Str, this.Pattern[Mode], '${first}' Chr(0x200B) '${second}')
    }
    static GetPattern(which) {
        switch which, 0 {
            case 1: return (
                'iJ)'
                '(?:'
                    '(?<first>' this.vowel ')' this.boundary '(?<second>' this.consonant ')'
                    '|(?<first>' this.consonant ')' this.boundary '(?<second>' this.vowel ')'
                    '|(?<first>' this.vowel this.clusters this.consonant ')' this.boundary '(?<second>' this.consonant ')'
                    '|(?<first>' this.consonant this.vowel ')' this.boundary '(?<second>' this.consonant ')'
                    '|' this.clusters '(?<first>' this.consonant ')' this.boundary '(?<second>' this.consonant this.vowel ')'
                ')'
            )
            case 2: return (
                'iJ)'
                '(?:'
                    '(?<first>' this.vowel ')' this.boundary '(?<second>' this.consonant this.vowel ')'
                    '|(?<first>' this.vowel this.clusters this.consonant ')' this.boundary '(?<second>' this.consonant this.vowel ')'
                    '|(?<first>' this.consonant this.vowel this.clusters this.consonant ')' this.boundary '(?<second>' this.consonant ')'
                ')'
            )
        }
    }
    static Vowel := '[aeiouy]'
    , Consonant := '[bcdfghjklmnpqrstvwz]'
    , Clusters := '(?!th|ch|ph|sh|wh|qu|gh|ck|ng|wr)' ; words should not be split between these
    , Boundary := '(?<!\W|^)(?<!\W.|^.)(?!\W|$)(?!.\W|.$)' ; don't break too close to non-alphanumeric / beginning / end
    , Pattern := [ this.GetPattern(1), this.GetPattern(2) ]
}
