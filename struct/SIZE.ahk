
/**
 * @class
 * @description - Implements the `Size` struct.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-size}
 */
class Size extends Buffer {
    /**
     * @description - The `Size` constructor.
     * @param [Width] - The width value.
     * @param [Height] - The height value.
     * @returns {Size}
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

