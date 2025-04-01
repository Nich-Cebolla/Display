

/**
 * @class
 * @description - Win is a namespace for functions that interact with windows.
 */
class Win extends RectBase {


    /**
     * @description - Calls `BeginDeferWindowPos`, which is used to prepare for adjusting the
     * dimensions of multiple windowss at once. This reduces flickering and increases
     * performance. After calling this function, fill the structure by calling `Win.DeferWindowPos`.
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
     * @param {Integer} Hwnd - The handle of the window to adjust.
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
    static DeferWindowPos(hWinPosInfo, Hwnd, X, Y, W, H, uFlags := 0, hWndInsertAfter := 0) {
        return DllCall('DeferWindowPos', 'ptr', hWinPosInfo, 'ptr', Hwnd, 'ptr', hWndInsertAfter
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


    static ToRect(Hwnd) => Rect.FromWin(Hwnd)



    ;@region Move
    /**
     * @description - Sets the Dpi awareness context, then moves the window.
     * @param {Integer} Hwnd - The handle of the window.
     * @param {Integer} [X] - The new x-coordinate of the window.
     * @param {Integer} [Y] - The new y-coordinate of the window.
     * @param {Integer} [W] - The new Width of the window.
     * @param {Integer} [H] - The new Height of the window.
     * @param {integer} [DPI_AWARENESS_CONTEXT=-4] - The Dpi_CONTEXT_AWARENESS value to toggle before the
     * position calculation.
     */
    static Move(Hwnd, X?, Y?, W?, H?, DPI_AWARENESS_CONTEXT := DPI_AWARENESS_CONTEXT_DEFAULT ?? -4) {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
        WinMove(
            IsSet(X) ? X : unset
          , IsSet(Y) ? Y : unset
          , IsSet(W) ? W : unset
          , IsSet(H) ? H : unset
          , Hwnd
        )
    }

    /**
     * @description - Moves the window, scaling for dpi.
     * @param {Integer} Hwnd - The handle of the window.
     * @param {Integer} [X] - The new x-coordinate of the window.
     * @param {Integer} [Y] - The new y-coordinate of the window.
     * @param {Integer} [W] - The new Width of the window.
     * @param {Integer} [H] - The new Height of the window.
     */
    static MoveScaled(Hwnd, X?, Y?, W?, H?) {
        OriginalDpi := GetDpiForWindow(hWnd)
        NewDpi := IsSet(X) || IsSet(Y) ? Mon.Dpi.Pt(X, Y) : OriginalDpi
        if !NewDpi
            NewDpi := Mon.Dpi.Pt(X * 96 / A_ScreenDpi, Y * 96 / A_ScreenDpi)
        DpiRatio := NewDpi / OriginalDpi
        WinMove(
            IsSet(X) ? X / DpiRatio : unset
          , IsSet(Y) ? Y / DpiRatio : unset
          , IsSet(W) ? W / DpiRatio : unset
          , IsSet(H) ? H / DpiRatio : unset
          , Hwnd
        )
    }
    ;@endregion



    ;@region WhichQuadrant
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
    static WhichQuadrant(Hwnd, &OutDiffHorizontal?, &OutDiffVertical?) {
        Unit := Mon.FromWin(Hwnd)
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



    ;@region MoveByWinH
    /**
     * @description - Moves a window to a new position relative to another window. If the target
     * window is on the Left side of the display, the moved window will be placed to the Right of
     * the target, and vice-versa.
     * @param {Integer} TargetHwnd - The handle of the target window.
     * @param {Integer} MoveHwnd - The handle of the window to move.
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
    static MoveByWinH(TargetHwnd, MoveHwnd, Padding := 3, UseWorkArea := true, AdjustTarget := true
    , OverrideSizeLimit := false) {
        Unit := UseWorkArea ? Mon.Get.WinW(TargetHwnd) : Mon.Get.WinD(TargetHwnd)
        Quadrant := this.WhichQuadrant(TargetHwnd)
        WinGetPos(&tx, &ty, &tw, &th, TargetHwnd)
        WinGetPos(&mx, &my, &mw, &mh, MoveHwnd)
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
                WinMove(, ty + YDiff, , , TargetHwnd)
                YOffset -= YDiff
            } else
                YOffset := my - Unit.Top
        } else if my + mh - YOffset > Unit.Bottom {
            if AdjustTarget {
                YDiff := Unit.Bottom - my - mh + YOffset
                WinMove(, ty + YDiff, , , TargetHwnd)
                YOffset -= YDiff
            } else
                YOffset := mh + my - Unit.Bottom
        }
        if InStr(Quadrant, 'R')
            WinMove(tx - mw - Padding, my - YOffset, , , MoveHwnd)
        else
            WinMove(tx + tw + Padding, my - YOffset, , , MoveHwnd)
        return Result
    }
    ;@endregion




    ;@region MoveByWinV
    /**
     * @description - Moves a window to a new position relative to another window. If the target
     * window is on the Top side of the display, the moved window will be placed below the target,
     * and vice-versa.
     * @param {Integer} TargetHwnd - The handle of the target window.
     * @param {Integer} MoveHwnd - The handle of the window to move.
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
    static MoveByWinV(TargetHwnd, MoveHwnd, Padding := 3, UseWorkArea := true, AdjustTarget := true
    , OverrideSizeLimit := false) {
        Unit := UseWorkArea ? Mon.Get.WinW(TargetHwnd) : Mon.Get.WinD(TargetHwnd)
        Quadrant := this.WhichQuadrant(TargetHwnd)
        WinGetPos(&tx, &ty, &tw, &th, TargetHwnd)
        WinGetPos(&mx, &my, &mw, &mh, MoveHwnd)
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
                WinMove(tx + XDiff, , , , TargetHwnd)
                XOffset -= XDiff
            } else
                XOffset := mx - Unit.Left
        } else if mx + mw - XOffset > Unit.Right {
            if AdjustTarget {
                XDiff := Unit.Right - mx - mw + XOffset
                WinMove(tx + XDiff, , , , TargetHwnd)
                XOffset -= XDiff
            } else
                XOffset := mw + mx - Unit.Right
        }
        if InStr(Quadrant, 'B')
            WinMove(mx - XOffset, ty - mh - Padding, , , MoveHwnd)
        else
            WinMove(mx - XOffset, ty + th + Padding, , , MoveHwnd)
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
     * @param {Integer} Hwnd - The handle to the window.
     * @param {Boolean} [UseWorkArea=true] - Whether to use the work area or the display area.
     * @param {Boolean} [MoveImmediately=true] - Whether to move the window immediately. If false,
     * the function will only return the new position.
     * @param {Object} [OffsetMouse={x:5,y:5}] - The offset from the mouse's current position.
     * @param {Object} [OffsetEdgeOfMonitor={x:50,y:50}] - The offset from the monitor's edge.
     * @param {integer} [DPI_AWARENESS_CONTEXT=-4] - The Dpi_CONTEXT_AWARENESS value to toggle before the
     * position calculation. The value is set to the original after calculation is complete.
     * @param {string} [MouseCoordMode='Screen'] - The `CoordMode('Mouse')` value to toggle before
     * the position calculation. The value is set to the original after calculation is complete.
     * @returns {Object} - An object with properties `X` and `Y` representing the new position of the
     * window.
     */
    static MoveByMouse(Hwnd, &OutX?, &OutY?, Params?) {
        Params := this.Defaults(Params??{}, A_ThisFunc)
        oCoordMode := CoordMode('Mouse', Params.MouseCoordMode)
        WinGetPos(&wX, &wY, &wW, &wH, Number(Hwnd))
        Win.GetPosByMouse(&X, &Y, &mX, &mY, &wW, &wH, Params.OffsetMouse, Params.OffsetEdgeOfMonitor, Mon.FromMouse_U(&mX, &mY))
        if MoveImmediately {
            WinMove(X, Y, , , Number(Hwnd))
        }
        CoordMode('Mouse', oCoordMode)
    }
    ;@endregion




    ;@region ScaleMoveByMouse
    /** ### Description - Monitor.WinMoveByMouse()
     * {@see Monitor.Win.MoveByMouse}
     * This method will scale the window if it moves to a monitor with a different Dpi.
     * @param {Integer} Hwnd - the handle of the window
     * @param {Boolean} [UseWorkArea=true] - whether to use the work area or the display area
     * @param {Boolean} [MoveImmediately=true] - whether to move the window immediately
     * @param {Object} [OffsetMouse={x:5,y:5}] - the offset from the mouse's current position
     * @param {Object} [OffsetEdgeOfMonitor={x:50,y:50}] - the offset from the monitor's edge
     * @param {integer} [DPI_AWARENESS_CONTEXT=-4] - the Dpi_CONTEXT_AWARENESS value to toggle before the
     * position calculation. The value is set to the original after calculation is complete.
     * @param {string} [MouseCoordMode='Screen'] - the `CoordMode('Mouse')` value to toggle before
     * the position calculation. The value is set to the original after calculation is complete.
     * @returns {Map} - a map object with the new x and y coordinates as `Map('x', <new x>, 'y',
     * <new y>)`
     */
    static ScaleMoveByMouse(Hwnd, UseWorkArea := true, MoveImmediately := true
        , OffsetMouse := {x:5,y:5}, OffsetEdgeOfMonitor := {x:50,y:50}
        , MouseCoordMode := 'Screen'
    ) {
        Params := this.Defaults(Params??{}, A_ThisFunc)
        oCoordMode := CoordMode('Mouse', Params.MouseCoordMode)
        WinGetPos(&wX, &wY, &wW, &wH, Number(Hwnd))
        DpiRatio := Mon.Dpi.Win(hWnd) / Mon.Dpi.Mouse()
        newW :=
        newH :=
        Mon.Win._GetPosByMouse(&x, &y, mX, mY, wW / DpiRatio, wH / DpiRatio, OffsetMouse, OffsetEdgeOfMonitor, unitMouse[UseWorkArea ? 'Work' : 'Display'])
        Win.GetPosByMouse(&X, &Y, &mX, &mY, &wW, &wH, Params.OffsetMouse, Params.OffsetEdgeOfMonitor, Mon.FromMouse_U(&mX, &mY))
        if MoveImmediately {
            WinMove(X, Y, , , Number(Hwnd))
        }
        CoordMode('Mouse', oCoordMode)

        params := Map('Dpi'||Unset, 'mouse', MouseCoordMode||Unset)
        oCoordMode := CoordMode('Mouse', MouseCoordMode)
        unitWin := Mon.FromWin(Hwnd), unitMouse := Mon.FromMouse(&mX, &mY)
        WinGetPos(&wX, &wY, &wW, &wH, Number(Hwnd))
        if MoveImmediately
            WinMove(x, y, newW, newH, Hwnd)
        CoordMode('Mouse', oCoordMode)
        return Map('x', x, 'y', y)
    }
    ;@endregion




    ;@region ScalePreserveAspectRatio
    /** ### Description - Monitor.Win.ScalePreserveAspectRatio()
     * This function requires any two either an Hwnd or a pseudo-`Rect` object
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
    static Snap(Hwnd, Hmon, style, position) {
        position.DefineProp('__Get', {Call:((*)=>'')})
        unitCurrent := Mon.FromWin(Hwnd), unitTarget := Mon.Get(Hmon)
        DpiRatio := unitCurrent['Dpi']['x'] / unitTarget['Dpi']['x']
        WinGetPos(&wX, &wY, &wW, &wH, Hwnd)

        if DpiRatio = 1 {
            switch style, 0 {
                case 'full':
                    WinMove(unitTarget['Work']['Left'], unitTarget['Work']['Top'], unitTarget['Work']['Width'], unitTarget['Work']['Height'], Hwnd)
                case 'SplitV':
                    unitTarget.SplitV(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(unitTarget['Left'], item['Top'], unitTarget['Width'], item['Bottom']-item['Top'], Hwnd)
                case 'SplitH':
                    unitTarget.SplitH(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(item['Left'], unitTarget['Top'], item['Right']-item['Left'], unitTarget['Height'], Hwnd)
                case 'quarter':
                    Result := unitTarget.GetQuandrants(position.item, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : Unset, position.HasOwnProp('cacheRefrash') ? position.cacheRefrash : Unset)
                    WinMove(Result['Left'], Result['Top'], Result['Width'], Result['Height'], Hwnd)
                default:
                    Mon.Win.InvokeSavedPosition(Hwnd, style)
            }
        } else if DpiRatio != 1 {
            switch style, 0 {
                case 'full':
                    WinMove(unitTarget['Work']['Left'], unitTarget['Work']['Top'], unitTarget['Work']['Width'], unitTarget['Work']['Height'], Hwnd)
                case 'SplitV':
                    unitTarget.SplitV(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(unitTarget['Left'], item['Top'], unitTarget['Width'], item['Bottom']-item['Top'], Hwnd)
                case 'SplitH':
                    unitTarget.SplitH(Hmon, position.count, &Result, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : true)
                    item := Result[position.offset]
                    WinMove(item['Left'], unitTarget['Top'], item['Right']-item['Left'], unitTarget['Height'], Hwnd)
                case 'quarter':
                    Result := unitTarget.GetQuandrants(position.item, position.HasOwnProp('UseWorkArea') ? position.UseWorkArea : Unset, position.HasOwnProp('cacheRefrash') ? position.cacheRefrash : Unset)
                    WinMove(Result['Left'], Result['Top'], Result['Width'], Result['Height'], Hwnd)
                default:
                    Mon.Win.InvokeSavedPosition(Hwnd, style)
            }
        }

    }
    ;@endregion





    /**
     * @description - Gets the font details of a window or control.
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logfonta}
     * @param {Integer} Hwnd - The handle of the window or control.
     * @param {Integer:VarRef} [OutFontSize] - Receives the font size.
     * @param {String:VarRef} [OutFontFamily] - Receives the font name.
     * @param {Boolean} [ReturnAll=false] - Whether to return all the font details. When true,
     * `GetFontDetails` constructs the Result object and returns it. When false, it only sets the
     * VarRef `Out` variables.
     * @returns {Object|Integer} - If successful and `ReturnAll` is true, returns an object with the
     * properties listed below. If successful and `ReturnAll` is false, returns an empty string.
     * If unsuccessful, returns one of the below error codes.
     * - Properties: { Height, Width, Escapement, Orientation, Weight, Italic, Underline,
     * Strikeout, Charset, OutPrecision, ClipPrecision, Quality, Family, Pitch, FaceName,
     * FontSize }
     * - Error Codes: 1 = Failed to get the font handle. 2 = Failed to get the font object.
     * 3 = Failed to get the Dpi.
     * @example
        G := Gui('-DpiScale +Resize')
        G.SetFont('s11 Q5', 'Consolas')
        txt := G.Add('Text', 'w100 r1', 'Test')
        Result := GetFontDetails(txt.Hwnd, &FontSize, &FontFamily, true)
        MsgBox(Result.FontSize) ; 11
        MsgBox(FontSize) ; 11
        MsgBox(Result.Quality) ; 5
        MsgBox(Result.FaceName) ; Consolas
     * @
     */
    static GetFontDetails(Hwnd, &OutFontSize?, &OutFontFamily?, ReturnAll := false) {
        if !(hFont := SendMessage(0x0031,,, Hwnd)) ; WM_GETFONT
            throw Error('Failed to get hFont.', -1)
        lpvFont := Buffer(92) ; LOGFONTW size
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', 92, 'ptr', lpvFont)
            throw Error('Failed to get LOGFONTW.', -1)
        if !(Dpi := DllCall("User32\GetDpiForWindow", "Ptr", Hwnd, "UInt"))
            throw Error('Failed to get window Dpi.', -1)
        OutFontSize := Round(-NumGet(lpvFont, 0, 'Int') * 72 / Dpi, 0)
        OutFontFamily := StrGet(lpvFont.ptr + 28, 32)
        if ReturnAll {
            _GetNibbles(&Family, &Pitch, NumGet(lpvFont, 27, 'UChar'))
            Result := {
              Height: NumGet(lpvFont, 0, 'Int')
            , Width: NumGet(lpvFont, 4, 'Int')
            , Escapement: NumGet(lpvFont, 8, 'Int')
            , Orientation: NumGet(lpvFont, 12, 'Int')
            , Weight: NumGet(lpvFont, 16, 'Int')
            , Italic: NumGet(lpvFont, 20, 'UChar')
            , Underline: NumGet(lpvFont, 21, 'UChar')
            , Strikeout: NumGet(lpvFont, 22, 'UChar')
            , Charset: NumGet(lpvFont, 23, 'UChar')
            , OutPrecision: NumGet(lpvFont, 24, 'UChar')
            , ClipPrecision: NumGet(lpvFont, 25, 'UChar')
            , Quality: NumGet(lpvFont, 26, 'UChar')
            , Family: Family ; Different usage of "Family" than is used in the AutoHotkey docs.
            , Pitch: Pitch
            , FaceName: OutFontFamily
            , FontSize: OutFontSize
            }
            return Result
        } else {
            return lpvFont
        }

        _GetNibbles(&Lower, &Upper, Input) {
            Lower := Input & 0x0F
            Upper := Input & 0xF0
        }
    }




    /**
     * @description - Gets the dimensions of a string within a given device context.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32a}
     * @param {String} Str - The string for which to get the dimensions.
     * @param {Integer} Hwnd - The handle to a Gui of Gui.Control object, or another window.
     * @param {VarRef} [Width] - A variable that will receive the width of the string.
     * @param {VarRef} [Height] - A variable that will receive the height of the string.
     * @returns {Integer} - One of the following:
     * 0 - Successful.
     * 1 - The function failed to acquire a device context for the input hwnd.
     * 2 - The function failed to select into the device context to get an hFont.
     * 3 - `GetTextExtentPoint32` failed.
     */
    static GetTextExtentPoint32(str, hwnd, &Width?, &Height?) {
        hDC := DllCall('GetDC', 'Ptr', hwnd)
        if !hDc {
            return 1
        }
        hFont := SendMessage(0x0031,,,hwnd)

        ; Select the font into the DC
        if !DllCall("Gdi32\SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr") {
            return 2
        }
        ; Create buffer to store SIZE
        StrPut(str, lpStr := Buffer(StrPut(str, 'utf-16')), StrLen(str), 'utf-16')
        ; Measure the text
        if !DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32', 'Ptr'
            , hDC, 'Ptr', lpStr, 'Int', StrLen(str), 'Ptr', SIZE := Buffer(8)) {
            return 3
        }
        DllCall('ReleaseDC', 'Ptr', hwnd, 'Ptr', hDC)
        Width := NumGet(SIZE, 0, "UINT")
        Height := NumGet(SIZE, 4, "UINT")
    }



    static GetTextExtentExPoint(Str, Hwnd, MaxWidth, &OutCharCount?, &OutLpStr?, &OutSize?) {
        hDC := DllCall('GetDC', 'Ptr', hwnd)
        hFont := SendMessage(0x0031,,,hwnd)
        ; Select the font into the DC
        if !DllCall("Gdi32\SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr") {
            return 2
        }
        StrPut(str, OutLpStr := Buffer(StrPut(Str, 'Utf-16') * 2))
        n := 0
        for Char in StrSplit(Str) {
            n += Ord(Char) > 0xFFFF ? 2 : 1
        }
        NumBuf := Buffer(4)
        OutSize := Buffer(8)
        if Result := DllCall('Gdi32.dll\GetTextExtentExPoint'
            , 'ptr', hDC          ; Device context
            , 'ptr', OutLpStr     ; String buffer
            , 'int', n            ; String length in WORDs
            , 'int', MaxWidth     ; Maximum width
            , 'ptr', NumBuf       ; To receive number of characters that can fit
            , 'ptr', 0            ; An array to receives partial string extents. Here it's null.
            , 'ptr', OutSize      ; To receive the dimensions of the string.
            , 'ptr'
        ) {
            OutCharCount := NumGet(NumBuf, 0, 'int')
            return 1
        }
    }


    static CalcTextRect(Str, Hwnd, WidthLimit?) {
        hDC := DllCall('GetDC', 'ptr', Hwnd, 'ptr')
        hFont := SendMessage(0x31, , , Hwnd)  ; WM_GETFONT
        oldFont := DllCall('SelectObject', 'ptr', hDC, 'ptr', hFont, 'ptr')

        rc := Buffer(16, 0)  ; RECT = 4x INT (left, top, right, bottom)

        if IsSet(WidthLimit)
            NumPut('int', 0, 'int', 0, 'int', WidthLimit, 'int', 0, rc)  ; Set max width

        DT_WORDBREAK := 0x10
        DT_CALCRECT := 0x400
        DT_LEFT := 0x0
        DT_TOP := 0x0

        flags := DT_CALCRECT | DT_WORDBREAK | DT_LEFT | DT_TOP

        DllCall('DrawTextW'
            , 'ptr', hDC
            , 'wstr', Str
            , 'int', -1
            , 'ptr', rc
            , 'uint', flags)

        width  := NumGet(rc, 8, 'int') - NumGet(rc, 0, 'int')
        height := NumGet(rc, 12, 'int') - NumGet(rc, 4, 'int')

        DllCall('SelectObject', 'ptr', hDC, 'ptr', oldFont)
        DllCall('ReleaseDC', 'ptr', Hwnd, 'ptr', hDC)

        return { w: width, h: height }
    }



    static IsVisible(Hwnd) {
        return DllCall('IsWindowVisible', 'Ptr', Hwnd, 'int')
    }



    ;@region GetToggleVis
    /** ### Description - Monitor.Win.ToggleVis
     * This function returns a function object that toggles the visibility of a window.
     * returns a function object that toggles the visibility of a window. Intended to be used
     * with a hotkey or control. Activating the function displays the window if hidden, and
     * hides if visible. It optionally moves the window, accounting for Dpi scaling.
     * @param {Integer|Object} Hwnd_or_gui - the handle of the window or a GUI object
     * @param {String} [flags=''] - a string of flags to control the behavior of the function.
     * Currently there are two flags: `-Move` and `-Resize`. Use `-Move` to exclude moving the
     * window when toggling visibility. Use `-Resize` to exclude resizing the window when
     * toggling visibility (in situation when the Dpi changes).
     * @param {String} [methodName='Call'] - the name of the method to call when the window is
     * toggled. The method should be a function that accepts the `toggle` object as a parameter.
     * @param {Object} [MoveByMouseDefault] - an object with default values for the
     * `Monitor.Win.MoveByMouse` functions. The toggle function allows you to pass individual
     * parameters when called, which are prioritized. If you do not pass one or more of the
     * parameters, the function then tries to retrieve one from one of these default values,
     * and if not set, it will use the built-in defaults.
     * @param {Function} [Callback] - a function that is called after the window is toggled.
     * The function should accept the `toggle` object as a parameter.
     * @returns {object} - if a GUI is passed to Hwnd_or_gui, the parent object is the GUI object.
     * Specifically, the GUI object gains a property `toggle` which is a container for this
     * functions properties. If an `Hwnd` is passed, an object is created and returned. The object
     * itself also is given the property `toggle`. `toggle` has these properties:
     *  - @property {func} autohide - the autohide function that can be used to set an autohide
     * timer for the window.
     *  - @property {func} Callback - if a Callback is assigned to this property, it will be
     * called every time the function is called and the window is currently hidden. The Callback
     * is not called if the window is currently shown and is being hidden. The Callback occurs
     * after the window is moved, but before it has been revealed. This can be modified by
     * simply moving its place in the script. Find it in the `Monitor.Win.GetToggleVis` method.
     *  - @property {string} cls - the class of the window.
     *  - @property {object} default - the object passed to MoveByMouseDefault.
     *  - @property {boolean} flag_ExcludeMove - whether the `-Move` flag was passed.
     *  - @property {boolean} flag_ExcludeResize - whether the `-Resize` flag was passed.
     *  - @property {integer} Hwnd - the handle of the window.
     *  - @property {string} methodName - the name of the method used to call the function.
     *  - @property {string} title - the title of the window.
     */
    static GetToggleVis(Hwnd_or_gui, flags:='', methodName := 'Call', MoveByMouseDefault?, Callback?) {

        if IsObject(Hwnd_or_gui)
            Hwnd := Hwnd_or_gui.Hwnd, obj := Hwnd_or_gui
        else
            Hwnd := Hwnd_or_gui, obj := {}
        obj.DefineProp('toggle', {Value:{
            default:MoveByMouseDefault??'', cls:WinGetClass(Hwnd), Hwnd:Hwnd
        , title:WinGetTitle(Hwnd), methodName:methodName, Callback:Callback??''
        , flag_ExcludeMove:InStr(flags,'-Move'), flag_ExcludeResize:InStr(flags,'-Resize')
        , autohide:_AutoHide_
        }})
        toggle := obj.toggle
        if IsObject(toggle.default)
            toggle.default.DefineProp('__Get', {Call:((*)=>'')})
        if toggle.flag_ExcludeMove
            toggle.DefineProp(methodName, {Call:_ToggleVis_})
        else
            toggle.DefineProp(methodName, {Call:_ToggleVisAndMove_})
        return obj

        _ToggleVis_(toggle, autohide:=0) {
            original := DetectHiddenWindows(0)
            isHidden := !WinExist(toggle.title ' ahk_class ' toggle.cls)
            DetectHiddenWindows(original)
            if isHidden {
                if toggle.Callback
                    toggle.Callback(toggle)
                WinRestore(toggle.Hwnd), WinActivate(toggle.Hwnd)
                if autohide
                    toggle.autohide(autohide)
            } else
                WinHide(toggle.Hwnd)
        }
        _ToggleVisAndMove_(toggle, coords?, MoveByMouseParams?, autohide:=0, Callback?) {
            original := DetectHiddenWindows(0)
            isHidden := !WinExist(toggle.title ' ahk_class ' toggle.cls)
            DetectHiddenWindows(original)
            if isHidden {
                if IsSet(MoveByMouseParams) {
                    if toggle.flag_ExcludeResize {
                        Mon.Win.MoveByMouse(toggle.Hwnd, _ResolveInput_('UseWorkArea') || Unset
                        , _ResolveInput_('MoveImmediately') || Unset, _ResolveInput_('OffsetMouse') || Unset
                        , _ResolveInput_('OffsetEdgeOfMonitor') || Unset
                        )
                    } else {
                        Mon.Win.ScaleMoveByMouse(toggle.Hwnd, _ResolveInput_('UseWorkArea') || Unset
                        , _ResolveInput_('MoveImmediately') || Unset, _ResolveInput_('OffsetMouse') || Unset
                        , _ResolveInput_('OffsetEdgeOfMonitor') || Unset
                        )
                    }
                } else if IsSet(coords) {
                    if toggle.flag_ExcludeResize {
                        WinMove(coords.x, coords.y
                        , (coords.HasOwnProp('w') ? coords.w : Unset)
                        , (coords.HasOwnProp('h') ? coords.h : Unset)
                        )
                    } else {
                        newSize := Mon.Win.GetScaledLength(Mon.FromWin(toggle.Hwnd), Mon.FromPt(coords.x,coords.y), toggle.Hwnd)
                        WinMove(coords.x, coords.y, newSize.Width, newSize.Height, toggle.Hwnd)
                    }
                }
                if toggle.Callback
                    toggle.Callback(toggle)
                if IsSet(Callback)
                    Callback(toggle)
                WinRestore(toggle.Hwnd), WinActivate(toggle.Hwnd)
                if autohide
                    toggle.autohide(autohide)
            } else
                WinHide(toggle.Hwnd)

        _ResolveInput_(key) => ((IsObject(MoveByMouseParams) && MoveByMouseParams.HasOwnProp(key)) ? MoveByMouseParams.%key%
            : (IsObject(toggle.default) && toggle.default.HasOwnProp(key)) ? toggle.default.%key% : '')
        }

        _AutoHide_(toggle, period, *) => SetTimer(WinHide.Bind(toggle.Hwnd), Abs(period) * -1)
    }
    ;@endregion


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
            this.GuiObj.UpdateText(Format('`r`nenum child window proc`r`n1: x{} y{} w{} h{}`r`n2: x{} y{} w{} h{}`r`n3: x{} y{} w{} h{}', rects[1].l, rects[1].t, rects[1].r, rects[1].b, rects[2].l, rects[2].t, rects[2].r, rects[2].b, rects[3].l, rects[3].t, rects[3].r, rects[3].b), A_ThisFunc, A_LineNumber, A_LineFile)
            DllCall('UnionRect', 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
            this.GuiObj.UpdateText(Format('`r`nenum child window proc`r`n1: x{} y{} w{} h{}`r`n2: x{} y{} w{} h{}`r`n3: x{} y{} w{} h{}', rects[1].l, rects[1].t, rects[1].r, rects[1].b, rects[2].l, rects[2].t, rects[2].r, rects[2].b, rects[3].l, rects[3].t, rects[3].r, rects[3].b), A_ThisFunc, A_LineNumber, A_LineFile)
            this.GuiObj.UpdateText(Format('`r`nenum child window proc`r`n1: x{} y{} w{} h{}`r`n2: x{} y{} w{} h{}`r`n3: x{} y{} w{} h{}', rects[1].l, rects[1].t, rects[1].r, rects[1].b, rects[2].l, rects[2].t, rects[2].r, rects[2].b, rects[3].l, rects[3].t, rects[3].r, rects[3].b), A_ThisFunc, A_LineNumber, A_LineFile)
            rects.Push(rects.RemoveAt(1))
            this.GuiObj.UpdateText(Format('`r`nenum child window proc`r`n1: x{} y{} w{} h{}`r`n2: x{} y{} w{} h{}`r`n3: x{} y{} w{} h{}', rects[1].l, rects[1].t, rects[1].r, rects[1].b, rects[2].l, rects[2].t, rects[2].r, rects[2].b, rects[3].l, rects[3].t, rects[3].r, rects[3].b), A_ThisFunc, A_LineNumber, A_LineFile)
            return 1
        }
    }


    ;@region GetPosByM
    /**
     * @description - A utility function for getting a new position for a window as a function of the
     * mouse's current position. See {@link Win.MoveByMouse} for more information.
     */
    static GetPosByMouse(&OutX, &OutY, mX, mY, wW, wH, OffsetMouse, OffsetEdgeOfMonitor, Unit) {
        if (mX + OffsetMouse.X + wW > Unit.R - OffsetEdgeOfMonitor.X)
            OutX := Unit.R - wW - OffsetEdgeOfMonitor.X
        else if (mX + OffsetMouse.X < Unit.L + OffsetEdgeOfMonitor.X)
            OutX := Unit.L + OffsetEdgeOfMonitor.X
        else
            OutX := mX + OffsetMouse.X
        if (mY + OffsetMouse.Y + wH > Unit.B - OffsetEdgeOfMonitor.Y)
            OutY := Unit.B - wH - OffsetEdgeOfMonitor.Y
        else if (mY + OffsetMouse.Y < Unit.T + OffsetEdgeOfMonitor.Y)
            OutY := Unit.T + OffsetEdgeOfMonitor.Y
        else
            OutY := mY + OffsetMouse.Y
    }
    ;@endregion




    ;@region PathFromTitle
    /**
     * @description - Uses RegEx to extract the path from a Window's title. Generally this is
     * intended to be used to get AHK script paths, but it will work with any window that has a
     * path in the title.
     * @param {String} Hwnd - The handle to the window.
     * @returns {RegExMatchInfo} - If found, returns the `RegExMatchInfo` object obtained from
     * the match. The object has the subcapture groups available:
     * - dir: The directory path starting from the drive letter.
     * - drive: The drive letter.
     * - name: The file name.
     * - ext: The file extension.
     */
    static PathFromTitle(Hwnd) {
        if RegExMatch(WinGetTitle(Hwnd)
        , '(?<dir>(?<drive>[a-zA-Z]):\\(?:[^\r\n\\/:\*\?"<>\|]+\\?)+)\\(?<name>[^\r\n\\/:\*\?"<>\|]+)\.(?<ext>[\w\d]+)\b'
        , &MatchPath) {
            return MatchPath
        }
    }
    ;@endregion



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



    /**
     * @class
     * @description - Handles the input options.
     */
    class Defaults {
        class Null {
            static __New() {
                ObjSetBase(this, this())
            }
        }

        /**
         * @description - Sets the base object.
         * @param {Object} Options - The input object.
         * @param {String} Name - The function name.
         * @return {Object} - The same input object.
         */
        static Call(Options, Name) {
            ObjSetBase(Options, this.%SubStr(Name, InStr(Name, '.', , , -1) + 1)%)
            return Options
        }
        static MoveByMouse := {
            UseWorkArea: true
          , MoveImmediately: true
          , OffsetMouse: { x: 5, y: 5 }
          , OffsetEdgeOfMonitor: { x: 50, y: 50 }
          , MouseCoordMode: 'Screen'
        }
    }
}

