/**
    "Unicode supplementary characters (where Number is in the range 0x10000 to 0x10FFFF) are counted
    as two characters. That is, the length of the return value as reported by StrLen may be 1 or 2.
    For further explanation, see String Encoding."
    {@link https://www.autohotkey.com/docs/v2/lib/Chr.htm}
    {@link https://www.autohotkey.com/docs/v2/Concepts.htm#string-encoding}
*/

/**
 * @description - Gets the height and width in pixels of the string contents of a Gui control.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w}
 * @param {String} Ctrl - The `Gui.Control` object.
 * @returns {SIZE} - A `SIZE` object with properties { Width, Height }.
 */
ControlGetTextExtent(Ctrl) {
    ; Get device context
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    ; Measure the text
    Result := DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', hDC
        , 'Ptr', StrPtr(Text)
        , 'Int', StrLen(Text)
        , 'Ptr', sz := SIZE()
    )
    if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
        throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
    }
    if Result {
        return sz
    }
    throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
}

/**
 * @description - Gets the height and width in pixels of the string contents of a ListBox control.
 * When ListBox controls are created, one of the options available is `Multi`. When `Multi` is in use,
 * the `Text` property returns an array of selected items. This version of the function has an
 * optional `Index` parameter to allow you to specify which item to measure. When unset, all items
 * in the array are measured. If a listbox is created without the `Multi` option, the `Index`
 * property has no effect because the `Text` property will return a string.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [Index] - If an integer, the index of the item to measure. If unset, all items
 * returned by the `Text` property are measured.
 * @returns {Array} - An array of objects with properties { Index, Width, Height }.
 */
ControlGetTextExtent_LB(Ctrl, Index?) {
    Result := []
    ; Get device context
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    if Ctrl.Text is Array {
        if IsSet(Index) {
            _Proc()
        } else {
            Index := 0
            loop Result.Capacity := Text.Length {
                ++Index
                _Proc()
            }
        }
    } else {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', hDC
            , 'Ptr', StrPtr(Ctrl.Text)
            , 'Int', StrLen(Ctrl.Text)
            , 'Ptr', sz := SIZE()
        ) {
            Result.Push({ Index: Index, Size: sz })
        } else {
            _Release()
            throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
        }
    }
    _Release()
    return Result

    _Proc() {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', hDC
            , 'Ptr', StrPtr(Ctrl.Text[Index])
            , 'Int', StrLen(Ctrl.Text[Index])
            , 'Ptr', sz := SIZE()
        ) {
            sz.Index := Index
            Result.Push(sz)
        } else {
            _Release()
            throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
        }
    }
    _Release() {
        if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
            throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
        }
    }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a link control.
 * Since the content displayed by a link control is different than the string returned by its `Text`
 * property, this version of the function removes the anchor html tags from the string and only
 * measures the inner text.
 * @param {Gui.Control} Ctrl - The control object.
 */
ControlGetTextExtent_Link(Ctrl) {
    ; Get device context
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    ; Remove the html anchor tags
    Text := RegExReplace(Ctrl.Text, '<.+?"[ \t]*>(.+?)</a>', '$1')
    ; Measure the text
    Result := DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
        , 'Ptr', hDC
        , 'Ptr', StrPtr(Text)
        , 'Int', StrLen(Text)
        , 'Ptr', sz := SIZE()
    )
    ; Release the DC.
    if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
        throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
    }
    if Result {
        return sz
    }
    throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
}

/**
 * @description - Gets the height and width in pixels of the string contents of a ListView control.
 * This version of the function has `RowNumber` and `ColumnNumber` parameters to pass to the the
 * `GetText` method of the control.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [RowNumber] - If an integer, the row number of the item to measure. If an
 * array, an array of row numbers as integers. Leave unset to get the SIZE for items from all rows.
 * @param {Array|Integer} [ColumnNumber] - If an integer, the column number of the item to measure.
 * If an array, an array of column numbers as integers. Leave unset to get the SIZE for items from
 * all columns.
 * @returns {Array} - An array of objects with properties { Row, Column, Width, Height }.
 */
ControlGetTextExtent_LV(Ctrl, RowNumber?, ColumnNumber?) {
    ; Get device context
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
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
                    _Proc()
                }
            }
        } else {
            Result.Capacity := RowNumber.Length
            c := ColumnNumber
            for r in RowNumber {
                _Proc()
            }
        }
    } else {
        r := RowNumber
        if IsObject(ColumnNumber) {
            Result.Capacity := ColumnNumber.Length
            for c in ColumnNumber {
                _Proc()
            }
        } else {
            c := ColumnNumber
            _Proc()
        }
    }

    return Result

    _Proc() {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', hDC
            , 'Ptr', StrPtr(Ctrl.GetText(r, c))
            , 'Int', StrLen(Ctrl.GetText(r, c))
            , 'Ptr', sz := SIZE()
        ) {
            sz.Row := r
            sz.Column := c
            Result.Push(sz)
        } else {
            _Release()
            throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
        }
    }
    _Release() {
        if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
            throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
        }
    }
}

/**
 * @description - Gets the height and width in pixels of the string contents of a TreeView control.
 * This version of the function has two usage options.
 * - If you set the `Id` parameter with an item id or an array of id,
 * - You can optionally set `Count`, which will
 * {@link https://www.autohotkey.com/docs/v2/lib/TreeView.htm}.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} [Id := 0] - The ID of the item to measure, or an array of IDs. The ids are
 * passed to the `GetText` method. If `Id` is `0`, `TreeViewObj.GetChild(0)` is called, which returns
 * the top item in the TreeView.
 * @param {Integer} [Count] - If set, `ControlGetTextExtent_TV` traverses the TreeView starting from
 * `Id` for `Count` items, or until the last item is measured. If `Count` is 0, all items after `Id`
 * are measured.
 * @returns {Array} - An array of objects with properties { Id, Width, Height }.
 */
ControlGetTextExtent_TV(Ctrl, Id := 0, Count?) {
    ; Get device context
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    Result := []
    if Id is Array {
        loop Id.Length {
            _id := Id[A_Index]
            _Proc()
        }
    } else {
        if !Id {
            _id := Ctrl.GetChild(0)
        }
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

    return Result

    _Proc() {
        ; Measure the text
        if DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
            , 'Ptr', hDC
            , 'Ptr', StrPtr(Ctrl.GetText(_id))
            , 'Int', StrLen(Ctrl.GetText(_id))
            , 'Ptr', sz := SIZE()
        ) {
            sz.Id := _id
            Result.Push(sz)
        } else {
            _Release()
            throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
        }
    }
    _Release() {
        if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
            throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
        }
    }
}

/**
 * @description - Calls `GetTextExtentExPoint` using the control as context. You can use this in
 * two general ways.
 * - Leave `nMaxExtent` 0: `OutExtentPoints` will receive an `IntegerArray` object, which will be a
 * buffer object containing the partial extent points of every character in the string. Said another
 * way, the integers in the array will be a cumulative representation of how wide the string is up
 * to that character, in pixels. E.g. "H" is 3 pixels wide, "He" is 6 pixels wide, "Hel" is 8 pixels
 * wide, etc. `OutCharacterFit` is not measured in this usage of the function, and will receive 0.
 * - Set `nMaxExtent` with a maximum width in pixels: `OutCharacterFit` is assigned the maximum
 * number of characters in the string that can fit `nMaxExtent` pixels without going over.
 * `OutExtentPoints` is assigned an `IntegerArray` object, but in this case it only contains the
 * partial extent points up to `OutCharacterFit` number of characters.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentexpointa}
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `nMaxExtent` pixels. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the
 * function description for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Width, Height }.
 */
ControlGetTextExtentEx(Ctrl, nMaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    return __ControlGetTextExtentEx_Process(StrPtr(Ctrl.Text), StrLen(Ctrl.Text), &nMaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the ListBox control as context. If the `ListBox`
 * has the `Multi` option active, use the `Index` parameter to specify which item to measure. If
 * the `ListBox` does not have the `Multi` option active, leave `Index` unset. See the parameter hint
 * for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [Index] - The index of the item to measure. Leave unset if the `ListBox` does
 * not have the `Multi` option active.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `nMaxExtent` pixels. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the
 * function description for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Width, Height }.
 */
ControlGetTextExtentEx_LB(Ctrl, Index?, nMaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if IsSet(Index) {
        return __ControlGetTextExtentEx_Process(StrPtr(Ctrl.Text[Index]), StrLen(Ctrl.Text[Index]), &nMaxExtent, &OutCharacterFit, &OutExtentPoints)
    } else {
        return __ControlGetTextExtentEx_Process(StrPtr(Ctrl.Text), StrLen(Ctrl.Text), &nMaxExtent, &OutCharacterFit, &OutExtentPoints)
    }
}

/**
 * @description - Calls `GetTextExtentExPoint` using the Link control as context.
 * Since the content displayed by a link control is different than the string returned by its `Text`
 * property, this version of the function removes the anchor html tags from the string and only
 * measures the inner text. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `nMaxExtent` pixels. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the
 * function description for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Width, Height }.
 */
CtrlTextExtentExPoint_Link(Ctrl, nMaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    ; Remove the html anchor tags
    Text := RegExReplace(Ctrl.Text, '<a\s*(?:href|id)=".+?">(.+?)</a>', '$1')
    return __ControlGetTextExtentEx_Process(StrPtr(Text), StrLen(Text), &nMaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the ListView control as context. This version of
 * the function has `RowNumber` and `ColumnNumber` parameters to pass to the ListView's `GetText`
 * method. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Array|Integer} RowNumber - The row number of the item to measure.
 * @param {Array|Integer} ColumnNumber - The column number of the item to measure.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `nMaxExtent` pixels. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the
 * function description for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Width, Height }.
 */
ControlGetTextExtentEx_LV(Ctrl, RowNumber, ColumnNumber, nMaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    return __ControlGetTextExtentEx_Process(StrPtr(Ctrl.GetText(RowNumber, ColumnNumber)), StrLen(Ctrl.GetText(RowNumber, ColumnNumber)), &nMaxExtent, &OutCharacterFit, &OutExtentPoints)
}

/**
 * @description - Calls `GetTextExtentExPoint` using the TreeView control as context. This version of
 * the function has an `Id` parameter to pass to the TreeView's `GetText` method. See the
 * parameter hint for {@link CtrlTextExtentExPoint} for full details.
 * @param {Gui.Control} Ctrl - The control object.
 * @param {Integer} [Id=0] - The Id of the item to measure. If `Id` is `0`, the first item in the
 * TreeView is measured.
 * @param {Integer} [nMaxExtent=0] - The maximum width of the string. See the function description
 * for further details.
 * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
 * that fit within `nMaxExtent` pixels. If `nMaxExtent` is 0, this will be set to 0.
 * @param {VarRef} [OutExtentPoints] - A variable that will receive an `IntegerArray`. See the
 * function description for further details.
 * @returns {SIZE} - The `SIZE` object with properties { Width, Height }.
 */
ControlGetTextExtentEx_TV(Ctrl, Id := 0, nMaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
    if !Id {
        Id := Ctrl.GetChild(0)
    }
    return __ControlGetTextExtentEx_Process(StrPtr(Ctrl.GetText(Id)), StrLen(Ctrl.GetText(Id)), &nMaxExtent, &OutCharacterFit, &OutExtentPoints)
}

__ControlGetTextExtentEx_Process(Ptr, cchString, &nMaxExtent, &OutCharacterFit, &OutExtentPoints) {
    ; Get device context
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -2, A_LastError)
    }
    if DllCall('Gdi32.dll\GetTextExtentExPoint'
        , 'ptr', hDC                                            ; Device context
        , 'ptr', Ptr                                            ; String to measure
        , 'int', cchString                                      ; String length in WORDs
        , 'int', nMaxExtent                                     ; Maximum width
        , 'ptr', lpnFit := nMaxExtent ? Buffer(4) : 0           ; To receive number of characters that can fit
        , 'ptr', OutExtentPoints := IntegerArray(cchString * 4) ; An array to receives partial string extents. Here it's null.
        , 'ptr', sz := Size()                                   ; To receive the dimensions of the string.
        , 'ptr'
    ) {
        _Release()
        OutCharacterFit := nMaxExtent ? NumGet(lpnFit, 0, 'int') : 0
        return sz
    } else {
        _Release()
        throw OSError('``GetTextExtentExPoint`` failed.', -1, A_LastError)
    }

    _Release() {
        if !DllCall('ReleaseDC', 'Ptr', Ctrl.hWnd, 'Ptr', hDC, 'int') {
            throw OSError('``ReleaseDC`` failed.', -1, A_LastError)
        }
    }
}

/**
 * @description - Wraps text to a maximum width in pixels, breaking at a space or tab character, or
 * at a breaking character defined by the `BreakChars` parameter. Any newline characters contained
 * in the input string are replaced with a space character prior to processing.
 * - Example using a control object, handling the adjustment externally from this function call:
 * @example
 *  G := Gui()
 *  Ctrl := G.Add('Text', , 'Original text.')
 *  ; Later, in some other portion of the code...
 *  ; User does some action that changes the text content of Ctrl
 *  Ctrl.Text := 'New text that needs to stay the same width.'
 *  ; We need to adjust the height of the control, keeping the width constant
 *  NewSize := WrapText(Ctrl, &NewStr)
 *  ; Perhaps we want to validate the size of the text before adjusting the control
 *  if NewSize.Height <= ArbitraryMaximum {
 *      Ctrl.Text := NewStr
 *      Ctrl.Move(, , , NewSize.Height)
 *  } else {
 *      HandleTooLargeInputFromUser(Txt, NewSize, NewStr)
 *  }
 * @
 * Example using a control object, allowing `WrapText` to make the adjustments:
 * @example
 *  G := Gui()
 *  Txt := G.Add('Text', , 'Original text.')
 *  ; Later, in some other portion of the code...
 *  ; User does some action that changes the text content of Ctrl
 *  Txt.Text := 'New text that needs to stay the same width.'
 *  ; Pass `true` to have `WrapText` update the control automatically
 *  WrapText(Txt, , , , true)
 * @
 * Example usign an input string:
 * @example
 *  ; The maximum width is defined, but the actual text is unknown until the user does some action.
 *  ; The control will be using the same font as neighboring controls, so we use one for the
 *  ; device context.
 *  MaxWidth := 290
 *  G := Gui()
 *  G.Add('Button', 'vBtnInput', 'Click me.').OnEvent('Click', HButtonClickGetInput)
 *  HButtonClickGetInput(Ctrl, *) {
 *      G := Ctrl.Gui
 *      if (Response := InputBox('Input text.', , , 'Lorem ipsum dolor sit amet consectetur adipiscing,'
 *      ' elit nostra interdum ut ad nec bibendum, semper quis lacinia condimentum blandit.')).Result == 'Cancel' {
 *          return
 *      }
 *      Str := Response.Value
 *      NewSize := WrapText(G['TxtInfo'], &Str, MaxWidth)
 *      G['TxtInfo'].GetPos(&X, &Y, , &H)
 *      MyGui.Add('Text', Format('X{} Y{} W{} H{}', X, Y + H + 10, MaxWidth, NewSize.Height), Str)
 *  }
 *  G.SetFont('s11 q5', 'Calisto')
 *  G.Add('Text', 'w' MaxWidth ' vTxtInfo', 'This is an example script to showcase ``WrapText``.')
 *  G.Show()
 * @
 * @param {Gui.Control|Integer} hDC_or_Control - Either a device context to use to measure the text,
 * or a control object that will be used to obtain the device context.
 * @param {VarRef} Str - A variable that will receive the result string.
 * - If you set `Str` with a string value, `WrapText` processes that value.
 * - If `hDC_or_Control` is a `Gui.Control` object, then `Str` is optional. If you leave it unset,
 * or pass it as an unset VarRef / empty string VarRef, then `WrapText` processes the contents of
 * `hDC_or_Control.Text`.
 * @param {Integer} [MaxWidth] - The maximum width in pixels to wrap the text to. If unset and if
 * `hDC_or_Control` is a `Gui.Control` object, the control's current width is used.
 * @param {String} [BreakChars='-'] - `BreakChars` is a string containing any characters which you
 * want to be used as breakpoint characters.
 *
 * When this function breaks a line, it will break at either a space, a tab, or after any character
 * defined by this class.
 * @example
 *  BreakChars := '-'
 *  Str := "The next step is to compile the code, then our command-line application is ready."
 *  MaxWidth :=  265
 *  WrapText(SomeCtrl, &Str, MaxWidth, BreakChars)
 *  ; The line breaks at the character following the hyphen.
 *  MsgBox(Str) ; ...then our command-`nline application
 * @
 *
 * If a single sequence of non-breakpoint characters exceeds `MaxWidth` pixels, the characters are
 * split and hyphenated at the largest character with the greatest extent point that does not exceed
 * `MaxWidth`.
 *
 * Newline characters are ignored; they are removed from the string prior to processing.
 *
 * If a line breaks on a space or tab character, the space or tab is removed from the string. If a
 * line breaks on any other type of breakpoint character, any subsequent consecutive spaces or tabs
 * are removed. Since most natural breaking characters are followed by a space anyway, defining
 * additional characters in `BreakChars` may not influence new behavior from `WrapText`. For example,
 * if I include a semicolon in the class, and my string is "A subject is here; a predicate goes there;
 * a conjunction finds a way to join them.", the semicolon won't change the result. Adding additional
 * breakpoint characters will only influence new behavior if there is a possibility the breakpoint
 * character is followed by a character that is not a whitespace character.
 */
ControlWrapText(Ctrl, &Str?, MaxWidth?, BreakChars := '-', AdjustControl := false, Newline := '`r`n') {
    local lpnFit, lpDx, lpSize
    if IsObject(Text := Str ?? Ctrl.Text) {
        throw TypeError(' The control`'s ``Text`` property returned a non-string value.', -1
        , 'Type: ' Type(Text))
    }
    ; Replace newlines with space.
    Text := RegExReplace(Text, '\R', ' ')
    ; If MaxWidth is unset, use the width of the control.
    if !IsSet(MaxWidth) {
        Ctrl.GetPos(, , &MaxWidth)
    }
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hWnd)) {
        throw OSError('``GetDC`` failed.', -1, A_LastError)
    }
    ; Get the length of the string in WORDs.
    cchString := Len

    pattern := '(?:(?<breakchar>[' BreakChars '])|(?<whitespace>[`s`t])).*$'
    Str := ''
    loop 100 {
        Len := StrLen(Text)
        _Measure()
        ; If we have reached the end of the string
        if NumGet(lpnFit, 0, 'int') >= Len {
            Str .= Text
            if AdjustControl {
                Ctrl.Text := Str
                Ctrl.Move(, , , lpnSize.Height)
            }
            DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
            return lpnSize
        }
        ; If there is a breakpoint character within the maximum width
        if RegExMatch(SubStr(text, 1, lpnFit - 1), pattern, &Match) {
            Str .= SubStr(Text, 1, Index := Match.Pos + (Match['breakchar'] ? 1 : 0)) Newline
            _ProcessText()
        ; If there is not a breakpoint characters within the maximum width
        } else {
            if !IsSet(HyphenExtent) {
                ; Measure the hyphen
                if !DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32'
                    , 'Ptr', hDC
                    , 'Str', '-'
                    , 'Int', 1
                    , 'Ptr', sz := SIZE()
                ) {
                    throw OSError('``GetTextExtentPoint32`` failed.', -1, A_LastError)
                }
                HyphenExtent := sz.Width
            }
            loop 100 {
                if lpnDx[lpnFit - A_Index] + HyphenExtent <= MaxWidth {
                    Index := A_Index
                    break
                }
            }
            if !IsSet(Index) {
                throw Error('1. The loop iterated for 100 iterations; there`'s a logical error in the function.', -1)
            }
            Str .= SubStr(Text, 1, Index) '-' Newline
            _ProcessText()
        }
        _Measure()
    }
    DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
    throw Error('2. The loop iterated for 100 iterations; there`'s a logical error in the function.', -1)

    _Measure() {
        ; Measure the text
        if !DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hDC                                            ; Device context
            , 'ptr', StrPtr(Text)                                   ; String to measure
            , 'int', cchString                                      ; String length in WORDs
            , 'int', MaxWidth                                       ; Maximum width
            , 'ptr', lpnFit := nMaxExtent ? Buffer(4) : 0           ; To receive number of characters that can fit
            , 'ptr', lpDx := IntegerArray(cchString * 4)            ; An array to receives partial string extents.
            , 'ptr', lpSize := Buffer(8)                            ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            throw OSError('``GetTextExtentExPoint`` failed.', -1, A_LastError)
        }
    }

    _ProcessText() {
        ; Skip any whitespace characters
        if RegExMatch(Text, '^[ \t]+', &MatchWhitespace, Index + 1) {
            Text := SubStr(Text, Index + MatchWhitespace.Len)
        } else {
            Text := SubStr(Text, Index + 1)
        }
    }
}
