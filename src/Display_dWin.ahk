
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
        OriginalDpi := GetDpiForWindow(hWnd)
        NewDpi := IsSet(X) || IsSet(Y) ? dMon.Dpi.Pt(X, Y) : OriginalDpi
        if !NewDpi
            NewDpi := dMon.Dpi.Pt(X * 96 / A_ScreenDpi, Y * 96 / A_ScreenDpi)
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
    static MoveByMouse(hWnd, &OutX?, &OutY?, Params?) {
        Params := this.Defaults(Params??{}, A_ThisFunc)
        oCoordMode := CoordMode('Mouse', Params.MouseCoordMode)
        MouseGetPos(&OutX, &OutY)
        WinGetPos(, , &wW, &wH, Number(hWnd))
        Params.OffsetPoint := Params.OffsetMouse
        dWin.GetPosByPoint(&OutX, &OutY, wW, wH, dMon.FromMouse_U(), Params)
        Params.DeleteProp('OffsetMouse')
        if Params.MoveImmediately {
            WinMove(OutX, OutY, , , Number(hWnd))
        }
        CoordMode('Mouse', oCoordMode)
    }
    ;@endregion




    ;@region ScaleMoveByMouse
    /** ### Description - Monitor.WinMoveByMouse()
     * {@see Monitor.dWin.MoveByMouse}
     * This method will scale the window if it moves to a monitor with a different Dpi.
     * @param {Integer} hWnd - the handle of the window
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
    static ScaleMoveByMouse(hWnd, &OutX?, &OutY?, Params?) {
        Params := this.Defaults(Params??{}, A_ThisFunc)
        oCoordMode := CoordMode('Mouse', Params.MouseCoordMode)
        WinGetPos(, , &wW, &wH, Number(hWnd))
        DpiRatio := dMon.Dpi.Win(hWnd) / dMon.Dpi.Mouse()
        MouseGetPos(&OutX, &OutY)
        Params.OffsetPoint := Params.OffsetMouse
        dWin.GetPosByPoint(&OutX, &OutY, wW / DpiRatio, wH / DpiRatio, dMon.FromMouse_U(), Params)
        Params.DeleteProp('OffsetMouse')
        if Params.MoveImmediately {
            WinMove(OutX, OutY, , , Number(hWnd))
        }
        CoordMode('Mouse', oCoordMode)
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
        unitCurrent := dMon.FromWin(hWnd), unitTarget := dMon.Get(Hmon)
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



    ;@region GetToggleVis
    /** ### Description - Monitor.dWin.ToggleVis
     * This function returns a function object that toggles the visibility of a window.
     * returns a function object that toggles the visibility of a window. Intended to be used
     * with a hotkey or control. Activating the function displays the window if hidden, and
     * hides if visible. It optionally moves the window, accounting for Dpi scaling.
     * @param {Integer|Object} hWnd_or_gui - the handle of the window or a GUI object
     * @param {String} [flags=''] - a string of flags to control the behavior of the function.
     * Currently there are two flags: `-Move` and `-Resize`. Use `-Move` to exclude moving the
     * window when toggling visibility. Use `-Resize` to exclude resizing the window when
     * toggling visibility (in situation when the Dpi changes).
     * @param {String} [methodName='Call'] - the name of the method to call when the window is
     * toggled. The method should be a function that accepts the `toggle` object as a parameter.
     * @param {Object} [MoveByMouseDefault] - an object with default values for the
     * `Monitor.dWin.MoveByMouse` functions. The toggle function allows you to pass individual
     * parameters when called, which are prioritized. If you do not pass one or more of the
     * parameters, the function then tries to retrieve one from one of these default values,
     * and if not set, it will use the built-in defaults.
     * @param {Function} [Callback] - a function that is called after the window is toggled.
     * The function should accept the `toggle` object as a parameter.
     * @returns {object} - if a GUI is passed to hWnd_or_gui, the parent object is the GUI object.
     * Specifically, the GUI object gains a property `toggle` which is a container for this
     * functions properties. If an `hWnd` is passed, an object is created and returned. The object
     * itself also is given the property `toggle`. `toggle` has these properties:
     *  - @property {func} autohide - the autohide function that can be used to set an autohide
     * timer for the window.
     *  - @property {func} Callback - if a Callback is assigned to this property, it will be
     * called every time the function is called and the window is currently hidden. The Callback
     * is not called if the window is currently shown and is being hidden. The Callback occurs
     * after the window is moved, but before it has been revealed. This can be modified by
     * simply moving its place in the script. Find it in the `Monitor.dWin.GetToggleVis` method.
     *  - @property {string} cls - the class of the window.
     *  - @property {object} default - the object passed to MoveByMouseDefault.
     *  - @property {boolean} flag_ExcludeMove - whether the `-Move` flag was passed.
     *  - @property {boolean} flag_ExcludeResize - whether the `-Resize` flag was passed.
     *  - @property {integer} hWnd - the handle of the window.
     *  - @property {string} methodName - the name of the method used to call the function.
     *  - @property {string} title - the title of the window.
     */
    static GetToggleVis(hWnd_or_gui, flags:='', methodName := 'Call', MoveByMouseDefault?, Callback?) {

        if IsObject(hWnd_or_gui)
            hWnd := hWnd_or_gui.hWnd, obj := hWnd_or_gui
        else
            hWnd := hWnd_or_gui, obj := {}
        obj.DefineProp('toggle', {Value:{
            default:MoveByMouseDefault??'', cls:WinGetClass(hWnd), hWnd:hWnd
        , title:WinGetTitle(hWnd), methodName:methodName, Callback:Callback??''
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
                WinRestore(toggle.hWnd), WinActivate(toggle.hWnd)
                if autohide
                    toggle.autohide(autohide)
            } else
                WinHide(toggle.hWnd)
        }
        _ToggleVisAndMove_(toggle, coords?, MoveByMouseParams?, autohide:=0, Callback?) {
            original := DetectHiddenWindows(0)
            isHidden := !WinExist(toggle.title ' ahk_class ' toggle.cls)
            DetectHiddenWindows(original)
            if isHidden {
                if IsSet(MoveByMouseParams) {
                    if toggle.flag_ExcludeResize {
                        dMon.dWin.MoveByMouse(toggle.hWnd, _ResolveInput_('UseWorkArea') || Unset
                        , _ResolveInput_('MoveImmediately') || Unset, _ResolveInput_('OffsetMouse') || Unset
                        , _ResolveInput_('OffsetEdgeOfMonitor') || Unset
                        )
                    } else {
                        dMon.dWin.ScaleMoveByMouse(toggle.hWnd, _ResolveInput_('UseWorkArea') || Unset
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
                        newSize := dMon.dWin.GetScaledLength(dMon.FromWin(toggle.hWnd), dMon.FromPt(coords.x,coords.y), toggle.hWnd)
                        WinMove(coords.x, coords.y, newSize.Width, newSize.Height, toggle.hWnd)
                    }
                }
                if toggle.Callback
                    toggle.Callback(toggle)
                if IsSet(Callback)
                    Callback(toggle)
                WinRestore(toggle.hWnd), WinActivate(toggle.hWnd)
                if autohide
                    toggle.autohide(autohide)
            } else
                WinHide(toggle.hWnd)

        _ResolveInput_(key) => ((IsObject(MoveByMouseParams) && MoveByMouseParams.HasOwnProp(key)) ? MoveByMouseParams.%key%
            : (IsObject(toggle.default) && toggle.default.HasOwnProp(key)) ? toggle.default.%key% : '')
        }

        _AutoHide_(toggle, period, *) => SetTimer(WinHide.Bind(toggle.hWnd), Abs(period) * -1)
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
            DllCall('UnionRect', 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
            rects.Push(rects.RemoveAt(1))
            return 1
        }
    }


    ;@region GetPosByPoint
    /**
     * @description - A utility function for getting a new position nearby a point. The returned
     * point is guaranteed to keep the rect completely on a single monitor, and allows two offsets
     * to be used to control the position relative to the point and relative to the edge of the
     * monitor.
     */
    static GetPosByPoint(&X, &Y, Width, Height, Unit, Params?) {
        Params := this.Defaults(Params??{}, A_ThisFunc)
        OffsetPoint := Params.OffsetPoint
        OffsetEdgeOfMonitor := Params.OffsetEdgeOfMonitor
        if Params.UseWorkArea {
            _Process(Unit.LW, Unit.TW, Unit.RW, Unit.BW)
        } else {
            _Process(Unit.L, Unit.T, Unit.R, Unit.B)
        }

        _Process(UnitL, UnitT, UnitR, UnitB) {
            if (X + OffsetPoint.X + Width > UnitR - OffsetEdgeOfMonitor.X)
                OutX := UnitR - Width - OffsetEdgeOfMonitor.X
            else if (X + OffsetPoint.X < UnitL + OffsetEdgeOfMonitor.X)
                OutX := UnitL + OffsetEdgeOfMonitor.X
            else
                OutX := X + OffsetPoint.X
            if (Y + OffsetPoint.Y + Height > UnitB - OffsetEdgeOfMonitor.Y)
                OutY := UnitB - Height - OffsetEdgeOfMonitor.Y
            else if (Y + OffsetPoint.Y < UnitT + OffsetEdgeOfMonitor.Y)
                OutY := UnitT + OffsetEdgeOfMonitor.Y
            else
                OutY := Y + OffsetPoint.Y
        }
    }
    ;@endregion


    ;@region PathFromTitle
    /**
     * @description - Uses RegEx to extract the path from a Window's title. Generally this is
     * intended to be used to get AHK script paths, but it will work with any window that has a
     * path in the title.
     * @param {String} hWnd - The handle to the window.
     * @returns {RegExMatchInfo} - If found, returns the `RegExMatchInfo` object obtained from
     * the match. The object has the subcapture groups available:
     * - drive: The drive letter, if present.
     * - dir: The directory path starting from the drive letter.
     * - name: The file name.
     * - ext: The file extension.
     * @example
     *  G := Gui(, 'C:\Users\YourName\Documents\AutoHotkey\lib\Display_Win.ahk')
     *  TitleMatch := dWin.PathFromTitle(G.hWnd)
     *  MsgBox(TitleMatch.drive) ; C
     *  MsgBox(TitleMatch.dir) ; C:\Users\YourName\Documents\AutoHotkey\lib
     *  MsgBox(TitleMatch.file) ; Display_Win
     *  MsgBox(TitleMatch.ext) ; ahk
     * @
     */
    static PathFromTitle(hWnd) {
        if RegExMatch(WinGetTitle(hWnd)
        , '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+)\b'
        , &MatchPath) {
            return MatchPath
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
        static GetPosByPoint := {
            UseWorkArea: true
          , OffsetPoint: { x: 5, y: 5 }
          , OffsetEdgeOfMonitor: { x: 50, y: 50 }
        }
        static ScaleMoveByMouse := {
            UseWorkArea: true
          , MoveImmediately: true
          , OffsetMouse: { x:5, y:5 }
          , OffsetEdgeOfMonitor: { x:50, y:50 }
          , MouseCoordMode: 'Screen'
        }
    }
}
