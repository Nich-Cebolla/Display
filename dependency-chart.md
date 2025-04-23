

### ____.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

## Dependency chart

Definition files are #Included where needed, so you don't need to worry about those.

This only shows primary dependencies.

### lib\Display_ComboBox.ahk

- definitions\Display_Define_ComboBox.ahk

### lib\Display_Dpi.ahk

- definitions\Display_Define_Dpi.ahk

### lib\Display_Gui.ahk
- src\Display_dWin.ahk
- src\Display_dGui.ahk

### lib\Display_Lib.ahk
- Definitions:             --
- Structs:                 Rect
- Source:                  dWin
- Lib:                     --

### lib\Display_SetThreadDpiAwareness__Call.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --
Note: It requires the globalvariable `DPI_AWARENESS_CONTEXT_DEFAULT`to be set.

### src\Display_Gui.ahk
- Definitions:             --
- Structs:                 LOGFONT
                           Rect
- Source:                  Display_DefaultConfig
                           dMon
- Lib:                     Display_SetThreadDpiAwareness__Call
                           Display_Gui

### Display_Lv.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

### Display_Mon.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
                           RectBase
- Classes:                 --
- Lib:                     --

### Display_Scrollbar.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
- Source:                  dWin
- Lib:                     --

### Display_Text.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
- Source:                  dWin
- Lib:                     --

### Display_Win.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
                           RectBase
- Source:                  dMon
- Lib:                     --

### Display_LOGFONT.ahk
- Definitions:             --
- Structs:                 Point
- Classes:                 --
- Lib:                     --

### Display_NumberArray.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

### Display_Point.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

### Display_Rect.ahk
- Definitions:             --
- Structs:                 RectBase
- Classes:                 --
- Lib:                     --

### Display_RectBase.ahk
- Definitions:             --
- Structs:                 Point
- Classes:                 --
- Lib:                     Display_SetThreadDpiAwareness__Call

### Display_WINDOWINFO.ahk
- Definitions:             --
- Structs:                 Rect
- Classes:                 --
- Lib:                     --
