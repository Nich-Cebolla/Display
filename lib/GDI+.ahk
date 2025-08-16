
#include ..\definitions
#include Define-GDI+.ahk

GdipStartup() {
    if GDIP_TOKEN {
        return
    }
    si := Buffer(24, 0)          ; GdiplusStartupInput
    NumPut('uint', 1, si, 0)     ; GdiplusVersion = 1
    if status := DllCall('gdiplus\GdiplusStartup', 'uptr*', &GDIP_TOKEN, 'ptr', si, 'ptr', 0, 'uint') {
        throw OSError('``GdiplusStartup`` failed.', -1, 'Status: ' status)
    }
    OnExit(GdipOnExit, 1)
}

GdipOnExit(*) {
    if GDIP_TOKEN {
        DllCall('gdiplus\GdiplusShutdown', 'ptr', GDIP_TOKEN, 'uint')
        GDIP_TOKEN := 0
    }
}

Gdip_LoadImage(path) {
    p := 0
    if DllCall('gdiplus\GdipLoadImageFromFile', 'WStr', path, 'ptr*', &p, 'uint')
        throw Error('GdipLoadImageFromFile failed: ' path)
    return p
}
Gdip_DisposeImage(p) {
    if p
        DllCall('gdiplus\GdipDisposeImage', 'ptr', p)
}
Gdip_GetImageW(p) {
    w := 0
    DllCall('gdiplus\GdipGetImageWidth', 'ptr', p, 'uint*', &w)
    return w
}
Gdip_GetImageH(p) {
    h := 0
    DllCall('gdiplus\GdipGetImageHeight', 'ptr', p, 'uint*', &h)
    return h
}

; Draw with opacity using ImageAttributes + ColorMatrix
Gdip_DrawImageWithOpacity(g, pImg, x, y, w, h, opacity := 1.0) {
    if (opacity >= 0.999) {
        DllCall('gdiplus\GdipDrawImageRectI', 'ptr', g, 'ptr', pImg, 'int', x, 'int', y, 'int', w, 'int', h)
        return
    }
    ; ColorMatrix is 5x5 floats; last column includes alpha multiplier
    cm := Buffer(100, 0) ; 25 floats
    i := 0
    Loop 25 {
        NumPut('Float', 0.0, cm, (A_Index-1)*4)
    }
    ; Identity
    NumPut('Float', 1.0, cm, (0)*4)   ; m00
    NumPut('Float', 1.0, cm, (6)*4)   ; m11
    NumPut('Float', 1.0, cm, (12)*4)  ; m22
    NumPut('Float', opacity, cm, (18)*4) ; m33 (alpha scale)
    NumPut('Float', 1.0, cm, (24)*4)  ; m44

    imgAttr := 0
    if DllCall('gdiplus\GdipCreateImageAttributes', 'ptr*', &imgAttr)
        return
    DllCall('gdiplus\GdipSetImageAttributesColorMatrix'
        , 'ptr', imgAttr, 'int', 0, 'int', true
        , 'ptr', cm, 'ptr', 0, 'int', 0)

    DllCall('gdiplus\GdipDrawImageRectRectI'
        , 'ptr', g, 'ptr', pImg
        , 'int', x, 'int', y, 'int', w, 'int', h      ; dest
        , 'int', 0, 'int', 0
        , 'int', _Gdip_GetImageW(pImg), 'int', _Gdip_GetImageH(pImg)  ; src
        , 'int', 2   ; UnitPixel
        , 'ptr', imgAttr
        , 'ptr', 0, 'ptr', 0)
    DllCall('gdiplus\GdipDisposeImageAttributes', 'ptr', imgAttr)
}

PickBestImage(files, pct) {
    best := files[1], bestDelta := 1e9
    for f in files {
        if RegExMatch(f, '@(?<dpi>\d+)(?=\.)', &match) {
            dpi := match['dpi']
        } else {
            dpi := 96
        }
        d := Abs(s - pct)
        if (d < bestDelta)
            best := f, bestDelta := d
    }
    return best
}
; --- Add a global cache for image sizes ---
global __ImageDimCache := Map()  ; path -> { w, h }

; --- Read width/height without keeping image loaded ---
GetImageSize(path) {
    global __ImageDimCache
    if __ImageDimCache.Has(path)
        return __ImageDimCache[path]
    _EnsureGDIp()
    p := 0
    if DllCall('gdiplus\GdipLoadImageFromFile', 'WStr', path, 'Ptr*', &p, 'UInt')
        throw Error('GdipLoadImageFromFile failed: ' path)
    w := 0, h := 0
    DllCall('gdiplus\GdipGetImageWidth',  'Ptr', p, 'UInt*', &w)
    DllCall('gdiplus\GdipGetImageHeight', 'Ptr', p, 'UInt*', &h)
    DllCall('gdiplus\GdipDisposeImage', 'Ptr', p)
    dims := { w: w, h: h }
    __ImageDimCache[path] := dims
    return dims
}

; --- Pick best image by dimensions, return chosen path + target control size ---
PickBestImageByDims(files, hGui) {
    if files.Length = 0
        throw Error('imageFiles must contain at least one path.')
    ; Collect sizes and validate aspect ratio
    sizes := []
    for f in files {
        d := _GetImageSize(f)
        sizes.Push({ path: f, w: d.w, h: d.h })
    }
    ; Sort by width (smallest is 'base')
    sizes.Sort((a,b) => a.w - b.w)
    baseW := sizes[1].w, baseH := sizes[1].h
    if baseW <= 0 || baseH <= 0
        throw Error('Invalid image dimensions in ' sizes[1].path)

    ; Check all have the same aspect ratio (within 1px tolerance)
    for s in sizes {
        if Abs(s.w * baseH - s.h * baseW) > 1
            throw Error('Images do not share the same aspect ratio: ' s.path)
    }

    ; Desired scale from current DPI
    dpi := _GetDpiForWindow(hGui)
    desired := dpi / 96.0

    ; Compute scale factor of each file relative to base
    best := sizes[1], bestDelta := 1e9, bestScale := 1.0
    for s in sizes {
        sf := s.w / baseW  ; (also equals s.h/baseH)
        delta := Abs(sf - desired)
        if (delta < bestDelta)
            best := s, bestDelta := delta, bestScale := sf
    }

    ; Target control size in device pixels (physics-consistent size)
    targetW := Round(baseW * desired)
    targetH := Round(baseH * desired)

    ; If you’d rather favor downscale (choose the next larger asset when between),
    ; uncomment this block:
    ; for s in sizes {
    ;     sf := s.w / baseW
    ;     if (sf >= desired) { best := s, bestScale := sf, break }
    ; }
    ; targetW := Round(baseW * desired), targetH := Round(baseH * desired)

    return { path: best.path, targetW: targetW, targetH: targetH }
}
