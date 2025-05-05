
#SingleInstance force
#include ..\config\DefaultConfig.ahk
#include ..\lib
#include Dpi.ahk
#include Text.ahk
#include ..\src\dGui.ahk

dGui.Initialize()
Example()

class Example {
    static Call() {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -3, 'ptr')
        G := this.G := dGui(, , , { OptFont: 's11 q5', FontFamily: 'Aptos' })
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        ; text from https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm
        InsertHyphenationPoints(&(Str := this.GetText1()))
        Txt1 := G.Add('Text', 'w300')
        WrapText(Txt1, &Str, { AdjustObject: true, MeasureLines: true }, &Width, &Height)
        G.Show()
        dGui.GuiFitCtrl(Txt1, &_w, &_h)
        dGui.SetDpiChangeHandler()
        Txt1.GetPos(&cx, &cy, &cw, &ch)
        G.GetClientPos(&gx, &gy, &gw, &gh)
        g.add('button', 'x' (cx+cw) ' y10', 'button')
        sz := ControlGetTextExtent(Txt1)
        sleep 1
    }

    static GetText1() {
        return (
            'On Windows 8.1 and later, secondary screens can have different DPI settings,'
            ' and "per-monitor DPI-aware" applications are expected to scale their windows'
            ' according to the DPI of whichever screen they are currently on, adapting dynamically'
            ' when the window moves between screens.'
        )
    }
}
