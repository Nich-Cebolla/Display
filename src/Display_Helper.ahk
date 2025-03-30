
/* Credits
Key details regarding DLL calls sourced from, or pulled directly from, these discussions:
https://www.autohotkey.com/boards/viewTopic.php?f=6&t=4606
@just me  -  @iPhilip  -  @guest3456
https://www.autohotkey.com/boards/viewTopic.php?f=83&t=79220
@Tigerlily  -  @CloakerSmoker  -  @jNizM

For further reading on Dpi scaling, see @Descolada's tutorial here:
https://www.autohotkey.com/boards/viewTopic.php?f=96&t=121040
Also available is Descolada's Dpi.ahk; there's significant overlap between Descolada's code and my
code, but each have functions unique to the other. You can find Descolada's Dpi.ahk here:
https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/Dpi.ahk
*/


class RectBase extends Buffer {
    static __New() {
        if this.Prototype.__Class == 'RectBase' {
            this.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
            this.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
    }
    static __Call(Name, Params) {
        ; Overriden
    }

    GetPos(&X?, &Y?, &W?, &H?) {
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }
    SplitW(Divisor) => Rect.Split(this.L, this.W, Divisor)
    SplitH(Divisor) => Rect.Split(this.T, this.H, Divisor)

    TL => Point(this.L, this.T)
    BR => Point(this.R, this.B)
    L => NumGet(this, 0, 'Int')
    X => NumGet(this, 0, 'Int')
    T => NumGet(this, 4, 'Int')
    Y => NumGet(this, 4, 'Int')
    R => NumGet(this, 8, 'Int')
    B => NumGet(this, 12, 'Int')
    W => this.R - this.L
    H => this.B - this.T
    MidX => (this.R - this.L) / 2
    MidY => (this.B - this.T) / 2

    /**
     * @description - Constructs a `Rect` using the current object's coordinates converted
     * to client coordinates using the input Hwnd. The original object's values stay the same.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {VarRef} [OutTlPoint] - A variable that will receive the `Point` object for the top-left
     * corner of the new `Rect`.
     * @param {VarRef} [OutBrPoint] - A variable that will receive the `Point` object for the
     * bottom-right corner of the new `Rect`.
     * @returns {Rect} - The new object.
     */
    ToClient(Hwnd, &OutTlPoint?, &OutBrPoint?) {
        OutTlPoint := this.TL.ToClient(Hwnd)
        OutBrPoint := this.BR.ToClient(Hwnd)
        return Rect(OutTlPoint.X, OutTlPoint.Y, OutBrPoint.X, OutBrPoint.Y)
    }

    /**
     * @description - Constructs a `Rect` using the current object's coordinates converted
     * to screen coordinates using the input Hwnd. The original object's values stay the same.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {VarRef} [OutTlPoint] - A variable that will receive the `Point` object for the top-left
     * corner of the new `Rect`.
     * @param {VarRef} [OutBrPoint] - A variable that will receive the `Point` object for the
     * bottom-right corner of the new `Rect`.
     * @returns {Rect} - The new object.
     */
    ToScreen(Hwnd, &OutTlPoint?, &OutBrPoint?) {
        OutTlPoint := this.TL.ToScreen(Hwnd)
        OutBrPoint := this.BR.ToScreen(Hwnd)
        return Rect(OutTlPoint.X, OutTlPoint.Y, OutBrPoint.X, OutBrPoint.Y)
    }
}

class DisplayBase {
    static __New() {
        if this.Prototype.__Class == 'DisplayBase' {
            this.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
            this.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
    }
}
