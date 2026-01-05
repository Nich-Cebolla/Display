
class Display_Size extends Buffer {
    /**
     * @description - A buffer representing a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-size SIZE structure}.
     * @class
     * @param {Integer} [W] - The width.
     * @param {Integer} [H] - The height.
     */
    __New(W?, H?) {
        this.Size := 8
        if IsSet(W) {
            this.W := W
        }
        if IsSet(H) {
            this.H := H
        }
    }
    W {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    H {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}
