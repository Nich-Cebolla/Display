
class Display_DefaultConfig {
    ; see `DisplayConfig.ahk` for details
    static NewControlSetFont := 1
    static NewGuiSetFont := true
    static NewGuiCall := true
    static NewGuiAdd := true
    static ExcludeNewGuiAddType := false
    static DpiExcludeControls := false
    static DefaultExcludeGui := false
    static SetGetTextExtent() {
        M := this.GetTextExtent := Map()
        M.CaseSense := false
        M.Default := ''
        M.Set(
            'Link', GUI_CONTROL_TEXTEXTENT_LINK
        , 'ListBox', GUI_CONTROL_TEXTEXTENT_MULTI
        , 'ListView', GUI_CONTROL_TEXTEXTENT_LISTVIEW
        , 'TreeView', GUI_CONTROL_TEXTEXTENT_INDEX
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
    }
    static GetTextExtent := this.SetGetTextExtent()
    static ResizeByText := ['Button', 'CheckBox', 'ComboBox', 'DDl', 'Edit', 'GroupBox', 'Radio'
        , 'StatusBar', 'Tab', 'Text']
}
