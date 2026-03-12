
class SelectFontIntoDc {
    static __New() {
        this.DeleteProp('__New')
        Display_SelectFontIntoDc_SetConstants()
        proto := this.Prototype
        proto.hdc :=
        proto.hFont :=
        proto.oldFont := ''
    }
    /**
     * @desc - Use this as a safe way to access a window's font object. This handles accessing and
     * releasing the device context and font object.
     *
     * Usage:
     *
     * @example
     * g := Gui()
     * txt := g.Add("Text", , "Hello, world!")
     * context := SelectFontIntoDc(txt.hwnd)
     * hdc := context.hdc
     * ; do work ...
     * ; when no longer needed
     * context() ; release the device context and delete the font object
     * @
     *
     * @class
     *
     * @param {Integer} hwnd - The handle to the window that will have its font object selected into
     * the device context.
     */
    __New(hWnd) {
        this.hWnd := hWnd
        if !(this.hdc := DllCall(g_user32_GetDC, 'ptr', hWnd, 'ptr')) {
            throw OSError()
        }
        OnError(this, 1)
        if !(this.hFont := SendMessage(0x0031, 0, 0, , hWnd)) { ; WM_GETFONT
            throw OSError()
        }
        if !(this.oldFont := DllCall(g_gdi32_SelectObject, 'ptr', this.hdc, 'ptr', this.hFont, 'ptr')) {
            throw OSError()
        }
    }

    /**
     * @description - Selects the old font back into the device context, then releases the
     * device context.
     * @param {Error} [thrown] - Leave unset.
     */
    Call(thrown?, *) {
        if IsSet(thrown) {
            this.__Release()
            throw thrown
        } else if err := this.__Release() {
            throw err
        }
    }

    __Release() {
        if this.oldFont {
            if !DllCall(g_gdi32_SelectObject, 'ptr', this.hdc, 'ptr', this.oldFont, 'int') {
                err := OSError()
            }
            this.DeleteProp('oldFont')
        }
        if this.hdc {
            if !DllCall(g_user32_ReleaseDC, 'ptr', this.hWnd, 'ptr', this.hdc, 'int') {
                if IsSet(err) {
                    err.Message .= '; Another error occurred: ' OSError().Message
                } else {
                    err := OSError()
                }
            }
            this.DeleteProp('hdc')
        }
        OnError(this, 0)
        return err ?? ''
    }
}
Display_SelectFontIntoDc_SetConstants(force := false) {
    global
    if IsSet(Display_SelectFontIntoDc_constants_set) {
        if !force {
            return
        }
    } else {
        if !IsSet(g_gdi32_SelectObject) {
            g_gdi32_SelectObject := 0
        }
        if !IsSet(g_user32_GetDC) {
            g_user32_GetDC := 0
        }
        if !IsSet(g_user32_ReleaseDC) {
            g_user32_ReleaseDC := 0
        }
    }
    Display_SelectFontIntoDc_LibraryToken := LibraryManager(
        'gdi32', [
            'SelectObject'
        ],
        'user32', [
            'GetDC',
            'ReleaseDC'
        ]
    )

    Display_SelectFontIntoDc_constants_set := true
}
