
/**
 * @classdesc - A wrapper around the LOGFONT structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
 */
class LOGFONT extends Buffer {
    /**
     * @class - Creates a new `LOGFONT` object. This object is a reusable buffer object
     * that is used to get or set font details for a control (or other window).
     * @example
     * G := Gui('+Resize -DPIScale')
     * Txt := G.Add('Text', , 'Some text')
     * G.Show()
     * lf := LOGFONT()
     * Font(Txt.hWnd)
     * MsgBox(Font.FaceName) ; Ms Shell Dlg
     * MsgBox(Font.FontSize) ; 11.25
     * Txt.SetFont('s15', 'Roboto')
     * Font(Txt.hWnd)
     * MsgBox(Font.FaceName) ; Roboto
     * MsgBox(Font.FontSize) ; 15.00
     * @
     * @return {LOGFONT} - A new `LOGFONT` object.
     */
    __New(hWnd?) {
        this.Size := 92
        this.Handle := ''
        this.__FontNames := []
        if IsSet(hWnd) {
            this.Initialize(hWnd)
        }
    }

    /**
     * @description - Attempts to set a window's font object using this object's values.
     */
    Apply(Redraw := true) {
        this.FindFont()
        if !(hFontOld := SendMessage(0x0031,,, this.hWnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        ; This checks if the `hFontOld` is a handle to an object that was created by this class.
        ; We don't want to delete any objects that we didn't create. We also want to make sure we
        ; do delete objects that we did create and that are no longer needed.
        Flag := this.Handle = hFontOld
        SendMessage(0x30, this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr'), Redraw, this.hWnd)  ; 0x30 = WM_SETFONT
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
    }

    Clone(lf?) {
        if !IsSet(lf) {
            lf := %this.__Class%()
        }
        lf.Height := this.Height
        lf.Width := this.Width
        lf.Escapement := this.Escapement
        lf.Orientation := this.Orientation
        lf.Weight := this.Weight
        lf.Italic := this.Italic
        lf.Underline := this.Underline
        lf.StrikeOut := this.StrikeOut
        lf.CharSet := this.CharSet
        lf.OutPrecision := this.OutPrecision
        lf.ClipPrecision := this.ClipPrecision
        lf.Quality := this.Quality
        lf.Pitch := this.Pitch
        lf.Family := this.Family
        lf.FaceName := this.FaceName
        return lf
    }

    DisposeFont() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }

    FindFont(Apply := true) {
        hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
        names := this.__FontNames
        cb := CallbackCreate(_EnumFontFamilies, 'F')
        found := false
        loop names.Length {
            name := names[A_Index]
            if StrLen(name) > 31 {
                throw Error('Font name too long.', -1, name)
            }
            StrPut(name, this.ptr + 28, 32, this.Encoding)
            DllCall('EnumFontFamiliesEx', 'ptr', hdc, 'ptr', this, 'ptr', cb, 'ptr', 0, 'uint', 0, 'int')
            if found {
                break
            }
        }
        CallbackFree(cb)
        if !found {
            loop 32 {
                NumPut('char', 0, this.ptr + 28, A_Index - 1)
            }
        }
        if Apply {
            this.Apply()
        }

        return

        _EnumFontFamilies(lpelfe, lpntme, FontType, lParam) {
            found := true
            return 0
        }
    }

    /**
     * @description - Gets / updates the structure with the window's current font details.
     */
    Get() {
        if !WinExist(this.hWnd) {
            throw TargetError('Window not found.', -1, this.hWnd)
        }
        if !(hFont := SendMessage(0x0031,,, this.hWnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', 92, 'ptr', this, 'int') {
            throw Error('Failed to get font object.', -1)
        }
    }

    Initialize(hWnd) {
        this.hWnd := hWnd
        this.Get()
        this.BaseFontSize := this.FontSize
        this.__FontNames.Push(this.FaceName)
    }

    OnDpiChanged(newDpi) {
        this.Height := Round(this.BaseFontSize * newDpi / -72)
        this.Apply()
    }

    Set(Name, Value, Apply := false) {
        if HasProp(this, Name) {
            this.%Name% := Value
        } else {
            throw Error('Property not found.', -1, Name)
        }
        if Apply {
            this.Apply()
        }
    }

    SetFontSize(newSize) {
        this.BaseFontSize := newSize
        this.Height := Round(newSize * this.Dpi / -72)
        this.Apply()
    }

    __Delete() {
        this.DisposeFont()
    }

    /**
     * @property {Integer} LOGFONT.Height - The height of the font in logical units.
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * @property {Integer} LOGFONT.Width - The average width of characters in the font.
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    /**
     * @property {Integer} LOGFONT.Escapement - The angle of escapement, in tenths of degrees.
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * @property {Integer} LOGFONT.Orientation - The angle of orientation, in tenths of degrees.
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * @property {Integer} LOGFONT.Weight - The weight of the font.
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * @property {Boolean} LOGFONT.Italic - The italic flag.
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * @property {Boolean} LOGFONT.Underline - The underline flag.
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * @property {Boolean} LOGFONT.StrikeOut - The strikeout flag.
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * @property {Integer} LOGFONT.CharSet - The character set of the font.
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * @property {Integer} LOGFONT.OutPrecision - The output precision of the font.
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * @property {Integer} LOGFONT.ClipPrecision - The clipping precision of the font.
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * @property {Integer} LOGFONT.Quality - The quality of the font.
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * @property {Integer} LOGFONT.Pitch - The pitch of the font.
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * @property {Integer} LOGFONT.Family - The font group to which the font belongs.
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * @property {String} LOGFONT.FaceName - The name of the font.
     */
    FaceName {
        Get => StrGet(this.ptr + 28, , this.Encoding)
        Set => HasMethod(Value, '__Enum') ? this.__FontNames.Push(Value*) : this.__FontNames.Push(Value)
    }
    /**
     * @property {Integer} LOGFONT.FontSize - The size of the font in points.
     */
    FontSize[digits := 0] {
        Get => Round(this.Height * -72 / this.Dpi, digits)
        Set => this.Height := Round(Value * this.Dpi / -72, digits)
    }
    /**
     * @property {Integer} LOGFONT.Dpi - The DPI of the window to which `hWnd` is the handle.
     */
    Dpi => DllCall('User32\GetDpiForWindow', 'Ptr', this.hWnd, 'UInt')

    static __New() {
        this.DeleteProp('__New')
        this.Prototype.DefineProp('Encoding', { Value: 'UTF-16' })
    }
}
