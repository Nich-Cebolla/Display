# Display
An AutoHotkey (AHK) library that provides tools for deploying attractive, user-friendly user interfaces with minimal code.

This is a work in progress and will change frequently while I finish it. If you use this library in a project, do not use your git clone directory for the project. I will break things as I release updates.

# Tested and working

The following functions have been tested to verify that they work and appear to do what they are expected to do, but they have not been fully validated and do not have a dedicated unit test.

## lib

### ComboBox.ahk

- CbFilter: A class that filters items in a ComboBox control as a function of the text in the ComboBox's edit control.
  - CbFilter.Prototype.__New: Creates an instance of `CbFilter`.
  - CbFilter.Prototype.Add: Adds a string to the control.
  - CbFilter.Prototype.Delete: Deletes a string from the control.
  - CbFilter.Prototype.Dispose: Deletes the filter and associated properties to allow the resources to be freed.
  - CbFilter.Prototype.HChangeComboBox: The event handler for the "Change" event. Initiates the filter function.
  - CbFilter.Prototype.HFocusComboBox: The event handler for the "Focus" event. Expands the dropdown.

### ControlTextExtent.ahk

