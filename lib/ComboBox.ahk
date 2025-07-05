
; Dependency
#include ..\definitions\define-ComboBox.ahk
#include FilterWords.ahk

/**
 * @description - Sets two event handlers:
 * - "Focus" - When focused, sends `CB_SHOWDROPDOWN` to the control.
 * - "Change" - When the contents of the combo box's edit control change, the items listed in the
 * combo box's dropdown will be filtered according to `FilterWords.FilterCallback`.
 * @param {Gui.ComboBox} ComboBox - The ComboBox object to use with the filter.
 * @param {Array} List - The array that contains the words displayed by the combobox.
 */
class CbFilter {
    __New(ComboBox, List) {
        this.Hwnd := ComboBox.Hwnd
        this.Filter := FilterWords(
            List
          , ((ComboBox) => ComboBox.Text).Bind(ComboBox)
          , _Add
          , _Delete
          , ObjBindMethod(FilterWords, 'FilterCallback')
        )
        ComboBox.OnEvent('Focus', ObjBindMethod(this, 'HFocusComboBox'), 1)
        ; ComboBox.OnEvent('LoseFocus', HLoseFocusComboBox, AddRemove)
        ComboBox.OnEvent('Change', ObjBindMethod(this, 'HChangeComboBox'), 1)

        ; HLoseFocusComboBox(Ctrl, *) {
        ;     if SendMessage(CB_GETDROPPEDSTATE, 0, 0, Ctrl.hWnd) {
        ;         SendMessage(CB_SHOWDROPDOWN, 0, 0, Ctrl.hWnd)
        ;     }
        ; }

        _Add(Index, *) {
            SendMessage(CB_ADDSTRING, 0, StrPtr(this.Filter.List[Index]), this.Hwnd)
        }
        _Delete(Index, FilteredIndex) {
            SendMessage(CB_DELETESTRING, FilteredIndex - 1, 0, this.Hwnd)
        }
    }

    Add(Str) => this.Filter.Add(Str)
    Delete(Str) => this.Filter.Delete(Str)

    Dispose() {
        this.ComboBox.OnEvent('Focus', ObjBindMethod(this, 'HFocusComboBox'), 0)
        ; ComboBox.OnEvent('LoseFocus', HLoseFocusComboBox, 0)
        this.ComboBox.OnEvent('Change', ObjBindMethod(this, 'HChangeComboBox'), 0)
        this.Filter.Dispose()
        this.DeleteProp('Filter')
    }

    HChangeComboBox(Ctrl, Item) {
        Ctrl.OnEvent('Change', ObjBindMethod(this, 'HChangeComboBox'), 0)
        this.Filter.Call()
        Ctrl.OnEvent('Change', ObjBindMethod(this, 'HChangeComboBox'), 1)
    }

    HFocusComboBox(Ctrl, *) {
        SendMessage(CB_SHOWDROPDOWN, 1, 0, Ctrl.hWnd)
    }

    ComboBox => GuiCtrlFromHwnd(this.Hwnd)
}
