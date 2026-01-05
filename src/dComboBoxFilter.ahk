
class dComboBoxFilter {
    static __New() {
        this.DeleteProp('__New')
        this.Collection := Map()
        proto := this.Prototype
        proto.Filter :=
        proto.HandlerChange :=
        proto.HwndComboBox :=
        proto.Id :=
        ''
    }
    /**
     * @description - Sets two event handlers on the `Gui.ComboBox`:
     * - {@link https://www.autohotkey.com/docs/v2/lib/GuiOnEvent.htm#Focus Focus} - When focused,
     *   sends `CB_SHOWDROPDOWN` to the control.
     * - {@link https://www.autohotkey.com/docs/v2/lib/GuiOnEvent.htm#Change Change} - When the
     *   contents of the combo box's edit control change, the items listed in the combo box's dropdown
     *   will be filtered.
     * @class
     *
     * @param {Gui.ComboBox} ComboBox - The ComboBox object to use with the filter.
     * @param {String[]} List - The array that contains the words displayed by the combobox.
     */
    __New(ComboBox, List) {
        loop 100 {
            id := Random(1, 4294967295)
            if !dComboBoxFilter.Collection.Has(id) {
                this.Id := id
                break
            }
        }
        if this.HasOwnProp('id') {
            ObjRelease(ObjPtr(this))
        } else {
            throw Error('Failed to produce a unique id.')
        }
        this.HwndComboBox := ComboBox.HwndComboBox
        this.Filter := Display_FilterWords(
            List
          , ((hwnd) => GuiCtrlFromHwnd(hwnd).Text).Bind(ComboBox.HwndComboBox)
          , __dComboBoxFilter_Add.Bind(this.Id, this.HwndComboBox)
          , __dComboBoxFilter_Delete.Bind(this.HwndComboBox)
          , Display_FilterWords_FilterCallback
        )
        this.HandlerChange := dComboBoxFilter.HandlerChange(this.Id)
        ComboBox.OnEvent('Change', this.HandlerChange, 1)
        ComboBox.OnEvent('Focus', __dComboBoxFilter_HandlerFocus, 1)
    }

    Add(Str) => this.Filter.Add(Str)
    Delete(Str) => this.Filter.Delete(Str)

    Dispose() {
        if this.HwndComboBox {
            this.ComboBox.OnEvent('Change', this.HandlerChange, 0)
            this.ComboBox.OnEvent('Focus', __dComboBoxFilter_HandlerFocus, 0)
            this.DeleteProp('HwndComboBox')
        }
        if this.Filter {
            this.Filter.Dispose()
            this.DeleteProp('Filter')
        }
    }

    __Delete() {
        this.Dispose()
        ObjPtrAddRef(this)
        if dComboBoxFilter.Collection.Has(this.Id) {
            dComboBoxFilter.Collection.Delete(this.Id)
        }
    }

    ComboBox => this.HwndComboBox ? GuiCtrlFromHwnd(this.HwndComboBox) : ''

    class HandlerChange {
        __New(id) {
            this.Id := id
        }
        Call(ctrl, *) {
            if dComboBoxFilter.Collection.Has(this.Id) {
                Ctrl.OnEvent('Change', this, 0)
                dComboBoxFilter.Collection.Get(this.Id).Filter.Call()
                Ctrl.OnEvent('Change', this, 1)
            }
        }
    }
}


__dComboBoxFilter_Add(id, hwnd, Index, *) {
    if dComboBoxFilter.Collection.Has(id) {
        SendMessage(0x0143, 0, StrPtr(dComboBoxFilter.Collection.Get(id).Filter.List[Index]), hwnd) ; CB_ADDSTRING
    }
}
__dComboBoxFilter_Delete(hwnd, index, FilteredIndex) {
    SendMessage(0x0144, FilteredIndex - 1, 0, hwnd) ; CB_DELETESTRING
}
__dComboBoxFilter_HandlerFocus(ctrl, *) {
    SendMessage(0x014F, 1, 0, ctrl.HwndComboBox) ; CB_SHOWDROPDOWN
}

/**
 * @classdesc - Filters strings in an array of strings as a function of an input string, such that
 * the filtered array contains only strings for which `FilterCallback(Item, Input)` is true. To
 * allow for flexibility in its usage, {@link Display_FilterWords} requires some setup. See the test file
 * "test-files\test-FilterWords.ahk" for an example setting up the function.
 */
class Display_FilterWords {

    /**
     * Creates an instance of {@link Display_FilterWords}, which should be used as part of an event handler. The
     * event handler should include something to the effect of the following example. In this example,
     * assume that `Ctrl.Gui.Filter` references an instance of {@link Display_FilterWords}, and `Ctrl` references
     * a `Gui.Control` object to which the event handler is associated. Basically, the event handler
     * must disable itself, call the {@link Display_FilterWords} object, then re-enable itself.
     * @example
     * HChangeEdit(Ctrl, *) {
     *     ; Disable the event handler.
     *     Ctrl.OnEvent('Change', HChangeEdit, 0)
     *     ; Call the filter object.
     *     Ctrl.Gui.Filter.Call()
     *     ; Enable the event handler.
     *     Ctrl.OnEvent('Change', HChangeEdit, 1)
     * }
     * @
     *
     * While the {@link Display_FilterWords} object is active and associated with an array, if your code needs to
     * add or remove items from the array, you must call {@link Display_FilterWords.Prototype.Add} or
     * {@link Display_FilterWords.Prototype.Delete}. These are not the same as the `AddCallback` and `DeleteCallback`
     * parameters.
     *
     * Items that have been filtered out of the `List` array (first parameter) are available from
     * the property {@link Display_FilterWordsObj.Filtered}, also an array.
     *
     * The callback functions are assigned to properties "CbGetText", "CbAdd", "CbDelete", "CbFilter",
     * so your code can set any of those properties with a new function object instead of creating a
     * new instance of {@link Display_FilterWords}, if needed.
     *
     * Similarly, the `List` array is set to the "List" property, so if it is more efficient in
     * the context of your code, you could swap out that property with a new array as well. You'll
     * need to handle any items from the "Filtered" array.
     * @example
     * List := Display_FilterWordsObj.List
     * Display_FilterWordsObj.List := NewList
     * if Display_FilterWordsObj.Filtered.Length {
     *     List.Push(Display_FilterWordsObj.Filtered*)
     *     Display_FilterWordsObj.Filtered := []
     * }
     * Display_FilterWordsObj.Capacity := NewList.Length
     * @
     * @class
     * @param {Array} List - The array of strings that will be associated with the filter.
     * @param {*} GetTextCallback - A `Func` or callable object that returns the text that is used
     * as input for filtering the items in `List`.
     * @param {*} AddCallback - A `Func` or callable object that is called when adding items that
     * were previously filtered out back into `List`. The function should accept one parameter,
     * the string being added back to `List`. The function should **not** add the string to `List`;
     * {@link Display_FilterWords} does this.
     * @param {*} DeleteCallback - A `Func` or callable object that is called when removing items
     * from `List`. The function should accept one parameter, the integer index of the item's position
     * in `List`. The function should **not** remove the string from `List`; {@link Display_FilterWords} does this
     * after calling `DeleteCallback`, so your code will still be able to identify the string using
     * `List[index]` if needed.
     * @param {*} [FilterCallback = InStr] - The comparison function. The parameters passed to the
     * function are:
     * - 1. The array item being evaluated.
     * - 2. the input string returned from `GetTextCallback`.
     *
     * The default is `InStr`. The function should return nonzero if the item is to be kept in the
     * active list, which is the `List` array. The function should return zero or an empty string
     * if the item is to be filtered out of the array. See "test-files\test-FilterWords.ahk" for
     * a more robust comparison function.
     */
    __New(List, GetTextCallback, AddCallback, DeleteCallback, FilterCallback := InStr) {
        this.CbGetText := GetTextCallback
        this.CbAdd := AddCallback
        this.CbDelete := DeleteCallback
        this.CbFilter := FilterCallback
        this.Transition := []
        this.Filtered := []
        this.List := List
        Indices := this.Indices := []
        Indices.Length := List.Length
        loop List.Length {
            Indices[A_Index] := A_Index
        }
        this.Transition.Capacity := this.Filtered.Capacity := List.Capacity
        this.PreviousText := ''
    }
    Call() {
        CbGetText := this.CbGetText
        CbAdd := this.CbAdd
        CbDelete := this.CbDelete
        CbFilter := this.CbFilter
        this.Time := A_TickCount
        Indices := this.Indices
        List := this.List
        Filtered := this.Filtered
        loop {
            if Text := CbGetText() {
                ; If the user added a character, then we only need to filter our current
                ; this.filtered this.list, not the entire this.list.
                if !this.PreviousText || (StrLen(Text) > StrLen(this.PreviousText) && InStr(Text, this.PreviousText) == 1) {
                    i := 0
                    loop Indices.Length {
                        if !CbFilter(List[Indices[++i]], Text) {
                            Index := Indices.RemoveAt(i)
                            CbDelete(Index, i--)
                            Filtered.Push(Index)
                        }
                    }
                } else if Text {
                    currentLen := Indices.Length
                    i := 0
                    loop Filtered.Length {
                        if CbFilter(List[Filtered[++i]], Text) {
                            Index := Filtered.RemoveAt(i)
                            CbAdd(Index, i--)
                            Indices.Push(Index)
                        }
                    }
                    i := 0
                    loop currentLen {
                        if !CbFilter(List[Indices[++i]], Text) {
                            Index := Indices.RemoveAt(i)
                            CbDelete(Index, i--)
                            Filtered.Push(Index)
                        }
                    }
                } else {
                    Reset()
                }
            } else {
                Reset()
            }
            this.PreviousText := Text
            if this.PreviousText == CbGetText() {
                if A_TickCount - this.Time > 500 {
                    break
                }
                sleep 50
            } else {
                this.Time := A_TickCount
            }
        }
        this.Time := 0

        return

        Reset() {
            loop Filtered.Length {
                Index := Filtered.Pop()
                CbAdd(Index, Filtered.Length + 1)
                Indices.Push(Index)
            }
        }
    }

    Add(Str) {
        this.List.Push(Str)
        if (text := this.CbGetText.Call()) {
            if this.CbFilter.Call(Str, text) {
                this.Indices.Push(this.List.Length)
                this.CbAdd.Call(this.List.Length)
            } else {
                this.Filtered.Push(this.List.Length)
            }
        } else {
            this.Indices.Push(this.List.Length)
            this.CbAdd.Call(this.List.Length)
        }
    }
    Delete(Index?, Str?) {
        if !IsSet(Index) {
            if IsSet(Str) {
                for s in this.List {
                    if s = Str {
                        Index := A_Index
                        break
                    }
                }
                if !IsSet(Index) {
                    throw Error('String not found.', , Str)
                }
            } else {
                throw Error('No parameters were defined.')
            }
        }
        if (text := this.CbGetText.Call()) {
            if this.CbFilter.Call(this.List[Index], text) {
                _LoopItems()
            } else {
                n := this.List.Length
                this.List.RemoveAt(Index)
                for i in this.Filtered {
                    if i = n {
                        this.Filtered.RemoveAt(A_Index)
                        return
                    }
                }
                for i in this.Indices {
                    if i = n {
                        this.Indices.RemoveAt(A_Index)
                        return
                    }
                }
            }
        } else {
            _LoopItems()
        }

        _LoopItems() {
            for i in this.Indices {
                if Index = i {
                    this.Indices.RemoveAt(A_Index)
                    this.CbDelete.Call(Index, A_Index)
                    this.List.RemoveAt(Index)
                    return
                }
            }
        }
    }
    Dispose() {
        list := []
        for prop in this.OwnProps() {
            list.Push(prop)
        }
        for prop in list {
            this.DeleteProp(prop)
        }
    }
}

Display_FilterWords_FilterCallback(Item, Input) {
    LeftOffsetInput := LeftOffsetItem := 1
    RightOffsetInput := 0
    _Input := RegExReplace(Input, '\s', '')
    _Item := RegExReplace(Item, '\s', '')
    LenInput := SubLen := StrLen(_Input)
    LenItem := StrLen(_Item)
    found := []
    found.Capacity := LenInput

    loop {
        ssInput := SubStr(_Input, LeftOffsetInput, LenInput - LeftOffsetInput - RightOffsetInput + 1)
        if pos := InStr(_Item, ssInput, , LeftOffsetItem) {
            LenSsInput := StrLen(ssInput)
            LeftOffsetItem := pos + LenSsInput
            LeftOffsetInput += LenSsInput
            found.Push(LeftOffsetInput, LenInput - LeftOffsetInput - RightOffsetInput + 1, pos)
            if LeftOffsetInput > LenInput {
                return found
            } else {
                RightOffsetInput := 0
            }
        } else {
            RightOffsetInput++
            if RightOffsetInput + LeftOffsetInput > LenInput {
                return 0
            }
        }
    }
    return 0
}
