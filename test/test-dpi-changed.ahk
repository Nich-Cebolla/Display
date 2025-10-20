
#include <DisplayConfig>

test_dpichanged()

class test_dpichanged {
    static Call() {
        ; SetThreadDpiAwarenessContext(-3)
        DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
        G := this.G := dGui('-DPIScale +Resize')
        DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
        ; SetThreadDpiAwarenessContext(-4)
        G.SetFont('s11', 'Roboto Mono')
        s := '
        (
HandleDpiChange(NewDPI, RECT, msg, hwnd) {
    MyGui := GuiFromHwnd(hwnd) ; Get the Gui
    if !MyGui
        return
    DPIRatio := NewDPI / MyGui.LastDPI ; Calculate the ratio of the new DPI to the old DPI
    MyGui.Move(RECT['left'], RECT['top'], RECT['width'], RECT['height']) ; Resize the Gui according to the new DPI
    if MyGui.HasOwnProp('FontSize')
        MyGui.SetFont('s' (MyGui.FontSize * NewDPI / MyGui.FontSizeDPI)) ; Adjust the gui's font size first
    for ctrl in MyGui {
        if ctrl.HasOwnProp('FontSize') ; Adjust control's font size if appropriate
            ctrl.SetFont('s' (ctrl.FontSize * NewDPI / ctrl.FontSizeDPI))
        ctrl.GetPos(&x, &y, &w, &h) ; Get the control's position and size
        ; Here, we account for rounding so our controls don't shift a little bit over time
        ctrl.Move(
            Round(newX:=((x + (ctrl.RoundedPos.x >= 0.5 ? ctrl.RoundedPos.x*-1 : ctrl.RoundedPos.x)) * DPIRatio))
          , Round(newY:=((y + (ctrl.RoundedPos.y >= 0.5 ? ctrl.RoundedPos.y*-1 : ctrl.RoundedPos.y)) * DPIRatio))
          , Round(newW:=((w + (ctrl.RoundedPos.w >= 0.5 ? ctrl.RoundedPos.w*-1 : ctrl.RoundedPos.w)) * DPIRatio))
          , Round(newH:=((h + (ctrl.RoundedPos.h >= 0.5 ? ctrl.RoundedPos.h*-1 : ctrl.RoundedPos.h)) * DPIRatio))
        `)
        ctrl.RoundedPos := {x: newX-Floor(newX), y: newY-Floor(newY), w: newW-Floor(newW), h: newH-Floor(newH)}
        if ctrl is Gui.ListView {
            ; if ctrl.HasOwnProp('UsesIcons')
                ; ctrl.SetImageList(IL) ; Re-set the image list with correct icon sizes
        }
    }
    MyGui.LastDPI := NewDPI
}
)'
        StrReplace(s, '`n', , , &Count)
        edt := G.Add('Edit', 'w600 r' Count ' -Wrap +Hscroll vedt', RegExReplace(s, '\R', '`r`n'))
        btn := G.Add('Button', 'Section vBtnOn', 'On')
        btn.OnEvent('Click', HClickButtonOn)
        btn := G.Add('Button', 'ys vBtnOff', 'Off')
        btn.OnEvent('Click', HClickButtonOff)
        G.Show()
        HClickButtonOn()

        HClickButtonOn(*) {
            dGui.SetDpiChangedHandler(1)
        }
        HClickButtonOff(*) {
            dGui.SetDpiChangedHandler(0)
        }

    }
}
