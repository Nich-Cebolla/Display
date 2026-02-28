
/**
 * @description - Calls {@link https://www.autohotkey.com/docs/v2/lib/OnMessage.htm OnMessage} to
 * set the `WM_DPICHANGED` message handler.
 * @param {*} Callback - A `Func` or callable object that will be called when
 * a {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm Gui} or {@link dGui} window receives
 * `WM_DPICHANGED`. See {@link https://www.autohotkey.com/docs/v2/lib/OnMessage.htm OnMessage} for
 * information about how to define the function.
 * @param {Integer} [MaxThreads = 1] - The value to pass to the `MaxThreads` parameter of
 * {@link https://www.autohotkey.com/docs/v2/lib/OnMessage.htm OnMessage}.
 */
Display_OnDpiChanged(Callback, MaxThreads := 1) {
    OnMessage(0x02E0, Callback, MaxThreads) ; WM_DPICHANGED
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-aredpiawarenesscontextsequal AreDpiAwarenessContextsEqual}.
 * @param {Integer} dpiContextA - The first value to compare.
 * @param {Integer} [dpiContextB] - The second value to compare. If unset, uses the return value
 * from {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getthreaddpiawarenesscontext GetThreadDpiAwarenessContext}.
 * @returns {Boolean} - `1` if true, else `0`.
 */
AreDpiAwarenessContextsEqual(dpiContextA, dpiContextB?) {
    return DllCall(g_user32_AreDpiAwarenessContextsEqual, 'ptr', dpiContextA, 'ptr', dpiContextB ?? DllCall(g_user32_GetThreadDpiAwarenessContext, 'ptr'), 'int')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getawarenessfromdpiawarenesscontext GetAwarenessFromDpiAwarenessContext}.
 * @param {Integer} value - The DPI_AWARENESS_CONTEXT.
 * @returns {Integer}
 */
GetAwarenessFromDpiAwarenessContext(value) {
    return DllCall(g_user32_GetAwarenessFromDpiAwarenessContext, 'ptr', value, 'int')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiawarenesscontextforprocess GetDpiAwarenessContextForProcess}.
 * @param {Integer} [hProcess = 0] - A handle to the process for which the DPI_AWARENESS_CONTEXT is
 * retrieved. If 0, the context is retrieved for the current process.
 * @returns {Integer} - The DPI_AWARENESS_CONTEXT for the specified process.
 */
GetDpiAwarenessContextForProcess(hProcess := 0) {
    return DllCall(g_user32_GetDpiAwarenessContextForProcess, 'ptr', hProcess, 'ptr')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-getdpiformonitor GetDpiForMonitor}.
 * @param {Integer} hMonitor - The handle of the monitor being queried.
 * @param {Integer} [DpiType = 0] - The type of DPI being queried. Possible values are from the
 * MONITOR_DPI_TYPE (MDT) enumeration. The default is MDT_DEFAULT (0).
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/ne-shellscalingapi-monitor_dpi_type}
 * @returns {Integer} - If succesful, the dpi for the monitor.
 * @throws {OSError} - If `GetDpiForMonitor` fails.
 */
GetDpiForMonitor(hMonitor, DpiType := 0) {
    if DllCall(g_shcore_GetProcessDpiAwareness, 'ptr', hMonitor, 'ptr', DpiType, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
        throw OSError()
    } else {
        return DpiX
    }
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforsystem GetDpiForSystem}.
 * @returns {Integer} - The dpi value.
 */
GetDpiForSystem() {
    return DllCall(g_user32_GetDpiForSystem, 'uint')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow GetDpiForWindow}.
 * @param {Integer} Hwnd - The window handle.
 * @returns {Integer} - The dpi value.
 */
GetDpiForWindow(Hwnd) {
    return DllCall(g_user32_GetDpiForWindow, 'ptr', Hwnd, 'uint')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpifromdpiawarenesscontext GetDpiFromDpiAwarenessContext}.
 * @param {Integer} value - The DPI_AWARENESS_CONTEXT.
 * @returns {Integer} - The dpi value.
 */
GetDpiFromDpiAwarenessContext(value) {
    return DllCall(g_user32_GetDpiFromDpiAwarenessContext, 'ptr', value, 'uint')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-getprocessdpiawareness}.
 * @param {IntegeR} [hProcess = 0] - Handle of the process that is being queried. If this parameter is
 * 0, the current process is queried.
 * @param {VarRef} [OutValue] - A variable that will receive the process dpi awareness.
 * @returns {Integer} - One of the following:
 * - S_OK (0) - The function successfully retrieved the DPI awareness of the specified process.
 * - E_INVALIDARG (0x80070057) - The handle or pointer passed in is not valid.
 * - E_ACCESSDENIED (0x80070005) - The application does not have sufficient privileges.
 */
GetProcessDpiAwareness(hProcess := 0, &OutValue?) {
    return DllCall('Shcore\GetProcessDpiAwareness', 'ptr', hProcess, 'int*', &OutValue := 0, 'int')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemdpiforprocess GetSystemDpiForProcess}.
 * @param {Integer} [hProcess = 0] - The handle to the process. If 0, this function retrieves the dpi
 * for the system.
 * @returns {Integer} - The dpi value.
 */
GetSystemDpiForProcess(hProcess := 0) {
    return DllCall(g_user32_GetSystemDpiForProcess, 'ptr', hProcess, 'uint')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetricsfordpi GetSystemMetricsForDpi}.
 * @param {Integer} index - A value from
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics}.
 * @param {Integer} dpi - The dpi to use to scale the returned metric.
 * @return {Integer}
 */
GetSystemMetricsForDpi(index, dpi?) {
    return DllCall(g_user32_GetSystemMetricsForDpi, 'int', index, 'uint', dpi, 'int')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getthreaddpiawarenesscontext GetThreadDpiAwarenessContext}.
 * @returns {Integer} -  The thread's DPI_AWARENESS_CONTEXT.
 */
GetThreadDpiAwarenessContext() {
    return DllCall(g_user32_GetThreadDpiAwarenessContext, 'ptr')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getthreaddpihostingbehavior GetThreadDpiHostingBehavior}.
 * @returns {Integer} - A value from the
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ne-windef-dpi_hosting_behavior DPI_HOSTING_BEHAVIOR enumeration}.
 */
GetThreadDpiHostingBehavior() {
    return DllCall(g_user32_GetThreadDpiHostingBehavior, 'ptr')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowdpiawarenesscontext GetWindowDpiAwarenessContext}.
 * @param {Integer} Hwnd - The window handle.
 * @returns {Integer} - The window's DPI_AWARENESS_CONTEXT.
 */
GetWindowDpiAwarenessContext(Hwnd) {
    return DllCall(g_user32_GetWindowDpiAwarenessContext, 'ptr', Hwnd, 'ptr')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowdpihostingbehavior GetWindowDpiHostingBehavior}.
 * @param {Integer} hwnd - The window handle.
 * @returns {Integer} - A value from the
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ne-windef-dpi_hosting_behavior DPI_HOSTING_BEHAVIOR enumeration}.
 */
GetWindowDpiHostingBehavior(hwnd) {
    return DllCall(g_user32_GetWindowDpiHostingBehavior, 'ptr', hwnd, 'ptr')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-isvaliddpiawarenesscontext IsValidDpiAwarenessContext}.
 * @param {Integer} value - The DPI_AWARENESS_CONTEXT.
 * @returns {Boolean} - If `value` is valid, returns `1`. Else, `0`.
 */
IsValidDpiAwarenessContext(value) {
    return DllCall(g_user32_IsValidDpiAwarenessContext, 'ptr', value, 'int')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpiawarenesscontext SetThreadDpiAwarenessContext}.
 * @param {Integer} value - The DPI_AWARENESS_CONTEXT. See
 * {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context}.
 * @returns {Integer} - If `value` is valid, returns the current setting. Else,
 * returns `0`.
 */
SetThreadDpiAwarenessContext(value) {
    return DllCall(g_user32_SetThreadDpiAwarenessContext, 'ptr', value, 'ptr')
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpiawarenesscontext SetThreadDpiAwarenessContext}.
 * @param {Integer} value - The DPI_AWARENESS_CONTEXT. See
 * {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context}.
 * @returns {Integer} - If `value` is valid, returns the current setting.
 * @throws {ValueError} - "Invalid DPI_AWARENESS_CONTEXT."
 */
SetThreadDpiAwarenessContext2(value) {
    if DllCall(g_user32_IsValidDpiAwarenessContext, 'ptr', value, 'int') {
        return DllCall(g_user32_SetThreadDpiAwarenessContext, 'ptr', value, 'ptr')
    } else {
        throw ValueError('Invalid DPI_AWARENESS_CONTEXT.')
    }
}
/**
 * @description - Calls
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpihostingbehavior SetThreadDpiHostingBehavior}.
 * @param {Integer} value - A value from the
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/windef/ne-windef-dpi_hosting_behavior DPI_HOSTING_BEHAVIOR enumeration}.
 * @returns {Integer} - The previous DPI_HOSTING_BEHAVIOR.
 */
SetThreadDpiHostingBehavior(value) {
    return DllCall(g_user32_SetThreadDpiHostingBehavior, 'ptr', value, 'ptr')
}

Display_Dpi_SetConstants(force := false) {
    global
    if IsSet(Display_Dpi_constants_set) {
        if !force {
            return
        }
    } else {
        g_user32_AreDpiAwarenessContextsEqual :=
        g_user32_GetAwarenessFromDpiAwarenessContext :=
        g_user32_GetDpiAwarenessContextForProcess :=
        g_user32_GetDpiForSystem :=
        g_user32_GetDpiForWindow :=
        g_user32_GetDpiFromDpiAwarenessContext :=
        g_user32_GetSystemDpiForProcess :=
        g_user32_GetSystemMetricsForDpi :=
        g_user32_GetThreadDpiAwarenessContext :=
        g_user32_GetThreadDpiHostingBehavior :=
        g_user32_GetWindowDpiAwarenessContext :=
        g_user32_GetWindowDpiHostingBehavior :=
        g_user32_IsValidDpiAwarenessContext :=
        g_user32_SetThreadDpiAwarenessContext :=
        g_user32_SetThreadDpiHostingBehavior :=
        g_shcore_GetProcessDpiAwareness := 0
    }
    Display_Dpi_LibraryToken := LibraryManager(
        'user32', [
            'AreDpiAwarenessContextsEqual',
            'GetAwarenessFromDpiAwarenessContext',
            'GetDpiAwarenessContextForProcess',
            'GetDpiForSystem',
            'GetDpiForWindow',
            'GetDpiFromDpiAwarenessContext',
            'GetSystemDpiForProcess',
            'GetSystemMetricsForDpi',
            'GetThreadDpiAwarenessContext',
            'GetThreadDpiHostingBehavior',
            'GetWindowDpiAwarenessContext',
            'GetWindowDpiHostingBehavior',
            'IsValidDpiAwarenessContext',
            'SetThreadDpiAwarenessContext',
            'SetThreadDpiHostingBehavior'
        ],
        'shcore', [
            'GetProcessDpiAwareness'
        ]
    )
    Display_Dpi_constants_set := true
}
