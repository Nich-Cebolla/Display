

#include ..\src\SelectFontIntoDc.ahk
#include ..\struct
#include Display_IntegerArray.ahk
#include Display_Size.ahk

/**
 * @description - Gets the dimensions of a string within a window's device context. Carriage return
 * and line feed characters are ignored, the returned height is always that of a one-line string.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}.
 *
 * @param {Integer} hdc - A handle to the device context you want used to measure the string.
 * @param {String} Str - The string to measure.
 * @returns {Display_Size}
 */
GetTextExtentPoint32(hdc, Str) {
    ; Measure the text
    if DllCall('Gdi32.dll\GetTextExtentPoint32'
        , 'ptr', hdc
        , 'ptr', StrPtr(Str)
        , 'int', StrLen(Str)
        , 'ptr', sz := Display_Size()
        , 'int'
    ) {
        return sz
    } else {
        throw OSError()
    }
}

/**
 * @description - Iterates an array of strings. For each string, a Size object is added to an array.
 * The array is returned, and the VarRef parameters receieve the cumulative height, and the greatest
 * width, of the items. For any string values that are empty strings, the associated value added to
 * the output array is also an empty string.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}.
 *
 * @param {Integer} hdc - A handle to the device context to use when measuring the string.
 * @param {String[]} Arr - An array of strings. The array may not have unset indices.
 * @param {VarRef} [OutWidth] - A variable that will receive the greatest width of the strings in the
 * array.
 * @param {VarRef} [OutHeight] - A variable that will receive the cumulative height of the lines.
 * @param {Boolean} [ReplaceItems = false] - If true, the original array is used to store the
 * {@link Display_Size} objects, and the strings are replaced with the objects. If false, a new array
 * is created.
 * @returns {Display_Size[]}
 */
GetMultiExtentPoints(hdc, Arr, &OutWidth?, &OutHeight?, ReplaceItems := false) {
    if ReplaceItems {
        Result := Arr
    } else {
        Result := []
        Result.Length := Arr.Length
    }
    OutWidth := OutHeight := 0
    for Str in Arr {
        if Str {
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'ptr', hdc
                , 'ptr', StrPtr(Str)
                , 'int', StrLen(Str)
                , 'ptr', sz := Display_Size()
                , 'int'
            ) {
                Result[A_Index] := sz
                OutWidth := Max(OutWidth, sz.W)
                OutHeight += sz.H
            } else {
                throw OSError()
            }
        } else {
            Result[A_Index] := ''
        }
    }
    return Result
}

/**
 * @description - Iterates an array of strings. For each string, a Size object is added to an array.
 * The array is returned, and the VarRef parameters receieve the cumulative height, and the greatest
 * width, of the items. For any string values that are empty strings, the associated value added to
 * the output array is also an empty string.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}.
 *
 * @param {Integer} hdc - A handle to the device context to use when measuring the string.
 * @param {String[]} Arr - An array of strings. The array may not have unset indices.
 * @param {VarRef} [OutWidth] - A variable that will receive the greatest width of the strings in the
 * array.
 * @param {VarRef} [OutHeight] - A variable that will receive the cumulative height of the lines.
 * @param {Boolean} [ReplaceItems = false] - If true, the original array is used to store the
 * {@link Display_Size} objects, and the strings are replaced with the objects. If false, a new array
 * is created.
 * @param {VarRef} [OutGreatestHeight] - A variable that will receive the greatest height of the strings
 * in the array.
 * @returns {Display_Size[]}
 */
GetMultiExtentPoints2(hdc, Arr, &OutWidth?, &OutHeight?, ReplaceItems := false, &OutGreatestHeight?) {
    if ReplaceItems {
        Result := Arr
    } else {
        Result := []
        Result.Length := Arr.Length
    }
    OutWidth := OutHeight := OutGreatestHeight := 0
    for Str in Arr {
        if Str {
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'ptr', hdc
                , 'ptr', StrPtr(Str)
                , 'int', StrLen(Str)
                , 'ptr', sz := Display_Size()
                , 'int'
            ) {
                Result[A_Index] := sz
                OutWidth := Max(OutWidth, sz.W)
                OutHeight += sz.H
                OutGreatestHeight := Max(OutGreatestHeight, sz.H)
            } else {
                throw OSError()
            }
        } else {
            Result[A_Index] := ''
        }
    }
    return Result
}

/**
 * @description - {@link GetTextExtentExPoint} measures a string's dimensions and the width (extent
 * point) in pixels of each character's position in the string.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointw}.
 *
 * @param {Integer} hdc - The handle to the device context to use when measuring the string.
 * @param {String} Str - The string to measure.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string in pixels. When nonzero,
 * `OutCharacterFit` is set to the number of characters that fit within the `MaxExtent` pixels, and
 * `OutExtentPoints` will only contain extent points up to `OutCharacterFit` number of characters.
 * If 0, `MaxExtent` is ignored, `OutCharacterFit` is assigned 0, and `OutExtentPoints` will contain
 * the extent point for every character in the string.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within the given width. If `MaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an {@link Display_IntegerArray},
 * a buffer object containing the partial string extent points (the cumulative width of the string at
 * each character from left to right measured from the beginning of the string to the right-side of
 * the character). If `MaxExtent` is nonzero, the number of extent points contained by
 * `OutExtentPoints` will equal `OutCharacterFit`. If `MaxExtent` is zero, `OutExtentPoints` will
 * contain the extent point for every character in the string. See {@link Display_IntegerArray}
 * for more information.
 * @returns {Display_Size}
 */
GetTextExtentExPoint(hdc, Str, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if MaxExtent {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hdc
            , 'ptr', StrPtr(Str)                                    ; String to measure
            , 'int', StrLen(Str)                                    ; String length in WORDs
            , 'int', MaxExtent                                      ; Maximum width
            , 'ptr', lpnFit := Buffer(4)                            ; To receive number of characters that can fit
            , 'ptr', OutExtentPoints := Display_IntegerArray(StrLen(Str))   ; An array to receives partial string extents.
            , 'ptr', sz := Display_Size()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := NumGet(lpnFit, 0, 'int')
            return sz
        } else {
            throw OSError()
        }
    } else {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hdc
            , 'ptr', StrPtr(Str)                                    ; String to measure
            , 'int', StrLen(Str)                                    ; String length in WORDs
            , 'int', 0
            , 'ptr', 0
            , 'ptr', OutExtentPoints := Display_IntegerArray(StrLen(Str))   ; An array to receives partial string extents.
            , 'ptr', sz := Display_Size()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := 0
            return sz
        } else {
            throw OSError()
        }
    }
}

/**
 * @description - Calls {@link GetTextExtentExPoint} for each string in an array, adding an object
 * to the output array. If an item in the input array is an empty string, its associated item in the
 * output array is also an empty string.
 *
 * Each item in the array is an object with properties { CharacterFit, ExtentPoints, Size }.
 *
 * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointw}.
 *
 * @param {Integer} hdc - The handle to the device context to use when measuring the string.
 * @param {String[]} list - The array of strings to measure.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string in pixels. When nonzero,
 * the property "CharacterFit is set with number of characters that fit within `MaxExtent` pixels,
 * and the value set to the property "ExtentPoints" will only contain extent points up to `CharacterFit`
 * number of characters. If 0, `MaxExtent` is ignored, the property "CharacterFit" is assigned 0, and
 * the property "ExtentPoints" will contain the extent point for every character in the string.
 *
 * The value set to the "ExtentPoints" property is an {@link Display_IntegerArray}, a buffer object
 * containing the partial string extent points (the cumulative width of the string at each character
 * from left to right measured from the beginning of the string to the right-side of the character).
 *
 * @param {Boolean} [ReplaceItems = false] - If true, the items in `list` are replaced with the output
 * objects. If false, a new array is created.
 *
 * @returns {Object[]} - Each object in the array is an object with properties { CharacterFit, ExtentPoints, Size }.
 */
GetMultiTextExtentExPoint(hdc, list, MaxExtent := 0, ReplaceItems := false) {
    if ReplaceItems {
        Result := list
    } else {
        Result := []
        Result.Length := list.Length
    }
    if MaxExtent {
        lpnFit := Buffer(4)
        for Str in list {
            if Str {
                if DllCall('Gdi32.dll\GetTextExtentExPoint'
                    , 'ptr', hdc
                    , 'ptr', StrPtr(Str)                                    ; String to measure
                    , 'int', StrLen(Str)                                    ; String length in WORDs
                    , 'int', MaxExtent                                      ; Maximum width
                    , 'ptr', lpnFit                                         ; To receive number of characters that can fit
                    , 'ptr', ExtentPoints := Display_IntegerArray(StrLen(Str))      ; An array to receives partial string extents.
                    , 'ptr', sz := Display_Size()                                   ; To receive the dimensions of the string.
                    , 'ptr'
                ) {
                    Result[A_Index] := { CharacterFit: NumGet(lpnFit, 0, 'int'), ExtentPoints: ExtentPoints, Size: sz }
                } else {
                    throw OSError()
                }
            } else {
                Result[A_Index] := ''
            }
        }
    } else {
        for Str in list {
            if Str {
                if DllCall('Gdi32.dll\GetTextExtentExPoint'
                    , 'ptr', hdc
                    , 'ptr', StrPtr(Str)                                    ; String to measure
                    , 'int', StrLen(Str)                                    ; String length in WORDs
                    , 'int', 0
                    , 'ptr', 0
                    , 'ptr', ExtentPoints := Display_IntegerArray(StrLen(Str))      ; An array to receives partial string extents.
                    , 'ptr', sz := Display_Size()                                   ; To receive the dimensions of the string.
                    , 'ptr'
                ) {
                    Result[A_Index] := { CharacterFit: 0, ExtentPoints: ExtentPoints, Size: sz }
                } else {
                    throw OSError()
                }
            } else {
                Result[A_Index] := ''
            }
        }
    }
    return Result
}

/**
 * @description - Evaluates a string to return the line ending used.
 * @returns {String} - The line ending. If there are no carriage return or line feed characters in
 * the string, the return value is an empty string.
 */
GetLineEnding(Str) {
    StrReplace(Str, '`r', , , &CountCr)
    StrReplace(Str, '`n', , , &CountLf)
    if CountCr == CountLf {
        if InStr(Str, '`r`n') {
            return '`r`n'
        } else {
            return '`n`r'
        }
    } else if CountCr > CountLf {
        return '`r'
    } else if CountLf {
        return '`n'
    } else {
        return ''
    }
}

MeasureList(List, hdc, StrAppend := '', &OutLowWidth?, &OutHighWidth?, &OutSumWidth?, &OutSumHeight?) {
    OutLowWidth := { W: 4294967295 }
    OutHighWidth := { W: 0 }
    OutSumWidth := OutSumHeight := 0
    result := []
    result.Capacity := List.Length
    result.StrAppend := StrAppend
    for str in List {
        _str := str StrAppend
        if !DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'ptr', hdc
            , 'ptr', StrPtr(_str)
            , 'int', StrLen(_str)
            , 'ptr', sz := Display_Size()
            , 'int'
        ) {
            throw OSError()
        }
        result.Push(sz)
        sz.Str := str
        if sz.W < OutLowWidth.W {
            OutLowWidth := sz
        }
        if sz.W > OutHighWidth.W {
            OutHighWidth := sz
        }
        OutSumWidth += sz.W
        OutSumHeight += sz.H
    }
    return result
}
