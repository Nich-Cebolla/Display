
; This contains a lot of values related to this library but that are not used directly by this library.

; ComboBox -----------------------------------------------------------------------------------------

CB_GETEDITSEL := 0x0140
CB_LIMITTEXT := 0x0141
CB_SETEDITSEL := 0x0142
CB_ADDSTRING := 0x0143
CB_DELETESTRING := 0x0144
CB_DIR := 0x0145
CB_GETCOUNT := 0x0146
CB_GETCURSEL := 0x0147
CB_GETLBTEXT := 0x0148
CB_GETLBTEXTLEN := 0x0149
CB_INSERTSTRING := 0x014A
CB_RESETCONTENT := 0x014B
CB_FINDSTRING := 0x014C
CB_SELECTSTRING := 0x014D
CB_SETCURSEL := 0x014E
CB_SHOWDROPDOWN := 0x014F
CB_GETITEMDATA := 0x0150
CB_SETITEMDATA := 0x0151
CB_GETDROPPEDCONTROLRECT := 0x0152
CB_SETITEMHEIGHT := 0x0153
CB_GETITEMHEIGHT := 0x0154
CB_SETEXTENDEDUI := 0x0155
CB_GETEXTENDEDUI := 0x0156
CB_GETDROPPEDSTATE := 0x0157
CB_FINDSTRINGEXACT := 0x0158
CB_SETLOCALE := 0x0159
CB_GETLOCALE := 0x015A
CB_GETTOPINDEX := 0x015b
CB_SETTOPINDEX := 0x015c
CB_GETHORIZONTALEXTENT := 0x015d
CB_SETHORIZONTALEXTENT := 0x015e
CB_GETDROPPEDWIDTH := 0x015f
CB_SETDROPPEDWIDTH := 0x0160
CB_INITSTORAGE := 0x0161
CB_SETMINVISIBLE := 0x1701

; winuser.h
CBS_SIMPLE := 0x0001
CBS_DROPDOWN := 0x0002
CBS_DROPDOWNLIST := 0x0003
CBS_OWNERDRAWFIXED := 0x0010
CBS_OWNERDRAWVARIABLE := 0x0020
CBS_AUTOHSCROLL := 0x0040
CBS_OEMCONVERT := 0x0080
CBS_SORT := 0x0100
CBS_HASSTRINGS := 0x0200
CBS_NOINTEGRALHEIGHT := 0x0400
CBS_DISABLENOSCROLL := 0x0800
CBS_UPPERCASE := 0x2000
CBS_LOWERCASE := 0x4000

; Dpi ----------------------------------------------------------------------------------------------

DPI_AWARENESS_INVALID := -1,
DPI_AWARENESS_UNAWARE := 0,
DPI_AWARENESS_SYSTEM_AWARE := 1,
DPI_AWARENESS_PER_MONITOR_AWARE := 2

PROCESS_DPI_UNAWARE := 0,
PROCESS_SYSTEM_DPI_AWARE := 1,
PROCESS_PER_MONITOR_DPI_AWARE := 2

; https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged
WM_DPICHANGED := 0x02E0

; https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged-beforeparent
WM_DPICHANGED_BEFOREPARENT := 0x02E2

; https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged-afterparent
WM_DPICHANGED_AFTERPARENT := 0x02E3

; https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-getdpiscaledsize
WM_GETDPISCALEDSIZE := 0x02E4

; https://learn.microsoft.com/en-us/windows/win32/gdi/wm-setredraw
WM_SETREDRAW := 0x000B

DPI_AWARENESS_CONTEXT_UNAWARE := -1
DPI_AWARENESS_CONTEXT_SYSTEM_AWARE := -2
DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE := -3
DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 := -4
DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED := -5


MDT_EFFECTIVE_DPI := 0
MDT_ANGULAR_DPI := 1
MDT_RAW_DPI := 2
MDT_DEFAULT := MDT_EFFECTIVE_DPI

; Scrollbar ----------------------------------------------------------------------------------------

MK_SHIFT := 0x0004
WM_MOUSEWHEEL := 0x020A
WM_MOUSEHWHEEL := 0x020E
WM_NCHITTEST := 0x0084
WM_VSCROLL := 0x0115
WM_HSCROLL := 0x0114

SB_HORZ := 0
SB_VERT := 1
SB_CTL := 2
SB_BOTH := 3

SW_ERASE := 0x0004
SW_INVALIDATE := 0x0002
SW_SCROLLCHILDREN := 0x0001
SW_SMOOTHSCROLL := 0x0010

SB_LINEUP := 0
SB_LINELEFT := 0
SB_LINEDOWN := 1
SB_LINERIGHT := 1
SB_PAGEUP := 2
SB_PAGELEFT := 2
SB_PAGEDOWN := 3
SB_PAGERIGHT := 3
SB_THUMBPOSITION := 4
SB_THUMBTRACK := 5
SB_TOP := 6
SB_LEFT := 6
SB_BOTTOM := 7
SB_RIGHT := 7
SB_ENDSCROLL := 8

ESB_ENABLE_BOTH := 0x0000
ESB_DISABLE_BOTH := 0x0003
ESB_DISABLE_LEFT := 0x0001
ESB_DISABLE_RIGHT := 0x0002
ESB_DISABLE_UP := 0x0001
ESB_DISABLE_DOWN := 0x0002

SIF_RANGE := 0x0001
SIF_PAGE := 0x0002
SIF_POS := 0x0004
SIF_DISABLENOSCROLL := 0x0008
SIF_TRACKPOS := 0x0010
SIF_ALL := SIF_RANGE | SIF_PAGE | SIF_POS | SIF_TRACKPOS

; Tab ----------------------------------------------------------------------------------------------

TCM_FIRST := 0x1300

TCM_ADJUSTRECT := TCM_FIRST + 40
TCM_DELETEALLITEMS := TCM_FIRST + 9
TCM_DESELECTALL := TCM_FIRST + 50
TCM_GETCURFOCUS := TCM_FIRST + 47
TCM_GETCURSEL := TCM_FIRST + 11
TCM_GETEXTENDEDSTYLE := TCM_FIRST + 53
TCM_GETIMAGELIST := TCM_FIRST + 2
TCM_GETITEMW := TCM_FIRST + 60
TCM_GETITEMCOUNT := TCM_FIRST + 4
TCM_GETITEMRECT := TCM_FIRST + 10
TCM_GETROWCOUNT := TCM_FIRST + 44
TCM_HIGHLIGHTITEM := TCM_FIRST + 51
TCM_HITTEST := TCM_FIRST + 13
TCM_REMOVEIMAGE := TCM_FIRST + 42
TCM_SETCURFOCUS := TCM_FIRST + 48
TCM_SETCURSEL := TCM_FIRST + 12
TCM_SETEXTENDEDSTYLE := TCM_FIRST + 52
TCM_SETIMAGELIST := TCM_FIRST + 3
TCM_SETITEMW := TCM_FIRST + 61
TCM_SETITEMSIZE := TCM_FIRST + 41
TCM_SETMINTABWIDTH := TCM_FIRST + 49

TCS_EX_FLATSEPARATORS    := 0x00000001
TCS_EX_REGISTERDROP      := 0x00000002

TCIF_TEXT                := 0x0001
TCIF_IMAGE               := 0x0002
TCIF_RTLREADING          := 0x0004
TCIF_PARAM               := 0x0008
TCIF_STATE               := 0x0010

TCIS_BUTTONPRESSED       := 0x0001
TCIS_HIGHLIGHTED         := 0x0002

TCM_DELETEITEM := TCM_FIRST + 8
TCM_GETITEMA := TCM_FIRST + 5
TCM_GETTOOLTIPS := TCM_FIRST + 45
TCM_INSERTITEM := TCM_INSERTITEMW := TCM_FIRST + 62
TCM_INSERTITEMA := TCM_FIRST + 7
TCM_SETITEMA := TCM_FIRST + 6
TCM_SETITEMEXTRA := TCM_FIRST + 14
TCM_SETPADDING := TCM_FIRST + 43
TCM_SETTOOLTIPS := TCM_FIRST + 46

TCHT_NOWHERE := 0x0001
TCHT_ONITEMICON := 0x0002
TCHT_ONITEMLABEL := 0x0004
TCHT_ONITEM := TCHT_ONITEMICON | TCHT_ONITEMLABEL

; Various width whitespace characters that can be used to offset text ------------------------------

SPACE_CHAR_START := 0x2000
SPACE_CHAR_END := 0x200B
EN_QUAD := Chr(0x2000)
EM_QUAD := Chr(0x2001)
EN := Chr(0x2002)
EM := Chr(0x2003)
THREE_PER_EM := Chr(0x2004)
FOUR_PER_EM := Chr(0x2005)
SIX_PER_EM := Chr(0x2006)
FIGURE := Chr(0x2007)
PUNCTUATION := Chr(0x2008)
THIN := Chr(0x2009)
HAIR := Chr(0x200A)
ZERO_WIDTH := Chr(0x200B)

; Windows ------------------------------------------------------------------------------------------

SW_HIDE := 0            ; Hides the window and activates another window.

SW_SHOWNORMAL :=        ; Activates and displays a window. If the window is minimized, maximized,
SW_NORMAL := 1          ; or arranged, the system restores it to its original size and position.
                        ; An application should specify this flag when displaying the window for the
                        ; first time.


SW_SHOWMINIMIZED := 2   ; Activates the window and displays it as a minimized window.

SW_MAXIMIZE :=          ; Activates the window and displays it as a maximized window.
SW_SHOWMAXIMIZED := 3

SW_SHOWNOACTIVATE := 4  ; Displays a window in its most recent size and position. This value is
                        ; similar to SW_SHOWNORMAL, except that the window is not activated.

SW_SHOW := 5            ; Activates the window and displays it in its current size and position.

SW_MINIMIZE := 6        ; Minimizes the specified window and activates the next top-level window in
                        ; the Z order.

SW_SHOWMINNOACTIVE :=   ; Displays the window as a minimized window. This value is similar to
SW_SHOWMINIMIZED := 7   ; except the window is not activated.

SW_SHOWNA :=            ; Displays the window in its current size and position. This value is similar to
SW_SHOW := 8            ; except that the window is not activated.

SW_RESTORE := 9         ; Activates and displays the window. If the window is minimized, maximized,
                        ; or arranged, the system restores it to its original size and position. An
                        ; application should specify this flag when restoring a minimized window.

SW_SHOWDEFAULT := 10    ; Sets the show state based on the SW_ value specified in the STARTUPINFO
                        ; structure passed to the CreateProcess function by the program that started
                        ; the application.

SW_FORCEMINIMIZE := 11  ; Minimizes a window, even if the thread that owns the window is not
                        ; responding. This flag should only be used when minimizing windows from a
                        ; different thread.


CWP_ALL := 0x0000               ; Does not skip any child windows
CWP_SKIPDISABLED := 0x0002      ; Skips disabled child windows
CWP_SKIPINVISIBLE := 0x0001     ; Skips invisible child windows
CWP_SKIPTRANSPARENT := 0x0004   ; Skips transparent child windows
