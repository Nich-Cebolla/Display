
#Include ..\lib\Display_ComboBox.ahk

#Include ..\..\SimpleArrayInspector\SimpleArrayInspector.ahk
#SingleInstance force

Test() {
    static Functions := ['GuiCb_ShowDropdown', 'GuiCb_SetMinVisible', 'GuiCb_SetFilterOnChange', 'AddEx', 'DeleteEx']
    EditWidth := 60
    G := Gui('+Resize -DPIScale ')
    G.SetFont('s11 q5', 'Roboto Mono')
    G.Add('Edit', 'w400 r20 vmain')
    Arr := []
    loop 20 {
        Str := ''
        loop 10 {
            Str .= Chr(Random(65, 90))
        }
        Arr.Push(Str)
    }
    cb := G.Add('ComboBox', 'w200 r20 vcb', Arr)
    GuiCb_SetFilterOnChange(cb, Arr)

    GreatestWidth := 0
    Btns := []
    Edits := []
    for Name in Functions {
        Btns.Push(G.Add('Button', 'x10 y10 vbtn_' Name, Name))
        Btns[-1].OnEvent('Click', HClickButtonTest)
        if cb.HasMethod(Name) {
            Function := cb.GetOwnPropDesc(Name).Call
            ct := Function.MaxParams - 1
            Btns[-1].Function := Function.Bind(cb)
        } else {
            Function := %Name%
            ct := Function.MaxParams
            Btns[-1].Function := Function
        }
        Btns[-1].Edits := []
        loop ct {
            Btns[-1].Edits.Push(G.Add('Edit', 'x10 y10 vedit_' Name '_' A_Index, ''))
        }
        Btns[-1].GetPos(, , &cw, &ch)
        if cW > GreatestWidth {
            GreatestWidth := cW
        }
    }
    X := G.MarginX
    Y := G.MarginY
    GreatestX := 0
    for Btn in Btns {
        Btn.Move(X, Y, GreatestWidth)
        X += GreatestWidth + G.MarginX
        for edt in Btn.Edits {
            edt.Move(X, Y, EditWidth)
            X += EditWidth + G.MarginX
        }
        Y += cH + G.MarginY
        if X > GreatestX {
            GreatestX := X
        }
        X := G.MarginX
    }
    G['main'].Move(GreatestX + G.MarginX, G.MarginY)
    G['cb'].Move(G.MarginX, Y + G.MarginY)
    G['cb'].GetPos(&cx, &cy, &cw)
    ArrayInspector := SimpleArrayInspector(Arr)
    G.Add('Button', 'x' (cx + cw + G.MarginX) ' y' cy ' vbtn_ArrayInspector', 'View / modify array').OnEvent('Click', ArrayInspector)
    G.Show('NoActivate')

    return G

    HClickButtonTest(Ctrl, *) {
        Params := []
        Params.Length := Ctrl.Edits.Length
        P := ''
        for edt in Ctrl.Edits {
            if !edt.Text {
                continue
            }
            Params[A_Index] := edt.Text
            P .= A_Index ': ' edt.Text '`r`n'
        }
        Function := Ctrl.Function
        Str := (
            'Function: ' Function.Name
            '`r`n' P
            'Start time: ' (StartTime := A_TickCount)
        )
        try {
            Result := Function(Params*)
            StopTime := A_TickCount
        } catch Error as err {
            StopTime := A_TickCount
            Result := (
                err.Message
                '`r`n' err.What
                '`r`n' err.Stack
                '`r`n' err.Line
                '`r`n' err.File
                err.Extra ? '`r`n' err.Extra : ''
            )
        }
        Str .= (
            '`r`nEnd time: ' StopTime
            '`r`nDuration: ' Round((StopTime - StartTime) / 1000, 4) ' seconds'
            '`r`nResult:'
            '`r`n' Result
            '----------------------`r`n'
        )
        G['main'].Text := Str '`r`n`r`n' G['main'].Text
    }
}


G := test()
