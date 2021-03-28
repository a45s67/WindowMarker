
Log(func,msg){
  OutputDebug, [%func%]%msg%
}

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



class WindowMarker{
  last_activate_winobj := {}

  marked_winobj_map := {}

  MarkFocuseWindow(mark_key := "a"){
    WinGet, getid, ID, A
    this.marked_winobj_map[mark_key] := new WindowObject(getid)
    
    log := Format("mark_key: {:s}, focused id: {:x}",mark_key,this.marked_winobj_map[mark_key].info.id)
    Log("MarkFocusWindow", log)

  }

  ToggleWindow(mark_key := "a"){

    winobj := this.marked_winobj_map[mark_key]

    If (winobj.IsActivate()){
      Log("ToggleWindow","Toggle window is Activate! So Toggle last window: " this.last_activate_winobj.info.id)
      this.last_activate_winobj.Activate()
      this.last_activate_winobj := winobj
      Log("ToggleWindow","Now last is: " winobj.info.id)
    }
    Else{
      Log("ToggleWindow","marked window is not activate")

      WinGet, last_id, ID, A
      this.last_activate_winobj := new WindowObject(last_id)

      winobj.Activate()
    }
  }

  MarkOrToggleWindow(mark_key := "a"){
    Log("MarkOrToggle","=====start=====")
    Log("MarkOrToggle","Toggle Markey: " mark_key)
    If (this.marked_winobj_map[mark_key] == ""){
      this.MarkFocuseWindow(mark_key)
    }
    Else{
      this.ToggleWindow(mark_key)
    }
    Log("MarkOrToggle","=====end=====")
  }
  RemoveMark(mark_key := "a"){
    this.marked_winobj_map[mark_key] := ""
    Log("RemoveMark","Remove: " mark_key)
  }

}


marker := new WindowMarker()
!m::marker.MarkFocuseWindow()
!a::marker.ToggleWindow()

!0::marker.MarkOrToggleWindow("0")
!1::marker.MarkOrToggleWindow("1")
!2::marker.MarkOrToggleWindow("2")
!3::marker.MarkOrToggleWindow("3")
!4::marker.MarkOrToggleWindow("4")
!5::marker.MarkOrToggleWindow("5")
!6::marker.MarkOrToggleWindow("6")
!7::marker.MarkOrToggleWindow("7")
!8::marker.MarkOrToggleWindow("8")
!9::marker.MarkOrToggleWindow("9")

^!0::marker.RemoveMark("0")
^!1::marker.RemoveMark("1")
^!2::marker.RemoveMark("2")
^!3::marker.RemoveMark("3")
^!4::marker.RemoveMark("4")
^!5::marker.RemoveMark("5")
^!6::marker.RemoveMark("6")
^!7::marker.RemoveMark("7")
^!8::marker.RemoveMark("8")
^!9::marker.RemoveMark("9")
