
#SingleInstance force
#include test-Base.ahk
#include ..\src\WrapText.ahk

/**
    This is a non-visual test using a random string.
    This test currently validates these components:
    - The function runs successfully with `Context` as a control and `Context` as an hdc.
    - `Option.MaxExtent` correctly causes `WrapText` to return a string that has a width no greater
    than the value.
    -----
    Although I believe `WrapText`'s wrapping logic does what it is designed to do, this test does
    not validate whether `WrapText` chose the correct wrap position given the string and options.

    The test takes about 20 seconds to run on my machine, performing 1152 tests.
 */

if A_LineFile == A_ScriptFullPath {
    if test_WrapText(false) {
        test_WrapText.WriteOut(test_WrapText.Problems)
        msgbox('problems: ' test_WrapText.Problems.Length)
    } else {
        msgbox('no problems. ' test_WrapText.WrapTextCallCount ' iterations completed.')
    }
}

class test_WrapText extends test_Base {
    static PathOut := A_MyDocuments '\test-output_WrapText.json'
    , PathIn := 'test-content_WrapText.txt'
    , PathTemp := A_ScriptDir '\temp-output.txt'
    , SetThreadDpiAwareness := -4
    , Font := [ '', 'Mono', 'Aptos' ]
    ; While debugging I'll use this over the larger array to save time
    , FontOpt := [ '' ]
    ; , FontOpt := [ '', 'bold', 'italic', 'strike', 'underline' ]
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
    , BreakChar := ')]>\/:-'
    , Problems := []
    , Result := []

    static Call(TempOutput := false) {
        local _opt, _size, _quality, _weight, _color, _family, _maxExtent, _breakChar, _string, G
        , BaseString, copy, hdc, Str, Edt, Extent, index_GetString, LineCount, i, Width, Height
        , ResultWidth, ResultHeight, _minExtent
        , whitespace := ['`n', '`s', '`t', '`r']
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
        _Loop(_hdc)

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
                WrapTextConfig.BreakChars := _breakChar
                WrapTextConfig.MinExtent := _minExtent
                WrapTextConfig.MeasureLines := []
                if test_WrapText.WrapTextCallCount == 10 {
                    sleep 1
                }
                LineCount := WrapText(Edt, &Str,  , &ResultWidth, &ResultHeight)
                if TempOutput {
                    this.WriteTemp(this.PathTemp, &Str)
                }
                if ResultWidth > _maxExtent {
                    this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'ResultWidth > _maxExtent')
                }

                ; Testing `WrapText` for short lines is complicated and requires comparison with
                ; the input string, which I have not written yet.

                ; else {
                ;     hdc := DllCall('GetDC', 'ptr', Edt.hWnd, 'ptr')
                ;     if !hdc {
                ;         throw OSError()
                ;     }
                ;     Split := StrSplit(Str, '`r`n')
                    ; loop Split.Length - 1 {
                    ;     sz := _GetTextExtentPoint32(hdc, Split[A_Index])
                    ;     w1 := sz.W
                    ;     w2 := Ceil(_minExtent * _maxExtent)
                    ;     if sz.W < Ceil(_minExtent * _maxExtent) {
                    ;         ; When _minExtent == 0.9, there's a chance that `WrapText` must wrap a line
                    ;         ; at a shorter width than the minimum.
                    ;         chr_sz := _GetTextExtentPoint32(hdc, SubStr(Split[A_Index+1], 1, 1))
                    ;         if chr_sz.W + sz.W < _maxExtent {
                    ;             if IsAlnum(SubStr(Split[A_Index + 1], 1, 1)) {
                    ;                 hyphen := '-'
                    ;                 if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'ptr'
                    ;                     , hdc, 'ptr', StrPtr(hyphen), 'int', 1, 'ptr', lpSize := Buffer(8)) {
                    ;                     throw OSError('``GetTextExtentPoint32`` failed.', , A_LastError)
                    ;                 }
                    ;                 if NumGet(lpSize, 0, 'uint') + chr_sz.W + sz.W < _maxExtent {
                    ;                     this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'sz.W < _minExtent')
                    ;                     return 1
                    ;                 }
                    ;             } else {
                    ;                 this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'sz.W < _minExtent')
                    ;                 return 1
                    ;             }
                    ;         }
                    ;     }
                    ; }
                    ; if !DllCall('ReleaseDC', 'ptr', Edt.hWnd, 'ptr', hdc, 'int') {
                    ;     throw OSError()
                    ; }
                ; }
            }
        }
        _hdc() {
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
                WrapTextConfig.BreakChars := _breakChar
                WrapTextConfig.MinExtent := _minExtent
                WrapTextConfig.MeasureLines := []
                WrapTextConfig.MaxExtent := _maxExtent
                context := SelectFontIntoDc(Edt.hWnd)
                Str := _string
                LineCount := WrapText(context.hdc, &Str, , &ResultWidth, &ResultHeight)
                context()
                if TempOutput {
                    this.WriteTemp(this.PathTemp, &Str)
                }
                if ResultWidth > _maxExtent {
                    this.AddProblem(A_LineNumber, A_ThisFunc, A_LineFile, __GetObj(), 'ResultWidth > _maxExtent')
                }
            }
        }

        _GetString_NoBreak() {
            copy := _string := RegExReplace(BaseString, '[`s`t`r`n' RegExReplace(StrReplace(_breakChar, '\', '\\'), '(\]|-)', '\$1') ']', '')
        }
        _GetString_OnlySpace() {
            _string := ''
            delta := 1
            z := 1
            loop 199 {
                _string .= SubStr(Copy, delta, 4) whitespace[z]
                if ++z > whitespace.Length {
                    z := 1
                }
                delta += 5
            }
        }
        _GetString_OnlyBreak() {
            _string := ''
            delta := 1
            split := StrSplit(_breakChar)
            z := 1
            loop 199 {
                _string .= SubStr(copy, delta, 4) split[z]
                if ++z > Split.Length {
                    z := 1
                }
                delta += 5
            }
        }
        _GetString_Both() {
            _string := ''
            delta := 1
            split := StrSplit(_breakChar)
            split.Push(whitespace*)
            z := 1
            loop 199 {
                _string .= SubStr(copy, delta, 4) split[z]
                if ++z > split.Length {
                    z := 1
                }
                delta += 5
            }
        }
        _GetMinMaxExtent(ctrl) {
            local hdc, hyphen, lpSize, W
            context := SelectFontIntoDc(ctrl.hWnd)
            hyphen := '-'
            if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'ptr'
                , context.hdc, 'ptr', StrPtr(hyphen), 'int', 1, 'ptr', lpSize := Buffer(8)) {
                throw OSError('``GetTextExtentPoint32`` failed.', , A_LastError)
            }
            hyphen := NumGet(lpSize, 0, 'uint')
            W := 'W'
            if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'ptr'
                , context.hdc, 'ptr', StrPtr(W), 'int', 1, 'ptr', lpSize) {
                throw OSError('``GetTextExtentPoint32`` failed.', , A_LastError)
            }
            context()
            return NumGet(lpSize, 0, 'uint') * 3 + hyphen
        }
        ; need to replace with SelectFontIntoDc
        ; _GetTextExtentPoint32(hdc, Line) {
        ;     ; Measure the text
        ;     context := SelectFontIntoDc(hdc)
        ;     if DllCall('Gdi32.dll\GetTextExtentPoint32'
        ;         , 'ptr', hdc
        ;         , 'ptr', StrPtr(Line)
        ;         , 'int', StrLen(Line)
        ;         , 'ptr', sz := Display_Size()
        ;         , 'int'
        ;     ) {
        ;         return sz
        ;     } else {
        ;         throw OSError()
        ;     }
        ; }
        __GetObj() {
            return { string: _string, opt: _opt, size: _size, quality: _quality, weight: _weight
            , color: _color, family: _family, MaxExtent: _maxExtent, breakChar: _breakChar
            , index_GetString: index_GetString, LineCount: LineCount, Options: WrapTextConfig
            , Edit: Edt, ResultWidth: ResultWidth, ResultHeight: ResultHeight, MinExtent: _minExtent }
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

class WrapTextConfig {
    static MeasureLines := []
}
