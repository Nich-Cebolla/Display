
; Dependencies
#include ..\struct
#include LOGFONT.ahk
#include ..\lib\ControlTextExtent.ahk
#include ..\..\AutoHotkey-LibV2\ItemScroller.ahk
#include <stringify>

#singleinstance force

/**
 * @class
 * @description - An instance of this class is added to `Gui.Control` objects on property
 * `DpiChangedHelper`. This implements some necessary logic for correctly scaling and responding
 * to `WM_DPICHANGED`.
 */
class ControlDpiChangedHelper {
    /**
     * @description - This method is used to create a new instance of the `ControlDpiChangedHelper`
     * class. This method is called by the `Gui.Control` constructor.
     * @param {Gui.Control} Ctrl - The control object to attach this helper to.
     * @returns {dGui.ControlDpiChangedHelper} - The new instance of the `ControlDpiChangedHelper`.
     */
    __New(Ctrl) {
        lf := LOGFONT(Ctrl.hWnd)
        lf()
        this.FontSize := lf.FontSize
        this.Dpi := lf.Dpi
        this.Rounded := { X: 0, Y: 0, W: 0, H: 0 }
        Ctrl.DefineProp('DpiChangedHelper', { Value: this })
    }

    /**
     * @description - This method is used to get the dpi-adjusted position and size values for
     * a control. This method is to be used when scaling controls by a dpi ratio. This method
     * prevents control drifting due to repeated rounding.
     * @param {Float} DpiRatio - The ratio of the new dpi to the old dpi.
     * @param {VarRef} [X] - The x coordinate of the control. This must contain the original
     * X value and will be modified to the scaled X value.
     * @param {VarRef} [Y] - The y coordinate of the control. This must contain the original
     * Y value and will be modified to the scaled Y value.
     * @param {VarRef} [W] - The width of the control. This must contain the original
     * W value and will be modified to the scaled W value.
     * @param {VarRef} [H] - The height of the control. This must contain the original
     * H value and will be modified to the scaled H value.
     */
    AdjustByDpi(DpiRatio, &X?, &Y?, &W?, &H?) {
        if IsSet(X) {
            X := Round(NewX := (X + (this.Rounded.X >= 0.5 ? this.Rounded.X*-1 : this.Rounded.X)) * DPIRatio, 0)
            this.Rounded.X := NewX - Floor(NewX)
        }
        if IsSet(Y) {
            Y := Round(NewY := (Y + (this.Rounded.Y >= 0.5 ? this.Rounded.Y*-1 : this.Rounded.Y)) * DPIRatio, 0)
            this.Rounded.Y := NewY - Floor(NewY)
        }
        if IsSet(W) {
            W := Round(NewW := (W + (this.Rounded.W >= 0.5 ? this.Rounded.W*-1 : this.Rounded.W)) * DPIRatio, 0)
            this.Rounded.W := NewW - Floor(NewW)
        }
        if IsSet(H) {
            H := Round(NewH := (H + (this.Rounded.H >= 0.5 ? this.Rounded.H*-1 : this.Rounded.H)) * DPIRatio, 0)
            this.Rounded.H := NewH - Floor(NewH)
        }
    }

    /**
     * @description - This method is used to get the dpi-adjusted position and size values for
     * a control. This method is to be used when scaling controls according to their text contents.
     * This method, when used in conjunction with text scaling functions, addresses the problem
     * of non-linear text scaling leaving blank / empty space within and around controls that
     * primarily contain text. When scaling using only a dpi ratio, there is often noticeable
     * gaps between the text and the control's borders. The way to handle this is to map the
     * interface around the control's text contents, instead of mapping the interface around
     * the controls' relative position to one another.
     * <br>
     * You don't need to call this method directly if you are using the built-in WM_DPICHANGED
     * family of functions. This method is called for any controls that are set by the
     * `DisplayConfig.ResizeByText` property. The default value sets this for controls which have
     * a simple `Text` property (e.g. no controls for which `Text` might return an array, or
     * for which `Text` does not return a string).
     * <br>
     * This library does not provide any methods for filling the extra space that your interface
     * gains from this process. Modern apps usually have a separate layouts defined to seamlessly
     * fill the extra space when the dpi changes.
     * <br>
     * This method performs these functions:
     * - Adjusts the size and position values according to the ratio of the a controls' new
     * text extent to its original text extent.
     * - Caches rounding to prevent control drifting.
     * <br>
     * @param {Float} WidthRatio - The ratio of: NewTextExtent / OriginalTextExtent.
     * @param {Float} HeightRatio - The ratio of: NewTextExtent / OriginalTextExtent.
     * @param {VarRef} [X] - The x coordinate of the control. This must contain the original
     * X value and will be modified to the scaled X value.
     * @param {VarRef} [Y] - The y coordinate of the control. This must contain the original
     * Y value and will be modified to the scaled Y value.
     * @param {VarRef} [W] - The width of the control. This must contain the original
     * W value and will be modified to the scaled W value.
     * @param {VarRef} [H] - The height of the control. This must contain the original
     * H value and will be modified to the scaled H value.
     */
    AdjustByText(WidthRatio, HeightRatio, &X?, &Y?, &W?, &H?) {
        if IsSet(X) {
            X := Round(NewX := (X + (this.Rounded.X >= 0.5 ? this.Rounded.X*-1 : this.Rounded.X)) * WidthRatio, 0)
            this.Rounded.X := NewX - Floor(NewX)
        }
        if IsSet(Y) {
            Y := Round(NewY := (Y + (this.Rounded.Y >= 0.5 ? this.Rounded.Y*-1 : this.Rounded.Y)) * HeightRatio, 0)
            this.Rounded.Y := NewY - Floor(NewY)
        }
        if IsSet(W) {
            W := Round(NewW := (W + (this.Rounded.W >= 0.5 ? this.Rounded.W*-1 : this.Rounded.W)) * WidthRatio, 0)
            this.Rounded.W := NewW - Floor(NewW)
        }
        if IsSet(H) {
            H := Round(NewH := (H + (this.Rounded.H >= 0.5 ? this.Rounded.H*-1 : this.Rounded.H)) * HeightRatio, 0)
            this.Rounded.H := NewH - Floor(NewH)
        }
    }
}


/**
 * @classdesc - An instance of this class is added to `Gui` objects on property
 * `DpiChangedHelper`. This implements some necessary logic for correctly scaling and responding
 * to `WM_DPICHANGED`.
 */
class GuiDpiHelper {
    /**
     * @description - This method is used to create a new instance of the `GuiDpiHelper`
     * class. This method is called by the `Gui` constructor.
     * @param {Gui} GuiObj - The Gui object to attach this helper to.
     * @returns {dGui.GuiDpiChangedHelper} - The new instance of the `GuiDpiChangedHelper`.
     */
    __New(GuiObj) {
        this.Dpi := GuiObj.Dpi
        this.FontHeight := -11
    }

    DpiScaleSize(Dpi) {
        this.Dpi := Dpi
        return this.AdjustedFontSize
    }

    SetFontSize(FontSize) {
        this.FontSize := FontSize
        return this.AdjustedFontSize
    }

    FontSize[digits := 0] => Round(this.FontHeight * -72 / this.Dpi, digits)
    AdjustedSize[digits := 0] => Round(this.FontHeight * -72 / A_ScreenDpi, digits)
}

DllCall('SetThreadDpiAwarenessContext', 'ptr', -3, 'ptr')
g := Gui('-DPIScale +Resize')
g.setfont('s11')
DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
t := g.Add('Text', , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
lf := LOGFONT(t.hWnd)
g.defineProp('dpi', { get: (self) => DllCall('GetDpiForWindow', 'ptr', self.hWnd, 'int') })
h := guidpihelper(g)
sz := ControlGetTextExtent(t)

g.add('text', 'section vtxtdpi', 'dpi')
g.add('edit', 'ys w100 veditdpi', g.dpi)
g.add('button', 'ys vbtnset', 'set').onevent('click', set)
g.add('text', 'section xs vtxtheight', 'height')
g.add('edit', 'ys w100 veditheight', lf.height)
g.add('text', 'section xs vtxtsize', 'size')
g.add('edit', 'ys w100 veditsize', lf.fontsize)
g.add('text', 'section xs vtxtextent', 'text w: ' sz.Width '; h: ' sz.Height)

stats := [ { dpi: g.dpi, height: lf.height, size: lf.fontsize, textW: sz.Width, textH: sz.Height } ]
g.add('edit', 'ys w150 h200 vstats', stringify(stats[1]))
g['stats'].getpos(, &y, , &h)

g.scroller := ItemScroller(g, { Array: stats, Callback: handlescroll, startx: 10, starty: y + h + g.marginy })
g.show()


set(*) {
    global
    DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
    item := stats[-1]
    lf.height := Round(lf.height * item.dpi / g.dpi, 0)
    t.setfont('s' lf.fontsize)
    t.setfont('s15')
    g['editdpi'].text := g.dpi
    lf.get()
    g['editheight'].text := lf.height
    g['editsize'].text := lf.fontsize
    sz := ControlGetTextExtent(t)
    g['txtextent'].text := 'text w: ' sz.Width '; h: ' sz.Height
    stats.Push({ dpi: g.dpi, height: lf.height, size: lf.fontsize, textW: sz.Width, textH: sz.Height })
    g['stats'].text := stringify(stats[-1]) '`r`n`r`n' g['stats'].text

}

handlescroll(index, scroller, *) {
    global
    g['stats'].text := stringify(scroller[index])
}
