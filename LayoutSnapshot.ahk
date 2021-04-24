#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%



class WindowObject{
  info := {}

  __New(id){
    this.info.id:=id
    Log("WindowsObject", "Construct: " id)
  }
  __Delete(){
    Log("WindowsObject", "obj: " this.info.id ", Destruct. " )
  }
  Activate(){
    WinActivate, % "ahk_id" this.info.id
    Log("WindowsObject", "obj: " this.info.id ", Activate. ")
  }
  IsActivate(){
    WinGet, getid, ID, A
    return getid == this.info.id
  }
}


class Layout{
    
    AddWinObj(winobj){

    }
}


Log(func,msg){
  OutputDebug, [%func%]%msg%
}

windows := {}

SetList(){
    global windows
    WinGet windows, List
    ; Log "main", windows
    Loop %windows%
    {
        id := windows%A_Index%
        WinGetTitle wt, ahk_id %id%
        Log("main", wt . "`n")
    }
    ; DetectHiddenWindows, Off
}

MinimizeWindow(){
    global windows    
    Loop %windows%
    {
        id := windows%A_Index%
        WinGetTitle wt, ahk_id %id%
        if (A_Index > 3 ) {
            Log("Minimize",wt)
            WinMinimize,  ahk_id %id%
        }
    }
}

RestoreWindow(){
    global windows    
    Loop %windows%
    {
        id := windows%A_Index%
        WinGetTitle wt, ahk_id %id%
        if (A_Index > 3 ) {
            Log("Restore",wt)
            WinRestore,  ahk_id %id%
        }
    }

}

SetList()

!h::MinimizeWindow()
!r::RestoreWindow()