

### ____.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

## Dependency chart

Definition files are #included where needed, so you don't need to worry about those.

This only shows primary dependencies.

### lib\ComboBox.ahk

- definitions\define-ComboBox.ahk

### lib\Dpi.ahk

- definitions\define-Dpi.ahk

### lib\Gui.ahk
- src\dWin.ahk
- src\dGui.ahk

### lib\Lib.ahk
- Definitions:             --
- Structs:                 Rect
- Source:                  dWin
- Lib:                     --

### lib\MetaSetThreadDpiAwareness.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --
Note: It requires the globalvariable `DPI_AWARENESS_CONTEXT_DEFAULT`to be set.

### src\Gui.ahk
- Definitions:             --
- Structs:                 LOGFONT
                           Rect
- Source:                  DefaultConfig
                           dMon
- Lib:                     MetaSetThreadDpiAwareness
                           Gui

### Lv.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

### Mon.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
                           RectBase
- Classes:                 --
- Lib:                     --

### Scrollbar.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
- Source:                  dWin
- Lib:                     --

### Text.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
- Source:                  dWin
- Lib:                     --

### Win.ahk
- Definitions:             --
- Structs:                 Point
                           Rect
                           RectBase
- Source:                  dMon
- Lib:                     --

### LOGFONT.ahk
- Definitions:             --
- Structs:                 Point
- Classes:                 --
- Lib:                     --

### NumberArray.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

### Point.ahk
- Definitions:             --
- Structs:                 --
- Classes:                 --
- Lib:                     --

### Rect.ahk
- Definitions:             --
- Structs:                 RectBase
- Classes:                 --
- Lib:                     --

### RectBase.ahk
- Definitions:             --
- Structs:                 Point
- Classes:                 --
- Lib:                     MetaSetThreadDpiAwareness

### WINDOWINFO.ahk
- Definitions:             --
- Structs:                 Rect
- Classes:                 --
- Lib:                     --
