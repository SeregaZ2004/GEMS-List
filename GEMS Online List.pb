; PB 5.60

Enumeration
  #Window         ; 0
  
  #GetListButton  ; 1
  #ListGadget     ; 2
  
  #WinCancel
  #WinCancelBut
  #WinCancelProgress
EndEnumeration

InitNetwork() ; we will work with network

Structure sgg
  gamename$
  gameurl$
  gamesize.l
EndStructure  
Global Dim ServerGames.sgg(0) ; global array for game names and them url and size
Global otvetservera$          ; global value for server's answer - page with a list of games

Global NetworkThread          ; additional thread process id 

Procedure CancelWindowProc()
  
  DisableWindow(#Window, 1)
  
  If OpenWindow(#WinCancel, 100, 100, 150, 65, "", #PB_Window_WindowCentered|#PB_Window_BorderLess, WindowID(#Window))
    ButtonGadget(#WinCancelBut, 0, 0, 150, 60, "Cancel")
    ProgressBarGadget(#WinCancelProgress, 0, 60, 150, 5, 0, 100)
    
    Repeat
     Select WaitWindowEvent()

       Case #PB_Event_Gadget

         Select EventGadget()
           
           Case #WinCancelBut ;{ cancel button
             If EventType() = #PB_EventType_LeftClick
               If IsThread(NetworkThread)
                 KillThread(NetworkThread)
               EndIf
               cancelqiut = 1
             EndIf
             ;}
             
         EndSelect
         
         Case #PB_Event_CloseWindow
           cancelqiut = 1
         
      EndSelect 
     
    Until cancelqiut = 1
    
    CloseWindow(#WinCancel)
    UseGadgetList(WindowID(#Window))
    
  EndIf  
  
  DisableWindow(#Window, 0)
  
EndProcedure

;- GEMS ONLINE
Procedure GetGEMSListNET(*Value)
  
  ; reset value
  otvetservera$ = "" 
  
  ; get page into memory
  *Buffer = ReceiveHTTPMemory("https://raw.githubusercontent.com/SeregaZ2004/GEMS-List/master/list.txt")
  If *Buffer
    
    ; get size of memory
    Size = MemorySize(*Buffer)
    ; read as text
    otvetservera$ = PeekS(*Buffer, Size, #PB_UTF8)
    ; clear memory
    FreeMemory(*Buffer)
    
    If FindString(otvetservera$, "--beginfile")
      ; some kind of header - to know sure it is correct info
      
      ; reset list of games
      ReDim ServerGames(0)
      
      finish = 2 ; 2 to miss first string - "--beginfile"
      Repeat
        tmp$ = StringField(otvetservera$, finish, Chr(10))
        
        If tmp$ And FindString(tmp$, "//")
          ; get existing size of array
          tik = ArraySize(ServerGames()) + 1
          ; resize array
          ReDim ServerGames(tik)
          ; split string into values for games array
          ServerGames(tik)\gamename$ = StringField(tmp$, 1, "//")
          ServerGames(tik)\gameurl$  = StringField(tmp$, 2, "//")
          ServerGames(tik)\gamesize  = Val(StringField(tmp$, 3, "//"))
        EndIf
        
        finish + 1 ; to next string

      Until tmp$ = ""
      
      otvetservera$ = "ok"
      
    Else
      otvetservera$ = "Cant get data"
    EndIf
    
  EndIf 
  
  If otvetservera$ = "ok"
    ; everything is ok, fill all list of games in a gadget
    For i = 1 To ArraySize(ServerGames())
      AddGadgetItem(#ListGadget, -1, ServerGames(i)\gamename$)
    Next
  EndIf
  
  ; send close window to cancel window
  PostEvent(#PB_Event_CloseWindow, #WinCancel, 0)
  
EndProcedure



If OpenWindow(#Window, 100, 100, 270, 250, "GEMS Online Database")
  
  ButtonGadget(#GetListButton, 10, 10, 250, 20, "get list")
  
  ListIconGadget(#ListGadget, 10, 40, 250, 200, "game", 230)
  
  Repeat
     Select WaitWindowEvent()

       Case #PB_Event_Gadget

         Select EventGadget()
           
           Case #GetListButton ;{ click on get list button
             If EventType() = #PB_EventType_LeftClick
               ; clear old list of games
               ClearGadgetItems(#ListGadget)
               
               ; start additional thread to avoid hung main window
               NetworkThread = CreateThread(@GetGEMSListNET(), *Value)
               If NetworkThread 
                 ; thread start fine
                 
                 ; show cancel window
                 CancelWindowProc()
                               
               Else
                 MessageRequester("Error!", "Problem with thread organization")
               EndIf
             EndIf
             ;}
             
           Case #ListGadget ;{
             If EventType() = #PB_EventType_LeftDoubleClick
               sz = ArraySize(ServerGames())
               If sz
                 ; array is exist
                 
                 ; get selected item
                 num = GetGadgetState(#ListGadget)
                 If num > -1
                   ; -1 it is empty select
                   
                   num + 1 ; array starts from 1, but gadget num is from 0
                   Debug ServerGames(num)\gameurl$
                   
                 EndIf
                 
               EndIf
             EndIf
             ;}
             
         EndSelect

       Case #PB_Event_CloseWindow         
         qiut = 1
   
     EndSelect
   Until qiut = 1

EndIf

End
; IDE Options = PureBasic 5.60 (Windows - x86)
; Folding = -
; EnableThread
; EnableXP
; EnableUser