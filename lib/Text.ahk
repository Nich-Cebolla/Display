
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/IntegerArray.ahk
#include <IntegerArray>

#include ..\src
#include SelectFontIntoDc.ahk
#include ..\struct
#include Size.ahk

/**
    The WinAPI text functions here require string length measured in WORDs. `StrLen()` handles this
    for us, as noted here: {@link https://www.autohotkey.com/docs/v2/lib/Chr.htm}
    "Unicode supplementary characters (where Number is in the range 0x10000 to 0x10FFFF) are counted
    as two characters. That is, the length of the return value as reported by StrLen may be 1 or 2.
    For further explanation, see String Encoding."
    {@link https://www.autohotkey.com/docs/v2/Concepts.htm#string-encoding}

    The functions all require a device context handle. Use the `SelectFontIntoDc` function to get
    an object that handles the boilerplate code.
   @example
    context := SelectFontIntoDc(hWnd)
    sz := GetTextExtentPoint32(context.hdc, 'Hello, world!')
    context() ; release the device context
   @

   If you need help understanding how to handle OS errors, read the section "OSError" here:
   {@link https://www.autohotkey.com/docs/v2/lib/Error.htm}
*/

; -------------------------

/**
 * @description - Gets the dimensions of a string within a window's device context. Carriage return
 * and line feed characters are ignored, the returned height is always that of a one-line string.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}
 *
 * @param {Integer} hdc - A handle to the device context you want used to measure the string.
 * @param {String} Str - The string to measure.
 * @returns {Size} - A `Size` object with properties { Width, Height }.
 */
GetTextExtentPoint32(hdc, Str) {
    ; Measure the text
    if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', hdc
        , 'Ptr', StrPtr(Str)
        , 'Int', StrLen(Str)
        , 'Ptr', sz := Size()
        , 'Int'
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
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}
 *
 * @param {Integer} hdc - A handle to the device context to use when measuring the string.
 * @param {String[]} Arr - An array of strings. The array may not have unset indices.
 * @param {VarRef} [OutWidth] - A variable that will receive the greatest width of the strings in the
 * array.
 * @param {VarRef} [OutHeight] - A variable that will receive the cumulative height of the lines.
 * @param {Boolean} [ReplaceItems = false] - If true, the original array is used to store the `Size`
 * objects, and the strings are replaced with the objects. If false, a new array is created.
 * @returns {Size[]} - An array of `Size` objects, each with properties { Width, Height }.
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
            if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', hdc
                , 'Ptr', StrPtr(Str)
                , 'Int', StrLen(Str)
                , 'Ptr', sz := Size()
                , 'Int'
            ) {
                Result[A_Index] := sz
                OutWidth := Max(OutWidth, sz.Width)
                OutHeight += sz.Height
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
 * @description - `GetTextExtentExPoint` is similar to `GetTextExtentPoint32`, but has several
 * additional functions to work with. `GetTextExtentExPoint` measures a string's dimensions and the
 * width (extent point) in pixels of each character's position in the string.
 *
 * An example function call is available in file {@link examples\example-GetTextExtentExPoint.ahk}
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getteextextentexpointa}
 *
 * @param {Integer} hdc - The handle to the device context to use when measuring the string.
 * @param {String} Str - The string to measure.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. When nonzero,
 * `OutCharacterFit` is set to the number of characters that fit within the `MaxExtent` pixels, and
 * `OutExtentPoints` will only contain extent points up to `OutCharacterFit` number of characters.
 * If 0, `MaxExtent` is ignored, `OutCharacterFit` is assigned 0, and `OutExtentPoints` will contain
 * the extent point for every character in the string.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within the given width. If `MaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`, a buffer
 * object containing the partial string extent points (the cumulative width of the string at
 * each character from left to right measured from the beginning of the string to the right-side of
 * the character). If `MaxExtent` is nonzero, the number of extent points contained by
 * `OutExtentPoints` will equal `OutCharacterFit`. If `MaxExtent` is zero, `OutExtentPoints` will
 * contain the extent point for every character in the string. `OutExtentPoints` is not an instance
 * of `Array`; it has only one method, `__Enum`, which you can use by calling it in a loop, and it
 * has properties { __Item, Capacity, Size, Type }. See struct\IntegerArray.ahk for more
 * information.
 * @returns {Size} - A `Size` object with properties { Width, Height }.
 */
GetTextExtentExPoint(hdc, Str, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if MaxExtent {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hdc
            , 'ptr', StrPtr(Str)                                    ; String to measure
            , 'int', StrLen(Str)                                    ; String length in WORDs
            , 'int', MaxExtent                                      ; Maximum width
            , 'ptr', lpnFit := Buffer(4)                            ; To receive number of characters that can fit
            , 'ptr', OutExtentPoints := IntegerArray(StrLen(Str))   ; An array to receives partial string extents.
            , 'ptr', sz := Size()                                   ; To receive the dimensions of the string.
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
            , 'ptr', OutExtentPoints := IntegerArray(StrLen(Str))   ; An array to receives partial string extents.
            , 'ptr', sz := Size()                                   ; To receive the dimensions of the string.
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
 * @description - Calls `GetTextExtentExPoint` for each string in an array, adding an object
 * to the output array. If an item in the input array is an empty string, its associated item in the
 * output array is also an empty string.
 *
 * An example function call is available in file {@link examples\example_Text_GetTextExtentExPoint.ahk}
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 *
 * @param {Integer} hdc - The handle to the device context to use when measuring the string.
 * @param {String} Str - The string to measure.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. When nonzero,
 * the `CharacterFit` property is set with number of characters that fit within the `MaxExtent` pixels,
 * and the value set to the `ExtentPoints` property will only contain extent points up to `CharacterFit`
 * number of characters. If 0, `MaxExtent` is ignored, `CharacterFit` is assigned 0, and
 * `ExtentPoints` will contain the extent point for every character in the string.
 *
 * The value set to the `ExtentPoints` property is an `IntegerArray`, a buffer object containing the
 * partial string extent points (the cumulative width of the string at each character from left to
 * right measured from the beginning of the string to the right-side of the character).
 *
 * `ExtentPoints` is not an instance of `Array`; it has only one method, `__Enum`, which you can use
 * by calling it in a loop, and it has properties { __Item, Capacity, Size, Type }. See
 * "structIntegerArray.ahk" for more information.
 * @param {Boolean} [ReplaceItems = false] - If true, the items in `Arr` are replaced with the output
 * objects. If false, a new array is created.
 *
 * @returns {Array} - Each item in the array is an object with properties { CharacterFit, ExtentPoints, Size }
 */
GetMultiTextExtentExPoint(hdc, Arr, MaxExtent := 0, ReplaceItems := false) {
    if ReplaceItems {
        Result := Arr
    } else {
        Result := []
        Result.Length := Arr.Length
    }
    if MaxExtent {
        for Str in Arr {
            if Str {
                if DllCall('Gdi32.dll\GetTextExtentExPoint'
                    , 'ptr', hdc
                    , 'ptr', StrPtr(Str)                                    ; String to measure
                    , 'int', StrLen(Str)                                    ; String length in WORDs
                    , 'int', MaxExtent                                      ; Maximum width
                    , 'ptr', lpnFit := Buffer(4)                            ; To receive number of characters that can fit
                    , 'ptr', ExtentPoints := IntegerArray(StrLen(Str))      ; An array to receives partial string extents.
                    , 'ptr', sz := Size()                                   ; To receive the dimensions of the string.
                    , 'ptr'
                ) {
                    Result[A_Index] := { CharacterFit: NumGet(lpnFit, 0, 'int'), ExtentPoints: ExtentPoints, Size: sz }
                } else {
                    throw OSError()
                }
            }
        }
    } else {
        for Str in Arr {
            if Str {
                if DllCall('Gdi32.dll\GetTextExtentExPoint'
                    , 'ptr', hdc
                    , 'ptr', StrPtr(Str)                                    ; String to measure
                    , 'int', StrLen(Str)                                    ; String length in WORDs
                    , 'int', 0
                    , 'ptr', 0
                    , 'ptr', ExtentPoints := IntegerArray(StrLen(Str))      ; An array to receives partial string extents.
                    , 'ptr', sz := Size()                                   ; To receive the dimensions of the string.
                    , 'ptr'
                ) {
                    Result[A_Index] := { CharacterFit: 0, ExtentPoints: ExtentPoints, Size: sz }
                } else {
                    throw OSError()
                }
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
    OutLowWidth := { Width: 4294967295 }
    OutHighWidth := { Width: 0 }
    OutSumWidth := OutSumHeight := 0
    result := []
    result.Capacity := List.Length
    result.StrAppend := StrAppend
    for str in List {
        _str := str StrAppend
        if !DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', hdc
            , 'Ptr', StrPtr(_str)
            , 'Int', StrLen(_str)
            , 'Ptr', sz := Size()
            , 'Int'
        ) {
            throw OSError()
        }
        result.Push(sz)
        sz.Str := str
        if sz.Width < OutLowWidth.Width {
            OutLowWidth := sz
        }
        if sz.Width > OutHighWidth.Width {
            OutHighWidth := sz
        }
        OutSumWidth += sz.Width
        OutSumHeight += sz.Height
    }
    return result
}
