#include Point.ahk
#include RECT.ahk

class RectBase extends Buffer {
    static __New() {
        this.DeleteProp('__New')
        this.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        this.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
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
    Topleft => Point(this.L, this.T)
    BR => Point(this.R, this.B)
    BottomRight => Point(this.R, this.B)
    L => NumGet(this, 0, 'Int')
    Left => NumGet(this, 0, 'Int')
    X => NumGet(this, 0, 'Int')
    T => NumGet(this, 4, 'Int')
    Top => NumGet(this, 4, 'Int')
    Y => NumGet(this, 4, 'Int')
    R => NumGet(this, 8, 'Int')
    Right => NumGet(this, 8, 'Int')
    B => NumGet(this, 12, 'Int')
    Bottom => NumGet(this, 12, 'Int')
    W => this.R - this.L
    Width => this.R - this.L
    H => this.B - this.T
    Height => this.B - this.T
    MidX => (this.R - this.L) / 2
    MidY => (this.B - this.T) / 2

    /**
     * @description - Constructs a `Rect` using the current object's coordinates converted
     * to client coordinates using the input Hwnd. The original object's values stay the same.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {VarRef} [OutTopLeft] - A variable that will receive the `Point` object for the top-left
     * corner of the new `Rect`.
     * @param {VarRef} [OutBottomRight] - A variable that will receive the `Point` object for the
     * bottom-right corner of the new `Rect`.
     * @returns {Rect} - The new object.
     */
    ToClient(Hwnd, &OutTopLeft?, &OutBottomRight?) {
        OutTopLeft := this.TL
        OutTopLeft.ToClient(Hwnd)
        OutBottomRight := this.BR
        OutBottomRight.ToClient(Hwnd)
        return Rect(OutTopLeft.X, OutTopLeft.Y, OutBottomRight.X, OutBottomRight.Y)
    }

    ToClientInPlace(hWnd) {
        if !DllCall('ScreenToClient', 'ptr', Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', Hwnd, 'ptr', this.ptr + 8, 'int') {
            throw OSError()
        }
    }

    /**
     * @description - Constructs a `Rect` using the current object's coordinates converted
     * to screen coordinates using the input Hwnd. The original object's values stay the same.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {VarRef} [OutTopLeft] - A variable that will receive the `Point` object for the top-left
     * corner of the new `Rect`.
     * @param {VarRef} [OutBottomRight] - A variable that will receive the `Point` object for the
     * bottom-right corner of the new `Rect`.
     * @returns {Rect} - The new object.
     */
    ToScreen(Hwnd, &OutTopLeft?, &OutBottomRight?) {
        OutTopLeft := this.TL
        OutTopLeft.ToScreen(Hwnd)
        OutBottomRight := this.BR
        OutBottomRight.ToScreen(Hwnd)
        return Rect(OutTopLeft.X, OutTopLeft.Y, OutBottomRight.X, OutBottomRight.Y)
    }

    ToScreenInPlace(hWnd) {
        if !DllCall('ClientToScreen', 'ptr', Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ClientToScreen', 'ptr', Hwnd, 'ptr', this.ptr + 8, 'int') {
            throw OSError()
        }
    }
}
