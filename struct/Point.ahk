
class Point extends Buffer {

    static ScreenToClient(X, Y) {
        Pt := Point(X, Y)
        Pt.ToClient()
        return Pt
    }

    static ClientToScreen(X, Y) {
        Pt := Point(X, Y)
        Pt.ToScreen()
        return Pt
    }

    static GetCaretPos() {
        DllCall('GetCaretPos', 'ptr', pt := Point(), 'int')
        return pt
    }

    static SetCaretPos(X, Y) {
        return DllCall('SetCaretPos', 'int', X, 'int', Y, 'int')
    }

    __New(X?, Y?) {
        this.Size := 8
        if IsSet(X) {
            this.X := X
        }
        if IsSet(Y) {
            this.Y := Y
        }
    }

    Value => (this.X & 0xFFFFFFFF) | (this.Y << 32)
    X {
        Get => NumGet(this, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    Y {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }

    /**
     * @description - Use this to convert screen coordinates (which should already be contained by
     * this Point), to client coordinates. This converts the points in-place; it does not return
     * a new object.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @returns {Boolean} - If succesful, 1. If unsuccessful, 0.
     */
    ToClient(Hwnd) {
        return DllCall("ScreenToClient", "ptr", Hwnd, "ptr", this, 'int')
    }


    /**
     * @description - Use this to convert client coordinates (which should already be contained by
     * this Point), to screen coordinates. This converts the points in-place; it does not return
     * a new object.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @returns {Boolean} - If succesful, 1. If unsuccessful, 0.
     */
    ToScreen(Hwnd) {
        return DllCall("ClientToScreen", "ptr", Hwnd, "ptr", this, 'int')
    }
}


class LogicalPoint extends Point {
    __New(X, Y, Dpi) {
        this.Size := 8
        this.X := X
        this.Y := Y
        this.Dpi := Dpi
    }
    ToPhysical(unit) {
        switch unit, 0 {
            case 'mm':
                return PhysicalPoint(this.X / this.dpi * 25.4, this.Y / this.dpi * 25.4, this.Dpi)
            case 'cm':
                return PhysicalPoint(this.X / this.dpi * 2.54, this.Y / this.dpi * 2.54, this.Dpi)
            case 'in':
                return PhysicalPoint(this.X / this.dpi, this.Y / this.dpi, this.Dpi)
            default:
                throw Error('Invalid unit.', -1, unit)
        }
    }
    IsLogical => true
    IsPhysical => false
}

class PhysicalPoint extends Point {
    __New(X, Y, Dpi) {
        this.Size := 8
        this.X := X * dpi
        this.Y := Y * dpi
        this.Dpi := Dpi
        this.IsLogical := false
    }
    ToLogical(unit) {
        switch unit, 0 {
            case 'mm':
                return LogPoint(this.X * dpi / 25.4, this.Y * dpi / 25.4, this.Dpi)
            case 'cm':
                return LogPoint(this.X * dpi / 2.54, this.Y * dpi / 2.54, this.Dpi)
            case 'in':
                return LogPoint(this.X * dpi, this.Y * dpi, this.Dpi)
            default:
                throw Error('Invalid unit.', -1, unit)
        }
    }
    IsLogical => false
    IsPhysical => true
}
