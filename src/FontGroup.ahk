
class FontGroup extends Map {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.DefineProp('SubgroupDelete', Map.Prototype.GetOwnPropDesc('Delete'))
    }
    /**
     * @desc - A {@link FontGroup} object is used to group together controls that share the same
     * font. The {@link FontGroup} class inherits from `Map`. The item keys can be anything, and
     * the item values are arrays of integers, where each integer is a control's handle.
     *
     * Though item keys can be anything, the most straightforward approach is to use the parent
     * window's handle as the key. This way, when the window is deleted, the subgroup can be
     * removed from the map easily.
     *
     * @param {Integer} fontSize - The base font size. This value gets set to property
     * {@link FontGroup#fontSize}.
     *
     * @param {Logfont} [logfont] - If set, the {@link Logfont} object to associate
     * with this font group. If unset, a new {@link Logfont} object is created.
     */
    __New(fontSize, logfont?) {
        this.logfont := logfont ?? Logfont()
        this.fontSize := fontSize
    }
    /**
     * @desc - Does the following:
     * - Sets {@link Logfont#fontSize} with {@link FontGroup#fontSize}.
     * - Creates a new font object by calling
     *   {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createfontindirectw CreateFontIndirectW}.
     * - Iterates each subgroup, sending
     *   {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/wm-setfont WM_SETFONT} to each hwnd.
     * - Deletes the old font object.
     *
     * @param {Boolean} [redraw = true] - If true, each control redraws itself.
     */
    Apply(redraw := true) {
        logfont := this.logfont
        logfont.fontSize := this.fontSize
        hFontOld := logfont.handle
        hFont := logfont.handle := DllCall(g_gdi32_CreateFontIndirectW, 'ptr', logfont, 'ptr')
        for key, list in this {
            for hwnd in list {
                SendMessage(0x0030, hFont, redraw, hwnd) ; WM_SETFONT
            }
        }
        if hFontOld {
            DllCall(g_gdi32_DeleteObject, 'ptr', hFontOld, 'int')
        }
    }
    /**
     * @desc - Adds a subgroup to the font group.
     *
     * @param {*} key - The subgroup's key.
     *
     * @param {Integer[]} [list] - If set, an array of window handles. If unset, an empty array
     * is paired with `Key`.
     */
    SubgroupAdd(key, list?) {
        this.Set(key, list ?? [])
    }
    /**
     * @desc - Applies the current font object to the subgroup. Unlike
     * {@link FontGroup.Prototype.Apply}, this does not call
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createfontindirectw CreateFontIndirectW}.
     *
     * @param {*} key - The subgroup's key.
     *
     * @param {Boolean} [redraw = true] - If true, each control redraws itself.
     */
    SubgroupApply(key, redraw := true) {
        hFont := this.logfont.handle
        for hwnd in this.Get(key) {
            SendMessage(0x0030, hFont, redraw, hwnd) ; WM_SETFONT
        }
    }
    /**
     * @desc - Deletes the subgroup.
     *
     * @param {*} key - The subgroup's key.
     */
    SubgroupDelete(key) {
        ; This is overridden
    }

    faceName {
        Get => this.logfont.faceName
        Set => this.logfont.faceName := value
    }
}
