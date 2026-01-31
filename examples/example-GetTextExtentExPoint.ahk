
#include ..\struct\Display_Size.ahk
#include ..\lib\Text.ahk
G := Gui()
G.SetFont('s11 q5', 'Roboto')
Txt := G.Add('Text', , 'Hello, world!')

; Some time later we update the control with input from the user.
; The layout of our UI restricts us to 80 pixels width, but we can
; increase its height if needed.
MyStr := ''
loop 10 {
   if MyStr := GetUserInput() {
       break
   }
}
if !MyStr {
    MsgBox('No input received, exiting process.')
    ExitApp()
}

MaxWidth := 80
; Get device context right before its needed
hdc := DllCall('GetDC', 'ptr', Txt.hWnd, 'ptr')
if !hdc {
    if HandleError(A_ThisFunc, A_LineFile, A_LineNumber) {
       Exit()
    }
    return
}
if !(sz := GetTextExtentExPoint(MyStr, hdc, MaxWidth, &fit, &extentPoints)) {
    if HandleError(A_ThisFunc, A_LineFile, A_LineNumber) {
        Exit()
    }
    return
}
; Release device context immediately when its no longer needed
if !DllCall('ReleaseDC', 'ptr', Txt.hWnd, 'ptr', hdc, 'int') {
    err := OSError()
    ; handle error
}
Len := StrLen(MyStr)
; If the width of the user's input is less than 80 pixels, update control
if fit >= Len {
    Txt.Text := MyStr
; If greater than 80 pixels, we need to wrap the text or take some other action.
; I've provided a wrap text function anyway, so the below code is just to show
; how to use the `OutExtentPoints`.
} else {
    Txt.Visible := 0
    s := ''
    ; To access the extent points, use `Obj[n]` syntax.
    loop 10 {
        s .= '`r`n' SubStr(MyStr, 1, A_Index) ' is ' extentPoints[A_Index] ' pixels wide.'
    }
    G.Add('Text', 'x10 y10', Trim(s, '`r`n'))
    G.Add('Button', , 'Exit').OnEvent('Click', (*)=>ExitApp())
    G.Show()
}

return

HandleError(fn, f, line) {
    msgbox(fn ' ' f ' ' line)
}
GetUserInput() => 'Hello, World!'
