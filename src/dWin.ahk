
; Dependencies
#include ..\lib
#include SetThreadDpiAwareness__Call.ahk

#include ..\struct
#include Rect.ahk
#include RectBase.ahk
#include POINT.ahk

#include ..\src\dMon.ahk

/**
 * @class
 * @description - Win is a namespace for functions that interact with windows.
 */
class dWin extends RectBase {

    static GetDpi(hWnd) => DllCall('GetDpiForWindow', 'ptr', hWnd, 'int')


    /**
     * @description - Calls `BeginDeferWindowPos`, which is used to prepare for adjusting the
     * dimensions of multiple windowss at once. This reduces flickering and increases
     * performance. After calling this function, fill the structure by calling `dWin.DeferWindowPos`.
     * All windows must have the same parent window.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-begindeferwindowpos}
     * @param {Integer} [InitialCount=2] - An estimate of the number of windows that will be
     * adjusted. The count will be adjusted automatically when calling `DeferWindowPos`, so it's
     * okay if this is not exact.
     * @return {Integer} - Returns a handle to the `hWinPosInfo` structure if successful, else 0.
     */
    static BeginDeferWindowPos(InitialCount := 2) {
        return DllCall('BeginDeferWindowPos', 'int', InitialCount, 'ptr')
    }

    /**
     * @description - Calls `DeferWindowPos`, which is used to prepare a window for being adjusted
     * when `EndDeferWindowPos` is called.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-deferwindowpos}
     * @param {Integer} hWinPosInfo - The handle to the `hWinPosInfo` structure created by
     * `BeginDeferWindowPos`.
     * @param {Integer} hWnd - The handle of the window to adjust.
     * @param {Integer} X - The new x-coordinate of the window.
     * @param {Integer} Y - The new y-coordinate of the window.
     * @param {Integer} W - The new Width of the window.
     * @param {Integer} Y - The new Height of the window.
     * @param {Integer} [uFlags=0] - A set of flags that control the window adjustment. The most
     * common flag is `SWP_NOZORDER` (0x0004), which prevents the window from being reordered. See
     * the link for the table of values.
     * @param {Integer} [hWndInsertAfter=0] - A handle to the window to precede the positioned
     * window in the Z-order, or one of the values listed on the linked webpage.
     * @return {Integer} - Returns the handle the the structure. It is important to use this return
     * value for the next call to `DeferWindowPos` or `EndDeferWindowPos` because the handle may
     * have changed.
     */
    static DeferWindowPos(hWinPosInfo, hWnd, X, Y, W, H, uFlags := 0, hWndInsertAfter := 0) {
        return DllCall('DeferWindowPos', 'ptr', hWinPosInfo, 'ptr', hWnd, 'ptr', hWndInsertAfter
        , 'int', X, 'int', Y, 'int', W, 'int', H, 'uint', uFlags, 'ptr')
    }

    /**
     * @description - Calls `EndDeferWindowPos`. Use this after setting the DWP struct.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enddeferwindowpos}
     * @param {Integer} hDwp - The handle to the `hWinPosInfo` structure.
     * @return {Boolean} - 1 if successful, 0 if unsuccessful.
     */
    static EndDeferWindowPos(hDwp) {
        return DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr')
    }


    static ToRect(hWnd) => Rect.FromWin(hWnd)



    ;@region Move
    /**
     * @description - Sets the Dpi awareness context, then moves the window.
     * @param {Integer} hWnd - The handle of the window.
     * @param {Integer} [X] - The new x-coordinate of the window.
     * @param {Integer} [Y] - The new y-coordinate of the window.
     * @param {Integer} [W] - The new Width of the window.
     * @param {Integer} [H] - The new Height of the window.
     * @param {integer} [DPI_AWARENESS_CONTEXT=-4] - The Dpi_CONTEXT_AWARENESS value to toggle before the
     * position calculation.
     */
    static Move(hWnd, X?, Y?, W?, H?, DPI_AWARENESS_CONTEXT := DPI_AWARENESS_CONTEXT_DEFAULT ?? -4) {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
        WinMove(
            IsSet(X) ? X : unset
          , IsSet(Y) ? Y : unset
          , IsSet(W) ? W : unset
          , IsSet(H) ? H : unset
          , hWnd
        )
    }

    /**
     * @description - Moves the window, scaling for dpi.
     * @param {Integer} hWnd - The handle of the window.
     * @param {Integer} [X] - The new x-coordinate of the window.
     * @param {Integer} [Y] - The new y-coordinate of the window.
     * @param {Integer} [W] - The new Width of the window.
     * @param {Integer} [H] - The new Height of the window.
     */
    static MoveScaled(hWnd, X?, Y?, W?, H?) {
        OriginalDpi := DllCall('GetDpiForWindow', 'ptr', hWnd, 'int')
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
          , hWnd
        )
    }
    ;@endregion



    ;@region WhichQuadrant
    /**
     * @description - Compares the center axes of a window with the center axes of the display
     * monitor to determine which quadrant the window occupies most.
     * @param {Integer} hWnd - The handle of the window.
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
    static WhichQuadrant(hWnd, &OutDiffHorizontal?, &OutDiffVertical?) {
        Unit := dMon.FromWin(hWnd)
        if !Unit
            return
        WinGetPos(&wx, &wy, &ww, &wh, hWnd)
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



    ;@region MoveByWinH
    /**
     * @description - Moves a window to a new position relative to another window. If the target
     * window is on the Left side of the display, the moved window will be placed to the Right of
     * the target, and vice-versa.
     * @param {Integer} TargethWnd - The handle of the target window.
     * @param {Integer} MovehWnd - The handle of the window to move.
     * @param {Integer} [Padding=3] - The padding (in pixels) between the target window and the moved
     * window.
     * @param {String} [UseWorkArea=true] - Whether to use the work area or the display area.
     * @param {Boolean} [AdjustTarget=true] - Whether to adjust the target window if the moved window
     * would be placed outside the monitor.
     * @param {Boolean} [OverrideSizeLimit=false] - Whether to override the size limit of the display
     * area. See the `Return` description for more information.
     * @returns {Boolean} - Returns 0 if the window is moved successfully. If the sum of the
     * Width of both windows and the padding value is greater than the total Width of the
     * display area, the function returns 1 and the window is not moved. You can override this
     * restriction by passing true to `OverrideSizeLimit`. The function will still return 1 if the
     * size limit is exceeded, but the window will be moved.
     */
    static MoveByWinH(TargethWnd, MovehWnd, Padding := 3, UseWorkArea := true, AdjustTarget := true
    , OverrideSizeLimit := false) {
        Unit := UseWorkArea ? dMon.Get.WinW(TargethWnd) : dMon.Get.WinD(TargethWnd)
        Quadrant := this.WhichQuadrant(TargethWnd)
        WinGetPos(&tx, &ty, &tw, &th, TargethWnd)
        WinGetPos(&mx, &my, &mw, &mh, MovehWnd)
        if tw + mw + Padding > Unit.Width {
            if !OverrideSizeLimit
                return 1
            Result := 1
        } else
            Result := 0
        tCenterY := ty + th / 2
        mCenterY := my + mh / 2
        YOffset := mCenterY - tCenterY
        if my - YOffset < Unit.Top {
            if AdjustTarget {
                YDiff := Unit.Top - (my - YOffset)
                WinMove(, ty + YDiff, , , TargethWnd)
                YOffset -= YDiff
            } else
                YOffset := my - Unit.Top
        } else if my + mh - YOffset > Unit.Bottom {
            if AdjustTarget {
                YDiff := Unit.Bottom - my - mh + YOffset
                WinMove(, ty + YDiff, , , TargethWnd)
                YOffset -= YDiff
            } else
                YOffset := mh + my - Unit.Bottom
        }
        if InStr(Quadrant, 'R')
            WinMove(tx - mw - Padding, my - YOffset, , , MovehWnd)
        else
            WinMove(tx + tw + Padding, my - YOffset, , , MovehWnd)
        return Result
    }
    ;@endregion




    ;@region MoveByWinV
    /**
     * @description - Moves a window to a new position relative to another window. If the target
     * window is on the Top side of the display, the moved window will be placed below the target,
     * and vice-versa.
     * @param {Integer} TargethWnd - The handle of the target window.
     * @param {Integer} MovehWnd - The handle of the window to move.
     * @param {Integer} [Padding=3] - The padding (in pixels) between the target window and the moved
     * window.
     * @param {String} [UseWorkArea=true] - Whether to use the work area or the display area.
     * @param {Boolean} [AdjustTarget=true] - Whether to adjust the target window if the moved window
     * would be placed outside the monitor.
     * @param {Boolean} [OverrideSizeLimit=false] - Whether to override the size limit of the display
     * area. See the `Return` description for more information.
     * @returns {Boolean} - Returns 0 if the window is moved successfully. If the sum of the
     * Height of both windows and the padding value is greater than the total Height of the
     * display area, the function returns 1 and the window is not moved. You can override this
     * restriction by passing true to `OverrideSizeLimit`. The function will still return 1 if the
     * size limit is exceeded, but the window will be moved.
     */
    static MoveByWinV(TargethWnd, MovehWnd, Padding := 3, UseWorkArea := true, AdjustTarget := true
    , OverrideSizeLimit := false) {
        Unit := UseWorkArea ? dMon.Get.WinW(TargethWnd) : dMon.Get.WinD(TargethWnd)
        Quadrant := this.WhichQuadrant(TargethWnd)
        WinGetPos(&tx, &ty, &tw, &th, TargethWnd)
        WinGetPos(&mx, &my, &mw, &mh, MovehWnd)
        if th + mh + Padding > Unit.Height {
            if !OverrideSizeLimit
                return 1
            Result := 1
        } else
            Result := 0
        tCenterX := tx + tw / 2
        mCenterX := mx + mw / 2
        XOffset := mCenterX - tCenterX
        if mx - XOffset < Unit.Left {
            if AdjustTarget {
                XDiff := Unit.Left - (mx - XOffset)
                WinMove(tx + XDiff, , , , TargethWnd)
                XOffset -= XDiff
            } else
                XOffset := mx - Unit.Left
        } else if mx + mw - XOffset > Unit.Right {
            if AdjustTarget {
                XDiff := Unit.Right - mx - mw + XOffset
                WinMove(tx + XDiff, , , , TargethWnd)
                XOffset -= XDiff
            } else
                XOffset := mw + mx - Unit.Right
        }
        if InStr(Quadrant, 'B')
            WinMove(mx - XOffset, ty - mh - Padding, , , MovehWnd)
        else
            WinMove(mx - XOffset, ty + th + Padding, , , MovehWnd)
        return Result
    }
    ;@endregion




    ;@region MoveByMouse
    /**
     * @description - A function for getting a new position for a window as a function of the mouse's
     * current position. This function restricts the window's new position to being within the
     * visible area of the monitor. Using the default value for `UseWorkArea`, this also accounts
     * for the taskbar and other docked windows. `OffsetMouse` and `OffsetEdgeOfMonitor` provide
     * some control over the new position relative to the mouse pointer or the edge of the monitor.
     * Use this when moving something on-screen next to the mouse pointer.
     * @param {Integer} hWnd - The handle to the window.
     * @param {Integer} [PaddingX=5] - Any number of pixels to pad between the mouse cursor's position
     * and the window along the X axis.
     * @param {Integer} [PaddingY=5] - Any number of pixels to pad between the mouse cursor's position
     * and the window along the Y axis.
     * @param {VarRef} [OutX] - A variable that will receive the new X coordinate.
     * @param {VarRef} [OutY] - A variable that will receive the new Y coordinate.
     * @param {Boolean} [CalculateOnly = false] - If true, the window will not be moved.
     */
    static MoveByMouse(hWnd, PaddingX := 5, PaddingY := 5, &OutX?, &OutY?, CalculateOnly := false) {
        Mon := dMon(dMon.FromMouse(&X, &Y))
        WinGetPos(&wx, &wy, &ww, &wh, hWnd)
        if !DllCall('MoveWindow', 'ptr', hWnd, 'int', OutX := _GetX(), 'int', OutY := _GetY(), 'int', ww, 'int', wh, 'int') {
            throw OSError()
        }
        ; WinMove(OutX := _GetX(), OutY := _GetY(), , hWnd)

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
    ;@endregion

    ;@region ScalePreserveAspectRatio
    /** ### Description - Monitor.dWin.ScalePreserveAspectRatio()
     * This function requires any two either an hWnd or a pseudo-`Rect` object
     * (object with 'Left,Top,Right,Bottom' properties). It identifies the largest
     * rectangle that can fit inside of the target  's area while also presering the
     * subject's aspect ration.
     * @param {Integer|Object} subject - the handle of the subject window or an object with
     * 'Left,Top,Right,Bottom' properties
     * @param {Integer|Object} target - the handle of the target window or an object with
     * 'Left,Top,Right,Bottom' properties
     * @returns {Map} - a map object with the new Width and Height as `Map('w', <new Width>, 'h', <new Height>)`
     */
    static ScalePreserveAspectRatio(subject, target) {
        if IsNumber(subject)
            WinGetPos(,,&w1,&h1, subject)
        else if IsObject(subject)
            w1 := subject.Right - subject.Left, h1 := subject.Bottom - subject.Top
        if IsNumber(target)
            WinGetPos(&x2,&y2,&w2,&h2, target)
        else if IsObject(target)
            w2 := target.Right - target.Left, h2 := target.Bottom - target.Top
        ar := h1/w1
        WidthFromHeight := h2 / ar, HeightFromWidth := w2 * ar
        if WidthFromHeight > w2
            return Map('w', w2, 'h', HeightFromWidth)
        else
            return Map('w', WidthFromHeight, 'h', h2)
    }
    ;@endregion

    ;@region Snap
    static Snap(hWnd, Hmon, style, position) {
        position.DefineProp('__Get', {Call:((*)=>'')})
        unitCurrent := dMon.FromWin(hWnd)
        unitTarget := dMon.Get(Hmon)
        DpiRatio := unitCurrent['Dpi']['x'] / unitTarget['Dpi']['x']
        WinGetPos(&wX, &wY, &wW, &wH, hWnd)

        if DpiRatio = 1 {
            switch style, 0 {
                case 'full':
                    WinMove(unitTarget['Work']['Left'], unitTarget['Work']['Top'], unitTarget['Work']['Width'], unitTarget['Work']['Height'], hWnd)
                case 'SplitV':
                    unitTarget.SplitV(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(unitTarget['Left'], item['Top'], unitTarget['Width'], item['Bottom']-item['Top'], hWnd)
                case 'SplitH':
                    unitTarget.SplitH(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(item['Left'], unitTarget['Top'], item['Right']-item['Left'], unitTarget['Height'], hWnd)
                case 'quarter':
                    Result := unitTarget.GetQuandrants(position.item, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : Unset, position.HasOwnProp('cacheRefrash') ? position.cacheRefrash : Unset)
                    WinMove(Result['Left'], Result['Top'], Result['Width'], Result['Height'], hWnd)
                default:
                    dMon.dWin.InvokeSavedPosition(hWnd, style)
            }
        } else if DpiRatio != 1 {
            switch style, 0 {
                case 'full':
                    WinMove(unitTarget['Work']['Left'], unitTarget['Work']['Top'], unitTarget['Work']['Width'], unitTarget['Work']['Height'], hWnd)
                case 'SplitV':
                    unitTarget.SplitV(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(unitTarget['Left'], item['Top'], unitTarget['Width'], item['Bottom']-item['Top'], hWnd)
                case 'SplitH':
                    unitTarget.SplitH(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(item['Left'], unitTarget['Top'], item['Right']-item['Left'], unitTarget['Height'], hWnd)
                case 'quarter':
                    Result := unitTarget.GetQuandrants(position.item, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : Unset, position.HasOwnProp('cacheRefrash') ? position.cacheRefrash : Unset)
                    WinMove(Result['Left'], Result['Top'], Result['Width'], Result['Height'], hWnd)
                default:
                    dMon.dWin.InvokeSavedPosition(hWnd, style)
            }
        }

    }
    ;@endregion

    static IsVisible(hWnd) {
        return DllCall('IsWindowVisible', 'Ptr', hWnd, 'int')
    }

    /**
     * @description - Gets the bounding rectangle of all child windows of a given window.
     * @param {Integer} hWnd - The handle to the parent window.
     * @returns {Rect} - The bounding rectangle of all child windows, specifically the smallest
     * rectangle that contains all child windows.
     */
    static GetChildrenBoundingRect(hWnd) {
        rects := [Rect(0, 0, 0, 0), Rect(0, 0, 0, 0), Rect()]
        DllCall('EnumChildWindows', 'ptr', hWnd, 'ptr', cb := CallbackCreate(_EnumChildWindowsProc, 'fast',  1), 'int', 0, 'int')
        CallbackFree(cb)
        return rects[1]

        _EnumChildWindowsProc(hWnd) {
            DllCall('GetWindowRect', 'ptr', hWnd, 'ptr', rects[1], 'int')
            DllCall('UnionRect', 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
            rects.Push(rects.RemoveAt(1))
            return 1
        }
    }

    ;@region PathFromTitle
    /**
     * @description - Uses RegEx to extract the path from a Window's title.
     * @param {String} hWnd - The handle to the window.
     * @returns {RegExMatchInfo} - If found, returns the `RegExMatchInfo` object obtained from
     * the match. The object has the subcapture groups available:
     * - drive: The drive letter, if present.
     * - dir: The directory path starting from the drive letter.
     * - name: The file name.
     * - ext: The file extension.
     * If not found, returns an empty string.
     * @example
     *  G := Gui(, 'C:\Users\YourName\Documents\AutoHotkey\lib\Win.ahk')
     *  TitleMatch := dWin.PathFromTitle(G.hWnd)
     *  MsgBox(TitleMatch.drive) ; C
     *  MsgBox(TitleMatch.dir) ; C:\Users\YourName\Documents\AutoHotkey\lib
     *  MsgBox(TitleMatch.file) ; Win
     *  MsgBox(TitleMatch.ext) ; ahk
     * @
     */
    static PathFromTitle(hWnd) {
        if RegExMatch(WinGetTitle(hWnd)
        , '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+)\b'
        , &Match) {
            return Match
        }
    }
    ;@endregion

    static AdjustWindowRectExForDpi(lpRect, dwStyle := 0, bMenu := 0, dwExStyle := 0) {
        return DllCall('AdjustWindowRectExForDpi', 'ptr', lpRect, 'int', dwStyle, 'int', bMenu, 'int', dwExStyle, 'int', dMon.Dpi.Rect(lpRect))
    }

    static FromPoint(X, Y) {
        return DllCall('WindowFromPoint', 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    }

    static FromPhysicalPoint(X, Y) {
        return DllCall('WindowFromPhysicalPoint', 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    }

    static PhysicalToLogicalPoint(hWnd, X, Y) {
        return DllCall('PhysicalToLogicalPoint', 'ptr', hWnd, 'ptr', Point(X, y), 'ptr')
    }

    static Show(hWnd, nCmdShow) {
        return DllCall('ShowWindow', 'ptr', hWnd, 'int', nCmdShow)
    }

    static AdjustWindowRectEx(lpRect, dwStyle := 0, bMenu := 0, dwExStyle := 0) {
        return DllCall('AdjustWindowRectEx', 'ptr', lpRect, 'uint', dwStyle, 'int', bMenu, 'uint', dwExStyle)
    }

    static GetClientRect(hWnd, &lpRect) {
        return DllCall('GetClientRect', 'ptr', hWnd, 'ptr', lpRect := Rect(), 'int')
    }

    static RealChildWindowFromPoint(hWnd, X, Y) {
        return DllCall('RealChildWindowFromPoint', 'ptr', hWnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    }

    static ChildWindowFromPoint(hWnd, X, Y) {
        return DllCall('ChildWindowFromPoint', 'ptr', hWnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    }

    static ChildWindowFromPointEx(hWnd, X, Y, flags := 0) {
        return DllCall('ChildWindowFromPointEx', 'ptr', hWnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', flags, 'ptr')
    }

    /**
     * @description - Retrieves the dimensions of the bounding rectangle of the specified window.
     * The dimensions are given in screen coordinates that are relative to the upper-left corner of
     * the screen.
     * @param {Integer} hWnd - The window handle.
     * @returns {Rect}
     */
    static GetWindowRect(hWnd) {
        rc := Rect()
        if !DllCall('GetWindowRect', 'ptr', hWnd, 'ptr', rc, 'int') {
            throw OSError()
        }
        return rc
    }

    /**
     * @param {Integer} hWnd - The handle to the window that will be modified.
     * @param {Integer} hWndNewParent - The handle to the window that will be set as the parent.
     * @returns {Integer} - The handle to the previous parent window.
     */
    static SetParent(hWnd, hWndNewParent) {
        return DllCall('SetParent', 'ptr', hWnd, 'ptr', hWndNewParent, 'ptr')
    }

    static LargestRectanglePreservingAspectRatio(W1, H1, &W2, &H2) {
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
}
