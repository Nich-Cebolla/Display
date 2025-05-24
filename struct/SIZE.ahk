
/**
 * @class
 * @description - Implements the `SIZE` struct.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-size}
 */
class SIZE extends Buffer {
    /**
     * @description - The `SIZE` constructor.
     * @param [Width] - The width value.
     * @param [Height] - The height value.
     * @returns {SIZE}
     */
    __New(Width?, Height?) {
        this.Size := 8
        if IsSet(Width) {
            this.Width := Width
        }
        if IsSet(Height) {
            this.Height := Height
        }
    }
    Width {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    Height {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}

