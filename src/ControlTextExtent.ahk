
#include __ControlGetTextExtentEx_Process.ahk
#include SelectFontIntoDc.ahk
#include ..\struct
#include Display_IntegerArray.ahk
#include Display_Size.ahk

/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w GetTextExtentPoint32}
 * to get the height and width in pixels of the string contents of a Gui control. If the "Text"
 * property returns multiple lines of text, the lines are split at each CRLF and each substring is
 * measured individually.
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {VarRef} [OutWidth] - A variable that will receive the greatest horizontal extent
 * of each line as integer.
 * @param {VarRef} [OutHeight] - A variable that will receive the text's total vertical extent
 * as integer.
 */
ControlGetTextExtent(Ctrl, &OutWidth?, &OutHeight?) {
    sz := Display_Size()
    context := SelectFontIntoDc(Ctrl.Hwnd)
    if InStr(Ctrl.Text, '`r`n') {
        OutWidth := OutHeight := 0
        hdc := context.hdc
        padding := ControlFitText.TextExtentPadding(Ctrl)
        for line in StrSplit(Ctrl.Text, '`r`n') {
            if line {
                if DllCall(
                    'Gdi32.dll\GetTextExtentPoint32'
                  , 'ptr', hdc
                  , 'ptr', StrPtr(line)
                  , 'int', StrLen(line)
                  , 'ptr', sz
                  , 'int'
                ) {
                    OutHeight += sz.H + padding.LinePadding
                    OutWidth := Max(OutWidth, sz.W)
                } else {
                    context()
                    throw OSError()
                }
            } else {
                OutHeight += padding.LineHeight + padding.LinePadding
            }
        }
        OutHeight -= padding.LinePadding
    } else {
        if DllCall(
            'Gdi32.dll\GetTextExtentPoint32'
          , 'ptr', context.hdc
          , 'wstr', Ctrl.Text
          , 'int', StrLen(Ctrl.Text)
          , 'ptr', sz
          , 'int'
        ) {
            OutHeight := sz.H
            OutWidth := sz.W
        } else {
            context()
            throw OSError()
        }
    }
    context()
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
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Integer} [Index] - If an integer, the index of the item to measure. If unset, all items
 * returned by the `Text` property are measured.
 * @returns {Array} - An array of objects with properties { H, Index, W }.
 */
ControlGetTextExtent_LB(Ctrl, Index?) {
    Result := []
    context := SelectFontIntoDc(Ctrl.Hwnd)
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'ptr', context.hdc
            , 'ptr', StrPtr(Ctrl.Text)
            , 'int', StrLen(Ctrl.Text)
            , 'ptr', sz := Display_Size()
            , 'int'
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'ptr', context.hdc
            , 'ptr', StrPtr(Ctrl.Text[Index])
            , 'int', StrLen(Ctrl.Text[Index])
            , 'ptr', sz := Display_Size()
            , 'int'
        ) {
            sz.Index := Index
            Result.Push(sz)
        } else {
            context()
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
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @returns {Display_Size} - A {@link Display_Size} object with properties { H, W }.
 */
ControlGetTextExtent_Link(Ctrl) {
    context := SelectFontIntoDc(Ctrl.Hwnd)
    ; Remove the html anchor tags
    Text := RegExReplace(Ctrl.Text, '<.+?"[ \t]*>(.+?)</a>', '$1')
    ; Measure the text
    if DllCall('Gdi32.dll\GetTextExtentPoint32'
        , 'ptr', context.hdc
        , 'ptr', StrPtr(Text)
        , 'int', StrLen(Text)
        , 'ptr', sz := Display_Size()
        , 'int'
    ) {
        context()
        return sz
    } else {
        context()
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
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [RowNumber] - If an integer, the row number of the item to measure. If an
 * array, an array of row numbers as integers. Leave unset to get the Size for items from all rows.
 * @param {Array|Integer} [ColumnNumber] - If an integer, the column number of the item to measure.
 * If an array, an array of column numbers as integers. Leave unset to get the Size for items from
 * all columns.
 * @returns {Array} - An array of objects with properties { Column, H, Row, W }.
 */
ControlGetTextExtent_LV(Ctrl, RowNumber?, ColumnNumber?) {
    context := SelectFontIntoDc(Ctrl.Hwnd)
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'ptr', context.hdc
            , 'ptr', StrPtr(Ctrl.GetText(r, c))
            , 'int', StrLen(Ctrl.GetText(r, c))
            , 'ptr', sz := Display_Size()
        ) {
            sz.Row := r
            sz.Column := c
            Result.Push(sz)
        } else {
            context()
            throw OSError()
        }
    }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a TreeView control.
 *
 * This version of the function has two usage options which depend on the value passed to `Count`.
 * {@link https://www.autohotkey.com/docs/v2/lib/TreeView.htm}.
 *
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [Id = 0] - The id of the item to measure, or an array of ids. The ids are
 * passed to the `GetText` method. If `Id` is `0`, `TreeViewObj.GetChild(0)` is called, which returns
 * the top item in the TreeView.
 * @param {Integer} [Count] - If set, {@link ControlGetTextExtent_TV} traverses the TreeView starting from
 * `Id` for `Count` items, or until the last item is measured. If `Count` is 0, all items after `Id`
 * are measured. If `Id` is an array, `Count` is ignored.
 * @returns {Array} - An array of objects with properties { Id, W, H }.
 */
ControlGetTextExtent_TV(Ctrl, Id := 0, Count?) {
    context := SelectFontIntoDc(Ctrl.Hwnd)
    hdc := context.hdc
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'ptr', hdc
            , 'ptr', StrPtr(Ctrl.GetText(_id))
            , 'int', StrLen(Ctrl.GetText(_id))
            , 'ptr', sz := Display_Size()
            , 'int'
        ) {
            sz.Id := _id
            Result.Push(sz)
        } else {
            context()
            throw OSError()
        }
    }
}

/**
 * @description - Calls `GetTextExtentExPoint` using the control as context.
 *
 * This function is only appropriate for single-line strings.
 *
 * You can use this in two general ways.
 *
 * Leave `MaxExtent` 0: `OutExtentPoints` will receive an  {@link Display_IntegerArray} object, which will be a
 * buffer object containing the partial extent points of every character in the string. Said another
 * way, the integers in the array will be a cumulative representation of how wide the string is up
 * to that character, in pixels. E.g. "H" is 3 pixels wide, "He" is 6 pixels wide, "Hel" is 8 pixels
 * wide, etc. `OutCharacterFit` is not measured in this usage of the function, and will receive 0.
 *
 * Set `MaxExtent` with a maximum width in pixels: `OutCharacterFit` is assigned the maximum
 * number of characters in the string that can fit `MaxExtent` pixels without going over.
 * `OutExtentPoints` is assigned an  {@link Display_IntegerArray} object, but in this case it only contains the
 * partial extent points up to `OutCharacterFit` number of characters.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 *
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the
 * function description for further details.
 * @returns {Display_Size}
 */
ControlGetTextExtentEx(Ctrl, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    return __ControlGetTextExtentEx_Process(Ctrl.Hwnd, StrPtr(Ctrl.Text), StrLen(Ctrl.Text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the ListBox control as context. If the `ListBox`
 * has the `Multi` option active, use the `Index` parameter to specify which item to measure. If
 * the `ListBox` does not have the `Multi` option active, leave `Index` unset. See the parameter hint
 * for {@link CtrlTextExtentExPoint} for full details.
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Integer} [Index] - The index of the item to measure. Leave unset if the `ListBox` does
 * not have the `Multi` option active.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}.
 * See the function description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Display_Size}
 */
ControlGetTextExtentEx_LB(Ctrl, Index?, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if IsSet(Index) {
        return __ControlGetTextExtentEx_Process(Ctrl.Hwnd, StrPtr(Ctrl.Text[Index]), StrLen(Ctrl.Text[Index]), MaxExtent, &OutCharacterFit, &OutExtentPoints)
    } else {
        return __ControlGetTextExtentEx_Process(Ctrl.Hwnd, StrPtr(Ctrl.Text), StrLen(Ctrl.Text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
    }
}

/**
 * @description - Calls `GetTextExtentExPoint` using the Link control as context.
 * Since the content displayed by a link control is different than the string returned by its `Text`
 * property, this version of the function removes the anchor html tags from the string and only
 * measures the inner text. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Display_Size}
 */
ControlGetTextExtentEx_Link(Ctrl, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    Text := RegExReplace(Ctrl.Text, '<a\s*(?:href|id)=".+?">(.+?)</a>', '$1')
    return __ControlGetTextExtentEx_Process(Ctrl.Hwnd, StrPtr(Text), StrLen(Text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the ListView control as context. This version of
 * the function has `RowNumber` and `ColumnNumber` parameters to pass to the ListView's `GetText`
 * method. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} RowNumber - The row number of the item to measure.
 * @param {Array|Integer} ColumnNumber - The column number of the item to measure.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Display_Size}
 */
ControlGetTextExtentEx_LV(Ctrl, RowNumber, ColumnNumber, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    text := Ctrl.GetText(RowNumber, ColumnNumber)
    return __ControlGetTextExtentEx_Process(Ctrl.Hwnd, StrPtr(text), StrLen(text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the TreeView control as context. This version of
 * the function has an `Id` parameter to pass to the TreeView's `GetText` method. See the
 * parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {dGui.Control|Gui.Control} Ctrl - The control object.
 * @param {Integer} [Id = 0] - The Id of the item to measure. If `Id` is `0`, the first item in the
 * TreeView is measured.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Display_Size}
 */
ControlGetTextExtentEx_TV(Ctrl, Id := 0, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    text := Ctrl.GetText(Id || Ctrl.GetChild(0))
    return __ControlGetTextExtentEx_Process(Ctrl.Hwnd, StrPtr(text), StrLen(text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Sets the text and adjusts the width of the control to fit all of the text. This
 * assumes there are no line breaks in the text. If the text has multiple lines, use
 * {@link ControlFitText}.
 * @param {dGui.Control|Gui.Control} Ctrl - The `Gui.Control` or `dGui.Control` object.
 * @param {String} [Text] - If set, the new text. If unset, the current text is used.
 * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
 * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height. If `AdjustHeight` is
 * zero or an empty string, this `PaddingY` is ignored.
 */
ControlSetTextEx(Ctrl, Text?, PaddingX := 0, PaddingY := 0) {
    if !IsSet(Text) {
        Text := Ctrl.Text
    }
    sz := Display_Size()
    context := SelectFontIntoDc(Ctrl.Hwnd)
    if Text is Integer {
        Text := String(Text)
    } else if IsObject(Text) {
        throw TypeError('Expected a string but received an object.')
    }
    if !DllCall('Gdi32.dll\GetTextExtentPoint32', 'ptr', context.hdc, 'ptr', StrPtr(Text), 'int', StrLen(Text), 'ptr', sz, 'int') {
        context()
        throw OSError()
    }
    context()
    Ctrl.Move(, , sz.W + PaddingX, sz.H + PaddingY)
    Ctrl.Text := Text
}
