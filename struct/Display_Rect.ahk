
class Display_Rect extends Buffer {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.offset_l := 0
        proto.offset_t := 4
        proto.offset_r := 8
        proto.offset_b := 12
        Display_Rect_SetConstants()
    }
    __New(L?, T?, R?, B?) {
        this.Size := 16
        if IsSet(L) {
            this.L := L
        }
        if IsSet(T) {
            this.T := T
        }
        if IsSet(R) {
            this.R := R
        }
        if IsSet(B) {
            this.B := B
        }
    }
    ToClient(hwndParent) {
        if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
    }
    ToScreen(hwndParent) {
        if !DllCall(g_user32_ClientToScreen, 'ptr', hwndParent, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
    }
    L {
        Get => NumGet(this, this.offset_l, 'int')
        Set => NumPut('int', Value, this, this.offset_l)
    }
    T {
        Get => NumGet(this, this.offset_t, 'int')
        Set => NumPut('int', Value, this, this.offset_t)
    }
    R {
        Get => NumGet(this, this.offset_r, 'int')
        Set => NumPut('int', Value, this, this.offset_r)
    }
    B {
        Get => NumGet(this, this.offset_b, 'int')
        Set => NumPut('int', Value, this, this.offset_b)
    }
    X {
        Get => NumGet(this, this.offset_l, 'int')
        Set => NumPut('int', Value, this, this.offset_l)
    }
    Y {
        Get => NumGet(this, this.offset_t, 'int')
        Set => NumPut('int', Value, this, this.offset_t)
    }
    W {
        Get => NumGet(this, 8, 'int') - NumGet(this, 0, 'int')
        Set => NumPut('int', NumGet(this, this.offset_l, 'int') + Value, this, this.offset_r)
    }
    H {
        Get => NumGet(this, 12, 'int') - NumGet(this, 4, 'int')
        Set => NumPut('int', NumGet(this, this.offset_t, 'int') + Value, this, this.offset_b)
    }
}

Display_Rect_SetConstants(force := false) {
    global
    if IsSet(Display_Rect_constants_set) {
        if !force {
            return
        }
    } else {
        if !IsSet(g_user32_ClientToScreen) {
            g_user32_ClientToScreen := 0
        }
        if !IsSet(g_user32_ScreenToClient) {
            g_user32_ScreenToClient := 0
        }
    }
    Display_Rect_LibraryToken := LibraryManager(
        'user32', [
            'ClientToScreen',
            'ScreenToClient'
        ]
    )
    Display_Rect_constants_set := true
}
