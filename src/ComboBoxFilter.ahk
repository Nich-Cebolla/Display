
#include FilterStrings.ahk

class ComboBoxFilter {
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
     * @description - Sets two event handlers:
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
            if !ComboBoxFilter.Collection.Has(id) {
                this.Id := id
                break
            }
        }
        if this.HasOwnProp('id') {
            ObjRelease(ObjPtr(this))
        } else {
            throw Error('Failed to produce a unique id.')
        }
        this.HwndComboBox := ComboBox.Hwnd
        this.Filter := FilterStrings({
            List: List,
            CallbackGetCriterion: __ComboBoxFilter_GetText.Bind(ComboBox.Hwnd),
            CallbackAdd:  __ComboBoxFilter_Add.Bind(this.Id, this.HwndComboBox),
            CallbackDelete: __ComboBoxFilter_Delete.Bind(this.HwndComboBox),
            CallbackFilter: FilterStrings_CallbackFilter
        })
        this.HandlerChange := ComboBoxFilter.HandlerChange(this.Id)
        ComboBox.OnEvent('Change', this.HandlerChange, 1)
        ComboBox.OnEvent('Focus', __ComboBoxFilter_HandlerFocus, 1)
    }

    Add(Str) => this.Filter.Add(Str)
    Delete(Str) => this.Filter.Delete(Str)

    Dispose() {
        if this.HwndComboBox {
            this.ComboBox.OnEvent('Change', this.HandlerChange, 0)
            this.ComboBox.OnEvent('Focus', __ComboBoxFilter_HandlerFocus, 0)
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
        if ComboBoxFilter.Collection.Has(this.Id) {
            ComboBoxFilter.Collection.Delete(this.Id)
        }
    }

    ComboBox => this.HwndComboBox ? GuiCtrlFromHwnd(this.HwndComboBox) : ''

    class HandlerChange {
        __New(id) {
            this.Id := id
        }
        Call(ctrl, *) {
            if ComboBoxFilter.Collection.Has(this.Id) {
                Ctrl.OnEvent('Change', this, 0)
                ComboBoxFilter.Collection.Get(this.Id).Filter.Call()
                Ctrl.OnEvent('Change', this, 1)
            }
        }
    }
}

__ComboBoxFilter_Add(id, hwnd, Index, *) {
    if ComboBoxFilter.Collection.Has(id) {
        SendMessage(0x0143, 0, StrPtr(ComboBoxFilter.Collection.Get(id).Filter.List[Index]), hwnd) ; CB_ADDSTRING
    }
}
__ComboBoxFilter_Delete(hwnd, index, FilteredIndex) {
    SendMessage(0x0144, FilteredIndex - 1, 0, hwnd) ; CB_DELETESTRING
}
__ComboBoxFilter_GetText(hwnd) => GuiCtrlFromHwnd(hwnd).Text
__ComboBoxFilter_HandlerFocus(ctrl, *) {
    SendMessage(0x014F, 1, 0, ctrl.Hwnd) ; CB_SHOWDROPDOWN
}
