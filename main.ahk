Log(func,msg){
  OutputDebug, [%func%]%msg%
}


CheckDllError(){
  if ErrorLevel{
    Log("DLL", "err" ErrorLevel)
  }
}


handle_virtual_desktop := DllCall("LoadLibrary", "Str", "VirtualDesktopAccessor.dll", "Ptr") 
CheckDllError()

GoToDesktopNumber := DllCall("GetProcAddress", "Ptr", handle_virtual_desktop, "AStr", "GoToDesktopNumber", "Ptr")
CheckDllError()

GetCurrentDesktopNumber  := DllCall("GetProcAddress", Ptr, handle_virtual_desktop, AStr, "GetCurrentDesktopNumber", "Ptr")
CheckDllError()


; hVirtualDesktopAccessor := DllCall("LoadLibrary", Str, "C:\Users\Fish\github\WindowMarker\VirtualDesktopAccessor.dll", "Ptr") 
; GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
; GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")



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

class WindowState extends WindowObject{
  __New(id){
    this.info.id:=id
    Log("WindowsState", "Construct: " id)
  }
  __Delete(){
    Log("WindowsState", "obj: " this.info.id ", Destruct. " )
  }
}

class WindowMarker{
  last_activate_winobj := {}

  marked_winobj_map := {}
  __New(){
    Log("WindowMarker","Create Marker")
  }
  __Delete(){
    Log("WindowMarker","Destruct Marker")
  }
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


class StateRecorder{
  winobj_map := {}
  RestoreStates(){

      
  }
  Insert(id){

  }
  Get(id){

  }
  Delete(id){

  }

}

class Layout{
  marker := new WindowMarker()
  window_states := new StateRecoder()
  ;======= marker ======
  MarkOrToggleWindow(key){
    this.marker.MarkOrToggleWindow(key)
  }
  RemoveMark(key){
    this.marker.RemoveMark(key)
  }
  ;======= state ========
  RecodeFocusedWindow(){
    WinGet, id, ID, A
    this.window_states.Insert(id) 
  }
  DetachFocusedWindow(){
    WinGet, id, ID, A
    this.window_states.Delete(id) 
  }
  RestoreRecodedLayout(){
    this.window_states.RestoreStates() 
  }
}



class DesktopUtil{
  markers := {}

  GetCurrentDesktopNumber(){
    global GetCurrentDesktopNumber,GoToDesktopNumber
    id := DllCall(GetCurrentDesktopNumber,UInt)
    return id
  }

  SetDesktopRecoder(){
    id := this.GetCurrentDesktopNumber()
    if (!this.markers.HasKey(id)){
      this.markers[id] := new WindowMarker()
      Log("SetDesktopRecoder","new desk recode " id)
    }
    Log("SetDesktopRecoder","cur id " id)
  }

  MarkOrToggleWindow(key){
    this.SetDesktopRecoder()

    id := this.GetCurrentDesktopNumber()

    marker := this.markers[id]
    marker.MarkOrToggleWindow(key)
  }

  RemoveMark(key){
    this.SetDesktopRecoder()

    id := this.GetCurrentDesktopNumber()

    marker := this.markers[id]
    marker.RemoveMark(key)

  }
  SwitchToDesktop(key){
    global GetCurrentDesktopNumber,GoToDesktopNumber
    DllCall(GoToDesktopNumber,UInt,key)
    Log("DesktopUtil - SwitchToDesktop", key)
  }

}



marker := new WindowMarker()
desktop_util := new DesktopUtil()


Loop ,7
{
  key := A_Index

  ; SetUpHotkey("#" . key, desktop_util.SwitchToDesktop(key)) 
  ; SetUpHotkey("!" . key, desktop_util.MarkOrToggleWindow(key)) 
  ; SetUpHotkey("^!" . key, desktop_util.RemoveMark(key)) 
  Hotkey, #%key%, SetKeyBindSwitchToDesktop
  Hotkey, !%key%, SetKeyBindMarkOrToggleWindow
  Hotkey, ^!%key%, SetKeyBindRemoveMark

}

SetKeyBindSwitchToDesktop:
  desktop_util.SwitchToDesktop(SubStr(A_ThisHotkey,2) - 1)
return 

SetKeyBindMarkOrToggleWindow:
  desktop_util.MarkOrToggleWindow(A_ThisHotkey)
return 

SetKeyBindRemoveMark:
  desktop_util.RemoveMark(A_ThisHotkey)
return 


#::return

; #0::desktop_util.SwitchToDesktop("0")

; #1::desktop_util.SwitchToDesktop("1")

; !0::desktop_util.MarkOrToggleWindow("0")
; !1::desktop_util.MarkOrToggleWindow("1")
; !2::desktop_util.MarkOrToggleWindow("2")
; !3::desktop_util.MarkOrToggleWindow("3")
; !4::desktop_util.MarkOrToggleWindow("4")


; SetUpHotkey(hk, handler) 
; !m::marker.MarkFocuseWindow()
; !a::marker.ToggleWindow()

; !0::marker.MarkOrToggleWindow("0")
; !1::marker.MarkOrToggleWindow("1")
; !2::marker.MarkOrToggleWindow("2")
; !3::marker.MarkOrToggleWindow("3")
; !4::marker.MarkOrToggleWindow("4")
; !5::marker.MarkOrToggleWindow("5")
; !6::marker.MarkOrToggleWindow("6")
; !7::marker.MarkOrToggleWindow("7")
; !8::marker.MarkOrToggleWindow("8")
; !9::marker.MarkOrToggleWindow("9")

; ^!0::marker.RemoveMark("0")
; ^!1::marker.RemoveMark("1")
; ^!2::marker.RemoveMark("2")
; ^!3::marker.RemoveMark("3")
; ^!4::marker.RemoveMark("4")
; ^!5::marker.RemoveMark("5")
; ^!6::marker.RemoveMark("6")
; ^!7::marker.RemoveMark("7")
; ^!8::marker.RemoveMark("8")
; ^!9::marker.RemoveMark("9")

