
class Display_Logfont {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Encoding := 'cp1200'
        Proto.Handle := Proto.Hwnd := 0
        Proto.CbSizeInstance :=
        4 + ; LONG  lfHeight                    0
        4 + ; LONG  lfWidth                     4
        4 + ; LONG  lfEscapement                8
        4 + ; LONG  lfOrientation               12
        4 + ; LONG  lfWeight                    16
        1 + ; BYTE  lfItalic                    20
        1 + ; BYTE  lfUnderline                 21
        1 + ; BYTE  lfStrikeOut                 22
        1 + ; BYTE  lfCharSet                   23
        1 + ; BYTE  lfOutPrecision              24
        1 + ; BYTE  lfClipPrecision             25
        1 + ; BYTE  lfQuality                   26
        1 + ; BYTE  lfPitchAndFamily            27
        64  ; WCHAR lfFaceName[LF_FACESIZE]     28
    }
    /**
     * @description - A wrapper around the LOGFONT structure.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
     * @class
     *
     * @param {Integer} [Hwnd] - The window handle to associate with the `Logfont` object. If
     * set, {@link Display_Logfont.Prototype.Call} is called, filling the structure with the values
     * associated with the window. If unset, the buffer is filled with 0.
     * @param {String} [Encoding] - The encoding used when getting and setting string values associated
     * with LOGFONT members. The default encoding used by `Logfont` objects is UTF-16 (cp1200).
     */
    __New(Hwnd?, Encoding?) {
        /**
         * A reference to the buffer object which is used as the LOGFONT structure.
         * @memberof Logfont
         * @instance
         */
        this.Buffer := Buffer(this.CbSizeInstance, 0)
        if IsSet(Encoding) {
            /**
             * The encoding to use with `StrPut` and `StrGet` when handling strings.
             * @memberof Logfont
             * @instance
             */
            this.Encoding := Encoding
        }
        if IsSet(Hwnd) {
            /**
             * The handle to the window associated with this object, if any.
             * @memberof Logfont
             * @instance
             */
            this.Hwnd := Hwnd
            this()
        }
    }
    /**
     * @description - Calls `CreateFontIndirectW` then sends WM_SETFONT to the window associated
     * with this `Logfont` object.
     * @param {Boolean} [Redraw = true] - The value to pass to the `lParam` parameter when sending
     * WM_SETFONT. If true, the control redraws itself.
     */
    Apply(Redraw := true) {
        hFontOld := SendMessage(0x0031,,, this.Hwnd) ; WM_GETFONT
        Flag := this.Handle = hFontOld
        /**
         * The handle to the font object created by this object.
         * @memberof Logfont
         * @instance
         */
        this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr')
        SendMessage(0x0030, this.Handle, Redraw, this.Hwnd) ; WM_SETFONT
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
    }
    /**
     * @description - Sends WM_GETFONT to the window associated with this `Logfont` object, updating
     * this object's properties with the values obtained from the window.
     * @throws {OSError} - Failed to get font object.
     */
    Call(*) {
        if !DllCall(
            'Gdi32.dll\GetObject',
            'ptr', SendMessage(0x0031,,, this.Hwnd), ; WM_GETFONT
            'int', this.Size,
            'ptr', this,
            'uint'
        ) {
            throw OSError('Failed to get font object.')
        }
    }
    __Delete() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }
    /**
     * Gets or sets the character set.
     * @memberof Logfont
     * @instance
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * Gets or sets the behavior when part of a character is clipped.
     * @memberof Logfont
     * @instance
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * If this `Logfont` object is associated with a window, returns the dpi for the window.
     * @memberof Logfont
     * @instance
     */
    Dpi => this.Hwnd ? DllCall('GetDpiForWindow', 'Ptr', this.Hwnd, 'UInt') : ''
    /**
     * Gets or sets the escapement measured in tenths of a degree.
     * @memberof Logfont
     * @instance
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * Gets or sets the font facename.
     * @memberof Logfont
     * @instance
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set => StrPut(SubStr(Value, 1, 31), this.Ptr + 28, 32, this.Encoding)
    }
    /**
     * Gets or sets the font family.
     * @memberof Logfont
     * @instance
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * Gets or sets the font size. "FontSize" requires that the `Logfont` object is associated
     * with a window handle because it needs a dpi value to work with.
     * @memberof Logfont
     * @instance
     */
    FontSize {
        Get => this.Hwnd ? Round(this.Height * -72 / this.Dpi, 2) : ''
        Set => this.Height := Round(Value * this.Dpi / -72)
    }
    /**
     * Gets or sets the font height.
     * @memberof Logfont
     * @instance
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * Gets or sets the italic flag.
     * @memberof Logfont
     * @instance
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * Gets or sets the orientation measured in tenths of degrees.
     * @memberof Logfont
     * @instance
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * Gets or sets the behavior when multiple fonts with the same name exist on the system.
     * @memberof Logfont
     * @instance
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * Gets or sets the pitch.
     * @memberof Logfont
     * @instance
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * Returns the pointer to the buffer.
     * @memberof Logfont
     * @instance
     */
    Ptr => this.Buffer.Ptr
    /**
     * Gets or sets the quality flag.
     * @memberof Logfont
     * @instance
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * Returns the buffer's size in bytes.
     * @memberof Logfont
     * @instance
     */
    Size => this.Buffer.Size
    /**
     * Gets or sets the strikeout flag.
     * @memberof Logfont
     * @instance
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * Gets or sets the underline flag.
     * @memberof Logfont
     * @instance
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * Gets or sets the weight flag.
     * @memberof Logfont
     * @instance
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * Gets or sets the width.
     * @memberof Logfont
     * @instance
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}
