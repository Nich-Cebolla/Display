#include ..\struct\LOGFONT.ahk

class FontGroup extends LOGFONT {
    __New(Parent?, hWnd?) {
        this.Size := 92
        if IsSet(Parent) {
            this.Parent := Number(Parent)
        }
        if IsSet(hWnd) {
            this.Initialize(hWnd)
        }
    }

    Add(hWnd, Sync := false, Redraw := true) {
        if hWnd is Array {
            this.__Item.Push(hWnd*)
            if Sync {
                for h in hWnd {
                    h := Number(h)
                    if !WinExist(h) {
                        throw TargetError('Window not found.', -1, h)
                    }
                    SendMessage(0x30, this.Handle, Redraw, h)  ; 0x30 = WM_SETFONT
                }
            }
        } else {
            this.__Item.Push(hWnd)
            if Sync {
                if !WinExist(hWnd) {
                    throw TargetError('Window not found.', -1, hWnd)
                }
                SendMessage(0x30, this.Handle, Redraw, hWnd)  ; 0x30 = WM_SETFONT
            }
        }
    }

    /**
     * @description - Sets the font object for the window(s) in this group. This will also delete
     * the previous font object if one has been created.
     * @param {Boolean} [Redraw=true] - If true, the window(s) will be redrawn after the font is set.
     * @throws {TargetError} - If a window is not found.
     */
    Apply(Redraw := true) {
        this.FindFont()
        oldHandle := this.Handle
        this.Handle := DllCall('CreateFontIndirect', 'ptr', this, 'ptr')
        for hWnd in this.__Item {
            if !WinExist(hWnd) {
                throw TargetError('Window not found.', -1, hWnd)
            }
            SendMessage(0x30, this.Handle, Redraw, hWnd)  ; 0x30 = WM_SETFONT
        }
        if oldHandle {
            if !DllCall('DeleteObject', 'ptr', oldHandle, 'int') {
                throw Error('Failed to delete old font object.', -1)
            }
        }
    }

    ; these exist on the base class
    ; Clone()
    ; DisposeFont()
    ; DpiScaleSize()

    Get() {
        if !WinExist(this.Parent) {
            throw TargetError('Window not found.', -1, this.Parent)
        }
        if !(hFont := SendMessage(0x0031,,, this.Parent)) {
            throw Error('Failed to get hFont.', -1)
        }
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', 92, 'ptr', this, 'int') {
            throw Error('Failed to get font object.', -1)
        }
    }

    Initialize(hWnd?) {
        if IsSet(hWnd) {
            if hWnd is Array {
                if !this.HasOwnProp('Parent') {
                    this.Parent := Number(hWnd.RemoveAt(1))
                }
                item := this.__Item := []
                item.Capacity := hWnd.Length
                for h in hWnd {
                    item.Push(Number(h))
                }
            } else {
                if this.HasOwnProp('Parent') {
                    if this.HasOwnProp('__Item') {
                        this.__Item.Push(Number(hWnd))
                    } else {
                        this.__Item := [Number(hWnd)]
                    }
                } else {
                    this.Parent := Number(hWnd)
                }
            }
        }
        this.Get()
        this.LastFontSize := this.FontSize
        this.LastDpi := this.Dpi
    }

    Remove(hWnd) {
        for h in this {
            if h = hWnd {
                return this.__Item.RemoveAt(A_Index)
            }
        }
    }

    Set(Prop, Value, Sync := false) {
        if HasProp(this, Prop) {
            this.%Prop% := Value
        } else {
            throw Error('Property not found.', -1, Prop)
        }
        if Sync {
            this.Apply()
        }
    }

    /**
     * @description - Sets the parent window for this font group. This will overwrite the current
     * font properties with the properties of the parent window.
     * @param {String} hWnd - The handle of the parent window.
     * @param {Boolean} [Sync=false] - If true, the font properties of all windows in this group will
     * be updated to match the parent window.
     */
    SetParent(hWnd, Sync := false) {
        this.Parent := hWnd
        this.Get()
        if Sync {
            this.Apply()
        }
    }

    ; this exists on the base class
    ; __Delete()

    __Enum(VarCount) => this.__Item.__Enum(VarCount)

    hWnd => this.Parent
}

class FontGroupCollection extends Map {
    Add(Name, Parent, hWnd?) {
        this.Set(Name, FontGroup(Parent, hWnd ?? unset))
    }
}
