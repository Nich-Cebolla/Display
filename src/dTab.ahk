
#include ..\definitions\Define-Tab.ahk
#include ..\struct
#include Point.ahk
#include Rect.ahk


/**
 * The display area is the area within which the tab's controls are visible.
 *
 * The window area is the window's entire area, including tabs and margins.
 */
class dTab extends Gui.Tab {


    static Call(GuiObj, Which, Opt?, Text?) {
        tab := GuiObj.Add(Which, Opt ?? unset, Text ?? unset)
        tab.__Controls := Map()
        tab.__Controls.CaseSense := false
        ObjSetBase(tab, this.Prototype)
        return tab
    }

    /**
     * @description - Delets all tabs.
     */
    DeleteAll() {
        return SendMessage(TCM_DELETEALLITEMS, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @param {Boolean} [Scope=false] - Flag that specifies the scope of the item deselection. If this
     * parameter is set to FALSE, all tab items will be reset. If it is set to TRUE, then all tab
     * items except for the one currently selected will be reset.
     */
    DeselectAll(Scope := false) {
        SendMessage(TCM_DESELECTALL, Scope, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - The input is a display rectangle, and the output is the window rectangle
     * necessary for a tab control to have a display rectangle of the input dimensions.
     * @param {Rect} RectObj - The display rectangle.
     * @returns {Rect} - The window rectangle (same object with new values)
     */
    DisplayToWindow(RectObj) {
        SendMessage(TCM_ADJUSTRECT, true, RectObj, this.hWnd, this.Gui.hWnd)
        return RectObj
    }

    /**
     * @description - Returns the control's display rectangle relative to the parent window.
     * @returns {Rect}
     */
    GetClientDisplayRect() {
        RectObj := Rect()
        if !DllCall('GetWindowRect', 'ptr', this.hWnd, 'ptr', RectObj, 'int') {
            throw OSError()
        }
        RectObj.ToClientInPlace(this.Gui.hWnd)
        SendMessage(TCM_ADJUSTRECT, false, RectObj, this.hWnd, this.Gui.hWnd)
        return RectObj
    }

    /**
     * @description - Returns the control's window rectangle relative to the parent window.
     * @returns {Rect}
     */
    GetClientWindowRect() {
        RectObj := Rect()
        if !DllCall('GetWindowRect', 'ptr', this.hWnd, 'ptr', RectObj, 'int') {
            throw OSError()
        }
        RectObj.ToClientInPlace(this.Gui.hWnd)
        return RectObj
    }

    /**
     * @description - Returns the index of the item that has the focus in a tab control.
     * @returns {Integer}
     */
    GetCurFocus() {
        return SendMessage(TCM_GETCURFOCUS, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Determines the currently selected tab in a tab control.
     * @returns {Integer} - Returns the index of the selected tab if successful, or -1 if no tab is
     * selected.
     */
    GetCurSel() {
        return SendMessage(TCM_GETCURSEL, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Retrieves the extended styles that are currently in use for the tab control.
     * @returns {Integer} - Returns a DWORD value that represents the extended styles currently in
     * use for the tab control. This value is a combination of tab control extended styles.
     */
    GetExtendedStyle() {
        return SendMessage(TCM_GETEXTENDEDSTYLE, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Retrieves the image list associated with a tab control.
     * @returns {Integer} - Returns the handle to the image list if successful, or NULL otherwise.
     */
    GetImageList() {
        return SendMessage(TCM_GETIMAGELIST, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Retrieves the number of tabs in the tab control.
     * @returns {Integer} - Returns the number of items if successful, or zero otherwise.
     */
    GetItemCount() {
        return SendMessage(TCM_GETITEMCOUNT, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Retrieves the bounding rectangle for a tab in a tab control.
     * @returns {Rect}
     * @throws {OSError} - If the `SendMessage` call fails.
     */
    GetItemRect(Index) {
        RectObj := Rect()
        if !SendMessage(TCM_GETITEMRECT, Index, RectObj, this.hWnd, this.Gui.hWnd) {
            throw OSError('Failed to get item rect.', -1)
        }
        return RectObj
    }

    /**
     * @description - Retrieves the current number of rows of tabs in a tab control.
     * @returns {Integer} - The number of rows of tabs.
     */
    GetRowCount() {
        return SendMessage(TCM_GETROWCOUNT, 0, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Returns the control's display rectangle relative to the screen.
     * @returns {Rect}
     */
    GetScreenDisplayRect() {
        RectObj := Rect()
        if !DllCall('GetWindowRect', 'ptr', this.hWnd, 'ptr', RectObj, 'int') {
            throw OSError()
        }
        SendMessage(TCM_ADJUSTRECT, false, RectObj, this.hWnd, this.Gui.hWnd)
        return RectObj
    }

    /**
     * @description - Returns the control's window rectangle relative to the screen.
     * @returns {Rect}
     */
    GetScreenWindowRect() {
        RectObj := Rect()
        if !DllCall('GetWindowRect', 'ptr', this.hWnd, 'ptr', RectObj, 'int') {
            throw OSError()
        }
        return RectObj
    }

    /**
     * @description - Determins if a tab is at the input coordinate.
     * @param {Integer} X - The x-coordinate.
     * @param {Integer} Y - The y-coordinate.
     * @returns {Integer} - One of the following values:
     * - 1: The position is not over a tab.
     * - 2: The position is over a tab's icon.
     * - 4: The position is over a tab's text.
     * - 6: The position is over a tab but not over its icon or its text. For owner-drawn tab
     * controls, this value is specified if the position is anywhere over a tab.
     */
    HitTest(X, Y) {
        HitTest := Buffer(12)
        NumPut('int', X, 'int', Y, HitTest, 0)
        SendMessage(TCM_HITTEST, 0, HitTest.ptr, this.hWnd, this.Gui.hWnd)
        return NumGet(HitTest, 8, 'uint')
    }

    /**
     * @description - Adjusts the size and position of the control to produce a display area with
     * the input dimensions. If a value is not provided, the current value is used.
     * @param {Integer} [X] - The x-coordinate.
     * @param {Integer} [Y] - The y-coordinate.
     * @param {Integer} [W] - The width.
     * @param {Integer} [H] - The height.
     * @returns {Rect} - The window rectangle.
     */
    MoveEx(X?, Y?, W?, H?) {
        RectObj := Rect()
        if !DllCall('GetWindowRect', 'ptr', this.hWnd, 'ptr', RectObj, 'int') {
            throw OSError()
        }
        RectObj.ToClientInPlace(this.Gui.hWnd)
        SendMessage(TCM_ADJUSTRECT, false, RectObj, this.hWnd, this.Gui.hWnd)
        rc := Rect(X ?? RectObj.X, Y ?? RectObj.Y, (W ?? RectObj.W) + (X ?? RectObj.X), (H ?? RectObj.H) + (Y ?? RectObj.Y))
        SendMessage(TCM_ADJUSTRECT, true, rc, this.hWnd, this.Gui.hWnd)
        this.Move(rc.X, rc.Y, rc.W, rc.H)
        return rc
    }

    /**
     * @description - Removes an image from a tab control's image list.
     * @param {Integer} Index - The index of the image to remove.
     */
    RemoveImage(Index) {
        SendMessage(TCM_REMOVEIMAGE, Index, 0, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - Assigns an image list to a tab control.
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/tcm-setimagelist}
     * @param {Integer} Index - The index of the image to remove.
     * @returns {Integer} - Returns the handle to the previous image list, or NULL if there is no
     * previous image list.
     */
    SetImageList(Handle) {
        SendMessage(TCM_SETIMAGELIST, 0, Handle, this.hWnd, this.Gui.hWnd)
    }

    /**
     * @description - The input is a window rectangle, and the output is the display rectangle
     * area for a tab control with the input dimensions.
     * @param {Rect} RectObj - The window rectangle. If unset, the control's current dimensions
     * are used.
     * @returns {Rect} - The display rectangle (same object with new values)
     */
    WindowToDisplay(RectObj) {
        SendMessage(TCM_ADJUSTRECT, false, RectObj, this.hWnd, this.Gui.hWnd)
        return RectObj
    }
}
