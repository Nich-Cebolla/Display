
; Dependencies:
#include Text.ahk
#include ..\definitions
#include Define-Font.ahk
#include ..\src
#include SelectFontIntoDc.ahk
#include ..\struct
#include SIZE.ahk
#include IntegerArray.ahk

/**
    The WinAPI text functions here require string length measured in WORDs. `StrLen()` handles this
    for us, as noted here: {@link https://www.autohotkey.com/docs/v2/lib/Chr.htm}
    "Unicode supplementary characters (where Number is in the range 0x10000 to 0x10FFFF) are counted
    as two characters. That is, the length of the return value as reported by StrLen may be 1 or 2.
    For further explanation, see String Encoding."
    {@link https://www.autohotkey.com/docs/v2/Concepts.htm#string-encoding}

   If you need help understanding how to handle OS errors, read the section "OSError" here:
   {@link https://www.autohotkey.com/docs/v2/lib/Error.htm}
*/

; -------------------------

/**
 * @description - Calls `GetTextExtentPoint32` to get the height and width in pixels of the string
 * contents of a Gui control. If the `Ctrl.Text` property contains multiple lines of text, the
 * lines are split at each newline character and each line is measured individually. The value
 * returned by this function will be an object where the height represents the sum of the height
 * of each line, and the width is the greatest width of each line. The height value will **not** be an
 * accurate representation of the height occupied by the text within a control's display area because
 * padding is added to each line.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}
 * @param {String} Ctrl - The `Gui.Control` object.
 * @returns {Object} - An object with properties { Height, Lines, Width }. `Lines` is an array of
 * `SIZE` objects. If there is a blank line in `Ctrl.Text`, its associated index in `Lines` is an
 * empty string.
 */
ControlGetTextExtent(Ctrl) {
    W := H := 0
    sz := SIZE()
    lines := StrSplit(Ctrl.Text, GetLineEnding(Ctrl.Text))
    context := SelectFontIntoDc(Ctrl.hWnd)
    for line in lines {
        if line {
            if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', context.hdc, 'Ptr', StrPtr(line), 'Int', StrLen(line), 'Ptr', sz, 'Int'
            ) {
                H += sz.Height
                W := Max(W, sz.Width)
                lines[A_Index] := sz
                sz := SIZE()
            } else {
                throw OSError()
            }
        }
    }
    context()
    return { Height: H, Lines: Lines, Width: W }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a ListBox control.
 * This version of the function is only appropriate for single-line strings.
 *
 * When ListBox controls are created, one of the options available is `Multi`. When `Multi` is in use,
 * the `Text` property returns an array of selected items. This version of the function has an
 * optional `Index` parameter to allow you to specify which item to measure. When unset, all items
 * in the array are measured. If a listbox is created without the `Multi` option, the `Index`
 * property has no effect because the `Text` property will return a string.
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [Index] - If an integer, the index of the item to measure. If unset, all items
 * returned by the `Text` property are measured.
 * @returns {Array} - An array of objects with properties { Height, Index, Width }.
 */
ControlGetTextExtent_LB(Ctrl, Index?) {
    Result := []
    context := SelectFontIntoDc(Ctrl.hWnd)
    if Ctrl.Text is Array {
        if IsSet(Index) {
            _Proc()
        } else {
            Index := 0
            loop Result.Capacity := Ctrl.Text.Length {
                ++Index
                _Proc()
            }
        }
    } else {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.Text)
            , 'Int', StrLen(Ctrl.Text)
            , 'Ptr', sz := SIZE()
            , 'Int'
        ) {
            sz.Index := Ctrl.Value
            Result.Push(sz)
        } else {
            throw OSError()
        }
    }
    context()

    return Result

    _Proc() {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.Text[Index])
            , 'Int', StrLen(Ctrl.Text[Index])
            , 'Ptr', sz := SIZE()
            , 'Int'
        ) {
            sz.Index := Index
            Result.Push(sz)
        } else {
            throw OSError()
        }
    }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a link control.
 * This version of the function is only appropriate for single-line strings.
 *
 * Since the content displayed by a link control is different than the string returned by its `Text`
 * property, this version of the function removes the anchor html tags from the string and only
 * measures the inner text.
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @returns {SIZE} - A `SIZE` object with properties { Height, Width }.
 */
ControlGetTextExtent_Link(Ctrl) {
    context := SelectFontIntoDc(Ctrl.hWnd)
    ; Remove the html anchor tags
    Text := RegExReplace(Ctrl.Text, '<.+?"[ \t]*>(.+?)</a>', '$1')
    ; Measure the text
    if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', context.hdc
        , 'Ptr', StrPtr(Text)
        , 'Int', StrLen(Text)
        , 'Ptr', sz := SIZE()
        , 'Int'
    ) {
        context()
        return sz
    } else {
        throw OSError()
    }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a ListView control.
 * This version of the function is only appropriate for single-line strings.
 *
 * This version of the function has `RowNumber` and `ColumnNumber` parameters to pass to the the
 * `GetText` method of the control.
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [RowNumber] - If an integer, the row number of the item to measure. If an
 * array, an array of row numbers as integers. Leave unset to get the SIZE for items from all rows.
 * @param {Array|Integer} [ColumnNumber] - If an integer, the column number of the item to measure.
 * If an array, an array of column numbers as integers. Leave unset to get the SIZE for items from
 * all columns.
 * @returns {Array} - An array of objects with properties { Column, Height, Row, Width }.
 */
ControlGetTextExtent_LV(Ctrl, RowNumber?, ColumnNumber?) {
    context := SelectFontIntoDc(Ctrl.hWnd)
    if !IsSet(RowNumber) {
        RowNumber := []
        loop RowNumber.Capacity := Ctrl.GetCount() {
            RowNumber.Push(A_Index)
        }
    }
    if !IsSet(ColumnNumber) {
        ColumnNumber := []
        loop ColumnNumber.Capacity := Ctrl.GetCount('col') {
            ColumnNumber.Push(A_Index)
        }
    }
    Result := []
    if IsObject(RowNumber) {
        if IsObject(ColumnNumber) {
            Result.Capacity := RowNumber.Length * ColumnNumber.Length
            for r in RowNumber {
                for c in ColumnNumber {
                    _Proc(r, c)
                }
            }
        } else {
            Result.Capacity := RowNumber.Length
            c := ColumnNumber
            for r in RowNumber {
                _Proc(r, c)
            }
        }
    } else {
        r := RowNumber
        if IsObject(ColumnNumber) {
            Result.Capacity := ColumnNumber.Length
            for c in ColumnNumber {
                _Proc(r, c)
            }
        } else {
            c := ColumnNumber
            _Proc(r, c)
        }
    }
    context()

    return Result

    _Proc(r, c) {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.GetText(r, c))
            , 'Int', StrLen(Ctrl.GetText(r, c))
            , 'Ptr', sz := SIZE()
        ) {
            sz.Row := r
            sz.Column := c
            Result.Push(sz)
        } else {
            throw OSError()
        }
    }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a TreeView control.
 * This version of the function is only appropriate for single-line strings.
 *
 * This version of the function has two usage options which depend on the value passed to `Count`.
 * {@link https://www.autohotkey.com/docs/v2/lib/TreeView.htm}.
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [Id = 0] - The id of the item to measure, or an array of ids. The ids are
 * passed to the `GetText` method. If `Id` is `0`, `TreeViewObj.GetChild(0)` is called, which returns
 * the top item in the TreeView.
 * @param {Integer} [Count] - If set, `ControlGetTextExtent_TV` traverses the TreeView starting from
 * `Id` for `Count` items, or until the last item is measured. If `Count` is 0, all items after `Id`
 * are measured. If `Id` is an array, `Count` is ignored.
 * @returns {Array} - An array of objects with properties { Id, Width, Height }.
 */
ControlGetTextExtent_TV(Ctrl, Id := 0, Count?) {
    context := SelectFontIntoDc(Ctrl.hWnd)
    Result := []
    if Id is Array {
        loop Result.Capacity := Id.Length {
            _id := Id[A_Index]
            _Proc()
        }
    } else {
        _id := Id || Ctrl.GetChild(0)
        _Proc()
        if IsSet(Count) {
            loop Count || Ctrl.GetCount() {
                if _id := Ctrl.GetNext(_id, 'F') {
                    _Proc()
                } else {
                    break
                }
            }
        }
    }
    context()

    return Result

    _Proc() {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.GetText(_id))
            , 'Int', StrLen(Ctrl.GetText(_id))
            , 'Ptr', sz := SIZE()
            , 'Int'
        ) {
            sz.Id := _id
            Result.Push(sz)
        } else {
            throw OSError()
        }
    }
}

/**
 * @description - Calls `GetTextExtentExPoint` using the control as context.
 *
 * This function is only appropriate for single-line strings. For multi-line usage,
 *
 * You can use this in two general ways.
 *
 * - Leave `MaxExtent` 0: `OutExtentPoints` will receive an `IntegerArray` object, which will be a
 * buffer object containing the partial extent points of every character in the string. Said another
 * way, the integers in the array will be a cumulative representation of how wide the string is up
 * to that character, in pixels. E.g. "H" is 3 pixels wide, "He" is 6 pixels wide, "Hel" is 8 pixels
 * wide, etc. `OutCharacterFit` is not measured in this usage of the function, and will receive 0.
 *
 * - Set `MaxExtent` with a maximum width in pixels: `OutCharacterFit` is assigned the maximum
 * number of characters in the string that can fit `MaxExtent` pixels without going over.
 * `OutExtentPoints` is assigned an `IntegerArray` object, but in this case it only contains the
 * partial extent points up to `OutCharacterFit` number of characters.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [MaxExtent=0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the
 * function description for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Height, Width }.
 */
ControlGetTextExtentEx(Ctrl, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    return __ControlGetTextExtentEx_Process(Ctrl.hWnd, StrPtr(Ctrl.Text), StrLen(Ctrl.Text), &MaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the ListBox control as context. If the `ListBox`
 * has the `Multi` option active, use the `Index` parameter to specify which item to measure. If
 * the `ListBox` does not have the `Multi` option active, leave `Index` unset. See the parameter hint
 * for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [Index] - The index of the item to measure. Leave unset if the `ListBox` does
 * not have the `Multi` option active.
 * @param {Integer} [MaxExtent=0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Height, Width }.
 */
ControlGetTextExtentEx_LB(Ctrl, Index?, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if IsSet(Index) {
        return __ControlGetTextExtentEx_Process(Ctrl.hWnd, StrPtr(Ctrl.Text[Index]), StrLen(Ctrl.Text[Index]), &MaxExtent, &OutCharacterFit, &OutExtentPoints)
    } else {
        return __ControlGetTextExtentEx_Process(Ctrl.hWnd, StrPtr(Ctrl.Text), StrLen(Ctrl.Text), &MaxExtent, &OutCharacterFit, &OutExtentPoints)
    }
}

/**
 * @description - Calls `GetTextExtentExPoint` using the Link control as context.
 * Since the content displayed by a link control is different than the string returned by its `Text`
 * property, this version of the function removes the anchor html tags from the string and only
 * measures the inner text. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [MaxExtent=0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Height, Width }.
 */
ControlGetTextExtentEx_Link(Ctrl, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    ; Remove the html anchor tags
    Text := RegExReplace(Ctrl.Text, '<a\s*(?:href|id)=".+?">(.+?)</a>', '$1')
    return __ControlGetTextExtentEx_Process(Ctrl.hWnd, StrPtr(Text), StrLen(Text), &MaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the ListView control as context. This version of
 * the function has `RowNumber` and `ColumnNumber` parameters to pass to the ListView's `GetText`
 * method. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} RowNumber - The row number of the item to measure.
 * @param {Array|Integer} ColumnNumber - The column number of the item to measure.
 * @param {Integer} [MaxExtent=0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Height, Width }.
 */
ControlGetTextExtentEx_LV(Ctrl, RowNumber, ColumnNumber, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    text := Ctrl.GetText(RowNumber, ColumnNumber)
    sz := __ControlGetTextExtentEx_Process(Ctrl.hWnd, StrPtr(text), StrLen(text), &MaxExtent, &OutCharacterFit, &OutExtentPoints)
    sz.Row := RowNumber
    sz.Column := ColumnNumber
    return sz
}

/**
 * @description - Calls `GetTextExtentExPoint` using the TreeView control as context. This version of
 * the function has an `Id` parameter to pass to the TreeView's `GetText` method. See the
 * parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [Id=0] - The Id of the item to measure. If `Id` is `0`, the first item in the
 * TreeView is measured.
 * @param {Integer} [MaxExtent=0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Height, Width }.
 */
ControlGetTextExtentEx_TV(Ctrl, Id := 0, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if !Id {
        Id := Ctrl.GetChild(0)
    }
    text := Ctrl.GetText(Id)
    sz := __ControlGetTextExtentEx_Process(Ctrl.hWnd, StrPtr(text), StrLen(text), &MaxExtent, &OutCharacterFit, &OutExtentPoints)
    sz.Id := Id
    return sz
}

__ControlGetTextExtentEx_Process(hWnd, Ptr, cchString, &MaxExtent, &OutCharacterFit, &OutExtentPoints) {
    context := SelectFontIntoDc(hWnd)
    if MaxExtent {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', context.hdc
            , 'ptr', Ptr                                            ; String to measure
            , 'int', cchString                                      ; String length in WORDs
            , 'int', MaxExtent                                      ; Maximum width
            , 'ptr', lpnFit := Buffer(4)                            ; To receive number of characters that can fit
            , 'ptr', OutExtentPoints := IntegerArray(cchString)     ; An array to receives partial string extents.
            , 'ptr', sz := SIZE()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := NumGet(lpnFit, 0, 'int')
            context()
            return sz
        } else {
            throw OSError()
        }
    } else {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', context.hdc
            , 'ptr', Ptr                                            ; String to measure
            , 'int', cchString                                      ; String length in WORDs
            , 'int', 0
            , 'ptr', 0
            , 'ptr', OutExtentPoints := IntegerArray(cchString)     ; An array to receives partial string extents.
            , 'ptr', sz := SIZE()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := 0
            context()
            return sz
        } else {
            throw OSError()
        }
    }
}
