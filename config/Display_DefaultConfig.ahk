/**
 * I don't recommend modifying the configuration here. It's better to create a copy of the
 * configuration file `Display_Template_ProjectConfig.ahk` and use that, because this will get
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

class Display_DefaultConfig {
    ; see `DisplayConfig.ahk` for details
    static NewControlSetFont := 1
    static NewGuiSetFont := true
    static NewGuiCall := true
    static NewGuiAdd := true
    static ExcludeNewGuiAddType := false
    static DpiExcludeControls := false
    static DefaultExcludeGui := false
    static GetTextExtent := Map(
        'Link', GUI_CONTROL_TEXTEXTENT_LINK
      , 'ListBox', GUI_CONTROL_TEXTEXTENT_LISTBOX
      , 'ListView', GUI_CONTROL_TEXTEXTENT_LISTVIEW
      , 'TreeView', GUI_CONTROL_TEXTEXTENT_TREEVIEW
      , 'Button', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'CheckBox', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'ComboBox', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'DDl', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'Edit', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'GroupBox', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'Radio', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'StatusBar', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'Tab', GUI_CONTROL_TEXTEXTENT_TEXT
      , 'Text', GUI_CONTROL_TEXTEXTENT_TEXT
    )
    static ResizeByText := ['Button', 'CheckBox', 'ComboBox', 'DDl', 'Edit', 'GroupBox', 'Radio', 'StatusBar', 'Tab', 'Text']
}
