#include ..\templates\DisplayConfig.ahk

; This tests using `FilterStrings` with a list-view control
test()

class test {
    static Call() {
        words := ['numerically','swathe','viverrine','debility','numb','sameness','parablast','disbud'
        ,'insoluble','indubitable','proposer','niccolite','immesh','seaboard','epicycle','petrify','boss'
        ,'mignonette','deference','beauxite','dimera','pintado','suzerain','synalepha','silken']

        g := this.g := gui('+Resize', , this)
        lv := this.lv := g.Add('ListView', 'w300 r11 -Hdr', [''])

        ; Add the words to the listview
        for w in words {
            lv.Add(, w)
        }

        ; We'll use an edit control to input the filter criterion
        edt := this.edt := g.Add('Edit', 'w300 Section')
        ; Set the "Change" event handler
        edt.OnEvent('Change', 'OnEditChanged')

        ; Let's also add a couple buttons and another edit control to demonstrate adding and deleting items.
        g.Add('Button', 'w93 xs ys+40 Section', 'Add').OnEvent('Click', 'OnClickButtonAdd')
        g.Add('Button', 'w93 ys', 'Delete').OnEvent('Click', 'OnClickButtonDelete')
        g.Add('Button', 'w93 ys', 'Clear').OnEvent('Click', 'OnClickButtonClear')
        this.edt2 := g.Add('Edit', 'w150 xs Section')
        this.edt3 := g.Add('Edit', 'w150 ys')
        Buffer.Prototype.DefineProp('__Enum', { Call: test_FilterStrings_Buffer_Enum })

        ; Create the FilterStrings object
        this.filter := FilterStrings({
            list: words,
            ; We include the list-view's handle because we need to be able to obtain a reference
            ; to the list-view control from within the scope of our callback functions. This
            ; is an easy way to do that.
            HwndCtrl: lv.hwnd,
            ; This built-in function `FilterStrings_GetControlTextFunc` returns a function that
            ; returns the edit control's text.
            callbackGetCriterion: FilterStrings_GetControlTextFunc(edt),
            ; This built-in function `FilterStrings_CallbackAddListView` adds items back to
            ; their correct position in the list-view control.
            callbackAdd: FilterStrings_CallbackAddListView,
            ; This built-in function `FilterStrings_CallbackDelete` handles deleting items that
            ; are filtered out.
            callbackDelete: FilterStrings_CallbackDelete,
            ; This last function is not built-in; most applications will need to define it's own
            ; function that is called at the end. Generally, the function needs to re-enable the
            ; event handler.
            callbackEnd: (*) => test.edt.OnEvent('Change', 'OnEditChanged', 1)
        })

        g.show()
        g.OnEvent('Close', (*) => ExitApp())
    }
    static OnClickButtonAdd(btn, *) {
        if this.edt2.Text {
            if this.HasOwnProp('TxtMessage') {
                this.TxtMessage.Text := ''
            }
            index := this.edt3.text
            this.Filter.Add(this.edt2.Text, StrLen(index) ? index : unset)
        } else {
            Helper(btn.Gui, 'Enter a word to add.')
        }
    }
    static OnClickButtonDelete(btn, *) {
        if txt := this.edt2.Text {
            if this.HasOwnProp('TxtMessage') {
                this.TxtMessage.Text := ''
            }
            length := this.edt3.text
            for s in this.Filter.list {
                if s = txt {
                    this.Filter.Delete(A_Index, StrLen(length) ? length : unset)
                    return
                }
            }
            Helper(btn.Gui, 'Word not found.')
        } else {
            Helper(btn.Gui, 'Enter a word to delete.')
        }
    }
    static OnEditChanged(edt, *) {
        ; Our event handler must disable itself and call the filter
        edt.OnEvent('Change', 'OnEditChanged', 0)
        SetTimer(this.filter, -10)
    }
}

Helper(g, msg) {
    if test.HasOwnProp('TxtMessage') {
        test.TxtMessage.Text := msg
    } else {
        test.TxtMessage := g.Add('Text', 'xs w300', msg)
        test.TxtMessage.GetPos(, &txty, , &txth)
        g.Show('h' (txty + txth + g.MarginY))
    }
}
test_FilterStrings_Buffer_Enum(buf, varCount := 1) {
    i := 0
    return _Enum%varCount%

    _Enum1(&val) {
        if ++i > buf.Size {
            return 0
        }
        val := NumGet(buf, i - 1, 'char')
        return 1
    }
    _Enum2(&index, &val) {
        if ++i > buf.Size {
            return 0
        }
        index := i
        val := NumGet(buf, i - 1, 'char')
        return 1
    }
}
