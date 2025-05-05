
; Dependencies
#include ..\definitions\Define-Scrollbar.ahk

#include ..\struct
#include POINT.ahk

#include ..\lib
#include SetThreadDpiAwareness__Call.ahk
#include Text.ahk

#include ..\src\dWin.ahk

class dScrollbar {

    /**
     * @description -
     * - SB_BOTH - Enables or disables the arrows on the horizontal and vertical scroll bars
     * associated with the specified window. The hWnd parameter must be the handle to the window.
     * - SB_CTL - Indicates that the scroll bar is a scroll bar control. The hWnd must be the handle
     * to the scroll bar control.
     * - SB_HORZ - Enables or disables the arrows on the horizontal scroll bar associated with the
     * specified window. The hWnd parameter must be the handle to the window.
     * - SB_VERT - Enables or disables the arrows on the vertical scroll bar associated with the
     * specified window. The hWnd parameter must be the handle to the window.
     * - ESB_DISABLE_BOTH - Disables both arrows on a scroll bar.
     * - ESB_DISABLE_DOWN - Disables the down arrow on a vertical scroll bar.
     * - ESB_DISABLE_LEFT - Disables the left arrow on a horizontal scroll bar.
     * - ESB_DISABLE_LTUP - Disables the left arrow on a horizontal scroll bar or the up arrow of a
     * vertical scroll bar.
     * - ESB_DISABLE_RIGHT - Disables the right arrow on a horizontal scroll bar.
     * - ESB_DISABLE_RTDN - Disables the right arrow on a horizontal scroll bar or the down arrow of
     * a vertical scroll bar.
     * - ESB_DISABLE_UP - Disables the up arrow on a vertical scroll bar.
     * - ESB_ENABLE_BOTH - Enables both arrows on a scroll bar.
     */
    static Call(GuiObj, wSBflags := 0, wArrows := 0, PageSizeDataCtrl?, UnitsPerScrollH := 8, UnitsPerScrollV := 8) {
        if !DllCall('ShowScrollBar', 'ptr', GuiObj.hWnd, 'uint', wSBflags, 'int', wArrows, 'int') {
            throw Error('ShowScrollbar failed.', -1)
        }
        DllCall('EnableScrollBar', 'ptr', GuiObj.hWnd, 'int', wSBflags, 'int', wArrows, 'int')
        GuiObj.UnitsPerScrollH := UnitsPerScrollH
        GuiObj.UnitsPerScrollV := UnitsPerScrollV
        if IsSet(PageSizeDataCtrl) {
            GuiObj.PageSizeDataCtrl := PageSizeDataCtrl
        } else {
            ; If the calling function doesn't provide a control to use as the basis for
            ; setting the page size, we will use the largest control. Specifically, what
            ; gets used is its font size. Choosing the largest control is arbitrary; we
            ; need some way to determine the page size.
            for Ctrl in GuiObj {
                Ctrl.GetPos(&cx, &cy, &cw, &ch)
                GuiObj.UpdateText(Format('`r`nx{} y{} w{} h{}', cx, cy, cw, ch), A_ThisFunc, A_LineNumber, A_LineFile)
                if A_Index == 1 {
                    LargestCtrl := { Ctrl: Ctrl, Area: cw * ch }
                } else {
                    if cw * ch > LargestCtrl.Area {
                        LargestCtrl := { Ctrl: Ctrl, Area: cw * ch }
                    }
                }
            }
            GuiObj.PageSizeDataCtrl := LargestCtrl.Ctrl
        }
        GuiObj.UpdateText(LargestCtrl.area, A_ThisFunc, A_LineNumber, A_LineFile)
        GuiObj.GetPos(, , &gw, &gh)
        this.SetScrollInfo(GuiObj, 0, gw, gh)

        OnMessage(WM_VSCROLL ?? 0x0115, ObjBindMethod(this, 'OnVScroll'))
        OnMessage(WM_HSCROLL ?? 0x0114, ObjBindMethod(this, 'OnHScroll'))
        ; OnMessage(WM_MOUSEWHEEL ?? 0x020A, OnMouseWheel)
        GuiObj.OnEvent('Size', ObjBindMethod(this, 'SetScrollInfo'))

    }

    static SetScrollInfo(GuiObj, MinMax, NewWidth, NewHeight) {
        ; Get the dimensions for a line of text.
        if !(hDC := DllCall('GetDC', 'Ptr', GuiObj.PageSizeDataCtrl.Hwnd, 'Ptr')) {
            throw OSError()
        }
        sz := GetTextExtentPoint32(hDC, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
        GuiObj.UpdateText('text extent point. horz: ' TextW '    vert: ' TextH, A_ThisFunc, A_LineNumber, A_LineFile)

        ; Get the bounding rect for all controls in the window.
        ScrollInfo := dWin.GetChildrenBoundingRect(GuiObj.Hwnd)
        GuiObj.UpdateText('GetChildrenBoundingRect: ' Format('l{} t{} r{} b{} w{} h{}', ScrollInfo.l, ScrollInfo.t, ScrollInfo.r, ScrollInfo.b, ScrollInfo.w, ScrollInfo.h), A_ThisFunc, A_LineNumber, A_LineFile)

        ;Vertical
        ; One line of text = 1 page unit.
        GuiObj.PageUnitV := TextH
        ScrollInfo := this.ScrollInfo(SIF_PAGE | SIF_RANGE)
        ; Set SIF_PAGE to the number of lines that can fit in the client area (`NewHeight`).
        NumPut('int', GuiObj.PageSizeV := NewHeight / TextH, ScrollInfo, 16) ; SIF_PAGE
        GuiObj.UpdateText('GuiObj.PageSizeV - ' GuiObj.PageSizeV, A_ThisFunc, A_LineNumber, A_LineFile)
        ; Set SIF_RANGE using the number of lines occupied by all controls in the window, including
        ; controls that are not visible.
        NumPut('int', GuiObj.ScrollRangeMinV := 1, ScrollInfo, 8) ; `nMin := 1` :: CIF_RANGE
        NumPut('int', GuiObj.ScrollRangeMaxV := ScrollInfo.H / TextH, ScrollInfo, 12) ; `nMax := Totalheight / TextHeight` for SIF_RANGE
        GuiObj.UpdateText('Min and MaxV - ' GuiObj.ScrollRangeMinV '   ' GuiObj.ScrollRangeMaxV, A_ThisFunc, A_LineNumber, A_LineFile)
        DllCall('SetScrollInfo', 'ptr', GuiObj.Hwnd, 'int', SB_VERT, 'ptr', ScrollInfo, 'int', 1, 'int')

        ;Horizontal
        ; The average width of a character = 1 page unit.
        GuiObj.PageUnitH := Round(NewWidth / 26, 0)
        GuiObj.UpdateText('GuiObj.PageUnitH: ' GuiObj.PageUnitH, A_ThisFunc, A_LineNumber, A_LineFile)
        ScrollInfo := this.ScrollInfo(SIF_PAGE | SIF_RANGE)
        ; Set SIF_PAGE to the number of characters that can fit in the client area (`NewWidth`).
        NumPut('int', GuiObj.PageSizeH := NewWidth / TextW, ScrollInfo, 16) ; SIF_PAGE
        GuiObj.UpdateText('GuiObj.PageSizeH - ' GuiObj.PageSizeH, A_ThisFunc, A_LineNumber, A_LineFile)
        ; Set SIF_RANGE using the number of characters occupied by all controls in the window, including
        ; controls that are not visible.
        NumPut('int', GuiObj.ScrollRangeMinH := 1, ScrollInfo, 8) ; `nMin := 1` :: CIF_RANGE
        NumPut('int', GuiObj.ScrollRangeMaxH := ScrollInfo.W / TextW, ScrollInfo, 12) ; `nMax := Totalwidth / TextWidth` for SIF_RANGE
        GuiObj.UpdateText('GuiObj.ScrollRangeMinH - ' GuiObj.ScrollRangeMinH ' ' 'GuiObj.ScrollRangeMaxH - ' GuiObj.ScrollRangeMaxH, A_ThisFunc, A_LineNumber, A_LineFile)
        DllCall('SetScrollInfo', 'ptr', GuiObj.Hwnd, 'int', SB_HORZ, 'ptr', ScrollInfo, 'int', 1, 'int')
    }


    static OnVScroll(wParam, lParam, Message, hWnd) {
        If !DllCall('GetScrollInfo', 'Ptr', hWnd, 'Int', SB_VERT, 'Ptr', ScrollInfo := this.ScrollInfo(SIF_ALL), 'int') {
            throw Error('GetScrollInfo failed.', -1)
        }
        GuiObj := GuiFromHwnd(Hwnd)
        GuiObj.UpdateText('OnVSCroll', A_ThisFunc, A_LineNumber, A_LineFile)
        GuiObj := GuiFromHwnd(Hwnd)
        yPos := NewPos := NumGet(ScrollInfo, 20, 'Int') ; nPos
        GuiObj.UpdateText('yPos := NewPos - ' yPos, A_ThisFunc, A_LineNumber, A_LineFile)
        Switch wParam & 0xFFFF {
            case SB_TOP: NewPos := GuiObj.ScrollRangeMinV
            GuiObj.UpdateText('SB_TOP: NewPos := GuiObj.ScrollRangeMinV - ' GuiObj.ScrollRangeMinV, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_BOTTOM: NewPos := GuiObj.ScrollRangeMaxV
            GuiObj.UpdateText('SB_BOTTOM: NewPos := GuiObj.ScrollRangeMaxV - ' GuiObj.ScrollRangeMaxV, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_LINEUP: NewPos -= GuiObj.LinesPerScroll
            GuiObj.UpdateText('SB_LINEUP: NewPos -= GuiObj.LinesPerScroll - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_LINEDOWN: NewPos += GuiObj.LinesPerScroll
            GuiObj.UpdateText('SB_LINEDOWN: NewPos += GuiObj.LinesPerScroll - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_PAGEUP: NewPos -= ScrollInfo.H - GuiObj.LinesPerScroll
            GuiObj.UpdateText('SB_PAGEUP: NewPos -= ScrollInfo.H - GuiObj.LinesPerScroll - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_PAGEDOWN: NewPos += ScrollInfo.H - GuiObj.LinesPerScroll
            GuiObj.UpdateText('SB_PAGEDOWN: NewPos += ScrollInfo.H - GuiObj.LinesPerScroll - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_THUMBTRACK: NewPos := wParam >> 16
            GuiObj.UpdateText('SB_THUMBTRACK: NewPos := wParam >> 16 - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            default: return
        }

        NumPut('int', NewPos, ScrollInfo, 20) ; nPos
        DllCall('SetScrollInfo', 'ptr', hWnd, 'int', SB_VERT, 'ptr', ScrollInfo, 'int', 1, 'int')
        DllCall('GetScrollInfo', 'ptr', hWnd, 'int', SB_VERT, 'ptr', ScrollInfo, 'int')
        NewPos := NumGet(ScrollInfo, 20, 'int') ; nPos
        GuiObj.UpdateText('NewPos = ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
        ; If the scroll position has changed, scroll the window.
        if yPos != NewPos {
            DllCall('ScrollWindowEx', 'ptr', hWnd, 'int', 0, 'int', GuiObj.PageUnitV * (yPos - NewPos), 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'int', 0, 'int')
            GuiObj.UpdateText("'ScrollWindowEx', 'ptr', hWnd, 'int', 0, 'int', GuiObj.PageUnitV * (yPos - NewPos)' NewPos - " (GuiObj.PageUnitV * (yPos - NewPos)), A_ThisFunc, A_LineNumber, A_LineFile)
        }
    }


    static OnHScroll(wParam, lParam, Message, hWnd) {
        If !DllCall('GetScrollInfo', 'Ptr', hWnd, 'Int', SB_HORZ, 'Ptr', ScrollInfo := this.ScrollInfo(SIF_ALL), 'int') {
            throw Error('GetScrollInfo failed.', -1)
        }
        GuiObj := GuiFromHwnd(Hwnd)
        GuiObj.UpdateText('OnHSCroll', A_ThisFunc, A_LineNumber, A_LineFile)
        GuiObj := GuiFromHwnd(Hwnd)
        xPos := NewPos := NumGet(ScrollInfo, 20, 'Int') ; nPos
        GuiObj.UpdateText('xPos := NewPos - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
        Switch wParam & 0xFFFF {
            case SB_LINELEFT: NewPos -= GuiObj.PageUnitH
                GuiObj.UpdateText('SB_LINELEFT: NewPos -= GuiObj.PageUnitH - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_LINERIGHT: NewPos += GuiObj.PageUnitH
                GuiObj.UpdateText('SB_LINERIGHT: NewPos += GuiObj.PageUnitH - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_PAGELEFT: NewPos -= ScrollInfo.W - GuiObj.PageUnitH
                GuiObj.UpdateText('SB_PAGELEFT: NewPos -= ScrollInfo.W - GuiObj.PageUnitH - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_PAGERIGHT: NewPos += ScrollInfo.W - GuiObj.PageUnitH
                GuiObj.UpdateText('SB_PAGERIGHT: NewPos += ScrollInfo.W - GuiObj.PageUnitH - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            case SB_THUMBTRACK: NewPos := wParam >> 16
                GuiObj.UpdateText('SB_THUMBTRACK: NewPos := wParam >> 16 - ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
            default: return
        }

        NumPut('int', NewPos, ScrollInfo, 20) ; nPos
        DllCall('SetScrollInfo', hWnd, 'ptr', SB_HORZ, 'ptr', ScrollInfo, 'int', 1, 'int')
        DllCall('GetScrollInfo', 'ptr', hWnd, 'int', SB_HORZ, 'ptr', ScrollInfo, 'int')
        NewPos := NumGet(ScrollInfo, 20, 'int') ; nPos
        ; If the scroll position has changed, scroll the window.
        GuiObj.UpdateText('NewPos = ' NewPos, A_ThisFunc, A_LineNumber, A_LineFile)
        if xPos != NewPos {
            DllCall('ScrollWindowEx', 'ptr', hWnd, 'int', GuiObj.PageUnitH * (xPos - NewPos), 'int', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'int', 0, 'int')
            GuiObj.UpdateText("ScrollWindowEx', 'ptr', hWnd, 'int', GuiObj.PageUnitH * (xPos - NewPos) - " (GuiObj.PageUnitH * (xPos - NewPos)), A_ThisFunc, A_LineNumber, A_LineFile)
        }
    }

    class ScrollInfo extends Buffer {
        __New(fMask?) {
            this.Size := 28
            NumPut('uint', this.Size, this, 0)
            if IsSet(fMask) {
                NumPut('uint', fMask, this, 4)
            }
        }
    }
}
