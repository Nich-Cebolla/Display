
#include SelectFontIntoDc.ahk
#include ..\struct
#include Display_Logfont.ahk
#include Display_Size.ahk

class ControlFitText {
    /**
     * @description -  - Resizes a control according to its text content.
     *
     * {@link ControlFitText.TextExtentPadding} approximates the padding added to a control's
     * area that displays the text.
     *
     * Not all controls are compatible with {@link ControlFitText}.
     *
     * Invalid control types: DateTime, DropDownList, GroupBox, Hotkey, ListBox, ListView, MonthCal,
     * Picture, Progress, Slider, Tab, Tab2, Tab3, TreeView, and UpDown.
     *
     * Valid control types: ActiveX (possibly), Button, CheckBox, ComboBox, Custom (possibly), Edit,
     * Radio, Text.
     *
     * @param {dGui.Control|Gui.Control} Ctrl - The control object.
     * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
     * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
     * @param {Boolean} [MoveControl = true] - If true, the `Gui.Control.Prototype.Move` will be
     * called for `Ctrl` using `OutWidth` and `OutHeight`. If false, the calculations are performed
     * without moving the control.
     * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
     * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
     */
    static Call(Ctrl, PaddingX := 0, PaddingY := 0, MoveControl := true, &OutWidth?, &OutHeight?) {
        sz := Display_Size()
        context := SelectFontIntoDc(Ctrl.Hwnd)
        if InStr(Ctrl.Text, '`r`n') {
            OutWidth := OutHeight := 0
            hdc := context.hdc
            padding := ControlFitText.TextExtentPadding(Ctrl)
            for line in StrSplit(Ctrl.Text, '`r`n') {
                if line {
                    if DllCall(
                        'Gdi32.dll\GetTextExtentPoint32'
                      , 'ptr', hdc
                      , 'ptr', StrPtr(line)
                      , 'int', StrLen(line)
                      , 'ptr', sz
                      , 'int'
                    ) {
                        OutHeight += sz.H + padding.LinePadding
                        OutWidth := Max(OutWidth, sz.W)
                    } else {
                        context()
                        throw OSError()
                    }
                } else {
                    OutHeight += padding.LineHeight + padding.LinePadding
                }
            }
            OutHeight -= padding.LinePadding
        } else {
            if DllCall(
                'Gdi32.dll\GetTextExtentPoint32'
              , 'ptr', context.hdc
              , 'wstr', Ctrl.Text
              , 'int', StrLen(Ctrl.Text)
              , 'ptr', sz
              , 'int'
            ) {
                OutHeight := sz.H
                OutWidth := sz.W
            } else {
                context()
                throw OSError()
            }
        }
        context()
        OutWidth += PaddingX + padding.W
        OutHeight += PaddingY + padding.H
        if MoveControl {
            Ctrl.Move(, , OutWidth, OutHeight)
        }
    }

    class TextExtentPadding {
        /**
         * @description - An instance of {@link ControlFitText.TextExtentPadding} has four
         * properties:
         * - {@link ControlFitText.TextExtentPadding#W} - The padding added to the text's
         *   extent along the X axis.
         * - {@link ControlFitText.TextExtentPadding#H} - The padding added to the text's
         *   extent along the Y axis, not including the padding added for each individual line.
         * - {@link ControlFitText.TextExtentPadding#LinePadding} - The padding added to the
         *   text's extent along the Y axis for each individual line.
         * - {@link ControlFitText.TextExtentPadding#LineHeight} - The height of one line.
         *
         * The values of each property are approximations. See the description above
         * {@link ControlFitText} for more details and limitations.
         * @class
         *
         * @param {dGui.Control|Gui.Control} Ctrl - The control object.
         * @param {String} [Options = ""] - Options to pass to `Gui.Prototype.Add`.
         */
        __New(Ctrl, Options := '') {
            g := Gui()
            lf := Display_Logfont(Ctrl.Hwnd)
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
            g.SetFont(fontOpt, lf.FaceName)
            g.Add(Ctrl.Type, Options, 'line').GetPos(, , &w1, &h1)
            g.Add(Ctrl.Type, Options, 'line`r`nline').GetPos(, , , &h2)
            context := SelectFontIntoDc(Ctrl.Hwnd)
            sz := Display_Size()
            DllCall('Gdi32.dll\GetTextExtentPoint32', 'ptr', context.hdc, 'wstr', 'line', 'int', 4, 'ptr', sz, 'int')
            context()
            g.Destroy()
            this.W := w1 - sz.W
            this.H := h1 - sz.H
            this.LinePadding := h2 - sz.H * 2 - this.H
            this.LineHeight := sz.H
        }
    }
}
