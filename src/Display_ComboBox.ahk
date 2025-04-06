
class ComboBoxHelper {
    static ShowDropdown(ComboBox, Value := 1) {
        SendMessage(CB_SHOWDROPDOWN ?? 0x014F, Value, 0, ComboBox.hWnd)
    }
    static SetMinVisible(ComboBox, MinVisible) {
        SendMessage(CB_SETMINVISIBLE ?? 0x1701, MinVisible, 0, ComboBox.hWnd)
    }

    /**
     * @description - Sets `Focus` to open the dropdown, `LoseFocus` to close the dropdown,
     * and `Change` to filter what is displayed in the dropdown as a function of the user's input
     * into the banner. This adds the array as a property `__Arr` to the ComboBox, but don't
     * interact with the array directly unless you have disabled this filter function by calling
     * `SetFilterOnChange` with `AddRemove := 0`. If you need to add / remove items, call
     * `ComboBoxObj.AddEx` or `ComboBoxObj.DeleteEx`. If you modify the array directly, the
     * ComboBox will not be updated properly.
     */
    static SetFilterOnChange(ComboBox, Arr, AddRemove := 1, MaxVisible := 20) {
        ComboBox.OnEvent('Focus', HFocusComboBox, AddRemove)
        ComboBox.OnEvent('LoseFocus', HLoseFocusComboBox, AddRemove)
        ComboBox.OnEvent('Change', HChangeComboBox, AddRemove)
        ComboBox.__Arr := Arr
        ComboBox.__Transitory := []
        ComboBox.__Filter := []
        ComboBox.__Transitory.Capacity := ComboBox.__Filter.Capacity := Arr.Length
        ComboBox.__MaxVisible := MaxVisible

        HChangeComboBox(Ctrl, Item) {
            static PreviousText := ''
            Time := A_TickCount
            Arr := Ctrl.__Arr
            Transitory := Ctrl.__Transitory
            Filter := Ctrl.__Filter
            Ctrl.OnEvent('Change', HChangeComboBox, 0)
            _Search()

            _Search() {
                loop {
                    if PreviousText == Ctrl.Text {
                        sleep 100
                        if A_TickCount - Time > 500 {
                            break
                        }
                        continue
                    }
                    if Ctrl.Text {
                        ; If the user added a character, then we only need to filter our current
                        ; filtered list, not the entire list.
                        if Ctrl.Text && (!PreviousText || (StrLen(Ctrl.Text) > StrLen(PreviousText) && InStr(Ctrl.Text, PreviousText) == 1)) {
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
                            SendMessage(CB_SETMINVISIBLE ?? 0x1701, Min(Ctrl.__Arr.Length, Ctrl.__MaxVisible), 0, ComboBox.hWnd)
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
                        SendMessage(CB_SETMINVISIBLE ?? 0x1701, Min(Ctrl.__Arr.Length, Ctrl.__MaxVisible), 0, ComboBox.hWnd)
                    } else {
                        _ResetFilter(Ctrl)
                    }
                    PreviousText := Ctrl.Text
                    Time := A_TickCount
                }
                Ctrl.OnEvent('Change', HChangeComboBox, 1)
                Time := 0
            }
        }
        HFocusComboBox(Ctrl, *) {
            SendMessage(CB_SHOWDROPDOWN ?? 0x014F, 1, 0, Ctrl.hWnd)
        }
        HLoseFocusComboBox(Ctrl, *) {
            SendMessage(CB_SHOWDROPDOWN ?? 0x014F, 0, 0, Ctrl.hWnd)
        }
        _ResetFilter(Ctrl) {
            Ctrl.Add(Ctrl.__Filter)
            Ctrl.__Arr.Push(Ctrl.__Filter*)
            Ctrl.__Filter := []
            Ctrl.__Filter.Capacity := Ctrl.__Arr.Length
        }
    }
}
