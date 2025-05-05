/**
 * I don't recommend modifying the configuration here. It's better to create a copy of the
 * configuration file `ProjectConfig.ahk` and use that, because this will get
 * reset every time it updates.
 */

if !IsSet(DPI_AWARENESS_CONTEXT_DEFAULT) {
    DPI_AWARENESS_CONTEXT_DEFAULT := -4
}
if !IsSet(MDT_DEFAULT) {
    MDT_DEFAULT := 0
}
if IsSet(Mon) && !dMon.HasOwnProp('UseOrderedMonitors') {
    dMon.UseOrderedMonitors := true
}

class DefaultConfig {

   static OverrideControlSetFont := true
   , OverrideGuiSetFont := true
   , OverrideGuiAdd := true
   , ControlIncludeByDefault := true
   , GetTextExtent := true
   , GetTextExtentEx := true
   , GuiCount := true
   , GuiDpiExclude := true
   , HandleDpiChanged := true
   , ResizeByText := ['Button', 'Edit', 'Link', 'StatusBar', 'Text']
   , GuiToggle := true
   , GuiCallWith_S := true
   , ControlCallWith_S := true
   , GuiDpi := true
   , ControlDpi := true

}
