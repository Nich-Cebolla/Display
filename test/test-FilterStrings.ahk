
#include ..\src
#include FilterStrings.ahk

if !A_IsCompiled && A_LineFile == A_ScriptFullPath {
    test_FilterStrings()
}

class test_FilterStrings {
    static Call() {
        words := ['numerically','swathe','viverrine','debility','numb','sameness','parablast','disbud'
        ,'insoluble','indubitable','proposer','niccolite','immesh','seaboard','epicycle','petrify','boss'
        ,'mignonette','deference','beauxite','dimera','pintado','suzerain','synalepha','silken']
        g := this.g := Gui(, , this)
        g.SetFont('s11 q5', 'Segoe Ui')
        initialY := y := g.MarginY
        deltaY := y / 2
        x := g.MarginX
        w := i := 0
        loop words.Length {
            if ++i > 7 {
                i := 1
                x += w + g.MarginX
                bottomY := y
                y := initialY
                w := 0
            }
            txt := g.Add('Text', 'x' x ' y' y, A_Index ': ' words[A_Index])
            txt.GetPos(, , &_w, &h)
            w := Max(w, _w)
            y += deltaY + h
        }
        g.Add('Text', 'x' g.MarginX ' y' (bottomY + h + g.MarginY) ' Section', 'Str:')
        this.input1 := g.Add('Edit', 'ys w200')
        g.Add('Text', 'ys', 'Index:')
        this.input2 := g.Add('Edit', 'ys w50')
        g.Add('Button', 'ys', 'Add').OnEvent('Click', 'HClickAdd')
        g.Add('Text', 'xs Section', 'Index:')
        this.input3 := g.Add('Edit', 'ys w50')
        g.Add('Text', 'ys', 'Length:')
        this.input4 := g.Add('Edit', 'ys w50')
        g.Add('Button', 'ys', 'Delete').OnEvent('Click', 'HClickDelete')
        ; g.Add('Checkbox', 'xs', 'Use FilterStrings_CallbackFilterEx').OnEvent('Click', 'HClickCheckbox')
        this.cb := g.Add('ComboBox', 'xs w400 r25', words)
        this.cb.OnEvent('Change', 'HChangeComboBox')
        this.cb.OnEvent('Focus', 'HFocusComboBox')
        this.cb.OnEvent('LoseFocus', 'HLoseFocusComboBox')
        options := {
            List: words,
            CallbackAdd: FilterStrings_CallbackAddComboBox,
            CallbackDelete: FilterStrings_CallbackDelete,
            CallbackGetCriterion: FilterStrings_GetControlTextFunc(this.cb),
            CallbackEnd: test_FilterStrings_OnEnd,
            HwndCtrl: this.cb.Hwnd,
            HwndCtrlEventHandler: this.cb.Hwnd
        }
        this.filterStrings := FilterStrings(options)
        Buffer.Prototype.DefineProp('__Enum', { Call: test_FilterStrings_Buffer_Enum })
        g.Show('Hide')
        g.GetPos(, &y)
        g.Move(, y - 300)
        g.Show()
    }

    static HClickAdd(btn, *) {
        if InStr(this.input1.Text, ',') {
            this.filterStrings.AddMultiple(StrSplit(this.input1.Text, ','), this.input2.Text || unset)
        } else {
            this.filterStrings.Add(this.input1.Text, this.input2.Text || unset)
        }
    }
    /*
    static HClickCheckbox(chk, *) {
        if chk.Value {
            this.filterStrings.CallbackFilter := test_FilterStrings_CallbackFilterEx
        } else {
            this.filterStrings.CallbackFilter := FilterStrings_CallbackFilter
        }
    }
    */
    static HClickDelete(btn, *) {
        this.filterStrings.Delete(this.input3.Text, this.input4.Text || unset)
    }
    static HChangeComboBox(cb, *) {
        cb.OnEvent('Change', 'HChangeComboBox', 0)
        this.filterStrings.Call()
    }
    static HFocusComboBox(cb, *) {
        SendMessage(0x014F, 1, 0, cb.Hwnd) ; CB_SHOWDROPDOWN
    }
    static HLoseFocusComboBox(cb, *) {
        cb.Text := ''
        this.filterStrings.Reset()
    }
}

test_FilterStrings_OnEnd(filterStringsObj) {
    test_FilterStrings.cb.OnEvent('Change', 'HChangeComboBox', 1)
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
/*
test_FilterStrings_CallbackFilterEx(item, criterion) {
    result := FilterStrings_CallbackFilterEx(item, criterion, , , 0.5)
    OutputDebug(
        'Item: ' item '`n'
        'Criterion: ' criterion '`n'
        'Result: ' result '`n'
    )
    return result
}
