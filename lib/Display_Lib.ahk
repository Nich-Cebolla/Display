; These are just some miscellaneous functions that I have plans for but aren't currently serving
; a purpose in the library

/**
 * @description - The cursor must have been created by either the CreateCursor or the
 * CreateIconIndirect function, or loaded by either the LoadCursor or the LoadImage function. If
 * this parameter (hCursor) is NULL, the cursor is removed from the screen.
 */
SetCursor(hCursor?) {
    return DllCall('SetCursor', 'ptr', hCursor ?? 0, 'ptr')
}


WEBVIEW2_ONDPICHANGE(GuiObj, DpiRatio, GuiL, GuiT, GuiR, GuiB) {
    WvCtrl := GuiObj['WvCtrl']
    WvC := GuiObj.WvC
    WvCtrl.Move(
        X := GuiL + WvCtrl.EdgeOffsetL
      , Y := GuiT + WvCtrl.EdgeOffsetT
      , W := GuiR - WvCtrl.EdgeOffsetR - X
      , H := GuiB - WvCtrl.EdgeOffsetB - Y
    )
    rc := Rect.FromDimensions(X, Y, W, H)
    WvC.Bounds := rc
}

WEBVIEW2_FILL(WvCtrl) {
    dWin.GetClientRect(WvCtrl.Gui.Hwnd, &rc)
    WvCtrl.Move(0, 0, rc.W, rc.H)
    WvCtrl.Gui.WvController.Bounds := rc
}

