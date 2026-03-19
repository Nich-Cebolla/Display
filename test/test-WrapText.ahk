
#SingleInstance force
#include ..\templates\DisplayConfig.ahk

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
        OutputDebug(A_ScriptName ': problems: ' test_WrapText.Problems.Length '`n')
        if MsgBox(test_WrapText.Problems.Length ' problems occurred. Write details to ' test_WrapText.pathout '?', , 'YN') = 'Yes' {
            test_WrapText.WriteOut(test_WrapText.Problems)
            Run('"' test_WrapText.pathout '"')
        }
    } else {
        OutputDebug(A_ScriptName ': complete`n')
    }
}

class test_WrapText extends test_Base {
    static PathOut := A_Temp '\test-output_WrapText.json'
    , PathIn := 'test-content_WrapText.txt'
    , PathTemp := A_Temp '\temp-output.txt'
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

class test_Base {
    static PathEditor := 'code-insiders' ; change to your preferred text editing program. Enclose in quotes if path has spaces
    , Result := []

    static CheckResult() {
        Final := []
        for Obj in this.Result {
            if Obj.Result.Length {
                Final.Push(Obj)
            }
        }
        return Final.Length ? Final : ''
    }

    static OpenEditor() {
        Run(A_ComSpec ' /C ' this.PathEditor ' ' this.Pathout)
    }

    static WriteOut(Results) {
        if IsObject(Results) {
            stringify := PrettyStringify()
            stringify(Results, &str)
            Results := str
        }
        f := FileOpen(this.PathOut, 'w')
        f.Write(Results)
        f.Close()
    }
}
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/stringify
    Author: Nich-Cebolla
    License: MIT
*/

class PrettyStringify {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CharThresholdArray :=
        proto.CharThresholdItem :=
        proto.CharThresholdMap :=
        proto.CharThresholdObject :=
        4294967295
        proto.DepthThreshold := 0
    }
    /**
     * @description - Creates the function object.
     *
     * This function includes an option to format objects' string representations as single lines
     * instead of having a line break between each value.
     *
     * The option is a threshold. If the number of characters of an object's string representation
     * is less than the threshold, the object is represented as a single line with a single space
     * character separating the brackets and values. If the number of characters of an object's string
     * representation is greater than the threshold, then there is a line break between the brackets
     * and each value. This also applies to map key-value pairs. See the example code for an example
     * of what the output looks like.
     *
     * The example code yields the following output:
     * <pre>
     * {
     *   "Array": [ { "prop": "val" }, [ [ "key", "val" ] ], [ "val" ] ],
     *   "Map": [ [ "arr", [ "val" ] ], [ "map", [ [ "key", "val" ] ] ], [ "obj", { "prop": "val" } ] ],
     *   "Object": { "arr": [ "val" ], "map": [ [ "key", "val" ] ], "obj": { "prop": "val" } }
     * }
     * </pre>
     *
     * - Map objects are represented as `[ [ "key", val ] ]`.
     * - This does not work with objects that inherit from `ComValue`.
     * - This does not check for reference cycles.
     * - For Array and Map objects, only the enumerator is processed.
     * - For other object types, only the own properties are processed.
     * - Unset array indices are represented as *null* JSON value.
     *
     * @param {Object} [Options] - An object with options as property : value pairs.
     * @param {Integer} [Options.CharThreshold = 200] - If an object's string representation is
     * less than or equal to `Options.CharThreshold`, that object is represented as a single line.
     * If an object's string representation is greater than `Options.CharThreshold`, that object
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     *
     * This value applies to all object types and all map key-value pairs, unless the individual
     * threshold options is set. The individual options supercede this option.
     * @param {Integer} [Options.CharThresholdArray] - If set, and if an array's string representation is
     * less than or equal to `Options.CharThresholdArray`, that array is represented as a single line.
     * If an array's string representation is greater than `Options.CharThresholdArray`, that array
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     * @param {Integer} [Options.CharThresholdItem] - If set, and if the string representation for a
     * key-value pair of a map object is less than or equal to `Options.CharThresholdItem`, that item
     * is represented as a single line. If the item's string representation is greater than
     * `Options.CharThresholdItem`, that item is represented with a line break separating the key
     * and value. The calculation does not include indentation and end of line characters.
     * @param {Integer} [Options.CharThresholdMap] - If set, and if an Map's string representation is
     * less than or equal to `Options.CharThresholdMap`, that Map is represented as a single line.
     * If an Map's string representation is greater than `Options.CharThresholdMap`, that Map
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     * @param {Integer} [Options.CharThresholdObject] - If set, and if an Object's string representation is
     * less than or equal to `Options.CharThresholdObject`, that Object is represented as a single line.
     * If an Object's string representation is greater than `Options.CharThresholdObject`, that Object
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     * @param {Integer} [options.DepthThreshold = 0] - `options.DepthThreshold` specifies the minimum
     * depth required to invoke the behavior associated with the "charThreshold" options. For example,
     * if `options.charThreshold` is `200`, `options.DepthThreshold` is `2`, then the substring for
     * the root level object (depth 1) will be unaltered, even if the character count is 200 or less.
     * @param {String} [Options.Eol = "`n"] - The end of line character(s) to use when building
     * the JSON string.
     * @param {String} [Options.IndentChar = "`s"] - The character used for indentation.
     * @param {Integer} [Options.IndentLen = 2] - The number of `Options.IndentChar` to use for one
     * level of indentation.
     *
     * @example
     * obj := {
     *     Map: Map("obj", { prop: "val" }, "arr", [ "val" ], "map", Map("key", "val"))
     *   , Array: [ { prop: "val", }, Map("key", "val"), [ "val" ] ]
     *   , Object: { obj: { prop: "val" }, map: Map("key", "val"), arr: [ "val" ] }
     * }
     * strfy := PrettyStringify()
     * strfy(obj, &str)
     * OutputDebug(str "`n")
     * @
     */
    __New(Options?) {
        options := PrettyStringify.Options(Options ?? unset)
        this.Eol := options.Eol
        this.Indent := PrettyStringify_IndentHelper(options.IndentLen, options.IndentChar)
        if IsNumber(options.CharThreshold) {
            this.CharThresholdArray := IsNumber(options.CharThresholdArray) ? options.CharThresholdArray : options.CharThreshold
            this.CharThresholdItem := IsNumber(options.CharThresholdItem) ? options.CharThresholdItem : options.CharThreshold
            this.CharThresholdMap := IsNumber(options.CharThresholdMap) ? options.CharThresholdMap : options.CharThreshold
            this.CharThresholdObject := IsNumber(options.CharThresholdObject) ? options.CharThresholdObject : options.CharThreshold
        } else {
            if IsNumber(options.CharThresholdArray) {
                this.CharThresholdArray := options.CharThresholdArray
            }
            if IsNumber(options.CharThresholdItem) {
                this.CharThresholdItem := options.CharThresholdItem
            }
            if IsNumber(options.CharThresholdMap) {
                this.CharThresholdMap := options.CharThresholdMap
            }
            if IsNumber(options.CharThresholdObject) {
                this.CharThresholdObject := options.CharThresholdObject
            }
        }
        this.DepthThreshold := options.DepthThreshold
    }

    /**
     * @param {*} Obj - The object to stringify.
     * @param {VarRef} OutStr - The variable that will receive the JSON string.
     * @param {Integer} [InitialIndent = 0] - The initial indentation level. All lines except the
     * first line (the opening brace) will minimally have this indentation level. The reason the first
     * line does not is to make it easier to use the output as a value in another JSON string.
     * @param {Integer} [ApproxGreatestDepth = 10] - `ApproxGreatestDepth` is used to approximate
     * the size of each substring to avoid needing to frequently expand the string.
     */
    Call(Obj, &OutStr, InitialIndent := 0, ApproxGreatestDepth := 10) {
        OutStr := ''
        VarSetStrCapacity(&OutStr, 64 * 2 ** ApproxGreatestDepth)
        eol := this.Eol
        ind := this.Indent
        thresholdArray := this.CharThresholdArray
        thresholdItem := this.CharThresholdItem
        thresholdMap := this.CharThresholdMap
        thresholdObject := this.CharThresholdObject
        DepthThreshold := this.DepthThreshold
        lenInd := StrLen(ind[1])
        lenEol := StrLen(eol)
        ws := depth := 0
        _Proc(Obj, InitialIndent, &OutStr)
        OutStr := RegExReplace(OutStr, ' +(?=\n|$)', '')
        VarSetStrCapacity(&OutStr, -1)

        return

        _Proc(Obj, indent, &str) {
            depth++
            c := s := ''
            VarSetStrCapacity(&s, 64 * 2 ** Max(ApproxGreatestDepth - depth, 3))
            switch Type(Obj) {
                case 'Array':
                    if Obj.Length {
                        _ws := ws
                        s .= '[ '
                        indent++
                        for val in Obj {
                            if IsSet(val) {
                                if IsObject(val) {
                                    s .= c eol ind[indent]
                                    _Proc(val, indent, &s)
                                } else if IsNumber(val) {
                                    s .= c eol ind[indent] val
                                } else {
                                    s .= c eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                                }
                            } else {
                                s .= c eol ind[indent] 'null'
                            }
                            ws += lenInd * indent + lenEol
                            c := ', '
                        }
                        indent--
                        if depth >= DepthThreshold && StrLen(s) - ws + _ws + 1 <= thresholdArray {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' ]'
                        } else {
                            str .= s eol ind[indent] ']'
                        }
                    } else {
                        str .= '[]'
                    }
                case 'Map':
                    if Obj.Count {
                        _ws := ws
                        s .= '[ '
                        indent++
                        for key, val in Obj {
                            _wsi := ws
                            _s := ''
                            VarSetStrCapacity(&_s, 64 * 2 ** (ApproxGreatestDepth - depth - 1))
                            _s .= c eol ind[indent] '[ '
                            ws += lenInd * indent + lenEol
                            c := ', '
                            indent++
                            if IsObject(key) {
                                if ObjHasOwnProp(key, 'Prototype') {
                                    _s .= eol ind[indent] '"{ ' key.__Class ' : ' key.Prototype.__Class ' }"'
                                } else if ObjHasOwnProp(key, '__Class') {
                                    _s .= eol ind[indent] '"{ Prototype : ' key.__Class ' }"'
                                } else {
                                    _s .= eol ind[indent] '"{ ' key.__Class ' }"'
                                }
                            } else if IsNumber(key) {
                                _s .= eol ind[indent] key
                            } else {
                                _s .= eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(key, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                            ws += lenInd * indent + lenEol
                            if IsObject(val) {
                                _s .= ', ' eol ind[indent]
                                _Proc(val, indent, &_s)
                            } else if IsNumber(val) {
                                _s .= ', ' eol ind[indent] val
                            } else {
                                _s .= ', ' eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                            ws += lenInd * indent + lenEol
                            indent--
                            if StrLen(_s) - ws + _wsi + 1 <= thresholdItem {
                                ws := _wsi
                                s .= RegExReplace(_s, '\R *(?![\]}])', '') ' ]'
                            } else {
                                s .= _s eol ind[indent] ']'
                            }
                        }
                        indent--
                        if depth >= DepthThreshold && StrLen(s) - ws + _ws + 1 <= thresholdMap {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' ]'
                        } else {
                            str .= s eol ind[indent] ']'
                        }
                    } else {
                        str .= '[[]]'
                    }
                default:
                    if ObjOwnPropcount(Obj) {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for prop, val in ObjOwnProps(Obj) {
                            s .= c eol ind[indent] '"' prop '": '
                            ws += lenInd * indent + lenEol
                            c := ', '
                            if IsObject(val) {
                                _Proc(val, indent, &s)
                            } else if IsNumber(val) {
                                s .= val
                            } else {
                                s .= '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                        }
                        indent--
                        if depth >= DepthThreshold && StrLen(s) - ws + _ws + 1 <= thresholdObject {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' }'
                        } else {
                            str .= s eol ind[indent] '}'
                        }
                    } else {
                        str .= '{}'
                    }
            }
            depth--
        }
    }
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.CharThreshold := 200
            proto.Eol := '`n'
            proto.IndentChar := '`s'
            proto.IndentLen := 2
            proto.CharThresholdArray :=
            proto.CharThresholdItem :=
            proto.CharThresholdMap :=
            proto.CharThresholdObject :=
            ''
            proto.DepthThreshold := 0
        }

        __New(options?) {
            if IsSet(options) {
                for prop in PrettyStringify.Options.Prototype.OwnProps() {
                    if HasProp(options, prop) {
                        this.%prop% := options.%prop%
                    }
                }
                if ObjHasOwnProp(this, '__Class') {
                    this.DeleteProp('__Class')
                }
            }
        }
    }

}

class PrettyStringify_IndentHelper extends Array {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__IndentLen := ''
        proto.DefineProp('ItemHelper', { Call: Array.Prototype.GetOwnPropDesc('__Item').Get })
    }
    __New(IndentLen, IndentChar := '`s') {
        this.__IndentChar := IndentChar
        this.SetIndentLen(IndentLen)
    }
    Expand(Index) {
        s := this[1]
        loop Index - this.Length {
            this.Push(this[-1] s)
        }
    }
    Initialize() {
        c := this.__IndentChar
        this.Length := 1
        s := ''
        loop this.__IndentLen {
            s .= c
        }
        this[1] := s
        this.Expand(4)
    }
    SetIndentChar(IndentChar) {
        this.__IndentChar := IndentChar
        this.Initialize()
    }
    SetIndentLen(IndentLen) {
        this.__IndentLen := IndentLen
        this.Initialize()
    }

    __Item[Index] {
        Get {
            if Index {
                if Abs(Index) > this.Length {
                    this.Expand(Abs(Index))
                }
                return this.ItemHelper(Index)
            } else {
                return ''
            }
        }
    }
    IndentChar {
        Get => this.__IndentChar
        Set => this.SetIndentChar(Value)
    }
    IndentLen {
        Get => this.__IndentLen
        Set => this.SetIndentLen(Value)
    }
}
