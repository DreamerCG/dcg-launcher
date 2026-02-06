#SingleInstance Force

Run('Demul.exe -run=' A_Args[1] ' -rom=' A_Args[2])

WinWait("FPS")
WinActivate()
WinWaitActive()

; Sleep 1 second then send Alt+Enter to toggle fullscreen
Sleep 1000
Send("{Alt down}{Enter}{Alt up}")
Sleep 2000

; Reactivate window after fullscreen toggle
;WinActivate(,"Star")
;WinWaitActive(,"Star")
WinActivate()
WinWaitActive()
Sleep 1000

; Start timer to check if demul.exe is running every second
SetTimer(CheckDemulProcess, 1000)

;--------------------------------------
; Hotkey: Alt+F4 triggers all mouse buttons down/up
!F4::
{
    MouseClick("Left", , , , "D")
    MouseClick("Right", , , , "D")
    MouseClick("Middle", , , , "D")
    Sleep 100
    MouseClick("Left", , , , "U")
    MouseClick("Right", , , , "U")
    MouseClick("Middle", , , , "U")
    return
}

;--------------------------------------
CheckDemulProcess(*) {
    if !ProcessExist("demul.exe")
        ExitApp()
}

ProcessExist(name) {
    ; Returns true if process is running
    wmi := ComObjGet("winmgmts:")
    ps := wmi.ExecQuery("Select * from Win32_Process Where Name='" name "'")
    return ps.Count > 0
}
