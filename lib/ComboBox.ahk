
; Dependency
#include ..\definitions\define-ComboBox.ahk

/**
 * @description - Shows or hides the combobox's dropdown.
 * @param {ComboBox} ComboBox - The ComboBox object to show the dropdown for.
 * @param {Integer} [Value=1] - The value to pass to the `CB_SHOWDROPDOWN` message. 1 shows the
 * dropdown, 0 hides it.
 */
GuiCb_ShowDropdown(ComboBox, Value := 1) {
    SendMessage(CB_SHOWDROPDOWN, Value, 0, ComboBox.hWnd)
    return ''
}


/**
 * @description - Sets the minimum number of items to display in the dropdown.
 * @param {ComboBox} ComboBox - The ComboBox object to set the minimum number of items for.
 * @param {Integer} MinVisible - The minimum number of items to display in the dropdown.
 */
GuiCb_SetMinVisible(ComboBox, MinVisible) {
    SendMessage(CB_SETMINVISIBLE, MinVisible, 0, ComboBox.hWnd)
    return ''
}


/**
 * @description - Applies these to the ComboBox control:
 * - `Focus` event opens the dropdown.
 * - `LoseFocus` event closes the dropdown.
 * - Adds methods `AddEx` and `DeleteEx`, which you should use to add / remove items for as long as
 * this function is active. If you don't, your filter will be temporarily out of sync.
 * - `Change` event calls a filter function. The filter function will temporarily remove any items
 * from the combobox that do not contain the string that is within its edit banner. Specifically,
 * this sequence of actions occur:
 *   - Disables the change event handler and sets a timer that repeatedly checks if the text has
 * changed in the edit banner.
 *   - Processes the text that invoked the change event. Any items which do not contain the
 * input text are deleted from the combobox as well as from the array which you pass to the `Arr`
 * parameter (which is set to `ComboBox.__Arr`), and places them in a separate array for filtered
 * items (`ComboBox.__Filter`).
 *   - Repeatedly checks to see if the text has changed every 100 ms, synchronizing the filtered
 * items with any changes to the text.
 *   - When 500ms passes without a change being detected, disables the timer an re-enables the
 * change event handler.
 * @param {ComboBox} ComboBox - The ComboBox object to set the filter on.
 * @param {Array} Arr - The array that contains the words displayed by the combobox. This gets set
 * to `ComboBox.__Arr`.
 * @param {Integer} [MaxVisible=20] - The maximum rows of items to display in the dropdown.
 * @param {Integer} [AddRemove=1] - The value that gets passed to the third parameter of
 * `Gui.Control.Prototype.OnEvent`. Call this function with an `AddRemove` value of 0 to delete
 * the properties associated with the filter and to unset the event handlers.
 */
GuiCb_SetFilterOnChange(ComboBox, Arr, MaxVisible := 20, AddRemove := 1) {
    if !AddRemove {
        _DisposeFilter()
        return
    }
    ComboBox.OnEvent('Focus', HFocusComboBox, AddRemove)
    ; ComboBox.OnEvent('LoseFocus', HLoseFocusComboBox, AddRemove)
    ComboBox.OnEvent('Change', HChangeComboBox, AddRemove)
    ComboBox.__Arr := Arr
    ComboBox.__Transitory := []
    ComboBox.__Filter := []
    ComboBox.__Transitory.Capacity := ComboBox.__Filter.Capacity := Arr.Length
    ComboBox.__MaxVisible := MaxVisible
    ComboBox.__PreviousText := ''
    ComboBox.DefineProp('AddEx', { Call: AddEx })
    ComboBox.DefineProp('DeleteEx', { Call: DeleteEx })

    return ''

    HChangeComboBox(Ctrl, Item) {
        Time := A_TickCount
        Arr := Ctrl.__Arr
        Transitory := Ctrl.__Transitory
        Filter := Ctrl.__Filter
        Ctrl.OnEvent('Change', HChangeComboBox, 0)
        _Search()

        _Search() {
            loop {
                if Ctrl.__PreviousText == Ctrl.Text {
                    sleep 100
                    if A_TickCount - Time > 500 {
                        break
                    }
                    continue
                }
                if Ctrl.Text {
                    ; If the user added a character, then we only need to filter our current
                    ; filtered list, not the entire list.
                    if Ctrl.Text && (!Ctrl.__PreviousText || (StrLen(Ctrl.Text) > StrLen(Ctrl.__PreviousText) && InStr(Ctrl.Text, Ctrl.__PreviousText) == 1)) {
                        n := 0
                        for Item in Ctrl.__Arr {
                            if !InStr(Item, Ctrl.Text) {
                                Ctrl.__Transitory.Push(A_Index)
                            }
                        }
                        for Index in Ctrl.__Transitory {
                            Ctrl.__Filter.Push(Ctrl.__Arr.RemoveAt(Index - n))
                            Ctrl.Delete(Index - n)
                            n++
                        }
                        Ctrl.__Transitory := []
                        Ctrl.__Transitory.Capacity := Ctrl.__Arr.Capacity
                    } else if Ctrl.Text {
                        i := Ctrl.__Arr.Length
                        List := []
                        List.Capacity := Ctrl.__Arr.Length
                        for Item in Ctrl.__Filter {
                            if InStr(Item, Ctrl.Text) {
                                List.Push(Item)
                                Ctrl.__Arr.Push(Item)
                                Ctrl.__Transitory.Push(A_Index)
                            }
                        }
                        if List.Length {
                            Ctrl.Add(List)
                        }
                        n := 0
                        for Index in Ctrl.__Transitory {
                            Ctrl.__Filter.RemoveAt(Index - n)
                            n++
                        }
                        Ctrl.__Transitory := []
                        Ctrl.__Transitory.Capacity := Ctrl.__Arr.Length
                        loop i {
                            if !InStr(Ctrl.__Arr[A_Index], Ctrl.Text) {
                                Ctrl.__Transitory.Push(A_Index)
                            }
                        }
                        n := 0
                        for Index in Ctrl.__Transitory {
                            Ctrl.__Filter.Push(Ctrl.__Arr.RemoveAt(Index - n))
                            Ctrl.Delete(Index - n)
                            n++
                        }
                        Ctrl.__Transitory := []
                        Ctrl.__Transitory.Capacity := Ctrl.__Arr.Length
                    } else {
                        _ResetFilter(Ctrl)
                    }
                } else {
                    _ResetFilter(Ctrl)
                }
                Ctrl.__PreviousText := Ctrl.Text
                Time := A_TickCount
            }
            Ctrl.OnEvent('Change', HChangeComboBox, 1)
            Time := 0
        }
    }

    HFocusComboBox(Ctrl, *) {
        if !SendMessage(CB_GETDROPPEDSTATE, 0, 0, Ctrl.hWnd) {
            SendMessage(CB_SHOWDROPDOWN, 1, 0, Ctrl.hWnd)
        }
    }
    ; HLoseFocusComboBox(Ctrl, *) {
    ;     if SendMessage(CB_GETDROPPEDSTATE, 0, 0, Ctrl.hWnd) {
    ;         SendMessage(CB_SHOWDROPDOWN, 0, 0, Ctrl.hWnd)
    ;     }
    ; }
    _ResetFilter(Ctrl) {
        Ctrl.Add(Ctrl.__Filter)
        Ctrl.__Arr.Push(Ctrl.__Filter*)
        Ctrl.__Filter := []
        Ctrl.__Filter.Capacity := Ctrl.__Arr.Length
    }
    AddEx(Ctrl, Item) {
        if Ctrl.Text && InStr(Item, Ctrl.Text) {
            Ctrl.__Arr.Push(Item)
            Ctrl.Add([Item])
        } else {
            Ctrl.__Filter.Push(Item)
        }
    }
    DeleteEx(Ctrl, Str) {
        if (Ctrl.Text && InStr(Str, Ctrl.Text)) || !Ctrl.Text {
            for Item in Ctrl.__Arr {
                if Item = Str {
                    Ctrl.__Arr.RemoveAt(A_Index)
                    Ctrl.Delete(A_Index)
                    break
                }
            }
        } else {
            for Item in Ctrl.__Filter {
                if Item = Str {
                    Ctrl.__Filter.RemoveAt(A_Index)
                    break
                }
            }
        }
    }
    _DisposeFilter() {
        for Prop in ['__Arr','__Transitory', '__Filter', '__MaxVisible', 'AddEx', 'DeleteEx'] {
            try {
                ComboBox.DeleteProp(Prop)
            }
        }
        ComboBox.OnEvent('Focus', HFocusComboBox, 0)
        ; ComboBox.OnEvent('LoseFocus', HLoseFocusComboBox, 0)
        ComboBox.OnEvent('Change', HChangeComboBox, 0)
    }
}
