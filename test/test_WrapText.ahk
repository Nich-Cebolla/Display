
#SingleInstance force
#Include test_Base.ahk
#Include ..\lib\Display_Text.ahk


test_WrapText()

class test_WrapText extends test_Base {
    static PathOut := A_MyDocuments '\test-output_WrapText.json'
    , PathIn := 'test-content_WrapText.txt'
    , SetThreadDpiAwareness := -4
    , Font := [ '', 'Mono', 'Calisto', 'Aptos' ]
    , FontOpt := [ '', 'bold', 'italic', 'strike', 'underline' ]
    , FontSize := [ 4, 8, 12, 40, 76 ]
    , FontQuality := [ 1, 5 ]
    , FontWeight := [ 100, 200, 900, 950 ]
    , FontColor := [ 'Red', 'Black', 'White' ]
    ; The items that are functions: `n` receives the minimum `MaxWidth` allowed by `WrapText`.
    , MaxWidth := [ (n) => n, (n) => 1.1 * n, (n) => 5 * n, (n) => 10 * n, 1980, 1980 * 2, 1980 * 3 ] ; pixels
    ; Characters which are typically followed by a space like commas, periods, and semicolons are
    ; not effective break characters, don't use them in live code unless you expect the possibility
    ; that one is not followed by a whitespace character.
    , BreakChar := [
        ''
      , '-'
      , '\'         ; to make sure the slash gets escaped correctly
      , ';.,'       ; to make sure characters that are typically followed by space are handled correctly
      , ')]>\/:-'   ; to increase the variety of symbols tested
      , 'jqp-'      ; to test letters as break characters, which should be no different from any other character
    ]
    , Problems := []
    , Result := []

    static Call() {
        local _opt, _size, _quality, _weight, _color, _family, _maxWidth, _breakChar, _string
        , BaseString, copy, Width, Height, hDC, Str, Txt, Edt, lpnDx, index_GetString, LineCount
        if this.SetThreadDpiAwareness {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.SetThreadDpiAwareness, 'ptr')
        }
        _GetControls()
        BaseString := ''
        r := 126 - 32
        loop 1000 {
            if Random() > 0.5 {
                ; Standard Western keyboard characters
                BaseString .= Chr(Ceil(Random() * r + 32))
            } else {
                ; Supplementary unicode characters. Even if none are installed on the system, it
                ; will still serve its purpose here.
                Chr(Ceil(Random() * 100) + 65336)
            }
        }
        this.BaseString := BaseString
        GetString := [
            _GetString_NoBreak
          , _GetString_OnlySpace
          , _GetString_OnlyBreak
          , _GetString_Both
        ]
        _Loop(_Control)

        _Loop(Callback) {
            i := 0
            loop this.FontOpt.Length {
                _opt := this.FontOpt[A_Index]
                loop this.FontSize.Length {
                    _size := this.FontSize[A_Index]
                    loop this.FontQuality.Length {
                        _quality := this.FontQuality[A_Index]
                        loop this.FontWeight.Length {
                            _weight := this.FontWeight[A_Index]
                            loop this.FontColor.Length {
                                _color := this.FontColor[A_Index]
                                loop this.Font.Length {
                                    _family := this.Font[A_Index]
                                    loop this.MaxWidth.Length {
                                        _maxWidth := this.MaxWidth[A_Index]
                                        loop this.BreakChar.Length {
                                            _breakChar := this.BreakChar[A_Index]
                                            Callback()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        _Control() {
            Txt.SetFont(Format('{} c{} s{} w{} q{}', _opt, _color, _size, _weight, _quality), _family || unset)
            if _maxWidth is Func {
                _maxWidth := _maxWidth(_GetMinMaxWidth(Txt))
            }
            Txt.Move(, , _maxWidth)
            if _breakChar {
                index_GetString := 0
                for fn in GetString {
                    index_GetString++
                    fn()
                    _Proc()
                }
            } else {
                index_GetString := 1
                GetString[1]()
                _Proc()
            }
            _Proc() {
                txt.Text := _string
                Height := WrapText(Txt, &Str, , _breakChar, true, , &LineCount)
                ; I stopped here, next step was to figure out why sometimes StrSplit(Ctrl.Text, '`n', '`r') returns an empty array
                _Validate(Txt)
            }
        }

        _GetString_NoBreak() {
            copy := _string := RegExReplace(BaseString, '[`s`t`r`n' RegExReplace(StrReplace(_breakChar, '\', '\\'), '(\]|-)', '\$1') ']', '')
        }
        _GetString_OnlySpace() {
            _string := ''
            delta := 1
            loop 199 {
                _string .= SubStr(copy, delta, delta + 4) (Random() > 0.5 ? (Random() > 0.5 ? '`n' : '`s') : '`t')
                delta += 5
            }
        }
        _GetString_OnlyBreak() {
            _string := ''
            delta := 1
            split := StrSplit(_breakChar)
            loop 199 {
                _string .= SubStr(copy, delta, delta + 4) split[Ceil(Random() * split.Length)]
                delta += 5
            }
        }
        _GetString_Both() {
            _string := ''
            delta := 1
            split := StrSplit(_breakChar)
            loop 199 {
                _string .= SubStr(copy, delta, delta + 4) (Random() > 0.5 ? split[Ceil(Random() * split.Length)] : '`s')
                delta += 5
            }
        }
        _GetControls() {
            G := this.G := Gui('+Resize -DPIScale')
            Txt := this.CtrlText := G.Add('Text')
            Edt := this.CtrlEdit := G.Add('Edit')
        }
        _GetMinMaxWidth(Ctrl_or_hDC) {
            local hDC, hyphen, lpSize, W
            if IsObject(Ctrl_or_hDC) {
                if !(hDC := DllCall('GetDC', 'Ptr', Ctrl_or_hDC.hWnd)) {
                    throw OSError('``GetDC`` failed.', -1, A_LastError)
                }
            } else {
                hDC := Ctrl_or_hDC
            }
            hyphen := '-'
            if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
                , hDC, 'Ptr', StrPtr(hyphen), 'Int', 1, 'Ptr', lpSize := Buffer(8)) {
                throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
            }
            hyphen := NumGet(lpSize, 0, 'uint')
            W := 'W'
            if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr'
                , hDC, 'Ptr', StrPtr(W), 'Int', 1, 'Ptr', lpSize) {
                throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
            }
            if IsObject(Ctrl_or_hDC) {
                if !DllCall('ReleaseDC', 'Ptr', Ctrl_or_hDC.hWnd, 'Ptr', hDC, 'int') {
                    throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
                }
            }
            return NumGet(lpSize, 0, 'uint') * 3 + hyphen
        }
        _GetTextExtentEx(Ctrl_or_hDC, Line) {
            if IsObject(Ctrl_or_hDC) {
                if !(hDC := DllCall('GetDC', 'Ptr', Ctrl_or_hDC.hWnd)) {
                    throw OSError('``GetDC`` failed.', -1, A_LastError)
                }
            } else {
                hDC := Ctrl_or_hDC
            }
            Result := DllCall('Gdi32.dll\GetTextExtentExPoint'
                , 'ptr', hDC
                , 'ptr', StrPtr(Line)
                , 'int', StrLen(Line)
                , 'int', 0
                , 'ptr', 0
                , 'ptr', lpnDx := IntegerArray(StrLen(Line) * 4)
                , 'ptr', lpSize := Buffer(8)
                , 'ptr'
            )
            if IsObject(Ctrl_or_hDC) {
                if !DllCall('ReleaseDC', 'Ptr', Ctrl_or_hDC.hWnd, 'Ptr', hDC, 'int') {
                    throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
                }
            }
            if Result {
                Width := NumGet(lpSize, 0, 'int')
                ; Height := NumGet(lpSize, 4, 'int')
            } else {
                throw OSError('``GetTextExtentExPoint`` failed.', -1, A_LastError)
            }
        }
        _Validate(Ctrl) {
            Split := StrSplit(Ctrl.Text, '`n', '`r')
            if !Split.Length {
                sleep 1
            }
            Validate_breakChar := '[`s`t`r`n' RegExReplace(StrReplace(_breakChar, '\', '\\'), '(\]|-)', '\$1') ']'
            _GetTextExtentEx(Txt, Split[1])
            WidthPrevious := Width
            i := 1
            loop Split.Length - 1 {
                if _CompareWidth(i) {
                    return 1
                }
                _GetTextExtentEx(Txt, Split[++i])
                if WidthPrevious + lpnDx[n := ((Pos := RegExMatch(Split[i], Validate_breakChar)) ? Pos : 1)] <= _maxWidth {
                    this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj()
                    , 'WidthPrevious + lpnDx[' n '] <= _maxExtent); WidthPrevious: ' WidthPrevious
                    '`r`nLinePrevious:`r`n' Split[i - 1] '`r`nLine:`r`n' Split[i])
                    return 1
                }
                WidthPrevious := Width
            }
            if _CompareWidth(Split.Length) {
                return 1
            }
            Ctrl.GetPos(, , , &cH)
            if cH !== Height {
                this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'cH !== Height; ch: ' ch '; Height: ' Height)
            }


            _CompareWidth(index) {
                if Width > _maxWidth {
                    this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj()
                    , 'Width > _maxExtent; Width: ' Width '`r`nLine:`r`n' Split[index])
                    return 1
                }
            }
        }
        __GetObj() {
            return { string: _string, opt: _opt, size: _size, quality: _quality, weight: _weight
            , color: _color, family: _family, maxWidth: _maxWidth, breakChar: _breakChar
            , index_GetString: index_GetString, LineCount: LineCount, Width: Width, Height: Height
            , Text: Txt }
        }
    }

    static AddProblem(Line, Fn, PathFile, Obj, Extra?) {
        this.Problems.Push({Line: Line, Fn: Fn, File: PathFile, Obj: Obj, Extra: Extra ?? unset })
    }

    class Context {
        __New(hWnd) {
            this.hWnd := hWnd
        }
        Index := 1
        Text => this.__Text[this.Index]
        GetPos(&x, &y, &w, &h) {
            if test_WrapText.SetThreadDpiAwareness {
                return DllCall('SetThreadDpiAwarenessContext', 'ptr', test_WrapText.SetThreadDpiAwareness, 'ptr')
            }
            WinGetPos(&x, &y, &w, &h, this.hWnd)
        }
    }
}


/*
    Outline

    Three iterations through the core test
    - With `Context` as `Gui.Control` leaving `Str` and `MaxWidth` unset
    - With `Context` as custom object with `hWnd`, `GetPos`, and `Text` properties. I'm not too
    familiar with device contexts, so I'm not sure what kind of non-AHK window to use. I bet Notepad
    would work fine, but I'll try it at another time. For now I'll stick with another `Gui.Control`
    - With `Context` as `hDc`. I'll just use the same one as one of the above

    Does DPI awareness context matter? Check and find out

    Params:
        - T1ext as Str
        - Test multiple `MaxWidth` values
            - A few very small values, and decide on a minimum or if a minimum is necessary
            - One very large one with a large string to go with it ( > system minimum large page size )
            - One with a `MaxWidth` larger than the length of the string
            - Two or three values < system minimum large page size
        - Various break characters. Include backslash as a break character to make sure the escape
        is handled correctly.
        - AdjustControl is straightforward but may as well be included
        - Newline doesn't need tested

    Process, before loop:
        Errors:
        I'm going to hold off on validating the errors. The function is quite short and I can
        visually validate them.
            - Object doesn't have hWnd property
            - Context.Text returns an object
            - Force an OS error by using an invalid hWnd
            - String value
            - Context is Number value without MaxWidth / Str
            - Force an OS error with an invalid hDC

        Checking the string for break chars gets validated within the loop, no earlier steps
        are necessary

        Handling strings with supplemental unicode characters also is validated within the loop

    Process, loop:
            Add in some OutputDebug functions to the `_Proc_N` functions so they can be commented on
            or off as needed. Have them output a 1 or 0 as the result of a condition check. Actually,
            write functions to call a method on the `test_WrapText` object to add an object to the array.

            When exiting the function, I should be able to validate the result mathematically
                - Measure the entire block of text. If Width > MaxWidth, problem

                - Measure each line. While iterating the lines, compare each line with its subsequent
                line. If there is a valid break character at a position that, if that substring were
                included in the previous line the width of the line still would not exceed `MaxWidth`,
                then there's a calculation problem.
*/
