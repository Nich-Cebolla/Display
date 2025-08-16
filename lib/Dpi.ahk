
#include ..\definitions\define-Dpi.ahk

/**
 * @description - Determines whether two DPI_AWARENESS_CONTEXT values are identical. A
 * DPI_AWARENESS_CONTEXT contains multiple pieces of information. For example, it includes both the
 * current and the inherited DPI_AWARENESS values. AreDpiAwarenessContextsEqual ignores informational
 * flags and determines if the values are equal. You can't use a direct bitwise comparison because
 * of these informational flags.
 * @param {Integer} DpiContextA - The first value to compare.
 * @param {Integer} [DpiContextB] - The second value to compare. If unset, uses the return value
 * from `GetThreadDpiAwarenessContext`.
 * @returns {Boolean} - 1 if true, else 0.
 */
AreDpiAwarenessContextsEqual(DpiContextA, DpiContextB?) {
    return DllCall('AreDpiAwarenessContextsEqual', 'ptr', DpiContextA, 'ptr', DpiContextB ?? GetThreadDpiAwarenessContext(), 'uint')
}

/**
 * @description - Gets a DPI_AWARENESS_CONTEXT handle for the specified process.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiawarenesscontextforprocess}
 * @param {Integer} [hProcess=0] - A handle to the process for which the DPI awareness context is
 * retrieved. If 0, the context is retrieved for the current process.
 * @returns {Integer} - The DPI_AWARENESS_CONTEXT for the specified process.
 */
GetDpiAwarenessContextForProcess(hProcess := 0) {
    return DllCall('GetDpiAwarenessContextForProcess', 'ptr', hProcess, 'ptr')
}


/**
 * @description - A DPI_AWARENESS_CONTEXT contains multiple pieces of information. For example, it
 * includes both the current and the inherited DPI_AWARENESS. This method retrieves the DPI_AWARENESS
 * from the structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getawarenessfromdpiawarenesscontext}
 * @param {Integer} DPI_AWARENESS_CONTEXT - The `DPI_AWARENESS_CONTEXT` from which to obtain the
 * DPI_AWARENESS.
 * @returns {Integer} - The DPI_AWARENESS value.
 */
GetAwarenessFromDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
    return DllCall('GetAwarenessFromDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
}

/**
 * @description - DPI_AWARENESS_CONTEXT handles associated with values of
 * DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE and DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 will
 * return a value of 0 for their DPI. This is because the DPI of a per-monitor-aware window can
 * change, and the actual DPI cannot be returned without the window's Hwnd.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpifromdpiawarenesscontext}
 * @param {Integer} DPI_AWARENESS_CONTEXT - The DPI_AWARENESS_CONTEXT from which to obtain the
 * dpi.
 * @returns {Integer} - The dpi value.
 */
GetDpiFromDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
    return DllCall('GetDpiFromDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'uint')
}

/**
 * @description - This API is not DPI aware and should not be used if the calling thread is
 * per-monitor DPI aware. For the DPI-aware version of this API, see GetDpiForWindow. When you call
 * GetDpiForMonitor, you will receive different DPI values depending on the DPI awareness of the
 * calling application. DPI awareness is an application-level property usually defined in the
 * application manifest. For more information about DPI awareness values, see PROCESS_DPI_AWARENESS.
 * The following table indicates how the results will differ based on the PROCESS_DPI_AWARENESS
 * value of your application.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-getdpiformonitor}
 * @param {Integer} hMonitor - The handle of the monitor being queried.
 * @param {Integer} [DpiType=MDT_DEFAULT] - The type of DPI being queried. Possible values are from the
 * MONITOR_DPI_TYPE enumeration.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/ne-shellscalingapi-monitor_dpi_type}
 * @returns {Integer} - If succesful, the dpi for the monitor. If unsuccessful, an empty string.
 * An unsuccessful function call would be caused by an invalid parameter.
 */
GetDpiForMonitor(hMonitor, DpiType := MDT_DEFAULT) {
    if !DllCall('Shcore\GetDpiForMonitor', 'ptr'
    , hMonitor, 'ptr', DpiType, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'uint') {
        return DpiX
    }
}

/**
 * @description - The return value will be dependent based upon the calling context. If the current
 * thread has a DPI_AWARENESS value of DPI_AWARENESS_UNAWARE, the return value will be 96. That is
 * because the current context always assumes a DPI of 96. For any other DPI_AWARENESS value, the
 * return value will be the actual system DPI. You should not cache the system DPI, but should use
 * GetDpiForSystem whenever you need the system DPI value.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforsystem}
 * @returns {Integer} - The system DPI value.
 */
GetDpiForSystem() {
    return DllCall('GetDpiForSystem', 'uint')
}

/**
 * @description - Returns the dots per inch (dpi) value for the specified window.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow}
 * @param {Integer} Hwnd - The window handle.
 * @returns {Integer} - The DPI for the window, which depends on the DPI_AWARENESS of the window.
 * - DPI_AWARENESS_UNAWARE - The base value of DPI which is set to 96 (defined as `USER_DEFAULT_SCREEN_DPI`)
 * - DPI_AWARENESS_SYSTEM_AWARE - The system DPI
 * - DPI_AWARENESS_PER_MONITOR_AWARE - The DPI of the monitor where the window is located.
 */
GetDpiForWindow(Hwnd) {
    return DllCall('GetDpiForWindow', 'ptr', Hwnd, 'uint')
}

/**
 * @description - Retrieves the dots per inch (dpi) awareness of the specified process.
 * @param {VarRef} OutValue - A variable that will receive the PROCESS_DPI_AWARENESS.
 * @param {IntegeR} [hProcess=0] - Handle of the process that is being queried. If this parameter is
 * 0, the current process is queried.
 * @returns {Integer} - One of the following:
 * - S_OK (0) - The function successfully retrieved the DPI awareness of the specified process.
 * - E_INVALIDARG - The handle or pointer passed in is not valid.
 * - E_ACCESSDENIED - The application does not have sufficient privileges.
 */
GetProcessDpiAwareness(&OutValue, hProcess := 0) {
    return DllCall('Shcore\GetProcessDpiAwareness', 'ptr', hProcess, 'uint*', &OutValue := 0, 'uint')
}

/**
 * @description - The return value will be dependent based upon the process passed as a parameter.
 * If the specified process has a DPI_AWARENESS value of DPI_AWARENESS_UNAWARE, the return value
 * will be 96. That is because the current context always assumes a DPI of 96. For any other
 * DPI_AWARENESS value, the return value will be the actual system DPI of the given process.
 * Identical to GetAwarenessFromDpiAwarenessContext(GetThreadDpiAwarenessContext());
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemdpiforprocess}
 * @param {Integer} [hProcess=0] - The handle to the process. If 0, this function retrieves the dpi
 * for the system.
 * @returns {Integer} - The dpi value.
 */
GetSystemDpiForProcess(hProcess := 0) {
    return DllCall('GetSystemDpiForProcess', 'ptr', hProcess, 'uint')
}

/**
 * @description - This method will return the latest DPI_AWARENESS_CONTEXT sent to
 * SetThreadDpiAwarenessContext. If SetThreadDpiAwarenessContext was never called for this thread,
 * then the return value will equal the default DPI_AWARENESS_CONTEXT for the process.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getthreaddpiawarenesscontext}
 * @returns {Integer} -  The thread's DPI_AWARENESS_CONTEXT.
 */
GetThreadDpiAwarenessContext() {
    return DllCall('GetThreadDpiAwarenessContext', 'ptr')
}

/**
 * @description - Returns the DPI_AWARENESS_CONTEXT associated with a window. The return value of
 * GetWindowDpiAwarenessContext is not affected by the DPI_AWARENESS of the current thread. It only
 * indicates the context of the window specified by the Hwnd input parameter.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowdpiawarenesscontext}
 * @param {Integer} Hwnd - The window handle.
 * @returns {Integer} - The window's DPI_AWARENESS_CONTEXT.
 */
GetWindowDpiAwarenessContext(Hwnd) {
    return DllCall('GetWindowDpiAwarenessContext', 'ptr', Hwnd, 'ptr')
}

/**
 * @description - IsValidDpiAwarenessContext determines the validity of any provided
 * DPI_AWARENESS_CONTEXT. You should make sure a context is valid before using
 * SetThreadDpiAwarenessContext to that context.
 * An input value of NULL is considered to be an invalid context and will result in a return value
 * of FALSE.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-isvaliddpiawarenesscontext}
 * @param {Integer} DPI_AWARENESS_CONTEXT - The DPI_AWARENESS_CONTEXT.
 * @returns {Boolean} - 1 if valid, else 0.
 */
IsValidDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
    return DllCall('IsValidDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'uint')
}

/**
 * @description - Use this API to change the DPI_AWARENESS_CONTEXT for the thread from the default
 * value for the app. `SetThreadDpiAwarenessContext` calls `IsValidDpiAwarenessContext` prior to
 * setting the dpi awareness context. If `IsValidDpiAwarenessContext` returns false, this
 * function returns an empty string and the dpi awareness context is not changed.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpiawarenesscontext}
 * @param [DPI_AWARENESS_CONTEXT=DPI_AWARENESS_CONTEXT_DEFAULT ?? -4] - Use the `DPI_AWARENESS_CONTEXT_DEFAULT`
 * global variable to define the default `DPI_AWARENESS_CONTEXT` for various functions, including
 * this one. If unset, this defaults to -4.
 * @returns {Integer} - If successful, returns the original thread `DPI_AWARENESS_CONTEXT`. If
 * unsuccessful, returns an empty string or 0.
 */
SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT := DPI_AWARENESS_CONTEXT_DEFAULT ?? -4) {
    if IsValidDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
        return DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
    }
}
