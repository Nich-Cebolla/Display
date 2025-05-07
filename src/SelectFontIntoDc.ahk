

class SelectFontIntoDc {

    __New(hWnd) {
        this.hWnd := hWnd
        if !(this.hdc := DllCall('GetDC', 'Ptr', this.hWnd, 'ptr')) {
            throw OSError()
        }
        OnError(ObjBindMethod(this, 'ReleaseOnError'), 1)
        if !(this.hFont := SendMessage(0x0031, 0, 0, , this.hWnd)) { ; WM_GETFONT
            throw OSError()
        }
        if !(this.oldFont := DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.hFont, 'ptr')) {
            throw OSError()
        }
    }

    Call() {
        if this.HasOwnProp('oldFont') {
            if !DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.oldFont, 'int') {
                err := OSError()
            }
        }
        if !DllCall('ReleaseDC', 'ptr', this.hWnd, 'ptr', this.hdc, 'int') {
            if IsSet(err) {
                err.Message .= '; Another error occurred: ' OSError().Message
            }
        }
        OnError(ObjBindMethod(this, 'ReleaseOnError'), 0)
        if IsSet(err) {
            throw err
        }
    }

    ReleaseOnError(thrown, mode) {
        if this.HasOwnProp('oldFont') {
            if !DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.oldFont, 'int') {
                thrown.Message .= '; Another error occurred: ' OSError().Message
            }
        }
        if !DllCall('ReleaseDC', 'ptr', this.hWnd, 'ptr', this.hdc, 'int') {
            thrown.Message .= '; Another error occurred: ' OSError().Message
        }
        throw thrown
    }

    __Delete() {
        OnError(this.Callback, 0)
    }
}
