
#include dWin.ahk
#include ..\lib\GDI+.ahk
global __AlphaBtn := Map()   ; hBtn -> { hGui, pImg, w, h, files }
global __NextCtrlId := 1001  ; simple control ID allocator

class dButton {
    __New(GuiHwnd, ImagePathList, X, Y) {
        if !ImagePathList.Length {
            throw Error('The image path list cannot be empty.', -1)
        }
        this.GuiHwnd := GuiHwnd
        this.Images := []
        this.Images.Capacity := ImagePathList.Length
        G := this.Gui
        GdipStartup()
        dpi := dWin.GetDpi(GuiHwnd)
        for path in ImagePathList {

        }
    }
    Gui => GuiFromHwnd(this.GuiHwnd)
}
CreateAlphaButton(hGui, imageFiles, x, y) {
    best := _PickBestImage(imageFiles, pct)

    pImg := _Gdip_LoadImage(best)
    try {
        w := _Gdip_GetImageW(pImg)
        h := _Gdip_GetImageH(pImg)
    } catch e {
        _Gdip_DisposeImage(pImg)
        throw
    }

    WS_CHILD   := 0x40000000
    WS_VISIBLE := 0x10000000
    WS_TABSTOP := 0x00010000
    BS_OWNERDRAW := 0x0000000B

    style := WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_OWNERDRAW
    exstyle := 0

    id := __NextCtrlId++, hInst := 0
    hBtn := DllCall('CreateWindowExW'
        , 'UInt', exstyle
        , 'Str',  'Button'
        , 'Str',  ''                ; text optional—owner-draw paints
        , 'UInt', style
        , 'Int',  x, 'Int', y, 'Int', w, 'Int', h
        , 'Ptr',  hGui
        , 'Ptr',  id
        , 'Ptr',  hInst
        , 'Ptr',  0
        , 'Ptr')

    if !hBtn {
        _Gdip_DisposeImage(pImg)
        throw Error('CreateWindowExW failed. LastError=' . A_LastError)
    }

    __AlphaBtn[hBtn] := {hGui:hGui, pImg:pImg, w:w, h:h, files:imageFiles}

    ; One-time hook for WM_DRAWITEM on this GUI (parent receives it)
    static hooked := Map()
    if !hooked.Has(hGui) {
        OnMessage(0x002B, WM_DRAWITEM_Handler) ; WM_DRAWITEM
        OnMessage(0x02E0, WM_DPICHANGED_Handler) ; WM_DPICHANGED
        hooked[hGui] := true
    }
    return hBtn
}

; ---------------- Update for DPI ----------------
UpdateAlphaButtonForDpi(hBtn) {
    if !__AlphaBtn.Has(hBtn)
        return
    data := __AlphaBtn[hBtn]
    hGui := data.hGui

    ; reload best image for new DPI
    dpi := _GetDpiForWindow(hGui)
    pct := Round(100 * dpi / 96.0)
    best := _PickBestImage(data.files, pct)

    pNew := _Gdip_LoadImage(best)
    try {
        w := _Gdip_GetImageW(pNew), h := _Gdip_GetImageH(pNew)
    } catch e {
        _Gdip_DisposeImage(pNew)
        throw
    }

    ; replace cached image
    _Gdip_DisposeImage(data.pImg)
    data.pImg := pNew, data.w := w, data.h := h
    __AlphaBtn[hBtn] := data

    ; resize control to image
    SWP_NOZORDER := 0x0004, SWP_NOMOVE := 0x0002
    DllCall('SetWindowPos', 'Ptr', hBtn, 'Ptr', 0, 'Int', 0, 'Int', 0
        , 'Int', w, 'Int', h, 'UInt', SWP_NOZORDER|SWP_NOMOVE)

    ; repaint
    DllCall('InvalidateRect', 'Ptr', hBtn, 'Ptr', 0, 'Int', 1)
}

; ---------------- Destroy ----------------
DestroyAlphaButton(hBtn) {
    if __AlphaBtn.Has(hBtn) {
        data := __AlphaBtn[hBtn]
        _Gdip_DisposeImage(data.pImg)
        __AlphaBtn.Delete(hBtn)
    }
    if hBtn
        DllCall('DestroyWindow', 'Ptr', hBtn)
}

; ---------------- Message handlers ----------------
WM_DPICHANGED_Handler(wParam, lParam, msg, hGui) {
    ; When the GUI’s DPI changes, refresh any alpha buttons on it.
    for hBtn, data in __AlphaBtn {
        if data.hGui = hGui
            UpdateAlphaButtonForDpi(hBtn)
    }
}

WM_DRAWITEM_Handler(wParam, lParam, msg, hWndParent) {
    ; DRAWITEMSTRUCT layout:
    ; UINT CtlType;   UINT CtlID;   UINT itemID;   UINT itemAction;
    ; UINT itemState; HWND hwndItem; HDC hDC;      RECT rcItem;   ULONG_PTR itemData;
    if !lParam
        return
    ; Read fields we need
    hwndItem := NumGet(lParam, 4*4, 'ptr')               ; offset 16: hwndItem (after 5 UINTs)
    if !__AlphaBtn.Has(hwndItem)
        return

    hdc      := NumGet(lParam, 4*4 + A_PtrSize, 'ptr')   ; after hwndItem
    rcLeft   := NumGet(lParam, 4*4 + 2*A_PtrSize + 0, 'int')
    rcTop    := NumGet(lParam, 4*4 + 2*A_PtrSize + 4, 'int')
    rcRight  := NumGet(lParam, 4*4 + 2*A_PtrSize + 8, 'int')
    rcBottom := NumGet(lParam, 4*4 + 2*A_PtrSize + 12, 'int')
    itemState:= NumGet(lParam, 4*3, 'uint')              ; itemState

    data := __AlphaBtn[hwndItem]

    ; 1) Draw themed button background
    _DrawThemedButtonBackground(hwndItem, hdc, rcLeft, rcTop, rcRight, rcBottom, itemState)

    ; 2) Draw the image with full alpha using GDI+
    ; Center the image in the content rect
    w := data.w, h := data.h
    cx := rcRight - rcLeft, cy := rcBottom - rcTop
    dx := rcLeft + (cx - w)//2
    dy := rcTop  + (cy - h)//2

    g := 0
    if DllCall('gdiplus\GdipCreateFromHDC', 'Ptr', hdc, 'Ptr*', &g)
        return
    ; Quality tweaks (optional)
    DllCall('gdiplus\GdipSetInterpolationMode', 'Ptr', g, 'Int', 7) ; HighQualityBicubic
    DllCall('gdiplus\GdipSetPixelOffsetMode',   'Ptr', g, 'Int', 2) ; Half
    ; Dim when disabled
    if (itemState & 0x0008) { ; ODS_DISABLED
        _Gdip_DrawImageWithOpacity(g, data.pImg, dx, dy, w, h, 0.45)
    } else {
        DllCall('gdiplus\GdipDrawImageRectI', 'Ptr', g, 'Ptr', data.pImg
            , 'Int', dx, 'Int', dy, 'Int', w, 'Int', h)
    }
    DllCall('gdiplus\GdipDeleteGraphics', 'Ptr', g)
}

; ---------------- Themed background ----------------
_DrawThemedButtonBackground(hBtn, hdc, L, T, R, B, itemState) {
    ; Prefer themed background for correctness under visual styles
    part := 1  ; BP_PUSHBUTTON
    state := 1 ; PBS_NORMAL
    if (itemState & 0x0001)   ; ODS_SELECTED
        state := 3            ; PBS_PRESSED
    else if _IsHot(hBtn)      ; hover
        state := 2            ; PBS_HOT
    else if (itemState & 0x0010) ; ODS_FOCUS (optional: could show focus cues)
        state := 1
    if (itemState & 0x0008)   ; ODS_DISABLED
        state := 4            ; PBS_DISABLED

    rc := Buffer(16), NumPut('int', L, rc, 0), NumPut('int', T, rc, 4), NumPut('int', R, rc, 8), NumPut('int', B, rc, 12)

    hTheme := DllCall('uxtheme\OpenThemeData', 'Ptr', hBtn, 'WStr', 'Button', 'Ptr')
    if hTheme {
        ; Let the parent’s background bleed correctly (for glass/complex themes)
        DllCall('uxtheme\DrawThemeParentBackground', 'Ptr', hBtn, 'Ptr', hdc, 'Ptr', rc)
        DllCall('uxtheme\DrawThemeBackground', 'Ptr', hTheme, 'Ptr', hdc, 'Int', part, 'Int', state, 'Ptr', rc, 'Ptr', 0)
        DllCall('uxtheme\CloseThemeData', 'Ptr', hTheme)
    } else {
        ; Fallback classic look
        DllCall('user32\FillRect', 'Ptr', hdc, 'Ptr', rc, 'Ptr'
            , DllCall('gdi32\GetStockObject', 'Int', 0, 'Ptr')) ; NULL_BRUSH? We'll paint a flat btnface instead:
        br := DllCall('gdi32\CreateSolidBrush', 'UInt', DllCall('user32\GetSysColor','Int',15,'UInt'), 'Ptr') ; COLOR_BTNFACE
        DllCall('user32\FillRect', 'Ptr', hdc, 'Ptr', rc, 'Ptr', br)
        DllCall('gdi32\DeleteObject', 'Ptr', br)
        if (itemState & 0x0001) { ; pressed
            DllCall('user32\DrawEdge', 'Ptr', hdc, 'Ptr', rc, 'UInt', 0x000A, 'UInt', 0x000F) ; EDGE_SUNKEN | BF_RECT
        } else {
            DllCall('user32\DrawEdge', 'Ptr', hdc, 'Ptr', rc, 'UInt', 0x0009, 'UInt', 0x000F) ; EDGE_RAISED | BF_RECT
        }
    }
}

_IsHot(hBtn) {
    ; naive hover test (mouse over hwnd)
    pt := Buffer(8)
    DllCall('user32\GetCursorPos', 'Ptr', pt)
    x := NumGet(pt, 0, 'int'), y := NumGet(pt, 4, 'int')
    hwndAt := DllCall('user32\WindowFromPoint', 'Int64', (x & 0xFFFFFFFF) | (y << 32), 'Ptr')
    return hwndAt = hBtn
}

; ---------------- GDI+ helpers ----------------
