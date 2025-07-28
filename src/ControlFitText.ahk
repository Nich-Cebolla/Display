
#include dGui.ahk
#include SelectFontIntoDc.ahk
#include ..\definitions
#include Define-Dpi.ahk
#include Define-Font.ahk
#include Define-Winuser.ahk
#include ..\lib
#include ControlTextExtent.ahk
#include Dpi.ahk
#include Text.ahk
#include ..\struct


/**
 * @classdesc - Resizes a control according to its text contents.
 *
 * To correctly evaluate the needed dimensions, an instance of
 * {@link ControlFitText.TextExtentPadding} is required. Leave the `UseCache` parameter set with
 * `true` to direct `ControlFitText` of `ControlFitText.MaxWidth` to cache the value for each control
 * type, and use the cached value when available.
 *
 * `ControlFitText`, `ControlFitText.MaxWidth`, and `ControlFitText.TextExtentPadding` require
 * `dGui.Control` objects; `Gui.Control` objects will not work without additional preparation (not
 * described here).
 *
 * You can use the "_S" suffix to set the thread dpi awareness context to the default value before
 * calling either function.
 * @see {@link ControlFitText.__Call}.
 *
 * `ControlFitText.TextExtentPadding` is an imperfect approximation of the padding added to a control's
 * area that displays the text. To get the correct dimensions, each control's text content would
 * have to be evaluated individually. However, any discrepencies will likely be unnoticeable, and
 * you can account for discrepencies by adding an additional pixel or two using the `PaddingX` or
 * `PaddingY` parameters. In most cases you shouldn't need to use additional padding. In my tests,
 * the most common problem was edit controls wrapping text when using a vertical scrollbar. `dGui`
 * accounts for this using the `dGui.ScrollbarPadding` value (set in the project config file), but
 * for standard edit controls you will likely need to set `PaddingX` to 1 for edit controls that
 * use a vertical scrollbar.
 *
 * Not all controls are compatible with `ControlFitText` and `ControlFitText.MaxWidth`.
 * `ControlFitText` will not evaluate the size correctly unless the control satisfies the following
 * conditions:
 * - `Ctrl.Text` must return a string that is the same as the text that is displayed in the gui.
 * - `Ctrl.GetPos`, when called directly after adding a control to a gui, must return the dimensions
 * of the control that is relevant to the text's bounding rectangle.
 * - `Ctrl.Move` must resize the portion of the control that is relevant to the text's bounding
 * rectangle.
 *
 * Invalid control types: DateTime, DropDownList, GroupBox, Hotkey, ListBox, ListView, MonthCal,
 * Picture, Progress, Slider, Tab, Tab2, Tab3, TreeView, and UpDown.
 *
 * Valid control types: ActiveX (possibly), Button, CheckBox, ComboBox, Custom (possibly), Edit,
 * Radio, Text.
 *
 * Additional notes:
 *
 * Be aware that `ControlFitText.TextExtentPadding.__New` calls `CtrlObj.GetTextExtent`. Some
 * control types require additional parameters passed to "GetTextExtent". This shouldn't be an issue
 * because those control types are invalid candidates for `ControlFitText`. However, if you experiment
 * with `ControlFitText` and you get an error "Too few parameters passed to function", just cache
 * a `ControlFitText.TextExtentPadding` object:
 * @example
 *  ; Assume `Ctrl` is some `dGui.Control` object and `Params` is an array of parameters for
 *  ; `Ctrl.GetTextExtent`.
 *  ControlFitText.Cache.Set(Ctrl.Type, ControlFitText.TextExtentPadding(Ctrl, , Params))
 * @
 *
 * CheckBox and Radio controls are valid even though they have the checkbox consuming additional
 * width. This is because `ControlFitText.TextExtentPadding` will evaluate that width in its output,
 * so the additional width is accounted for.
 *
 * Link controls are not valid because `LinkCtrl.Text` returns the xml content.
 *
 * ListView controls inherently are poor candidates for `ControlFitText` because they have
 * additional methods / system messages that make it easier to adjust the size of the control according
 * to the text. The additional work required to make `ControlFitText` work with ListView controls
 * exceeds that required to use existing methods.
 */
class ControlFitText {
    static __New() {
        this.DeleteProp('__New')
        this.Cache := this.TextExtentPaddingCollection()
    }

    /**
     * @description - `ControlFitText` returns the width and height for a control to fit its text
     * contents, plus any additional padding.
     *
     * @param {dGui.Control} Ctrl - The control object. See the notes in the class description above
     * {@link ControlFitText} for compatibility requirements.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * `ControlFitText.TextExtentPadding`. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of `SIZE` objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
     * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutWidth` and `OutHeight`. If false, the calculations are performed
     * without moving the control.
     */
    static Call(Ctrl, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutWidth?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(Ctrl.Text, GetLineEnding(Ctrl.Text))
        context := SelectFontIntoDc(Ctrl.hWnd)
        GetMultiExtentPoints(context.hDc, OutExtentPoints, &OutWidth, , true)
        context()
        OutHeight := 0
        if UseCache {
            if !this.Cache.Has(Ctrl.Type) {
                this.Cache.Set(Ctrl.Type, this.TextExtentPadding(Ctrl))
            }
            Padding := this.Cache.Get(Ctrl.Type)
        } else {
            Padding := this.TextExtentPadding(Ctrl)
        }
        OutWidth += PaddingX + Padding.Width
        for sz in OutExtentPoints {
            if sz {
                OutHeight += sz.Height + Padding.LinePadding
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        OutHeight += PaddingY + Padding.Height + Padding.LinePadding * OutExtentPoints.Length
        if MoveControl {
            Ctrl.Move(, , OutWidth, OutHeight)
        }
    }

    /**
     * @description - `ControlFitText.MaxWidth` resizes a control to fit the text contents of the
     * control plus any additional padding while limiting the width of the control to a maximum value.
     * Note that `ControlFitText.MaxWidth` does not include the width value when calling `Ctrl.Move`;
     * it is assumed your code has handled setting the width.
     *
     * @param {dGui.Control} Ctrl - The control object. See the notes in the class description above
     * {@link ControlFitText} for compatibility requirements.
     * @param {Integer} [MaxWidth] - The maximum width in pixels. If unset, uses the controls current
     * width.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * `ControlFitText.TextExtentPadding`. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of `SIZE` objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutHeight] - A variable that will receive an integer value representing the
     * height that was passed to `Ctrl.Move`.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutHeight`. If false, the calculations are performed without moving
     * the control.
     */
    static MaxWidth(Ctrl, MaxWidth?, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(Ctrl.Text, GetLineEnding(Ctrl.Text))
        context := SelectFontIntoDc(Ctrl.hWnd)
        GetMultiExtentPoints(context.hDc, OutExtentPoints, &OutWidth, , true)
        context()
        if !IsSet(MaxWidth) {
            Ctrl.GetPos(, , &MaxWidth)
        }
        if UseCache {
            if !this.Cache.Has(Ctrl.Type) {
                this.Cache.Set(Ctrl.Type, this.TextExtentPadding(Ctrl))
            }
            Padding := this.Cache.Get(Ctrl.Type)
        } else {
            Padding := this.TextExtentPadding(Ctrl)
        }
        MaxWidth -= Padding.Width + PaddingX
        OutHeight := PaddingY + Padding.Height
        for sz in OutExtentPoints {
            if sz {
                lines := Ceil(sz.Width / MaxWidth)
                OutHeight += (sz.Height + Padding.LinePadding) * lines
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        if MoveControl {
            Ctrl.Move(, , , OutHeight)
        }
    }

    class TextExtentPadding {
        /**
         * An instance of `ControlFitText.TextExtentPadding` has four properties:
         * - {@link ControlFitText.TextExtentPadding#Width} - The padding added to the text's extent
         * along the X axis.
         * - {@link ControlFitText.TextExtentPadding#Height} - The padding added to the text's extent
         * along the Y axis, not including the padding added for each individual line.
         * - {@link ControlFitText.TextExtentPadding#LinePadding} - The padding added to the text's
         * extent along the Y axis for each individual line.
         * - {@link ControlFitText.TextExtentPadding#LineHeight} - The approximate height of an
         * blank line.
         *
         * The values of each property are approximations. See the description above
         * {@link ControlFitText} for more details and limitations.
         * @class
         *
         * @param {dGui.Control} Ctrl - The control object.
         * @param {String} [Opt = ""] - Options to pass to `Gui.Prototype.Add`.
         * @param {Array} [GetTextExtentParams] - Some control types require additional parameters
         * passed to `CtrlObj.GetTextExtent`. Set `GetTextExtentParams` with an array of parameters
         * to pass to the method.
         * @param {Integer} [ThreadDpiAwarenessContext] - If set, `ControlFitText.TextExtentPadding.__New`
         * calls `SetThreadDpiAwarenessContext` at the beginning, and calls it again before returning
         * to set the thread's context to its original value.
         */
        __New(Ctrl, Opt := '', GetTextExtentParams?, ThreadDpiAwarenessContext?) {
            if IsSet(ThreadDpiAwarenessContext) {
                originalContext := SetThreadDpiAwarenessContext(ThreadDpiAwarenessContext)
            }
            lf := LOGFONT(Ctrl.Hwnd)
            lf()
            G := dGui()
            G.SetFont('s' lf.FontSize, lf.FaceName)
            lf.DisposeFont()
            c := G.Add(Ctrl.Type, Opt, 'line')
            c.GetPos(, , , &h)
            c2 := G.Add(Ctrl.Type, Opt, 'line`r`nline')
            c2.GetPos(, , &w2, &h2)
            if IsSet(GetTextExtentParams) {
                sz := c.GetTextExtent(GetTextExtentParams*)
                sz2 := c2.GetTextExtent(GetTextExtentParams*)
            } else {
                sz := c.GetTextExtent()
                sz2 := c2.GetTextExtent()
            }
            G.Destroy()
            this.Width := w2 - sz2.Width
            this.Height := h - sz.Height
            this.LinePadding := h2 - sz2.Height - h + sz.Height
            this.LineHeight := (h2 - this.Height) / 2
            if IsSet(originalContext) {
                SetThreadDpiAwarenessContext(originalContext)
            }
        }
    }

    static __Call(Obj, Name, Params) {
        Split := StrSplit(Name, '_')
        if Obj.HasMethod(Split[1]) && Split[2] = 'S' {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
            if Params.Length {
                return Obj.%Split[1]%(Params*)
            } else {
                return Obj.%Split[1]%()
            }
        } else {
            throw PropertyError('Property not found.', -1, Name)
        }
    }

    class TextExtentPaddingCollection extends Map {
    }
}
