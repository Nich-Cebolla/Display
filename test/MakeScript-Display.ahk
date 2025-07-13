
#include <TestInterfaceConfig>

; #Include any scripts


; ~~~ End config

Filter := PropsInfo.FilterGroup()

; Filter := PropsInfo.FilterGroup(FilterFunc)

; FilterFunc(InfoItem) {

; }

; ~~~ End filters

; include any extra files that aren't #included above

; paths := [
; ]

; Dirs := [
; ]
; paths := RecursiveGetFiles(Dirs, , paths ?? unset)

NameTestInterface := ''
Exclude := '__Init,Prototype,Base'

; ~~~ End config


RecursiveGetFiles(Dirs, opt := 'FR', paths?) {
    if !IsSet(paths) {
        paths := []
    }
    for Dir in Dirs {
        loop Files Dir '\*', opt {
            if SubStr(A_LoopFileName, 1, 1) == '.' {
                continue
            }
            if A_LoopFileExt = 'ahk' {
                paths.Push(A_LoopFileFullPath)
            }
        }
    }
    return paths
}

; ~~~ End paths

Content := FileRead(A_ScriptFullPath)
pos1 := InStr(Content, '; ~~~ End config')
pos2 := InStr(Content, '; ~~~ End filters')
Indent := '`s`s`s`s`s`s`s`s'
codeHeader := Trim(SubStr(Content, 1, pos1 - 1), '`r`n')
codeHeaderPart := ''
for path in paths {
    codeHeaderPart .= '#include ' path '`n'
}
codeFilters := ''
for line in StrSplit(Trim(SubStr(Content, pos1 + 18, pos2 - pos1 - 18), '`r`n'), '`n', '`r') {
    codeFilters .= Indent line '`n'
}

pos := 1
while RegExMatch(codeHeader, '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>\w+)\b', &Match, pos) {
    pos := Match.Pos + Match.Len
    paths.Push(Match)
}
codeHeader .= '`n' codeHeaderPart

AllSubjects := Map()

for path in paths {
    if path is RegExMatchInfo {
        if path['drive'] {
            fullPath := path[0]
        } else {
            loop Files path[0] {
                fullPath := A_LoopFileFullPath
            }
        }
        name := path['file']
    } else {
        SplitPath(path, , , , &name, &Drive)
        if Drive {
            fullPath := path
        } else {
            loop Files path {
                fullPath := A_LoopFileFullPath
            }
        }
    }
    if instr(name, 'dgui') {
        sleep 1
    }
    AllSubjects.Set(fullPath, obj := {})
    obj.ScriptParser := ScriptParser(fullPath)
    obj.FileName := name
    obj.Fullpath := fullPath
    obj.Subjects := TestInterface.SubjectCollection.FromScriptParser(
        obj.ScriptParser
        ; SubjectCollectionObj
      , unset
        ; Filter
      , Filter.Count ? Filter : unset
        ; Functions
      , true
        ; Classes
      , true
        ; StopAt
      , unset
        ; Exclude
      , Exclude
        ; ExcludeMethods
      , false
    )
}

code := (
    codeHeader
    '`n`ntest()`n`n'
    'class test {`n'
    '    static Call() {`n'
    codeFilters
    Indent 'Subjects := TestInterface.SubjectCollection()`n'
    '`n'
)

for path, obj in AllSubjects {
    scriptName := 'Script' A_Index
    code .= (
        Indent '; ' obj.FileName '`n'
        Indent scriptName ' := ScriptParser(`'' obj.FullPath '`')`n'
        obj.Subjects.ToInitialValuesCode(
            ; FunctionInitialValue
            '"a"'
            ; MethodInitialValue
          , ', "a"'
            ; PropGetInitialValue
          , ', "a"'
            ; PropSetInitialValue
          , ', "a"'
            ; GetPropsInfoParams
          , ', `'' Exclude '`', false'
            ; SubjectsVar
          , 'Subjects'
            ; ScriptParserVar
          , scriptName
            ; FilterVar
          , 'Filter'
            ; Indent
          , Indent
        )
    )
}

code .= (
    '`n' Indent 'TI := this.TI := TestInterface(`'' NameTestInterface '`', Subjects)`n'
    '`n`s`s`s`s}'
    '`n}'
)

A_Clipboard := code
