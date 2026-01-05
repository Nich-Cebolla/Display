
class Display_Point extends Buffer {
    /**
     * @description - A buffer representing a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-point POINT structure}.
     * @class
     * @param {Integer} [X] - The x coordinate.
     * @param {Integer} [Y] - The y coordinate.
     */
    __New(X?, Y?) {
        this.Size := 8
        if IsSet(X) {
            this.X := X
        }
        if IsSet(Y) {
            this.Y := Y
        }
    }
    X {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    Y {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    Value => (this.X & 0xFFFFFFFF) | (this.Y << 32)
}
