#include C:\Users\Shared\001_Repos\AutoHotkey-LibV2\RectHighlight.ahk
#include <DisplayConfig>
#include C:\Users\Shared\001_Repos\AutoHotkey-LibV2\structs\Rect.ahk

persistent
t()
t() {

    FloatingText('test')
}


WndProc_GDI(hwnd, uMsg, wParam, lParam) {
    static WM_PAINT := 0x000F, WM_DESTROY := 0x0002
    static ps := Buffer(64, 0)

    switch uMsg {
        case WM_PAINT:
            hdc := DllCall('BeginPaint', 'ptr', hwnd, 'ptr', ps, 'ptr')

            ; Create GDI+ graphics from HDC
            DllCall('gdiplus\GdipCreateFromHDC', 'ptr', hdc, 'ptr*', &graphics := 0)

            ; Create font
            DllCall('gdiplus\GdipCreateFontFamilyFromName', 'wstr', 'Segoe UI', 'ptr', 0, 'ptr*', &fontFam := 0)
            DllCall('gdiplus\GdipCreateFont', 'ptr', fontFam, 'float', 24.0, 'int', 0, 'int', 0, 'ptr*', &font := 0)

            ; Create brush
            DllCall('gdiplus\GdipCreateSolidFill', 'uint', 0xFF3399FF, 'ptr*', &brush := 0)

            ; Get text
            txt := DllCall('GetPropW', 'ptr', hwnd, 'str', 'GDIText', 'ptr')

            ; Create layout rectangle
            rc := Buffer(16)
            DllCall('GetClientRect', 'ptr', hwnd, 'ptr', rc)
            layout := Buffer(16*4, 0) ; RectF (x, y, width, height)
            NumPut('float', 0, layout, 0)
            NumPut('float', 0, layout, 4)
            NumPut('float', NumGet(rc, 8, 'int'), layout, 8)
            NumPut('float', NumGet(rc, 12, 'int'), layout, 12)

            ; Draw the string
            DllCall('gdiplus\GdipDrawString', 'ptr', graphics, 'ptr', txt, 'int', -1,
                'ptr', font, 'ptr', layout, 'ptr', 0, 'ptr', brush)

            ; Clean up
            DllCall('gdiplus\GdipDeleteBrush', 'ptr', brush)
            DllCall('gdiplus\GdipDeleteFont', 'ptr', font)
            DllCall('gdiplus\GdipDeleteFontFamily', 'ptr', fontFam)
            DllCall('gdiplus\GdipDeleteGraphics', 'ptr', graphics)

            DllCall('EndPaint', 'ptr', hwnd, 'ptr', ps)
            return 0

        case WM_DESTROY:
            DllCall('PostQuitMessage', 'int', 0)
            return 0
    }
    return DllCall('DefWindowProc', 'ptr', hwnd, 'uint', uMsg, 'ptr', wParam, 'ptr', lParam)
}

class FloatingText {
    static __New() {
        this.DeleteProp('__New')
        this.ClassName := 'FLOATING_TEXT_WINDOW'
    }
    static Call(Text, WindowTitle, X := 0, Y := 0, W?, H?) {
        if !this.HasOwnProp('hInstance') {
            this.hInstance := DllCall('GetModuleHandle', 'ptr', 0, 'ptr')
        }
        Gdip_StartupToken := 0

        ; Load GDI+ and start it
        gdip := DllCall('LoadLibrary', 'str', 'gdiplus', 'ptr')
        if !gdip {
            throw OSError('GDI+ not found')
        }
        startupInstance := Buffer(24, 0)
        NumPut('uint', 1, startupInstance) ; GdiplusVersion = 1
        if DllCall('gdiplus\GdiplusStartup', 'ptr*', &Gdip_StartupToken, 'ptr', startupInstance, 'ptr', 0, 'uint') {
            throw OSError('GdiplusStartup failed')
        } else {
            this.StartupToken := Gdip_StartupToken
        }

        size_WNDCLASSEX := A_PtrSize == 8 ? 80 : 48
        wc := Buffer(size_WNDCLASSEX)
        if this.HasOwnProp('ClassAtom') {
            NumPut('uint', size_WNDCLASSEX, wc)
            if !DllCall('GetClassInfoExA', 'ptr', this.hInstance, 'ptr', StrPtr(this.ClassName), 'ptr', wc, 'int') {
                throw OSError()
            }
        } else {
            this.WndProc_GDI := CallbackCreate(WndProc_GDI, 'Fast')
            if !(hCursor := DllCall('LoadCursor', 'ptr', 0, 'ptr', 32512, 'ptr')) {
                throw OSError()
            }
            if !(hbrBackground := DllCall('GetStockObject', 'int', 0, 'ptr')) {
                throw OSError()
            }
            NumPut(
                'uint', size_WNDCLASSEX         ; cbSize
              , 'uint', 0                       ; style
              , 'ptr', this.WndProc_GDI         ; lpfnWndProc
              , 'int', 0                        ; cbClsExtra
              , 'int', 0                        ; cbWndExtra
              , 'ptr', this.hInstance           ; hInstance
              , 'ptr', 0                        ; hIcon
              , 'ptr', hCursor                  ; hCursor
              , 'ptr', hbrBackground            ; hbrBackground
              , 'ptr', 0                        ; lpszMenuName
              , 'ptr', StrPtr(this.ClassName)   ; lpszClassName
              , 'ptr', 0                        ; hIconSm
              , wc
            )
            if !(this.ClassAtom := DllCall('RegisterClassEx', 'ptr', wc, 'ushort')) {
                throw OSError()
            }
        }

        ; Create the window
        if !(hwnd := DllCall(
            'CreateWindowEx'
          , 'uint', 0x00080000 | 0x08000000         ; dwExStyle - WS_EX_LAYERED | WS_EX_NOACTIVATE
          , 'ptr', this.ClassAtom                   ; lpClassName
          , 'ptr', StrPtr(WindowTitle)              ; lpWindowName
          , 'uint', 0x80000000 | 0x10000000         ; dwStyle - WS_POPUP | WS_VISIBLE
          , 'int', X
          , 'int', Y
          , 'int', W
          , 'int', H
          , 'ptr', 0                                ; hWndParent
          , 'ptr', 0                                ; hMenu
          , 'ptr', this.hInstance                   ; hInstance
          , 'ptr', 0                                ; lpParam
          , 'ptr'
        )) {
            throw OSError()
        }
        hdc := DllCall('CreateCompatibleDC', 'ptr', 0, 'ptr')
        size_BITMAPINFOHEADER := 40
        bih := Buffer(size_BITMAPINFOHEADER)
        NumPut(
            'uint', size_BITMAPINFOHEADER   ; biSize
          , 'uint', W                       ; biWidth
          , 'uint', -H                      ; biHeight
          , 'ushort', 1                     ; biPlanes
          , 'ushort', 32                    ; biBitCount
          , 'uint', 0                       ; biCompression
          , 'uint', 0                       ; biSizeImage
          , 'uint', 0                       ; biXPelsPerMeter
          , 'uint', 0                       ; biYPelsPerMeter
          , 'uint', 0                       ; biClrUsed
          , 'uint', 0                       ; biClrImportant
          , bih
        )
        ppvBits := 0
        if !(hBitmap := DllCall(
            'CreateDIBSection'
          , 'ptr', hdc          ; hdc
          , 'ptr', bih          ; *pbmi
          , 'uint', 0           ; usage
          , 'ptr', &ppvBits     ; **ppvBits
          , 'ptr', 0            ; hSection
          , 'uint', 0           ; offset
          , 'ptr'
        )) {
            throw OSError()
        }

        DllCall('gdiplus\GdipCreateFromHDC', 'ptr', hdc, 'ptr*', &graphics := 0)
        DllCall('gdiplus\GdipSetSmoothingMode', 'ptr', graphics, 'int', 4) ; AntiAlias

        ; Clear background (fully transparent)
        DllCall('gdiplus\GdipGraphicsClear', 'ptr', graphics, 'uint', 0x00000000)

        ; Create font + brush
        DllCall('gdiplus\GdipCreateFontFamilyFromName', 'wstr', 'Segoe UI', 'ptr', 0, 'ptr*', &fontFam := 0)
        DllCall('gdiplus\GdipCreateFont', 'ptr', fontFam, 'float', fontSize, 'int', 0, 'int', 0, 'ptr*', &font := 0)
        DllCall('gdiplus\GdipCreateSolidFill', 'uint', 0xFF00CCFF, 'ptr*', &brush := 0) ; ARGB

        layout := BufferAlloc(16)
        NumPut('float', 0, layout, 0)
        NumPut('float', 0, layout, 4)
        NumPut('float', width, layout, 8)
        NumPut('float', height, layout, 12)

        DllCall('gdiplus\GdipDrawString', 'ptr', graphics, 'wstr', Text, 'int', -1,
            'ptr', font, 'ptr', layout, 'ptr', 0, 'ptr', brush)

        ; --- Push to layered window ---
        blend := BufferAlloc(4)
        NumPut('uchar', 255, blend, 0)  ; BlendOp
        NumPut('uchar', 0, blend, 1)    ; BlendFlags
        NumPut('uchar', 255, blend, 2)  ; SourceConstantAlpha
        NumPut('uchar', 1, blend, 3)    ; AlphaFormat = AC_SRC_ALPHA

        ptSrc := BufferAlloc(8, 0)
        ptSize := BufferAlloc(8)
        NumPut('int', width, ptSize, 0)
        NumPut('int', height, ptSize, 4)

        DllCall('UpdateLayeredWindow', 'ptr', hwnd, 'ptr', hdcScreen, 'ptr', 0, 'ptr', ptSize,
            'ptr', hdcMem, 'ptr', ptSrc, 'uint', 0, 'ptr', blend, 'uint', 2) ; ULW_ALPHA
        ; Store the text for later
        txtBuf := Buffer(StrLen(Text)*2 + 2, 0)
        StrPut(Text, txtBuf, 'UTF-16')
        DllCall('SetPropW', 'ptr', hwnd, 'str', 'GDIText', 'ptr', txtBuf)

        DllCall('ShowWindow', 'ptr', hwnd, 'int', 5)
        DllCall('UpdateWindow', 'ptr', hwnd)

        ; Message loop
        Msg := Buffer(48, 0)
        while DllCall('GetMessage', 'ptr', Msg, 'ptr', 0, 'uint', 0, 'uint', 0)
        {
            DllCall('TranslateMessage', 'ptr', Msg)
            DllCall('DispatchMessage', 'ptr', Msg)
        }

        PersistentTextWindowCleanupHandler.ShutdownGdiplus()
    }
    static Add(callbacks*) {
        i := this.Callbacks.Length
        this.Callbacks.Push(callbacks*)
        return i
    }
    static Add_ShutdownGdiplus(token) {
        if this.HasOwnProp('StartupToken') {
            throw Error('A startup token has already been registered.', -1)
        } else {
            this.StartupTokenIndex := this.Callbacks.Push(DllCall.Bind('gdiplus\GdiplusShutdown', 'ptr', token))
            this.StartupToken := token
        }
    }
    static Add_CallbackFree(Address) {
        this.Callbacks.Push(CallbackFree.Bind(Address))
    }
    static ShutdownGdiplus() {
        this.Callbacks.RemoveAt(this.StartupTokenIndex)()
        this.DeleteProp('StartupToken')
        this.DeleteProp('StartupTokenIndex')
    }
    static SetOnExit(n) {
        OnExit(this, n)
        this.OnExit := n
    }
}
