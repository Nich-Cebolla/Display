
#include SelectFontIntoDc.ahk
#include ..\struct
#include Display_Logfont.ahk
#include Display_Size.ahk

class Display_ControlFitText {
    static __New() {
        this.DeleteProp('__New')
        this.Cache := this.TextExtentPaddingCollection()
    }

    /**
     * @description -  - Resizes a control according to its text contents.
     *
     * Leave the `UseCache` parameter set with `true` to direct {@link Display_ControlFitText} and
     * {@link Display_ControlFitText.MaxWidth} to cache the value for each control type, and use the
     * cached value when available.
     *
     * {@link Display_ControlFitText.TextExtentPadding} is an imperfect approximation of the padding added
     * to a control's area that displays the text. To get the correct dimensions, each control's text
     * content would have to be evaluated individually. However, any discrepencies will likely be
     * unnoticeable, and you can account for discrepencies by adding an additional pixel or two using
     * the `PaddingX` or `PaddingY` parameters. In most cases you shouldn't need to use additional padding.
     * In my tests, the most common problem was edit controls wrapping text when using a vertical scrollbar;
     * a `PaddingX` value of `1` is sufficient in thise case.
     *
     * Not all controls are compatible with {@link Display_ControlFitText} and {@link Display_ControlFitText.MaxWidth}.
     * {@link Display_ControlFitText} will not evaluate the size correctly unless the control satisfies the following
     * conditions:
     * - `Ctrl.Text` must return a string that is the same as the text that is displayed in the gui.
     * - `Ctrl.GetPos`, when called directly after adding a control to a gui, must return the dimensions
     *   of the control that is relevant to the text's bounding rectangle.
     * - `Ctrl.Move` must resize the portion of the control that is relevant to the text's bounding
     *   rectangle.
     *
     * Invalid control types: DateTime, DropDownList, GroupBox, Hotkey, ListBox, ListView, MonthCal,
     * Picture, Progress, Slider, Tab, Tab2, Tab3, TreeView, and UpDown.
     *
     * Valid control types: ActiveX (possibly), Button, CheckBox, ComboBox, Custom (possibly), Edit,
     * Radio, Text.
     *
     * {@link Display_ControlFitText} returns the width (`OutWidth`) and height (`OutHeight`) for a
     * control to fit its text contents, plus any additional padding.
     *
     * @param {dGui.Control|Gui.Control} Ctrl - The control object.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * {@link Display_ControlFitText.TextExtentPadding}. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of  {@link Display_Size} objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
     * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutWidth` and `OutHeight`. If false, the calculations are performed
     * without moving the control.
     */
    static Call(Ctrl, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutWidth?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(RegExReplace(Ctrl.Text, '\R', '`n'), '`n')
        context := SelectFontIntoDc(Ctrl.Hwnd)
        hdc := context.Hdc
        _Proc()
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
        OutWidth += PaddingX + Padding.W
        for sz in OutExtentPoints {
            if sz {
                OutHeight += sz.H + Padding.LinePadding
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        OutHeight += PaddingY + Padding.H + Padding.LinePadding * OutExtentPoints.Length
        if MoveControl {
            Ctrl.Move(, , OutWidth, OutHeight)
        }

        return

        _Proc() {
            local sz
            OutWidth := 0
            for Str in OutExtentPoints {
                if Str {
                    if DllCall('Gdi32.dll\GetTextExtentPoint32'
                        , 'Ptr', hdc
                        , 'Ptr', StrPtr(Str)
                        , 'Int', StrLen(Str)
                        , 'Ptr', sz := Display_Size()
                        , 'Int'
                    ) {
                        OutExtentPoints[A_Index] := sz
                        OutWidth := Max(OutWidth, sz.W)
                    } else {
                        throw OSError()
                    }
                }
            }
        }
    }

    /**
     * @description - {@link Display_ControlFitText.MaxWidth} resizes a control to fit the text contents of the
     * control plus any additional padding while limiting the width of the control to a maximum value.
     * Note that {@link Display_ControlFitText.MaxWidth} does not include the width value when calling `Ctrl.Move`;
     * it is assumed your code has handled setting the width.
     *
     * @param {dGui.Control} Ctrl - The control object. See the notes in the class description above
     * {@link Display_ControlFitText} for compatibility requirements.
     * @param {Integer} [MaxWidth] - The maximum width in pixels. If unset, uses the controls current
     * width.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [UseCache = true] - If true, stores or retrieves the output from
     * {@link Display_ControlFitText.TextExtentPadding}. If false, a new instance is evaluated.
     * @param {VarRef} [OutExtentPoints] - A variable that will receive an array of  {@link Display_Size} objects
     * returned from `GetMultiExtentPoints`.
     * @param {VarRef} [OutHeight] - A variable that will receive an integer value representing the
     * height that was passed to `Ctrl.Move`.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutHeight`. If false, the calculations are performed without moving
     * the control.
     */
    static MaxWidth(Ctrl, MaxWidth?, PaddingX := 0, PaddingY := 0, UseCache := true, &OutExtentPoints?, &OutHeight?, MoveControl := true) {
        OutExtentPoints := StrSplit(RegExReplace(Ctrl.Text, '\R', '`n'), '`n')
        context := SelectFontIntoDc(Ctrl.Hwnd)
        hdc := context.Hdc
        _Proc()
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
        MaxWidth -= Padding.W + PaddingX
        OutHeight := PaddingY + Padding.H
        for sz in OutExtentPoints {
            if sz {
                lines := Ceil(sz.W / MaxWidth)
                OutHeight += (sz.H + Padding.LinePadding) * lines
            } else {
                OutHeight += Padding.LineHeight
            }
        }
        if MoveControl {
            Ctrl.Move(, , , OutHeight)
        }

        return

        _Proc() {
            local sz
            OutWidth := 0
            for Str in OutExtentPoints {
                if Str {
                    if DllCall('Gdi32.dll\GetTextExtentPoint32'
                        , 'Ptr', hdc
                        , 'Ptr', StrPtr(Str)
                        , 'Int', StrLen(Str)
                        , 'Ptr', sz := Display_Size()
                        , 'Int'
                    ) {
                        OutExtentPoints[A_Index] := sz
                        OutWidth := Max(OutWidth, sz.W)
                    } else {
                        throw OSError()
                    }
                }
            }
        }
    }

    class TextExtentPadding {
        /**
         * An instance of {@link Display_ControlFitText.TextExtentPadding} has four properties:
         * - {@link Display_ControlFitText.TextExtentPadding#W} - The padding added to the text's extent
         * along the X axis.
         * - {@link Display_ControlFitText.TextExtentPadding#H} - The padding added to the text's extent
         * along the Y axis, not including the padding added for each individual line.
         * - {@link Display_ControlFitText.TextExtentPadding#LinePadding} - The padding added to the text's
         * extent along the Y axis for each individual line.
         * - {@link Display_ControlFitText.TextExtentPadding#LineHeight} - The approximate height of an
         * blank line.
         *
         * The values of each property are approximations. See the description above
         * {@link Display_ControlFitText} for more details and limitations.
         * @class
         *
         * @param {dGui.Control} Ctrl - The control object.
         * @param {String} [Opt = ""] - Options to pass to `Gui.Prototype.Add`.
         * @param {Integer} [ThreadDpiAwarenessContext] - If set, {@link Display_ControlFitText.TextExtentPadding.__New}
         * calls `SetThreadDpiAwarenessContext` at the beginning, and calls it again before returning
         * to set the thread's context to its original value.
         */
        __New(Ctrl, Opt := '', ThreadDpiAwarenessContext?) {
            if IsSet(ThreadDpiAwarenessContext) {
                originalContext := DllCall('SetThreadDpiAwarenessContext', 'ptr', ThreadDpiAwarenessContext, 'ptr')
            }
            lf := Display_Logfont(Ctrl.Hwnd)
            G := Gui()
            fontOpt := 's' lf.FontSize ' w' lf.Weight
            if lf.Quality {
                fontOpt .= ' q' lf.Quality
            }
            if lf.Italic {
                fontOpt .= ' italic'
            }
            if lf.StrikeOut {
                fontOpt .= ' strike'
            }
            if lf.Underline {
                fontOpt .= ' underline'
            }
            G.SetFont(fontOpt, lf.FaceName)
            _ctrl := G.Add(Ctrl.Type, Opt, 'line')
            _ctrl.GetPos(, , , &h)
            _ctrl2 := G.Add(Ctrl.Type, Opt, 'line`r`nline')
            _ctrl2.GetPos(, , &w2, &h2)
            sz := _Proc(_ctrl)
            sz2 := _Proc(_ctrl2)
            G.Destroy()
            this.W := w2 - sz2.W
            this.H := h - sz.H
            this.LinePadding := h2 - sz2.H - h + sz.H
            this.LineHeight := (h2 - this.H) / 2
            if IsSet(originalContext) {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', originalContext, 'ptr')
            }

            return

            _Proc(Ctrl) {
                local sz, h, w
                W := H := 0

                lines := StrSplit(RegExReplace(Ctrl.Text, '\R', '`n'), '`n')
                context := SelectFontIntoDc(Ctrl.Hwnd)
                for line in lines {
                    if line {
                        if DllCall('Gdi32.dll\GetTextExtentPoint32', 'Ptr', context.hdc, 'Ptr', StrPtr(line), 'Int', StrLen(line), 'Ptr', sz := Display_Size(), 'Int') {
                            H += sz.H
                            W := Max(W, sz.W)
                            lines[A_Index] := sz

                        } else {
                            context()
                            throw OSError()
                        }
                    }
                }
                context()
                return { H: H, Lines: Lines, W: W }
            }
        }
    }

    class TextExtentPaddingCollection extends Map {
    }
}
