MDT_EFFECTIVE_DPI := 0
MDT_ANGULAR_DPI := 1
MDT_RAW_DPI := 2
MDT_DEFAULT := MDT_EFFECTIVE_DPI

DPI_AWARENESS_INVALID := -1,
DPI_AWARENESS_UNAWARE := 0,
DPI_AWARENESS_SYSTEM_AWARE := 1,
DPI_AWARENESS_PER_MONITOR_AWARE := 2

PROCESS_DPI_UNAWARE := 0,
PROCESS_SYSTEM_DPI_AWARE := 1,
PROCESS_PER_MONITOR_DPI_AWARE := 2

/** {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged} */
WM_DPICHANGED := 0x02E0
/** {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged-beforeparent} */
WM_DPICHANGED_BEFOREPARENT := 0x02E2
/** {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged-afterparent} */
WM_DPICHANGED_AFTERPARENT := 0x02E3
/** {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-getdpiscaledsize} */
WM_GETDPISCALEDSIZE := 0x02E4

DPI_AWARENESS_CONTEXT_UNAWARE := -1
DPI_AWARENESS_CONTEXT_SYSTEM_AWARE := -2
DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE := -3
DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 := -4
DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED := -5
DPI_AWARENESS_CONTEXT_DEFAULT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2


SW_HIDE := 0 ; Hides the window and activates another window.
SW_NORMAL := SW_SHOWNORMAL := 1 ; Activates and displays a window. If the window is minimized, maximized, or arranged,
; the system restores it to its original size and position. An application should specify this flag
; when displaying the window for the first time.
SW_SHOWMINIMIZED := 2 ; Activates the window and displays it as a minimized window.
SW_MAXIMIZE := SW_SHOWMAXIMIZED := 3 ; Activates the window and displays it as a maximized window.
SW_SHOWNOACTIVATE := 4 ; Displays a window in its most recent size and position. This value is
; similar to SW_SHOWNORMAL, except that the window is not activated.
SW_SHOW := 5 ; Activates the window and displays it in its current size and position.
SW_MINIMIZE := 6 ; Minimizes the specified window and activates the next top-level window in the Z
; order.
SW_SHOWMINNOACTIVE := SW_SHOWMINIMIZED := 7 ; Displays the window as a minimized window. This value is similar to
 ; except the window is not activated.
SW_SHOWNA := SW_SHOW := 8 ; Displays the window in its current size and position. This value is similar to
; except that the window is not activated.
SW_RESTORE := 9 ; Activates and displays the window. If the window is minimized, maximized, or
; arranged, the system restores it to its original size and position. An application should specify
; this flag when restoring a minimized window.
SW_SHOWDEFAULT := 10 ; Sets the show state based on the SW_ value specified in the STARTUPINFO
; structure passed to the CreateProcess function by the program that started the application.
SW_FORCEMINIMIZE := 11 ; Minimizes a window, even if the thread that owns the window is not
; responding. This flag should only be used when minimizing windows from a different thread.

CWP_ALL := 0x0000 ; Does not skip any child windows
CWP_SKIPDISABLED := 0x0002 ; Skips disabled child windows
CWP_SKIPINVISIBLE := 0x0001 ; Skips invisible child windows
CWP_SKIPTRANSPARENT := 0x0004 ; Skips transparent child windows

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
