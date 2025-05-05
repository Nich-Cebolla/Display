/**
 * I don't recommend modifying the configuration here. It's better to create a copy of the
 * configuration file `Template_ProjectConfig.ahk` and use that, because this will get
 * reset every time it updates.
 */

if !IsSet(DPI_AWARENESS_CONTEXT_DEFAULT) {
    DPI_AWARENESS_CONTEXT_DEFAULT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 ?? -4
}
if !IsSet(MDT_DEFAULT) {
    MDT_DEFAULT := MDT_EFFECTIVE_DPI ?? 0
}
if IsSet(Mon) && !dMon.HasOwnProp('UseOrderedMonitors') {
    dMon.UseOrderedMonitors := false
}

class DefaultConfig {
    ; see `DisplayConfig.ahk` for details
    static NewControlSetFont := 1
    static NewGuiSetFont := true
    static NewGuiCall := true
    static NewGuiAdd := true
    static ExcludeNewGuiAddType := false
    static DpiExcludeControls := false
    static DefaultExcludeGui := false
    static GetTextExtent := true
    static ResizeByText := ['Button', 'CheckBox', 'ComboBox', 'DDl', 'Edit', 'GroupBox', 'Radio', 'StatusBar', 'Tab', 'Text']
}
