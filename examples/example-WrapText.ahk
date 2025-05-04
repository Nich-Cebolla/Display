
#SingleInstance force
#include ..\lib\Text.ahk

; Using `WrapText` is easy.
; Let's set up an example Gui

G := Gui('+resize')
G.setfont('s11 q5', 'aptos')
txt := G.Add('Text', 'w300')
txt.getpos(&x1, &y1, &w1, &h1) ; just for demonstration
g.show()

; Get our string
str := 'This parameter may include backreferences like $1, which brings in the substring from Haystack that matched the first subpattern. The simplest backreferences are $0 through $9, where $0 is the substring that matched the entire pattern, $1 is the substring that matched the first subpattern, $2 is the second, and so on. For backreferences greater than 9 (and optionally those less than or equal to 9), enclose the number in braces; e.g. ${10}, ${11}, and so on. For named subpatterns, enclose the name in braces; e.g. ${SubpatternName}. To specify a literal $, use $$ (this is the only character that needs such special treatment; backslashes are never needed to escape anything).'
; Source of text: https://www.autohotkey.com/docs/v2/lib/RegExReplace.htm

; We should always insert soft hyphens first, unless the text already has them or the text
; is not mostly English words.
InsertSoftHyphens(&str)

; Either use a config object, or pass an object literal. I like using a config object.
; When using a Gui.Control object for the context, `WrapText` will use the current width
; of the control as the maximum unless your options object specifies a `MaxExtent` value.
; In this example, we let `WrapText` use the control's width (300) as the maximum.
class dWrapTextConfig {
    static AdjustObject := true
    , MeasureLines := true
}

; Call the function. Live code should call this in a try-catch block.
try {
    LineCount := WrapText(txt, &str, , &Width, &Height)
    ; `WrapText` will only adjust the control, not the gui
    ; To correctly size the gui, we need to know the size of the non-client area of the gui.
    ; These next three lines aren't specific to `WrapText`, but just dealing with the non-client
    ; area of a Gui window in general.
    G.GetPos(, , , &g_h)
    G.GetClientPos(, , , &g_h2)
    diff := g_h - g_h2
    G.Move(, , Width, Height + diff) ; add on the height of the string + the non-client area
} catch OSError {
    ; handle
} catch ValueError {
    ; handle
} catch Error {
    ; handle
}

; Not part of calling `WrapText`. This is just to see some information about the dimensions before
; and after
txt.getpos(&x2, &y2, &w2, &h2)
G.AddText('x10 y' (Height + G.MarginY * 2) ' w300', (
    Format('x1: {}; y1: {}; w1: {}; h1: {}', x1, y1, w1, h1)
    '`r`n' Format('x2: {}; y2: {}; w2: {}; h2: {}', x2, y2, w2, h2)
    '`r`nWidth: ' width '`r`nHeight: ' height '`r`nLine count: ' LineCount
)).GetPos(, &y3, , &h3)
G.Move(, , , y3 + h3 + diff)
