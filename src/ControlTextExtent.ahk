
#include dGui.ahk
#include SelectFontIntoDc.ahk
#include Text.ahk
#include ..\struct
#include Display_IntegerArray.ahk
#include Display_Logfont.ahk
#include Display_Size.ahk

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
 * `Size` objects. If there is a blank line in `Ctrl.Text`, its associated index in `Lines` is an
 * empty string.
 */
ControlGetTextExtent(Ctrl) {
    W := H := 0
    sz := Display_Size()
    lines := StrSplit(Ctrl.Text, GetLineEnding(Ctrl.Text))
    context := SelectFontIntoDc(Ctrl.hWnd)
    for line in lines {
        if line {
            if DllCall('Gdi32.dll\GetTextExtentPoint32'
                , 'Ptr', context.hdc, 'Ptr', StrPtr(line), 'Int', StrLen(line), 'Ptr', sz, 'Int'
            ) {
                H += sz.H
                W := Max(W, sz.W)
                lines[A_Index] := sz
                sz := Display_Size()
            } else {
                context()
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.Text)
            , 'Int', StrLen(Ctrl.Text)
            , 'Ptr', sz := Display_Size()
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.Text[Index])
            , 'Int', StrLen(Ctrl.Text[Index])
            , 'Ptr', sz := Display_Size()
            , 'Int'
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
 * @param {Gui.Control} Ctrl - The control object.
 * @returns {Display_Size} - A {@link Display_Size} object with properties { Height, Width }.
 */
ControlGetTextExtent_Link(Ctrl) {
    context := SelectFontIntoDc(Ctrl.hWnd)
    ; Remove the html anchor tags
    Text := RegExReplace(Ctrl.Text, '<.+?"[ \t]*>(.+?)</a>', '$1')
    ; Measure the text
    if DllCall('Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', context.hdc
        , 'Ptr', StrPtr(Text)
        , 'Int', StrLen(Text)
        , 'Ptr', sz := Display_Size()
        , 'Int'
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
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [RowNumber] - If an integer, the row number of the item to measure. If an
 * array, an array of row numbers as integers. Leave unset to get the Size for items from all rows.
 * @param {Array|Integer} [ColumnNumber] - If an integer, the column number of the item to measure.
 * If an array, an array of column numbers as integers. Leave unset to get the Size for items from
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.GetText(r, c))
            , 'Int', StrLen(Ctrl.GetText(r, c))
            , 'Ptr', sz := Display_Size()
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
 * This version of the function is only appropriate for single-line strings.
 *
 * This version of the function has two usage options which depend on the value passed to `Count`.
 * {@link https://www.autohotkey.com/docs/v2/lib/TreeView.htm}.
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [Id = 0] - The id of the item to measure, or an array of ids. The ids are
 * passed to the `GetText` method. If `Id` is `0`, `TreeViewObj.GetChild(0)` is called, which returns
 * the top item in the TreeView.
 * @param {Integer} [Count] - If set, {@link ControlGetTextExtent_TV} traverses the TreeView starting from
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
        if DllCall('Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', context.hdc
            , 'Ptr', StrPtr(Ctrl.GetText(_id))
            , 'Int', StrLen(Ctrl.GetText(_id))
            , 'Ptr', sz := Display_Size()
            , 'Int'
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
 * This function is only appropriate for single-line strings. For multi-line usage,
 *
 * You can use this in two general ways.
 *
 * - Leave `MaxExtent` 0: `OutExtentPoints` will receive an `Display_IntegerArray` object, which will be a
 * buffer object containing the partial extent points of every character in the string. Said another
 * way, the integers in the array will be a cumulative representation of how wide the string is up
 * to that character, in pixels. E.g. "H" is 3 pixels wide, "He" is 6 pixels wide, "Hel" is 8 pixels
 * wide, etc. `OutCharacterFit` is not measured in this usage of the function, and will receive 0.
 *
 * - Set `MaxExtent` with a maximum width in pixels: `OutCharacterFit` is assigned the maximum
 * number of characters in the string that can fit `MaxExtent` pixels without going over.
 * `OutExtentPoints` is assigned an `Display_IntegerArray` object, but in this case it only contains the
 * partial extent points up to `OutCharacterFit` number of characters.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 *
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `Display_IntegerArray`. See the
 * function description for further details.
 * @returns {Size} - The `Size` object with properties { Height, Width }.
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
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `Display_IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Size} - The `Size` object with properties { Height, Width }.
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
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `Display_IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Size} - The `Size` object with properties { Height, Width }.
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
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `Display_IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Size} - The `Size` object with properties { Height, Width }.
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
 * @param {Integer} [Id = 0] - The Id of the item to measure. If `Id` is `0`, the first item in the
 * TreeView is measured.
 * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
 * for {@link ControlGetTextExtentEx} for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `Display_IntegerArray`. See the function
 * description for {@link ControlGetTextExtentEx} for further details.
 * @returns {Size} - The `Size` object with properties { Height, Width }.
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
            , 'ptr', OutExtentPoints := Display_IntegerArray(cchString)     ; An array to receives partial string extents.
            , 'ptr', sz := Display_Size()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := NumGet(lpnFit, 0, 'int')
            context()
            return sz
        } else {
            context()
            throw OSError()
        }
    } else {
        if DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', context.hdc
            , 'ptr', Ptr                                            ; String to measure
            , 'int', cchString                                      ; String length in WORDs
            , 'int', 0
            , 'ptr', 0
            , 'ptr', OutExtentPoints := Display_IntegerArray(cchString)     ; An array to receives partial string extents.
            , 'ptr', sz := Display_Size()                                   ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharacterFit := 0
            context()
            return sz
        } else {
            context()
            throw OSError()
        }
    }
}

/**
 * @description - Sets the text and adjusts the width of the control to fit all of the text. This
 * assumes there are no line breaks in the text. If the text has multiple lines, use
 * {@link Display_ControlFitText}.
 * @param {Gui.Control} Ctrl - The `Gui.Control` or `dGui.Control` object.
 * @param {String} [Text] - If set, the new text. If unset, the current text is used.
 * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
 * @param {Boolean} [AdjustHeight = false] - If true, the height will be adjusted to the vertical
 * extent of the text + `PaddingY`. If false, the height is not changed.
 * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height. If `AdjustHeight` is
 * zero or an empty string, this `PaddingY` is ignored.
 * @param {Integer} [MaxWidth] - If set, and if the horizontal extent of `Text` plus `PaddingX`
 * exceeds `MaxWidth`, the width of `Ctrl` will be adjusted to `MaxWidth`.
 */
ControlSetTextEx(Ctrl, Text?, PaddingX := 0, AdjustHeight := false, PaddingY := 0, MaxWidth?) {
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
    if !DllCall('Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', context.hdc, 'Ptr', StrPtr(Text), 'Int', StrLen(Text), 'Ptr', sz, 'Int'
    ) {
        context()
        throw OSError()
    }
    context()
    if IsSet(PaddingY) {
        H := sz.H + PaddingY
    }
    if IsSet(MaxWidth) {
        Ctrl.Move(, , Min(sz.W + PaddingX, MaxWidth), H ?? unset)
    } else {
        Ctrl.Move(, , sz.W + PaddingX, H ?? unset)
    }
    Ctrl.Text := Text
}
_ControlGetTextEx(Ctrl) {
    return Ctrl.Text
}

/**
 * @classdesc - Resizes a control according to its text contents.
 *
 * To correctly evaluate the needed dimensions, an instance of
 * {@link Display_ControlFitText.TextExtentPadding} is required. Leave the `UseCache` parameter set with
 * `true` to direct `Display_ControlFitText` of {@link Display_ControlFitText.MaxWidth} to cache the value for each control
 * type, and use the cached value when available.
 *
 * `Display_ControlFitText`, {@link Display_ControlFitText.MaxWidth}, and {@link Display_ControlFitText.TextExtentPadding} require
 * `dGui.Control` objects; `Gui.Control` objects will not work without additional preparation (not
 * described here).
 *
 * You can use the "_S" suffix to set the thread dpi awareness context to the default value before
 * calling either function.
 * @see {@link Display_ControlFitText.__Call}.
 *
 * {@link Display_ControlFitText.TextExtentPadding} is an imperfect approximation of the padding added to a control's
 * area that displays the text. To get the correct dimensions, each control's text content would
 * have to be evaluated individually. However, any discrepencies will likely be unnoticeable, and
 * you can account for discrepencies by adding an additional pixel or two using the `PaddingX` or
 * `PaddingY` parameters. In most cases you shouldn't need to use additional padding. In my tests,
 * the most common problem was edit controls wrapping text when using a vertical scrollbar. `dGui`
 * accounts for this using the {@link dGui.ScrollbarPadding} value (set in the project config file), but
 * for standard edit controls you will likely need to set `PaddingX` to 1 for edit controls that
 * use a vertical scrollbar.
 *
 * Not all controls are compatible with `Display_ControlFitText` and {@link Display_ControlFitText.MaxWidth}.
 * `Display_ControlFitText` will not evaluate the size correctly unless the control satisfies the following
 * conditions:
 * - `Ctrl.Text` must return a string that is the same as the text that is displayed in the gui.
 * - `Ctrl.GetPos`, when called directly after adding a control to a gui, must return the dimensions
 * of the control that is relevant to the text's bounding rectangle.
 * - `Ctrl.Move` must resize the portion of the control that is relevant to the text's bounding
 * rectangle.
 *
 * Invalid control types: DateTime, DropDownList, GroupBox, Hotkey, ListBox, ListView, MonthCal,
 * Picture, Progress, Slider, Tab, Tab2, Tab3, TreeView, and UpDown.
 *
 * Valid control types: ActiveX (possibly), Button, CheckBox, ComboBox, Custom (possibly), Edit,
 * Radio, Text.
 *
 * Additional notes:
 *
 * Be aware that {@link Display_ControlFitText.TextExtentPadding.__New} calls `CtrlObj.GetTextExtent`. Some
 * control types require additional parameters passed to "GetTextExtent". This shouldn't be an issue
 * because those control types are invalid candidates for `Display_ControlFitText`. However, if you experiment
 * with `Display_ControlFitText` and you get an error "Too few parameters passed to function", just cache
 * a {@link Display_ControlFitText.TextExtentPadding} object:
 * @example
 * ; Assume `Ctrl` is some `dGui.Control` object and `Params` is an array of parameters for
 * ; `Ctrl.GetTextExtent`.
 * Display_ControlFitText.Cache.Set(Ctrl.Type, Display_ControlFitText.TextExtentPadding(Ctrl, , Params))
 * @
 *
 * CheckBox and Radio controls are valid even though they have the checkbox consuming additional
 * width. This is because {@link Display_ControlFitText.TextExtentPadding} will evaluate that width in its output,
 * so the additional width is accounted for.
 *
 * Link controls are not valid because `LinkCtrl.Text` returns the xml content.
 *
 * ListView controls inherently are poor candidates for `Display_ControlFitText` because they have
 * additional methods / system messages that make it easier to adjust the size of the control according
 * to the text. The additional work required to make `Display_ControlFitText` work with ListView controls
 * exceeds that required to use existing methods.
 */
class Display_ControlFitText {
    static __New() {
        this.DeleteProp('__New')
        this.Cache := this.TextExtentPaddingCollection()
    }

    /**
     * @description - `Display_ControlFitText` returns the width and height for a control to fit its text
     * contents, plus any additional padding.
     *
     * @param {dGui.Control} Ctrl - The control object. See the notes in the class description above
     * {@link Display_ControlFitText} for compatibility requirements.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * {@link Display_ControlFitText.TextExtentPadding}. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of `Size` objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
     * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutWidth` and `OutHeight`. If false, the calculations are performed
     * without moving the control.
     */
    static Call(Ctrl, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutWidth?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(Ctrl.Text, GetLineEnding(Ctrl.Text))
        context := SelectFontIntoDc(Ctrl.hWnd)
        GetMultiExtentPoints(context.hDc, OutExtentPoints, &OutWidth, , true)
        context()
        OutHeight := 0
        if UseCache {
            if !this.Cache.Has(Ctrl.Type) {
                this.Cache.Set(Ctrl.Type, this.TextExtentPadding(Ctrl))
            }
            Padding := this.Cache.Get(Ctrl.Type)
        } else {
            Padding := this.TextExtentPadding(Ctrl)
        }
        OutWidth += PaddingX + Padding.Width
        for sz in OutExtentPoints {
            if sz {
                OutHeight += sz.H + Padding.LinePadding
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        OutHeight += PaddingY + Padding.Height + Padding.LinePadding * OutExtentPoints.Length
        if MoveControl {
            Ctrl.Move(, , OutWidth, OutHeight)
        }
    }

    /**
     * @description - {@link Display_ControlFitText.MaxWidth} resizes a control to fit the text contents of the
     * control plus any additional padding while limiting the width of the control to a maximum value.
     * Note that {@link Display_ControlFitText.MaxWidth} does not include the width value when calling `Ctrl.Move`;
     * it is assumed your code has handled setting the width.
     *
     * @param {dGui.Control} Ctrl - The control object. See the notes in the class description above
     * {@link Display_ControlFitText} for compatibility requirements.
     * @param {Integer} [MaxWidth] - The maximum width in pixels. If unset, uses the controls current
     * width.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * {@link Display_ControlFitText.TextExtentPadding}. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of `Size` objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutHeight] - A variable that will receive an integer value representing the
     * height that was passed to `Ctrl.Move`.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutHeight`. If false, the calculations are performed without moving
     * the control.
     */
    static MaxWidth(Ctrl, MaxWidth?, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(Ctrl.Text, GetLineEnding(Ctrl.Text))
        context := SelectFontIntoDc(Ctrl.hWnd)
        GetMultiExtentPoints(context.hDc, OutExtentPoints, &OutWidth, , true)
        context()
        if !IsSet(MaxWidth) {
            Ctrl.GetPos(, , &MaxWidth)
        }
        if UseCache {
            if !this.Cache.Has(Ctrl.Type) {
                this.Cache.Set(Ctrl.Type, this.TextExtentPadding(Ctrl))
            }
            Padding := this.Cache.Get(Ctrl.Type)
        } else {
            Padding := this.TextExtentPadding(Ctrl)
        }
        MaxWidth -= Padding.Width + PaddingX
        OutHeight := PaddingY + Padding.Height
        for sz in OutExtentPoints {
            if sz {
                lines := Ceil(sz.W / MaxWidth)
                OutHeight += (sz.H + Padding.LinePadding) * lines
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        if MoveControl {
            Ctrl.Move(, , , OutHeight)
        }
    }

    class TextExtentPadding {
        /**
         * An instance of {@link Display_ControlFitText.TextExtentPadding} has four properties:
         * - {@link Display_ControlFitText.TextExtentPadding#Width} - The padding added to the text's extent
         * along the X axis.
         * - {@link Display_ControlFitText.TextExtentPadding#Height} - The padding added to the text's extent
         * along the Y axis, not including the padding added for each individual line.
         * - {@link Display_ControlFitText.TextExtentPadding#LinePadding} - The padding added to the text's
         * extent along the Y axis for each individual line.
         * - {@link Display_ControlFitText.TextExtentPadding#LineHeight} - The approximate height of an
         * blank line.
         *
         * The values of each property are approximations. See the description above
         * {@link Display_ControlFitText} for more details and limitations.
         * @class
         *
         * @param {dGui.Control} Ctrl - The control object.
         * @param {String} [Opt = ""] - Options to pass to `Gui.Prototype.Add`.
         * @param {Array} [GetTextExtentParams] - Some control types require additional parameters
         * passed to `CtrlObj.GetTextExtent`. Set `GetTextExtentParams` with an array of parameters
         * to pass to the method.
         * @param {Integer} [ThreadDpiAwarenessContext] - If set, {@link Display_ControlFitText.TextExtentPadding.__New}
         * calls `SetThreadDpiAwarenessContext` at the beginning, and calls it again before returning
         * to set the thread's context to its original value.
         */
        __New(Ctrl, Opt := '', GetTextExtentParams?, ThreadDpiAwarenessContext?) {
            if IsSet(ThreadDpiAwarenessContext) {
                originalContext := SetThreadDpiAwarenessContext(ThreadDpiAwarenessContext)
            }
            lf := Display_Logfont(Ctrl.Hwnd)
            G := dGui()
            opt := 's' lf.FontSize ' w' lf.Weight
            if lf.Quality {
                opt .= ' q' lf.Quality
            }
            if lf.Italic {
                opt .= ' italic'
            }
            if lf.StrikeOut {
                opt .= ' strike'
            }
            if lf.Underline {
                opt .= ' underline'
            }
            G.SetFont(opt, lf.FaceName)
            _ctrl := G.Add(Ctrl.Type, Opt, 'line')
            _ctrl.GetPos(, , , &h)
            _ctrl2 := G.Add(Ctrl.Type, Opt, 'line`r`nline')
            _ctrl2.GetPos(, , &w2, &h2)
            if IsSet(GetTextExtentParams) {
                sz := _ctrl.GetTextExtent(GetTextExtentParams*)
                sz2 := _ctrl2.GetTextExtent(GetTextExtentParams*)
            } else {
                sz := _ctrl.GetTextExtent()
                sz2 := _ctrl2.GetTextExtent()
            }
            G.Destroy()
            this.Width := w2 - sz2.W
            this.Height := h - sz.H
            this.LinePadding := h2 - sz2.H - h + sz.H
            this.LineHeight := (h2 - this.Height) / 2
            if IsSet(originalContext) {
                SetThreadDpiAwarenessContext(originalContext)
            }
        }
    }

    class TextExtentPaddingCollection extends Map {
    }
}
