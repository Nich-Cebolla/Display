
#include dMon.ahk
#include ..\struct
#include Display_Point.ahk
#include Display_Rect.ahk

Display_AdjustWindowRectEx(lpRect, dwStyle := 0, bMenu := 0, dwExStyle := 0) {
    return DllCall('AdjustWindowRectEx', 'ptr', lpRect, 'uint', dwStyle, 'int', bMenu, 'uint', dwExStyle)
}
Display_AdjustWindowRectExForDpi(lpRect, dwStyle := 0, bMenu := 0, dwExStyle := 0) {
    return DllCall('AdjustWindowRectExForDpi', 'ptr', lpRect, 'int', dwStyle, 'int', bMenu, 'int', dwExStyle, 'int', dMon.Dpi.Rect(lpRect))
}
Display_AllowSetForegroundWindow(PID?) {
    if !DllCall('AllowSetForegroundProcess', 'uint', PID ?? WinGetPid(A_ScriptHwnd), 'int') {
        throw OSError()
    }
}
/**
 * @description - Calls `BeginDeferWindowPos`, which is used to prepare for adjusting the
 * dimensions of multiple windowss at once. This reduces flickering and increases
 * performance. After calling this function, fill the structure by calling {@link Display_DeferWindowPos}.
 * All windows must have the same parent window.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-begindeferwindowpos}
 * @param {Integer} [InitialCount = 2] - An estimate of the number of windows that will be
 * adjusted. The count will be adjusted automatically when calling `DeferWindowPos`, so it's
 * okay if this is not exact.
 * @return {Integer} - Returns a handle to the `hWinPosInfo` structure if successful, else 0.
 */
Display_BeginDeferWindowPos(InitialCount := 2) {
    return DllCall('BeginDeferWindowPos', 'int', InitialCount, 'ptr')
}
Display_BringWindowToTop(Hwnd) {
    return DllCall('BringWindowToTop', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}
Display_ChildWindowFromPoint(Hwnd, X, Y) {
    return DllCall('ChildWindowFromPoint', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
Display_ChildWindowFromPointEx(Hwnd, X, Y, flags := 0) {
    return DllCall('ChildWindowFromPointEx', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', flags, 'ptr')
}
/**
 * @description - Calls `DeferWindowPos`, which is used to prepare a window for being adjusted
 * when `EndDeferWindowPos` is called.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-deferwindowpos}
 * @param {Integer} hWinPosInfo - The handle to the `hWinPosInfo` structure created by
 * `BeginDeferWindowPos`.
 * @param {Integer} Hwnd - The handle of the window to adjust.
 * @param {Integer} X - The new x-coordinate of the window.
 * @param {Integer} Y - The new y-coordinate of the window.
 * @param {Integer} W - The new Width of the window.
 * @param {Integer} Y - The new Height of the window.
 * @param {Integer} [uFlags = 0] - A set of flags that control the window adjustment. The most
 * common flag is `SWP_NOZORDER` (0x0004), which prevents the window from being reordered. See
 * the link for the table of values.
 * @param {Integer} [HwndInsertAfter = 0] - A handle to the window to precede the positioned
 * window in the Z-order, or one of the values listed on the linked webpage.
 * @return {Integer} - Returns the handle the the structure. It is important to use this return
 * value for the next call to `DeferWindowPos` or `EndDeferWindowPos` because the handle may
 * have changed.
 */
Display_DeferWindowPos(hWinPosInfo, Hwnd, X, Y, W, H, uFlags := 0, HwndInsertAfter := 0) {
    return DllCall('DeferWindowPos', 'ptr', hWinPosInfo, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', IsObject(HwndInsertAfter) ? HwndInsertAfter.Hwnd : HwndInsertAfter
    , 'int', X, 'int', Y, 'int', W, 'int', H, 'uint', uFlags, 'ptr')
}
Display_DestroyWindow(Hwnd) {
    return DllCall('DestroyWindow', 'ptr', Hwnd, 'int')
}
/**
 * @description - Calls `EndDeferWindowPos`. Use this after setting the DWP struct.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enddeferwindowpos}
 * @param {Integer} hDwp - The handle to the `hWinPosInfo` structure.
 * @return {Boolean} - 1 if successful, 0 if unsuccessful.
 */
Display_EndDeferWindowPos(hDwp) {
    return DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr')
}
Display_EnumChildWindows(HwndParent, Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall('EnumChildWindows', 'ptr', IsObject(HwndParent) ? HwndParent.Hwnd : HwndParent, 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}
Display_EnumThreadWindows(PID, Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall('EnumThreadWindows', 'uint', PID, 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}
Display_EnumWindows(Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall('EnumWindows', 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}
Display_FromPhysicalPoint(X, Y) {
    return DllCall('WindowFromPhysicalPoint', 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
Display_FromPoint(X, Y) {
    return DllCall('WindowFromPoint', 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
Display_GetActiveWindow() {
    return DllCall('GetActiveWindow', 'ptr')
}
/**
 * @param Flags -
 * - 1 : Retrieves the parent window. This does not include the owner, as it does with the GetParent function.
 * - 2 : Retrieves the root window by walking the chain of parent windows.
 * - 3 : Retrieves the owned root window by walking the chain of parent and owner windows returned by GetParent.
 */
Display_GetAncestor(Hwnd, Flags) {
    return DllCall('GetAncestor', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Flags, 'ptr')
}
/**
 * @description - Gets the bounding rectangle of all child windows of a given window.
 * @param {Integer} Hwnd - The handle to the parent window.
 * @returns {Display_Rect} - The bounding rectangle of all child windows, specifically the smallest
 * rectangle that contains all child windows.
 */
Display_GetChildrenBoundingRect(Hwnd) {
    rects := [Buffer(16), Buffer(16), Buffer(16)]
    DllCall('EnumChildWindows', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', cb := CallbackCreate(_EnumChildWindowsProc, 'fast',  1), 'int', 0, 'int')
    CallbackFree(cb)
    return rects[1]

    _EnumChildWindowsProc(Hwnd) {
        DllCall('GetWindowRect', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', rects[1], 'int')
        DllCall('UnionRect', 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
        rects.Push(rects.RemoveAt(1))
        return 1
    }
}
Display_GetClientRect(Hwnd, &lpRect) {
    return DllCall('GetClientRect', 'ptr', Hwnd, 'ptr', lpRect := Display_Rect(), 'int')
}
Display_GetDesktopWindow() {
    return DllCall('GetDesktopWindow', 'ptr')
}
Display_GetDpi(Hwnd) => DllCall('GetDpiForWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
Display_GetForegroundWindow() => DllCall('GetForegroundWindow', 'ptr')
/**
 * @param Cmd -
 * - 2 : Returns a handle to the window below the given window.
 * - 3 : Returns a handle to the window above the given window.
 */
Display_GetNextWindow(Hwnd, Cmd) {
    return DllCall('GetNextWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr')
}
Display_GetParent(Hwnd) {
    return DllCall('GetParent', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr')
}
Display_GetShellWindow() {
    return DllCall('GetShellWindow', 'ptr')
}
Display_GetTopWindow(Hwnd := 0) {
    return DllCall('GetTopWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr')
}
/**
 * @param Cmd -
 * - GW_CHILD - 5 - The retrieved handle identifies the child window at the top of the Z order,
 *  if the specified window is a parent window; otherwise, the retrieved handle is NULL. The
 *  function examines only child windows of the specified window. It does not examine descendant
 *  windows.
 *
 * - GW_ENABLEDPOPUP - 6 - The retrieved handle identifies the enabled popup window owned by the
 *  specified window (the search uses the first such window found using GW_HwndNEXT); otherwise,
 *  if there are no enabled popup windows, the retrieved handle is that of the specified window.
 *
 * - GW_HwndFIRST - 0 - The retrieved handle identifies the window of the same type that is highest
 *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndLAST - 1 - The retrieved handle identifies the window of the same type that is lowest
 *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level window.
 *  If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndNEXT - 2 - The retrieved handle identifies the window below the specified window in
 *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndPREV - 3 - The retrieved handle identifies the window above the specified window in
 *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_OWNER - 4 - The retrieved handle identifies the specified window's owner window, if any.
 *  For more information, see Owned Windows.
 */
Display_GetWindow(Hwnd, Cmd) {
    return DllCall('GetWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr')
}
/**
 * @description - Retrieves the dimensions of the bounding rectangle of the specified window.
 * The dimensions are given in screen coordinates that are relative to the upper-left corner of
 * the screen.
 * @param {Integer} Hwnd - The window handle.
 * @returns {Display_Rect}
 */
Display_GetWindowRect(Hwnd) {
    rc := Display_Rect()
    if !DllCall('GetWindowRect', 'ptr', Hwnd, 'ptr', rc, 'int') {
        throw OSError()
    }
    return rc
}
Display_IsChild(HwndParent, HwndChild) {
    return DllCall('IsChild', 'ptr', IsObject(HwndParent) ? HwndParent.Hwnd : HwndParent, 'ptr', IsObject(HwndChild) ? HwndChild.Hwnd : HwndChild, 'int')
}
Display_IsVisible(Hwnd) {
    return DllCall('IsWindowVisible', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}
Display_LargestRectanglePreservingAspectRatio(W1, H1, &W2, &H2) {
    AspectRatio := W1 / H1
    WidthFromHeight := H2 / AspectRatio
    HeightFromWidth := W2 * AspectRatio
    if WidthFromHeight > W2 {
        W2 := W2
        H2 := HeightFromWidth
    } else {
        W2 := WidthFromHeight
        H2 := H2
    }
}
/**
 * @param code -
 * - 1 : Disables calls to SetForegroundWindow
 * - 2 : Enables calls to SetForegroundWindow
 */
Display_LockSetForegroundWindow(code) {
    return DllCall('LockSetForegroundWindow', 'uint', code, 'int')
}
/**
 * @description - Calculates the optimal position to move one rectangle adjacent to another while
 * ensuring that the `Subject` rectangle stays within the monitor's work area. The properties
 * { L, T, R, B } of `Subject` are updated with the new values.
 *
 * @param {*} Subject - The object representing the rectangle that will be moved. This can be an
 * instance of {@link Display_Rect} or any class that inherits from {@link Display_Rect}, or any object with properties
 * { L, T, R, B }. Those four property values will be updated with the result of this function call.
 *
 * @param {*} [Target] - The object representing the rectangle that will be used as reference. This
 * can be an instance of {@link Display_Rect} or any class that inherits from {@link Display_Rect}, or any object with properties
 * { L, T, R, B }. If unset, the mouse's current position relative to the screen is used. To use
 * a point instead of a rectangle, set the properties "L" and "R" equivalent to one another, and
 * "T" and "B" equivalent to one another.
 *
 * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
 * the area that the window is permitted to be moved within. The object must have poperties
 * { L, T, R, B } to be valid. If unset, the work area of the monitor with the greatest area of
 * intersection with `Target` is used.
 *
 * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the window is to be moved
 * adjacent to `Target` on either the X or Y axis. If "X", `Subject` is moved to the left or right
 * of `Target`, and `Subject`'s vertical center is aligned with `Target`'s vertical center. If "Y",
 * `Subject` is moved to the top or bottom of `Target`, and `Subject`'s horizontal center is aligned
 * with `Target`'s horizontal center.
 *
 * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
 * empty string, the function will move the window to the side the has the greatest amount of
 * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
 * the window will be moved to that side unless doing so would cause the the window to extend
 * outside of the monitor's work area.
 * - "L" - Prefers the left side.
 * - "T" - Prefers the top side.
 * - "R" - Prefers the right side.
 * - "B" - Prefes the bottom.
 *
 * @param {Number} [Padding = 0] - The amount of padding to leave between `Subject` and `Target`.
 *
 * @param {Integer} [InsufficientSpaceAction = 0] - Determines the action taken if there is
 * insufficient space to move the window adjacent to `Target` while also keeping the window
 * entirely within the monitor's work area. The function will always sacrifice some of the padding
 * if it will allow the window to stay within the monitor's work area. If the space is still
 * insufficient, the action can be one of the following:
 * - 0 : The function will not move the window.
 * - 1 : The function will move the window, allowing the window's area to extend into a non-visible
 *   region of the monitor.
 * - 2 : The function will move the window, keeping the window's area within the monitor's work
 *   area by allowing the window to overlap with `Target`.
 *
 * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
 */
Display_MoveAdjacent(Subject, Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
    Result := 0
    if IsSet(Target) {
        tarL := Target.L
        tarT := Target.T
        tarR := Target.R
        tarB := Target.B
    } else {
        mode := CoordMode('Mouse', 'Screen')
        MouseGetPos(&tarL, &tarT)
        tarR := tarL
        tarB := tarT
        CoordMode('Mouse', mode)
    }
    tarW := tarR - tarL
    tarH := tarB - tarT
    if IsSet(ContainerRect) {
        monL := ContainerRect.L
        monT := ContainerRect.T
        monR := ContainerRect.R
        monB := ContainerRect.B
        monW := monR - monL
        monH := monB - monT
    } else {
        buf := Buffer(16)
        NumPut('int', tarL, 'int', tarT, 'int', tarR, 'int', tarB, buf)
        Hmon := DllCall('MonitorFromRect', 'ptr', buf, 'uint', 0x00000002, 'ptr')
        mon := Buffer(40)
        NumPut('int', 40, mon)
        if !DllCall('GetMonitorInfo', 'ptr', Hmon, 'ptr', mon, 'int') {
            throw OSError()
        }
        monL := NumGet(mon, 20, 'int')
        monT := NumGet(mon, 24, 'int')
        monR := NumGet(mon, 28, 'int')
        monB := NumGet(mon, 32, 'int')
        monW := monR - monL
        monH := monB - monT
    }
    subL := Subject.L
    subT := Subject.T
    subR := Subject.R
    subB := Subject.B
    subW := subR - subL
    subH := subB - subT
    if Dimension = 'X' {
        if Prefer = 'L' {
            if tarL - subW - Padding >= monL {
                X := tarL - subW - Padding
            } else if tarL - subW >= monL {
                X := monL
            }
        } else if Prefer = 'R' {
            if tarR + subW + Padding <= monR {
                X := tarR + Padding
            } else if tarR + subW <= monR {
                X := monR - subW
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(X) {
            flag_nomove := false
            X := _Proc(subW, subL, subR, tarW, tarL, tarR, monW, monL, monR, Prefer = 'L' ? 1 : Prefer = 'R' ? -1 : 0)
            if flag_nomove {
                return Result
            }
        }
        Y := tarT + tarH / 2 - subH / 2
        if Y + subH > monB {
            Y := monB - subH
        } else if Y < monT {
            Y := monT
        }
    } else if Dimension = 'Y' {
        if Prefer = 'T' {
            if tarT - subH - Padding >= monT {
                Y := tarT - subH - Padding
            } else if tarT - subH >= monT {
                Y := monT
            }
        } else if Prefer = 'B' {
            if tarB + subH + Padding <= monB {
                Y := tarB + Padding
            } else if tarB + subH <= monB {
                Y := monB - subH
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(Y) {
            flag_nomove := false
            Y := _Proc(subH, subT, subB, tarH, tarT, tarB, monH, monT, monB, Prefer = 'T' ? 1 : Prefer = 'B' ? -1 : 0)
            if flag_nomove {
                return Result
            }
        }
        X := tarL + tarW / 2 - subW / 2
        if X + subW > monR {
            X := monR - subW
        } else if X < monL {
            X := monL
        }
    } else {
        throw _ValueError('Dimension', Dimension)
    }
    Subject.L := X
    Subject.T := Y
    Subject.R := X + subW
    Subject.B := Y + subH

    return Result

    _Proc(SubLen, SubMainSide, SubAltSide, TarLen, TarMainSide, TarAltSide, MonLen, MonMainSide, MonAltSide, Prefer) {
        if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
            if TarMainSide - SubLen - Padding >= MonMainSide {
                return TarMainSide - SubLen - Padding
            } else if TarMainSide - SubLen >= MonMainSide {
                return MonMainSide + TarMainSide - SubLen
            } else {
                Result := 1
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarMainSide - SubLen
                    case 2: return MonMainSide
                    default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                }
            }
        } else if TarAltSide + SubLen + Padding <= MonAltSide {
            return TarAltSide + Padding
        } else if TarAltSide + SubLen <= MonAltSide {
            return MonAltSide - TarAltSide + SubLen
        } else {
            Result := 1
            switch InsufficientSpaceAction, 0 {
                case 0: flag_nomove := true
                case 1: return TarAltSide
                case 2: return MonAltSide - SubLen
                default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
            }
        }
    }
    _ValueError(name, Value) {
        if IsObject(Value) {
            return TypeError('Invalid type passed to ``' name '``.', -2)
        } else {
            return ValueError('Unexpected value passed to ``' name '``.', -2, Value)
        }
    }
}
/**
 * @description - A function for getting a new position for a window as a function of the mouse's
 * current position. This function restricts the window's new position to being within the
 * visible area of the monitor. Using the default value for `UseWorkArea`, this also accounts
 * for the taskbar and other docked windows. `OffsetMouse` and `OffsetEdgeOfMonitor` provide
 * some control over the new position relative to the mouse pointer or the edge of the monitor.
 * Use this when moving something on-screen next to the mouse pointer.
 * @param {Integer} Hwnd - The handle to the window.
 * @param {Integer} [PaddingX = 5] - Any number of pixels to pad between the mouse cursor's position
 * and the window along the X axis.
 * @param {Integer} [PaddingY = 5] - Any number of pixels to pad between the mouse cursor's position
 * and the window along the Y axis.
 * @param {VarRef} [OutX] - A variable that will receive the new X coordinate.
 * @param {VarRef} [OutY] - A variable that will receive the new Y coordinate.
 * @param {Boolean} [CalculateOnly = false] - If true, the window will not be moved.
 */
Display_MoveByMouse(Hwnd, PaddingX := 5, PaddingY := 5, &OutX?, &OutY?, CalculateOnly := false) {
    Mon := dMon(dMon.FromMouse(&X, &Y))
    WinGetPos(&wx, &wy, &ww, &wh, Hwnd)
    if !DllCall('MoveWindow', 'ptr', Hwnd, 'int', OutX := _GetX(), 'int', OutY := _GetY(), 'int', ww, 'int', wh, 'int') {
        throw OSError()
    }
    ; WinMove(OutX := _GetX(), OutY := _GetY(), , Hwnd)

    return

    _GetX() {
        if X + ww + PaddingX <= Mon.RW {
            return X + PaddingX
        } else if X - ww - PaddingX >= Mon.LW {
            return X - ww - PaddingX
        } else {
            return 100
        }
    }
    _GetY() {
        if Y + wh + PaddingY <= Mon.BW {
            return Y + PaddingY
        } else if Y - wh - PaddingY >= Mon.TW {
            return Y - wh - PaddingY
        } else {
            return 100
        }
    }
}
/**
 * @description - Moves the window, scaling for dpi.
 * @param {Integer} Hwnd - The handle of the window.
 * @param {Integer} [X] - The new x-coordinate of the window.
 * @param {Integer} [Y] - The new y-coordinate of the window.
 * @param {Integer} [W] - The new Width of the window.
 * @param {Integer} [H] - The new Height of the window.
 */
Display_MoveScaled(Hwnd, X?, Y?, W?, H?) {
    OriginalDpi := DllCall('GetDpiForWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
    NewDpi := IsSet(X) || IsSet(Y) ? dMon.Dpi.Pt(X, Y) : OriginalDpi
    if !NewDpi {
        NewDpi := dMon.Dpi.Pt(X * 96 / A_ScreenDpi, Y * 96 / A_ScreenDpi)
    }
    DpiRatio := NewDpi / OriginalDpi
    WinMove(
        IsSet(X) ? X / DpiRatio : unset
      , IsSet(Y) ? Y / DpiRatio : unset
      , IsSet(W) ? W / DpiRatio : unset
      , IsSet(H) ? H / DpiRatio : unset
      , Hwnd
    )
}
/**
 * @description - Uses RegEx to extract the path from a Window's title.
 * @param {String} Hwnd - The handle to the window.
 * @returns {RegExMatchInfo} - If found, returns the `RegExMatchInfo` object obtained from
 * the match. The object has the subcapture groups available:
 * - drive: The drive letter, if present.
 * - dir: The directory path starting from the drive letter.
 * - name: The file name.
 * - ext: The file extension.
 * If not found, returns an empty string.
 * @example
 *  G := Gui(, 'C:\Users\YourName\Documents\AutoHotkey\lib\Win.ahk')
 *  TitleMatch := dWin.PathFromTitle(G.Hwnd)
 *  MsgBox(TitleMatch.drive) ; C
 *  MsgBox(TitleMatch.dir) ; C:\Users\YourName\Documents\AutoHotkey\lib
 *  MsgBox(TitleMatch.file) ; Win
 *  MsgBox(TitleMatch.ext) ; ahk
 * @
 */
Display_PathFromTitle(Hwnd) {
    if RegExMatch(WinGetTitle(Hwnd)
    , '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+)\b'
    , &Match) {
        return Match
    }
}
Display_PhysicalToLogicalPoint(Hwnd, X, Y) {
    return DllCall('PhysicalToLogicalPoint', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr', Display_Point(X, Y), 'ptr')
}
Display_RealChildWindowFromPoint(Hwnd, X, Y) {
    return DllCall('RealChildWindowFromPoint', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
Display_SetActiveWindow(Hwnd) {
    return DllCall('SetActiveWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}
Display_SetForegroundWindow(Hwnd) {
    return DllCall('SetForegroundWindow', 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'int')
}
/**
 * @param {Integer} Hwnd - The handle to the window that will be modified.
 * @param {Integer} HwndNewParent - The handle to the window that will be set as the parent.
 * @returns {Integer} - The handle to the previous parent window.
 */
Display_SetParent(HwndChild, HwndNewParent := 0) {
    return DllCall('SetParent', 'ptr', IsObject(HwndChild) ? HwndChild.Hwnd : HwndChild, 'ptr', IsObject(HwndNewParent) ? HwndNewParent.Hwnd : HwndNewParent, 'ptr')
}
Display_Show(Hwnd, nCmdShow) {
    return DllCall('ShowWindow', 'ptr', Hwnd, 'int', nCmdShow)
}
/**
 * @description - Compares the center axes of a window with the center axes of the display
 * monitor to determine which quadrant the window occupies most.
 * @param {Integer} Hwnd - The handle of the window.
 * @param {VarRef} [OutDiffHorizontal] - Receives the difference between the window's horizontal
 * axis and the monitor's horizontal axis.
 * @param {VarRef} [OutDiffVertical] - Receives the difference between the window's vertical
 * axis and the monitor's vertical axis.
 * @returns {Integer} - One of the following:
 * - 1: Center left
 * - 2: Left top
 * - 3: Center top
 * - 4: Right top
 * - 5: Center right
 * - 6: Right bottom
 * - 7: Center bottom
 * - 8: Left bottom
 */
Display_WhichQuadrant(Hwnd, &OutDiffHorizontal?, &OutDiffVertical?) {
    Unit := dMon.FromWin(Hwnd)
    if !Unit
        return
    WinGetPos(&wx, &wy, &ww, &wh, Hwnd)
    OutDiffHorizontal := (ww / 2 + wx) - (Unit.L + Unit.W / 2)
    OutDiffVertical := (wh / 2 + wy) - (Unit.T + Unit.H / 2)
    if OutDiffHorizontal < 0 {
        if OutDiffVertical < 0
            return 2 ; Left top
        if OutDiffVertical == 0
            return 1 ; Center left
        return 8 ; Left bottom
    }
    if OutDiffHorizontal == 0 {
        if OutDiffVertical < 0
            return 3 ; Center top
        if OutDiffVertical == 0
            return 0 ; Center
        return 7 ; Center bottom
    }
    if OutDiffHorizontal > 0 {
        if OutDiffVertical < 0
            return 4 ; Right top
        if OutDiffVertical == 0
            return 5 ; Center right
        return 6 ; Right bottom
    }
}
