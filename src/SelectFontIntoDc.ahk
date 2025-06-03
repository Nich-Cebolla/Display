
/**
 * @classdesc - Use this as a safe way to access a window's font object. This handles accessing and
 * releasing the device context and font object.
 */
class SelectFontIntoDc {

    __New(hWnd) {
        this.hWnd := hWnd
        if !(this.hdc := DllCall('GetDC', 'Ptr', hWnd, 'ptr')) {
            throw OSError()
        }
        OnError(this.Callback := ObjBindMethod(this, '__ReleaseOnError'), 1)
        if !(this.hFont := SendMessage(0x0031, 0, 0, , hWnd)) { ; WM_GETFONT
            throw OSError()
        }
        if !(this.oldFont := DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.hFont, 'ptr')) {
            throw OSError()
        }
    }

    /**
     * @description - Selects the old font back into the device context, then releases the
     * device context.
     */
    Call() {
        if err := this.__Release() {
            throw err
        }
    }

    __ReleaseOnError(thrown, mode) {
        if err := this.__Release() {
            thrown.Message .= '; ' err.Message
        }
        throw thrown
    }

    __Release() {
        if this.oldFont {
            if !DllCall('SelectObject', 'ptr', this.hdc, 'ptr', this.oldFont, 'int') {
                err := OSError()
            }
            this.DeleteProp('oldFont')
        }
        if this.hdc {
            if !DllCall('ReleaseDC', 'ptr', this.hWnd, 'ptr', this.hdc, 'int') {
                if IsSet(err) {
                    err.Message .= '; Another error occurred: ' OSError().Message
                }
            }
            this.DeleteProp('hdc')
        }
        OnError(this.Callback, 0)
        return err ?? ''
    }

    __Delete() => this()

    static __New() {
        if this.Prototype.__Class == 'SelectFontIntoDc' {
            Proto := this.Prototype
            Proto.DefineProp('hdc', { Value: '' })
            Proto.DefineProp('hFont', { Value: '' })
            Proto.DefineProp('oldFont', { Value: '' })
        }
    }
}
