
#SingleInstance force
#Include test_Base.ahk
#Include ..\lib\Display_Text.ahk


if test_WrapText(false) {
    test_WrapText.WriteOut(test_WrapText.Problems)
    test_WrapText.OpenEditor()
}

class test_WrapText extends test_Base {
    static PathOut := A_MyDocuments '\test-output_WrapText.json'
    , PathIn := 'test-content_WrapText.txt'
    , PathTemp := A_ScriptDir '\temp-output.txt'
    , SetThreadDpiAwareness := -4
    , Font := [ '', 'Mono', 'Aptos' ]
    , FontOpt := [ '', 'bold', 'italic', 'strike', 'underline' ]
    , FontSize := [ 4, 76 ]
    , FontQuality := [ 1, 5 ]
    , FontWeight := [ 100, 950 ]
    , FontColor := 'Black'
    ; The items that are functions: `n` receives the minimum `MaxExtent` allowed by `WrapText`.
    , MaxExtent := [ (n) => n, (n) => 1.1 * n, 1980 ] ; pixels
    , MinExtent := [ 0.7, 0.9 ]
    ; Characters which are typically followed by a space like commas, periods, and semicolons are
    ; not effective break characters, don't use them in live code unless you expect the possibility
    ; that one is not followed by a whitespace character.
    , BreakChar := ')]>\/:-\'
    , Problems := []
    , Result := []

    static Call(TempOutput := false) {
        local _opt, _size, _quality, _weight, _color, _family, _maxExtent, _breakChar, _string, G
        , BaseString, copy, hDC, Str, Edt, Extent, index_GetString, LineCount, i, Width, Height
        , ResultWidth, LineHeight, _minExtent
        if this.SetThreadDpiAwareness {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.SetThreadDpiAwareness, 'ptr')
        }
        this.LoopCount := 0
        this.WrapTextCallCount := 0
        G := this.G := Gui('+Resize -DPIScale')
        Edt := this.CtrlEdit := G.Add('Edit', '+Wrap -HScroll')
        if FileExist(this.PathIn) {
            BaseString := this.BaseString := FileRead(this.PathIn)
        } else {
            BaseString := ''
            r := 126 - 32
            loop 1000 {
                if Random() > 0.5 {
                    ; Standard Western keyboard characters
                    BaseString .= Chr(Ceil(Random() * r + 32))
                } else {
                    ; Supplementary unicode characters. Even if none are installed on the system, it
                    ; will still serve its purpose here.
                    BaseString .= Chr(Ceil(Random() * 100) + 65336)
                }
            }
            this.BaseString := BaseString
            f := FileOpen(this.PathIn, 'w')
            f.Write(BaseString)
            f.Close()
        }
        GetString := [
            _GetString_NoBreak
          , _GetString_OnlySpace
          , _GetString_OnlyBreak
          , _GetString_Both
        ]
        _breakChar := this.BreakChar
        _color := this.FontColor
        _Loop(_Control)

        return this.Problems.Length

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
                            loop this.Font.Length {
                                _family := this.Font[A_Index]
                                loop this.MaxExtent.Length {
                                    _maxExtent := this.MaxExtent[A_Index]
                                    loop this.MinExtent.Length {
                                        _minExtent := this.MinExtent[A_Index]
                                        this.LoopCount++
                                        if Callback() {
                                            return
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
            Edt.SetFont(Format('{} c{} s{} w{} q{}', _opt, _color, _size, _weight, _quality), _family || unset)
            if _maxExtent is Func {
                _maxExtent := _maxExtent(_GetMinMaxExtent(Edt))
            }
            Edt.Move(, , _maxExtent)
            if _breakChar {
                index_GetString := 0
                for fn in GetString {
                    this.WrapTextCallCount++
                    index_GetString++
                    fn()
                    _Proc()
                }
            } else {
                this.WrapTextCallCount++
                index_GetString := 1
                GetString[1]()
                _Proc()
            }
            _Proc() {
                Edt.Text := _string
                len := StrLen(_string)
                Str := unset
                dWrapTextConfig.BreakChars := _breakChar
                dWrapTextConfig.MinExtent := _minExtent
                if this.WrapTextCallCount == 8 {
                    sleep 1
                }
                LineCount := WrapText(Edt, &Str, , &ResultWidth, &LineHeight)
                if TempOutput {
                    this.WriteTemp(this.PathTemp, &Str)
                }
                if ResultWidth > _maxExtent {
                    this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'ResultWidth > _maxExtent')
                } else {
                    hDC := DllCall('GetDC', 'ptr', Edt.hWnd, 'ptr')
                    if !hDC {
                        throw OSError()
                    }
                    Split := StrSplit(Str, '`r`n')
                    ; To-do: check the `copy` string for context. For example, if the last character
                    ; in a line is a letter, `HyphenateAlpha == true`, then that is only valid if
                    ; the line broke at a whitespace character.
                    loop Split.Length - 1 {
                        sz := _GetTextExtentPoint32(hDC, Split[A_Index])
                        if sz.Width < _minExtent * _maxExtent {
                            this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'sz.Width < _minExtent')
                            return 1
                        }
                    }
                    if !DllCall('ReleaseDC', 'Ptr', Edt.hWnd, 'Ptr', hDC, 'Int') {
                        throw OSError()
                    }
                }
            }
        }

        _GetString_NoBreak() {
            copy := _string := RegExReplace(BaseString, '[`s`t`r`n' RegExReplace(StrReplace(_breakChar, '\', '\\'), '(\]|-)', '\$1') ']', '')
        }
        _GetString_OnlySpace() {
            _string := ''
            delta := 1
            loop 199 {
                _string .= SubStr(Copy, delta, 4) (Random() > 0.5 ? (Random() > 0.5 ? '`n' : '`s') : '`t')
                delta += 5
            }
        }
        _GetString_OnlyBreak() {
            _string := ''
            delta := 1
            split := StrSplit(_breakChar)
            loop 199 {
                _string .= SubStr(copy, delta, 4) split[Ceil(Random() * split.Length)]
                delta += 5
            }
        }
        _GetString_Both() {
            _string := ''
            delta := 1
            split := StrSplit(_breakChar)
            loop 199 {
                _string .= SubStr(copy, delta, 4) (Random() > 0.5 ? split[Ceil(Random() * split.Length)] : '`s')
                delta += 5
            }
        }
        _GetMinMaxExtent(Ctrl_or_hDC) {
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
        _GetTextExtentPoint32(hDC, Line) {
            ; Measure the text
            if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', hDC
                , 'Ptr', StrPtr(Line)
                , 'Int', StrLen(Line)
                , 'Ptr', sz := SIZE()
                , 'Int'
            ) {
                return sz
            } else {
                throw OSError()
            }
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
                , 'ptr', Extent := IntegerArray(StrLen(Line) * 4)
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
        __GetObj() {
            return { string: _string, opt: _opt, size: _size, quality: _quality, weight: _weight
            , color: _color, family: _family, MaxExtent: _maxExtent, breakChar: _breakChar
            , index_GetString: index_GetString, LineCount: LineCount, Options: dWrapTextConfig
            , Edit: Edt, ResultWidth: ResultWidth, LineHeight: LineHeight, MinExtent: _minExtent }
        }
    }

    static AddProblem(Line, Fn, PathFile, Obj, Extra?) {
        this.Problems.Push({Line: Line, Fn: Fn, File: PathFile, Obj: Obj, Extra: Extra ?? unset })
    }

    static WriteTemp(Path, &Str) {
        f := FileOpen(Path, 'w')
        f.Write(Str)
        f.Close()
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

class dWrapTextConfig {
}


/*
    Outline

    Three iterations through the core test
    - With `Context` as `Gui.Control` leaving `Str` and `MaxExtent` unset
    - With `Context` as custom object with `hWnd`, `GetPos`, and `Text` properties. I'm not too
    familiar with device contexts, so I'm not sure what kind of non-AHK window to use. I bet Notepad
    would work fine, but I'll try it at another time. For now I'll stick with another `Gui.Control`
    - With `Context` as `hDc`. I'll just use the same one as one of the above

    Does DPI awareness context matter? Check and find out

    Params:
        - T1ext as Str
        - Test multiple `MaxExtent` values
            - A few very small values, and decide on a minimum or if a minimum is necessary
            - One very large one with a large string to go with it ( > system minimum large page size )
            - One with a `MaxExtent` larger than the length of the string
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
            - Context is Number value without MaxExtent / Str
            - Force an OS error with an invalid hDC

        Checking the string for break chars gets validated within the loop, no earlier steps
        are necessary

        Handling strings with supplemental unicode characters also is validated within the loop

    Process, loop:
            Add in some OutputDebug functions to the `_Proc_N` functions so they can be commented on
            or off as needed. Have them output a 1 or 0 as the result of a condition check. Actually,
            write functions to call a method on the `test_WrapText` object to add an object to the array.

            When exiting the function, I should be able to validate the result mathematically
                - Measure the entire block of text. If Width > MaxExtent, problem

                - Measure each line. While iterating the lines, compare each line with its subsequent
                line. If there is a valid break character at a position that, if that substring were
                included in the previous line the width of the line still would not exceed `MaxExtent`,
                then there's a calculation problem.
*/
