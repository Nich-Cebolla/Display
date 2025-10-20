class TCITEMW {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSize :=
        ; Size      Type        Symbol         Offset                Padding
        4 +         ; UINT      mask           0
        4 +         ; DWORD     dwState        4
        A_PtrSize + ; DWORD     dwStateMask    8                     +4 on x64 only
        A_PtrSize + ; LPWSTR    pszText        8 + A_PtrSize * 1
        4 +         ; int       cchTextMax     8 + A_PtrSize * 2
        4 +         ; int       iImage         12 + A_PtrSize * 2
        A_PtrSize   ; LPARAM    lParam         16 + A_PtrSize * 2
        proto.offset_mask := 0
        proto.offset_dwState := 4
        proto.offset_dwStateMask := 8
        proto.offset_pszText := 8 + A_PtrSize * 1
        proto.offset_cchTextMax := 8 + A_PtrSize * 2
        proto.offset_iImage := 12 + A_PtrSize * 2
        proto.offset_lParam := 16 + A_PtrSize * 2
    }
    /**
     * @param {Integer} mask - One or more of the following values. To combine values, use the bitwise
     * "|", e.g. `tcitemwObj.mask := 16 | 2`.
     * <pre>
     * |  Symbol             Value    Meaning                                                   |
     * |  ------------------------------------------------------------------------------------  |
     * |  TCIF_IMAGE         1        The iImage member is valid.                               |
     * |  TCIF_PARAM         2        The lParam member is valid.                               |
     * |  TCIF_RTLREADING    4        The string pointed to by pszText will be displayed in     |
     * |                              the direction opposite to the text in the parent window.  |
     * |  TCIF_STATE         8        The dwState member is valid.                              |
     * |  TCIF_TEXT          16       The pszText member is valid.                              |
     * </pre>
     *
     * @param {Integer} [dwState] - Either 1 or 0 to enable or disable the state flag indicated by
     * `dwStateMask`.
     *
     * @param {Integer} [dwStateMask] - One of the following values:
     * <pre>
     * |  Symbol                Value    Meaning                                                   |
     * |  ---------------------------------------------------------------------------------------  |
     * |  TCIS_BUTTONPRESSED    1        The tab control item is selected. This state is only      |
     * |                                 meaningful if the TCS_BUTTONS style flag has been set.    |
     * |  TCIS_HIGHLIGHTED      2        The tab control item is highlighted, and the tab and      |
     * |                                 text are drawn using the current highlight color. When    |
     * |                                 using high-color, this will be a true interpolation,      |
     * |                                 not a dithered color.                                     |
     * </pre>
     *
     * @param {String} [pszText] - If using the `TCITEMW` structure to set a tab's text, pass
     * the text as string to `pszText` and leave `cchTextMatch` unset.
     *
     * @param {Integer} [cchTextMatch] - If using the `TCITEMW` structure to get information about
     * a tab, pass the maximum string length to `cchTextMax` as integer and leave `pszText` unset.
     *
     * @param {Integer} [iImage] - Index in the tab control's image list, or -1 if there is no
     * image for the tab.
     *
     * @param {Integer} [lParam] - An integer to associate with the tab.
     *
     */
    __New(mask?, dwState?, dwStateMask?, pszText?, cchTextMax?, iImage?, lParam?) {
        this.Buffer := Buffer(this.cbSize)
        if IsSet(mask) {
            this.mask := mask
        }
        if IsSet(dwState) {
            this.dwState := dwState
        }
        if IsSet(dwStateMask) {
            this.dwStateMask := dwStateMask
        }
        if IsSet(pszText) {
            this.pszText := pszText
        }
        if IsSet(cchTextMax) {
            this.cchTextMax := cchTextMax
        }
        if IsSet(iImage) {
            this.iImage := iImage
        }
        if IsSet(lParam) {
            this.lParam := lParam
        }
    }
    mask {
        Get => NumGet(this.Buffer, this.offset_mask, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_mask)
        }
    }
    dwState {
        Get => NumGet(this.Buffer, this.offset_dwState, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwState)
        }
    }
    dwStateMask {
        Get => NumGet(this.Buffer, this.offset_dwStateMask, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwStateMask)
        }
    }
    pszText {
        Get {
            if ptr := NumGet(this.Buffer, this.offset_pszText, 'ptr') {
                return StrGet(ptr, 'cp1200')
            } else {
                return ''
            }
        }
        Set {
            if this.HasOwnProp('__pszText') {
                bytes := StrPut(Value, 'UTF-16')
                if this.__pszText.Size < bytes {
                    this.__pszText.Size := bytes
                    NumPut('ptr', this.__pszText.Ptr, this.Buffer, this.offset_pszText)
                    NumPut('int', this.__pszText.Size / 2, this.Buffer, this.offset_cchTextMax)
                }
            } else {
                this.__pszText := Buffer(StrPut(Value, 'UTF-16'))
                NumPut('ptr', this.__pszText.Ptr, this.Buffer, this.offset_pszText)
                NumPut('int', this.__pszText.Size / 2, this.Buffer, this.offset_cchTextMax)
            }
            StrPut(Value, this.__pszText, 'UTF-16')
        }
    }
    cchTextMax {
        Get => NumGet(this.Buffer, this.offset_cchTextMax, 'int')
        Set {
            this.__pszText := Buffer(Value * 2)
            NumPut('ptr', this.__pszText.Ptr, this.Buffer, this.offset_pszText)
            NumPut('int', Value, this.Buffer, this.offset_cchTextMax)
        }
    }
    iImage {
        Get => NumGet(this.Buffer, this.offset_iImage, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_iImage)
        }
    }
    lParam {
        Get => NumGet(this.Buffer, this.offset_lParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lParam)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
